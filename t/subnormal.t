use strict;
use warnings;
use Math::Bfloat16 qw(:all);

use Test::More;

for(5e-41, 6e-41, 7e-41, 8e-41, 9e-41) {
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new($_), "10e-41 == $_ (NV)");
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new(Math::MPFR->new($_)), "10e-41 == $_ (MPFR from NV)");
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new($_), "4e-41 != $_ (NV)");
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new(Math::MPFR->new($_)), "4e-41 != $_ (MPFR from NV)");
}

for ('5e-41', '6e-41', '7e-41', '8e-41', '9e-41') {
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new($_), "10e-41 == $_ (PV)");
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new(Math::MPFR->new($_)), "10e-41 == $_ (MPFR from PV)");
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new($_), "4e-41 != $_ (PV)");
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new(Math::MPFR->new($_)), "4e-41 != $_ (MPFR from PV)");
}

cmp_ok(Math::Bfloat16->new(4e-41), '==', 0, '4e-41 is zero');


done_testing();
