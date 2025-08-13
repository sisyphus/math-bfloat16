use strict;
use warnings;

use Math::MPFR qw(:mpfr);
use Math::Bfloat16 qw(:all);

use Test::More;

use constant EMIN_ORIG => Rmpfr_get_emin();
use constant EMAX_ORIG => Rmpfr_get_emax();
use constant EMIN_MOD  => bf16_EMIN;
use constant EMAX_MOD  => bf16_EMAX;

if($Math::MPFR::VERSION < 4.44) {
  warn "\n Aborting this test script:\n",
       " This test script needs Math-MPFR-4.44 but we have only version $Math::MPFR::VERSION\n",
       " If Math-MPFR-4.44 is not yet on CPAN, install the devel version from the github repo\n at https://github.com/sisyphus/math-mpfr\n";
       is(1, 1);
       done_testing();
       exit 0;
}

Rmpfr_set_default_prec(bf16_MANTBITS);

my $bf16_rop = Math::Bfloat16->new();
my $mpfr_rop = Math::MPFR->new();

my @p = (  (2 ** (bf16_EMIN -1)),
           (2 ** bf16_EMIN) + (2 ** (bf16_EMIN + 2)),
           "$Math::Bfloat16::bf16_NORM_MIN",
           "$Math::Bfloat16::bf16_NORM_MAX",
           "$Math::Bfloat16::bf16_DENORM_MIN",
           "$Math::Bfloat16::bf16_DENORM_MAX",
            '2.2', '3.2', '5.2', '27.2',
        );

for my $v(@p) {
  my $bf16_1 = Math::Bfloat16->new($v);
  Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
  SET_EMIN_EMAX();
  my $inex = Rmpfr_sqrt($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
  RESET_EMIN_EMAX();
  Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($bf16_rop, '==', sqrt($bf16_1), "sqrt($v): Math::MPFR & Math::Bfloat16 concur");
}

my $mpfr1 = Math::MPFR->new();
my $mpfr2 = Math::MPFR->new();
my $flt_rop = Math::Bfloat16->new();

for my $v1(@p) {
  my $flt_1 = Math::Bfloat16->new($v1);
  Math::MPFR::Rmpfr_set_BFLOAT16($mpfr1, $flt_1, 0);
  for my $v2(@p) {
    my $flt_2 = Math::Bfloat16->new($v2);
    Math::MPFR::Rmpfr_set_BFLOAT16($mpfr2, $flt_2, 0);
    SET_EMIN_EMAX();
    my $inex = Math::MPFR::Rmpfr_fmod($mpfr_rop, $mpfr1, $mpfr2, 0);
    Math::MPFR::Rmpfr_subnormalize($mpfr_rop, $inex, 0);
    RESET_EMIN_EMAX();
    Math::MPFR::Rmpfr_get_BFLOAT16($flt_rop, $mpfr_rop, 0);
    cmp_ok($flt_rop, '==', $flt_1 % $flt_2, "fmod($v1, $v2): Math::MPFR & Math::Bfloat16 concur");
  }
}

for my $v(@p) {
  my $bf16_1 = Math::Bfloat16->new($v);
  Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
  SET_EMIN_EMAX();
  my $inex = Rmpfr_sqr($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
  RESET_EMIN_EMAX();
  Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($bf16_rop, '==', $bf16_1 ** 2, "$v ** 2: Math::MPFR & Math::Bfloat16 concur");
}

for my $v(@p) {
  my $bf16_1 = Math::Bfloat16->new($v);
  Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
  SET_EMIN_EMAX();
  my $inex = Rmpfr_log($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
  RESET_EMIN_EMAX();
  Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($bf16_rop, '==', log($bf16_1), "log($v): Math::MPFR & Math::Bfloat16 concur");
}

for my $v(@p) {
  my $bf16_1 = Math::Bfloat16->new($v);
  Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
  SET_EMIN_EMAX();
  my $inex = Rmpfr_exp($mpfr_rop, $mpfr_rop, MPFR_RNDN);
  Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
  RESET_EMIN_EMAX();
  Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
  cmp_ok($bf16_rop, '==', exp($bf16_1), "exp($v): Math::MPFR & Math::Bfloat16 concur");
}

my @powers = ('0.1', '0.2', '0.3', '0.4', '0.6', '0.7', '0.8', '0.9');

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v);
    Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_pow($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($bf16_rop, '==', $bf16_1 ** "$pow", "$v ** '$pow': Math::MPFR & Math::Bfloat16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v);
    Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_mul($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($bf16_rop, '==', $bf16_1 * "$pow", "'$v * $pow': Math::MPFR & Math::Bfloat16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v);
    Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_div($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($bf16_rop, '==', $bf16_1 / "$pow", "$v / '$pow': Math::MPFR & Math::Bfloat16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v);
    Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_add($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($bf16_rop, '==', $bf16_1 + "$pow", "$v + '$pow': Math::MPFR & Math::Bfloat16 concur");
  }
}

for my $p(@powers) {
  my $pow = Math::MPFR->new($p);
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v);
    Rmpfr_set_BFLOAT16($mpfr_rop, $bf16_1, MPFR_RNDN);
    SET_EMIN_EMAX();
    my $inex = Rmpfr_sub($mpfr_rop, $mpfr_rop, $pow, MPFR_RNDN);
    Rmpfr_subnormalize($mpfr_rop, $inex, MPFR_RNDN);
    RESET_EMIN_EMAX();
    Rmpfr_get_BFLOAT16($bf16_rop, $mpfr_rop, MPFR_RNDN);
    cmp_ok($bf16_rop, '==', $bf16_1 - "$pow", "$v - '$pow': Math::MPFR & Math::Bfloat16 concur");
  }
}

# Test that Math::MPFR::subnormalize_bfloat16
# fixes a known double-rounding anomaly.
my $s = '13.75e-41';
my $round = 0; # MPFR_RNDN
my $mpfr_anom1 = Math::MPFR::Rmpfr_init2(8);
Math::MPFR::Rmpfr_strtofr($mpfr_anom1, $s, 10, 0); # RNDN
my $anom1 = Math::Bfloat16->new($s);
cmp_ok(unpack_bf16_hex($anom1), 'eq', '0001', "direct assignment results in '0001'");
cmp_ok(Math::MPFR::unpack_bfloat16($mpfr_anom1, $round), 'eq', '0002', "indirect assignment results in '0002'");
cmp_ok($anom1, '!=', Math::Bfloat16->new($mpfr_anom1), "double-checked: values are different");
my $mpfr_anom2 = Math::MPFR::subnormalize_bfloat16($s);
cmp_ok(Math::MPFR::unpack_bfloat16($mpfr_anom2, $round), 'eq', '0001', "Math::MPFR::subnormalize_bfloat16() ok");
cmp_ok($anom1, '==', Math::Bfloat16->new($mpfr_anom2), "double-checked: values are equivalent");

done_testing();

sub SET_EMIN_EMAX {
  Rmpfr_set_emin(EMIN_MOD);
  Rmpfr_set_emax(EMAX_MOD);
}

sub RESET_EMIN_EMAX {
  Rmpfr_set_emin(EMIN_ORIG);
  Rmpfr_set_emax(EMAX_ORIG);
}
__END__
