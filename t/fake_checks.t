use strict;
use warnings;

use Math::MPFR qw(:mpfr);
use Math::Bfloat16 qw(:all);

use Test::More;

eval { require Math::FakeBfloat16;};

if($@) {
  warn "Skipping all tests as Math::FakeBfloat16 failed to load";
  is(1, 1);
  done_testing();
  exit 0;
}

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

my @p = (  (2 ** (bf16_EMIN -1)),
           (2 ** bf16_EMIN) + (2 ** (bf16_EMIN + 2)),
           "$Math::Bfloat16::bf16_NORM_MIN",
           "$Math::Bfloat16::bf16_NORM_MAX",
           "$Math::Bfloat16::bf16_DENORM_MIN",
           "$Math::Bfloat16::bf16_DENORM_MAX",
            '2.2', '3.2', '5.2', '27.2',
        );

for my $v(@p) {
  my $bf16 = Math::Bfloat16->new($v);
  my $fake = Math::FakeBfloat16->new($v);
  cmp_ok("$bf16", 'eq', "$fake", "$v: real and fake match");

  my $sqrt_bf16 = sqrt($bf16);
  my $sqrt_fake = sqrt($fake);
  cmp_ok("$sqrt_bf16", 'eq', "$sqrt_fake", "sqrt $v: real and fake match");
}


for my $v1(@p) {
  my $flt_1 = Math::Bfloat16->new($v1);
  my $fake_1 = Math::FakeBfloat16->new($v1);
  for my $v2(@p) {
    my $flt_2 = Math::Bfloat16->new($v2);
    my $fake_2 = Math::FakeBfloat16->new($v2);

    my $fmod_flt_1 = $flt_1 % $flt_2;
    my $fmod_flt_2 = $flt_2 % $flt_1;

    my $fmod_fake_1 = $fake_1 % $fake_2;
    my $fmod_fake_2 = $fake_2 % $fake_1;

    cmp_ok("$fmod_flt_1", 'eq', "$fmod_fake_1", "$v1 % $v2: real and fake match");
    cmp_ok("$fmod_flt_2", 'eq', "$fmod_fake_2", "$v2 % $v1: real and fake match");



    my $pow_flt_1 = $flt_1 ** $flt_2;
    my $pow_flt_2 = $flt_2 ** $flt_1;

    my $pow_fake_1 = $fake_1 ** $fake_2;
    my $pow_fake_2 = $fake_2 ** $fake_1;

    cmp_ok("$pow_flt_1", 'eq', "$pow_fake_1", "$v1 ** $v2: real and fake match");
    cmp_ok("$pow_flt_2", 'eq', "$pow_fake_2", "$v2 ** $v1: real and fake match");


  }
}

my @powers = ('0.1', '0.2', '0.3', '0.4', '0.6', '0.7', '0.8', '0.9');

for my $p(@powers) {
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v) ** $p;
    my $bf16_2 = Math::Bfloat16->new($p) ** $v;
    my $fake_1 = Math::FakeBfloat16->new($v) ** $p;
    my $fake_2 = Math::FakeBfloat16->new($p) ** $v;
    cmp_ok("$bf16_1", 'eq', "$fake_1", "$p ** $v: real and fake match");
    cmp_ok("$bf16_2", 'eq', "$fake_2", "$p ** $v: real and fake match");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v) * $p;
    my $bf16_2 = Math::Bfloat16->new($p) * $v;
    my $fake_1 = Math::FakeBfloat16->new($v) * $p;
    my $fake_2 = Math::FakeBfloat16->new($p) * $v;
    cmp_ok("$bf16_1", 'eq', "$fake_1", "$p * $v: real and fake match");
    cmp_ok("$bf16_2", 'eq', "$fake_2", "$p * $v: real and fake match");
    cmp_ok($bf16_1, '==', $bf16_2, "* (real) : commutative law holds");
    cmp_ok($fake_1, '==', $fake_2, "* (fake) : commutative law holds");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v) / $p;
    my $bf16_2 = Math::Bfloat16->new($p) / $v;
    my $fake_1 = Math::FakeBfloat16->new($v) / $p;
    my $fake_2 = Math::FakeBfloat16->new($p) / $v;
    cmp_ok("$bf16_1", 'eq', "$fake_1", "$p / $v: real and fake match");
    cmp_ok("$bf16_2", 'eq', "$fake_2", "$p / $v: real and fake match");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v) + $p;
    my $bf16_2 = Math::Bfloat16->new($p) + $v;
    my $fake_1 = Math::FakeBfloat16->new($v) + $p;
    my $fake_2 = Math::FakeBfloat16->new($p) + $v;
    cmp_ok("$bf16_1", 'eq', "$fake_1", "$p + $v: real and fake match");
    cmp_ok("$bf16_2", 'eq', "$fake_2", "$p + $v: real and fake match");
    cmp_ok($bf16_1, '==', $bf16_2, "+ (real) : commutative law holds");
    cmp_ok($fake_1, '==', $fake_2, "+ (fake) : commutative law holds");
  }
}

for my $p(@powers) {
  for my $v(@p) {
    my $bf16_1 = Math::Bfloat16->new($v) - $p;
    my $bf16_2 = Math::Bfloat16->new($p) - $v;
    my $fake_1 = Math::FakeBfloat16->new($v) - $p;
    my $fake_2 = Math::FakeBfloat16->new($p) - $v;
    cmp_ok("$bf16_1", 'eq', "$fake_1", "$p - $v: real and fake match");
    cmp_ok("$bf16_2", 'eq', "$fake_2", "$p - $v: real and fake match");
    cmp_ok($bf16_1, '==', -$bf16_2, "* (real) : converse relationship holds");
    cmp_ok($fake_1, '==', -$fake_2, "* (fake) : converse relationship holds");
  }
}

# Test that Math::MPFR::subnormalize_generic
# fixes a known double-rounding anomaly.
my $s = '13.75e-41';
my $round = 0; # MPFR_RNDN
my $mpfr_anom1 = Math::MPFR::Rmpfr_init2(8);
Math::MPFR::Rmpfr_strtofr($mpfr_anom1, $s, 10, 0); # RNDN
my $anom1 = Math::FakeBfloat16->new($s);
cmp_ok(Math::FakeBfloat16::unpack_bf16_hex($anom1), 'eq', '0001', "direct assignment results in '0001'");
cmp_ok(Math::MPFR::unpack_bfloat16($mpfr_anom1, $round), 'eq', '0002', "indirect assignment results in '0002'");
cmp_ok($anom1, '!=', Math::FakeBfloat16->new($mpfr_anom1), "double-checked: values are different");
my $mpfr_anom2 = Math::MPFR::subnormalize_generic($s, -132, 128, 8);
cmp_ok(Math::MPFR::unpack_bfloat16($mpfr_anom2, $round), 'eq', '0001', "Math::MPFR::subnormalize_generic() ok");
cmp_ok($anom1, '==', Math::FakeBfloat16->new($mpfr_anom2), "double-checked: values are equivalent");

Rmpfr_set_default_prec($Math::MPFR::NV_properties{bits});

for my $man(1 ..15 ) {
  for my $exp(26 .. 41) {
    my $s = "${man}e-${exp}";
    my $bf16_1 = Math::Bfloat16->new($s);
    my $fake_1 = Math::FakeBfloat16->new($s);
    cmp_ok("$bf16_1", 'eq', "$fake_1", "$s: agreement between real and fake");
    my $nv = $s + 0;
    my $bf16_2 = Math::Bfloat16->new($nv);
    my $fake_2 = Math::FakeBfloat16->new($nv);
    cmp_ok("$bf16_2", 'eq', "$fake_2", "$nv: agreement between real and fake");
    cmp_ok($fake_1, '==', $fake_2, "$nv: both Math::FakeBfloat16 objects are equivalent");
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

for my $c(@corners) {
  my $bf16 = Math::Bfloat16->new($c);
  my $fake = Math::FakeBfloat16->new($c);
  cmp_ok("$bf16", 'eq', "$fake", "$c: fake & real agree");
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
  my $fake = Math::FakeBfloat16->new($s);
  cmp_ok("$bf16", 'eq', "$fake", "$s: fake & real agree");
}

@corners = ('0b0.01111111111111p+128', '-0b0.01111111111111p+128', 1.7012041427303509e38, -1.7012041427303509e38,
           Math::MPFR->new(1.7012041427303509e38), Math::MPFR->new(-1.7012041427303509e38));

if($have_gmpf) { push @corners, Math::GMPf->new(1.7012041427303509e38), Math::GMPf->new(-1.7012041427303509e38) }
if($have_gmpq) { push @corners, Math::GMPq->new(1.7012041427303509e38), Math::GMPq->new(-1.7012041427303509e38) }


for my $s (@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $fake = Math::FakeBfloat16->new($s);
  cmp_ok("$bf16", 'eq', "$fake", "$s: fake & real agree");
}

@corners = ('0b0.111111111p+128',  '-0b0.111111111p+128', 3.3961775292304601e38, -3.3961775292304601e38,
            Math::MPFR->new(3.3961775292304601e38), Math::MPFR->new(-3.3961775292304601e38));

if($have_gmpf) { push @corners, Math::GMPf->new(3.3961775292304601e38), Math::GMPf->new(-3.3961775292304601e38) }
if($have_gmpq) { push @corners, Math::GMPq->new(3.3961775292304601e38), Math::GMPq->new(-3.3961775292304601e38) }


for my $s (@corners) {
  my $bf16 = Math::Bfloat16->new($s);
  my $fake = Math::FakeBfloat16->new($s);
  cmp_ok("$bf16", 'eq', "$fake", "$s: fake & real agree");
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
  my $fake = Math::FakeBfloat16->new($s);
  cmp_ok("$bf16", 'eq', "$fake", "$s: fake & real agree");
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
  my $fake = Math::FakeBfloat16->new($s);
  cmp_ok("$bf16", 'eq', "$fake", "$s: fake & real agree");
}

for my $iv(1, -1, 1234567, -1234567, ~0, ~0 >> 1, -(~0 >> 1), ~0 >> 2, -(~0 >> 2)) {
  my $bf16 = Math::Bfloat16->new($iv);
  my $fake = Math::FakeBfloat16->new($iv);
  cmp_ok("$bf16", 'eq', "$fake", "IV $iv: fake & new agree");
}

done_testing();

__END__

