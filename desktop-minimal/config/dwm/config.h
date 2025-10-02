/* See LICENSE file for copyright and license details. */

/* includes */
#include "gaplessgrid.c"
// include f keys header 
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int tabModKey = 0x40;
static const unsigned int tabCycleKey = 0x17;
static const unsigned int gappx     = 2;        /* gaps between windows */
static const unsigned int borderpx  = 4;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const Bool viewontag         = True;     /* Switch view on tag switch */
// anybar
static const int usealtbar          = 1;        /* 1 means use non-dwm status bar */
static const char *altbarclass      = "Polybar"; /* Alternate bar class name */
static const char *alttrayname      = "tray";    /* Polybar tray instance name */
// dont need the line bellow our launch script handles polybar launch
static const char *altbarcmd        = ""; /* Alternate bar launch command */
// static const char *altbarcmd        = "/home/dwm-test/bar.sh"; /* Alternate bar launch command */
// static const char *fonts[]          = { "monospace:size=12" };
// static const char *fonts[]          = {"MonaspaceRadonNF:size=10"};
static const char *fonts[] = {
    "MonospaceRadonNF:size=10",
    "Noto Sans CJK:size=10"  // example fallback with CJK support
};
static const char dmenufont[]       = "MonaspaceRadonNF:size=10";
// static const char col_gray1[]       = "#222222";
// static const char col_gray2[]       = "#444444";
// static const char col_gray3[]       = "#bbbbbb";
// static const char col_gray4[]       = "#eeeeee";
// static const char col_cyan[]        = "#005577";
// static const char *colors[][3]      = {
// 	/*               fg         bg         border   */
// 	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
// 	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
static char normbgcolor[]           = "#222222";
static char normbordercolor[]       = "#444444";
static char normfgcolor[]           = "#bbbbbb";
static char selfgcolor[]            = "#eeeeee";
static char selbordercolor[]        = "#005577";
static char selbgcolor[]            = "#005577";
static char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class                 instance    title             tags mask     isfloating   monitor */
	// { "Gimp",              NULL,       NULL,                0,            1,           -1 },
	{ "Yad",                  "yad",      "Keybindings",       0,            1,           -1 },
	{ "Vivaldi-stable",       NULL,       NULL,              1 << 0,         0,           -1 },
	{ "kitty",                NULL,       NULL,              1 << 2,         0,           -1 },
	{ "Firefox",              NULL,       NULL,              1 << 8,         0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 2;    /* number of clients in master area */
// static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
	/* symbol     arrange function */
  { "###",      gaplessgrid},
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* Custom functions */
static void tagmonfollow(const Arg *arg);

void
tagmonfollow(const Arg *arg)
{
    tagmon(arg);
    focusmon(arg);
}

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

#define STACKKEYS(MOD,ACTION) \
	{ MOD|ControlMask,  XK_space, ACTION##stack, {.i = PREVSEL } }, \
	{ MOD, XK_Left,     ACTION##stack, {.i = 0 } }, \
	{ MOD, XK_Right,    ACTION##stack, {.i = 1 } }, \
	{ MOD, XK_Up,       ACTION##stack, {.i = 1 } }, \
	{ MOD, XK_Down,     ACTION##stack, {.i = 2 } }, \
	{ MOD|ControlMask, XK_Down,     ACTION##stack, {.i = -1 } },
	// { MOD, XK_j,     ACTION##stack, {.i = INC(+1) } }, \
	// { MOD, XK_k,     ACTION##stack, {.i = INC(-1) } }, \

/* commands */
/* general */
static const char *lock[]  = { "slock", "-d", NULL };
static const char scratchpadname[] = "scratchpad";
const char *scratchpadcmd[] = { "kitty", "--class", scratchpadname,  "--title", scratchpadname, "-o", "remember_window_size=no", "-o", "initial_window_width=120c", "-o", "initial_window_height=34c", NULL };
// not used
// static const char *scratchpadcmd[] = { "st", "-t", scratchpadname, "-g", "120x34", NULL };

/* apps */
static const char *term[]  = { "kitty", NULL };
static const char *browser[]  = { "vivaldi", NULL };
static const char *fileManager[]  = { "Thunar", NULL };
// not used 
// static const char *termcmd[]  = { "st", NULL };

// Open on startup
Autostarttag autostarttaglist[] = {
	{.cmd = browser, .tags = 1 << 0 },
	{.cmd = term,    .tags = 1 << 2 },
	{.cmd = NULL, .tags = 0 },
};

/* dmenu */
static char dmenumon[2] = "-1"; /* component of dmenuCmd, manipulated in spawn() -1 == current active monitor 0 == first 1== secont etc */
static const char *dmenuCmd[] = { "dmenu_run", "-i", "-c", "-F", "-fn", dmenufont, NULL };
static const char *dmenuCalc[] = { "dmenu", "-c", "-C", NULL };
static const char *dmenuClipboard[] = {
  "/bin/sh", "-c",
  "greenclip print | grep . | dmenu -l 10 -g 4 -i -p clipboard | xargs -r -d '\\n' -I '{}' greenclip print '{}'",
  NULL
};
const char *dmenuMusic[] ={"/home/dwm-test/.config/scripts/DmenuBeats.sh", NULL}; // change the dwm-test with your username
const char *dmenuQuit[] ={"/home/dwm-test/.config/scripts/dmenu_sys.sh", NULL}; // change the dwm-test with your username
const char *dmenuWallpaper[] ={"/home/dwm-test/.config/scripts/wallpaper-menu.sh", NULL}; // change the dwm-test with your username
const char *dmenuWebSearch[] ={"/home/dwm-test/.config/scripts/websearch.sh", NULL}; // change the dwm-test with your username
const char *dmenuVideo[] ={"/home/dwm-test/.config/scripts/dmenu_mpv_player.sh", NULL}; // change the dwm-test with your username
const char *dmenuDoc[] ={"/home/dwm-test/.config/scripts/documents.sh", NULL}; // change the dwm-test with your username
const char *dmenuEq[] ={"/home/dwm-test/.config/scripts/eq-profiles.sh", NULL}; // change the dwm-test with your username
const char *dmenuManPage[] ={"/home/dwm-test/.config/scripts/man.sh", NULL}; // change the dwm-test with your username
const char *dmenuArchWiki[] ={"/home/dwm-test/.config/scripts/wiki.sh", NULL}; // change the dwm-test with your username
const char *dmenuRelaxingSounds[] ={"/home/dwm-test/.config/scripts/RelaxingSounds.sh", NULL}; // change the dwm-test with your username
const char *dmenuDictionary[] ={"/home/dwm-test/.config/scripts/dictionary.sh", NULL}; // change the dwm-test with your username
const char *dmenuSpellCheck[] ={"/home/dwm-test/.config/scripts/spellcheck.sh", NULL}; // change the dwm-test with your username
// not used
// static const char *dmenuCmd[] = { "dmenu_run", "-c", "-F", "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbordercolor, "-sf", selfgcolor, NULL };
// static const char *dmenuCmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };

/* rofi */
const char *rofiClipboard[] ={"/home/dwm-test/.config/scripts/ClipManager.sh", NULL}; // change the dwm-test with your username
const char *rofiCalc[] ={"/home/dwm-test/.config/scripts/RofiCalc.sh", NULL}; // change the dwm-test with your username
const char *rofiEmoji[] ={"/home/dwm-test/.config/scripts/RofiEmoji.sh", NULL}; // change the dwm-test with your username
const char *rofiKeybinds[] ={"/home/dwm-test/.config/scripts/KeyBinds.sh", NULL}; // change the dwm-test with your username
const char *rofiKeyHints[] ={"/home/dwm-test/.config/scripts/KeyHints.sh", NULL}; // change the dwm-test with your username
const char *rofiWallpaper[] ={"/home/dwm-test/.config/scripts/WallpaperSelect.sh", NULL}; // change the dwm-test with your username
const char *rofiQuit[] ={"/home/dwm-test/.config/rofi/powermenu/type-5/powermenu.sh", NULL}; // change the dwm-test with your username
const char *rofiMusic[] ={"/home/dwm-test/.config/scripts/RofiBeats.sh", NULL}; // change the dwm-test with your username
const char *rofiRun[] ={"rofi", "-show", "drun", NULL}; // change the dwm-test with your username
const char *rofiWebSearch[] ={"/home/dwm-test/.config/scripts/websearch.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiQuickEdit[] ={"/home/dwm-test/.config/scripts/QuickEdit.sh", NULL}; // change the dwm-test with your username
const char *rofiDoc[] ={"/home/dwm-test/.config/scripts/documents.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiEq[] ={"/home/dwm-test/.config/scripts/eq-profiles.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiManPage[] ={"/home/dwm-test/.config/scripts/man.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiArchWiki[] ={"/home/dwm-test/.config/scripts/wiki.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiRelaxingSounds[] ={"/home/dwm-test/.config/scripts/RelaxingSounds.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiDictionary[] ={"/home/dwm-test/.config/scripts/dictionary.sh", "-r", NULL}; // change the dwm-test with your username
const char *rofiSpellCheck[] ={"/home/dwm-test/.config/scripts/spellcheck.sh", "-r", NULL}; // change the dwm-test with your username
// not used
// static const char *rofi[] = {"rofi", "-show", "drun", "-theme", "~/.config/rofi/config.rasi", NULL};
const char *rofiOldWebSearch[] ={"/home/dwm-test/.config/scripts/RofiSearch.sh", NULL}; // change the dwm-test with your username

/* scripts */
const char *themeOnly[] ={"/home/dwm-test/.config/scripts/wallpaper-wal.sh", NULL}; // change the dwm-test with your username
const char *idleToggle[] ={"/home/dwm-test/.config/scripts/x11-idle-inhibitor-toggle.sh", NULL}; // change the dwm-test with your username
const char *BriUp[] ={"/home/dwm-test/.config/scripts/Brightness.sh", "--inc", NULL}; // change the dwm-test with your username
const char *BriDown[] ={"/home/dwm-test/.config/scripts/Brightness.sh", "--dec", NULL}; // change the dwm-test with your username
const char *BriKeyUp[] ={"/home/dwm-test/.config/scripts/BrightnessKbd.sh", "--inc", NULL}; // change the dwm-test with your username
const char *BriKeyDown[] ={"/home/dwm-test/.config/scripts/BrightnessKbd.sh", "--dec", NULL}; // change the dwm-test with your username
const char *VolUp[] ={"/home/dwm-test/.config/scripts/Volume.sh", "--inc", NULL}; // change the dwm-test with your username
const char *VolDown[] ={"/home/dwm-test/.config/scripts/Volume.sh", "--dec", NULL}; // change the dwm-test with your username
const char *VolToggle[] ={"/home/dwm-test/.config/scripts/Volume.sh", "--toggle", NULL}; // change the dwm-test with your username
const char *MediaPrev[] ={"/home/dwm-test/.config/scripts/MediaCtrl.sh", "--prv", NULL}; // change the dwm-test with your username
const char *MediaNext[] ={"/home/dwm-test/.config/scripts/MediaCtrl.sh", "--nxt", NULL}; // change the dwm-test with your username
const char *MediaToggle[] ={"/home/dwm-test/.config/scripts/MediaCtrl.sh", "--pause", NULL}; // change the dwm-test with your username
const char *MediaStop[] ={"/home/dwm-test/.config/scripts/MediaCtrl.sh", "--stop", NULL}; // change the dwm-test with your username
const char *AirplaneMode[] ={"/home/dwm-test/.config/scripts/AirplaneMode.sh", NULL}; // change the dwm-test with your username
const char *ColorPicker[] ={"/home/dwm-test/.config/scripts/screenshot_extra_features.sh", "color", NULL}; // change the dwm-test with your username
const char *GenearlAudioOutSwitch[] ={"/home/dwm-test/.config/scripts/audio_output_switch.sh", NULL}; // change the dwm-test with your username
const char *PersonalAudioOutSwitch[] ={"/home/dwm-test/.config/scripts/dmenu_audioswitch_prev.sh", NULL}; // change the dwm-test with your username
const char *ForceKillActive[] ={"/home/dwm-test/.config/scripts/KillActiveProcess.sh", NULL}; // change the dwm-test with your username
const char *ScreenShotSel[] ={"/home/dwm-test/.config/scripts/screenshot_extra_features.sh", NULL}; // change the dwm-test with your username
const char *ScreenShotScreen[] ={"/home/dwm-test/.config/scripts/screenshot_extra_features.sh", "full", NULL}; // change the dwm-test with your username
const char *RecordSelNoAudio[] ={"/home/dwm-test/.config/scripts/record.sh", "-s", NULL}; // change the dwm-test with your username
const char *RecordSelAudio[] ={"/home/dwm-test/.config/scripts/record.sh", "-as", NULL}; // change the dwm-test with your username
const char *RecordScreenNoAudio[] ={"/home/dwm-test/.config/scripts/record.sh", NULL}; // change the dwm-test with your username
const char *RecordScreenAudio[] ={"/home/dwm-test/.config/scripts/record.sh", "-a", NULL}; // change the dwm-test with your username
// not used

static const Key keys[] = {
	/* modifier                     key        function               argument */
  // general 
	{ MODKEY,                       XK_l,      spawn,                 {.v = lock } }, // lock screen
	{ MODKEY,                       XK_q,      killclient,            {0} }, // kill active window normaly
	{ MODKEY|Mod1Mask,              XK_b,      togglebar,             {0} }, // toggle polybar to hide or not
	{ MODKEY,                       XK_space,  togglefloating,        {0} }, // make window float
	{ MODKEY|ControlMask,           XK_p,      togglesticky,          {0} }, // pin floating window so it follows you
	{ MODKEY|ShiftMask,             XK_f,      togglefullscr,         {0} }, // enter full screen
	{ MODKEY|ControlMask,           XK_bracketleft,   shiftview,      {.i = +1} }, // keybind for touchpad to change tags
	{ MODKEY|ControlMask,           XK_bracketright,  shiftview,      {.i = -1} }, // keybind for touchpad to change tags
	STACKKEYS(MODKEY,                          focus) // change window
	STACKKEYS(MODKEY|ShiftMask,                push) // move window
	{ MODKEY,                       XK_z,      zoom,                  {0} }, // swap master window with selected one
	{ MODKEY|Mod1Mask,              XK_Left,   viewtoleft,            {0} }, // move view 1 tag to the left
	{ MODKEY|Mod1Mask,              XK_Right,  viewtoright,           {0} }, // move view 1 tag to the right 
	{ MODKEY|ControlMask,           XK_Left,   tagtoleft,             {0} }, // move window 1 tag to the left 
	{ MODKEY|ControlMask,           XK_Right,  tagtoright,            {0} }, // move window 1 tag to the right
	TAGKEYS(                        XK_1,                             0) // go to tag 1-9 with win+1-9 
	TAGKEYS(                        XK_2,                             1) // or move tag to 1-9 with win+shift+1-9
	TAGKEYS(                        XK_3,                             2) // or view multiple tags with win+ctrl+1-9
	TAGKEYS(                        XK_4,                             3) // or clone windiw to multiple tags with win+ctrl+shift+1-9
	TAGKEYS(                        XK_5,                             4)
	TAGKEYS(                        XK_6,                             5)
	TAGKEYS(                        XK_7,                             6)
	TAGKEYS(                        XK_8,                             7)
	TAGKEYS(                        XK_9,                             8)
	{ MODKEY,                       XK_0,      view,                  {.ui = ~0 } }, // go to tag 0 so you can see all windows
	{ MODKEY|ShiftMask,             XK_0,      tag,                   {.ui = ~0 } }, // move to tag 0 so it shows in every tag
	{ MODKEY|ShiftMask,             XK_s,      winview,               {0} }, // select selected window from the 0 tag to go there
	{ MODKEY|Mod1Mask,              XK_comma,  focusmon,              {.i = -1 } }, // Move focus Between Multi monitors
  { MODKEY|Mod1Mask,              XK_period, focusmon,              {.i = +1 } }, // Move focus Between Multi monitors
  { MODKEY|ShiftMask,             XK_comma,  tagmonfollow,          {.i = -1 } }, // send Window To monitor and follow
  { MODKEY|ShiftMask,             XK_period, tagmonfollow,          {.i = +1 } }, // send Window To monitor and follow{ Mod1Mask,                     XK_Tab,    alttab,                {0} }, // alt tab to change window
	// { MODKEY|Mod1Mask,              XK_comma,  focusmon,              {.i = -1 } }, // Move focus Between Multi monitors
	// { MODKEY|Mod1Mask,              XK_period, focusmon,              {.i = +1 } }, // Move focus Between Multi monitors
	// { MODKEY|ShiftMask,             XK_comma,  tagmon,                {.i = -1 } }, // send Window To monitor
	// { MODKEY|ShiftMask,             XK_period, tagmon,                {.i = +1 } }, // send Window To monitor
  // not used general
	// { MODKEY,                    XK_i,      incnmaster,            {.i = +1 } }, // increase windows in master layouts
	// { MODKEY,                    XK_d,      incnmaster,            {.i = -1 } }, // decrease windows in master layout
	// { MODKEY,                    XK_h,      setmfact,              {.f = -0.05} },
	// { MODKEY,                    XK_l,      setmfact,              {.f = +0.05} },
	// { MODKEY,                    XK_t,      setlayout,             {.v = &layouts[0]} }, // tiled layout 
	// { MODKEY,                    XK_f,      setlayout,             {.v = &layouts[1]} }, // float layout 
	// { MODKEY,                    XK_m,      setlayout,             {.v = &layouts[2]} }, // monacle layout
	// { MODKEY|ShiftMask,          XK_space,  setlayout,             {0} },
	// { MODKEY|Mod1Mask,           XK_Tab,    view,                  {0} }, // swap master window and slave window positio 
  
  // apps 
	{ MODKEY,                       XK_Return, spawn,                 {.v = term } },
	{ MODKEY,                       XK_b,      spawn,                 {.v = browser} },
	{ MODKEY,                       XK_f,      spawn,                 {.v = fileManager} },
	{ MODKEY|ShiftMask,             XK_Return, togglescratch,         {.v = scratchpadcmd } },

  // not used apps 
	// { MODKEY|ShiftMask,          XK_Return, spawn,                 {.v = termcmd } },
  
  // dmenu 
	{ MODKEY|ShiftMask,             XK_d,      spawn,                 {.v = dmenuCmd } },
	{ MODKEY|ShiftMask,             XK_c,      spawn,                 {.v = dmenuCalc } },
	{ MODKEY|ShiftMask,             XK_v,      spawn,                 {.v = dmenuClipboard } },
	{ MODKEY|ShiftMask,             XK_x,      spawn,                 {.v = dmenuQuit } },
	{ MODKEY|ShiftMask,             XK_m,      spawn,                 {.v = dmenuMusic } },
	{ MODKEY|Mod1Mask,              XK_w,      spawn,                 {.v = dmenuWallpaper } },
	{ MODKEY|ShiftMask|ControlMask, XK_d,      spawn,                 {.v = dmenuDoc } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_s,      spawn,                 {.v = dmenuWebSearch} },
	{ MODKEY|ShiftMask|ControlMask, XK_m,      spawn,                 {.v = dmenuManPage } },
	{ MODKEY|ShiftMask|ControlMask, XK_e,      spawn,                 {.v = dmenuEq } },
	{ MODKEY|ShiftMask|Mod1Mask,    XK_a,      spawn,                 {.v = dmenuArchWiki } },
	{ MODKEY|ShiftMask|Mod1Mask,    XK_m,      spawn,                 {.v = dmenuRelaxingSounds } },
	{ MODKEY|ShiftMask|Mod1Mask,    XK_d,      spawn,                 {.v = dmenuDictionary } },
	{ MODKEY|ShiftMask|Mod1Mask,    XK_c,      spawn,                 {.v = dmenuSpellCheck } },
	{ MODKEY|ControlMask,           XK_v,      spawn,                 {.v = dmenuVideo } },
  
  // rofi 
	{ MODKEY,                       XK_d,      spawn,                 {.v = rofiRun } },
	{ MODKEY,                       XK_c,      spawn,                 {.v = rofiCalc } },
	{ MODKEY,                       XK_v,      spawn,                 {.v = rofiClipboard } },
	{ MODKEY,                       XK_x,      spawn,                 {.v = rofiQuit } },
	{ MODKEY,                       XK_m,      spawn,                 {.v = rofiMusic } },
	{ MODKEY,                       XK_w,      spawn,                 {.v = rofiWallpaper } },
	{ MODKEY|ControlMask,           XK_d,      spawn,                 {.v = rofiDoc } },
	{ MODKEY|Mod1Mask,              XK_s,      spawn,                 {.v = rofiWebSearch} },
	{ MODKEY|ControlMask,           XK_m,      spawn,                 {.v = rofiManPage } },
	{ MODKEY|ControlMask,           XK_e,      spawn,                 {.v = rofiEq } },
	{ MODKEY|ShiftMask|ControlMask, XK_a,      spawn,                 {.v = rofiArchWiki } },
	{ MODKEY|Mod1Mask,              XK_m,      spawn,                 {.v = rofiRelaxingSounds } },
	{ MODKEY|Mod1Mask,              XK_d,      spawn,                 {.v = rofiDictionary } },
	{ MODKEY|Mod1Mask,              XK_c,      spawn,                 {.v = rofiSpellCheck } },
	{ MODKEY,                       XK_comma,  spawn,                 {.v = rofiEmoji } },
	{ MODKEY,                       XK_slash,  spawn,                 {.v = rofiKeybinds } },
	{ MODKEY|ShiftMask,             XK_e,      spawn,                 {.v = rofiQuickEdit } },
  
  // scripts
	{ MODKEY|ShiftMask,             XK_w,      spawn,                 {.v = themeOnly } },
	{ MODKEY|ShiftMask,             XK_i,      spawn,                 {.v = idleToggle } },
  { 0,                            XF86XK_AudioMute,          spawn, {.v = VolToggle} },
  { 0,                            XF86XK_AudioLowerVolume,   spawn, {.v = VolDown} },
  { 0,                            XF86XK_AudioRaiseVolume,   spawn, {.v = VolUp} },
  { 0,                            XF86XK_MonBrightnessDown,  spawn, {.v = BriDown} },
  { 0,                            XF86XK_MonBrightnessUp,    spawn, {.v = BriUp} },
  { Mod1Mask,                     XF86XK_MonBrightnessDown,  spawn, {.v = BriKeyDown} },
  { Mod1Mask,                     XF86XK_MonBrightnessUp,    spawn, {.v = BriKeyUp} },
	{ MODKEY|ShiftMask,             XK_n,      spawn,                 {.v = MediaNext} },
	{ MODKEY|ShiftMask,             XK_p,      spawn,                 {.v = MediaPrev} },
	{ MODKEY|ControlMask,           XK_p,      spawn,                 {.v = MediaToggle} },
	{ MODKEY|Mod1Mask,              XK_space,  spawn,                 {.v = MediaStop} },
	{ MODKEY|Mod1Mask,              XK_a,      spawn,                 {.v = AirplaneMode} },
	{ MODKEY|ShiftMask,             XK_a,      spawn,                 {.v = GenearlAudioOutSwitch} },
	{ MODKEY|ControlMask,           XK_a,      spawn,                 {.v = PersonalAudioOutSwitch} },
	{ MODKEY|ControlMask,           XK_c,      spawn,                 {.v = ColorPicker} },
	{ MODKEY|ShiftMask,             XK_q,      spawn,                 {.v = ForceKillActive} },
	{ MODKEY|ControlMask,           XK_s,      spawn,                 {.v = ScreenShotScreen} },
	{ MODKEY|ShiftMask,             XK_s,      spawn,                 {.v = ScreenShotSel} },
	{ MODKEY|ControlMask,           XK_r,      spawn,                 {.v = RecordScreenNoAudio} },
	{ MODKEY|Mod1Mask,              XK_r,      spawn,                 {.v = RecordSelNoAudio} },
	{ MODKEY|Mod1Mask|ControlMask,  XK_r,      spawn,                 {.v = RecordScreenAudio} },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_r,      spawn,                 {.v = RecordSelAudio} },
	{ MODKEY|ShiftMask,             XK_r,      quit,           {0} }, // this reloads dwm due to a script
	{ MODKEY|ShiftMask,             XK_slash,  spawn,                 {.v = rofiKeyHints } },
	{ MODKEY|ControlMask,           XK_x,      spawn,         {.v = (const char*[]){"pkill", "dwm", NULL}}}, // this quits dwm
  // not used scripts
	// { MODKEY,                    XK_F5,     xrdb,           {.v = NULL } }, // wallpaper-wal and menu does it with the script
  // {0,                             XF86XK_AudioMute,          spawn, SHCMD("pactl set-sink-mute 0 toggle")},
  // {0,                             XF86XK_AudioLowerVolume,   spawn, SHCMD("pactl set-sink-volume 0 -5%")},
  // {0,                             XF86XK_AudioRaiseVolume,   spawn, SHCMD("pactl set-sink-volume 0 +5%")},
  // {0,                             XF86XK_MonBrightnessDown,  spawn, SHCMD("brightnessctl set 5%-")},
  // {0,                             XF86XK_MonBrightnessUp,    spawn, SHCMD("brightnessctl set 5%+")}, 
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	// { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	// { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	// { ClkWinTitle,          0,              Button2,        zoom,           {0} },
	// { ClkStatusText,        0,              Button2,        spawn,          {.v = term } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

