unit gossmake;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef WIN64}{$define 64bit}{$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d`3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps{$ifdef gamecore}, gossgame ,gamefiles{$endif};
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
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
//## Library.................. Dynamic content generators for interactive archive support
//## Version.................. 1.00.3010 (+89)
//## Items.................... 11
//## Last Updated ............ 05sep2026, 02sep2026, 30aug2026, 30jul2026, 25jun2026, 18jun2026, 15jun2026, 14jun2026, 13jun2026, 12jun2026, 11jun2026, 08jun2026, 06jun2026
//## Lines of Code............ 10,200+
//## Origin .................. Human generated and maintained
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy          | Version   | Date        | Update history / brief description of function
//## |------------------------|--------------------|-----------|-------------|--------------------------------------------------------
//## | tartfilter             | tobject            | 1.00.420  | 13jun2026   | Color pixel modifier - 08jun2026, 07jun2026, 06jun2026
//## | tartbase               | tobject            | 1.00.830  | 12jun2026   | Dynamic image construction - 07jun2026, 06jun2026
//## | tcursorbase            | tobject            | 1.00.670  | 13jun2026   | Dynamic cursor base class - 11jun2026
//## | tcursordefault         | tcursorbase        | 1.00.150  | 30aug2026   | Dynamic standard cursor: supports standard, outline, and solid shapes - 30jul2026, 13jun2026, 12jun2026, 11jun2026
//## | tcursormodern          | tcursordefault     | 1.00.080  | 30jul2026   | Dynamic modern cursor: supports standard and solid shapes, outline disabled for now - 13jun2026, 12jun2026, 11jun2026
//## | tmakebase              | tobject            | 1.00.201  | 13jun2026   | Generator base class - 06jun2026, 30may2026, 29may2026
//## | tmaketest              | tmakebase          | 1.00.002  | 06jun2026   | Test generator - 29may2026
//## | tmakecursor            | tobject            | 1.00.402  | 18jun2026   | Cursor generator - 15jun2026, 13jun2026, 06jun2026, 23may2026, 22may2026
//## | tmakecursordefault     | tmakecursor        | 1.00.050  | 13jun2026   | Default cursor generator - 12jun2026, 11jun2026, 10jun2026
//## | tmakecursormodern      | tmakecursordefault | 1.00.005  | 13jun2026   | Modern cursor generator - 12jun2026
//## | tmakewallpaper         | tobject            | 1.00.111  | 02sep2026   | Wallpaper generator - 06jun2026, 23may2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================

const

   //wallpapers ----------------------------------------------------------------

   //wallpaper color modifier
   wcm_normal         =0;
   wcm_hue0           =1;
   wcm_hue1           =2;
   wcm_hue2           =3;
   wcm_hue3           =4;
   wcm_hue4           =5;
   wcm_hue5           =6;
   wcm_hue6           =7;
   wcm_hue7           =8;
   wcm_hue8           =9;
   wcm_hue9           =10;
   wcm_hue10          =11;
   wcm_hue11          =12;

   wcm_pink           =13;
   wcm_sweetblue      =14;
   wcm_red            =15;
   wcm_green          =16;
   wcm_blue           =17;
   wcm_yellow         =18;
   wcm_sepia          =19;

   wcm_invertR2       =20;
   wcm_invertG2       =21;
   wcm_invertB2       =22;
   wcm_invertR        =23;
   wcm_invertG        =24;
   wcm_invertB        =25;
   wcm_invertRGB      =26;

   wcm_max            =26;

   wem_mix1           ='a';
   wem_mix2           ='b';
   wem_mix3           ='c';
   wem_mix4           ='d';
   wem_mix5           ='e';
   wem_skew1          ='f';
   wem_skew2          ='g';
   wem_skew3          ='h';



   //cursors -------------------------------------------------------------------

   //common for all cursors
   cursor_minsize     =32;
   cursor_maxsize     =128;
   cursor_celllimit   =72;
   cursorspeed_min    =25;//25jun2026
   cursorspeed_max    =200;


   //(c)ursor type inde(x) codes
   cx_cf              =0;
   cx_cc              =1;
   cx_cb              =2;
   cx_ct              =3;
   cx_cv              =4;
   cx_co              =5;
   cx_ca              =6;
   cx_max             =6;


   //cursor colors - values generated by cc__makeNameList
   cc_customcolor     =0;
   cc_customcolorMAX  =0;

   cc_rainbow         =1;
   cc_rainbow2        =2;
   cc_rainbow3        =3;
   cc_rainbow4        =4;
   cc_rainbow5        =5;
   cc_rainbowMAX      =5;

   cc_red             =6;
   cc_red2            =7;
   cc_red3            =8;
   cc_red4            =9;
   cc_red5            =10;
   cc_red6            =11;
   cc_red7            =12;
   cc_red8            =13;
   cc_red9            =14;
   cc_red10           =15;
   cc_redMAX          =15;

   cc_green           =16;
   cc_green2          =17;
   cc_green3          =18;
   cc_green4          =19;
   cc_green5          =20;
   cc_green6          =21;
   cc_green7          =22;
   cc_green8          =23;
   cc_green9          =24;
   cc_green10         =25;
   cc_greenMAX        =25;

   cc_blue            =26;
   cc_blue2           =27;
   cc_blue3           =28;
   cc_blue4           =29;
   cc_blue5           =30;
   cc_blue6           =31;
   cc_blue7           =32;
   cc_blue8           =33;
   cc_blue9           =34;
   cc_blue10          =35;
   cc_blueMAX         =35;

   cc_yellow          =36;
   cc_yellow2         =37;
   cc_yellow3         =38;
   cc_yellow4         =39;
   cc_yellow5         =40;
   cc_yellow6         =41;
   cc_yellow7         =42;
   cc_yellow8         =43;
   cc_yellow9         =44;
   cc_yellow10        =45;
   cc_yellowMAX       =45;

   cc_aqua            =46;
   cc_aqua2           =47;
   cc_aqua3           =48;
   cc_aqua4           =49;
   cc_aqua5           =50;
   cc_aqua6           =51;
   cc_aqua7           =52;
   cc_aqua8           =53;
   cc_aqua9           =54;
   cc_aqua10          =55;
   cc_aquaMAX         =55;

   cc_orange          =56;
   cc_orange2         =57;
   cc_orange3         =58;
   cc_orange4         =59;
   cc_orange5         =60;
   cc_orange6         =61;
   cc_orange7         =62;
   cc_orange8         =63;
   cc_orange9         =64;
   cc_orange10        =65;
   cc_orangeMAX       =65;

   cc_purple          =66;
   cc_purple2         =67;
   cc_purple3         =68;
   cc_purple4         =69;
   cc_purple5         =70;
   cc_purple6         =71;
   cc_purple7         =72;
   cc_purple8         =73;
   cc_purple9         =74;
   cc_purple10        =75;
   cc_purpleMAX       =75;

   cc_pink            =76;
   cc_pink2           =77;
   cc_pink3           =78;
   cc_pink4           =79;
   cc_pink5           =80;
   cc_pink6           =81;
   cc_pink7           =82;
   cc_pink8           =83;
   cc_pink9           =84;
   cc_pink10          =85;
   cc_pinkMAX         =85;

   cc_white           =86;
   cc_white2          =87;
   cc_white3          =88;
   cc_white4          =89;
   cc_white5          =90;
   cc_white6          =91;
   cc_white7          =92;
   cc_white8          =93;
   cc_white9          =94;
   cc_white10         =95;
   cc_whiteMAX        =95;

   cc_grey            =96;
   cc_grey2           =97;
   cc_grey3           =98;
   cc_grey4           =99;
   cc_grey5           =100;
   cc_grey6           =101;
   cc_grey7           =102;
   cc_grey8           =103;
   cc_grey9           =104;
   cc_grey10          =105;
   cc_greyMAX         =105;

   cc_black           =106;
   cc_black2          =107;
   cc_black3          =108;
   cc_black4          =109;
   cc_black5          =110;
   cc_black6          =111;
   cc_black7          =112;
   cc_black8          =113;
   cc_black9          =114;
   cc_black10         =115;
   cc_blackMAX        =115;

   cc_brown           =116;
   cc_brown2          =117;
   cc_brown3          =118;
   cc_brown4          =119;
   cc_brown5          =120;
   cc_brown6          =121;
   cc_brown7          =122;
   cc_brown8          =123;
   cc_brown9          =124;
   cc_brown10         =125;
   cc_brownMAX        =125;

   cc_max             =126;


   //cursor bits
   cb_32                =0;
   cb_8                 =1;
   cb_max               =1;


   //cursor opacity %
   co_100               =0;
   co_75                =1;
   co_50                =2;
   co_30                =3;
   co_max               =3;


   //cursor animation
   ca_static            =0;//1  cell
   ca_8cell             =1;
   ca_16cell            =2;
   ca_24cell            =3;
   ca_48cell            =4;
   ca_72cell            =5;
   ca_max               =5;

   //cursor type
   ct_plain             =0;
   ct_sparkle           =1;
   ct_hstripe           =2;
   ct_vstripe           =3;
   ct_pulse             =4;
   ct_flat              =5;
   ct_colors            =6;
   ct_colors2           =7;
   ct_colors3           =8;
   ct_max               =8;


   //cursor canvas
   cv_standard          =0;//black edges
   cv_whiteedge         =1;//white edges
   cv_goldedge          =2;//gold edges
   cv_outline           =3;
   cv_solid             =4;
   cv_tone              =5;
   cv_max               =5;


   //tmakebase -----------------------------------------------------------------
   mb_namelimit       =50;
   mb_typelimit       =10;
   mb_vallimit        =30;


   //tmakecursor ---------------------------------------------------------------
   //.cursor extensions
   ce_ani               =0;
   ce_cur               =1;
   ce_max               =1;


type

   tcommonimage       =tbasicimage;
   tartfilter         =class;
   tartbase           =class;


   //cursors -------------------------------------------------------------------

   tcursorcolorset    =record

    edge              :longint32;//clnone=not set
    body              :longint32;
    body2             :longint32;
    body3             :longint32;
    sparkle           :longint32;
    speed             :longint32;
    mirror            :boolean;

    end;

   tcursorclass       =( ccl_default ,ccl_modern );

   tmakecursorinfo=record

     n                :longint32;
     cf               :longint32;
     cc               :longint32;
     cb               :longint32;
     co               :longint32;
     ca               :longint32;
     ct               :longint32;
     cv               :longint32;

    end;

   tanimationinfo=record

    cellwidth         :longint32;
    cellheight        :longint32;
    cellcount         :longint32;
    delay             :longint32;

    //misc
    cursorinfo        :tmakecursorinfo;

    end;

   tcustomcursorcolors=record

    //shared color set for all custom cursors
    changeId          :longint32;
    canEdit           :boolean;
    canSpeed          :boolean;
    useShared         :boolean;
    shared            :tcursorcolorset;
    info              :tmakecursorinfo;//info only
    infoInit          :boolean;

    //individual color sets for each individual custom cursor
    clist             :array[0..cf_max] of tcursorcolorset;
    cf_index          :longint32;//currently selected cursor for color editing -> -1=off/disabled

    //other
    statusCaching     :boolean;

    end;

   tcustomwallpapereffects=record

    changeId          :longint32;
    mirror            :boolean;
    pixelate          :longint32;//0=off
    fade              :longint32;//0=off
    brightness        :longint32;//0=off

    end;


{tartfilter}
   tartdrawmode       =( dm_raw ,dm_lum  ,dm_luminv ,dm_replace ,dm_whites ,dm_blacks ,dm_alpha );
   tartlinemode       =( lm_none ,lm_horz   ,lm_horz2   ,lm_vert   ,lm_vert2  );
   tartrotate         =( rt_0    ,rt_90     ,rt_180     ,rt_270 );
   tartbendmode       =( bm_flat ,bm_flat2  ,bm_hill    ,bm_slope );

   tartfilterlist=record

    ok                :boolean;
    x1                :longint32;
    x2                :longint32;
    color1            :tcolor24;
    color2            :tcolor24;
    clist             :array[0..255] of tcolor24;
    power255          :array[0..255] of byte;//0..255
    mode              :tartbendmode;
    bend              :double;//0..1
    power             :double;//-1..0..1

    end;

   tartfilter=class(tobject)
   private

    hlist             :tartfilterlist;
    vlist             :tartfilterlist;
    iarea             :twinrect;
    idrawmode         :tartdrawmode;
    ilinemode         :tartlinemode;
    ilinesize         :longint32;
    ilinestep         :longint32;
    ilinethre         :longint32;
    isparkle20        :longint32;
    ithreshold255     :longint32;
    ipower255         :longint32;
    irandompos        :longint32;
    imustsync         :boolean;

    procedure xsync;
    procedure setlinesize(x:longint32);
    procedure setsparkle20(x:longint32);
    procedure setpower255(x:longint32);
    procedure setthreshold255(x:longint32);

    function  gethmode:tartbendmode;
    procedure sethmode(const x:tartbendmode);
    function  gethbend:double;
    procedure sethbend(const x:double);
    function  gethpower:double;
    procedure sethpower(const x:double);
    procedure sethcolor1(const x:tcolor24);
    procedure sethcolor2(const x:tcolor24);
    function  gethcolor1:tcolor24;
    function  gethcolor2:tcolor24;

    function  getvmode:tartbendmode;
    procedure setvmode(const x:tartbendmode);
    function  getvbend:double;
    procedure setvbend(const x:double);
    function  getvpower:double;
    procedure setvpower(const x:double);
    procedure setvcolor1(const x:tcolor24);
    procedure setvcolor2(const x:tcolor24);
    function  getvcolor1:tcolor24;
    function  getvcolor2:tcolor24;

   public

    //create
    constructor create;  virtual;
    destructor  destroy; override;

    //area -> sets work area -> required before this object can be used
    property  area                               :twinrect           read iarea;
    procedure setarea(const d:twinrect);
    procedure setarea2(const d:tartbase);

    //horizontal shade
    property  hcolor1                            :tcolor24           read gethcolor1     write sethcolor1;
    property  hcolor2                            :tcolor24           read gethcolor2     write sethcolor2;
    property  hpower                             :double             read gethpower      write sethpower;//-1..0..1
    property  hbend                              :double             read gethbend       write sethbend;//0..1
    property  hmode                              :tartbendmode       read gethmode       write sethmode;

    //vertical shade
    property  vcolor1                            :tcolor24           read getvcolor1     write setvcolor1;
    property  vcolor2                            :tcolor24           read getvcolor2     write setvcolor2;
    property  vpower                             :double             read getvpower      write setvpower;//-1..0..1
    property  vbend                              :double             read getvbend       write setvbend;//0..1
    property  vmode                              :tartbendmode       read getvmode       write setvmode;

    //filter properties
    property  drawmode                           :tartdrawmode       read idrawmode      write idrawmode;
    property  power255                           :longint32          read ipower255      write setpower255;
    property  linemode                           :tartlinemode       read ilinemode      write ilinemode;
    property  linesize                           :longint32          read ilinesize      write setlinesize;//1..32
    property  sparkle20                          :longint32          read isparkle20     write setsparkle20;//0..20
    property  threshold255                       :longint32          read ithreshold255  write setthreshold255;

    //filter
    procedure filter32(const dx,dy:longint32;s32:tcolor32;var d32:tcolor32);

    //clear
    procedure clear;
    procedure defaults;

    //copy
    procedure copyfrom(const x:tartfilter);

    //static random
    procedure resetRandom(const cindex,xmoreseparation:longint32);

   end;


{tartbase}
   tartbase=class(tobject)
   private

    iimage            :tcommonimage;
    isrs32            :pcolorrows32;
    icellindex        :longint32;
    icellcount        :longint32;
    icellwidth        :longint32;
    icellheight       :longint32;
    icelldelay        :longint32;
    ihotx             :longint32;//common for all cells
    ihoty             :longint32;
    iworkarea         :array[0..199] of twinrect;//workarea per cell
    iwidth            :longint32;
    iheight           :longint32;
    imapcount         :longint32;
    imaplist          :array[0..199] of byte;//map a virtual cellcount over the real cellcount - optional
    ifilter           :tartfilter;//change "image" pixels on-the-fly

    function getworkarea(cindex:longint):twinrect;
    procedure setcellindex(x:longint32);
    function xrotate32(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32;xshiftdeg:extended;const dmirror:boolean):boolean;//25jun2026, 12jun2026, 29sep2018

   public

    //create
    constructor create;                                                                            virtual;
    procedure   on__create;                                                                        virtual;
    procedure   on__destroy;                                                                       virtual;
    destructor  destroy;                                                                           override;

    //information
    property  cellindex                                                        :longint32          read icellindex        write setcellindex;
    property  cellcount                                                        :longint32          read icellcount;
    property  cellwidth                                                        :longint32          read icellwidth;
    property  cellheight                                                       :longint32          read icellheight;
    property  hotx                                                             :longint32          read ihotx;
    property  hoty                                                             :longint32          read ihoty;
    function  cellarea                                                         :twinrect;//via icellindex
    property  workarea[cindex:longint32]                                       :twinrect           read getworkarea;//used area for 1st cell
    property  width                                                            :longint32          read iwidth;//total width
    property  height                                                           :longint32          read iheight;//total height = cellheight
    property  image                                                            :tcommonimage       read iimage;//read-only -> do not change size etc
    property  filter                                                           :tartfilter         read ifilter;

    //io
    function loadfrom(const x:array of byte)                                                       :boolean;
    function loadfrom2(const x:array of byte;const xforceCellCount,xforceDelay:longint32)          :boolean;

    //pixel
    procedure setRGBA(const cindex,dx,dy:longint32;const r,g,b,a:byte);
    procedure setRGB (const cindex,dx,dy:longint32;const r,g,b:byte);

    //draw
    function  draw (const d:tcommonimage;cindex:longint32;const ddx,ddy:longint32)                                            :boolean;
    function  draw2(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32)                                  :boolean;
    function  draw3(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32;const dmirror,dflip:boolean)      :boolean;
    function  draw4(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32;const drotate:tartrotate;const dmirror:boolean)         :boolean;
    function  draw5(const d:tcommonimage;cindex:longint32;ddx,ddy:longint32;const dpower255:longint32;const xrotate:extended;const dmirror:boolean) :boolean;

    //map support -> for use with an alternative cellcount
    property  mapCount                                                                                                        :longint32 read imapcount;
    procedure setmapCount(const dnewCellCount:longint32);

    function  mapdraw (const d:tcommonimage;const cindex,ddx,ddy:longint32)                                                   :boolean;
    function  mapdraw2(const d:tcommonimage;const cindex,ddx,ddy,dpower255:longint32)                                         :boolean;
    function  mapdraw3(const d:tcommonimage;const cindex,ddx,ddy,dpower255:longint32;const dmirror,dflip:boolean)             :boolean;
    function  mapdraw4(const d:tcommonimage;const cindex,ddx,ddy,dpower255:longint32;const drotate:tartrotate;const dmirror:boolean) :boolean;

   end;

//3333333333333333333333333333333
{tcursorbase}
   tcursorposition=record

    r                 :extended;//rotation
    x                 :longint32;
    y                 :longint32;
    w                 :longint32;
    h                 :longint32;

    end;

   tcursorpositionlist=array[0..4] of tcursorposition;
   
   tcursorbase=class(tobject)
   private

    iart              :tartbase;//auto-create
    iart2             :tartbase;//auto-create
    iart3             :tartbase;//auto-create
    ihotX             :longint32;
    ihotY             :longint32;
    ihollow           :boolean;
    isolid            :boolean;
    isize             :longint32;
    iopacity          :longint32;
    isparkle          :boolean;
    ihstripe          :boolean;
    ivstripe          :boolean;
    ianimate          :boolean;
    ipulse            :boolean;
    iflat             :boolean;
    imirror           :boolean;
    iwidth            :longint32;
    iheight           :longint32;
    icellcount        :longint32;
    icellcount2       :longint32;
    icellcount4       :longint32;
    icellcount8       :longint32;
    icfindex          :longint32;
    idelay            :longint32;
    ibytes            :longint32;
    ilastref          :string;
    iiobusy           :boolean;

    iedgeColor        :longint32;
    ibodyColor1       :longint32;//dark shade color -> left and right extremes
    ibodyColor2       :longint32;//main body color
    ibodyColor3       :longint32;//extra body color -> used by ct_colors to generate a 2-color vertical shade
    isparkleColor     :longint32;

    //animation support
    ipert1            :extended;
    ipert2            :extended;
    ipert4            :extended;
    ipert8            :extended;

    function  xicoMultiResolution__todata32(const xcellindex,xcellcount:longint32;const xdata:tstr8;const dPNG,xascendingSizeOrder:boolean):boolean;//20jun2026
    function  xico__todata32(const dcell32:tcommonimage;const xdata:tstr8;const dfullHeader,dPNG:boolean):boolean;
    function  xbmp__toicondata32(const dcell32:tcommonimage;const xdata:tstr8) :boolean;//24may2026
    function  xbmp__toicondata1(const dcell32:tcommonimage;const xdata:tstr8)  :boolean;//24may2026
    function  xfindWantSize(const xwantsize:longint32)                         :tcursorbase;
    procedure setsize(x:longint32);
    procedure xsyncSize;
    procedure xautoload;                                                                                                         virtual;

    //percentage (0..1) based on cell index within "on__celldraw()" proc
    property pert1                                                             :extended           read ipert1;
    property pert2                                                             :extended           read ipert2;
    property pert4                                                             :extended           read ipert4;
    property pert8                                                             :extended           read ipert8;

    function pert1R(const xreverse:boolean)                                    :extended;
    function pert2R(const xreverse:boolean)                                    :extended;
    function pert4R(const xreverse:boolean)                                    :extended;
    function pert8R(const xreverse:boolean)                                    :extended;

   public

    //optional sub-resolution handlers
    altlist                                                                    :array[0..9] of tcursorbase;

    //info
    info                                                                       :tmakecursorinfo;

    //create
    constructor create;                                                                                                          virtual;
    procedure   on__filtersize(var x:longint32);                                                                                 virtual;
    procedure   on__filterinfo(var x:tmakecursorinfo);                                                                           virtual;
    procedure   on__load;                                                                                                        virtual;
    procedure   on__create;                                                                                                      virtual;
    procedure   on__cell(const dcell32:tcommonimage;const cindex,ccount:longint32);                                              virtual;
    procedure   on__cellinfo(const cindex:longint);                                                                              virtual;
    procedure   on__cellfirst(const dcell32:tcommonimage;const cindex,ccount:longint32);                                         virtual;
    procedure   on__position(var v:tcursorpositionlist;var xmirror:boolean);                                                     virtual;
    procedure   on__celldraw(const dcell32:tcommonimage;const cindex,ccount:longint32;var xmirror:boolean);                      virtual;
    procedure   on__mirror(const dcell32:tcommonimage;const xhotX:boolean);                                                      virtual;//25jun2026
    procedure   on__destroy;                                                                                                     virtual;
    destructor  destroy;                                                                                                         override;

    //information
    property hollow                                                            :boolean            read ihollow;
    property solid                                                             :boolean            read isolid;
    property pulse                                                             :boolean            read ipulse;
    property flat                                                              :boolean            read iflat;
    property mirror                                                            :boolean            read imirror;
    property size                                                              :longint32          read isize                    write setsize;
    property cfindex                                                           :longint32          read icfindex;
    property opacity                                                           :longint32          read iopacity;
    property sparkle                                                           :boolean            read isparkle;
    property hstripe                                                           :boolean            read ihstripe;
    property vstripe                                                           :boolean            read ivstripe;
    property animate                                                           :boolean            read ianimate;
    property hotX                                                              :longint32          read ihotX                    write ihotX;
    property hotY                                                              :longint32          read ihotY                    write ihotY;
    property width                                                             :longint32          read iwidth;
    property height                                                            :longint32          read iheight;
    property cellcount                                                         :longint32          read icellcount;
    property delay                                                             :longint32          read idelay;
    property bytes                                                             :longint32          read ibytes;

    //colors
    property edgeColor                                                         :longint32          read iedgeColor               write iedgeColor;
    property bodyColor1                                                        :longint32          read ibodyColor1              write ibodyColor1;
    property bodyColor2                                                        :longint32          read ibodyColor2              write ibodyColor2;
    property bodyColor3                                                        :longint32          read ibodyColor3              write ibodyColor3;
    property sparkleColor                                                      :longint32          read isparkleColor            write isparkleColor;

    //core values
    procedure setinfo(x:tmakecursorinfo);                                                                                        virtual;

    //art handlers
    function art                                                               :tartbase;
    function art2                                                              :tartbase;
    function art3                                                              :tartbase;

    function canart                                                            :boolean;
    function canart2                                                           :boolean;
    function canart3                                                           :boolean;

    procedure clearArts;

    //io
    property iobusy                                                                      :boolean  read iiobusy;
    function todata(const xdata:tstr8)                                                   :boolean;                               virtual;
    function tofile(const xfilename:string)                                              :boolean;                               virtual;

    //.these procs will fail when "iobusy=true"
    function toanimation(const xwantSize:longint32;const ximage:tcommonimage)            :boolean;                               virtual;
    function toanimationinfo(const xwantSize:longint32;var x:tanimationinfo)             :boolean;                               virtual;
    function toanimationcell(const xwantSize,xcellindex:longint32;const ximage:tcommonimage):boolean;                            virtual;

   end;


//33333333333333333333333
{tcursordefault}
   tcursordefault=class(tcursorbase)
   private

    procedure xdrawbase(const dcell32:tcommonimage;const xart:tartbase;const dx,dy:longint32;const xedgeColor1,xedgeColor2,xbaseColor:tcolor24;const xrotate:extended;const xmirror,xhotspot:boolean);

   public

    procedure   on__filtersize(var x:longint32);                                                                                 override;
    procedure   on__load;                                                                                                        override;
    procedure   on__position(var v:tcursorpositionlist;var xmirror:boolean);                                                     override;
    procedure   on__celldraw(const dcell32:tcommonimage;const cindex,ccount:longint32;var xmirror:boolean);                      override;//30aug2026

   end;


{tcursormodern}
   tcursormodern=class(tcursordefault)
   public

    procedure   on__load;                                                                                                        override;
    procedure   on__position(var v:tcursorpositionlist;var xmirror:boolean);                                                     override;

   end;


{tmakebase}
   pmaketypeitem=^tmaketypeitem;
   tmaketypeitem=record

    valcount          :longint32;
    vallist           :array[0..pred(mb_vallimit)] of byte;

    end;

   tmakenameitem=record

    name              :string[50];//string;
    makecode          :string[50];
    code              :longint32;
    filecount         :longint32;
    tep               :longint32;
    color             :longint32;//tep color
    slot              :longint32;//slot in this list
    typecount         :longint;
    typelist          :array[0..pred(mb_typelimit)] of tmaketypeitem;
    typemultiplier    :array[0..pred(mb_typelimit)] of longint32;

    end;

   tmakelookup=record

    nindex           :longint32;
    vindex           :array[0..pred(mb_typelimit)] of longint32;

    end;

   pmakenamelist     =^tmakenamelist;
   tmakenamelist     =array[0..pred(mb_namelimit)] of tmakenameitem;

   tmakebase=class(tobject)
   private

    imade             :boolean;
    ifilecount        :longint32;
    inamecount        :longint32;
    inamemultiplier   :array[0..pred(mb_namelimit)] of longint32;
    inameList         :tmakenamelist;
    ipnamelist        :pmakenamelist;
    iuserfilename     :string;

    procedure setuserfilename(x:string);

   public

    //create
    constructor create;                                                                                        virtual;
    procedure   on__create;                                                                                    virtual;
    procedure   on__make(const xmakecode:string);                                                              virtual;
    procedure   on__name(const x:tmakenameitem;const nameIndex:longint32);                                     virtual;
    procedure   on__type(const x:tmakenameitem;const nameIndex,typeIndex:longint32);                           virtual;
    procedure   on__val(const x:tmakenameitem;const nameIndex,typeIndex,valIndex:longint32);                   virtual;
    procedure   on__destroy;                                                                                   virtual;
    destructor  destroy;                                                                                       override;

    //information
    property made                                                                                  :boolean    read imade;
    property namecount                                                                             :longint32  read inamecount;
    property namelist                                                                              :pmakenamelist read ipnamelist;
    property filecount                                                                             :longint32  read ifilecount;

    //user filename override -> for "save a file to disk" with files that have subfiles that need auto-renaming and any content alteration on-the-fly - 18jun2026
    //--> WARNING: MUST be filtered as Windows cannot handle "..." in filename -> fails to install if present - 25jun2026
    property userfilename                                                                          :string     read iuserfilename      write setuserfilename;

    //info
    property info__count                                                                           :longint32  read ifilecount;
    function info__int32(const x:tmakelookup)                                                      :longint32; virtual;
    function info__fromint32(x32:longint32;var x:tmakelookup)                                      :boolean;   virtual;

    //file
    function filename(const xindex:longint)                                                        :string;    virtual;
    function filesize(const xindex:longint)                                                        :longint32; virtual;
    function filesize2(const xindex:longint;var xisApproximate:boolean)                            :longint32; virtual;
    function filecolor(const xindex:longint)                                                       :longint32; virtual;
    function findfile(const n:string;var dindex:longint32)                                         :boolean;   virtual;
    function fromfile(const xindex:longint;const xdata:tstr8)                                      :boolean;   virtual;

    //clear
    procedure clear;                                                                                           virtual;

    //make
    procedure make(const xmakecode:string);                                                                    virtual;
    function  finish                                                                               :boolean;   virtual;

    //add
    function addName(const xname,xmakecode:string;const xcode,xtep,xcolor:longint32;var x:tmakenameitem):boolean;   virtual;
    function addType                                                                               :boolean;   virtual;
    function addVal(const xval:byte)                                                               :boolean;   virtual;
    function addVal2(const dtypeindex:longint32;const xval:byte)                                   :boolean;   virtual;
    function addonceVal(const xval:byte)                                                           :boolean;   virtual;
    function addonceVal2(const dtypeindex:longint32;const xval:byte)                               :boolean;   virtual;

   end;


{tmaketest}
   tmaketest=class(tmakebase)
   public

    procedure   on__make(const xmakecode:string);                                                              override;

   end;


{tmakecursor}

   tmakecursorColorset=record

    //background - static
    b                 :tcolor32;
    l                 :tcolor32;//left
    r                 :tcolor32;//right

    //background tint
    b1                :tcolor32;
    b2                :tcolor32;

    //foreground color
    f1                :tcolor32;
    f2                :tcolor32;

    //fade -> fades color 1 -> color2 in a loop
    fade1             :tcolor32;
    fade2             :tcolor32;

    //bounce -> bounce shade color1 -> color2 up and down
    vbounce1          :tcolor32;
    vbounce2          :tcolor32;

    //flash
    flash1            :tcolor32;
    flash2            :tcolor32;

    end;

   tmakecursor=class(tmakebase)
   private

    iclassname        :string;//optional
    ilastdata         :array[0..cf_max] of tstr8;
    ilastmakeREF      :array[0..cf_max] of string;
    icursors1         :array[0..cf_max] of tcursorbase;//required
    icursors2         :array[0..cf_max] of tcursorbase;//optional
    icursors3         :array[0..cf_max] of tcursorbase;//optional
    ifilesizeINF      :longint32;//approximate file size for all INF files

    function fromfileINF(const xindex:longint;x:tmakecursorinfo;const y:tcursorbase)               :string;//18jun2026

   public

    //create
    procedure   on__create;                                                                                                      override;
    procedure   on__classname(var xclassname:string);                                                                            virtual;
    procedure   on__createCursorType(const cfindex:longint32;var x1,x2,x3:tcursorbase);                                          virtual;
    procedure   on__destroy;                                                                                                     override;
    procedure   on__setcursorcolorsetc(const a:tcursorbase;const x:tmakecursorinfo);                                             virtual;

    //file
    function filename(const xindex:longint)                                                        :string;                      override;
    function filesize2(const xindex:longint;var xisApproximate:boolean)                            :longint32;                   override;
    function filecolor(const xindex:longint)                                                       :longint32;                   override;
    function fromfile(const xindex:longint;const xdata:tstr8)                                      :boolean;                     override;
    function toanimation(const xwantSize,xindex:longint;const ximage:tcommonimage)                 :boolean;                     virtual;
    function toanimationinfo(const xwantSize,xindex:longint;var x:tanimationinfo)                  :boolean;                     virtual;
    function toanimationcell(const xwantSize,xindex,xcellindex:longint32;const ximage:tcommonimage):boolean;                     virtual;

    //support procs
    function  xintchar(const x:longint32)                                                          :char;
    function  xcharint(const x:char)                                                               :longint32;
    function  cur__fromint32(const xindex:longint;var x:tmakecursorinfo;var y:tcursorbase)         :boolean;
    function  cur__int32(const x:tmakecursorinfo)                                                  :longint32;//13jun2026
    function  cur__id(const x:tmakecursorinfo)                                                     :string;
    function  cur__TypeChar(const x:tmakecursorinfo)                                               :string;
    function  ext__code(const x:tmakecursorinfo)                                                   :longint32;
    function  ext__CurAni(const x:tmakecursorinfo)                                                 :string;
    function  ext__CurAniInf(const x:tmakecursorinfo)                                              :string;

   end;


{tmakecursordefault}
   tmakecursordefault=class(tmakecursor)
   public

    procedure on__classname(var xclassname:string);                                                            override;
    procedure on__createCursorType(const cfindex:longint32;var x1,x2,x3:tcursorbase);                          override;
    procedure on__setcursorcolorsetc(const a:tcursorbase;const x:tmakecursorinfo);                             override;
    procedure on__make(const xmakecode:string);                                                                override;

   end;


{tmakecursormodern}
//55555555555
   tmakecursormodern=class(tmakecursordefault)
   public

    procedure on__classname(var xclassname:string);                                                            override;
    procedure on__createCursorType(const cfindex:longint32;var x1,x2,x3:tcursorbase);                          override;

   end;


{tmakewallpaper}
//9999999999999999999999999999
   tmakewallpaper=class(tobject)
   private

    iname             :tdynamicinteger;
    iwcm              :tdynamicinteger;//wallpaper color modifier (only 1)
    iwemList          :string;
    icount            :longint32;
    ifuzzRandom       :tdynamicbyte;

    function  xadjust(const s:tbasicimage;const xindex:longint32)                                     :boolean;
    procedure xhue(const s:tbasicimage;const sw,sh:longint32;v:longint32);//02sep2026
    procedure xtint(const s:tbasicimage;const sw,sh:longint32;const r,g,b:byte);
    procedure xinvert(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
    procedure xmix(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
    procedure xskew(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
    procedure xpixelate(const s:tbasicimage;const dsize:longint32);
    procedure xbrightness(const s:tbasicimage;const sw,sh:longint32;xlevel:single);
    procedure xfadeLR(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
    procedure xfadeTB(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
    function  find__wcm(const xindex:longint32)                                                       :longint32;
    function  find__mirror                                                                            :boolean;
    function  find__pixelateSize                                                                      :longint32;
    function  find__fade                                                                              :longint32;
    function  find__brightnessRatio                                                                   :single;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //make
    procedure makelist(const xwemList:string);

    //file
    function file__count                                                                           :longint32;
    function file__name(const xindex:longint32)                                                    :string;
    function file__size(const xindex:longint32)                                                    :longint32;
    function file__size2(const xindex:longint32;var xisApproximate:boolean)                        :longint32;
    function file__data(const xindex:longint32;const xdata:tstr8)                                  :boolean;

   end;


const
   fast_arctan_min              =-199;
   fast_arctan_max              = 199;
   fast_sincos_max              = 6500;

var
   fast_arctanOK                :boolean=false;
   fast_arctan                  :array[fast_arctan_min..fast_arctan_max] of array[fast_arctan_min..fast_arctan_max] of double;
   fast_sin                     :array[0..fast_sincos_max] of double;
   fast_cos                     :array[0..fast_sincos_max] of double;

   static_randomOK              :boolean=false;
   static_random                :array[0..max16]           of byte;

   cursor_usepng                :boolean=false;//for tfoldercursor -> tmakecursor -> tcursorbase.todata()
   cursor_wantsize              :longint32=128;

   cursor_customcolors          :tcustomcursorcolors=( changeId:0; canEdit:false; canSpeed:false; infoInit:false; cf_index:0; statusCaching:false; );//25jun2026
   wallpaper_customeffects      :tcustomwallpapereffects=( changeId:0; Mirror:false; Pixelate:0; Fade:0; Brightness:0; );//04sep2026


//support procs ----------------------------------------------------------------

function miscom32(const dw,dh:longint32):tcommonimage;
function mis__atleast(const d:tcommonimage;const dw,dh:longint32):boolean;//15jun2026
function mis__fromarray2(const d:tcommonimage;const x:array of byte):boolean;
function mis__scanAH(const d:tcommonimage;dx1,dx2:longint32;var xarea:twinrect;var xhotx,xhoty:longint32):boolean;
function mis__rotateFAST32(const s,d:tobject;const xshiftdeg:extended;const xenlarge:boolean):boolean;//12jun2026, 29sep2018

function static__random(var xpos:longint32;const xval:longint32):longint32;
procedure static__randomnewpos(var xpos:longint32;const xnewpos:longint32);

function wem__name(const xcode:char):string;
function wcm__name(const wcmCode:longint32):string;

function int__cursorclass(const x:longint32):tcursorclass;
function cursor__classname(const x:tcursorclass):string;
function cursor__classlabel(const x:tcursorclass):string;
function cursor__scopeAll:boolean;
procedure cursor__setscopeAll(const xall:boolean);
function cursor__speed:longint32;
procedure cursor__setspeed(x:longint32);
function cursor__mirror:boolean;
procedure cursor__setmirror(x:boolean);
procedure cursor__customcolors_save;
procedure cursor__customcolors_load;
function cursor__safename(const x:string):string;//25jun2026

function cf__name(const xindex:longint32):string;
function cf__label(const xindex:longint32):string;

function cv__name(const xindex:longint32):string;
function cv__label(const xindex:longint32):string;

function ct__name(const xindex:longint32):string;
function ct__label(const xindex:longint32):string;

function ca__name(const xindex:longint32):string;
function ca__label(const xindex:longint32):string;

function co__name(const xindex:longint32):string;
function co__label(const xindex:longint32):string;

function cb__name(const xindex:longint32):string;
function cb__label(const xindex:longint32):string;

function cc__name(const xindex:longint32):string;
function cc__tepcolor(const xclass:tcursorclass;const xindex:longint32):longint32;

procedure cc__makeNameList;//creates cursor color code list and copies it to clipboard

procedure wallpaper__customeffects_save;
procedure wallpaper__customeffects_load;
function  wallpaper__changed(var xlastChangeId:longint32)                                             :boolean;
function  wallpaper__mirror                                                                           :boolean;
procedure wallpaper__setmirror(const x:boolean);
function  wallpaper__pixelate                                                                         :longint32;
procedure wallpaper__setpixelate(const x:longint32);
function  wallpaper__pixelatemax                                                                      :longint32;
function  wallpaper__pixelateLabel(const xindex:longint32)                                            :string;
function  wallpaper__fade                                                                             :longint32;
procedure wallpaper__setfade(const x:longint32);
function  wallpaper__fademax                                                                          :longint32;
function  wallpaper__fadeLabel(const xindex:longint32)                                                :string;
function  wallpaper__brightness                                                                       :longint32;
function  wallpaper__brightnessRatio                                                                  :single;
function  wallpaper__brightnessFindRatio(const xindex:longint32)                                      :single;
procedure wallpaper__setbrightness(const x:longint32);
function  wallpaper__brightnessmax                                                                    :longint32;
function  wallpaper__brightnessLabel(const xindex:longint32)                                          :string;
procedure wallpaper__alloff;


implementation

uses gossfold, archiveFiles;


//## support procs #############################################################

function wem__name(const xcode:char):string;
begin


if      (xcode=wem_mix1)   then result:='mix1'
else if (xcode=wem_mix2)   then result:='mix2'
else if (xcode=wem_mix3)   then result:='mix3'
else if (xcode=wem_mix4)   then result:='mix4'
else if (xcode=wem_mix5)   then result:='mix5'
else if (xcode=wem_skew1)  then result:='skew1'
else if (xcode=wem_skew2)  then result:='skew2'
else if (xcode=wem_skew3)  then result:='skew3'
else                            result:='';

end;

function wcm__name(const wcmCode:longint32):string;
begin

case wcmCode of

wcm_normal            :result:='normal';
wcm_hue0              :result:='hue1';
wcm_hue1              :result:='hue2';
wcm_hue2              :result:='hue3';
wcm_hue3              :result:='hue4';
wcm_hue4              :result:='hue5';
wcm_hue5              :result:='hue6';
wcm_hue6              :result:='hue7';
wcm_hue7              :result:='hue8';
wcm_hue8              :result:='hue9';
wcm_hue9              :result:='hue10';
wcm_hue10             :result:='hue11';
wcm_hue11             :result:='hue12';

wcm_pink              :result:='pink';
wcm_sweetblue         :result:='light-blue';
wcm_red               :result:='red';
wcm_green             :result:='green';
wcm_blue              :result:='blue';
wcm_yellow            :result:='yellow';
wcm_sepia             :result:='sepia';

wcm_invertR2          :result:='invert-red50%';
wcm_invertG2          :result:='invert-green50%';
wcm_invertB2          :result:='invert-blue50%';
wcm_invertR           :result:='invert-red';
wcm_invertG           :result:='invert-green';
wcm_invertB           :result:='invert-blue';
wcm_invertRGB         :result:='invert-rgb';

else                   result:='';

end;//case

end;

function int__cursorclass(const x:longint32):tcursorclass;
begin

if      (x<=0)                            then result:=ccl_default
else if (x>longint32(high(tcursorclass))) then result:=high( tcursorclass )
else                                           result:=tcursorclass( x );

end;

function cursor__classname(const x:tcursorclass):string;
begin

case x of
ccl_default           :result   :='default';
ccl_modern            :result   :='modern';
else                   result   :='unknown';
end;//case

end;

function cursor__classlabel(const x:tcursorclass):string;
begin

case x of
ccl_default           :result   :='default';
ccl_modern            :result   :='modern';
else                   result   :='unknown';
end;//case

end;

function cursor__scopeAll:boolean;
begin

result                :=cursor_customcolors.useShared;

end;

procedure cursor__setscopeAll(const xall:boolean);
begin

if low__setbol(cursor_customcolors.useShared,xall) then
   begin

   rollid32( cursor_customcolors.changeId );

   end;

end;

function cursor__speed:longint32;
begin

if       cursor_customcolors.useshared    then result :=cursor_customcolors.shared.speed
else if (cursor_customcolors.cf_index>=0) then result :=cursor_customcolors.clist[ cursor_customcolors.cf_index ].speed
else                                           result :=100;

end;

procedure cursor__setspeed(x:longint32);

   procedure s(const s:longint32;var d:longint32);
   begin

   if (s<>d) then
      begin

      d        :=s;

      rollid32( cursor_customcolors.changeId );

      end;

   end;

begin

//range
x           :=frcrange32( x ,cursorspeed_min ,cursorspeed_max );

//set
case cursor_customcolors.useshared of
true:s( x ,cursor_customcolors.shared.speed );
else s( x ,cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].speed );
end;//case

end;

function cursor__mirror:boolean;
begin

if      cursor_customcolors.useshared     then result :=cursor_customcolors.shared.mirror
else if (cursor_customcolors.cf_index>=0) then result :=cursor_customcolors.clist[ cursor_customcolors.cf_index ].mirror
else                                           result :=false;

end;

procedure cursor__setmirror(x:boolean);

   procedure s(const s:boolean;var d:boolean);
   begin

   if (s<>d) then
      begin

      d        :=s;

      rollid32( cursor_customcolors.changeId );

      end;

   end;

begin

case cursor_customcolors.useshared of
true:s( x ,cursor_customcolors.shared.mirror );
else s( x ,cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].mirror );
end;//case

end;

procedure cursor__customcolors_save;
var
   v                  :string;
   p                  :longint32;

   procedure b(const n:string;const x:boolean);
   begin

   v                  :=v + n + ': ' + bolstr(x) + #10;

   end;

   procedure a(const n:string;const x:longint32);
   begin

   v                  :=v + n + ': ' + intstr32(x) + #10;

   end;

   procedure ac(const n:string;const x:tcursorcolorset);
   begin

   a( n + '.edge'    ,x.edge    );
   a( n + '.body'    ,x.body    );
   a( n + '.body2'   ,x.body2   );
   a( n + '.body3'   ,x.body3   );
   a( n + '.sparkle' ,x.sparkle );
   a( n + '.speed'   ,x.speed   );
   b( n + '.mirror'  ,x.mirror  );

   end;

begin

//init
v                               :='';

//get
b( 'useshared'                  ,cursor_customcolors.useshared );
ac( 'shared'                    ,cursor_customcolors.shared );

for p:=0 to cf_max do
begin

ac( 'cursor'+intstr32(p)        ,cursor_customcolors.clist[p] );

end;//p

//set
io__tofilestr2( app__folderSettings(true) + 'cursor-customcolors.ini' , v );

end;

procedure cursor__customcolors_load;
var
   a                  :tvars8;
   p                  :longint32;
   e                  :string;

   procedure ac(const n:string;var x:tcursorcolorset);
   begin

   x.edge             :=a.idef ( n + '.edge'     , clnone   );
   x.body             :=a.idef ( n + '.body'     , 0        );
   x.body2            :=a.idef ( n + '.body2'    , clwhite  );
   x.body3            :=a.idef ( n + '.body3'    , clgray   );
   x.sparkle          :=a.idef ( n + '.sparkle'  , clnone   );
   x.speed            :=a.idef2( n + '.speed'   , 100 ,cursorspeed_min ,cursorspeed_max );
   x.mirror           :=a.bdef ( n + '.mirror'  , false     );

   end;

begin

//defaults
a                               :=nil;

try

//init
a                               :=tvars8.create;
a.fromfile( app__folderSettings(true) + 'cursor-customcolors.ini' ,e );

//get
cursor_customcolors.useshared   :=a.bdef( 'useshared' ,true );
ac( 'shared'                    ,cursor_customcolors.shared );

for p:=0 to cf_max do
begin

ac( 'cursor'+intstr32(p)        ,cursor_customcolors.clist[p] );

end;//p

//id

if (not cursor_customcolors.infoInit) then
   begin

   cursor_customcolors.infoInit :=true;

   low__cls(@cursor_customcolors.info,sizeof(cursor_customcolors.info));

   end;

rollid32( cursor_customcolors.changeId );

except;end;

//free
freeobj(@a);

end;

function cursor__safename(const x:string):string;//25jun2026
var//Note: Windows doesn't like "..." in a cursor scheme filename -> fails to locate sub-files even though the files exist and can
   //      be located/accessed via their file dialog window -  25jun2026
   v        :string;
   p        :longint32;

   ffolder  :string;
   fname    :string;
   fext     :string;

begin

//split
ffolder     :=io__asfolderNIL( io__extractfilepath( x ) );
fname       :=io__extractnameonly( x );
fext        :=io__readfileext_low( x );

//.remove all double dots from name, but leave the single dot for file extensions
for p:=1 to 100 do
begin

v           :=fname;
swapstrs( fname ,'..' ,'--' );

if (fname=v) then break;

end;//p

//get
result      :=ffolder + fname + insstr('.',fext<>'') + fext;

end;

function cf__name(const xindex:longint32):string;
begin

case xindex of
cf_install            :result:='install';
cf_alt                :result:='alt';
cf_arrow              :result:='arrow';
cf_work               :result:='work';
cf_cross              :result:='cross';
cf_ew                 :result:='ew';
cf_hand               :result:='link';//was: hand - 30jul2026
cf_help               :result:='help';
cf_txt                :result:='text';
cf_move               :result:='move';
cf_nesw               :result:='nesw';
cf_no                 :result:='no';
cf_ns                 :result:='ns';
cf_nwse               :result:='nwse';
cf_pen                :result:='pen';
cf_person             :result:='person';
cf_pin                :result:='pin';
cf_wait               :result:='wait';
else                   result:='';
end;//case

end;

function cf__label(const xindex:longint32):string;
begin

case xindex of
cf_install            :result:='installer';
cf_alt                :result:='alt';
cf_arrow              :result:='arrow';
cf_work               :result:='work';
cf_cross              :result:='cross';
cf_ew                 :result:='ew';
cf_hand               :result:='link';//was: hand - 30jul2026
cf_help               :result:='help';
cf_txt                :result:='text';
cf_move               :result:='move';
cf_nesw               :result:='nesw';
cf_no                 :result:='no';
cf_ns                 :result:='ns';
cf_nwse               :result:='nwse';
cf_pen                :result:='pen';
cf_person             :result:='person';
cf_pin                :result:='pin';
cf_wait               :result:='wait';
else                   result:='';
end;//case

end;



function cc__name(const xindex:longint32):string;//proc generated by cc__makeNameList

   procedure sn(const n:string;const xfrom:longint32);
   begin

   result   :=n + insstr( intstr32( 1 + xindex - xfrom ) ,xindex>xfrom);

   end;

   procedure s1(const n:string);
   begin

   result   :=n;

   end;

begin

case xindex of

cc_customcolor      ..        cc_customcolorMAX   :sn('customcolor'       ,cc_customcolor      );
cc_rainbow          ..        cc_rainbowMAX       :sn('rainbow'           ,cc_rainbow          );
cc_red              ..        cc_redMAX           :sn('red'               ,cc_red              );
cc_green            ..        cc_greenMAX         :sn('green'             ,cc_green            );
cc_blue             ..        cc_blueMAX          :sn('blue'              ,cc_blue             );
cc_yellow           ..        cc_yellowMAX        :sn('yellow'            ,cc_yellow           );
cc_aqua             ..        cc_aquaMAX          :sn('aqua'              ,cc_aqua             );
cc_orange           ..        cc_orangeMAX        :sn('orange'            ,cc_orange           );
cc_purple           ..        cc_purpleMAX        :sn('purple'            ,cc_purple           );
cc_pink             ..        cc_pinkMAX          :sn('pink'              ,cc_pink             );
cc_white            ..        cc_whiteMAX         :sn('white'             ,cc_white            );
cc_grey             ..        cc_greyMAX          :sn('grey'              ,cc_grey             );
cc_black            ..        cc_blackMAX         :sn('black'             ,cc_black            );
cc_brown            ..        cc_brownMAX         :sn('brown'             ,cc_brown            );
else                                               s1('other'                                  );

end;//case

end;

function cc__tepcolor(const xclass:tcursorclass;const xindex:longint32):longint32;

   procedure s(const xcolor:longint32);
   begin

   result   :=xcolor;

   end;

begin

case xindex of

cc_customcolor      ..        cc_customcolorMAX   :s( clwhite                  );
cc_rainbow          ..        cc_rainbowMAX       :s( low__aorb(clFuchsia,clPurple,xclass=ccl_default) );
cc_red              ..        cc_redMAX           :s( clred                    );
cc_green            ..        cc_greenMAX         :s( cllime                   );
cc_blue             ..        cc_blueMAX          :s( clblue                   );
cc_yellow           ..        cc_yellowMAX        :s( clyellow                 );
cc_aqua             ..        cc_aquaMAX          :s( claqua                   );
cc_orange           ..        cc_orangeMAX        :s( rgba0__int(255,128,0)    );
cc_purple           ..        cc_purpleMAX        :s( clpurple                 );
cc_pink             ..        cc_pinkMAX          :s( rgba0__int(255,128,255)  );
cc_white            ..        cc_whiteMAX         :s( rgba0__int(208,208,208)  );
cc_grey             ..        cc_greyMAX          :s( rgba0__int(127,127,127)  );
cc_black            ..        cc_blackMAX         :s( rgba0__int(80,80,80)     );
cc_brown            ..        cc_brownMAX         :s( rgba0__int(130,70,0)     );
else                                               s( clred                    );

end;//case

end;

function cb__name(const xindex:longint32):string;
begin

case xindex of
cb_32                 :result:='32-bit';
cb_8                  :result:='8-bit';
else                   result:='';
end;//case

end;

function cb__label(const xindex:longint32):string;
begin

result      :=cb__name( xindex );

end;

function co__name(const xindex:longint32):string;
begin

case xindex of
co_100                :result:='100%';
co_75                 :result:='75%';
co_50                 :result:='50%';
co_30                 :result:='30%';
else                   result:='';
end;//case

end;

function co__label(const xindex:longint32):string;

   procedure s(const x:longint32);
   begin

   result   :=intstr32(x) + '%';

   end;

begin

case xindex of
co_100                :s(100);
co_75                 :s(75);
co_50                 :s(50);
co_30                 :s(30);
else                   s(100);
end;//case

end;

function ca__name(const xindex:longint32):string;
begin

case xindex of
ca_static             :result:='static';
ca_72cell             :result:='72cell';
ca_48cell             :result:='48cell';
ca_24cell             :result:='24cell';
ca_16cell             :result:='16cell';
ca_8cell              :result:='8cell';
else                   result:='static';
end;//case

end;

function ca__label(const xindex:longint32):string;
begin

case xindex of
ca_static             :result:='1';
ca_72cell             :result:='72';
ca_48cell             :result:='48';
ca_24cell             :result:='24';
ca_16cell             :result:='16';
ca_8cell              :result:='8';
else                   result:='1';
end;//case

end;

function ct__name(const xindex:longint32):string;
begin

case xindex of
ct_plain              :result:='plain';
ct_sparkle            :result:='sparkle';
ct_hstripe            :result:='hstripe';
ct_vstripe            :result:='vstripe';
ct_pulse              :result:='pulse';
ct_flat               :result:='flat';
ct_colors             :result:='colors';
ct_colors2            :result:='colors2';
ct_colors3            :result:='colors3';
else                   result:='';
end;//case

end;

function ct__label(const xindex:longint32):string;
begin

result      :=ct__name( xindex );

end;

function cv__name(const xindex:longint32):string;

   procedure s(const n:string);
   begin

   result   :=n;

   end;

begin

case xindex of
cv_standard           :s('standard');
cv_whiteedge          :s('whiteedge');
cv_goldedge           :s('goldedge');
cv_outline            :s('outline');
cv_solid              :s('solid');
cv_tone               :s('tone');
else                   s('solid');
end;//case

end;

function cv__label(const xindex:longint32):string;

   procedure s(const n:string);
   begin

   result   :=n;

   end;

begin

case xindex of
cv_standard           :s('standard');
cv_whiteedge          :s('white edge');
cv_goldedge           :s('gold edge');
cv_outline            :s('outline');
cv_solid              :s('solid');
cv_tone               :s('tone');
else                   s('solid');
end;//case

end;

procedure cc__makeNameList;//creates cursor color code list and copies it to clipboard
const
   t                  =3;//indent/tab
   ipad               =19;
   npad               =23;

var
   xvarcount          :longint32;
   ilist              :string;
   nlist              :string;

   procedure iadd(const xindent:longint32;const xline:string);
   begin

   ilist              :=ilist + strpad( '' ,xindent ) + xline + rcode;

   end;

   procedure nadd(const xindent:longint32;const xline:string);
   begin

   nlist              :=nlist + strpad( '' ,xindent ) + xline + rcode;

   end;

   procedure xadd(const xname:string);
   begin

   //ilist
   iadd( t, strpad( 'cc_' + xname ,ipad ) + '=' + intstr32(xvarcount) + ';' );

   //inc
   inc(xvarcount);

   end;

   procedure a(const xcount:longint32;const n:string);//add range
   var
      p               :longint32;

   begin

   //add color values
   if (xcount<=1) then
      begin

      xadd( n );

      end

   else begin

      for p:=1 to xcount do
      begin

      xadd( n +insstr(intstr32(p),p>=2) );

      end;//p

      end;

   //.max
   iadd( t, strpad( 'cc_' + n+'MAX' ,ipad ) + '=' + intstr32(pred(xvarcount)) + ';' );

   //.add trailing vertical clear space
   iadd( 0 ,'' );

   //add color name range in compact form
   nadd( 0 , strpad( 'cc_' + n ,20 ) + strpad( '..' ,10 ) + strpad( 'cc_' + n + 'MAX' ,20 ) +

       ':sn(' + strpad( char(sssinglequote) + n + char(sssinglequote) ,20 ) + ',' + strpad( 'cc_' + n ,20 ) + ');'

      );

   end;

begin


//defaults
ilist       :='';
nlist       :='';
xvarcount   :=0;

//init

//.ilist
iadd( t, '//cursor colors - values generated by cc__makeNameList' );

//.nlist
nadd( 0, 'function cc__name(const xindex:longint32):string;//proc generated by cc__makeNameList' );
nadd( 0, '' );
nadd( t, 'procedure sn(const n:string;const xfrom:longint32);' );
nadd( t, 'begin' );
nadd( 0, '' );
nadd( t, 'result   :=n + insstr( intstr32( 1 + xindex - xfrom ) ,xindex>xfrom);' );
nadd( 0, '' );
nadd( t, 'end;' );
nadd( 0, '' );
nadd( t, 'procedure s1(const n:string);' );
nadd( t, 'begin' );
nadd( 0, '' );
nadd( t, 'result   :=n;' );
nadd( 0, '' );
nadd( t, 'end;' );
nadd( 0, '' );
nadd( 0, 'begin' );
nadd( 0, '' );
nadd( 0, 'case xindex of' );
nadd( 0, '' );

//get
a(  1 ,'customcolor' );
a(  5 ,'rainbow'     );
a( 10 ,'red'         );
a( 10 ,'green'       );
a( 10 ,'blue'        );
a( 10 ,'yellow'      );
a( 10 ,'aqua'        );
a( 10 ,'orange'      );
a( 10 ,'purple'      );
a( 10 ,'pink'        );
a( 10 ,'white'       );
a( 10 ,'grey'        );
a( 10 ,'black'       );
a( 10 ,'brown'       );

//finalise

//.ilist
iadd( t ,strpad( 'cc_max' ,ipad ) + '=' + intstr32(xvarcount) + ';' );

//.nlist
nadd( 0 ,strpad( 'else' ,51 ) + 's1(' + strpad( char(sssinglequote) + 'other' + char(sssinglequote) ,41 ) + ');' );
nadd( 0 ,'' );
nadd( 0 ,'end;//case' );
nadd( 0 ,'' );
nadd( 0 ,'end;' );//end of proc

//set
clip__copytext( ilist + rcode + rcode + nlist );

showtext('Color list copied to Clipboard');

end;


//wallpaper effects procs ------------------------------------------------------
procedure wallpaper__customeffects_save;
var
   v                  :string;
   p                  :longint32;

   procedure b(const n:string;const x:boolean);
   begin

   v                  :=v + n + ': ' + bolstr(x) + #10;

   end;

   procedure i(const n:string;const x:longint32);
   begin

   v                  :=v + n + ': ' + intstr32(x) + #10;

   end;

begin

//init
v                               :='';

//get
b( 'mirror'     ,wallpaper__mirror     );
i( 'pixelate'   ,wallpaper__pixelate   );
i( 'fade'       ,wallpaper__fade       );
i( 'brightness' ,wallpaper__brightness );

//set
io__tofilestr2( app__folderSettings(true) + 'wallpaper-customeffects.ini' , v );

end;

procedure wallpaper__customeffects_load;
var
   a                  :tvars8;
   e                  :string;

begin

//defaults
a                                         :=nil;

try

//init
a                                         :=tvars8.create;
a.fromfile( app__folderSettings(true) + 'wallpaper-customeffects.ini' ,e );

//get
wallpaper__setmirror    ( a.bdef( 'mirror'     ,false ) );
wallpaper__setpixelate  ( a.idef( 'pixelate'   ,0     ) );
wallpaper__setfade      ( a.idef( 'fade'       ,0     ) );
wallpaper__setbrightness( a.idef( 'brightness' ,0     ) );

except;end;

//free
freeobj(@a);

end;

function wallpaper__changed(var xlastChangeId:longint32):boolean;
begin

result      :=low__setint( xlastChangeId ,wallpaper_customeffects.changeId );

end;

function wallpaper__mirror:boolean;
begin

result      :=wallpaper_customeffects.mirror;

end;

procedure wallpaper__setmirror(const x:boolean);
begin

if low__setbol(wallpaper_customeffects.mirror,x) then rollid32( wallpaper_customeffects.changeId );

end;

function wallpaper__pixelate:longint32;
begin

result      :=wallpaper_customeffects.pixelate;

end;

function wallpaper__pixelateSize:longint32;
begin

case wallpaper_customeffects.pixelate of
1   :result:=32;
2   :result:=48;
3   :result:=64;
4   :result:=96;
5   :result:=128;
6   :result:=192;
7   :result:=256;
else result:=0;
end;//case

end;

procedure wallpaper__setpixelate(const x:longint32);
begin

if low__setint( wallpaper_customeffects.pixelate ,frcrange32(x,0,wallpaper__pixelateMax) ) then rollid32( wallpaper_customeffects.changeId );

end;

function wallpaper__pixelatemax:longint32;
begin

result      :=7;

end;

function wallpaper__pixelateLabel(const xindex:longint32):string;
begin

case xindex of
0    :result:='Off';
1    :result:='32px';
2    :result:='48px';
3    :result:='64px';
4    :result:='96px';
5    :result:='128px';
6    :result:='192px';
7    :result:='256px';
else  result:='Off';
end;//case

end;

function wallpaper__fade:longint32;
begin

result      :=wallpaper_customeffects.fade;

end;

procedure wallpaper__setfade(const x:longint32);
begin

if low__setint( wallpaper_customeffects.fade ,frcrange32(x,0,wallpaper__fadeMax) ) then rollid32( wallpaper_customeffects.changeId );

end;

function wallpaper__fademax:longint32;
begin

result      :=8;

end;

function wallpaper__fadeLabel(const xindex:longint32):string;
begin

case xindex of
0    :result:='Off';
1    :result:='Left';
2    :result:='Left+';
3    :result:='Right';
4    :result:='Right+';
5    :result:='Top';
6    :result:='Top+';
7    :result:='Bottom';
8    :result:='Bottom+';
else  result:='Off';
end;//case

end;

function wallpaper__brightness:longint32;
begin

result      :=wallpaper_customeffects.brightness;

end;

function wallpaper__brightnessRatio:single;
begin

result      :=wallpaper__brightnessFindRatio(wallpaper__brightness);

end;

function wallpaper__brightnessFindRatio(const xindex:longint32):single;
begin

case xindex of
1   :result:=1.10;
2   :result:=1.30;
3   :result:=1.50;
4   :result:=2.00;
5   :result:=0.90;
6   :result:=0.70;
7   :result:=0.50;
else result:=1.0;
end;//case

end;

procedure wallpaper__setbrightness(const x:longint32);
begin

if low__setint( wallpaper_customeffects.brightness ,frcrange32(x,0,wallpaper__brightnessMax) ) then rollid32( wallpaper_customeffects.changeId );

end;

function wallpaper__brightnessmax:longint32;
begin

result      :=7;

end;

function wallpaper__brightnessLabel(const xindex:longint32):string;
begin

case xindex of
0    :result:='Off';
else  result:=k64(round( wallpaper__brightnessFindRatio(xindex) * 100 ))+'%';
end;//case

end;

procedure wallpaper__alloff;
begin

wallpaper__setmirror( false );
wallpaper__setfade( 0 );
wallpaper__setpixelate( 0 );
wallpaper__setbrightness( 0 );

end;


//## support procs #############################################################

function static__random(var xpos:longint32;const xval:longint32):longint32;
var
   p                  :longint32;

begin

//init
if not static_randomOK then
   begin

   static_randomOK    :=true;

   for p:=0 to high(static_random) do static_random[p]:=random(256);//0..255

   end;

//inc
inc(xpos);

if (xpos<0) or (xpos>high(static_random)) then
   begin

   xpos               :=0

   end;

//get
result                :=( xval * static_random[ xpos ] ) div 256;//never reaches full value -> e.g. 256 * 255 / 256 = 255 and not 256

end;

procedure static__randomnewpos(var xpos:longint32;const xnewpos:longint32);
begin

if      (xnewpos<0)                   then xpos:=0
else if (xnewpos>high(static_random)) then xpos:=0
else                                       xpos:=xnewpos;

end;

function miscom32(const dw,dh:longint32):tcommonimage;
begin

result      :=misimg32(dw,dh);

end;

function mis__atleast(const d:tcommonimage;const dw,dh:longint32):boolean;
begin

if ( dw > misw(d) ) or ( dh > mish(d) ) then
   begin

   result   :=missize( d ,dw ,dh );

   end
else begin

   result   :=true;

   end;

end;

function mis__fromarray2(const d:tcommonimage;const x:array of byte):boolean;
label
   skipend;

var
   a                  :tstr8;
   e                  :string;

begin

//defaults
result                :=false;
a                     :=nil;

try

//init
a                     :=rescache__newStr8;

//get
if not a.addrec( @x ,sizeof(x) ) then goto skipend;

//.unzip
if strmatch(io__anyformatb(@a),'zip') then
   begin

   if not low__decompress( @a ) then goto skipend;

   end;

//.load
if not mis__fromdata( d ,@a ,e ) then goto skipend;

//successful
result                :=true;

skipend:

except;end;

//free
rescache__delStr8( @a );

end;

function mis__scanAH(const d:tcommonimage;dx1,dx2:longint32;var xarea:twinrect;var xhotx,xhoty:longint32):boolean;
var
   dx                 :longint32;
   dy                 :longint32;
   dr32               :pcolorrow32;
   honce              :boolean;

begin

//defaults
result                :=false;

//check
if (d=nil) then exit;

//init
dx1                   :=frcrange32( dx1 ,0   ,pred(d.width) );
dx2                   :=frcrange32( dx2 ,dx1 ,pred(d.width) );
xarea.left            :=dx2;
xarea.right           :=dx1;
xarea.top             :=pred(d.height);
xarea.bottom          :=0;
xhotx                 :=0;
xhoty                 :=0;
honce                 :=true;

//find
for dy:=0 to pred(d.height) do
begin

if not misscan32( d ,dy ,dr32 ) then exit;

for dx:=dx1 to dx2 do
begin

if (dr32[dx].a>=5) then
   begin

   if ( dx<xarea.left    ) then xarea.left    :=dx;
   if ( dx>xarea.right   ) then xarea.right   :=dx;
   if ( dy>xarea.bottom  ) then xarea.bottom  :=dy;
   if ( dy<xarea.top     ) then xarea.top     :=dy;

   if honce then
      begin

      honce :=false;
      xhotx :=dx;
      xhoty :=dy;

      end;

   end;

end;//dx

end;//dy

//successful
result                :=true;

end;

function mis__rotateFAST32(const s,d:tobject;const xshiftdeg:extended;const xenlarge:boolean):boolean;//12jun2026, 29sep2018
label
   skipend;

var
   srs32              :pcolorrows32;
   dr32               :pcolorrow32;
   t32                :tcolor32;
   xm                 :longint32;
   ym                 :longint32;
   xs                 :longint32;
   ys                 :longint32;
   ls                 :longint32;
   rs                 :longint32;
   ts                 :longint32;
   bs                 :longint32;
   sw                 :longint32;
   sh                 :longint32;
   dx                 :longint32;
   dy                 :longint32;
   dx2                :longint32;
   dy2                :longint32;
   dw                 :longint32;
   dh                 :longint32;
   sox                :longint32;
   soy                :longint32;
   dox                :longint32;
   doy                :longint32;
   xshiftrad          :double;
   twopie             :double;
   xlen               :double;
   xdeg               :double;
   xval1              :double;

   procedure dmap(const sx,sy:longint;var dx,dy:longint);
   var
      xm              :longint32;
      ym              :longint32;
      xs              :longint32;
      ys              :longint32;

   begin

   //defaults
   dx                 :=0;
   dy                 :=0;

   //.xs
   xs                 :=sx-sox;
   xm                 :=xs;
   if (xm<0) then
      begin

      xm              :=-xm;

      end;

   //.ys
   ys                 :=sy-soy;
   ym                 :=ys;
   if (ym<0) then
      begin

      ym              :=-ym;

      end;

   //.len
   xlen               :=sqrt( ( 1.0 * xm * xm ) + ( 1.0 * ym * ym ) );

   //.xdeg
   if (ym=0) then xdeg:=xshiftrad + arctan( xm /0.000000000000000001 )
   else           xdeg:=xshiftrad + arctan( xs / ys                  );

   //get
   if ((xs>=0) and (ys<0)) or ((xs<0) and (ys<=0)) then
      begin

      dx              :=round( sox - ( sin(xdeg) * xlen ) );
      dy              :=round( soy - ( cos(xdeg) * xlen ) );

      end
   else begin

      dx              :=round( ( sin(xdeg) * xlen ) + sox );
      dy              :=round( ( cos(xdeg) * xlen ) + soy );

      end;

   end;

begin

//defaults
result                :=false;

//check
if not misok32( s ,sw ,sh )  then exit;
if not misok32( d ,dw ,dh )  then exit;
if not misrows32( s ,srs32 ) then exit;


//init -------------------------------------------------------------------------


if not fast_arctanOK then
   begin

   fast_arctanOK:=true;

   for ys:=fast_arctan_min to fast_arctan_max do
   begin

   for xs:=fast_arctan_min to fast_arctan_max do
   begin

   if (ys=0) then fast_arctan[ys][xs] :=arctan( xs / 0.000000000000000001 )
   else           fast_arctan[ys][xs] :=arctan( xs / ys                   );

   end;//xs

   end;//ys


   for xs:=0 to fast_sincos_max do
   begin

   fast_sin[xs]       :=sin( xs / 1000 );
   fast_cos[xs]       :=cos( xs / 1000 );

   end;//xs


   end;


//.two-pie
twopie                :=2 * 3.1415926535897932384626433832795;
xshiftrad             :=( xshiftdeg / 360 ) * twopie;

//.t32
t32                   :=color32( 0 ,0 ,0 ,0 );

//.s
sox                   :=sw div 2;
soy                   :=sh div 2;

//.d
dw                    :=sw;
dh                    :=sh;


if xenlarge then
   begin

   ls                 :=max32;
   rs                 :=min32;
   ts                 :=max32;
   bs                 :=min32;


   //.top-left
   dmap( 0 ,0 ,dx ,dy );

   ls                 :=smallest32(ls,dx);
   rs                 :=largest32 (rs,dx);
   ts                 :=smallest32(ts,dy);
   bs                 :=largest32 (bs,dy);

   //.top-right
   dmap( pred(sw) ,0 ,dx ,dy );
   ls                 :=smallest32(ls,dx);
   rs                 :=largest32 (rs,dx);
   ts                 :=smallest32(ts,dy);
   bs                 :=largest32 (bs,dy);

   //.bottom-right
   dmap( pred(sw) ,pred(sh) ,dx ,dy );
   ls                 :=smallest32(ls,dx);
   rs                 :=largest32 (rs,dx);
   ts                 :=smallest32(ts,dy);
   bs                 :=largest32 (bs,dy);

   //.bottom-left
   dmap( 0 ,pred(sh) ,dx ,dy );
   ls                 :=smallest32(ls,dx);
   rs                 :=largest32 (rs,dx);
   ts                 :=smallest32(ts,dy);
   bs                 :=largest32 (bs,dy);

   //.new size
   dw                 :=rs-ls+1;
   dh                 :=bs-ts+1;

   //.new pivot
   dox                :=-ls+sox;
   doy                :=-ts+soy;

   end
else begin

   dox                :=sox;
   doy                :=soy;

   end;

//size "d"
if not missize( d ,dw ,dh ) then
   begin

   goto skipend;

   end;


//get --------------------------------------------------------------------------

//.dy
for dy:=0 to pred(dh) do
begin

if not misscan32( d ,dy ,dr32 ) then goto skipend;

//.ys
ys                    :=dy-doy;

if (ys<0) then ym     :=-ys
else           ym     :=ys;

xval1                 :=1.0 * ym * ym;

//.dx
for dx:=0 to pred(dw) do
begin

//.xs
xs                    :=dx-dox;

if (xs<0) then xm     :=-xs
else           xm     :=xs;


//.xlen
xlen                  :=sqrt( ( 1.0 * xm * xm ) + xval1 );

//.xdeg
if (ym=0) then
   begin

   xdeg               :=xshiftrad + arctan( xm / 0.000000000000000001 );

   end
else if (xs>=fast_arctan_min) and (xs<=fast_arctan_max) and (ys>=fast_arctan_min) and (ys<=fast_arctan_max) then
   begin

   xdeg               :=xshiftrad + fast_arctan[ys][xs];

   end
else begin

   xdeg               :=xshiftrad + arctan( xs / ys                   );

   end;



//.map
if ((xs>=0) and (ys<0)) or ((xs<0) and (ys<=0)) then
   begin

   if (xdeg>=0) and (xdeg<6.4) then
      begin

      dx2             :=round( sox - ( fast_sin[round(xdeg*1000)] * xlen ) );
      dy2             :=round( soy - ( fast_cos[round(xdeg*1000)] * xlen ) );

      end

   else begin

      dx2             :=round( sox - ( sin(xdeg) * xlen ) );
      dy2             :=round( soy - ( cos(xdeg) * xlen ) );

      end;

   end

else begin

   if (xdeg>=0) and (xdeg<6.4) then
      begin

      dx2             :=round( ( fast_sin[round(xdeg*1000)] * xlen ) + sox );
      dy2             :=round( ( fast_cos[round(xdeg*1000)] * xlen ) + soy );

      end

   else begin

      dx2             :=round( ( sin(xdeg) * xlen ) + sox );
      dy2             :=round( ( cos(xdeg) * xlen ) + soy );

      end;

   end;

//unbalanced pivot causes +90/-90 to leave a gap on boundary -> an even width/height will have an unbalanced pivot - 29sep2018
if ((xshiftdeg=90) or (xshiftdeg=-90) or (xshiftdeg=270) or (xshiftdeg=-270)) then
   begin

   //detect unbalanced pivout (sox/soy) and clip outer boundary by 1px
   if ((2*sox)=sw) and (dx2=sw) then dx2:=pred(sw);
   if ((2*soy)=sh) and (dy2=sh) then dy2:=pred(sh);

   end;

//range
if (dx2>=0) and (dx2<sw) and (dy2>=0) and (dy2<sh) then dr32[dx]:=srs32[dy2][dx2]
else                                                    dr32[dx]:=t32;

end;//dx

end;//dy

//successful
result                :=true;

skipend:

end;


//## tartfilter ################################################################

constructor tartfilter.create;
begin

//self
inherited create;

//vars
clear;

end;

destructor  tartfilter.destroy;
begin
try

//free

//self
inherited destroy;

except;end;
end;

procedure tartfilter.copyfrom(const x:tartfilter);
begin

//defaults
defaults;

//get
if (x<>nil) then
   begin

   //.area
   setarea( x.area );

   //.h
   hcolor1            :=x.hcolor1;
   hcolor2            :=x.hcolor2;
   hpower             :=x.hpower;
   hbend              :=x.hbend;
   hmode              :=x.hmode;

   //.v
   vcolor1            :=x.vcolor1;
   vcolor2            :=x.vcolor2;
   vpower             :=x.vpower;
   vbend              :=x.vbend;
   vmode              :=x.vmode;

   //.core
   drawmode           :=x.drawmode;
   power255           :=x.power255;
   linemode           :=x.linemode;
   linesize           :=x.linesize;
   sparkle20          :=x.sparkle20;
   threshold255       :=x.threshold255;

   end;

end;

procedure tartfilter.clear;
begin


iarea                 :=area__make( 0, 0, 0, 0 );
irandompos            :=0;//13jun2026

defaults;

end;

procedure tartfilter.defaults;
begin

//note: does not reset area

low__cls(@hlist,sizeof(hlist));
low__cls(@vlist,sizeof(vlist));

hlist.mode            :=bm_hill;
vlist.mode            :=bm_hill;

idrawmode             :=dm_lum;
ilinemode             :=lm_none;
setlinesize( 2 );
ipower255             :=255;
isparkle20            :=0;
ithreshold255         :=40;//12jun2026
imustsync             :=true;

end;

procedure tartfilter.resetRandom(const cindex,xmoreseparation:longint32);
begin

//random pos
static__randomnewpos( irandompos ,(cindex * 500) + xmoreseparation );

end;

procedure tartfilter.setlinesize(x:longint32);
begin

ilinesize   :=frcrange32( x ,1 ,32 );
ilinestep   :=ilinesize * 2;
ilinethre   :=pred(ilinestep div 2);

end;

procedure tartfilter.setpower255(x:longint32);
begin

ipower255   :=frcrange32( x ,0 ,255 );
hlist.ok    :=false;
vlist.ok    :=false;
imustsync   :=true;

end;

procedure tartfilter.setsparkle20(x:longint32);
begin

isparkle20  :=frcrange32( x ,0 ,20 );

end;

procedure tartfilter.setthreshold255(x:longint32);
begin

ithreshold255:=frcrange32( x ,0 ,255 );

end;

function tartfilter.gethmode:tartbendmode;
begin

result      :=hlist.mode;

end;

procedure tartfilter.sethmode(const x:tartbendmode);
begin

hlist.mode  :=x;
hlist.ok    :=false;
imustsync   :=true;

end;

function tartfilter.gethbend:double;
begin

result      :=hlist.bend;

end;

procedure tartfilter.sethbend(const x:double);
begin

if      (x<0) then hlist.bend:=0
else if (x>1) then hlist.bend:=1
else               hlist.bend:=x;

hlist.ok    :=false;
imustsync   :=true;

end;

function tartfilter.gethpower:double;
begin

result      :=hlist.power;

end;

procedure tartfilter.sethpower(const x:double);
begin

if      (x<-1) then hlist.power:=-1
else if (x>1 ) then hlist.power:=1
else                hlist.power:=x;

hlist.ok    :=false;
imustsync   :=true;

end;

procedure tartfilter.sethcolor1(const x:tcolor24);
begin

hlist.color1:=x;
hlist.ok    :=false;
imustsync   :=true;

end;

procedure tartfilter.sethcolor2(const x:tcolor24);
begin

hlist.color2:=x;
hlist.ok    :=false;
imustsync   :=true;

end;

function tartfilter.gethcolor1:tcolor24;
begin

result      :=hlist.color1;

end;

function tartfilter.gethcolor2:tcolor24;
begin

result      :=hlist.color2;

end;

function tartfilter.getvmode:tartbendmode;
begin

result      :=vlist.mode;

end;

procedure tartfilter.setvmode(const x:tartbendmode);
begin

vlist.mode  :=x;
vlist.ok    :=false;
imustsync   :=true;

end;

function tartfilter.getvbend:double;
begin

result      :=vlist.bend;

end;

procedure tartfilter.setvbend(const x:double);
begin

if      (x<0) then vlist.bend:=0
else if (x>1) then vlist.bend:=1
else               vlist.bend:=x;

vlist.ok    :=false;
imustsync   :=true;

end;

function tartfilter.getvpower:double;
begin

result      :=vlist.power;

end;

procedure tartfilter.setvpower(const x:double);
begin

if      (x<-1) then vlist.power:=-1
else if (x>1 ) then vlist.power:=1
else                vlist.power:=x;

vlist.ok    :=false;
imustsync   :=true;

end;

procedure tartfilter.setvcolor1(const x:tcolor24);
begin

vlist.color1:=x;
vlist.ok    :=false;
imustsync   :=true;

end;

procedure tartfilter.setvcolor2(const x:tcolor24);
begin

vlist.color2:=x;
vlist.ok    :=false;
imustsync   :=true;

end;

function tartfilter.getvcolor1:tcolor24;
begin

result      :=vlist.color1;

end;

function tartfilter.getvcolor2:tcolor24;
begin

result      :=vlist.color2;

end;

procedure tartfilter.xsync;
var
   dx                 :longint32;
   ax                 :longint32;
   xdiv               :longint32;
   xdiv2              :longint32;
   v                  :extended;
   v255               :longint32;

begin

//off
imustsync             :=false;


//hlist ------------------------------------------------------------------------

if not hlist.ok then
   begin

   hlist.ok           :=true;
   xdiv               :=frcmin32( iarea.right - iarea.left ,1 );
   xdiv2              :=frcmin32( (iarea.right - iarea.left) div 2 ,1 );//half

   for dx:=iarea.left to iarea.right do
   begin

   //init
   ax                 :=dx - iarea.left;

   case hlist.mode of

   bm_hill:begin

      //0..2 => 0..1..0
      v               :=ax / xdiv2;
      if (v>1) then v :=2.0 - v;

      end;

   bm_slope:begin

      //0..1 => 0..1
      v               :=ax / xdiv;

      end;

   bm_flat:begin

      //0 -> 0
      v               :=0;

      end;

   bm_flat2:begin

      //1 -> 1
      v               :=1;

      end;

   end;//case

   //bend
   v                  :=v * hlist.bend;

   //range
   if      (v<0) then v:=0
   else if (v>1) then v:=1;

   //0..1 - solid
   if (hlist.power>=0) then
      begin

      hlist.power255[ax] :=round( hlist.power * ipower255 );//0..255

      end

   //-1..<0 - merge with slope
   else begin

      hlist.power255[ax] :=round( v * -hlist.power * ipower255 );//0..255

      end;


   //get
   v255               :=round( v * 255 );
   hlist.clist[ax].r  :=( (v255*hlist.color2.r) + ((255-v255)*hlist.color1.r) ) shr 8;
   hlist.clist[ax].g  :=( (v255*hlist.color2.g) + ((255-v255)*hlist.color1.g) ) shr 8;
   hlist.clist[ax].b  :=( (v255*hlist.color2.b) + ((255-v255)*hlist.color1.b) ) shr 8;

   end;//dx

   end;


//vlist ------------------------------------------------------------------------

if not vlist.ok then
   begin

   vlist.ok           :=true;
   xdiv               :=frcmin32( iarea.bottom - iarea.top ,1 );
   xdiv2              :=frcmin32( (iarea.bottom - iarea.top) div 2 ,1 );//half

   for dx:=iarea.top to iarea.bottom do
   begin

   //init
   ax                 :=dx - iarea.top;

   case vlist.mode of

   bm_hill:begin

      //0..2
      v               :=ax / xdiv2;
      if (v>1) then v :=2.0 - v;

      end;

   bm_slope:begin

      //0..1
      v               :=ax / xdiv;

      end;

   bm_flat:begin

      //0 -> 0
      v               :=0;

      end;

   bm_flat2:begin

      //1 -> 1
      v               :=1;

      end;

   end;//case

   //bend
   v                  :=v * vlist.bend;

   //range
   if      (v<0) then v:=0
   else if (v>1) then v:=1;

   //0..1 - solid
   if (vlist.power>=0) then
      begin

      vlist.power255[ax] :=round( vlist.power * ipower255 );//0..255

      end

   //-1..<0 - merge with slope
   else begin

      vlist.power255[ax] :=round( v * -vlist.power * ipower255 );//0..255

      end;

   //get
   v255               :=round( v * 255 );
   vlist.clist[ax].r  :=( (v255*vlist.color2.r) + ((255-v255)*vlist.color1.r) ) shr 8;
   vlist.clist[ax].g  :=( (v255*vlist.color2.g) + ((255-v255)*vlist.color1.g) ) shr 8;
   vlist.clist[ax].b  :=( (v255*vlist.color2.b) + ((255-v255)*vlist.color1.b) ) shr 8;

   end;//dx

   end;

end;

procedure tartfilter.filter32(const dx,dy:longint32;s32:tcolor32;var d32:tcolor32);
var//Note: dx=0..pred(icellwidth) and dy=0..pred(icellheight) at all times - 11jun2026
   lum                :longint32;
   dpower             :longint32;
   inva               :longint32;
   v                  :longint32;
   ax                 :longint32;

begin


//check
if (ipower255<=0) then exit;


//sync
if imustsync then xsync;


//sparkle
if (isparkle20>=1) then
   begin

   if (static__random( irandompos, 40 )>=isparkle20) then exit;

   end;


//linemode
case ilinemode of

lm_horz:begin

   v                  :=dy - ((dy div ilinestep)*ilinestep);

   if (v<=ilinethre) then exit;

   end;

lm_horz2:begin

   v                  :=dy - ((dy div ilinestep)*ilinestep);

   if (v>ilinethre) then exit;

   end;

lm_vert:begin

   v                  :=dx - ((dx div ilinestep)*ilinestep);

   if (v<=ilinethre) then exit;

   end;

lm_vert2:begin

   v                  :=dx - ((dx div ilinestep)*ilinestep);

   if (v>ilinethre) then exit;

   end;

end;//case


//drawmode
case idrawmode of

dm_raw:begin

   d32                :=s32;

   exit;

   end;

dm_lum:begin

   lum                :=s32.r;
   if (s32.g>lum) then lum:=s32.g;
   if (s32.b>lum) then lum:=s32.b;

   lum                :=(lum*s32.a) shr 8;//full range: 0..255

   end;

dm_luminv:begin

   lum                :=s32.r;
   if (s32.g>lum) then lum:=s32.g;
   if (s32.b>lum) then lum:=s32.b;

   lum                :=((255-lum)*s32.a) shr 8;//full range: 0..255

   end;

dm_replace:begin

   lum                :=255;

   end;

dm_whites:begin

   lum                       :=s32.r;
   if (s32.g>lum) then lum   :=s32.g;
   if (s32.b>lum) then lum   :=s32.b;

   //cut-off
   if (lum<ithreshold255) then exit;//part range: ithreshold..255

   //alpha merge
   lum                       :=(lum*s32.a) shr 8;

   end;

dm_blacks:begin

   lum                       :=s32.r;
   if (s32.g>lum) then lum   :=s32.g;
   if (s32.b>lum) then lum   :=s32.b;
   lum                       :=(255-lum);

   //cut-off
   if (lum<ithreshold255) then exit;//part range: ithreshold..255

   //alpha merge
   lum                       :=(lum*s32.a) shr 8;

   end;

dm_alpha:begin

   lum                       :=s32.a;

   end;

else begin

   exit;

   end;

end;//case


//get
if (lum>=1) and (dx>=iarea.left) and (dx<=iarea.right) and (dy>=iarea.top) and (dy<=iarea.bottom) then
   begin

   //sparkle
   if (isparkle20>=1) then
      begin

      //strong sparkle lum - 12jun2026
      lum             :=static__random( irandompos, 2 * lum );

      if (lum>255) then
         begin

         lum          :=255;

         end

      else if (lum<1) then
         begin

         lum          :=1;

         end;

      end;

   //hlist
   ax                 :=dx-iarea.left;

   if (hlist.power255[ax]>=1) then
      begin

      dpower          :=(  hlist.power255[ax] * lum ) shr 8;
      d32.r           :=( (hlist.clist[ax].r*dpower) + ((255-dpower)*d32.r) ) shr 8;
      d32.g           :=( (hlist.clist[ax].g*dpower) + ((255-dpower)*d32.g) ) shr 8;
      d32.b           :=( (hlist.clist[ax].b*dpower) + ((255-dpower)*d32.b) ) shr 8;
      d32.a           :=( (255*dpower) + ((255-dpower)*d32.a) ) shr 8;

      end;

   //vlist
   ax                 :=dy-iarea.top;

   if (vlist.power255[ax]>=1) then
      begin

      dpower          :=(  vlist.power255[ax] * lum ) shr 8;
      d32.r           :=( (vlist.clist[ax].r*dpower) + ((255-dpower)*d32.r) ) shr 8;
      d32.g           :=( (vlist.clist[ax].g*dpower) + ((255-dpower)*d32.g) ) shr 8;
      d32.b           :=( (vlist.clist[ax].b*dpower) + ((255-dpower)*d32.b) ) shr 8;
      d32.a           :=( (255*dpower) + ((255-dpower)*d32.a) ) shr 8;

      end;

   end;

end;

procedure tartfilter.setarea(const d:twinrect);
begin

//limit width and height to internal limits
iarea.left            :=d.left;
iarea.right           :=frcrange32( d.right  ,d.left ,d.left + high(hlist.clist) );
iarea.top             :=d.top;
iarea.bottom          :=frcrange32( d.bottom ,d.top  ,d.top  + high(vlist.clist) );

hlist.ok              :=false;
vlist.ok              :=false;
imustsync             :=true;

end;

procedure tartfilter.setarea2(const d:tartbase);
begin

if (d<>nil) then setarea( d.cellarea )
else             setarea( area__make(0,0,0,0) );

end;


//## tartbase ##################################################################

constructor tartbase.create;
begin

//self
inherited create;

//vars
iimage                :=miscom32(1,1);
isrs32                :=iimage.prows32;
icellindex            :=0;
icellcount            :=1;
icellwidth            :=1;
icellheight           :=1;
ihotx                 :=0;
ihoty                 :=0;
icelldelay            :=0;
iwidth                :=1;
iheight               :=1;
imapcount             :=1;
ifilter               :=tartfilter.create;

low__cls(@imaplist,sizeof(imaplist));
low__cls(@iworkarea,sizeof(iworkarea));

//event
on__create;

end;

procedure   tartbase.on__create;
begin

//nil

end;

procedure   tartbase.on__destroy;
begin

//nil

end;

destructor  tartbase.destroy;
begin
try

//free
freeobj(@iimage);
freeobj(@ifilter);

//self
inherited destroy;

except;end;
end;

function tartbase.loadfrom(const x:array of byte):boolean;
begin

result      :=loadfrom2( x ,0 ,0 );

end;

function tartbase.loadfrom2(const x:array of byte;const xforceCellCount,xforceDelay:longint32):boolean;
var
   cindex             :longint32;
   hx                 :longint32;
   hy                 :longint32;

begin

//init
result                :=mis__fromarray2( iimage     ,x );
isrs32                :=iimage.prows32;
iwidth                :=frcmin32( iimage.width      ,1 );
iheight               :=frcmin32( iimage.height     ,1 );

//cells
if (xforceCellCount>=1) then
   begin

   icellheight        :=iheight;
   icellwidth         :=frcmin32( iwidth div xforceCellCount  ,1 );
   icellcount         :=frcmin32( iwidth div icellwidth       ,1 );

   end
else begin

   icellcount         :=frcmin32( iimage.ai.count      ,frcmin32( xforceCellCount ,1 ) );//convert a static imagestrip, e.g. in png format, into a celllist of X cells
   icellwidth         :=frcmin32( iimage.ai.cellwidth  ,1 );
   icellheight        :=frcmin32( iimage.ai.cellheight ,1 );

   end;


//enforce cellwidth/cellheight range - 12jun2026
icellwidth            :=frcmax32( icellwidth  ,cursor_maxsize );
icellheight           :=frcmax32( icellheight ,cursor_maxsize );

//limit cellcount to internal limits
icellcount            :=frcmax32( icellcount ,high(iworkarea)+1 );
icellindex            :=0;

//common
case (icellcount>=2) of
true:icelldelay       :=frcmin32( low__aorb( iimage.ai.delay ,xforceDelay ,xforceDelay>=1 ) ,1 );
else icelldelay       :=0;
end;//case

setmapcount( icellcount );

//workarea for each cell
for cindex:=0 to pred(icellcount) do
begin

mis__scanAH( iimage, cindex*icellwidth ,cindex*icellwidth + pred(icellwidth) ,iworkarea[cindex] ,hx ,hy );

//.1st cell sets the hotspotX/Y for all cells
if (cindex=0) then
   begin

   ihotx              :=hx;
   ihoty              :=hy;

   end;

end;//cindex


//sharp-drop alpha values for crisp clean edges - 20jun2026, 18jun2026
for hy:=0 to pred(iimage.height) do
begin

for hx:=0 to pred(iimage.width) do
begin

isrs32[hy][hx].a      :=( (isrs32[hy][hx].a*255) + (255-isrs32[hy][hx].a) ) shr 8;

end;//dx

end;//dy


end;

function tartbase.getworkarea(cindex:longint):twinrect;
begin

if      (icellcount<=0)        then result:=area__make(0,0,0,0)
else if (cindex<=0)            then result:=iworkarea[0]
else if (cindex>=icellcount)   then result:=iworkarea[pred(icellcount)]
else                                result:=iworkarea[cindex];

end;

procedure tartbase.setcellindex(x:longint32);
begin

icellindex  :=frcrange32( x ,0 ,frcmin32(pred(icellcount),0) );

end;

function tartbase.cellarea:twinrect;
begin

if (icellcount<=0) then result:=area__make(0,0,0,0)
else                    result:=iworkarea[ icellindex ];

end;

procedure tartbase.setmapcount(const dnewCellCount:longint32);
var
   p        :longint32;

begin

imapcount   :=frcmin32( dnewCellCount ,1 );

//1:1 ratio
if (imapcount=icellcount) then
   begin

   for p:=0 to high(imaplist) do
   begin

   if (p<imapcount) then imaplist[p] :=p
   else                  imaplist[p] :=pred(icellcount);

   end;//p

   end

//variable ratio
else begin

   for p:=0 to high(imaplist) do
   begin

   if (p<imapcount) then imaplist[p] :=round( ( (p+1) / imapcount ) * pred(icellcount) )
   else                  imaplist[p] :=pred(icellcount);

   end;//p

   end;

end;

procedure tartbase.setRGBA(const cindex,dx,dy:longint32;const r,g,b,a:byte);
begin

if (cindex>=0) and (cindex<icellcount) and (dy>=0) and (dy<icellheight) and (dx>=0) and (dx<icellwidth) then
   begin

   isrs32[ dy ][ (cindex*icellwidth) + dx ].r    :=r;
   isrs32[ dy ][ (cindex*icellwidth) + dx ].g    :=g;
   isrs32[ dy ][ (cindex*icellwidth) + dx ].b    :=b;
   isrs32[ dy ][ (cindex*icellwidth) + dx ].a    :=a;

   end;

end;

procedure tartbase.setRGB(const cindex,dx,dy:longint32;const r,g,b:byte);
begin

if (cindex>=0) and (cindex<icellcount) and (dy>=0) and (dy<icellheight) and (dx>=0) and (dx<icellwidth) then
   begin

   isrs32[ dy ][ (cindex*icellwidth) + dx ].r    :=r;
   isrs32[ dy ][ (cindex*icellwidth) + dx ].g    :=g;
   isrs32[ dy ][ (cindex*icellwidth) + dx ].b    :=b;

   end;

end;

function tartbase.draw(const d:tcommonimage;cindex:longint32;const ddx,ddy:longint32):boolean;
var
   sr32     :pcolorrow32;
   dr32     :pcolorrow32;
   sx       :longint32;
   sx1      :longint32;
   sx2      :longint32;
   sy       :longint32;
   dx       :longint32;
   dy       :longint32;
   dw       :longint32;
   dh       :longint32;

begin

//defaults
result      :=false;

//check
if (d=nil)                             then exit;
if (ddy>=d.height) or (ddy<=-d.height) then exit;
if (ddx>=d.width)  or (ddx<=-d.width)  then exit;

//init
cindex                :=frcrange32( cindex ,0 ,pred(icellcount) );
dw                    :=d.width;
dh                    :=d.height;
dy                    :=ddy;
sx1                   :=cindex * icellwidth;
sx2                   :=sx1 + pred(icellwidth);
ifilter.power255      :=255;
ifilter.setarea( iworkarea[ cindex ] );

//sy
for sy:=0 to pred(icellheight) do
begin

//sx
if (dy>=0) and (dy<dh) then
   begin

   //init
   dx       :=ddx;
   sr32     :=isrs32[sy];

   if not misscan32( d ,dy ,dr32 ) then break;

   //get
   for sx:=sx1 to sx2 do
   begin

   if (dx>=0) then
      begin

      if (dx>=dw) then break
      else             ifilter.filter32( sx ,sy ,sr32[sx] ,dr32[dx] );

      end;

   //inc
   inc(dx);

   end;//sx

   end;

//inc
inc( dy );

if (dy>=dh) then break;

end;//sy

//successful
result      :=true;

end;

function tartbase.draw2(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32):boolean;
var
   sr32     :pcolorrow32;
   dr32     :pcolorrow32;
   sx       :longint32;
   sx1      :longint32;
   sx2      :longint32;
   sy       :longint32;
   dx       :longint32;
   dy       :longint32;
   dw       :longint32;
   dh       :longint32;

begin

//defaults
result      :=false;

//decide
if (dpower255<=0) then
   begin

   result   :=true;

   exit;

   end

else if (dpower255>=255) then
   begin

   result   :=draw(d,cindex,ddx,ddy);

   exit;

   end;

//check
if (d=nil)                             then exit;
if (ddy>=d.height) or (ddy<=-d.height) then exit;
if (ddx>=d.width)  or (ddx<=-d.width)  then exit;

//init
cindex                :=frcrange32( cindex ,0 ,pred(icellcount) );
dw                    :=d.width;
dh                    :=d.height;
dy                    :=ddy;
sx1                   :=cindex * icellwidth;
sx2                   :=sx1 + pred(icellwidth);
ifilter.power255      :=dpower255;
ifilter.setarea( iworkarea[ cindex ] );

//sy
for sy:=0 to pred(icellheight) do
begin

//sx
if (dy>=0) and (dy<dh) then
   begin

   //init
   dx       :=ddx;
   sr32     :=isrs32[sy];

   if not misscan32( d ,dy ,dr32 ) then break;

   //get
   for sx:=sx1 to sx2 do
   begin

   if (dx>=0) then
      begin

      if (dx>=dw) then break

      else begin

         ifilter.filter32( sx - sx1 ,sy ,sr32[sx] ,dr32[dx] );

         end;

      end;

   //inc
   inc(dx);

   end;//sx

   end;

//inc
inc( dy );

if (dy>=dh) then break;

end;//sy

//successful
result      :=true;

end;

function tartbase.draw3(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32;const dmirror,dflip:boolean):boolean;
var
   sr32     :pcolorrow32;
   dr32     :pcolorrow32;
   sx       :longint32;
   ssx      :longint32;
   sx1      :longint32;
   sx2      :longint32;
   ssy      :longint32;
   sy       :longint32;
   dx       :longint32;
   dy       :longint32;
   dw       :longint32;
   dh       :longint32;

begin

//defaults
result      :=false;

//decide
if (dpower255<=0) then
   begin

   result   :=true;

   exit;

   end

else if dmirror or dflip then
   begin

   //ok

   end

else if (dpower255>=255) then
   begin

   result   :=draw(d,cindex,ddx,ddy);

   exit;

   end

else begin

   result   :=draw2(d,cindex,ddx,ddy,dpower255);

   exit;

   end;

//check
if (d=nil)                             then exit;
if (ddy>=d.height) or (ddy<=-d.height) then exit;
if (ddx>=d.width)  or (ddx<=-d.width)  then exit;

//init
cindex                :=frcrange32( cindex ,0 ,pred(icellcount) );
dw                    :=d.width;
dh                    :=d.height;
dy                    :=ddy;
sx1                   :=cindex * icellwidth;
sx2                   :=sx1 + pred(icellwidth);
ifilter.power255      :=dpower255;
ifilter.setarea( iworkarea[ cindex ] );

//sy
for ssy:=0 to pred(icellheight) do
begin

//sx
if (dy>=0) and (dy<dh) then
   begin

   //init
   dx       :=ddx;

   if dflip then sy:=pred(icellheight)- ssy
   else          sy:=ssy;

   sr32     :=isrs32[sy];

   if not misscan32( d ,dy ,dr32 ) then break;

   //get
   for ssx:=sx1 to sx2 do
   begin

   if dmirror then sx:=sx2 + sx1 - ssx
   else            sx:=ssx;

   if (dx>=0) then
      begin

      if      (dx>=dw)         then break

      else begin

         ifilter.filter32( sx ,sy ,sr32[sx] ,dr32[dx] );

         end;

      end;//dx

   //inc
   inc(dx);

   end;//sx

   end;

//inc
inc( dy );

if (dy>=dh) then break;

end;//sy

//successful
result      :=true;

end;

function tartbase.draw4(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32;const drotate:tartrotate;const dmirror:boolean):boolean;
var//Note: only supports rotate when icellwidth=icellheight and only for 90,180,270
   dr32     :pcolorrow32;
   sx       :longint32;
   sx1      :longint32;
   sy       :longint32;
   dx       :longint32;
   dy       :longint32;
   dw       :longint32;
   dh       :longint32;
   fx       :longint32;
   fy       :longint32;
   dmax     :longint32;

begin

//defaults
result      :=false;

//decide
if (dpower255<=0) then
   begin

   result   :=true;

   exit;

   end

else if (drotate<>rt_0) and (icellwidth=icellheight) then
   begin

   //ok

   end

else if (dpower255>=255) and (not dmirror) then
   begin

   result   :=draw(d,cindex,ddx,ddy);

   exit;

   end

else begin

   case dmirror of
   true:result   :=draw3(d,cindex,ddx,ddy,dpower255,dmirror,false);//25jun2026
   else result   :=draw2(d,cindex,ddx,ddy,dpower255);
   end;

   exit;

   end;

//check
if (d=nil)                             then exit;
if (ddy>=d.height) or (ddy<=-d.height) then exit;
if (ddx>=d.width)  or (ddx<=-d.width)  then exit;

//init
cindex                :=frcrange32( cindex ,0 ,pred(icellcount) );
dw                    :=d.width;
dh                    :=d.height;
dy                    :=ddy;
sx1                   :=cindex * icellwidth;
dmax                  :=pred(icellwidth);
ifilter.power255      :=dpower255;
ifilter.setarea( iworkarea[ cindex ] );

//sy
for sy:=0 to dmax do
begin

//sx
if (dy>=0) and (dy<dh) then
   begin

   if not misscan32( d ,dy ,dr32 ) then break;

   //mirror
   case dmirror of
   true:dx:=ddx + dmax;
   else dx:=ddx;
   end;//case

   //get
   for sx:=0 to dmax do
   begin

   if (dx>=0) then
      begin

      //decide
      case drotate of

      rt_90:begin//r90

         fx           :=sy;
         fy           :=dmax - sx;

         end;

      rt_180:begin//r180

         fx           :=dmax - sx;
         fy           :=dmax - sy;

         end;

      rt_270:begin//r270

         fx           :=dmax - sy;
         fy           :=sx;

         end;

      else begin//r0

         fx           :=sx;
         fy           :=sy;

         end;

      end;//case

      //set
      if      (dx>=dw)         then break
      else                          ifilter.filter32( sx1 + fx ,fy ,isrs32[fy][sx1 + fx] ,dr32[dx] );

      end;//dx

   //inc
   case dmirror of
   true:dec(dx);
   else inc(dx);
   end;

   end;//sx

   end;

//inc
inc( dy );

if (dy>=dh) then break;

end;//sy

//successful
result      :=true;

end;

function tartbase.draw5(const d:tcommonimage;cindex:longint32;ddx,ddy:longint32;const dpower255:longint32;const xrotate:extended;const dmirror:boolean):boolean;
var
   v        :tartrotate;

begin

if (dpower255<=0) then
   begin

   result   :=true;

   end

else if (xrotate<>0) then
   begin

   //if cell is square and rotation is simple, pass off to a faster proc
   if (icellwidth=icellheight) and (not dmirror) then
      begin

      if      (xrotate=90)  then v     :=rt_90
      else if (xrotate=180) then v     :=rt_180
      else if (xrotate=270) then v     :=rt_270
      else                       v     :=rt_0;

      if (v<>rt_0) then
         begin

         result                        :=draw4( d ,cindex ,ddx ,ddy ,dpower255 ,v ,dmirror );

         exit;

         end;

      end;

   //slow rotate
   result                              :=xrotate32( d ,cindex ,ddx ,ddy ,dpower255 ,xrotate ,dmirror );

   end

else if (dpower255>=255) and (not dmirror) then
   begin

   result   :=draw(d,cindex,ddx,ddy);

   end

else begin

   case dmirror of
   true:result   :=draw3(d,cindex,ddx,ddy,255,dmirror,false);
   else result   :=draw2(d,cindex,ddx,ddy,dpower255);
   end;//case

   end;

end;

function tartbase.xrotate32(const d:tcommonimage;cindex:longint32;const ddx,ddy,dpower255:longint32;xshiftdeg:extended;const dmirror:boolean):boolean;//25jun2026, 12jun2026, 29sep2018
label
   skipend;

var
   tr32               :pcolorrow32;
   xm                 :longint32;
   ym                 :longint32;
   xs                 :longint32;
   ys                 :longint32;
   dx                 :longint32;
   dy                 :longint32;
   dx2                :longint32;
   dy2                :longint32;
   sox                :longint32;
   soy                :longint32;
   xshiftrad          :double;
   twopie             :double;
   xlen               :double;
   xdeg               :double;
   xval1              :double;
   sx1                :longint32;
   tw                 :longint32;
   th                 :longint32;
   tx                 :longint32;
   ty                 :longint32;

begin


//defaults
result                :=false;

//check
if (d=nil)                             then exit;
if (ddy>=d.height) or (ddy<=-d.height) then exit;
if (ddx>=d.width)  or (ddx<=-d.width)  then exit;

//scale down

if (xshiftdeg>360) then
   begin

   xshiftdeg          :=xshiftdeg - ( (round(xshiftdeg) div 360) * 360 );

   end

else if (xshiftdeg<-360) then
   begin

   xshiftdeg          :=-xshiftdeg;//make positive
   xshiftdeg          :=xshiftdeg - ( (round(xshiftdeg) div 360) * 360 );
   xshiftdeg          :=-xshiftdeg;//make negative

   end;


//init -------------------------------------------------------------------------


if not fast_arctanOK then
   begin


   fast_arctanOK:=true;

   for ys:=fast_arctan_min to fast_arctan_max do
   begin

   for xs:=fast_arctan_min to fast_arctan_max do
   begin

   if (ys=0) then fast_arctan[ys][xs] :=arctan( xs / 0.000000000000000001 )
   else           fast_arctan[ys][xs] :=arctan( xs / ys                   );

   end;//xs

   end;//ys


   for xs:=0 to fast_sincos_max do
   begin

   fast_sin[xs]       :=sin( xs / 1000 );
   fast_cos[xs]       :=cos( xs / 1000 );

   end;//xs


   end;


cindex                :=frcrange32( cindex ,0 ,pred(icellcount) );
sx1                   :=cindex * icellwidth;
tw                    :=d.width;
th                    :=d.height;
ifilter.power255      :=dpower255;
ifilter.setarea( iworkarea[ cindex ] );

//.two-pie
twopie                :=2 * 3.1415926535897932384626433832795;
xshiftrad             :=( xshiftdeg / 360 ) * twopie;

//.s
sox                   :=icellwidth  div 2;
soy                   :=icellheight div 2;


//get --------------------------------------------------------------------------
//Note: rotate based on 1st cell, then shift by sx1 and ddx as required

//.dy
for dy:=0 to pred(icellheight) do
begin

//.target y
ty                    :=ddy + dy;

if (ty>=0) and (ty<th) then
   begin

   if not misscan32( d ,ty ,tr32 ) then goto skipend;

   //.ys
   ys                    :=dy-soy;

   if (ys<0) then ym     :=-ys
   else           ym     :=ys;

   xval1                 :=1.0 * ym * ym;

   //.dx
   for dx:=0 to pred(icellwidth) do
   begin

   case dmirror of
   true:tx               :=ddx + pred(icellwidth) - dx;
   else tx               :=ddx + dx;
   end;//case

   if (tx>=0) and (tx<tw) then
      begin

      //.xs
      xs                    :=dx-sox;

      if (xs<0) then xm     :=-xs
      else           xm     :=xs;

      //.xlen
      xlen                  :=sqrt( ( 1.0 * xm * xm ) + xval1 );

      //.xdeg
      if (ym=0) then
         begin

         xdeg               :=xshiftrad + arctan( xm / 0.000000000000000001 );

         end
      else if (xs>=fast_arctan_min) and (xs<=fast_arctan_max) and (ys>=fast_arctan_min) and (ys<=fast_arctan_max) then
         begin

         xdeg               :=xshiftrad + fast_arctan[ys][xs];

         end
      else begin

         xdeg               :=xshiftrad + arctan( xs / ys                   );

         end;

      //.map
      if ((xs>=0) and (ys<0)) or ((xs<0) and (ys<=0)) then
         begin

         if (xdeg>=0) and (xdeg<6.4) then
            begin

            dx2             :=round( sox - ( fast_sin[round(xdeg*1000)] * xlen ) );
            dy2             :=round( soy - ( fast_cos[round(xdeg*1000)] * xlen ) );

            end

         else begin

            dx2             :=round( sox - ( sin(xdeg) * xlen ) );
            dy2             :=round( soy - ( cos(xdeg) * xlen ) );

            end;

         end

      else begin

         if (xdeg>=0) and (xdeg<6.4) then
            begin

            dx2             :=round( ( fast_sin[round(xdeg*1000)] * xlen ) + sox );
            dy2             :=round( ( fast_cos[round(xdeg*1000)] * xlen ) + soy );

            end

         else begin

            dx2             :=round( ( sin(xdeg) * xlen ) + sox );
            dy2             :=round( ( cos(xdeg) * xlen ) + soy );

            end;

         end;

      //unbalanced pivot causes +90/-90 to leave a gap on boundary -> an even width/height will have an unbalanced pivot - 29sep2018
      if ((xshiftdeg=90) or (xshiftdeg=-90) or (xshiftdeg=270) or (xshiftdeg=-270)) then
         begin

         //detect unbalanced pivout (sox/soy) and clip outer boundary by 1px
         if ((2*sox)=icellwidth ) and (dx2=icellwidth ) then dx2:=pred(icellwidth);
         if ((2*soy)=icellheight) and (dy2=icellheight) then dy2:=pred(icellheight);

         end;

      //range
      if (dx2>=0) and (dx2<icellwidth) and (dy2>=0) and (dy2<icellheight) then
         begin

         ifilter.filter32( dx2 + sx1 ,dy2 ,isrs32[dy2][dx2 + sx1] ,tr32[tx] );

         end;

      end;//tx

   end;//ty

end;//dx

end;//dy


//successful
result                :=true;

skipend:

end;

function tartbase.mapdraw(const d:tcommonimage;const cindex,ddx,ddy:longint32):boolean;
begin

if (cindex<0) then
   begin

   result   :=draw( d ,imaplist[0] ,ddx ,ddy );

   end

else if (cindex>high(imaplist)) then
   begin

   result   :=draw( d ,imaplist[high(imaplist)] ,ddx ,ddy );

   end

else begin

   result   :=draw( d ,imaplist[cindex] ,ddx ,ddy )

   end;

end;

function tartbase.mapdraw2(const d:tcommonimage;const cindex,ddx,ddy,dpower255:longint32):boolean;
begin

if (cindex<0) then
   begin

   result   :=draw2( d ,imaplist[0] ,ddx ,ddy ,dpower255 );

   end

else if (cindex>high(imaplist)) then
   begin

   result   :=draw2( d ,imaplist[high(imaplist)] ,ddx ,ddy ,dpower255 );

   end

else begin

   result   :=draw2( d ,imaplist[cindex] ,ddx ,ddy ,dpower255 );

   end;

end;

function tartbase.mapdraw3(const d:tcommonimage;const cindex,ddx,ddy,dpower255:longint32;const dmirror,dflip:boolean):boolean;
begin

if (cindex<0) then
   begin

   result   :=draw3( d, imaplist[0], ddx, ddy, dpower255 ,dmirror ,dflip );

   end

else if (cindex>high(imaplist)) then
   begin

   result   :=draw3( d ,imaplist[high(imaplist)] ,ddx ,ddy ,dpower255 ,dmirror ,dflip );

   end

else begin

   result   :=draw3( d ,imaplist[cindex] ,ddx ,ddy ,dpower255 ,dmirror ,dflip );

   end;

end;

function tartbase.mapdraw4(const d:tcommonimage;const cindex,ddx,ddy,dpower255:longint32;const drotate:tartrotate;const dmirror:boolean):boolean;
begin

if (cindex<0) then
   begin

   result   :=draw4( d, imaplist[0], ddx, ddy, dpower255 ,drotate ,dmirror );

   end

else if (cindex>high(imaplist)) then
   begin

   result   :=draw4( d ,imaplist[high(imaplist)] ,ddx ,ddy ,dpower255 ,drotate ,dmirror );

   end

else begin

   result   :=draw4( d ,imaplist[cindex] ,ddx ,ddy ,dpower255 ,drotate ,dmirror );

   end;

end;


//333333333333333333333333
//## tcursorbase ###############################################################

constructor tcursorbase.create;
begin

//self
inherited create;

//vars
low__cls(@altlist,sizeof(altlist));

iart                  :=nil;
iart2                 :=nil;
iart3                 :=nil;
ipert1                :=0;
ipert2                :=0;
ipert4                :=0;
ipert8                :=0;

ilastref              :='';
isize                 :=32;

iedgeColor            :=clnone;
ibodyColor1           :=0;
ibodyColor2           :=255;
ibodyColor3           :=120;
isparkleColor         :=clnone;


//init and set defaults
low__cls(@info,sizeof(info));

setinfo( info );

//event
on__create;

end;

destructor tcursorbase.destroy;
begin
try

//vars
freeobj(@iart);
freeobj(@iart2);
freeobj(@iart3);

//self
inherited destroy;

except;end;
end;

procedure tcursorbase.setsize(x:longint32);
begin

on__filtersize( x );

isize       :=frcrange32( x ,cursor_minsize ,cursor_maxsize );

xsyncSize;

end;

procedure tcursorbase.setinfo(x:tmakecursorinfo);
var
   xspeed100                    :longint32;

begin

//filter
on__filtersize( isize );

xsyncSize;

on__filterinfo( x     );

//range
x.cf                            :=frcrange32( x.cf ,0 ,cf_max );
x.cc                            :=frcrange32( x.cc ,0 ,cc_max );
x.cb                            :=frcrange32( x.cb ,0 ,cb_max );
x.co                            :=frcrange32( x.co ,0 ,co_max );
x.ca                            :=frcrange32( x.ca ,0 ,ca_max );
x.ct                            :=frcrange32( x.ct ,0 ,ct_max );
x.cv                            :=frcrange32( x.cv ,0 ,cv_max );

//.image references only -> cf_install is a text script not an image
if (x.cf=cf_install) then x.cf  :=cf_arrow;

//info
info                            :=x;
icfindex                        :=x.cf;

//hollow -> uses a different set of images for this
ihollow                         :=( x.cv =  cv_outline );

//opacity
case x.co of
co_100      :iopacity           :=255;
co_75       :iopacity           :=191;
co_50       :iopacity           :=127;
co_30       :iopacity           :=77;
else         iopacity           :=255;
end;//case

//cell count
case x.ca of
ca_static   :icellcount         :=1;
ca_72cell   :icellcount         :=frcmax32( 72 ,cursor_celllimit );
ca_48cell   :icellcount         :=frcmax32( 48 ,cursor_celllimit );
ca_24cell   :icellcount         :=frcmax32( 24 ,cursor_celllimit );
ca_16cell   :icellcount         :=frcmax32( 16 ,cursor_celllimit );
ca_8cell    :icellcount         :=frcmax32(  8 ,cursor_celllimit );
else         icellcount         :=48;
end;//case

icellcount2                     :=frcmin32( icellcount div 2 ,1 );
icellcount4                     :=frcmin32( icellcount div 4 ,1 );
icellcount8                     :=frcmin32( icellcount div 8 ,1 );

//delay
case x.ca of
ca_static   :idelay             :=0  ;//static
ca_72cell   :idelay             :=33 ;//a factor 16.66 -> 30 fps -> critical for high-speed timing of animation - 15jun2026
ca_48cell   :idelay             :=50 ;//20 fps
ca_24cell   :idelay             :=100;//10 fps
ca_16cell   :idelay             :=150;// 6.6 fps
ca_8cell    :idelay             :=300;// 3.3 fps
else         idelay             :=50 ;//20 fps
end;//case

//.delay modifier - 25jun2026
if cursor_customcolors.useShared then xspeed100:=cursor_customcolors.shared.speed
else                                  xspeed100:=cursor_customcolors.clist[ x.cf ].speed;

if (xspeed100<>100) then
   begin

   idelay                       :=round( (idelay * 100) /  frcrange32( xspeed100 ,cursorspeed_min ,cursorspeed_max ) );//25jun2026

   end;

//.mirror modifier - 25jun2026
if cursor_customcolors.useShared then imirror:=cursor_customcolors.shared.mirror
else                                  imirror:=cursor_customcolors.clist[ x.cf ].mirror;

//support vars
ianimate                        :=( x.ca <> ca_static  );
isolid                          :=( x.cv =  cv_solid   );
isparkle                        :=( x.ct =  ct_sparkle );
ihstripe                        :=( x.ct =  ct_hstripe );
ivstripe                        :=( x.ct =  ct_vstripe );
ipulse                          :=( x.ct =  ct_pulse   );
iflat                           :=( x.ct =  ct_flat    );

end;

procedure tcursorbase.xsyncSize;
begin

iwidth                          :=isize;
iheight                         :=isize;
ibytes                          :=round32( (33/8) * iwidth * iheight * icellcount );//32-bit color image and 1-bit mask

end;

procedure tcursorbase.xautoload;
begin

if low__setstr( ilastref ,bolstr(ihollow)+'|'+intstr32(icfindex)+'|'+intstr32(isize) ) then
   begin

   //clear previous
   clearArts;

   //load
   on__load;

   end;

end;

procedure tcursorbase.on__filtersize(var x:longint32);
begin

//nil

end;

procedure tcursorbase.on__filterinfo(var x:tmakecursorinfo);
begin

//nil

end;

procedure tcursorbase.on__load;
begin

//nil

end;

procedure tcursorbase.on__create;
begin

//nil

end;

procedure tcursorbase.on__destroy;
begin

//nil

end;

procedure tcursorbase.on__cell(const dcell32:tcommonimage;const cindex,ccount:longint32);
var
   xmirror            :boolean;

begin

//check
if (dcell32=nil) then exit;

//auto-load
xautoload;

//size check
if (dcell32.width<iwidth) and (dcell32.height<iheight) then
   begin

   missize( dcell32 ,iwidth ,iheight );

   end

else if (dcell32.width<iwidth) then
   begin

   missize( dcell32 ,iwidth ,dcell32.height );

   end

else if (dcell32.height<iheight) then
   begin

   missize( dcell32 ,dcell32.width ,iheight );

   end;

//cls
mis__cls( dcell32 ,0 ,0 ,0 ,0 );

//range check
if (cindex<0) or (cindex>=icellcount) or (ccount<=0) or (ccount>icellcount) then
   begin

   exit;

   end;


//static random reset
if (iart <>nil) then iart .filter.resetRandom( cindex ,0 );
if (iart2<>nil) then iart2.filter.resetRandom( cindex ,172 );
if (iart3<>nil) then iart3.filter.resetRandom( cindex ,313 );


//support info
on__cellinfo( cindex );

//1st cell
if (cindex=0) then
   begin

   on__cellfirst( dcell32 ,cindex ,ccount );

   end;

//render cell
xmirror     :=imirror;
on__celldraw( dcell32 ,cindex ,ccount ,xmirror );

if xmirror then
   begin

   on__mirror( dcell32 ,cindex=0 );

   end;
   
//enforce opacity
if (iopacity<255) then
   begin

   mask__setopacity( dcell32 ,iopacity );

   end;

end;

procedure tcursorbase.on__cellinfo(const cindex:longint);
begin


//pert1 ------------------------------------------------------------------------

//get
if (icellcount<=1) then
   begin

   ipert1   :=1.0;

   end
else begin

   ipert1   :=cindex / frcmin32( icellcount ,1 );//never quite reaches 1.0 -> important for rotation values with low cell count animations, e.g. for cf_wait - 15jun2026

   end;

//range
if      (ipert1<0) then ipert1:=0
else if (ipert1>1) then ipert1:=1;


//pert2 ------------------------------------------------------------------------

//get
ipert2      :=cindex/icellcount2;

//quick and simple range enforcement
if (ipert2>2) then ipert2:=ipert2-2;
if (ipert2>1) then ipert2:=2-ipert2;

//range
if      (ipert2<0) then ipert2:=0
else if (ipert2>1) then ipert2:=1;


//pert4 ------------------------------------------------------------------------

//get
ipert4      :=cindex/icellcount4;

//quick and simple range enforcement
if (ipert4>2) then ipert4:=ipert4-2;
if (ipert4>2) then ipert4:=ipert4-2;
if (ipert4>1) then ipert4:=2-ipert4;

//range
if      (ipert4<0) then ipert4:=0
else if (ipert4>1) then ipert4:=1;


//pert8 ------------------------------------------------------------------------

//get
ipert8      :=cindex/icellcount8;

//quick and simple range enforcement
if (ipert8>2) then ipert8:=ipert8-2;
if (ipert8>2) then ipert8:=ipert8-2;
if (ipert8>2) then ipert8:=ipert8-2;
if (ipert8>2) then ipert8:=ipert8-2;
if (ipert8>1) then ipert8:=2-ipert8;

//range
if      (ipert8<0) then ipert8:=0
else if (ipert8>1) then ipert8:=1;


end;


function tcursorbase.pert1R(const xreverse:boolean):extended;
begin

if xreverse then result:=1 - ipert1
else             result:=ipert1;

end;

function tcursorbase.pert2R(const xreverse:boolean):extended;
begin

if xreverse then result:=1 - ipert2
else             result:=ipert2;

end;

function tcursorbase.pert4R(const xreverse:boolean):extended;
begin

if xreverse then result:=1 - ipert4
else             result:=ipert4;

end;

function tcursorbase.pert8R(const xreverse:boolean):extended;
begin

if xreverse then result:=1 - ipert8
else             result:=ipert8;

end;

procedure tcursorbase.on__cellfirst(const dcell32:tcommonimage;const cindex,ccount:longint32);
begin

//nil

end;

procedure tcursorbase.on__position(var v:tcursorpositionlist;var xmirror:boolean);
begin

//nil

end;

procedure tcursorbase.on__celldraw(const dcell32:tcommonimage;const cindex,ccount:longint32;var xmirror:boolean);
begin

//nil

end;

procedure tcursorbase.on__mirror(const dcell32:tcommonimage;const xhotX:boolean);//25jun2026
begin

mis__mirror82432( dcell32 );

//1st cell only
if xhotX then
   begin

   ihotX    :=pred(iwidth) - ihotX;

   end;

end;

function tcursorbase.canart:boolean;
begin

result      :=iart<>nil;

end;

function tcursorbase.canart2:boolean;
begin

result      :=iart2<>nil;

end;

function tcursorbase.canart3:boolean;
begin

result      :=iart3<>nil;

end;

function tcursorbase.art:tartbase;
begin

if (iart=nil) then
   begin

   iart     :=tartbase.create;

   end;

result      :=iart;

end;

function tcursorbase.art2:tartbase;
begin

if (iart2=nil) then
   begin

   iart2    :=tartbase.create;

   end;

result      :=iart2;

end;

function tcursorbase.art3:tartbase;
begin

if (iart3=nil) then
   begin

   iart3    :=tartbase.create;

   end;

result      :=iart3;

end;

procedure tcursorbase.clearArts;
begin

if (iart <>nil) then freeobj(@iart);
if (iart2<>nil) then freeobj(@iart2);
if (iart3<>nil) then freeobj(@iart3);

end;

function tcursorbase.xfindWantSize(const xwantsize:longint32):tcursorbase;
var
   p                  :longint32;

begin

//defaults
result                :=self;

//check
if (xwantsize<=0) then
   begin

   exit;

   end;

//search altlist for a match
for p:=0 to high(altlist) do
begin

if (altlist[p]<>nil) then
   begin

   if (altlist[p].width=xwantsize) then
      begin

      result          :=altlist[p];

      break;

      end;

   end

else break;//stop

end;//p

end;

function tcursorbase.toanimation(const xwantSize:longint32;const ximage:tcommonimage):boolean;//13jun2026
var
   cindex             :longint32;
   dcell              :tcommonimage;
   d                  :tcursorbase;

begin

//default
result                :=false;
dcell                 :=nil;

//want size
d                     :=xfindWantSize( xwantSize );

if (d<>self) then
   begin
                                     //0=no further searching -> prevent cyclic loop
   result             :=d.toanimation( 0, ximage );
   exit;

   end;

//check
if (ximage=nil) then exit;
if iiobusy      then exit;

try

//init
if not missize( ximage ,iwidth * icellcount ,iheight ) then
   begin

   exit;

   end;

misai( ximage ).itemindex       :=0;
misai( ximage ).delay           :=idelay;
misai( ximage ).count           :=icellcount;
misai( ximage ).cellwidth       :=iwidth;
misai( ximage ).cellheight      :=iheight;

dcell                           :=miscom32( iwidth ,iheight );

//cells
for cindex:=0 to pred(icellcount) do
begin

on__cell( dcell ,cindex ,icellcount );

mis__copyfast( maxarea ,misarea(dcell) ,(cindex * iwidth) ,0 ,iwidth ,iheight ,dcell ,ximage );

end;//cindex

//successful
result                          :=true;

except;end;

//free
freeobj(@dcell);

end;

function tcursorbase.toanimationinfo(const xwantSize:longint32;var x:tanimationinfo):boolean;
var
   d                  :tcursorbase;

begin

d                     :=xfindWantSize( xwantSize );

if (d<>self) then
   begin

   result             :=d.toanimationinfo( 0, x );

   end

else begin

   result                :=true;
   x.delay               :=idelay;
   x.cellcount           :=icellcount;
   x.cellwidth           :=iwidth;
   x.cellheight          :=iheight;
   x.cursorinfo          :=info;

   end;

end;

function tcursorbase.toanimationcell(const xwantSize,xcellindex:longint32;const ximage:tcommonimage):boolean;
var
   cindex             :longint32;
   d                  :tcursorbase;

begin

//default
result                :=false;

//want size
d                     :=xfindWantSize( xwantSize );

if (d<>self) then
   begin
                                         //0=no further searching -> prevent cyclic loop
   result             :=d.toanimationcell( 0, xcellindex ,ximage );
   exit;

   end;

//check
if (ximage=nil) then exit;
if iiobusy      then exit;

//init
if not missize( ximage ,iwidth ,iheight ) then
   begin

   exit;

   end;

misai( ximage ).itemindex       :=0;
misai( ximage ).delay           :=idelay;
misai( ximage ).count           :=icellcount;
misai( ximage ).cellwidth       :=iwidth;
misai( ximage ).cellheight      :=iheight;

//cell
on__cell( ximage ,frcrange32( xcellindex ,0 ,frcmin32(pred(icellcount),0) ) ,icellcount );

//successful
result                          :=true;

end;

function tcursorbase.tofile(const xfilename:string):boolean;//11jun2026
var
   xdata              :tstr8;
   e                  :string;

begin

//defaults
xdata                 :=nil;

try

//init
xdata                 :=rescache__newStr8;

//get
result                :=todata( xdata ) and io__tofile( xfilename ,@xdata ,e );

except;end;

//free
rescache__delStr8( @xdata );

end;

function tcursorbase.todata(const xdata:tstr8):boolean;//11jun2026, 23may2026
label//note: known anirec.flags: 1=win7/ours, 3=ms old/our
   skipend;

var
   dicon              :tstr8;
   diconlist          :tstr8;
   anirec             :tanirec;
   cindex             :longint32;
   dpng               :boolean;

begin


//defaults ---------------------------------------------------------------------

result                :=false;
dicon                 :=nil;
diconlist             :=nil;
dpng                  :=cursor_usepng;//19jun2026

//quick check
if (xdata=nil) then exit;


//init
iiobusy               :=true;


//static cursor ----------------------------------------------------------------

if (not ianimate) or (icellcount<=1) then
   begin

   result             :=xicoMultiResolution__todata32( 0 ,1 ,xdata ,dPNG ,true );

   goto skipend;

   end;


//animated cursor --------------------------------------------------------------

//init
dicon                 :=rescache__newStr8;
dicon.floatsize       :=100000;//100K
diconlist             :=rescache__newStr8;
diconlist.floatsize   :=1000000;//1mb

//cells
for cindex:=0 to pred(icellcount) do
begin

if not xicoMultiResolution__todata32( cindex ,icellcount ,dicon ,dPNG ,true ) then goto skipend;

//add icon
diconlist.addstr('icon');
diconlist.addint4(dicon.len32);
diconlist.addfast32(dicon);

end;//p


//RIFF -------------------------------------------------------------------------

//init
low__cls(@anirec,sizeof(anirec));

anirec.cbsizeof       :=sizeof(anirec);
anirec.cframes        :=icellcount;//number of unique images
anirec.csteps         :=icellcount;//number of cells in anmiation
anirec.cbitcount      :=32;
anirec.jifrate        :=frcmin32( round32(idelay/16.666) ,1 );
anirec.flags          :=1;//win7/some of ours

//get
with xdata do
begin

clear;

sadd('RIFF');
addint4(0);//set last

//._anih - 'ACONanih'+from32bit(sizeof(anirec))+fromstruc(@anirec,sizeof(anirec));
sadd('ACONanih');
addint4(sizeof(anirec));
addrec(@anirec,sizeof(anirec));

//._list
sadd('LIST');
addint4(4 + diconlist.len32 );
sadd('fram');
add( diconlist );

//.reduce mem
diconlist.clear;

//.set overal size
int4[4]     :=frcmin32(len32-4,0);

end;

//successful
result                :=true;
skipend:

//clear on error
if (not result) then
   begin

   xdata.clear;

   end;

//free
rescache__delStr8( @dicon     );
rescache__delStr8( @diconlist );

//not busy
iiobusy               :=false;

end;

function tcursorbase.xicoMultiResolution__todata32(const xcellindex,xcellcount:longint32;const xdata:tstr8;const dPNG,xascendingSizeOrder:boolean):boolean;//20jun2026
var
   dcell              :tcommonimage;
   clist              :array[0..19] of tcursorbase;
   dlist              :array[0..19] of tstr8;
   dcount             :longint32;
   dw                 :longint32;
   dh                 :longint32;
   xstartofdata       :longint32;
   dpos               :longint32;
   p                  :longint32;

   procedure xadd(const x:tcursorbase);
   begin

   if (x<>nil) and (dcount<=high(dlist)) then
      begin

      clist[ dcount ] :=x;

      inc( dcount );

      end;

   end;

   procedure xsort(const xascendingSizeOrder:boolean);
   var
      tlist           :array[0..high(clist)] of tcursorbase;
      p               :longint32;

      function xfindnext:tcursorbase;
      var
         p            :longint32;
         v            :longint32;
         i            :longint32;

      begin

      //defaults
      result          :=nil;
      i               :=0;

      //get

      //.find small-to-large order
      if xascendingSizeOrder then
         begin

         v            :=max32;

         for p:=0 to pred(dcount) do
         begin

         if (tlist[p]<>nil) and (tlist[p].width<v) then
            begin

            i            :=p;
            v            :=tlist[p].width;

            end;

         end;//p

         end

      //.find large-to-small order
      else begin

         v            :=0;

         for p:=0 to pred(dcount) do
         begin

         if (tlist[p]<>nil) and (tlist[p].width>v) then
            begin

            i            :=p;
            v            :=tlist[p].width;

            end;

         end;//p

         end;

      //set
      result          :=tlist[ i ];
      tlist[ i ]      :=nil;

      end;

   begin

   //check
   if (dcount<=1) then exit;

   //init
   for p:=0 to pred(dcount) do
   begin

   tlist[p]           :=clist[p];

   end;//p

   //get
   for p:=0 to pred(dcount) do
   begin

   clist[p]           :=xfindnext;

   end;//p

   end;

begin

//defaults
result                :=false;
dcell                 :=nil;
dcount                :=0;

//quick check
if   (xdata=nil) then exit
else                  xdata.clear;

//self
xadd( self );

//alt list
for p:=0 to high(altlist) do
begin

if (altlist[p]<>nil) then xadd( altlist[p] )
else                      break;

end;//p

//sort order -> .cur=large-to-small, .ani=small-to-large
xsort( xascendingSizeOrder );

try

//init
dcell                 :=miscom32(1,1);
low__cls( @dlist ,sizeof(dlist) );

//header
xdata.addwrd2( 0      );
xdata.addwrd2( 2      );//0=stockicon, 1=icon (default for icons), 2=cursor
xdata.addwrd2( dcount );//number of images

xstartofdata          :=6 + (dcount*16);
dpos                  :=xstartofdata;

//get
for p:=0 to pred(dcount) do
begin

dw                    :=clist[p].width;
dh                    :=clist[p].height;

if (dw>=256) then dw  :=0;//0=256px
if (dh>=256) then dh  :=0;//0=256px

//.width
xdata.addbyt1( dw );

//.height
xdata.addbyt1( dh );

//.colors in palette (0 if no palette used)
xdata.addbyt1( 0 );

//.null
xdata.addbyt1( 0 );


//.image -> cursor data stream

missize( dcell ,clist[p].width ,clist[p].height );

clist[p].on__cell( dcell ,xcellindex ,xcellcount );

dlist[p]              :=rescache__newStr8;

xico__todata32( dcell ,dlist[p] ,false ,dPNG );//exclude first 22bytes


//.hotspotX,Y - 20jun2026
xdata.addwrd2( clist[p].hotX );//hotX - cursor
xdata.addwrd2( clist[p].hotY );//hotY - cursor

//.size of image data
xdata.addint4( dlist[p].len32 );

//.offset from beginning of this file
xdata.addint4( dpos );

//.round up to nearest 4 bytes
str__nearest4( @dlist[p] );//??????????????????????????????

//inc
inc(dpos, dlist[p].len32 );

end;//p

//append image data
for p:=0 to pred(dcount) do
begin

xdata.addfast32( dlist[p] );

end;//p

//successful
result                :=true;

except;end;

//free
freeobj(@dcell);

for p:=0 to pred(dcount) do
begin

if (dlist[p]<>nil) then
   begin

   rescache__delStr8( @dlist[p] );

   end;

end;//p

end;

function tcursorbase.xico__todata32(const dcell32:tcommonimage;const xdata:tstr8;const dfullHeader,dPNG:boolean):boolean;
label
   skipdone ,skipend;

const
   dcursor            =true;

var
   dimg               :tstr8;
   dmask              :tstr8;
   etmp               :string;

   procedure w1(const x:byte);
   begin

   xdata.addbyt1(x);

   end;

   procedure w2(const x:word);
   begin

   xdata.addwrd2( x );

   end;

   procedure w4(const x:longint);
   begin

   xdata.addint4( x );

   end;

begin

//defaults
result                :=false;
dimg                  :=nil;
dmask                 :=nil;

//quick check
if   (xdata=nil) then exit
else                  xdata.clear;

if (dcell32=nil) then exit;

//init
dimg                  :=rescache__newStr8;
dmask                 :=rescache__newStr8;

//get

//start header -> include first 22 bytes of header -> multi-resolution icon/cursor excludes this header portion + finish header section(s)
if dfullHeader then
   begin

   //.type header (6)
   w2(0);

   if dcursor then w2(2)//0=stockicon, 1=icon (default for icons), 2=cursor
   else            w2(1);

   w2(1);//count

   //.icon header (16)
   if ( dcell32.width <=255 ) then w1(dcell32.width)  else w1(0);
   if ( dcell32.height<=255 ) then w1(dcell32.height) else w1(0);

   w2(0);//colors

   //.cursor
   if dcursor then
      begin

      w2( frcrange32( dcell32.ai.hotspotX ,0 ,max16 ) );//reserved1
      w2( frcrange32( dcell32.ai.hotspotY ,0 ,max16 ) );//reserved2

      end

   //.icon
   else begin

      w2(1 );//color planes
      w2(32);//bits

      end;

   end;


//png - store png --------------------------------------------------------------

if dpng or (dcell32.width>=257) or (dcell32.height>=257) then
   begin

   //get
   result:=png__todata( dcell32 ,@dimg ,etmp );

   if not result then goto skipend;

   //finish header
   if dfullHeader then
      begin

      w4(dimg.len32);
      w4(22);//6 + 16 = 22

      end;

   //store png
   xdata.addfast32( dimg );

   goto skipdone;

   end;


//ico - store icon + mask ------------------------------------------------------

//image data (no header)
if not xbmp__toicondata32( dcell32 ,dimg ) then goto skipend;

//1bit mask (no header, no palette)
if not xbmp__toicondata1( dcell32 ,dmask ) then goto skipend;

//finish header
if dfullHeader then
   begin

   w4(40 + dimg.len32 + dmask.len32);
   w4(22);//6 + 16 = 22

   end;

//.image header (40)
w4(40);//biSize
w4( dcell32.width );//biWidth
w4( dcell32.height * 2);//biHeight (x2 = image + trailing 1bit mask)
w2(1 );//biPlanes
w2(32);//biBitCount
w4(0);//compression=0
w4( dimg.len32 + dmask.len32 );
w4(0);
w4(0);
w4(0);//# of colors used
w4(0);//# of important colors

//.image data
xdata.addfast32( dimg  );
xdata.addfast32( dmask );

//successful
skipdone:
result                :=true;
skipend:

//clear on error
if not result then
   begin

   xdata.clear;

   end;

//free
rescache__delStr8( @dimg  );
rescache__delStr8( @dmask );

end;

function tcursorbase.xbmp__toicondata32(const dcell32:tcommonimage;const xdata:tstr8):boolean;//24may2026
label
   skipend;

var
   dpos               :longint32;
   dbytes             :longint32;
   drowsize           :longint32;
   sx                 :longint32;
   sy                 :longint32;
   sr32               :pcolorrow32;
   dr32               :pcolorrow32;
   c0                 :tcolor32;

begin

//defaults
result                :=false;

//quick check
if (xdata=nil) then exit;

//init
drowsize              :=mis__rowsize4( dcell32.width ,32 );//nearest 4 bytes
dbytes                :=( dcell32.height * drowsize );
dpos                  :=0;
c0.r                  :=0;
c0.g                  :=0;
c0.b                  :=0;
c0.a                  :=0;

//size
if not xdata.setlen( dbytes ) then goto skipend;

//get - 128% faster - 04jun2026
for sy:=0 to pred(dcell32.height) do
begin

if not misscan32( dcell32 ,pred(dcell32.height) - sy ,sr32 ) then goto skipend;
dr32                  :=ptr__shift( xdata.core ,sy * drowsize );

//sx
for sx:=0 to pred(dcell32.width) do
begin

//.transparent pixel as black
if (sr32[sx].a<=0) then
   begin

   dr32[ sx ]         :=c0;

   end

//.color pixel
else begin

   dr32[ sx ]         :=sr32[sx];

   end;

end;//sx

end;//sy

//successful
result                :=true;
skipend:

//clear on error
if not result then
   begin

   xdata.clear;

   end;

end;

function tcursorbase.xbmp__toicondata1(const dcell32:tcommonimage;const xdata:tstr8):boolean;//24may2026
label
   skipend;

var
   dpos               :longint32;
   dbytes             :longint32;
   drowsize           :longint32;
   sx                 :longint32;
   sy                 :longint32;
   ix                 :byte;
   ival               :byte;
   vbit               :byte;
   sr32               :pcolorrow32;

begin

//defaults
result                :=false;

//quick check
if (xdata=nil)   then exit;
if (dcell32=nil) then exit;

//init
drowsize              :=mis__rowsize4( dcell32.width ,1 );//nearest 4 bytes
dpos                  :=0;

//bytes -> relies on palette count
dbytes                :=( dcell32.height * drowsize );

//size
if not xdata.setlen(dbytes) then goto skipend;

//get
for sy:=0 to pred(dcell32.height) do
begin

if not misscan32( dcell32 ,pred(dcell32.height) - sy ,sr32 ) then goto skipend;
dpos                  :=sy * drowsize;
ix                    :=0;
ival                  :=0;

for sx:=0 to pred(dcell32.width) do
begin

//read mask value
if   (sr32[sx].a<=0) then vbit:=1
else                      vbit:=0;

//inc
inc(ix);

//add to pixel bucket
case ix of
1           :ival:=    vbit * 128  ;
2           :inc(ival ,vbit * 64  );
3           :inc(ival ,vbit * 32  );
4           :inc(ival ,vbit * 16  );
5           :inc(ival ,vbit *  8  );
6           :inc(ival ,vbit *  4  );
7           :inc(ival ,vbit *  2  );
8           :inc(ival ,vbit       );
end;//case

//save pixels
if (ix>=8) then
   begin

   //add byte
   xdata.pbytes[dpos]:=ival;
   inc(dpos,1);

   //reset
   ival:=0;
   ix  :=0;

   end;

end;//sx

//save last un-saved pixel
if (ix>=1) then
   begin

   //add byte
   xdata.pbytes[dpos]:=ival;
   inc(dpos,1);

   end;

end;//sy

//successful
result                :=true;
skipend:

//clear on error
if not result then
   begin

   xdata.clear;

   end;

end;


//## tcursordefault ############################################################
const

//------------------------------------------------------------------------------
//128px solid cursors ----------------------------------------------------------
//------------------------------------------------------------------------------

modern_arrow128
:array[0..2784] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,10,168,73,68,65,84,120,1,236,157,119,108,20,103,26,198,95,140,13,152,106,12,6,211,109,186,141,41,6,92,48,6,27,131,233,144,156,46,9,74,20,201,186,83,116,186,228,74,20,69,73,148,220,37,36,18,9,209,93,2,18,40,135,46,137,72,174,252,71,23,88,244,14,130,208,65,128,41,162,9,48,85,64,232,96,74,158,119,194,152,29,111,247,142,119,103,237,199,210,104,119,103,102,103,191,239,247,62,51,243,61,239,247,125,99,17,254,145,0,9,144,128,65,160,94,189,122,113,49,49,49,13,117,193,251,24,98,169,253,4,44,65,142,143,143,111,155,148,148,148,211,166,77,155,188,166,77,155,118,165,8,234,158,0,146,187,119,239,94,50,120,240,224,47,51,50,50,222,77,72,72,232,171,87,133,218,143,161,238,214,208,114,5,104,208,160,65,66,215,174,93,95,29,62,124,120,246,184,113,227,254,152,153,153,249,105,235,214,173,7,235,45,161,238,34,170,221,53,183,8,64,47,249,56,235,227,251,244,233,35,99,198,140,145,241,227,199,191,152,149,149,245,207,
228,228,228,130,250,245,235,55,230,45,161,246,137,193,34,0,173,30,206,118,105,222,188,185,244,238,221,91,70,141,26,37,19,39,78,28,58,100,200,144,127,117,234,212,105,98,108,108,108,51,138,160,118,137,192,77,0,90,61,4,89,154,52,105,34,104,15,72,97,97,161,76,154,52,169,219,176,97,195,126,76,77,77,157,210,176,97,195,36,138,160,246,136,192,34,0,4,182,190,107,213,26,53,106,36,41,41,41,146,159,159,175,34,136,31,49,98,196,191,123,244,232,241,187,198,141,27,119,162,8,92,73,69,239,123,139,0,60,85,3,13,67,233,216,177,163,228,230,230,234,237,64,111,11,211,211,210,210,254,212,172,89,179,30,20,129,39,98,209,181,206,175,0,180,58,184,247,11,26,130,2,123,40,19,38,76,208,6,226,123,125,251,246,125,191,101,203,150,253,33,2,218,196,232,138,185,165,180,1,9,64,191,161,141,67,88,66,233,223,191,191,140,29,59,86,96,19,127,15,155,248,153,38,142,104,19,45,76,163,234,131,69,0,79,159,62,125,236,171,244,56,219,5,103,189,32,73,36,163,71,143,214,171,193,164,236,236,236,175,219,183,111,63,138,14,193,23,57,231,
110,179,8,0,1,182,52,2,189,21,27,247,127,195,38,142,28,57,82,219,5,217,166,77,140,139,139,75,96,187,192,27,53,103,174,183,8,64,139,168,103,121,32,127,112,2,210,173,91,55,211,38,118,70,246,240,191,176,137,175,208,38,6,66,207,57,251,184,9,64,139,22,168,8,212,38,118,238,220,89,134,14,29,170,87,130,88,216,196,57,61,123,246,124,131,54,209,57,1,246,87,18,143,2,240,247,37,215,237,106,19,59,116,232,32,57,57,57,154,43,144,226,226,226,105,72,37,191,131,108,98,47,222,14,92,73,57,243,125,200,2,208,106,153,54,113,208,160,65,134,77,132,75,120,27,110,225,239,137,137,137,3,33,2,218,68,103,198,222,40,149,45,2,208,35,169,77,108,213,170,85,165,77,68,71,210,107,16,196,23,109,219,182,205,167,77,116,174,2,108,19,128,86,81,219,14,45,90,180,144,244,244,116,189,21,232,213,160,88,109,34,110,17,99,104,19,157,41,2,91,5,96,86,17,163,137,4,141,65,41,42,42,210,118,65,38,26,137,223,117,233,210,229,55,104,47,36,178,93,96,82,114,198,171,69,0,118,6,7,195,203,4,131,75,4,246,80,69,208,166,160,160,224,63,176,141,
175,195,57,36,219,249,59,206,192,24,189,165,176,8,64,171,161,151,113,187,254,144,19,48,108,98,94,94,158,209,145,132,43,194,204,94,189,122,253,1,93,205,41,20,129,93,148,67,59,142,155,0,244,112,118,138,0,217,65,65,170,88,208,22,48,28,2,82,200,83,117,188,33,218,10,233,20,65,104,193,179,227,219,30,5,128,62,1,59,142,93,121,12,12,39,19,140,52,150,129,3,7,234,48,51,237,76,122,107,192,128,1,159,192,53,100,209,33,84,98,138,200,27,143,2,168,137,146,168,77,68,94,64,208,141,108,142,55,124,89,71,31,195,38,14,227,120,195,154,32,30,216,49,195,38,0,45,142,222,90,92,109,34,210,199,133,24,104,50,11,3,78,198,209,38,6,22,48,187,247,10,171,0,204,194,155,227,13,209,119,160,14,33,77,109,98,74,74,202,75,180,137,38,161,240,189,186,9,192,238,251,191,183,170,168,77,76,77,77,21,12,54,85,17,180,132,77,252,94,39,165,96,125,123,54,14,189,81,179,127,189,155,0,236,116,0,254,138,171,29,73,24,110,46,24,79,96,218,196,175,48,28,253,77,78,75,243,71,206,190,237,110,2,208,67,135,83,4,218,145,212,174,93,59,193,4,20,
67,4,72,33,127,228,98,19,217,145,100,95,172,61,30,201,34,0,4,62,160,17,65,30,143,20,194,74,211,38,98,140,161,97,19,57,45,45,4,152,65,126,213,34,0,253,110,56,207,126,215,178,234,239,186,218,68,116,36,253,150,211,210,92,9,213,204,123,55,1,132,171,17,232,173,58,85,167,165,193,38,206,166,77,244,70,43,244,245,110,2,8,253,144,161,31,193,180,137,133,133,198,180,180,158,152,153,52,151,54,49,116,174,158,142,224,72,1,104,65,171,76,75,107,14,49,124,175,211,210,104,19,61,133,177,250,235,28,43,0,173,82,85,155,136,97,232,255,192,180,180,63,115,90,90,245,3,94,245,155,110,2,136,84,35,176,106,193,204,207,230,120,67,181,137,207,166,165,125,192,105,105,38,157,208,95,221,4,160,135,116,154,8,212,38,98,10,154,168,77,132,69,228,180,180,208,227,94,121,4,139,0,16,248,136,228,1,42,75,227,227,141,138,178,234,180,52,181,137,72,34,21,177,35,201,7,56,63,155,44,2,240,179,175,35,54,87,153,150,150,139,52,242,55,180,137,213,15,77,212,9,64,171,106,78,75,67,7,146,166,143,83,249,244,146,58,38,0,173,110,21,155,24,
15,155,104,60,189,132,54,49,56,49,88,174,0,254,166,135,7,119,232,154,223,91,109,162,62,189,196,156,150,166,79,47,193,156,132,191,210,38,6,206,222,34,0,39,55,2,189,85,201,236,77,52,159,94,130,145,199,239,233,200,99,157,160,234,237,59,92,255,156,128,69,0,186,218,105,22,240,121,81,189,191,211,241,134,230,211,75,116,126,98,234,175,211,212,19,189,127,131,91,76,2,22,1,32,248,198,231,104,20,129,150,89,71,25,105,3,17,237,131,36,179,130,124,245,77,192,34,0,180,1,158,248,222,221,217,91,111,220,184,33,231,207,159,151,242,242,242,53,119,238,220,57,235,236,210,58,163,116,22,1,56,163,72,207,75,161,93,211,79,158,60,145,199,143,31,203,163,71,143,164,162,162,66,30,62,124,40,15,30,60,144,251,247,239,203,221,187,119,5,129,150,91,183,110,137,6,255,228,201,147,114,226,196,9,57,123,246,236,50,236,247,243,243,35,241,157,55,2,53,46,0,13,226,205,155,55,53,40,114,248,240,97,57,112,224,128,236,219,183,79,246,238,221,43,187,119,239,150,29,59,118,200,246,237,219,101,219,182,109,178,117,235,86,217,178,101,
139,108,218,180,73,54,110,220,40,27,54,108,144,117,235,214,201,218,181,107,101,245,234,213,178,106,213,42,89,185,114,165,172,88,177,66,150,47,95,110,44,165,165,165,178,108,217,50,89,186,116,169,241,25,199,45,189,116,233,210,22,84,216,231,3,175,188,1,169,107,235,107,84,0,26,252,235,215,175,203,193,131,7,141,192,205,159,63,95,204,101,222,188,121,162,139,235,103,125,111,174,115,221,254,108,221,35,108,191,135,229,38,62,95,198,114,14,203,41,44,101,88,246,98,217,186,102,205,154,25,101,101,101,223,220,190,125,251,76,180,223,206,194,37,196,26,21,128,158,249,122,214,235,153,139,192,149,34,72,111,99,121,3,75,9,150,215,176,188,132,229,5,44,227,177,20,99,41,194,126,5,120,205,195,107,238,130,5,11,178,176,12,88,184,112,97,250,162,69,139,50,22,47,94,220,111,201,146,37,153,56,219,179,113,214,15,193,217,159,143,43,193,8,92,21,70,35,248,147,247,236,217,243,177,222,255,113,203,184,19,46,128,209,254,59,177,174,21,48,93,128,235,186,234,190,215,251,242,145,35,71,140,75,56,46,223,179,33,132,89,56,51,
79,154,199,227,25,106,146,136,236,171,69,0,90,20,59,44,160,54,204,142,31,63,110,220,195,215,175,95,255,63,8,97,142,6,159,65,143,108,176,61,253,186,199,91,64,40,34,184,119,239,158,209,26,215,134,28,26,112,75,15,29,58,52,19,183,130,163,12,190,39,252,145,95,231,81,0,213,45,150,90,179,211,167,79,203,230,205,155,5,247,228,13,104,241,79,71,35,240,32,131,95,93,162,53,255,61,203,0,16,252,187,152,116,60,227,239,21,125,200,147,62,212,33,152,63,245,231,103,206,156,49,108,28,108,218,110,216,177,169,87,174,92,249,9,193,127,24,204,113,184,111,120,9,216,114,5,208,4,205,185,115,231,12,63,143,6,223,9,109,141,195,139,111,70,18,231,65,120,171,195,95,11,150,64,200,2,208,12,221,133,11,23,100,231,206,157,154,172,185,186,107,215,174,15,46,94,188,184,145,193,15,54,20,145,217,63,36,1,104,154,246,242,229,203,130,51,94,131,255,20,89,189,119,159,249,240,187,145,169,14,127,53,88,2,30,5,16,136,11,192,189,93,174,94,189,42,251,247,239,215,6,159,94,254,255,162,57,120,92,17,110,5,91,8,238,31,57,2,22,1,32,240,
150,70,161,183,98,105,240,175,93,187,102,228,245,113,230,107,14,255,67,180,254,231,163,45,112,131,45,126,111,212,156,185,222,34,0,45,98,32,103,191,246,188,193,223,27,157,52,176,124,211,208,3,247,127,244,208,93,97,240,157,25,100,95,165,114,19,128,175,157,117,155,230,247,53,197,171,61,116,232,173,155,129,140,223,15,72,254,148,51,248,254,200,57,115,123,80,2,64,58,87,142,29,59,38,72,239,106,240,231,30,61,122,244,91,164,125,79,51,248,206,12,110,32,165,10,88,0,58,248,66,7,91,60,75,241,206,211,206,29,116,248,28,103,240,3,193,236,220,125,44,141,62,60,195,175,55,178,128,110,153,64,77,241,158,58,117,202,8,62,186,94,87,163,229,255,57,82,188,7,16,124,14,186,112,110,108,3,42,153,69,0,58,152,18,143,111,157,128,165,137,78,193,210,73,153,58,28,75,71,243,104,126,31,41,222,29,154,229,131,253,219,137,224,87,4,244,11,220,201,209,4,44,143,6,199,147,57,186,232,63,125,194,191,123,249,91,191,126,253,234,233,63,132,210,39,126,235,88,59,220,243,203,52,209,131,172,223,58,102,249,28,29,211,234,23,14,22,
48,14,195,170,59,226,217,125,147,49,233,114,206,148,41,83,202,75,74,74,42,240,232,182,229,186,78,159,233,91,253,163,243,155,81,67,0,66,136,209,41,215,232,29,204,192,132,139,28,180,13,210,244,115,212,84,128,5,37,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,18,32,1,7,16,248,5,0,0,255,255,3,0,183,122,113,223,69,156,65,99,0,0,0,0,73,69,78,68,174,66,96,130);

modern_alt128
:array[0..3760] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,14,120,73,68,65,84,120,1,236,157,93,108,84,117,26,198,79,75,63,105,105,75,161,223,211,118,218,242,93,196,82,160,13,109,105,203,148,150,47,129,69,48,187,235,157,23,100,197,236,205,134,189,97,67,54,225,98,93,35,89,195,146,72,214,155,141,55,198,93,215,11,93,141,18,4,220,32,42,42,70,220,44,232,202,135,128,124,169,96,148,15,65,132,206,254,158,19,198,197,58,45,29,235,208,115,78,223,147,156,204,244,204,57,51,255,121,222,231,125,223,231,125,255,255,51,117,28,219,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,47,33,144,114,115,243,210,152,188,50,150,84,175,12,36,153,227,200,202,202,202,205,203,203,27,147,154,154,154,193,158,10,31,146,249,113,190,122,239,192,19,
160,176,176,48,107,220,184,113,53,227,199,143,111,41,42,42,170,31,195,230,43,11,37,121,176,129,39,64,70,70,70,104,218,180,105,203,234,234,234,214,78,159,62,253,254,202,202,202,201,96,106,33,224,38,177,2,77,128,242,242,242,20,34,126,101,69,69,197,154,214,214,214,197,51,103,206,92,14,1,154,72,7,133,146,5,73,118,46,95,188,125,160,9,128,5,42,58,217,38,76,152,80,61,107,214,172,116,246,218,209,163,71,47,37,45,84,229,230,230,166,249,194,66,73,30,100,208,9,80,94,80,80,176,112,226,196,137,14,36,112,194,225,112,90,125,125,253,76,30,187,178,179,179,243,146,140,173,47,222,62,176,4,32,236,143,37,228,55,228,231,231,55,243,220,169,170,170,114,72,9,206,164,73,147,138,32,67,7,169,160,118,212,168,81,233,35,61,19,4,150,0,184,95,8,131,247,200,251,75,74,74,156,244,244,116,135,104,224,240,119,74,40,20,154,131,56,156,77,65,48,90,101,161,47,92,53,73,131,12,228,151,199,227,51,240,236,16,97,190,27,99,59,148,127,142,60,157,126,128,83,90,90,154,2,9,138,106,106,106,126,78,121,56,37,141,45,73,216,250,226,
109,3,73,0,144,175,136,68,34,61,181,181,181,121,101,101,101,78,78,78,142,107,12,66,190,51,118,236,88,105,129,84,246,86,210,65,11,209,33,31,114,140,216,138,32,144,4,136,70,163,21,132,247,238,234,234,106,167,184,184,248,123,158,72,232,119,164,9,16,131,169,24,191,11,82,148,144,30,70,108,119,48,112,4,192,184,197,115,231,206,109,194,240,245,18,125,132,249,239,17,64,81,64,90,128,198,80,234,228,201,147,167,19,33,218,51,51,51,11,190,119,210,8,250,35,112,4,192,118,33,114,126,15,6,118,197,95,95,91,42,218,211,11,112,43,2,244,65,53,123,15,145,162,142,230,80,122,223,115,71,194,223,129,34,0,222,63,154,114,175,14,177,215,173,48,79,255,63,174,13,69,2,12,174,40,160,178,112,46,17,161,153,99,153,35,81,10,4,138,0,88,59,52,117,234,212,30,66,123,42,106,223,85,253,113,25,192,65,85,4,74,17,156,159,207,92,65,59,100,169,133,0,163,250,59,63,168,199,3,71,0,20,127,143,154,62,42,253,6,218,84,253,73,31,80,14,102,66,132,102,158,207,229,154,177,104,132,17,85,17,4,134,0,132,252,138,246,246,246,54,30,170,84,250,
73,232,221,110,83,69,160,115,233,12,150,114,221,47,136,10,85,138,2,35,41,21,4,134,0,24,59,68,141,223,131,71,255,160,244,235,143,8,177,138,128,158,64,250,93,108,148,134,29,180,142,115,57,127,196,68,129,64,16,0,37,95,192,92,255,116,106,255,86,60,249,7,165,95,127,4,208,113,186,133,14,243,2,18,132,133,232,134,118,82,72,57,145,33,109,164,68,129,64,16,0,59,134,200,251,221,40,250,239,250,254,3,25,253,214,215,98,81,0,2,164,64,132,86,34,64,27,199,114,140,0,183,162,228,225,231,120,191,122,249,149,212,246,221,242,228,219,137,191,190,95,69,134,86,20,80,69,0,9,138,152,65,92,194,227,36,244,192,136,168,8,130,16,1,66,244,253,35,228,113,133,112,135,133,30,125,109,124,219,191,69,2,22,137,196,214,12,52,67,134,70,162,64,214,72,136,2,65,32,64,37,77,157,110,8,144,176,247,199,152,33,67,211,14,118,231,8,232,11,20,80,25,68,208,1,213,188,30,248,57,2,95,19,128,240,95,52,103,206,156,70,106,248,187,85,206,245,215,249,139,25,122,160,71,245,5,20,5,208,18,89,144,105,14,68,152,175,190,64,208,163,128,175,9,128,
65,67,204,232,117,107,185,151,22,125,12,213,88,177,40,0,9,194,16,106,17,123,149,162,192,64,196,241,251,107,190,253,114,120,127,54,30,90,115,187,190,127,34,6,18,129,168,2,52,63,224,80,85,222,197,251,183,176,96,40,155,227,218,18,121,43,223,156,235,91,2,128,112,8,197,222,205,234,158,12,137,63,41,249,161,110,50,178,222,7,114,57,44,38,41,163,170,232,162,175,48,145,245,2,129,157,41,244,45,1,48,86,53,138,223,93,244,145,104,233,55,16,81,212,23,144,22,160,163,152,129,182,88,169,121,2,180,197,152,160,134,0,95,18,0,207,172,104,105,105,153,75,142,174,99,119,151,121,13,100,212,68,94,83,20,136,205,17,144,6,148,14,238,161,195,88,201,42,163,64,230,0,95,18,0,131,86,226,157,11,8,211,131,238,251,39,66,130,88,20,144,184,164,41,52,157,104,48,135,70,83,32,163,128,239,8,128,247,231,145,247,167,210,179,111,87,247,14,34,36,98,219,65,157,27,211,2,234,44,134,195,97,221,69,212,69,154,169,228,49,112,51,133,190,35,0,22,172,194,243,187,98,125,127,133,235,100,108,234,11,168,34,192,251,181,118,176,21,178,181,
243,89,57,164,130,100,124,220,176,189,167,175,8,128,71,106,188,85,120,255,2,45,250,24,74,227,103,48,136,171,34,208,236,34,105,32,4,9,218,249,252,90,202,194,64,205,17,248,138,0,50,62,247,122,182,99,252,18,149,126,90,215,151,204,77,55,13,169,34,192,248,81,74,195,102,116,192,221,8,66,221,77,20,152,162,192,119,4,32,44,47,32,44,255,232,190,127,34,132,145,22,208,218,65,42,141,20,82,78,9,17,96,5,164,171,131,0,105,65,73,5,190,33,0,94,63,190,161,161,97,38,171,126,102,37,75,252,197,35,71,108,142,128,165,227,217,16,96,129,244,0,109,231,188,160,132,0,223,16,0,227,84,99,248,8,21,128,91,250,169,84,187,83,155,230,8,212,29,100,245,240,104,170,129,37,164,130,241,124,126,32,102,10,125,65,0,188,63,147,80,28,6,248,46,25,34,217,226,175,47,177,20,5,136,60,186,179,56,117,202,148,41,245,220,117,212,66,69,16,136,181,131,190,32,0,249,182,138,206,95,4,53,158,35,241,7,17,250,218,40,169,127,75,11,80,121,184,21,1,105,160,26,77,176,16,82,214,48,14,223,223,89,236,11,2,96,128,106,196,87,151,110,246,188,211,222,
31,99,150,42,2,69,1,117,7,25,199,2,154,66,141,16,64,183,161,199,78,241,229,163,231,9,128,167,149,53,55,55,55,33,188,38,171,239,175,178,108,184,182,88,95,128,21,228,185,51,102,204,232,224,222,3,173,23,184,115,98,36,9,95,220,243,4,192,195,106,16,94,93,132,255,164,244,253,19,193,84,90,64,17,136,177,100,170,47,0,25,103,17,21,244,3,148,190,13,3,158,38,0,222,63,134,125,34,158,23,73,116,189,127,34,134,77,228,92,245,5,84,134,210,139,8,99,252,213,84,8,229,28,243,52,142,3,125,63,175,15,188,154,186,59,130,242,118,151,124,169,28,27,238,77,229,167,180,0,4,200,108,108,108,188,155,210,176,13,45,48,154,72,229,203,40,224,121,2,104,38,142,40,48,108,226,47,30,225,176,183,251,171,99,164,130,50,34,83,39,2,181,20,98,248,242,110,34,207,18,0,163,87,207,155,55,175,149,92,91,113,39,250,254,241,12,221,223,177,88,20,160,34,200,128,0,29,104,0,221,71,144,233,71,45,224,89,2,0,126,53,161,54,114,167,250,254,253,25,59,222,113,69,123,69,1,180,64,10,81,160,156,95,32,189,143,210,176,22,145,232,101,60,227,125,21,
111,46,121,6,204,66,150,99,205,96,226,71,119,233,12,107,233,23,23,53,14,170,47,160,197,40,170,78,136,86,109,236,13,204,20,106,5,113,127,151,120,242,184,87,25,27,6,208,136,22,125,208,118,117,84,126,121,109,147,161,213,23,160,51,168,57,130,124,210,84,228,218,181,107,250,73,50,94,242,15,9,60,71,0,188,95,75,176,213,247,159,47,112,135,171,243,55,24,194,105,181,184,198,71,154,202,98,111,134,176,243,104,14,229,15,230,90,175,156,227,57,2,200,248,243,231,207,239,100,217,87,129,238,246,81,15,222,203,155,180,128,136,138,88,157,194,99,15,41,75,191,80,234,69,92,227,194,232,197,129,134,201,253,17,82,128,167,189,63,134,166,194,189,126,142,134,126,133,82,193,108,117,7,175,94,189,234,189,156,21,27,112,159,71,79,17,128,240,95,58,123,246,236,70,194,106,253,79,221,247,191,113,227,134,67,142,118,174,92,185,226,244,246,246,246,129,225,199,255,41,2,40,74,41,10,80,22,150,135,195,225,78,34,151,42,2,95,244,5,60,69,0,204,16,6,60,77,251,186,226,111,168,98,74,203,182,180,227,145,206,249,243,231,157,35,71,
142,56,31,125,244,145,115,248,240,97,231,244,233,211,206,215,95,127,253,227,45,127,203,149,234,11,168,34,128,192,185,60,46,164,55,48,147,72,144,203,248,61,175,6,61,67,0,192,203,193,248,19,200,169,17,45,250,24,234,122,255,235,215,175,59,151,47,95,118,13,125,240,224,65,231,141,55,222,232,221,185,115,231,165,237,219,183,159,126,238,185,231,156,215,95,127,221,217,191,127,191,115,232,208,33,231,139,47,190,112,137,114,139,77,19,122,42,59,199,238,44,230,182,242,98,4,225,125,68,133,82,200,103,4,24,44,146,128,88,195,52,171,214,251,167,73,252,105,210,37,209,77,222,46,195,203,179,207,158,61,235,124,240,193,7,206,238,221,187,157,87,94,121,229,212,11,47,188,176,109,207,158,61,143,241,248,167,189,123,247,110,228,249,75,47,190,248,226,133,87,95,125,213,121,235,173,183,156,247,222,123,207,249,228,147,79,220,20,145,232,231,234,124,149,170,34,45,105,96,20,43,135,26,136,98,250,159,4,158,159,35,240,76,4,0,195,26,122,234,243,37,254,18,245,254,152,225,191,250,234,43,215,136,50,38,30,126,249,229,151,
95,62,137,215,63,143,161,31,219,181,107,215,250,29,59,118,252,153,215,182,16,17,254,178,109,219,182,135,159,125,246,217,181,239,188,243,206,86,8,114,144,115,157,215,94,123,205,37,195,135,31,126,232,70,133,68,136,160,40,32,45,64,36,211,30,70,24,182,211,195,40,33,50,120,250,110,34,79,132,40,132,147,150,124,253,138,219,189,127,215,221,221,173,123,243,7,133,189,196,92,204,227,21,198,79,156,56,161,60,127,253,232,209,163,39,207,156,57,179,151,231,187,16,125,255,254,248,227,143,15,127,251,237,183,23,72,9,215,33,75,20,99,185,223,155,207,77,231,61,170,217,67,252,210,72,131,214,29,224,181,250,31,67,105,74,67,18,162,218,57,238,254,199,17,93,118,243,210,184,227,19,17,47,94,188,232,166,22,8,117,12,98,109,96,12,255,228,216,197,184,23,120,224,160,87,8,208,177,108,217,178,135,59,58,58,90,248,169,119,119,234,119,32,108,4,180,20,189,66,253,167,159,126,234,156,58,117,202,193,232,223,64,128,163,7,14,28,248,15,130,239,37,128,223,119,233,210,165,163,223,176,65,146,27,122,63,93,215,223,134,112,43,130,
8,250,77,128,42,242,248,66,106,249,197,116,247,234,32,137,59,30,94,119,31,117,187,152,72,160,86,112,60,50,136,144,199,143,31,119,208,26,138,66,91,137,56,155,17,158,135,249,236,254,63,188,191,65,221,129,227,195,78,0,194,101,1,53,244,47,41,255,182,66,2,135,181,255,174,183,197,251,238,42,229,4,176,28,234,220,185,115,46,208,18,113,132,108,108,126,254,31,159,125,246,217,110,188,253,109,108,126,254,243,207,63,151,215,97,211,222,132,128,199,232,217,92,83,140,189,198,119,118,118,182,49,29,125,15,100,88,64,110,215,228,79,84,19,64,154,159,144,78,81,222,87,5,32,50,196,54,141,81,99,67,91,244,62,243,204,51,187,33,228,175,209,35,255,85,244,137,157,227,165,199,97,39,0,158,53,117,209,162,69,27,218,218,218,238,103,250,215,145,199,245,221,228,60,24,213,81,142,199,176,174,225,143,29,59,118,17,99,31,161,156,123,19,53,191,141,80,127,0,160,207,96,188,43,92,31,149,33,134,186,161,69,198,241,217,133,44,252,168,33,159,47,199,224,203,209,40,197,68,9,253,183,145,116,233,21,77,85,51,9,228,146,65,132,80,84,
34,26,57,136,204,235,104,138,191,163,59,126,79,122,58,58,212,177,36,235,250,97,37,0,162,47,133,156,59,157,214,239,95,151,47,95,62,147,159,251,27,37,207,210,38,163,99,76,87,149,19,202,93,85,79,136,191,129,71,245,162,214,247,17,226,119,98,244,61,24,253,16,251,89,114,252,53,133,122,174,75,200,227,7,3,44,97,63,139,183,205,103,31,131,70,89,200,28,192,82,68,222,44,148,126,38,4,200,129,196,105,138,10,18,175,104,15,135,42,67,98,242,237,147,39,79,254,97,223,190,125,255,130,0,23,6,243,57,35,238,28,20,114,26,101,95,253,226,197,139,159,124,228,145,71,122,223,125,247,221,40,94,30,197,176,209,11,23,46,68,201,165,81,192,140,62,253,244,211,209,77,155,54,157,88,187,118,237,246,165,75,151,110,96,69,110,55,161,185,148,208,252,221,15,56,197,203,199,63,53,160,120,122,10,159,155,135,218,47,235,233,233,137,172,92,185,114,211,189,247,222,187,127,253,250,245,199,183,108,217,242,229,19,79,60,17,221,188,121,243,151,15,61,244,208,155,172,17,120,224,230,205,35,63,245,48,130,243,126,24,45,5,27,230,209,67,
239,122,240,193,7,159,127,252,241,199,47,82,174,69,223,127,255,253,40,141,155,232,83,79,61,117,117,227,198,141,167,87,173,90,181,3,129,184,14,178,52,225,117,37,24,33,139,112,171,203,135,13,12,26,86,153,140,125,44,250,165,18,2,63,176,100,201,146,39,87,175,94,253,183,21,43,86,108,101,25,251,42,210,68,57,227,251,191,56,24,182,145,122,252,131,101,68,74,174,220,166,166,166,159,1,224,222,13,27,54,124,243,232,163,143,158,91,183,110,221,169,53,107,214,252,131,180,240,27,60,94,255,208,161,132,115,85,83,15,159,213,227,96,169,21,193,68,178,108,210,66,30,227,156,76,42,152,198,115,119,169,184,199,134,26,103,244,30,57,132,146,118,67,43,75,192,238,66,11,252,22,77,240,71,170,129,251,241,246,25,24,126,12,249,86,255,226,85,155,71,70,28,127,24,84,3,186,97,84,15,230,249,241,33,26,248,40,198,78,101,18,101,60,185,182,152,230,75,62,196,240,205,180,234,173,223,204,235,68,189,117,172,158,125,174,28,239,217,193,217,192,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,
1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,184,227,8,252,15,0,0,255,255,3,0,74,10,145,211,44,5,253,227,0,0,0,0,73,69,78,68,174,66,96,130);

default_arrow128
:array[0..1247] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,4,167,73,68,65,84,120,1,236,156,11,110,163,48,16,64,201,42,231,234,82,169,199,170,218,180,234,177,170,46,219,139,101,153,8,71,142,215,63,2,54,99,250,144,186,177,49,113,199,111,94,6,10,171,116,29,27,4,32,0,129,11,129,195,225,112,2,197,207,34,240,203,89,238,43,18,56,68,118,222,117,5,144,229,34,193,206,147,110,47,207,39,0,18,216,132,118,222,14,9,128,4,59,79,188,89,94,76,0,36,48,148,118,252,154,18,0,9,118,156,124,89,90,142,0,72,176,99,9,114,5,64,130,157,74,16,21,224,225,225,193,93,54,127,34,186,68,26,239,71,5,248,250,250,234,144,160,241,12,39,194,143,10,32,239,125,121,121,241,77,65,37,240,81,105,112,95,82,128,190,239,187,207,207,79,223,210,144,192,71,165,177,125,73,1,100,61,72,208,88,86,103,132,155,37,0,18,204,32,218,216,161,217,2,32,65,99,153,205,12,119,150,0,72,144,73,181,161,195,102,11,128,4,13,101,55,35,212,187,4,64,130,12,178,141,28,114,183,0,72,208,72,134,19,97,46,18,0,9,18,116,27,
24,94,44,0,18,52,144,229,72,136,171,8,128,4,17,194,202,135,86,19,0,9,148,103,58,16,222,170,2,32,65,128,178,226,221,171,11,128,4,138,179,237,9,173,136,0,72,224,33,173,116,87,49,1,144,64,105,198,157,176,138,10,128,4,14,109,133,221,226,2,32,129,194,172,91,33,85,17,0,9,44,226,202,154,213,4,64,2,101,153,159,194,169,42,0,18,232,147,160,186,0,72,160,75,130,77,4,64,2,61,18,108,38,0,18,232,144,96,83,1,144,96,123,9,54,23,0,9,182,149,64,133,0,72,176,157,4,106,4,64,130,109,36,80,37,0,18,212,151,64,157,0,72,80,87,2,149,2,32,65,61,9,212,10,128,4,117,36,80,45,0,18,148,151,64,189,0,72,80,86,130,38,4,64,130,114,18,52,35,0,18,148,145,224,88,102,218,240,172,195,48,132,7,51,71,158,159,159,187,143,143,15,247,104,249,206,162,238,124,62,159,220,1,250,97,2,213,5,120,127,127,239,190,191,191,195,17,45,27,65,130,153,252,170,159,2,2,95,59,55,51,236,232,225,124,123,89,20,207,237,224,106,2,72,105,207,41,239,242,141,99,158,47,159,188,141,106,121,15,9,50,25,174,114,10,144,196,63,61,61,93,18,43,9,78,109,82,5,
228,120,103,27,156,254,210,238,239,241,154,160,31,175,9,214,158,119,105,92,170,222,191,88,0,147,124,89,149,156,219,165,159,146,192,84,1,247,90,96,76,214,163,42,58,63,32,152,69,167,0,59,249,134,149,92,228,229,108,158,107,129,94,62,177,57,239,229,152,245,8,220,45,128,47,249,18,150,169,2,169,16,77,21,112,142,123,117,250,116,11,19,184,75,128,80,242,77,172,84,1,67,66,255,235,108,1,82,201,151,37,187,231,246,16,6,170,64,136,76,189,253,179,4,136,36,255,109,12,121,176,195,62,157,78,118,55,216,230,90,32,136,166,202,64,182,0,177,228,79,183,95,69,130,235,230,185,85,123,29,179,27,84,1,155,70,253,118,150,0,25,201,151,123,240,195,24,190,252,92,55,170,192,21,133,218,70,82,0,73,162,231,166,141,44,232,109,250,228,219,139,251,107,119,168,2,54,13,157,237,168,0,146,252,64,18,125,201,247,62,137,163,10,232,76,188,137,42,42,192,156,228,155,9,199,87,174,5,44,24,218,155,81,1,60,193,123,63,249,246,113,158,211,66,71,21,176,9,233,106,207,17,32,153,124,107,105,84,1,11,134,230,102,174,0,115,146,191,232,90,
192,243,168,152,103,4,5,13,202,17,96,86,242,173,88,111,170,64,234,238,160,156,38,142,199,99,232,162,147,103,4,22,216,53,155,41,1,238,77,254,127,85,32,244,144,40,145,120,179,214,155,63,47,205,78,94,151,19,56,70,166,120,156,110,238,68,14,73,14,73,21,184,126,122,229,33,145,220,249,147,77,18,31,248,43,227,50,62,253,115,183,128,246,36,180,195,4,14,246,208,248,60,254,60,245,215,72,254,101,42,107,206,75,63,240,63,122,237,48,164,77,226,93,34,133,250,190,10,176,90,242,167,152,135,241,181,159,218,169,79,61,137,55,160,42,189,186,2,172,157,124,89,134,156,6,122,105,68,54,18,31,129,83,114,232,230,20,80,234,23,141,167,129,63,227,220,189,103,126,18,239,129,82,115,151,91,1,74,253,110,183,10,144,248,82,164,181,206,43,85,96,252,57,105,141,143,184,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,
64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,148,39,240,15,0,0,255,255,3,0,177,194,168,159,30,115,243,171,0,0,0,0,73,69,78,68,174,66,96,130);

default_work128//part image and square (w=h) to enable rotation
:array[0..945] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,48,0,0,0,48,8,6,0,0,0,87,2,249,135,0,0,3,121,73,68,65,84,120,1,236,88,205,138,26,65,16,238,73,20,22,141,231,245,224,66,16,47,10,123,80,208,179,224,27,8,65,208,163,143,160,175,224,77,31,193,163,18,9,248,6,130,103,61,120,8,196,219,18,208,131,123,54,89,2,26,76,125,189,211,67,239,236,184,51,83,61,36,57,76,65,59,221,51,85,213,245,213,79,119,219,66,196,20,123,32,246,64,236,129,216,3,6,30,176,56,178,150,101,93,56,114,126,50,151,203,37,180,61,9,63,165,215,190,39,18,9,81,46,151,5,129,185,198,18,232,61,25,45,54,155,141,56,159,207,129,248,221,76,108,0,48,126,177,88,8,0,49,33,24,222,104,52,196,122,189,102,169,121,199,146,250,143,132,216,238,67,216,225,185,168,82,136,235,19,86,2,147,209,63,104,66,200,166,184,181,224,202,253,39,210,69,175,46,31,194,2,225,70,224,22,198,83,251,78,181,144,226,212,130,150,251,48,254,35,53,60,67,19,171,6,200,83,63,105,38,233,53,164,16,162,144,76,38,157,201,209,247,27,67,198,78,63,44,201,79,182,78,71,71,208,14,
55,2,175,244,159,78,39,209,106,181,228,251,217,108,38,159,126,227,87,74,24,47,34,3,160,207,205,93,211,117,29,65,251,198,0,142,199,163,56,28,14,226,238,238,78,192,243,48,190,211,233,200,249,39,147,201,139,244,82,145,65,122,237,118,59,1,89,83,50,1,240,155,38,127,216,110,183,247,253,126,95,140,70,35,145,203,229,222,180,71,213,197,126,191,23,144,33,89,240,63,80,131,46,22,177,150,81,204,100,23,96,137,186,95,168,149,154,205,166,3,2,245,160,71,2,158,215,141,239,245,122,98,62,159,67,205,55,106,159,240,164,34,198,56,52,177,1,96,38,63,16,122,17,3,0,60,31,165,241,210,134,208,144,93,2,110,16,237,118,91,140,199,99,153,251,136,4,8,198,35,34,221,110,87,76,167,83,188,50,246,60,148,128,140,34,240,172,194,137,196,61,141,87,181,90,237,102,185,92,74,163,117,0,232,215,235,117,177,90,173,126,17,95,141,218,87,110,218,168,121,241,140,4,128,84,100,89,105,122,62,18,128,52,0,128,244,20,194,216,6,128,77,240,150,187,113,65,143,78,172,157,88,87,240,175,251,145,0,176,235,32,79,96,222,43,64,200,123,172,62,250,
10,100,127,3,79,222,150,81,236,236,167,49,0,173,136,63,147,21,55,133,66,65,173,78,178,14,212,242,9,62,124,3,15,53,240,150,162,0,97,4,64,51,222,217,11,6,131,129,231,191,52,28,222,240,13,251,5,140,167,38,101,76,65,176,1,120,25,239,222,141,177,242,168,149,8,86,99,167,6,79,148,32,216,0,200,30,39,21,244,93,24,134,130,96,56,86,33,52,31,16,50,245,158,165,194,255,154,0,144,197,88,44,22,197,112,56,124,113,14,130,193,250,137,20,125,55,8,200,64,150,40,79,205,41,254,176,16,76,14,115,114,174,76,38,35,178,217,172,51,175,242,60,94,224,52,10,82,167,83,125,69,130,12,100,77,201,24,128,110,128,219,243,250,55,244,85,84,212,202,228,254,206,25,71,6,224,45,207,123,69,130,99,172,151,12,11,0,173,64,56,54,224,79,189,133,243,140,242,44,254,216,232,116,109,172,248,237,179,16,142,51,41,172,106,156,227,5,11,0,77,248,72,77,78,172,238,135,96,56,250,32,220,23,129,2,142,229,237,6,177,227,15,65,232,107,21,238,42,148,166,141,41,85,173,86,69,165,82,145,59,47,60,136,126,216,49,116,64,23,25,143,168,134,38,110,4,228,
197,46,231,62,200,109,33,210,41,190,27,117,123,37,200,88,229,190,125,164,8,34,226,201,131,66,86,181,226,201,224,243,146,157,66,8,61,247,74,220,199,166,248,115,236,129,216,3,177,7,98,15,252,61,15,252,1,0,0,255,255,3,0,157,161,125,211,66,73,148,186,0,0,0,0,73,69,78,68,174,66,96,130);

default_hand128
:array[0..1946] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,7,98,73,68,65,84,120,1,236,93,141,121,235,38,20,69,110,7,200,8,158,164,193,237,32,205,251,186,71,147,116,144,246,101,144,214,242,155,196,221,32,11,244,185,247,72,198,66,128,28,73,209,15,136,115,191,79,1,33,4,151,115,143,46,8,144,163,20,133,8,16,1,34,176,36,2,90,169,221,75,125,40,137,87,135,4,148,53,16,40,150,171,20,70,191,60,119,212,87,42,85,156,148,250,46,121,40,75,34,176,16,1,238,26,223,106,111,241,74,18,88,112,44,16,93,128,0,125,141,111,90,75,18,24,36,150,8,127,88,160,146,163,91,199,243,243,239,74,235,71,85,20,133,58,159,207,238,101,45,9,226,9,40,75,32,240,227,204,149,104,187,124,173,181,58,30,255,182,147,84,89,158,212,225,240,115,43,77,78,180,28,165,28,148,153,17,216,205,91,126,209,26,244,225,201,119,5,158,192,79,223,105,55,31,207,231,65,96,102,2,244,83,26,158,161,45,151,199,246,57,207,230,66,96,110,2,104,91,113,60,237,148,184,16,152,155,0,113,181,150,218,120,8,144,0,30,36,121,37,
144,0,121,217,219,107,45,9,224,65,146,87,2,9,144,151,189,189,214,146,0,30,36,121,37,144,0,121,217,219,107,45,9,224,65,146,87,2,9,144,151,189,189,214,146,0,30,36,121,37,144,0,121,217,219,107,109,236,4,208,162,177,28,216,84,130,144,50,53,2,115,239,7,24,171,239,94,246,8,94,154,155,17,53,75,203,213,142,161,82,18,112,80,62,137,64,172,30,96,223,221,46,108,44,45,142,87,175,208,157,141,87,122,33,16,43,1,122,40,95,237,48,214,215,140,18,162,155,48,196,64,188,234,54,174,151,25,116,33,16,107,23,80,233,107,54,138,60,62,254,164,78,167,111,178,125,172,116,218,81,252,37,9,251,58,17,221,4,228,162,171,160,250,131,110,227,114,144,104,217,164,49,102,35,16,45,1,176,77,236,229,69,236,103,201,203,203,171,122,125,253,195,74,49,198,183,147,220,56,188,2,73,224,162,98,206,163,237,2,92,227,67,97,164,25,175,96,26,208,47,4,9,32,232,22,16,199,0,243,118,200,121,213,93,104,228,200,77,162,37,64,151,33,208,29,132,4,196,56,30,255,169,54,152,250,155,76,113,7,12,222,26,55,152,98,116,157,94,145,68,226,121,73,148,93,
192,195,195,195,32,43,92,46,255,221,242,155,125,135,32,68,96,187,249,45,95,56,82,121,7,249,38,33,159,79,212,146,243,0,238,135,36,225,167,93,102,141,70,111,64,237,252,126,49,204,153,196,83,163,244,0,247,48,61,159,255,189,119,185,117,13,94,192,125,115,112,7,151,129,129,37,202,208,114,148,114,108,94,146,243,0,67,44,242,254,254,222,202,14,66,184,131,75,156,251,94,100,167,91,55,110,248,100,211,4,232,223,93,184,246,206,231,195,148,77,19,160,239,131,27,24,47,184,140,232,91,84,114,249,72,128,228,76,54,173,194,36,192,180,120,38,87,26,9,144,156,201,166,85,152,4,152,22,207,228,74,35,1,146,51,217,180,10,147,0,211,226,153,92,105,36,64,114,38,155,86,97,18,96,90,60,147,43,237,3,2,96,157,252,182,134,142,117,116,57,148,78,174,149,84,184,19,129,142,197,32,24,29,171,98,178,132,238,73,161,235,164,217,127,207,47,84,57,170,46,234,250,91,127,135,228,109,221,152,251,73,0,76,99,252,94,208,148,66,18,89,63,87,18,134,196,222,218,45,57,173,117,251,80,238,53,211,138,194,253,201,196,75,0,155,53,53,156,167,
110,183,11,208,245,147,223,187,50,201,207,110,161,55,90,17,102,116,8,80,25,179,165,38,150,74,177,213,10,7,150,83,113,248,130,251,224,57,40,169,33,96,143,1,180,171,124,109,244,199,91,178,214,245,175,124,30,14,191,120,27,45,106,207,1,62,229,179,157,234,6,76,194,17,203,3,152,79,175,234,214,212,79,123,99,124,187,141,248,185,87,127,19,5,114,96,224,72,79,96,99,21,123,220,34,64,91,213,176,129,155,60,225,157,52,184,78,18,52,40,197,31,179,9,160,135,170,75,18,12,69,44,190,252,54,1,70,105,119,159,4,163,138,228,77,11,34,96,17,0,19,59,141,184,187,105,155,43,126,172,155,4,77,222,240,219,67,115,157,177,117,16,176,8,208,86,192,249,6,175,125,49,112,246,17,9,62,26,83,4,138,100,210,2,8,88,4,240,95,223,176,103,126,136,128,4,102,190,192,190,15,198,15,108,188,180,179,48,190,18,2,206,252,231,14,211,159,218,232,114,58,157,170,232,16,247,189,223,239,213,211,211,175,98,112,173,190,126,253,243,19,31,116,26,45,150,9,3,30,111,24,251,151,81,115,242,90,96,112,71,252,169,93,60,193,120,186,183,44,92,11,184,89,
183,250,150,254,118,134,8,158,142,161,221,65,171,0,158,68,139,128,61,21,108,41,9,18,180,215,5,64,2,184,117,246,229,22,76,27,136,90,131,192,86,107,74,33,128,215,7,226,115,107,252,151,47,202,118,16,232,34,128,180,16,111,5,62,9,2,131,165,237,160,209,180,164,108,162,219,142,221,33,0,26,238,147,0,19,68,88,13,220,146,228,236,213,62,32,64,55,9,56,40,220,198,35,208,131,0,97,18,240,205,96,27,4,232,120,11,8,53,174,234,14,176,65,64,155,171,102,60,176,245,57,2,211,222,45,134,61,61,128,105,58,231,8,12,18,91,9,7,18,0,205,14,147,32,229,129,148,241,100,141,81,139,108,222,117,71,16,0,91,192,253,215,195,109,205,17,124,151,54,230,33,99,8,32,200,248,175,135,128,203,127,146,226,7,17,158,43,176,247,161,140,95,243,105,52,28,73,0,84,238,147,96,35,115,4,229,52,208,166,81,202,39,8,128,6,134,73,144,210,28,129,239,181,170,47,157,210,176,222,4,90,126,146,0,97,18,0,212,84,72,16,112,255,19,192,154,78,17,206,134,144,177,138,95,74,25,24,106,185,123,47,71,37,99,54,147,152,123,151,10,65,82,163,231,181,206,82,66,
111,17,108,41,125,214,168,167,152,182,210,246,199,160,40,59,230,205,36,254,38,16,188,221,160,91,203,71,38,242,0,55,192,78,226,9,158,110,103,18,193,19,134,125,4,216,42,22,147,4,158,126,81,207,159,227,136,73,231,57,116,153,96,12,208,82,171,76,97,142,0,175,126,254,224,207,159,219,104,181,108,163,39,83,123,0,129,9,227,129,246,230,82,96,247,246,246,22,141,39,248,242,229,55,229,254,142,112,142,79,63,236,50,181,7,64,153,34,254,235,33,82,49,91,184,246,219,65,199,151,205,7,232,151,163,204,68,0,64,25,38,1,92,239,90,27,74,194,198,175,92,127,153,163,241,209,230,98,254,134,227,115,241,240,127,225,112,127,127,96,46,93,224,117,252,62,191,170,173,204,213,245,27,172,23,32,0,170,234,38,1,222,16,230,252,114,136,198,55,166,14,135,11,17,160,170,92,139,195,57,134,213,144,93,38,19,19,225,142,225,161,66,153,251,147,111,236,176,36,1,174,117,250,95,30,25,101,76,56,134,12,102,85,47,252,31,70,77,201,8,243,155,236,177,91,239,198,87,32,64,165,130,22,67,224,91,51,9,239,11,200,0,113,255,95,32,12,13,25,54,151,
79,227,87,160,89,127,214,34,128,81,65,247,37,130,185,97,92,72,195,119,225,182,54,1,140,94,122,6,34,148,82,230,41,183,185,125,3,104,223,48,22,2,216,250,234,43,25,144,38,241,222,82,214,6,71,254,188,22,116,122,35,20,200,24,35,1,92,53,117,157,176,187,134,245,153,24,185,52,49,9,237,184,149,204,40,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,128,8,16,1,34,64,4,136,0,17,32,2,68,32,53,4,254,7,0,0,255,255,3,0,0,202,204,84,56,48,132,57,0,0,0,0,73,69,78,68,174,66,96,130);

default_move128
:array[0..1610] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,6,18,73,68,65,84,120,1,236,157,9,146,155,48,20,68,49,201,185,50,76,229,94,177,157,139,36,23,73,13,206,193,198,81,219,81,129,177,132,89,180,254,223,191,138,1,179,104,233,126,5,2,33,166,105,24,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,16,165,64,123,106,26,76,12,133,10,192,248,195,245,62,233,133,224,160,208,121,83,101,24,126,61,62,214,253,112,110,154,79,179,94,87,40,4,192,101,190,53,93,31,4,202,0,152,51,95,39,4,138,0,88,98,190,62,8,90,91,101,217,115,183,249,199,227,143,6,211,115,160,125,128,99,228,199,23,249,85,244,155,127,58,29,155,174,235,110,18,92,46,151,169,20,102,67,107,206,144,215,126,186,65,210,111,225,0,204,155,111,141,212,12,129,96,0,150,153,175,29,2,161,0,172,51,95,51,4,2,1,216,102,190,86,8,132,1,176,207,124,141,16,8,2,32,140,249,218,32,16,2,64,88,243,53,65,32,0,128,56,230,107,
129,160,114,0,226,154,175,1,130,138,1,72,99,190,116,8,42,5,32,173,249,146,33,168,16,128,60,230,75,133,160,54,0,58,99,196,47,107,134,157,163,71,15,29,59,169,66,82,223,65,101,221,193,109,55,53,57,181,249,54,127,0,231,238,74,182,123,212,49,255,90,71,49,253,165,188,92,254,54,239,239,223,253,59,76,182,188,189,125,243,158,45,78,167,115,131,244,52,69,245,0,244,125,31,204,47,152,31,50,189,96,5,139,152,80,101,151,128,136,74,40,77,154,0,40,53,222,86,187,182,151,66,59,91,240,229,243,214,28,51,140,1,64,11,254,227,227,143,243,112,180,37,30,47,1,183,215,196,123,231,206,254,149,107,247,247,167,148,96,75,129,109,0,220,231,187,226,54,104,163,119,109,153,95,247,105,54,31,54,222,35,126,34,63,76,107,163,51,239,19,154,105,26,155,211,155,38,20,236,119,97,0,184,31,242,252,175,109,111,230,152,42,137,225,172,51,20,24,32,150,53,248,164,160,54,192,172,249,131,134,213,47,149,245,202,121,33,0,104,49,223,210,91,14,4,5,0,160,205,252,178,32,200,12,128,219,124,60,98,181,207,219,173,92,53,207,81,23,247,99,227,
252,103,130,140,0,248,205,79,217,177,147,10,44,127,223,65,94,8,50,1,160,203,124,11,89,137,16,100,0,64,167,249,165,66,144,24,0,221,230,151,8,65,66,0,104,190,5,0,243,82,46,7,137,0,160,249,99,243,237,114,9,16,36,0,128,230,91,195,93,243,220,16,68,238,11,8,105,126,219,153,175,120,185,52,124,177,14,199,93,95,236,227,219,140,99,227,231,9,8,16,231,243,207,219,124,248,115,187,69,52,63,227,125,189,44,98,119,240,62,243,159,187,102,7,89,246,44,173,235,14,222,147,211,112,236,92,158,195,94,104,23,156,29,16,96,143,120,29,72,145,46,1,251,204,31,139,162,105,57,199,229,32,2,0,52,127,15,180,169,33,8,220,6,8,103,62,222,222,141,17,115,233,206,109,219,83,150,181,233,166,108,19,4,108,3,132,51,127,143,216,146,142,77,209,38,8,52,50,136,230,199,0,207,246,136,198,252,132,93,0,0,104,126,12,243,109,154,177,33,136,208,8,180,69,231,188,6,5,2,156,1,240,37,77,124,81,179,233,198,21,182,167,45,75,240,120,27,151,151,43,16,187,29,16,0,0,84,134,16,44,183,116,249,158,177,205,71,73,2,222,5,32,185,112,237,1,84,62,198,
64,77,220,146,217,219,44,148,120,28,57,242,28,231,63,94,78,97,62,242,11,252,28,0,207,172,209,172,192,51,236,33,236,51,110,159,240,195,158,195,82,142,129,154,57,242,28,106,60,44,165,50,31,57,70,104,4,2,2,60,187,126,12,64,128,138,49,230,21,72,105,62,74,18,1,0,36,75,8,160,194,218,72,109,62,202,23,248,18,48,174,114,184,203,193,61,213,77,3,53,205,161,109,55,189,36,153,149,11,35,93,158,57,204,135,8,17,1,64,242,33,33,216,58,176,50,199,224,208,117,121,230,50,31,14,69,186,4,32,105,27,188,28,88,37,92,243,156,230,163,60,9,0,64,54,132,0,42,76,35,183,249,40,79,34,0,144,21,33,128,10,54,74,48,31,101,73,8,0,178,35,4,80,161,20,243,81,150,196,0,32,75,221,16,148,100,126,38,0,244,66,80,154,249,112,34,242,109,32,178,240,5,206,4,56,1,185,31,27,251,142,170,117,125,137,230,67,203,140,0,32,123,29,16,224,203,99,143,95,31,67,221,17,241,94,247,190,167,255,250,111,134,54,192,180,80,238,54,193,116,47,121,191,243,155,15,77,11,0,0,197,208,6,65,25,230,23,4,128,38,8,202,49,31,170,103,110,3,160,8,227,192,153,160,
233,205,137,169,107,158,98,235,248,190,167,132,82,172,232,93,93,226,247,140,111,117,76,81,134,69,121,20,6,192,173,204,189,185,36,152,201,27,157,119,139,115,67,107,246,223,10,15,142,221,50,56,20,16,151,101,116,227,137,192,175,132,121,114,9,182,218,253,202,217,154,228,231,6,106,134,25,144,90,214,41,254,149,54,133,52,2,95,21,147,219,99,41,64,0,98,41,91,73,186,37,182,1,86,73,183,118,220,193,220,64,205,185,109,190,66,185,31,240,248,246,46,111,125,245,0,204,189,230,189,86,238,53,111,45,35,109,60,222,37,0,107,85,14,188,255,150,87,206,67,20,193,255,108,127,246,14,38,68,214,65,211,8,52,50,40,104,153,102,18,43,99,4,146,223,124,220,1,92,127,207,84,160,184,77,149,1,0,253,242,66,48,111,126,29,247,254,99,10,43,4,32,31,4,210,204,135,146,149,2,144,30,2,137,230,87,14,64,58,8,164,154,47,0,128,248,16,72,54,95,8,0,241,32,144,110,190,32,0,194,67,160,193,124,97,0,132,131,64,139,249,2,1,216,15,129,38,243,133,2,176,29,2,109,230,11,6,96,61,4,26,205,23,14,192,114,8,180,154,15,133,42,123,37,12,69,222,18,
238,87,201,236,63,115,180,61,138,143,41,215,245,106,215,99,217,151,255,82,2,0,4,113,67,224,150,74,135,249,168,187,34,0,80,221,37,16,232,49,95,33,0,175,32,208,101,190,82,0,124,16,232,51,31,74,40,14,92,14,14,102,196,8,38,44,51,20,42,0,227,105,190,66,227,89,101,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,162,21,248,7,0,0,255,255,3,0,219,123,55,92,132,118,62,111,0,0,0,0,73,69,78,68,174,66,96,130);

default_cross128
:array[0..755] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,2,187,73,68,65,84,120,1,236,220,209,106,227,64,12,5,208,184,237,255,255,113,73,201,163,3,130,184,136,209,200,58,133,125,200,52,29,107,206,189,184,75,192,125,60,124,17,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,208,79,224,232,55,242,127,39,62,158,215,126,242,57,194,230,235,26,138,119,223,77,64,1,238,150,232,197,243,40,192,69,176,187,189,253,231,110,7,250,244,60,207,231,239,233,173,199,241,125,122,61,229,133,59,192,148,164,131,115,42,64,0,51,101,89,1,166,36,29,156,83,1,2,152,41,203,10,48,37,233,224,156,10,16,192,76,89,86,128,41,73,7,231,84,128,0,102,202,178,2,76,73,58,56,167,2,4,48,83,150,21,96,74,210,193,57,21,32,128,153,178,172,0,83,146,14,206,169,0,1,204,148,101,5,152,146,116,112,78,5,8,96,166,44,43,192,148,164,131,115,42,64,0,51,101,89,1,166,36,29,156,83,1,2,152,41,203,10,48,37,233,224,
156,10,16,192,76,89,86,128,41,73,7,231,84,128,0,102,202,178,2,76,73,58,56,167,2,4,48,83,150,21,96,74,210,193,57,23,62,27,120,245,249,252,96,226,101,203,213,243,174,249,251,4,238,0,203,10,181,231,133,20,96,207,92,150,77,165,0,203,168,247,188,208,194,255,3,156,1,222,159,207,63,127,119,253,171,234,121,170,254,62,129,59,192,250,174,109,117,69,5,216,42,142,245,195,40,192,122,243,173,174,88,86,128,215,239,188,202,127,239,41,84,206,82,245,251,255,101,80,86,128,247,0,188,174,17,80,128,26,247,109,174,170,0,219,68,81,51,200,194,207,1,214,124,182,29,51,94,253,108,191,122,222,248,36,153,223,113,7,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,
115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,151,2,52,12,45,115,100,5,200,212,108,184,215,194,103,3,247,210,169,124,38,127,39,9,119,128,157,210,40,152,69,1,10,208,119,186,164,2,236,148,134,89,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,240,145,192,31,0,0,0,255,255,3,0,38,217,18,226,159,23,159,98,0,0,0,0,73,69,78,68,174,66,96,130);

default_ns128
:array[0..1124] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,4,44,73,68,65,84,120,1,236,157,1,114,210,96,16,70,147,234,185,100,189,73,79,98,193,123,57,13,94,68,111,82,179,180,12,157,16,160,73,179,145,111,247,253,51,25,75,104,54,187,239,123,45,85,198,254,77,195,130,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,64,34,2,214,207,226,71,217,245,80,118,242,67,240,237,115,211,248,81,87,130,170,2,216,91,240,111,254,215,149,160,162,0,131,240,223,28,40,250,157,160,154,0,23,194,175,43,65,37,1,110,132,95,83,130,42,2,140,134,255,244,244,163,241,227,124,213,249,153,160,130,0,23,195,223,110,159,26,63,42,75,144,93,128,171,225,31,191,242,43,75,144,89,128,15,133,95,93,130,172,2,76,10,191,178,4,25,5,152,21,126,85,9,178,9,240,169,240,43,74,144,73,128,69,194,175,38,65,22,1,22,13,191,146,4,25,4,8,9,191,138,4,234,2,132,134,95,65,2,101,1,86,9,63,187,4,170,2,172,26,126,102,9,20,5,248,47,225,103,149,224,203,
113,48,157,63,219,63,195,94,253,205,28,255,247,252,181,150,153,29,110,181,223,239,7,183,108,31,251,19,187,193,201,187,126,248,245,174,187,251,64,115,30,134,31,93,55,12,227,242,197,102,155,209,39,167,213,176,102,191,255,221,223,183,27,173,165,114,82,94,0,15,96,74,8,175,194,252,26,205,103,183,251,57,169,214,104,17,177,147,15,98,253,210,238,194,4,16,96,97,160,106,229,20,95,2,186,25,144,109,198,53,126,73,55,243,58,153,203,4,5,120,249,62,145,174,245,255,7,160,63,230,172,23,255,137,190,155,115,165,202,53,188,4,168,36,21,212,39,2,4,129,85,41,139,0,42,73,5,245,137,0,65,96,85,202,34,128,74,82,65,125,34,64,16,88,149,178,8,160,146,84,80,159,8,16,4,86,165,44,2,168,36,21,212,39,2,4,129,85,41,139,0,42,73,5,245,137,0,65,96,85,202,34,128,74,82,65,125,34,64,16,88,149,178,8,160,146,84,80,159,8,16,4,86,165,44,2,168,36,21,212,39,2,4,129,85,41,139,0,42,73,5,245,137,0,65,96,85,202,34,128,74,82,65,125,34,64,16,88,149,178,8,160,146,84,80,159,8,16,4,86,165,44,2,168,36,21,212,39,2,4,129,85,41,139,0,42,
73,5,245,137,0,65,96,85,202,34,128,74,82,65,125,34,64,16,88,149,178,8,160,146,84,80,159,8,16,4,86,165,44,2,168,36,21,212,39,2,4,129,85,41,139,0,42,73,5,245,137,0,65,96,85,202,34,128,74,82,65,125,34,64,16,88,149,178,8,160,146,84,80,159,8,16,4,86,165,44,2,168,36,21,212,167,224,111,10,61,236,236,29,132,99,88,182,245,77,8,38,110,68,48,249,55,153,14,111,186,234,99,65,1,26,91,145,208,154,247,90,113,172,211,173,120,9,56,177,40,249,17,2,148,140,253,52,180,226,75,192,169,251,254,35,223,1,196,247,12,90,98,121,157,41,181,50,236,48,34,47,128,111,23,179,217,124,91,100,211,168,75,123,9,141,201,181,221,238,82,108,47,35,184,107,88,211,239,14,213,62,190,15,229,184,123,151,127,55,88,99,121,248,254,213,127,190,14,127,3,248,123,126,254,126,207,180,247,219,218,213,206,172,151,224,121,248,25,107,108,31,119,35,252,110,216,211,189,63,86,21,192,185,218,218,18,100,11,223,33,42,11,224,253,219,90,18,100,12,223,1,170,11,224,51,88,180,4,89,195,119,120,25,4,240,57,44,74,130,204,225,59,184,44,2,248,44,182,180,
4,217,195,119,104,153,4,240,121,108,41,9,42,132,239,192,178,9,224,51,217,103,37,168,18,190,195,202,40,128,207,101,115,37,168,20,190,131,202,42,128,207,102,83,37,168,22,190,67,202,44,128,207,103,31,149,160,98,248,14,40,187,0,62,163,221,146,160,106,248,14,167,130,0,62,167,93,146,192,159,188,242,198,78,231,207,103,94,85,4,240,12,109,76,130,241,112,15,239,234,117,227,207,229,58,91,73,0,79,206,110,75,80,39,124,7,82,77,0,159,217,46,75,80,43,124,135,81,81,0,159,219,206,37,168,23,190,131,168,188,172,151,224,229,245,112,33,88,21,9,88,63,180,31,44,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,228,32,240,15,0,0,255,255,3,0,51,69,59,64,254,172,31,45,0,0,0,0,73,69,78,68,174,66,96,130);

modern_link128//part image
:array[0..1306] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,40,0,0,0,40,8,6,0,0,0,140,254,184,109,0,0,4,226,73,68,65,84,120,1,236,150,81,72,157,101,24,199,207,57,217,230,156,86,231,232,42,119,4,77,157,149,135,182,85,142,149,40,67,80,111,66,137,236,120,162,161,48,163,132,26,97,174,144,22,76,45,86,100,117,33,70,96,187,232,170,72,183,38,232,69,160,23,99,32,210,210,4,195,73,51,53,53,205,66,183,85,206,92,155,250,245,251,31,206,39,199,47,143,158,155,174,250,30,248,241,188,223,249,222,247,125,158,247,255,62,223,251,30,135,195,54,91,1,91,1,91,1,91,1,91,129,255,66,1,23,147,38,192,189,112,95,148,236,161,95,44,56,193,106,119,242,131,222,111,54,151,98,40,150,98,254,203,172,147,233,121,39,164,130,31,142,128,130,70,99,55,232,244,25,92,130,171,176,4,6,40,185,67,240,22,220,5,86,187,201,15,23,225,44,76,193,223,160,113,65,139,49,27,33,191,11,95,0,239,250,124,190,212,225,225,97,61,43,233,104,76,147,62,230,116,58,71,241,231,225,75,248,13,60,208,4,143,27,134,113,7,222,106,198,33,108,96,96,64,130,156,132,
11,240,151,217,201,76,80,73,40,153,195,69,69,69,77,221,221,221,15,210,214,100,43,32,37,214,32,82,162,74,108,189,36,72,194,157,146,146,146,57,59,59,251,0,191,127,4,82,232,119,88,4,169,105,154,57,110,119,127,127,255,221,252,232,43,46,46,110,234,233,233,57,78,251,18,44,131,97,6,213,54,22,147,220,105,146,123,136,182,2,94,79,76,76,252,169,162,162,162,45,59,59,91,43,50,251,210,220,96,198,224,224,96,124,107,107,107,85,121,121,185,183,173,173,109,183,222,50,246,26,246,5,205,119,64,53,86,224,241,120,98,235,235,235,29,177,177,193,170,49,70,70,70,226,154,155,155,3,44,74,139,113,195,26,73,254,64,146,42,135,110,184,169,160,74,38,11,190,162,163,148,115,4,2,129,201,246,246,246,15,104,170,211,60,104,181,91,153,230,216,11,47,122,189,222,163,51,51,51,42,124,7,219,61,134,123,30,190,7,169,103,93,164,158,247,64,113,73,73,201,27,157,157,157,105,180,53,238,10,174,12,70,213,65,242,158,202,201,201,121,9,169,181,250,5,58,188,142,239,132,63,32,82,114,26,171,18,49,75,65,101,160,175,180,106,124,124,252,181,
244,244,116,213,222,34,115,125,130,127,31,180,205,155,153,153,67,41,2,125,72,135,164,204,204,204,37,230,248,148,246,219,90,249,14,240,145,156,252,10,91,51,138,239,131,63,33,82,114,188,10,126,237,250,58,159,134,71,64,201,254,10,159,103,100,100,92,198,171,126,181,181,207,130,18,87,172,205,76,49,20,171,207,229,114,41,246,202,216,216,88,48,39,218,59,52,169,169,132,188,62,241,111,96,1,164,72,36,83,48,47,52,67,42,252,8,126,248,5,244,49,204,128,18,212,182,106,87,34,37,199,171,160,41,214,130,219,237,86,236,3,160,163,46,152,155,117,160,145,156,156,172,36,183,74,142,215,65,211,42,247,178,45,170,161,52,208,150,106,190,235,240,30,91,43,47,117,86,33,26,91,11,197,222,176,107,202,50,220,156,115,115,115,202,222,154,120,120,159,240,182,84,119,52,52,52,184,225,77,154,175,194,85,184,6,147,36,169,247,42,120,29,53,219,153,43,20,59,56,167,217,89,137,40,99,109,135,252,78,142,134,39,240,73,176,93,146,82,121,9,12,142,14,45,52,5,84,115,10,160,18,121,5,94,134,99,240,51,108,181,43,138,149,20,138,45,129,
214,115,210,139,91,112,185,180,180,84,62,134,45,203,194,231,130,174,165,13,171,225,217,52,5,211,45,113,14,84,115,49,220,60,62,252,81,184,31,180,224,97,248,26,204,122,164,185,169,41,134,98,229,134,98,199,228,231,231,7,115,226,183,91,74,80,1,206,116,117,117,77,227,21,216,195,129,125,10,31,128,52,136,7,21,122,56,113,60,75,189,115,124,245,250,114,13,174,69,55,103,224,113,218,39,96,31,232,102,146,178,234,27,62,54,188,173,185,211,32,144,151,151,167,152,170,227,181,222,222,94,229,114,6,22,117,134,73,206,27,48,217,215,215,183,159,155,35,9,60,212,84,110,99,99,99,81,117,117,245,46,204,55,61,61,253,40,125,14,134,120,24,175,58,155,95,94,94,246,182,180,180,236,171,171,171,139,171,173,173,141,231,136,217,223,209,209,241,84,101,101,101,76,66,66,66,182,101,156,57,254,32,183,202,1,191,223,255,228,208,208,80,35,202,149,85,85,85,37,51,159,161,155,100,98,98,226,36,237,239,224,182,185,133,242,90,177,238,226,143,183,187,139,169,253,219,244,253,22,94,128,88,56,129,122,126,110,144,68,218,58,90,180,19,
218,25,121,51,6,205,13,38,97,180,131,82,84,74,175,146,220,149,72,119,49,239,131,166,237,40,128,237,254,205,172,146,164,86,88,6,243,160,131,248,57,120,134,0,89,133,133,133,247,208,142,148,24,175,54,152,81,83,83,179,204,157,60,197,175,82,238,2,172,255,155,177,78,162,103,125,69,169,160,131,247,8,72,33,171,233,228,63,13,253,32,53,53,78,74,72,193,195,112,12,84,95,209,152,142,160,139,112,22,166,64,231,176,212,221,210,36,189,142,12,93,250,82,199,138,14,103,109,165,213,148,168,22,164,247,214,49,145,158,21,67,177,20,211,54,91,1,91,1,91,1,91,1,91,129,255,155,2,255,0,0,0,255,255,3,0,228,115,129,6,147,254,153,72,0,0,0,0,73,69,78,68,174,66,96,130);

default_help128//part image
:array[0..1142] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,32,8,6,0,0,0,31,124,40,241,0,0,4,62,73,68,65,84,120,1,124,150,111,72,164,85,20,198,159,119,54,205,77,29,42,114,172,177,208,53,106,131,202,54,98,17,201,15,43,180,132,138,187,43,42,173,9,110,53,42,226,135,36,149,40,176,66,210,146,96,12,82,35,40,63,152,26,130,173,95,44,252,159,136,244,69,12,66,9,63,132,16,174,129,81,254,193,52,179,208,233,121,238,206,29,157,119,220,14,252,60,247,158,123,239,153,123,207,61,231,190,2,81,226,192,113,156,56,114,129,92,33,87,73,29,185,70,46,145,167,1,15,87,88,142,23,159,81,147,19,206,144,52,199,65,7,187,93,164,154,188,76,202,200,21,82,76,174,147,27,156,243,44,73,37,63,210,225,17,16,162,25,144,131,123,169,223,35,159,147,231,137,151,36,144,187,194,80,153,118,60,181,236,79,145,203,132,59,196,50,183,241,43,219,102,143,79,80,215,145,251,147,147,147,81,80,80,128,234,234,106,76,79,79,99,102,102,6,123,123,123,152,157,157,69,127,127,63,90,91,91,145,157,157,13,143,199,19,199,249,151,200,87,116,246,16,
181,249,37,135,90,160,185,185,25,53,53,53,240,122,181,169,99,201,205,205,141,116,2,129,0,154,154,154,48,48,48,32,219,163,228,67,158,42,160,168,69,36,51,51,19,219,219,219,24,31,31,71,69,69,5,138,138,138,204,162,174,174,46,28,28,28,152,121,62,159,15,157,157,157,40,47,47,183,235,110,176,113,150,206,156,28,54,38,72,82,126,126,62,70,71,71,237,132,40,93,86,86,134,190,190,62,196,197,233,84,192,200,200,8,74,74,74,112,120,120,168,238,117,5,52,34,39,156,232,231,247,201,95,68,115,82,134,134,134,28,191,223,143,142,14,93,44,13,41,41,134,245,245,117,117,95,212,209,34,49,146,133,242,29,209,213,191,64,46,144,139,100,129,96,121,121,25,59,59,59,106,34,33,33,33,178,59,118,111,233,215,126,34,75,228,28,249,148,180,134,66,33,230,135,21,31,243,236,247,71,212,211,173,218,139,216,221,221,141,196,141,67,27,220,141,178,217,56,209,206,126,9,133,28,58,177,126,204,88,30,237,223,144,123,116,171,45,45,45,108,194,196,82,113,219,223,87,4,240,164,22,223,65,140,19,37,223,56,241,167,165,165,153,248,148,150,150,98,
109,109,13,85,85,85,152,156,156,212,218,111,201,181,83,29,241,38,21,187,171,228,19,242,112,124,124,60,122,123,123,161,29,172,172,172,160,190,190,30,99,99,99,28,194,63,164,158,167,248,204,212,154,44,199,226,209,81,51,217,255,158,120,211,211,211,209,214,214,134,202,202,74,179,147,218,218,90,76,76,40,91,140,140,133,66,104,80,189,69,93,191,134,28,39,36,39,55,213,78,77,77,53,201,167,178,89,90,90,66,99,99,163,41,29,141,81,134,73,192,22,173,142,112,66,76,247,37,26,158,145,177,187,187,27,133,133,133,88,93,93,61,233,228,111,14,41,110,175,241,118,183,53,79,18,117,52,30,73,59,124,147,60,158,151,151,103,106,79,241,81,109,13,15,107,3,248,151,188,77,222,162,147,63,101,176,226,62,154,130,127,94,131,42,84,149,195,226,226,34,230,230,230,236,252,121,198,228,99,123,28,107,148,118,29,237,120,232,232,232,200,212,145,158,145,173,173,45,59,16,180,13,183,62,205,145,73,137,158,158,30,100,101,101,161,184,184,24,27,27,27,118,221,57,219,112,235,168,60,10,231,15,183,142,215,221,19,195,253,247,153,51,239,
30,103,254,29,102,201,76,103,15,146,15,200,205,48,95,135,117,144,250,177,255,89,234,30,210,105,205,215,228,62,46,244,147,139,132,143,189,115,183,123,230,201,126,212,245,107,128,41,192,215,14,37,108,126,65,62,34,213,164,137,240,43,227,252,193,25,183,216,142,17,87,176,77,87,111,209,151,196,36,165,222,157,176,188,74,61,196,31,49,79,138,53,90,29,229,136,229,161,188,122,135,232,211,131,246,246,118,76,77,77,153,74,87,159,226,35,252,182,153,162,54,6,251,39,202,17,141,207,145,116,13,14,14,14,162,161,161,1,57,57,57,8,6,131,200,200,200,144,89,161,80,10,184,215,197,24,76,166,243,187,133,205,205,77,221,160,22,67,101,146,152,152,104,218,252,147,68,110,15,88,139,219,192,133,10,200,111,196,155,148,148,132,186,186,58,232,73,157,159,159,199,194,130,121,182,245,116,190,193,58,211,59,21,37,177,158,249,207,3,103,12,146,179,81,51,111,119,126,160,186,76,71,145,154,57,101,142,53,233,97,115,94,33,63,147,245,48,43,212,3,132,231,139,249,109,187,208,173,21,71,227,204,203,133,231,195,60,64,205,99,199,196,
56,178,248,63,0,0,0,255,255,3,0,187,55,32,231,46,36,56,160,0,0,0,0,73,69,78,68,174,66,96,130);

default_text128
:array[0..767] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,2,199,73,68,65,84,120,1,236,221,193,110,26,65,16,4,80,147,228,255,255,56,194,242,209,123,27,102,151,170,102,95,164,28,44,225,233,226,117,121,76,56,132,175,47,127,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,129,73,2,143,57,97,31,207,115,179,62,15,207,253,234,243,207,77,127,214,105,127,206,58,200,57,51,5,254,205,140,125,70,234,179,127,226,207,200,244,254,51,220,0,239,55,175,154,56,246,6,120,62,255,47,65,62,30,127,151,30,127,245,249,75,97,46,124,176,27,224,66,220,9,71,143,189,1,86,113,87,127,162,87,207,159,250,120,55,192,212,205,157,148,123,108,1,126,126,167,239,252,61,250,237,156,181,250,250,226,56,59,249,245,216,2,36,209,62,105,182,2,124,210,54,95,120,46,10,240,2,218,39,125,203,160,127,5,28,223,187,95,93,195,234,59,127,187,243,86,243,101,30,239,6,200,184,215,76,85,128,154,85,
100,130,40,64,198,189,102,170,2,212,172,34,19,68,1,50,238,53,83,21,160,102,21,153,32,10,144,113,175,153,170,0,53,171,200,4,81,128,140,123,205,84,5,168,89,69,38,136,2,100,220,107,166,42,64,205,42,50,65,20,32,227,94,51,85,1,106,86,145,9,162,0,25,247,154,169,10,80,179,138,76,16,5,200,184,215,76,85,128,154,85,100,130,40,64,198,189,102,170,2,212,172,34,19,68,1,50,238,53,83,21,160,102,21,153,32,10,144,113,175,153,170,0,53,171,200,4,81,128,140,123,205,84,5,168,89,69,38,136,2,100,220,107,166,42,64,205,42,50,65,20,32,227,94,51,85,1,106,86,145,9,162,0,25,247,154,169,10,80,179,138,76,16,5,200,184,215,76,85,128,154,85,100,130,40,64,198,189,102,170,2,212,172,34,19,68,1,50,238,53,83,21,160,102,21,153,32,10,144,113,175,153,170,0,53,171,200,4,81,128,140,123,205,84,5,168,89,69,38,136,2,100,220,107,166,42,64,205,42,50,65,20,32,227,94,51,85,1,106,86,145,9,162,0,25,247,154,169,131,62,47,96,245,255,251,223,53,222,157,55,227,243,6,220,0,187,61,25,254,253,10,48,124,129,187,241,21,96,87,112,248,247,
15,122,13,240,91,250,236,79,2,221,61,111,234,103,7,186,1,126,247,234,118,95,221,166,0,171,159,12,122,151,38,220,166,0,119,89,232,234,243,28,251,26,224,234,223,185,87,159,191,186,168,171,30,239,6,184,74,118,200,185,99,111,128,125,223,227,59,117,187,239,252,237,39,74,156,224,6,72,168,155,73,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,120,81,224,27,0,0,255,255,3,0,31,160,29,124,154,132,39,101,0,0,0,0,73,69,78,68,174,66,96,130);

default_pen128
:array[0..1770] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,6,178,73,68,65,84,120,1,236,157,111,114,163,54,24,198,133,219,123,148,94,100,163,76,103,186,135,232,206,108,122,140,124,105,156,126,218,30,195,147,115,180,198,61,137,115,130,156,160,235,190,47,88,24,129,4,146,44,33,176,31,205,96,64,255,249,61,79,36,129,99,91,8,4,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,0,1,16,176,17,144,182,4,196,47,135,192,15,137,186,34,133,40,246,180,109,207,27,159,63,9,177,249,89,136,147,160,80,210,118,164,13,33,51,129,34,93,251,69,173,244,68,253,21,25,226,149,242,208,30,33,7,129,77,142,70,59,109,202,243,72,65,102,225,17,67,208,57,194,156,4,82,77,1,116,13,133,164,151,146,54,215,80,54,211,68,61,109,72,42,244,78,219,145,54,132,132,4,18,142,0,197,161,219,111,41,165,80,91,55,222,114,44,207,35,3,70,5,11,160,88,209,63,198,170,104,170,158,135,135,79,98,187,125,105,179,85,
213,65,188,190,254,89,159,87,85,213,198,247,14,228,121,36,161,12,88,43,244,216,68,57,77,61,5,144,128,77,40,138,66,60,61,125,85,167,162,44,203,250,156,227,120,100,40,203,159,196,225,160,13,26,109,94,58,40,155,233,97,83,144,17,170,110,2,142,175,35,64,64,147,5,217,12,227,151,250,79,167,255,46,39,150,35,53,50,140,140,10,84,242,244,72,47,149,165,10,68,123,16,72,56,2,240,2,142,23,116,122,224,191,246,177,160,70,6,206,247,254,254,46,142,199,163,33,123,241,116,158,26,118,134,68,68,121,16,72,105,0,234,6,15,217,66,170,254,72,249,80,15,247,234,124,108,223,53,194,110,103,212,185,60,27,236,64,245,28,199,234,66,154,157,192,198,158,20,63,69,45,250,124,106,102,211,240,212,241,242,242,135,165,24,63,63,216,108,45,137,136,158,32,144,216,0,223,163,9,195,119,16,251,253,63,150,17,228,68,183,23,245,131,164,137,203,69,114,159,64,226,41,128,155,43,36,189,148,180,181,97,106,29,208,102,236,29,168,105,129,163,13,119,12,37,214,5,61,96,14,167,51,24,128,223,0,186,172,3,88,184,238,243,0,135,62,14,178,40,3,193,
4,3,52,222,17,51,24,128,239,219,253,239,6,166,174,132,77,192,155,225,78,161,196,72,48,69,239,146,158,120,13,160,26,42,94,213,17,239,67,22,131,221,242,234,152,23,136,251,253,223,181,17,84,220,121,47,201,4,180,56,68,152,34,48,147,1,134,139,193,237,86,243,196,84,63,71,211,97,130,81,60,163,137,51,25,128,251,160,143,2,163,189,10,72,132,9,2,160,81,145,25,13,160,119,144,167,129,152,163,0,215,14,19,232,140,93,206,102,52,0,79,3,250,40,16,107,45,208,189,80,152,160,75,99,250,120,70,3,112,103,190,87,253,46,197,30,5,184,126,152,160,79,217,126,62,195,109,160,214,248,177,255,254,0,223,203,243,237,28,63,228,137,25,248,109,230,195,225,223,254,155,73,212,72,253,96,106,23,179,173,53,215,53,243,8,192,168,134,119,4,41,166,2,110,9,35,1,83,24,15,25,12,192,29,210,215,2,252,222,127,138,169,128,91,130,9,152,130,61,100,50,128,121,65,8,19,216,133,74,149,82,164,170,216,173,222,225,103,7,154,119,252,30,220,138,123,230,122,124,252,69,24,254,211,168,58,255,135,145,103,109,183,145,61,211,8,160,224,233,83,1,199,
166,90,15,112,221,152,14,152,130,30,50,27,96,56,21,240,95,40,255,165,166,10,48,129,78,54,179,1,184,51,48,129,46,201,188,103,153,215,0,221,139,29,126,52,140,159,15,240,95,108,170,128,53,1,221,143,165,130,27,86,47,76,16,198,45,188,212,194,12,192,23,2,19,132,203,233,95,114,129,6,128,9,252,101,12,47,177,80,3,192,4,225,146,250,149,92,176,1,96,2,63,41,195,114,47,220,0,48,65,152,172,238,165,86,96,0,152,192,93,78,255,156,43,49,0,76,224,47,173,91,137,21,25,0,38,112,147,212,47,215,202,12,0,19,248,201,59,157,123,133,6,128,9,166,101,117,207,177,82,3,192,4,238,18,143,231,92,177,1,96,130,113,105,221,82,87,110,0,152,192,77,102,123,174,27,48,0,76,96,151,119,58,229,70,12,0,19,76,75,109,206,113,67,6,128,9,204,18,143,199,222,152,1,96,130,113,185,135,169,55,104,0,152,96,40,179,61,230,70,13,0,19,216,37,215,83,110,216,0,48,129,46,181,249,236,198,13,0,19,152,101,191,196,222,129,1,96,130,139,220,195,163,59,49,0,76,48,148,190,137,185,35,3,192,4,38,19,44,224,163,97,166,110,165,138,27,254,206,192,188,159,
69,60,169,11,147,231,207,63,168,243,108,251,59,27,1,20,231,121,63,124,242,237,219,95,226,249,249,89,53,78,251,22,123,149,251,163,233,109,79,58,189,187,147,195,121,76,48,20,95,225,109,209,103,53,193,157,77,1,10,62,239,211,79,7,14,226,115,71,100,206,233,224,142,13,192,236,211,153,192,38,254,219,219,219,162,190,219,184,29,135,24,199,253,134,184,211,193,152,248,95,190,252,86,99,94,202,71,211,97,128,214,245,113,76,224,34,190,106,114,9,38,128,1,148,26,245,254,58,19,248,136,175,154,205,109,2,24,64,41,209,238,195,76,16,34,190,106,50,167,9,96,0,165,130,182,247,51,193,53,226,171,102,115,153,0,6,80,10,12,246,110,38,136,33,190,106,58,135,9,238,252,54,80,161,55,237,167,111,17,99,138,207,61,176,127,133,93,186,223,69,196,8,96,210,94,139,51,143,4,159,63,255,218,123,188,219,20,226,251,124,117,171,167,85,227,113,98,24,9,170,84,143,140,49,2,76,10,99,30,9,244,103,251,77,37,49,196,231,154,12,191,146,42,155,22,226,191,194,0,78,76,251,38,104,223,213,107,75,199,18,159,43,52,124,93,110,213,54,20,249,
0,6,112,6,218,53,129,62,115,198,20,223,48,252,83,15,139,131,115,55,61,51,206,253,139,33,158,221,91,92,246,29,137,33,169,87,229,229,45,221,66,124,124,124,8,254,133,146,107,131,89,124,81,209,252,255,251,181,117,219,202,23,182,4,196,143,17,48,47,12,175,249,90,219,17,241,31,199,122,114,109,26,12,16,76,48,158,9,114,137,207,151,14,3,4,27,160,198,183,167,87,217,173,194,247,11,174,115,138,95,95,65,183,243,56,14,33,16,62,18,228,22,31,6,8,209,219,88,198,223,4,75,16,31,6,48,138,25,26,233,110,130,165,136,15,3,132,106,109,45,55,109,130,37,137,15,3,88,133,188,38,193,110,130,165,137,15,3,92,163,243,104,217,161,9,44,217,171,84,111,242,88,218,27,68,227,54,112,128,36,86,196,164,9,170,220,226,243,149,194,0,177,244,54,214,99,53,65,181,4,241,141,93,70,100,108,2,252,207,28,108,4,254,149,84,222,167,251,231,142,216,61,71,125,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,32,0,2,43,33,240,63,0,0,0,255,255,3,0,31,105,
232,250,190,43,128,49,0,0,0,0,73,69,78,68,174,66,96,130);

default_person128//part image
:array[0..1312] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,31,0,0,0,33,8,6,0,0,0,33,222,112,228,0,0,4,232,73,68,65,84,120,1,188,87,111,44,182,85,24,191,60,94,53,100,228,21,94,150,55,249,51,90,125,208,144,68,98,99,38,62,228,223,88,152,146,180,85,51,95,152,47,136,205,88,243,37,246,178,86,88,254,213,104,195,154,201,50,182,204,214,74,62,48,150,229,147,205,172,48,107,163,33,244,251,221,238,251,222,253,220,207,253,60,146,214,181,253,158,235,58,215,185,206,249,157,115,159,227,186,14,247,203,203,75,105,110,110,86,80,95,95,47,237,237,237,226,230,230,38,255,135,216,140,36,199,199,199,198,166,131,205,69,25,224,9,251,41,67,219,33,254,38,199,61,99,192,238,238,174,177,169,219,36,80,37,30,250,93,160,24,240,85,125,84,63,1,95,32,174,15,250,252,234,234,138,190,27,69,223,57,9,150,151,151,29,62,185,74,252,56,102,250,10,248,17,168,6,140,196,104,10,23,245,9,112,0,188,206,49,234,56,52,157,139,190,243,211,211,83,169,171,171,179,139,84,39,240,130,243,7,224,121,118,118,119,119,75,122,122,186,196,198,198,178,
41,188,51,115,115,115,50,48,48,32,19,19,19,62,112,125,3,112,129,159,1,46,197,141,131,41,43,43,43,146,144,144,160,172,88,251,108,32,231,226,190,5,50,146,147,147,21,130,136,136,8,134,91,202,240,240,176,84,86,86,106,125,233,48,22,181,185,52,167,81,43,159,253,252,252,92,18,19,19,237,62,149,186,235,44,4,103,196,196,196,200,248,248,184,184,34,230,164,101,101,101,210,211,211,163,205,255,37,140,199,180,134,149,182,157,157,157,73,75,75,139,222,103,90,233,35,118,52,53,53,73,80,80,144,30,227,202,168,169,169,145,204,204,76,134,112,64,186,186,9,203,33,182,182,182,54,233,232,232,80,58,77,196,207,194,249,48,52,52,84,138,138,138,44,7,91,57,73,150,159,159,175,117,189,167,25,86,218,198,164,66,49,17,211,21,194,159,236,236,108,170,91,73,110,110,174,22,255,170,102,88,105,229,204,45,136,25,203,155,43,33,33,33,118,119,129,190,155,36,56,56,88,11,241,135,225,174,53,204,218,105,7,62,223,3,4,191,197,203,150,147,147,115,171,5,236,239,239,75,87,87,23,185,254,0,174,63,45,91,38,209,147,140,201,207,230,111,
252,89,92,92,164,186,149,204,206,206,106,241,204,15,78,197,21,249,47,24,117,176,181,181,37,51,51,51,78,39,48,119,240,8,39,39,39,53,119,175,102,88,105,61,195,89,117,194,87,11,12,183,182,182,42,89,205,203,139,201,206,181,140,140,140,200,212,212,20,131,254,4,190,115,114,159,148,73,244,138,161,180,76,63,56,119,222,137,53,32,54,43,43,75,73,52,222,222,222,166,168,235,38,73,166,167,167,165,188,188,92,78,78,78,232,44,4,190,190,11,57,39,225,197,227,17,248,68,71,71,75,99,99,163,20,22,22,138,187,187,187,216,108,54,185,184,184,16,150,98,190,5,198,198,198,132,53,2,242,49,208,0,98,151,229,205,229,206,57,139,154,161,238,195,92,0,94,160,47,48,48,80,194,195,195,133,199,112,112,112,32,235,235,235,74,129,65,215,95,192,135,192,167,224,189,46,26,104,56,19,151,228,42,49,47,101,50,48,1,220,148,99,207,16,51,14,124,0,28,221,176,113,113,122,219,85,98,214,237,37,224,123,32,136,133,165,162,162,66,230,231,231,101,111,111,79,248,247,188,177,177,33,189,189,189,146,146,146,34,62,62,62,44,36,111,2,59,192,219,
152,195,229,230,44,201,213,49,207,96,130,95,129,151,153,229,134,134,134,100,117,117,85,250,251,251,37,45,45,77,2,2,2,196,207,207,79,120,15,170,171,171,101,97,97,65,182,183,183,165,184,184,152,247,225,9,140,251,28,232,118,197,239,64,174,6,243,140,127,6,2,50,50,50,100,109,109,77,74,75,75,149,51,134,207,82,56,206,223,223,95,70,71,71,21,168,243,188,143,224,38,103,11,112,32,87,103,158,134,126,50,47,47,79,73,24,190,190,230,87,147,37,191,238,44,40,40,80,94,55,170,227,35,232,215,172,22,96,71,174,6,100,33,56,153,231,59,56,56,232,114,183,58,155,133,193,167,86,95,31,223,147,138,240,253,231,80,71,236,200,213,192,65,106,190,229,111,187,99,117,188,174,170,170,170,36,53,53,149,237,64,160,220,188,123,51,249,139,8,122,192,74,86,82,82,194,65,119,18,146,213,214,50,67,43,242,142,102,104,90,39,87,87,149,195,14,222,94,102,175,255,66,12,143,145,87,48,31,191,128,46,102,134,151,216,19,25,25,169,7,220,213,240,244,244,20,94,92,85,236,38,54,147,63,100,16,223,109,230,243,209,70,255,27,29,21,21,165,13,11,
208,12,234,123,198,6,108,165,100,197,199,199,75,67,67,131,36,37,37,41,95,129,255,32,220,102,49,135,135,135,178,185,185,41,59,59,59,74,246,91,90,90,210,104,60,52,131,218,76,158,6,223,35,32,175,179,179,147,253,186,32,117,74,92,92,156,132,133,133,9,203,42,225,225,225,161,148,79,86,181,163,163,35,225,195,131,69,198,66,126,135,175,13,208,95,25,140,177,203,189,134,221,61,141,62,30,20,31,224,113,128,114,28,208,255,84,88,87,249,14,88,6,230,0,190,171,46,110,42,52,136,185,22,46,196,0,15,216,97,64,2,144,5,228,1,133,64,9,240,6,144,3,164,3,207,1,247,1,227,88,109,74,7,253,55,0,0,0,255,255,3,0,20,239,73,40,29,103,81,229,0,0,0,0,73,69,78,68,174,66,96,130);

default_pin128//part image
:array[0..1400] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,26,0,0,0,32,8,6,0,0,0,12,171,104,5,0,0,5,64,73,68,65,84,120,1,180,86,91,72,156,87,16,158,255,95,111,89,21,219,64,193,186,154,136,4,137,193,135,234,86,139,119,45,4,146,32,13,17,19,44,177,210,80,83,26,47,8,90,132,86,141,20,35,168,172,96,90,72,138,40,136,82,105,46,125,240,65,83,10,38,145,98,180,32,106,30,52,146,188,196,32,86,11,250,96,188,36,70,179,253,190,127,247,255,247,166,219,134,166,3,223,158,57,51,115,102,254,57,51,231,156,149,221,221,29,233,232,232,16,17,197,9,12,255,3,169,244,185,187,187,235,116,109,247,19,66,17,197,65,38,14,142,15,243,99,238,165,82,119,118,118,100,104,232,142,151,216,53,133,207,3,64,18,92,87,67,122,21,232,1,190,199,252,107,200,63,4,204,152,255,35,169,179,179,179,50,55,55,231,101,168,125,125,48,156,156,134,98,24,248,3,176,1,149,38,147,169,24,99,5,208,6,60,0,238,195,174,16,8,6,191,47,153,210,210,210,164,191,191,95,236,118,215,182,97,81,4,86,180,3,45,161,161,161,135,79,158,60,105,170,168,168,80,234,234,234,
164,180,180,84,46,92,184,32,41,41,41,74,80,80,144,105,113,113,209,242,242,229,203,2,216,198,96,221,40,198,77,192,135,212,203,151,27,157,53,114,4,130,113,24,172,122,129,47,115,114,114,2,110,220,184,33,125,125,125,114,233,210,37,225,71,165,166,166,106,227,197,139,23,165,183,183,87,110,222,188,41,199,143,31,15,128,253,231,192,207,88,255,142,136,86,122,76,93,164,62,123,246,204,152,193,136,11,90,128,252,179,103,207,42,61,61,61,114,226,196,9,9,11,11,99,35,24,118,100,56,55,155,205,12,34,221,221,221,114,254,252,121,26,124,12,216,20,197,30,68,27,119,114,134,54,182,45,29,202,47,146,147,147,213,166,166,38,57,116,232,144,71,128,215,175,95,203,214,214,150,91,151,58,92,89,44,22,185,114,229,138,164,167,167,51,216,103,64,158,67,227,250,53,114,116,102,83,141,125,15,169,173,173,149,35,71,142,24,86,108,255,199,143,31,75,87,87,151,84,85,85,201,245,235,215,229,225,195,135,242,234,213,43,195,38,38,38,70,106,106,106,152,37,179,169,134,191,64,67,9,6,129,140,108,222,195,60,251,216,177,99,130,218,24,153,
176,73,134,135,135,37,55,55,87,171,19,183,137,193,50,50,50,180,38,98,150,36,110,101,94,94,158,36,38,38,114,154,6,88,200,232,100,100,4,193,7,64,24,186,73,14,30,60,168,235,101,117,117,85,154,155,155,101,121,121,217,144,145,225,22,182,180,180,136,123,141,89,203,204,204,76,170,15,0,86,50,58,185,7,122,31,66,53,62,62,94,84,213,37,126,244,232,145,76,79,79,235,246,30,35,183,147,231,80,39,102,117,244,232,81,78,233,32,74,151,235,2,125,206,61,85,130,131,61,207,29,111,142,23,47,94,232,54,62,35,51,211,207,32,3,133,132,132,208,134,77,225,93,35,99,237,60,184,221,169,169,41,209,247,157,154,184,184,56,253,43,13,67,157,97,183,113,7,24,128,196,117,19,19,19,100,121,121,62,37,163,147,107,143,68,38,33,92,167,161,123,61,162,163,163,165,172,172,76,183,247,24,121,75,36,36,36,24,178,149,149,21,25,29,29,229,156,183,131,22,81,87,242,128,234,180,10,230,87,220,123,159,178,38,81,81,81,218,151,178,94,197,197,197,194,246,29,28,28,148,145,145,17,177,90,173,114,234,212,41,13,1,1,46,23,92,55,51,51,67,127,247,129,
69,50,58,57,114,118,206,176,5,159,128,253,165,168,168,40,128,109,236,220,111,221,86,54,55,55,101,109,109,77,112,255,73,120,120,184,33,39,179,189,189,45,149,149,149,60,107,220,182,18,212,173,223,221,192,125,235,40,191,7,60,185,123,247,174,118,32,221,13,201,243,202,137,140,140,244,9,66,29,187,115,104,104,136,44,107,173,49,156,232,228,157,17,231,229,192,213,242,242,114,181,189,189,93,2,3,61,154,71,95,231,49,242,230,104,104,104,144,214,214,86,158,222,111,129,54,100,100,220,4,52,246,8,164,9,20,229,93,140,19,168,81,220,192,192,128,224,222,163,216,47,241,44,229,231,231,203,252,252,60,235,98,69,140,37,239,5,123,5,162,172,6,104,197,211,160,218,108,54,159,90,185,59,225,125,87,95,95,47,176,99,6,77,192,119,8,228,184,151,220,12,125,2,81,135,166,192,155,34,15,112,21,37,220,186,117,203,227,238,115,91,171,177,227,227,227,82,80,80,192,35,241,20,130,143,16,228,47,111,27,206,247,11,68,121,9,208,93,88,88,104,234,236,236,148,136,8,62,186,158,180,190,190,174,117,26,30,64,118,90,37,240,35,2,121,212,
70,95,177,103,32,42,145,85,40,134,223,208,226,233,124,0,17,208,184,1,168,167,63,214,176,164,164,68,54,54,54,120,216,115,33,123,78,221,94,180,111,32,26,35,88,46,134,193,164,164,36,243,237,219,183,37,54,54,22,83,7,225,191,130,156,59,119,78,198,198,198,248,40,157,70,144,253,255,74,193,192,228,92,183,231,128,64,11,80,88,150,150,150,172,56,160,74,118,118,182,118,179,179,157,175,93,187,198,255,18,220,166,159,128,14,192,167,1,32,51,200,111,70,180,66,176,195,24,126,199,65,141,225,31,17,60,215,50,57,57,169,53,192,194,194,194,159,208,229,32,155,39,180,245,71,255,38,16,109,190,2,126,56,115,230,140,169,173,173,77,26,27,27,249,186,178,1,190,1,108,8,180,103,3,64,247,102,132,172,204,192,61,252,159,176,103,101,101,217,209,32,118,204,199,1,54,204,219,37,56,77,6,86,1,6,121,14,100,188,221,8,78,111,112,172,2,13,192,6,208,12,248,109,164,255,244,17,112,30,8,196,115,124,83,71,127,3,0,0,255,255,3,0,21,188,178,144,80,26,171,219,0,0,0,0,73,69,78,68,174,66,96,130);

default_no128
:array[0..2521] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,9,161,73,68,65,84,120,1,236,92,139,113,227,54,16,37,117,141,40,141,196,112,174,143,156,61,233,35,150,82,72,198,87,72,98,40,141,68,110,228,148,125,16,65,2,11,128,146,77,138,88,42,187,51,20,62,4,192,197,219,135,197,135,146,154,70,69,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,20,1,69,64,17,80,4,214,129,64,187,14,53,167,106,185,217,13,45,156,30,134,120,99,186,184,29,242,218,195,57,254,195,231,249,112,40,114,71,177,59,37,128,55,248,233,101,6,91,117,4,56,237,169,173,46,62,67,171,66,154,184,35,2,204,106,244,49,243,16,9,238,135,12,95,198,122,186,146,123,166,105,54,79,100,20,140,118,138,223,92,182,77,211,62,209,101,232,73,239,116,29,233,90,173,172,220,3,96,212,95,118,243,47,47,191,247,
6,50,198,4,241,243,114,192,218,67,159,103,173,117,241,195,225,159,198,199,251,155,249,8,85,88,175,71,88,41,1,46,27,222,27,125,183,155,182,12,0,57,246,251,63,156,233,199,9,209,238,155,230,199,46,207,17,185,185,43,36,64,251,70,112,154,28,164,115,25,61,215,54,242,60,25,70,136,96,201,27,60,150,234,75,204,95,211,26,192,208,188,251,47,129,184,229,64,194,173,127,251,246,107,131,209,30,186,120,94,110,106,122,187,221,54,79,79,223,220,51,222,223,223,155,227,241,200,155,220,174,109,109,176,18,15,80,118,249,24,245,215,184,249,221,110,239,140,133,185,29,18,142,226,144,52,15,15,63,247,36,50,230,188,70,112,21,50,31,227,30,193,121,2,155,169,38,42,107,5,4,200,27,255,26,195,195,232,126,254,254,12,234,158,24,120,214,24,25,30,31,191,70,132,26,158,37,127,93,32,156,0,31,55,190,31,233,83,12,63,24,112,136,129,12,99,68,40,147,77,54,9,36,19,192,208,124,138,5,95,36,99,35,191,108,132,168,137,73,137,49,34,148,159,47,151,4,82,9,96,114,198,127,123,251,59,235,138,203,192,71,182,182,212,230,97,200,113,103,253,
148,231,196,116,33,5,27,67,43,121,76,254,20,150,165,68,68,172,11,30,31,127,201,84,148,185,38,16,74,128,116,171,151,51,126,25,236,16,255,73,163,207,16,105,94,168,53,10,83,129,55,120,123,251,43,185,81,214,235,36,14,111,113,10,117,35,223,132,168,150,70,27,202,44,180,0,35,125,242,68,40,77,9,5,175,100,165,157,19,108,0,162,28,193,162,47,30,109,99,198,135,222,24,129,48,194,141,197,158,13,151,186,113,108,39,225,242,49,234,67,193,214,20,186,51,49,52,197,236,88,94,213,164,36,15,64,224,196,139,190,146,139,205,33,150,247,4,147,220,127,238,49,93,94,58,69,225,70,110,154,202,123,2,57,83,129,32,15,224,92,108,15,122,206,248,24,101,109,251,133,14,126,246,125,57,31,201,123,2,188,40,186,197,136,131,39,0,185,98,201,45,254,242,135,84,183,208,41,214,229,218,148,20,2,24,82,24,87,47,25,247,217,31,234,96,143,95,159,4,120,241,147,35,193,215,190,15,62,146,246,101,177,87,215,94,133,98,40,132,0,233,232,231,39,111,48,56,230,91,47,82,73,0,29,57,57,243,239,40,54,198,247,165,102,40,129,0,0,2,87,47,124,196,192,
245,231,78,246,164,146,0,122,241,69,33,222,49,196,114,171,233,41,126,202,165,148,0,2,92,30,253,57,227,251,142,201,33,65,99,189,78,8,67,111,133,116,97,87,128,91,85,69,0,1,46,143,126,14,38,71,76,6,9,194,83,198,198,121,44,62,21,112,189,105,107,137,67,166,170,82,155,0,38,236,61,86,254,124,238,207,140,126,155,59,76,169,79,130,116,81,232,95,61,251,62,74,220,17,84,38,64,236,254,61,80,62,196,60,154,142,126,255,253,59,119,40,227,139,186,80,0,9,108,168,16,116,231,107,1,190,190,9,203,215,136,87,38,64,220,101,14,78,126,244,247,115,173,21,232,9,72,167,120,107,152,18,56,238,115,237,105,160,38,1,12,65,129,171,23,238,254,251,27,125,196,141,254,62,69,17,43,144,4,161,126,205,117,211,64,84,101,209,68,77,2,68,29,197,252,31,74,222,253,247,163,63,42,42,139,4,241,55,131,115,30,128,123,186,219,156,86,134,16,149,227,21,9,176,49,161,90,233,62,57,188,235,226,54,201,25,50,232,158,164,53,65,60,13,92,222,13,12,29,89,58,86,145,0,227,93,77,231,255,120,155,149,169,109,101,145,32,163,161,192,172,138,4,136,126,
165,75,219,63,115,1,158,254,215,186,99,229,172,12,18,196,186,242,117,64,218,215,24,139,177,14,206,125,175,34,1,230,238,74,223,158,149,65,130,94,31,209,145,123,36,0,0,183,74,130,235,120,87,147,0,38,84,145,111,1,51,171,103,50,234,135,132,202,87,91,24,210,179,7,225,125,225,125,165,146,102,40,189,108,172,38,1,150,232,169,173,72,130,37,250,55,249,25,53,9,64,198,25,132,31,153,166,11,165,79,143,18,122,206,226,158,192,12,61,75,99,188,175,84,194,166,165,150,201,169,73,128,101,122,120,126,138,173,64,130,190,127,25,50,247,247,106,71,254,47,4,0,206,118,57,18,108,12,61,111,21,82,145,0,241,193,14,95,40,165,39,131,27,51,3,162,118,25,18,140,239,235,121,95,233,5,210,97,134,190,125,170,137,138,4,248,148,190,115,84,178,203,144,96,80,53,61,251,31,238,213,142,137,37,64,250,229,137,89,191,61,115,107,18,152,49,195,242,147,65,250,107,25,210,167,142,84,36,64,252,214,44,61,251,167,205,177,49,12,149,205,142,101,76,73,218,219,120,130,84,71,190,239,79,167,128,41,221,152,86,183,34,1,82,197,249,91,179,116,
29,144,214,153,152,99,231,39,65,236,169,56,137,11,91,64,210,163,142,84,38,64,252,218,148,67,192,193,35,99,21,127,169,203,235,126,32,109,103,36,129,225,207,229,243,127,206,211,241,58,75,166,43,19,32,238,42,7,7,174,51,37,193,198,196,181,102,73,217,121,72,144,254,182,145,187,255,84,219,228,91,78,105,145,27,230,84,38,64,188,14,64,63,47,79,3,240,2,233,60,59,3,70,118,58,9,98,45,248,232,255,192,183,156,226,134,110,152,170,76,0,244,108,124,26,200,255,160,98,124,159,61,1,47,59,23,9,224,185,248,232,231,30,142,244,164,231,213,21,1,4,136,1,0,72,220,11,164,211,64,99,110,228,5,160,140,157,131,4,215,141,254,186,238,31,157,21,240,71,145,39,2,124,211,146,46,134,46,39,109,219,186,63,100,244,105,252,65,35,228,112,136,14,204,204,185,30,234,207,46,71,106,145,30,214,62,133,45,251,231,115,66,226,207,35,177,183,247,127,28,9,227,35,47,148,231,231,223,250,251,93,190,165,112,31,150,169,17,111,107,60,52,243,76,67,96,191,133,249,0,145,31,6,45,251,39,16,78,155,68,47,228,230,116,67,62,244,131,240,255,13,194,
220,159,254,119,128,123,67,105,93,133,138,31,2,60,128,235,253,145,123,1,140,54,78,0,140,170,204,60,106,36,121,2,120,43,239,177,188,93,165,142,126,232,39,133,0,164,10,92,121,187,163,72,36,220,221,34,253,253,251,247,168,12,37,12,213,165,171,73,110,80,222,84,57,82,3,135,107,167,3,110,252,188,215,58,61,83,155,104,183,186,8,34,0,176,136,215,2,185,57,23,0,23,72,176,237,72,240,78,13,29,233,154,83,142,212,216,213,36,240,15,198,98,54,37,43,118,61,167,87,95,166,118,40,140,0,206,11,24,2,101,235,129,25,35,193,251,123,242,143,221,84,15,11,55,231,13,230,36,130,33,114,210,5,79,19,11,244,3,33,249,200,135,241,51,211,149,37,227,63,199,45,212,77,181,117,31,95,122,122,123,226,119,114,255,192,133,50,121,23,219,215,182,4,248,158,82,20,126,70,252,129,83,124,190,239,91,130,225,249,130,15,247,242,139,190,252,246,210,183,85,43,20,230,1,122,24,14,124,206,133,43,205,141,52,191,221,242,158,162,111,225,28,217,118,30,97,119,246,10,155,159,136,16,184,67,249,238,58,82,232,197,80,100,75,35,253,137,194,23,42,255,
74,161,233,46,10,98,193,78,224,245,245,207,56,147,82,5,227,211,29,57,243,126,168,116,27,38,100,197,49,250,210,145,87,218,130,1,120,184,220,91,191,106,45,61,31,216,21,220,62,221,145,177,229,131,142,92,164,122,0,210,51,61,32,130,242,126,164,195,27,132,130,57,24,222,0,249,153,181,65,88,244,83,113,24,30,71,187,124,107,234,27,43,27,95,214,162,207,235,235,67,193,30,192,171,152,247,4,48,116,110,254,245,181,188,71,64,122,138,87,24,27,241,254,89,227,198,79,95,120,249,122,18,194,21,16,192,193,100,104,78,142,78,10,145,11,18,248,145,233,74,21,62,64,6,8,136,16,126,29,43,36,6,218,130,248,47,161,148,70,186,43,212,125,148,13,143,2,24,249,178,141,239,180,236,250,178,134,192,16,168,180,56,107,40,140,229,90,34,196,181,62,159,130,225,65,164,144,64,113,107,114,231,252,88,79,66,148,103,200,79,231,255,168,25,122,223,154,8,48,60,36,179,191,119,249,244,97,187,5,159,79,139,15,87,72,0,96,154,95,23,120,180,189,59,191,102,122,240,117,74,225,21,70,239,170,174,195,229,243,126,174,148,0,174,27,166,52,37,240,
78,130,16,126,110,247,228,64,25,255,133,13,191,70,64,94,232,214,71,70,58,138,118,178,78,195,247,218,251,200,138,67,115,45,17,230,237,163,51,188,165,54,113,173,86,214,236,1,56,232,102,25,34,192,240,16,249,43,252,179,158,227,159,247,68,128,176,167,166,35,3,242,40,62,85,238,203,232,33,26,247,74,128,176,143,230,156,216,116,97,244,133,210,46,47,116,227,225,15,53,239,99,148,159,251,175,159,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,160,8,40,2,138,128,34,176,110,4,254,3,0,0,255,255,3,0,17,164,48,165,115,135,28,171,0,0,0,0,73,69,78,68,174,66,96,130);

default_alt128
:array[0..849] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,3,25,73,68,65,84,120,1,236,156,1,78,194,64,20,68,183,224,65,188,137,61,153,20,79,162,39,177,245,96,224,150,128,49,96,227,148,2,237,206,127,155,212,74,252,150,157,55,47,64,82,99,74,44,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,148,71,160,250,76,169,63,226,174,85,220,232,135,226,235,156,63,31,113,37,8,42,192,79,249,39,255,195,74,16,80,128,139,242,67,75,16,76,128,193,242,195,74,16,72,128,203,242,55,155,215,212,31,103,171,142,244,153,96,125,22,222,244,225,223,229,55,205,38,213,117,238,59,175,174,235,14,231,227,151,231,44,65,157,191,255,56,62,182,61,5,16,96,184,252,83,171,145,37,48,23,224,255,242,163,75,96,44,128,94,126,100,9,76,5,24,95,126,84,9,12,5,184,190,252,136,18,152,9,48,189,252,104,18,24,9,112,187,242,35,73,96,34,192,237,203,143,34,129,129,0,247,43,63,130,4,133,
11,112,255,242,221,37,40,88,128,199,149,239,44,65,161,2,60,190,124,87,9,10,20,96,190,242,29,37,40,76,128,249,203,119,147,160,52,1,222,79,5,244,231,254,94,126,127,75,119,174,53,124,23,49,109,231,218,211,216,231,45,250,15,66,182,219,183,84,85,235,81,71,211,12,119,211,255,108,236,245,250,61,148,188,138,22,160,100,240,75,217,59,2,44,165,137,153,246,129,0,51,129,95,202,211,62,45,101,35,218,62,246,149,54,247,123,106,213,164,180,191,242,147,98,149,63,48,236,242,239,251,46,94,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,
149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,8,1,124,187,149,146,33,128,132,201,119,168,176,127,23,63,189,136,174,251,74,109,219,77,191,144,201,21,194,9,208,182,109,22,160,53,169,111,122,12,222,2,166,51,44,250,10,8,80,116,125,211,55,31,224,45,96,215,166,84,189,76,71,197,21,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,176,32,2,223,0,0,0,255,255,3,0,124,75,164,240,85,17,166,253,0,0,0,0,73,69,78,68,174,66,96,130);

default_wait128
:array[0..1267] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,4,187,73,68,65,84,120,1,236,156,1,114,219,32,16,69,237,182,7,243,201,26,167,39,107,14,214,170,222,164,154,145,17,178,140,44,224,239,234,49,147,137,101,4,44,239,127,1,70,178,79,39,18,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,209,8,156,117,58,116,30,116,98,105,17,201,32,193,254,91,139,174,210,134,46,1,12,160,171,77,147,200,48,64,19,204,186,141,252,80,13,109,24,254,168,134,182,41,174,243,249,251,166,114,181,11,49,2,212,38,44,94,63,6,16,23,168,118,120,24,160,54,97,241,250,101,215,0,170,115,166,184,158,197,225,49,2,20,35,139,85,0,3,196,210,179,184,55,24,160,24,89,172,2,18,251,209,121,164,247,247,6,188,237,11,204,215,48,26,123,255,41,107,70,128,148,200,193,142,49,192,193,4,79,187,139,1,82,34,7,59,118,107,0,155,99,167,127,169,110,211,188,249,124,124,186,43,91,35,63,141,71,245,216,173,1,84,129,122,139,11,3,120,83,108,231,120,49,192,206,
64,189,85,39,123,47,96,13,100,186,47,144,206,227,173,243,215,226,85,205,103,4,80,85,166,81,92,24,160,17,104,213,102,48,128,170,50,141,226,114,187,6,72,249,48,231,167,68,158,59,118,51,2,92,175,239,207,245,72,224,44,79,177,186,25,1,222,223,127,125,74,123,189,190,9,72,188,28,130,137,63,198,186,124,150,78,142,240,8,112,158,93,242,6,86,249,234,90,22,127,222,23,21,11,8,63,15,96,136,190,93,79,167,97,118,201,191,189,253,188,25,97,246,246,67,166,175,238,19,60,172,252,150,249,88,252,191,183,126,104,38,225,17,192,128,25,184,249,213,163,54,18,120,21,223,8,139,27,192,66,212,54,129,103,241,157,24,64,215,4,222,197,55,178,226,107,0,11,113,154,218,173,9,166,173,230,94,71,16,223,250,229,96,10,152,226,215,152,14,162,136,239,208,0,22,114,95,19,68,18,223,169,1,250,153,32,154,248,70,210,217,26,192,66,158,166,253,214,4,211,90,115,175,35,138,111,253,212,252,213,130,156,2,217,247,134,223,183,101,140,153,248,50,205,254,248,248,248,60,188,92,238,222,158,158,82,244,58,170,248,6,193,185,1,172,11,117,77,16,
89,252,32,6,168,103,130,232,226,7,50,192,254,38,56,130,248,70,205,249,34,208,186,144,166,252,194,48,125,96,36,45,149,30,167,55,143,190,242,237,190,132,125,12,141,147,156,109,4,61,3,62,191,79,240,76,201,199,231,196,19,223,250,27,208,0,214,173,26,87,105,141,58,45,214,190,41,168,1,214,161,218,16,63,253,91,47,17,243,140,195,26,32,166,156,229,189,194,0,229,204,66,149,192,0,161,228,44,239,140,155,167,130,203,187,246,184,68,233,199,194,199,181,249,205,13,58,2,216,94,192,222,169,70,157,123,199,88,94,95,64,3,228,55,130,202,209,164,37,236,233,228,120,38,8,102,128,188,248,246,24,121,105,202,151,137,103,130,64,6,88,22,63,247,29,130,233,30,64,110,219,215,202,28,193,4,65,12,80,38,254,179,163,193,17,76,16,192,0,117,196,31,77,18,221,4,206,13,80,87,252,35,152,192,241,237,224,125,197,79,215,1,185,125,130,136,207,8,56,29,1,246,21,127,188,210,215,254,71,156,14,28,26,160,143,248,163,57,162,153,192,153,1,250,138,31,209,4,142,214,0,26,226,143,38,176,255,17,214,4,78,30,11,215,19,223,12,48,126,239,96,
252,30,130,189,247,63,93,190,190,175,96,143,172,107,39,7,6,208,20,127,148,213,187,9,196,13,160,45,126,4,19,8,47,2,247,21,127,109,239,127,45,127,20,123,233,191,215,79,7,194,6,216,231,199,161,150,4,171,241,254,99,19,212,104,241,245,58,133,13,112,223,185,45,191,12,118,95,67,155,163,101,19,180,105,191,180,21,55,6,48,176,94,146,167,88,195,62,19,184,182,183,255,106,190,23,51,174,197,233,102,4,88,235,8,249,219,8,96,128,109,220,194,148,194,0,97,164,220,214,145,48,107,128,87,231,244,87,203,111,195,223,191,20,35,64,127,13,186,70,128,1,186,226,239,223,56,6,232,175,65,215,8,220,174,1,94,157,179,107,151,239,170,106,65,227,140,0,5,176,34,158,138,1,34,170,90,208,39,12,80,0,43,226,169,194,207,4,158,135,41,240,220,115,250,211,124,181,215,233,26,227,246,139,166,146,172,25,1,212,156,211,56,30,12,208,24,184,90,115,24,64,77,145,198,241,8,205,75,247,115,126,99,14,29,154,211,88,19,48,2,116,144,94,169,73,12,160,164,70,135,88,48,64,7,232,74,77,202,222,11,240,246,185,127,77,212,249,190,192,90,137,54,249,
140,0,109,56,203,182,130,1,100,165,105,19,24,6,104,195,89,182,21,217,53,128,234,156,41,171,228,198,192,24,1,54,130,139,82,12,3,68,81,114,99,63,48,192,70,112,20,131,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,170,4,254,1,0,0,255,255,3,0,71,116,163,156,100,244,253,250,0,0,0,0,73,69,78,68,174,66,96,130);


//------------------------------------------------------------------------------
//128px hollow cursors ---------------------------------------------------------
//------------------------------------------------------------------------------

default_arrow128H
:array[0..1399] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,5,63,73,68,65,84,120,1,236,157,11,146,171,54,16,69,141,147,133,76,86,18,101,101,111,178,146,228,173,36,157,157,100,37,113,250,82,240,34,4,70,178,249,9,230,168,74,70,18,178,212,125,250,186,241,103,138,185,221,40,16,128,0,4,58,2,247,79,80,124,105,2,205,227,118,67,4,95,73,2,247,177,179,143,111,136,96,76,229,170,35,19,2,144,171,136,224,170,1,79,253,122,34,0,68,144,130,186,106,127,70,0,136,224,170,65,143,253,202,8,0,17,196,176,174,216,46,16,0,34,184,98,224,123,159,10,5,128,8,122,96,87,59,230,4,96,67,135,249,116,48,228,113,254,94,70,0,143,223,220,69,27,186,137,8,134,60,206,221,203,8,64,206,61,126,31,187,136,8,198,76,206,57,82,32,0,101,128,54,19,36,30,34,130,4,200,41,187,37,2,144,99,134,8,78,25,223,172,209,165,2,208,66,134,8,178,60,79,55,225,21,1,200,57,67,4,167,139,241,172,193,175,10,64,139,25,34,152,101,122,170,147,239,8,64,14,26,34,56,85,156,159,26,251,174,0,180,160,33,130,167,92,79,115,
98,137,0,228,164,33,130,211,196,122,210,208,165,2,208,162,134,8,38,217,158,98,112,13,1,200,81,67,4,167,136,247,200,200,181,4,160,133,13,17,140,248,86,63,176,166,0,228,172,33,130,234,99,62,48,112,109,1,104,113,67,4,3,198,85,119,182,16,128,28,54,68,80,117,220,127,24,183,149,0,180,129,33,130,31,156,171,109,108,41,0,57,109,136,160,218,216,183,134,109,45,0,109,98,136,160,101,93,229,195,30,2,144,227,134,8,170,140,255,109,47,1,32,130,58,227,191,171,0,16,65,133,34,216,51,3,244,238,27,151,131,30,197,241,199,35,4,32,175,13,17,28,31,124,89,112,148,0,180,183,33,2,97,56,182,28,41,0,121,110,136,224,107,11,0,17,28,27,255,67,47,1,177,235,70,38,136,113,236,215,62,250,18,16,123,138,8,98,26,59,181,107,18,128,92,54,50,193,78,145,239,182,169,77,0,50,203,16,65,23,157,29,14,53,10,64,110,27,34,216,33,250,190,69,173,2,144,247,134,8,132,97,219,82,179,0,228,185,33,130,175,45,0,68,176,109,252,171,190,4,196,174,27,153,32,198,177,94,187,246,75,64,236,41,34,136,105,172,212,62,147,0,228,178,145,9,86,138,124,
183,204,207,235,46,87,180,90,40,154,53,59,169,241,27,87,233,30,69,113,105,239,89,228,3,255,126,198,163,180,231,9,28,32,128,70,129,11,243,102,229,206,250,191,53,152,44,136,96,18,203,204,224,1,151,128,169,219,206,205,88,248,242,41,238,94,246,10,178,53,5,16,124,99,213,92,49,159,160,186,97,65,4,165,112,215,186,4,132,219,173,249,203,55,53,191,54,123,205,21,101,129,38,36,179,44,233,47,236,62,126,245,5,130,87,243,74,121,66,96,13,1,132,46,248,218,194,219,69,208,205,231,169,6,175,81,153,186,33,101,116,154,230,234,4,238,11,87,12,81,240,187,165,218,55,121,5,203,142,222,11,248,90,169,32,10,150,97,202,34,2,75,4,16,198,193,111,109,241,241,162,64,154,207,83,141,74,169,120,162,167,208,92,68,224,93,1,132,39,193,239,140,41,13,36,89,96,81,244,86,120,242,59,2,200,4,191,181,202,231,20,21,243,89,170,81,41,21,79,244,20,154,111,19,120,85,0,97,250,149,175,111,230,210,64,222,63,203,172,34,11,148,113,218,102,214,43,2,8,207,131,175,175,95,211,64,234,179,120,81,49,159,165,26,21,178,64,4,99,211,102,169,0,
194,124,240,91,27,205,31,85,163,66,22,136,96,84,217,252,105,104,85,243,57,236,223,60,181,183,65,252,35,25,247,174,210,126,250,195,203,253,23,63,17,162,185,106,235,242,144,43,255,248,122,193,39,125,120,237,74,243,225,141,239,93,135,195,70,4,50,25,64,193,159,74,229,83,193,151,133,169,32,52,70,22,16,133,90,75,46,3,132,177,225,207,130,223,207,188,55,222,138,159,167,54,89,192,33,212,88,50,25,32,53,57,23,124,205,39,11,164,212,106,238,231,50,64,100,123,73,240,251,233,100,129,158,68,237,199,194,12,240,74,240,229,242,146,44,208,252,157,64,11,222,87,165,108,64,160,32,3,188,26,252,222,202,81,22,208,137,153,119,245,237,155,69,253,164,28,52,113,88,154,15,239,207,60,119,56,155,94,57,129,76,6,120,55,248,50,96,148,5,130,15,170,38,69,129,111,30,211,159,54,250,169,163,172,208,159,224,184,144,192,76,6,208,111,243,143,63,151,173,159,102,129,230,195,215,235,94,201,115,175,248,126,87,9,176,181,195,250,17,142,235,18,104,134,203,233,149,168,210,254,97,134,181,205,197,15,253,154,253,66,109,80,191,245,
189,233,227,146,204,51,189,34,163,211,4,38,4,176,102,240,181,105,251,167,98,97,122,251,116,148,192,167,68,182,238,39,2,104,175,209,182,242,166,161,19,193,204,178,4,126,6,206,166,167,82,1,108,180,217,179,44,64,224,55,2,94,188,236,78,2,80,102,105,69,208,25,70,224,139,35,116,157,137,18,64,233,15,67,215,241,26,79,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,252,79,224,63,0,0,0,255,255,3,0,175,171,65,88,236,4,183,148,0,0,0,0,73,69,78,68,174,66,96,130);

default_work128H//part image and square (w=h) to enable rotation
:array[0..736] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,48,0,0,0,48,8,6,0,0,0,87,2,249,135,0,0,2,168,73,68,65,84,120,1,236,152,187,110,220,64,12,69,119,243,0,12,187,13,224,86,72,23,3,254,178,52,54,144,111,200,7,218,8,210,110,109,23,105,18,167,10,148,123,132,225,66,146,103,37,13,103,164,117,49,4,46,52,47,146,151,156,151,164,221,174,74,205,64,205,64,205,64,205,64,70,6,246,30,221,253,126,223,122,244,230,116,218,182,77,230,243,97,206,232,76,255,139,250,115,131,129,244,229,140,159,147,221,57,1,64,190,17,120,230,8,228,15,130,43,136,119,57,158,223,130,110,206,12,88,230,206,186,132,188,51,240,71,217,103,233,16,196,149,144,188,249,130,14,186,216,192,22,54,147,197,59,3,215,242,100,51,128,211,70,72,221,11,185,250,248,245,139,142,210,43,225,119,0,229,157,112,25,64,121,174,62,208,247,50,241,206,64,204,223,56,163,140,57,132,129,77,120,142,235,161,217,255,240,238,129,41,143,118,174,19,144,103,111,76,217,126,213,87,98,6,222,203,234,103,225,81,104,4,136,255,20,144,47,2,123,195,246,71,163,50,66,253,
86,64,247,159,176,189,104,141,95,8,15,66,43,252,16,110,4,91,247,79,42,63,11,159,4,246,197,145,32,101,129,177,232,160,139,141,139,227,128,173,10,114,58,38,50,14,2,242,4,65,48,204,10,227,79,234,108,197,123,224,103,138,16,164,5,200,119,1,76,141,29,24,221,186,18,33,214,45,137,208,78,16,128,204,71,151,220,214,124,163,254,2,193,91,61,255,10,220,13,177,123,193,206,125,198,48,54,106,235,108,141,129,116,255,98,35,243,44,31,64,217,2,232,2,44,69,116,141,123,160,20,183,69,118,138,4,160,236,226,140,187,128,115,221,132,179,190,9,176,123,128,190,238,222,8,58,212,207,43,16,17,110,132,201,115,93,253,111,111,19,71,200,31,239,130,113,90,83,198,142,117,87,169,207,17,10,253,108,94,208,113,152,211,89,133,232,41,163,34,51,185,36,2,241,39,61,65,119,19,99,75,229,69,75,238,148,223,98,237,34,98,199,226,224,92,15,4,201,186,189,74,60,135,242,120,38,6,247,70,49,98,75,13,245,2,24,156,235,106,135,40,89,55,226,22,8,109,253,153,176,4,12,244,151,250,183,113,69,142,81,140,137,28,128,32,136,93,179,180,17,28,80,177,
140,148,248,30,48,38,16,63,8,176,227,59,0,233,127,23,88,157,191,24,13,149,18,226,154,1,101,208,254,38,64,22,64,158,182,88,187,205,200,228,184,96,83,38,210,164,127,115,46,214,148,179,95,26,124,47,64,238,163,240,85,184,203,172,127,147,254,119,33,73,200,74,178,40,0,251,153,197,43,130,149,147,237,4,5,155,153,221,214,63,119,237,93,167,255,158,227,9,194,246,14,207,100,113,237,129,100,47,43,42,228,156,66,150,185,98,75,200,19,103,78,0,248,115,77,187,135,104,213,169,25,168,25,168,25,168,25,88,37,3,255,1,0,0,255,255,3,0,18,80,139,88,238,206,56,243,0,0,0,0,73,69,78,68,174,66,96,130);

default_cross128H
:array[0..733] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,2,165,73,68,65,84,120,1,236,219,209,74,235,0,20,68,81,189,248,255,191,236,125,20,10,5,35,237,206,164,93,62,41,173,57,147,117,134,36,47,249,248,240,67,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,192,245,4,62,175,23,249,175,137,63,191,143,253,231,247,91,216,252,59,134,226,219,175,38,160,0,175,182,209,131,231,163,0,7,193,94,237,235,95,175,118,66,191,63,159,219,123,252,209,103,132,223,79,90,254,166,43,192,242,118,130,108,10,16,32,47,143,80,128,229,237,4,217,20,32,64,94,30,161,0,203,219,9,178,41,64,128,188,60,66,1,150,183,19,100,83,128,0,121,121,132,2,44,111,39,200,166,0,1,242,242,8,5,88,222,78,144,77,1,2,228,229,17,10,176,188,157,32,155,2,4,200,203,35,20,96,121,59,65,54,5,8,144,151,71,40,192,242,118,130,108,10,16,32,47,143,80,128,229,237,4,217,20,32,64,94,30,161,0,203,219,9,178,41,64,128,188,
60,66,1,150,183,19,100,83,128,0,121,121,132,2,44,111,39,200,166,0,1,242,242,8,5,88,222,78,144,45,124,55,240,106,239,222,157,157,247,246,221,197,231,180,193,21,224,57,174,151,57,170,2,92,102,85,207,9,170,0,207,113,189,204,81,195,103,128,91,147,230,30,119,59,245,254,223,103,231,57,231,153,195,21,224,126,35,222,226,19,5,120,139,53,223,63,73,5,184,111,243,22,159,156,248,12,112,206,61,239,103,171,183,247,252,179,243,252,36,43,127,115,5,40,181,7,103,41,192,224,82,202,72,10,80,106,15,206,10,159,1,110,239,185,181,198,209,123,252,217,121,27,31,87,128,198,121,118,138,2,204,174,166,9,166,0,141,243,236,20,5,152,93,77,19,76,1,26,231,217,41,10,48,187,154,38,152,2,52,206,179,83,20,96,118,53,77,48,5,104,156,103,167,40,192,236,106,154,96,10,208,56,207,78,81,128,217,213,52,193,20,160,113,158,157,162,0,179,171,105,130,41,64,227,60,59,69,1,102,87,211,4,83,128,198,121,118,138,2,204,174,166,9,166,0,141,243,236,20,5,152,93,77,19,76,1,26,231,217,41,10,48,187,154,38,152,2,52,206,179,83,20,96,118,53,77,
48,5,104,156,103,167,40,192,236,106,154,96,10,208,56,207,78,9,223,13,92,51,56,250,174,224,90,254,199,228,113,5,120,140,227,101,143,162,0,151,93,221,99,130,43,192,99,28,29,133,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,161,192,127,0,0,0,255,255,3,0,0,3,17,164,114,170,1,230,0,0,0,0,73,69,78,68,174,66,96,130);

default_help128H//part image
:array[0..931] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,32,8,6,0,0,0,31,124,40,241,0,0,3,107,73,68,65,84,120,1,124,149,59,104,84,65,20,134,239,222,44,10,106,180,8,248,88,139,68,19,65,16,163,133,41,4,11,21,98,44,124,33,130,8,65,20,226,3,73,101,140,104,108,20,212,128,241,177,149,104,26,55,65,162,96,74,5,19,81,193,148,10,62,10,171,4,172,162,177,49,176,198,247,222,245,251,231,177,142,187,171,63,252,123,206,156,153,57,115,206,153,51,119,83,197,98,49,178,176,50,142,107,234,24,103,96,26,214,218,185,40,143,252,4,39,147,228,215,15,107,139,221,148,21,90,108,128,131,54,148,99,112,25,172,230,104,26,251,100,28,167,251,145,35,73,146,188,71,150,16,131,22,248,16,139,184,3,174,134,138,106,1,212,177,162,244,122,184,30,222,130,3,236,57,11,103,161,27,104,81,22,42,26,143,55,40,125,176,11,238,114,148,62,0,63,64,161,21,246,192,189,26,8,41,240,10,185,6,106,81,7,33,63,136,34,95,55,44,37,221,214,68,145,96,60,13,125,52,43,146,164,48,110,103,177,2,229,60,198,194,102,234,213,13,251,45,211,7,168,203,
18,179,194,254,92,68,244,6,227,171,210,75,197,70,95,12,137,38,218,0,67,28,98,48,193,1,167,56,121,152,136,117,107,170,143,210,157,7,27,56,176,46,140,72,167,150,59,193,100,208,200,111,150,13,77,110,44,49,234,244,12,50,35,71,41,103,144,248,2,159,64,133,187,214,241,2,178,0,151,194,85,208,227,181,87,36,149,218,8,108,134,83,80,105,60,38,5,28,90,255,164,48,31,155,138,91,14,31,93,158,137,188,28,93,131,111,225,24,249,79,32,29,74,55,183,29,131,34,87,109,62,70,81,226,230,77,77,165,127,131,95,211,180,188,110,43,103,215,162,5,160,38,71,25,170,219,133,73,168,181,17,183,184,5,209,42,29,228,240,49,69,68,97,189,237,12,233,204,69,219,9,47,67,233,51,240,8,27,222,225,100,19,250,32,20,100,127,41,69,169,149,193,164,116,5,99,59,244,78,14,227,100,212,69,34,39,139,220,166,46,217,165,87,132,67,58,58,81,79,67,78,116,1,187,89,60,132,19,213,42,116,50,196,248,182,117,17,87,58,98,242,14,212,137,114,178,47,136,228,174,179,35,162,27,144,40,19,165,102,16,68,148,80,196,120,63,86,31,182,218,224,41,145,172,196,166,
72,230,64,109,60,9,79,132,78,24,135,53,50,125,163,14,246,184,238,148,131,72,239,156,154,20,110,250,30,243,11,37,131,136,140,89,111,199,67,141,38,52,89,17,141,35,239,87,115,162,249,114,71,110,143,17,157,20,94,183,167,158,17,76,7,91,181,242,183,220,145,190,73,30,122,46,199,161,143,178,30,93,172,138,160,143,76,141,84,23,117,172,239,218,112,211,51,6,166,179,67,163,215,83,127,254,69,188,137,124,227,120,57,35,245,145,162,249,12,83,220,146,62,193,255,68,121,106,44,52,143,82,5,238,132,89,199,173,200,255,34,72,205,190,106,250,230,18,59,244,80,21,145,199,102,162,84,189,182,17,217,11,111,12,229,95,17,185,183,212,205,2,239,36,248,172,152,94,58,31,110,14,245,146,35,156,72,63,19,76,170,131,245,239,162,111,249,115,103,111,35,50,217,42,16,164,102,254,158,107,221,138,9,58,184,207,54,95,50,195,33,57,236,45,110,142,238,79,248,204,150,98,48,230,112,244,19,139,190,205,66,35,205,216,206,233,245,56,89,199,184,195,88,237,79,133,19,153,131,235,47,114,237,53,123,176,221,179,235,163,239,72,245,205,66,168,
7,43,60,162,216,190,211,173,197,253,6,169,165,34,22,13,19,197,57,230,122,224,108,216,0,61,116,91,186,205,170,8,83,243,11,122,81,54,194,65,71,117,187,187,250,130,30,110,85,252,6,0,0,255,255,3,0,149,34,232,17,219,6,204,22,0,0,0,0,73,69,78,68,174,66,96,130);

default_text128H
:array[0..764] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,2,196,73,68,65,84,120,1,236,221,65,82,195,64,12,4,64,66,241,255,47,195,125,47,169,205,218,158,81,209,220,82,56,43,165,53,150,115,130,175,47,63,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,192,36,129,215,156,102,95,191,215,246,250,187,124,246,187,207,191,182,251,171,78,251,190,234,32,231,204,20,248,153,217,246,21,93,95,125,199,95,209,211,243,103,216,0,207,155,87,85,28,188,1,214,103,248,59,215,221,59,254,238,243,223,245,251,204,239,109,128,103,156,107,171,12,222,0,187,166,187,119,244,238,249,51,175,183,1,102,206,237,178,174,7,111,128,221,103,250,106,182,110,132,211,243,214,243,103,188,182,1,102,204,233,182,46,5,224,54,218,25,7,11,192,140,57,221,214,229,160,239,0,235,51,123,215,100,247,25,127,90,111,183,191,204,245,54,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,
64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,10,64,205,40,50,141,8,64,198,189,166,170,0,212,140,34,211,136,0,100,220,107,170,14,250,127,1,187,127,239,255,212,248,180,222,140,255,55,96,3,156,230,100,248,251,5,96,248,0,79,219,23,128,83,193,
225,239,31,244,29,96,149,190,250,25,123,122,222,233,119,134,245,243,61,243,218,6,120,198,185,182,202,224,13,176,107,186,123,135,158,110,132,221,254,50,215,219,0,25,247,154,170,175,154,78,222,54,178,123,7,191,61,240,230,11,102,108,16,27,224,230,24,180,31,255,143,190,3,172,163,88,239,208,105,27,102,253,60,159,189,182,1,62,115,243,46,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,0,1,2,4,8,16,32,64,128,64,68,224,15,0,0,255,255,3,0,229,134,28,161,61,80,196,66,0,0,0,0,73,69,78,68,174,66,96,130);

default_hand128H
:array[0..1845] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,6,253,73,68,65,84,120,1,236,157,141,185,164,38,20,134,157,187,41,32,37,76,9,233,96,217,78,210,73,54,29,164,132,220,74,194,237,32,37,108,9,169,96,39,231,67,241,226,25,24,212,81,7,240,227,121,92,126,68,126,222,243,137,160,204,221,174,163,35,1,18,32,129,35,9,152,174,123,251,222,31,157,132,221,33,30,221,43,8,92,142,171,20,70,191,253,145,168,207,118,221,229,163,235,126,74,30,186,35,9,28,36,128,135,198,15,250,123,249,147,34,8,112,28,16,60,64,0,115,141,239,123,75,17,120,18,71,248,95,14,168,228,159,251,58,96,100,12,249,206,93,7,223,123,70,2,114,158,238,8,2,191,236,92,137,81,229,91,153,7,124,147,35,76,150,60,23,45,18,73,235,172,28,116,59,19,120,219,183,252,139,154,244,221,98,119,182,21,1,168,244,55,179,111,187,88,186,39,176,179,0,124,53,57,255,167,157,230,184,125,157,198,25,219,139,192,222,2,48,170,225,86,197,25,125,49,129,189,5,240,226,238,177,250,28,1,10,32,71,168,241,243,20,64,227,6,206,117,
143,2,200,17,106,252,60,5,208,184,129,115,221,163,0,114,132,26,63,79,1,52,110,224,92,247,40,128,28,161,198,207,83,0,141,27,56,215,61,10,32,71,168,241,243,20,64,227,6,206,117,175,116,1,24,233,128,28,216,84,2,159,110,107,2,123,239,7,88,219,222,171,124,34,14,54,13,32,232,63,45,187,29,67,86,18,112,208,61,73,160,212,17,224,154,238,23,54,150,98,3,137,27,21,210,217,120,102,22,129,82,5,48,163,241,110,135,177,25,50,138,15,65,120,97,32,76,129,12,108,30,122,59,239,9,188,136,33,38,78,237,252,25,207,93,197,120,191,143,177,207,128,149,224,15,57,247,62,36,93,7,127,240,46,70,206,253,53,92,43,225,238,42,7,252,225,112,245,127,72,252,135,28,116,17,2,5,143,0,120,214,187,253,131,223,250,173,226,8,235,173,99,221,53,210,39,149,228,246,27,26,149,200,232,64,160,96,1,196,126,36,226,210,236,114,235,249,77,167,254,49,129,9,230,120,248,249,132,89,94,110,253,87,20,44,128,20,220,113,59,185,206,96,251,17,3,163,196,221,72,33,121,97,240,201,188,193,95,111,250,244,115,142,20,165,44,3,127,243,214,24,252,255,84,
60,19,189,93,62,51,140,27,76,173,24,93,238,238,37,14,249,33,158,216,232,179,164,156,122,242,86,56,2,220,61,247,63,18,184,109,34,61,147,156,252,253,98,230,186,58,79,87,40,128,219,117,1,106,123,159,23,119,56,70,12,127,196,30,23,157,185,191,174,205,148,10,5,176,200,16,191,170,220,255,222,15,239,24,238,181,8,222,140,186,174,217,104,235,2,184,78,45,119,123,159,198,125,108,156,55,12,9,231,249,97,74,235,2,240,22,206,249,86,101,48,42,222,108,148,2,104,214,180,243,58,70,1,204,227,212,108,46,10,160,89,211,206,235,24,5,48,143,83,179,185,40,128,102,77,59,175,99,20,192,60,78,205,230,162,0,154,53,237,188,142,81,0,243,56,53,155,43,35,0,191,181,202,125,37,195,151,50,124,93,51,205,210,56,97,199,18,159,131,97,120,124,21,187,69,144,96,27,22,220,185,62,155,246,125,110,239,95,249,42,166,157,55,190,78,143,198,173,136,68,190,174,117,226,199,92,184,181,27,231,195,239,246,177,252,175,76,171,169,173,219,113,210,143,0,211,223,249,179,43,144,252,124,44,204,166,85,96,70,245,8,112,198,84,205,116,67,189,237,
19,253,143,51,244,60,192,205,17,100,36,56,207,78,26,5,169,218,104,40,0,115,223,11,183,43,215,126,166,223,134,112,236,174,199,156,1,3,10,69,240,201,171,252,80,240,8,24,239,110,223,106,43,1,28,17,23,221,162,45,249,156,8,190,71,46,96,82,161,4,2,1,232,22,70,255,172,107,144,41,182,147,6,167,41,130,0,82,241,193,80,0,102,121,107,41,130,229,204,202,186,34,20,192,202,150,61,18,193,202,34,121,217,97,4,2,1,60,179,49,50,37,130,73,63,236,36,198,72,17,4,2,1,232,246,224,89,190,196,229,68,144,155,83,44,169,139,121,183,34,16,8,0,6,212,14,111,5,151,56,148,129,21,130,94,61,184,209,197,46,41,137,121,143,33,160,94,5,195,224,250,206,95,253,206,223,72,23,172,28,149,56,190,10,22,67,185,81,192,78,45,182,122,89,167,202,153,150,202,88,25,4,130,71,128,111,144,27,194,125,100,240,87,139,64,149,195,104,105,4,34,2,64,19,83,34,232,76,105,29,96,123,158,35,144,16,0,158,221,122,89,136,138,98,223,0,158,107,0,175,126,45,129,148,0,164,85,169,101,221,221,55,131,215,246,96,159,218,237,62,197,150,87,234,3,1,160,177,81,
17,152,97,36,40,175,55,235,91,36,125,58,167,203,8,0,80,82,34,192,146,145,174,118,2,51,4,128,46,198,68,192,149,65,237,198,71,251,103,10,0,89,33,2,253,98,135,34,0,153,154,221,2,1,160,155,169,229,33,31,7,181,138,96,161,0,30,137,160,51,181,66,144,73,173,250,240,149,252,83,116,245,118,49,209,242,21,2,56,195,59,2,253,39,99,18,244,26,72,94,35,0,233,118,108,82,8,26,250,78,170,130,144,145,86,226,8,157,13,35,45,135,87,10,0,72,162,34,48,13,188,35,176,232,221,89,220,19,2,0,162,148,8,106,154,20,234,81,235,92,27,87,158,20,64,74,4,85,45,15,13,122,113,86,183,209,255,23,128,31,140,184,31,141,94,3,144,70,94,51,200,134,19,255,99,146,224,76,49,65,55,82,73,59,71,103,37,36,191,112,58,143,219,96,4,240,176,106,124,71,128,145,42,116,231,89,254,249,94,111,40,0,20,153,18,65,103,124,133,229,248,177,121,138,123,219,89,78,19,15,104,201,198,2,168,230,29,129,17,177,234,187,255,84,67,191,215,214,214,2,144,114,163,43,3,73,47,105,51,137,158,249,3,199,249,238,126,244,122,7,1,120,152,169,29,69,177,161,23,215,28,
229,98,66,140,61,186,142,106,207,107,235,217,104,21,16,235,4,102,255,88,5,220,61,255,205,176,98,120,143,93,181,111,90,204,248,16,234,237,239,125,235,45,183,244,157,70,0,223,225,212,227,0,162,112,251,240,197,63,194,97,212,137,214,103,207,58,244,123,234,59,11,0,213,36,69,32,231,112,71,198,238,74,223,188,45,124,24,95,79,248,92,185,54,190,106,217,162,206,122,202,192,16,125,148,51,131,177,83,245,89,49,136,12,199,88,73,108,225,146,134,71,225,150,198,239,25,31,41,128,190,198,121,119,60,12,180,84,12,70,230,28,114,184,255,237,67,252,148,91,253,83,183,84,129,85,167,191,64,0,142,151,145,209,0,235,112,241,179,206,246,57,244,91,186,241,191,117,49,217,18,198,12,52,254,136,98,8,188,74,0,190,29,102,129,16,252,53,43,124,26,62,5,237,213,2,240,237,50,59,8,193,74,153,31,103,159,229,123,192,41,191,20,1,132,237,51,131,24,144,38,225,217,206,246,6,71,254,115,190,213,155,77,42,200,88,162,0,130,230,185,160,233,19,222,6,191,143,137,145,173,15,137,31,134,131,100,6,73,128,4,72,128,4,72,128,4,72,128,4,72,
128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,128,4,72,160,54,2,255,3,0,0,255,255,3,0,43,164,78,84,218,105,81,172,0,0,0,0,73,69,78,68,174,66,96,130);

default_move128H
:array[0..1587] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,5,251,73,68,65,84,120,1,236,156,9,154,219,40,16,133,101,103,238,21,229,100,73,78,50,71,137,114,177,118,120,202,48,237,5,48,72,44,69,213,227,251,212,178,197,86,188,247,91,66,91,47,11,19,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,84,41,112,253,177,44,88,152,12,42,0,227,47,183,191,139,93,8,46,6,157,119,67,134,225,183,239,143,99,191,252,92,150,15,183,221,86,50,8,64,200,124,111,186,61,8,140,1,144,50,223,38,4,134,0,200,49,223,30,4,87,63,100,221,235,152,249,216,229,99,121,78,152,31,160,142,254,100,96,15,144,50,223,79,250,114,202,232,132,65,57,0,37,198,150,148,213,3,131,98,0,142,24,122,164,206,220,48,40,5,224,140,145,103,234,206,7,131,66,0,106,24,88,163,141,57,96,80,6,64,77,227,106,182,37,23,6,69,0,180,48,172,69,155,178,96,80,2,64,75,163,90,182,61,30,6,5,0,244,48,168,71,31,99,96,152,28,128,
158,198,244,236,171,31,12,19,3,48,194,144,17,125,182,133,97,82,0,70,26,49,178,239,250,48,76,8,128,4,3,36,196,80,7,134,47,117,154,233,214,202,234,122,250,247,181,183,222,15,114,220,54,119,183,16,63,158,245,41,22,247,29,219,145,63,71,154,236,118,240,117,125,149,181,183,249,62,2,220,73,12,221,74,246,249,115,172,255,153,35,204,84,148,183,175,206,136,95,169,18,143,121,151,223,241,103,255,246,93,187,107,47,55,221,114,11,138,45,167,0,128,151,221,240,27,177,83,166,1,166,210,246,222,116,39,60,123,178,67,128,112,53,39,12,143,0,76,104,90,205,144,103,59,13,92,203,7,127,117,117,30,222,1,216,220,247,111,225,118,246,185,132,43,239,211,62,193,220,252,183,204,117,105,249,204,102,219,20,19,56,7,192,68,44,148,246,231,247,182,80,78,122,219,135,203,190,124,79,151,137,229,126,108,46,7,75,105,90,221,233,160,91,158,211,225,246,158,27,170,246,93,24,0,177,11,44,251,120,55,247,23,203,36,233,97,175,243,95,204,0,113,212,105,107,88,54,65,115,128,164,249,225,232,167,220,42,235,145,115,33,0,88,49,223,19,43,
7,2,1,0,88,51,95,22,4,131,1,136,153,191,95,98,221,188,84,10,214,110,44,161,203,198,227,247,4,3,1,72,153,239,223,216,81,96,253,255,67,136,221,59,24,11,193,32,0,172,153,239,41,144,7,193,0,0,172,154,47,19,130,206,0,88,55,95,30,4,29,1,160,249,222,254,191,107,25,135,131,78,0,208,252,71,243,253,183,241,16,116,0,128,230,123,187,195,235,177,16,52,190,23,80,211,252,235,234,158,228,9,107,152,220,138,122,169,135,64,82,149,81,183,71,159,128,0,191,69,156,18,222,167,253,20,209,109,64,126,155,212,240,118,240,89,243,159,111,205,86,19,96,203,191,29,220,163,207,251,62,206,106,118,223,86,222,231,70,135,128,254,3,201,27,174,244,82,253,15,7,13,0,160,249,231,48,235,11,65,229,67,64,77,243,247,182,190,158,19,51,84,187,230,83,193,161,246,67,219,82,125,134,202,99,91,77,45,99,125,184,59,20,241,172,210,156,62,1,151,70,53,119,249,246,154,86,2,160,125,160,115,27,121,38,250,182,218,86,0,160,109,128,103,164,211,83,183,157,198,13,38,129,122,100,183,48,146,10,123,0,200,212,142,80,11,38,164,199,216,86,219,74,0,
16,130,180,137,71,115,219,154,143,168,42,2,128,230,106,6,188,183,197,211,64,200,250,144,234,62,86,94,25,0,68,90,11,2,139,151,130,189,211,181,52,244,237,197,215,13,38,129,125,175,100,197,135,54,107,78,63,243,161,80,3,0,208,44,33,128,10,229,169,175,249,136,175,225,237,96,64,0,190,106,221,226,220,143,125,155,107,176,48,93,215,215,24,114,155,232,217,103,127,243,161,66,67,0,208,124,77,8,142,190,88,57,226,229,208,210,62,199,152,15,135,26,29,2,208,180,79,60,28,120,37,194,235,113,230,35,158,14,0,160,27,66,0,21,94,211,88,243,17,79,39,0,208,21,33,128,10,159,105,188,249,136,165,35,0,232,142,16,64,5,39,251,143,240,196,180,238,69,158,189,171,55,127,58,3,128,104,172,67,32,199,124,184,49,0,0,203,16,200,50,127,32,0,22,33,144,103,254,96,0,222,65,176,172,40,161,36,173,82,142,249,207,122,14,58,4,220,135,17,155,19,220,151,209,248,185,255,132,47,164,162,0,0,16,150,53,8,100,152,15,229,133,0,96,9,2,57,230,67,245,198,247,2,208,69,73,194,158,96,217,28,151,235,242,146,142,190,223,247,210,80,143,13,91,
248,127,2,161,235,125,140,61,98,200,234,67,24,0,123,204,155,19,201,45,209,180,70,115,130,25,87,87,254,40,60,168,123,228,229,80,64,44,203,232,37,146,26,60,17,20,233,169,202,230,216,169,84,81,227,155,3,226,91,184,70,141,167,144,100,237,226,195,227,252,220,42,104,14,240,25,20,63,245,83,128,0,244,211,90,100,79,18,231,0,165,66,109,101,21,240,162,102,108,78,144,202,139,246,178,70,115,38,200,80,0,64,233,155,183,49,243,225,86,233,196,109,159,147,172,19,248,28,13,81,193,33,96,212,127,218,140,77,72,147,103,48,81,35,70,101,76,6,0,126,161,152,101,63,167,222,16,196,204,223,99,219,158,163,147,252,125,178,211,64,47,101,202,128,210,221,184,111,51,119,61,178,239,220,24,243,203,77,10,0,6,56,194,136,17,125,230,155,121,164,228,196,0,244,134,64,159,249,80,112,114,0,122,65,160,211,124,37,0,180,134,64,175,249,138,0,104,5,129,110,243,149,1,80,27,2,253,230,43,4,160,22,4,54,204,87,10,192,89,8,236,152,175,24,128,163,16,216,50,95,57,0,165,16,216,51,223,0,0,185,16,216,52,223,8,0,239,32,64,254,243,127,49,
217,165,249,89,126,123,24,245,230,74,10,174,4,230,10,30,251,149,135,234,207,245,92,95,104,4,185,219,12,1,0,73,114,32,176,99,62,20,49,6,192,59,8,108,153,111,20,128,24,4,246,204,135,18,134,19,14,7,23,247,128,32,22,124,102,50,168,0,140,167,249,6,141,231,144,169,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,80,1,42,64,5,168,0,21,160,2,84,128,10,168,86,224,15,0,0,0,255,255,3,0,107,70,163,152,190,130,129,161,0,0,0,0,73,69,78,68,174,66,96,130);

default_ns128H
:array[0..1092] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,4,12,73,68,65,84,120,1,236,157,141,142,147,80,16,70,105,227,123,57,62,153,235,147,45,190,152,245,78,173,201,166,133,182,31,11,116,239,55,231,38,55,42,12,63,115,190,147,5,197,192,48,48,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,96,68,32,90,47,57,203,142,99,217,206,207,193,31,222,135,33,103,93,9,170,10,16,151,224,47,254,215,149,160,162,0,87,225,95,28,40,250,147,160,154,0,51,225,215,149,160,146,0,15,194,175,41,65,21,1,102,194,63,252,106,247,2,109,94,143,58,247,4,21,4,184,19,254,159,183,97,200,89,87,2,119,1,30,132,63,92,70,93,9,156,5,120,50,252,218,18,184,10,32,134,95,87,2,71,1,22,134,95,83,2,55,1,62,25,126,61,9,156,4,88,41,252,90,18,184,8,176,114,248,117,36,112,16,96,163,240,107,72,208,187,0,27,135,239,47,65,207,2,236,20,190,183,4,189,10,176,115,248,190,18,244,40,192,139,194,247,148,160,67,1,206,79,234,254,167,113,249,53,
31,230,228,191,231,239,53,238,62,59,216,235,36,86,57,206,183,85,246,242,218,157,140,45,252,54,135,104,243,217,49,206,20,198,204,242,137,197,121,204,195,247,182,34,38,86,118,179,200,65,128,22,192,65,9,97,28,134,83,155,83,227,240,179,45,141,169,53,174,203,58,188,4,184,70,241,154,190,16,224,53,220,191,204,81,123,188,4,140,11,232,197,130,109,114,147,113,225,118,221,108,214,161,0,167,31,34,221,16,239,17,62,236,254,148,255,95,112,252,176,192,238,183,92,2,236,34,213,26,66,0,141,151,93,53,2,216,69,170,53,132,0,26,47,187,106,4,176,139,84,107,8,1,52,94,118,213,8,96,23,169,214,16,2,104,188,236,170,17,192,46,82,173,33,4,208,120,217,85,35,128,93,164,90,67,8,160,241,178,171,70,0,187,72,181,134,16,64,227,101,87,141,0,118,145,106,13,33,128,198,203,174,26,1,236,34,213,26,66,0,141,151,93,53,2,216,69,170,53,132,0,26,47,187,106,4,176,139,84,107,8,1,52,94,118,213,8,96,23,169,214,16,2,104,188,236,170,17,192,46,82,173,33,4,208,120,217,85,35,128,93,164,90,67,8,160,241,178,171,70,0,187,72,181,134,16,
64,227,101,87,141,0,118,145,106,13,33,128,198,203,174,26,1,236,34,213,26,66,0,141,151,93,53,2,216,69,170,53,132,0,26,47,187,106,4,176,139,84,107,8,1,52,94,118,213,8,96,23,169,214,16,2,104,188,236,170,17,192,46,82,173,161,14,223,20,58,245,189,0,173,233,231,171,207,111,15,207,55,136,11,67,126,147,169,176,239,245,75,59,20,96,136,245,49,204,238,113,207,99,205,158,196,150,43,184,4,108,73,183,131,125,35,64,7,33,109,121,138,61,94,2,174,121,140,237,11,32,249,86,239,21,198,121,63,194,190,250,255,194,136,131,0,49,12,199,223,43,125,52,106,124,222,162,227,91,19,175,29,187,239,209,225,37,96,234,46,251,212,238,212,51,144,189,198,57,252,137,191,29,76,157,219,94,231,180,236,56,135,101,155,189,124,171,104,31,129,120,191,61,139,61,62,31,119,55,252,241,246,156,190,246,146,94,5,72,170,177,191,4,94,225,39,196,158,5,200,243,143,253,36,240,11,63,1,246,46,64,246,16,219,75,224,25,126,194,115,16,32,251,136,237,36,240,13,63,193,185,8,144,189,196,250,18,120,135,159,208,156,4,200,126,98,61,9,252,195,79,96,
110,2,100,79,241,121,9,106,132,159,176,28,5,200,190,98,185,4,117,194,79,80,174,2,100,111,161,75,80,43,252,132,228,44,64,246,23,207,75,80,47,252,4,228,46,64,246,24,143,37,168,25,126,194,169,32,64,246,25,243,18,228,234,124,152,116,61,206,15,118,198,235,165,110,127,174,34,64,230,22,211,18,76,69,90,35,252,236,188,146,0,217,111,60,150,160,78,248,9,164,154,0,217,115,204,75,80,43,252,132,81,81,128,236,59,110,37,168,23,126,130,168,60,162,73,112,250,55,83,8,70,69,2,209,154,206,201,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,128,7,129,191,0,0,0,255,255,3,0,62,248,237,57,226,159,132,183,0,0,0,0,73,69,78,68,174,66,96,130);

default_pen128H
:array[0..1674] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,6,82,73,68,65,84,120,1,236,157,93,146,163,54,20,133,193,147,21,228,45,111,100,39,154,170,108,35,85,157,93,204,91,186,159,102,25,169,169,202,62,134,222,73,247,70,226,156,75,91,110,12,146,141,133,4,216,254,110,21,45,36,204,149,56,231,179,132,233,191,170,34,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,32,166,128,139,29,160,125,59,10,124,41,52,20,87,85,245,79,109,207,135,205,234,79,85,181,251,189,170,246,149,162,209,246,166,141,88,89,129,186,92,255,117,231,244,133,252,173,128,120,209,107,84,18,107,40,176,91,163,211,94,159,238,48,83,8,22,155,49,42,213,137,37,21,40,181,4,232,26,106,167,47,141,182,169,209,124,44,19,221,178,225,116,210,187,182,55,109,68,65,5,10,206,0,245,235,96,220,173,234,126,27,28,26,85,221,97,102,96,86,24,73,147,183,225,151,188,233,206,101,51,32,254,123,238,189,194,201,
228,191,15,117,237,7,67,237,221,76,210,114,175,16,212,103,118,99,233,37,64,6,158,196,143,94,237,77,251,86,183,77,112,236,222,85,58,109,161,104,62,150,135,93,45,16,218,208,11,104,75,83,64,130,22,11,247,49,141,247,243,239,167,244,103,231,217,204,160,50,22,251,175,58,210,198,142,210,62,93,129,41,134,76,207,54,122,229,240,163,96,253,50,88,6,70,103,244,26,220,5,16,90,205,6,6,2,49,67,129,130,55,129,54,42,51,60,57,218,15,131,163,38,59,229,223,43,187,74,34,85,129,194,0,12,135,181,247,55,125,195,3,231,234,173,64,208,76,21,131,201,158,31,236,158,207,37,224,88,92,1,9,91,58,134,203,192,164,251,128,216,160,220,153,101,161,101,73,136,201,22,111,95,98,6,144,49,253,152,245,110,85,46,91,18,130,179,129,83,187,102,3,226,26,5,10,126,12,244,195,176,111,0,157,172,211,78,245,23,127,52,173,180,143,130,246,145,240,36,175,165,106,4,129,83,249,67,27,49,65,1,19,113,129,24,46,3,246,14,62,121,40,148,58,6,23,89,18,90,150,131,105,146,46,48,3,216,64,70,239,86,167,70,65,48,59,222,148,65,239,246,238,93,223,244,
178,105,159,153,160,167,71,116,119,137,123,0,117,30,122,183,207,186,23,24,92,80,240,193,144,19,4,220,19,12,148,26,86,23,2,192,186,13,222,184,13,199,51,163,14,4,41,226,45,180,4,216,208,186,41,217,245,6,169,253,236,207,246,89,14,122,2,79,217,93,16,128,224,157,187,32,200,114,47,208,191,86,32,232,171,113,97,127,65,0,108,36,123,109,245,147,237,125,70,246,89,192,82,3,193,167,192,103,247,22,6,192,126,194,39,248,137,224,85,163,212,177,172,1,4,19,228,92,240,38,208,143,38,244,137,224,248,131,33,254,69,153,74,110,12,47,9,185,244,12,112,24,207,104,22,104,10,220,16,250,107,103,38,240,74,4,202,149,0,136,221,16,22,185,31,176,203,6,130,128,249,214,84,71,218,23,106,30,62,34,182,110,131,211,118,166,241,4,127,244,188,125,228,199,198,43,205,0,222,207,209,82,160,3,117,163,47,122,199,22,9,102,130,129,172,43,3,16,92,10,154,195,67,35,32,24,152,85,162,186,50,0,118,73,64,80,194,216,169,57,55,0,128,135,160,118,218,107,172,118,136,134,153,192,75,81,174,220,8,0,221,5,174,177,62,175,209,103,57,55,19,50,111,
9,0,27,254,26,134,172,209,103,130,85,101,78,217,26,0,64,80,198,231,104,214,45,2,0,4,81,187,242,31,216,42,0,64,144,223,235,96,198,45,3,0,4,65,203,242,54,110,29,0,32,200,235,247,40,219,45,0,0,4,35,219,242,53,220,10,0,64,144,207,243,147,76,183,4,0,16,156,88,151,167,114,107,0,0,65,30,223,143,89,110,17,0,32,56,218,55,127,231,86,1,0,130,249,222,119,25,110,25,0,32,200,0,193,173,3,0,4,51,33,184,7,0,128,96,6,4,247,2,0,16,36,66,112,79,0,0,65,2,4,247,6,0,16,92,9,193,61,2,0,4,87,64,112,175,0,0,193,68,8,238,25,0,32,152,0,193,189,3,0,4,23,32,120,4,0,128,224,12,4,143,2,0,16,68,32,120,36,0,54,0,65,247,39,114,108,28,77,225,223,122,178,62,38,197,163,1,96,162,172,241,139,32,191,169,223,63,62,29,169,109,183,217,2,4,143,8,128,137,191,36,4,223,212,223,119,235,244,52,182,1,193,163,2,96,94,44,1,193,57,243,61,15,205,154,51,193,35,3,80,26,130,136,249,213,159,50,252,87,117,46,227,143,161,253,218,169,38,40,151,141,71,7,192,212,46,49,19,156,49,191,250,183,80,159,73,228,0,192,135,108,57,33,184,100,190,55,
42,103,159,62,231,213,37,0,124,74,150,195,144,169,230,251,94,115,244,233,115,37,149,0,112,42,219,28,67,174,53,223,247,60,167,79,159,35,185,4,128,177,116,41,134,164,154,239,123,79,233,211,159,59,171,4,128,176,124,215,24,50,215,124,63,130,107,250,244,231,204,46,1,32,46,225,20,67,114,153,239,71,17,233,179,216,95,80,173,0,192,75,31,46,35,134,212,78,47,183,199,187,129,39,124,246,57,191,251,168,167,34,41,66,125,90,34,181,231,15,0,184,172,105,200,144,70,167,245,158,237,31,147,204,53,223,39,122,215,131,161,39,95,81,217,104,123,233,213,179,237,2,192,52,41,7,16,216,119,245,70,145,203,124,37,174,255,209,151,166,215,67,171,125,141,33,127,172,240,255,2,242,95,196,50,25,251,127,196,186,30,118,153,211,252,159,74,238,78,59,168,95,79,235,249,106,204,0,215,105,169,119,97,183,254,55,42,15,103,90,217,61,219,215,177,185,17,253,107,230,127,205,205,28,59,31,0,98,202,196,219,101,244,16,130,170,57,180,205,128,32,106,254,215,248,80,230,31,1,128,52,13,123,16,28,19,52,233,16,172,99,190,141,28,0,142,254,
93,189,147,9,130,245,204,7,128,171,61,31,157,48,19,130,117,205,7,128,145,159,73,13,137,16,172,111,62,0,36,249,29,60,233,74,8,182,97,62,0,4,189,76,110,156,8,193,118,204,7,128,100,175,163,39,94,128,96,91,230,219,85,212,209,75,225,192,12,5,130,70,135,242,181,107,255,203,58,0,8,217,146,165,237,34,4,171,155,111,151,9,0,89,204,142,37,137,66,208,174,253,206,143,141,152,246,236,10,236,158,245,62,211,55,120,236,191,164,90,105,117,2,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,80,0,5,50,42,240,63,0,0,0,255,255,3,0,205,253,133,78,156,55,166,214,0,0,0,0,73,69,78,68,174,66,96,130);

default_person128H//part image
:array[0..1085] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,32,0,0,0,33,8,6,0,0,0,184,38,169,81,0,0,4,5,73,68,65,84,120,1,180,151,91,72,84,65,24,199,119,189,151,221,237,74,130,20,101,148,25,148,36,81,24,105,24,20,145,97,33,26,129,69,245,208,253,70,15,69,65,225,75,4,5,65,5,210,133,8,130,10,122,168,44,202,168,192,7,161,94,122,168,135,34,76,48,37,40,236,98,70,222,112,251,253,119,207,232,186,231,156,61,123,146,62,248,57,179,51,223,247,205,55,51,231,155,25,3,1,87,9,210,35,254,175,36,13,215,125,48,24,76,130,127,142,212,37,0,119,127,26,12,25,3,101,112,138,9,92,130,115,212,15,67,1,164,249,153,84,178,179,178,9,32,20,213,157,20,96,158,163,105,216,7,183,160,26,138,97,17,44,129,85,176,5,138,9,162,13,154,169,123,138,203,10,196,218,105,240,208,36,90,31,193,105,24,15,175,160,6,246,194,17,184,14,223,96,57,212,193,33,130,112,153,32,189,238,162,217,27,34,90,56,26,7,175,33,4,205,176,26,210,163,125,240,59,25,164,119,6,254,64,31,236,137,214,73,176,62,116,240,64,32,153,217,7,107,65,131,55,193,180,120,142,
232,215,71,89,5,61,208,11,121,241,244,99,250,204,224,42,35,130,131,153,160,217,104,86,243,76,123,188,18,61,201,13,80,208,79,19,76,103,251,224,26,4,7,7,44,71,245,148,131,145,197,139,32,98,167,237,248,13,253,224,186,106,124,132,102,96,39,143,225,241,42,173,158,139,33,196,73,203,165,237,39,237,77,32,39,185,46,58,1,135,44,176,141,49,199,50,126,233,230,196,169,221,10,246,139,213,55,209,73,71,109,41,131,29,182,129,77,87,183,85,201,48,13,62,202,84,75,183,215,205,134,0,92,7,54,54,111,168,76,129,18,184,102,26,189,74,246,93,75,47,59,201,215,72,97,255,235,121,80,224,167,15,179,13,144,77,253,178,221,133,115,11,186,179,232,57,14,10,68,7,85,23,248,23,28,77,6,229,180,82,177,52,17,15,232,165,192,51,80,26,94,137,196,144,136,165,163,78,248,32,218,143,35,165,211,119,88,6,225,244,112,82,167,43,13,46,128,244,59,32,219,73,207,87,27,78,210,161,14,140,211,99,212,179,32,21,116,4,107,198,210,41,132,251,32,189,110,88,235,53,123,215,153,196,70,136,179,81,180,157,135,106,80,250,254,130,6,80,190,235,183,210,
85,199,174,238,8,93,74,91,225,129,215,217,225,249,17,226,36,44,4,32,221,76,40,132,177,160,129,116,192,44,128,124,208,105,167,180,86,90,61,135,59,208,110,253,166,112,22,207,0,24,88,162,59,95,14,119,130,222,4,157,240,4,30,194,99,208,74,188,3,173,196,4,152,11,219,64,219,212,72,217,3,254,37,60,116,228,102,235,164,174,125,253,8,219,65,142,181,239,3,91,72,85,183,160,190,131,124,184,10,230,30,104,160,62,53,18,155,175,24,244,8,9,174,7,93,169,26,92,183,155,182,192,83,208,211,135,185,20,244,50,82,42,234,45,161,71,76,226,130,65,46,152,153,235,205,103,142,213,132,157,96,147,3,205,160,32,238,37,108,104,61,66,204,65,114,27,227,168,59,195,135,27,84,177,205,131,118,80,16,107,188,210,50,236,29,197,34,203,64,7,143,191,165,179,197,23,84,16,71,45,127,31,40,189,38,19,54,184,105,25,156,77,40,98,219,160,67,27,240,165,15,180,213,242,169,52,118,23,148,70,64,23,232,195,155,238,174,233,175,7,95,250,136,181,13,53,209,150,202,219,88,153,65,131,14,153,22,222,63,109,177,157,195,248,125,215,178,45,138,78,73,
167,0,178,44,197,31,100,185,2,25,182,48,107,141,211,98,57,98,130,131,111,16,167,0,148,110,210,200,135,70,140,79,192,74,208,123,64,219,163,195,70,151,144,14,34,161,156,55,23,146,126,235,54,204,128,145,48,31,170,240,83,11,245,32,25,146,206,182,163,24,131,79,40,117,192,108,208,89,95,2,155,96,55,232,120,173,132,50,88,15,235,128,27,47,80,14,21,32,189,29,112,16,78,194,46,216,8,5,160,175,255,5,224,35,244,153,50,44,3,71,169,105,80,73,16,106,215,153,95,10,43,96,33,40,32,181,105,213,132,177,53,165,89,215,126,250,12,173,212,223,131,238,3,221,29,111,185,29,93,223,135,244,219,133,88,148,66,90,214,76,200,129,197,160,127,205,202,65,255,1,85,195,102,168,0,29,221,197,160,165,215,75,74,91,145,106,247,58,216,242,23,0,0,255,255,3,0,203,157,180,129,66,163,191,99,0,0,0,0,73,69,78,68,174,66,96,130);

default_pin128H
:array[0..1014] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,23,0,0,0,32,8,6,0,0,0,249,85,227,181,0,0,3,190,73,68,65,84,120,1,172,150,89,168,77,81,24,199,215,217,247,152,135,36,202,152,33,15,134,7,41,137,66,138,39,68,36,20,15,40,221,20,34,202,85,134,40,101,136,40,36,99,185,68,136,7,73,202,240,194,125,49,15,81,166,148,49,151,162,100,62,251,248,253,215,94,107,159,189,143,125,142,251,224,171,255,254,198,245,173,111,127,223,218,235,156,92,177,88,52,198,8,162,92,196,254,211,51,248,87,226,32,8,218,129,169,96,37,216,9,54,129,133,96,168,49,133,170,101,228,179,189,69,19,4,53,125,241,109,0,51,179,99,12,49,205,26,241,213,129,250,48,252,253,11,75,42,52,173,89,87,168,196,115,17,159,1,159,248,58,242,94,176,10,108,2,39,193,27,208,25,28,0,183,131,32,223,5,158,34,87,185,239,181,42,206,175,39,98,53,208,32,206,130,133,97,24,190,132,151,145,125,187,89,24,183,128,65,224,9,173,26,66,236,83,31,152,170,156,138,21,172,196,188,162,169,37,112,114,118,98,45,207,25,124,71,17,122,129,171,160,45,184,200,6,237,225,150,
168,60,170,26,99,71,44,135,157,189,142,133,251,156,92,149,17,71,33,225,40,222,248,33,129,3,0,115,42,46,82,222,100,229,43,113,72,111,96,193,54,120,76,108,156,3,35,192,70,176,24,244,139,157,86,176,105,52,159,16,112,146,106,122,203,236,146,255,148,60,71,15,104,73,196,162,39,137,58,33,61,7,13,96,5,216,1,212,223,61,160,6,217,18,5,221,67,184,228,212,137,226,54,121,16,180,28,140,172,36,111,195,176,160,147,145,164,35,40,189,147,6,39,215,194,71,149,217,143,59,125,154,94,194,85,110,186,57,227,11,63,3,233,84,214,21,54,86,114,5,218,90,102,191,230,244,62,201,158,171,106,209,167,136,197,79,217,227,87,143,173,37,97,48,5,180,44,169,230,149,147,85,84,92,249,7,103,244,155,56,213,52,34,20,188,146,193,111,208,235,239,9,187,31,180,62,176,56,249,93,23,48,160,108,72,239,176,159,119,190,44,182,188,204,56,217,233,87,213,150,188,20,134,248,134,193,223,70,28,2,230,129,228,25,159,139,126,7,116,7,209,71,97,204,15,228,253,192,247,24,209,210,116,199,207,136,187,129,218,53,219,157,99,190,227,150,241,218,31,
17,24,144,233,15,52,64,29,85,29,128,69,248,252,93,173,225,15,196,166,107,192,95,27,38,23,221,231,246,100,232,18,122,15,68,125,88,248,194,74,77,122,216,123,230,52,161,83,192,30,214,46,208,50,127,20,117,79,104,120,122,85,17,109,137,139,138,44,85,158,180,180,21,238,9,46,100,183,15,141,147,59,195,22,199,199,176,160,131,15,106,2,223,73,76,115,112,142,123,253,190,143,79,37,167,250,199,56,78,1,13,250,112,83,170,167,215,205,136,157,1,68,235,18,205,40,181,37,242,217,231,26,39,143,167,250,158,9,123,134,104,91,119,12,71,27,112,49,12,191,93,79,6,165,42,151,131,234,31,193,14,1,125,153,39,168,204,31,63,212,52,177,185,190,68,127,182,151,26,211,34,21,240,87,114,231,93,13,87,89,195,192,8,103,75,49,183,169,111,225,17,138,122,144,10,64,201,76,78,224,107,124,244,207,250,235,73,100,63,182,178,197,227,208,135,3,21,81,87,230,179,106,102,114,23,168,147,243,25,244,5,188,114,137,220,16,15,98,209,250,101,124,225,42,230,47,170,152,156,234,191,18,173,143,66,149,173,37,97,235,196,234,181,200,61,128,46,168,
93,165,91,33,17,129,24,127,161,105,115,164,145,80,67,189,12,70,131,43,64,119,187,126,128,117,161,233,92,143,166,136,107,240,76,202,234,101,28,200,194,2,27,204,198,240,28,104,131,145,96,51,208,29,126,1,52,128,138,84,181,114,191,138,13,52,220,53,224,11,80,123,66,208,149,175,145,223,129,138,157,173,226,97,117,130,54,32,191,2,109,129,206,61,255,105,10,85,19,19,19,221,231,18,170,17,237,249,73,245,147,136,185,9,110,129,250,74,67,76,230,105,82,91,162,5,250,15,153,239,204,70,141,81,87,42,183,195,111,240,7,0,0,255,255,3,0,72,24,8,230,155,233,14,103,0,0,0,0,73,69,78,68,174,66,96,130);

default_no128H
:array[0..2478] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,9,118,73,68,65,84,120,1,236,92,141,153,163,56,12,37,92,35,185,74,86,211,73,174,146,203,86,178,59,149,172,211,73,182,145,205,61,25,8,182,44,19,38,1,108,114,210,247,25,44,255,202,79,207,63,144,25,154,198,196,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,12,1,67,192,16,48,4,246,129,192,97,31,102,190,106,101,123,30,91,184,125,27,227,13,245,113,55,166,29,46,93,252,207,144,54,220,199,34,111,20,123,83,2,12,14,191,253,187,128,175,122,2,220,190,163,173,62,190,64,171,149,52,241,70,4,88,212,233,83,238,1,9,222,135,12,127,77,141,116,39,121,212,52,237,9,78,225,217,142,248,234,114,108,154,195,9,129,208,211,111,132,43,194,110,101,231,43,0,207,250,57,203,252,225,251,232,161,251,222,
206,73,174,79,167,254,142,91,75,184,64,252,89,129,124,116,250,226,246,188,34,236,148,0,115,28,63,56,253,207,121,218,127,15,115,9,179,125,56,75,32,158,19,238,239,229,190,114,141,175,150,190,67,2,28,126,1,13,210,17,89,204,233,122,243,190,95,79,134,76,255,188,162,220,62,114,149,107,76,223,19,1,0,186,119,190,134,163,67,222,101,195,25,200,182,228,206,28,176,101,63,135,196,157,16,96,106,201,159,187,244,114,27,44,247,247,0,228,213,238,226,198,184,39,210,160,15,247,49,59,142,81,158,8,126,37,120,84,63,110,173,128,182,3,2,228,156,63,199,241,185,186,179,145,238,29,248,104,70,231,182,165,57,54,206,182,101,149,130,149,63,6,230,28,56,5,44,215,241,143,104,19,103,133,217,88,30,81,18,225,225,99,223,39,158,30,120,50,17,66,40,212,165,223,92,152,88,83,188,102,2,0,188,230,71,10,214,35,231,175,246,62,224,56,77,4,118,242,254,72,80,235,22,64,0,155,103,176,144,220,190,154,91,41,162,234,14,109,94,198,20,255,62,0,105,94,168,191,227,214,82,127,78,192,125,74,178,68,68,189,175,216,62,213,199,250,121,149,18,
64,219,83,85,231,103,192,14,129,203,58,42,44,148,139,115,251,185,211,62,215,113,153,199,62,174,167,17,184,58,188,171,51,168,7,14,0,134,50,229,68,141,44,92,119,170,78,216,246,172,56,77,16,193,233,143,125,234,170,196,101,63,102,245,184,81,161,118,163,126,102,118,195,160,201,131,212,35,71,170,43,195,204,254,102,23,115,157,227,212,190,72,39,45,191,21,100,219,35,33,108,49,231,40,165,176,82,211,10,0,112,146,101,211,205,159,49,218,74,240,136,60,207,162,175,245,197,109,105,4,209,86,130,91,53,184,87,180,2,220,223,183,15,94,113,138,243,9,36,185,233,179,72,3,159,159,8,214,152,113,220,87,50,187,97,119,66,96,164,105,191,15,172,97,19,186,122,66,106,33,0,193,118,14,129,248,151,47,129,206,209,129,36,57,199,110,73,2,117,137,103,27,149,195,159,36,203,106,143,170,2,175,199,106,37,4,24,28,123,55,216,33,198,33,16,63,107,104,76,168,150,4,176,81,206,112,191,10,184,209,118,142,181,132,75,113,169,225,69,16,97,214,156,99,36,110,255,64,191,6,105,132,248,143,64,31,162,72,231,151,47,201,155,182,79,180,137,
188,230,136,48,8,101,202,14,249,79,222,213,23,64,232,171,185,32,92,17,122,105,255,70,132,6,173,139,171,182,7,69,214,143,86,176,2,204,153,253,73,153,0,153,90,86,130,100,197,162,192,72,68,115,91,70,92,106,107,173,130,21,224,240,51,30,180,54,251,229,10,17,215,128,70,153,217,189,225,74,48,103,134,251,85,9,182,222,133,227,223,239,90,129,72,233,21,128,1,8,197,65,225,16,72,50,251,157,242,116,128,242,165,87,2,109,134,223,127,122,238,199,227,207,2,193,216,56,42,207,11,34,123,101,181,48,1,18,231,202,225,18,18,56,4,50,252,52,235,79,252,65,58,71,139,147,192,9,131,8,58,135,64,228,19,65,144,85,32,90,152,0,114,196,242,209,47,33,136,67,13,14,44,174,194,149,0,54,73,7,183,212,76,10,147,182,156,148,36,0,97,216,28,66,113,161,146,198,37,65,170,36,129,48,123,206,54,32,170,108,168,150,36,128,28,166,19,9,4,157,67,40,46,84,250,56,210,106,218,14,146,125,158,82,155,147,85,226,156,150,217,38,165,32,1,90,138,135,24,254,86,31,231,244,154,83,83,187,68,228,213,68,130,122,28,60,129,153,207,42,72,128,71,166,201,
253,127,14,65,106,34,193,163,241,213,145,95,242,61,0,31,126,142,35,12,126,127,191,142,250,225,132,248,113,212,101,254,152,19,196,174,136,95,112,16,59,5,105,28,165,109,223,19,220,208,101,98,195,39,27,210,201,163,252,161,220,250,247,118,253,46,54,239,193,213,181,29,108,62,254,47,117,248,142,4,96,0,156,145,96,30,15,74,18,128,132,137,112,90,36,20,105,227,243,191,72,206,170,174,32,9,208,119,36,20,105,233,88,100,190,40,190,158,90,146,0,235,141,106,108,217,21,36,193,104,69,197,177,146,4,128,115,34,161,72,91,110,150,184,2,36,144,99,17,67,107,100,62,108,44,35,37,9,176,229,136,93,1,18,132,227,67,255,117,202,255,133,0,140,190,219,142,4,45,161,191,93,72,65,2,200,23,59,45,197,136,61,202,143,75,207,212,220,54,36,144,239,255,165,117,45,197,41,114,172,113,238,154,90,65,2,172,57,172,201,182,221,54,36,8,109,72,126,196,10,51,139,198,43,38,128,252,81,101,209,159,77,215,38,1,77,123,85,174,16,209,119,139,166,171,46,156,91,144,0,179,28,236,226,241,182,231,88,127,73,115,235,172,4,170,141,232,43,18,138,
180,130,74,65,2,104,163,150,224,173,190,55,186,229,73,144,172,84,232,35,18,138,180,238,113,215,137,180,205,212,194,4,144,63,155,202,113,203,165,209,131,75,178,212,139,186,91,144,4,138,109,114,255,151,191,114,190,104,253,139,213,11,19,64,90,175,206,30,23,151,106,41,214,23,209,220,50,36,72,254,43,8,237,242,227,231,148,72,130,76,149,93,62,175,48,1,228,57,128,7,248,104,27,96,146,200,50,139,0,227,94,39,129,180,35,113,46,161,4,135,80,92,168,108,29,47,76,0,30,238,195,109,224,156,150,145,167,232,197,96,115,11,146,0,109,201,217,159,44,255,92,166,168,84,64,0,57,126,109,134,203,179,0,207,162,85,86,1,54,198,45,67,130,57,179,63,41,195,253,111,42,37,255,34,168,31,168,250,191,117,156,23,252,5,13,255,143,93,242,1,38,234,210,146,255,11,228,186,175,202,21,13,188,240,151,69,188,170,221,126,198,70,28,126,64,63,6,105,14,113,148,43,43,135,178,221,223,123,39,44,243,191,238,154,143,48,136,242,140,224,203,160,108,40,90,185,48,255,165,56,165,118,113,123,185,62,135,49,36,127,155,168,180,227,203,56,110,
173,164,212,66,0,96,192,75,186,124,10,208,190,164,193,31,136,144,146,115,136,44,247,148,78,95,35,129,63,228,185,184,167,132,184,200,79,72,18,87,217,72,171,136,0,60,98,233,92,213,177,164,59,36,183,119,47,130,100,166,79,213,62,209,97,226,124,228,215,49,251,217,208,202,14,129,12,104,40,218,129,48,235,104,234,137,129,251,226,226,244,25,171,218,23,116,206,171,154,95,17,130,52,63,70,23,36,20,141,86,182,2,48,22,218,140,81,103,26,161,44,222,9,72,128,185,13,79,18,38,147,99,101,1,33,204,21,4,185,69,53,189,104,51,154,157,159,148,119,58,145,134,118,182,191,87,72,0,6,65,110,5,156,166,129,236,203,242,225,145,56,166,136,67,189,23,136,224,103,48,154,77,28,57,116,197,237,127,12,74,112,167,158,200,65,146,39,165,86,54,44,179,121,188,130,199,64,117,204,23,0,120,138,115,188,142,244,240,179,43,190,196,103,247,56,168,146,224,216,181,195,31,152,224,143,51,240,71,28,252,25,18,233,13,135,43,194,32,132,200,17,101,78,184,99,101,241,31,174,32,196,57,40,194,171,146,255,152,133,204,35,212,101,82,10,73,62,124,
33,242,203,168,135,50,221,206,233,85,93,66,81,81,221,14,184,65,66,30,28,151,115,24,23,89,66,178,253,163,241,156,205,185,213,107,9,123,94,107,163,98,2,240,192,114,128,78,57,97,45,34,112,159,44,242,221,68,151,250,164,173,67,229,98,247,202,9,192,184,228,72,208,184,204,254,59,128,73,253,138,192,58,226,207,202,36,217,250,70,115,54,206,169,251,172,93,203,212,219,1,1,252,64,73,223,87,61,9,120,102,58,95,42,127,161,46,171,197,61,250,33,169,79,247,185,206,95,239,159,148,207,205,244,174,84,119,205,57,158,115,235,119,190,183,178,27,200,46,174,52,177,199,59,56,118,14,17,22,26,168,119,252,55,52,6,155,52,169,119,207,151,214,238,101,5,8,236,214,222,19,220,179,221,186,68,96,199,179,124,249,177,176,171,86,225,181,214,199,192,41,168,62,113,46,96,226,146,82,232,136,85,226,132,128,60,190,55,191,17,174,8,47,8,59,157,219,107,248,209,142,239,28,20,225,37,95,125,44,84,202,214,147,196,64,238,85,8,142,153,251,216,231,80,246,210,13,52,250,219,2,164,123,161,254,142,91,75,184,244,146,157,233,67,1,220,247,
177,215,7,6,71,209,61,19,96,24,8,125,129,8,67,157,5,238,222,241,14,13,113,216,173,188,3,1,6,240,105,27,34,176,227,89,230,60,37,116,37,107,190,190,19,1,66,156,169,39,3,167,33,254,170,188,151,211,67,52,222,149,0,225,24,169,83,218,254,174,190,7,112,93,25,190,14,103,5,142,191,199,44,231,145,152,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,128,33,96,8,24,2,134,192,222,17,248,15,0,0,255,255,3,0,9,62,240,217,152,252,30,41,0,0,0,0,73,69,78,68,174,66,96,130);

default_alt128H
:array[0..813] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,2,245,73,68,65,84,120,1,236,221,1,78,26,1,24,68,225,197,244,94,229,102,181,39,107,79,38,133,54,52,33,45,56,10,10,59,255,183,201,198,16,71,96,222,60,89,18,18,93,22,7,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,8,32,128,0,2,235,35,176,249,177,44,135,115,238,241,52,183,250,239,225,183,251,254,251,115,174,4,67,5,248,59,254,209,255,177,18,12,20,224,159,241,71,75,48,76,128,179,227,143,149,96,144,0,255,27,127,243,125,127,253,223,159,39,199,118,210,123,130,33,2,156,27,255,229,121,89,14,231,92,9,6,8,112,105,252,227,111,254,92,9,202,5,72,198,159,45,65,177,0,111,25,127,174,4,165,2,188,103,252,153,18,20,10,112,205,248,243,36,40,19,224,22,227,207,146,160,72,128,91,142,63,71,130,18,1,62,98,252,25,18,20,8,240,145,227,247,75,176,114,1,62,99,252,110,9,86,44,192,103,142,223,43,193,74,5,184,199,248,157,
18,172,80,128,123,142,223,39,193,202,4,120,132,241,187,36,88,153,0,203,246,136,255,207,215,195,199,184,135,79,242,238,117,156,251,20,241,94,207,231,237,143,187,121,251,143,220,243,39,54,187,235,31,253,146,52,79,207,203,178,251,118,253,99,236,86,195,117,109,175,0,215,111,227,30,78,8,16,224,4,199,188,27,4,152,183,249,73,227,47,39,183,30,254,198,123,174,173,215,92,215,47,189,95,120,120,88,209,19,244,10,16,97,234,13,17,160,119,219,168,25,1,34,76,189,33,2,244,110,27,53,35,64,132,169,55,68,128,222,109,163,102,4,136,48,245,134,8,208,187,109,212,140,0,17,166,222,16,1,122,183,141,154,17,32,194,212,27,34,64,239,182,81,51,2,68,152,122,67,4,232,221,54,106,70,128,8,83,111,136,0,189,219,70,205,8,16,97,234,13,17,160,119,219,168,25,1,34,76,189,33,2,244,110,27,53,35,64,132,169,55,68,128,222,109,163,102,4,136,48,245,134,8,208,187,109,212,140,0,17,166,222,16,1,122,183,141,154,17,32,194,212,27,34,64,239,182,81,51,2,68,152,122,67,4,232,221,54,106,70,128,8,83,111,136,0,189,219,70,205,8,16,97,234,13,
17,160,119,219,168,25,1,34,76,189,33,2,244,110,27,53,35,64,132,169,55,68,128,222,109,163,102,4,136,48,245,134,8,208,187,109,212,140,0,17,166,222,16,1,122,183,141,154,17,32,194,212,27,34,64,239,182,81,51,2,68,152,122,67,4,232,221,54,106,182,178,63,23,31,117,122,37,180,251,186,15,108,95,9,141,249,246,64,1,14,227,111,206,8,112,131,127,73,180,50,117,92,2,86,54,216,173,159,46,1,110,77,116,101,247,55,224,18,240,242,115,255,146,127,184,238,59,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,64,0,1,4,16,232,33,240,11,0,0,255,255,3,0,198,5,123,162,42,28,7,97,0,0,0,0,73,69,78,68,174,66,96,130);

default_wait128H
:array[0..1156] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,128,0,0,0,128,8,6,0,0,0,195,62,97,203,0,0,4,76,73,68,65,84,120,1,236,156,81,118,155,48,16,69,237,164,11,235,206,154,172,172,93,89,221,206,7,39,4,131,132,65,210,188,25,174,62,98,131,64,26,221,247,60,146,101,218,219,141,2,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,64,54,2,119,157,1,221,31,58,177,140,136,228,33,193,254,109,196,80,233,67,151,0,6,208,213,102,72,100,24,96,8,102,221,78,126,232,134,166,49,71,182,227,163,185,198,33,3,180,83,56,100,75,24,32,164,108,237,130,198,0,237,88,134,108,73,120,13,160,57,103,134,84,185,16,52,25,160,0,231,10,85,24,224,10,42,23,198,136,1,10,112,174,80,37,177,31,189,14,122,185,6,136,182,47,16,35,126,50,192,186,251,46,115,22,3,92,70,234,245,129,98,128,117,46,151,57,43,188,15,80,211,160,54,199,122,215,215,226,215,168,39,3,104,232,224,22,5,6,112,67,175,209,49,6,208,208,193,45,138,192,107,128,229,190,0,115,254,17,23,145,1,142,80,75,116,15,6,72,36,
230,145,161,96,128,35,212,18,221,19,120,13,176,84,97,244,154,96,217,127,204,227,64,25,224,237,35,14,226,56,177,6,50,192,227,215,237,22,1,172,197,104,177,198,40,194,6,184,127,62,35,84,55,193,150,248,107,99,121,30,157,199,25,225,231,1,12,71,9,232,223,143,215,128,157,221,39,168,245,214,50,214,90,95,237,234,133,51,128,13,210,68,94,251,244,168,101,130,152,226,27,97,113,3,88,136,234,38,136,43,126,16,3,40,155,32,182,248,70,86,124,13,96,33,206,75,75,224,181,53,193,188,223,181,247,45,99,89,107,127,204,185,0,83,192,28,132,202,116,144,67,124,35,27,204,0,22,178,183,9,242,136,31,212,0,158,38,200,37,190,145,12,182,6,176,144,231,101,164,32,35,251,154,143,177,239,251,224,6,48,56,35,132,25,209,71,95,161,183,90,79,96,128,222,38,200,43,190,145,75,98,128,94,38,200,45,126,50,3,180,54,65,126,241,141,216,187,253,201,83,30,127,254,175,9,44,171,253,92,140,201,142,63,23,231,106,135,191,159,47,176,223,37,236,107,104,158,18,112,31,160,6,127,107,159,160,118,95,173,62,159,248,54,226,132,6,176,97,245,248,148,
246,104,211,98,245,45,137,158,9,124,21,228,217,223,2,94,237,79,243,250,164,25,64,19,182,98,84,24,64,81,149,129,49,97,128,129,176,21,187,186,240,26,96,249,239,8,20,229,233,31,83,210,12,96,155,56,173,75,143,54,91,199,248,122,123,9,13,176,181,131,247,58,156,239,119,168,61,136,250,61,186,163,71,201,12,176,37,254,218,147,197,53,100,107,247,228,51,193,133,127,12,218,179,15,80,50,84,142,141,161,36,25,160,151,80,91,219,202,121,50,65,2,3,244,18,127,154,34,114,155,32,184,1,122,139,159,223,4,129,215,0,173,197,191,230,154,32,104,6,104,45,254,244,73,175,189,230,155,14,2,26,192,75,252,201,28,185,76,16,204,0,222,226,231,51,65,160,53,128,138,248,147,9,236,85,49,166,121,124,245,247,65,12,160,12,90,57,182,20,6,136,0,56,66,140,235,102,16,207,0,145,192,70,138,245,203,12,194,6,104,13,180,246,61,191,86,255,5,109,251,93,235,152,183,123,106,85,35,252,45,192,246,219,151,69,253,209,236,210,87,196,229,88,52,142,133,13,176,4,164,46,254,20,239,150,9,166,122,173,215,64,6,48,176,81,74,156,88,19,63,19,88,155,
211,207,214,71,49,99,57,206,64,25,160,60,16,106,143,17,192,0,199,184,165,185,11,3,164,145,242,216,64,18,173,1,206,206,233,103,239,63,38,128,247,93,100,0,111,5,156,251,199,0,206,2,120,119,143,1,188,21,112,238,63,240,26,224,236,156,221,251,126,103,101,119,118,79,6,216,9,42,235,101,24,32,171,178,59,199,133,1,118,130,202,122,153,240,243,0,181,57,90,93,146,24,241,147,1,212,125,212,57,62,12,208,25,176,122,243,24,64,93,161,206,241,9,173,1,150,115,102,231,145,187,55,175,241,127,20,145,1,220,141,224,27,0,6,240,229,239,222,59,6,112,151,192,55,0,225,223,2,52,230,200,118,242,104,174,113,200,0,237,20,14,217,18,6,8,41,91,187,160,49,64,59,150,33,91,18,94,3,104,206,153,33,85,46,4,77,6,40,192,185,66,21,6,184,130,202,133,49,98,128,2,28,170,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,64,68,2,255,0,0,0,255,255,3,0,86,211,84,93,1,199,50,206,0,0,0,0,73,69,78,68,174,66,96,130);


//------------------------------------------------------------------------------
//64px solid cursors -----------------------------------------------------------
//------------------------------------------------------------------------------

modern_arrow64
:array[0..1300] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,4,220,73,68,65,84,120,1,236,154,89,72,91,89,24,199,79,182,49,49,26,151,186,68,99,213,186,68,35,145,104,52,168,243,160,82,23,92,70,5,183,186,203,208,183,82,90,102,232,32,149,50,43,125,40,195,128,76,116,80,234,56,3,153,136,14,184,32,197,7,41,62,41,136,15,162,15,62,22,31,68,4,181,168,104,139,36,169,206,247,93,122,66,181,196,92,109,39,36,55,231,64,184,55,55,39,222,243,255,221,239,124,255,243,29,35,33,208,68,34,17,17,139,197,120,234,119,141,83,173,82,169,2,147,146,146,180,241,241,241,42,185,92,238,87,16,56,0,32,60,166,180,180,212,90,89,89,249,171,86,171,85,7,6,6,114,81,225,15,36,56,0,161,161,161,114,147,201,164,239,238,238,190,11,16,158,235,245,250,20,165,82,9,51,67,36,120,6,206,137,143,161,111,48,24,36,157,157,157,213,53,53,53,255,26,141,198,156,240,240,112,177,208,33,80,0,220,163,150,74,165,4,166,128,168,173,173,45,187,190,190,222,154,147,147,115,59,58,58,90,42,228,4,73,1,156,209,88,71,
177,144,19,72,83,83,147,182,185,185,249,239,188,188,188,59,177,177,177,1,66,133,64,1,156,155,236,24,246,81,81,81,164,174,174,78,211,218,218,250,71,97,97,225,195,196,196,68,165,76,38,163,156,4,115,164,0,62,202,250,8,33,44,44,140,84,84,84,168,96,74,252,82,82,82,242,67,106,106,106,152,66,161,16,140,120,20,226,4,224,74,85,80,80,16,41,46,46,254,2,146,227,55,229,229,229,125,105,105,105,26,184,6,124,206,5,141,171,175,123,253,117,183,0,80,1,58,4,216,164,180,163,163,163,189,170,170,234,47,176,201,244,224,224,96,65,56,4,7,128,207,227,196,249,159,153,153,41,1,8,165,181,181,181,227,96,147,166,136,136,8,159,135,224,140,0,62,33,45,145,72,72,74,74,138,8,18,99,102,99,99,35,218,100,133,90,173,246,105,155,116,2,56,59,115,58,225,165,243,22,237,48,46,46,142,52,52,52,36,183,180,180,252,89,80,80,208,165,209,104,228,8,199,23,155,19,192,85,6,143,209,18,25,25,73,96,197,168,134,104,248,189,168,168,232,17,216,100,112,64,64,192,85,254,140,87,244,117,2,224,147,7,46,142,56,36,36,132,128,51,40,219,219,219,
191,135,98,234,231,228,228,228,27,190,102,147,20,192,181,61,13,138,38,2,11,37,25,216,228,125,88,51,152,117,58,221,77,112,141,235,240,188,200,215,35,239,57,0,124,231,191,171,17,97,232,231,230,230,74,1,194,29,176,73,75,118,118,182,14,246,24,124,194,33,104,4,184,210,198,251,58,22,82,25,25,25,98,176,201,66,88,66,163,77,22,192,114,90,194,199,93,120,223,228,127,232,200,1,192,65,126,142,129,162,19,192,206,18,218,164,30,138,41,11,216,228,87,49,49,49,50,111,46,164,104,4,208,227,39,51,70,177,80,61,18,40,167,111,129,77,62,7,155,252,26,108,83,225,173,54,249,217,132,127,72,14,163,9,86,137,164,186,186,58,18,10,169,62,168,37,190,131,200,240,74,155,164,0,248,173,130,62,84,201,227,28,109,178,172,172,76,1,121,225,9,56,197,143,176,106,12,226,241,53,143,118,161,0,174,109,131,238,70,139,27,172,249,249,249,50,216,110,235,130,197,211,13,119,253,61,253,185,148,222,240,42,73,16,109,211,149,117,158,158,158,114,159,209,62,120,220,223,223,39,59,59,59,235,39,39,39,175,233,253,188,229,232,4,192,103,64,40,
6,132,144,245,245,117,199,209,209,209,59,104,196,225,112,16,16,125,134,231,239,223,227,57,54,27,125,29,28,28,236,44,45,45,245,109,110,110,190,229,115,31,79,246,161,83,192,237,61,81,252,238,238,46,153,158,158,126,213,223,223,223,101,54,155,139,7,6,6,190,28,28,28,52,13,13,13,25,135,135,135,13,35,35,35,122,139,197,162,179,90,173,186,209,209,81,253,216,216,152,97,124,124,220,56,51,51,115,123,117,117,245,5,64,59,117,123,35,15,119,160,17,224,54,7,96,24,207,206,206,110,129,152,123,43,43,43,47,247,246,246,56,49,8,198,151,27,5,112,169,134,195,195,67,50,55,55,183,7,79,255,219,181,181,181,121,20,239,235,194,169,96,183,83,224,248,248,152,204,207,207,31,79,77,77,61,134,48,158,130,28,224,16,138,120,132,112,41,0,200,218,100,97,97,193,6,226,159,46,47,47,255,179,189,189,109,199,44,47,164,70,1,128,11,158,79,3,54,155,141,64,230,182,79,78,78,254,6,71,243,214,214,214,9,100,117,33,105,231,180,112,0,46,138,183,219,237,4,18,157,99,98,98,98,16,34,224,25,216,215,27,161,61,121,250,36,185,141,188,132,132,
4,53,212,243,119,211,211,211,165,40,20,124,254,29,88,216,24,204,253,222,141,141,141,125,140,6,65,55,216,238,190,217,219,219,187,186,184,184,232,192,87,79,79,207,139,172,172,172,88,191,249,177,4,238,222,64,237,158,4,53,252,3,40,97,127,130,117,123,2,254,71,200,175,26,214,241,0,66,132,191,9,240,197,221,93,191,122,88,76,44,35,192,8,48,2,140,0,35,192,8,48,2,140,0,35,192,8,48,2,140,0,35,192,8,48,2,140,0,35,192,8,48,2,140,0,35,192,8,48,2,140,0,35,112,117,2,255,1,0,0,255,255,3,0,76,48,130,204,238,54,183,26,0,0,0,0,73,69,78,68,174,66,96,130);

modern_alt64
:array[0..1577] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,5,241,73,68,65,84,120,1,236,154,75,76,99,85,24,199,239,237,155,71,161,148,55,229,85,160,148,242,42,15,33,72,162,211,133,25,6,117,74,6,42,72,102,48,18,151,16,227,14,72,88,145,72,76,220,184,114,195,70,112,33,174,136,11,23,186,49,6,156,21,36,64,120,36,4,72,16,35,175,48,19,140,4,132,50,245,255,53,45,193,78,185,246,113,238,237,230,220,164,233,235,246,222,115,126,223,255,251,127,223,57,32,8,252,224,4,56,1,78,128,19,224,4,56,1,78,128,19,224,4,56,1,78,128,19,224,4,100,39,160,211,233,68,131,193,32,170,84,42,217,239,21,201,13,20,29,69,86,86,150,80,84,84,100,46,46,46,174,200,203,203,211,137,162,24,201,24,101,61,71,81,0,233,233,233,234,230,230,230,103,29,29,29,95,215,213,213,213,26,141,198,132,19,80,12,128,197,98,17,242,243,243,115,91,91,91,7,186,186,186,92,118,187,253,35,40,33,73,173,86,203,26,225,255,187,184,98,0,48,16,177,172,172,236,237,234,234,234,186,198,198,70,77,75,75,75,87,97,97,161,35,
41,41,41,161,42,80,12,0,162,111,44,41,41,233,117,56,28,58,72,95,112,58,157,197,149,149,149,159,88,173,214,164,68,26,162,34,0,32,127,17,230,87,93,85,85,245,32,39,39,71,160,9,67,254,42,164,195,35,128,177,155,205,230,132,169,64,17,0,25,25,25,90,200,253,131,154,154,26,19,202,160,63,45,83,82,82,4,24,97,49,160,12,228,230,230,234,19,165,2,217,1,144,249,101,102,102,90,32,253,247,160,2,85,176,244,209,51,82,66,13,47,120,92,80,80,224,48,153,76,9,81,129,236,0,16,113,149,205,102,123,8,0,229,148,251,119,143,228,228,100,82,129,21,223,125,12,80,134,68,84,4,89,1,64,246,2,228,109,134,209,245,2,130,38,84,230,244,158,84,128,222,192,157,157,157,109,71,170,40,174,2,89,1,80,233,195,4,27,144,231,173,72,131,187,193,191,125,77,94,128,138,80,132,199,51,168,64,241,238,80,86,0,136,190,1,110,255,33,106,127,138,86,171,189,157,244,221,23,164,130,210,210,82,117,83,83,147,27,21,194,129,170,160,168,10,100,3,64,242,135,164,173,232,248,58,96,114,146,147,34,47,168,173,173,45,67,149,120,138,245,130,78,73,47,144,13,
0,58,60,53,242,222,141,73,229,211,4,165,142,160,10,234,235,235,251,160,130,26,37,189,64,22,0,40,119,2,38,146,11,0,221,104,127,213,193,210,39,5,129,188,160,161,161,193,66,16,168,47,208,104,52,82,167,51,251,78,22,0,24,157,104,181,90,219,209,234,58,81,223,35,26,44,169,0,191,81,161,44,118,195,7,170,144,10,146,105,19,209,69,35,56,73,22,0,88,235,167,194,216,250,80,223,181,209,228,115,64,5,86,248,65,47,150,206,250,104,126,27,193,92,195,158,194,28,0,92,159,150,189,212,247,187,32,229,168,162,24,244,2,168,160,31,229,83,17,47,96,14,0,230,167,5,132,30,152,159,89,175,215,135,165,46,245,33,169,0,203,229,34,148,78,15,22,73,178,123,1,83,0,20,125,68,189,144,250,126,188,190,237,251,165,38,28,250,93,192,11,212,148,6,40,165,212,29,134,158,194,244,61,83,0,112,110,234,251,223,129,252,109,161,125,127,52,163,38,21,160,61,166,238,240,73,90,90,154,65,206,138,192,20,0,250,249,12,152,95,47,220,95,75,145,140,245,160,223,194,3,180,212,24,85,84,84,84,2,72,84,94,18,205,125,99,31,101,200,93,32,121,17,15,39,228,
223,74,187,191,241,30,169,169,169,2,218,227,18,116,146,30,168,64,39,151,10,152,1,192,164,245,0,64,125,191,145,197,96,3,21,65,139,138,240,20,74,168,140,39,165,164,130,193,4,0,228,42,32,74,180,174,127,72,125,127,36,157,159,212,160,130,223,145,10,200,11,160,130,110,172,38,245,168,48,193,175,152,61,51,1,128,114,167,134,241,189,143,232,91,200,192,88,29,119,84,208,95,94,94,94,17,143,175,220,55,166,184,1,80,244,97,126,57,48,171,39,232,251,53,82,209,247,249,124,130,215,235,21,78,79,79,133,195,195,67,223,249,249,185,64,159,73,29,1,47,176,2,64,31,58,76,3,107,8,113,3,32,189,195,249,223,132,76,27,239,235,251,105,146,215,215,215,254,73,47,44,44,252,61,59,59,251,124,106,106,234,199,185,185,185,63,22,23,23,111,78,78,78,252,96,194,129,160,9,195,91,116,88,40,245,163,196,150,211,223,22,195,157,23,235,103,113,47,185,176,234,75,9,244,253,175,117,109,52,241,171,171,43,225,232,232,200,183,185,185,249,215,218,218,218,111,171,171,171,223,239,236,236,252,124,115,115,115,142,232,250,247,11,176,8,234,194,
228,154,145,66,122,218,16,161,92,191,27,105,248,11,85,132,210,229,229,101,207,214,214,214,23,187,187,187,255,196,58,225,208,223,197,5,0,145,33,249,35,253,255,219,247,211,196,47,47,47,253,17,95,89,89,57,95,95,95,255,9,19,255,110,111,111,239,215,179,179,179,23,7,7,7,175,72,254,88,54,175,238,239,239,175,3,226,52,82,169,137,182,206,145,70,157,0,145,67,203,104,218,70,163,157,36,130,129,115,53,0,253,24,159,77,225,247,127,94,92,92,132,206,69,249,247,104,123,85,3,3,3,159,205,207,207,95,35,210,62,122,96,130,190,141,141,13,47,100,126,52,62,62,254,77,79,79,79,39,122,251,12,218,18,167,200,134,243,8,228,54,237,31,136,112,124,67,103,103,167,109,112,112,240,211,137,137,137,95,112,141,151,0,232,61,62,62,246,45,45,45,121,199,198,198,102,113,45,19,75,163,141,139,26,1,192,128,223,157,158,158,254,125,123,123,251,21,6,123,61,51,51,179,55,58,58,250,149,219,237,126,11,145,52,98,226,226,125,251,129,225,110,142,101,48,69,91,213,222,222,110,242,120,60,15,134,134,134,190,156,156,156,124,62,50,50,242,173,
203,229,170,66,186,48,245,128,112,99,136,248,51,154,24,22,45,58,12,180,15,209,249,97,120,120,248,115,0,121,3,41,145,76,253,64,44,171,193,224,205,105,27,13,185,47,194,252,180,109,109,109,153,180,186,100,217,99,4,239,19,247,51,254,219,195,31,49,128,72,67,30,235,105,39,39,248,231,175,184,47,30,184,0,121,64,240,193,234,154,204,175,67,3,100,209,2,51,31,24,191,32,39,192,9,112,2,156,0,39,192,9,112,2,156,0,39,192,9,112,2,156,0,39,240,26,129,127,1,0,0,255,255,3,0,207,192,75,190,53,142,167,213,0,0,0,0,73,69,78,68,174,66,96,130);

default_arrow64
:array[0..539] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,227,73,68,65,84,120,1,236,217,97,114,131,32,16,5,96,172,61,151,146,120,46,141,209,115,153,154,147,89,158,133,206,42,49,49,198,31,194,46,51,140,168,164,245,125,128,205,80,165,164,40,149,36,137,230,234,240,101,131,107,131,80,115,68,112,0,200,126,225,136,64,1,88,34,204,1,216,33,76,0,242,60,7,0,10,155,229,48,1,200,178,76,117,93,247,71,192,4,97,2,128,228,90,107,85,150,37,27,4,15,0,201,235,186,102,131,240,16,128,19,194,34,0,23,132,167,0,28,16,94,2,196,142,176,10,32,102,132,213,0,177,34,188,5,16,35,194,219,0,177,33,108,2,136,9,97,51,64,44,8,31,1,196,128,240,49,64,232,8,187,0,132,140,176,27,64,168,8,187,2,132,136,176,59,64,104,8,155,1,206,231,179,74,211,116,177,182,109,11,11,87,14,187,199,184,10,0,59,68,243,82,85,213,252,210,171,243,67,34,124,191,122,106,140,244,253,126,31,247,10,177,95,232,10,218,216,69,198,61,83,174,195,48,212,238,94,72,199,167,51,192,133,71,160,166,105,188,92,100,22,92,
188,155,129,92,88,4,160,225,145,5,35,221,247,253,36,150,155,5,184,24,234,191,213,30,2,144,240,72,124,50,21,199,40,103,129,7,64,195,155,117,125,50,21,225,175,0,136,113,22,36,8,102,167,47,93,199,61,194,227,158,43,166,207,143,105,107,188,248,110,183,155,187,60,30,177,52,138,162,24,219,230,115,227,207,156,116,56,240,137,55,3,204,179,122,225,237,243,71,57,11,230,0,75,225,149,93,10,61,48,232,95,4,140,62,89,54,214,42,156,3,5,88,12,79,226,252,207,2,124,57,66,112,76,125,251,93,160,55,253,240,206,168,73,255,48,154,102,125,235,181,79,138,119,129,169,3,169,56,95,253,249,181,191,231,176,253,16,214,134,231,21,156,142,8,171,17,167,193,165,45,2,34,32,2,34,32,2,34,32,2,34,32,2,34,32,2,34,32,2,34,32,2,34,32,2,34,32,2,34,32,2,34,16,180,192,47,0,0,0,255,255,3,0,234,135,208,59,32,69,240,14,0,0,0,0,73,69,78,68,174,66,96,130);

default_work64//part image and square (w=h) to enable rotation
:array[0..618] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,24,0,0,0,24,8,6,0,0,0,224,119,61,248,0,0,2,50,73,68,65,84,120,1,236,84,191,139,90,65,16,30,95,158,28,247,14,17,12,24,60,17,130,157,221,179,147,75,37,130,138,88,136,26,107,33,22,98,74,45,84,16,11,69,5,11,139,52,66,42,109,2,137,133,149,136,16,172,46,8,22,250,15,8,1,49,36,98,123,39,65,241,101,230,241,46,16,112,246,66,170,20,183,197,14,59,223,204,55,191,118,23,224,105,61,210,1,19,135,155,205,102,205,235,245,130,201,196,154,128,166,105,176,88,44,224,112,56,176,70,50,23,64,85,85,24,143,199,32,203,172,9,28,143,71,8,133,66,48,159,207,57,26,96,189,151,203,229,125,36,18,81,236,118,251,217,42,40,251,237,118,11,100,199,178,35,240,140,3,145,224,189,211,233,124,59,28,14,205,137,68,2,82,169,20,196,98,177,223,50,30,143,67,191,223,191,95,175,215,47,145,131,13,194,86,64,78,146,36,105,52,131,82,169,4,181,90,13,42,149,10,52,155,77,40,151,203,208,104,52,128,112,17,57,98,124,5,72,44,91,44,150,55,209,104,212,74,153,19,105,189,94,7,69,81,32,16,8,192,
102,179,129,94,175,247,125,183,219,189,67,158,35,145,157,91,236,244,141,219,115,227,247,251,63,117,187,221,107,135,195,161,87,210,110,183,1,219,2,217,108,246,219,116,58,125,141,164,95,104,30,220,98,3,144,131,17,228,21,14,251,243,96,48,184,160,91,67,183,42,153,76,254,28,141,70,1,52,185,21,145,235,28,180,137,22,6,185,242,249,124,63,38,147,201,213,67,239,131,193,224,221,108,54,123,129,228,119,34,95,194,36,145,129,81,129,106,179,217,48,113,25,168,61,36,233,140,126,170,129,139,40,248,0,134,51,205,224,99,167,211,185,192,151,173,19,145,164,51,233,81,113,243,88,16,81,5,151,30,143,231,3,13,216,237,118,195,126,191,135,66,161,160,75,58,147,158,112,12,114,41,42,65,244,14,36,171,213,250,220,229,114,233,164,197,98,17,170,213,42,144,108,181,90,64,122,194,145,92,148,164,16,84,78,167,147,137,50,207,229,114,58,121,62,159,215,37,157,73,79,56,6,80,68,21,176,209,113,152,95,177,191,74,58,157,134,213,106,5,153,76,230,15,73,122,194,201,78,20,128,109,17,254,166,10,222,245,191,249,77,149,127,253,77,33,
28,14,63,60,182,179,73,210,35,195,223,244,44,246,164,252,127,58,240,11,0,0,255,255,3,0,165,220,212,220,254,224,154,188,0,0,0,0,73,69,78,68,174,66,96,130);

default_cross64
:array[0..330] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,18,73,68,65,84,120,1,236,152,219,10,131,64,12,68,221,182,255,255,199,101,197,22,31,4,101,227,14,52,105,114,10,82,148,144,203,153,113,33,46,11,63,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,5,9,52,159,153,91,63,175,219,127,222,207,227,188,145,58,79,95,158,163,246,254,254,148,111,237,233,214,70,121,7,0,192,205,123,65,10,227,128,32,66,184,181,129,3,220,208,7,41,140,3,130,8,225,214,6,14,112,67,31,164,48,14,8,34,132,91,27,147,219,224,213,62,175,206,161,230,189,255,61,161,252,43,48,233,128,175,210,251,62,175,234,174,230,81,190,39,148,119,128,4,96,35,175,92,187,115,148,28,138,250,91,125,9,192,62,192,63,255,79,158,1,247,79,219,35,164,171,211,94,205,123,172,98,185,43,239,0,0,88,108,146,57,6,7,100,86,215,50,27,14,176,80,202,28,131,3,50,171,107,153,13,7,88,40,101,142,193,1,153,213,181,204,54,185,13,90,82,143,99,212,93,126,92,97,28,81,254,21,24,35,34,2,2,16,128,0,4,32,0,1,8,64,0,2,16,128,64,66,2,43,0,
0,0,255,255,3,0,201,236,17,246,225,143,186,97,0,0,0,0,73,69,78,68,174,66,96,130);

modern_link64//part image
:array[0..801] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,28,0,0,0,28,8,6,0,0,0,114,13,223,148,0,0,2,233,73,68,65,84,120,1,236,148,193,75,211,97,24,199,223,77,171,69,233,168,38,211,116,133,225,74,172,195,98,131,36,58,72,4,106,36,88,183,46,11,148,188,52,193,78,17,94,18,26,116,137,14,91,206,133,135,24,74,224,201,83,134,116,12,86,36,213,69,41,232,232,97,198,210,82,146,202,108,125,190,191,246,51,249,57,177,63,96,15,124,120,158,223,251,62,239,243,190,239,247,125,127,175,49,101,43,43,80,86,96,7,5,42,232,63,0,13,59,112,144,254,74,112,129,76,227,234,192,57,78,181,212,183,97,246,0,53,236,134,139,112,19,78,119,117,117,185,91,91,91,9,255,217,252,252,188,73,165,82,191,105,153,133,135,240,12,150,224,28,60,9,133,66,85,237,237,237,46,229,141,143,143,43,239,45,60,128,167,240,19,172,85,202,239,130,14,24,41,20,10,135,240,74,22,91,108,120,120,88,185,145,100,50,153,238,239,239,159,34,142,129,118,188,119,116,116,180,50,28,14,19,26,51,54,54,166,188,179,46,151,235,4,190,15,148,187,38,89,180,229,243,144,210,
100,53,53,53,31,243,249,124,134,239,119,224,156,212,77,91,51,244,146,219,28,8,4,46,117,119,119,231,248,190,13,151,35,145,200,30,188,76,121,33,136,146,215,196,164,41,226,30,120,14,198,171,128,142,53,188,164,58,5,146,87,11,113,162,130,234,11,194,107,198,172,227,53,161,22,97,47,222,30,163,60,213,154,45,214,214,100,154,203,52,194,10,141,63,240,3,160,68,167,233,172,253,208,11,245,160,226,97,159,207,247,109,102,102,70,103,115,15,74,141,83,219,64,177,246,10,177,230,50,141,241,120,124,53,151,203,173,18,75,6,201,225,52,13,188,15,95,65,242,104,167,62,120,83,44,150,38,46,53,161,37,173,106,107,14,114,26,181,210,255,181,253,147,147,147,30,206,236,12,3,170,64,43,126,201,249,4,240,95,96,91,91,94,94,54,156,183,213,111,237,102,112,112,112,221,239,247,75,251,54,216,110,17,75,252,38,146,86,183,238,40,232,252,238,194,53,184,3,214,181,199,111,54,213,106,11,6,131,21,209,104,84,249,150,124,139,248,87,197,248,58,254,56,72,30,251,240,229,117,91,31,215,214,214,46,34,161,135,120,4,116,30,121,208,101,208,
100,155,243,21,171,134,106,169,166,54,166,57,22,213,241,11,114,67,67,67,23,40,118,68,158,239,125,69,84,244,24,232,162,124,128,195,60,8,161,116,58,93,95,204,211,14,170,193,206,83,174,104,130,43,16,167,102,16,217,63,17,223,130,247,146,72,166,159,180,19,30,145,176,241,227,47,44,44,152,233,233,105,131,28,223,233,235,129,44,36,19,137,68,103,44,22,211,14,172,7,66,121,155,205,235,245,26,143,199,227,166,205,205,100,159,241,125,48,5,107,246,132,196,150,4,27,79,91,38,147,113,183,180,180,152,108,54,91,224,69,209,5,185,10,47,64,239,99,7,220,224,183,56,57,49,49,225,174,174,214,38,255,154,226,185,185,57,195,229,210,98,182,60,109,118,158,237,37,177,10,54,56,168,227,91,125,50,45,82,82,234,57,115,230,57,191,85,203,30,71,88,182,178,2,101,5,74,40,240,7,0,0,255,255,3,0,79,159,226,107,221,173,14,138,0,0,0,0,73,69,78,68,174,66,96,130);

default_help64//part image
:array[0..805] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,24,0,0,0,24,8,6,0,0,0,224,119,61,248,0,0,2,237,73,68,65,84,120,1,180,85,93,104,146,81,24,126,61,186,217,44,187,145,48,204,186,240,162,203,108,73,16,68,131,6,70,35,97,131,48,136,160,165,196,252,33,214,68,108,195,177,139,6,163,221,12,12,54,26,140,165,12,239,182,96,116,225,214,69,4,179,139,168,225,69,32,116,187,132,98,37,8,43,140,165,251,190,158,227,114,243,251,108,199,175,160,23,30,207,239,251,60,231,59,239,251,30,117,164,50,89,150,85,51,127,55,212,233,116,10,7,166,24,253,135,129,65,27,231,159,190,170,62,39,62,163,96,85,38,198,152,17,184,198,152,62,13,44,0,185,223,72,48,102,56,3,224,128,146,240,140,7,10,128,72,15,207,20,238,244,153,203,229,186,217,215,215,119,43,28,14,119,14,12,12,116,58,157,206,123,54,155,109,29,235,179,16,49,139,20,14,20,128,147,3,228,23,123,123,123,141,227,227,227,108,104,104,136,13,14,14,82,34,145,160,169,169,41,125,40,20,106,179,90,173,119,176,207,75,84,191,174,102,41,145,0,25,12,6,217,100,50,81,161,80,160,
213,213,85,26,27,27,163,76,38,67,248,2,10,4,2,228,118,187,185,191,191,153,118,127,70,40,80,169,84,104,101,101,69,10,6,131,159,38,39,39,95,47,46,46,206,163,95,93,91,91,35,139,197,66,118,187,93,135,67,156,192,117,158,218,167,84,246,68,2,63,177,245,99,169,84,122,130,246,50,208,13,60,44,22,139,59,229,114,25,221,61,227,28,198,189,145,170,163,172,10,44,54,22,26,50,232,164,36,85,11,68,140,103,148,9,203,143,205,102,179,63,149,74,177,174,174,46,138,68,34,114,58,157,126,129,249,126,73,146,190,112,110,117,161,9,5,184,3,55,144,31,70,19,67,251,96,116,116,180,195,235,245,210,242,242,50,205,204,204,84,55,55,55,175,75,210,206,115,80,215,246,170,5,52,22,26,121,64,62,18,139,197,140,62,159,143,146,201,36,77,79,79,203,184,190,5,176,190,170,147,215,20,84,63,162,24,212,182,130,248,24,58,253,200,127,99,52,26,165,185,185,57,154,152,152,248,1,242,121,204,143,224,10,191,169,56,21,195,150,2,216,125,20,56,223,211,211,67,8,48,45,45,45,109,227,190,103,49,119,31,87,243,149,199,71,100,226,213,6,207,124,62,79,
72,85,218,216,216,216,198,244,7,144,35,149,154,66,216,224,177,219,213,18,131,45,108,125,19,143,199,175,160,229,15,207,119,160,184,91,189,173,5,180,124,1,200,232,6,112,26,184,0,92,5,94,2,154,76,139,64,59,82,143,159,254,41,144,3,222,2,1,60,114,109,104,91,154,22,1,27,138,111,118,120,120,184,59,155,205,50,191,223,127,8,172,119,129,179,162,71,174,174,44,20,64,138,242,245,78,224,184,199,227,33,60,219,132,23,148,251,86,129,29,45,2,194,32,35,29,37,104,188,3,217,58,10,236,156,195,225,96,185,92,142,7,250,51,192,131,221,210,154,210,160,241,45,226,222,16,104,71,115,9,184,13,240,227,151,128,71,40,176,247,104,97,202,75,80,63,21,45,5,118,73,248,223,167,254,8,250,29,64,21,228,92,4,166,36,231,51,255,40,192,93,181,153,90,224,23,0,0,0,255,255,3,0,71,117,231,8,42,110,196,60,0,0,0,0,73,69,78,68,174,66,96,130);

default_text64
:array[0..359] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,47,73,68,65,84,120,1,236,153,209,14,194,32,12,69,135,250,255,127,108,48,139,146,189,208,1,29,215,37,229,152,24,13,246,118,237,233,133,7,217,54,94,16,128,0,4,32,0,1,8,64,0,2,16,128,0,4,32,176,30,129,164,105,57,229,190,188,249,247,252,209,248,190,236,61,81,175,158,32,93,76,111,227,186,10,164,0,114,126,87,43,79,233,89,93,31,141,175,38,25,92,148,2,176,106,177,26,181,226,149,235,15,101,242,125,210,103,239,242,236,179,24,203,45,69,123,245,83,10,224,106,113,255,208,139,182,64,57,221,173,22,172,195,175,165,179,242,249,215,151,119,0,0,252,230,137,161,196,1,49,230,232,239,2,7,248,217,197,80,226,128,24,115,244,119,129,3,252,236,98,40,113,64,140,57,250,187,192,1,126,118,49,148,56,32,198,28,253,93,224,0,63,187,24,74,28,16,99,142,254,46,112,128,159,93,12,165,232,94,192,250,223,191,5,173,165,155,127,111,176,252,22,16,57,224,59,233,222,75,208,86,156,242,126,240,22,7,88,151,161,173,13,162,248,93,234,
128,209,201,141,198,207,0,114,139,3,142,194,247,67,109,254,193,118,228,231,27,4,32,0,1,8,64,0,2,16,128,0,4,32,0,1,8,64,160,70,224,3,0,0,255,255,3,0,133,169,28,196,49,3,188,125,0,0,0,0,73,69,78,68,174,66,96,130);

default_hand64
:array[0..924] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,3,100,73,68,65,84,120,1,236,90,11,110,226,48,16,13,187,156,3,209,139,128,65,220,99,57,8,34,1,113,44,68,83,78,178,220,128,3,32,209,121,179,25,215,217,166,212,73,19,59,192,140,52,177,227,239,188,151,177,61,9,36,201,147,203,239,38,248,7,131,65,70,106,72,83,210,23,82,12,243,183,201,88,177,251,176,229,117,140,32,176,175,212,222,84,244,153,93,175,215,188,162,188,215,69,191,234,88,71,224,13,181,135,38,171,213,42,217,239,247,201,100,50,193,45,196,240,245,206,46,195,38,246,2,116,150,101,182,235,98,177,64,126,106,11,238,40,83,203,3,8,151,1,54,231,169,39,198,112,17,138,109,6,55,247,34,117,9,184,23,92,222,118,42,1,222,84,61,104,67,245,128,7,125,176,222,176,90,245,0,138,19,16,33,190,22,106,188,173,136,216,176,85,2,8,71,74,106,10,5,17,18,50,35,108,70,121,239,164,81,32,244,21,10,68,135,144,227,241,200,74,89,16,2,101,33,18,144,110,40,100,206,184,160,7,151,86,9,112,163,195,225,240,99,104,9,156,64,12,
9,94,160,198,148,254,33,133,228,164,111,177,72,105,123,9,0,16,203,104,52,226,20,94,113,56,28,88,133,8,170,16,240,104,99,72,65,74,70,105,112,249,120,76,45,79,125,62,159,121,68,39,84,78,132,20,84,224,69,10,117,240,154,221,110,135,162,41,46,161,165,51,15,184,5,4,158,32,196,56,203,198,220,234,211,85,93,80,2,78,167,19,227,112,150,66,87,184,188,199,13,74,128,183,85,1,27,42,1,1,201,238,229,84,37,15,192,81,68,122,37,229,40,174,151,22,183,108,148,253,40,10,208,52,182,169,24,223,126,236,4,65,84,159,226,108,119,118,239,138,46,245,138,36,104,162,96,200,218,83,111,132,230,173,217,3,10,96,6,187,243,229,114,97,117,118,234,135,246,6,89,2,28,132,172,215,107,75,37,162,55,137,237,169,48,90,164,102,13,234,40,83,138,4,37,56,145,185,196,205,139,72,45,149,242,71,74,197,3,24,147,0,118,1,162,204,241,4,174,250,159,40,183,253,189,229,249,167,49,218,3,94,200,112,131,183,53,172,253,241,120,92,194,1,192,40,71,44,143,116,185,92,150,234,127,122,179,221,110,101,136,141,100,66,165,118,215,149,29,30,0,177,254,
67,74,204,83,192,18,0,192,68,2,31,133,161,73,136,73,64,105,15,160,115,120,6,34,176,20,170,246,3,212,61,154,148,8,40,192,49,9,216,249,159,129,132,79,4,144,23,228,68,68,48,18,242,28,211,197,147,79,4,192,148,130,132,13,242,1,61,33,199,124,161,165,20,8,185,147,19,9,120,49,66,81,10,18,112,20,66,219,150,152,71,32,176,84,122,128,128,4,9,148,103,79,192,127,0,186,112,215,226,75,177,76,25,60,229,71,252,221,172,93,197,8,216,100,139,48,59,39,178,103,223,217,209,69,189,23,1,152,184,139,24,65,206,127,26,222,190,114,119,1,242,214,152,222,4,96,16,34,225,138,180,141,64,105,62,159,203,175,71,209,158,62,176,124,185,9,162,178,66,224,166,41,173,91,3,0,120,125,110,178,49,58,224,49,197,166,98,158,96,69,181,60,64,172,146,229,128,123,120,131,47,17,206,154,151,161,162,185,190,24,208,136,0,116,150,141,81,6,2,17,80,215,35,220,83,163,216,236,164,121,84,183,23,35,144,54,38,128,59,255,251,201,27,31,74,12,238,61,132,221,189,56,94,61,154,119,223,228,71,4,184,230,145,71,24,186,135,78,73,69,222,36,211,39,208,98,
147,166,202,128,50,160,12,40,3,202,128,50,160,12,40,3,202,128,50,160,12,40,3,202,128,50,160,12,40,3,202,192,19,50,240,14,0,0,255,255,3,0,191,130,251,178,3,146,69,54,0,0,0,0,73,69,78,68,174,66,96,130);

default_move64
:array[0..879] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,3,55,73,68,65,84,120,1,236,154,11,146,156,32,16,134,113,54,247,10,147,131,69,39,23,73,78,146,97,110,178,23,73,12,63,46,5,138,15,154,87,111,85,232,42,75,68,186,225,255,22,105,116,86,136,110,157,64,39,208,9,116,2,157,64,39,208,9,176,16,184,77,66,224,248,47,13,194,135,121,57,248,32,12,60,236,33,120,30,215,125,15,15,33,254,234,250,182,118,107,219,29,122,115,226,199,241,187,192,177,24,128,180,159,9,111,31,189,55,58,173,197,79,211,40,164,148,166,239,215,235,133,179,190,184,233,89,57,43,92,180,176,134,0,66,241,86,32,39,132,70,0,142,197,115,67,104,0,224,90,60,39,132,202,0,226,197,115,65,168,8,128,46,158,3,66,45,0,82,139,249,9,65,72,115,88,237,169,22,46,140,2,105,226,157,26,231,170,125,245,125,192,227,241,67,12,195,91,112,40,101,210,158,25,31,202,123,109,224,91,219,170,3,168,45,32,55,254,151,220,0,158,191,244,202,74,111,102,244,134,102,207,134,167,174,149,123,119,116,157,210,126,247,131,123,168,
150,222,61,229,149,147,139,133,102,0,22,60,8,179,71,242,120,46,28,109,124,156,209,103,190,21,0,224,86,251,252,225,80,34,148,121,119,200,4,224,196,187,151,26,138,136,180,182,174,175,124,8,25,0,214,226,83,82,93,154,124,97,210,106,41,8,137,0,248,196,91,104,0,94,2,66,2,0,126,241,37,33,16,211,96,172,120,172,210,135,38,15,239,152,52,119,234,27,184,218,71,111,217,52,153,53,65,183,137,255,178,68,0,16,43,222,140,81,6,35,141,175,32,251,230,64,56,216,172,108,71,27,39,222,223,222,110,35,108,175,165,252,186,170,202,241,181,129,166,233,33,220,246,57,238,27,99,4,128,56,241,118,16,220,103,42,132,132,69,144,91,98,217,254,35,102,0,58,140,155,5,57,211,56,199,215,34,161,254,245,225,23,9,0,77,175,33,224,149,54,214,158,207,223,250,139,240,178,14,64,252,253,254,45,214,85,204,243,159,160,109,138,120,4,33,100,1,164,22,60,49,243,104,23,26,187,250,34,208,198,212,230,218,191,148,254,197,78,89,237,212,217,42,105,11,254,57,85,60,98,16,0,160,121,44,132,179,87,90,147,231,37,162,237,152,58,127,29,198,79,105,
107,203,17,143,72,9,139,32,32,32,197,8,147,114,48,0,46,203,21,143,113,39,0,128,27,63,132,18,226,161,132,248,8,192,197,90,248,56,216,59,181,207,165,196,99,156,137,51,192,74,92,207,4,91,91,251,108,23,225,229,81,196,24,210,45,19,0,58,118,16,210,135,145,226,25,183,213,189,138,156,241,8,248,161,205,95,65,249,53,117,202,126,118,41,243,11,114,33,0,70,174,15,64,46,31,72,201,24,224,23,164,186,37,138,17,175,200,17,47,28,10,60,2,23,61,124,242,219,37,103,192,174,84,124,182,58,217,49,26,31,108,137,175,183,183,187,225,179,43,227,55,239,180,174,222,117,130,193,123,134,252,248,207,15,189,239,151,164,8,97,170,155,127,145,2,68,54,174,5,64,119,143,69,42,13,66,40,62,47,213,157,177,168,8,0,221,210,33,180,20,143,17,86,6,64,131,208,90,124,35,0,113,16,56,196,55,4,112,14,129,75,60,70,69,248,34,132,230,37,108,253,101,9,17,75,238,237,169,35,100,0,128,33,58,8,110,192,101,246,246,46,222,167,47,1,2,255,63,75,51,99,2,4,28,221,58,129,78,160,19,232,4,58,129,78,160,19,104,79,224,31,0,0,0,255,255,3,0,77,69,138,
60,130,64,60,30,0,0,0,0,73,69,78,68,174,66,96,130);

default_ns64
:array[0..617] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,2,49,73,68,65,84,120,1,236,154,129,81,195,48,12,69,157,194,32,153,132,186,44,66,55,105,194,38,89,132,58,76,210,73,8,250,225,212,38,87,39,180,184,178,206,135,116,103,156,200,85,173,255,44,2,103,199,57,51,35,96,4,140,128,17,48,2,70,192,8,24,1,13,2,213,209,57,52,61,219,232,77,61,10,247,52,63,53,61,8,74,0,206,226,153,191,26,132,39,206,32,95,127,17,127,60,126,184,253,254,205,117,93,135,233,107,170,4,79,253,120,67,125,22,203,12,96,46,222,251,173,171,235,218,121,239,213,32,100,4,112,45,158,151,88,19,66,38,0,203,226,181,33,100,0,240,187,120,77,8,194,0,110,23,175,5,65,16,192,253,226,53,32,60,243,164,2,189,199,119,226,9,31,66,24,219,116,14,248,241,87,0,22,66,127,53,14,63,199,226,18,247,18,38,9,96,204,55,38,158,133,92,0,4,215,182,239,236,206,218,11,2,168,218,184,146,1,203,238,227,99,46,208,63,67,125,124,108,136,187,19,189,130,0,190,154,120,110,27,242,15,62,62,6,241,75,113,241,136,84,239,38,245,
11,74,143,55,0,165,175,96,106,254,86,1,169,4,75,143,183,10,40,125,5,83,243,183,10,72,37,88,122,188,85,64,233,43,152,154,191,85,64,42,193,210,227,173,2,74,95,193,212,252,173,2,82,9,150,30,111,21,80,250,10,166,230,47,184,39,136,189,191,152,141,155,162,177,1,242,97,108,41,78,102,175,80,16,192,112,88,80,185,230,246,203,27,166,174,89,11,252,235,152,32,128,159,148,112,184,177,221,190,92,229,7,63,219,244,154,125,232,251,254,51,122,96,50,253,76,234,181,228,209,152,167,228,234,211,233,228,154,230,48,190,8,1,161,220,112,36,206,198,199,227,60,134,158,206,7,232,176,228,124,180,16,200,209,81,123,184,9,2,64,194,149,167,140,107,188,1,2,81,83,209,107,74,112,84,182,219,189,242,71,2,253,90,236,248,230,209,189,36,0,228,122,55,132,156,226,145,160,52,128,187,32,228,22,159,11,192,77,16,52,196,231,4,176,10,65,75,60,146,170,240,35,175,205,95,156,192,220,185,30,120,49,157,10,0,144,198,5,194,36,169,32,249,180,159,204,51,187,84,2,128,28,102,16,130,134,248,25,9,157,27,64,24,65,232,76,111,179,26,1,35,96,
4,140,128,17,48,2,70,224,63,19,248,6,0,0,255,255,3,0,152,94,184,37,212,55,137,242,0,0,0,0,73,69,78,68,174,66,96,130);

default_pen64
:array[0..843] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,3,19,73,68,65,84,120,1,236,154,97,150,154,48,16,199,19,187,123,15,78,82,99,63,121,139,114,129,221,19,108,43,244,61,15,96,247,4,30,164,26,111,130,7,105,233,252,129,32,237,130,16,65,153,188,55,243,94,32,132,36,206,252,152,153,96,84,41,17,33,32,4,132,128,16,16,2,66,64,8,8,1,33,32,4,250,9,232,92,169,162,28,149,90,36,212,223,244,143,225,221,227,147,159,122,58,169,250,71,116,54,4,35,166,146,80,161,186,58,83,201,168,4,37,11,63,109,117,138,254,198,152,186,84,227,13,65,32,175,64,1,152,112,228,233,22,85,151,203,207,42,73,54,245,80,107,79,42,77,127,40,107,173,169,188,193,42,149,3,22,157,121,139,103,8,228,100,141,142,181,214,42,142,191,214,150,69,81,84,95,159,78,39,180,71,232,87,193,216,163,129,171,44,60,21,179,232,79,79,26,167,15,2,175,200,243,223,106,179,249,238,238,25,130,192,58,44,60,61,0,118,21,9,47,66,13,185,160,77,92,142,56,159,207,42,203,178,168,244,6,5,215,200,218,250,207,217,230,235,1,
164,171,134,33,69,204,95,83,220,152,165,58,30,127,53,188,129,167,39,220,0,224,79,226,12,79,146,212,85,59,207,8,139,75,72,240,131,112,3,0,216,90,46,135,200,252,67,132,51,132,27,114,0,76,206,45,189,9,106,170,24,42,157,185,0,247,156,184,124,81,174,18,58,166,118,22,57,225,70,0,48,171,72,134,6,6,193,56,44,133,125,194,17,194,162,79,233,238,251,200,5,126,161,128,185,184,133,195,8,0,48,167,76,136,120,47,24,146,16,49,2,194,9,194,136,16,40,141,161,35,197,178,142,171,55,192,34,28,234,59,87,42,92,194,97,10,0,89,200,16,166,0,128,231,28,44,132,169,0,4,11,97,74,0,65,66,152,26,64,112,16,238,1,32,40,8,247,2,16,12,132,123,2,8,2,194,189,1,176,135,240,8,0,172,33,60,10,0,91,8,143,4,192,18,194,163,1,176,131,128,93,157,185,196,208,183,72,108,153,23,123,134,248,138,60,68,182,219,173,122,123,251,86,117,133,250,249,138,14,182,106,240,62,141,220,15,240,254,188,230,0,91,41,95,236,48,15,217,79,104,26,191,94,175,171,185,198,109,180,206,17,2,77,8,25,93,12,218,79,104,26,191,219,237,212,251,251,207,98,158,177,
123,140,115,3,128,17,25,149,171,16,254,55,254,245,245,5,227,234,205,151,49,16,56,0,128,45,25,149,86,8,93,198,99,16,100,236,206,146,46,167,97,115,52,205,196,248,252,252,84,39,60,184,189,123,242,109,218,34,135,148,191,83,96,163,246,242,227,77,91,223,102,27,23,15,112,58,101,84,169,61,225,112,56,20,237,125,198,151,131,181,218,239,247,168,26,42,4,97,152,204,185,10,116,105,104,221,234,128,14,200,246,215,158,60,250,224,255,9,171,213,23,84,73,202,173,250,178,222,127,212,253,93,102,235,97,154,225,208,245,158,240,209,248,225,238,15,203,56,3,128,126,230,26,132,177,198,227,3,184,3,128,142,166,13,194,20,198,99,242,16,0,64,79,211,132,128,165,239,223,152,247,115,123,76,232,36,20,0,208,215,56,8,78,121,186,78,125,150,188,203,184,112,107,21,4,252,89,115,145,132,107,134,104,46,4,132,128,16,16,2,66,64,8,8,1,33,32,4,102,39,240,23,0,0,255,255,3,0,118,60,126,227,134,82,16,7,0,0,0,0,73,69,78,68,174,66,96,130);

default_person64//part image
:array[0..816] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,19,0,0,0,20,8,6,0,0,0,111,85,6,116,0,0,2,248,73,68,65,84,120,1,132,84,93,72,83,97,24,126,247,163,166,133,63,171,205,166,88,186,208,174,134,11,11,165,108,12,68,131,13,11,155,97,91,8,35,186,24,180,27,155,23,54,234,198,129,16,210,141,100,84,176,220,48,196,77,138,160,186,80,72,217,149,210,134,23,221,40,40,8,187,11,242,15,33,189,105,235,121,15,231,59,156,157,4,63,120,252,222,239,121,222,243,156,247,188,123,63,41,159,207,19,99,102,102,134,116,58,29,169,23,159,101,24,68,172,214,181,177,94,16,235,235,235,34,20,6,231,65,60,7,210,64,22,248,10,4,96,90,206,198,199,45,35,147,251,251,251,180,176,176,64,133,66,65,84,119,3,116,42,16,8,212,245,245,245,81,85,85,21,229,114,57,199,212,212,148,103,105,105,233,33,180,123,192,47,160,104,73,149,173,172,172,16,67,94,23,176,127,138,197,98,117,147,147,147,228,241,120,168,179,179,147,252,126,63,165,82,41,26,26,26,186,9,253,3,170,147,10,17,15,241,174,223,216,216,160,104,52,42,62,141,185,112,40,20,178,240,
195,101,101,101,124,86,86,77,77,13,13,15,15,147,221,110,239,2,217,163,8,114,160,31,28,28,164,229,229,101,233,19,193,113,51,110,245,246,246,82,73,73,137,54,87,58,215,214,214,82,127,127,191,148,167,77,208,103,50,25,97,36,180,179,102,179,89,196,199,238,54,155,141,249,115,218,31,194,160,206,134,200,111,188,143,62,89,155,155,155,213,82,81,60,61,61,205,95,243,13,63,216,119,181,160,109,98,1,226,199,120,60,126,197,229,114,81,69,69,133,58,87,138,185,199,179,179,179,127,113,248,172,21,139,42,99,17,197,253,92,91,91,187,141,208,220,218,218,170,24,242,216,108,110,110,82,56,28,166,213,213,213,247,208,223,112,190,122,253,55,125,114,31,184,41,201,182,182,182,171,60,26,22,139,69,50,74,36,18,249,221,221,221,4,180,16,204,255,168,141,56,150,230,76,67,150,227,252,192,96,48,216,140,70,35,97,87,100,140,6,191,252,58,224,150,251,171,104,28,20,153,33,161,26,220,23,183,219,61,154,78,167,77,139,139,139,20,137,68,40,24,12,210,248,248,56,101,179,89,93,50,153,188,220,212,212,148,68,222,40,242,139,158,87,14,
178,240,214,231,243,117,97,250,169,163,163,67,26,90,240,252,82,105,168,43,43,43,201,235,245,210,220,220,156,190,165,165,37,2,250,145,208,57,71,50,147,137,158,250,250,122,239,216,216,24,157,52,103,14,135,131,38,38,38,248,217,40,96,97,35,94,74,101,136,131,35,35,35,134,134,134,6,73,56,233,143,211,233,36,220,20,54,186,43,170,19,102,103,64,94,107,111,111,63,201,67,209,75,75,75,9,189,229,115,151,32,197,208,158,6,81,189,181,181,69,141,141,141,196,189,17,119,147,231,75,44,81,193,225,225,33,237,236,236,208,246,246,54,75,117,66,23,102,191,65,60,27,24,24,120,108,50,153,46,117,119,119,147,213,106,37,254,47,193,183,128,171,56,58,58,162,131,131,3,218,219,219,35,190,5,243,243,243,124,11,126,0,163,194,76,217,249,173,192,41,192,14,248,129,167,192,75,224,53,240,14,120,5,188,0,158,0,119,128,139,128,17,80,60,254,1,0,0,255,255,3,0,198,231,206,219,63,185,147,21,0,0,0,0,73,69,78,68,174,66,96,130);

default_pin64//part image
:array[0..802] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,18,0,0,0,20,8,6,0,0,0,128,151,109,74,0,0,2,234,73,68,65,84,120,1,156,83,93,72,147,81,24,126,246,231,148,13,37,88,45,70,86,10,66,23,46,92,98,72,50,240,98,93,24,162,40,222,212,152,119,10,57,21,4,161,11,169,196,212,100,76,35,34,72,33,83,4,81,188,80,68,244,206,59,197,192,65,10,93,36,8,50,136,169,23,91,179,139,134,99,126,61,231,232,247,109,78,36,236,192,115,206,123,222,231,125,159,239,188,231,61,31,20,229,4,201,228,49,60,30,15,0,29,241,127,67,47,210,20,69,193,218,218,87,97,105,42,58,157,206,68,88,9,59,113,243,204,54,105,1,89,134,161,183,247,53,246,246,246,48,50,18,212,40,38,221,229,102,138,232,35,222,16,221,132,143,240,144,19,95,140,18,231,134,49,149,74,81,228,157,116,50,72,212,246,140,248,216,213,213,85,80,95,95,143,178,178,50,8,247,214,214,86,225,226,226,98,97,48,24,252,198,125,39,99,190,176,18,173,4,253,238,238,46,150,150,150,164,16,167,66,34,48,61,61,93,48,56,56,8,183,219,13,171,213,10,139,197,130,170,170,42,244,247,247,99,102,
102,198,194,152,183,196,29,66,27,122,167,211,133,112,56,76,135,188,232,96,75,75,139,163,177,177,17,57,57,57,216,217,217,193,248,248,56,70,71,71,177,189,189,13,163,209,8,193,181,183,183,223,96,194,135,204,230,232,143,143,19,82,149,167,23,74,79,58,58,58,96,50,153,16,141,70,81,93,93,141,214,214,86,248,253,126,184,92,46,28,30,30,194,96,48,160,179,83,84,134,199,204,49,203,100,78,236,154,86,102,169,195,225,48,231,231,231,75,110,121,121,25,7,7,7,106,156,92,167,166,196,253,3,102,179,25,69,69,69,6,154,165,210,193,137,66,218,136,197,227,113,77,181,164,164,68,35,84,163,184,184,88,154,226,142,207,98,127,169,156,80,61,27,186,163,100,50,233,45,47,47,183,57,157,78,216,237,118,233,23,205,200,205,205,149,37,182,181,181,201,210,86,87,87,49,57,57,249,83,81,116,175,212,138,50,79,36,18,135,3,129,128,20,16,247,212,211,211,131,80,40,36,47,122,96,96,64,54,64,144,67,67,67,98,25,86,69,196,70,182,74,24,98,240,125,136,110,132,230,231,231,111,213,213,213,73,95,246,180,178,178,130,218,218,218,8,253,15,88,
226,190,202,159,19,2,12,20,59,233,171,169,169,121,57,55,55,135,188,188,60,53,78,174,137,68,2,94,175,23,11,11,11,1,69,209,191,0,82,26,159,37,36,79,101,37,251,125,118,118,246,118,83,83,147,22,40,12,190,108,52,52,52,136,211,220,227,105,142,50,201,11,66,130,100,137,254,138,138,138,247,124,241,6,155,205,38,227,99,177,24,88,238,201,250,250,122,55,69,78,255,169,12,165,140,174,165,189,20,250,17,137,68,158,178,115,215,42,43,43,37,49,49,49,129,177,177,177,48,55,207,137,211,87,156,78,185,204,210,139,83,221,39,254,108,108,108,40,155,155,155,10,237,36,241,48,171,63,151,9,164,253,76,50,18,159,124,62,159,210,220,220,44,132,62,11,95,58,226,10,22,19,175,243,231,141,19,191,105,59,174,144,122,49,148,2,143,8,247,191,74,250,11,0,0,255,255,3,0,22,111,229,221,85,58,129,50,0,0,0,0,73,69,78,68,174,66,96,130);

default_no64
:array[0..1159] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,4,79,73,68,65,84,120,1,236,152,235,145,218,48,16,199,109,210,8,105,36,136,73,33,129,20,18,76,10,73,142,66,50,136,244,145,137,211,200,145,253,73,94,100,3,54,216,146,239,203,105,103,108,189,247,241,223,213,179,40,50,101,4,50,2,25,129,140,64,70,32,35,144,17,200,8,100,4,50,2,25,129,140,64,70,224,221,33,80,190,173,197,139,202,203,59,175,26,185,166,73,109,147,74,114,222,203,175,85,14,45,115,228,222,0,128,139,209,187,145,6,8,8,243,131,49,51,0,24,127,190,24,190,219,125,115,24,24,99,154,212,7,130,181,39,87,230,183,223,127,47,172,181,151,178,100,164,48,31,16,51,1,112,107,120,85,93,112,104,27,215,155,175,170,189,3,35,116,56,175,37,111,67,57,77,110,6,0,130,241,120,252,218,112,12,131,78,167,223,23,79,107,68,172,86,159,10,242,198,248,200,160,223,122,253,249,210,175,40,74,25,252,90,81,159,138,18,3,208,111,252,173,71,251,77,0,4,192,83,32,186,99,211,130,240,161,95,141,209,45,70,70,252,100,84,219,243,
40,143,23,79,167,19,77,66,24,80,74,193,205,235,173,84,72,185,144,242,226,31,173,66,203,186,174,139,195,225,224,10,62,34,140,203,55,60,164,176,40,101,188,117,149,145,63,97,148,132,140,24,117,132,83,219,120,202,93,239,61,59,143,29,47,195,120,0,56,30,127,145,189,230,149,68,247,68,17,80,226,249,37,202,190,188,252,112,202,178,178,47,151,75,103,0,21,222,123,229,134,172,124,181,124,67,116,144,70,233,87,110,136,6,8,222,124,144,231,149,38,10,82,0,32,90,149,21,138,253,253,251,135,196,121,106,187,253,234,242,183,138,63,13,66,45,12,28,8,58,125,148,23,91,165,144,73,49,21,22,112,138,163,114,199,120,66,31,194,243,141,130,46,101,10,64,236,6,218,167,153,46,198,53,12,255,172,244,117,12,224,169,188,2,159,225,193,207,180,38,0,0,79,120,3,73,213,120,242,80,91,241,105,32,176,237,121,16,28,67,249,133,173,53,28,178,180,109,108,26,11,128,65,32,161,9,225,125,107,173,203,203,42,189,86,197,211,128,160,167,68,153,21,66,33,10,216,122,167,83,36,0,215,225,111,85,19,50,242,5,239,197,131,224,163,32,0,172,162,226,
210,72,0,186,194,57,221,121,114,123,124,147,79,9,2,59,128,151,161,81,39,145,182,234,106,49,174,148,20,128,126,209,41,64,120,181,253,252,167,183,196,2,96,16,173,71,214,86,120,90,234,187,20,13,130,133,159,202,80,153,82,101,168,159,74,177,0,140,148,27,13,194,72,121,143,187,199,2,96,17,161,247,249,48,47,135,188,50,25,4,131,44,149,161,50,17,79,253,84,138,5,160,71,238,194,244,52,52,213,147,65,24,102,59,161,53,18,0,110,117,97,94,114,159,127,158,198,130,224,183,220,113,50,30,107,19,9,64,87,128,134,167,108,77,238,120,220,109,189,87,122,22,4,119,216,49,112,80,25,225,196,217,222,114,239,201,24,174,139,188,12,113,39,47,43,46,43,28,79,185,253,65,227,110,107,240,224,102,87,152,235,75,79,224,229,215,20,140,175,42,127,231,208,203,150,244,217,210,111,42,37,136,0,127,66,211,139,74,80,132,40,120,246,152,250,76,36,132,227,111,75,150,13,242,166,229,34,35,0,161,165,145,159,243,30,81,160,33,218,120,147,54,214,137,90,190,7,52,28,9,236,251,155,205,23,199,131,23,38,79,103,188,95,55,133,73,73,2,0,130,226,
104,0,0,93,16,202,141,84,71,131,160,60,49,190,121,36,177,194,119,47,95,20,149,81,163,59,131,203,51,69,110,105,122,93,237,190,232,178,95,187,39,177,206,168,251,133,240,36,214,230,71,232,183,22,191,181,140,21,158,113,148,32,2,84,129,219,133,76,67,182,153,14,75,22,76,63,101,22,31,5,12,6,214,252,132,140,172,23,155,102,58,29,165,188,148,175,3,230,28,198,35,163,228,151,142,88,244,252,22,216,246,156,190,18,233,57,254,145,188,246,88,250,118,141,103,209,101,209,76,67,137,1,64,169,0,2,243,86,95,116,105,209,7,19,189,210,42,32,244,211,3,142,78,31,250,67,115,26,15,255,25,0,128,45,33,237,159,201,41,92,123,148,186,71,212,53,156,222,105,61,175,242,231,2,0,254,70,148,222,249,148,162,84,136,167,1,67,73,175,180,122,177,209,136,8,11,29,61,231,49,92,117,152,19,0,149,97,174,129,208,134,225,212,31,176,82,206,247,123,242,222,2,128,182,92,211,128,161,117,82,118,100,125,226,47,87,115,27,237,101,229,127,70,32,35,144,17,200,8,100,4,50,2,25,129,140,64,70,32,35,144,17,200,8,100,4,222,45,2,255,1,0,0,255,255,
3,0,24,160,5,249,95,174,29,6,0,0,0,0,73,69,78,68,174,66,96,130);

default_alt64
:array[0..444] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,132,73,68,65,84,120,1,236,217,11,110,131,48,12,6,96,131,122,175,249,100,35,236,98,203,46,182,14,167,20,109,106,162,176,45,126,72,253,35,5,42,18,72,252,217,149,170,66,132,6,1,8,64,0,2,16,128,0,4,32,0,1,8,64,192,94,128,183,37,165,187,181,217,109,229,18,248,244,78,36,221,15,193,11,128,247,192,119,127,63,4,15,128,35,248,101,121,37,233,183,230,131,96,13,240,35,248,148,22,146,238,137,96,9,240,16,252,158,122,87,4,43,128,102,240,222,8,22,0,221,224,61,17,180,1,78,7,239,133,160,9,240,235,224,61,16,180,0,254,28,188,53,194,229,190,224,216,243,204,68,87,98,222,78,91,75,105,45,231,239,7,25,99,126,57,46,213,230,28,131,229,195,204,68,159,185,124,28,120,80,2,184,237,48,231,76,210,107,237,142,35,99,57,127,208,186,190,213,166,169,95,83,2,144,76,181,190,93,87,73,59,183,35,155,30,203,165,76,30,159,125,121,172,18,0,229,118,185,150,159,188,37,164,202,65,238,75,149,235,106,151,90,105,82,91,48,218,131,1,16,
45,35,214,251,65,5,88,139,71,91,15,21,16,45,35,214,251,65,5,88,139,71,91,15,21,16,45,35,214,251,65,5,88,139,71,91,15,21,16,45,35,214,251,65,5,88,139,71,91,15,21,16,45,35,214,251,65,5,88,139,71,91,239,233,43,64,235,111,241,110,162,229,69,200,218,120,3,208,189,121,224,4,55,128,214,27,163,129,177,157,122,212,116,106,214,216,73,220,121,92,238,140,99,24,2,16,128,0,4,32,0,1,8,64,0,2,16,128,192,191,5,190,0,0,0,255,255,3,0,107,239,99,211,10,43,213,106,0,0,0,0,73,69,78,68,174,66,96,130);

default_wait64
:array[0..618] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,2,50,73,68,65,84,120,1,236,90,209,114,195,32,12,75,182,125,88,115,251,238,93,248,177,93,134,211,122,97,172,20,50,36,103,215,56,15,165,20,34,44,89,53,164,215,97,240,203,21,112,5,92,1,87,192,21,112,5,206,170,192,136,33,62,46,24,156,189,40,75,119,252,47,123,151,124,182,249,111,72,66,203,242,137,132,43,98,141,227,107,113,108,239,128,59,96,175,98,143,230,35,51,243,104,29,228,216,233,29,208,93,69,127,102,227,186,27,176,106,193,230,176,254,234,175,113,159,222,1,84,1,36,99,91,214,134,245,125,79,95,179,134,108,169,2,32,3,101,97,65,207,1,121,144,90,11,52,235,127,237,231,184,200,190,59,0,169,102,9,235,63,102,94,99,69,59,32,8,240,52,189,43,62,172,77,48,3,12,52,2,129,207,1,18,218,56,199,151,75,188,134,121,254,144,15,126,93,181,154,144,223,32,228,67,8,242,113,124,89,38,121,131,186,208,14,136,113,173,1,198,120,3,196,9,76,242,34,34,193,1,154,155,253,78,208,59,181,101,147,151,117,8,14,208,240,251,156,
96,65,94,34,37,58,64,133,168,59,65,103,106,107,69,94,214,51,16,96,93,166,90,24,143,32,111,40,64,155,8,150,153,87,193,141,28,240,189,220,250,227,169,30,140,244,83,109,117,123,140,59,137,89,92,196,34,168,180,202,173,16,222,72,151,231,49,71,14,21,128,73,172,21,155,250,52,88,11,162,244,85,168,221,135,28,55,116,192,186,29,202,25,185,24,255,54,118,157,91,156,8,28,48,18,224,254,89,32,175,1,242,236,112,19,33,170,100,35,130,129,0,247,201,151,146,104,45,2,121,187,105,35,175,59,65,90,19,172,206,4,68,7,180,145,63,218,9,36,7,244,145,79,69,97,59,129,224,0,28,121,17,130,93,19,192,2,180,145,207,171,127,222,79,29,192,22,1,44,192,112,209,128,115,18,189,253,228,231,181,117,141,94,60,189,223,244,36,152,87,251,90,95,131,100,182,104,7,48,99,165,96,155,56,160,150,233,218,56,133,249,13,212,29,192,84,183,150,217,189,227,140,88,79,239,0,240,73,208,255,33,194,112,41,21,19,228,0,255,167,40,53,75,76,112,232,57,32,125,158,103,6,173,187,7,98,141,211,239,2,80,7,32,51,131,200,110,11,198,233,29,208,34,146,207,
113,5,92,1,87,192,21,112,5,92,129,231,84,224,11,0,0,255,255,3,0,61,190,237,160,202,61,207,207,0,0,0,0,73,69,78,68,174,66,96,130);


//------------------------------------------------------------------------------
//small hollow cursors ---------------------------------------------------------
//------------------------------------------------------------------------------

default_arrow64H
:array[0..563] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,251,73,68,65,84,120,1,236,154,1,142,131,32,16,69,213,236,189,22,79,86,123,178,178,23,211,253,223,74,194,82,108,65,237,90,134,153,100,10,85,169,252,55,191,198,160,237,52,77,77,169,209,182,237,238,169,119,252,133,174,235,12,219,26,99,6,0,225,6,16,134,154,1,80,251,165,70,8,206,1,174,248,213,65,8,1,84,231,132,16,128,93,172,80,141,19,66,0,63,0,208,215,4,33,4,208,140,227,72,23,92,107,129,240,0,128,194,1,97,64,83,5,132,40,128,154,32,172,2,168,5,194,83,0,53,64,120,9,64,58,132,36,0,146,33,36,3,144,10,33,11,128,68,8,217,0,164,65,216,4,64,18,132,205,0,164,64,216,5,64,2,132,221,0,74,135,112,8,128,146,33,28,6,160,84,8,135,2,40,17,194,225,0,74,131,240,197,9,111,9,44,161,223,48,206,36,142,229,26,163,91,104,73,28,242,63,135,37,57,96,229,121,129,91,49,74,157,233,71,46,180,190,116,128,171,52,90,187,172,23,206,130,217,231,54,124,49,200,235,178,140,134,110,89,241,212,1,78,252,34,233,18,145,230,92,16,219,
23,57,252,243,54,173,2,8,196,115,230,124,126,104,216,113,177,56,194,242,59,246,13,108,75,139,40,0,79,188,133,160,30,201,150,17,171,116,209,46,120,0,224,139,71,133,251,165,202,78,164,56,23,132,0,88,97,131,228,5,143,149,159,195,183,58,54,136,114,65,8,128,130,255,136,159,9,220,63,68,186,32,4,176,38,190,89,115,1,47,140,222,223,198,227,85,70,215,191,15,88,21,239,73,161,11,12,19,162,7,180,223,236,35,25,22,201,251,1,182,197,68,203,151,164,88,197,212,137,71,170,109,161,246,20,225,71,188,36,53,3,200,41,23,97,225,248,27,210,34,79,17,142,243,206,113,10,0,158,57,199,49,247,169,190,231,243,52,0,239,145,147,255,171,71,0,232,242,79,43,107,132,2,144,85,207,124,53,234,128,124,102,178,70,168,3,100,213,51,95,141,58,32,159,153,172,17,234,0,89,245,84,53,74,64,9,40,1,37,160,4,148,128,18,80,2,74,64,9,40,129,52,2,191,0,0,0,255,255,3,0,140,64,224,230,225,248,135,225,0,0,0,0,73,69,78,68,174,66,96,130);

default_work64H//part image and square (w=h) to enable rotation
:array[0..479] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,24,0,0,0,24,8,6,0,0,0,224,119,61,248,0,0,1,167,73,68,65,84,120,1,236,148,191,74,3,65,16,135,239,14,11,61,132,4,180,12,1,83,136,196,194,20,54,130,90,166,246,13,242,10,121,147,228,17,244,53,98,167,132,52,42,215,152,86,56,174,21,146,194,179,187,243,247,133,229,12,154,217,179,178,202,192,199,204,238,252,219,217,205,37,8,182,82,115,3,225,186,191,44,203,106,25,69,17,139,92,124,111,86,222,202,32,63,46,138,162,170,19,134,149,185,10,218,169,66,127,27,20,239,10,180,37,177,28,115,203,201,190,175,1,39,127,21,117,13,124,19,6,17,93,12,57,210,254,167,56,21,76,210,249,161,217,199,79,156,41,190,9,56,57,167,131,71,209,23,19,113,41,30,196,181,192,231,155,208,59,65,161,228,133,56,17,87,226,94,244,227,56,126,151,62,23,236,227,39,206,20,243,138,90,173,22,227,15,196,72,28,11,78,62,201,243,156,135,61,19,236,15,92,156,204,205,98,54,72,211,52,80,242,76,105,67,113,43,184,10,154,32,119,98,136,159,56,159,152,13,72,114,201,137,204,166,224,228,188,5,154,117,
82,87,92,49,222,55,8,218,237,54,49,61,177,16,31,130,187,71,179,238,57,191,76,91,204,9,72,206,178,236,66,169,99,49,104,52,26,188,73,224,52,111,51,198,95,215,196,108,160,228,61,21,89,221,181,138,206,150,203,229,129,214,207,104,214,178,135,248,93,156,204,205,98,54,80,56,190,166,72,92,241,169,236,27,49,117,235,196,249,125,53,188,111,192,99,134,226,80,188,8,138,243,45,160,89,179,143,159,56,83,124,95,242,155,203,122,146,222,21,252,130,214,53,251,92,35,113,251,98,163,248,198,227,116,214,255,80,71,190,174,243,19,103,138,111,2,70,159,139,210,204,254,195,21,121,114,183,174,127,186,129,47,0,0,0,255,255,3,0,138,244,113,234,45,19,54,222,0,0,0,0,73,69,78,68,174,66,96,130);

default_cross64H
:array[0..331] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,19,73,68,65,84,120,1,236,152,209,14,131,48,8,69,117,217,255,255,178,203,178,52,173,137,36,64,141,48,122,124,177,42,5,122,238,237,67,221,54,46,8,64,0,2,16,128,0,4,32,0,1,8,64,0,2,11,18,216,99,214,188,31,215,117,143,199,251,121,93,55,178,206,219,96,0,95,197,159,87,125,148,55,24,192,216,74,204,24,0,49,220,243,84,197,1,121,180,136,233,4,7,196,112,207,83,21,7,228,209,34,166,19,28,16,195,61,79,85,28,144,71,139,152,78,222,190,178,210,121,222,151,173,207,154,205,107,63,89,46,191,5,156,14,104,154,217,137,183,153,231,251,108,30,191,115,112,192,89,9,235,147,159,252,175,82,83,126,54,143,181,239,30,143,3,58,11,203,168,41,103,153,51,198,74,138,207,230,29,107,232,198,203,59,0,0,58,163,212,141,194,1,117,181,213,173,12,7,232,56,213,141,194,1,117,181,213,173,12,7,232,56,213,141,194,1,117,181,213,173,108,242,143,144,174,136,28,37,157,10,229,25,119,127,89,126,11,220,13,148,124,16,128,0,4,32,0,1,8,64,0,
2,16,128,0,4,254,130,192,7,0,0,255,255,3,0,35,52,17,86,227,24,249,173,0,0,0,0,73,69,78,68,174,66,96,130);

default_help64H
:array[0..533] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,12,0,0,0,20,8,6,0,0,0,185,240,220,17,0,0,1,221,73,68,65,84,120,1,84,210,79,72,20,97,24,199,241,153,119,215,69,100,205,131,26,180,233,65,89,72,16,5,137,232,144,29,164,131,232,69,10,214,114,233,20,25,72,122,81,188,136,176,108,97,160,94,188,44,172,29,60,44,98,30,69,165,46,150,4,225,169,83,234,37,186,42,21,122,86,74,223,241,251,219,153,157,29,31,248,240,60,239,204,251,206,251,111,92,207,179,142,194,152,88,27,233,137,74,220,198,13,236,227,179,181,23,63,200,132,41,191,84,231,81,90,159,144,195,12,212,206,6,237,109,99,226,69,52,210,166,175,137,53,145,31,163,5,171,24,198,125,220,196,44,118,240,2,207,212,217,37,154,105,168,99,18,37,180,67,131,247,240,1,137,32,167,200,93,90,111,37,58,40,138,200,160,21,243,88,180,246,242,55,89,131,53,160,93,83,212,81,12,225,28,147,120,139,117,104,96,75,46,151,43,228,243,111,238,81,63,192,134,163,83,98,208,29,52,192,120,158,167,246,115,156,98,47,104,175,81,255,193,93,87,15,42,161,77,81,247,98,25,58,239,105,
232,116,22,80,192,92,100,15,229,251,184,197,195,247,184,192,56,154,161,206,39,216,180,68,156,162,28,156,179,190,254,10,250,136,58,167,241,14,127,49,129,3,56,225,0,106,13,24,192,207,128,150,112,132,140,181,231,191,42,93,35,75,114,92,94,234,151,168,135,214,174,122,139,99,165,179,174,194,239,26,157,65,155,216,69,22,15,161,96,86,29,138,190,229,71,56,3,63,216,127,30,233,30,186,209,19,88,34,95,139,112,64,240,180,150,252,20,31,241,13,99,28,70,116,21,193,194,120,195,139,26,146,142,244,37,190,226,16,175,209,231,47,139,138,136,206,144,166,253,8,95,172,253,55,66,46,5,239,185,155,234,229,70,167,59,166,195,119,12,26,147,216,38,119,66,251,58,69,24,225,175,193,111,161,217,250,49,5,205,118,137,57,14,99,133,76,248,139,9,7,248,15,181,23,147,164,78,129,31,225,140,59,208,214,170,43,191,2,0,0,255,255,3,0,236,98,126,127,22,97,193,245,0,0,0,0,73,69,78,68,174,66,96,130);

default_text64H
:array[0..347] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,35,73,68,65,84,120,1,236,154,193,10,131,64,12,68,181,244,255,127,217,82,104,46,66,72,50,108,144,102,159,23,113,73,226,206,155,209,67,237,113,112,64,0,2,16,128,0,4,32,0,1,8,64,0,2,16,128,192,126,4,206,30,201,231,149,155,123,253,238,95,173,207,77,207,84,189,51,69,125,53,89,225,125,59,104,6,96,14,223,5,120,194,171,245,247,185,245,235,102,0,222,134,60,161,94,125,223,122,51,0,207,105,19,100,32,162,58,171,95,127,126,173,31,249,95,19,155,18,96,206,122,48,60,199,163,62,111,158,190,190,125,2,0,160,135,103,70,39,9,152,225,163,174,130,4,232,236,102,116,146,128,25,62,234,42,72,128,206,110,70,39,9,152,225,163,174,130,4,232,236,102,116,146,128,25,62,234,42,72,128,206,110,70,39,9,152,225,163,174,130,4,232,236,102,116,54,125,23,240,126,247,143,160,69,125,235,191,27,108,255,8,52,37,192,156,206,58,22,213,69,201,176,251,213,207,205,0,188,13,121,130,34,16,222,60,125,253,225,127,136,84,55,190,30,208,195,
239,128,175,160,245,162,170,88,169,135,0,4,32,0,1,8,64,0,2,16,128,0,4,32,0,129,221,8,124,0,0,0,255,255,3,0,99,41,28,87,226,214,250,171,0,0,0,0,73,69,78,68,174,66,96,130);

default_hand64H
:array[0..909] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,3,85,73,68,65,84,120,1,236,88,139,181,218,48,12,125,121,237,0,237,6,108,130,50,73,187,201,51,163,188,73,48,27,116,4,58,9,189,55,72,28,39,60,210,196,36,54,206,177,206,17,146,255,186,215,34,17,52,111,27,145,203,229,18,133,228,61,102,85,211,52,78,245,168,86,98,246,121,133,53,179,9,0,224,35,2,255,80,21,181,36,130,126,113,50,139,0,5,41,138,242,0,219,66,189,182,69,109,81,230,123,100,180,30,223,57,199,181,32,133,70,160,123,58,165,201,172,12,0,56,81,128,39,3,10,34,188,250,98,125,37,217,185,4,148,132,109,82,172,149,128,73,52,109,120,82,205,128,13,95,238,36,104,139,102,0,94,137,172,16,89,20,21,83,24,45,74,0,40,103,133,40,170,183,50,25,132,8,21,253,47,39,177,133,208,35,32,172,14,41,44,138,4,106,37,51,220,91,209,116,176,34,170,235,204,252,177,40,1,33,48,220,248,37,192,230,213,23,216,15,140,237,96,127,65,41,30,122,10,215,178,51,149,44,74,192,32,232,51,218,59,232,39,192,253,134,101,217,124,132,17,
168,129,135,123,253,202,96,236,45,7,9,239,140,96,37,249,161,251,254,9,246,255,27,248,45,0,55,104,31,180,111,31,140,37,115,215,36,96,12,196,25,224,61,39,4,183,46,108,167,150,212,4,236,20,96,152,9,169,49,247,206,75,77,64,239,240,87,104,84,2,94,225,22,114,198,208,203,0,188,138,88,202,94,248,186,162,159,51,176,84,103,223,234,0,130,198,161,162,7,211,178,124,253,128,229,235,202,195,62,20,125,157,245,198,209,247,179,215,129,6,250,100,216,151,187,221,101,128,222,54,131,243,4,163,128,188,6,183,233,108,176,12,176,34,196,138,18,222,86,171,196,48,11,88,190,42,31,219,50,70,64,135,10,160,125,8,15,109,62,19,216,213,145,16,142,109,197,191,123,8,14,129,145,4,244,221,50,67,199,189,218,226,141,17,112,82,36,76,117,25,162,82,18,90,244,147,136,195,48,83,134,243,75,106,127,211,96,61,128,55,240,5,186,131,126,66,135,114,70,135,87,133,89,78,112,180,211,221,72,112,148,56,231,162,214,89,6,216,143,18,143,93,248,250,59,70,237,86,224,162,27,1,140,29,169,221,42,6,146,224,212,223,180,233,17,160,72,141,4,62,15,
54,79,194,29,1,250,128,75,70,2,72,150,156,41,118,71,0,131,81,18,236,129,148,42,19,124,14,34,190,36,64,73,112,176,33,9,194,254,21,132,69,22,197,206,186,182,18,125,62,36,128,231,35,19,28,140,5,118,92,41,93,5,103,100,19,171,3,198,2,152,82,35,140,173,127,56,166,15,89,193,4,15,178,141,232,135,243,199,6,158,174,3,198,54,215,76,240,152,179,116,141,144,53,253,137,121,244,43,192,9,38,32,161,85,127,17,18,112,251,86,108,241,246,189,157,147,218,78,38,64,3,35,9,30,218,145,16,251,76,80,240,130,125,40,79,165,254,117,139,248,207,38,102,233,0,128,199,30,147,126,32,97,157,195,92,75,123,184,255,255,183,137,147,166,8,178,104,202,180,187,57,81,4,112,151,47,192,120,116,159,160,180,38,98,14,108,8,156,105,223,6,99,79,187,201,9,96,196,32,65,96,8,140,118,138,28,56,9,193,186,41,147,231,204,201,66,64,24,160,146,33,232,219,7,253,204,136,78,214,0,109,123,211,102,39,32,12,38,135,31,75,192,220,183,64,14,108,171,158,89,9,88,149,222,2,54,175,25,80,192,37,173,26,98,205,128,85,233,45,96,243,154,1,5,92,82,13,177,
50,80,25,168,12,84,6,42,3,149,129,202,64,101,96,13,6,254,1,0,0,255,255,3,0,161,17,237,147,14,55,174,43,0,0,0,0,73,69,78,68,174,66,96,130);

default_move64H
:array[0..776] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,2,208,73,68,65,84,120,1,236,88,139,114,131,32,16,212,76,63,140,126,89,219,47,171,95,86,203,18,205,128,1,188,151,98,27,110,70,163,192,221,237,174,136,71,134,161,91,87,160,43,208,21,232,10,116,5,186,2,93,129,38,10,220,62,135,1,199,75,26,136,143,243,253,104,39,194,216,70,123,16,158,63,210,220,227,215,48,252,248,246,115,237,118,110,58,100,139,201,131,52,14,24,4,105,55,19,238,24,14,63,131,96,110,218,151,218,15,7,116,102,130,61,146,123,253,103,98,53,207,69,37,71,29,103,14,240,200,128,92,82,220,241,71,98,87,199,150,146,145,250,169,1,91,6,208,146,208,250,91,114,225,199,114,249,213,158,27,40,22,97,240,49,237,237,205,62,228,54,34,190,239,227,166,232,193,152,249,221,159,38,92,121,115,126,204,119,184,74,78,115,114,119,196,77,131,66,232,8,26,215,136,233,60,140,245,168,32,194,147,70,49,148,76,105,239,23,10,164,204,44,72,66,249,113,148,28,137,79,245,198,104,6,132,119,21,196,150,163,154,83,209,185,198,
199,47,114,234,205,64,0,0,217,110,108,244,192,246,35,216,236,29,148,2,196,228,215,77,205,62,116,253,136,53,151,94,4,133,0,91,242,103,110,101,145,203,70,4,161,0,45,201,175,243,199,70,4,129,0,87,32,111,39,2,179,16,162,146,199,42,93,52,87,236,41,22,68,21,143,240,47,18,158,35,214,131,176,38,248,107,250,235,200,16,128,74,62,128,117,225,44,59,9,124,65,88,38,194,72,195,72,38,207,1,63,109,114,107,124,151,80,100,156,155,212,213,91,4,205,253,141,85,117,106,216,201,195,43,88,4,27,114,59,32,245,203,191,2,68,1,32,61,229,253,10,155,28,226,115,162,108,135,75,161,230,12,110,10,190,231,120,140,175,0,107,165,157,158,83,61,90,220,227,42,127,49,229,155,67,171,203,247,201,200,231,99,237,182,214,22,153,117,177,172,5,9,59,186,217,143,112,209,40,127,77,217,14,231,226,215,240,68,25,10,151,130,69,208,166,4,45,224,97,54,235,159,188,64,0,96,188,130,8,122,242,96,34,20,160,181,8,54,228,149,2,228,68,64,219,25,134,154,31,134,45,49,102,163,220,20,51,96,77,26,191,14,107,219,25,191,122,242,64,201,248,12,214,72,
133,167,48,213,70,216,244,133,218,97,9,53,155,228,51,18,32,96,138,1,57,63,61,107,91,226,224,144,57,193,15,159,200,140,37,133,83,166,95,214,100,240,10,200,18,255,119,47,183,20,54,254,105,98,197,150,26,124,31,197,143,147,70,105,228,23,131,151,136,160,245,111,68,59,77,43,37,33,245,75,179,95,228,142,75,134,59,254,34,52,235,48,168,164,168,227,234,217,46,218,187,71,110,175,255,162,180,120,176,74,36,75,237,188,232,146,209,153,127,86,36,97,56,62,32,27,215,242,240,141,239,117,181,61,7,9,198,54,16,0,105,99,17,112,15,179,169,237,239,177,254,196,185,221,180,191,144,60,16,1,71,183,174,64,87,160,43,208,21,232,10,116,5,186,2,231,43,240,11,0,0,255,255,3,0,132,152,37,138,121,13,84,65,0,0,0,0,73,69,78,68,174,66,96,130);

default_ns64H
:array[0..536] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,224,73,68,65,84,120,1,236,154,1,118,194,32,12,134,211,110,7,241,38,99,55,241,38,235,110,178,157,68,118,147,157,196,46,161,130,56,233,172,125,13,76,248,243,30,66,3,22,254,207,68,124,84,34,24,8,128,0,8,128,0,8,128,0,8,128,64,9,2,221,129,72,74,57,235,203,77,237,132,27,158,159,75,57,8,133,0,4,241,158,127,49,8,79,126,5,249,234,88,252,248,202,243,126,114,4,236,185,222,113,109,184,230,235,106,77,196,119,227,84,36,244,131,113,219,251,203,165,67,88,141,78,99,86,188,159,174,102,8,55,197,215,12,97,177,248,26,33,220,45,190,38,8,171,197,103,133,160,184,13,118,31,39,37,150,168,239,166,45,78,182,57,95,120,51,32,250,150,23,54,195,99,246,231,62,55,102,199,126,177,221,169,188,203,197,214,246,188,245,13,19,247,51,68,35,151,223,38,191,193,142,118,242,246,134,199,188,77,237,188,175,138,0,186,153,79,108,124,97,137,44,56,105,150,163,224,43,217,67,46,98,210,93,143,229,237,7,22,201,106,164,246,150,242,249,
62,221,90,226,176,105,3,128,166,63,126,22,143,8,64,4,52,78,0,41,208,120,0,224,75,16,41,128,20,104,156,0,82,160,241,0,192,46,128,20,64,10,52,78,160,249,20,80,60,20,141,207,252,226,48,115,135,162,177,35,106,75,223,220,251,142,67,52,112,179,166,34,128,85,199,220,38,125,132,238,244,14,155,169,142,110,164,8,32,204,98,211,71,221,254,153,128,140,147,118,42,27,255,60,66,151,55,254,103,123,140,71,99,202,4,87,67,48,211,179,3,247,167,137,131,242,34,181,111,127,55,132,154,196,123,184,139,33,212,40,126,49,132,154,197,223,132,80,76,124,231,151,150,175,150,116,32,22,44,230,254,38,199,181,243,137,195,158,125,114,169,111,5,0,136,168,24,66,16,105,115,139,119,43,9,211,103,111,92,64,40,34,62,187,228,235,9,5,66,8,255,235,110,120,64,0,4,64,0,4,64,0,4,64,0,4,244,8,252,0,0,0,255,255,3,0,239,25,129,155,3,98,187,65,0,0,0,0,73,69,78,68,174,66,96,130);

default_pen64H
:array[0..696] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,2,128,73,68,65,84,120,1,236,89,209,113,131,48,12,53,116,145,116,19,119,147,76,208,14,208,143,166,119,157,160,27,116,139,254,133,108,66,23,41,125,50,182,227,80,12,24,218,196,112,79,119,194,198,150,136,222,139,100,7,71,41,10,25,32,3,100,128,12,144,1,50,64,6,200,0,25,32,3,227,12,20,141,82,70,143,74,149,7,216,235,113,159,188,45,238,210,194,43,14,214,126,135,86,131,140,61,244,0,69,95,125,65,107,232,170,164,76,139,182,120,181,246,21,90,167,50,164,65,2,178,66,84,250,155,21,73,123,41,1,147,254,33,74,109,9,192,156,43,145,117,16,145,88,2,192,103,210,222,96,255,8,24,168,209,199,125,89,160,213,208,93,107,103,74,35,180,195,84,94,82,38,134,83,89,123,221,239,247,125,80,170,1,9,190,84,96,183,185,178,48,181,222,87,6,93,78,44,120,183,115,228,89,18,137,37,32,24,203,123,92,0,206,232,43,218,152,212,152,64,250,187,178,40,246,184,63,65,107,104,54,82,166,71,34,105,238,228,215,98,232,38,130,86,236,93,73,228,
87,14,51,8,16,108,14,80,243,18,32,29,232,230,77,194,64,224,67,83,209,45,113,192,201,249,200,186,96,74,104,192,246,58,83,51,51,32,12,206,100,129,14,71,226,253,205,101,130,255,70,143,113,208,125,51,222,239,230,153,176,48,3,252,130,168,123,126,29,246,33,183,99,219,202,4,128,119,123,189,124,179,41,146,79,38,164,68,221,103,171,73,130,89,213,153,9,204,4,212,7,73,32,9,96,128,36,144,132,150,1,102,2,51,129,153,224,25,96,57,176,28,124,50,232,92,222,29,10,31,210,245,59,66,130,61,71,144,35,54,255,106,61,22,201,51,12,222,90,35,9,191,121,192,165,106,239,211,175,11,207,3,210,63,48,240,168,108,240,24,146,83,165,73,175,210,33,248,207,246,89,203,14,90,103,28,139,7,16,150,119,107,60,226,132,76,216,163,213,237,17,122,83,161,223,39,1,120,245,4,131,199,220,143,220,251,64,196,198,244,200,154,32,224,229,248,76,20,192,67,217,254,161,202,0,120,71,196,118,73,152,0,190,75,194,164,181,196,57,41,89,70,115,19,125,222,29,36,227,141,72,205,191,219,126,172,209,129,223,100,92,183,220,5,98,64,170,243,238,32,38,
133,172,246,9,224,221,191,86,226,187,110,209,35,11,163,67,55,213,206,217,175,170,29,3,55,54,191,42,176,177,96,99,32,99,227,177,231,172,122,188,11,182,123,63,27,220,228,213,114,246,39,252,157,163,128,62,94,62,46,233,29,226,210,117,165,119,150,4,249,3,38,109,191,95,41,94,134,77,6,200,0,25,32,3,100,128,12,144,1,50,64,6,254,139,129,31,0,0,0,255,255,3,0,125,214,228,192,102,112,65,53,0,0,0,0,73,69,78,68,174,66,96,130);

default_person64H//part image
:array[0..631] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,19,0,0,0,20,8,6,0,0,0,111,85,6,116,0,0,2,63,73,68,65,84,120,1,148,148,207,75,20,97,24,199,223,25,53,242,7,232,18,72,102,164,172,4,133,43,137,221,60,120,233,214,178,7,87,9,188,148,155,130,148,65,16,158,35,42,186,73,94,162,232,226,255,32,210,65,132,232,80,151,14,29,108,65,143,30,34,58,100,135,37,112,113,157,237,243,157,217,121,247,157,221,38,232,129,207,204,51,207,243,204,247,125,222,121,223,119,188,122,189,110,154,22,251,94,51,244,31,158,255,175,90,223,247,123,161,8,207,225,25,20,160,59,237,157,191,136,169,171,192,240,210,52,206,23,120,13,215,96,10,54,225,51,185,73,238,109,230,136,197,83,52,8,117,78,80,185,5,239,224,114,16,4,5,200,203,135,79,138,35,152,229,158,176,206,196,147,81,87,167,10,189,128,247,240,8,145,64,1,25,238,47,68,238,227,94,130,39,112,27,172,209,153,58,114,187,234,26,36,48,3,235,174,80,252,6,177,26,254,75,184,137,112,95,28,215,221,153,166,93,193,12,241,94,56,80,65,138,237,19,63,7,61,110,30,49,137,88,33,229,126,
67,21,134,244,144,98,23,136,171,238,216,205,59,157,217,240,55,188,175,80,178,17,199,97,106,26,249,46,124,132,138,147,114,167,25,133,249,38,250,128,143,225,30,47,222,1,59,96,195,127,64,110,1,158,54,106,113,35,107,89,205,56,108,118,240,214,224,21,148,16,249,192,93,162,55,32,7,43,8,169,179,132,217,81,19,81,99,180,74,23,65,251,100,28,230,96,22,174,192,9,140,48,128,22,41,97,109,98,20,13,83,161,61,38,129,37,208,166,205,9,252,49,120,8,203,160,141,171,21,181,230,185,7,157,228,89,50,187,160,142,138,8,252,180,149,142,67,157,86,90,39,68,249,60,117,225,78,111,237,108,145,228,40,220,74,19,34,167,147,240,157,219,60,92,7,45,70,104,86,140,209,228,175,194,6,3,253,136,210,233,87,4,15,201,190,1,142,87,16,22,90,49,158,244,193,179,176,221,178,137,195,194,148,139,166,58,206,143,65,71,48,177,207,206,243,172,13,57,65,147,25,192,111,158,89,21,71,22,254,158,60,242,250,248,87,65,255,55,29,65,227,238,179,50,207,111,65,173,171,227,67,223,239,208,105,56,130,42,200,180,64,18,209,138,143,128,142,211,58,104,
202,38,177,154,198,212,248,151,157,233,39,174,255,153,246,151,94,26,0,137,168,77,137,74,92,131,236,65,153,239,91,137,63,203,31,0,0,0,255,255,3,0,55,188,149,72,85,132,72,101,0,0,0,0,73,69,78,68,174,66,96,130);

default_pin64H
:array[0..616] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,16,0,0,0,20,8,6,0,0,0,132,98,189,119,0,0,2,48,73,68,65,84,120,1,140,147,77,72,21,81,20,199,239,140,74,248,129,20,6,174,204,194,164,165,20,111,161,41,33,68,139,62,160,64,171,77,181,72,131,160,4,67,16,63,160,164,149,32,182,42,20,130,86,146,160,155,54,173,82,16,196,22,165,148,59,75,74,104,145,45,10,133,138,202,222,155,233,247,191,111,238,204,27,158,139,14,252,222,249,184,247,156,123,238,153,251,188,48,12,76,34,94,98,254,167,229,27,227,146,156,54,198,247,253,61,80,13,141,176,23,42,128,189,197,82,154,14,133,36,151,156,33,54,2,135,161,2,180,231,35,60,163,198,112,16,4,127,177,99,161,106,136,227,233,84,143,228,7,56,83,176,12,167,160,10,234,225,30,116,194,42,251,14,161,99,41,108,235,50,209,107,112,26,122,56,105,5,173,1,125,198,158,70,55,193,39,120,100,204,6,42,47,20,176,167,151,227,222,135,9,120,69,66,142,147,174,98,63,133,49,236,90,98,223,177,111,65,198,247,27,180,102,197,117,80,141,215,8,99,108,12,73,184,130,253,4,212,85,31,188,32,
86,22,4,217,15,216,107,208,134,111,167,238,10,156,36,248,14,126,68,11,23,176,53,60,39,71,48,50,145,179,128,150,95,38,223,21,216,196,222,167,64,36,95,156,17,105,77,250,107,244,201,247,99,235,58,154,79,124,202,107,108,77,188,153,235,191,228,107,60,196,86,87,7,224,23,140,115,181,117,186,171,196,110,135,89,252,44,58,238,224,55,246,28,244,234,179,178,168,123,54,195,49,56,10,163,32,57,8,117,48,3,86,188,48,84,119,246,245,157,69,233,13,100,40,160,97,21,9,29,60,39,248,147,46,47,185,23,236,102,192,169,89,45,190,129,161,162,76,2,36,235,74,199,225,174,75,214,190,184,64,100,14,18,235,96,179,90,143,5,95,19,191,3,243,176,30,47,96,20,20,176,225,183,252,234,25,15,145,84,98,35,246,169,155,86,236,19,160,255,66,46,31,207,255,166,10,176,248,135,240,109,56,15,231,180,133,58,53,40,205,102,18,222,67,74,226,33,38,209,45,146,106,6,240,111,64,11,220,132,46,104,226,128,109,116,74,10,95,91,180,96,223,211,99,156,235,208,3,186,251,197,221,146,137,23,205,64,49,190,72,238,27,74,29,244,195,34,104,120,187,74,106,
6,201,14,251,63,89,194,231,97,153,110,10,238,36,107,105,235,31,0,0,0,255,255,3,0,151,167,154,223,204,94,49,67,0,0,0,0,73,69,78,68,174,66,96,130);

default_no64H
:array[0..1014] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,3,190,73,68,65,84,120,1,236,88,139,113,219,48,12,149,220,69,220,73,138,110,146,77,146,142,146,73,202,110,210,46,18,247,129,228,147,32,70,178,68,83,82,114,23,224,142,2,1,130,248,60,194,250,184,235,156,28,1,71,192,17,112,4,28,1,71,192,17,112,4,28,1,71,192,17,112,4,28,129,47,135,64,127,110,197,151,151,20,239,246,35,199,149,204,67,230,96,183,95,184,24,121,92,57,98,118,2,0,67,209,207,149,5,0,132,227,193,56,24,0,45,254,102,10,239,245,116,65,111,33,178,241,164,37,203,96,189,218,27,89,187,225,120,32,16,115,79,210,194,251,219,56,216,5,53,49,74,31,19,80,106,28,157,109,107,19,159,43,92,117,209,230,247,8,80,175,115,140,104,47,211,140,227,90,6,115,206,223,212,186,86,250,86,187,225,190,189,38,200,150,215,118,127,131,76,138,201,163,200,120,146,2,126,197,32,93,49,209,33,0,226,9,3,188,251,135,241,23,227,21,192,244,224,146,134,206,111,1,243,79,71,50,158,168,61,41,157,151,63,135,184,14,251,129,48,143,118,
218,9,249,180,149,47,249,177,250,193,199,135,78,80,0,19,47,147,139,133,229,162,226,41,110,72,212,182,189,206,73,19,95,84,126,6,62,36,108,146,181,197,78,18,151,141,25,195,110,14,84,250,82,254,57,72,198,68,153,208,92,146,212,105,81,22,28,238,153,229,50,250,182,5,207,1,51,187,127,85,121,89,181,88,53,136,207,109,88,241,25,175,197,241,70,168,156,137,235,13,145,54,177,173,97,183,74,97,220,99,125,209,207,234,254,85,131,29,0,224,105,242,142,79,64,24,219,38,254,8,8,118,15,125,50,22,129,166,190,158,183,2,32,57,100,200,92,101,29,160,219,207,249,211,179,5,109,237,132,73,193,18,221,15,221,196,14,75,218,218,107,35,0,60,237,248,170,138,216,23,193,69,41,164,97,139,109,237,4,182,253,69,224,123,55,106,4,160,204,131,95,121,4,68,215,247,4,65,253,49,6,191,39,40,235,90,61,237,12,192,82,2,123,128,192,130,151,98,60,166,111,5,64,114,216,144,121,41,103,181,178,102,16,66,118,38,153,151,114,86,215,177,86,0,234,162,181,131,80,25,111,221,188,21,128,144,67,72,230,165,156,213,150,61,220,9,146,189,132,204,75,
57,171,235,88,43,0,11,209,46,178,176,144,213,15,131,112,223,237,3,171,141,0,244,127,82,204,139,36,78,57,73,247,175,181,32,240,145,91,19,227,126,6,186,218,8,64,25,128,119,234,173,111,104,91,65,136,47,59,146,162,49,6,1,177,143,220,50,159,83,100,126,152,48,152,38,171,186,154,55,52,238,41,247,89,125,140,99,190,54,203,184,140,95,199,119,232,128,225,13,13,133,91,178,111,126,86,63,55,223,210,9,186,143,167,61,128,27,230,188,157,172,179,167,196,208,19,157,80,187,206,237,190,161,72,108,211,185,149,135,211,151,117,159,167,88,48,113,155,36,117,154,108,87,145,168,221,103,253,177,144,217,63,95,184,248,145,156,167,98,147,30,146,5,8,241,203,111,99,130,118,159,245,103,193,169,1,117,57,236,142,255,10,207,254,115,251,138,214,197,191,184,49,217,43,64,120,193,16,232,190,227,247,12,117,252,215,87,185,64,247,148,214,58,189,209,93,49,64,122,127,209,251,131,146,22,207,167,139,126,106,119,1,163,153,250,102,15,19,7,54,73,155,188,22,24,31,91,224,91,104,178,23,27,22,253,110,113,118,182,141,38,203,159,195,
187,182,151,84,76,108,113,156,180,181,211,125,58,74,178,254,230,214,75,251,58,121,231,14,24,130,11,138,211,86,206,84,158,40,245,247,184,22,203,150,87,187,71,124,220,243,159,214,142,2,64,189,11,146,126,78,92,197,72,97,124,150,83,142,92,226,181,187,100,126,124,225,41,30,50,228,228,64,142,162,222,1,177,33,156,158,184,18,111,130,73,218,251,122,6,0,54,103,201,96,80,7,57,82,72,140,31,58,199,22,157,98,249,213,17,112,4,28,1,71,192,17,112,4,28,1,71,192,17,112,4,28,1,71,192,17,248,178,8,252,7,0,0,255,255,3,0,241,104,93,229,91,111,65,84,0,0,0,0,73,69,78,68,174,66,96,130);

default_alt64H
:array[0..415] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,1,103,73,68,65,84,120,1,236,153,13,14,130,48,12,133,7,241,94,246,102,234,201,224,100,98,203,79,152,68,2,42,219,107,198,107,82,221,24,89,251,190,86,157,33,4,26,9,144,0,9,144,0,9,144,0,9,144,0,9,144,0,9,228,39,32,26,210,28,102,53,44,114,47,188,106,66,48,199,65,64,1,144,81,248,200,31,7,1,1,32,18,95,61,20,132,186,25,14,194,16,63,207,171,168,208,110,240,250,62,135,180,241,116,29,247,113,152,243,73,51,146,89,100,44,126,10,86,54,132,13,241,101,67,216,41,190,76,8,95,138,47,11,194,143,226,203,128,240,167,248,124,16,18,157,3,106,5,208,91,59,188,217,55,252,210,151,63,119,203,117,155,199,86,75,60,59,106,124,57,106,163,149,125,36,132,78,253,163,181,209,85,209,251,110,209,60,219,48,17,128,103,171,21,95,17,209,93,117,65,86,22,245,242,116,50,92,222,97,123,22,97,253,31,32,61,13,190,65,144,241,144,212,228,150,184,86,166,220,121,192,226,17,0,12,189,147,192,236,0,39,133,128,165,193,14,128,161,119,18,152,
29,224,164,16,176,52,216,1,48,244,78,2,179,3,156,20,2,150,6,59,0,134,222,73,96,118,128,147,66,192,210,96,7,192,208,59,9,204,14,112,82,8,88,26,167,239,128,68,207,5,246,20,180,178,7,33,230,80,3,2,8,2,85,62,6,175,0,73,108,9,111,1,57,49,36,9,144,0,9,144,0,9,144,0,9,144,0,9,144,192,201,8,188,0,0,0,255,255,3,0,115,35,68,184,241,183,219,11,0,0,0,0,73,69,78,68,174,66,96,130);

default_wait64H
:array[0..606] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,64,0,0,0,64,8,6,0,0,0,170,105,113,222,0,0,2,38,73,68,65,84,120,1,236,90,139,110,195,32,12,108,167,126,88,246,229,203,159,101,64,112,84,89,60,12,156,211,164,56,82,75,1,115,216,119,55,74,165,61,30,246,24,3,198,128,49,96,12,24,3,198,192,172,12,60,49,133,63,55,12,78,43,202,54,156,255,79,235,150,223,22,255,194,22,52,174,136,44,31,156,227,204,1,50,198,165,81,56,101,164,59,142,198,77,239,128,81,2,217,122,239,0,77,23,224,241,167,119,128,50,1,92,177,209,62,51,28,160,171,76,0,32,67,101,8,240,61,128,103,75,247,2,58,23,122,251,28,23,215,55,7,224,184,44,33,93,79,121,202,22,237,128,117,7,126,254,209,6,184,246,192,140,123,224,144,193,72,62,209,112,218,23,72,168,125,27,240,148,36,152,124,141,172,143,118,128,219,117,251,117,111,171,123,45,142,136,2,9,46,66,244,4,140,197,133,174,17,91,180,234,2,65,18,213,184,19,120,218,18,12,190,166,173,175,224,0,74,96,212,9,183,85,158,8,160,182,71,197,158,53,180,223,37,219,150,130,90,98,47,89,108,46,41,73,97,
146,152,28,126,223,184,226,25,192,19,10,103,130,31,92,248,204,91,63,206,29,177,111,83,58,31,79,36,32,85,64,237,91,32,181,6,59,246,97,2,176,197,244,160,41,255,26,172,165,68,191,17,106,113,122,243,39,58,192,31,112,225,89,99,155,106,226,220,17,155,138,185,227,88,238,116,79,157,1,185,88,157,186,79,112,64,80,115,113,233,175,178,187,252,232,13,82,135,168,78,84,169,154,159,115,130,162,3,90,149,231,28,223,218,9,82,229,121,209,169,62,18,43,133,15,31,211,72,88,3,19,94,184,7,148,38,202,255,230,121,63,149,156,20,59,181,54,63,134,62,3,150,125,43,141,187,252,129,25,247,200,23,213,50,115,242,77,208,43,237,31,186,1,214,250,123,180,230,59,218,1,154,185,170,96,159,228,128,154,210,181,121,149,218,3,168,57,64,143,91,143,92,83,182,117,30,159,237,244,14,0,83,234,21,37,85,193,208,1,14,143,63,189,3,134,255,211,114,215,89,83,245,146,147,232,62,81,138,41,207,77,239,0,240,61,96,92,145,178,94,52,139,115,156,57,128,56,197,180,56,101,48,249,212,81,166,119,64,157,34,139,48,6,140,1,99,192,24,48,6,140,129,111,
101,224,31,0,0,255,255,3,0,139,77,171,91,154,246,93,222,0,0,0,0,73,69,78,68,174,66,96,130);

default_nil
:array[0..0] of byte=(0);


procedure tcursordefault.on__filtersize(var x:longint32);
begin

//allow 128px and 64px cursor sizes
if (x<>128) and (x<>64) then
   begin

   x        :=128;

   end;

end;

procedure tcursordefault.on__load;

   procedure s(const n,h:array of byte);
   begin

   case ihollow of
   true:art.loadfrom( h );
   else art.loadfrom( n );
   end;//case

   end;

   procedure s2(const n,h:array of byte);
   begin

   case ihollow of
   true:art2.loadfrom( h );
   else art2.loadfrom( n );
   end;//case

   end;

   procedure s3(const n,h:array of byte);
   begin

   case ihollow of
   true:art3.loadfrom( h );
   else art3.loadfrom( n );
   end;//case

   end;

begin


//load main cursor shape/template

//.128px
if (isize=128) then
   begin

   case cfindex of

   cf_alt                :s( default_alt128    ,default_alt128H    );

   cf_arrow              :s( default_arrow128  ,default_arrow128H  );

   cf_work               :begin
                          s ( default_arrow128 ,default_arrow128H  );
                          s2( default_work128  ,default_work128H   );
                          end;

   cf_cross              :s( default_cross128  ,default_cross128H  );

   cf_ns                 :s( default_ns128     ,default_ns128H     );
   cf_ew                 :s( default_ns128     ,default_ns128H     );
   cf_nesw               :s( default_ns128     ,default_ns128H     );
   cf_nwse               :s( default_ns128     ,default_ns128H     );

   cf_hand               :s( default_hand128   ,default_hand128H   );

   cf_help               :begin
                          s ( default_arrow128 ,default_arrow128H  );
                          s2( default_help128  ,default_help128H   );
                          end;

   cf_txt                :s( default_text128   ,default_text128H   );
   cf_move               :s( default_move128   ,default_move128H   );
   cf_no                 :s( default_no128     ,default_no128H     );
   cf_pen                :s( default_pen128    ,default_pen128H    );

   cf_person             :begin
                          s ( default_hand128   ,default_hand128H   );
                          s2( default_person128 ,default_person128H );
                          end;

   cf_pin                 :begin
                          s ( default_hand128   ,default_hand128H   );
                          s2( default_pin128    ,default_pin128H    );
                          end;

   cf_wait               :s ( default_wait128   ,default_wait128H   );
   else                   s( default_arrow128  ,default_arrow128H  );
   end;//case

   end

//.64px
else begin

   case cfindex of
   cf_alt                :s( default_alt64    ,default_alt64H    );
   cf_arrow              :s( default_arrow64  ,default_arrow64H  );

   cf_work               :begin
                          s ( default_arrow64  ,default_arrow64H  );
                          s2( default_work64   ,default_work64H   );
                          end;

   cf_cross              :s( default_cross64  ,default_cross64H  );

   cf_ns                 :s( default_ns64     ,default_ns64H     );
   cf_ew                 :s( default_ns64     ,default_ns64H     );
   cf_nesw               :s( default_ns64     ,default_ns64H     );
   cf_nwse               :s( default_ns64     ,default_ns64H     );

   cf_hand               :s( default_hand64   ,default_hand64H   );

   cf_help               :begin
                          s ( default_arrow64  ,default_arrow64H );
                          s2( default_help64   ,default_help64H  );
                          end;

   cf_txt                :s( default_text64   ,default_text64H   );
   cf_move               :s( default_move64   ,default_move64H   );
   cf_no                 :s( default_no64     ,default_no64H     );
   cf_pen                :s( default_pen64    ,default_pen64H    );

   cf_person             :begin
                          s ( default_hand64   ,default_hand64H   );
                          s2( default_person64 ,default_person64H );
                          end;

   cf_pin                 :begin
                          s ( default_hand64   ,default_hand64H   );
                          s2( default_pin64    ,default_pin64H    );
                          end;

   cf_wait               :s( default_wait64   ,default_wait64H   );
   else                   s( default_arrow64  ,default_arrow64H  );
   end;//case

   end;

end;

procedure tcursordefault.xdrawbase(const dcell32:tcommonimage;const xart:tartbase;const dx,dy:longint32;const xedgeColor1,xedgeColor2,xbaseColor:tcolor24;const xrotate:extended;const xmirror,xhotspot:boolean);
label
   skipend;

begin


//check
if (dcell32=nil) then exit;


//edge
if not isolid then
   begin

   //.animate the gold edge
   if (info.cv=cv_goldedge) then

      begin

      xart.filter.defaults;
      xart.filter.drawmode         :=dm_alpha;

      xart.filter.hmode            :=bm_hill;
      xart.filter.hpower           :=1.0;
      xart.filter.hbend            :=1.0 - (pert2*0.8);
      xart.filter.hcolor1          :=xedgeColor1;
      xart.filter.hcolor2          :=xedgeColor2;

      xart.filter.vmode            :=bm_hill;
      xart.filter.vpower           :=0.9*pert4;
      xart.filter.vbend            :=1.0 - ((1.0-pert2)*0.1);
      xart.filter.vcolor1          :=xedgeColor1;
      xart.filter.vcolor2          :=xedgeColor2;

      end

   else begin

      xart.filter.defaults;
      xart.filter.drawmode         :=dm_alpha;

      xart.filter.hmode            :=bm_hill;
      xart.filter.hpower           :=1.0;
      xart.filter.hbend            :=1.0;
      xart.filter.hcolor1          :=xedgeColor1;
      xart.filter.hcolor2          :=xedgeColor2;

      xart.filter.vmode            :=bm_hill;
      xart.filter.vpower           :=1.0;
      xart.filter.vbend            :=1.0;
      xart.filter.vcolor1          :=xedgeColor1;
      xart.filter.vcolor2          :=xedgeColor2;

      end;

   //draw
   xart.draw5( dcell32 ,0 ,dx ,dy ,255 ,xrotate ,xmirror );

   end;


//base
xart.filter.defaults;
xart.filter.vcolor1             :=xbaseColor;
xart.filter.vcolor2             :=xbaseColor;
xart.filter.vmode               :=bm_flat;
xart.filter.vbend               :=1.0;
xart.filter.vpower              :=1.0;

case isolid of
true:xart.filter.drawmode       :=dm_alpha;
else xart.filter.drawmode       :=dm_whites;
end;

xart.draw5( dcell32 ,0 ,dx ,dy ,255 ,xrotate ,xmirror );


//hotspot -> based on first cell of animation
if xhotspot then
   begin

   ihotX    :=dx + art.hotX;
   ihotY    :=dy + art.hotY;

   //force center hotspot for these cursor types
   case cfindex of
   cf_cross,cf_ew,cf_txt,cf_move,cf_nesw,cf_nwse,cf_ns,cf_no,cf_wait:begin

      ihotX :=dx + art.workarea[0].left + ((art.workarea[0].right-art.workarea[0].left+1) div 2);
      ihotY :=dy + art.workarea[0].top  + ((art.workarea[0].bottom-art.workarea[0].top+1) div 2);

      end;

   end;//case

   end;


end;

procedure tcursordefault.on__celldraw(const dcell32:tcommonimage;const cindex,ccount:longint32;var xmirror:boolean);//30aug2026
var
   dart                         :tartbase;
   c1                           :tcolor24;
   c2                           :tcolor24;
   c3                           :tcolor24;
   dedge1                       :tcolor24;
   dedge2                       :tcolor24;
   dbody1                       :tcolor24;
   dbody2                       :tcolor24;
   dbody3                       :tcolor24;
   dsparkle1                    :tcolor24;
   dsparkle2                    :tcolor24;
   dsolid                       :boolean;
   v1                           :extended;
   vlist                        :tcursorpositionlist;

   function ddrawmode:tartdrawmode;
   begin

   if      ihollow             then result:=dm_blacks
   else if isolid              then result:=dm_alpha
   else if (info.cv=cv_tone)   then result:=dm_blacks
   else                             result:=dm_whites;

   end;

   function dpulse:extended;
   begin

   case ipulse of
   true:result        :=0.8;
   else result        :=0.2;
   end;

   end;

begin


//check
if (dcell32=nil) then exit;


//defaults
dart                  :=art;

low__cls( @vlist ,sizeof(vlist) );

vlist[0].w            :=dart.workarea[0].right  - dart.workarea[0].left + 1;
vlist[0].h            :=dart.workarea[0].bottom - dart.workarea[0].top  + 1;

if canart2 then
   begin

   vlist[1].w         :=art2.workarea[0].right  - art2.workarea[0].left + 1;
   vlist[1].h         :=art2.workarea[0].bottom - art2.workarea[0].top  + 1;

   //part image -> bottom-right align
   vlist[1].x         :=vlist[0].x + dart.workarea[0].right  + 1;
   vlist[1].y         :=vlist[0].y + dart.workarea[0].bottom - ( (art2.workarea[0].bottom-art.workarea[0].top) div 2 );

   end;


//realtime colors -> generate on-the-fly
if (info.cc>=cc_rainbow) and (info.cc<=cc_rainbowMAX) then
   begin

   case info.cc of
   cc_rainbow         :ibodycolor2        :=c32__int( c32__splice( 0.50 ,rainbow32( pert1 ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );
   cc_rainbow2        :ibodycolor2        :=c32__int( c32__splice( 0.75 ,rainbow32( pert1 ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );
   cc_rainbow3        :ibodycolor2        :=c32__int( c32__splice( 0.20 ,rainbow32( pert1 ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );

   cc_rainbow4        :begin

                       //slide color from left-to-right -> only suitable for ct_plain - 18jun2026
                       v1                 :=pert1 + 0.17;
                       if (v1>1) then
                          begin

                          v1              :=v1-1;

                          end;

                       ibodycolor1        :=c32__int( c32__splice( 0.00 ,rainbow32( v1    ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );
                       ibodycolor2        :=c32__int( c32__splice( 0.20 ,rainbow32( pert1 ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );

                      end;

   cc_rainbow5        :begin

                       //slide color from right-to-left -> only suitable for ct_plain - 18jun2026
                       v1                 :=pert1 - 0.17;
                       if (v1<0) then
                          begin

                          v1              :=v1+1;

                          end;

                       ibodycolor1        :=c32__int( c32__splice( 0.00 ,rainbow32( v1    ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );
                       ibodycolor2        :=c32__int( c32__splice( 0.20 ,rainbow32( pert1 ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );

                      end;

   else                ibodycolor2        :=c32__int( c32__splice( 0.20 ,rainbow32( pert1 ,255 ) ,color32( 255 ,255 ,255 ,255 ) ) );
   end;//case

   isparklecolor      :=clnone;

   end;


//target colors
c1                    :=int__c24 ( ibodycolor1 );
c2                    :=int__c24 ( ibodycolor2 );
c3                    :=int__c24 ( ibodycolor3 );

case info.cv of
cv_standard           :dedge1   :=color24( 000,000,000 );//black edges
cv_whiteedge          :dedge1   :=color24( 190,190,190 );//white edges
cv_goldedge           :dedge1   :=color24( 035,035,000 );//gold edges
else                   dedge1   :=int__c24( low__aorb( ibodycolor1 ,iedgecolor    ,iedgecolor<>clnone ));
end;//case

case info.cv of
cv_whiteedge          :dedge2   :=color24( 255,255,255 );//white edges
cv_goldedge           :dedge2   :=color24( 170,170,000 );//gold edges
else                   dedge2   :=dedge1;
end;//case

dbody1                :=c24__splice( 0.2 + ( pert4 * dpulse ) ,c1 ,c2 );//high-contrast pulser required to off-set goldedge mode - 14jun2026
dbody2                :=c2;
dbody3                :=c3;

dsparkle2             :=int__c24( low__aorb( ibodycolor2 ,isparklecolor ,isparklecolor<>clnone ) );
dsparkle1             :=c24__splice( 0.2 + ( pert4 * 0.5 * dpulse ) ,dbody1 ,dsparkle2 );

if iflat then
   begin

   dbody1             :=dbody2;
   dsparkle1          :=dsparkle2;

   end;


//positon and rotation
on__position( vlist ,xmirror );


//generic body and edge --------------------------------------------------------

//draw
xdrawbase( dcell32 ,dart ,vlist[0].x ,vlist[0].y ,dedge1 ,dedge2 ,dbody2 ,vlist[0].r ,false ,(cindex=0) );

if canart2 then
   begin

   //Important: counter-act mirror for small art which must not be mirrored - 25jun2026
   xdrawbase( dcell32 ,art2 ,vlist[1].x ,vlist[1].y ,dedge1 ,dedge2 ,dbody2 ,vlist[1].r ,xmirror ,false );

   end;


//custom body ------------------------------------------------------------------

//init
with dart.filter do
begin

defaults;
hcolor1               :=dbody1;
hcolor2               :=dbody2;
hmode                 :=bm_hill;
hbend                 :=1.0;
hpower                :=1.0;
drawmode              :=ddrawmode;
linesize              :=isize div 32;

end;

//ct_colors -> static
if (info.ct=ct_colors) then
   begin

   with dart.filter do
   begin

   vcolor1               :=dbody2;
   vcolor2               :=dbody3;
   vmode                 :=bm_slope;
   vbend                 :=1.0;
   vpower                :=1.0;

   end;

   end

//ct_colors2 -> animated
else if (info.ct=ct_colors2) then
   begin

   with dart.filter do
   begin

   vcolor1               :=c24__splice( pert2 ,dbody2 ,dbody3 );
   vcolor2               :=c24__splice( pert2 ,dbody3 ,dbody2 );
   vmode                 :=bm_slope;
   vbend                 :=1.0;
   vpower                :=1.0;

   end;

   end

//ct_colors3 -> anmimated
else if (info.ct=ct_colors3) then
   begin

   with dart.filter do
   begin

   vcolor1               :=c24__splice( pert8 ,dbody2 ,dbody3 );
   vcolor2               :=c24__splice( pert8 ,dbody3 ,dbody2 );
   vmode                 :=bm_slope;
   vbend                 :=1.0;
   vpower                :=pert2;

   end;

   end;


//.horizontal or vertical stripes
if hstripe then
   begin

   case low__iseven(cindex) of
   true:dart.filter.linemode    :=lm_horz2;
   else dart.filter.linemode    :=lm_horz;
   end;//case

   end

else if vstripe then
   begin

   case low__iseven(cindex) of
   true:dart.filter.linemode    :=lm_vert2;
   else dart.filter.linemode    :=lm_vert;
   end;//case

   end;

dart.draw5( dcell32 ,0 ,vlist[0].x ,vlist[0].y ,255 ,vlist[0].r ,false );

if canart2 then
   begin

   art2.filter.copyfrom( dart.filter );
   art2.filter.linesize         :=frcmin32( art2.filter.linesize div 2 ,2 );

   //Important: counter-act mirror for small art which must not be mirrored - 25jun2026
   art2.draw5( dcell32 ,0 ,vlist[1].x ,vlist[1].y ,255 ,vlist[1].r ,xmirror );

   end;


//custom body -> sparkle layer -------------------------------------------------

if sparkle then
   begin

   with dart.filter do
   begin

   defaults;
   sparkle20          :=10;
//was:   hmode              :=bm_hill;
   hmode              :=bm_flat2;
   hbend              :=1.0;//full slope
   hpower             :=-1.0;//include slop based feathering
   hcolor1            :=dsparkle2;
   hcolor2            :=dsparkle1;
   drawmode           :=ddrawmode;

   end;

   dart.draw5( dcell32 ,0 ,vlist[0].x ,vlist[0].y ,255 ,vlist[0].r ,false );

   if canart2 then
      begin

      art2.filter.copyfrom( dart.filter );
      art2.draw5( dcell32 ,0 ,vlist[1].x ,vlist[1].y ,255 ,vlist[1].r ,xmirror );//fixed for mirror: 30aug2026

      end;

   end;

end;

procedure tcursordefault.on__position(var v:tcursorpositionlist;var xmirror:boolean);
begin//main image: v[0]
     //sub images: v[1]..v[n]

if animate then
   begin

   case icfindex of

   cf_wait                      :v[0].r   :=pert1R(xmirror) * 359.9;

   cf_work                      :begin//bounce the hourglass
                                 v[1].r   :=pert1 * 2 * 359.9;//part image
                                 v[1].x   :=v[1].x - round( pert2 * v[0].w * 0.35 );
                                 v[1].y   :=v[1].y - round( (1-pert4) * v[0].h * 0.65 );
                                 end;

   cf_hand                      :begin//bounce the hourglass
                                 v[1].r   :=pert1 * 1 * 359.9;//part image
                                 end;

   cf_ns                        :v[0].r   :=   0 + ( pert4 * 8 ) - 4;//slight wobble
   cf_ew                        :v[0].r   :=  90 + ( pert4 * 8 ) - 4;//slight wobble
   cf_nesw                      :v[0].r   :=  45 + ( pert4 * 8 ) - 4;//slight wobble
   cf_nwse                      :v[0].r   := -45 + ( pert4 * 8 ) - 4;//slight wobble

   cf_no                        :begin
                                 xmirror  :=false;//no mirror for this cursor
                                 v[0].x   :=round( pert8 * 10 ) - 5;
                                 v[0].r   :=( pert4 * 10 ) - 5;
                                 end;

   cf_person                    :begin
                                 v[1].x   :=v[1].x + round( pert4 * 5 * (isize/128) );
                                 v[1].y   :=v[1].y - round( pert4 * 5 * (isize/128) );
                                 end;

   cf_pin                       :v[1].y   :=v[1].y - round( pert4 * 10 * (isize/128) );

   cf_help                      :begin
                                 v[1].x   :=v[1].x - round( pert2 * 10 * (isize/128) );
                                 v[1].y   :=v[1].y + round( pert4 * 10 * (isize/128) );
                                 end;

   cf_move                      :if (pert4>=0.5) then v[0].r:=90;

   end;//case

   end

//static movement
else begin

   case icfindex of

   cf_ns                        :v[0].r   :=   0;
   cf_ew                        :v[0].r   :=  90;
   cf_nesw                      :v[0].r   :=  45;
   cf_nwse                      :v[0].r   := -45;

   end;//case

   end;


//mirror correction
if mirror then
   begin

   case icfindex of

   cf_nesw                      :v[0].r   := v[0].r + 90;
   cf_nwse                      :v[0].r   := v[0].r + 90;

   end;//case

   end;


end;


//## tcursormodern #############################################################

procedure tcursormodern.on__load;

   procedure s(const n,h:array of byte);
   begin

   case ihollow of
   true:art.loadfrom( h );
   else art.loadfrom( n );
   end;//case

   end;

   procedure s2(const n,h:array of byte);
   begin

   case ihollow of
   true:art2.loadfrom( h );
   else art2.loadfrom( n );
   end;//case

   end;

   procedure s3(const n,h:array of byte);
   begin

   case ihollow of
   true:art3.loadfrom( h );
   else art3.loadfrom( n );
   end;//case

   end;

begin


//load main cursor shape/template

//.128px
if (isize=128) then
   begin

   case cfindex of
   cf_alt                :s( modern_alt128           ,default_alt128H    );
   cf_arrow              :s( modern_arrow128         ,default_arrow128H  );



   cf_work               :begin
                          s ( modern_arrow128 ,default_arrow128H  );
                          s2( default_work128  ,default_work128H   );
                          end;

   cf_cross              :s( default_cross128  ,default_cross128H  );

   cf_ns                 :s( default_ns128     ,default_ns128H     );
   cf_ew                 :s( default_ns128     ,default_ns128H     );
   cf_nesw               :s( default_ns128     ,default_ns128H     );
   cf_nwse               :s( default_ns128     ,default_ns128H     );

   cf_hand               :begin
                          s ( modern_arrow128  ,modern_arrow128  );
                          s2( modern_link128   ,modern_link128   );
                          end;


   cf_help               :begin
                          s ( modern_arrow128 ,default_arrow128H  );
                          s2( default_help128  ,default_help128H   );
                          end;

   cf_txt                :s( default_text128   ,default_text128H   );
   cf_move               :s( default_move128   ,default_move128H   );
   cf_no                 :s( default_no128     ,default_no128H     );
   cf_pen                :s( default_pen128    ,default_pen128H    );

   cf_person             :begin
                          s ( modern_arrow128 ,default_arrow128H  );//29jul2026
                          s2( default_person128 ,default_person128H );
                          end;

   cf_pin                 :begin
                          s ( modern_arrow128 ,default_arrow128H  );//29jul2026
                          s2( default_pin128    ,default_pin128H    );
                          end;

   cf_wait               :s ( default_wait128   ,default_wait128H   );
   else                   s( modern_arrow128  ,default_arrow128H  );
   end;//case

   end

//.64px
else begin

   case cfindex of
   cf_alt                :s( modern_alt64           ,default_alt64H    );
   cf_arrow              :s( modern_arrow64         ,default_arrow64H  );



   cf_work               :begin
                          s ( modern_arrow64 ,default_arrow64H  );
                          s2( default_work64  ,default_work64H   );
                          end;

   cf_cross              :s( default_cross64  ,default_cross64H  );

   cf_ns                 :s( default_ns64     ,default_ns64H     );
   cf_ew                 :s( default_ns64     ,default_ns64H     );
   cf_nesw               :s( default_ns64     ,default_ns64H     );
   cf_nwse               :s( default_ns64     ,default_ns64H     );

   cf_hand               :begin
                          s ( modern_arrow64 ,default_arrow64H  );//29jul2026
                          s2( modern_link64  ,modern_link64 );
                          end;

   cf_help               :begin
                          s ( modern_arrow64 ,default_arrow64H  );
                          s2( default_help64  ,default_help64H   );
                          end;

   cf_txt                :s( default_text64   ,default_text64H   );
   cf_move               :s( default_move64   ,default_move64H   );
   cf_no                 :s( default_no64     ,default_no64H     );
   cf_pen                :s( default_pen64    ,default_pen64H    );

   cf_person             :begin
                          s ( modern_arrow64 ,default_arrow64H  );//29jul2026
                          s2( default_person64 ,default_person64H );
                          end;

   cf_pin                 :begin
                          s ( modern_arrow64 ,default_arrow64H  );//29jul2026
                          s2( default_pin64    ,default_pin64H    );
                          end;

   cf_wait               :s ( default_wait64   ,default_wait64H   );
   else                   s( modern_arrow64  ,default_arrow64H  );
   end;//case

   end;

end;

procedure tcursormodern.on__position(var v:tcursorpositionlist;var xmirror:boolean);
begin

//animated
if animate then
   begin

   case icfindex of

   cf_alt   :v[0].r   :=(pert4 - 0.5) * 10;

   else      inherited on__position( v ,xmirror );

   end;//case

   end

//static
else begin

   inherited on__position( v ,xmirror );

   end


end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//2222222222222222222222222222222222222
//## tmakebase #################################################################

constructor tmakebase.create;
begin

//self
inherited create;

//vars
imade                 :=false;
ipnamelist            :=@inamelist;
iuserfilename         :='';//use with care

//clear
clear;

//proc
on__create;

end;

destructor tmakebase.destroy;
begin
try

//proc
on__destroy;

//clear
clear;

//self
inherited destroy;

except;end;
end;

procedure tmakebase.setuserfilename(x:string);//25jun2026
begin

//filter's out bad chars AND "..." (3 dots) which cause the Windows Cursor Scheme installer to fail, unable to locate
//sub-files for each cursor, even though the cursor files are present and accessible via the standard Windows open dialog - 25jun2026

iuserfilename         :=cursor__safename( x );

end;

procedure tmakebase.on__create;
begin

//nil

end;

procedure tmakebase.on__make(const xmakecode:string);
begin

//nil

end;

procedure tmakebase.on__name(const x:tmakenameitem;const nameIndex:longint32);
begin

//nil

end;

procedure tmakebase.on__type(const x:tmakenameitem;const nameIndex,typeIndex:longint32);
begin

//nil

end;

procedure tmakebase.on__val(const x:tmakenameitem;const nameIndex,typeIndex,valIndex:longint32);
begin

//nil

end;

procedure tmakebase.on__destroy;
begin

//nil

end;

procedure tmakebase.clear;
begin

//disable control
imade       :=false;

//clear vars
low__cls(@inamemultiplier,sizeof(inamemultiplier));
low__cls(@inameList,sizeof(inameList));

inamecount  :=0;
ifilecount  :=0;

end;

function tmakebase.finish:boolean;
var
   nindex   :longint32;
   tindex   :longint32;
   sindex   :longint32;
   v        :longint32;
   fcount64 :longint64;

begin

//fast check -------------------------------------------------------------------

result      :=false;

if imade            then exit;
if (inamecount<=0)  then exit;


//check all used slots have non-zero counts ------------------------------------

for nindex:=0 to pred(inamecount) do
begin

//.name as no type slots used -> math error
if (inamelist[nindex].typecount<=0) then
   begin

   exit;

   end;

for tindex:=0 to pred(inamelist[nindex].typecount) do
begin

//.type has no value slots used -> math error
if (inamelist[nindex].typelist[tindex].valcount<=0) then
   begin

   exit;

   end;

end;//tindex

end;//nindex


//pre-calculate computational values -------------------------------------------


sindex                                      :=0;
ifilecount                                  :=0;
fcount64                                    :=0;

for nindex:=0 to pred(inamecount) do
begin


v                                           :=1;

for tindex:=0 to pred(inamelist[nindex].typecount) do
begin

inamelist[ nindex ].typemultiplier[ tindex ]:=v;
v                                           :=v * inamelist[ nindex ].typelist[ tindex ].valcount;

end;//tindex

inc( sindex ,inamelist[ nindex ].typemultiplier[ pred(inamelist[nindex].typecount) ] );


inamemultiplier[ nindex ]                   :=ifilecount + 1;
ifilecount                                  :=ifilecount + v;
fcount64                                    :=fcount64  + v;

end;//nindex


//finalise ---------------------------------------------------------------------

imade                                       :=(fcount64<max32);
result                                      :=imade;

end;

procedure tmakebase.make(const xmakecode:string);
begin

on__make( xmakecode );

end;

function tmakebase.addName(const xname,xmakecode:string;const xcode,xtep,xcolor:longint32;var x:tmakenameitem):boolean;//layer 1
begin

//defaults
result      :=false;

//check
if imade or (inamecount>high(inamelist)) then
   begin

   exit;

   end;

//init
with inamelist[ inamecount ] do
begin

name        :=io__safename( strdefb( xname ,'' ) );//allow "nil" - 14jun2026
makecode    :=xmakecode;
code        :=xcode;
tep         :=xtep;
color       :=xcolor;
slot        :=inamecount;//slot points to this item within the nameList

end;

//inc
inc32( inamecount ,1 );

//proc
on__name( x, pred(inamecount) );

//successful
result      :=true;

end;

function tmakebase.addType:boolean;//layer 2

   function nindex:longint32;
   begin

   result   :=pred(inamecount);

   end;

   function tindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typecount );

   end;

begin

result      :=(not imade) and (nindex>=0) and (tindex>=-1) and ( tindex < high(inamelist[0].typelist ) );

if result then
   begin

   //inc
   inc32( inamelist[ nindex ].typecount ,1 );

   //proc
   on__type( inamelist[ nindex ] ,nindex ,tindex );

   end;

end;

function tmakebase.addVal(const xval:byte):boolean;//layer 3

   function nindex:longint32;
   begin

   result   :=pred(inamecount);

   end;

   function tindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typecount );

   end;

   function vindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typelist[ tindex ].valcount );

   end;

begin

result      :=(not imade) and (nindex>=0) and (tindex>=0) and (vindex>=-1) and ( vindex < high(inamelist[0].typelist[0].vallist ) );

if result then
   begin

   //get
   inamelist[ nindex ].typelist[ tindex ].vallist[ vindex + 1 ]:=xval;

   //inc
   inc32( inamelist[ nindex ].typelist[ tindex ].valcount ,1 );

   //proc
   on__val( inamelist[ nindex ] ,nindex ,tindex ,vindex );

   end;

end;

function tmakebase.addVal2(const dtypeindex:longint32;const xval:byte):boolean;//layer 3

   function nindex:longint32;
   begin

   result   :=pred(inamecount);

   end;

   function tindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typecount );

   end;

   function vindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typelist[ tindex ].valcount );

   end;

begin

//get
result      :=
 (not imade)     and
 (nindex>=0    ) and
 (dtypeindex>=0) and ( dtypeindex <= high(inamelist[0].typelist            ) ) and
 (vindex>=-1   ) and ( vindex     <  high(inamelist[0].typelist[0].vallist ) ) ;

//set
if result then
   begin

   //get
   inamelist[ nindex ].typelist[ dtypeindex ].vallist[ vindex + 1 ]      :=xval;

   //enlarge typeList if required
   if (dtypeindex>=inamelist[ nindex ].typecount) then
      begin

      inamelist[ nindex ].typecount       :=dtypeindex;

      end;

   //inc
   inc32( inamelist[ nindex ].typelist[ tindex ].valcount ,1 );

   //proc
   on__val( inamelist[ nindex ] ,nindex ,tindex ,vindex );

   end;

end;

function tmakebase.addonceVal(const xval:byte):boolean;//layer 3
var
   p        :longint32;
   t        :pmaketypeitem;

   function nindex:longint32;
   begin

   result   :=pred(inamecount);

   end;

   function tindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typecount );

   end;

   function vindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typelist[ tindex ].valcount );

   end;

begin

result      :=(not imade) and (nindex>=0) and (tindex>=0) and (vindex>=-1) and ( vindex < high(inamelist[0].typelist[0].vallist ) );

if result then
   begin

   //find -> ensure value does not already exist
   if (vindex>=0) then
      begin

      //init
      t     :=@inamelist[ nindex ].typelist[ tindex ];

      //find
      for p:=0 to pred(t.valcount) do
      begin

      if (xval=t.vallist[p]) then
         begin

         //value already exists -> exit
         exit;

         end;

      end;//p

      end;

   //get
   inamelist[ nindex ].typelist[ tindex ].vallist[ vindex + 1 ]:=xval;

   //inc
   inc32( inamelist[ nindex ].typelist[ tindex ].valcount ,1 );

   //proc
   on__val( inamelist[ nindex ] ,nindex ,tindex ,vindex );

   end;

end;

function tmakebase.addonceVal2(const dtypeindex:longint32;const xval:byte):boolean;//layer 3
var
   p        :longint32;
   t        :pmaketypeitem;

   function nindex:longint32;
   begin

   result   :=pred(inamecount);

   end;

   function vindex:longint32;
   begin

   result   :=pred( inamelist[ nindex ].typelist[ dtypeindex ].valcount );

   end;

begin

//get
result      :=
 (not imade)     and
 (nindex>=0    ) and
 (dtypeindex>=0) and ( dtypeindex <= high(inamelist[0].typelist            ) ) and
 (vindex>=-1   ) and ( vindex     <  high(inamelist[0].typelist[0].vallist ) ) ;

//set
if result then
   begin

   //find -> ensure value does not already exist
   if (vindex>=0) then
      begin

      //init
      t     :=@inamelist[ nindex ].typelist[ dtypeindex ];

      //find
      for p:=0 to pred(t.valcount) do
      begin

      if (xval=t.vallist[p]) then
         begin

         //value already exists -> exit
         exit;

         end;

      end;//p

      end;

   //get
   inamelist[ nindex ].typelist[ dtypeindex ].vallist[ vindex + 1 ]     :=xval;

   //enlarge typeList if required
   if (dtypeindex>=inamelist[ nindex ].typecount) then
      begin

      inamelist[ nindex ].typecount       :=dtypeindex + 1;

      end;

   //inc
   inc32( inamelist[ nindex ].typelist[ dtypeindex ].valcount ,1 );

   //proc
   on__val( inamelist[ nindex ] ,nindex ,dtypeindex ,vindex );

   end;

end;

function tmakebase.info__int32(const x:tmakelookup):longint32;
var
   tindex   :longint32;

   function r(const v,vmin,vmax:longint32):longint32;
   begin

   if      (v<vmin) then result:=vmin
   else if (v>vmax) then result:=vmax
   else                  result:=v;

   end;

begin

//check
if (not imade) or (x.nindex<0) or (x.nindex>=inamecount) then
   begin

   result   :=0;

   exit;

   end;

//get
result                :=pred(inamemultiplier[ x.nindex ]);

for tindex:=0 to pred(inamelist[ x.nindex ].typeCount) do
begin

inc( result , inamelist[ x.nindex ].typemultiplier[ tindex ] *

              r( x.vindex[tindex] ,0 , pred(inamelist[ x.nindex ].typelist[ tindex ].valCount) )

              );

end;//tindex

end;

function tmakebase.info__fromint32(x32:longint32;var x:tmakelookup):boolean;
var
   nindex   :longint32;
   tindex   :longint32;

begin

//defaults
result                :=imade and (x32>=0) and (x32<ifilecount);
x.nindex              :=0;

//check
if not result then
   begin

   //safe "nil" lookup record
   for tindex:=0 to high(x.vindex) do
   begin

   x.vindex[ tindex ] :=0;

   end;//p

   //stop
   exit;

   end;

//return lookup record
for nindex:=pred(inamecount) downto 0 do
begin

if (x32>=inameMultiplier[nindex]) then
   begin

   x.nindex :=nindex;

   break;

   end;

end;//p

x32                   :=x32 - inamemultiplier[x.nindex] + 1;//((x32 div namemultiplier[x.nindex])  * namemultiplier[x.nindex]);

//read vindex values
for tindex:=pred( inamelist[x.nindex].typecount ) downto 0 do
begin

if (x32>=1) then
   begin

   x.vindex[tindex]   :=x32 div inamelist[x.nindex].typemultiplier[tindex];
   x32                :=x32 - (x.vindex[tindex] * inamelist[x.nindex].typemultiplier[tindex]);

   end
else begin

   x.vindex[tindex]   :=0;

   end;

end;//tindex

end;

function tmakebase.filename(const xindex:longint):string;
var
   x:tmakelookup;

begin

if info__fromint32( xindex ,x ) then
   begin

   result   :=inamelist[x.nindex].name + '--' + low__digpad11( xindex, 8 ) + '.txt';

   end
else begin

   result   :='';

   end;

end;

function tmakebase.filesize(const xindex:longint):longint32;
var
   bol1     :boolean;

begin

result      :=filesize2( xindex ,bol1 );

end;

function tmakebase.filesize2(const xindex:longint;var xisApproximate:boolean):longint32;
begin

result                :=0;
xisApproximate        :=false;

end;

function tmakebase.filecolor(const xindex:longint):longint32;
begin

result      :=clnone;

end;

function tmakebase.findfile(const n:string;var dindex:longint32):boolean;
var
   p:longint32;

begin

//defaults
result      :=false;
dindex      :=0;

//check
if not imade then exit;

//find
for p:=0 to pred(ifilecount) do
begin

if strmatch( n ,filename(p) ) then
   begin

   result   :=true;
   dindex   :=p;

   break;

   end;

end;//p

end;

function tmakebase.fromfile(const xindex:longint;const xdata:tstr8):boolean;
begin

//defaults
result      :=true;

//clear
if (xdata<>nil) then
   begin

   xdata.clear;

   end;

end;


//## tmaketest #################################################################

procedure tmaketest.on__make(const xmakecode:string);
var
   n        :tmakenameitem;

   procedure a(const xname:string;const xcolor:longint32);
   begin

   addName( xname ,xmakecode ,0 ,tepCursor20 ,xcolor ,n );

   end;

   procedure ta;
   begin

   addType;

   end;

   procedure va(const xval:byte);
   begin

   addVal( xval );

   end;

begin

//nil

end;


//333333333333333333333333333
//## tmakecursor ###############################################################

procedure tmakecursor.on__create;
var
   p:longint32;

begin

//vars
iclassname            :='';
ifilesizeINF          :=0;//18jun2026

on__classname( iclassname );

for p:=0 to cf_max do
begin

ilastdata[p]          :=str__new8;
ilastmakeREF[p]       :='';
icursors1[p]          :=nil;
icursors2[p]          :=nil;
icursors3[p]          :=nil;

if (p<>cf_install) then
   begin

   on__createCursorType( p ,icursors1[p] ,icursors2[p] ,icursors3[p] );

   end;

end;//p

end;

procedure tmakecursor.on__classname(var xclassname:string);
begin

//nil

end;

procedure tmakecursor.on__createCursorType(const cfindex:longint32;var x1,x2,x3:tcursorbase);
begin

//nil

end;

procedure tmakecursor.on__destroy;
var
   p:longint32;

begin
try

//vars
for p:=0 to cf_max do
begin

str__free(@ilastdata[p]);

if (icursors1[p]<>nil) then freeobj(@icursors1[p]);
if (icursors2[p]<>nil) then freeobj(@icursors2[p]);
if (icursors3[p]<>nil) then freeobj(@icursors3[p]);

end;//p

except;end;
end;

procedure tmakecursor.on__setcursorcolorsetc(const a:tcursorbase;const x:tmakecursorinfo);
begin

//nil

end;

function tmakecursor.xintchar(const x:longint32):char;
begin

case x of
0    :result:='0';
1    :result:='1';
2    :result:='2';
3    :result:='3';
4    :result:='4';
5    :result:='5';
6    :result:='6';
7    :result:='7';
8    :result:='8';
9    :result:='9';
10   :result:='a';
11   :result:='b';
12   :result:='c';
13   :result:='d';
14   :result:='e';
15   :result:='f';
else  result:='f';
end;//case

end;

function tmakecursor.xcharint(const x:char):longint32;
begin

if      (x='0') then result:=0
else if (x='1') then result:=1
else if (x='2') then result:=2
else if (x='3') then result:=3
else if (x='4') then result:=4
else if (x='5') then result:=5
else if (x='6') then result:=6
else if (x='7') then result:=7
else if (x='8') then result:=8
else if (x='9') then result:=9

else if (x='a') then result:=10
else if (x='b') then result:=11
else if (x='c') then result:=12
else if (x='d') then result:=13
else if (x='e') then result:=14
else if (x='f') then result:=15

else if (x='A') then result:=10
else if (x='B') then result:=11
else if (x='C') then result:=12
else if (x='D') then result:=13
else if (x='E') then result:=14
else if (x='F') then result:=15

else                 result:=0;

end;

function tmakecursor.filename(const xindex:longint):string;
const
   xsep='-';

var
   x        :tmakecursorinfo;
   y        :tcursorbase;

begin

if cur__fromint32( xindex ,x ,y ) then
   begin

   //user based filename scheme
   if (iuserfilename<>'') then
      begin

      //user format and this file's format extensions match -> use the user's filename
      if strmatch(io__readfileext(iuserfilename,false),ext__CurAniInf( x )) then
         begin

         result:=

         io__extractnameonly( iuserfilename ) + '.' +
         ext__CurAniInf( x );

         end

      //modify the user's filename to accomodate this file's specific format/additional naming requirements
      else begin

         result:=

         io__extractnameonly( iuserfilename ) + xsep +
         cf__name( x.cf )                + '.'  +//e.g. "arrow"
         ext__CurAniInf( x );

         end;

      end

   //original unique filename
   else begin

      result:=

      inamelist[ x.n ].name     + insstr( xsep ,inamelist[ x.n ].name<>'' )+
      cc__name( x.cc )          + xsep +
      iclassname                + xsep +
      ca__name( x.ca )          + xsep +
      co__name( x.co )          + xsep +
      cv__name( x.cv )          + xsep +
      ct__name( x.ct )          + xsep +
      cur__id( x )              + xsep +
      cf__name( x.cf )          + '.'  +
      ext__CurAniInf( x );

      end;

   end

else begin

   result             :='unknown.cur';

   end;

end;

function tmakecursor.filesize2(const xindex:longint;var xisApproximate:boolean):longint32;
var
   x        :tmakecursorinfo;
   y        :tcursorbase;
   p        :longint32;
   bol1     :boolean;

begin

//defaults
result      :=1;

//get
if cur__fromint32( xindex ,x ,y ) and (y<>nil) then
   begin

   if (x.cf=cf_install) then
      begin

      if (ifilesizeINF<=0) then
         begin

         ifilesizeINF :=low__len32( fromfileINF( xindex ,x ,y ) );

         end;

      result          :=ifilesizeINF;
      xisApproximate  :=false;

      end
   else begin

      result          :=y.bytes;
      xisApproximate  :=cursor_usepng;

      //include any "altlist" resolutions
      for p:=0 to high(y.altlist) do
      begin

      if (y.altlist[p]<>nil) then
         begin

         inc32( result ,y.altlist[p].bytes )

         end

      else break;//stop

      end;//p

      //shrink size approximately to accommodate for PNG format
      if cursor_usepng then
         begin

         case x.ct of
         ct_sparkle   :result   :=result div 10;//random pixels -> less compression - 20jun2026
         else          result   :=result div 16;
         end;//case

         end;

      end;

   end;

end;

function tmakecursor.filecolor(const xindex:longint):longint32;
var
   x        :tmakecursorinfo;
   y        :tcursorbase;

begin

if cur__fromint32( xindex ,x ,y ) then result:=inameList[ x.n ].color
else                                   result:=clnone;

end;

//3333333333333333333333333333333333//xxxxxxxxxxxxxxxxxxxxxxxxxxx
function tmakecursor.fromfile(const xindex:longint;const xdata:tstr8):boolean;
var
   x        :tmakecursorinfo;
   y        :tcursorbase;
   p        :longint32;

begin

//defaults
result      :=false;

//clear
if (xdata=nil) then exit
else                xdata.clear;

//get
if cur__fromint32( xindex ,x ,y ) and (y<>nil) then
   begin

   //install script - 18jun2026
   if (x.cf=cf_install) then
      begin

      xdata.text      :=fromfileINF( xindex ,x ,y );

      result          :=(xdata.len32>=1);

      end

   //cursor .cur/.ani
   else begin

      //set cursor specific colors, effects, etc
      on__setcursorcolorsetc( y ,x );

      //alt list
      for p:=0 to high(y.altlist) do
      begin

      if (y.altlist[p]<>nil) then
         begin

         on__setcursorcolorsetc( y.altlist[p] ,x );

         end;

      end;//p

      //make cursor data stream -> xdata
      result   :=y.todata( xdata );

      end;

   end;

end;

function tmakecursor.fromfileINF(const xindex:longint;x:tmakecursorinfo;const y:tcursorbase):string;//18jun2026
const//Note: Supports all 17 cursors, including Location and Person
   xsep     ='-';

   procedure ladd(const xline:string);
   begin

   result   :=result + xline + rcode;

   end;

   function ffind(const cf_index:longint32):longint32;
   begin

   x.cf     :=cf_index;
   result   :=cur__int32( x );

   end;

   function fname(const cf_index:longint32):string;
   begin

   result   :=filename( ffind( cf_index ) );

   end;

   function xoriginalSchemeLabel:string;
   begin

   //init
   x.cf     :=cf_install;

   //get
   result   :=

   inamelist[ x.n ].name     + insstr( xsep ,inamelist[ x.n ].name<>'' )+
   cc__name( x.cc )          + xsep +
   iclassname                + xsep +//25jun2026
   ca__name( x.ca )          + xsep +
   co__name( x.co )          + xsep +
   cv__name( x.cv )          + xsep +
   ct__name( x.ct )          + xsep +
   cur__id( x );

   end;

   function xschemeLabel:string;
   begin

   //defaults
   result   :='';

   //init
   x.cf     :=cf_install;

   //get
   if (iuserfilename<>'') then
      begin

      result          :=io__extractnameonly( iuserfilename );

      end;

   //fallback
   if (result='') then
      begin

      result          :=xoriginalSchemeLabel;

      //upper-case 1st char
      result          :=strup( strcopy1(result,1,1) ) + strcopy1(result,2,low__len32(result));

      end;

   end;

   function xquote(const x:string):string;
   begin

   result   :='"' + x +'"';

   end;

begin

//defaults
result      :='';

//get
ladd( '; ' + app__info('name') + ' by ' + app__info('author.name') + #32 + app__info('url.portal') );
ladd('');

ladd('[Version]');
ladd('signature="$CHICAGO$"');
ladd( 'original name: '+xoriginalSchemeLabel );//original scheme name
ladd( app__info('url.software') );
ladd('');

ladd('[DefaultInstall]');
ladd('CopyFiles = Scheme.Cur, Scheme.Txt');
ladd('AddReg    = Scheme.Reg');
ladd('');

ladd('[DestinationDirs]');
ladd('Scheme.Cur = 10,"%CUR_DIR%"');
ladd('Scheme.Txt = 10,"%CUR_DIR%"');
ladd('');

ladd('[Scheme.Reg]');
ladd('HKCU,"Control Panel\Cursors\Schemes","%SCHEME_NAME%",,"%10%\%CUR_DIR%\%pointer%,%10%\%CUR_DIR%\%help%,%10%\%CUR_DIR%\%work%,%10%\%CUR_DIR%\%busy%,%10%\%CUR_DIR%\%cross%,'+'%10%\%CUR_DIR%\%Text%,%10%\%CUR_DIR%\%Hand%,%10%\%CUR_DIR%\%unavailiable%,%10%\%CUR_DIR%\%Vert%,%10%\%CUR_DIR%\%Horz%,%10%\%CUR_DIR%\%Dgn1%,%10%\%CUR_DIR%\%Dgn2%,%10%\%CUR_DIR%\%move%,'+'%10%\%CUR_DIR%\%alternate%,%10%\%CUR_DIR%\%link%,%10%\%CUR_DIR%\%location%,%10%\%CUR_DIR%\%person%"');

ladd('');

ladd('');
ladd('; --- installed files ---');
ladd('');

ladd('[Scheme.Cur]');
ladd( xquote(fname( cf_arrow )) );
ladd( xquote(fname( cf_help  )) );
ladd( xquote(fname( cf_work  )) );
ladd( xquote(fname( cf_wait  )) );
ladd( xquote(fname( cf_txt   )) );
ladd( xquote(fname( cf_no    )) );
ladd( xquote(fname( cf_ns    )) );
ladd( xquote(fname( cf_ew    )) );
ladd( xquote(fname( cf_nwse  )) );
ladd( xquote(fname( cf_nesw  )) );
ladd( xquote(fname( cf_move  )) );
ladd( xquote(fname( cf_hand  )) );
ladd( xquote(fname( cf_cross )) );
ladd( xquote(fname( cf_pen   )) );
ladd( xquote(fname( cf_alt   )) );
ladd( xquote(fname( cf_pin   )) );
ladd( xquote(fname( cf_person)) );
ladd('');

ladd('[Strings]');
ladd( strpad('CUR_DIR',14)       + '=' + xquote('Cursors\' + io__safename( xschemeLabel )) );
ladd( strpad('SCHEME_NAME',14)   + '=' + xquote(xschemeLabel)                              );
ladd( strpad('pointer',14)       + '=' + xquote(fname( cf_arrow  )) );
ladd( strpad('help',14)          + '=' + xquote(fname( cf_help   )) );
ladd( strpad('work',14)          + '=' + xquote(fname( cf_work   )) );
ladd( strpad('busy',14)          + '=' + xquote(fname( cf_wait   )) );
ladd( strpad('text',14)          + '=' + xquote(fname( cf_txt    )) );
ladd( strpad('unavailiable',14)  + '=' + xquote(fname( cf_no     )) );
ladd( strpad('vert',14)          + '=' + xquote(fname( cf_ns     )) );
ladd( strpad('horz',14)          + '=' + xquote(fname( cf_ew     )) );
ladd( strpad('dgn1',14)          + '=' + xquote(fname( cf_nwse   )) );
ladd( strpad('dgn2',14)          + '=' + xquote(fname( cf_nesw   )) );
ladd( strpad('move',14)          + '=' + xquote(fname( cf_move   )) );
ladd( strpad('link',14)          + '=' + xquote(fname( cf_hand   )) );
ladd( strpad('cross',14)         + '=' + xquote(fname( cf_cross  )) );
ladd( strpad('hand',14)          + '=' + xquote(fname( cf_pen    )) );//handwriting
ladd( strpad('alternate',14)     + '=' + xquote(fname( cf_alt    )) );
ladd( strpad('location',14)      + '=' + xquote(fname( cf_pin    )) );//18jun2026 - OK
ladd( strpad('person',14)        + '=' + xquote(fname( cf_person )) );//18jun2026 - OK

end;

function tmakecursor.toanimation(const xwantSize,xindex:longint;const ximage:tcommonimage):boolean;
var
   x        :tmakecursorinfo;
   y        :tcursorbase;

begin

//defaults
result      :=false;

//check
if (ximage=nil) then exit;

//get
if cur__fromint32( xindex ,x ,y ) and (y<>nil) then
   begin

   //set cursor specific colors, effects, etc
   on__setcursorcolorsetc( y ,x );

   //make cursor data stream -> xdata
   result   :=y.toanimation( xwantSize ,ximage );

   end

else begin

  missize( ximage ,1 ,1 );

  end;

end;

function tmakecursor.toanimationinfo(const xwantSize,xindex:longint;var x:tanimationinfo):boolean;
var
   v        :tmakecursorinfo;
   y        :tcursorbase;

begin

//defaults
result      :=false;

//get
if cur__fromint32( xindex ,v ,y ) and (y<>nil) then
   begin

   y                  :=y.xfindWantSize( xwantSize );
   x.cellcount        :=y.cellcount;
   x.cellwidth        :=y.width;
   x.cellheight       :=y.height;
   x.delay            :=y.delay;
   x.cursorinfo       :=y.info;

   //successful
   result             :=true;

   end

else begin

  low__cls(@x,sizeof(x));

  end;

end;

function tmakecursor.toanimationcell(const xwantSize,xindex,xcellindex:longint32;const ximage:tcommonimage):boolean;
var
   x        :tmakecursorinfo;
   y        :tcursorbase;

begin

//defaults
result      :=false;

//check
if (ximage=nil) then exit;

//get
if cur__fromint32( xindex ,x ,y ) and (y<>nil) then
   begin

   //want size
   y        :=y.xfindWantSize( xwantSize );

   //set cursor specific colors, effects, etc
   on__setcursorcolorsetc( y ,x );

   //make cursor data stream -> xdata
   result   :=y.toanimationcell( 0 ,xcellindex ,ximage );

   end

else begin

  missize( ximage ,1 ,1 );

  end;

end;

function tmakecursor.cur__fromint32(const xindex:longint;var x:tmakecursorinfo;var y:tcursorbase):boolean;
var
   a                  :tmakelookup;
   p                  :longint32;
   
begin

//get
result      :=inherited info__fromint32( xindex ,a );
y           :=nil;

//set
if result then
   begin

   x.n                :=a.nindex;
   x.cf               :=inamelist[ x.n ].typelist[ cx_cf ].vallist[ a.vindex[ cx_cf ] ];
   x.cc               :=inamelist[ x.n ].typelist[ cx_cc ].vallist[ a.vindex[ cx_cc ] ];
   x.cb               :=inamelist[ x.n ].typelist[ cx_cb ].vallist[ a.vindex[ cx_cb ] ];
   x.co               :=inamelist[ x.n ].typelist[ cx_co ].vallist[ a.vindex[ cx_co ] ];
   x.ca               :=inamelist[ x.n ].typelist[ cx_ca ].vallist[ a.vindex[ cx_ca ] ];
   x.ct               :=inamelist[ x.n ].typelist[ cx_ct ].vallist[ a.vindex[ cx_ct ] ];
   x.cv               :=inamelist[ x.n ].typelist[ cx_cv ].vallist[ a.vindex[ cx_cv ] ];

   //fetch the cursor for use with data generation -----------------------------

   //try 1 -> assume there is a dedicated cursor handler for each cursor type (cf_code)
   y                  :=icursors1[ x.cf ];

   //try 2 -> assume "cr_arrow" is a shared cursor handler for all cursor types
   if (y=nil) then
      begin

      y               :=icursors1[ cf_arrow ];

      end;

   //sync cursor info -> fast -> minimal update
   if (y<>nil) then
      begin

      y.setinfo( x );

      for p:=0 to high(y.altlist) do
      begin

      if (y.altlist[p]<>nil) then y.altlist[p].setinfo( x )
      else                        break;

      end;//p

      end;

   end;

end;

function tmakecursor.cur__int32(const x:tmakecursorinfo):longint32;//13jun2026
var
   a                  :tmakelookup;
   p                  :longint32;

   function fval(const cx_index,xval:longint32):longint32;
   var
      p               :longint32;

   begin

   //defaults
   result             :=0;

   //check
   if (cx_index<0) or (cx_index>=inamelist[ x.n ].typeCount) then
      begin

      exit;

      end;

   //find
   for p:=0 to pred( inamelist[ x.n ].typelist[ cx_index ].valcount) do
   begin

   if ( xval = inamelist[ x.n ].typelist[ cx_index ].vallist[p] ) then
      begin

      result          :=p;

      break;

      end;

   end;//p

   end;

begin

//get
if (x.n<0) or (x.n>=inamecount) then
   begin

   a.nindex           :=0;

   for p:=0 to high(a.vindex) do
   begin

   a.vindex[p]        :=0;

   end;//p

   end
else begin

   a.nindex           :=x.n;

   //for each cursor sub-value "x.*" look through the corresponding mathematical list for the matching value
   a.vindex[ cx_cf ]  :=fval( cx_cf ,x.cf );
   a.vindex[ cx_cc ]  :=fval( cx_cc ,x.cc );
   a.vindex[ cx_cb ]  :=fval( cx_cb ,x.cb );
   a.vindex[ cx_co ]  :=fval( cx_co ,x.co );
   a.vindex[ cx_ca ]  :=fval( cx_ca ,x.ca );
   a.vindex[ cx_ct ]  :=fval( cx_ct ,x.ct );
   a.vindex[ cx_cv ]  :=fval( cx_cv ,x.cv );

   end;

//set
result                :=inherited info__int32( a );

end;

function tmakecursor.cur__id(const x:tmakecursorinfo):string;
begin

result:=
 xintchar(x.cb) +
 xintchar(x.co) +
 xintchar(x.ca) +
 xintchar(x.ct) +
 xintchar(x.cv) +
 xintchar(x.cc) +
 xintchar(x.cf) +
 '';

end;

function tmakecursor.ext__code(const x:tmakecursorinfo):longint32;
begin

if (x.ca=ca_static) then
   begin

   result   :=ce_cur;

   end
else begin

   result   :=ce_ani;

   end;

end;

function tmakecursor.ext__CurAni(const x:tmakecursorinfo):string;
begin

if (x.ca=ca_static) then
   begin

   result   :='cur';

   end
else begin

   result   :='ani';

   end;

end;

function tmakecursor.ext__CurAniInf(const x:tmakecursorinfo):string;
begin

if (x.cf=cf_install) then
   begin

   result   :='inf';

   end
else if (x.ca=ca_static) then
   begin

   result   :='cur';

   end
else begin

   result   :='ani';

   end;

end;

function tmakecursor.cur__TypeChar(const x:tmakecursorinfo):string;
begin

if (x.ca=ca_static) then
   begin

   result   :='s';//s=static

   end
else begin

   result   :='a';//a=animated

   end;

end;


//## tmakecursordefault ########################################################

procedure tmakecursordefault.on__classname(var xclassname:string);
begin

xclassname  :='default';

end;

procedure tmakecursordefault.on__createCursorType(const cfindex:longint32;var x1,x2,x3:tcursorbase);
begin

x1                    :=tcursordefault.create;
x1.size               :=128;

x2                    :=tcursordefault.create;
x2.size               :=64;

//tell "x1" that "x2" exists -> allows for multi-resolution cursors
x1.altlist[0]         :=x2;

end;

procedure tmakecursordefault.on__setcursorcolorsetc(const a:tcursorbase;const x:tmakecursorinfo);

   function c(const r,g,b:byte):longint32;
   begin

   result   :=rgba0__int( r ,g ,b );

   end;

   procedure sc(const e,b1,b2,b3,s:longint32);
   begin

   a.edgeColor        :=e;
   a.bodyColor1       :=b1;
   a.bodyColor2       :=b2;
   a.bodyColor3       :=b3;
   a.sparkleColor     :=s;

   end;

   procedure sb2(const b1,b2:longint32);
   begin

   sc( clnone ,b1 ,b2 ,b1 ,clnone);

   end;

   procedure sb3(const b1,b2,b3:longint32);
   begin

   sc( clnone ,b1 ,b2 ,b3 ,clnone);

   end;

   procedure cs3(const x:tcursorcolorset);//25jun2026
   begin

   sb3( x.body ,x.body2 ,x.body3 );

   end;

   procedure scustom;
   begin

   if cursor_customcolors.useShared then cs3( cursor_customcolors.shared        )
   else                                  cs3( cursor_customcolors.clist[ x.cf ] );

   end;

begin

//colors
case x.cc of

//rainbow
cc_rainbow            :sb2( 0   ,rainbow32__int(0.87,0)  );//fallback values only -> cursor uses realtime values instead

//custom -> user defined colors
cc_customcolor        :scustom;

//red
cc_red                :sb3( 0   ,c(255,000,000) ,c(255,255,000) );
//cc_red2               :sb3( 0   ,c(255,137,128) ,c(191,79,255) );
cc_red2               :sb3( 0   ,c(244,1,76) ,c(165,248,0) );



//cc_red2               :sb( 0   ,rgba0__int(255,064,064) );
cc_red3               :sb2( 60  ,c(255,24,78)   );
cc_red4               :sb2( 0   ,c(169,13,0)    );
cc_red5               :sb2( 0   ,c(193,0,77)    );
cc_red6               :sb2( 0   ,c(255,137,128) );
cc_red7               :sb2( 0   ,c(253,73,0)    );
cc_red8               :sb2( 120 ,c(255,100,000) );
cc_red9               :sb2( 64  ,c(255,173,97)  );
cc_red10              :sb2( 120 ,c(248,165,0)   );


//green
cc_green              :sb3( 0 ,c(000,255,000) ,c(224,0,251) );
cc_green2             :sb3( 0 ,c(125,255,141) ,c(124,0,151) );

cc_green3             :sb2( 0 ,c(128,255,128) );
cc_green4             :sb2( 0 ,c(000,128,000) );


//blue
cc_blue               :sb3( 0 ,c(000,000,255) ,c(223,35,0) );
cc_blue2              :sb3( 0 ,c(114,152,255) ,c(224,73,73) );


//yellow
cc_yellow             :sb3( 0 ,c(255,255,000) ,c(0,151,146) );
cc_yellow2            :sb3( 0 ,c(255,255,128) ,c(0,126,123) );
cc_yellow3            :sb2( 0 ,c(128,120,000) );


//aqua
cc_aqua               :sb3( 0 ,c(000,255,255) ,c(62,0,131) );
cc_aqua2              :sb3( 0 ,c(141,255,242) ,c(108,0,226) );


//orange
cc_orange             :sb3( 0 ,c(255,128,000) ,c(108,0,226) );
cc_orange2            :sb3( 0 ,c(236,170,105) ,c(125,255,48) );


//purple
cc_purple             :sb3( 0 ,c(128,000,255) ,c(251,255,103) );
cc_purple2            :sb3( 0 ,c(177,117,236) ,c(242,0,120) );


//pink
cc_pink               :sb3( 0 ,c(255,024,216) ,c(150,0,93) );
cc_pink2              :sb3( 0 ,c(237,145,255) ,c(255,20,82) );
cc_pink3              :sb2( 0 ,c(255,090,255) );


//white
cc_white              :sb2( 0 ,c(255,255,255) );


//grey
cc_grey               :sb2( 0 ,c(150,150,150) );


//black
cc_black              :sb3( 0 ,c(060,060,060) ,c(255,255,255) );


//brown
cc_brown              :sb3( 0 ,c(158,075,000) ,c(195,177,0) );
cc_brown2             :sb3( 0 ,c(179,142,110) ,c(99,83,144) );


//cccccccccccccccccccccccccccccccccccccc//????????????????


else                   sb2( 0 ,rgba0__int(200,200,200) );
end;//case


end;

procedure tmakecursordefault.on__make(const xmakecode:string);//'red'
const
   xsep               =#32;

var
   n                  :tmakenameitem;
   p                  :longint32;
   vcolor             :longint32;
   cc_index           :longint32;
   ca_index           :longint32;
   ct_index           :longint32;
   xok                :boolean;

   procedure vinit;
   var
      xdata           :string;

      function vnext:string;
      begin

      low__splitstrSAFE( xdata ,ssDot ,result ,xdata );

      end;

   begin

   //init
   xdata              :=xmakecode + '.';//enforce trailing separator

   //.cc / ca / ct
   cc_index           :=frcrange32( strint32(strdefb(vnext,'-1')) , 0 ,cc_max );//0..N=specific
   ca_index           :=frcrange32( strint32(strdefb(vnext,'-1')) ,-2 ,ca_max );//-2=static and all animated, -1=all animated ,0..N=specific
   ct_index           :=frcrange32( strint32(strdefb(vnext,'-1')) ,-1 ,ct_max );

   //.color
   vcolor             :=strint32( vnext );

   end;

   procedure a(const xname:string;const xcolor:longint32);
   begin

   addName( xname ,xmakecode ,0 ,tepCursor20 ,xcolor ,n );

   end;

   procedure t;
   begin

   addType;

   end;

   procedure v1(const xval:byte);
   begin

   addonceVal( xval );//exclude repeat values

   end;

   procedure v2(const dtypeIndex:longint32;const xval:byte);
   begin

   addonceVal2( dtypeIndex ,xval );//exclude repeat values

   end;

   procedure cf__all;
   var
      p     :longint32;
   begin

   for p:=0 to cf_max do
   begin

   v2( cx_cf ,p );

   end;//p

   end;

   procedure xaddcolor(const xcolorcode:longint32);
   begin

   if (xcolorcode>=0) and (xcolorcode<=cc_max) then
      begin

      v2( cx_cc ,xcolorcode );

      end;

   end;

   procedure xaddcolors(const xfrom,xto:longint32);//add color range
   var
      c               :longint32;

   begin

   for c:=xfrom to xto do
   begin

   xaddcolor( c );

   end;//p

   end;

   function xcanstatic:boolean;
   begin

   result:=(cc_index<cc_rainbow) or (cc_index>cc_rainbowMAX);

   end;

begin

//init -------------------------------------------------------------------------

vinit;


//label
a( '' ,vcolor );


//all cursor files (0..cf_max)
cf__all;


//32-bit
v2( cx_cb ,cb_32 );


//opacity
v2( cx_co ,co_100 );
v2( cx_co ,co_75 );
v2( cx_co ,co_50 );


//animated or static
for p:=ca_max downto 0 do
begin

if (ca_index=-2) or ( (ca_index=-1) and (p<>ca_static) ) or (p=ca_index) then
   begin

   if (p<>ca_static) or xcanstatic then
      begin

      v2( cx_ca ,p );

      end;

   end;

end;//p


//type -> filter which cursor types get added based on color type --------------
for p:=0 to ct_max do
begin

if (ct_index<0) or (p=ct_index) then
   begin

   //init
   xok                :=true;


   //rainbow cursors use a small subset of cursor types as the color range is fixed
   if (cc_index>=cc_rainbow) and (cc_index<=cc_rainbowMAX) then
      begin

      //cc_rainbow4/5 slide the color shade left or right, and effects other than ct_plain/ct_sparkle are not suitable - 20jun2026
      case cc_index of
      cc_rainbow4     :xok      :=(p=ct_plain) or (p=ct_sparkle);
      cc_rainbow5     :xok      :=(p=ct_plain) or (p=ct_sparkle);
      end;//case

      //exclude ct_colors for all rainbow cursors
      xok                       :=xok and ( (p<>ct_colors) and (p<>ct_colors2) and (p<>ct_colors3) );

      end

   else begin

      v2( cx_ct ,p )

      end;

   //add cursor type
   if xok then
      begin

      v2( cx_ct ,p );

      end;


   end;

end;//p


//canvas
for p:=0 to cv_max do
begin

if (p=cv_outline) and strmatch(iclassname,'modern') then
   begin

   //nil

   end
else v2( cx_cv ,p )

end;


//colors -----------------------------------------------------------------------

if (cc_index>=0) and (cc_index<=cc_max) then
   begin

   xaddcolor( cc_index );

   end;

end;


//555555555555555555555555555//xxxxxxxxxxxxxxxxxxx
//## tmakecursormodern #########################################################

procedure tmakecursormodern.on__classname(var xclassname:string);
begin

xclassname  :='modern';

end;

procedure tmakecursormodern.on__createCursorType(const cfindex:longint32;var x1,x2,x3:tcursorbase);
begin

x1                    :=tcursormodern.create;
x1.size               :=128;

x2                    :=tcursormodern.create;
x2.size               :=64;

//tell "x1" that "x2" exists -> allows for multi-resolution cursors
x1.altlist[0]         :=x2;

end;


//## tmakewallpaper ############################################################

//9999999999999999999999999999
constructor tmakewallpaper.create;
begin

//self
if classnameis('tmakewallpaper') then track__inc(satOther,1);
inherited create;

//vars
icount                :=0;
iname                 :=tdynamicinteger.create;
iwcm                  :=tdynamicinteger.create;//(0)color modifier (1 only) + (1)mirror
iwemList              :='';
ifuzzRandom           :=nil;

end;

destructor tmakewallpaper.destroy;
begin
try

//vars
freeobj(@iname);
freeobj(@iwcm);
freeobj(@ifuzzRandom);

//self
inherited destroy;
if classnameis('tmakewallpaper') then track__inc(satOther,-1);

except;end;
end;

procedure tmakewallpaper.makelist(const xwemList:string);
var
   p                  :longint32;
   p2                 :longint32;
   xdata              :pauto;
   xdatalen           :longint32;
   xorgsize           :longint32;
   xcompressed        :boolean;
   xpathname          :string;
   dext               :string;
   v                  :string;
   c                  :char;

   procedure xadd(const xnameIndex,xwcm:longint32);
   var
      i                         :longint32;
      v                         :tint4;
   begin

   i                            :=iname.count;
   iname.value[i]               :=xnameIndex;

   v.val                        :=0;//clear
   v.bytes[0]                   :=xwcm;           //byte0 stores color modifier

   iwcm.value[i]                :=v.val;

   end;

begin

//clear
iname.clear;
iwcm.clear;
icount                :=0;
iwemList              :=xwemList;


//get
for p:=0 to max32 do
begin

if archiveFiles.storage__findfile( p ,xdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   //exclude system files that start with "." e.g. ".about.jpg"
   if (strcopy1(xpathname,1,1)<>'.') then
      begin

      dext               :=io__readfileext_low( xpathname );

      if (dext='jpg') or (dext='png') then
         begin

         //color adjusters
         for p2:=0 to wcm_max do
         begin

         xadd( p ,p2 );

         end;//p2

         end;

      end;

   end

else break;

end;//p

icount                :=iname.count;

end;

function tmakewallpaper.file__count:longint32;
begin

result      :=icount;

end;

function tmakewallpaper.file__name(const xindex:longint32):string;
var
   xdata              :pauto;
   xdatalen           :longint32;
   xorgsize           :longint32;
   xcompressed        :boolean;
   xpathname          :string;

begin

//defaults
result                :='';

//get
if (xindex>=0) and (xindex<icount) and archiveFiles.storage__findfile( iname.value[xindex] ,xdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   result             :=io__remlastext(xpathname)             +
                        '_' + wcm__name( find__wcm(xindex) )  +
                        '.' + io__extractfileext(xpathname);

   end;

end;

function tmakewallpaper.file__size(const xindex:longint32):longint32;
var
   xisApproximate     :boolean;

begin

result                :=file__size2( xindex ,xisApproximate );

end;

function tmakewallpaper.find__wcm(const xindex:longint32):longint32;
begin

if (xindex>=0) and (xindex<icount) then result:=tint4(iwcm.value[xindex]).bytes[0]
else                                    result:=wcm_normal;

end;

function tmakewallpaper.find__mirror:boolean;
begin

result      :=wallpaper__mirror;

end;

function tmakewallpaper.find__pixelateSize:longint32;
begin

result      :=wallpaper__pixelateSize;

end;

function tmakewallpaper.find__fade:longint32;
begin

result      :=wallpaper__fade;

end;

function tmakewallpaper.find__brightnessRatio:single;
begin

result      :=wallpaper__brightnessRatio;

end;

function tmakewallpaper.file__size2(const xindex:longint32;var xisApproximate:boolean):longint32;
var
   xdata              :pauto;
   xdatalen           :longint32;
   xorgsize           :longint32;
   xcompressed        :boolean;
   xpathname          :string;
   dext               :string;

begin

//defaults
result                :=0;
xisApproximate        :=false;

//get
if (xindex>=0) and (xindex<icount) and archiveFiles.storage__findfile( iname.value[xindex] ,xdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   //init
   result             :=xorgSize;

   //get
   if (iwemlist<>'') or (find__wcm(xindex)<>wcm_normal) or find__mirror or (find__pixelateSize>=1) or (find__brightnessRatio<>1.0) or (find__fade>=1) then
      begin

      xisApproximate  :=true;
      dext            :=io__extractfileext(xpathname);

      if strmatch(dext,'jpg') or strmatch(dext,'jif') or strmatch(dext,'jpeg') then
         begin

         result          :=round32( result * 1.90 );

         end;

      end;

   end;

end;

function tmakewallpaper.file__data(const xindex:longint32;const xdata:tstr8):boolean;
var
   a                  :tstr8;
   b                  :tbasicimage;
   pdata              :pauto;
   xdatalen           :longint32;
   xorgsize           :longint32;
   xcompressed        :boolean;
   xpathname          :string;
   e                  :string;
   dext               :string;

begin

//defaults
result                :=false;
a                     :=nil;
b                     :=nil;

try

//get
if str__ok(@xdata) and (xindex>=0) and (xindex<icount) and archiveFiles.storage__findfile( iname.value[xindex] ,pdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   //init
   a     :=rescache__newStr8;
   dext  :=strlow( io__extractfileext(xpathname) );

   //get
   if a.addrec( pdata ,xdatalen ) and ( (not xcompressed) or low__decompress(@a) ) then
      begin

      //no adjustment
      if (iwemlist='') and (find__wcm(xindex)=wcm_normal) and (not find__mirror) and (find__pixelateSize<=0) and (find__brightnessRatio=1.0) and (find__fade=0) then
         begin

         xdata.clear;
         xdata.addfast32( a );

         result       :=true;

         end

      //perform adjustment
      else begin

         //init
         b            :=misimg32(1,1);

         //get and adjust
         if mis__fromdata( b ,@a ,e ) and xadjust( b ,xindex ) then
            begin

            //convert
            if (dext='jpg') or (dext='jif') or (dext='jpeg') then
               begin

               result    :=mis__todata2( b ,@xdata ,'jpg' ,ia__iadd64('',ia_quality100,[95]) ,e );//90% for fast high quality - 02sep2026

               end

            else begin

               result    :=mis__todata2( b ,@xdata ,dext ,'' ,e );

               end;

            end;

         end;

      end;

   end;

except;end;

//free
rescache__delStr8( @a );
freeobj(@b);

//clear on error
if not result then str__clear(@xdata);

end;

function tmakewallpaper.xadjust(const s:tbasicimage;const xindex:longint32):boolean;
label
   skipend;

var
   stemp              :tbasicimage;
   p                  :longint32;
   v                  :char;
   sw                 :longint32;
   sh                 :longint32;
   int1               :longint32;
   c                  :char;
   xonce              :boolean;

begin

//defaults
result                :=false;
stemp                 :=nil;
xonce                 :=true;

//check
if (xindex<0) or (xindex>=icount) then exit;
if not misok32(s,sw,sh)           then exit;


//effect modifiers (pre-processing) --------------------------------------------

//mirror
if find__mirror then mis__mirror82432( s );

//mixers
for p:=1 to low__len32(iwemlist) do
begin

c                     :=iwemlist[ p - 1 + stroffset ];

//.pre-pixelate
if (c>=wem_mix1) and (c<=wem_mix5) then
   begin

   if xonce then
      begin

      xonce:=false;
      if (find__pixelateSize>=1) then xpixelate( s ,find__pixelateSize );

      end;

   end;

if      (c=wem_mix1)   then   xmix( s ,sw ,sh ,0 )
else if (c=wem_mix2)   then   xmix( s ,sw ,sh ,1 )
else if (c=wem_mix3)   then   xmix( s ,sw ,sh ,2 )
else if (c=wem_mix4)   then   xmix( s ,sw ,sh ,3 )
else if (c=wem_mix5)   then   xmix( s ,sw ,sh ,4 )
else if (c=wem_skew1)  then   xskew( s ,sw ,sh ,0 )
else if (c=wem_skew2)  then   xskew( s ,sw ,sh ,1 )
else if (c=wem_skew3)  then   xskew( s ,sw ,sh ,2 );

end;//p

//post-pixelate
if xonce then
   begin

   xonce:=false;
   if (find__pixelateSize>=1) then xpixelate( s ,find__pixelateSize );

   end;


//color modifiers --------------------------------------------------------------
case find__wcm(xindex) of
wcm_normal            :;//nil
wcm_hue0              :xhue( s ,sw ,sh ,1  );
wcm_hue1              :xhue( s ,sw ,sh ,2  );
wcm_hue2              :xhue( s ,sw ,sh ,3  );
wcm_hue3              :xhue( s ,sw ,sh ,4  );
wcm_hue4              :xhue( s ,sw ,sh ,5  );
wcm_hue5              :xhue( s ,sw ,sh ,6  );
wcm_hue6              :xhue( s ,sw ,sh ,7  );
wcm_hue7              :xhue( s ,sw ,sh ,8  );
wcm_hue8              :xhue( s ,sw ,sh ,9  );
wcm_hue9              :xhue( s ,sw ,sh ,10 );
wcm_hue10             :xhue( s ,sw ,sh ,11 );
wcm_hue11             :xhue( s ,sw ,sh ,12 );

wcm_pink              :xtint( s ,sw ,sh ,255 ,018 ,171 );
wcm_sweetblue         :xtint( s ,sw ,sh ,102 ,215 ,255 );
wcm_red               :xtint( s ,sw ,sh ,255 ,000 ,000 );
wcm_green             :xtint( s ,sw ,sh ,000 ,255 ,000 );
wcm_blue              :xtint( s ,sw ,sh ,000 ,000 ,255 );
wcm_yellow            :xtint( s ,sw ,sh ,255 ,255 ,000 );
wcm_sepia             :xtint( s ,sw ,sh ,222 ,185 ,130 );

wcm_invertR           :xinvert( s ,sw ,sh ,0 );
wcm_invertG           :xinvert( s ,sw ,sh ,1 );
wcm_invertB           :xinvert( s ,sw ,sh ,2 );

wcm_invertR2          :xinvert( s ,sw ,sh ,3 );
wcm_invertG2          :xinvert( s ,sw ,sh ,4 );
wcm_invertB2          :xinvert( s ,sw ,sh ,5 );

wcm_invertRGB         :xinvert( s ,sw ,sh ,6 );

end;//case


//effect modifiers (post-processing) -------------------------------------------

//brightness
if (find__brightnessRatio<>1.0) then xbrightness( s ,sw ,sh ,find__brightnessRatio );

//fade
case find__fade of
1:xfadeLR( s ,sw ,sh ,0 );//left
2:xfadeLR( s ,sw ,sh ,1 );//left
3:xfadeLR( s ,sw ,sh ,2 );//right
4:xfadeLR( s ,sw ,sh ,3 );//right
5:xfadeTB( s ,sw ,sh ,0 );//top
6:xfadeTB( s ,sw ,sh ,1 );//top
7:xfadeTB( s ,sw ,sh ,2 );//bottom
8:xfadeTB( s ,sw ,sh ,3 );//bottom
end;//case


//successful
result                :=true;
skipend:

//free
freeobj(@stemp);

end;

procedure tmakewallpaper.xhue(const s:tbasicimage;const sw,sh:longint32;v:longint32);//02sep2026
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   xpertMode          :longint32;
   xpert              :single;
   dpert              :single;
   sc                 :tcolor32;
   t                  :longint32;


begin

//range
v                     :=frcrange32( v, 1, 13 );
xpert                 :=v/13;

if (xpert>=1.0) then exit

else if (xpert<=0.33) then
   begin

   xpertMode          :=0;
   dpert              :=(xpert - 0.00) * 3;//for 1.0

   end

else if (xpert<=0.66) then
   begin

   xpertMode          :=1;
   dpert              :=(xpert - 0.33) * 3;//for 1.0

   end

else begin

   xpertMode          :=2;
   dpert              :=(xpert - 0.66) * 3;//for 1.0

   end;

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

for sx:=0 to pred(sw) do
begin


sc                 :=sr[sx];


case xpertMode of

0:begin//0.00 .. 0.33

   sr[sx].r        :=round( (sc.r-(dpert*sc.r)) + (sc.g*dpert)  );//r -> g
   sr[sx].g        :=round( (sc.g-(dpert*sc.g)) + (sc.b*dpert)  );//g -> b
   sr[sx].b        :=round( (sc.b-(dpert*sc.b)) + (sc.r*dpert)  );//b -> r

   end;

1:begin//0.34 .. 0.66

   sr[sx].r        :=round( (sc.g-(dpert*sc.g)) + (sc.b*dpert) );//g -> b
   sr[sx].g        :=round( (sc.b-(dpert*sc.b)) + (sc.r*dpert) );//b -> r
   sr[sx].b        :=round( (sc.r-(dpert*sc.r)) + (sc.g*dpert) );//r -> g

   end;

2:begin//0.67 .. 1.00

   sr[sx].r        :=round( (sc.b-(dpert*sc.b)) + (sc.r*dpert) );//b -> r
   sr[sx].g        :=round( (sc.r-(dpert*sc.r)) + (sc.g*dpert) );//r -> g
   sr[sx].b        :=round( (sc.g-(dpert*sc.g)) + (sc.b*dpert) );//g -> b

   end;

end;//case


end;//sx

end;//sy

end;

procedure tmakewallpaper.xtint(const s:tbasicimage;const sw,sh:longint32;const r,g,b:byte);
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   sc                 :tcolor32;

begin

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

for sx:=0 to pred(sw) do
begin


sc                    :=sr[sx];

if (sc.g>sc.r) then sc.r:=sc.g;
if (sc.b>sc.r) then sc.r:=sc.b;

sr[sx].r              :=(sc.r * r) shr 8;
sr[sx].g              :=(sc.r * g) shr 8;
sr[sx].b              :=(sc.r * b) shr 8;


end;//sx

end;//sy

end;

procedure tmakewallpaper.xinvert(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;

begin

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

case xmode of

0:for sx:=0 to pred(sw) do sr[sx].r:=255-sr[sx].r;
1:for sx:=0 to pred(sw) do sr[sx].g:=255-sr[sx].g;
2:for sx:=0 to pred(sw) do sr[sx].b:=255-sr[sx].b;
3:for sx:=0 to pred(sw) do sr[sx].r:=( sr[sx].r + (255-sr[sx].r) ) shr 2;
4:for sx:=0 to pred(sw) do sr[sx].g:=( sr[sx].g + (255-sr[sx].g) ) shr 2;
5:for sx:=0 to pred(sw) do sr[sx].b:=( sr[sx].b + (255-sr[sx].b) ) shr 2;
6:begin

   for sx:=0 to pred(sw) do
   begin

   sr[sx].r:=255-sr[sx].r;
   sr[sx].g:=255-sr[sx].g;
   sr[sx].b:=255-sr[sx].b;

   end;

   end;

end;//case

end;//sy

end;

procedure tmakewallpaper.xmix(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   v                  :longint32;
   l                  :longint32;
   c                  :tcolor32;

begin

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

case xmode of

0:begin//red

   for sx:=0 to pred(sw) do
   begin

   v        :=round( sr[sx].r * 1.2 );

   if (v>255) then v:=255;

   sr[sx].r :=v;

   case v of
   0..128  :sr[sx].g:=sr[sx].g div 2;
   else     sr[sx].b:=sr[sx].b div 2;
   end;//case

   end;//sx

   end;

1:begin//green

   for sx:=0 to pred(sw) do
   begin

   v        :=round( sr[sx].g * 1.2 );

   if (v>255) then v:=255;

   sr[sx].g :=v;

   case v of
   0..128  :sr[sx].b:=sr[sx].b div 2;
   else     sr[sx].r:=sr[sx].r div 2;
   end;//case

   end;//sx

   end;

2:begin//blue

   for sx:=0 to pred(sw) do
   begin

   v        :=round( sr[sx].b * 1.2 );

   if (v>255) then v:=255;

   sr[sx].b :=v;

   case v of
   0..128  :sr[sx].r:=sr[sx].r div 2;
   else     sr[sx].g:=sr[sx].g div 2;
   end;//case

   end;//sx

   end;

3:begin

   for sx:=0 to pred(sw) do
   begin

   c        :=sr[sx];

   if low__iseven(sx) then
      begin

      sr[sx].r   :=c.g;
      sr[sx].g   :=c.b;
      sr[sx].b   :=c.r;

      end
   else begin

      sr[sx].r   :=c.b;
      sr[sx].g   :=c.r;
      sr[sx].b   :=c.g;

      end;

   end;//sx

   end;

4:begin

   for sx:=0 to pred(sw) do
   begin

   c        :=sr[sx];

   if low__iseven(sx) then
      begin

      sr[sx].r   :=c.g;
      sr[sx].g   :=c.r;
//      sr[sx].b   :=c.b;

      end
   else begin

      sr[sx].r   :=c.b;
      sr[sx].g   :=c.g;
      sr[sx].b   :=c.r;

      end;

   end;//sx

   end;

end;//case

end;//sy

end;

procedure tmakewallpaper.xskew(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
const
   xlimit             =6;

var
   lr                 :pcolorrow32;
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   dx                 :longint32;
   v                  :longint32;

begin

//auto-create and fill
if (ifuzzRandom=nil) then ifuzzRandom:=tdynamicbyte.create;

if (sh>ifuzzRandom.count) then
   begin

   for sx:=ifuzzRandom.count to sh do ifuzzRandom.value[sx]:=random(xlimit);

   end;

//init
case xmode of
0   :v:=1;
1   :v:=2;
2   :v:=4;
else v:=1;
end;//case

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

if (sy>=1) then
   begin

   //init
   dx       :=ifuzzRandom.value[sy] * v;
   if (sx>=sw) then sx:=pred(sw);

   //get
   for sx:=0 to pred(sw) do
   begin

   if (dx<pred(sw)) then inc(dx);

   lr[sx]   :=sr[dx];

   end;//sx

   end;

lr          :=sr;

end;//sy

end;

procedure tmakewallpaper.xpixelate(const s:tbasicimage;const dsize:longint32);
var
   d                  :tbasicimage;

begin

//check
if (dsize<=0) then exit;

//defaults
d                     :=nil;

try
//init
d                     :=misimg32( frcmin32(misw(s) div dsize,1), frcmin32(mish(s) div dsize,1) );

//s -> d
mis__copyfast(maxarea,misarea(s),0,0,misw(d),mish(d),s,d);

//d -> s
mis__copyfast2(maxarea,misarea(d),0,0,misw(s),mish(s),d,s,100);

except;end;

//free
freeobj(@d);

end;

procedure tmakewallpaper.xbrightness(const s:tbasicimage;const sw,sh:longint32;xlevel:single);
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   v                  :longint32;

begin

//range
if      (xlevel< 0.1) then xlevel:=0.1
else if (xlevel>10.0) then xlevel:=10.0
else if (xlevel= 1.0) then exit;//nothing to do

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

for sx:=0 to pred(sw) do
begin

//.r
v                     :=round( xlevel * sr[sx].r );
if (v>255) then v     :=255;
sr[sx].r              :=v;

//.g
v                     :=round( xlevel * sr[sx].g );
if (v>255) then v     :=255;
sr[sx].g              :=v;

//.b
v                     :=round( xlevel * sr[sx].b );
if (v>255) then v     :=255;
sr[sx].b              :=v;

end;//sx

end;//sy

end;

procedure tmakewallpaper.xfadeLR(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   xpert              :single;

begin

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

case xmode of

0:begin//left (black) -> right (color)

   for sx:=0 to pred(sw) do
   begin

   xpert              :=(sx / sw) * 2;

   if      (xpert>1) then xpert:=1
   else if (xpert<0.25) then xpert:=0.25;

   sr[sx].r           :=round( sr[sx].r * xpert );
   sr[sx].g           :=round( sr[sx].g * xpert );
   sr[sx].b           :=round( sr[sx].b * xpert );

   end;//sx

   end;

1:begin//left (black) -> right (color)

   for sx:=0 to pred(sw) do
   begin

   xpert              :=(sx / sw);

   sr[sx].r           :=round( sr[sx].r * xpert );
   sr[sx].g           :=round( sr[sx].g * xpert );
   sr[sx].b           :=round( sr[sx].b * xpert );

   end;//sx

   end;

2:begin//left (color) -> right (black)

   for sx:=0 to pred(sw) do
   begin

   xpert              :=(( pred(sw) - sx ) / sw) * 2;

   if      (xpert>1) then xpert:=1
   else if (xpert<0.25) then xpert:=0.25;

   sr[sx].r           :=round( sr[sx].r * xpert );
   sr[sx].g           :=round( sr[sx].g * xpert );
   sr[sx].b           :=round( sr[sx].b * xpert );

   end;//sx

   end;

3:begin//left (color) -> right (black)

   for sx:=0 to pred(sw) do
   begin

   xpert              :=(( pred(sw) - sx ) / sw);

   sr[sx].r           :=round( sr[sx].r * xpert );
   sr[sx].g           :=round( sr[sx].g * xpert );
   sr[sx].b           :=round( sr[sx].b * xpert );

   end;//sx

   end;

end;//case

end;//sy

end;

procedure tmakewallpaper.xfadeTB(const s:tbasicimage;const sw,sh:longint32;const xmode:byte);
var
   sr                 :pcolorrow32;
   sy                 :longint32;
   sx                 :longint32;
   xpert              :single;

begin

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr) then exit;

case xmode of
0:xpert               :=(sy / sh) * 2;//top (black) -> bottom (color)
1:xpert               :=(sy / sh);//top (black) -> bottom (color)
2:xpert               :=(( pred(sh) - sy ) / sh) * 2;//top (color) -> bottom (black)
3:xpert               :=(( pred(sh) - sy ) / sh);//top (color) -> bottom (black)
end;//case

case xmode of

0,2:begin

   if      (xpert>1) then xpert:=1
   else if (xpert<0.25) then xpert:=0.25;

   end;

end;//case

for sx:=0 to pred(sw) do
begin

sr[sx].r           :=round( sr[sx].r * xpert );
sr[sx].g           :=round( sr[sx].g * xpert );
sr[sx].b           :=round( sr[sx].b * xpert );

end;//sx

end;//sy

end;

end.
