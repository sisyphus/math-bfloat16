use strict;
use warnings;
use Math::Bfloat16 qw(:all);

my $have_mpfr = 0;
eval { require Math::MPFR;};
$have_mpfr = 1 unless $@;

use Test::More;
cmp_ok(unpack_bf16_hex($Math::Bfloat16::bf16_DENORM_MIN), 'eq', '0001', "DENORM_MIN unpacks correctly");
cmp_ok(unpack_bf16_hex($Math::Bfloat16::bf16_DENORM_MAX), 'eq', '007F', "DENORM_MAX unpacks correctly");
cmp_ok(unpack_bf16_hex($Math::Bfloat16::bf16_NORM_MIN),   'eq', '0080', "NORM_MIN unpacks correctly");
cmp_ok(unpack_bf16_hex($Math::Bfloat16::bf16_NORM_MAX),   'eq', '7F7F', "NORM_MAX unpacks correctly");
cmp_ok(unpack_bf16_hex(sqrt(Math::Bfloat16->new(2))),     'eq', '3FB5', "sqrt 2 unpacks correctly");
cmp_ok(unpack_bf16_hex(Math::Bfloat16->new('5e-41')),     'eq', '0001', "'5e-41' unpacks correctly");
cmp_ok(unpack_bf16_hex(Math::Bfloat16->new(Math::MPFR->new('5e-41'))), 'eq', '0001', "MPFR('5e-41') unpacks correctly") if $have_mpfr;

cmp_ok(unpack_bf16_hex(-$Math::Bfloat16::bf16_DENORM_MIN), 'eq', '8001', "-DENORM_MIN unpacks correctly");
cmp_ok(unpack_bf16_hex(-$Math::Bfloat16::bf16_DENORM_MAX), 'eq', '807F', "-DENORM_MAX unpacks correctly");
cmp_ok(unpack_bf16_hex(-$Math::Bfloat16::bf16_NORM_MIN),   'eq', '8080', "-NORM_MIN unpacks correctly");
cmp_ok(unpack_bf16_hex(-$Math::Bfloat16::bf16_NORM_MAX),   'eq', 'FF7F', "-NORM_MAX unpacks correctly");
cmp_ok(unpack_bf16_hex(-(sqrt(Math::Bfloat16->new(2)))),   'eq', 'BFB5', "-(sqrt 2) unpacks correctly");
cmp_ok(unpack_bf16_hex(Math::Bfloat16->new('-5e-41')),     'eq', '8001', "'-5e-41' unpacks correctly");
cmp_ok(unpack_bf16_hex(Math::Bfloat16->new(Math::MPFR->new('-5e-41'))), 'eq', '8001', "MPFR('5e-41') unpacks correctly") if $have_mpfr;

{
  my $inc = Math::Bfloat16->new('0');
  my $dec = Math::Bfloat16->new('-0');

  my ($iv_inc, $iv_dec, $iv_store) = (0, 0, 0);

  cmp_ok(unpack_bf16_hex($inc), 'eq', '0000', " 0 unpacks to 0000");
  cmp_ok(unpack_bf16_hex($dec), 'eq', '8000', "-0 unpacks to 8000");

  my $pack = pack_bf16_hex('0000');
  cmp_ok(ref($pack), 'eq', "Math::Bfloat16", "'0000': pack returns Math::Bfloat16 object");
  cmp_ok(is_bf16_zero($pack), '==', 1, "returns 0 as expected");

  $pack = pack_bf16_hex('8000');
  cmp_ok(ref($pack), 'eq', "Math::Bfloat16", "'8000': pack returns Math::Bfloat16 object");
  cmp_ok(is_bf16_zero($pack), '==', -1, "returns -0 as expected");

  for(1..2060) {
    bf16_nextabove($inc);
    bf16_nextbelow($dec);
    my $unpack_inc = unpack_bf16_hex($inc);
    my $pack_inc = pack_bf16_hex($unpack_inc);
    cmp_ok($pack_inc, '==', $inc, "$unpack_inc: round_trip ok");

    my $unpack_dec = unpack_bf16_hex($dec);
    my $pack_dec = pack_bf16_hex($unpack_dec);
    cmp_ok($pack_dec, '==', $dec, "$unpack_dec: round_trip ok");

    cmp_ok(length($unpack_inc), '==', 4, "length($unpack_inc) == 4");
    cmp_ok(length($unpack_dec), '==', 4, "length($unpack_inc) == 4");

    $iv_inc = hex($unpack_inc);
    cmp_ok($iv_inc - $iv_store, '==', 1, "inc has been incremented to $unpack_inc");
    $iv_dec = hex($unpack_dec);
    cmp_ok($iv_dec - $iv_inc, '==', 0x8000, "dec has been decremented to $unpack_dec");

    $iv_store = $iv_inc;
  }
}

{
  my $inc = Math::Bfloat16->new('-inf');
  my $dec = Math::Bfloat16->new('inf');

  my ($iv_inc, $iv_dec, $iv_store) = (0, 0, hex('7F80'));

  cmp_ok(is_bf16_inf($inc), '==', -1, "is -inf as expected");
  cmp_ok(is_bf16_inf($dec), '==', 1, "is +inf as expected");

  cmp_ok(unpack_bf16_hex($inc), 'eq', 'FF80', " -inf unpacks to FF80");
  cmp_ok(unpack_bf16_hex($dec), 'eq', '7F80', "+inf unpacks to 7F80");

  my $pack = pack_bf16_hex('FF80');
  cmp_ok(ref($pack), 'eq', "Math::Bfloat16", "'FF80': pack returns Math::Bfloat16 object");
  cmp_ok(is_bf16_inf($pack), '==', -1, "returns -inf as expected");

  $pack = pack_bf16_hex('7F80');
  cmp_ok(ref($pack), 'eq', "Math::Bfloat16", "'7F80': pack returns Math::Bfloat16 object");
  cmp_ok(is_bf16_inf($pack), '==', 1, "returns +inf as expected");

  for(1..2060) {
    bf16_nextabove($inc);
    bf16_nextbelow($dec);
    my $unpack_inc = unpack_bf16_hex($inc);
    my $pack_inc = pack_bf16_hex($unpack_inc);
    cmp_ok($pack_inc, '==', $inc, "$unpack_inc: round_trip ok");

    my $unpack_dec = unpack_bf16_hex($dec);
    my $pack_dec = pack_bf16_hex($unpack_dec);
    cmp_ok($pack_dec, '==', $dec, "$unpack_dec: round_trip ok");

    cmp_ok(length($unpack_inc), '==', 4, "length($unpack_inc) == 4");
    cmp_ok(length($unpack_dec), '==', 4, "length($unpack_inc) == 4");

    $iv_dec = hex($unpack_dec);
    cmp_ok($iv_store - $iv_dec, '==', 1, "dec has been decremented to $unpack_dec");
    $iv_inc = hex($unpack_inc);
    cmp_ok($iv_inc - $iv_dec, '==', 0x8000, "inc has been incremented to $unpack_inc");

    $iv_store = $iv_dec;
  }
}

{

  # Check for values next to the subnormal/normal boundary
  my $inc = Math::Bfloat16->new($Math::Bfloat16::bf16_DENORM_MAX);
  my $dec = Math::Bfloat16->new(-$Math::Bfloat16::bf16_DENORM_MAX);

  $inc -= 10 * $Math::Bfloat16::bf16_DENORM_MIN;
  $dec += 10 * $Math::Bfloat16::bf16_DENORM_MIN;

  my ($iv_inc, $iv_dec, $iv_store) = (0, 0, hex(unpack_bf16_hex($inc)));

  for(1..20) {
    bf16_nextabove($inc);
    bf16_nextbelow($dec);
    my $unpack_inc = unpack_bf16_hex($inc);
    my $pack_inc = pack_bf16_hex($unpack_inc);
    cmp_ok($pack_inc, '==', $inc, "$unpack_inc: round_trip ok");

    my $unpack_dec = unpack_bf16_hex($dec);
    my $pack_dec = pack_bf16_hex($unpack_dec);
    cmp_ok($pack_dec, '==', $dec, "$unpack_dec: round_trip ok");

    cmp_ok(length($unpack_inc), '==', 4, "length($unpack_inc) == 4");
    cmp_ok(length($unpack_dec), '==', 4, "length($unpack_inc) == 4");

    $iv_inc = hex($unpack_inc);
    cmp_ok($iv_inc - $iv_store, '==', 1, "inc has been incremented to $unpack_inc");
    $iv_dec = hex($unpack_dec);
    cmp_ok($iv_dec - $iv_inc, '==', 0x8000, "dec has been decremented to $unpack_dec");

    $iv_store = $iv_inc;
  }
}

done_testing();
