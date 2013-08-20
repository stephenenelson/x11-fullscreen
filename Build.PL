use strict;
use lib qw(inc);
use Devel::CheckLib;
use File::Spec;
use Module::Build;

check_lib_or_exit(
    # fill in what you prompted the user for here
    lib => [qw(Imlib2 X11 Xext freetype)]
);

my ($imlib_include, $imlib_lib);
if ( my $imlib_config = find_imlib_config() ) {
    $imlib_include = qx/$imlib_config --cflags/;
    $imlib_lib = qx/$imlib_config --libs/;
}
else {
    warn "Unable to find 'imlib2-config'. Please make sure that you have installed the development packages for imlib2 and that 'imlib2-config' is in your path.\n";
    exit(0);
}

sub find_imlib_config {
    for my $path_dir ( File::Spec->path() ) {
	my $bin = File::Spec->catfile($path_dir, 'imlib2-config');
	-x $bin and return $bin;
    }
    return;
}

my $build = Module::Build->new(
    module_name          => 'X11::FullScreen',
    extra_linker_flags   => $imlib_lib . ' -lz -lm -ldl  -lXext -lX11',
    extra_compiler_flags => '-I. ' . $imlib_include,
    license              => 'perl',
    build_requires => {
        'ExtUtils::CBuilder' => '0',
    },
	configure_requires => { 
		'Module::Build' => 0
	},
	test_requires => {
		'Test::More' => 0,
		'FindBin' => 0,
		'Test::Kwalitee' => 0,
		'Test::More' => 0
	},
	requires => {
		'perl' => '5.10.0',
		'XSLoader' => 0,
		'strict' => 0,
		'warnings' => 0
	}

);

$build->create_build_script();

