use strict;
use warnings;
use Math::Bfloat16 qw(:all);

use Test::More;

my($have_gmpf, $have_gmpq, $have_mpfr) = (0, 0, 0);

eval { require Math::GMPf;};
$have_gmpf = 1 unless $@;

eval { require Math::GMPq;};
$have_gmpq = 1 unless $@;

eval { require Math::MPFR;};
$have_mpfr = 1 unless $@;

my @inputs = ('1.5', '-1.75', 2.625, 42);

push(@inputs, Math::Bfloat16->new(Math::MPFR->new(3.875))) if $have_mpfr;

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
  cmp_ok($nan, '!=', $v, "NaN != $v");
  cmp_ok(defined($nan <=> $v), '==', 0, "$v: spaceship operator returns undef");
  cmp_ok(defined($v <=> $nan), '==', 0, "$v (reversed): spaceship operator returns undef");
}



for my $p(@inputs) {
  for my $q(@inputs) {
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

my $bf = Math::Bfloat16->new(42.5);

cmp_ok($bf, '==', 42.5, "== NV");
cmp_ok($bf, '==', '42.5', "== PV");
cmp_ok($bf, '==', Math::Bfloat16->new(Math::MPFR->new(42.5)), "== from MPFR");

cmp_ok($bf, '<', 44.5, "< NV");
cmp_ok($bf, '<', '44.5', "< PV");
cmp_ok($bf, '<', Math::Bfloat16->new(Math::MPFR->new(44.5)), "< from MPFR");

cmp_ok($bf, '<=', 44.5, "<= NV");
cmp_ok($bf, '<=', '44.5', "<= PV");
cmp_ok($bf, '<=', Math::Bfloat16->new(Math::MPFR->new(44.5)), "<= from MPFR");

cmp_ok($bf, '<=', 42.5, "<= equiv NV");
cmp_ok($bf, '<=', '42.5', "<= equiv PV");
cmp_ok($bf, '<=', Math::Bfloat16->new(Math::MPFR->new(42.5)), "<= from equiv MPFR");

cmp_ok($bf, '>=', 42.5, ">= equiv NV");
cmp_ok($bf, '>=', '42.5', ">= equiv PV");
cmp_ok($bf, '>=', Math::Bfloat16->new(Math::MPFR->new(42.5)), ">= from equiv MPFR");

cmp_ok($bf, '>=', 40.5, ">= NV");
cmp_ok($bf, '>=', '40.5', ">= PV");
cmp_ok($bf, '>=', Math::Bfloat16->new(Math::MPFR->new(40.5)), ">= from MPFR");

cmp_ok($bf, '>', 40.5, "> NV");
cmp_ok($bf, '>', '40.5', "> PV");
cmp_ok($bf, '>', Math::Bfloat16->new(Math::MPFR->new(40.5)), "> from MPFR");

cmp_ok(($bf <=> 42.5), '==', 0, "<=> equiv NV");
cmp_ok(($bf <=> '42.5'), '==', 0, "<=> equiv PV");
cmp_ok(($bf <=> Math::Bfloat16->new(Math::MPFR->new(42.5))), '==', 0, "<=> from equiv MPFR");

cmp_ok(($bf <=> 40.5), '==', 1, "<=> smaller NV");
cmp_ok(($bf <=> '40.5'), '==', 1, "<=> smaller PV");
cmp_ok(($bf <=> Math::Bfloat16->new(Math::MPFR->new(40.5))), '==', 1, "<=> from smaller MPFR");

cmp_ok(($bf <=> 44.5), '==', -1, "<=> bigger NV");
cmp_ok(($bf <=> '44.5'), '==', -1, "<=> bigger PV");
cmp_ok(($bf <=> Math::Bfloat16->new(Math::MPFR->new(44.5))), '==', -1, "<=> from bigger MPFR");

my $uv = ~0;
cmp_ok(Math::Bfloat16->new($uv), '==', Math::Bfloat16->new("$uv"), 'IV assignment == PV assignment');

done_testing();
