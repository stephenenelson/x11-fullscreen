package X11::FullScreen;

use 5.008005;
use strict;
use warnings;

our $VERSION = '0.03';

require XSLoader;
XSLoader::load('X11::FullScreen', $VERSION);

package X11::FullScreen::Display;

sub createWindow {
  my $self = shift;
  my ($width, $height) = @_;

  defined $width
    or $width = $self->getWidth();

  defined $height
    or $height = $self->getHeight();

  return doCreateWindow($self,$width,$height);
}

sub displayStill {
  my $self = shift;
  my ($window, $mrl, $width, $height) = @_;
  defined $width
    or $width = $self->getWidth();
  defined $height
    or $height = $self->getHeight();
  doDisplayStill($self,$window,$mrl,$width,$height);
}


1;
__END__

=head1 NAME

X11::FullScreen - Perl extension for creating a simple borderless window with X

=head1 SYNOPSIS

  use X11::FullScreen;

  # Open a handle to the X display 0.0
  my $display = X11::Fullscreen::Display->new(":0.0");

  # Create a full-screen window
  my $window = $display->createWindow();

  # Sync the X display
  $display->sync();

  # Display a still image
  $display->displayStill($window, "/path/to/my.png");

  # Return any new expose events
  my @events = $display->checkWindowEvent($window);


=head1 DESCRIPTION

Companion to Video::Xine, this module is used for creating simple
borderless X windows. In addition, it uses Imlib2 to display still
images.

It was primarily developed to provide a no-frills interface to X for
use with Video::Xine, as part of the Video::PlaybackMachine project.

=head1 METHODS

The primary class for this package is X11::FullScreen::Display.

=over

=item new( $display_string )

Creates a new Display object. C<$display_string> should be a valid
display specifier, such as ':0.0'. Example:

  my $display = X11::FullScreen::Display->new('localhost:0.1');

=item getDefaultScreenNumber()

Returns the number of the display's default screen.

=item getWidth( $screen_number )

Returns the width in pixels of the screen numbered C<$screen_number>
of the current display, or of the default screen if not specified.

=item getHeight( $screen_number )

Returns the height in pixels of the screen numbered C<$screen_number>
of the current display, or of the default screen if not specified.

=item getPixelAspect( $screen_number )

Returns the pixel aspect of the screen numbered C<$screen_number> of
the current display, or of the default screen if not specified. The
pixel aspect is calculated by dividing the screen's vertical
resolution by its horizontal resolution.

=item createWindow( $width, $height )

Creates a new X11 window on the display and returns its ID. If $width
and $height are not specified, takes up the entire screen.

=item displayStill( $window, $image_file, [ $width, $height ] )

Displays a still image on the given display on the given window.

=item checkWindowEvent( $window, $event_mask )

Checks for any new event which has occurred to C<$window>. If
C<$event_mask> is not specified, defaults to ( ExposureMask |
VisibilityChangeMask). This package does not yet have constants for
the various event masks available; if you wish to use different masks
you are on your own.

=back

=head1 BUGS

Undoubtably. This code is still in alpha state.

The checkWindowEvent() method is currently only useful for checking
for expose events, since the method does not provide useful constants
for passing event masks to it.

=head1 SEE ALSO

L<Video::Xine>, L<Video::PlaybackMachine>, L<Xlib>

=head1 AUTHOR

Stephen Nelson, E<lt>stephen@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Stephen Nelson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
