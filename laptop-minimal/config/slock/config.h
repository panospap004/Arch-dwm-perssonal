/* user and group to drop privileges to */
// static const char *user  = "dwm-test";
// static const char *group = "nogroup";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "black",     /* after initialization */
	[INPUT] =  "#005577",   /* during input */
	[FAILED] = "#CC3333",   /* wrong password */
	[CAPS] = "red",         /* CapsLock on */
};

/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
		{ "color4",       STRING,  &colorname[INIT] },
		{ "color2",       STRING,  &colorname[INPUT] },
		{ "color1",       STRING,  &colorname[FAILED] },
		{ "color3",       STRING,  &colorname[CAPS] },
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* time in seconds before the monitor shuts down */
static const int monitortime = 15;

/* enable or disable (1 means enable, 0 disable) bell sound when password is incorrect */
static const int xbell = 0;

/* time in seconds to cancel lock with mouse movement */
static const int timetocancel = 5;

#include <X11/XF86keysym.h>

static const Passthrough passthroughs[] = {
	/* Modifier   Key */
	{ 0,          XF86XK_AudioRaiseVolume },
	{ 0,          XF86XK_AudioLowerVolume },
	{ 0,          XF86XK_AudioMute },
	{ 0,          XF86XK_AudioPause },
	{ 0,          XF86XK_AudioStop },
	{ 0,          XF86XK_AudioNext },
	{ 0,          XF86XK_AudioPrev },
	{ 0,          XF86XK_MonBrightnessUp },
	{ 0,          XF86XK_MonBrightnessDown },
};


/* insert grid pattern with scale 1:1, the size can be changed with logosize */
static const int logosize = 20;
/* grid width and height for right center alignment */
static const int logow = 14;
static const int logoh = 8;

static XRectangle rectangles[9] = {
	/* x    y       w       h */
	{ 0,    3,      1,      3 },
	{ 1,    3,      2,      1 },
	{ 0,    5,      8,      1 },
	{ 3,    0,      1,      5 },
	{ 5,    3,      1,      2 },
	{ 7,    3,      1,      2 },
	{ 8,    3,      4,      1 },
	{ 9,    4,      1,      2 },
	{ 11,   4,      1,      2 },
};

/*Enable blur*/
#define BLUR
/*Set blur radius*/
static const int blurRadius=5;
/*Enable Pixelation*/
// #define PIXELATION
/*Set pixelation radius*/
static const int pixelSize=5;
