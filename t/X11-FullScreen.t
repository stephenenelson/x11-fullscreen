# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl X11-FullScreen.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
BEGIN { use_ok('X11::FullScreen') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $display = X11::FullScreen::Display->new();
my $window = $display->createWindow();
$display->sync();
$display->displayStill($window,'/home/steven/baycon_stills/2003spacesuit.png');

sleep(5);

$display->closeWindow($window);
