use strict;
use warnings;
use Math::Bfloat16 qw(:all);

use Test::More;

my($have_gmpf, $have_gmpq) = (0, 0);

eval { require Math::GMPf };
$have_gmpf = 1 unless $@;

eval { require Math::GMPq };
$have_gmpq = 1 unless $@;

my $mpfr = Math::MPFR->new(3.875);

my @inputs = ('1.5', '-1.75', 2.625, Math::Bfloat16->new($mpfr), 42);

if($have_gmpf) {
  my $f = Math::GMPf->new(5.25);
  push (@inputs, Math::Bfloat16->new($f));
}
if($have_gmpq) {
  my $q = Math::GMPq->new('3/4');
  push(@inputs, Math::Bfloat16->new($q));
}

my $nan = Math::Bfloat16->new();

for my $v (@inputs) {
  my $add = $nan + $v;
  cmp_ok(is_bfloat16_nan($add), '==', 1, "NaN + $v is NaN");

  my $mul = $nan * $v;
  cmp_ok(is_bfloat16_nan($mul), '==', 1, "NaN * $v is NaN");

  my $sub = $nan - $v;
  cmp_ok(is_bfloat16_nan($sub), '==', 1, "NaN - $v is NaN");

  my $div = $nan / $v;
  cmp_ok(is_bfloat16_nan($div), '==', 1, "NaN / $v is NaN");
}

for my $v (@inputs) {
  my $add = $v + $nan;
  cmp_ok(is_bfloat16_nan($add), '==', 1, "$v + NaN is NaN");

  my $mul = $v * $nan;
  cmp_ok(is_bfloat16_nan($mul), '==', 1, "$v * NaN  is NaN");

  my $sub = $v - $nan;
  cmp_ok(is_bfloat16_nan($sub), '==', 1, "$v - NaN is NaN");

  my $div = $v / $nan;
  cmp_ok(is_bfloat16_nan($div), '==', 1, "$v / NaN is NaN");
}

###############
# Error Tests #
###############

eval{ my $x = Math::Bfloat16->new(1) + Math::MPFR->new(25);};
like($@, qr/^Unrecognized 2nd argument passed/, "+ Math::MPFR object: \$\@ set as expected");

eval{ my $x = Math::Bfloat16->new() - Math::MPFR->new(25);};
like($@, qr/^Unrecognized 2nd argument passed/, "- Math::MPFR object: \$\@ set as expected");

eval{ my $x = Math::Bfloat16->new() * Math::MPFR->new(25);};
like($@, qr/^Unrecognized 2nd argument passed/, "* Math::MPFR object: \$\@ set as expected");

eval{ my $x = Math::Bfloat16->new() / Math::MPFR->new(25);};
like($@, qr/^Unrecognized 2nd argument passed/, "/ Math::MPFR object: \$\@ set as expected");

if($have_gmpf) {
  eval{ my $x = Math::Bfloat16->new() + Math::GMPf->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "+ Math::GMPf object: \$\@ set as expected");

  eval{ my $x = Math::Bfloat16->new(1) - Math::GMPf->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "- Math::GMPf object: \$\@ set as expected");

  eval{ my $x = Math::Bfloat16->new() * Math::GMPf->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "* Math::GMPf object: \$\@ set as expected");

  eval{ my $x = Math::Bfloat16->new() / Math::GMPf->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "/ Math::GMPf object: \$\@ set as expected");
}

if($have_gmpq) {
  eval{ my $x = Math::Bfloat16->new() + Math::GMPq->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "+ Math::GMPq object: \$\@ set as expected");

  eval{ my $x = Math::Bfloat16->new() - Math::GMPq->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "- Math::GMPq object: \$\@ set as expected");

  eval{ my $x = Math::Bfloat16->new(1) * Math::GMPq->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "* Math::GMPq object: \$\@ set as expected");

  eval{ my $x = Math::Bfloat16->new() / Math::GMPq->new(25);};
  like($@, qr/^Unrecognized 2nd argument passed/, "/ Math::GMPq object: \$\@ set as expected");
}

done_testing();

__END__
