# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl X11-FullScreen.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use FindBin '$Bin';

use Test::More tests => 2;
BEGIN { use_ok('X11::FullScreen') };

#########################

our $Image = "$Bin/2003stephencentauri.png";

my $display = X11::FullScreen::Display->new();
my $window = $display->createWindow();
$display->sync();
$display->displayStill($window,$Image);

our $running = 1;
$SIG{ALRM} = sub { $running = 0 };
alarm(5);
while ($running) {
	my $event = $display->checkWindowEvent($window)
	  or next;
	if ($event->get_type() == 12) {
	  $display->displayStill($window,$Image);
	}
}

$display->closeWindow($window);
ok(1);
