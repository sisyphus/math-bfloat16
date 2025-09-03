use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;

eval{ require 5.032;};

if($@) {
  warn "\n Aborting build of Math::Bfloat16 because:\n$@\n";
  exit 0;
}

if($Config{ptrsize} == 4) {
  warn "\n Aborting build of Math::Bfloat16 because this is a 32-bit build of perl.\n",
       " (We might address this in the future to support 32-bit builds.)\n";
  exit 0;
}

###########################################
# Check whether __bf16 type is recognized #
###########################################

my $have_bfloat16 = 0;
my $mycc = $Config{cc};
my $ccflags = $Config{ccflags};
#$mycc .= ' -msse2' if $Config{ptrsize} == 4; # This can work ok - except that it
                                              # can also break other stuff.

my $out = `$mycc $ccflags -o have_bfloat16.exe -x c have_bfloat16.in 2>&1`;
if( -e 'have_bfloat16.exe') {
  my $size = $^O =~ /MSWin32/i ? `have_bfloat16.exe` : `./have_bfloat16.exe`;
  $have_bfloat16 = 1 if $size eq '2';
}
###########################################
###########################################

###########################################
# Check presence of suitable mpfr library #
###########################################

my ($mpfr_ver_ok, $mpfr_opt_ok, $version, $opt) = (0, 0, 0, 0);

$out = `$mycc $ccflags -o mpfr_ver.exe -x c mpfr_ver.in 2>&1`;
if( -e 'mpfr_ver.exe') {
  $version = $^O =~ /MSWin32/i ? `mpfr_ver.exe` : `./mpfr_ver.exe`;
  $mpfr_ver_ok = 1 if $version >= 262912;
}
else {
  warn "\n Aborting build of Math::Bfloat16 because the C program mpfr_ver.in failed to build.\n",
       " Build output was:\n $out\n";
  exit 0;
}

unless($mpfr_ver_ok) {
  warn "\n Aborting build of Math::Bfloat16 because mpfr (version $version) is less than 262912\n";
  exit 0;
}

##########################################

my $mylibpth;
my @libpth = split /\s+/, $Config{libpth};
for(@libpth) { $mylibpth .= " -L$_" }
$mylibpth .= " -lmpfr -lgmp";

$out = `$mycc $ccflags -o mpfr_opt.exe -x c mpfr_opt.in $mylibpth 2>&1`;
if( -e 'mpfr_opt.exe') {
  $opt = $^O =~ /MSWin32/i ? `mpfr_opt.exe` : `./mpfr_opt.exe`;
  $mpfr_opt_ok = 1 if $opt == 1;
}
else {
  warn "\n Aborting build of Math::Bfloat16 because the C program mpfr_opt.in failed to build.\n",
       " Build output was:\n $out\n";
  exit 0;
}

unless($mpfr_opt_ok) {
  warn "\n Aborting build of Math::Bfloat16 because mpfr was built without __bf16 support\n";
  exit 0;
}

##########################################

my $defines = $Config::Config{byteorder} =~ /^1234/ ? " -DWE_HAVE_LENDIAN" : " -DWE_HAVE_BENDIAN";

my %options = (
  NAME         => 'Math::Bfloat16',
  AUTHOR       => 'Sisyphus (sisyphus at (@) cpan dot (.) org)',
  ABSTRACT     => "Perl interface to C's __bf16 ('brain float') arithmetic",
  LICENSE      => 'perl',
  VERSION_FROM => 'Bfloat16.pm',
  LIBS         =>  ['-lmpfr -lgmp -lquadmath'],
  DEFINE       =>  $defines,
  clean        => { FILES => '*.exe *.txt' },
  META_MERGE   => {
    'meta-spec'  => { version => 2 },
    resources    => {
      repository   => {
        type         => 'git',
        url          => 'https://github.com/sisyphus/math-bfloat16.git',
        web          => 'https://github.com/sisyphus/math-bfloat16',
      },
    },
  },
);

my $prereq =  { 'Test::More' => '0.88',
                'Test::Warn' => '0.36',
                'Exporter'   => '5.58',
                'Math::MPFR' => '4.43',
              };

$options{PREREQ_PM} = $prereq;

WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
