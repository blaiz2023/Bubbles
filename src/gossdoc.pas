unit gossdoc;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gosswin2, gossroot, gossio, gosswin, gossimg;
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
//## Library.................. Multi-document format processing (gossdoc.pas)
//## Version.................. 1.00.1590 (+20)
//## Items.................... 8
//## Last Updated ............ 16nov2026, 14nov2026, 13mnov2026, 12nov2026, 11nov2026, 10nov2026, 08nov2026, 07nov2026, 06nov2026, 05nov2026, 04nov2026, 03nov2026, 29oct2026, 28oct2026, 25oct2026
//## Lines of Code............ 9,000+
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossdoc.pas ............. Multi-format document procs for decoding/encoding document formats
//## gossepub.pas ............ EPUB generator
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossfold.pas ............ Virtual folder(s) and file viewer(s) for interactive archive support
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossmake.pas ............ Dynamic content generators for interactive archive support
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
//## | doc__*                 | family of procs   | 1.00.055  | 11nov2026   | Multi document procs - 10nov2026, 07nov2026, 06nov2026, 05nov2026
//## | uni__*                 | family of procs   | 1.00.050  | 13nov2026   | Unidoc support procs - 12nov2026, 11nov2026, 10nov2026, 08nov2026
//## | codepoint__*           | family of procs   | 1.00.025  | 06nov2026   | Codepoint procs - 05nov2026
//## | u__*                   | family of procs   | 1.00.040  | 10nov2026   | Unicode procs - 06nov2026, 05nov2026
//## | u8__*                  | family of procs   | 1.00.285  | 12nov2026   | utf-8 procs, 11nov2026, 10nov2026, 06nov2026, 28oct2026, 25oct2026, 16feb2026, 21apr2025, 16mar2025, 15apr2024: created
//## | mail__*                | family of procs   | 1.00.175  | 06nov2026   | Mail related procs (email) - 07apr2025, 21nov2024
//## | rtf__*                 | family of procs   | 1.00.200  | 06nov2026   | Read / write RTF documents - 05nov2026, 04nov2026, 03nov2026, 29oct2026, 28oct2026, 25oct2026
//## | tunidoc                | tobject           | 1.00.740  | 16nov2026   | Universal document - supports unicode, windows-1252 and 7-bit ascii encoding, images, and basic formatting options - 15nov2026, 13nov2026, 11nov2026, 10nov2026, 08nov2026, 07nov2026, 06nov2026, 05nov2026, 04nov2026, 03nov2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================



const

   //u8 ------------------------------------------------------------------------

   u8_addBOM_def                =false;//not required and not recommended for modern utf-8 streams - 12nov2026


   //codepoints ----------------------------------------------------------------

   c_ulabel                     ='Unicode';
   c_8label                     ='Windows-1252';
   c_7label                     ='Ascii 7-bit';
   c_none                       ='Unknown';

   u_codepoint_max              =1114111;
   u_codepoint_limit            =u_codepoint_max + 1;//unicode codepoint range


   //unidoc --------------------------------------------------------------------

   uni_listmax                  =1023;//hard upperlimit - 10nov2026


   //rtf command names ---------------------------------------------------------

   rf_nil                       ='';
   rf_pard                      ='pard';
   rf_plain                     ='plain';
   rf_par                       ='par';
   rf_line                      ='line';
   rf_tab                       ='tab';
   rf_uc                        ='uc';//unicode skipcount
   rf_b                         ='b';
   rf_b1                        ='b1';
   rf_b0                        ='b0';
   rf_i                         ='i';
   rf_i1                        ='i1';
   rf_i0                        ='i0';
   rf_ul                        ='ul';
   rf_ul1                       ='ul1';
   rf_ul0                       ='ul0';
   rf_ulnone                    ='ulnone';
   rf_cf                        ='cf';//foreground color index
   rf_highlight                 ='highlight';//background color index
   rf_highlight_2c              ='hi';//first 2 chars
   rf_fs                        ='fs';//font size in half points (e.g. fs24 = 12pt)
   rf_strike                    ='strike';
   rf_strike1                   ='strike1';
   rf_strike0                   ='strike0';
   rf_ql                        ='ql';//align left
   rf_qc                        ='qc';//align center
   rf_qr                        ='qr';//align right
   rf_qj                        ='qj';//justify
   rf_f                         ='f';//font entry
   rf_u                         ='u';//unicode character
   rf_fonttbl                   ='fonttbl';//font table
   rf_colortbl                  ='colortbl';//color table
   rf_pict                      ='pict';//picture
   rf_goalwidth                 ='goalwidth';
   rf_goalheight                ='goalheight';



   //rtf codes -----------------------------------------------------------------

   rtf_rtf1                     ='rtf1';
   rtf_pard                     ='pard';
   rtf_par                      ='par';
   rtf_plain                    ='plain';//no styles -> e.g. no bold, no italic
   rtf_b                        ='b';//????????????????????????
   rtf_b0                       ='b0';
   rtf_i                        ='i';
   rtf_i0                       ='i0';
   rtf_u                        ='ul';
   rtf_u0                       ='ulnone';
   rtf_h                        ='highlight';
   rtf_hLEN                     =9;
   rtf_s                        ='strike';
   rtf_s0                       ='strike0';
   rtf_tab                      ='tab';
   rtf_left                     ='ql';//align left
   rtf_center                   ='qc';//align center
   rtf_right                    ='qr';//align right
   rtf_pict                     ='pict';
   rtf_object                   ='object';
   rtf_hyperlink                ='hyperlink';
   rtf_fldinst                  ='fldinst';
   rtf_unicodeChar              ='u';
   rtf_canIgnore                ='*';
   rtf_unicodeFallbackCount     ='uc';

type

   //classes
   tunidoc                      =class;


   //document handlers ---------------------------------------------------------

   tdocType                     =( d_none ,d_uni ,d_core ,d_str8 ,d_str9 );

   //d_none  => unknown document handler
   //d_uni   => universal document handler
   //d_core  => TextCore document handler


   //unidoc --------------------------------------------------------------------

   tcodepoint                   =( c_n ,c_7 ,c_8 ,c_u );

   //c_u => full unicode codepoint range: 0..1,114,111  (1,114,112)
   //c_8 => windows-1252 codepoint range: 0..255        (256)
   //c_7 => ascii 7-bit  codepoint range: 0..127        (128)


   //slot style - Important Notice: this style is limited to 1-bit (0/1) bandwidth due to compact data constraints within tunidoc for per slot storage, currently set to 32-bit 4-b (21-bit=unicode codepoint, 10-bit=listID, 1-bit=slot style => 32-bit longint32) - 10nov2026
   tslotstyle                   =( s_t ,s_i );

   //s_t => slot value is a text character
   //s_i => slot value is an image


   //universal document --------------------------------------------------------

   tanydoc                      =tobject;

   punidoc_image                =^tunidoc_image;
   tunidoc_image                =record

    ok                          :boolean;//true=slot in use, false=slot is available
    format                      :string;//format
    data                        :tstr8;
    image                       :tbasicimage;
    imageLoaded                 :boolean;

    end;

   punidoc_font                 =^tunidoc_font;
   tunidoc_font                 =record

    ok                          :boolean;//true=slot in use, false=slot is available
    name                        :string;
    size                        :longint32;
    color                       :longint32;
    bgcolor                     :longint32;
    brcolor                     :longint32;
    align                       :longint32;
    bold                        :boolean;
    italic                      :boolean;
    underline                   :boolean;
    strikeout                   :boolean;
    highlight                   :boolean;

    end;

   punidoc_misc                 =^tunidoc_misc;
   tunidoc_misc                 =record

    orientation                 :longint32;//0=vertical (normal), 1=landscape
    wrapstyle                   :longint32;
    linespacing                 :longint32;
    bgcolor                     :longint32;
    systemscheme                :boolean;
    buildnumber                 :longint32;

    end;

   tunidoc                      =class(tobject)
   private

    lmax                        :longint32;
    ilist                       :array[0..uni_listmax] of tunidoc_image;
    flist                       :array[0..uni_listmax] of tunidoc_font;
    imisc                       :tunidoc_misc;

    tcount                      :longint32;
    tlist                       :tstr8;//list of 32-bit/4-byte slots that each stores "tslot(unicode codepoint)=21-bit, slotStyle(tslotstyle)=1-bit, listID(0..uni_listmax)=10-bit"

    //last font
    lfont                       :tunidoc_font;
    lfont_slot                  :longint32;


    //font procs
    procedure lfont__sync;
//xxxxxxxxxxxxxxxxxxxxxx//uuuuuuuuuuuuuuuuuuuuuuuuuuuu//??????????????????????
   public

    //temp vars
    font                        :tunidoc_font;//font currentl in use

    //create
    constructor create;         virtual;
    destructor  destroy;        override;

    //information
    property  count             :longint32          read tcount;//number of slots in document
    function  info              :string;

    //clear
    function  canclear          :boolean;
    procedure clear;
    procedure flush;
    function  cull              :boolean;//remove abandoned font slots and image slots

    //write -> add character slot
    function  a_r               (const u:longint32;const s:tslotstyle;const vid:longint32):boolean;//add raw slot
    function  a_u               (const xchar:longint32):boolean;//add Unicode char
    function  a_8               (const xchar:longint32):boolean;//add Windows-1252 char
    function  a_7               (const xchar:longint32):boolean;//add Ascii 7-bit char
    function  a_i               (const ximgdata:pobject):boolean;//add image data
    function  a_i2              (const ximgdata:pobject;var islot:longint32):boolean;//add image

    //write -> set character slot (no add)
    function  s_r               (const tslot,u:longint32;const s:tslotstyle;const vid:longint32):boolean;//set raw slot
    function  s_u               (const tslot,xchar:longint32):boolean;//set unicode char
    function  s_8               (const tslot,xchar:longint32):boolean;//set windows-1252 char
    function  s_7               (const tslot,xchar:longint32):boolean;//set ascii 7-bit char

    //read -> get character slot
    function  g_u               (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get unicode char
    function  g_ub              (const tslot:longint32):longint32;//get unicode
    function  g_r               (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var did:longint32):boolean;//get raw slot
    function  g_r0              (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get raw slot
    function  g_8               (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var dcharTranslated:boolean):boolean;//get windows-1252 char
    function  g_8b              (const tslot:longint32):longint32;//get windows-1252 char
    function  g_82              (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get windows-1252 char
    function  g_83              (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var did:longint32;var dcharTranslated:boolean):boolean;//get windows-1252 char
    function  g_7               (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var dcharTranslated:boolean):boolean;//get ascii 7-bit char
    function  g_7b              (const tslot:longint32):longint32;//get 7-bit ascii
    function  g_72              (const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get ascii 7-bit char

    function  findalign         (const tslot:longint32):longint32;//13nov2026, 11nov2026

    //text procs
    function  t_u8              :string;//get utf-8 text
    function  t_u82             (const xfrom0,xlen:longint32):string;//get utf-8 text
    function  t_u83             (const xfrom0,xlen:longint32;const xincludeBOM:boolean):string;//get utf-8 text
    function  t_8               :string;//get windows-1252 text
    function  t_82              (const xfrom0,xlen:longint32):string;//get windows-1252 text - 13nov2026
    function  t_7               :string;//get ascii 7-bit text
    function  t_72              (const xfrom0,xlen:longint32):string;//get windows-1252 text - 13nov2026
    function  t_numList         :string;//get a list of numberical character values as a comma separated list -> for debug

    //misc procs
    function  misc__find        :punidoc_misc;

    //font procs
    function  font__findslot    (const tslot:longint32):punidoc_font;
    procedure font__fromLastSlot;
    function  font__findSlotCount:longint32;//count number of active slots

    //.direct font slot procs
    function  font__slotOK      (const fslot:longint32):boolean;
    procedure font__fromSlot    (const fslot:longint32);
    function  font__slotFlush   (const fslot:longint32):boolean;//07nov2026

    //image procs
    function  image__findslot   (const tslot:longint32):punidoc_image;
    function  image__findwidth  (const tslot:longint32):longint32;
    function  image__findheight (const tslot:longint32):longint32;
    function  image__findformat (const tslot:longint32):string;
    function  image__finddata   (const tslot:longint32):pobject;
    function  image__finddata8  (const tslot:longint32):tstr8;
    function  image__findimg32  (const tslot:longint32):tbasicimage;
    function  image__findSlotCount:longint32;//count number of active slots

    //.direct image slot procs
    function  image__slotOK     (const islot:longint32):boolean;
    function  image__slot       (const islot:longint32):punidoc_image;
    function  image__slotStart  (const islot:longint32):boolean;//06nov2026
    function  image__slotFinish (const islot:longint32):boolean;//06nov2026
    function  image__slotFlush  (const islot:longint32):boolean;//06nov2026
    function  image__makeSlot   (const v:pobject;const xautoCreate:boolean):longint32;
    function  image__getImage   (const islot:longint32;var x:tbasicimage):boolean;

    //io
    function  u8__add           (const s:pobject;var e:string):boolean;//add unicode (utf-8) stream
    function  u8__add2          (const s:pobject;const xfrom,xto:longint32;var e:string):boolean;//add unicode (utf-8) stream
    function  a8__add           (const s:pobject;var e:string):boolean;//add windows-1252 (8-bit ascii) stream
    function  a8__add2          (const s:pobject;const xfrom,xto:longint32;var e:string):boolean;//add windows-1252 (8-bit ascii) stream
    function  a7__add           (const s:pobject;var e:string):boolean;//add 7-bit ascii stream
    function  u8__set           (const s:pobject;var e:string):boolean;//read unicode (utf-8) stream
    function  u8__set2          (const s:pobject;const xfrom,xto:longint32;var e:string):boolean;//read unicode (utf-8) stream
    function  a8__set           (const s:pobject;var e:string):boolean;//read windows-1252 (8-bit ascii) stream
    function  a7__set           (const s:pobject;var e:string):boolean;//read 7-bit ascii stream
    function  u8__get           (const d:pobject;var e:string):boolean;//get unicode (utf-8) stream
    function  u8__get2          (const d:pobject;const xfrom,xto:longint32;var e:string):boolean;//get unicode (utf-8) stream
    function  u8__get3          (const d:pobject;const xfrom,xto:longint32;const xincludeBOM:boolean;var e:string):boolean;//get unicode (utf-8) stream - 12nov2026

    //.udoc
    function  udoc__todata      (const d:pobject;var e:string):boolean;//06nov2026
    function  udoc__todata2     (const d:pobject;const xfrom,xto:longint32;var e:string):boolean;//06nov2026
    function  udoc__fromdata    (const s:pobject;var e:string):boolean;//06nov2026

    //.rtf
    function  rtf__fromdata     (const s:pobject;var e:string):boolean;//06nov2026
    function  rtf__todata       (const d:pobject;var e:string):boolean;//06nov2026
    function  rtf__todata2      (const d:pobject;const xfrom,xto:longint32;var e:string):boolean;//06nov2026

    //.textCore
    function  any__fromcore     (const s:tanydoc;var e:string):boolean;
    function  any__fromcore2    (const s:tanydoc;const xfrom0,xto0:longint32;var e:string):boolean;
    function  any__tocore       (const d:tanydoc;var e:string):boolean;
    function  any__tocore2      (const d:tanydoc;const xfrom0,xto0:longint32;var e:string):boolean;

    //.copyFrom
    function copyfrom           (const s:tunidoc):boolean;
    function copyfrom2          (const s:tunidoc;const xfrom0,xlen:longint32):boolean;
    function copyfrom3          (const s:tunidoc;const xfrom0,xto0:longint32):boolean;//16nov2026

    //font procs
    procedure font__defaults;

    //support procs
    function  usv__int          (const u:longint32;const s:tslotstyle;const vid:longint32):longint32;//10nov2026
    procedure int__usv          (const int32:longint32;var u:longint32;var s:tslotstyle;var vid:longint32);//10nov2026
    function  int__usv2         (const int32:longint32;var u:longint32;var s:tslotstyle;var vid:longint32):boolean;//10nov2026
    procedure int__us           (const int32:longint32;var u:longint32;var s:tslotstyle);//10nov2026
    procedure int__v            (const int32:longint32;var vid:longint32);//11nov2026
    function  int__v2           (const int32:longint32;var vid:longint32):boolean;//11nov2026
    function  docsep1           (const i,xdepthcount:longint32):boolean;//11nov2026

   end;


   //rtf -----------------------------------------------------------------------

   trtf_stackitem               =record

    font                        :tunidoc_font;
    uc                          :longint32;//unicode skip count
    ignorable                   :boolean;//e.g., "\*"
    width                       :longint32;
    height                      :longint32;

    end;

   trtf_stack                   =record

    index                       :longint32;
    count                       :longint32;
    list                        :array[0..99] of trtf_stackitem;

    end;


//start-stop procs -------------------------------------------------------------

procedure gosstext__start;
procedure gosstext__stop;


//info procs -------------------------------------------------------------------

function app__info(const xname:string):string;
function info__doc(xname:string):string;//information specific to this unit of code - 01feb2026


//support procs ----------------------------------------------------------------

function doc__uni:tunidoc;

function doc__todata(const s:tanydoc;const d:pobject;const dformat:string;var e:string):boolean;
function doc__todata2(const s:tanydoc;const d:pobject;const dformat:string;const sfrom,sto:longint32;var e:string):boolean;
function doc__fromdata(const d:tanydoc;const s:pobject;var e:string):boolean;

function doc__fromfile(const s:tanydoc;const sfilename:string;var e:string):boolean;//13nov2026

function doc__ext(const sindex:longint32;var dext:string;var dcanwrite:boolean):boolean;//07nov2026
function doc__ext2(const sindex:longint32;var dext:string;var dcanwrite:boolean;var dmaxformatlevel:longint32):boolean;//07nov2026
function doc__extb(const sindex:longint32):string;

function doc__extSupported(const sext:string):boolean;
function doc__extSupported2(const sext:string;var dcanwrite:boolean;var dmaxformatlevel:longint32):boolean;

function doc__ok(const s:tanydoc):boolean;
function doc__ok2(const s:tanydoc;var xdocType:tdoctype):boolean;
function doc__type(const s:tanydoc):tdoctype;
function doc__typeLabel(const s:tdoctype):string;

function doc__isuni(const s:tanydoc):boolean;
function doc__iscore(const s:tanydoc):boolean;
function doc__isstr8(const s:tanydoc):boolean;
function doc__isstr9(const s:tanydoc):boolean;

function doc__canfont(const s:tanydoc):boolean;
function doc__canfont2(const xdocType:tdoctype):boolean;
function doc__canimage(const s:tanydoc):boolean;
function doc__canimage2(const xdocType:tdoctype):boolean;

function doc__codepointCurrent(const s:tanydoc):tcodepoint;//current codepoint document handler is running at
function doc__codepointCurrentLabel(const s:tanydoc):string;
function doc__codepointLimit(const s:tanydoc):tcodepoint;//max codepoint document handler can handle
function doc__codepointLimitLabel(const s:tanydoc):string;
function doc__codepointSafe(const s:tanydoc;const scodepoint:tcodepoint):tcodepoint;//return a codepoint in range for the document handler


//codepoint procs --------------------------------------------------------------

function codepoint__label(const s:tcodepoint):string;
function codepoint__ok(const s:tcodepoint):boolean;
function codepoint__frcmax(const s,xmax:tcodepoint):tcodepoint;
function codepoint__frcmin(const s,xmin:tcodepoint):tcodepoint;
function codepoint__frcrange(const s,xmin,xmax:tcodepoint):tcodepoint;


//unicode character procs ------------------------------------------------------

function  u__hiSurrogateOK      (const v:longint32):boolean;
function  u__loSurrogateOK      (const v:longint32):boolean;
function  u__surrogateOK        (const v:longint32):boolean;

function  u__to7                (const scharU:longint32;var dchar7:longint32):boolean;//05nov2026 - unicode character -> ascii 7-bit character
function  u__to72               (const scharU:longint32;var dchar7:longint32;var dcharTranslated:boolean):boolean;//10nov2026 - unicode character -> ascii 7-bit character
function  u__to8                (const scharU:longint32;var dchar8:longint32):boolean;//05nov2026 - unicode character -> Windows-1252 character
function  u__to8b               (const scharU:longint32):longint32;
function  u__to82               (const scharU:longint32;var dchar8:longint32;var dcharTranslated:boolean):boolean;//10nov2026, 05nov2026 - unicode character -> Windows-1252 character

function  u__from8              (const schar8:longint32;var dcharU:longint32):boolean;//05nov2026 - Windows-1252 character -> unicode character
function  u__from8b             (const schar8:longint32):longint32;//11nov2026 - Windows-1252 character -> unicode character
function  u__from7              (const schar7:longint32;var dcharU:longint32):boolean;//06nov2026 - ascii 7-bit character -> unicode character
function  u__from7b             (const schar7:longint32):longint32;


//utf-8 procs ------------------------------------------------------------------

function  u8__hasBOM            (const u8:pobject):boolean;
function  u8__hasBOMstr         (const u8:string):boolean;
function  u8__skipBOM           (const u8:pobject;var spos0:longint32):boolean;
function  u8__skipBOMstr        (const u8:string;var spos0:longint32):boolean;
procedure u8__addBOM            (const u8:pobject);//only required for utf-16 and utf-32 and some older legacy Windows apps
procedure u8__addBOMstr         (var u8:string);//12nov2026
function  u8__charLen           (const x:byte):longint32;
function  u8__rc                (const u8:pobject;var spos0,u:longint32):boolean;//read unicode char - 06nov2026
function  u8__rcStr             (const u8:string;var spos0,u:longint32):boolean;//read unicode char - 12nov2026
function  u8__wc                (const u8:pobject;const u:longint32):boolean;//write unicode char
function  u8__wcStr             (var u8:string;const u:longint32):boolean;//write unicode char - 12nov2026

//.utf8 -> windows-1252 (8-bit ascii)
function  u8__to8               (const u8,d8:pobject):boolean;//06nov2026, 16feb2026 - utf8 -> windows-1252 (8-bit ascii)
function  u8__to82              (const u8,d8:pobject;var dcharTranslateCount:longint32):boolean;//10nov2026, 06nov2026, 16feb2026 - utf8 -> windows-1252 (8-bit ascii)
function  u8__to8str            (const u8:string;var d8:string):boolean;
function  u8__to8strb           (const u8:string):string;
function  u8__to82str           (const u8:string;var d8:string;var dcharTranslateCount:longint32):boolean;
function  u8__to83str           (var u8:string):boolean;
function  u8__to84str           (var u8:string;var dcharTranslateCount:longint32):boolean;

//.windows-1252 (8-bit ascii) -> utf8
function  u8__from8             (const s8,u8:pobject):boolean;//06nov2026 - windows-1252 (8-bit ascii) -> utf8
function  u8__from82            (const s8,u8:pobject;const xincludeBOM:boolean):boolean;//12nov2026 - windows-1252 (8-bit ascii) -> utf8
function  u8__from8str          (const s8:string;var u8:string):boolean;
function  u8__from82str         (const s8:string;var u8:string;const xincludeBOM:boolean):boolean;//12nov2026
function  u8__from83str         (var u8:string):boolean;
function  u8__from84str         (var u8:string;const xincludeBOM:boolean):boolean;
function  u8__from8strb         (const s8:string):string;
function  u8__from82strb        (const s8:string;const xincludeBOM:boolean):string;

//.utf8 -> 7-bit ascii
function  u8__to7               (const u8,d7:pobject):boolean;//06nov2026 - utf8 -> 7-bit ascii
function  u8__to72              (const u8,d7:pobject;var dcharTranslateCount:longint32):boolean;//10nov2026, 06nov2026 - utf8 -> 7-bit ascii
function  u8__to7str            (const u8:string;var d7:string):boolean;
function  u8__to7strb           (const u8:string):string;
function  u8__to72str           (const u8:string;var d7:string;var dcharTranslateCount:longint32):boolean;
function  u8__to73str           (var u8:string):boolean;
function  u8__to74str           (var u8:string;var dcharTranslateCount:longint32):boolean;

//.7-bit ascii -> utf8
function  u8__from7             (const s7,u8:pobject):boolean;//06nov2026
function  u8__from72            (const s7,u8:pobject;const xincludeBOM:boolean):boolean;//12nov2026
function  u8__from7str          (const s7:string;var u8:string):boolean;
function  u8__from72str         (const s7:string;var u8:string;const xincludeBOM:boolean):boolean;//12nov2026
function  u8__from73str         (var u8:string):boolean;
function  u8__from74str         (var u8:string;const xincludeBOM:boolean):boolean;
function  u8__from7strb         (const u8:string):string;
function  u8__from72strb        (const u8:string;const xincludeBOM:boolean):string;

//.legacy html utf-8 encoding support
function  utf8__encodetohtml    (s,d:pobject;const dappend,dasfilename,dnoslashes:boolean):boolean;
function  utf8__encodetohtmlstr (const x:string;const xasfilename,xnoslashes:boolean):string;


//mail procs -------------------------------------------------------------------
function mail__date(x:tdatetime):string;
function mail__fromqp(_s:string):string;//quoted-printable, 22mar2024: updated "_" as a space
function mail__encodefield(x:string;xencode:boolean):string;//like subject etc
function mail__extractaddress(x:string):string;//03apr2025
function mail__filteraddresses(x:string;xaddressesonly,xwraponlines:boolean):string;//06apr2025
function mail__diskname(xdate:tdatetime;xsubject:string;xtrycount:longint):string;//21nov2024: fixed ":" oversight
function mail__makemsg(x:pobject;xsenderip,xfrom,xto,xsubject,xmsg:string;xdate:tdatetime;var e:string):boolean;//06apr2025, 09feb2024
function mail__makemsg2(x:pobject;xserverdomain,xuseragent,xsenderip,xfrom,xto,xcc,xbcc,xsubject,xmsg:string;xdate:tdatetime;xattachments:tfastvars;var e:string):boolean;//07apr2025
function mail__writemsg(x:pobject;xsubject,xdestfolder:string):boolean;
function mail__findfield(x:pobject;const xfieldname:string;xoutput:pobject):boolean;
function mail__findfield2(x:pobject;const xfieldname:string;xdecodelines:boolean;xoutput:pobject):boolean;


//rtf procs --------------------------------------------------------------------

function rtf__fromdata(const s:pobject;const dout:tanydoc):boolean;
function rtf__fromdata2(const s:pobject;const dout:tanydoc;const dcodepointLimit:tcodepoint):boolean;//04nov2026

function rtf__defColorTable32(const xslot:longint32;const xforegroundColor:boolean):longint32;
function rtf__deffontName:string;
function rtf__deffontSize:longint32;
function rtf__defalign:longint32;
function rtf__stackInit(var s:trtf_stack):boolean;
function rtf__stackPush(var s:trtf_stack):boolean;
function rtf__stackPull(var s:trtf_stack):boolean;
function rtf__stackSyncFont(const s:trtf_stack;var d:tanydoc;const ddocType:tdoctype):boolean;





//???????????????????????????????????
//???????????????????????????????????
//???????????????????????????????????
//???????????????????????????????????
//???????????????????????????????????
//???????????????????????????????????
procedure rtf__write(const xtextCore,xtextIO:tobject);






//.support procs
function  rtf__readNextSlashValue(const x:tstr8;var xpos0:longint32;const xscanTo0:longint32;var xval:string):boolean;//02nov2026

function  rtf__stopChar(const v:longint32):boolean;
function  rtf__cleanLine(const xline:string):string;


//unidoc procs -----------------------------------------------------------------

function uni__copyfont(const s:tunidoc_font;var d:tunidoc_font):boolean;
function uni__deffontname:string;
function uni__deffontsize:longint32;
function uni__defalign:longint32;
function uni__defcolor:longint32;
function uni__defbgcolor:longint32;
function uni__defbrcolor:longint32;
function uni__defbold:boolean;
function uni__defitalic:boolean;
function uni__defunderline:boolean;
function uni__defstrikeout:boolean;
function uni__defhighlight:boolean;
function uni__orientationSafe(const v:longint32):longint32;
function uni__wrapstyleSafe(const v:longint32):longint32;
function uni__linespacingSafe(const v:longint32):longint32;
function uni__buildnumberSafe(const v:longint32):longint32;
function uni__fontnameSafe(const v:string):string;
function uni__fontsizeSafe(const v:longint32):longint32;
function uni__alignSafe(const v:longint32):longint32;
function uni__fromCoreColor(const v:longint32):longint32;
function uni__toCoreColor(const v:longint32):longint32;
function uni__colorfromHex8(const v:string):longint32;


implementation

uses gossfast, gossnet, gosstext;


var
   system_started_doc           :boolean                      =false;


//start-stop procs -------------------------------------------------------------
procedure gosstext__start;
begin
try

//check
if system_started_doc then exit else system_started_doc:=true;


//init

except;end;
end;

procedure gosstext__stop;
begin
try

//check
if not system_started_doc then exit else system_started_doc:=false;


//close

except;end;
end;


//info procs -------------------------------------------------------------------
function app__info(const xname:string):string;
begin

result                :=info__rootfind(xname);

end;

function info__doc(xname:string):string;//information specific to this unit of code
begin

//defaults
result                :='';

//init
xname                 :=strlow(xname);

//check -> xname must be "gossdoc.*"
if (strcopy1(xname,1,8)='gossdoc.') then strdel1(xname,1,8) else exit;

//get
if      (xname='ver')        then result:='1.00.1590'
else if (xname='date')       then result:='16nov2026'
else if (xname='name')       then result:='Doc'
else
   begin
   //nil
   end;

end;


//doc procs --------------------------------------------------------------------

function doc__uni:tunidoc;
begin

result                :=tunidoc.create;

end;

function doc__ext(const sindex:longint32;var dext:string;var dcanwrite:boolean):boolean;//07nov2026
var
   dmaxformatlevel              :longint32;

begin

result                          :=doc__ext2( sindex ,dext ,dcanwrite ,dmaxformatlevel );

end;

function doc__ext2(const sindex:longint32;var dext:string;var dcanwrite:boolean;var dmaxformatlevel:longint32):boolean;//07nov2026
var
   dpos                         :longint32;

   function xcan:boolean;
   begin

   result                       :=(sindex=dpos);

   inc(dpos);

   end;

   procedure a(const v:string;const vwrite:boolean;const vformatlevel:longint32);
   begin

   result                       :=true;
   dext                         :=strlow(v);
   dcanwrite                    :=vwrite;
   dmaxformatlevel              :=vformatlevel;

   end;

begin

//defaults
result                          :=false;
dext                            :='';
dcanwrite                       :=false;
dpos                            :=0;
dmaxformatlevel                 :=fmlTXT;

//search
if xcan then a(febwd  ,true, fmlBWD );
if xcan then a(febwp  ,true, fmlBWP );
if xcan then a(feudoc ,true, fmlBWP );//07nov2026
if xcan then a(fertf  ,true, fmlBWP );
if xcan then a(fetxt  ,true, fmlTXT );
if xcan then a(fetpub ,true, fmlTXT );//17oct2026
if xcan then a(fedic  ,true, fmlTXT );//17feb2026

//if xcan then a(fehtml ,true, fmlBWP );
//if xcan then a(fehtm  ,true, fmlBWP );
if xcan then a(fehtml ,true, fmlTXT );//for source code only, until HTM/HTML reader/writer procs are finished - 17oct2026
if xcan then a(fehtm  ,true, fmlTXT );
if xcan then a(fexml  ,true, fmlTXT );//17oct2026

end;

function doc__extb(const sindex:longint32):string;
var
   dcanwrite                    :boolean;
   dmaxformatlevel              :longint32;

begin

doc__ext2( sindex ,result ,dcanwrite ,dmaxformatlevel );

end;

function doc__extSupported(const sext:string):boolean;
var
   bol1                         :boolean;
   int1                         :longint32;
begin

result                          :=doc__extSupported2( sext ,bol1 ,int1 );

end;

function doc__extSupported2(const sext:string;var dcanwrite:boolean;var dmaxformatlevel:longint32):boolean;
var
   p                            :longint32;
   int1                         :longint32;
   str1                         :string;
   bol1                         :boolean;

begin

//defaults
result                          :=false;
dcanwrite                       :=false;
dmaxformatlevel                 :=fmlTXT;

//scan
for p:=0 to max32 do
begin

case doc__ext2( p ,str1 ,bol1 ,int1 ) of

true:begin

   if strmatch( str1 ,sext ) then
      begin

      result                    :=true;
      dcanwrite                 :=bol1;
      dmaxformatlevel           :=int1;
      break;

      end;

   end;

else break;

end;//case

end;//p

end;

function doc__todata(const s:tanydoc;const d:pobject;const dformat:string;var e:string):boolean;
begin

result                          :=doc__todata2( s ,d ,dformat ,0 ,max32 ,e );

end;

function doc__todata2(const s:tanydoc;const d:pobject;const dformat:string;const sfrom,sto:longint32;var e:string):boolean;
label
   skipend;

var
   uu                 :tunidoc;
   cc                 :ttextcore;
   sdocType           :tdoctype;
   ddformat           :string;
   etmp               :string;
   bol1               :boolean;
   bol2               :boolean;

   function u:tunidoc;
   begin

   //get
   if      (sdocType=d_uni) then uu       :=tunidoc(s)//cast
   else if (uu=nil)         then uu       :=doc__uni;//create a tunidoc handler

   //set
   result                                 :=uu;

   end;

   function c:ttextcore;
   begin

   //get
   if      (sdocType=d_core) then cc      :=ttextcore(s)//cast
   else if (cc=nil)          then cc      :=doc__core;//create a ttextcore handler

   //set
   result                                 :=cc;

   end;

begin

//defaults
result                :=false;
e                     :=gecTaskfailed;
uu                    :=nil;
cc                    :=nil;
ddformat              :=strlow(dformat);
sdocType              :=doc__type( s );

try

//check
bol1                  :=str__lock( d );

case sdocType of
d_str9      :bol2     :=str__lock( @s );
d_str8      :bol2     :=str__lock( @s );
else         bol2     :=true;
end;//case

if (not bol1) or (not bol2) then goto skipend;

//clear
str__clear( d );

//get
if (ddformat=feudoc) then
   begin

   case sdocType of

   d_uni:begin

      if not u.udoc__todata2 ( d ,sfrom ,sto ,etmp     )   then goto skipend;//u    -> d

      end;

   d_core:begin

      if not u.any__fromcore2( c ,sfrom ,sto ,etmp     )   then goto skipend;//core -> u
      if not u.udoc__todata ( d ,etmp                  )   then goto skipend;//u    -> d

      end;

   else begin

      if not u.u8__set2      ( @s ,sfrom ,sto ,etmp   )   then goto skipend;//s    -> u
      if not u.udoc__todata (  d ,etmp                )   then goto skipend;//u    -> d

      end;

   end;//case

   end

else if (ddformat=fertf) then
   begin

   case sdocType of

   d_uni:begin

      if not u.rtf__todata2  ( d ,sfrom ,sto ,etmp     )   then goto skipend;//u    -> d

      end;

   d_core:begin

      if not u.any__fromcore2( c ,sfrom ,sto ,etmp     )   then goto skipend;//core -> u
      if not u.rtf__todata  ( d ,etmp                  )   then goto skipend;//u    -> d

      end;

   else begin

      if not u.u8__set2     ( @s ,sfrom ,sto ,etmp    )   then goto skipend;//s    -> u
      if not u.rtf__todata  (  d ,etmp                )   then goto skipend;//u    -> d

      end;

   end;//case

   end

else if (ddformat=febwp) or (ddformat=febwd) then
   begin

   case sdocType of

   d_uni:begin

      if not u.any__tocore2 ( c ,sfrom ,sto, etmp     )   then goto skipend;//u    -> core
      if not c.iogetdata3   ( d ,ddformat             )   then goto skipend;//core -> d

      end;

   d_core:begin

      if not c.iogetdata4   ( d ,ddformat ,sfrom ,sto )   then goto skipend;//core -> d

      end;

   else begin

      if not c.iosetdata3   ( @s                                               )  then goto skipend;//s    -> core
      if not c.iogetdata4   (  d ,ddformat ,sfrom ,sto )  then goto skipend;//core -> d

      end;

   end;//case

   end

else if (ddformat=fetxt) then
   begin

   case sdocType of

   d_uni:begin

      if not u.u8__get2     ( d ,sfrom ,sto ,etmp     )   then goto skipend;//u    -> d

      end;

   d_core:begin

      if not c.iogetdata4   ( d ,ddformat ,sfrom ,sto )   then goto skipend;//core -> d

      end;

   else begin

      if not u.u8__set      ( @s ,etmp    )   then goto skipend;//s    -> u
      if not u.u8__get      (  d ,etmp    )   then goto skipend;//u    -> d

      end;

   end;//case

   end

else begin

   e                  :=gecUnsupportedFormat;

   end;

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf( d );

if (uu<>nil) and (uu<>s) then freeobj(@uu);
if (cc<>nil) and (cc<>s) then freeobj(@cc);

case sdocType of
d_str9      :str__uaf( @s );
d_str8      :str__uaf( @s );
end;//case

end;

function doc__fromdata(const d:tanydoc;const s:pobject;var e:string):boolean;
label
   skipend;

var
   uu                 :tunidoc;
   cc                 :ttextcore;
   ddocType           :tdoctype;
   ssformat           :string;
   etmp               :string;
   bol1               :boolean;
   bol2               :boolean;

   function u:tunidoc;
   begin

   //get
   if      (ddocType=d_uni) then uu       :=tunidoc(d)//cast
   else if (uu=nil)         then uu       :=doc__uni;//create a tunidoc handler

   //set
   result                                 :=uu;

   end;

   function c:ttextcore;
   begin

   //get
   if      (ddocType=d_core) then cc      :=ttextcore(d)//cast
   else if (cc=nil)          then cc      :=doc__core;//create a ttextcore handler

   //set
   result                                 :=cc;

   end;

begin

//defaults
result                :=false;
e                     :=gecTaskfailed;
uu                    :=nil;
cc                    :=nil;
ddocType              :=doc__type( d );

try


//check
bol1                  :=str__lock( s );

case ddocType of
d_str9      :bol2     :=str__lock( @d );
d_str8      :bol2     :=str__lock( @d );
else         bol2     :=true;
end;//case

if (not bol1) or (not bol2) then goto skipend;


//init
ssformat              :=strlow(io__anyformatb( s ));


//get
if (ssformat=feudoc) then
   begin

   case ddocType of

   d_uni:begin

      if not u.udoc__fromdata ( s ,etmp     )   then goto skipend;//s    -> u

      end;

   d_core:begin

      if not u.udoc__fromdata ( s ,etmp     )   then goto skipend;//s    -> u
      if not u.any__tocore    ( c ,etmp     )   then goto skipend;//u    -> core

      end;

   else begin

      if not u.u8__set      (  s ,etmp     )   then goto skipend;//s    -> u
      if not u.u8__get      ( @d ,etmp     )   then goto skipend;//u    -> d

      end;

   end;//case

   end

else if (ssformat=fertf) then
   begin

   case ddocType of

   d_uni:begin

      if not u.rtf__fromdata  ( s ,etmp     )   then goto skipend;//s    -> u

      end;

   d_core:begin

      if not u.rtf__fromdata  ( s ,etmp     )   then goto skipend;//s    -> u
      if not u.any__tocore    ( c ,etmp     )   then goto skipend;//u    -> core

      end;

   else begin

      if not u.rtf__fromdata  (  s ,etmp    )   then goto skipend;//s    -> u
      if not u.u8__get        ( @d ,etmp    )   then goto skipend;//u    -> d

      end;

   end;//case

   end

else if (ssformat=febwp) or (ssformat=febwd) then
   begin

   case ddocType of

   d_uni:begin

      if not c.iosetdata3   ( s           )   then goto skipend;//s    -> core
      if not u.any__fromcore( c ,etmp     )   then goto skipend;//core -> u

      end;

   d_core:begin

      if not c.iosetdata3   ( s           )   then goto skipend;//s    -> core

      end;

   else begin

      if not c.iosetdata3   (  s           )  then goto skipend;//s    -> core
      if not c.iogetdata3   ( @d ,ssformat )  then goto skipend;//core -> d

      end;

   end;//case

   end

else begin

   case ddocType of

   d_uni:begin

      if not u.u8__set      ( s ,etmp     )   then goto skipend;//s    -> u

      end;

   d_core:begin

      if not c.iosetdata3   ( @d          )   then goto skipend;//s    -> core

      end;

   else begin

      if not u.u8__set      (  s ,etmp    )   then goto skipend;//s    -> u
      if not u.u8__get      ( @d ,etmp    )   then goto skipend;//u    -> d

      end;

   end;//case

   end;


//successful
result                :=true;

skipend:

except;end;

//free
str__uaf( s );

if (uu<>nil) and (uu<>d) then freeobj(@uu);
if (cc<>nil) and (cc<>d) then freeobj(@cc);

case ddocType of
d_str9      :str__uaf( @d );
d_str8      :str__uaf( @d );
end;//case

end;

function doc__fromfile(const s:tanydoc;const sfilename:string;var e:string):boolean;//13nov2026
label
   skipend;

var
   a        :tobject;

begin

//defaults
result      :=false;
e           :=gecTaskfailed;
a           :=nil;

try

//get
a           :=str__new9;

if not io__fromfile64(sfilename,@a,e) then
   begin

   e        :=gecFileNotFound;

   goto skipend;

   end;
   
if not doc__fromdata( s ,@a ,e )      then goto skipend;

//successful
result      :=true;

skipend:

except;end;

//free
str__free(@a);

end;

function doc__ok(const s:tanydoc):boolean;
begin

if      (s is tunidoc)   then result:=true
else if (s is ttextcore) then result:=true
else if (s is tstr8)     then result:=true
else if (s is tstr9)     then result:=true
else                          result:=false;

end;

function doc__ok2(const s:tanydoc;var xdocType:tdoctype):boolean;
begin

xdocType                        :=doc__type(s);
result                          :=(xdocType<>d_none);

end;

function doc__type(const s:tanydoc):tdoctype;
begin

if      (s is tunidoc)   then result:=d_uni
else if (s is ttextcore) then result:=d_core
else if (s is tstr8)     then result:=d_str8
else if (s is tstr9)     then result:=d_str9
else                          result:=d_none;

end;

function doc__typeLabel(const s:tdoctype):string;
begin

case s of

d_uni       :result:='uni';
d_core      :result:='core';
d_str8      :result:='str8';
d_str9      :result:='str9';
else         result:='';

end;//case

end;

function doc__isuni(const s:tanydoc):boolean;
begin

if      (s is tunidoc)   then result:=true
else                          result:=false;

end;

function doc__iscore(const s:tanydoc):boolean;
begin

if (s is ttextcore)      then result:=true
else                          result:=false;

end;

function doc__isstr8(const s:tanydoc):boolean;
begin

if (s is tstr8)          then result:=true
else                          result:=false;

end;

function doc__isstr9(const s:tanydoc):boolean;
begin

if (s is tstr9)          then result:=true
else                          result:=false;

end;

function doc__canfont(const s:tanydoc):boolean;
begin

result                          :=doc__canfont2( doc__type(s) );

end;

function doc__canfont2(const xdocType:tdoctype):boolean;
begin

case xdocType of

d_uni       :result   :=true;
d_core      :result   :=true;
else         result   :=false;

end;//case

end;

function doc__canimage(const s:tanydoc):boolean;
begin

result                          :=doc__canimage2( doc__type(s) );

end;

function doc__canimage2(const xdocType:tdoctype):boolean;
begin

case xdocType of

d_uni       :result   :=true;
d_core      :result   :=true;
else         result   :=false;

end;//case

end;

function doc__codepointCurrent(const s:tanydoc):tcodepoint;//current codepoint document handler is running at
begin

if      (s is tunidoc)   then result:=c_u
else if (s is ttextcore) then result:=c_8
else if (s is tstr8)     then result:=c_u
else if (s is tstr9)     then result:=c_u
else                          result:=c_n;//none

end;

function doc__codepointCurrentLabel(const s:tanydoc):string;
begin

result                          :=codepoint__label( doc__codepointCurrent(s) );

end;

function doc__codepointLimit(const s:tanydoc):tcodepoint;//max codepoint document handler can handle
begin

if      (s is tunidoc)   then result:=c_u
else if (s is ttextcore) then result:=c_8
else if (s is tstr8)     then result:=c_u
else if (s is tstr9)     then result:=c_u
else                          result:=c_7;

end;

function doc__codepointLimitLabel(const s:tanydoc):string;
begin

result                          :=codepoint__label( doc__codepointLimit(s) );

end;

function doc__codepointSafe(const s:tanydoc;const scodepoint:tcodepoint):tcodepoint;//return a codepoint in range for the document handler
begin

result                          :=codepoint__frcrange( scodepoint ,tcodepoint(0) ,doc__codepointLimit(s) );

end;


//codepoint procs --------------------------------------------------------------

function codepoint__label(const s:tcodepoint):string;
begin

case s of

c_u  :result:=c_ulabel;
c_8  :result:=c_8label;
c_7  :result:=c_7label;
else  result:=c_7label;

end;//case

end;

function codepoint__ok(const s:tcodepoint):boolean;
begin

case s of

c_u  :result:=true;
c_8  :result:=true;
c_7  :result:=true;
else  result:=false;

end;//case

end;

function codepoint__frcmax(const s,xmax:tcodepoint):tcodepoint;
begin

result                          :=tcodepoint(frcmax32(  byte(s) ,byte(xmax)  ));

end;

function codepoint__frcmin(const s,xmin:tcodepoint):tcodepoint;
begin

result                          :=tcodepoint(frcmin32(  byte(s) ,byte(xmin)  ));

end;

function codepoint__frcrange(const s,xmin,xmax:tcodepoint):tcodepoint;
begin

result                          :=tcodepoint(frcrange32(  byte(s) ,byte(xmin) ,byte(xmax)  ));

end;


//unidoc procs -----------------------------------------------------------------

function uni__copyfont(const s:tunidoc_font;var d:tunidoc_font):boolean;
begin

//pass-thru
result                          :=true;

//get
d.ok                            :=s.ok;
d.name                          :=s.name;
d.size                          :=s.size;
d.align                         :=s.align;
d.color                         :=s.color;
d.bgcolor                       :=s.bgcolor;
d.brcolor                       :=s.brcolor;
d.bold                          :=s.bold;
d.italic                        :=s.italic;
d.underline                     :=s.underline;
d.strikeout                     :=s.strikeout;
d.highlight                     :=s.highlight;

end;

function uni__deffontname:string;
begin

result                          :='arial';

end;

function uni__deffontsize:longint32;
begin

result                          :=12;

end;

function uni__defalign:longint32;
begin

result                          :=0;

end;

function uni__defcolor:longint32;
begin

result                          :=0;

end;

function uni__defbgcolor:longint32;
begin

result                          :=clnone;

end;

function uni__defbrcolor:longint32;
begin

result                          :=clnone;

end;

function uni__defbold:boolean;
begin

result                          :=false;

end;

function uni__defitalic:boolean;
begin

result                          :=false;

end;

function uni__defunderline:boolean;
begin

result                          :=false;

end;

function uni__defstrikeout:boolean;
begin

result                          :=false;

end;

function uni__defhighlight:boolean;//10nov2026
begin

result                          :=false;

end;

function uni__orientationSafe(const v:longint32):longint32;
begin

if      (v<0) then result:=0
else if (v>1) then result:=1
else               result:=v;

end;

function uni__wrapstyleSafe(const v:longint32):longint32;
begin

if      (v<0) then result:=0
else if (v>3) then result:=3
else               result:=v;

end;

function uni__linespacingSafe(const v:longint32):longint32;
begin

if      (v<1) then result:=1
else if (v>2) then result:=2
else               result:=v;

end;

function uni__buildnumberSafe(const v:longint32):longint32;
begin

if      (v<0) then result:=0
else               result:=v;

end;

function uni__fontnameSafe(const v:string):string;
begin

result                :=stripwhitespace_lt( v );

if (result='') then
   begin

   result             :=uni__deffontname;

   end;

end;

function uni__fontsizeSafe(const v:longint32):longint32;
begin

if      (v<4   ) then result:=4
else if (v>1000) then result:=1000
else                  result:=v;

end;

function uni__alignSafe(const v:longint32):longint32;
begin

if      (v<0) then result:=0
else if (v>2) then result:=2
else               result:=v;

end;

function uni__fromCoreColor(const v:longint32):longint32;
begin

if      (v=clnone)     then result:=rgba__int( 0 ,0 ,0 ,0 )//32-bit "transparent color" -> rgba(0,0,0,0) transparent color
else if (tint4(v).a=0) then result:=rgba__int( tint4(v).r ,tint4(v).g ,tint4(v).b ,255 )//24-bit color -> 32-bit color
else                        result:=v;//32-bit color

end;

function uni__toCoreColor(const v:longint32):longint32;
begin

if (tint4(v).r=0) and (tint4(v).g=0) and (tint4(v).b=0) and (tint4(v).a=0) then result:=clnone
else                                                                            result:=v;//32-bit color

end;

function uni__colorfromHex8(const v:string):longint32;
begin

result                          :=hex8__int4( v + 'AAAAAAAA' )

end;

constructor tunidoc.create;
var
   p                            :longint32;

begin

//self
inherited create;

//vars
tcount                          :=0;
lmax                            :=uni_listmax;

//range check
if (lmax<1) or (lmax>1023) then
   begin

   showerror('Warning: unidoc.lmax must be in the range of 1..1023');

   end;

//slots
for p:=0 to lmax do
begin

//.image
ilist[p].ok                     :=false;
ilist[p].data                   :=nil;
ilist[p].image                  :=nil;

//.font
flist[p].ok                     :=false;

end;

//.text slots
tlist                           :=str__new8;
tlist.floatsize                 :=max16;//resize less often for more speed

//defaults
flush;

end;

destructor  tunidoc.destroy;
begin
try

//flush
flush;

//free
str__free(@tlist);

//self
inherited destroy;

except;end;
end;

function tunidoc.docsep1(const i,xdepthcount:longint32):boolean;//11nov2026
begin//not unicode compliant//???????????????

case g_8b(i) of

0..38,40..47,58..64,91..96,123..191,247 :result:=true;
ssSingleQuote                           :result:=(xdepthcount>=3) or (docsep1(i-1,xdepthcount+1) or docsep1(i+1,xdepthcount+1));
else                                     result:=false;

end;//case

end;

function tunidoc.info:string;
var
   f                  :array[0..high(flist)] of boolean;
   i                  :array[0..high(flist)] of boolean;
   p                  :longint32;
   u                  :longint32;
   s                  :tslotstyle;
   vid                :longint32;
   tc                 :longint32;
   fc                 :longint32;
   ic                 :longint32;

   procedure ladd(const v:string);
   begin

   result             :=result + v + #10;

   end;

begin

//defaults
result                :='';

//init
low__cls( @f ,sizeof(f) );
low__cls( @i ,sizeof(i) );


//get
for p:=0 to pred(tcount) do
begin

if g_r( p ,u ,s ,vid ) then
   begin

   case s of
   s_t:inc(tc);
   end;//case

   if (vid>=0) and (vid<=lmax) then
      begin

      if (s=s_t) then
         begin

         if not f[ vid ] then
            begin

            f[ vid ]  :=true;
            inc(fc);

            end;

         end

      else if (s=s_i) then
         begin

         if not i[ vid ] then
            begin

            i[ vid ]  :=true;
            inc(ic);

            end;

         end

      end;//vid
      
   end;

end;//p


//set
ladd('-- reference --');
ladd('image.slot.count: ' + k64(image__findSlotCount) );
ladd('font.slot.count: ' + k64(font__findSlotCount) );
ladd('');
ladd('-- document --');
ladd('image.count: ' + k64(ic) );
ladd('font.count: ' + k64(fc) );
ladd('text.count: ' + k64(tc) );

end;

function tunidoc.canclear:boolean;
begin

result                          :=(tcount>=1) or (lfont_slot>=0);

end;

procedure tunidoc.clear;
begin

flush;

end;

procedure tunidoc.flush;
var//Note: proc must free any streams/images currently active
   p                            :longint32;

begin

//flush doc slots
tcount                          :=0;

tlist.clear;

//flush misc
with imisc do
begin

orientation                     :=0;//vertical
bgcolor                         :=clnone;
wrapstyle                       :=0;//none
linespacing                     :=1;
systemScheme                    :=false;//off
buildnumber                     :=0;

end;

//flush font slots
font__slotFlush( 0 );

for p:=1 to lmax do uni__copyfont( flist[0] ,flist[p] );

//flush image slots
for p:=0 to lmax do image__slotFlush( p );

//default font
font__defaults;

end;

function  tunidoc.misc__find:punidoc_misc;
begin

result                :=@imisc;

end;

function tunidoc.font__findSlotCount:longint32;//count number of active slots
var
   p                  :longint32;

begin

//defaults
result                :=0;

//get
for p:=0 to lmax do
begin

if flist[p].ok then inc(result);

end;//p

end;

procedure tunidoc.font__defaults;
begin

//last font
with lfont do
begin

ok                              :=false;
name                            :=uni__deffontname;
size                            :=uni__deffontsize;
align                           :=uni__defalign;
color                           :=uni__defcolor;
bgcolor                         :=uni__defbgcolor;
brcolor                         :=uni__defbrcolor;
bold                            :=uni__defbold;
italic                          :=uni__defitalic;
underline                       :=uni__defunderline;
strikeout                       :=uni__defstrikeout;
highlight                       :=uni__defhighlight;

end;

lfont_slot                      :=-1;//not set

//current font

uni__copyfont( lfont ,font );

font.ok                         :=true;

end;

procedure tunidoc.font__fromSlot(const fslot:longint32);
begin

//check
if (fslot<0) or (fslot>lmax) or (not flist[fslot].ok) then exit;

//get
uni__copyfont( flist[fslot] ,font );

//trigger update
lfont_slot            :=-1;

//sync
lfont__sync;

end;

procedure tunidoc.font__fromLastSlot;
var
   p        :longint32;
   u        :longint32;
   s        :tslotStyle;
   vid      :longint32;

begin

for p:=pred(tcount) downto 0 do
begin

if g_r( p ,u ,s ,vid ) and (s=s_t) and flist[vid].ok then
   begin

   uni__copyfont( flist[vid] ,font );

   lfont__sync;

   break;

   end;

end;//p

end;

procedure tunidoc.lfont__sync;
label
   add;

var
   p                            :longint32;

begin

//force range ------------------------------------------------------------------

font.name                       :=uni__fontnameSafe( font.name   );
font.size                       :=uni__fontsizeSafe( font.size   );
font.align                      :=uni__alignSafe   ( font.align  );


//change detect ----------------------------------------------------------------

if ( lfont_slot      <0               ) then goto add;
if ( lfont.size      <>font.size      ) then goto add;
if ( lfont.align     <>font.align     ) then goto add;
if ( lfont.color     <>font.color     ) then goto add;
if ( lfont.bgcolor   <>font.bgcolor   ) then goto add;
if ( lfont.brcolor   <>font.brcolor   ) then goto add;
if ( lfont.bold      <>font.bold      ) then goto add;
if ( lfont.italic    <>font.italic    ) then goto add;
if ( lfont.underline <>font.underline ) then goto add;
if ( lfont.strikeout <>font.strikeout ) then goto add;
if ( lfont.highlight <>font.highlight ) then goto add;
if not strmatch(lfont.name,font.name  ) then goto add;

//no change -> quit
exit;


//add font slot ----------------------------------------------------------------

add:

//store new values

uni__copyfont( font ,lfont );


//find existing slot

for p:=0 to lmax do
begin

if flist[p].ok then
   begin

   if ( lfont.size          =flist[p].size      ) and
      ( lfont.align         =flist[p].align     ) and
      ( lfont.color         =flist[p].color     ) and
      ( lfont.bgcolor       =flist[p].bgcolor   ) and
      ( lfont.brcolor       =flist[p].brcolor   ) and
      ( lfont.bold          =flist[p].bold      ) and
      ( lfont.italic        =flist[p].italic    ) and
      ( lfont.underline     =flist[p].underline ) and
      ( lfont.strikeout     =flist[p].strikeout ) and
      ( lfont.highlight     =flist[p].highlight ) and
      strmatch(lfont.name  ,flist[p].name       ) then

      begin

      //font exists at this slot
      lfont_slot                :=p;

      exit;

      end;

   end;

end;//p


//find new slot

for p:=0 to lmax do
begin

if not flist[p].ok then
   begin

   uni__copyfont( lfont ,flist[p] );

   flist[p].ok                  :=true;//mark slot in use

   lfont_slot                   :=p;

   exit;

   end;

end;


//at capacity -> fallback to slot #0

lfont_slot                      :=0;


end;

function tunidoc.usv__int(const u:longint32;const s:tslotstyle;const vid:longint32):longint32;//10nov2026
begin

if      (u<0) or (u>2097153)    then result:=0
else if (vid<=0)                then result:=u or ( 0           shl 21 ) or (longint32(s) shl 31)
else if (vid>=uni_listmax)      then result:=u or ( uni_listmax shl 21 ) or (longint32(s) shl 31)
else                                 result:=u or ( vid         shl 21 ) or (longint32(s) shl 31);

end;

procedure tunidoc.int__usv(const int32:longint32;var u:longint32;var s:tslotstyle;var vid:longint32);//10nov2026
begin

//get
u                     :=(int32 shl 11) shr 11;//flush top 11-bits, leaving bottom 21-bits
s                     :=tslotstyle( int32 shr 31 );//flush bottom 31-bits, leaving top 1-bit
vid                   :=(int32 shl 1) shr 22;//flush top 1-bit and bottom 21-bits, leaving 10-bits

//range check
if      (vid<0          ) then vid:=0
else if (vid>uni_listmax) then vid:=uni_listmax;

end;

function tunidoc.int__usv2(const int32:longint32;var u:longint32;var s:tslotstyle;var vid:longint32):boolean;//10nov2026
begin

//pass-thru
result                :=true;

//get
u                     :=(int32 shl 11) shr 11;//flush top 11-bits, leaving bottom 21-bits
s                     :=tslotstyle( int32 shr 31 );//flush bottom 31-bits, leaving top 1-bit
vid                   :=(int32 shl 1) shr 22;//flush top 1-bit and bottom 21-bits, leaving 10-bits

//range check
if      (vid<0          ) then vid:=0
else if (vid>uni_listmax) then vid:=uni_listmax;

end;

procedure tunidoc.int__us(const int32:longint32;var u:longint32;var s:tslotstyle);//10nov2026
begin

//get
u                     :=(int32 shl 11) shr 11;//flush top 11-bits, leaving bottom 21-bits
s                     :=tslotstyle( int32 shr 31 );//flush bottom 31-bits, leaving top 1-bit

end;

procedure tunidoc.int__v(const int32:longint32;var vid:longint32);//11nov2026
begin

//get
vid                   :=(int32 shl 1) shr 22;//flush top 1-bit and bottom 21-bits, leaving 10-bits

//range check
if      (vid<0          ) then vid:=0
else if (vid>uni_listmax) then vid:=uni_listmax;

end;

function tunidoc.int__v2(const int32:longint32;var vid:longint32):boolean;//11nov2026
begin

//pass-thru
result                :=true;

//get
vid                   :=(int32 shl 1) shr 22;//flush top 1-bit and bottom 21-bits, leaving 10-bits

//range check
if      (vid<0          ) then vid:=0
else if (vid>uni_listmax) then vid:=uni_listmax;

end;

function tunidoc.a_r(const u:longint32;const s:tslotstyle;const vid:longint32):boolean;//add raw slot
begin

//defaults
result                                              :=false;

//get
tlist.int4[ tcount * 4 ]                            :=usv__int( u ,s ,vid );

//inc
inc( tcount );

//successful
result                                              :=true;

end;

function tunidoc.a_u(const xchar:longint32):boolean;//add unicode char
begin

//defaults
result                          :=false;

//check
if (xchar<0) or (xchar>u_codepoint_max) then exit;

//get
lfont__sync;

result                          :=a_r( xchar ,s_t ,lfont_slot );

end;

function tunidoc.a_8(const xchar:longint32):boolean;//add windows-1252 char
var
   u                  :longint32;

begin

result                :=u__to8( xchar ,u ) and a_u( u );

end;

function tunidoc.a_7(const xchar:longint32):boolean;//add ascii 7-bit char
var
   u                  :longint32;

begin

result                :=u__to7( xchar ,u ) and a_u( u );

end;

function tunidoc.s_r(const tslot,u:longint32;const s:tslotstyle;const vid:longint32):boolean;//set raw slot
begin

//defaults
result                :=(tslot>=0) and (tslot<tcount);

//get
if result then
   begin

   tlist.int4[ tslot * 4 ]      :=usv__int( u ,s ,vid );

   end;

end;

function tunidoc.s_u(const tslot,xchar:longint32):boolean;//set unicode char
var
   pv                 :longint32;

begin

result                := (tslot>=0) and (tslot<tcount) and (xchar>=0) and (xchar<=u_codepoint_max) and

                         int__v2( tlist.int4[ tcount * 4 ] ,pv )                                   and

                         s_r( tslot ,xchar ,s_t ,pv );//use slot's previous font.slot

end;

function tunidoc.s_8(const tslot,xchar:longint32):boolean;//set windows-1252 char
var
   u                  :longint32;

begin

u__from8( xchar ,u );//windows-1252 -> unicode

result                :=s_u( tslot ,u );

end;

function tunidoc.s_7(const tslot,xchar:longint32):boolean;//set ascii 7-bit char
var
   u                  :longint32;

begin

u__from7( xchar ,u );//7-bit ascii -> unicode

result                :=s_u( tslot ,u );

end;

function tunidoc.g_u(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get unicode char
begin

result                :=g_r0( tslot ,dchar ,dstyle );

end;

function tunidoc.g_ub(const tslot:longint32):longint32;
var
   dstyle             :tslotstyle;

begin

g_r0( tslot ,result ,dstyle );

if (dstyle<>s_t) then result    :=bad_char;

end;

function tunidoc.g_r(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var did:longint32):boolean;//get raw slot
begin

result                :=(tslot>=0) and (tslot<tcount);

if result then
   begin

   int__usv( tlist.pints4[ tslot ] ,dchar ,dstyle ,did );

   end

else begin

   dchar              :=bad_char;
   dstyle             :=s_t;
   did                :=0;

   end;

end;

function tunidoc.g_r0(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get raw slot
begin

result                :=(tslot>=0) and (tslot<tcount);

if result then
   begin

   int__us( tlist.pints4[ tslot ] ,dchar ,dstyle );

   end

else begin

   dchar              :=bad_char;
   dstyle             :=s_t;

   end;

end;

function tunidoc.findalign(const tslot:longint32):longint32;//13nov2026, 11nov2026
var
   p                  :longint32;
   pmax               :longint32;
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

//defaults
result                :=0;//0=left, 1=centre, 2=right
pmax                  :=pred(tcount);

//find
if (tslot>=0) and (tslot<=pmax) then
   begin

   for p:=tslot to pmax do
   begin

   //get
   g_r( p ,u ,s ,v );

   //set
   if (s=s_t) and ((u=10) or (u=13) or (p=pmax)) then//align usually hangs on the trailing return code, also handles missing return code - 13nov2026
      begin

      if flist[ v ].ok then
         begin

         result       :=flist[ v ].align;

         end;

      break;

      end;

   end;//p

   end;

end;

function tunidoc.g_8(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var dcharTranslated:boolean):boolean;//get windows-1252 char
begin

result                          :=g_r0( tslot ,dchar ,dstyle );

if result and (dstyle=s_t) then u__to82( dchar ,dchar ,dcharTranslated )
else                            dcharTranslated:=false;

end;

function tunidoc.g_8b(const tslot:longint32):longint32;
var
   dstyle             :tslotstyle;

begin

if g_r0( tslot ,result ,dstyle ) and (dstyle=s_t) then u__to8( result ,result )
else                                                   result :=bad_char;

end;

function tunidoc.g_82(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get windows-1252 char
begin

result                          :=g_r0( tslot ,dchar ,dstyle );

if result and (dstyle=s_t) then u__to8( dchar ,dchar );

end;

function tunidoc.g_83(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var did:longint32;var dcharTranslated:boolean):boolean;//get windows-1252 char
begin

result                          :=g_r( tslot ,dchar ,dstyle ,did );

if result and (dstyle=s_t) then u__to82( dchar ,dchar ,dcharTranslated )
else                            dcharTranslated:=false;

end;

function tunidoc.g_7(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle;var dcharTranslated:boolean):boolean;//get ascii 7-bit char
begin

result                          :=g_r0( tslot ,dchar ,dstyle );

if result and (dstyle=s_t) then u__to72( dchar ,dchar ,dcharTranslated )
else                            dcharTranslated:=false;

end;

function tunidoc.g_7b(const tslot:longint32):longint32;
var
   dstyle             :tslotstyle;

begin

if g_r0( tslot ,result ,dstyle ) and (dstyle=s_t) then u__to7( result ,result )
else                                                   result :=bad_char;

end;

function tunidoc.g_72(const tslot:longint32;var dchar:longint32;var dstyle:tslotstyle):boolean;//get ascii 7-bit char
begin

result                          :=g_r0( tslot ,dchar ,dstyle );

if result and (dstyle=s_t) then u__to7( dchar ,dchar );

end;

function tunidoc.t_u8:string;//get utf-8 text
begin

result                          :=t_u83( 0 ,tcount ,u8_addBOM_def );

end;

function tunidoc.t_u82(const xfrom0,xlen:longint32):string;//get utf-8 text
begin

result                          :=t_u83( xfrom0 ,xlen ,u8_addBOM_def );

end;

function tunidoc.t_u83(const xfrom0,xlen:longint32;const xincludeBOM:boolean):string;//get utf-8 text
var
   p                            :longint32;
   u                            :longint32;
   s                            :tslotstyle;
   d                            :tstr8;
   donce                        :boolean;

begin

//defaults
result                          :='';
d                               :=nil;
donce                           :=false;

//check
if (xlen<=0) then exit;

try

//init
d                               :=faststr__new8;

//get
for p:=xfrom0 to pred(xfrom0+xlen) do
begin

if (p>=0) and (p<tcount) and g_u( p ,u ,s ) and (s=s_t) then
   begin

   //.add BOM
   if not donce then
      begin

      donce                     :=true;

      if xincludeBOM then u8__addBOM( @d );

      end;

   //.add unicode codepoint
   u8__wc( @d ,u );

   end;

end;//p

//set
result                          :=d.text;//utf-8

except;end;

//free
if (d<>nil) then faststr__free(@d);

end;

function tunidoc.t_8:string;//get windows-1252 text
begin

result                :=t_82( 0 ,tcount );

end;

function tunidoc.t_82(const xfrom0,xlen:longint32):string;//get windows-1252 text - 13nov2026
var
   p                            :longint32;
   dlen                         :longint32;
   dchar                        :longint32;
   dstyle                       :tslotstyle;

begin

//check
if (xlen<=0) then
   begin

   result                       :='';

   exit;

   end;

//defaults
low__setlen( result ,xlen );

//init
dlen                            :=0;

//get
for p:=xfrom0 to pred(xfrom0+xlen) do
begin

if (p>=0) and (p<tcount) and g_82( p ,dchar ,dstyle ) and (dstyle=s_t) and (dchar>=0) and (dchar<=255) then
   begin

   result[dlen+stroffset]       :=char( dchar );

   inc(dlen);

   end;

end;//p

//finalise
if (dlen<>xlen) then low__setlen( result ,dlen );

end;

function tunidoc.t_7:string;//get ascii 7-bit text
begin

result                :=t_72( 0 ,tcount );

end;

function tunidoc.t_72(const xfrom0,xlen:longint32):string;//get windows-1252 text - 13nov2026
var
   p                            :longint32;
   dlen                         :longint32;
   dchar                        :longint32;
   dstyle                       :tslotstyle;

begin

//check
if (xlen<=0) then
   begin

   result                       :='';

   exit;

   end;

//defaults
low__setlen( result ,tcount );

//init
dlen                            :=0;

//get
for p:=xfrom0 to pred(xfrom0+xlen) do
begin

if (p>=0) and (p<tcount) and g_72( p ,dchar ,dstyle ) and (dstyle=s_t) and (dchar>=0) and (dchar<=255) then
   begin

   result[dlen+stroffset]       :=char( dchar );

   inc(dlen);

   end;

end;//p

//finalise
if (dlen<>xlen) then low__setlen( result ,dlen );

end;

function tunidoc.t_numList:string;//get a list of numberical character values as a comma separated list
var
   p                            :longint32;
   dchar                        :longint32;
   dstyle                       :tslotstyle;
   r                            :tstr8;
   dfirst                       :boolean;

begin

//defaults
result                          :='';
r                               :=nil;
dfirst                          :=false;

try

//init
r                               :=str__new8;

//get
for p:=0 to pred(tcount) do
begin

if g_82( p ,dchar ,dstyle ) and (dstyle=s_t) then
   begin

   if dfirst then r.sadd( ',' + intstr32(dchar) )

   else begin

      dfirst                    :=true;

      r.sadd( intstr32(dchar) );

      end;

   end;

end;//p

//set
result                          :=r.text;

except;end;

//free
str__free( @r );

end;

function tunidoc.a_i(const ximgdata:pobject):boolean;//add image
var
   islot                        :longint32;
   
begin

result                          :=a_i2( ximgdata ,islot );

end;

function tunidoc.a_i2(const ximgdata:pobject;var islot:longint32):boolean;//add image
var
   f                            :string;

begin

//defaults
result                          :=false;
islot                           :=-1;

//check
if not str__lock( ximgdata ) then exit;

try

//get
f                               :=io__anyformatb( ximgdata );

if (f<>'') and io__imageExtSupported( f ) then
   begin

   //find or make image slot
   islot                        :=image__makeSlot( ximgdata ,true );

   //add
   result                       :=(islot>=0) and a_r( 0 ,s_i ,islot );//image slot

   end;

except;end;

//free
str__uaf( ximgdata );

end;

function tunidoc.font__slotFlush(const fslot:longint32):boolean;//07nov2026
begin

result                          :=(fslot>=0) and (fslot<=lmax);

if result then
   begin

   with flist[ fslot ] do
   begin

   ok                              :=false;
   name                            :=uni__deffontname;
   size                            :=uni__deffontsize;
   align                           :=uni__defalign;
   color                           :=uni__defcolor;
   bgcolor                         :=uni__defbgcolor;
   brcolor                         :=uni__defbrcolor;
   bold                            :=uni__defbold;
   italic                          :=uni__defitalic;
   underline                       :=uni__defunderline;
   strikeout                       :=uni__defstrikeout;
   highlight                       :=uni__defhighlight;

   end;//with

   end;

end;

function tunidoc.image__slotOK(const islot:longint32):boolean;
begin

result                          :=(islot>=0) and (islot<=lmax) and ilist[ islot ].ok;

end;

function  tunidoc.image__slot(const islot:longint32):punidoc_image;
begin

if image__slotOK( islot ) then result:=@ilist[ islot ]
else                           result:=@ilist[ 0 ];//always return a valid pointer

end;

function  tunidoc.image__findslot(const tslot:longint32):punidoc_image;
var
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) then result:=image__slot( v )
else                                                                                              result:=@ilist[ 0 ];//always return a valid pointer

end;

function tunidoc.image__findSlotCount:longint32;//count number of active slots
var
   p                  :longint32;

begin

//defaults
result                :=0;

//get
for p:=0 to lmax do
begin

if ilist[p].ok then inc(result);

end;//p

end;

function tunidoc.image__slotStart(const islot:longint32):boolean;//06nov2026
begin

//defaults
result                          :=false;

//check
if (islot<0) or (islot>lmax) then exit;

//slot now in use
ilist[ islot ].ok               :=true;
ilist[ islot ].format           :='';//unknown
ilist[ islot ].imageLoaded      :=false;

//create data stream + copy data
if (ilist[ islot ].data=nil)  then ilist[ islot ].data        :=str__new8
else                               ilist[ islot ].data.clear;

if (ilist[ islot ].image=nil) then ilist[ islot ].image       :=misimg32(1,1)
else                               missize(ilist[ islot ].image,1,1);

//successful
result                          :=true;

end;

function tunidoc.image__slotFinish(const islot:longint32):boolean;//06nov2026
var
   dformat            :string;

begin

//defaults
result                          :=false;

//check
if (islot<0) or (islot>lmax) then exit;

//slot now in use
dformat                         :=io__anyformatb( @ilist[ islot ].data );

if io__imageExtSupported( dformat ) then
   begin

   ilist[ islot ].format        :=dformat;
   result                       :=true;

   end

else begin

   image__slotFlush( islot );

   end;

end;

function tunidoc.image__slotFlush(const islot:longint32):boolean;//06nov2026
begin

result                          :=(islot>=0) and (islot<=lmax);

if result then
   begin

   with ilist[ islot ] do
   begin

   //mark not in use
   ok                           :=false;

   //clear
   format                       :='';
   imageLoaded                  :=false;

   //reduce memory -> free data stream
   if (data <>nil) then freeobj( @data  );
   if (image<>nil) then freeobj( @image );

   end;//with

   end;

end;

function tunidoc.image__makeSlot(const v:pobject;const xautoCreate:boolean):longint32;
label
   skipend;

var
   p                            :longint32;
   f                            :string;
   vlen                         :longint32;
   vshort                       :string;
   vshortLen                    :longint32;

begin

//defaults
result                          :=-1;

//check
if not str__lock( v ) then exit;

try

//init
f                               :=io__anyformatb( v );
vlen                            :=str__len32( v );
vshort                          :=str__str1( v ,1 ,1000 );
vshortLen                       :=low__len32( vshort );


//find existing ----------------------------------------------------------------

for p:=0 to lmax do
begin
                                                                                  //fast compare                                     //full compare
if ilist[p].ok and (vlen=ilist[p].data.len32) and strmatch(f,ilist[p].format) and (vshort=str__str1( @ilist[p].data ,1 ,vshortLen )) and (str__text( v )=ilist[p].data.text) then
   begin

   result                       :=p;

   goto skipend;

   end;

end;//p


//find new slot ----------------------------------------------------------------

for p:=0 to lmax do
begin

if not ilist[p].ok then
   begin

   //slot now in use
   ilist[p].ok                                      :=true;
   ilist[p].format                                  :=f;
   ilist[p].imageLoaded                             :=false;

   //create data stream + copy data
   if (ilist[p].data=nil)  then ilist[p].data        :=str__new8;
   if (ilist[p].image=nil) then ilist[p].image       :=misimg32(1,1);

   str__add( @ilist[p].data ,v );

   //return result
   result                                           :=p;

   goto skipend;

   end;

end;


skipend:

except;end;

//free
str__uaf( v );

end;

function tunidoc.image__getImage(const islot:longint32;var x:tbasicimage):boolean;
var
   e                            :string;

begin

//defaults
result                          :=false;
x                               :=nil;

//get
if image__slotOK(islot) then
   begin

   //load
   if (not ilist[islot].imageLoaded) then
      begin

      //mark loaded
      ilist[islot].imageLoaded  :=true;

      //load image from stream
      mis__fromdata( ilist[islot].image ,@ilist[islot].data ,e );

      end;

   //get
   result                       :=true;
   x                            :=ilist[islot].image;

   end;

end;

function tunidoc.image__findwidth(const tslot:longint32):longint32;
var
   x                  :tbasicimage;
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) and image__getImage( v ,x ) then result:=x.width
else                                                                                                                          result:=1;

end;

function tunidoc.image__findheight(const tslot:longint32):longint32;
var
   x                  :tbasicimage;
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) and image__getImage( v ,x ) then result:=x.height
else                                                                                                                          result:=1;

end;

function tunidoc.image__findformat(const tslot:longint32):string;
var
   x                  :tbasicimage;
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) and image__getImage( v ,x ) then result:=ilist[ v ].format
else                                                                                                                          result:='';

end;

function  tunidoc.image__finddata(const tslot:longint32):pobject;
var
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) and image__slotOK( v ) then result:=@ilist[ v ].data
else                                                                                                                     result:=nil;

end;

function  tunidoc.image__finddata8(const tslot:longint32):tstr8;
var
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) and image__slotOK( v ) then result:=ilist[ v ].data
else                                                                                                                     result:=nil;

end;

function  tunidoc.image__findimg32(const tslot:longint32):tbasicimage;
var
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

//defaults
result                          :=nil;

//get
if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_i) then image__getImage( v, result );

end;

function tunidoc.font__slotOK(const fslot:longint32):boolean;
begin

result                          :=(fslot>=0) and (fslot<=lmax) and flist[fslot].ok;

end;

function  tunidoc.font__findslot(const tslot:longint32):punidoc_font;
var
   u                  :longint32;
   s                  :tslotstyle;
   v                  :longint32;

begin

if (tslot>=0) and (tslot<tcount) and int__usv2( tlist.pints4[ tslot ] ,u ,s ,v ) and (s=s_t) and font__slotOK( v ) then result:=@flist[ v ]
else                                                                                                                    result:=@flist[ 0 ];//always return a valid pointer

end;

function  tunidoc.u8__add(const s:pobject;var e:string):boolean;//add unicode (utf-8) stream
begin

result                :=u8__add2( s ,0 ,max32 ,e );

end;

function  tunidoc.u8__add2(const s:pobject;const xfrom,xto:longint32;var e:string):boolean;//add unicode (utf-8) stream
label
   redo ,skipend;

var
   spos0              :longint32;
   slen               :longint32;
   u                  :longint32;

begin

//defaults
result                :=false;
e                     :=gecTaskfailed;

try

//check
if not str__lock(s) then goto skipend;

//init
slen                  :=str__len32( s );

u8__skipBOM( s, spos0 );

//get
redo:

if u8__rc( s ,spos0 ,u ) then a_u( u );

//.loop
if (spos0<slen) then goto redo;

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf(s);

end;

function  tunidoc.a8__add(const s:pobject;var e:string):boolean;//add windows-1252 (8-bit ascii) stream
begin

result                :=a8__add2( s ,0 ,max32 ,e );

end;

function  tunidoc.a8__add2(const s:pobject;const xfrom,xto:longint32;var e:string):boolean;//add windows-1252 (8-bit ascii) stream
label
   skipend;

var
   p                  :longint32;
   f8                 :tstr8;
   f9                 :tstr9;
   v                  :longint32;
   u                  :longint32;
   dfrom              :longint32;
   dto                :longint32;
   dpos               :longint32;

begin

//defaults
result                :=false;
e                     :=gecTaskfailed;

try

//check
if not str__lock(s) then goto skipend;

//init
dfrom                 :=frcrange( xfrom ,0  ,max32 );
dto                   :=frcrange( xto   ,-1 ,max32 );
dpos                  :=0;

str__as89( s ,f8 ,f9 );

//check
if (dto<dfrom) then
   begin

   result             :=true;

   goto skipend;

   end;

//get
for p:=0 to pred(str__len32(s)) do
begin

//.get char
if      (f8<>nil) then v:=f8.pbytes[p]
else if (f9<>nil) then v:=f9.bytes[p]
else                   v:=str__bytes0(s,p);

if u__from8( v ,u ) then
   begin

   if (dpos>=dfrom) and (dpos<=dto) then a_u( u );

   if (dpos>=dto)                   then break;//stop

   inc(dpos);

   end;

end;//p

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf(s);

end;

function  tunidoc.a7__add(const s:pobject;var e:string):boolean;//add 7-bit ascii stream
label
   skipend;

var
   p                  :longint32;
   f8                 :tstr8;
   f9                 :tstr9;
   v                  :longint32;
   u                  :longint32;

begin

//defaults
result                :=false;
e                     :=gecTaskfailed;

try

//check
if not str__lock(s) then goto skipend;

//init
str__as89( s ,f8 ,f9 );

//get
for p:=0 to pred(str__len32(s)) do
begin

//.get char
if      (f8<>nil) then v:=f8.pbytes[p]
else if (f9<>nil) then v:=f9.bytes[p]
else                   v:=str__bytes0(s,p);

if u__from7( v ,u ) then a_u( u );

end;//p

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf(s);

end;

function tunidoc.u8__set(const s:pobject;var e:string):boolean;//read unicode (utf-8) stream
begin

result                :=u8__set2( s ,0 ,max32 ,e );

end;

function  tunidoc.u8__set2(const s:pobject;const xfrom,xto:longint32;var e:string):boolean;//read unicode (utf-8) stream
begin

clear;
result                :=u8__add2( s ,xfrom ,xto ,e );

end;

function tunidoc.a8__set(const s:pobject;var e:string):boolean;//read windows-1252 (8-bit ascii) stream
begin

clear;
result                :=a8__add( s ,e );

end;

function tunidoc.a7__set(const s:pobject;var e:string):boolean;//read 7-bit ascii stream
begin

clear;
result                :=a7__add( s ,e );

end;

function  tunidoc.u8__get(const d:pobject;var e:string):boolean;//get unicode (utf-8) stream
begin

result                :=u8__get3( d ,0 ,max32 ,u8_addBOM_def ,e );

end;

function  tunidoc.u8__get2(const d:pobject;const xfrom,xto:longint32;var e:string):boolean;//get unicode (utf-8) stream
begin

result                :=u8__get3( d ,xfrom ,xto ,u8_addBOM_def ,e );

end;

function  tunidoc.u8__get3(const d:pobject;const xfrom,xto:longint32;const xincludeBOM:boolean;var e:string):boolean;//get unicode (utf-8) stream - 12nov2026
label
   skipend;

var
   p                            :longint32;
   u                            :longint32;
   s                            :tslotstyle;
   donce                        :boolean;
   dfrom                        :longint32;
   dto                          :longint32;

begin

//defaults
result                          :=false;
e                               :=gecTaskfailed;
donce                           :=false;

try

//check
if not str__lock(d) then goto skipend;

//init
dfrom                           :=frcrange( xfrom ,0  ,pred(tcount) );
dto                             :=frcrange( xto   ,-1 ,pred(tcount) );

//clear
str__clear( d );

//get
for p:=dfrom to dto do
begin

if g_u ( p ,u ,s ) and (s=s_t) then
   begin

   //insert BOM header
   if not donce then
      begin

      donce           :=true;

      if xincludeBOM then u8__addBOM( d );

      end;

   //write utf-8 character
   u8__wc( d, u );

   end;

end;//p

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf(d);

end;

function tunidoc.rtf__fromdata(const s:pobject;var e:string):boolean;//06nov2026
begin

e                     :=gecTaskfailed;

//s -> self
result                :=gossdoc.rtf__fromdata( s ,self );

//????????????????????????????????????

end;

function tunidoc.rtf__todata(const d:pobject;var e:string):boolean;//06nov2026
begin

result                :=rtf__todata2( d ,0 ,max32 ,e );

end;

function tunidoc.rtf__todata2(const d:pobject;const xfrom,xto:longint32;var e:string):boolean;//06nov2026
begin

//defaults
result                :=false;
e                     :=gecTaskfailed;

//????????????????????????????????????????????????????????????????????

end;

function  tunidoc.udoc__todata(const d:pobject;var e:string):boolean;//06nov2026
begin

result                :=udoc__todata2( d ,0 ,max32 ,e );

end;

function  tunidoc.udoc__todata2(const d:pobject;const xfrom,xto:longint32;var e:string):boolean;//06nov2026
label
   skipend;

const
   xsep               ='_';
   ximgFragementLen   =900;
   xwriteAllComments  =false;

var
   f8                 :tstr8;//pointer only
   f9                 :tstr9;//pointer only
   f                  :array[0..high(flist)] of boolean;
   i                  :array[0..high(flist)] of boolean;
   p                  :longint32;
   n                  :string;
   u                  :longint32;
   s                  :tslotstyle;
   vid                :longint32;
   t                  :tstr8;
   tline              :tstr8;
   tpos               :longint32;
   dfrom              :longint32;
   dto                :longint32;
   fonce              :boolean;
   ionce              :boolean;

   procedure ladd(const v:string);
   begin

   if      (f8<>nil) then f8.sadd( v + rcode )
   else if (f9<>nil) then f9.sadd( v + rcode )
   else                   str__sadd( d ,v + rcode );

   end;


begin

//defaults
result                :=false;
e                     :=gecTaskfailed;
t                     :=nil;
tline                 :=nil;
fonce                 :=false;
ionce                 :=false;

try

//check
if not str__lock( d ) then goto skipend;

//init
dfrom                           :=frcrange( xfrom ,0  ,pred(tcount) );
dto                             :=frcrange( xto   ,-1 ,pred(tcount) );

low__cls( @f ,sizeof(f) );
low__cls( @i ,sizeof(i) );

str__as89( d, f8 ,f9 );

//clear
str__clear( d );

//scan for used fonts and images
for p:=dfrom to dto do
begin

if g_r( p ,u ,s ,vid ) then
   begin

   case s of

   s_t      :f[vid]:=true;
   s_i      :i[vid]:=true;

   end;//case

   end;

end;//p


//header -----------------------------------------------------------------------

ladd('unidoc1.0');


//body -------------------------------------------------------------------------

//.write misc info
n:='m0' + xsep;

ladd('//document container for images, unicode text, and basic formatting in 7-bit ascii text');

//.info
ladd('');
ladd('//misc');

if xwriteAllComments then
   begin

   ladd('//fixed at slot 0.');
   ladd('//orientation: 0=vertical, 1=landscape.');
   ladd('//bgcolor: page background color in ''rrggbbaa'' hex8 format.');
   ladd('//wrapstyle: 0=none, 1=wrap to window, 2=wrap to page, 3=wrap to manuscript margins.');
   ladd('//linespacing: 1=single line, 2=double line.');
   ladd('//buildnumber: document build number, range 0..'+intstr32(max32)+'.');
   ladd('//systemscheme: use system color scheme for document, 0=false(off), 1=true(on).');

   end;

ladd( n + 'orientation'         + xsep + intstr32(imisc.orientation)  );
ladd( n + 'bgcolor'             + xsep + strlow(int4__hex8(imisc.bgcolor)) );
ladd( n + 'wrapstyle'           + xsep + intstr32(imisc.wrapstyle)    );
ladd( n + 'linespacing'         + xsep + intstr32(imisc.linespacing)  );
ladd( n + 'buildnumber'         + xsep + intstr32(imisc.buildnumber)  );
ladd( n + 'systemscheme'        + xsep + bolstr(imisc.systemscheme)   );

//.write font list
for p:=0 to high(flist) do if f[p] and flist[p].ok then
   begin

   //information
   ladd('');
   ladd('//font.slot: '+intstr32(p)+' (0..'+intstr32(lmax)+')');

   //.once only
   if (not fonce) then
      begin

      fonce           :=true;

      if xwriteAllComments then
         begin

         ladd('//name: font name as utf-8 hex.  Example ''Arial'' = '+str__hex(u8__from82strb('Arial',false),0,false)+'.');//no BOM
         ladd('//size: font size: 1..N pt.  E.g. 12 = 12 points.');
         ladd('//align: 0=left, 1=center, 2=right.');
         ladd('//color: font color in ''rrggbbaa'' hex8 format.');
         ladd('//bgcolor: font background color in ''rrggbbaa'' hex8 format.');
         ladd('//brcolor: font border color in ''rrggbbaa'' hex8 format.');
         ladd('//bold, italic, underline, strikeout and highlight: 0=false(off), 1=true(on).');

         end;

      end;

   n                            :='f' + intstr32(p) + xsep;

   ladd( n + 'name'             + xsep + str__hex(  u8__from82strb(flist[p].name,false)  ,0,false));//encode font name with hex, 8-bit ascii -> utf-8 (no BOM)
   ladd( n + 'size'             + xsep + intstr32(flist[p].size)        );
   ladd( n + 'align'            + xsep + intstr32(flist[p].align)       );
   ladd( n + 'color'            + xsep + strlow(int4__hex8(flist[p].color  )) );
   ladd( n + 'bgcolor'          + xsep + strlow(int4__hex8(flist[p].bgcolor)) );
   ladd( n + 'brcolor'          + xsep + strlow(int4__hex8(flist[p].brcolor)) );
   ladd( n + 'bold'             + xsep + bolstr(flist[p].bold)          );
   ladd( n + 'italic'           + xsep + bolstr(flist[p].italic)        );
   ladd( n + 'underline'        + xsep + bolstr(flist[p].underline)     );
   ladd( n + 'strikeout'        + xsep + bolstr(flist[p].strikeout)     );
   ladd( n + 'highlight'        + xsep + bolstr(flist[p].highlight)     );

   end;//p

//.write image list
for p:=0 to high(ilist) do if i[p] and ilist[p].ok then
   begin

   //init
   n                            :='j' + intstr32(p) + xsep;
   tpos                         :=0;

   if (t=nil    ) then t    :=faststr__new8 else t.clear;
   if (tline=nil) then tline:=faststr__new8 else tline.clear;

   //information
   ladd('');
   ladd('//image.slot: '+intstr32(p)+' (0..'+intstr32(lmax)+')');
   ladd('//image.format: '+io__anyformatb(@ilist[p].data) );

   //.once only
   if not ionce then
      begin

      ionce           :=true;

      if xwriteAllComments then
         begin

         ladd('//one or more binary image fragments in hex.');

         end;

      end;

   //get
   str__tohex( @ilist[p].data ,@t ,ximgFragementLen ,false );//even number of hex per line

   //set
   while str__nextline0( @t ,@tline ,tpos ) do
   begin

   ladd( n + tline.text );

   end;

   end;//p

//.write text character list
ladd('');

if xwriteAllComments then
   begin

   ladd('//document body.  a stream of image slots ''i(image.slot)'', or text slots ''t(font.slot)'+xsep+'(unicode codepoint)''');
   ladd('//with raw unencoded decimal unicode codepoints in the range 0..' + intstr32(u_codepoint_max)+'.' );

   end

else begin

   ladd('//document body');

   end;

for p:=dfrom to dto do
begin

if g_r( p ,u ,s ,vid ) then
   begin

   case s of

   s_t:ladd( 't' + intstr32(vid) + xsep + intstr32(u) );//t<font slot>_<unicode char><return code>
   s_i:ladd( 'i' + intstr32(vid) );

   end;//case

   end;

end;//p

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf( d );
if (t    <>nil) then faststr__free(@t    );
if (tline<>nil) then faststr__free(@tline);

end;

function  tunidoc.udoc__fromdata(const s:pobject;var e:string):boolean;//06nov2026
label
   skipend;

const
   xsep               ='_';

var
   f8                 :tstr8;//pointer only
   f9                 :tstr9;//pointer only
   p                  :longint32;
   lp                 :longint32;
   n                  :string;
   u                  :longint32;
   vid                :longint32;
   t                  :tstr8;
   sline              :tstr8;
   dline              :tstr8;
   spos               :longint32;

   vv1                :longint32;
   vv2                :longint32;
   mv2                :string;
   mv3                :string;

   function snext:boolean;//next line
   begin

   result             :=str__nextline0( s ,@sline ,spos );

   end;

   function mv(const n:byte):boolean;
   label
      skipdone;

   var
      p               :longint32;
      dcount          :longint32;

   begin

   //defaults
   result             :=false;

   //get
   if (sline.len32>=1) and (n=sline.pbytes[0]) then
      begin

      //init
      result          :=true;
      vv1             :=0;
      vv2             :=0;
      mv2             :='';
      mv3             :='';
      dcount          :=0;

      //image -> has no underscore
      if (n=lli) then
         begin

         vv1          :=frcrange32( strint32(sline.str[ 1, sline.len32 ]) ,0 ,lmax );

         goto skipdone;
         
         end;

      //get
      for p:=1 to pred(sline.len32) do
      begin

      if (ssunderscore=sline.pbytes[p]) then
         begin

         case dcount of
         0:begin

            vv1       :=frcrange32( strint32(sline.str[ 1, pred(p) ]) ,0 ,lmax );

            case n of

            llj:begin//image fragment

               dline.clear;

               sline.del( 0 ,p );

               low__fromhex( sline ,dline );

               break;

               end;

            llf:;//font fragment -> continue to stage 2

            llt:begin//text character

               vv2    :=strint32(sline.str[ succ(p) ,sline.len32 ]);

               break;

               end;

            else break;

            end;//case


            end;

         1:begin//stage 2


            case n of

            llf:begin//font fragment

               mv2    :=sline.str[ lp ,p-lp ];
               mv3    :=sline.str[ succ(p) ,sline.len32 ];

               break;

               end;
            else break;

            end;//case


            end;

         end;//case

         //.inc
         inc( dcount );

         lp           :=succ(p);

         end;

      end;//p

      end;//if

   skipdone:

   end;

begin

//defaults
result                :=false;
e                     :=gecTaskfailed;
t                     :=nil;
sline                 :=nil;
dline                 :=nil;

try

//check
if not str__lock( s ) then goto skipend;

//init
clear;

str__as89( s, f8 ,f9 );

spos                  :=0;
sline                 :=faststr__new8;
dline                 :=faststr__new8;

//header -----------------------------------------------------------------------

if not snext                            then goto skipend;
if not strmatch(sline.text,'unidoc1.0') then goto skipend;


//body -------------------------------------------------------------------------

while snext do
begin

if mv( llm ) then//misc fragment
   begin

   if      (mv2='orientation'   ) then imisc.orientation        :=uni__orientationSafe( strint32(mv3)    )
   else if (mv2='bgcolor'       ) then imisc.bgcolor            :=uni__colorfromHex8(mv3)
   else if (mv2='wrapstyle'     ) then imisc.wrapstyle          :=uni__wrapstyleSafe( strint32(mv3)      )
   else if (mv2='linespacing'   ) then imisc.linespacing        :=uni__wrapstyleSafe( strint32(mv3)      )
   else if (mv2='buildnumber'   ) then imisc.buildnumber        :=uni__buildnumberSafe( strint32(mv3)    )
   else if (mv2='systemscheme'  ) then imisc.systemscheme       :=strbol(mv3);

   end

else if mv( llf ) then//font fragment
   begin

   if (vv1>=0) and (vv1<=lmax) then
      begin

      if      (mv2='name'       ) then flist[vv1].name        :=uni__fontnameSafe(u8__to8strb(  hex__str(mv3) ))//utf-8 -> 8-bit ascii
      else if (mv2='size'       ) then flist[vv1].size        :=uni__fontsizeSafe(strint32(mv3) )
      else if (mv2='align'      ) then flist[vv1].align       :=uni__alignSafe(strint32(mv3))
      else if (mv2='color'      ) then flist[vv1].color       :=uni__colorfromHex8(mv3)//32-bit support
      else if (mv2='bgcolor'    ) then flist[vv1].bgcolor     :=uni__colorfromHex8(mv3)//32-bit support
      else if (mv2='brcolor'    ) then flist[vv1].brcolor     :=uni__colorfromHex8(mv3)//32-bit support
      else if (mv2='bold'       ) then flist[vv1].bold        :=strbol(mv3)
      else if (mv2='italic'     ) then flist[vv1].italic      :=strbol(mv3)
      else if (mv2='underline'  ) then flist[vv1].underline   :=strbol(mv3)
      else if (mv2='strikeout'  ) then flist[vv1].strikeout   :=strbol(mv3)
      else if (mv2='highlight'  ) then flist[vv1].highlight   :=strbol(mv3);

      if (not flist[vv1].ok)      then flist[vv1].ok          :=true;

      end;

   end

else if mv( llj ) then//image fragment
   begin

   if (vv1>=0) and (vv1<=lmax) then
      begin

      //start
      if not ilist[vv1].ok then image__slotStart( vv1 );

      //add data fragment
      str__add( @ilist[ vv1 ].data ,@dline );

      end;

   end

else if mv( llt ) then//text slot (character)
   begin

   if (vv2>=0) and (vv2<=u_codepoint_max) and (vv1>=0) and (vv1<=lmax) then
      begin

      a_r( vv2 ,s_t ,vv1 );

      end;

   end

else if mv( lli ) then//image slot
   begin

   if (vv1>=0) and (vv1<=lmax) then
      begin

      a_r( 0 ,s_i ,vv1 );

      end;

   end;

end;//with


//finalise images
for p:=0 to lmax do
begin

if ilist[p].ok then image__slotFinish( p );

end;//p

//cull
cull;

//sync to last font in document
font__fromLastSlot;;

//successful
result                :=true;

skipend:

except;end;

//free
str__uaf( s );
if (t    <>nil) then faststr__free(@t    );
if (sline<>nil) then faststr__free(@sline);
if (dline<>nil) then faststr__free(@dline);

end;

function  tunidoc.any__fromcore(const s:tanydoc;var e:string):boolean;
begin

result                          :=any__fromcore2( s ,0 ,max32 ,e );

end;

function  tunidoc.any__fromcore2(const s:tanydoc;const xfrom0,xto0:longint32;var e:string):boolean;
var
   t                            :ttextcore;
   p                            :longint32;
   ff                           :tfastfont;
   fc                           :tfastchar;
   ltid                         :longint32;
   liid                         :longint32;
   islot                        :longint32;
   dfrom                        :longint32;
   dto                          :longint32;

begin

//defaults
result                          :=false;
e                               :=gecTaskfailed;
ltid                            :=-1;//last text id
liid                            :=-1;//last image id
islot                           :=-1;//last image slot used to store image

//check
if (s is ttextcore) then t      :=ttextcore( s )
else                     exit;

//init
dfrom                           :=frcrange( xfrom0 ,0  ,pred(t.len32) );
dto                             :=frcrange( xto0   ,-1 ,pred(t.len32) );

//clear
clear;

//misc
imisc.orientation               :=low__aorb(0,1,t.landscape);
imisc.wrapstyle                 :=uni__wrapstyleSafe( t.wrapstyle );
imisc.linespacing               :=uni__linespacingSafe( t.linespacing );

//get
for p:=succ(dfrom) to succ(dto) do//1-based
begin

if t.xfastchar( ff ,p ,1 ,fc ) then
   begin

   //.text
   if (fc.cs=wc_t) then
      begin

      //sync font
      if (ltid<>fc.wid) and (fc.wid>=0) and (fc.wid<=lmax) then
         begin

         //init
         ltid         :=fc.wid;

         //get
         with t.tlist[ fc.wid ] do
         begin

         font.name                 :=uni__fontnameSafe( name );
         font.size                 :=uni__fontsizeSafe( size );
         font.align                :=uni__alignSafe( t.xfastfindalign(p) );
         font.color                :=uni__fromCoreColor( color   );
         font.bgcolor              :=uni__fromCoreColor( bgcolor );
         font.brcolor              :=uni__fromCoreColor( brcolor );
         font.bold                 :=bold;
         font.italic               :=italic;
         font.underline            :=underline;
         font.strikeout            :=strikeout;
         font.highlight            :=(bgcolor<>clnone);//10nov2026

         end;//with

         //sync
         lfont__sync;

         end;//if

      //add windows-1252 character
      a_8( fc.c );

      end

   //.image
   else if (fc.cs=wc_i) then
      begin

      //sync image
      if ((liid<>fc.wid) or (islot<0)) and (fc.wid>=0) and (fc.wid<=lmax) then
         begin

         liid         :=fc.wid;

         a_i2( @t.ilist[ fc.wid ].orgdata ,islot );

         end

      //add duplicate image
      else begin

         if (islot>=0) then
            begin

            a_r( 0 ,s_i ,islot );

            end;

         end;

      end;

   end;

end;//p

//successful
result                          :=true;

//remove abandoned fonts/images
cull;

//sync to last font in document
font__fromLastSlot;

end;

function  tunidoc.any__tocore(const d:tanydoc;var e:string):boolean;
begin

result                          :=any__tocore2( d ,0 ,max32 ,e );

end;

function  tunidoc.any__tocore2(const d:tanydoc;const xfrom0,xto0:longint32;var e:string):boolean;
begin

result                          :=(d is ttextcore) and ttextcore(d).any__fromuni2( self ,xfrom0 ,xto0 );

end;

function  tunidoc.cull:boolean;
var
   f                  :array[0..high(flist)] of boolean;
   i                  :array[0..high(flist)] of boolean;
   p                  :longint32;
   u                  :longint32;
   s                  :tslotstyle;
   vslotIndex         :longint32;

begin

//pass-thru
result                          :=true;

//init
low__cls( @f ,sizeof(f) );
low__cls( @i ,sizeof(i) );

//get
for p:=0 to pred(tcount) do
begin

if g_r( p ,u ,s ,vslotIndex ) then
   begin

   case s of

   s_t      :f[vslotIndex]:=true;
   s_i      :i[vslotIndex]:=true;

   end;//case

   end;

end;//p

//cull fonts and images
for p:=0 to lmax do
begin

if flist[p].ok and (not f[p]) then font__slotFlush ( p );
if ilist[p].ok and (not i[p]) then image__slotFlush( p );

end;//p

end;

function tunidoc.copyfrom(const s:tunidoc):boolean;
begin

result                          :=copyfrom3( s ,0 ,pred(max32) );

end;

function tunidoc.copyfrom2(const s:tunidoc;const xfrom0,xlen:longint32):boolean;
begin

result                          :=copyfrom3( s ,xfrom0 ,(xfrom0+pred(xlen)) );

end;

function tunidoc.copyfrom3(const s:tunidoc;const xfrom0,xto0:longint32):boolean;//16nov2026
var
   p                            :longint32;
   uu                           :longint32;
   ss                           :tslotstyle;
   vv                           :longint32;
   lv                           :longint32;

   function dsyncFont:boolean;
   begin

   //defaults
   result                       :=true;//pass-thru

   //get
   if (lv<>vv) then
      begin

      lv                        :=vv;

      uni__copyfont( s.font__findslot(p)^ ,font );

      lfont__sync;

      end;

   end;

begin

//defaults
result                          :=true;
lv                              :=-1;

//clear
clear;

//check
if (s=nil) then exit;//14nov2026

//get
for p:=frcmin32( xfrom0 ,0 ) to frcmax32( xto0 ,pred(s.count) ) do
begin

if s.g_r( p ,uu ,ss ,vv ) then
   begin

   case ss of

   s_t      :if dsyncFont then a_u( uu );
   s_i      :a_i( s.image__finddata(p) );

   end;//case

   end;

end;//p

//cull
if (tcount>=1) then cull;

end;

//unicode characer proces ------------------------------------------------------

function u__hiSurrogateOK(const v:longint32):boolean;
begin

case v of

55296..56319          :result:=true;
else                   result:=false;

end;//case

end;

function u__loSurrogateOK(const v:longint32):boolean;
begin

case v of

56320..57343          :result:=true;
else                   result:=false;

end;//case

end;

function u__surrogateOK(const v:longint32):boolean;
begin

case v of

55296..56319          :result:=true;
56320..57343          :result:=true;
else                   result:=false;

end;//case

end;

function u__to7(const scharU:longint32;var dchar7:longint32):boolean;//05nov2026 - unicode character -> ascii 7-bit character

   procedure i;//as is
   begin

   result             :=true;
   dchar7             :=scharU;

   end;

   procedure s(const v:longint32);//convert
   begin

   result             :=true;
   dchar7             :=v;

   end;

   procedure f;//fallback character
   begin

   result             :=true;

   end;


begin

//not used
result                :=false;//not a character
dchar7                :=bad_char;

//get
case scharU of

//ascii 7-bit -> as is ---------------------------------------------------------

0..127:i;


//extended ascii 8-bit -> 7-bit conversion -------------------------------------

128:f;
129:;//not used
130:s(ssSingleQuote);
131:s(llf);
132:s(ssDoubleQuote);
133..135:f;
136:s(ssPower);
137:f;
138:s(uuS);
139:s(ssLessThan);
140:f;
141:;//not used
142:s(uuZ);
143..144:;//not used
145:s(ssSingleQuote);
146:s(ssSingleQuote);
147:s(ssDoubleQuote);
148:s(ssDoubleQuote);
149:s(ssAsterisk);
150:s(ssDash);
151:s(ssDash);
152:s(ssSquiggle);
153:f;
154:s(lls);
155:s(ssMoreThan);
156:f;
157:;//not used
158:s(llz);
159:s(uuY);
160:s(ssSpace);
161..165:f;
166:s(ssPipe);
167..172:f;
173:s(ssDash);
174..177:f;
178:s(nn2);
179:s(nn3);
180:s(ssSingleQuote);
181:s(llu);//micro
182:f;
183:s(ssDot);
184:f;
185:s(nn1);
186..191:f;
192..197:s(uuA);
198:f;
199:s(uuC);
200..203:s(uuE);
204..207:s(uuI);
208:f;
209:s(uuN);
210..214:s(uuO);
215:s(llx);
216:s(uuO);
217..220:s(uuU);
221:s(uuY);
222..223:f;
224..229:s(lla);
230:f;
231:s(llc);
232..235:s(lle);
236..239:s(lli);
240:f;
241:s(lln);
242..246:s(llo);
247:s(37);//divide
248:s(llo);
249..252:s(llu);
253:s(lly);
254:f;
255:s(lly);


//unicode -> 7-bit ascii conversion --------------------------------------------

8218:s(sssinglequote);//Single low-9 quotation mark
402 :s(llf);//Latin small letter f with hook
8222:s(ssdoublequote);//Double low-9 quotation mark
//8230:s(133);//Horizontal ellipsis
//8224:s(134);//Dagger
//8225:s(135);//Double dagger
//710 :s(136);//Modifier letter circumflex accent
//8240:s(137);//Per mille sign
352 :s(uuS);//Latin capital letter S with caron
8249:s(ssLessThan);//Single left-pointing angle quotation
//338 :s(140);//Latin capital ligature OE
//141 not used
381 :s(uuZ);//Latin capital letter Z with caron
//143 not used
//144 not used
8209:s(ssdash);//non-breaking dash -> dash
8216:s(sssinglequote);//Left single quotation mark
8217:s(sssinglequote);//Right single quotation mark
8220:s(ssdoublequote);//Left double quotation mark
8221:s(ssdoublequote);//Right double quotation mark
8226:s(ssasterisk);//bullet
8211:s(ssdash);//En dash
8212:s(ssdash);//Em dash
732 :s(126);//Small tilde
//8482:s(153);//Trade mark sign
353 :s(llS);//Latin small letter S with caron
8250:s(ssMoreThan);//Single right-pointing angle quotation mark
//339 :s(156);//Latin small ligature oe
//157 not used
382 :s(llz);//Latin small letter z with caron
376 :s(uuY);//Latin capital letter Y with diaeresis

else f;

end;//case

end;

function u__to72(const scharU:longint32;var dchar7:longint32;var dcharTranslated:boolean):boolean;//10nov2026 - unicode character -> ascii 7-bit character

   procedure i;//as is
   begin

   result             :=true;
   dchar7             :=scharU;

   end;

   procedure s(const v:longint32);//convert
   begin

   result             :=true;
   dchar7             :=v;
   dcharTranslated    :=true;

   end;

   procedure f;//fallback character
   begin

   result             :=true;
   dcharTranslated    :=true;

   end;


begin

//not used
result                :=false;//not a character
dchar7                :=bad_char;
dcharTranslated       :=false;

//get
case scharU of

//ascii 7-bit -> as is ---------------------------------------------------------

0..127:i;


//extended ascii 8-bit -> 7-bit conversion -------------------------------------

128:f;
129:;//not used
130:s(ssSingleQuote);
131:s(llf);
132:s(ssDoubleQuote);
133..135:f;
136:s(ssPower);
137:f;
138:s(uuS);
139:s(ssLessThan);
140:f;
141:;//not used
142:s(uuZ);
143..144:;//not used
145:s(ssSingleQuote);
146:s(ssSingleQuote);
147:s(ssDoubleQuote);
148:s(ssDoubleQuote);
149:s(ssAsterisk);
150:s(ssDash);
151:s(ssDash);
152:s(ssSquiggle);
153:f;
154:s(lls);
155:s(ssMoreThan);
156:f;
157:;//not used
158:s(llz);
159:s(uuY);
160:s(ssSpace);
161..165:f;
166:s(ssPipe);
167..172:f;
173:s(ssDash);
174..177:f;
178:s(nn2);
179:s(nn3);
180:s(ssSingleQuote);
181:s(llu);//micro
182:f;
183:s(ssDot);
184:f;
185:s(nn1);
186..191:f;
192..197:s(uuA);
198:f;
199:s(uuC);
200..203:s(uuE);
204..207:s(uuI);
208:f;
209:s(uuN);
210..214:s(uuO);
215:s(llx);
216:s(uuO);
217..220:s(uuU);
221:s(uuY);
222..223:f;
224..229:s(lla);
230:f;
231:s(llc);
232..235:s(lle);
236..239:s(lli);
240:f;
241:s(lln);
242..246:s(llo);
247:s(37);//divide
248:s(llo);
249..252:s(llu);
253:s(lly);
254:f;
255:s(lly);


//unicode -> 7-bit ascii conversion --------------------------------------------

8218:s(sssinglequote);//Single low-9 quotation mark
402 :s(llf);//Latin small letter f with hook
8222:s(ssdoublequote);//Double low-9 quotation mark
//8230:s(133);//Horizontal ellipsis
//8224:s(134);//Dagger
//8225:s(135);//Double dagger
//710 :s(136);//Modifier letter circumflex accent
//8240:s(137);//Per mille sign
352 :s(uuS);//Latin capital letter S with caron
8249:s(ssLessThan);//Single left-pointing angle quotation
//338 :s(140);//Latin capital ligature OE
//141 not used
381 :s(uuZ);//Latin capital letter Z with caron
//143 not used
//144 not used
8209:s(ssdash);//non-breaking dash -> dash
8216:s(sssinglequote);//Left single quotation mark
8217:s(sssinglequote);//Right single quotation mark
8220:s(ssdoublequote);//Left double quotation mark
8221:s(ssdoublequote);//Right double quotation mark
8226:s(ssasterisk);//bullet
8211:s(ssdash);//En dash
8212:s(ssdash);//Em dash
732 :s(126);//Small tilde
//8482:s(153);//Trade mark sign
353 :s(llS);//Latin small letter S with caron
8250:s(ssMoreThan);//Single right-pointing angle quotation mark
//339 :s(156);//Latin small ligature oe
//157 not used
382 :s(llz);//Latin small letter z with caron
376 :s(uuY);//Latin capital letter Y with diaeresis

else f;

end;//case

end;

function u__to8b(const scharU:longint32):longint32;
begin

u__to8( scharU ,result );

end;

function u__to8(const scharU:longint32;var dchar8:longint32):boolean;//05nov2026 - unicode character -> Windows-1252 character

   procedure i;//as is
   begin

   result             :=true;
   dchar8             :=scharU;

   end;

   procedure s(const v:longint32);//convert
   begin

   result             :=true;
   dchar8             :=v;

   end;

   procedure f;//fallback character
   begin

   result             :=true;

   end;

begin

//not used
result                :=false;//not a character
dchar8                :=bad_char;

//get
case scharU of

//ascii 7-bit -> as is ---------------------------------------------------------

0..127:i;


//extended ascii 8-bit -> as is ------------------------------------------------

128:i;
129:;//not used
130..140:i;
141:;//not used
142:i;
143..144:;//not used
145..156:i;
157:;//not used
158..255:i;


//unicode -> 8-bit ascii conversion --------------------------------------------

8364:s(128);//euro sign
//129 not used
8218:s(130);//Single low-9 quotation mark
402 :s(131);//Latin small letter f with hook
8222:s(132);//Double low-9 quotation mark
8230:s(133);//Horizontal ellipsis
8224:s(134);//Dagger
8225:s(135);//Double dagger
710 :s(136);//Modifier letter circumflex accent
8240:s(137);//Per mille sign
352 :s(138);//Latin capital letter S with caron
8249:s(139);//Single left-pointing angle quotation
338 :s(140);//Latin capital ligature OE
//141 not used
381 :s(142);//Latin capital letter Z with caron
//143 not used
//144 not used
8209:s(45);//non-breaking dash -> dash
8216:s(145);//Left single quotation mark
8217:s(146);//Right single quotation mark
8220:s(147);//Left double quotation mark
8221:s(148);//Right double quotation mark
8226:s(149);//bullet
8211:s(150);//En dash
8212:s(151);//Em dash
732 :s(152);//Small tilde
8482:s(153);//Trade mark sign
353 :s(154);//Latin small letter S with caron
8250:s(155);//Single right-pointing angle quotation mark
339 :s(156);//Latin small ligature oe
//157 not used
382 :s(158);//Latin small letter z with caron
376 :s(159);//Latin capital letter Y with diaeresis

else f;

end;//case

end;

function u__to82(const scharU:longint32;var dchar8:longint32;var dcharTranslated:boolean):boolean;//10nov2026, 05nov2026 - unicode character -> Windows-1252 character

   procedure i;//as is
   begin

   result             :=true;
   dchar8             :=scharU;

   end;

   procedure s(const v:longint32);//convert
   begin

   result             :=true;
   dchar8             :=v;
   dcharTranslated    :=true;

   end;

   procedure f;//fallback character
   begin

   result             :=true;
   dcharTranslated    :=true;

   end;

begin

//not used
result                :=false;//not a character
dcharTranslated       :=false;
dchar8                :=bad_char;

//get
case scharU of

//ascii 7-bit -> as is ---------------------------------------------------------

0..127:i;


//extended ascii 8-bit -> as is ------------------------------------------------

128:i;
129:;//not used
130..140:i;
141:;//not used
142:i;
143..144:;//not used
145..156:i;
157:;//not used
158..255:i;


//unicode -> 8-bit ascii conversion --------------------------------------------

8364:s(128);//euro sign
//129 not used
8218:s(130);//Single low-9 quotation mark
402 :s(131);//Latin small letter f with hook
8222:s(132);//Double low-9 quotation mark
8230:s(133);//Horizontal ellipsis
8224:s(134);//Dagger
8225:s(135);//Double dagger
710 :s(136);//Modifier letter circumflex accent
8240:s(137);//Per mille sign
352 :s(138);//Latin capital letter S with caron
8249:s(139);//Single left-pointing angle quotation
338 :s(140);//Latin capital ligature OE
//141 not used
381 :s(142);//Latin capital letter Z with caron
//143 not used
//144 not used
8209:s(45);//non-breaking dash -> dash
8216:s(145);//Left single quotation mark
8217:s(146);//Right single quotation mark
8220:s(147);//Left double quotation mark
8221:s(148);//Right double quotation mark
8226:s(149);//bullet
8211:s(150);//En dash
8212:s(151);//Em dash
732 :s(152);//Small tilde
8482:s(153);//Trade mark sign
353 :s(154);//Latin small letter S with caron
8250:s(155);//Single right-pointing angle quotation mark
339 :s(156);//Latin small ligature oe
//157 not used
382 :s(158);//Latin small letter z with caron
376 :s(159);//Latin capital letter Y with diaeresis

else f;

end;//case

end;

function u__from8b(const schar8:longint32):longint32;
begin

u__from8( schar8 ,result );

end;

function u__from8(const schar8:longint32;var dcharU:longint32):boolean;//05nov2026 - Windows-1252 character -> unicode character

   procedure i;//as is
   begin

   dcharU             :=schar8;
   result             :=true;

   end;

   procedure s(const v:longint32);//convert
   begin

   dcharU             :=v;
   result             :=true;

   end;

   procedure f;//fallback character
   begin

   result             :=true;

   end;

begin

//not used
result                :=false;//not a character
dcharU                :=bad_char;

case schar8 of

//ascii 7-bit -> as is ---------------------------------------------------------

0..127:i;


//extended ascii 8-bit -> as is ------------------------------------------------

128:s(8364);
129:;//not used
130:s(8218);
131:s(402 );
132:s(8222);
133:s(8230);
134:s(8224);//U+2020
135:s(8225);
136:s(710 );//U+02C6
137:s(8240);
138:s(352 );
139:s(8249);
140:s(338 );
141:;//not used
142:s(381 );
143..144:;//not used
145:s(8216);
146:s(8217);
147:s(8220);
148:s(8221);
149:s(8226);
150:s(8211);
151:s(8212);
152:s(732 );
153:s(8482);
154:s(353 );
155:s(8250);
156:s(339 );
157:;//not used
158:s(382 );
159:s(376 );

//.as is
160..255:i;

end;//case

end;

function u__from7b(const schar7:longint32):longint32;
begin

u__from7( schar7 ,result );

end;

function u__from7(const schar7:longint32;var dcharU:longint32):boolean;//06nov2026 - ascii 7-bit character -> unicode character

begin

case schar7 of

0..127:begin

   result             :=true;//OK
   dcharU             :=schar7;

   end;

else begin

   result             :=false;//not a character
   dcharU             :=bad_char;

   end;
   
end;//case

end;


//Utf-8 procs ------------------------------------------------------------------

function u8__hasBOM(const u8:pobject):boolean;
begin//Optional BOM code is: "EF BB BF" => 239,187,191

result                := (str__bytes0(u8,0)=239) and
                         (str__bytes0(u8,1)=187) and
                         (str__bytes0(u8,2)=191);

end;

function u8__hasBOMstr(const u8:string):boolean;
begin//Optional BOM code is: "EF BB BF" => 239,187,191

result                := (low__len32(u8)>=3)    and
                         (u8[0+stroffset]=#239) and
                         (u8[0+stroffset]=#187) and
                         (u8[0+stroffset]=#191);

end;

function u8__skipBOM(const u8:pobject;var spos0:longint32):boolean;
begin

result                :=u8__hasBOM(u8);

case result of

true:spos0            :=3;
else spos0            :=0;

end;//case

end;

function u8__skipBOMstr(const u8:string;var spos0:longint32):boolean;
begin

result                :=u8__hasBOMstr(u8);

case result of

true:spos0            :=3;
else spos0            :=0;

end;//case

end;

procedure u8__addBOM(const u8:pobject);
begin

str__addbyt1( u8, 239 );
str__addbyt1( u8, 187 );
str__addbyt1( u8, 191 );

end;

procedure u8__addBOMstr(var u8:string);//12nov2026
begin

u8                    :=u8 + #239#187#191;

end;

function u8__charLen(const x:byte):longint32;
begin

if      (x>=240) then result:=4 //4 byte character
else if (x>=224) then result:=3 //3 byte
else if (x>=192) then result:=2 //2 byte
else                  result:=1;//1 byte -> pure ascii (0..127)

end;

function u8__rc(const u8:pobject;var spos0,u:longint32):boolean;//read unicode char - 06nov2026
const//u = unicode codepoint
     //Important: Always increments the "spos0" data pointer, regardless of any errors
   vm                 =64;
   vm2                =vm*vm;
   vm3                =vm*vm*vm;

var
   v1                 :longint32;
   v2                 :longint32;
   v3                 :longint32;
   v4                 :longint32;

   procedure dansi1;//emergency fallback
   begin

   u                  :=str__bytes0(u8,spos0);
   result             :=true;

   inc(spos0,1);

   end;

begin

//defaults
result                :=false;
u                     :=bad_char;

//get
case u8__charlen( str__bytes0(u8,spos0) ) of
1:begin

   v1                 :=str__bytes0(u8,spos0);

   if (v1>=0) and (v1<=127) then
      begin

      result          :=true;
      u               :=str__bytes0(u8,spos0);

      inc(spos0,1);

      end

   else dansi1;

   end;

2:begin

   v1                 :=str__bytes0(u8,spos0  )-192;
   v2                 :=str__bytes0(u8,spos0+1)-128;

   if (v1>=0) and (v2>=0) then
      begin

      result          :=true;
      u               :=(v1*vm) + v2;

      inc(spos0,2);

      end

   else dansi1;

   end;

3:begin

   v1                 :=str__bytes0(u8,spos0  )-224;
   v2                 :=str__bytes0(u8,spos0+1)-128;
   v3                 :=str__bytes0(u8,spos0+2)-128;

   if (v1>=0) and (v2>=0) and (v3>=0) then
      begin

      result          :=true;
      u               :=(v1*vm2) + (v2*vm) + v3;

      inc(spos0,3);

      end

   else dansi1;

   end;

4:begin

   v1                 :=str__bytes0(u8,spos0  )-240;
   v2                 :=str__bytes0(u8,spos0+1)-128;
   v3                 :=str__bytes0(u8,spos0+2)-128;
   v4                 :=str__bytes0(u8,spos0+3)-128;

   if (v1>=0) and (v2>=0) and (v3>=0) and (v4>=0) then
      begin

      result          :=true;
      u               :=(v1*vm3) + (v2*vm2) + (v3*vm) + v4;

      inc(spos0,4);

      end

   else dansi1;

   end

else begin

   inc(spos0,1);

   end;

end;//case

end;

function u8__rcStr(const u8:string;var spos0,u:longint32):boolean;//read unicode char - 11nov2026
const//u = unicode codepoint
     //Important: Always increments the "spos0" data pointer, regardless of any errors
   vm                 =64;
   vm2                =vm*vm;
   vm3                =vm*vm*vm;

var
   v1                 :longint32;
   v2                 :longint32;
   v3                 :longint32;
   v4                 :longint32;
   ulen               :longint32;

   function g8(const xpos0:longint32):byte;
   begin

   if (xpos0>=0) and (xpos0<ulen) then result:=byte(u8[xpos0+stroffset])
   else                                result:=0;

   end;

   procedure dansi1;//emergency fallback
   begin

   u                  :=g8(spos0);
   result             :=true;

   inc(spos0,1);

   end;

begin

//defaults
result                :=false;
u                     :=bad_char;
ulen                  :=low__len32( u8 );

//get
case u8__charlen( g8(spos0) ) of
1:begin

   v1                 :=g8(spos0);

   if (v1>=0) and (v1<=127) then
      begin

      result          :=true;
      u               :=g8(spos0);

      inc(spos0,1);

      end

   else dansi1;

   end;

2:begin

   v1                 :=g8(spos0  )-192;
   v2                 :=g8(spos0+1)-128;

   if (v1>=0) and (v2>=0) then
      begin

      result          :=true;
      u               :=(v1*vm) + v2;

      inc(spos0,2);

      end

   else dansi1;

   end;

3:begin

   v1                 :=g8(spos0  )-224;
   v2                 :=g8(spos0+1)-128;
   v3                 :=g8(spos0+2)-128;

   if (v1>=0) and (v2>=0) and (v3>=0) then
      begin

      result          :=true;
      u               :=(v1*vm2) + (v2*vm) + v3;

      inc(spos0,3);

      end

   else dansi1;

   end;

4:begin

   v1                 :=g8(spos0  )-240;
   v2                 :=g8(spos0+1)-128;
   v3                 :=g8(spos0+2)-128;
   v4                 :=g8(spos0+3)-128;

   if (v1>=0) and (v2>=0) and (v3>=0) and (v4>=0) then
      begin

      result          :=true;
      u               :=(v1*vm3) + (v2*vm2) + (v3*vm) + v4;

      inc(spos0,4);

      end

   else dansi1;

   end

else begin

   inc(spos0,1);

   end;

end;//case

end;

function u8__wc(const u8:pobject;const u:longint32):boolean;//write unicode char
const
   vm                 =64;
   vm2                =vm*vm;
   vm3                =vm*vm*vm;

var
   v                  :longint32;
   vd                 :longint32;

begin

//defaults
result                :=false;
v                     :=u;

//get
case u of

0..127:begin//1 byte

   if not str__addbyt1( u8 ,v ) then exit;

   end;

128..2047:begin//2 bytes

   vd                 :=v div vm;
   v                  :=v - (vd*vm);
   if not str__addbyt1( u8 ,192 + vd ) then exit;

   if not str__addbyt1( u8 ,128 + v  ) then exit;

   end;

2048..65535:begin//3 bytes

   vd                 :=v div vm2;
   v                  :=v - (vd*vm2);
   if not str__addbyt1( u8 ,224 + vd ) then exit;

   vd                 :=v div vm;
   v                  :=v - (vd*vm);
   if not str__addbyt1( u8 ,128 + vd ) then exit;

   if not str__addbyt1( u8 ,128 + v ) then exit;

   end;

65536..1114111:begin//4 bytes

   vd                 :=v div vm3;
   v                  :=v - (vd*vm3);
   if not str__addbyt1( u8 ,240 + vd ) then exit;

   vd                 :=v div vm2;
   v                  :=v - (vd*vm2);
   if not str__addbyt1( u8 ,128 + vd ) then exit;

   vd                 :=v div vm;
   v                  :=v - (vd*vm);
   if not str__addbyt1( u8 ,128 + vd ) then exit;

   if not str__addbyt1( u8 ,128 + v ) then exit;

   end;

end;//case

//successful
result                :=true;

end;

function u8__wcStr(var u8:string;const u:longint32):boolean;//write unicode char - 12nov2026
const
   vm                 =64;
   vm2                =vm*vm;
   vm3                =vm*vm*vm;

var
   v                  :longint32;
   vd                 :longint32;

   procedure a(const v:byte);
   begin

   u8                 :=u8 + char(v);

   end;

begin

//defaults
result                :=false;
v                     :=u;

//get
case u of

0..127:begin//1 byte

   a( v );

   end;

128..2047:begin//2 bytes

   vd                 :=v div vm;
   v                  :=v - (vd*vm);
   a( 192 + vd );

   a( 128 + v  );

   end;

2048..65535:begin//3 bytes

   vd                 :=v div vm2;
   v                  :=v - (vd*vm2);
   a( 224 + vd );

   vd                 :=v div vm;
   v                  :=v - (vd*vm);
   a( 128 + vd );

   a( 128 + v );

   end;

65536..1114111:begin//4 bytes

   vd                 :=v div vm3;
   v                  :=v - (vd*vm3);
   a( 240 + vd );

   vd                 :=v div vm2;
   v                  :=v - (vd*vm2);
   a( 128 + vd );

   vd                 :=v div vm;
   v                  :=v - (vd*vm);
   a( 128 + vd );

   a( 128 + v );

   end;

end;//case

//successful
result                :=true;

end;

function utf8__encodetohtml(s,d:pobject;const dappend,dasfilename,dnoslashes:boolean):boolean;
label
   redo, skipend;

var
   v                  :longint32;
   spos               :longint32;
   slen               :longint32;

   procedure xadd(const x:string);
   begin

   str__sadd(d,x);

   end;

   procedure xaddcode(const x:longint32);
   begin

   str__sadd(d,'&#'+intstr32(x)+';');

   end;

begin

//defaults
result                :=false;

//check
if (not str__ok(s)) or (not str__ok(d)) then exit;

//init
if not dappend then str__clear(d);

//get
spos                  :=0;
slen                  :=str__len32(s);

if (slen<=0) then goto skipend;

redo:

u8__rc( s ,spos ,v );//25oct2026

if (v=ssmorethan) or (v=sslessthan) or (v=ssampersand) or (v=ssdoublequote) then xaddcode(v)//absolute minimum to make it html safe
else if dasfilename and ((v=sssemicolon) or (v=ssasterisk) or (v=ssquestion) or (v=ssdoublequote) or (v=sslessthan) or (v=ssmorethan) or (v=sspipe) or (v=ssdollar)) then xaddcode(v)
else if dnoslashes and ((v=ssslash) or (v=ssbackslash)) then xaddcode(v)
else if (v>=32) and (v<=127) then xadd(char(v))//visible ascii
else xaddcode(v);

//loop
if (spos<slen) then goto redo;

//successful
result                :=true;

skipend:

end;

function utf8__encodetohtmlstr(const x:string;const xasfilename,xnoslashes:boolean):string;
var
   s                  :tobject;
   d                  :tobject;

begin

//defaults
result                :='';
s                     :=nil;
d                     :=nil;

try

//init
s                     :=str__new9;
str__settext(@s,x);
d                     :=str__new9;

//get
utf8__encodetohtml( @s ,@d ,false ,xasfilename ,xnoslashes );

//set
result                :=str__text(@d);

except;end;

//free
str__free(@s);
str__free(@d);

end;

function u8__to8(const u8,d8:pobject):boolean;//06nov2026, 16feb2026 - utf8 -> windows-1252 (8-bit ascii)
var
   dcharTranslateCount:longint32;

begin

result                :=u8__to82( u8 ,d8 ,dcharTranslateCount );

end;

function u8__to82(const u8,d8:pobject;var dcharTranslateCount:longint32):boolean;//10nov2026, 06nov2026, 16feb2026 - utf8 -> windows-1252 (8-bit ascii)
label
   redo, skipend;

var
   v                  :longint32;
   dv                 :longint32;
   slen               :longint32;
   spos               :longint32;
   f8                 :tstr8;//pointer only
   f9                 :tstr9;//pointer only
   dcharTranslated    :boolean;

begin

//defaults
result                :=false;
dcharTranslateCount   :=0;

try

//check
if not str__lock2(u8,d8) then goto skipend;
if (u8=d8)               then goto skipend;

//init
str__clear(d8);
str__as89( d8, f8 ,f9 );
slen                  :=str__len32(u8);

//BOM
u8__skipBOM( u8 ,spos );

//check
if (slen<=0) then
   begin

   result             :=true;
   goto skipend;

   end;

//get
redo:

if (spos<slen) then
   begin

   //add char
   if u8__rc( u8 ,spos ,v ) and u__to82( v ,dv ,dcharTranslated ) then
      begin

      //count number of bad chars
      if dcharTranslated and (dcharTranslateCount<max32) then inc( dcharTranslateCount );

      //add char
      if      (f8<>nil) then f8.addbyt1( dv )//fast
      else if (f9<>nil) then f9.addbyt1( dv )//fast
      else              str__addbyt1( d8 ,dv );//slow

      end;

   //loop
   goto redo;

   end;

//successful
result                :=true;

skipend:
except;end;

//free
str__uaf2(u8,d8);

end;

function u8__to8str(const u8:string;var d8:string):boolean;
var
   int1               :longint32;

begin

result                :=u8__to82str( u8 ,d8 ,int1 );

end;

function u8__to82str(const u8:string;var d8:string;var dcharTranslateCount:longint32):boolean;
var
   uu8                :tstr8;
   dd8                :tstr8;

begin

//defaults
result                :=false;
d8                    :='';
uu8                   :=nil;
dd8                   :=nil;
dcharTranslateCount   :=0;

try

//init
uu8                   :=faststr__new8;
dd8                   :=faststr__new8;
uu8.text              :=u8;

if u8__to82( @uu8 ,@dd8 ,dcharTranslateCount ) then
   begin

   faststr__free( @uu8 );//reduce ram

   d8                 :=dd8.text;

   result             :=true;

   end;

except;end;

//free
if (uu8<>nil) then    faststr__free(@uu8);
if (dd8<>nil) then    faststr__free(@dd8);

end;

function u8__to83str(var u8:string):boolean;
var
   int1               :longint32;

begin

result                :=u8__to82str( u8 ,u8 ,int1 );

end;

function u8__to84str(var u8:string;var dcharTranslateCount:longint32):boolean;
begin

result                :=u8__to82str( u8 ,u8 ,dcharTranslateCount );

end;


function u8__to8strb(const u8:string):string;
var
   int1               :longint32;
   
begin

u8__to82str( u8 ,result ,int1 );

end;

function  u8__from8(const s8,u8:pobject):boolean;//06nov2026 - windows-1252 (8-bit ascii) -> utf8
begin

result                :=u8__from82( s8 ,u8 ,u8_addBOM_def );

end;

function  u8__from82(const s8,u8:pobject;const xincludeBOM:boolean):boolean;//12nov2026 - windows-1252 (8-bit ascii) -> utf8
label//s8 (windows-1252/8-bit) -> utf-8
   redo, skipend;

var
   p                  :longint32;
   slen               :longint32;
   v                  :longint32;
   u                  :longint32;
   f8                 :tstr8;//pointer only
   f9                 :tstr9;//pointer only

begin

//defaults
result                :=false;

try

//check
if not str__lock2(s8,u8) then goto skipend;
if (s8=u8)               then goto skipend;

//init
str__clear(u8);
str__as89( s8, f8 ,f9 );

slen                  :=str__len32(s8);

//check
if (slen<=0) then
   begin

   result             :=true;
   goto skipend;

   end;

//add BOM
if xincludeBOM then u8__addBOM( u8 );

//get
for p:=0 to pred(slen) do
begin

//.get char
if      (f8<>nil) then v:=f8.pbytes[p]//fast
else if (f9<>nil) then v:=f9. bytes[p]//semi-fast
else                   v:=str__bytes0( s8 ,p );//slow

//.write char
if u__from8( v ,u ) and (not u8__wc( u8 ,u )) then goto skipend;

end;//p

//successful
result                :=true;

skipend:
except;end;

//free
str__uaf2(s8,u8);

end;

function u8__from8str(const s8:string;var u8:string):boolean;
begin

result                :=u8__from82str( s8 ,u8 ,u8_addBOM_def );

end;

function u8__from82str(const s8:string;var u8:string;const xincludeBOM:boolean):boolean;//12nov2026
var//flow: 8-bit ascii -> utf-8
   //dual mode proc -> short and long string handlers
   p                  :longint32;
   slen               :longint32;
   ss8                :tstr8;
   uu8                :tstr8;

begin

//defaults
result                :=false;
u8                    :='';
ss8                   :=nil;
uu8                   :=nil;
slen                  :=low__len32(s8);

//check
if (slen<=0) then exit;


//short string -----------------------------------------------------------------

if ( slen <= short_string_len ) then
   begin

   //BOM
   if xincludeBOM then u8__addBOMstr( u8 );

   //get
   for p:=0 to pred(slen) do
   begin

   u8__wcStr( u8 ,u__from8b(byte(s8[p+stroffset])) );

   end;//p

   //successful
   result             :=true;

   //stop
   exit;

   end;


//long string ------------------------------------------------------------------

try

//init
ss8                   :=faststr__new8;
uu8                   :=faststr__new8;
ss8.text              :=s8;

if u8__from82( @ss8 ,@uu8 ,xincludeBOM ) then
   begin

   faststr__free( @ss8 );//reduce ram

   u8                 :=uu8.text;

   result             :=true;

   end;

except;end;

//free
if (ss8<>nil) then    faststr__free(@ss8);
if (uu8<>nil) then    faststr__free(@uu8);


end;

function u8__from83str(var u8:string):boolean;
begin

result                :=u8__from82str( u8 ,u8 ,u8_addBOM_def );

end;

function u8__from84str(var u8:string;const xincludeBOM:boolean):boolean;
begin

result                :=u8__from82str( u8 ,u8 ,xincludeBOM );

end;

function u8__from8strb(const s8:string):string;
begin

u8__from82str( s8 ,result ,u8_addBOM_def );

end;

function u8__from82strb(const s8:string;const xincludeBOM:boolean):string;
begin

u8__from82str( s8 ,result ,xincludeBOM );

end;

function u8__to7(const u8,d7:pobject):boolean;//06nov2026 - utf8 -> 7-bit ascii
var
   dcharTranslateCount:longint32;

begin

result                :=u8__to72( u8 ,d7 ,dcharTranslateCount );

end;

function u8__to72(const u8,d7:pobject;var dcharTranslateCount:longint32):boolean;//10nov2026, 06nov2026 - utf8 -> 7-bit ascii
label
   redo, skipend;

var
   v                  :longint32;
   dv                 :longint32;
   slen               :longint32;
   spos               :longint32;
   f8                 :tstr8;//pointer only
   f9                 :tstr9;//pointer only
   dcharTranslated    :boolean;

begin

//defaults
result                :=false;
dcharTranslateCount   :=0;

try

//check
if not str__lock2(u8,d7) then goto skipend;
if (u8=d7)               then goto skipend;

//init
str__clear(d7);
str__as89( d7, f8 ,f9 );
slen                  :=str__len32(u8);

//.bom
u8__skipBOM( u8 ,spos );

//check
if (slen<=0) then
   begin

   result             :=true;
   goto skipend;

   end;

//get
redo:

if (spos<slen) then
   begin

   //add char
   if u8__rc( u8 ,spos ,v ) and u__to72( v ,dv ,dcharTranslated ) then
      begin

      //translate count
      if dcharTranslated and (dcharTranslateCount<max32) then inc( dcharTranslateCount );

      //add
      if      (f8<>nil) then f8.addbyt1( dv )//fast
      else if (f9<>nil) then f9.addbyt1( dv )//fast
      else              str__addbyt1( d7 ,dv );//slow

      end;
      
   //loop
   goto redo;

   end;

//successful
result                :=true;

skipend:
except;end;

//free
str__uaf2(u8,d7);

end;

function u8__to7str(const u8:string;var d7:string):boolean;
var
   int1               :longint32;

begin

result                :=u8__to72str( u8 ,d7 ,int1 );

end;

function u8__to72str(const u8:string;var d7:string;var dcharTranslateCount:longint32):boolean;
var
   uu8                :tstr8;
   dd7                :tstr8;

begin

//defaults
result                :=false;
d7                    :='';
uu8                   :=nil;
dd7                   :=nil;
dcharTranslateCount   :=0;

try

//init
uu8                   :=faststr__new8;
dd7                   :=faststr__new8;
uu8.text              :=u8;

if u8__to72( @uu8 ,@dd7 ,dcharTranslateCount ) then
   begin

   faststr__free( @uu8 );//reduce ram

   d7                 :=dd7.text;

   result             :=true;

   end;

except;end;

//free
if (uu8<>nil) then    faststr__free(@uu8);
if (dd7<>nil) then    faststr__free(@dd7);

end;

function u8__to7strb(const u8:string):string;
var
   int1               :longint32;

begin

u8__to72str( u8 ,result ,int1 );

end;

function u8__to73str(var u8:string):boolean;
var
   int1               :longint32;

begin

result                :=u8__to72str( u8 ,u8 ,int1 );

end;

function u8__to74str(var u8:string;var dcharTranslateCount:longint32):boolean;
begin

result                :=u8__to72str( u8 ,u8 ,dcharTranslateCount );

end;

function u8__from7(const s7,u8:pobject):boolean;//06nov2026
begin

result                :=u8__from72( s7 ,u8 ,u8_addBOM_def );

end;

function u8__from72(const s7,u8:pobject;const xincludeBOM:boolean):boolean;//12nov2026
label//s7 ascii 7-bit -> utf-8
   redo, skipend;

var
   p                  :longint32;
   slen               :longint32;
   v                  :longint32;
   u                  :longint32;
   f8                 :tstr8;//pointer only
   f9                 :tstr9;//pointer only

begin

//defaults
result                :=false;

try

//check
if not str__lock2(s7,u8) then goto skipend;
if (s7=u8)               then goto skipend;

//init
str__clear(u8);
str__as89( s7, f8 ,f9 );
slen                  :=str__len32(s7);

//check
if (slen<=0) then
   begin

   result             :=true;
   goto skipend;

   end;

//add BOM
if xincludeBOM then u8__addBOM( u8 );

//get
for p:=0 to pred(slen) do
begin

//.get char
if      (f8<>nil) then v:=f8.pbytes[p]//fast
else if (f9<>nil) then v:=f9. bytes[p]//semi-fast
else                   v:=str__bytes0( s7 ,p );//slow

//.write char
if u__from7( v ,u ) and (not u8__wc( u8 ,u )) then goto skipend;

end;//p

//successful
result                :=true;

skipend:
except;end;

//free
str__uaf2(s7,u8);

end;

function u8__from7str(const s7:string;var u8:string):boolean;
begin

result                :=u8__from72str( s7 ,u8 ,u8_addBOM_def );

end;

function u8__from72str(const s7:string;var u8:string;const xincludeBOM:boolean):boolean;//12nov2026
var//dual mode proc -> short and long string handlers
   p                  :longint32;
   slen               :longint32;
   ss7                :tstr8;
   uu8                :tstr8;

begin

//defaults
result                :=false;
u8                    :='';
ss7                   :=nil;
uu8                   :=nil;
slen                  :=low__len32(s7);

//check
if (slen<=0) then exit;


//short string -----------------------------------------------------------------

if ( slen <= short_string_len ) then
   begin

   //BOM
   if xincludeBOM then u8__addBOMstr( u8 );

   //get
   for p:=0 to pred(slen) do
   begin

   u8__wcStr( u8 ,u__from7b(byte(s7[p+stroffset])) );

   end;//p

   //successful
   result             :=true;

   //stop
   exit;

   end;


//long string ------------------------------------------------------------------

try

//init
ss7                   :=faststr__new8;
uu8                   :=faststr__new8;
ss7.text              :=s7;

if u8__from72( @ss7 ,@uu8 ,xincludeBOM ) then
   begin

   faststr__free( @ss7 );//reduce ram

   u8                 :=uu8.text;

   result             :=true;

   end;

except;end;

//free
if (ss7<>nil) then    faststr__free(@ss7);
if (uu8<>nil) then    faststr__free(@uu8);


end;

function u8__from73str(var u8:string):boolean;
begin

result                :=u8__from72str( u8 ,u8 ,u8_addBOM_def );

end;

function u8__from74str(var u8:string;const xincludeBOM:boolean):boolean;
begin

result                :=u8__from72str( u8 ,u8 ,xincludeBOM );

end;

function u8__from7strb(const u8:string):string;
begin

u8__from72str( u8 ,result ,u8_addBOM_def );

end;

function u8__from72strb(const u8:string;const xincludeBOM:boolean):string;
begin

u8__from72str( u8 ,result ,xincludeBOM );

end;


//mail procs -------------------------------------------------------------------
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

function mail__fromqp(_s:string):string;//quoted-printable, 22mar2024: updated "_" as a space
label
   redo;
var
   s,sline,d:tstr8;
   int1,p,spos:longint;

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
   if (sline.len<1) or (sline.pbytes[sline.len32-1]<>ssEqual) then rcodeok:=true;//line has a return code
   if (sline.len>=1) and (sline.pbytes[sline.len32-1]=ssEqual) then sline.setlen(sline.len-1);//strip trailing "="
   //get
   p:=0;
   redo:
   inc(p);
   if (p<=sline.len) then
      begin
      //get
      if (sline.pbytes[p-1]=ssEqual) then
         begin
         d.sadd(char(hex2__int1(sline.str1[p+1,2])));
         inc(p,2);
         end
      else if (sline.pbytes[p-1]=ssUnderscore) then d.aadd([ssSpace])//22mar2024
      else d.sadd(sline.str1[p,1]);
      //loop
      goto redo;
      end;
   except;end;
   try
   //.append return code
   if rcodeok then d.sadd(#10);
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
   if (sline.len>=1) then for p:=sline.len32 downto 1 do if (sline.pbytes[p-1]<>9) and (sline.pbytes[p-1]<>32) then
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

function mail__encodefield(x:string;xencode:boolean):string;//like subject etc
label
   encode1,decode2,redo1,redo2,skipend;
var
   xmustencode:boolean;
   p:longint;
   str2,str1,z:string;

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
   if (x<>'') then for p:=1 to low__len32(x) do if (x[p-1+stroffset]='=') then
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
   if (x<>'') and (xtype<>'') then for p:=1 to low__len32(x) do if (x[p-1+stroffset]='?') and strmatch(strcopy1(x,p,2),'?=') then
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

   function hascode(xn:string;var x:string):boolean;
   begin
   result:=false;

   try
   result:=
    strmatch(strcopy1(x,1,low__len32(xn)),xn) or
    strmatch(strcopy1(x,1,low__len32(xn)+1),#32+xn) or
    strmatch(strcopy1(x,1,low__len32(xn)+1),#9+xn);//Old Netscape Mail 3.0 compatible - they used leading tabs instead of spaces back then
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
if (not xmustencode) and (low__len32(result)>60) then xmustencode:=true;//allows for 16c field name, e.g. "Subject: " = 9c
if (not xmustencode) and (result<>'') then for p:=1 to low__len32(result) do
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

function mail__extractaddress(x:string):string;//03apr2025
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
   if (result<>'') then for p:=1 to low__len32(result) do if (result[p-1+stroffset]='@') then
      begin
      bol1:=true;
      break;
      end;//p
   if not bol1 then result:='';

   //.remove leading labels
   if (result<>'') then for p:=1 to low__len32(result) do if (result[p-1+stroffset]='@') then
      begin
      for p2:=p downto 1 do if (result[p2-1+stroffset]=#32) or (result[p2-1+stroffset]='<') or (result[p2-1+stroffset]='>') or (result[p2-1+stroffset]=';') or (result[p2-1+stroffset]=',') then
         begin
         result:=strcopy1(result,p2+1,low__len32(result));
         break;
         end;//p2
      break;
      end;

   //.remove trailing labels
   if (result<>'') then for p:=1 to low__len32(result) do if (result[p-1+stroffset]='@') then
      begin
      for p2:=p to low__len32(result) do if (result[p2-1+stroffset]=#32) or (result[p2-1+stroffset]='<') or (result[p2-1+stroffset]='>') or (result[p2-1+stroffset]=';') or (result[p2-1+stroffset]=',')  then
         begin
         result:=strcopy1(result,1,p2-1);
         break;
         end;//p2
      break;
      end;

   //.filter content -- 03apr2025
   low__remchar(result,'"');
   end;
except;end;

//free
freeobj(@a);

end;

function mail__filteraddresses(x:string;xaddressesonly,xwraponlines:boolean):string;//06apr2025
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
      true:begin
         if ((low__len32(xline)+low__len32(v))<=74) then xline:=xline+v+', '//76c line length limit
         else
            begin
            if (xline<>'') then d.sadd(xline+#10);//let NO accidental blank lines through - 04nov2018
            xline:=#32+v+', ';//enforce leading space for next line
            end;
         end;//begin
      else d.sadd(insstr(', ',d.len>=1)+v);//06apr2025: fixed
      end;//case
      end;//if
   end;//p
//.finalise
if (xline<>'') then d.sadd(xline+#10);//let NO accidental blank lines through - 04nov2018
//set
result:=striptrailingrcodesb(d.text);//no trailing RCODE
if (low__len32(result)>=2) and (strcopy1(result,low__len32(result)-1,2)=', ') then strdel1(result,low__len32(result)-1,2);//remove trailing ", "
except;end;
try
freeobj(@a);
str__free(@d);
except;end;
end;

function mail__diskname(xdate:tdatetime;xsubject:string;xtrycount:longint):string;//21nov2024: fixed ":" oversight

   function xsafename80(x:string):string;//21nov2024: fixed ":' oversight
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
   swapchars(result,':','-');//21nov2024
   //check length, trim to last whoe "&#...;" code
   len:=low__len32(result);
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
result:=low__dateascode(xdate)+'_'+xsafename80(xsubject)+insstr('_'+intstr32(xtrycount),xtrycount>=1)+'.eml';
end;

function mail__makemsg(x:pobject;xsenderip,xfrom,xto,xsubject,xmsg:string;xdate:tdatetime;var e:string):boolean;//06apr2025, 09feb2024

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
   xlen:=low__len32(x);
   xpos:=1;
   //get
   redo:
   if low__nextline1(x,xline,xlen,xpos) then
      begin
      if (xline='.') then b.sadd(#32+xline+#10) else b.sadd(xline+#10);
      goto redo;
      end;
   //set
   result:=b.text;
   except;end;

   //free
   str__free(@b);
   
   end;

   procedure ladd(xline:string);
   begin
   str__sadd(x,xline+rcode);//must be #13#10 as per RFC1035
   end;
begin
//defaults
result:=false;
e:=gecTaskfailed;

//check
if not str__lock(x) then exit;

try
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
//free
str__uaf(x);
end;

function mail__findfield(x:pobject;const xfieldname:string;xoutput:pobject):boolean;
begin
result:=mail__findfield2(x,xfieldname,true,xoutput);
end;

function mail__findfield2(x:pobject;const xfieldname:string;xdecodelines:boolean;xoutput:pobject):boolean;
label
   skipend;
var
   xline:tstr8;
   xpos,nlen:longint;
   xwithin:boolean;
   v,lc,uc:byte;
begin
//defaults
result     :=false;
xline      :=nil;
nlen       :=low__len32(xfieldname);
xwithin    :=false;

try
//check
if not str__lock2(x,xoutput) then goto skipend;
if (nlen<=0)                 then goto skipend;

//init
xline:=str__new8;
xpos :=0;
lc   :=byte(strlow(xfieldname[1])[1]);
uc   :=byte(strup (xfieldname[1])[1]);

//find
while str__nextline0(x,@xline,xpos) do
begin
v:=xline.bytes[0];

//stop
if xwithin and (v<>ssSpace) then break;

//start
if (not xwithin) and ((v=lc) or (v=uc)) and strmatch(xfieldname,xline.str1[1,nlen]) then xwithin:=true;

//add line to output
if xwithin then
   begin

   if xdecodelines then//unwrap lines into one long line
      begin
      if (v=ssSpace) then str__add3(xoutput,@xline,1,xline.len-1)//exclude leading space
      else                str__add (xoutput,@xline);
      end
   else
      begin//retain raw format
      str__add(xoutput,@xline);
      str__sadd(xoutput,rcode);//must be CRLF for mail
      end;

   result:=true;//mark as found
   end;

end;//loop

skipend:
except;end;
//clear on error
if not result then str__clear(xoutput);
//free
str__free(@xline);
str__uaf(x);
str__uaf(xoutput);
end;

function mail__makemsg2(x:pobject;xserverdomain,xuseragent,xsenderip,xfrom,xto,xcc,xbcc,xsubject,xmsg:string;xdate:tdatetime;xattachments:tfastvars;var e:string):boolean;//07apr2025
var//Note: xattachments=optional, but when supplied this proc looks for files with name of "file.name1..N" and file data "file.data1..N":
   ///RFC5322 -> max line limit is 998c + CRLF = total 1,000c hard line length limit -> not to be exceeded
   xboundary,xname:string;
   xdata:tstr8;
   xcount,xdatalen,p:longint;
   xneedboundary:boolean;

   function xpullandshrink(var x:string):string;
   begin
   result:=strcopy1(x,1,200);
   strdel1(x,1,low__len32(result));
   end;

   function xmakemsgid36:string;
   var
      p:longint;

      function rc:char;
      var
         v:longint;
      begin
      v:=frcrange32(random(36),0,35);
      case v of
      0..25:result:=char(v+llA);
      else  result:=char(v+nn0-26);
      end;//case

      end;
   begin
   low__setlen(result,36);
   for p:=1 to low__len32(result) do result[p-1+stroffset]:=rc;
   end;

   function xmakeboundary36:string;
   begin
   result:='------------'+strup(strcopy1(xmakemsgid36,1,24))+result;
   end;

   procedure ladd(xline:string);
   const
      xlimit=990;

      procedure xaddpart(const xpartline:string);
      begin
      case (xpartline='.') of
      true:str__sadd(x,#32+xpartline+rcode);//avoid lines with only a dot ".'
      else str__sadd(x,    xpartline+rcode);
      end;//case
      end;
   begin
   //expected blank line -> only point a blank line is allowed
   if (xline='') then
      begin
      str__sadd(x,rcode);
      exit;
      end;

   //no blank lines from this point on -> break long line into sub-lines and avoid RFC limit of 998c + CRLF
   while (low__len32(xline)>xlimit) do//greater than avoids creating any "unexpected blank line/s"
   begin
   xaddpart(strcopy1(xline,1,xlimit));
   strdel1(xline,1,xlimit);//remainder should never be "nil"
   end;

   //strictly enforce the no "unexpected blank line" policy
   if (xline<>'') then xaddpart(xline);
   end;

   function laddmsg(const x:string):string;//longish lines permitted - 03apr2025
   var
      xline:string;
      xlen,xpos:longint;
   begin
   try
   //check
   if (x='') then exit;

   //init
   xlen :=low__len32(x);
   xpos :=1;

   //get
   while low__nextline1(x,xline,xlen,xpos) do ladd(xline);
   except;end;
   end;

   function xsafefilename64(const x:string):string;
   begin
   //defaults
   result:=x;

   //filter
   low__remchar(result,'"');

   //get
   result:=strcopy1(result,1, frcmax32(low__len32(result),64) );
   end;
begin
//defaults
result   :=false;
e        :=gecTaskfailed;
xdata    :=nil;
xcount   :=0;

//check
if not str__lock(x) then exit;


try
//init
str__clear(x);
xdata     :=str__new8;


//filter
//.subject
swapchars(xsubject,#10,#32);
low__remchar(xsubject,#13);
u8__to73str(xsubject);
u8__to73str(xuseragent);

//.xserverdomain
low__remchar(xserverdomain,#32);
u8__to73str(xserverdomain);

//.message
u8__to73str(xmsg);


//find attachment count
if (xattachments<>nil) and (xattachments.count>=2) then for p:=1 to (max32-1) do if xattachments.found('file.name'+intstr32(p)) then xcount:=p else break;


//generate boundary marker
xneedboundary:=(xcount>=1);
if xneedboundary then xboundary:=xmakeboundary36;//create a unique boundary that does not appear within the message and is 76-2-2-12=60 chars long at most


//message headers --------------------------------------------------------------
//.to - required
ladd('To: '+mail__filteraddresses(xto,true,true));//wrap over multiple lines

//.cc
if (xcc<>'')  then ladd('Cc: '+mail__filteraddresses(xcc,true,true));//wrap over multiple lines

//.bcc
if (xbcc<>'') then ladd('Bcc: '+mail__filteraddresses(xbcc,true,true));//wrap over multiple lines

//.from -> single address only (multiple not permitted
ladd('From: '+mail__filteraddresses(xfrom,true,true));//wrap over multiple lines

//.subject -> wrap over multiple lines
ladd('Subject: '+xpullandshrink(xsubject));
while (xsubject<>'') do ladd(#32+xpullandshrink(xsubject));

//.message-id
ladd('Message-ID: <'+xmakemsgid36+'@'+strdefb(xserverdomain,'localhost')+'>');//36c + @ + domain - 07apr2025

//.date
ladd('Date: '+mail__date(xdate));

//.user-agent - optional
if (xuseragent<>'') then ladd('User-Agent: '+xuseragent);

//.mime version
ladd('Mime-Version: 1.0');

//.multi-part indicating attachments etc - optional
if xneedboundary then
   begin
   ladd('Content-Type: multipart/mixed;');
   ladd(' boundary="'+xboundary+'"');
   ladd('');
   ladd('This is a multi-part message in MIME format.');
   ladd('--'+xboundary);
   end;


//message
ladd('Content-Type: text/plain; charset=UTF-8');
ladd('Content-Transfer-Encoding: 7bit');
ladd('');
laddmsg(xmsg);
ladd('');


//attachments - optional
if (xcount>=1) then for p:=1 to xcount do if xattachments.sfound('file.name'+intstr32(p),xname) then
   begin
   //start
   ladd('--'+xboundary);

   //file name
   xname:=xsafefilename64(xname);
   ladd('Content-Type: '+net__mimefind(io__lastext(xname))+';');
   ladd(' name="'+xname+'"');//68c name max
   ladd('Content-Transfer-Encoding: base64');
   ladd('Content-Disposition: attachment;');
   ladd(' filename="'+xname+'"');//64c name max
   ladd('');
   //.file data - base64 format
   str__clear(@xdata);
   xattachments.sfound8('file.data'+intstr32(p),@xdata,false,xdatalen);

   str__tob643(@xdata,@xdata,1,72,true,true,true);
   str__add(x,@xdata);
   str__clear(@xdata);
   end;//p


//last boundary trails with "--" -> not required for a simple message
if xneedboundary then ladd('--'+xboundary + '--');


//successful
result:=true;
except;end;
//free
str__uaf(x);
end;

function mail__writemsg(x:pobject;xsubject,xdestfolder:string):boolean;
label
   skipend,redo;
var
   df,e:string;
   xtrycount:longint;
begin
//defaults
result:=false;

//check
if not str__lock(x) then exit;

try
//get -> write as .tmp first (so remote client won't download until FULL file is written) then rename full file as a non-tmp
xtrycount:=0;
redo:

case (xdestfolder<>'') of
true:begin
   xdestfolder:=io__asfolder(xdestfolder);
   io__makefolder(xdestfolder);
   df:=xdestfolder+mail__diskname(date__now,xsubject,xtrycount);
   end;
else df:=app__subfolder('inbox')+mail__diskname(date__now,xsubject,xtrycount);
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


//rtf procs --------------------------------------------------------------------

function rtf__stopChar(const v:longint32):boolean;
begin

result                :=(v=10) or (v=13) or (v=ssSpace) or (v=ssBackSlash) or (v=ssLCurlyBracket) or (v=ssRCurlyBracket);

end;

function rtf__cleanLine(const xline:string):string;
label
   redo;

var

   bol1            :boolean;
begin

//strip leading and trailing whitespace
result             :=stripwhitespace_lt( xline );
bol1               :=false;

redo:

//strip leading '"'
if (strcopy1(result,1,1)='"') then
   begin

   bol1            :=true;
   strdel1(result,1,1);

   goto redo;

   end;

//strip trailing '"'
if (strcopy1(result,low__len32(result),1)='"') then
   begin

   bol1            :=true;
   strdel1(result,low__len32(result),1);

   goto redo;

   end;

//finalise
if bol1 then result:=stripwhitespace_lt( result );

end;

function rtf__readNextSlashValue(const x:tstr8;var xpos0:longint32;const xscanTo0:longint32;var xval:string):boolean;//02nov2026
label
   redo;
var
   xlen                         :longint32;

   function xendChar(const v:longint32):boolean;
   begin

   result                       :=(v=ssSpace) or (v=ssBackSlash) or (v=ssLCurlyBracket) or (v=ssRCurlyBracket);

   end;

begin

//defaults
result                          :=false;
xval                            :='';

//check
if (x=nil) then exit;

//init
xlen                            :=x.len32;

if (xpos0<0) then xpos0         :=0;

//get
redo:

//.stop
if (xpos0>xscanTo0) or (xpos0>=xlen) then exit

//.inc + stop
else if xendChar(x.pbytes[xpos0]) then
   begin

   result                       :=true;

   inc(xpos0);

   exit

   end

//.inc + add char
else begin

   //add char
   result                       :=true;
   xval                         :=xval + char(x.pbytes[xpos0]);

   //next char
   inc(xpos0);

   goto redo;

   end;

end;

procedure rtf__readPict(const x:ttextio;var xrtfType,xpos:longint32;const spos0:longint32);
label
   nredo;

var
   bd                           :longint32;
   xfrom                        :longint32;
   xto                          :longint32;
   i                            :longint32;
   l32                          :longint32;
   xstart                       :boolean;
   npos0                        :longint32;
   nval                         :string;
   dw                           :longint32;
   dh                           :longint32;
   dformat                      :string;
   v                            :string;
   v32                          :longint32;

   function v0(const xindex:longint32):byte;
   begin

   if (xindex>=0) and (xindex<l32) then result:=x.iostream.pbytes[xindex]
   else                                 result:=0;

   end;

   function m(const n:string):boolean;
   begin

   result                       :=strmatch(nval,n);

   end;

   function mv(const n:string):boolean;
   begin

   result:=strm(nval,n,v,v32);

   end;

begin

//check
if (x=nil) then exit;

//init
//xrtfType                        :=rtf_nil;
xfrom                           :=spos0;
xto                             :=spos0;
bd                              :=0;//bracket depth
xstart                          :=true;
l32                             :=str__len32(@x.iostream);
dw                              :=1;
dh                              :=1;
dformat                         :='';
v                               :='';
v32                             :=0;

{

xxxxxxxxxxxxxxxxxxx "wmf" is:
\pard\sa200\sl240\slmult1{\pict{\*\picprop}////// \wmetafile8\picw6959\pich6853\picwgoal3945\pichgoal3885

 {
xxxxxxxxxxxxxxxxxxxxxx "emf" is ????????? \eblip\............

both are missing their headers

wmf=22 placeable header + 18 internal header????????????


 and "emf"


dwidth  = picwgoal3945 * ( 96 / 1440 );

{}//?????????????????????????????????????????????????
{}//?????????????????????????????????????????????????
{}//?????????????????????????????????????????????????
{}//?????????????????????????????????????????????????
{}//?????????????????????????????????????????????????
{}//?????????????????????????????????????????????????
{}//?????????????????????????????????????????????????


//find start/finish
for i:=spos0 to l32 do
begin

case v0(i) of

ssLCurlyBracket:inc(bd);

ssRCurlyBracket:begin

   dec(bd);

   if (not xstart) and (bd=-1) then
      begin

      xto                       :=pred(i);
      xpos                      :=i;//allow main loop to detect end-of-pict - 19feb2026

      break;

      end;

   end;

ssSpace:begin

   if (bd=0) and xstart then
      begin

      xfrom                     :=succ(i);
      xto                       :=succ(i);
      xpos                      :=succ(i);
      xstart                    :=false;

      end;

   end;

end;//case

end;//i


//slashValues
npos0                           :=spos0;

nredo:

if rtf__readNextSlashValue( x.iostream ,npos0 ,xfrom ,nval ) then
   begin

   if       m('wmetafile8') then dformat  :=fewmf
   else if mv('picwgoal')   then dw       :=frcmin32( v32 div 15 ,1 )// "96/1440" => "1/15"
   else if mv('pichgoal')   then dh       :=frcmin32( v32 div 15 ,1 );

   goto nredo;

   end;


{//??????????????????????????????????????
showbasic(
'-- img vals--'+rcode+
'f: '+dformat+rcode+
'w: '+k64(dw)+rcode+
'h: '+k64(dh)+rcode+
'');
{}


//image
x.tmp1.clear;
x.tmp2.clear;
x.tmp2.add2( x.iostream ,xfrom ,xto );


low__fromhex( x.tmp2 ,x.tmp1 );

//.insert header for WMF
if (dformat=fewmf) then
   begin

   x.tmp2.clear;

   wmf__writeheader( @x.tmp2 ,dw ,dh );

   x.tmp1.ins( x.tmp2 ,0 );

   end;

//????????????????xrtfType                        :=rtf_pict;

//reduce ram
x.tmp2.clear;

end;

procedure rtf__readField(const v:ttextio;var xrtfType,xpos:longint32);//???????????????????????????????//remove//???????????????
var
   xfrom                        :longint32;
   bd                           :longint32;
   i                            :longint32;
   i2                           :longint32;
   l32                          :longint32;
   xreadStop                    :boolean;

   function v0(const xindex:longint32):byte;
   begin

   if (xindex>=0) and (xindex<l32) then result:=v.iostream.pbytes[xindex]
   else                                 result:=0;

   end;

   procedure xdecodeField;
   label
      redo;

   var
      bd           :longint32;
      vmax         :longint32;
      dlen         :longint32;
      p            :longint32;

      procedure a1(const c:byte);
      begin

      v.tmp1.pbytes[dlen]    :=c;

      inc(dlen,1);

      end;

   begin

   //defaults
   dlen            :=0;
   vmax            :=pred(v.tmp1.len32);
   p               :=0;
   bd              :=0;

   //get
   redo:

   case v.tmp1.pbytes[p] of

   ssLCurlyBracket:;//nil
   ssRCurlyBracket:;//nil

   ssBackSlash:begin// "\{" => "{" etc

      if      (v.tmp1.str[p,2]='\{')   then
         begin

         a1(ssLCurlyBracket);
         inc(p,1);

         end

      else if (v.tmp1.str[p,2]='\}')   then
         begin

         a1(ssRCurlyBracket);
         inc(p,1);

         end

      else if (v.tmp1.str[p,4]='\\\\') then
         begin

         a1(ssBackSlash);
         inc(p,3);

         end;

      end;//begin

   else  a1(v.tmp1.pbytes[p]);

   end;//case

   //loop
   inc(p);

   if (p<=vmax) then goto redo;

   //finalise size
   if (dlen<v.tmp1.len32) then v.tmp1.setlen(dlen);

   end;



begin

//check
if (v=nil) then exit;

//defaults
//?????????????xrtfType                        :=rtf_nil;
bd                              :=0;
xfrom                           :=frcmin32(xpos-2,0);
xreadStop                       :=false;
l32                             :=str__len32(@v.iostream);

//init
v.tmp1.clear;

//find start/finish
for i:=xfrom to l32 do
begin

case v0(i) of

ssRCurlyBracket:begin

   if (v0(pred(i))<>ssBackSlash) then
      begin

      dec(bd);

      end;

   if (bd=0) then
      begin

      xpos                      :=i;//allow main loop to detect the trailing double "}" - 19feb2026

      break;

      end;

   end;

ssLCurlyBracket:begin

   if (v0(pred(i))<>ssBackSlash) then
      begin

      inc(bd);

      end;

//???????????????????????????????????????????????
//???????????????????????????????????????????????
//???????????????????????????????????????????????
//???????????????????????????????????????????????
//???????????????????? there is more than one way to encode this!!!!!!!!!!!!!!!!!!!!!!!!
//????????????????????????????????????????????
//Libre Office: \par \pard\plain \s0\rtlch\af7\afs24\alang1081 \ltrch\lang2057\langfe2052\hich\af0\loch\widctlpar\hyphpar0\ltrpar\cf0\f0\fs24\lang2057\kerning1\dbch\af8\langfe2052\sl240\slmult1\ql\ltrpar{{\field{\*\fldinst HYPERLINK "https://nicdee.com" }{\fldrslt {\hich\af3\loch\loch\cf9\ul\ulc0\fs24\lang1033\f3\loch

//code.bit--> field{\*\fldinst HYPERLINK "https://nicdee.com" }

//code.bit--> field{\*\fldinst{HYPERLINK https://nicdee.com }}

//WordPad     :{\f0\lang1033{\field{\*\fldinst{HYPERLINK https://nicdee.com }}{\fldrslt{https://nicdee.com\ul0\cf0}}}}\f2\fs24\par


//???????????????????????????????????????????????
//???????????????????????????????????????????????
//???????????????????????????????????????????????
//???????????????????????????????????????????????
//???????????????????????????????????????????????

{

the "\*" means teh contents enclodes in the brackets can be discarded if the decoder does not recognise the command, or support!!!!


//         //.type.1:field{\*\fldinst{HYPERLINK https://mysite.com }//} - WordPad
   if (not xreadStop) and strmatch(v.iostream.str1[succ(i),11],'{hyperlink ') then
      begin

      //??????????xrtfType                  :=rtf_url;
      xreadStop                 :=true;

      for i2:=(i+11) to l32 do if (v0(i2)=ssRCurlyBracket) and (v0(i2+1)=ssRCurlyBracket) then
         begin

         v.tmp1.text            :=v.iostream.str1[i+12,i2-i-12];

         xdecodeField;

         break;//i2

         end;

      end

   //.type.2:field{\*\fldinst HYPERLINK "https://mysite.com" }// - LibreOffice
//??????????????????????
//??????????????????????
//??????????????????????
//won't work as we're scanning for curly bracket and not a space...................................
//??????????????????????
//??????????????????????
//??????????????????????

   else if (not xreadStop) and strmatch(v.iostream.str1[succ(i),11],' hyperlink ') then
      begin

      //????????????????xrtfType                  :=rtf_url;
      xreadStop                 :=true;

      for i2:=(i+11) to l32 do if (v0(i2)=32) and (v0(i2+1)=ssRCurlyBracket) then
         begin

         v.tmp1.text            :=v.iostream.str1[i+12,i2-i-12];

         xdecodeField;

         break;//i2

         end;

      end;

   end;//begin

end;//case

end;//i

end;


//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//???????????????????????????????????????????

function rtf__findBracketContent(const x:tstr8;const xfrom0:longint32;var xfrom,xto:longint32;var xerror:boolean):boolean;
var
   p                            :longint32;
   bcount                       :longint32;
   xlen                         :longint32;

begin

//defaults
result                          :=false;
xerror                          :=false;
xlen                            :=x.len32;
bcount                          :=0;

//scan
if (xfrom0>=0) and (xfrom0<xlen) then
   begin

   for p:=xfrom0 to pred(xlen) do
   begin

   case x.pbytes[p] of

   ssLCurlyBracket:begin

      if (bcount=0) then
         begin

         xfrom                  :=succ(p);
         xto                    :=xfrom;
         result                 :=true;

         end;

      inc(bcount);

      end;

   ssRCurlyBracket:begin

      dec(bcount);

      if (bcount=0) then
         begin

         xto                    :=pred(p);
         break;

         end;

      end;

   end;//end

   end;//p

   end;

//error check
xerror                          :=(bcount<>0);

end;

function  rtf__az(const v:longint32):boolean;
begin

case v of

uuA..uuZ    :result:=true;
lla..llz    :result:=true;
else         result:=false;

end;//case

end;



//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????

procedure rtf__write2(const t:ttextcore;const v:ttextio);//basic RTF
var
   a                            :tbasicimage;
   b                            :tstr8;
   xalign                       :longint32;
   fmapCount                    :longint32;
   xlastc                       :longint32;
   xlastid                      :longint32;
   p                            :longint32;
   ff                           :tfastfont;
   fc                           :tfastchar;
   fmap                         :array[0..textcore_listmax] of longint;//map used font to rtf font (f0..n)
   xfirstChar                   :boolean;
   xbold                        :boolean;
   xitalic                      :boolean;
   xunderline                   :boolean;
   xstrikeout                   :boolean;
   xhighlight                   :boolean;
   xformat                      :string;
   e                            :string;

   function tv2(const xindex:longint32):ptextinfo;
   begin

   case (xindex>=0) and (xindex<=textcore_listmax) of
   true:result:=@t.tlist[xindex];
   else result:=@t.tlist[0];
   end;//case

   end;

   function tv:ptextinfo;
   begin
   result:=@t.tlist[fc.wid];
   end;

   function iv:pimageinfo;
   begin
   result:=@t.ilist[fc.wid];
   end;

   function xmuststyle(const xid:longint):boolean;
   begin

   result:=(xid>=0) and (xid<=textcore_listmax) and (v.tmp1.pbytes[xid]=0);
   if result then v.tmp1.pbytes[xid]:=1;//mark as done

   end;

   procedure a1(const x1:byte);
   begin

   v.iostream.addbyt1(x1);

   end;

   procedure a2(const x1,x2:byte);
   begin

   v.iostream.addbyt1(x1);
   v.iostream.addbyt1(x2);

   end;

   procedure sa(const x:string);
   begin

   v.iostream.sadd(x);

   end;

   procedure la(const x:string);
   begin

   v.iostream.sadd( x + rcode );

   end;

   function xsafeval(const x:string):string;
   var
      v     :longint32;
      p     :longint32;
      
   begin

   //defaults
   result   :='';
   b.clear;

   try

   //scan
   for p:=1 to low__len32(x) do
   begin

   v:=ord( x[p-1+stroffset] );

   case v of

   ssbackslash      :b.sadd('\\');
   ssLCurlyBracket  :b.sadd('\{');
   ssRCurlyBracket  :b.sadd('\}');
   else              b.addbyt1(v);

   end;//case

   end;//p

   //get
   result   :=b.text;

   except;end;

   //clear
   b.clear;

   end;

   procedure xStyleChange(const xAllow:boolean);
   begin

   //bold
   if low__setbol( xbold ,tv.bold and xAllow ) then
      begin

      case xbold of
      true:sa('\b ');//on
      else sa('\b0 ');//off
      end;//case

      end;

   //italic
   if low__setbol( xitalic ,tv.italic and xAllow) then
      begin

      case xitalic of
      true:sa('\i ');//on
      else sa('\i0 ');//off
      end;//case

      end;

   //underline
   if low__setbol( xunderline ,tv.underline and xAllow) then
      begin

      case xunderline of
      true:sa('\ul ');//on
      else sa('\ulnone ');//off
      end;//case

      end;

   //strikeout
   if low__setbol( xstrikeout ,tv.strikeout and xAllow) then
      begin

      case xstrikeout of
      true:sa('\strike ');//on
      else sa('\strike0 ');//off
      end;//case

      end;

   //highlight
   if low__setbol( xhighlight ,(tv.bgcolor<>clnone) and xAllow) then
      begin

      case xhighlight of
      true:sa('\highlight1 ');//on -> refers to 1st color table entry
      else sa('\highlight0 ');//off
      end;//case

      end;

   end;

   function xalignStr:string;
   begin

   case xalign of

   wcaCenter :result:='\qc';
   wcaRight  :result:='\qr';
   else       result:='';

   end;//case

   end;

   function xfontsize:string;
   begin

   result:=intstr32( tv.size*2 );

   end;

   function xpicWH(const xpx:longint):string;
   begin

   result:=intstr32(round32( (xpx / 96) * 2540));

   end;

   function xpicWHgoal(const xpx:longint):string;
   begin

   result:=intstr32(round32( (xpx / 96) * 1440));

   end;

begin

//defaults
a           :=nil;
b           :=nil;

try

//init
b           :=str__new8;
b.floatsize :=5000;
xbold       :=false;
xitalic     :=false;
xunderline  :=false;
xstrikeout  :=false;
xhighlight  :=false;
xalign      :=t.xfastfindalign(v.wfrom);
xfirstChar  :=true;
fmapCount   :=0;
low__cls(@fmap,0);

v.tmp1.setlen(textcore_listmax+1);
v.tmp1.fill(0,v.tmp1.len32-1,0);

t.xfastcharinit(ff);
t.xfastchar(ff,v.wfrom,1,fc);

xlastc      :=-1;
xlastid     :=-1;


//map used fonts to fmap -------------------------------------------------------
for p:=v.wfrom to v.wto do if t.xfastchar(ff,p,1,fc) and (fc.cs=wc_t) and xmuststyle(fc.wid) then
   begin

   fmap[ fmapCount ]:=fc.wid;
   inc( fmapCount );

   end;

//header + used fonts ----------------------------------------------------------

sa('{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang2057{\fonttbl{\f0\fnil\fcharset0 '+xsafeval( font__realname(tv2( fmap[0] ).name) )+';}');//root font

//for p:=1 to (fmapCount-1) do sa('{\f'+intstr32(p)+'\fnil\fcharset0 '+xsafeval( font__realname(tv2( fmap[p] ).name) )+';}');//additional fonts - not required, as this writer generates basic RTF

sa('{\colortbl ;\red168\green168\blue168;}');//for highlight or font usage -> a light grey highlight background - 19feb2026

sa('}'+rcode);

//.comment
la('{\*\generator TextCore 2.00.6621}\viewkind4\uc1');

//.first par
sa('\pard\sl240\slmult1\f0\fs'+xfontsize+'\lang9'+xalignStr);//240=single line spacing, 480=double line spacing


//text -------------------------------------------------------------------------

for p:=v.wfrom to v.wto do
begin

if xfirstChar then
   begin

   case fc.c of

   ssbackslash,ssLCurlyBracket, ssRCurlyBracket:;//special char can be encoded as first char of pard
   else a1(32);//insert a space if first char is NOT a specially encoded char

   end;//case

   xfirstchar:=false;

   end;

if t.xfastchar(ff,p,1,fc) then
   begin

   //style change
   xStyleChange(true);

   //text
   if (fc.cs=wc_t) then
      begin

      case fc.c of

      ssbackslash      :a2(ssbackslash,fc.c);
      ssLCurlyBracket  :a2(ssbackslash,fc.c);
      ssRCurlyBracket  :a2(ssbackslash,fc.c);

      9:sa('\tab ');//19feb2026

      10:begin

         sa('\par'+rcode);

         if low__setint(xalign,t.xfastfindalign(p+1)) and (p<v.wto) then
            begin

            sa('\pard\sl240\slmult1\fs'+xfontsize+xalignStr+#32);

            end;

         end;

      13               :;

      else if (fc.c<=127) then a1( fc.c )//standard ascii range 0..127
      else if (fc.c>127)  then sa( '\' + #39 + strlow(int1__hex2(fc.c)) );//extended ascii range 128..255 -> "\'af" -> "\'<2 digit hex>" - 27oct2026

      end;//case

      end

   else if (fc.cs=wc_i) then
      begin

      if (iv.orgdata.len32>=1) then
         begin


         //sa('{\pict\pngblip\picw2037\pich1905\picwgoal1155\pichgoal1080 ...hex.data...} *** for a 77w x 72h image
         xformat:=strlow(io__anyformatb(@iv.orgdata));


         //.use existing image data stream if "png" or "jpg"
         if (xformat='jpg') or (xformat='png') then
            begin

            low__tohex(iv.orgdata,v.tmp3,800);

            sa('{\pict\' + low__aorbstr('png','jpeg',xformat='jpg') + 'blip' +

            '\picw'+xpicWH(iv.w)+
            '\pich'+xpicWH(iv.h)+
            '\picwgoal'+xpicWHgoal(iv.w)+
            '\pichgoal'+xpicWHgoal(iv.h)+
            #32+ v.tmp3.text +

            '}');

            //reduce ram
            v.tmp3.clear;

            end

         //.convert image data stream to "png"
         else begin

            //init
            if (a=nil) then a:=misimg32(1,1);

            //make png
            mis__fromdata(a,@iv.orgdata,e);
            png__todata(a,@v.tmp2,e);

            low__tohex(v.tmp2,v.tmp3,800);
            v.tmp2.clear;//reduce ram

            //get
            sa('{\pict\pngblip'+

            '\picw'+xpicWH(misw(a))+
            '\pich'+xpicWH(mish(a))+
            '\picwgoal'+xpicWHgoal(misw(a))+
            '\pichgoal'+xpicWHgoal(mish(a))+
            #32+ v.tmp3.text +

            '}');

            //reduce ram
            v.tmp3.clear;

            end;

         end;

      end;

   end;

end;//p


//finish document --------------------------------------------------------------
la('}');

except;end;

//free
freeobj(@a);
str__free(@b);

end;


procedure rtf__write(const xtextCore,xtextIO:tobject);//?????????????????????
begin

if (xtextCore is ttextcore) and (xtextIO is ttextio) then
   begin

   rtf__write2( (xtextCore as ttextcore) ,(xtextIO as ttextio) );

   end;

end;



//?????????????????????????????????????????????????????
//?????????????????????????????????????????????????????
//?????????????????????????????????????????????????????
//?????????????????????????????????????????????????????
//?????????????????????????????????????????????????????
//?????????????????????????????????????????????????????


function rtf__defColorTable32(const xslot:longint32;const xforegroundColor:boolean):longint32;

   procedure s(const r,g,b,a:byte);
   begin

   result             :=rgba__int(r,g,b,a);

   end;

begin

case xslot of

0   :s(000,000,000,000);
1   :s(000,000,000,255);//black
2   :s(000,000,255,255);//blue
3   :s(000,255,255,255);//cyan
4   :s(000,255,000,255);//green
5   :s(255,000,255,255);//magenta
6   :s(255,000,000,255);//red
7   :s(255,255,000,255);//yellow
8   :s(255,255,255,255);//white
9   :s(000,000,128,255);//dark blue
10  :s(000,128,128,255);//dark cyan
11  :s(000,128,000,255);//dark green
12  :s(128,000,128,255);//dark magenta
13  :s(128,000,000,255);//dark red
14  :s(128,128,000,255);//dark yellow
15  :s(128,128,128,255);//dark grey
16  :s(192,192,192,255);//light grey

else begin

   case xforegroundColor of

   true:s(000,000,000,255);//black
   else s(000,000,000,000);//transparent

   end;//case

   end;

end;//case

end;

function rtf__deffontName:string;
begin

result                          :='arial';

end;

function rtf__deffontSize:longint32;
begin

result                          :=12;

end;

function rtf__defalign:longint32;
begin

result                          :=0;

end;

function rtf__stackInit(var s:trtf_stack):boolean;
var
   p                            :longint32;

begin

result                          :=true;//pass-thru

//get
s.index                         :=0;
s.count                         :=1;

with s.list[ s.index ] do
begin

uc                              :=1;//skip count
width                           :=1;
height                          :=1;
ignorable                       :=false;

end;//with

with s.list[ s.index ].font do
begin

name                            :=rtf__deffontName;
size                            :=rtf__deffontSize;
align                           :=rtf__defalign;
color                           :=uni__defcolor;
bgcolor                         :=uni__defbgcolor;
bold                            :=false;
italic                          :=false;
underline                       :=false;
strikeout                       :=false;

end;//with

end;

function rtf__stackPush(var s:trtf_stack):boolean;
begin

//defaults
result                          :=false;

//at limit -> ignore
if (s.index>=high(s.list)) then exit;

//get
inc(s.index);
s.count                         :=succ(s.count);

//set - fill new slot with current values

//.font
s.list[ s.index ].font.name     :=s.list[ pred(s.index) ].font.name;
s.list[ s.index ].font.size     :=s.list[ pred(s.index) ].font.size;
s.list[ s.index ].font.align    :=s.list[ pred(s.index) ].font.align;
s.list[ s.index ].font.color    :=s.list[ pred(s.index) ].font.color;
s.list[ s.index ].font.bgcolor  :=s.list[ pred(s.index) ].font.bgcolor;
s.list[ s.index ].font.bold     :=s.list[ pred(s.index) ].font.bold;
s.list[ s.index ].font.italic   :=s.list[ pred(s.index) ].font.italic;
s.list[ s.index ].font.underline:=s.list[ pred(s.index) ].font.underline;
s.list[ s.index ].font.strikeout:=s.list[ pred(s.index) ].font.strikeout;

//.width & height
s.list[ s.index ].width         :=s.list[ pred(s.index) ].width;
s.list[ s.index ].height        :=s.list[ pred(s.index) ].height;

//.other
s.list[ s.index ].uc            :=s.list[ pred(s.index) ].uc;
s.list[ s.index ].ignorable     :=s.list[ pred(s.index) ].ignorable;

//successful
result                          :=true;

end;

function rtf__stackPull(var s:trtf_stack):boolean;
begin

//drop down to previous slot
result                          :=(s.index>=1);

//get
if result then
   begin

   dec(s.index);

   s.count                      :=succ(s.count);

   end;

end;

function rtf__stackSyncFont(const s:trtf_stack;var d:tanydoc;const ddocType:tdoctype):boolean;
begin

if (ddocType=d_uni) then
   begin

   result                       :=true;

   with s.list[ s.index ].font do
   begin

   with tunidoc(d) do
   begin

   font.name                    :=name;
   font.size                    :=size;
   font.align                   :=align;
   font.color                   :=color;
   font.bgcolor                 :=bgcolor;
   font.bold                    :=bold;
   font.italic                  :=italic;
   font.underline               :=underline;
   font.strikeout               :=strikeout;

   end;//with

   end;//with

   end

else if (ddocType=d_core) then
   begin

   result                       :=true;

   with s.list[ s.index ].font do
   begin

   with ttextcore(d) do
   begin
{

   font.name                    :=name;
   font.size                    :=size;
   font.align                   :=align;
   font.color                   :=color;
   font.bgcolor                 :=bgcolor;
   font.bold                    :=bold;
   font.italic                  :=italic;
   font.underline               :=underline;
   font.strikeout               :=strikeout;
{}//???????????????????

   end;//with

   end;//with

   end

else begin

   result                       :=false;

   end;

end;

function rtf__fromdata(const s:pobject;const dout:tanydoc):boolean;//04nov2026
begin

result                          :=rtf__fromdata2( s ,dout ,c_u );

end;

function rtf__fromdata2(const s:pobject;const dout:tanydoc;const dcodepointLimit:tcodepoint):boolean;//04nov2026
label
   redo ,skipone ,skipdone ,skipend;

const
   def_name                     ='arial';
   def_size                     =12;
   def_align                    =0;
   def_char                     =bad_char;

var
   f8                           :tstr8;//pointer
   f9                           :tstr9;
   ddocType                     :tdocType;
   duni                         :tunidoc;//pointer
   dcore                        :ttextcore;//pointer
   d8                           :tstr8;//pointer
   d9                           :tstr9;//pointer
   veat                         :boolean;
   vpos                         :longint32;
   vlen                         :longint32;
   v                            :longint32;
   v2                           :longint32;
   cs                           :longint32;
   cwithin                      :boolean;
   mv                           :string;
   mv32                         :longint32;
   dheaderDone                  :boolean;
   dcodepoint                   :tcodepoint;
   dcanUnicode                  :boolean;//????????????
   dcanFont                     :boolean;
   dcanImage                    :boolean;
   p                            :longint32;
   vstack                       :trtf_stack;

   //.color table
   dcolortable                  :array[0..999] of longint32;
   dcolortableCount             :longint32;

   function v0(const xpos0:longint32):longint32;
   begin

   if (xpos0>=0) and (xpos0<vlen) then
      begin

      if      (f8<>nil) then result  :=f8.pbytes[ xpos0 ]
      else if (f9<>nil) then result  :=f9.bytes [ xpos0 ]
      else                   result  :=str__bytes0(s,xpos0);

      end

   else                 result  :=0;

   end;

   function vstr(const xpos0,xlen:longint32):string;
   var
      p                         :longint32;

   begin

   result                       :='';

   for p:=xpos0 to pred(xpos0+xlen) do
   begin

   if (p>=vlen) then break;

   result                       :=result + char( v0(p) );

   end;//p

   end;

   procedure dclear;
   begin

   case ddocType of

   d_uni    :duni.clear;
   d_core   :dcore.clear;
   d_str8   :d8.clear;
   d_str9   :d9.clear;

   end;//case

   end;

   function a_7(const xchar:longint32):boolean;//add ascii 7-bit char
   begin

   //defaults
   result                       :=true;//pass-thru

   //check
   if (xchar<0) or (xchar>127) then exit;

   //get
   case ddocType of

   d_uni    :duni.a_7( xchar );
   d_core   :;//???????????????????????????? dcore.a_7( xchar );
   d_str8   :d8.addbyt1( xchar );
   d_str9   :d9.addbyt1( xchar );

   end;//case

   end;

   function a_hex(const xfrom:longint32):boolean;//add windows-1252 8-bit char from hex
   var
      v                         :longint32;
      dv                        :longint32;

   begin

   result                       :=true;//pass-thru

   //get
   v                            :=hex2__int1(  char(v0(xfrom+0)) + char(v0(xfrom+1))  );

   //set
   case ddocType of

   d_uni:begin

      case dcodepoint of

      c_u  :duni.a_8( v );
      c_8  :if (v>=0) and (v<=255) then duni.a_8( v ) else duni.a_7( def_char );
      c_7  :if (v>=0) and (v<=127) then duni.a_7( v ) else duni.a_7( def_char );
      else  duni.a_7( def_char );

      end;//case

      end;//begin

   d_core:;//???????????????????

   d_str8:begin

      case dcodepoint of

      c_8  :if u__to8( v ,dv ) then d8.addbyt1( dv );
      c_7  :if u__to7( v ,dv ) then d8.addbyt1( dv );
      else  if u__to7( v ,dv ) then d8.addbyt1( dv );

      end;//case

      end;

   d_str9:begin

      case dcodepoint of

      c_8  :if u__to8( v ,dv ) then d9.addbyt1( dv );
      c_7  :if u__to7( v ,dv ) then d9.addbyt1( dv );
      else  if u__to7( v ,dv ) then d9.addbyt1( dv );

      end;//case

      end;

   end;//case

   end;

   function a_u(const xchar:longint32):boolean;//add unicode char
   begin

   result                       :=true;//pass-thru

   case ddocType of

   d_uni    :duni.a_u( xchar );
   //d_core   :dcore.a_7( xchar );
   d_str8   :;//out of range
   d_str9   :;//out of range

   end;//case

   end;

   procedure dsyncFont;
   begin

   //???????????? rtf__stackSyncFont( vstack ,dout ,ddocType );

   end;

   function dnil:boolean;
   begin

   result                       :=true;//pass-thru

   end;

   function duc(const xval:longint32):boolean;
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].uc           :=frcmin32(xval,0);

   end;

   function dbold(const xval:boolean):boolean;
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].font.bold    :=xval;
   dsyncFont;

   end;

   function ditalic(const xval:boolean):boolean;
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].font.italic  :=xval;
   dsyncFont;

   end;

   function dunderline(const xval:boolean):boolean;
   begin

   result                                           :=true;//pass-thru
   vstack.list[vstack.index].font.underline         :=xval;
   dsyncFont;

   end;

   function dstrikeout(const xval:boolean):boolean;
   begin

   result                                           :=true;//pass-thru
   vstack.list[vstack.index].font.strikeout         :=xval;
   dsyncFont;

   end;

   function dsize(const xval:longint32):boolean;//font size
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].font.size    :=xval;
   dsyncFont;

   end;

   function dalign(const xval:longint32):boolean;//align
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].font.align   :=frcrange32( xval ,0 ,2 );
   dsyncFont;

   end;

   function dcolor(const xval:longint32):boolean;//font color
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].font.color   :=xval;
   dsyncFont;

   end;

   function dbgcolor(const xval:longint32):boolean;//background color
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].font.bgcolor :=xval;
   dsyncFont;

   end;

   function dfromColorTable(const xindex:longint32;const xforegroundColor:boolean):longint32;
   begin

   if (xindex>=0) and (xindex<dcolortableCount) then result:=dcolortable[ xindex ]//document color table
   else                                              result:=rtf__defColorTable32( xindex ,xforegroundColor );

   end;

   function dpard:boolean;
   begin

   result                                 :=true;//pass-thru
   dheaderDone                            :=true;//can start reading text now
   vstack.list[vstack.index].font.align   :=def_align;
   dsyncFont;

   end;

   function dplain:boolean;
   begin

   result                                 :=true;//pass-thru

   with vstack.list[vstack.index].font do
   begin

   size                         :=def_size;
   color                        :=dfromColorTable( 1 ,true  );
   bgcolor                      :=dfromColorTable( 0 ,false );
   bold                         :=false;
   italic                       :=false;
   underline                    :=false;
   strikeout                    :=false;

   end;//with

   dsyncFont;

   end;

   function dplainAll:boolean;
   begin

   result                                 :=true;//pass-thru

   with vstack.list[vstack.index].font do
   begin

   name                         :=def_name;
   size                         :=def_size;
   align                        :=def_align;
   color                        :=dfromColorTable( 1 ,true  );
   bgcolor                      :=dfromColorTable( 0 ,false );
   bold                         :=false;
   italic                       :=false;
   underline                    :=false;
   strikeout                    :=false;

   end;//with

   dsyncFont;

   end;

   procedure s_push;
   begin

   rtf__stackPush( vstack );

   end;

   procedure s_pull;
   begin

   //drop down to previous slot
   if rtf__stackPull( vstack ) then
      begin

      dsyncFont;

      end;

   end;

   function cstart(const xchar:longint32):boolean;
   begin

   case xchar of

   ssbackslash                  :result:=true;
   else                          result:=false;

   end;//case

   end;

   function cstop(const xchar:longint32;var xeatStopChar:boolean):boolean;
   begin

   xeatStopChar                 :=false;

   case xchar of

   9,10,13,32                   :begin;result:=true;xeatStopChar:=true;end;
   ssbackSlash                  :result:=true;
   ssLCurlyBracket              :result:=true;
   ssRCurlyBracket              :result:=true;
   ssDash                       :result:=false;//used for negative numbers
   uuA..uuZ                     :result:=false;
   lla..llz                     :result:=false;
   nn0..nn9                     :result:=false;
   else                          result:=true;

   end;//case

   end;

   function vinc(const xval:longint32):boolean;
   begin

   result                       :=true;//pass-thru

   if (xval>=1) then inc( vpos ,xval );

   end;

   function mv09(const n,xval:string):boolean;
   begin

   result                       :=strm(xval,n,mv,mv32) and (xval=(n+intstr32(mv32)));

   end;

   function c__unicode(const n:string;var xchar:longint32):boolean;
   begin

   //defaults
   result                       :=false;
   xchar                        :=0;

   //check
   if (n='') or (n[stroffset]<>rf_u) then exit;

   //read

   //????????????????????????????????????????????? finish me
   //1. lo/hi surrogate -> signals 2-parts (must jump over multiple fallback "bytes" e.g. 2="?a" and 1="?' and 1="\'ae" and 2="\'ae\'ae" etc
   //2. or 1 part only -> use u_hi/loSurrogateOK unicode procs to detect

   end;

   function a_cmd(const n:string):boolean;//add command
   var
      cu                        :longint32;//unicode char
      c8                        :longint32;//windows-1252 char
      n1                        :string;
      n2                        :string;

   begin

   //init
   result                       :=true;//pass-thru
   n1                           :=strcopy1(n,1,1);
   n2                           :=strcopy1(n,1,2);

   //get
   if      (n=rf_nil            ) then dnil
   else if (n=rf_pard           ) then dpard
   else if (n=rf_plain          ) then dplain
   else if (n=rf_par            ) then a_7(10)
   else if (n=rf_line           ) then a_7(10)//soft-return
   else if (n=rf_tab            ) then a_7(9)

   else if (n2=rf_uc            ) and mv09('uc',n) then duc( mv32 )

   else if (n=rf_b              ) then dbold(true)
   else if (n=rf_b1             ) then dbold(true)
   else if (n=rf_b0             ) then dbold(false)
   else if (n=rf_i              ) then ditalic(true)
   else if (n=rf_i1             ) then ditalic(true)
   else if (n=rf_i0             ) then ditalic(false)
   else if (n=rf_ul             ) then dunderline(true)
   else if (n=rf_ul1            ) then dunderline(true)
   else if (n=rf_ul0            ) then dunderline(false)
   else if (n=rf_ulnone         ) then dunderline(false)//turn of ALL underline variants

   else if (n2=rf_fs            ) and mv09(rf_fs        ,n) then dsize(mv32 div 2)//rtf.fontsize=N * (1/2pt) => fs24 = 12pt
   else if (n2=rf_cf            ) and mv09(rf_cf        ,n) then dcolor  (dfromColorTable( mv32 ,true  ))//set forground  color (text)
   else if (n2=rf_highlight_2c  ) and mv09(rf_highlight ,n) then dbgcolor(dfromColorTable( mv32 ,false ))//set background color (highlight)

   else if (n=rf_strike         ) then dstrikeout(true)
   else if (n=rf_strike1        ) then dstrikeout(true)
   else if (n=rf_strike0        ) then dstrikeout(false)

   else if (n=rf_ql             ) then dalign(0)//left
   else if (n=rf_qc             ) then dalign(1)//center
   else if (n=rf_qr             ) then dalign(2)//right
   else if (n=rf_qj             ) then dalign(0)//justify

//   rf_colortbl//???????????????????????
//   rf_pict//???????????????????????????????

   else if (n1=rf_u) and dcanUnicode and c__unicode( n ,cu ) then//this command may change "veat" and "vpos" due to multiple sub-parts or not
      begin

      a_u( cu );

      end;


   //showbasic('cmd>'+n+'<<');

   end;

   function signore:boolean;
   begin

   result                                 :=true;//pass-thru
   vstack.list[vstack.index].ignorable    :=true;

   end;

begin

//defaults
result                :=false;
duni                  :=nil;
dcore                 :=nil;
d8                    :=nil;
d9                    :=nil;

try

//check
if not str__lock(s)    then goto skipend;

str__as89( s, f8 ,f9 );

ddocType              :=doc__type( dout );

case ddocType of

d_uni       :duni     :=(dout as tunidoc);
d_core      :dcore    :=(dout as ttextcore);
d_str8      :d8       :=(dout as tstr8);
d_str9      :d9       :=(dout as tstr9);
else        goto skipend;//unknown document handler

end;//case


//init -------------------------------------------------------------------------

vlen                  :=str__len32( s );
vpos                  :=0;
cs                    :=0;
mv                    :='';
mv32                  :=0;
cwithin               :=false;
dheaderDone           :=false;
dcodepoint            :=doc__codepointSafe( dout ,dcodepointLimit );//enforce document handler based safe codepoint range check
dcanUnicode           :=(dcodepoint=c_u);
dcanFont              :=doc__canfont2 ( ddocType );
dcanImage             :=doc__canimage2( ddocType );

dclear;

//.stack init first "slot 0"
rtf__stackInit( vstack );

//.defaults
dplainAll;


//.default color table entries

dcolortableCount      :=17;

for p:=0 to pred(dcolortableCount) do
begin

dcolortable[p]        :=rtf__defColorTable32( p ,false );

end;//p


//get --------------------------------------------------------------------------

redo:

v                     :=v0( vpos );

//.stack
case v of

ssLCurlyBracket       :s_push;
ssRCurlyBracket       :begin

   //down 
   s_pull;

   //at end of document
   if (vstack.index<=0) then goto skipdone;

   end;

end;//case

//.end of command
if cwithin and cstop( v ,veat ) then
   begin

   //stop
   cwithin       :=false;

   //add command
   a_cmd(strlow(  vstr( cs ,vpos - cs )  ));

   //eat
   if veat then goto skipone;

   end;

//.start of command
if (not cwithin) and cstart( v ) then
   begin

   //init
   v2                 :=v0( vpos + 1 );


   //2-char fixed length commands ----------------------------------------------

   case v2 of

   ssBackSlash        :if a_7(v2)   and vinc(1) then goto skipone;//back slash
   ssLCurlyBracket    :if a_7(v2)   and vinc(1) then goto skipone;//left curly bracket
   ssRCurlyBracket    :if a_7(v2)   and vinc(1) then goto skipone;//right curly bracket
   ssDash             :if a_7(v2)   and vinc(1) then goto skipone;//optional hyphen
   ssSquiggle         :if a_u(160)  and vinc(1) then goto skipone;//non-breaking space
   ssunderscore       :if a_u(8209) and vinc(1) then goto skipone;//non-breaking hyphen
   sspipe             :if               vinc(1) then goto skipone;//formula character
   ssColon            :if               vinc(1) then goto skipone;//subentry in an index entry
   ssasterisk         :if signore   and vinc(1) then goto skipone;//Marks a destination whose text should be ignored if not understood by the RTF reader

   end;//case


   //4-char fixed length hex char ----------------------------------------------

   case v2 of

   sssinglequote      :if a_hex( vpos + 2 ) and vinc(3) then goto skipone;//character as a hex value

   end;//case


   //variable length command ---------------------------------------------------

   //start of command
   cs                 :=vpos + 1;
   cwithin            :=true;

   goto skipone;

   end;

//.skip
case v of
ssLCurlyBracket       :goto skipone;
ssRCurlyBracket       :goto skipone;
0..31                 :goto skipone;//filter out 0..31 from document text, permitted via "\'<hex>", but not here - 04nov2026
end;//case

//.normal text -> ascii 7-bit (0..127)

if (not cwithin) and (not vstack.list[vstack.index].ignorable) and dheaderDone then
   begin

   a_7( v );

   end;


skipone:

//.loop
inc(vpos);

if (vpos<vlen) then goto redo;


//successful
skipdone:

result                :=true;

skipend:

except;end;

//free
str__uaf( s );

end;


//??????????????????????????????????
//??????????????????????????????????
//??????????????????????????????????
//??????????????????????????????????

//1. Implement "\u..." handling, this can be complex as it can have multiple fallback chars in either ascii 7-bit or hex "\'ae"
//2. and be made up as a single, or two-part unicode

//e.g "\uc2\u3333\'ae\'aa\u-345\'ee\'ea" where
//the final output might be:
//a) u3333 and u-345 as 2 separate chars,
//OR
//b) u3333 and u-345 might combine into one large unicode codepoint (2 x 16bit values) using lo/hiSurrogate detection
//AND then
//c) the "vpos" and "veat" params would have to be adjusted for the multiple control words read by this one command alone


//uc2 = 2 fallback "BYTES"

//3. add support for "TextCore", so that either a "tunidoc" or a "ttextcore" can be passed and the rtf applied directly to either
//4. add "pict" support
//5. add "wmf" support
//6. add "emf" support
//7. add dcharLevel support
//8. implement font table
//9. implement color table
//10. implement font entry "\f0..N"
//11. tunidoc -> reduce down to 5-bytes per slot, from the current 7-bytes per slot - 06nov2026


end.
