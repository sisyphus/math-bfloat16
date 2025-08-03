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
       " This test script needs Math-MPFR-4.44 but we have only version $Math::MPFR::VERSION\n";
       is(1, 1);
       exit 0;
}

cmp_ok(Rmpfr_get_emin(), '!=', Math::Bfloat16::_XS_get_emin(), "perl and xs have different values for mpfr_get_emin()");
cmp_ok(Rmpfr_get_emax(), '!=', Math::Bfloat16::_XS_get_emax(), "perl and xs have different values for mpfr_get_emax()");

cmp_ok(Math::Bfloat16::_XS_get_emin(), '==', bf16_EMIN, "xs sets mpfr_get_emin() to expected value");
cmp_ok(Math::Bfloat16::_XS_get_emax(), '==', bf16_EMAX,"xs sets mpfr_get_emax() to expected value");
SET_EMIN_EMAX();
cmp_ok(Math::Bfloat16::_XS_get_emin(), '==', bf16_EMIN, "xs mpfr_get_emin() still set to expected value");
cmp_ok(Math::Bfloat16::_XS_get_emax(), '==', bf16_EMAX,"xs mpfr_get_emax() still set to expected value");
RESET_EMIN_EMAX();
cmp_ok(Math::Bfloat16::_XS_get_emin(), '==', bf16_EMIN, "xs mpfr_get_emin() still correct");
cmp_ok(Math::Bfloat16::_XS_get_emax(), '==', bf16_EMAX,"xs mpfr_get_emax() still correct");

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
