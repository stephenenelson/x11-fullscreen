# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl X11-FullScreen.t'

#########################

use FindBin '$Bin';

use Test::More;
BEGIN { use_ok('X11::FullScreen') };

#########################

our $Image = "$Bin/2003stephencentauri.png";


my $display_str = $ENV{'DISPLAY'};
my $display = X11::FullScreen->new($display // ':0');
isa_ok($display, 'X11::FullScreen');

SKIP: {
  skip 'No X11 display found', 1 unless $display;
  
  $display->show();
  ok(1, "show called");
  $display->sync();
  $display->display_still($Image);
  ok( defined $display->display, "Display is defined" );
  
  our $running = 1;
  $SIG{ALRM} = sub { $running = 0 };
  alarm(5);
  while ($running) {
    my $event = $display->check_event()
      or next;
    if ($event->get_type() == 12) {
      $display->display_still($Image);
    }
  }

  $display->close();
  ok(1, "Displayed images");
}

done_testing();