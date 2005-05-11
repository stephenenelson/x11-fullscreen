#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <X11/extensions/XShm.h>

#include <Imlib2.h>

#define MWM_HINTS_DECORATIONS   (1L << 1)
#define PROP_MWM_HINTS_ELEMENTS 5
typedef struct {
  uint32_t  flags;
  uint32_t  functions;
  uint32_t  decorations;
  int32_t   input_mode;
  uint32_t  status;
} MWMHints;


// Bitmap data for invisible pointer
static unsigned char bm_no_data[] = { 0,0,0,0, 0,0,0,0 };

// Color for invisible pointer
static XColor black = { 0L, 0, 0, 0, 0, 0 };


MODULE = X11::FullScreen	PACKAGE = X11::FullScreen::Display

Display *
new(CLASS,display_str=NULL)
	char *CLASS
	char *display_str
	CODE:
		if(!XInitThreads()) {
			croak("Unable to init threads");
		}
		RETVAL = XOpenDisplay(display_str);
	OUTPUT:
		RETVAL

int
getDefaultScreenNumber(display)
	Display * display
	CODE:
		RETVAL  = XDefaultScreen(display);
	OUTPUT:
		RETVAL

int
getWidth(display,screen=XDefaultScreen(display))
	Display * display
	int screen
	CODE:
		RETVAL = DisplayWidth(display, screen);
	OUTPUT:
		RETVAL


int
getHeight(display,screen=XDefaultScreen(display))
	Display * display
	int screen
	CODE:
		RETVAL = DisplayHeight(display, screen);
	OUTPUT:
		RETVAL

int
getDefaultScreen(display)
	Display * display
	CODE:
		RETVAL = XDefaultScreen(display);
	OUTPUT:
		RETVAL

double
getPixelAspect(display,screen=XDefaultScreen(display))
	Display * display
	int screen
	INIT:
		double res_h;
		double res_v;
	CODE:
		res_h = (DisplayWidth(display,screen) * 1000 / DisplayWidthMM(display, screen));
 		res_v = (DisplayHeight(display,screen) * 1000 / DisplayHeightMM(display, screen));
		RETVAL = res_v / res_h;
	OUTPUT:
		RETVAL

void
DESTROY(display)
	Display * display
	CODE:
  		XCloseDisplay(display);


Window
doCreateWindow(display,width,height)
	Display * display
	int width;
	int height;
	INIT:
		Pixmap bm_no;
		Cursor cursor;
		Atom XA_NO_BORDER;
		MWMHints mwmhints;
	CODE:
 		XLockDisplay(display);
 		RETVAL = XCreateSimpleWindow(display, XDefaultRootWindow(display), 0, 0, width, height, 0, 0, 0);
		XSelectInput(display, RETVAL, (ExposureMask | ButtonPressMask | KeyPressMask | ButtonMotionMask | StructureNotifyMask | PropertyChangeMask | PointerMotionMask));
  XA_NO_BORDER         = XInternAtom(display, "_MOTIF_WM_HINTS", False);
  mwmhints.flags       = MWM_HINTS_DECORATIONS;
  mwmhints.decorations = 0;
  XChangeProperty(display, RETVAL,
		  XA_NO_BORDER, XA_NO_BORDER, 32, PropModeReplace, (unsigned char *) &mwmhints,
		  PROP_MWM_HINTS_ELEMENTS);

		bm_no = XCreateBitmapFromData(display,
				XDefaultRootWindow(display),
				bm_no_data,
				8,
				8);

  		cursor = XCreatePixmapCursor(display, bm_no, bm_no, &black, &black, 0, 0);
  		XDefineCursor(display, RETVAL, cursor);
		XMapRaised(display, RETVAL);
  		XUnlockDisplay(display);
	OUTPUT:
		RETVAL


void
closeWindow(display, window)
	Display * display
	Window window
	CODE:
  		XLockDisplay(display);
  		XUnmapWindow(display,  window);
  		XDestroyWindow(display,  window);
 		XUnlockDisplay(display);


void
sync(display)
	Display * display
	CODE:
		XSync(display, False);

void
doDisplayStill(display,window,a_mrl,screen_width,screen_height)
	Display * display
	Window window
	char * a_mrl
	int screen_width
	int screen_height
	INIT:
	  Imlib_Image image;
	CODE:	
	  imlib_context_set_display(display);
	  imlib_context_set_visual(DefaultVisual(display,DefaultScreen(display)));
	  imlib_context_set_colormap(DefaultColormap(display,DefaultScreen(display)));
	  imlib_context_set_drawable(window);
	  image = imlib_load_image(a_mrl);
	  if (image == NULL) {
 	   croak("Unable to load image '%s'", a_mrl);
	  }
	  imlib_context_set_image(image);
	  imlib_render_image_on_drawable_at_size(0,0,screen_width,screen_height);
	  imlib_free_image();
	

XEvent *
checkWindowEvent(display,window,event_mask=( ExposureMask | VisibilityChangeMask ))
	Display * display
	Window window
	long event_mask
	PREINIT:
		char *CLASS = "X11::FullScreen::Event";
	CODE:
		RETVAL = (XEvent*) safemalloc( sizeof(XEvent) );
		if ( ! XCheckWindowEvent(
					display,
					window,
					event_mask,
					RETVAL) ) {
                        safefree(RETVAL);
			XSRETURN_UNDEF;
		}
	OUTPUT:
		RETVAL


MODULE = X11::FullScreen	PACKAGE = X11::FullScreen::Event	PREFIX=x11_fullscreen_event_

int
x11_fullscreen_event_get_type(event)
	XEvent *event
	CODE:
		RETVAL = event->type;
	OUTPUT:
		RETVAL

void
x11_fullscreen_event_DESTROY(event)
	XEvent *event
	CODE:
		safefree(event);
