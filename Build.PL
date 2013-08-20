use strict;
use lib qw(inc);
use Devel::CheckLib;
use ExtUtils::PkgConfig;
use Module::Build;

check_lib_or_exit(
    # fill in what you prompted the user for here
    lib => [qw(Imlib2 X11)]
);

my %x11_info = ExtUtils::PkgConfig->find('x11');
my %imlib2_info = ExtUtils::PkgConfig->find('imlib2');

my $build = Module::Build->new(
    module_name          => 'X11::FullScreen',
    extra_linker_flags   => $imlib2_info{'libs'} . ' ' . $x11_info{'libs'},
    extra_compiler_flags => '-I. ' . $imlib2_info{'cflags'} . ' ' . $x11_info{'cflags'},
    license              => 'perl',
    build_requires => {
        'ExtUtils::CBuilder' => '0',
    },
	configure_requires => { 
		'Module::Build' => 0,
		'Devel::CheckLib' => '1.01',
		'ExtUtils::PkgConfig' => 0
	},
	test_requires => {
		'Test::More' => 0,
		'Test::Kwalitee' => 0
	},
	requires => {
		'perl' => '5.10.0',
		'XSLoader' => 0,
		'strict' => 0,
		'warnings' => 0
	},
    meta_merge => {
    	resources => {
    		repository => 'https://github.com/stephenenelson/x11-fullscreen'
    	}
    }

);

$build->create_build_script();

