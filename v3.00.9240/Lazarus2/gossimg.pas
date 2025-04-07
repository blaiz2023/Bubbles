unit gossimg;

interface

uses
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3} sysutils, math, gossroot, gossio, gosswin; {$endif}
{$ifdef laz} sysutils, math, gossroot, gossio, gosswin; {$endif}
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}

//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2024 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. Graphics (gossimg.pas)
//## Version.................. 4.00.10257
//## Items.................... 4
//## Last Updated ............ 17apr2024
//## Lines of Code............ 11,500+
//##
//## gossroot.pas ............ App hub / core program execution
//## gossio.pas .............. File IO
//## gossimg.pas ............. Graphics
//## gossnet.pas ............. Network
//## gosswin.pas ............. Win32
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | mis*                   | family of procs   | 1.00.9900 | 17apr2024   | Graphic procs for working with multiple different image objects
//## | tbasicimage            | tobject           | 1.00.187  | 07dec2023   | Lightweight, fast, variable bit (8/24/32), system independent image handler - 09may2022, 27jul2021, 25jan2021, ??jan2020
//## | tbitmap2               | tobject           | 1.00.050  | 03jan2023   | Lightweight alternative to tbitmap -> no canvas support
//## | tbmp                   | tobject           | 1.00.120  | 05feb2022   | Bitmap to system image conversion and handler with Android and Windows lock/unlock support for Mobile phone and 32bit support - 08jun2021, 25jan2021, ??jan2020
//## ==========================================================================================================================================================================================================================

type
{tbasicimage}
   tbasicimage=class(tobject)
   private
    idata,irows:tstr8;
    ibits,iwidth,iheight:longint;
    iprows8 :pcolorrows8;
    iprows16:pcolorrows16;
    iprows24:pcolorrows24;
    iprows32:pcolorrows32;
    istable:boolean;
    procedure setareadata(sa:trect;sdata:tstr8);
    function getareadata(sa:trect):tstr8;
    function getareadata2(sa:trect):tstr8;
   public
    //animation support
    ai:tanimationinformation;
    dtransparent:boolean;
    omovie:boolean;//default=false, true=fromdata will create the "movie" if not already created
    oaddress:string;//used for "AAS" to load from a specific folder - 30NOV2010
    ocleanmask32bpp:boolean;//default=false, true=reads only the upper levels of the 8bit mask of a 32bit icon/cursor to eliminate poor mask quality - ccs.fromicon32() etc - 26JAN2012
    rhavemovie:boolean;//default=false, true=object has a movie as it's animation
    //create
    constructor create; virtual;
    destructor destroy; override;
    function copyfrom(s:tbasicimage):boolean;//09may2022, 09feb2022
    //information
    property stable:boolean read istable;
    property bits:longint read ibits;
    property width:longint read iwidth;
    property height:longint read iheight;
    property prows8 :pcolorrows8  read iprows8;
    property prows16:pcolorrows16 read iprows16;
    property prows24:pcolorrows24 read iprows24;
    property prows32:pcolorrows32 read iprows32;
    property rows:tstr8 read irows;
    //workers
    function sizeto(dw,dh:longint):boolean;
    function setparams(dbits,dw,dh:longint):boolean;
    function findscanline(slayer,sy:longint):pointer;
    //io
    function todata:tstr8;//19feb2022
    function fromdata(s:tstr8):boolean;//19feb2022
    //core
    property data:tstr8 read idata;
    //.raw data handlers
    function setraw(dbits,dw,dh:longint;ddata:tstr8):boolean;
    function getarea(ddata:tstr8;da:trect):boolean;//07dec2023
    function getarea_fast(ddata:tstr8;da:trect):boolean;//07dec2023 - uses a statically sized buffer (sizes it to correct length if required) so repeat usage is faster
    function setarea(ddata:tstr8;da:trect):boolean;//07dec2023
    property areadata[sa:trect]:tstr8 read getareadata write setareadata;
    property areadata_fast[sa:trect]:tstr8 read getareadata2 write setareadata;
   end;

{tbitmap2}
   tbitmap2=class(tobject)
   private
    icore:tdynamicstr8;
    irows:tstr8;
    ifallback:tstr8;
    ibits,iwidth,iheight,ilockcount:longint;
    irows8 :pcolorrows8;
    irows15:pcolorrows16;
    irows16:pcolorrows16;
    irows24:pcolorrows24;
    irows32:pcolorrows32;
    procedure setbits(x:longint);
    procedure setwidth(x:longint);
    procedure setheight(x:longint);
    function getscanline(sy:longint):pointer;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property core:tdynamicstr8 read icore;
    function cansetparams:boolean;
    function setparams(dbits,dw,dh:longint):boolean;
    property width:longint read iwidth write setwidth;
    property height:longint read iheight write setheight;
    property bits:longint read ibits write setbits;
    //rows -> can only use rows when locked, e.g. "canrows=true" - 21may2020
    function canrows:boolean;
    property rows:tstr8 read irows;//read-only
    property prows8 :pcolorrows8  read irows8;
    property prows15:pcolorrows16 read irows15;
    property prows16:pcolorrows16 read irows16;
    property prows24:pcolorrows24 read irows24;
    property prows32:pcolorrows32 read irows32;
    property scanline[sy:longint]:pointer read getscanline;
    //lock -> required to map rows under Android via FireMonkey
    function locked:boolean;
    function lock:boolean;
    function unlock:boolean;
    //dummmy canvas support
    function cancanvas:boolean;
    function canvas:tobject;
    //assign
    function assign(x:tobject):boolean;
   end;

{tbmp}
   tbmp=class(tobject)
   private
    icore:tbitmap2;
    irows:tstr8;
    isharp,ilockcount,ibits,iwidth,iheight:longint;
    iunlocking:boolean;
    irows8 :pcolorrows8;
    irows15:pcolorrows16;
    irows16:pcolorrows16;
    irows24:pcolorrows24;
    irows32:pcolorrows32;
    ilockptr:pointer;
    {$ifdef d3laz}
    isharphfont:hfont;//Win32 only
    {$endif}
    procedure setbits(x:longint);
    procedure setwidth(x:longint);
    procedure setheight(x:longint);
    procedure setsharp(x:longint);
    function getcanvas:tobject;
    procedure xinfo;
   public
    //animation support
    ai:tanimationinformation;
    dtransparent:boolean;
    omovie:boolean;//default=false, true=fromdata will create the "movie" if not already created
    oaddress:string;//used for "AAS" to load from a specific folder - 30NOV2010
    ocleanmask32bpp:boolean;//default=false, true=reads only the upper levels of the 8bit mask of a 32bit icon/cursor to eliminate poor mask quality - ccs.fromicon32() etc - 26JAN2012
    rhavemovie:boolean;//default=false, true=object has a movie as it's animation
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property core:tbitmap2 read icore;
    function cansetparams:boolean;
    function setparams(dbits,dw,dh:longint):boolean;
    property width:longint read iwidth write setwidth;
    property height:longint read iheight write setheight;
    property bits:longint read ibits write setbits;
    //rows -> can only use rows when locked, e.g. "canrows=true" - 21may2020
    function canrows:boolean;
    property rows:tstr8 read irows;//read-only
    property prows8 :pcolorrows8  read irows8;
    property prows15:pcolorrows16 read irows15;
    property prows16:pcolorrows16 read irows16;
    property prows24:pcolorrows24 read irows24;
    property prows32:pcolorrows32 read irows32;
    //lock -> required to map rows under Android via FireMonkey
    function locked:boolean;
    function lock:boolean;
    function unlock:boolean;
    //sharp -> can't do this once we're locked
    function cansharp:boolean;
    property sharp:longint read isharp write setsharp;//0=off, 1=sharp, 2=greyscale
    //canvas
    function cancanvas:boolean;
//    property canvas:tcanvas read getcanvas;
    //assign
    function canassign:boolean;
    function assign(x:tobject):boolean;
   end;

var
   //.started
   system_started      :boolean=false;
   //.temp buffer support
   systmpstyle           :array[0..99] of byte;//0=free, 1=available, 2=locked
   systmpid              :array[0..99] of string;
   systmptime            :array[0..99] of comp;
   systmpbmp             :array[0..99] of tbasicimage;//23may2020
   systmppos             :longint;
   //.temp int buffer support
   sysintstyle           :array[0..99] of byte;//0=free, 1=available, 2=locked
   sysintid              :array[0..99] of string;
   sysinttime            :array[0..99] of comp;
   sysintobj             :array[0..99] of tdynamicinteger;
   sysintpos             :longint;
   //.temp byte buffer support
   sysbytestyle          :array[0..99] of byte;//0=free, 1=available, 2=locked
   sysbyteid             :array[0..99] of string;
   sysbytetime           :array[0..99] of comp;
   sysbyteobj            :array[0..99] of tdynamicbyte;
   sysbytepos            :longint;
   //.mis support
   system_default_ai     :tanimationinformation;//29may2019


//start-stop procs -------------------------------------------------------------
procedure gossimg__start;
procedure gossimg__stop;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__img(xname:string):string;//information specific to this unit of code

//general procs ----------------------------------------------------------------
function zzimg(x:tobject):boolean;//12feb2202
function asimg(x:tobject):tbasicimage;//12feb2202

//temp procs -------------------------------------------------------------------
//note: rapid reuse of temporary objects for caching tasks, like for intensive graphics scaling work etc
function low__createimg24(var x:tbasicimage;xid:string;var xwascached:boolean):boolean;
procedure low__freeimg(var x:tbasicimage);
procedure low__checkimg;
function low__createint(var x:tdynamicinteger;xid:string;var xwascached:boolean):boolean;
procedure low__freeint(var x:tdynamicinteger);
procedure low__checkint;
function low__createbyte(var x:tdynamicbyte;xid:string;var xwascached:boolean):boolean;
procedure low__freebyte(var x:tdynamicbyte);
procedure low__checkbyte;

//graphics procs ---------------------------------------------------------------
function low__cornerMaxwidth:longint;//used by some patch systems to work around corner restrictions such as "statusbar.cellpert.round/square" - 07ul2021
function low__cornersolid(xdynamicCorners:boolean;var a:trect;amin,ay,xmin,xmax,xroundstyle:longint;xround:boolean;var lx,rx:longint):boolean;//29mar2021
function misv(s:tobject):boolean;//image is valid
function misb(s:tobject):longint;//get image bits
procedure missetb(s:tobject;sbits:longint);
function missetb2(s:tobject;sbits:longint):boolean;//12feb2022
function misw(s:tobject):longint;//get image width
function mish(s:tobject):longint;//get image height
//.animation information
function misonecell(s:tobject):boolean;//26apr2022
function miscells(s:tobject;var sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;var shasai:boolean;var stransparent:boolean):boolean;//27jul2021
function miscell(s:tobject;sindex:longint;var scellarea:trect):boolean;
function miscell2(s:tobject;sindex:longint):trect;
function miscellarea(s:tobject;sindex:longint):trect;
function mishasai(s:tobject):boolean;
function misaiclear2(s:tobject):boolean;
function misaiclear(var x:tanimationinformation):boolean;
function misai(s:tobject):panimationinformation;
function low__aicopy(var s,d:tanimationinformation):boolean;
function misaicopy(s,d:tobject):boolean;
{$ifdef jpeg}
function misjpg:tjpegimage;//01may2021
{$endif}
//.create image
function createbitmap:tbitmap2;
function misbitmap(dbits,dw,dh:longint):tbitmap2;
function misbitmap32(dw,dh:longint):tbitmap2;
function misbmp(dbits,dw,dh:longint):tbmp;
function misbmp32(dw,dh:longint):tbmp;
function misbmp24(dw,dh:longint):tbmp;
function misimg(dbits,dw,dh:longint):tbasicimage;
function misimg8(dw,dh:longint):tbasicimage;//26jan2021
function misimg24(dw,dh:longint):tbasicimage;
function misimg32(dw,dh:longint):tbasicimage;
//.size image
function misatleast(s:tobject;dw,dh:longint):boolean;//26jul2021
function missize(s:tobject;dw,dh:longint):boolean;
function missize2(s:tobject;dw,dh:longint;xoverridelock:boolean):boolean;
//.area
function misrect(x,y,x2,y2:longint):trect;
function misarea(s:tobject):trect;//get image area (0,0,w-1,h-1)
//.check image and get basic imformation
function miscopy(s,d:tobject):boolean;//12feb2022
function misokex(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misok(s:tobject;var sbits,sw,sh:longint):boolean;
function misokk(s:tobject):boolean;
function misokai(s:tobject;var sbits,sw,sh:longint):boolean;
function misokaii(s:tobject):boolean;
function misok8(s:tobject;var sw,sh:longint):boolean;
function misokai8(s:tobject;var sw,sh:longint):boolean;
function misok24(s:tobject;var sw,sh:longint):boolean;
function misokk24(s:tobject):boolean;
function misokai24(s:tobject;var sw,sh:longint):boolean;
function misok824(s:tobject;var sbits,sw,sh:longint):boolean;
function misok82432(s:tobject;var sbits,sw,sh:longint):boolean;
function misokk824(s:tobject):boolean;
function misokk82432(s:tobject):boolean;
function misokai824(s:tobject;var sbits,sw,sh:longint):boolean;
//.lock image
procedure bmplock(x:tobject);
procedure bmpunlock(x:tobject);
function mismustlock(s:tobject):boolean;
function mislock(s:tobject):boolean;
function misunlock(s:tobject):boolean;
function mislocked(s:tobject):boolean;//27jan2021
//.get image information
function misinfo(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo2432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo82432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo8162432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo824(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
//.get image scan rows (all rows = for full height of image)
function misrows8(s:tobject;var xout:pcolorrows8):boolean;
function misrows16(s:tobject;var xout:pcolorrows16):boolean;
function misrows24(s:tobject;var xout:pcolorrows24):boolean;
function misrows32(s:tobject;var xout:pcolorrows32):boolean;
function misrows82432(s:tobject;var xout8:pcolorrows8;var xout24:pcolorrows24;var xout32:pcolorrows32):boolean;//26jan2021
//.get image scan row (just one row)
function misscan82432(s:tobject;sy:longint;var sr8:pcolorrow8;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
function misscan8(s:tobject;sy:longint;var sr8:pcolorrow8):boolean;//26jan2021
function misscan24(s:tobject;sy:longint;var sr24:pcolorrow24):boolean;//26jan2021
function misscan32(s:tobject;sy:longint;var sr32:pcolorrow32):boolean;//26jan2021
function misscan2432(s:tobject;sy:longint;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
function misscan824(s:tobject;sy:longint;var sr8:pcolorrow8;var sr24:pcolorrow24):boolean;//26jan2021
function misscan832(s:tobject;sy:longint;var sr8:pcolorrow8;var sr32:pcolorrow32):boolean;//14feb2022
//.get and set image pixel
function mispixel8VAL(s:tobject;sy,sx:longint):byte;
function mispixel8(s:tobject;sy,sx:longint):tcolor8;
function mispixel24VAL(s:tobject;sy,sx:longint):longint;
function mispixel24(s:tobject;sy,sx:longint):tcolor24;
function mispixel32VAL(s:tobject;sy,sx:longint):longint;
function mispixel32(s:tobject;sy,sx:longint):tcolor32;
function missetpixel32VAL(s:tobject;sy,sx,xval:longint):boolean;
function missetpixel32(s:tobject;sy,sx:longint;xval:tcolor32):boolean;
//.count image colors
function miscountcolors(i:tobject):longint;//full color count - uses dynamic memory (2mb) - 15OCT2009
function miscountcolors2(da_clip:trect;i,xsel:tobject):longint;//full color count - uses dynamic memory (2mb) - 19sep2018, 15OCT2009
function miscountcolors3(da_clip:trect;i,xsel:tobject;var xcolorcount,xmaskcount:longint):boolean;//full color count - uses dynamic memory (2mb) - 19sep2018, 15OCT2009
//.copy an area of pixels from one image to another - full 32bit RGBA support - 15feb2022
function miscopyarea32(ddx,ddy,ddw,ddh:currency;sa:trect;d,s:tobject):boolean;//can copy ALL 32bits of color
function miscopyarea321(da,sa:trect;d,s:tobject):boolean;//can copy ALL 32bits of color
function miscopyarea322(da_clip:trect;ddx,ddy,ddw,ddh:currency;sa:trect;d,s:tobject;xscroll,yscroll:longint):boolean;//can copy ALL 32bits of color
//.transparent color support
function mistranscol(s:tobject;stranscolORstyle:longint;senable:boolean):longint;
function misfindtranscol82432(s:tobject;stranscol:longint):longint;
function misfindtranscol82432ex(s:tobject;stranscol:longint;var tr,tg,tb:longint):boolean;
//.other
function degtorad2(deg:extended):extended;//20OCT2009
function miscurveAirbrush2(var x:array of longint;xcount,valmin,valmax:longint;xflip,yflip:boolean):boolean;//20jan2021, 29jul2016

function miscls(s:tobject;xcolor:longint):boolean;
function misclsarea(s:tobject;sarea:trect;xcolor:longint):boolean;
function misclsarea2(s:tobject;sarea:trect;xcolor,xcolor2:longint):boolean;
function misclsarea3(s:tobject;sarea:trect;xcolor,xcolor2,xalpha,xalpha2:longint):boolean;

function mistodata(s:tobject;ddata:tstr8;dformat:string;var e:string):boolean;//02jun2020
function mistodata2(s:tobject;ddata:tstr8;dformat:string;dtranscol,dfeather,dlessdata:longint;dtransframe:boolean;var e:string):boolean;//04sep2021, 03jun2020
function mistodata3(_s:tobject;ddata:tstr8;dformat:string;dtranscol,dfeather,dlessdata:longint;dtransframe,xuseacopy:boolean;var e:string):boolean;//04sep2021, 03jun2020

//.special
function mis__drawdigits(s:tobject;dcliparea:trect;dx,dy,dfontsize,dcolor:longint;x:string;xbold,xdraw:boolean;var dwidth,dheight:longint):boolean;
function mis__drawdigits2(s:tobject;dcliparea:trect;dx,dy,dfontsize,dcolor:longint;dheightscale:extended;x:string;xbold,xdraw:boolean;var dwidth,dheight:longint):boolean;

//png procs --------------------------------------------------------------------
procedure low__PNGfilter_textlatin1(x:tstr8);//21jan2021
function low__PNGfilter_nullsplit(xdata:tstr8;xfilterlatin1:boolean;xname,xval:tstr8):boolean;
function low__PNGfilter_fromsettings(xdata:tstr8;var stranscol,sfeather,slessdata:longint;var shadsettings:boolean):boolean;
function mistopng82432(x:tobject;stranscol,sfeather,slessdata:longint;stransframe:boolean;xdata:tstr8;var e:string):boolean;//20jan2021
function mistopng82432b(x:tobject;stranscol,sfeather,slessdata:longint;stransframe:boolean;var xoutbpp:longint;xdata:tstr8;var e:string):boolean;//OK=27jan2021, 20jan2021
function misfrompng82432(s:tobject;sbackcol:longint;sdata:tstr8;var e:string):boolean;//26jan2021
function misfrompng82432ex(s:tobject;sbackcol:longint;var stranscol,sfeather,slessdata:longint;var shadsettings:boolean;sdata:tstr8;var e:string):boolean;//26jan2021, 21jan2021

//tea procs (text picture) -----------------------------------------------------
function low__teamake(x:tobject;xout:tstr8;var e:string):boolean;
function low__teamake2(x:tobject;xver2,xtransparent,xsyscolors:boolean;xval1,xval2:longint;xout:tstr8;var e:string):boolean;//07apr2021
function low__teainfo(var adata:tlistptr;xsyszoom:boolean;var aw,ah,aSOD,aversion,aval1,aval2:longint;var atransparent,asyscolors:boolean):boolean;
function low__teainfo2(adata:tstr8;xsyszoom:boolean;var aw,ah,aSOD,aversion,aval1,aval2:longint;var atransparent,asyscolors:boolean):boolean;
function low__teadraw(xcolorise,xsyszoom:boolean;dx,dy,dc,dc2:longint;xarea,xarea2:trect;d:tobject;xtea:tlistptr;xfocus,xgrey,xround:boolean;xroundstyle:longint):boolean;//curved corner support - 07may2020, 09apr2020, 29mar2020
function low__teadraw2(xcolorise,xsyszoom:boolean;dx,dy,dc,dc2:longint;xarea,xarea2:trect;dbits,dw,dh:longint;drows24:pcolorrows24;drows32:pcolorrows32;xmask:tmask8;xmaskval:longint;xtea:tlistptr;xfocus,xgrey,xround:boolean;xroundstyle:longint):boolean;//curved corner support - 13may2020, 07may2020, 09apr2020, 29mar2020
function low__teatoraw24(xtea:tlistptr;xdata:tstr8;var xw,xh:longint):boolean;
function low__teaTLpixel(xtea:tlistptr):longint;//top-left pixel of TEA image - 01aug2020
function low__teaTLpixel2(xtea:tlistptr;var xw,xh,xcolor:longint):boolean;//top-left pixel of TEA image - 01aug2020
function low__teatoimg(xtea:tlistptr;d:tbasicimage;var xw,xh:longint):boolean;//23may2020
function low__teatobmp(sdata:tstr8;d:tbmp;var xw,xh:longint):boolean;//12apr2021, 21aug2020

//gif procs --------------------------------------------------------------------
//compiler tag: "gif" check with need_gif
//cost: ?
function low__fromgif(x:tbmp;y:tstr8;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
function low__fromgif1(x:tbmp;y:tstr8;xuse32:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
function low__fromgif2(x:tbmp;y:tstr8;var xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;var xtransparent:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
function low__fromgif3(x:tbmp;y:tstr8;var xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;xuse32:boolean;var xtransparent:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
function low__togif(x:tobject;y:tstr8;var e:string):boolean;//11SEP2007
function low__togif2(x:tobject;xtranscol:longint;y:tstr8;var e:string):boolean;//permit transparent color override - 09sep2021, 11SEP2007
function low__togif3(x:tobject;xtranscol:longint;xlocalpalettes,xuse32:boolean;y:tstr8;var e:string):boolean;//31dec2022 - fixed bad [0,59] terminator, 14may2022 - now supports 32bit mask channel for transparency, 22sep2021 (now supports localpalettes - each cell of an animation has it's own separate color palette), 11SEP2007
//.gif2 support - 31dec2022 - v1.00.130
function gif_start(dcore:tstr8;dw,dh:longint;dloop:boolean;xsmartwrite24:tbasicimage):boolean;
function gif_stop(dcore:tstr8):boolean;
function gif_add(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite:boolean):boolean;
function gif_add2(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite:boolean;xsmartwrite24:tbasicimage):boolean;
function gif_add3(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite,xwritefullframe:boolean;xsmartwrite24:tbasicimage):boolean;

{$ifdef gif}//these procs only enable when GIF is enabled for the program
procedure gif_decompress(x:tstr8);//28jul2021, 11SEP2007
procedure gif_decompressex(var xlenpos1:longint;x,imgdata:tstr8;_width,_height:longint;interlaced:boolean);//11SEP2007
function gif_compress(x:tstr8;var e:string):boolean;//12SEP2007
function gif_compressex(x,imgdata:tstr8;e:string):boolean;//12SEP2007
{$endif}

//mask procs -------------------------------------------------------------------
function mask__empty(s:tobject):boolean;
function mask__transparent(s:tobject):boolean;//replaces "misAlphatransparent832()"
function mask__range(s:tobject;var xmin,xmax:longint):boolean;//15feb2022
function mask__range2(s:tobject;var v0,v255,vother:boolean;var xmin,xmax:longint):boolean;//15feb2022
function mask__maxave(s:tobject):longint;//0..255
function mask__setval(s:tobject;xval:longint):boolean;//replaces "missetAlphaval32()"
function mask__setopacity(s:tobject;xopacity255:longint):boolean;//06jun2021
function mask__multiple(s:tobject;xby:currency):boolean;//18sep2022
function mask__copy(s,d:tobject):boolean;//15feb2022 - was "missetAlpha32(()"
function mask__copy2(s,d:tobject;stranscol:longint):boolean;
function mask__copy3(s,d:tobject;stranscol,sremove:longint):boolean;
function mask__copymin(s,d:tobject):boolean;//15feb2022
function mask__feather(s,d:tobject;sfeather,stranscol:longint;var xouttranscol:longint):boolean;//20jan2021
function mask__feather2(s,d:tobject;sfeather,stranscol:longint;stransframe:boolean;var xouttranscol:longint):boolean;//15feb2022, 18jun2021, 08jun2021, 20jan2021 - was "misalpha82432b()"

//color procs ------------------------------------------------------------------
function low__greyscale2(var x:tcolor24):byte;
function low__rgbint(x:tcolor24):longint;
function low__rgbaint(x:tcolor32):longint;
function low__rgb(r,g,b:byte):longint;
function low__rgb24(r,g,b:byte):tcolor24;
function low__rgb32to24(var x:tcolor32):tcolor24;//21jun2022
function low__rgb24to32(var x:tcolor24;xa:byte):tcolor32;//21jun2022
function low__rgba(r,g,b,a:byte):longint;
function low__rgba32(r,g,b,a:byte):tcolor32;//25nov2023
function ppBlend32(var s,snew:tcolor32):boolean;//color / pixel processor - 30nov2023
function ppBlendColor32(var s,snew:tcolor32):boolean;//color blending / pixel processor - 01dec2023
function low__colbright(x:longint):longint;
function low__colsplice(x,c1,c2:longint):longint;
function low__colsplice1(xpert:extended;s,d:longint):longint;//13nov2022
function low__rgbsplice24(xpert:extended;s,d:tcolor24):tcolor24;//17may2022
function low__rgbsplice32(xpert:extended;s,d:tcolor32):tcolor32;//06dec2023
function low__sc(sc,dc,pert:longint):longint;//shift color
function low__sc1(xpert:extended;sc,dc:longint):longint;//shift color
function low__dc(x,y:longint):longint;//differential color
function low__cv(col,bgcolor,by:longint):boolean;//color visible
function low__ecv(col,bgcolor,by:longint):longint;//ensure color visible
function low__brightness(x:longint;var xout:longint):boolean;
function low__brightnessb(x:longint):longint;
function low__brightness2(x:longint;var xout:longint):boolean;
function low__brightness2b(x:longint):longint;
function low__invert(x:longint;var xout:longint):boolean;
function low__invert2(x:longint;xgreycorrection:boolean;var xout:longint):boolean;
function low__invertb(x:longint):longint;
function low__invert2b(x:longint;xgreycorrection:boolean):longint;
function low__intrgb(x:longint):tcolor24;
function low__intrgb32(x:longint;aval:byte):tcolor32;
function low__intrgba32(x:longint):tcolor32;
function low__compare24(s,d:tcolor24):boolean;
function low__compare32(s,d:tcolor32):boolean;


//logic procs ------------------------------------------------------------------
function low__aorbimg(a,b:tbasicimage;xuseb:boolean):tbasicimage;//30nov2023

implementation


//start-stop procs -------------------------------------------------------------
procedure gossimg__start;
var
   p:longint;
begin
try
//check
if system_started then exit else system_started:=true;

//temp support -----------------------------------------------------------------
//.temp buffer support
systmppos:=0;
for p:=0 to high(systmpstyle) do
begin
systmpstyle[p]:=0;//free
systmpid[p]:='';
systmptime[p]:=0;
systmpbmp[p]:=nil;
end;//p
//.temp int buffer support
sysintpos:=0;
for p:=0 to high(sysintstyle) do
begin
sysintstyle[p]:=0;//free
sysintid[p]:='';
sysinttime[p]:=0;
sysintobj[p]:=nil;
end;//p
//.temp byte buffer support
sysbytepos:=0;
for p:=0 to high(sysbytestyle) do
begin
sysbytestyle[p]:=0;//free
sysbyteid[p]:='';
sysbytetime[p]:=0;
sysbyteobj[p]:=nil;
end;//p

except;end;
end;

procedure gossimg__stop;
var
   p:longint;
begin
try
//check
if not system_started then exit else system_started:=false;

//temp support -----------------------------------------------------------------
//.temp buffer support
for p:=0 to high(systmpstyle) do
begin
systmpstyle[p]:=2;//locked
freeobj(@systmpbmp[p]);
end;//p
//.temp int support
for p:=0 to high(sysintstyle) do
begin
sysintstyle[p]:=2;//locked
freeobj(@sysintobj[p]);
end;//p
//.temp byte support
for p:=0 to high(sysbytestyle) do
begin
sysbytestyle[p]:=2;//locked
freeobj(@sysbyteobj[p]);
end;//p

except;end;
end;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__img(xname:string):string;//information specific to this unit of code
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//check -> xname must be "gossimg.*"
if (strcopy1(xname,1,8)='gossimg.') then strdel1(xname,1,8) else exit;

//get
if      (xname='ver')        then result:='4.00.10257'
else if (xname='date')       then result:='17apr2024'
else if (xname='name')       then result:='Graphics'
else
   begin
   //nil
   end;

except;end;
end;

//general procs ----------------------------------------------------------------
//## zzimg ##
function zzimg(x:tobject):boolean;//12feb2202
begin
result:=(x<>nil) and (x is tbasicimage);
end;
//## asimg ##
function asimg(x:tobject):tbasicimage;//12feb2202
begin
result:=nil;
if (x<>nil) and (x is tbasicimage) then result:=x as tbasicimage;
end;

//## tbasicimage ###############################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//ggggggggggggggggggggggggggggg
//## create ##
constructor tbasicimage.create;//01NOV2011
begin
track__inc(satBasicimage,1);
inherited create;
//options
misaiclear(ai);
dtransparent:=true;
omovie:=false;
oaddress:='';
ocleanmask32bpp:=false;
rhavemovie:=false;
//vars
istable:=false;
idata:=str__new8;
irows:=str__new8;
ibits:=0;
iwidth:=0;
iheight:=0;
iprows8 :=nil;
iprows16:=nil;
iprows24:=nil;
iprows32:=nil;
//defaults
setparams(8,1,1);
//enable
istable:=true;
end;
//## destroy ##
destructor tbasicimage.destroy;//28NOV2010
begin
try
//disable
istable:=false;
//controls
iprows8 :=nil;
iprows16:=nil;
iprows24:=nil;
iprows32:=nil;
freeobj(@irows);
freeobj(@idata);
//destroy
inherited destroy;
track__inc(satBasicimage,-1);
except;end;
end;
//## copyfrom ##
function tbasicimage.copyfrom(s:tbasicimage):boolean;//09may2022, 09feb2022
label
   skipend;
begin
//defaults
result:=false;
try
//check
if (s=self) then
   begin
   result:=true;
   exit;
   end;
if (s=nil) then exit;
//get
//was: if not low__aicopy(ai,s.ai) then goto skipend;
if not low__aicopy(s.ai,ai) then goto skipend;//09may2022
dtransparent:=s.dtransparent;
omovie:=s.omovie;
oaddress:=s.oaddress;
ocleanmask32bpp:=s.ocleanmask32bpp;
rhavemovie:=s.rhavemovie;
setraw(misb(s),misw(s),mish(s),s.data);
//successful
result:=true;
skipend:
except;end;
end;
//## todata ##
function tbasicimage.todata:tstr8;//19feb2022
label
   skipend;
var
   xresult:boolean;
   v8:tvars8;
   tmp:tstr8;//pointer only
begin
result:=nil;
xresult:=false;
try
//defaults
result:=str__new8;
v8:=nil;
//info
v8:=vnew;
if (ai.format<>'')        then v8.s['f']:=ai.format;
if (ai.subformat<>'')     then v8.s['s']:=ai.subformat;
if (ai.info<>'')          then v8.s['i']:=ai.info;
if (ai.map16<>'')         then v8.s['m']:=ai.map16;
if ai.transparent         then v8.b['t']:=ai.transparent;
if ai.syscolors           then v8.b['sc']:=ai.syscolors;
if ai.flip                then v8.b['fp']:=ai.flip;
if ai.mirror              then v8.b['mr']:=ai.mirror;
if (ai.delay<>0)          then v8.i['d']:=ai.delay;
if (ai.itemindex<>0)      then v8.i['i']:=ai.itemindex;
if (ai.count<>0)          then v8.i['c']:=ai.count;
if (ai.bpp<>0)            then v8.i['bp']:=ai.bpp;
if ai.binary              then v8.b['bin']:=ai.binary;
if (ai.hotspotX<>0)       then v8.i['hx']:=ai.hotspotX;
if (ai.hotspotY<>0)       then v8.i['hy']:=ai.hotspotY;
if ai.hotspotMANUAL       then v8.b['hm']:=ai.hotspotMANUAL;
if ai.owrite32bpp         then v8.b['w32']:=ai.owrite32bpp;
if ai.readB64             then v8.b['r64']:=ai.readB64;
if ai.readB128            then v8.b['r128']:=ai.readB128;
if ai.writeB64            then v8.b['w64']:=ai.writeB64;
if ai.writeB128           then v8.b['w128']:=ai.writeB128;
if (ai.iosplit<>0)        then v8.i['ios']:=ai.iosplit;
if (ai.cellwidth<>0)      then v8.i['cw']:=ai.cellwidth;
if (ai.cellheight<>0)     then v8.i['ch']:=ai.cellheight;
if ai.use32               then v8.b['u32']:=ai.use32;//22may2022
if dtransparent           then v8.b['dt']:=dtransparent;
if omovie                 then v8.b['mv']:=omovie;
if (oaddress<>'')         then v8.s['ad']:=oaddress;
if ocleanmask32bpp        then v8.b['c32']:=ocleanmask32bpp;
if rhavemovie             then v8.b['hmv']:=rhavemovie;
//.info
tmp:=v8.data;
result.addint4(0);
result.addint4(tmp.len);
result.add(tmp);
//.pixels
result.addint4(1);
result.addint4(12+idata.len);
result.addint4(bits);
result.addint4(width);
result.addint4(height);
result.add(idata);
//.finished
result.addint4(max32);
//successful
xresult:=true;
skipend:
except;end;
try
result.oautofree:=true;
if (not xresult) and (result<>nil) then result.clear;
freeobj(@v8);
except;end;
end;
//## fromdata ##
function tbasicimage.fromdata(s:tstr8):boolean;//19feb2022
label
   redo,skipend;
var
   v8:tvars8;
   abits,xid,xpos,xlen:longint;
   xdata:tstr8;
   //## xpull ##
   function xpull:boolean;
   label
      skipend;
   var
      b,w,h,slen:longint;
   begin
   //defaults
   result:=false;
   try
   //clear
   xdata.clear;
   //id
   if ((xpos+3)>=xlen) then goto skipend;
   xid:=s.int4[xpos];
   inc(xpos,4);
   //eof
   if (xid=max32) then
      begin
      result:=true;
      goto skipend;
      end;
   //slen
   if ((xpos+3)>=xlen) then goto skipend;
   slen:=s.int4[xpos];
   inc(xpos,4);
   //check
   if ((xpos+slen-1)>=xlen) then goto skipend;
   //data
   if not xdata.add3(s,xpos,slen) then goto skipend;
   inc(xpos,slen);
   //set
   case xid of
   0:v8.data:=xdata;
   1:begin
      b:=xdata.int4[0];//0..3
      w:=xdata.int4[4];//4..7
      h:=xdata.int4[8];//8..11
      if (b<0) or (w<=0) or (h<=0) then goto skipend;
      if not xdata.del3(0,12) then goto skipend;
      if not setraw(b,w,h,xdata) then goto skipend;
      end;
   else goto skipend;//error
   end;
   //successfsul
   result:=true;
   skipend:
   except;end;
   end;
begin
//defaults
result:=false;
abits:=bits;
try
v8:=nil;
xdata:=nil;
//check
if not str__lock(@s) then exit;
//init
xlen:=s.len;
xpos:=0;
v8:=vnew;
xdata:=str__new8;
//get
redo:
if not xpull then goto skipend;
if (xid<>max32) then goto redo;

//info
ai.format            :=v8.s['f'];
ai.subformat         :=v8.s['s'];
ai.info              :=v8.s['i'];
ai.map16             :=v8.s['m'];
ai.transparent       :=v8.b['t'];
ai.syscolors         :=v8.b['sc'];
ai.flip              :=v8.b['fp'];
ai.mirror            :=v8.b['mr'];
ai.delay             :=v8.i['d'];
ai.itemindex         :=v8.i['i'];
ai.count             :=v8.i['c'];
ai.bpp               :=v8.i['bp'];
ai.binary            :=v8.b['bin'];
ai.hotspotX          :=v8.i['hx'];
ai.hotspotY          :=v8.i['hy'];
ai.hotspotMANUAL     :=v8.b['hm'];
ai.owrite32bpp       :=v8.b['w32'];
ai.use32             :=v8.b['u32'];//22may2022
ai.readB64           :=v8.b['r64'];
ai.readB128          :=v8.b['r128'];
ai.writeB64          :=v8.b['w64'];
ai.writeB128         :=v8.b['w128'];
ai.iosplit           :=v8.i['ios'];
ai.cellwidth         :=v8.i['cw'];
ai.cellheight        :=v8.i['ch'];
dtransparent         :=v8.b['dt'];
omovie               :=v8.b['mv'];
oaddress             :=v8.s['ad'];
ocleanmask32bpp      :=v8.b['c32'];
rhavemovie           :=v8.b['hmv'];

//successful
result:=true;
skipend:
except;end;
try
freeobj(@v8);
str__free(@xdata);
str__uaf(@s);
//error
if not result then setparams(abits,1,1);
except;end;
end;
//## sizeto ##
function tbasicimage.sizeto(dw,dh:longint):boolean;
begin
result:=setparams(ibits,dw,dh);
end;
//## setparams ##
function tbasicimage.setparams(dbits,dw,dh:longint):boolean;
var
   dy,dlen:longint;
begin
//defaults
result:=false;
try
//range
if (dbits<>8) and (dbits<>16) and (dbits<>24) and (dbits<>32) then dbits:=24;
if (dw<1) then dw:=1;
if (dh<1) then dh:=1;
//check
if (dbits=ibits) and (dw=iwidth) and (dh=iheight) then
   begin
   result:=true;
   exit;
   end;
//get
dlen:=(dbits div 8)*dw*dh;
if idata.setlen(dlen) then
   begin
   //init
   ibits:=dbits;
   iwidth:=dw;
   iheight:=dh;
   irows.setlen(dh*sizeof(pointer));
   iprows8 :=irows.prows8;
   iprows16:=irows.prows16;
   iprows24:=irows.prows24;
   iprows32:=irows.prows32;
   //get
   for dy:=0 to (dh-1) do
   begin
   case dbits of
   8 :iprows8[dy] :=pointer(cardinal(idata.core)+(dy*dw));  //not 64bit safe -> cardinal only 0..2.1Gb
   16:iprows16[dy]:=pointer(cardinal(idata.core)+(dy*dw*2));
   24:iprows24[dy]:=pointer(cardinal(idata.core)+(dy*dw*3));
   32:iprows32[dy]:=pointer(cardinal(idata.core)+(dy*dw*4));
   end;
   end;//dy
   //successful
   result:=true;
   end;
except;end;
end;
//## setraw ##
function tbasicimage.setraw(dbits,dw,dh:longint;ddata:tstr8):boolean;
var
   p,xlen:longint;
   v:byte;
begin
//defaults
result:=false;
try
//size
setparams(dbits,dw,dh);
//lock
if not str__lock(@ddata) then exit;
//get
if (ddata<>nil) and (idata<>nil) then
   begin
   xlen:=frcmax32(idata.len,ddata.len);
   if (xlen>=1) then
      begin
      //was: for p:=0 to (xlen-1) do idata.pbytes[p]:=ddata.pbytes[p];
      //faster - 22apr2022
      for p:=0 to (xlen-1) do
      begin
      v:=ddata.pbytes[p];
      idata.pbytes[p]:=v;
      end;//p
      end;
   end;
result:=true;//19feb2022
except;end;
try;str__uaf(@ddata);except;end;
end;
//## getareadata ##
function tbasicimage.getareadata(sa:trect):tstr8;
begin
result:=nil;
try
result:=str__newaf8;
str__lock(@result);
getarea(result,sa);
str__unlock(@result);
except;end;
end;
//## setareadata ##
procedure tbasicimage.setareadata(sa:trect;sdata:tstr8);
begin
try;setarea(sdata,sa);except;end;
end;
//## getarea ##
function tbasicimage.getarea(ddata:tstr8;da:trect):boolean;//07dec2023
label
   skipend;
var
   a:tbasicimage;
begin
//defaults
result:=false;
try
a:=nil;
//lock
if not str__lock(@ddata) then exit;
ddata.clear;
//check
if not validarea(da) then goto skipend;
//get
a:=misimg(bits,da.right-da.left+1,da.bottom-da.top+1);//image of same bit depth as ourselves
result:=miscopyarea32(0,0,misw(a),mish(a),da,a,self) and ddata.addb(a.data);//copy area to this image and then return it's raw datastream - 07dec2023
skipend:
except;end;
try
str__uaf(@ddata);
freeobj(@a);
except;end;
end;
//## getareadata ##
function tbasicimage.getareadata2(sa:trect):tstr8;
begin
result:=nil;
try
result:=str__newaf8;
str__lock(@result);
getarea_fast(result,sa);
str__unlock(@result);
except;end;
end;
//## getarea_fast ##
function tbasicimage.getarea_fast(ddata:tstr8;da:trect):boolean;//07dec2023
label
   skipend;
var
   sstart,srowsize,drowsize,sw,sh,dy,dw,dh:longint;
begin
//defaults
result:=false;
try
//lock
if not str__lock(@ddata) then exit;
//ddata.clear;
//check
if not validarea(da) then goto skipend;
//range
sw:=width;
sh:=height;
da.left:=frcrange32(da.left,0,sw-1);
da.right:=frcrange32(da.right,da.left,sw-1);
da.top:=frcrange32(da.top,0,sh-1);
da.bottom:=frcrange32(da.bottom,da.top,sh-1);
dw:=da.right-da.left+1;
dh:=da.bottom-da.top+1;
sstart:=(bits div 8)*da.left;
srowsize:=(bits div 8)*sw;
drowsize:=(bits div 8)*dw;
//.size - presize for maximum speed
//ddata.minlen(dh*drowsize);
//ddata.count:=0;

if (ddata.len<>(dh*drowsize)) then ddata.setlen(dh*drowsize);
ddata.setcount(0);



//get
for dy:=da.top to da.bottom do
begin
if not ddata.add3(idata,(dy*srowsize)+sstart,drowsize) then goto skipend;
end;

//successful
result:=true;
skipend:
except;end;
try
if not result then ddata.clear;
str__uaf(@ddata);
except;end;
end;
//## setarea ##
function tbasicimage.setarea(ddata:tstr8;da:trect):boolean;//07dec2023
label
   skipend;
var
   a:tbasicimage;
begin
//defaults
result:=false;
try
a:=nil;
//lock
if not str__lock(@ddata) then exit;
//check
if (da.left>=width) or (da.right<0) or (da.top>=height) or (da.bottom<0) or (da.right<da.left) or (da.bottom<da.top) then
   begin
   result:=true;
   goto skipend;
   end;
//init
a:=misimg8(1,1);
//get
result:=a.setraw(bits,da.right-da.left+1,da.bottom-da.top+1,ddata) and miscopyarea32(da.left,da.top,da.right-da.left+1,da.bottom-da.top+1,misarea(a),self,a);
skipend:
except;end;
try
str__uaf(@ddata);
freeobj(@a);
except;end;
end;
//## getscanline ##
function tbasicimage.findscanline(slayer,sy:longint):pointer;
begin
//defaults
result:=nil;
//check
if (iwidth<1) or (iheight<1) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=iheight) then sy:=iheight-1;
//get
result:=pointer(cardinal(idata)+(sy*iwidth*(ibits div 8)));//not 64bit safe
end;

//## tbitmap2 ##################################################################
//## create ##
constructor tbitmap2.create;
begin
track__inc(satBitmap,1);
inherited create;
//vars
icore:=tdynamicstr8.create;
irows:=str__new8;
ifallback:=str__new8;
ibits:=0;
iwidth:=0;
iheight:=0;
ilockcount:=0;
//defaults
setparams(32,1,1);
end;
//## destroy ##
destructor tbitmap2.destroy;
begin
try
//vars
str__free(@ifallback);
str__free(@irows);
freeobj(@icore);
//self
inherited destroy;
track__inc(satBitmap,-1);
except;end;
end;
//## assign ##
function tbitmap2.assign(x:tobject):boolean;
label
   skipend;
var
   sy:longint;
begin
//defaults
result:=false;
try
//check
if (x=nil) then exit;
//self check
if (x=self) then
   begin
   result:=true;
   exit;
   end;
//get
if (x is tbitmap2) then
   begin
   //wipe memory
   setparams(8,1,1);
   //set
   if not setparams((x as tbitmap2).bits,(x as tbitmap2).width,(x as tbitmap2).height) then goto skipend;
   //copy
   for sy:=0 to (iheight-1) do
   begin
   icore.value[sy].clear;
   if not icore.value[sy].add((x as tbitmap2).core.items[sy]) then goto skipend;
   end;//sy
   end;
//successful
result:=true;
skipend:
except;end;
end;
//## setbits ##
procedure tbitmap2.setbits(x:longint);
begin
try;setparams(x,iwidth,iheight);except;end;
end;
//## setwidth ##
procedure tbitmap2.setwidth(x:longint);
begin
try;setparams(ibits,x,iheight);except;end;
end;
//## setheight ##
procedure tbitmap2.setheight(x:longint);
begin
try;setparams(ibits,iwidth,x);except;end;
end;
//## cansetparams ##
function tbitmap2.cansetparams:boolean;
begin
result:=true;
end;
//## setparams ##
function tbitmap2.setparams(dbits,dw,dh:longint):boolean;
var
   s:tstr8;
   dsize,sy:longint;
   //## xchangerow ##
   procedure xchangerow(sy:longint);
   var
      dx,xmax:longint;
      c32:tcolor32;
      c24:tcolor24;
       c8:tcolor8;
   begin
   try
   if (sy>=0) and (sy<iheight) then
      begin
      //init
      if (s=nil) then s:=str__new8;
      xmax:=iwidth-1;
      //copy
      s.add(icore.items[sy]);
      //resize
      icore.value[sy].setlen(iwidth*(dbits div 8));
      //rewrite row
      //.32 -> 24
      if (ibits=32) and (dbits=24) then
         begin
         for dx:=0 to xmax do
         begin
         c32:=s.prows32[sy][dx];
         c24.r:=c32.r;
         c24.g:=c32.g;
         c24.b:=c32.b;
         icore.items[sy].prows24[sy][dx]:=c24;
         end;//dx
         end
      //.32 -> 8
      else if (ibits=32) and (dbits=8) then
         begin
         for dx:=0 to xmax do
         begin
         c32:=s.prows32[sy][dx];
         c8:=c32.r;
         if (c32.g>c8) then c8:=c32.g;
         if (c32.b>c8) then c8:=c32.b;
         icore.items[sy].prows8[sy][dx]:=c8;
         end;//dx
         end
      //.24 -> 32
      else if (ibits=24) and (dbits=32) then
         begin
         for dx:=0 to xmax do
         begin
         c24:=s.prows24[sy][dx];
         c32.r:=c24.r;
         c32.g:=c24.g;
         c32.b:=c24.b;
         c32.a:=255;
         icore.items[sy].prows24[sy][dx]:=c24;
         end;//dx
         end
      //.24 -> 8
      else if (ibits=24) and (dbits=8) then
         begin
         for dx:=0 to xmax do
         begin
         c24:=s.prows24[sy][dx];
         c8:=c24.r;
         if (c24.g>c8) then c8:=c24.g;
         if (c24.b>c8) then c8:=c24.b;
         icore.items[sy].prows8[sy][dx]:=c8;
         end;//dx
         end
      //.8 -> 32
      else if (ibits=8) and (dbits=32) then
         begin
         for dx:=0 to xmax do
         begin
         c8:=s.prows8[sy][dx];
         c32.r:=c8;
         c32.g:=c8;
         c32.b:=c8;
         c32.a:=255;
         icore.items[sy].prows32[sy][dx]:=c32;
         end;//dx
         end
      //.8 -> 24
      else if (ibits=8) and (dbits=24) then
         begin
         for dx:=0 to xmax do
         begin
         c8:=s.prows8[sy][dx];
         c24.r:=c8;
         c24.g:=c8;
         c24.b:=c8;
         icore.items[sy].prows24[sy][dx]:=c24;
         end;//dx
         end;
      end;
   except;end;
   end;
begin
//defaults
result:=false;
try
s:=nil;
//check
if not cansetparams then exit;
//range
if (dbits<>8) and (dbits<>24) and (dbits<>32) then dbits:=32;
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
//get
if (dbits<>ibits) or (dw<>iwidth) or (dh<>iheight) then
   begin
   //ifallback
   ifallback.setlen(dw*(dbits div 8));

   //bits
   if (dbits<>ibits) then
      begin
      for sy:=0 to (iheight-1) do xchangerow(sy);
      ibits:=dbits;
      end;

   //width
   if (iwidth<>dw) then
      begin
      dsize:=dw*(dbits div 8);
      for sy:=0 to (iheight-1) do icore.value[sy].setlen(dsize);
      iwidth:=dw;
      end;

   //height
   if (iheight<>dh) then
      begin
      //.make more rows
      if (dh>iheight) then
         begin
         dsize:=iwidth*(ibits div 8);
         for sy:=(iheight-1) to (dh-1) do
         begin
         icore.value[sy]:=nil;//create the row
         icore.value[sy].setlen(dsize);//size the row
         end;//sy
         iheight:=dh;
         end;
      end;

   //successful
   result:=true;
   end
else result:=true;
except;end;
end;
//## getscanline ##
function tbitmap2.getscanline(sy:longint):pointer;
begin
//defaults
result:=ifallback;
//check
if (iwidth<1) or (iheight<1) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=iheight) then sy:=iheight-1;
//get
result:=pointer(icore.items[sy]);
end;
//## cancanvas ##
function tbitmap2.cancanvas:boolean;
begin
result:=false;
end;
//## canvas ##
function tbitmap2.canvas:tobject;
begin
result:=nil;
end;
//## canrows ##
function tbitmap2.canrows:boolean;
begin
result:=locked;
end;
//## locked ##
function tbitmap2.locked:boolean;
begin
result:=(ilockcount>=1);
end;
//## lock ##
function tbitmap2.lock:boolean;
label
   skipend;
var
   dy:longint;
begin
//defaults
result:=false;
try
//check
inc(ilockcount);
if (ilockcount<>1) then exit;
//init
irows.setlen(iheight*sizeof(tpointer));
irows8 :=irows.core;
irows15:=irows.core;
irows16:=irows.core;
irows24:=irows.core;
irows32:=irows.core;

//get rows ---------------------------------------------------------------------
case ibits of
8 :for dy:=0 to (iheight-1) do irows8[dy] :=scanline[dy];
24:for dy:=0 to (iheight-1) do irows24[dy]:=scanline[dy];
32:for dy:=0 to (iheight-1) do irows32[dy]:=scanline[dy];
end;

//successful
result:=true;
skipend:
except;end;
end;
//## unlock ##
function tbitmap2.unlock:boolean;
begin
result:=true;
ilockcount:=frcmin32(ilockcount-1,0);
end;

//## tbmp ######################################################################
//## create ##
constructor tbmp.create;
begin
track__inc(satBmp,1);
inherited create;
//options
misaiclear(ai);
dtransparent:=true;
omovie:=false;
oaddress:='';
ocleanmask32bpp:=false;
rhavemovie:=false;
//vars
ilockptr:=nil;
ibits:=0;
iwidth:=0;
iheight:=0;
ilockcount:=0;
iunlocking:=false;
isharp:=0;//0=off, 1=monochrome, 8=greyscale
{$ifdef d3laz}
isharphfont:=0;
{$endif}
icore  :=createbitmap;
irows  :=str__new8;
irows8 :=nil;
irows15:=nil;
irows16:=nil;
irows24:=nil;
irows32:=nil;
//defaults
setparams(32,1,1);
end;
//## destroy ##
destructor tbmp.destroy;
begin
try
//release
unlock;
sharp:=0;
//vars
irows8 :=nil;
irows15:=nil;
irows16:=nil;
irows24:=nil;
irows32:=nil;
freeobj(@icore);
str__free(@irows);
//self
inherited destroy;
track__inc(satBmp,-1);
except;end;
end;
//## setbits ##
procedure tbmp.setbits(x:longint);
begin
try;setparams(x,iwidth,iheight);except;end;
end;
//## setwidth ##
procedure tbmp.setwidth(x:longint);
begin
try;setparams(ibits,x,iheight);except;end;
end;
//## setheight ##
procedure tbmp.setheight(x:longint);
begin
try;setparams(ibits,iwidth,x);except;end;
end;
//## cansetparams ##
function tbmp.cansetparams:boolean;
begin
result:=(not locked) and (isharp=0);
end;
//## setparams ##
function tbmp.setparams(dbits,dw,dh:longint):boolean;
begin
//defaults
result:=false;
try
//check
if not cansetparams then exit;
//range
if (dbits<>1) and (dbits<>8) and (dbits<>15) and (dbits<>16) and (dbits<>24) and (dbits<>32) then dbits:=32;
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
//get
if (dbits<>ibits) or (dw<>iwidth) or (dh<>iheight) then
   begin
   //bits
   icore.bits:=dbits;
   //width
   if (icore.width<>dw) then icore.width:=dw;
   //height
   if (icore.height<>dh) then icore.height:=dh;
   //sync
   xinfo;
   //successful
   result:=true;
   end
else result:=true;
except;end;
end;
//## xinfo ##
procedure tbmp.xinfo;
var
   int1:longint;
begin
try
int1:=misb(icore);
if (int1>=1) then ibits:=int1
else
   begin
   missetb(icore,ibits);//fixed - 07apr2021
   //Critical Note: 32bit image loses it's bits setting when "assigned/pasted" to our icore (bitmap)
   //               so must restore bit value and check mask for 32bit images is valid because
   //               24bit images pasted into a 32bit image have an empty mask (all zeros)
   //               when this is the case change all the zeros to 255's - 18jun2021
   if (ibits=32) and mask__empty(icore) then mask__setval(icore,255);//build a "solid" alpha mask - 18jun2021
   end;
iwidth:=misw(icore);
iheight:=mish(icore);
except;end;
end;
//## cancanvas ##
function tbmp.cancanvas:boolean;
begin
result:=true;
end;
//## getcanvas ##
function tbmp.getcanvas:tobject;
begin
result:=nil;try;result:=icore.canvas;except;end;
end;
//## canassign ##
function tbmp.canassign:boolean;
begin
result:=(not locked) and (isharp=0);
end;
//## assign ##
function tbmp.assign(x:tobject):boolean;
begin
//defaults
result:=false;
try
//check
if (not canassign) or zznil(x,7402) then exit;//04may2021
//get
if (x is tbitmap2) then
   begin
   icore.assign(x as tbitmap2);
   xinfo;
   result:=true;//27apr2021
   end;
{$ifdef jpeg}
if (x is tjpegimage) then
   begin
   icore.assign(x as tjpegimage);
   xinfo;
   result:=true;//27apr2021
   end;
{$endif}
except;end;
end;
//## canrows ##
function tbmp.canrows:boolean;
begin
result:=locked;
end;
//## locked ##
function tbmp.locked:boolean;
begin
result:=(ilockcount>=1);
end;
//## lock ##
function tbmp.lock:boolean;
label
   skipend;
var
{$ifdef D10}
   a:tbitmapdata;
{$endif}
   dy:longint;
begin
//defaults
result:=false;
try
//check
inc(ilockcount);
if (ilockcount<>1) then exit;
//init
irows.setlen(iheight*sizeof(tpointer));
irows8 :=irows.core;
irows15:=irows.core;
irows16:=irows.core;
irows24:=irows.core;
irows32:=irows.core;

//get rows ---------------------------------------------------------------------

{$ifdef d3laz}
ilockptr:=nil;//not used for Win32
case ibits of
1 :for dy:=0 to (iheight-1) do irows8[dy] :=icore.scanline[dy];//05feb2022
8 :for dy:=0 to (iheight-1) do irows8[dy] :=icore.scanline[dy];
15:for dy:=0 to (iheight-1) do irows15[dy]:=icore.scanline[dy];
16:for dy:=0 to (iheight-1) do irows16[dy]:=icore.scanline[dy];
24:for dy:=0 to (iheight-1) do irows24[dy]:=icore.scanline[dy];
32:for dy:=0 to (iheight-1) do irows32[dy]:=icore.scanline[dy];
end;
{$endif}

{$ifdef D10}
//lock
if not icore.map(tmapaccess.write,a) then
   begin
   ilocked:=false;//cancel lock
   goto skipend;
   end;
//info
ilockptr:=@a;//retain this object
case ibits of
1 :for dy:=0 to (iheight-1) do irows8[dy] :=a.getscanline(dy);//05feb2022
8 :for dy:=0 to (iheight-1) do irows8[dy] :=a.getscanline(dy);
15:for dy:=0 to (iheight-1) do irows15[dy]:=a.getscanline(dy);
16:for dy:=0 to (iheight-1) do irows16[dy]:=a.getscanline(dy);
24:for dy:=0 to (iheight-1) do irows24[dy]:=a.getscanline(dy);
32:for dy:=0 to (iheight-1) do irows32[dy]:=a.getscanline(dy);
end;
{$endif}

//successful
result:=true;
skipend:
except;end;
end;
//## unlock ##
function tbmp.unlock:boolean;
begin
//defaults
result:=false;
try
//check
if iunlocking or (ilockcount<=0) then exit else iunlocking:=true;

{$ifdef D10}
if (ilockptr<>nil) then
   begin
   icore.unmap(tbitmapdata(ilockptr^));
   ilockptr:=nil;
   end;
{$endif}

//successful
result:=true;
except;end;
try
xinfo;//25jna2021
iunlocking:=false;
ilockcount:=frcmin32(ilockcount-1,0);
except;end;
end;
//## cansharp ##
function tbmp.cansharp:boolean;
begin
result:=(not locked);
end;
//## setsharp ##
procedure tbmp.setsharp(x:longint);
label
   dosharp,donormal,done;
{
var
   xlf:tlogfont;
   v,xf1,xf2:hfont;

//  DEFAULT_QUALITY = 0;
//  DRAFT_QUALITY = 1;
//  PROOF_QUALITY = 2;
//  NONANTIALIASED_QUALITY = 3;
//  ANTIALIASED_QUALITY = 4;
}
begin
try
//filter
case x of
min32..0:x:=0;//off
1..7     :x:=1;//monchrome
8..max32:x:=8;//greyscale
end;//case
//check
if (not cansharp) or (x=isharp) then exit;
//get
isharp:=x;
if (x=0) then goto donormal else goto dosharp;
//sharp ------------------------------------------------------------------------
dosharp:
{
//Note: Any change in width and/or height will cause font to be reset
win____getobject(icore.canvas.font.handle,sizeof(xlf),@xlf);
xlf.lfQuality:=low__aorb(NONANTIALIASED_QUALITY,4,x=8);//was: DEFAULT_QUALITY;
xf1:=win____createfontindirect(xlf);
xf2:=win____selectobject(icore.canvas.handle,xf1);
isharphfont:=xf1;
}
goto done;


//normal -----------------------------------------------------------------------
donormal:
{
//reinstate previous font -> keep Delphi happy - 04apr2020
if (isharphfont<>0) then
   begin
   v:=win____selectobject(icore.canvas.handle,isharphfont);
   win____deleteobject(v);
   isharphfont:=0;
   end;
}

goto done;

//done -------------------------------------------------------------------------
done:
except;end;
end;

//temp procs -------------------------------------------------------------------
//## createtmp ##
function low__createimg24(var x:tbasicimage;xid:string;var xwascached:boolean):boolean;
var
   i,p:longint;
   _ms64:comp;
   //## _init ##
   function _init(x:longint):tbasicimage;
   begin
   result:=nil;
   try
   systmpstyle[x]:=2;//0=free, 1=available, 2=locked
   systmptime[x]:=add64(ms64,30000);//30s
   systmpid[x]:=xid;
   if zznil(systmpbmp[x],2122) then systmpbmp[x]:=misimg(24,1,1);
   result:=systmpbmp[x];
   except;end;
   end;
begin
//defaults
result:=false;
try
x:=nil;
xwascached:=false;
//find existing
for p:=0 to high(systmpstyle) do if (systmpstyle[p]=1) and (xid=systmpid[p]) then
   begin
   x:=_init(p);
   xwascached:=true;//signal to calling proc the int.list was cacched intact -> allows for optimisation at the calling proc's end - 06sep2017
   break;
   end;
//find new
if zznil(x,2123) then for p:=0 to high(systmpstyle) do if (systmpstyle[p]=0) then
   begin
   x:=_init(p);
   break;
   end;
//find oldest
if zznil(x,2124) then
   begin
   i:=-1;
   _ms64:=0;
   //find
   for p:=0 to high(systmpstyle) do if (systmpstyle[p]=1) and ((systmptime[p]<_ms64) or (_ms64=0)) then
      begin
      i:=p;
      _ms64:=systmptime[p];
      end;//p
   //get
   if (i>=0) then x:=_init(i);
   end;
//successful
result:=(x<>nil);
except;end;
end;
//## low__freeimg ##
procedure low__freeimg(var x:tbasicimage);
var
   p:longint;
begin
try
if zzok(x,7003) then for p:=0 to high(systmpstyle) do if (x=systmpbmp[p]) then
   begin
   if (systmpstyle[p]=2) then//locked
      begin
      systmptime[p]:=add64(ms64,30000);//30s - hold onto this before trying to free it via "checktmp"
      systmpstyle[p]:=1;//unlock -> make this buffer available again
      x:=nil;
      end;
   break;
   end;//p
except;end;
end;
//## checkimg ##
procedure low__checkimg;
begin
try
//init
inc(systmppos);
if (systmppos<0) or (systmppos>high(systmpstyle)) then systmppos:=0;
//shrink buffer
if (systmpstyle[systmppos]=1) and (ms64>=systmptime[systmppos]) and zzok(systmpbmp[systmppos],7005) and ((systmpbmp[systmppos].width>1) or (systmpbmp[systmppos].height>1)) then
   begin
   systmpstyle[systmppos]:=2;//lock
   try
   systmpid[systmppos]:='';//clear id - 06sep2017
   if (systmpbmp[systmppos].width>1) or (systmpbmp[systmppos].height>1) then systmpbmp[systmppos].sizeto(1,1);//23may2020
   except;end;
   systmpstyle[systmppos]:=1;//unlock
   end;
except;end;
end;
//## createint ##
function low__createint(var x:tdynamicinteger;xid:string;var xwascached:boolean):boolean;
var
   _ms64:comp;
   i,p:longint;
   //## _init ##
   function _init(x:longint):tdynamicinteger;
   begin
   result:=nil;
   try
   sysintstyle[x]:=2;//0=free, 1=available, 2=locked
   sysinttime[x]:=add64(ms64,30000);//30s
   sysintid[x]:=xid;//set the id (duplicate id's are allowed)
   if zznil(sysintobj[x],2125) then sysintobj[x]:=tdynamicinteger.create;
   result:=sysintobj[x];
   except;end;
   end;
begin
//defaults
result:=false;
try
xwascached:=false;
x:=nil;
//find existing
for p:=0 to high(sysintstyle) do if (sysintstyle[p]=1) and (xid=sysintid[p]) then
   begin
   x:=_init(p);
   xwascached:=true;//signal to calling proc the int.list was cacched intact -> allows for optimisation at the calling proc's end - 06sep2017
   break;
   end;
//find new
if zznil(x,2126) then for p:=0 to high(sysintstyle) do if (sysintstyle[p]=0) then
   begin
   x:=_init(p);
   break;
   end;
//find oldest
if zznil(x,2127) then
   begin
   i:=-1;
   _ms64:=0;
   //find
   for p:=0 to high(sysintstyle) do if (sysintstyle[p]=1) and ((sysinttime[p]<_ms64) or (_ms64=0)) then
      begin
      i:=p;
      _ms64:=sysinttime[p];
      end;//p
   //get
   if (i>=0) then x:=_init(i);
   end;
//successful
result:=(x<>nil);
except;end;
end;
//## freeint ##
procedure low__freeint(var x:tdynamicinteger);
var
   p:longint;
begin
try
if (x<>nil) then for p:=0 to high(sysintstyle) do if (x=sysintobj[p]) then
   begin
   if (sysintstyle[p]=2) then//locked
      begin
      sysinttime[p]:=add64(ms64,30000);//30s - hold onto this before trying to free it via "checktmp"
      sysintstyle[p]:=1;//unlock -> make this buffer available again
      x:=nil;
      end;
   break;
   end;//p
except;end;
end;
//## checkint ##
procedure low__checkint;
begin
try
//init
inc(sysintpos);
if (sysintpos<0) or (sysintpos>high(sysintstyle)) then sysintpos:=0;
//shrink buffer
if (sysintstyle[sysintpos]=1) and (ms64>=sysinttime[sysintpos]) and zzok(sysintobj[sysintpos],7006) and (sysintobj[sysintpos].size>1) then
   begin
   sysintstyle[sysintpos]:=2;//lock
   sysintid[sysintpos]:='';//clear id - 06sep2017
   sysintobj[sysintpos].clear;
   sysintstyle[sysintpos]:=1;//unlock
   end;
except;end;
end;
//## createbyte ##
function low__createbyte(var x:tdynamicbyte;xid:string;var xwascached:boolean):boolean;
var
   _ms64:comp;
   i,p:longint;
   //## _init ##
   function _init(x:longint):tdynamicbyte;
   begin
   result:=nil;
   try
   sysbytestyle[x]:=2;//0=free, 1=available, 2=locked
   sysbytetime[x]:=add64(ms64,30000);//30s
   sysbyteid[x]:=xid;//set the id (duplicate id's are allowed)
   if zznil(sysbyteobj[x],2128) then sysbyteobj[x]:=tdynamicbyte.create;
   result:=sysbyteobj[x];
   except;end;
   end;
begin
//defaults
result:=false;
try
xwascached:=false;
x:=nil;
//find existing
for p:=0 to high(sysbytestyle) do if (sysbytestyle[p]=1) and (xid=sysbyteid[p]) then
   begin
   x:=_init(p);
   xwascached:=true;//signal to calling proc the int.list was cacched intact -> allows for optimisation at the calling proc's end - 06sep2017
   break;
   end;
//find new
if zznil(x,2129) then for p:=0 to high(sysbytestyle) do if (sysbytestyle[p]=0) then
   begin
   x:=_init(p);
   break;
   end;
//find oldest
if zznil(x,2130) then
   begin
   i:=-1;
   _ms64:=0;
   //find
   for p:=0 to high(sysbytestyle) do if (sysbytestyle[p]=1) and ((sysbytetime[p]<_ms64) or (_ms64=0)) then
      begin
      i:=p;
      _ms64:=sysbytetime[p];
      end;//p
   //get
   if (i>=0) then x:=_init(i);
   end;
//successful
result:=(x<>nil);
except;end;
end;
//## freebyte ##
procedure low__freebyte(var x:tdynamicbyte);
var
   p:longint;
begin
try
if (x<>nil) then for p:=0 to high(sysbytestyle) do if (x=sysbyteobj[p]) then
   begin
   if (sysbytestyle[p]=2) then//locked
      begin
      sysbytetime[p]:=add64(ms64,30000);//30s - hold onto this before trying to free it via "checktmp"
      sysbytestyle[p]:=1;//unlock -> make this buffer available again
      x:=nil;
      end;
   break;
   end;//p
except;end;
end;
//## checkbyte ##
procedure low__checkbyte;
begin
try
//init
inc(sysbytepos);
if (sysbytepos<0) or (sysbytepos>high(sysbytestyle)) then sysbytepos:=0;
//shrink buffer
if (sysbytestyle[sysbytepos]=1) and (ms64>=sysbytetime[sysbytepos]) and zzok(sysbyteobj[sysbytepos],7007) and (sysbyteobj[sysbytepos].size>1) then
   begin
   sysbytestyle[sysbytepos]:=2;//lock
   sysbyteid[sysbytepos]:='';//clear id - 06sep2017
   sysbyteobj[sysbytepos].clear;
   sysbytestyle[sysbytepos]:=1;//unlock
   end;
except;end;
end;

//png procs --------------------------------------------------------------------
//## low__PNGfilter_textlatin1 ##
procedure low__PNGfilter_textlatin1(x:tstr8);//OK=27jan2021, 21jan2021
label
   skipend;
var
   v,lv,p,dlen,xlen:longint;
begin
try
//defaults
if not str__lock(@x) then exit;
//init
dlen:=0;
xlen:=x.len;
//check
if (xlen<=0) then goto skipend;
//latin 1 characters only + #10
lv:=-1;
for p:=1 to xlen do
begin
v:=x.pbytes[p-1];
case v of
10,32..126,161..255:if (v<>32) or (lv<>32) then//exclude duplicate spaces - 21jan2021
   begin
   inc(dlen);
   if (dlen<>p) then x.pbytes[dlen-1]:=x.pbytes[p-1];
   end;
end;//case
lv:=v;
end;//p
if (dlen<>xlen) then x.setlen(dlen);
//strip leading spaces
if (dlen>=1) then
   begin
   for p:=1 to dlen do if (x.pbytes[p-1]<>32) then
      begin
      if (p>=2) then
         begin
         //was: delete(x,1,p-1);
         x.del3(0,p-1);
         dlen:=x.len;
         end;
      break;
      end;//p
   end;
//strip trailing spaces
if (dlen>=1) then
   begin
   for p:=dlen downto 1 do if (x.pbytes[p-1]<>32) then//fixed - 27jan2021
      begin
      if (p<dlen) then
         begin
         //was: delete(x,p+1,dlen-p);
         x.del3(p,dlen-p);
         //dlen:=x.len;
         end;
      break;
      end;//p
   end;
skipend:
except;end;
try;str__uaf(@x);except;end;
end;
//## low__PNGfilter_nullsplit ##
function low__PNGfilter_nullsplit(xdata:tstr8;xfilterlatin1:boolean;xname,xval:tstr8):boolean;//OK=27jan2021
label
   skipend;
var
   p:longint;
begin
//defaults
result:=false;
try
//check
str__lock(@xdata);
str__lock(@xname);
str__lock(@xval);
if zznil(xdata,2142) or zznil(xname,2143) or zznil(xval,2144) then goto skipend;
//init
xname.add(xdata);
xval.clear;
//get
for p:=1 to xdata.len do if (xdata.pbytes[p-1]=0) then
   begin
   xname.clear;
   xname.add3(xdata,0,p-1);
   xval.add3(xdata,p,xdata.len);
   //was: xname:=copy(xdata,1,p-1);
   //was: xval:=copy(xdata,p+1,length(xdata));
   break;
   end;//p
//filter
if xfilterlatin1 then
   begin
   low__PNGfilter_textlatin1(xname);
   low__PNGfilter_textlatin1(xval);
   end;
//successful
result:=true;
skipend:
except;end;
try
str__uaf(@xdata);
str__uaf(@xname);
str__uaf(@xval);
except;end;
end;
//## low__PNGfilter_fromsettings ##
function low__PNGfilter_fromsettings(xdata:tstr8;var stranscol,sfeather,slessdata:longint;var shadsettings:boolean):boolean;//OK=27jan2021
label
   skipend;
var
   vc,lp,p:longint;
   v,v1,v2,v3:string;
begin
//defaults
result:=false;
try
shadsettings:=false;
stranscol:=clnone;
sfeather:=-1;//asis
slessdata:=0;
str__lock(@xdata);
//check
if zznil(xdata,2146) or (xdata.len<=0) then goto skipend;
//filter
low__PNGfilter_textlatin1(xdata);
//check #2
if zznil(xdata,2147) or (xdata.len<=0) then goto skipend;
//get
//was: xdata:=xdata+'...';//pad out with 3x terminating dots
xdata.aadd([ssDot,ssDot,ssDot]);
v1:='';
v2:='';
v3:='';
lp:=1;
vc:=0;
for p:=1 to xdata.len do
begin
if (xdata.pbytes[p-1]=ssDot) then
   begin
   //was: v:=copy(xdata,lp,p-lp);
   v:=xdata.str1[lp,p-lp];
   lp:=p+1;
   inc(vc);
   case vc of
   1:v1:=v;
   2:v2:=v;
   3:begin
      v3:=v;
      break;
      end;
   end;//case
   end;//if
end;//p
//set
if (v1<>'') then stranscol:=strint(v1);
if (v2<>'') then sfeather:=frcrange32(strint(v2),-1,100);//-1=asis, 0=none, 1..100=automatic feather size in px - 21jan2021
if (v3<>'') then slessdata:=frcrange32(strint(v3),0,5);//0=none, 1=subtle color reduction..5=heavy color reduction
shadsettings:=(v1<>'') and (v2<>'') and (v3<>'');
//successful
result:=true;
skipend:
except;end;
try;str__uaf(@xdata);except;end;
end;
//## mistopng82432 ##
function mistopng82432(x:tobject;stranscol,sfeather,slessdata:longint;stransframe:boolean;xdata:tstr8;var e:string):boolean;//OK=27jan2021, 20jan2021
var
   xoutbpp:longint;
begin
result:=false;try;result:=mistopng82432b(x,stranscol,sfeather,slessdata,stransframe,xoutbpp,xdata,e);except;end;
end;
//## mistopng82432b ##
function mistopng82432b(x:tobject;stranscol,sfeather,slessdata:longint;stransframe:boolean;var xoutbpp:longint;xdata:tstr8;var e:string):boolean;//OK=27jan2021, 20jan2021
label
   //xtranscol: clNone=solid, clTopLeft=pixel(0,0), clwhite/clblack/clred/cllime/clblue=protected transparent colors, else unprotected user transparent color (note: white, black, red, lime, blue, yellow and grey are retained even with a reducer)
   //xfeather: -1=as is, 0=sharp, 1..100px (with dual mode 3x3 or 5x5 blurring)
   //xlessdata: 0=off, 1=subtle reduction, 2=normal reduction, 3=heavy reduction, 4=extra reduction, 5=extreme/damaging reduction
   redo,skipend;
var
   xalpha:tbasicimage;
   ar8,sr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc24:tcolor24;
   sc32:tcolor32;
   trSAFE,tgSAFE,tbSAFE,xtranscol,tr,tg,tb,int1,int2,int3,int4,dpos,xreducer1,xreducer2,xfeather,p,xcoltype,xi,dbits,xbits,xw,xh,sx,sy:longint;
   lastf2,f0,f1,f2,f3,f4,xrow,str1:tstr8;
   fbpp,flen,flen0,flen1,flen2,flen3,flen4:longint;
   xcollist:array[0..256] of tcolor32;//allow to overrun limit -> we can detect TOO MANY colors error - 19jan2021
   xcollistcount:longint;
   xreducerok,xmustwritePAL,xmustwritePALA:boolean;
   //## i32 ##
   function i32(xval:longint):longint;//26jan2021, 11jan2021, 11jun2017
   var
      a,b:tint4;
   begin
   //defaults
   a.val:=xval;
   //get
   b.bytes[3]:=a.bytes[0];
   b.bytes[2]:=a.bytes[1];
   b.bytes[1]:=a.bytes[2];
   b.bytes[0]:=a.bytes[3];
   //set
   result:=b.val;
   end;
   //## xaddchunk ##
   function xaddchunk(xname:array of byte;xval:tstr8):boolean;
   label
      skipend;
   begin
   //defaults
   result:=false;
   try
   //check
   if system_debug and (sizeof(xname)<>4) then showbasic('PNG: Invalid chunk name length');
   if not str__lock(@xval) then goto skipend;

   //compress -> for "IDAT" chunks only -> must use standard linux "deflate" algorithm - 11jan2021
   if low__comparearray(xname,[uuI,uuD,uuA,uuT]) and (xval.len>=1) and (not low__compress(@xval)) then goto skipend;

   //get
   xdata.addint4(i32(xval.len));
   xdata.aadd(xname);
   if (xval.len>=1) then xdata.add(xval);
   //.insert name at begining of val and then do crc32 on it - 26jan2021
   xval.ains(xname,0);
   xdata.addint4(i32(low__crc32b(xval)));
   //successful
   result:=true;
   skipend:
   except;end;
   try;str__uaf(@xval);except;end;
   end;
   //## xaddTEXT ##
   function xaddTEXT(xkeyword,xtext:tstr8):boolean;
   label
      skipend;
   var
      xval:tstr8;
   begin
   //defaults
   result:=false;
   try
   str__lock(@xkeyword);
   str__lock(@xtext);
   //xkeyword
   if zznil(xkeyword,2150) or (xkeyword.len<=0) then goto skipend;
   if (xkeyword.len>79) then xkeyword.setlen(79);
   low__PNGfilter_textlatin1(xkeyword);
   if (xkeyword.len<=0) then goto skipend;
   //xtext
   low__PNGfilter_textlatin1(xtext);
   //xval
   xval:=str__newaf8;
   try
   xval.add(xkeyword);
   xval.addbyt1(0);//null sep
   xval.add(xtext);
   except;end;
   //get              "tEXt"
   result:=xaddchunk([llt,uuE,uuX,llt],xval);
   //was: result:=pushb(xdatalen,xdata,xchunkdata('tEXt',xkeyword+#0+xtext));
   skipend:
   except;end;
   try
   str__uaf(@xkeyword);
   str__uaf(@xtext);
   except;end;
   end;
   //## xaddcol32 ##
   function xaddcol32(x:tcolor32):byte;
   var
      p:longint;
   begin
   result:=0;
   //1st
   if (xcollistcount<=0) then
      begin
      xcollist[0].r:=x.r;
      xcollist[0].g:=x.g;
      xcollist[0].b:=x.b;
      xcollist[0].a:=x.a;
      result:=0;
      xcollistcount:=1;//first item counted - 27jan2021
      exit;
      end;
   //find existing
   for p:=0 to (xcollistcount-1) do if (xcollist[p].r=x.r) and (xcollist[p].g=x.g) and (xcollist[p].b=x.b) and (xcollist[p].a=x.a) then
      begin
      if (p<=255) then result:=p else result:=0;
      exit;
      end;
   //add new
   if (xcollistcount<=high(xcollist)) then
      begin
      xcollist[xcollistcount].r:=x.r;
      xcollist[xcollistcount].g:=x.g;
      xcollist[xcollistcount].b:=x.b;
      xcollist[xcollistcount].a:=x.a;
      if (xcollistcount<=255) then result:=xcollistcount else result:=0;//default 1st item by default
      inc(xcollistcount);
      end;
   end;
   //## xreduce32 ##
   procedure xreduce32;
   const
      xthreshold=50;
   begin
   //.leave these primary colors FULLY intact - 13jan2021
   if ((sc32.r<>255) or (sc32.g<>255) or (sc32.b<>255)) and//white clwhite
      ((sc32.r<>0  ) or (sc32.g<>0  ) or (sc32.b<>0  )) and//black clblack
      ((sc32.r<>255) or (sc32.g<>0  ) or (sc32.b<>0  )) and//red   clred
      ((sc32.r<>0  ) or (sc32.g<>255) or (sc32.b<>0  )) and//lime  clime
      ((sc32.r<>0  ) or (sc32.g<>0  ) or (sc32.b<>255)) and//blue clblue
      ((sc32.r<>tr ) or (sc32.g<>tg ) or (sc32.b<>tb))  then//transparent color if specified - 20jan2021
      begin
      //get
      if (sc32.r>xthreshold) then sc32.r:=(sc32.r div xreducer1)*xreducer1 else sc32.r:=(sc32.r div xreducer2)*xreducer2;
      if (sc32.g>xthreshold) then sc32.g:=(sc32.g div xreducer1)*xreducer1 else sc32.g:=(sc32.g div xreducer2)*xreducer2;
      if (sc32.b>xthreshold) then sc32.b:=(sc32.b div xreducer1)*xreducer1 else sc32.b:=(sc32.b div xreducer2)*xreducer2;
      //restrict
      if (sc32.r=tr) and (sc32.g=tg) and (sc32.b=tb) then//transparent color
         begin
         sc32.r:=trSAFE;
         sc32.g:=tbSAFE;
         sc32.b:=tgSAFE;
         end
      else if (sc32.r=255) and (sc32.g=255) and (sc32.b=255) then//non-white
         begin
         sc32.r:=254;
         sc32.g:=254;
         sc32.b:=254;
         end
      else if (sc32.r=0) and (sc32.g=0) and (sc32.b=0) then//non-black
         begin
         sc32.r:=1;
         sc32.g:=1;
         sc32.b:=1;
         end
      else if (sc32.r=255) and (sc32.g=0) and (sc32.b=0) then//non-red
         begin
         sc32.r:=254;
         sc32.g:=0;
         sc32.b:=0;
         end
      else if (sc32.r=0) and (sc32.g=255) and (sc32.b=0) then//non-green
         begin
         sc32.r:=0;
         sc32.g:=254;
         sc32.b:=0;
         end
      else if (sc32.r=0) and (sc32.g=0) and (sc32.b=255) then//non-blue
         begin
         sc32.r:=0;
         sc32.g:=0;
         sc32.b:=254;
         end;
      end;
   //.leave these alpha values FULLY intact - 13jan2021
   if (sc32.a<>0) then//and (sc32.a<>127) and (sc32.a<>255) then
      begin
      if (sc32.a>xthreshold) then sc32.a:=(sc32.a div xreducer1)*xreducer1 else sc32.a:=(sc32.a div xreducer2)*xreducer2;
      if (sc32.a=0) then sc32.a:=xreducer1;
      end;
   end;
   //## xdeflatesize ##
   function xdeflatesize(x:tstr8):longint;//a value estimate of WHAT it might be if we were to actually compress "x" and return it's size - 16jan2021
   var//Typical way for PNG standard to determine best filter type to use - 16jan2021
      //Note: Tested against actual per filter compression, simple method below
      //      produces PNG images for about 107% larger than per filter compression
      //      checking but with only 21% time taken or 4.76x faster.
      p:longint;
   begin
   result:=0;
   if zzok(x,7010) and (x.len>=1) then
      begin
      for p:=1 to x.len do inc(result,x.pbytes[p-1]);
      end;
   end;
   //## xpaeth ##
   function xpaeth(a,b,c:byte):longint;
   var
      p,pa,pb,pc:longint;
   begin
   //a = left, b=above, c=upper left
   p:=a+b-c;//initial estimate
   pa:=abs(p-a);
   pb:=abs(p-b);
   pc:=abs(p-c);
   if (pa<=pb) and (pa<=pc) then result:=a
   else if (pb<=pc)         then result:=b
   else                          result:=c;
   end;
begin
//defaults
result:=false;
try
e:=gecTaskfailed;
xalpha:=nil;
xoutbpp:=8;

//check
if not str__lock(@xdata) then exit;
xdata.clear;

//range
sfeather:=frcrange32(sfeather,-1,100);//-1=asis, 0=none(sharp), 1..100=feather(Npx/blur)
slessdata:=frcrange32(slessdata,0,5);

//init
if not misok82432(x,xbits,xw,xh) then exit;
//dbits:=xbits;
xalpha:=misimg8(xw,xh);
lastf2:=str__new8;
f0:=str__new8;
f1:=str__new8;
f2:=str__new8;
f3:=str__new8;
f4:=str__new8;
xrow:=str__new8;
str1:=str__new8;

//xfeather
xfeather:=sfeather;
//.force sharp feather when a transparent color is specified - 17jan2021
if (stranscol<>clnone) and (xfeather<0) then xfeather:=0;

//slessdata
xreducer1:=slessdata;
xreducer2:=xreducer1+1;
xreducerok:=(xreducer1>=2) or (xreducer2>=2);

//make feather -> the alpha channel -> this takes control of all alpha values - 12jan2021
if not mask__feather2(x,xalpha,sfeather,stranscol,stransframe,xtranscol) then goto skipend;//requires "sfeather" and "stranscol" in their original formats

//xtranscol -> used in this proc for reduce32 (to avoid reducing this particular color)
tr:=-1;
tg:=-1;
tb:=-1;
if (xtranscol<>clnone) then
   begin
   sc24:=low__intrgb(xtranscol);
   tr:=sc24.r;
   tg:=sc24.g;
   tb:=sc24.b;
   if (tr=255) and (tg=255) and (tb=255) then
      begin
      trSAFE:=254;
      tgSAFE:=254;
      tbSAFE:=254;
      end
   else
      begin
      trSAFE:=255;
      tgSAFE:=255;
      tbSAFE:=255;
      end;
   end;

//start with 8bit mode - 19jan2021
dbits:=8;

//start ------------------------------------------------------------------------
redo:
//dbits
if (dbits=8) then
   begin
   if (xcollistcount>256) then dbits:=32;//we tried 8bit mode BUT ended up with more than 256 colors -> switch to 32bit mode instead - 19jan2021
   end
else if (dbits<32) and (xbits=24) and (xfeather>=0) then dbits:=32;
xoutbpp:=dbits;

//reset
xcollistcount:=0;
xmustwritePAL:=false;
xmustwritePALA:=false;
xdata.clear;

//color type
case dbits of
8:xcoltype:=3;//palette based (includes only RGB entries of any number between 1 and 256 entirely dependant on the size of DATA in "PLTE" chunk, need to use "tRNS" which like palette stores JUST the alpha values for each palette entry)
24:xcoltype:=2;//0=greyscale, 1=pallete used, 2=color used, 4=alpha used -> add these together to produce final value - 11jan2021
32:xcoltype:=6;
end;

//header
//was: pushb(xdatalen,xdata,#137 +#80 +#78 +#71 +#13 +#10 +#26 +#10);
xdata.aadd([137,80,78,71,13,10,26,10]);

//IHDR                         //name   width.4     height.4   bitdepth.1  colortype.1 (6=R8,G8,B8,A8)  compressionMethod.1(#0 only = deflate/inflate)  filtermethod.1(#0 only) interlacemethod.1(#0=LR -> TB scanline order)
//was: pushb(xdatalen,xdata,xchunkdata('IHDR', i32(xw)     +i32(xh)   +#8         +char(xcoltype)              +#0                                             +#0                     +#0));
str1.clear;
str1.addint4(i32(xw));
str1.addint4(i32(xh));
str1.addbyt1(8);
str1.addbyt1(xcoltype);
str1.addbyt1(0);
str1.addbyt1(0);
str1.addbyt1(0);
xaddchunk([uuI,uuH,uuD,uuR],str1);
str1.clear;

//text chunks
if not xaddTEXT(bcopystrall('Software'),bcopystrall(app__info('name')+' v'+app__info('ver'))) then goto skipend;
if not xaddTEXT(bcopystrall('be.png.settings'),bcopystrall(inttostr(stranscol)+'.'+inttostr(sfeather)+'.'+inttostr(slessdata))) then goto skipend;

//scanlines
//was: setlength(xrow, xh * (1+(xw*(dbits div 8))) );
xrow.setlen( xh * (1+(xw*(dbits div 8))) );
//.filter support
fbpp:=dbits div 8;//bytes per pixel
flen:=(xw*fbpp);//size of row excluding leading filter byte
//was: setlength(f0,flen);
//was: setlength(f1,flen);
//was: setlength(f2,flen);
//was: setlength(lastf2,flen);for p:=1 to flen do lastf2[p]:=#0;
//was: setlength(f3,flen);
//was: setlength(f4,flen);
f0.setlen(flen);
f1.setlen(flen);
f2.setlen(flen);
lastf2.setlen(flen);for p:=0 to (flen-1) do lastf2.pbytes[p]:=0;
f3.setlen(flen);
f4.setlen(flen);

xi:=0;
for sy:=0 to (xh-1) do
begin
if not misscan8(xalpha,sy,ar8) then goto skipend;
if not misscan82432(x,sy,sr8,sr24,sr32) then goto skipend;
inc(xi);xrow.pbytes[xi-1]:=0;//filter subtype=none (#0)
dpos:=xi;

//.32 => 32
if (xbits=32) and (dbits=32) then
   begin
   if xreducerok then
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=sr32[sx];
      sc32.a:=ar8[sx];
      xreduce32;
      inc(xi);xrow.pbytes[xi-1]:=sc32.r;
      inc(xi);xrow.pbytes[xi-1]:=sc32.g;
      inc(xi);xrow.pbytes[xi-1]:=sc32.b;
      inc(xi);xrow.pbytes[xi-1]:=sc32.a;
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=sr32[sx];
      sc32.a:=ar8[sx];
      inc(xi);xrow.pbytes[xi-1]:=sc32.r;
      inc(xi);xrow.pbytes[xi-1]:=sc32.g;
      inc(xi);xrow.pbytes[xi-1]:=sc32.b;
      inc(xi);xrow.pbytes[xi-1]:=sc32.a;
      end;//sx
      end;
   end
//.32 => 24
else if (xbits=32) and (dbits=24) then
   begin
   if xreducerok then
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=sr32[sx];
      xreduce32;
      inc(xi);xrow.pbytes[xi-1]:=sc32.r;
      inc(xi);xrow.pbytes[xi-1]:=sc32.g;
      inc(xi);xrow.pbytes[xi-1]:=sc32.b;
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=sr32[sx];
      inc(xi);xrow.pbytes[xi-1]:=sc32.r;
      inc(xi);xrow.pbytes[xi-1]:=sc32.g;
      inc(xi);xrow.pbytes[xi-1]:=sc32.b;
      end;//sx
      end;
   end
//.32 => 8
else if (xbits=32) and (dbits=8) then
   begin
   xmustwritePAL:=true;
   xmustwritePALA:=true;
   for sx:=0 to (xw-1) do
   begin
   sc32:=sr32[sx];
   sc32.a:=ar8[sx];
   if xreducerok then xreduce32;
   inc(xi);xrow.pbytes[xi-1]:=xaddcol32(sc32);
   end;//sx
   //check TOO MANY colors error - 19jan2021
   if (xcollistcount>256) then goto redo;
   end

//.24 => 32
else if (xbits=24) and (dbits=32) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24:=sr24[sx];
   sc32.r:=sc24.r;
   sc32.g:=sc24.g;
   sc32.b:=sc24.b;
   sc32.a:=ar8[sx];
   if xreducerok then xreduce32;
   inc(xi);xrow.pbytes[xi-1]:=sc32.r;
   inc(xi);xrow.pbytes[xi-1]:=sc32.g;
   inc(xi);xrow.pbytes[xi-1]:=sc32.b;
   inc(xi);xrow.pbytes[xi-1]:=sc32.a;
   end;//sx
   end
//.24 => 24
else if (xbits=24) and (dbits=24) then
   begin
   if xreducerok then
      begin
      for sx:=0 to (xw-1) do
      begin
      sc24:=sr24[sx];
      sc32.r:=sc24.r;
      sc32.g:=sc24.g;
      sc32.b:=sc24.b;
      sc32.a:=255;
      xreduce32;
      inc(xi);xrow.pbytes[xi-1]:=sc32.r;
      inc(xi);xrow.pbytes[xi-1]:=sc32.g;
      inc(xi);xrow.pbytes[xi-1]:=sc32.b;
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc24:=sr24[sx];
      sc32.r:=sc24.r;
      sc32.g:=sc24.g;
      sc32.b:=sc24.b;
      sc32.a:=255;
      inc(xi);xrow.pbytes[xi-1]:=sc32.r;
      inc(xi);xrow.pbytes[xi-1]:=sc32.g;
      inc(xi);xrow.pbytes[xi-1]:=sc32.b;
      end;//sx
      end;
   end
//.24 => 8
else if (xbits=24) and (dbits=8) then
   begin
   xmustwritePAL:=true;
   xmustwritePALA:=(xfeather>=1) or ((xfeather>=0) and (stranscol<>clnone));//specially for 8bit palette images -> required for alpha palette addon values - 13jan2021
   for sx:=0 to (xw-1) do
   begin
   sc24:=sr24[sx];
   sc32.r:=sc24.r;
   sc32.g:=sc24.g;
   sc32.b:=sc24.b;
   sc32.a:=ar8[sx];
   if xreducerok then xreduce32;
   inc(xi);xrow.pbytes[xi-1]:=xaddcol32(sc32);
   end;//sx
   //check TOO MANY colors error - 19jan2021
   if (xcollistcount>256) then goto redo;
   end

//.8 => 32
else if (xbits=8) and (dbits=32) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32.r:=sr8[sx];
   sc32.g:=sc32.r;
   sc32.b:=sc32.r;
   sc32.a:=ar8[sx];
   if xreducerok then xreduce32;
   inc(xi);xrow.pbytes[xi-1]:=sc32.r;
   inc(xi);xrow.pbytes[xi-1]:=sc32.g;
   inc(xi);xrow.pbytes[xi-1]:=sc32.b;
   inc(xi);xrow.pbytes[xi-1]:=sc32.a;
   end;//sx
   end
//.8 => 24
else if (xbits=8) and (dbits=24) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32.r:=sr8[sx];
   sc32.g:=sc32.r;
   sc32.b:=sc32.r;
   sc32.a:=255;
   if xreducerok then xreduce32;
   inc(xi);xrow.pbytes[xi-1]:=sc32.r;
   inc(xi);xrow.pbytes[xi-1]:=sc32.g;
   inc(xi);xrow.pbytes[xi-1]:=sc32.b;
   end;//sx
   end
//.8 => 8
else if (xbits=8) and (dbits=8) then
   begin
   xmustwritePAL:=true;
   xmustwritePALA:=(xfeather>=1) or ((xfeather>=0) and (stranscol<>clnone));//specially for 8bit palette images -> required for alpha palette addon values - 13jan2021
   for sx:=0 to (xw-1) do
   begin
   sc32.r:=sr8[sx];
   sc32.g:=sc32.r;
   sc32.b:=sc32.r;
   sc32.a:=ar8[sx];
   if xreducerok then xreduce32;
   inc(xi);xrow.pbytes[xi-1]:=xaddcol32(sc32);
   end;//sx
   end
//.?
else break;

//sample all filters and use the one that compresses the best
//.f0
//was: for p:=1 to flen do f0[p]:=xrow[dpos+p];
//for p:=1 to flen do f0.pbytes[p-1]:=xrow.pbytes[dpos+(p-1)];
for p:=1 to flen do f0.pbytes[p-1]:=xrow.pbytes[dpos+p-1];
flen0:=xdeflatesize(f0);

//.f1 -> sub -> write difference in pixels in horizontal lines
for p:=1 to flen do
begin
int1:=xrow.pbytes[dpos+p-1];
if ((p-fbpp)>=1) then int2:=xrow.pbytes[dpos+p-fbpp-1] else int2:=0;
int1:=int1-int2;
if (int1<0) then inc(int1,256);
f1.pbytes[p-1]:=int1;
end;//p
flen1:=xdeflatesize(f1);

//.f2 - up -> write difference in pixels in vertical lines
for p:=1 to flen do
begin
int2:=lastf2.pbytes[p-1];
int1:=xrow.pbytes[dpos+p-1];
int1:=int1-int2;
if (int1<0) then inc(int1,256);
f2.pbytes[p-1]:=int1;
end;//p
flen2:=xdeflatesize(f2);

//.f3 - average
for p:=1 to flen do
begin
int3:=lastf2.pbytes[p-1];
if ((p-fbpp)>=1) then int2:=xrow.pbytes[dpos+p-fbpp-1] else int2:=0;
int1:=xrow.pbytes[dpos+p-1];
int1:=int1-trunc((int2+int3)/2);
if (int1<0) then inc(int1,256);
f3.pbytes[p-1]:=int1;
end;//p
flen3:=xdeflatesize(f3);

//.f4 - paeth
for p:=1 to flen do
begin
if ((p-fbpp)>=1) then int4:=lastf2.pbytes[p-fbpp-1] else int4:=0;
int3:=lastf2.pbytes[p-1];
if ((p-fbpp)>=1) then int2:=xrow.pbytes[dpos+p-fbpp-1] else int2:=0;
int1:=xrow.pbytes[dpos+p-1];
int1:=int1-xpaeth(int2,int3,int4);
if (int1<0) then inc(int1,256);
f4.pbytes[p-1]:=int1;
end;//p
flen4:=xdeflatesize(f4);

//.sync lastf2 -> do here BEFORE xrow is modified below - 14jan2021
for p:=1 to flen do lastf2.pbytes[p-1]:=xrow.pbytes[dpos+p-1];

//.write filter back into row
int1:=flen0;
int2:=0;
//.1
if (flen1<int1) then
   begin
   int1:=flen1;
   int2:=1;
   end;
//.2
if (flen2<int1) then
   begin
   int1:=flen2;
   int2:=2;
   end;
//.3
if (flen3<int1) then
   begin
   int1:=flen3;
   int2:=3;
   end;
//.4
if (flen4<int1) then
   begin
   //int1:=flen4;
   int2:=4;
   end;

//.write
case int2 of
1:begin
   xrow.pbytes[dpos-1]:=1;
   for p:=1 to flen do xrow.pbytes[dpos+p-1]:=f1.pbytes[p-1];
   end;
2:begin
   xrow.pbytes[dpos-1]:=2;
   for p:=1 to flen do xrow.pbytes[dpos+p-1]:=f2.pbytes[p-1];
   end;
3:begin
   xrow.pbytes[dpos-1]:=3;
   for p:=1 to flen do xrow.pbytes[dpos+p-1]:=f3.pbytes[p-1];
   end;
4:begin
   xrow.pbytes[dpos-1]:=4;
   for p:=1 to flen do xrow.pbytes[dpos+p-1]:=f4.pbytes[p-1];
   end;
end;

end;//sy

//.PLTE - color palette (RGB sets only) for 8bit images -> must preceed any "IDAT"
if xmustwritePAL then
   begin
   str1.clear;
   if (xcollistcount>=1) then
      begin
      //was: setlength(str1,xcollistcount*3);
      str1.setlen(xcollistcount*3);
      xi:=0;
      for p:=0 to (xcollistcount-1) do
      begin
      inc(xi);str1.pbytes[xi-1]:=xcollist[p].r;
      inc(xi);str1.pbytes[xi-1]:=xcollist[p].g;
      inc(xi);str1.pbytes[xi-1]:=xcollist[p].b;
      end;//p
      end;
   //add
   //was: pushb(xdatalen,xdata,xchunkdata('PLTE',str1));
   xaddchunk([uuP,uuL,uuT,uuE],str1);
   str1.clear;
   end;

//.tRNS - color palette alpha's (A bytes only from the RGBA color list) for 8bit images -> must come after "PLTE" and before any "IDAT" chunks
if xmustwritePALA then
   begin
   str1.clear;
   if (xcollistcount>=1) then
      begin
      //was: setlength(str1,xcollistcount);
      str1.setlen(xcollistcount);
      xi:=0;
      for p:=0 to (xcollistcount-1) do
      begin
      inc(xi);str1.pbytes[xi-1]:=xcollist[p].a;//alpha values (1 byte) only - 11jan2021
      end;//p
      end;
   //add
   //was: pushb(xdatalen,xdata,xchunkdata('tRNS',str1));
   xaddchunk([llt,uuR,uuN,uuS],str1);
   str1.clear;
   end;

//.IDAT
//was: pushb(xdatalen,xdata,xchunkdata('IDAT',xrow));
xaddchunk([uuI,uuD,uuA,uuT],xrow);

//IEND
//was: pushb(xdatalen,xdata,xchunkdata('IEND',''));
str1.clear;
xaddchunk([uuI,uuE,uuN,uuD],str1);//27jan2021
//successful
result:=true;
skipend:
except;end;
try
freeobj(@xalpha);
str__free(@lastf2);
str__free(@f0);
str__free(@f1);
str__free(@f2);
str__free(@f3);
str__free(@f4);
str__free(@xrow);
str__free(@str1);
except;end;
try
if (not result) and zzok(x,7011) then xdata.clear;
str__uaf(@xdata);
except;end;
end;
//## misfrompng82432 ##
function misfrompng82432(s:tobject;sbackcol:longint;sdata:tstr8;var e:string):boolean;//26jan2021
var
   stranscol,sfeather,slessdata:longint;
   shadsettings:boolean;
begin
result:=false;try;result:=misfrompng82432ex(s,sbackcol,stranscol,sfeather,slessdata,shadsettings,sdata,e);except;end;
end;
//## misfrompng82432ex ##
function misfrompng82432ex(s:tobject;sbackcol:longint;var stranscol,sfeather,slessdata:longint;var shadsettings:boolean;sdata:tstr8;var e:string):boolean;//OK=27jan2021, 23jan2021, 21jan2021
label
   //sbackcol: optional background color -> if not "clnone" then image is render onto background color primarily to display any feathering - 20jan2021
   skipend;
var
   sdata64:tstr8;//decoded base64 version of "sdata" -> automatic and optionally used to keep "sdata" unchanged
   sr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   bc8:tcolor8;
   sc24,bc24:tcolor24;
   sc32:tcolor32;
   xpos,xbitdepth,spos,int1,int2,int3,int4,p,xcoltype,sbits,xbits,sw,sh,xw,xh,sx,sy:longint;
   n,v,xdata,xval,lastfd,fd,str1,str2,str3:tstr8;
   fbpp,flen:longint;
   xnam:array[0..3] of byte;
   xcollist:array[0..255] of tcolor32;
   xtransparent,sbackcolok,sdataok:boolean;
   //## fi32 ##
   function fi32(xval:longint):longint;//26jan2021, 11jan2021, 11jun2017
   var
      a,b:tint4;
   begin
   //get
   a.val:=xval;
   b.bytes[0]:=a.bytes[3];
   b.bytes[1]:=a.bytes[2];
   b.bytes[2]:=a.bytes[1];
   b.bytes[3]:=a.bytes[0];
   //set
   result:=b.val;
   end;
   //## xpullchunk ##
   function xpullchunk(var xname:array of byte;xdata:tstr8):boolean;
   label//Chunk structure: "i32(length(xdata))+xname+xdata+i32(misc.crc32b(xname+xdata))"
      skipend;
   var
      xlen:longint;
   begin
   //defaults
   result:=false;
   try
   //check
   if (not str__lock(@xdata)) or (sizeof(xname)<>4) then goto skipend;
   xdata.clear;
   xname[0]:=0;
   xname[1]:=0;
   xname[2]:=0;
   xname[3]:=0;
   //chunk length
   if sdataok then xlen:=fi32(sdata.int4[spos-1]) else xlen:=fi32(sdata64.int4[spos-1]);
   inc(spos,4);
   if (xlen<0) then goto skipend;
   //chunk name
   //was: if sdataok then xname:=copy(sdata,spos,4) else xname:=copy(sdata64,spos,4);
   if sdataok then
      begin
      xname[0]:=sdata.byt1[spos-1+0];
      xname[1]:=sdata.byt1[spos-1+1];
      xname[2]:=sdata.byt1[spos-1+2];
      xname[3]:=sdata.byt1[spos-1+3];
      end
   else
      begin
      xname[0]:=sdata64.byt1[spos-1+0];
      xname[1]:=sdata64.byt1[spos-1+1];
      xname[2]:=sdata64.byt1[spos-1+2];
      xname[3]:=sdata64.byt1[spos-1+3];
      end;
   inc(spos,4);
   //chunk data
   if (xlen>=1) then
      begin
      //was: if sdataok then xdata:=copy(sdata,spos,xlen) else xdata:=copy(sdata64,spos,xlen);
      if sdataok then xdata.add3(sdata,spos-1,xlen) else xdata.add3(sdata64,spos-1,xlen);
      end;
   if (xdata.len<>xlen) then goto skipend;
   inc(spos,xlen+4);//step over trailing crc32(4b)
   //successful
   result:=true;
   skipend:
   except;end;
   try;str__uaf(@xdata);except;end;
   end;
   //## xpaeth ##
   function xpaeth(a,b,c:byte):longint;
   var
      p,pa,pb,pc:longint;
   begin
   //a = left, b=above, c=upper left
   p:=a+b-c;//initial estimate
   pa:=abs(p-a);
   pb:=abs(p-b);
   pc:=abs(p-c);
   if (pa<=pb) and (pa<=pc) then result:=a
   else if (pb<=pc)         then result:=b
   else                          result:=c;
   end;
begin
//defaults
result:=false;
xbits:=0;

try
e:=gecTaskfailed;
xtransparent:=false;
sdataok:=true;
n:=nil;
v:=nil;
xdata:=nil;
xval:=nil;
lastfd:=nil;
fd:=nil;
str1:=nil;
str2:=nil;
str3:=nil;
sdata64:=nil;
//.return values - 21jan2021
shadsettings:=false;
stranscol:=clnone;
sfeather:=-1;//asis
slessdata:=0;
//check
if not str__lock(@sdata) then exit;
//init
if not misok82432(s,sbits,sw,sh) then
   begin
   if (sw<1) then sw:=1;
   if (sh<1) then sh:=1;
   missize2(s,sw,sh,true);
   if not misok82432(s,sbits,sw,sh) then goto skipend;
   end;
spos:=1;
n:=str__new8;
v:=str__new8;
xdata:=str__new8;
xval:=str__new8;
lastfd:=str__new8;
fd:=str__new8;
str1:=str__new8;
str2:=str__new8;
str3:=str__new8;

//.palette
for p:=0 to high(xcollist) do
begin
xcollist[p].r:=0;
xcollist[p].g:=0;
xcollist[p].b:=0;
xcollist[p].a:=255;//fully solid
end;//p

//.sbackcol - 16jan2021
sbackcolok:=(sbackcol<>clnone);
if sbackcolok then
   begin
   bc24:=low__intrgb(sbackcol);
   bc8:=bc24.r;
   if (bc24.g>bc8) then bc8:=bc24.g;
   if (bc24.b>bc8) then bc8:=bc24.b;
   end;

//header
//was: if (copy(sdata,1,8)<>(#137 +#80 +#78 +#71 +#13 +#10 +#26 +#10)) then
if not sdata.asame3(0,[137,80,78,71,13,10,26,10],true) then
   begin
   //switch to base64 encoded text mode
   //was: if (comparetext(copy(sdata,1,4),'b64:')=0) then
   if sdata.asame3(0,[98,54,52,58],true) then
      begin
      sdataok:=false;
      if zznil(sdata64,2151) then sdata64:=str__new8;
      //was: sdata64:=copy(sdata,5,length(sdata));
      //was: sdata64:=low__fromb64b(sdata64);
      sdata64.add3(sdata,4,sdata.len);
      if not low__fromb64(sdata64,sdata64,e) then goto skipend;
      end
   else
      begin
      sdataok:=false;
      if zznil(sdata64,2152) then sdata64:=str__new8;
      //was: sdata64:=low__fromb64b(sdata);
      if not low__fromb64(sdata,sdata64,e) then goto skipend;
      end;
   //check again
   //was: if (copy(sdata64,1,8)<>(#137 +#80 +#78 +#71 +#13 +#10 +#26 +#10)) then
   if not sdata64.asame3(0,[137,80,78,71,13,10,26,10],true) then
      begin
      e:=gecUnknownformat;
      goto skipend;
      end;
   end;
spos:=9;

//IHDR                         //name   width.4     height.4   bitdepth.1  colortype.1 (6=R8,G8,B8,A8)  compressionMethod.1(#0 only = deflate/inflate)  filtermethod.1(#0 only) interlacemethod.1(#0=LR -> TB scanline order)
//pushb(xdatalen,xdata,xchunkdata('IHDR', i32(xw)     +i32(xh)   +#8         +char(xcoltype)              +#0                                             +#0                     +#0));

//was: if (not xpullchunk(xnam,xval)) or (comparetext(xnam,'ihdr')<>0) or (length(xval)<13) then
if (not xpullchunk(xnam,xval)) or (not low__comparearray(xnam,[uuI,uuH,uuD,uuR])) or (xval.len<13) then
   begin
   e:=gecDatacorrupt;
   goto skipend;
   end;
xw:=fi32(xval.int4[1-1]);//1..4
xh:=fi32(xval.int4[5-1]);//5..8
if (xw<=0) or (xh<=0) then
   begin
   e:=gecDatacorrupt;
   goto skipend;
   end
else
   begin
   //size "s" to match datastream image
   if not missize2(s,xw,xh,true) then goto skipend;
   sw:=misw(s);
   sh:=mish(s);
   if (sw<>xw) or (sh<>xh) then goto skipend;
   end;
xbitdepth:=xval.byt1[9-1];
if (xbitdepth<>8) then//we support bit depth of 8bits only
   begin
   e:=gecUnsupportedFormat;
   goto skipend;
   end;
xcoltype:=xval.byt1[10-1];
if (xval.byt1[11-1]<>0) or (xval.byt1[12-1]<>0) or (xval.byt1[13-1]<>0) then
   begin
   e:=gecUnsupportedFormat;
   goto skipend;
   end;

//read remaining chunks
while true do
begin
if not xpullchunk(xnam,xval) then
   begin
   e:=gecDataCorrupt;
   goto skipend;
   end;

//.iend
//was: if      (comparetext(xnam,'iend')=0) then break
if low__comparearray(xnam,[uuI,uuE,uuN,uuD]) then break
//.text
//was: else if (comparetext(xnam,'text')=0) then
else if low__comparearray(xnam,[uuT,uuE,uuX,uuT]) then
   begin
   low__PNGfilter_nullsplit(xval,true,n,v);
   if strmatch(n.text,'be.png.settings') then low__PNGfilter_fromsettings(v,stranscol,sfeather,slessdata,shadsettings);
   end
//.idat
else if low__comparearray(xnam,[uuI,uuD,uuA,uuT]) then xdata.add(xval)//was: pushb(xdatalen,xdata,xval)
//.plte
else if low__comparearray(xnam,[uuP,uuL,uuT,uuE]) then
   begin
   int1:=frcrange32(xval.len div 3,0,1+high(xcollist));
   if (int1>=1) then
      begin
      int2:=1;
      for p:=0 to (int1-1) do
      begin
      xcollist[p].r:=xval.pbytes[int2+0-1];
      xcollist[p].g:=xval.pbytes[int2+1-1];
      xcollist[p].b:=xval.pbytes[int2+2-1];
      inc(int2,3);
      end;//p
      end;//int1
   end
//.trns
else if low__comparearray(xnam,[uuT,uuR,uuN,uuS]) then
   begin
   int1:=frcrange32(xval.len,0,1+high(xcollist));
   if (int1>=1) then
      begin
      for p:=0 to (int1-1) do xcollist[p].a:=xval.pbytes[p];
      end;//int1
   end;
end;//while

//.finalise
//was: pushb(xdatalen,xdata,'');
xval.clear;
//.decompress "xdata"
if ( (xdata.len>=1) and (not low__decompress(@xdata)) ) or (xdata.len<=0) then
   begin
   e:=gecDataCorrupt;
   goto skipend;
   end;

//check datalen matches expected datalen ---------------------------------------
//   Color   Allowed     Interpretation
//   Type    Bit Depths
//   0       1,2,4,8,16  Each pixel is a grayscale sample.
//   2       8,16        Each pixel is an R,G,B triple.
//   3       1,2,4,8     Each pixel is a palette index;
//                       a PLTE chunk must appear.
//   4       8,16        Each pixel is a grayscale sample,
//                       followed by an alpha sample.
//   6       8,16        Each pixel is an R,G,B triple,
//                       followed by an alpha sample.
case xcoltype of
0:xbits:=8;
2:xbits:=24;
3:xbits:=8;
4:xbits:=16;
6:xbits:=32;
end;

if ( (xh * (1+(xw*(xbits div 8))) ) > xdata.len ) then
   begin
   e:=gecDataCorrupt;
   goto skipend;
   end;

//scanlines
//.filter support
fbpp:=xbits div 8;//bytes per pixel
flen:=(xw*fbpp);//size of row excluding leading filter byte
//was: setlength(fd,flen);
fd.setlen(flen);
//was: setlength(lastfd,flen);for p:=1 to flen do lastfd[p]:=#0;
lastfd.setlen(flen);for p:=1 to flen do lastfd.pbytes[p-1]:=0;

for sy:=0 to (xh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
xpos:=1+(sy*(1+flen));

//.unscramble filter row "filtertype.1 + scanline"
case xdata.pbytes[xpos-1] of
0:;//none -> nothing to do
1:begin//.f1 -> sub -> write difference in pixels in horizontal lines
   for p:=1 to flen do
   begin
   int1:=xdata.pbytes[xpos+p-1];
   if ((p-fbpp)>=1) then int2:=xdata.pbytes[xpos+p-fbpp-1] else int2:=0;
   int1:=int1+int2;
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
2:begin//.f2 - up -> write difference in pixels in vertical lines
   for p:=1 to flen do
   begin
   int2:=lastfd.pbytes[p-1];
   int1:=xdata.pbytes[xpos+p-1];
   int1:=int1+int2;
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
3:begin//.f3 - average
   for p:=1 to flen do
   begin
   int3:=lastfd.pbytes[p-1];
   if ((p-fbpp)>=1) then int2:=xdata.pbytes[xpos+p-fbpp-1] else int2:=0;
   int1:=xdata.pbytes[xpos+p-1];
   int1:=int1+trunc((int2+int3)/2);
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
4:begin
   //.f4 - paeth
   for p:=1 to flen do
   begin
   if ((p-fbpp)>=1) then int4:=lastfd.pbytes[p-fbpp-1] else int4:=0;
   int3:=lastfd.pbytes[p-1];
   if ((p-fbpp)>=1) then int2:=xdata.pbytes[xpos+p-fbpp-1] else int2:=0;
   int1:=xdata.pbytes[xpos+p-1];
   int1:=int1+xpaeth(int2,int3,int4);
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
else
   begin
   e:=gecDatacorrupt;
   goto skipend;
   end;
end;//case

//.32 => 32
if (xbits=32) and (sbits=32) then
   begin
   if sbackcolok then//destructive preview mode -> transparency can't be reliabled upon to be maintained -> for viewing/previewing purposes only - 20jan2021
      begin
      for sx:=0 to (xw-1) do
      begin
      int1:=xdata.pbytes[xpos+4-1];
      sc32.r:=((xdata.pbytes[xpos+1-1]*int1)+(bc24.r*(255-int1))) div 255;
      sc32.g:=((xdata.pbytes[xpos+2-1]*int1)+(bc24.g*(255-int1))) div 255;
      sc32.b:=((xdata.pbytes[xpos+3-1]*int1)+(bc24.b*(255-int1))) div 255;
      if (int1=0) then xtransparent:=true;
      sc32.a:=255;
      sr32[sx]:=sc32;
      inc(xpos,4);
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32.r:=xdata.pbytes[xpos+1-1];
      sc32.g:=xdata.pbytes[xpos+2-1];
      sc32.b:=xdata.pbytes[xpos+3-1];
      sc32.a:=xdata.pbytes[xpos+4-1];
      if (sc32.a=0) then xtransparent:=true;//17jan2021
      sr32[sx]:=sc32;
      inc(xpos,4);
      end;//sx
      end;
   end
//.32 => 24
else if (xbits=32) and (sbits=24) then
   begin
   if sbackcolok then//destructive preview mode -> transparency can't be reliabled upon to be maintained -> for viewing/previewing purposes only - 20jan2021
      begin
      for sx:=0 to (xw-1) do
      begin
      int1:=xdata.pbytes[xpos+4-1];
      sc24.r:=((xdata.pbytes[xpos+1-1]*int1)+(bc24.r*(255-int1))) div 255;
      sc24.g:=((xdata.pbytes[xpos+2-1]*int1)+(bc24.g*(255-int1))) div 255;
      sc24.b:=((xdata.pbytes[xpos+3-1]*int1)+(bc24.b*(255-int1))) div 255;
      if (int1=0) then xtransparent:=true;
      sr24[sx]:=sc24;
      inc(xpos,4);
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc24.r:=xdata.pbytes[xpos+1-1];
      sc24.g:=xdata.pbytes[xpos+2-1];
      sc24.b:=xdata.pbytes[xpos+3-1];
      if (xdata.pbytes[xpos+4-1]=0) then xtransparent:=true;//17jan2021
      sr24[sx]:=sc24;
      inc(xpos,4);
      end;//sx
      end;
   end
//.32 => 8
else if (xbits=32) and (sbits=8) then
   begin
   if sbackcolok then//destructive preview mode -> transparency can't be reliabled upon to be maintained -> for viewing/previewing purposes only - 20jan2021
      begin
      for sx:=0 to (xw-1) do
      begin
      int1:=xdata.pbytes[xpos+4-1];
      sc24.r:=xdata.pbytes[xpos+1-1];
      sc24.g:=xdata.pbytes[xpos+2-1];
      sc24.b:=xdata.pbytes[xpos+3-1];
      if (sc24.g>sc24.r) then sc24.r:=sc24.g;
      if (sc24.b>sc24.r) then sc24.r:=sc24.b;
      sc24.r:=((sc24.r*int1)+(bc8*(255-int1))) div 255;
      if (int1=0) then xtransparent:=true;
      sr8[sx]:=sc24.r;
      inc(xpos,4);
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc24.r:=xdata.pbytes[xpos+1-1];
      sc24.g:=xdata.pbytes[xpos+2-1];
      sc24.b:=xdata.pbytes[xpos+3-1];
      if (sc24.g>sc24.r) then sc24.r:=sc24.g;
      if (sc24.b>sc24.r) then sc24.r:=sc24.b;
      if (xdata.pbytes[xpos+4-1]=0) then xtransparent:=true;//17jan2021
      sr8[sx]:=sc24.r;
      inc(xpos,4);
      end;//sx
      end;
   end

//.24 => 32
else if (xbits=24) and (sbits=32) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32.r:=xdata.pbytes[xpos+1-1];
   sc32.g:=xdata.pbytes[xpos+2-1];
   sc32.b:=xdata.pbytes[xpos+3-1];
   sc32.a:=255;//fully solid
   sr32[sx]:=sc32;
   inc(xpos,3);
   end;//sx
   end
//.24 => 24
else if (xbits=24) and (sbits=24) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24.r:=xdata.pbytes[xpos+1-1];
   sc24.g:=xdata.pbytes[xpos+2-1];
   sc24.b:=xdata.pbytes[xpos+3-1];
   sr24[sx]:=sc24;
   inc(xpos,3);
   end;//sx
   end
//.24 => 8
else if (xbits=32) and (sbits=8) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24.r:=xdata.pbytes[xpos+1-1];
   sc24.g:=xdata.pbytes[xpos+2-1];
   sc24.b:=xdata.pbytes[xpos+3-1];
   if (sc24.g>sc24.r) then sc24.r:=sc24.g;
   if (sc24.b>sc24.r) then sc24.r:=sc24.b;
   sr8[sx]:=sc24.r;
   inc(xpos,3);
   end;//sx
   end

//.8 => 32
else if (xbits=8) and (sbits=32) then
   begin
   if sbackcolok then//destructive preview mode -> transparency can't be reliabled upon to be maintained -> for viewing/previewing purposes only - 20jan2021
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=xcollist[xdata.pbytes[xpos+1-1]];
      int1:=sc32.a;
      sc32.r:=((sc32.r*int1)+(bc24.r*(255-int1))) div 255;
      sc32.g:=((sc32.g*int1)+(bc24.g*(255-int1))) div 255;
      sc32.b:=((sc32.b*int1)+(bc24.b*(255-int1))) div 255;
      sc32.a:=255;
      if (int1=0) then xtransparent:=true;
      sr32[sx]:=sc32;
      inc(xpos,1);
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=xcollist[xdata.pbytes[xpos+1-1]];
      if (sc32.a=0) then xtransparent:=true;//17jan2021
      sr32[sx]:=sc32;
      inc(xpos,1);
      end;//sx
      end;
   end
//.8 => 24
else if (xbits=8) and (sbits=24) then
   begin
   if sbackcolok then//destructive preview mode -> transparency can't be reliabled upon to be maintained -> for viewing/previewing purposes only - 20jan2021
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=xcollist[xdata.pbytes[xpos+1-1]];
      int1:=sc32.a;
      sc24.r:=((sc32.r*int1)+(bc24.r*(255-int1))) div 255;
      sc24.g:=((sc32.g*int1)+(bc24.g*(255-int1))) div 255;
      sc24.b:=((sc32.b*int1)+(bc24.b*(255-int1))) div 255;
      if (int1=0) then xtransparent:=true;
      sr24[sx]:=sc24;
      inc(xpos,1);
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=xcollist[xdata.pbytes[xpos+1-1]];
      sc24.r:=sc32.r;
      sc24.g:=sc32.g;
      sc24.b:=sc32.b;
      if (sc32.a=0) then xtransparent:=true;//17jan2021
      sr24[sx]:=sc24;
      inc(xpos,1);
      end;//sx
      end;
   end
//.8 => 8
else if (xbits=8) and (sbits=8) then
   begin
   if sbackcolok then//destructive preview mode -> transparency can't be reliabled upon to be maintained -> for viewing/previewing purposes only - 20jan2021
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=xcollist[xdata.pbytes[xpos+1-1]];
      int1:=sc32.a;
      if (sc32.g>sc32.r) then sc32.r:=sc32.g;
      if (sc32.b>sc32.r) then sc32.r:=sc32.b;
      sc32.r:=((sc32.r*int1)+(bc8*(255-int1))) div 255;
      if (int1=0) then xtransparent:=true;
      sr8[sx]:=sc32.r;
      inc(xpos,1);
      end;//sx
      end
   else
      begin
      for sx:=0 to (xw-1) do
      begin
      sc32:=xcollist[xdata.pbytes[xpos+1-1]];
      if (sc32.g>sc32.r) then sc32.r:=sc32.g;
      if (sc32.b>sc32.r) then sc32.r:=sc32.b;
      if (sc32.a=0) then xtransparent:=true;//17jan2021
      sr8[sx]:=sc32.r;
      inc(xpos,1);
      end;//sx
      end;
   end
//.?
else break;


//.sync lastf2 -> do here BEFORE xrow is modified below - 14jan2021
xpos:=1+(sy*(1+flen));
for p:=1 to flen do lastfd.pbytes[p-1]:=xdata.pbytes[xpos+p-1];
end;//sy


//.transparent feedback
if mishasai(s) then
   begin
   misai(s).format:='PNG';
   misai(s).subformat:=inttostr(stranscol)+'.'+inttostr(sfeather)+'.'+inttostr(slessdata);//23jan2021
   misai(s).transparent:=xtransparent;
   case xcoltype of
   0:misai(s).bpp:=8;
   2:misai(s).bpp:=24;
   3:misai(s).bpp:=8;
   4:misai(s).bpp:=16;
   6:misai(s).bpp:=32;
   end;//case
   end;

//successful
result:=true;
skipend:
except;end;
try
str__free(@n);
str__free(@v);
str__free(@xdata);
str__free(@xval);
str__free(@lastfd);
str__free(@fd);
str__free(@str1);
str__free(@str2);
str__free(@str3);
str__free(@sdata64);
str__uaf(@sdata);//27jan2021
except;end;
end;


//tea procs (text picture) -----------------------------------------------------
//## low__teamake ##
function low__teamake(x:tobject;xout:tstr8;var e:string):boolean;
begin
result:=false;try;result:=low__teamake2(x,false,false,false,0,0,xout,e);except;end;
end;
//## low__teamake2 ##
function low__teamake2(x:tobject;xver2,xtransparent,xsyscolors:boolean;xval1,xval2:longint;xout:tstr8;var e:string):boolean;//07apr2021
label
   skipend;
var
   xmustunlock:boolean;
   l:tint4;
   xw,xh,xbits,sx,sy:longint;
   prows8:pcolorrows8;
   prows24:pcolorrows24;
   prows32:pcolorrows32;
   sr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc8:tcolor8;//07apr2021
   sc24:tcolor24;
   sc32:tcolor32;
   //## xadd24 ##
   procedure xadd24;
   begin
   if (l.r<>sc24.r) or (l.g<>sc24.g) or (l.b<>sc24.b) then
      begin
      if (l.a>=1) then xout.addint4(l.val);
      l.r:=sc24.r;
      l.g:=sc24.g;
      l.b:=sc24.b;
      l.a:=1;
      end
   else
      begin
      inc(l.a);
      if (l.a>=250) then
         begin
         xout.addint4(l.val);
         l.a:=0;//reset
         end;
      end;
   end;
begin
//defaults
result:=false;
e:=gecTaskfailed;
xmustunlock:=false;

try
str__lock(@xout);
if zznil(xout,2201) or zznil(x,2202) then goto skipend;
//init
//.bmp
if (x is tbmp) then
   begin
   if (x as tbmp).lock then xmustunlock:=true else goto skipend;
   if not (x as tbmp).canrows then goto skipend;
   prows8 :=(x as tbmp).prows8;
   prows24:=(x as tbmp).prows24;
   prows32:=(x as tbmp).prows32;
   end
//.image
else if (x is tbasicimage) then
   begin
   prows8 :=(x as tbasicimage).prows8;
   prows24:=(x as tbasicimage).prows24;
   prows32:=(x as tbasicimage).prows32;
   end
else goto skipend;
//.info
xbits:=misb(x);
xw:=misw(x);
xh:=mish(x);
if (xbits<>8) and (xbits<>24) and (xbits<>32) then goto skipend;
xout.clear;
l.val:=0;
//head
if xver2 then
   begin
   xout.aadd([uuT,uuE,uuA,nn2,ssHash]);//TEA2#
   xout.addbyt1(low__insint(1,xtransparent));//0=solid, 1=transparent
   xout.addbyt1(low__insint(1,xsyscolors));//0=no, 1=yes
   xout.addbyt1(0);//reserved
   xout.addbyt1(0);//reserved
   xout.addbyt1(0);//reserved
   xout.addbyt1(0);//reserved
   xout.addint4(xval1);
   xout.addint4(xval2);
   end
else xout.aadd([uuT,uuE,uuA,nn1,ssHash]);//TEA1#
xout.addint4(xw);
xout.addint4(xh);//13 bytes
//pixels
e:=gecOutofmemory;
for sy:=0 to (xh-1) do
begin
if (xbits=8) then
   begin
   sr8:=prows8[sy];
   for sx:=0 to (xw-1) do
   begin
   sc8:=sr8[sx];
   sc24.r:=sc8;
   sc24.g:=sc8;
   sc24.b:=sc8;
   xadd24;
   end;//sx
   end
else if (xbits=24) then
   begin
   sr24:=prows24[sy];
   for sx:=0 to (xw-1) do
   begin
   sc24:=sr24[sx];
   xadd24;
   end;//sx
   end
else if (xbits=32) then
   begin
   sr32:=prows32[sy];
   for sx:=0 to (xw-1) do
   begin
   sc32:=sr32[sx];
   sc24.r:=sc32.r;
   sc24.g:=sc32.g;
   sc24.b:=sc32.b;
   xadd24;
   end;//sx
   end;
end;//xy
//.finalise
if (l.a>=1) then xout.addint4(l.val);
if (xout.len<>xout.count) then xout.setlen(xout.count);
//successful
result:=true;
skipend:
except;end;
try
if (not result) and zzok(xout,7041) then xout.clear;
//.unlock
if xmustunlock and zzok(x,7042) and (x is tbmp) then (x as tbmp).unlock;
str__uaf(@xout);
except;end;
end;
//## low__teainfo ##
function low__teainfo(var adata:tlistptr;xsyszoom:boolean;var aw,ah,aSOD,aversion,aval1,aval2:longint;var atransparent,asyscolors:boolean):boolean;
label//Note: aSOD = start of data
   skipend;
var
   v:tint4;
   xpos:longint;
begin
//defaults
result:=false;
try
aw:=0;
ah:=0;
aSOD:=13;
aversion:=1;
aval1:=0;
aval2:=0;
atransparent:=true;
asyscolors:=true;
//check
if (adata.count<13) or (adata.bytes=nil) then goto skipend;
//get
//.header
if (adata.bytes[0]=uuT) and (adata.bytes[1]=uuE) and (adata.bytes[2]=uuA) and (adata.bytes[3]=nn2) and (adata.bytes[4]=ssHash) then
   begin
   //init
   aSOD:=27;//zero based (27=28 bytes)
   xpos:=5;
   aversion:=2;
   if (adata.count<(aSOD+1)) then goto skipend;//1 based
   //transparent
   atransparent:=(adata.bytes[xpos]<>0);
   inc(xpos,1);
   //syscolors -> black=font color, black+1=border color
   asyscolors:=(adata.bytes[xpos]<>0);
   inc(xpos,1);
   //reserved 1-4
   inc(xpos,4);
   //val1
   v.bytes[0]:=adata.bytes[xpos+0];
   v.bytes[1]:=adata.bytes[xpos+1];
   v.bytes[2]:=adata.bytes[xpos+2];
   v.bytes[3]:=adata.bytes[xpos+3];
   inc(xpos,4);
   aval1:=v.val;
   //val2
   v.bytes[0]:=adata.bytes[xpos+0];
   v.bytes[1]:=adata.bytes[xpos+1];
   v.bytes[2]:=adata.bytes[xpos+2];
   v.bytes[3]:=adata.bytes[xpos+3];
   inc(xpos,4);
   aval2:=v.val;
   end
else if (adata.bytes[0]=uuT) and (adata.bytes[1]=uuE) and (adata.bytes[2]=uuA) and (adata.bytes[3]=nn1) and (adata.bytes[4]=ssHash) then xpos:=5//TEA1#
else goto skipend;
//.w
v.bytes[0]:=adata.bytes[xpos+0];
v.bytes[1]:=adata.bytes[xpos+1];
v.bytes[2]:=adata.bytes[xpos+2];
v.bytes[3]:=adata.bytes[xpos+3];
aw:=v.val;
if (aw<=0) then goto skipend;
inc(xpos,4);
//.h
v.bytes[0]:=adata.bytes[xpos+0];
v.bytes[1]:=adata.bytes[xpos+1];
v.bytes[2]:=adata.bytes[xpos+2];
v.bytes[3]:=adata.bytes[xpos+3];
ah:=v.val;
if (ah<=0) then goto skipend;
//.multiplier
if xsyszoom then low__syszoom(aw,ah);
//successful
result:=true;
skipend:
except;end;
end;
//## low__teainfo2 ##
function low__teainfo2(adata:tstr8;xsyszoom:boolean;var aw,ah,aSOD,aversion,aval1,aval2:longint;var atransparent,asyscolors:boolean):boolean;
label
   skipend;
var
   v:tint4;
   xpos:longint;
begin
//defaults
result:=false;
try
aw:=0;
ah:=0;
aSOD:=13;
aversion:=1;
aval1:=0;
aval2:=0;
atransparent:=true;
asyscolors:=true;
//check
if zznil(adata,2205) or (adata.len<13) then goto skipend;
//get
//.header
if (adata.pbytes[0]=uuT) and (adata.pbytes[1]=uuE) and (adata.pbytes[2]=uuA) and (adata.pbytes[3]=nn2) and (adata.pbytes[4]=ssHash) then
   begin
   //init
   aSOD:=27;//zero based (27=28 bytes)
   xpos:=5;
   aversion:=2;
   if (adata.len<(aSOD+1)) then goto skipend;//1 based
   //transparent
   atransparent:=(adata.pbytes[xpos]<>0);
   inc(xpos,1);
   //syscolors -> black=font color, black+1=border color
   asyscolors:=(adata.pbytes[xpos]<>0);
   inc(xpos,1);
   //reserved 1-4
   inc(xpos,4);
   //val1
   v.bytes[0]:=adata.pbytes[xpos+0];
   v.bytes[1]:=adata.pbytes[xpos+1];
   v.bytes[2]:=adata.pbytes[xpos+2];
   v.bytes[3]:=adata.pbytes[xpos+3];
   inc(xpos,4);
   aval1:=v.val;
   //val2
   v.bytes[0]:=adata.pbytes[xpos+0];
   v.bytes[1]:=adata.pbytes[xpos+1];
   v.bytes[2]:=adata.pbytes[xpos+2];
   v.bytes[3]:=adata.pbytes[xpos+3];
   inc(xpos,4);
   aval2:=v.val;
   end
else if (adata.pbytes[0]=uuT) and (adata.pbytes[1]=uuE) and (adata.pbytes[2]=uuA) and (adata.pbytes[3]=nn1) and (adata.pbytes[4]=ssHash) then xpos:=5//TEA1#
else goto skipend;
//.w
v.bytes[0]:=adata.pbytes[xpos+0];
v.bytes[1]:=adata.pbytes[xpos+1];
v.bytes[2]:=adata.pbytes[xpos+2];
v.bytes[3]:=adata.pbytes[xpos+3];
aw:=v.val;
if (aw<=0) then goto skipend;
inc(xpos,4);
//.h
v.bytes[0]:=adata.pbytes[xpos+0];
v.bytes[1]:=adata.pbytes[xpos+1];
v.bytes[2]:=adata.pbytes[xpos+2];
v.bytes[3]:=adata.pbytes[xpos+3];
ah:=v.val;
if (ah<=0) then goto skipend;
//.multiplier
if xsyszoom then low__syszoom(aw,ah);
//successful
result:=true;
skipend:
except;end;
try;str__autofree(@adata);except;end;
end;
//## low__teadraw ##
function low__teadraw(xcolorise,xsyszoom:boolean;dx,dy,dc,dc2:longint;xarea,xarea2:trect;d:tobject;xtea:tlistptr;xfocus,xgrey,xround:boolean;xroundstyle:longint):boolean;//curved corner support - 07may2020, 09apr2020, 29mar2020
var
   prows24:pcolorrows24;
   prows32:pcolorrows32;
begin
//defaults
result:=false;
try
if zznil(d,2206) then exit;
//init
if (d is tbmp) then
   begin
   if not (d as tbmp).locked then exit;
   prows24:=(d as tbmp).prows24;
   prows32:=(d as tbmp).prows32;
   end
else if (d is tbasicimage) then//07mar2022
   begin
   prows24:=(d as tbasicimage).prows24;
   prows32:=(d as tbasicimage).prows32;
   end
else exit;
//get
result:=low__teadraw2(xcolorise,xsyszoom,dx,dy,dc,dc2,xarea,xarea2,misb(d),misw(d),mish(d),prows24,prows32,nil,-1,xtea,xfocus,xgrey,xround,xroundstyle);
except;end;
end;
//## low__teadraw2 ##
function low__teadraw2(xcolorise,xsyszoom:boolean;dx,dy,dc,dc2:longint;xarea,xarea2:trect;dbits,dw,dh:longint;drows24:pcolorrows24;drows32:pcolorrows32;xmask:tmask8;xmaskval:longint;xtea:tlistptr;xfocus,xgrey,xround:boolean;xroundstyle:longint):boolean;//curved corner support - 13may2020, 07may2020, 09apr2020, 29mar2020
label//Note: now supports curved corners on clip area "xarea" - 09apr2020
     //Note: xsys=optional system color information, if present (xsys<>nil) then image colors are replaced with shades of the system colors - 10mar2021
   skipdone,skipend,zoomdraw,zoomredo,redo;
var
   a:trect;
   b:tint4;
   xzoom,zx,zy,v,mbits,lx,rx,lx2,rx2,lx3,rx3,lx4,rx4,amin,p,yi,xi,xx,xw,xh,dd,xSOD,xversion,xval1,xval2:longint;
   mr8,mr82,mr83,mr84:pcolorrow8;//for mask support
   dr24,dr242,dr243,dr244:pcolorrow24;
   dr32,dr322,dr323,dr324:pcolorrow32;
   ddc,tc,xc,xc2:tcolor24;
   ddc32:tcolor32;
   xcoloriseOK,finv,dreplaceblackOK,dreplaceblackOK2,xonce,xtransparent,xsyscolors:boolean;
   //## x_sys ##
   procedure x_sys;
   begin
   v:=(ddc.r+ddc.g+ddc.b) div 3;
   if (v<100) then v:=100 else if (v>230) then v:=230;
   if finv then v:=255-v;//26mar2021
   ddc.r:=((xc.r*v) + (xc2.r*(255-v))) div 255;
   ddc.g:=((xc.g*v) + (xc2.g*(255-v))) div 255;
   ddc.b:=((xc.b*v) + (xc2.b*(255-v))) div 255;
   end;
   //## x_grey ##
   procedure x_grey;
   begin
   if not xcoloriseOK then
      begin
      //Nolonger greyscale -> instead a darker version of image -> far better appearance - 14mar2021
      v:=(ddc.r+ddc.g+ddc.b) div 3;
      if (v<150) then v:=150 else if (v>230) then v:=230;
      ddc.r:=(ddc.r*v) div 255;
      ddc.g:=(ddc.g*v) div 255;
      ddc.b:=(ddc.b*v) div 255;
      end;
   end;
   //## x_focus ##
   procedure x_focus;
   const
      xval=40;//was: 30 - 29mar2020
   var
      int1:longint;
   begin
   //.r
   int1:=ddc.r+xval;
   if (int1>255) then int1:=255;
   ddc.r:=byte(int1);
   //.g
   int1:=ddc.g+xval;
   if (int1>255) then int1:=255;
   ddc.g:=byte(int1);
   //.b
   int1:=ddc.b+xval;
   if (int1>255) then int1:=255;
   ddc.b:=byte(int1);
   end;
   //## xscan ##
   procedure xscan;
   begin
   case dbits of
   24:dr24:=drows24[yi];
   32:dr32:=drows32[yi];
   end;//case
   if (xmaskval>=0) then mr8:=xmask.prows8[yi];
   end;
   //## xscan2 ##
   procedure xscan2;
   begin
   case dbits of
   24:begin
      if ((zy+0)>=xarea.top) and ((zy+0)<=xarea.bottom) then dr24:=drows24[zy];
      if ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then dr242:=drows24[zy+1];
      if ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then dr243:=drows24[zy+2];
      if ((zy+3)>=xarea.top) and ((zy+3)<=xarea.bottom) then dr244:=drows24[zy+3];
      end;
   32:begin
      if ((zy+0)>=xarea.top) and ((zy+0)<=xarea.bottom) then dr32:=drows32[zy];
      if ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then dr322:=drows32[zy+1];
      if ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then dr323:=drows32[zy+2];
      if ((zy+3)>=xarea.top) and ((zy+3)<=xarea.bottom) then dr324:=drows32[zy+3];
      end;
   end;//case
   if (xmaskval>=0) then
      begin
      if ((zy+0)>=xarea.top) and ((zy+0)<=xarea.bottom) then mr8:=xmask.prows8[zy+0];
      if (xzoom>=2) and ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then mr82:=xmask.prows8[zy+1];
      if (xzoom>=3) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then mr83:=xmask.prows8[zy+2];
      if (xzoom>=4) and ((zy+3)>=xarea.top) and ((zy+3)<=xarea.bottom) then mr84:=xmask.prows8[zy+3];
      end;
   end;
begin
//defaults
result:=false;
try
//check image "d"
if (dw<1) or (dh<1) then exit;
case dbits of
24:if (drows24=nil) then exit;
32:if (drows32=nil) then exit;
else exit;
end;
//.zoom - optional
if xsyszoom then xzoom:=vizoom else xzoom:=1;
//check area
if (xarea.bottom<xarea.top) or (xarea.right<xarea.left) or (xarea.right<0) or (xarea.left>=dw) or (xarea.bottom<0) or (xarea.top>=dh) then exit;
if (xarea2.bottom<xarea2.top) or (xarea2.right<xarea2.left) or (xarea2.right<xarea.left) or (xarea2.left>xarea.right) or (xarea2.bottom<xarea.top) or (xarea2.top>xarea.bottom) then exit;
//check tea
if not low__teainfo(xtea,false,xw,xh,xSOD,xversion,xval1,xval2,xtransparent,xsyscolors) then exit;
//check mask
if (xmaskval>=0) then
   begin
   if zznil(xmask,2207) or ((xmask.width<dw) or (xmask.height<dh)) then xmaskval:=-1;//off
   end;
//init
//.dreplaceblackOK
dreplaceblackOK:=xsyscolors and (dc<>clnone);//(0,0,0) => dc.color
dreplaceblackOK2:=xsyscolors and (dc2<>clnone);//(0,0,1) => dc2.color - 02mar2021
//.xc -> dual purpose: replace "0,0,0 => xc" and "0,0,1 => xc2" OR colorise by converting color pixels into shades of "xc ... xc2" - 27mar2021
xc:=low__intrgb(dc);
xc2:=low__intrgb(dc2);
xcoloriseOK:=xcolorise and (dc<>clnone) and (dc2<>clnone);
finv:=(low__brightness2b(low__rgbint(xc))<low__brightness2b(low__rgbint(xc2)));
//.amin
a:=xarea2;//used for calculating curved cornersretain original copy of "xarea" for calculations and reference
amin:=smallest(low__sum32([a.bottom,-a.top,1]),low__sum32([a.right,-a.left,1]));
//.x
if (xarea.left<xarea2.left) then xarea.left:=xarea2.left;
xarea.left:=frcrange32(xarea.left,0,dw-1);
if (xarea.right>xarea2.right) then xarea.right:=xarea2.right;
xarea.right:=frcrange32(xarea.right,0,dw-1);
if (xarea.right<xarea.left) then exit;
//.y
if (xarea.top<xarea2.top) then xarea.top:=xarea2.top;
xarea.top:=frcrange32(xarea.top,0,dh-1);
if (xarea.bottom>xarea2.bottom) then xarea.bottom:=xarea2.bottom;
xarea.bottom:=frcrange32(xarea.bottom,0,dh-1);
if (xarea.bottom<xarea.top) then exit;
//.mbits
mbits:=dbits;
if (xmaskval>=0) then mbits:=mbits*10;
//get
xonce:=true;
dd:=xSOD;//start of data
xx:=0;
xi:=dx;
yi:=dy;
zx:=dx;
zy:=dy;
//.switch
if (xzoom>=2) then goto zoomdraw;


//-- normal draw ---------------------------------------------------------------
//.scan
if (yi>=xarea.top) and (yi<=xarea.bottom) then xscan;
//.corner
low__cornersolid(true,a,amin,yi,xarea.left,xarea.right,xroundstyle,xround,lx,rx);

redo:
if ((dd+3)<xtea.count) then
   begin
   b.bytes[0]:=xtea.bytes[dd+0];
   b.bytes[1]:=xtea.bytes[dd+1];
   b.bytes[2]:=xtea.bytes[dd+2];
   b.bytes[3]:=xtea.bytes[dd+3];
   //.transparent color - top-left (first) pixel
   if xonce then
      begin
      tc.r:=b.r;
      tc.g:=b.g;
      tc.b:=b.b;
      xonce:=false;
      end;

   //.draw pixels
   if (b.a>=1) then for p:=1 to b.a do
      begin
      //.fasttimer - xcheck - 07jul2021
//      inc(sysfasttimer_xcount); if (sysfasttimer_xcount>=sysfasttimer_xtrigger) then fasttimer_xcheck;

      //.don't draw transparent pixels (tc -> top-left pixel defined) - 03mar2018
      if (yi>=xarea.top) and (yi<=xarea.bottom) and (xi>=lx) and (xi<=rx) and ((not xtransparent) or (b.r<>tc.r) or (b.g<>tc.g) or (b.b<>tc.b)) then
         begin
         //get
         //.black -> user specified color "dc"
         if dreplaceblackOK and (b.r=0) and (b.g=0) and (b.b=0) then ddc:=xc
         else if dreplaceblackOK2 and (b.r=0) and (b.g=0) and (b.b=1) then ddc:=xc2//02mar2021
         //.all other colors applied "as is"
         else
            begin
            ddc.r:=b.r;
            ddc.g:=b.g;
            ddc.b:=b.b;
            if xcoloriseOK then x_sys;
            end;
         //set
         if xgrey then x_grey;
         if xfocus then x_focus;

         case mbits of
         24:dr24[xi]:=ddc;
         240:if (mr8[xi]=xmaskval) then dr24[xi]:=ddc;
         32:begin
            ddc32.r:=ddc.r;
            ddc32.g:=ddc.g;
            ddc32.b:=ddc.b;
            ddc32.a:=255;
            dr32[xi]:=ddc32;
            end;
         320:begin
            if (mr8[xi]=xmaskval) then
               begin
               ddc32.r:=ddc.r;
               ddc32.g:=ddc.g;
               ddc32.b:=ddc.b;
               ddc32.a:=255;
               dr32[xi]:=ddc32;
               end;
            end;
         end;//case
         end;

      inc(xx);
      xi:=xx+dx;
      if (xx>=xw) then
         begin
         inc(yi);
         if (yi>=xarea.top) and (yi<=xarea.bottom) then xscan;
         //.corner
         low__cornersolid(true,a,amin,yi,xarea.left,xarea.right,xroundstyle,xround,lx,rx);
         xx:=0;
         xi:=dx;
         end;
      end;//b.a
   //.loop
   inc(dd,4);
   if ((dd+3)<xtea.count) and (yi<=xarea.bottom) then goto redo;
   end;
goto skipdone;


//-- zoom draw -----------------------------------------------------------------
zoomdraw:
//.scan
xscan2;
//.corner
low__cornersolid(true,a,amin,yi,xarea.left,xarea.right,xroundstyle,xround,lx,rx);
if (xzoom>=2) then low__cornersolid(true,a,amin,zy+1,xarea.left,xarea.right,xroundstyle,xround,lx2,rx2);
if (xzoom>=3) then low__cornersolid(true,a,amin,zy+2,xarea.left,xarea.right,xroundstyle,xround,lx3,rx3);
if (xzoom>=4) then low__cornersolid(true,a,amin,zy+3,xarea.left,xarea.right,xroundstyle,xround,lx4,rx4);

zoomredo:
if ((dd+3)<xtea.count) then
   begin
   b.bytes[0]:=xtea.bytes[dd+0];
   b.bytes[1]:=xtea.bytes[dd+1];
   b.bytes[2]:=xtea.bytes[dd+2];
   b.bytes[3]:=xtea.bytes[dd+3];
   //.transparent color - top-left (first) pixel
   if xonce then
      begin
      tc.r:=b.r;
      tc.g:=b.g;
      tc.b:=b.b;
      xonce:=false;
      end;

   //.draw pixels
   if (b.a>=1) then for p:=1 to b.a do
      begin
      //.fasttimer - xcheck - 07jul2021
//      inc(sysfasttimer_xcount); if (sysfasttimer_xcount>=sysfasttimer_xtrigger) then fasttimer_xcheck;

      //.don't draw transparent pixels (tc -> top-left pixel defined) - 03mar2018
      if (zy>=xarea.top) and (zy<=xarea.bottom) and ((not xtransparent) or (b.r<>tc.r) or (b.g<>tc.g) or (b.b<>tc.b)) then
         begin
         //get
         //.black -> user specified color "dc"
         if dreplaceblackOK and (b.r=0) and (b.g=0) and (b.b=0) then ddc:=xc
         else if dreplaceblackOK2 and (b.r=0) and (b.g=0) and (b.b=1) then ddc:=xc2//02mar2021
         //.all other colors applied "as is"
         else
            begin
            ddc.r:=b.r;
            ddc.g:=b.g;
            ddc.b:=b.b;
            if xcoloriseOK then x_sys;
            end;
         //set
         if xgrey then x_grey;
         if xfocus then x_focus;

         case mbits of
         24:begin
            //y+0
            if (zx>=lx) and (zx<=rx)                        then dr24[zx+0]:=ddc;
            if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr24[zx+1]:=ddc;
            if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr24[zx+2]:=ddc;
            if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr24[zx+3]:=ddc;
            //y+1
            if (xzoom>=2) and ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx)                        then dr242[zx+0]:=ddc;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr242[zx+1]:=ddc;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr242[zx+2]:=ddc;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr242[zx+3]:=ddc;
               end;
            //y+2
            if (xzoom>=3) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx)                        then dr243[zx+0]:=ddc;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr243[zx+1]:=ddc;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr243[zx+2]:=ddc;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr243[zx+3]:=ddc;
               end;
            //y+32
            if (xzoom>=4) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx)                        then dr244[zx+0]:=ddc;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr244[zx+1]:=ddc;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr244[zx+2]:=ddc;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr244[zx+3]:=ddc;
               end;
            end;//24
         240:begin
            //y+0
            if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                        then dr24[zx+0]:=ddc;
            if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr8[zx]=xmaskval) then dr24[zx+1]:=ddc;
            if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr8[zx]=xmaskval) then dr24[zx+2]:=ddc;
            if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr8[zx]=xmaskval) then dr24[zx+3]:=ddc;
            //y+1
            if (xzoom>=2) and ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                         then dr242[zx+0]:=ddc;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr82[zx]=xmaskval) then dr242[zx+1]:=ddc;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr82[zx]=xmaskval) then dr242[zx+2]:=ddc;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr82[zx]=xmaskval) then dr242[zx+3]:=ddc;
               end;
            //y+2
            if (xzoom>=3) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                         then dr243[zx+0]:=ddc;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr83[zx]=xmaskval) then dr243[zx+1]:=ddc;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr83[zx]=xmaskval) then dr243[zx+2]:=ddc;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr83[zx]=xmaskval) then dr243[zx+3]:=ddc;
               end;
            //y+32
            if (xzoom>=4) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                         then dr244[zx+0]:=ddc;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr84[zx]=xmaskval) then dr244[zx+1]:=ddc;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr84[zx]=xmaskval) then dr244[zx+2]:=ddc;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr84[zx]=xmaskval) then dr244[zx+3]:=ddc;
               end;
            end;//240
         32:begin
            //init
            ddc32.r:=ddc.r;
            ddc32.g:=ddc.g;
            ddc32.b:=ddc.b;
            ddc32.a:=255;
            //y+0
            if (zx>=lx) and (zx<=rx)                        then dr32[zx+0]:=ddc32;
            if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr32[zx+1]:=ddc32;
            if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr32[zx+2]:=ddc32;
            if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr32[zx+3]:=ddc32;
            //y+1
            if (xzoom>=2) and ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx)                        then dr322[zx+0]:=ddc32;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr322[zx+1]:=ddc32;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr322[zx+2]:=ddc32;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr322[zx+3]:=ddc32;
               end;
            //y+2
            if (xzoom>=3) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx)                        then dr323[zx+0]:=ddc32;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr323[zx+1]:=ddc32;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr323[zx+2]:=ddc32;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr323[zx+3]:=ddc32;
               end;
            //y+32
            if (xzoom>=4) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx)                        then dr324[zx+0]:=ddc32;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) then dr324[zx+1]:=ddc32;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) then dr324[zx+2]:=ddc32;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) then dr324[zx+3]:=ddc32;
               end;
            end;//32
         320:begin
            //init
            ddc32.r:=ddc.r;
            ddc32.g:=ddc.g;
            ddc32.b:=ddc.b;
            ddc32.a:=255;
            //y+0
            if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                        then dr32[zx+0]:=ddc32;
            if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr8[zx]=xmaskval) then dr32[zx+1]:=ddc32;
            if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr8[zx]=xmaskval) then dr32[zx+2]:=ddc32;
            if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr8[zx]=xmaskval) then dr32[zx+3]:=ddc32;
            //y+1
            if (xzoom>=2) and ((zy+1)>=xarea.top) and ((zy+1)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                         then dr322[zx+0]:=ddc32;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr82[zx]=xmaskval) then dr322[zx+1]:=ddc32;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr82[zx]=xmaskval) then dr322[zx+2]:=ddc32;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr82[zx]=xmaskval) then dr322[zx+3]:=ddc32;
               end;
            //y+2
            if (xzoom>=3) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                         then dr323[zx+0]:=ddc32;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr83[zx]=xmaskval) then dr323[zx+1]:=ddc32;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr83[zx]=xmaskval) then dr323[zx+2]:=ddc32;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr83[zx]=xmaskval) then dr323[zx+3]:=ddc32;
               end;
            //y+32
            if (xzoom>=4) and ((zy+2)>=xarea.top) and ((zy+2)<=xarea.bottom) then
               begin
               if (zx>=lx) and (zx<=rx) and (mr8[zx]=xmaskval)                         then dr324[zx+0]:=ddc32;
               if (xzoom>=2) and ((zx+1)>=lx) and ((zx+1)<=rx) and (mr84[zx]=xmaskval) then dr324[zx+1]:=ddc32;
               if (xzoom>=3) and ((zx+2)>=lx) and ((zx+2)<=rx) and (mr84[zx]=xmaskval) then dr324[zx+2]:=ddc32;
               if (xzoom>=4) and ((zx+3)>=lx) and ((zx+3)<=rx) and (mr84[zx]=xmaskval) then dr324[zx+3]:=ddc32;
               end;
            end;//320
         end;//case
         end;//if

      inc(xx);
      //xi:=xx+dx;
      zx:=(xx*xzoom)+dx;//12mar2021
      if (xx>=xw) then
         begin
         inc(yi);
         zy:=((yi-dy)*xzoom)+dy;
         xscan2;
         //.corner
         low__cornersolid(true,a,amin,zy,xarea.left,xarea.right,xroundstyle,xround,lx,rx);
         if (xzoom>=2) then low__cornersolid(true,a,amin,zy+1,xarea.left,xarea.right,xroundstyle,xround,lx2,rx2);
         if (xzoom>=3) then low__cornersolid(true,a,amin,zy+2,xarea.left,xarea.right,xroundstyle,xround,lx3,rx3);
         if (xzoom>=4) then low__cornersolid(true,a,amin,zy+3,xarea.left,xarea.right,xroundstyle,xround,lx4,rx4);
         xx:=0;
         //xi:=dx;
         zx:=dx;
         end;
      end;//b.a
   //.loop
   inc(dd,4);
   if ((dd+3)<xtea.count) and (yi<=xarea.bottom) then goto zoomredo;
   end;
goto skipdone;

//successful
skipdone:
result:=true;
skipend:
except;end;
end;
//## low__teatoraw24 ##
function low__teatoraw24(xtea:tlistptr;xdata:tstr8;var xw,xh:longint):boolean;
label
   skipend,redo;
var
   a:tint4;
   p,di,dd,xSOD,xversion,xval1,xval2:longint;
   xtransparent,xsyscolors:boolean;
begin
//defaults
result:=false;
try
xw:=0;
xh:=0;
//check
str__lock(@xdata);
if zznil(xdata,2208) or (not low__teainfo(xtea,false,xw,xh,xSOD,xversion,xval1,xval2,xtransparent,xsyscolors)) then goto skipend;
//init
xdata.clear;
xdata.setlen(xw*xh*3);//RGB
//get
dd:=xSOD;//start of data
di:=0;

redo:
if ((dd+3)<xtea.count) then
   begin
   a.bytes[0]:=xtea.bytes[dd+0];
   a.bytes[1]:=xtea.bytes[dd+1];
   a.bytes[2]:=xtea.bytes[dd+2];
   a.bytes[3]:=xtea.bytes[dd+3];
   //.get pixels
   if (a.a>=1) then
      begin
      for p:=1 to a.a do
      begin
      //.fasttimer - xcheck - 07jul2021
//      inc(sysfasttimer_xcount); if (sysfasttimer_xcount>=sysfasttimer_xtrigger) then fasttimer_xcheck;

      if ((di+2)<xdata.count) then
         begin
         xdata.pbytes[di+0]:=a.r;
         xdata.pbytes[di+1]:=a.g;
         xdata.pbytes[di+2]:=a.b;
         end
      else break;
      end;//p
      end;//a.a
   //.loop
   inc(dd,4);
   if ((dd+3)<xtea.count) then goto redo;
   end;
//successful
result:=true;
skipend:
except;end;
try;str__uaf(@xdata);except;end;
end;
//## low__teaTLpixel ##
function low__teaTLpixel(xtea:tlistptr):longint;//top-left pixel of TEA image - 01aug2020
var
   int1,int2:longint;
begin
result:=0;try;low__teaTLpixel2(xtea,int1,int2,result);except;end;
end;
//## low__teaTLpixel2 ##
function low__teaTLpixel2(xtea:tlistptr;var xw,xh,xcolor:longint):boolean;//top-left pixel of TEA image - 01aug2020
var
   a:tint4;
   dd,xSOD,xversion,xval1,xval2:longint;
   xtransparent,xsyscolors:boolean;
begin
//defaults
result:=false;
try
xw:=0;
xh:=0;
xcolor:=clnone;
//check
if (not low__teainfo(xtea,false,xw,xh,xSOD,xversion,xval1,xval2,xtransparent,xsyscolors)) then exit;
//get
dd:=xSOD;//start of data
if ((dd+3)<xtea.count) then
   begin
   a.bytes[0]:=xtea.bytes[dd+0];
   a.bytes[1]:=xtea.bytes[dd+1];
   a.bytes[2]:=xtea.bytes[dd+2];
   a.bytes[3]:=xtea.bytes[dd+3];
   //.get pixels
   if (a.a>=1) then xcolor:=low__rgb(a.r,a.g,a.b);
   end;
//successful
result:=true;
except;end;
end;
//## low__teatoimg ##
function low__teatoimg(xtea:tlistptr;d:tbasicimage;var xw,xh:longint):boolean;//23may2020
label//Supports "d" in 8/24/32 bits
   redo;
var
   a:tint4;
   p,dd,dbits,dx,dy,dw,dh,xSOD,xversion,xval1,xval2:longint;
   xtransparent,xsyscolors,dhasai:boolean;
   dr8 :pcolorrow8;
   dr24:pcolorrow24;
   dr32:pcolorrow32;
   dc24:tcolor24;
   dc32:tcolor32;
   //## dscan ##
   procedure dscan;
   begin
   case dbits of
   8: dr8 :=d.prows8[dy];
   24:dr24:=d.prows24[dy];
   32:dr32:=d.prows32[dy];
   end;
   end;
begin
//defaults
result:=false;
try
xw:=0;
xh:=0;
//check
if (not low__teainfo(xtea,false,xw,xh,xSOD,xversion,xval1,xval2,xtransparent,xsyscolors)) or (not misinfo82432(d,dbits,dw,dh,dhasai)) then exit;
//init
d.sizeto(xw,xh);
dw:=d.width;
dh:=d.height;
//get
dd:=xSOD;//start of data
dx:=0;
dy:=0;
dscan;

redo:
if ((dd+3)<xtea.count) then
   begin
   a.bytes[0]:=xtea.bytes[dd+0];
   a.bytes[1]:=xtea.bytes[dd+1];
   a.bytes[2]:=xtea.bytes[dd+2];
   a.bytes[3]:=xtea.bytes[dd+3];
   //.get pixels
   if (a.a>=1) then
      begin
      for p:=1 to a.a do
      begin
      //.fasttimer - xcheck - 07jul2021
//      inc(sysfasttimer_xcount); if (sysfasttimer_xcount>=sysfasttimer_xtrigger) then fasttimer_xcheck;

      case dbits of
      8:begin
         if (a.g>a.r) then a.r:=a.g;
         if (a.b>a.r) then a.r:=a.b;
         dr8[dx]:=a.r;
         end;
      24:begin
         dc24.r:=a.r;
         dc24.g:=a.g;
         dc24.b:=a.b;
         dr24[dx]:=dc24;
         end;
      32:begin
         dc32.r:=a.r;
         dc32.g:=a.g;
         dc32.b:=a.b;
         dc32.a:=255;
         dr32[dx]:=dc32;
         end;
      end;//case
      //.inc
      inc(dx);
      if (dx>=xw) then
         begin
         dx:=0;
         inc(dy);
         if (dy>=xh) then break;
         dscan;
         end;
      end;//p
      end;//a.a
   //.loop
   inc(dd,4);
   if ((dd+3)<xtea.count) then goto redo;
   end;
//xtransparent
d.ai.transparent:=xtransparent;//07apr2021
d.ai.syscolors:=xsyscolors;//13apr2021
//successful
result:=true;
except;end;
end;
//## low__teatobmp ##
function low__teatobmp(sdata:tstr8;d:tbmp;var xw,xh:longint):boolean;//12apr2021, 21aug2020
label//Supports "d" in 8/24/32 bits
   skipend,redo;
var
   a:tint4;
   slen,p,dd,dbits,dx,dy,xSOD,xversion,xval1,xval2:longint;
   dr8 :pcolorrow8;
   dr24:pcolorrow24;
   dr32:pcolorrow32;
   dc24:tcolor24;
   dc32:tcolor32;
   xtransparent,xsyscolors,dmustunlock:boolean;
begin
//defaults
result:=false;
xw:=0;
xh:=0;
dmustunlock:=false;
try
//check
str__lock(@sdata);
if (not low__teainfo2(sdata,false,xw,xh,xSOD,xversion,xval1,xval2,xtransparent,xsyscolors)) then goto skipend;
//size
missize(d,xw,xh);
if (not misok82432(d,dbits,xw,xh)) then goto skipend;
//get
bmplock(d);
dmustunlock:=true;
slen:=sdata.len;
dd:=xSOD;//start of data
dx:=0;
dy:=0;
if not misscan82432(d,dy,dr8,dr24,dr32) then goto skipend;
redo:
if ((dd+3)<slen) then
   begin
   a.bytes[0]:=sdata.pbytes[dd+0];
   a.bytes[1]:=sdata.pbytes[dd+1];
   a.bytes[2]:=sdata.pbytes[dd+2];
   a.bytes[3]:=sdata.pbytes[dd+3];
   //.get pixels
   if (a.a>=1) then
      begin
      for p:=1 to a.a do
      begin
      //.fasttimer - xcheck - 07jul2021
//      inc(sysfasttimer_xcount); if (sysfasttimer_xcount>=sysfasttimer_xtrigger) then fasttimer_xcheck;

      case dbits of
      8:begin
         if (a.g>a.r) then a.r:=a.g;
         if (a.b>a.r) then a.r:=a.b;
         dr8[dx]:=a.r;
         end;
      24:begin
         dc24.r:=a.r;
         dc24.g:=a.g;
         dc24.b:=a.b;
         dr24[dx]:=dc24;
         end;
      32:begin
         dc32.r:=a.r;
         dc32.g:=a.g;
         dc32.b:=a.b;
         dc32.a:=255;
         dr32[dx]:=dc32;
         end;
      end;//case
      //.inc
      inc(dx);
      if (dx>=xw) then
         begin
         dx:=0;
         inc(dy);
         if (dy>=xh) then break;
         if not misscan82432(d,dy,dr8,dr24,dr32) then goto skipend;
         end;
      end;//p
      end;//a.a
   //.loop
   inc(dd,4);
   if ((dd+3)<slen) then goto redo;
   end;
//xtransparent
d.ai.transparent:=xtransparent;//07apr2021
d.ai.syscolors:=xsyscolors;//13apr2021
//successful
result:=true;
skipend:
except;end;
try
str__uaf(@sdata);
if dmustunlock then bmpunlock(d);
except;end;
end;


//gif procs --------------------------------------------------------------------
{$ifdef gif}
//## gif_decompress ##
procedure gif_decompress(x:tstr8);//28jul2021, 11SEP2007
var
   p:longint;
   z:tstr8;
begin
try
//init
z:=nil;
p:=1;
if block(x) then x.clear else exit;
//get
z:=bnew;
gif_decompressex(p,x,z,0,0,false);
//set
x.add(z);
except;end;
try
bunlockautofree(x);
bfree(z);
except;end;
end;
//## gif_decompressex ##
procedure gif_decompressex(var xlenpos1:longint;x,imgdata:tstr8;_width,_height:longint;interlaced:boolean);//11SEP2007
label
   skipend;
const
  GIFCodeBits=12;// Max number of bits per GIF token code
  GIFCodeMax=(1 SHL GIFCodeBits)-1;//Max GIF token code,12 bits=4095
  StackSize=(2 SHL GIFCodeBits);//Size of decompression stack
  TableSize=(1 SHL GIFCodeBits);//Size of decompression table
var
   tmprow,xlen:longint;
   table0:array[0..TableSize-1] of longint;
   table1:array[0..TableSize-1] of longint;
   firstcode,oldcode:longint;
   buf:array[0..257] of BYTE;
   v,xpos,ypos,pass:longint;
   stack:array[0..StackSize-1] of longint;
   Source:^longint;
   BitsPerCode:longint;//number of CodeTableBits/code
   InitialBitsPerCode:BYTE;
   MaxCode,MaxCodeSize,ClearCode,EOFCode,step,i,StartBit,LastBit,LastByte:longint;
   get_done,return_clear,ZeroBlock:boolean;
   ClearValue:BYTE;

//## read ##
function read(a:pointer;len:longint):longint;
var
   b:pdlByte;
   i:longint;
begin
//defaults
result:=0;
try
//init
b:=a;
//process
for i:=1 to len do if (xlenpos1<=xlen) then
   begin
   b[result]:=x.bytes1[xlenpos1];
   inc(result);
   inc(xlenpos1);
   end
else break;
except;end;
end;
//## nextCode ##
function nextCode(BitsPerCode: longint): longint;
const
   masks:array[0..15] of longint=($0000,$0001,$0003,$0007,$000f,$001f,$003f,$007f,$00ff,$01ff,$03ff,$07ff,$0fff,$1fff,$3fff,$7fff);
var
   p2,StartIndex,EndIndex,ret,EndBit:longint;
   count:BYTE;
begin
//defaults
result:=-1;
try
//check
if return_clear then
   begin
   return_clear:=false;
   result:=ClearCode;
   exit;
   end;//end of if
//get
EndBit:=StartBit+BitsPerCode;
if (EndBit>=LastBit) then
   begin
   if get_done then
      begin
      if (StartBit>=LastBit) then result:=-1;
      exit;
      end;//end of if
   buf[0]:=buf[LastByte-2];
   buf[1]:=buf[LastByte-1];
   //.count
   if (xlenpos1>xlen) then
      begin
      result:=-1;
      exit;
      end
   else
      begin
      count:=byte(x.bytes1[xlenpos1]);
      inc(xlenpos1);
      end;//end of if
   //.check
   if (count=0) then
      begin
      ZeroBlock:=True;
      get_done:=TRUE;
      end
   else
      begin
      //handle premature end of file
      if ((1+xlen-xlenpos1)<count) then
         begin
         //Not enough data left - Just read as much as we can get
         Count:=xlen-xlenpos1+1;
         end;//end of if
      if (Count<>0) and (read(@buf[2],count)<>count) then exit;//out of data
      end;//end of if
   LastByte:=2+count;
   StartBit:=(StartBit-LastBit)+16;
   LastBit:=LastByte*8;
   EndBit:=StartBit+BitsPerCode;
   end;//end of if
//set
EndIndex:=EndBit div 8;
StartIndex:=StartBit div 8;
//check
if (startindex>high(buf)) then exit;//out of range
if (StartIndex=EndIndex) then ret:=buf[StartIndex]
else if ((StartIndex+1)=EndIndex) then ret:=buf[StartIndex] or (buf[StartIndex+1] shl 8)
else ret:=buf[StartIndex] or (buf[StartIndex+1] shl 8) or (buf[StartIndex+2] shl 16);
ret:=(ret shr (StartBit and $0007)) and masks[BitsPerCode];
inc(StartBit,BitsPerCode);
result:=ret;
except;end;
end;
//## NextLZW ##
function NextLZW:longint;
var
   code,incode,i:longint;
   b:byte;
begin
//defaults
result:=-1;
try
//scan
code:=nextCode(BitsPerCode);
while (code>=0) do
begin
if (code=ClearCode) then
   begin
   //check
   if (clearcode>tablesize) then exit;//out of range
   for i:=0 to (ClearCode-1) do
   begin
   table0[i]:=0;
   table1[i]:=i;
   end;//loop

   for i:=ClearCode to (TableSize-1) do
   begin
   table0[i]:=0;
   table1[i]:=0;
   end;//end of loop
   BitsPerCode:=InitialBitsPerCode+1;
   MaxCodeSize:=2*ClearCode;
   MaxCode:=ClearCode+2;
   Source:=@stack;

   repeat
   firstcode:=nextCode(BitsPerCode);
   oldcode:=firstcode;
   until (firstcode<>ClearCode);
   Result := firstcode;
   exit;
   end;//if
//.eof
if (code=EOFCode) then
   begin
   Result:=-2;
   if ZeroBlock then exit;
   //eat blank data (all 0's)
   //--ignore
   exit;
   end;//if

incode:=code;
if (code>=MaxCode) then
   begin
   Source^:=firstcode;
   Inc(Source);
   code:=oldcode;
   end;//if
//check
if (Code>TableSize) then exit;//out of range

 while (code>=ClearCode) do
 begin
 Source^:=table1[code];
 Inc(Source);
 //check
 if (code=table0[code]) then exit;//error
 code:=table0[code];
 //check
 if (Code>TableSize) then exit;
 end;//loop

firstcode:=table1[code];
Source^:=firstcode;
Inc(Source);
code:=MaxCode;
if (code<=GIFCodeMax) then
   begin
   table0[code]:=oldcode;
   table1[code]:=firstcode;
   Inc(MaxCode);
   if ((MaxCode>=MaxCodeSize) and (MaxCodeSize<=GIFCodeMax)) then
      begin
      MaxCodeSize:=MaxCodeSize*2;
      Inc(BitsPerCode);
      end;//end of if
   end;//if
oldcode:=incode;
if (longInt(Source)>longInt(@stack)) then
   begin
   Dec(Source);
   Result:=Source^;
   exit;
   end
end;//loop
Result:=code;
except;end;
end;
//## readLZW ##
function readLZW:longint;
begin
result:=0;
try
if (longInt(Source)>longInt(@stack)) then
   begin
   Dec(Source);
   Result:=Source^;
   end
else Result:=NextLZW;
except;end;
end;

//START
begin
try
//check
if not low__true2(block(x),block(imgdata)) then goto skipend;

//init
xlen:=x.len;
imgdata.clear;
if (xlenpos1<1) or (xlenpos1>xlen) then goto skipend;
//get
if (xlenpos1>xlen) then goto skipend;
InitialBitsPerCode:=x.bytes1[xlenpos1];
inc(xlenpos1);
imgdata.setlen(_width*_height);//was: setlength(imgdata,_width*_height);
//Initialize the Compression routines
BitsPerCode:=InitialBitsPerCode+1;
ClearCode:=1 shl InitialBitsPerCode;
EOFCode:=ClearCode+1;
MaxCodeSize:=2*ClearCode;
MaxCode:=ClearCode+2;
StartBit:=0;
LastBit:=0;
LastByte:=2;
ZeroBlock:=false;
get_done:=false;
return_clear:=true;
Source:=@stack;
try
if interlaced then
   begin
   ypos:=0;
   pass:=0;
   step:=8;
   for i:=0 to (_Height-1) do
   begin
   tmprow:=_width*ypos;
    for xpos:=0 to (_width-1) do
    begin
    v:=readLZW;
    if (v<0) then exit;
    imgdata.bytes1[1+tmprow+xpos]:=byte(v);
    end;//end of loop
   //inc
   Inc(ypos,step);
   if (ypos>=_height) then
      begin
      repeat
      if (pass>0) then step:=step div 2;
      Inc(pass);
      ypos := step DIV 2;
      until (ypos < _height);
      end;//if
   end;//loop
   end
else
   begin
   if (_width>=1) and (_height>=1) then
      begin
      for ypos:=0 to ((_height*_width)-1) do
      begin
      v:=readLZW;
      if (v<0) then exit;
      imgdata.bytes1[1+ypos]:=byte(v);
      end;//end of loop
      end
   else
      begin//decompress raw data string (width and height are not used
      tmprow:=1;
      while true do
      begin
      v:=readLZW;
      if (v<0) then exit;//done
      imgdata.bytes1[tmprow]:=byte(v);
      inc(tmprow);
      end;//loop
      end;//if
   end;//if
except;end;
//too much data
if (readLZW>=0) then
   begin
   //ignore
   end;//if
skipend:
except;end;
try
bunlockautofree(x);
bunlockautofree(imgdata);
except;end;
end;
//## gif_compress ##
function gif_compress(x:tstr8;var e:string):boolean;//12SEP2007
var
   z:tstr8;
begin
//defaults
result:=false;
try
z:=nil;
if not block(x) then exit;
z:=bnew;
//get
if gif_compressex(x,z,e) then
   begin
   x.clear;
   x.add(z);
   result:=true;
   end;
except;end;
try
bfree(z);
bunlockautofree(x);
except;end;
end;
//## gif_compressex ##
function gif_compressex(x,imgdata:tstr8;e:string):boolean;//12SEP2007
label
   skipend;
const
   EndBlockByte=$00;			// End of block marker
var
   h:thashtable;
   buf:tstr8;
   NewCode,Prefix,FreeEntry:smallint;
   NewKey:longint;
   Color:byte;
   ClearFlag:boolean;
   MaxCode,EOFCode,BaseCode,ClearCode:smallint;
   maxcolor,xlen,xpos,BitsPerCode,OutputBits,OutputBucket:longint;
   BitsPerPixel,InitialBitsPerCode:byte;

//## MaxCodesFromBits ##
function MaxCodesFromBits(bits:longint):smallint;
begin
result:=(smallint(1) shl bits)-1;
end;
//## writechar ##
procedure writechar(x:byte);//15SEP2007
begin//"x=nil" => flush
try
//get
buf.addbyt1(x);
//set
if (buf.len>=255) then
   begin
   //was:pushb(imglen,imgdata,char(length(buf))+buf);
   imgdata.addbyt1(buf.len);
   imgdata.add(buf);
   buf.clear;
   end;
except;end;
end;
//## writecharfinish ##
procedure writecharfinish;
begin//"x=nil" => flush
try
if (buf.len>=1) then
   begin
   //was:pushb(imglen,imgdata,char(length(buf))+buf);
   imgdata.addbyt1(buf.len);
   imgdata.add(buf);
   buf.clear;
   end;
except;end;
end;
//## output ##
procedure output(value:longint);
const
  BitBucketMask: array[0..16] of longInt =
    ($0000,
     $0001, $0003, $0007, $000F,
     $001F, $003F, $007F, $00FF,
     $01FF, $03FF, $07FF, $0FFF,
     $1FFF, $3FFF, $7FFF, $FFFF);
begin
try
//get
if (OutputBits > 0) then OutputBucket := (OutputBucket AND BitBucketMask[OutputBits]) OR (longInt(Value) SHL OutputBits)
else OutputBucket := Value;
inc(OutputBits, BitsPerCode);
//set
while (OutputBits >= 8) do
begin
writechar(OutputBucket and $FF);//was: writechar(char(OutputBucket and $FF));
OutputBucket:=OutputBucket shr 8;
dec(OutputBits,8);
end;//end of loop
//check
if (Value = EOFCode) then
   begin
   // At EOF, write the rest of the buffer.
   while (OutputBits > 0) do
   begin
   writechar(OutputBucket and $FF);//was: writechar(char(OutputBucket and $FF));
   OutputBucket := OutputBucket shr 8;
   dec(OutputBits, 8);
   end;//end of loop
   end;//end of if
// If the next entry is going to be too big for the code size,
// then increase it, if possible.
if (FreeEntry > MaxCode) or (ClearFlag) then
   begin
   if (ClearFlag) then
      begin
      BitsPerCode := InitialBitsPerCode;
      MaxCode := MaxCodesFromBits(BitsPerCode);
      ClearFlag := False;
      end
   else
      begin
      inc(BitsPerCode);
      if (BitsPerCode=GIFCodeBits) then MaxCode:=GIFTableMaxMaxCode
      else MaxCode:=MaxCodesFromBits(BitsPerCode);
      end;//end of if
   end;//end of if
except;end;
end;

begin
//defaults
result:=false;
try
h:=nil;
buf:=nil;
//check
if not low__true2(block(x),block(imgdata)) then goto skipend;
imgdata.clear;
e:=gecUnexpectedError;
//init
xlen:=x.len;
xpos:=1;
if (xlen<=2) then goto skipend;
h:=thashtable.create;
buf:=bnew;
maxcolor:=256;
BitsPerPixel:=8;//bits per pixel - fixed at 8, don't go below 2
InitialBitsPerCode:=BitsPerPixel+1;
BitsPerCode:=InitialBitsPerCode;
MaxCode:=MaxCodesFromBits(BitsPerCode);
ClearCode:=(1 SHL (InitialBitsPerCode-1));
EOFCode:=ClearCode+1;
BaseCode:=EOFCode+1;
//.clear bit bucket
OutputBucket:=0;
OutputBits:=0;
imgdata.addbyt1(BitsPerPixel);//was: pushb(imglen,imgdata,char(BitsPerPixel));

//clear - hash table and sync decoder
clearflag:=true;
output(clearcode);
h.clear;
freeentry:=clearcode+2;
//get
prefix:=smallint(x.bytes1[xpos]);//was: x[xpos]);
if (Prefix>=MaxColor) then
   begin
   e:=gecIndexOutOfRange;
   goto skipend;
   end;
while true do
begin
//.inc
inc(xpos);
if (xpos>xlen) then break;
//.get
color:=x.bytes1[xpos];//was: x[xpos];
if (color>=maxcolor) then
   begin
   e:=gecIndexOutOfRange;
   goto skipend;
   end;//end of if
//append postfix to prefix and lookup in table...
NewKey := (longint(Prefix) SHL 8) OR Color;
NewCode := h.lookup(NewKey);
if (NewCode >= 0) then
   begin
   // ...if found, get next pixel
   prefix:=newcode;
   //skip to next item
   continue;
   end;//end of if
// ...if not found, output and start over
output(prefix);
prefix:=smallint(color);
if (FreeEntry < GIFTableMaxFill) then
   begin
   h.insert(NewKey, FreeEntry);
   inc(FreeEntry);
   end
else
   begin
   //clear
   clearflag:=true;
   output(clearcode);
   h.clear;
   freeentry:=clearcode+2;
   end;//end of if
end;//loop
output(prefix);
skipend:
//finalise - 15SEP2007
output(EOFCode);
writecharfinish;
imgdata.addbyt1(EndBlockByte);//was: //writechar('');pushb(imglen,imgdata,char(EndBlockByte));pushb(imglen,imgdata,'');
//successful
result:=true;
except;end;
try
freeobj(@h);
bfree(buf);
bunlockautofree(x);
bunlockautofree(imgdata);
except;end;
end;
//## hashkey ##
function hashkey(key:longint):smallint;
begin
result:=smallint(((Key SHR (GIFCodeBits-8)) XOR Key) MOD HashSize);
end;
//## nexthashkey ##
function nexthashkey(hkey:smallint):smallint;
var
  disp:smallint;
begin
//defaults
result:=0;
try
//secondary hash (after G. Knott)
disp:=HashSize-HKey;
if (HKey=0) then disp:=1;
//disp := 13;		// disp should be prime relative to HashSize, but
			// it doesn't seem to matter here...
dec(HKey,disp);
if (HKey<0) then inc(HKey,HashSize);
Result:=HKey;
except;end;
end;
//## create ##
constructor thashtable.create;
begin//longInt($FFFFFFFF) = -1, 'TGIFImage implementation assumes $FFFFFFFF = -1');
inherited create;
getmem(hashtable,sizeof(thasharray));
clear;
end;
//## destroy ##
destructor thashtable.destroy;
begin
try
freemem(hashtable);
inherited destroy;
except;end;
end;
//## clear ##
procedure thashtable.clear;
begin
try;fillchar(hashtable^,sizeof(thasharray),$FF);except;end;
end;
//## insert  ##
procedure thashtable.insert(key:longint;code:smallint);
var
   hkey:smallint;
begin
try
//Create hash key from prefix string
hkey:=hashkey(key);
//Scan for empty slot
//while (HashTable[HKey] SHR GIFCodeBits <> HashEmpty) do { Unoptimized }
while (hashtable[hkey] and (hashempty shl gifcodebits)<>(hashempty shl gifcodebits)) do hkey:=nexthashkey(hkey);
//Fill slot with key/value pair
hashtable[hkey]:=(key shl gifcodebits) or (code and gifcodemask);
except;end;
end;
//## lookup ##
function thashtable.lookup(key:longInt):smallint;
var
// Search for key in hash table.
// Returns value if found or -1 if not
  hkey:smallint;
  htkey:longInt;
begin
result:=-1;
try
// Create hash key from prefix string
HKey := HashKey(Key);
// Scan table for key
// HTKey := HashTable[HKey] SHR GIFCodeBits; { Unoptimized }
Key := Key SHL GIFCodeBits; { Optimized }
HTKey := HashTable[HKey] AND (HashEmpty SHL GIFCodeBits); { Optimized }
// while (HTKey <> HashEmpty) do { Unoptimized }
while (HTKey <> HashEmpty SHL GIFCodeBits) do { Optimized }
begin
if (Key = HTKey) then
   begin
   // Extract and return value
   Result := HashTable[HKey] AND GIFCodeMask;
   exit;
   end;
// Try next slot
HKey := NextHashKey(HKey);
// HTKey := HashTable[HKey] SHR GIFCodeBits; { Unoptimized }
HTKey := HashTable[HKey] AND (HashEmpty SHL GIFCodeBits); { Optimized }
end;//end of loop
// Found empty slot - key doesn't exist
Result := -1;
except;end;
end;
//## low__fromgif ##
function low__fromgif(x:tbmp;y:tstr8;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
begin
result:=false;try;result:=low__fromgif1(x,y,false,e);except;end;
end;
//## low__fromgif ##
function low__fromgif1(x:tbmp;y:tstr8;xuse32:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
var
   xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;
   xtransparent:boolean;
begin
result:=false;try;result:=low__fromgif3(x,y,xcellcount,xcellwidth,xcellheight,xdelay,xbpp,xuse32,xtransparent,e);except;end;
end;
//## low__fromgif2 ##
function low__fromgif2(x:tbmp;y:tstr8;var xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;var xtransparent:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
begin
result:=false;try;result:=low__fromgif3(x,y,xcellcount,xcellwidth,xcellheight,xdelay,xbpp,false,xtransparent,e);except;end;
end;
//## low__fromgif3 ##
function low__fromgif3(x:tbmp;y:tstr8;var xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;xuse32:boolean;var xtransparent:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
label//Important Note: WHITE is only ever used for transparent pixels, all other colors are allowed
   skipone,skipend;
const
   //main flags
   pfGlobalColorTable	= $80;		{ set if global color table follows L.S.D. }
   pfColorResolution	= $70;		{ Color resolution - 3 bits }
   pfSort		= $08;		{ set if global color table is sorted - 1 bit }
   pfColorTableSize	= $07;		{ size of global color table - 3 bits }
   //local - image des
   idLocalColorTable	= $80;    { set if a local color table follows }
   idInterlaced		= $40;    { set if image is interlaced }
   idSort		= $20;    { set if color table is sorted }
   idReserved		= $0C;    { reserved - must be set to $00 }
   idColorTableSize	= $07;    { size of color table as above }
type
   pgifpal=^tgifpal;
   tgifpal=record
    c:array[0..255] of tcolor24;
    count:longint;
    init:boolean;
    end;
var
   imgdata,tmp:tstr8;
   xbits,imglimit,imgcount,nx,ny,offx,len,dy,dx,trans,delay,loops,i,p,tmp2,ylen,pos1:longint;
   xmustunlock,alltrans,ok,wait,v87a,v89a:boolean;
   lastdispose,dispose,bgcolor,ci,v2,v:byte;
   s:tgifscreen;
   lp,gp:tgifpal;//global color palette
   pal:pgifpal;//pointer to current palette for image to use
   id:tgifimgdes;
   sr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc8,zc8:tcolor8;
   sc32,zc32:tcolor32;
   yc24,zc24,tc24:tcolor24;
   lastrect:trect;
   //## palinit ##
   procedure palinit(var x:tgifpal);
   var
      p:longint;
      r,g,b:byte;
   begin
   try
   //check
   if x.init then exit else x.init:=true;
   //swap
   for p:=0 to high(x.c) do
   begin
   //get
   r:=x.c[p].r;
   g:=x.c[p].g;
   b:=x.c[p].b;
   //set - swap r/b elements
   x.c[p].r:=b;
   x.c[p].g:=g;
   x.c[p].b:=r;
   end;//end of loop
   except;end;
   end;
//START
begin//Note: xe=points to an animation structure for storing timing/framecount information, and is optional
//defaults
result:=false;
try
e:=gecUnexpectedError;
xcellcount:=1;
xcellwidth:=1;
xcellheight:=1;
xtransparent:=false;
xdelay:=100;
xbpp:=8;
tmp:=nil;
imgdata:=nil;
//.check y
if not block(y) then goto skipend;
//.bits
xbits:=misb(x);
if (xbits<>8) and (xbits<>24) and (xbits<>32) then goto skipend;
//WARNING: x must be locked to read pixles BUT also must be unlocked to resize -> so we need to switch between the two - 28jul2021
xmustunlock:=not x.locked;
if xmustunlock then x.lock;

//INIT
ylen:=y.len;
if (ylen<6) then exit;
imgcount:=0;
imglimit:=0;
alltrans:=false;
offx:=0;
pos1:=1;
loops:=0;
delay:=0;
pal:=@gp;
dispose:=0;
lastdispose:=0;
//.static transparent color of "WHITE"
tc24.r:=255;
tc24.g:=255;
tc24.b:=255;
//.control items
bgcolor:=0;
trans:=-1;//not in use
wait:=false;
//GET
//header sig (GIF)
if not y.asame3(pos1-1,[uuG,uuI,uuF],false) then//GIF
   begin
   e:=gecUnknownFormat;
   goto skipend;
   end;//end of if
inc(pos1,3);
e:=gecDataCorrupt;
//version
v87a:=y.asame3(pos1-1,[nn8,nn7,llA],false);
v89a:=y.asame3(pos1-1,[nn8,nn9,llA],false);
inc(pos1,3);
if (not v87a) and (not v89a) then goto skipend;

//screen info
if ((pos1+sizeof(s)-1)>ylen) then goto skipend;
if not y.writeto1(@s,sizeof(s),pos1,sizeof(s)) then goto skipend;//was: tostrucb(@s,sizeof(s),copy(y,pos,sizeof(s)));
inc(pos1,sizeof(s));
//.range
s.w:=frcmin32(s.w,1);
s.h:=frcmin32(s.h,1);
imglimit:=max32;//yyyyyyyyyyyyy [disabled for huge images on 22SEP2009] 21000 div s.w;//safe number of frames (tbitmap.width=22000+ crashes)
//.global color palette - always empty, since we may have to use it even when we shouldn't be
fillchar(gp,sizeof(gp),0);
if ((s.pf and pfGlobalColorTable)=pfGlobalColorTable) then
   begin
   //get
   gp.count:=2 shl (s.pf and pfColorTableSize);
   if (gp.count<2) or (gp.count>256) then
      begin
      e:=gecIndexOutOfRange;
      goto skipend;
      end;//end of if
   //set
   tmp2:=gp.count*sizeof(tcolor24);
   if ((pos1+tmp2-1)>ylen) then goto skipend;
   y.writeto1(@gp.c,tmp2,pos1,tmp2);//was: tostrucb(@gp.c,tmp2,copy(y,pos,tmp2));
   inc(pos1,tmp2);
   end;//end of if
//init
palinit(gp);
//IMAGES
if (pos1>ylen) then goto skipend;
tmp:=bnew;
imgdata:=bnew;
repeat
v:=y.bytes1[pos1];
//scan
if (v=59) then break//terminator
else if (v<>0) then
   begin
   //init
   inc(pos1);
   if (pos1<=ylen) then v2:=y.bytes1[pos1] else v2:=0;
   //blocks
   if (v=33) then
      begin
      //get - multi-length sub-parts (ie. text blocks etc)
      inc(pos1);
      tmp.clear;
      while true do
      begin
      if (pos1<=ylen) then
         begin
         tmp2:=y.bytes1[pos1];
         tmp.add31(y,pos1+1,tmp2);//was: tmp:=tmp+copy(y,pos+1,tmp2);
         if (tmp2=0) then break else inc(pos1,1+tmp2);
         end
      else break;
      end;//end of loop
      if (tmp.len=0) then goto skipone;
      //set
      case v2 of
      249:begin//control - for image handling
         if (tmp.len<4) then goto skipone;
         tmp2:=tmp.bytes1[1];//was: byte(tmp[1]);
         //.defaults
         bgcolor:=0;
         trans:=-1;//not in use
         wait:=false;
         dispose:=0;
         //.dispose mode
         dispose:=byte(frcrange32((tmp2 shl 27) shr 29,0,7));
         //.wait
         if (((tmp2 shl 30) shr 31)>=1) then wait:=true;
         //.bgcolor
         bgcolor:=tmp.bytes1[4];
         //.transparent
         if (((tmp2 shl 31) shr 31)>=1) then trans:=bgcolor;
         //.delay
         inc(delay,frcmin32(tmp.sml2[2-1],0));//was: inc(delay,frcmin32(to16bit(copy(tmp,2,2),true),0));
         end;//end of begin
      255:begin//loop
         loops:=tmp.sml2[tmp.len-1-1];//was: loops:=to16bit(copy(tmp,length(tmp)-1,2),true);
         end;//end of begin
      254:begin//comment
         //ignore
         end;//end of begin
      1:begin//plain text - displayed on image
         //ignore
         end;//end of begin
      end;//end of case
      end
   else if (v=44) then//image
      begin
      //get
      dec(pos1);
      y.writeto1(@id,sizeof(id),pos1,sizeof(id));//was: tostrucb(@id,sizeof(id),copy(y,pos,sizeof(id)));
      inc(pos1,sizeof(id));
      //range
      id.dx:=frcrange32(id.dx,0,s.w);
      id.dy:=frcrange32(id.dy,0,s.h);
      id.w:=frcrange32(id.w,1,s.w);
      id.h:=frcrange32(id.h,1,s.h);
      fillchar(lp,sizeof(lp),0);
      //local palette
      if ((id.pf and idLocalColorTable)=idLocalColorTable) then
         begin
         //get
         lp.count:=2 shl (id.pf and idColorTableSize);
         if (lp.count<2) or (lp.count>256) then
            begin
            e:=gecIndexOutOfRange;
            goto skipend;
            end;//end of if
         //set
         tmp2:=lp.count*sizeof(tcolor24);
         if ((pos1+tmp2-1)>ylen) then goto skipend;
         y.writeto1(@lp.c,tmp2,pos1,tmp2);//was: tostrucb(@lp.c,tmp2,copy(y,pos,tmp2));
         inc(pos1,tmp2);
         //init
         palinit(lp);
         end;//end of if
      if (lp.count=0) then pal:=@gp else pal:=@lp;
      //decompress image
      gif_decompressex(pos1,y,imgdata,id.w,id.h,((id.pf and idInterlaced)<>0));
      //transparency check - if transparent color index is not used, then turn it off!
      ok:=false;
      if (trans>=0) then
         begin
         //check
         v:=byte(trans);
         for p:=1 to imgdata.len do if (v=imgdata.bytes1[p]) then
            begin
            ok:=true;
            break;
            end;//end of if
         if not ok then trans:=-1;
         //image is transparent - therefore entire image is transparent
         if (imgcount=0) and (trans>=0) then alltrans:=true;
         end;//end of if
      //size
      inc(imgcount);
      if ((imgcount*s.w)>x.width) or (x.height<>s.h) then
         begin//size ahead by 5 cells
         //WARNING: Image width is adjusted as we go, so we must USE a BITMAP that retains image rows when resizing - 28jul2021
         x.unlock;
         try
         x.width:=frcmax32(((x.width div nozero(1100133,s.w))+5),imglimit)*s.w;
         if (x.height<>s.h) then x.height:=s.h;
         except;end;
         x.lock;
         end;//if
      //cls
      if (imgcount<=1) then
         begin
         if (trans>=0) then zc24:=tc24 else zc24:=low__nonwhite24(pal.c[bgcolor]);
         for dy:=0 to (s.h-1) do
         begin
         if not misscan82432(x,dy,sr8,sr24,sr32) then goto skipend;
         //.32
         if (xbits=32) then
            begin
            if xuse32 and (trans>=0) then
               begin
               sc32.r:=0;
               sc32.g:=0;
               sc32.b:=0;
               sc32.a:=0;
               end
            else
               begin
               sc32.r:=zc24.r;
               sc32.g:=zc24.g;
               sc32.b:=zc24.b;
               sc32.a:=255;
               end;
            for dx:=0 to (s.w-1) do sr32[offx+dx]:=sc32;
            end
         //.24
         else if (xbits=24) then
            begin
            for dx:=0 to (s.w-1) do sr24[offx+dx]:=zc24;
            end
         //.8
         else if (xbits=8) then
            begin
            sc8:=low__greyscale2(zc24);
            for dx:=0 to (s.w-1) do sr8[offx+dx]:=sc8;
            end;
         end;//dy
         end
      else
         begin
         //init
         if (trans>=0) then zc24:=tc24 else zc24:=low__nonwhite24(pal.c[bgcolor]);
         if (xbits=32) and xuse32 and (trans>=0) then
            begin
            zc32.r:=0;
            zc32.g:=0;
            zc32.b:=0;
            zc32.a:=0;
            end
         else
            begin
            zc32.r:=zc24.r;
            zc32.g:=zc24.g;
            zc32.b:=zc24.b;
            zc32.a:=255;
            end;

{
         zc32.r:=zc24.r;
         zc32.g:=zc24.g;
         zc32.b:=zc24.b;
         zc32.a:=255;
{}//xxxxxxx
         zc8:=low__greyscale2(zc24);
         //get
         for dy:=0 to (s.h-1) do
         begin
         if not misscan82432(x,dy,sr8,sr24,sr32) then goto skipend;
         //.32
         if (xbits=32) then
            begin
            for dx:=0 to (s.w-1) do
            begin
            case lastdispose of
            0,1:begin//graphic left in place
               sc32:=sr32[offx-s.w+dx];
               sr32[offx+dx]:=sc32;
               end;
            2:begin//restore background color - area used by image
               if (dy>=lastrect.top) and (dy<=lastrect.bottom) and (dx>=lastrect.left) and (dx<=lastrect.right) then sr32[offx+dx]:=zc32
               else
                  begin
                  sc32:=sr32[offx-s.w+dx];
                  sr32[offx+dx]:=sc32;
                  end;
               end;
            3:begin//restore to previous image - area used by image
               sc32:=sr32[offx-s.w+dx];
               sr32[offx+dx]:=sc32;
               end;
            end;//case
            end;//dx
            end//32
         //.24
         else if (xbits=24) then
            begin
            for dx:=0 to (s.w-1) do
            begin
            case lastdispose of
            0,1:begin//graphic left in place
               yc24:=sr24[offx-s.w+dx];
               sr24[offx+dx]:=yc24;
               end;
            2:begin//restore background color - area used by image
               if (dy>=lastrect.top) and (dy<=lastrect.bottom) and (dx>=lastrect.left) and (dx<=lastrect.right) then sr24[offx+dx]:=zc24
               else
                  begin
                  yc24:=sr24[offx-s.w+dx];
                  sr24[offx+dx]:=yc24;
                  end;
               end;
            3:begin//restore to previous image - area used by image
               yc24:=sr24[offx-s.w+dx];
               sr24[offx+dx]:=yc24;
               end;
            end;//case
            end;//dx
            end//24
         //.8
         else if (xbits=8) then
            begin
            for dx:=0 to (s.w-1) do
            begin
            case lastdispose of
            0,1:begin//graphic left in place
               sc8:=sr8[offx-s.w+dx];
               sr8[offx+dx]:=sc8;
               end;
            2:begin//restore background color - area used by image
               if (dy>=lastrect.top) and (dy<=lastrect.bottom) and (dx>=lastrect.left) and (dx<=lastrect.right) then sr8[offx+dx]:=zc8
               else
                  begin
                  sc8:=sr8[offx-s.w+dx];
                  sr8[offx+dx]:=sc8;
                  end;
               end;
            3:begin//restore to previous image - area used by image
               sc8:=sr8[offx-s.w+dx];
               sr8[offx+dx]:=sc8;
               end;
            end;//case
            end;//dx
            end;//8
         end;//dy
         end;//if
      //draw
      p:=1;
      len:=imgdata.len;
      for dy:=0 to (id.h-1) do
      begin
      ny:=dy+id.dy;
      if (ny>=0) and (ny<s.h) then
         begin
         if not misscan82432(x,ny,sr8,sr24,sr32) then goto skipend;
         //.32
         if (xbits=32) then
            begin
            for dx:=0 to (id.w-1) do
            begin
            nx:=dx+id.dx;
            if (nx>=0) and (nx<s.w) then
               begin
               ci:=imgdata.bytes1[p];
               if (trans=-1) then
                  begin
                  yc24:=pal.c[ci];//important: must maintain original image data if not transparent - special white/offwhite image cases, any rounding down will cause white+offwhite=>all offwhite which will cause entire area of both colors to be transparent if the "transparent" option is then used - 17SEP2007
                  sc32.r:=yc24.r;
                  sc32.g:=yc24.g;
                  sc32.b:=yc24.b;
                  sc32.a:=255;
                  sr32[offx+nx]:=sc32;
                  end
               else if (ci<>trans) then
                  begin
                  yc24:=low__nonwhite24(pal.c[ci]);
                  sc32.r:=yc24.r;
                  sc32.g:=yc24.g;
                  sc32.b:=yc24.b;
                  sc32.a:=255;
                  sr32[offx+nx]:=sc32;
                  end;
               end;//if
            //inc
            inc(p);
            //quit
            if (p>len) then break;
            end;//dx
            end//32
         //.24
         else if (xbits=24) then
            begin
            for dx:=0 to (id.w-1) do
            begin
            nx:=dx+id.dx;
            if (nx>=0) and (nx<s.w) then
               begin
               ci:=imgdata.bytes1[p];
               if (trans=-1) then sr24[offx+nx]:=pal.c[ci]//important: must maintain original image data if not transparent - special white/offwhite image cases, any rounding down will cause white+offwhite=>all offwhite which will cause entire area of both colors to be transparent if the "transparent" option is then used - 17SEP2007
               else if (ci<>trans) then sr24[offx+nx]:=low__nonwhite24(pal.c[ci]);
               end;//if
            //inc
            inc(p);
            //quit
            if (p>len) then break;
            end;//dx
            end//24
         //.8
         else if (xbits=8) then
            begin
            for dx:=0 to (id.w-1) do
            begin
            nx:=dx+id.dx;
            if (nx>=0) and (nx<s.w) then
               begin
               ci:=imgdata.bytes1[p];
               if (trans=-1) then
                  begin
                  sc8:=low__greyscale2(pal.c[ci]);//important: must maintain original image data if not transparent - special white/offwhite image cases, any rounding down will cause white+offwhite=>all offwhite which will cause entire area of both colors to be transparent if the "transparent" option is then used - 17SEP2007
                  sr8[offx+nx]:=sc8;
                  end
               else if (ci<>trans) then
                  begin
                  sc8:=low__greyscale2b(low__nonwhite24(pal.c[ci]));
                  sr8[offx+nx]:=sc8;
                  end;
               end;//if
            //inc
            inc(p);
            //quit
            if (p>len) then break;
            end;//dx
            end;//8
         end;//ny

      if (p>len) then break;
      end;//end of loop
      //enforce top-left corner transparency (only if entire animation is transparent)
      if alltrans and (trans>=0) then
         begin
         if not misscan82432(x,0,sr8,sr24,sr32) then goto skipend;
         //.32
         if (xbits=32) then
            begin
            if not xuse32 then
               begin
               sc32.r:=tc24.r;
               sc32.g:=tc24.g;
               sc32.b:=tc24.b;
               sc32.a:=255;
               sr32[offx]:=sc32;
               end;
            end
         //.24
         else if (xbits=24) then sr24[offx]:=tc24
         //.8
         else if (xbits=8) then
            begin
            sc8:=low__greyscale2b(tc24);
            sr32[offx]:=sc32;
            end;
         end;//if
      //inc
      inc(offx,s.w);
      dec(pos1);
      //last
      lastdispose:=dispose;
      lastrect:=rect(id.dx,id.dy,frcmax32(id.dx+id.w-1,s.w-1),frcmax32(id.dy+id.h-1,s.h-1));
      //frame limit
      if (imgcount>=imglimit) then break;//safe number of frames
      end
   else if (v=59) then break//terminator
   else break;//unknown
   end;//end of if
skipone:
//inc
inc(pos1);
until (pos1>ylen);
//trim
if (imgcount<>0) and (x<>nil) then
   begin
   x.unlock;
   try;x.width:=(imgcount*s.w);except;end;
   x.lock;
   end;
//animation information --------------------------------------------------------
//range - max. number of frames-per-second=50 (20ms)...[delay=0=>20ms or 50fps]
if (imgcount>=1) then
   begin
   delay:=frcmin32((delay div nozero(1100134,imgcount))*10,0);//ave. units => ave. ms
   //.default is 100ms
   if (delay<=0) then delay:=100;
   end;//end of if
//set
xdelay:=frcmin32(delay,1);//28jul2021
xcellcount:=frcmin32(imgcount,1);
xcellwidth:=frcmin32(s.w,1);
xcellheight:=frcmin32(s.h,1);
xtransparent:=alltrans;;
xdelay:=frcmin32(delay,1);
case gp.count of
2:xbpp:=2;
3..16:xbpp:=4;
17..256:xbpp:=8;
end;//case
//.store a copy onboard "tbitmapenhanced" - 28jul2021
misai(x).delay:=xdelay;
misai(x).count:=xcellcount;
misai(x).cellwidth:=xcellwidth;
misai(x).cellheight:=xcellheight;
misai(x).transparent:=xtransparent;
misai(x).bpp:=xbpp;
//successful
result:=true;
skipend:
except;end;
try
if (x<>nil) and xmustunlock then x.unlock;
bfree(tmp);
bfree(imgdata);
bunlockautofree(y);
except;end;
end;
//## togif ##
function low__togif(x:tobject;y:tstr8;var e:string):boolean;//11SEP2007
begin
result:=false;try;result:=low__togif2(x,clnone,y,e);except;end;
end;
//## low__togif2 ##
function low__togif2(x:tobject;xtranscol:longint;y:tstr8;var e:string):boolean;//11SEP2007
begin
result:=false;try;result:=low__togif3(x,xtranscol,true,false,y,e);except;end;
end;
//## low__togif3 ##
function low__togif3(x:tobject;xtranscol:longint;xlocalpalettes,xuse32:boolean;y:tstr8;var e:string):boolean;//31dec2022 - fixed bad [0,59] terminator, 14may2022 - now supports 32bit mask channel for transparency, 22sep2021 (now supports localpalettes - each cell of an animation has it's own separate color palette), 11SEP2007
label//writes v89a GIF's
   skipend;
const
   //main flags
   pfGlobalColorTable	= $80;		{ set if global color table follows L.S.D. }
   pfColorResolution	= $70;		{ Color resolution - 3 bits }
   pfSort		= $08;		{ set if global color table is sorted - 1 bit }
   pfColorTableSize	= $07;		{ size of global color table - 3 bits }
   //local - image des
   idLocalColorTable	= $80;    { set if a local color table follows }
   idInterlaced		= $40;    { set if image is interlaced }
   idSort		= $20;    { set if color table is sorted }
   idReserved		= $0C;    { reserved - must be set to $00 }
   idColorTableSize	= $07;    { size of color table as above }
var
   z:tstr8;
   e2:string;
   xhasai,xtransparent:boolean;
   xdelay,xbits,xw,xh,palcount,dpalcount,ccount,cw,ch,nx,ny,offx,len,dy,dx,delay,loops,i,p,p2,tmp2,pos:longint;
   flags:byte;
   s:tgifscreen;
   pal:array[0..255] of tcolor24;
   lpal:array[0..255] of tcolor24;
   id:tgifimgdes;
   sr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc8:tcolor8;
   yc,zc,tc:tcolor24;
   sc32:tcolor32;
   lastrect:trect;
   trans:boolean;
   //## palfind ##
   function palfind(var z:tcolor24):byte;
   var
      p:longint;
   begin
   result:=0;
   try
   //defaults
   result:=frcmax32(1,palcount-1);//avoid "item.0" if we can as it is reserved for transparent pixels - 23JAN2012
   //scan
   if xlocalpalettes then
      begin
      for p:=0 to (palcount-1) do if (lpal[p].r=z.r) and (lpal[p].g=z.g) and (lpal[p].b=z.b) then
         begin
         result:=byte(p);
         break;
         end;
      end
   else
      begin
      for p:=0 to (palcount-1) do if (pal[p].r=z.r) and (pal[p].g=z.g) and (pal[p].b=z.b) then
         begin
         result:=byte(p);
         break;
         end;
      end;
   except;end;
   end;
   //## low__transwhite ##
   function low__transwhite(x:tobject;var e:string):boolean;//prepare a multi-cell imagestrip, ensuring all [0,0] pixel corners are "black" if transparent and all black must be [1,1,1] or higher
   label
      skipend;
   var//Note: White is reserved for transparent information
      xhasai:boolean;
      xbits,xw,xh,ccount,cw,ch,delay,p,dy,dx,offx:longint;
      sc8:tcolor8;
      zc,tc,white,offwhite:tcolor24;
      white32,offwhite32:tcolor32;
      sc32:tcolor32;
      sr8:pcolorrow8;
      sr24:pcolorrow24;
      sr32:pcolorrow32;
   begin
   //defaults
   result:=false;
   try
   e:=gecUnexpectedError;
   ccount:=1;
   //check
   if not miscells(x,xbits,xw,xh,ccount,cw,ch,delay,xhasai,xtransparent) then goto skipend;
   if (xbits<>8) and (xbits<>24) and (xbits<>32) then goto skipend;
   if (xtranscol<>clnone) then xtransparent:=true;//09sep2021
   //init
   //.white
   white.r:=255;
   white.g:=255;
   white.b:=255;
   //.white32
   white32.r:=255;
   white32.g:=255;
   white32.b:=255;
   white32.a:=255;
   //.offwhite
   offwhite.r:=254;
   offwhite.g:=254;
   offwhite.b:=254;
   //.offwhite32
   offwhite32.r:=254;
   offwhite32.g:=254;
   offwhite32.b:=254;
   offwhite32.a:=255;
   //get
   e:=gecOutOfMemory;
   for p:=1 to ccount do
   begin
   offx:=(p-1)*cw;
   //y
   for dy:=0 to (ch-1) do
   begin
   if not misscan82432(x,dy,sr8,sr24,sr32) then goto skipend;
   if (dy=0) and (not xuse32) then
      begin
      if (xtranscol=clTopLeft) then tc:=mispixel24(x,dy,offx)
      else if (xtranscol<>clnone) then tc:=low__intrgb(xtranscol)
      else tc:=mispixel24(x,dy,offx);//was: tc:=r[offx]; - 09sep2021
      //transparent color is already WHITE, so there is nothing to do
      if (tc.r=white.r) and (tc.g=white.g) and (tc.b=white.b) then break;
      end;//end of if
   //get
   //.8
   if (xbits=8) then
      begin
      for dx:=0 to (cw-1) do
      begin
      sc8:=sr8[offx+dx];
      //.swap pixel to transparent color (as defined by 0,0 pixel of cell)
      if (sc8=tc.r) then sc8:=white.r
      //.pixel is white, but not transparent - swap to offwhite (non-transparent white)
      else if (sc8=white.r) then sc8:=offwhite.r;
      //.set
      sr8[offx+dx]:=sc8;
      end;//dx
      end//8
   //.24
   else if (xbits=24) then
      begin
      for dx:=0 to (cw-1) do
      begin
      zc:=sr24[offx+dx];
      //.swap pixel to transparent color (as defined by 0,0 pixel of cell)
      if (zc.r=tc.r) and (zc.g=tc.g) and (zc.b=tc.b) then zc:=white
      //.pixel is white, but not transparent - swap to offwhite (non-transparent white)
      else if (zc.r=white.r) and (zc.g=white.g) and (zc.b=white.b) then zc:=offwhite;
      //.set
      sr24[offx+dx]:=zc;
      end;//dx
      end//24
   //.32
   else if (xbits=32) then
      begin
      if xuse32 then//14may2022
         begin
         for dx:=0 to (cw-1) do
         begin
         sc32:=sr32[offx+dx];
         //.swap pixel to transparent color (as defined by 0,0 pixel of cell)
         if (sc32.a=0) then sc32:=white32
         //.pixel is white, but not transparent - swap to offwhite (non-transparent white)
         else if (sc32.r=white.r) and (sc32.g=white.g) and (sc32.b=white.b) then sc32:=offwhite32;
         //.set
         sr32[offx+dx]:=sc32;
         end;//dx
         end
      else
         begin
         for dx:=0 to (cw-1) do
         begin
         sc32:=sr32[offx+dx];
         //.swap pixel to transparent color (as defined by 0,0 pixel of cell)
         if (sc32.r=tc.r) and (sc32.g=tc.g) and (sc32.b=tc.b) then sc32:=white32
         //.pixel is white, but not transparent - swap to offwhite (non-transparent white)
         else if (sc32.r=white.r) and (sc32.g=white.g) and (sc32.b=white.b) then sc32:=offwhite32;
         //.set
         sr32[offx+dx]:=sc32;
         end;//dx
         end;
      end;//32
   end;//end of loop - y
   end;//end of loop - p (all cells)

   //successful
   result:=true;
   skipend:
   except;end;
   end;
begin
//defaults
result:=false;
try
e:=gecUnexpectedError;
z:=nil;

//lock
if not block(y) then exit;
//check
if not miscells(x,xbits,xw,xh,ccount,cw,ch,xdelay,xhasai,xtransparent) then goto skipend;
if xuse32 and (xbits<>32) then xuse32:=false;//14may2022
if (xbits<>8) and (xbits<>24) and (xbits<>32) then goto skipend;
if (xtranscol<>clnone) or (xuse32 and (xbits=32)) then xtransparent:=true;//14may2022, 09sep2021
//.turn off local palletes for static images and single cell animations - 22sep2021
if xlocalpalettes and (ccount<=1) then xlocalpalettes:=false;

//init
y.clear;
z:=bnew;
flags:=0;
delay:=0;
trans:=false;
palcount:=0;
dpalcount:=0;
fillchar(pal,sizeof(pal),0);//23JAN2012
if xhasai or xtransparent then
   begin
   delay:=frcmin32(xdelay div 10,2);//20ms or larger (50fps)
   if xtransparent then
      begin
      inc(flags);//1=transparent
      trans:=true;
      end;
   inc(flags,8);//remove-by background
   end;

//init
if (xw<=0) or (xh<=0) or (ccount<=0) then exit;
//INIT
//.enforces transparent color as "WHITE", do this even if the image is not transparent - keep consistent
if trans and (not low__transwhite(x,e)) then goto skipend;

//.build palette - 09sep2021, 22JAN2012
case xlocalpalettes of
true:begin
   //.count colors only -> do not reduce
   if not mislimitcolors82432ex(x,0,cw,low__rgb(255,255,255),high(pal)+1,true,false,pal,palcount,e) then goto skipend;
   palcount:=256;//localpalettes assumes FULL palette consumption (e.g. global palette is NOT used, but included) - 22sep2021
   end;
false:if not mislimitcolors82432(x,low__rgb(255,255,255),high(pal)+1,true,pal,palcount,e) then goto skipend;
end;//case

case palcount of
0..2:dpalcount:=2;
3..16:dpalcount:=16;
else dpalcount:=256;
end;

//HEADER
y.aadd([uuG,uuI,uuF,nn8,nn9,lla]);//was: pushb(ylen,y,'GIF89a');
//screen info
fillchar(s,sizeof(s),0);
s.w:=cw;
s.h:=ch;
//.palette size - 22JAN2012
case dpalcount of
2:s.pf:=176;
16:s.pf:=179;
else s.pf:=183;//183=256PAL,NOT-SORTED [247=SORTED]
end;

//was: pushb(ylen,y,fromstruc(@s,sizeof(s)));
y.addwrd2(s.w);
y.addwrd2(s.h);
y.addbyt1(s.pf);
y.addbyt1(s.bgi);
y.addbyt1(s.ar);

//global palette - fixed at 2, 16 or 256 colors - 23JAN2012
//was: for p:=0 to (dpalcount-1) do pushb(ylen,y,char(pal[p].r)+char(pal[p].g)+char(pal[p].b));
for p:=0 to (dpalcount-1) do
begin
y.addbyt1(pal[p].r);
y.addbyt1(pal[p].g);
y.addbyt1(pal[p].b);
end;//p


//LOOP       //unknown code block [78..3..1]                       //0=loop forever
//was: if (ccount>=2) then pushb(ylen,y,#33#255#11#78#69#84#83#67#65#80#69#50#46#48#3#1+from16bit(0,true)+#0);
if (ccount>=2) then
   begin
   y.aadd([33,255,11,78,69,84,83,67,65,80,69,50,46,48,3,1]);
   y.addsmi2(0);
   y.addbyt1(0);
   end;


//IMAGES
for p:=1 to ccount do
begin
//img-control [ext,imgctrl,4bytes]+[trans=v1,wait=v2,(dispose=v0..3used, v4..7 resv)
//dispose modes(0=nothing=>0, 1=leave-as-is=>4, 2=background=>8, 3=previous-image=>12
//.value=transparent1 and/or background8 = 1,8 or 9
                      //flags + delay + transparent-color-index (fixed at ZERO for us)+#0terminator
//was: pushb(ylen,y,#33#249#4+char(flags)+from16bit(delay,true)+#0#0);
y.aadd([33,249,4]);
y.addbyt1(flags);
y.addsmi2(delay);//***********************
y.aadd([0,0]);


//img-des - Note: pf=0 (no local color table, not interlaced, not sorted)
fillchar(id,sizeof(id),0);
id.sep:=44;
id.w:=cw;
id.h:=ch;
//was: pushb(ylen,y,fromstruc(@id,sizeof(id)));
y.addbyt1(id.sep);
y.addwrd2(id.dx);
y.addwrd2(id.dy);
y.addwrd2(id.w);
y.addwrd2(id.h);
//if xlocalpalettes then id.pf:=idLocalColorTable;//+idColorTableSize;//only for local palette support - 22sep2021

offx:=(p-1)*s.w;

//.build local palette
if xlocalpalettes then
   begin
   //.create local palette - 22sep2021
   //Note: palcount=actual number of colors in palette -> this is NOT store in the GIF as it can differ / internal reference only - 22sep2021
   if not mislimitcolors82432ex(x,offx,cw,low__rgb(255,255,255),high(pal)+1,true,true,lpal,palcount,e) then goto skipend;

   case palcount of
   0..2:dpalcount:=2;
   3..16:dpalcount:=16;
   else dpalcount:=256;
   end;

   case dpalcount of
   2:inc(id.pf,176);
   16:inc(id.pf,179);
   else inc(id.pf,183);//183=256PAL,NOT-SORTED [247=SORTED]
   end;

   y.addbyt1(id.pf);//bit fields

   //.store local palette - 22sep2021
   for p2:=0 to (dpalcount-1) do
   begin
   y.addbyt1(lpal[p2].r);
   y.addbyt1(lpal[p2].g);
   y.addbyt1(lpal[p2].b);
   end;//p
   end
else y.addbyt1(id.pf);//bit fields

//IMAGE DATA
z.setlen(cw*ch);//was: setlength(z,cw*ch);
i:=1;
for dy:=0 to (ch-1) do
begin
if not misscan82432(x,dy,sr8,sr24,sr32) then goto skipend;
//.8
if (xbits=8) then
   begin
   for dx:=0 to (cw-1) do
   begin
   sc8:=sr8[dx+offx];
   zc.r:=sc8;
   zc.g:=sc8;
   zc.b:=sc8;
   z.pbytes[i-1]:=palfind(zc);//r-b elements are reversed in pal items
   inc(i);
   end;//dx
   end
//.24
else if (xbits=24) then
   begin
   for dx:=0 to (cw-1) do
   begin
   zc:=sr24[dx+offx];
   z.pbytes[i-1]:=palfind(zc);//r-b elements are reversed in pal items
   inc(i);
   end;//dx
   end
//.32
else if (xbits=32) then
   begin
   for dx:=0 to (cw-1) do
   begin
   sc32:=sr32[dx+offx];
   zc.r:=sc32.r;
   zc.g:=sc32.g;
   zc.b:=sc32.b;
   z.pbytes[i-1]:=palfind(zc);//r-b elements are reversed in pal items
   inc(i);
   end;//dx
   end;
end;//dy

//compressed image data
if not gif_compress(z,e2) then
   begin
   e:=e2;
   goto skipend;
   end;//end of if
y.add(z);//was: pushb(ylen,y,z);
z.clear;
end;//p

//terminator
//was: y.aadd([0,59]);//was: pushb(ylen,y,#0#59);
y.aadd([59]);//fixed 31dec2022

//successful
result:=true;
skipend:
except;end;
try
bfree(z);
bunlockautofree(y);
except;end;
end;

{$else}

//## low__fromgif ##
function low__fromgif(x:tbmp;y:tstr8;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
var
   xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;
   xtransparent:boolean;
begin
result:=false;try;result:=low__fromgif2(x,y,xcellcount,xcellwidth,xcellheight,xdelay,xbpp,xtransparent,e);except;end;
end;
//## low__fromgif ##
function low__fromgif1(x:tbmp;y:tstr8;xuse32:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
var
   xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;
   xtransparent:boolean;
begin
result:=false;try;result:=low__fromgif3(x,y,xcellcount,xcellwidth,xcellheight,xdelay,xbpp,xuse32,xtransparent,e);except;end;
end;
//## low__fromgif2 ##
function low__fromgif2(x:tbmp;y:tstr8;var xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;var xtransparent:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
begin
result:=false;try;result:=low__fromgif3(x,y,xcellcount,xcellwidth,xcellheight,xdelay,xbpp,false,xtransparent,e);except;end;
end;
//## low__fromgif3 ##
function low__fromgif3(x:tbmp;y:tstr8;var xcellcount,xcellwidth,xcellheight,xdelay,xbpp:longint;xuse32:boolean;var xtransparent:boolean;var e:string):boolean;//28jul2021, 20JAN2012, 22SEP2009
begin
result:=false;
try
e:=gecUnexpectederror;
xcellcount:=1;
xcellwidth:=1;
xcellheight:=1;
xdelay:=500;
xbpp:=8;
xtransparent:=false;
except;end;
end;
//## low__togif ##
function low__togif(x:tobject;y:tstr8;var e:string):boolean;//11SEP2007
begin
result:=false;try;result:=low__togif2(x,clnone,y,e);except;end;
end;
//## low__togif2 ##
function low__togif2(x:tobject;xtranscol:longint;y:tstr8;var e:string):boolean;//permit transparent color override - 09sep2021, 11SEP2007
begin
result:=false;try;result:=low__togif3(x,xtranscol,true,false,y,e);except;end;
end;
//## low__togif3 ##
function low__togif3(x:tobject;xtranscol:longint;xlocalpalettes,xuse32:boolean;y:tstr8;var e:string):boolean;//14may2022 - now supports 32bit mask channel for transparency, 22sep2021 (now supports localpalettes - each cell of an animation has it's own separate color palette), 11SEP2007
begin
result:=false;
e:=gecUnknownformat;
try;str__autofree(@y);except;end;
end;
{$endif}
//-- GIF end -------------------------------------------------------------------


{$ifdef gif2}
//## gif_start ##
function gif_start(dcore:tstr8;dw,dh:longint;dloop:boolean;xsmartwrite24:tbasicimage):boolean;
const
   //main flags
   pfGlobalColorTable	= $80;		{ set if global color table follows L.S.D. }
   pfColorResolution	= $70;		{ Color resolution - 3 bits }
   pfSort		= $08;		{ set if global color table is sorted - 1 bit }
   pfColorTableSize	= $07;		{ size of global color table - 3 bits }
   //local - image des
   idLocalColorTable	= $80;    { set if a local color table follows }
   idInterlaced		= $40;    { set if image is interlaced }
   idSort		= $20;    { set if color table is sorted }
   idReserved		= $0C;    { reserved - must be set to $00 }
   idColorTableSize	= $07;    { size of color table as above }
var
   s:tgifscreen;
   p:longint;
begin
//defaults
result:=false;
try
//check
if not block(dcore) then exit;
//range
dw:=frcrange32(dw,1,maxword);
dh:=frcrange32(dh,1,maxword);
//init
dcore.clear;
dcore.tag1:=dw;//store screen width and height - 27dec2022
dcore.tag2:=dh;
dcore.tag3:=0;//cell count
//get --------------------------------------------------------------------------
//header
dcore.aadd([uuG,uuI,uuF,nn8,nn9,lla]);//was: pushb(ylen,y,'GIF89a');
//screen info - no global palette - 31dec2022
fillchar(s,sizeof(s),0);
s.w:=dw;
s.h:=dh;

//was: pushb(ylen,y,fromstruc(@s,sizeof(s)));
dcore.addwrd2(s.w);
dcore.addwrd2(s.h);
dcore.addbyt1(s.pf);
dcore.addbyt1(s.bgi);
dcore.addbyt1(s.ar);

//loop       //unknown code block [78..3..1]                       //0=loop forever
if dloop then
   begin
   dcore.aadd([33,255,11,78,69,84,83,67,65,80,69,50,46,48,3,1]);
   dcore.addsmi2(0);
   dcore.addbyt1(0);
   end;

//xsmartwrite24
if (xsmartwrite24<>nil) and misokk24(xsmartwrite24) then
   begin
   missize(xsmartwrite24,dw,dh);
   miscls(xsmartwrite24,0);
   end;
//successful
result:=true;
except;end;
try
bunlockautofree(dcore);
except;end;
end;
//## gif_stop ##
function gif_stop(dcore:tstr8):boolean;
begin
//defaults
result:=false;
try
//check
if not block(dcore) then exit;
if (dcore.len>=12)   then
   begin
   //write the terminator code "0,59" - 27dec2022
//was:   dcore.aadd([0,59]); <- this is wrong, should have just been a single [59] value as per GIF89a format spec - 31dec2022
   dcore.aadd([59]);//fixed - 31dec2022
   //successful
   result:=true;
   end;
except;end;
try;bunlockautofree(dcore);except;end;
end;
//## gif_add ##
function gif_add(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite:boolean):boolean;
begin
result:=false;try;result:=gif_add2(dcore,s,sdelay,strancol2,xoverwrite,nil);except;end;
end;
//## gif_add2 ##
function gif_add2(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite:boolean;xsmartwrite24:tbasicimage):boolean;
begin
result:=false;try;result:=gif_add3(dcore,s,sdelay,strancol2,xoverwrite,false,xsmartwrite24);except;end;
end;
//## gif_add3 ##
function gif_add3(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite,xwritefullframe:boolean;xsmartwrite24:tbasicimage):boolean;
label//Note: We keep white (255,255,255) as the internal transparent color even when using 32bit images - 27dec2022
     //Note: Uses transparency info when (sbits=32) via alpha channel BUT can additionally make "strancol2" colors transparent, useful for 8/24bit images
     //Note: "xsmartwrite=true" requires a valid image to be provided in "slast"
     //Note: relies on "xsmartwrite=true" in which case when "xwritefullframe=true" the xsmartwrite24 buffer fill fully filled with "s" and an entire intact frame is written to stream - 05jan2023
   skipend;
var
   ddata:tstr8;
   sx,sy,p,stranscol,lcount,dcount,dpalcount,ddelay,sbits,sw,sh,lbits,lw,lh:longint;
   dflags:byte;
   dfirst,dtrans,xsmartwrite:boolean;
   ddes:tgifimgdes;
   dpal:array[0..255] of tcolor24;
   sr32:pcolorrow32;
   sr24:pcolorrow24;
   sr8 :pcolorrow8;
   dr24:pcolorrow24;
   d24:tbasicimage;
   lr24:pcolorrow24;
   c32:tcolor32;
   c24:tcolor24;
   l24:tcolor24;
   stranscol24:tcolor24;
   snottrans24:tcolor24;
   strancol2_24:tcolor24;
   strancol2_24OK:boolean;
   v:byte;
   e:string;
   //## palfind ##
   function palfind(var z:tcolor24):byte;
   var
      p:longint;
   begin
   //defaults
   result:=1;//frcmax32(1,dpalcount-1);//avoid "item.0" if we can as it is reserved for transparent pixels - 23JAN2012
   //scan
   for p:=0 to (dpalcount-1) do if (dpal[p].r=z.r) and (dpal[p].g=z.g) and (dpal[p].b=z.b) then
      begin
      result:=byte(p);
      break;
      end;
   end;
begin
//defaults
result:=false;
try
d24:=nil;
ddata:=nil;

//check
if not block(dcore) then exit;
if (dcore.len<12) or (dcore.tag1<=0) or (dcore.tag2<=0) then goto skipend;
if not misok82432(s,sbits,sw,sh) then goto skipend;
//range
sw:=frcmax32(frcrange32(sw,1,maxword),dcore.tag1);
sh:=frcmax32(frcrange32(sh,1,maxword),dcore.tag2);

//init
inc(dcore.tag3);

//.smartwrite
xsmartwrite:=(xsmartwrite24<>nil) and misok82432(xsmartwrite24,lbits,lw,lh) and (lbits=24) and (lw>=sw) and (lh>=sh);

//.static transparent color of WHITE - used internally - 27dec2022
stranscol24:=low__rgb24(255,255,255);
snottrans24:=low__rgb24(254,254,254);
stranscol:=low__rgb(stranscol24.r,stranscol24.g,stranscol24.b);
strancol2_24OK:=false;
if (strancol2<>clnone) then
   begin
   strancol2_24OK:=true;
   if (strancol2=clTopLeft) then strancol2_24:=mispixel24(s,0,0)
   else                          strancol2_24:=low__intrgb(strancol2);
   end;

//.other
fillchar(dpal,sizeof(dpal),0);
dpalcount:=0;
dtrans:=false;
dflags:=0;

//Note: Does a "delay=0" produce a multi-image 1st frame for preview systems => NO - 05jan2023
ddelay:=frcrange32(sdelay div 10,0,32767);//20ms or larger (50fps)
dcount:=frcmin32(dcore.tag3,0);
lcount:=dcount;
if xwritefullframe then lcount:=0;

//if xsmartwrite and xwritefullframe then miscls(xsmartwrite24,low__rgbint(stranscol24));


//image convert
d24:=misimg24(sw,sh);
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
if not misscan24(d24,sy,dr24)           then goto skipend;
if xsmartwrite and (not misscan24(xsmartwrite24,sy,lr24)) then goto skipend;

//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   //get
   c32:=sr32[sx];
   if (c32.a>=1) then
      begin
      c24.r:=c32.r;
      c24.g:=c32.g;
      c24.b:=c32.b;
      if strancol2_24OK and (c24.r=strancol2_24.r) and (c24.g=strancol2_24.g) and (c24.b=strancol2_24.b) then
         begin
         c24:=stranscol24;//make this color transparent - optional
         dtrans:=true;
         end
      else if (c24.r=stranscol24.r) and (c24.g=stranscol24.g) and (c24.b=stranscol24.b) then c24:=snottrans24;//can't use white -> we've reserved this for internal transparency -> use an off-white instead "snottrans24" - 27dec2022
      end
   else
      begin
      c24:=stranscol24;
      dtrans:=true;
      end;
   //smartwrite
   if xsmartwrite then
      begin
      l24:=lr24[sx];
      if (lcount>=2) and (l24.r=c24.r) and (l24.g=c24.g) and (l24.b=c24.b) then
         begin
         c24:=stranscol24;
         dtrans:=true;
         end
      else lr24[sx]:=c24;
      end;
   //set
   dr24[sx]:=c24;
   end;//sx
   end
//.24
else if (sbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   //get
   c24:=sr24[sx];
   if strancol2_24OK and (c24.r=strancol2_24.r) and (c24.g=strancol2_24.g) and (c24.b=strancol2_24.b) then
      begin
      c24:=stranscol24;//make this color transparent - optional
      dtrans:=true;
      end
   else if (c24.r=stranscol24.r) and (c24.g=stranscol24.g) and (c24.b=stranscol24.b) then c24:=snottrans24;//can't use white -> we've reserved this for internal transparency -> use an off-white instead "snottrans24" - 27dec2022
   //smartwrite
   if xsmartwrite then
      begin
      l24:=lr24[sx];
      if (lcount>=2) and (l24.r=c24.r) and (l24.g=c24.g) and (l24.b=c24.b) then
         begin
         c24:=stranscol24;
         dtrans:=true;
         end
      else lr24[sx]:=c24;
      end;
   //set
   dr24[sx]:=c24;
   end;//sx
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   //get
   c24.r:=sr8[sx];
   c24.g:=c24.r;
   c24.b:=c24.r;
   if strancol2_24OK and (c24.r=strancol2_24.r) and (c24.g=strancol2_24.g) and (c24.b=strancol2_24.b) then
      begin
      c24:=stranscol24;//make this color transparent - optional
      dtrans:=true;
      end
   else if (c24.r=stranscol24.r) and (c24.g=stranscol24.g) and (c24.b=stranscol24.b) then c24:=snottrans24;//can't use white -> we've reserved this for internal transparency -> use an off-white instead "snottrans24" - 27dec2022
   //smartwrite
   if xsmartwrite then
      begin
      l24:=lr24[sx];
      if (lcount>=2) and (l24.r=c24.r) and (l24.g=c24.g) and (l24.b=c24.b) then
         begin
         c24:=stranscol24;
         dtrans:=true;
         end
      else lr24[sx]:=c24;
      end;
   //set
   dr24[sx]:=c24;
   end;//sx
   end;
end;//sy

//image flags
if xsmartwrite and (dcore.tag3<=1) then dtrans:=false;//no transparency on first frame of animation -> other frames use transparency to paint only the required sections
if dtrans then inc(dflags);//1=transparent

//.flags - 0=nothing, 4=leave as is, 8=clear background, 12=previous image
if xsmartwrite     then inc(dflags,4)
else if xoverwrite then inc(dflags,4) //4=leave as is (overwrite previous pixels)
else                    inc(dflags,8);//8=clear background and write new pixels

//image header
dcore.aadd([33,249,4]);
dcore.addbyt1(dflags);
dcore.addsmi2(ddelay);
dcore.aadd([0,0]);

//image information - Note: pf=0 (no local color table, not interlaced, not sorted)
fillchar(ddes,sizeof(ddes),0);
ddes.sep:=44;
ddes.w:=sw;
ddes.h:=sh;
ddes.dx:=0;
ddes.dy:=0;
dcore.addbyt1(ddes.sep);//2C = OK
dcore.addwrd2(ddes.dx);
dcore.addwrd2(ddes.dy);
dcore.addwrd2(ddes.w);
dcore.addwrd2(ddes.h);

//image palette -> do it FAST - 27dec2022
if not mislimitcolors82432ex(d24,0,sw,stranscol,high(dpal)+1,true,true,dpal,dpalcount,e) then goto skipend;

//.restric palette count
case dpalcount of
0..2:dpalcount:=2;
3..16:dpalcount:=16;
else dpalcount:=256;
end;

//.store palette flag
case dpalcount of
2:dcore.addbyt1(176);
16:dcore.addbyt1(179);
else dcore.addbyt1(183);//183=256PAL,NOT-SORTED [247=SORTED]
end;

//.store local palette colors - 22sep2021
for p:=0 to (dpalcount-1) do
begin
dcore.addbyt1(dpal[p].r);
dcore.addbyt1(dpal[p].g);
dcore.addbyt1(dpal[p].b);
end;//p

//image data
ddata:=bnew;
ddata.setlen(sw*sh);//was: setlength(z,cw*ch);
p:=1;
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan24(d24,sy,dr24) then goto skipend;
//.sx
for sx:=0 to (sw-1) do
begin
c24:=dr24[sx];
ddata.pbytes[p-1]:=palfind(c24);//r-b elements are reversed in pal items
inc(p);
end;//sx
end;//sy
//.compress image data
{$ifdef gif}
if not gif_compress(ddata,e) then goto skipend;
{$else}
goto skipend;
{$endif}
//.append image data
dcore.add(ddata);

//successful
result:=true;
skipend:
except;end;
try
freeobj(@d24);
bfree(ddata);
bunlockautofree(dcore);
except;end;
end;
{$else}
//## gif_start ##
function gif_start(dcore:tstr8;dw,dh:longint;dloop:boolean;xsmartwrite24:tbasicimage):boolean;
begin
result:=false;
end;
//## gif_stop ##
function gif_stop(dcore:tstr8):boolean;
begin
result:=false;
end;
//## gif_add ##
function gif_add(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite:boolean):boolean;
begin
result:=false;
end;
//## gif_add2 ##
function gif_add2(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite:boolean;xsmartwrite24:tbasicimage):boolean;
begin
result:=false;
end;
//## gif_add3 ##
function gif_add3(dcore:tstr8;s:tbasicimage;sdelay,strancol2:longint;xoverwrite,xwritefullframe:boolean;xsmartwrite24:tbasicimage):boolean;
begin
result:=false;
end;
{$endif}


//mask support -----------------------------------------------------------------
//## mask__empty ##
function mask__empty(s:tobject):boolean;
var
   xmin,xmax:longint;
begin
result:=true;
if mask__range(s,xmin,xmax) then result:=(xmax<=0);
end;
//## mask__transparent ##
function mask__transparent(s:tobject):boolean;
var
   v0,v255,vother:boolean;
   xmin,xmax:longint;
begin
result:=false;try;result:=mask__range2(s,v0,v255,vother,xmin,xmax) and (not v255);except;end;
end;
//## mask__range ##
function mask__range(s:tobject;var xmin,xmax:longint):boolean;//15feb2022
var
   v0,v255,vother:boolean;
begin
result:=false;try;result:=mask__range2(s,v0,v255,vother,xmin,xmax);except;end;
end;
//## mask__range2 ##
function mask__range2(s:tobject;var v0,v255,vother:boolean;var xmin,xmax:longint):boolean;//15feb2022
label
   skipend;
var
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
   v:byte;
begin
//defaults
result:=false;
try
v0:=false;
v255:=false;
vother:=false;
xmin:=255;
xmax:=0;
//check
if not misok82432(s,sbits,sw,sh) then exit;
//get
//.24
if (sbits=24) then
   begin
   xmin:=255;
   xmax:=255;
   v255:=true;
   result:=true;
   goto skipend;
   end;
//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   v:=sr32[sx].a;
   if (v>xmax) then xmax:=v;
   if (v<xmin) then xmin:=v;
   case v of
   0   :v0:=true;
   255 :v255:=true;
   else vother:=true;
   end;//case
   end;//sx
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   v:=sr8[sx];
   if (v>xmax) then xmax:=v;
   if (v<xmin) then xmin:=v;
   case v of
   0   :v0:=true;
   255 :v255:=true;
   else vother:=true;
   end;//case
   end;//sx
   end;
//check
if (xmin<=0) and (xmax>=255) and v0 and v255 and vother then break;
end;//sy
//successful
result:=true;
skipend:
except;end;
end;
//## mask__maxave ##
function mask__maxave(s:tobject):longint;//0..255
label
   skipend;
var
   dtotal,dcount:comp;
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
begin
//defaults
result:=0;
try
dtotal:=0;
dcount:=0;
//check
if not misok82432(s,sbits,sw,sh) then exit;
//get
//.24
if (sbits=24) then
   begin
   result:=255;
   goto skipend;
   end;
//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do dtotal:=dtotal+sr32[sx].a;
   dcount:=dcount+sw;
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do dtotal:=dtotal+sr8[sx];
   dcount:=dcount+sw;
   end;
end;//sy
skipend:
//.finalise
if (dcount>=1) then result:=frcrange32(restrict32(div64(dtotal,dcount)),0,255);
except;end;
end;
//## mask__setval ##
function mask__setval(s:tobject;xval:longint):boolean;
label
   skipend;
var
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
   v:byte;
begin
//defaults
result:=false;
try
//check
if not misok82432(s,sbits,sw,sh) then exit;
//.24
if (sbits=24) then//ignore
   begin
   result:=true;
   goto skipend;
   end;
//range
v:=frcrange32(xval,0,255);
//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do sr32[sx].a:=v;
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do sr8[sx]:=v;
   end;
end;//dy
//successful
result:=true;
skipend:
except;end;
end;
//## mask__copy ##
function mask__copy(s,d:tobject):boolean;//15feb2022
begin
result:=false;try;result:=mask__copy3(s,d,clnone,-1);except;end;
end;
//## mask__copy2 ##
function mask__copy2(s,d:tobject;stranscol:longint):boolean;
begin
result:=false;try;result:=mask__copy3(s,d,stranscol,-1);except;end;
end;
//## mask__copy3 ##
function mask__copy3(s,d:tobject;stranscol,sremove:longint):boolean;
label//extracts 8bit alpha from d32 and copies it to a8
     //note: strancols adds transparency to existing mask as it copies it over
     //note: sremove=0..255 = removes original mask as its copied over
   skipend;
var
   tr,tg,tb,sx,sy,sw,sh,sbits,dbits,dw,dh:longint;
   sr8,dr8:pcolorrow8;
   sr24,dr24:pcolorrow24;
   sr32,dr32:pcolorrow32;
   sc32:tcolor32;
   sc24:tcolor24;
   sc8:tcolor8;
begin
//defaults
result:=false;
try
//check
if not misok82432(s,sbits,sw,sh) then exit;
if not misok82432(d,dbits,dw,dh) then exit;
if (sw>dw) or (sh>dh) then exit;
//init
tr:=-1;
tg:=-1;
tb:=-1;
stranscol:=mistranscol(s,stranscol,stranscol<>clnone);
if (stranscol<>clnone) then
   begin
   sc24:=low__intrgb(stranscol);
   tr:=sc24.r;
   tg:=sc24.g;
   tb:=sc24.b;
   end;
//.sremove
if (sremove=clnone) then sremove:=-1;//off
sremove:=frcrange32(sremove,-1,255);//-1=off
//get
//.dy
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
if not misscan82432(d,sy,dr8,dr24,dr32) then goto skipend;
//.32 + 32
if (sbits=32) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc32:=sr32[sx];
   if (tr=sc32.r) and (tg=sc32.g) and (tb=sc32.b) then dr32[sx].a:=0
   else if (sremove>=0)                           then dr32[sx].a:=byte(sremove)
   else                                                dr32[sx].a:=sc32.a;
   end;//sx
   end
//.32 + 24
else if (sbits=32) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.32 + 8
else if (sbits=32) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc32:=sr32[sx];
   if (tr=sc32.r) and (tg=sc32.g) and (tb=sc32.b) then dr8[sx]:=0
   else if (sremove>=0)                           then dr8[sx]:=byte(sremove)
   else                                                dr8[sx]:=sc32.a;
   end;//sx
   end
//.24 + 32
else if (sbits=24) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc24:=sr24[sx];
   if (tr=sc24.r) and (tg=sc24.g) and (tb=sc24.b) then dr32[sx].a:=0
   else                                                dr32[sx].a:=255;
   end;//sx
   end
//.24 + 24
else if (sbits=24) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.24 + 8
else if (sbits=24) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc24:=sr24[sx];
   if (tr=sc24.r) and (tg=sc24.g) and (tb=sc24.b) then dr8[sx]:=0
   else                                                dr8[sx]:=255;
   end;//sx
   end
//.8 + 32
else if (sbits=8) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc8:=sr8[sx];
   sc32:=dr32[sx];
   if (tr=sc32.r) and (tg=sc32.g) and (tb=sc32.b) then dr32[sx].a:=0
   else if (sremove>=0) then                           dr32[sx].a:=byte(sremove)
   else                                                dr32[sx].a:=sc8;
   end;//sx
   end
//.8 + 24
else if (sbits=8) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.8 + 8
else if (sbits=8) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc8:=sr8[sx];
   if (sremove>=0) then dr8[sx]:=byte(sremove)
   else                 dr8[sx]:=sc8;
   end;//sx
   end;
end;//dy
//successful
result:=true;
skipend:
except;end;
end;
//## mask__copymin ##
function mask__copymin(s,d:tobject):boolean;//15feb2022
label
   skipend;
var
   sx,sy,sw,sh,sbits,dbits,dw,dh:longint;
   sr8,dr8:pcolorrow8;
   sr24,dr24:pcolorrow24;
   sr32,dr32:pcolorrow32;
   sv,dv:tcolor8;
begin
//defaults
result:=false;
try
//check
if not misok82432(s,sbits,sw,sh) then exit;
if not misok82432(d,dbits,dw,dh) then exit;
if (sw>dw) or (sh>dh) then exit;
if (s=d) then
   begin
   result:=true;
   exit;
   end;
//get
//.dy
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
if not misscan82432(d,sy,dr8,dr24,dr32) then goto skipend;
//.32 + 32
if (sbits=32) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr32[sx].a;
   dv:=dr32[sx].a;
   if (dv<sv) then sv:=dv;
   dr32[sx].a:=sv;
   end;//sx
   end
//.32 + 24
else if (sbits=32) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.32 + 8
else if (sbits=32) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr32[sx].a;
   dv:=dr8[sx];
   if (dv<sv) then sv:=dv;
   dr8[sx]:=sv;
   end;//sx
   end
//.24 + 32
else if (sbits=24) and (dbits=32) then
   begin
   result:=true;
   goto skipend;
   end
//.24 + 24
else if (sbits=24) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.24 + 8
else if (sbits=24) and (dbits=8) then
   begin
   result:=true;
   goto skipend;
   end
//.8 + 32
else if (sbits=8) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr8[sx];
   dv:=dr32[sx].a;
   if (dv<sv) then sv:=dv;
   dr32[sx].a:=sv;
   end;//sx
   end
//.8 + 24
else if (sbits=8) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.8 + 8
else if (sbits=8) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr8[sx];
   dv:=dr8[sx];
   if (dv<sv) then sv:=dv;
   dr8[sx]:=sv;
   end;//sx
   end;
end;//dy
//successful
result:=true;
skipend:
except;end;
end;
//## mask__setopacity ##
function mask__setopacity(s:tobject;xopacity255:longint):boolean;//06jun2021
label
   skipend;
var
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
   sv,v8:byte;
begin
//defaults
result:=false;
try
//check
if not misok82432(s,sbits,sw,sh) then exit;
//range
v8:=frcrange32(xopacity255,0,255);
//.nothing to do -> ignore
if (v8=255) then
   begin
   result:=true;
   exit;
   end;
//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr32[sx].a;
   if (sv>=1) then
      begin
      sv:=(sv*v8) div 255;
      if (sv<=0) then sv:=1;
      sr32[sx].a:=sv;
      end;
   end;//sx
   end
//.24
else if (sbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr8[sx];
   if (sv>=1) then
      begin
      sv:=(sv*v8) div 255;
      if (sv<=0) then sv:=1;
      sr8[sx]:=sv;
      end;
   end;//sx
   end;
end;//sy
//successful
result:=true;
skipend:
except;end;
end;
//## mask__multiple ##
function mask__multiple(s:tobject;xby:currency):boolean;//18sep2022
label
   skipend;
var
   sv,sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
begin
//defaults
result:=false;
try
//check
if not misok82432(s,sbits,sw,sh) then exit;
//.nothing to do -> ignore
if (xby=1) or (xby<0) then exit;
//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr32[sx].a;
   if (sv>=1) then
      begin
      sv:=round(sv*xby);
      if (sv<=0) then sv:=1 else if (sv>255) then sv:=255;
      sr32[sx].a:=byte(sv);
      end;
   end;//sx
   end
//.24
else if (sbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sv:=sr8[sx];
   if (sv>=1) then
      begin
      sv:=round(sv*xby);
      if (sv<=0) then sv:=1 else if (sv>255) then sv:=255;
      sr8[sx]:=byte(sv);
      end;
   end;//sx
   end;
end;//sy
//successful
result:=true;
skipend:
except;end;
end;
//## mask__feather ##
function mask__feather(s,d:tobject;sfeather,stranscol:longint;var xouttranscol:longint):boolean;//20jan2021
begin
result:=false;try;result:=mask__feather2(s,d,sfeather,stranscol,false,xouttranscol);except;end;
end;
//## mask__feather2 ##
function mask__feather2(s,d:tobject;sfeather,stranscol:longint;stransframe:boolean;var xouttranscol:longint):boolean;//15feb2022, 18jun2021, 08jun2021, 20jan2021
label//sfeather:  -1=asis, 0=none(sharp), 1=feather(1px/blur), 2=feather(2px/blur), 3=feather(1px), 4=feather(2px)
     //stranscol: clnone=solid (no see thru parts), clTopLeft=pixel(0,0), else=user specified color
   doasis,dosolid,dofeather,doblur,skipdone,skipend;
const
   xfeather1=110;//more inline with a sine curve - 20jan2021
   xfeather2=30;
var
   xlist:array[0..255] of longint;//used to cache a feather curve that drifts off towards zero for more effective edge softening - 20jan2021
   srows8,drows8:pcolorrows8;
   srows24,drows24:pcolorrows24;
   srows32,drows32:pcolorrows32;
   sr8,dr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32,dr32:pcolorrow32;
   ac8,sc8:tcolor8;
   ac24,sc24:tcolor24;
   ac32,sc32:tcolor32;
   xlen,ylen,xylen,xshortlen,dval,fx,fy,xfeather,i,dv,dc,sbits,sw,sh,dbits,dw,dh,sxx,sx,sy:longint;
   fval:byte;
   tr,tg,tb:longint;
   xinitrows8OK,tok,xblur,xalternate:boolean;
   //## xinitrows832 ##
   procedure xinitrows832;
   begin
   if xinitrows8OK then exit;
   misrows82432(d,drows8,drows24,drows32);
   xinitrows8OK:=true;
   end;
   //## drect832 ##
   procedure drect832(dx,dy,dx2,dy2,dval:longint);
   var
      sx,sy:longint;
   begin
   //range
   if (dval<=0) then dval:=1 else if (dval>=255) then dval:=254;//never 0 or 255
   //check
   if (dx2<dx) or (dy2<dy) or (dx<0) or (dx>=sw) or (dy<0) or (dy>=sh) or (dx2<0) or (dx2>=sw) or (dy2<0) or (dy2>=sh) then exit;
   //.32
   if (dbits=32) then
      begin
      for sx:=dx to dx2 do drows32[dy][sx].a:=byte(dval);//top
      for sx:=dx to dx2 do drows32[dy2][sx].a:=byte(dval);//bottom
      for sy:=dy to dy2 do drows32[sy][dx].a:=byte(dval);//left
      for sy:=dy to dy2 do drows32[sy][dx2].a:=byte(dval);//right
      end
   //.8
   else if (dbits=8) then
      begin
      for sx:=dx to dx2 do drows8[dy][sx]:=byte(dval);//top
      for sx:=dx to dx2 do drows8[dy2][sx]:=byte(dval);//bottom
      for sy:=dy to dy2 do drows8[sy][dx]:=byte(dval);//left
      for sy:=dy to dy2 do drows8[sy][dx2]:=byte(dval);//right
      end;
   end;
begin
//defaults
result:=false;
try
xinitrows8OK:=false;
xouttranscol:=clnone;
//init
if not misok82432(s,sbits,sw,sh) then exit;
if not misok82432(d,dbits,dw,dh) then
   begin
   //special case: allow "s32" to write to own mask e.g. "s32.mask" - 15feb2022
   if (d=nil) and (sbits=32) then
      begin
      d:=s;
      dbits:=sbits;
      dw:=sw;
      dh:=sh;
      end
   else exit;
   end;
if (sw>dw) or (sh>dh) then exit;

//feather
xfeather:=frcrange32(sfeather,-1,100);//-1=asis
xblur:=(xfeather>=1);

//.force sharp feather when transparent color is specified - 17jan2021
if (xfeather<0) and (stranscol<>clnone) then xfeather:=0;

//.feather curve -> used for feathers 3px+
if (xfeather>=1) and (not miscurveAirbrush2(xlist,high(xlist)+1,0,255,false,false)) then goto skipend;

//transcol
tr:=-1;
tg:=-1;
tb:=-1;
tok:=false;//no transparency -> solid
if (xfeather>=0) and (stranscol<>clnone) then
   begin
   //.ok
   tok:=true;
   if not misfindtranscol82432ex(s,stranscol,tr,tg,tb) then goto skipend;
   xouttranscol:=low__rgb(tr,tg,tb);
   end;

//decide
if (xfeather=-1)  then goto doasis
else if not tok   then goto dosolid
else                   goto dofeather;

//asis -------------------------------------------------------------------------
doasis:
//get
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
if not misscan832(d,sy,dr8,dr32) then goto skipend;

//.32 + 32 + (s=d)
if (sbits=32) and (dbits=32) and (s=d) then
   begin
   result:=true;
   goto skipend;
   end
//.32 + 32
else if (sbits=32) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc8:=sr32[sx].a;
   dr32[sx].a:=sc8;
   end;//sx
   end
//.32 + 24
else if (sbits=32) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.32 + 8
else if (sbits=32) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc8:=sr32[sx].a;
   dr8[sx]:=sc8;
   end;//sx
   end
//.24 + 32
else if (sbits=24) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do dr32[sx].a:=255;
   end
//.24 + 24
else if (sbits=24) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.24 + 8
else if (sbits=24) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do dr8[sx]:=255;
   end
//.8 + 32
else if (sbits=8) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc8:=sr8[sx];
   dr32[sx].a:=sc8;
   end;//sx
   end
//.8 + 24
else if (sbits=8) and (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.8 + 8
else if (sbits=8) and (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   sc8:=sr8[sx];
   dr8[sx]:=sc8;
   end;//sx
   end;
end;//sy
goto skipdone;


//solid ------------------------------------------------------------------------
dosolid:
//cls
for sy:=0 to (sh-1) do
begin
if not misscan832(d,sy,dr8,dr32) then goto skipend;
//.32
if (dbits=32) then
   begin
   for sx:=0 to (sw-1) do dr32[sx].a:=255;
   end
//.24
else if (dbits=24) then
   begin
   result:=true;
   goto skipend;
   end
//.8
else if (dbits=8) then
   begin
   for sx:=0 to (sw-1) do dr8[sx]:=255;
   end;
end;//sy
//get
xinitrows832;
case xfeather of
1..2:begin
   for sx:=0 to (xfeather-1) do
   begin
   if (xfeather=1) then dval:=xfeather1
   else if (sx=0) then dval:=xfeather2 else dval:=xfeather1;

   drect832(sx,sx,sw-1-sx,sh-1-sx,dval);
   end;//sx
   end;
3..max32:begin
   for sx:=0 to (xfeather-1) do drect832(sx,sx,sw-1-sx,sh-1-sx,xlist[round((sx/xfeather)*255)]);
   end;
end;//case
//.blur
goto doblur;


//feather ----------------------------------------------------------------------
dofeather:

//init
if (xfeather>=1) and (not misrows82432(s,srows8,srows24,srows32)) then goto skipend;

//get
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
if not misscan832(d,sy,dr8,dr32) then goto skipend;

case xfeather of
//sharp
0:begin
   //.32 + 32
   if (sbits=32) and (dbits=32) then
      begin
      for sx:=0 to (sw-1) do
      begin
      sc32:=sr32[sx];
      if (tr=sc32.r) and (tg=sc32.g) and (tb=sc32.b) then dr32[sx].a:=0 else dr32[sx].a:=255;
      end;//sx
      end
   //.32 + 24
   else if (sbits=32) and (dbits=24) then
      begin
      goto skipend;
      result:=true;
      end
   //.32 + 8
   else if (sbits=32) and (dbits=8) then
      begin
      for sx:=0 to (sw-1) do
      begin
      sc32:=sr32[sx];
      if (tr=sc32.r) and (tg=sc32.g) and (tb=sc32.b) then dr8[sx]:=0 else dr8[sx]:=255;
      end;//sx
      end
   //.24 + 32
   else if (sbits=24) and (dbits=32) then
      begin
      for sx:=0 to (sw-1) do
      begin
      sc24:=sr24[sx];
      if (tr=sc24.r) and (tg=sc24.g) and (tb=sc24.b) then dr32[sx].a:=0 else dr32[sx].a:=255;
      end;//sx
      end
   //.24 + 24
   else if (sbits=24) and (dbits=24) then
      begin
      result:=true;
      goto skipend;
      end
   //.24 + 8
   else if (sbits=24) and (dbits=8) then
      begin
      for sx:=0 to (sw-1) do
      begin
      sc24:=sr24[sx];
      if (tr=sc24.r) and (tg=sc24.g) and (tb=sc24.b) then dr8[sx]:=0 else dr8[sx]:=255;
      end;//sx
      end
   //.8 + 32
   else if (sbits=8) and (dbits=32) then
      begin
      for sx:=0 to (sw-1) do
      begin
      sc8:=sr8[sx];
      if (tr=sc8) then dr32[sx].a:=0 else dr32[sx].a:=255;
      end;//sx
      end
   //.8 + 24
   else if (sbits=8) and (dbits=24) then
      begin
      result:=true;
      goto skipend;
      end
    //.8 + 8
   else if (sbits=8) and (dbits=8) then
      begin
      for sx:=0 to (sw-1) do
      begin
      sc8:=sr8[sx];
      if (tr=sc8) then dr8[sx]:=0 else dr8[sx]:=255;
      end;//sx
      end;
   end;//begin
//slow feather -----------------------------------------------------------------
3..max32:begin
   //.32 + 32/24/8
   if (sbits=32) then
      begin
      for sx:=0 to (sw-1) do
      begin
      //init
      sc32:=sr32[sx];
      dval:=0;
      //get
      if (tr<>sc32.r) or (tg<>sc32.g) or (tb<>sc32.b) then
         begin
         //init
         dval:=255;
         xshortlen:=xfeather+1;
         //.fy
         for fy:=(sy-xfeather) to (sy+xfeather) do
         begin
         if (fy>=0) and (fy<sh) then
            begin
            //.y len
            ylen:=fy-sy;
            if (ylen<0) then ylen:=-ylen;
            //.fx
            for fx:=(sx-xfeather) to (sx+xfeather) do
            begin
            if (fx>=0) and (fx<sw) and ((fx<>sx) or (fy<>sy)) then
               begin
               //get
               ac32:=srows32[fy][fx];
               if ((tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b)) or (stransframe and ( (fx<=0) or (fx>=(sw-1)) or (fy<=0) or (fy>=(sh-1)) ) ) then
                  begin
                  //get
                  //.x len
                  xlen:=fx-sx;
                  if (xlen<0) then xlen:=-xlen;
                  //.yx len
                  xylen:=trunc(sqrt((xlen*xlen)+(ylen*ylen)));
                  if (xylen<xshortlen) then xshortlen:=xylen;
                  if (xshortlen<1) then xshortlen:=1;
                  if (xshortlen<=1) then break;
                  end;//tr -> ac32
               end;
            end;//fx
            end;
         //check
         if (xshortlen<=1) then break;
         end;//fy
         //set
         if (xshortlen<(xfeather+1)) then
            begin
            dval:=round((xshortlen/(xfeather+1))*255);
            //.curve the feather
            if (dval<0) then dval:=0 else if (dval>255) then dval:=255;
            dval:=xlist[dval];
            //.limit the feather to visible shades (not 0=off, not 255=solid)
            if (dval<=0) then dval:=1 else if (dval>=255) then dval:=254;//never 0 or 255
            end;
         end;//tr -> sc32
      //set
      case dbits of
      32:dr32[sx].a:=dval;
      24:begin
         result:=true;
         goto skipend;
         end;
      8:dr8[sx]:=dval;
      end;//case
      end;//sx
      end//32
   //.24 + 32/24/8
   else if (sbits=24) then
      begin
      for sx:=0 to (sw-1) do
      begin
      //init
      sc24:=sr24[sx];
      dval:=0;
      //get
      if (tr<>sc24.r) or (tg<>sc24.g) or (tb<>sc24.b) then
         begin
         //init
         dval:=255;
         xshortlen:=xfeather+1;
         //.fy
         for fy:=(sy-xfeather) to (sy+xfeather) do
         begin
         if (fy>=0) and (fy<sh) then
            begin
            //.y len
            ylen:=fy-sy;
            if (ylen<0) then ylen:=-ylen;
            //.fx
            for fx:=(sx-xfeather) to (sx+xfeather) do
            begin
            if (fx>=0) and (fx<sw) and ((fx<>sx) or (fy<>sy)) then
               begin
               //get
               ac24:=srows24[fy][fx];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then
                  begin
                  //get
                  //.x len
                  xlen:=fx-sx;
                  if (xlen<0) then xlen:=-xlen;
                  //.yx len
                  xylen:=trunc(sqrt((xlen*xlen)+(ylen*ylen)));
                  if (xylen<xshortlen) then xshortlen:=xylen;
                  if (xshortlen<1) then xshortlen:=1;
                  if (xshortlen<=1) then break;
                  end;//tr -> ac24
               end;
            end;//fx
            end;
         //check
         if (xshortlen<=1) then break;
         end;//fy
         //set
         if (xshortlen<(xfeather+1)) then
            begin
            dval:=round((xshortlen/(xfeather+1))*255);
            //.curve the feather
            if (dval<0) then dval:=0 else if (dval>255) then dval:=255;
            dval:=xlist[dval];
            //.limit the feather to visible shades (not 0=off, not 255=solid)
            if (dval<=0) then dval:=1 else if (dval>=255) then dval:=254;//never 0 or 255
            end;
         end;//tr -> sc24
      //set
      case dbits of
      32:dr32[sx].a:=dval;
      24:begin
         result:=true;
         goto skipend;
         end;
      8:dr8[sx]:=dval;
      end;//case
      end;//sx
      end//24
   //.8 + 32/24/8
   else if (sbits=8) then
      begin
      for sx:=0 to (sw-1) do
      begin
      //init
      sc8:=sr8[sx];
      dval:=0;
      //get
      if (tr<>sc8) then
         begin
         //init
         dval:=255;
         xshortlen:=xfeather+1;
         //.fy
         for fy:=(sy-xfeather) to (sy+xfeather) do
         begin
         if (fy>=0) and (fy<sh) then
            begin
            //.y len
            ylen:=fy-sy;
            if (ylen<0) then ylen:=-ylen;
            //.fx
            for fx:=(sx-xfeather) to (sx+xfeather) do
            begin
            if (fx>=0) and (fx<sw) and ((fx<>sx) or (fy<>sy)) then
               begin
               //get
               ac8:=srows8[fy][fx];
               if (tr=ac8) then
                  begin
                  //get
                  //.x len
                  xlen:=fx-sx;
                  if (xlen<0) then xlen:=-xlen;
                  //.yx len
                  xylen:=trunc(sqrt((xlen*xlen)+(ylen*ylen)));
                  if (xylen<xshortlen) then xshortlen:=xylen;
                  if (xshortlen<1) then xshortlen:=1;
                  if (xshortlen<=1) then break;
                  end;//tr -> ac24
               end;
            end;//fx
            end;
         //check
         if (xshortlen<=1) then break;
         end;//fy
         //set
         if (xshortlen<(xfeather+1)) then
            begin
            dval:=round((xshortlen/(xfeather+1))*255);
            //.curve the feather
            if (dval<0) then dval:=0 else if (dval>255) then dval:=255;
            dval:=xlist[dval];
            //.limit the feather to visible shades (not 0=off, not 255=solid)
            if (dval<=0) then dval:=1 else if (dval>=255) then dval:=254;//never 0 or 255
            end;
         end;//tr -> sc24
      //set
      case dbits of
      32:dr32[sx].a:=dval;
      24:begin
         result:=true;
         goto skipend;
         end;
      8:dr8[sx]:=dval;
      end;//case
      end;//sx
      end;//8
   end;
//------------------------------------------------------------------------------
//fast feather 1 & 2 -> eat into image edge -> feather works in on solid parts of image -> never extends -> original color image remains unaltered - 12jan2021
1..2:begin
   //.8 + 32/24/8
   if (sbits=8) then
      begin
      for sx:=0 to (sw-1) do
      begin
      //init
      sc8:=sr8[sx];
      dval:=0;
      //get
      if (tr<>sc8) then
         begin
         //init
         dval:=255;
         if (xfeather=1) then fval:=xfeather1 else fval:=xfeather2;
         //stransframe
         if stransframe then
            begin
            //feather 1
            if ((sx-1)<=0) or ((sx+1)>=(sw-1)) then dval:=fval
            else if ((sy-1)<=0) or ((sy+1)>=(sh-1)) then dval:=fval;
            //feather 2
            if (dval=255) and (xfeather=2) then
               begin
               if ((sx-2)<=0) or ((sx+2)>=(sw-1)) then dval:=xfeather1
               else if ((sy-2)<=0) or ((sy+2)>=(sh-1)) then dval:=xfeather1;
               end;
            end;
         //x-1
         if (dval=255) and (sx>=1) then
            begin
            ac8:=srows8[sy][sx-1];
            if (tr=ac8) then dval:=fval;
            end;
         //x+1
         if (dval=255) and (sx<(sw-1)) then
            begin
            ac8:=srows8[sy][sx+1];
            if (tr=ac8) then dval:=fval;
            end;
         //y-1
         if (dval=255) and (sy>=1) then
            begin
            ac8:=srows8[sy-1][sx];
            if (tr=ac8) then dval:=fval;
            end;
         //y+1
         if (dval=255) and (sy<(sh-1)) then
            begin
            ac8:=srows8[sy+1][sx];
            if (tr=ac8) then dval:=fval;
            end;

         //.feather 2
         if (xfeather=2) and (dval=255) then
            begin
            //x-2
            if (dval=255) and (sx>=2) then
               begin
               ac8:=srows8[sy][sx-2];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //x+2
            if (dval=255) and (sx<(sw-2)) then
               begin
               ac8:=srows8[sy][sx+2];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //x-1,y-1
            if (dval=255) and (sx>=1) and (sy>=1) then
               begin
               ac8:=srows8[sy-1][sx-1];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //x+1,y-1
            if (dval=255) and (sx<(sw-1)) and (sy>=1) then
               begin
               ac8:=srows8[sy-1][sx+1];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //y-2
            if (dval=255) and (sy>=2) then
               begin
               ac8:=srows8[sy-2][sx];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //x-1,y+1
            if (dval=255) and (sx>=1) and (sy<(sh-1)) then
               begin
               ac8:=srows8[sy+1][sx-1];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //x+1,y+1
            if (dval=255) and (sx<(sw-1)) and (sy<(sh-1)) then
               begin
               ac8:=srows8[sy+1][sx+1];
               if (tr=ac8) then dval:=xfeather1;
               end;
            //y+2
            if (dval=255) and (sy<(sh-2)) then
               begin
               ac8:=srows8[sy+2][sx];
               if (tr=ac8) then dval:=xfeather1;
               end;
            end;//feather2
         end;//tr
      //set
      case dbits of
      32:dr32[sx].a:=dval;
      24:begin
         result:=true;
         goto skipend;
         end;
      8:dr8[sx]:=dval;
      end;//case
      end;//sx
      end//s8
   //.24 + 32/24/8
   else if (sbits=24) then
      begin
      for sx:=0 to (sw-1) do
      begin
      //init
      sc24:=sr24[sx];
      dval:=0;
      //get
      if (tr<>sc24.r) or (tg<>sc24.g) or (tb<>sc24.b) then
         begin
         //init
         dval:=255;
         if (xfeather=1) then fval:=xfeather1 else fval:=xfeather2;
         //stransframe
         if stransframe then
            begin
            //feather 1
            if ((sx-1)<=0) or ((sx+1)>=(sw-1)) then dval:=fval
            else if ((sy-1)<=0) or ((sy+1)>=(sh-1)) then dval:=fval;
            //feather 2
            if (dval=255) and (xfeather=2) then
               begin
               if ((sx-2)<=0) or ((sx+2)>=(sw-1)) then dval:=xfeather1
               else if ((sy-2)<=0) or ((sy+2)>=(sh-1)) then dval:=xfeather1;
               end;
            end;
         //x-1
         if (dval=255) and (sx>=1) then
            begin
            ac24:=srows24[sy][sx-1];
            if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=fval;
            end;
         //x+1
         if (dval=255) and (sx<(sw-1)) then
            begin
            ac24:=srows24[sy][sx+1];
            if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=fval;
            end;
         //y-1
         if (dval=255) and (sy>=1) then
            begin
            ac24:=srows24[sy-1][sx];
            if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=fval;
            end;
         //y+1
         if (dval=255) and (sy<(sh-1)) then
            begin
            ac24:=srows24[sy+1][sx];
            if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=fval;
            end;

         //.feather 2
         if (xfeather=2) and (dval=255) then
            begin
            //x-2
            if (dval=255) and (sx>=2) then
               begin
               ac24:=srows24[sy][sx-2];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //x+2
            if (dval=255) and (sx<(sw-2)) then
               begin
               ac24:=srows24[sy][sx+2];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //x-1,y-1
            if (dval=255) and (sx>=1) and (sy>=1) then
               begin
               ac24:=srows24[sy-1][sx-1];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //x+1,y-1
            if (dval=255) and (sx<(sw-1)) and (sy>=1) then
               begin
               ac24:=srows24[sy-1][sx+1];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //y-2
            if (dval=255) and (sy>=2) then
               begin
               ac24:=srows24[sy-2][sx];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //x-1,y+1
            if (dval=255) and (sx>=1) and (sy<(sh-1)) then
               begin
               ac24:=srows24[sy+1][sx-1];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //x+1,y+1
            if (dval=255) and (sx<(sw-1)) and (sy<(sh-1)) then
               begin
               ac24:=srows24[sy+1][sx+1];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            //y+2
            if (dval=255) and (sy<(sh-2)) then
               begin
               ac24:=srows24[sy+2][sx];
               if (tr=ac24.r) and (tg=ac24.g) and (tb=ac24.b) then dval:=xfeather1;
               end;
            end;//feather2
         end;//tr
      //set
      case dbits of
      32:dr32[sx].a:=dval;
      24:begin
         result:=true;
         goto skipend;
         end;
      8:dr8[sx]:=dval;
      end;//case
      end;//sx
      end//s24
   //.32 + 32/24/8
   else if (sbits=32) then
      begin
      for sx:=0 to (sw-1) do
      begin
      //init
      sc32:=sr32[sx];
      dval:=0;
      //get
      if (tr<>sc32.r) or (tg<>sc32.g) or (tb<>sc32.b) then
         begin
         //init
         dval:=255;
         if (xfeather=1) then fval:=xfeather1 else fval:=xfeather2;
         //stransframe
         if stransframe then
            begin
            //feather 1
            if ((sx-1)<=0) or ((sx+1)>=(sw-1)) then dval:=fval
            else if ((sy-1)<=0) or ((sy+1)>=(sh-1)) then dval:=fval;
            //feather 2
            if (dval=255) and (xfeather=2) then
               begin
               if ((sx-2)<=0) or ((sx+2)>=(sw-1)) then dval:=xfeather1
               else if ((sy-2)<=0) or ((sy+2)>=(sh-1)) then dval:=xfeather1;
               end;
            end;
         //x-1
         if (dval=255) and (sx>=1) then
            begin
            ac32:=srows32[sy][sx-1];
            if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=fval;
            end;
         //x+1
         if (dval=255) and (sx<(sw-1)) then
            begin
            ac32:=srows32[sy][sx+1];
            if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=fval;
            end;
         //y-1
         if (dval=255) and (sy>=1) then
            begin
            ac32:=srows32[sy-1][sx];
            if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=fval;
            end;
         //y+1
         if (dval=255) and (sy<(sh-1)) then
            begin
            ac32:=srows32[sy+1][sx];
            if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=fval;
            end;

         //.feather 2
         if (xfeather=2) and (dval=255) then
            begin
            //x-2
            if (dval=255) and (sx>=2) then
               begin
               ac32:=srows32[sy][sx-2];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //x+2
            if (dval=255) and (sx<(sw-2)) then
               begin
               ac32:=srows32[sy][sx+2];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //x-1,y-1
            if (dval=255) and (sx>=1) and (sy>=1) then
               begin
               ac32:=srows32[sy-1][sx-1];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //x+1,y-1
            if (dval=255) and (sx<(sw-1)) and (sy>=1) then
               begin
               ac32:=srows32[sy-1][sx+1];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //y-2
            if (dval=255) and (sy>=2) then
               begin
               ac32:=srows32[sy-2][sx];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //x-1,y+1
            if (dval=255) and (sx>=1) and (sy<(sh-1)) then
               begin
               ac32:=srows32[sy+1][sx-1];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //x+1,y+1
            if (dval=255) and (sx<(sw-1)) and (sy<(sh-1)) then
               begin
               ac32:=srows32[sy+1][sx+1];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            //y+2
            if (dval=255) and (sy<(sh-2)) then
               begin
               ac32:=srows32[sy+2][sx];
               if (tr=ac32.r) and (tg=ac32.g) and (tb=ac32.b) then dval:=xfeather1;
               end;
            end;//feather2
         end;//tr
      //set
      case dbits of
      32:dr32[sx].a:=dval;
      24:begin
         result:=true;
         goto skipend;
         end;
      8:dr8[sx]:=dval;
      end;//case
      end;//sx
      end;//s32
   end;//begin
end;//case
end;//sy

//.blur
goto doblur;


//blur -------------------------------------------------------------------------
doblur:
//check
if (xfeather<=0) or (not xblur) then goto skipdone;//xfeather=0=sharp(no feather, hence nothing to blur)

//init
xinitrows832;

//get -> blur x2 for both "feather 1" and "feather 2" for best most consistent results - 12jan2021
xalternate:=true;
for i:=0 to frcmin32((xfeather div 5),1) do
begin
xalternate:=not xalternate;
for sy:=0 to (sh-1) do
begin
//.32
if (dbits=32) then
   begin
   for sxx:=0 to (sw-1) do
   begin
   if xalternate then sx:=sw-1-sxx else sx:=sxx;
   dv:=drows32[sy][sx].a;
   if (dv>=1) then//only adjust existing feather -> do not grow it outside of the scope of the image - 11jan2021
      begin
      dc:=1;
      //3x3
      //x-1
      if (sx>=1) then
         begin
         inc(dv,drows32[sy][sx-1].a);
         inc(dc);
         end;
      //x+1
      if (sx<(sw-1)) then
         begin
         inc(dv,drows32[sy][sx+1].a);
         inc(dc);
         end;
      //y-1
      if (sy>=1) then
         begin
         inc(dv,drows32[sy-1][sx].a);
         inc(dc);
         end;
      //y+1
      if (sy<(sh-1)) then
         begin
         inc(dv,drows32[sy+1][sx].a);
         inc(dc);
         end;
      //enlarge to a 5x5 - 20jan2021
      if (xfeather>=3) then
         begin
         //x-2
         if (sx>=2) then
            begin
            inc(dv,drows32[sy][sx-2].a);
            inc(dc);
            end;
         //x+2
         if (sx<(sw-2)) then
            begin
            inc(dv,drows32[sy][sx+2].a);
            inc(dc);
            end;
         //x-1,y-1
         if (sx>=1) and (sy>=1) then
            begin
            inc(dv,drows32[sy-1][sx-1].a);
            inc(dc);
            end;
         //x+1,y-1
         if (sx<(sw-1)) and (sy>=1) then
            begin
            inc(dv,drows32[sy-1][sx+1].a);
            inc(dc);
            end;
         //y-2
         if (sy>=2) then
            begin
            inc(dv,drows32[sy-2][sx].a);
            inc(dc);
            end;
         //x-1,y+1
         if (sx>=1) and (sy<(sh-1)) then
            begin
            inc(dv,drows32[sy+1][sx-1].a);
            inc(dc);
            end;
         //x+1,y+1
         if (sx<(sw-1)) and (sy<(sh-1)) then
            begin
            inc(dv,drows32[sy+1][sx+1].a);
            inc(dc);
            end;
         //y+2
         if (sy<(sh-2)) then
            begin
            inc(dv,drows32[sy+2][sx].a);
            inc(dc);
            end;
         end;//xfeather

      //set
      if (dc>=2) then
         begin
   //was: dv:=dv div dc;//Warning: This had been used but found to round down summed values e.g. 255*5 div 5 -> 254 and 253 etc where as using "round(x/y)" rounds up to 255 - 19jan2021
         dv:=round(dv/dc);
         drows32[sy][sx].a:=byte(dv);
         end;
      end;
   end;//sx
   end
//.24
else if (dbits=24) then goto skipdone
//.8
else if (dbits=8) then
   begin
   for sxx:=0 to (sw-1) do
   begin
   if xalternate then sx:=sw-1-sxx else sx:=sxx;
   dv:=drows8[sy][sx];
   if (dv>=1) then//only adjust existing feather -> do not grow it outside of the scope of the image - 11jan2021
      begin
      dc:=1;
      //3x3
      //x-1
      if (sx>=1) then
         begin
         inc(dv,drows8[sy][sx-1]);
         inc(dc);
         end;
      //x+1
      if (sx<(sw-1)) then
         begin
         inc(dv,drows8[sy][sx+1]);
         inc(dc);
         end;
      //y-1
      if (sy>=1) then
         begin
         inc(dv,drows8[sy-1][sx]);
         inc(dc);
         end;
      //y+1
      if (sy<(sh-1)) then
         begin
         inc(dv,drows8[sy+1][sx]);
         inc(dc);
         end;
      //enlarge to a 5x5 - 20jan2021
      if (xfeather>=3) then
         begin
         //x-2
         if (sx>=2) then
            begin
            inc(dv,drows8[sy][sx-2]);
            inc(dc);
            end;
         //x+2
         if (sx<(sw-2)) then
            begin
            inc(dv,drows8[sy][sx+2]);
            inc(dc);
            end;
         //x-1,y-1
         if (sx>=1) and (sy>=1) then
            begin
            inc(dv,drows8[sy-1][sx-1]);
            inc(dc);
            end;
         //x+1,y-1
         if (sx<(sw-1)) and (sy>=1) then
            begin
            inc(dv,drows8[sy-1][sx+1]);
            inc(dc);
            end;
         //y-2
         if (sy>=2) then
            begin
            inc(dv,drows8[sy-2][sx]);
            inc(dc);
            end;
         //x-1,y+1
         if (sx>=1) and (sy<(sh-1)) then
            begin
            inc(dv,drows8[sy+1][sx-1]);
            inc(dc);
            end;
         //x+1,y+1
         if (sx<(sw-1)) and (sy<(sh-1)) then
            begin
            inc(dv,drows8[sy+1][sx+1]);
            inc(dc);
            end;
         //y+2
         if (sy<(sh-2)) then
            begin
            inc(dv,drows8[sy+2][sx]);
            inc(dc);
            end;
         end;//xfeather

      //set
      if (dc>=2) then
         begin
   //was: dv:=dv div dc;//Warning: This had been used but found to round down summed values e.g. 255*5 div 5 -> 254 and 253 etc where as using "round(x/y)" rounds up to 255 - 19jan2021
         dv:=round(dv/dc);
         drows8[sy][sx]:=byte(dv);
         end;
      end;
   end;//sx
   end;
end;//sy
end;//i

//successful
skipdone:
result:=true;
skipend:
except;end;
end;



//graphics procs ---------------------------------------------------------------
//## low__cornerMaxwidth ##
function low__cornerMaxwidth:longint;//used by some patch systems to work around corner restrictions such as "statusbar.cellpert.round/square" - 07ul2021
begin
result:=3;
end;
//## low__cornersolid ##
function low__cornersolid(xdynamicCorners:boolean;var a:trect;amin,ay,xmin,xmax,xroundstyle:longint;xround:boolean;var lx,rx:longint):boolean;//29mar2021
var
   ax,ax2:longint;
begin
//defaults
result:=true;
try
ax :=a.left;
ax2:=a.right;
lx :=xmin;
rx :=xmax;

//square corner ----------------------------------------------------------------
if (not xround) or ((amin<3) and xdynamicCorners) or (xmax<xmin) then exit;//check

//rounded corner ---------------------------------------------------------------
//17mar2021
if (xroundstyle=corSlight) or (xroundstyle=corSlight2) or (xroundstyle=corToSquare) then amin:=3//slight corner
else if not xdynamicCorners then amin:=11;//29mar2021

case amin of
3..10:begin
   if (ay=a.top) or (ay=a.bottom) then
      begin
      lx:=ax +1;
      rx:=ax2-1;
      end;
   end;//begin
11..max32:begin//multi-pixel curved corner
   if (ay=a.top) or (ay=a.bottom) then
      begin
      lx:=ax +3;
      rx:=ax2-3;
      end
   else if (ay=(a.top+1)) or (ay=(a.bottom-1)) then
      begin
      lx:=ax +2;
      rx:=ax2-2;
      end
   else if (ay=(a.top+2)) or (ay=(a.bottom-2)) or (ay=(a.top+3)) or (ay=(a.bottom-3)) or (ay=(a.top+4)) or (ay=(a.bottom-4)) then
      begin
      lx:=ax +1;
      rx:=ax2-1;
      end;
   end;//begin
end;//case
//detect usuability
result:=(lx<=rx);
//enforce range -> must do this else fatal error can occur when a window is dragged offscreen - 29mar2021
lx:=frcrange32(lx,xmin,xmax);
rx:=frcrange32(rx,xmin,xmax);
except;end;
end;
//## mistodata ##
function mistodata(s:tobject;ddata:tstr8;dformat:string;var e:string):boolean;//02jun2020
begin                                       //asis
result:=false;try;result:=mistodata2(s,ddata,dformat,clnone,-1,0,false,e);except;end;
end;
//## mistodata2 ##
function mistodata2(s:tobject;ddata:tstr8;dformat:string;dtranscol,dfeather,dlessdata:longint;dtransframe:boolean;var e:string):boolean;//04sep2021, 03jun2020
begin
result:=false;try;result:=mistodata3(s,ddata,dformat,dtranscol,dfeather,dlessdata,dtransframe,false,e);except;end;
end;
//## mistodata3 ##
function mistodata3(_s:tobject;ddata:tstr8;dformat:string;dtranscol,dfeather,dlessdata:longint;dtransframe,xuseacopy:boolean;var e:string):boolean;//04sep2021, 03jun2020
label//xformat: BMP, JPG, JIF, JPEG, TEM, TEH, TEA, RAW24, RAW32
   skipend;
var
   s:tobject;
   a:tbmp;
   xalpha:tbasicimage;
   sbmp:tobject;
   xmustunlock,bol1,smustfree:boolean;
   m:tmemstr8;
   //xouttranscol:longint;
{$ifdef jpeg}
   j:tjpegimage;
   jint2:longint;
   jbol2:boolean;
{$else}
   j:tobject;
{$endif}
   int1:longint;
   //## ainit ##
   procedure ainit;
   begin
   if zznil(a,2131) then
      begin
      a:=misbmp32(misw(s),mish(s));
      miscopyarea32(0,0,misw(s),mish(s),low__rect(0,0,misw(s)-1,mish(s)-1),a,s);
      end;
   end;
   //## sbmpinit ##
   procedure sbmpinit;//converts "s.bitmap" into a managed bitmap "tbmp" - 21aug2020
   begin
   if (s is tbasicimage) or (s is tbmp) or (s is tbitmap2) then sbmp:=s;
   //.lock
   bmplock(sbmp);//required - 18jun2022
   end;
   //## minit ##
   procedure minit;
   begin
   if zznil(m,2132) then m:=tmemstr8.create(ddata);
   end;
   //## jinit ##
   procedure jinit;
   begin
{$ifdef jpeg}
   if zznil(j,2133) then j:=misjpg;
{$endif}
   end;
begin
//defaults
result:=false;
e:='Task failed';
xmustunlock:=false;
smustfree:=false;
bol1:=false;

try
s:=_s;
xmustunlock:=mislocked(_s);
a:=nil;
xalpha:=nil;
m:=nil;
sbmp:=nil;
str__lock(@ddata);
j:=nil;
dformat:=io__extractfileext2(dformat,dformat,true);//accepts filename and extension only - 12apr2021
//check
if zznil(ddata,2134) then goto skipend else ddata.clear;
if zznil(_s,2135) or (misw(_s)<1) or (mish(_s)<1) then goto skipend;
//copy "_s" to "s" in order to retain original state of "_s" - 12feb2022
if xuseacopy then
   begin
   s:=misimg32(1,1);
   if not miscopy(_s,s) then goto skipend;
   end;
//get
if (dformat='BMP') then
   begin
   goto skipend;//disabled
{
   ainit;
   //.alpha - supports feather and transparent color - 05jun2021
   if (misb(a)=32) then
      begin
      int1:=dtranscol;
      if (int1=clnone) and mishasai(s) and misai(s).transparent then int1:=mispixel24VAL(s,0,0);
      //.make alpha
      a.lock;
      try
      xalpha:=misimg8(misw(a),mish(a));
      bol1:=mask__feather2(a,xalpha,dfeather,int1,dtransframe,xouttranscol) and mask__copy(a,xalpha);
      except;end;
      a.unlock;
      if not bol1 then goto skipend;//01aug2021
      end;
   minit;
   a.core.savetostream(m);
}
   end
else if (dformat='GIF') then//22may2022, 01aug2021
   begin
   bmplock(s);
   case misai(_s).use32 of
   false:bol1:=low__togif2(s,dtranscol,ddata,e);//permit transparent color override - 09sep2021
   true:result:=low__togif3(s,dtranscol,true,true,ddata,e);//22may2022
   end;
   bmpunlock(s);
   if not bol1 then goto skipend;
   end
else if (dformat='JPG') or (dformat='JIF') then
   begin
{$ifdef jpeg}
   e:='Out of memory';
   ainit;
   jinit;
   //xxxxxxxxxxxxxxx ...........rework this.............>> j.assign(a.core);
   minit;
   //.auto-adaptive for high quality images that exceed JPEG limit -> quality is reduced to ensure stability - 04sep2021
   jint2:=dlessdata;//start at X% and step down till there is no error -> Dephi's JPEG is prone to fail at high-quality and large image sizes -> e.g. ~1200x800 @ 100% failes - 06aug2019
   if (jint2>=1) then
      begin
      while true do
      begin
      jbol2:=false;
      try;j.compressionquality:=jint2;j.savetostream(m);jbol2:=true;except;end;
      if jbol2 then break;
      dec(jint2,5);
      if (jint2<5) then break;//04sep2021
      end;//while
      //.error
      if not jbol2 then goto skipend;
      end
   else j.savetostream(m);
{$else}
   e:='Image format not supported: '+dformat;
   goto skipend;
{$endif}
   end
else if (dformat='JPEG') then//automatically create best size jpeg with good quality
   begin
   //init
{$ifdef jpeg}
   e:='Out of memory';
   ainit;
   jinit;
   //xxxxxxxxxxxxxxx ...........rework this.............>> j.assign(a.core);
   jint2:=100;//start at 100% and step down till there is no error -> Dephi's JPEG is prone to fail at high-quality and large image sizes -> e.g. ~1200x800 @ 100% failes - 06aug2019
   //get
   minit;
   while true do
   begin
   jbol2:=false;
   try;j.compressionquality:=jint2;j.savetostream(m);jbol2:=true;except;end;
   if jbol2 then break;
   dec(jint2,5);
   if (jint2<=10) then break;
   end;//while
   //.error
   if not jbol2 then goto skipend;
{$else}
   e:='Image format not supported: '+dformat;
   goto skipend;
{$endif}
   end
else if (dformat='PNG') then
   begin
   sbmpinit;
   int1:=dtranscol;
   if (int1=clnone) and mishasai(sbmp) and misai(sbmp).transparent then int1:=mispixel24VAL(sbmp,0,0);
   if not mistopng82432(sbmp,int1,dfeather,dlessdata,dtransframe,ddata,e) then goto skipend;
   end
else if (dformat='TEA') then
   begin
   sbmpinit;
   if not low__teamake2(sbmp,true,misai(sbmp).transparent,misai(sbmp).syscolors,0,0,ddata,e) then goto skipend;//12apr2021
   end
{
else if (dformat='RAW24') then
   begin
   ainit;
   if not low__bmptoraw24(a,ddata,int1,int2,int3) then goto skipend;
   end
else if (dformat='RAW32') then
   begin
   ainit;
   if not low__bmptoraw32(a,ddata,int1,int2,int3) then goto skipend;
   end
{}//xxxxxxxxxx
else
   begin
   e:='Unsupported format';
   goto skipend;
   end;
//successful
result:=true;
skipend:
except;end;
try
if (not result) and zzok(ddata,7009) then ddata.clear;//reset
freeobj(@a);
freeobj(@xalpha);
freeobj(@j);
if smustfree then freeobj(@sbmp);
freeobj(@m);//do last
str__uaf(@ddata);
//.s - 12feb2022
if (s<>_s) then freeobj(@s);
//.unlock
if (_s<>nil) and xmustunlock and mislocked(_s) then misunlock(_s);
except;end;
end;
//## miscls ##
function miscls(s:tobject;xcolor:longint):boolean;
begin
result:=false;try;result:=misclsarea2(s,maxarea,xcolor,xcolor);except;end;
end;
//## misclsarea ##
function misclsarea(s:tobject;sarea:trect;xcolor:longint):boolean;
begin
result:=false;try;result:=misclsarea3(s,sarea,xcolor,xcolor,clnone,clnone);except;end;
end;
//## misclsarea2 ##
function misclsarea2(s:tobject;sarea:trect;xcolor,xcolor2:longint):boolean;
begin
result:=false;try;result:=misclsarea3(s,sarea,xcolor,xcolor2,clnone,clnone);except;end;
end;
//## misclsarea3 ##
function misclsarea3(s:tobject;sarea:trect;xcolor,xcolor2,xalpha,xalpha2:longint):boolean;
label
   skipdone,skipend;
var
  sr8 :pcolorrow8;
  sr16:pcolorrow16;
  sr24:pcolorrow24;
  sr32:pcolorrow32;
  sc8 :tcolor8;
  sc16:tcolor16;
  sc24,sc,sc2:tcolor24;
  sc32:tcolor32;
  dx,dy,sbits,sw,sh:longint;
  xpert:extended;
  xcolorok,xalphaok,shasai:boolean;
  da:trect;
  xa:byte;
begin
//defaults
result:=false;
sc8:=0;
sc16:=0;
xa:=0;

try
//check
if not misinfo8162432(s,sbits,sw,sh,shasai) then exit;
//range
if (sarea.right<sarea.left) or (sarea.bottom<sarea.top) or (sarea.bottom<0) or (sarea.top>=sh) or (sarea.right<0) or (sarea.left>=sw) then
   begin
   result:=true;
   exit;
   end;
da.left:=frcrange32(sarea.left,0,sw-1);
da.right:=frcrange32(sarea.right,0,sw-1);
da.top:=frcrange32(sarea.top,0,sh-1);
da.bottom:=frcrange32(sarea.bottom,0,sh-1);

//init
//.color
if (xcolor <>clnone) and (xcolor2=clnone) then xcolor2:=xcolor;
if (xcolor2<>clnone) and (xcolor =clnone) then xcolor:=xcolor2;
xcolorok:=(xcolor<>clnone) and (xcolor2<>clnone);
if xcolorok then
   begin
   sc:=low__intrgb(xcolor);
   sc2:=low__intrgb(xcolor2);
   end;
//.alpha
if (xalpha <>clnone) and (xalpha2=clnone) then xalpha2:=xalpha;
if (xalpha2<>clnone) and (xalpha =clnone) then xalpha:=xalpha2;
xalphaok:=(xalpha<>clnone) and (xalpha2<>clnone);
if xalphaok then
   begin
   xalpha:=frcrange32(xalpha,0,255);
   xalpha2:=frcrange32(xalpha2,0,255);
   end;
//check
if (not xcolorok) and (not xalphaok) then goto skipdone;
//get
for dy:=da.top to da.bottom do
begin
//.color gradient - optional
if xcolorok and ((xcolor<>xcolor2) or (dy=da.top)) then
   begin
   //.make color
   if (xcolor=xcolor2) then
      begin
      sc24.r:=sc.r;
      sc24.g:=sc.g;
      sc24.b:=sc.b;
      end
   else
      begin
      xpert:=(dy-da.top+1)/(da.bottom-da.top+1);
      sc24.r:=round( (sc.r*(1-xpert))+(sc2.r*xpert) );
      sc24.g:=round( (sc.g*(1-xpert))+(sc2.g*xpert) );
      sc24.b:=round( (sc.b*(1-xpert))+(sc2.b*xpert) );
      end;
   //.more bits
   case sbits of
   8:begin
      sc8:=sc24.r;
      if (sc24.g>sc8) then sc8:=sc24.g;
      if (sc24.b>sc8) then sc8:=sc24.b;
      end;
   16:sc16:=(sc24.r div 8) + (sc24.g div 8)*32 + (sc24.b div 8)*1024;
   32:begin
      sc32.r:=sc24.r;
      sc32.g:=sc24.g;
      sc32.b:=sc24.b;
      sc32.a:=255;//fully solid
      end;
   end;//case
   end;
//.alpha gradient - optional
//was: if xalphaok and (xalpha<>xalpha2) or (dy=da.top) then
if xalphaok and ((xalpha<>xalpha2) or (dy=da.top)) then//fixed error - 22apr2021
   begin
   //.make alpha
   if (xalpha=xalpha2) then
      begin
      xa:=xalpha;
      end
   else
      begin
      xpert:=(dy-da.top+1)/(da.bottom-da.top+1);
      xa:=byte(frcrange32(round( (xalpha*(1-xpert))+(xalpha2*xpert) ),0,255));
      end;
   end;
//.scan
if not misscan2432(s,dy,sr24,sr32) then goto skipend;
//.pixels
case sbits of
8 :begin
   if not xcolorok then goto skipdone;
   sr8:=pointer(sr24);
   for dx:=da.left to da.right do sr8[dx]:=sc8;
   end;
16:begin
   if not xcolorok then goto skipdone;
   sr16:=pointer(sr24);
   for dx:=da.left to da.right do sr16[dx]:=sc16;
   end;
24:begin
   if not xcolorok then goto skipdone;
   for dx:=da.left to da.right do sr24[dx]:=sc24;
   end;
32:begin
   //.c + a
   if xcolorok and xalphaok then
      begin
      sc32.a:=xa;
      for dx:=da.left to da.right do sr32[dx]:=sc32;
      end
   //.c only
   else if xcolorok then
      begin
      for dx:=da.left to da.right do sr32[dx]:=sc32;
      end
   //.a only
   else if xalphaok then
      begin
      for dx:=da.left to da.right do sr32[dx].a:=xa;
      end;
   end;
end;//case
end;//dy
//successful
skipdone:
result:=true;
skipend:
except;end;
end;
//## degtorad2 ##
function degtorad2(deg:extended):extended;//20OCT2009
const
   PieRadian=3.1415926535897932384626433832795;
   v=((2*PieRadian)/360);
begin
result:=0;try;result:=v*deg;except;end;
end;
//## miscurveAirbrush2 ##
function miscurveAirbrush2(var x:array of longint;xcount,valmin,valmax:longint;xflip,yflip:boolean):boolean;//20jan2021, 29jul2016
var
   dp,dv,valmag,p,v,maxp:longint;
   tmp,deg:extended;
begin
//defaults
result:=false;
try
//range
xcount:=frcrange32(xcount,0,high(x)+1);
if (xcount<2) then exit;
if (valmin>valmax) then low__swapint(valmin,valmax);
//init
valmag:=valmax-valmin;
maxp:=frcmin32(xcount-1,0);
//set
for p:=0 to maxp do
begin
deg:=90*(p/(1+maxp));//29jul2016
tmp:=round(maxp*sin(degtorad2(deg)));
deg:=90*(tmp/(1+maxp));
v:=round(
 valmag*
 power(cos(degtorad2(deg)),2)//4 or 5 increases the steepness, 1..3 decreases steepness, 3=middle ground and is 98% same as Adobe's airbrush curve
 );
v:=frcrange32(v,0,valmag);
//.support X and Y flipping - 20jan2021
if xflip then dp:=p else dp:=maxp-p;
if yflip then dv:=valmax-v else dv:=valmin+v;
x[dp]:=frcrange32(dv,valmin,valmax);
end;//p
//successful
result:=true;
except;end;
end;
//## mistranscol ##
function mistranscol(s:tobject;stranscolORstyle:longint;senable:boolean):longint;
begin
result:=clnone;
if senable then result:=misfindtranscol82432(s,stranscolORstyle);
end;
//## misfindtranscol82432 ##
function misfindtranscol82432(s:tobject;stranscol:longint):longint;
var
   tr,tg,tb:longint;
begin
result:=0;try;misfindtranscol82432ex(s,stranscol,tr,tg,tb);result:=low__rgb(tr,tg,tb);except;end;
end;
//## misfindtranscol82432ex ##
function misfindtranscol82432ex(s:tobject;stranscol:longint;var tr,tg,tb:longint):boolean;
label
   skipend;
var
   sr8 :pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc24:tcolor24;
   sbits,sw,sh:longint;
begin
//defaults
result:=false;
try
tr:=255;
tg:=255;
tb:=255;
//get
//.top-left
if (stranscol=cltopleft) then
   begin
   if not misok82432(s,sbits,sw,sh) then goto skipend;
   if not misscan82432(s,0,sr8,sr24,sr32) then goto skipend;
   if (sbits=8) then
      begin
      tr:=sr8[0];
      tg:=tr;
      tb:=tr;
      end
   else if (sbits=24) then
      begin
      tr:=sr24[0].r;
      tg:=sr24[0].g;
      tb:=sr24[0].b;
      end
   else if (sbits=32) then
      begin
      tr:=sr32[0].r;
      tg:=sr32[0].g;
      tb:=sr32[0].b;
      end;
   end
else if (stranscol=clwhite) then
   begin
   tr:=255;
   tg:=255;
   tb:=255;
   end
else if (stranscol=clblack) then
   begin
   tr:=0;
   tg:=0;
   tb:=0;
   end
else if (stranscol=clred) then
   begin
   tr:=255;
   tg:=0;
   tb:=0;
   end
else if (stranscol=cllime) then
   begin
   tr:=0;
   tg:=255;
   tb:=0;
   end
else if (stranscol=clblue) then
   begin
   tr:=0;
   tg:=0;
   tb:=255;
   end
//.user specified color
else
   begin
   sc24:=low__intrgb(stranscol);
   tr:=sc24.r;
   tg:=sc24.g;
   tb:=sc24.b;
   end;
//successful
result:=true;
skipend:
except;end;
end;
//## misrect ##
function misrect(x,y,x2,y2:longint):trect;
begin
result.left:=x;
result.top:=y;
result.right:=x2;
result.bottom:=y2;
end;
//## misarea ##
function misarea(s:tobject):trect;
begin
result:=nilrect;
if zzok(s,7008) then result:=low__rect(0,0,misw(s)-1,mish(s)-1);
end;
//## miscopyarea32 ##
function miscopyarea32(ddx,ddy,ddw,ddh:currency;sa:trect;d,s:tobject):boolean;//can copy ALL 32bits of color
begin
result:=false;try;result:=miscopyarea322(maxarea,ddx,ddy,ddw,ddh,sa,d,s,0,0);except;end;
end;
//## miscopyarea321 ##
function miscopyarea321(da,sa:trect;d,s:tobject):boolean;//can copy ALL 32bits of color
begin
result:=false;try;result:=miscopyarea32(da.left,da.top,da.right-da.left+1,da.bottom-da.top+1,sa,d,s);except;end;
end;
//## miscopyarea322 ##
function miscopyarea322(da_clip:trect;ddx,ddy,ddw,ddh:currency;sa:trect;d,s:tobject;xscroll,yscroll:longint):boolean;//can copy ALL 32bits of color
label
   skipend;
var//Note: Speed optimised using x-pixel limiter "d1,d2", y-pixel limiter "d3,d4"
   //      and object caching "1x createtmp" and "2x createint" with a typical speed
   //      increase in PicWork of 45x, or a screen paint time originally of 3,485ms now 78ms
   //      with layer 2 image at 80,000px wide @ 1,000% zoom as of 06sep2017.
   //Note: s and d are required - 25jul2017
   //Note: da,sa are zero-based areas, e.g: da.left/right=0..[width-1],
   //Critical Note: must use "trunc" instead of "round" for correct rounding behaviour - 24SEP2011
   //.locks
   dmustunlock,smustunlock:boolean;
   dr32,sr32:pcolorrow32;//25apr2020
   dr24,sr24:pcolorrow24;
   dr8,sr8:pcolorrow8;
   sc32:tcolor32;
   sc24:tcolor24;
   sc8:tcolor8;
   mx,my:pdllongint;
   _mx,_my:tdynamicinteger;//mapper support
   p,daW,daH,saW,saH:longint;
   d1,d2,d3,d4:longint;//x-pixel(d) and y-pixel(d) speed optimisers -> represent ACTUAL d.area needed to be processed - 05sep2017
   //.image values
   sw,sh,sbits:longint;
   shasai:boolean;
   dw,dh,dbits:longint;
   dhasai:boolean;
   //.other
   dx,dy,sx,sy:longint;
   dx1,dx2,dy1,dy2:longint;
   bol1,xmirror,xflip:boolean;
   da:trect;
   //## cint32 ##
   function cint32(x:currency):longint;
   begin//Note: Clip a 64bit integer to a 32bit integer range
   if (x>max32) then x:=max32
   else if (x<min32) then x:=min32;
   result:=trunc(x);
   end;
begin
//defaults
result:=false;
try
_mx:=nil;
_my:=nil;
//.locks
dmustunlock     :=false;
smustunlock     :=false;

//check
if (sa.right<sa.left) or (sa.bottom<sa.top) then goto skipend;
if not misinfo82432(s,sbits,sw,sh,shasai) then goto skipend;
if not misinfo82432(d,dbits,dw,dh,dhasai) then goto skipend;

//.mirror + flip
xmirror:=(ddw<0);if xmirror then ddw:=-ddw;
xflip  :=(ddh<0);if xflip   then ddh:=-ddh;
da.left:=cint32(ddx);
da.right:=cint32(ddx)+cint32(ddw-1);
da.top:=cint32(ddy);
da.bottom:=cint32(ddy)+cint32(ddh-1);

//.da_clip - limit to dimensions of "d" - 05sep2017
da_clip.left:=frcrange32(da_clip.left,0,dw-1);
da_clip.right:=frcrange32(da_clip.right,da_clip.left,dw-1);
da_clip.top:=frcrange32(da_clip.top,0,dH-1);
da_clip.bottom:=frcrange32(da_clip.bottom,0,dH-1);

//.optimise actual x-pixels scanned -> d1 + d2 -> 05sep2017
//.warning: Do not alter boundary handling below or failure will result - 27sep2017
d1:=largest(largest(da.left,da_clip.left),0);//range: 0..max32
d2:=smallest(smallest(da.right,da_clip.right),dw-1);//range: min32..dw-1
if (d2<d1) then goto skipend;

//.optimise actual y-pixels scanned -> d3 + d4 -> 05sep2017
//.warning: Do not alter boundary handling below or failure will result - 27sep2017
d3:=largest(largest(da.top,da_clip.top),0);//range: 0..max32
d4:=smallest(smallest(da.bottom,da_clip.bottom),dH-1);//range: min32..dh-1
if (d4<d3) then goto skipend;

//.other
daW:=low__posn(da.right-da.left)+1;
daH:=low__posn(da.bottom-da.top)+1;
saW:=low__posn(sa.right-sa.left)+1;
saH:=low__posn(sa.bottom-sa.top)+1;
dx1:=frcrange32(da.left,0,dw-1);
dx2:=frcrange32(da.right,0,dw-1);
dy1:=frcrange32(da.top,0,dh-1);
dy2:=frcrange32(da.bottom,0,dh-1);
//.check area -> do nothing
if (daw=0) or (dah=0) or (saw=0) or (sah=0) then goto skipend;
if (sa.right<sa.left) or (sa.bottom<sa.top) or (da.right<da.left) or (da.bottom<da.top) then goto skipend;
if (dx2<dx1) or (dy2<dy1) then goto skipend;

//.locks
if mismustlock(d)   then dmustunlock:=mislock(d);
if mismustlock(s)   then smustunlock:=mislock(s);

//.x-scroll
if (xscroll<>0) then
   begin
   xscroll:=-xscroll;//logic inversion -> match user expectation -> neg.vals=left, pos.vals=right
   bol1:=(xscroll<0);
   xscroll:=low__posn(xscroll);
   xscroll:=xscroll-((xscroll div saW)*saW);
   xscroll:=frcrange32(xscroll,0,saW-1);
   if bol1 then xscroll:=-xscroll;
   end;

//.y-scroll
if (yscroll<>0) then
   begin
   yscroll:=-yscroll;//logic inversion -> match user expectation -> neg.vals=up, pos.vals=down
   bol1:=(yscroll<0);
   yscroll:=low__posn(yscroll);
   yscroll:=yscroll-((yscroll div saH)*saH);
   yscroll:=frcrange32(yscroll,0,saH-1);
   if bol1 then yscroll:=-yscroll;
   end;

//.mx (mapped dx) - highly optimised - 06sep2017
if not low__createint(_mx,'copyareaxx_mx.'+inttostr(daW)+'.0.'+inttostr(sa.left)+'.'+inttostr(sa.right)+'.'+inttostr(saW),bol1) then goto skipend;
if not bol1 then
   begin
   //init
   _mx.setparams(daW,daW,0);
   mx:=_mx.core;
   //get
   for p:=0 to (daW-1) do
   begin
   mx[p]:=frcrange32(sa.left+trunc(p*(saW/daW)),sa.left,sa.right);//06apr2017
   end;//p
   end;
mx:=_mx.core;

//.my (mapped dy) - highly optimised - 06sep2017
if not low__createint(_my,'copyareaxx_my.'+inttostr(daH)+'.0.'+inttostr(sa.top)+'.'+inttostr(sa.bottom)+'.'+inttostr(saH),bol1) then goto skipend;
if not bol1 then
   begin
   //init
   _my.setparams(daH,daH,0);
   my:=_my.core;
   //get
   for p:=0 to (daH-1) do
   begin
   my[p]:=frcrange32(sa.top+trunc(p*(saH/daH)),sa.top,sa.bottom);//24SEP2011
   end;//p
   end;
my:=_my.core;

//-- Draw Color Pixels ---------------------------------------------------------
//dy
//...was: for dy:=da.top to da.bottom do if (dy>=0) and (dy<dH) and (dy>=da_clip.top) and (dy<=da_clip.bottom) then
for dy:=d3 to d4 do
   begin
   //.ar
   if xflip then sy:=my[(da.bottom-da.top)-(dy-da.top)] else sy:=my[dy-da.top];//zero base
   //.y-scroll
   if (yscroll<>0) then
      begin
      sy:=sy+yscroll;
      if (sy<sa.top) then sy:=sa.bottom-(-sy-sa.top) else if (sy>sa.bottom) then sy:=sa.top+(sy-sa.bottom);
      end;
   //.sy
   if (sy>=0) and (sy<sH) then
      begin
      if not misscan82432(d,dy,dr8,dr24,dr32)                     then goto skipend;//25apr2020, 28may2019
      if not misscan82432(s,sy,sr8,sr24,sr32)                     then goto skipend;//25apr2020,
      //dx - Note: xeven only updated at this stage for speed during "sselshowbits<>0" - 08jul2019
      //...was: for dx:=da.left to da.right do if (dx>=0) and (dx<dw) and (dx>=da_clip.left) and (dx<=da_clip.right) then
      for dx:=d1 to d2 do
         begin
         if xmirror then sx:=mx[(da.right-da.left)-(dx-da.left)] else sx:=mx[dx-da.left];//zero base
         //.x-scroll
         if (xscroll<>0) then
            begin
            sx:=sx+xscroll;
            if (sx<sa.left) then
               begin
               //.math quirk for "animation cell area" referencing - 25sep2017
               if (sx<=0) then sx:=sa.right-(-sx-sa.left) else sx:=sa.right-(sa.left-sx);
               end
            else if (sx>sa.right) then sx:=sa.left+(sx-sa.right);
            end;
         //.sx
         if (sx>=0) and (sx<sW) then
            begin
            //.32 + 32
            if (sbits=32) and (dbits=32) then
               begin
               sc32:=sr32[sx];
               dr32[dx]:=sc32;
               end
            //.32 + 24
            else if (sbits=32) and (dbits=24) then
               begin
               sc32:=sr32[sx];
               sc24.r:=sc32.r;
               sc24.g:=sc32.g;
               sc24.b:=sc32.b;
               dr24[dx]:=sc24;
               end
            //.32 + 8
            else if (sbits=32) and (dbits=8) then
               begin
               sc32:=sr32[sx];
               if (sc32.g>sc32.r) then sc32.r:=sc32.g;
               if (sc32.b>sc32.r) then sc32.r:=sc32.b;
               dr8[dx]:=sc32.r;
               end
            //.24 + 32
            else if (sbits=24) and (dbits=32) then
               begin
               sc24:=sr24[sx];
               sc32.r:=sc24.r;
               sc32.g:=sc24.g;
               sc32.b:=sc24.b;
               sc32.a:=255;
               dr32[dx]:=sc32;
               end
            //.24 + 24
            else if (sbits=24) and (dbits=24) then
               begin
               sc24:=sr24[sx];
               dr24[dx]:=sc24;
               end
            //.24 + 8
            else if (sbits=24) and (dbits=8) then
               begin
               sc24:=sr24[sx];
               if (sc24.g>sc24.r) then sc24.r:=sc24.g;
               if (sc24.b>sc24.r) then sc24.r:=sc24.b;
               dr8[dx]:=sc24.r;
               end
            //.8 + 32
            else if (sbits=8) and (dbits=32) then
               begin
               sc32.r:=sr8[sx];
               sc32.g:=sc32.r;
               sc32.b:=sc32.r;
               sc32.a:=255;
               dr32[dx]:=sc32;
               end
            //.8 + 24
            else if (sbits=8) and (dbits=24) then
               begin
               sc24.r:=sr8[sx];
               sc24.g:=sc24.r;
               sc24.b:=sc24.r;
               dr24[dx]:=sc24;
               end
            //.8 + 8
            else if (sbits=8) and (dbits=8) then
               begin
               sc8:=sr8[sx];
               dr8[dx]:=sc8;
               end;
            end;//sx
         end;//dx
      end;//sy
   end;//dy

//successful
result:=true;
skipend:
except;end;
try
//.unlocks
if dmustunlock     then misunlock(d);
if smustunlock     then misunlock(s);
//.free
low__freeint(_mx);
low__freeint(_my);
except;end;
end;
//## miscopy ##
function miscopy(s,d:tobject):boolean;//12feb2022
label
   skipend;
var
   //s
   sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;
   shasai:boolean;
   stransparent:boolean;
   //d
   dbits,dw,dh,dcellcount,dcellw,dcellh,ddelay:longint;
   dhasai:boolean;
   dtransparent:boolean;
begin
//defaults
result:=false;
try
//get
//.invalid
if zznil2(s) or zznil2(d) then goto skipend
//.fast
else if zzimg(s) and zzimg(d) then result:=asimg(d).copyfrom(asimg(s))//09may2022
//.moderate
else
   begin
   //.info
   if not miscells(s,sbits,sw,sh,scellcount,scellw,scellh,sdelay,shasai,stransparent) then goto skipend;
   if not miscells(d,dbits,dw,dh,dcellcount,dcellw,dcellh,ddelay,dhasai,dtransparent) then goto skipend;
   //.size
   if (sw<>dw) or (sh<>dh) and (not missize(d,sw,sh)) then goto skipend;
   //.bits
   if (sbits<>dbits) and (not missetb2(d,sbits)) then goto skipend;
   //.pixels -> full 32bit RGBA support - 15feb2022
   if not miscopyarea32(0,0,sw,sh,misarea(s),d,s) then goto skipend;
   //.ai
   if shasai and dhasai and (not misaicopy(s,d)) then goto skipend;
   end;
//successful
result:=true;
skipend:
except;end;
end;
//## misokex ##
function misokex(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
//defaults
result:=false;
try
sbits:=0;
sw:=0;
sh:=0;
shasai:=false;
//check
if system_nographics then exit;//special debug mode - 10jun2019
//get
if zznil(s,2079) then exit
else if (s is tbmp) then
   begin
   sw     :=(s as tbmp).width;
   sh     :=(s as tbmp).height;
   sbits  :=(s as tbmp).bits;
   shasai :=true;
   end
else if (s is tbasicimage) then
   begin
   sw     :=(s as tbasicimage).width;
   sh     :=(s as tbasicimage).height;
   sbits  :=(s as tbasicimage).bits;
   shasai :=true;
   end
else if (s is tbitmap2) then
   begin
   sw:=(s as tbitmap2).width;
   sh:=(s as tbitmap2).height;
   sbits:=(s as tbitmap2).bits;
   end;
//set
result:=(sw>=1) and (sh>=1) and (sbits>=1);
except;end;
end;
//## misok ##
function misok(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai);
end;
//## misokk ##
function misokk(s:tobject):boolean;
var
   shasai:boolean;
   sbits,sw,sh:longint;
begin
result:=misokex(s,sbits,sw,sh,shasai);
end;
//## misokai ##
function misokai(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and shasai;
end;
//## misokaii ##
function misokaii(s:tobject):boolean;
var
   shasai:boolean;
   sbits,sw,sh:longint;
begin
result:=misokex(s,sbits,sw,sh,shasai) and shasai;
end;
//## misok8 ##
function misok8(s:tobject;var sw,sh:longint):boolean;
var
   sbits:longint;
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and (sbits=8);
end;
//## misokai8 ##
function misokai8(s:tobject;var sw,sh:longint):boolean;
var
   sbits:longint;
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and (sbits=8) and shasai;
end;
//## misok24 ##
function misok24(s:tobject;var sw,sh:longint):boolean;
var
   sbits:longint;
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and (sbits=24);
end;
//## misokk24 ##
function misokk24(s:tobject):boolean;
var
   sbits,sw,sh:longint;
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and (sbits=24);
end;
//## misok24 ##
function misokai24(s:tobject;var sw,sh:longint):boolean;
var
   sbits:longint;
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and (sbits=24) and shasai;
end;
//## misok824 ##
function misok824(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24));
end;
//## misok82432 ##
function misok82432(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24) or (sbits=32));
end;
//## misokk824 ##
function misokk824(s:tobject):boolean;
var
   shasai:boolean;
   sbits,sw,sh:longint;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24));
end;
//## misokk82432 ##
function misokk82432(s:tobject):boolean;
var
   shasai:boolean;
   sbits,sw,sh:longint;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24) or (sbits=32));
end;
//## misokai824 ##
function misokai824(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24)) and shasai;
end;
//## bmplock ##
procedure bmplock(x:tobject);
begin
try;if zzok(x,1011) and (x is tbmp) then (x as tbmp).lock;except;end;
end;
//## bmpunlock ##
procedure bmpunlock(x:tobject);
begin
try;if zzok(x,1012) and (x is tbmp) then (x as tbmp).unlock;except;end;
end;
//## mismustlock ##
function mismustlock(s:tobject):boolean;
begin
result:=false;
try
if     zznil(s,2080) then exit
else if (s is tbmp)  then result:=not (s as tbmp).locked;
except;end;
end;
//## mislock ##
function mislock(s:tobject):boolean;
begin
result:=false;
try
if     zznil(s,2081) then exit
else if (s is tbmp)  then
   begin
   if not (s as tbmp).locked then
      begin
      (s as tbmp).lock;
      result:=(s as tbmp).locked;
      end;
   end;
except;end;
end;
//## misunlock ##
function misunlock(s:tobject):boolean;
begin
result:=false;
try
if     zznil(s,2082) then exit
else if (s is tbmp)  then
   begin
   if (s as tbmp).locked then
      begin
      (s as tbmp).unlock;
      result:=not (s as tbmp).locked;
      end;
   end;
except;end;
end;
//## mislocked ##
function mislocked(s:tobject):boolean;//27jan2021
begin
result:=false;
try
if     zznil(s,2083) then exit
else if (s is tbmp)  then result:=(s as tbmp).locked;
except;end;
end;
//## misinfo ##
function misinfo(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=false;
try
sbits:=0;
sw:=0;
sh:=0;
shasai:=false;
if zznil(s,2085) then exit;
sbits:=misb(s);
sw:=misw(s);
sh:=mish(s);
shasai:=mishasai(s);
result:=(sw>=1) and (sh>=1) and (sbits>=1);
except;end;
end;
//## misinfo2432 ##
function misinfo2432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=24) or (sbits=32));
end;
//## misinfo82432 ##
function misinfo82432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24) or (sbits=32));
end;
//## misinfo8162432 ##
function misinfo8162432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=16) or (sbits=24) or (sbits=32));
end;
//## misinfo824 ##
function misinfo824(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24));
end;
//## misrows8 ##
function misrows8(s:tobject;var xout:pcolorrows8):boolean;
begin
//defaults
result:=false;
try
xout:=nil;
//get
if zznil(s,2086) then exit
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then xout:=(s as tbmp).prows8;
   end
else if (s is tbasicimage) then xout:=(s as tbasicimage).prows8;
//set
result:=(xout<>nil);
except;end;
end;
//## misrows16 ##
function misrows16(s:tobject;var xout:pcolorrows16):boolean;
begin
//defaults
result:=false;
try
xout:=nil;
//get
if zznil(s,2087) then exit
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then xout:=(s as tbmp).prows16;
   end
else if (s is tbasicimage) then xout:=(s as tbasicimage).prows16;
//set
result:=(xout<>nil);
except;end;
end;
//## misrows24 ##
function misrows24(s:tobject;var xout:pcolorrows24):boolean;
begin
//defaults
result:=false;
try
xout:=nil;
//get
if zznil(s,2088) then exit
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then xout:=(s as tbmp).prows24;
   end
else if (s is tbasicimage) then xout:=(s as tbasicimage).prows24;
//set
result:=(xout<>nil);
except;end;
end;
//## misrows32 ##
function misrows32(s:tobject;var xout:pcolorrows32):boolean;
begin
//defaults
result:=false;
try
xout:=nil;
//get
if zznil(s,2089) then exit
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then xout:=(s as tbmp).prows32;
   end
else if (s is tbasicimage) then xout:=(s as tbasicimage).prows32;
//set
result:=(xout<>nil);
except;end;
end;
//## misrows82432 ##
function misrows82432(s:tobject;var xout8:pcolorrows8;var xout24:pcolorrows24;var xout32:pcolorrows32):boolean;//26jan2021
begin
//defaults
result:=false;
try
xout8:=nil;
xout24:=nil;
xout32:=nil;
//get
if zznil(s,2090) then exit
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      xout8 :=(s as tbmp).prows8;
      xout24:=(s as tbmp).prows24;
      xout32:=(s as tbmp).prows32;
      end
   else exit;
   end
else if (s is tbasicimage) then
   begin
   xout8 :=(s as tbasicimage).prows8;
   xout24:=(s as tbasicimage).prows24;
   xout32:=(s as tbasicimage).prows32;
   end;
//set
result:=(xout8<>nil) and (xout24<>nil) and (xout32<>nil);
except;end;
end;
//## mispixel8VAL ##
function mispixel8VAL(s:tobject;sy,sx:longint):byte;
begin
result:=mispixel8(s,sy,sx);
end;
//## mispixel8 ##
function mispixel8(s:tobject;sy,sx:longint):tcolor8;
var
   sr8 :pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc24:tcolor24;
   sc32:tcolor32;
   sbits,sw,sh:longint;
begin
//defaults
result:=0;
try
//get
if misok82432(s,sbits,sw,sh) and (sx>=0) and (sx<sw) and (sy>=0) and (sy<sh) and misscan82432(s,sy,sr8,sr24,sr32) then
   begin
   //.8
   if      (sbits=8)  then result:=sr8[sx]
   //.24
   else if (sbits=24) then
      begin
      sc24:=sr24[sx];
      result:=sc24.r;
      if (sc24.g>result) then result:=sc24.g;
      if (sc24.b>result) then result:=sc24.b;
      end
   //.32
   else if (sbits=32) then
      begin
      sc32:=sr32[sx];
      result:=sc32.r;
      if (sc32.g>result) then result:=sc32.g;
      if (sc32.b>result) then result:=sc32.b;
      end;
   end;
except;end;
end;
//## mispixel24VAL ##
function mispixel24VAL(s:tobject;sy,sx:longint):longint;
begin
result:=low__rgbint(mispixel24(s,sy,sx));
end;
//## mispixel24 ##
function mispixel24(s:tobject;sy,sx:longint):tcolor24;
var
   sr8 :pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc32:tcolor32;
   sbits,sw,sh:longint;
begin
//defaults
result.r:=0;
result.g:=0;
result.b:=0;
try
//get
if misok82432(s,sbits,sw,sh) and (sx>=0) and (sx<sw) and (sy>=0) and (sy<sh) and misscan82432(s,sy,sr8,sr24,sr32) then
   begin
   //.8
   if      (sbits=8)  then
      begin
      result.r:=sr8[sx];
      result.g:=result.r;
      result.b:=result.r;
      end
   //.24
   else if (sbits=24) then result:=sr24[sx]
   //.32
   else if (sbits=32) then
      begin
      sc32:=sr32[sx];
      result.r:=sc32.r;
      result.g:=sc32.g;
      result.b:=sc32.b;
      end;
   end;
except;end;
end;
//## mispixel32VAL ##
function mispixel32VAL(s:tobject;sy,sx:longint):longint;
begin
result:=low__rgbaint(mispixel32(s,sy,sx));
end;
//## mispixel32 ##
function mispixel32(s:tobject;sy,sx:longint):tcolor32;
var
   sr8 :pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc24:tcolor24;
   sbits,sw,sh:longint;
begin
//defaults
result.r:=0;
result.g:=0;
result.b:=0;
result.a:=0;
try
//get
if misok82432(s,sbits,sw,sh) and (sx>=0) and (sx<sw) and (sy>=0) and (sy<sh) and misscan82432(s,sy,sr8,sr24,sr32) then
   begin
   //.8
   if      (sbits=8)  then
      begin
      result.r:=sr8[sx];
      result.g:=result.r;
      result.b:=result.r;
      result.a:=255;
      end
   //.24
   else if (sbits=24) then
      begin
      sc24:=sr24[sx];
      result.r:=sc24.r;
      result.g:=sc24.g;
      result.b:=sc24.b;
      result.a:=255;
      end
   //.32
   else if (sbits=32) then result:=sr32[sx];
   end;
except;end;
end;
//## missetpixel32VAL ##
function missetpixel32VAL(s:tobject;sy,sx,xval:longint):boolean;
begin
result:=missetpixel32(s,sy,sx,low__intrgba32(xval));
end;
//## missetpixel32 ##
function missetpixel32(s:tobject;sy,sx:longint;xval:tcolor32):boolean;
var
   sr8 :pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc24:tcolor24;
   sbits,sw,sh:longint;
begin
//defaults
result:=false;
try
//get
if misok82432(s,sbits,sw,sh) and (sx>=0) and (sx<sw) and (sy>=0) and (sy<sh) and misscan82432(s,sy,sr8,sr24,sr32) then
   begin
   //.8
   if      (sbits=8)  then
      begin
      sc24.r:=xval.r;
      sc24.g:=xval.g;
      sc24.b:=xval.b;
      sr8[sx]:=low__greyscale2(sc24);
      end
   //.24
   else if (sbits=24) then
      begin
      sc24.r:=xval.r;
      sc24.g:=xval.g;
      sc24.b:=xval.b;
      sr24[sx]:=sc24;
      end
   //.32
   else if (sbits=32) then sr32[sx]:=xval;
   end;
//successful
result:=true;
except;end;
end;
//## misscan82432 ##
function misscan82432(s:tobject;sy:longint;var sr8:pcolorrow8;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr8:=nil;
sr24:=nil;
sr32:=nil;
//check
if zznil(s,2091) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr8 :=(s as tbasicimage).prows8[sy];
   sr24:=(s as tbasicimage).prows24[sy];
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr8 :=(s as tbmp).prows8[sy];
      sr24:=(s as tbmp).prows24[sy];
      sr32:=(s as tbmp).prows32[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then
   begin
   sr8 :=(s as tbitmap2).scanline[sy];
   sr24:=(s as tbitmap2).scanline[sy];
   sr32:=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr8<>nil) and (sr24<>nil) and (sr32<>nil);
except;end;
end;
//## misscan8 ##
function misscan8(s:tobject;sy:longint;var sr8:pcolorrow8):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr8:=nil;
//check
if zznil(s,2092) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr8 :=(s as tbasicimage).prows8[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr8 :=(s as tbmp).prows8[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then//Warning: Use with care -> not really supported dfor mobile phone technology - 26jan2021
   begin
   sr8 :=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr8<>nil);
except;end;
end;
//## misscan24 ##
function misscan24(s:tobject;sy:longint;var sr24:pcolorrow24):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr24:=nil;
//check
if zznil(s,2093) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr24:=(s as tbasicimage).prows24[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr24:=(s as tbmp).prows24[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then//Warning: Use with care -> not really supported dfor mobile phone technology - 26jan2021
   begin
   sr24:=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr24<>nil);
except;end;
end;
//## misscan32 ##
function misscan32(s:tobject;sy:longint;var sr32:pcolorrow32):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr32:=nil;
//check
if zznil(s,2099) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr32:=(s as tbmp).prows32[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then//Warning: Use with care -> not really supported dfor mobile phone technology - 26jan2021
   begin
   sr32:=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr32<>nil);
except;end;
end;
//## misscan2432 ##
function misscan2432(s:tobject;sy:longint;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr24:=nil;
sr32:=nil;
//check
if zznil(s,2100) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr24:=(s as tbasicimage).prows24[sy];
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr24:=(s as tbmp).prows24[sy];
      sr32:=(s as tbmp).prows32[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then//Warning: Use with care -> not really supported dfor mobile phone technology - 26jan2021
   begin
   sr24:=(s as tbitmap2).scanline[sy];
   sr32:=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr24<>nil) and (sr32<>nil);
except;end;
end;
//## misscan824 ##
function misscan824(s:tobject;sy:longint;var sr8:pcolorrow8;var sr24:pcolorrow24):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr8:=nil;
sr24:=nil;
//check
if zznil(s,2101) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr8 :=(s as tbasicimage).prows8[sy];
   sr24:=(s as tbasicimage).prows24[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr8 :=(s as tbmp).prows8[sy];
      sr24:=(s as tbmp).prows24[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then//Warning: Use with care -> not really supported dfor mobile phone technology - 26jan2021
   begin
   sr8 :=(s as tbitmap2).scanline[sy];
   sr24:=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr8<>nil) and (sr24<>nil);
except;end;
end;
//## misscan832 ##
function misscan832(s:tobject;sy:longint;var sr8:pcolorrow8;var sr32:pcolorrow32):boolean;//14feb2022
var
   sw,sh:longint;
begin
//defaults
result:=false;
try
sr8:=nil;
sr32:=nil;
//check
if zznil(s,2101) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr8 :=(s as tbasicimage).prows8[sy];
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is tbmp) then
   begin
   if (s as tbmp).canrows then
      begin
      sr8 :=(s as tbmp).prows8[sy];
      sr32:=(s as tbmp).prows32[sy];
      end
   else exit;
   end
else if (s is tbitmap2) then//Warning: Use with care -> not really supported dfor mobile phone technology - 26jan2021
   begin
   sr8 :=(s as tbitmap2).scanline[sy];
   sr32:=(s as tbitmap2).scanline[sy];
   end
else exit;
//successful
result:=(sr8<>nil) and (sr32<>nil);
except;end;
end;
//## createbitmap ##
function createbitmap:tbitmap2;
begin
result:=nil;
try
track__inc(satBitmap,1);
result:=tbitmap2.create;
except;end;
end;
//## misbitmap ##
function misbitmap(dbits,dw,dh:longint):tbitmap2;
begin//Note: Flow now goes -> ask for bits -> get what we can get -> must check what bits we actually got under Android etc - 03may2020
result:=nil;
try
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
result:=createbitmap;
missetb(result,dbits);
missize(result,dw,dh);
except;end;
end;
//## misbitmap32 ##
function misbitmap32(dw,dh:longint):tbitmap2;
begin
result:=nil;try;result:=misbitmap(32,dw,dh);except;end;
end;
{$ifdef jpeg}
//## misjpg ##
function misjpg:tjpegimage;//01may2021
begin
try
result:=nil;
result:=tjpegimage.create;
zzadd(result);
track__inc(satJpegimage,1);
except;end;
end;
{$endif}
//## misbmp ##
function misbmp(dbits,dw,dh:longint):tbmp;
begin//Note: Flow now goes -> ask for bits -> get what we can get -> must check what bits we actually got under Android etc - 03may2020
result:=nil;
try
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
result:=tbmp.create;
result.setparams(dbits,dw,dh);
except;end;
end;
//## misbmp32 ##
function misbmp32(dw,dh:longint):tbmp;
begin
result:=nil;try;result:=misbmp(32,dw,dh);except;end;
end;
//## misbmp24 ##
function misbmp24(dw,dh:longint):tbmp;
begin
result:=nil;try;result:=misbmp(24,dw,dh);except;end;
end;
//## misimg ##
function misimg(dbits,dw,dh:longint):tbasicimage;
begin
result:=nil;
try
result:=tbasicimage.create;
result.setparams(dbits,frcmin32(dw,1),frcmin32(dh,1));
except;end;
end;
//## misimg8 ##
function misimg8(dw,dh:longint):tbasicimage;//26jan2021
begin
result:=nil;try;result:=misimg(8,dw,dh);except;end;
end;
//## misimg24 ##
function misimg24(dw,dh:longint):tbasicimage;
begin
result:=nil;try;result:=misimg(24,dw,dh);except;end;
end;
//## misimg32 ##
function misimg32(dw,dh:longint):tbasicimage;
begin
result:=nil;try;result:=misimg(32,dw,dh);except;end;
end;
//## misatleast ##
function misatleast(s:tobject;dw,dh:longint):boolean;//26jul2021
label
   skipend;
begin
//defaults
result:=false;
try
//check
if zznil(s,101) then exit;
//get
if (dw<=0) or (dh<=0) then
   begin
   result:=true;
   exit;
   end;
if (misw(s)<dw) or (mish(s)<dh) then
   begin
   if not missize(s,dw+100,dh+100) then goto skipend;
   end;
//successful
result:=true;
skipend:
except;end;
end;
//## missize ##
function missize(s:tobject;dw,dh:longint):boolean;
begin
result:=missize2(s,dw,dh,false);
end;
//## missize2 ##
function missize2(s:tobject;dw,dh:longint;xoverridelock:boolean):boolean;
label
   skipend;
var
   xmustrelock:boolean;
begin
//defaults
result:=false;
xmustrelock:=false;
try
//check
if zznil(s,2102) then exit;
//range
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
//.bmp
if (s is tbmp) then
   begin
   if (dw<>(s as tbmp).width) or (dh<>(s as tbmp).height) then
      begin
      //init
      xmustrelock:=mislocked(s);
      if xmustrelock then misunlock(s);
      //check
      if not (s as tbmp).cansetparams then goto skipend;
      //shrink
      (s as tbmp).setparams((s as tbmp).bits,1,1);
      //enlarge
      result:=(s as tbmp).setparams((s as tbmp).bits,dw,dh);
      end
   else result:=true;
   end
//.image
else if (s is tbasicimage) then result:=(s as tbasicimage).sizeto(dw,dh)
//.bitmap
else if (s is tbitmap2) then
   begin
   if (dw<>(s as tbitmap2).width) or (dh<>(s as tbitmap2).height) then
      begin
      //shrink
      (s as tbitmap2).height:=1;
      (s as tbitmap2).width:=1;
      //enlarge
      (s as tbitmap2).width:=dw;
      (s as tbitmap2).height:=dh;
      end;
   //successful
   result:=true;
   end;
skipend:
except;end;
try;if xmustrelock then mislock(s);except;end;
end;
//## miscountcolors ##
function miscountcolors(i:tobject):longint;//full color count - uses dynamic memory (2mb) - 15OCT2009
begin
result:=miscountcolors2(maxarea,i,nil);
end;
//## miscountcolors2 ##
function miscountcolors2(da_clip:trect;i,xsel:tobject):longint;//full color count - uses dynamic memory (2mb) - 19sep2018, 15OCT2009
var
   int1:longint;
begin
result:=0;try;miscountcolors3(da_clip,i,xsel,result,int1);except;end;
end;
//## miscountcolors3 ##
function miscountcolors3(da_clip:trect;i,xsel:tobject;var xcolorcount,xmaskcount:longint):boolean;//full color count - uses dynamic memory (2mb) - 19sep2018, 15OCT2009
label
   skipend;
const
   maxp=2097152;
type
   pcs=^tcs;
   tcs=array[0..maxp] of set of 0..7;
var//~580ms for a 1152x864 [24bit] with 362,724 colors
   //Dynamic memory used now instead of limited stack - 15OCT2009
   xselw,xselh,iw,ih,ibits,xselbits,p,ci,ip,rx,ry:longint;
   a32:pcolorrow32;
   a24,xselr24:pcolorrow24;
   a8,xselr8:pcolorrow8;
   b:tdynamicbyte;
   z32:tcolor32;
   z24:tcolor24;
   ics:pcs;
   c2:set of 0..7;
   a:array[0..255] of boolean;
   xselok:boolean;
begin
//defaults
result:=false;
try
xcolorcount:=0;
xmaskcount:=0;
b:=nil;
//check
if not misok82432(i,ibits,iw,ih) then exit;
//init
b:=tdynamicbyte.create;
b.setparams(maxp+1,maxp+1,0);
ics:=b.core;
fillchar(a,sizeof(a),#0);
//.x range
da_clip.left:=frcrange32(da_clip.left,0,iw-1);
da_clip.right:=frcrange32(da_clip.right,0,iw-1);
low__orderint(da_clip.left,da_clip.right);
//.y range
da_clip.top:=frcrange32(da_clip.top,0,ih-1);
da_clip.bottom:=frcrange32(da_clip.bottom,0,ih-1);
low__orderint(da_clip.top,da_clip.bottom);
//.xselok
xselok:=misok824(xsel,xselbits,xselw,xselh) and (xselw>=iw) and (xselh>=ih);
//get
//.ry
for ry:=da_clip.top to da_clip.bottom do
begin
if not misscan82432(i,ry,a8,a24,a32) then goto skipend;
if xselok and (not misscan824(xsel,ry,xselr8,xselr24)) then goto skipend;
//.32
if (ibits=32) then
   begin
   for rx:=da_clip.left to da_clip.right do if (xselbits=0) or ((xselbits=8) and (xselr8[rx]>=1)) or ((xselbits=24) and (xselr24[rx].r>=1)) then
   begin
   //colorcount
   //.get
   z32:=a32[rx];
   p:=z32.r+(z32.g*256)+(z32.b*65536);//0..16,777,215 -> 0..2,097,152
   ip:=p div 8;
   ci:=p-ip*8;
   //.set
   if not (ci in ics[ip]) then include(ics[ip],ci);
   //maskcount
   a[z32.a]:=true;
   end;//rx
   end
//.24
else if (ibits=24) then
   begin
   for rx:=da_clip.left to da_clip.right do if (xselbits=0) or ((xselbits=8) and (xselr8[rx]>=1)) or ((xselbits=24) and (xselr24[rx].r>=1)) then
   begin
   //.get
   z24:=a24[rx];
   p:=z24.r+z24.g*256+z24.b*65536;//0..16,777,215 -> 0..2,097,152
   ip:=p div 8;
   ci:=p-ip*8;
   //.set
   if not (ci in ics[ip]) then include(ics[ip],ci);
   end;//rx
   end
//.8
else if (ibits=8) then
   begin
   for rx:=da_clip.left to da_clip.right do if (xselbits=0) or ((xselbits=8) and (xselr8[rx]>=1)) or ((xselbits=24) and (xselr24[rx].r>=1)) then
   begin
   //colorcount
   //.get
   z24.r:=a8[rx];
   p:=z24.r+z24.r*256+z24.r*65536;//0..16,777,215 -> 0..2,097,152
   ip:=p div 8;
   ci:=p-ip*8;
   //.set
   if not (ci in ics[ip]) then include(ics[ip],ci);
   //maskcount
   a[z32.a]:=true;
   end;//rx
   end;
end;//ry

//.colorcount
for rx:=0 to maxp do
begin
c2:=ics[rx];
if (byte(c2)>=1) then//25ms faster than "(c2<>[])"
   begin
   if (0 in c2) then xcolorcount:=xcolorcount+1;//faster than a loop
   if (1 in c2) then xcolorcount:=xcolorcount+1;
   if (2 in c2) then xcolorcount:=xcolorcount+1;
   if (3 in c2) then xcolorcount:=xcolorcount+1;
   if (4 in c2) then xcolorcount:=xcolorcount+1;
   if (5 in c2) then xcolorcount:=xcolorcount+1;
   if (6 in c2) then xcolorcount:=xcolorcount+1;
   if (7 in c2) then xcolorcount:=xcolorcount+1;
   end;//end of if
end;//end of loop
//.maskcount
for p:=0 to high(a) do if a[p] then xmaskcount:=xmaskcount+1;
//successful
result:=true;
skipend:
except;end;
try;freeobj(@b);except;end;
end;
//## misv ##
function misv(s:tobject):boolean;//valid
begin
result:=zzok(s,1061) and ( (s is tbmp) or (s is tbasicimage) or (s is tbitmap2));
end;
//## misb ##
function misb(s:tobject):longint;//bits 0..N
begin
//defaults
result:=0;
try
//get
if zznil(s,2072) then exit
//.bmp
else if (s is tbmp) then result:=(s as tbmp).bits
//.image
else if (s is tbasicimage) then result:=(s as tbasicimage).bits
//.bitmap
else if (s is tbitmap2) then result:=(s as tbitmap2).bits;
except;end;
end;
//## missetb ##
procedure missetb(s:tobject;sbits:longint);
begin
try
sbits:=frcmin32(sbits,1);
if not misv(s) then exit
else if (s is tbasicimage) then (s as tbasicimage).setparams(sbits,misw(s),mish(s))
else if (s is tbmp) then (s as tbmp).bits:=sbits
else if (s is tbitmap2) then (s as tbitmap2).bits:=sbits;
except;end;
end;
//## missetb2 ##
function missetb2(s:tobject;sbits:longint):boolean;//12feb2022
begin
result:=false;
try
missetb(s,sbits);
result:=(misb(s)<>sbits);
except;end;
end;
//## misw ##
function misw(s:tobject):longint;
begin
result:=0;
try
if zznil(s,2075)           then exit
else if (s is tbmp)        then result:=(s as tbmp).width
else if (s is tbasicimage) then result:=(s as tbasicimage).width
else if (s is tbitmap2)    then result:=(s as tbitmap2).width;
except;end;
end;
//## mish ##
function mish(s:tobject):longint;
begin
result:=0;
try
if zznil(s,2076)           then exit
else if (s is tbmp)        then result:=(s as tbmp).height
else if (s is tbasicimage) then result:=(s as tbasicimage).height
else if (s is tbitmap2)    then result:=(s as tbitmap2).height;
except;end;
end;
//## mishasai ##
function mishasai(s:tobject):boolean;
begin
result:=false;
try
if zznil(s,2077)           then exit
else if (s is tbmp)        then result:=true
else if (s is tbasicimage) then result:=true
else if (s is tbitmap2)    then result:=false;
except;end;
end;
//## misonecell ##
function misonecell(s:tobject):boolean;//26apr2022
label
   skipend;
var
   a:tbasicimage;
   ca:trect;
begin
//defaults
result:=true;
try
a:=nil;
//check
if not mishasai(s) then exit;
if (misai(s).count<=1) then exit;
//get
result:=false;
if not miscell(s,0,ca) then goto skipend;
a:=misimg(misb(s),ca.right-ca.left+1,ca.bottom-ca.top+1);
if not miscopyarea32(0,0,misw(a),mish(a),ca,a,s) then goto skipend;//can copy ALL 32bits of color
if not missize(s,misw(a),mish(a)) then goto skipend;
if not miscopyarea32(0,0,misw(a),mish(a),ca,s,a) then goto skipend;//can copy ALL 32bits of color
misai(s).count:=1;
//successful
result:=true;
skipend:
except;end;
try;freeobj(@a);except;end;
end;
//## miscells ##
function miscells(s:tobject;var sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;var shasai:boolean;var stransparent:boolean):boolean;//27jul2021
var
   xbits,xw,xh:longint;
   xhasai:boolean;
begin
//defaults
result:=false;
try
sbits:=0;
sw:=1;
sh:=1;
scellcount:=1;
scellw:=1;
scellh:=1;
sdelay:=500;//500 ms
shasai:=false;
stransparent:=false;
//check
if not misokex(s,xbits,xw,xh,xhasai) then exit;
//get
sbits:=xbits;
sw:=frcmin32(xw,1);
sh:=frcmin32(xh,1);
if xhasai then
   begin
   scellcount:=frcmin32(misai(s).count,1);
   stransparent:=misai(s).transparent;
   sdelay:=frcmin32(misai(s).delay,1);
   end;
shasai:=xhasai;
scellw:=frcmin32(trunc(sw/scellcount),1);
scellh:=sh;
//successful
result:=true;
except;end;
end;
//## miscell ##
function miscell(s:tobject;sindex:longint;var scellarea:trect):boolean;
var
   sms,sbits,sw,sh,scellcount,scellw,scellh:longint;
   shasai:boolean;
   stransparent:boolean;
begin
//defaults
result:=false;
try
scellarea:=nilarea;
//get
if miscells(s,sbits,sw,sh,scellcount,scellw,scellh,sms,shasai,stransparent) then
   begin
   //range
   sindex:=frcrange32(sindex,0,scellcount-1);
   //get
   scellarea.left:=sindex*scellw;
   scellarea.right:=scellarea.left+scellw-1;
   scellarea.top:=0;
   scellarea.bottom:=scellh-1;
   result:=true;
   end;
except;end;
end;
//## miscell2 ##
function miscell2(s:tobject;sindex:longint):trect;
begin
miscell(s,sindex,result);
end;
//## miscellarea ##
function miscellarea(s:tobject;sindex:longint):trect;
begin
miscell(s,sindex,result);
end;
//## misaiclear2 ##
function misaiclear2(s:tobject):boolean;
begin
result:=(s<>nil) and misaiclear(misai(s)^);
end;
//## misaiclear ##
function misaiclear(var x:tanimationinformation):boolean;
begin
//defaults
result:=false;
try
//get
with x do
begin
binary:=true;
format:='';
subformat:='';
info:='';//22APR2012
filename:='';
map16:='';//Warning: won't work under D10 - 21aug2020
transparent:=false;
syscolors:=false;
flip:=false;
mirror:=false;
delay:=0;
itemindex:=0;
count:=1;
bpp:=24;
//cursor - 20JAN2012
hotspotX:=0;
hotspotY:=0;
hotspotMANUAL:=false;//use system generated AUTOMATIC hotspot - 03jan2019
//special
owrite32bpp:=false;//22JAN2012
//final
readb64:=false;
readb128:=false;
writeb64:=false;
writeb128:=false;
//internal
iosplit:=0;//none
cellwidth:=0;
cellheight:=0;
use32:=false;
end;
//successful
result:=true;
except;end;
end;
//## msiai ##
function misai(s:tobject):panimationinformation;
begin
result:=@system_default_ai;//always return a pointer to a valid structure
try
if zznil(s,2078) then misaiclear(system_default_ai)
else if (s is tbasicimage) then result:=@(s as tbasicimage).ai
else if (s is tbmp) then result:=@(s as tbmp).ai
else misaiclear(system_default_ai);
except;end;
end;
//## low__aicopy ##
function low__aicopy(var s,d:tanimationinformation):boolean;
begin
//defaults
result           :=false;
try
//get
d.format         :=s.format;
d.subformat      :=s.subformat;
d.filename       :=s.filename;
d.map16          :=s.map16;
d.transparent    :=s.transparent;
d.syscolors      :=s.syscolors;//13apr2021
d.flip           :=s.flip;
d.mirror         :=s.mirror;
d.delay          :=s.delay;
d.itemindex      :=s.itemindex;
d.count          :=s.count;
d.bpp            :=s.bpp;
d.owrite32bpp    :=s.owrite32bpp;
d.binary         :=s.binary;
d.readB64        :=s.readB64;
d.readB128       :=s.readB128;
d.readB128       :=s.readB128;
d.writeB64       :=s.writeB64;
d.writeB128      :=s.writeB128;
d.iosplit        :=s.iosplit;
d.cellwidth      :=s.cellwidth;
d.cellheight     :=s.cellheight;
d.use32          :=s.use32;//22may2022
//.special - 10jul2019
d.hotspotMANUAL  :=s.hotspotMANUAL;
d.hotspotX       :=s.hotspotX;
d.hotspotY       :=s.hotspotY;
//successful
result           :=true;
except;end;
end;
//## misaicopy ##
function misaicopy(s,d:tobject):boolean;
begin
result:=false;
try
if mishasai(d) then
   begin
   if mishasai(s) then result:=low__aicopy(misai(s)^,misai(d)^) else result:=misaiclear(misai(d)^);
   end;
except;end;
end;
//## low__drawdigits ##
function mis__drawdigits(s:tobject;dcliparea:trect;dx,dy,dfontsize,dcolor:longint;x:string;xbold,xdraw:boolean;var dwidth,dheight:longint):boolean;
begin
result:=mis__drawdigits2(s,dcliparea,dx,dy,dfontsize,dcolor,2,x,xbold,xdraw,dwidth,dheight);
end;
//## mis__drawdigits2 ##
function mis__drawdigits2(s:tobject;dcliparea:trect;dx,dy,dfontsize,dcolor:longint;dheightscale:extended;x:string;xbold,xdraw:boolean;var dwidth,dheight:longint):boolean;
label
   skipdone,skipend;
//Draws a series of square numerical digits without the need of tcanvas, tbitmap, tfont or the need for a font
// =====
// | | |
// =====
// | | |
// =====
var
   odx,v1,v2,v3,v4,v5,v6,h1,h2,h3,h4,ddiff,dthick0,dthick,p,x1,x2,y1,y2,dw,dh,dgap,xlen,sbits,sw,sh:longint;
   sai:boolean;
   prows32:pcolorrows32;
   prows24:pcolorrows24;
   prows8 :pcolorrows8;
   c32:tcolor32;
   c24:tcolor24;
    c8:tcolor8;
   //## xdrawarea ##
   procedure xdrawarea(dx1,dx2,dy1,dy2:longint);
   var
      px,py:longint;
   begin
   //scale
   dx1:=dx+dx1;
   dx2:=dx+dx2;
   dy1:=dy+dy1;
   dy2:=dy+dy2;
   //get
   if xdraw then
      begin
      for py:=dy1 to dy2 do
      begin
      if (py>=y1) and (py<=y2) and (py>=dy) then
         begin
         case sbits of
         32:for px:=dx1 to dx2 do if (px>=x1) and (px<=x2) and (px>=odx) then prows32[py][px]:=c32;
         24:for px:=dx1 to dx2 do if (px>=x1) and (px<=x2) and (px>=odx) then prows24[py][px]:=c24;
          8:for px:=dx1 to dx2 do if (px>=x1) and (px<=x2) and (px>=odx) then prows8 [py][px]:=c8;
          end;//case
          end;
      end;//py
      end;
   //.inc size
   dwidth:=largest(dwidth,dx2-odx+1);
   dheight:=largest(dheight,dy2-dy+1);
   end;
   //## xdrawdigit ##
   procedure xdrawdigit(xdigit:longint;xincludegap:boolean);
   label
      skipdone;
   var
      int1:longint;
      //##b ##
      procedure b(x:longint);
      begin
      case x of
      0:xdrawarea(h1,h4,v1,v2);//top horizontal
      1:xdrawarea(h1,h2,v1,v4);//left-top vertical
      2:xdrawarea(h3,h4,v1,v4);//right-top vertical
      3:xdrawarea(h1,h4,v3,v4);//middle horizontal
      4:xdrawarea(h1,h2,v3,v6);//left-bottom vertical
      5:xdrawarea(h3,h4,v3,v6);//right-bottom vertical
      6:xdrawarea(h1,h4,v5,v6);//bottom horizontal
      end;//case
      end;
   begin
   //decide
   case xdigit of
   //.space
   32:inc(dwidth,dw);
   //.plus
   43:begin
      xdrawarea(dthick0*2,dthick0*3-1+ddiff,dthick0,dh-1-dthick0);//v
      xdrawarea(0,dthick0*5-1+ddiff,v3,v4);//h
      end;
   //.comma
   44:begin
      int1:=dthick0;
      xdrawarea(int1+h1+dthick,int1+h1+(2*dthick)-1,v5-(2*dthick0),v6);
      xdrawarea(int1+h1,int1+h2,v5,v6);
      end;
   //.minus
   45:xdrawarea(h1,h4,v3,v4);
   //.dot
   46:xdrawarea(h1,h1+(2*dthick)-1,v6-(dthick*2)+1,v6);
   //.0-9 = 48..57
   48:begin; b(0);b(1);b(2);b(4);b(5);b(6); end;
   49:begin; b(1);b(4); end;
   50:begin; b(0);b(2);b(3);b(4);b(6); end;
   51:begin; b(0);b(2);b(3);b(5);b(6); end;
   52:begin; b(1);b(2);b(3);b(5); end;
   53:begin; b(0);b(1);b(3);b(5);b(6); end;
   54:begin; b(0);b(1);b(3);b(4);b(5);b(6); end;
   55:begin; b(0);b(2);b(5); end;
   56:begin; b(0);b(1);b(2);b(3);b(4);b(5);b(6); end;
   57:begin; b(0);b(1);b(2);b(3);b(5);b(6); end;
   //.A-Z
   65:begin; b(0);b(1);b(4);b(2);b(5);b(3); end;

   else goto skipdone;
   end;

   //done
   skipdone:
   //dx
   dx:=odx+dwidth+low__insint(dgap,xincludegap);
   end;
begin
//defaults
result:=false;
try
dwidth:=0;
dheight:=0;
odx:=dx;
sbits:=8;
sw:=0;
sh:=0;

//heightscale in %
if (dheightscale<=0)        then dheightscale:=4
else if (dheightscale<1)    then dheightscale:=1
else if (dheightscale>10)   then dheightscale:=10;

//check
if xdraw then
   begin
   if not misinfo82432(s,sbits,sw,sh,sai) then exit;
   if (not validarea(dcliparea)) or (dcliparea.right<0) or (dcliparea.left>=sw) or (dcliparea.bottom<0) or (dcliparea.top>=sh) then goto skipdone;
   end;

//convert font height (negative px values) into font size (font width)
if (dfontsize<0) then dfontsize:=round(-dfontsize/dheightscale);

//range
dfontsize:=frcrange32(dfontsize,3,5000);

//init
xlen:=low__length(x);
if (xlen<=0) then goto skipdone;
dthick0:=frcmax32(frcmin32(dfontsize div 5,1),dfontsize div 3);
dthick:=frcmax32(frcmin32(dfontsize div low__aorb(5,2,xbold),1),dfontsize div 3);
ddiff:=dthick-dthick0;
dgap:=dthick*4;//easy to view the numbers at low font size
dw:=dfontsize;
dh:=frcmin32(round(dw*dheightscale),1);

//cliparea tied to safe image area
if xdraw then
   begin
   x1:=frcrange32(dcliparea.left,0,sw-1);
   x2:=frcrange32(dcliparea.right,x1,sw-1);
   y1:=frcrange32(dcliparea.top,0,sh-1);
   y2:=frcrange32(dcliparea.bottom,y1,sh-1);
   //check
   if (dx>x2) or (dy>y2) then goto skipdone;
   end;

//colors + rows
if xdraw then
   begin
   c32:=low__intrgba32(dcolor);
   c24:=low__intrgb(dcolor);
   c8:=low__greyscale2(c24);
   //rows8-32
   if not misrows82432(s,prows8,prows24,prows32) then goto skipend;
   end;

//inner dimensions
v1:=0;
v2:=v1+dthick-1;

v3:=(dh div 2) - (dthick div 2);
v4:=v3+dthick-1;

v5:=dh-1-(dthick-1);
v6:=dh-1;

h1:=0;
h2:=dthick-1;
h3:=dw-1-(dthick-1);
h4:=dw-1;

//get
for p:=1 to xlen do xdrawdigit(byte(x[p-1+stroffset]),p<xlen);

//successful
skipdone:
result:=true;
skipend:
except;end;
end;


//color procs ------------------------------------------------------------------
//## low__greyscale2 ##
function low__greyscale2(var x:tcolor24):byte;
begin
result:=x.r;
if (x.g>result) then result:=x.g;
if (x.b>result) then result:=x.b;
end;
//## rgbint ##
function low__rgbint(x:tcolor24):longint;
var
   a:tint4;
begin
//get
a.r:=x.r;
a.g:=x.g;
a.b:=x.b;
a.a:=0;
//set
result:=a.val;
end;
//## rgbaint ##
function low__rgbaint(x:tcolor32):longint;
var
   a:tint4;
begin
//get
a.r:=x.r;
a.g:=x.g;
a.b:=x.b;
a.a:=x.a;
//set
result:=a.val;
end;
//## low__rgb ##
function low__rgb(r,g,b:byte):longint;
var
   x:tint4;
begin
x.r:=r;
x.g:=g;
x.b:=b;
x.a:=0;
result:=x.val;
end;
//## low__rgb24 ##
function low__rgb24(r,g,b:byte):tcolor24;
begin
result.r:=r;
result.g:=g;
result.b:=b;
end;
//## low__rgba32 ##
function low__rgba32(r,g,b,a:byte):tcolor32;//25nov2023
begin
result.r:=r;
result.g:=g;
result.b:=b;
result.a:=a;
end;
//## low__rgba ##
function low__rgba(r,g,b,a:byte):longint;
var
   x:tint4;
begin
x.r:=r;
x.g:=g;
x.b:=b;
x.a:=a;
result:=x.val;
end;
//## low__rgb32to24 ##
function low__rgb32to24(var x:tcolor32):tcolor24;//21jun2022
begin
result.r:=x.r;
result.g:=x.g;
result.b:=x.b;
end;
//## low__rgb24to32 ##
function low__rgb24to32(var x:tcolor24;xa:byte):tcolor32;//21jun2022
begin
result.r:=x.r;
result.g:=x.g;
result.b:=x.b;
result.a:=xa;
end;
//## ppBlend32 ##
function ppBlend32(var s,snew:tcolor32):boolean;//color / pixel processor - 30nov2023
var//250ms -> 235ms -> 218ms -> 204ms per 10,000,000 calls
   v1,v2,da,daBIG:longint;
begin
//defaults
result:=false;
//decide
if (snew.a=0) then exit
else if (snew.a=255) then
   begin
   result:=true;
   s:=snew;
   exit;
   end;
//get
v1:=snew.a*255;
v2:=s.a*(255-snew.a);
da:=snew.a + (v2 div 255);//must div by 255 exactly, otherwise subtle color loss creeps in damaging the image
daBIG:=v1 + v2;
s.r:=( (snew.r*v1) + (s.r*v2) ) div daBIG;
s.g:=( (snew.g*v1) + (s.g*v2) ) div daBIG;
s.b:=( (snew.b*v1) + (s.b*v2) ) div daBIG;
s.a:=da;
//successful
result:=true;
end;
{
//----------------------------------------------------------------------START---
//reference for ppBlend32 - original floating point algorithms
var//250ms -> 235ms -> 218ms -> 204ms per 10,000,000 calls
   sr,sg,sb,sa,nr,ng,nb,na,dr,dg,db,da:extended;
begin
//defaults
result:=false;
//decide
if (snew.a=0) then exit
else if (snew.a=255) then
   begin
   result:=true;
   s:=snew;
   exit;
   end;
//init
//.n
nr:=snew.r / 255;
ng:=snew.g / 255;
nb:=snew.b / 255;
na:=snew.a / 255;
//.s
sr:=s.r / 255;
sg:=s.g / 255;
sb:=s.b / 255;
sa:=s.a / 255;

da:=na + (sa*(1-na));
dr:=( (nr*na) + (sr*sa*(1-na)) ) / da;
dg:=( (ng*na) + (sg*sa*(1-na)) ) / da;
db:=( (nb*na) + (sb*sa*(1-na)) ) / da;

s.r:=round(dr*255);
s.g:=round(dg*255);
s.b:=round(db*255);
s.a:=round(da*255);
//------------------------------------------------------------------------END---
{}
//## ppBlendColor32 ##
function ppBlendColor32(var s,snew:tcolor32):boolean;//color blending / pixel processor - 01dec2023
begin
//defaults
result:=false;
//check
if (s.a=0) or (snew.a=0) then exit;
//get
s.r:=((snew.r*snew.a) + (s.r*(255-snew.a))) div 255;
s.g:=((snew.g*snew.a) + (s.g*(255-snew.a))) div 255;
s.b:=((snew.b*snew.a) + (s.b*(255-snew.a))) div 255;
//successful
result:=true;
end;
//## low__colbright ##
function low__colbright(x:longint):longint;
var
   a:tint4;
begin
result:=0;
a.val:=x;
if (a.r>result) then result:=a.r;
if (a.g>result) then result:=a.g;
if (a.b>result) then result:=a.b;
end;
//## low__colsplice ##
function low__colsplice(x,c1,c2:longint):longint;
var
   a,b:tint4;
   P1,P2:longint;
begin
{Error}
result:=0;
try
{P1 & P2}
x:=frcrange32(x,0,100);
P1:=(X*100) Div 100;
P2:=100-P1;
{Color}
a.val:=c1;
b.val:=c2;
a.R:=(a.R*P1+b.R*P2) Div 100;
a.G:=(a.G*P1+b.G*P2) Div 100;
a.B:=(a.B*P1+b.B*P2) Div 100;
{Return Result}
Result:=a.val;
except;end;
end;
//## low__colsplice1 ##
function low__colsplice1(xpert:extended;s,d:longint):longint;//13nov2022
begin//xpert range is 0..1 (0=0% and 0.5=50% and 1=100%)
result:=0;try;result:=low__rgbint(low__rgbsplice24(xpert,low__intrgb(s),low__intrgb(d)));except;end;
end;
//## low__compare24 ##
function low__compare24(s,d:tcolor24):boolean;
begin
result:=(s.r=d.r) and (s.g=d.g) and (s.b=d.b);
end;
//## low__compare32 ##
function low__compare32(s,d:tcolor32):boolean;
begin
result:=(s.r=d.r) and (s.g=d.g) and (s.b=d.b) and (s.a=d.a);
end;
//## low__rgbsplice24 ##
function low__rgbsplice24(xpert:extended;s,d:tcolor24):tcolor24;//17may2022
var//xpert range is 0..1 (0=0% and 0.5=50% and 1=100%)
   p2:extended;
   v:longint;
begin
//defaults
result:=s;
try
//init
if (xpert<0) then xpert:=0 else if (xpert>1) then xpert:=1;
p2:=1-xpert;
//r
v:=round((d.r*xpert)+(s.r*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.r:=v;
//g
v:=round((d.g*xpert)+(s.g*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.g:=v;
//b
v:=round((d.b*xpert)+(s.b*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.b:=v;
except;end;
end;
//## low__rgbsplice32 ##
function low__rgbsplice32(xpert:extended;s,d:tcolor32):tcolor32;//06dec2023
var//xpert range is 0..1 (0=0% and 0.5=50% and 1=100%)
   p2:extended;
   v:longint;
begin
//defaults
result:=s;
try
//init
if (xpert<0) then xpert:=0 else if (xpert>1) then xpert:=1;
p2:=1-xpert;
//r
v:=round((d.r*xpert)+(s.r*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.r:=v;
//g
v:=round((d.g*xpert)+(s.g*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.g:=v;
//b
v:=round((d.b*xpert)+(s.b*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.b:=v;
//a
v:=round((d.a*xpert)+(s.a*p2));
if (v<0) then v:=0 else if (v>255) then v:=255;
result.a:=v;
except;end;
end;
//## low__sc ##
function low__sc(sc,dc,pert:longint):longint;//shift color
begin
result:=0;try;result:=low__colsplice(frcrange32(pert,0,100),dc,sc);except;end;
end;
//## low__sc1 ##
function low__sc1(xpert:extended;sc,dc:longint):longint;//shift color
begin
result:=0;try;result:=low__colsplice1(xpert,sc,dc);except;end;
end;
//## dc ##
function low__dc(x,y:longint):longint;//differential color
label
     redo;
var
   once:boolean;
   ox,a:tint4;
   by,z:longint;
begin
result:=0;
try
//prepare
once:=true;
ox.val:=x;
//y check
if (y=0) then
   begin
   result:=ox.val;
   exit;
   end;//end of if
//check for "black"
//.y
//yyyyyyyyyyyyyyyyyif (colbright(ox.val)<100) then y:=100;
//.by
by:=y;
if (by<0) then by:=-by;
by:=by div 2;
//a.val
a.val:=ox.val;
//process
redo:
//.r
z:=(a.r+y);if (z<0) then z:=0 else if (z>255) then z:=255;a.r:=z;
//.g
z:=(a.g+y);if (z<0) then z:=0 else if (z>255) then z:=255;a.g:=z;
//.b
z:=(a.b+y);if (z<0) then z:=0 else if (z>255) then z:=255;a.b:=z;
//check
if once and (low__nrw(low__colbright(a.val),low__colbright(ox.val),by) or (low__nrw(a.r,ox.r,by) and low__nrw(a.g,ox.g,by) and low__nrw(a.b,ox.b,by))) then
   begin
   a.val:=ox.val;
   y:=-y;
   once:=false;
   goto redo;
   end;//end of if
//return result
result:=a.val;
except;end;
end;
//## low__cv ##
function low__cv(col,bgcolor,by:longint):boolean;//color visible
var
   c,b:tint4;
   //## xccv ##
   function xccv(x,y:byte;by:longint):boolean;
   begin
   if (by<0) then by:=30;
   result:=(low__posn(x-y)>=by);
   end;
begin
result:=false;
try
c.val:=col;
b.val:=bgcolor;
result:=xccv(c.bytes[0],b.bytes[0],by) or xccv(c.bytes[1],b.bytes[1],by) or xccv(c.bytes[2],b.bytes[2],by);
except;end;
end;
//## low__ecv ##
function low__ecv(col,bgcolor,by:longint):longint;//ensure color visible
begin
result:=col;
try;if not low__cv(result,bgcolor,by) then result:=low__invert2b(result,true);except;end;
end;
//## low__brightness ##
function low__brightness(x:longint;var xout:longint):boolean;
var
   a:tint4;
begin
result:=true;
try
xout:=0;
a.val:=x;
if (a.r>xout) then xout:=a.r;
if (a.g>xout) then xout:=a.g;
if (a.b>xout) then xout:=a.b;
except;end;
end;
//## low__brightnessb ##
function low__brightnessb(x:longint):longint;
begin
low__brightness(x,result);
end;
//## low__brightness2 ##
function low__brightness2(x:longint;var xout:longint):boolean;//27mar2021
var
   a:tint4;
begin
result:=true;
try
xout:=0;
a.val:=x;
xout:=(a.r+a.g+a.b) div 3;
except;end;
end;
//## low__brightness2b ##
function low__brightness2b(x:longint):longint;
begin
low__brightness2(x,result);
end;
//## low__invert ##
function low__invert(x:longint;var xout:longint):boolean;
begin
result:=true;low__invert2(x,false,xout);
end;
//## low__invert2 ##
function low__invert2(x:longint;xgreycorrection:boolean;var xout:longint):boolean;
var
   a:tint4;
   b:longint;
begin
//defaults
result:=true;
try
xout:=x;
//get
if xgreycorrection and low__brightness(x,b) and (b>=100) and (b<=156) then
   begin
   xout:=low__rgb(255,255,255);
   exit;
   end;
//invert
a.val:=x;
a.r:=255-a.r;
a.g:=255-a.g;
a.b:=255-a.b;
xout:=a.val;
except;end;
end;
//## low__invertb ##
function low__invertb(x:longint):longint;
begin
low__invert2(x,false,result);
end;
//## low__invert2b ##
function low__invert2b(x:longint;xgreycorrection:boolean):longint;
begin
low__invert2(x,xgreycorrection,result);
end;
//## low__intrgb ##
function low__intrgb(x:longint):tcolor24;
var
   a:tint4;
begin
//get
a.val:=x;
//set
result.r:=a.r;
result.g:=a.g;
result.b:=a.b;
end;
//## low__intrgb32 ##
function low__intrgb32(x:longint;aval:byte):tcolor32;
var
   a:tint4;
begin
//get
a.val:=x;
//set
result.r:=a.r;
result.g:=a.g;
result.b:=a.b;
result.a:=aval;
end;
//## low__intrgba32 ##
function low__intrgba32(x:longint):tcolor32;
var
   a:tint4;
begin
//get
a.val:=x;
//set
result.r:=a.r;
result.g:=a.g;
result.b:=a.b;
result.a:=a.a;//fixed - 17nov2023
end;


//logic procs ------------------------------------------------------------------
//## low__aorbimg ##
function low__aorbimg(a,b:tbasicimage;xuseb:boolean):tbasicimage;//30nov2023
begin
if xuseb then result:=b else result:=a;
end;

end.

