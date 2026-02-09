# Test set/get Bfloat16 to/from Float32 (single precision float).

use strict;
use warnings;

use Math::Bfloat16 qw(:all);
use Test::More;

my $have_math_float32 = 0;
eval { require Math::Float32;};
$have_math_float32 = 1 unless $@;

unless($have_math_float32) {
  is(1,1);
  warn "Skipping all tests: Math::Float32 was not loaded";
  done_testing();
  exit 0;
}

#my $have_math_mpfr = 0;
#eval { require Math::MPFR;};
#unless($@) {
#  if($Math::MPFR::VERSION >= 4.43) {
#    $have_math_mpfr = 1;
#  }
# else {
#    warn "\n Skipping some tests because Math::MPFR version is too old.\n",
#         " Math-MPFR-4.43 is required, but you have only version $Math::MPFR::VERSION.\n";
#  }
#}
#else {
#  warn "\n Skipping some tests because Math::MPFR could not be loaded\n";
#}

my $f32_nan = Math::Float32->new();
my $new0 = Math::Bfloat16->new($f32_nan);
cmp_ok(is_bf16_nan($new0), '==', 1, "Float32 NaN assigns as Bfloat16 NaN");

cmp_ok(Math::Float32::is_flt_nan(bf16_to_Float32($new0)), '==', 1, "NaN passes round trip");

my $f32_pinf = Math::Float32->new();
Math::Float32::flt_set_inf($f32_pinf, 1);
my $new1 = Math::Bfloat16->new($f32_pinf);
cmp_ok(is_bf16_inf($new1), '==', 1, "Float32 +Inf assigns as Bfloat16 +Inf");

cmp_ok(Math::Float32::is_flt_inf(bf16_to_Float32($new1)), '==', 1, "+Inf passes round trip");


my $f32_ninf = Math::Float32->new();
Math::Float32::flt_set_inf($f32_ninf, -1);
my $new2 = Math::Bfloat16->new($f32_ninf);
cmp_ok(is_bf16_inf($new2), '==', -1, "Float32 -Inf assigns as Bfloat16 -Inf");

cmp_ok(Math::Float32::is_flt_inf(bf16_to_Float32($new2)), '==', -1, "-Inf passes round trip");

my $f32_pzero = Math::Float32->new();
Math::Float32::flt_set_zero($f32_pzero, 1);
my $new3 = Math::Bfloat16->new($f32_pzero);
cmp_ok(is_bf16_zero($new3), '==', 1, "Float32 +0 assigns as Bfloat16 +0");

cmp_ok(Math::Float32::is_flt_zero(bf16_to_Float32($new3)), '==', 1, "+0 passes round trip");

my $f32_nzero = Math::Float32->new();
Math::Float32::flt_set_zero($f32_nzero, -1);
my $new4 = Math::Bfloat16->new($f32_nzero);
cmp_ok(is_bf16_zero($new4), '==', -1, "Float32 -0 assigns as Bfloat16 -0");

cmp_ok(Math::Float32::is_flt_zero(bf16_to_Float32($new4)), '==', -1, "-0 passes round trip");


my @first = (sqrt(Math::Float32->new(2)), Math::Float32->new(22) / 7, Math::Float32->new(2.5) ** -20);
my @second = ($f32_nan, $f32_pinf, $f32_ninf, $f32_pzero, $f32_nzero);
my @third = ( Math::Float32->new(int(rand(10)) . int(rand(100000)) . 'e'  . int(rand(40))),
              Math::Float32->new(int(rand(10)) . int(rand(100000)) . 'e-' . int(rand(40))),
              Math::Float32->new('-' . int(rand(10)) . int(rand(100000)) . 'e'  . int(rand(40))),
              Math::Float32->new('-' . int(rand(10)) . int(rand(100000)) . 'e-' . int(rand(40))), );

my @fourth;
{ no warnings 'once';
  @fourth = ( Math::Float32->new($Math::Float32::flt_DENORM_MIN),
              Math::Float32->new($Math::Float32::flt_DENORM_MAX),
              Math::Float32->new($Math::Float32::flt_NORM_MIN),
              Math::Float32->new($Math::Float32::flt_NORM_MAX), );
}

push @second, @third, @fourth;

for my $f32 (@first) {
  my $new = Math::Bfloat16->new($f32);
  my $expected = substr(Math::Float32::unpack_flt_hex($f32), 0, 4) ;
  my $got = unpack_bf16_hex($new);

  cmp_ok($got, 'eq', $expected, "$f32 correctly truncated to a __bf16 value");

  cmp_ok($got . '0000', 'eq', Math::Float32::unpack_flt_hex( bf16_to_Float32($new) ), "$f32 resurrected ok");
}

for my $f32 (@second) {
  my $new = Math::Bfloat16->new($f32);
  my $expected = substr(Math::Float32::unpack_flt_hex($f32), 0, 4) ;
  my $got = unpack_bf16_hex($new);

  cmp_ok($got, 'eq', $expected, "$f32 correctly set by new() to the comparable __bf16 value");

  cmp_ok($got . '0000', 'eq', Math::Float32::unpack_flt_hex( bf16_to_Float32($new) ), "$f32 resurrected ok");

}

my $bf16_reusable = Math::Bfloat16->new(10);

for my $f32 (@first, @second) {
  bf16_set($bf16_reusable, $f32);
  my $expected = substr(Math::Float32::unpack_flt_hex($f32), 0, 4) ;
  my $got = unpack_bf16_hex($bf16_reusable);

  cmp_ok($got, 'eq', $expected, "$f32 correctly assigned to the Math::Bfloat16 object");

  cmp_ok($got . '0000', 'eq', Math::Float32::unpack_flt_hex( bf16_to_Float32($bf16_reusable) ), "$f32 resurrected ok");
}

done_testing();
