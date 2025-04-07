unit gossroot;

interface

uses
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3} sysutils, classes, {$ifdef jpeg}jpeg, {$endif}gosswin; {$endif}
{$ifdef laz} dialogs, classes, sysutils, math, gosswin; {$endif}
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
{$ifdef d3laz} const stroffset=1; {$else} const stroffset=0; {$endif}  {0 or 1 based string index handling}

//ENABLE or DISABLE support for net or ipsec below:
{$define net} {network support -> file servers and inbound remote clients}
{$define ipsec} {IP address based security and client tracking}

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
//## Library.................. Root (gossroot.pas)
//## Version.................. 4.00.2991 (+10)
//## Items.................... 30
//## Last Updated ............ 02may2024: low__ref256/U, 28apr2024: low__uptime(), 17apr2024
//## Lines of Code............ 17,000+
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
//## | new__*                 | low level procs   | 1.00.010  | 30apr2024   | Creation procs -> create objects using less source code
//## | low__*                 | low level procs   | 1.00.103  | 01may2024   | Support procs
//## | low__b64*              | family of procs   | 1.00.030  | 17apr2024   | Base64 encoding/decoding
//## | block__*               | family of procs   | 1.00.095  | 17apr2024   | Block based memory management procs
//## | str__*                 | family of procs   | 1.00.120  | 17apr2024   | Procs for working with both tstr8 and tstr9 objects
//## | mem__*                 | family of procs   | 1.00.010  | 17apr2024   | Linear memory management procs
//## | track__*               | family of procs   | 1.00.005  | 17apr2024   | Type instance tracking
//## | utf8__*                | family of procs   | 1.00.090  | 15apr2024   | UTF-8 decoding support, 15apr2024: created
//## | twproc                 | tobject           | 1.00.021  | 09feb2024   | Window based window message handler - 09feb2024: fixed destroy(), 23dec2023
//## | tstr8                  | tobjectex         | 1.00.727  | 25feb2024   | 8bit binary memory handler - memory as one chunk - 25feb2024: splice() proc, 26dec2023, 27dec2022, 20mar2022, 27dec2021, 28jul2021, 30apr2021, 14feb2021, 28jan2021, 21aug2020
//## | tstr9                  | tobjectex         | 1.00.255  | 07mar2024   | 8bit binary memory handler - memory as a stream of randomly allocated memory blocks - 07mar2024: softclear2(), 25feb2024: splice() proc, 07feb2024: Optimised for speed, 04feb2024: Created
//## | tvars8                 | tobject           | 1.00.221  | 15jan2024   | 8bit binary replacement for "tdynamicvars" and "tdynamictext" -> simple, fast, and lighter with full binary support (no string used) - 31jan2022, 02jan2022, 16aug2020
//## | tfastvars              | tobject           | 1.00.056  | 24mar2024   | Faster version of tvars8 (10x faster) and simpler - 24mar2024: fixed ilimit (was: max-1 => now: max+1) 07feb2024: updated, 12jan2024: support for tstr9 in sfoundB() proc, 25dec2023
//## | tmask8                 | tobject           | 1.00.360  | 07jul2021   | 10may2020, Rapid 8bit graphic mask for tracking onscreen window areas (square and rounded) at speed: WRITE: 101x[1920x1080] mask redraws in under 500ms ~ 5ms/mask and READ: 101x[1920x1080] mask scans in under 1,100ms ~11ms/mask on Intel Atom 1.1Ghz
//## | tdynamiclist           | tobject           | 1.00.110  | 09feb2024   | Base class for dynamic arrays/lists of differing structures: byte, word, longint, currency, pointer etc. - 09feb2024: removed "protected" for "public", 08aug2017
//## | tdynamicbyte           | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of byte (1b/item) - 09feb2024: removed "protected" for "public", 21jun2006
//## | tdynamicinteger        | tdynamiclist      | 1.00.023  | 09feb2024   | Dynamic array of longint (4b/item) - 09feb2024: removed "protected" for "public", 10jan2012
//## | tdynamicdatetime       | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of tdatetime (8b/item) - 09feb2024: removed "protected" for "public", 25dec2023, 21jun2006
//## | tdynamiccurrency       | tdynamiclist      | 1.00.014  | 09feb2024   | Dynamic array of currency (8b/item) - 09feb2024: removed "protected" for "public", 21jun2006
//## | tdynamiccomp           | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of comp (8b/item) - 09feb2024: removed "protected" for "public", 20oct2012
//## | tdynamicpointer        | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of pointer - 09feb2024: removed "protected" for "public", 21jun2006
//## | tdynamicstring         | tdynamiclist      | 1.00.049  | 09feb2024   | Dynamic array of string - 09feb2024: removed "protected" for "public", 29jul2017, 6oct2005
//## | tdynamicname           | tdynamicstring    | 1.00.025  | 31mar2024   | Dynamic array of STRING with quick lookup system - 31mar2024: updated with comp and to fit new code, 05apr2005: created
//## | tdynamicnamelist       | tdynamicname      | 1.00.045  | 09apr2024   | Dynamically tracks a list of names - 09apr2024: find(), 08feb2020: updated, 30aug2007: created
//## | tdynamicvars           | tobject           | 1.00.200  | 09apr2024   | Dynamic list of name/value pairs, large capacity, rapid lookup system - 09apr2024: added/removed procs to be more inline with tfastvars, 15jun2019: updated, 20oct2018: updated, 13apr2018: updated, 04JUL2013: created
//## | tdynamicstr8           | tdynamiclist      | 1.00.035  | 09feb2024   | Dynamic array of tstr8 - 09feb2024: removed "protected" for "public", 01jan2024, 28dec2023
//## | tdynamicstr9           | tobjectex         | 1.00.155  | 17feb2024   | Dynamic array of tstr9 using memory blocks, 17feb2024: created
//## | tintlist               | tobjectex         | 1.00.155  | 20feb2024   | Dynamic array of longint/pointer using memory blocks, 20feb2024: mincount() fixed, 17feb2024: created
//## | tcmplist               | tobjectex         | 1.00.035  | 20feb2024   | Dynamic array of comp/double/datetime using memory blocks, 20feb2024: mincount() fixed, 17feb2024: created
//## | tmemstr8               | tstream           | 1.00.002  | 23dec2023   | tstringstream replacement based on tstr8
//## ==========================================================================================================================================================================================================================

var
   //tdynamiclist and others - global "incsize" override for intial creation, allows for easy coordinated INCSIZE increase e.g. "incsize=10,000" for much better RAM usage - 22MAY2010
   globaloverride_incSIZE:longint=0;//set to 1 or higher to override controls (used when object is first created)

const
   //memory block size
   system_blocksize          =8192;//do not set below 4096 -> required by tintlist/tstr9 for a large data range

   //message loop sleep delay in milliseconds
   system_timerinterval    =15;//15 ms - 28apr2024

   //.net
   {$ifdef net}system_net_limit=4000;{$else}system_net_limit=3;{$endif}

   //.ipsec
   {$ifdef ipsec}system_ipsec_limit=10000;{$else}system_ipsec_limit=3;{$endif}

   //.core state
   ssMustStart=0;
   ssStarting =1;
   ssRunning  =2;
   ssStopping =3;
   ssStopped  =4;
   ssShutdown =5;
   ssFinished =6;
   ssMax      =6;

   //.run styles
   rsBooting  =0;
   rsUnknown  =1;
   rsConsole  =2;
   rsService  =3;
   rsGUI      =4;
   rsMax      =4;

   //.nurmerical support
   crc_seed       =-306674912;//was $edb88320 - avoid constant range error
   crc_against    =-1;//was $ffffffff
   onemb          =1024000;
   maxheight      =1000000;//1m -> used for max clientheight calculations - 21feb2021
   mincur         =-922337203685477.5807;//note: 0.5808 exceeds range
   maxcur         =922337203685477.5807;
   maxcmp32       =4294967294.0;//actual max is 4294967295, but ".0" rounds it up, hence the "..294.0" - 16dec2016
   min16          =0;
   max16          =65535;
   min32          =-2147483647-1;//makes -2147483648 -> avoids constant range error
   max32          =2147483647;
   min64          =-999999999999999999.0;//18 whole digits - 1 million terabytes
   max64          = 999999999999999999.0;//18 whole digits - 1 million terabytes
   maxword        =max16;
   maxport        =max16;
   maxpointer     =(max32 div sizeof(pointer))-1;
   maxrow         =(max16*10);//safe range (0..655,350) - 28dec2023
   maxpixel       =max32 div 50;//safe even for large color sets such as "tcolor96" - 29apr2020

   //.colors
   clTopLeft      =-1;
   clnone         =255+(255*256)+(255*256*256)+(31*256*256*256);
   clBlack        =$000000;
   clMaroon       =$000080;
   clGreen        =$008000;
   clOlive        =$008080;
   clNavy         =$800000;
   clPurple       =$800080;
   clTeal         =$808000;
   clGray         =$808080;
   clSilver       =$C0C0C0;
   clRed          =$0000FF;
   clLime         =$00FF00;
   clYellow       =$00FFFF;
   clBlue         =$FF0000;
   clFuchsia      =$FF00FF;
   clAqua         =$FFFF00;
   clLtGray       =$C0C0C0;
   clDkGray       =$808080;
   clWhite        =$FFFFFF;
   clDefault      =$20000000;

   //corner styles
   corNone        =0;//same as square - 29aug2020
   corRound       =1;
   corSlight      =2;
   corToSquare    =3;//finished with inner area as a perfect square
   corSlight2     =4;
   corMax         =4;

   //.other
   rcode          =#13#10;
   r10            =#10;
   pcSymSafe      ='-';//used to replace unsafe filename characters

   //system references
   WM_USER              =$0400;//anything below this is reserved
   wm_net_message       =WM_USER + $0001;//route window message for socket based communications to the net__* subsystem

   //System Stats Codes
   track_limit           =200;
   track_endof_overview  =9;
   track_endof_core      =69;
   track_endof_gui       =(track_limit-1);
   //.overview
   satErrors           =0;
   satMaskcapture      =1;
   satPartpaint        =2;
   satFullpaint        =3;
   satDragstart        =4;
   satDragcapture      =5;
   satDragpaint        =6;
   satSizestart        =7;
   satSizecapture      =8;
   satSizepaint        =9;

   //.core
   satBasicprg         =13;
   satObjectex         =14;
   satStr8             =15;
   satMask8            =16;
   satBmp              =17;
   satBasicimage       =18;
   satBWP              =19;
   //.dynamic
   satDynlist          =20;
   satDynbyte          =21;
   satDynint           =22;
   satDynstr           =23;
   satFrame            =24;//31jan2021
   satStringlist       =25;//02feb2021
   satBitmap           =26;
   satMidi             =27;//07feb2021
   satMidiopen         =28;//07feb2021
   satMidiblocks       =29;
   satThread           =30;
   satTimer            =31;//19feb2021
   satVars8            =32;//01may2021
   satJpegimage        =33;//01may2021
   satFile             =34;//was tfilestream - 24dec2023
   satPstring          =35;
   satWave             =36;
   satWaveopen         =37;
   satAny              =38;//09feb2022
   satDyndate          =39;
   satDynstr8          =40;//28dec2023
   satDyncur           =41;
   satDyncomp          =42;
   satDynptr           =43;//04feb2024
   satStr9             =44;//04feb2024
   satDynstr9          =45;//07feb2024
   satBlock            =46;//17feb2024
   satDynname          =47;//31mar2024
   satDynnamelist      =48;//31mar2024
   satDynvars          =49;//09apr2024
   satNV               =50;//09apr2024

   //.gui
   satSystem           =70;
   satControl          =71;
   satTitle            =72;
   satEdit             =73;
   satHead             =74;
   satTick             =75;
   satToolbar          =76;
   satScroll           =77;
   satNav              =78;
   satSplash           =79;
   satHelp             =80;
   satColmatrix        =81;
   satColor            =82;
   satInfo             =83;
   satMenu             =84;
   satCols             =85;
   satSetcolor         =86;
   satOther            =87;//16nov2023

   //nav__.styles
   bnNil               =0;
   bnFav               =1;
   bnFavlist           =2;
   bnNav               =3;
   bnNavlist           =4;
   bnFolder            =5;
   bnOpen              =6;
   bnSave              =7;
   bnNamelist          =8;//11jan2022
   bnMax               =8;

   //nav__list.sortstyle
   nlName              =0;//sort by name - ascending
   nlSize              =1;
   nlDate              =2;
   nlType              =3;
   nlAsis              =4;
   nlNameD             =5;//sort by name - descending
   nlSizeD             =6;
   nlDateD             =7;
   nlTypeD             =8;
   nlAsisD             =9;
   nlMax               =9;
   //nav__list.style
   nltNav              =0;
   nltFolder           =1;
   nltFile             =2;
   nltSysFolder        =3;//fully specified folder (complete drive/folder info)
   nltTitle            =4;
   nltNone             =5;
   nltMax              =5;

   //-- Easy access chars and symbols for use with BYTE arrays -----------------
   //Access ASCII values under Delphi 10+ which no longer supports 8 bit characters
   //numbers 0-9
   nn0 = 48;
   nn1 = 49;
   nn2 = 50;
   nn3 = 51;
   nn4 = 52;
   nn5 = 53;
   nn6 = 54;
   nn7 = 55;
   nn8 = 56;
   nn9 = 57;
   //uppercase letters A-Z
   uuA = 65;
   uuB = 66;
   uuC = 67;
   uuD = 68;
   uuE = 69;
   uuF = 70;
   uuG = 71;
   uuH = 72;
   uuI = 73;
   uuJ = 74;
   uuK = 75;
   uuL = 76;
   uuM = 77;
   uuN = 78;
   uuO = 79;
   uuP = 80;
   uuQ = 81;
   uuR = 82;
   uuS = 83;
   uuT = 84;
   uuU = 85;
   uuV = 86;
   uuW = 87;
   uuX = 88;
   uuY = 89;
   uuZ = 90;
   //lowercase letters a-z
   lla = 97;
   llb = 98;
   llc = 99;
   lld = 100;
   lle = 101;
   llf = 102;
   llg = 103;
   llh = 104;
   lli = 105;
   llj = 106;
   llk = 107;
   lll = 108;
   llm = 109;
   lln = 110;
   llo = 111;
   llp = 112;
   llq = 113;
   llr = 114;
   lls = 115;
   llt = 116;
   llu = 117;
   llv = 118;
   llw = 119;
   llx = 120;
   lly = 121;
   llz = 122;
   //common symbols
   ssdollar = 36;//"$" - 10jan2023
   sspipe = 124;//"|"
   sshash = 35;
   sspert = 37;//"%" - 01apr2024
   ssasterisk = 42;
   ssdash =45;
   ssslash = 47;
   ssbackslash = 92;
   sscolon = 58;
   sssemicolon = 59;
   ssplus = 43;
   sscomma = 44;
   ssminus = 45;//06jul2022
   ssat = 64;
   ssdot = 46;
   ssexclaim = 33;
   ssmorethan = 62;
   sslessthan = 60;
   ssequal    = 61;
   ssquestion = 63;
   ssunderscore =  95;
   ssspace = 32;
   ssspace2 = 160;//05feb2023
   ss10 = 10;
   ss13 = 13;
   ss9 = 9;
   ssTab = 9;
   ssdoublequote=34;
   sspercentage=37;//"%"
   ssampersand=38;//"&"
   sssinglequote=39;
   ssLSquarebracket=91;//"["
   ssRSquarebracket=93;//"]"
   ssLRoundbracket=40;//"("
   ssRRoundbracket=41;//")"
   ssLCurlyBracket=123;//"{"
   ssRCurlyBracket=125;//"}"
   ssSquiggle=126;//"~"


   //system images -------------------------------------------------------------
   //.system "nil" image -> indicates there is no image to work with
   tepNone                 =0;


   //File Extension Codes
   fesep          =';';//main separator -> "bat;bmp;exe;txt+bwd+bwp;ico;"
   feany          ='*';//special

   //G.E.C. -->> General Error Codes v1.00.028, 22jun2005
   gecTaskFailed             ='Task failed';//translate('Task failed')
   gecFileNotFound           ='File not found';//translate('File not found')
   gecOutOfMemory            ='Out of memory';//translate('Out of memory')
   gecBadFileName            ='Bad file name';//translate('Bad file name')
   gecFileInUse              ='File in use, or access denied';//translate('File in use, or access denied') - 13apr2024: updated
   gecOutOfDiskSpace         ='Out of disk space';//translate('Out of disk space')
   gecUnknownFormat          ='Unknown format';//translate('Unknown format')
   gecPathNotFound           ='Path not found';//translate('Path not found')
   gecDataCorrupt            ='Data corrupt';//translate('Data corrupt')
   gecUnsupportedFormat      ='Unsupported format';//translate('Unsupported format')
   gecUnexpectedError        ='Unexpected error';//translate('Unexpected error')
   gecIndexOutOfRange        ='Index out of range';//translate('Index out of range')

   //base64 - references
   base64:array[0..64] of byte=(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47,61);
   base64r:array[0..255] of byte=(113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,110,113,113,113,111,100,101,102,103,104,105,106,107,108,109,113,113,113,112,113,113,113,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,113,113,113,113,113,113,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113);

   //months
   system_month:array[1..12] of string=('January','February','March','April','May','June','July','August','September','October','November','December');
   system_month_abrv:array[1..12] of string=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
   //days
   system_dayOfweek:array[1..7] of string=('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
   system_dayOfweek_abrv:array[1..7] of string=('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

   //tnetbasic
   //.wstreammode
   wsmBuf          =0;
   wsmRAM          =1;
   wsmDisk         =2;
   wsmMax          =2;
   //.hmethod
   hmUNKNOWN       =0;
   hmGET           =1;
   hmHEAD          =2;
   hmPOST          =3;
   hmCONNECT       =4;
   hmMax           =4;
   //.hver (http/1.1 etc)
   hvUnknown       =0;
   hv0_9           =1;//0.9
   hv1_0           =2;//1.0
   hv1_1           =3;//1.1
   hvMax           =3;
   //.hc (connection: close or connection: keep-alive or not set)
   hcUnspecified   =0;
   hcClose         =1;
   hcKeepalive     =2;
   hcUnknown       =3;
   hcMax           =3;



type
   pobject         =^tobject;
   tpointer        =^pointer;
   tevent          =tnotifyevent;//procedure(sender:tobject) of object;
   tdrivelist      =array[0..25] of boolean;//0=A, 1=B, 2=C..25=Z
   tobjectex       =class;
   tstr8           =class;
   tstr9           =class;
   tdynamicbyte    =class;
   tdynamicinteger =class;
   tdynamiccurrency =class;
   tdynamiccomp     =class;
   tdynamicstring   =class;
   tdynamicstr8     =class;
   tdynamicstr9     =class;
   tintlist         =class;
   tcmplist         =class;
   //.color
   pcolor8       =^tcolor8;      tcolor8 =byte;
   pcolor16      =^tcolor16;     tcolor16=word;
   pcolor24      =^tcolor24;     tcolor24=packed record b:byte;g:byte;r:byte;end;//shoulde be packed for safety - 27SEP2011
   pcolor32      =^tcolor32;     tcolor32=packed record b:byte;g:byte;r:byte;a:byte;end;
   pcolor96      =^tcolor96;     tcolor96=packed record v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11:byte;end;
   //.row
   pcolorrow8    =^tcolorrow8;   tcolorrow8 =array[0..maxpixel] of tcolor8;
   pcolorrow16   =^tcolorrow16;  tcolorrow16=array[0..maxpixel] of tcolor16;
   pcolorrow24   =^tcolorrow24;  tcolorrow24=array[0..maxpixel] of tcolor24;
   pcolorrow32   =^tcolorrow32;  tcolorrow32=array[0..maxpixel] of tcolor32;
   pcolorrow96   =^tcolorrow96;  tcolorrow96=array[0..maxpixel] of tcolor96;
   //.rows
   pcolorrows8   =^tcolorrows8 ; tcolorrows8 =array[0..maxrow] of pcolorrow8;
   pcolorrows16  =^tcolorrows16; tcolorrows16=array[0..maxrow] of pcolorrow16;
   pcolorrows24  =^tcolorrows24; tcolorrows24=array[0..maxrow] of pcolorrow24;
   pcolorrows32  =^tcolorrows32; tcolorrows32=array[0..maxrow] of pcolorrow32;
   pcolorrows96  =^tcolorrows96; tcolorrows96=array[0..maxrow] of pcolorrow96;

   prect=^trect;
   trect=record
    case longint of
    0:(left,top,right,bottom:longint);
    1:(topleft,bottomright:tpoint);
    end;


   //.reference arrays
   pbitboolean   =^tbitboolean;  tbitboolean=set of 0..7;
   pdlbitboolean =^tdlbitboolean;tdlbitboolean=array[0..((max32 div sizeof(tbitboolean))-1)] of tbitboolean;
   pdlbyte       =^tdlbyte;      tdlbyte=array[0..((max32 div sizeof(byte))-1)] of byte;
   pdlchar       =^tdlchar;      tdlchar=array[0..((max32 div sizeof(char))-1)] of char;
   pdlsmallint   =^tdlsmallint;  tdlsmallint=array[0..((max32 div sizeof(smallint))-1)] of smallint;
   pdlword       =^tdlword;      tdlword=array[0..((max32 div sizeof(word))-1)] of word;
   pbilongint    =^tbilongint;   tbilongint=array[0..1] of longint;
   pdlbilongint  =^tdlbilongint; tdlbilongint=array[0..((max32 div sizeof(tbilongint))-1)] of tbilongint;
   pdllongint    =^tdllongint;   tdllongint=array[0..((max32 div sizeof(longint))-1)] of longint;
   pdlpoint      =^tdlpoint;     tdlpoint=array[0..((max32 div sizeof(tpoint))-1)] of tpoint;
   pdlcurrency   =^tdlcurrency;  tdlcurrency=array[0..((max32 div sizeof(currency))-1)] of currency;
   pdlcomp       =^tdlcomp;      tdlcomp=array[0..((max32 div sizeof(comp))-1)] of comp;
   pdldouble     =^tdldouble;    tdldouble=array[0..((max32 div sizeof(double))-1)] of double;
   pdldatetime   =^tdldatetime;  tdldatetime=array[0..((max32 div sizeof(tdatetime))-1)] of tdatetime;
   pdlrect       =^tdlrect;      tdlrect=array[0..((max32 div sizeof(trect))-1)] of trect;
   pdlstring     =^tdlstring;    tdlstring=array[0..((max32 div 32)-1)] of pstring;
   pdlpointer    =^tdlpointer;   tdlpointer=array[0..((max32 div sizeof(pointer))-1)] of pointer;
   pdlobject     =^tdlobject;    tdlobject=array[0..((max32 div sizeof(pobject))-1)] of tobject;
   pdlstr8       =^tdlstr8;      tdlstr8=array[0..((max32 div sizeof(pointer))-1)] of tstr8;
   pdlstr9       =^tdlstr9;      tdlstr9=array[0..((max32 div sizeof(pointer))-1)] of tstr9;

   //.conversion records
   pbit8=^tbit8;
   tbit8=record//01may2020 - char discontinued due to Unicode in D10
    case longint of
    0:(bits:tbitboolean);
    1:(val:byte);
    2:(s:shortint);
    end;

   pbyt1=^tbyt1;
   tbyt1=record
    case longint of
    0:(val:byte);
    1:(b:byte);
    2:(s:shortint);
    3:(bits:set of 0..7);
    4:(bol:boolean);
    end;

   pwrd2=^twrd2;
   twrd2=record
    case longint of
    0:(val:word);
    1:(si:smallint);
    3:(bytes:array [0..1] of byte);
    4:(bits:set of 0..15);
    end;

   pint4=^tint4;
   tint4=record
    case longint of
    0:(r,g,b,a:byte);
    1:(val:longint);
    2:(bytes:array [0..3] of byte);
    3:(wrds:array [0..1] of word);
    4:(bols:array [0..3] of bytebool);
    5:(sint:array[0..1] of smallint);
    6:(short:array[0..3] of shortint);
    7:(bits:set of 0..31);
    8:(b0,b1,b2,b3:byte);//26dec2024
    end;

   pcmp8=^tcmp8;
   tcmp8=record
    case longint of
    0:(val:comp);
    1:(cur:currency);
    2:(dbl:double);
    3:(bytes:array[0..7] of byte);
    4:(wrds:array[0..3] of word);
    5:(ints:array[0..1] of longint);
    6:(bits:set of 0..63);
    7:(datetime:tdatetime);
    end;

   pcur8=^tcur8;
   tcur8=record
    case longint of
    0:(val:currency);
    1:(cmp:comp);
    2:(dbl:double);
    3:(bytes:array[0..7] of byte);
    4:(wrds:array[0..3] of word);
    5:(ints:array[0..1] of longint);
    6:(bits:set of 0..63);
    7:(datetime:tdatetime);
    end;

   pext10=^text10;
   text10=record
    case longint of
    0:(val:extended);
    1:(bytes:array[0..9] of byte);
    2:(wrds:array[0..4] of word);
    3:(bits:set of 0..79);
    end;

   plistptr=^tlistptr;
   tlistptr=record
     count:longint;
     bytes:pdlbyte;
     end;

   //.bitmap animation helper record
   panimationinformation=^tanimationinformation;
   tanimationinformation=record
    format:string;//uppercase EXT (e.g. JPG, BMP, SAN etc)
    subformat:string;//same style as format, used for dual format streams "ATEP: 1)animation header + 2)image"
    info:string;//UNICODE WARNING --- optional custom information data block packed at end of image data - 22APR2012
    filename:string;
    map16:string;//UNICODE WARNING --- 26MAY2009 - used in "CAN or Compact Animation" to map all original cells to compacted imagestrip
    transparent:boolean;
    syscolors:boolean;//13apr2021
    flip:boolean;
    mirror:boolean;
    delay:longint;
    itemindex:longint;
    count:longint;//0..X (0=1cell, 1=2cells, etc)
    bpp:byte;
    binary:boolean;
    //cursor - 20JAN2012
    hotspotX:longint;//-1=not set=default
    hotspotY:longint;//-1=not set=default
    hotspotMANUAL:boolean;//use this hotspot instead of automatic hotspot - 03jan2019
    //32bit capable formats
    owrite32bpp:boolean;//default=false, for write modes within "ccs.todata()" where 32bit is used as the default save BPP - 22JAN2012
    //final
    readB64:boolean;//true=image was b64 encoded
    readB128:boolean;//true=image was b128 encoded
    writeB64:boolean;//true=encode image using b64
    writeB128:boolean;//true=encode image using b128 - 09feb2015
    //internal
    iosplit:longint;//position in IO stream that animation sep. (#0 or "#" occurs)
    cellwidth:longint;
    cellheight:longint;
    use32:boolean;
    end;

{low__filelist3}
   tsearchrecevent =function(var xfolder:string;var xrec:tsearchrec;var xsize:comp;var xdate:tdatetime;xisfile,xisfolder:boolean;xhelper:tobject):boolean of object;//return true to keep processing, false=to cancel/stop
   tsearchrecevent2=function(var xfolder:string;var xrec:tsearchrec;var xsize:comp;var xdate:tdatetime;xisfile,xisfolder:boolean;xhelper:tobject):boolean;//return true to keep processing, false=to cancel/stop


{tobjectex}
   tobjectex=class(tobject)
   private

   public
    //"__cacheptr" is reserved for use by "cache__ptr()" proc -> 10feb2024
    __cacheptr:tobject;
   end;

{twproc}
   twproc=class(tobject)
   private
    iwindow:hwnd;
   public
    //create
    constructor create;
    destructor destroy; override;
    //information
    property window:hwnd read iwindow;
   end;

{tdynamiclist}
   tdynamiclistevent=procedure(sender:tobject;index:longint) of object;
   tdynamiclistswapevent=procedure(sender:tobject;x,y:longint) of object;
   tdynamiclist=class(tobject)
   private
    itextsupported:boolean;
    icore:pointer;
    icount,iincsize,ilimit,ibpi,isize:longint;
    ilockedBPI:boolean;
    procedure setcount(x:longint);
    procedure setsize(x:longint);
    procedure setbpi(x:longint);//bytes per item
    procedure setincsize(x:longint);
    function notify(s,f:longint;_event:tdynamiclistevent):boolean;
    procedure sdm_track(xby:comp);
   public
    //vars
    freesorted:boolean;//destroys "sorted" object if TRUE
    sorted:tdynamicinteger;
    //user vars
    utag:longint;
    //events
    oncreateitem:tdynamiclistevent;
    onfreeitem:tdynamiclistevent;
    onswapitems:tdynamiclistswapevent;
    //internal - 07feb2021
    property _textsupported:boolean read itextsupported write itextsupported;
    property _size:longint read isize write isize;
    //create
    constructor create; virtual;
    destructor destroy; override;
    procedure _createsupport; virtual;
    procedure _destroysupport; virtual;
    //workers
    procedure clear; virtual;
    //.add
    function add:boolean;
    function addrange(_count:longint):boolean;
    //.delete
    function _del(x:longint):boolean;//2nd copy - 20oct2018
    function del(x:longint):boolean;
    function delrange(s,_count:longint):boolean;
    //.insert
    function ins(x:longint):boolean;
    function insrange(s,_count:longint):boolean;
    function swap(x,y:longint):boolean;
    function setparams(_count,_size,_bpi:longint):boolean;
    //limits
    property count:longint read icount write setcount;
    property size:longint read isize write setsize;
    function atleast(_size:longint):boolean; virtual;
    property bpi:longint read ibpi write setbpi;//bytes per item
    property limit:longint read ilimit;
    property incsize:longint read iincsize write setincsize;
    function findvalue(_start:longint;_value:pointer):longint;
    function sindex(x:longint):longint;
    //sort
    procedure sort(_asc:boolean);
    procedure nosort;
    procedure nullsort;
    //core
    property core:pointer read icore;
    //support
    procedure _oncreateitem(sender:tobject;index:longint); virtual;
    procedure _onfreeitem(sender:tobject;index:longint); virtual;
    function _setparams(_count,_size,_bpi:longint;_notify:boolean):boolean; virtual;
    procedure shift(s,by:longint); virtual;
    procedure _init; virtual;
    procedure _corehandle; virtual;
    procedure _sort(_asc:boolean); virtual;
   end;

{tdynamicbyte}
   tdynamicbyte=class(tdynamiclist)
   private
    iitems:pdlbyte;
    ibits:pdlbitboolean;
    function getvalue(_index:longint):byte;
    procedure setvalue(_index:longint;_value:byte);
    function getsvalue(_index:longint):byte;
    procedure setsvalue(_index:longint;_value:byte);
   public
    constructor create; override;//01may2019
    destructor destroy; override;//01may2019
    property value[x:longint]:byte read getvalue write setvalue;
    property svalue[x:longint]:byte read getsvalue write setsvalue;
    property items:pdlBYTE read iitems;
    property bits:pdlBITBOOLEAN read ibits;
    function find(_start:longint;_value:byte):longint;
    //support
    procedure _init; override;
    procedure _corehandle; override;
    procedure _sort(_asc:boolean); override;
    procedure __sort(a:pdlBYTE;b:pdllongint;l,r:longint;_asc:boolean);
   end;

{tdynamicinteger}
   tdynamicinteger=class(tdynamiclist)//09feb2022
   private
    iitems:pdllongint;
    function getvalue(_index:longint):longint;
    procedure setvalue(_index:longint;_value:longint);
    function getsvalue(_index:longint):longint;
    procedure setsvalue(_index:longint;_value:longint);
   public
    constructor create; override;//01may2019
    destructor destroy; override;//01may2019
    function copyfrom(s:tdynamicinteger):boolean;//09feb2022
    property value[x:longint]:longint read getvalue write setvalue;
    property svalue[x:longint]:longint read getsvalue write setsvalue;
    property items:pdllongint read iitems;
    function find(_start:longint;_value:longint):longint;
    //support
    procedure _init; override;
    procedure _corehandle; override;
    procedure _sort(_asc:boolean); override;
    procedure __sort(a:pdllongint;b:pdllongint;l,r:longint;_asc:boolean);
   end;

{tdynamicdatetime}
    tdynamicdatetime=class(tdynamiclist)
    private
     iitems:pdlDATETIME;
     function getvalue(_index:longint):tdatetime;
     procedure setvalue(_index:longint;_value:tdatetime);
     function getsvalue(_index:longint):tdatetime;
     procedure setsvalue(_index:longint;_value:tdatetime);
    public
     constructor create; override;
     destructor destroy; override;
     property value[x:longint]:tdatetime read getvalue write setvalue;
     property svalue[x:longint]:tdatetime read getsvalue write setsvalue;
     property items:pdlDATETIME read iitems;
     function find(_start:longint;_value:tdatetime):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlDATETIME;b:pdllongint;l,r:longint;_asc:boolean);
    end;

{tdynamiccurrency}
    tdynamiccurrency=class(tdynamiclist)
    private
     iitems:pdlCURRENCY;
     function getvalue(_index:longint):currency;
     procedure setvalue(_index:longint;_value:currency);
     function getsvalue(_index:longint):currency;
     procedure setsvalue(_index:longint;_value:currency);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:longint]:currency read getvalue write setvalue;
     property svalue[x:longint]:currency read getsvalue write setsvalue;
     property items:pdlCURRENCY read iitems;
     function find(_start:longint;_value:currency):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlCURRENCY;b:pdllongint;l,r:longint;_asc:boolean);
    end;

{tdynamiccomp}
    tdynamiccomp=class(tdynamiclist)//20OCT2012
    private
     iitems:pdlCOMP;
     function getvalue(_index:longint):comp;
     procedure setvalue(_index:longint;_value:comp);
     function getsvalue(_index:longint):comp;
     procedure setsvalue(_index:longint;_value:comp);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:longint]:comp read getvalue write setvalue;
     property svalue[x:longint]:comp read getsvalue write setsvalue;
     property items:pdlCOMP read iitems;
     function find(_start:longint;_value:comp):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlCOMP;b:pdlLONGINT;l,r:longint;_asc:boolean);
    end;

{tdynamicpointer}
    tdynamicpointer=class(tdynamiclist)
    private
     iitems:pdlPOINTER;
     function getvalue(_index:longint):pointer;
     procedure setvalue(_index:longint;_value:pointer);
     function getsvalue(_index:longint):pointer;
     procedure setsvalue(_index:longint;_value:pointer);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:longint]:pointer read getvalue write setvalue;
     property svalue[x:longint]:pointer read getsvalue write setsvalue;
     property items:pdlPOINTER read iitems;
     function find(_start:longint;_value:pointer):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
    end;

{tdynamicstring}
    tdynamicstring=class(tdynamiclist)//09feb2022
    private
     iitems:pdlstring;
     function getvalue(_index:longint):string;
     procedure setvalue(_index:longint;_value:string); virtual;
     function getsvalue(_index:longint):string;
     procedure setsvalue(_index:longint;_value:string);
     function gettext:string;
     procedure settext(x:string);
     function getstext:string;
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     function copyfrom(s:tdynamicstring):boolean;//09feb2022
     property text:string read gettext write settext;
     property stext:string read getstext;
     property value[x:longint]:string read getvalue write setvalue;
     property svalue[x:longint]:string read getsvalue write setsvalue;
     property items:pdlstring read iitems;
     function find(_start:longint;_value:string;_casesensitive:boolean):longint;
     //support
     procedure _oncreateitem(sender:tobject;index:longint); override;
     procedure _onfreeitem(sender:tobject;index:longint); override;
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlstring;b:pdllongint;l,r:longint;_asc:boolean);
    end;

{tdynamicname}
    tdynamicname=class(tdynamicstring)
    private
     iref:tdynamiccomp;
     function _setparams(_count,_size,_bpi:longint;_notify:boolean):boolean; override;
     procedure setvalue(_index:longint;_value:string); override;
     procedure shift(s,by:longint); override;
    public
     //create
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     procedure _createsupport; override;
     procedure _destroysupport; override;
     //other
     function findfast(_start:longint;_value:string):longint;
     procedure sync(x:longint);
     //internal
     property ref:tdynamiccomp read iref;
    end;

{tdynamicnamelist}
    tdynamicnamelist=class(tdynamicname)
    private
     iactive:longint;
    public
     //vars
     delshrink:boolean;
     //create
     constructor create; override;
     destructor destroy; override;
     property active:longint read iactive;
     procedure clear; override;
     function add(x:string):longint;
     function addb(x:string;newonly:boolean):longint;
     function addex(x:string;newonly:boolean;var isnewitem:boolean):longint;
     function addonce(x:string):boolean;//true=non-existent and added, false=already exists
     function addonce2(x:string;var xindex:longint):boolean;//08feb2020
     function del(x:string):boolean;
     function have(x:string):boolean;
     function find(x:string;var xindex:longint):boolean;//09apr2024
     function replace(x,y:string):boolean;//can't prevent duplications if this proc is used
     procedure delindex(x:longint);//30AUG2007
    end;

{tdynamicvars}
    tdynamicvars=class(tobject)
    private
     function getcount:longint;
     function getvalue(n:string):string;
     procedure setvalue(n,v:string);
     function getvaluei(x:longint):string;
     function getvaluelen(x:longint):longint;//20oct2018
     function getname(x:longint):string;
     function _find(n,v:string;_newedit:boolean):longint;
     procedure setincsize(x:longint);
     function getincsize:longint;
     function getb(x:string):boolean;
     procedure setb(x:string;y:boolean);
     function getd(x:string):double;
     procedure setd(x:string;y:double);
     function getc(x:string):currency;
     procedure setc(x:string;y:currency);
     function geti64(x:string):comp;
     procedure seti64(x:string;y:comp);
     function geti(x:string):longint;
     procedure seti(x:string;y:longint);
     function getpt(x:string):tpoint;//09JUN2010
     procedure setpt(x:string;y:tpoint);//09JUN2010
     function getnc(x:string):currency;
     function getni(x:string):longint;
     function getni64(x:string):comp;
     function getvalueiptr(x:longint):pstring;
     function getbytes:longint;//13apr2018
    protected
     inamesREF:tdynamiccomp;
     inames:tdynamicstring;
     ivalues:tdynamicstring;
    public
     //vars
     debug:boolean;
     debugtitle:string;
     //create
     constructor create; virtual;
     destructor destroy; override;
     //wrappers
     property s[x:string]:string read getvalue write setvalue;//22SEP2007
     property b[x:string]:boolean read getb write setb;//boolean
     property i[x:string]:longint read geti write seti;//longint
     property ni[x:string]:longint read getni;//numercial comma longint - slow
     property i64[x:string]:comp read geti64 write seti64;//comp - 15jun2019
     property ni64[x:string]:comp read getni64;//numercial comma comp - slow
     property d[x:string]:double read getd write setd;//currency
     property c[x:string]:currency read getc write setc;//currency
     property nc[x:string]:currency read getnc;//numercial comma currency - slow
     property pt[x:string]:tpoint read getpt write setpt;//point - 09JUN2010
     procedure roll(x:string;by:currency);
     property n[x:longint]:string read getname;//name
     property v[x:longint]:string read getvaluei;//value
     //other
     property bytes:longint read getbytes;//13apr2018
     procedure clear; virtual;
     function new(n,v:string):longint;
     function find(n:string;var i:longint):boolean;
     function find2(n:string):longint;
     function found(n:string):boolean;
     property value[n:string]:string read getvalue write setvalue;
     property valuei[x:longint]:string read getvaluei;
     property valuelen[x:longint]:longint read getvaluelen;
     property valueiptr[x:longint]:pstring read getvalueiptr;
     property name[x:longint]:string read getname;
     property count:longint read getcount;
     property incsize:longint read getincsize write setincsize;
     procedure copyfrom(x:tdynamicvars);
     procedure copyvars(x:tdynamicvars;i,e:string);
     procedure delete(x:longint);
     procedure remove(x:longint);//20oct2018
     function rename(sn,dn:string;var e:string):boolean;//22oct2018
     //sort
     procedure sortbyNAME(_asc:boolean);//12jul2016
     procedure sortbyVALUE(_asc,_asnumbers:boolean);//04JUL2013
     procedure sortbyVALUEEX(_asc,_asnumbers,_commentsattop:boolean);//04JUL2013
     //internal
     property namesREF:tdynamiccomp read inamesREF;
     property names:tdynamicstring read inames;
     property values:tdynamicstring read ivalues;
    end;

{tdynamicstr8}
   tdynamicstr8=class(tdynamiclist)
   private
    ifallback:tstr8;
    iitems:pdlSTR8;
    function getvalue(_index:longint):tstr8;
    procedure setvalue(_index:longint;_value:tstr8);
    function getsvalue(_index:longint):tstr8;
    procedure setsvalue(_index:longint;_value:tstr8);
   public
    constructor create; override;
    destructor destroy; override;
    property _fallback:tstr8 read ifallback;//read only
    property value[x:longint]:tstr8 read getvalue write setvalue;
    property svalue[x:longint]:tstr8 read getsvalue write setsvalue;
    property items:pdlSTR8 read iitems;
    function find(_start:longint;_value:tstr8):longint;
    //support
    procedure _init; override;
    procedure _corehandle; override;
    procedure _oncreateitem(sender:tobject;index:longint); override;
    procedure _onfreeitem(sender:tobject;index:longint); override;
   end;

{tdynamicstr9}
   tdynamicstr9=class(tobjectex)
   private
    ifallback:tstr9;
    ilist:tintlist;
    function getvalue(x:longint):tstr9;
    procedure setvalue(x:longint;xval:tstr9);
    function getcount:longint;
    procedure setcount(xnewcount:longint);
    procedure xfreeitem(x:pointer);
   public
    constructor create; virtual;
    destructor destroy; override;
    property _fallback:tstr9 read ifallback;//read only
    //information
    function mem:longint;
    property count:longint read getcount write setcount;
    property value[x:longint]:tstr9 read getvalue write setvalue;
    //workers
    procedure clear;
   end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//6666666666666666666666
{tintlist}
   tintlist=class(tobjectex)//limit of 4,194,304 items when system_blocksize=8192 - 17feb2024
   private
    iroot:pdlpointer;
    igetmin,igetmax,isetmin,isetmax,iblocksize,irootcount,icount,irootlimit,iblocklimit,ilimit:longint;
    igetmem,isetmem:pointer;
    procedure setcount(x:longint);
    function getvalue(x:longint):longint;
    procedure setvalue(x:longint;xval:longint);
    function getptr(x:longint):pointer;
    procedure setptr(x:longint;xval:pointer);
   public
    constructor create; virtual;
    destructor destroy; override;
    //information
    function mem:longint;//memory size in bytes used
    function mem_predict(xcount:comp):comp;//info proc used to predict value of mem
    property limit:longint read ilimit;
    property count:longint read icount write setcount;
    property rootcount:longint read irootcount;
    property rootlimit:longint read irootlimit;//tier 1 limit (iroot)
    property blocklimit:longint read iblocklimit;//tier 2 limit (child of iroot)
    function fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
    //workers
    procedure clear;
    function mincount(xcount:longint):boolean;//fixed 20feb2024
    property value[x:longint]:longint read getvalue write setvalue;
    property int[x:longint]:longint read getvalue write setvalue;
    property ptr[x:longint]:pointer read getptr write setptr;
   end;

{tcmplist}
   tcmplist=class(tobjectex)//limit of ?????????????? items when system_blocksize=8192 - 17feb2024
   private
    iroot:pdlpointer;
    igetmin,igetmax,isetmin,isetmax,iblocksize,irootcount,icount,irootlimit,iblocklimit,ilimit:longint;
    igetmem,isetmem:pointer;
    procedure setcount(x:longint);
    function getvalue(x:longint):comp;
    procedure setvalue(x:longint;xval:comp);
    function getdbl(x:longint):double;
    procedure setdbl(x:longint;xval:double);
    function getdate(x:longint):tdatetime;
    procedure setdate(x:longint;xval:tdatetime);
   public
    constructor create; virtual;
    destructor destroy; override;
    //information
    function mem:longint;//memory size in bytes used
    property limit:longint read ilimit;
    property count:longint read icount write setcount;
    property rootcount:longint read irootcount;
    property rootlimit:longint read irootlimit;//tier 1 limit (iroot)
    property blocklimit:longint read iblocklimit;//tier 2 limit (child of iroot)
    function fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
    //workers
    procedure clear;
    function mincount(xcount:longint):boolean;//fixed 20feb2024
    property value[x:longint]:comp read getvalue write setvalue;
    property cmp[x:longint]:comp read getvalue write setvalue;
    property dbl[x:longint]:double read getdbl write setdbl;
    property date[x:longint]:tdatetime read getdate write setdate;
   end;

{tstr8 - 8bit binary string -> replacement for Delphi 10's lack of 8bit native string - 29apr2020}
   tstr8=class(tobjectex)
   private
    idata:pointer;
    ilockcount,idatalen,icount:longint;//datalen=size of allocated memory | count=size of memory in use by user
    ichars :pdlchar;
    ibytes :pdlbyte;
    iints4 :pdllongint;
    irows8 :pcolorrows8;
    irows15:pcolorrows16;
    irows16:pcolorrows16;
    irows24:pcolorrows24;
    irows32:pcolorrows32;
    function getbytes(x:longint):byte;
    procedure setbytes(x:longint;xval:byte);
    function getbytes1(x:longint):byte;//1-based
    procedure setbytes1(x:longint;xval:byte);
    function getchars(x:longint):char;
    procedure setchars(x:longint;xval:char);
    //get + set support --------------------------------------------------------
    function getcmp8(xpos:longint):comp;
    function getcur8(xpos:longint):currency;
    function getint4(xpos:longint):longint;
    function getint4i(xindex:longint):longint;
    function getint4R(xpos:longint):longint;
    function getint3(xpos:longint):longint;
    function getsml2(xpos:longint):smallint;//28jul2021
    function getwrd2(xpos:longint):word;
    function getwrd2R(xpos:longint):word;
    function getbyt1(xpos:longint):byte;
    function getbol1(xpos:longint):boolean;
    function getchr1(xpos:longint):char;
    function getstr(xpos,xlen:longint):string;//0-based - fixed - 16aug2020
    function getstr1(xpos,xlen:longint):string;//1-based
    function getnullstr(xpos,xlen:longint):string;//20mar2022
    function getnullstr1(xpos,xlen:longint):string;//20mar2022
    function gettext:string;
    procedure settext(x:string);
    function gettextarray:string;
    procedure setcmp8(xpos:longint;xval:comp);
    procedure setcur8(xpos:longint;xval:currency);
    procedure setint4(xpos:longint;xval:longint);
    procedure setint4i(xindex:longint;xval:longint);
    procedure setint4R(xpos:longint;xval:longint);
    procedure setint3(xpos:longint;xval:longint);
    procedure setsml2(xpos:longint;xval:smallint);
    procedure setwrd2(xpos:longint;xval:word);
    procedure setwrd2R(xpos:longint;xval:word);
    procedure setbyt1(xpos:longint;xval:byte);
    procedure setbol1(xpos:longint;xval:boolean);
    procedure setchr1(xpos:longint;xval:char);
    procedure setstr(xpos:longint;xlen:longint;xval:string);//0-based
    procedure setstr1(xpos:longint;xlen:longint;xval:string);//1-based
    //replace support ----------------------------------------------------------
    procedure setreplace(x:tstr8);
    procedure setreplacecmp8(x:comp);
    procedure setreplacecur8(x:currency);
    procedure setreplaceint4(x:longint);
    procedure setreplacewrd2(x:word);
    procedure setreplacebyt1(x:byte);
    procedure setreplacebol1(x:boolean);
    procedure setreplacechr1(x:char);
    procedure setreplacestr(x:string);
    //.ease of use support
    procedure setbdata(x:tstr8);
    function getbdata:tstr8;
    procedure setbappend(x:tstr8);
   public
    //ease of use support options
    oautofree:boolean;//default=false
    otestlock1:boolean;//debug only - 09may2021
    //misc
    tag1:longint;
    tag2:longint;
    tag3:longint;
    tag4:longint;
    //create
    constructor create(xlen:longint); virtual;
    destructor destroy; override;
    function xresize(x:longint;xsetcount:boolean):boolean;
    function copyfrom(s:tstr8):boolean;//09feb2022
    //lock - disables "oautofree" whilst many layers are working on same object - 19aug2020
    procedure lock;
    procedure unlock;
    property lockcount:longint read ilockcount;
    //information
    property core:pointer read idata;//read-only
    property datalen:longint read idatalen;//actual internal size of data buffer - 25sep2020
    property len:longint read icount;
    property count:longint read icount;
    property chars[x:longint]:char read getchars write setchars;
    property bytes[x:longint]:byte read getbytes write setbytes;//0-based
    property bytes1[x:longint]:byte read getbytes1 write setbytes1;//1-based
    function scanline(xfrom:longint):pointer;
    //.rapid access -> no range checking
    property pbytes:pdlbyte       read ibytes;
    property pints4 :pdllongint   read iints4;
    property prows8 :pcolorrows8  read irows8;
    property prows16:pcolorrows16 read irows16;
    property prows24:pcolorrows24 read irows24;
    property prows32:pcolorrows32 read irows32;
    function maplist:tlistptr;//26apr2021, 07apr2021
    //workers
    function clear:boolean;
    function setlen(x:longint):boolean;
    function minlen(x:longint):boolean;
    procedure setcount(x:longint);//07dec2023
    function fill(xfrom,xto:longint;xval:byte):boolean;
    function del(xfrom,xto:longint):boolean;
    function del3(xfrom,xlen:longint):boolean;//27jan2021
    //.object support
    function add(var x:tstr8):boolean;
    function addb(x:tstr8):boolean;
    function add2(var x:tstr8;xfrom,xto:longint):boolean;
    function add3(var x:tstr8;xfrom,xlen:longint):boolean;
    function add31(var x:tstr8;xfrom1,xlen:longint):boolean;//28jul2021
    function ins(var x:tstr8;xpos:longint):boolean;
    function ins2(var x:tstr8;xpos,xfrom,xto:longint):boolean;//26apr2021
    function _ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//08feb2024: tstr9 support, 22apr2022, 27apr2021, 26apr2021
    function owr(var x:tstr8;xpos:longint):boolean;//overwrite -> enlarge if required - 01oct2020
    function owr2(var x:tstr8;xpos,xfrom,xto:longint):boolean;
    //.swappers
    function swap(s:tstr8):boolean;//27dec2021
    //.array support
    function aadd(x:array of byte):boolean;
    function aadd1(x:array of byte;xpos1,xlen:longint):boolean;//1based - 19aug2020
    function aadd2(x:array of byte;xfrom,xto:longint):boolean;
    function ains(x:array of byte;xpos:longint):boolean;
    function ains2(x:array of byte;xpos,xfrom,xto:longint):boolean;
    function padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
    function pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;//07feb2022
    //.add number support -> always append to end of data
    function addcmp8(xval:comp):boolean;
    function addcur8(xval:currency):boolean;
    function addRGBA4(r,g,b,a:byte):boolean;
    function addRGB3(r,g,b:byte):boolean;
    function addint4(xval:longint):boolean;
    function addint4R(xval:longint):boolean;
    function addint3(xval:longint):boolean;
    function addwrd2(xval:word):boolean;
    function addwrd2R(xval:word):boolean;
    function addsmi2(xval:smallint):boolean;//01aug2021
    function addbyt1(xval:byte):boolean;
    function addbol1(xval:boolean):boolean;
    function addchr1(xval:char):boolean;
    function addstr(xval:string):boolean;
    function addrec(a:pointer;asize:longint):boolean;//07feb2022
    //.insert number support -> insert at specified position (0-based)
    function insbyt1(xval:byte;xpos:longint):boolean;
    function insbol1(xval:boolean;xpos:longint):boolean;
    function insint4(xval,xpos:longint):boolean;
    //.string support
    function sadd(var x:string):boolean;//26dec2023, 27apr2021
    function sadd2(var x:string;xfrom,xto:longint):boolean;//26dec2023, 27apr2021
    function sadd3(var x:string;xfrom,xlen:longint):boolean;//26dec2023, 27apr2021
    function saddb(x:string):boolean;//27apr2021
    function sadd2b(x:string;xfrom,xto:longint):boolean;//27apr2021
    function sadd3b(x:string;xfrom,xlen:longint):boolean;//27apr2021
    function sins(var x:string;xpos:longint):boolean;//27apr2021
    function sins2(var x:string;xpos,xfrom,xto:longint):boolean;
    function sinsb(x:string;xpos:longint):boolean;//27apr2021
    function sins2b(x:string;xpos,xfrom,xto:longint):boolean;
    //.push support -> insert data at position "pos" and inc pos to new position
    function pushcmp8(var xpos:longint;xval:comp):boolean;
    function pushcur8(var xpos:longint;xval:currency):boolean;
    function pushint4(var xpos:longint;xval:longint):boolean;
    function pushint4R(var xpos:longint;xval:longint):boolean;
    function pushint3(var xpos:longint;xval:longint):boolean;//range: 0..16777215
    function pushwrd2(var xpos:longint;xval:word):boolean;
    function pushwrd2R(var xpos:longint;xval:word):boolean;
    function pushbyt1(var xpos:longint;xval:byte):boolean;
    function pushbol1(var xpos:longint;xval:boolean):boolean;
    function pushchr1(var xpos:longint;xval:char):boolean;//WARNING: Unicode conversion possible -> use only 0-127 chars????
    function pushstr(var xpos:longint;xval:string):boolean;
    //.get/set support
    property cmp8[xpos:longint]:comp read getcmp8 write setcmp8;
    property cur8[xpos:longint]:currency read getcur8 write setcur8;
    property int4[xpos:longint]:longint read getint4 write setint4;
    property int4i[xindex:longint]:longint read getint4i write setint4i;
    property int4R[xpos:longint]:longint read getint4R write setint4R;
    property int3[xpos:longint]:longint read getint3 write setint3;//range: 0..16777215
    property sml2[xpos:longint]:smallint read getsml2 write setsml2;//28jul2021
    property wrd2[xpos:longint]:word read getwrd2 write setwrd2;
    property wrd2R[xpos:longint]:word read getwrd2R write setwrd2R;
    property byt1[xpos:longint]:byte read getbyt1 write setbyt1;
    property bol1[xpos:longint]:boolean read getbol1 write setbol1;
    property chr1[xpos:longint]:char read getchr1 write setchr1;
    property str[xpos:longint;xlen:longint]:string read getstr write setstr;//0-based
    property str1[xpos:longint;xlen:longint]:string read getstr1 write setstr1;//1-based
    property nullstr[xpos:longint;xlen:longint]:string read getnullstr;//0-based
    property nullstr1[xpos:longint;xlen:longint]:string read getnullstr1;//1-based
    function setarray(xpos:longint;xval:array of byte):boolean;
    property text:string read gettext write settext;//use carefully -> D10 uses unicode
    property textarray:string read gettextarray;
    //.replace support
    property replace:tstr8 write setreplace;
    property replacecmp8:comp write setreplacecmp8;
    property replacecur8:currency write setreplacecur8;
    property replaceint4:longint write setreplaceint4;
    property replacewrd2:word write setreplacewrd2;
    property replacebyt1:byte write setreplacebyt1;
    property replacebol1:boolean write setreplacebol1;
    property replacechr1:char write setreplacechr1;
    property replacestr:string write setreplacestr;
    //.writeto structures - 28jul2021
    function writeto1(a:pointer;asize,xfrom1,xlen:longint):boolean;
    function writeto1b(a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
    function writeto(a:pointer;asize,xfrom0,xlen:longint):boolean;//28jul2021
    //.logic support
    function empty:boolean;
    function notempty:boolean;
    function same(var x:tstr8):boolean;
    function same2(xfrom:longint;var x:tstr8):boolean;
    function asame(x:array of byte):boolean;
    function asame2(xfrom:longint;x:array of byte):boolean;
    function asame3(xfrom:longint;x:array of byte;xcasesensitive:boolean):boolean;
    function asame4(xfrom,xmin,xmax:longint;var x:array of byte;xcasesensitive:boolean):boolean;
    //.converters
    function uppercase:boolean;
    function uppercase1(xpos1,xlen:longint):boolean;
    function lowercase:boolean;
    function lowercase1(xpos1,xlen:longint):boolean;
    //.data block support
    function datpush(n:longint;x:tstr8):boolean;//27jun2022
    function datpull(var xpos,n:longint;x:tstr8):boolean;//27jun2022
    //.ease of use point of access
    property bdata:tstr8 read getbdata write setbdata;
    property bappend:tstr8 write setbappend;
    //.other
    function splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;//25feb2024
   end;

{tstr9 - 8bit binary str spread over multiple memory blocks to ensure maximum memory reuse/reliability}
   tstr9=class(tobjectex)
   private
    ilist:tintlist;
    ilockcount,iblockcount,iblocksize,idatalen,ilen,ilen2,imem:longint;
    igetmin,igetmax,isetmin,isetmax:longint;
    igetmem,isetmem:pdlbyte;
    function getv(xpos:longint):byte;
    procedure setv(xpos:longint;v:byte);
    function getv1(xpos:longint):byte;
    procedure setv1(xpos:longint;v:byte);
    function getchar(xpos:longint):char;
    procedure setchar(xpos:longint;v:char);
    //get + set support --------------------------------------------------------
    function getcmp8(xpos:longint):comp;
    function getcur8(xpos:longint):currency;
    function getint4(xpos:longint):longint;
    function getint4i(xindex:longint):longint;
    function getint4R(xpos:longint):longint;
    function getint3(xpos:longint):longint;
    function getsml2(xpos:longint):smallint;//28jul2021
    function getwrd2(xpos:longint):word;
    function getwrd2R(xpos:longint):word;
    function getbyt1(xpos:longint):byte;
    function getbol1(xpos:longint):boolean;
    function getchr1(xpos:longint):char;
    function getstr(xpos,xlen:longint):string;//0-based - fixed - 16aug2020
    function getstr1(xpos,xlen:longint):string;//1-based
    function getnullstr(xpos,xlen:longint):string;//20mar2022
    function getnullstr1(xpos,xlen:longint):string;//20mar2022
    function gettext:string;
    procedure settext(x:string);
    function gettextarray:string;
    procedure setcmp8(xpos:longint;xval:comp);
    procedure setcur8(xpos:longint;xval:currency);
    procedure setint4(xpos:longint;xval:longint);
    procedure setint4i(xindex:longint;xval:longint);
    procedure setint4R(xpos:longint;xval:longint);
    procedure setint3(xpos:longint;xval:longint);
    procedure setsml2(xpos:longint;xval:smallint);
    procedure setwrd2(xpos:longint;xval:word);
    procedure setwrd2R(xpos:longint;xval:word);
    procedure setbyt1(xpos:longint;xval:byte);
    procedure setbol1(xpos:longint;xval:boolean);
    procedure setchr1(xpos:longint;xval:char);
    procedure setstr(xpos:longint;xlen:longint;xval:string);//0-based
    procedure setstr1(xpos:longint;xlen:longint;xval:string);//1-based
   public
    //ease of use support options
    oautofree:boolean;//default=false
    //misc
    tag1:longint;
    tag2:longint;
    tag3:longint;
    tag4:longint;
    //create
    constructor create(xlen:longint); virtual;
    destructor destroy; override;
    //lock - disables "oautofree" whilst many layers are working on same object - 04feb2020
    procedure lock;
    procedure unlock;
    property lockcount:longint read ilockcount;
    //information
    property len:longint read ilen;//length of data
    property datalen:longint read idatalen;
    property mem:longint read imem;//size of allocated memory
    function mem_predict(xlen:comp):comp;//info proc used to predict value of mem
    //workers
    function softclear:boolean;
    function softclear2(xmaxlen:longint):boolean;//07mar2024
    function clear:boolean;
    function setlen(x:longint):boolean;
    function minlen(x:longint):boolean;//atleast this length, 29feb2024: updated
    property chars[x:longint]:char read getchar write setchar;
    property pbytes[x:longint]:byte read getv write setv;//0-based
    property bytes[x:longint]:byte read getv write setv;//0-based
    property bytes1[x:longint]:byte read getv1 write setv1;//1-based
    function del3(xfrom,xlen:longint):boolean;//06feb2024
    function del(xfrom,xto:longint):boolean;//06feb2024
    //.fast support
    function splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
    function fastinfo(xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;//15feb2024
    function fastadd(var x:array of byte;xsize:longint):longint;
    function fastwrite(var x:array of byte;xsize,xpos:longint):longint;
    function fastread(var x:array of byte;xsize,xpos:longint):longint;
    //.object support
    function add(x:pobject):boolean;
    function addb(x:tobject):boolean;
    function add2(x:pobject;xfrom,xto:longint):boolean;
    function add3(x:pobject;xfrom,xlen:longint):boolean;
    function add31(x:pobject;xfrom1,xlen:longint):boolean;
    function ins(x:pobject;xpos:longint):boolean;
    function ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//79% native speed of tstr8.ins2 which uses a single block of memory
    function owr(x:pobject;xpos:longint):boolean;//overwrite -> enlarge if required
    function owr2(x:pobject;xpos,xfrom,xto:longint):boolean;
    //.array support
    function aadd(x:array of byte):boolean;
    function aadd1(x:array of byte;xpos1,xlen:longint):boolean;//1based
    function aadd2(x:array of byte;xfrom,xto:longint):boolean;
    function ains(x:array of byte;xpos:longint):boolean;
    function ains2(x:array of byte;xpos,xfrom,xto:longint):boolean;
    function padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
    function pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;//07feb2022
    //.add number support -> always append to end of data
    function addcmp8(xval:comp):boolean;
    function addcur8(xval:currency):boolean;
    function addRGBA4(r,g,b,a:byte):boolean;
    function addRGB3(r,g,b:byte):boolean;
    function addint4(xval:longint):boolean;
    function addint4R(xval:longint):boolean;
    function addint3(xval:longint):boolean;
    function addwrd2(xval:word):boolean;
    function addwrd2R(xval:word):boolean;
    function addsmi2(xval:smallint):boolean;//01aug2021
    function addbyt1(xval:byte):boolean;
    function addbol1(xval:boolean):boolean;
    function addchr1(xval:char):boolean;
    function addstr(xval:string):boolean;
    function addrec(a:pointer;asize:longint):boolean;
    //.string support
    function sadd(var x:string):boolean;
    function sadd2(var x:string;xfrom,xto:longint):boolean;
    function sadd3(var x:string;xfrom,xlen:longint):boolean;
    function saddb(x:string):boolean;
    function sadd2b(x:string;xfrom,xto:longint):boolean;
    function sadd3b(x:string;xfrom,xlen:longint):boolean;
    function sins(var x:string;xpos:longint):boolean;
    function sins2(var x:string;xpos,xfrom,xto:longint):boolean;
    function sinsb(x:string;xpos:longint):boolean;
    function sins2b(x:string;xpos,xfrom,xto:longint):boolean;
    //.logic support
    function empty:boolean;
    function notempty:boolean;
    function same(x:pobject):boolean;
    function same2(xfrom:longint;x:pobject):boolean;
    function asame(x:array of byte):boolean;
    function asame2(xfrom:longint;x:array of byte):boolean;
    function asame3(xfrom:longint;x:array of byte;xcasesensitive:boolean):boolean;
    function asame4(xfrom,xmin,xmax:longint;var x:array of byte;xcasesensitive:boolean):boolean;
    //.get/set support
    property cmp8[xpos:longint]:comp read getcmp8 write setcmp8;
    property cur8[xpos:longint]:currency read getcur8 write setcur8;
    property int4[xpos:longint]:longint read getint4 write setint4;
    property int4i[xindex:longint]:longint read getint4i write setint4i;
    property int4R[xpos:longint]:longint read getint4R write setint4R;
    property int3[xpos:longint]:longint read getint3 write setint3;//range: 0..16777215
    property sml2[xpos:longint]:smallint read getsml2 write setsml2;
    property wrd2[xpos:longint]:word read getwrd2 write setwrd2;
    property wrd2R[xpos:longint]:word read getwrd2R write setwrd2R;
    property byt1[xpos:longint]:byte read getbyt1 write setbyt1;
    property bol1[xpos:longint]:boolean read getbol1 write setbol1;
    property chr1[xpos:longint]:char read getchr1 write setchr1;
    property str[xpos:longint;xlen:longint]:string read getstr write setstr;//0-based
    property str1[xpos:longint;xlen:longint]:string read getstr1 write setstr1;//1-based
    property nullstr[xpos:longint;xlen:longint]:string read getnullstr;//0-based
    property nullstr1[xpos:longint;xlen:longint]:string read getnullstr1;//1-based
    function setarray(xpos:longint;xval:array of byte):boolean;
    property text:string read gettext write settext;
    property textarray:string read gettextarray;
    //support
    function xshiftup(spos,slen:longint):boolean;//29feb2024: fixed min range
   end;

{tmemstr8}
   tmemstr8=class(tstream)//tstringstream replacement
   private
    iposition:longint;
    idata:tstr8;//pointer only
   protected
    procedure setsize(newsize:longint); override;
   public
    //create
    constructor create(_ptr:tstr8); virtual;
    destructor destroy; override;
    //workers
    function read(var x;xlen:longint):longint; override;
    function write(const x;xlen:longint):longint; override;
    function seek(offset:longint;origin:word):longint; override;
    function readstring(count:longint):string;
    procedure writestring(const x:string);
   end;

{tvars8}
   tvars8=class(tobject)
   private
    icore:tstr8;
    function getb(xname:string):boolean;
    procedure setb(xname:string;xval:boolean);
    function geti(xname:string):longint;
    procedure seti(xname:string;xval:longint);
    function geti64(xname:string):comp;
    procedure seti64(xname:string;xval:comp);
    function getdt64(xname:string):tdatetime;
    procedure setdt64(xname:string;xval:tdatetime);//31jan2022
    function getc(xname:string):currency;
    procedure setc(xname:string;xval:currency);
    function gets(xname:string):string;
    procedure sets(xname,xvalue:string);
    function getd(xname:string):tstr8;
    procedure setd(xname:string;xvalue:tstr8);
    function xfind(xname:string;var xpos,nlen,dlen,blen:longint):boolean;
    function xnext(var xfrom,xpos,nlen,dlen,blen:longint):boolean;
    procedure xsets(xname,xvalue:string);
    procedure xsetd(xname:string;xvalue:tstr8);
    function gettext:string;
    procedure settext(x:string);
    function getdata:tstr8;
    procedure setdata(xdata:tstr8);
    function getbinary(hdr:string):tstr8;
    procedure setbinary(hdr:string;xval:tstr8);
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    property core:tstr8 read icore;//use carefully - 09oct2020
    //workers
    procedure clear;
    //information
    function len:longint;
    function found(xname:string):boolean;
    property b[xname:string]:boolean read getb write setb;
    property i[xname:string]:longint read geti write seti;
    property i64[xname:string]:comp read geti64 write seti64;
    property dt64[xname:string]:tdatetime read getdt64 write setdt64;//31jan2022
    property c[xname:string]:currency read getc write setc;
    property value[xname:string]:string read gets write sets;//support text only
    property s[xname:string]:string read gets write sets;//support text only
    property d[xname:string]:tstr8 read getd write setd;//supports binary data
    //.fast "d" access - 28dec2021
    function dget(xname:string;xdata:tstr8):boolean;
    //default value handlers
    function bdef(xname:string;xdefval:boolean):boolean;
    function idef(xname:string;xdefval:longint):longint;
    function idef2(xname:string;xdefval,xmin,xmax:longint):longint;
    function idef64(xname:string;xdefval:comp):comp;
    function idef642(xname:string;xdefval,xmin,xmax:comp):comp;
    function sdef(xname,xdefval:string):string;
    //special setters -> return TRUE if new value set else FALSE - 25mar2021
    function bok(xname:string;xval:boolean):boolean;
    function iok(xname:string;xval:longint):boolean;
    function i64ok(xname:string;xval:comp):boolean;
    function cok(xname:string;xval:currency):boolean;
    function sok(xname,xval:string):boolean;
    //workers
    property text:string read gettext write settext;
    property data:tstr8 read getdata write setdata;
    property binary[hdr:string]:tstr8 read getbinary write setbinary;
    function xnextname(var xpos:longint;var xname:string):boolean;
    function findcount:longint;//10jan2022
    function xdel(xname:string):boolean;//02jan2022
   end;

//tmask8 - rapid 8bit graphic mask for tracking onscreen window areas (square and rounded) - 05may2020
   tmaskrgb96 =packed array[0..11] of byte;
   pmaskrow96 =^tmaskrow96;tmaskrow96=packed array[0..((max32 div sizeof(tmaskrgb96))-1)] of tmaskrgb96;
   pmaskrows96=^tmaskrows96;tmaskrows96=array[0..maxrow] of pmaskrow96;
   tmask8=class(tobject)
   private
    icore:tstr8;
    irows:tstr8;
    ilastdy,icount,iblocksize,irowsize,iwidth,iheight:longint;
    irows96:pmaskrows96;
    irows8:pcolorrows8;
    ibytes:pdlbyte;
   public
    //create
    constructor create(w,h:longint); virtual;
    destructor destroy; override;
    //information
    property width:longint read iwidth;
    property height:longint read iheight;
    property rowsize:longint read irowsize;
    property bytes:pdlbyte read ibytes;
    property rows:pmaskrows96 read irows96;
    property prows8:pcolorrows8 read irows8;
    property core:tstr8 read icore;//read-only
    //workers
    function resize(w,h:longint):boolean;
    //mask writers -> boundary is checked
    function cls(xval:byte):boolean;
    function fill(xarea:trect;xval:byte;xround:boolean):boolean;
    function fill2(xarea:trect;xval:byte;xround:boolean):boolean;//29apr2020
    //mask readers -> boundary is NOT checked -> out of range values will cause memory errors - 29apr2020
    procedure mrow(dy:longint);
    function mval(dx:longint):byte;
    function mval2(dx,dy:longint):byte;
   end;

{tfastvars}
   tfastvars=class(tobject)//10x or more faster than "tvars8"
   private
    icount,ilimit:longint;
    vnref1:array[0..999] of longint;
    vnref2:array[0..999] of longint;
    vn:array[0..999] of string;
    vb:array[0..999] of boolean;
    vi:array[0..999] of longint;
    vc:array[0..999] of comp;
    vs:array[0..999] of string;
    vm:array[0..999] of byte;
    function xmakename(xname:string;var xindex:longint):boolean;
    function getb(xname:string):boolean;
    function geti(xname:string):longint;
    function getc(xname:string):comp;
    function gets(xname:string):string;
    procedure setb(xname:string;x:boolean);
    procedure seti(xname:string;x:longint);
    procedure setc(xname:string;x:comp);
    procedure sets(xname:string;x:string);
    function getchecked(xname:string):boolean;//12jan2024
    procedure setchecked(xname:string;x:boolean);
    function getn(xindex:longint):string;
    procedure settext(x:string);
    function gettext:string;
    procedure setnettext(x:string);
    function getv(xindex:longint):string;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    property count:longint read icount;
    //workers
    procedure clear;
    function find(xname:string;var xindex:longint):boolean;
    //found
    function found(xname:string):boolean;
    function sfound(xname:string;var x:string):boolean;
    function sfound8(xname:string;x:pobject;xappend:boolean;var xlen:longint):boolean;
    //values
    property b[x:string]:boolean read getb write setb;
    property i[x:string]:longint read geti write seti;
    property c[x:string]:comp read getc write setc;
    property s[x:string]:string read gets write sets;
    property n[x:longint]:string read getn;//name
    property v[x:longint]:string read getv;//value
    //.html support
    property checked[x:string]:boolean read getchecked write setchecked;//uses string storage "s[x]"
    //inc
    //.32bit longint
    procedure iinc(xname:string);
    procedure iinc2(xname:string;xval:longint);
    //.64bit comp
    procedure cinc(xname:string);
    procedure cinc2(xname:string;xval:comp);
    //io
    property nettext:string write setnettext;//reads in POST data from a web stream
    property text:string read gettext write settext;
    function tofile(x:string;var e:string):boolean;
    function fromfile(x:string;var e:string):boolean;
   end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//000000000000000000000000000000000//111111111111111111111
var
   //.started
   system_started         :boolean=false;

   //.info support
   info_mode              :longint=0;//0=unset, 1=console app, 2=console app as a service, 3=gui app

   //.system wide type tracking
   track_typecount        :array[0..(track_limit-1)] of longint;
   track_bytes            :comp=0;//total memory allocated for pointers

   //.64bit system timer - Delphi 3
   system_ms64_init       :boolean=false;
   system_ms64_last       :comp=0;
   system_ms64_offset     :comp=0;
   //.32bit minute timer
   system_min32_val       :longint=0;

   //.crc32 support
   sys_crc32             :array[0..255] of longint;
   sys_initcrc32         :boolean=false;

   //.ref support
   p4INT32               :array[0..32] of longint;
   p8CMP256              :array[0..256] of comp;

   //.system values
   vizoom              :longint=1;
   system_eventdriven  :boolean=false;//true=Windows event list driven, false=internally driven
   system_runstyle     :longint=0;//0=unknown, 1=console app, 2=service, 3=gui app
   system_state        :longint=0;//ssStarting..ssMax
   system_musthalt     :boolean=false;//external trigger -> informs app it must shutdown
   system_pause        :boolean=false;//used by service manager to pause/unpause app execution
   system_servicestatus:tservicestatus;
   system_servicestatush:SERVICE_STATUS_HANDLE=0;
   system_servicetable :array [0..2] of TServiceTableEntry;
   system_adminlevel   :longint=0;//0=not set, 1=not admin, 2=admin level
   system_firsttimer   :boolean=false;
   system_lasttimer    :boolean=false;
   system_debug        :boolean=false;
   system_master       :boolean=true;//this program will write settings etc (not a child)
   system_instanceid   :longint=0;//set by "siInit"
   system_nographics   :boolean=false;//true=disable graphic procs (mainly for debug)
   system_debugging    :boolean=false;//true=turns on internal debugging
   system_boot         :comp=0;//ms
   system_boot_date    :tdatetime=0;
   //.settings
   system_settings     :tvars8=nil;
   system_settings_ref :tvars8=nil;//list of acceptable value names and their ranges - RAM only
   system_settings_load:boolean=false;//marks the settings have been loaded, allowing for subsequent save requests
   system_settings_filt:boolean=false;//true=filtered
   //.windows message support
   system_wproc        :twproc=nil;//windows message handler
   system_message_count:longint=0;
   //.console screen support
   system_scn_x        :longint=0;
   system_scn_y        :longint=0;
   system_scn_width    :longint=100;
   system_scn_height   :longint=26;
   system_scn_lines    :array[0..59] of string;//18 Kb
   system_scn_ref      :string='';
   system_scn_mustpaint:boolean=false;//true=must update console screen
   system_scn_visible  :boolean=false;//true=take control of console screen and paint from "system_scn_lines", false=paint line by line in traditional mode
   system_scn_ref1     :boolean=false;
   system_stdin        :thandle;
   system_line_str     :string='';
   system_timeperiod   :longint=0;//not set -> adjusts main thread's timing accuracy -> see the proc "root__settimeperiod()" - 14mar2024
   //.turbo
   system_turbo        :boolean=false;//false=idling, true=working/powering through tasks
   system_turboref     :comp=0;
   //.system timers
   system_timer1       :tnotifyevent=nil;
   system_timer2       :tnotifyevent=nil;
   system_timer3       :tnotifyevent=nil;
   system_timer4       :tnotifyevent=nil;
   system_timer5       :tnotifyevent=nil;

//start-stop procs -------------------------------------------------------------
procedure gossroot__start;
procedure gossroot__stop;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function app____netmore:tobject;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
function info__root(xname:string):string;//information specific to this unit of code
function info__rootfind(xname:string):string;//central point from which to find the requested information - 09apr2024
function info__mode:longint;

//nil procs --------------------------------------------------------------------
procedure nil__1(x1:pobject);
procedure nil__2(x1,x2:pobject);
procedure nil__3(x1,x2,x3:pobject);
procedure nil__4(x1,x2,x3,x4:pobject);
procedure nil__5(x1,x2,x3,x4,x5:pobject);
procedure nil__6(x1,x2,x3,x4,x5,x6:pobject);
procedure nil__7(x1,x2,x3,x4,x5,x6,x7:pobject);

//free procs -------------------------------------------------------------------
procedure free__1(x1:pobject);
procedure free__2(x1,x2:pobject);
procedure free__3(x1,x2,x3:pobject);
procedure free__4(x1,x2,x3,x4:pobject);
procedure free__5(x1,x2,x3,x4,x5:pobject);
procedure free__6(x1,x2,x3,x4,x5,x6:pobject);
procedure free__7(x1,x2,x3,x4,x5,x6,x7:pobject);

//new procs --------------------------------------------------------------------
function new__str:tdynamicstring;
function new__byte:tdynamicbyte;
function new__int:tdynamicinteger;
function new__comp:tdynamiccomp;
function new__date:tdynamicdatetime;

//track procs ------------------------------------------------------------------
function track__limit:longint;
procedure track__inc(xindex,xcreate:longint);
function track__typecount(xindex:longint):longint;
function track__typecountstr(xindex:longint):string;

//utf-8 procs ------------------------------------------------------------------
function utf8__charlen(x:byte):longint;
function utf8__charpoint0(x:pobject;var xpos:longint):longint;
function utf8__encodetohtml(s,d:pobject;dappend,dasfilename,dnoslashes:boolean):boolean;
function utf8__encodetohtmlstr(x:string;xasfilename,xnoslashes:boolean):string;

//mail procs -------------------------------------------------------------------
function mail__date(x:tdatetime):string;
function mail__fromqp(_s:string):string;//quoted-printable, 22mar2024: updated "_" as a space
function mail__encodefield(x:string;xencode:boolean):string;//like subject etc
function mail__extractaddress(x:string):string;
function mail__filteraddresses(x:string;xaddressesonly,xwraponlines:boolean):string;
function mail__diskname(xdate:tdatetime;xsubject:string;xtrycount:longint):string;
function mail__makemsg(x:pobject;xsenderip,xfrom,xto,xsubject,xmsg:string;xdate:tdatetime;var e:string):boolean;//09feb2024
function mail__writemsg(x:pobject;xsubject,xdestfolder:string):boolean;

//memory management procs ------------------------------------------------------
procedure mem__newpstring(var z:pstring);//29NOV2011
procedure mem__despstring(var z:pstring);//29NOV2011
function mem__getmem(var p:pointer;size,xid:longint):boolean;//27apr2021, 29apr2020
function mem__reallocmem(var p:pointer;oldsize,newsize,xid:longint):boolean;//27apr2021, 29apr2020
function mem__reallocmemCLEAR(var p:pointer;oldsize,newsize,xid:longint):boolean;//29apr2021, 29NOV2011
function mem__freemem(var x:pointer;oldsize,xid:longint):boolean;//27apr2021, 29apr2020

//block memory management procs ------------------------------------------------
//Note: These procs assume fixed memory blocks defined by "system_blocksize", typically 8192 bytes.
//      Controls such as tstr9 and tintlist use block based memory for maximum stability and
//      scalability by reducing/almost elmininating memory fragmentation.
function block__fastinfo(x:pobject;xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;//for supported controls (tstr9, tintlist etc) returns the memory block pointer in the byte array form "pdlbyte" referenced by the control's item index -> this provides an optimisation layer, as not every item index has to lookup it's memory block
function block__fastptr(x:pobject;xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;
function block__size:longint;//returns the system block size as defined by "system_blocksize"
procedure block__cls(x:pointer);//sets the memory block to all zeros
function block__new:pointer;//creates a new memory block and returns a pointer to it
procedure block__free(var x:pointer);//frees the memory block and sets the pointer to nil
procedure block__freeb(x:pointer);//frees the memory block and does NOT flush the pointer to nil

//binary string procs ----------------------------------------------------------
function cache__ptr(x:tobject):pobject;//09feb2024: Stores a "floating object" (a dynamically created object that is to be passed to a proc as a parameter)
//.info
function str__info(x:pobject;var xstyle:longint):boolean;
function str__info2(x:pobject):longint;
function str__ok(x:pobject):boolean;
function str__lock(x:pobject):boolean;
function str__lock2(x,x2:pobject):boolean;
function str__unlock(x:pobject):boolean;
procedure str__unlockautofree(x:pobject);
procedure str__uaf(x:pobject);//short version of "str__unlockautofree"
procedure str__uaf2(x,x2:pobject);
procedure str__autofree(x:pobject);
//.new
function str__new8:tstr8;
function str__new9:tstr9;
function str__newaf8:tstr8;//autofree
function str__newaf9:tstr9;//autofree
//.workers
function str__equal(s,s2:pobject):boolean;
function str__mem(x:pobject):longint;
function str__datalen(x:pobject):longint;
function str__len(x:pobject):longint;
function str__minlen(x:pobject;xnewlen:longint):boolean;//29feb2024: created
function str__setlen(x:pobject;xnewlen:longint):boolean;
function str__splice(x:pobject;xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
procedure str__clear(x:pobject);
procedure str__softclear(x:pobject);//retain data block but reset len to 0
procedure str__softclear2(x:pobject;xmaxlen:longint);
procedure str__free(x:pobject);
//.multi-part web form (post data)
function str__multipart_nextitem(x:pobject;var xpos:longint;var xboundary,xname,xfilename,xcontenttype:string;xoutdata:pobject):boolean;
//.object support
function str__add(x,xadd:pobject):boolean;
function str__addb(x,xadd:tobject):boolean;
function str__add2(x,xadd:pobject;xfrom,xto:longint):boolean;
function str__add3(x,xadd:pobject;xfrom,xlen:longint):boolean;
function str__add31(x,xadd:pobject;xfrom1,xlen:longint):boolean;
function str__addrec(x:pobject;xrec:pointer;xrecsize:longint):boolean;//20feb2024, 07feb2022
function str__ins(x,xadd:pobject;xpos:longint):boolean;
function str__ins2(x,xadd:pobject;xpos,xfrom,xto:longint):boolean;
function str__del3(x:pobject;xfrom,xlen:longint):boolean;//06feb2024
function str__del(x:pobject;xfrom,xto:longint):boolean;//06feb2024
//..pdl support -> direct memory support
function str__padd(s:pobject;x:pdlbyte;xsize:longint):boolean;//15feb2024
function str__pins2(s:pobject;x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;
//.string procs
function str__sadd(x:pobject;var xdata:string):boolean;
function str__saddb(x:pobject;xdata:string):boolean;
function str__remchar(x:pobject;y:byte):boolean;//29feb2024: created
function str__text(x:pobject):string;
function str__settext(x:pobject;var xtext:string):boolean;
function str__settextb(x:pobject;xtext:string):boolean;
function str__str0(x:pobject;xpos,xlen:longint):string;
function str__str1(x:pobject;xpos,xlen:longint):string;
function str__copy81(x:tobject;xpos1,xlen:longint):tstr8;
function str__copy91(x:tobject;xpos1,xlen:longint):tstr9;
function str__bytes0(x:pobject;xpos:longint):byte;
function str__bytes1(x:pobject;xpos:longint):byte;
procedure str__setbytes0(x:pobject;xpos:longint;xval:byte);
procedure str__setbytes1(x:pobject;xpos:longint;xval:byte);
//.other / older procs
function bgetstr1(x:tobject;xpos1,xlen:longint):string;
function _blen(x:tobject):longint;//does NOT destroy "x", keeps "x"
procedure bdel1(x:tobject;xpos1,xlen:longint);
function bcopystr1(x:string;xpos1,xlen:longint):tstr8;
function bcopystrall(x:string):tstr8;
function bcopyarray(x:array of byte):tstr8;
function bnew2(var x:tstr8):boolean;//21mar2022
function bnewlen(xlen:longint):tstr8;
function bnewstr(xtext:string):tstr8;
function breuse(var x:tstr8;xtext:string):tstr8;//also acts as a pass-thru - 05jul2022
function bnewfrom(xdata:tstr8):tstr8;

//zero checkers ----------------------------------------------------------------
function nozero__int32(xdebugID,x:longint):longint;
function nozero__int64(xdebugID:longint;x:comp):comp;
function nozero__byt(xdebugID:longint;x:byte):byte;
function nozero__dbl(xdebugID:longint;x:double):double;
function nozero__ext(xdebugID:longint;x:extended):extended;
function nozero__cur(xdebugID:longint;x:currency):currency;
function nozero__sig(xdebugID:longint;x:single):single;
function nozero__rel(xdebugID:longint;x:real):real;

//timing procs -----------------------------------------------------------------
function mn32:longint;//32bit minute timer - 08jan2024
function ms64:comp;//64bit millisecond system timer, 01-SEP-2006
function ms64str:string;//06NOV2010
function msok(var xref:comp):boolean;//timer reference has expired
function msset(var xref:comp;xdelay:comp):boolean;//restart timer reference with supplied delay
function mswaiting(var xref:comp):boolean;//timer reference has not yet expired (still waiting to expire)

//simple message procs ---------------------------------------------------------
function showerror(x:string):boolean;
function showerror2(x:string;xsec:longint):boolean;
procedure showbasic(x:string);
function showmsg(x:string):boolean;
function showmsg2(x:string;xsec:longint):boolean;

//date and time procs ----------------------------------------------------------
function low__uptime(x:comp;xforcehr,xforcemin,xforcesec,xshowsec,xshowms:boolean;xsep:string):string;//28apr2024: changed 'dy' to 'd', 01apr2024: xforcesec, xshowsec/xshowms pos swapped, fixed - 09feb2024, 27dec2021, fixed 10mar2021, 22feb2021, 22jun2018, 03MAY2011, 07SEP2007
function low__year(xmin:longint):longint;
function low__yearstr(xmin:longint):string;
function low__dhmslabel(xms:comp):string;//days hours minutes and seconds from milliseconds - 06feb2023
function low__dateinminutes(x:tdatetime):longint;//date in minutes (always >0)
function low__dateascode(x:tdatetime):string;//tight as - 17oct2018
function low__SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
function low__gmt(x:tdatetime):string;//gtm for webservers - 01feb2024
procedure low__gmtOFFSET(var h,m,factor:longint);
function low__makeetag(x:tdatetime):string;//high speed version - 25dec2023
function low__makeetag2(x:tdatetime;xboundary:string):string;//high speed version - 31mar2024, 25dec2023
function low__datetimename(x:tdatetime):string;//12feb2023
function low__datename(x:tdatetime):string;
function low__datetimename2(x:tdatetime):string;//10feb2023
function low__safedate(x:tdatetime):tdatetime;
procedure low__decodedate2(x:tdatetime;var y,m,d:word);//safe range
procedure low__decodetime2(x:tdatetime;var h,min,s,ms:word);//safe range
function low__encodedate2(y,m,d:word):tdatetime;
function low__encodetime2(h,min,s,ms:word):tdatetime;
function low__dayofweek(x:tdatetime):longint;//01feb2024
function low__dayofweek1(x:tdatetime):longint;
function low__dayofweek0(x:tdatetime):longint;
function low__dayofweekstr(x:tdatetime;xfullname:boolean):string;
function low__month1(x:longint;xfullname:boolean):string;//08mar2022
function low__month0(x:longint;xfullname:boolean):string;//08mar2022
function low__weekday1(x:longint;xfullname:boolean):string;//08mar2022
function low__weekday0(x:longint;xfullname:boolean):string;//08mar2022
function low__datestr(xdate:tdatetime;xformat:longint;xfullname:boolean):string;//09mar2022
function low__leapyear(xyear:longint):boolean;
function low__datetoday(x:tdatetime):longint;
function low__datetosec(x:tdatetime):comp;
function low__date1(xyear,xmonth1,xday1:longint;xformat:longint;xfullname:boolean):string;
function low__date0(xyear,xmonth,xday:longint;xformat:longint;xfullname:boolean):string;
function low__time0(xhour,xminute:longint;xsep,xsep2:string;xuppercase,xshow24:boolean):string;
function low__hour0(xhour:longint;xsep:string;xuppercase,xshowAMPM,xshow24:boolean):string;

//string procs -----------------------------------------------------------------
function low__lcolumn(x:string;xmaxwidth:longint):string;//left aligned column - 09apr2024
function low__rcolumn(x:string;xmaxwidth:longint):string;//right aligned column - 09apr2024
function low__hexchar(x:byte):char;
function low__hex(x:byte):string;
function low__hexint2(x2:string):longint;//26dec2023
function low__splitto(s:string;d:tfastvars;ssep:string):boolean;//13jan2024
function low__ref32u(x:string):longint;//1..32 - 25dec2023, 04feb2023
function low__ref256(x:string):comp;//01may2025: never 0 for valid input, 28dec2023
function low__ref256U(x:string):comp;//01may2025: never 0 for valid input, 28dec2023
function low__nextline0(xdata,xlineout:tstr8;var xpos:longint):boolean;//17oct2018
function low__nextline1(var xdata,xlineout:string;xdatalen:longint;var xpos:longint):boolean;//17oct2018
function low__matchmask(var xline,xmask:string):boolean;//04nov2019
function low__matchmaskb(xline,xmask:string):boolean;//04nov2019
function low__matchmasklist(var xline,xmasklist:string):boolean;//04oct2020
function low__matchmasklistb(xline:string;var xmasklist:string):boolean;//04oct2020
//.size
function low__size(x:comp;xstyle:string;xpoints:longint;xsym:boolean):string;//01apr2024:plus support, 10feb2024: created
function low__bDOT(x:comp;sym:boolean):string;
function low__b(x:comp;sym:boolean):string;//10feb2024, fixed - 30jan2016
function low__kb(x:comp;sym:boolean):string;
function low__kbb(x:comp;p:longint;sym:boolean):string;
function low__mb(x:comp;sym:boolean):string;
function low__mbb(x:comp;p:longint;sym:boolean):string;
function low__gb(x:comp;sym:boolean):string;
function low__gbb(x:comp;p:longint;sym:boolean):string;
function low__mbAUTO(x:comp;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
function low__mbAUTO2(x:comp;p:longint;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
function low__mbPLUS(x:comp;sym:boolean):string;//01apr2024: created

function low__ipercentage(a,b:longint):extended;
function low__percentage64(a,b:comp):extended;//24jan2016
function low__percentage64str(a,b:comp;xsymbol:boolean):string;//04oct2022

//base64 procs -----------------------------------------------------------------
function low__tob641(s,d:tstr8;xpos1,linelength:longint;var e:string):boolean;//to base64 using #10 return codes - 13jan2024
function low__tob64(s,d:tstr8;linelength:longint;var e:string):boolean;//to base64
function low__tob64b(s:tstr8;linelength:longint):tstr8;
function low__tob64bstr(x:string;linelength:longint):string;//13jan2024
function low__fromb64(s,d:tstr8;var e:string):boolean;//from base64
function low__fromb641(s,d:tstr8;xpos1:longint;var e:string):boolean;//from base64
function low__fromb64b(s:tstr8):tstr8;
function low__fromb64str(x:string):string;

//general procs ----------------------------------------------------------------
function debugging:boolean;
function vnew:tvars8;
function vnew2(xdebugid:longint):tvars8;
function low__param(x:longint):string;//01mar2024
function low__paramstr1:string;
function low__fireevent(xsender:tobject;x:tevent):boolean;
function low__comparearray(a,b:array of byte):boolean;//27jan2021
function low__cls(x:pointer;xsize:longint):boolean;
function low__intr(x:longint):longint;//reverse longint
function low__wrdr(x:word):word;//reverse word
function low__posn(x:longint):longint;
procedure low__iroll(var x:longint;by:longint);//continuous incrementer with safe auto. reset
procedure low__croll(var x:currency;by:currency);//continuous incrementer with safe auto. reset
procedure low__roll64(var x:comp;by:comp);//continuous incrementer with safe auto. reset to user specified value - 05feb2016
function low__nrw(x,y,r:longint):boolean;//number within range
procedure low__int3toRGB(x:longint;var r,g,b:byte);
function low__iseven(x:longint):boolean;
function low__even(x:longint):boolean;
procedure low__msb16(var s:word);//most significant bit first - 22JAN2011
procedure low__msb32(var s:longint);//most significant bit first - 22JAN2011
function strlow(x:string):string;//make string lowercase
function strup(x:string):string;//make string uppercase
function strmatch(a,b:string):boolean;//same as (low__comparetext(a,b)=true) or (comparetext(a,b)=0)
function strmatch2(a,b:string):longint;
function strmatchCASE(a,b:string):boolean;//match using case sensitivity
function bnc(x:boolean):string;//boolean to number
function uptob(x:string;sep:char):string;
function upto(var x:string;sep:char):string;
function swapcharsb(x:string;a,b:char):string;
procedure swapchars(var x:string;a,b:char);//20JAN2011
function swapallcharsb(x:string;n:char):string;//08apr2024
function swapallchars(var x:string;n:char):string;//08apr2024
function swapstrsb(x,a,b:string):string;
function swapstrs(var x:string;a,b:string):boolean;
function stripwhitespace_lt(x:string):string;//strips leading and trailing white space
function stripwhitespace(x:string;xstriptrailing:boolean):string;
procedure striptrailingrcodes(var x:string);
function striptrailingrcodesb(x:string):string;
function freeobj(x:pobject):boolean;//09feb2024: Added support for "._rtmp" & mustnil, 02feb2021, 05may2020, 05DEC2011, 14JAN2011, 15OCT2004
function mult64(xval,xval2:comp):comp;//multiply
function add64(xval,xval2:comp):comp;//add
function sub64(xval,xval2:comp):comp;//subtract
function div64(xval,xdivby:comp):comp;//28dec2021, this proc performs proper "comp division" -> fixes Delphi's "comp" division error -> which raises POINTER EXCEPTION and MEMORY ERRORS when used at speed and repeatedly - 13jul2021, 19apr2021
function insstr(x:string;y:boolean):string;
function strcopy0(var x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
function strcopy0b(x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
function strcopy1(var x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
function strcopy1b(x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
function strlast(var x:string):string;//returns last char of string or nil if string is empty
function strlastb(x:string):string;//returns last char of string or nil if string is empty
function strdel0(var x:string;xpos,xlen:longint):boolean;//0based
function strdel1(var x:string;xpos,xlen:longint):boolean;//1based
function strbyte0(var x:string;xpos:longint):byte;//0based always -> backward compatible with D3 - 02may2020
function strbyte0b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
function strbyte1(var x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
function strbyte1b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
procedure strdef(var x:string;xdef:string);//set new value, default to "xdef" if xnew is nil
function strdefb(x,xdef:string):string;
function low__setlen(var x:string;xlen:longint):boolean;
function low__length(var x:string):longint;
function low__lengthb(x:string):longint;
function floattostrex2(x:extended):string;//19DEC2007
function floattostrex(x:extended;dig:byte):string;//07NOV20210
function strtofloatex(x:string):extended;//triggers less errors (x=nil now covered)
function restrict32(x:comp):longint;//limit32 - 24jan2016
function restrict64(x:comp):comp;//24jan2016
function k64(x:comp):string;//converts 64bit number into a string with commas -> handles full 64bit whole number range of min64..max64 - 24jan2016
function k642(x:comp;xsep:boolean):string;//handles full 64bit whole number range of min64..max64 - 24jan2016
function makestr(var x:string;xlen:longint;xfillchar:byte):boolean;
function makestrb(xlen:longint;xfillchar:byte):string;


//system procs -----------------------------------------------------------------
function pok(x:pobject):boolean;//06feb2024
function zzok(x:tobject;xid:longint):boolean;
function zznil(x:tobject;xid:longint):boolean;
function zznil2(x:tobject):boolean;//12feb202
function ppok(x:pointer;xid:longint):boolean;
function zzvars(x:tvars8;xid:longint):tvars8;
//.need checkers
procedure need_filecache;
procedure need_net;
procedure need_ipsec;
procedure need_png;//requires zip support
procedure need_zip;
procedure need_jpeg;
procedure need_gif;
procedure need_gif2;

//app procs --------------------------------------------------------------------
//.information
function app__uptime:comp;
function app__uptimegreater(x:comp):boolean;
function app__uptimestr:string;
//.folder
function app__folder:string;
function app__folder2(xsubfolder:string;xcreate:boolean):string;
function app__folder3(xsubfolder:string;xcreate,xalongsideexe:boolean):string;//15jan2024
function app__subfolder(xsubfolder:string):string;
function app__subfolder2(xsubfolder:string;xalongsideexe:boolean):string;
function app__settingsfile(xname:string):string;
//.settings
//..load+save
function app__loadsettings:boolean;
function app__savesettings:boolean;
procedure app__filtersettings;
//..register -> filters settings data so only registered values persist
procedure app__breg(xname:string;xdefval:boolean);//register boolean for settings
procedure app__ireg(xname:string;xdefval,xmin,xmax:longint);//32bit register integer for settings
procedure app__creg(xname:string;xdefval,xmin,xmax:comp);//64bit register comp for settings
procedure app__sreg(xname:string;xdefval:string);//register string for settings
//..value readers
function app__bval(xname:string):boolean;//self-filtering
function app__ival(xname:string):longint;//self-filtering
function app__cval(xname:string):comp;//self-filtering
function app__sval(xname:string):string;//self-filtering
//..value writers
function app__bvalset(xname:string;xval:boolean):boolean;
function app__ivalset(xname:string;xval:longint):longint;
function app__cvalset(xname:string;xval:comp):comp;
function app__svalset(xname,xval:string):string;
//.memory
function mem__alloc(xsize:longint):pointer;
function mem__realloc(xptr:pointer;xsize:longint):pointer;
function mem__free(xptr:pointer):boolean;
//.run
//xxxxxxxxxxxxxxxxxxxx//66666666666666666666
function app__adminlevel:boolean;
procedure app__paintnow;//flicker free paint
function app__paused:boolean;
procedure app__pause(x:boolean);
function app__runstyle:longint;//04mar2024
procedure app__install_uninstall;
procedure app__boot(xEventDriven,xFileCache:boolean);//this determines how to run the app and then calls "app__run"
procedure app__run;//this runs and manages the console program and enables screen output support
function app__running:boolean;
procedure app__halt;//halt the program
function app__processmessages:boolean;
function app__processallmessages:boolean;
function app__wproc:twproc;//auto makes the windows message handler
function app__eventproc(ctrltype:dword):bool; stdcall;//detects shutdown requests from Windows
//.read + write line
function app__write(x:string):boolean;//write
function app__writeln(x:string):boolean;//write line
function app__writeln2(x:string;xsec:longint):boolean;//write line
function app__writenil:boolean;//write blank line
function app__readln(var x:string):boolean;//read line - waits
function app__read(var x:char):boolean;//read one char - waits
function app__key:char;//read one char - does not wait, but throws away other message types
function app__line(var x:string):boolean;//non-stopping line reader
function app__line2(var x:string;xecho:boolean):boolean;//non-stopping line reader
//.timers
function app__firsttimer:boolean;//true the first time the timer events are called
function app__lasttimer:boolean;//true when the timer events are called for the last time
procedure app__timers;//should only be called from app__run
//.wait
procedure app__waitms(xms:longint);//wait for xms
procedure app__waitsec(xsec:longint);//wait for xsec
//.turbo mode -> run with maximum CPU power for a short burst of time
procedure app__turbo;
procedure app__shortturbo(xms:comp);//doesn't shorten any existing turbo, but sets a small delay when none exist, or a short one already exists - 05jan2024
function app__turboOK:boolean;


//screen procs -----------------------------------------------------------------
//.title
procedure scn__settitle(x:string);//change console tab title
//.visible - show or hide then screen
function scn__visible:boolean;
procedure scn__setvisible(x:boolean);
//.size
function scn__width:longint;
function scn__height:longint;
//.window (console)
function scn__windowwidth:longint;
function scn__windowheight:longint;
function scn__windowsize(var xwidth,xheight:longint):boolean;//size of Windows console w x h - 20dec2023
procedure scn__windowcls;
//.cls
procedure scn__cls;
//.paint
function scn__canpaint:boolean;
function scn__mustpaint:boolean;
procedure scn__paint;
function rl(var x:string):boolean;
function wl(x:string):boolean;//write line - short version
function scn__writeln(x:string):boolean;//write line
function scn__changed(xset:boolean):boolean;


//.draw
procedure scn__moveto(x,y:longint);
procedure scn__setx(xval:longint);
procedure scn__sety(xval:longint);
procedure scn__down;
procedure scn__up;
procedure scn__left;
procedure scn__right;
procedure scn__text(x:string);
procedure scn__text2(x1,x2:longint;x:string);
procedure scn__clearline;
procedure scn__hline(x:string);
procedure scn__vline(x:string);
procedure scn__proc(xstyle,xtext:string;xfrom,xto:longint);
function scn__gettext(xwidth,xheight:longint):string;


//numerical procs --------------------------------------------------------------
//.16bit
function low__rword(x:word):word;
//.32bit
function low__sum32(x:array of longint):longint;
procedure low__orderint(var x,y:longint);
function frcmin32(x,min:longint):longint;
function frcmax32(x,max:longint):longint;
function frcrange32(x,min,max:longint):longint;
function frcrange2(var x:longint;xmin,xmax:longint):boolean;//29apr2020
function smallest(a,b:longint):longint;
function largest(a,b:longint):longint;
function cfrcrange32(x,min,max:currency):currency;//date: 02-APR-2004
function strint(x:string):longint;//skip over pluses "+" - 22jan2022, skip over commas - 05jun2021, date: 16aug2020, 25mar2016 v1.00.50 / 10DEC2009, v1.00.045
//.64bit
function frcmin64(x,min:comp):comp;//24jan2016
function frcmax64(x,max:comp):comp;//24jan2016
function frcrange64(x,min,max:comp):comp;//24jan2016
function frcrange642(var x:comp;xmin,xmax:comp):boolean;//20dec2023
function smallest64(a,b:comp):comp;
function largest64(a,b:comp):comp;
function strint64(x:string):comp;//v1.00.035 - 05jun2021, v1.00.033 - 28jan2017
function intstr64(x:comp):string;//30jan2017
function strdec(x:string;y:byte;xcomma:boolean):string;
function curdec(x:currency;y:byte;xcomma:boolean):string;
function curstrex(x:currency;sep:string):string;//01aug2017, 07SEP2007
function curcomma(x:currency):string;{same as "Thousands" but for "double"}
function low__remcharb(x:string;c:char):string;//26apr2019
function low__remchar(var x:string;c:char):boolean;//26apr2019
function low__rembinary(var x:string):boolean;//07apr2020
function low__digpad20(v:comp;s:longint):string;//1 -> 01
function low__digpad11(v,s:longint):string;//1 -> 01
//.area
function nilrect:trect;
function nilarea:trect;//25jul2021
function maxarea:trect;//02dec2023, 27jul2021
function noarea:trect;//sets area to maximum inverse values - 19nov2023
function validrect(x:trect):boolean;
function validarea(x:trect):boolean;//26jul2021
function low__shiftarea(xarea:trect;xshiftx,xshifty:longint):trect;//always shift
function low__shiftarea2(xarea:trect;xshiftx,xshifty:longint;xvalidcheck:boolean):trect;//xvalidcheck=true=shift only if valid area, false=shift always
function low__withinrect(x,y:longint;z:trect):boolean;
function low__withinrect2(xy:tpoint;z:trect):boolean;
function low__rect(xleft,xtop,xright,xbottom:longint):trect;
function low__rectclip(clip_rect,s:trect):trect;//21nov2023
function low__rectgrow(x:trect;xby:longint):trect;//07apr2021
function low__rectstr(x:trect):string;
function low__point(x,y:longint):tpoint;//09apr2024



//logic procs ------------------------------------------------------------------
function low__setstr(var xdata:string;xnewvalue:string):boolean;
function low__setcmp(var xdata:comp;xnewvalue:comp):boolean;//10mar2021
function low__setint(var xdata:longint;xnewvalue:longint):boolean;
function low__setbol(var xdata:boolean;xnewvalue:boolean):boolean;
function low__insint(x:longint;y:boolean):longint;
function low__inscmp(x:comp;y:boolean):comp;//28dec2023
function low__aorb(a,b:longint;xuseb:boolean):longint;
function low__aorbrect(a,b:trect;xuseb:boolean):trect;//25nov2023
function low__aorbbyte(a,b:byte;xuseb:boolean):byte;
function low__aorbcur(a,b:currency;xuseb:boolean):currency;//07oct2022
function low__aorbcomp(a,b:comp;xuseb:boolean):comp;//19feb2024
function low__yes(x:boolean):string;//16sep2022
function low__enabled(x:boolean):string;//29apr2024
function low__aorbstr(a,b:string;xuseb:boolean):string;
function low__aorbchar(a,b:char;xuseb:boolean):char;
function low__aorbbol(a,b:boolean;xuseb:boolean):boolean;
function low__aorbstr8(a,b:tstr8;xuseb:boolean):tstr8;//06dec2023
function low__aorbvars8(a,b:tvars8;xuseb:boolean):tvars8;//06dec2023


//swap procs -------------------------------------------------------------------
procedure low__swapbol(var x,y:boolean);//05oct2018
procedure low__swapbyt(var x,y:byte);//22JAN2011
procedure low__swapint(var x,y:longint);
procedure low__swapstr(var x,y:string);//20nov2023
procedure low__swapcomp(var x,y:comp);//07apr2016
procedure low__swapcur(var x,y:currency);
procedure low__swapext(var x,y:extended);//06JUN2007
procedure low__swapstr8(var x,y:tstr8);//07dec2023
procedure low__swapvars8(var x,y:tvars8);//07dec2023
procedure low__swapcolor32(var x,y:tcolor32);//13dec2023



//file procs -------------------------------------------------------------------
function low__foldertep(xfolder:string):longint;
function low__foldertep2(xownerid:longint;xfolder:string):longint;


//.support
function tepext(xfilenameORext:string):longint;


//logic helpers support -------------------------------------------------------
//special note: low__true* and low__or* designed to execute ALL input values fully
//note: force predictable logic and proc execution by forcing ALL supplied inbound values to be fully processed BEFORE a result is returned, thus allowing for muiltiple and combined dynamic value processing and yet yeilding stable and consistent output
function low__true1(v1:boolean):boolean;
function low__true2(v1,v2:boolean):boolean;//all must be TRUE to return TRUE
function low__true3(v1,v2,v3:boolean):boolean;
function low__true4(v1,v2,v3,v4:boolean):boolean;
function low__true5(v1,v2,v3,v4,v5:boolean):boolean;
function low__or2(v1,v2:boolean):boolean;//only one must be TRUE to return TRUE
function low__or3(v1,v2,v3:boolean):boolean;//only one must be TRUE to return TRUE

//crc32 support ----------------------------------------------------------------
procedure low__initcrc32;
procedure low__crc32inc(var _crc32:longint;x:byte);//23may2020, 31-DEC-2006
procedure low__crc32(var _crc32:longint;x:tstr8;s,f:longint);//31-DEC-2006, updated 27-MAR-2007
function low__crc32c(x:tstr8;s,f:longint):longint;
function low__crc32b(x:tstr8):longint;
function low__crc32nonzero(x:tstr8):longint;//02SEP2010
function low__crc32seedable(x:tstr8;xseed:longint):longint;//14jan2018

//general procs ----------------------------------------------------------------
procedure runLOW(fDOC,fPARMS:string);//stress tested on Win98/WinXP - 27NOV2011, 06JAN2011
procedure low__syszoom(var aw,ah:longint);

//compression procs (standard ZIP - 26jan2021) ---------------------------------
function low__compress(x:pobject):boolean;
function low__decompress(x:pobject):boolean;
function low__compress2(x:pobject;xcompress,xfast:boolean):boolean;//05feb2021

implementation

uses gossio, gossimg, gossnet, bubbles1;


//nil procs --------------------------------------------------------------------
procedure nil__1(x1:pobject);
begin
if (x1<>nil) then x1^:=nil;
end;
procedure nil__2(x1,x2:pobject);
begin
if (x1<>nil) then x1^:=nil;
if (x2<>nil) then x2^:=nil;
end;
procedure nil__3(x1,x2,x3:pobject);
begin
if (x1<>nil) then x1^:=nil;
if (x2<>nil) then x2^:=nil;
if (x3<>nil) then x3^:=nil;
end;
procedure nil__4(x1,x2,x3,x4:pobject);
begin
if (x1<>nil) then x1^:=nil;
if (x2<>nil) then x2^:=nil;
if (x3<>nil) then x3^:=nil;
if (x4<>nil) then x4^:=nil;
end;
procedure nil__5(x1,x2,x3,x4,x5:pobject);
begin
if (x1<>nil) then x1^:=nil;
if (x2<>nil) then x2^:=nil;
if (x3<>nil) then x3^:=nil;
if (x4<>nil) then x4^:=nil;
if (x5<>nil) then x5^:=nil;
end;
procedure nil__6(x1,x2,x3,x4,x5,x6:pobject);
begin
if (x1<>nil) then x1^:=nil;
if (x2<>nil) then x2^:=nil;
if (x3<>nil) then x3^:=nil;
if (x4<>nil) then x4^:=nil;
if (x5<>nil) then x5^:=nil;
if (x6<>nil) then x6^:=nil;
end;
procedure nil__7(x1,x2,x3,x4,x5,x6,x7:pobject);
begin
if (x1<>nil) then x1^:=nil;
if (x2<>nil) then x2^:=nil;
if (x3<>nil) then x3^:=nil;
if (x4<>nil) then x4^:=nil;
if (x5<>nil) then x5^:=nil;
if (x6<>nil) then x6^:=nil;
if (x7<>nil) then x7^:=nil;
end;

//free procs --------------------------------------------------------------------
procedure free__1(x1:pobject);
begin
if (x1<>nil) then freeobj(x1);
end;
procedure free__2(x1,x2:pobject);
begin
if (x1<>nil) then freeobj(x1);
if (x2<>nil) then freeobj(x2);
end;
procedure free__3(x1,x2,x3:pobject);
begin
if (x1<>nil) then freeobj(x1);
if (x2<>nil) then freeobj(x2);
if (x3<>nil) then freeobj(x3);
end;
procedure free__4(x1,x2,x3,x4:pobject);
begin
if (x1<>nil) then freeobj(x1);
if (x2<>nil) then freeobj(x2);
if (x3<>nil) then freeobj(x3);
if (x4<>nil) then freeobj(x4);
end;
procedure free__5(x1,x2,x3,x4,x5:pobject);
begin
if (x1<>nil) then freeobj(x1);
if (x2<>nil) then freeobj(x2);
if (x3<>nil) then freeobj(x3);
if (x4<>nil) then freeobj(x4);
if (x5<>nil) then freeobj(x5);
end;
procedure free__6(x1,x2,x3,x4,x5,x6:pobject);
begin
if (x1<>nil) then freeobj(x1);
if (x2<>nil) then freeobj(x2);
if (x3<>nil) then freeobj(x3);
if (x4<>nil) then freeobj(x4);
if (x5<>nil) then freeobj(x5);
if (x6<>nil) then freeobj(x6);
end;
procedure free__7(x1,x2,x3,x4,x5,x6,x7:pobject);
begin
if (x1<>nil) then freeobj(x1);
if (x2<>nil) then freeobj(x2);
if (x3<>nil) then freeobj(x3);
if (x4<>nil) then freeobj(x4);
if (x5<>nil) then freeobj(x5);
if (x6<>nil) then freeobj(x6);
if (x7<>nil) then freeobj(x7);
end;

//new procs --------------------------------------------------------------------
function new__str:tdynamicstring;
begin
result:=tdynamicstring.create;
end;
function new__byte:tdynamicbyte;
begin
result:=tdynamicbyte.create;
end;
function new__int:tdynamicinteger;
begin
result:=tdynamicinteger.create;
end;
function new__comp:tdynamiccomp;
begin
result:=tdynamiccomp.create;
end;
function new__date:tdynamicdatetime;
begin
result:=tdynamicdatetime.create;
end;

//start-stop procs -------------------------------------------------------------
procedure gossroot__start;
var
   p:longint;
begin
try
//check
if system_started then exit else system_started:=true;

//.track array
for p:=0 to high(track_typecount) do track_typecount[p]:=0;

except;end;
end;

procedure gossroot__stop;
begin
try
//check
if not system_started then exit else system_started:=false;

except;end;
end;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function app____netmore:tobject;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=app__netmore;
end;

function info__root(xname:string):string;//information specific to this unit of code
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//check -> xname must be "gossroot.*"
if (strcopy1(xname,1,9)='gossroot.') then strdel1(xname,1,9) else exit;

//get
if      (xname='ver')        then result:='4.00.2880'
else if (xname='date')       then result:='01may2024'
else if (xname='name')       then result:='Root'
else if (xname='mode.int')   then result:=inttostr(info__mode)
else if (xname='mode')       then
   begin
   case info__mode of
   1:result:='Console App';
   2:result:='Windows Service';
   3:result:='GUI App';
   else result:='Unknown';
   end;//case
   end
else
   begin
   //nil
   end;

except;end;
end;

function info__rootfind(xname:string):string;//central point from which to find the requested information - 09apr2024
begin
//defaults
result:='';

//get
//.app
if (result='') then result:=info__app(xname);
//if (result='') then result:=info__gui(xname);
if (result='') then result:=info__root(xname);
if (result='') then result:=info__io(xname);
if (result='') then result:=info__img(xname);
if (result='') then result:=info__net(xname);
if (result='') then result:=info__win(xname);

//global values
if (result='') then
   begin
   //init
   xname:=strlow(xname);

   //get
   if      (xname='mode.int')         then result:=info__rootfind('gossroot.'+xname)
   else if (xname='mode')             then result:=info__rootfind('gossroot.'+xname);
   end;
end;

function info__mode:longint;
begin
//get
if (info_mode<=0) then
   begin
   info_mode:=1;

   end;
//set
result:=info_mode;
end;

//track procs ------------------------------------------------------------------
function track__limit:longint;
begin
result:=track_limit;
end;

procedure track__inc(xindex,xcreate:longint);
begin
if (xindex>=0) and (xindex<track_limit) then inc(track_typecount[xindex],xcreate);
end;

function track__typecount(xindex:longint):longint;
begin
if (xindex>=0) and (xindex<track_limit) then result:=track_typecount[xindex] else result:=0;
end;

function track__typecountstr(xindex:longint):string;
begin
result:=k64(track__typecount(xindex));
end;

//utf-8 procs ------------------------------------------------------------------
//## utf8__charlen ##
function utf8__charlen(x:byte):longint;
begin
if      (x>=240) then result:=4//4 byte character
else if (x>=224) then result:=3//3 byte
else if (x>=192) then result:=2//2 byte
else                  result:=1;//1 byte -> pure ascii (0..127)
end;
//## utf8__charpoint0 ##
function utf8__charpoint0(x:pobject;var xpos:longint):longint;
const
   vm=64;
var
   v1,v2,v3,v4:longint;
begin
//defaults
result:=0;

//get
case utf8__charlen(str__bytes0(x,xpos)) of
1:begin
   result:=str__bytes0(x,xpos+0);
   inc(xpos,1);
   end;
2:begin
   v1:=str__bytes0(x,xpos+0)-192;
   v2:=str__bytes0(x,xpos+1)-128;
   if (v1>=0) and (v2>=0) then result:=(v1*vm)+v2;
   inc(xpos,2);
   end;
3:begin
   v1:=str__bytes0(x,xpos+0)-224;
   v2:=str__bytes0(x,xpos+1)-128;
   v3:=str__bytes0(x,xpos+2)-128;
   if (v1>=0) and (v2>=0) and (v3>=0) then result:=(v1*vm*vm)+(v2*vm)+v3;
   inc(xpos,3);
   end;
4:begin
   v1:=str__bytes0(x,xpos+0)-240;
   v2:=str__bytes0(x,xpos+1)-128;
   v3:=str__bytes0(x,xpos+2)-128;
   v4:=str__bytes0(x,xpos+3)-128;
   if (v1>=0) and (v2>=0) and (v3>=0) and (v4>=0) then result:=(v1*vm*vm*vm)+(v2*vm*vm)+(v3*vm)+v4;
   inc(xpos,4);
   end
else
   begin
   inc(xpos,1);
   end;
end;//case
end;
//## utf8__encodetohtml ##
function utf8__encodetohtml(s,d:pobject;dappend,dasfilename,dnoslashes:boolean):boolean;
label
   redo,skipend;
var
   v,spos,slen:longint;
   //## xadd ##
   procedure xadd(x:string);
   begin
   str__sadd(d,x);
   end;
   //## xaddcode ##
   procedure xaddcode(x:longint);
   begin
   str__saddb(d,'&#'+inttostr(x)+';');
   end;
begin
//defaults
result:=false;

//check
if (not str__ok(s)) or (not str__ok(d)) then exit;

//init
if not dappend then str__clear(d);

//get
spos:=0;
slen:=str__len(s);
if (slen<=0) then goto skipend;

redo:
v:=utf8__charpoint0(s,spos);
if (v=ssmorethan) or (v=sslessthan) or (v=ssampersand) or (v=ssdoublequote) then xaddcode(v)//absolute minimum to make it html safe
else if dasfilename and ((v=sssemicolon) or (v=ssasterisk) or (v=ssquestion) or (v=ssdoublequote) or (v=sslessthan) or (v=ssmorethan) or (v=sspipe) or (v=ssdollar)) then xaddcode(v)
else if dnoslashes and ((v=ssslash) or (v=ssbackslash)) then xaddcode(v)
else if (v>=32) and (v<=127) then xadd(char(v))//visible ascii
else xaddcode(v);

//loop
if (spos<slen) then goto redo;

//successful
result:=true;
skipend:
end;
//## utf8__encodetohtmlstr ##
function utf8__encodetohtmlstr(x:string;xasfilename,xnoslashes:boolean):string;
var
   s,d:tobject;
begin
//defaults
result:='';

try
//init
s:=str__new9;
str__settext(@s,x);
d:=str__new9;
//get
utf8__encodetohtml(@s,@d,false,xasfilename,xnoslashes);
//set
result:=str__text(@d);
except;end;
try
str__free(@s);
str__free(@d);
except;end;
end;

//mail procs -------------------------------------------------------------------
//## mail__date ##
function mail__date(x:tdatetime):string;
var
   y,m,d,hr,min,sec,msec:word;
   oh,om,ox:longint;
   oxstr:string;
begin
//defaults
result:='';
try
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,hr,min,sec,msec);
low__gmtOFFSET(oh,om,ox);
oxstr:=low__aorbstr('-','+',ox>=0);
//get
result:=
 low__dayofweekstr(x,false)+', '+low__digpad11(d,2)+#32+low__month1(m,false)+#32+low__digpad11(y,4)+#32+
 low__digpad11(hr,2)+':'+low__digpad11(min,2)+':'+low__digpad11(sec,2)+#32+oxstr+low__digpad11(oh,2)+low__digpad11(om,2);
except;end;
end;
//## mail__fromqp ##
function mail__fromqp(_s:string):string;//quoted-printable, 22mar2024: updated "_" as a space
label
   redo;
var
   s,sline,d:tstr8;
   int1,p,spos:longint;
   //## xdecode ##
   procedure xdecode;
   label
      redo;
   var
      rcodeok:boolean;
      p:longint;
   begin
   //defaults
   rcodeok:=false;
   try
   //init
   if (sline.len<1) or (sline.pbytes[sline.len-1]<>ssEqual) then rcodeok:=true;//line has a return code
   if (sline.len>=1) and (sline.pbytes[sline.len-1]=ssEqual) then sline.setlen(sline.len-1);//strip trailing "="
   //get
   p:=0;
   redo:
   inc(p);
   if (p<=sline.len) then
      begin
      //get
      if (sline.pbytes[p-1]=ssEqual) then
         begin
         d.saddb(char(low__hexint2(sline.str1[p+1,2])));
         inc(p,2);
         end
      else if (sline.pbytes[p-1]=ssUnderscore) then d.aadd([ssSpace])//22mar2024
      else d.saddb(sline.str1[p,1]);
      //loop
      goto redo;
      end;
   except;end;
   try
   //.append return code
   if rcodeok then d.saddb(#10);
   except;end;
   end;
begin
//defaults
result:='';
try
s:=nil;
sline:=nil;
d:=nil;
//init
s:=str__new8;
s.sadd(_s);
sline:=str__new8;
d:=str__new8;//22mar2024
spos:=0;
//get
redo:
if low__nextline0(s,sline,spos) then
   begin
   //strip trailing white space "#32/#9"
   int1:=0;
   if (sline.len>=1) then for p:=sline.len downto 1 do if (sline.pbytes[p-1]<>9) and (sline.pbytes[p-1]<>32) then
      begin
      int1:=p;
      break;
      end;
   if (int1<>sline.len) then sline.setlen(int1);
   //decode
   xdecode;
   goto redo;
   end;
//set
result:=d.text;
except;end;
try
str__free(@s);
str__free(@sline);
str__free(@d);
except;end;
end;
//## mail__encodefield ##
function mail__encodefield(x:string;xencode:boolean):string;//like subject etc
label
   encode1,decode2,redo1,redo2,skipend;
var
   xmustencode:boolean;
   p:longint;
   str2,str1,z:string;
   //## xextractline ##
   function xextractline(var xresult,x,xtype,xline:string):boolean;
   var
      int1,p:longint;
   begin
   //defaults
   result:=false;
   try
   xline:='';
   xtype:='';//raw
   //check
   if (x='') then exit;
   //start
   if (x<>'') then for p:=1 to low__length(x) do if (x[p-1+stroffset]='=') then
      begin
      if strmatch(strcopy1(x,p,8),'=?UTF-8?') then
         begin
         if (p>=2) and ((x[p-1-1+stroffset]=#32) or (x[p-1-1+stroffset]=#9)) then int1:=1 else int1:=0;
         if (xresult='') then xresult:=strcopy1(x,1,p-1-int1);
         xtype:=strlow(strcopy1(x,p+8,1));
         strdel1(x,1,p+9);
         break;
         end
      else if strmatch(strcopy1(x,p,13),'=?iso-8859-1?') then
         begin
         if (p>=2) and ((x[p-1-1+stroffset]=#32) or (x[p-1-1+stroffset]=#9)) then int1:=1 else int1:=0;
         if (xresult='') then xresult:=strcopy1(x,1,p-1-int1);
         xtype:=strlow(strcopy1(x,p+13,1));
         strdel1(x,1,p+14);
         break;
         end;
      end;
   //finish
   if (x<>'') and (xtype<>'') then for p:=1 to low__length(x) do if (x[p-1+stroffset]='?') and strmatch(strcopy1(x,p,2),'?=') then
      begin
      result:=true;
      xline:=strcopy1(x,1,p-1);
      strdel1(x,1,p+1);
      break;
      end;
   //raw
   if (xtype='') then
      begin
      xline:=x;
      result:=(x<>'');
      x:='';
      end;
   except;end;
   end;
   //## hascode ##
   function hascode(xn:string;var x:string):boolean;
   begin
   result:=false;
   try
   result:=
    strmatch(strcopy1(x,1,low__length(xn)),xn) or
    strmatch(strcopy1(x,1,low__length(xn)+1),#32+xn) or
    strmatch(strcopy1(x,1,low__length(xn)+1),#9+xn);//Old Netscape Mail 3.0 compatible - they used leading tabs instead of spaces back then
   except;end;
   end;
begin
//defaults
result:='';
try
result:=x;
xmustencode:=false;
//check
if xencode then goto encode1 else goto decode2;
//-- Encode --
encode1:
if (not xmustencode) and (hascode('=?iso-8859-1?',x) or hascode('=?UTF-8?',x)) then xmustencode:=true;
if (not xmustencode) and (low__length(result)>60) then xmustencode:=true;//allows for 16c field name, e.g. "Subject: " = 9c
if (not xmustencode) and (result<>'') then for p:=1 to low__length(result) do
   begin
   case byte(result[p-1+stroffset]) of
   32..126:;//OK - 7bit
   else
      begin
      xmustencode:=true;
      break;
      end;
   end;//case
   end;//p
if not xmustencode then goto skipend;
//.encode - special note: last line of encoded content HAS NO trailing return code - 30oct2018
z:=low__tob64bstr(result,0);
result:='';
redo1:
str1:=strcopy1(z,1,44);
if (str1<>'') then
   begin
   result:=result+insstr(#10+#32,result<>'')+'=?iso-8859-1?B?'+str1+'?=';//15c + base64 data
   strdel1(z,1,44);
   goto redo1;
   end;
goto skipend;

//-- Decode --
decode2:
//init
z:=stripwhitespace_lt(result);
result:='';
low__remchar(z,#10);
low__remchar(z,#13);
redo2:
if xextractline(result,z,str1,str2) then
   begin
   //.base64
   if (str1='b') then
      begin
      if (str2<>'') then result:=result+low__fromb64str(str2);
      end
   //.quoted-printable encoded chunk
   else if (str1='q') then
      begin
      if (str2<>'') then result:=result+mail__fromqp(str2);
      end
   //.other
   else result:=result+str2;
   //loop
   goto redo2;
   end;
goto skipend;

skipend:
//remove trailing return codes
if (result<>'') then striptrailingrcodes(result);
except;end;
end;
//## mail__extractaddress ##
function mail__extractaddress(x:string):string;
var
   a:tfastvars;
   p2,p:longint;
   bol1:boolean;
begin
//defaults
result:='';
try
a:=nil;
//init
a:=tfastvars.create;
//get
x:=x+'<';
swapchars(x,#13,'<');
swapchars(x,#10,'<');
swapchars(x,'>','<');
//.split multiple entries into a list of vars "v0..vN" within "a"
low__splitto(x,a,'<');
if (a.s['v0']<>'')      then result:=a.s['v0']
else if (a.s['v1']<>'') then result:=a.s['v1']
else if (a.s['v2']<>'') then result:=a.s['v2']
else                         result:=a.s['v3'];
//filter to raw email address only
if (result<>'') then
   begin
   //.detect an invalid address (one without @ symbol)
   bol1:=false;
   if (result<>'') then for p:=1 to low__length(result) do if (result[p-1+stroffset]='@') then
      begin
      bol1:=true;
      break;
      end;//p
   if not bol1 then result:='';

   //.remove leading labels
   if (result<>'') then for p:=1 to low__length(result) do if (result[p-1+stroffset]='@') then
      begin
      for p2:=p downto 1 do if (result[p2-1+stroffset]=#32) or (result[p2-1+stroffset]='<') or (result[p2-1+stroffset]='>') or (result[p2-1+stroffset]=';') or (result[p2-1+stroffset]=',') then
         begin
         result:=strcopy1(result,p2+1,low__length(result));
         break;
         end;//p2
      break;
      end;

   //.remove trailing labels
   if (result<>'') then for p:=1 to low__length(result) do if (result[p-1+stroffset]='@') then
      begin
      for p2:=p to low__length(result) do if (result[p2-1+stroffset]=#32) or (result[p2-1+stroffset]='<') or (result[p2-1+stroffset]='>') or (result[p2-1+stroffset]=';') or (result[p2-1+stroffset]=',')  then
         begin
         result:=strcopy1(result,1,p2-1);
         break;
         end;//p2
      break;
      end;
   end;
except;end;
try;freeobj(@a);except;end;
end;
//## mail__filteraddresses ##
function mail__filteraddresses(x:string;xaddressesonly,xwraponlines:boolean):string;
var
   a:tdynamicstring;
   d:tstr8;
   p:longint;
   xline,v:string;
begin
//defaults
result:='';
try
result:=x;
a:=nil;
d:=nil;
//check
if (x='') then exit;
//init
a:=tdynamicstring.create;
d:=str__new8;
swapchars(x,#13,#10);
swapchars(x,';',#10);
swapchars(x,',',#10);//28oct2018
swapstrs(x,'<',#10+'<');
swapstrs(x,'>','>'+#10);
a.text:=x;
xline:='';
//get
if (a.count>=1) then for p:=0 to (a.count-1) do if (a.value[p]<>'') then
   begin
   //filter
   v:=a.value[p];
   if xaddressesonly then v:=mail__extractaddress(v);
   //get
   if (v<>'') then
      begin
      case xwraponlines of
      false:d.saddb(insstr(', ',d.len>=1)+xline);
      true:begin
         if ((low__length(xline)+low__length(v))<=74) then xline:=xline+v+', '//76c line length limit
         else
            begin
            if (xline<>'') then d.saddb(xline+#10);//let NO accidental blank lines through - 04nov2018
            xline:=#32+v+', ';//enforce leading space for next line
            end;
         end;//begin
      end;//case
      end;//if
   end;//p
//.finalise
if (xline<>'') then d.saddb(xline+#10);//let NO accidental blank lines through - 04nov2018
//set
result:=striptrailingrcodesb(d.text);//no trailing RCODE
if (low__length(result)>=2) and (strcopy1(result,low__length(result)-1,2)=', ') then strdel1(result,low__length(result)-1,2);//remove trailing ", "
except;end;
try
freeobj(@a);
str__free(@d);
except;end;
end;
//## mail__diskname ##
function mail__diskname(xdate:tdatetime;xsubject:string;xtrycount:longint):string;
   //## xsafename80 ##
   function xsafename80(x:string):string;
   var//Special Note: forces "_" to "&#95;", allowing "_" to be used for other purposes
      lp,p,len:longint;
      xwithin:boolean;
   begin
   //defaults
   if (x='') then x:='(no subject)';
   //strip leading/trailing white space
   result:=stripwhitespace_lt(x);
   //convert from utf-8 binary to html using disk safe name convention
   result:=utf8__encodetohtmlstr(result,true,true);
   //force "_" to html code "&#95;" so the "_" can be used internally for filename importance -> do after ABOVE html conversion so the "&" is preserved - 15apr2024
   swapstrs(result,'_','&#95;');
   //check length, trim to last whoe "&#...;" code
   len:=low__length(result);
   if (len>80) then
      begin
      lp:=1;
      xwithin:=false;
      for p:=1 to len do
      begin
      if (result[p-1+stroffset]='&') then
         begin
         lp:=p-1;
         xwithin:=true;
         end
      else if (result[p-1+stroffset]=';') then xwithin:=false
      else if not xwithin then lp:=p;
      //trim
      if (p>=80) then
         begin
         result:=strcopy1(result,1,lp);
         break;
         end;
      end;//p
      end;
   end;
begin
result:=low__dateascode(xdate)+'_'+xsafename80(xsubject)+insstr('_'+inttostr(xtrycount),xtrycount>=1)+'.eml';
end;
//## mail__makemsg ##
function mail__makemsg(x:pobject;xsenderip,xfrom,xto,xsubject,xmsg:string;xdate:tdatetime;var e:string):boolean;//09feb2024
   //## xmsgfilter ##
   function xmsgfilter(x:string):string;
   label
      redo;
   var
      b:tstr8;
      xline:string;
      xlen,xpos:longint;
   begin
   //defaults
   result:='';
   try
   b:=nil;
   //check
   if (x='') then exit;
   //init
   b:=str__new8;
   xlen:=low__length(x);
   xpos:=1;
   //get
   redo:
   if low__nextline1(x,xline,xlen,xpos) then
      begin
      case (xline<>'') and (xline[1-1+stroffset]='.') of
      true:b.saddb('.'+xline+#10);//one dot => two dots ( . => .. )
      false:b.saddb(xline+#10);
      end;//case
      goto redo;
      end;
   //set
   result:=b.text;
   except;end;
   try;str__free(@b);except;end;
   end;
   //## ladd ##
   procedure ladd(xline:string);
   begin
   try;str__saddb(x,xline+#10);except;end;
   end;
begin
//defaults
result:=false;
try
e:=gecTaskfailed;

//check
if not str__lock(x) then exit;

//init
str__clear(x);

//get
ladd('From: '+mail__filteraddresses(xfrom,true,true));
ladd('To: '+mail__filteraddresses(xto,true,true));
ladd('Subject: '+xsubject);
ladd('Date: '+mail__date(xdate));
ladd('Content-Type: text/plain; charset=windows-1252; format=flowed');
ladd('Content-Transfer-Encoding: 7bit');
ladd('Content-Language: en-US');
ladd('');
ladd(xmsg);

//successful
result:=true;
except;end;
try;str__unlockautofree(x);except;end;
end;
//## mail__writemsg ##
function mail__writemsg(x:pobject;xsubject,xdestfolder:string):boolean;
label
   skipend,redo;
var
   df,e:string;
   xtrycount:longint;
begin
//defaults
result:=false;
try

//check
if not str__lock(x) then exit;

//get -> write as .tmp first (so remote client won't download until FULL file is written) then rename full file as a non-tmp
xtrycount:=0;
redo:

case (xdestfolder<>'') of
true:begin
   xdestfolder:=io__asfolder(xdestfolder);
   io__makefolder(xdestfolder);
   df:=xdestfolder+mail__diskname(now,xsubject,xtrycount);
   end;
false:df:=app__subfolder('inbox')+mail__diskname(now,xsubject,xtrycount);
end;

if io__fileexists(df+'.tmp') or io__fileexists(df) then
   begin
   inc(xtrycount);
   if (xtrycount>=500) then goto skipend;
   app__waitms(10);
   goto redo;
   end;

//set
if not io__tofile64(df+'.tmp',x,e) then goto skipend;
if not io__renamefile(df+'.tmp',df) then goto skipend;

//successful
result:=true;
skipend:
except;end;
try;str__unlockautofree(x);except;end;
end;

//memory management procs ------------------------------------------------------
procedure mem__newpstring(var z:pstring);//29NOV2011
begin
track__inc(satPstring,1);
system.new(z);
end;
procedure mem__despstring(var z:pstring);//29NOV2011
begin
system.dispose(z);
track__inc(satPstring,-1);
end;

function mem__getmem(var p:pointer;size,xid:longint):boolean;//27apr2021, 29apr2020
begin
result:=false;

try
system.getmem(p,size);
if (size<=0) then p:=nil;
track_bytes:=add64(track_bytes,size);
result:=true;
except;end;
end;

function mem__reallocmem(var p:pointer;oldsize,newsize,xid:longint):boolean;//27apr2021, 29apr2020
var
   //wasp:pointer;
   xok:boolean;
begin
//defaults
result:=false;

try
xok:=false;
//range
if (newsize<0) then newsize:=0;
//get
try
system.reallocmem(p,newsize);//does set to nil but we are covering it just incase - 27apr2021
xok:=true;
except;end;
//reset -> Delphi's proc fails to reset "p" to nil - 29apr2021
if (newsize<=0) or (not xok) then p:=nil;
//memory
track_bytes:=add64(track_bytes,newsize);
track_bytes:=sub64(track_bytes,oldsize);
//successful
result:=xok;
except;end;
end;

function mem__reallocmemCLEAR(var p:pointer;oldsize,newsize,xid:longint):boolean;//29apr2021, 29NOV2011
label
   skipend;
var
   a:pdlbyte;
   i:longint;
begin
//defaults
result:=false;

try
//range
if (oldsize<0) then oldsize:=0;
if (newsize<0) then newsize:=0;
//get
if not mem__reallocmem(p,oldsize,newsize,xid) then goto skipend;
//clear
if (p<>nil) and (newsize>oldsize) then//fixed 29apr2021
   begin
   a:=pdlbyte(p);
   for i:=oldsize to (newsize-1) do a[i]:=0;
   end;
//successful
result:=true;
skipend:
except;end;
end;

function mem__freemem(var x:pointer;oldsize,xid:longint):boolean;//27apr2021, 29apr2020
begin
result:=false;

try
if (x<>nil) then//27apr2021
   begin
   system.freemem(x);//does not set "x" to "nil" when freeing - 28apr2021
   x:=nil;//27apr2021
   track_bytes:=sub64(track_bytes,oldsize);
   end;
result:=true;
except;end;
end;

//block memory management procs ------------------------------------------------
function block__size:longint;
begin
result:=system_blocksize;//static, does not change during runtime
end;

function block__fastinfo(x:pobject;xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;
var
   pmem:pointer;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if str__ok(x) then
   begin
   if      (x^ is tstr9) then (x^ as tstr9).fastinfo(xpos,xmem,xmin,xmax)
   else if (x^ is tstr8) then
      begin
      if (xpos>=0) and (xpos<(x^ as tstr8).len) then
         begin
         xmem:=(x^ as tstr8).core;
         xmin:=0;
         xmax:=(x^ as tstr8).len-1;
         end;
      end
   else if (x^ is tintlist) then
      begin
      (x^ as tintlist).fastinfo(xpos,pmem,xmin,xmax);
      xmem:=pdlbyte(pmem);
      end;
   //successful
   result:=(xmem<>nil) and (xmax>=0) and (xmin>=0);
   end;
except;end;
end;

function block__fastptr(x:pobject;xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;
var
   bmem:pdlbyte;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if str__ok(x) then
   begin
   if      (x^ is tstr9) then
      begin
      (x^ as tstr9).fastinfo(xpos,bmem,xmin,xmax);
      xmem:=pointer(bmem);
      end
   else if (x^ is tstr8) then
      begin
      if (xpos>=0) and (xpos<(x^ as tstr8).len) then
         begin
         xmem:=(x^ as tstr8).core;
         xmin:=0;
         xmax:=(x^ as tstr8).len-1;
         end;
      end
   else if (x^ is tintlist) then (x^ as tintlist).fastinfo(xpos,xmem,xmin,xmax);
   //successful
   result:=(xmem<>nil) and (xmax>=0) and (xmin>=0);
   end;
except;end;
end;

procedure block__cls(x:pointer);
begin
if (x<>nil) then low__cls(x,block__size);
end;

function block__new:pointer;
begin
result:=mem__alloc(system_blocksize);
if (result<>nil) then track__inc(satBlock,1);
end;

procedure block__free(var x:pointer);
begin
if (x<>nil) then
   begin
   mem__free(x);
   x:=nil;
   if (x=nil) then track__inc(satBlock,-1);
   end;
end;

procedure block__freeb(x:pointer);
begin
if (x<>nil) then
   begin
   mem__free(x);
   x:=nil;
   if (x=nil) then track__inc(satBlock,-1);
   end;
end;

//binary string procs ----------------------------------------------------------
function cache__ptr(x:tobject):pobject;//09feb2024: Stores a "floating object" (a dynamically created object that is to be passed to a proc as a parameter)
begin                                //           but which has no persistent variable to act as a SAFE pointer -> object is thus stored on it's own temp var
                                     //           as a special variable "__cacheptr", allowing for safe pointer operations - works on Delphi 3 and Lazarus - 10feb2024
//defaults
result:=nil;
try
//get
if (x<>nil) then
   begin
   if (x is tobjectex) then
      begin
      (x as tobjectex).__cacheptr:=x;
      result:=@(x as tobjectex).__cacheptr;
      end
   else freeobj(@x);//base class doesn't support ".__cacheptr" so we must free it and return nil
   end;
except;end;
end;
//## str__info ##
function str__info(x:pobject;var xstyle:longint):boolean;
begin
result:=false;
xstyle:=0;

try
if (x<>nil) and (x^<>nil) then
   begin
   if (x^ is tstr8) then
      begin
      xstyle:=8;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      xstyle:=9;
      result:=true;
      end;
   end;
except;end;
end;
//## str__info2 ##
function str__info2(x:pobject):longint;
begin
str__info(x,result);
end;
//## str__ok ##
function str__ok(x:pobject):boolean;
begin
//defaults
result:=false;
try
//get
if (x<>nil) and (x^<>nil) then result:=(x^ is tstr8) or (x^ is tstr9);
except;end;
end;
//## str__lock ##
function str__lock(x:pobject):boolean;
begin
result:=false;
try
result:=str__ok(x);
if result then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).lock
   else if (x^ is tstr9) then (x^ as tstr9).lock
   else result:=false;
   end;
except;end;
end;
//## str__lock2 ##
function str__lock2(x,x2:pobject):boolean;
begin
result:=true;
try
if not str__lock(x)  then result:=false;
if not str__lock(x2) then result:=false;
except;end;
end;
//## str__unlock ##
function str__unlock(x:pobject):boolean;
begin
result:=false;
try
result:=str__ok(x);
if result then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).unlock
   else if (x^ is tstr9) then (x^ as tstr9).unlock
   else result:=false;
   end;
except;end;
end;
//## str__unlockautofree ##
procedure str__unlockautofree(x:pobject);
begin
try;if str__unlock(x) then str__autofree(x);except;end;
end;
//## str__uaf ##
procedure str__uaf(x:pobject);
begin
try;if str__unlock(x) then str__autofree(x);except;end;
end;
//## str__uaf2 ##
procedure str__uaf2(x,x2:pobject);
begin
try
if str__unlock(x)  then str__autofree(x);
if str__unlock(x2) then str__autofree(x2);
except;end;
end;
//## str__autofree ##
procedure str__autofree(x:pobject);
begin
try
if str__ok(x) then
   begin
   if      (x^ is tstr8) and (x^ as tstr8).oautofree and ((x^ as tstr8).lockcount=0) then freeobj(x)
   else if (x^ is tstr9) and (x^ as tstr9).oautofree and ((x^ as tstr9).lockcount=0) then freeobj(x);
   end;
except;end;
end;
//## str__mem ##
function str__mem(x:pobject):longint;
begin
result:=0;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).datalen
else if (x^ is tstr9) then result:=(x^ as tstr9).mem;
except;end;
try;str__uaf(x);except;end;
end;
//## str__len ##
function str__len(x:pobject):longint;
begin
result:=0;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).len
else if (x^ is tstr9) then result:=(x^ as tstr9).len;
except;end;
try;str__uaf(x);except;end;
end;
//## str__datalen ##
function str__datalen(x:pobject):longint;
begin
result:=0;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).datalen
else if (x^ is tstr9) then result:=(x^ as tstr9).datalen;
except;end;
try;str__uaf(x);except;end;
end;
//## str__equal ##
function str__equal(s,s2:pobject):boolean;
label
   skipend;
var
   smin,smax,smin2,smax2,p,slen,slen2:longint;
   smem,smem2:pdlbyte;
begin
result:=false;
try
//check
if not str__lock2(s,s2) then goto skipend;

//length check
slen :=str__len(s);
slen2:=str__len(s2);
if (slen<>slen2) then goto skipend;
if (slen<=0) then
   begin
   result:=true;
   goto skipend;
   end;

//data check
smax:=-2;
smax2:=-2;
for p:=0 to (slen-1) do
begin
if (p>smax)  and (not block__fastinfo(s,p,smem,smin,smax)) then goto skipend;
if (p>smax2) and (not block__fastinfo(s2,p,smem2,smin2,smax2)) then goto skipend;
//.compare
if (smem[p-smin]<>smem2[p-smin2]) then goto skipend;
end;//p

//successful
result:=true;
skipend:
except;end;
try;str__uaf2(s,s2);except;end;
end;
//## str__minlen ##
function str__minlen(x:pobject;xnewlen:longint):boolean;//29feb2024: created
begin
//defaults
result:=false;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).minlen(xnewlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).minlen(xnewlen);
except;end;
try;str__uaf(x);except;end;
end;
//## str__setlen ##
function str__setlen(x:pobject;xnewlen:longint):boolean;
begin
//defaults
result:=false;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).setlen(xnewlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).setlen(xnewlen);
except;end;
try;str__uaf(x);except;end;
end;
//## str__new8 ##
function str__new8:tstr8;
begin
result:=nil;try;result:=tstr8.create(0);except;end;
end;
//## str__new9 ##
function str__new9:tstr9;
begin
result:=nil;try;result:=tstr9.create(0);except;end;
end;
//## str__newaf8 ##
function str__newaf8:tstr8;//autofree
begin
result:=nil;try;result:=tstr8.create(0);result.oautofree:=true;except;end;
end;
//## str__newaf9 ##
function str__newaf9:tstr9;//autofree
begin
result:=nil;try;result:=tstr9.create(0);result.oautofree:=true;except;end;
end;
//## str__free ##
procedure str__free(x:pobject);
begin
freeobj(x);
end;
//## str__splice ##
function str__splice(x:pobject;xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
begin
//defaults
result:=false;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).splice(xpos,xlen,xoutmem,xoutlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).splice(xpos,xlen,xoutmem,xoutlen);
except;end;
try;str__uaf(x);except;end;
end;
//## str__clear ##
procedure str__clear(x:pobject);
begin
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then (x^ as tstr8).clear
else if (x^ is tstr9) then (x^ as tstr9).clear;
except;end;
try;str__uaf(x);except;end;
end;
//## str__softclear ##
procedure str__softclear(x:pobject);
begin
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then (x^ as tstr8).clear
else if (x^ is tstr9) then (x^ as tstr9).softclear;
except;end;
try;str__uaf(x);except;end;
end;
//## str__softclear2 ##
procedure str__softclear2(x:pobject;xmaxlen:longint);
begin
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then
   begin
   if ((x^ as tstr8).len>xmaxlen) then (x^ as tstr8).setlen(xmaxlen);
   end
else if (x^ is tstr9) then (x^ as tstr9).softclear2(xmaxlen);
except;end;
try;str__uaf(x);except;end;
end;

//.string procs ----------------------------------------------------------------
//## addrec ##
function str__addrec(x:pobject;xrec:pointer;xrecsize:longint):boolean;//20feb2024, 07feb2022
begin
result:=str__pins2(x,pdlbyte(xrec),xrecsize,str__len(x),0,xrecsize-1);
end;
//## add ##
function str__add(x,xadd:pobject):boolean;
begin
result:=false;try;result:=str__ins2(x,xadd,str__len(x),0,max32);except;end;
end;
//## addb ##
function str__addb(x,xadd:tobject):boolean;
begin
result:=false;try;result:=str__add(@x,@xadd);except;end;
end;
//## add2 ##
function str__add2(x,xadd:pobject;xfrom,xto:longint):boolean;
begin
result:=false;try;result:=str__ins2(x,xadd,str__len(x),xfrom,xto);except;end;
end;
//## add3 ##
function str__add3(x,xadd:pobject;xfrom,xlen:longint):boolean;
begin
//result:=false;try;if (xlen>=1) then result:=str__ins2(x,xadd,str__len(x),xfrom,xfrom+xlen-1) else result:=true;except;end;
if (xlen>=1) then result:=str__ins2(x,xadd,str__len(x),xfrom,xfrom+xlen-1) else result:=true;
end;
//## add31 ##
function str__add31(x,xadd:pobject;xfrom1,xlen:longint):boolean;
begin
result:=false;try;if (xlen>=1) then result:=str__ins2(x,xadd,str__len(x),(xfrom1-1),(xfrom1-1)+xlen-1) else result:=true;except;end;
end;
//## str__padd ##
function str__padd(s:pobject;x:pdlbyte;xsize:longint):boolean;//15feb2024
begin
if (xsize<=0) then result:=true else result:=str__pins2(s,x,xsize,str__len(s),0,xsize-1);
end;
//## str__pins2 ##
function str__pins2(s:pobject;x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;
begin
result:=false;
try
if str__lock(s) then
   begin
   if      (s^ is tstr9) then result:=(s^ as tstr9).pins2(x,xcount,xpos,xfrom,xto)
   else if (s^ is tstr8) then result:=(s^ as tstr8).pins2(x,xcount,xpos,xfrom,xto);
   end;
except;end;
try;str__uaf(s);except;end;
end;
//## ins ##
function str__ins(x,xadd:pobject;xpos:longint):boolean;
begin
result:=false;try;result:=str__ins2(x,xadd,xpos,0,max32);except;end;
end;
//## str__ins2 ##
function str__ins2(x,xadd:pobject;xpos,xfrom,xto:longint):boolean;
begin
result:=false;
try
//get
if low__true2(str__lock(x),str__lock(xadd)) then
   begin
   if      (x^ is tstr9) then result:=(x^ as tstr9).ins2(xadd,xpos,xfrom,xto)//79% native speed of tstr8.ins2 which uses a single block of memory
   else if (x^ is tstr8) then result:=(x^ as tstr8)._ins2(xadd,xpos,xfrom,xto);
   end;
except;end;
try
str__uaf(x);
str__uaf(xadd);
except;end;
end;
//## del3 ##
function str__del3(x:pobject;xfrom,xlen:longint):boolean;//06feb2024
begin
result:=str__del(x,xfrom,xfrom+xlen-1);
end;
//## del ##
function str__del(x:pobject;xfrom,xto:longint):boolean;//06feb2024
label
   skipend;
var
   smin,dmin,smax,dmax,xlen,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=true;//pass-thru
try
if not str__lock(x) then exit;
xlen:=str__len(x);

//check
if (xlen<=0) or (xfrom>xto) or (xto<0) or (xfrom>=xlen) then exit;
//get
if frcrange2(xfrom,0,xlen-1) and frcrange2(xto,xfrom,xlen-1) then
   begin
   //shift down
   int1:=xto+1;
   if (int1<xlen) then
      begin
      //init
      smax:=-2;
      dmax:=-2;
      //get
      for p:=int1 to (xlen-1) do
      begin
      if (p>smax) and (not block__fastinfo(x,p,smem,smin,smax)) then goto skipend;
      v:=smem[p-smin];

      if ((xfrom+p-int1)>dmax) and (not block__fastinfo(x,xfrom+p-int1,dmem,dmin,dmax)) then goto skipend;
      dmem[xfrom+p-int1-dmin]:=v;
      end;//p
      end;
   //resize
   result:=str__setlen(x,xlen-(xto-xfrom+1));
   end;
skipend:
except;end;
end;
//## str__sadd ##
function str__sadd(x:pobject;var xdata:string):boolean;
begin
result:=false;
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).sadd(xdata)
else if (x^ is tstr9) then result:=(x^ as tstr9).sadd(xdata);
except;end;
try;str__uaf(x);except;end;
end;
//## str__saddb ##
function str__saddb(x:pobject;xdata:string):boolean;
begin
result:=false;try;result:=str__sadd(x,xdata);except;end;
end;
//## str__remchar ##
function str__remchar(x:pobject;y:byte):boolean;//29feb2024: created
label
   skipend;
var
   smin,smax,dmin,dmax,slen,dlen,p:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try
//check
if not str__lock(x) then exit;

//init
slen:=str__len(x);
dlen:=0;
if (slen<=0) then goto skipend;
smax:=-2;
smin:=-1;
dmax:=-2;
dmin:=-1;

//get
for p:=0 to (slen-1) do
begin
if (p>smax) and (not block__fastinfo(x,p,smem,smin,smax)) then goto skipend;
v:=smem[p-smin];
if (v<>y) then
   begin
   if (dlen>dmax) and (not block__fastinfo(x,dlen,dmem,dmin,dmax)) then goto skipend;
   dmem[dlen-dmin]:=v;
   inc(dlen);
   end;
end;//p

//finalise
if (dlen<>slen) then
   begin
   str__setlen(x,dlen);
   result:=true;
   end;

skipend:
except;end;
try;str__uaf(x);except;end;
end;
//## str__text ##
function str__text(x:pobject):string;
begin
//defaults
result:='';
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).text
else if (x^ is tstr9) then result:=(x^ as tstr9).text;
except;end;
try;str__uaf(x);except;end;
end;
//## str__settext ##
function str__settext(x:pobject;var xtext:string):boolean;
begin
//defaults
result:=false;

try
//check
if not str__lock(x) then exit;

//get
if (x^ is tstr8) then
   begin
   (x^ as tstr8).text:=xtext;
   result:=true;
   end
else if (x^ is tstr9) then
   begin
   (x^ as tstr9).text:=xtext;
   result:=true;
   end;
except;end;
try;str__uaf(x);except;end;
end;
//## str__settextb ##
function str__settextb(x:pobject;xtext:string):boolean;
begin
result:=str__settext(x,xtext);
end;
//## str__str1 ##
function str__str1(x:pobject;xpos,xlen:longint):string;
begin
//defaults
result:='';
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).str1[xpos,xlen]
else if (x^ is tstr9) then result:=(x^ as tstr9).str1[xpos,xlen];
except;end;
try;str__uaf(x);except;end;
end;
//## str__str0 ##
function str__str0(x:pobject;xpos,xlen:longint):string;
begin
//defaults
result:='';
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).str[xpos,xlen]
else if (x^ is tstr9) then result:=(x^ as tstr9).str[xpos,xlen];
except;end;
try;str__uaf(x);except;end;
end;
//## str__copy81 ##
function str__copy81(x:tobject;xpos1,xlen:longint):tstr8;
begin
result:=str__newaf8;
str__add3(@result,@x,xpos1-1,xlen);
end;
//## str__copy91 ##
function str__copy91(x:tobject;xpos1,xlen:longint):tstr9;
begin
result:=str__newaf9;
str__add3(@result,@x,xpos1-1,xlen);
end;
//## str__bytes0 ##
function str__bytes0(x:pobject;xpos:longint):byte;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).bytes[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).bytes[xpos];
   end;
end;
//## str__bytes1 ##
function str__bytes1(x:pobject;xpos:longint):byte;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).bytes[xpos-1]
   else if (x^ is tstr9) then result:=(x^ as tstr9).bytes[xpos-1];
   end;
end;
//## str__setbytes0 ##
procedure str__setbytes0(x:pobject;xpos:longint;xval:byte);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).bytes[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).bytes[xpos]:=xval;
   end;
end;
//## str__setbytes1 ##
procedure str__setbytes1(x:pobject;xpos:longint;xval:byte);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).bytes[xpos-1]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).bytes[xpos-1]:=xval;
   end;
end;

function str__multipart_nextitem(x:pobject;var xpos:longint;var xboundary,xname,xfilename,xcontenttype:string;xoutdata:pobject):boolean;
label//Note: xboundary is the "boundary string" generated by the Browser when transmitting the form data
   redo,redo2,skipdone,skipend;
var
   lp,p,xdatapos,xdatalen,smin,smax,xlen,blen:longint;
   smem:pdlbyte;
   v,b1:byte;
   //## xreadline ##
   procedure xreadline;
   var
      n,v,xline:string;
      p3,lp2,p2:longint;
      c:byte;
      xwithinquotes:boolean;
      //## xclean ##
      function xclean(x:string):string;
      var
         p:longint;
         //## xcharok ##
         function xcharok(x:byte):boolean;
         begin
         result:=(x<>ssSpace) and (x<>ssTab) and (x<>ssDoublequote) and (x<>10) and (x<>13);
         end;
      begin
      result:='';
      try
      //defaults
      result:=x;
      //pre-clean
      if (result<>'') then
         begin
         for p:=1 to low__length(result) do
         begin
         if xcharok( ord(result[p-1+stroffset]) ) then
            begin
            result:=strcopy1(result,p,low__length(result));
            break;
            end;
         end;//p
         end;
      //post-clean
      if (result<>'') then
         begin
         for p:=low__length(result) downto 1 do
         begin
         if xcharok( ord(result[p-1+stroffset]) ) then
            begin
            result:=strcopy1(result,1,p);
            break;
            end;
         end;//p
         end;
      except;end;
      end;
   begin
   try
   xwithinquotes:=false;
   xline:=str__str0(x,lp,p-lp)+';';
   lp2:=1;
   for p2:=1 to low__length(xline) do
   begin
   c:=ord(xline[p2-1+stroffset]);
   if      (c=ssDoublequote) then xwithinquotes:=not xwithinquotes
   else if (c=ssSemicolon) and (not xwithinquotes) then
      begin
      n:=strcopy1(xline,lp2,p2-lp2);
      v:='';
      lp2:=p2+1;
      //.split into name+value
      if (n<>'') then
         begin
         for p3:=1 to low__length(n) do
         begin
         c:=ord(n[p3-1+stroffset]);
         if (c=ssColon) or (c=ssEqual) then
            begin
            //get
            v:=xclean(strcopy1(n,p3+1,low__length(n)));
            n:=xclean(strlow(strcopy1(n,1,p3-1)));
            //set
            if      (n='name')         then xname:=v
            else if (n='filename')     then xfilename:=v
            else if (n='content-type') then xcontenttype:=v;
            //stop
            break;
            end;
         end;//p3
         end;//n
      end;
   end;//p2
   except;end;
   end;
begin
//defaults
result:=false;
try
xname:='';
xfilename:='';
xcontenttype:='';
smin:=-1;
smax:=-2;

//check
if not low__true2(str__lock(x),str__lock(xoutdata)) then goto skipend;
if (x=xoutdata) then goto skipend;

//init
str__clear(xoutdata);
blen:=low__length(xboundary);
if (blen<=0) then goto skipend;
b1:=ord(xboundary[1-1+stroffset]);

xlen:=str__len(x);
if (xpos<0) then xpos:=0;
if (xpos>=xlen) then goto skipend;

//find boundary - start
redo:
if (xpos>smax) and (not block__fastinfo(x,xpos,smem,smin,smax)) then goto skipend;
if (smem[xpos-smin]=b1) and (xboundary=str__str1(x,xpos+1,blen)) then
   begin
   inc(xpos,blen);
   xdatapos:=xpos;
   xdatalen:=xlen-xpos;
   goto redo2;
   end;

//.inc
inc(xpos);
if (xpos<xlen) then goto redo;
//.failed
goto skipend;

//find boundary - finish
redo2:
if (xpos>smax) and (not block__fastinfo(x,xpos,smem,smin,smax)) then goto skipend;
if (smem[xpos-smin]=b1) then
   begin
   if (xboundary=str__str1(x,xpos+1,blen)) then
      begin
      xdatalen:=xpos-xdatapos-2;//back up to exclude previous CRLF
      goto skipdone;
      end
   else if ((strcopy1(xboundary,1,blen-2)+'--')=str__str1(x,xpos+1,blen)) then
      begin
      xdatalen:=xpos-xdatapos-2;//back up to exclude previous CRLF
      xpos:=xlen;//mark as at end of list
      goto skipdone;
      end;
   end;
//.inc
inc(xpos);
if (xpos<xlen) then goto redo2;

//done - read data
skipdone:

//.read header
lp:=xdatapos;
for p:=xdatapos to (xdatapos+xdatalen-1) do
begin
v:=str__bytes0(x,p);
if (v=13) and (str__bytes0(x,p+1)=10) and (str__bytes0(x,p+2)=13) and (str__bytes0(x,p+3)=10) then
   begin
   xreadline;
   if not str__add3(xoutdata,x,p+4,xdatalen-(p-xdatapos)-4) then goto skipend;
   break;
   end
else if (v=13) then
   begin
   xreadline;
   lp:=p+2;
   end;
end;

//successful
result:=true;
skipend:
except;end;
try
str__uaf(x);
str__uaf(xoutdata);
except;end;
end;

function bgetstr1(x:tobject;xpos1,xlen:longint):string;
begin
result:='';
try
if (str__len(@x)>=1) then
   begin
   if      (x is tstr8) then result:=(x as tstr8).str1[xpos1,xlen]
   else if (x is tstr9) then result:=(x as tstr9).str1[xpos1,xlen];
   end;
except;end;
try;str__autofree(@x);except;end;
end;

function _blen(x:tobject):longint;//does NOT destroy "x", keeps "x"
begin
result:=0;
try
if zzok(x,1001) then
   begin
   if      (x is tstr8) then result:=(x as tstr8).len
   else if (x is tstr9) then result:=(x as tstr9).len;
   end;
except;end;
end;

procedure bdel1(x:tobject;xpos1,xlen:longint);
begin
try
if (xpos1>=1) and (xlen>=1) and zzok(x,1003) then
   begin
   if      (x is tstr8) then (x as tstr8).del(xpos1-1,xpos1-1+xlen-1)
   else if (x is tstr9) then (x as tstr9).del(xpos1-1,xpos1-1+xlen-1);
   end;
except;end;
try;str__autofree(@x);except;end;
end;

function bcopystr1(x:string;xpos1,xlen:longint):tstr8;
begin
result:=nil;
try
result:=str__newaf8;
if (x<>'') then result.sadd3(x,xpos1-1,xlen);
except;end;
end;

function bcopystrall(x:string):tstr8;
begin
result:=nil;
try
result:=str__newaf8;
if (x<>'') then result.sadd(x);
except;end;
end;

function bcopyarray(x:array of byte):tstr8;
begin
result:=nil;
try
result:=str__newaf8;
result.aadd(x);
except;end;
end;

function bnew2(var x:tstr8):boolean;//21mar2022
begin
result:=false;
try
x:=nil;
x:=str__new8;
result:=(x<>nil);
except;end;
end;

function bnewlen(xlen:longint):tstr8;
begin
result:=nil;
try
result:=tstr8.create(frcmin32(xlen,0));
except;end;
end;

function bnewstr(xtext:string):tstr8;
begin
result:=nil;
try
result:=str__new8;
result.replacestr:=xtext;
except;end;
end;

function breuse(var x:tstr8;xtext:string):tstr8;//also acts as a pass-thru - 05jul2022
begin//Warning: Use with care, auto-creates, but never destroys -> that is upto the host
result:=nil;
try
if (x=nil) then x:=str__new8;
x.replacestr:=xtext;
result:=x;
except;end;
end;

function bnewfrom(xdata:tstr8):tstr8;
begin
result:=nil;
try
result:=tstr8.create(0);
result.replace:=xdata;
except;end;
end;

//zero checkers ----------------------------------------------------------------
function nozero__int32(xdebugID,x:longint):longint;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (int) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__int64(xdebugID:longint;x:comp):comp;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (comp) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__byt(xdebugID:longint;x:byte):byte;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (byte) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__dbl(xdebugID:longint;x:double):double;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (double) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__ext(xdebugID:longint;x:extended):extended;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (extended) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__cur(xdebugID:longint;x:currency):currency;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (currency) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__sig(xdebugID:longint;x:single):single;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (single) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__rel(xdebugID:longint;x:real):real;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+inttostr(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (real) error at location '+inttostr(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

//timing procs -----------------------------------------------------------------
function mn32:longint;//32bit minute timer - 08jan2024
begin
result:=system_min32_val;
end;

function ms64:comp;//64bit millisecond system timer, 01-SEP-2006
var//64bit system timer, replaces "gettickcount" with range of 49.7 days,
   //now with new range of 29,247 years.
   //Note: must be called atleast once every 49.7 days, or it will loose track so
   //      system timer should call this routine regularly.
   i4:tint4;
   tmp:comp;
begin
//defaults
result:=0;

try
{$ifdef d3laz}

//get
//i4.val:=gettickcount;
i4.val:=win____timeGettime;//high resolution timer - 28sep2021
//#1
result:=i4.bytes[0];
//#2
tmp:=i4.bytes[1];
result:=result+(tmp*256);
//#3
tmp:=i4.bytes[2];
result:=result+(tmp*256*256);
//#4
tmp:=i4.bytes[3];
result:=result+(tmp*256*256*256);
//#5
if (not system_ms64_init) then
   begin
{//debug code only
   if programtesting then
      begin
      ms64OFFSET:=max32;
      ms64OFFSET:=ms64OFFSET*4;
      end
   else ms64OFFSET:=0;
{}
   system_ms64_offset:=0;
   system_ms64_last:=result;
   system_ms64_init:=true;
   end;//end of if
//# thread safe - allow a large difference margin (10 minutes) so close calling
//# threads won't corrupt (increment falsely) the offset var.
if ((result+600000)<system_ms64_last) then system_ms64_offset:=add64(system_ms64_offset,system_ms64_last);
//lastv
system_ms64_last:=result;
//#6
result:=add64(result,system_ms64_offset);
{$endif}

{$ifdef D10}
result:=DateTimeToMilliseconds(now);
{$endif}
except;end;
end;

function ms64str:string;//06NOV2010
begin
result:=floattostr(ms64);
end;

function msok(var xref:comp):boolean;
begin
result:=(ms64>=xref);
end;

function msset(var xref:comp;xdelay:comp):boolean;
begin
result:=true;//pass-thru
xref:=add64(ms64,xdelay);
end;

function mswaiting(var xref:comp):boolean;//still valid, the timer is waiting to expire
begin
result:=(xref>=ms64);
end;

//simple message procs ---------------------------------------------------------
function showerror(x:string):boolean;
begin
result:=false;try;result:=showerror2(x,5);except;end;
end;
function showerror2(x:string;xsec:longint):boolean;
begin
result:=true;

try
app__writenil;
app__writeln('ERROR > '+x);
app__writenil;
app__waitsec(xsec);
except;end;
end;

procedure showbasic(x:string);
begin
{$ifdef debug}showmessage(x);{$else}showmsg(x);{$endif}
end;
//## showmsg ##
function showmsg(x:string):boolean;
begin
result:=showmsg2(x,5);
end;
//## showmsg2 ##
function showmsg2(x:string;xsec:longint):boolean;
begin
result:=true;
try
app__writenil;
app__writeln(' > '+x);
app__writenil;
app__waitsec(xsec);
except;end;
end;

//date and time procs ----------------------------------------------------------
//## low__uptime ##
function low__uptime(x:comp;xforcehr,xforcemin,xforcesec,xshowsec,xshowms:boolean;xsep:string):string;//28apr2024: changed 'dy' to 'd', 01apr2024: xforcesec, xshowsec/xshowms pos swapped, fixed - 09feb2024, 27dec2021, fixed 10mar2021, 22feb2021, 22jun2018, 03MAY2011, 07SEP2007
const//Show: days, hours, min, sec - 09feb2024, 03MAY2011
     //Note: x is time in milliseconds
   oneday  =86400000;
   onehour =3600000;
   onemin  =60000;
   onesec  =1000;
var
   dy,h,m,s,ms:comp;
   ok:boolean;
begin
try
//defaults
result:='';
ok:=false;
dy:=0;
h:=0;
m:=0;
s:=0;
ms:=0;

//range
x:=frcrange64(x,0,max64);

//get
if (x>=0) then
   begin
   //.day
   dy:=div64(x,oneday);
   x:=sub64(x,mult64(dy,oneday));
   //.hour
   h:=div64(x,onehour);
   if (h>23) then h:=23;//24feb2021
   x:=sub64(x,mult64(h,onehour));
   //.minute
   m:=div64(x,onemin);
   if (m>59) then m:=59;//24feb2021
   x:=sub64(x,mult64(m,onemin));
   //.second
   s:=div64(x,onesec);
   if (s>59) then s:=59;//24feb2021
   x:=sub64(x,mult64(s,onesec));
   //.ms
   ms:=x;
   if (ms>999) then ms:=999;//24feb2021
   end;

//set
if (dy>=1) or ok then
   begin
   result:=result+insstr(xsep,low__length(result)>=1)+low__digpad20(dy,1)+'d';//28apr2024: changed 'dy' to 'd', 02MAY2011
   ok:=true;
   end;
if (h>=1) or ok or xforcehr then
   begin
   result:=result+insstr(xsep,low__length(result)>=1)+low__digpad20(h,2)+'h';
   ok:=true;
   end;
if (m>=1) or ok or xforcemin then
   begin
   result:=result+insstr(xsep,low__length(result)>=1)+low__digpad20(m,2)+'m';
   ok:=true;
   end;
if (xshowsec or xshowms) and ((s>=1) or ok or xforcesec) then//01apr2024: xforcesec, fixed - 27dec2021
   begin
   result:=result+insstr(xsep,low__length(result)>=1)+low__digpad20(s,2)+'s';
   ok:=true;
   end;
if xshowms then//fixed - 27dec2021
   begin
   //enforce range
   result:=result+insstr(xsep,low__length(result)>=1)+low__digpad20(ms,low__insint(3,ok))+'ms';
   //ok:=true;
   end;
except;end;
end;
//## low__dhmslabel ##
function low__dhmslabel(xms:comp):string;//days hours minutes and seconds from milliseconds - 06feb2023
var
   xok:boolean;
   y:comp;
   v:string;
begin
//defaults
result:='0s';

try
//check
if (xms<0) then exit;
//init
xms:=div64(xms,1000);//ms -> seconds
xok:=false;
v:='';
//get
if xok or (xms>=86400) then
   begin
   y:=div64(xms,86400);
   xms:=sub64(xms,mult64(y,86400));
   xok:=true;
   v:=v+intstr64(y)+'d ';
   end;
if xok or (xms>=3600) then
   begin
   y:=div64(xms,3600);
   xms:=sub64(xms,mult64(y,3600));
   xok:=true;
   v:=v+insstr('0',(y<=9) and (v<>''))+intstr64(y)+'h ';//19may20223
   end;
if xok or (xms>=60) then
   begin
   y:=div64(xms,60);
   xms:=sub64(xms,mult64(y,60));
   //xok:=true;
   v:=v+insstr('0',(y<=9) and (v<>''))+intstr64(y)+'m ';//19may20223
   end;
v:=v+intstr64(xms)+'s';
//set
result:=v;
except;end;
end;
//## low__year ##
function low__year(xmin:longint):longint;
var
   y,m,d:word;
begin
result:=xmin;

try
low__decodedate2(now,y,m,d);
if (y>xmin) then result:=y;
except;end;
end;
//## low__yearstr ##
function low__yearstr(xmin:longint):string;
begin
result:='';try;result:=inttostr(low__year(xmin));except;end;
end;
//## low__gmt ##
function low__gmt(x:tdatetime):string;//gtm for webservers
var
   y,m,d,hr,min,sec,msec:word;
begin
//defaults
result:='';

try
//get
low__decodedate2(x,y,m,d);
low__decodetime2(x,hr,min,sec,msec);
//set
result:=low__weekday1(low__dayofweek(x),false)+', '+low__digpad11(d,2)+#32+low__month1(m,false)+#32+low__digpad11(y,4)+#32+low__digpad11(hr,2)+':'+low__digpad11(min,2)+':'+low__digpad11(sec,2)+' GMT';
except;end;
end;
//## low__dateinminutes ##
function low__dateinminutes(x:tdatetime):longint;//date in minutes (always >0)
begin//30% faster
result:=0;

try
result:=round(x*1440);
if (result<1) then result:=1;
except;end;
end;
//## low__dateascode ##
function low__dateascode(x:tdatetime):string;//tight as - 17oct2018
var
   h,s,ms,y,min,m,d:word;
begin
//defaults
result:='';

try
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,s,ms);
//get
result:=
 low__digpad11(y,4)+low__digpad11(m,2)+low__digpad11(d,2)+
 low__digpad11(h,2)+low__digpad11(min,2)+low__digpad11(s,2)+
 low__digpad11(ms,3);
except;end;
end;
//## low__SystemTimeToDateTime ##
function low__SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
begin
result:=0;try;with systemtime do result:=low__encodedate2(wYear,wMonth,wDay)+low__encodetime2(wHour,wMinute,wSecond,wMilliSeconds);except;end;
end;
//## low__gmtOFFSET ##
procedure low__gmtOFFSET(var h,m,factor:longint);
var//Confirmed using 02-JUL-2005 (all GMT offsets are correct - no summer daylight timings)
   a,b:longint;
   sys:tsystemtime;
begin
try
//defaults
h:=0;
m:=0;
factor:=1;
//get
win____getsystemtime(sys);
a:=low__dateinminutes(now);
b:=low__dateinminutes(low__SystemTimeToDateTime(sys));
//calc
a:=a-b;
if (a<0) then
   begin
   a:=-a;
   factor:=-1;
   end
else if (a=0) then factor:=0;
h:=a div 60;
dec(a,h*60);
m:=a;
except;end;
end;
//## low__makeetag ##
function low__makeetag(x:tdatetime):string;//high speed version - 25dec2023
begin
result:=low__makeetag2(x,'"');
end;
//## low__makeetag2 ##
function low__makeetag2(x:tdatetime;xboundary:string):string;//high speed version - 31mar2024, 25dec2023
var
   y,m,d,hr,min,sec,msec:word;
begin
//defaults
result:='';

try
//get
low__decodedate2(x,y,m,d);
low__decodetime2(x,hr,min,sec,msec);
result:=xboundary+inttostr(low__dayofweek(x))+'-'+inttostr(d)+'-'+inttostr(m)+'-'+inttostr(y)+'-'+inttostr(hr)+'-'+inttostr(min)+'-'+inttostr(sec)+'-'+inttostr(msec)+xboundary;
except;end;
end;
//## low__datetimename ##
function low__datetimename(x:tdatetime):string;//12feb2023
var
   y,m,d:word;
   h,min,s,ms:word;
begin
//defaults
result:='';

try
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,s,ms);
//get
result:=low__digpad11(y,4)+'-'+low__digpad11(m,2)+'-'+low__digpad11(d,2)+'--'+low__digpad11(h,2)+'-'+low__digpad11(min,2)+'-'+low__digpad11(s,2)+'-'+low__digpad11(ms,4);
except;end;
end;
//## low__datename ##
function low__datename(x:tdatetime):string;
var
   y,m,d:word;
begin
//defaults
result:='';

try
low__decodedate2(x,y,m,d);
result:=low__digpad11(y,4)+'-'+low__digpad11(m,2)+'-'+low__digpad11(d,2);
except;end;
end;
//## low__datetimename2 ##
function low__datetimename2(x:tdatetime):string;//10feb2023
var
   y,m,d:word;
   h,min,s,ms:word;
begin
//defaults
result:='';

try
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,s,ms);
//get
result:=low__digpad11(y,4)+low__digpad11(m,2)+low__digpad11(d,2)+'_'+low__digpad11(h,2)+low__digpad11(min,2)+low__digpad11(s,2)+low__digpad11(ms,4);
except;end;
end;
//## low__safedate ##
function low__safedate(x:tdatetime):tdatetime;
begin
result:=x;try;if (result<-693593) then result:=-693593 else if (result>9000000) then result:=9000000;except;end;
end;
//## low__decodedate2 ##
procedure low__decodedate2(x:tdatetime;var y,m,d:word);//safe range
begin
try;decodedate(low__safedate(x),y,m,d);except;end;
end;
//## low__decodetime2 ##
procedure low__decodetime2(x:tdatetime;var h,min,s,ms:word);//safe range
begin
try;decodetime(low__safedate(x),h,min,s,ms);except;end;
end;
//## low__encodedate2 ##
function low__encodedate2(y,m,d:word):tdatetime;
begin
result:=0;try;result:=encodedate(y,m,d);except;end;
end;
//## low__encodetime2 ##
function low__encodetime2(h,min,s,ms:word):tdatetime;
begin
result:=0;try;result:=encodetime(h,min,s,ms);except;end;
end;
//## low__dayofweek ##
function low__dayofweek(x:tdatetime):longint;//01feb2024
begin
result:=1;try;result:=dayofweek(low__safedate(x));except;end;
end;
//## low__dayofweek1 ##
function low__dayofweek1(x:tdatetime):longint;
begin
result:=frcrange32(low__dayofweek(x),1,7);
end;
//## low__dayofweek0 ##
function low__dayofweek0(x:tdatetime):longint;
begin
result:=frcrange32(low__dayofweek(x)-1,0,6);
end;
//## low__dayofweekstr ##
function low__dayofweekstr(x:tdatetime;xfullname:boolean):string;
begin
result:=low__weekday1(low__dayofweek1(x),xfullname);
end;
//## low__month1 ##
function low__month1(x:longint;xfullname:boolean):string;//08mar2022
begin
result:=low__month0(x-1,xfullname);
end;
//## low__month0 ##
function low__month0(x:longint;xfullname:boolean):string;//08mar2022
begin//note: x=1..12
result:='';
try
//range
x:=frcrange32(x,0,11);
case xfullname of
true:result:=system_month[x+1];
false:result:=system_month_abrv[x+1];
end;
except;end;
end;
//## low__weekday1 ##
function low__weekday1(x:longint;xfullname:boolean):string;//08mar2022
begin//note: x=1..7
result:=low__weekday0(x-1,xfullname);
end;
//## low__weekday0 ##
function low__weekday0(x:longint;xfullname:boolean):string;//08mar2022
begin
result:='';
try
//range
x:=frcrange32(x,0,11);
case xfullname of
true:result:=system_dayOfweek[x+1];
false:result:=system_dayOfweek_abrv[x+1];//0..11 -> 1..12
end;
except;end;
end;
//## low__leapyear ##
function low__leapyear(xyear:longint):boolean;
begin//Note: leap years are: 2024, 2028 and 2032 - when Feb has 29 days instead of the usual 28 days
result:=(xyear=((xyear div 4)*4));
end;
//## low__datetoday ##
function low__datetoday(x:tdatetime):longint;
const
   dim:array[1..12] of byte=(31,28,31,30,31,30,31,31,30,31,30,31);
var
   y,m,d:word;
   dy,dm:longint;
begin
//defaults
result:=0;

try
//init
low__decodedate2(x,y,m,d);//1 based
//range
y:=frcrange32(y,0,9999);
m:=frcrange32(m,low(dim),high(dim));
//get
for dy:=0 to y do
begin
for dm:=1 to 12 do
begin
if (dy=y) and (dm>=m) then break;
inc(result,dim[dm]);
if (dm=2) and low__leapyear(dy) then inc(result);
end;//dm
end;//dy
//day
inc(result,d);
except;end;
end;
//## low__datetosec ##
function low__datetosec(x:tdatetime):comp;
const
   dmin=60;
   dhour=3600;
   dday=24*dhour;
var
   h,m,s,ms:word;
begin
//defaults
result:=0;

try
//init
low__decodetime2(x,h,m,s,ms);
//days
result:=mult64(low__datetoday(x),dday);
//time
result:=add64( add64( mult64(frcmin32(h-1,0),dhour) , mult64(frcmin32(m-1,0),dmin) ) ,s);
except;end;
end;
//## low__datestr ##
function low__datestr(xdate:tdatetime;xformat:longint;xfullname:boolean):string;//09mar2022
var
   y,m,d:word;
begin
result:='';

try
low__decodedate2(xdate,y,m,d);
result:=low__date1(y,m,d,xformat,xfullname);
except;end;
end;
//## low__date1 ##
function low__date1(xyear,xmonth1,xday1:longint;xformat:longint;xfullname:boolean):string;
begin
result:=low__date0(xyear,xmonth1-1,xday1-1,xformat,xfullname);
end;
//## low__date0 ##
function low__date0(xyear,xmonth,xday:longint;xformat:longint;xfullname:boolean):string;
var
   xmonthstr,xth:string;
begin
//defaults
result:='';

try
//range
xday:=1+frcrange32(xday,0,30);
xmonth:=1+frcrange32(xmonth,0,11);
xmonthstr:=low__month1(xmonth,xfullname);
//get
case xday of
1,21,31:xth:='st';
2,22:xth:='nd';
3,23:xth:='rd';
else xth:='th';
end;
//set
case frcrange32(xformat,0,3) of
1:result:=low__digpad11(xday,1)+xth+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);
2:result:=xmonthstr+#32+low__digpad11(xday,1)+insstr(', '+low__digpad11(xyear,4),xyear>=0);
3:result:=xmonthstr+#32+low__digpad11(xday,1)+xth+insstr(', '+low__digpad11(xyear,4),xyear>=0);
else result:=low__digpad11(xday,1)+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);
end;
except;end;
end;
//## low__time0 ##
function low__time0(xhour,xminute:longint;xsep,xsep2:string;xuppercase,xshow24:boolean):string;
var
   dPM:boolean;
   xampm:string;
begin
//defaults
result:='';

try
//range
xhour:=frcrange32(xhour,0,23);
xminute:=frcrange32(xminute,0,59);
xsep:=strdefb(xsep,':');
xsep2:=strdefb(xsep2,#32);
//get
case xshow24 of
true:result:=low__digpad11(xhour,2)+xsep+low__digpad11(xminute,2);
false:begin
   //get
   dPM:=(xhour>=12);
   case xhour of
   13..23:dec(xhour,12);
   24:xhour:=12;//never used - 28feb2022
   0:xhour:=12;//"0:00" -> "12:00am"
   end;
   xampm:=low__aorbstr('am','pm',dPM);
   if xuppercase then xampm:=strup(xampm);
   //set
   result:=low__digpad11(xhour,1)+xsep+low__digpad11(xminute,2)+xsep2+xampm;
   end;
end;//case
except;end;
end;
//## low__hour0 ##
function low__hour0(xhour:longint;xsep:string;xuppercase,xshowAMPM,xshow24:boolean):string;
var
   dPM:boolean;
   xampm:string;
begin
//defaults
result:='';

try
//range
xhour:=frcrange32(xhour,0,23);
xsep:=strdefb(xsep,#32);
//get
case xshow24 of
true:result:=low__digpad11(xhour,2);
false:begin
   //get
   dPM:=(xhour>=12);
   case xhour of
   13..23:dec(xhour,12);
   24:xhour:=12;//never used - 28feb2022
   0:xhour:=12;//"0:00" -> "12:00am"
   end;
   if xshowAMPM then
      begin
      xampm:=low__aorbstr('am','pm',dPM);
      if xuppercase then xampm:=strup(xampm);
      end
   else xampm:='';
   //set
   result:=low__digpad11(xhour,1)+insstr(xsep+xampm,xshowAMPM);
   end;
end;//case
except;end;
end;

//string procs -----------------------------------------------------------------
//## low__lcolumn ##
function low__lcolumn(x:string;xmaxwidth:longint):string;//left aligned column
const
   xcolwidth='                                        ';//40c
begin
result:=x+strcopy1b(xcolwidth,1,frcmax32(low__lengthb(xcolwidth),xmaxwidth)-low__length(x));
end;
//## low__rcolumn ##
function low__rcolumn(x:string;xmaxwidth:longint):string;//right aligned column
const
   xcolwidth='                                        ';//40c
begin
result:=strcopy1b(xcolwidth,1,frcmax32(low__lengthb(xcolwidth),xmaxwidth)-low__length(x))+x;
end;
//## low__hexchar ##
function low__hexchar(x:byte):char;
begin
result:=#0;

try
//range
if (x>15) then x:=15;
//get
case x of
0..9   :result:=chr(48+x);
10..15 :result:=chr(55+x);
else    result:='?';
end;//case
except;end;
end;
//## low__hex ##
function low__hex(x:byte):string;
var
   a,b:byte;
begin
result:='';

try
a:=x div 16;
b:=x-(a*16);
result:=low__hexchar(a)+low__hexchar(b);
except;end;
end;
//## low__hexint2 ##
function low__hexint2(x2:string):longint;//26dec2023
   //## xval ##
   function xval(x:byte):longint;
   begin
   case x of
   48..57: result:=x-48;
   65..70: result:=x-55;
   97..102:result:=x-87;
   else    result:=0;
   end;//case
   end;
begin
result:=0;try;result:=(xval(strbyte1(x2,1))*16)+xval(strbyte1(x2,2));except;end;
end;
//## low__splitto ##
function low__splitto(s:string;d:tfastvars;ssep:string):boolean;//13jan2024
label
   redo;
var
   vcount,p:longint;
begin
//defaults
result:=false;

try
if (d<>nil) then d.clear else exit;
//init
if (ssep='') then ssep:='=';
s:=s+ssep;
vcount:=0;
//get
redo:
if (low__length(s)>=2) then for p:=1 to low__length(s) do if (s[p-1+stroffset]=ssep) then
   begin
   //get
   d.s['v'+inttostr(vcount)]:=strcopy1(s,1,p-1);
   //inc
   inc(vcount);
   strdel1(s,1,p);
   result:=true;//we have read at least one value
   goto redo;
   end;//p
except;end;
end;
//## low__ref32u ##
function low__ref32u(x:string):longint;//1..32 - 25dec2023, 04feb2023
var//Fast: 180% faster
   v:byte;
   p,xlen:longint;
begin
//default
result:=0;

try
//init
xlen:=length(x);
if (xlen<=0) then exit;
if (xlen>high(p4INT32)) then xlen:=high(p4INT32);
//get
for p:=0 to (xlen-1) do
begin
//2-stage - prevent math error
v:=byte(x[p+stroffset]);
if (v>=97) and (v<=122) then dec(v,32);
//inc
result:=result+p4INT32[p+1]*v;//fixed - 25dec2023
end;//p
//check
if (result=0) then result:=1;//never zero - 04feb2023
except;end;
end;
//## ref256 ##
function low__ref256(x:string):comp;//01may2025: never 0 for valid input, 28dec2023
var//Fast: 300% faster
   p,xlen:longint;
begin
//default
result:=0;

try
//init
xlen:=length(x);
if (xlen<=0) then exit;
if (xlen>high(p8CMP256)) then xlen:=high(p8CMP256);
//get
for p:=0 to (xlen-1) do result:=result+p8CMP256[p+1]*byte(x[p+stroffset]);//fixed - 25dec2023
//check
if (result=0) then result:=1;//never zero - 01may2024
except;end;
end;
//## ref256U ##
function low__ref256U(x:string):comp;//01may2025: never 0 for valid input, 28dec2023
var//Fast: 300% faster
   v:byte;
   p,xlen:longint;
begin
//default
result:=0;

try
//init
xlen:=low__length(x);
if (xlen<=0) then exit;
if (xlen>high(p8CMP256)) then xlen:=high(p8CMP256);
//get
for p:=0 to (xlen-1) do
begin
//lowercase
v:=byte(x[p+stroffset]);
if (v>=97) and (v<=122) then dec(v,32);
//add
result:=result+p8CMP256[p+1]*v;//fixed - 25dec2023
end;//p
//check
if (result=0) then result:=1;//never zero - 01may2024
except;end;
end;
//## low__nextline0 ##
function low__nextline0(xdata,xlineout:tstr8;var xpos:longint):boolean;//17oct2018
label
   skipend;
var//0-base
   //Super fast line reader.  Supports #13 / #10 / #13#10 / #10#13,
   //with support for last line detection WITHOUT a trailing #10/#13 or combination thereof.
   xlen,int1,p:longint;
begin
//defaults
result:=false;

try
//cehck
str__lock(@xdata);
str__lock(@xlineout);
if zznil(xdata,2199) or zznil(xlineout,2200) then goto skipend;
//init
xlineout.clear;
if (xpos<0) then xpos:=0;
xlen:=xdata.count;
//get
if (xlen>=1) and (xpos<xlen) then for p:=xpos to (xlen-1) do if (xdata.pbytes[p]=10) or (xdata.pbytes[p]=13) or ((p+1)=xlen) then
   begin
   //get
   result:=true;//detect even blank lines
   if (p>=xpos) then//fixed, was "p>xpos" - 07apr2020
      begin
      if ((p+1)=xlen) and (xdata.pbytes[p]<>10) and (xdata.pbytes[p]<>13) then int1:=1 else int1:=0;//adjust for last line terminated by #10/#13 or without either - 18oct2018
      xlineout.add3(xdata,xpos,p-xpos+int1);
      end;
   //inc
   if (p<(xlen-1)) and (xdata.pbytes[p]=13) and (xdata.pbytes[p+1]=10) then xpos:=p+2//2 byte return code
   else if (p<(xlen-1)) and (xdata.pbytes[p]=10) and (xdata.pbytes[p+1]=13) then xpos:=p+2//2 byte return code
   else xpos:=p+1;//1 byte return code
   //quit
   break;
   end;
skipend:
except;end;
try
str__uaf(@xdata);
str__uaf(@xlineout);
except;end;
end;
//## low__nextline1 ##
function low__nextline1(var xdata,xlineout:string;xdatalen:longint;var xpos:longint):boolean;//17oct2018
var//Super fast line reader.  Supports #13 / #10 / #13#10 / #10#13,
   //with support for last line detection WITHOUT a trailing #10/#13 or combination thereof.
   int1,p:longint;
begin
//defaults
result:=false;

try
xlineout:='';
//init
if (xpos<1) then xpos:=1;
//get
if (xdatalen>=1) and (xpos<=xdatalen) then for p:=xpos to xdatalen do if (xdata[p-1+stroffset]=#10) or (xdata[p-1+stroffset]=#13) or (p=xdatalen) then
   begin
   //get
   result:=true;//detect even blank lines
   if (p>xpos) then
      begin
      if (p=xdatalen) and (xdata[p-1+stroffset]<>#10) and (xdata[p-1+stroffset]<>#13) then int1:=1 else int1:=0;//adjust for last line terminated by #10/#13 or without either - 18oct2018
      xlineout:=strcopy1(xdata,xpos,p-xpos+int1);
      end;
   //inc
   if (p<xdatalen) and (xdata[p-1+stroffset]=#13) and (xdata[p+1-1+stroffset]=#10) then xpos:=p+2//2 byte return code
   else if (p<xdatalen) and (xdata[p-1+stroffset]=#10) and (xdata[p+1-1+stroffset]=#13) then xpos:=p+2//2 byte return code
   else xpos:=p+1;//1 byte return code
   //quit
   break;
   end;
except;end;
end;
//## low__matchmask ##
function low__matchmask(var xline,xmask:string):boolean;//04nov2019
label//Handles semi-complex masks (upto two "*" allow in a xmask - 04nov2019
     //Superfast: between 20,000 (short ~14c) to 4,000 (long ~160c) comparisons/sec -> Intel atom 1.33Ghz
     //Accepts masks:
     // exact='aaaaaaaaaaa', two-part='aaaaaa*aaaaaa', tri-part='aaa*aaa*aaa',
     // start='aaa*' or 'aaa*aaa*', end='*aaaa' or '*aaa*aaa', any='**' or '*'
   skipend;
var
   fs,fm,fe:string;
   fmlen,xpos,xpos2,xlen,p:longint;
   fexact,bol1:boolean;
begin
//defaults
result:=false;

try
//check
if (xmask='') then exit;
xlen:=length(xline);
if (xlen<=0) then exit;
//init
fs:=xmask;
fm:='';
fe:='';
fexact:=true;
//.fs
if (fs<>'') then for p:=1 to length(fs) do if (fs[p-1+stroffset]='*') then
   begin
   fe:=strcopy1(fs,p+1,length(fs));
   fs:=strcopy1(fs,1,p-1);
   fexact:=false;
   break;
   end;
//.fe
if (fe<>'') then for p:=length(fe) downto 1 do if (fe[p-1+stroffset]='*') then
   begin
   fm:=strcopy1(fe,1,p-1);
   strdel1(fe,1,p);
   fexact:=false;
   break;
   end;
//find
xpos:=1;

//.fexact
if fexact and (not strmatch(fs,xline)) then goto skipend;
//.fs
if (fs<>'') then
   begin
   if not strmatch(fs,strcopy1(xline,1,length(fs))) then goto skipend;
   xpos:=length(fs)+1;
   end;
//.fe
if (fe<>'') then
   begin
   xpos2:=length(xline)-length(fe)+1;
   if (xpos2<xpos) then goto skipend;
   if not strmatch(fe,strcopy1(xline,xpos2,length(fe))) then goto skipend;
   dec(xlen,length(fe));
   end;
//.fm
if (fm<>'') then
   begin
   fmlen:=length(fm);
   xpos2:=xlen-fmlen+1;
   if (xpos2<xpos) then goto skipend;
   bol1:=false;
   for p:=xpos to xpos2 do if strmatch(fm,strcopy1(xline,p,fmlen)) then//faster than "c1/c2" + comparetext (200% faster) - 04nov2019
      begin
      bol1:=true;
      break;
      end;//p
   if not bol1 then goto skipend;
   end;
//successful
result:=true;
skipend:
except;end;
end;
//## low__matchmaskb ##
function low__matchmaskb(xline,xmask:string):boolean;//04nov2019
begin
result:=false;try;result:=low__matchmask(xline,xmask);except;end;
end;
//## low__matchmasklist ##
function low__matchmasklist(var xline,xmasklist:string):boolean;//04oct2020
var//Note: masklist => "*.bmp;*.jpg;*.jpeg" etc
   lp,p,xlen:longint;
   str1:string;
   bol1:boolean;
begin
//defaults
result:=false;

try
//init
xlen:=length(xmasklist);
if (xlen<=0) then exit;
//get
lp:=1;
for p:=1 to xlen do
begin
bol1:=(xmasklist[p-1+stroffset]=fesep);//fesep=";"
if bol1 or (p=xlen) then
   begin
   //init
   if bol1 then str1:=strcopy1(xmasklist,lp,p-lp) else str1:=strcopy1(xmasklist,lp,p-lp+1);
   lp:=p+1;
   //get
   if (str1<>'') and low__matchmask(xline,str1) then
      begin
      result:=true;
      break;
      end;
   end;
end;//p
except;end;
end;
//## low__matchmasklistb ##
function low__matchmasklistb(xline:string;var xmasklist:string):boolean;//04oct2020
begin
result:=false;try;result:=low__matchmasklist(xline,xmasklist);except;end;
end;

//## low__size ##
function low__size(x:comp;xstyle:string;xpoints:longint;xsym:boolean):string;//01apr2024:plus support, 10feb2024: created
var
   xorgstyle,vneg,v,vp,s:string;
   vlen:longint;
   //## xdiv ##
   procedure xdiv(xdivfactor:longint;xsymbol:string);
   label
      skipend;
   begin
   try
   //range
   xdivfactor:=frcmin32(xdivfactor,0);
   //get
   s:=xsymbol;
   if (xdivfactor<=0) then goto skipend;
   //set
   vp:=strcopy1(v,vlen-frcmin32(xdivfactor-1,0),vlen);
   vp:=strcopy1b(strcopy1b('000000000000',1,xdivfactor-low__length(vp))+vp,1,xpoints);
   if (xdivfactor>=1) then
      begin
      strdel1(v,vlen-(xdivfactor-1),vlen);
      vlen:=low__length(v);
      if (strbyte1(v,vlen)=ssComma) then strdel1(v,vlen,1);
      if (v='') then v:='0';
      end;
   skipend:
   except;end;
   end;
begin
try
//defaults
result:='0';
//init
xpoints:=frcrange32(xpoints,0,3);
xstyle:=strlow(xstyle);
xorgstyle:=xstyle;
v:=k64(x);
vlen:=low__length(v);
vp:='';
vneg:='';

//minus
if (strbyte1(v,1)=ssdash) then
   begin
   vneg:='-';
   strdel1(v,1,1);
   vlen:=low__length(v);
   end;

//automatic style
if (xstyle='?') or (xstyle='mb+') then
   begin
   if      (vlen<=3)  then xstyle:='b'
   else if (vlen<=7)  then xstyle:='kb'
   else if (vlen<=11) then xstyle:='mb'
   else if (vlen<=15) then xstyle:='gb'
   else if (vlen<=19) then xstyle:='tb'
   else if (vlen<=23) then xstyle:='pb'
   else                    xstyle:='eb';

   //.plus -> force to this unit and above - 01apr2024
   if      (xorgstyle='kb+') and (vlen<=3)  then xstyle:='kb'
   else if (xorgstyle='mb+') and (vlen<=7)  then xstyle:='mb'
   else if (xorgstyle='gb+') and (vlen<=11) then xstyle:='gb'
   else if (xorgstyle='tb+') and (vlen<=15) then xstyle:='tb'
   else if (xorgstyle='pb+') and (vlen<=19) then xstyle:='pb'
   else if (xorgstyle='eb+') and (vlen<=23) then xstyle:='eb';
   end;

//get
if      (xstyle='kb') then xdiv(3,'KB')
else if (xstyle='mb') then xdiv(6+1,'MB')
else if (xstyle='gb') then xdiv(9+2,'GB')
else if (xstyle='tb') then xdiv(12+3,'TB')
else if (xstyle='pb') then xdiv(15+4,'PB')
else if (xstyle='eb') then xdiv(18+5,'EB')
else                       xdiv(0,'b');

//set
result:=vneg+v+insstr('.'+vp,vp<>'')+insstr(#32+s,xsym);
except;end;
end;
//## low__mbPLUS ##
function low__mbPLUS(x:comp;sym:boolean):string;//01apr2024: created
begin
result:=low__size(x,'mb+',3,sym);
end;
//## bDOT ##
function low__bDOT(x:comp;sym:boolean):string;
begin
result:=low__size(x,'b',0,sym);swapchars(result,',','.');
end;
//## low__b ##
function low__b(x:comp;sym:boolean):string;//fixed - 30jan2016
begin
result:=low__size(x,'b',0,sym);
end;
//## kb ##
function low__kb(x:comp;sym:boolean):string;
begin
result:=low__size(x,'kb',3,sym);
end;
//## kbb ##
function low__kbb(x:comp;p:longint;sym:boolean):string;
begin
result:=low__size(x,'kb',p,sym);
end;
//## mb ##
function low__mb(x:comp;sym:boolean):string;
begin
result:=low__size(x,'mb',3,sym);
end;
//## mbb ##
function low__mbb(x:comp;p:longint;sym:boolean):string;
begin
result:=low__size(x,'mb',p,sym);
end;
//## gb ##
function low__gb(x:comp;sym:boolean):string;
begin
result:=low__size(x,'gb',3,sym);
end;
//## gbb ##
function low__gbb(x:comp;p:longint;sym:boolean):string;
begin
result:=low__size(x,'gb',p,sym);
end;
//## mbAUTO ##
function low__mbAUTO(x:comp;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
begin
result:=low__size(x,'?',3,sym);
end;
//## mbAUTO2 ##
function low__mbAUTO2(x:comp;p:longint;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
begin
result:=low__size(x,'?',p,sym);
end;
//## ipercentage ##
function low__ipercentage(a,b:longint):extended;
begin
result:=0;

try
if (a<0) then a:=0;
if (b<1) then b:=1;
result:=(a/nozero__int32(1200003,b))*100;
if (result<0) then result:=0 else if (result>100) then result:=100;
except;end;
end;
//## percentage64 ##
function low__percentage64(a,b:comp):extended;//24jan2016
begin
result:=0;

try
if (a<0) then a:=0;
if (b<1) then b:=1;
result:=(a/nozero__int64(1200005,b))*100;
if (result<0) then result:=0 else if (result>100) then result:=100;
except;end;
end;
//## low__percentage64str ##
function low__percentage64str(a,b:comp;xsymbol:boolean):string;//04oct2022
begin
result:='';try;result:=curdec(low__percentage64(a,b),2,false)+insstr('%',xsymbol);except;end;
end;

//base64 procs -----------------------------------------------------------------
//## low__tob64 ##
function low__tob64(s,d:tstr8;linelength:longint;var e:string):boolean;//to base64
begin
result:=false;try;result:=low__tob641(s,d,1,linelength,e);except;end;
end;
//## low__tob641 ##
function low__tob641(s,d:tstr8;xpos1,linelength:longint;var e:string):boolean;//to base64 using #10 return codes - 13jan2024
label//Speed: 2,997Kb in 3320ms (~0.902Mb/sec) @ 200Mhz
   skipend;
var
   sptr:tstr8;
   smustfree:boolean;
   a,b:tint4;
   ll,slen,dlen,p,i:longint;
begin
//defaults
result:=false;
e:=gecOutOfMemory;
smustfree:=false;
try
sptr:=s;
str__lock(@s);
str__lock(@d);
//check
if zznil(s,2188) or zznil(d,2189) then goto skipend;
//init
if (str__len(@s)<=0) then
   begin
   result:=true;
   goto skipend;
   end;
//.detect in-out same conflict - 21aug2020
if (s=d) then
   begin
   smustfree:=true;
   sptr:=str__new8;
   sptr.add(s);
   s.clear;
   end;
d.clear;//07oct2020
dlen:=0;
slen:=str__len(@sptr);
ll:=0;
p:=1;
if (linelength<0) then linelength:=0;
//get
d.minlen(4096+6);
repeat
//.get
a.val:=0;
a.bytes[2]:=sptr.pbytes[p-1];
if ((p+1)<=slen) then a.bytes[1]:=sptr.pbytes[p+1-1] else a.bytes[1]:=0;
if ((p+0)<=slen) then a.bytes[0]:=sptr.pbytes[p+2-1] else a.bytes[0]:=0;
//.soup (3 -> 4)
b.bytes[0]:=(a.val div 262144);
dec(a.val,b.bytes[0]*262144);
b.bytes[1]:=(a.val div 4096);
dec(a.val,b.bytes[1]*4096);
if ((p+1)<=slen) then
   begin
   b.bytes[2]:=a.val div 64;
   dec(a.val,b.bytes[2]*64);
   end
else b.bytes[2]:=64;
if ((p+2)<=slen) then b.bytes[3]:=a.val else b.bytes[3]:=64;
//.encode
for i:=0 to 3 do b.bytes[i]:=base64[b.bytes[i]];
//.dlen
if ((dlen+6)>=d.len) then d.minlen(dlen+100000);//100K buffer
inc(dlen,4);
d.pbytes[dlen-3-1]:=b.bytes[0];
d.pbytes[dlen-2-1]:=b.bytes[1];
d.pbytes[dlen-1-1]:=b.bytes[2];
d.pbytes[dlen-1]  :=b.bytes[3];
//.line
if (linelength<>0) then
   begin
   inc(ll,4);
   if (ll>=linelength) then
      begin
      inc(dlen,1);
      d.pbytes[dlen-1]:=10;//was #13#10 but now just #10 - 13jan2024
      ll:=0;
      end;//if
   end;//if
//.inc
inc(p,3);
until (p>slen);
//.finalise
if (dlen>=1) then d.setlen(dlen);
//successful
result:=true;
skipend:
except;end;
try
if (not result) and zzok(d,7027) then d.clear;
if smustfree then str__free(@sptr);
str__uaf(@s);
str__uaf(@d);
except;end;
end;
//## low__tob64b ##
function low__tob64b(s:tstr8;linelength:longint):tstr8;//28jan2021
var
   e:string;
begin
result:=nil;
try;result:=str__new8;low__tob641(s,result,1,linelength,e);except;end;
try;result.oautofree:=true;except;end;
end;
//## low__tob64bstr ##
function low__tob64bstr(x:string;linelength:longint):string;//13jan2024
var
   s,d:tstr8;
   e:string;
begin
//defaults
result:='';
try
s:=nil;
d:=nil;
//init
s:=str__new8;
d:=str__new8;
//get
s.sadd(x);
x:='';//reduce memory
if low__tob64(s,d,linelength,e) then
   begin
   s.clear;//reduce memory
   result:=d.text;
   end;
except;end;
try;str__free(@s);str__free(@d);except;end;
end;
//## low__fromb64 ##
function low__fromb64(s,d:tstr8;var e:string):boolean;//from base64
begin
result:=low__fromb641(s,d,1,e);
end;
//## low__fromb641 ##
function low__fromb641(s,d:tstr8;xpos1:longint;var e:string):boolean;//from base64
label//Speed: 4,101Kb in 3150ms (~1.301Mb/sec) @ 200Mhz
   skipend;
var
   sptr:tstr8;
   smustfree:boolean;
   b,a:tint4;
   slen,dlen,c,p:longint;
   v:byte;
begin
//defaults
result:=false;
e:=gecOutOfMemory;
smustfree:=false;
try
sptr:=s;
str__lock(@s);
str__lock(@d);
//check
if zznil(s,2190) or zznil(d,2191) then goto skipend;
//init
if (str__len(@s)<=0) then
   begin
   result:=true;
   goto skipend;
   end;
//.detect in-out same conflict - 21aug2020
if (s=d) then
   begin
   smustfree:=true;
   sptr:=str__new8;
   sptr.add(s);
   s.clear;
   end;
d.clear;
dlen:=0;
slen:=str__len(@sptr);
p:=frcmin32(xpos1,1);
if (p>slen) then
   begin
   result:=true;
   goto skipend;
   end;
//get
repeat
a.val:=0;
c:=0;
repeat
//.store
v:=byte(base64r[sptr.pbytes[p-1]]-48);
if (v>=0) and (v<=63) then
   begin
   //.set
   case c of
   0:inc(a.val,v*262144);
   1:inc(a.val,v*4096);
   2:inc(a.val,v*64);
   3:begin
     inc(a.val,v);
     inc(c);
     inc(p);
     break;
     end;//begin
   end;//case
   //.inc
   inc(c,1);
   end
else if (v=64) then
   begin
   p:=slen;
   break;//=
   end;//if
//.inc
inc(p);
until (p>slen);
//.split (4 -> 3)
b.bytes[0]:=a.val div 65536;
dec(a.val,b.bytes[0]*65536);
b.bytes[1]:=a.val div 256;
dec(a.val,b.bytes[1]*256);
b.bytes[2]:=a.val;
//.set
case c of
4:begin
  inc(dlen,3);
  if ((dlen+3)>d.len) then d.minlen(dlen+100000);
  d.pbytes[dlen-2-1]:=b.bytes[0];
  d.pbytes[dlen-1-1]:=b.bytes[1];
  d.pbytes[dlen+0-1]:=b.bytes[2];
  end;//begin
3:begin//finishing #1
  inc(dlen,2);
  if ((dlen+2)>d.len) then d.minlen(dlen+100);
  d.pbytes[dlen-1-1]:=b.bytes[0];
  d.pbytes[dlen+0-1]:=b.bytes[1];
  end;//begin
1..2:begin//finishing #2
  inc(dlen,1);
  if ((dlen+1)>d.len) then d.minlen(dlen+100);
  d.pbytes[dlen+0-1]:=b.bytes[0];
  end;//begin
end;//end of case
until (p>=slen);
//.finalise
if (dlen>=1) then d.setlen(dlen);
//successful
result:=true;
skipend:
except;end;
try
if (not result) and zzok(d,7027) then d.clear;
if smustfree then str__free(@sptr);
str__uaf(@s);
str__uaf(@d);
except;end;
end;
//## low__fromb64b ##
function low__fromb64b(s:tstr8):tstr8;//28jan2021
var
   e:string;
begin
result:=nil;
try;result:=str__new8;low__fromb641(s,result,1,e);except;end;
try;result.oautofree:=true;except;end;
end;
//## low__fromb64str ##
function low__fromb64str(x:string):string;
var
   e:string;
   s,d:tstr8;
begin
//defaults
result:='';
try
s:=nil;
d:=nil;
//init
s:=str__new8;
d:=str__new8;
s.text:=x;
//get
if low__fromb641(s,d,1,e) then result:=d.text;
except;end;
try;str__free(@s);str__free(@d);except;end;
end;

//general procs ----------------------------------------------------------------
function debugging:boolean;
begin
{$ifdef debug}result:=true;{$else}result:=false;{$endif}
end;

function low__fireevent(xsender:tobject;x:tevent):boolean;
begin
result:=false;
try
if assigned(x) then
   begin
   x(xsender);
   result:=true;
   end;
except;end;
end;

function low__param(x:longint):string;//01mar2024
begin
result:='';
try
x:=frcmin32(x,0);
//impose a definite limit
if (x<=255) then result:=paramstr(x);
except;end;
end;

function low__paramstr1:string;
begin
result:=low__param(1);
end;

function vnew:tvars8;
begin
result:=nil;try;result:=tvars8.create;except;end;
end;

function vnew2(xdebugid:longint):tvars8;
begin
result:=nil;try;result:=tvars8.create;except;end;
end;

procedure low__int3toRGB(x:longint;var r,g,b:byte);
begin
//range
x:=frcrange32(x,0,16777215);
//get
//.b
b:=byte(frcrange32(x div (256*256),0,255));
dec(x,b*256*256);
//.g
g:=byte(frcrange32(x div 256,0,255));
dec(x,g*256);
//.r
r:=byte(frcrange32(x,0,255));
end;

//## low__comparearray ##
function low__comparearray(a,b:array of byte):boolean;//27jan2021
var
   ai,bi,va,vb,p:longint;
begin
//defaults
result:=false;

try
//get
if (sizeof(a)=sizeof(b)) then
   begin
   //init
   result:=true;
   ai:=low(a);
   bi:=low(b);
   //get
   for p:=1 to sizeof(a) do
   begin
   va:=a[ai];
   vb:=b[bi];
   if (va>=97) and (va<=122) then dec(va,32);
   if (vb>=97) and (vb<=122) then dec(vb,32);
   if (va<>vb) then
      begin
      result:=false;
      break;
      end;
   //inc
   inc(ai);
   inc(bi);
   end;//p
   end;
except;end;
end;
//## low__cls ##
function low__cls(x:pointer;xsize:longint):boolean;
begin
result:=false;try;result:=(x<>nil);if result then fillchar(x^,xsize,0);except;end;
end;
//## low__intr ##
function low__intr(x:longint):longint;//reverse longint
var
   s,d:tint4;
begin
result:=0;

try
s.val:=x;
d.bytes[0]:=s.bytes[3];//swap round
d.bytes[1]:=s.bytes[2];
d.bytes[2]:=s.bytes[1];
d.bytes[3]:=s.bytes[0];
result:=d.val;
except;end;
end;
//## low__wrdr ##
function low__wrdr(x:word):word;//reverse word
var
   s,d:twrd2;
begin
result:=0;

try
s.val:=x;
d.bytes[0]:=s.bytes[1];//swap round
d.bytes[1]:=s.bytes[0];
result:=d.val;
except;end;
end;
//## low__posn ##
function low__posn(x:longint):longint;
begin
result:=x;try;if (result<0) then result:=-result;except;end;
end;
//## low__iroll ##
procedure low__iroll(var x:longint;by:longint);//continuous incrementer with safe auto. reset
begin//if (x>capacity) reset to 0
try;x:=x+by;except;x:=0;end;
try;if (x<0) then x:=0;except;end;//required when compiler "range checking" is turned OFF - 25jun2022
end;
//## croll ##
procedure low__croll(var x:currency;by:currency);//continuous incrementer with safe auto. reset
begin//if (x>capacity) reset to 0
try;x:=x+by;except;x:=0;end;
try;if (x<0) then x:=0;except;end;//required when compiler "range checking" is turned OFF - 25jun2022
end;
//## roll64 ##
procedure low__roll64(var x:comp;by:comp);//continuous incrementer with safe auto. reset to user specified value - 05feb2016
begin//if (x>capacity) reset to 0
try
x:=x+by;
//.don't allow "x" to exceed upper limit of whole number range
if (x>max64) then x:=0
else if (x<0) then x:=0;//06sep2016
except;x:=0;end;
try;if (x<0) then x:=0;except;end;//required when compiler "range checking" is turned OFF - 25jun2022
end;
//## low__nrw ##
function low__nrw(x,y,r:longint):boolean;//number within range
begin
result:=false;try;result:=(x>=(y-r)) and (x<=(y+r));except;end;
end;

function low__iseven(x:longint):boolean;
begin//no error handling for maximum speed - 28mar2020
result:=(x=((x div 2)*2));
end;

function low__even(x:longint):boolean;
begin//no error handling for maximum speed - 28mar2020
result:=(x=((x div 2)*2));
end;

procedure low__msb16(var s:word);//most significant bit first - 22JAN2011
var//bit work, 16bit, swapper, swap
   a,b:twrd2;
begin
a.val:=s;
b.bytes[0]:=a.bytes[1];
b.bytes[1]:=a.bytes[0];
s:=b.val;
end;

procedure low__msb32(var s:longint);//most significant bit first - 22JAN2011
var//bit work, 32bit, swap, swapper,
   a,b:tint4;
begin
a.val:=s;
b.bytes[0]:=a.bytes[3];
b.bytes[1]:=a.bytes[2];
b.bytes[2]:=a.bytes[1];
b.bytes[3]:=a.bytes[0];
s:=b.val;
end;

function strlow(x:string):string;//make string lowercase
begin
result:='';try;result:=lowercase(x);except;end;
end;

function strup(x:string):string;//make string uppercase
begin
result:='';try;result:=uppercase(x);except;end;
end;

function strmatch(a,b:string):boolean;//same as (low__comparetext(a,b)=true) or (comparetext(a,b)=0)
begin
result:=false;try;result:=(comparetext(a,b)=0);except;end;
end;

function strmatch2(a,b:string):longint;
begin
result:=0;try;result:=comparestr(a,b);except;end;
end;

function strmatchCASE(a,b:string):boolean;//match using case sensitivity
begin
result:=false;try;result:=(comparestr(a,b)=0);except;end;
end;

function bnc(x:boolean):string;//boolean to number
begin
result:='';try;if x then result:='1' else result:='0';except;end;
end;

function uptob(x:string;sep:char):string;
begin
result:='';try;result:=upto(x,sep);except;end;
end;

function upto(var x:string;sep:char):string;
var
   p:longint;
   bol1:boolean;
begin
//defaults
result:='';

try
bol1:=false;
//get
for p:=1 to low__length(x) do if (x[p-1+stroffset]=sep) then
   begin
   result:=strcopy1(x,1,p-1);
   bol1:=true;
   break;
   end;
//fallback
if not bol1 then result:=x;
except;end;
end;

function swapcharsb(x:string;a,b:char):string;
begin
result:='';try;result:=x;swapchars(result,a,b);except;end;
end;

procedure swapchars(var x:string;a,b:char);//20JAN2011
var
   p:longint;
begin
try
//check
if (x='') then exit;
//get
for p:=0 to (low__length(x)-1) do if (x[p+stroffset]=a) then x[p+stroffset]:=b;
except;end;
end;

function swapallcharsb(x:string;n:char):string;//08apr2024
begin
result:=swapallchars(x,n);
end;

function swapallchars(var x:string;n:char):string;//08apr2024
var
   p:longint;
begin
try
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__length(result) do result[p-1+stroffset]:=n;
   end;
except;end;
end;

function swapstrsb(x,a,b:string):string;
begin
try;result:=x;swapstrs(result,a,b);except;end;
end;

function swapstrs(var x:string;a,b:string):boolean;
label
   redo;
var
   lenb,lena,maxp,p:longint;
begin
//defaults
result:=false;

try
//init
maxp:=low__length(x);
lena:=low__length(a);
lenb:=low__length(b);
p:=0;
//get
redo:
p:=p+1;
if (p>maxp) then exit;
if (x[p-1+stroffset]=a[0+stroffset]) and (strcopy1(x,p,lena)=a) then
   begin
   x:=strcopy1(x,1,p-1)+b+strcopy1(x,p+lena,maxp);
   p:=p+lenb-1;
   maxp:=maxp-lena+lenb;
   //mark as modified
   result:=true;
   end;
//loop
goto redo;
except;end;
end;

function stripwhitespace_lt(x:string):string;//strips leading and trailing white space
begin
result:='';

try
result:=x;
result:=stripwhitespace(result,false);
result:=stripwhitespace(result,true);
except;end;
end;

function stripwhitespace(x:string;xstriptrailing:boolean):string;
var//Agressive mode
   p:longint;
begin
//defaults
result:='';

try
//check
if (x='') then exit;

//find
case xstriptrailing of
false:begin//leading white space
   for p:=1 to low__length(x) do
   begin
   case ord(x[p-1+stroffset]) of
   0..32,160:;
   else
      begin
      result:=strcopy1(x,p,low__length(x));
      break;
      end;
   end;//case
   end;//p
   end;
true:begin//trailing white space
   for p:=low__length(x) downto 1 do
   begin
   case ord(x[p-1+stroffset]) of
   0..32,160:;
   else
      begin
      result:=strcopy1(x,1,p);
      break;
      end;
   end;//case
   end;//p
   end;
end;//case
except;end;
end;

procedure striptrailingrcodes(var x:string);
var
   p:longint;
begin
try
//remove last return codes
if (x<>'') then for p:=low__length(x) downto 1 do if (x[p-1+stroffset]<>#10) and (x[p-1+stroffset]<>#13) then
   begin
   x:=strcopy1(x,1,p);
   break;
   end;
except;end;
end;

function striptrailingrcodesb(x:string):string;
begin
result:='';try;result:=x;striptrailingrcodes(result);except;end;
end;

function freeobj(x:pobject):boolean;//09feb2024: Added support for "._rtmp" & mustnil, 02feb2021, 05may2020, 05DEC2011, 14JAN2011, 15OCT2004
var
   xmustnil:boolean;
{//was:
   //## xbasicthreadstop ##
   procedure xbasicthreadstop;
   label
      redo;
   var
      aref:comp;
      a:tbasicthreadstop;
      p:longint;
   begin
   try
   //defaults
   a:=(x^ as tbasicthreadstop);
   if zznil(a,2051) then exit;
   //muststop
   if a.stopping then
      begin
      x^:=nil;//nil only -> since another copy is already shuting this object down - 20feb2021
      exit;
      end;
   //signal thread to stop
   aref:=ms64+60000;//60sec timeout
   a.muststop;
   //timer is caught in a VCL event -> don't wait - 10may2021
   if a.vcl_waiting then
      begin
      x^:=nil;//nil only -> since another copy is already shuting this object down - 20feb2021
      a.mustfree;
      exit;
      end;
   //wait for thread to finish
   redo:
   if (not a.stopped) and (aref>=ms64) then
      begin
      app__processallmessages;
      sleep(20);
      goto redo;
      end;
   //successful
   x^.free;
   x^:=nil;
   except;end;
   end;
{}//yyyyyyyyyyyyyyy
begin//Note: as a function this proc supports inline processing -> e.g. if a and b and freeobj() and d then -> which uses LESS code
result:=true;

try
//check
if (x=nil) or (x^=nil)  then exit;
//hide
//try;if (x^ is tcommonform)    then (x^ as tcommonform).visible:=false;except;end;
//counters
//if      (x^ is tstringlist)   then track__inc(satStringlist,-1)
//else if (x^ is tbitmap)       then track__inc(satBitmap,-1)
//else if (x^ is tfilestream)   then track__inc(satFilestream,-1)

//.dummy logic to "start" the if statement
if (true=false) then
   begin

   end
{$ifdef jpeg} else if (x^ is tjpegimage)    then track__inc(satJpegimage,-1) {$endif}//01may2021


//hide
else
   begin
   //nil
   end;

//-- shutdown handlers ---------------------------------------------------------
//tthread based
//was: if (x^ is tbasictimer)  then xbasictimer
//was: if (x^ is tbasicthreadstop) then xbasicthreadstop//21may2021
//general purpose shutdown handler
//else
   begin
   //mustnil - Special case when the pointer refers to the "_rtmp" var on the object itself. This is used by "str__ptr()" to
   //          cache the pointer of a floating tstr8/tstr9 object, from a call like "low__tofile64('myfile.dat',str__ptr(vars8.data),e)".
   //          A call to "vars8.data" returns a tstr8 object with data, which must be destroyed by the proc it's passed to, in this case low__tofile64.
   //          It is not safe to pass this directly, so tstr__ptr() stores it in "_rtmp" on the object in question - 09feb2024
   xmustnil:=true;
   if (x^ is tobjectex) and (x=@(x^ as tobjectex).__cacheptr) then xmustnil:=false;

   //free the object
   x^.free;

   //safe to set the owner var to nil
   if xmustnil then x^:=nil;
   end;
except;end;
end;

function mult64(xval,xval2:comp):comp;//multiply
begin
result:=xval;
try;result:=result*xval2;except;end;
end;

function add64(xval,xval2:comp):comp;//add
begin
result:=xval;
try;result:=result+xval2;except;end;
end;

function sub64(xval,xval2:comp):comp;//subtract
begin
result:=xval;
try;result:=result-xval2;except;end;
end;

function div64(xval,xdivby:comp):comp;//28dec2021, this proc performs proper "comp division" -> fixes Delphi's "comp" division error -> which raises POINTER EXCEPTION and MEMORY ERRORS when used at speed and repeatedly - 13jul2021, 19apr2021
label
   vsmall,x1b,x100m,x10m,x1m,x100K,x10K,x1K,x100,x10,x1;
var
   xminus:boolean;
   vmax,v,xoutval:comp;
begin
//defaults
result:=0;

try
xoutval:=0;
//zero value - 13jul2021
if (xval=0) then
   begin
   result:=0;
   exit;
   end;
//.divide by zero - 28dec2021
if (xdivby=0) then
   begin
   result:=0;
   exit;
   end;
//init
xminus:=(xval<0);
if xminus then xval:=-xval;
vmax:=mult64(100000000,1000);
//decide
if (xdivby>=vmax) then goto vsmall;

//1b
v:=xdivby*1000000000;
x1b:
if (v<=xval) then
   begin
   xoutval:=xoutval+1000000000;
   xval:=xval-v;
   goto x1b;
   end;

//100m
v:=xdivby*100000000;
x100m:
if (v<=xval) then
   begin
   xoutval:=xoutval+100000000;
   xval:=xval-v;
   goto x100m;
   end;
//10m
v:=xdivby*10000000;
x10m:
if (v<=xval) then
   begin
   xoutval:=xoutval+10000000;
   xval:=xval-v;
   goto x10m;
   end;
//1m
v:=xdivby*1000000;
x1m:
if (v<=xval) then
   begin
   xoutval:=xoutval+1000000;
   xval:=xval-v;
   goto x1m;
   end;
//100K
v:=xdivby*100000;
x100K:
if (v<=xval) then
   begin
   xoutval:=xoutval+100000;
   xval:=xval-v;
   goto x100K;
   end;
//10K
v:=xdivby*10000;
x10K:
if (v<=xval) then
   begin
   xoutval:=xoutval+10000;
   xval:=xval-v;
   goto x10K;
   end;
//1K
v:=xdivby*1000;
x1K:
if (v<=xval) then
   begin
   xoutval:=xoutval+1000;
   xval:=xval-v;
   goto x1K;
   end;
//100
v:=xdivby*100;
x100:
if (v<=xval) then
   begin
   xoutval:=xoutval+100;
   xval:=xval-v;
   goto x100;
   end;
//10
vsmall:
v:=xdivby*10;
x10:
if (v<=xval) then
   begin
   xoutval:=xoutval+10;
   xval:=xval-v;
   goto x10;
   end;
//1
v:=xdivby;
x1:
if (v<=xval) then
   begin
   xoutval:=xoutval+1;
   xval:=xval-v;
   goto x1;
   end;

//set
if xminus then result:=-xoutval else result:=xoutval;
except;end;
end;

function insstr(x:string;y:boolean):string;
begin
result:='';try;if y then result:=x;except;end;
end;

function strcopy0(var x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<0) then xpos:=0;
result:=copy(x,xpos+stroffset,xlen);
except;end;
end;

function strcopy0b(x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<0) then xpos:=0;
result:=copy(x,xpos+stroffset,xlen);
except;end;
end;

function strcopy1(var x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<1) then xpos:=1;
result:=copy(x,xpos-1+stroffset,xlen);
except;end;
end;

function strcopy1b(x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<1) then xpos:=1;
result:=copy(x,xpos-1+stroffset,xlen);
except;end;
end;

function strlast(var x:string):string;//returns last char of string or nil if string is empty
begin
result:='';try;result:=strcopy1(x,length(x),1);except;end;
end;

function strlastb(x:string):string;//returns last char of string or nil if string is empty
begin
result:='';try;result:=strlast(x);except;end;
end;

function strdel0(var x:string;xpos,xlen:longint):boolean;//0based
begin
result:=true;

try
if (xlen<1) then exit;
if (xpos<0) then xpos:=0;
delete(x,xpos+stroffset,xlen);
except;end;
end;

function strdel1(var x:string;xpos,xlen:longint):boolean;//1based
begin
result:=true;

try
if (xlen<1) then exit;
if (xpos<1) then xpos:=1;
delete(x,xpos-1+stroffset,xlen);
except;end;
end;

function strbyte0(var x:string;xpos:longint):byte;//0based always -> backward compatible with D3 - 02may2020
var
   xlen:longint;
begin
result:=0;

try
if (xpos<0) then xpos:=0;
xlen:=length(x);
if (xlen>=1) and (xpos<xlen) then result:=byte(x[xpos+stroffset]);
except;end;
end;

function strbyte0b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
begin
result:=0;try;result:=strbyte0(x,xpos);except;end;
end;

function strbyte1(var x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
var
   xlen:longint;
begin
result:=0;

try
if (xpos<1) then xpos:=1;
xlen:=length(x);
if (xlen>=1) and (xpos<=xlen) then result:=byte(x[xpos-1+stroffset]);
except;end;
end;

function strbyte1b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
begin
result:=0;try;result:=strbyte1(x,xpos);except;end;
end;

procedure strdef(var x:string;xdef:string);//set new value, default to "xdef" if xnew is nil
begin
try;if (x='') then x:=xdef;except;end;
end;

function strdefb(x,xdef:string):string;
begin
result:='';try;result:=x;strdef(result,xdef);except;end;
end;

function low__setlen(var x:string;xlen:longint):boolean;
begin
result:=false;

try
if (xlen<=0) then x:='' else setlength(x,xlen);
result:=true;
except;end;
end;

function low__length(var x:string):longint;
begin
result:=0;try;result:=length(x);except;end;
end;

function low__lengthb(x:string):longint;
begin
result:=0;try;result:=low__length(x);except;end;
end;

function floattostrex2(x:extended):string;//19DEC2007
begin
result:='';try;result:=floattostrex(x,18);except;end;
end;

function floattostrex(x:extended;dig:byte):string;//07NOV20210
var//0=integer part only, 1-18=include partial content if present
   p:longint;
   a,b,c:string;
begin
//defaults
result:='0';

try
//get
a:=floattostrf(x,ffFixed,18,18);
b:='';
c:='';
if (a<>'') then
   begin
   for p:=0 to (length(a)-1) do if (a[p+stroffset]='.') then
   begin
   if (dig>=1) then b:=strcopy0(a,p+1,dig);
   a:=strcopy0(a,0,p);
   break;
   end;
   end;
//scan
if (b<>'') then
   begin
   for p:=(length(b)-1) downto 0 do if (b[p+stroffset]<>'0') then
   begin
   c:=strcopy0(b,0,p+1);//strip off excess zeros - 07NOV2010
   break;
   end;
   end;
//set
result:=a+insstr('.'+c,c<>'');
except;end;
end;

function strtofloatex(x:string):extended;//triggers less errors (x=nil now covered)
begin
result:=0;try;if (x<>'') then result:=strtofloat(x);except;end;
end;

function restrict64(x:comp):comp;//24jan2016
begin
result:=x;

try
if (result>max64) then result:=max64;
if (result<min64) then result:=min64;
except;end;
end;

function restrict32(x:comp):longint;//limit32 - 24jan2016
begin
result:=0;

try
if (x>max32) then x:=max32;
if (x<min32) then x:=min32;
result:=round(x);
except;end;
end;

function k64(x:comp):string;//converts 64bit number into a string with commas -> handles full 64bit whole number range of min64..max64 - 24jan2016
begin
result:='';try;result:=k642(x,true);except;end;
end;

function k642(x:comp;xsep:boolean):string;//handles full 64bit whole number range of min64..max64 - 24jan2016
const
   sep=',';
var
   i,xlen,p:longint;
   z2,z,y:string;
begin
//defaults
result:='0';

try
//range
x:=restrict64(x);
//get
z2:='';
if (x<0) then
   begin
   x:=-x;
   z2:='-';
   end;
y:=floattostrex2(x);
z:='';
xlen:=length(y);
i:=0;
if (xlen>=1) then
   begin
   for p:=(xlen-1) downto 0 do
   begin
   inc(i);
   if (i>=3) and (p>0) then
      begin
      case xsep of//10mar2021
      true:z:=sep+strcopy0(y,p,3)+z;
      false:z:=strcopy0(y,p,3)+z;
      end;
      i:=0;
      end;
   end;//p
   end;
if (i<>0) then z:=strcopy0(y,0,i)+z;
//set
result:=z2+z;
except;end;
end;

function makestr(var x:string;xlen:longint;xfillchar:byte):boolean;
var
   p:longint;
   c:char;
begin
//defaults
result:=false;

try
//get
x:='';
if low__setlen(x,xlen) then
   begin
   c:=char(xfillchar);
   for p:=1 to low__length(x) do x[p-1+stroffset]:=c;
   //successful
   result:=true;
   end;
except;end;
try;if not result then x:='';except;end;
end;

function makestrb(xlen:longint;xfillchar:byte):string;
begin
result:='';try;makestr(result,xlen,xfillchar);except;end;
end;

//system procs -----------------------------------------------------------------
//## pok ##
function pok(x:pobject):boolean;//06feb2024
begin
result:=(x<>nil) and (x^<>nil);
end;
//## zzok ##
function zzok(x:tobject;xid:longint):boolean;
begin
result:=(x<>nil);
end;
//## zznil ##
function zznil(x:tobject;xid:longint):boolean;
begin
result:=(x=nil);
end;
//## zznil2 ##
function zznil2(x:tobject):boolean;//12feb202
begin
result:=(x=nil);
end;
//## ppok ##
function ppok(x:pointer;xid:longint):boolean;
begin
result:=(x<>nil);
end;
//## zzvars ##
function zzvars(x:tvars8;xid:longint):tvars8;
begin
result:=x;
end;

//screen procs -----------------------------------------------------------------
//## scn__changed ##
function scn__changed(xset:boolean):boolean;
var
   ww,wh:longint;
   str1:string;
begin
//defaults
result:=false;

try
//init
scn__windowsize(ww,wh);
system_scn_width :=frcrange32(ww,1, low__length(system_scn_lines[0]) );
system_scn_height:=frcrange32(wh,1, high(system_scn_lines)+1 );
//special width/height override -> allows the internal paint handler to continue to function even whem run as a service - 07mar2024
if (system_scn_width<=1)  then system_scn_width:=100;
if (system_scn_height<=1) then system_scn_height:=26;
//get
str1:=bnc(system_scn_visible)+'|'+inttostr(ww)+'|'+inttostr(wh)+'|'+inttostr(system_scn_width)+'|'+inttostr(system_scn_height);
result:=(system_scn_ref<>str1);
if result and xset then system_scn_ref:=str1;
except;end;
end;
//## scn__visible ##
function scn__visible:boolean;
begin
result:=system_scn_visible;
end;
//## scn__setvisible ##
procedure scn__setvisible(x:boolean);
begin
try;if low__setbol(system_scn_visible,x) then scn__paint;except;end;
end;
//## scn__width ##
function scn__width:longint;
begin
result:=system_scn_width;
end;
//## scn__height ##
function scn__height:longint;
begin
result:=system_scn_height;
end;
//## scn__canpaint ##
function scn__canpaint:boolean;
begin
result:=system_scn_visible;
end;
//## scn__mustpaint ##
function scn__mustpaint:boolean;
begin
result:=system_scn_mustpaint;
end;
//## scn__paint ##
procedure scn__paint;
begin
try;if scn__canpaint then system_scn_mustpaint:=true;except;end;
end;
//## rl ##
function rl(var x:string):boolean;
begin
result:=false;try;result:=app__readln(x);except;end;
end;
//## wl ##
function wl(x:string):boolean;//write line - short version
begin
result:=false;try;result:=scn__writeln(x);except;end;
end;
//## scn__writeln ##
function scn__writeln(x:string):boolean;//write line
begin
result:=false;try;result:=app__writeln(x);except;end;
end;
//## scn__windowwidth ##
function scn__windowwidth:longint;
var
   int1:longint;
begin
result:=0;try;scn__windowsize(result,int1);except;end;
end;
//## scn__windowheight ##
function scn__windowheight:longint;
var
   int1:longint;
begin
result:=0;try;scn__windowsize(int1,result);except;end;
end;
//## scn__windowsize ##
function scn__windowsize(var xwidth,xheight:longint):boolean;//size of Windows console w x h - 21dec2023
begin
result:=false;try;result:=low__console('windowsize',xwidth,xheight);except;end;
end;
//## scn__windowcls ##
procedure scn__windowcls;
begin
try;low__consoleb('cls',0,0);except;end;
end;
//## scn__cls ##
procedure scn__cls;
var
   dx,dy,dw,dh:longint;
begin
try
//init
dw:=scn__width;
dh:=scn__height;
//get
for dy:=0 to (dh-1) do
begin
for dx:=0 to (dw-1) do system_scn_lines[dy][dx+stroffset]:=#32;
end;//dy
except;end;
end;
//## scn__moveto ##
procedure scn__moveto(x,y:longint);
begin
try
system_scn_x:=frcrange32(x,0,scn__width-1);
system_scn_y:=frcrange32(y,0,scn__height-1);
except;end;
end;
//## scn__down ##
procedure scn__down;
begin
scn__moveto(system_scn_x,system_scn_y+1);
end;
//## scn__up ##
procedure scn__up;
begin
scn__moveto(system_scn_x,system_scn_y-1);
end;
//## scn__left ##
procedure scn__left;
begin
scn__moveto(system_scn_x-1,system_scn_y);
end;
//## scn__right ##
procedure scn__right;
begin
scn__moveto(system_scn_x+1,system_scn_y);
end;
//## scn__setx ##
procedure scn__setx(xval:longint);
begin
scn__moveto(xval,system_scn_y);
end;
//## scn__sety ##
procedure scn__sety(xval:longint);
begin
scn__moveto(system_scn_x,xval);
end;
//## scn__text ##
procedure scn__text(x:string);
begin
scn__proc('text',x,0,max32);
end;
//## scn__text2 ##
procedure scn__text2(x1,x2:longint;x:string);
begin
scn__proc('text',x,x1,x2);
end;
//## scn__clearline ##
procedure scn__clearline;
begin
scn__proc('clearline','',0,max32);
end;
//## scn__hline ##
procedure scn__hline(x:string);
begin
scn__proc('hline',x,0,max32);
end;
//## scn__vline ##
procedure scn__vline(x:string);
begin
scn__proc('vline',x,0,max32);
end;
//## scn__proc ##
procedure scn__proc(xstyle,xtext:string;xfrom,xto:longint);
var
   sw,sh,sx,sy,dx,dy:longint;
   dc:char;
   //## xclipok ##
   function xclipok(x:longint):boolean;
   begin
   result:=(x>=xfrom) and (x<=xto);
   end;
begin
try
//check
if (xto<xfrom) then exit;
//range
xstyle:=strlow(xstyle);
sw:=scn__width;
sh:=scn__height;
sx:=frcrange32(system_scn_x,0,sw-1);
sy:=frcrange32(system_scn_y,0,sh-1);
//get
if (xstyle='clearline') then
   begin
   for dx:=0 to (sw-1) do if xclipok(dx) then system_scn_lines[sy][dx+stroffset]:=#32;
   end
else if (xstyle='text') then
   begin
   for dx:=sx to frcmax32(sx+(low__length(xtext)-1),sw-1) do if xclipok(dx) then system_scn_lines[sy][dx+stroffset]:=xtext[dx-sx+stroffset];
   end
else if (xstyle='hline') then
   begin
   dc:=char(strbyte1b(xtext+'-',1));//at least one char
   for dx:=0 to (sw-1) do if xclipok(dx) then system_scn_lines[sy][dx+stroffset]:=dc;
   end
else if (xstyle='vline') then
   begin
   dc:=char(strbyte1b(xtext+'-',1));//at least one char
   for dy:=0 to (sh-1) do if xclipok(dy) then system_scn_lines[dy][sx+stroffset]:=dc;
   end;
except;end;
end;
//## scn__settitle ##
procedure scn__settitle(x:string);
begin
try;win____setconsoletitle(pchar(strdefb(x,app__info('name'))));except;end;
end;
//## scn__gettext ##
function scn__gettext(xwidth,xheight:longint):string;
var
   b:tstr8;
   dy:longint;
begin
//defaults
result:='';

try
b:=nil;

//check
if (xwidth<=0) or (xheight<=0) then exit;

//range
xwidth:=frcrange32(xwidth,1,low__length(system_scn_lines[0]));
xheight:=frcrange32(xheight,1,high(system_scn_lines)+1);

//init
b:=str__new8;

//get
for dy:=0 to (xheight-1) do b.saddb(strcopy1(system_scn_lines[dy],1,xwidth)+#10);

//set
result:=b.text;
except;end;
try;str__free(@b);except;end;
end;


//app procs --------------------------------------------------------------------
//## mem__alloc ##
function mem__alloc(xsize:longint):pointer;
begin
result:=win____HeapAlloc(win____GetProcessHeap,0,xsize);
end;
//## mem__realloc ##
function mem__realloc(xptr:pointer;xsize:longint):pointer;
begin
result:=win____HeapReAlloc(win____GetProcessHeap,0,xptr,xsize);
end;
//## mem__free ##
function mem__free(xptr:pointer):boolean;
begin
result:=win____HeapFree(win____GetProcessHeap,0,xptr);
end;
//## app__adminlevel ##
function app__adminlevel:boolean;
begin
result:=root__adminlevel;
end;
//## app__folder ##
function app__folder:string;
begin
result:='';try;result:=app__folder2('',true);except;end;
end;
//## app__folder2 ##
function app__folder2(xsubfolder:string;xcreate:boolean):string;
begin
result:='';try;result:=app__folder3(xsubfolder,xcreate,false);except;end;
end;
//## app__folder3 ##
function app__folder3(xsubfolder:string;xcreate,xalongsideexe:boolean):string;//15jan2024
begin
//defaults
result:='';

try
//xalongsideexe=false="exe path\", true="exe path\<exe name>_storage\"
result:=io__asfolder(io__extractfilepath(io__exename));
if not xalongsideexe then result:=io__asfolder(result+io__extractfilename(io__exename)+'_storage');
//subfolder
if (xsubfolder<>'') then result:=io__asfolder(result+xsubfolder);
//create
if xcreate then io__makefolder(result);
except;end;
end;
//## app__folder ##
function app__subfolder(xsubfolder:string):string;
begin
result:='';try;result:=app__subfolder2(xsubfolder,false);except;end;
end;
//## app__subfolder2 ##
function app__subfolder2(xsubfolder:string;xalongsideexe:boolean):string;
begin
result:='';try;result:=app__folder3(xsubfolder,true,xalongsideexe);except;end;
end;
//## app__settingsfile ##
function app__settingsfile(xname:string):string;
begin
result:='';try;result:=app__subfolder('settings')+io__extractfilename(xname);except;end;
end;
//## app__breg ##
procedure app__breg(xname:string;xdefval:boolean);//register boolean for settings
begin
try
if (system_settings_ref<>nil) then
   begin
   system_settings_filt:=false;
   system_settings_ref.b['nam.'+xname]:=true;//main name
   system_settings_ref.i['cla.'+xname]:=0;
   system_settings_ref.b['def.'+xname]:=xdefval;
   end;
except;end;
end;
//## app__ireg ##
procedure app__ireg(xname:string;xdefval,xmin,xmax:longint);//register integer for settings
begin
try
if (system_settings_ref<>nil) then
   begin
   system_settings_filt:=false;
   system_settings_ref.b['nam.'+xname]:=true;//main name
   system_settings_ref.i['cla.'+xname]:=1;
   system_settings_ref.i['def.'+xname]:=frcrange32(xdefval,xmin,xmax);
   system_settings_ref.i['min.'+xname]:=xmin;
   system_settings_ref.i['max.'+xname]:=xmax;
   end;
except;end;
end;
//## app__creg ##
procedure app__creg(xname:string;xdefval,xmin,xmax:comp);//register comp for settings
begin
try
if (system_settings_ref<>nil) then
   begin
   system_settings_filt:=false;
   system_settings_ref.b['nam.'+xname]:=true;//main name
   system_settings_ref.i['cla.'+xname]:=3;
   system_settings_ref.i64['def.'+xname]:=frcrange64(xdefval,xmin,xmax);
   system_settings_ref.i64['min.'+xname]:=xmin;
   system_settings_ref.i64['max.'+xname]:=xmax;
   end;
except;end;
end;
//## app__sreg ##
procedure app__sreg(xname:string;xdefval:string);//register string for settings
begin
try
if (system_settings_ref<>nil) then
   begin
   system_settings_filt:=false;
   system_settings_ref.b['nam.'+xname]:=true;//main name
   system_settings_ref.i['cla.'+xname]:=2;
   system_settings_ref.s['def.'+xname]:=xdefval;
   end;
except;end;
end;
//## app__savesettings ##
function app__savesettings:boolean;
var
   e:string;
begin
//defaults
result:=false;

try
//check
if (system_settings=nil) or (not system_settings_load) then exit;//settings haven't been loaded yet - thus not safe to save
//filter
app__filtersettings;
//get
result:=io__tofile(app__subfolder('settings')+'settings.ini',cache__ptr(system_settings.data),e);//09feb2024
except;end;
end;
//## app__loadsettings ##
function app__loadsettings:boolean;
var
   b:tstr8;
   e:string;
begin
//defaults
result:=false;

try
b:=nil;
//get
if (system_settings<>nil) then
   begin
   b:=str__new8;
   io__fromfile(app__subfolder('settings')+'settings.ini',@b,e);
   system_settings.data:=b;
   system_settings_load:=true;
   //successful
   result:=true;
   end;
except;end;
try;str__free(@b);except;end;
end;
//## app__filtersettings ##
procedure app__filtersettings;
label
   redo;
var
   a:tvars8;
   c,xpos:longint;
   str1,n:string;
begin
try
//defaults
a:=nil;
//check
if (system_settings=nil) or (system_settings_ref=nil) then exit;
if system_settings_filt then exit else system_settings_filt:=true;
//init
a:=tvars8.create;
//get
xpos:=0;
redo:
if system_settings_ref.xnextname(xpos,str1) then
   begin
   if strmatch(strcopy1(str1,1,4),'nam.') then
      begin
      //init
      n:=strcopy1(str1,5,low__length(str1));
      //get
      if (n<>'') then
         begin
         c:=system_settings_ref.i['cla.'+n];//class - 0=boolean, 1=integer, 2=string
         case c of
         0:if system_settings.found(n) then a.b[n]:=system_settings.b[n]                                                                                     else a.b[n]:=system_settings_ref.b['def.'+n];//boolean
         1:if system_settings.found(n) then a.i[n]:=frcrange32(system_settings.i[n],system_settings_ref.i['min.'+n],system_settings_ref.i['max.'+n])           else a.i[n]:=frcrange32(system_settings_ref.i['def.'+n],system_settings_ref.i['min.'+n],system_settings_ref.i['max.'+n]);//integer
         2:if system_settings.found(n) then a.s[n]:=strdefb(system_settings.s[n],system_settings_ref.s['def.'+n]);
         3:if system_settings.found(n) then a.i64[n]:=frcrange64(system_settings.i64[n],system_settings_ref.i64['min.'+n],system_settings_ref.i64['max.'+n]) else a.i64[n]:=frcrange64(system_settings_ref.i64['def.'+n],system_settings_ref.i64['min.'+n],system_settings_ref.i64['max.'+n]);//comp
         end;//case
         end;
      end;
   goto redo;
   end;
//set
system_settings.data:=a.data;
except;end;
try;freeobj(@a);except;end;
end;
//## app__bval ##
function app__bval(xname:string):boolean;//self-filtering
begin
//defaults
result:=false;

try
//get
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   //filter
   app__filtersettings;
   //get
   result:=system_settings.b[xname];
   end;
except;end;
end;
//## app__ival ##
function app__ival(xname:string):longint;//self-filtering
begin
//defaults
result:=0;

try
//get
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   //filter
   app__filtersettings;
   //get
   result:=system_settings.i[xname];
   end;
except;end;
end;
//## app__cval ##
function app__cval(xname:string):comp;//self-filtering
begin
//defaults
result:=0;

try
//get
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   //filter
   app__filtersettings;
   //get
   result:=system_settings.i64[xname];
   end;
except;end;
end;
//## app__sval ##
function app__sval(xname:string):string;//self-filtering
begin
//range
result:='';

try
//get
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   //filter
   app__filtersettings;
   //get
   result:=system_settings.s[xname];
   end;
except;end;
end;
//## app__bvalset ##
function app__bvalset(xname:string;xval:boolean):boolean;
begin
result:=false;

try
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   app__filtersettings;
   result:=xval;
   system_settings.b[xname]:=result;
   end;
except;end;
end;
//## app__ivalset ##
function app__ivalset(xname:string;xval:longint):longint;
begin
result:=0;

try
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   app__filtersettings;
   result:=frcrange32(xval,system_settings_ref.i['min.'+xname],system_settings_ref.i['max.'+xname]);
   system_settings.i[xname]:=result;
   end;
except;end;
end;
//## app__cvalset ##
function app__cvalset(xname:string;xval:comp):comp;
begin
result:=0;

try
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   app__filtersettings;
   result:=frcrange64(xval,system_settings_ref.i64['min.'+xname],system_settings_ref.i64['max.'+xname]);
   system_settings.i64[xname]:=result;
   end;
except;end;
end;
//## app__svalset ##
function app__svalset(xname,xval:string):string;
begin
result:='';

try
if (system_settings<>nil) and (system_settings_ref<>nil) and system_settings_ref.found('nam.'+xname) then
   begin
   app__filtersettings;
   result:=xval;
   system_settings.s[xname]:=result;
   end;
except;end;
end;
//## app__eventproc ##
function app__eventproc(ctrltype:dword):bool; stdcall;//detects shutdown requests from Windows
label//WARNING: This event is run by Windows in a separate thread -> thus be careful to be thread safe
   redo;
var
   xcount:longint;
begin
//handled
result:=true;

try

//signal the system to shutdown
system_musthalt:=true;

//wait 20secs for app to shut
xcount:=20;
redo:
if (system_state<ssFinished) then
   begin
   app__waitms(1000);
   dec(xcount);
   if (xcount>=1) then goto redo;
   end;

//not used: if (CtrlType = CTRL_CLOSE_EVENT) then
except;end;
end;
//## app__running ##
function app__running:boolean;
begin
result:=(system_state=ssRunning);
end;
//## app__paintnow ##
procedure app__paintnow;//flicker free paint
var
   sw,sh,p:longint;
begin
try
//check
if (not system_scn_visible) and (system_scn_ref1=system_scn_visible) then exit;
//init
system_scn_ref1:=system_scn_visible;
scn__changed(false);
sw:=scn__width;
sh:=scn__height;
//call the paint proc
app__onpaint(sw,sh);
//cls entire screen due to a height change
if scn__changed(true) then scn__windowcls;
//position cursor at top-left corner
low__consoleb('setcursorpos',0,0);
//write lines back on screen
if system_scn_visible then
   begin
   for p:=0 to (sh-1) do app__writeln(strcopy1b(system_scn_lines[p],1,sw));
   end;
except;end;
end;

//## app__paused ##
function app__paused:boolean;
begin
result:=system_pause;
end;
//## app__pause ##
procedure app__pause(x:boolean);
begin
system_pause:=x;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//111111111111111111111111
//## app__runstyle ##
function app__runstyle:longint;//04mar2024
begin
result:=system_runstyle;
end;
//## app__install_uninstall ##
procedure app__install_uninstall;
var
   p,e:longint;
   v:string;
begin
try
for p:=1 to maxint do
begin
v:=strlow(low__param(p));
if (v='') then break
else if (v='/install') then
   begin
   case service__install(e) of
   true:app__writeln('Installed "'+app__info('service.name')+'" to service list');
   false:app__writeln('Service installation failed ('+k64(e)+')');
   end;//case
   end
else if (v='/uninstall') then
   begin
   case service__uninstall(e) of
   true:app__writeln('Uninstalled "'+app__info('service.name')+'" from service list');
   false:app__writeln('Service uninstallation failed ('+k64(e)+')');
   end;//case
   end;
end;//p
except;end;
end;
//## app__boot ##
procedure app__boot(xEventDriven,xFileCache:boolean);
begin
try
//check
if (system_runstyle>rsBooting) then exit else system_runstyle:=rsUnknown;

//init
system_eventdriven:=xeventdriven;
system_filecache_limit:=frcmax32(low__aorb(20,high(system_filecache_slot)+1,xFileCache),high(system_filecache_slot)+1);//29apr2024

//start
//.attempt to run program in service mode
service__start1;

//.service has finished DO NOT proceed -> quit instead
if (system_runstyle=rsService) then
   begin
   //all code execution has taken place and the app is now closing
   end
else
   begin
   system_runstyle:=rsConsole;
   app__run;//run the app as a console app
   end;

except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//0000000000000000000000000000
//## app__run ##
procedure app__run;//run;
label
   redo,loop,shutdown;
var
   p:longint;
   painttimer,timer500,timer30:comp;
   xlastturbo,xmustshutdown,xlastvisible:boolean;

   //## xmn32 ##
   procedure xmn32;
   begin
   system_min32_val:=frcmin32(restrict32(div64(ms64,60000)),0);
   end;
   //## xboolcheck ##
   function xboolcheck:boolean;//triggered when "Complete boolean eval=ticked" - 01jul2021
   begin
   result:=true;try;showerror2('Logic failure - boolean parameters are being read past the first left-most TRUE value. Turn off "Complete boolean eval" processing in the compiler options.',10);xmustshutdown:=true;except;end;
   end;
   //## xparamcheck ##
   procedure xparamcheck; pascal;
   var
      xerr,xfirst:boolean;
      v:longint;
      //## a ##
      function a:longint;
      begin
      result:=-10;
      if xfirst then xerr:=false;
      end;
      //## b ##
      function b:longint;
      begin
      result:=10;
      xfirst:=false;
      end;
      //## xtest ##
      function xtest(v1,v2:longint):longint; pascal;
      begin
      result:=v1*v2;
      end;
   begin
   try
   //defaults
   xfirst:=true;
   xerr:=true;
   //get
   v:=xtest(a,b);
   //check
   if xerr then
      begin
      xmustshutdown:=true;
      showerror2('Logic failure - proc parameters are being read from right-to-left.  Parameters must be passed left-to-right. Ref('+inttostr(v)+')',10);
      end;
   except;end;
   end;
begin
try
//check
if (system_state=ssMustStart) then system_state:=ssStarting else exit;

//defaults
xmustshutdown:=false;
low__handlenone(system_stdin);
xlastturbo:=false;



//--< starting >--

//ref arrays -------------------------------------------------------------------
try
//.int32
for p:=0 to high(p4INT32) do p4INT32[p]:=p*p*p*p;
//.cmp256
for p:=0 to high(p8CMP256) do p8CMP256[p]:=mult64(p*p,p*p);
except;end;


//unit start procs -------------------------------------------------------------
gossroot__start;
gossimg__start;
gossio__start;
gossnet__start;


//screen support
for p:=0 to high(system_scn_lines) do makestr(system_scn_lines[p] ,300,32);//18 Kb


//init
randomize;
xmn32;
system_boot:=ms64;
system_boot_date:=now;
timer30:=0;
timer500:=0;
painttimer:=0;
xlastvisible:=scn__visible;

//.std in/out
system_stdin:=low__stdin;

//load settings
system_settings    :=tvars8.create;
system_settings_ref:=tvars8.create;
app__loadsettings;

//start the program
system_state:=ssRunning;

//window title name
scn__settitle(app__info('name'));

//-- System Logic Checks -------------------------------------------------------
//check compiler is NOT set to evaluate all boolean expressions -> e.g. read past the first TRUE value
if true or xboolcheck then
   begin
   //nil
   end;

//check compiler is NOT set to pass values to procs in right-to-left fashion
xparamcheck;

//one or more logic checks failed -> must shutdown as program cannot function under these logic conditions - 09feb2024
if xmustshutdown then goto shutdown;

//system blocksize min size check
if (system_blocksize<4096) then
   begin
   showerror2('System memory block size set to '+k64(system_blocksize)+'.  Should be atleast 4096.',10);
   goto shutdown;
   end;


//-- Start The Program ---------------------------------------------------------
//proc to create the program with
app__create;

//.handles shutdown messages from Windows -> connect the proc AFTER the app has been created - 23dec2023
win____setconsolectrlhandler(@app__eventproc,true);

//--< running >--

//.first timer
system_firsttimer:=true;
app__timers;
system_firsttimer:=false;

//.start system timer -> basic timer using the Windows event queue
if system_eventdriven then win____settimer(app__wproc.window,1,system_timerinterval,nil);


//.main program loop
redo:

//.pause
if system_pause then
   begin
   app__waitms(1000);
   goto loop;
   end;

//.paint screen
if ((system_scn_visible<>system_scn_ref1) or system_scn_mustpaint) and msok(painttimer) then
   begin
   //get
   system_scn_mustpaint:=false;
   app__paintnow;
   if low__setbol(xlastvisible,system_scn_visible) and (not system_scn_visible) then app__onpaintOFF;
   //reset
   msset(painttimer,100);
   end;

//.500ms
if msok(timer500) then
   begin
   system_turbo:=mswaiting(system_turboref);
   //screen changed
   if scn__changed(false) then scn__paint;
   //fileache - 12apr2024
   filecache__managementevent;
   //reset
   msset(timer500,500);
   end;

//.30sec
if msok(timer30) then
   begin

   //minute counter
   xmn32;

   //log writer
   log__writemaybe;

   //reset
   msset(timer30,30000);
   end;

//.messages
case system_eventdriven of
false:app__processmessages;//time sliced
true:if (not app__processmessages) and (system_state=ssRunning) and (not system_musthalt) then win____waitmessage;//don't switch to wait mode if we're not running, e.g. shuting down etc - 28apr2024
end;

//.timers
app__timers;

//.run normally when not in turbo mode - WARNING: turbo mode uses full CPU power when NOT event_driven -> no real way to slow it down at this stage
if (not system_turbo) and (not system_eventdriven) then app__waitms(system_timerinterval);

//.increase processing priority during turbo mode
if (system_turbo<>xlastturbo) then
   begin
   xlastturbo:=system_turbo;
   if system_turbo then root__settimeperiod(1) else root__stoptimeperiod;
   if (xlastturbo<>root__priority) then root__setpriority(xlastturbo);
   end;

//.loop -> "system_musthalt" is for "app__eventproc()" to trigger a halt without using "app__halt/system_state"
loop:
if (system_state=ssRunning) and (not system_musthalt) then goto redo;


//--< stopping >--
system_state:=ssStopping;

//.stop system timer
if system_eventdriven and (system_wproc<>nil) then win____killtimer(app__wproc.window,1);

//.last timer
system_lasttimer:=true;
app__timers;
system_lasttimer:=false;

//.destroy program related objects
app__destroy;

//.stdin
low__handlenone(system_stdin);

//.stopped
system_state:=ssStopped;

//.shutdown
shutdown:
system_state:=ssShutdown;

//windows message proc
if (system_wproc<>nil) then freeobj(@system_wproc);

//network
gossnet__stop;


//save settings
app__savesettings;
freeobj(@system_settings);
freeobj(@system_settings_ref);

//finish logs (if active) and close vars
log__writenow;
str__free(@system_log_cache);

//clear the console screen
//scn__windowcls;


//disable any custom timing resolution - 14mar2024
root__stoptimeperiod;

//unit stop procs
gossimg__stop;
gossio__stop;
gossroot__stop;

//finished
system_state:=ssFinished;
except;end;
end;
//## app__* procs ##############################################################
//## app__halt ##
procedure app__halt;
begin
try;if (system_state=ssRunning) then system_state:=ssStopping;except;end;
end;
//## app__processmessages ##
function app__processmessages:boolean;
label
   redo;
var
   xhandled:boolean;
   msg:tmsg;
   v64:comp;
begin
//defaults
result:=false;
v64:=ms64;;

//get
redo:
if win____peekmessage(msg,0,0,0,PM_REMOVE) then
   begin
   result:=true;//13mar2022
   if (msg.message=WM_QUIT) then app__halt
   else
      begin
      xhandled:=false;
      //if assigned(application.onmessage) then application.onmessage(msg,xhandled);
      if not xhandled then
         begin
         win____translatemessage(msg);
         win____dispatchmessage(msg);
         end;
      //loop - process multiple message for upto just less than 2ms - 30sep2021
      if ((ms64-v64)<=5) then goto redo;
      end;
   end;
end;
//## app__processallmessages ##
function app__processallmessages:boolean;
label
   redo;
var
   xhandled:boolean;
   msg:tmsg;
begin
//defaults
result:=false;

//get
redo:
if win____peekmessage(msg,0,0,0,PM_REMOVE) then
   begin
   result:=true;
   if (msg.message=WM_QUIT) then app__halt
   else
      begin
      xhandled:=false;
      //if assigned(application.onmessage) then application.onmessage(msg,xhandled);
      if not xhandled then
         begin
         win____translatemessage(msg);
         win____dispatchmessage(msg);
         end;
      //loop - process multiple message for upto just less than 2ms - 30sep2021
      goto redo;
      end;
   end;
end;
//## app__wproc ##
function app__wproc:twproc;//auto makes the windows message handler
begin
result:=system_wproc;

try
if (result=nil) then
   begin
   system_wproc:=twproc.create;
   result:=system_wproc;
   end;
except;end;
end;
//## app__write ##
function app__write(x:string):boolean;//write
begin
result:=true;try;if app__running then write(x);except;end;
end;
//## app__writeln ##
function app__writeln(x:string):boolean;//write line
begin
result:=true;try;if (system_runstyle>rsBooting) then writeln(x);except;end;
end;
//## app__writeln2 ##
function app__writeln2(x:string;xsec:longint):boolean;//write line
begin
result:=false;try;result:=app__writeln(x);app__waitsec(xsec);except;end;
end;
//## app__writenil ##
function app__writenil:boolean;//write blank line
begin
result:=false;try;result:=app__writeln('');except;end;
end;
//## app__readln ##
function app__readln(var x:string):boolean;//read line
begin
result:=true;

try
x:='';
if app__running then readln(x);
except;end;
end;
//## app__read ##
function app__read(var x:char):boolean;//read char - does not wait
begin
result:=true;

try
x:=#0;
if app__running then read(x);
except;end;
end;
//## app__key ##
function app__key:char;//non-stopping character reader
begin
result:=#0; try;if app__running then result:=low__consolekey(system_stdin);except;end;
end;
//## app__line ##
function app__line(var x:string):boolean;//non-stopping line reader
begin
result:=false;try;result:=app__line2(x,true);except;end;
end;
//## app__line2 ##
function app__line2(var x:string;xecho:boolean):boolean;//non-stopping line reader
var
   a:char;
   v:byte;
begin
//defaults
result:=false;

try
//get
a:=app__key;
v:=byte(a);
case v of
0:;
8:begin//del left
   if (system_line_str<>'') then
      begin
      //shift cursor left 1 place -> cannot delete to beginning when wrapped to next line
      if xecho then app__write(#8#32#8);//shift left -> flush char with a space -> shift left
      //remove trailing char from buffer
      strdel1(system_line_str,low__length(system_line_str),1);
      end;
   end;
13:begin
   result:=true;
   x:=system_line_str;
   app__write(#13);
   //reset
   system_line_str:='';
   end;
else
   begin
   system_line_str:=system_line_str+a;
   if xecho then app__write(a);
   end;
end;//case

except;end;
end;
//## app__firsttimer ##
function app__firsttimer:boolean;
begin
result:=system_firsttimer;
end;
//## app__lasttimer ##
function app__lasttimer:boolean;
begin
result:=system_lasttimer;
end;
//## app__timers ##
procedure app__timers;
begin
app__ontimer;
if assigned(system_timer1) then system_timer1(nil);
if assigned(system_timer2) then system_timer2(nil);
if assigned(system_timer3) then system_timer3(nil);
if assigned(system_timer4) then system_timer4(nil);
if assigned(system_timer5) then system_timer5(nil);
end;
//## app__turbo ##
procedure app__turbo;
begin
system_turbo:=true;
msset(system_turboref,5000);
end;
//## app__shortturbo ##
procedure app__shortturbo(xms:comp);//doesn't shorten any existing turbo, but sets a small delay when none exist, or a short one already exists - 05jan2024
begin
xms:=add64(ms64,xms);
if (xms>system_turboref) then
   begin
   system_turbo:=true;
   system_turboref:=xms;
   end;
end;
//## app__turbook ##
function app__turbook:boolean;
begin
result:=false;try;result:=system_turbo or mswaiting(system_turboref);except;end;
end;
//## app__waitms ##
procedure app__waitms(xms:longint);
begin
try;if (xms>=1) and app__running then win____sleep(xms);except;end;
end;
//## app__waitsec ##
procedure app__waitsec(xsec:longint);
begin
try;if (xsec>=1) then app__waitms(xsec*1000);except;end;
end;
//## app__uptime ##
function app__uptime:comp;
begin
result:=0;try;result:=sub64(ms64,system_boot);except;end;
end;
//## app__uptimegreater ##
function app__uptimegreater(x:comp):boolean;
begin//true when "app__uptime>= x"
result:=false; try;result:=(app__uptime>=x);except;end;
end;
//## app__uptimestr ##
function app__uptimestr:string;
begin
result:='';try;result:=low__uptime(app__uptime,false,false,true,true,true,#32);except;end;
end;

//need checkers ----------------------------------------------------------------
//## need_filecache ##
procedure need_filecache;
begin
try;if not filecache__enabled then showerror('Filecache support required');except;end;
end;
//## need_net ##
procedure need_net;
begin
try;if (system_net_limit<=10) then showerror('Net support required');except;end;
end;
//## need_ipsec ##
procedure need_ipsec;
begin
try;if (system_ipsec_limit<=10) then showerror('Ipsec support required');except;end;
end;
//## need_png ##
procedure need_png;
begin
{$ifdef d3laz}{$else}showerror('PNG support requires zip support.');{$endif}
end;
//## need_zip ##
procedure need_zip;
begin
{$ifdef d3laz}{$else}showerror('ZIP support required.');{$endif}
end;
//## need_jpeg ##
procedure need_jpeg;
begin
try;{$ifdef jpeg}{$else}showerror('JPEG support required');{$endif}except;end;
end;
//## need_gif ##
procedure need_gif;
begin
try;{$ifdef gif}{$else}showerror('GIF support required');{$endif}except;end;
end;
//## need_gif2 ##
procedure need_gif2;
var
   ok,ok2:boolean;
begin
try
ok:=false;
ok2:=false;
{$ifdef gif}
ok:=true;
{$endif}
{$ifdef gif2}
ok2:=true;
{$endif}
if (not ok) or (not ok2) then showerror('GIF2 requires both GIF and GIF2 support');
except;end;
end;

//numerical procs --------------------------------------------------------------
//## low__sum32 ##
function low__sum32(x:array of longint):longint;
var//Add N longint's (32bit) numbers together and limit to longint range min32..max32 - 08may2020
   v:comp;
   p:longint;
begin
result:=0;

try
//defaults
result:=x[low(x)];
//get
if (low(x)<>high(x)) then
   begin
   v:=0;
   for p:=low(x) to high(x) do
   begin
   v:=v+x[p];
   if (v<min32) then v:=min32;
   if (v>max32) then v:=max32;
   end;//p
   //set
   result:=round(v);
   end;
except;end;
end;
//## nilrect ##
function nilrect:trect;
begin
result:=low__rect(0,0,-1,-1);
end;
//## nilarea ##
function nilarea:trect;//25jul2021
begin
result:=low__rect(0,0,-1,-1);
end;
//## maxarea ##
function maxarea:trect;//02dec2023, 27jul2021
begin//allow for graphics sub-procs to have room with their maths -> don't push it too near to "max32-1" - 28jul2021
result:=low__rect(0,0,max32-100000,max32-100000);//allow 100k numeric void
end;
//## noarea ##
function noarea:trect;//sets area to maximum inverse values - 19nov2023
begin
result.right    :=min32;
result.left     :=max32;
result.top      :=max32;
result.bottom   :=min32;
end;
//## validrect ##
function validrect(x:trect):boolean;
begin
result:=(x.left<=x.right) and (x.top<=x.bottom);
end;
//## validarea ##
function validarea(x:trect):boolean;//26jul2021
begin
result:=(x.left<=x.right) and (x.top<=x.bottom);
end;
//## low__shiftarea ##
function low__shiftarea(xarea:trect;xshiftx,xshifty:longint):trect;//always shift
begin
result.left:=0;
try;result:=low__shiftarea2(xarea,xshiftx,xshifty,false);except;end;
end;
//## low__shiftarea2 ##
function low__shiftarea2(xarea:trect;xshiftx,xshifty:longint;xvalidcheck:boolean):trect;//xvalidcheck=true=shift only if valid area, false=shift always
begin
result:=xarea;

try
if (not xvalidcheck) or validarea(xarea) then
   begin
   inc(result.left,xshiftx);
   inc(result.right,xshiftx);
   inc(result.top,xshifty);
   inc(result.bottom,xshifty);
   end;
except;end;
end;
//## low__withinrect ##
function low__withinrect(x,y:longint;z:trect):boolean;
begin
result:=(z.left<=z.right) and (z.top<=z.bottom) and (x>=z.left) and (x<=z.right) and (y>=z.top) and (y<=z.bottom);
end;
//## low__withinrect2 ##
function low__withinrect2(xy:tpoint;z:trect):boolean;
begin
result:=(z.left<=z.right) and (z.top<=z.bottom) and (xy.x>=z.left) and (xy.x<=z.right) and (xy.y>=z.top) and (xy.y<=z.bottom);
end;
//## low__point ##
function low__point(x,y:longint):tpoint;//09apr2024
begin
result.x:=x;
result.y:=y;
end;
//## low__rect ##
function low__rect(xleft,xtop,xright,xbottom:longint):trect;
begin
result.left:=xleft;
result.top:=xtop;
result.right:=xright;
result.bottom:=xbottom;
end;
//## low__rectclip ##
function low__rectclip(clip_rect,s:trect):trect;//21nov2023
begin
//defaults
result:=s;

try
//check
if (s.left>clip_rect.right) or (s.right<clip_rect.left) or (s.top>clip_rect.bottom) or (s.bottom<clip_rect.top) or (s.right<s.left) or (s.bottom<s.top) or (clip_rect.right<clip_rect.left) or (clip_rect.bottom<clip_rect.top) then
   begin
   result:=nilrect;
   exit;
   end;
//range
result.left      :=frcrange32(result.left,clip_rect.left,clip_rect.right);
result.right     :=frcrange32(result.right,clip_rect.left,clip_rect.right);
result.top       :=frcrange32(result.top,clip_rect.top,clip_rect.bottom);
result.bottom    :=frcrange32(result.bottom,clip_rect.top,clip_rect.bottom);
//check
if (result.right<result.left) or (result.bottom<result.top) then result:=nilrect;
except;end;
end;
//## low__rectgrow ##
function low__rectgrow(x:trect;xby:longint):trect;//07apr2021
begin
result.left    :=x.left  -xby;
result.top     :=x.top   -xby;
result.right   :=x.right +xby;
result.bottom  :=x.bottom+xby;
end;
//## low__rectstr ##
function low__rectstr(x:trect):string;
begin
result:='';try;result:='rect('+inttostr(x.left)+','+inttostr(x.top)+','+inttostr(x.right)+','+inttostr(x.bottom)+') and '+inttostr(x.right-x.left+1)+'w x '+inttostr(x.bottom-x.top+1)+'h';except;end;
end;
//## low__orderint ##
procedure low__orderint(var x,y:longint);
begin
try;if (x>y) then low__swapint(x,y);except;end;
end;
//## low__setstr ##
function low__setstr(var xdata:string;xnewvalue:string):boolean;
begin
result:=false;

try
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end;
except;end;
end;
//## low__setcmp ##
function low__setcmp(var xdata:comp;xnewvalue:comp):boolean;//10mar2021
begin
result:=false;

try
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end;
except;end;
end;
//## low__setint ##
function low__setint(var xdata:longint;xnewvalue:longint):boolean;
begin
result:=false;

try
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end;
except;end;
end;
//## low__setbol ##
function low__setbol(var xdata:boolean;xnewvalue:boolean):boolean;
begin
result:=false;

try
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end;
except;end;
end;
//## low__rword ##
function low__rword(x:word):word;
var
   b,a:twrd2;
begin
result:=0;

try
//process
a.val:=x;
b.bytes[0]:=a.bytes[1];
b.bytes[1]:=a.bytes[0];
//return result
result:=b.val;
except;end;
end;
//## low__insint ##
function low__insint(x:longint;y:boolean):longint;
begin
if y then result:=x else result:=0;
end;
//## low__inscmp ##
function low__inscmp(x:comp;y:boolean):comp;
begin
if y then result:=x else result:=0;
end;
//## frcmin ##
function frcmin32(x,min:longint):longint;
begin
result:=x;
if (result<min) then result:=min;
end;
//## frcmax ##
function frcmax32(x,max:longint):longint;
begin
result:=x;
if (result>max) then result:=max;
end;
//## frcrange ##
function frcrange32(x,min,max:longint):longint;
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;
//## frcrange2 ##
function frcrange2(var x:longint;xmin,xmax:longint):boolean;//20dec2023, 29apr2020
begin
result:=true;//pass-thru
if (x<xmin) then x:=xmin;
if (x>xmax) then x:=xmax;
end;
//## smallest ##
function smallest(a,b:longint):longint;
begin
result:=a;
if (result>b) then result:=b;
end;
//## largest ##
function largest(a,b:longint):longint;
begin
result:=a;
if (result<b) then result:=b;
end;
//## cfrcrange ##
function cfrcrange32(x,min,max:currency):currency;//date: 02-APR-2004
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;
//## strint ##
function strint(x:string):longint;//skip over pluses "+" - 22jan2022, skip over commas - 05jun2021, date: 16aug2020, 25mar2016 v1.00.50 / 10DEC2009, v1.00.045
var //Similar speed to "strtoint" - no erros are produced though
    //Fixed "integer out of range" error, for data sets that fall outside of range
   n,xlen,z,y:longint;
   tmp:currency;
begin
//defaults
result:=0;

try
tmp:=0;
if (x='') then exit;
//init
xlen:=length(x);
n:=1;
//get
z:=1;
while true do
begin
y:=byte(x[z-1+stroffset]);
if (y=45) then n:=-1
else if (y=43) then
   begin
   //do nothing as "+" does nothing - 22jan2022
   end
else if (y=ssComma) then//05jun2021
   begin
   //nil
   end
else
    begin
    if (y<48) or (y>57) then break;
    tmp:=(tmp*10)+y-48;
    end;
inc(z);
if (z>xlen) then break;
//.range limit => prevent error "EInvalidOP - Invalid floating point operation" - 25mar2016
if (tmp>max32) then
   begin
   tmp:=max32;
   break;
   end;
end;//loop
//n
tmp:=cfrcrange32(tmp*n,min32,max32);
result:=round(tmp);
except;end;
end;
//## frcmin64 ##
function frcmin64(x,min:comp):comp;//24jan2016
begin
result:=x;
if (result<min) then result:=min;
end;
//## frcmax64 ##
function frcmax64(x,max:comp):comp;//24jan2016
begin
result:=x;
if (result>max) then result:=max;
end;
//## frcrange64 ##
function frcrange64(x,min,max:comp):comp;//24jan2016
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;
//## frcrange642 ##
function frcrange642(var x:comp;xmin,xmax:comp):boolean;//20dec2023
begin
result:=true;//pass-thru
if (x<xmin) then x:=xmin;
if (x>xmax) then x:=xmax;
end;
//## smallest64 ##
function smallest64(a,b:comp):comp;
begin
result:=a;
if (result>b) then result:=b;
end;
//## largest64 ##
function largest64(a,b:comp):comp;
begin
result:=a;
if (result<b) then result:=b;
end;
//## strint64 ##
function strint64(x:string):comp;//v1.00.035 - 05jun2021, v1.00.033 - 28jan2017
var
   n,digcount,xlen,z,y:longint;
begin
//defaults
result:=0;

try
if (x='') then exit;
//init
xlen:=length(x);
digcount:=0;//comp 64bit allows for 18 digit WHOLE numbers (- and +) - 28jan2017
n:=1;
//get
z:=0;
while true do
begin
y:=byte(x[z+stroffset]);
if (y=45) then n:=-n
else if (y=ssComma) then//05jun2021
   begin
   //nil
   end
else
    begin
    if (y<48) or (y>57) then break;
    result:=result*10+(y-48);
    inc(digcount);
    end;
inc(z);
//.range limit to 18 digits => prevent error "EInvalidOP - Invalid floating point operation" - 27jan2017
if (z>=xlen) or (digcount>=18) then break;
end;//end of while
//sign
result:=n*result;
except;end;
end;
//## intstr64 ##
function intstr64(x:comp):string;//30jan2017
var
   p:longint;
begin
//defaults
result:='0';

try
//get
result:=floattostrf(x,ffFixed,18,18);
if (result<>'') then
   begin
   for p:=0 to (length(result)-1) do if (result[p+stroffset]='.') then
      begin
      result:=strcopy0(result,0,p);
      break;
      end;//p
   end;
except;end;
end;
//## strdec ##
function strdec(x:string;y:byte;xcomma:boolean):string;
var
   a,b:string;
   aLen,p:longint;
begin
result:='';

try
//range
if (y>10) then y:=10;
//init
a:=x;
alen:=length(a);
b:='';
//get
if (alen>=1) then
   begin
   for p:=0 to (alen-1) do if (a[p+stroffset]='.') then
      begin
      b:=strcopy0(a,p+1,alen);
      a:=strcopy0(a,0,p);
      break;
      end;//p
   end;
//xcomma - thousands
if xcomma then a:=curcomma(strtofloatex(a));
//set
if (y<=0) then result:=a else result:=a+'.'+strcopy0b(b+'0000000000',0,y);
except;end;
end;
//## curdec ##
function curdec(x:currency;y:byte;xcomma:boolean):string;
begin
result:='';try;result:=strdec(floattostrex2(x),y,xcomma);except;end;
end;
//## curstrex ##
function curstrex(x:currency;sep:string):string;//01aug2017, 07SEP2007
var
   xlen,i,p:longint;
   decbit,z2,Z,Y:String;
begin
//defaults
result:='0';

try
decbit:='';
//init
z2:='';
if (x<0) then
   begin
   x:=-x;
   z2:='-';
   end;
//.dec point fix - 01aug2017
y:=floattostrex2(x);
if (y<>'') then for p:=0 to (length(y)-1) do if (y[p+stroffset]='.') then
   begin
   decbit:=strcopy0(y,p,length(y));
   y:=strcopy0(y,0,p);
   break;
   end;
//get
z:='';
xlen:=length(y);
i:=0;
if (xlen>=1) then
   begin
   for p:=(xlen-1) downto 0 do
   begin
   inc(i);
   if (i>=3) and (p>0) then
      begin
      z:=sep+strcopy0(y,p,3)+z;
      i:=0;
      end;
   end;//p
   end;
if (i<>0) then z:=strcopy0(y,0,i)+z;
//return result
result:=z2+z+decbit;
except;end;
end;
//## curcomma ##
function curcomma(x:currency):string;{same as "Thousands" but for "double"}
begin
result:='';try;result:=curstrex(x,',');except;end;
end;
//## low__remcharb ##
function low__remcharb(x:string;c:char):string;//26apr2019
begin
result:='';try;result:=x;low__remchar(result,c);except;end;
end;
//## low__remchar ##
function low__remchar(var x:string;c:char):boolean;//26apr2019
var
   xlen,i,p:longint;
begin
//defaults
result:=false;

try
xlen:=length(x);
i:=0;
//get
if (xlen>=1) then
   begin
   for p:=0 to (xlen-1) do
   begin
   if (x[p+stroffset]=c) then inc(i)
   else if (i<>0) then x[p-i+stroffset]:=x[p+stroffset];
   end;//p
   end;
//shrink
if (i<>0) then low__setlen(x,xlen-i);
except;end;
end;
//## low__rembinary ##
function low__rembinary(var x:string):boolean;//07apr2020
var
   xlen,i,p:longint;
begin
//defaults
result:=false;

try
xlen:=length(x);
i:=0;
//get
if (xlen>=1) then
   begin
   for p:=0 to (xlen-1) do
   begin
   if (x[p+stroffset]<#32) then inc(i)
   else if (i<>0) then x[p-i+stroffset]:=x[p+stroffset];
   end;//p
   end;
//shrink
if (i<>0) then low__setlen(x,xlen-i);
except;end;
end;
//## low__digpad20 ##
function low__digpad20(v:comp;s:longint):string;//1 -> 01
const
   p='00000000000000000000';//20
begin
result:='';

try
v:=restrict64(v);
result:=floattostrex2(v);
result:=strcopy1b(p,1,frcmin32(s-length(result),0))+result;
except;end;
end;
//## low__digpad11 ##
function low__digpad11(v,s:longint):string;//1 -> 01
const
   p='00000000000';//11
begin
result:='';

try
result:=inttostr(v);
result:=strcopy1b(p,1,frcmin32(s-length(result),0))+result;
except;end;
end;



//compression procs ------------------------------------------------------------
//## low__compress ##
function low__compress(x:pobject):boolean;
begin
result:=false;try;result:=low__compress2(x,true,true);except;end;
end;
//## decompress ##
function low__decompress(x:pobject):boolean;
begin
result:=false;try;result:=low__compress2(x,false,true);except;end;
end;
//## low__compress2 ##
function low__compress2(x:pobject;xcompress,xfast:boolean):boolean;//17feb2024, 05feb2021
begin
//defaults
result:=false;

try
//check
if not str__ok(x) then exit;

{$ifdef d3}  result:=d3__compress(x^,xcompress,xfast); {$endif}
{$ifdef laz} result:=laz__compress(x^,xcompress,xfast); {$endif}
except;end;
end;




//general procs ----------------------------------------------------------------


//.file procs ------------------------------------------------------------------
//## low__foldertep ##
function low__foldertep(xfolder:string):longint;
begin
result:=0;try;result:=low__foldertep2(0,xfolder);except;end;
end;
//## low__foldertep2 ##
function low__foldertep2(xownerid:longint;xfolder:string):longint;
begin
result:=tepNone;//for GUI only
end;

//nav procs (file list support) ------------------------------------------------
//## tepext ##
function tepext(xfilenameORext:string):longint;
begin
result:=tepNone;
end;
//## low__true1 ##
function low__true1(v1:boolean):boolean;
begin
result:=v1;
end;
//## low__true2 ##
function low__true2(v1,v2:boolean):boolean;
begin
result:=v1 and v2;
end;
//## low__true3 ##
function low__true3(v1,v2,v3:boolean):boolean;
begin
result:=v1 and v2 and v3;
end;
//## low__true4 ##
function low__true4(v1,v2,v3,v4:boolean):boolean;
begin
result:=v1 and v2 and v3 and v4;
end;
//## low__true5 ##
function low__true5(v1,v2,v3,v4,v5:boolean):boolean;
begin
result:=v1 and v2 and v3 and v4 and v5;
end;
//## low__or2 ##
function low__or2(v1,v2:boolean):boolean;
begin
result:=v1 or v2;
end;
//## low__or3 ##
function low__or3(v1,v2,v3:boolean):boolean;
begin
result:=v1 or v2 or v3;
end;
//## swapbol ##
procedure low__swapbol(var x,y:boolean);//05oct2018
var
   z:boolean;
begin
z:=x;
x:=y;
y:=z;
end;
//## swapbyt ##
procedure low__swapbyt(var x,y:byte);//22JAN2011
var
   z:byte;
begin
z:=x;
x:=y;
y:=z;
end;
//## swapint ##
procedure low__swapint(var x,y:longint);
var
   z:longint;
begin
z:=x;
x:=y;
y:=z;
end;
//## low__swapstr ##
procedure low__swapstr(var x,y:string);//20nov2023
var
   z:string;
begin
try;z:=x;x:=y;y:=z;except;end;
end;
//## swapcomp ##
procedure low__swapcomp(var x,y:comp);//07apr2016
var
   z:comp;
begin
z:=x;
x:=y;
y:=z;
end;
//## swapcur ##
procedure low__swapcur(var x,y:currency);
var
   z:currency;
begin
z:=x;
x:=y;
y:=z;
end;
//## swapext ##
procedure low__swapext(var x,y:extended);//06JUN2007
var
   z:extended;
begin
z:=x;
x:=y;
y:=z;
end;
//## low__swapstr8 ##
procedure low__swapstr8(var x,y:tstr8);//07dec2023
var
   z:tstr8;
begin
z:=x;
x:=y;
y:=z;
end;
//## low__swapvars8 ##
procedure low__swapvars8(var x,y:tvars8);//07dec2023
var
   z:tvars8;
begin
z:=x;
x:=y;
y:=z;
end;
//## low__swapcolor32 ##
procedure low__swapcolor32(var x,y:tcolor32);//13dec2023
var
   z:tcolor32;
begin
z:=x;
x:=y;
y:=z;
end;
//## runLOW ##
procedure runLOW(fDOC,fPARMS:string);//stress tested on Win98/WinXP - 27NOV2011, 06JAN2011
begin
try;win____shellexecute(longint(0),nil,PChar(fDoc),PChar(fPARMS),nil,1);except;end;
end;
//## low__syszoom ##
procedure low__syszoom(var aw,ah:longint);
begin
try
aw:=aw*vizoom;
ah:=ah*vizoom;
except;end;
end;




//## aorb ##
function low__aorb(a,b:longint;xuseb:boolean):longint;
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbrect ##
function low__aorbrect(a,b:trect;xuseb:boolean):trect;//25nov2023
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbbyte ##
function low__aorbbyte(a,b:byte;xuseb:boolean):byte;//11feb2023
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbcur ##
function low__aorbcur(a,b:currency;xuseb:boolean):currency;//07oct2022
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbcomp ##
function low__aorbcomp(a,b:comp;xuseb:boolean):comp;//19feb2024
begin
if xuseb then result:=b else result:=a;
end;
//## low__yes ##
function low__yes(x:boolean):string;//16sep2022
begin
result:=low__aorbstr('No','Yes',x);
end;
//## low__enabled ##
function low__enabled(x:boolean):string;//29apr2024
begin
result:=low__aorbstr('Disabled','Enabled',x);
end;
//## low__aorbstr8 ##
function low__aorbstr8(a,b:tstr8;xuseb:boolean):tstr8;//06dec2023
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbvars8 ##
function low__aorbvars8(a,b:tvars8;xuseb:boolean):tvars8;//06dec2023
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbstr ##
function low__aorbstr(a,b:string;xuseb:boolean):string;
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbchar ##
function low__aorbchar(a,b:char;xuseb:boolean):char;
begin
if xuseb then result:=b else result:=a;
end;
//## low__aorbbol ##
function low__aorbbol(a,b:boolean;xuseb:boolean):boolean;
begin
if xuseb then result:=b else result:=a;
end;
//## initcrc32 ##
procedure low__initcrc32;
var//Note: 0xedb88320L="-306674912"
   c,k,n:longint;
begin
try
//check
if sys_initcrc32 then exit;
//get
for n:=0 to 255 do
begin
c:=n;
for k:=0 to 7 do if boolean(c and 1) then c:=crc_seed xor (c shr 1) else c:=c shr 1;
sys_crc32[n]:=c;
end;//end of loop
except;end;
try;sys_initcrc32:=true;except;end;
end;
//## crc32inc ##
procedure low__crc32inc(var _crc32:longint;x:byte);//23may2020, 31-DEC-2006
var
   c:longint;
begin
try
//check
if not sys_initcrc32 then low__initcrc32;
//get
c:=_crc32 xor crc_against;//was $ffffffff;
c:=sys_crc32[(c xor byte(x)) and $ff] xor (c shr 8);
_crc32:=c xor crc_against;//was $ffffffff;
except;end;
end;
//## low__crc32 ##
procedure low__crc32(var _crc32:longint;x:tstr8;s,f:longint);//31-DEC-2006, updated 27-MAR-2007
label
   skipend;
var//Industry standard CRC-32 (PASSED, Sunday 31-DEC-2006)
   p,xlen:longint;
begin
try
//defaults
_crc32:=0;
//check
if (not str__lock(@x)) or (x.count<=0) then goto skipend else xlen:=x.count;
//init
if not sys_initcrc32 then low__initcrc32;
//range
s:=frcrange32(s,1,xlen);
f:=frcrange32(f,s,xlen);
//get
for p:=s to f do low__crc32inc(_crc32,x.bytes1[p]);
skipend:
except;end;
try;str__uaf(@x);except;end;
end;
//## crc32c ##
function low__crc32c(x:tstr8;s,f:longint):longint;
begin
result:=0;
try;if str__lock(@x) then low__crc32(result,x,s,f);except;end;
try;str__uaf(@x);except;end;
end;
//## crc32b ##
function low__crc32b(x:tstr8):longint;
begin
result:=0;
try;if str__lock(@x) then low__crc32(result,x,1,x.count);except;end;
try;str__uaf(@x);except;end;
end;
//## crc32nonzero ##
function low__crc32nonzero(x:tstr8):longint;//02SEP2010
begin
//defaults
result:=0;//only zero if "z=''" else non-zero, always
try
//get
if str__lock(@x) and (x.count>=1) then
   begin
   result:=low__crc32b(x);
   if (result=0) then result:=1;
   end;
except;end;
try;str__uaf(@x);except;end;
end;
//## crc32seedable ##
function low__crc32seedable(x:tstr8;xseed:longint):longint;//14jan2018
label
   skipend;
var
   xref:array[0..255] of longint;
   k,n,c:longint;
begin
//defaults
result:=0;//only zero if "z=''" else non-zero, always
try
//check
if zznil(x,2196) or (x.count<=0) then goto skipend;
if (xseed=0) then xseed:=crc_seed;//industry standard seed value
//init
for n:=0 to 255 do
begin
c:=n;
for k:=0 to 7 do if boolean(c and 1) then c:=xseed xor (c shr 1) else c:=c shr 1;
xref[n]:=c;
end;//n
//get
for n:=1 to x.count do
begin
c:=result xor crc_against;//was $ffffffff;
c:=xref[(c xor x.bytes1[n]) and $ff] xor (c shr 8);
result:=c xor crc_against;//was $ffffffff;
end;//n
skipend:
except;end;
try;str__autofree(@x);except;end;
end;

//## twproc ####################################################################
//## wproc__windowproc ##
function wproc__windowproc(hWnd:hwnd;msg:uint;wparam:wparam;lparam:lparam):lresult; stdcall;
begin
//defaults
result:=0;
try
//track the number of inbound messages
if (system_message_count<max32) then inc(system_message_count) else system_message_count:=0;
//check
if (system_state>=ssStopping) then exit;//when "state=ssStopped" it must be assumed the app has already destroyed it's core support structure, e.g. vars/object and references
//decide
if (msg=wm_net_message) and system_net_session then result:=app__onmessage(msg,wparam,lparam)
else                                                result:=win____defwindowproc(hwnd,msg,wparam,lparam);//app__onmessage(msg,wparam,lparam);
except;end;
end;
//## create ##
constructor twproc.create;
const
   xclassname='wproc';//22dec2023
var
   a:twndclass;
begin
try
//self
inherited create;
//make class
with a do
begin
style           :=0;
lpfnWndProc     :=@wproc__windowproc;
cbClsExtra      :=0;
cbWndExtra      :=0;
hInstance       :=0;
hIcon           :=0;
hCursor         :=0;
hbrBackground   :=0;
lpszMenuName    :=nil;
lpszClassName   :=pchar(xclassname);
end;
//register class
win____registerclassa(a);
//make window
iwindow:=win____createwindow(pchar(xclassname),'',0,0,0,0,0,0,0,hinstance,nil);
except;end;
end;
//## destroy ##
destructor twproc.destroy;
begin
try
win____destroywindow(iwindow);
iwindow:=0;
inherited destroy;
except;end;
end;

//## tdynamiclist ##############################################################
//## create ##
constructor tdynamiclist.create;
begin
//self
track__inc(satDynlist,1);
inherited create;
//sd
//vars
sorted:=nil;
icore:=nil;
ilockedBPI:=false;
isize:=0;
icount:=0;
ibpi:=1;
ilimit:=max32;
if (globaloverride_incSIZE>=1) then iincsize:=globaloverride_incSIZE else iincsize:=200;//22MAY2010
freesorted:=true;
//defaults
_createsupport;
_init;
_corehandle;
end;
//## destroy ##
destructor tdynamiclist.destroy;
begin
try
//clear
clear;
//controls
_destroysupport;
mem__freemem(icore,isize*ibpi,9021);
sdm_track(-isize*ibpi);//04may2019
if freesorted and (sorted<>nil) then freeobj(@sorted);
//self
inherited destroy;
track__inc(satDynlist,-1);
except;end;
end;
//## sdm_track ##
procedure tdynamiclist.sdm_track(xby:comp);
begin
try
//nil
except;end;
end;
//## _createsupport ##
procedure tdynamiclist._createsupport;
begin
//nil
end;
//## _destroysupport ##
procedure tdynamiclist._destroysupport;
begin
//nil
end;
//## nosort ##
procedure tdynamiclist.nosort;
begin
try;if (sorted<>nil) then freeobj(@sorted);except;end;
end;
//## nullsort ##
procedure tdynamiclist.nullsort;
var
   p:longint;
begin
try
//check
if (sorted=nil) then
   begin
   freesorted:=true;
   sorted:=tdynamicinteger.create;
   end;//end of if
//process
//.sync "sorted" object
sorted.size:=size;
sorted.count:=count;
//.fill with default "non-sorted" map list
for p:=0 to (count-1) do sorted.items[p]:=p;
except;end;
end;
//## sort ##
procedure tdynamiclist.sort(_asc:boolean);
begin
try
//init
nullsort;
//get
if (count>=1) then _sort(_asc);
except;end;
end;
//## _sort ##
procedure tdynamiclist._sort(_asc:boolean);
begin
{nil}
end;
//## _init ##
procedure tdynamiclist._init;
begin
try;_setparams(0,0,1,false);except;end;
end;
//## _corehandle ##
procedure tdynamiclist._corehandle;
begin
{nil}
end;
//## _oncreateitem ##
procedure tdynamiclist._oncreateitem(sender:tobject;index:longint);
begin
try;if assigned(oncreateitem) then oncreateitem(self,index);except;end;
end;
//## _onfreeitem ##
procedure tdynamiclist._onfreeitem(sender:tobject;index:longint);
begin
try;if assigned(onfreeitem) then onfreeitem(self,index);except;end;
end;
//## setincsize ##
procedure tdynamiclist.setincsize(x:longint);
begin
try;iincsize:=frcmin32(x,1);except;end;
end;
//## clear ##
procedure tdynamiclist.clear;
begin
try;size:=0;except;end;
end;
//## notify ##
function tdynamiclist.notify(s,f:longint;_event:tdynamiclistevent):boolean;
var
   p:longint;
begin
//defaults
result:=false;
try
//no range checking (isize may be undefined at this stage, assume s & f are within range)
if (s<0) or (f<0) or (s>f) then exit;
//process
for p:=s to f do if assigned(_event) then _event(self,p);
//successful
result:=true;
except;end;
end;
//## shift ##
procedure tdynamiclist.shift(s,by:longint);
var
   p:longint;
begin
try
if (by>=1) then for p:=(isize-1) downto (s+by) do swap(p,p-by)
else if (by<=-1) then for p:=s to (isize-1) do swap(p,p+by);
except;end;
end;
//## swap ##
function tdynamiclist.swap(x,y:longint):boolean;
var
   a:byte;
   b:pdlBYTE;
   p:longint;
begin
//defaults
result:=false;
try
//check
if (x<0) or (x>=isize) or (y<0) or (y>=isize) then exit;
if assigned(onswapitems) then onswapitems(self,x,y)
else
    begin
    //init
    b:=icore;
    x:=x*ibpi;
    y:=y*ibpi;
    //get (swap values byte-by-byte)
    for p:=0 to (ibpi-1) do
    begin
    //1
    a:=b[x+p];
    //2
    b[x+p]:=b[y+p];
    //3
    b[y+p]:=a;
    end;//p
    end;
//successful
result:=true;
except;end;
end;
//## setparams ##
function tdynamiclist.setparams(_count,_size,_bpi:longint):boolean;
begin
result:=_setparams(_count,_size,_bpi,true);
end;
//## _setparams ##
function tdynamiclist._setparams(_count,_size,_bpi:longint;_notify:boolean):boolean;
label
     skipend;
var
   a:pointer;
   _oldsize,_limit:longint;
begin
//defaults
result:=false;
try
//enforce range
if ilockedBPI then _bpi:=ibpi else _bpi:=frcmin32(_bpi,1);
_limit:=(max32 div nozero__int32(1000002,_bpi))-1;
_size:=frcrange32(_size,0,_limit);
_oldsize:=frcrange32(isize,0,_limit)*ibpi;
//process
//.size
if (_size<>isize) then
   begin
   a:=icore;
   //.enlarge
   if (_size>isize) then
      begin
      mem__reallocmemCLEAR(icore,_oldsize,_size*_bpi,3);
      sdm_track((_size*_bpi)-_oldsize);//04may2019
      //.update core handle
      if (a<>icore) then _corehandle;
      if _notify then notify(isize,_size-1,_oncreateitem);
      end
   //.shrink
   else if (_size<isize) then
      begin
      if _notify then notify(_size,isize-1,_onfreeitem);
      mem__reallocmemCLEAR(icore,_oldsize,_size*_bpi,4);
      sdm_track((_size*_bpi)-_oldsize);//04may2019
      //.update core handle
      if (a<>icore) then _corehandle;
      end;//end of if
   //.check
   end;
//.vars
ilimit:=_limit;
isize:=_size;
icount:=frcrange32(_count,0,_size);
ibpi:=_bpi;
//successful
result:=true;
skipend:
except;end;
end;
//## atleast ##
function tdynamiclist.atleast(_size:longint):boolean;
begin
if (_size>=size) then result:=_setparams(count,((_size div nozero__int32(1000003,incsize))+1)*incsize,bpi,true) else result:=true;
end;
//## addrange ##
function tdynamiclist.addrange(_count:longint):boolean;
var
   newsize,newcount:longint;
begin
//defaults
result:=false;
try
//check
if (_count<=0) then exit;
//prepare
newsize:=isize;
newcount:=icount+_count;
//check
if (newcount>ilimit) then exit;
if (newcount>newsize) then
   begin
   newsize:=newcount+iincsize;
   if (newsize>ilimit) then newsize:=ilimit;
   end;//end of if
//process
result:=setparams(newcount,newsize,bpi) and (newcount>=icount);
except;end;
end;
//## add ##
function tdynamiclist.add:boolean;
begin
result:=addrange(1);
end;
//## delrange
function tdynamiclist.delrange(s,_count:longint):boolean;
begin
//defaults
result:=false;
try
//check
if (s<0) or (s>=isize) then exit;
_count:=frcrange32(_count,0,isize-s);
if (_count<=0) then exit;
//process
//.free
if not notify(s,s+_count-1,_onfreeitem) then exit;
//.shift down by "_count"
shift(s+_count,-_count);
//.shrink
if not _setparams(count-_count,isize-_count,bpi,false) then exit;
//successful
result:=true;
except;end;
end;
//## _del ##
function tdynamiclist._del(x:longint):boolean;//2nd copy - 20oct2018
begin
result:=delrange(x,1);
end;
//## del ##
function tdynamiclist.del(x:longint):boolean;
begin
result:=delrange(x,1);
end;
//## insrange ##
function tdynamiclist.insrange(s,_count:longint):boolean;
var
   _oldsize:longint;
begin
//defaults
result:=false;
try
//check
_count:=frcmin32(_count,0);
if (_count<=0) or (s<0) or (s>=isize) then exit;
if ((isize+_count)>ilimit) then exit;
//process
//.enlarge
_oldsize:=isize*bpi;
inc(isize,_count);
inc(icount,_count);
mem__reallocmemCLEAR(icore,_oldsize,isize*bpi,5);
//.shift up by "_count"
shift(s,_count);
//.new
if not notify(s,s+_count-1,_oncreateitem) then exit;
//successful
result:=true;
except;end;
end;
//## ins ##
function tdynamiclist.ins(x:longint):boolean;
begin
result:=insrange(x,1);
end;
//## setcount ##
procedure tdynamiclist.setcount(x:longint);
begin
setparams(x,size,bpi);
end;
//## setsize ##
procedure tdynamiclist.setsize(x:longint);
begin
setparams(count,x,bpi);
end;
//## setbpi ##
procedure tdynamiclist.setbpi(x:longint);//bytes per item
begin
setparams(count,size,x);
end;
//## findvalue ##
function tdynamiclist.findvalue(_start:longint;_value:pointer):longint;
var
   a,b:pdlBYTE;
   maxp2,ai,p2,p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) or (_value=nil) then exit;
//init
a:=core;
b:=_value;
maxp2:=ibpi-1;
//get
for p:=_start to (icount-1) do
    begin
    ai:=p*ibpi;
    p2:=0;
    repeat
    if (a[ai+p2]<>b[p2]) then break;
    inc(p2);
    until (p2>maxp2);
    if (p2>maxp2) then
       begin
       result:=p;
       exit;
       end;//p2
    end;//p
except;end;
end;
//## sindex ##
function tdynamiclist.sindex(x:longint):longint;
begin//sorted index
if zznil(sorted,2280) or (x>=sorted.count) then result:=x else result:=sorted.value[x];
end;

//## tdynamicinteger ###########################################################
//## create ##
constructor tdynamicinteger.create;//01may2019
begin
track__inc(satDynint,1);
inherited create;
end;
//## destroy ##
destructor tdynamicinteger.destroy;//01may2019
begin
inherited destroy;
track__inc(satDynint,-1);
end;
//## _init ##
procedure tdynamicinteger._init;
begin
try
_setparams(0,0,4,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;
//## copyfrom ##
function tdynamicinteger.copyfrom(s:tdynamicinteger):boolean;
var
   p,xcount:longint;
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
freesorted:=s.freesorted;
utag:=s.utag;
xcount:=s.count;
size:=s.size;
count:=xcount;
for p:=(xcount-1) downto 0 do value[p]:=s.value[p];
if (s.sorted=nil) then
   begin
   if (sorted<>nil) then nosort;
   end
else
   begin
   nullsort;
   for p:=(s.sorted.count-1) downto 0 do sorted.value[p]:=s.sorted.value[p];
   end;
except;end;
end;
//## _corehandle ##
procedure tdynamicinteger._corehandle;
begin
iitems:=core;
end;
//## getvalue ##
function tdynamicinteger.getvalue(_index:longint):longint;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;
//## setvalue ##
procedure tdynamicinteger.setvalue(_index:longint;_value:longint);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;
//## getsvalue ##
function tdynamicinteger.getsvalue(_index:longint):longint;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamicinteger.setsvalue(_index:longint;_value:longint);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamicinteger.find(_start:longint;_value:longint):longint;
var
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;//p
except;end;
end;
//## _sort ##
procedure tdynamicinteger._sort(_asc:boolean);
begin
try;__sort(items,sorted.items,0,count-1,_asc);except;end;
end;
//## __sort ##
procedure tdynamicinteger.__sort(a:pdllongint;b:pdllongint;l,r:longint;_asc:boolean);
var
  p,tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;//end of if
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;//end of if
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;
//## tdynamicdatetime ##########################################################
//## create ##
constructor tdynamicdatetime.create;
begin
track__inc(satDyndate,1);
inherited create;
end;
//## destroy ##
destructor tdynamicdatetime.destroy;
begin
inherited destroy;
track__inc(satDyndate,-1);
end;
//## _init ##
procedure tdynamicdatetime._init;
begin
try
_setparams(0,0,8,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamicdatetime._corehandle;
begin
iitems:=core;
end;
//## getvalue ##
function tdynamicdatetime.getvalue(_index:longint):tdatetime;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;
//## setvalue ##
procedure tdynamicdatetime.setvalue(_index:longint;_value:tdatetime);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;
//## getsvalue ##
function tdynamicdatetime.getsvalue(_index:longint):tdatetime;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamicdatetime.setsvalue(_index:longint;_value:tdatetime);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamicdatetime.find(_start:longint;_value:tdatetime):longint;
var//* Uses "2xInteger for QUICK comparision".
   //* Direct "Double" comparison is upto 3-4 times slower.
   a:pdlbilongint;
   b:pbilongint;
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
a:=core;
b:=@_value;
//process
for p:=_start to (icount-1) do if (a[p][0]=b[0]) and (a[p][1]=b[1]) then
    begin
    result:=p;
    break;
    end;//end of if
except;end;
end;
//## _sort ##
procedure tdynamicdatetime._sort(_asc:boolean);
begin
try;__sort(items,sorted.items,0,count-1,_asc);except;end;
end;
//## __sort ##
procedure tdynamicdatetime.__sort(a:pdlDATETIME;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:tdatetime;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;//end of if
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;//end of if
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;
//## tdynamicbyte ##############################################################
//## create ##
constructor tdynamicbyte.create;//01may2019
begin
track__inc(satDynbyte,1);
inherited create;
end;
//## destroy ##
destructor tdynamicbyte.destroy;//01may2019
begin
inherited destroy;
track__inc(satDynbyte,-1);
end;
//## _init ##
procedure tdynamicbyte._init;
begin
try
_setparams(0,0,1,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamicbyte._corehandle;
begin
iitems:=core;
ibits:=core;
end;
//## getvalue ##
function tdynamicbyte.getvalue(_index:longint):byte;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;
//## setvalue ##
procedure tdynamicbyte.setvalue(_index:longint;_value:byte);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;
//## getsvalue ##
function tdynamicbyte.getsvalue(_index:longint):byte;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamicbyte.setsvalue(_index:longint;_value:byte);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamicbyte.find(_start:longint;_value:byte):longint;
var
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;//p
except;end;
end;
//## _sort ##
procedure tdynamicbyte._sort(_asc:boolean);
begin
try;__sort(items,sorted.items,0,count-1,_asc);except;end;
end;
//## __sort ##
procedure tdynamicbyte.__sort(a:pdlbyte;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:byte;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;//end of if
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;//end of if
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamiccurrency ##########################################################
//## create ##
constructor tdynamiccurrency.create;//01may2019
begin
track__inc(satDyncur,1);
inherited create;
end;
//## destroy ##
destructor tdynamiccurrency.destroy;//01may2019
begin
inherited destroy;
track__inc(satDyncur,-1);
end;
//## _init ##
procedure tdynamiccurrency._init;
begin
try
_setparams(0,0,8,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamiccurrency._corehandle;
begin
iitems:=core;
end;
//## getvalue ##
function tdynamiccurrency.getvalue(_index:longint):currency;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;
//## setvalue ##
procedure tdynamiccurrency.setvalue(_index:longint;_value:currency);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;
//## getsvalue ##
function tdynamiccurrency.getsvalue(_index:longint):currency;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamiccurrency.setsvalue(_index:longint;_value:currency);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamiccurrency.find(_start:longint;_value:currency):longint;
var//* Uses "2xInteger for QUICK comparision".
   //* Direct "Currency" comparison is upto 3-4 times slower.
   a:pdlbilongint;
   b:pbilongint;
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
a:=core;
b:=@_value;
//process
for p:=_start to (icount-1) do if (a[p][0]=b[0]) and (a[p][1]=b[1]) then
    begin
    result:=p;
    break;
    end;//end of if
except;end;
end;
//## _sort ##
procedure tdynamiccurrency._sort(_asc:boolean);
begin
try;__sort(items,sorted.items,0,count-1,_asc);except;end;
end;
//## __sort ##
procedure tdynamiccurrency.__sort(a:pdlCURRENCY;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:currency;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;//end of if
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;//end of if
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamiccomp ##############################################################
//## create ##
constructor tdynamiccomp.create;//01may2019
begin
track__inc(satDyncomp,1);
inherited create;
end;
//## destroy ##
destructor tdynamiccomp.destroy;//01may2019
begin
inherited destroy;
track__inc(satDyncomp,-1);
end;
//## _init ##
procedure tdynamiccomp._init;
begin
try
_setparams(0,0,8,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamiccomp._corehandle;
begin
iitems:=core;
end;
//## getvalue ##
function tdynamiccomp.getvalue(_index:longint):comp;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;
//## setvalue ##
procedure tdynamiccomp.setvalue(_index:longint;_value:comp);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;
//## getsvalue ##
function tdynamiccomp.getsvalue(_index:longint):comp;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamiccomp.setsvalue(_index:longint;_value:comp);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamiccomp.find(_start:longint;_value:comp):longint;
var//* Uses "2xInteger for QUICK comparision".
   a:pdlBILONGINT;
   b:pBILONGINT;
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
a:=core;
b:=@_value;
//process
for p:=_start to (icount-1) do if (a[p][0]=b[0]) and (a[p][1]=b[1]) then
    begin
    result:=p;
    break;
    end;//end of if
except;end;
end;
//## _sort ##
procedure tdynamiccomp._sort(_asc:boolean);
begin
try;__sort(items,sorted.items,0,count-1,_asc);except;end;
end;
//## __sort ##
procedure tdynamiccomp.__sort(a:pdlCOMP;b:pdlLONGINT;l,r:longint;_asc:boolean);
var
  p:comp;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;//end of if
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;//end of if
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamicpointer ###########################################################
//## create ##
constructor tdynamicpointer.create;//01may2019
begin
track__inc(satDynptr,1);
inherited create;
end;
//## destroy ##
destructor tdynamicpointer.destroy;//01may2019
begin
track__inc(satDynptr,-1);
inherited destroy;
end;
//## _init ##
procedure tdynamicpointer._init;
begin
try
_setparams(0,0,4,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamicpointer._corehandle;
begin
iitems:=core;
end;
//## getvalue ##
function tdynamicpointer.getvalue(_index:longint):pointer;
begin
//.check
if (_index<0) or (_index>=count) then result:=nil
else result:=items[_index];
end;
//## setvalue ##
procedure tdynamicpointer.setvalue(_index:longint;_value:pointer);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;
//## getsvalue ##
function tdynamicpointer.getsvalue(_index:longint):pointer;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamicpointer.setsvalue(_index:longint;_value:pointer);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamicpointer.find(_start:longint;_value:pointer):longint;
var
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;//end of if
except;end;
end;

//## tdynamicstring ############################################################
//## create ##
constructor tdynamicstring.create;//01may2019
begin
track__inc(satDynstr,1);
inherited create;
end;
//## destroy ##
destructor tdynamicstring.destroy;//01may2019
begin
inherited destroy;
track__inc(satDynstr,-1);
end;
//## copyfrom ##
function tdynamicstring.copyfrom(s:tdynamicstring):boolean;
var
   p,xcount:longint;
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
freesorted:=s.freesorted;
utag:=s.utag;
xcount:=s.count;
size:=s.size;
count:=xcount;
for p:=(xcount-1) downto 0 do value[p]:=s.value[p];
if (s.sorted=nil) then
   begin
   if (sorted<>nil) then nosort;
   end
else
   begin
   nullsort;
   for p:=(s.sorted.count-1) downto 0 do sorted.value[p]:=s.sorted.value[p];
   end;
except;end;
end;
//## gettext ##
function tdynamicstring.gettext:string;
var
   a:tstr8;
   p:longint;
begin
//defaults
result:='';
try
a:=nil;
//get
a:=str__new8;
for p:=0 to (count-1) do a.saddb(value[p]+rcode);
//set
result:=a.text;
except;end;
try;str__free(@a);except;end;
end;
//## settext ##
procedure tdynamicstring.settext(x:string);
var
   xdata,xline:tstr8;
   p:longint;
begin
try
//defaults
xdata:=nil;
xline:=nil;
p:=0;
//clear
clear;
//init
xdata:=bnewstr(x);
xline:=str__new8;
//get
while low__nextline0(xdata,xline,p) do value[count]:=xline.text;
except;end;
try
str__free(@xdata);
str__free(@xline);
except;end;
end;
//## getstext ##
function tdynamicstring.getstext:string;
var
   a:tstr8;
   p:longint;
begin
//defaults
result:='';
try
a:=nil;
//get
a:=str__new8;
for p:=0 to (count-1) do a.saddb(svalue[p]+rcode);
//set
result:=a.text;
except;end;
try;str__free(@a);except;end;
end;
//## _init ##
procedure tdynamicstring._init;
begin
try
_setparams(0,0,4,false);
ilockedBPI:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamicstring._corehandle;
begin
iitems:=core;
end;
//## _oncreateitem ##
procedure tdynamicstring._oncreateitem(sender:tobject;index:longint);
begin
try
mem__newpstring(iitems[index]);//29NOV2011
inherited;
except;end;
end;
//## _onfreeitem ##
procedure tdynamicstring._onfreeitem(sender:tobject;index:longint);
begin
try
inherited;
mem__despstring(iitems[index]);//29NOV2011
except;end;
end;
//## getvalue ##
function tdynamicstring.getvalue(_index:longint):string;
begin
if (_index<0) or (_index>=count) then result:='' else result:=items[_index]^;
end;
//## setvalue ##
procedure tdynamicstring.setvalue(_index:longint;_value:string);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]^:=_value;
end;
//## getsvalue ##
function tdynamicstring.getsvalue(_index:longint):string;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamicstring.setsvalue(_index:longint;_value:string);
begin
value[sindex(_index)]:=_value;
end;
//## find ##
function tdynamicstring.find(_start:longint;_value:string;_casesensitive:boolean):longint;
var
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//process
if _casesensitive then
   begin
   for p:=_start to (icount-1) do if strmatchCASE(iitems[p]^,_value) then//27apr2021
      begin
      result:=p;
      break;
      end;
   end
else
   begin
   for p:=_start to (icount-1) do if strmatch(iitems[p]^,_value) then
      begin
      result:=p;
      break;
      end;
   end;
except;end;
end;
//## _sort ##
procedure tdynamicstring._sort(_asc:boolean);
begin
try;__sort(items,sorted.items,0,count-1,_asc);except;end;
end;
//## __sort ##
procedure tdynamicstring.__sort(a:pdlstring;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:pstring;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (strmatch2(a^[b^[I]]^,p^)<0) do inc(I);
     while (strmatch2(a^[b^[J]]^,p^)>0) do dec(J);
     end
  else
     begin
     while (strmatch2(a^[b^[I]]^,p^)>0) do inc(I);
     while (strmatch2(a^[b^[J]]^,p^)<0) do dec(J);
     end;//end of if
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;//end of if
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamicname ##############################################################
//## create ##
constructor tdynamicname.create;//01may2019
begin
track__inc(satDynname,1);
inherited create;
end;
//## destroy ##
destructor tdynamicname.destroy;//01may2019
begin
track__inc(satDynname,-1);
inherited destroy;
end;
//## _createsupport ##
procedure tdynamicname._createsupport;
begin
try
//controls
iref:=tdynamiccomp.create;
except;end;
end;
//## _destroysupport ##
procedure tdynamicname._destroysupport;
begin
try
//controls
freeObj(@iref);
except;end;
end;
//## shift ##
procedure tdynamicname.shift(s,by:longint);
begin
try;inherited shift(s,by);iref.shift(s,by);except;end;
end;
//## _setparams ##
function tdynamicname._setparams(_count,_size,_bpi:longint;_notify:boolean):boolean;
begin
result:=false;try;result:=(inherited _setparams(_count,_size,_bpi,_notify)) and iref._setparams(_count,_size,_bpi,_notify);except;end;
end;
//## setvalue ##
procedure tdynamicname.setvalue(_index:longint;_value:string);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]^:=_value;
sync(_index);
end;
//## findfast ##
function tdynamicname.findfast(_start:longint;_value:string):longint;
var
   vREF:comp;
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
vREF:=low__ref256U(_value);
//process
p:=_start-1;
while TRUE do
begin
p:=iref.find(p+1,vREF);
if (p=-1) or (p>=size) then break
else if (comparetext(iitems[p]^,_value)=0) then
    begin
    result:=p;
    break;
    end;//end of if
end;//end of loop
except;end;
end;
//## sync ##
procedure tdynamicname.sync(x:longint);
begin
try;iref.value[x]:=low__ref256U(items[x]^);except;end;
end;

//## tdynamicnamelist ##########################################################
//## create ##
constructor tdynamicnamelist.create;
begin
track__inc(satDynnamelist,1);
//self
inherited create;
//vars
delshrink:=false;
iactive:=0;
end;
//## destroy ##
destructor tdynamicnamelist.destroy;
begin
track__inc(satDynnamelist,-1);
try;inherited destroy;except;end;
end;
//## clear ##
procedure tdynamicnamelist.clear;
begin
try
inherited clear;
iactive:=0;
except;end;
end;
//## add ##
function tdynamicnamelist.add(x:string):longint;
begin
result:=addb(x,true);
end;
//## addb ##
function tdynamicnamelist.addb(x:string;newonly:boolean):longint;
var
   isnewitem:boolean;
begin
result:=addex(x,newonly,isnewitem);
end;
//## addex ##
function tdynamicnamelist.addex(x:string;newonly:boolean;var isnewitem:boolean):longint;
var
   p:longint;
begin
//defaults
result:=-1;
isnewitem:=false;

try
//get
if (x<>'') then
   begin
   //.find
   p:=findfast(0,x);
   if newonly and (p>=0) then exit;
   //.new
   if (p=-1) then
      begin
      p:=findfast(0,'');
      if (p=-1) then p:=count;
      //.set
      value[p]:=x;
      isnewitem:=true;
      inc(iactive);
      end;//end of if
   //successful
   result:=p;
   end;//end of if
except;end;
end;
//## addonce ##
function tdynamicnamelist.addonce(x:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') and (not have(x)) then
   begin
   p:=findfast(0,'');
   if (p=-1) then p:=count;
   value[p]:=x;
   inc(iactive);
   //successful
   result:=true;
   end;//end of if
except;end;
end;
//## addonce2 ##
function tdynamicnamelist.addonce2(x:string;var xindex:longint):boolean;//08feb2020
begin//Note: Always returns xindex (new or otherwise), but also returns
//          (a) false=if "x" already exists and (b) true=if "x" did not exist and was added
//defaults
result:=false;
xindex:=-1;

try
//check
if (x='') then exit;

//get
//.return index of existing item (0..N)
xindex:=findfast(0,x);
//.add item if it doesn't already exist (-1)
if (xindex<0) then
   begin
   xindex:=count;
   value[xindex]:=x;
   inc(iactive);
   //successful
   result:=true;
   end;//end of if
except;end;
end;
//## replace ##
function tdynamicnamelist.replace(x,y:string):boolean;//can't prevent duplications if this proc is used
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') and (y<>'') and have(x) then
   begin
   p:=findfast(0,x);
   if (p>=0) then
      begin
      value[p]:=y;
      result:=true;
      end;//end of if
   end;//end of if
except;end;
end;
//## del ##
function tdynamicnamelist.del(x:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') then
   begin
   p:=findfast(0,x);
   if (p>=0) then
      begin
      if delshrink then (inherited del(p)) else value[p]:='';
      iactive:=frcmin32(iactive-1,0);
      result:=true;
      end;//end of if
   end;//end of if
except;end;
end;
//## delindex ##
procedure tdynamicnamelist.delindex(x:longint);//30AUG2007
begin
try;if delshrink then (inherited del(x)) else value[x]:='';except;end;
end;
//## have ##
function tdynamicnamelist.have(x:string):boolean;
begin
if (x='') then result:=false else result:=(findfast(0,x)>=0);
end;
//## find ##
function tdynamicnamelist.find(x:string;var xindex:longint):boolean;//09apr2024
begin
if (x<>'') then
   begin
   xindex:=findfast(0,x);
   result:=(xindex>=0);
   end
else
   begin
   xindex:=0;
   result:=false
   end;
end;

//## tdynamicvars ##############################################################
//## create ##
constructor tdynamicvars.create;
begin
track__inc(satDynvars,1);
//self
inherited create;
//controls
inamesREF:=tdynamiccomp.create;//09apr2024
inames:=tdynamicstring.create;
ivalues:=tdynamicstring.create;
//.incsize
if (globaloverride_incSIZE>=1) then incsize:=globaloverride_incSIZE else incsize:=10;//22MAY2010
end;
//## destroy ##
destructor tdynamicvars.destroy;
begin
track__inc(satDynvars,-1);
try
//controls
freeObj(@inamesREF);
freeObj(@inames);
freeObj(@ivalues);
//self
inherited destroy;
//sd
except;end;
end;
//## getbytes ##
function tdynamicvars.getbytes:longint;//13apr2018
var
   p:longint;
begin
result:=0;

try
result:=frcmin32(inamesREF.count,0)*8;
if (inames.count>=1) then for p:=(inames.count-1) downto 0 do inc(result,length(inames.items[p]^));
if (ivalues.count>=1) then for p:=(ivalues.count-1) downto 0 do inc(result,length(ivalues.items[p]^));
except;end;
end;
//## sortbyVALUE ##
procedure tdynamicvars.sortbyVALUE(_asc,_asnumbers:boolean);//04JUL2013
begin
sortbyVALUEEX(_asc,true,false);
end;
//## sortbyVALUEEX ##
procedure tdynamicvars.sortbyVALUEEX(_asc,_asnumbers,_commentsattop:boolean);//04JUL2013
var
   z:string;
   dcount,ncount,p,i:longint;
   n,v:tdynamicstring;
   vi:tdynamicinteger;
begin
//defaults
n:=nil;
v:=nil;
vi:=nil;
z:='';
dcount:=0;
i:=0;

try
//init
ncount:=names.count;
if (ncount<=0) then exit;//nothing to do
n:=tdynamicstring.create;
v:=tdynamicstring.create;
vi:=tdynamicinteger.create;
n.setparams(ncount,ncount,0);
v.setparams(ncount,ncount,0);
vi.setparams(ncount,ncount,0);
//get
//.make a FAST copy
for p:=0 to (ncount-1) do
begin
n.items[p]^:=names.items[p]^;
v.items[p]^:=values.items[p]^;
try;vi.items[p]:=strint(values.items[p]^);except;end;
end;
//.sort that copy
case _asnumbers of
true:vi.sort(_asc);
false:v.sort(_asc);
end;
//set
//.shift ALL comments "//" to top of list
if _commentsattop then for p:=0 to (n.count-1) do if (copy(n.items[p]^,1,2)='//') then
   begin
   names.items[dcount]^:=n.items[p]^;
   values.items[dcount]^:=v.items[p]^;
   inc(dcount);
   end;
//.by value
for p:=0 to (n.count-1) do
begin
case _asnumbers of
true:i:=vi.sorted.items[p];
false:i:=v.sorted.items[p];
end;
if (not _commentsattop) or (copy(n.items[i]^,1,2)<>'//') then
   begin
   names.items[dcount]^:=n.items[i]^;
   values.items[dcount]^:=v.items[i]^;
   inc(dcount);
   end;
end;//end of loop
//.namesREF
for p:=0 to (names.count-1) do namesREF.items[p]:=low__ref256U(names.items[p]^);
except;end;
try
freeobj(@n);
freeobj(@v);
freeobj(@vi);
except;end;
end;
//## sortbyNAME ##
procedure tdynamicvars.sortbyNAME(_asc:boolean);//12jul2016
var
   ncount,p,i:longint;
   n,v:tdynamicstring;
begin
try
//defaults
n:=nil;
v:=nil;
//init
ncount:=names.count;
if (ncount<=0) then exit;//nothing to do
n:=tdynamicstring.create;
v:=tdynamicstring.create;
n.setparams(ncount,ncount,0);
v.setparams(ncount,ncount,0);
//get
//.make a FAST copy
for p:=0 to (ncount-1) do
begin
n.items[p]^:=names.items[p]^;
v.items[p]^:=values.items[p]^;
end;
//.sort copy
n.sort(_asc);
//set
for p:=0 to (ncount-1) do
begin
i:=n.sorted.items[p];
namesREF.items[p]:=low__ref256U(n.items[i]^);
names.items[p]^:=n.items[i]^;
values.items[p]^:=v.items[i]^;
end;//p
except;end;
try
freeobj(@n);
freeobj(@v);
except;end;
end;
//## roll ##
procedure tdynamicvars.roll(x:string;by:currency);
var
   a:currency;
begin
try
a:=c[x];
low__croll(a,by);
c[x]:=a;
except;end;
end;
//## getb ##
function tdynamicvars.getb(x:string):boolean;
begin
result:=(i[x]<>0);
end;
//## setb ##
procedure tdynamicvars.setb(x:string;y:boolean);
begin
c[x]:=longint(y);
end;
//## getd ##
function tdynamicvars.getd(x:string):double;
begin
result:=strtofloatex(value[x]);
end;
//## setd ##
procedure tdynamicvars.setd(x:string;y:double);
begin
value[x]:=floattostrex2(y);
end;
//## getnc ##
function tdynamicvars.getnc(x:string):currency;
begin
result:=strtofloatex(swapstrsb(value[x],',',''));
end;
//## getc ##
function tdynamicvars.getc(x:string):currency;
begin
result:=strtofloatex(value[x]);
end;
//## setc ##
procedure tdynamicvars.setc(x:string;y:currency);
begin
value[x]:=floattostrex2(y);
end;
//## getni64 ##
function tdynamicvars.getni64(x:string):comp;
begin
result:=strint64(swapstrsb(value[x],',',''));
end;
//## geti64 ##
function tdynamicvars.geti64(x:string):comp;
begin
result:=strint64(value[x]);
end;
//## seti64 ##
procedure tdynamicvars.seti64(x:string;y:comp);
begin
value[x]:=intstr64(y);
end;
//## getni ##
function tdynamicvars.getni(x:string):longint;
begin
result:=strint(swapstrsb(value[x],',',''));
end;
//## geti ##
function tdynamicvars.geti(x:string):longint;
begin
result:=strint(value[x]);
end;
//## seti ##
procedure tdynamicvars.seti(x:string;y:longint);
begin
c[x]:=y;
end;
//## getpt ##
function tdynamicvars.getpt(x:string):tpoint;//09JUN2010
var
   a,b:string;
   p:longint;
begin
//defaults
result:=low__point(0,0);

try
//get
a:=value[x];
b:='';
for p:=1 to length(a) do if (a[p]='|') then
   begin
   b:=copy(a,p+1,length(a));
   a:=copy(a,1,p-1);
   break;
   end;
//set
result:=low__point(strint(a),strint(b));
except;end;
end;
//## setpt ##
procedure tdynamicvars.setpt(x:string;y:tpoint);//09JUN2010
begin
value[x]:=inttostr(y.x)+'|'+inttostr(y.y);
end;
//## copyfrom ##
procedure tdynamicvars.copyfrom(x:tdynamicvars);
var
   p:longint;
begin
try;for p:=0 to (x.count-1) do value[x.name[p]]:=x.valuei[p];except;end;
end;
//## copyvars ##
procedure tdynamicvars.copyvars(x:tdynamicvars;i,e:string);
var
   p:longint;
   n:string;
begin
try
for p:=0 to (x.count-1) do
begin
n:=x.n[p];
if low__matchmask(n,i) and ((e='') or (not low__matchmask(n,e))) then value[n]:=x.v[p];
end;//p
except;end;
end;
//## getincsize ##
function tdynamicvars.getincsize:longint;
begin
result:=inames.incsize;
end;
//## setincsize ##
procedure tdynamicvars.setincsize(x:longint);
begin
x:=frcmin32(x,1);
inamesREF.incsize:=x;
inames.incsize:=x;
ivalues.incsize:=x;
end;
//## getcount ##
function tdynamicvars.getcount:longint;
begin
result:=inames.count;
end;
//## new ##
function tdynamicvars.new(n,v:string):longint;
begin
result:=_find(n,v,true);
end;
//## find ##
function tdynamicvars.find(n:string;var i:longint):boolean;
begin
i:=find2(n);result:=(i>=0);
end;
//## find2 ##
function tdynamicvars.find2(n:string):longint;
begin
result:=_find(n,'',false);
end;
//## found ##
function tdynamicvars.found(n:string):boolean;
var
   int1:longint;
begin
result:=find(n,int1);
end;
//## _find ##
function tdynamicvars._find(n,v:string;_newedit:boolean):longint;
var
   i:longint;
   nREF:currency;
begin
//defaults
result:=-1;
if (n='') then exit;

try
//init - "uppercase" restriction removed from "n" on 14NOV2010
nREF:=low__ref256U(n);//now using "ref256U()" - 14NOV2010

//get
i:=0;
repeat
i:=inamesREF.find(i,nREF);
if (i<>-1) and (0=comparetext(inames.items[i]^,n)) then
   begin
   result:=i;
   break;
   end;
if (i<>-1) then inc(i);
until (i=-1);
//.new/edit
if _newedit then
    begin
    if (result=-1) then
       begin
       //.new empty
       result:=inamesREF.find(0,0);
       //.new
       if (result=-1) then result:=inamesREF.count;
       end;
    inamesREF.value[result]:=nREF;
    inames.value[result]:=n;
    ivalues.value[result]:=v;
    end;
except;end;
end;
//## delete ##
procedure tdynamicvars.delete(x:longint);
begin
if (x>=0) and (x<count) then
   begin
   inamesREF.value[x]:=0;
   inames.value[x]:='';
   ivalues.value[x]:='';
   end;
end;
//## remove ##
procedure tdynamicvars.remove(x:longint);//20oct2018
begin
if (x>=0) and (x<count) then
   begin
   inamesREF._del(x);
   inames._del(x);
   ivalues._del(x);
   end;
end;
//## rename ##
function tdynamicvars.rename(sn,dn:string;var e:string):boolean;//22oct2018
label
   skipend;
var
   si:longint;
begin
//defaults
result:=false;
e:=gecTaskfailed;

try
//check
if (sn='') or (dn='') then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;
if not find(sn,si) then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;
if (comparetext(sn,dn)=0) then//nothing to do -> skip
   begin
   result:=true;
   goto skipend;
   end;
if found(dn) then
   begin
   e:=gecFileinuse;
   goto skipend;
   end;
//get
inames.value[si]:=dn;
inamesREF.value[si]:=low__ref256U(dn);//now using "ref256U()" - 14NOV2010
//successful
result:=true;
skipend:
except;end;
end;
//## getname ##
function tdynamicvars.getname(x:longint):string;
begin
if (x<0) or (x>=inames.count) then result:='' else result:=inames.value[x];
end;
//## getvaluei ##
function tdynamicvars.getvaluei(x:longint):string;
begin
if (x<0) or (x>=inames.count) then result:='' else result:=ivalues.value[x];
end;
//## getvaluelen ##
function tdynamicvars.getvaluelen(x:longint):longint;//20oct2018
begin
if (x<0) or (x>=inames.count) then result:=0 else result:=length(ivalues.items[x]^);
end;
//## getvalueiptr ##
function tdynamicvars.getvalueiptr(x:longint):pstring;
begin
if (x<0) or (x>=inames.count) then result:=nil else result:=ivalues.items[x];
end;
//## getvalue ##
function tdynamicvars.getvalue(n:string):string;
var
   p:longint;
begin
p:=_find(n,'',false);
if (p=-1) then result:='' else result:=ivalues.value[p];
end;
//## setvalue ##
procedure tdynamicvars.setvalue(n,v:string);
begin
_find(n,v,true);
end;
//## clear ##
procedure tdynamicvars.clear;
begin
inamesREF.clear;
inames.clear;
ivalues.clear;
end;

//## tdynamicstr8 ##############################################################
//## create ##
constructor tdynamicstr8.create;//28dec2023
begin
track__inc(satDynstr8,1);
inherited create;
ifallback:=str__new8;
end;
//## destroy ##
destructor tdynamicstr8.destroy;
begin
try
str__free(@ifallback);
inherited destroy;
track__inc(satDynstr8,-1);
except;end;
end;
//## _init ##
procedure tdynamicstr8._init;
begin
try
_setparams(0,0,sizeof(pointer),false);
ilockedBPI:=true;
except;end;
end;
//## _corehandle ##
procedure tdynamicstr8._corehandle;
begin
iitems:=core;
end;
//## _oncreateitem ##
procedure tdynamicstr8._oncreateitem(sender:tobject;index:longint);
begin
try
iitems[index]:=str__new8;
inherited;
except;end;
end;
//## _onfreeitem ##
procedure tdynamicstr8._onfreeitem(sender:tobject;index:longint);
begin
try
inherited;
str__free(@iitems[index]);
except;end;
end;
//## getvalue ##
function tdynamicstr8.getvalue(_index:longint):tstr8;
begin
result:=nil;
try
if (_index>=0) and (_index<count) then result:=items[_index] else result:=nil;
if (result=nil) then
   begin
   if (ifallback.len<>0) then ifallback.clear;
   result:=ifallback;
   end;
except;end;
end;
//## setvalue ##
procedure tdynamicstr8.setvalue(_index:longint;_value:tstr8);//accepts "_value=nil" which create the index item and clears it's contents
label
   skipend;
begin
try
//lock
str__lock(@_value);
//get
if (_index>=0) then
   begin
   //set
   if (_index>=isize) and (not atleast(_index)) then goto skipend;
   //count
   if (_index>=icount) then icount:=_index+1;
   //set
   if (items[_index]<>nil) then
      begin
      items[_index].clear;
      if (_value<>nil) then items[_index].add(_value);
      end;
   end;
skipend:
except;end;
try;str__uaf(@_value);except;end;
end;
//## getsvalue ##
function tdynamicstr8.getsvalue(_index:longint):tstr8;
begin
result:=value[sindex(_index)];
end;
//## setsvalue ##
procedure tdynamicstr8.setsvalue(_index:longint;_value:tstr8);
begin
try;if str__lock(@_value) then value[sindex(_index)].add(_value);except;end;
try;str__uaf(@_value);except;end;
end;
//## find ##
function tdynamicstr8.find(_start:longint;_value:tstr8):longint;
var
   p:longint;
begin
//defaults
result:=-1;
try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;//end of if
except;end;
end;

//## tdynamicstr9 ##############################################################
//## create ##
constructor tdynamicstr9.create;//17feb2024
begin
track__inc(satDynstr9,1);
ifallback:=str__new9;
ilist:=tintlist.create;
inherited create;
end;
//## destroy ##
destructor tdynamicstr9.destroy;
begin
try
clear;
str__free(@ifallback);
freeobj(@ilist);
inherited destroy;
track__inc(satDynstr9,-1);
except;end;
end;
//## clear ##
procedure tdynamicstr9.clear;
begin
count:=0;
end;
//## mem ##
function tdynamicstr9.mem:longint;
var
   p:longint;
begin
result:=ilist.mem;

try
if (count>=1) then
   begin
   for p:=0 to (count-1) do if (ilist.ptr[p]<>nil) then inc(result,tstr9(ilist.ptr[p]).mem);
   end;
except;end;
end;
//## getcount ##
function tdynamicstr9.getcount:longint;
begin
result:=ilist.count;
end;
//## xfreeitem ##
procedure tdynamicstr9.xfreeitem(x:pointer);//works - 23feb2024
var
   a:tstr9;
begin
try
if pok(x) then
   begin
   a:=tstr9(x);
   freeobj(@a);
   end;
except;end;
end;
//## setcount ##
procedure tdynamicstr9.setcount(xnewcount:longint);
var
   a:pointer;
   p:longint;
begin
try
//range
xnewcount:=frcrange32(xnewcount,0,ilist.limit);

//fallback flush
if (ifallback.len>=1) then ifallback.clear;

//delete slot content
if (xnewcount<count) then
   begin
   for p:=(count-1) downto xnewcount do if (ilist.ptr[p]<>nil) then
      begin
      a:=ilist.ptr[p];
      ilist.ptr[p]:=nil;//set to nil first then free the object
      xfreeitem(a);
      end;
   end;

//list
ilist.count:=xnewcount;
except;end;
end;
//## getvalue ##
function tdynamicstr9.getvalue(x:longint):tstr9;//allows nil to be returned
begin
result:=nil;

if (x>=0) and (x<ilist.count) then
   begin
   result:=tstr9(ilist.ptr[x]);
   if (result=nil) then
      begin
      result:=str__new9;//auto create
      ilist.ptr[x]:=result;
      end;
   end;
//fallback
if (result=nil) then
   begin
   if (ifallback.len<>0) then ifallback.clear;
   result:=ifallback;
   end;
end;
//## setvalue ##
procedure tdynamicstr9.setvalue(x:longint;xval:tstr9);
var
   a:pointer;
begin
//get
if (x>=0) and ((x<ilist.count) or ilist.mincount(x+1)) and ((xval=nil) or (xval is tstr9)) and (tstr9(ilist.ptr[x])<>xval) then
   begin
   if (ilist.ptr[x]<>nil) then
      begin
      a:=ilist.ptr[x];
      xfreeitem(@a);
      end;
   ilist.ptr[x]:=xval;
   end;
end;

//## tstr8 #####################################################################
//## create ##
constructor tstr8.create(xlen:longint);
begin
track__inc(satStr8,1);
inherited create;
otestlock1:=false;
oautofree:=false;
ilockcount:=0;
idata:=nil;
idatalen:=0;
icount:=0;
ibytes :=idata;
ichars :=idata;
iints4 :=idata;
irows8 :=idata;
irows15:=idata;
irows16:=idata;
irows24:=idata;
irows32:=idata;
tag1:=0;
tag2:=0;
tag3:=0;
tag4:=0;
xresize(xlen,true);
end;
//## destroy ##
destructor tstr8.destroy;
begin
try
mem__freemem(idata,idatalen,8021);
inherited destroy;
track__inc(satStr8,-1);
except;end;
end;
//## splice ##
function tstr8.splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;//25feb2024
begin
//defaults
result:=false;
xoutmem:=nil;
xoutlen:=0;

//check
if (xpos<0) or (xpos>=icount) or (xlen<=0) or (idata=nil) then exit;

//get
xoutmem:=pointer(cardinal(idata)+xpos);
xoutlen:=icount-xpos;
if (xoutlen>xlen) then xoutlen:=xlen;
//successful
result:=(xoutmem<>nil) and (xoutlen>=1);
end;
//## copyfrom ##
function tstr8.copyfrom(s:tstr8):boolean;//09feb2022
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
if (s=nil) or (not str__lock(@s)) then exit;
//clear
clear;
//get
oautofree:=s.oautofree;
otestlock1:=s.otestlock1;
add(s);
except;end;
try;str__uaf(@s);except;end;
end;
//## maplist ##
function tstr8.maplist:tlistptr;//26apr2021, 07apr2021
begin
try
result.count:=len;
result.bytes:=idata;
//was: result.bytes:=@idata^;
//was: result.bytes:=idata;
//was: result.bytes:=@core^;
//was: result.bytes:=core;//<-- Not sure if this caused the intermittent CRASHING of Gossamer, duplicate fix at "low__maplist2"
except;end;
end;
//## lock ##
procedure tstr8.lock;
begin
try;inc(ilockcount);except;end;
end;
//## unlock ##
procedure tstr8.unlock;
begin
try;ilockcount:=frcmin32(ilockcount-1,0);except;end;
end;
//## writeto1 ##
function tstr8.writeto1(a:pointer;asize,xfrom1,xlen:longint):boolean;
begin
result:=writeto(a,asize,xfrom1-1,xlen);
end;
//## writeto1b ##
function tstr8.writeto1b(a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
begin
result:=false;
try
xlen:=frcrange32(xlen,0,frcmin32(asize,0));//fixed - 22may2022
result:=writeto(a,asize,xfrom1-1,xlen);
if result then inc(xfrom1,xlen)
except;end;
end;
//## writeto ##
function tstr8.writeto(a:pointer;asize,xfrom0,xlen:longint):boolean;//28jul2021
var
   sp,slen,p:longint;
   b:pdlBYTE;
   v:byte;
begin
//defaults
result:=false;
try
//check
if (a=nil) then exit;
//init
slen:=len;//our length
fillchar(a^,asize,0);
b:=a;
xlen:=frcmax32(xlen,asize);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;
//get
sp:=xfrom0;
for p:=0 to (xlen-1) do
begin
if (sp>=0) then
   begin
   //was: if (sp<slen) then b[p]:=pbytes[sp] else break;
   //faster - 22apr2022
   if (sp<slen) then
      begin
      v:=pbytes[sp];
      b[p]:=v;
      end
   else break;
   end;
inc(sp);
end;
//successful
result:=true;
except;end;
end;
//## setbdata ##
procedure tstr8.setbdata(x:tstr8);//27apr2021
begin
try;clear;add(x);except;end;
end;
//## setbappend ##
procedure tstr8.setbappend(x:tstr8);//27apr2021
begin
try;add(x);except;end;
end;
//## getbdata ##
function tstr8.getbdata:tstr8;//27apr2021, 28jan2021
begin
result:=nil;
try
result:=str__new8;
result.add(self);
result.oautofree:=true;
except;end;
end;
//## datpush ##
function tstr8.datpush(n:longint;x:tstr8):boolean;//27jun2022
begin
result:=false;
try
addint4(n);
if str__lock(@x) then result:=addint4(x.len) and add(x) else result:=addint4(0);
except;end;
try;str__uaf(@x);except;end;
end;
//## datpull ##
function tstr8.datpull(var xpos,n:longint;x:tstr8):boolean;//27jun2022
label
   skipend;
var
   int1,xlen:longint;
begin
result:=false;
try
n:=-1;
//range
if (xpos<0) then xpos:=0;
//check
if str__lock(@x) then x.clear;
if ((xpos+7)>=icount) then goto skipend;
//get
n   :=int4[xpos]; inc(xpos,4);
xlen:=int4[xpos]; inc(xpos,4);
int1:=xpos;
inc(xpos,xlen);//inc over data EVEN if an error occurs - 27jun2022
//.read data
if (xlen>=1) and (x<>nil) then x.add3(self,int1,xlen);
//successful
result:=true;
skipend:
except;end;
try;str__unlockautofree(@x);except;end;
end;
//## empty ##
function tstr8.empty:boolean;
begin
result:=(icount<=0);
end;
//## notempty ##
function tstr8.notempty:boolean;
begin
result:=(icount>=1);
end;
//## uppercase ##
function tstr8.uppercase:boolean;
begin
result:=uppercase1(1,len);
end;
//## uppercase1 ##
function tstr8.uppercase1(xpos1,xlen:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;
try
xlen:=frcmax32(xlen,len);
//get
if (xpos1>=1) and (xpos1<=xlen) and (xlen>=1) and (ibytes<>nil) then
   begin
   for p:=xpos1 to xlen do if (ibytes[p-1]>=97) and (ibytes[p-1]<=122) then
      begin
      ibytes[p-1]:=byte(ibytes[p-1]-32);
      result:=true;
      end;//p
   end;
except;end;
end;
//## lowercase ##
function tstr8.lowercase:boolean;
begin
result:=lowercase1(1,len);
end;
//## uppercase1 ##
function tstr8.lowercase1(xpos1,xlen:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;
try
xlen:=frcmax32(xlen,len);
//get
if (xpos1>=1) and (xpos1<=xlen) and (xlen>=1) and (ibytes<>nil) then
   begin
   for p:=xpos1 to xlen do if (ibytes[p-1]>=65) and (ibytes[p-1]<=90) then
      begin
      ibytes[p-1]:=byte(ibytes[p-1]+32);
      result:=true;
      end;//p
   end;
except;end;
end;
//## swap ##
function tstr8.swap(s:tstr8):boolean;//27dec2021
var
   t:tstr8;
begin
//defaults
result:=false;
try
t:=nil;
//check
if not str__lock(@s) then exit;
//init
t:=str__new8;
//self -> t
t.add(self);
//s -> self
clear;
add(s);
//t -> s
s.clear;
s.add(t);
//successful
result:=true;
except;end;
try;str__uaf(@s);except;end;
end;
//## same ##
function tstr8.same(var x:tstr8):boolean;
begin
result:=same2(0,x);
end;
//## same2 ##
function tstr8.same2(xfrom:longint;var x:tstr8):boolean;
label
   skipend;
var
   i,p:longint;
begin
//defaults
result:=false;
try
//check
if (x=idata) then
   begin
   result:=true;
   exit;
   end;
//get
if str__lock(@x) then
   begin
   //init
   if (xfrom<0) then xfrom:=0;
   //get
   if (x.count>=1) and (x.pbytes<>nil) then
      begin
      //check
      if (ibytes=nil) then goto skipend;
      //get
      for p:=0 to (x.count-1) do
      begin
      i:=xfrom+p;
      if (i>=icount) or (ibytes[i]<>x.pbytes[p]) then goto skipend;
      end;//p
      end;
   //successful
   result:=true;
   end;
skipend:
except;end;
try;str__uaf(@x);except;end;
end;
//## asame ##
function tstr8.asame(x:array of byte):boolean;
begin
result:=false;try;result:=asame3(0,x,true);except;end;
end;
//## asame2 ##
function tstr8.asame2(xfrom:longint;x:array of byte):boolean;
begin
result:=false;try;result:=asame3(xfrom,x,true);except;end;
end;
//## asame3 ##
function tstr8.asame3(xfrom:longint;x:array of byte;xcasesensitive:boolean):boolean;
begin
result:=false;try;result:=asame4(xfrom,low(x),high(x),x,xcasesensitive);except;end;
end;
//## asame4 ##
function tstr8.asame4(xfrom,xmin,xmax:longint;var x:array of byte;xcasesensitive:boolean):boolean;
label
   skipend;
var
   i,p:longint;
   sv,v:byte;
begin
result:=false;
try
//check
if (sizeof(x)=0) or (ibytes=nil) then exit;
//range
if (xfrom<0) then xfrom:=0;
//init
xmin:=frcrange32(xmin,low(x),high(x));
xmax:=frcrange32(xmax,low(x),high(x));
if (xmin>xmax) then exit;
//get
for p:=xmin to xmax do
begin
i:=xfrom+(p-xmin);
if (i>=icount) or (i<0) then goto skipend//22aug2020
else if xcasesensitive and (x[p]<>ibytes[i]) then goto skipend
else
   begin
   sv:=x[p];
   v:=ibytes[i];
   if (sv>=65) and (sv<=90) then inc(sv,32);
   if (v>=65)  and (v<=90)  then inc(v,32);
   if (sv<>v) then goto skipend;
   end;
end;//p
//successful
result:=true;
skipend:
except;end;
end;
//## xresize ##
function tstr8.xresize(x:longint;xsetcount:boolean):boolean;
var
   xnew,xold:longint;
begin
//defaults
result:=false;
try
//init
xnew:=frcrange32(x,0,max32);
xold:=frcrange32(idatalen,0,max32);
//get
if (xnew<>xold) then
   begin
   //debug check
   //if system_debug and otestlock1 and (system_debug_testlock1<>0) then showerror('Lock 1 violation [001]');//debug purposes only - 09may2021
   //get
   if not mem__reallocmem(idata,xold,xnew,2) then xnew:=xold;//revert back to previous size if allocation fails - 27apr2021
   idatalen:=xnew;
   ibytes:=idata;
   ichars:=idata;
   iints4 :=idata;
   irows8 :=idata;
   irows15:=idata;
   irows16:=idata;
   irows24:=idata;
   irows32:=idata;
   end;
//sync
if xsetcount then icount:=xnew else icount:=frcrange32(icount,0,xnew);
//successful
result:=true;//27apr2021
except;end;
end;
//## clear ##
function tstr8.clear:boolean;
begin
result:=setlen(0);
end;
//## setcount ##
procedure tstr8.setcount(x:longint);//07dec2023
begin
icount:=frcrange32(x,0,idatalen);
end;
//## setlen ##
function tstr8.setlen(x:longint):boolean;
begin
result:=xresize(x,true);
end;
//## minlen ##
function tstr8.minlen(x:longint):boolean;//atleast this length
var
   int1:longint;
begin
//defaults
result:=false;
try
//get
x:=frcrange32(x,0,max32);
if (x>idatalen) then
   begin
   case largest(idatalen,x) of
   0..100      :int1:=100;//100b
   101..1000   :int1:=1000;//1K
   1001..10000 :int1:=10000;//10K - 11jan2022
   10001..100000:int1:=100000;//100K
{
   0..100      :int1:=100;//100b
   101..1000   :int1:=1000;//1K
   1001..100000:int1:=100000;//100K
{}
   else         int1:=1000000;//1M
   end;//case
   result:=xresize(x+int1,false);//requested len + some more for extra speed - 29apr2020
   end
else result:=true;//27apr2021
except;end;
end;
//## fill ##
function tstr8.fill(xfrom,xto:longint;xval:byte):boolean;
var
   p:longint;
begin
result:=(ibytes<>nil);
try
if result and (xfrom<=xto) and (icount>=1) and frcrange2(xfrom,0,icount-1) and frcrange2(xto,xfrom,icount-1) then
   begin
   for p:=xfrom to xto do ibytes[p]:=xval;
   end;
except;end;
end;
//## del3 ##
function tstr8.del3(xfrom,xlen:longint):boolean;//27jan2021
begin
result:=del(xfrom,xfrom+xlen-1);
end;
//## del ##
function tstr8.del(xfrom,xto:longint):boolean;//27apr2021
var
   p,int1:longint;
   v:byte;
begin
//defaults
result:=true;//pass-thru
try
//check
if (icount<=0) or (xfrom>xto) or (xto<0) or (xfrom>=icount) then exit;
//get
if frcrange2(xfrom,0,icount-1) and frcrange2(xto,xfrom,icount-1) then
   begin
   //shift down
   int1:=xto+1;
   //was: if (int1<icount) and (ibytes<>nil) then for p:=int1 to (icount-1) do ibytes[xfrom+p-int1]:=ibytes[p];
   if (int1<icount) and (ibytes<>nil) then
      begin
      //assigning value using "v" SPEEDS things up - 22apr2022
      for p:=int1 to (icount-1) do
      begin
      v:=ibytes[p];
      ibytes[xfrom+p-int1]:=v;
      end;//p
      end;
   //resize
   result:=xresize(icount-(xto-xfrom+1),true);//27apr2021
   end;
except;end;
end;
//object support ---------------------------------------------------------------
//## add ##
function tstr8.add(var x:tstr8):boolean;//27apr2021
begin
result:=ins2(x,icount,0,max32);
end;
//## addb ##
function tstr8.addb(x:tstr8):boolean;
begin
result:=add(x);
end;
//## add2 ##
function tstr8.add2(var x:tstr8;xfrom,xto:longint):boolean;//27apr2021
begin
result:=ins2(x,icount,xfrom,xto);
end;
//## add3 ##
function tstr8.add3(var x:tstr8;xfrom,xlen:longint):boolean;//27apr2021
begin
if (xlen>=1) then result:=ins2(x,icount,xfrom,xfrom+xlen-1) else result:=true;
end;
//## add31 ##
function tstr8.add31(var x:tstr8;xfrom1,xlen:longint):boolean;//28jul2021
begin
if (xlen>=1) then result:=ins2(x,icount,(xfrom1-1),(xfrom1-1)+xlen-1) else result:=true;
end;
//## ins ##
function tstr8.ins(var x:tstr8;xpos:longint):boolean;//27apr2021
begin
result:=ins2(x,xpos,0,max32);
end;
//## ins2 ##
function tstr8.ins2(var x:tstr8;xpos,xfrom,xto:longint):boolean;//22apr2022, 27apr2021, 26apr2021
begin
result:=_ins2(@x,xpos,xfrom,xto);
end;
//## _ins2 ##
function tstr8._ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//08feb2024: tstr9 support, 22apr2022, 27apr2021, 26apr2021
label
   skipend;
var
   smin,smax,dcount,p,int1:longint;
   smem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try
//check
if (not str__ok(x)) or (x=@self) then
   begin
   result:=true;
   exit;
   end;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
//check
int1:=str__len(x);
if (int1=0) then//06jul2021
   begin
   result:=true;
   goto skipend;
   end;
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then goto skipend;
//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dcount:=icount+(xto-xfrom+1);//always means to increase the size - 26apr2021
//check
if not minlen(dcount) then goto skipend;//27apr2021
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //assigning value indirectly using "v" SPEEDS things up drastically - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x.pbytes[p];
   //assigning value indirectly using "v" SPEEDS things up drastically - 22apr2022
   if (x^ is tstr8) then
      begin
      for p:=xfrom to xto do
      begin
      v:=(x^ as tstr8).pbytes[p];
      ibytes[xpos+p-xfrom]:=v;
      end;//p
      end
   else if (x^ is tstr9) then
      begin
      smax:=-2;
      for p:=xfrom to xto do
      begin
      if (p>smax) and (not block__fastinfo(x,p,smem,smin,smax)) then goto skipend;
      v:=smem[p-smin];
      ibytes[xpos+p-xfrom]:=v;
      end;//p
      end;
   end;
icount:=dcount;
//successful
result:=true;
skipend:
except;end;
try;str__autofree(x);except;end;
end;
//## owr ##
function tstr8.owr(var x:tstr8;xpos:longint):boolean;//overwrite -> enlarge if required - 27apr2021, 01oct2020
begin
result:=owr2(x,xpos,0,max32);
end;
//## owr2 ##
function tstr8.owr2(var x:tstr8;xpos,xfrom,xto:longint):boolean;//22apr2022
label
   skipend;
var
   dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;
try
//check
if zznil(x,2251) or (x=idata) then
   begin
   result:=true;
   exit;
   end;
//init
xpos:=frcmin32(xpos,0);
//check
int1:=x.count;
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then
   begin
   result:=true;//27apr2021
   goto skipend;
   end;
//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dcount:=xpos+(xto-xfrom+1);
//check
if not minlen(dcount) then goto skipend;
//copy + size
if (ibytes<>nil) and (x.pbytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x.pbytes[p];
   //local var "v" makes things FASTER - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=x.pbytes[p];
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=largest(dcount,icount);
//successful
result:=true;
skipend:
except;end;
try;str__autofree(@x);except;end;
end;
//array support ----------------------------------------------------------------
//## aadd ##
function tstr8.aadd(x:array of byte):boolean;//27apr2021
begin
result:=ains2(x,icount,0,max32);
end;
//## aadd1 ##
function tstr8.aadd1(x:array of byte;xpos1,xlen:longint):boolean;//1based - 27apr2021, 19aug2020
begin
result:=ains2(x,icount,xpos1-1,xpos1-1+xlen);
end;
//## aadd2 ##
function tstr8.aadd2(x:array of byte;xfrom,xto:longint):boolean;//27apr2021
begin
result:=ains2(x,icount,xfrom,xto);
end;
//## ains ##
function tstr8.ains(x:array of byte;xpos:longint):boolean;//27apr2021
begin
result:=ains2(x,xpos,0,max32);
end;
//## ains2 ##
function tstr8.ains2(x:array of byte;xpos,xfrom,xto:longint):boolean;//26apr2021
var
   dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;
try
//check
if (xto<xfrom) then exit;
//range
xfrom:=frcrange32(xfrom,low(x),high(x));
xto  :=frcrange32(xto  ,low(x),high(x));
if (xto<xfrom) then exit;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
dcount:=icount+(xto-xfrom+1);
minlen(dcount);
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //faster - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x[p];
   //faster - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=x[p];
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=dcount;
//successful
result:=true;
except;end;
end;
//## padd ##
function tstr8.padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
begin
if (xsize<=0) then result:=true else result:=pins2(x,xsize,icount,0,xsize-1);
end;
//## pins2 ##
function tstr8.pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;//07feb2022
var
   dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;
try
//check
if (x=nil) or (xcount<=0) then
   begin
   result:=true;
   exit;
   end;
if (xto<xfrom) then exit;
//range
xfrom:=frcrange32(xfrom,0,xcount-1);
xto  :=frcrange32(xto  ,0,xcount-1);
if (xto<xfrom) then exit;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
dcount:=icount+(xto-xfrom+1);
minlen(dcount);
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //faster - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x[p];
   //faster - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=x[p];
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=dcount;
//successful
result:=true;
except;end;
end;
//## insbyt1 ##
function tstr8.insbyt1(xval:byte;xpos:longint):boolean;
begin
result:=ains2([xval],xpos,0,0);
end;
//## insbol1 ##
function tstr8.insbol1(xval:boolean;xpos:longint):boolean;
begin
if xval then result:=ains2([1],xpos,0,0) else result:=ains2([0],xpos,0,0);
end;
//## insint4 ##
function tstr8.insint4(xval,xpos:longint):boolean;
var
   a:tint4;
begin
a.val:=xval;result:=ains2([a.bytes[0],a.bytes[1],a.bytes[2],a.bytes[3]],xpos,0,3);
end;
//string support ---------------------------------------------------------------
//## sadd ##
function tstr8.sadd(var x:string):boolean;//26dec2023, 27apr2021
begin
result:=sins2(x,icount,0,max32);
end;
//## sadd2 ##
function tstr8.sadd2(var x:string;xfrom,xto:longint):boolean;//26dec2023, 27apr2021
begin
result:=sins2(x,icount,xfrom,xto);
end;
//## sadd3 ##
function tstr8.sadd3(var x:string;xfrom,xlen:longint):boolean;//26dec2023, 27apr2021
begin
if (xlen>=1) then result:=sins2(x,icount,xfrom,xfrom+xlen-1) else result:=true;
end;
//## saddb ##
function tstr8.saddb(x:string):boolean;//27apr2021
begin
result:=false;try;result:=sins2(x,icount,0,max32);except;end;
end;
//## sadd2b ##
function tstr8.sadd2b(x:string;xfrom,xto:longint):boolean;//27apr2021
begin
result:=false;try;result:=sins2(x,icount,xfrom,xto);except;end;
end;
//## sadd3b ##
function tstr8.sadd3b(x:string;xfrom,xlen:longint):boolean;//27apr2021
begin
result:=false;try;if (xlen>=1) then result:=sins2(x,icount,xfrom,xfrom+xlen-1) else result:=true;except;end;
end;
//## sins ##
function tstr8.sins(var x:string;xpos:longint):boolean;//27apr2021
begin
result:=sins2(x,xpos,0,max32);
end;
//## sinsb ##
function tstr8.sinsb(x:string;xpos:longint):boolean;//27apr2021
begin
result:=false;try;result:=sins2(x,xpos,0,max32);except;end;
end;
//## sins2b ##
function tstr8.sins2b(x:string;xpos,xfrom,xto:longint):boolean;
begin
result:=false;try;result:=sins2(x,xpos,xfrom,xto);except;end;
end;
//## sins2 ##
function tstr8.sins2(var x:string;xpos,xfrom,xto:longint):boolean;
label
   skipend;
var//Always zero based for "xfrom" and "xto"
   xlen,dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;
try
//check
xlen:=length(x);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;
//check #2
if (xto<xfrom) then exit;//27apr2021
//range
xfrom:=frcrange32(xfrom,0,xlen-1);
xto  :=frcrange32(xto  ,0,xlen-1);
if (xto<xfrom) then exit;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
dcount:=icount+(xto-xfrom+1);
//check
if not minlen(dcount) then goto skipend;
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //faster - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];;
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=byte(x[p+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
   //faster - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=byte(x[p+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=dcount;
//successful
result:=true;
skipend:
except;end;
end;
//push support -----------------------------------------------------------------
//## pushcmp8 ##
function tstr8.pushcmp8(var xpos:longint;xval:comp):boolean;
begin
result:=ains(tcmp8(xval).bytes,xpos);
if result then inc(xpos,8);
end;
//## pushcur8 ##
function tstr8.pushcur8(var xpos:longint;xval:currency):boolean;
begin
result:=ains(tcur8(xval).bytes,xpos);
if result then inc(xpos,8);
end;
//## pushint4 ##
function tstr8.pushint4(var xpos:longint;xval:longint):boolean;
begin
result:=ains(tint4(xval).bytes,xpos);
if result then inc(xpos,4);
end;
//## pushint4R ##
function tstr8.pushint4R(var xpos:longint;xval:longint):boolean;
begin
xval:=low__intr(xval);//swap round
result:=ains(tint4(xval).bytes,xpos);
if result then inc(xpos,4);
end;
//## pushint3 ##
function tstr8.pushint3(var xpos:longint;xval:longint):boolean;
var
   r,g,b:byte;
begin
low__int3toRGB(xval,r,g,b);
result:=ains([r,g,b],xpos);
if result then inc(xpos,3);
end;
//## pushwrd2 ##
function tstr8.pushwrd2(var xpos:longint;xval:word):boolean;
begin
result:=ains(twrd2(xval).bytes,xpos);
if result then inc(xpos,2);
end;
//## pushwrd2R ##
function tstr8.pushwrd2R(var xpos:longint;xval:word):boolean;
begin
xval:=low__wrdr(xval);
result:=ains(twrd2(xval).bytes,xpos);
if result then inc(xpos,2);
end;
//## pushbyt1 ##
function tstr8.pushbyt1(var xpos:longint;xval:byte):boolean;
begin
result:=ains([xval],xpos);
if result then inc(xpos,1);
end;
//## pushbol1 ##
function tstr8.pushbol1(var xpos:longint;xval:boolean):boolean;
begin
if xval then result:=ains([1],xpos) else result:=ains([0],xpos);
if result then inc(xpos,1);
end;
//## pushchr1 ##
function tstr8.pushchr1(var xpos:longint;xval:char):boolean;
begin
result:=ains([byte(xval)],xpos);
if result then inc(xpos,1);
end;
//## pushstr ##
function tstr8.pushstr(var xpos:longint;xval:string):boolean;
begin
result:=false;
try
result:=sins(xval,xpos);
if result then inc(xpos,length(xval));
except;end;
end;
//add support ------------------------------------------------------------------
//## addcmp8 ##
function tstr8.addcmp8(xval:comp):boolean;
begin
result:=aadd(tcmp8(xval).bytes);
end;
//## addcur8 ##
function tstr8.addcur8(xval:currency):boolean;
begin
result:=aadd(tcur8(xval).bytes);
end;
//## addRGBA4 ##
function tstr8.addRGBA4(r,g,b,a:byte):boolean;
begin
result:=aadd([r,g,b,a]);
end;
//## addRGB3 ##
function tstr8.addRGB3(r,g,b:byte):boolean;
begin
result:=aadd([r,g,b]);
end;
//## addint4 ##
function tstr8.addint4(xval:longint):boolean;
begin
result:=aadd(tint4(xval).bytes);
end;
//## addint4R ##
function tstr8.addint4R(xval:longint):boolean;
begin
xval:=low__intr(xval);//swap round
result:=aadd(tint4(xval).bytes);
end;
//## addint3 ##
function tstr8.addint3(xval:longint):boolean;
var
   r,g,b:byte;
begin
low__int3toRGB(xval,r,g,b);
result:=aadd([r,g,b]);
end;
//## addwrd2 ##
function tstr8.addwrd2(xval:word):boolean;
begin
result:=aadd(twrd2(xval).bytes);//16aug2020
end;
//## addwrd2R ##
function tstr8.addwrd2R(xval:word):boolean;
begin
xval:=low__wrdr(xval);//swap round
result:=aadd(twrd2(xval).bytes);//16aug2020
end;
//## addsmi2 ##
function tstr8.addsmi2(xval:smallint):boolean;//01aug2021
var
   a:twrd2;
begin
a.si:=xval;
result:=aadd([a.bytes[0],a.bytes[1]]);
end;
//## addbyt1 ##
function tstr8.addbyt1(xval:byte):boolean;
begin
result:=aadd([xval]);
end;
//## addbol1 ##
function tstr8.addbol1(xval:boolean):boolean;//21aug2020
begin
if xval then result:=aadd([1]) else result:=aadd([0]);
end;
//## addchr1 ##
function tstr8.addchr1(xval:char):boolean;
begin
result:=aadd([byte(xval)]);
end;
//## addstr ##
function tstr8.addstr(xval:string):boolean;
begin
result:=false;try;result:=sadd(xval);except;end;
end;
//## addrec ##
function tstr8.addrec(a:pointer;asize:longint):boolean;//07feb2022
begin
result:=pins2(pdlbyte(a),asize,icount,0,asize-1);
end;
//get support ------------------------------------------------------------------
//## getcmp8 ##
function tstr8.getcmp8(xpos:longint):comp;
var
   a:tcmp8;
begin
if (xpos>=0) and ((xpos+7)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   a.bytes[2]:=ibytes[xpos+2];
   a.bytes[3]:=ibytes[xpos+3];
   a.bytes[4]:=ibytes[xpos+4];
   a.bytes[5]:=ibytes[xpos+5];
   a.bytes[6]:=ibytes[xpos+6];
   a.bytes[7]:=ibytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;
//## getcur8 ##
function tstr8.getcur8(xpos:longint):currency;
var
   a:tcur8;
begin
if (xpos>=0) and ((xpos+7)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   a.bytes[2]:=ibytes[xpos+2];
   a.bytes[3]:=ibytes[xpos+3];
   a.bytes[4]:=ibytes[xpos+4];
   a.bytes[5]:=ibytes[xpos+5];
   a.bytes[6]:=ibytes[xpos+6];
   a.bytes[7]:=ibytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;
//## getint4 ##
function tstr8.getint4(xpos:longint):longint;
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   a.bytes[2]:=ibytes[xpos+2];
   a.bytes[3]:=ibytes[xpos+3];
   result:=a.val;
   end
else result:=0;
end;
//## getint4i ##
function tstr8.getint4i(xindex:longint):longint;
begin
result:=getint4(xindex*4);
end;
//## getint4R ##
function tstr8.getint4R(xpos:longint):longint;//14feb2021
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+3];//swap round
   a.bytes[1]:=ibytes[xpos+2];
   a.bytes[2]:=ibytes[xpos+1];
   a.bytes[3]:=ibytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;
//## getint3 ##
function tstr8.getint3(xpos:longint):longint;
begin
if (xpos>=0) and ((xpos+2)<icount) and (ibytes<>nil) then result:=ibytes[xpos+0]+(ibytes[xpos+1]*256)+(ibytes[xpos+2]*256*256) else result:=0;
end;
//## getsml2 ##
function tstr8.getsml2(xpos:longint):smallint;//28jul2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   result:=a.si;
   end
else result:=0;
end;
//## getwrd2 ##
function tstr8.getwrd2(xpos:longint):word;
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   result:=a.val;
   end
else result:=0;
end;
//## getwrd2R ##
function tstr8.getwrd2R(xpos:longint):word;//14feb2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+1];//swap round
   a.bytes[1]:=ibytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;
//## getbyt1 ##
function tstr8.getbyt1(xpos:longint):byte;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=ibytes[xpos] else result:=0;
end;
//## getbol1 ##
function tstr8.getbol1(xpos:longint):boolean;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=(ibytes[xpos]<>0) else result:=false;
end;
//## getchr1 ##
function tstr8.getchr1(xpos:longint):char;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=char(ibytes[xpos]) else result:=#0;
end;
//## getstr ##
function tstr8.getstr(xpos,xlen:longint):string;//fixed - 16aug2020
var
   dlen,p:longint;
begin
result:='';
try
if (xlen>=1) and (xpos>=0) and (xpos<icount) and (ibytes<>nil) then
   begin
   dlen:=frcmax32(xlen,icount-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      for p:=xpos to (xpos+dlen-1) do result[p-xpos+stroffset]:=char(ibytes[p]);
      end;
   end;
except;end;
end;
//## getstr1 ##
function tstr8.getstr1(xpos,xlen:longint):string;
begin
result:='';try;result:=getstr(xpos-1,xlen);except;end;
end;
//## getnullstr ##
function tstr8.getnullstr(xpos,xlen:longint):string;//20mar2022
var
   dcount,dlen,p:longint;
   v:byte;
begin
result:='';
try
if (xlen>=1) and (xpos>=0) and (xpos<icount) and (ibytes<>nil) then
   begin
   dlen:=frcmax32(xlen,icount-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      dcount:=0;
      for p:=xpos to (xpos+dlen-1) do
      begin
      if (ibytes[p]=0) then
         begin
         if (dcount<>dlen) then low__setlen(result,dcount);
         break;
         end;
      //was: result[p-xpos+stroffset]:=char(ibytes[p]);
      v:=ibytes[p];
      result[p-xpos+stroffset]:=char(v);
      inc(dcount);
      end;//p
      end;
   end;
except;end;
end;
//## getnullstr1 ##
function tstr8.getnullstr1(xpos,xlen:longint):string;//20mar2022
begin
result:='';try;result:=getnullstr(xpos-1,xlen);except;end;
end;
//## gettext ##
function tstr8.gettext:string;
var
   p:longint;
   v:byte;
begin
result:='';
try
if (icount>=1) and (ibytes<>nil) then//27apr2021
   begin
   low__setlen(result,icount);
   //was: for p:=0 to (icount-1) do result[p+stroffset]:=char(ibytes[p]);//27apr2021
   //faster - 22apr2022
   for p:=0 to (icount-1) do
   begin
   v:=ibytes[p];
   result[p+stroffset]:=char(v);//27apr2021
   end;//p
   end;
except;end;
end;
//## settext ##
procedure tstr8.settext(x:string);
var
   xlen,p:longint;
   v:byte;
begin
try
xlen:=length(x);
setlen(xlen);
if (xlen>=1) and (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=1 to xlen do ibytes[p-1]:=byte(x[p-1+stroffset]);//force 8bit conversion
   //faster - 22apr2022
   for p:=1 to xlen do
   begin
   v:=byte(x[p-1+stroffset]);
   ibytes[p-1]:=v;//force 8bit conversion
   end;//p
   end;
except;end;
end;
//## gettextarray ##
function tstr8.gettextarray:string;
label
   skipend;
var
   a,aline:tstr8;
   xmax,p:longint;
begin
//defaults
result:='';
try
a:=nil;
aline:=nil;
//check
if (icount<=0) or (ibytes=nil) then goto skipend;
//init
a:=str__new8;
aline:=str__new8;
xmax:=icount-1;
//get
for p:=0 to xmax do
begin
aline.saddb(inttostr(ibytes[p])+insstr(',',p<xmax));
if (aline.count>=1010) then
   begin
   aline.saddb(rcode);
   a.add(aline);
   aline.clear;
   end;
end;//p
//.finalise
if (aline.count>=1) then
   begin
   a.add(aline);
   aline.clear;
   end;
//set
result:=':array[0..'+inttostr(icount-1)+'] of byte=('+rcode+a.text+');';//cleaned 02mar2022
skipend:
except;end;
try
str__free(@a);
str__free(@aline);
except;end;
end;
//set support ------------------------------------------------------------------
//## setcmp8 ##
procedure tstr8.setcmp8(xpos:longint;xval:comp);
var
   a:tcmp8;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+8)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
ibytes[xpos+2]:=a.bytes[2];
ibytes[xpos+3]:=a.bytes[3];
ibytes[xpos+4]:=a.bytes[4];
ibytes[xpos+5]:=a.bytes[5];
ibytes[xpos+6]:=a.bytes[6];
ibytes[xpos+7]:=a.bytes[7];
icount:=frcmin32(icount,xpos+8);//10may2020
except;end;
end;
//## setcur8 ##
procedure tstr8.setcur8(xpos:longint;xval:currency);
var
   a:tcur8;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+8)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
ibytes[xpos+2]:=a.bytes[2];
ibytes[xpos+3]:=a.bytes[3];
ibytes[xpos+4]:=a.bytes[4];
ibytes[xpos+5]:=a.bytes[5];
ibytes[xpos+6]:=a.bytes[6];
ibytes[xpos+7]:=a.bytes[7];
icount:=frcmin32(icount,xpos+8);//10may2020
except;end;
end;
//## setint4 ##
procedure tstr8.setint4(xpos:longint;xval:longint);
var
   a:tint4;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+4)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
ibytes[xpos+2]:=a.bytes[2];
ibytes[xpos+3]:=a.bytes[3];
icount:=frcmin32(icount,xpos+4);//10may2020
except;end;
end;
//## setint4i ##
procedure tstr8.setint4i(xindex:longint;xval:longint);
begin
try;setint4(xindex*4,xval);except;end;
end;
//## setint4R ##
procedure tstr8.setint4R(xpos:longint;xval:longint);
var
   a:tint4;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+4)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[3];//swap round
ibytes[xpos+1]:=a.bytes[2];
ibytes[xpos+2]:=a.bytes[1];
ibytes[xpos+3]:=a.bytes[0];
icount:=frcmin32(icount,xpos+4);//10may2020
except;end;
end;
//## setint3 ##
procedure tstr8.setint3(xpos:longint;xval:longint);
var
   r,g,b:byte;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+3)) or (ibytes=nil) then exit;
low__int3toRGB(xval,r,g,b);
ibytes[xpos+0]:=r;
ibytes[xpos+1]:=g;
ibytes[xpos+2]:=b;
icount:=frcmin32(icount,xpos+3);//10may2020
except;end;
end;
//## setsml2 ##
procedure tstr8.setsml2(xpos:longint;xval:smallint);
var
   a:twrd2;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+2)) or (ibytes=nil) then exit;
a.si:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
icount:=frcmin32(icount,xpos+2);//10may2020
except;end;
end;
//## setwrd2 ##
procedure tstr8.setwrd2(xpos:longint;xval:word);
var
   a:twrd2;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+2)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
icount:=frcmin32(icount,xpos+2);//10may2020
except;end;
end;
//## setwrd2R ##
procedure tstr8.setwrd2R(xpos:longint;xval:word);
var
   a:twrd2;
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+2)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[1];//swap round
ibytes[xpos+1]:=a.bytes[0];
icount:=frcmin32(icount,xpos+2);//10may2020
except;end;
end;
//## setbyt1 ##
procedure tstr8.setbyt1(xpos:longint;xval:byte);
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
ibytes[xpos]:=xval;
icount:=frcmin32(icount,xpos+1);//10may2020
except;end;
end;
//## setbol1 ##
procedure tstr8.setbol1(xpos:longint;xval:boolean);
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
if xval then ibytes[xpos]:=1 else ibytes[xpos]:=0;
icount:=frcmin32(icount,xpos+1);//10may2020
except;end;
end;
//## setchr1 ##
procedure tstr8.setchr1(xpos:longint;xval:char);
begin
try
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
ibytes[xpos]:=byte(xval);
icount:=frcmin32(icount,xpos+1);//10may2020
except;end;
end;
//## setstr ##
procedure tstr8.setstr(xpos:longint;xlen:longint;xval:string);
var
   xminlen,p:longint;
   v:byte;
begin
try
if (xpos<0) then xpos:=0;
if (xlen<=0) or (xval='') then exit;
xlen:=frcmax32(xlen,length(xval));
xminlen:=xpos+xlen;
if (not minlen(xminlen)) or (ibytes=nil) then exit;
//was: ERROR: for p:=xpos to (xpos+xlen-1) do ibytes[p]:=ord(xval[p+stroffset]);
//was: for p:=0 to (xlen-1) do ibytes[xpos+p]:=ord(xval[p+stroffset]);
for p:=0 to (xlen-1) do
begin
v:=ord(xval[p+stroffset]);
ibytes[xpos+p]:=v;
end;//p
icount:=frcmin32(icount,xminlen);//10may2020
except;end;
end;
//## setstr1 ##
procedure tstr8.setstr1(xpos:longint;xlen:longint;xval:string);
begin
try;setstr(xpos-1,xlen,xval);except;end;
end;
//## setarray ##
function tstr8.setarray(xpos:longint;xval:array of byte):boolean;
var
   xminlen,xmin,xmax,p:longint;
   v:byte;
begin
//defaults
result:=false;
try
//get
if (xpos<0) then xpos:=0;
xmin:=low(xval);
xmax:=high(xval);
xminlen:=xpos+(xmax-xmin+1);
if (not minlen(xminlen)) or (ibytes=nil) then exit;
//was: for p:=xmin to xmax do ibytes[xpos+(p-xmin)]:=xval[p];
for p:=xmin to xmax do
begin
v:=xval[p];
ibytes[xpos+(p-xmin)]:=v;
end;//p
icount:=frcmin32(icount,xminlen);//10may2020
//successful
result:=true;
except;end;
end;
//## scanline ##
function tstr8.scanline(xfrom:longint):pointer;
begin
//defaults
result:=nil;
try
if (icount<=0) then exit;
//get
if (xfrom<0) then xfrom:=0 else if (xfrom>=icount) then xfrom:=icount-1;
if (ibytes<>nil) then result:=tpointer(@ibytes[xfrom]);
except;end;
end;
//## getbytes ##
function tstr8.getbytes(x:longint):byte;//0-based
begin
result:=0;try;if (x>=0) and (x<icount) and (ibytes<>nil) then result:=ibytes[x];except;end;
end;
//## setbytes ##
procedure tstr8.setbytes(x:longint;xval:byte);
begin
try;if (x>=0) and (x<icount) and (ibytes<>nil) then ibytes[x]:=xval;except;end;
end;
//## getbytes1 ##
function tstr8.getbytes1(x:longint):byte;//1-based
begin
result:=0;try;if (x>=1) and (x<=icount) and (ibytes<>nil) then result:=ibytes[x-1];except;end;
end;
//## setbytes1 ##
procedure tstr8.setbytes1(x:longint;xval:byte);
begin
try;if (x>=1) and (x<=icount) and (ibytes<>nil) then ibytes[x-1]:=xval;except;end;
end;
//## getchars ##
function tstr8.getchars(x:longint):char;//D10 uses unicode here - 27apr2021
begin
result:=#0;try;if (x>=0) and (x<icount) and (ibytes<>nil) then result:=char(ibytes[x]);except;end;
end;
//## setchars ##
procedure tstr8.setchars(x:longint;xval:char);//D10 uses unicode here
begin
try;if (x>=0) and (x<icount) and (ibytes<>nil) then ibytes[x]:=byte(xval);except;end;
end;

//replace support --------------------------------------------------------------
//## setreplace ##
procedure tstr8.setreplace(x:tstr8);
begin
try;clear;add(x);except;end;
end;
//## setreplacecmp8 ##
procedure tstr8.setreplacecmp8(x:comp);
begin
try;clear;setcmp8(0,x);except;end;
end;
//## setreplacecur8 ##
procedure tstr8.setreplacecur8(x:currency);
begin
try;clear;setcur8(0,x);except;end;
end;
//## setreplaceint4 ##
procedure tstr8.setreplaceint4(x:longint);
begin
try;clear;setint4(0,x);except;end;
end;
//## setreplacewrd2 ##
procedure tstr8.setreplacewrd2(x:word);
begin
try;clear;setwrd2(0,x);except;end;
end;
//## setreplacebyt1 ##
procedure tstr8.setreplacebyt1(x:byte);
begin
try;clear;setbyt1(0,x);except;end;
end;
//## setreplacebol1 ##
procedure tstr8.setreplacebol1(x:boolean);
begin
try;clear;setbol1(0,x);except;end;
end;
//## setreplacechr1 ##
procedure tstr8.setreplacechr1(x:char);
begin
try;clear;setchr1(0,x);except;end;
end;
//## setreplacestr ##
procedure tstr8.setreplacestr(x:string);
begin
try;clear;setstr(0,length(x),x);except;end;
end;

//## tstr9 #####################################################################
//## create ##
constructor tstr9.create(xlen:longint);
begin
track__inc(satStr9,1);
oautofree:=false;
igetmin:=-1;
igetmax:=-2;
ilen:=0;
ilen2:=0;//real length
idatalen:=0;
imem:=0;
iblockcount:=0;
iblocksize:=block__size;
ilockcount:=0;
ilist:=nil;
ilist:=tintlist.create;//tdynamicpointer.create;
ilist.ptr[0]:=nil;//make sure 1st item always exists
inherited create;
tag1:=0;
tag2:=0;
tag3:=0;
tag4:=0;
setlen(xlen);
end;
//## destroy ##
destructor tstr9.destroy;
begin
try
setlen(0);
freeobj(@ilist);
inherited destroy;
track__inc(satStr9,-1);
except;end;
end;
//## empty ##
function tstr9.empty:boolean;
begin
result:=(ilen<=0);
end;
//## notempty ##
function tstr9.notempty:boolean;
begin
result:=(ilen>=1);
end;
//## lock ##
procedure tstr9.lock;
begin
try;inc(ilockcount);except;end;
end;
//## unlock ##
procedure tstr9.unlock;
begin
try;ilockcount:=frcmin32(ilockcount-1,0);except;end;
end;
//## splice ##
function tstr9.splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
var
   xmin,xmax:longint;
begin
//defaults
result:=false;
xoutmem:=nil;
xoutlen:=0;

//check
if (xpos<0) or (xpos>=ilen) or (xlen<=0) then exit;

//get
if fastinfo(xpos,xoutmem,xmin,xmax) then
   begin
   xoutmem:=pointer(cardinal(xoutmem)+xpos-xmin);
   xoutlen:=xmax-xpos+1;
   if (xoutlen>xlen) then xoutlen:=xlen;
   //successful
   result:=(xoutmem<>nil) and (xoutlen>=1);
   end;
end;
//## fastinfo ##
function tstr9.fastinfo(xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;//15feb2024
var
   i:longint;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;
//get
if (xpos>=0) and (xpos<ilen) then
   begin
   //set
   i:=xpos div iblocksize;
   xmem:=ilist.ptr[i];
   xmin:=i*iblocksize;
   xmax:=xmin+iblocksize-1;
   //.limit max for last block using datastream length - 15feb2024
   if (xmax>=ilen) then xmax:=ilen-1;
   //successful
   result:=(xmem<>nil);
   end;
end;
//## fastadd ##
function tstr9.fastadd(var x:array of byte;xsize:longint):longint;
begin
result:=fastwrite(x,xsize,ilen);
end;
//## fastwrite ##
function tstr9.fastwrite(var x:array of byte;xsize,xpos:longint):longint;
label
   skipend;
var
   vmin,vmax,i:longint;
   vmem:pdlbyte;
begin
//defaults
result:=0;

try
//range
if (xpos<0) then xpos:=0;

//check
if (xsize<=0) then goto skipend;

//init
vmin:=-1;
vmax:=-1;

//size
if not minlen(xpos+xsize) then goto skipend;

//get
for i:=0 to (xsize-1) do
begin
if (xpos>vmax) and (not fastinfo(xpos,vmem,vmin,vmax)) then goto skipend;
vmem[xpos-vmin]:=x[i];
//.inc
inc(xpos);
inc(result);
end;//i

skipend:
except;end;
end;
//## fastread ##
function tstr9.fastread(var x:array of byte;xsize,xpos:longint):longint;
label
   skipend;
var
   vmin,vmax,i:longint;
   vmem:pdlbyte;
begin
//defaults
result:=0;
try

//check
if (xsize<=0) or (xpos<0) or (xpos>=ilen) then goto skipend;

//init
vmin:=-1;
vmax:=-1;

//get
for i:=0 to (xsize-1) do
begin
if (xpos>vmax) and (not fastinfo(xpos,vmem,vmin,vmax)) then goto skipend;
if (xpos<ilen) then
   begin
   x[i]:=vmem[xpos-vmin];
   inc(result);
   end
else break;
//.inc
inc(xpos);
end;//i

skipend:
except;end;
end;
//## getv ##
function tstr9.getv(xpos:longint):byte;
begin
if (xpos<=igetmax) and (xpos>=igetmin)         then result:=igetmem[xpos-igetmin]
else if fastinfo(xpos,igetmem,igetmin,igetmax) then result:=igetmem[xpos-igetmin]
else
   begin
   result:=0;
   igetmin:=-1;
   igetmax:=-2;//off
   end;
end;
//## setv ##
procedure tstr9.setv(xpos:longint;v:byte);
begin
if (xpos<=isetmax) and (xpos>=isetmin)         then isetmem[xpos-isetmin]:=v
else if fastinfo(xpos,isetmem,isetmin,isetmax) then isetmem[xpos-isetmin]:=v
else
   begin
   isetmin:=-1;
   isetmax:=-2;//off
   end;
end;
//## getv1 ##
function tstr9.getv1(xpos:longint):byte;
begin
result:=getv(xpos-1);
end;
//## setv1 ##
procedure tstr9.setv1(xpos:longint;v:byte);
begin
setv(xpos-1,v);
end;
//## getchar ##
function tstr9.getchar(xpos:longint):char;
begin
result:=char(getv(xpos));
end;
//## setchar ##
procedure tstr9.setchar(xpos:longint;v:char);
begin
setv(xpos,byte(v));
end;
//## clear ##
function tstr9.clear:boolean;
begin
result:=setlen(0);
end;
//## softclear ##
function tstr9.softclear:boolean;
begin
ilen:=0;
result:=true;
end;
//## softclear2 ##
function tstr9.softclear2(xmaxlen:longint):boolean;
begin
if (ilen>xmaxlen) then setlen(xmaxlen);
ilen:=0;
result:=true;
end;
//## setlen ##
function tstr9.setlen(x:longint):boolean;
var//Note: x is new length
   a:pointer;
   p,xnewlen:longint;
begin
//defaults
result:=false;
//range
xnewlen:=frcmin32(x,0);
//check
if (xnewlen<=0) then
   begin
   if (ilen<=0) and (ilen2<=0) then exit;
   end
else if (xnewlen=ilen) then exit;

try
//reset cache vars
igetmin:=-1;//off
igetmax:=-2;//off
isetmin:=-1;//off
isetmax:=-2;//off

try
//clear
if (xnewlen<=0) and ((ilen2>=1) or (ilist.count>=1)) then
   begin
//   lastlog:=lastlog+'clear: '+k64(ilen2)+'..'+k64(xnewlen)+rcode;//xxxxxxxxxxxxxxxx
   for p:=(ilist.count-1) downto 0 do if (ilist.ptr[p]<>nil) then
      begin
      a:=ilist.ptr[p];
      ilist.ptr[p]:=nil;//set to nil before freeing object
      block__freeb(a);
      end;
   ilist.clear;
   end
//more
else if (xnewlen>=1) and (xnewlen>ilen2) then
   begin
//   lastlog:=lastlog+'more: '+k64(ilen2)+'..'+k64(xnewlen)+rcode;//xxxxxxxxxxxxxxxx
   ilist.mincount((xnewlen div iblocksize)+1);
   for p:=(ilen2 div iblocksize) to (xnewlen div iblocksize) do if (ilist.ptr[p]=nil) then ilist.ptr[p]:=block__new;//keep going even if out-of-memory
   end
//less
else if (ilen2>=1) and (xnewlen<ilen2) then
   begin
//   lastlog:=lastlog+'less: '+k64(ilen2)+'..'+k64(xnewlen)+rcode;//xxxxxxxxxxxxxxxx
   for p:=(ilen2 div iblocksize) downto ((xnewlen div iblocksize)+1) do if (ilist.ptr[p]<>nil) then
      begin
      a:=ilist.ptr[p];
      ilist.ptr[p]:=nil;//set to nil before freeing object
      block__freeb(a);
      end;
   end;

except;end;

//set
ilen2:=xnewlen;
ilen:=xnewlen;
if (ilen2<=0) then idatalen:=0 else idatalen:=((xnewlen div iblocksize)+1)*iblocksize;//23feb2024: corrected
imem:=idatalen + ilist.mem;

//successful
result:=true;
except;end;
end;
//## mem_predict ##
function tstr9.mem_predict(xlen:comp):comp;
begin
xlen:=frcmin64(xlen,0);
if (xlen<=0) then result:=0 else result:=mult64( add64( div64(xlen,iblocksize) ,1) ,iblocksize);
if (ilist<>nil) then result:=add64(result, ilist.mem_predict(add64(div64(xlen,iblocksize),1)) );
end;
//## minlen ##
function tstr9.minlen(x:longint):boolean;//atleast this length, 29feb2024: updated
begin
//defaults
result:=true;
//get
if (x>ilen) then
   begin
   //reset cache vars
   igetmin:=-1;//off
   igetmax:=-2;//off
   isetmin:=-1;//off
   isetmax:=-2;//off
   //enlarge
   if (x>idatalen) then result:=setlen(x) else ilen:=x;
   end;
end;
//## xshiftup ##
function tstr9.xshiftup(spos,slen:longint):boolean;//29feb2024: fixed min range
label
   skipend;
var
   smin,dmin,smax,dmax,xlen,p:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try
xlen:=ilen;

//check
if (xlen<=0) or (slen<=0) then
   begin
   result:=true;
   goto skipend;
   end;

//check
if (spos<0) or (spos>=xlen) then goto skipend;

//init
smax:=-2;
smin:=-1;
dmax:=-2;
dmin:=-1;

//get
for p:=(xlen-1) downto (spos+slen) do
begin
if (((p-slen)<smin) or ((p-slen)>smax)) and (not block__fastinfo(@self,p-slen,smem,smin,smax)) then goto skipend;
if ((p<dmin) or (p>dmax))               and (not block__fastinfo(@self,p,     dmem,dmin,dmax)) then goto skipend;
v:=smem[p-slen-smin];
dmem[p-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;
//object support ---------------------------------------------------------------
//## add ##
function tstr9.add(x:pobject):boolean;
begin
result:=ins2(x,ilen,0,max32);
end;
//## addb ##
function tstr9.addb(x:tobject):boolean;
begin
result:=add(@x);
end;
//## add2 ##
function tstr9.add2(x:pobject;xfrom,xto:longint):boolean;
begin
result:=ins2(x,ilen,xfrom,xto);
end;
//## add3 ##
function tstr9.add3(x:pobject;xfrom,xlen:longint):boolean;
begin
if (xlen>=1) then result:=ins2(x,ilen,xfrom,xfrom+xlen-1) else result:=true;
end;
//## add31 ##
function tstr9.add31(x:pobject;xfrom1,xlen:longint):boolean;
begin
if (xlen>=1) then result:=ins2(x,ilen,(xfrom1-1),(xfrom1-1)+xlen-1) else result:=true;
end;
//## ins ##
function tstr9.ins(x:pobject;xpos:longint):boolean;
begin
result:=ins2(x,xpos,0,max32);
end;
//## ins2 ##
function tstr9.ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//79% native speed of tstr8.ins2 which uses a single block of memory
label
   skipend;
var
   smin,dmin,smax,dmax,slen,dlen,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try

//check
if not pok(x) then
   begin
   result:=true;
   exit;
   end;

//init
slen:=ilen;
xpos:=frcrange32(xpos,0,slen);//allow to write past end

//check
int1:=str__len(x);
if (int1=0) then//06jul2021
   begin
   result:=true;
   goto skipend;
   end;
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then goto skipend;

//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dlen:=ilen+(xto-xfrom+1);//always means to increase the size

//check
if not minlen(dlen) then goto skipend;

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
if (x^ is tstr8) then
   begin
   //init
   dmax:=-2;
   //get
   smem:=(x^ as tstr8).core;
   for p:=xfrom to xto do
   begin
   v:=smem[p];
   if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
   dmem[xpos+p-xfrom-dmin]:=v;
   end;//p
   end
else if (x^ is tstr9) then
   begin
   //init
   smax:=-2;
   smin:=-1;
   dmax:=-2;
   dmin:=-1;
   //get
   for p:=xfrom to xto do
   begin
   if (p>smax)              and (not block__fastinfo(x,p,smem,smin,smax))                then goto skipend;
   if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
   v:=smem[p-smin];
   dmem[xpos+p-xfrom-dmin]:=v;
   end;//p
   end;

//successful
result:=true;
skipend:
except;end;
try;str__autofree(x);except;end;
end;
//## owr ##
function tstr9.owr(x:pobject;xpos:longint):boolean;//overwrite -> enlarge if required - 27apr2021, 01oct2020
begin
result:=owr2(x,xpos,0,max32);
end;
//## owr2 ##
function tstr9.owr2(x:pobject;xpos,xfrom,xto:longint):boolean;//22apr2022
label
   skipend;
var
   smin,dmin,smax,dmax,dlen,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try

//check
if not pok(x) then
   begin
   result:=true;
   exit;
   end;

//init
xpos:=frcmin32(xpos,0);

//check
int1:=str__len(x);
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then
   begin
   result:=true;//27apr2021
   goto skipend;
   end;

//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dlen:=xpos+(xto-xfrom+1);

//check
if not minlen(dlen) then goto skipend;

//copy + size
if (x^ is tstr8) then
   begin
   if ((x^ as tstr8).pbytes<>nil) then
      begin
      //init
      dmax:=-2;
      //get
      smem:=(x^ as tstr8).core;
      for p:=xfrom to xto do
      begin
      v:=smem[p];
      if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
      dmem[xpos+p-xfrom-dmin]:=v;
      end;//p
      end;
   end
else if (x^ is tstr9) then
   begin
   //init
   smax:=-2;
   dmax:=-2;
   //get
   for p:=xfrom to xto do
   begin
   if (p>smax)              and (not block__fastinfo(x,p,smem,smin,smax))              then goto skipend;
   if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
   v:=smem[p-smin];
   dmem[xpos+p-xfrom-dmin]:=v;
   end;//p
   end;

//successful
result:=true;
skipend:
except;end;
try;str__autofree(x);except;end;
end;
//array support ----------------------------------------------------------------
//## aadd ##
function tstr9.aadd(x:array of byte):boolean;
begin
result:=ains2(x,ilen,0,max32);
end;
//## aadd1 ##
function tstr9.aadd1(x:array of byte;xpos1,xlen:longint):boolean;
begin
result:=ains2(x,ilen,xpos1-1,xpos1-1+xlen);
end;
//## aadd2 ##
function tstr9.aadd2(x:array of byte;xfrom,xto:longint):boolean;
begin
result:=ains2(x,ilen,xfrom,xto);
end;
//## ains ##
function tstr9.ains(x:array of byte;xpos:longint):boolean;
begin
result:=ains2(x,xpos,0,max32);
end;
//## ains2 ##
function tstr9.ains2(x:array of byte;xpos,xfrom,xto:longint):boolean;
label
   skipend;
var
   dmin,dmax,slen,dlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try

//check
if (xto<xfrom) then goto skipend;

//range
xfrom:=frcrange32(xfrom,low(x),high(x));
xto  :=frcrange32(xto  ,low(x),high(x));
if (xto<xfrom) then goto skipend;

//init
xpos:=frcrange32(xpos,0,ilen);//allow to write past end
slen:=ilen;
dlen:=slen+(xto-xfrom+1);

//check
if not minlen(dlen) then goto skipend;

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
dmax:=-2;
for p:=xfrom to xto do
begin
v:=x[p];
if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xfrom-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;
//## padd ##
function tstr9.padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
begin
if (xsize<=0) then result:=true else result:=pins2(x,xsize,ilen,0,xsize-1);
end;
//## pins2 ##
function tstr9.pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;
label
   skipend;
var
   dmin,dmax,slen,dlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try

//check
if (x=nil) or (xcount<=0) then
   begin
   result:=true;
   exit;
   end;
if (xto<xfrom) then exit;

//range
xfrom:=frcrange32(xfrom,0,xcount-1);
xto  :=frcrange32(xto  ,0,xcount-1);
if (xto<xfrom) then exit;

//init
xpos:=frcrange32(xpos,0,ilen);//allow to write past end
slen:=ilen;
dlen:=slen+(xto-xfrom+1);
minlen(dlen);

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
dmax:=-2;

for p:=xfrom to xto do
begin
v:=x[p];
if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xfrom-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;
//string support ---------------------------------------------------------------
//## sadd ##
function tstr9.sadd(var x:string):boolean;
begin
result:=sins2(x,ilen,0,max32);
end;
//## sadd2 ##
function tstr9.sadd2(var x:string;xfrom,xto:longint):boolean;
begin
result:=sins2(x,ilen,xfrom,xto);
end;
//## sadd3 ##
function tstr9.sadd3(var x:string;xfrom,xlen:longint):boolean;
begin
if (xlen>=1) then result:=sins2(x,ilen,xfrom,xfrom+xlen-1) else result:=true;
end;
//## saddb ##
function tstr9.saddb(x:string):boolean;
begin
result:=false;try;result:=sins2(x,ilen,0,max32);except;end;
end;
//## sadd2b ##
function tstr9.sadd2b(x:string;xfrom,xto:longint):boolean;
begin
result:=false;try;result:=sins2(x,ilen,xfrom,xto);except;end;
end;
//## sadd3b ##
function tstr9.sadd3b(x:string;xfrom,xlen:longint):boolean;
begin
result:=false;try;if (xlen>=1) then result:=sins2(x,ilen,xfrom,xfrom+xlen-1) else result:=true;except;end;
end;
//## sins ##
function tstr9.sins(var x:string;xpos:longint):boolean;
begin
result:=sins2(x,xpos,0,max32);
end;
//## sinsb ##
function tstr9.sinsb(x:string;xpos:longint):boolean;
begin
result:=false;try;result:=sins2(x,xpos,0,max32);except;end;
end;
//## sins2b ##
function tstr9.sins2b(x:string;xpos,xfrom,xto:longint):boolean;
begin
result:=false;try;result:=sins2(x,xpos,xfrom,xto);except;end;
end;
//## sins2 ##
function tstr9.sins2(var x:string;xpos,xfrom,xto:longint):boolean;
label
   skipend;
var//Always zero based for "xfrom" and "xto"
   dmin,dmax,xlen,slen,dlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try

//check
xlen:=length(x);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;

//check #2
if (xto<xfrom) then exit;

//range
xfrom:=frcrange32(xfrom,0,xlen-1);
xto  :=frcrange32(xto  ,0,xlen-1);
if (xto<xfrom) then exit;

//init
xpos:=frcrange32(xpos,0,ilen);//allow to write past end
slen:=ilen;
dlen:=slen+(xto-xfrom+1);

//check
if not minlen(dlen) then goto skipend;

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
dmax:=-2;
for p:=xfrom to xto do
begin
v:=byte(x[p+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xfrom-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;
//## same ##
function tstr9.same(x:pobject):boolean;
begin
result:=same2(0,x);
end;
//## same2 ##
function tstr9.same2(xfrom:longint;x:pobject):boolean;
label
   skipend;
var
   i,p:longint;
begin
//defaults
result:=false;
try
//check
if (x=nil) or (x^=nil) then exit;
//get
if str__lock(x) then
   begin
   //init
   if (xfrom<0) then xfrom:=0;
   //get
   if (x^ is tstr8) and (str__len(x)>=1) and ((x^ as tstr8).pbytes<>nil) then
      begin
      //get
      for p:=0 to (str__len(x)-1) do
      begin
      i:=xfrom+p;
      if (i>=ilen) or (getv(i)<>(x^ as tstr8).pbytes[p]) then goto skipend;
      end;//p
      end
   else if (x^ is tstr9) and (str__len(x)>=1) then
      begin
      //get
      for p:=0 to (str__len(x)-1) do
      begin
      i:=xfrom+p;
      if (i>=ilen) or (getv(i)<>(x^ as tstr9).bytes[p]) then goto skipend;
      end;//p
      end;
   //successful
   result:=true;
   end;
skipend:
except;end;
try;str__uaf(x);except;end;
end;
//## asame ##
function tstr9.asame(x:array of byte):boolean;
begin
result:=false;try;result:=asame3(0,x,true);except;end;
end;
//## asame2 ##
function tstr9.asame2(xfrom:longint;x:array of byte):boolean;
begin
result:=false;try;result:=asame3(xfrom,x,true);except;end;
end;
//## asame3 ##
function tstr9.asame3(xfrom:longint;x:array of byte;xcasesensitive:boolean):boolean;
begin
result:=false;try;result:=asame4(xfrom,low(x),high(x),x,xcasesensitive);except;end;
end;
//## asame4 ##
function tstr9.asame4(xfrom,xmin,xmax:longint;var x:array of byte;xcasesensitive:boolean):boolean;
label
   skipend;
var
   i,p:longint;
   sv,v:byte;
begin
result:=false;
try
//check
if (sizeof(x)=0) or (ilen=0) then exit;
//range
if (xfrom<0) then xfrom:=0;
//init
xmin:=frcrange32(xmin,low(x),high(x));
xmax:=frcrange32(xmax,low(x),high(x));
if (xmin>xmax) then exit;
//get
for p:=xmin to xmax do
begin
i:=xfrom+(p-xmin);
if (i>=ilen) or (i<0) then goto skipend//22aug2020
else if xcasesensitive and (x[p]<>getv(i)) then goto skipend
else
   begin
   sv:=x[p];
   v:=getv(i);
   if (sv>=65) and (sv<=90) then inc(sv,32);
   if (v>=65)  and (v<=90)  then inc(v,32);
   if (sv<>v) then goto skipend;
   end;
end;//p
//successful
result:=true;
skipend:
except;end;
end;
//## del3 ##
function tstr9.del3(xfrom,xlen:longint):boolean;//06feb2024
begin
result:=del(xfrom,xfrom+xlen-1);
end;
//## del ##
function tstr9.del(xfrom,xto:longint):boolean;//06feb2024
label
   skipend;
var
   smin,dmin,smax,dmax,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=true;//pass-thru
try
//check
if (ilen<=0) or (xfrom>xto) or (xto<0) or (xfrom>=ilen) then exit;
//get
if frcrange2(xfrom,0,ilen-1) and frcrange2(xto,xfrom,ilen-1) then
   begin
   //shift down
   int1:=xto+1;
   if (int1<ilen) then
      begin
      //init
      smax:=-2;
      dmax:=-2;
      //get
      for p:=int1 to (ilen-1) do
      begin
      if (p>smax) and (not block__fastinfo(@self,p,smem,smin,smax)) then goto skipend;
      v:=smem[p-smin];

      if ((xfrom+p-int1)>dmax) and (not block__fastinfo(@self,xfrom+p-int1,dmem,dmin,dmax)) then goto skipend;
      dmem[xfrom+p-int1-dmin]:=v;
      end;//p
      end;
   //resize
   result:=setlen(ilen-(xto-xfrom+1));
   end;
skipend:
except;end;
end;
//add support ------------------------------------------------------------------
//## addcmp8 ##
function tstr9.addcmp8(xval:comp):boolean;
begin
result:=aadd(tcmp8(xval).bytes);
end;
//## addcur8 ##
function tstr9.addcur8(xval:currency):boolean;
begin
result:=aadd(tcur8(xval).bytes);
end;
//## addRGBA4 ##
function tstr9.addRGBA4(r,g,b,a:byte):boolean;
begin
result:=aadd([r,g,b,a]);
end;
//## addRGB3 ##
function tstr9.addRGB3(r,g,b:byte):boolean;
begin
result:=aadd([r,g,b]);
end;
//## addint4 ##
function tstr9.addint4(xval:longint):boolean;
begin
result:=aadd(tint4(xval).bytes);
end;
//## addint4R ##
function tstr9.addint4R(xval:longint):boolean;
begin
xval:=low__intr(xval);//swap round
result:=aadd(tint4(xval).bytes);
end;
//## addint3 ##
function tstr9.addint3(xval:longint):boolean;
var
   r,g,b:byte;
begin
low__int3toRGB(xval,r,g,b);
result:=aadd([r,g,b]);
end;
//## addwrd2 ##
function tstr9.addwrd2(xval:word):boolean;
begin
result:=aadd(twrd2(xval).bytes);//16aug2020
end;
//## addwrd2R ##
function tstr9.addwrd2R(xval:word):boolean;
begin
xval:=low__wrdr(xval);//swap round
result:=aadd(twrd2(xval).bytes);//16aug2020
end;
//## addsmi2 ##
function tstr9.addsmi2(xval:smallint):boolean;//01aug2021
var
   a:twrd2;
begin
a.si:=xval;
result:=aadd([a.bytes[0],a.bytes[1]]);
end;
//## addbyt1 ##
function tstr9.addbyt1(xval:byte):boolean;
begin
result:=aadd([xval]);
end;
//## addbol1 ##
function tstr9.addbol1(xval:boolean):boolean;//21aug2020
begin
if xval then result:=aadd([1]) else result:=aadd([0]);
end;
//## addchr1 ##
function tstr9.addchr1(xval:char):boolean;
begin
result:=aadd([byte(xval)]);
end;
//## addstr ##
function tstr9.addstr(xval:string):boolean;
begin
result:=false;try;result:=sadd(xval);except;end;
end;
//## addrec ##
function tstr9.addrec(a:pointer;asize:longint):boolean;//07feb2022
begin
result:=pins2(pdlbyte(a),asize,ilen,0,asize-1);
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//yyyyyyyyyyyyyyyyyyyyyyy
//get support ------------------------------------------------------------------
//## getcmp8 ##
function tstr9.getcmp8(xpos:longint):comp;
var
   a:tcmp8;
begin
if (xpos>=0) and ((xpos+7)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   a.bytes[2]:=bytes[xpos+2];
   a.bytes[3]:=bytes[xpos+3];
   a.bytes[4]:=bytes[xpos+4];
   a.bytes[5]:=bytes[xpos+5];
   a.bytes[6]:=bytes[xpos+6];
   a.bytes[7]:=bytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;
//## getcur8 ##
function tstr9.getcur8(xpos:longint):currency;
var
   a:tcur8;
begin
if (xpos>=0) and ((xpos+7)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   a.bytes[2]:=bytes[xpos+2];
   a.bytes[3]:=bytes[xpos+3];
   a.bytes[4]:=bytes[xpos+4];
   a.bytes[5]:=bytes[xpos+5];
   a.bytes[6]:=bytes[xpos+6];
   a.bytes[7]:=bytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;
//## getint4 ##
function tstr9.getint4(xpos:longint):longint;
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   a.bytes[2]:=bytes[xpos+2];
   a.bytes[3]:=bytes[xpos+3];
   result:=a.val;
   end
else result:=0;
end;
//## getint4i ##
function tstr9.getint4i(xindex:longint):longint;
begin
result:=getint4(xindex*4);
end;
//## getint4R ##
function tstr9.getint4R(xpos:longint):longint;//14feb2021
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+3];//swap round
   a.bytes[1]:=bytes[xpos+2];
   a.bytes[2]:=bytes[xpos+1];
   a.bytes[3]:=bytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;
//## getint3 ##
function tstr9.getint3(xpos:longint):longint;
begin
if (xpos>=0) and ((xpos+2)<ilen) then result:=bytes[xpos+0]+(bytes[xpos+1]*256)+(bytes[xpos+2]*256*256) else result:=0;
end;
//## getsml2 ##
function tstr9.getsml2(xpos:longint):smallint;//28jul2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   result:=a.si;
   end
else result:=0;
end;
//## getwrd2 ##
function tstr9.getwrd2(xpos:longint):word;
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   result:=a.val;
   end
else result:=0;
end;
//## getwrd2R ##
function tstr9.getwrd2R(xpos:longint):word;//14feb2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+1];//swap round
   a.bytes[1]:=bytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;
//## getbyt1 ##
function tstr9.getbyt1(xpos:longint):byte;
begin
if (xpos>=0) and (xpos<ilen) then result:=bytes[xpos] else result:=0;
end;
//## getbol1 ##
function tstr9.getbol1(xpos:longint):boolean;
begin
if (xpos>=0) and (xpos<ilen) then result:=(bytes[xpos]<>0) else result:=false;
end;
//## getchr1 ##
function tstr9.getchr1(xpos:longint):char;
begin
if (xpos>=0) and (xpos<ilen) then result:=char(bytes[xpos]) else result:=#0;
end;
//## getstr ##
function tstr9.getstr(xpos,xlen:longint):string;//fixed - 16aug2020
var
   dlen,p:longint;
begin
result:='';
try
if (xlen>=1) and (xpos>=0) and (xpos<ilen) then
   begin
   dlen:=frcmax32(xlen,ilen-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      for p:=xpos to (xpos+dlen-1) do result[p-xpos+stroffset]:=char(bytes[p]);
      end;
   end;
except;end;
end;
//## getstr1 ##
function tstr9.getstr1(xpos,xlen:longint):string;
begin
result:='';try;result:=getstr(xpos-1,xlen);except;end;
end;
//## getnullstr ##
function tstr9.getnullstr(xpos,xlen:longint):string;//20mar2022
var
   dcount,dlen,p:longint;
   v:byte;
begin
result:='';
try
if (xlen>=1) and (xpos>=0) and (xpos<ilen) then
   begin
   dlen:=frcmax32(xlen,ilen-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      dcount:=0;
      for p:=xpos to (xpos+dlen-1) do
      begin
      if (bytes[p]=0) then
         begin
         if (dcount<>dlen) then low__setlen(result,dcount);
         break;
         end;
      //was: result[p-xpos+stroffset]:=char(ibytes[p]);
      v:=bytes[p];
      result[p-xpos+stroffset]:=char(v);
      inc(dcount);
      end;//p
      end;
   end;
except;end;
end;
//## getnullstr1 ##
function tstr9.getnullstr1(xpos,xlen:longint):string;//20mar2022
begin
result:='';try;result:=getnullstr(xpos-1,xlen);except;end;
end;
//## gettext ##
function tstr9.gettext:string;
label
   skipend;
var
   smin,smax,p:longint;
   smem:pdlbyte;
   v:byte;
begin
//defaults
result:='';
try
//get
if (ilen>=1) then
   begin
   //init
   smax:=-2;
   low__setlen(result,ilen);
   //get
   for p:=0 to (ilen-1) do
   begin
   if (p>smax) and (not block__fastinfo(@self,p,smem,smin,smax)) then goto skipend;
   v:=smem[p-smin];
   result[p+stroffset]:=char(v);
   end;//p
   end;
skipend:
except;end;
end;
//## gettextarray ##
function tstr9.gettextarray:string;
label
   skipend;
var
   a,aline:tstr8;
   smin,smax,xmax,p:longint;
   smem:pdlbyte;
   v:byte;
begin
//defaults
result:='';
try
a:=nil;
aline:=nil;
//check
if (ilen<=0) then goto skipend;
//init
a:=str__new8;
aline:=str__new8;
xmax:=ilen-1;
smax:=-2;
//get
for p:=0 to xmax do
begin
if (p>smax) and (not block__fastinfo(@self,p,smem,smin,smax)) then goto skipend;
v:=smem[p-smin];
aline.saddb(inttostr(v)+insstr(',',p<xmax));
if (aline.count>=1010) then
   begin
   aline.saddb(rcode);
   a.add(aline);
   aline.clear;
   end;
end;//p
//.finalise
if (aline.count>=1) then
   begin
   a.add(aline);
   aline.clear;
   end;
//set
result:=':array[0..'+inttostr(ilen-1)+'] of byte=('+rcode+a.text+');';//cleaned 02mar2022
skipend:
except;end;
try
str__free(@a);
str__free(@aline);
except;end;
end;
//set support ------------------------------------------------------------------
//## setcmp8 ##
procedure tstr9.setcmp8(xpos:longint;xval:comp);
var
   a:tcmp8;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+8) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
bytes[xpos+2]:=a.bytes[2];
bytes[xpos+3]:=a.bytes[3];
bytes[xpos+4]:=a.bytes[4];
bytes[xpos+5]:=a.bytes[5];
bytes[xpos+6]:=a.bytes[6];
bytes[xpos+7]:=a.bytes[7];
except;end;
end;
//## setcur8 ##
procedure tstr9.setcur8(xpos:longint;xval:currency);
var
   a:tcur8;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+8) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
bytes[xpos+2]:=a.bytes[2];
bytes[xpos+3]:=a.bytes[3];
bytes[xpos+4]:=a.bytes[4];
bytes[xpos+5]:=a.bytes[5];
bytes[xpos+6]:=a.bytes[6];
bytes[xpos+7]:=a.bytes[7];
except;end;
end;
//## setint4 ##
procedure tstr9.setint4(xpos:longint;xval:longint);
var
   a:tint4;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+4) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
bytes[xpos+2]:=a.bytes[2];
bytes[xpos+3]:=a.bytes[3];
except;end;
end;
//## setint4i ##
procedure tstr9.setint4i(xindex:longint;xval:longint);
begin
try;setint4(xindex*4,xval);except;end;
end;
//## setint4R ##
procedure tstr9.setint4R(xpos:longint;xval:longint);
var
   a:tint4;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+4) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[3];//swap round
bytes[xpos+1]:=a.bytes[2];
bytes[xpos+2]:=a.bytes[1];
bytes[xpos+3]:=a.bytes[0];
except;end;
end;
//## setint3 ##
procedure tstr9.setint3(xpos:longint;xval:longint);
var
   r,g,b:byte;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+3) then exit;
low__int3toRGB(xval,r,g,b);
bytes[xpos+0]:=r;
bytes[xpos+1]:=g;
bytes[xpos+2]:=b;
except;end;
end;
//## setsml2 ##
procedure tstr9.setsml2(xpos:longint;xval:smallint);
var
   a:twrd2;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+2) then exit;
a.si:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
except;end;
end;
//## setwrd2 ##
procedure tstr9.setwrd2(xpos:longint;xval:word);
var
   a:twrd2;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+2) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
except;end;
end;
//## setwrd2R ##
procedure tstr9.setwrd2R(xpos:longint;xval:word);
var
   a:twrd2;
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+2) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[1];//swap round
bytes[xpos+1]:=a.bytes[0];
except;end;
end;
//## setbyt1 ##
procedure tstr9.setbyt1(xpos:longint;xval:byte);
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
bytes[xpos]:=xval;
except;end;
end;
//## setbol1 ##
procedure tstr9.setbol1(xpos:longint;xval:boolean);
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
if xval then bytes[xpos]:=1 else bytes[xpos]:=0;
except;end;
end;
//## setchr1 ##
procedure tstr9.setchr1(xpos:longint;xval:char);
begin
try
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
bytes[xpos]:=byte(xval);
except;end;
end;
//## setstr ##
procedure tstr9.setstr(xpos:longint;xlen:longint;xval:string);
label
   skipend;
var
   dmin,dmax,xminlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
try
if (xpos<0) then xpos:=0;
if (xlen<=0) or (xval='') then exit;
xlen:=frcmax32(xlen,length(xval));
xminlen:=xpos+xlen;
if not minlen(xminlen) then exit;
dmax:=-2;
//was: ERROR: for p:=xpos to (xpos+xlen-1) do ibytes[p]:=ord(xval[p+stroffset]);
//was: for p:=0 to (xlen-1) do ibytes[xpos+p]:=ord(xval[p+stroffset]);
for p:=0 to (xlen-1) do
begin
v:=ord(xval[p+stroffset]);
if ((xpos+p)>dmax) and (not block__fastinfo(@self,xpos+p,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-dmin]:=v;
end;//p
skipend:
except;end;
end;
//## setstr1 ##
procedure tstr9.setstr1(xpos:longint;xlen:longint;xval:string);
begin
try;setstr(xpos-1,xlen,xval);except;end;
end;
//## setarray ##
function tstr9.setarray(xpos:longint;xval:array of byte):boolean;
label
   skipend;
var
   dmin,dmax,xminlen,xmin,xmax,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try
//get
if (xpos<0) then xpos:=0;
xmin:=low(xval);
xmax:=high(xval);
xminlen:=xpos+(xmax-xmin+1);
if not minlen(xminlen) then exit;
dmax:=-2;
//was: for p:=xmin to xmax do ibytes[xpos+(p-xmin)]:=xval[p];
for p:=xmin to xmax do
begin
v:=xval[p];
if ((xpos+p-xmin)>dmax) and (not block__fastinfo(@self,xpos+p-xmin,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xmin-dmin]:=v;
end;//p
//successful
result:=true;
skipend:
except;end;
end;
//## settext ##
procedure tstr9.settext(x:string);
label
   skipend;
var
   dmin,dmax,xlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
try
xlen:=length(x);
setlen(xlen);
if (xlen>=1) then
   begin
   //init
   dmax:=-2;
   //get
   for p:=1 to xlen do
   begin
   v:=byte(x[p-1+stroffset]);
   if ((p-1)>dmax) and (not block__fastinfo(@self,p-1,dmem,dmin,dmax)) then goto skipend;
   dmem[p-1-dmin]:=v;
   end;//p
   end;
skipend:
except;end;
end;

//## tintlist ##################################################################
//## create ##
constructor tintlist.create;
begin
inherited create;
iblocksize:=block__size;
irootlimit:=iblocksize div 4;//stores pointers to memory blocks
iblocklimit:=iblocksize div 4;//stores list of longint's (4 bytes each) in memory blocks
ilimit:=restrict32(mult64(irootlimit,iblocklimit));
icount:=0;
irootcount:=0;
iroot:=nil;
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;
end;
//## destroy ##
destructor tintlist.destroy;
begin
try
clear;
inherited destroy;
except;end;
end;
//## mem ##
function tintlist.mem:longint;
begin
result:=0;
try;if (iroot<>nil) then result:=(irootcount+1)*iblocksize;except;end;
end;
//## mem_predict ##
function tintlist.mem_predict(xcount:comp):comp;
var
   xrootcount:comp;
begin
if (xcount<=0) then xrootcount:=0 else xrootcount:=add64(div64(xcount,irootlimit),1);
result:=mult64(add64(xrootcount,1),iblocksize);
end;
//## clear ##
procedure tintlist.clear;
begin
setcount(0);
end;
//## mincount ##
function tintlist.mincount(xcount:longint):boolean;//fixed 20feb2024
begin
if (xcount>icount) then setcount(xcount);
result:=(xcount<=icount);
end;
//## setcount ##
procedure tintlist.setcount(x:longint);
label
   skipend;
var
   a:pointer;
   p,xnewrootcount,xoldrootcount,xnewcount,xoldcount:longint;
   //## xblockcount ##
   function xblockcount(xcount:longint):longint;
   begin
   if (xcount<=0) then result:=0 else result:=(xcount div irootlimit)+1;
   end;
begin
//range
xoldcount:=icount;
xnewcount:=frcrange32(x,0,ilimit);

//check
if (xnewcount=xoldcount) then exit;

//reset cache vars
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;

//init
xoldrootcount:=irootcount;
xnewrootcount:=xblockcount(xnewcount);

try
//check 2
if (xnewrootcount=xoldrootcount) then goto skipend;//already done -> just need to update the icount var

//enlarge
if (xnewrootcount>xoldrootcount) and (xnewrootcount>=1) then
   begin
   //root
   if (iroot=nil) then
      begin
      iroot:=block__new;
      block__cls(iroot);
      end;

   //root slots
   for p:=frcmin32(xoldrootcount-1,0) to (xnewrootcount-1) do if (iroot[p]=nil) then
      begin
      a:=block__new;
      if (a<>nil) then
         begin
         block__cls(a);
         iroot[p]:=a;
         end;
      end;
   end

//shrink
else if (xnewrootcount<xoldrootcount) and (xoldrootcount>=1) then
   begin
   //root slots
   if (iroot<>nil) then
      begin
      for p:=(xoldrootcount-1) downto frcmin32(xnewrootcount-1,0) do if (iroot[p]<>nil) then block__free(iroot[p]);
      end;

   //root
   if (xnewcount<=0) then
      begin
      a:=iroot;
      iroot:=nil;//set to nil before freeing memory
      block__freeb(a);
      end;
   end;

skipend:
except;end;
try
//set
irootcount:=xnewrootcount;
icount:=xnewcount;
except;end;
end;
//## fastinfo ##
function tintlist.fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
var
   xrootindex:longint;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if (xpos>=0) and (xpos<icount) and (iroot<>nil) then
   begin
   xrootindex:=xpos div irootlimit;
   xmem:=iroot[xrootindex];
   if (xmem<>nil) then
      begin
      xmin:=xrootindex*iblocklimit;
      xmax:=((xrootindex+1)*iblocklimit)-1;
      //.limit max for last block using datastream length - 15feb2024
      if (xmax>=icount) then xmax:=icount-1;
      //successful
      result:=(xmem<>nil);
      end;
   end;
except;end;
end;
//## getvalue ##
function tintlist.getvalue(x:longint):longint;
begin
result:=0;
if (x>=igetmin) and (x<=igetmax)                                      then result:=pdllongint(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdllongint(igetmem)[x-igetmin];
end;
//## setvalue ##
procedure tintlist.setvalue(x:longint;xval:longint);
begin
if (x>=isetmin) and (x<=isetmax) then pdllongint(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdllongint(isetmem)[x-isetmin]:=xval;
   end;
end;
//## getptr ##
function tintlist.getptr(x:longint):pointer;
begin
result:=nil;
if (x>=igetmin) and (x<=igetmax)                                      then result:=pdlpointer(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdlpointer(igetmem)[x-igetmin];
end;
//## setptr ##
procedure tintlist.setptr(x:longint;xval:pointer);
begin
if (x>=isetmin) and (x<=isetmax) then pdlpointer(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdlpointer(isetmem)[x-isetmin]:=xval;
   end;
end;

//## tcmplist ##################################################################
//## create ##
constructor tcmplist.create;
begin
inherited create;
iblocksize:=block__size;
irootlimit:=iblocksize div 4;//stores pointers to memory blocks
iblocklimit:=iblocksize div 8;//stores list of comp's (8 bytes each) in memory blocks
ilimit:=restrict32(mult64(irootlimit,iblocklimit));
icount:=0;
irootcount:=0;
iroot:=nil;
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;
end;
//## destroy ##
destructor tcmplist.destroy;
begin
try
clear;
inherited destroy;
except;end;
end;
//## mem ##
function tcmplist.mem:longint;
begin
result:=0;
try;if (iroot<>nil) then result:=(irootcount+1)*iblocksize;except;end;
end;
//## clear ##
procedure tcmplist.clear;
begin
setcount(0);
end;
//## mincount ##
function tcmplist.mincount(xcount:longint):boolean;//fixed 20feb2024
begin
if (xcount>icount) then setcount(xcount);
result:=(xcount<=icount);
end;
//## setcount ##
procedure tcmplist.setcount(x:longint);
label
   skipend;
var
   p,xrootcount,xcount:longint;
begin
//range
xcount:=frcrange32(x,0,ilimit);
xrootcount:=irootcount;

try
//check
//.count
if (xcount=icount) then exit;

//.rootcount
xrootcount:=xcount div irootlimit;
if (xcount<>(xrootcount*irootlimit)) then xrootcount:=frcrange32(xrootcount+1,0,irootlimit);
if (irootcount=xrootcount) then goto skipend;

//.reset fastinfo vars
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;


//get
if (xrootcount>irootcount) then
   begin
   //root
   if (iroot=nil) then
      begin
      iroot:=block__new;
      low__cls(iroot,iblocksize);
      end;

   //slots
   for p:=irootcount to (xrootcount-1) do if (iroot[p]=nil) then
      begin
      iroot[p]:=block__new;;
      block__cls(iroot[p]);
      end;
   end
else if (xrootcount<irootcount) then
   begin
   //root
   if (iroot=nil) then goto skipend;

   //slots
   for p:=(irootcount-1) downto xrootcount do if (iroot[p]<>nil) then block__free(iroot[p]);

   //root
   if (xcount<=0) then
      begin
      block__freeb(iroot);
      iroot:=nil;
      end;
   end;

skipend:
except;end;
try
//set
irootcount:=xrootcount;
icount:=xcount;
except;end;
end;
//## fastinfo ##
function tcmplist.fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
var
   xrootindex:longint;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if (xpos>=0) and (xpos<icount) and (iroot<>nil) then
   begin
   xrootindex:=xpos div irootlimit;
   xmem:=iroot[xrootindex];
   if (xmem<>nil) then
      begin
      xmin:=xrootindex*iblocklimit;
      xmax:=((xrootindex+1)*iblocklimit)-1;
      //.limit max for last block using datastream length - 15feb2024
      if (xmax>=icount) then xmax:=icount-1;
      //successful
      result:=(xmem<>nil);
      end;
   end;
except;end;
end;
//## getvalue ##
function tcmplist.getvalue(x:longint):comp;
begin
result:=0;
if (x>=igetmin) and (x<=igetmax)                                                       then result:=pdlcomp(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and (iroot<>nil) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdlcomp(igetmem)[x-igetmin];
end;
//## setvalue ##
procedure tcmplist.setvalue(x:longint;xval:comp);
begin
if (x>=isetmin) and (x<=isetmax) then pdlcomp(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdlcomp(isetmem)[x-isetmin]:=xval;
   end;
end;
//## getdbl ##
function tcmplist.getdbl(x:longint):double;
begin
result:=0;
if (x>=igetmin) and (x<=igetmax)                                                       then result:=pdldouble(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and (iroot<>nil) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdldouble(igetmem)[x-igetmin];
end;
//## setdbl ##
procedure tcmplist.setdbl(x:longint;xval:double);
begin
if (x>=isetmin) and (x<=isetmax) then pdldouble(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdldouble(isetmem)[x-isetmin]:=xval;
   end;
end;
//## getdate ##
function tcmplist.getdate(x:longint):tdatetime;
begin
result:=0;
if (x>=igetmin) and (x<=igetmax)                                                       then result:=pdldatetime(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and (iroot<>nil) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdldatetime(igetmem)[x-igetmin];
end;
//## setdate ##
procedure tcmplist.setdate(x:longint;xval:tdatetime);
begin
if (x>=isetmin) and (x<=isetmax) then pdldatetime(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdldatetime(isetmem)[x-isetmin]:=xval;
   end;
end;

//## tmemstr8 ##################################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//mmmmmmmmmmmmmmmmmmmm
//## create ##
constructor tmemstr8.create(_ptr:tstr8);
begin
//self
inherited create;
//set
idata:=_ptr;
iposition:=0;
end;
//## destroy ##
destructor tmemstr8.destroy;
begin
try;inherited destroy;except;end;
end;
//## read ##
function tmemstr8.read(var x;xlen:longint):longint;
begin
result:=0;
try
//set
if not zznil(idata,2261) then
   begin
   result:=str__len(@idata)-iposition;
   if (result>xlen) then result:=xlen;
   if (idata.pbytes<>nil) then move(idata.pbytes[iposition],x,result);//27apr2021
   inc(iposition,result);
   end;//if
except;end;
end;
//## write ##
function tmemstr8.write(const x;xlen:longint):longint;
begin
result:=0;
try
//set
if not zznil(idata,2262) then
  begin
  result:=xlen;
  idata.setlen(iposition+result);
  if (idata.pbytes<>nil) then move(x,idata.pbytes[iposition],result);//27apr2021
  inc(iposition,result);
  end;
except;end;
end;
//## seek ##
function tmemstr8.seek(offset:longint;origin:word):longint;
begin
result:=0;
try
//check
if zznil(idata,2263) then
   begin
   iposition:=0;
   //result:=0;
   exit;
   end;//if
//set
case Origin of
soFromBeginning:iposition:=offset;
soFromCurrent:iposition:=iposition+offset;
soFromEnd:iposition:=str__len(@idata)-offset;
end;//end of case
//range
iposition:=frcrange32(iposition,0,str__len(@idata));
//return result
result:=iposition;
except;end;
end;
//## readstring ##
function tmemstr8.readstring(count:longint):string;
var
  len:longint;
begin
//defaults
result:='';
try
//check
if zznil(idata,2264) then exit;
//process
len:=str__len(@idata)-iposition;
if (len>count) then len:=count;
result:=bgetstr1(idata,iposition+1,len);
inc(iposition,len);
except;end;
end;
//## writestring ##
procedure tmemstr8.writestring(const x:string);
begin
//was: try;write(pchar(x)^,length(x));except;end;
try;if zzok(idata,7073) then idata.replacestr:=x;except;end;
end;
//## setsize ##
procedure tmemstr8.setsize(newsize:longint);
begin
try
//check
if zznil(idata,2265) then exit;
//set
idata.setlen(newsize);
if (iposition>newsize) then iposition:=newsize;
except;end;
end;

//## tvars8 ####################################################################
//## create ##
constructor tvars8.create;
begin
track__inc(satVars8,1);
inherited create;
icore:=str__new8;
end;
//## destroy ##
destructor tvars8.destroy;
begin
try
str__free(@icore);
inherited destroy;
track__inc(satVars8,-1);
except;end;
end;
//## len ##
function tvars8.len:longint;
begin
result:=0;try;result:=icore.len;except;end;
end;
//## clear ##
procedure tvars8.clear;
begin
try;icore.clear;except;end;
end;
//## bdef ##
function tvars8.bdef(xname:string;xdefval:boolean):boolean;
begin
result:=xdefval;
if found(xname) then result:=b[xname];
end;
//## idef ##
function tvars8.idef(xname:string;xdefval:longint):longint;
begin
result:=xdefval;
if found(xname) then result:=i[xname];
end;
//## idef2 ##
function tvars8.idef2(xname:string;xdefval,xmin,xmax:longint):longint;
begin
result:=xdefval;
if found(xname) then result:=i[xname];
//range
result:=frcrange32(result,xmin,xmax);
end;
//## idef64 ##
function tvars8.idef64(xname:string;xdefval:comp):comp;
begin
result:=xdefval;
if found(xname) then result:=i64[xname];
end;
//## idef642 ##
function tvars8.idef642(xname:string;xdefval,xmin,xmax:comp):comp;
begin
result:=xdefval;
if found(xname) then result:=i64[xname];
//range
result:=frcrange64(result,xmin,xmax);
end;
//## sdef ##
function tvars8.sdef(xname,xdefval:string):string;
begin
result:='';
try
result:=xdefval;
if found(xname) then result:=s[xname];
except;end;
end;
//## getb ##
function tvars8.getb(xname:string):boolean;
begin
result:=(i[xname]<>0);
end;
//## setb ##
procedure tvars8.setb(xname:string;xval:boolean);
begin
if xval then xsets(xname,'1') else xsets(xname,'0');
end;
//## geti ##
function tvars8.geti(xname:string):longint;
begin
result:=strint(value[xname]);
end;
//## seti ##
procedure tvars8.seti(xname:string;xval:longint);
begin
try;xsets(xname,inttostr(xval));except;end;
end;
//## geti64 ##
function tvars8.geti64(xname:string):comp;
begin
result:=strint64(value[xname]);
end;
//## seti64 ##
procedure tvars8.seti64(xname:string;xval:comp);
begin
try;xsets(xname,intstr64(xval));except;end;
end;
//## getdt64 ##
function tvars8.getdt64(xname:string):tdatetime;
var
   y,m,d,hh,mm,ss,ms:word;
   a:tstr8;
begin
//defaults
result:=0;
try
//init
a:=nil;
a:=str__new8;
//get
a.text:=gets(xname);
if (a.len>=8) then
   begin
   ms:=frcrange32(a.wrd2[7],0,999);//7..8
   ss:=frcrange32(a.byt1[6],0,59);//6
   mm:=frcrange32(a.byt1[5],0,59);//5
   hh:=frcrange32(a.byt1[4],0,23);//4
   d:=frcrange32(a.byt1[3],1,31);//3
   m:=frcrange32(a.byt1[2],1,12);//2
   y:=a.wrd2[0];
   //set
   result:=low__safedate(low__encodedate2(y,m,d)+low__encodetime2(hh,mm,ss,ms));
   end;
except;end;
try;str__free(@a);except;end;
end;
//## setdt64 ##
procedure tvars8.setdt64(xname:string;xval:tdatetime);//31jan2022
var
   y,m,d,hh,mm,ss,ms:word;
   a:tstr8;
begin
try
a:=nil;
a:=str__new8;
low__decodedate2(xval,y,m,d);
low__decodetime2(xval,hh,mm,ss,ms);
a.wrd2[7]:=frcrange32(ms,0,999);//7..8
a.byt1[6]:=frcrange32(ss,0,59);//6
a.byt1[5]:=frcrange32(mm,0,59);//5
a.byt1[4]:=frcrange32(hh,0,23);//4
a.byt1[3]:=frcrange32(d,1,31);//3
a.byt1[2]:=frcrange32(m,1,12);//2
a.wrd2[0]:=y;//0..1
xsets(xname,a.text);
except;end;
try;str__free(@a);except;end;
end;
//## getc ##
function tvars8.getc(xname:string):currency;
begin
result:=0;try;result:=strtofloatex(value[xname]);except;end;
end;
//## setc ##
procedure tvars8.setc(xname:string;xval:currency);
begin
try;xsets(xname,floattostrex2(xval));except;end;
end;
//## gets ##
function tvars8.gets(xname:string):string;
var
   xpos,nlen,dlen,blen:longint;
begin
result:='';
try;if xfind(xname,xpos,nlen,dlen,blen) and zzok(icore,7075) then result:=icore.str[xpos+16+nlen,dlen];except;end;
end;
//## sets ##
procedure tvars8.sets(xname,xvalue:string);
begin
try;xsets(xname,xvalue);except;end;
end;
//## getd ##
function tvars8.getd(xname:string):tstr8;//27apr2021
var
   xpos,nlen,dlen,blen:longint;
begin
result:=nil;
try
//was: result:=bnew2(124);
result:=str__newaf8;//27apr2021
if xfind(xname,xpos,nlen,dlen,blen) then result.bdata:=str__copy81(icore,(xpos+1)+16+nlen,dlen);
except;end;
end;
//## dget ##
function tvars8.dget(xname:string;xdata:tstr8):boolean;//2dec2021
var
   xpos,nlen,dlen,blen:longint;
begin
result:=false;
try
if not str__lock(@xdata) then exit;
if xfind(xname,xpos,nlen,dlen,blen) then
   begin
   xdata.clear;
   xdata.add3(icore,(xpos+0)+16+nlen,dlen);
   result:=true;
   end;
except;end;
try
if not result then xdata.clear;
str__uaf(@xdata);
except;end;
end;
//## setd ##
procedure tvars8.setd(xname:string;xvalue:tstr8);
begin
try;xsetd(xname,xvalue);except;end;
end;
//## bok ##
function tvars8.bok(xname:string;xval:boolean):boolean;
begin
result:=(xval<>b[xname]);
if result then b[xname]:=xval;
end;
//## iok ##
function tvars8.iok(xname:string;xval:longint):boolean;
begin
result:=(xval<>i[xname]);
if result then i[xname]:=xval;
end;
//## i64ok ##
function tvars8.i64ok(xname:string;xval:comp):boolean;
begin
result:=(xval<>i64[xname]);
if result then i64[xname]:=xval;
end;
//## cok ##
function tvars8.cok(xname:string;xval:currency):boolean;
begin
result:=(xval<>c[xname]);
if result then c[xname]:=xval;
end;
//## sok ##
function tvars8.sok(xname,xval:string):boolean;
begin
result:=false;try;result:=(xval<>s[xname]);if result then s[xname]:=xval;except;end;
end;
//## found ##
function tvars8.found(xname:string):boolean;
var
   xpos,nlen,dlen,blen:longint;
begin
result:=xfind(xname,xpos,nlen,dlen,blen);
end;
//## xfind ##
function tvars8.xfind(xname:string;var xpos,nlen,dlen,blen:longint):boolean;
label
   redo;
var
   xlen:longint;
   v:tint4;
   c,nref:tcur8;
   lb:pdlbyte;
begin
//defaults
result:=false;
try
xpos:=0;
nlen:=0;
dlen:=0;
blen:=0;
//check
if zznil(icore,2266) or (icore.pbytes=nil) then exit;//27apr2021
//init
xlen:=icore.len;
lb:=icore.pbytes;
nref.val:=low__ref256u(xname);
//find
redo:
if ((xpos+15)<xlen) then
   begin
   //nlen/4 - name length
   v.bytes[0]:=lb[xpos+0];
   v.bytes[1]:=lb[xpos+1];
   v.bytes[2]:=lb[xpos+2];
   v.bytes[3]:=lb[xpos+3];
   if (v.val<0) then v.val:=0;
   nlen:=v.val;
   //dlen/4 - data length
   v.bytes[0]:=lb[xpos+4];
   v.bytes[1]:=lb[xpos+5];
   v.bytes[2]:=lb[xpos+6];
   v.bytes[3]:=lb[xpos+7];
   if (v.val<0) then v.val:=0;
   dlen:=v.val;
   //nref/8
   c.bytes[0]:=lb[xpos+8];
   c.bytes[1]:=lb[xpos+9];
   c.bytes[2]:=lb[xpos+10];
   c.bytes[3]:=lb[xpos+11];
   c.bytes[4]:=lb[xpos+12];
   c.bytes[5]:=lb[xpos+13];
   c.bytes[6]:=lb[xpos+14];
   c.bytes[7]:=lb[xpos+15];
   //blen - block length "16 + <name> + <data>"
   blen:=16+nlen+dlen;
   //name
   case (c.ints[0]=nref.ints[0]) and (c.ints[1]=nref.ints[1]) and strmatch(xname,icore.str[xpos+16,nlen]) of
   true:result:=true;
   false:begin//inc to next block
      inc(xpos,blen);
      goto redo;
      end;
   end;//case
   end;
except;end;
end;
//## xnext ##
function tvars8.xnext(var xfrom,xpos,nlen,dlen,blen:longint):boolean;
var
   xlen:longint;
   v:tint4;
   lb:pdlbyte;
begin
//defaults
result:=false;
try
if (xfrom<0) then xfrom:=0;
xpos:=0;
nlen:=0;
dlen:=0;
blen:=0;
//check
if zznil(icore,2269) or (icore.pbytes=nil) then exit;//27apr2021
//init
xlen:=icore.len;
lb:=icore.pbytes;
//find
if ((xfrom+15)<xlen) then
   begin
   //nlen/4 - name length
   v.bytes[0]:=lb[xfrom+0];
   v.bytes[1]:=lb[xfrom+1];
   v.bytes[2]:=lb[xfrom+2];
   v.bytes[3]:=lb[xfrom+3];
   if (v.val<0) then v.val:=0;
   nlen:=v.val;
   //dlen/4 - data length
   v.bytes[0]:=lb[xfrom+4];
   v.bytes[1]:=lb[xfrom+5];
   v.bytes[2]:=lb[xfrom+6];
   v.bytes[3]:=lb[xfrom+7];
   if (v.val<0) then v.val:=0;
   dlen:=v.val;
   //blen - block length "16 + <name> + <data>"
   blen:=16+nlen+dlen;
   //name
   xpos:=xfrom;
   inc(xfrom,blen);
   //successful
   result:=true;
   end;
except;end;
end;
//## xnextname ##
function tvars8.xnextname(var xpos:longint;var xname:string):boolean;
var
   nlen,dlen,blen,xlen:longint;
   v:tint4;
   lb:pdlbyte;
begin
//defaults
result:=false;
try
xname:='';
if (xpos<0) then xpos:=0;
//check
if zznil(icore,2270) or (icore.pbytes=nil) then exit;//27apr2021
//init
xlen:=icore.len;
lb:=icore.pbytes;
//get
if ((xpos+15)<xlen) then
   begin
   //nlen/4 - name length
   v.bytes[0]:=lb[xpos+0];
   v.bytes[1]:=lb[xpos+1];
   v.bytes[2]:=lb[xpos+2];
   v.bytes[3]:=lb[xpos+3];
   if (v.val<0) then v.val:=0;
   nlen:=v.val;
   //dlen/4 - data length
   v.bytes[0]:=lb[xpos+4];
   v.bytes[1]:=lb[xpos+5];
   v.bytes[2]:=lb[xpos+6];
   v.bytes[3]:=lb[xpos+7];
   if (v.val<0) then v.val:=0;
   dlen:=v.val;
   //nref/8
   {
   c.bytes[0]:=lb[xpos+8];
   c.bytes[1]:=lb[xpos+9];
   c.bytes[2]:=lb[xpos+10];
   c.bytes[3]:=lb[xpos+11];
   c.bytes[4]:=lb[xpos+12];
   c.bytes[5]:=lb[xpos+13];
   c.bytes[6]:=lb[xpos+14];
   c.bytes[7]:=lb[xpos+15];
   }
   //blen - block length "16 + <name> + <data>"
   blen:=16+nlen+dlen;
   //name
   xname:=icore.str[xpos+16,nlen];
   //inc
   inc(xpos,blen);
   //successful
   result:=true;
   end;
except;end;
end;
//## findcount ##
function tvars8.findcount:longint;//10jan2023
label
   redo;
var
   str1:string;
   xpos:longint;
begin
result:=0;
try
xpos:=0;
redo:
if xnextname(xpos,str1) then
   begin
   inc(result);
   goto redo;
   end;
except;end;
end;
//## xdel ##
function tvars8.xdel(xname:string):boolean;//02jan2022
var
   xpos,nlen,dlen,blen:longint;
begin
//defaults
result:=false;
try
//check
if (xname='') or zznil(icore,2271) then exit;
//delete existing
if xfind(xname,xpos,nlen,dlen,blen) then
   begin
   bdel1(icore,xpos+1,blen);
   result:=true;
   end;
except;end;
end;
//## xsets ##
procedure tvars8.xsets(xname,xvalue:string);
label
   skipend;
var
   p,xpos,xlen,nlen,dlen,blen:longint;
   v:tint4;
   nref:tcur8;
   lb:pdlbyte;
begin
try
//check
if (xname='') or zznil(icore,2271) then goto skipend;
//delete existing
if xfind(xname,xpos,nlen,dlen,blen) then bdel1(icore,xpos+1,blen);
//init
nlen:=length(xname);
dlen:=length(xvalue);
xpos:=_blen(icore);
blen:=16+nlen+dlen;
xlen:=xpos+blen;
nref.val:=low__ref256u(xname);
//size
if (icore.len<>xlen) and (not icore.setlen(xlen)) then exit;//27apr2021
//check
if (icore.pbytes=nil) then exit;//27apr2021
//init
lb:=icore.pbytes;
//nlen/4
v.val:=nlen;
lb[xpos+0]:=v.bytes[0];
lb[xpos+1]:=v.bytes[1];
lb[xpos+2]:=v.bytes[2];
lb[xpos+3]:=v.bytes[3];
//dlen/4
v.val:=dlen;
lb[xpos+4]:=v.bytes[0];
lb[xpos+5]:=v.bytes[1];
lb[xpos+6]:=v.bytes[2];
lb[xpos+7]:=v.bytes[3];
//nref/8
lb[xpos+8]:=nref.bytes[0];
lb[xpos+9]:=nref.bytes[1];
lb[xpos+10]:=nref.bytes[2];
lb[xpos+11]:=nref.bytes[3];
lb[xpos+12]:=nref.bytes[4];
lb[xpos+13]:=nref.bytes[5];
lb[xpos+14]:=nref.bytes[6];
lb[xpos+15]:=nref.bytes[7];
//name
for p:=1 to nlen do lb[xpos+15+p]:=byte(xname[p-1+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
//data
if (dlen>=1) then
   begin
   for p:=1 to dlen do lb[xpos+15+nlen+p]:=byte(xvalue[p-1+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
   end;
skipend:
except;end;
end;
//## xsetd ##
procedure tvars8.xsetd(xname:string;xvalue:tstr8);
label
   skipend;
var
   p,xpos,xlen,nlen,dlen,blen:longint;
   v:tint4;
   nref:tcur8;
   sb,lb:pdlbyte;
   v8:byte;
begin
try
str__lock(@xvalue);
//check
if (xname='') or zznil(icore,2272) or (icore=xvalue) then goto skipend;
//delete existing
if xfind(xname,xpos,nlen,dlen,blen) then bdel1(icore,xpos+1,blen);
//init
nlen:=length(xname);
dlen:=_blen(xvalue);
xpos:=_blen(icore);
blen:=16+nlen+dlen;
xlen:=xpos+blen;
nref.val:=low__ref256u(xname);
//size
if (icore.len<>xlen) and (not icore.setlen(xlen)) then exit;
//check
if (icore.pbytes=nil) then exit;
//init
lb:=icore.pbytes;
//nlen/4
v.val:=nlen;
lb[xpos+0]:=v.bytes[0];
lb[xpos+1]:=v.bytes[1];
lb[xpos+2]:=v.bytes[2];
lb[xpos+3]:=v.bytes[3];
//dlen/4
v.val:=dlen;
lb[xpos+4]:=v.bytes[0];
lb[xpos+5]:=v.bytes[1];
lb[xpos+6]:=v.bytes[2];
lb[xpos+7]:=v.bytes[3];
//nref/8
lb[xpos+8]:=nref.bytes[0];
lb[xpos+9]:=nref.bytes[1];
lb[xpos+10]:=nref.bytes[2];
lb[xpos+11]:=nref.bytes[3];
lb[xpos+12]:=nref.bytes[4];
lb[xpos+13]:=nref.bytes[5];
lb[xpos+14]:=nref.bytes[6];
lb[xpos+15]:=nref.bytes[7];
//name
for p:=1 to nlen do lb[xpos+15+p]:=byte(xname[p-1+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
//data
if (dlen>=1) then
   begin
   sb:=xvalue.pbytes;
   //was: for p:=1 to dlen do lb[xpos+15+nlen+p]:=sb[p-1];
   //faster - 22apr2022
   for p:=1 to dlen do
   begin
   v8:=sb[p-1];
   lb[xpos+15+nlen+p]:=v8;
   end;//p
   end;
skipend:
except;end;
try;str__uaf(@xvalue);except;end;
end;
//## gettext ##
function tvars8.gettext:string;
var
   a:tstr8;
begin
result:='';
try
a:=nil;
a:=data;
if (a<>nil) then result:=a.text;
except;end;
try;str__autofree(@a);except;end;
end;
//## settext ##
procedure tvars8.settext(x:string);
begin
try;data:=bcopystr1(x,1,max32);except;end;
end;
//## getdata ##
function tvars8.getdata:tstr8;
label
   redo;
var
   xfrom,xpos,nlen,dlen,blen:longint;
begin
result:=nil;
try
//defaults
result:=str__newaf8;
//init
xfrom:=0;
//get
redo:
if (result<>nil) and zzok(icore,7076) and xnext(xfrom,xpos,nlen,dlen,blen) then
   begin
   result.saddb(icore.str[xpos+16,nlen]+': '+icore.str[xpos+16+nlen,dlen]+r10);
   goto redo;
   end;
except;end;
end;
//## setdata ##
procedure tvars8.setdata(xdata:tstr8);
label
   redo;
var
   xline:tstr8;
   xlen,p,xpos:longint;
   lb:pdlbyte;
begin
try
//init
xline:=nil;
clear;
//check
if zznil(xdata,2077) or (icore=xdata) then exit;
//init
str__lock(@xdata);
xline:=str__new8;
xpos:=0;
//get
redo:
if low__nextline0(xdata,xline,xpos) then
   begin
   xlen:=xline.len;
   if (xlen>=1) and (xline.pbytes<>nil) then//27apr2021
      begin
      lb:=xline.pbytes;
      for p:=1 to xlen do if (lb[p-1]=58) then//":"
         begin
         xsets(xline.str[0,p-1],xline.str[p+1,xlen]);
         break;
         end;//p
      end;//xlen
   goto redo;
   end;
except;end;
try
str__free(@xline);
str__uaf(@xdata);
except;end;
end;
//## getbinary ##
function tvars8.getbinary(hdr:string):tstr8;
label
   skipend,redo;
const
   nMAXSIZE=high(word);
var
   xfrom,xpos,nlen,dlen,blen:longint;
begin
result:=nil;
try
//defaults
result:=str__newaf8;
//init
xfrom:=0;
//hdr
if (hdr<>'') and (not result.sadd(hdr)) then goto skipend;
//get
redo:
if xnext(xfrom,xpos,nlen,dlen,blen) then
   begin
   //nlen+vlen
   if (nlen>nMAXSIZE) then nlen:=nMAXSIZE;
   if not result.addwrd2(nlen) then goto skipend;
   if not result.addint4(dlen) then goto skipend;
   //name
   if not result.add3(icore,xpos+16,nlen) then goto skipend;
   //data
   if not result.add3(icore,xpos+16+nlen,dlen) then goto skipend;
   //loop
   goto redo;
   end;
skipend:
except;end;
end;
//## setbinary ##
procedure tvars8.setbinary(hdr:string;xval:tstr8);
label
   skipend,redo;
var
   xlen,xpos:longint;
   aname,aval:tstr8;
   //## apull ##
   function apull:boolean;
   var
      nlen,vlen:longint;
   begin
   //defaults
   result:=false;
   //check
   if (xpos>=xlen) then exit;
   //init
   nlen:=xval.wrd2[xpos+0];//0..1
   vlen:=xval.int4[xpos+2];//2..5
   if (nlen<=0) or (vlen<0) then exit;
   //get
   aname.clear;
   aname.add3(xval,xpos+6,nlen);
   aval.clear;
   if (vlen>=1) then aval.add3(xval,xpos+6+nlen,vlen);
   //inc
   inc(xpos,6+nlen+vlen);
   //successful
   result:=true;
   end;
begin
try
//defaults
clear;
aname:=nil;
aval:=nil;
//check
if zznil(xval,2278) or (icore=xval) then exit;
//init
str__lock(@xval);
aname:=str__new8;
aval:=str__new8;
xpos:=0;
xlen:=xval.len;
//hdr
if (hdr<>'') then
   begin
   aval.add3(xval,0,length(hdr));
   if not strmatch(hdr,aval.text) then goto skipend;
   inc(xpos,length(hdr));
   end;
//name+value sets
redo:
if apull then
   begin
   xsetd(aname.text,aval);
   goto redo;
   end;
skipend:
except;end;
try
str__free(@aname);
str__free(@aval);
str__uaf(@xval);
except;end;
end;

//## tmask8 ####################################################################
//## newmask8 ##
function newmask8(w,h:longint):tmask8;
begin
result:=nil;try;result:=tmask8.create(w,h);except;end;
end;
//## create ##
constructor tmask8.create(w,h:longint);
begin
track__inc(satMask8,1);
inherited create;
iwidth:=0;
iheight:=0;
icount:=0;
iblocksize:=sizeof(tmaskrgb96);
irowsize:=0;
icore:=str__new8;
irows:=str__new8;
resize(w,h);
end;
//## destroy ##
destructor tmask8.destroy;
begin
try
str__free(@icore);
str__free(@irows);
inherited destroy;
track__inc(satMask8,-1);
except;end;
end;
//## resize ##
function tmask8.resize(w,h:longint):boolean;
var
   p,dy,xcount,xrowsize:longint;
begin
//defaults
result:=false;
try
//init
w:=frcmin32(w,1);
h:=frcmin32(h,1);
xrowsize:=(w div iblocksize)*iblocksize;//round up to nearest block of 12b
if (xrowsize<>w) then inc(xrowsize,iblocksize);
xcount:=(h*xrowsize);
//get
if (xcount<>icore.len) and icore.setlen(xcount) then//27apr2021
   begin
   irowsize:=xrowsize;
   iwidth:=w;
   iheight:=h;
   ibytes:=icore.core;
   icount:=xcount;
   //rows
   p:=0;
//   app__fasttimer;
   irows.setlen(h*sizeof(pointer));
//   app__fasttimer;
   irows96:=irows.core;
   irows8:=irows.core;
   for dy:=0 to (h-1) do
   begin
   irows96[dy]:=icore.scanline(p);
   inc(p,irowsize);

   //fasttimer - ycheck
//   inc(sysfasttimer_ycount); if (sysfasttimer_ycount>=sysfasttimer_ytrigger) then fasttimer_ycheck;
   end;//dy
   //successful
   result:=true;
   end
else result:=true;
except;end;
end;
//## cls ##
function tmask8.cls(xval:byte):boolean;
var
   sr96:pmaskrow96;
   dc96:tmaskrgb96;
   p,dx,dy,dw96:longint;
begin
//defaults
result:=false;
try
//check
if (iwidth<1) or (iheight<1) then exit;
//init
for p:=0 to high(dc96) do dc96[p]:=xval;
//get
dw96:=irowsize div sizeof(dc96);
for dy:=0 to (iheight-1) do
begin
sr96:=rows[dy];
for dx:=0 to (dw96-1) do sr96[dx]:=dc96;

//fasttimer - ycheck
//inc(sysfasttimer_ycount); if (sysfasttimer_ycount>=sysfasttimer_ytrigger) then fasttimer_ycheck;
end;//dy

//successful
result:=true;
except;end;
end;
//## fill ##
function tmask8.fill(xarea:trect;xval:byte;xround:boolean):boolean;//29apr2020
var//Speed: 3,300ms -> 1,280ms -> 1,141ms -> 1,080ms
   sr96:pmaskrow96;
   dc96:tmaskrgb96;
   amin,xcorner,dxstart,dx96,xleft96,xright96,dx1,dx2,dx,dy,dh,dw96:longint;
   bol1:boolean;
//xxxxxxxxxxxxxxxxxxxxxxx this needs to be replaced with "low__cornersolid()" for a consistent system wide approach - 16may2020
   //## xcorneroffset_solid ##
   procedure xcorneroffset_solid;
   begin
   //.int1 -> set offset to draw slightly rounded corners - 09apr2020
   xcorner:=0;
   case amin of
   3..10:if (dy=xarea.top) or (dy=xarea.bottom)           then xcorner:=1;//1px curved corner
   11..max32:begin//multi-pixel curved corner
      if      (dy=xarea.top)     or (dy=xarea.bottom)     then xcorner:=3
      else if (dy=(xarea.top+1)) or (dy=(xarea.bottom-1)) then xcorner:=2
      else if (dy=(xarea.top+2)) or (dy=(xarea.bottom-2)) then xcorner:=1
      else if (dy=(xarea.top+3)) or (dy=(xarea.bottom-3)) then xcorner:=1
      else if (dy=(xarea.top+4)) or (dy=(xarea.bottom-4)) then xcorner:=1;
      end;
   end;//case
   end;
begin
//defaults
result:=true;
try

//check
if (iwidth<1) or (iheight<1) or (xarea.right<xarea.left) or (xarea.bottom<xarea.top) or (xarea.right<0) or (xarea.left>=iwidth) or (xarea.bottom<0) or (xarea.top>=iheight) then exit;

//init
xcorner:=0;
amin:=smallest(xarea.bottom-xarea.top+1,xarea.right-xarea.left+1);
dh:=iheight;
dw96:=irowsize div sizeof(dc96);
//.left
xleft96:=xarea.left div iblocksize;
if ((xleft96*iblocksize)>xarea.left) then dec(xleft96);
xleft96:=frcrange32(xleft96,0,frcmin32(dw96-1,0));
//.right
xright96:=xarea.right div iblocksize;
if ((xright96*iblocksize)<xarea.right) then inc(xright96);
xright96:=frcrange32(xright96,xleft96,frcmin32(dw96-1,0));
dxstart:=xleft96*iblocksize;

//get
for dy:=0 to (dh-1) do
begin
sr96:=rows[dy];
if (dy>=xarea.top) and (dy<=xarea.bottom) then
   begin
   //fasttimer - ycheck
//   inc(sysfasttimer_ycount); if (sysfasttimer_ycount>=sysfasttimer_ytrigger) then fasttimer_ycheck;

   //.xcorner -> set offset to draw slightly rounded corners - 09apr2020
   if xround then xcorneroffset_solid;
   dx1:=xarea.left+xcorner;
   dx2:=xarea.right-xcorner;

   //.dx
   dx:=dxstart;
   for dx96:=xleft96 to xright96 do
   begin
   bol1:=false;
   dc96:=sr96[dx96];

   //.0
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[0]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.1
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[1]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.2
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[2]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.3
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[3]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.4
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[4]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.5
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[5]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.6
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[6]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.7
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[7]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.8
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[8]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.9
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[9]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.10
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[10]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.11
   if (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[11]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //set
   if bol1 then sr96[dx96]:=dc96;
   end;//dx96
   end;
end;//dy
except;end;
end;
//## fill2 ##
function tmask8.fill2(xarea:trect;xval:byte;xround:boolean):boolean;//29apr2020
var//Speed: 3,300ms -> 1,280ms -> 1,141ms -> 1,080ms -> 700ms -> 672ms (5x faster) -> 500ms
   //Usage: Use in top-down window order -> draw topmost window, then next, then next, and last the bottommost window - 17may2020
   sr96:pmaskrow96;
   dc96:tmaskrgb96;
   dh,amin,xcorner,dxstart,dx96,xleft96,xright96,dx1,dx2,dx,dy,dw96:longint;
   bol1:boolean;
//xxxxxxxxxxxxxxxxxxxxxxx this needs to be replaced with "low__cornersolid()" for a consisten system wide approach - 16may2020
   //## xcorneroffset_solid ##
   procedure xcorneroffset_solid;
   begin
   //.int1 -> set offset to draw slightly rounded corners - 09apr2020
   xcorner:=0;
   case amin of
   3..10:if (dy=xarea.top) or (dy=xarea.bottom)           then xcorner:=1;//1px curved corner
   11..max32:begin//multi-pixel curved corner
      if      (dy=xarea.top)     or (dy=xarea.bottom)     then xcorner:=3
      else if (dy=(xarea.top+1)) or (dy=(xarea.bottom-1)) then xcorner:=2
      else if (dy=(xarea.top+2)) or (dy=(xarea.bottom-2)) then xcorner:=1
      else if (dy=(xarea.top+3)) or (dy=(xarea.bottom-3)) then xcorner:=1
      else if (dy=(xarea.top+4)) or (dy=(xarea.bottom-4)) then xcorner:=1;
      end;
   end;//case
   end;
begin
//defaults
result:=true;
try

//check
if (iwidth<1) or (iheight<1) or (xarea.right<xarea.left) or (xarea.bottom<xarea.top) or (xarea.right<0) or (xarea.left>=iwidth) or (xarea.bottom<0) or (xarea.top>=iheight) then exit;

//init
xcorner:=0;
amin:=smallest(xarea.bottom-xarea.top+1,xarea.right-xarea.left+1);
dh:=iheight;
dw96:=irowsize div sizeof(dc96);
//.left
xleft96:=xarea.left div iblocksize;
if ((xleft96*iblocksize)>xarea.left) then dec(xleft96);
xleft96:=frcrange32(xleft96,0,frcmin32(dw96-1,0));
//.right
xright96:=xarea.right div iblocksize;
if ((xright96*iblocksize)<xarea.right) then inc(xright96);
xright96:=frcrange32(xright96,xleft96,frcmin32(dw96-1,0));
dxstart:=xleft96*iblocksize;

//get
for dy:=0 to (dh-1) do
begin
sr96:=rows[dy];
if (dy>=xarea.top) and (dy<=xarea.bottom) then
   begin
   //fasttimer - ycheck
//   inc(sysfasttimer_ycount); if (sysfasttimer_ycount>=sysfasttimer_ytrigger) then fasttimer_ycheck;

   //.xcorner -> set offset to draw slightly rounded corners - 09apr2020
   if xround then xcorneroffset_solid;
   dx1:=xarea.left+xcorner;
   dx2:=xarea.right-xcorner;

   //.dx
   dx:=dxstart;
   for dx96:=xleft96 to xright96 do
   begin
   bol1:=false;
   dc96:=sr96[dx96];

   //.0
   if (dc96[0]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[0]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.1
   if (dc96[1]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[1]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.2
   if (dc96[2]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[2]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.3
   if (dc96[3]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[3]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.4
   if (dc96[4]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[4]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.5
   if (dc96[5]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[5]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.6
   if (dc96[6]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[6]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.7
   if (dc96[7]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[7]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.8
   if (dc96[8]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[8]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.9
   if (dc96[9]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[9]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.10
   if (dc96[10]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[10]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //.11
   if (dc96[11]=0) and (dx>=dx1) and (dx<=dx2) then
      begin
      dc96[11]:=xval;
      bol1:=true;
      end;//dx
   inc(dx);
   //set
   if bol1 then sr96[dx96]:=dc96;
   end;//dx96
   end;
end;//dy
except;end;
end;
//## mrow ##
procedure tmask8.mrow(dy:longint);
begin//speed: 4,094ms -> 3,400ms -> 2,100ms -> 2,000ms
ilastdy:=dy*irowsize;
end;
//## mval ##
function tmask8.mval(dx:longint):byte;
begin//speed: 4,094ms -> 3,400ms -> 2,100ms -> 2,000ms -> 1350ms
result:=ibytes[ilastdy+dx];
end;
//## mval2 ##
function tmask8.mval2(dx,dy:longint):byte;
begin//speed: 4,094ms -> 3,400ms -> 2,100ms -> 2,000ms
result:=ibytes[(dy*irowsize)+dx];
end;

//## tfastvars #################################################################
//## create ##
constructor tfastvars.create;
begin
//self
inherited create;
//vars
ilimit:=high(vn)+1;//24mar2024: fixed
//clear
clear;
end;
//## destroy ##
destructor tfastvars.destroy;
begin
try
//self
inherited destroy;
except;end;
end;
//## tofile ##
function tfastvars.tofile(x:string;var e:string):boolean;
var
   b:tstr8;
begin
//defaults
result:=false;
try
e:=gecTaskfailed;
b:=nil;
//get
b:=str__new8;
b.text:=text;
result:=io__tofile(x,@b,e);
except;end;
try;str__free(@b);except;end;
end;
//## fromfile ##
function tfastvars.fromfile(x:string;var e:string):boolean;
var
   b:tstr8;
begin
//defaults
result:=false;
try
e:=gecTaskfailed;
b:=nil;
//get
b:=str__new8;
if io__fromfile(x,@b,e) then
   begin
   text:=b.text;
   result:=true;
   end;
except;end;
try;str__free(@b);except;end;
end;
//## settext ##
procedure tfastvars.settext(x:string);
label
   redo;
var
   a:tvars8;
   i,xpos:longint;
   v,n:string;
begin
try
//defaults
a:=nil;
//init
clear;
xpos:=0;
a:=vnew;
a.text:=x;
//get
redo:
if a.xnextname(xpos,n) and xmakename(n,i) then
   begin
   v:=a.s[n];
   vc[i]:=strint64(v);
   vi[i]:=restrict32(vc[i]);
   vb[i]:=(vi[i]<>0);
   vs[i]:=v;
   vm[i]:=4;//1=boolean, 2=longint, 3=comp, 4=string
   goto redo;
   end;
except;end;
try;freeobj(@a);except;end;
end;
//## gettext ##
function tfastvars.gettext:string;
var
   a:tvars8;
   p:longint;
   bol1:boolean;
begin
//defaults
result:='';
try
a:=nil;
//init
a:=vnew;
bol1:=false;
//get
for p:=0 to (icount-1) do
begin
if (vnref1[p]<>0) or (vnref2[p]<>0) then
   begin
   case vm[p] of
   1:a.b[vn[p]]:=vb[p];
   2:a.i[vn[p]]:=vi[p];
   3:a.i64[vn[p]]:=vc[p];
   else a.s[vn[p]]:=vs[p];
   end;//case
   bol1:=true;
   end;
end;//p
//set
if bol1 then result:=a.text;
except;end;
try;freeobj(@a);except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//nnnnnnnnnnnnnnnnnnn
//## setnettext ##
procedure tfastvars.setnettext(x:string);
var
   xname,xvalue:string;
   v,c,xlen,o,t,p:longint;
begin
try
//init
xlen:=low__length(x);
xname:='';
xvalue:='';
t:=1;

//clear
clear;

//get
c:=ssequal;
for p:=1 to xlen do
begin
v:=byte(x[p-1+stroffset]);
if (v=c) or (p=xlen) then
   begin
   //get
   if (v=c) then o:=0 else o:=1;
   xvalue:=strcopy1(x,t,p-t+o);
   t:=p+1;
   //set
   if (c=ssequal) then
       begin
       net__decodestr(xvalue);
       xname:=xvalue;
       c:=ssampersand;
       end
    else
       begin
       //set
//       if storerawvalue then value[_name+'_raw']:=tmp;//28FEB2008
       net__decodestr(xvalue);
       s[xname]:=xvalue;
       //reset
       xname:='';
       c:=ssequal;
       end;
   end;
end;//p
except;end;
end;
//## clear ##
procedure tfastvars.clear;
var
   p:longint;
begin
try
icount:=0;
for p:=0 to (ilimit-1) do
begin
vnref1[p]:=0;
vnref2[p]:=0;
vn[p]:='';
vb[p]:=false;
vi[p]:=0;
vc[p]:=0;
vs[p]:='';
vm[p]:=0;
end;//p
except;end;
end;
//## xmakename ##
function tfastvars.xmakename(xname:string;var xindex:longint):boolean;
var
   ni,nref1,nref2,p:longint;
   c:tcur8;
begin
//defaults
result:=false;
try
xindex:=0;
//check
if (xname='') then exit;
//init
c.val:=low__ref256u(xname);
nref1:=c.ints[0];
nref2:=c.ints[1];
ni:=-1;
//get
for p:=0 to (ilimit-1) do
begin
if (vnref1[p]=nref1) and (vnref2[p]=nref2) then
   begin
   xindex:=p;
   result:=true;
   break;
   end
else if (ni=-1) and (vnref1[p]=0) and (vnref2[p]=0) then ni:=p;
end;//p
//new
if (not result) and (ni>=0) then
   begin
   xindex:=ni;
   vn[xindex]:=xname;
   vnref1[xindex]:=nref1;
   vnref2[xindex]:=nref2;
   result:=true;
   end;
//count
if result and (xindex>=icount) then icount:=xindex+1;
except;end;
end;
//## find ##
function tfastvars.find(xname:string;var xindex:longint):boolean;
var
   nref1,nref2,p:longint;
   c:tcur8;
begin
//defaults
result:=false;
try
xindex:=0;
//check
if (xname='') then exit;
//init
c.val:=low__ref256u(xname);
nref1:=c.ints[0];
nref2:=c.ints[1];
//get
for p:=0 to (ilimit-1) do
begin
if (vnref1[p]=nref1) and (vnref2[p]=nref2) then
   begin
   xindex:=p;
   result:=true;
   break;
   end;
end;//p
except;end;
end;
//## found ##
function tfastvars.found(xname:string):boolean;
var
   xindex:longint;
begin
result:=find(xname,xindex);
end;
//## sfound ##
function tfastvars.sfound(xname:string;var x:string):boolean;
var
   xindex:longint;
begin
result:=find(xname,xindex);
try;if result then x:=vs[xindex] else x:='';except;end;
end;
//## sfound8 ##
function tfastvars.sfound8(xname:string;x:pobject;xappend:boolean;var xlen:longint):boolean;
var
   xindex:longint;
begin
//defaults
result:=false;
try
xlen:=0;
if str__lock(x) and find(xname,xindex) then
   begin
   xlen:=low__length(vs[xindex]);
   if not xappend then str__clear(x);
   result:=str__sadd(x,vs[xindex]);
   end;
except;end;
try;str__unlockautofree(x);except;end;
end;
//## getb ##
function tfastvars.getb(xname:string):boolean;
var
   xindex:longint;
begin
result:=false;
try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:result:=vb[xindex];
   2:result:=(vi[xindex]>=1);
   3:result:=(vc[xindex]>=1);
   else result:=(strint64(vs[xindex])>=1);
   end;//case
   end;
except;end;
end;
//## geti ##
function tfastvars.geti(xname:string):longint;
var
   xindex:longint;
begin
result:=0;
try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:if vb[xindex] then result:=1;
   2:result:=vi[xindex];
   3:result:=restrict32(vc[xindex]);
   else result:=restrict32(strint64(vs[xindex]));
   end;//case
   end;
except;end;
end;
//## getc ##
function tfastvars.getc(xname:string):comp;
var
   xindex:longint;
begin
result:=0;
try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:if vb[xindex] then result:=1;
   2:result:=vi[xindex];
   3:result:=vc[xindex];
   else result:=strint64(vs[xindex]);
   end;//case
   end;
except;end;
end;
//## gets ##
function tfastvars.gets(xname:string):string;
var
   xindex:longint;
begin
result:='';
try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:if vb[xindex] then result:='1' else result:='0';
   2:result:=inttostr(vi[xindex]);
   3:result:=intstr64(vc[xindex]);
   else result:=vs[xindex];
   end;//case
   end;
except;end;
end;
//## getn ##
function tfastvars.getn(xindex:longint):string;
begin
result:='';
try;if (xindex>=0) and (xindex<ilimit) and ((vnref1[xindex]<>0) or (vnref2[xindex]<>0)) then result:=vn[xindex];except;end;
end;
//## getv ##
function tfastvars.getv(xindex:longint):string;
begin
result:='';
try;if (xindex>=0) and (xindex<ilimit) and ((vnref1[xindex]<>0) or (vnref2[xindex]<>0)) then result:=vs[xindex];except;end;
end;
//## getchecked ##
function tfastvars.getchecked(xname:string):boolean;//12jan2024
begin
result:=false;try;result:=strmatch(s[xname],'on');except;end;
end;
//## setchecked ##
procedure tfastvars.setchecked(xname:string;x:boolean);
begin
try;s[xname]:=insstr('on',x);except;end;
end;
//## setb ##
procedure tfastvars.setb(xname:string;x:boolean);
var
   xindex:longint;
begin
try
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=x;
   vi[xindex]:=0;
   vc[xindex]:=0;
   vs[xindex]:='';
   vm[xindex]:=1;//1=boolean, 2=longint, 3=comp, 4=string
   end;
except;end;
end;
//## seti ##
procedure tfastvars.seti(xname:string;x:longint);
var
   xindex:longint;
begin
try
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=x;
   vc[xindex]:=0;
   vs[xindex]:='';
   vm[xindex]:=2;//1=boolean, 2=longint, 3=comp, 4=string
   end;
except;end;
end;
//## setc ##
procedure tfastvars.setc(xname:string;x:comp);
var
   xindex:longint;
begin
try
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=0;
   vc[xindex]:=x;
   vs[xindex]:='';
   vm[xindex]:=3;//1=boolean, 2=longint, 3=comp, 4=string
   end;
except;end;
end;
//## sets ##
procedure tfastvars.sets(xname:string;x:string);
var
   xindex:longint;
begin
try
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=0;
   vc[xindex]:=0;
   vs[xindex]:=x;
   vm[xindex]:=4;//1=boolean, 2=longint, 3=comp, 4=string
   end;
except;end;
end;
//## iinc ##
procedure tfastvars.iinc(xname:string);
begin
iinc2(xname,1);
end;
//## iinc2 ##
procedure tfastvars.iinc2(xname:string;xval:longint);
var
   xindex:longint;
begin
try
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   low__iroll(vi[xindex],xval);
   vc[xindex]:=0;
   vs[xindex]:='';
   vm[xindex]:=2;//1=boolean, 2=longint, 3=comp, 4=string
   end;
except;end;
end;
//## cinc ##
procedure tfastvars.cinc(xname:string);
begin
cinc2(xname,1);
end;
//## cinc2 ##
procedure tfastvars.cinc2(xname:string;xval:comp);
var
   xindex:longint;
begin
try
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=0;
   low__roll64(vc[xindex],xval);
   vs[xindex]:='';
   vm[xindex]:=3;//1=boolean, 2=longint, 3=comp, 4=string
   end;
except;end;
end;

end.
