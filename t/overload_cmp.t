# No bi-directional cross-class overloading yet. (TODO)
# Bi-directional overloading can currently only be done between Math::Bfloat16
# objects, IVs, PVs, and NVs. Math::MPFR, Math::GMPf and Math::GMPq objects need
# to be converted to a Math::Bfloat16 object before being given to an overloaded
# operation if they are the first argument. If $mb is a Math::Bfloat16 object
# and $mpfr is a Math::MPFR object, it's ok to do '$mb + $mpfr' but '$mpfr + $mb'
# will presently croak with "Invalid argument supplied to Math::MPFR::overload_add ".
# OTOH, 'Math::Bfloat16->new($mpfr) + $mb' will, of course, work fine.

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
  cmp_ok($nan, '!=', $v, "NaN != $v");
  cmp_ok(defined($nan <=> $v), '==', 0, "$v: spaceship operator returns undef");
}

for my $v (@inputs_alt) {
  cmp_ok($v, '!=', $nan, "$v != NaN");
  cmp_ok(defined($v <=> $nan), '==', 0, "$v (reversed): spaceship operator returns undef");
}

for my $p(@inputs) {
  for my $q(@inputs_alt) {
    cmp_ok(Math::Bfloat16->new($q), '==', $p, "$q == $p") if Math::Bfloat16->new($p) == $q;
    cmp_ok(Math::Bfloat16->new($q), '>', $p, "$q > $p") if Math::Bfloat16->new($p) < $q;
    cmp_ok(Math::Bfloat16->new($q), '<', $p, "$q < $p") if Math::Bfloat16->new($p) > $q;
    cmp_ok(Math::Bfloat16->new($q), '>=', $p, "$q >= $p") if Math::Bfloat16->new($p) <= $q;
    cmp_ok(Math::Bfloat16->new($q), '<=', $p, "$q <= $p") if Math::Bfloat16->new($p) >= $q;
    my $x = (Math::Bfloat16->new($q) <=> $p);
    my $y = (Math::Bfloat16->new($p) <=> $q);
    cmp_ok($x, '==', -$y, "$q <=> $p");
  }
}

done_testing();
