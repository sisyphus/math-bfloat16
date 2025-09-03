use strict;
use warnings;
use Math::Bfloat16 qw(:all);

use Test::More;

my $have_mpfr = 0;
eval { require Math::MPFR;};
$have_mpfr = 1 unless $@;

for(5e-41, 6e-41, 7e-41, 8e-41, 9e-41) {
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new($_), "10e-41 == $_ (NV)");
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new(Math::MPFR->new($_)), "10e-41 == $_ (MPFR from NV)") if $have_mpfr;
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new($_), "4e-41 != $_ (NV)");
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new(Math::MPFR->new($_)), "4e-41 != $_ (MPFR from NV)") if $have_mpfr;
}

for ('5e-41', '6e-41', '7e-41', '8e-41', '9e-41') {
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new($_), "10e-41 == $_ (PV)");
   cmp_ok(Math::Bfloat16->new(10e-41), '==', Math::Bfloat16->new(Math::MPFR->new($_)), "10e-41 == $_ (MPFR from PV)") if $have_mpfr;
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new($_), "4e-41 != $_ (PV)");
   cmp_ok(Math::Bfloat16->new(4e-41 ), '!=', Math::Bfloat16->new(Math::MPFR->new($_)), "4e-41 != $_ (MPFR from PV)") if $have_mpfr;
}

cmp_ok(Math::Bfloat16->new(4e-41), '==', 0, '4e-41 is zero');


done_testing();
