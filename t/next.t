use strict;
use warnings;
use Math::Bfloat16 qw(:all);

use Test::More;

cmp_ok(Math::Bfloat16::_XS_get_emin(), '==', Math::Bfloat16::bf16_EMIN, "emin set correctly");
cmp_ok(Math::Bfloat16::_XS_get_emax(), '==', Math::Bfloat16::bf16_EMAX, "emin set correctly");

my $nan = Math::Bfloat16->new();
cmp_ok( (is_bf16_nan($nan)), '==', 1, "new obj is NaN");

bf16_nextabove($nan);
cmp_ok( (is_bf16_nan($nan)), '==', 1, "next above NaN is NaN");

bf16_nextbelow($nan);
cmp_ok( (is_bf16_nan($nan)), '==', 1, "next below NaN is NaN");

my $pinf = Math::Bfloat16->new();

bf16_set_inf($pinf, 1);
cmp_ok( (is_bf16_inf($pinf)), '==', 1, "+inf is inf");

bf16_nextbelow($pinf);
cmp_ok( (is_bf16_inf($pinf)), '==', 0, "next below +inf is not inf");
cmp_ok( $pinf, '==', '3.39e38' , "next below +inf is 3.39e38");

bf16_nextabove($pinf);
cmp_ok( (is_bf16_inf($pinf)), '==', 1, "next above 3.39e38 is inf");

my $pmin = Math::Bfloat16->new(2) ** -133;
cmp_ok($pmin, '==', '9.184e-41', "+min is 9.184e-41");

bf16_nextbelow($pmin);
cmp_ok($pmin, '==', 0, "next below +min is zero");
cmp_ok( (is_bf16_zero($pmin)), '==', 1, "next below +min is unsigned zero");

bf16_nextabove($pmin);
cmp_ok($pmin, '==', '9.184e-41', "next above zero is 9.184e-41");

my $ninf = -$pinf;
cmp_ok( (is_bf16_inf($ninf)), '==', -1, "inf is -inf");

bf16_nextabove($ninf);
cmp_ok( (is_bf16_inf($ninf)), '==', 0, "next above -inf is not inf");
cmp_ok( $ninf, '==', '-3.39e38' , "next above inf is -3.39e38");

bf16_nextbelow($ninf);
cmp_ok( (is_bf16_inf($ninf)), '==', -1, "next below -3.39e38 is -inf");

my $nmin = -$pmin;

bf16_nextabove($nmin);
cmp_ok($nmin, '==', 0, "next above -min is zero");
cmp_ok( (is_bf16_zero($nmin)), '==', -1, "next above -min is -0");

bf16_nextbelow($nmin);
cmp_ok($nmin, '==', '-9.184e-41', "next below zero is -9.184e-41");

my $zero =Math::Bfloat16->new(0);
my $max_subnormal = Math::Bfloat16->new(0);

for(127 .. 133) { $max_subnormal += 2 ** -$_ }
cmp_ok($max_subnormal, '==', '1.166e-38', "DENORM_MAX is 1.166e-38");

bf16_nextabove($max_subnormal);
cmp_ok($max_subnormal, '==', Math::Bfloat16->new(2) ** -126, "next above max subnormal is 2 ** -126"); # 1.175e-38

bf16_nextbelow($max_subnormal);
cmp_ok($max_subnormal, '==', '1.166e-38', "next below 2 ** -126 is 1.166e-38");

my $neg_normal_min = Math::Bfloat16->new('-1.175e-38');
bf16_nextabove($neg_normal_min);
cmp_ok($neg_normal_min, '==', '-1.166e-38', "next above -1.175e-38 is -1.166e-38");



done_testing();
