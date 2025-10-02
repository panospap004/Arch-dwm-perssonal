/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

/* Size of the window border */
static unsigned int border_width = 4;
static int topbar = 0;                      /* -b  option; if 0, dmenu appears at bottom     */
static int draw_input = 1;                  /* -noi option; if 0, the input will not be drawn by default */
static int fuzzy  = 1;                      /* -F  option; if 0, dmenu doesn't use fuzzy matching */
static int centered = 1;                    /* -c option; centers dmenu on screen */
static int min_width = 500;                    /* minimum width when centered */
static const float menu_height_ratio = 4.0f;  /* This is the ratio used in the original calculation */

/* -fn option overrides fonts[0]; default X11 font or font set */
static char font[] = "MonaspaceRadonNF:size=10";
static const char *fonts[] = {
	"MonaspaceRadonNF:size=10",
};
// static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
// static const char *colors[SchemeLast][2] = {
static char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
static char normfgcolor[] = "#bbbbbb";
static char lightfgcolor[] = "#ffffff";
static char normbgcolor[] = "#222222";
static char selfgcolor[]  = "#eeeeee";
static char selbgcolor[]  = "#005577";
static char *colors[SchemeLast][2] = {
	/*     fg         bg       */
	[SchemeNorm] = { normfgcolor, normbgcolor },
	[SchemeSel] = { selfgcolor,  selbgcolor  },
	[SchemeSelHighlight] = { lightfgcolor, selbgcolor },
	[SchemeNormHighlight] = { lightfgcolor, normbgcolor },
	[SchemeOut] = { "#000000", "#00ffff" },
	// [SchemeNorm] = { "#bbbbbb", "#222222" },
	// [SchemeSel] = { "#eeeeee", "#005577" },
	// [SchemeSelHighlight] = { "#ffc978", "#005577" },
	// [SchemeNormHighlight] = { "#ffc978", "#222222" },
	// [SchemeOut] = { "#000000", "#00ffff" },
};
/* -l and -g options; controls number of lines and columns in grid if > 0 */
static unsigned int lines      = 9;
static unsigned int columns    = 5;
static int horizpadbar = 2;                 /* horizontal padding */
static int vertpadbar = 4;                  /* vertical padding */

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
	{ "font",   STRING, &font },
	{ "color4", STRING, &normfgcolor },
	{ "color6", STRING, &lightfgcolor },
	{ "color0", STRING, &normbgcolor },
	{ "color6", STRING, &selfgcolor },
 	{ "color1", STRING, &selbgcolor }, // this is the color that handles the border 
	{ "prompt", STRING, &prompt },
};
