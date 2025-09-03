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

push (@inputs, Math::MPFR->new(3.875)) if $have_mpfr;

#push(@inputs, Math::GMPf->new(5.25)) if $have_gmpf;
push(@inputs, Math::GMPq->new('3/4')) if $have_gmpq;

for my $in(@inputs) {
  cmp_ok(bf16_to_NV(Math::Bfloat16->new($in)), '==', $in, "bf16_to_NV: $in ok");
  cmp_ok(bf16_to_MPFR(Math::Bfloat16->new($in)), '==', $in, "bf16_to_MPFR: $in ok");

  cmp_ok(bf16_to_NV(Math::Bfloat16->new(-$in)), '==', -$in, "bf16_to_NV: -$in ok");
  cmp_ok(bf16_to_MPFR(Math::Bfloat16->new(-$in)), '==', -$in, "bf16_to_MPFR: -$in ok");
}

if($have_gmpf) {
  # There's no overloading of '==' between Math::MPFR and Math::GMPf
  my $in = Math::GMPf->new(5.25);
  cmp_ok(bf16_to_MPFR(Math::Bfloat16->new($in)),  '==', Math::MPFR->new($in),  "bf16_to_MPFR from GMPf: $in ok");
  cmp_ok(bf16_to_MPFR(Math::Bfloat16->new(-$in)), '==', Math::MPFR->new(-$in), "bf16_to_MPFR from GMPf: -$in ok");
}

cmp_ok(ref(Math::Bfloat16->new()), 'eq', 'Math::Bfloat16', "Math::Bfloat16->new() returns a Math::Bfloat16 object");
cmp_ok(ref(Math::Bfloat16::new()), 'eq', 'Math::Bfloat16', "Math::Bfloat16::new() returns a Math::Bfloat16 object");


cmp_ok(is_bf16_nan(Math::Bfloat16->new()), '==', 1, "Math::Bfloat16->new() returns NaN");
cmp_ok(is_bf16_nan(Math::Bfloat16::new()), '==', 1, "Math::Bfloat16::new() returns NaN");

my $obj = Math::Bfloat16->new('1.414');
cmp_ok(Math::Bfloat16->new($obj), '==', $obj, "new(obj) == obj");
cmp_ok(Math::Bfloat16->new($obj), '==', '1.414', "new(obj) == value of obj");

my $mpfr_obj = Math::MPFR->new();
Math::MPFR::Rmpfr_set_inf($mpfr_obj, 1);
#print "$mpfr_obj\n";
my $pinf = Math::Bfloat16->new($mpfr_obj);
cmp_ok(is_bf16_inf($pinf), '==', 1, "+Inf, as expected");

Math::MPFR::Rmpfr_set_inf($mpfr_obj, -1);
my $ninf = Math::Bfloat16->new($mpfr_obj);
cmp_ok(is_bf16_inf($ninf), '==', -1, "-Inf, as expected");

Math::MPFR::Rmpfr_set_si($mpfr_obj, -1, 0);
my $not_inf = Math::Bfloat16->new($mpfr_obj);
cmp_ok(is_bf16_inf($not_inf), '==', 0, "Not an infinity");
cmp_ok(is_bf16_zero($not_inf), '==', 0, "Not a zero");

Math::MPFR::Rmpfr_set_zero($mpfr_obj, 1);
my $pzero = Math::Bfloat16->new($mpfr_obj);
cmp_ok(is_bf16_zero($pzero), '==', 1, "+0, as expected");

Math::MPFR::Rmpfr_set_zero($mpfr_obj, -1);
my $nzero = Math::Bfloat16->new($mpfr_obj);
cmp_ok(is_bf16_zero($nzero), '==', -1, "-0, as expected");

done_testing();
