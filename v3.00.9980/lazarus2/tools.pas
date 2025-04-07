unit tools;

interface

uses
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define bmp} {$define ico} {$define gif} {$define snd} {$endif}
{$ifdef con2} {$define bmp} {$define ico} {$define gif} {$define jpeg} {$endif}

{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3laz} {$ifdef laz}httpsend, ssl_openssl,{$endif} classes, sysutils, gossroot, {$ifdef gui}gossgui,{$endif} gosswin, gossio, gossimg, gossnet; {$endif}

{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}

//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
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
//## Library.................. Built-in modules for Bubbles
//## Version.................. 1.00.1895
//## Items.................... 8
//## Last Updated ............ 21feb2025, 16aug2024
//## Lines of Code............ 5,200+
//##
//## main.pas ................ app code
//## gossroot.pas ............ console/gui app startup and control
//## gossio.pas .............. file io
//## gossimg.pas ............. image/graphics
//## gossnet.pas ............. network
//## gosswin.pas ............. 32bit windows api's
//## gosssnd.pas ............. sound/audio/midi/chimes
//## gossgui.pas ............. gui management/controls
//## gossdat.pas ............. static data/icons/splash/help settings/help document(gui only)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tbubblesmodule         | tobject           | 1.00.010  | 17aug2024   | Base object for a Bubbles module
//## | tsearch                | tbubblesmodule    | 1.00.1020 | 16aug2024   | Search Engine module for Bubbles -> currently not finished
//## | tgeturl                | tthread           | 1.00.040  | 12aug2024   | Http and https document fetcher
//## | turlcache              | tobject           | 1.00.120  | 12aug2024   | Url crawl cache
//## | turlpool               | tobject           | 1.00.035  | 12aug2024   | Raw url cache for push add and trickle pull
//## | tdomainlist            | tobject           | 1.00.050  | 15aug2024   | fast domain lookup list -> for black and white domain lists
//## | tkeywordlist           | tobject           | 1.00.040  | 15aug2024   | fast keyword lookup list -> for black and white keyword lists
//## | ticonmaker             | tbubblesmodule    | 1.00.580  | 21feb2025   | icon maker
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================

type
   tsearch=class;
   turlcache=class;
   tgeturl=class;
   turlpool=class;
   tdomainlist=class;
   tkeywordlist=class;

   pdlcomp2=^tdlcomp2;
   tdlcomp2=array[0..((max32 div sizeof(tcmp8))-1)] of tcmp8;

   pkeys=^tkeys;
   tkeys=array[0..9] of comp;//0=key not used

   pkeys2=^tkeys2;
   tkeys2=array[0..9] of string;

//tramrec
   pramrec=^tramrec;
   tramrec=packed record
     dlen:byte;//domain length
     dref:comp;//domain ref
     ulen:byte;//url length
     uref:comp;//url ref
     utyp:byte;//0=http, 1=https
     uage:comp;//in seconds
     uhel:byte;//health -> 0=bad=slow won't appear in results, 1..255=OK=will appear in result -> decreases each time crawler fails to load page -> stays in index so crawler may be able to access the page later on
     drev:byte;//domain relevancy level -> 0=domain not in white list, 1=domain in white list
     krev:byte;//keyword relevancy level -> 0..10 range where 0=no keywords in white list, 5=5 keywords in white list, 10=all keywords in white list
     keys:tkeys;//0=key not used
     end;

   pdlramrec    =^tdlramrec;   tdlramrec=array[0..((max32 div sizeof(tramrec))-1)] of tramrec;

//tdiskrec
   turl    =array[0..254]  of byte;//255b -> not to exceed 255 len
   ttitle  =array[0..59]   of byte;//60b
   tdes    =array[0..239]  of byte;//240b
   tkeyword=array[0..19]   of byte;//20b

   pdiskrec=^tdiskrec;
   tdiskrec=packed record
     url :turl;
     tit :ttitle;
     des :tdes;
     keys:array[0..9] of tkeyword;
     end;

//tbubblesmodule
   tbubblesmodule=class(tobject)
   private
    imodname:string;
    ijobcount:comp;
    irundone,irunning,iloaded:boolean;
   public
    //create
    constructor create; virtual;//2 stage creation process -> stage 1: create init's basic vars in order to register system vars, stage 2: run creates the objects variables making the object usable, attempting to use the object BEFORE calling run will cause fatal errors
    procedure run; virtual;
    destructor destroy; override;
    function xrunstart:boolean;
    function xrundone(xgetvals:boolean):boolean;
    //information
    property modname:string read imodname;//read only
    function subname:string; virtual;//name used for individualise settings storage
    property running:boolean read irunning;//object is up and running
    property loaded:boolean read iloaded;//settings have been loaded
    function storagefolder:string; virtual;
    function storagefilename(xname:string):string; virtual;
    property jobcount:comp read ijobcount;
    //workers
    procedure inc_jobcount;
    function listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean; virtual;
    function statusinfo(i:longint;var n,v:string):boolean; virtual;//low level command line
    function info(n:string):string; virtual;
    procedure regvals; virtual;
    procedure getvals; virtual;
    procedure setvals; virtual;
    function readvals(f,n:string;v:tfastvars):boolean; virtual;
    function toolbarcount:longint; virtual;
    function toolbaritem(i:longint;var s,n,t,h:string):boolean; virtual;
    function specialvals(nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean; virtual;
    function canmakeraw(nadmin:boolean;n:string):boolean; virtual;
    function canmakepage(nadmin:boolean;n:string):boolean; virtual;
    function makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean; virtual;
    procedure xtimer; virtual;
    //match page name
    function mp(n,xpagename:string):boolean;//match page name
    function pp(xpagename:string):string;//public page (admin or web)
    //reg val (register value)
    procedure rb(sname:string;xdefval:boolean);
    procedure ri(sname:string;xdefval,xmin,xmax:longint);
    procedure rs(sname,xdefval:string);
    //get val (get value)
    function gb(sname:string):boolean;
    function gi(sname:string):longint;
    function gs(sname:string):string;
    //set val (set value)
    procedure sb(sname:string;xval:boolean);
    procedure si(sname:string;xval:longint);
    procedure ss(sname,xval:string);
   end;

//tsearch //11111111111111111111
   tsearch=class(tbubblesmodule)
   private
    igoodnew,itimertoggle,itimerbusy,ilastnew,ishowadd:boolean;
    iusedbandwidth,itimer100,itimer200,itimercrawl,irambytes,idiskbytes:comp;
    idomain_whitehits,idomain_blackhits,ikeyword_whitehits,ikeyword_blackhits:comp;
    ihel_def:byte;

    //search results
    iresults_domainlimit  :longint;
    iresults_domainlimit2 :longint;


    //search database
    isearch_allow         :boolean;
    isearch_size          :longint;
    isearch_check         :boolean;
    isearch_domainlimit   :longint;
    isearch_domainlimit2  :longint;
    isearch_pullpos       :longint;
    isearch_checkpos      :longint;
    isearch_checkdelcount :comp;
    isearch_checkmodcount :comp;
    irecsize              :longint;
    irecsize2             :longint;
    iactive               :longint;
    ilimit                :longint;
    ilastslot             :longint;


    //.core
    dlen:tdynamicbyte;
    dref:tdynamiccomp;
    ulen:tdynamicbyte;
    uref:tdynamiccomp;
    utyp:tdynamicbyte;
    uhel:tdynamicbyte;
    uage:tdynamiccomp;//milliseconds
    drev:tdynamicbyte;
    krev:tdynamicbyte;
    keys:array[0..9] of tdynamiccomp;


    //crawler
    icrawler_theweb       :boolean;
    icrawler_keepfresh    :boolean;
    icrawler_harvest      :boolean;
    icrawler_havebandwidth:boolean;
    icrawler_harvestlimit :longint;
    icrawler_harvestlimit2:longint;
    icrawler_rate0        :longint;
    icrawler_rate         :longint;
    icrawler_rateDELAY    :longint;
    icrawler_outlevel     :longint;
    icrawler_state        :byte;
    icrawler_outhits      :comp;

    iaddurl_allow         :boolean;
    iaddurl_spamguard     :boolean;//spam guard
    iaddurl_off           :string;
    iaddurl_ok            :string;
    iaddurl_fail          :string;

    igoodcount            :comp;
    igoodtit              :string;
    igooddes              :string;
    igoodurl              :string;

    ifailcount            :comp;
    ifailmsg              :string;
    ifailurl              :string;

    //url cache -> for crawler
    icrawlcache:turlcache;
    icrawlpool:turlpool;

    //lists
    idomain_whitelist,idomain_blacklist:tdomainlist;
    ikeyword_whitelist,ikeyword_blacklist:tkeywordlist;


    procedure xsetsize(xnewsize:longint);
    function xslotrange(xslot:longint):longint;
    function xfilename(xramlist:boolean):string;
    function xloadrec(xslot:longint;r:pramrec;d:pdiskrec):boolean;
    function xsaverec(xslot:longint;r:pramrec;d:pdiskrec):boolean;
    procedure xreload(xfromslot:longint);
    procedure xreload2(xfromslot:longint;xclear:boolean);
    function xfindslot(sdlen,sulen:longint;sdref,suref:comp;xnewslot:boolean):boolean;
    function xfindurl(sulen:longint;suref:comp):boolean;
    function xfind(k:pkeys;xout:pobject):boolean;
    procedure xonurl(sender:tobject);
    function xmakekeys(xtext:string;kout:pkeys;koutlist:pkeys2):boolean;
    procedure syncinfo;
    procedure xage_backsync;
    procedure xsync;
    function xsearchinfo:string;
    function xcrawlerinfo:string;
   public
    //create
    constructor create; override;
    procedure run; override;
    destructor destroy; override;
    //module support
    function listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean; override;
    function info(n:string):string; override;
    procedure regvals; override;
    procedure getvals; override;
    procedure setvals; override;
    function readvals(f,n:string;v:tfastvars):boolean; override;
    function statusinfo(i:longint;var n,v:string):boolean; override;
    function toolbarcount:longint; override;
    function toolbaritem(i:longint;var s,n,t,h:string):boolean; override;
    //function canmakeraw(nadmin:boolean;n:string):boolean; override;
    function canmakepage(nadmin:boolean;n:string):boolean; override;
    function makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean; override;
    procedure xtimer; override;

    //information --------------------------------------------------------------
    //.search database
    property rambytes:comp read irambytes;//ram bytes consumed
    property diskbytes:comp read idiskbytes;//disk bytes consumed
    property limit:longint read ilimit;//number of slots available 0..10,000,000
    function active:longint;//number of slots in use (active)

    property search__checkpos:longint read isearch_checkpos;
    property search__checkdelcount:comp read isearch_checkdelcount;//delete count
    property search__checkmodcount:comp read isearch_checkmodcount;//modify count

    //.crawler
    property crawler__rate:longint read icrawler_rate0;
    property crawlpool:turlpool read icrawlpool;
    property crawlcache:turlcache read icrawlcache;
    property crawler__outhits:comp read icrawler_outhits;
    property crawler__outlevel:longint read icrawler_outlevel;
    property lastslot:longint read ilastslot;


    //procs --------------------------------------------------------------------
    function find:boolean;

    //search results - procs ---------------------------------------------------
    procedure results__setdomainlimits(v,v2:longint);

    //search database - procs --------------------------------------------------
    procedure setlimit(xnewsize:longint);
    function search__check:boolean;
    property search__domainlimit :longint read isearch_domainlimit;
    property search__domainlimit2:longint read isearch_domainlimit2;
    procedure search__setdomainlimits(v,v2:longint);
    property search__pullpos:longint read isearch_pullpos;
    //.io
    function search__pushpage(xurl,xpagecode:string):boolean;
    function search__pushclean(xdomain,xurl,xtitle,xdes:string;utyp,ddrev:byte):boolean;
    function search__pullUrl(var xurl:string):boolean;
    //.slot
    function slot2rec(x:longint;r:pramrec):boolean;
    function rec2slot(x:longint;r:pramrec):boolean;
    function delslot(x:longint):boolean;
    function saveslot(x:longint):boolean;

    //crawler - procs ----------------------------------------------------------
    function crawler__havebandwidth(var xbytes:comp;xreset:boolean):boolean;
    procedure crawler__setrate(x:longint);//crawl rate urls/sec
    function crawler__canaddurls:boolean;
    function crawler__addurls(xlistOfUrls:string;xPriorityAddURL:boolean):boolean;
    function crawler__addurls2(xlistOfUrls:string;var xrejectedURLS:string;xPriorityAddURL,xreturnRejectedUrls:boolean):boolean;
    property crawler__harvestlimit :longint read icrawler_harvestlimit;//domain is unlisted
    property crawler__harvestlimit2:longint read icrawler_harvestlimit2;//domain is white listed
    procedure crawler__setharvestlimits(v,v2:longint);
    property crawler__state:byte read icrawler_state;//0=off, 1=crawling, 2=waiting, 3=draining pool
    //.io
    function crawler__canpush:boolean;
    function crawler__pushUrl(xurl:string):boolean;
    //.good info
    procedure good(xurl,xtit,xdes:string;xnew:boolean;utyp:byte);
    property goodcount:comp read igoodcount;
    property goodnew:boolean read igoodnew;
    property goodtit:string read igoodtit;
    property gooddes:string read igooddes;
    property goodurl:string read igoodurl;
    //.fail info
    procedure failed(xurl,xmsg:string;utyp:byte);
    property failcount:comp read ifailcount;
    property failmsg:string read ifailmsg;
    property failurl:string read ifailurl;
    //.black and white list counters -> each counter increments when a domain or domain's keyword matches a list when crawling
    property domain_whitehits:comp read idomain_whitehits;
    property domain_blackhits:comp read idomain_blackhits;
    property keyword_whitehits:comp read ikeyword_whitehits;
    property keyword_blackhits:comp read ikeyword_blackhits;
    procedure domain_whitehits_inc;
    procedure domain_blackhits_inc;
    //.black and white list management
    property domain_whitelist:tdomainlist read idomain_whitelist;
    property domain_blacklist:tdomainlist read idomain_blacklist;
    property keyword_whitelist:tkeywordlist read ikeyword_whitelist;
    property keyword_blacklist:tkeywordlist read ikeyword_blacklist;
   end;

//tgeturl
   tgeturl=class(tthread)
   private
     iurl,itext:string;
     procedure execute; override;
   public
     constructor create(xurl:string;xondone:tnotifyevent);
     property url:string read iurl;
     property text:string read itext;
   end;

//2222222222222222222222222222222222222//xxxxxxxxxxxxxxxxxxxxxxxxxxxx we need a url cache for crawling and add url purposes around 1 mil => 1,000,000 * 102 b => 102 Mb => ulen + utyp + url

//turlcache
   pudiskrec=^tudiskrec;
   tudiskrec=packed record
     ulen:byte;
     dlen:byte;
     utyp:byte;
     usrc:byte;//source 0=crawler -> crawl url if not in db, or if db.url is 12hrs+ old, 1=add url -> crawl regardless of age so it can be updated ASAP
     uref:comp;
     dref:comp;
     url:turl;
     end;

   turlcache=class(tobject)
   private
    istoragefolder:string;
    iaccepthits,irambytes,idiskbytes:comp;
    ilastslot,ipushpos,ipullpos,iactive,ilimit,irecsize,irecsize2:longint;
    ulen:tdynamicbyte;
    uref:tdynamiccomp;
    dlen:tdynamicbyte;
    dref:tdynamiccomp;
    procedure xsetsize(xnewsize:longint);
    function xfilename:string;
    function xloadrec(xslot:longint;d:pudiskrec):boolean;
    function xsaverec(xslot:longint;d:pudiskrec):boolean;
    procedure xreload(xfromslot:longint);
    procedure xreload2(xfromslot:longint;xclear:boolean);
    function xslotrange(xslot:longint):longint;
    procedure syncinfo;
   public
    //create
    constructor create(xstoragefolder:string); virtual;
    destructor destroy; override;
    function storagefolder:string;
    //information
    property limit:longint read ilimit;//number of slots available 0..1,000,000
    function active:longint;//number of slots in use (active)
    property rambytes:comp read irambytes;//ram bytes consumed
    property diskbytes:comp read idiskbytes;//disk bytes consumed
    procedure setlimit(xnewsize:longint);
    property pullpos:longint read ipullpos;
    property pushpos:longint read ipushpos;
    function almostfull:boolean;
    property accepthits:comp read iaccepthits;
    //io
    function canpull:boolean;
    function pull(xsearch:tsearch;var xurl:string):boolean;
    function canpush:boolean;
    function push(xsearch:tsearch;xurl:string;xPriorityAddURL:boolean):boolean;
   end;

//turlpool
   turlpool=class(tobject)
   private
    islotsize,iactive,ilimit,ipullpos,ipushpos:longint;
    ilen:tdynamicword;
    isrc:tdynamicbyte;
    icore:tstr8;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    property active:longint read iactive;
    function rambytes:longint;
    function almostfull:boolean;
    function halffull:boolean;
    //io
    function canpush:boolean;
    function push(xurl:string;xPriorityAddURL:boolean):boolean;
    function canpull:boolean;
    function pull(var xurl:string;var xPriorityAddURL:boolean):boolean;
   end;

//tdomainlist
   tdomainlist=class(tobject)
   private
    iactive,ilimit:longint;
    ilist:tobject;//tstr8 or tstr9
    ilen:tdynamicbyte;
    iref:tdynamiccomp;
    ifilename:string;
    procedure setlist(xlist:string);
    function getlist:string;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    property active:longint read iactive;
    property filename:string read ifilename write ifilename;
    //workers
    procedure clear;
    function have(xlen:longint;xref:comp):boolean;
    function load:boolean;
    function save:boolean;
    //list
    property list:string read getlist write setlist;
   end;

//tkeywordlist
   tkeywordlist=class(tobject)
   private
    iactive,ilimit:longint;
    ilist:tobject;//tstr8 or tstr9
    iref:tdynamiccomp;
    ifilename:string;
    procedure setlist(xlist:string);
    function getlist:string;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    property active:longint read iactive;
    property filename:string read ifilename write ifilename;
    //workers
    procedure clear;
    function have(xref:comp):boolean;
    function load:boolean;
    function save:boolean;
    //list
    property list:string read getlist write setlist;
   end;


//ticonmaker -------------------------------------------------------------------
   ticonmaker=class(tbubblesmodule)
   private
    itimerbusy:boolean;
    iinboundimagesizelimit,iuploadlimit:longint;
    itimer100,itimer200:comp;
    iallow:boolean;
    irambytes,idiskbytes:comp;
    igif32:string;
    function xinfo:string;
    procedure xloadsupport;
    function img2ico(v:tfastvars;var dw,dh,dbits,dcolors,dbytes:longint;var dtransparent:boolean;var dimagedata_b64:string;var derrortitle,derrormessage:string):boolean;
    function xform(v:tfastvars):string;
    function xdefaultico32(xdata:pobject):boolean;
   public
    //create
    constructor create; override;
    procedure run; override;
    destructor destroy; override;
    //module support
    function listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean; override;
    function info(n:string):string; override;
    procedure regvals; override;
    procedure getvals; override;
    procedure setvals; override;
    function readvals(f,n:string;v:tfastvars):boolean; override;
    function toolbarcount:longint; override;
    function toolbaritem(i:longint;var s,n,t,h:string):boolean; override;
    function specialvals(nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean; override;
    function canmakeraw(nadmin:boolean;n:string):boolean; override;
    function canmakepage(nadmin:boolean;n:string):boolean; override;
    function makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean; override;
    procedure xtimer; override;
    //information
    property rambytes:comp read irambytes;
    property diskbytes:comp read idiskbytes;
   end;


//timageconverter --------------------------------------------------------------
   timageconverter=class(tbubblesmodule)
   private
    itimerbusy:boolean;
    iwidthlimit,iheightlimit,iuploadlimit:longint;
    itimer100,itimer200:comp;
    iallow:boolean;
    irambytes,idiskbytes:comp;
    igif32:string;
    function xinfo:string;
    procedure xloadsupport;
    function img2img(v:tfastvars;var dw,dh,dbytes:longint;var dformat,dimagedata_b64,dthumb_b64:string;var derrortitle,derrormessage:string):boolean;
    function xform(v:tfastvars):string;
    function xdefaultimage(xdata:pobject):boolean;
   public
    //create
    constructor create; override;
    procedure run; override;
    destructor destroy; override;
    //module support
    function listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean; override;
    function info(n:string):string; override;
    procedure regvals; override;
    procedure getvals; override;
    procedure setvals; override;
    function readvals(f,n:string;v:tfastvars):boolean; override;
    function toolbarcount:longint; override;
    function toolbaritem(i:longint;var s,n,t,h:string):boolean; override;
    function specialvals(nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean; override;
    function canmakeraw(nadmin:boolean;n:string):boolean; override;
    function canmakepage(nadmin:boolean;n:string):boolean; override;
    function makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean; override;
    procedure xtimer; override;
    //information
    property rambytes:comp read irambytes;
    property diskbytes:comp read idiskbytes;
   end;

//available module names
const
   more_prefix     ='tools-';
   more_prefixLEN  =6;
var
   local_started:boolean=false;
   local_list   :array[0..99] of tbubblesmodule;//list of active modules
   local_count  :longint=0;

   //support vars
   local_age_back12hrs:comp=0;


//module procs -----------------------------------------------------------------
//start and stop modules
procedure tools__start;
procedure tools__run;
procedure tools__stop;

//fire module timers
procedure tools__timers;

//info
function tools__count:longint;
function tools__listings:string;
function tools__listing(xindex:longint;var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean;
function tools__info(xname:string):string;
function tools__names(xindex:longint;var xname:string):boolean;
function tools__vers(xindex:longint;var xname,xver:string):boolean;
function tools__bytes(xindex:longint;var xname:string;var xrambytes,xdiskbytes:comp):boolean;
function tools__have(xname:string):boolean;
function tools__find(xname:string;var xindex:longint):boolean;
function tools__findbypage(nadmin:boolean;n:string):longint;
function tools__findbypage2(nadmin:boolean;n:string;var xindex:longint):boolean;//searches modules until one supports the requested page name, e.g. "n=index.html"
function tools__findbypage3(nadmin:boolean;n:string;var xindex:longint;var xmodname:string):boolean;//searches modules until one supports the requested page name, e.g. "n=index.html"
function tools__specialvals(xindex:longint;nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean;
function tools__toolbarcount(xindex:longint):longint;
function tools__toolbaritem(xindex,xtoolindex:longint;var s,n,t,h:string):boolean;
function tools__statusinfo(xname:string;xindex:longint;var n,v:string):boolean;
function tools__canprefix(n:string):boolean;
function tools__canmakeraw(nadmin:boolean;n:string):boolean;
function tools__canmakeraw2(xindex:longint;nadmin:boolean;n:string):boolean;
function tools__canmakepage(nadmin:boolean;n:string):boolean;
function tools__canmakepage2(xindex:longint;nadmin:boolean;n:string):boolean;
function tools__makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;
function tools__makepage2(xindex:longint;nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;
function tools__makepagestr(nadmin:boolean;n:string;v:tfastvars;var xdata:string;var xbinary:boolean):boolean;
function tools__makepagestr2(xindex:longint;nadmin:boolean;n:string;v:tfastvars;var xdata:string;var xbinary:boolean):boolean;

//settings
procedure tools__regvals;
procedure tools__getvals;
procedure tools__setvals;

//read settings from html form
function tools__readvals(xindex:longint;f,n:string;v:tfastvars):boolean;


//support procs ----------------------------------------------------------------
//.general
function low__filter(x:string;xfull:boolean):string;

//.keyword
function keyword__makeref(xkeyword:string):comp;
function keyword__sep(c:byte):boolean;
function keyword__filter(x:string;xreadTosep:boolean;var kout:string):boolean;

//.url
function url__split(surl:string;var utyp:byte;var xdomain,xurl:string):boolean;
function url__split2(surl:string;var utyp:byte;var xisfrontpage:boolean;var xdomain,xurl:string;xisfrontpageCHECK,xstrict:boolean):boolean;
function url__makeref(xurl:string):comp;
function url__nowage:comp;
function url__nowage2(inc_hr:longint):comp;
function url__older_than_12hrs(uage:comp):boolean;
function url__hasdomainname(xurl:string):boolean;//not an numbered ip address -> help to prevent indexing internal ip addresses

//.html
function html__inserttag(xtag:array of byte;xhtml,xvalue:pobject;xvaluestr:string;xappendIfnotfound:boolean):boolean;
function html__inserttag1(xhtml,xvalue:pobject;xvaluestr:string;xappend:boolean):boolean;
function html__inserttag2(xhtml,xvalue:pobject;xvaluestr:string;xappend:boolean):boolean;


implementation

uses
   main;


procedure tools__start;
   procedure s(o:tbubblesmodule);
   begin
   if (local_count<=high(local_list)) then
      begin
      local_list[local_count]:=o;
      inc(local_count);
      end;
   end;
begin
//check
if local_started         then exit else local_started:=true;
//.tools are disabled
if not app__bol('tools') then exit;

//start each server tool module ------------------------------------------------

//.mini search engine and web crawler -> under construction - 20feb2025
//{$ifdef laz}
//s(tsearch.create);//requires https support via Lazarus
//{$endif}

s(ticonmaker.create);
s(timageconverter.create);
end;

procedure tools__run;
var
   p:longint;
begin
//run modules
if (local_count>=1) then for p:=0 to (local_count-1) do if (local_list[p]<>nil) and (not local_list[p].running) then local_list[p].run;
end;

procedure tools__stop;
var
   p:longint;
begin
if (local_count>=1) then for p:=0 to (local_count-1) do freeobj(@local_list[p]);
end;

function tools__running(xindex:longint):boolean;
begin
result:=(xindex>=0) and (xindex<local_count) and (local_list[xindex]<>nil) and local_list[xindex].running;
end;

function tools__count:longint;
begin
result:=local_count;
end;

function tools__listings:string;
var
   b:tstr8;
   xcount,p:longint;
   ximgdata,xtitle,xdescription,xrootpage:string;
   xonline:boolean;
   xjobcount,xrambytes,xdiskbytes:comp;

   procedure a(x:string);
   begin
   str__saddb(@b,x);
   end;

   procedure d(x:string);
   begin
   str__saddb(@b,'<div>'+x+'</div>');
   end;

   function mb(x:comp):string;
   begin
   result:=low__size(x,'mb+',3,true);
   end;

   procedure la;
   begin
   str__saddb(@b,
   '<a href="'+xrootpage+'" style="text-decoration:none">'+
   '<div style="display:grid;grid-template-columns:auto 1fr;grid-gap:2px;width:auto;padding:10px;border:1px #eee solid;border-radius:15px;color:#555;">'+

    '<div style="width:64px;height:64px;margin:0;margin-right:10px;border-radius:12px;"></div>'+

    '<div>'+
    '<div style="display:block;font-size:1.00em;font-weight:bold;">'+k64(xcount)+'. '+xtitle+'</div>'+
    '<div style="display:block;font-size:0.85em;">'+xdescription+'</div>'+
    '<div style="display:grid;grid-template-columns:auto auto auto auto;grid-gap:5px;font-size:0.70em;margin-top:10px;border-radius:15px;"><div style="border-radius:inherit;text-align:center;'+low__aorbstr('color:white;background-color:red;','color:#444;background-color:lime;',xonline)+'">'+low__aorbstr('Offline','Online',xonline)+'</div><div style="border-radius:inherit;text-align:center;color:#444;background-color:#ddd;">'+k64(xjobcount)+' jobs</div><div>RAM: '+mb(xrambytes)+'</div><div>Disk: '+mb(xdiskbytes)+'</div></div>'+
    '</div>'+

   '</div>'+
   '</a>'+
   '');
   end;
begin
result:='';
b:=nil;

try
//init
b:=str__new8;

if (tools__count>=1) then
   begin
   xcount:=0;
   a('<div class="tool-listings" style="max-width:100%;padding:0;border:0;">');

   for p:=0 to (tools__count-1) do
   begin
   if tools__listing(p,ximgdata,xtitle,xdescription,xrootpage,xonline,xjobcount,xrambytes,xdiskbytes) then
      begin
      inc(xcount);
      la;
      end;
   end;//p

   a('</div>');

   //set
   result:=str__text(@b);
   end
else
   begin
   result:='Built-in tools are disabled';
   end;

except;end;
try;str__free(@b);except;end;
end;

function tools__listing(xindex:longint;var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean;
begin
result:=tools__running(xindex);
if result then local_list[xindex].listing(ximgdata,xtitle,xdescription,xrootpage,xonline,xjobcount,xrambytes,xdiskbytes);
end;

function tools__info(xname:string):string;
var
   p,nlen:longint;
begin
//defaults
result:='';

//init
xname:=strlow(xname);

//find
for p:=0 to (local_count-1) do if tools__running(p) then
   begin
   nlen:=low__lengthb(local_list[p].modname);
   if strmatch( strcopy1(xname,1,1+nlen), local_list[p].modname+'.' ) then
      begin
      result:=local_list[p].info(strcopy1(xname,nlen+2,low__length(xname)));
      break;
      end;
   end;//p
end;

function tools__names(xindex:longint;var xname:string):boolean;
begin
if tools__running(xindex) then xname:=local_list[xindex].modname else xname:='';
result:=(xname<>'');
end;

function tools__vers(xindex:longint;var xname,xver:string):boolean;
var
   v:string;
begin
if tools__names(xindex,v) then
   begin
   v:=v+'.';
   xname:=tools__info(v+'name');
   xver :=tools__info(v+'ver');
   result:=true;
   end
else result:=false;
end;

function tools__bytes(xindex:longint;var xname:string;var xrambytes,xdiskbytes:comp):boolean;
var
   v:string;
begin
if tools__names(xindex,v) then
   begin
   xname:=tools__info(v+'.name');
   xrambytes:=strint64(tools__info(v+'.rambytes'));
   xdiskbytes:=strint64(tools__info(v+'.diskbytes'));
   result:=true;
   end
else result:=false;
end;

procedure tools__timers;
var
   p:longint;
begin
if (local_count>=1) then for p:=0 to (local_count-1) do if tools__running(p) then local_list[p].xtimer;
end;

function tools__have(xname:string):boolean;
var
   int1:longint;
begin
result:=tools__find(xname,int1);
end;

function tools__find(xname:string;var xindex:longint):boolean;
var
   p:longint;
begin
result:=false;

if (local_count>=1) then for p:=0 to (local_count-1) do if tools__running(p) and strmatch( strcopy1(xname,1,low__lengthb(local_list[p].modname)) ,local_list[p].modname) then
   begin
   xindex:=p;
   result:=true;
   break;
   end;
end;

function tools__findbypage(nadmin:boolean;n:string):longint;
begin
tools__findbypage2(nadmin,n,result);
end;

function tools__findbypage2(nadmin:boolean;n:string;var xindex:longint):boolean;//searches modules until one supports the requested page name, e.g. "n=index.html"
var
   str1:string;
begin
result:=tools__findbypage3(nadmin,n,xindex,str1);
end;

function tools__findbypage3(nadmin:boolean;n:string;var xindex:longint;var xmodname:string):boolean;//searches modules until one supports the requested page name, e.g. "n=index.html"
var
   p:longint;
begin
//defaults
result:=false;
xindex:=-1;
xmodname:='';

//find
if (local_count>=1) and tools__canprefix(n) then
   begin
   n:=strlow(n);
   for p:=0 to (local_count-1) do if tools__running(p) and local_list[p].canmakepage(nadmin,n) then
      begin
      xindex:=p;
      xmodname:=local_list[p].modname;
      result:=true;
      break;
      end;//p
   end;
end;

function tools__toolbarcount(xindex:longint):longint;
begin
if tools__running(xindex) then result:=local_list[xindex].toolbarcount else result:=0;
end;

function tools__toolbaritem(xindex,xtoolindex:longint;var s,n,t,h:string):boolean;
begin
result:=tools__running(xindex) and local_list[xindex].toolbaritem(xtoolindex,s,n,t,h);
end;

function tools__statusinfo(xname:string;xindex:longint;var n,v:string):boolean;
var
   i:longint;
begin
result:=tools__find(xname,i) and local_list[i].statusinfo(xindex,n,v);
end;

function tools__specialvals(xindex:longint;nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean;
begin
result:=tools__running(xindex) and local_list[xindex].specialvals(nadmin,n,xuploadlimit,xmultipart,xcanmakeraw,xreadpost);
end;

function tools__canprefix(n:string):boolean;
begin
result:=strmatch(more_prefix,strcopy1(n,1,more_prefixLEN));
end;

function tools__canmakeraw(nadmin:boolean;n:string):boolean;
var
   i:longint;
begin
result:=tools__findbypage2(nadmin,n,i) and local_list[i].canmakeraw(nadmin,n);
end;

function tools__canmakeraw2(xindex:longint;nadmin:boolean;n:string):boolean;
begin
result:=tools__running(xindex) and tools__canprefix(n) and local_list[xindex].canmakeraw(nadmin,n);
end;

function tools__canmakepage(nadmin:boolean;n:string):boolean;
var
   i:longint;
begin
result:=tools__findbypage2(nadmin,n,i) and local_list[i].canmakepage(nadmin,n);
end;

function tools__canmakepage2(xindex:longint;nadmin:boolean;n:string):boolean;
begin
result:=tools__running(xindex) and tools__canprefix(n) and local_list[xindex].canmakepage(nadmin,n);
end;

function tools__makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;
begin
result:=tools__makepage2(-1,nadmin,n,v,xdata,xbinary);
end;

function tools__makepage2(xindex:longint;nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;
begin
case (xindex>=0) and (xindex<local_count) and (local_list[xindex]<>nil) and local_list[xindex].running of
true :result:=local_list[xindex].makepage(nadmin,n,v,xdata,xbinary);//direct access
else  result:=tools__findbypage2(nadmin,n,xindex) and local_list[xindex].makepage(nadmin,n,v,xdata,xbinary);//search for it
end;//case
end;

function tools__makepagestr(nadmin:boolean;n:string;v:tfastvars;var xdata:string;var xbinary:boolean):boolean;
begin
result:=tools__makepagestr2(-1,nadmin,n,v,xdata,xbinary);
end;

function tools__makepagestr2(xindex:longint;nadmin:boolean;n:string;v:tfastvars;var xdata:string;var xbinary:boolean):boolean;
var
   b:tobject;
begin
result:=false;
b:=nil;

try
b:=str__new8;
result:=tools__makepage2(xindex,nadmin,n,v,@b,xbinary);
if result then xdata:=str__text(@b);
except;end;
try;str__free(@b);except;end;
end;

procedure tools__regvals;
var
   i:longint;
begin
if (local_count>=1) then for i:=0 to (local_count-1) do if (local_list[i]<>nil) then local_list[i].regvals;
end;

procedure tools__getvals;
var
   i:longint;
begin
if (local_count>=1) then for i:=0 to (local_count-1) do if tools__running(i) then local_list[i].getvals;
end;

procedure tools__setvals;
var
   i:longint;
begin
if (local_count>=1) then for i:=0 to (local_count-1) do if tools__running(i) then local_list[i].setvals;
end;

function tools__readvals(xindex:longint;f,n:string;v:tfastvars):boolean;
begin
result:=tools__running(xindex) and local_list[xindex].readvals(f,n,v);
end;


//tbubblesmodule ---------------------------------------------------------------
constructor tbubblesmodule.create;
begin
inherited create;
imodname:='nil';
irundone:=false;
irunning:=false;
iloaded:=false;
ijobcount:=0;
end;

procedure tbubblesmodule.run;
begin
xrunstart;
xrundone(false);
end;

function tbubblesmodule.xrunstart:boolean;
begin
result:=not irundone;
if result then irundone:=true;
end;

function tbubblesmodule.xrundone(xgetvals:boolean):boolean;
begin
irundone:=true;
irunning:=true;
if xgetvals then getvals;
end;

destructor tbubblesmodule.destroy;
begin
inherited destroy;
end;

function tbubblesmodule.listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean;
begin
result:=true;
ximgdata:='';
xtitle:='Untitled';
xdescription:='Untitled Tool';
xrootpage:=pp('index.html');
xonline:=false;
xjobcount:=0;
xrambytes:=0;
xdiskbytes:=0;
end;

function tbubblesmodule.pp(xpagename:string):string;//public page (admin or web)
begin
result:=more_prefix+xpagename;
end;

function tbubblesmodule.mp(n,xpagename:string):boolean;//match page name
begin
result:=strmatch(n,more_prefix+xpagename);
end;

procedure tbubblesmodule.inc_jobcount;
begin
low__roll64(ijobcount,1);
end;

function tbubblesmodule.subname:string;
begin
result:=modname;
end;

function tbubblesmodule.storagefolder:string;
begin
result:=app__subfolder(more_prefix+modname);
end;

function tbubblesmodule.storagefilename(xname:string):string;
begin
result:=storagefolder+xname;
end;

procedure tbubblesmodule.rb(sname:string;xdefval:boolean);
begin
app__breg(subname+'.'+sname,xdefval);
end;

procedure tbubblesmodule.ri(sname:string;xdefval,xmin,xmax:longint);
begin
app__ireg(subname+'.'+sname,xdefval,xmin,xmax);
end;

procedure tbubblesmodule.rs(sname,xdefval:string);
begin
app__sreg(subname+'.'+sname,xdefval);
end;

function tbubblesmodule.gb(sname:string):boolean;
begin
result:=app__bval(subname+'.'+sname);
end;

function tbubblesmodule.gi(sname:string):longint;
begin
result:=app__ival(subname+'.'+sname);
end;

function tbubblesmodule.gs(sname:string):string;
begin
result:=app__sval(subname+'.'+sname);
end;

procedure tbubblesmodule.sb(sname:string;xval:boolean);
begin
app__bvalset(subname+'.'+sname,xval);
end;

procedure tbubblesmodule.si(sname:string;xval:longint);
begin
app__ivalset(subname+'.'+sname,xval);
end;

procedure tbubblesmodule.ss(sname,xval:string);
begin
app__svalset(subname+'.'+sname,xval);
end;

function tbubblesmodule.info(n:string):string;
begin
result:='';
end;

procedure tbubblesmodule.regvals;
begin

end;

procedure tbubblesmodule.getvals;
begin
iloaded:=true;
end;

procedure tbubblesmodule.setvals;
begin

end;

function tbubblesmodule.readvals(f,n:string;v:tfastvars):boolean;
begin
result:=false;
end;

function tbubblesmodule.statusinfo(i:longint;var n,v:string):boolean;
begin
result:=false;
end;

function tbubblesmodule.toolbarcount:longint;
begin
result:=0;
end;

function tbubblesmodule.toolbaritem(i:longint;var s,n,t,h:string):boolean;
begin
result:=false;
end;

function tbubblesmodule.specialvals(nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean;
begin
result:=false;
xuploadlimit:=0;
xmultipart:=false;
xcanmakeraw:=false;
xreadpost:=false;
end;

function tbubblesmodule.canmakeraw(nadmin:boolean;n:string):boolean;
begin
result:=false;
end;

function tbubblesmodule.canmakepage(nadmin:boolean;n:string):boolean;
begin
result:=false;
end;

function tbubblesmodule.makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;
begin
result:=false;
end;

procedure tbubblesmodule.xtimer;
begin

end;


//tsearch ----------------------------------------------------------------------
constructor tsearch.create;
begin
inherited create;
imodname:='search';
regvals;
end;

procedure tsearch.run;
label
   redo;
var
   p:longint;
begin
//check
if not xrunstart then exit;

//get
itimerbusy           :=false;
itimertoggle         :=false;
ishowadd             :=false;//debug only
ihel_def             :=10;//default health of new url
ilimit               :=-1;
irecsize             :=sizeof(tramrec);
irecsize2            :=sizeof(tdiskrec);
ilastslot            :=-1;
ilastnew             :=false;
irambytes            :=0;
idiskbytes           :=0;
itimer100            :=0;
itimer200            :=0;
itimercrawl          :=0;
iusedbandwidth       :=0;


//search results - settings
iresults_domainlimit   :=3;
iresults_domainlimit2  :=100;


//search database - settings
isearch_allow          :=false;
isearch_size           :=0;
isearch_check          :=false;

isearch_pullpos        :=-1;

isearch_domainlimit    :=3;
isearch_domainlimit2   :=50;

isearch_checkpos       :=-1;
isearch_checkdelcount  :=0;
isearch_checkmodcount  :=0;


//crawler - settings
icrawler_harvest       :=false;//allow harvesting of links from page code if page is a front page
icrawler_theweb        :=false;//crawl the web
icrawler_keepfresh     :=false;//keep database fresh -> crawl the database
icrawler_rate0         :=0;//1..100 - user set
icrawler_rate          :=0;//0..100 - internally set
icrawler_rateDELAY     :=1;
icrawler_outlevel      :=0;
icrawler_harvestlimit  :=50;//links extraction from page text
icrawler_harvestlimit2 :=500;
icrawler_outhits       :=0;
icrawler_state         :=0;

iaddurl_allow          :=true;
iaddurl_spamguard      :=false;
iaddurl_off            :='';
iaddurl_ok             :='';
iaddurl_fail           :='';

idomain_whitehits      :=0;
idomain_blackhits      :=0;
ikeyword_whitehits     :=0;
ikeyword_blackhits     :=0;

ifailmsg               :='';
ifailurl               :='';
ifailcount             :=0;

igoodtit               :='';
igooddes               :='';
igoodurl               :='';
igoodcount             :=0;
igoodnew               :=false;

//core
dlen           :=new__byte;
dref           :=new__comp;
ulen           :=new__byte;
uref           :=new__comp;
utyp           :=new__byte;
uhel           :=new__byte;
uage           :=new__comp;
drev           :=new__byte;
krev           :=new__byte;
for p:=0 to high(keys) do keys[p]:=new__comp;

//url caches
icrawlcache:=turlcache.create(storagefolder);
icrawlpool:=turlpool.create;

//lists
idomain_whitelist:=tdomainlist.create;
idomain_whitelist.filename:=storagefolder+'domain-whitelist.txt';
idomain_whitelist.load;

idomain_blacklist:=tdomainlist.create;
idomain_blacklist.filename:=storagefolder+'domain-blacklist.txt';
idomain_blacklist.load;

ikeyword_whitelist:=tkeywordlist.create;
ikeyword_whitelist.filename:=storagefolder+'keyword-whitelist.txt';
ikeyword_whitelist.load;

ikeyword_blacklist:=tkeywordlist.create;
ikeyword_blacklist.filename:=storagefolder+'keyword-blacklist.txt';
ikeyword_blacklist.load;


//defaults - off
xage_backsync;
xsetsize(0);

//done -> we are now running and "getvals" has been fired - 18aug2024
xrundone(true);
end;

destructor tsearch.destroy;
var
   p:longint;
   xref:comp;
begin
try
inherited destroy;

//object was not started -> core vars not set so don't destroy them
if not irunning then exit;

//wait for threads to close
xref:=add64(ms64,30000);//30s
while true do
begin
if (icrawler_outlevel<=0) then break;
win____sleep(100);
app__processmessages;//threads talk to main thread so needs processing
end;

//core
freeobj(@dlen);
freeobj(@dref);
freeobj(@ulen);
freeobj(@uref);
freeobj(@utyp);
freeobj(@uhel);
freeobj(@uage);
freeobj(@drev);
freeobj(@krev);
for p:=0 to high(keys) do freeobj(@keys[p]);

//url caches
freeobj(@icrawlcache);
freeobj(@icrawlpool);

//lists
freeobj(@idomain_whitelist);
freeobj(@idomain_blacklist);

freeobj(@ikeyword_whitelist);
freeobj(@ikeyword_blacklist);
except;end;
end;

function tsearch.listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean;
begin
result:=true;
ximgdata:='';
xtitle:='Search';
xdescription:='Search Engine and Web Crawler';
xrootpage:=pp('search.html');
xonline:=isearch_allow;
xjobcount:=0;
xrambytes:=irambytes;
xdiskbytes:=idiskbytes;
end;

function tsearch.canmakepage(nadmin:boolean;n:string):boolean;
begin
case nadmin of
false:result:=mp(n,'search.html') or mp(n,'addurl.html');
else  result:=mp(n,'search.html') or mp(n,'crawler.html') or mp(n,'addurls.html') or mp(n,'addurl.html') or mp(n,'wl.html') or mp(n,'bl.html');
end;
end;

function tsearch.makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;
var
   z:string;
   zlen:longint;

   function xsave2(xname,xlabel:string;xenable:boolean):string;
   begin
   result:=xvsep+'<input name="cmd" type="hidden" value="'+xname+'">'+insstr('<input class="button" type=submit value="'+strdefb(xlabel,'Save')+'">',xenable)+'</form>'+#10;
   end;

   function xsave(xname:string):string;
   begin
   result:=xsave2(xname,'',true);
   end;

   function fs(xname:string;xhash:string):string;//form start
   begin
   result:='<form class="block" method=post action="'+pp(xname)+insstr('#',xhash<>'')+xhash+'">';
   end;
begin
result:=false;
xbinary:=false;

//check
if (not str__lock(xdata)) or (v=nil) then exit;

try
//public pages -----------------------------------------------------------------
if not nadmin then
   begin
   if mp(n,'search.html') then
      begin
      result:=true;
      //str__settextb(xdata,'Some text for the public SEARCH.html page '+ms64str);
      end
   else if mp(n,'addurl.html') then
      begin
      result:=true;
      str__settextb(xdata,'AddURL text...'+ms64str);
      end;
   end

//admin pages ------------------------------------------------------------------
else if mp(n,'search.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('db',xsymbol('search')+'Search Database')+
   xsearchinfo+

   fs('search.html','db')+
   '<div class="grid2">'+#10+
   '<div>Database Capacity (1..10,000,000 urls)<br><input class="text" name="size" type="text" value="'+k64(isearch_size)+'"></div>'+#10+
   '<div></div>'+
   '<div>Max Entries - Unlisted Domains (1..1,000,000)<br><input class="text" name="domainlimit" type="text" value="'+k64(isearch_domainlimit)+'"></div>'+#10+
   '<div>Max Entries - White Listed Domains (1..1,000,000)<br><input class="text" name="domainlimit2" type="text" value="'+k64(isearch_domainlimit2)+'"></div>'+#10+

   html__checkbox('Enable the Search Database and permit Searching (use '+pp('search.html')+') and Crawling operations','allow',isearch_allow,true,true)+
   html__checkbox('Gradually delete or modify entries in the Search Database according to the White and Black Lists.  Progress indicated by Check Slot.','check',isearch_check,true,true)+
   '</div>'+#10+

   '<p style="font-weight:bold">Hint</p>'+
   'Search results are automatically inserted into the "'+pp('search.html')+'" page of your website.  Please ensure this file exists.  Use the <span style="text-wrap:nowrap;">"&lt;!--insert--!&gt;"</span> tag (no quotes) to control '+
   'where on the page to insert the results.  If the tag is not present, the results will be inserted at the bottom of the page.'+
   xsave('search.settings')+


   xh2('results',xsymbol('search')+'Search Results')+
   fs('search.html','results')+
   '<div class="grid2">'+#10+
   '<div>Max Entries - Unlisted Domains (0..5000)<br><input class="text" name="results.domainlimit" type="text" value="'+k64(iresults_domainlimit)+'"></div>'+#10+
   '<div>Max Entries - White Listed Domains (0..5000)<br><input class="text" name="results.domainlimit2" type="text" value="'+k64(iresults_domainlimit2)+'"></div>'+#10+

   '</div>'+#10+
   xsave('search.results')+
   '');
   end

else if mp(n,'crawler.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('crawler',xsymbol('crawler')+'Crawler Settings')+
   insstr('<div class="bad">Crawler is offline as the Search Database is offline - see the "Search" tab to enable.</div>',not isearch_allow)+
   xcrawlerinfo+

   fs('crawler.html','')+
   '<div class="grid2">'+#10+
   '<div class="inlineblock">Crawl Rate (1..100 urls/sec)<br><input class="text" name="crawler.rate" type="text" value="'+k64(icrawler_rate0)+'"></div>'+#10+
   '<div></div>'+

   html__checkbox('Crawl The Web','crawler.theweb',icrawler_theweb,isearch_allow,true)+
   html__checkbox('Keep Database Fresh','crawler.keepfresh',icrawler_keepfresh,isearch_allow and icrawler_theweb,true)+
   '</div>'+#10+
   xsave('crawler.settings')+


   xh2('harvest',xsymbol('harvest')+'Harvest Settings')+
   fs('crawler.html','harvest')+
   '<div class="grid2">'+#10+

   '<div class="inlineblock">Harvest Limit - Unlisted Domains (0..30,000)<br><input class="text" name="crawler.harvestlimit" type="text" value="'+k64(icrawler_harvestlimit)+'"></div>'+#10+
   '<div class="inlineblock">Harvest Limit - White Listed Domains (0..30,000)<br><input class="text" name="crawler.harvestlimit2" type="text" value="'+k64(icrawler_harvestlimit2)+'"></div>'+#10+

   html__checkbox('Enable Link Harvesting - Only front pages are harvested (domain)','crawler.harvest',icrawler_harvest,true,true)+
   '</div>'+#10+
   xsave('crawler.harvest.settings')+
   '');
   end

else if mp(n,'addurls.html') then
   begin
   //get and flush
   z:=v.s['urllist.leftover'];
   zlen:=low__length(z);
   v.s['urllist.leftover']:='';

   //page
   result:=true;
   str__settextb(xdata,

   xh2('crawler',xsymbol('crawler')+'Add Urls')+
   insstr('<div class="bad">This option is disabled as the Search Database is offline - see the "Search" tab to enable.</div>',not isearch_allow)+
   insstr('<div class="bad">Warning: Some urls were not accepted because the crawl pool / cache is full.  Please try again in a minute.</div>',zlen>=1)+
   xcrawlerinfo+

   fs('addurls.html','')+
   'Type one url per line in the box below and be sure to include "http://" or "https://".  Submitted urls are stored in the crawl pool and trickled into the crawl cache ready for indexing.'+#10+
   '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="urllist">'+net__encodeforhtmlstr(z)+'</textarea>'+#10+

   xsave2('addurl.list','',isearch_allow)+
   '');
   end

else if mp(n,'addurl.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('search',xsymbol('search')+'Add Url Submissions')+
   fs('addurl.html','')+
   '<div class="grid2">'+#10+
   '<div><input name="addurl.allow" type="checkbox" '+insstr('checked',iaddurl_allow)+'>Allow Url Submissions (use '+pp('addurl.html')+').  Submissions are stored in the '+'crawl cache for crawling.  See crawl settings below.</div>'+#10+
   '<div><input name="addurl.spamguard" type="checkbox" '+insstr('checked',iaddurl_spamguard)+'>Protect against mass spam with Spam Guard.  Presents a simple math question on the add url form.  A correct answer stores the url submission for crawling, and an incorrect one discards it.</div>'+#10+
   '<div class="inlineblock">1. '+net__encodeforhtmlstr(iaddurl_def_ok)+'<br><input class="text" name="addurl.ok" type="text" value="'+net__encodeforhtmlstr(iaddurl_ok)+'"></div>'+#10+
   '<div class="inlineblock">2. '+net__encodeforhtmlstr(iaddurl_def_fail)+'<br><input class="text" name="addurl.fail" type="text" value="'+net__encodeforhtmlstr(iaddurl_fail)+'"></div>'+#10+
   '<div class="inlineblock">3. '+net__encodeforhtmlstr(iaddurl_def_off)+'<br><input class="text" name="addurl.off" type="text" value="'+net__encodeforhtmlstr(iaddurl_off)+'"></div>'+#10+
   '</div>'+#10+

   xsave('addurl')+
   '');
   end

else if mp(n,'wl.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('domain',xsymbol('search')+'White Listed Domains')+
   '<div class="console2 miniinfo">'+'CAPACITY: '+k64(idomain_whitelist.active)+' / '+k64(idomain_whitelist.limit)+'</div>'+#10+

   fs('wl.html','domain')+
   'Type one domain name per line in the box below'+#10+
   '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="list">'+net__encodeforhtmlstr(idomain_whitelist.list)+'</textarea>'+#10+
   xsave('dwl.list')+


   xh2('keyword',xsymbol('search')+'White Listed Keywords')+
   '<div class="console2 miniinfo">'+'CAPACITY: '+k64(ikeyword_whitelist.active)+' / '+k64(ikeyword_whitelist.limit)+'</div>'+#10+

   fs('wl.html','keyword')+
   'Type one keyword per line in the box below'+#10+
   '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="list">'+net__encodeforhtmlstr(ikeyword_whitelist.list)+'</textarea>'+#10+
   xsave('kwl.list')+
   '');
   end

else if mp(n,'bl.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('domain',xsymbol('search')+'Black Listed Domains')+
   '<div class="console2 miniinfo">'+'CAPACITY: '+k64(idomain_blacklist.active)+' / '+k64(idomain_blacklist.limit)+'</div>'+#10+

   fs('bl.html','domain')+
   'Type one domain name per line in the box below'+#10+
   '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="list">'+net__encodeforhtmlstr(idomain_blacklist.list)+'</textarea>'+#10+
   xsave('dbl.list')+


   xh2('keyword',xsymbol('search')+'Black Listed Keywords')+
   '<div class="console2 miniinfo">'+'CAPACITY: '+k64(ikeyword_blacklist.active)+' / '+k64(ikeyword_blacklist.limit)+'</div>'+#10+

   fs('bl.html','keyword')+
   'Type one keyword per line in the box below'+#10+
   '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="list">'+net__encodeforhtmlstr(ikeyword_blacklist.list)+'</textarea>'+#10+
   xsave('kbl.list')+
   '');
   end;

except;end;
try;str__uaf(xdata);except;end;
end;

function tsearch.xsearchinfo:string;
var
   bol1,bol2:boolean;
begin
bol1:=isearch_allow and isearch_check;
bol2:=isearch_allow and (igoodcount>=1);

result:=
'<div class="console2 miniinfo">'+
'RAM '+low__mbauto(irambytes,true)+' &nbsp; &nbsp; DISK '+low__mbauto(idiskbytes,true)+' &nbsp; &nbsp; CAPACITY '+low__aorbstr('-',k64(iactive)+' of '+k64(ilimit),isearch_allow)+' &nbsp; &nbsp; Check Slot '+low__aorbstr('-',k64(frcmin32(isearch_checkpos,0)),bol1)+'<br>'+
'<br>'+
'Slots Deleted   '+low__aorbstr('-',k64(isearch_checkdelcount),bol1)+'<br>'+
'Slots Modified  '+low__aorbstr('-',k64(isearch_checkmodcount),bol1)+'<br>'+
'Total Accepted  '+low__aorbstr('-',k64(igoodcount),bol2)+'<br>'+
'<br>'+
'Title/Des.      '+low__aorbstr('-', low__aorbstr('[UPDATE]','[NEW]',igoodnew)+' "'+igoodtit+'" / "'+igooddes+'"', bol2)+'<br>'+
'Url             '+low__aorbstr('-','"'+igoodurl+'"',bol2)+
'</div>'+#10;
end;

function tsearch.xcrawlerinfo:string;
var
   v:string;
begin
case icrawler_state of
0:v:='Off';
1:v:='Crawling';
2:v:='Waiting';
3:v:='Paused - Draining Pool';
else v:='Unknown';
end;

result:=
'<div class="console2 miniinfo">'+
'RAM '+low__mbauto(icrawlcache.rambytes,true)+' &nbsp; &nbsp; DISK '+low__mbauto(icrawlcache.diskbytes,true)+' &nbsp; &nbsp; CAPACITY '+low__aorbstr('-',k64(icrawlcache.active)+' of '+k64(icrawlcache.limit),isearch_allow) + ' &nbsp; &nbsp; POOL '+k64(icrawlpool.active)+' of '+k64(icrawlpool.limit)+'<br>'+
'<br>'+
'Black List Hits  '+k64(add64(idomain_blackhits,ikeyword_blackhits)) +' (domain '+k64(idomain_blackhits)+' &nbsp keyword '+k64(ikeyword_blackhits)+')<br>'+
'White List Hits  '+k64(add64(idomain_whitehits,ikeyword_whitehits)) +' (domain '+k64(idomain_whitehits)+' &nbsp keyword '+k64(ikeyword_whitehits)+')<br>'+
'Total Rejected   '+k64(ifailcount)+insstr(' '+ifailmsg+'  '+ifailurl,ifailcount>=1)+'<br>'+
'Total Accepted   '+k64(icrawlcache.accepthits)+'<br>'+
'Total Crawled    '+k64(icrawler_outhits)+'<br>'+
'Open Connections '+k64(icrawler_outlevel)+'<br>'+
'<br>'+
'Crawl State     '+v+

'</div>'+#10;
end;

function tsearch.info(n:string):string;
begin
if      (n='ver')                 then result:='1.00.1305'
else if (n='date')                then result:='16aug2024'
else if (n='name')                then result:='Search'
else if (n='rambytes')            then result:=intstr64( add64( add64(irambytes,icrawlcache.rambytes) ,icrawlpool.rambytes) )
else if (n='diskbytes')           then result:=intstr64( add64(idiskbytes,icrawlcache.diskbytes) )
else                                   result:='';
end;

function tsearch.statusinfo(i:longint;var n,v:string):boolean;
var
   bol1:boolean;
begin
bol1:=icrawler_havebandwidth;

case i of
0:begin
   n:='Search';
   v:=low__aorbstr('-',k64(iactive)+' / '+k64(ilimit)+' urls',bol1);
   result:=true;
   end;
1:begin
   n:='Crawl Requests';
   v:=low__aorbstr('-',k64(icrawler_outhits),bol1 and icrawler_theweb);
   result:=true;
   end;
2:begin
   n:='Open Connections';
   v:=low__aorbstr('-',k64(icrawler_outlevel),bol1 and icrawler_theweb);
   result:=true;
   end;
else result:=false;
end;//case
end;

function tsearch.toolbarcount:longint;
begin
result:=6;
end;

function tsearch.toolbaritem(i:longint;var s,n,t,h:string):boolean;
   procedure v(ss,nn,tt,hh:string);
   begin
   s:=ss;
   n:=pp(nn);
   t:=tt;
   h:=hh;
   result:=true;
   end;
begin
case i of
0:v('general','search'  ,'Search','Search Settings');
1:v('general','crawler' ,'Crawler','Crawler Settings');
2:v('general','addurls' ,'Add Urls','Add a list of urls to crawl');
3:v('general','addurl'  ,'Add Url','Url Submission Settings');
4:v('general','wl'      ,'White List','White List');
5:v('general','bl'      ,'Black List','Black List');
else result:=false;
end;//case
end;

procedure tsearch.regvals;
begin
//.search database - settings
rb('allow',false);
rb('check',true);
ri('size',100000,1,10000000);//1..10,000,000
ri('domainlimit' ,  50,1,1000000);
ri('domainlimit2',5000,1,1000000);

//.search results - settings
ri('results.domainlimit' ,3,0,5000);//search result domain limit - unlisted domain
ri('results.domainlimit2',50,0,5000);//search result domain limit - white list domain

//.crawler - settings
rb('crawler.theweb',true);
rb('crawler.harvest',true);
rb('crawler.keepfresh',true);
ri('crawler.rate',1,1,100);//1..100
ri('crawler.harvestlimit',50,0,30000);
ri('crawler.harvestlimit2',5000,0,30000);

//.addurl form messages
rb('addurl.spamguard',false);
rb('addurl.allow',false);
rs('addurl.off','');
rs('addurl.ok','');
rs('addurl.fail','');
end;

procedure tsearch.getvals;
begin
//.search database - settings
isearch_allow :=gb('allow');
isearch_size  :=gi('size');
isearch_check :=gb('check');
search__setdomainlimits(gi('domainlimit'),gi('domainlimit2'));

//.search results - settings
results__setdomainlimits(gi('results.domainlimit'),gi('results.domainlimit2'));

//.crawler - settings
icrawler_theweb   :=gb('crawler.theweb');
icrawler_keepfresh:=gb('crawler.keepfresh');
icrawler_rate0    :=gi('crawler.rate');
icrawler_harvest  :=gb('crawler.harvest');
crawler__setharvestlimits(gi('crawler.harvestlimit'),gi('crawler.harvestlimit2'));

//.addurl form
iaddurl_spamguard:=gb('addurl.spamguard');
iaddurl_allow    :=gb('addurl.allow');
iaddurl_off      :=gs('addurl.off');
iaddurl_ok       :=gs('addurl.ok');
iaddurl_fail     :=gs('addurl.fail');

//loaded
inherited getvals;

//sync
xsync;
end;

procedure tsearch.setvals;
begin
//.search database - settings
sb('allow',isearch_allow);
si('size',isearch_size);
sb('check',isearch_check);
si('domainlimit' ,isearch_domainlimit);
si('domainlimit2',isearch_domainlimit2);

//.search results - settings
si('results.domainlimit' ,iresults_domainlimit);
si('results.domainlimit2',iresults_domainlimit2);

//.crawler - settings
sb('crawler.theweb',icrawler_theweb);
sb('crawler.harvest',icrawler_harvest);
sb('crawler.keepfresh',icrawler_keepfresh);
si('crawler.rate',icrawler_rate0);
si('crawler.harvestlimit' ,icrawler_harvestlimit);
si('crawler.harvestlimit2',icrawler_harvestlimit2);

//.addurl form
sb('addurl.spamguard',iaddurl_spamguard);
sb('addurl.allow',iaddurl_allow);
ss('addurl.off',iaddurl_off);
ss('addurl.ok',iaddurl_ok);
ss('addurl.fail',iaddurl_fail);
end;

function tsearch.readvals(f,n:string;v:tfastvars):boolean;
var
   str1:string;

   function m(sname:string):boolean;
   begin
   result:=strmatch(sname,n);
   end;

   function b(sname:string):boolean;
   begin
   result:=v.checked[sname];
   end;

   function i(sname:string):longint;
   begin
   result:=app__ivalset(subname+'.'+sname,v.i[sname]);
   end;

   function s(sname:string):string;
   begin
   result:=v.s[sname];
   end;
begin
result:=false;

//.search database - settings
if m('search.settings') then
   begin
   isearch_allow :=b('allow');
   isearch_size  :=i('size');
   isearch_check :=b('check');
   search__setdomainlimits(i('domainlimit'),i('domainlimit2'));
   result:=true;
   end;

//.search results - settings
if m('search.results') then
   begin
   results__setdomainlimits(i('results.domainlimit'),i('results.domainlimit2'));
   result:=true;
   end;

//.crawler - settings
if m('crawler.settings') then
   begin
   icrawler_theweb   :=b('crawler.theweb');
   icrawler_keepfresh:=b('crawler.keepfresh');
   icrawler_rate0    :=i('crawler.rate');
   result:=true;
   end;

if m('crawler.harvest.settings') then
   begin
   icrawler_harvest  :=b('crawler.harvest');
   crawler__setharvestlimits(i('crawler.harvestlimit'),i('crawler.harvestlimit2'));
   result:=true;
   end;

if m('addurl.list') then
   begin
   crawler__addurls2(v.s['urllist'],str1,true,true);//mark as priority -> indexed without 12hr age restriction
   v.s['urllist.leftover']:=str1;
   end;

if m('addurl') then
   begin
   iaddurl_spamguard:=b('addurl.spamguard');
   iaddurl_allow    :=b('addurl.allow');
   iaddurl_off      :=s('addurl.off');
   iaddurl_ok       :=s('addurl.ok');
   iaddurl_fail     :=s('addurl.fail');
   result:=true;
   end;

//.black and white lists
if m('dwl.list') then idomain_whitelist.list:=s('list');//domain white list
if m('dbl.list') then idomain_blacklist.list:=s('list');//domain black list
if m('kwl.list') then ikeyword_whitelist.list:=s('list');//keyword white list
if m('kbl.list') then ikeyword_blacklist.list:=s('list');//keyword black list

//sync
if result then xsync;
end;

procedure tsearch.xsync;
begin
//search.size
setlimit(insint(isearch_size,isearch_allow));
//crawler.rate
crawler__setrate(insint(icrawler_rate0,isearch_allow));
end;

procedure tsearch.domain_whitehits_inc;
begin
low__roll64(idomain_whitehits,1);
end;

procedure tsearch.domain_blackhits_inc;
begin
low__roll64(idomain_blackhits,1);
end;

function tsearch.xfilename(xramlist:boolean):string;
begin
case xramlist of
true :result:=storagefilename('search-ram.db');
false:result:=storagefilename('search-disk.db');
end;
end;

procedure tsearch.search__setdomainlimits(v,v2:longint);
begin
isearch_domainlimit :=frcrange32(v,1,1000000);
isearch_domainlimit2:=frcrange32(v2,1,1000000);
end;

procedure tsearch.results__setdomainlimits(v,v2:longint);
begin
iresults_domainlimit :=frcrange32(v,0,5000);
iresults_domainlimit2:=frcrange32(v2,0,5000);
end;

//111111111111111111111111111111//xxxxxxxxxxxxxxx
function tsearch.search__pullUrl(var xurl:string):boolean;
var//rolls forward through database working back to the beginning -> repeating over and over
   d:tdiskrec;
   xlen,p,p2:longint;
begin
result:=false;
xurl:='';

//check
if (ilimit<=0) then exit;

//find -> limit to 10K scans
for p:=0 to frcmax32((ilimit-1),12000) do
begin

inc(isearch_pullpos);
if (isearch_pullpos<0) or (isearch_pullpos>=ilimit) then isearch_pullpos:=0;

//found in database and MUST BE 12hrs old or more since LAST index - 12aug2024
if (dlen.items[isearch_pullpos]>=1) and url__older_than_12hrs(uage.items[isearch_pullpos]) then
   begin
   //load
   if xloadrec(isearch_pullpos,nil,@d) then
      begin
      xlen:=ulen.items[isearch_pullpos];

      low__setlen(xurl,xlen);

      for p2:=1 to xlen do xurl[p2-1+stroffset]:=char(d.url[p2-1]);

      if (utyp.items[isearch_pullpos]=1) then xurl:='https://'+xurl else xurl:='http://'+xurl;

      //successful
      result:=true;
      end;

   //stop
   break;
   end;
end;//p
end;

//1111111111111111111111111111//xxxxxxxxxxxxxxxxxx

procedure tsearch.xage_backsync;
begin
local_age_back12hrs:=url__nowage2(-12);//minus 12hrs from current age
end;

procedure tsearch.xtimer;
label
   redocrawl,skipcrawl;
var
   xurl:string;
   int1,p:longint;
   bol1,xonce:boolean;
   c:comp;
begin
try
//check
if itimerbusy  then exit else itimerbusy:=true;


//get

//100ms
if msok(itimer100) then
   begin
   //bandwidth shutoff detection
   icrawler_havebandwidth:=not bubbles__daily_bandwidth_exceeded;

   //trickle transfer urls from icrawlpool to icrawlcache -> OK to discard url if urlcache is full -> max rate 500 urls/sec
   bol1:=true;
   for p:=1 to 50 do
   begin
   if not icrawlpool.pull(xurl,bol1) then
      begin
      bol1:=false;
      break;//stop if urlpool is low/empty
      end;
   icrawlcache.push(self,xurl,bol1);
   end;//p

   //.include crawler's bandwidth usage in the daily bandwidth count for Bubbles
   if crawler__havebandwidth(c,true) then bubbles__inc_daily_bandwidth(c);

   //reset
   msset(itimer100,low__aorb(500,100,bol1));//throttle back if urlpool is low/empty
   end;


//200ms
if msok(itimer200) then
   begin
   //auto throttle back if nothing deleted
   if isearch_check and search__check then int1:=100 else int1:=1000;

   //local_age_back12hrs ref var
   xage_backsync;

   //reset
   msset(itimer200,int1);
   end;


//crawl timer
if msok(itimercrawl) then
   begin
   //init
   icrawler_rateDELAY:=frcmin32(1000 div low__aorb(1,icrawler_rate,icrawler_rate>=1) ,1);

   //in sync with Bubbles daily bandwidth quota via "icrawler_havebandwidth" - 12aug2024
   if icrawler_theweb and icrawler_havebandwidth and (icrawler_rate>=1) then
      begin
      //all outbound connections are busy
      if not crawler__canpush then goto skipcrawl;

      //if POOL is too full and CACHE is not, then pause crawling to allow POOL to empty out into the CACHE
      if icrawlpool.halffull and (not icrawlcache.almostfull) then
         begin
         icrawler_rateDELAY:=1000;
         icrawler_state:=3;
         goto skipcrawl;
         end;

      //alternate between "Crawl Cache" and "Crawl Database"
      itimertoggle:=not itimertoggle;

      //decide
      if icrawler_keepfresh then int1:=low__aorb(0,1,itimertoggle) else int1:=0;

      //get
      xonce:=true;
      redocrawl:
      case int1 of
      0:begin
         if icrawlcache.pull(self,xurl) then
            begin
            icrawler_state:=1;
            crawler__pushUrl(xurl);//from cache
            end
         else
            begin
//            inc(bc1);
            //don't waste this task, instead switch over to database (1)
            if xonce and icrawler_keepfresh then
               begin
               xonce:=false;
               int1:=1;
               goto redocrawl;
               end;

            icrawler_state:=2;
            end;
         end;//begin
      1:begin
         if search__pullUrl(xurl) then
            begin
            icrawler_state:=1;
            crawler__pushUrl(xurl);//from database
            end
         else
            begin
//            inc(bc2);
            //don't waste this task, instead switch over to cache (0)
            if xonce then
               begin
               xonce:=false;
               int1:=0;
               goto redocrawl;
               end;

            icrawler_state:=2;
            end;
         end;//begin
      end;//case

      //stop -> not enough urls to go fast so idle back
      //if (bc1>=1) and (bc2>=1) then icrawler_rateDELAY:=500;//idle back
      end
   else icrawler_state:=0;//off

skipcrawl:
   //reset
   msset(itimercrawl,icrawler_rateDELAY);
   end;

except;end;
try
itimerbusy:=false;
except;end;
end;

procedure tsearch.crawler__setrate(x:longint);
begin
icrawler_rate:=frcrange32(x,0,100);
end;

procedure tsearch.setlimit(xnewsize:longint);
begin
xsetsize(xnewsize);
end;

procedure tsearch.xsetsize(xnewsize:longint);
label
   redo;
var
   xlastlimit,k,p:longint;
   bol1,xonce:boolean;
begin
//check
if (xnewsize=ilimit) then exit;

//init
xlastlimit     :=ilimit;
xonce          :=true;

redo:
//limit
xnewsize:=frcrange32(xnewsize,0,10000000);//0..10mil where 0=disabled (off)

//size
bol1:=true;
dlen.forcesize(xnewsize);
if bol1 and (dlen.size<>xnewsize) then bol1:=false;

dref.forcesize(xnewsize);
if bol1 and (dref.size<>xnewsize) then bol1:=false;

ulen.forcesize(xnewsize);
if bol1 and (ulen.size<>xnewsize) then bol1:=false;

uref.forcesize(xnewsize);
if bol1 and (uref.size<>xnewsize) then bol1:=false;

utyp.forcesize(xnewsize);
if bol1 and (utyp.size<>xnewsize) then bol1:=false;

uhel.forcesize(xnewsize);
if bol1 and (uhel.size<>xnewsize) then bol1:=false;

uage.forcesize(xnewsize);
if bol1 and (uage.size<>xnewsize) then bol1:=false;

drev.forcesize(xnewsize);
if bol1 and (drev.size<>xnewsize) then bol1:=false;

krev.forcesize(xnewsize);
if bol1 and (krev.size<>xnewsize) then bol1:=false;


for k:=0 to high(keys) do
begin
keys[k].forcesize(xnewsize);
if bol1 and (keys[k].size<>xnewsize) then bol1:=false;
end;

if xonce and (not bol1) then
   begin
   xonce:=false;
   xnewsize:=frcmax32(xnewsize,100000);//reduce to a safe level of 100K in case of memory shortage
   goto redo;
   end;

//set
ilimit:=xnewsize;

//init new records
if (xnewsize>xlastlimit) and (xnewsize>=1) then
   begin
   //clear new records
   for p:=frcmin32(xlastlimit,0) to (xnewsize-1) do dlen.items[p]:=0;

   //size files -> ensure file size covers all records -> new space is zeroed
   io__filesize_atleast(xfilename(true) ,mult64(xnewsize,irecsize));//ram list
   io__filesize_atleast(xfilename(false),mult64(xnewsize,irecsize2));//disk list

   //load from disk -> load RAM records into memory
   xreload2(xlastlimit,false);
   end
else syncinfo;
end;

function tsearch.xslotrange(xslot:longint):longint;
begin
if (xslot<0) then xslot:=0 else if (xslot>=ilimit) then xslot:=frcmin32(ilimit-1,0);
result:=xslot;
end;

procedure tsearch.xreload(xfromslot:longint);
begin
xreload2(xfromslot,true);
end;

procedure tsearch.xreload2(xfromslot:longint;xclear:boolean);
label
   skipend;
var
   a:tstr8;
   b:tramrec;
   xblockcount,acount,p:longint;
   df,e:string;
   xfilesize,xfrom,xsize:comp;
   xdate:tdatetime;
begin//Load ram list slots from disk
try
//defaults
a:=nil;
a:=str__new8;
df:=xfilename(true);
xblockcount:=10000;
xsize:=mult64(xblockcount,irecsize);//10K slots per read from disk

//check
if (ilimit<=0) then
   begin
   irambytes:=0;
   idiskbytes:=0;
   goto skipend;//disabled (off)
   end;

//range
xfromslot:=xslotrange(xfromslot);

//clear slots -> in case of io failure we have a predictable outcome
if xclear then
   begin
   for p:=xfromslot to (ilimit-1) do dlen.items[p]:=0;
   end;

//load slots
if io__fileexists(df) then
   begin
   xfrom:=xfromslot*irecsize;

   while true do
   begin
   if io__fromfile64b(df,@a,e,xfilesize,xfrom,xsize,xdate) then
      begin
      acount:=0;

      while true do
      begin
      if not str__writeto(@a,@b,irecsize,(acount*irecsize),irecsize) then break;

      if not rec2slot(xfromslot,@b) then break;

      inc(xfromslot);
      if (xfromslot>=ilimit) then break;

      inc(acount);
      if (acount>=xblockcount) then break;
      end;//loop

      if (xfrom>=xfilesize) or (xfromslot>=ilimit) then break;
      end
   else break;

   end;//loop
   end;

//syncinfo
syncinfo;

skipend:
except;end;
try
str__free(@a);
except;end;
end;

procedure tsearch.syncinfo;
var
   int1,p:longint;
   c:comp;
begin
//sync active
int1:=0;
for p:=0 to (ilimit-1) do if (dlen.items[p]<>0) then inc(int1);
iactive:=int1;

//url cache
icrawlcache.setlimit(insint(1000000,ilimit>=1));

//disk bytes
c:=add64( mult64(ilimit,irecsize) , mult64(ilimit,irecsize2));
c:=add64(c,icrawlcache.diskbytes);
idiskbytes:=c;

//ram bytes
c:=0;
c:=add64(c,dlen.size*dlen.bpi);
c:=add64(c,dref.size*dref.bpi);

c:=add64(c,ulen.size*ulen.bpi);
c:=add64(c,uref.size*uref.bpi);

c:=add64(c,utyp.size*utyp.bpi);
c:=add64(c,uhel.size*uhel.bpi);

c:=add64(c,uage.size*uage.bpi);

c:=add64(c,drev.size*drev.bpi);

c:=add64(c,krev.size*krev.bpi);

for p:=0 to high(keys) do c:=add64(c,keys[p].size*keys[p].bpi);

c:=add64(c,icrawlcache.rambytes);

irambytes:=c;
end;

//111111111111111111111111111111111//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

function tsearch.xmakekeys(xtext:string;kout:pkeys;koutlist:pkeys2):boolean;
var//kout and koutlist are both optional
   k:array[0..high(tkeys)] of string;
   kcount,lp,p:longint;
   c:byte;
   v:string;

   function vhave:boolean;
   var
      p:longint;
   begin
   result:=false;
   if (kcount>=1) then
      begin
      for p:=0 to (kcount-1) do if strmatch(k[p],v) then
         begin
         result:=true;
         break;
         end;
      end;
   end;
begin
result:=false;
//check
if (xtext='') then exit;

//enforce trailing separator charc
xtext:=xtext+#32;

//kinit
for p:=0 to high(k) do
begin
if (kout<>nil) then kout[p]:=0;
k[p]:='';
if (koutlist<>nil) then koutlist[p]:='';
end;//p
kcount:=0;
lp:=1;

for p:=1 to low__length(xtext) do
begin
c:=byte(xtext[p-1+stroffset]);
if keyword__sep(c) then
   begin
   //enforce minimum and maximum keyword lengths and check for repeats
   if keyword__filter( strcopy1(xtext,lp,p-lp) ,false,v) and (not vhave) then
      begin
      //set
      k[kcount]:=v;
      if (kout<>nil)     then kout[kcount]:=keyword__makeref(v);
      if (koutlist<>nil) then koutlist[kcount]:=v;
      //inc
      inc(kcount);
      if (kcount>high(k)) then break;
      end;
   lp:=p+1;
   end;
end;

//successful
result:=(kcount>=1);
end;

procedure tsearch.crawler__setharvestlimits(v,v2:longint);
begin
icrawler_harvestlimit :=frcrange32(v ,0,30000);
icrawler_harvestlimit2:=frcrange32(v2,0,30000);
end;

function tsearch.crawler__canaddurls:boolean;
begin
result:=icrawlpool.canpush;
end;

function tsearch.crawler__addurls(xlistOfUrls:string;xPriorityAddURL:boolean):boolean;
var
   str1:string;
begin
result:=crawler__addurls2(xlistOfUrls,str1,xPriorityAddURL,false);
end;

function tsearch.crawler__addurls2(xlistOfUrls:string;var xrejectedURLS:string;xPriorityAddURL,xreturnRejectedUrls:boolean):boolean;
var//mark as priority -> Add URL -> indexed regardless of age etc - 12aug2024
   b:tstr8;
   xlen,xpos:longint;
   xline:string;
   xonce:boolean;
begin
result:=false;
xonce:=true;
b:=nil;
xrejectedURLS:='';

//check
if (xlistofurls='') then exit;

//init
xlen:=low__length(xlistofurls);

//get
try

xpos:=1;
while true do
begin
case low__nextline1(xlistofurls,xline,xlen,xpos) of
true :begin
   if icrawlpool.push(xline,xPriorityAddURL) then result:=true
   else
      begin
      if xonce then
         begin
         xonce:=false;
         failed(xline,'Crawl pool is full',0);
         end;

      if xreturnRejectedUrls then
         begin
         if (b=nil) then b:=str__new8;
         str__saddb(@b,xline+#10);
         end
      else break;//dump the rest and quit
      end;
   end;//begin
false:break;
end;//case
end;//loop

//return rejectedURLS
if (b<>nil) then xrejectedURLS:=str__text(@b);
except;end;

//free
if (b<>nil) then str__free(@b);
end;

function tsearch.crawler__canpush:boolean;
begin
result:=(icrawler_outlevel<icrawler_rate);
end;

function tsearch.crawler__pushUrl(xurl:string):boolean;
begin
if (xurl<>'') then
   begin
   low__roll64(icrawler_outhits,1);
   inc(icrawler_outlevel);//thread count
   tgeturl.create(xurl,xonurl);
   result:=true;
   end
else result:=false;
end;

procedure tsearch.failed(xurl,xmsg:string;utyp:byte);
begin
ifailmsg:=xmsg;
ifailurl:=low__aorbstr('http://','https://',utyp=1)+xurl;
low__roll64(ifailcount,1);
end;

procedure tsearch.good(xurl,xtit,xdes:string;xnew:boolean;utyp:byte);
begin
igoodnew:=xnew;
igoodtit:=xtit;
igooddes:=xdes;
igoodurl:=low__aorbstr('http://','https://',utyp=1)+xurl;
low__roll64(igoodcount,1);
end;

function tsearch.search__pushpage(xurl,xpagecode:string):boolean;
label//Note: if xurl is a front page -> a domain with a trailing "/" or "/index.html" or /index.htm" then harvest links from page text, ELSE just index the page and DO NOT harvest any links
   skipend;
var
   dlen,xharvestlimit,llen,p:longint;
   dref:comp;
   xdomain,str1,ilastm,l,xh1,xtit,xdes:string;
   xurl_isfrontpage,xwhitelisted_domain:boolean;
   drev,utyp:byte;
   c:char;

   function m(x:string):boolean;
   begin
   ilastm:=x;
   result:=strmatch(strcopy1(l,p,low__length(x)),x);
   end;

   function et(x:string):string;
   var
      mlen,xlen,i:longint;
   begin
   result:='';
   mlen:=low__length(ilastm);
   xlen:=low__length(x);

   for i:=(p+mlen) to llen do
   begin
   if (i<=llen) and (l[i-1+stroffset]=x[stroffset]) and strmatch(strcopy1(l,i,xlen),x) then
      begin
      result:=strcopy1(xpagecode,p+mlen,i-(p+mlen));
      break;
      end;
   end;//i
   end;

   function fsv(n:string;var v:string):boolean;//find sub-value -> e.g. "<meta name='description' content='a description'>" where sub values are "name" and 'description' and "content" and 'a description'
   var//only set "xdes" if we find a non-nil value
      mlen,nlen,i:longint;
      dn,dv:string;
      sc,c:char;
      xequal,xwithin:boolean;

      function xsep(c:char):boolean;
      begin
      result:=(not xwithin) and ( (c=#32) or (c='=') or (c=#9) or (c=#10) or (c=#13) or (c='>') );
      end;
   begin
   result:=false;
   v:='';

   //check
   if (n='') then exit;
   n:=strlow(n);
   nlen:=low__length(n);
   mlen:=low__length(ilastm);
   xwithin:=false;
   xequal:=false;
   dn:='';
   dv:='';
   sc:=#0;

   //find
   for i:=(p+mlen) to llen do
   begin
   c:=l[i-1+stroffset];

   if (not xwithin) and ((c=#34) or (c=#39)) and (sc<>c) then sc:=c;

   if (c=sc) and (sc<>#0) then xwithin:=not xwithin;

   if (not xwithin) and (c='=') then
      begin
      xequal:=not xequal;
      sc:=#0;
      end;

   case xsep(c) of
   true:begin
      if (dn<>'') and (dv<>'') then
         begin
         if strmatch(dn,n) then
            begin
            result:=true;
            v:=dv;
            break;
            end;

         dn:='';
         dv:='';
         sc:=#0;
         xequal:=false;
         end;
      end;
   false:begin
      if (sc=#0) or (c<>sc) then
         begin
         case xequal of
         true :dv:=dv+xpagecode[i-1+stroffset];
         false:dn:=dn+c;
         end;//case
         end;
      end;
   end;//case

   if (c='>') then break;
   end;//i
   end;
begin
result:=false;
xharvestlimit:=0;
drev:=0;

try
//check
if (xurl='') then
   begin
   if ishowadd then
      begin
      scn__writeln('u: url is empty');
      scn__writeln('');
      end;

   failed(xurl,'Url is empty',0);
   goto skipend;
   end;

//domain info
if url__split2(xurl,utyp,xurl_isfrontpage,xdomain,xurl,true,true) then
   begin
   //list suport
   dlen:=low__length(xdomain);
   dref:=url__makeref(xdomain);

   //check domain against "black listed domains" list
   if idomain_blacklist.have(dlen,dref) then
      begin
      low__roll64(idomain_blackhits,1);
      failed(xurl,'Url banned by domain black list',utyp);
      goto skipend;
      end;

   //domain relevancy
   xwhitelisted_domain:=idomain_whitelist.have(dlen,dref);
   drev:=low__aorb(0,1,xwhitelisted_domain);

   //harvest limit
   if xurl_isfrontpage then xharvestlimit:=low__aorb(icrawler_harvestlimit,icrawler_harvestlimit2,xwhitelisted_domain)
   else                     xharvestlimit:=0;

   end
else
   begin
   if ishowadd then
      begin
      scn__writeln('u: url does not have a domain name');
      scn__writeln('');
      end;

   failed(xurl,'Url does not have a domain name',utyp);
   goto skipend;
   end;


if (xpagecode='') then
   begin
   if ishowadd then
      begin
      scn__writeln('u: '+xurl);
      scn__writeln('c: no page text');
      scn__writeln('');
      end;

   failed(xurl,'Page as no content',utyp);
   low__roll64(ifailcount,1);
   goto skipend;
   end;

//extract information from page text
xtit:='';
xdes:='';
xh1:='';
l:=strlow(xpagecode);
llen:=low__length(l);
ilastm:='';

for p:=1 to llen do
begin
c:=l[p-1+stroffset];
if (c='<') then
   begin
   if      m('<title>') then xtit:=et('</')
   else if m('<h1>')    then xh1:=et('</')
   else if m('<meta ')  and fsv('name',str1) and strmatch(str1,'description') and fsv('content',str1) and (str1<>'') then xdes:=str1;
   end;
end;//p

//set
xtit:=strdefb(xtit,xh1);
result:=search__pushclean(xdomain,xurl,xtit,xdes,utyp,drev);//successful or not

//harvest links ONLY if added to search database
if result and icrawler_harvest and (xharvestlimit>=1) then
   begin


   end;

skipend:
except;end;
end;

function tsearch.search__pushclean(xdomain,xurl,xtitle,xdes:string;utyp,ddrev:byte):boolean;
label//Note: expects inbound values to already be cleaned ready for processing
   skipend;
var
   r:tramrec;
   d:tdiskrec;
   p,p2:longint;
   k:tkeys2;
   str1:string;
begin
result:=false;

try
//check
if (xurl='') then
   begin
   failed(xurl,'Empty url',utyp);
   goto skipend;
   end;
if (low__length(xurl)>sizeof(turl)) then
   begin
   failed(xurl,'Url too big',utyp);
   goto skipend;
   end;
if (xtitle='') and (xdes='') then
   begin
   failed(xurl,'Page has no title or description',utyp);
   goto skipend;
   end;

//filter
xtitle  :=low__filter(xtitle,false);
xdes    :=low__filter(xdes,false);

//check 2
if (xdomain='') then
   begin
   failed(xurl,'Bad domain name',utyp);
   goto skipend;
   end;
if (xurl='') then
   begin
   failed(xurl,'Bad url',utyp);
   goto skipend;
   end;
if (xtitle='') and (xdes='') then
   begin
   failed(xurl,'Page has no title or description',utyp);
   goto skipend;
   end;

//.write url
low__cls(@d.url,sizeof(d.url));
for p:=1 to low__length(xurl) do d.url[p-1]:=byte(xurl[p-1+stroffset]);

//.title
low__cls(@d.tit,sizeof(d.tit));
for p:=1 to frcmax32(low__length(xtitle),sizeof(d.tit)) do d.tit[p-1]:=byte(xtitle[p-1+stroffset]);

//.des
low__cls(@d.des,sizeof(d.des));
for p:=1 to frcmax32(low__length(xdes),sizeof(d.des)) do d.des[p-1]:=byte(xdes[p-1+stroffset]);

//.keywords
for p:=0 to high(k) do
begin
k[p]:='';
r.keys[p]:=0;
low__cls(@d.keys[p],sizeof(d.keys[0]));
end;

if not xmakekeys(xdes+#32+xtitle,@r.keys,@k) then
   begin
   if ishowadd then
      begin
      scn__writeln('u: '+xurl);
      scn__writeln('t: '+xtitle);
      scn__writeln('d: '+xdes);
      scn__writeln('k: no usable keywords found in description and title'+xdes);
      scn__writeln('');
      end;

   failed(xurl,'No usable keywords found in description and title',utyp);
   goto skipend;
   end;

//.check keywords against Black and White keyword lists
r.krev:=0;
for p:=0 to high(k) do if (r.keys[p]<>0) then
   begin
   if ikeyword_blacklist.have(r.keys[p]) then//black list -> stop and discard
      begin
      if ishowadd then
         begin
         scn__writeln('u: '+xurl);
         scn__writeln('t: '+xtitle);
         scn__writeln('d: '+xdes);
         scn__writeln('k: keyword in black list "'+k[p]+'"');
         scn__writeln('');
         end;

      failed(xurl,'Page has a black listed keyword "'+k[p]+'"',utyp);
      low__roll64(ikeyword_blackhits,1);
      goto skipend;
      end
   else if ikeyword_whitelist.have(r.keys[p]) then inc(r.krev);//white list -> increment relevancy counter
   end;

if (r.krev>=1) then low__roll64(ikeyword_whitehits,1);


//.keywords have already been length checked -> safe to read as is
for p:=0 to high(k) do if (k[p]<>'') then
   begin
   for p2:=1 to low__length(k[p]) do d.keys[p][p2-1]:=byte(k[p][p2-1+stroffset]);
   end;

//.other vars
r.dlen:=low__length(xdomain);
r.dref:=url__makeref(xdomain);

r.ulen:=low__length(xurl);
r.uref:=url__makeref(xurl);

r.utyp:=utyp;

r.uhel:=ihel_def;
r.uage:=url__nowage;

r.drev:=ddrev;

if not xfindslot(r.dlen,r.ulen,r.dref,r.uref,true) then
   begin
   failed(xurl,'No space in database',utyp);
   goto skipend;
   end;

//set
if not rec2slot(ilastslot,@r) then goto skipend;

//save
if not xsaverec(ilastslot,@r,@d) then goto skipend;

//show
if ishowadd then
   begin
   scn__writeln('u: '+xurl);
   scn__writeln('t: '+xtitle);
   scn__writeln('d: '+xdes);

   str1:='';
   for p:=0 to high(k) do if (k[p]<>'') then str1:=str1+insstr(', ',str1<>'')+k[p];
   scn__writeln('k: '+str1);

   scn__writeln('r: slot('+k64(ilastslot)+') '+low__aorbstr('Update','New Entry',ilastnew));
   scn__writeln('');
   end;

good(xurl,xtitle,xdes,ilastnew,r.utyp);

//successful
result:=true;
skipend:
except;end;
end;

function tsearch.xfindslot(sdlen,sulen:longint;sdref,suref:comp;xnewslot:boolean):boolean;
var
   dlimit,dcount,inew,iold,ihav,p:longint;
   dage,xage:comp;
   sdref8,suref8:tcmp8;
   ulen1:pdlbyte;
   uref8:pdlcomp2;
   dlen1:pdlbyte;
   dref8:pdlcomp2;
   uage8:pdlcomp;
begin
result:=false;
ilastslot:=-1;
ilastnew:=false;

//check
if (sulen=0) or (suref=0) or (ilimit<=0) then exit;

//find slot
if not result then
   begin
   dage:=max64;
   xage:=max64;
   inew:=-1;
   iold:=-1;
   ihav:=-1;

   sdref8.val:=sdref;
   suref8.val:=suref;
   dlen1:=dlen.core;
   dref8:=dref.core;
   ulen1:=ulen.core;
   uref8:=uref.core;
   uage8:=uage.core;

   dcount:=0;//count number of times the domain is listed in core
   dlimit:=frcmin32(low__aorb(isearch_domainlimit,isearch_domainlimit2, idomain_whitelist.have(sdlen,sdref) ),1);



   for p:=0 to (ilimit-1) do
   begin
   //find domain -> domain.len1 and domain.ref8(4+4)
   if (dlen1[p]=sdlen) and (dref8[p].ints[0]=sdref8.ints[0]) and (dref8[p].ints[1]=sdref8.ints[1]) then
      begin
      inc(dcount);

      //find url -> url.len1 and url.ref8(4+4)
      if (ulen1[p]=sulen) and (uref8[p].ints[0]=suref8.ints[0]) and (uref8[p].ints[1]=suref8.ints[1]) then
         begin
         ilastslot:=p;
         result:=true;
         break;
         end
      //.oldest slot agmonst same domain
      else if (dcount<=dlimit) and (uage8[p]<dage) then
         begin
         ihav:=p;
         dage:=uage8[p];
         end;
      end
   //.find new
   else if (dlen1[p]=0) then
      begin
      if (inew=-1) then inew:=p;
      end
   //.find oldest
   else if (uage8[p]<xage) then
      begin
      iold:=p;
      xage:=uage8[p];
      end;
   end;//p

   //new or old
   if (not result) and xnewslot then
      begin
      //create new slot for url/domain as it occurs less frequently in core than the max. limit allowed
      if (inew>=0) and (dcount<dlimit) then
         begin
         inc(iactive);//increment active count
         ilastnew:=true;
         ilastslot:=inew;
         result:=true;
         end
      //reuse an existing slot used by one of the domain's urls
      else if (ihav>=0) then
         begin
         ilastslot:=ihav;
         result:=true;
         //scn__writeln(k64(ilastslot)+'>>'+k64(dage)+'<<'+k64(xnowage));//xxxxxxxx
         end
      //reuse any old slot for the url
      else if (iold>=0) then
         begin
         ilastnew:=true;
         ilastslot:=iold;
         result:=true;
         end;
      end;
   end;
end;

function tsearch.active:longint;//number of slots (urls) in database
begin
result:=frcrange32(iactive,0,ilimit);
end;

function tsearch.xfindurl(sulen:longint;suref:comp):boolean;
var
   p:longint;
begin
result:=false;

//check
if (sulen=0) or (suref=0) or (ilimit<=0) then exit;

//find slot
for p:=(ilimit-1) downto 0 do
begin
if (ulen.items[p]=sulen) and (uref.items[p]=suref) then
   begin
   result:=true;
   break;
   end;
end;//p
end;

function tsearch.xfind(k:pkeys;xout:pobject):boolean;
label
//xxxxxxxxxxxxxxxxxxxx need more results and a -1/-2/-3 keyword match lists xxxxxxxxxxxxxxxxxxxx
   finish,skipend;
var
   rcount,kcount,p,p2,p3:longint;
   bol1,rmatch:boolean;
   rslot:array[0..99] of longint;
   rage:array[0..99] of comp;
   dlen1:pdlbyte;
   uhel1:pdlbyte;

   procedure radd(xslot:longint;xage:comp);
   var
      p,p2:longint;
      bol1:boolean;
   begin
   if (rcount>=1) then
      begin
      bol1:=false;

      for p:=0 to (rcount-1) do
      begin
      if (xage>rage[p]) then
         begin
         //shift down (oldest=larger slot, youngest=smaller slot)
         for p2:=(rcount-1) downto p do
         begin
         if (p2<high(rslot)) then
            begin
            rslot[p2+1]:=rslot[p2];
            rage[p2+1] :=rage[p2];
            end;
         end;//p2
         //insert
         rslot[p]:=xslot;
         rage[p] :=xage;
         bol1:=true;
         //inc
         if (rcount<=high(rslot)) then inc(rcount);
         //stop
         break;
         end;
      end;//p

      if (not bol1) and (rcount<=high(rslot)) then
         begin
         rslot[rcount]:=xslot;
         rage[rcount]:=xage;
         inc(rcount);
         end;
      end
   else
      begin
      rslot[rcount]:=xslot;
      rage[rcount] :=xage;
      inc(rcount);
      end;
   end;
begin
result:=false;
rcount:=0;

try
//check
if not str__lock(xout) then goto skipend;
if (k=nil)             then goto skipend;
if (ilimit<=0)         then goto skipend;

//check keys
kcount:=0;
for p:=0 to high(tkeys) do if (k[p]<>0) then kcount:=p+1 else break;
if (kcount<=0) then goto finish;

//init
dlen1:=dlen.core;
uhel1:=uhel.core;

//find slot
for p:=0 to (ilimit-1) do
begin
if (dlen1[p]<>0) and (uhel1[p]>=1) then//must have health "uhel1" of 1..255, 0=>bad slot=>hide from results BUT keep in database
   begin
   rmatch:=true;

   for p2:=0 to (kcount-1) do
   begin
   bol1:=false;

   for p3:=0 to high(tkeys) do if (k[p2]=keys[p3].items[p]) then
      begin
      bol1:=true;
      break;
      end;

   if not bol1 then
      begin
      rmatch:=false;
      break;
      end;
   end;//p2

   //matched
//   if rmatch then scn__writeln('matched.slot('+k64(p)+')');// else scn__writeln('No match>>'+k64(kcount));//xxxxxxxxxxxxxxxxx

   if rmatch then radd(p,uage.items[p]);
   end;
end;//p


finish:
if (rcount<=0) then
   begin
   str__settextb(xout,'No results found');
   end
else
   begin
   str__settextb(xout,k64(rcount)+' matches found');
//debug:   for p:=0 to (rcount-1) do str__saddb(xout,rcode+'r'+k64(p)+'='+inttostr(rslot[p])+' age('+k64(rage[p])+')');
   end;

//extract html template from a template page and use to insert results...
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx


//successful
result:=true;
skipend:
except;end;
end;

function tsearch.slot2rec(x:longint;r:pramrec):boolean;
var
   p:longint;
begin
result:=false;

//check
if (ilimit<=0) or (x<0) or (x>=ilimit) or (r=nil) then exit;

//get
r.dlen:=dlen.items[x];
r.dref:=dref.items[x];
r.ulen:=ulen.items[x];
r.uref:=uref.items[x];
r.utyp:=utyp.items[x];
r.uage:=uage.items[x];
r.uhel:=uhel.items[x];
r.drev:=drev.items[x];
r.krev:=krev.items[x];
for p:=0 to high(keys) do r.keys[p]:=keys[p].items[x];

//successful
result:=true;
end;

function tsearch.rec2slot(x:longint;r:pramrec):boolean;
var
   p:longint;
begin
result:=false;

//check
if (ilimit<=0) or (x<0) or (x>=ilimit) or (r=nil) then exit;

//get
dlen.items[x]:=frcrange32(r.dlen,0,sizeof(turl));//strictly enforce length
dref.items[x]:=r.dref;
ulen.items[x]:=frcrange32(r.ulen,0,sizeof(turl));//strictly enforce length
uref.items[x]:=r.uref;
utyp.items[x]:=r.utyp;
uage.items[x]:=r.uage;
uhel.items[x]:=r.uhel;
drev.items[x]:=frcrange32(r.drev,0,1);
krev.items[x]:=frcrange32(r.krev,0,high(tkeys)+1);//0..10
for p:=0 to high(keys) do keys[p].items[x]:=r.keys[p];

//successful
result:=true;
end;

function tsearch.delslot(x:longint):boolean;
var
   r:tramrec;
begin
result:=false;

//check
if (ilimit<=0) or (x<0) or (x>=ilimit) then exit;

//get
if slot2rec(x,@r) then
   begin
   iactive:=frcmin32(iactive-1,0);
   r.dlen:=0;
   result:=rec2slot(x,@r) and xsaverec(x,@r,nil);
   end;
end;

function tsearch.saveslot(x:longint):boolean;
var
   r:tramrec;
begin
result:=false;

//check
if (ilimit<=0) or (x<0) or (x>=ilimit) then exit;

//get
result:=slot2rec(x,@r) and xsaverec(x,@r,nil);
end;

function tsearch.search__check:boolean;
label//max work load = 10 keywords x 60,000 keywords (white+black list) = 600,000 + 20,000 domains (black+white list) = 620,000 checks PER slot in search database
   skipend;
var
   i,p:longint;
   ddrev,kkrev:byte;
   xmustdel:boolean;
begin
result:=false;

//check
if (ilimit<=0)  or (not isearch_check) then exit;

//find next slot in use within 100K slots of us
for p:=0 to frcmin32(frcmax32(ilimit-10,100000),0) do//-10=allows for gui display of check pos to be moving
begin
inc(isearch_checkpos);
if (isearch_checkpos<0) or (isearch_checkpos>=ilimit) then isearch_checkpos:=0;

if (dlen.items[isearch_checkpos]>=1) then
   begin

   //delete check -> black list ------------------------------------------------
   xmustdel:=false;

   //domain check
   if (not xmustdel) and (idomain_blacklist.active>=1) and idomain_blacklist.have(dlen.items[isearch_checkpos],dref.items[isearch_checkpos]) then xmustdel:=true;

   //keyword check
   if (not xmustdel) and (ikeyword_blacklist.active>=1) then
      begin
      for i:=0 to high(tkeys) do if ikeyword_blacklist.have( keys[i].items[isearch_checkpos] ) then
         begin
         xmustdel:=true;
         goto skipend;
         end;
      end;

   //delete
   if xmustdel then
      begin
      delslot(isearch_checkpos);
      low__roll64(isearch_checkdelcount,1);
      result:=true;//tell host we modified a slot
      goto skipend;
      end;


   //upgrade check -> white list -----------------------------------------------
   ddrev:=0;
   kkrev:=0;

   //domain check
   if (idomain_whitelist.active>=1) and idomain_whitelist.have(dlen.items[isearch_checkpos],dref.items[isearch_checkpos]) then ddrev:=1;

   //keyword check
   if (ikeyword_whitelist.active>=1) then
      begin
      for i:=0 to high(tkeys) do if ikeyword_whitelist.have( keys[i].items[isearch_checkpos] ) then inc(kkrev);
      end;

   //modify
   if (ddrev<>drev.items[isearch_checkpos]) or (kkrev<>krev.items[isearch_checkpos]) then
      begin
      drev.items[isearch_checkpos]:=ddrev;
      krev.items[isearch_checkpos]:=kkrev;
      saveslot(isearch_checkpos);

      low__roll64(isearch_checkmodcount,1);
      result:=true;//tell host we modified a slot
      goto skipend;
      end;
   end;//if
end;//p

skipend:
end;

function tsearch.find:boolean;//xxxxxxxxxxxxxxxxx testing only so far..............
var
   k:tkeys;
   k2:tkeys2;
   a:tobject;
begin
result:=false;

a:=nil;
a:=str__new8;

xmakekeys('my nice',@k,@k2);
xfind(@k,@a);
scn__writeln(str__text(@a));//xxxxxxxxxxxx

//scn__writeln(k2[0]+'('+k64(k[0])+')__'+k2[1]+'('+k64(k[1])+')<<'+str__text(@a));//xxxxxxxxxxxx
str__free(@a);
end;

function tsearch.xsaverec(xslot:longint;r:pramrec;d:pdiskrec):boolean;
label
   skipend;
var
   a:tstr8;
   df,e:string;
   ds:comp;
begin//Load ram list slots from disk
//defaults
result:=false;
a:=nil;

//check
if (xslot<0) or (xslot>=ilimit) or (ilimit<=0) then exit;

try
//init
a:=str__new8;

//ramlist
if (r<>nil) then
   begin
   df :=xfilename(true);
   ds :=mult64(xslot,irecsize);
   str__clear(@a);
   str__addrec(@a,r,irecsize);
//was:   if (not io__filesize_atleast(df,add64(ds,irecsize))) or (not io__tofileex64(df,@a,ds,false,e)) then goto skipend;

   //write RAM slot to disk -> file should already be correctly sized
   if not io__tofileex64(df,@a,ds,false,e) then goto skipend;
   end;

//disklist
if (d<>nil) then
   begin
   df:=xfilename(false);
   ds:=mult64(xslot,irecsize2);
   str__clear(@a);
   str__addrec(@a,d,irecsize2);
//was:   if (not io__filesize_atleast(df,add64(ds,irecsize2))) or (not io__tofileex64(df,@a,ds,false,e)) then goto skipend;//11aug2024: fixed "irecsize2"

   //write DISK slot to disk -> file should already be correctly sized
   if not io__tofileex64(df,@a,ds,false,e) then goto skipend;
   end;

//successful
result:=true;
skipend:
except;end;
try
str__free(@a);
except;end;
end;

function tsearch.xloadrec(xslot:longint;r:pramrec;d:pdiskrec):boolean;
label
   skipend;
var
   a:tstr8;
   e:string;
   xfilesize:comp;
   xdate:tdatetime;
begin
//defaults
result:=false;
a:=nil;

//check
if (xslot<0) or (xslot>=ilimit) or (ilimit<=0) then exit;

try
//init
a:=str__new8;

//ramlist
if (r<>nil) then
   begin
   if ( (not io__fromfile64d(xfilename(true),@a,false,e,xfilesize,mult64(xslot,irecsize),irecsize,xdate)) or (not str__writeto(@a,r,irecsize,0,irecsize)) ) then goto skipend;
   //range check in case of data corruption
   r.dlen:=frcrange32(r.dlen,0,sizeof(turl));
   r.ulen:=frcrange32(r.ulen,0,sizeof(turl));
   end;

//disklist
if (d<>nil) and ( (not io__fromfile64d(xfilename(false),@a,false,e,xfilesize,mult64(xslot,irecsize2),irecsize2,xdate)) or (not str__writeto(@a,d,irecsize2,0,irecsize2)) ) then goto skipend;

//successful
result:=true;
skipend:
except;end;
try
str__free(@a);
except;end;
end;

procedure tsearch.xonurl(sender:tobject);
var
   xin,xout:comp;
begin
if (sender is tgeturl) then
   begin
   //approximate bandwidth consumption -> e.g. 5K per outbound request AND 5K + text.length per inbound response => 10K + text.length total
   xin:=add64(5000,low__lengthb((sender as tgeturl).text));
   xout:=5000;

   net__inccounters(xin,xout);

   //.for Bubbles daily bandwidth tracking and auto shutoff
   iusedbandwidth:=add64(iusedbandwidth,xin);
   iusedbandwidth:=add64(iusedbandwidth,xout);

   //shrinl the number of active download threads by 1
   icrawler_outlevel:=frcmin32(icrawler_outlevel-1,0);

   //submit page text to search database pre-processor
   search__pushpage((sender as tgeturl).url,(sender as tgeturl).text);
   end;
end;

function tsearch.crawler__havebandwidth(var xbytes:comp;xreset:boolean):boolean;
begin
result:=(iusedbandwidth>=1);
if result then
   begin
   xbytes:=iusedbandwidth;
   if xreset then iusedbandwidth:=0;
   end;
end;


//turlcache --------------------------------------------------------------------
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//2222222222222222222222
constructor turlcache.create(xstoragefolder:string);
begin
inherited create;

istoragefolder :=xstoragefolder;
ipullpos       :=-1;
ipushpos       :=-1;
iaccepthits    :=0;
irambytes      :=0;
idiskbytes     :=0;
ilimit         :=-1;
iactive        :=0;
ulen           :=new__byte;
uref           :=new__comp;

dlen           :=new__byte;
dref           :=new__comp;

irecsize       :=ulen.bpi+dlen.bpi+uref.bpi+dref.bpi;
irecsize2      :=sizeof(tudiskrec);

//defaults - off
xsetsize(0);
end;

destructor turlcache.destroy;
begin
try
inherited destroy;
//core
freeobj(@ulen);
freeobj(@uref);

freeobj(@dlen);
freeobj(@dref);
except;end;
end;

function turlcache.storagefolder:string;
begin
result:=istoragefolder;
end;

function turlcache.almostfull:boolean;
begin
result:=((iactive+5000)>=ilimit);
end;

function turlcache.active:longint;
begin
result:=frcrange32(iactive,0,ilimit);
end;

function turlcache.xloadrec(xslot:longint;d:pudiskrec):boolean;
label
   skipend;
var
   a:tstr8;
   e:string;
   xfilesize:comp;
   xdate:tdatetime;
begin
//defaults
result:=false;
a:=nil;

//check
if (xslot<0) or (xslot>=ilimit) or (ilimit<=0) then exit;

try
//init
a:=str__new8;

//disklist
if (d<>nil) then
   begin
   if ( (not io__fromfile64d(xfilename,@a,false,e,xfilesize,mult64(xslot,irecsize2),irecsize2,xdate)) or (not str__writeto(@a,d,irecsize2,0,irecsize2)) ) then goto skipend;
   //range check in case of data corruption
   d.ulen:=frcrange32(d.ulen,0,sizeof(turl));
   end;
//successful
result:=true;
skipend:
except;end;
try
str__free(@a);
except;end;
end;

function turlcache.xsaverec(xslot:longint;d:pudiskrec):boolean;
label
   skipend;
var
   a:tstr8;
   df,e:string;
   ds:comp;
begin//Load ram list slots from disk
//defaults
result:=false;
a:=nil;

//check
if (xslot<0) or (xslot>=ilimit) or (ilimit<=0) then exit;

try
//init
a:=str__new8;

//disklist
if (d<>nil) then
   begin
   df:=xfilename;
   ds:=mult64(xslot,irecsize2);
   str__clear(@a);
   str__addrec(@a,d,irecsize2);
//was:   if (not io__filesize_atleast(df,add64(ds,irecsize2))) or (not io__tofileex64(df,@a,ds,false,e)) then goto skipend;

   //write DISK slot to disk -> file should already be correctly sized
   if not io__tofileex64(df,@a,ds,false,e) then goto skipend;
   end;

//successful
result:=true;
skipend:
except;end;
try
str__free(@a);
except;end;
end;

function turlcache.canpush:boolean;
begin
result:=(ilimit>=1) and (iactive<ilimit);
end;

function turlcache.push(xsearch:tsearch;xurl:string;xPriorityAddURL:boolean):boolean;
label//rolls forward through cache working back to the beginning -> repeating over and over
   skipend;
var
   a:tudiskrec;
   v1,v2,p:longint;
   xsrc:byte;
   len1:pdlbyte;
   ref8:pdlbilongint;
   xdomain:string;
begin
result:=false;

//range
xsrc:=low__aorb(0,1,xPriorityAddURL);//source 0=crawler -> crawl url if not in db, or if db.url is 12hrs+ old, 1=add url -> crawl regardless of age so it can be updated ASAP

//check
if (ilimit<=0) then exit;
if (xurl='') then
   begin
   if (xsearch<>nil) then xsearch.failed(xurl,'Empty url',0);
   exit;
   end;

//url
if not url__split(xurl,a.utyp,xdomain,xurl) then
   begin
   if (xsearch<>nil) then xsearch.failed(xurl,'Bad url detected',a.utyp);
   exit;
   end;

//init
len1:=ulen.core;
ref8:=uref.core;

a.dlen:=low__length(xdomain);
a.dref:=url__makeref(xdomain);
a.usrc:=xsrc;

//check domain against black list
if (xsearch<>nil) then
   begin
   //domain black listed
   if xsearch.domain_blacklist.have(a.dlen,a.dref) then
      begin
      xsearch.failed(xurl,'Domain is black listed',0);
      xsearch.domain_blackhits_inc;
      goto skipend;
      end;

   //domain white listed
   if xsearch.domain_whitelist.have(a.dlen,a.dref) then
      begin
      xsearch.domain_whitehits_inc;
      end;

   //general inc
   low__roll64(iaccepthits,1);
   end;

//.url info
a.ulen:=low__length(xurl);
a.uref:=url__makeref(xurl);

low__cls(@a.url,sizeof(a.url));
for p:=1 to a.ulen do a.url[p-1]:=byte(xurl[p-1+stroffset]);

//find existing -> found -> url is already in the crawl cache -> disregard the request
v1:=tcmp8(a.uref).ints[0];
v2:=tcmp8(a.uref).ints[1];
for p:=0 to (ilimit-1) do if (a.ulen=len1[p]) and (v1=ref8[p][0]) and (v2=ref8[p][1]) then
   begin
   xsearch.failed(xurl,'Url already in cache',a.utyp);
   goto skipend;
   end;

//find
for p:=0 to (ilimit-1) do
begin

inc(ipushpos);
if (ipushpos<0) or (ipushpos>=ilimit) then ipushpos:=0;

if (len1[ipushpos]=0) then
   begin
   //save slot
   xsaverec(ipushpos,@a);

   ulen.items[ipushpos]:=a.ulen;
   uref.items[ipushpos]:=a.uref;

   dlen.items[ipushpos]:=a.dlen;
   dref.items[ipushpos]:=a.dref;

   //inc
   iactive:=frcmax32(iactive+1,ilimit);

   //successful
   result:=true;
   break;
   end;
end;//p

skipend:
end;

function turlcache.canpull:boolean;
begin
result:=(ilimit>=1) and (iactive>=1);
end;

function turlcache.pull(xsearch:tsearch;var xurl:string):boolean;
var//rolls forward through cache working back to the beginning -> repeating over and over
   a:tudiskrec;
   p,p2:longint;
   utyp1,dlen1,ulen1:byte;
   dref8,uref8:comp;
   ddomain,durl:string;
begin
result:=false;
xurl:='';

//check
if (ilimit<=0) or (xsearch=nil) then exit;

//find -> limit to 10K scans
for p:=0 to frcmax32((ilimit-1),12000) do
begin

inc(ipullpos);
if (ipullpos<0) or (ipullpos>=ilimit) then ipullpos:=0;

if (ulen.items[ipullpos]>=1) then
   begin
   //load
   if xloadrec(ipullpos,@a) and (a.ulen>=1) then
      begin
      low__setlen(xurl,a.ulen);
      for p2:=1 to a.ulen do xurl[p2-1+stroffset]:=char(a.url[p2-1]);

      if (a.utyp=1) then xurl:='https://'+xurl else xurl:='http://'+xurl;

      //priority check
      //.url is a priority Add URL and can be indexed immediately without any further checks
      if (a.usrc=1) then result:=true

      //.url is NOT a priority Add URL and must be checked against search database: (a) does not exist or (b) is 12hrs+ old since last index ==> OK to index it again
      else
         begin
         //works with fully qualified url
         if url__split(xurl,utyp1,ddomain,durl) then
            begin

            dlen1:=low__length(ddomain);
            dref8:=url__makeref(ddomain);
            ulen1:=low__length(durl);
            uref8:=url__makeref(durl);

            case xsearch.xfindslot(dlen1,ulen1,dref8,uref8,false) of
            false:result:=true;//not found in database ==> OK to index it
            true :if url__older_than_12hrs(xsearch.uage.items[xsearch.lastslot]) then result:=true;//found in database and MUST BE 12hrs old or more since LAST index - 12aug2024
            end;//case

            end;//if
         end;//if
      end;

   //delete entry regarless of load state or outcome -> slots that are too young (been indexed less than 12hr prior are removed, freeing up crawl cache) - 12aug2024
   a.ulen:=0;
   xsaverec(ipullpos,@a);

   //delete from RAM too
   ulen.items[ipullpos]:=0;

   //dec
   iactive:=frcmin32(iactive-1,0);

   //stop
   break;
   end;
end;//p
end;

function turlcache.xfilename:string;
begin
result:=storagefolder+'cache-disk.db';
end;

procedure turlcache.setlimit(xnewsize:longint);
begin
xsetsize(xnewsize);
end;

procedure turlcache.xsetsize(xnewsize:longint);
label
   redo;
var
   xlastlimit,p:longint;
   bol1,xonce:boolean;
begin
xlastlimit     :=ilimit;
xonce          :=true;

redo:
//limit
xnewsize:=frcrange32(xnewsize,0,1000000);//0..1mil where 0=disabled (off)

//size
bol1:=true;

ulen.forcesize(xnewsize);
if bol1 and (ulen.size<>xnewsize) then bol1:=false;

dlen.forcesize(xnewsize);
if bol1 and (dlen.size<>xnewsize) then bol1:=false;

uref.forcesize(xnewsize);
if bol1 and (uref.size<>xnewsize) then bol1:=false;

dref.forcesize(xnewsize);
if bol1 and (dref.size<>xnewsize) then bol1:=false;

if xonce and (not bol1) then
   begin
   xonce:=false;
   xnewsize:=frcmax32(xnewsize,50000);//reduce to a safe level of 50K in case of memory shortage
   goto redo;
   end;

//set
ilimit:=xnewsize;

//init new records
if (xnewsize>xlastlimit) and (xnewsize>=1) then
   begin
   //clear new slots
   for p:=frcmin32(xlastlimit,0) to (xnewsize-1) do ulen.items[p]:=0;

   //size file -> ensure file size cover all slots -> new space is zeroed
   io__filesize_atleast(xfilename ,mult64(xnewsize,irecsize2));//url list

   //load RAM slots from disk
   xreload2(xlastlimit,false);
   end
else syncinfo;
end;

function turlcache.xslotrange(xslot:longint):longint;
begin
if (xslot<0) then xslot:=0 else if (xslot>=ilimit) then xslot:=frcmin32(ilimit-1,0);
result:=xslot;
end;

procedure turlcache.xreload(xfromslot:longint);
begin
xreload2(xfromslot,true);
end;

procedure turlcache.xreload2(xfromslot:longint;xclear:boolean);
label
   skipend;
var
   a:tstr8;
   b:tudiskrec;
   xblockcount,acount,p:longint;
   df,e:string;
   xfilesize,xfrom,xsize:comp;
   xdate:tdatetime;
begin//Load ram list slots from disk
try
//defaults
a:=nil;
a:=str__new8;
df:=xfilename;
xblockcount:=10000;
xsize:=mult64(xblockcount,irecsize2);//10K slots per read

//check
if (ilimit<=0) then
   begin
   irambytes:=0;
   idiskbytes:=0;
   goto skipend;//disabled (off)
   end;

//range
xfromslot:=xslotrange(xfromslot);

//clear slots -> in case of io failure we have a predictable outcome
if xclear then
   begin
   for p:=xfromslot to (ilimit-1) do ulen.items[p]:=0;
   end;

//load slots
if io__fileexists(df) then
   begin
   xfrom:=xfromslot*irecsize2;

   while true do
   begin
   if io__fromfile64b(df,@a,e,xfilesize,xfrom,xsize,xdate) then
      begin
      acount:=0;

      while true do
      begin
      if not str__writeto(@a,@b,irecsize2,(acount*irecsize2),irecsize2) then break;

      ulen.items[xfromslot]:=b.ulen;
      uref.items[xfromslot]:=b.uref;

      inc(xfromslot);
      if (xfromslot>=ilimit) then break;

      inc(acount);
      if (acount>=xblockcount) then break;
      end;//loop

      if (xfrom>=xfilesize) or (xfromslot>=ilimit) then break;
      end
   else break;

   end;//loop
   end;

//syncinfo
syncinfo;

skipend:
except;end;
try
str__free(@a);
except;end;
end;

procedure turlcache.syncinfo;
var
   int1,p:longint;
begin
//sync active
int1:=0;
for p:=0 to (ilimit-1) do if (ulen.items[p]<>0) then inc(int1);
iactive:=int1;

//bytes
irambytes:=mult64(ilimit,irecsize);
idiskbytes:=mult64(ilimit,irecsize2);
end;


//tgeturl ----------------------------------------------------------------------
constructor tgeturl.create(xurl:string;xondone:tnotifyevent);
begin
iurl:=xurl;
itext:='';
onterminate:=xondone;
freeonterminate:=true;
inherited create(false);//execute immediately
end;

procedure tgeturl.execute;
var
  a:tstrings;
begin
a:=nil;

try
{$ifdef laz}
a:=tstringlist.create;
if HttpGetText(iurl,a) then
   begin
   itext:=a.text;
   if (itext='') then itext:=#32;
   end;
{$endif}

{$ifdef d3}
//debug only:
win____sleep(2500);
itext:='<html><title>Sample Page</title><meta name="description" content="My site meta-description">';//xxxxxxxxxxxxxxxxx
{$endif}
except;end;
try;if (a<>nil) then freeobj(@a);except;end;
end;


//turlpool ---------------------------------------------------------------------
constructor turlpool.create;
var
   p:longint;
begin
inherited create;

ilimit         :=50000;//50,000 slots
iactive        :=0;
ipushpos       :=-1;
ipullpos       :=-1;
islotsize      :=8+sizeof(turl);//protocol + url -> turl does not store protocol hence our extra 8b
isrc           :=new__byte;
ilen           :=new__word;
icore          :=str__new8;

isrc.forcesize(ilimit);
ilen.forcesize(ilimit);
for p:=0 to (ilimit-1) do ilen.items[p]:=0;

icore.setlen(ilimit*islotsize);
end;

destructor turlpool.destroy;
begin
try
inherited destroy;
//core
freeobj(@isrc);
freeobj(@ilen);
freeobj(@icore);
except;end;
end;

function turlpool.almostfull:boolean;
begin
result:=((iactive+1000)>=ilimit);
end;

function turlpool.halffull:boolean;
begin
result:=(iactive>=frcmin32(ilimit div 2,1));
end;

function turlpool.rambytes:longint;
begin
result:=icore.len + (isrc.bpi*isrc.size) + (ilen.bpi*ilen.size);
end;

function turlpool.canpush:boolean;
begin
result:=(iactive<ilimit);
end;

function turlpool.push(xurl:string;xPriorityAddURL:boolean):boolean;
var
   xlen,i,ap,p:longint;
   a:pdlbyte;
begin
result:=false;

//check
if not canpush                   then exit;//no capacity left -> ignore

xlen:=low__length(xurl);
if (xlen<=0) or (xlen>islotsize) then exit;//too small or too big -> ignore

//find free slot
for p:=0 to (ilimit-1) do
begin

inc(ipushpos);
if (ipushpos<0) or (ipushpos>=ilimit) then ipushpos:=0;

if (ilen.items[ipushpos]=0) then
   begin
   //mark slot as taken
   ilen.items[ipushpos]:=xlen;
   inc(iactive);

   //mark as priority
   isrc.items[ipushpos]:=low__aorb(0,1,xPriorityAddURL);

   //write url to slot
   a:=icore.core;
   ap:=ipushpos*islotsize;

   for i:=1 to xlen do
   begin
   a[ap]:=byte(xurl[i-1+stroffset]);
   inc(ap);
   end;//i

   //successful
   result:=true;
   break;
   end;//if

end;//p
end;

function turlpool.canpull:boolean;
begin
result:=(iactive>=1);
end;

function turlpool.pull(var xurl:string;var xPriorityAddURL:boolean):boolean;
var
   xlen,i,ap,p:longint;
   a:pdlbyte;
begin
result:=false;
xurl:='';
xPriorityAddURL:=false;

//check
if not canpull then exit;//we have no slots in use -> ignore

//find a used slot
for p:=0 to (ilimit-1) do
begin

inc(ipullpos);
if (ipullpos<0) or (ipullpos>=ilimit) then ipullpos:=0;

if (ilen.items[ipullpos]>=1) then
   begin
   //mark slot as free
   xlen:=ilen.items[ipullpos];
   ilen.items[ipullpos]:=0;
   iactive:=frcmin32(iactive-1,0);

   //read priority
   xPriorityAddURL:=(isrc.items[ipushpos]=1);

   //read url from slot
   a:=icore.core;
   ap:=ipullpos*islotsize;

   low__setlen(xurl,xlen);//size buffer in preparation for filling

   for i:=1 to xlen do
   begin
   byte(xurl[i-1+stroffset]):=a[ap];
   inc(ap);
   end;//i

   //successful
   result:=true;
   break;
   end;//if

end;//p
end;


//tdomainlist ------------------------------------------------------------------
constructor tdomainlist.create;
begin
inherited create;

ilimit         :=10000;
iactive        :=0;

ilist          :=str__new9;
ilen           :=new__byte;
iref           :=new__comp;

//size
ilen.forcesize(ilimit);
iref.forcesize(ilimit);
end;

destructor tdomainlist.destroy;
begin
try
inherited destroy;
//core
freeobj(@ilist);
freeobj(@ilen);
freeobj(@iref);
except;end;
end;

procedure tdomainlist.clear;
begin
iactive:=0;
str__clear(@ilist);
end;

function tdomainlist.have(xlen:longint;xref:comp):boolean;
var
   len1:pdlbyte;
   ref8:pdlbilongint;
   p,v0,v1:longint;
begin
result:=false;

//check
if (xlen<=0) or (xref=0) then exit;

//init
len1:=ilen.core;
ref8:=iref.core;

v0:=tcmp8(xref).ints[0];
v1:=tcmp8(xref).ints[1];

//find
for p:=0 to (iactive-1) do if (xlen=len1[p]) and (v0=ref8[p][0]) and (v1=ref8[p][1]) then
   begin
   result:=true;
   break;
   end;
end;

procedure tdomainlist.setlist(xlist:string);
label
   skipend;
var
   dref:comp;
   xlen,xpos:longint;
   dlen,utyp:byte;
   ddomain,uurl,xline:string;
   bol1:boolean;
begin
try
//init
xlen:=low__length(xlist);

//clear list
clear;

//check
if (xlen<=0) then goto skipend;

//get
xpos:=1;

while low__nextline1(xlist,xline,xlen,xpos) do
begin

if url__split2(xline,utyp,bol1,ddomain,uurl,false,false) then
   begin
   dlen:=low__length(ddomain);
   dref:=url__makeref(ddomain);

   if not have(dlen,dref) then//detect duplicates -> include only one instance of domain
      begin
      ilen.items[iactive]:=dlen;
      iref.items[iactive]:=dref;

      str__saddb(@ilist,ddomain+#10);

      //inc
      inc(iactive);
      if (iactive>=ilimit) then break;
      end;
   end;

end;//loop

skipend:
//save
save;
except;end;
end;

function tdomainlist.getlist:string;
begin
result:=str__text(@ilist);
end;

function tdomainlist.save:boolean;
var
   e:string;
begin
result:=(ifilename<>'') and io__tofile(ifilename,@ilist,e);
end;

function tdomainlist.load:boolean;
var
   e:string;
   b:tobject;
begin
result:=false;
b:=nil;

//check
if (ifilename='') then exit;

try
//clear
clear;

//init
b:=str__newsametype(@ilist);

//get
if io__fromfile(ifilename,@b,e) then setlist(str__text(@b));
except;end;
try;str__free(@b);except;end;
end;


//tkeywordlist -----------------------------------------------------------------
constructor tkeywordlist.create;
begin
inherited create;

ilimit         :=30000;
iactive        :=0;

ilist          :=str__new9;
iref           :=new__comp;

//size
iref.forcesize(ilimit);
end;

destructor tkeywordlist.destroy;
begin
try
inherited destroy;
//core
freeobj(@ilist);
freeobj(@iref);
except;end;
end;

procedure tkeywordlist.clear;
begin
iactive:=0;
str__clear(@ilist);
end;

function tkeywordlist.have(xref:comp):boolean;
var
   ref8:pdlbilongint;
   p,v0,v1:longint;
begin
result:=false;

//check
if (xref=0) then exit;

//init
ref8:=iref.core;

v0:=tcmp8(xref).ints[0];
v1:=tcmp8(xref).ints[1];

//find
for p:=0 to (iactive-1) do if (v0=ref8[p][0]) and (v1=ref8[p][1]) then
   begin
   result:=true;
   break;
   end;
end;

procedure tkeywordlist.setlist(xlist:string);
label
   skipend;
var
   xref:comp;
   xlen,xpos:longint;
   xline:string;
begin
try
//init
xlen:=low__length(xlist);

//clear list
clear;

//check
if (xlen<=0) then goto skipend;

//get
xpos:=1;

while low__nextline1(xlist,xline,xlen,xpos) do
begin

if (xline<>'') and keyword__filter(xline,true,xline) then
   begin
   xref:=keyword__makeref(xline);

   if not have(xref) then//detect duplicates -> include only one instance of domain
      begin
      iref.items[iactive]:=xref;

      str__saddb(@ilist,xline+#10);

      //inc
      inc(iactive);
      if (iactive>=ilimit) then break;
      end;
   end;

end;//loop

skipend:
//save
save;
except;end;
end;

function tkeywordlist.getlist:string;
begin
result:=str__text(@ilist);
end;

function tkeywordlist.save:boolean;
var
   e:string;
begin
result:=(ifilename<>'') and io__tofile(ifilename,@ilist,e);
end;

function tkeywordlist.load:boolean;
var
   e:string;
   b:tobject;
begin
result:=false;
b:=nil;

//check
if (ifilename='') then exit;

try
//clear
clear;

//init
b:=str__newsametype(@ilist);

//get
if io__fromfile(ifilename,@b,e) then setlist(str__text(@b));
except;end;
try;str__free(@b);except;end;
end;


//ticonmaker -------------------------------------------------------------------
constructor ticonmaker.create;
begin
inherited create;
imodname:='iconmaker';
regvals;

//check we have what we need to run the graphics for this module
need_bmp;
need_jpg;
need_gif;
need_ico;
need_tga;
need_png;

//vars
iinboundimagesizelimit:=2048;//max width/height e.g. 2048 x 2048
end;

procedure ticonmaker.run;
label
   redo;
begin
//check
if not xrunstart then exit;

//get
iallow               :=false;
itimerbusy           :=false;
iuploadlimit         :=0;
irambytes            :=0;
idiskbytes           :=0;
itimer100            :=0;
itimer200            :=0;
igif32               :='';

//defaults
xloadsupport;

//done -> we are now running and "getvals" has been fired - 18aug2024
xrundone(true);
end;

procedure ticonmaker.xloadsupport;
const
   //uncompressed (not zipped)
   xgif32x32:array[0..277] of byte=(71,73,70,56,57,97,32,0,32,0,176,0,0,255,255,255,224,224,224,33,255,11,78,69,84,83,67,65,80,69,50,46,48,3,1,0,0,0,33,249,4,8,33,0,0,0,44,0,0,0,0,32,0,32,0,0,8,98,0,1,4,16,72,112,160,193,130,8,15,42,20,184,176,97,194,135,11,33,74,116,216,144,226,196,139,3,49,106,172,184,177,99,70,139,32,39,134,28,249,208,163,71,146,40,9,154,68,153,50,229,202,141,45,59,190,28,25,147,228,76,140,53,53,222,4,153,51,228,78,145,63,29,6,133,216,243,226,80,142,69,133,38,37,122,20,97,83,133,75,149,62,101,56,117,96,64,0,33,249,4,8,33,0,0,0,44,0,0,0,0,32,0,32,0,0,8,98,0,3,0,16,72,112,160,193,130,8,15,42,20,184,176,97,194,135,11,33,74,116,216,144,226,196,139,3,49,106,172,184,177,99,70,139,32,39,134,28,249,208,163,71,146,40,9,154,68,153,50,229,202,141,45,59,190,28,25,147,228,76,140,53,53,222,4,153,51,228,78,145,63,29,6,133,216,243,226,80,142,69,133,38,37,122,20,97,83,133,75,149,62,101,56,117,96,64,0,0,59);
var
   a:tstr8;
begin
//defaults
a:=nil;

try
//gif32 -> base64 embed ready data string
a:=str__new8;
str__addrec(@a,@xgif32x32,sizeof(xgif32x32));
str__tob64(@a,@a,0);
igif32:='data:image/gif;base64,'+str__text(@a);


except;end;

str__free(@a);
end;

destructor ticonmaker.destroy;
begin
try
inherited destroy;

//object was not started -> core vars not set so don't destroy them
if not irunning then exit;
except;end;
end;

function ticonmaker.listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean;
begin
result:=true;
ximgdata:='';
xtitle:='Icon Maker';
xdescription:='Create an icon from an image using your browser.';
xrootpage:=pp('iconmaker.html');
xonline:=iallow;
xjobcount:=inherited jobcount;
xrambytes:=irambytes;
xdiskbytes:=idiskbytes;
end;

function ticonmaker.xdefaultico32(xdata:pobject):boolean;
const
   xico:array[0..4285] of byte=(
0,0,1,0,1,0,32,32,0,0,0,0,32,0,168,16,0,0,22,0,0,0,40,0,0,0,32,0,0,0,64,0,0,0,1,0,32,0,0,0,0,0,128,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,50,137,81,255,79,153,93,255,115,181,122,255,91,169,108,255,98,168,105,255,117,171,104,255,112,166,106,255,64,132,73,255,45,133,67,255,30,102,49,255,71,132,74,255,135,167,110,255,174,197,145,255,115,178,122,255,46,160,100,255,56,167,113,255,35,87,47,255,14,99,49,255,25,122,65,255,26,129,71,255,72,155,100,255,89,167,113,255,76,151,97,255,56,151,94,255,23,93,56,255,28,121,70,255,27,103,62,255,11,75,39,255,12,84,41,255,16,99,54,255,22,62,34,255,48,159,105,255,3,80,36,255,38,129,73,255,79,157,96,255,84,169,107,255,83,157,93,255,130,176,117,255,153,185,128,255,41,119,58,255,77,141,82,255,27,99,46,255,91,146,89,255,137,177,119,255,165,186,131,255,164,190,137,255,160,202,147,255,38,93,46,255,36,116,69,255,29,126,69,255,28,125,68,255,52,147,90,255,37,139,81,255,28,136,77,255,60,154,97,255,41,138,82,255,40,111,71,255,30,103,63,255,6,89,44,255,8,89,44,
255,15,98,53,255,17,84,47,255,28,140,93,255,61,175,115,255,4,68,32,255,7,74,37,255,40,114,56,255,69,150,87,255,48,130,65,255,120,166,107,255,153,182,126,255,93,144,84,255,89,144,87,255,41,105,59,255,107,155,96,255,128,168,110,255,112,169,108,255,171,194,142,255,181,204,152,255,102,151,105,255,47,112,67,255,56,153,96,255,49,146,89,255,37,140,82,255,23,133,74,255,26,136,77,255,20,128,75,255,29,118,68,255,17,113,66,255,8,47,25,255,7,57,27,255,27,79,39,255,48,118,71,255,27,115,75,255,7,58,24,255,37,142,93,255,38,151,94,255,4,55,27,255,101,151,97,255,101,158,97,255,106,156,98,255,46,120,56,255,82,136,77,255,131,166,109,255,38,104,53,255,79,125,78,255,129,169,111,255,116,160,101,255,172,196,142,255,173,196,144,255,159,195,141,255,144,192,140,255,40,74,43,255,69,120,82,255,48,134,80,255,40,133,78,255,36,115,64,255,18,93,49,255,22,101,52,255,4,112,60,255,12,46,29,255,5,37,20,255,17,45,25,255,20,76,41,255,7,83,42,255,2,97,46,255,17,141,87,255,9,75,34,255,116,195,132,255,0,51,23,255,96,
148,88,255,109,155,96,255,77,134,73,255,98,150,90,255,52,118,66,255,110,152,97,255,48,120,68,255,119,154,97,255,117,157,99,255,169,195,142,255,177,196,141,255,161,186,130,255,170,204,150,255,151,200,150,255,46,83,51,255,43,80,48,255,19,73,38,255,22,83,47,255,16,88,35,255,38,77,129,255,29,40,178,255,30,46,169,255,3,32,29,255,10,35,21,255,8,40,21,255,13,74,40,255,0,91,44,255,3,107,54,255,8,141,78,255,14,106,55,255,137,199,147,255,3,73,36,255,62,119,64,255,104,145,88,255,96,144,85,255,81,135,75,255,94,141,85,255,39,107,48,255,36,35,253,255,41,29,255,255,30,26,255,255,40,37,247,255,137,171,130,255,141,180,154,255,81,90,218,255,41,55,235,255,40,50,192,255,23,63,105,255,13,59,46,255,14,60,68,255,21,11,157,255,19,16,169,255,26,16,190,255,26,17,198,255,38,28,212,255,15,29,77,255,16,43,39,255,13,55,30,255,21,101,58,255,7,130,74,255,9,140,83,255,16,91,47,255,166,211,155,255,33,143,84,255,39,92,48,255,71,122,65,255,85,136,79,255,67,128,70,255,68,132,72,255,42,33,243,255,42,27,255,255,36,
27,254,255,37,28,255,255,36,27,254,255,32,22,236,255,27,21,240,255,30,23,244,255,24,17,238,255,19,14,230,255,19,14,230,255,19,20,224,255,16,15,171,255,21,14,159,255,20,15,174,255,24,15,185,255,25,19,192,255,27,22,207,255,37,23,219,255,33,28,227,255,37,54,133,255,14,34,15,255,8,44,27,255,38,87,43,255,49,94,51,255,189,223,176,255,90,187,130,255,29,83,48,255,71,113,66,255,91,133,78,255,76,131,74,255,36,32,228,255,40,27,249,255,42,29,251,255,32,25,246,255,38,29,255,255,37,34,243,255,20,20,240,255,22,19,249,255,25,21,254,255,28,19,230,255,23,16,221,255,25,17,212,255,23,20,230,255,25,18,223,255,19,14,159,255,18,15,168,255,20,15,174,255,23,16,180,255,22,13,183,255,29,24,209,255,31,23,218,255,42,34,229,255,81,153,83,255,81,133,85,255,27,71,32,255,34,81,48,255,204,227,182,255,148,207,156,255,18,81,39,255,46,96,54,255,56,115,64,255,50,116,64,255,28,23,209,255,36,24,230,255,40,31,242,255,42,28,253,255,38,25,247,255,24,19,242,255,17,15,241,255,20,18,244,255,19,19,251,255,36,22,247,255,52,
43,253,255,44,35,245,255,23,14,225,255,25,19,222,255,21,12,163,255,20,17,170,255,20,15,174,255,22,16,181,255,22,15,190,255,28,19,199,255,26,20,209,255,24,17,208,255,29,30,198,255,104,165,97,255,89,159,96,255,20,69,31,255,207,219,169,255,197,216,161,255,10,92,40,255,44,92,50,255,64,117,67,255,56,107,79,255,31,17,213,255,34,24,225,255,37,25,231,255,36,29,250,255,37,28,255,255,21,16,239,255,17,15,241,255,24,23,246,255,47,39,246,255,43,36,255,255,29,29,249,255,47,40,255,255,43,38,254,255,56,43,255,255,22,14,161,255,24,14,168,255,19,16,169,255,23,16,181,255,23,14,184,255,22,15,190,255,21,16,199,255,25,18,209,255,27,22,207,255,153,188,131,255,123,171,112,255,77,145,86,255,176,204,151,255,143,191,132,255,38,154,89,255,24,87,47,255,56,115,65,255,59,124,85,255,31,16,191,255,34,24,244,255,30,23,252,255,41,33,255,255,41,34,255,255,20,17,246,255,20,18,244,255,25,21,246,255,32,30,255,255,35,35,255,255,41,39,253,255,49,39,255,255,47,38,255,255,45,41,254,255,48,43,255,255,47,36,236,255,15,16,
166,255,17,14,167,255,20,15,174,255,25,18,183,255,25,19,192,255,27,18,198,255,24,21,201,255,141,176,119,255,114,165,103,255,55,120,65,255,201,218,167,255,188,205,154,255,99,193,129,255,17,83,41,255,52,118,66,255,77,142,86,255,30,25,241,255,32,27,243,255,36,31,247,255,38,29,255,255,38,29,255,255,23,21,247,255,20,18,244,255,23,18,233,255,27,20,241,255,35,31,255,255,50,41,251,255,47,36,252,255,51,35,253,255,51,40,255,255,57,53,255,255,45,47,255,255,54,37,234,255,23,20,173,255,23,18,177,255,23,18,177,255,19,14,177,255,25,18,193,255,27,20,195,255,134,174,116,255,84,150,91,255,59,101,53,255,148,207,149,255,128,198,138,255,123,191,132,255,111,172,114,255,77,136,85,255,40,44,227,255,36,22,248,255,31,24,245,255,29,25,244,255,33,26,247,255,36,27,254,255,43,36,255,255,45,36,255,255,44,29,251,255,28,21,226,255,44,29,221,255,41,26,218,255,34,24,208,255,42,29,221,255,47,32,244,255,39,31,248,255,19,15,248,255,24,15,249,255,33,22,172,255,22,19,172,255,20,17,170,255,20,16,172,255,20,17,180,255,
22,20,180,255,41,130,74,255,68,144,90,255,68,140,80,255,145,209,150,255,120,197,136,255,71,145,81,255,147,192,136,255,138,185,117,255,37,33,229,255,45,34,220,255,33,26,247,255,31,24,245,255,31,24,245,255,33,26,247,255,38,31,252,255,56,44,250,255,53,36,241,255,80,63,230,255,38,23,211,255,80,63,220,255,30,21,191,255,30,25,164,255,33,18,180,255,40,30,230,255,32,30,255,255,34,22,252,255,18,15,178,255,18,16,165,255,18,19,159,255,20,20,158,255,20,18,168,255,97,172,104,255,98,179,124,255,39,126,70,255,61,144,82,255,154,209,152,255,107,196,133,255,101,171,108,255,129,196,141,255,109,136,210,255,36,31,246,255,23,23,243,255,32,25,246,255,29,24,240,255,27,22,238,255,29,24,240,255,39,28,245,255,52,36,238,255,72,48,242,255,89,66,242,255,50,46,118,255,37,34,80,255,55,31,167,255,28,25,140,255,34,24,168,255,48,28,187,255,64,38,238,255,65,41,255,255,67,50,255,255,35,21,233,255,23,16,207,255,21,40,177,255,43,120,53,255,36,108,61,255,75,160,110,255,114,190,136,255,32,110,56,255,91,188,124,255,125,
202,141,255,158,206,147,255,170,221,164,255,55,46,255,255,38,29,255,255,29,27,253,255,28,21,242,255,26,21,237,255,26,21,237,255,23,18,234,255,27,22,238,255,38,29,239,255,50,37,243,255,68,46,141,255,85,62,77,255,52,43,56,255,52,53,73,255,36,36,48,255,48,36,166,255,43,27,175,255,54,34,217,255,72,50,255,255,74,58,255,255,65,57,252,255,67,56,255,255,39,28,232,255,27,17,218,255,15,27,185,255,56,158,100,255,30,124,67,255,91,178,128,255,66,144,83,255,159,199,141,255,175,207,150,255,168,209,158,255,32,30,220,255,30,25,255,255,27,25,251,255,28,21,242,255,23,18,234,255,23,18,234,255,26,21,237,255,23,18,234,255,22,17,233,255,46,37,248,255,102,87,91,255,71,63,64,255,110,94,88,255,65,48,51,255,66,56,69,255,20,26,55,255,16,9,136,255,49,32,197,255,61,41,254,255,72,58,253,255,71,64,255,255,69,61,255,255,58,50,255,255,48,36,242,255,28,21,226,255,20,12,227,255,54,139,89,255,90,167,106,255,25,109,51,255,46,130,66,255,151,198,135,255,136,193,178,255,36,33,243,255,60,55,255,255,32,30,255,255,22,21,
245,255,23,18,233,255,21,18,228,255,21,17,230,255,34,30,255,255,43,32,255,255,117,83,160,255,108,86,104,255,29,21,22,255,15,15,29,255,183,167,168,255,101,84,93,255,65,55,97,255,44,45,149,255,140,96,233,255,57,37,220,255,41,38,255,255,94,91,255,255,77,69,253,255,61,55,255,255,51,42,252,255,30,23,220,255,33,24,234,255,27,36,229,255,72,157,95,255,149,208,157,255,149,217,164,255,20,89,46,255,68,94,148,255,35,34,238,255,41,36,252,255,44,39,255,255,34,25,252,255,28,25,255,255,27,25,251,255,30,28,254,255,28,26,252,255,34,25,252,255,39,38,232,255,113,95,88,255,17,5,41,255,63,44,63,255,24,21,30,255,115,91,85,255,59,51,82,255,146,113,241,255,27,20,195,255,91,63,236,255,84,62,251,255,50,47,255,255,94,91,255,255,67,62,255,255,47,38,255,255,29,21,216,255,28,17,233,255,31,27,240,255,76,157,110,255,164,217,167,255,180,227,178,255,86,175,119,255,33,85,48,255,44,39,255,255,42,37,253,255,38,31,252,255,29,27,253,255,38,29,255,255,32,30,255,255,30,28,254,255,30,28,254,255,28,27,253,255,63,50,255,
255,123,115,146,255,46,21,35,255,29,18,34,255,13,5,16,255,110,100,106,255,75,58,125,255,156,120,255,255,122,92,251,255,29,19,220,255,39,31,238,255,39,33,252,255,36,38,253,255,58,55,255,255,49,38,255,255,29,21,216,255,32,22,223,255,33,26,231,255,116,191,139,255,150,212,160,255,176,225,175,255,147,222,168,255,39,94,45,255,44,56,222,255,41,36,252,255,41,34,255,255,43,36,255,255,41,34,255,255,35,33,255,255,31,29,255,255,27,23,255,255,43,38,254,255,38,28,255,255,88,66,249,255,75,59,244,255,139,124,138,255,133,109,141,255,124,112,134,255,81,61,250,255,143,111,255,255,159,133,255,255,69,61,252,255,26,17,228,255,47,38,255,255,19,14,223,255,41,37,255,255,55,44,254,255,27,19,196,255,27,18,215,255,40,30,244,255,112,192,125,255,108,186,122,255,113,195,130,255,155,221,169,255,48,127,76,255,80,150,97,255,40,35,250,255,37,32,248,255,42,37,253,255,41,34,255,255,32,30,255,255,32,30,255,255,32,32,252,255,36,27,254,255,38,29,255,255,42,33,254,255,43,38,253,255,76,70,255,255,121,94,255,255,114,92,
255,255,20,25,248,255,100,80,253,255,136,109,255,255,84,79,255,255,22,14,239,255,26,19,240,255,41,37,250,255,20,17,170,255,24,21,174,255,25,18,183,255,36,19,217,255,80,164,135,255,139,186,137,255,124,194,131,255,122,202,141,255,141,218,157,255,50,119,69,255,101,160,109,255,100,168,115,255,43,33,255,255,38,33,249,255,38,31,252,255,35,35,255,255,31,31,251,255,32,30,255,255,38,29,255,255,30,28,254,255,25,21,254,255,36,26,255,255,51,48,252,255,82,68,254,255,89,77,255,255,33,28,251,255,60,48,254,255,92,76,254,255,88,88,255,255,36,35,255,255,23,16,237,255,29,32,244,255,23,16,203,255,24,15,165,255,23,19,174,255,56,112,123,255,88,171,116,255,52,135,80,255,179,213,159,255,177,224,175,255,105,186,131,255,64,111,65,255,59,106,60,255,105,150,94,255,67,147,94,255,89,159,136,255,37,31,250,255,37,30,251,255,36,27,254,255,29,27,253,255,41,34,255,255,27,23,255,255,27,23,255,255,35,24,255,255,38,41,253,255,54,56,251,255,73,66,255,255,42,45,255,255,41,39,255,255,68,58,255,255,73,73,255,255,42,37,
253,255,24,21,231,255,28,21,242,255,52,51,231,255,64,149,99,255,50,147,80,255,21,114,63,255,91,159,106,255,107,175,122,255,181,221,166,255,181,221,173,255,25,58,31,255,46,70,40,255,19,46,26,255,26,80,45,255,56,162,95,255,71,170,102,255,44,33,255,255,36,28,253,255,34,27,254,255,38,30,254,255,44,32,255,255,29,25,255,255,27,23,255,255,30,28,254,255,37,36,252,255,48,44,255,255,46,49,254,255,34,34,254,255,27,24,254,255,48,42,255,255,61,63,255,255,69,71,255,255,24,18,237,255,23,19,232,255,39,36,252,255,62,139,148,255,75,164,101,255,83,149,97,255,85,145,97,255,76,159,97,255,27,152,83,255,28,112,53,255,49,94,55,255,28,65,33,255,10,38,18,255,11,56,29,255,56,149,98,255,34,137,79,255,73,108,212,255,37,30,251,255,38,31,252,255,40,29,246,255,41,37,250,255,30,28,254,255,39,30,255,255,32,30,255,255,35,36,254,255,39,41,255,255,39,43,252,255,38,38,255,255,30,28,254,255,44,39,254,255,61,65,254,255,68,63,254,255,34,24,255,255,25,18,223,255,41,34,255,255,56,72,238,255,78,165,109,255,48,122,74,255,
88,165,104,255,85,168,106,255,54,150,86,255,0,148,82,255,71,128,77,255,21,99,46,255,18,103,51,255,18,105,55,255,29,82,42,255,27,108,61,255,94,180,118,255,33,28,244,255,33,30,240,255,43,32,249,255,49,45,255,255,41,32,255,255,42,33,255,255,38,29,255,255,43,36,255,255,42,37,253,255,29,27,253,255,39,40,255,255,41,36,252,255,44,39,254,255,59,61,255,255,61,64,255,255,40,35,251,255,26,20,221,255,48,42,243,255,49,119,82,255,45,126,71,255,45,159,112,255,56,152,88,255,97,171,111,255,83,146,84,255,58,147,84,255,27,122,65,255,31,94,50,255,28,90,44,255,22,75,35,255,16,80,38,255,50,128,81,255,111,191,126,255,136,213,206,255,39,30,241,255,47,38,249,255,49,28,255,255,32,25,246,255,43,36,255,255,41,34,255,255,42,35,255,255,46,41,255,255,32,30,255,255,43,38,254,255,55,53,255,255,66,57,251,255,66,64,254,255,69,71,255,255,70,65,248,255,129,165,153,255,106,159,119,255,60,136,82,255,37,129,78,255,47,147,95,255,45,153,94,255,53,154,102,255,142,193,136,255,111,175,116,255,89,163,103,255,72,138,79,255,
30,134,71,255,67,142,80,255,39,113,53,255,221,255,248,255,47,137,91,255,181,226,200,255,123,195,142,255,35,50,220,255,52,39,249,255,64,58,253,255,21,16,215,255,43,32,249,255,46,35,252,255,42,35,255,255,162,198,238,255,53,49,245,255,58,51,255,255,56,49,254,255,76,76,255,255,84,86,251,255,86,135,119,255,70,136,77,255,85,143,88,255,45,128,73,255,35,152,91,255,56,142,88,255,79,149,86,255,92,149,88,255,140,180,122,255,164,209,153,255,181,215,161,255,168,195,139,255,120,183,114,255,119,180,112,255,146,206,136,255,255,254,253,255,142,196,136,255,112,168,115,255,52,149,87,255,45,184,163,255,19,113,59,255,32,60,40,255,47,71,177,255,40,33,238,255,38,28,255,255,105,134,242,255,183,225,177,255,80,102,197,255,60,55,248,255,60,56,252,255,70,70,254,255,113,105,255,255,139,201,125,255,78,163,111,255,31,127,73,255,55,139,84,255,96,177,122,255,72,156,102,255,109,174,112,255,112,177,115,255,152,194,139,255,91,151,90,255,118,196,135,255,133,215,186,255,131,198,129,255,141,192,125,255,143,194,150,
255,235,255,253,255,121,177,112,255,76,139,77,255,45,150,87,255,127,225,209,255,59,199,170,255,20,96,62,255,17,70,43,255,51,97,78,255,38,98,68,255,85,132,99,255,93,157,111,255,46,91,52,255,39,58,43,255,51,78,38,255,90,136,84,255,48,72,54,255,137,186,130,255,37,131,74,255,95,181,121,255,46,154,95,255,78,167,104,255,103,187,122,255,99,181,109,255,105,174,123,255,73,147,83,255,127,161,97,255,121,187,116,255,199,255,249,255,143,200,139,255,158,212,152,255,144,245,220,255,217,252,255,255,155,207,147,255,91,182,119,255,39,154,87,255,62,140,79,255,161,225,219,255,81,209,197,255,43,132,82,255,47,126,69,255,69,169,97,255,87,168,105,255,115,201,137,255,141,186,129,255,54,86,51,255,43,67,43,255,27,57,44,255,54,82,53,255,29,127,75,255,82,128,75,255,88,156,101,255,118,172,112,255,73,160,94,255,114,187,117,255,132,203,146,255,61,143,78,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
begin
result:=false;
if not str__lock(xdata) then exit;
str__clear(xdata);
result:=str__addrec(xdata,@xico,sizeof(xico));
str__uaf(xdata);
end;

function ticonmaker.xform(v:tfastvars):string;
const
   imghint='Right click image and select ''Save Image As'' to save icon.';
   br=#10;
   esize=512;
var
   dw,dh,dbits,dcolors,dbytes:longint;
   dtransparent:boolean;
   dimagedata_b64,derrortitle,derrormessage:string;

   function mb(xsize:longint):string;
   begin
   result:=' <input class="iconmaker-button" type="submit" value="'+low__aorbstr('&nbsp;'+k64(xsize)+'px&nbsp;','Make '+k64(xsize)+'px',xsize=16)+'" name="submit.'+intstr32(xsize)+'">';
   end;

   function h4(x:string):string;
   begin
   result:='<h4 style="padding-bottom:0.25em;">'+x+'</h4>'+br;
   end;
begin
//icon
img2ico(v,dw,dh,dbits,dcolors,dbytes,dtransparent,dimagedata_b64,derrortitle,derrormessage);

//get
result:=

'<style type="text/css">'+br+
'.iconmaker-enlarged-view {display:relative;max-width:532px;}'+br+
'.iconmaker-grid {display:grid;grid-template-columns:auto 15rem;grid-gap:1rem;width:auto;padding:5px;border:0;}'+br+
'.iconmaker-space {display:none}'+br+
'.iconmaker-button,.iconmaker-button:link,input[type=file]::file-selector-button {margin:0.1rem;padding:0.25rem 0.3rem;color:#fff;background-color:#f22;border:#f66 1px solid;border-radius:0.5rem;transition:.25s;}'+br+
'.iconmaker-button:hover,input[type=file]::file-selector-button:hover {color:#f22;background-color:#fff;border:#ddd 1px solid;text-decoration:none;}'+br+
'@media only screen and (max-width:650px)'+br+
'{'+br+
'.iconmaker-enlarged-view {display:none;}'+br+
'.iconmaker-grid {grid-template-columns:auto;}'+br+
'.iconmaker-space {display:block}'+br+
'}'+br+
'</style>'+br+

'<a name="iconmaker.scrolldown">&nbsp;</a>'+br+
'<div style="display:block;max-width:99%;width:'+intstr32(esize+256+90)+'px;text-align:left;line-height:normal;letter-spacing:normal;margin:0 auto;padding:0;background-color:#eee;background-image:linear-gradient(45deg, #f0f0f4, #f9f9f9);border:1px #aaa solid;border-radius:15px;">'+br+
'<div style="display:block;text-align:center;margin:0;padding:10px;border:0;border-radius:15px;border-bottom-left-radius:0;border-bottom-right-radius:0;font-size:2em;background-color:#ebebeb;">Icon Maker</div>'+br+
'<div style="display:block;width:auto;margin:0;padding:15px;padding-bottom:20px;border:0;">'+br+
'<div class="iconmaker-grid">'+br+

'<div class="iconmaker-enlarged-view">'+br+
'Enlarged View<br>'+br+

'<div style="width:100%;aspect-ratio:1;border:10px red solid;border-radius:15px;">'+br+
 '<div style="position:relative;width:100%;height:100%;margin:0;padding:0;border:0;"><img src="'+igif32+'" style="position:absolute;top:0px;left:0px;width:100%;height:100%;image-rendering:pixelated;">'+br+
 '<img title="'+imghint+'" src="'+dimagedata_b64+'" style="display:block;position:absolute;top:0;left:0;width:100%;height:100%;margin:0;padding:0;border:0;image-rendering:pixelated">'+br+
 '</div>'+br+
'</div>'+br+
'</div>'+br+

'<div>'+br+
'Icon View<br>'+br+
'<div style="max-width:'+intstr32(dw)+'px;aspect-ratio:1;border:2px red solid;border-radius:3px;margin-top:5px;">'+br+
 '<div style="position:relative;width:100%;height:100%;margin:0;padding:0;border:0;"><img src="'+igif32+'" style="position:absolute;top:0px;left:0px;width:100%;height:100%;image-rendering:pixelated">'+br+
 '<img title="'+imghint+'" src="'+dimagedata_b64+'" style="display:block;position:absolute;top:0;left:0;width:100%;height:100%;margin:0;padding:0;border:0;image-rendering:pixelated">'+br+
 '</div>'+br+
'</div>'+br+

'<br>'+br+

'Icon Details<br>'+br+
'<div style="line-height:180%;display:grid;grid-template-columns:auto auto;grid-gap:2px;margin:0;margin-top:5px;padding:5px;border:1px #ddd solid;border-radius:5px;">'+br+
'<div>'+
'Colors<br>'+
'Bits<br>'+
'Size<br>'+
'Transparent<br>'+
'Width<br>'+
'Height<br>'+
'</div>'+

'<div>'+
k64(dcolors)+'<br>'+
k64(dbits)+' bpp<br>'+
k64(dbytes)+' bytes<br>'+
low__aorbstr('No','Yes, '+low__aorbstr('1 bit','8 bit',dbits=32),dtransparent)+'<br>'+
k64(dw)+' px<br>'+
k64(dh)+' px<br>'+
'</div>'+

'</div>'+br+

'<a class="iconmaker-button" style="display:block;border-radius:20px;margin:0.5rem 0 0 0;text-align:center;" download href="'+dimagedata_b64+'">Download Icon</a>'+br+

'</div>'+
'</div>'+br+

'<div style="text-align:left;width:auto;margin:0;margin:5px;margin-top:20px;padding:5px;color:#fff;background-color:#d71919;background-image:linear-gradient(180deg, #d71919, #f77070, #d71919);border:1px #aaa solid;border-radius:15px;font-size:80%;">'+br+

insstr(h4(derrortitle)+derrormessage+'<br>'+br+'<br>'+br,derrormessage<>'')+

h4('How To')+
'Click "Browse" or "Choose File" button and select an image (bmp, gif, ico, jpg, png, tea or tga). '+
'There is a '+k64(iuploadlimit)+' Mb and '+k64(iinboundimagesizelimit)+' x '+k64(iinboundimagesizelimit)+'px resolution limit. '+
'Then select a "Make 16-256px" button. '+
'Image is uploaded and converted into an icon. '+
'Right click the "Icon View" or "Enlarged View" image and select "Save Image As..." to save your icon. '+
'Alternatively, click the "Download Icon" button to save your icon to your Downloads folder using a generic filename.'+
'<br>'+br+

'<br>'+br+
'<form style="display:block;margin:0;padding:0;border:0;" method=post action="'+pp('iconmaker.html')+'#iconmaker.scrolldown" enctype="multipart/form-data">'+br+
'<input name="cmd" type="hidden" value="upload.image"><input type="file" name="filename" id="filename">'+
'<div class="iconmaker-space">&nbsp;</div>'+
 mb(16)+mb(24)+mb(32)+mb(48)+mb(64)+mb(72)+mb(96)+mb(128)+mb(256)+br+
'</form>'+br+
'</div>'+br+

'</div>'+br+

'</div>'+br+
'';
end;

procedure ticonmaker.xtimer;
begin
//check
if itimerbusy  then exit else itimerbusy:=true;
end;

function ticonmaker.xinfo:string;
begin
result:=
'<div class="console2 miniinfo">'+
'RAM '+low__mbauto(irambytes,true)+' &nbsp; &nbsp; DISK '+low__mbauto(idiskbytes,true)+'<br>'+
'<br>'+
'Jobs Done '+k64(jobcount)+'<br>'+
'</div>'+#10;
end;

function ticonmaker.specialvals(nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean;
begin
result:=true;
xuploadlimit:=insint( (iuploadlimit*1024000), iallow);//admin settable upload limit -> in megabytes
xmultipart:=iallow;
xcanmakeraw:=canmakeraw(nadmin,n);
//this file requires access to inbound user data
xreadpost:=iallow and ( mp(n,'iconmaker.html') );
end;

function ticonmaker.canmakeraw(nadmin:boolean;n:string):boolean;
begin
//was: result:=mp(n,'iconmaker.gif');
result:=false;
end;

function ticonmaker.canmakepage(nadmin:boolean;n:string):boolean;
begin
case nadmin of
true:result:=mp(n,'iconmaker.html');
else result:=mp(n,'iconmaker.html');
end;
end;

function ticonmaker.makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;

   function xsave2(xname,xlabel:string):string;
   begin
   result:=xvsep+'<input name="cmd" type="hidden" value="'+xname+'"><input class="button" type=submit value="'+strdefb(xlabel,'Save')+'"></form>'+#10;
   end;

   function xsave(xname:string):string;
   begin
   result:=xsave2(xname,'');
   end;

   function fs(xname:string;xhash:string):string;//form start
   begin
   result:='<form class="block" method=post action="'+pp(xname)+insstr('#',xhash<>'')+xhash+'">';
   end;
begin
result:=false;
xbinary:=false;

//check
if (not str__lock(xdata)) or (v=nil) then exit;

try
//public pages -----------------------------------------------------------------
if not nadmin then
   begin
   if mp(n,'iconmaker.html') then
      begin
      result:=true;
      if iallow then
         begin
         html__inserttag1(xdata,nil,xform(v),true);
         //was: html__inserttag2(xdata,nil,k64(iuploadlimit),false);//optional
         end;
      end;
   end

//admin pages ------------------------------------------------------------------
else if mp(n,'iconmaker.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('settings',xsymbol('iconmaker')+'Settings')+
   xinfo+


   fs('iconmaker.html','db')+
   '<div class="grid2">'+#10+
   '<div>Upload Limit (1..50 Mb)<br><input class="text" name="uploadlimit" type="text" value="'+k64(iuploadlimit)+'"></div>'+#10+

   html__checkbox('Enable "Icon Maker"','allow',iallow,true,true)+
   '</div>'+#10+
   '<br>'+
   '<p style="font-weight:bold">Hint</p>'+
   'The editor is automatically inserted into the "'+pp('iconmaker.html')+'" page of your website.  Please ensure this file exists.  Use the <span style="text-wrap:nowrap;">"&lt;!--insert--!&gt;"</span> tag (no quotes) to control '+
   'where on the page to insert the editor.  If the tag is not present, the editor will be inserted at the bottom of the page.'+

   xsave('iconmaker.settings')+
   '');
   end;
except;end;
end;

function ticonmaker.img2ico(v:tfastvars;var dw,dh,dbits,dcolors,dbytes:longint;var dtransparent:boolean;var dimagedata_b64:string;var derrortitle,derrormessage:string):boolean;
var
   b:tobject;
   da:trect;
   s,d:tbasicimage;
   ddw,ddh,sw,sh,dsize:longint;
   daction,sformat,e:string;
   xwithinlimits:boolean;
begin
//defaults
result:=false;
derrortitle  :='';
derrormessage:='';
b:=nil;
s:=nil;
d:=nil;
dimagedata_b64:='';
dw:=1;
dh:=1;
dcolors:=0;
dbits:=32;
dbytes:=0;
dtransparent:=false;

try
//size
if      (ivars.s['submit.256']<>'') then dsize:=256
else if (ivars.s['submit.128']<>'') then dsize:=128
else if (ivars.s['submit.96']<>'')  then dsize:=96
else if (ivars.s['submit.72']<>'')  then dsize:=72
else if (ivars.s['submit.64']<>'')  then dsize:=64
else if (ivars.s['submit.48']<>'')  then dsize:=48
else if (ivars.s['submit.24']<>'')  then dsize:=24
else if (ivars.s['submit.16']<>'')  then dsize:=16
else                                     dsize:=32;

//init
s:=misimg32(1,1);
d:=misimg32(dsize,dsize);
mis__cls(d,0,0,0,0);//transparent area

//get
if (v<>nil) then
   begin
   b:=str__new8;
   str__settextb(@b,ivars.s['file.data1']);

   ivars.s['file.data1']:='';//reduce RAM

   //inc job counter - 22feb2025
   if (str__len(@b)>=1) then
      begin
      inc_jobcount;
      inc__dailyjobs;
      end;

   //init
   if not io__findimagewh(@b,sformat,sw,sh) then
      begin
      xwithinlimits:=false;
      if (str__len(@b)>=1) then
         begin
         derrortitle:='Unsupported Image Format';
         derrormessage:='Format of the uploaded image is not supported. Try again with an image in one of these formats: bmp, gif, ico, jpg, png, tea or tga.';
         end;
      end
   else if (sw>iinboundimagesizelimit) or (sh>iinboundimagesizelimit) then
      begin
      xwithinlimits:=false;
      derrortitle:='Image Exceeds Limit';
      derrormessage:='Resolution of the uploaded image is '+k64(sw)+' x '+k64(sh)+'px which exceeds the limit of '+k64(iinboundimagesizelimit)+' x '+k64(iinboundimagesizelimit)+'px. Try again with a smaller image.';
      end
   else xwithinlimits:=true;

   //crop
   low__scalecrop(dsize,dsize,sw,sh,ddw,ddh);
   da.left    :=(dsize-ddw) div 2;
   da.right   :=da.left+ddw-1;
   da.top     :=(dsize-ddh) div 2;
   da.bottom  :=da.top+ddh-1;

   //draw "s" onto "d" -> if failure, make "d" blank
   if (not xwithinlimits) or (not mis__fromdata(s,@b,e)) or (not mis__onecell(s)) or (not mis__fixemptymask(s)) or (not miscopyarea32(da.left,da.top,da.right-da.left+1,da.bottom-da.top+1,misarea(s),d,s)) then
      begin
      //fallback to default icon
      xdefaultico32(@b);
      if not mis__fromdata(d,@b,e) then mis__cls(d,0,0,0,0);//fallback #2 to transparent area
      end;
   //"d" -> icon
   str__clear(@b);
   daction:='';
   if mis__todata3(d,@b,'ico',daction,e) then
      begin
      dw     :=misw(d);
      dh     :=mish(d);
      dbits  :=ia__ifindvalb(daction,ia_bpp,0,1);//actual bits used to create the icon - 19feb2025
      dtransparent:=(ia__ifindvalb(daction,ia_transparent,0,0)<>0);
      dcolors:=miscountcolors(d);
      dbytes :=str__len(@b);
      //.convert to base64
      str__tob64(@b,@b,0);
      dimagedata_b64:='data:'+xmimetype('ico')+';base64,'+str__text(@b);//22feb2025
      //successful
      result:=true;
      end;
   end;
except;end;
try
freeobj(@s);
freeobj(@d);
freeobj(@b);
except;end;
end;

function ticonmaker.readvals(f,n:string;v:tfastvars):boolean;

   function m(sname:string):boolean;
   begin
   result:=strmatch(sname,n);
   end;

   function b(sname:string):boolean;
   begin
   result:=v.checked[sname];
   end;

   function i(sname:string):longint;
   begin
   result:=app__ivalset(subname+'.'+sname,v.i[sname]);
   end;

   function s(sname:string):string;
   begin
   result:=v.s[sname];
   end;
begin
if m('iconmaker.settings') then
   begin
   iallow      :=b('allow');
   iuploadlimit:=i('uploadlimit');
   result:=true;
   end
else result:=false;
end;


function ticonmaker.info(n:string):string;
begin
if      (n='ver')                 then result:='1.00.580'
else if (n='date')                then result:='21feb2025'
else if (n='name')                then result:='Icon Maker'
else if (n='rambytes')            then result:=intstr64(irambytes)
else if (n='diskbytes')           then result:=intstr64(idiskbytes)
else                                   result:='';
end;

function ticonmaker.toolbarcount:longint;
begin
result:=2;
end;

function ticonmaker.toolbaritem(i:longint;var s,n,t,h:string):boolean;
   procedure v(ss,nn,tt,hh:string);
   begin
   s:=ss;
   n:=pp(nn);
   t:=tt;
   h:=hh;
   result:=true;
   end;
begin
case i of
0:v('general','iconmaker','Icon Maker','Icon Maker Settings');
else result:=false;
end;//case
end;

procedure ticonmaker.regvals;
begin
rb('allow',false);
ri('uploadlimit',2,1,50);//1..50 Mb
end;

procedure ticonmaker.getvals;
begin
iallow      :=gb('allow');
iuploadlimit:=gi('uploadlimit');

//loaded
inherited getvals;
end;

procedure ticonmaker.setvals;
begin
sb('allow',iallow);
si('uploadlimit',iuploadlimit);
end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//???????????????????????????????????????????
//timageconverter --------------------------------------------------------------
constructor timageconverter.create;
begin
inherited create;
imodname:='imageconverter';
regvals;

//check we have what we need to run the graphics for this module
need_bmp;
need_jpg;
need_gif;
need_ico;
need_tga;
need_png;

//vars
iwidthlimit  :=1920;
iheightlimit :=1080;
end;

procedure timageconverter.run;
label
   redo;
begin
//check
if not xrunstart then exit;

//get
iallow               :=false;
itimerbusy           :=false;
iuploadlimit         :=0;
irambytes            :=0;
idiskbytes           :=0;
itimer100            :=0;
itimer200            :=0;
igif32               :='';

//defaults
xloadsupport;

//done -> we are now running and "getvals" has been fired - 18aug2024
xrundone(true);
end;

procedure timageconverter.xloadsupport;
const
   //uncompressed (not zipped)
   xgif32x32:array[0..277] of byte=(71,73,70,56,57,97,32,0,32,0,176,0,0,255,255,255,224,224,224,33,255,11,78,69,84,83,67,65,80,69,50,46,48,3,1,0,0,0,33,249,4,8,33,0,0,0,44,0,0,0,0,32,0,32,0,0,8,98,0,1,4,16,72,112,160,193,130,8,15,42,20,184,176,97,194,135,11,33,74,116,216,144,226,196,139,3,49,106,172,184,177,99,70,139,32,39,134,28,249,208,163,71,146,40,9,154,68,153,50,229,202,141,45,59,190,28,25,147,228,76,140,53,53,222,4,153,51,228,78,145,63,29,6,133,216,243,226,80,142,69,133,38,37,122,20,97,83,133,75,149,62,101,56,117,96,64,0,33,249,4,8,33,0,0,0,44,0,0,0,0,32,0,32,0,0,8,98,0,3,0,16,72,112,160,193,130,8,15,42,20,184,176,97,194,135,11,33,74,116,216,144,226,196,139,3,49,106,172,184,177,99,70,139,32,39,134,28,249,208,163,71,146,40,9,154,68,153,50,229,202,141,45,59,190,28,25,147,228,76,140,53,53,222,4,153,51,228,78,145,63,29,6,133,216,243,226,80,142,69,133,38,37,122,20,97,83,133,75,149,62,101,56,117,96,64,0,0,59);
var
   a:tstr8;
begin
//defaults
a:=nil;

try
//gif32 -> base64 embed ready data string
a:=str__new8;
str__addrec(@a,@xgif32x32,sizeof(xgif32x32));
str__tob64(@a,@a,0);
igif32:='data:image/gif;base64,'+str__text(@a);


except;end;

str__free(@a);
end;

destructor timageconverter.destroy;
begin
try
inherited destroy;

//object was not started -> core vars not set so don't destroy them
if not irunning then exit;
except;end;
end;

function timageconverter.listing(var ximgdata,xtitle,xdescription,xrootpage:string;var xonline:boolean;var xjobcount,xrambytes,xdiskbytes:comp):boolean;
begin
result:=true;
ximgdata:='';
xtitle:='Image Converter';
xdescription:='Convert an image from one format to another.';
xrootpage:=pp('imageconverter.html');
xonline:=iallow;
xjobcount:=inherited jobcount;
xrambytes:=irambytes;
xdiskbytes:=idiskbytes;
end;

function timageconverter.xdefaultimage(xdata:pobject):boolean;
const
xpng:array[0..2835] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,32,0,0,0,32,8,6,0,0,0,115,122,122,244,0,0,0,23,116,69,88,116,83,111,102,116,119,97,114,101,0,68,97,110,105,32,118,49,46,48,48,46,50,54,48,20,195,73,175,0,0,0,29,116,69,88,116,98,101,46,112,110,103,46,115,101,116,116,105,110,103,115,0,53,51,54,56,55,48,57,49,49,46,48,46,53,1,238,85,59,0,0,10,143,73,68,65,84,120,1,53,151,95,108,28,213,21,198,63,123,61,147,120,24,123,202,102,82,239,36,120,82,179,249,179,113,48,144,85,83,75,137,17,88,168,145,80,80,74,213,90,149,34,85,188,160,170,188,244,5,169,106,251,180,18,15,125,225,177,82,85,181,15,32,85,180,18,60,208,74,80,4,109,141,168,129,154,162,4,48,80,19,188,33,76,8,187,137,150,53,27,143,134,120,70,137,251,59,227,116,86,119,103,230,254,59,223,253,206,119,206,189,83,169,221,235,110,29,188,123,170,117,91,152,183,106,83,110,107,119,236,183,246,214,131,86,117,194,109,5,119,112,191,67,45,127,194,111,77,213,119,183,124,191,210,250,209,3,223,111,125,85,189,220,58,48,59,213,58,114,100,178,53,180,
115,163,21,55,106,173,253,199,118,183,194,41,181,22,30,186,187,21,212,39,90,115,179,245,214,84,228,183,78,78,29,109,53,103,226,214,241,217,131,173,51,63,142,91,73,239,90,107,52,186,209,26,157,24,109,197,123,252,214,176,187,163,170,155,202,229,58,226,202,203,146,115,175,6,53,245,59,93,141,59,190,252,235,190,250,253,190,38,199,106,10,18,71,135,210,170,158,208,105,61,149,61,170,63,6,63,215,175,194,5,205,199,39,52,223,184,71,131,98,67,142,227,168,225,213,245,179,230,67,106,14,98,53,254,237,105,158,62,139,207,94,81,126,29,27,55,93,245,147,84,10,92,13,199,241,97,13,99,36,47,182,141,87,157,88,247,50,81,179,113,191,30,244,231,202,78,167,239,63,165,24,163,179,58,168,200,9,244,132,255,61,205,36,145,2,126,161,23,107,110,208,212,169,149,166,230,23,27,154,77,142,201,203,34,245,58,133,58,171,158,50,167,96,81,133,178,191,45,43,8,119,202,229,45,26,174,234,196,244,52,207,62,182,61,79,65,80,165,154,203,113,85,100,116,8,154,234,37,137,162,59,66,205,14,26,90,104,71,250,181,191,160,133,141,25,205,
102,24,237,50,113,167,163,162,55,144,83,48,121,49,80,56,200,84,7,204,108,7,64,78,29,38,122,24,151,194,32,148,231,7,90,153,72,228,92,117,180,83,53,61,18,158,212,92,253,56,198,83,141,172,247,46,107,7,15,118,237,244,24,160,84,225,203,171,58,213,143,229,185,158,172,169,16,134,148,201,241,29,57,59,67,60,53,160,20,74,62,107,171,190,175,161,98,163,167,194,5,200,151,61,121,181,72,205,85,250,133,117,41,118,244,74,144,40,241,218,186,218,249,66,123,119,236,81,60,12,7,3,88,121,31,192,135,247,104,232,228,169,185,173,65,150,104,35,235,107,202,243,245,216,149,135,21,229,161,145,33,7,175,120,136,99,101,237,172,66,63,42,65,58,62,109,24,183,223,32,237,40,172,214,49,78,19,224,138,254,64,94,53,82,97,237,128,236,76,22,122,38,120,93,29,230,142,227,186,122,111,94,82,164,113,205,184,117,22,228,104,224,15,52,82,71,44,171,69,95,155,94,95,143,4,247,41,188,196,10,105,244,48,62,72,123,76,28,148,134,149,227,27,187,76,42,92,6,64,48,148,229,80,45,220,184,35,212,128,62,54,78,169,245,45,20,190,151,233,241,233,
7,229,120,142,218,157,158,150,167,164,228,242,21,250,23,10,232,91,116,29,13,61,122,234,204,214,106,241,182,188,34,213,163,197,125,138,17,151,82,40,79,49,144,119,0,192,196,102,34,103,133,176,225,184,72,143,50,240,161,28,67,133,77,4,0,175,22,40,235,119,228,153,55,13,136,45,162,10,120,55,84,224,3,148,231,23,162,101,253,105,249,101,61,224,78,203,235,123,42,252,76,35,38,22,7,71,207,245,238,86,227,90,29,83,230,111,6,219,26,108,133,128,177,24,29,64,105,80,107,112,47,208,2,173,6,128,213,27,75,30,202,73,250,168,190,143,112,243,62,111,19,229,12,5,160,25,169,100,173,45,111,186,174,248,195,76,119,162,252,18,178,107,255,133,70,206,15,46,232,120,81,83,83,136,134,206,37,253,24,46,132,176,160,179,164,218,220,193,176,160,234,41,121,119,89,89,76,116,230,128,168,154,97,212,237,194,84,215,122,224,50,130,203,82,138,129,116,108,30,216,16,45,14,237,77,191,174,217,104,70,75,69,71,139,221,215,96,109,151,70,166,234,174,206,172,226,167,47,6,116,54,191,162,119,67,110,194,50,218,183,241,242,130,255,62,90,
85,60,221,208,11,107,171,74,136,92,103,159,167,55,243,183,229,67,251,195,213,187,112,29,192,88,163,135,48,77,168,25,162,52,0,38,228,237,59,185,195,9,117,50,136,181,248,193,107,234,164,95,162,129,147,205,173,133,247,155,10,77,60,38,56,91,53,180,151,5,227,104,25,16,24,195,239,70,154,83,141,49,158,233,57,244,113,93,155,208,251,145,45,90,71,226,105,109,228,169,126,163,239,42,233,66,57,243,152,35,29,88,241,208,129,3,91,129,1,27,131,21,40,106,7,61,61,147,189,184,13,96,254,181,80,13,107,164,99,169,114,38,55,223,15,204,199,90,87,134,1,155,176,167,97,133,113,67,43,80,254,124,191,173,241,56,214,181,52,213,161,93,223,212,199,157,11,186,179,155,235,113,53,212,206,63,135,9,116,192,184,65,126,137,154,59,209,79,84,50,19,76,108,135,115,187,88,213,147,193,95,0,80,219,191,181,144,31,45,19,142,7,202,50,220,160,210,146,205,246,111,29,195,41,60,164,76,180,95,61,226,61,195,191,139,233,138,174,80,151,186,190,92,215,213,137,220,71,217,57,17,146,227,194,84,179,238,97,198,93,65,43,100,86,77,17,9,49,32,
72,110,227,8,251,166,244,194,222,37,45,122,231,52,244,251,120,97,107,134,212,106,52,150,9,197,66,203,158,185,155,168,50,109,148,0,18,168,153,209,30,216,64,136,190,212,60,208,212,115,159,252,157,112,28,211,133,228,156,14,169,170,166,187,71,13,18,214,98,127,133,125,131,132,164,47,137,136,113,10,190,199,117,1,73,170,212,88,181,208,147,222,159,229,197,99,26,9,105,78,124,11,37,252,139,104,44,112,122,172,222,195,231,219,73,39,167,198,165,151,69,194,53,166,178,60,65,82,57,183,164,184,90,45,251,133,110,77,243,212,47,230,95,234,149,254,121,197,244,239,177,136,168,122,8,86,200,18,128,178,20,109,97,105,87,65,142,121,44,187,159,39,79,195,97,68,35,52,13,74,227,183,132,70,83,47,191,192,234,55,233,2,181,188,7,76,154,129,168,200,47,43,206,3,40,174,43,234,18,164,73,79,143,228,177,150,242,79,104,79,49,94,5,74,77,81,173,142,113,83,63,102,208,138,198,34,57,208,111,58,243,8,225,240,90,80,110,100,67,255,156,254,197,86,153,46,146,213,50,183,7,37,23,22,185,159,223,154,16,191,241,179,8,72,116,137,59,
123,140,118,193,74,160,101,93,64,27,57,173,57,119,219,185,253,146,45,39,55,119,77,106,6,218,7,136,185,4,115,107,47,41,227,138,140,105,89,240,15,119,189,171,161,167,102,207,108,53,55,73,66,221,142,122,36,21,139,87,219,231,77,243,5,12,56,218,193,179,65,52,23,164,148,46,32,92,64,176,231,211,227,172,190,160,133,101,82,103,87,164,125,154,65,112,86,21,214,0,158,176,85,147,206,61,171,67,192,75,221,37,137,180,237,81,247,172,255,146,134,158,158,127,98,43,186,132,178,65,101,178,203,250,54,45,121,0,127,219,202,204,231,6,132,132,74,43,234,43,175,156,119,115,139,79,49,54,12,238,6,255,85,197,181,153,91,250,97,68,119,25,160,117,34,0,55,163,169,130,244,253,98,242,60,88,17,38,187,227,210,209,76,195,75,131,165,210,248,246,38,227,41,2,89,236,218,105,103,28,195,210,138,62,99,242,62,79,102,124,155,129,132,119,243,183,105,35,182,220,81,26,55,177,102,234,116,87,48,6,19,172,184,238,207,96,156,36,68,143,14,145,209,78,150,136,146,73,92,197,238,137,32,79,117,34,141,172,232,67,205,32,152,122,74,55,196,17,
148,105,211,185,165,122,115,197,58,96,134,153,196,242,154,137,178,203,19,98,164,180,121,110,179,249,152,56,183,47,3,138,202,187,41,188,237,101,14,71,9,249,162,224,212,105,98,14,1,187,202,25,34,38,233,153,11,126,153,190,164,202,104,172,86,35,63,80,38,12,125,189,73,14,168,200,169,0,166,66,182,224,170,6,147,26,124,157,49,197,77,8,30,87,69,183,105,140,122,59,90,173,195,130,137,50,160,182,170,81,29,209,110,29,36,58,146,175,207,151,90,218,204,135,97,131,69,85,106,42,110,72,239,220,248,184,116,69,5,56,191,29,253,151,178,131,185,134,246,55,253,173,159,94,63,173,128,120,181,51,128,169,221,144,135,182,219,177,55,216,123,65,220,119,242,139,248,253,255,212,187,60,155,241,28,247,88,20,8,79,115,98,6,134,157,250,34,60,111,52,91,66,107,231,73,89,204,13,22,202,30,57,99,217,95,211,27,223,234,203,229,84,60,98,218,181,9,76,233,54,32,194,168,133,78,66,50,10,45,113,80,103,7,17,207,189,157,122,243,59,84,82,105,201,201,82,116,64,49,173,88,170,54,97,70,180,175,234,34,121,132,104,33,28,13,160,25,183,137,
108,140,3,160,236,30,95,147,161,175,255,158,75,52,156,195,116,102,219,48,134,109,199,178,211,141,93,61,126,203,233,123,90,65,60,230,127,199,244,129,226,189,114,149,53,214,104,129,88,3,140,21,91,185,207,216,156,88,233,83,146,114,14,91,113,88,214,151,175,244,33,52,201,21,203,151,214,212,254,176,91,46,110,88,156,82,209,39,2,52,250,49,204,233,214,78,66,38,146,194,54,22,247,186,206,166,239,110,239,136,136,40,112,247,150,244,175,96,164,192,128,193,168,179,241,212,217,168,98,29,40,1,69,0,218,6,182,159,182,61,24,134,122,74,0,253,237,50,146,93,160,242,241,51,81,211,136,101,140,55,244,1,33,19,67,57,49,111,148,243,51,223,59,185,57,200,232,197,247,233,167,100,182,131,165,78,204,13,5,117,43,90,43,89,136,8,2,203,160,230,198,237,59,140,226,54,59,180,158,77,19,234,108,158,106,201,206,146,79,164,248,124,25,17,41,254,88,170,161,233,185,234,86,206,129,116,210,3,109,219,144,147,48,232,191,212,125,139,85,241,110,219,172,79,49,129,230,27,165,25,99,170,67,8,154,239,75,191,218,234,74,35,219,225,105,
117,37,155,128,180,103,65,251,128,219,91,140,97,74,85,109,111,224,36,222,237,244,53,220,229,155,207,78,14,139,255,249,72,239,204,116,245,180,255,170,126,151,191,170,78,53,215,95,221,53,14,17,183,147,221,26,156,255,237,67,101,140,137,183,35,192,20,111,197,68,23,149,198,109,149,182,113,249,74,106,104,97,30,150,206,28,83,239,177,123,212,254,33,123,194,67,13,125,251,7,15,104,122,246,132,198,163,113,237,138,171,112,207,183,161,125,159,165,89,170,233,227,49,167,241,190,82,148,107,110,137,231,143,233,244,79,22,180,188,127,29,133,32,170,61,232,194,142,85,172,198,82,112,232,146,209,16,101,128,8,29,124,27,187,0,170,77,168,115,47,97,134,118,58,120,164,60,204,57,229,1,157,111,3,59,138,225,22,190,17,174,15,174,115,18,151,142,206,125,71,149,234,164,219,26,165,243,13,56,179,136,168,84,200,24,149,138,14,31,104,168,115,241,162,46,94,93,211,122,99,72,239,220,60,175,206,55,190,210,102,48,172,170,191,75,149,192,227,116,132,90,42,133,214,227,155,90,217,191,169,179,59,63,85,199,37,63,236,76,117,149,
79,190,113,220,183,118,225,115,77,237,139,149,109,22,28,35,136,172,127,188,174,209,219,80,138,101,179,205,97,253,15,31,75,137,110,173,16,181,247,0,0,0,0,73,69,78,68,174,66,96,130);
begin
result:=false;
if not str__lock(xdata) then exit;
str__clear(xdata);
result:=str__addrec(xdata,@xpng,sizeof(xpng));
str__uaf(xdata);
end;

function timageconverter.xform(v:tfastvars):string;
const
   br=#10;
   esize=512;
var
   dw,dh,dbytes:longint;
   xbrowserimage,xtffirst:boolean;
   dformat,dthumb_b64,dimagedata_b64,derrortitle,derrormessage:string;

   function tf(ddformat:string):string;
   begin
   result   :='<input class="general-button" type="submit" value="&nbsp; '+insstr('Target Format: ',xtffirst)+strup(ddformat)+' &nbsp;" name="submit.'+strlow(ddformat)+'">';
   xtffirst :=false;
   end;

   function h4(x:string):string;
   begin
   result:='<h4 style="padding-bottom:0.25em;">'+x+'</h4>'+br;
   end;

   function xbackgroundANDimage:string;
   begin
//   result:='background-color:#3f9afb;background-image:linear-gradient(180deg,#1975d7,#6ad7f0,#1975d7);';
   result:='background-color:#3f9afb;background-image:linear-gradient(180deg,#1975d7,#17b0fb,#1975d7);';
   end;

   function xstartinfo:string;
   begin
   result:='<div style="text-align:left;width:auto;margin:0;margin:5px;margin-top:20px;padding:5px;color:#fff;'+xbackgroundANDimage+';border:1px #aaa solid;border-radius:15px;font-size:80%;">'+br;
   end;

   function xstopinfo:string;
   begin
   result:='</div>'+br;
   end;

   function ximghint:string;
   begin
   if xbrowserimage then result:='Right click image and select ''Save Image As'' to save image.'
   else                  result:='This is a preview of the image.  To save, click the ''Download Image'' button below.';
   end;

   function xpreview:string;
   begin
   //get
   result:=
   '<div class="general-preview">'+br+

   '<div style="max-height:450px;aspect-ratio:'+floattostrex(dw/frcmin32(dh,1),2)+';border:4px #009fff solid;border-radius:5px;margin:0 auto;">'+br+
    '<div style="position:relative;width:100%;height:100%;margin:0;padding:0;border:0;"><img src="'+igif32+'" style="position:absolute;top:0px;left:0px;width:100%;height:100%;image-rendering:pixelated;border-radius:0;">'+br+
    '<img title="'+ximghint+'" src="'+low__aorbstr(dthumb_b64,dimagedata_b64,xbrowserimage)+'" style="display:block;position:absolute;top:0;left:0;width:100%;height:100%;margin:0;padding:0;border:0;border-radius:0;image-rendering:pixelated;">'+br+
    '</div>'+br+
   '</div>'+br+
   '</div>'+br;

   //add the "download image" button for non-browser native image formats
   if not xbrowserimage then
      begin
      result:=result+'<a class="general-button" style="display:block;border-radius:20px;margin:1.2rem 0 0 0;text-align:center;font-size:200%;" download="untitled.'+dformat+'" href="'+dimagedata_b64+'">&#11015; Download Image "untitled.'+strlow(dformat)+'"</a>'+br;
      end;
   end;
begin
//init
xtffirst:=true;

//image
img2img(v,dw,dh,dbytes,dformat,dimagedata_b64,dthumb_b64,derrortitle,derrormessage);
xbrowserimage:=mis__browsersupports(dformat);

//get
result:=

'<style type="text/css">'+br+
'.general-preview {display:relative;}'+br+
'.general-button,.general-button:link,input[type=file]::file-selector-button {margin:0.1rem;padding:0.25rem 0.3rem;color:#fff;background-color:#22c1ff;border:#669bff 1px solid;border-radius:0.5rem;transition:.25s;}'+br+
'.general-button:hover,input[type=file]::file-selector-button:hover {color:#22c1ff;background-color:#fff;border:#ddd 1px solid;text-decoration:none;}'+br+
'.general-infobar {display:grid;grid-template-columns:auto auto auto auto;grid-gap:0.75rem;width:auto;padding:2px;border:0;}'+br+
'.general-space {display:none}'+br+
'@media only screen and (max-width:650px)'+br+
'{'+br+
'.general-space {display:block}'+br+
'}'+br+

'</style>'+br+

'<a name="general.scrolldown">&nbsp;</a>'+br+
'<div style="display:block;max-width:850px;'+'text-align:left;line-height:normal;letter-spacing:normal;margin:0 auto;padding:0;background-color:#eee;background-image:linear-gradient(45deg, #f0f0f4, #f9f9f9);border:1px #aaa solid;border-radius:15px;">'+br+
'<div style="display:block;text-align:center;margin:0;padding:10px;border:0;border-radius:15px;border-bottom-left-radius:0;border-bottom-right-radius:0;font-size:2em;background-color:#ebebeb;">Image Converter</div>'+br+
'<div style="display:block;width:auto;margin:0;padding:15px;padding-bottom:20px;border:0;">'+br+


//.image preview OR download image (for formats the browser cannot display)
xpreview+

xstartinfo+
h4('Image Information')+
'<div class="general-infobar">'+
'<div>Size '+k64(dbytes)+' bytes ('+low__mbplus(dbytes,true)+')</div>'+
'<div>Dimensions '+k64(dw)+'w x '+k64(dh)+'h</div>'+
'<div>Format '+strup(dformat)+'</div>'+
'</div>'+
xstopinfo+


xstartinfo+
insstr(h4(derrortitle)+derrormessage+'<br>'+br+'<br>'+br,derrormessage<>'')+

h4('How To')+
'Click "Browse" or "Choose File" button and select an image (bmp, gif, ico, jpg, png, tea or tga). '+
'There is a '+k64(iuploadlimit)+' Mb and a '+k64(iwidthlimit)+'w x '+k64(iheightlimit)+'h resolution limit. '+
'Click a target format button. '+
'Image is uploaded and converted to target format. '+
'Right click the image and select "Save Image As..." to save your image to file.  Some formats such as TGA, TEA, PPM etc cannot be viewed by the browser, in which case click the "Download Image" button to save your image to your Downloads folder. '+
'<br>'+br+

'<br>'+br+
'<form style="display:block;margin:0;padding:0;border:0;" method=post action="'+pp('imageconverter.html')+'#general.scrolldown" enctype="multipart/form-data">'+br+
'<input name="cmd" type="hidden" value="upload.image"><input type="file" name="filename" id="filename">'+
'<div class="general-space">&nbsp;</div>'+
 tf('png')+{$ifdef d3}tf('gif')+{$endif}tf('bmp')+tf('tga')+tf('tea')+tf('ppm')+tf('pgm')+tf('pbm')+
'</form>'+br+
'</div>'+br+

xstopinfo;
end;

procedure timageconverter.xtimer;
begin
//check
if itimerbusy then exit else itimerbusy:=true;
end;

function timageconverter.xinfo:string;
begin
result:=
'<div class="console2 miniinfo">'+
'RAM '+low__mbauto(irambytes,true)+' &nbsp; &nbsp; DISK '+low__mbauto(idiskbytes,true)+'<br>'+
'<br>'+
'Jobs Done '+k64(jobcount)+'<br>'+
'</div>'+#10;
end;

function timageconverter.specialvals(nadmin:boolean;n:string;var xuploadlimit:longint;var xmultipart,xcanmakeraw,xreadpost:boolean):boolean;
begin
result:=true;
xuploadlimit:=insint( (iuploadlimit*1024000), iallow);//admin settable upload limit -> in megabytes
xmultipart:=iallow;
xcanmakeraw:=canmakeraw(nadmin,n);
//this file requires access to inbound user data
xreadpost:=iallow and ( mp(n,'imageconverter.html') );
end;

function timageconverter.canmakeraw(nadmin:boolean;n:string):boolean;
begin
result:=false;
end;

function timageconverter.canmakepage(nadmin:boolean;n:string):boolean;
begin
case nadmin of
true:result:=mp(n,'imageconverter.html');
else result:=mp(n,'imageconverter.html');
end;
end;

function timageconverter.makepage(nadmin:boolean;n:string;v:tfastvars;xdata:pobject;var xbinary:boolean):boolean;

   function xsave2(xname,xlabel:string):string;
   begin
   result:=xvsep+'<input name="cmd" type="hidden" value="'+xname+'"><input class="button" type=submit value="'+strdefb(xlabel,'Save')+'"></form>'+#10;
   end;

   function xsave(xname:string):string;
   begin
   result:=xsave2(xname,'');
   end;

   function fs(xname:string;xhash:string):string;//form start
   begin
   result:='<form class="block" method=post action="'+pp(xname)+insstr('#',xhash<>'')+xhash+'">';
   end;
begin
result:=false;
xbinary:=false;

//check
if (not str__lock(xdata)) or (v=nil) then exit;

try
//public pages -----------------------------------------------------------------
if not nadmin then
   begin
   if mp(n,'imageconverter.html') then
      begin
      result:=true;
      if iallow then
         begin
         html__inserttag1(xdata,nil,xform(v),true);
         //was: html__inserttag2(xdata,nil,k64(iuploadlimit),false);//optional
         end;
      end;
   end

//admin pages ------------------------------------------------------------------
else if mp(n,'imageconverter.html') then
   begin
   result:=true;
   str__settextb(xdata,

   xh2('settings',xsymbol('imageconverter')+'Settings')+
   xinfo+


   fs('imageconverter.html','db')+
   '<div class="grid2">'+#10+
   '<div>Upload Limit (1..50 Mb)<br><input class="text" name="uploadlimit" type="text" value="'+k64(iuploadlimit)+'"></div>'+#10+

   html__checkbox('Enable "Image Converter"','allow',iallow,true,true)+
   '</div>'+#10+
   '<br>'+
   '<p style="font-weight:bold">Hint</p>'+
   'The editor is automatically inserted into the "'+pp('imageconverter.html')+'" page of your website.  Please ensure this file exists.  Use the <span style="text-wrap:nowrap;">"&lt;!--insert--!&gt;"</span> tag (no quotes) to control '+
   'where on the page to insert the editor.  If the tag is not present, the editor will be inserted at the bottom of the page.'+

   xsave('imageconverter.settings')+
   '');
   end;
except;end;
end;

function timageconverter.img2img(v:tfastvars;var dw,dh,dbytes:longint;var dformat,dimagedata_b64,dthumb_b64:string;var derrortitle,derrormessage:string):boolean;
const
   xthumbsize=430;
var
   b:tobject;
   da:trect;
   d,s:tbasicimage;
   ddw,ddh,sw,sh:longint;
   daction,sformat,e:string;
   xbrowserimage,xwithinlimits:boolean;
begin
//defaults
result:=false;
derrortitle  :='';
derrormessage:='';
b:=nil;
s:=nil;
d:=nil;
dimagedata_b64:='';
dthumb_b64:='';
dbytes:=0;
dw:=1;
dh:=1;

try
//size
if      (ivars.s['submit.png']<>'') then dformat:='png'
//special workaround -> under Lazarus "gif" fails -> switch to PNG
{$ifdef d3}
else if (ivars.s['submit.gif']<>'') then dformat:='gif'
{$endif}
else if (ivars.s['submit.tga']<>'') then dformat:='tga'
else if (ivars.s['submit.tea']<>'') then dformat:='tea'
else if (ivars.s['submit.bmp']<>'') then dformat:='bmp'
else if (ivars.s['submit.ppm']<>'') then dformat:='ppm'
else if (ivars.s['submit.pbm']<>'') then dformat:='pbm'
else if (ivars.s['submit.pgm']<>'') then dformat:='pgm'
else                                     dformat:='png';


//init
s:=misimg32(1,1);

//get
if (v<>nil) then
   begin
   b:=str__new8;
   str__settextb(@b,ivars.s['file.data1']);

   ivars.s['file.data1']:='';//reduce RAM

   //inc job counter - 22feb2025
   if (str__len(@b)>=1) then
      begin
      inc_jobcount;
      inc__dailyjobs;
      end;

   //init
   if not io__findimagewh(@b,sformat,sw,sh) then
      begin
      xwithinlimits:=false;
      if (str__len(@b)>=1) then
         begin
         derrortitle:='Unsupported Image Format';
         derrormessage:='Format of the uploaded image is not supported. Try again with an image in one of these formats: bmp, gif, ico, jpg, png, tea or tga.';
         end;
      end
   else if (sw>iwidthlimit) or (sh>iheightlimit) then
      begin
      xwithinlimits:=false;
      derrortitle:='Image Exceeds Limit';
      derrormessage:='Resolution of the uploaded image is '+k64(sw)+'w x '+k64(sh)+'h which exceeds the limit of '+k64(iwidthlimit)+'w x '+k64(iheightlimit)+'h. Try again with a smaller image.';
      end
   else xwithinlimits:=true;

   //convert "s" to "dformat" -> if failure, make "s" default image/blank
   if (not xwithinlimits) or (not mis__fromdata(s,@b,e)) or (not mis__onecell(s)) or (not mis__fixemptymask(s)) or (not mis__todata3(s,@b,dformat,daction,e)) then
      begin
      //fallback to default image
      xdefaultimage(@b);
      if not mis__fromdata(s,@b,e) then
         begin
         missize(s,32,32);
         mis__cls(s,0,0,0,0);//fallback #2 to transparent area
         end;
      end;

   //info
   dw     :=misw(s);
   dh     :=mish(s);
   dbytes :=str__len(@b);
   dformat:=io__anyformatb(@b);
   xbrowserimage:=mis__browsersupports(dformat);

   //read "s" back from datastream for "d" thumbnail
   if not xbrowserimage then mis__fromdata(s,@b,e);

   //.convert to base64
   str__tob64(@b,@b,0);
   dimagedata_b64:='data:'+xmimetype(dformat)+';base64,'+str__text(@b);

   //.create a thumbnail for non-browser supported images
   if not xbrowserimage then
      begin
      //crop
      low__scalecrop(xthumbsize,xthumbsize,dw,dh,ddw,ddh);
      da.left    :=(misw(d)-ddw) div 2;
      da.right   :=da.left+ddw-1;
      da.top     :=(mish(d)-ddh) div 2;
      da.bottom  :=da.top+ddh-1;

      //init
      d:=misimg32(da.right-da.left+1,da.bottom-da.top+1);

      //draw "s" onto "d" -> if failure, make "d" blank
      miscopyarea32(0,0,misw(d),mish(d),misarea(s),d,s);
      mis__todata(d,@b,'png',e);
      str__tob64(@b,@b,0);
      dthumb_b64:='data:'+xmimetype('png')+';base64,'+str__text(@b);
      end;

   //successful
   result:=true;
   end;
except;end;
try
freeobj(@s);
freeobj(@b);
freeobj(@d);
except;end;
end;

function timageconverter.readvals(f,n:string;v:tfastvars):boolean;

   function m(sname:string):boolean;
   begin
   result:=strmatch(sname,n);
   end;

   function b(sname:string):boolean;
   begin
   result:=v.checked[sname];
   end;

   function i(sname:string):longint;
   begin
   result:=app__ivalset(subname+'.'+sname,v.i[sname]);
   end;

   function s(sname:string):string;
   begin
   result:=v.s[sname];
   end;
begin
if m('imageconverter.settings') then
   begin
   iallow      :=b('allow');
   iuploadlimit:=i('uploadlimit');
   result:=true;
   end
else result:=false;
end;


function timageconverter.info(n:string):string;
begin
if      (n='ver')                 then result:='1.00.220'
else if (n='date')                then result:='22feb2025'
else if (n='name')                then result:='Image Converter'
else if (n='rambytes')            then result:=intstr64(irambytes)
else if (n='diskbytes')           then result:=intstr64(idiskbytes)
else                                   result:='';
end;

function timageconverter.toolbarcount:longint;
begin
result:=2;
end;

function timageconverter.toolbaritem(i:longint;var s,n,t,h:string):boolean;
   procedure v(ss,nn,tt,hh:string);
   begin
   s:=ss;
   n:=pp(nn);
   t:=tt;
   h:=hh;
   result:=true;
   end;
begin
case i of
0:v('general','imageconverter','Image Converter','Image Converter Settings');
else result:=false;
end;//case
end;

procedure timageconverter.regvals;
begin
rb('allow',false);
ri('uploadlimit',2,1,50);//1..50 Mb
end;

procedure timageconverter.getvals;
begin
iallow      :=gb('allow');
iuploadlimit:=gi('uploadlimit');

//loaded
inherited getvals;
end;

procedure timageconverter.setvals;
begin
sb('allow',iallow);
si('uploadlimit',iuploadlimit);
end;

//support procs ----------------------------------------------------------------
function low__filter(x:string;xfull:boolean):string;
var
   p:longint;
   s,d:byte;
begin
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__length(result) do
   begin
   s:=byte(result[p-1+stroffset]);
   d:=s;

   case s of
   9,10,13       :d:=32;
   ssdoublequote :if xfull then d:=sssinglequote;  //" => '
   sslessthan    :d:=ssLRoundbracket;//< => (
   ssmorethan    :d:=ssRRoundbracket;//> => )
   end;//case

   if (s<>d) then byte(result[p-1+stroffset]):=d;
   end;//p
   end;//if
end;

function url__split(surl:string;var utyp:byte;var xdomain,xurl:string):boolean;
var
   bol1:boolean;
begin
result:=url__split2(surl,utyp,bol1,xdomain,xurl,false,true);
end;

function url__split2(surl:string;var utyp:byte;var xisfrontpage:boolean;var xdomain,xurl:string;xisfrontpageCHECK,xstrict:boolean):boolean;
label
   skipend;
var
   xurl_len,xslashpos,xslashcount,xperiodcount,p:longint;
   c:char;

   function m(n:string):boolean;
   begin
   result:=(xslashpos>=1) and (n<>'') and strmatch(strcopy1(xurl,xslashpos,low__length(n)),n);
   end;
begin
//defaults
result:=false;
xisfrontpage:=false;

//check
if (surl='') then goto skipend;

//filter: surl -> xurl
xurl:=low__filter(surl,true);

//protocol
if      strmatch(strcopy1(xurl,1,7),'http://') then
   begin
   utyp:=0;
   xurl:=strcopy1(xurl,8,low__length(xurl));
   end
else if strmatch(strcopy1(xurl,1,8),'https://') then
   begin
   utyp:=1;
   xurl:=strcopy1(xurl,9,low__length(xurl));
   end
else if not xstrict then
   begin
   utyp:=0;//assumes "http://" without it being present
   end
else goto skipend;

//check
xurl_len:=low__length(xurl);
if (xurl_len<=0) or (xurl_len>sizeof(turl))  then goto skipend;

//.domain
xdomain:=xurl;
xperiodcount:=0;

for p:=1 to xurl_len do
begin
c:=xdomain[p-1+stroffset];
if      (c='.') then inc(xperiodcount)//domain name must have at least one period
else if (c='/') or (c='\') or (c=':') then
   begin
   xdomain:=strcopy1(xdomain,1,p-1);
   break;
   end;
end;//p

if (xdomain='') or (xperiodcount<=0) then goto skipend;

//is frontpage
if xisfrontpageCHECK then
   begin
   xslashcount:=0;
   xslashpos:=1;

   for p:=1 to xurl_len do
   begin

   case byte(xurl[p-1+stroffset]) of
   ssQuestion:break;
   ssSlash:begin
      xslashpos:=p;
      inc(xslashcount);
      if (xslashcount>=2) then break;
      end;
   end;//case

   end;//p

   case xslashcount of
   0:xisfrontpage:=true;
   1:xisfrontpage:=(xurl[xurl_len-1+stroffset]='/') or m('/index.html') or m('/index.htm') or m('/index.asp');
   end;//case

   end;

//successful
result:=true;
skipend:
end;

function url__makeref(xurl:string):comp;
begin
result:=low__ref256U(xurl);
end;

function keyword__makeref(xkeyword:string):comp;
begin
result:=low__ref256U(xkeyword);
end;

function keyword__sep(c:byte):boolean;
begin
result:=(c=32) or (c=9) or (c=10) or (c=sscomma) or (c=ssdot) or (c=sscolon) or (c=sssemicolon) or (c=ssexclaim) or (c=ssat) or (c=ssquestion) or (c=ssSlash) or (c=ssbackslash);
end;

function keyword__filter(x:string;xreadTosep:boolean;var kout:string):boolean;
var
   p:longint;
begin
//filter and lowercase keyword
kout:=strlow(low__filter(strlow(x),false));

//read to keyword sep - optional
if xreadTosep and (kout<>'') then
   begin
   for p:=1 to low__length(kout) do if keyword__sep(byte(kout[p-1+stroffset])) then
      begin
      kout:=strcopy1(kout,1,p-1);
      break;
      end;//p
   end;

//enforce maximum keyword length
if (low__length(kout)>sizeof(tkeyword)) then kout:=strcopy1(kout,1,sizeof(tkeyword));

//successful
result:=(kout<>'');
end;

function url__nowage:comp;
begin
result:=url__nowage2(0);
end;

function url__nowage2(inc_hr:longint):comp;
var
   x:tdatetime;
   y,m,d,hr,min,sec,msec:word;
begin
x:=now;
low__decodedate2(x,y,m,d);
low__decodetime2(x,hr,min,sec,msec);

result:=frcrange32(msec,0,999);
result:=add64(result,sec*1000);
result:=add64(result,min*60*1000);
result:=add64(result,hr*3600*1000);
result:=add64(result,d*24*3600*1000);
result:=add64(result,mult64(m*30*24,3600*1000));
result:=add64(result,mult64(mult64(y,365),24*3600*1000));

if (inc_hr<>0) then result:=add64(result,mult64(inc_hr,3600*1000));
end;

function url__older_than_12hrs(uage:comp):boolean;
begin
result:=(uage<=local_age_back12hrs);
end;

function url__hasdomainname(xurl:string):boolean;//not an numbered ip address -> help to prevent indexing internal ip addresses
var
   p:longint;
begin
result:=false;

//check
if (xurl='') then exit;

//strip protocol
if      strmatch(strcopy1(xurl,1,7),'http://')  then xurl:=strcopy1(xurl,8,low__length(xurl))
else if strmatch(strcopy1(xurl,1,8),'https://') then xurl:=strcopy1(xurl,9,low__length(xurl))
else                                                 exit;

//scan
for p:=1 to low__length(xurl) do
begin

case byte(xurl[p-1+stroffset]) of
ssSlash:break;
lla..llz,uua..uuz:begin
   result:=true;
   break;
   end;
end;//case

end;//p
end;

function html__inserttag(xtag:array of byte;xhtml,xvalue:pobject;xvaluestr:string;xappendIfnotfound:boolean):boolean;
label
   skipend;
var
   xlen,i,p:longint;
begin
result:=false;

try
//check
if not str__lock(xhtml) then goto skipend;
str__lock(xvalue);

//init
xlen:=str__len(xhtml);
i:=-1;

//find
for p:=0 to (xlen-1-sizeof(xtag)) do
begin
if (xtag[0]=str__pbytes0(xhtml,p)) and (xtag[1]=str__pbytes0(xhtml,p+1)) and str__asame3(xhtml,p,xtag,false) then
   begin
   i:=p;
   break;
   end;
end;//p

//insert code
if (i>=0) then
   begin
   str__del3(xhtml,i,sizeof(xtag));
   if str__ok(xvalue) then str__ins(xhtml,xvalue,i) else str__insstr(xhtml,xvaluestr,i);
   end
else if xappendIfnotfound then
   begin
   if str__ok(xvalue) then str__add(xhtml,xvalue) else str__sadd(xhtml,xvaluestr);
   end;

//successful
result:=true;
skipend:
except;end;
try
str__uaf(xhtml);
str__uaf(xvalue);
except;end;
end;

function html__inserttag1(xhtml,xvalue:pobject;xvaluestr:string;xappend:boolean):boolean;
const
   xtag:array[0..13] of byte=(60,33,45,45,105,110,115,101,114,116,45,45,33,62);//'<!--insert--!>'
begin
result:=html__inserttag(xtag,xhtml,xvalue,xvaluestr,xappend);
end;

function html__inserttag2(xhtml,xvalue:pobject;xvaluestr:string;xappend:boolean):boolean;
const
   xtag:array[0..14] of byte=(60,33,45,45,105,110,115,101,114,116,50,45,45,33,62);//'<!--insert2--!>'
begin
result:=html__inserttag(xtag,xhtml,xvalue,xvaluestr,xappend);
end;


end.
