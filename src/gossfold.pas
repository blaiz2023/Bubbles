unit gossfold;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef WIN64}{$define 64bit}{$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d`3laz} {$undef laz} {$endif}
uses gossmake, gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps{$ifdef gamecore}, gossgame ,gamefiles{$endif};
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
//## Library.................. Virtual folder(s) and file viewer(s) for interactive archive support
//## Version.................. 1.00.4440 (+43)
//## Items.................... 19
//## Last Updated ............ 05sep2026, 02sep2026, 30aug2026, 30jul2026, 28jun2026, 25jun2026, 19jun2026, 16jun2026, 14jun2026, 13jun2026, 08jun2026, 07jun2026, 25may2026
//## Lines of Code............ 13,500+
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
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tfolderhub             | tbasicscroll      | 1.00.486  | 02sep2026   | Interactive list of folders of "tfolderbase" class - 30aug2026, 14jun2026, 06jun2026, 29may2026, 26may2026, 25may2026
//## | tfolderbase            | tbasicscroll      | 1.00.1011 | 14jun2026   | Folder base class -> high capacity file support - 06jun2026, 05jun2026, 29may2026, 26may2026, 25may2026
//## | tfolderhome            | tfolderbase       | 1.00.146  | 30jul2026   | Home folder -> root folder which lists other folders as sub-folders and optional system files (about/readme/license) - 14jun2026, 06jun2026, 29may2026, 26may2026
//## | tfoldertest            | tfolderbase       | 1.00.011  | 06jun2026   | Test folder - 29may2026
//## | tfolderarchive         | tfolderbase       | 1.00.025  | 30aug2026   | Archive folder -> contents based on "archivefiles.pas" unit - 06jun2026, 29may2026, 26may2026, 25may2026
//## | tfoldercursor          | tfolderbase       | 1.00.096  | 13jun2026   | Cursor folder - > contents dynamically generated by "tmakecursor" - 06jun2026, 29may2026, 26may2026, 25may2026
//## | tfolderwallpaper       | tfolderbase       | 1.00.070  | 02sep2026   | Wallpaper folder - > contents dynamically generated by "tmakewallpaper" - 06jun2026, 29may2026, 27may2026
//## | tfilehub               | tbasicscroll      | 1.00.252  | 14jun2026   | Interactive list of file viewers - 13jun2026, 06jun2026, 29may2026, 27may2026
//## | tfilebase              | tbasicscroll      | 1.00.224  | 06jun2026   | File base class -> generic content viewer - 05jun2026, 02jun2026, 29may2026, 27may2026
//## | tfileblank             | tfilebase         | 1.00.010  | 06jun2026   | Blank file viewer -> shown when current file format is not supported - 29may2026, 27may2026
//## | tfilefolder            | tfilebase         | 1.00.022  | 14jun2026   | Open folder / show all files GUI for easy folder access
//## | tfileimage             | tfilebase         | 1.00.050  | 14jun2026   | Image viewer - 06jun2026, 05jun2026, 02jun2026, 29may2026, 27may2026
//## | tfilecursorscheme      | tfilebase         | 1.00.335  | 30jul2026   | Cursor scheme / multi-cursor viewer - 28jun2026, 14jun2026, 13jun2026
//## | tfilesprite            | tfilebase         | 1.00.020  | 14jun2026   | Game sprite (pic8) image viewer - 06jun2026, 29may2026
//## | tfiletext              | tfilebase         | 1.00.030  | 06jun2026   | Text viewer - 29may2026, 27may2026
//## | tfilemidi              | tfilebase         | 1.00.380  | 06jun2026   | Midi player - 29may2026, 27may2026
//## | tmanagecursor          | tobject           | 1.00.521  | 06jun2026   | System cursor customisation support with undo/redo/reset options - 14may2026, 11may2026
//## | tmanagebackground      | tobject           | 1.00.621  | 06jun2026   | System Desktop Background (picture mode) customisation support with undo/redo and multi-monitor support - 14may2026
//## | tmanagedata            | tbasictoolbar     | 1.00.080  | 19jun2026   | Content manager toolbar -> handles cursors and images - 18jun2026, 06jun2026, 05jun2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


const

   //common consts used by this unit and others --------------------------------

   //make collection codes
   mk_test_PinkCursors                           =0;
   mk_test_RedCursors                            =1;
   mk_test_BlueCursors                           =2;
   mk_test_max                                   =2;


   //scroll delays
   sd_image                     =2;
   sd_imageAnimated             =sd_image * 2;
   sd_cursorScheme              =2;
   sd_cursorSchemeAnimated      =sd_cursorScheme * 2;
   sd_sprite                    =3;
   sd_text                      =10;
   sd_midi                      =2;
   sd_midiPlaying               =10;
   sd_other                     =2;


   //cursor files
   cf_install           =0;
   cf_alt               =1;
   cf_arrow             =2;
   cf_work              =3;
   cf_cross             =4;
   cf_ew                =5;
   cf_hand              =6;
   cf_help              =7;
   cf_txt               =8;//cf_text reserved for clipboard
   cf_move              =9;
   cf_nesw              =10;
   cf_no                =11;
   cf_ns                =12;
   cf_nwse              =13;
   cf_pen               =14;
   cf_person            =15;
   cf_pin               =16;
   cf_wait              =17;
   cf_max               =17;


   //com codes
   class_desktopwallpaper       :tguid                        ='{C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD}';//OK
   interface_desktopwallpaper                                 ='{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}';//OK


   //folder hub ----------------------------------------------------------------

   folderhub_folderlimit        =1000;



type

   tfolderhub         =class;
   tfolderbase        =class;
   tfolderhome        =class;
   tfoldertest        =class;
   tfolderarchive     =class;
   tfoldercursor      =class;
   tfolderwallpaper   =class;
   tfilehub           =class;
   tfilebase          =class;
   tfileblank         =class;
   tfilefolder        =class;
   tfilecursorScheme  =class;
   tfileimage         =class;
   tfilesprite        =class;
   tfiletext          =class;
   tfilemidi          =class;

   tmaskmode          =( mm_default ,mm_all ,mm_simple ,mm_custom ,mm_custom2 );
   tdatatype          =( dt_none ,dt_folder ,dt_text ,dt_cursor ,dt_image ,dt_sprite ,dt_midi ,dt_music ,dt_cursorScheme ,dt_wallpaper ,dt_binary );
   titemtype          =( it_file ,it_folder ,it_none );
   tsetmonitor        =( sm_one, sm_all );
   tsetcursor         =( sc_arrow ,sc_hand );
   tfilecopyformat    =( fc_copy ,fc_copyall ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal );


{IDesktopWallpaper}
   IDesktopWallpaper  =interface( IUnknown )

    [interface_desktopwallpaper]

    procedure SetWallpaper( monitorID:PWideChar; wallpaper:PWideChar ); safecall;
    function  GetWallpaper( monitorID:PWideChar ): PWideChar; safecall;
    function  GetMonitorDevicePathAt( monitorIndex:iauto ): PWideChar; safecall;
    function  GetMonitorDevicePathCount:iauto; safecall;
    function  GetMonitorRECT( monitorID:PWideChar ):twinrect; safecall;
    procedure SetBackgroundColor( color:COLORREF32 ); safecall;
    function  GetBackgroundColor:COLORREF32; safecall;
    procedure SetPosition( position:longint32 ); safecall;
    function  GetPosition:longint32; safecall;
    procedure SetSlideshow( items:pauto ); safecall;
    function  GetSlideshow:pauto; safecall;
    procedure SetSlideshowOptions( options:longint32; slideshowTick:iauto ); safecall;
    procedure GetSlideshowOptions( out options:longint32; out slideshowTick:iauto ); safecall;
    procedure AdvanceSlideShow( monitorID:PWideChar; direction:longint32 ); safecall;
    function  GetStatus:longint32; safecall;
    procedure Enable( enable:LongBool ); safecall;

   end;


{tfolderhub}
//11111111111111111111111
   tfolderhub=class(tbasicscroll)
   private

    flist                    :array[0..pred(folderhub_folderlimit)] of tfolderbase;
    fcount                   :longint32;
    ilocked                  :boolean;
    ifullcount               :longint64;
    itimer100                :longint64;
    itimer500                :longint64;
    isettingsREF             :string;
    istarted                 :boolean;

    itopbar                  :tbasictoolbar;
    itoplabel                :tbasictitle;
    ilist                    :tbasicmenu;
    ilistTab                 :string;
    imask                    :tbasicset;
    imaskbar                 :tbasictoolbar;

    ilasthome                :tfolderhome;
    ifinishdone              :boolean;
    iitemindex               :longint32;
    iitemindexREF            :longint32;
    ifilehub                 :tfilehub;//optional
    imustcode                :longint32;
    iautoscroll              :boolean;
    iautoscrolltime          :longint64;
    iautoscrollPaused        :boolean;
    irenderPaused            :boolean;

    ifullbytes               :longint64;
    ifullbytesDONE           :boolean;

    isubbytes                :longint64;

    //system files
    isysfile_about           :string;
    isysfile_aboutOK         :boolean;

    isysfile_readme          :string;
    isysfile_readmeOK        :boolean;

    isysfile_license         :string;
    isysfile_licenseOK       :boolean;

    procedure xupdatebuttons;
    procedure __onclick(sender:tobject);
    procedure xcmd(const xcode2:string);
    procedure xshowSysFile(const n:string);
    procedure xsyncFullbytes;
    procedure xresetFullbytes;

    //folder support procs
    function  folder__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    procedure folder__onclick(sender:tobject);
    procedure folder__ondbclick(sender:tobject);
    function  xhelpval(const x:string):string;
    function  xhelpval2(const x:string;const xfull:boolean):string;

   public

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean);                            override;
    procedure on__create;                                                                   virtual;
    procedure on__destroy;                                                                  virtual;
    destructor destroy;                                                                     override;
    procedure _ontimer(sender:tobject);                                                     override;

    //information
    function  subfolderCurrent                                          :tfolderbase;       virtual;//14jun2026
    function  folderCurrent                                             :tfolderbase;       virtual;
    function  folderCurrentOK(var x:tfolderbase)                        :boolean;           virtual;
    function  folderIndex                                               :longint32;         virtual;
    procedure setfolderIndex(const xindex:longint32);                                       virtual;
    function  folder(const xindex:longint)                              :tfolderbase;       virtual;
    property  foldercount                                               :longint32          read fcount;
    property  fullcount                                                 :longint64          read ifullcount;
    function  subcount                                                  :longint64;         virtual;
    property  fullbytes                                                 :longint64          read ifullbytes;//gradual
    property  subbytes                                                  :longint64          read isubbytes;
    function  folderSeeking                                             :boolean;           virtual;
    function  folderisempty                                             :boolean;           virtual;
    function  canopenfolder                                             :boolean;           virtual;
    procedure openfolder;                                                                   virtual;
    function  canopenhome                                               :boolean;           virtual;
    procedure openhome;                                                                     virtual;
    function  athome                                                    :boolean;           virtual;

    //system files
    property sysfile_about                                              :string             read isysfile_about;
    property sysfile_aboutOK                                            :boolean            read isysfile_aboutOK;

    property sysfile_readme                                             :string             read isysfile_readme;
    property sysfile_readmeOK                                           :boolean            read isysfile_readmeOK;

    property sysfile_license                                            :string             read isysfile_license;
    property sysfile_licenseOK                                          :boolean            read isysfile_licenseOK;

    //autoscroll
    function  autoscrollDelay                                           :longint32;         virtual;
    function  autoscroll                                                :boolean;           virtual;
    procedure setautoscroll(const x:boolean);                                               virtual;
    procedure noscroll;                                                                     virtual;
    procedure autoscrollNextFile;                                                           virtual;
    procedure autoscrollPause;                                                              virtual;
    procedure autoscrollUnpause;                                                            virtual;
    function  autoscrollPaused                                          :boolean;           virtual;

    //render
    procedure renderPause;                                                                  virtual;
    procedure renderUnpause;                                                                virtual;
    function  renderPaused                                              :boolean;           virtual;//13jun2026

    //filehub
    function  canfilehub                                                :boolean;           virtual;
    function  filehub                                                   :tfilehub;          virtual;//not guaranteed to be present - check before use
    procedure setfilehub(const x:tfilehub);                                                 virtual;

    //settings
    function  settings                                                  :string;            virtual;
    procedure setsettings(const x:string);                                                  virtual;
    function  settingsFilename                                          :string;
    procedure loadsettings;
    procedure savesettings;
    procedure autosavesettings;

    //new
    function  nhome                                                     :tfolderhome;
    function  ntest      (const xname:string)                           :tfoldertest;
    function  narchive   (const xname:string)                           :tfolderarchive;
    function  ncursors   (const xclass:tcursorclass;const xname:string) :tfoldercursor;
    function  nwallpapers(const xname:string;const xtepColor:longint32;const wemList:string):tfolderwallpaper;
    procedure nfinish;

    //new -> cursors
    procedure ncursorsCustomColor(const clist:array of tcursorclass);//25jun2026
    procedure ncursorsRainbow(const clist:array of tcursorclass);
    procedure ncursorsMixed(const clist:array of tcursorclass);
    procedure ncursorsRed(const clist:array of tcursorclass);
    procedure ncursorsGreen(const clist:array of tcursorclass);
    procedure ncursorsBlue(const clist:array of tcursorclass);
    procedure ncursorsYellow(const clist:array of tcursorclass);
    procedure ncursorsBrown(const clist:array of tcursorclass);
    procedure ncursorsGrey(const clist:array of tcursorclass);
    procedure ncursorsPink(const clist:array of tcursorclass);
    procedure ncursorsCustom0(const clist:array of tcursorclass;const cc_from:longint32);
    procedure ncursorsCustom(const clist:array of tcursorclass;const cc_from,cc_to:longint32);

    //new -> wallpapers
    procedure nwallpapersAll(const xname:string);


    //start -> call after all "folders" have been created
    procedure start(const xIncludeSysFiles:boolean);

    //io
    function  cansubfileid(const xsubFileID:longint32)                                                          :boolean;//generic -> fast
    function  cansubfile(const xsubFileID:longint32)                                                            :boolean;//file specific -> slower
    function  filename(const xsubFileID:longint32)                                                              :string;
    function  filesize(const xsubFileID:longint32)                                                              :longint32;//14jun2026
    function  filesize2(const xsubFileID:longint32;var xisApproximate:boolean)                                  :longint32;
    function  itemtype(const xsubFileID:longint32)                                                              :titemtype;
    function  isfile  (const xsubFileID:longint32)                                                              :boolean;
    function  isfolder(const xsubFileID:longint32)                                                              :boolean;
    function  fromfile(const xsubFileID:longint32;const xdata:tstr8)                                            :boolean;
    function  toanimation(const xwantSize,xsubFileID:longint32;const ximage:tcommonimage)                                 :boolean;
    function  toanimationinfo(const xwantSize,xsubFileID:longint32;var x:tanimationinfo)                                  :boolean;
    function  toanimationcell(const xwantSize,xsubFileID:longint32;const xcellindex:longint32;const ximage:tcommonimage)  :boolean;

    //nextfile
    function cannextFile:boolean;                                                           virtual;
    procedure nextFile;                                                                     virtual;

    //prevfile
    function canprevFile:boolean;                                                           virtual;
    procedure prevFile;                                                                     virtual;

    //mustcode
    procedure setmustcode(const xcode:longint32);                                           virtual;

    //misc
    function mustshowfolder(const xreset:boolean)                       :boolean;           virtual;

    //support procs
    function archivefiles__fileexists(const xfilename:string)           :boolean;
    function archivefiles__fromfile(const xfilename:string;var xdata:string):boolean;
    function xnewslot(const x:tfolderbase):longint32;

   end;


{tfakeset}
//333333333333333333333333
   tfakeset=class(tobject)
   private

    icount            :longint32;
    iobj              :tbasicset;
    idef              :longint32;
    ival              :longint32;

    icaps             :array[0..31] of string;
    inams             :array[0..31] of string;
    ihlps             :array[0..31] of string;
    ivisb             :array[0..31] of boolean;

    ivisible          :boolean;

    procedure xsynccount;
    procedure setobj(x:tbasicset);
    function  getcaps(xindex:longint):string;
    procedure setcaps(xindex:longint;xval:string);
    function  getnams(xindex:longint):string;
    procedure setnams(xindex:longint;xval:string);
    function  getvisb(xindex:longint):boolean;//31jul2021
    procedure setvisb(xindex:longint;xval:boolean);
    function  getvals(xindex:longint32):boolean;
    procedure setvals(xindex:longint32;xval:boolean);
    procedure ysetval(xval:longint32);
    function  ygetval:longint32;
    procedure setval(xval:longint);
    procedure setvisible(x:boolean);
    function  getvisible:boolean;

    property yval                         :longint32                         read ygetval                  write ysetval;

   public


    //create
    constructor create; virtual;
    destructor destroy; override;

    //information
    property caps[xindex:longint32]       :string                            read getcaps                  write setcaps;
    property nams[xindex:longint32]       :string                            read getnams                  write setnams;
    property visb[xindex:longint32]       :boolean                           read getvisb                  write setvisb;

    property count                        :longint32                         read icount;
    property vals[xindex:longint]         :boolean                           read getvals                  write setvals;
    property val                          :longint32                         read ygetval                  write setval;
    property obj                          :tbasicset                         read iobj                     write setobj;
    property visible                      :boolean                           read getvisible               write setvisible;
    function focused                      :boolean;

    //workers
    procedure xset3(xindex:longint;xcap,xnam,xhlp:string;xval:boolean);
    procedure xset(xindex:longint;xcap,xnam,xhlp:string;xval:boolean);
    procedure setparams(xdef,xval:longint);
    procedure setparams2(xdef,xval,xitemsperline:longint);

   end;

{tfakemenu}
//333333333333333333333333
   tfakemenu=class(tobject)
   private

    imenu             :tbasicmenu;//pointer only
    icountx           :longint32;
    iitemindex        :longint32;
    ipos              :longint32;

    procedure setmenu(x:tbasicmenu);
    function  getcountx:longint32;
    procedure setcountx(x:longint32);
    function  getitemindex:longint32;
    procedure setitemindex(x:longint32);
    function  getpos:longint32;
    procedure setpos(x:longint32);

   public

    //create
    constructor create;
    destructor  destroy;                                                                                   override;

    //information
    property menu                         :tbasicmenu                        read imenu                    write setmenu;
    property countx                       :longint32                         read getcountx                write setcountx;
    property count                        :longint32                         read getcountx                write setcountx;
    property itemindex                    :longint32                         read getitemindex             write setitemindex;
    property pos                          :longint32                         read getpos                   write setpos;

    //procs
    procedure paintnow;

   end;


{tfolderbase}
   tfolderbase=class(tobject)
   private

    imade             :boolean;
    ihubslot          :longint32;
    ishowing          :boolean;

    iid               :longint32;
    icode             :longint32;
    iname             :string;
    isubfolder        :string;
    ifullcount        :longint32;
    isubcount         :longint32;

    //.gui support
    ilist             :tfakemenu;//pointer only -> set/unset in on__activate/on__unactivate
    imask             :tfakeset;
    imaskbar          :tbasictoolbar;

    //.gradual "overal data bytes" for the folder -> all the files in the folder, visible or not
    ifullbytes        :longint64;
    ifullbytespos     :longint32;
    ifullbytesDONE    :boolean;

    isubbytes         :longint64;

    itep              :longint32;
    icolor            :longint32;
    ilocked           :boolean;
    ifolderhub        :tfolderhub;//pointer only
    iupdateDoneFirst  :boolean;

    imaskmode         :tmaskmode;
    ilastmaskmode     :longint32;
    imaskCustom       :string;
    imaskCustom2      :string;
    imaskREF          :string;
    imaskDefault      :string;

    ilistval1         :array[0..longint32(high(tmaskmode))] of longint32;//item.index
    ilistval2         :array[0..longint32(high(tmaskmode))] of longint32;//item.vpos

    imasksimpleOK     :boolean;

    itimer500X        :longint64;
    isettingsREF      :string;

    isublist          :tdynamicinteger;

    procedure xfillWithMask;                                                                virtual;
    procedure xupdatebuttons;                                                               virtual;
    function  xsubTOfull(const xindex:longint32):longint32;
    procedure xmasksimple__setListOfFileExtensions(xmask:string);
    procedure newID;                                                                        virtual;
    function  xmustResetFullBytes                                       :boolean;           virtual;
    procedure xresetFullbytes;                                                              virtual;
    procedure xincFullbytes;                                                                virtual;
    procedure xsyncSubbytes;                                                                virtual;

   public

    //user filename override -> for "save a file to disk" with files that have subfiles that need auto-renaming and any content alteration on-the-fly - 18jun2026
    ouserfilename                                                       :string;

    //create
    constructor create(const xfolderhub:tfolderhub;const xname:string;const xoptionalcode:longint32);        virtual;
    procedure on__create;                                                                                    virtual;
    function  on__cmd(const xcode2:string)                              :boolean;                            virtual;
    procedure on__roottimer;
    procedure on__timer;                                                                                     virtual;
    procedure on__show(const xlist:tbasicmenu;const xmask:tbasicset;const xmaskbar:tbasictoolbar);
    procedure on__unshow;
    procedure on__destroy;                                                                                   virtual;
    destructor destroy;                                                                                      override;

    //makers
    procedure make(const xfullcount,xtep,xcolor:longint32;const xmaskDefault,xmaskSimple:string); virtual;

    //information
    property  hubslot                                                   :longint32          read ihubslot;
    property  made                                                      :boolean            read imade;
    property  code                                                      :longint32          read icode;//20jun2026
    property  id                                                        :longint32          read iid;
    property  name                                                      :string             read iname;
    property  subfolder                                                 :string             read isubfolder;//based on name e.g. "name\" when name is not "nil"
    property  tep                                                       :longint32          read itep;
    property  color                                                     :longint32          read icolor;
    property  fullbytes                                                 :longint64          read ifullbytes;//gradual
    property  fullbytesDONE                                             :boolean            read ifullbytesDONE;
    property  fullcount                                                 :longint32          read ifullcount;
    property  subbytes                                                  :longint64          read isubbytes;
    property  subcount                                                  :longint32          read isubcount;
    property  folderhub                                                 :tfolderhub         read ifolderhub;
    function  empty                                                     :boolean;           virtual;
    property  showing                                                   :boolean            read ishowing;
    
    //settings
    function  settings                                                   :string;           virtual;
    procedure setsettings(const x:string);                                                  virtual;
    function  settingsFilename                                           :string;
    procedure loadsettings;
    procedure savesettings;
    procedure autosavesettings;

    //lock -> disable selection modified/mask updates
    function  canlock:boolean;
    procedure lock;
    procedure unlock;

    //mask
    function  mask                                                      :string;            virtual;
    function  maskmode                                                  :tmaskmode;
    procedure setmaskmode(const xmaskmode:tmaskmode;const xforce:boolean);
    procedure bringReady(const xforce:boolean);                                             virtual;

    //file
    function  cansubfileID(const xsubfileID:longint32)                                      :boolean;
    function  cansubfile(const xsubFileID:longint32)                                        :boolean;//18jun2026 - file specific testing
    function  findindex(const xsubindex,xsubfileID:longint32;var dfullindex:longint32)      :boolean;
    function  havefile (const n:string)                                                     :boolean;
    function  findfile (const n:string;var xsubindex:longint32)                             :boolean;
    function  filename (const xsubindex,xsubfileID:longint32)                               :string;
    function  fileext  (const xsubindex,xsubfileID:longint32)                               :string;
    function  filesize (const xsubindex,xsubfileID:longint32)                               :longint32;
    function  filesize2(const xsubindex,xsubfileID:longint32;var xisApproximate:boolean)    :longint32;
    function  filetep  (const xsubindex,xsubfileID:longint32)                               :longint32;
    function  filecolor(const xsubindex,xsubfileID:longint32)                               :longint32;
    function  filetext (const xsubindex,xsubfileID:longint32)                               :string;
    function  fromfile (const xsubindex,xsubfileID:longint32;const xdata:tstr8)             :boolean;
    function  savefile (const dsubindex:longint32;const dfilename:string;var wbytes:longint32):boolean;
    function  datatype (const xsubindex,xsubfileID:longint32)                               :tdatatype;//dt_code
    function  itemtype (const xsubindex,xsubfileID:longint32)                               :titemtype;//it_code
    function  isfile   (const xsubindex,xsubfileID:longint32)                               :boolean;
    function  isfolder (const xsubindex,xsubfileID:longint32)                               :boolean;
    function  folderindex(const xsubindex,xsubfileID:longint)                               :longint32;
    function  toanimation(const xwantSize,xsubindex,xsubfileID:longint32;const ximage:tcommonimage)   :boolean;//13jun2026
    function  toanimationinfo(const xwantSize,xsubindex,xsubFileID:longint32;var x:tanimationinfo):boolean;
    function  toanimationcell(const xwantSize,xsubindex,xsubFileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean;

    //itemindex
    function  itemindex                                                                     :longint32;
    procedure setitemindex(const xsubindex:longint32);

    //core file functions -> not restricted by mask -> full file range
    function  full__cansubfileID(const xsubfileID:longint32)                                                                     :boolean;     virtual;
    function  full__findindex(const xindex,xsubfileID:longint32;var dfullindex:longint32)                                        :boolean;     virtual;
    function  full__havefile (const n:string)                                                                                    :boolean;     virtual;
    function  full__findfile (const n:string;var xindex:longint32)                                                               :boolean;     virtual;
    function  full__filename (const xindex,xsubfileID:longint32)                                                                 :string;      virtual;
    function  full__filesize (const xindex,xsubfileID:longint32)                                                                 :longint32;   virtual;
    function  full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean)                                      :longint32;   virtual;
    function  full__fileext  (const xindex,xsubfileID:longint32)                                                                 :string;      virtual;
    function  full__filetep  (const xindex,xsubfileID:longint32)                                                                 :longint32;   virtual;
    function  full__filecolor(const xindex,xsubfileID:longint32)                                                                 :longint32;   virtual;
    function  full__filetext (const xindex,xsubfileID:longint32)                                                                 :string;      virtual;
    function  full__fromfile (const xindex,xsubfileID:longint32;const xdata:tstr8)                                               :boolean;     virtual;
    function  full__savefile (const dindex:longint32;const dfilename:string;var wbytes:longint32)                                :boolean;     virtual;
    function  full__datatype (const xindex,xsubfileID:longint32)                                                                 :tdatatype;   virtual;
    function  full__itemtype (const xindex,xsubfileID:longint32)                                                                 :titemtype;   virtual;
    function  full__isfile   (const xindex,xsubfileID:longint32)                                                                 :boolean;     virtual;
    function  full__isfolder (const xindex,xsubfileID:longint32)                                                                 :boolean;     virtual;
    function  full__folderindex(const xindex,xsubfileID:longint)                                                                 :longint32;   virtual;
    function  full__toanimation(const xwantSize,xindex,xsubfileID:longint32;const ximage:tcommonimage)                                     :boolean;     virtual;
    function  full__toanimationinfo(const xwantSize,xindex,xsubfileID:longint32;var x:tanimationinfo)                                      :boolean;     virtual;
    function  full__toanimationcell(const xwantSize,xindex,xsubfileID:longint32;const xcellindex:longint32;const ximage:tcommonimage)      :boolean;     virtual;

    //next
    function  cannextfile                                                                   :boolean;          virtual;
    procedure nextfile;                                                                                        virtual;

    //prev
    function  canprevfile                                                                   :boolean;          virtual;
    procedure prevfile;                                                                                        virtual;

    //sub-folder support
    function  canopenfolder                                                                  :boolean;         virtual;
    procedure openfolder;                                                                                      virtual;

    //support procs
    procedure xfolder__ondbclick(sender:tobject);
    procedure xfolder__onclick(sender:tobject);
    function  xfolder__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    procedure xcmd(const xcode2:string);                                                    virtual;

   end;


{tbasichome}
   tfolderhomeitem=record

    name              :string;
    size              :longint32;
    tep               :longint32;
    color             :longint32;
    data              :string;
    folder            :tfolderbase;
    folderIndex       :longint32;

    end;

   tfolderhome=class(tfolderbase)
   private

    fcount            :longint32;
    flist             :array[0..(folderhub_folderlimit+10)] of tfolderhomeitem;
    ihub              :tfolderhub;

   public

    //create
    procedure on__create;                                                                   override;
    function  on__cmd(const xcode2:string)                               :boolean;          override;
    procedure finish(const xhub:tfolderhub);                                                virtual;

    //sub-folder support
    function  canopenfolder                                                                  :boolean;         override;
    procedure openfolder;                                                                                      override;

    //core file functions -> not restricted by mask -> full file range
    function  full__filename (const xindex,xsubfileID:longint32)                            :string;           override;
    function  full__filesize (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean) :longint32;        override;
    function  full__filetep  (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filecolor(const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__fromfile (const xindex,xsubfileID:longint32;const xdata:tstr8)          :boolean;          override;
    function  full__itemtype (const xindex,xsubfileID:longint)                              :titemtype;        override;
    function  full__folderindex(const xindex,xsubfileID:longint)                            :longint32;        override;

   end;


{tfoldertest}
   tfoldertest=class(tfolderbase)
   private

   public

    //create
    procedure on__create;                                                                   override;

    //core file functions -> not restricted by mask -> full file range
    function  full__filename (const xindex,xsubfileID:longint32)                            :string;           override;
    function  full__filesize (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filetep  (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filecolor(const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__fromfile (const xindex,xsubfileID:longint32;const xdata:tstr8)          :boolean;          override;

   end;


{tbasicarchive}
   tfolderarchive=class(tfolderbase)
   private

   public

    //create
    procedure on__create;                                                                   override;

    //core file functions -> not restricted by mask -> full file range
    function  full__filename (const xindex,xsubfileID:longint32)                            :string;           override;
    function  full__filesize (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filesize2(const xsubindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;      override;
    function  full__filetep  (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filecolor(const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__fromfile (const xindex,xsubfileID:longint32;const xdata:tstr8)          :boolean;          override;

   end;


{tfoldercursor}
//5555555555555555555555555555555//xxxxxxxxxxxxxxxxxxxxxxx

   tfoldercursor=class(tfolderbase)
   private

    icore             :tmakecursor;
    icursorclass      :tcursorclass;
    iclassname        :string;
    ilast_usepng      :boolean;

   public

    //create
    procedure on__create;                                                                                      override;
    procedure on__destroy;                                                                                     override;
    function  xmustResetFullBytes                                                           :boolean;          override;

    //information
    property  cursorclass                                                                   :tcursorclass      read icursorclass;
    property  classname                                                                     :string            read iclassname;

    //makers
    procedure nmake(cc_index,ca_index,ct_index,xtepcolor:longint32);
    procedure nfinish;

    //core file functions -> not restricted by mask -> full file range
    function  full__cansubFileID(const xsubfileID:longint32)                                :boolean;          override;
    function  full__findindex(const xindex,xsubfileID:longint32;var dfullindex:longint32)   :boolean;          override;
    function  full__filename (const xindex,xsubfileID:longint32)                            :string;           override;
    function  full__filesize (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean) :longint32;        override;
    function  full__filetep  (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filecolor(const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__fromfile (const xindex,xsubfileID:longint32;const xdata:tstr8)          :boolean;          override;
    function  full__toanimation(const xwantSize,xindex,xsubfileID:longint32;const ximage:tcommonimage):boolean;          override;
    function  full__toanimationinfo(const xwantSize,xindex,xsubfileID:longint32;var x:tanimationinfo)        :boolean;          override;
    function  full__toanimationcell(const xwantSize,xindex,xsubfileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean; override;

    //test procs
    procedure test__mapping;//13jun2026

   end;


{tfolderwallpaper}
//9999999999999999999999999999999999999999999999
   tfolderwallpaper=class(tfolderbase)
   private

    icore             :tmakewallpaper;
    iclassname        :string;

   public

    //create
    procedure on__create;                                                                   override;
    procedure on__destroy;                                                                  override;

    //information
    property  classname                                                                     :string            read iclassname;

    //makelist
    procedure makelist(const xtepColor:longint32;const wemList:string);

    //core file functions -> not restricted by mask -> full file range
    function  full__datatype(const xindex,xsubfileID:longint32)                             :tdatatype;        override;//04sep2026
    function  full__cansubFileID(const xsubfileID:longint32)                                :boolean;          override;
    function  full__findindex(const xindex,xsubfileID:longint32;var dfullindex:longint32)   :boolean;          override;
    function  full__filename (const xindex,xsubfileID:longint32)                            :string;           override;
    function  full__filesize (const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean) :longint32;        override;
    function  full__filecolor(const xindex,xsubfileID:longint32)                            :longint32;        override;
    function  full__fromfile (const xindex,xsubfileID:longint32;const xdata:tstr8)          :boolean;          override;

   end;


{tfilehub}
   tfilehub=class(tbasicscroll)
   private

    //core
    flist                    :array[0..199] of tfilebase;
    fcount                   :longint32;

    itimer100                :longint64;
    itimer500                :longint64;
    istarted                 :boolean;
    isettingsREF             :string;
    ilastfilename            :string;
    ifirstload               :boolean;
    ilastref                 :string;
    ifolderhub               :tfolderhub;//pointer only
    imasterplaying           :boolean;
    fonsync                  :tnotifyevent;
    iwallpaper_changeId      :longint32;
    
    procedure xupdatebuttons;
    procedure __onclick(sender:tobject);
    procedure xcmd(const xcode2:string);
    function  xaddfile(const x:tfilebase):boolean;
    function  xpagename(const xindex:longint32):string;

   public

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean);                            override;
    procedure on__create;                                                                   virtual;
    procedure on__destroy;                                                                  virtual;
    destructor destroy;                                                                     override;
    procedure _ontimer(sender:tobject);                                                     override;

    //file handlers
    property  firstload                                                 :boolean            read ifirstload;
    function  fileIndex                                                 :longint32;
    procedure setfileIndex(const xindex:longint32);
    function  fileCurrent                                               :tfilebase;
    function  files(const xindex:longint)                               :tfilebase;
    property  filecount                                                 :longint32          read fcount;
    property  onsync                                                    :tnotifyevent       read fonsync               write fonsync;

    //folderhub
    function  canfolderhub                                              :boolean;           virtual;
    function  folderhub                                                 :tfolderhub;        virtual;//not guaranteed to be present - check before use
    procedure setfolderhub(const x:tfolderhub);                                             virtual;
    function  folderisempty                                             :boolean;           virtual;
    function  canopenfolder                                             :boolean;           virtual;
    procedure openfolder;                                                                   virtual;
    function  canopenhome                                               :boolean;           virtual;
    procedure openhome;                                                                     virtual;

    //settings
    function  settings                                                  :string;            virtual;
    procedure setsettings(const x:string);                                                  virtual;
    function  settingsFilename                                          :string;
    procedure loadsettings;
    procedure savesettings;
    procedure autosavesettings;

    //new
    function  nblank (const xname:string)                               :tfileblank;
    function  nfolder(const xname:string)                               :tfilefolder;
    function  ncursorScheme(const xname:string)                         :tfilecursorScheme;//13jun2026
    function  nimage (const xname:string)                               :tfileimage;
    function  nsprite(const xname:string)                               :tfilesprite;
    function  ntext  (const xname:string)                               :tfiletext;
    function  nmidi  (const xname:string)                               :tfilemidi;

    //start -> call after all "viewers" (nimage etc) have been created
    procedure start(const xhub:tfolderhub);

    //current file
    function issysfile   (const xsubFileID:longint32)                                                         :boolean;           virtual;
    function fileext     (const xsubFileID:longint32)                                                         :string;            virtual;
    function datatype    (const xsubFileID:longint32)                                                         :tdatatype;         virtual;
    function itemtype    (const xsubFileID:longint32)                                                         :titemtype;         virtual;
    function filename    (const xsubFileID:longint32)                                                         :string;            virtual;
    function filesize    (const xsubFileID:longint32)                                                         :longint32;         virtual;
    function canfromfile (const xsubFileID:longint32)                                                         :boolean;           virtual;
    function fromfile    (const xsubFileID:longint32;const xdata:tstr8)                                       :boolean;           virtual;
    function toanimation (const xwantSize,xsubFileID:longint32;const ximage:tcommonimage)                               :boolean; virtual;
    function toanimationinfo(const xwantSize,xsubFileID:longint32;var x:tanimationinfo)                                 :boolean; virtual;
    function toanimationcell(const xwantSize,xsubFileID:longint32;const xcellindex:longint32;const ximage:tcommonimage) :boolean; virtual;

    //load current file only once -> uses folderhub.foldercurrent.itemindex
    procedure loadfileonce;

    //stop
    procedure stop;                                                                         virtual;

    //play
    procedure play;                                                                         virtual;
    procedure playToggle;                                                                   virtual;
    function  playing                                                    :boolean;          virtual;

    //masterplaying -> persists over multiple file types
    procedure setmasterplaying(const x:boolean);                                            virtual;
    function masterplaying                                               :boolean;          virtual;

    //next
    function  cannextfile                                                :boolean;          virtual;
    procedure nextfile;                                                                     virtual;

    //prev
    function  canprevfile                                                :boolean;          virtual;
    procedure prevfile;                                                                     virtual;

    //copy
    function  supcopyformat(const xformat:tfilecopyformat)               :boolean;          virtual;
    function  cancopyformat(const xformat:tfilecopyformat)               :boolean;          virtual;
    procedure copyformat(const xformat:tfilecopyformat);                                    virtual;

    //fetchers
    function fetchImage(var x:tcommonimage)                              :boolean;          virtual;
    function fetchImageView(var x:tbasicimgview)                         :boolean;          virtual;
    function fetchTextBox(var x:tbasicbwp)                               :boolean;          virtual;

   end;


{tfilebase}
   tfilebase=class(tbasicscroll)
   private

    imade             :boolean;
    iname             :string;
    idatatype         :tdatatype;//dt_code
    iitemtype         :titemtype;//it_code
    ifileext          :string;
    ifilename         :string;
    itimer500X        :longint64;
    isettingsREF      :string;
    ifirstload        :boolean;
    iloaded           :boolean;
    iwasloaded        :boolean;
    idata             :tstr8;
    ifilehub          :tfilehub;//pointer only
    ilaststopped      :boolean;
    ilastplaying      :boolean;

    procedure xcmd(const xcode2:string);                                                    virtual;
    procedure xupdatebuttons;                                                               virtual;
    procedure x__onclick(sender:tobject);                                                   virtual;
    procedure xlist__onclick(sender:tobject);                                               virtual;
    procedure xlist__ondbclick(sender:tobject);                                             virtual;
    procedure x__onmustcode(sender:tobject;const xmustcode:longint32);                      virtual;

   public

    //options
    oturbo                                                              :boolean;

    //create
    constructor create(xparent:tobject;const xname:string);                                 virtual;
    constructor create2(xparent:tobject;xscroll,xstart:boolean;const xname:string);         virtual;
    procedure on__create;                                                                   virtual;
    function  on__cmd(const xcode2:string)                              :boolean;           virtual;
    procedure on__timer;                                                                    virtual;
    function  on__notify(sender:tobject)                                :boolean;           virtual;
    procedure on__updatebuttons;                                                            virtual;
    procedure on__destroy;                                                                  virtual;
    destructor destroy;                                                                     override;
    procedure _ontimer(sender:tobject);                                                     override;

    //information
    property filehub                                                    :tfilehub           read ifilehub;
    property loaded                                                     :boolean            read iloaded;
    property wasloaded                                                  :boolean            read iwasloaded;
    property fileext                                                    :string             read ifileext;
    property data                                                       :tstr8              read idata;
    function subdata(const xreturnFileContents:boolean)                 :tstr8;             virtual;
    function subdataExt                                                 :string;            virtual;

    //settings
    function  settings                                                  :string;            virtual;
    procedure setsettings(const x:string);                                                  virtual;
    function  settingsFilename                                          :string;
    procedure loadsettings;
    procedure savesettings;
    procedure autosavesettings;
    function  on__settings(const xindex:longint;var dname,dvalue:string):boolean;           virtual;
    procedure on__setsettings(const x:tvars8);                                              virtual;

    //load / unload
    function  datatype                                                  :tdatatype;         virtual;
    function  itemtype                                                  :titemtype;         virtual;
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           virtual;
    function  canloadFileext (const lext:string)                        :boolean;           virtual;

    function  canload                                                   :boolean;           virtual;
    procedure load;                                                                         virtual;
    procedure on__load;                                                                     virtual;

    function  canunload                                                 :boolean;           virtual;
    procedure unload;                                                                       virtual;
    procedure on__unload;                                                                   virtual;

    //make
    procedure make(const xfilehub:tfilehub);

    //stop
    function  canstop                                                   :boolean;           virtual;
    procedure stop;                                                                         virtual;
    procedure stop2(const xsyncMaster:boolean);                                             virtual;
    function  wasstopped                                                :boolean;           virtual;
    procedure on__stop;                                                                     virtual;

    //playpos
    function  playpos                                                   :longint32;         virtual;
    procedure setplaypos(const xnewpos:longint32);
    function  playlen                                                   :longint32;         virtual;

    //play
    function  canplay                                                   :boolean;           virtual;
    procedure play;                                                                         virtual;
    procedure playToggle;                                                                   virtual;
    function  playing                                                   :boolean;           virtual;
    function  wasplaying                                                :boolean;           virtual;
    procedure on__play;                                                                     virtual;

    //copy
    function  supcopyformat(const xformat:tfilecopyformat)              :boolean;           virtual;
    function  cancopyformat(const xformat:tfilecopyformat)              :boolean;           virtual;
    procedure copyformat(const xformat:tfilecopyformat);                                    virtual;

    //object fetchers
    function fetchImage(var x:tcommonimage)                             :boolean;           virtual;
    function fetchImageView(var x:tbasicimgview)                        :boolean;           virtual;
    function fetchTextBox(var x:tbasicbwp)                              :boolean;           virtual;

    //other
    function  animated                                                  :boolean;           virtual;

   end;


{tfileblank}
   tfileblank=class(tfilebase)
   private

   public

    function  on__notify(sender:tobject)                                :boolean;           override;
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;
    procedure load;                                                                         override;
    procedure unload;                                                                       override;

   end;

   
//xxxxxxxxxxxxxxxxxxxxxxx//6666666666666666666
{tfilefolder}
   tfilefolder=class(tfilebase)
   private

    ibar                     :tbasictoolbar;
    itimer500                :longint64;

    procedure xupdatebuttons;

   public

    procedure on__create;                                                                   override;
    procedure on__load;                                                                     override;
    procedure on__timer;                                                                    override;
    function  on__cmd(const xcode2:string)                              :boolean;           override;
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;

   end;


{tfileimage}
//7777777777777777777777777777
   tfileimage=class(tfilebase)
   private

    itimer500                :longint64;
    iimage                   :tbasicimgview;
    ilastmode                :longint32;
    ilastREF                 :string;
    icursorpreviewREF        :string;

    procedure xcursorPreview;

   public

    //options
    opreviewCursor           :boolean;//default=false
    omanageCursor            :boolean;//default=true
    omanageBackground        :boolean;//default=true

    //create
    procedure on__create;                                                                   override;
    procedure on__destroy;                                                                  override;

    //load / unload
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;
    procedure on__load;                                                                     override;
    procedure on__unload;                                                                   override;
    procedure on__timer;                                                                    override;

    //copy
    function  supcopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    function  cancopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    procedure copyformat(const xformat:tfilecopyformat);                                    override;

    //fetcher
    function fetchImageView(var x:tbasicimgview)                        :boolean;           override;

    //other
    function  animated                                                  :boolean;           override;

   end;


{tfilecursorscheme}
//8888888888888888888888888888
   tfilecursorschemeimage=record

    ok                       :boolean;
    cfindex                  :longint32;
    painttimer               :longint64;
    filename                 :string[255];
    wantsize                 :longint32;
    changeid                 :longint32;
    info                     :tanimationinfo;
    itemindex                :longint32;
    cachedcells              :tcommonimage;
    iscached                 :array[ 0..pred(cursor_celllimit) ] of boolean;
    area                     :twinrect;

    end;

   tfilecursorscheme=class(tfilebase)
   private

    icell                    :tcommonimage;
    itimer500                :longint64;
    ilastmode                :longint32;
    ilastREF                 :string;
    icursorpreviewREF        :string;
    iscreen                  :tbasiccontrol;
    ilist                    :array[0..pred(cf_max)] of tfilecursorschemeimage;
    ianmimated               :boolean;
    ihoverindex              :longint32;
    iitemindex               :longint32;
    ileftclickX              :longint32;
    irightclickX             :longint32;
    icolumncount             :longint32;//set via paint proc
    isubdata                 :tstr8;

    procedure xcursorPreview;
    function  on__notify(sender:tobject):boolean;
    procedure on__screenpaint(sender:tobject);
    procedure setitemindex(x:longint32);
    procedure sethoverindex(x:longint32);
    function findindex(const sx,sy:longint32):longint32;

   public

    //options
    opreviewCursor           :boolean;//default=false
    omanageCursor            :boolean;//default=true
    omanageBackground        :boolean;//default=true
    osmooth                  :boolean;//default=true=high cpu

    //create
    procedure on__create;                                                                   override;
    procedure on__destroy;                                                                  override;

    //load / unload
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;
    procedure on__load;                                                                     override;
    procedure on__unload;                                                                   override;
    procedure on__timer;                                                                    override;

    //information
    property  itemindex                                                 :longint32          read iitemindex     write setitemindex;
    property  hoverindex                                                :longint32          read ihoverindex;
    function subdata(const xreturnFileContents:boolean)                 :tstr8;             override;
    function subdataExt                                                 :string;            override;

    //copy
    function  supcopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    function  cancopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    procedure copyformat(const xformat:tfilecopyformat);                                    override;

    //other
    function  animated                                                  :boolean;           override;

   end;


{tfiletext}
   tfiletext=class(tfilebase)
   private

    itext                   :tbasicbwp;
    ivars                   :tfastvars;
    inameref                :string;

    procedure xstorepos;

   public

    //create
    procedure on__create;                                                                   override;
    procedure on__destroy;                                                                  override;

    //load / unload
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;
    procedure on__load;                                                                     override;
    procedure on__unload;                                                                   override;

    //copy
    function  supcopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    function  cancopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    procedure copyformat(const xformat:tfilecopyformat);                                    override;

    //fetcher
    function fetchTextBox(var x:tbasicbwp)                              :boolean;           override;

   end;


{tfilemidi}
   tfilemidi=class(tfilebase)
   private

    ilastfilename            :string;
    ifastTimer               :longint64;
    itimer100                :longint64;
    itimer250                :longint64;
    ilist                    :tbasicmenu;
    ivol                     :tsimpleint;
    ispeed                   :tsimpleint;
    idevice                  :tbasicsel;
    iLastTimeRef             :longint64;
    ibeatval                 :double;
    ibeatvalBass             :double;
    ijump                    :tbasicjump;
    inewdata                 :boolean;
    ilastflash               :boolean;

    function xlist__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    procedure xbeatFlash;
    procedure xsyncInfo;

   public

    //create
    procedure on__create;                                                                   override;
    procedure on__destroy;                                                                  override;
    procedure on__timer;                                                                    override;
    function  on__cmd(const xcode2:string)                              :boolean;           override;
    procedure on__updatebuttons;                                                            override;

    //information
    function tracks                                                     :longint32;         virtual;

    //settings
    function  on__settings(const xindex:longint;var dname,dvalue:string):boolean;           override;
    procedure on__setsettings(const x:tvars8);                                              override;

    //load / unload
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;
    procedure on__load;                                                                     override;
    procedure on__unload;                                                                   override;

    //stop
    function  canstop                                                   :boolean;           override;
    procedure on__stop;                                                                     override;

    //playpos
    function  playpos                                                   :longint32;         override;
    procedure setplaypos(const xnewpos:longint32);
    function  playlen                                                   :longint32;         override;

    //play
    function  canplay                                                   :boolean;           override;
    procedure on__play;                                                                     override;
    function  playing                                                   :boolean;           override;

   end;


{tfilesprite}
   tfilesprite=class(tfilebase)
   private

    ipreview                 :tpre8;
    isprite                  :tpiccore8;//record
    iimage                   :tcommonimage;
    iflashref                :string;

   public

    //create
    procedure on__create;                                                                   override;
    procedure on__destroy;                                                                  override;
    procedure on__timer;                                                                    override;

    //load / unload
    function  canloadDatatype(const xdatatype:tdatatype)                :boolean;           override;
    function  canloadFileext (const lext:string)                        :boolean;           override;
    procedure on__load;                                                                     override;
    procedure on__unload;                                                                   override;

    //copy
    function  supcopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    function  cancopyformat(const xformat:tfilecopyformat)              :boolean;           override;
    procedure copyformat(const xformat:tfilecopyformat);                                    override;

    //fetcher
    function fetchImage(var x:tcommonimage)                             :boolean;           override;

   end;


{tmanagecursor}
   tmanagecursoritem=record

    undoslot          :array[0..199] of string;
    lastdata          :string;

    ocr_index         :longint32;
    res_name          :pansichar;//use makeintresource(ocr_index) to set value
    reg_name          :string;

    end;

   tmanagecursor=class(tobject)
   private

    iundoinfo:tstr8;
    ilist:array[0..longint32(high(tsetcursor))] of tmanagecursoritem;

    function xisfilename     (const x:string):boolean;
    function xfindOCRIndex   (const xindex:tsetcursor):longint32;
    function xfindREGname    (const xindex:tsetcursor):string;
    procedure xinititem      (const xindex:tsetcursor);
    procedure xfreeitem      (const xindex:tsetcursor);
    function xfromstr        (const xindex:tsetcursor;const xdata:string):boolean;
    function xfinddefault    (const xindex:tsetcursor):string;//11may2026

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //can
    function can             (const xindex:tsetcursor):boolean;

    //reset
    function canreset        :boolean;
    function reset           :boolean;//restore cursor to system default

    //undo
    function canundo         :boolean;
    function undo            :boolean;

    //redo
    function canredo         :boolean;
    function redo            :boolean;

    //fromdata
    function canfromdata     (const xindex:tsetcursor):boolean;
    function fromdata        (const xindex:tsetcursor;const xdata:pobject):boolean;

    //fromfile
    function canfromfile     (const xindex:tsetcursor):boolean;
    function fromfile        (const xindex:tsetcursor;const xfilename:string):boolean;

    //fromstr
    function canfromstr      (const xindex:tsetcursor):boolean;
    function fromstr         (const xindex:tsetcursor;const xdata:string):boolean;

    //fromrec
    function canfromrec      (const xindex:tsetcursor):boolean;
    function fromrec         (const xindex:tsetcursor;const xdata:array of byte):boolean;

    //windows support
    procedure mousePropertiesDialog;
    procedure mouseSettingsDialog;

   end;


{tmanagebackground}
   tmanagebackgrounditem=record

    dslot             :array[0..99] of string;//image data
    wslot             :array[0..99] of widestring;//image filename

    dlast             :string;
    wlast             :widestring;

    end;

   tmanagebackground=class(tobject)
   private

    iundoinfo         :tstr8;//control info
    ilist             :array[0..19] of tmanagebackgrounditem;
    icount            :longint32;
    icom              :IDesktopWallpaper;

    function xisfilename     (const x:string):boolean;
    procedure xinititem      (const xindex:longint32);
    procedure xfreeitem      (const xindex:longint32);
    function xfromstr        (const xindex:longint;const ddata:string;wdata:widestring):boolean;
    function getfilename     (xindex:longint):widestring;
    procedure setfilename    (xindex:longint;x:widestring);
    property filename        [xindex:longint]:widestring read getfilename write setfilename;
    function xtempfile       (const xindex:longint):string;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //canmode
    function canmode         (const xmode:tsetmonitor):boolean;

    //undo
    function canundo         :boolean;
    function undo            :boolean;

    //redo
    function canredo         :boolean;
    function redo            :boolean;

    //fromdata
    function canfromdata     (const xmode:tsetmonitor):boolean;
    function fromdata        (const xmode:tsetmonitor;const xdata:pobject):boolean;

    //fromfile
    function canfromfile     (const xmode:tsetmonitor):boolean;
    function fromfile        (const xmode:tsetmonitor;const xfilename:string):boolean;

    //fromstr
    function canfromstr      (const xmode:tsetmonitor):boolean;
    function fromstr         (const xmode:tsetmonitor;const xdata:string):boolean;

    //fromrec
    function canfromrec      (const xmode:tsetmonitor):boolean;
    function fromrec         (const xmode:tsetmonitor;const xdata:array of byte):boolean;

    //ms pages
    procedure pageBackground;

   end;


{tmanagedata}
   tmanagedataevent=procedure(sender:tobject;xpromptForCustomName:boolean) of object;
   tmanagedata=class(tbasictoolbar)
   private

    icursor                  :tmanagecursor;
    ibackground              :tmanagebackground;
    idata                    :tstr8;//pointer only
    iext                     :string;
    icanmanageCursor         :boolean;
    icanmanageCursorINF      :boolean;
    icanmanageBackground     :boolean;
    itimer250                :longint64;
    ilasthub                 :tfilehub;
    isep                     :longint32;
    isep2                    :longint32;

    fon__cursorInstall       :tmanagedataevent;

    procedure xcmd(const xcode2:string);
    procedure x__onclick(sender:tobject);
    function xfetchdata(var x:tstr8):boolean;

   public

    //create
    constructor create2(xparent:tobject;xstart:boolean);                                                       override;
    destructor destroy;                                                                                        override;
    procedure _ontimer(sender:tobject);                                                                        override;
    procedure xupdatebuttons;

    //information
    function canmanage                                                                             :boolean;   virtual;
    function canmanageCursor                                                                       :boolean;   virtual;
    function canmanageBackground                                                                   :boolean;   virtual;

    //dialog access
    procedure mousePropertiesDialog;

    //data
    function  data                                                                                 :tstr8;     virtual;
    procedure setdata(const x:tfilehub);                                                                       virtual;
    procedure nodata;                                                                                          virtual;

    //events
    property on__cursorInstall                                                                     :tmanagedataevent      read fon__cursorInstall       write fon__cursorInstall;

   end;


{tmanagecustomcursorcolors}
   tmanagecustomcursorcolors=class(tbasicscroll)
   private

    itimer100         :longint64;
    itimer500         :longint64;
    ibody             :tbasiccolor;
    ibody2            :tbasiccolor;
    ibody3            :tbasiccolor;
    tbar              :tbasictoolbar;
    icolorLock        :boolean;
    icolorref         :string;
    ilastcanEdit      :boolean;

    function  getbody                                                          :longint32;
    function  getbody2                                                         :longint32;
    function  getbody3                                                         :longint32;
    function  getspeed                                                         :longint32;
    procedure setbody(x:longint32);
    procedure setbody2(x:longint32);
    procedure setbody3(x:longint32);
    procedure setspeed(x:longint32);
    procedure xsetcolor(const s:longint32;var d:longint32);
    procedure xupdatebuttons;
    procedure xcmd(const xcode2:string);

   public

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean);                                               override;
    destructor destroy;                                                                                        override;
    procedure _ontimer(sender:tobject);                                                                        override;
    procedure  on__color(sender:tobject;xval:longint);
    procedure  on__click(sender:tobject);

    //information
    property body                                                              :longint32             read getbody        write setbody;
    property body2                                                             :longint32             read getbody2       write setbody2;
    property body3                                                             :longint32             read getbody3       write setbody3;
    property speed                                                             :longint32             read getspeed       write setspeed;

   end;


{tmanagecustomwallpapereffects}
   tmanagecustomwallpapereffects=class(tbasicscroll)
   private

    itimer100         :longint64;
    itimer500         :longint64;
    tbar              :tbasictoolbar;
    ilastChangeId     :longint32;


    procedure xupdatebuttons;
    procedure xcmd(const xcode2:string);

   public

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean);                                               override;
    destructor  destroy;                                                                                       override;
    procedure   _ontimer(sender:tobject);                                                                      override;
    procedure   on__click(sender:tobject);

   end;


//support procs ----------------------------------------------------------------

function dt__label(const x:tdatatype):string;//14jun2026


implementation

uses main, archiveFiles;


//support procs ----------------------------------------------------------------

function dt__label(const x:tdatatype):string;//14jun2026

   procedure s(const x:string);
   begin

   result   :=x;

   end;

begin

case x of
dt_none               :s('None');
dt_folder             :s('Folder');
dt_text               :s('Text');
dt_cursor             :s('Cursor');
dt_image              :s('Image');
dt_sprite             :s('Sprite');
dt_midi               :s('Midi Music');
dt_music              :s('Music');
dt_cursorScheme       :s('Cursor Scheme');
dt_wallpaper          :s('Wallpaper');//04sep2026
dt_binary             :s('Binary');
else                   s('Binary');
end;//case

end;


//## tfolderhub ################################################################
//11111111111111111111111111111111111111111//xxxxxxxxxxx
constructor tfolderhub.create2(xparent:tobject;xscroll,xstart:boolean);
begin

//self
if classnameis('tfolderhub') then track__inc(satOther,1);
inherited create2(xparent,false,false);

bordersize            :=0;
oautoheight           :=true;
oclsarea              :=true;//is set to false via "nfinish" when there are 1 or more attached folders
static                :=true;

//vars
low__cls(@flist,sizeof(flist));
fcount                :=0;
ilocked               :=false;
ifullcount            :=0;
itimer100             :=slowms64;
itimer500             :=slowms64;
isettingsREF          :='';
istarted              :=false;
ilasthome             :=nil;
ifinishdone           :=false;
iitemindex            :=0;
iitemindexREF         :=-1;
ifilehub              :=nil;
imustcode             :=mc_none;

ifullbytes            :=0;
ifullbytesDONE        :=false;

isubbytes             :=0;

iautoscroll           :=false;
iautoscrolltime       :=0;
iautoscrollPaused     :=false;

irenderPaused         :=false;

//system files
isysfile_about        :='';
isysfile_aboutOK      :=false;

isysfile_readme       :='';
isysfile_readmeOK     :=false;

isysfile_license      :='';
isysfile_licenseOK    :=false;

//controls
with xhigh do
begin

itopbar               :=ntoolbar('');

with itopbar do
begin

halign                :=1;//center align

normal                :=false;

add( 'Home'       ,tepHome20     ,0 ,'home'     ,'Home|Show the default home folder (root folder) of the archive' );
add( 'ABOUT'      ,tepEdit20     ,0 ,'about'    ,'ABOUT|Show the about panel for the archive' );
add( 'README'     ,tepREADME20   ,0 ,'readme'   ,'README|Show the information panel for the archive' );
add( 'License'    ,tepLicense20  ,0 ,'license'  ,'License|Show the license panel for the archive' );

add( ''     ,tepScrollDown20 ,0 ,'autoscroll' ,
 'Automatic Scroll|Automatically scroll down through the list of files.  The scroll rate varies depending on the file type:'+
 '|*'+
 '|* Cursor Scheme  '+k64(sd_cursorScheme)        +'s  ('+k64(sd_cursorSchemeAnimated)+'s when animated)'+
 '|* Image  '+k64(sd_image)        +'s  ('+k64(sd_imageAnimated)+'s when animated)'+
 '|* Sprite '+k64(sd_sprite)       +'s'+
 '|* Text   '+k64(sd_text)         +'s'+
 '|* Music  '+k64(sd_midi)         +'s  ('+k64(sd_midiPlaying)+'s when playing)'+
 '|* Other  '+k64(sd_other)        +'s'+
 '');

end;

itoplabel             :=ntitle2(false,false,'','Current Location|Reports the currently open folder in the archive');
itoplabel.obold       :=false;

end;//xhigh

//list
ilist                 :=client.nlistx('',
 'File List'+
 '|A list of available files in the archive.  A file is viewed and / or played in the content viewer on the right.'+
 '|*|Each file can be extracted out to disk using one of the extraction methods under the "Archive Extraction Options" panel, bottom right column.'+
 '',0,0,folder__onitem);

ilist.ostyle          :=lslist;//17jun2026
ilist.bordersize      :=0;
ilist.oretainpos      :=true;
ilist.ocanshowmenu    :=true;
ilist.tagstr          :='list.doubleclick';
ilist.onumberFrom     :=0;
ilist.orows           :=true;
ilist.ofast           :=true;
ilistTab              :='';

with xhigh2 do
begin

nbreak(10);

imask                 :=nset('Available File Formats','File Formats|Toggle which file formats to view',0,0);

with imask do
begin

itemsperline          :=5;
visible               :=false;//hide by default

end;

imaskbar              :=ntoolbar('');

with imaskbar do
begin

oscaleh               :=0.8;//06may2026
normal                :=false;
enabled               :=false;//disabled by default

add('Default'   ,tepMask20,0,'maskmode.'+intstr32(longint32(mm_default)) ,xhelpval( 'maskmode.'+intstr32(longint32(mm_default))  ) );
add('All'       ,tepMask20,0,'maskmode.'+intstr32(longint32(mm_all))     ,xhelpval( 'maskmode.'+intstr32(longint32(mm_all))      ) );
add('Simple'    ,tepMask20,0,'maskmode.'+intstr32(longint32(mm_simple))  ,xhelpval( 'maskmode.'+intstr32(longint32(mm_simple))   ) );
add('Custom'    ,tepMask20,0,'maskmode.'+intstr32(longint32(mm_custom))  ,xhelpval( 'maskmode.'+intstr32(longint32(mm_custom))   ) );
add('Custom 2'  ,tepMask20,0,'maskmode.'+intstr32(longint32(mm_custom2)) ,xhelpval( 'maskmode.'+intstr32(longint32(mm_custom2))  ) );

end;

nbreak(10);

end;//xhigh2


//sub-proc
on__create;

//events
itopbar.onclick       :=__onclick;
imaskbar.onclick      :=folder__onclick;
ilist.ongetitem       :=folder__onitem;
ilist.onclick         :=folder__onclick;
ilist.ondbclick       :=folder__ondbclick;

end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//111111111111111111

function tfolderhub.folder__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   d        :tfolderbase;

begin

result      :=folderCurrentOK(d) and d.xfolder__onitem(sender,xindex,xtab,xtep,xtepcolor,xcaption,xcaplabel,xhelp,xcode2,xcode,xshortcut,xindent,xflash,xenabled,xtitle,xsep,xbold);

end;

procedure tfolderhub.folder__onclick(sender:tobject);
var
   d        :tfolderbase;

begin

//check
if not folderCurrentOK(d) then exit;
if not d.made             then exit;

//turn off autoscroll
if (sender is tbasicmenu) then
   begin

   noscroll;

   end;

//get
if      (sender is tbasictoolbar)    then d.xcmd( (sender as tbasictoolbar).ocode2 )
else if (sender is tbasicjump)       then d.xcmd('jump.mustpos');

end;

procedure tfolderhub.folder__ondbclick(sender:tobject);
var
   d        :tfolderbase;

begin

//check
if not folderCurrentOK(d) then exit;
if not d.made             then exit;
if not vidoubleclicks     then exit;

//get
if (sender is tbasicmenu) then d.xcmd( (sender as tbasicmenu).tagstr );

end;

function tfolderhub.xhelpval(const x:string):string;
begin

result:=xhelpval2(x,true);

end;

function tfolderhub.xhelpval2(const x:string;const xfull:boolean):string;
begin

if (x='maskmode.'+intstr32(longint32(mm_default))) then
   begin

   result:=
   'File List - Default'+
   '|A straightforward option to list files contained within the archive.'+
   '';

   end

else if (x='maskmode.'+intstr32(longint32(mm_all))) then
   begin

   result:=
   'File List - All Files'+
   '|A straightforward option to list all the files contained within the archive.'+
   '';

   end

else if (x='maskmode.'+intstr32(longint32(mm_simple))) then
   begin

   result:=
   'File List - Simple (Interactive Mask)'+
   '|An easy-to-use interactive file listing selector.  Select the file types you wish to list and un-select those you don''t.  The file list will update automatically.'+
   '|*|Note:|Un-selecting all the file types is identical to selecting them all, and will list every file in the archive.'+
   '';

   end

else if (x='maskmode.'+intstr32(longint32(mm_custom))) or (x='maskmode.'+intstr32(longint32(mm_custom2))) then
   begin

   result:=

   'File List - Custom Mask'+insstr(' 2',(x='maskmode.'+intstr32(longint32(mm_custom2))))+
   '|Use one or a series of complex masks to filter which files appear in the file list.'+
   '|*|Type one or more complex masks (e.g. *abc*.mid;*.jpg; ) per line, separating each with a semi-colon ";" and using no more '+
   'than 2 asterisks "*" per mask (e.g. *abc*;).'+

   '|*|Each file name in the list is compared against all the masks on one line.  If it matches just one mask, it passes down to the next line.'+
   '|*|If the file name passes every line to the last, then the file name will appear in the file list.'+

   insstr(
   '|*|To edit this custom mask, select this option, then select it again to display a pop-up text box.'
   ,xfull
   )+

   '';

   end

else
   begin

   result:='';

   end;

end;

procedure tfolderhub.on__create;
begin

//nil

end;

procedure tfolderhub.on__destroy;
begin

//nil

end;

destructor tfolderhub.destroy;
var
   p                  :longint32;

begin
try

//save settings to file
autosavesettings;

//sub-proc
on__destroy;

//free folders
for p:=0 to high(flist) do
begin

if (flist[p]<>nil) then
   begin

   freeobj(@flist[p]);

   end;

end;//p

//self
inherited destroy;
if classnameis('tfolderhub') then track__inc(satOther,-1);

except;end;
end;

procedure tfolderhub.start(const xIncludeSysFiles:boolean);
begin

//check
if istarted then exit
else             istarted:=true;

//finish -> in case it hasn't already been called - 27may2026
nfinish;

//only show the nav lavel when we have a HOME folder that can branch out to sub-folders - 14jun2026
itoplabel.visible     :=(ilasthome<>nil);

//defaults
setfolderindex( 0 );//show first folder by default

//loadsettings
loadsettings;

//start
inherited start;

end;

function tfolderhub.canfilehub:boolean;
begin

result      :=(ifilehub<>nil);

end;

function tfolderhub.fileHub:tfilehub;
begin

result      :=ifilehub;

end;

procedure tfolderhub.setfilehub(const x:tfilehub);
begin

ifilehub    :=x;

end;

function  tfolderhub.cansubfile(const xsubFileID:longint32):boolean;//18jun2026
begin

result      :=(folderCurrent<>nil) and folderCurrent.cansubfile( xsubFileID );

end;

function tfolderhub.filename(const xsubFileID:longint32):string;
var
   d:tfolderbase;

begin

//defaults
result      :='';

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.subfolder + d.filename( d.itemindex ,xsubFileID );

   end;

end;

function tfolderhub.filesize(const xsubFileID:longint32):longint32;
var
   d:tfolderbase;

begin

//defaults
result      :=0;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.filesize( d.itemindex ,xsubFileID );

   end;

end;

function tfolderhub.filesize2(const xsubFileID:longint32;var xisApproximate:boolean):longint32;
var
   d:tfolderbase;

begin

//defaults
result                :=0;
xisApproximate        :=false;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.filesize2( d.itemindex ,xsubFileID ,xisApproximate );

   end;

end;

function tfolderhub.cansubfileid(const xsubFileID:longint32):boolean;
var
   d:tfolderbase;

begin

//defaults
result      :=false;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.cansubfileid( xsubFileID );

   end;

end;

function tfolderhub.itemtype(const xsubFileID:longint32):titemtype;
var
   d:tfolderbase;

begin

//defaults
result      :=it_none;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.itemtype( d.itemindex ,xsubFileID );

   end;

end;


function tfolderhub.isfile(const xsubFileID:longint32):boolean;
begin

result      :=( itemtype( xsubFileID ) = it_file );

end;

function tfolderhub.isfolder(const xsubFileID:longint32):boolean;
begin

result      :=( itemtype( xsubFileID ) = it_folder );

end;

function tfolderhub.fromfile(const xsubFileID:longint32;const xdata:tstr8):boolean;
var
   d:tfolderbase;

begin

//defaults
result      :=false;

//clear
if (xdata=nil) then exit
else                xdata.clear;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.fromfile( d.itemindex ,xsubFileID ,xdata );

   end;

end;

function tfolderhub.toanimation(const xwantSize,xsubFileID:longint32;const ximage:tcommonimage):boolean;
var
   d:tfolderbase;

begin

//defaults
result      :=false;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.toanimation( xwantSize ,d.itemindex ,xsubFileID ,ximage );

   end;

end;

function tfolderhub.toanimationinfo(const xwantSize,xsubFileID:longint32;var x:tanimationinfo):boolean;
var
   d:tfolderbase;

begin

//defaults
result      :=false;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.toanimationinfo( xwantSize ,d.itemindex ,xsubFileID ,x );

   end;

//clear on error
if not result then
   begin

   low__cls(@x,sizeof(x));

   end;

end;

function tfolderhub.toanimationcell(const xwantSize,xsubFileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean;
var
   d:tfolderbase;

begin

//defaults
result      :=false;

//get
d           :=folderCurrent;

if (d<>nil) then
   begin

   result   :=d.toanimationcell( xwantSize ,d.itemindex ,xsubFileID ,xcellindex ,ximage  );

   end;

end;

function  tfolderhub.folderIndex:longint32;
begin

if (foldercount>=1) then result:=frcrange32( iitemindex ,0 ,frcmin32(pred(fcount),0) )
else                     result:=0;

end;

procedure tfolderhub.setfolderIndex(const xindex:longint32);
begin

iitemindex  :=frcrange32( xindex ,0 ,frcmin32(pred(fcount),0) );

end;

function  tfolderhub.subfolderCurrent:tfolderbase;
begin

//defaults
result      :=nil;

//get
if (folderCurrent is tfolderhome) and isfolder(0) then
   begin

   result   :=folder( folderCurrent.folderindex(folderCurrent.itemindex,0) );

   end;

end;

function  tfolderhub.folderCurrent:tfolderbase;
begin

if (foldercount>=1) then result:=folder( folderindex )
else                     result:=nil;

end;

function  tfolderhub.folderCurrentOK(var x:tfolderbase):boolean;
begin

x           :=folderCurrent;
result      :=(x<>nil);

end;

function  tfolderhub.folder(const xindex:longint):tfolderbase;
begin

result      :=flist[ frcrange32( xindex ,0 ,frcmin32(pred(fcount),0) ) ];

end;

function tfolderhub.settingsFilename:string;
begin

result      :=app__folderSettings(true) + 'folderhub-settings.ini';

end;

procedure tfolderhub.loadsettings;
begin

if istarted then
   begin

   setsettings( io__fromfilestr2( settingsFilename ) );

   isettingsREF       :=settings;

   end;

end;

procedure tfolderhub.savesettings;
begin

if istarted then
   begin

   isettingsREF       :=settings;

   io__tofilestr2( settingsFilename ,isettingsREF );

   end;

end;

procedure tfolderhub.autosavesettings;
begin

if istarted and low__setstr( isettingsREF ,settings ) then savesettings;

end;

function tfolderhub.settings:string;

   procedure i32(const n:string;const v:longint32);
   begin

   result:=result+n+': '+intstr32(v)+#10;

   end;

   procedure b(const n:string;const v:boolean);
   begin

   result:=result+n+': '+bolstr(v)+#10;

   end;

   procedure s(const n,v:string);
   begin

   result:=result+n+': '+v+#10;

   end;

begin

//defaults
result      :='';

//check
if not istarted then exit;

//add values
i32('folder.index'    ,folderindex );
b  ('autoscroll'      ,iautoscroll );

end;

procedure tfolderhub.setsettings(const x:string);
var
   a:tvars8;

begin

//check
if not istarted then exit;

//defaults
a                     :=nil;

try

//init
a                     :=tvars8.create;
a.text                :=x;

//get
setfolderindex( a.idef2('folder.index' ,0 ,0 ,pred(fcount)) );
setautoscroll ( a.bdef ('autoscroll'  ,false              ) );

except;end;

//free
freeobj(@a);

end;

function  tfolderhub.nhome:tfolderhome;
begin

//home already exists -> limit of one home folder
if (ilasthome<>nil) then
   begin

   result   :=ilasthome;
   exit;

   end;

//get
result      :=tfolderhome.create( self ,'Home' ,0 );
ilasthome   :=result;//use in proc "homefinish"

if (fcount<>1) then
   begin

   showerror('Warning: Home folder must be created first');

   end;

end;

function tfolderhub.archivefiles__fileexists(const xfilename:string):boolean;
var//Note: reads files from "archivefiles.pas" unit
   xdatalen           :longint32;
   xorgSize           :longint32;
   p                  :longint32;
   pdata              :pointer;
   xcompressed        :boolean;
   xpathname          :string;

begin

//defaults
result                :=false;

//get
for p:=0 to max32 do
begin

if archiveFiles.storage__findfile( p ,pdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   if strmatch( xpathname ,xfilename ) then
      begin

      result          :=true;

      break;

      end;

   end

else break;

end;//p

end;

function tfolderhub.archivefiles__fromfile(const xfilename:string;var xdata:string):boolean;
var//Note: reads files from "archivefiles.pas" unit
   xdatalen           :longint32;
   xorgSize           :longint32;
   p                  :longint32;
   pdata              :pointer;
   xcompressed        :boolean;
   xpathname          :string;
   a                  :tstr8;

begin

//defaults
result                :=false;
a                     :=nil;

try

//get
for p:=0 to max32 do
begin

if archiveFiles.storage__findfile( p ,pdata ,xdatalen ,xorgSize ,xcompressed ,xpathname ) then
   begin

   if strmatch( xpathname ,xfilename ) then
      begin

      //init
      a     :=rescache__newStr8;

      //get
      if a.addrec( pdata ,xdatalen ) and ( (not xcompressed) or low__decompress(@a) ) then
         begin

         //successful
         xdata        :=a.text;
         result       :=true;

         end;

      //stop
      break;

      end;

   end

else break;

end;//p

except;end;

//free
rescache__delStr8( @a );

end;

procedure tfolderhub.nfinish;//call once all folders are attached/created
var
   p:longint32;

   procedure xfindSysFile(const xbasename:string;var xfilename:string;var xok:boolean);

      procedure f(const fext:string);
      var
         df:string;

      begin

      if (not xok) and (fext<>'') then
         begin

         df           :=xbasename + '.' + fext;

         if archivefiles__fileexists( df ) then
            begin

            xfilename :=df;
            xok       :=true;

            end;

         end;

      end;

   begin

   //defaults
   xfilename          :='';
   xok                :=false;

   //find
   f('txt');
   f('bwd');
   f('bwp');
   f('rtf');

   f('jpg');
   f('png');
   f('gif');

   end;

begin


//check
if ifinishdone then exit
else                ifinishdone:=true;


//full count -------------------------------------------------------------------

//Note: Remains static from this point on, only subcount changes

for p:=0 to pred(fcount) do
begin

inc64( ifullcount ,flist[p].fullcount );

end;//p


//find system files -> uses "archivefiles.pas" ---------------------------------

if (foldercount>=1) then
   begin

   xfindSysFile( '.about'    ,isysfile_about     ,isysfile_aboutOK   );
   xfindSysFile( '.readme'   ,isysfile_readme    ,isysfile_readmeOK  );
   xfindSysFile( '.license'  ,isysfile_license   ,isysfile_licenseOK );

   end;


//finalise "home" folder
if (ilasthome<>nil) then
   begin

   ilasthome.finish( self );

   end;


//sync -------------------------------------------------------------------------

if (foldercount>=1) then
   begin

   oclsarea :=false;

   end;

xupdatebuttons;

end;

function  tfolderhub.ntest(const xname:string):tfoldertest;
begin

result      :=tfoldertest.create( self ,strdefb(xname,'Test') ,0 );

end;

function  tfolderhub.narchive(const xname:string):tfolderarchive;
begin

result      :=tfolderarchive.create( self ,strdefb(xname,'Archive') ,0 );

end;

function  tfolderhub.ncursors(const xclass:tcursorclass;const xname:string):tfoldercursor;
begin

result      :=tfoldercursor.create( self ,strdefb(xname,'Cursors') ,longint32(xclass) );

end;

procedure tfolderhub.ncursorsRainbow(const clist:array of tcursorclass);
begin

ncursorsCustom( clist, cc_rainbow ,cc_rainbowMAX );

end;

procedure tfolderhub.ncursorsCustomColor(const clist:array of tcursorclass);
begin

ncursorsCustom( clist, cc_customcolor ,cc_customcolorMAX );

end;

procedure tfolderhub.ncursorsMixed(const clist:array of tcursorclass);

   procedure d(const ccfrom,ccto:longint32);
   var
      cindex          :longint32;
      cc              :longint32;

   begin

   for cindex:=0 to high(clist) do
   begin

   for cc:=ccfrom to ccto do
   begin

   ncursorsCustom0( clist[cindex] ,cc );

   end;//p

   end;//cc

   end;

begin

d( cc_red      ,cc_red2      );

d( cc_green    ,cc_green2    );

d( cc_blue     ,cc_blue2     );

d( cc_yellow   ,cc_yellow2   );

d( cc_aqua     ,cc_aqua2     );

d( cc_orange   ,cc_orange2   );

d( cc_purple   ,cc_purple2   );

d( cc_pink     ,cc_pink2     );

d( cc_white    ,cc_white     );

d( cc_grey     ,cc_grey      );

d( cc_black    ,cc_black     );

d( cc_brown    ,cc_brown2    );

end;

procedure tfolderhub.ncursorsRed(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_red ,cc_redMAX );

end;

procedure tfolderhub.ncursorsGreen(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_green ,cc_greenMAX );

end;

procedure tfolderhub.ncursorsBlue(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_blue ,cc_blueMAX );

end;

procedure tfolderhub.ncursorsYellow(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_yellow ,cc_yellowMAX );

end;

procedure tfolderhub.ncursorsBrown(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_brown ,cc_brownMAX );

end;

procedure tfolderhub.ncursorsGrey(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_grey ,cc_greyMAX );

end;

procedure tfolderhub.ncursorsPink(const clist:array of tcursorclass);
begin

ncursorsCustom( clist ,cc_pink ,cc_pinkMAX );

end;

procedure tfolderhub.ncursorsCustom0(const clist:array of tcursorclass;const cc_from:longint32);
begin

ncursorsCustom( clist ,cc_from ,cc_from );

end;

procedure tfolderhub.ncursorsCustom(const clist:array of tcursorclass;const cc_from,cc_to:longint32);
var
   cindex             :longint32;
   cc_index           :longint32;

   function xfoldername(const cc_index:longint32):string;
   begin

   result:=cc__name( cc_index ) + '-cursors-' + cursor__classname( clist[cindex] );

   end;

   procedure nOne;
   var
      ct_index        :longint32;

   begin


   //.make folder
   with ncursors( clist[cindex] ,xfoldername( cc_index  ) ) do
   begin

   nmake( cc_index ,-2 ,-1 ,cc__tepcolor( clist[cindex] ,cc_index ) );

   nfinish;

   end;//with

   end;

begin

for cindex:=0 to high(clist) do
begin

for cc_index:=cc_from to cc_to do
begin

nOne;

end;//cc

end;//cindex

end;

function  tfolderhub.nwallpapers(const xname:string;const xtepColor:longint32;const wemList:string):tfolderwallpaper;
begin

result      :=tfolderwallpaper.create( self ,strdefb(xname,'Wallpapers') ,0 );
result.makeList( xtepColor ,wemList );

end;

procedure tfolderhub.nwallpapersAll(const xname:string);

   procedure xadd(const xtepColor:longint32;const xstyle:string);
   var
      p               :longint32;
      n               :string;
      c               :char;
      v               :string;

   begin

   //init
   n                  :=xname;

   for p:=1 to low__len32(xstyle) do
   begin

   c                  :=xstyle[ p - 1 + stroffset ];
   v                  :=wem__name( c );

   if (v<>'') then n:=n + insstr('__',n<>'') + v;

   end;//p

   //get
   nwallpapers( n ,xtepColor ,xstyle );

   end;

begin

xadd( rgba__int(255,34,239,255) ,'' );
xadd( clred ,wem_mix1 );
xadd( clred ,wem_mix2 );
xadd( clred ,wem_mix3 );
xadd( cllime ,wem_mix4 );
xadd( cllime ,wem_mix5 );
xadd( clyellow ,wem_skew1 );
xadd( clyellow ,wem_skew2 );
xadd( clyellow ,wem_skew3 );

end;

function  tfolderhub.xnewslot(const x:tfolderbase):longint32;
begin

if (x<>nil) and (fcount<=high(flist)) then
   begin

   result             :=fcount;//return slot index
   flist[ fcount ]    :=x;

   inc( fcount );

   end

else begin

   result:=0;//return a safe value even thought it's incorrect

   end;

end;

procedure tfolderhub.xupdatebuttons;
var
   xfolderCurrent     :tfolderbase;
   xfilename0         :string;

begin

//init
xfolderCurrent        :=folderCurrent;

if (foldercount>=1) and (folderindex=0) then
   begin

   xfilename0         :=folder(0).filename( folder(0).itemindex ,0 );

   end

else begin

   xfilename0         :='';

   end;


//topbar -----------------------------------------------------------------------

if (xfolderCurrent<>nil) then
   begin

   itoplabel.text  :=
    insstr('Home',ilasthome<>nil)+//have a home folder so show "Home" by default
    insstr( insstr( '  >  ' ,ilasthome<>nil ) + xfolderCurrent.name ,xfolderCurrent<>ilasthome );

   end;


with itopbar do
begin

bvisible2['home']            :=(ilasthome<>nil);
benabled2['home']            :=(ilasthome<>nil) and (folderindex<>0);

bvisible2['about']           :=isysfile_aboutOK;
bmarked2 ['about']           :=isysfile_aboutOK and strmatch(xfilename0,isysfile_about);

bvisible2['readme']          :=isysfile_readmeOK;
bmarked2 ['readme']          :=isysfile_readmeOK and strmatch(xfilename0,isysfile_readme);

bvisible2['license']         :=isysfile_licenseOK;
bmarked2 ['license']         :=isysfile_licenseOK and strmatch(xfilename0,isysfile_license);

bmarked2 ['autoscroll']      :=iautoscroll;
bflash2  ['autoscroll']      :=iautoscroll;

end;

end;

procedure tfolderhub.__onclick(sender:tobject);
begin

if (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 );

end;

procedure tfolderhub.xcmd(const xcode2:string);
label
   skipend;

var
   xresult:boolean;
   xwas,v32:longint32;
   v,e:string;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
xresult     :=true;
e           :=gecTaskfailed;
v           :='';
v32         :=0;

//check
if not istarted then exit;

try

if m('home') then
   begin

   noscroll;
   setfolderindex( 0 );

   end

else if m('about') then
   begin

   if isysfile_aboutOK then xshowSysFile( isysfile_about );

   end

else if m('readme') then
   begin

   if isysfile_readmeOK then xshowSysFile( isysfile_readme );

   end

else if m('license') then
   begin

   if isysfile_licenseOK then xshowSysFile( isysfile_license );

   end

else if m('autoscroll') then
   begin

   setautoscroll( not autoscroll );

   end

else begin

   //nil
   
   end;

skipend:

except;end;

//update
xupdatebuttons;

//sbow error
if not xresult then gui.poperror('',e);

end;

procedure tfolderhub.xshowSysFile(const n:string);
var
   i:longint32;

begin

//system files are always in the first folder
if (n<>'') and (foldercount>=1) then
   begin

   //stop autoscroll
   noscroll;

   //show root folder
   if (folderindex<>0) then
      begin

      setfolderindex( 0 );

      //force update -> proper selection/mask/etc
      folder(0).bringReady( true );

      end;

   //find the file
   if folder(0).findfile( n ,i ) then
      begin

      folder(0).setitemindex( i );

      end

   //switch mask back to mm_default and try again
   else begin

      folder(0).setmaskmode( mm_default ,true );

      //force update -> proper selection/mask/etc
      folder(0).bringReady( true );

      if folder(0).findfile( n ,i ) then
         begin

         folder(0).setitemindex( i );

         end;

      end;

   end;

end;

procedure tfolderhub._ontimer(sender:tobject);
var
   xmustupdate        :boolean;
   v                  :longint32;
   p                  :longint32;
   
begin
try

//self
inherited _ontimer(sender);

//defaults
xmustupdate :=false;

//get

if (imustcode<>mc_none) then
   begin

   //get
   v        :=imustcode;
   imustcode:=mc_none;

   //set
   case v of
   mc_nextFile:nextFile;
   mc_prevFile:prevFile;
   end;//case

   end;

//itimer100
if (slowms64>=itimer100) then
   begin

   //autoscroll
   if iautoscroll and (not iautoscrollPaused) then
      begin

      //reset time
      if (iautoscrolltime=0) then
         begin

         iautoscrolltime :=slowms64;

         end;

      //check timeout
      if ( sub64(slowms64,iautoscrolltime) >= autoscrollDelay ) then
         begin

         //reset timeout
         iautoscrolltime :=slowms64;

         //nextFile
         autoscrollNextFile;

         end;

      end;

   //all folder timers except current folder
   for p:=0 to pred(fcount) do
   begin

   if (p<>iitemindex) then
      begin

      flist[p].on__roottimer;

      end;

   end;//p

   //reset
   itimer100:=add64( slowms64 ,100 );

   end;


//misc -------------------------------------------------------------------------

//pageindex check
if mustshowfolder(true) then
   begin

   xmustupdate:=true;

   end;

//.itimer500
if (slowms64>=itimer500) then
   begin

   //update
   xmustupdate        :=true;

   //update data counters
   if not ifullbytesDONE then
      begin

      xsyncFullbytes;

      end;

   //save settings
   autosavesettings;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

//current folder timer
if (iitemindex>=0) and (iitemindex<fcount) then//fixed: 30aug2026
   begin

   flist[iitemindex].on__roottimer;

   end;

//update
if xmustupdate then
   begin

   //updatebuttons
   xupdatebuttons;

   end;

except;end;
end;

procedure tfolderhub.xresetFullbytes;
begin

ifullbytesDONE        :=false;

end;

procedure tfolderhub.xsyncFullbytes;
var
   v                  :longint64;
   vok                :boolean;
   p                  :longint32;

begin

//init
v                     :=0;
vok                   :=true;

//get
for p:=0 to pred(foldercount) do
begin

inc64( v ,flist[p].fullbytes );

if not flist[p].fullbytesDONE then
   begin

   vok                :=false;

   end;

end;//p

//set
ifullbytes            :=v;
ifullbytesDONE        :=vok;

end;

function tfolderhub.mustshowfolder(const xreset:boolean):boolean;
begin

result      :=(iitemindexREF<>folderindex);

if xreset and result then
   begin

   //unshow
   if (iitemindexREF>=0) and (iitemindexREF<fcount) then
      begin

      flist[iitemindexREF].on__unshow;

      end;

   //sync
   iitemindexREF      :=folderindex;

   //show
   if (iitemindexREF>=0) and (iitemindexREF<fcount) then
      begin

      flist[iitemindexREF].on__show( ilist ,imask ,imaskbar );

      end;

   end;

end;

function  tfolderhub.folderisempty:boolean;
begin

result      :=(folderCurrent=nil) or folderCurrent.empty;

end;

function  tfolderhub.canopenfolder:boolean;
begin

result      :=(folderCurrent<>nil) and folderCurrent.canopenfolder;

end;

procedure tfolderhub.openfolder;
begin

if canopenfolder then
   begin

   folderCurrent.openfolder;

   end;

end;

function  tfolderhub.athome:boolean;
begin

result      :=(ilasthome<>nil) and (folderindex=0);

end;

function  tfolderhub.canopenhome:boolean;
begin

result      :=(ilasthome<>nil);

end;

procedure tfolderhub.openhome;
begin

if canopenhome then
   begin

   setfolderindex( 0 );

   end;

end;

function tfolderhub.folderSeeking:boolean;
begin

result      :=mustshowfolder( false ) or ( (folderCurrent<>nil) and (not folderCurrent.showing) );

end;

procedure tfolderhub.autoscrollNextFile;
begin

if cannextFile then
   begin

   folderCurrent.nextFile;

   end;

end;

function tfolderhub.autoscrollDelay:longint32;
begin

//get delay in seconds
if (ifilehub.fileCurrent<>nil) then
   begin

   case ifilehub.fileCurrent.datatype of
   dt_wallpaper       :result:=sd_image;
   dt_cursorScheme    :result:=low__aorb( sd_cursorScheme ,sd_cursorSchemeAnimated ,ifilehub.fileCurrent.animated );
   dt_cursor          :result:=low__aorb( sd_image        ,sd_imageAnimated        ,ifilehub.fileCurrent.animated );
   dt_image           :result:=low__aorb( sd_image        ,sd_imageAnimated        ,ifilehub.fileCurrent.animated );
   dt_sprite          :result:=           sd_sprite;
   dt_midi            :result:=low__aorb( sd_midi         ,sd_midiPlaying          ,ifilehub.fileCurrent.playing  );
   dt_text            :result:=           sd_text;
   else                result:=           sd_other;

   end;//case

   end

else begin

   result   :=sd_other;

   end;

//convert seconds into milliseconds
result      :=result * 1000;


end;

function tfolderhub.renderPaused:boolean;
begin

result                :=irenderPaused;

end;

procedure tfolderhub.renderPause;
begin

irenderPaused         :=true;

end;

procedure tfolderhub.renderUnpause;
begin

irenderPaused         :=false;

end;

function tfolderhub.autoscrollPaused:boolean;
begin

result                :=iautoscrollPaused;

end;

procedure tfolderhub.autoscrollPause;
begin

iautoscrollPaused     :=true;

end;

procedure tfolderhub.autoscrollUnpause;
begin

iautoscrollPaused     :=false;

end;

function tfolderhub.autoscroll:boolean;
begin

result      :=iautoscroll;

end;

procedure tfolderhub.setautoscroll(const x:boolean);
begin

if low__setbol(iautoscroll,x) then
   begin

   iautoscrolltime:=0;//reset
   xupdatebuttons;

   end;

end;

procedure tfolderhub.noscroll;
begin

setautoscroll( false );

end;

function tfolderhub.subcount:longint64;
var
   p:longint32;

begin

//defaults
result      :=0;

//get
for p:=0 to pred(fcount) do
begin

inc64( result ,flist[p].subcount );

end;//p

end;

function tfolderhub.cannextFile:boolean;
begin

result      :=istarted and (not iautoscrollPaused) and (folderCurrent<>nil) and folderCurrent.cannextFile;

end;

procedure tfolderhub.nextFile;
begin

if cannextFile then
   begin

   noscroll;//turn off autoscroll

   folderCurrent.nextFile;

   end;

end;

function tfolderhub.canprevFile:boolean;
begin

result      :=istarted and (not iautoscrollPaused) and (folderCurrent<>nil) and folderCurrent.canprevFile;

end;

procedure tfolderhub.prevFile;
begin

if canprevFile then
   begin

   folderCurrent.prevFile;

   end;

end;

procedure tfolderhub.setmustcode(const xcode:longint32);
begin

//turn off autoscroll
noscroll;

//get
imustcode   :=frcrange32( xcode ,0 ,mc_max );

end;


//xxxxxxxxxxxxxxxxxxxxxxxxxxx//33333333333333333333

//## tfakeset ##################################################################

constructor tfakeset.create;
begin

//self
inherited create;

//vars
iobj                  :=nil;
icount                :=0;
idef                  :=0;
ival                  :=0;
ivisible              :=false;

end;

destructor tfakeset.destroy;
begin

//nil

end;

procedure tfakeset.setobj(x:tbasicset);
var
   p                  :longint32;
   w                  :tbasicset;

begin

//check
if ((x=nil) and (iobj=nil)) or ((x<>nil) and (iobj<>nil)) then exit;

//connecting
if (x<>nil) then
   begin

   //on
   iobj               :=x;

   //us -> obj
   for p:=0 to high(icaps) do
   begin

   iobj.xset( p ,icaps[p] ,inams[p] ,ihlps[p] ,vals[p] );

   end;//p

   iobj.val           :=ival;

   end

//disconnecting
else begin

   //off
   w                  :=iobj;//temp copy
   iobj               :=nil;

   //obj -> us
   for p:=0 to high(icaps) do
   begin

   xset( p ,w.caps[p] ,w.nams[p] ,w.hlps[p] ,w.vals[p] );

   end;//p

   ival               :=w.val;

   end;

end;

procedure tfakeset.setvisible(x:boolean);
begin

case (iobj<>nil) of
true:iobj.visible     :=x;
else ivisible         :=x;
end;//case

end;

function tfakeset.focused:boolean;
begin

case (iobj<>nil) of
true:result :=iobj.focused;
else result :=false;
end;//case

end;

function tfakeset.getvisible:boolean;
begin

case (iobj<>nil) of
true:result :=iobj.visible;
else result :=ivisible;
end;//case

end;

procedure tfakeset.xsynccount;
var
   p                  :longint32;
   int1               :longint32;
begin

int1                  :=0;

for p:=0 to high(icaps) do if (low__len32(icaps[p])>=1) then inc(int1);

icount                :=int1;

end;

procedure tfakeset.xset(xindex:longint;xcap,xnam,xhlp:string;xval:boolean);
begin

case (iobj<>nil) of
true:iobj.xset(xindex,xcap,xnam,xhlp,xval);
else xset3(xindex,xcap,xnam,xhlp,xval);
end;//case

end;

procedure tfakeset.xset3(xindex:longint;xcap,xnam,xhlp:string;xval:boolean);
begin

if (iobj<>nil) then
   begin

   iobj.xset3(xindex,xcap,xnam,xhlp,xval,'');

   end
else begin

   if (xindex>=0) and (xindex<=high(icaps)) then
      begin

      icaps[xindex]      :=xcap;
      inams[xindex]      :=xnam;
      ihlps[xindex]      :=xhlp;
      vals[xindex]       :=xval;

      xsynccount;

      end;

   end;

end;

function tfakeset.getcaps(xindex:longint):string;
begin

if      (iobj<>nil)                           then result:=iobj.caps[xindex]
else if (xindex>=0) and (xindex<=high(icaps)) then result:=icaps[xindex]
else                                               result:='';

end;

procedure tfakeset.setcaps(xindex:longint;xval:string);
begin

if      (iobj<>nil)                                                     then iobj.caps[xindex]:=xval
else if (xindex>=0) and (xindex<=high(icaps)) and (xval<>icaps[xindex]) then
   begin

   icaps[xindex]      :=xval;

   xsynccount;

   end;

end;

function tfakeset.getnams(xindex:longint):string;
begin

if      (iobj<>nil)                           then result:=iobj.nams[xindex]
else if (xindex>=0) and (xindex<=high(icaps)) then result:=inams[xindex]
else                                               result:='';

end;

procedure tfakeset.setnams(xindex:longint;xval:string);
begin

if      (iobj<>nil)                                                     then iobj.nams[xindex] :=xval
else if (xindex>=0) and (xindex<=high(icaps)) and (xval<>inams[xindex]) then inams[xindex]     :=xval;

end;

function tfakeset.getvisb(xindex:longint):boolean;//31jul2021
begin

if      (iobj<>nil)                           then result:=iobj.visb[xindex]
else if (xindex>=0) and (xindex<=high(ivisb)) then result:=ivisb[xindex]
else                                               result:=false;

end;

procedure tfakeset.setvisb(xindex:longint;xval:boolean);
begin

if      (iobj<>nil)                                                     then iobj.visb[xindex] :=xval
else if (xindex>=0) and (xindex<=high(ivisb)) and (xval<>ivisb[xindex]) then ivisb[xindex]     :=xval;

end;

function tfakeset.getvals(xindex:longint):boolean;
var
   a                  :tint4;
begin

if      (iobj<>nil)                           then result:=iobj.vals[xindex]
else if (xindex>=0) and (xindex<=high(icaps)) then
   begin

   a.val              :=yval;
   result             :=(xindex in a.bits);

   end

else begin

   result             :=false;

   end;

end;

procedure tfakeset.setvals(xindex:longint;xval:boolean);
var
   a                  :tint4;
   bol1               :boolean;

begin

if      (iobj<>nil)                           then iobj.vals[xindex] :=xval
else if (xindex>=0) and (xindex<=high(icaps)) then
   begin

   a.val              :=yval;
   bol1               :=(xindex in a.bits);

   if (bol1<>xval) then
      begin

      if xval then include(a.bits,xindex)
      else         exclude(a.bits,xindex);

      val             :=a.val;

      end;

   end;
end;

procedure tfakeset.ysetval(xval:longint32);
begin

ival:=xval;

end;

function tfakeset.ygetval:longint32;
begin

if (iobj<>nil) then result:=iobj.val
else                result:=ival;

end;

procedure tfakeset.setval(xval:longint);
begin

if (iobj<>nil) then iobj.val :=xval
else                setparams(idef,xval);

end;

procedure tfakeset.setparams(xdef,xval:longint);
begin

if (iobj<>nil) then iobj.setparams( xdef ,xval )
else setparams2(xdef,xval,0);

end;

procedure tfakeset.setparams2(xdef,xval,xitemsperline:longint);
begin

if (iobj<>nil) then iobj.setparams2( xdef ,xval ,iobj.itemsperline )
else if (xdef<>idef) or (xval<>yval) then
   begin

   idef                         :=xdef;

   if (yval<>xval) then yval    :=xval;

   end;

end;


//## tfakemenu #################################################################

constructor tfakemenu.create;
begin

//self
inherited create;

//vars
imenu                 :=nil;
icountx               :=0;
iitemindex            :=0;
ipos                  :=0;

end;

destructor tfakemenu.destroy;
begin

//nil

end;

procedure tfakemenu.setmenu(x:tbasicmenu);
begin

//check
if ((x=nil) and (imenu=nil)) or ((x<>nil) and (imenu<>nil)) then exit;

//connecting
if (x<>nil) then
   begin

   //on
   imenu              :=x;

   //get
   imenu.countx       :=icountx;
   imenu.itemindex    :=iitemindex;
   imenu.pos          :=ipos;

   end

//disconnecting
else begin

   //get
   icountx            :=imenu.countx;
   iitemindex         :=imenu.itemindex;
   ipos               :=imenu.pos;

   //off
   imenu              :=nil;

   end;

end;

function  tfakemenu.getcountx:longint32;
begin

case (imenu<>nil) of
true:result :=imenu.countx;
else result :=icountx;
end;//case

end;

procedure tfakemenu.setcountx(x:longint32);
begin

case (imenu<>nil) of
true:imenu.countx     :=x;
else icountx          :=frcmin32(x,0);
end;//case

end;

procedure tfakemenu.paintnow;
begin

if (imenu<>nil) then imenu.paintnow;

end;

function tfakemenu.getitemindex:longint32;
begin

case (imenu<>nil) of
true:result:=imenu.itemindex;
else result:=iitemindex;
end;//case

end;

procedure tfakemenu.setitemindex(x:longint32);
begin

case (imenu<>nil) of
true:imenu.itemindex  :=x;
else iitemindex       :=x;
end;//case

end;

function tfakemenu.getpos:longint32;
begin

case (imenu<>nil) of
true:result:=imenu.pos;
else result:=ipos;
end;//case

end;

procedure tfakemenu.setpos(x:longint32);
begin

case (imenu<>nil) of
true:imenu.pos        :=x;
else ipos             :=x;
end;//case

end;


//## tfolderbase ###############################################################

constructor tfolderbase.create(const xfolderhub:tfolderhub;const xname:string;const xoptionalcode:longint32);
begin

//self
inherited create;

//ouserfilename
ouserfilename         :='';//off - use with care


//name
iname                 :=io__safename( xname );//can be nil

if (iname<>'') then isubfolder  :=iname+'\'
else                isubfolder  :='';

//check
if (xfolderhub=nil) then
   begin

   showerror('Folder requires tfolderhub host');

   end;

//vars
ifolderhub            :=xfolderhub;
icode                 :=xoptionalcode;
imade                 :=false;//requires a call to one of the "make" procs to setup and enable the folder
itimer500X            :=slowms64;
iid                   :=1;//never zero
ifullcount            :=0;
isubcount             :=0;
isubbytes             :=0;
itep                  :=tepFolder20;
icolor                :=clNone;
imaskmode             :=mm_default;
ilastmaskmode         :=-1;
imaskCustom           :='';
imaskCustom2          :='';
imaskREF              :='';
imaskDefault          :='';
imasksimpleOK         :=false;
ilocked               :=false;
iupdateDoneFirst      :=false;

ilist                 :=tfakemenu.create;
imask                 :=tfakeset.create;

ifullbytes            :=0;//gradual -> access even when folder is not showing
ifullbytespos         :=0;
ifullbytesDONE        :=false;

isubbytes             :=0;
isublist              :=tdynamicinteger.create;

low__cls(@ilistval1,sizeof(ilistval1));
low__cls(@ilistval2,sizeof(ilistval2));

//add this folder to the folderhub -> hub takes ownership of the folder
ihubslot              :=ifolderhub.xnewslot( self );

//sub-proc
on__create;

end;

procedure tfolderbase.on__create;
begin

//nil

end;

function tfolderbase.on__cmd(const xcode2:string):boolean;
begin

//not handled
result      :=false;

end;

procedure tfolderbase.on__roottimer;
begin

//.itimer500
if (slowms64>=itimer500X) then
   begin

   //updatebuttons
   xupdatebuttons;

   //reset full bytes
   if xmustResetFullBytes then
      begin

      ifolderhub.xresetFullbytes;
      xresetFullBytes;

      end;

   //sync full bytes
   if not ifullbytesDONE then
      begin

      xincFullbytes;

      end;

   //save settings
   autosavesettings;

   //reset
   itimer500X:=add64( slowms64 ,low__aorb(100,500,iupdateDoneFirst) );

   end;

on__timer;

end;

procedure tfolderbase.on__timer;
begin

//nil

end;

procedure tfolderbase.on__destroy;
begin

//nil

end;

destructor tfolderbase.destroy;
begin
try

//save settings to file
autosavesettings;

//sub-proc
on__destroy;

//free
freeobj(@ilist);
freeobj(@imask);
freeobj(@isublist );

//self
inherited destroy;
if classnameis('tfolderbase') then track__inc(satOther,-1);

except;end;
end;

procedure tfolderbase.on__show(const xlist:tbasicmenu;const xmask:tbasicset;const xmaskbar:tbasictoolbar);
begin

//get
imaskbar              :=xmaskbar;
imask.obj             :=xmask;
ilist.menu            :=xlist;

//vars
imaskbar.enabled      :=imade;

//showing
ishowing              :=true;

//bringReady
bringReady( false );

end;

procedure tfolderbase.on__unshow;
begin

//not showing
ishowing              :=false;

//vars
ilist.menu            :=nil;
imask.obj             :=nil;
imaskbar              :=nil;

end;

function tfolderbase.canopenfolder:boolean;
begin

result      :=false;

end;

procedure tfolderbase.openfolder;
begin

//nil

end;

function  tfolderbase.canlock:boolean;
begin

result      :=not ilocked;

end;

procedure tfolderbase.lock;
begin

ilocked     :=true;

end;

procedure tfolderbase.unlock;
begin

ilocked     :=false;

end;

procedure tfolderbase.make(const xfullcount,xtep,xcolor:longint32;const xmaskDefault,xmaskSimple:string);
begin

//check
if imade then exit;

//get
ifullcount            :=frcmin32( xfullcount ,0 );
isubcount             :=0;
itep                  :=xtep;
icolor                :=xcolor;
imaskdefault          :=xmaskdefault;

isublist .setparams( ifullcount ,ifullcount ,0 );//fixed at this size

//fast.mask -> use a "simple" predefined mask here for speed - 25may2026
if (xmaskSimple<>'') then
   begin

   xmasksimple__setListOfFileExtensions( xmaskSimple );

   end;

//made
imade                 :=true;

//slow.mask => scan file list for file extensions to build mask
if (xmaskSimple='') then
   begin

   xfillWithMask;

   end;

//load settings
loadsettings;

end;

function tfolderbase.settingsFilename:string;
begin

result      :=app__folderSettings(true) + 'folder--'+iname + '.ini';

end;

procedure tfolderbase.loadsettings;
begin

if imade then
   begin

   setsettings( io__fromfilestr2( settingsFilename ) );

   isettingsREF       :=settings;

   end;

end;

procedure tfolderbase.savesettings;
begin

if imade then
   begin

   isettingsREF       :=settings;

   io__tofilestr2( settingsFilename ,isettingsREF );

   end;

end;

procedure tfolderbase.autosavesettings;
begin

if imade and low__setstr( isettingsREF ,settings ) then
   begin

   savesettings;

   end;

end;

function tfolderbase.settings:string;
var
   li,lp,p:longint;

   procedure i32(const n:string;const v:longint32);
   begin

   result:=result+n+': '+intstr32(v)+#10;

   end;

   procedure b(const n:string;const v:boolean);
   begin

   result:=result+n+': '+bolstr(v)+#10;

   end;

   procedure s(const n,v:string);
   begin

   result:=result+n+': '+v+#10;

   end;

begin

//defaults
result      :='';

//check
if not imade then exit;

//add values
i32('mask.set'       ,imask.val          );
i32('mask.mode'      ,longint32(imaskmode)              );
s  ('mask.custom'    ,low__tob64bstr( imaskCustom  ,0 ) );
s  ('mask.custom2'   ,low__tob64bstr( imaskCustom2 ,0 ) );

for p:=0 to longint32(high(tmaskmode)) do
begin

//.only if mask has been used -> list has not been setup to hold and position/selection so we can't read from it
if (p=ilastmaskmode) then
   begin

   li       :=ilist.itemindex;
   lp       :=ilist.pos;

   end
else begin

   li       :=ilistval1[p];
   lp       :=ilistval2[p];

   end;

i32( intstr32(p) + '.lindex'  ,li );
i32( intstr32(p) + '.lpos'    ,lp );

end;//p

end;

procedure tfolderbase.setsettings(const x:string);
var
   a:tvars8;
   p,xmustIndex:longint32;

begin

//check
if not imade then exit;

//defaults
a                     :=nil;

try

//init
a                     :=tvars8.create;
a.text                :=x;
xmustindex            :=-1;

//get
imask.val             :=a.idef('mask.set',max32);
imaskmode             :=tmaskmode(a.idef2('mask.mode',0,0,longint32(high(tmaskmode))));
imaskCustom           :=low__fromb64str( a.s['mask.custom' ] );
imaskCustom2          :=low__fromb64str( a.s['mask.custom2'] );


for p:=0 to longint32(high(tmaskmode)) do
begin

ilistval1[p]          :=a.i[ intstr32(p) + '.lindex' ];
ilistval2[p]          :=a.i[ intstr32(p) + '.lpos'   ];

if (p=longint32(imaskmode)) then
   begin

   xmustIndex         :=a.idef( intstr32(p) + '.lindex' ,-1 );//-1=signals that "index" has no value and should not be used - 06may2026

   end;

end;//p

//select file
if (xmustIndex>=0) and (ilist.itemindex<>xmustIndex) then
   begin

   ilist.itemindex    :=xmustIndex;

   end;

except;end;

//free
freeobj(@a);

end;

procedure tfolderbase.xfolder__ondbclick(sender:tobject);
begin

//check
if not imade                         then exit;
if not vidoubleclicks                then exit;

//get
if (sender is tbasicmenu)            then xcmd( (sender as tbasicmenu).tagstr );

end;

procedure tfolderbase.xfolder__onclick(sender:tobject);
begin

//check
if not imade                         then exit;

//turn off autoscroll
if (sender is tbasicmenu) then
   begin

   ifolderhub.noscroll;

   end;

//get
if      (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 )
else if (sender is tbasicjump)       then xcmd('jump.mustpos');

end;

function tfolderbase.xfolder__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   xfilesize          :longint32;
   xfiletep           :longint32;
   v                  :longint32;

begin

//defaults
result      :=true;
xtab        :='';//was ilistTab//????????????????

//get
xcaption    :=filename ( xindex ,0 );

if (xcaption='') then xcaption:='?';

xfilesize   :=filesize ( xindex ,0 );

//.merge tepcolor with current text color - 25may2026
v           :=filecolor( xindex ,0 );
if (v<>clnone) then
   begin

   xtepcolor:=int__splice24( 0.65 ,ifolderhub.info.mfont , v );

   end;

//.text image
xtep        :=filetep  ( xindex ,0 );

if (xtep=tepNone) then
   begin

   xtep     :=tep__filetype202(xcaption,tepEdit20);

   end;

//tab - optional
if (xtab<>'') then xcaplabel:=xcaption+#9+low__mbAUTO2( xfilesize ,1 ,true )
else               xcaplabel:=xcaption;

end;

procedure tfolderbase.xcmd(const xcode2:string);
label
   skipend;

var
   xresult:boolean;
   xwas,v32:longint32;
   v,e:string;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
xresult     :=true;
e           :=gecTaskfailed;
v           :='';
v32         :=0;

//check
if not imade then exit;

try

if on__cmd(xcode2) then
   begin

   //nil

   end

else if m('list.doubleclick') then
   begin

   if folderhub.canfilehub then
      begin

      folderhub.filehub.playToggle;

      end;

   end

else if mv('maskmode.') then
   begin

   xwas               :=longint32(imaskmode);
   imaskmode          :=tmaskmode(frcrange32(v32,0,longint32(high(tmaskmode))));

   //edit
   if (xwas=longint32(imaskmode)) then
      begin

      case imaskmode of
      mm_custom :ifolderhub.gui.poptxt4( imaskCustom  ,0 ,true ,false ,true ,'Custom Mask'   , ifolderhub.xhelpval2( 'maskmode.'+intstr32(longint32(imaskmode)) ,false ) ,'','','',1,0.5);
      mm_custom2:ifolderhub.gui.poptxt4( imaskCustom2 ,0 ,true ,false ,true ,'Custom Mask 2' , ifolderhub.xhelpval2( 'maskmode.'+intstr32(longint32(imaskmode)) ,false ) ,'','','',1,0.5);
      end;//case

      end;

   end

else begin

   //nil

   end;

skipend:

except;end;

//update
xupdatebuttons;

//sbow error
if not xresult then ifolderhub.gui.poperror('',e);

end;

function  tfolderbase.xmustResetFullBytes:boolean;
begin

result                :=false;

end;

procedure tfolderbase.xresetFullbytes;
begin

ifullbytes            :=0;
ifullbytespos         :=0;
ifullbytesDONE        :=false;

xsyncSubbytes;

end;

procedure tfolderbase.xincFullbytes;
var
   p                  :longint32;

begin

//check
if ifullbytesDONE then exit;

//get
for p:=1 to 5000 do
begin

if (ifullbytespos<ifullcount) then
   begin

   inc64( ifullbytes    ,full__filesize(ifullbytespos,0) );
   inc32( ifullbytespos ,1                               );

   end

else break;

end;//p

//finalise
ifullbytesDONE        :=ifullbytespos>=ifullcount;

end;

procedure tfolderbase.xmasksimple__setListOfFileExtensions(xmask:string);
var
   b,a:tdynamicstring;
   p:longint32;
   v:string;

begin

//defaults
a           :=nil;
b           :=nil;

//check
if imasksimpleOK then exit
else                  imasksimpleOK:=true;

try

//init
a           :=tdynamicstring.create;
b           :=tdynamicstring.create;

//filter
swapchars(xmask,';',#10);
low__remchar(xmask,'*');
low__remchar(xmask,'.');
low__remchar(xmask,#13);

//get
a.text      :=xmask;

for p:=0 to pred(a.count) do
begin

v           :=stripwhitespace_lt( a.value[p] );

if (v<>'') then
   begin

   v        :=io__readfileext_low( '.' + v );

   if (b.find( 0 ,v ,false )<=-1) then
      begin

      b.value[ b.count ]:=v;

      if (b.count>=32) then break;

      end;//b

   end;//v

end;//p

//set
if (b.count>=1) then
   begin

   //alpha sort
   b.sort( true );

   //get
   for p:=0 to pred(b.count) do
   begin

   imask.xset( p ,strup( b.svalue[p] ) ,strlow( b.svalue[p] ) ,'' ,true );//all on by default

   end;//p

   end;

except;end;

//free
freeobj(@a);
freeobj(@b);

end;

procedure tfolderbase.xfillWithMask;
label
   redo;

var
   xstatusStep        :longint32;
   p2                 :longint32;
   p                  :longint32;
   dcount             :longint32;
   xstatusref         :longint64;
   bol1               :boolean;
   xforcefast         :boolean;
   xstatusRunning     :boolean;
   n                  :string;
   mlastEXT           :string;
   xmask              :string;
   mlist              :tdynamicstring;

   //custom mask
   xmasklist          :array[0..99] of string;
   xmasklistCount     :longint32;

   procedure mAdd(const n:string);
   begin

   //fast check
   if (n=mlastEXT) then exit
   else                 mlastEXT:=n;
   //get

   if (mlist.count<=31) and (mlist.find( 0 ,n ,false )<=-1) then
      begin

      mlist.value[ mlist.count ]:=n;

      end;

   end;

   procedure dstart;
   begin

   ifolderhub.gui.xstatusstart(1.0,1);
   ifolderhub.gui.xstatustab(tbDefault);
   sysstatus_settext(0,'File'+#9+k64(1)+' of '+k64(ifullcount));
   ifolderhub.gui.xstatus(0,'Applying mask...');

   end;

   procedure dstatus;
   begin

   if (slowms64>=xstatusref) then
      begin

      if not xstatusRunning then
         begin

         xstatusRunning:=true;
         dstart;

         end;

      sysstatus_settext(0,'File'+#9+k64(p+1)+' of '+k64(ifullcount));
      sysstatus_setpert(low__percentage64(p+1,ifullcount));
      msset(xstatusref,100);

      end;

   end;

begin

//check
if not imade then exit;
if ilocked   then exit;

//init
xstatusRunning        :=false;
xstatusref            :=add64( ms64, 2000 );//status show delay
xstatusStep           :=0;
xmask                 :=mask;
mlist                 :=nil;
xforcefast            :=false;

//fill the "simple" mask list with file-list based values if not pre-filled from "make" - 25may2026
if not imasksimpleOK then
   begin

   //init
   if (mlist=nil) then mlist:=tdynamicstring.create
   else                mlist.clear;

   mlastEXT           :='';

   //get
   for p:=0 to pred(ifullcount) do
   begin

   n        :=io__readfileext_low( full__filename(p ,0) );

   if (n<>mlastEXT) then
      begin

      mlastEXT:=n;

      if (mlist.find( 0 ,n ,false )<=-1) then
         begin

         mlist.value[ mlist.count ]:=n;

         if (mlist.count>=32) then break;

         end;

      end;

   end;//p

   //set "simple" mask list
   xmasksimple__setListOfFileExtensions( mlist.text );

   end;

//store list info
if (ilastmaskmode>=0) then
   begin

   ilistval1[ilastmaskmode]     :=ilist.itemindex;
   ilistval2[ilastmaskmode]     :=ilist.pos;

   end;


try

//all files -> no check required -> fast ---------------------------------------
redo:

if xforcefast or (xmask='') or (xmask='*') or (xmask='*.*') then
   begin

   for p:=0 to pred(ifullcount) do
   begin

   isublist.items[ p ]:=p;

   end;//p

   isubcount          :=ifullcount;

   end


//include files via "simple" file extension mask check -> medium ---------------
else if (imaskmode=mm_simple) then
   begin

   //init
   xmasklistCount     :=0;

   //get list of active file extensions to compare against
   for p:=0 to pred(imask.count) do
   begin

   if imask.vals[ p ] then
      begin

      xmasklist[xmasklistCount]:=strlow( imask.nams[p] );

      inc( xmasklistCount );

      if (xmasklistCount>high(xmasklist)) then break;

      end;

   end;//p

   //check -> empty -> default back to fast method
   if (xmasklistCount<=0) then
      begin

      xforcefast:=true;//engage fast method

      goto redo;

      end;

   //apply "file extension" mask -----------------------------------------------

   //status stop
   ifolderhub.gui.xstatusstop;

   //init
   dcount             :=0;

   //get
   for p:=0 to pred(ifullcount) do
   begin

   //.optional status
   inc(xstatusStep,1);

   if (xstatusStep>=10000) then
      begin

      xstatusStep:=0;

      dstatus;

      //stopped
      if xstatusRunning and ifolderhub.gui.xstatustopped then
         begin

         break;

         end;

      end;

   //single line mask -> use no loop -------------------------------------------
   if (xmasklistCount<=1) then
      begin

      n               :=io__readfileext_low( full__filename(p ,0) );

      if (n='') or (n=xmasklist[0]) then//allow files with no extension through always (e.g. a folder name)
         begin

         isublist.items[ dcount ]:=p;

         inc(dcount);

         end;

      end

   //multi-line mask -> use a loop ---------------------------------------------
   else begin

      //init
      n               :=io__readfileext_low( full__filename(p ,0) );

      if (n='') then//allow files with no extension through always (e.g. a folder name)
         begin

         isublist.items[ dcount ]:=p;

         inc(dcount);

         end

      else begin

         //check file extension matches at least ONCE - 25may2026
         for p2:=0 to pred(xmasklistCount) do
         begin

         if (n=xmasklist[p2]) then
            begin

            isublist.items[ dcount ]:=p;

            inc(dcount);

            end;

         end;//p2

         end;

      end;

   end;//p

   //set
   isubcount          :=dcount;

   //status stop
   ifolderhub.gui.xstatusstop;

   end

//include files via mask check -> slow -----------------------------------------
else begin

   //read multi-line complex mask into "masklist" ------------------------------

   if (mlist=nil) then mlist:=tdynamicstring.create
   else                mlist.clear;//reuse object

   mlist.text         :=xmask;
   xmasklistCount     :=0;

   for p:=0 to pred(mlist.count) do
   begin

   xmasklist[xmasklistCount]    :=stripwhitespace_lt(mlist.value[p]);

   if (xmasklist[xmasklistCount]<>'') then
      begin

      inc( xmasklistCount );

      if (xmasklistCount>high(xmasklist)) then break;

      end;

   end;//p

   //check -> empty -> default back to fast method
   if (xmasklistCount<=0) then
      begin

      xforcefast:=true;//engage fast method

      goto redo;

      end;


   //apply mask ----------------------------------------------------------------

   //status stop
   ifolderhub.gui.xstatusstop;

   //init
   dcount             :=0;

   //get
   for p:=0 to pred(ifullcount) do
   begin

   //.optional status
   inc(xstatusStep,1);

   if (xstatusStep>=10000) then
      begin

      xstatusStep:=0;

      dstatus;

      //stopped
      if xstatusRunning and ifolderhub.gui.xstatustopped then
         begin

         break;

         end;

      end;

   //single line mask -> use no loop -------------------------------------------
   if (xmasklistCount<=1) then
      begin

      if filter__matchlist( full__filename(p ,0) ,xmasklist[0] ) then
         begin

         isublist.items[ dcount ]:=p;

         inc(dcount);

         end;

      end

   //multi-line mask -> use a loop ---------------------------------------------
   else begin

      //init
      bol1            :=true;
      n               :=full__filename(p ,0);

      //check filename against each line of the mask
      for p2:=0 to pred(xmasklistCount) do
      begin

      if not filter__matchlist( n ,xmasklist[p2] ) then
         begin

         bol1         :=false;
         break;

         end;

      end;//p2

      //add file
      if bol1 then
         begin

         isublist.items[ dcount ]:=p;

         inc(dcount);

         end;

      end

   end;//p


   //set
   isubcount          :=dcount;

   //status stop
   ifolderhub.gui.xstatusstop;

   end;

//sync
ilastmaskmode         :=longint32(imaskmode);
ilist.countx          :=isubcount;
ilist.itemindex       :=frcrange32( ilistval1[longint32(imaskmode)] ,0 ,pred(isubcount) );
ilist.pos             :=ilistval2[longint32(imaskmode)];

xsyncSubbytes;

//repaint
ilist.paintnow;

except;end;

//free
if (mlist<>nil) then freeobj(@mlist);

end;

procedure tfolderbase.xsyncSubbytes;
var
   v                  :longint64;
   p                  :longint32;
   xsubfile           :longint32;
   dfullindex         :longint32;
   flist              :tdynamicbyte;

begin

//defaults
flist                 :=nil;

try

//init
v                     :=0;
flist                 :=tdynamicbyte.create;
flist.setparams( ifullcount ,ifullcount ,0 );

//clear
for p:=0 to pred(ifullcount) do
begin

flist.items[p]        :=0;

end;//p

//get
for p:=0 to pred(isubcount) do
begin

for xsubfile:=0 to max32 do
begin

if findindex( p ,xsubfile ,dfullindex ) then
   begin

   if (flist.value[ dfullindex ]=0) then
      begin

      //inc bytes counter
      inc64( v ,filesize( p ,xsubfile ) );

      //mark as done
      flist.value[ dfullindex ] :=1;

      end;

   end

else break;

end;//subfile

end;//p

//set
isubbytes             :=v;

except;end;

//free
freeobj(@flist);

end;

procedure tfolderbase.xupdatebuttons;
var
   xmustRealign,bol1:boolean;
   p:longint32;

begin

//check
if (not imade) or (not ifolderhub.gui.paintfirst) or (not ifolderhub.gui.showing) then
   begin

   exit;

   end;

//defaults
iupdateDoneFirst      :=true;
xmustRealign          :=false;


//maskbar ----------------------------------------------------------------------

if ishowing then
   begin

   with imaskbar do
   begin

   for p:=0 to longint32(high(tmaskmode)) do
   begin

   bmarked2 ['maskmode.'+intstr32(p)]     :=(p=longint32(imaskmode));
   //bflash2  ['maskmode.'+intstr32(p)]     :=(p=imaskmode);

   end;//p

   end;//with

   end;


//other ------------------------------------------------------------------------

if ishowing then
   begin

   bol1               :=(imaskmode=mm_simple);

   if (bol1<>imask.visible) then
      begin

      imask.visible   :=bol1;
      xmustRealign    :=true;

      end;

   end;


//xmustRealign
if xmustRealign then
   begin

   ifolderhub.gui.fullalignpaint;

   end;


//fill with mask ---------------------------------------------------------------

//Note: Do last in-order to allow visual controls above to paint changes BEFORE
//      possibly entering into a lengthy mask operation.

//.pause for a short moment before applying when in "simple" mask mode - 25may2026

if (imaskmode<>mm_simple) or (not imask.focused) or (low__clickidle>=1000) then
   begin

   bringReady( false );

   end;

end;

procedure tfolderbase.bringReady(const xforce:boolean);//readies file list for content viewing/extraction

   function mref:string;
   begin

   result   :=intstr32(longint32(imaskmode))+'|'+mask;

   end;

begin

if ( xforce or ishowing ) and (imaskREF<>mref) then
   begin

   imaskREF :=mref;

   xfillWithMask;

   end;

end;

function  tfolderbase.maskmode:tmaskmode;
begin

result      :=imaskmode;

end;

procedure tfolderbase.setmaskmode(const xmaskmode:tmaskmode;const xforce:boolean);
begin

if (imaskmode<>xmaskmode) then
   begin

   imaskmode:=xmaskmode;
   bringReady( xforce );

   end;

end;

procedure tfolderbase.newID;
begin

if imade then rollid32( iid );

end;

function tfolderbase.itemindex:longint32;
begin

//get
result      :=ilist.itemindex;

//range
if      (result<0)          then result:=0
else if (result>=isubcount) then
   begin

   if (isubcount>=1)        then result:=pred(isubcount)
   else                          result:=0;

   end;

end;

procedure tfolderbase.setitemindex(const xsubindex:longint32);
begin

ilist.itemindex       :=frcrange32( xsubindex ,0 ,frcmin32( pred(isubcount),0 ) );

if ifolderhub.canfilehub then
   begin

   //load immedately to avoid timer delays/lag sync error
   ifolderhub.filehub.loadfileonce;

   end;

end;

function  tfolderbase.mask:string;
var
   p:longint32;

begin

if (imaskmode=mm_default) then
   begin

   result             :=imaskDefault;

   end

else if (imaskmode=mm_all) then
   begin

   result             :='';

   end

else if (imaskmode=mm_simple) then
   begin

   //init
   result             :='';

   //get
   for p:=0 to pred(imask.count) do
   begin

   if imask.vals[ p ] then result:=result + '*.' + imask.nams[ p ] + ';';

   end;//p

   end

else if (imaskmode=mm_custom) then
   begin

   result             :=imaskCustom;

   end

else if (imaskmode=mm_custom2) then
   begin

   result             :=imaskCustom2;

   end

else begin

   result             :='';

   end;

end;

function  tfolderbase.empty:boolean;
begin

result      :=(isubcount<=0);

end;

function  tfolderbase.full__cansubfileID(const xsubfileID:longint32):boolean;
begin

result      :=imade and (xsubfileID=0);

end;

function  tfolderbase.full__findindex(const xindex,xsubfileID:longint32;var dfullindex:longint32):boolean;
begin

result      :=imade and (xindex>=0) and (xindex<ifullcount) and (xsubfileID=0);
dfullindex  :=xindex;

end;

function  tfolderbase.full__havefile(const n:string):boolean;
var
   xindex:longint32;

begin

result      :=full__findfile( n ,xindex );

end;

function  tfolderbase.full__findfile(const n:string;var xindex:longint32):boolean;
var
   p:longint32;

begin

//defaults
result      :=false;
xindex      :=0;

//find
for p:=0 to pred(ifullcount) do
begin

if strmatch( n ,full__filename(p ,0) ) then
   begin

   xindex   :=p;
   result   :=true;

   break;

   end;

end;//p

end;

function  tfolderbase.full__filename(const xindex,xsubfileID:longint32):string;
begin

result      :='';

end;

function  tfolderbase.full__filesize(const xindex,xsubfileID:longint32):longint32;
var
   bol1     :boolean;

begin

result      :=full__filesize2( xindex ,xsubfileID ,bol1 );

end;

function  tfolderbase.full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;
begin

xisApproximate        :=false;
result                :=0;

end;

function  tfolderbase.full__fileext(const xindex,xsubfileID:longint32):string;
begin

result      :=io__readfileext_low( full__filename( xindex ,xsubfileID ) );

end;

function  tfolderbase.full__filetep(const xindex,xsubfileID:longint32):longint32;
begin

result      :=tep__filetype202( full__filename( xindex ,xsubfileID ) ,tepEdit20 );

end;

function  tfolderbase.full__filecolor(const xindex,xsubfileID:longint32):longint32;
begin

result      :=clNone;

end;

function  tfolderbase.full__filetext(const xindex,xsubfileID:longint32):string;
var
   a:tstr8;
begin

//defaults
result      :='';
a           :=nil;

try

//init
a           :=rescache__newStr8;

//get
if full__fromfile( xindex ,xsubfileID ,a ) then
   begin

   result   :=a.text;

   end;

except;end;

//free
rescache__delStr8( @a );

end;

function  tfolderbase.full__fromfile(const xindex,xsubfileID:longint32;const xdata:tstr8):boolean;
begin

result      :=false;

if (xdata<>nil) then xdata.clear;

end;

function  tfolderbase.full__savefile(const dindex:longint32;const dfilename:string;var wbytes:longint32):boolean;
var
   fdata:tstr8;
   e:string;

begin

//defaults
result                :=false;
wbytes                :=0;

//get
if imade and (dindex>=0) and (dindex<ifullcount) and (dfilename<>'') then
   begin

   //defaults
   fdata              :=nil;

   try

   //init
   fdata              :=rescache__newStr8;

   //get
   result             :=full__fromfile( dindex ,0 ,fdata ) and io__tofile( dfilename ,@fdata ,e );

   if result then
      begin

      wbytes          :=fdata.len32;//bytes written

      end;

   except;end;

   //free
   rescache__delStr8( @fdata );

   end;

end;

function  tfolderbase.full__toanimation(const xwantSize,xindex,xsubfileID:longint32;const ximage:tcommonimage):boolean;
begin

result      :=false;

end;

function  tfolderbase.full__toanimationinfo(const xwantSize,xindex,xsubfileID:longint32;var x:tanimationinfo):boolean;
begin

result      :=false;
low__cls(@x,sizeof(x));

end;

function  tfolderbase.full__toanimationcell(const xwantSize,xindex,xsubfileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean;
begin

result      :=false;

end;

function tfolderbase.full__datatype(const xindex,xsubfileID:longint32):tdatatype;
var
   v:string;

   function m(const n:string):boolean;
   begin

   result   :=strmatch( v ,n );

   end;

begin

//get
case full__itemtype( xindex ,xsubfileID ) of

it_folder:begin

   result   :=dt_folder

   end;

it_file:begin

   v        :=full__fileext ( xindex ,xsubFileID );

   //decide
   if   m('txt') or m('bwd') or m('bwp') or m('rtf') or
        m('bat') or m('log') or m('md')  or m('ini') then result:=dt_text

   else if m('pic8')                                 then result:=dt_sprite

   else if m('cur') or m('ani')                      then result:=dt_cursor//14jun2026

   else if io__imageExtSupported(v)                  then result:=dt_image

   else if m('mid') or m('midi') or m('rmi')         then result:=dt_midi

   else if m('wav') or m('mp3')  or m('mp4')         then result:=dt_music

   else if m('inf')                                  then result:=dt_cursorScheme//27may2026

   else                                                   result:=dt_binary;

   end;

else begin

   result   :=dt_none;

   end;

end;//case

end;

function tfolderbase.full__itemtype(const xindex,xsubfileID:longint32):titemtype;
begin
                                          //isubcount<=0 => folder is empty
if (xindex>=0) and (xindex<ifullcount) and (isubcount>=1) and full__cansubfileID(xsubfileID) then result:=it_file
else                                                                                              result:=it_none;

end;

function  tfolderbase.full__isfile(const xindex,xsubfileID:longint32):boolean;
begin

result      :=( full__itemtype( xindex ,xsubfileID ) = it_file );

end;

function  tfolderbase.full__isfolder(const xindex,xsubfileID:longint32):boolean;
begin

result      :=( full__itemtype( xindex ,xsubfileID ) = it_folder );

end;

function  tfolderbase.full__folderindex(const xindex,xsubfileID:longint):longint32;
begin

result      :=0;

end;

function tfolderbase.xsubTOfull(const xindex:longint32):longint32;
begin

//low bounds error
if (xindex<0) then
   begin

   result   :=0;

   end

//high bounds error
else if (xindex>=isubcount) then
   begin

   if (isubcount>=1) then result:=pred(isubcount)
   else                   result:=0;

   end

//all files are visible -> no mapping required
else if (isubcount>=ifullcount) then
   begin

   result   :=xindex;

   end

//subset of files are visible -> map via isublist
else begin

   result   :=isublist.items[ xindex ];

   end;

end;

function  tfolderbase.cansubfileID(const xsubfileID:longint32):boolean;
begin

result      :=full__cansubfileID( xsubfileID );

end;

function  tfolderbase.cansubfile(const xsubFileID:longint32):boolean;//18jun2026 - file specific testing
var
   dfullindex         :longint32;

begin

result      :=findindex( itemindex ,xsubfileid ,dfullindex );

end;

function  tfolderbase.findindex(const xsubindex,xsubfileID:longint32;var dfullindex:longint32):boolean;
begin

result      :=full__findindex( xsubTOfull(xsubindex) ,xsubfileID ,dfullindex );

end;

function  tfolderbase.havefile(const n:string):boolean;
var
   xsubindex:longint32;

begin

result      :=findfile( n ,xsubindex );

end;

function  tfolderbase.findfile(const n:string;var xsubindex:longint32):boolean;
var
   p:longint32;

begin

//defaults
result      :=false;
xsubindex   :=0;

//find
for p:=0 to pred(isubcount) do
begin

if strmatch( n ,filename(p ,0) ) then
   begin

   xsubindex:=p;
   result   :=true;

   break;

   end;

end;//p

end;

function  tfolderbase.filename(const xsubindex,xsubfileID:longint32):string;
begin

result      :=full__filename( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.filesize(const xsubindex,xsubfileID:longint32):longint32;
var
   bol1     :boolean;

begin

result      :=filesize2( xsubindex ,xsubfileID ,bol1 );

end;

function  tfolderbase.filesize2(const xsubindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;
begin

result                :=full__filesize2( xsubTOfull(xsubindex) ,xsubfileID ,xisApproximate );

end;

function  tfolderbase.fileext(const xsubindex,xsubfileID:longint32):string;
begin

result      :=full__fileext( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.filetep(const xsubindex,xsubfileID:longint32):longint32;
begin

result      :=full__filetep( xsubTOfull(xsubindex) ,xsubfileID );

if (result=tepNone) then
   begin

   result   :=tep__filetype202( filename( xsubindex ,xsubfileID ) ,tepEdit20 );

   end;

end;

function  tfolderbase.filecolor(const xsubindex,xsubfileID:longint32):longint32;
begin

result      :=full__filecolor( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.filetext(const xsubindex,xsubfileID:longint32):string;
begin

result      :=full__filetext( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.fromfile(const xsubindex,xsubfileID:longint32;const xdata:tstr8):boolean;
begin

result      :=full__fromfile( xsubTOfull(xsubindex) ,xsubfileID ,xdata );

end;

function  tfolderbase.toanimation(const xwantSize,xsubindex,xsubfileID:longint32;const ximage:tcommonimage):boolean;
begin

result      :=full__toanimation( xwantSize ,xsubTOfull(xsubindex) ,xsubfileID ,ximage );

end;

function tfolderbase.toanimationinfo(const xwantSize,xsubindex,xsubFileID:longint32;var x:tanimationinfo):boolean;
begin

result      :=full__toanimationinfo( xwantSize ,xsubTOfull(xsubindex) ,xsubfileID ,x );

end;

function tfolderbase.toanimationcell(const xwantSize,xsubindex,xsubfileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean;
begin

result      :=full__toanimationcell( xwantSize ,xsubTOfull(xsubindex) ,xsubfileID ,xcellindex ,ximage );

end;

function tfolderbase.datatype(const xsubindex,xsubfileID:longint32):tdatatype;
begin

result      :=full__datatype( xsubTOfull(xsubindex) ,xsubfileID  );

end;

function tfolderbase.itemtype(const xsubindex,xsubfileID:longint32):titemtype;
begin

result      :=full__itemtype( xsubTOfull(xsubindex) ,xsubfileID  );

end;

function  tfolderbase.isfile(const xsubindex,xsubfileID:longint32):boolean;
begin

result      :=full__isfile( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.isfolder(const xsubindex,xsubfileID:longint32):boolean;
begin

result      :=full__isfolder( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.folderindex(const xsubindex,xsubfileID:longint):longint32;
begin

result      :=full__folderindex( xsubTOfull(xsubindex) ,xsubfileID );

end;

function  tfolderbase.savefile(const dsubindex:longint32;const dfilename:string;var wbytes:longint32):boolean;
begin

result      :=full__savefile( xsubTOfull(dsubindex) ,dfilename ,wbytes );

end;

function tfolderbase.cannextFile:boolean;
begin

result      :=imade and (subcount>=1);

end;

procedure tfolderbase.nextFile;
var
   i:longint32;

begin

if cannextFile then
   begin

   //get
   i        :=itemindex + 1;

   if (i>=subcount) then i:=0;

   //set
   setitemindex( i );

   end;

end;

function tfolderbase.canprevFile:boolean;
begin

result      :=imade and (subcount>=1);

end;

procedure tfolderbase.prevFile;
var
   i:longint32;

begin

if canprevFile then
   begin

   //get
   i        :=itemindex - 1;

   if (i<0) then i:=pred(subcount);

   //set
   setitemindex( i );

   end;

end;


//## tfoldertest ###############################################################

procedure tfoldertest.on__create;
begin

make( 10000 ,tepFolder20 ,clnone ,'' ,'*.txt' );

end;

function  tfoldertest.full__filename(const xindex,xsubfileID:longint32):string;
begin

result   :='test-file-'+intstr32(1+xindex)+'.txt';

end;

function  tfoldertest.full__filesize(const xindex,xsubfileID:longint32):longint32;
begin

result   :=9;

end;

function  tfoldertest.full__filetep(const xindex,xsubfileID:longint32):longint32;
begin

result      :=tepEdit20;

end;

function  tfoldertest.full__filecolor(const xindex,xsubfileID:longint32):longint32;
begin

result      :=clYellow;

end;

function  tfoldertest.full__fromfile(const xindex,xsubfileID:longint32;const xdata:tstr8):boolean;
begin

//defaults
result      :=true;

//get
if (xdata<>nil) then
   begin

   xdata.clear;
   xdata.sadd('Test data');

   end;

end;


//## tfolderarchive ############################################################

procedure tfolderarchive.on__create;
var
   xdatalen,xorgSize,fc,p:longint32;
   xdata:pointer;
   xcompressed:boolean;
   xpathname:string;

begin

//init
fc          :=0;

//get
for p:=0 to max32 do
begin

if archiveFiles.storage__findfile( p,xdata,xdatalen,xorgSize,xcompressed,xpathname) then
   begin

   fc       :=p + 1;

   end

else break;

end;//p

//set
make( fc ,tepFolder20 ,clnone ,'' ,'' );

end;

function  tfolderarchive.full__filename(const xindex,xsubfileID:longint32):string;
var
   xdatalen,xorgSize:longint32;
   xdata:pointer;
   xcompressed:boolean;

begin

if (not imade) or (not full__cansubFileID(xsubfileID)) or (not archiveFiles.storage__findfile( xindex ,xdata ,xdatalen ,xorgSize ,xcompressed ,result )) then
   begin

   result   :='';

   end;

end;

function  tfolderarchive.full__filesize(const xindex,xsubfileID:longint32):longint32;
var
   bol1               :boolean;

begin

result                :=full__filesize2(xindex,xsubfileID,bol1);

end;

function  tfolderarchive.full__filesize2(const xsubindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;//30aug2026
var
   xdatalen           :longint32;
   xdata              :pointer;
   xcompressed        :boolean;
   xpathname          :string;

begin

xisApproximate        :=false;

if (not imade) or (not full__cansubFileID(xsubfileID)) or  (not archiveFiles.storage__findfile( xsubindex ,xdata ,xdatalen ,result ,xcompressed ,xpathname )) then
   begin

   result   :=0;

   end;

end;

function  tfolderarchive.full__filetep(const xindex,xsubfileID:longint32):longint32;
begin

result      :=tep__filetype202( full__filename( xindex ,xsubfileID ) ,tepEdit20 );

end;

function  tfolderarchive.full__filecolor(const xindex,xsubfileID:longint32):longint32;
begin

result      :=clNone;

end;

function  tfolderarchive.full__fromfile(const xindex,xsubfileID:longint32;const xdata:tstr8):boolean;
var
   xdatalen,xorgsize:longint32;
   pdata:pointer;
   xcompressed:boolean;
   xpathname:string;

begin

//defaults
result      :=false;

//clear
if (xdata<>nil) then xdata.clear
else                 exit;

//get
if imade and full__cansubFileID(xsubfileID) and archiveFiles.storage__findfile( xindex ,pdata ,xdatalen ,xorgsize ,xcompressed ,xpathname ) then
   begin

   result   :=xdata.addrec( pdata ,xdatalen ) and ( (not xcompressed) or low__decompress(@xdata) );

   //clear on error
   if not result then xdata.clear;

   end;

end;


//## tfoldercursor #############################################################

procedure tfoldercursor.on__create;
begin

icursorclass          :=int__cursorclass( icode );//safe range
iclassname            :=cursor__classname( icursorclass );

case icursorclass of
ccl_default :icore    :=tmakecursordefault.create;
ccl_modern  :icore    :=tmakecursormodern.create;
end;//case

ilast_usepng          :=cursor_usepng;

end;

procedure tfoldercursor.on__destroy;
begin

freeobj(@icore);

end;

function  tfoldercursor.xmustResetFullBytes:boolean;
begin

result                :=(ilast_usepng<>cursor_usepng);

if result then
   begin

   ilast_usepng       :=cursor_usepng;

   end;

end;

procedure tfoldercursor.nmake(cc_index,ca_index,ct_index,xtepcolor:longint32);
const
   xsep               ='.';

begin

//filter
if (xtepcolor=clnone) then
   begin

   xtepcolor          :=clRed;

   end;

//get
icore.make(
 intstr32(cc_index)  + xsep +
 intstr32(ca_index)  + xsep +
 intstr32(ct_index)  + xsep +
 intstr32(xtepcolor)
 );

icolor                :=xtepcolor;

end;

procedure tfoldercursor.nfinish;
begin

icore.finish;
                                                                   //pre-fill for max-speed
make( icore.filecount ,tepFolder20 ,icolor ,'*.inf' ,'*.inf;*.cur;*.ani' );

end;

procedure tfoldercursor.test__mapping;//13jun2026
var
   s        :longint32;
   d        :longint32;
   x        :tmakelookup;
   y        :tmakecursorinfo;
   z        :tcursorbase;
   lcount   :longint32;
   hcount   :longint32;

   function xmsg(const ecount:longint32):string;
   begin

   case (ecount<=0) of
   true:result:='passed';
   else result:='failed with '+k64(ecount)+' errors';
   end;//case

   end;

begin

//defaults
lcount      :=0;
hcount      :=0;

//low mapping scan
for s:=0 to pred(icore.filecount) do
begin

if icore.info__fromint32( s ,x ) then
   begin

   d        :=icore.info__int32( x );

   if (s<>d) then
      begin

      inc( lcount );

      end;

   end
else begin

   inc( lcount );

   end;


end;//p

//high mapping scan
for s:=0 to pred(icore.filecount) do
begin

if icore.cur__fromint32( s ,y ,z ) then
   begin

   d        :=icore.cur__int32( y );

   if (s<>d) then
      begin

      inc( hcount );

      end;

   end
else begin

   inc( hcount );

   end;

end;//p


//show results
showtext(
'-- Test Results --' + rcode +
'records tested: ' + k64(icore.filecount) + rcode +
'low mapping: '  + xmsg(lcount) + rcode +
'high mapping: ' + xmsg(hcount) + rcode +
'');

end;

function  tfoldercursor.full__cansubFileID(const xsubfileID:longint32):boolean;
begin

result      :=(xsubfileID>=0) and (xsubfileID<=cf_max);

end;

function  tfoldercursor.full__findindex(const xindex,xsubfileID:longint32;var dfullindex:longint32):boolean;
var
   x        :tmakecursorinfo;
   y        :tcursorbase;

begin

//defaults
result                :=imade and (xindex>=0) and (xindex<ifullcount) and (xsubfileID>=0) and (xsubfileID<=cf_max);
dfullindex            :=xindex;

//get
if result and (xsubfileID<>0) then
   begin

   //subfiles are permitted to branch off from the master file -> ".inf" -> Cursor Scheme file
   if icore.cur__fromint32( xindex ,x ,y ) and (x.cf=cf_install) then
      begin

      x.cf            :=xsubfileID;

      dfullindex      :=icore.cur__int32( x );

      end

   //file is not the master file -> do not allow branching
   else begin

      result          :=false;

      end;

   end;

end;

function  tfoldercursor.full__filename(const xindex,xsubfileID:longint32):string;
var
   dindex:longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   if (ouserfilename<>'') then
      begin

      icore.userfilename        :=ouserfilename;
      result                    :=icore.filename( dindex );
      icore.userfilename        :='';

      end

   else begin

      result                    :=icore.filename( dindex );

      end;

   end

else begin

   result:='';

   end;

end;

function  tfoldercursor.full__filesize(const xindex,xsubfileID:longint32):longint32;
var
   dindex:longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   result   :=icore.filesize( dindex );

   end

else begin

   result:=0;

   end;

end;

function  tfoldercursor.full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;
var
   dindex:longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   result             :=icore.filesize2( dindex ,xisApproximate );

   end

else begin

   xisApproximate     :=false;
   result             :=0;

   end;

end;

function  tfoldercursor.full__filetep(const xindex,xsubfileID:longint32):longint32;
var
   n:string;

begin

n           :=full__fileext( xindex ,xsubfileID );

if (n='cur') or (n='ani') then
   begin

   result   :=tepCursor20

   end

else if (n='inf') then
   begin

   result   :=tepCursorScheme20;

   end

else begin

   result   :=inherited full__filetep( xindex ,xsubfileID );

   end;

end;

function  tfoldercursor.full__filecolor(const xindex,xsubfileID:longint32):longint32;
var
   dindex   :longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   result:=icore.filecolor( dindex );

   end

else result:=clnone;

end;

function  tfoldercursor.full__fromfile(const xindex,xsubfileID:longint32;const xdata:tstr8):boolean;
var
   dindex:longint32;

begin

//defaults
result      :=false;

//clear
if (xdata<>nil) then xdata.clear
else                 exit;

//get
if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   //get
   if (ouserfilename<>'') then
      begin

      icore.userfilename        :=ouserfilename;
      result                    :=icore.fromfile( dindex ,xdata );
      icore.userfilename        :='';

      end

   else begin

      result                    :=icore.fromfile( dindex ,xdata );

      end;

   //clear on error
   if not result then xdata.clear;

   end;

end;

function  tfoldercursor.full__toanimation(const xwantSize,xindex,xsubfileID:longint32;const ximage:tcommonimage):boolean;
var
   dindex:longint32;

begin

//defaults
result      :=false;

//check
if (ximage=nil) then exit;

//get
if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   //get
   result   :=icore.toanimation( xwantSize ,dindex ,ximage );

   end;

end;

function tfoldercursor.full__toanimationinfo(const xwantSize,xindex,xsubfileID:longint32;var x:tanimationinfo):boolean;
var
   dindex:longint32;

begin

//defaults
result      :=false;

//get
if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   //get
   result   :=icore.toanimationinfo( xwantSize ,dindex ,x );

   end;

end;

function tfoldercursor.full__toanimationcell(const xwantSize,xindex,xsubfileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean;
var
   dindex:longint32;

begin

//defaults
result      :=false;

//check
if (ximage=nil) then exit;

//get
if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   //get
   result   :=icore.toanimationcell( xwantSize ,dindex ,xcellindex ,ximage );

   end;

end;


//## tfolderwallpaper ##########################################################
procedure tfolderwallpaper.on__create;
begin

icore                 :=tmakewallpaper.create;

end;

procedure tfolderwallpaper.on__destroy;
begin

freeobj( @icore );

end;

procedure tfolderwallpaper.makelist(const xtepColor:longint32;const wemList:string);
begin

icore.makelist( wemList );
                                                               //pre-fill for max-speed
make( icore.file__count ,tepFolder20 ,xtepColor ,'*.jpg;*.png;' ,'*.jpg;*.png;' );

end;

function tfolderwallpaper.full__datatype(const xindex,xsubfileID:longint32):tdatatype;
begin

result      :=inherited full__datatype(xindex,xsubfileID);

//override
if (result=dt_image) then
   begin

   result   :=dt_wallpaper;//engages more detailed toolbar options, e.g. wallpaper based effects editing - 04sep2026

   end;

end;

function  tfolderwallpaper.full__cansubFileID(const xsubfileID:longint32):boolean;
begin

result      :=(xsubfileID=0);

end;

function  tfolderwallpaper.full__findindex(const xindex,xsubfileID:longint32;var dfullindex:longint32):boolean;
begin

//defaults
result                :=imade and (xindex>=0) and (xindex<ifullcount) and (xsubfileID=0);
dfullindex            :=xindex;

end;

function  tfolderwallpaper.full__filename(const xindex,xsubfileID:longint32):string;
var
   dindex:longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   result   :=icore.file__name( dindex );

   end

else begin

   result:='';

   end;

end;

function  tfolderwallpaper.full__filesize(const xindex,xsubfileID:longint32):longint32;
var
   xisApproximate     :boolean;

begin

result                :=full__filesize2( xindex ,xsubfileID ,xisApproximate );

end;

function  tfolderwallpaper.full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;
var
   dindex             :longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   result             :=icore.file__size2( dindex ,xisApproximate );

   end

else begin

   xisApproximate     :=false;
   result             :=0;

   end;

end;

function  tfolderwallpaper.full__filecolor(const xindex,xsubfileID:longint32):longint32;
var
   dindex:longint32;

begin

if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   result   :=clred;

   end

else result:=clnone;

end;

function  tfolderwallpaper.full__fromfile(const xindex,xsubfileID:longint32;const xdata:tstr8):boolean;
var
   dindex             :longint32;

begin

//defaults
result      :=false;

//clear
if (xdata<>nil) then xdata.clear
else                 exit;

//get
if imade and full__findindex( xindex, xsubfileID ,dindex ) then
   begin

   //get
   result             :=icore.file__data( dindex ,xdata );

   //clear on error
   if not result then xdata.clear;

   end;

end;


//## tfolderhome ###############################################################

procedure tfolderhome.on__create;
begin

isubfolder  :='';//no subfolder for "home" -> we are the root folder
ihub        :=nil;
fcount      :=0;

end;

function  tfolderhome.on__cmd(const xcode2:string):boolean;
var
   dfullindex:longint32;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
result      :=false;//not handled
dfullindex  :=xsubTOfull( itemindex );

//check
if (not imade) or (dfullindex<0) or (dfullindex>ifullcount) then exit;

//get
if m('list.doubleclick') then
   begin

   if (flist[dfullindex].folderIndex>=0) and (ihub<>nil) then
      begin

      result          :=true;//handled
      ihub.setfolderindex( flist[dfullindex].folderIndex );

      end;

   end;

end;

function tfolderhome.canopenfolder:boolean;
var
   dfullindex         :longint32;
begin

if imade then
   begin

   //init
   dfullindex         :=xsubTOfull( itemindex );

   //get
   result             :=(dfullindex>=0) and (dfullindex<ifullcount) and (flist[dfullindex].folderIndex>=0) and (ihub<>nil);

   end
else begin

   result             :=false;

   end;

end;

procedure tfolderhome.openfolder;
var
   dfullindex         :longint32;
begin

if canopenfolder then
   begin

   //init
   dfullindex         :=xsubTOfull( itemindex );

   //get
   if (dfullindex>=0) and (dfullindex<ifullcount) and (flist[dfullindex].folderIndex>=0) and (ihub<>nil) then
      begin

      ihub.setfolderindex( flist[dfullindex].folderIndex );

      end;

   end;

end;

procedure tfolderhome.finish(const xhub:tfolderhub);//locks in file count etc
var
   p                  :longint32;

   function fdatacheck(const fdata:tstr8;var dext:string):boolean;
   begin

   //defaults
   result   :=false;
   dext     :='';

   //check
   if (fdata=nil) then exit;

   //get
   dext     :=io__anyformatb( @fdata );

   if strmatch(dext,'zip') then
      begin

      low__decompress( @fdata );

      end;

   //set
   dext     :=strlow(strdefb( io__anyformatb( @fdata ) ,'txt' ));
   result   :=(fdata.len32>=10);

   end;

   procedure fadd(const xname:string;const xtep,xcolor,xfolderIndex:longint;const xdata:string;const xfolder:tfolderbase);
   begin

   if (fcount<=high(flist)) then
      begin

      flist[fcount].name        :=xname;
      flist[fcount].tep         :=xtep;
      flist[fcount].color       :=xcolor;
      flist[fcount].data        :=xdata;
      flist[fcount].size        :=low__len32( xdata );
      flist[fcount].folderIndex :=xfolderIndex;
      flist[fcount].folder      :=xfolder;

      inc( fcount );

      end;

   end;

   procedure faddSysFile(const xfilename:string);
   var
      fdata           :string;

   begin

   if (xfilename<>'') and ifolderhub.archivefiles__fromfile( xfilename ,fdata ) then
      begin

      fadd( xfilename ,tepNone ,clnone ,-1 ,fdata ,nil );

      end;

   end;

begin

//folder list
if (xhub<>nil) then
   begin

   //init
   ihub     :=xhub;

   //system files -> folderhub has already looked them up -> use their filenames
   faddSysFile( insstr( ihub.sysfile_about   ,ihub.sysfile_aboutOK   ) );
   faddSysFile( insstr( ihub.sysfile_license ,ihub.sysfile_licenseOK ) );
   faddSysFile( insstr( ihub.sysfile_readme  ,ihub.sysfile_readmeOK  ) );

   //get
   for p:=0 to pred( ihub.foldercount ) do
   begin

   if (self<>ihub.folder(p)) and (fcount<=high(flist)) then
      begin

      fadd( ihub.folder(p).name ,ihub.folder(p).tep ,ihub.folder(p).color ,p ,'' ,ihub.folder(p) );

      end;

   end;//p

   end;

//set
make( fcount ,tepHome20 ,clNone ,'' ,'' );

end;

function  tfolderhome.full__filename(const xindex,xsubfileID:longint32):string;
begin

if full__cansubfileID(xsubfileID) and (xindex>=0) and (xindex<fcount) then result:=flist[xindex].name
else                                                                       result:='';

end;

function  tfolderhome.full__filesize(const xindex,xsubfileID:longint32):longint32;
begin

if full__cansubfileID(xsubfileID) and (xindex>=0) and (xindex<fcount) then result:=flist[xindex].size
else                                                                       result:=0;

end;

function  tfolderhome.full__filesize2(const xindex,xsubfileID:longint32;var xisApproximate:boolean):longint32;//30jul2026
begin

xisApproximate        :=false;
result                :=full__filesize( xindex ,xsubfileID );

end;

function  tfolderhome.full__filetep(const xindex,xsubfileID:longint32):longint32;
begin

if full__cansubfileID(xsubfileID) and (xindex>=0) and (xindex<fcount) then result:=flist[xindex].tep
else                                                                       result:=tepNone;

end;

function  tfolderhome.full__filecolor(const xindex,xsubfileID:longint32):longint32;
begin

if full__cansubfileID(xsubfileID) and (xindex>=0) and (xindex<fcount) then result:=flist[xindex].color
else                                                                       result:=clnone;

end;

function  tfolderhome.full__fromfile(const xindex,xsubfileID:longint32;const xdata:tstr8):boolean;
begin

if full__cansubfileID(xsubfileID) and (xindex>=0) and (xindex<fcount) and (xdata<>nil) then
   begin

   result   :=true;

   xdata.clear;

   if (flist[xindex].data<>'') then
      begin

      xdata.sadd( flist[xindex].data );

      end;

   end

else result :=false;

end;

function tfolderhome.full__itemtype(const xindex,xsubfileID:longint):titemtype;
begin

if (xindex>=0) and (xindex<fcount) and (xsubfileID=0) then
   begin

   if (flist[xindex].folderIndex>=0) then result:=it_folder
   else                                   result:=it_file;

   end

else result :=it_none;

end;

function tfolderhome.full__folderindex(const xindex,xsubfileID:longint):longint32;
begin

if full__cansubfileID(xsubfileID) and (xindex>=0) and (xindex<fcount) then result:=flist[xindex].folderIndex
else                                                                       result:=0;

end;


//## tfilehub ##################################################################

constructor tfilehub.create2(xparent:tobject;xscroll,xstart:boolean);
begin

//self
if classnameis('tfilehub') then track__inc(satOther,1);
inherited create2(xparent,false,false);

//vars
bordersize            :=0;
oautoheight           :=true;
oclsarea              :=true;//is set to false via "nfinish" when there are 1 or more attached file viewers
istarted              :=false;
itimer100             :=slowms64;
itimer500             :=slowms64;
isettingsREF          :='';
ifirstload            :=true;
ifolderhub            :=nil;
imasterplaying        :=false;
fonsync               :=nil;
iwallpaper_changeId   :=0;

//controls


//sub-proc
on__create;

//events

end;

procedure tfilehub.on__create;
begin

//nil

end;

procedure tfilehub.on__destroy;
begin

//nil

end;

destructor tfilehub.destroy;
begin
try

//save settings to file
autosavesettings;

//sub-proc
on__destroy;

//self
inherited destroy;
if classnameis('tfilehub') then track__inc(satOther,-1);

except;end;
end;

procedure tfilehub.start(const xhub:tfolderhub);
begin

//check
if not (xhub is tfolderhub) then exit
else if istarted            then exit
else if (xhub=nil)          then exit
else begin

   istarted           :=true;
   ifolderhub         :=xhub;

   end;

//folder
nfolder('');

//append a blank fileviewer -> used for unsupported files
nblank('');

//point to blank by default
pageindex   :=pred(fcount);

//loadsettings
loadsettings;

//start
inherited start;

end;

function  tfilehub.folderisempty:boolean;
begin

result      :=(not canfolderhub) or folderhub.folderisempty;

end;

function  tfilehub.canopenfolder:boolean;
begin

result      :=canfolderhub and folderhub.canopenfolder;

end;

procedure tfilehub.openfolder;
begin

if canopenfolder then
   begin

   folderhub.openfolder;

   end;

end;

function  tfilehub.canopenhome:boolean;
begin

result      :=canfolderhub and folderhub.canopenhome;

end;

procedure tfilehub.openhome;
begin

if canopenhome then
   begin

   folderhub.openhome;

   end;

end;

function tfilehub.fetchImage(var x:tcommonimage):boolean;
begin

//defaults
result      :=false;
x           :=nil;

//get
if (fileCurrent<>nil) then
   begin

   result   :=fileCurrent.fetchImage( x );

   end;

end;

function tfilehub.fetchImageView(var x:tbasicimgview):boolean;
begin

//defaults
result      :=false;
x           :=nil;

//get
if (fileCurrent<>nil) then
   begin

   result   :=fileCurrent.fetchImageView( x );

   end;

end;

function tfilehub.fetchTextBox(var x:tbasicbwp):boolean;
begin

//defaults
result      :=false;
x           :=nil;

//get
if (fileCurrent<>nil) then
   begin

   result   :=fileCurrent.fetchTextBox( x );

   end;

end;

function tfilehub.canfolderhub:boolean;
begin

result      :=(ifolderhub<>nil);

end;

function tfilehub.folderhub:tfolderhub;
begin

result      :=ifolderhub;

end;

procedure tfilehub.setfolderhub(const x:tfolderhub);
begin

ifolderhub            :=x;

end;

function  tfilehub.nblank(const xname:string):tfileblank;
begin

result      :=tfileblank.create( client, strdefb(xname,'Blank') );

xaddfile( result );

end;

function  tfilehub.nfolder(const xname:string):tfilefolder;
begin

result      :=tfilefolder.create( client, strdefb(xname,'Folder') );

xaddfile( result );

end;

function  tfilehub.nimage(const xname:string):tfileimage;
begin

result      :=tfileimage.create( client, strdefb(xname,'Image') );

xaddfile( result );

end;

function  tfilehub.ncursorScheme(const xname:string):tfilecursorScheme;
begin

result      :=tfilecursorScheme.create( client, strdefb(xname,'Cursor Scheme') );

xaddfile( result );

end;

function  tfilehub.nsprite(const xname:string):tfilesprite;
begin

result      :=tfilesprite.create( client, strdefb(xname,'Sprite') );

xaddfile( result );

end;

function  tfilehub.ntext(const xname:string):tfiletext;
begin

result      :=tfiletext.create( client, strdefb(xname,'Text') );

xaddfile( result );

end;

function  tfilehub.nmidi(const xname:string):tfilemidi;
begin

result      :=tfilemidi.create( client, strdefb(xname,'Midi') );

xaddfile( result );

end;

function  tfilehub.xaddfile(const x:tfilebase):boolean;
begin

result      :=(x<>nil) and (fcount<=high(flist));

if result then
   begin

   //make
   x.make( self );

   //add
   flist[ fcount ]    :=x;
   x.opagename        :=xpagename(fcount);

   //inc
   inc( fcount );

   end;

end;

function tfilehub.xpagename(const xindex:longint32):string;
begin

result      :='filehub--'+intstr32(xindex);

end;

function  tfilehub.fileIndex:longint32;
begin

if (filecount>=1) then result:=frcrange32( pageindex ,0 ,frcmin32(pred(fcount),0) )
else                   result:=0;

end;

procedure tfilehub.setfileIndex(const xindex:longint32);
begin

pageindex   :=frcrange32( xindex ,0 ,frcmin32(pred(fcount),0) );

end;

function  tfilehub.fileCurrent:tfilebase;
begin

if (filecount>=1) then   result:=files( fileindex )
else                     result:=nil;

end;

function  tfilehub.files(const xindex:longint):tfilebase;
begin

result      :=flist[ frcrange32( xindex ,0 ,frcmin32(pred(fcount),0) ) ];

end;

function tfilehub.settingsFilename:string;
begin

result      :=app__folderSettings(true) + 'filehub-settings.ini';

end;

procedure tfilehub.loadsettings;
begin

if istarted then
   begin

   setsettings( io__fromfilestr2( settingsFilename ) );

   isettingsREF       :=settings;

   end;

end;

procedure tfilehub.savesettings;
begin

if istarted then
   begin

   isettingsREF       :=settings;

   io__tofilestr2( settingsFilename ,isettingsREF );

   end;

end;

procedure tfilehub.autosavesettings;
begin

if istarted and low__setstr( isettingsREF ,settings ) then savesettings;

end;

function tfilehub.settings:string;

   procedure i32(const n:string;const v:longint32);
   begin

   result:=result+n+': '+intstr32(v)+#10;

   end;

   procedure b(const n:string;const v:boolean);
   begin

   result:=result+n+': '+bolstr(v)+#10;

   end;

   procedure s(const n,v:string);
   begin

   result:=result+n+': '+v+#10;

   end;

begin

//defaults
result      :='';

//check
if not istarted then exit;

end;

procedure tfilehub.setsettings(const x:string);
var
   a:tvars8;

begin

//check
if not istarted then exit;

//defaults
a                     :=nil;

try

//init
a                     :=tvars8.create;
a.text                :=x;

except;end;

//free
freeobj(@a);

end;

procedure tfilehub.xupdatebuttons;
begin

//nil

end;

procedure tfilehub.__onclick(sender:tobject);
begin

if (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 );

end;

procedure tfilehub._ontimer(sender:tobject);
begin
try

//self
inherited _ontimer(sender);


//.itimer100
if (slowms64>=itimer100) then
   begin

   //autoload
   loadfileonce;

   //reset
   itimer100:=add64( slowms64 ,100 );

   end;


//.itimer500
if (slowms64>=itimer500) then
   begin

   //updatebuttons
   xupdatebuttons;

   //save settings
   autosavesettings;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

except;end;
end;

procedure tfilehub.loadfileonce;
var
   dfileindex         :longint32;
   p                  :longint32;
   xmustupdate        :boolean;
   xcanload           :boolean;
   xempty             :boolean;
   
begin

//check
if not istarted                             then exit;

//.we don't have any file veiwers available -> stop
if (fcount<=0)                              then exit;

//.folder is not ready
if ifolderhub.folderSeeking then exit;

//.filename has not changed
if not low__setstr( ilastref ,bolstr(ifolderhub.folderisempty)+'|'+filename(0) ) then
   begin


   //automatic reload for special data types - 04sep2026 -----------------------
   
   case datatype(0) of

   dt_wallpaper       :if not wallpaper__changed(iwallpaper_changeId) then exit;
   else                exit;

   end;//case

   end;

//defaults
xempty      :=ifolderhub.folderisempty;
xcanload    :=not xempty;
xmustupdate :=false;
dfileindex  :=pred(fcount);

//load
for p:=0 to pred(fcount) do
begin

if xcanload and flist[p].canload then
   begin

   dfileindex         :=p;

   if not flist[p].loaded then
      begin

      xmustupdate     :=true;

      end;

   xcanload :=false;
   flist[p].load;

   end

else if flist[p].canunload then
   begin

   if flist[p].loaded then
      begin

      xmustupdate     :=true;

      end;

   flist[p].unload;

   end;

end;//p

//folder is empty -> default to "tfilefolder"
if xempty then
   begin

   for p:=0 to pred(fcount) do
   begin

   if (flist[p] is tfilefolder) then
      begin

      dfileindex      :=p;
      
      flist[p].load;

      xmustupdate     :=true;

      break;

      end;

   end;//p

   end;


//fileindex
setfileindex( dfileindex );


//update
if assigned(fonsync) then
   begin

   fonsync(self);

   end;

flist[dfileindex].xupdatebuttons;

xupdatebuttons;


//align and paint
if xmustupdate then
   begin

   gui.fullalignpaint;

   end;

end;

function tfilehub.issysfile(const xsubFileID:longint32):boolean;

   function sok(const n:string):boolean;

      function s(const v:string):boolean;
      begin

      result:=strmatch( n ,v );

      end;

   begin

   result   :=

    ( ifolderhub.sysfile_aboutOK   and s( ifolderhub.sysfile_about   ) ) or
    ( ifolderhub.sysfile_readmeOK  and s( ifolderhub.sysfile_readme  ) ) or
    ( ifolderhub.sysfile_licenseOK and s( ifolderhub.sysfile_license ) );

   end;

begin

if istarted and (ifolderhub.folderCurrent<>nil) then result:=sok( ifolderhub.folderCurrent.filename(ifolderhub.folderCurrent.itemindex,xsubFileID) )
else                                                 result:=false;

end;

function tfilehub.fileext(const xsubFileID:longint32):string;
begin

if istarted and (ifolderhub.folderCurrent<>nil) then result:=ifolderhub.folderCurrent.fileext(ifolderhub.folderCurrent.itemindex,xsubFileID)
else                                                 result:='';

end;

function tfilehub.datatype(const xsubFileID:longint32):tdatatype;
begin

if istarted and (ifolderhub.folderCurrent<>nil) then result:=ifolderhub.folderCurrent.datatype(ifolderhub.folderCurrent.itemindex,xsubFileID)
else                                                 result:=dt_none;

end;

function tfilehub.itemtype(const xsubFileID:longint32):titemtype;
begin

if istarted and (ifolderhub.folderCurrent<>nil) then result:=ifolderhub.folderCurrent.itemtype(ifolderhub.folderCurrent.itemindex,xsubFileID)
else                                                 result:=it_none;

end;

function tfilehub.filename(const xsubFileID:longint32):string;
begin

if istarted and (ifolderhub.folderCurrent<>nil) then result:=ifolderhub.folderCurrent.filename(ifolderhub.folderCurrent.itemindex,xsubFileID)
else                                                 result:='';

end;

function tfilehub.filesize(const xsubFileID:longint32):longint32;
begin

if istarted and (ifolderhub.folderCurrent<>nil) then result:=ifolderhub.folderCurrent.filesize(ifolderhub.folderCurrent.itemindex,xsubFileID)
else                                                 result:=0;

end;

function tfilehub.canfromfile(const xsubFileID:longint32):boolean;
begin

result      :=( itemtype(xsubFileID) = it_file );

end;

function tfilehub.fromfile(const xsubFileID:longint32;const xdata:tstr8):boolean;
begin

//defaults
result      :=false;

//get
if (xdata<>nil) and canfromfile( xsubFileID ) then
   begin

   result   :=ifolderhub.fromfile( xsubFileID ,xdata );

   end;

end;

function tfilehub.toanimation(const xwantSize,xsubFileID:longint32;const ximage:tcommonimage):boolean;
begin

//defaults
result      :=false;

//get
if (ximage<>nil) then
   begin

   result   :=ifolderhub.toanimation( xwantSize ,xsubFileID ,ximage );

   end;

end;

function tfilehub.toanimationinfo(const xwantSize,xsubFileID:longint32;var x:tanimationinfo):boolean;
begin

result      :=ifolderhub.toanimationinfo( xwantSize ,xsubFileID ,x );

end;

function tfilehub.toanimationcell(const xwantSize,xsubFileID:longint32;const xcellindex:longint32;const ximage:tcommonimage):boolean;
begin

//defaults
result      :=false;

//get
if (ximage<>nil) then
   begin

   result   :=ifolderhub.toanimationcell( xwantSize ,xsubFileID ,xcellindex ,ximage );

   end;

end;

procedure tfilehub.xcmd(const xcode2:string);
label
   skipend;

var
   xresult:boolean;
   xwas,v32:longint32;
   v,e:string;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
xresult     :=true;
e           :=gecTaskfailed;
v           :='';
v32         :=0;

//check
if not istarted then exit;

try

if m('stop') then
   begin


   end

else begin

   //nil
   
   end;

skipend:

except;end;

//update
xupdatebuttons;

//sbow error
if not xresult then gui.poperror('',e);

end;

procedure tfilehub.stop;
begin

if (fileCurrent<>nil) then
   begin

   fileCurrent.stop;

   end;

end;

procedure tfilehub.play;
begin

if (fileCurrent<>nil) then
   begin

   fileCurrent.play;

   end;

end;

procedure tfilehub.setmasterplaying(const x:boolean);
begin

imasterplaying        :=x;

end;

function tfilehub.masterplaying:boolean;
begin

result                :=imasterplaying;

end;

procedure tfilehub.playToggle;
begin

if (fileCurrent<>nil) then
   begin

   fileCurrent.playToggle;

   end;

end;


function tfilehub.playing:boolean;
begin

result      :=(fileCurrent<>nil) and fileCurrent.playing;

end;

function tfilehub.cannextFile:boolean;
begin

result      :=istarted and ifolderhub.cannextFile;

end;

procedure tfilehub.nextFile;
begin

if cannextFile then
   begin

   ifolderhub.nextFile;

   end;

end;

function tfilehub.canprevFile:boolean;
begin

result      :=istarted and ifolderhub.canprevFile;

end;

procedure tfilehub.prevFile;
begin

if canprevFile then
   begin

   ifolderhub.prevFile;

   end;

end;

function tfilehub.supcopyformat(const xformat:tfilecopyformat):boolean;
begin

result      :=(fileCurrent<>nil) and fileCurrent.supcopyformat(xformat);

end;

function tfilehub.cancopyformat(const xformat:tfilecopyformat):boolean;
begin

result      :=(fileCurrent<>nil) and fileCurrent.cancopyformat(xformat);

end;

procedure tfilehub.copyformat(const xformat:tfilecopyformat);
begin

if cancopyformat(xformat) then fileCurrent.copyformat(xformat);

end;


//## tfilebase #################################################################

constructor tfilebase.create(xparent:tobject;const xname:string);
begin

create2(xparent,true,true,xname);

end;

constructor tfilebase.create2(xparent:tobject;xscroll,xstart:boolean;const xname:string);
begin

//self
if classnameis('tfilebase') then track__inc(satOther,1);
inherited create2(xparent,false,false);

//vars
oturbo                :=false;
iname                 :=io__safename( xname );//can be nil
imade                 :=false;//requires a call to one of the "make" procs to setup and enable the folder
bordersize            :=0;
oautoheight           :=true;
oclsarea              :=true;
idata                 :=str__new8;
ifirstload            :=true;
iloaded               :=false;
iwasloaded            :=false;
itimer500X            :=slowms64;
idatatype             :=dt_none;
iitemtype             :=it_none;
ifileext              :='';
ifilename             :='';
isettingsREF          :='';
ilaststopped          :=true;
ilastplaying          :=false;

//sub-proc
on__create;

//events
client.onnotify       :=on__notify;

//start
if xstart then start;

end;

function tfilebase.subdata(const xreturnFileContents:boolean):tstr8;
begin

result      :=idata;

end;

function tfilebase.subdataExt:string;
begin

result      :=ifileext;

end;

procedure tfilebase.on__create;
begin

//nil

end;

function tfilebase.on__notify(sender:tobject):boolean;
begin

result      :=false;//not handled

end;

procedure tfilebase.on__timer;
begin

//nil

end;

procedure tfilebase.on__updatebuttons;
begin

//nil

end;

function  tfilebase.on__settings(const xindex:longint;var dname,dvalue:string):boolean;
begin

result      :=false;//no settings

end;

procedure tfilebase.on__setsettings(const x:tvars8);
begin

//nil

end;

function  tfilebase.on__cmd(const xcode2:string):boolean;
begin

result      :=false;//not handled

end;

procedure tfilebase.on__load;
begin

//nil

end;

procedure tfilebase.on__unload;
begin

//nil

end;

procedure tfilebase.on__destroy;
begin

//nil

end;

destructor tfilebase.destroy;
begin
try

//save settings to file
autosavesettings;

//sub-proc
on__destroy;

//free
str__free( @idata );

//self
inherited destroy;
if classnameis('tfilebase') then track__inc(satOther,-1);

except;end;
end;

function tfilebase.supcopyformat(const xformat:tfilecopyformat):boolean;
begin

result      :=false;

end;

function tfilebase.cancopyformat(const xformat:tfilecopyformat):boolean;
begin

result      :=false;

end;

procedure tfilebase.copyformat(const xformat:tfilecopyformat);
begin

//nil

end;

function tfilebase.fetchImage(var x:tcommonimage):boolean;
begin

result      :=false;//return a pointer to a tbasicimage object
x           :=nil;

end;

function tfilebase.fetchImageView(var x:tbasicimgview):boolean;
begin

result      :=false;//return a pointer to a tbasicimage object
x           :=nil;

end;

function tfilebase.fetchTextBox(var x:tbasicbwp):boolean;
begin

result      :=false;//return a pointer to a tbasicbwp object
x           :=nil;

end;

procedure tfilebase.make;
begin

//check
if       imade         then exit;


//find filehub
ifilehub              :=findclassToHost( tfilehub ) as tfilehub;

if (ifilehub=nil) then
   begin

   showerror('tfilehub not found');

   exit;

   end;

//made
imade                 :=true;

//load settings
loadsettings;

end;

procedure tfilebase._ontimer(sender:tobject);
begin
try

//self
inherited _ontimer( sender );

//check
if (not imade) or (not iloaded) then exit;

//itimer500X
if (slowms64>=itimer500X) then
   begin

   //oturbo
   if oturbo then
      begin

      app__turbo;

      end;

   //only when visible
   if visibletohost then
      begin

      //updatebuttons
      xupdatebuttons;

      //save settings
      autosavesettings;

      end;

   //reset
   itimer500X:=add64( slowms64 ,500 );

   end;

//timer
on__timer;

except;end;
end;

function tfilebase.settingsFilename:string;
begin

result      :=app__folderSettings(true) + 'file--'+iname + '.ini';

end;

procedure tfilebase.loadsettings;
begin

if imade then
   begin

   setsettings( io__fromfilestr2( settingsFilename ) );

   isettingsREF       :=settings;

   end;

end;

procedure tfilebase.savesettings;
begin

if imade then
   begin

   isettingsREF       :=settings;

   io__tofilestr2( settingsFilename ,isettingsREF );

   end;

end;

procedure tfilebase.autosavesettings;
begin

if imade and low__setstr( isettingsREF ,settings ) then savesettings;

end;

function tfilebase.settings:string;
var
   p:longint32;
   n,v:string;

   procedure s(const n,v:string);
   begin

   result:=result+n+': '+v+#10;

   end;

begin

//defaults
result      :='';

//check
if not imade then exit;

//add values
for p:=0 to max32 do
begin

if on__settings( p ,n ,v ) then s( n ,v )
else                            break;

end;//p

end;

procedure tfilebase.setsettings(const x:string);
var
   a:tvars8;

begin

//check
if not imade then exit;

//defaults
a                     :=nil;

try

//init
a                     :=tvars8.create;
a.text                :=x;

//get
on__setsettings( a );

except;end;

//free
freeobj(@a);

end;

procedure tfilebase.x__onmustcode(sender:tobject;const xmustcode:longint32);
begin

if imade and ifilehub.canfolderhub then
   begin

   ifilehub.folderhub.setmustcode( xmustcode );

   end;

end;

procedure tfilebase.x__onclick(sender:tobject);
begin

//check
if not imade                         then exit;

//get
if      (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 )
else if (sender is tbasicjump)       then xcmd('jump.mustpos')

end;

procedure tfilebase.xlist__onclick(sender:tobject);
begin

x__onclick( sender );

end;

procedure tfilebase.xlist__ondbclick(sender:tobject);
begin

//check
if not imade                         then exit;
if not vidoubleclicks                then exit;

//get
if (sender is tbasicmenu)            then xcmd( (sender as tbasicmenu).tagstr );

end;

procedure tfilebase.xupdatebuttons;
begin

on__updatebuttons;

end;

procedure tfilebase.xcmd(const xcode2:string);
label
   skipend;

var
   xresult:boolean;
   xwas,v32:longint32;
   v,e:string;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
xresult     :=true;
e           :=gecTaskfailed;
v           :='';
v32         :=0;

//check
if not imade then exit;

try

if on__cmd( xcode2 ) then
   begin

   //handled

   end

else begin

   //nil
   
   end;

skipend:

except;end;

//update
xupdatebuttons;

//sbow error
if not xresult then gui.poperror('',e);

end;

function  tfilebase.datatype:tdatatype;
begin

result      :=idatatype;

end;

function  tfilebase.itemtype:titemtype;
begin

result      :=iitemtype;

end;

function  tfilebase.canloaddatatype(const xdatatype:tdatatype):boolean;
begin

result      :=false;

end;

function  tfilebase.canloadfileext(const lext:string):boolean;
begin

result      :=false;

end;

function  tfilebase.canload:boolean;
begin

result      :=imade and canloaddatatype( ifilehub.datatype(0) ) and canloadfileext( ifilehub.fileext(0) );

end;

procedure tfilebase.load;
begin

if canload then
   begin

   ifilehub.fromfile( 0 ,idata );

   end
else begin

   idata.clear;

   end;

idatatype   :=ifilehub.datatype(0);
iitemtype   :=ifilehub.itemtype(0);
ifilename   :=ifilehub.filename(0);//05jun2026
ifileext    :=ifilehub.fileext (0);
iwasloaded  :=iloaded;

on__load;

iloaded     :=true;
ifirstload  :=false;

end;

function  tfilebase.canunload:boolean;
begin

result      :=imade and iloaded;

end;

procedure tfilebase.unload;
begin

if canunload then
   begin

   on__unload;

   idata.clear;

   iloaded  :=false;

   end;

end;

function  tfilebase.canstop:boolean;
begin

result      :=false;

end;

procedure tfilebase.stop;
begin

stop2( true );

end;

procedure tfilebase.stop2(const xsyncMaster:boolean);
begin

if xsyncMaster then
   begin

   ifilehub.setmasterplaying( false );

   end;

on__stop;

end;

procedure tfilebase.on__stop;
begin

//nil

end;

function tfilebase.wasstopped:boolean;
var
   v:boolean;

begin

v           :=not playing;
result      :=low__setbol(ilaststopped,v) and (not v);

end;

function  tfilebase.playpos:longint32;
begin

result      :=0;

end;

procedure tfilebase.setplaypos(const xnewpos:longint32);
begin

//nil

end;

function  tfilebase.playlen:longint32;
begin

result      :=0;

end;

function  tfilebase.canplay:boolean;
begin

result      :=false;

end;

procedure tfilebase.play;
begin

ifilehub.setmasterplaying( true );

on__play;

end;

procedure tfilebase.on__play;
begin

//nil

end;

procedure tfilebase.playToggle;
begin

case playing of
true:stop;
else play;
end;//case

end;

function  tfilebase.playing:boolean;
begin

result      :=false;

end;

function tfilebase.wasplaying:boolean;
var
   v:boolean;

begin

v           :=playing;
result      :=low__setbol(ilastplaying,v) and (not v);

end;

function  tfilebase.animated:boolean;
begin

result      :=false;

end;


//## tfileblank ################################################################

function tfileblank.on__notify(sender:tobject):boolean;
begin

//defaults
result      :=false;//not handled

//get
if gui.mousedown and (not gui.mousewasdown) then
   begin

   if      (mousedownxy.x<round(clientwidth*0.3)) then x__onmustcode(self,mc_prevFile)
   else if (mousedownxy.x>round(clientwidth*0.7)) then x__onmustcode(self,mc_nextFile);

   //handled
   result   :=true;

   end;

end;

function  tfileblank.canloadDatatype(const xdatatype:tdatatype):boolean;
begin

result      :=true;

end;

function  tfileblank.canloadFileext(const lext:string):boolean;
begin

result      :=true;

end;

procedure tfileblank.load;
begin

iloaded     :=true;
ifirstload  :=false;

end;

procedure tfileblank.unload;
begin

iloaded  :=false;

end;


//6666666666666666666666666666
//## tfilefolder ###############################################################

procedure tfilefolder.on__create;
begin

itimer500             :=slowms64;

xcols.style           :=bcToptobottom;

with xcols.makecol(0,42,false) do
begin

//vertical padding

end;//col0

with xcols.makecol(1,58,false) do
begin

ibar                  :=ntoolbar('');

with ibar do
begin

oautoheight           :=true;
halign                :=1;//align center
oscaleh               :=2.0;//large height button

lsadd('Open Folder' ,tepFolder20,0,'open' ,'Open Folder|Open the folder to view its contents',-30);
lsadd('Show All Files' ,tepFolder20,0,'showall' ,'Show All Files|Show all files in the folder',-30);

bhighlight2['open']   :=true;
bhighlight2['showall']:=true;

end;

end;//col1

//events
ibar.onclick          :=x__onclick;

end;

procedure tfilefolder.on__load;
begin

end;

procedure tfilefolder.on__timer;
begin
try

//.itimer500
if (slowms64>=itimer500) then
   begin

   //updatebuttons
   xupdatebuttons;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

except;end;
end;

procedure tfilefolder.xupdatebuttons;
var
   xcanopen           :boolean;
   xisempty           :boolean;

begin

//init
xcanopen              :=ifilehub.canopenfolder;
xisempty              :=ifilehub.folderisempty;

//get
with ibar do
begin

bvisible2['open']     :=xcanopen;
bvisible2['showall']  :=(not xcanopen) and xisempty;
bflash2['showall']    :=(not xcanopen) and xisempty;

end;

end;

//xxxxxxxxxxxxxxxxxx//6666666666666666
function tfilefolder.on__cmd(const xcode2:string):boolean;
var
   v                  :string;
   v32                :longint32;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
result      :=true;
v           :='';
v32         :=0;

//get
if m('open') then
   begin

   if ifilehub.canopenfolder then
      begin

      ifilehub.openfolder;

      end;

   end

else if m('showall') then
   begin

   if ifilehub.canfolderhub and (ifilehub.folderhub.folderCurrent<>nil) then
      begin

      ifilehub.folderhub.folderCurrent.setmaskmode( mm_default ,true );

      end;

   end

else begin

   //not handled
   result   :=false;

   end;

end;

function  tfilefolder.canloadDatatype(const xdatatype:tdatatype):boolean;
begin

result      :=true;

end;

function  tfilefolder.canloadFileext(const lext:string):boolean;
begin

result      :=true;

end;


//## tfileimage ################################################################

function  tfileimage.canloaddatatype(const xdatatype:tdatatype):boolean;
begin

result      :=(xdatatype=dt_image) or (xdatatype=dt_cursor) or (xdatatype=dt_wallpaper);

end;

function  tfileimage.canloadfileext(const lext:string):boolean;
begin

result      :=true;

end;

//7777777777777777777777777777777777777
procedure tfileimage.on__create;//tfileimage.oncreate
begin

//vars
oclsarea              :=false;
oturbo                :=true;//for fast animation preview
opreviewCursor        :=false;//disabled for now => Windows can't handle loading many large animated cursors - 05jun2026
omanageCursor         :=true;
omanageBackground     :=true;
iimage                :=client.nimgview;
ilastmode             :=0;
ilastREF              :='';
itimer500             :=slowms64;

with iimage do
begin

oautoheight           :=true;
countcolors           :=true;
animate               :=true;
ohighspeed            :=true;

end;

//events
iimage.onmustcode     :=x__onmustcode;

end;

procedure tfileimage.on__destroy;
begin
try


except;end;
end;

procedure tfileimage.on__load;
var
   dmode              :longint32;
   dslow              :boolean;

begin

//mode
if ifilehub.issysfile(0)    then dmode:=1//system image
else                             dmode:=2;//normal image

if (not ifirstload) and (not iwasloaded)                        then dslow:=false
else if (ilastmode=0)                                           then dslow:=true
else if (ilastmode<>dmode)                                      then dslow:=false
else                                                                 dslow:=true;

ilastmode             :=dmode;

//fill style
if ifilehub.issysfile(0)    then iimage.fillStyle:=vfsScreen
else                             iimage.fillStyle:=vfsDefault;

//fade speed
if dslow                    then iimage.fadespeed:=15//slow
else                             iimage.fadespeed:=100;//fast

//load
iimage.loadfromdata( @idata ,true );

end;

procedure tfileimage.on__unload;
begin

inherited on__unload;

//stop cursor preview
if opreviewCursor then
   begin

   cursor__untemp;

   end;
   
end;

function tfileimage.fetchImageView(var x:tbasicimgview):boolean;
begin

//defaults
result      :=iloaded;
x           :=nil;

//get
if result then
   begin

   x        :=iimage;

   end;

end;

procedure tfileimage.on__timer;
begin
try

//update cursor preview
xcursorPreview;

//.itimer500
if (slowms64>=itimer500) then
   begin

   //updatebuttons
   xupdatebuttons;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

except;end;
end;

function  tfileimage.animated:boolean;
begin

result      :=(iimage.cells>=2);

end;

procedure tfileimage.xcursorPreview;
var
   xok:boolean;

begin

//get
xok         :=
            opreviewCursor                                                                      and
            (gui.control__fastfindxyb( gui.mousemovexy.x ,gui.mousemovexy.y )=iimage.coreindex) and
            ( strmatch(ifileext,'cur') or strmatch(ifileext,'ani') );

//get
if low__setstr(icursorpreviewREF,bolstr(xok)+'|'+ifilename) then
   begin

   case xok of
   true:cursor__usetemp( @idata );
   else cursor__untemp;
   end;//case

   end;

end;

function tfileimage.supcopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of
fc_copyall ,fc_copy ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal:result   :=true;
else                                                                                                                    result   :=false;
end;//case

end;

function tfileimage.cancopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of

fc_copyall  :result   :=iloaded and (idata.len32>=1) and ( (iimage.image32.width>=2) or (iimage.image32.height>=2) ) and (iimage.cells>=2);

fc_copy ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal:begin

             result   :=iloaded and (idata.len32>=1) and ( (iimage.image32.width>=2) or (iimage.image32.height>=2) );

             end;

else         result   :=false;

end;//case

end;

procedure tfileimage.copyformat(const xformat:tfilecopyformat);
var
   d                  :tobject;

begin

//defaults
d                     :=nil;

//check
if not cancopyformat(xformat) then exit;

try

//get
case xformat of
fc_copy:begin

   if (iimage.cells>=2) then
      begin

      d     :=misraw32(1,1);
      mis__copy( iimage.image32 ,d );
      mis__onecell( d );
      clip__copyimage( d );//one cell

      end

   else clip__copyimage( iimage.image32 );//one cell

   end;

fc_copyall            :clip__copyimage( iimage.image32 );//all cells

fc_pngPascal          :clip__copyimageAsArrayByte( iimage.image32 ,'png' ,true ,false );
fc_jpgPascal          :clip__copyimageAsArrayByte( iimage.image32 ,'jpg' ,true ,false );
fc_icoPascal          :clip__copyimageAsArrayByte( iimage.image32 ,'ico' ,true ,false );
fc_gifPascal          :clip__copyimageAsArrayByte( iimage.image32 ,'gif' ,true ,false );

fc_pngB64             :clip__copyimageAsBase64( iimage.image32 ,'png' ,true ,false );
fc_jpgB64             :clip__copyimageAsBase64( iimage.image32 ,'jpg' ,true ,false );
fc_icoB64             :clip__copyimageAsBase64( iimage.image32 ,'ico' ,true ,false );
fc_gifB64             :clip__copyimageAsBase64( iimage.image32 ,'gif' ,true ,false );

end;//case

except;end;

//free
freeobj(@d);

end;


//## tfilecursorscheme #########################################################

function  tfilecursorscheme.canloaddatatype(const xdatatype:tdatatype):boolean;
begin

result      :=(xdatatype=dt_cursorScheme);

end;

function  tfilecursorscheme.canloadfileext(const lext:string):boolean;
begin

result      :=true;

end;

procedure tfilecursorscheme.on__create;
var
   p                  :longint32;
   v                  :longint32;

begin

//vars
oclsarea              :=false;
oturbo                :=true;//for fast animation preview
osmooth               :=true;//for smooth paint (all cells painted)
opreviewCursor        :=false;//disabled for now => Windows can't handle loading many large animated cursors - 05jun2026
omanageCursor         :=true;
omanageBackground     :=true;
ilastmode             :=0;
ilastREF              :='';
itimer500             :=slowms64;
ianmimated            :=false;
iitemindex            :=1;//range: 0..cf_max
ihoverindex           :=-1;//range: -1..cf_max
ileftclickX           :=min32;
irightclickX          :=max32;
icolumncount          :=0;
isubdata              :=str__new8;

//screen
iscreen               :=ncontrol;
icell                 :=miscom32(1,1);

with iscreen do
begin

oautoheight           :=true;

normal:=false;

end;


//image list
v                     :=0;

for p:=0 to high(ilist) do
begin

if (v=cf_install) then
   begin

   inc( v);

   end;

with ilist[p] do
begin

cfindex               :=v;
ok                    :=false;
filename              :='';
painttimer            :=0;
itemindex             :=0;
cachedcells           :=nil;
area                  :=nilarea;
wantsize              :=-1;//25jun2026
changeid              :=-1;

low__cls(@iscached,sizeof(iscached));
low__cls(@info,sizeof(info));

end;//ilist

//inc
inc(v);

end;//p


//events
iscreen.onpaint       :=on__screenpaint;
iscreen.onnotify      :=on__notify;//for mustcode

end;

procedure tfilecursorscheme.on__destroy;
var
   p                  :longint32;

begin
try

//vars
freeobj(@isubdata);
freeobj(@icell);

for p:=0 to high(ilist) do freeobj(@ilist[p].cachedcells);

except;end;
end;

procedure tfilecursorscheme.on__load;
var
   xmustpaint         :boolean;
   p                  :longint32;
   xanimated          :boolean;
   xwantSize          :longint32;
   xchangeid          :longint32;

   procedure xload(const lindex:longint32);
   var
      f               :string;
      xlastref        :string;

      function xref:string;
      begin

      result:=intstr32(ilist[lindex].info.cellwidth)+'|'+intstr32(ilist[lindex].info.cellheight)+'|'+intstr32(ilist[lindex].info.cellcount);

      end;

   begin

   //check
   f                  :=ifilehub.filename( ilist[lindex].cfindex );

   if (not strmatch(f,ilist[lindex].filename)) or (xwantSize<>ilist[lindex].wantsize) or (xchangeid<>ilist[lindex].changeid) then
      begin

      //get
      xmustpaint                :=true;
      xlastref                  :=xref;

      //.reset cache
      low__cls(@ilist[lindex].iscached,sizeof(ilist[lindex].iscached));

      ilist[lindex].changeid    :=xchangeid;
      ilist[lindex].wantsize    :=xwantSize;
      ilist[lindex].painttimer  :=0;//mark for immediate paint
      ilist[lindex].filename    :=f;
      ilist[lindex].ok          :=ifilehub.toanimationinfo( ilist[lindex].wantsize, ilist[lindex].cfindex ,ilist[lindex].info );

      //.reset animation index
      if (xref<>xlastref) then
         begin

         ilist[lindex].itemindex:=0;

         end;

      end;

   //animated
   if (ilist[lindex].info.cellcount>=2) then
      begin

      xanimated                 :=true;

      end;

   end;

begin

//defaults
xmustpaint            :=false;
xanimated             :=false;
xwantSize             :=cursor_wantsize;
xchangeid             :=cursor_customcolors.changeid;

//get
for p:=0 to high(ilist) do
begin

xload( p );

end;//p

//set
ianmimated            :=xanimated;


cursor_customcolors.canEdit     :=(ilist[cf_arrow].info.cursorinfo.cc=cc_customcolor);
cursor_customcolors.canSpeed    :=(ilist[cf_arrow].info.cursorinfo.ca<>ca_static);
cursor_customcolors.info        :=ilist[cf_arrow].info.cursorinfo;

if xmustpaint then
   begin

   iscreen.paintnow;

   end;

end;

function tfilecursorscheme.on__notify(sender:tobject):boolean;
begin

//defaults
result      :=false;//not handled

//hover
if gui.mousemoved then
   begin

   sethoverindex( findindex( mousemovexy.x ,mousemovexy.y ) );

   end;

//get
if gui.mousedown and (not gui.mousewasdown) then
   begin

   //item index
   setitemindex( findindex( mousemovexy.x ,mousemovexy.y ) );

   //mustcode
   if      (mousedownxy.x<=ileftclickX)  then x__onmustcode(self,mc_prevFile)
   else if (mousedownxy.x>=irightclickX) then x__onmustcode(self,mc_nextFile);

   //handled
   result   :=true;

   end;

if (gui.key<>aknone) then
   begin

   case gui.key of
   akhome             :itemindex:=0;
   akend              :itemindex:=high(ilist);
   akleft             :itemindex:=frcmin32( pred(itemindex) ,0 );
   akright            :itemindex:=succ(itemindex);
   akup               :if ((itemindex-icolumncount)>=0          ) then itemindex:=itemindex - icolumncount;
   akdown             :if ((itemindex+icolumncount)<=high(ilist)) then itemindex:=itemindex + icolumncount;
   end;//case

   //handled
   result             :=true;

   end;

end;

function tfilecursorscheme.subdata(const xreturnFileContents:boolean):tstr8;
begin

if (itemindex>=0) and (ilist[itemindex].ok) then
   begin

   case xreturnFileContents of
   true:ifilehub.fromfile( 1 + itemindex ,isubdata );
   else isubdata.setlen( 1 );
   end;//case

   result   :=isubdata;//.cur or .ani

   end
else begin

   result   :=idata;//.inf

   end;

end;

function tfilecursorscheme.subdataExt:string;
begin

if (itemindex>=0) and (ilist[itemindex].ok) then
   begin

   result   :=ifilehub.fileext( 1 + itemindex );

   end
else begin

   result   :=ifileext;//.inf

   end;

end;

function tfilecursorscheme.findindex(const sx,sy:longint32):longint32;
var
   p        :longint32;

begin

//defaults
result      :=-1;

//find
for p:=0 to high(ilist) do
begin

if ilist[p].ok and area__within( ilist[p].area ,sx ,sy ) then
   begin

   result   :=p;

   break;

   end;

end;//p

end;

procedure tfilecursorscheme.setitemindex(x:longint32);
begin

if (x>=0) and (x<=high(ilist)) and low__setint( iitemindex ,x ) then
   begin

   iscreen.paintnow;

   end;

end;

procedure tfilecursorscheme.sethoverindex(x:longint32);
begin

if low__setint( ihoverindex ,x ) then
   begin

   iscreen.paintnow;

   end;

end;

//xxxxxxxxxxxxxxxxxxxxxxx//8888888888888888888888
procedure tfilecursorscheme.on__screenpaint(sender:tobject);
const
   xpadding           =10;//20;
   xmargin            =16;//32;
   xcolumnlimit       =6;
   xsep               =#32;
   xsep2              =', ';

var
   s                  :tclientinfo;
   lcount             :longint32;
   xcolumnwidth       :longint32;
   xrowheight         :longint32;
   xcolumncount       :longint32;
   xrowcount          :longint32;
   xlabelheight       :longint32;
   c                  :longint32;
   r                  :longint32;
   i                  :longint32;
   dx                 :longint32;
   dy                 :longint32;
   da                 :twinrect;
   ta                 :twinrect;
   cw                 :longint32;//cell width
   ch                 :longint32;//cell height
   cc                 :longint32;//cell count
   ci                 :longint32;//cell index
   tx                 :longint32;//target x
   ty                 :longint32;//target y
   xcellback          :longint32;
   xlabel             :string;
   dxstart            :longint32;
   xbytes             :longint32;
   xsummaryLineHeight :longint32;
   xsummaryheight     :longint32;
   vc                 :longint32;
   xinfo              :tmakecursorinfo;
   xwantsize          :longint32;
   xchangeid          :longint32;
   xcached            :boolean;
   minDelay           :longint32;
   maxDelay           :longint32;

   procedure sline(const xline:string);
   begin

   ftext( s.back ,ta ,dx ,dy ,s.font ,'L130;L130;L130;L130;L130;L130;' ,xline , s.fn ,true );

   inc( dy ,xsummaryLineHeight );

   end;

   function xfps:string;

      function f(const xdelay:longint32):string;
      var
         v  :double;

      begin

      v     :=1000 / frcmin32( xdelay,1 );

      if (v>60) then v:=60;

      result:=floattostrex( v ,0 );

      end;
   begin

   if (minDelay=maxDelay) then result:=low__aorbstr('static',f(minDelay) ,cc>=2 )
   else                        result:=f(maxDelay) + ' - ' + f(minDelay);

   end;

begin

//init
infovars(s);

lcount                :=high(ilist) + 1;
xcached               :=true;
xwantsize             :=cursor_wantsize;
xchangeid             :=cursor_customcolors.changeID;
xsummaryLineHeight    :=round( s.fnH * 1.5 );
xsummaryheight        :=( 2 * xpadding ) + ( 2 * xsummaryLineHeight );

xlabelheight          :=s.fnH;
xcolumnwidth          :=( 2 * xpadding ) + cursor_maxsize;
xrowheight            :=( 2 * xpadding ) + cursor_maxsize + round(1.2 * xlabelheight );
xcolumncount          :=frcrange32( ( s.cw - (2*xmargin) ) div xcolumnwidth ,1 ,frcmax32( xcolumnlimit ,lcount )  );
xrowcount             :=lcount div xcolumncount;
xcellback             :=int__splice32( 0.50 ,s.back ,s.hover );
cc                    :=1;
minDelay              :=max32;
maxDelay              :=min32;

if ( ( xcolumncount * xrowcount ) < lcount ) then
   begin

   inc(xrowcount);

   end;

dxstart               :=( s.cw - ( xcolumncount * xcolumnwidth ) ) div 2;

ileftclickX           :=dxstart - 1;
irightclickX          :=pred(s.cw) - ileftclickX;
icolumncount          :=xcolumncount;

low__cls(@xinfo,sizeof(xinfo));

//cls
ffillArea( s.cs ,s.back ,false );

//draw images
i                     :=0;
dy                    :=( s.ch - xsummaryheight - ( xrowcount * xrowheight ) ) div 2;

for r:=0 to pred(xrowcount) do
begin

dx                    :=dxstart;

for c:=0 to pred(xcolumncount) do
begin

//wantSize has changed
if (i<lcount) and ilist[i].ok and ( (xwantsize<>ilist[i].wantsize) or (xchangeid<>ilist[i].changeid) ) then
   begin

   //sync info check to 1st cell of animation -> all successive cells must conform to these same settings otherwise restart at 1st - 25jun2026
   if (ilist[i].itemindex<>0) then
      begin

      ilist[i].itemindex:=0;

      end;

   //get info
   ilist[i].wantsize  :=xwantsize;
   ilist[i].changeid  :=xchangeid;
   ilist[i].ok        :=ifilehub.toanimationinfo( ilist[i].wantsize, ilist[i].cfindex ,ilist[i].info );

   //clear cache status
   low__cls( @ilist[i].iscached ,sizeof(ilist[i].iscached) );

   end;

//get
if (i<lcount) and ilist[i].ok then
   begin

   //init
   da.left            :=dx;
   da.right           :=da.left + pred(xcolumnwidth);
   da.top             :=dy;
   da.bottom          :=da.top  + pred(xrowheight);
   ta                 :=area__grow(da,-xpadding div 2);
   xinfo              :=ilist[i].info.cursorinfo;
   cw                 :=ilist[i].info.cellwidth;
   ch                 :=ilist[i].info.cellheight;
   ci                 :=frcrange32( ilist[i].itemindex ,0 ,frcmin32(pred(ilist[i].info.cellcount),0) );
   cc                 :=ilist[i].info.cellcount;

   if (iitemindex<0) or (iitemindex=i) then
      begin

      if (ilist[i].info.delay < minDelay ) then minDelay:=ilist[i].info.delay;
      if (ilist[i].info.delay > maxDelay ) then maxDelay:=ilist[i].info.delay;

      end;

   tx                 :=da.left + (( ( da.right  - da.left + 1 ) - cw ) div 2);
   ty                 :=da.top  + (( ( da.bottom - da.top + 1  ) - ch ) div 2);
   ilist[i].area      :=da;

   //background tint
   if      (iitemindex=i)  then vc:=s.hover2
   else if (ihoverindex=i) then vc:=s.hover
   else                         vc:=xcellback;

   ffillArea( ta ,vc ,false );


   //use cached cell for lower CPU usage
   if (ilist[i].itemindex>=0) and (ilist[i].itemindex<cursor_celllimit) and ilist[i].iscached[ ilist[i].itemindex ] then
      begin

      //draw cell
      fdraw3( ilist[i].cachedcells ,area__make( ci * cw ,0 ,(ci * cw) + pred(cw) ,pred(ch) ) ,tx ,ty ,cw ,ch ,clnone ,255 ,0 ,false ,false ,true );

      end

   //fetch cell -> proc will fail during IO work "iobusy=true"
   else if ifilehub.toanimationcell( ilist[i].wantsize ,ilist[i].cfindex ,ilist[i].itemindex ,icell ) then
      begin

      //status
      xcached         :=false;

      //draw cell
      fdraw( icell ,tx ,ty ,clnone ,255 ,true );

      //cache cell
      if (ilist[i].itemindex>=0) and (ilist[i].itemindex<cursor_celllimit) then
         begin

         ilist[i].iscached[ ilist[i].itemindex ]    :=true;

         if (ilist[i].cachedcells=nil) then
            begin

            ilist[i].cachedcells                    :=miscom32(1,1);

            end;

         missize( ilist[i].cachedcells ,cc * cw ,ch );

         mis__copyfast( maxarea ,misarea( icell ) ,ci * cw ,0 ,cw ,ch ,icell ,ilist[i].cachedcells );

         //sync image based aimation information -> for clipboard work etc
         with misai(ilist[i].cachedcells)^ do
         begin

         delay        :=ilist[i].info.delay;
         count        :=ilist[i].info.cellcount;
         cellwidth    :=ilist[i].info.cellwidth;
         cellheight   :=ilist[i].info.cellheight;

         end;

         end;

      end;

   //label
   xlabel   :=intstr32( i + 1 ) + '. ' + cf__label( ilist[i].cfindex );

   ftext( s.back ,ta ,ta.left + (xpadding div 2)  ,ta.bottom - xlabelheight + round( (xlabelheight-s.fnH) / 2 ) , s.font ,'' ,xlabel, s.fn ,true );

   end;

//inc
inc( i );
inc( dx ,xcolumnwidth );

end;//c

//inc
inc( dy ,xrowheight );

end;//r


//summary ----------------------------------------------------------------------

//init
dx                    :=dxstart;

da.left               :=dx;
da.right              :=da.left + pred( xcolumncount * xcolumnwidth );
da.top                :=dy;
da.bottom             :=da.top  + xsummaryheight;

ta                    :=area__grow(da,-xpadding div 2);

xbytes                :=0;

for i:=0 to cf_max do
begin

inc( xbytes ,ifilehub.filesize( i ) );

end;//i

//background tint
ffillArea( ta ,xcellback ,false );

//start
dx                    :=ta.left + (xpadding div 2);
dy                    :=ta.top  + ((ta.bottom-ta.top+1-( 2 * xsummaryLineHeight )) div 2);


//line 1
sline(
 'File Size: ' +low__mbAUTO2( xbytes ,1 ,true )   + #9 +
 'Type: '    + cv__label( xinfo.cv )              + #9 +
 'Style: '   + ct__label( xinfo.ct )              + #9 +
 'Opacity: ' + co__label( xinfo.co )              + #9 +
 'Format: '  + cb__label( xinfo.cb )              + #9 +
'');

//line 2
sline(
 ''                                               + #9 +
 'Size: '    + k64(ilist[0].info.cellwidth)+' x '+k64(ilist[0].info.cellheight)           + #9 +
 'Cells: '   + ca__label( xinfo.ca )              + #9 +
 'Fps: '     + xfps                               + #9 +
'');


//sync
cursor_customcolors.cf_index              :=ilist[ frcrange32( iitemindex ,0 ,cf_max ) ].info.cursorinfo.cf;
cursor_customcolors.statusCaching         :=not xcached;

end;

//xxxxxxxxxxxxxxx//88888888888888888
procedure tfilecursorscheme.on__unload;
var
   p                  :longint32;

begin

inherited on__unload;

//stop cursor preview
if opreviewCursor then
   begin

   cursor__untemp;

   end;

//clear cache to reduce memory
for p:=0 to high(ilist) do
begin

if (ilist[p].cachedcells<>nil) then
   begin

   missize( ilist[p].cachedcells ,1 ,1 );

   end;

low__cls(@ilist[p].iscached,sizeof(ilist[p].iscached));

ilist[p].ok           :=false;
ilist[p].filename     :='';


end;//p

cursor_customcolors.canEdit     :=false;

end;

//xxxxxxxxxxxxxxxxxxxxxxxx//8888888888888888888888888
procedure tfilecursorscheme.on__timer;
var
   p                  :longint32;
   i                  :longint32;
   v                  :longint32;
   xmustpaint         :boolean;
   xref               :longint64;
   xstep              :longint32;

begin
try

//defaults
xmustpaint            :=false;

//update cursor preview
xcursorPreview;

//.itimer500
if (slowms64>=itimer500) then
   begin

   //updatebuttons
   xupdatebuttons;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

//.animation timers
xref                  :=ms64;
xstep                 :=low__aorb(2,1,osmooth);

for p:=0 to high(ilist) do
begin

if ilist[p].ok and (xref>=ilist[p].painttimer) then
   begin

   //inc
   i                  :=ilist[p].itemindex + xstep;

   if (i>=ilist[p].info.cellcount) then
      begin

      i               :=0;

      end;

   if (i<>ilist[p].itemindex) then
      begin

      ilist[p].itemindex  :=i;
      xmustpaint          :=true;

      end;

   //reset
   if ifilehub.canfolderhub and ifilehub.folderhub.renderPaused then v:=1000
   else if (ilist[p].info.cellcount>=2)                         then v:=ilist[p].info.delay * xstep
   else                                                              v:=500;

   ilist[p].painttimer    :=add64( xref ,v );

   end;


end;//p

//mustpaint
if xmustpaint then
   begin

   iscreen.paintnow;

   end;

except;end;
end;

function  tfilecursorscheme.animated:boolean;
begin

result      :=ianmimated;

end;

procedure tfilecursorscheme.xcursorPreview;
var
   xok:boolean;

begin

//get
xok         :=
            opreviewCursor                                                                       and
            (gui.control__fastfindxyb( gui.mousemovexy.x ,gui.mousemovexy.y )=iscreen.coreindex) and
            strmatch(ifileext,'inf');

//get
if low__setstr(icursorpreviewREF,bolstr(xok)+'|'+ifilename) then
   begin

   case xok of
   true:cursor__usetemp( @idata );
   else cursor__untemp;
   end;//case

   end;

end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//8888888888888888888888888888888//ffffffffffffffff
function tfilecursorscheme.supcopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of
fc_copyAll ,fc_copy ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal:result   :=true;
else                                                                                                                    result   :=false;
end;//case

end;

function tfilecursorscheme.cancopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of

fc_copyAll  :result:=iloaded and (idata.len32>=1) and (itemindex>=0) and animated;
fc_copy ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal:begin

             result   :=iloaded and (idata.len32>=1) and (itemindex>=0);

             end;

else         result   :=false;

end;//case

end;

procedure tfilecursorscheme.copyformat(const xformat:tfilecopyformat);
label
   skipend;

var
   a                  :tstr8;
   d                  :tobject;
   e                  :string;

begin

//defaults
a                     :=nil;
d                     :=nil;

//check
if not cancopyformat(xformat) then exit;

try

//init
a           :=rescache__newStr8;
d           :=misraw32(1,1);

if not filehub.fromfile( ilist[ frcrange32(itemindex,0,high(ilist)) ].cfindex ,a ) then goto skipend;
if not mis__fromdata( d ,@a ,e )                                                   then goto skipend;

//get
case xformat of

fc_copyall            :clip__copyimage( d );

fc_copy               :begin

                       misonecell( d );
                       clip__copyimage( d );

                       end;

fc_pngPascal          :clip__copyimageAsArrayByte( d ,'png' ,true ,false );
fc_jpgPascal          :clip__copyimageAsArrayByte( d ,'jpg' ,true ,false );
fc_icoPascal          :clip__copyimageAsArrayByte( d ,'ico' ,true ,false );
fc_gifPascal          :clip__copyimageAsArrayByte( d ,'gif' ,true ,false );

fc_pngB64             :clip__copyimageAsBase64( d ,'png' ,true ,false );
fc_jpgB64             :clip__copyimageAsBase64( d ,'jpg' ,true ,false );
fc_icoB64             :clip__copyimageAsBase64( d ,'ico' ,true ,false );
fc_gifB64             :clip__copyimageAsBase64( d ,'gif' ,true ,false );

end;//case

skipend:

except;end;

//free
rescache__delStr8( @a );
freeobj(@d);

end;


//## tfiletext #################################################################

function  tfiletext.canloaddatatype(const xdatatype:tdatatype):boolean;
begin

result      :=(xdatatype=dt_text);

end;

function  tfiletext.canloadfileext(const lext:string):boolean;
begin

result      :=true;

end;

procedure tfiletext.on__create;
begin

oclsarea              :=false;
itext                 :=client.nbwp('',nil);
ivars                 :=tfastvars.create;
inameref              :='';

with itext do
begin

oautoheight           :=true;
core.viewurl          :=false;
core.readonly         :=true;
olivewordcount        :=true;

end;

end;

procedure tfiletext.on__destroy;
begin

freeobj(@ivars);

end;

procedure tfiletext.on__load;
var
   fext:string;

begin

//init
xstorepos;

fext                  :=ifilehub.fileext(0);
inameref              :=ifilehub.filename(0)+'|';

//load
itext.core.onefontname:=low__aorbstr(font_name1,font_name2,fext='txt');
itext.core.onefontsize:=low__aorb(0,1,fext='txt');
itext.ioset4( idata ,'' ,ivars.i[ inameref + 'scrollv.px' ] ,-1 ,ivars.i[ inameref + 'scrollh' ] ,ivars.i[ inameref +'pos' ] ,ivars.i[ inameref +'pos2' ] ,false ,false );

end;

function tfiletext.fetchTextBox(var x:tbasicbwp):boolean;
begin

//defaults
result      :=iloaded;
x           :=nil;

//get
if result then
   begin

   x        :=itext;

   end;

end;

procedure tfiletext.xstorepos;
begin

if (inameref<>'') then
   begin

   ivars.i[ inameref + 'pos'        ]:=itext.cpos;
   ivars.i[ inameref + 'pos2'       ]:=itext.cpos2;
   ivars.i[ inameref + 'scrollv.px' ]:=itext.core.vpos_px;
   ivars.i[ inameref + 'scrollh'    ]:=itext.core.hpos;

   end;

end;

procedure tfiletext.on__unload;
begin

xstorepos;

inherited on__unload;

end;

function tfiletext.supcopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of
fc_copyall ,fc_copy   :result   :=true;
else                   result   :=false;
end;//case

end;

function tfiletext.cancopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of

fc_copyall            :result   :=iloaded;

fc_copy               :result   :=iloaded and itext.core.cancopy;

else                   result   :=false;

end;//case

end;

procedure tfiletext.copyformat(const xformat:tfilecopyformat);
begin

//check
if not cancopyformat(xformat) then exit;

//get
case xformat of

fc_copy               :itext.core.copy;

fc_copyall            :itext.core.copyall;

end;//case

end;


//aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
//## tfilemidi #################################################################

function  tfilemidi.canloaddatatype(const xdatatype:tdatatype):boolean;
begin

result      :=(xdatatype=dt_midi);

end;

function  tfilemidi.canloadfileext(const lext:string):boolean;
begin

result      :=true;

end;

procedure tfilemidi.on__create;
begin

//init midi device range -> disable "all midi devices" - 13sep2025
mid_setAllowAllDevices(false);

//.midi handler
mid_setkeepopen(false);//auto closes midi device after 5 seconds of inactivity
mid_enhance(true);//enable enhanced midi features -> e.g. realtime status
mid_settrimtolastnote(true);

//vars
oclsarea              :=false;
ilastfilename         :='';
ifastTimer            :=ms64;
itimer100             :=slowms64;
itimer250             :=slowms64;
inewdata              :=false;

iLastTimeRef          :=0;
ibeatval              :=0;
ibeatvalBass          :=0;


with xtoolbar do
begin

add('Stop',tepStop20,0,'stop','Stop|Stop music playback');
add('Play',tepPlay20,0,'play','Play|Toggle music playback');
add('Mixer',tepVol20,0,'mixer','Mixer|Show volume mixer');

benabled2['mixer']:=low__canshowvol;

addsep;

add('',tepDownward20,0,'vol.-','Volume|Decrease volume by 10%');
add('Vol 100',tepNone,0,'vol.100','Volume|Reset volume to 100%');
add('',tepUpward20,0,'vol.+','Volume|Increase volume by 10%');

add('',tepDownward20,0,'speed.-','Playback Speed|Decrease playback speed by 2%');
add('Speed 100',tepNone,0,'speed.100','Playback Speed|Reset playback speed to 100%');
add('',tepUpward20,0,'speed.+','Playback Speed|Increase playback speed by 2%');

end;

ilist                 :=client.nlistx('','',0,0,xlist__onitem);
ilist.otab            :=tbL100_L500;
ilist.oscaleh         :=0.70;
ilist.makepanel;
ilist.countx          :=18;

with xcolsh do//use "xcolsh"
begin

style       :=bcLeftToRight;

with makecol(0,30,false) do
begin

ivol                  :=mmidivol('Volume','');

end;

with makecol(1,30,false) do
begin

ispeed                :=mint2b('Speed','Playback speed|Restore default playback speed','Playback speed|Set playback speed from 50% (slower) to 200% (faster)|Normal playback speed is 100%',50,200,100,100,'');
ispeed.ounit          :=' %';

end;

with makecol(2,40,false) do
begin

idevice               :=nmidi('Midi Device','');

end;

end;//xcolsh


with xhigh2 do
begin

nbreak(10);

//.ijump
ntitle(false,'Playback Progress','').normal:=false;

nbreak(10);

ijump                 :=njump('','Click and/or drag to adjust playback position',0,0);
ijump.status          :=1;

end;


//events
xtoolbar.onclick      :=x__onclick;
ijump.onclick         :=x__onclick;

end;

procedure tfilemidi.on__destroy;
begin

stop;

end;

function tfilemidi.tracks:longint32;
begin

if iloaded and (idata.len32>=1) then result:=mid_tracks
else                                 result:=0;

end;

function  tfilemidi.on__settings(const xindex:longint;var dname,dvalue:string):boolean;

   procedure s(const dn,dv:string);
   begin

   result   :=true;
   dname    :=dn;
   dvalue   :=dv;

   end;

   procedure i(const dn:string;const dv:longint32);
   begin

   result   :=true;
   dname    :=dn;
   dvalue   :=intstr32( dv );

   end;

   procedure b(const dn:string;const dv:boolean);
   begin

   result   :=true;
   dname    :=dn;
   dvalue   :=bolstr( dv );

   end;

begin

case xindex of
0           :i( 'device' ,vimididevice );
1           :i( 'speed'  ,mid_speed       );
2           :i( 'vol'    ,ivol.val       );
else         result:=false;
end;//case

end;

procedure tfilemidi.on__setsettings(const x:tvars8);
begin

vimidideviceNew       :=x.idef('device',-1);
ivol.val              :=x.idef2('vol',100 ,0 ,200 );
ispeed.val            :=x.idef2('speed',100 ,50 ,200 );

end;

procedure tfilemidi.on__load;

begin

//init
inewdata    :=low__setstr( ilastfilename ,filehub.filename(0) );

//load
if playing or ifilehub.masterplaying then
   begin

   play;

   end

else if (playpos>=playlen) then
   begin

   setplaypos( 0 );

   end;

//info
xsyncInfo;

end;

procedure tfilemidi.on__unload;
begin

if playing then
   begin

   stop2( false );

   end;

inherited on__unload;

end;

procedure tfilemidi.on__updatebuttons;
begin

xsyncInfo;

with xtoolbar do
begin

//.stop and play
benabled2['stop']               :=canstop;

bmarked2 ['play']               :=playing;
bflash2  ['play']               :=playing;

//.volume
benabled2['vol.-']              :=(mid_vol>ivol.min);

benabled2['vol.+']              :=(mid_vol<ivol.max);

benabled2['vol.100']            :=(mid_vol<>100);

//.speed
benabled2['speed.-']            :=(mid_speed>50);

benabled2['speed.+']            :=(mid_speed<200);

benabled2['speed.100']          :=(mid_speed<>100);

end;

end;

procedure tfilemidi.on__timer;
begin

//speed
if (not gui.mousedown) and (mid_speed<>ispeed.val) then
   begin

   mid_setspeed(ispeed.val);

   end;

//midi beat flash
xbeatFlash;

//.itimer100
if (slowms64>=itimer100) then
   begin

   //info
   xsyncInfo;

   //reset
   itimer100:=add64( slowms64 ,100 );

   end;

//.itimer250
if (slowms64>=itimer250) then
   begin

   ilist.paintnow;

   //reset
   itimer250:=add64( slowms64 ,250 );

   end;

//flash
if low__setbol(ilastflash,sysflash) then
   begin

   ilist.paintnow;

   end;

end;

function tfilemidi.xlist__onitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   int1,xfileindex,xfilecount,xfilesize,xpos,xlen,xspeed,spos,slen,strim:longint;
   xfolder,xerrmsg,str1:string;
   bol1,xhavefile:boolean;

   function xfilter(x,xdef:string):string;
   begin

   if xhavefile then result:=x else result:=xdef;

   end;

   function s(xcount:longint):string;
   begin

   result:=insstr('s',xcount<>1);

   end;

begin

//handled
result                :=true;

//check
if not imade then exit;

try

//init
xtep                  :=tepFNew20;
xtepcolor             :=clnone;
xcaption              :='';
xcaplabel             :='';
xhelp                 :='';
xcode2                :='';
xcode                 :=0;
xshortcut             :=aknone;
xindent               :=0;//xindex*5;
xflash                :=false;//25mar2021
xenabled              :=true;
xtitle                :=false;//(xindex=3);
xsep                  :=false;
xhavefile             :=(idata.len32>=1);
xlen                  :=1;//safe default
xpos                  :=0;
xspeed                :=100;
slen                  :=1;//safe default
spos                  :=0;
strim                 :=0;
xfilesize             :=str__len32( @idata );

if (ifilehub.folderhub.foldercount>=1) and (ifilehub.folderhub.folder(0) is tfolderhome) then
   begin

   xfolder            :=ifilehub.folderhub.folder(0).name+'\';

   end
else begin

   xfolder            :='\';

   end;

if (ifilehub.folderhub.folderCurrent<>nil) then
   begin

   xfolder            :=xfolder + ifilehub.folderhub.folderCurrent.subFolder;
   xfileindex         :=ifilehub.folderhub.folderCurrent.itemindex;
   xfilecount         :=ifilehub.folderhub.folderCurrent.subcount;

   end
else begin

   xfileindex         :=1;
   xfilecount         :=0;

   end;

if xhavefile then
   begin

   xlen      :=frcmin32(mid_len,1);
   xpos      :=mid_pos;
   xspeed    :=frcmin32(mid_speed,1);

   //speed adjusted values
   slen      := frcmin32(trunc( xlen*(100/xspeed) ),1);
   spos      := trunc( (xpos/xlen)*slen );
   strim     := trunc( (mid_lenfull-mid_len)*(100/xspeed) );

   end;

//.info
case xindex of
//technical
0:begin
   xtep:=tepnone;
   xcaption:='Technical';
   xtitle:=true;
   end;

1:begin

   int1:=mid_handlecount;

   case mid_deviceactive of
   true:str1:='Online' +insstr('  ( '+k64(int1)+' device'+insstr('s',int1<>1)+' in use ) ',int1>=1);
   else str1:='Offline'+insstr(' - failed to open midi device', mid_playing and (mid_outdevicecount>=1) );
   end;//case

   xcaption:='Device Status'+#9+str1;

   end;

2:begin

   int1:=mid_outdevicecount;

   case (int1>=1) of
   true:str1:=k64(int1)+' midi playback device'+s(int1)+' present';
   else str1:='ERROR: No midi playback devices present - no sound';
   end;//case

   xcaption:='Device Count'+#9+str1;

   end;

3:begin

   xerrmsg  :=insstr(' ( '+mid_timermsg+' )',mid_timercode<>0);
   xcaption :='Resolution'+#9+curdec(mid_msrate,2,false)+' ms / '+curdec(mid_mspert100,1,false)+'%'+xerrmsg;//15aug2025, 05mar2022

   end;

4:xcaption:='Name'+#9+xfilter(io__extractfilename(ilastfilename),'-');
5:xcaption:='Folder'+#9+xfolder;
6:xcaption:='Size'+#9+xfilter(low__b(xfilesize,true)+'  ( '+low__mb(xfilesize,true)+' )','-');
7:xcaption:='File'+#9+xfilter(k64(1+xfileindex)+' / '+k64(xfilecount),'-');

8:begin
   int1:=mid_format;
   case int1 of
   0:str1:='Single Track';
   1:str1:='Multi-Track';
   else str1:='Not Supported';
   end;
   xcaption:='Format'+#9+xfilter(intstr32(int1)+' / '+str1,'-');
   end;

9:xcaption:='Tracks'+#9+xfilter(k64(mid_tracks),'-');
10:xcaption:='Messages'+#9+xfilter(k64(mid_msgssent)+' / '+k64(mid_msgs),'-');

//playback
11:begin
   xtep:=tepnone;
   xcaption:='Playback';
   xtitle:=true;
   end;
12:xcaption:='Elapsed'+#9+low__uptime(spos,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32);
13:xcaption:='Remaining'+#9+low__uptime(slen-spos,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32);
14:xcaption:='Total'+#9+low__uptime(slen,(slen>=3600000),(slen>=60000),true,true,ijump.oms,#32)+insstr(' ( '+curdec( (100/xspeed)*100 ,1,true)+'% )',slen<>xlen);
15:xcaption:='Trim'+#9+low__aorbstr('Off', low__uptime(strim,false,false,false,true,ijump.oms,#32)+' of silence', mid_trimtolastnote );
16:xcaption:='Speed'+#9+k64(mid_speed)+'%';
17:xcaption:='State'+#9+low__aorbstr('Stopped','Playing',mid_playing);
else
   begin
   xtep:=tepnone;
   end;
end;//case
except;end;
end;

procedure tfilemidi.xbeatFlash;
var
   xbass:boolean;
   dcount,dtotal,dcount3,dtotal3,xchannel,xnote,vcount,vtotal:longint;
   vave,vave3,vaved,vaveBass:double;
   vtime,v64:comp;
   xinfo:tmidinote;

   function xave(xtotal,xcount:longint):double;
   begin

   result:=frcrangeD64( ( xtotal/frcmin32(xcount,1) )*(1/127), 0, 1);

   end;

begin
try

//animate "playback bar" and side "volume bars"
if mid_playing then
   begin

   //init
   v64    :=ms64;

   vtime  :=0;
   vcount :=0;
   vtotal :=0;

   //.drums
   dcount  :=0;
   dtotal  :=0;

   dcount3 :=0;
   dtotal3 :=0;

   //get
   //.channels
   for xchannel:=0 to 15 do
   begin

   xbass   :=mid_voiceisBass( mmsys_mid_voiceindex[ xchannel ] );

   //.notes
   for xnote:=0 to 127 do if mid_trackinginfo(xchannel,xnote,xinfo) and (xinfo.volOUT>=1) and (xinfo.timeOUt>=v64) then
      begin

      //normal notes
      inc(vcount);
      inc(vtotal,xinfo.volOUT);

      //bass.average notes
      if xbass then
         begin

         inc(dcount3);
         inc(dtotal3,xinfo.volOUT);

         end;

      //drum notes
      if (xchannel=9) then
         begin

         inc(dcount,1);
         inc(dtotal,xinfo.volOUT);

         end;

      end;//xnote

   end;//xchannel


   //set
   vave     :=xave(vtotal,vcount);
   vave3    :=xave(dtotal3,dcount3);
   vaved    :=xave(dtotal,dcount);


   if low__setcmp(iLastTimeRef,vtime) then//new notes bring new times -> detect new notes and pulse the bars up/down by 25% - 03sep2025
      begin

      if (vave>=1)  then vave:=(vave*0.75)   else vave:=frcrangeD64(1.25*vave,0,1);
      if (vave3>=1) then vave3:=(vave3*0.75) else vave3:=frcrangeD64(1.25*vave3,0,1);
      if (vaved>=1) then vaved:=(vaved*0.95) else vaved:=frcrangeD64(1.05*vaved,0,1);

      end;

   vaveBass        :=frcrangeD64( vaved + ( vave3*0.3 ) ,0,1);
   ibeatval        :=frcrangeD64( (( vave     + (ibeatval     *5) ) / 6), 0, 1);//choke values 0..1 to avoid accidental numerical runaway overflow
   ibeatvalBass    :=frcrangeD64( (( vaveBass + (ibeatvalBass *2) ) / 3), 0, 1);//faster drift down for drums

   //.immediate up stroke
   if (vaveBass>ibeatvalBass) then ibeatvalBass:=vaveBass;


   //fast timer
   app__turbo;

   end
else
   begin

   ibeatval        :=0;
   ibeatvalBass    :=0;

   end;


//render.rate - 01feb2026
if (ms64>=ifastTimer) then
   begin

   //jump bar animation
   if true then
      begin

      ijump.flashval  :=ibeatval;
      ijump.flashval9 :=ibeatvalBass;

      case 1 of
      0:ijump.power    :=0.20;
      1:ijump.power    :=0.45;
      else ijump.power :=1.00;
      end;//case

      end
   else
      begin

      ijump.flashval  :=0;
      ijump.flashval9 :=0;

      end;


   //reset
   ifastTimer:=add64(ms64,30);

   end;

except;end;
end;

procedure tfilemidi.xsyncInfo;
begin

//check
if not imade then exit;

//get
case (idata.len32>=1) of
true:ijump.setparams( playpos ,playlen ,mid_speed );
else ijump.setparams( 0 ,0 ,100 );
end;//case

if iloaded and (playpos>=playlen) and (not mid_seeking) and playing then
   begin

   ifilehub.nextFile;

   end;

end;

function  tfilemidi.on__cmd(const xcode2:string):boolean;
var
   v:string;
   v32:longint32;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin

//defaults
result      :=true;//handled
v           :='';
v32         :=0;

//get
if m('list.doubleclick') then
   begin

   playToggle;

   end

else if mv('jump.mustpos') then
   begin

   play;

   setplaypos( round32( (ijump.hoverpert/100) * playlen ) );

   end

else if m('stop') then
   begin

   stop;

   end

else if m('play') then
   begin

   playToggle;

   end

else if m('mixer') then
   begin

   low__showvol;

   end

else if mv('vol.') then
   begin

   if      (v='-')   then ivol.val:=mid_vol - 10
   else if (v='+')   then ivol.val:=mid_vol + 10
   else if (v='100') then ivol.val:=100;

   end

else if mv('speed.') then
   begin

   if      (v='-')   then v32:=mid_speed - 2
   else if (v='+')   then v32:=mid_speed + 2
   else if (v='100') then v32:=100;

   ispeed.val         :=frcrange32( v32 ,50 ,200 );

   end

else begin

   //not handled
   result   :=false;

   end;

end;

function tfilemidi.canstop:boolean;
begin

result      :=mid_canstop;

end;

procedure tfilemidi.on__stop;
begin

mid_stop;

end;

function  tfilemidi.playpos:longint32;
begin

result      :=mid_pos;

end;

procedure tfilemidi.setplaypos(const xnewpos:longint32);
begin

mid_setpos( xnewpos );

end;

function  tfilemidi.playlen:longint32;
begin

result      :=mid_len;

end;

function tfilemidi.canplay:boolean;
begin

result      :=mid_canplay;

end;

procedure tfilemidi.on__play;
begin

if inewdata then
   begin

   inewdata :=false;

   mid_playmidi( idata );

   end

else mid_play;

end;

function tfilemidi.playing:boolean;
begin

result      :=mid_playing;

end;


//## tfilesprite ###############################################################

function  tfilesprite.canloaddatatype(const xdatatype:tdatatype):boolean;
begin

result      :=(xdatatype=dt_sprite);

end;

function  tfilesprite.canloadfileext(const lext:string):boolean;
begin

result      :=(lext='pic8');

end;

procedure tfilesprite.on__create;
begin

//start game engine and use subframes
gossgame__start;
game__setsubframes( true );

//vars
oclsarea              :=false;
iflashref             :='';
iimage                :=miscom32(1,1);

pic8__init( isprite ,1 ,1 );

ipreview              :=tpre8.create( client ,nil ,@isprite );
ipreview.oautoheight  :=true;

//events
ipreview.onmustcode   :=x__onmustcode;

end;

procedure tfilesprite.on__destroy;
begin

//controls
ipreview.disconnect;

freeobj(@iimage);

end;

procedure tfilesprite.on__load;
begin

//get
pic8__fromdata( isprite ,idata.text );
pic8__renderinit( isprite );

ipreview.paintnow;

end;

procedure tfilesprite.on__unload;
begin

inherited on__unload;

end;

procedure tfilesprite.on__timer;
begin

//cycle flashers
game__flashcycle(false);

//repaint sprite
if pic8__mustpaint( isprite ,iflashref ) then
   begin

   app__turbo;

   pic8__renderinit( isprite );

   ipreview.paintnow;

   end;

end;

function tfilesprite.fetchImage(var x:tcommonimage):boolean;
begin

result      :=iloaded and pic8__toimage( isprite ,iimage );
x           :=iimage;

end;

function tfilesprite.supcopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of
fc_copy ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal:result   :=true;
else                                                                                                        result   :=false;
end;//case

end;

function tfilesprite.cancopyformat(const xformat:tfilecopyformat):boolean;
begin

case xformat of

fc_copy ,fc_pngB64 ,fc_jpgB64 ,fc_icoB64 ,fc_gifB64 ,fc_pngPascal ,fc_jpgPascal ,fc_icoPascal ,fc_gifPascal:begin

             result   :=iloaded and (idata.len32>=1) and ( (isprite.w>=2) or (isprite.h>=2) );

             end;

else         result   :=false;

end;//case

end;

procedure tfilesprite.copyformat(const xformat:tfilecopyformat);
var
   d                  :tobject;

begin

//defaults
d                     :=nil;

//check
if not cancopyformat(xformat) then exit;

try

//init
d           :=misraw32(1,1);
pic8__toimage( isprite ,d );

//get
case xformat of

fc_copy               :clip__copyimage( d );

fc_pngPascal          :clip__copyimageAsArrayByte( d ,'png' ,true ,false );
fc_jpgPascal          :clip__copyimageAsArrayByte( d ,'jpg' ,true ,false );
fc_icoPascal          :clip__copyimageAsArrayByte( d ,'ico' ,true ,false );
fc_gifPascal          :clip__copyimageAsArrayByte( d ,'gif' ,true ,false );

fc_pngB64             :clip__copyimageAsBase64( d ,'png' ,true ,false );
fc_jpgB64             :clip__copyimageAsBase64( d ,'jpg' ,true ,false );
fc_icoB64             :clip__copyimageAsBase64( d ,'ico' ,true ,false );
fc_gifB64             :clip__copyimageAsBase64( d ,'gif' ,true ,false );

end;//case

except;end;

//free
freeobj(@d);

end;


//## tmanagecursor #############################################################

const
//default Win11 Arrow Cursor - 15may2026
win11__arrow__small//.cur
:array[0..184] of byte=(
120,1,228,146,49,14,194,48,12,69,191,43,36,70,26,6,86,218,76,12,189,3,220,140,34,144,88,144,184,1,28,5,142,195,41,106,126,34,80,108,232,194,140,165,151,244,251,185,145,82,21,168,32,104,154,154,171,224,81,1,11,0,43,210,144,13,17,76,184,2,119,186,209,234,58,168,234,168,250,135,102,240,151,148,88,151,134,240,179,186,220,98,222,22,157,228,71,110,237,56,125,140,33,148,3,83,142,102,34,103,115,96,206,101,60,191,111,116,206,70,167,108,117,202,86,51,59,205,236,52,196,107,240,190,174,196,165,239,192,255,230,183,90,171,14,75,213,11,57,241,249,64,250,45,153,190,152,113,167,235,223,125,85,221,145,61,57,146,51,185,146,27,73,245,4,0,0,255,255,3,0,187,195,122,229);

win11__arrow__large//.png
:array[0..856] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,47,0,0,0,68,8,6,0,0,0,17,20,108,53,0,0,3,32,73,68,65,84,120,1,212,154,59,114,194,48,16,134,149,71,155,3,80,209,229,0,84,164,74,149,38,84,164,74,149,138,138,28,128,138,138,28,32,21,21,57,131,43,114,12,46,64,147,142,11,80,165,73,246,103,144,177,245,178,245,178,165,157,217,177,65,150,244,253,203,122,37,3,140,49,118,69,158,165,93,19,245,51,249,44,71,122,192,195,214,228,217,9,224,240,89,10,168,194,103,39,64,132,207,74,128,10,62,27,1,58,248,44,4,152,224,147,23,32,193,79,38,19,64,87,45,217,50,42,193,47,151,75,54,155,73,37,63,73,1,18,60,66,190,94,175,179,16,160,132,207,69,128,22,62,7,1,70,248,212,5,52,194,167,44,160,21,124,170,2,90,195,167,40,192,10,62,53,1,214,240,41,9,112,130,79,69,128,51,124,10,2,188,224,251,22,224,13,223,167,128,32,240,13,2,164,61,54,174,15,97,193,224,1,163,217,141,22,212,20,69,64,80,248,174,5,4,135,239,82,64,20,248,174,4,68,131,239,66,64,84,248,216,2,162,195,199,20,208,9,124,44,1,157,193,115,1,138,239,133,156,215,
129,78,225,33,160,40,10,22,74,64,231,240,33,5,244,2,31,74,64,111,240,33,4,244,10,239,43,160,119,120,31,1,73,192,187,10,72,6,222,69,64,82,240,182,2,110,209,33,134,237,118,59,6,119,49,44,98,219,237,86,236,138,149,120,74,94,54,68,131,31,12,6,108,62,159,139,0,190,175,107,2,162,165,13,224,21,63,15,249,194,163,127,185,23,114,130,63,28,14,108,56,28,50,28,77,134,223,183,34,217,73,128,53,60,242,120,60,30,159,192,87,171,149,145,77,19,125,228,210,48,128,127,91,229,60,7,231,196,155,205,134,33,186,128,212,25,218,113,93,197,240,83,227,23,249,95,229,61,167,211,214,145,23,193,249,108,14,209,31,81,95,252,199,199,219,90,193,235,192,49,59,162,234,144,251,65,110,134,70,120,13,120,237,78,21,210,66,138,168,34,247,17,125,239,111,209,140,240,26,112,172,60,99,242,82,0,82,167,143,232,107,225,177,194,161,170,8,134,213,237,225,12,94,43,53,109,162,47,60,254,121,71,95,9,15,240,233,20,43,113,205,0,254,66,206,171,4,42,70,175,209,151,224,145,42,45,192,161,10,34,172,162,63,26,141,196,135,111,175,232,75,240,138,
253,136,24,113,128,115,11,17,125,212,125,39,147,224,133,81,76,224,184,52,68,244,81,117,240,9,88,155,9,190,9,156,79,22,34,250,78,117,95,7,143,245,188,122,115,114,80,213,17,209,175,173,255,138,189,120,217,15,109,138,212,116,138,190,10,30,32,239,228,188,170,148,19,27,78,62,168,173,86,121,196,107,121,33,64,49,192,185,194,172,23,173,27,26,228,158,252,245,60,152,11,56,231,184,163,147,71,188,56,30,143,167,205,26,170,11,64,17,233,197,98,193,246,251,61,191,182,122,68,122,62,145,227,104,101,213,93,165,15,56,38,69,244,81,57,78,91,76,172,186,72,17,67,10,1,22,219,227,242,19,163,115,43,195,223,207,121,190,213,106,182,213,40,151,139,113,227,53,221,124,128,198,92,202,220,185,12,213,124,6,120,184,77,126,155,70,197,88,63,228,170,13,126,48,104,14,128,156,15,109,101,238,159,7,6,244,27,249,39,185,115,138,156,199,138,126,64,212,127,201,241,156,233,180,248,68,39,108,152,64,149,54,13,93,236,155,255,1,0,0,255,255,3,0,179,3,85,176,140,240,10,126,0,0,0,0,73,69,78,68,174,66,96,130);

//default Win11 Hand Cursor - 15may2026
win11__hand__small//.cur
:array[0..280] of byte=(
120,1,172,141,177,74,195,80,20,134,255,196,4,42,56,116,18,178,101,116,148,32,130,83,178,103,17,164,25,116,52,185,29,178,136,186,73,72,209,119,200,160,163,15,16,112,136,67,150,142,121,12,179,57,102,44,65,122,122,146,230,214,164,80,186,244,92,190,123,249,254,195,57,23,80,161,192,52,199,56,225,243,171,2,167,0,206,24,147,113,24,5,26,223,192,156,123,187,202,247,125,20,69,1,215,117,145,36,9,234,186,70,20,69,48,12,3,105,154,194,178,44,148,101,185,107,252,208,185,118,115,117,219,219,57,250,16,34,124,248,15,222,4,215,215,198,71,151,141,223,111,252,184,81,17,58,50,240,90,23,102,231,250,90,133,92,248,34,178,54,233,250,90,22,124,246,93,13,175,215,19,114,254,17,122,152,231,121,38,29,208,131,187,201,119,210,119,111,50,221,231,79,14,100,233,129,247,252,46,133,95,61,120,157,245,148,189,111,77,127,143,79,135,125,245,98,232,135,51,218,174,229,17,209,66,33,170,64,244,131,152,230,204,12,118,11,96,47,153,191,142,229,152,243,115,166,26,16,83,197,59,42,155,137,135,44,182,63,35,90,1,0,0,255,255,3,0,
155,112,153,182);

win11__hand__large//.png
:array[0..1571] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,61,0,0,0,77,8,6,0,0,0,21,64,108,40,0,0,5,235,73,68,65,84,120,1,236,154,61,118,219,56,16,199,185,201,190,183,85,250,168,210,29,84,41,149,251,117,229,84,169,92,185,242,94,96,27,87,202,21,226,202,57,64,154,117,229,51,196,149,115,0,55,113,229,156,193,77,50,63,132,131,12,71,144,72,49,160,72,120,53,239,141,0,226,139,248,99,6,152,25,80,85,53,44,45,100,248,51,225,139,58,61,150,244,15,225,81,105,168,9,204,4,213,181,48,160,61,61,74,193,74,248,202,87,236,235,249,197,0,47,98,33,55,1,230,117,44,200,165,48,82,31,133,134,0,253,159,32,73,73,216,3,4,56,11,176,119,202,13,26,176,81,130,139,197,162,186,189,189,173,158,158,158,170,135,135,135,234,236,140,237,29,9,192,236,245,189,83,110,208,17,48,72,174,175,175,43,128,67,179,217,172,186,188,188,140,207,161,208,44,80,253,188,151,36,55,232,168,214,128,5,168,167,227,227,198,186,208,96,189,145,239,148,249,57,55,232,214,233,165,22,162,181,83,230,6,123,7,157,121,254,189,134,59,128,238,181,108,5,118,58,
72,186,64,161,245,154,242,65,210,189,150,173,192,78,7,73,23,40,180,94,83,254,95,74,250,207,94,75,149,183,19,161,23,14,185,250,224,92,50,220,8,115,201,64,62,59,77,1,180,15,47,1,79,224,194,98,156,8,223,9,103,165,41,171,55,224,185,129,225,38,6,70,27,88,32,46,31,72,121,238,117,221,53,5,73,135,16,84,67,206,155,155,155,234,241,49,106,53,192,63,11,147,194,158,104,184,179,54,140,46,105,66,77,110,87,184,96,128,185,97,209,139,135,26,33,170,158,2,76,53,229,104,131,214,35,121,242,244,129,147,154,48,186,164,185,66,242,49,246,197,197,69,117,114,130,0,215,137,182,70,19,104,160,192,57,252,56,7,116,1,168,131,40,231,246,53,158,13,163,131,118,82,101,146,149,170,122,120,168,127,88,8,24,2,244,249,249,121,197,86,168,73,37,171,207,54,101,239,83,191,20,14,251,102,116,245,182,179,219,148,103,97,20,48,109,144,54,91,97,7,66,250,183,194,65,221,139,1,237,1,2,60,165,17,44,6,23,146,176,171,7,248,7,198,25,93,189,61,152,212,179,223,243,218,198,237,237,32,125,123,205,12,232,229,114,89,221,221,197,237,28,204,92,
17,146,86,144,62,245,160,45,96,109,235,202,144,246,235,162,65,43,48,210,77,218,96,219,104,254,217,128,86,64,93,210,3,232,46,171,244,28,218,28,36,253,28,164,216,5,195,65,210,110,149,52,98,73,70,42,174,109,81,143,41,143,12,175,133,104,5,39,93,35,22,92,26,188,251,247,194,223,133,139,38,15,26,47,30,192,158,52,138,161,142,48,237,163,112,47,240,26,60,136,107,168,55,5,143,18,45,105,62,190,87,2,12,222,25,156,14,113,60,146,109,196,205,92,224,149,73,61,20,251,182,101,44,104,0,165,0,219,49,24,153,133,65,27,222,10,239,12,28,208,117,56,169,179,212,84,134,251,69,137,96,225,87,101,157,115,109,214,234,55,21,232,65,166,96,98,59,124,86,34,22,66,186,196,42,2,250,179,112,145,251,93,65,255,140,206,107,200,128,133,1,14,104,174,112,120,118,132,250,21,9,28,208,72,11,201,5,66,245,92,100,18,202,41,227,46,203,73,189,72,224,128,126,45,28,247,85,10,112,64,45,63,44,200,115,0,174,234,173,184,90,83,36,189,5,120,92,188,214,129,70,108,0,232,111,246,253,230,150,193,22,55,242,91,128,7,51,67,99,183,13,26,253,199,
126,0,52,102,39,222,167,92,93,93,249,43,214,228,28,55,0,143,109,183,109,147,216,104,164,140,170,55,14,71,36,174,87,187,144,2,175,237,110,236,194,73,223,215,134,198,65,6,204,168,157,37,197,252,68,245,196,84,193,93,137,109,129,119,196,2,76,73,181,209,92,39,196,185,130,6,27,128,185,27,142,164,182,58,22,20,152,73,129,86,245,6,14,251,186,241,45,197,125,69,40,16,114,122,202,22,52,45,136,164,26,27,154,111,74,93,78,244,244,240,147,44,157,217,128,67,103,200,63,0,80,245,24,124,0,60,97,155,181,253,164,211,212,249,146,2,13,136,127,132,113,52,130,123,202,1,197,151,130,82,129,3,200,146,61,200,108,57,249,181,19,93,221,80,223,112,202,207,124,217,116,159,125,151,219,64,43,240,175,146,137,238,37,246,151,143,99,165,80,234,244,110,3,13,54,0,99,202,34,240,93,109,56,131,140,69,171,213,170,130,13,253,213,5,52,237,139,181,225,168,182,249,120,207,181,212,220,155,44,179,32,141,108,177,54,220,125,217,12,49,70,87,73,235,10,224,151,54,124,83,78,116,239,123,107,227,177,83,0,207,231,115,59,13,244,124,181,201,
100,217,134,54,79,39,246,118,180,225,152,50,174,147,82,246,208,118,28,35,111,212,90,95,31,254,164,178,43,104,58,55,108,56,5,83,181,225,14,52,251,249,11,243,221,85,189,233,3,209,175,17,149,77,205,134,39,84,27,79,51,184,216,125,65,43,240,175,146,137,166,108,74,54,156,96,9,27,109,136,96,42,168,247,75,83,216,39,251,73,58,189,19,126,69,231,251,251,123,146,234,232,232,40,164,99,253,32,229,211,211,83,251,122,78,237,127,181,224,119,36,173,99,76,206,134,59,219,204,60,163,148,121,200,1,154,113,56,205,27,95,3,18,255,227,162,221,224,148,240,181,81,233,198,61,65,87,231,164,109,178,108,158,134,175,199,106,59,247,175,109,140,223,174,39,238,119,193,5,99,54,230,69,65,46,73,51,22,180,246,213,147,195,141,107,167,161,237,56,128,49,157,142,226,137,109,203,115,73,90,199,196,134,55,142,76,212,141,201,56,155,169,237,179,164,250,14,55,24,106,205,124,214,40,183,164,245,5,107,123,156,10,164,78,132,150,203,109,69,186,152,166,196,117,22,167,245,27,225,228,167,228,161,64,131,145,83,221,254,1,157,178,64,128,
230,99,0,139,208,71,237,177,191,72,119,131,246,32,225,183,194,73,192,76,96,72,208,58,254,7,201,68,95,157,66,75,0,103,17,116,1,116,17,176,181,150,145,166,178,237,239,242,28,90,239,133,55,2,166,253,208,160,121,7,132,212,137,206,194,157,27,5,153,9,233,226,98,226,95,183,210,190,64,235,68,0,143,212,1,31,221,87,173,236,145,2,150,131,147,180,51,237,27,180,78,140,247,254,45,12,248,93,22,128,3,74,249,163,228,183,170,177,212,79,154,144,58,224,209,2,189,168,80,141,160,28,13,201,38,160,31,0,0,0,255,255,3,0,171,188,178,234,191,22,174,45,0,0,0,0,73,69,78,68,174,66,96,130);


constructor tmanagecursor.create;
var
   p:longint32;

begin

//self
if classnameis('tmanagecursor') then track__inc(satOther,1);
inherited create;

//create
iundoinfo   :=str__new8;
mundo__init( iundoinfo ,high(ilist[0].undoslot)+1 );

for p:=0 to high(ilist) do xinititem(tsetcursor(p));

end;

destructor tmanagecursor.destroy;
var
   p:longint32;

begin
try

//free
for p:=0 to high(ilist) do xfreeitem(tsetcursor(p));

str__free(@iundoinfo);

//self
inherited destroy;
if classnameis('tmanagecursor') then track__inc(satOther,-1);

except;end;
end;

function tmanagecursor.xfinddefault(const xindex:tsetcursor):string;//11may2026

   procedure s(const xdata:array of byte);
   var
      dkey:hkey;
      dext,v,e:string;
      a:tstr8;
      b:tbasicimage;
      vbuf:array[0..max_path] of char;

      function m(const n:string):boolean;
      begin

      result:=strmatch(n,dext);

      end;

   begin

   //defaults
   a        :=nil;
   b        :=nil;

   //check
   if (low(xdata)<>0) then exit;

   try

   //init
   a        :=str__new8;

   //from registry based filename first
   if (ilist[longint32(xindex)].reg_name<>'') then
      begin

      v     :=reg__readval(0,'Control Panel\Cursors\'+ilist[longint32(xindex)].reg_name,false);

      //decode shortened filenames -> e.g. "%SystemRoot%\cursors\arrow_eoa.cur' - 11may2026
      if (v<>'') then
         begin

         low__cls(@vbuf,sizeof(vbuf));

         case (win____ExpandEnvironmentStrings( pchar(v) ,@vbuf, sizeof(vbuf) )>=1) of
         true:v:=string(vbuf);
         else v:='';
         end;//case

         end;

      //read cursor data
      if (v<>'') then
         begin

         io__fromfile64( v ,@a ,e );

         //check format
         dext         :=io__anyformatb( @a );

         case m('ico') or m('cur') or m('ani') of//ico is required - 11may2026
         true:;//OK
         else begin//convert to cur - 08jun2026

            //read
            b         :=misimg32(1,1);
            if mis__fromdata( b, @a ,e ) then
               begin

               //write as "cur" with auto-hotspot creation
               if not mis__todata( b ,@a, 'cur', e) then
                  begin

                  a.clear;

                  end;

               end
            else a.clear;

            end;

         end;//case

         end;

      end;

   //fallback -> get cursor data from built-in content - 11may2026
   if (a.len32<=0) then
      begin

      a.aadd( xdata );

      if strmatch('zip',io__anyformatb(@a)) then
         begin

         low__decompress( @a );

         end;

      end;

   //set
   result   :=a.text;

   except;end;

   //free
   freeobj(@a);
   freeobj(@b);

   end;

begin

//defaults
result      :='';

//get
case xindex of

sc_arrow    :begin

   case (cursor__size<=32) of
   true:s(win11__arrow__small);
   else s(win11__arrow__large);
   end;//case

   end;

sc_hand     :begin

   case (cursor__size<=32) of
   true:s(win11__hand__small);
   else s(win11__hand__large);
   end;//case

   end;

end;//case

end;

procedure tmanagecursor.mousePropertiesDialog;
begin

io__runwait1('control','main.cpl',1);//Win95-Win11

end;

procedure tmanagecursor.mouseSettingsDialog;
begin

if not io__runwait1('ms-settings:easeofaccess-mousepointer','',1) then
   begin

   if (app__gui<>nil) then app__gui.poperror('Not Found','Option not available on this operating system version');

   end;

end;

function tmanagecursor.xfindOCRIndex(const xindex:tsetcursor):longint32;
begin

case longint32(xindex) of
longint32(sc_arrow)   :result:=ocr_normal;
longint32(sc_hand)    :result:=ocr_hand;
else                   result:=ocr_normal;
end;//case

end;

function tmanagecursor.xfindREGname(const xindex:tsetcursor):string;
begin

case longint32(xindex) of
longint32(sc_arrow)   :result:='Arrow';
longint32(sc_hand)    :result:='Hand';
else                   result:='Arrow';
end;//case

end;

procedure tmanagecursor.xinititem(const xindex:tsetcursor);
var
   p:longint;

begin

//check
if not can(xindex) then exit;

//get
with ilist[ longint32(xindex) ] do
begin

for p:=0 to high(undoslot) do
begin

undoslot[p]           :='';

end;//p

ocr_index             :=xfindOCRIndex   ( xindex );
res_name              :=makeintresource ( ocr_index );
reg_name              :=xfindREGname    ( xindex );

//default cursor
lastdata              :=xfindDefault( xindex );

end;//with

end;

procedure tmanagecursor.xfreeitem(const xindex:tsetcursor);
begin

//check
if not can(xindex) then exit;

end;

function tmanagecursor.xfromstr(const xindex:tsetcursor;const xdata:string):boolean;
var
   df:string;

begin

//defaults
result      :=false;

//get
if can(xindex) and (xdata<>'') then
   begin

   //write cursor to file
   df       :=app__folderSettings(true) + 'cursor.cur';

   //write to file
   if io__tofilestr2( df ,xdata ) then
      begin

      //read from file
      result:=win____SetSystemCursor( win____LoadCursorFromFile( pchar(df) ) ,ilist[longint32(xindex)].ocr_index );

      end;

   //remove temp file
   io__remfile( df );

   end;

end;

function tmanagecursor.can(const xindex:tsetcursor):boolean;
begin

result      :=(longint32(xindex)>=0) and (longint32(xindex)<=high(ilist));

end;

function tmanagecursor.canreset:boolean;
begin

result      :=true;

end;

function tmanagecursor.reset:boolean;
var
   p:longint;

begin

for p:=0 to longint32(high(tsetcursor)) do
begin

fromstr( tsetcursor(p) , xfinddefault(tsetcursor(p)) );

end;//p

end;

function tmanagecursor.canundo:boolean;
begin

result      :=mundo__canundo( iundoinfo );

end;

function tmanagecursor.undo:boolean;
var
   p,i:longint32;
   s,d:string;

begin

//defaults
result      :=canundo;

//get
if result and mundo__undo( iundoinfo ,i ) then
   begin

   for p:=0 to longint32(high(tsetcursor)) do
   begin

   s                         :=ilist[p].undoslot[i];
   d                         :=ilist[p].lastdata;

   ilist[p].undoslot[i]      :=d;
   ilist[p].lastdata         :=s;

   xfromstr( tsetcursor(p) ,s );

   end;//p

   end;

end;

function tmanagecursor.canredo:boolean;
begin

result      :=mundo__canredo( iundoinfo );

end;

function tmanagecursor.redo:boolean;
var
   p,i:longint32;
   s,d:string;

begin

//defaults
result      :=canredo;

//get
if result and mundo__redo( iundoinfo ,i ) then
   begin

   for p:=0 to longint32(high(tsetcursor)) do
   begin

   s                         :=ilist[p].undoslot[i];
   d                         :=ilist[p].lastdata;

   ilist[p].undoslot[i]      :=d;
   ilist[p].lastdata         :=s;

   xfromstr( tsetcursor(p) ,s );

   end;//p

   end;

end;

function tmanagecursor.canfromdata(const xindex:tsetcursor):boolean;
begin

result      :=can(xindex);

end;

function tmanagecursor.fromdata(const xindex:tsetcursor;const xdata:pobject):boolean;
var
   dext:string;
   p,i:longint32;

   function m(n:string):boolean;
   begin

   result   :=strmatch( n ,dext );

   end;

begin

//defaults
result      :=false;

//check
if not canfromdata(xindex) then exit;
if not str__lock( xdata )  then exit;

try

//check format -> empty data -> default cursor from "xfinddefault()"
case (str__len32(xdata)=0) of
true:dext:='cur';
else dext:=io__anyformatb( xdata );
end;//case

//get
if m('ico') or m('cur') or m('ani') then
   begin

   result   :=xfromstr( xindex ,str__text(xdata) );

   if result then
      begin

      i                         :=mundo__newslot( iundoinfo );

      for p:=0 to longint32(high(tsetcursor)) do
      begin

      if (p=longint32(xindex)) then
         begin

         ilist[p].undoslot[i]   :=ilist[p].lastdata;
         ilist[p].lastdata      :=str__text(xdata);

         end
      else begin

         ilist[p].undoslot[i]   :=ilist[p].lastdata;

         end;

      end;//p

      end;

   end;

except;end;

//free
str__uaf( xdata );

end;

function tmanagecursor.xisfilename(const x:string):boolean;
begin

result      :=(strcopy1(x,2,2)=':\');

end;

function tmanagecursor.canfromfile(const xindex:tsetcursor):boolean;
begin

result      :=can(xindex);

end;

function tmanagecursor.fromfile(const xindex:tsetcursor;const xfilename:string):boolean;
begin

case canfromfile(xindex) and xisFilename(xfilename) of
true:result :=fromstr( xindex ,io__fromfilestr2(xfilename) );
else result :=false;
end;//case

end;

function tmanagecursor.canfromstr(const xindex:tsetcursor):boolean;
begin

result      :=canfromdata( xindex );

end;

function tmanagecursor.fromstr(const xindex:tsetcursor;const xdata:string):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromstr( xindex ) then exit;
if (xdata='')               then exit;

try

//init
a           :=str__new8;
a.sadd( xdata );


//get
result      :=fromdata( xindex ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;

function tmanagecursor.canfromrec(const xindex:tsetcursor):boolean;
begin

result      :=canfromdata( xindex );

end;

function tmanagecursor.fromrec(const xindex:tsetcursor;const xdata:array of byte):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromrec( xindex ) then exit;
if (low(xdata)<>0)          then exit;

try

//init
a           :=str__new8;
a.aadd( xdata );


//get
result      :=fromdata( xindex ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;


//## tmanagebackground #########################################################

constructor tmanagebackground.create;
var
   p:longint32;
   a:pointer;

begin

//self
if classnameis('tmanagebackground') then track__inc(satOther,1);
inherited create;

//init
iundoinfo   :=str__new8;
mundo__init( iundoinfo ,high(ilist[0].dslot) + 1 );

icom        :=com__create( class_desktopwallpaper ) as IDesktopWallpaper;
icount      :=frcrange32( monitors__count ,1 ,high(ilist)+1 );

for p:=0 to pred(icount) do xinititem(p);

end;

destructor tmanagebackground.destroy;
var
   p:longint32;

begin
try

//free
for p:=0 to pred(icount) do xfreeitem(p);

str__free(@iundoinfo);

//self
inherited destroy;
if classnameis('tmanagebackground') then track__inc(satOther,-1);

except;end;
end;

function tmanagebackground.canmode(const xmode:tsetmonitor):boolean;
begin

result      :=(longint32(xmode)>=0) and (longint32(xmode)<=longint32(high(tsetmonitor)));

end;

function tmanagebackground.xtempfile(const xindex:longint):string;
begin//one temp file per monitor

result      :=app__foldersettings(true) + 'background'+intstr32(frcrange32(xindex,0,pred(icount)))+'.bmp';

end;

procedure tmanagebackground.xinititem(const xindex:longint32);
var
   p:longint;

begin

//check
if (xindex<0) or (xindex>=icount) then exit;

//get
with ilist[ xindex ] do
begin

dlast                 :='';
wlast                 :=filename[ xindex ];

//check if currently set background is ours, if so, load the image into RAM and ignore the filename
if strmatch( wlast ,xtempfile( xindex ) ) then
   begin

   dlast              :=io__fromfilestr2( xtempfile( xindex ) );
   wlast              :='';

   end;

for p:=0 to high(dslot) do
begin

dslot[p]              :='';
wslot[p]              :='';

end;//p

end;//with

end;

procedure tmanagebackground.xfreeitem(const xindex:longint32);
begin

//check
if (xindex<0) or (xindex>=icount) then exit;

end;

function tmanagebackground.getfilename(xindex:longint):widestring;
var
   vbuf:array[0..max_path] of char;

begin

//range check
if (xindex<0) or (xindex>=icount) then
   begin

   result   :='';

   end

//modern access
else if (icom<>nil) then
   begin

   result   :=widestring( icom.getwallpaper( icom.GetMonitorDevicePathAt( frcrange32(xindex,0,pred(icount)) ) ) );

   end

//fallback access
else if win____SystemParametersInfo( 115, sizeof(vbuf), @vbuf, 0 ) then//115 = 0x0073 = GetWallpaper
   begin

   result   :=string(vbuf);

   end
else begin

   result   :='';

   end;

end;

procedure tmanagebackground.setfilename(xindex:longint;x:widestring);
var
   v:string;

begin
try

//range check
if (xindex<0) or (xindex>=icount) then
   begin

   //nil

   end

//modern access
else if (icom<>nil) then
   begin

   icom.setwallpaper( icom.GetMonitorDevicePathAt( xindex ) ,pwidechar(x) );

   end

//fallback access -> Works on Windows 95 - 15may2026
else begin

   v        :=string(x);
   win____SystemParametersInfo( 20, 0, pchar(v), 1 or 2 );//20 = 0x0014 = SetWallpaper | 1=SPIF_UPDATEINIFILE or 2=SPIF_SENDWININICHANGE

   end;

except;end;
end;

function tmanagebackground.xfromstr(const xindex:longint;const ddata:string;wdata:widestring):boolean;
var
   a:tbasicimage;
   b:tstr8;
   e:string;

   procedure s;
   begin

   result             :=true;
   filename[ xindex ] :=wdata;

   end;

begin

//defaults
result      :=false;
a           :=nil;
b           :=nil;

//check
if (xindex<0) or (xindex>=icount) then exit;

try

//use image data
if (ddata<>'') then
   begin

   wdata :=xtempfile(xindex);

   a     :=misimg24(1,1);//24bit image -> compatible with Windows 95+ - 15may2026
   b     :=str__new8;
   b.sadd( ddata );

   mis__fromdata( a ,@b ,e );

   mis__tofile( a ,string(wdata) ,io__readfileext_low(string(wdata)) ,e );//writes a 24-bit Bitmap

   s;

   end

//use filename
else begin

   s;

   end;

except;end;

//free
if (a<>nil) then freeobj(@a);
if (b<>nil) then str__free(@b);

end;

function tmanagebackground.canundo:boolean;
begin

result:=mundo__canundo( iundoinfo );

end;

function tmanagebackground.undo:boolean;
var
   p,i:longint32;
   lw,sw:widestring;
   ld,sd:string;

begin

//defaults
result      :=canundo;

//get
if result and mundo__undo( iundoinfo ,i ) then
   begin

   for p:=0 to pred(icount) do
   begin

   sd                        :=ilist[p].dslot[i];
   sw                        :=ilist[p].wslot[i];

   ld                        :=ilist[p].dlast;
   lw                        :=ilist[p].wlast;

   ilist[p].dslot[i]         :=ld;
   ilist[p].wslot[i]         :=lw;

   ilist[p].dlast            :=sd;
   ilist[p].wlast            :=sw;

   xfromstr( p ,sd ,sw );

   end;//p

   end;

end;

function tmanagebackground.canredo:boolean;
begin

result:=mundo__canredo( iundoinfo );

end;

function tmanagebackground.redo:boolean;
var
   p,i:longint32;
   sd,ld:string;
   sw,lw:widestring;

begin

//defaults
result      :=canredo;

//get
if result and mundo__redo( iundoinfo ,i ) then
   begin

   for p:=0 to pred(icount) do
   begin

   sd                        :=ilist[p].dslot[i];
   sw                        :=ilist[p].wslot[i];

   ld                        :=ilist[p].dlast;
   lw                        :=ilist[p].wlast;

   ilist[p].dslot[i]         :=ld;
   ilist[p].wslot[i]         :=lw;

   ilist[p].dlast            :=sd;
   ilist[p].wlast            :=sw;

   xfromstr( p ,sd ,sw );

   end;//p

   end;

end;

procedure tmanagebackground.pageBackground;
begin

//Windows 10+
if not io__runwait1('ms-settings:personalization-background','',1) then
   begin

   //Windows 95+
   io__runwait1('control','desk.cpl',1);

   end;

end;

function tmanagebackground.canfromdata(const xmode:tsetmonitor):boolean;
begin

result      :=canmode(xmode);

end;

function tmanagebackground.fromdata(const xmode:tsetmonitor;const xdata:pobject):boolean;
var
   p,i:longint32;

begin

//defaults
result      :=false;

//check
if not canfromdata(xmode) then exit;
if not str__lock( xdata ) then exit;

try

//get
if io__imageExtSupported( io__anyformatb( xdata ) ) then
   begin

   //init
   result   :=true;
   i        :=mundo__newslot( iundoinfo );

   //get
   for p:=0 to pred(icount) do
   begin

   if (xmode=sm_all) or ((xmode=sm_one) and (app__gui<>nil) and (app__gui.form__monitorindex=p)) then
      begin

      xfromstr( p ,str__text(xdata) ,'' );

      ilist[p].dslot[i]      :=ilist[p].dlast;
      ilist[p].wslot[i]      :=ilist[p].wlast;

      ilist[p].dlast         :=str__text(xdata);
      ilist[p].wlast         :='';

      end
   else begin

      ilist[p].dslot[i]      :=ilist[p].dlast;
      ilist[p].wslot[i]      :=ilist[p].wlast;

      end;

   end;//p

   end;

except;end;

//free
str__uaf( xdata );

end;

function tmanagebackground.xisfilename(const x:string):boolean;
begin

result      :=(strcopy1(x,2,2)=':\');

end;

function tmanagebackground.canfromfile(const xmode:tsetmonitor):boolean;
begin

result      :=canmode( xmode );

end;

function tmanagebackground.fromfile(const xmode:tsetmonitor;const xfilename:string):boolean;
begin

case canfromfile(xmode) and xisFilename(xfilename) of
true:result :=fromstr( xmode ,io__fromfilestr2(xfilename) );
else result :=false;
end;//case

end;

function tmanagebackground.canfromstr(const xmode:tsetmonitor):boolean;
begin

result      :=canfromdata( xmode );

end;

function tmanagebackground.fromstr(const xmode:tsetmonitor;const xdata:string):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromstr( xmode )  then exit;
if (xdata='')               then exit;

try

//init
a           :=str__new8;
a.sadd( xdata );


//get
result      :=fromdata( xmode ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;

function tmanagebackground.canfromrec(const xmode:tsetmonitor):boolean;
begin

result      :=canfromdata( xmode );

end;

function tmanagebackground.fromrec(const xmode:tsetmonitor;const xdata:array of byte):boolean;
var
   a:tstr8;

begin

//defaults
result      :=false;
a           :=nil;

//check
if not canfromrec( xmode )  then exit;
if (low(xdata)<>0)          then exit;

try

//init
a           :=str__new8;
a.aadd( xdata );


//get
result      :=fromdata( xmode ,@a );

except;end;

//free
if (a<>nil) then str__free(@a);

end;


//## tmanagecustomcursorcolors #################################################

constructor tmanagecustomcursorcolors.create2(xparent:tobject;xscroll,xstart:boolean);

   function nc(const n,xhelp:string;const x:tbasiccontrol):tbasiccolor;
   begin

   result                       :=x.ncolor('','');

   with result do
   begin

   oshaderange                  :=false;
   opopcolor                    :=true;
   caption                      :=n;
   help                         :=xhelp;

   end;

   end;

begin

//self
inherited create2(xparent,xscroll,xstart);

//vars
oautoheight                     :=true;
itimer100                       :=slowms64;
itimer500                       :=slowms64;
icolorLock                      :=false;
icolorref                       :='';
ilastcanEdit                    :=false;

//controls
xcols.style                     :=bcLeftToRight;
xcols.omakeautoheight           :=true;

with xcols.makecol(0,50,false) do
begin

tbar                            :=xtoolbar;

with tbar do
begin

add('Adjust',tepSelectAll20,0,'adjust' ,
 'Cursor Adjustment Scope|'+
 'Toggle adjustment scope between "All" and "One".'+
 '|*|All = Adjust all cursors at once in the cursor scheme'+
 '|One = Adjust only the selected cursor'+
 '');

add('Speed',tepPlay20,0,'speed' ,
 'Cursor Playback Speed|'+
 'Click to increment animation playback speed from 25% to 200%'+
 '|*|Note:|A short delay may occur for playback speeds over 100% due to realtime caching.  '+
 'Caching is complete when the play symbol stops flashing.'+
 '');

add('Mirror',tepMirror20,0,'mirror' ,
 'Mirror Cursor|'+
 'Flip cursor(s) horizontally'+
 '');

end;

end;

with xcols.makecol(1,30,false) do
begin

ibody2                          :=nc('Main Body','',client);
ibody2.help                     :=
 'Main Body Color|Change the middle area / main body color of the cursor.  Best set to a bright shade '+
 'to contrast against the darker outer body color for depth.';

end;

with xcols.makecol(2,30,false) do
begin

ibody                           :=nc('Outer Body','',client);
ibody.help                      :=
 'Outer Body Color|Change the left / right edge color shades.  Best set to a dark shade '+
 'to contrast the main body color for depth.';

end;

with xcols.makecol(3,30,false) do
begin

ibody3                          :=nc('Alt Body','',client);
ibody3.help                     :=
 'Alt Body Color|Set an alternative main body color.  Used by styles "colors", '+
 '"colors2" and "colors3".  The cursor''s main body color is vertically shaded / cycled between main and alt body colors.';

end;

//load custom colors
cursor__customcolors_load;

ibody.color                     :=body;
ibody2.color                    :=body2;
ibody3.color                    :=body3;

//events
ibody.oncolor                   :=on__color;
ibody2.oncolor                  :=on__color;
ibody3.oncolor                  :=on__color;
tbar.onclick                    :=on__click;


//start
if xstart then start;

end;

destructor tmanagecustomcursorcolors.destroy;
begin
try

//save custom colors
cursor__customcolors_save;

//self
inherited destroy;

except;end;
end;

procedure tmanagecustomcursorcolors.xupdatebuttons;
var
   xspeed                    :longint32;
   p                         :longint32;
   xok                       :boolean;

begin

//init
xspeed                       :=cursor__speed;
xok                          :=cursor_customcolors.useshared or (cursor_customcolors.cf_index>=0);

//get
with tbar do
begin

bcap2['adjust']              :='Adjust: ' + low__aorbstr('One','All',cursor_customcolors.useshared);

bmarked2 ['mirror']          :=cursor__mirror;
benabled2 ['mirror']         :=xok;

bcap2['speed']               :='Speed: '+k64(cursor__speed)+'%';
bflash2['speed']             :=cursor_customcolors.statusCaching;
benabled2['speed']           :=cursor_customcolors.canSpeed and xok;

end;

//color columns
for p:=1 to 3 do
begin

xcols.vis[p]:= xok and cursor_customcolors.canEdit and
            ( (p<>3) or ((cursor_customcolors.info.ct>=ct_colors) and (cursor_customcolors.info.ct<=ct_colors3)) );

end;//p

end;

procedure tmanagecustomcursorcolors.on__click(sender:tobject);
begin

if (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 );

end;

procedure tmanagecustomcursorcolors.xcmd(const xcode2:string);
var
   xresult            :boolean;
   v                  :string;
   v32                :longint32;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin


//defaults
xresult               :=true;
v                     :='';
v32                   :=0;


//get
if m('speed') then
   begin

   case cursor__speed of
   25   :cursor__setspeed( 50 );
   50   :cursor__setspeed( 75 );
   75   :cursor__setspeed( 100 );
   100  :cursor__setspeed( 150 );
   150  :cursor__setspeed( 200 );
   200  :cursor__setspeed( 25 );
   else  cursor__setspeed( 100 );
   end;//case

   end

else if mv('adjust') then
   begin

   cursor__setscopeAll( not cursor__scopeAll )

   end

else if mv('mirror') then
   begin

   cursor__setmirror( not cursor__mirror )

   end;

//finish
xupdatebuttons;

end;

procedure tmanagecustomcursorcolors._ontimer(sender:tobject);
var
   xmustupdate        :boolean;

begin

//defaults
xmustupdate           :=false;

//self
inherited _ontimer(sender);

//itimer100
if (slowms64>=itimer100) then
   begin

   //read custom cursor colors to local color palettes
   if low__setstr( icolorref ,bolstr(cursor_customcolors.useshared)+'|'+intstr32(cursor_customcolors.cf_index) ) then
      begin

      //prevent color changes
      icolorLock      :=true;

      //get
      ibody.color     :=body;
      ibody2.color    :=body2;
      ibody3.color    :=body3;

      xmustupdate     :=true;

      //unlock

      icolorLock      :=false;

      end;

   //detect canedit mode change
   if low__setbol( ilastcanEdit ,cursor_customcolors.canedit ) then
      begin

      xmustupdate     :=true;

      end;

   //reset
   itimer100:=add64(slowms64,100);

   end;

//itimer500
if (slowms64>=itimer500) or xmustupdate then
   begin

   //xupdatebuttons
   xupdatebuttons;

   //reset
   itimer500:=add64(slowms64,500);

   end;

end;

function tmanagecustomcursorcolors.getbody:longint32;
begin

case cursor_customcolors.useshared of
true:result :=cursor_customcolors.shared.body;
else result :=cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].body;
end;//case

end;

function tmanagecustomcursorcolors.getbody2:longint32;
begin

case cursor_customcolors.useshared of
true:result :=cursor_customcolors.shared.body2;
else result :=cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].body2;
end;//case

end;

function tmanagecustomcursorcolors.getbody3:longint32;
begin

case cursor_customcolors.useshared of
true:result :=cursor_customcolors.shared.body3;
else result :=cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].body3;
end;//case

end;

function tmanagecustomcursorcolors.getspeed:longint32;
begin

result      :=cursor__speed;

end;

procedure tmanagecustomcursorcolors.xsetcolor(const s:longint32;var d:longint32);
begin

if (s<>d) then
   begin

   d        :=s;

   rollid32( cursor_customcolors.changeId );

   end;

end;

procedure tmanagecustomcursorcolors.setbody(x:longint32);
begin

case cursor_customcolors.useshared of
true:xsetcolor( x ,cursor_customcolors.shared.body );
else xsetcolor( x ,cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].body );
end;//case

end;

procedure tmanagecustomcursorcolors.setbody2(x:longint32);
begin

case cursor_customcolors.useshared of
true:xsetcolor( x ,cursor_customcolors.shared.body2 );
else xsetcolor( x ,cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].body2 );
end;//case

end;

procedure tmanagecustomcursorcolors.setbody3(x:longint32);
begin

case cursor_customcolors.useshared of
true:xsetcolor( x ,cursor_customcolors.shared.body3 );
else xsetcolor( x ,cursor_customcolors.clist[ frcrange32( cursor_customcolors.cf_index ,0 ,cf_max ) ].body3 );
end;//case

end;

procedure tmanagecustomcursorcolors.setspeed(x:longint32);
begin

cursor__setspeed( x );

end;

procedure tmanagecustomcursorcolors.on__color(sender:tobject;xval:longint);

begin

//check
if icolorLock then exit;

//get
if      (sender = ibody)  then body   :=xval
else if (sender = ibody2) then body2  :=xval
else if (sender = ibody3) then body3  :=xval;

end;


//## tmanagecustomwallpapereffects #############################################

constructor tmanagecustomwallpapereffects.create2(xparent:tobject;xscroll,xstart:boolean);

   function nc(const n,xhelp:string;const x:tbasiccontrol):tbasiccolor;
   begin

   result                       :=x.ncolor('','');

   with result do
   begin

   oshaderange                  :=false;
   opopcolor                    :=true;
   caption                      :=n;
   help                         :=xhelp;

   end;

   end;

begin

//self
inherited create2(xparent,xscroll,xstart);

//vars
oautoheight                     :=true;
itimer100                       :=slowms64;
itimer500                       :=slowms64;
ilastChangeId                   :=0;

//controls
xcols.style                     :=bcLeftToRight;
xcols.omakeautoheight           :=true;

with xcols.makecol(0,50,false) do
begin

tbar                            :=xtoolbar;

with tbar do
begin

add('Mirror',tepMirror20,0,'mirror' ,
 'Wallpaper Effect - Mirror|'+
 'Flip wallpaper horizontally'+
 '');

addsep;

add('Brightness',tepNew20,0,'brightness' ,
 'Wallpaper Effect - Brightness|'+
 'Adjust wallpaper brightness from 50% to 200%'+
 '');

 add('Fade',tepNew20,0,'fade' ,
 'Wallpaper Effect - Fade|'+
 'Fade wallpaper: Left, right, top, bottom, or off'+
 '');

add('Pixelate',tepNew20,0,'pixelate' ,
 'Wallpaper Effect - Pixelate|'+
 'Pixelate wallpaper: 32x32 px, 64x64 px, 128x128 px, or off'+
 '');

addsep;

add('All Off',tepClose20,0,'alloff',
 'Wallpaper Effects|'+
 'Turn off all wallpaper effects'+
 '');

end;

end;

//load custom effects
wallpaper__customeffects_load;

//events
tbar.onclick                    :=on__click;

//start
if xstart then start;

end;

destructor tmanagecustomwallpapereffects.destroy;
begin
try

//save custom effects
wallpaper__customeffects_save;

//self
inherited destroy;

except;end;
end;

procedure tmanagecustomwallpapereffects.xupdatebuttons;
var
   p                         :longint32;
   xok                       :boolean;

begin

//get
with tbar do
begin

bmarked2 ['mirror']          :=wallpaper__mirror;

bmarked2 ['fade']            :=(wallpaper__fade<>0);
bmarked2 ['pixelate']        :=(wallpaper__pixelate<>0);
bmarked2 ['brightness']      :=(wallpaper__brightness<>0);

bflash2 ['fade']             :=(wallpaper__fade<>0);
bflash2 ['pixelate']         :=(wallpaper__pixelate<>0);
bflash2 ['brightness']       :=(wallpaper__brightness<>0);

bcap2['fade']                :='Fade: '+wallpaper__fadeLabel( wallpaper__fade );
bcap2['pixelate']            :='Pixelate: '+wallpaper__pixelateLabel( wallpaper__pixelate );
bcap2['brightness']          :='Brightness: '+wallpaper__brightnessLabel( wallpaper__brightness );

benabled2['alloff']          :=wallpaper__mirror or (wallpaper__fade<>0) or (wallpaper__pixelate<>0) or (wallpaper__brightness<>0);

end;

end;

procedure tmanagecustomwallpapereffects.on__click(sender:tobject);
begin

if (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 );

end;

procedure tmanagecustomwallpapereffects.xcmd(const xcode2:string);
var
   xresult            :boolean;
   v                  :string;
   v32                :longint32;
   i                  :longint32;

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin


//defaults
xresult               :=true;
v                     :='';
v32                   :=0;


//get
if mv('mirror') then
   begin

   wallpaper__setmirror( not wallpaper__mirror )

   end

else if mv('fade') then
   begin

   i                  :=succ(wallpaper__fade);
   if (i>wallpaper__fadeMax) then i:=0;
   wallpaper__setfade( i );

   end

else if mv('pixelate') then
   begin

   i                  :=succ(wallpaper__pixelate);
   if (i>wallpaper__pixelateMax) then i:=0;
   wallpaper__setpixelate( i );

   end

else if mv('brightness') then
   begin

   i                  :=succ(wallpaper__brightness);
   if (i>wallpaper__brightnessMax) then i:=0;
   wallpaper__setbrightness( i );

   end

else if mv('alloff') then
   begin

   wallpaper__alloff;

   end;

//finish
xupdatebuttons;

end;

procedure tmanagecustomwallpapereffects._ontimer(sender:tobject);
var
   xmustupdate        :boolean;

begin

//defaults
xmustupdate           :=false;

//self
inherited _ontimer(sender);

//itimer100
if (slowms64>=itimer100) then
   begin

   //detect changes
   if wallpaper__changed( ilastChangeId ) then
      begin

      xmustupdate     :=true;

      end;

   //reset
   itimer100:=add64(slowms64,100);

   end;

//itimer500
if (slowms64>=itimer500) or xmustupdate then
   begin

   //xupdatebuttons
   xupdatebuttons;

   //reset
   itimer500:=add64(slowms64,500);

   end;

end;


//## tmanagedata ###############################################################

constructor tmanagedata.create2(xparent:tobject;xstart:boolean);
begin

//self
inherited create2(xparent,false);

//vars
icursor               :=nil;//auto-create
ibackground           :=nil;//auto-create
idata                 :=nil;
iext                  :='';
icanmanageCursor      :=false;
icanmanageCursorINF   :=false;
icanmanageBackground  :=false;
itimer250             :=slowms64;
ilasthub              :=nil;
fon__cursorInstall    :=nil;


//init
//maketitle3('Cursor',false,false);

normal                :=false;


//cursor buttons ---------------------------------------------------------------

add('Auto',tepImage20,0,'cursor.wantsize',
 'Preview Size'+
 '|Toggle cursor preview size between 128px and 64px'
 );

add('PNG',tepImage20,0,'cursor.png',
 'PNG'+
 '|Select this option to shrink the size of all cursors that are extracted, saved, or installed by compressing their images in PNG format.'+
 '|*|Note:'+
 '|Some old versions of Windows may not support PNG cursors.  In addition, when enabled, this option will slow down processing due to realtime compression.'+
 '');

isep:=addSep;

add('Install',tepSaveAS20,0,'cursor.install',
 'Install'+
 '|Install the selected cursor scheme onto your computer.  All 17 cursors will be installed into your computer''s cursor folder.'+
 '|*|Upon successful installation, a "Mouse Properties" dialog will display.  '+
 'Click the "Pointers" tab, and select your cursor scheme from the "Scheme" drop-down list of installed cursor schemes.'+
 '|*|Click the "OK" button to activate your cursor scheme, and click "Yes" to confirm if required.'+
 '|*|Your cursor scheme will now be active.'+
 '');

add('Install 2',tepSaveAS20,0,'cursor.install2',
 'Install 2'+
 '|Install the selected cursor scheme with a custom name onto your computer.  All 17 cursors will be installed into your computer''s cursor folder.'+
 '|*|Upon successful installation, a "Mouse Properties" dialog will display.  '+
 'Click the "Pointers" tab, and select your cursor scheme from the "Scheme" drop-down list of installed cursor schemes.'+
 '|*|Click the "OK" button to activate your cursor scheme, and click "Yes" to confirm if required.'+
 '|*|Your cursor scheme will now be active.'+
 '');

isep2:=addSep;

//was: add('Set as Arrow (Select)',tepArrow20,0,'cursor.setarrow',
add('Set as Arrow',tepArrow20,0,'cursor.setarrow',
 'Set as Arrow (Select)'+
 '|Use the currently previewed/selected cursor below for your Arrow (Normal Select) mouse pointer.'+
 '|*|Note:|Changes are not permanent and will be lost the next time your computer reboots.  '+
 '|*|To make your cursor permanent:'+
 '|1. Save your cursor to file (bottom panel, last button)'+
 '|2. Then click the "Mouse Properties" button on this toolbar (right)'+
 '|3. A dialog will show, select the "Pointers" tab'+
 '|4. Select "Normal Select" from the list'+
 '|5. Click the "Browse" button and locate your saved cursor'+
 '|6. Click the "Open" button'+
 '|7. And click the "OK" button to close the "Mouse Properties" dialog'+
 '');

//was: add('Set as Hand (Link)',tepHand20,0,'cursor.sethand',
add('Set as Link',tepHand20,0,'cursor.sethand',
 'Set as Link (Hand)'+
 '|Use the currently previewed/selected cursor below for your Link (Hand) mouse pointer.'+
 '|*|Note:|Changes are not permanent and will be lost the next time your computer reboots.  '+
 '|*|To make your cursor permanent:'+
 '|1. Save your cursor to file (bottom panel, last button)'+
 '|2. Then click the "Mouse Properties" button on this toolbar (right)'+
 '|3. A dialog will show, select the "Pointers" tab'+
 '|4. Select "Link Select" from the list'+
 '|5. Click the "Browse" button and locate your saved cursor'+
 '|6. Click the "Open" button'+
 '|7. And click the "OK" button to close the "Mouse Properties" dialog'+
 '');

add('Redo',tepRedo20,0,'cursor.redo','Cursor|Redo last arrow/link cursor change');

add('Undo',tepUndo20,0,'cursor.undo','Cursor|Undo last arrow/link cursor change');

add('Mouse Properties',tepMouseDialog20,0,'cursor.mouseproperties',
 'Mouse Properties Dialog'+
 '|Show the Windows "Mouse Properties" dialog to make permanent changes to your mouse pointer (cursor).'+
 '|*|A cursor customised using this manual method is permanent, and will remain customised even after your computer reboots.'+
 '|*|'+
 'Process:'+
 '|1. Click the "Mouse Properties" button to begin'+
 '|2. Select the "Pointers" tab'+
 '|3. Select the cursor to change, e.g. "Normal Select" (Arrow)'+
 '|4. Click the "Browse" button'+
 '|5. Navigate to your cursor file, select it, and click "Open"'+
 '|6. Click "OK" to set your cursor and close the dialog'+
 '');

add('Mouse & Touch',tepMouseDialog20,0,'cursor.mousesettings',
 'Mouse and Touch Settings'+
 '|Show the Windows "Mouse pointer and touch" settings page, where you can adjust the size of your mouse pointer (cursor).'+
 '|*|Note:'+
 '|This option is only available for Windows 10 and 11.'+
 '');


//background buttons -----------------------------------------------------------

add('Set This Monitor',tepComputerMonitor20,0,'background.setone',
 'Set This Monitor'+
 '|Use the currently previewed image below as this monitor''s Desktop Background Picture'+
 '');

add('Set All Monitors',tepComputerMonitor20,0,'background.setall',
 'Set All Monitors'+
 '|Use the currently previewed image below as the Desktop Background Picture for all monitors'+
 '');

add('Redo',tepRedo20,0,'background.redo','Background|Redo last background change');

add('Undo',tepUndo20,0,'background.undo','Background|Undo last background change');

add('Personalisation',tepThemesDialog20,0,'background.background',
 'Personalisation'+
 '|Show the Windows "Personalisation > Background" settings page for more background picture options, or the "Display Properties" dialog window for older operating system versions.'+
 '');



//events
onclick               :=x__onclick;

//start
if xstart then start;

end;

destructor tmanagedata.destroy;
begin
try

//vars
freeobj(@icursor);
freeobj(@ibackground);

//self
inherited destroy;

except;end;
end;

function  tmanagedata.data:tstr8;
begin

result      :=idata;

end;

function tmanagedata.xfetchdata(var x:tstr8):boolean;
begin

if (ilasthub<>nil) and (ilasthub.fileCurrent<>nil) then
   begin

   x        :=ilasthub.fileCurrent.subdata( true );

   end
else begin

   x        :=nil;

   end;

//successful
result      :=(x<>nil);

end;

procedure tmanagedata.setdata(const x:tfilehub);
begin

//check
if (x=nil) or (x.fileCurrent=nil) or x.issysfile(0) then
   begin

   icanmanageCursorINF          :=false;
   idata                        :=nil;
   iext                         :='';

   end
else begin

   //mainfile
   icanmanageCursorINF          :=strmatch(x.fileCurrent.fileext,'inf');

   //subfile
   idata                        :=x.fileCurrent.subdata( false );
   iext                         :=x.fileCurrent.subdataext;

   end;

//manage support
if icanmanageCursorINF or ((idata<>nil) and (idata.len32>=1)) then
   begin

   //cursor
   icanmanageCursor       :=strmatch(iext,'cur') or strmatch(iext,'ani');

   if (icanmanageCursor or icanmanageCursorINF) and (icursor=nil) then
      begin

      icursor             :=tmanagecursor.create;

      end;

   //background
   icanmanageBackground   :=(not icanmanageCursor) and (not icanmanageCursorINF) and io__imageExtSupported(iext);

   if icanmanageBackground and (ibackground=nil) then
      begin

      ibackground         :=tmanagebackground.create;

      end;

   //last
   ilasthub               :=x;

   end

else begin

   icanmanageCursor       :=false;
   icanmanageCursorINF    :=false;
   icanmanageBackground   :=false;
   ilasthub               :=nil;

   end;

//sync
xupdatebuttons;

end;

procedure tmanagedata.nodata;
begin

setdata( nil );

end;

function tmanagedata.canmanage:boolean;
begin

result      :=icanmanageCursor or icanmanageCursorINF or icanmanageBackground;

end;

function tmanagedata.canmanageCursor:boolean;
begin

result      :=icanmanageCursor or icanmanageCursorINF;

end;

function tmanagedata.canmanageBackground:boolean;
begin

result      :=icanmanageBackground;

end;

procedure tmanagedata._ontimer(sender:tobject);
begin
try

//self
inherited _ontimer(sender);


//.itimer250
if (slowms64>=itimer250) then
   begin

   //updatebuttons
   xupdatebuttons;

   //reset
   itimer250:=add64( slowms64 ,250 );

   end;


except;end;
end;

procedure tmanagedata.xupdatebuttons;
begin

//manage cursor
bvisible2[ 'cursor.setarrow'           ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.sethand'            ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.redo'               ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.undo'               ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.mouseproperties'    ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.mousesettings'      ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.install'            ]         :=icanmanageCursorINF and assigned(on__cursorInstall);//inf files only
bvisible2[ 'cursor.install2'           ]         :=icanmanageCursorINF and assigned(on__cursorInstall);//inf files only
bvisible2[ 'cursor.png'                ]         :=icanmanageCursor or icanmanageCursorINF;
bvisible2[ 'cursor.wantsize'           ]         :=icanmanageCursorINF;//25jun2026
bvisible [ isep                        ]         :=icanmanageCursor or icanmanageCursorINF;//04sep2026
bvisible [ isep2                       ]         :=icanmanageCursor or icanmanageCursorINF;


benabled2[ 'cursor.setarrow'           ]         :=icanmanageCursor;
benabled2[ 'cursor.sethand'            ]         :=icanmanageCursor;
benabled2[ 'cursor.undo'               ]         :=icanmanageCursor and icursor.canundo;
benabled2[ 'cursor.redo'               ]         :=icanmanageCursor and icursor.canredo;
benabled2[ 'cursor.reset'              ]         :=icanmanageCursor and icursor.canreset;
benabled2[ 'cursor.install'            ]         :=icanmanageCursorINF and assigned(on__cursorInstall);
benabled2[ 'cursor.install2'           ]         :=icanmanageCursorINF and assigned(on__cursorInstall);
benabled2[ 'cursor.png'                ]         :=icanmanageCursor or icanmanageCursorINF;
benabled2[ 'cursor.wantsize'           ]         :=icanmanageCursorINF;

bmarked2 [ 'cursor.png'                ]         :=cursor_usepng;
bcap2    [ 'cursor.wantsize'           ]         :=low__aorbstr( 'Auto' ,k64( cursor_wantsize )+'px' ,cursor_wantsize>=1 );



//manage background
bvisible2[ 'background.setone'         ]         :=icanmanageBackground;
bvisible2[ 'background.setall'         ]         :=icanmanageBackground;
bvisible2[ 'background.redo'           ]         :=icanmanageBackground;
bvisible2[ 'background.undo'           ]         :=icanmanageBackground;
bvisible2[ 'background.background'     ]         :=icanmanageBackground;

benabled2[ 'background.setall'         ]         :=icanmanageBackground;
benabled2[ 'background.setone'         ]         :=icanmanageBackground;
benabled2[ 'background.undo'           ]         :=icanmanageBackground and ibackground.canundo;
benabled2[ 'background.redo'           ]         :=icanmanageBackground and ibackground.canredo;

end;

procedure tmanagedata.x__onclick(sender:tobject);
begin

if (sender is tbasictoolbar) then
   begin

   xcmd( (sender as tbasictoolbar).ocode2 );

   end;

end;

procedure tmanagedata.xcmd(const xcode2:string);
label
   skipend;

var
   xresult            :boolean;
   v                  :string;
   e                  :string;
   v32                :longint32;
   x                  :tstr8;//pointer only

   function mv(const x:string):boolean;
   begin

   result             :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result             :=strmatch(x,xcode2);

   end;

begin

//defaults
xresult               :=true;
e                     :=gecTaskfailed;
v                     :='';
v32                   :=0;

try


//cursor support ---------------------------------------------------------------

if m('cursor.setarrow') then
   begin

   if icanmanageCursor and xfetchdata(x) then icursor.fromdata( sc_arrow ,@x );

   end

else if m('cursor.sethand') then
   begin

   if icanmanageCursor and xfetchdata(x) then icursor.fromdata( sc_hand ,@x );

   end

else if m('cursor.install') then
   begin

   if icanmanageCursorINF and assigned(on__cursorInstall) then
      begin

      on__cursorInstall(self,false);

      end;

   end

else if m('cursor.install2') then
   begin

   if icanmanageCursorINF and assigned(on__cursorInstall) then
      begin

      on__cursorInstall(self,true);

      end;

   end

else if m('cursor.png') then
   begin

   cursor_usepng      :=not cursor_usepng;

   end

else if m('cursor.wantsize') then
   begin

   //0 -> 128 -> 64 -> 0
   case cursor_wantsize of
   0   :cursor_wantsize:=128;//128px
   128 :cursor_wantsize:=64;//64px
   64  :cursor_wantsize:=128;
   else cursor_wantsize:=128;
   end;//case

   end

else if m('cursor.undo') then
   begin

   if icanmanageCursor then icursor.undo;

   end

else if m('cursor.redo') then
   begin

   if icanmanageCursor then icursor.redo;

   end

else if m('cursor.reset') then
   begin

   if icanmanageCursor then icursor.reset;

   end

else if m('cursor.mouseproperties') then
   begin

   icursor.mousePropertiesDialog;//16jun2026

   end

else if m('cursor.mousesettings') then
   begin

   icursor.mouseSettingsDialog;//16jun2026

   end


//background support -----------------------------------------------------------

else if m('background.setall') then
   begin

   if icanmanageBackground and xfetchdata(x) then ibackground.fromdata( sm_all, @x );

   end

else if m('background.setone') then
   begin

   if icanmanageBackground and xfetchdata(x) then ibackground.fromdata( sm_one ,@x );

   end

else if m('background.undo') then
   begin

   if icanmanageBackground then ibackground.undo;

   end

else if m('background.redo') then
   begin

   if icanmanageBackground then ibackground.redo;

   end

else if m('background.background') then
   begin

   if icanmanageBackground then ibackground.pageBackground;

   end

else begin

   //nil

   end;
skipend:

except;end;

//finish
xupdatebuttons;

//sbow error
if not xresult then gui.poperror('',e);

end;

procedure tmanagedata.mousePropertiesDialog;
begin

xcmd('cursor.mouseproperties');

end;

end.
