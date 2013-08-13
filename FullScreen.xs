#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


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


/* Bitmap data for invisible pointer */
static unsigned char bm_no_data[] = { 0,0,0,0, 0,0,0,0 };

/* Color for invisible pointer */
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
		XEvent xev;
		Atom wm_state;
		Atom fullscreen;
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
		
		wm_state = XInternAtom(display, "_NET_WM_STATE", False);
		fullscreen = XInternAtom(display, "_NET_WM_STATE_FULLSCREEN", False);
		
		memset(&xev, 0, sizeof(xev));
		xev.type = ClientMessage;
		xev.xclient.window = RETVAL;
		xev.xclient.message_type = wm_state;
		xev.xclient.format = 32;
		xev.xclient.data.l[0] = 1;
		xev.xclient.data.l[1] = fullscreen;
		xev.xclient.data.l[2] = 0;

		XSendEvent(display, DefaultRootWindow(display), False, SubstructureNotifyMask, &xev);
		
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
doDisplayStill(display,window,a_mrl)
	Display * display
	Window window
	char * a_mrl
	INIT:
	  int screen_width = 0;
	  int screen_height = 0;
	  XWindowAttributes windowattr;
	  Imlib_Image image;
	  int image_width = 0;
	  int image_height = 0;
	  int x = 0;
	  int y = 0;
	  float width_ratio = 0.0f;
	  float height_ratio = 0.0f;
	  int width;
	  int height;
	CODE:
	  if ( XGetWindowAttributes(display, window, &windowattr) == 0) { 
	  	croak("Failed to get window attributes"); 
	  } 
	  screen_width = windowattr.width; 
	  screen_height = windowattr.height;
	  imlib_context_set_display(display);
	  imlib_context_set_visual(DefaultVisual(display,DefaultScreen(display)));
	  imlib_context_set_colormap(DefaultColormap(display,DefaultScreen(display)));
	  imlib_context_set_drawable(window);
	  image = imlib_load_image_immediately(a_mrl);
	  if (image == NULL) {
 	   croak("Unable to load image '%s'", a_mrl);
	  }
	  imlib_context_set_image(image);
	  image_width = imlib_image_get_width();
	  image_height = imlib_image_get_height();
	  width_ratio =  (float) screen_width / (float) image_width;
	  height_ratio =  (float) screen_height / (float) image_height;
	  if ( width_ratio < height_ratio ) {
	  	height = round( image_height * width_ratio );
	  	width = screen_width;
	  	y = ( screen_height - height ) / 2;
	  }
	  else {
	  	width = round( image_width * height_ratio );
	  	height = screen_height;
	  	x = ( screen_width - width ) / 2;
	  }
	  imlib_render_image_on_drawable_at_size(x,y,width,height);
	  imlib_free_image();
	

void
clearWindow(display,window)
	Display * display
	Window window
	CODE:
		XClearWindow(display,window);

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
