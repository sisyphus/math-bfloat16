use strict;
use warnings;

use Math::Bfloat16 qw(:all);

use Test::More;

cmp_ok($Math::Bfloat16::VERSION, '==', '0.01', "We have Math-Bfloat16-0.01");


done_testing();
