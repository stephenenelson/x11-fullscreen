use strict;
use lib qw(inc);
use Devel::CheckLib;
use File::Spec;

# Prompt the user here for any paths and other configuration

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


use 5.008005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'X11::FullScreen',
    VERSION_FROM      => 'lib/X11/FullScreen.pm', # finds $VERSION
    TYPEMAPS          => ['perlobject.map'],
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/X11/FullScreen.pm', # retrieve abstract from module
       AUTHOR         => 'Stephen Nelson <stephenenelson@mac.com>') : ()),
    LIBS              => [$imlib_lib . ' -lz -lm -ldl  -lXext -lX11'], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I. ' . $imlib_include, # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);


sub find_imlib_config {
    for my $path_dir ( File::Spec->path() ) {
	my $bin = File::Spec->catfile($path_dir, 'imlib2-config');
	-x $bin and return $bin;
    }
    return;
}
