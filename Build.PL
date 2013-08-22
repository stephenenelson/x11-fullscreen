use strict;
use FindBin '$Bin';
use lib "$Bin/inc";

use PkgConfBuild;

my $build = PkgConfBuild->new(
    module_name          => 'X11::FullScreen',
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

