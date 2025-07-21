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

my @inputs = ('1.5', '-1.75', 2.625, $mpfr, 42);
my @inputs_alt = ('1.5', '-1.75', 2.625, Math::Bfloat16->new($mpfr), 42);

if($have_gmpf) {
  my $f = Math::GMPf->new(5.25);
  push(@inputs, $f);
  push (@inputs_alt, Math::Bfloat16->new($f));
}
if($have_gmpq) {
  my $q = Math::GMPq->new('3/4');
  push(@inputs, $q);
  push(@inputs_alt, Math::Bfloat16->new($q));
}

my $nan = Math::Bfloat16->new();

for my $v (@inputs) {
  my $add = $nan + $v;
  cmp_ok(Math::Bfloat16::is_nan($add), '==', 1, "NaN + $v is NaN");

  my $mul = $nan * $v;
  cmp_ok(Math::Bfloat16::is_nan($mul), '==', 1, "NaN * $v is NaN");

  my $sub = $nan - $v;
  cmp_ok(Math::Bfloat16::is_nan($sub), '==', 1, "NaN - $v is NaN");

  my $div = $nan / $v;
  cmp_ok(Math::Bfloat16::is_nan($div), '==', 1, "NaN / $v is NaN");
}

for my $v (@inputs_alt) {
  my $add = $v + $nan;
  cmp_ok(Math::Bfloat16::is_nan($add), '==', 1, "$v + NaN is NaN");

  my $mul = $v * $nan;
  cmp_ok(Math::Bfloat16::is_nan($mul), '==', 1, "$v * NaN  is NaN");

  my $sub = $v - $nan;
  cmp_ok(Math::Bfloat16::is_nan($sub), '==', 1, "$v - NaN is NaN");

  my $div = $v / $nan;
  cmp_ok(Math::Bfloat16::is_nan($div), '==', 1, "$v / NaN is NaN");
}

done_testing();

__END__

for my $v (@inputs) {
  cmp_ok($nan, '!=', $v, "NaN != $v");
  cmp_ok(defined($nan <=> $v), '==', 0, "$v: spaceship operator returns undef");
}

for my $v (@inputs_alt) {
  cmp_ok($v, '!=', $nan, "$v != NaN");
  cmp_ok(defined($v <=> $nan), '==', 0, "$v (reversed): spaceship operator returns undef");
}
