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

Rmpfr_set_default_prec($Math::MPFR::NV_properties{bits});

for my $man(1 ..15 ) {
  for my $exp(26 .. 41) {
    my $s = "${man}e-${exp}";
    my $bf16_1 = Math::Bfloat16->new($s);
    my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($s), MPFR_RNDN));
    $get =~ s/\+//g;
    cmp_ok(lc("$bf16_1"), 'eq', lc($get), "$s: agreement with Rmpfr_get_bfloat16");
    my $mpfr_1 = Math::MPFR::subnormalize_bfloat16($s);
    my $mpfr_2 = Math::MPFR::subnormalize_bfloat16(Math::MPFR->new($s));
    cmp_ok($bf16_1, '==', "$mpfr_1", "$s (strings) agreement");
    cmp_ok($bf16_1, '==', "$mpfr_2", "$s (strings & mpfr) agreement");
    my $nv = $s + 0;
    my $bf16_2 = Math::Bfloat16->new($nv);
    cmp_ok($bf16_1, '==', $bf16_2, "$nv: both Math::Bfloat16 objects are equivalent");
    $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($nv), MPFR_RNDN));
    $get =~ s/\+//g;
    cmp_ok(lc("$bf16_1"), 'eq', lc($get), "$s: agreement with Rmpfr_get_bfloat16");
    my $mpfr_3 = Math::MPFR::subnormalize_bfloat16($nv);
    my $mpfr_4 = Math::MPFR::subnormalize_bfloat16(Math::MPFR->new($nv));
    cmp_ok($bf16_2, '==', "$mpfr_3", "$s (NVs) agreement");
    cmp_ok($bf16_2, '==', "$mpfr_4", "$s (NVs & mpfr) agreement");
  }
}

my($have_gmpf, $have_gmpq) = (0, 0);

eval { require Math::GMPf;};
if($@) { warn "skipping Math::GMPf tests\n" }
else { $have_gmpf = 1 }

eval { require Math::GMPq;};
if($@) { warn "skipping Math::GMPq tests\n" }
else { $have_gmpq = 1 }

my @corners = ('0b0.1000000000000001p-133', '-0b0.1000000000000001p-133', '0b0.1p-133', '-0b0.1p-133',
              '4.5919149377459931e-41', '-4.5919149377459931e-41', 4.5919149377459931e-41, -4.5919149377459931e-41,
               Math::MPFR->new('0b0.1000000000000001p-133'), Math::MPFR->new('-0b0.1000000000000001p-133'),
               Math::MPFR->new('0b0.1p-133'), Math::MPFR->new('-0b0.1p-133'),
               Math::MPFR->new(4.5919149377459931e-41), Math::MPFR->new(-4.5919149377459931e-41)
              );

if($have_gmpf) { push @corners, Math::GMPf->new(4.5919149377459931e-41), Math::GMPf->new(-4.5919149377459931e-41),
                                Math::GMPf->new(4.5e-41), Math::GMPf->new(-4.5e-41) }
if($have_gmpq) { push @corners, Math::GMPq->new(4.5919149377459931e-41), Math::GMPq->new(-4.5919149377459931e-41),
                                Math::GMPq->new(4.5e-41), Math::GMPq->new(-4.5e-41) }
# 4.5917748078995606e-41
for my $c(@corners) {
  my $bf16 = Math::Bfloat16->new($c);
  my $mpfr = Math::MPFR::subnormalize_bfloat16($c);
  my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($c), MPFR_RNDN));
  $get =~ s/\+//g;
  cmp_ok(lc("$bf16"), 'eq', lc($get), "$c: agreement with Rmpfr_get_bfloat16");
  unless(is_bf16_zero($bf16)) {
    if($bf16 > 0) {
      cmp_ok($bf16, '==', $Math::Bfloat16::bf16_DENORM_MIN, "Value is +DENORM_MIN");
    }
    else {
      cmp_ok($bf16, '==', -$Math::Bfloat16::bf16_DENORM_MIN, "Value is -DENORM_MIN");
    }
  }
  cmp_ok("$bf16", 'eq', "$mpfr", "$c: new & subnormalize_bfloat16 agree");
}

@corners = ('0b0.11111111p+128',       '-0b0.11111111p+128', 3.3895313892515355e38, -3.3895313892515355e38,
           '0b0.11111111011111p+128', '-0b0.11111111011111p+128', 3.3959698373561187e38, -3.3959698373561187e38,
           Math::MPFR->new(3.3895313892515355e38), Math::MPFR->new(-3.3895313892515355e38),
           Math::MPFR->new(3.3959698373561187e38), Math::MPFR->new(-3.3959698373561187e38), );

if($have_gmpf) { push @corners, Math::GMPf->new(3.3895313892515355e38), Math::GMPf->new(-3.3895313892515355e38),
                Math::GMPf->new(3.3959698373561187e38), Math::GMPf->new(-3.3959698373561187e38) }

if($have_gmpq) { push @corners, Math::GMPq->new(3.3895313892515355e38), Math::GMPq->new(-3.3895313892515355e38),
                Math::GMPq->new(3.3959698373561187e38), Math::GMPq->new(-3.3959698373561187e38) }

for my $s(@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $mpfr = subnormalize_bfloat16($s);
  my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($s), MPFR_RNDN));
  $get =~ s/\+//g;
  cmp_ok(lc("$bf16"), 'eq', lc($get), "$s: agreement with Rmpfr_get_bfloat16");
  cmp_ok("$bf16", 'eq', "$mpfr", "$s: subnormalize & new agree");
  if($bf16 > 0) {
    cmp_ok($bf16, '==', $Math::Bfloat16::bf16_NORM_MAX, "$s is +NORM_MAX");
  }
  else {
    cmp_ok($bf16, '==', -$Math::Bfloat16::bf16_NORM_MAX, "$s is -NORM_MAX");
  }
}

@corners = ('0b0.01111111111111p+128', '-0b0.01111111111111p+128', 1.7012041427303509e38, -1.7012041427303509e38,
           Math::MPFR->new(1.7012041427303509e38), Math::MPFR->new(-1.7012041427303509e38));

if($have_gmpf) { push @corners, Math::GMPf->new(1.7012041427303509e38), Math::GMPf->new(-1.7012041427303509e38) }
if($have_gmpq) { push @corners, Math::GMPq->new(1.7012041427303509e38), Math::GMPq->new(-1.7012041427303509e38) }


for my $s (@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $mpfr = subnormalize_bfloat16($s);
  my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($s), MPFR_RNDN));
  $get =~ s/\+//g;
  cmp_ok("$bf16", 'eq', $get, "$s: agreement with Rmpfr_get_bfloat16");
  cmp_ok("$bf16", 'eq', "$mpfr", "$s: subnormalize & new agree");
  if($bf16 > 0) {
    cmp_ok("$bf16", 'eq', '1.701e38', "$s is 1.701e38");
  }
  else {
    cmp_ok("$bf16", 'eq', '-1.701e38', "$s is -1.701e38");
  }
}

@corners = ('0b0.111111111p+128',  '-0b0.111111111p+128', 3.3961775292304601e38, -3.3961775292304601e38,
            Math::MPFR->new(3.3961775292304601e38), Math::MPFR->new(-3.3961775292304601e38));

if($have_gmpf) { push @corners, Math::GMPf->new(3.3961775292304601e38), Math::GMPf->new(-3.3961775292304601e38) }
if($have_gmpq) { push @corners, Math::GMPq->new(3.3961775292304601e38), Math::GMPq->new(-3.3961775292304601e38) }


for my $s (@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $mpfr = subnormalize_bfloat16($s);
  my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($s), MPFR_RNDN));
  $get =~ s/\+//g;
  cmp_ok(lc("$bf16"), 'eq', lc($get), "$s: agreement with Rmpfr_get_bfloat16");
  cmp_ok("$bf16", 'eq', "$mpfr", "$s: subnormalize & new agree");
  if($bf16 > 0) {
    cmp_ok(is_bf16_inf($bf16), '==', 1, "$s is +Inf");
  }
  else {
    cmp_ok(is_bf16_inf($bf16), '==', -1, "$s is -INF");
  }
}

@corners = ('0b0.1p+129', '0b0.1111111111111111p+129', '0b0.1p+130', '0b0.1111111111111111p+130',
            '0b0.1p+250', '0b0.1111111111111111p+250',
            3.4028236692093846e38, 6.8055434924815986e38, 6.8056473384187693e38, 1.3611086984963197e39,
            9.0462569716653278e74, 1.8092237873476784e75,
            Math::MPFR->new(3.4028236692093846e38), Math::MPFR->new(6.8055434924815986e38),
            Math::MPFR->new(6.8056473384187693e38), Math::MPFR->new(1.3611086984963197e39),
            Math::MPFR->new(9.0462569716653278e74), Math::MPFR->new(1.8092237873476784e75)
           );

if($have_gmpf) { push @corners, Math::GMPf->new(3.4028236692093846e38), Math::GMPf->new(6.8055434924815986e38),
                                Math::GMPf->new(6.8056473384187693e38), Math::GMPf->new(1.3611086984963197e39),
                                Math::GMPf->new(9.0462569716653278e74), Math::GMPf->new(1.8092237873476784e75) }

if($have_gmpq) { push @corners, Math::GMPq->new(3.4028236692093846e38), Math::GMPq->new(6.8055434924815986e38),
                                Math::GMPq->new(6.8056473384187693e38), Math::GMPq->new(1.3611086984963197e39),
                                Math::GMPq->new(9.0462569716653278e74), Math::GMPq->new(1.8092237873476784e75) }

for my $s (@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $mpfr = subnormalize_bfloat16($s);
  my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($s), MPFR_RNDN));
  $get =~ s/\+//g;
  cmp_ok(lc("$bf16"), 'eq', lc($get), "$s: agreement with Rmpfr_get_bfloat16");
  cmp_ok(is_bf16_inf($bf16), '==', 1, "$s assigns to Math::Bfloat16 as +Inf");
  cmp_ok(Rmpfr_inf_p($mpfr), '==', 1, "subnormalize_bfloat16 returns $s as Inf");
  cmp_ok(Rmpfr_signbit($mpfr), '==', 0, "$s is +Inf");
}

#################################################
#################################################

@corners = ('-0b0.1p+129', '-0b0.1111111111111111p+129', '-0b0.1p+130', '-0b0.1111111111111111p+130',
            '-0b0.1p+250', '-0b0.1111111111111111p+250',
            -3.4028236692093846e38, -6.8055434924815986e38, -6.8056473384187693e38, -1.3611086984963197e39,
            -9.0462569716653278e74, -1.8092237873476784e75,
            Math::MPFR->new(-3.4028236692093846e38), Math::MPFR->new(-6.8055434924815986e38),
            Math::MPFR->new(-6.8056473384187693e38), Math::MPFR->new(-1.3611086984963197e39),
            Math::MPFR->new(-9.0462569716653278e74), Math::MPFR->new(-1.8092237873476784e75)
           );

if($have_gmpf) { push @corners, Math::GMPf->new(-3.4028236692093846e38), Math::GMPf->new(-6.8055434924815986e38),
                                Math::GMPf->new(-6.8056473384187693e38), Math::GMPf->new(-1.3611086984963197e39),
                                Math::GMPf->new(-9.0462569716653278e74), Math::GMPf->new(-1.8092237873476784e75) }

if($have_gmpq) { push @corners, Math::GMPq->new(-3.4028236692093846e38), Math::GMPq->new(-6.8055434924815986e38),
                                Math::GMPq->new(-6.8056473384187693e38), Math::GMPq->new(-1.3611086984963197e39),
                                Math::GMPq->new(-9.0462569716653278e74), Math::GMPq->new(-1.8092237873476784e75) }

for my $s (@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $get = sprintf("%.4g", Rmpfr_get_bfloat16(Math::MPFR->new($s), MPFR_RNDN));
  $get =~ s/\+//g;
  cmp_ok(lc("$bf16"), 'eq', lc($get), "$s: agreement with Rmpfr_get_bfloat16");
  my $mpfr = subnormalize_bfloat16($s);
  cmp_ok(is_bf16_inf($bf16), '==', -1, "$s assigns to Math::Bfloat16 as -Inf");
  cmp_ok(Rmpfr_inf_p($mpfr), '==', 1, "subnormalize_bfloat16 returns $s as Inf");
  cmp_ok(Rmpfr_signbit($mpfr), '==', 1, "$s is -Inf");
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
