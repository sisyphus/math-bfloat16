use strict;
use warnings;
package Math::Bfloat16;
use Math::MPFR qw(:mpfr);

use constant bf16_EMIN     => -132;
use constant bf16_EMAX     =>  128;
use constant bf16_MANTBITS =>    8;


use overload
'+'  => \&oload_add,
'-'  => \&oload_sub,
'*'  => \&oload_mul,
'/'  => \&oload_div,
'%'  => \&oload_fmod,
'**' => \&oload_pow,

'=='  => \&oload_equiv,
'!='  => \&oload_not_equiv,
'>'   => \&oload_gt,
'>='  => \&oload_gte,
'<'   => \&oload_lt,
'<='  => \&oload_lte,
'<=>' => \&oload_spaceship,

'abs'  => \&oload_abs,
'""'   => \&oload_interp,
 # The above overload subs are in Bfloat16.pm.
 # The below overload subs are in Bfloat16.xs.
'sqrt' => \&_oload_sqrt,
'exp'  => \&_oload_exp,
'log'  => \&_oload_log,
'int'  => \&_oload_int,
'!'    => \&_oload_not,
'bool' => \&_oload_bool,
;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

our $VERSION = '0.01';
Math::Bfloat16->DynaLoader::bootstrap($VERSION);

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

if(Math::MPFR::MPFR_VERSION < 262912 || !Math::MPFR::Rmpfr_buildopt_bfloat16_p()) {
  warn "Aborting: The underlying mpfr library (", Math::MPFR::MPFR_VERSION_STRING, ") does not support the __bf16 type";
  exit 0;
}

my @tagged = qw( bf16_to_NV bf16_to_MPFR
                 is_bf16_nan is_bf16_inf is_bf16_zero bf16_set_nan bf16_set_inf bf16_set_zero
                 bf16_set
                 bf16_nextabove bf16_nextbelow
                 unpack_bf16_hex
                 bf16_EMIN bf16_EMAX bf16_MANTBITS
               );

@Math::Bfloat16::EXPORT = ();
@Math::Bfloat16::EXPORT_OK = @tagged;
%Math::Bfloat16::EXPORT_TAGS = (all => \@tagged);


%Math::Bfloat16::handler = (1 => sub {print "OK: 1\n"},
               2  => sub {return _fromIV(shift)},
               4  => sub {return _fromPV(shift)},
               3  => sub {return _fromNV(shift)},
               5  => sub {return _fromMPFR(shift)},
               6  => sub {return _fromGMPf(shift)},
               7  => sub {return _fromGMPq(shift)},

               20 => sub {return _fromBfloat16(shift)},
               );

$Math::Bfloat16::bf16_DENORM_MIN = Math::Bfloat16->new(2) ** (bf16_EMIN - 1);                   # 9.184e-41
$Math::Bfloat16::bf16_DENORM_MAX = Math::Bfloat16->new(_get_denorm_max());                      # 1.166e-38
$Math::Bfloat16::bf16_NORM_MIN   = Math::Bfloat16->new(2) ** (bf16_EMIN + (bf16_MANTBITS - 2)); # 1.175e-38
$Math::Bfloat16::bf16_NORM_MAX   = Math::Bfloat16->new(_get_norm_max());                        # 3.39e38

_XS_set_emin(bf16_EMIN);
_XS_set_emax(bf16_EMAX);

sub new {
   shift if (@_ > 0 && !ref($_[0]) && _itsa($_[0]) == 4 && $_[0] eq "Math::Bfloat16");
   if(!@_) { return _fromMPFR(Math::MPFR->new());}
   die "Too many args given to new()" if @_ > 1;
   my $itsa = _itsa($_[0]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return $coderef->($_[0]);
   }
   die "Unrecognized 1st argument passed to new() function";
}

sub bf16_set {
   die "bf16_set expects to receive precisely 2 arguments" if @_ != 2;
   my $itsa = _itsa($_[1]);
   if($itsa == 20) { _bf16_set(@_) }
   else {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     _bf16_set( $_[0], $coderef->($_[1]));
   }
}

sub oload_add {
   my $itsa = _itsa($_[1]);
   return _oload_add(@_) if $itsa == 20;
   if($itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_add($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_add() function";
}

sub oload_mul {
   my $itsa = _itsa($_[1]);
   return _oload_mul(@_) if $itsa == 20;
   if($itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_mul($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_mul() function";
}

sub oload_sub {
   my $itsa = _itsa($_[1]);
   return _oload_sub(@_) if $itsa == 20;
   if($itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_sub($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_sub() function";
}

sub oload_div {
   my $itsa = _itsa($_[1]);
   return _oload_div(@_) if $itsa == 20;
   if($itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_div($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_div() function";
}

sub oload_pow {
   my $itsa = _itsa($_[1]);
   return _oload_pow(@_) if $itsa == 20;
   if($itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_pow($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_pow() function";
}

sub oload_fmod {
   my $itsa = _itsa($_[1]);
   return _oload_fmod(@_) if $itsa == 20;
   if($itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_fmod($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_fmod() function";
}

sub oload_abs {
  return $_[0] * -1 if $_[0] < 0;
  return $_[0];
}

sub oload_equiv {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_equiv($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_equiv() function";
}

sub oload_not_equiv {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_not_equiv($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_not_equiv() function";
}

sub oload_gt {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_gt($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_gt() function";
}

sub oload_gte {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_gte($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_gte() function";
}

sub oload_lt {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_lt($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_lt() function";
}

sub oload_lte {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_lte($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_lte() function";
}

sub oload_spaceship {
   my $itsa = _itsa($_[1]);
   if($itsa == 20 || $itsa < 5) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_spaceship($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_spaceship() function";
}

sub oload_interp {
   my $ret = Math::MPFR::Rmpfr_get_str(bf16_to_MPFR($_[0]), 10, 0, MPFR_RNDN);
   $ret =~ s/\@//g;
   return $ret;
}

sub bf16_nextabove {
  if(is_bf16_zero($_[0])) {
    bf16_set($_[0], $Math::Bfloat16::bf16_DENORM_MIN);
  }
  elsif($_[0] < $Math::Bfloat16::bf16_NORM_MIN && $_[0] >= -$Math::Bfloat16::bf16_NORM_MIN ) {
    $_[0] += $Math::Bfloat16::bf16_DENORM_MIN;
    bf16_set_zero($_[0], -1) if is_bf16_zero($_[0]);
  }
  else {
    _bf16_nextabove($_[0]);
  }
}

sub bf16_nextbelow {
  if(is_bf16_zero($_[0])) {
    bf16_set($_[0], -$Math::Bfloat16::bf16_DENORM_MIN);
  }
  elsif($_[0] <= $Math::Bfloat16::bf16_NORM_MIN && $_[0] > -$Math::Bfloat16::bf16_NORM_MIN ) {
   $_[0] -= $Math::Bfloat16::bf16_DENORM_MIN;
  }
  else {
    _bf16_nextbelow($_[0]);
  }
}

sub unpack_bf16_hex {
  my @ret = _unpack_bf16_hex($_[0]);
  return join('', @ret);
}

sub _get_norm_max {
  my $ret = 0;
  for my $p(1 .. bf16_MANTBITS) { $ret += 2 ** (bf16_EMAX - $p) }
  return $ret;
}

sub _get_denorm_max {
  my $ret = 0;
  my $max = -(bf16_EMIN - 1);
  my $min = $max - (bf16_MANTBITS - 2);
  for my $p($min .. $max) { $ret += 2 ** -$p }
  return $ret;
}

1;

__END__
