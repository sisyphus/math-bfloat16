use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;

require 5.032;

###########################################
# Check whether __bf16 type is recognized #
###########################################

my $have_bfloat16 = 0;
my $mycc = $Config{cc};
#$mycc .= ' -msse2' if $Config{ptrsize} == 4;

my $out = `$mycc -o have_bfloat16.exe -x c have_bfloat16.in 2>&1`;
if( -e 'have_bfloat16.exe') {
  my $size = $^O =~ /MSWin32/i ? `have_bfloat16.exe` : `./have_bfloat16.exe`;
  $have_bfloat16 = 1 if $size eq '2';
}

if(!$have_bfloat16) {
  warn "Aborting build of Math::Bfloat16 because the __bf16 type is not recognized by your compiler";
  exit 0;
}

my %options = (
  NAME         => 'Math::Bfloat16',
  AUTHOR       => 'Sisyphus (sisyphus at (@) cpan dot (.) org)',
  ABSTRACT     => "Perl interface to C's __bf16 ('brain float') arithmetic",
  LICENSE      => 'perl',
  VERSION_FROM => 'Bfloat16.pm',
  LIBS         =>  ['-lmpfr -lgmp -lquadmath'],
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
                'Exporter'   => '5.58', # avoid test failures on pre perl-5.8.4
                'Math::MPFR' => '4.43',
              };

$options{PREREQ_PM} = $prereq;

WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
