package X11::FullScreen;

use 5.008005;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use X11::FullScreen ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

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

  my $display = X11::Fullscreen::Display->new();
  my $width = $display->getDisplayWidth();
  my $height = $display->getDisplayHeight();
  my $window = $display->createWindow($width,$height);

=head1 DESCRIPTION

Companion to Video::Xine, this module is used for creating simple
borderless X windows.

=head2 EXPORT

None by default.



=head1 SEE ALSO

L<Video::Xine>

=head1 AUTHOR

Stephen Nelson, E<lt>stephen@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Stephen Nelson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
