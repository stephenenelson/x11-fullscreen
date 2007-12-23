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
    LIBS              => ['-L/usr/lib64 -L/usr/lib -lImlib2 -lfreetype -lz -lm -ldl  -L/usr/X11R6/lib64 -lXext -lX11'], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
