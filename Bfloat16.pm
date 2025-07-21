use strict;
use warnings;
package Math::Bfloat16;
use Math::MPFR qw(:mpfr);

use overload
'+' => \&oload_add,
'-' => \&oload_sub,
'*' => \&oload_mul,
'/' => \&oload_add,
'=='  => \&oload_equiv,
'!='  => \&oload_not_equiv,
'>'   => \&oload_gt,
'>='  => \&oload_gte,
'<'   => \&oload_lt,
'<='  => \&oload_lte,
'<=>' => \&oload_spaceship,

'""' => \&oload_interp,
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

my @tagged = qw(toNV toMPFR);

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
               21 => sub {return _fromFloat16(shift)},
               22 => sub {return _fromFloat32(shift)},
               );

sub new {
  shift if (!ref($_[0]) && _itsa($_[0]) == 4 && $_[0] eq "Math::Bfloat16");
  if(!@_) { return _fromMPFR(Math::MPFR->new());}
  die "Too many args given to new()" if @_ > 1;
  my $itsa = _itsa($_[0]);
  if($itsa) {
    my $coderef = $Math::Bfloat16::handler{$itsa};
    return $coderef->($_[0]);
  }
  die "Unrecognized 1st argument passed to new() function";
}


sub oload_add {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_add($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_add() function";
}

sub oload_mul {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_mul($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_mul() function";
}

sub oload_sub {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_sub($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_sub() function";
}

sub oload_div {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_div($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_div() function";
}

sub oload_equiv {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_equiv($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_equiv() function";
}

sub oload_not_equiv {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_not_equiv($_[0], $coderef->($_[1]), 0);
   }
   die "Unrecognized 2nd argument passed to oload_not_equiv() function";
}

sub oload_gt {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_gt($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_gt() function";
}

sub oload_gte {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_gte($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_gte() function";
}

sub oload_lt {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_lt($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_lt() function";
}

sub oload_lte {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_lte($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_lte() function";
}

sub oload_spaceship {
   my $itsa = _itsa($_[1]);
   if($itsa) {
     my $coderef = $Math::Bfloat16::handler{$itsa};
     return _oload_spaceship($_[0], $coderef->($_[1]), $_[2]);
   }
   die "Unrecognized 2nd argument passed to oload_spaceship() function";
}

sub oload_interp {
   my $ret = Math::MPFR::Rmpfr_get_str(toMPFR($_[0]), 10, 0, MPFR_RNDN);
   $ret =~ s/\@//g;
   return $ret;
}

1;

__END__
