use strict;
use warnings;

use Math::Bfloat16 qw(:all);

use Test::More;

eval { require Math::Float32; };
if($@) {
  is(1, 1);
  warn "Skipping all tests - Math::Float32 did not load";
  exit(0);
}

my $bf16 = Math::Bfloat16->new(11);
my $f32  = Math::Float32 ->new(2.75);

## DIV ##
my $r1 = $bf16 / $f32;
cmp_ok(ref($r1), 'eq', 'Math::Bfloat16', "division returns Math::Bfloat16 object");
cmp_ok($r1, '==', 4,                     "division returns correct value");

my $r2 = $f32 / $bf16;
cmp_ok(ref($r2), 'eq', 'Math::Bfloat16', "inverted division returns Math::Bfloat16 object");
cmp_ok($r2, '==', 0.25,                  "inverted division returns correct value");

## SUB ##
$r1 = $bf16 - $f32;
cmp_ok(ref($r1), 'eq', 'Math::Bfloat16', "subtraction returns Math::Bfloat16 object");
cmp_ok($r1, '==', 8.25,                  "subtraction returns correct value");

$r2 = $f32 - $bf16;
cmp_ok(ref($r2), 'eq', 'Math::Bfloat16', "inverted subtraction returns Math::Bfloat16 object");
cmp_ok($r2, '==', -8.25,                 "inverted subtraction returns correct value");

## MUL ##
$r1 = $bf16 * $f32;
cmp_ok(ref($r1), 'eq', 'Math::Bfloat16', "multiplication returns Math::Bfloat16 object");
cmp_ok($r1, '==', 30.25,                 "multiplication returns correct value");

$r2 = $f32 * $bf16;
cmp_ok(ref($r2), 'eq', 'Math::Bfloat16', "inverted multiplication returns Math::Bfloat16 object");
cmp_ok($r2, '==', 30.25,                 "inverted multiplication returns correct value");

## ADD ##
$r1 = $bf16 + $f32;
cmp_ok(ref($r1), 'eq', 'Math::Bfloat16', "addition returns Math::Bfloat16 object");
cmp_ok($r1, '==', 13.75,                 "addition returns correct value");

$r2 = $f32 + $bf16;
cmp_ok(ref($r2), 'eq', 'Math::Bfloat16', "inverted addition returns Math::Bfloat16 object");
cmp_ok($r2, '==', 13.75,                 "inverted addition returns correct value");

## POW ##
$r1 = $bf16 ** Math::Float32->new(2);
cmp_ok(ref($r1), 'eq', 'Math::Bfloat16', "pow returns Math::Bfloat16 object");
cmp_ok($r1, '==', 121,                   "pow returns correct value");

$r2 = $f32 ** Math::Bfloat16->new(2);
cmp_ok(ref($r2), 'eq', 'Math::Bfloat16', "inverted pow returns Math::Bfloat16 object");
cmp_ok($r2, '==', 7.5625,                "inverted pow returns correct value");

## FMOD ##
$r1 = $bf16 % $f32;
cmp_ok(ref($r1), 'eq', 'Math::Bfloat16', "fmod returns Math::Bfloat16 object");
cmp_ok($r1, '==', 0,                     "fmod returns correct value");

$r2 = $f32 % $bf16;
cmp_ok(ref($r2), 'eq', 'Math::Bfloat16', "inverted fmod returns Math::Bfloat16 object");
cmp_ok($r2, '==', 2.75,                  "inverted fmod returns correct value");

$bf16 /= $f32;
cmp_ok(ref($bf16), 'eq', 'Math::Bfloat16', "/= returns Math::Bfloat16 object");
cmp_ok($bf16, '==', 4,                     "/= returns correct value");

$bf16 *= $f32;
cmp_ok(ref($bf16), 'eq', 'Math::Bfloat16', "*= returns Math::Bfloat16 object");
cmp_ok($bf16, '==', 11,                    "*/= returns correct value");

$bf16 -= $f32;
cmp_ok(ref($bf16), 'eq', 'Math::Bfloat16', "-= returns Math::Bfloat16 object");
cmp_ok($bf16, '==', 8.25,                  "-= returns correct value");

$bf16 += $f32;
cmp_ok(ref($bf16), 'eq', 'Math::Bfloat16', "+= returns Math::Bfloat16 object");
cmp_ok($bf16, '==', 11,                    "+= returns correct value");

$bf16 **= Math::Float32->new(2);
cmp_ok(ref($bf16), 'eq', 'Math::Bfloat16', "**= returns Math::Bfloat16 object");
cmp_ok($bf16, '==', 121,                   "**= returns correct value");

$bf16 %= $f32;
cmp_ok(ref($bf16), 'eq', 'Math::Bfloat16', "%= returns Math::Bfloat16 object");
cmp_ok($bf16, '==', 0,                     "%= returns correct value");

$bf16 += 11;
$f32 *= 12;

# $bf16 is 11
# $f32 is 33
cmp_ok($bf16, '==', 11, "Math::Bfloat object == 11");
cmp_ok($f32,  '==', 33, "Math::Float32 object == 33");

my $trans = Math::Float32->new($f32);
$trans /= $bf16;
cmp_ok(ref($trans), 'eq', 'Math::Bfloat16', "inverted /= returns a Math::Bfloat16 object");
cmp_ok($trans, '==', 3,                     "inverted /= returns correct value");

$trans = Math::Float32->new(2.75);
$trans *= $bf16;
cmp_ok(ref($trans), 'eq', 'Math::Bfloat16', "inverted *= returns a Math::Bfloat16 object");
cmp_ok($trans, '==', 30.25,                 "inverted *= returns correct value");

$trans = Math::Float32->new(2.75);
$trans -= $bf16;
cmp_ok(ref($trans), 'eq', 'Math::Bfloat16', "inverted -= returns a Math::Bfloat16 object");
cmp_ok($trans, '==', -8.25,                 "inverted -= returns correct value");

$trans = Math::Float32->new(2.75);
$trans += $bf16;
cmp_ok(ref($trans), 'eq', 'Math::Bfloat16', "inverted += returns a Math::Bfloat16 object");
cmp_ok($trans, '==', 13.75,                 "inverted += returns correct value");

$trans = Math::Float32->new(3);
$trans **= Math::Bfloat16->new(4);
cmp_ok(ref($trans), 'eq', 'Math::Bfloat16', "inverted **= returns a Math::Bfloat16 object");
cmp_ok($trans, '==', 81,                    "inverted **= returns correct value");

$trans = Math::Float32->new(2.75);
$trans %= $bf16;
cmp_ok(ref($trans), 'eq', 'Math::Bfloat16', "inverted %= returns a Math::Bfloat16 object");
cmp_ok($trans, '==', 2.75,                  "inverted %= returns correct value");

cmp_ok($bf16, '==', 11, "Math::Bfloat16 object == 11");
cmp_ok($f32,  '==', 33, "Math::Float32 object == 33");

cmp_ok($bf16, '==', Math::Float32->new(11),  "Bfloat16 == Float32(11)");
cmp_ok($f32,  '==', Math::Bfloat16->new(33), "Float32 == Bfloat16(33)");

cmp_ok($bf16, '!=', $f32, "Bfloat16 != Float32");
cmp_ok($f32, '!=', $bf16, "Float32 != Bfloat16");

cmp_ok($bf16, '<', $f32, "Bfloat16 < Float32");
cmp_ok($f32, '>', $bf16, "Float32 > Bfloat16");

cmp_ok($bf16, '<=', $f32, "Bfloat16 <= Float32");
cmp_ok($f32, '>=', $bf16, "Float32 >= Bfloat16");

cmp_ok($f32 <=> $bf16, '==',  1, "Float32 <=> Bfloat16 is 1");
cmp_ok($bf16 <=> $f32, '==', -1, "Bfloat16 <=> Float32 is -1");

cmp_ok(defined($f32 <=> Math::Bfloat16->new()), '==', 0, "Float32 <=> Bfloat16(nan) is undef");
cmp_ok(defined(Math::Bfloat16->new() <=> $f32), '==', 0, "Bfloat16(nan) <=> Float32 is undef");

cmp_ok(Math::Bfloat16->new() ** Math::Float32->new(0), '==', 1, "Bfloat16(nan) ** Float32(0) is 1");
cmp_ok(Math::Float32->new() ** Math::Bfloat16->new(0), '==', 1, "Float32(nan) ** Bfloat16(0) is 1");

done_testing();
