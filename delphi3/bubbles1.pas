unit bubbles1;

interface

uses
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3} windows, sysutils, gossroot, gosswin, gossio, gossimg, gossnet; {$endif}
{$ifdef laz} classes, sysutils, gossroot, gosswin, gossio, gossimg, gossnet; {$endif}
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
//## App...................... Bubbles - Multi-Function Server (bubbles1.pas)
//## Version.................. 3.00.9220
//## Last Updated ............ 02may2024, 29apr2024, 30mar2024, 22mar2024, 16mar2024, 02mar2024, 29feb2024: str__splice(), 19feb2024, 13feb2024, 22jan224, 15jan2024, 03jan2023, 28dec2023, 26dec2023
//## Lines of Code............ 9,300+
//## Languages Supported...... English (ANSI)
//## File Support............. 64bit
//##
//## gossroot.pas ............ App hub / core program execution
//## gossio.pas .............. File IO
//## gossimg.pas ............. Graphics
//## gossnet.pas ............. Network
//## gosswin.pas ............. Win32
//##
//## ==========================================================================================================================================================================================================================

const
   iadminpath               ='/admin/';
   ipowerlimit              =100;
   idefaultpower            =100;
   iserverqueuesize         =10*1000;//10K
   ibufferlimit             =100*1000;//100K
   idefaultpassword         ='admin';
   idefaultdisksite         ='www_';
   idefaultport             =1080;
   idefaultconnections      =1000;
   idefaultthreshold        =10000000;//10 Mb
   idefaultcachesize        =1200;//Mb
   imaxcachesize            =1500;//Mb
   icontact_def_off         ='Unable to accept messages at this stage';
   icontact_def_ok          ='Thank you for your online message';
   icontact_def_fail        ='Your online message could not be processed';
   imaxheadersize           =maxword;//65K
   imaxuploadsize_normal    =maxword;//65K
   imaxuploadsize_admin     =200*1024*1000;//200Mb
   iinbox_msgsperpage       =500;
   iinbox_msgastext_size    =10*1024*1000;//10Mb
   ilogs_perpage            =500;
   ilogs_report_read_limit  =500*1024*1000;//500Mb - this may take ~50 sec to compile into a Log Report, meanwhile the server is held up
   ilogs_report_large_limit =10000;//10K items for such things as Vistors and Referrers

   //client types
   ctNone=0;//not in use
   ctHttp=1;//web server http 1.1
   ctMail=2;//mail server
   ctMax =2;

bubbles_ico_32px:array[0..765] of byte=(
0,0,1,0,1,0,32,32,16,0,0,0,0,0,232,2,0,0,22,0,0,0,40,0,0,0,32,0,0,0,64,0,0,0,1,0,4,0,0,0,0,0,128,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,135,48,0,255,255,255,0,255,225,200,0,255,135,55,0,255,215,185,0,255,205,170,0,255,135,50,0,255,180,130,0,255,230,210,0,255,240,225,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,17,17,16,0,0,0,0,0,0,0,0,0,0,0,17,17,17,17,17,17,0,0,0,0,0,0,0,0,0,17,17,17,17,17,17,17,17,0,0,0,0,0,0,0,1,17,17,17,17,17,17,17,17,16,0,0,0,0,0,0,17,17,17,17,17,17,17,17,17,17,0,0,0,0,0,1,17,17,17,17,17,17,17,17,17,17,16,0,0,0,0,17,17,18,34,34,34,34,34,42,17,17,17,0,0,0,1,17,17,34,34,34,34,34,34,34,35,17,17,16,0,0,1,17,17,162,34,34,34,34,34,34,34,113,17,16,0,0,17,17,17,17,18,34,17,17,17,18,34,33,17,17,0,0,17,17,17,17,18,34,17,17,17,17,34,33,17,17,0,0,17,17,17,17,18,34,17,17,17,17,34,33,17,17,0,1,17,17,17,17,18,34,17,17,17,18,34,33,17,17,0,1,17,17,17,17,18,34,136,136,146,34,34,17,17,17,16,1,17,17,17,17,18,34,34,34,34,34,39,17,17,17,16,1,17,17,
17,17,18,34,34,34,34,34,17,17,17,17,16,1,17,17,17,17,18,34,102,99,34,34,33,17,17,17,16,1,17,17,17,17,18,34,17,17,17,34,37,17,17,17,0,0,17,17,17,17,18,34,17,17,17,18,34,17,17,17,0,0,17,17,17,17,18,34,17,17,17,18,34,17,17,17,0,0,17,17,17,17,18,34,17,17,20,34,33,17,17,17,0,0,1,17,17,50,34,34,34,34,34,34,33,17,17,16,0,0,1,17,17,34,34,34,34,34,34,34,17,17,17,16,0,0,0,17,17,18,34,34,34,34,34,17,17,17,17,0,0,0,0,1,17,17,17,17,17,17,17,17,17,17,16,0,0,0,0,0,17,17,17,17,17,17,17,17,17,17,0,0,0,0,0,0,1,17,17,17,17,17,17,17,17,16,0,0,0,0,0,0,0,17,17,17,17,17,17,17,17,0,0,0,0,0,0,0,0,0,17,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0,0,0,17,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,248,31,255,255,192,3,255,255,0,0,255,254,0,0,127,252,0,0,63,248,0,0,31,240,0,0,15,224,0,0,7,224,0,0,7,192,0,0,3,192,0,0,3,192,0,0,3,128,0,0,3,128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,1,128,0,0,3,192,0,0,3,192,0,0,3,192,0,0,3,224,0,0,7,224,0,0,7,240,0,0,15,248,0,0,31,252,0,0,63,254,0,0,127,255,0,0,255,255,192,3,255,255,252,
63,255,255,255,255,255);

var
   //timers
   iboostref:comp=0;
   itimerGMT:comp=0;
   itimer100:comp=0;
   itimer1000:comp=0;
   itimer5000:comp=0;
   itimer30000:comp=0;
   itimer_eventdriven:comp=0;

   //core vars
   imailport:longint=25;//fixed at 25
   imail_domain:string='';
   imail_sizelimit:longint=10;//in megabytes
   imail_allow:boolean=false;

   iendofdaydone:boolean=false;
   itimerbusy:boolean=false;
   iloaddate:tdatetime;
   iramlimit:longint=1500;//1.5Gb
   ipowerlevel:longint=idefaultpower;
   iconnlimit:longint=0;
   iconncount:longint=0;
   iconncount_1sec:longint=0;
   ihttpserver:pnetwork=nil;
   imailserver:pnetwork=nil;//port 25
   imustsavesettings:boolean=false;
   imustcloseall:boolean=false;
   imustport:boolean=false;
   ibubbles_png:tstr9=nil;
   ibubbles_ico_32px:tstr9=nil;
   ichunksize:longint=0;
   iresumesupport:boolean=true;
   igmtoffset_hours:longint=0;
   igmtoffset_minutes:longint=0;

   //shared resources -> these are used amongst all connections
   ibuffer:array[0..65535] of byte;//shared buffer
   ibuf2:tobject;//can be tstr8 or tstr9
   igmtstr:string;
   ivars:tfastvars;
   icontact_allow,icontact_question:boolean;
   icontact_off,icontact_ok,icontact_fail:string;

   //settings
   imustboost,icache,ialongsideexe,ishutidle,icsp,inorefdown,isummarynotice,iquotanotice,ireloadnotice,ireverseproxy,ilivestats,irawlogs:boolean;
   iconsolerate,iport:longint;
   iidletimeout:comp;
   imap:tfastvars;//list of domain mapping
   idom:tfastvars;//list of domains to track hits for
   idominfo:tfastvars;//stores number of files and memory (in bytes) for each disk site (domain)
   imime:tfastvars;//list of mime types
   imime_fallback:tfastvars;
   iredirect:tfastvars;//list of redirect links for ALL sites
   //tracking
   imustmakepngs:boolean;
   ihitmustsave:boolean;
   ihit,ihitref:tfastvars;//list of domains and their hits plus "total"
   ibytes:tfastvars;//list of domains and their bandwidth
   ihitpng:tfastvars;//one PNG image per domain, dynamically created/allocated - 26dec2023
   //.request rate info
   irequestrate:longint=0;//number of requests per minute
   irequestrate0:longint=0;//temp var

   //security
   i127_0_0_1:tint4;

   //admin
   iadminkey:string;
   isessiontimeout   :comp=0;
   icookietimeout    :comp=0;
   isessioncount     :longint=0;//for information purposes only
   isessionnameLEN   :longint=100;
   isessiontime      :array[0..99] of comp;//0=not in use, else=use to detect idle time
   isessioncookietime:array[0..99] of comp;
   isessionname      :array[0..99] of string;//list of ids of logged in users as a file path (both sessionname and isessioncookie are required for access to /admin/ services) - 11mar2024
   isessioncookie    :array[0..99] of string;//list of ids of logged in users as a cookie
   isessionua        :array[0..99] of string;//user agent -> if this differs during a session then auto logout the user and report a security warning
   ihelpdata         :string='';//filled via xmakehelp

   //ram file cache
   ireload_domindex:longint;
   irambytes,ireload_rambytes,ireload_ramlimit,ithreshold:comp;
   iramfilescached,iramfilecount,iramcount:longint;//does not shrink for maximum stability
   iramgmt:string;
   iramdate:tdatetime;
   iramid:longint;//increments each time "xreload()" is called
   inref1:tdynamicinteger;
   inref2:tdynamicinteger;
   iname:tdynamicstring;
   idata:tdynamicstr9;//07feb2024: using 4K memory blocks
   isize:tdynamiccomp;//for content-length
   idate:tdynamicdatetime;//used to make etag in realtime and for header purposes
   imode:tdynamicinteger;//wsmRam, wsmDisk, wsmLink
   idomindex:tdynamicinteger;
   ihave:tdynamicbyte;//used during creload() proc to determine if file is to be included in the RAM cache

   idaily_bandwidth,idaily_bandwidth_quota,idaily_bandwidth_quota_bytes:comp;
   idaily_bandwidth_exceeded:boolean;

   //fast folder references
   ifastfolder__logs:string;
   ifastfolder__inbox:string;
   ifastfolder__inbox_read:string;
   ifastfolder__trash:string;//16mar2024
   ifastfolder__trash_read:string;
   ifastfolder__root:string;

   //contact form question support
   iquestion__answer:array [0..999] of longint;//0=question not set, as answers are always ">=1" - 04apr2024
   iquestion__index:longint;


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 09apr2024

//basic app functions ----------------------------------------------------------
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__create;
procedure app__destroy;
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;
function app__syncandsavesettings:boolean;

//header creators
function header__make(var a:pnetwork;xcode:longint;xacceptranges,xcustom404:boolean;xval,xtext,xmoreheaders:string):boolean;
function header__make206(var a:pnetwork;xpartFROM,xpartTO,xFILESIZE:comp;xdate:tdatetime;xcache:boolean):boolean;
function header__make3(var a:pnetwork;xcode:longint;xacceptranges:boolean;xconlen:comp;xdate:tdatetime;xcache,xnoreferrer:boolean;xmoreheaders:string):boolean;
function header__make4(var a:pnetwork;xcode:longint;xacceptranges,xmustclose,xfirstwrite:boolean):boolean;

//stream procs
procedure stm__readdata1(var a:pnetwork);
procedure stm__makereply2(var a:pnetwork);
procedure stm__writedata3(var a:pnetwork);
procedure stm__readmail(var a:pnetwork);//implements the SMTP protocol - updated to 40K search 11mar2024

//log report procs
function log__info(xname:string):string;
procedure log__makereport(var a:pnetwork;slogfilename:string);
function log__buildreport(var a:pnetwork;d:tobject;dmakeref,slogfilename:string):boolean;


//xxxxxxxxxxxxxxxxxxxxxxxx//ccccccccccccccccc
//question support (contact form anti-spam challenge filter)
function question__make(var xquestion:string):boolean;
function question__checkanswer(xanswer:longint):boolean;

//support procs
function hits__extcounts(xext:string):boolean;
function xconn_limit:longint;//maximum number of records permitted
function xconn_count:longint;//number of records in use
function xaccept_connection_autotype(s:tsocket):boolean;
procedure xclose_connection(x:pnetwork);
procedure xsetdaily_bandwidth_quota(xquota_in_mb:comp);
procedure xinc_daily_bandwidth(xlen:longint);
function xmakehelp(xclaudehelp:boolean):string;
function xsymbol(xname:string):string;
function xcmdline__mustclose:boolean;
function xcmdline__mustclose2(xforcecmd:string;var xoutput:string):boolean;
function xcmdline__output(xforcecmd:string):string;
function xstrcopyto(x:string;xto:char):string;
function xforce_backslash(x:string):string;
function xforce_slash(x:string):string;
function xaddfiletoram(var xfolder:string;var xrec:tsearchrec;var xsize:comp;var xdate:tdatetime;xisfile,xisfolder:boolean;xhelper:tobject):boolean;
function xdomfiles(n:string):longint;
function xdombytes(n:string):comp;
function xreload(xboot:boolean):boolean;//01may2024: optimised for fast reload
function xmakehash(x:string):string;
function xextractsessionname(xpath:string;var xname:string):boolean;
function xpassword_ok(xpassword:string):boolean;
function xnewsession(xpassword,xuseragent:string;var xsessionname,xsessioncookie:string;var xindex:longint):boolean;
function xsessionok(xsessionname,xsessioncookie,xuseragent,xip,xadminpage:string;var xindex:longint):boolean;
function xsessiondel(xsessionname:string):boolean;//27dec2023
procedure xsessiondelall;
function xramnewslot(xname:string;var xslot:longint;var xnew:boolean):boolean;
function xramfind(m:tnetbasic):boolean;
function xfileinram(xfilename:string):boolean;
function xfromfile64(m:tnetbasic;xfrom:comp;var xfilesize:comp;var xfiledate:tdatetime;xchunksize:longint;xfirst,xmustbuffer:boolean):boolean;
function xstreamstart(var a:pnetwork;wmode:longint;xfilename:string;xcancache:boolean):boolean;
function xstreammore(var a:pnetwork;var xdataproblem,xdone:boolean):boolean;
procedure xwritemsg(xsubject,xmsg:string);
procedure xendofday;
function xdailysummary(xreset:boolean):string;
function xlogs(var a:pnetwork;xcmd:string):string;
function mail__bestformat(s,d:pobject;var dhtml:boolean;var dfrom,dto,ddate,dsubject:string):boolean;
function xneurl(x:string):string;//netencode url
function xencodetextforhtml_barely(x:string):string;//only filter out [<>"] 3 chars
function xinbox__folder(xstyle:string;xread:boolean):string;
function xinbox_filenameassubject(s:string;var xdatestr,xsubjectstr:string):boolean;
function xinbox(var a:pnetwork;xstyle,xcmd,xcmd2:string):string;
function xinbox_act(var a:pnetwork;xname:string):string;
procedure xinbox__markread(xstyle,xname:string);
procedure xinbox_msgastext(var a:pnetwork;xstyle,xname:string);//14mar2024: Updated for Facebook emails
function xdommapping2(xonesiteonly:string;var xerrorcount:longint):string;
function xdommapping(var xerrorcount:longint):string;
function xinfostats:string;
function xcolumnRight(x:string):string;
function xminiconsole:string;
function xpowerlevel:string;
function xtotallabel(xpreblankline:boolean;xcount:comp;xname,xname12:string):string;
function xconbut(xpageurl,xcmd,xcmd2,xtitle,xbutlabel:string):string;
function xinfo2(xpageurl,xcmd:string):string;
procedure xinfo(xpageurl,xcmd:string;var xtitle,xout:string);
function xmanage:string;
function xredirect__have(sname:string;var dnameORurl:string):boolean;
function xredirect__sitelinks(ssite:string):string;
procedure xredirect__addlocal(xsite,xlinks:string);
procedure xredirect__clean(xremovesite:string);
function xh2(xlinkname,xname:string):string;
function xh2b(xlinkname,xname,xclass:string):string;
function xvsep:string;
function xvsepbig:string;
function xhtmlstart(var a:pnetwork;xshowtoolbar:boolean):string;
function xhtmlstart2(var a:pnetwork;xhead:string;xshowtoolbar:boolean):string;
function xhtmlstart3(var a:pnetwork;xhead:string;xshowtoolbar,xbare,xultrawide:boolean):string;
function xhtmlstart4(var a:pnetwork;xhead0,xhead1:string;xshowtoolbar,xbare,xultrawide:boolean):string;
function xhtmlback:string;
function xhtmlfinish:string;
function xhtmlfinish2(xbare:boolean):string;
function xsafewebname(var x:string):boolean;
function xcontact_html(var a:pnetwork):boolean;
function xlogrequest_http(var a:pnetwork;xaltcode:longint):boolean;
function xlogrequest_smtp(var a:pnetwork;xcode:longint):boolean;
function xcodedes(xcode:longint):string;
function xmimelist:string;
procedure xmime_fallback;
function xmimetype(xext:string):string;//09apr2024: updated to allow minor modification to "html", includes common fallback defaults - 26dec2923
function xcommonheaders(xext:string;xkeepalive,xcache,xacceptranges:boolean):string;
function xmakehitspng(x:tstr8;xhits:comp):boolean;//make "hits.png" image
procedure xmakepngs(xforce:boolean);//make all "hits.png" for listed disk domains "idom"
procedure xinchit(xdiskhost:string);
procedure xresolvehost(m:tnetbasic);//use mapping


implementation


//info procs -------------------------------------------------------------------
//## app__info ##
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;
//## info__app ##
function info__app(xname:string):string;//information specific to this unit of code - 09apr2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='ver')                 then result:='3.00.9220'
else if (xname='date')                then result:='02may2024'
else if (xname='name')                then result:='Bubbles'
else if (xname='des')                 then result:='Multi-Function Server'
else if (xname='infoline')            then result:='Bubbles Multi-Function Server v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:='Bubbles Multi-Function Server'
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:='HTTP/1, SMTP, web panel, web mail, virtual hosting, domain mapping, redirector, logs + reports, contact form and site counters'
else
   begin
   //nil
   end;

except;end;
end;

//app procs --------------------------------------------------------------------
//## app__create ##
procedure app__create;
label
   redo;
var
   p:longint;
   e:string;
begin
try
//need checkers -> displays an error message if one or more libraries not enabled
need_filecache;
need_net;
need_ipsec;
need_png;


//vars
iloaddate:=now;
isessiontimeout:=mult64(2000,86400);//2 days
icookietimeout:=mult64(1000,60*60);//retransmit ative Admin session cookie every hour
iidletimeout:=mult64(1000,120);//2 minutes
ibuf2:=str__new9;
ivars:=tfastvars.create;

imustmakepngs:=false;
ihitmustsave:=false;
ihit:=tfastvars.create;//persists - does not reset
ihitref:=tfastvars.create;//resyncs every 24hr
ibytes:=tfastvars.create;//reset every 24hr
ihitpng:=tfastvars.create;

imap:=tfastvars.create;
idom:=tfastvars.create;
idominfo:=tfastvars.create;
imime:=tfastvars.create;
imime_fallback:=tfastvars.create;
iredirect:=tfastvars.create;

igmtstr:=low__gmt(now);
ibubbles_png:=str__new9;
ibubbles_ico_32px:=str__new9;
str__addrec(@ibubbles_ico_32px,@bubbles_ico_32px,sizeof(bubbles_ico_32px));

ichunksize:=high(ibuffer)+1;

//.127.0.0.1
with i127_0_0_1 do
begin
b0:=127;
b1:=0;
b2:=0;
b3:=1;
end;


//admin
iadminkey:='';
for p:=0 to high(isessiontime) do
begin
isessiontime[p]:=0;
isessioncookietime[p]:=0;
isessionname[p]:='';
isessioncookie[p]:='';
isessionua[p]:='';
end;//p

//ram cache
ireload_domindex:=0;
ireload_rambytes:=0;
ireload_ramlimit:=0;
irambytes:=0;
iramcount:=0;//number of RAM slots used both FULL and EMPTY slots
iramfilescached:=0;
iramfilecount:=0;
iramdate:=now;
iramgmt:='';
iramid:=1;
inref1:=new__int;
inref2:=new__int;
iname:=new__str;
idata:=tdynamicstr9.create;
isize:=new__comp;
idate:=new__date;
imode:=new__int;
idomindex:=new__int;
ihave:=new__byte;

idaily_bandwidth:=0;
idaily_bandwidth_quota:=0;
idaily_bandwidth_quota_bytes:=0;
idaily_bandwidth_exceeded:=false;

//register acceptable value names for use with settings
app__ireg('powerlevel',idefaultpower,1,ipowerlimit);
app__breg('service',false);//02mar2024
app__breg('cache',true);
app__breg('livestats',true);
app__breg('rawlogs',true);
app__breg('csp',true);
app__breg('norefdown',true);
app__breg('shutidle',true);
app__breg('alongsideexe',false);
app__breg('reverseproxy',false);
app__breg('summary.notice',true);
app__breg('quota.notice',true);//03apr2024
app__breg('reload.notice',true);
app__ireg('consolerate',5,0,60);//web console refresh rat, 0=off, 1..60=refresh interval in seconds
app__ireg('connlimit',idefaultconnections,10,net__limit);//10..max (less than 10 will make browser fail, possibly deny access to admin panel if other users are using the server) - 08jan2024
app__ireg('port',idefaultport,2,maxport);//Chrome states "port 1" is unsafe
app__ireg('ramlimit',idefaultcachesize,10,imaxcachesize);//10..1500 Mb
app__sreg('hitinfo','');
app__sreg('domainmap','');
app__sreg('adminkey',xmakehash(idefaultpassword));
app__creg('threshold',idefaultthreshold,0,mult64(imaxcachesize,1024000));//0..1.5Gb
app__creg('daily.bandwidth.quota',0,0,max64);

//.contact form messages
app__breg('contact.question',false);
app__breg('contact.allow',false);
app__sreg('contact.off','');
app__sreg('contact.ok','');
app__sreg('contact.fail','');
//.mail
app__breg('mail.allow',false);
app__sreg('mail.domain','');
app__ireg('mail.sizelimit',20,1,50);//1..50Mb
//.ipsec
app__ireg('scanfor',24*60,0,max32);//1 day
app__ireg('banfor',7*24*60,0,max32);//1 week
app__ireg('simconnlimit',30,0,max32);//30 connections
app__ireg('postlimit',20,0,max32);//20 submissions
app__ireg('badlimit',20,0,max32);//20 attempts
app__ireg('hitlimit',100*1000,0,max32);//100K hits
app__creg('datalimit',5000,0,max64);//5Gb

//read settings
ipowerlevel     :=app__ival('powerlevel');
icache          :=app__bval('cache');
ilivestats      :=app__bval('livestats');
irawlogs        :=app__bval('rawlogs');
iconsolerate    :=app__ival('consolerate');
icsp            :=app__bval('csp');
inorefdown      :=app__bval('norefdown');
ishutidle       :=app__bval('shutidle');
ialongsideexe   :=app__bval('alongsideexe');
ireverseproxy   :=app__bval('reverseproxy');
isummarynotice  :=app__bval('summary.notice');
iquotanotice    :=app__bval('quota.notice');
ireloadnotice   :=app__bval('reload.notice');
iconnlimit      :=app__ival('connlimit');
iramlimit       :=app__ival('ramlimit');//in mb
iport           :=app__ival('port');
iadminkey       :=app__sval('adminkey');
ithreshold      :=app__cval('threshold');
xsetdaily_bandwidth_quota(app__cval('daily.bandwidth.quota'));

//.contact form
icontact_question:=app__bval('contact.question');
icontact_allow   :=app__bval('contact.allow');
icontact_off     :=app__sval('contact.off');
icontact_ok      :=app__sval('contact.ok');
icontact_fail    :=app__sval('contact.fail');

//.question support
iquestion__index:=0;
low__cls(@iquestion__answer,sizeof(iquestion__answer));

//.mail
imail_allow     :=app__bval('mail.allow');
imail_domain    :=app__sval('mail.domain');
imail_sizelimit :=app__ival('mail.sizelimit');

//.ipsec
ipsec__setvals(app__ival('scanfor'),app__ival('banfor'),app__ival('simconnlimit'),app__ival('postlimit'),app__ival('badlimit'),app__ival('hitlimit'),mult64(app__cval('datalimit'),1024000));

//.load hit info
ihit.fromfile(app__settingsfile('hits.ini'),e);
ihitref.fromfile(app__settingsfile('hitsref.ini'),e);
ibytes.fromfile(app__settingsfile('bytes.ini'),e);
//.load map info (domain mapping)
imap.fromfile(app__settingsfile('map.ini'),e);
//.load mime type info
xmime_fallback;
imime.fromfile(app__settingsfile('mime.ini'),e);
//.load redirect info
iredirect.fromfile(app__settingsfile('redirect.ini'),e);

//.create http server record
net__makerec(ihttpserver);
net__makerec(imailserver);

//.command line parameters
if not xcmdline__mustclose then
   begin
   app__halt;
   exit;
   end;

//.help - for server only, not required command prompt
ihelpdata:=xmakehelp(false);

//.starting...
app__writeln('');
app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(ilivestats);


//xmakelogreport('c:\temp\logs\2024y-03m-10d__rawlog.txt');app__halt;//xxxxxxxxxxxxxxxxxxxxxx


//load
xreload(true);
except;end;
end;
//## app__destroy ##
procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//vars
free__7(@ihit,@ihitref,@ibytes,@imap,@idom,@idominfo,@imime);
free__4(@imime_fallback,@iredirect,@ihitpng,@ivars);
str__free(@ibuf2);
str__free(@ibubbles_png);
freeobj(@ibubbles_ico_32px);
//.ram cache
free__7(@inref1,@inref2,@iname,@idata,@isize,@idate,@imode);
free__2(@ihave,@idomindex);
except;end;
end;
//## app__syncandsavesettings ##
function app__syncandsavesettings:boolean;
var
   e:string;
begin
//defaults
result:=false;
try
//.settings
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
app__ivalset('port',iport);
app__ivalset('connlimit',iconnlimit);
app__bvalset('cache',icache);
app__bvalset('livestats',ilivestats);
app__ivalset('consolerate',iconsolerate);
app__bvalset('rawlogs',irawlogs);
app__bvalset('csp',icsp);
app__bvalset('norefdown',inorefdown);
app__bvalset('shutidle',ishutidle);
app__bvalset('alongsideexe',ialongsideexe);
app__bvalset('reverseproxy',ireverseproxy);
app__bvalset('summary.notice',isummarynotice);
app__bvalset('quota.notice',iquotanotice);
app__bvalset('reload.notice',ireloadnotice);
app__svalset('adminkey',iadminkey);
app__cvalset('threshold',ithreshold);
app__cvalset('daily.bandwidth.quota',idaily_bandwidth_quota);

//.contact form
app__bvalset('contact.question',icontact_question);
app__bvalset('contact.allow',icontact_allow);
app__svalset('contact.off',icontact_off);
app__svalset('contact.ok',icontact_ok);
app__svalset('contact.fail',icontact_fail);

//.mail
app__bvalset('mail.allow',imail_allow);
app__svalset('mail.domain',imail_domain);
app__ivalset('mail.sizelimit',imail_sizelimit);

//.ipsec
app__ivalset('scanfor',ipsec__scanfor);
app__ivalset('banfor',ipsec__banfor);
app__ivalset('simconnlimit',ipsec__connlimit);
app__ivalset('postlimit',ipsec__postlimit);
app__ivalset('badlimit',ipsec__badlimit);
app__ivalset('hitlimit',ipsec__hitlimit);
app__cvalset('datalimit',div64(ipsec__datalimit,1024000));

//.save
app__savesettings;

//.save hit info
ihit.tofile(app__settingsfile('hits.ini'),e);
ihitref.tofile(app__settingsfile('hitsref.ini'),e);
ibytes.tofile(app__settingsfile('bytes.ini'),e);
//.save map info
imap.tofile(app__settingsfile('map.ini'),e);
//.save mime type info
imime.tofile(app__settingsfile('mime.ini'),e);
//.save redirect info
iredirect.tofile(app__settingsfile('redirect.ini'),e);

//successful
result:=true;
except;end;
end;
//## app__netmore ##
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=nil;try;result:=tnetbasic.create;except;end;
end;
//## app__onmessage ##
function app__onmessage(m,w,l:longint):longint;
var
   a:tint4;//fixed 19feb2024
   x:pnetwork;
begin
//defaults
result:=0;

if (m=wm_net_message) then
   begin
   imustboost:=true;
   //get
   a.val:=l;
   case a.bytes[0] of
   fd_connect:;
   fd_close:begin
      case net__findbysock(x,w) of
      true :xclose_connection(x);
      false:net____closesocket(w);
      end;
      end;
   fd_accept:xaccept_connection_autotype(w);//08apr2024
   fd_read: if net__findbysock(x,w) then x.canread:=true;
   fd_write:if net__findbysock(x,w) then x.canwrite:=true;
   end;
   end;
end;
//## app__onpaintOFF ##
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
try
app__writeln('Bubbles online at port '+k64(iport)+'.  Live stats are off.');
except;end;
end;
//## app__onpaint ##
procedure app__onpaint(sw,sh:longint);
var
   p:longint;
   str1,n:string;
   //## nv ##
   procedure nv(c:longint;n,v:string);
   const
      nw=19;
      vw=11;
      gw=13;
   var
      dx:longint;
   begin
   //c
   dx:=2;
   if (c>=1) then
      begin
      inc(dx,nw*c);
      inc(dx,vw*c);
      inc(dx,gw*c);
      end;
   //n
   scn__setx(dx);
   scn__text(n);
   //v
   scn__setx(dx+nw);
   if (v<>'') then scn__text(v);
   end;
begin
try
//cls
scn__cls;

//text
scn__moveto(2,1);
scn__text(app__info('infoline'));

scn__down;
scn__down;
nv(0,'Up Time',app__uptimestr);

scn__down;
nv(0,'HTTP Port',inttostr(iport)+' ('+low__aorbstr('offline','online',net__socketgood(ihttpserver))+')' +insstr(' - Quota Reached',idaily_bandwidth_exceeded));
scn__down;
nv(0,'SMTP Port',inttostr(imailport)+' ('+low__aorbstr('offline','online',net__socketgood(imailserver))+')' +insstr(' - Quota Reached',idaily_bandwidth_exceeded));

scn__down;
nv(0,'RAM',low__mbauto(irambytes,true)+'  ('+low__percentage64str(iramfilescached,iramfilecount,true)+' of files cached: '+k64(iramfilescached)+' / '+k64(iramfilecount)+')');
scn__down;
nv(0,'Memory Blocks',k64(track__typecount(satBlock))+' ('+low__kb(block__size,true)+' per block)');

scn__down;
nv(0,'Hits',k64(ihit.c['total']));

scn__down;
if (idaily_bandwidth_quota>=1) then str1:=low__mbPLUS(idaily_bandwidth,true)+' / '+low__mbPLUS(idaily_bandwidth_quota_bytes,true)+insstr(' - Quota Reached',idaily_bandwidth_exceeded) else str1:='Disabled';
nv(0,'Daily Quota',str1);

scn__down;
nv(0,'Bandwidth',low__mbAUTO(net__total,true));
nv(1,'In',low__mbAUTO(net__in,true));

scn__down;
nv(0,'Connections',k64(iconncount_1sec)+' / '+k64(iconnlimit));
nv(1,'Out',low__mbAUTO(net__out,true));

scn__down;
nv(0,'Admin Sessions',k64(isessioncount)+' / '+k64(high(isessionname)+1));

scn__down;
nv(0,'Power Level',k64(ipowerlevel)+'%');
nv(1,'Admin Privileges',low__yes(app__adminlevel));

scn__down;
nv(0,'Traffic Logs',low__enabled(irawlogs));
nv(1,'Cache File Handles',low__enabled(filecache__enabled));

scn__down;
nv(0,'Request Rate',k64(irequestrate)+' req/min ('+k64(irequestrate div 60)+' req/sec)');

scn__down;
scn__down;
nv(0,'Site ---','');
nv(1,'Hits ---','');
nv(2,'Bandwidth ---','');
for p:=0 to frcmax32(idom.count-1,50) do
begin
n:=idom.n[p];
if (n<>'') then
   begin
   scn__down;
   nv(0,n,'');
   nv(1,k64(ihit.c[n]),'');
   nv(2,low__mbAUTO(ibytes.c[n],true),'');
   end;
end;

//frame
//.left
scn__moveto(0,0);
scn__vline('|');
//.right
scn__moveto(scn__width-1,0);
scn__vline('|');
//.top
scn__moveto(0,0);
scn__hline('=');
//.header underscore
scn__moveto(0,2);
scn__hline('=');
//.bottom
scn__moveto(0,scn__height-1);
scn__hline('=');
except;end;
end;
//## xconn_limit ##
function xconn_limit:longint;//maximum number of records permitted
begin
result:=frcmax32(iconnlimit+2,net__limit);//+2 = http and smtp servers -> same network list
end;
//## xconn_count ##
function xconn_count:longint;//number of records in use
begin
result:=frcmax32(iconnlimit+2,net__count);//+2 = http and smtp servers -> same network list
end;
//## xaccept_connection_autotype ##
function xaccept_connection_autotype(s:tsocket):boolean;
var
   asock:tsocket;
   arec:pnetwork;
   v,vsize:longint;
begin
//defaults
result:=false;
v:=0;
vsize:=sizeof(v);

//get
if (0=net____getsockopt(invalid_socket,SOL_SOCKET,SO_OPENTYPE,pchar(@v),vsize)) then
   begin
   //get the client socket
   asock:=net__accept(s);

   //connect inbound socket connection to one of our network slots / permit connection recycling - 08apr2024
   case net__makeclient2(arec,xconn_limit,asock,s,[cthttp,ctmail],xclose_connection) of
   true:begin
      if      (s=ihttpserver.sock) then arec.infotag:=ctHttp//mark as http client
      else if (s=imailserver.sock) then arec.infotag:=ctMail;//mark as mail client
      //successful
      result:=true;
      end;
   false:net____closesocket(asock);
   end;//case
   end;//if

end;
//## xclose_connection ##
procedure xclose_connection(x:pnetwork);
var
   mm:tnetbasic;//ptr only
   buf:pobject;//pointer only
begin
if (x<>nil) and x.init then
   begin
   if x.client then
      begin
      if net__recinfo(x,mm,buf) then
         begin
         case x.infotag of
         //was: ctHttp:if mm.writing then xlogrequest(x,502);
         ctHttp:if mm.vmustlog then xlogrequest_http(x,502);
         ctMail:if mm.vmustlog then xlogrequest_smtp(x,221);
         end;//case
         end;
      net__closerec2(x,true);
      end
   else if x.server then net__closeonlysocket(x);
   end;
end;
//## app__ontimer ##
procedure app__ontimer;
label
   loop;
var
   xms64_timeout_trigger,xms64:comp;
   a:pnetwork;
   xloopcount,dport,int1,xconncount,p:longint;
   bol1:boolean;
   e:string;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors
//init
xms64:=ms64;

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin
   scn__settitle(app__info('name'));
   scn__setvisible(ilivestats);
   end;


//throttle -> as delay and loop count
case msok(iboostref) of
false:root__throttleASdelay(ipowerlevel,xloopcount);//higher power
true:root__throttleASdelay(1,xloopcount);//lowest power
end;//case


loop:

//connections
if (not idaily_bandwidth_exceeded) and ( (ihttpserver.init and ihttpserver.server and (ihttpserver.port>=1)) or (imailserver.init and imailserver.server and (imailserver.port>=1)) ) then
   begin
   //.update GMT str - each connection can use this val as is without having to call "low__gmt" repeatedly
   if msok(itimerGMT) then
      begin
      igmtstr:=low__gmt(now);
      //reset
      msset(itimerGMT,1000);
      end;

   //.connections
   xconncount:=0;
   xms64_timeout_trigger:=xms64-iidletimeout;//sub64(xms64,a.time)>=iidletimeout) => rewritten as "(xms64-iidletimeout)>=a.time"
   for p:=0 to (xconn_count-1) do if net__haverec(a,p) and a.client and (a.more<>nil) then
      begin
      case a.infotag of
      ctHttp:begin
         case tnetbasic(a.more).writing of
         true:if a.canwrite then stm__writedata3(a);
         false:if a.canread then stm__readdata1(a);//separate read and write procs
         end;//case
         end;
      ctMail:if a.canread or a.canwrite then stm__readmail(a);//single combined read and write proc
      end;
      //inc
      inc(xconncount);
      //close client -> Note: SMTP (Mail) connections always close after idle period as they point directly to the internet, whereas HTTP connections have the option of going through a frontend server without idle timeout - 03apr2024
      if a.mustclose or ( (ishutidle or (a.infotag=ctMail)) and a.client and (xms64_timeout_trigger>=a.time_idle) ) then xclose_connection(a);
      end;//p
   iconncount:=largest(iconncount,xconncount);

   //.close all socket connections (except server)
   if imustcloseall then
      begin
      imustcloseall:=false;
      net__closerecBYownk2(ihttpserver,xclose_connection);
      net__closerecBYownk2(imailserver,xclose_connection);
      end;
   end;

//5s
if msok(itimer5000) or imustport then
   begin
   //.reset
   imustport:=false;

   //.make the http server -> "port=0" makes a server that is offline (x.sock=invalid_socket)
   if ihttpserver.init then
      begin
      //init
      dport:=low__insint(iport,not idaily_bandwidth_exceeded);

      //decide
      if (dport<>0) then bol1:=(ihttpserver.port<>dport) or (ihttpserver.sock=invalid_socket)
      else               bol1:=(ihttpserver.port<>dport) or (ihttpserver.sock<>invalid_socket);

      //get
      if bol1 then
         begin
         net__makeserver2(ihttpserver,dport,iserverqueuesize,true);//close any children sockets for immediate affect - 23dec2023
         if not ilivestats then
            begin
            case (ihttpserver.sock<>invalid_socket) of
            true:scn__writeln('HTTP Online at port '+inttostr(iport));
            false:scn__writeln('HTTP Failed to acquire port '+inttostr(iport));
            end;//case
            end;
         end;

      end;

   //.make the mail server -> "port=0" makes a server that is offline (x.sock=invalid_socket)
   if imailserver.init then
      begin
      //init
      dport:=low__insint(imailport,imail_allow and (not idaily_bandwidth_exceeded));

      //decide
      if (dport<>0) then bol1:=(imailserver.port<>dport) or (imailserver.sock=invalid_socket)
      else               bol1:=(imailserver.port<>dport) or (imailserver.sock<>invalid_socket);

      //get
      if bol1 then
         begin
         net__makeserver2(imailserver,dport,iserverqueuesize,true);//close any children sockets for immediate affect - 23dec2023
         if not ilivestats then
            begin
            case (imailserver.sock<>invalid_socket) of
            true:scn__writeln('SMTP Online at port '+inttostr(imailport));
            false:scn__writeln('SMTP Offline at port '+inttostr(imailport));
            end;//case
            end;
         end;
      end;

   //.remake domain based "hits.png" images
   if imustmakepngs then xmakepngs(false);

   //.save settings
   if imustsavesettings then
      begin
      imustsavesettings:=false;
      app__syncandsavesettings;
      end;

   //.net__findcount - allows us to shrink it safely here
   net__findcount;

   //.write unwritten log cache to disk
   log__writemaybe;

   //reset
   msset(itimer5000,5000);
   end;

//30s
if msok(itimer30000) then
   begin
   //.save domain hit information to disk
   if ihitmustsave then
      begin
      ihitmustsave:=false;
      ihit.tofile(app__settingsfile('hits.ini'),e);
      ihitref.tofile(app__settingsfile('hitsref.ini'),e);
      ibytes.tofile(app__settingsfile('bytes.ini'),e);
      end;

   //write daily summary / reset 24 hr counters
   xendofday;

   //reset
   msset(itimer30000,30000);
   end;

//1s
if msok(itimer1000) then
   begin
   //requestrate over 1sec
   int1:=irequestrate0*60;
   if (int1>=irequestrate) then irequestrate:=int1 else irequestrate:=(irequestrate+int1) div 2;
   irequestrate0:=0;

   //.connection count over 1sec
   iconncount_1sec:=iconncount;
   iconncount:=0;

   //reset
   msset(itimer1000,1000);
   end;

//0.1s
if msok(itimer100) then
   begin
   if (ilivestats<>scn__visible) then scn__setvisible(ilivestats);
   if scn__visible then scn__paint;
   msset(itimer100,100);
   end;



//loop
dec(xloopcount);
if (xloopcount>=1) then goto loop;

//turbo mode -> disables console app wait proc
app__turbo;

//boost
if imustboost then
   begin
   imustboost:=false;
   msset(iboostref,1000);
   end;

except;end;
try
itimerbusy:=false;
except;end;
end;
//## xcmdline__output ##
function xcmdline__output(xforcecmd:string):string;
begin
xcmdline__mustclose2(xforcecmd,result);
end;
//## xcmdline__mustclose ##
function xcmdline__mustclose:boolean;
var
   str1:string;
begin
result:=xcmdline__mustclose2('',str1);
end;
//## xcmdline__mustclose2 ##
function xcmdline__mustclose2(xforcecmd:string;var xoutput:string):boolean;
label
   redo,skipend;
const
   clist:array[0..17] of string=('password','connections','port','smtp','cachesize','filesize','quota','power','logs','live','install','uninstall','info','commands','run','help','rawhelp','howto');
var
   xout:tobject;
   p,nlen,int1,xpos:longint;
   xappname,n,v,vreuse,vcomment:string;
   xforcecmdok,xrun,bol1:boolean;
   //## xaddline ##
   procedure xaddline(x:string);
   begin
   case xforcecmdok of
   true:begin
      if (xout=nil) then xout:=str__new9;
      str__saddb(@xout,x+#10);
      end;
   false:app__writeln(x);
   end;//case
   end;
   //## h ##
   procedure h(x:string);//heading (underlined)
   begin
   x:='[ '+x+' ]';
   xaddline(x);
   xaddline(strcopy1b('-----------------------------',1,low__length(x)));
   end;
   //## m ##
   procedure m(x:string);//normal line
   begin
   xaddline(x);
   end;
   //## e ##
   procedure e(x:string);//example
   begin
   xaddline(#32+x);
   end;
   //## xenabled ##
   function xenabled(x:boolean):string;
   begin
   result:=low__aorbstr('Disabled','Enabled',x);
   end;
   //## xinstalled ##
   function xinstalled(x:boolean):string;
   begin
   result:=low__aorbstr('Not Installed','Installed',x);
   end;
   //## xpull ##
   function xpull:string;
   begin
   if (vreuse<>'') then
      begin
      result:=vreuse;
      vreuse:='';
      v:='';
      end
   else
      begin
      case xforcecmdok of
      true:begin
         result:=xforcecmd;//use once only
         xforcecmd:='';
         end;
      false:result:=low__param(xpos);
      end;//case
      inc(xpos);
      end;
   //legacy support
   if (strcopy1(result,1,1)='/') then result:='--'+strcopy1(result,2,low__length(result));
   end;
   //## vcheck ##
   procedure vcheck(xdef:string);
   begin
   //get
   v:=xpull;
   vcomment:='';
   //is the value a command
   if (strcopy1(v,1,1)='/') or (strcopy1(v,1,2)='--') then
      begin
      vreuse:=v;
      v:='';
      end;
   //use default value
   if (v='') and (xdef<>'') then
      begin
      vcomment:=' (default used)';
      v:=xdef;
      end;
   end;
   //## xinforow ##
   procedure xinforow(n,v:string);
   const
      xwidth='.........................';
   begin
   xaddline(n+#32+strcopy1b(xwidth,1,low__lengthb(xwidth)-low__length(n))+#32+v);
   end;
   //## vok ##
   procedure vok(xmsg,xvalue:string;xsavesettings:boolean);
   begin
   //save
   if xsavesettings then app__savesettings;
   //screen message
   if (xmsg<>'') then xinforow(xmsg,xvalue+vcomment);
   end;
   //## xhelp ##
   procedure xhelp(xname:string);
   var
      xbody:string;
      p:longint;
      //## e2 ##
      procedure e2(x:string);//example
      begin
      e(xappname+' --'+xname+x);
      end;
      //## e3 ##
      procedure e3(x:string);//example
      begin
      e(xappname+insstr(' --',x<>'')+x);
      end;
      //## xabout2 ##
      procedure xabout2(xdes,usage0,xusage,xrange:string;xexamples:boolean);//description
      begin
      xaddline('');
      xaddline('');
      h(xname);
      xaddline(strdefb(xdes,'This command does not exist. For complete help, type '+xappname+' --help'));
      if (xusage<>'') then
         begin
         xaddline('');
         xaddline('Usage:');
         xaddline(#32+xappname+' --'+xname+usage0+insstr(xusage,xusage<>'!'));
         end;
      if (xrange<>'') then
         begin
         xaddline('');
         xaddline('Range:');
         xaddline(#32+xrange);
         end;
      if xexamples then
         begin
         xaddline('');
         xaddline('Examples:');
         end;
      end;
      //## xabout ##
      procedure xabout(xdes,xusage,xrange:string;xexamples:boolean);//description
      begin
      xabout2(xdes,#32,xusage,xrange,xexamples);
      end;
   begin
   //init
   xname:=strlow(xname);
   xbody:='';
   //strip leading slash
   if (strcopy1(xname,1,2)='--') then strdel1(xname,1,2)
   else if (strcopy1(xname,1,1)='/') then strdel1(xname,1,1);//legacy support

   //body
   if (xname='filesize') then
      begin
      xabout('Set the maximum file size threshold. All files at or below this size are loaded into the RAM cache. '+
        'Larger files are streamed from disk when requested. '+'Set to 0 (zero) to load any file size into cache.',
        '<size in bytes>','0..'+low__b(imaxcachesize*1024000,true),true);
      e2(' 123,500');
      e2(' 1024000');
      e2(' 333');
      e2('');
      m('');
      m('Example 1 loads files of 123.5 KB or less into cache.  The second 1 MB or less.  The third to 333 bytes or less. And the fourth defaults to 10 MB.');
      end
   else if (xname='cachesize') then
      begin
      xabout('Set the maximum RAM Cache Size. The cache stores files for rapid access without disk lag. The cache expands upto this size to accomodate files. When the cache is full, or a file is too large, it''s left on disk and streamed out when requested.',
        '<size in MB (megabytes)>','10..'+k64(imaxcachesize),true);
      e2(' 50');
      e2(' 250');
      e2(' 1,500');
      e2('');
      m('');
      m('Example 1 sets RAM cache to use 50 MB. The second 250 MB.  The third to 1500 MB (1.5 GB). And the fourth defaults to 1200 MB (1.2 GB)');
      end
   else if (xname='quota') then
      begin
      xabout('Set the daily bandwidth quota. If the combined upstream (client -> server) and downstream (server -> client) bandwidth exceeds the quota limit, all traffic in and out of Bubbles is '+'suspended until midnight.  At midnight, daily bandwidth quota tracking begins afresh.',
        '<size in MB (megabytes)>','0=Disabled (no limit), 10..N Mb',true);
      e2(' 250');
      e2(' 1,000');
      e2(' 3,000,000');
      e2('');
      m('');
      m('Example 1 sets the daily bandwidth quota to 250 Mb. The second to 1 Gb (1,000 Mb).  The third to 3 Tb (3,000,000 Mb). And the fourth defaults to 0, which disables quota tracking and allows any amount of bandwidth.');
      end
   else if (xname='info') then
      begin
      xabout('Display basic settings in a easy to view summary.',
        '!','',false);
      end
   else if (xname='run') then
      begin
      xabout('Runs the server.',
        '!','',true);
      e3('port 80 --password abcde --run');
      e3('port 80 --password abcde --run --cachesize 1100');
      e3('run');
      e3('');
      m('');
      m('Example 1 sets port to 80, password to abcde, and then runs the server. The second does the same, but all commands after --run are ignored, --cachesize is never executed. Both 1 and 2 are examples of command stacking. Examples 3 and 4 run the server.');
      end
   else if (xname='port') then
      begin
      xabout('Set the broadcast port for the HTTP server.  Default is port '+inttostr(idefaultport)+'.',
        '<a number>','2..'+k64(maxport),true);
      e2(' 80');
      e2(' 1080');
      e2(' 2000');
      m('');
      m('Example 1 sets the port to 80, the standard port for http (insecure) web servers. The second sets it to broadcast on port 1080. And the third port 2000. Typically ports above 1024 require no special administration privileges.');
      end
   else if (xname='connections') then
      begin
      xabout('Set the maximum number of inbound connections.  Default is '+k64(idefaultconnections)+'.',
        '<a number>','10..'+k64(net__limit),true);
      e2(' 500');
      e2(' 3000');
      e2(' 4000');
      e2('');
      m('');
      m('Example 1 sets the maximum number of connections to 500. The second to 3,000. And the third to 4,000. The fourth defaults to '+k64(idefaultconnections)+'.');
      end
   else if (xname='password') then
      begin
      xabout('Set the web panel admin password. The default password is set to "'+idefaultpassword+'". We strongly recommend the password be changed to a strong/unique password before exposing the server to the internet.',
        '<a string of unique characters>','A minimum of 5 characters',true);
      e2(' 12345');
      e2(' Ajkd?t78%1_S');
      e2('');
      m('');
      m('Example 1 sets the password to "12345", a weak password. The second sets it to a strong password. And the third defaults to "'+idefaultpassword+'".');
      m('');
      m('Security Notice:');
      m('This web server supports the HTTP protcol, which does not encrypt data, consequently if you intend to use the web panel over the internet, we suggest you do so via a frontend server '+'like Caddy. Caddy supports HTTPS which encrypts all inbound/outbound data and will keep your password and admin session secure from hackers.');
      end
   else if (xname='power') then
      begin
      xabout('Set power level for CPU usage.  Default is '+k64(idefaultpower)+'.',
        '<a number>','0..'+k64(ipowerlimit),true);
      e2(' 1');
      e2(' 20');
      e2(' 30');
      e2(' 90');
      e2('');
      m('');
      m('Example 1 sets power level to 1%, which uses the least amount of CPU.  The second sets it to 20%. The third to 30%. The fourth to 90%. And the fifth defaults to '+k64(idefaultpower)+'%. The higher the power level, the more CPU the server uses for request processing and file streaming. Be aware, if the server '+'shares a single CPU/virtual core with another server like Caddy, then setting the power level too high may starve the other server of CPU cycles, and result in a '+'slower than expected request-response transaction. When run with admin privileges, e.g. as a service, the server automatically steps up to a higher thread priority.');
      end
   else if (xname='logs') then
      begin
      xabout('Set raw traffic logging.  Default is enabled.',
        '<a value, 0 or negative=disabled, 1 or higher=enabled>','',true);
      e2(' 1');
      e2(' 100');
      e2('');
      e2(' 0');
      e2(' -10');
      m('');
      m('Examples 1, 2 and 3 enable raw traffic logs. Examples 4 and 5 disable raw traffic logs. When raw traffic logs are enabled, all request activity on the server is recorded in a daily log file (*.txt) in the Logs '+'folder. Log files can be accessed from the Logs tab on the web panel.');
      end
   else if (xname='smtp') then
      begin
      xabout('Set SMTP (simple mail transport protocol) mode.  Default is disabled.',
        '<a value, 0 or negative=disabled, 1 or higher=enabled>','',true);
      e2(' 1');
      e2(' 100');
      e2(' 0');
      e2(' -10');
      e2('');
      m('');
      m('Examples 1 and 2 enable SMTP mode.  Examples 3, 4 and 5 disable SMTP. The mail port used is port 25. All inbound mail is unencrypted. Emails are stored in the Inbox folder as *.eml files. All mail (email and contact'+' form messages) are accessible from the Inbox tab of the web panel.');
      end
   else if (xname='live') then
      begin
      xabout('Set live stats mode (console window).  Default is enabled.',
        '<a value, 0 or negative=disabled, 1 or higher=enabled>','',true);
      e2(' 1');
      e2(' 100');
      e2('');
      e2(' 0');
      e2(' -10');
      m('');
      m('Examples 1, 2 and 3 enable live stats. Examples 4 and 5 disable live stats. When enabled, basic realtime information is rendered to the console window. This window can also be accessed anytime (even when live stats are disabled) '+'from the Console tab of the web panel.');
      end
   else if (xname='install') then
      begin
      xabout('Install Bubbles as a service.',
        '','',false);
      e2('');
      m('');
      m('Installs the server as a service with the following parameters:');
      m('Name: '+app__info('service.name'));
      m('Display Name: '+app__info('service.displayname'));
      m('Description: '+app__info('service.description'));
      end
   else if (xname='uninstall') then
      begin
      xabout('Uninstall Bubbles as a service.',
        '','',false);
      e2('');
      m('');
      m('Removes the server from the services list.');
      end
   else if (xname='commands') then
      begin
      xabout('List supported commands.',
        '!','',false);
      end
   else if (xname='help') then
      begin
      xabout2('Get help for a specific command.',':',
        '<command name>','',true);
      e2(':password');
      e2(':port');
      m('');
      m('Example 1 displays help for the Password command.  Example 2 for the Port command.');
      end
   else if (xname='rawhelp') then
      begin
      m('');
      m('');
      h('rawhelp');
      m('');
      m('Generate encoded version of help for Claude website builder.  Output can be piped (saved) to a text file.');
      m('');
      m('Example:');
      e3('rawhelp > 1.txt');
      end
   else if (xname='howto') then
      begin
      m('');
      m('');
      h('How To');
      m('');
      m('To list all help topics:');
      e3('help');
      m('');
      m('To list help for a specific command:');
      e3('help:<command name>');
      m('');
      m('An example for the port command:');
      e3('help:port');
      m('');
      m('Available commands:');
      for p:=0 to high(clist) do e(clist[p]);
      m('');
      m('Stacked commands:');
      m('Commands may be stacked in sequence, and are processed in left to right order.');
      m('');
      m('Examples:');
      e3('port 80 --password abcde --cachesize 1100 --filesize 500,000 --info');
      e3('port 80 --password abcde --cachesize 1100 --filesize 500,000 --info --run');
      e3('port 80 --password abcde --run --cachesize 1100 --filesize 500,000 --info');
      m('');
      m('Example 1 sets the HTTP broadcast port to 80, the password to abcde, cachesize to 1.1 GB, file size to 500 KB and finally lists an information summary. Example 2 performs the same operations, but the last command then instructs the server to run'+' and begin broadcasting. '+
        'Example 3 sets the port and password, then runs the server, ignoring all commands after --run.');
      end
   else
      begin
      xabout('','','',false);
      end;
   end;
   //## xadminrequired ##
   function xadminrequired:string;
   begin
   result:=insstr(' - Admin Level required',not app__adminlevel);
   end;
begin
//defaults
result:=true;
xrun:=false;
xout:=nil;
xoutput:='';

//init
xpos:=1;
vreuse:='';
vcomment:='';
xappname:=io__remlastext(io__extractfilename(io__exename));

//decide
xforcecmdok:=(xforcecmd<>'');

//get
try
redo:
n:=strlow(xpull);
nlen:=low__length(n);
if (nlen>=1) then result:=false;

if (nlen<=0) then goto skipend
else if (n='--password') then
   begin
   vcheck(idefaultpassword);
   if (low__length(v)>=5) then iadminkey:=xmakehash(v)
   else
      begin
      v:='<must be at least 5 characters>';
      end;
   vok('Password',v,true);
   end
else if (n='--port') then
   begin
   vcheck(inttostr(idefaultport));
   int1:=strint(v);
   if (int1<2) then int1:=idefaultport else int1:=frcrange32(int1,2,maxport);
   iport:=int1;
   vok('Port',inttostr(iport),true);
   end
else if (n='--smtp') then
   begin
   vcheck('0');
   imail_allow:=(strint(v)>=1);
   vok('SMTP (Port 25)',xenabled(imail_allow),true);
   end
else if (n='--power') then
   begin
   vcheck(k64(idefaultpower));
   ipowerlevel:=frcrange32(strint(v),1,ipowerlimit);
   vok('Power Level',k64(ipowerlevel)+'%',true);
   end
else if (n='--live') then
   begin
   vcheck('1');
   ilivestats:=(strint(v)>=1);
   vok('Live',xenabled(ilivestats),true);
   end
else if (n='--logs') then
   begin
   vcheck('1');
   irawlogs:=(strint(v)>=1);
   vok('Traffic Logs',xenabled(irawlogs),true);
   end
else if (n='--install') then
   begin
   bol1:=service__install(int1);
   vok('Install',low__aorbstr('Failed to install service ('+inttostr(int1)+')'+xadminrequired,'Service installed',bol1),true);
   end
else if (n='--uninstall') then
   begin
   bol1:=service__uninstall(int1);
   vok('Uninstall',low__aorbstr('Failed to uninstall service ('+inttostr(int1)+')'+xadminrequired,'Service uninstalled',bol1),true);
   end
else if (n='--connections') then
   begin
   vcheck(inttostr(idefaultconnections));
   iconnlimit:=frcrange32(strint(v),10,net__limit);
   vok('Connections',k64(iconnlimit),true);
   end
else if (n='--cachesize') then
   begin
   vcheck(inttostr(idefaultcachesize));
   iramlimit:=frcrange32(strint(v),10,imaxcachesize);
   vok('RAM Cache Size',low__mbauto(mult64(iramlimit,1000000),true),true);
   end
else if (n='--filesize') then
   begin
   vcheck(inttostr(idefaultthreshold));
   ithreshold:=frcrange32(strint(v),0,imaxcachesize*1024000);
   vok('Max. File Size to Cache',low__mbauto(ithreshold,true),true);
   end
else if (n='--quota') then
   begin
   vcheck('0');
   xsetdaily_bandwidth_quota(strint64(v));
   vok('Daily Bandwidth Quota',low__aorbstr('Disabled',low__mbauto(idaily_bandwidth_quota_bytes,true),idaily_bandwidth_quota_bytes>=1),true);
   end
else if (n='--info') then
   begin
   xaddline('');
   xaddline('--- Bubbles Information ---');
   xinforow('Version',app__info('ver'));
   xinforow('EXE Size',app__info('size'));
   xinforow('Password',low__aorbstr('<Unique Password>','<Default Password>',iadminkey=xmakehash(idefaultpassword)));
   xinforow('Connections',k64(iconnlimit));
   xinforow('Port',inttostr(iport));
   xinforow('SMTP (Port 25)',xenabled(imail_allow));
   xinforow('RAM Cache Size',low__mbauto(mult64(iramlimit,1000000),true));
   xinforow('Max. File Size to Cache',low__mbauto(ithreshold,true));
   xinforow('Daily Bandwidth Quota',low__aorbstr('Disabled',low__mbauto(idaily_bandwidth_quota_bytes,true),idaily_bandwidth_quota_bytes>=1));
   xinforow('Power Level',k64(ipowerlevel)+'%');
   xinforow('Traffic Logs',xenabled(irawlogs));
   xinforow('Live Stats',xenabled(ilivestats));
   xinforow('Web Panel','http://localhost:'+inttostr(iport)+iadminpath);
   end
else if (n='--commands') then
   begin
   m('');
   m('');
   h('Supported Commands');
   for p:=0 to high(clist) do m(clist[p]);
   end
else if (n='--howto') then xhelp(n)

else if (n='--help:')                         then xaddline('Command name expected. Format should be "--help:<command name>"')
else if (strcopy1(n,1,7)='--help:')           then xhelp(strcopy1(n,8,low__length(n)))
else if (n='--help') then
   begin
   for p:=0 to high(clist) do xhelp(clist[p]);
   end

else if (n='--rawhelp') then
   begin
   xaddline(xmakehelp(true));
   end

else if (n='--run') then
   begin
   xrun:=true;
   goto skipend;
   end
else
   begin
   vcheck('');
   xaddline('Unknown command "'+n+'".  Need help?  Type '+xappname+' --help');
   end;

//.loop
goto redo;

skipend:
//.run
if xrun then result:=true;
except;end;
try
if (xout<>nil) then xoutput:=str__text(@xout);
str__free(@xout);
except;end;
end;
//## xmakehitspng ##
function xmakehitspng(x:tstr8;xhits:comp):boolean;//make "hits.png" image
label
   skipend;
const
   dheightscale=2.5;
   dfontsize=12;
   dbold=true;
var
   a:tbasicimage;
   e,str1:string;
   bcolor,dcolor,hpad,vpad,int2,int1,aw,ah:longint;
begin
//defaults
result:=false;
try
a:=nil;
hpad:=8;
vpad:=4;

//check
if not str__lock(@x) then exit;

//range
xhits:=frcrange64(xhits,0,max64);

//init
a:=misimg32(1,1);
bcolor:=low__rgb(0,0,0);
dcolor:=low__rgb(255,255,255);

//calculate dimensions required
str1:=intstr64(xhits);
mis__drawdigits2(a,misarea(a),hpad,vpad,dfontsize,dcolor,dheightscale,str1,dbold,false,aw,ah);
inc(aw,2*hpad);
inc(ah,2*vpad);
missize(a,aw,ah);

//draw background color
misclsarea2(a,low__rect(0,0,aw-1,ah-1),bcolor,bcolor);

//draw text without using system graphics support
mis__drawdigits2(a,misarea(a),hpad,vpad,dfontsize,dcolor,dheightscale,str1,dbold,true,int1,int2);

//make text transparent and background slightly transparent
mask__copy3(a,a,dcolor,220);

//write to io stream
if not mistopng82432(a,clnone,-1,0,false,x,e) then goto skipend;

//successful
result:=true;
skipend:
except;end;
try
str__uaf(@x);
freeobj(@a);
except;end;
end;
//## xinchit ##
procedure xinchit(xdiskhost:string);
begin
try
imustmakepngs:=true;//triggers ".hits.png" to update
ihitmustsave:=true;//trigers "hits.ini" to be written to disk
ihit.cinc(xdiskhost);
ihitpng.b['mustupdate.'+xdiskhost]:=true;
except;end;
end;
//## xmakepngs ##
procedure xmakepngs(xforce:boolean);//make all "hits.png" for listed disk domains "idom"
var
   b:tstr8;
   p,xlen:longint;
   st,ht:comp;
   n:string;
   //## xmakepng ##
   procedure xmakepng(n:string;st:comp);
   begin
   try
   //total ALWAYS updates and DISK DOMAIN only if xfore or mustupdate
   if strmatch(n,'total') or ( strmatch(strcopy1(n,1,xlen),idefaultdisksite) and (xforce or ihitpng.b['mustupdate.'+n]) ) then
      begin
      ihitpng.b['mustupdate.'+n]:=false;
      xmakehitspng(b,st);
      ihitpng.s[n]:=b.text;
      end;
   except;end;
   end;
begin
try
//defaults
b:=nil;
//check
if (not imustmakepngs) and (not xforce) then exit else imustmakepngs:=false;
//init
xlen:=low__lengthb(idefaultdisksite);
b:=str__new8;
ht:=0;

//make disk domains
for p:=0 to (idom.count-1) do
begin
n:=strlow(idom.n[p]);
if (n<>'total') then
   begin
   st:=frcmin64(ihit.c[n],0);
   ht:=add64(ht,st);
   xmakepng(n,st);
   end;
end;
//make "total"
ihit.c['total']:=ht;
xmakepng('total',ht);
except;end;
try;str__free(@b);except;end;
end;
//## xresolvehost ##
procedure xresolvehost(m:tnetbasic);//use mapping
label
   redo;
var
   int3,xcount,v,p:longint;
   xhost,str1:string;
   xfirst:boolean;
   //## xcleanhost ##
   function xcleanhost(var x:string):boolean;
   var
      p,v:byte;
   begin
   //pass-thru
   result:=true;
   try

   //strip leading "http://" or "https://" for proxy connections
   if (x<>'') and strmatch(strcopy1(x,1,7),'http://') then strdel1(x,1,7);

   //strip leading "http://" or "https://" for proxy connections
   if strmatch(strcopy1(x,1,8),'https://') then strdel1(x,1,8);

   //strip leading "www."
   if strmatch(strcopy1(x,1,4),'www.') then strdel1(x,1,4);

   //strip everything AFTER first colon ":" or slash "/" -> skip over IPv6 addresses embedded within bracket [...] pair
   if (x<>'') then
      begin
      int3:=0;
      for p:=1 to low__length(x) do
      begin
      v:=byte(x[p-1+stroffset]);
      if (v=ssLSquareBracket) then inc(int3)
      else if (v=ssRSquareBracket) then dec(int3);

      if ((v=ssColon) or (v=ssSlash)) and (int3=0) then
         begin
         x:=strcopy1(x,1,p-1);
         break;
         end;
      end;//p
      end;
   except;end;
   end;
begin
try
//check
if (m=nil) then exit;
//init
xfirst:=true;
xhost:=m.hhost;
xcount:=10;

redo:

//clean host
xcleanhost(xhost);

//xfirst
if xfirst then
   begin
   xfirst:=false;
   m.hhost:=xhost;
   m.hdesthost:=xhost;
   end;

//domain map
if imap.sfound(xhost,str1) and (str1<>'') and xcleanhost(str1) and (str1<>'') and (not strmatch(xhost,str1)) then
   begin
   xhost:=str1;
   dec(xcount);
   //.revert to original host if too many lookups OR we're caught in a cyclic loop -> predictable failure point - 25dec2023
   if (xcount<0) then xhost:='' else goto redo;
   end;

//set hdesthost field
if (xhost<>'') then m.hdesthost:=xhost;

//swap "." with "_" to make it into a disk domain
if (xhost<>'') then
   begin
   for p:=1 to low__length(xhost) do
   begin
   v:=byte(xhost[p-1+stroffset]);
   if (v=ssDot) then xhost[p-1+stroffset]:='_';
   end;//p
   end;

//enforce leading "www_"
xhost:=idefaultdisksite+xhost;


//check diskhost matches -> ensures against ilegal disk domains
if idom.found(xhost) then m.hdiskhost:=xhost else m.hdiskhost:=idefaultdisksite;
except;end;
end;
//## xextractsessionname ##
function xextractsessionname(xpath:string;var xname:string):boolean;
var
   xcount,xlen,lp,v,p:longint;
begin
//defaults
result:=false;
try
xname:='';
//check
if (xpath='') then exit;
//get
xlen:=low__length(xpath);
xcount:=0;
lp:=xlen;
for p:=xlen downto 1 do
begin
v:=byte(xpath[p-1+stroffset]);
if (v=ssSlash) then
   begin
   inc(xcount);
   if (xcount>=2) then
      begin
      xname:=strcopy1(xpath,p+1,lp-p-1);
      result:=(low__length(xname)=isessionnameLEN);
      break;
      end;
   lp:=p;
   end;
end;//p
except;end;
end;
//## xpassword_ok ##
function xpassword_ok(xpassword:string):boolean;
begin
result:=false;try;result:=(xmakehash(xpassword)=iadminkey);except;end;
end;
//## xnewsession ##
function xnewsession(xpassword,xuseragent:string;var xsessionname,xsessioncookie:string;var xindex:longint):boolean;
var
   i,p:longint;
   xmost:comp;
begin
//defaults
result:=false;

try
xindex:=0;
i:=-1;

//passkey check
if not xpassword_ok(xpassword) then exit;

{
//find existing -> prevent multiple same requests (e.g. when cookie failure occurs on client browser and locks in a login -> redirect -> login loop) - 27mar2024
for p:=0 to high(isessiontime) do if (isessiontime[p]<>0) and strmatch(isessionua[p],xuseragent) then
   begin
   xindex:=p;
   isessiontime[p]:=ms64;//more time
   xsessionname:=isessionname[p];
   xsessioncookie:=isessioncookie[p];
   //successful
   result:=true;
   exit;
   end;
{}

//new
for p:=0 to high(isessiontime) do if (isessiontime[p]=0) then
   begin
   i:=p;
   inc(isessioncount);
   break;
   end;
//oldest
if (i<0) then
   begin
   xmost:=max64;
   for p:=0 to high(isessiontime) do if (isessiontime[p]>=1) and (isessiontime[p]<xmost) then
      begin
      xmost:=isessiontime[p];
      i:=p;
      end;
   end;
//set
if (i>=0) then
   begin
   //get
   xindex:=i;
   //.create random session name = 100c => "a..z" lowercase
   xsessionname:='';
   for p:=1 to isessionnameLEN do xsessionname:=xsessionname+char(lla+random(26));
   //.create random session cookie = 100c => "a..z" lowercase
   xsessioncookie:='';
   for p:=1 to isessionnameLEN do xsessioncookie:=xsessioncookie+char(lla+random(26));
   //set
   isessiontime[i]:=ms64;
   isessionname[i]:=xsessionname;
   isessioncookie[i]:=xsessioncookie;//11mar2024
   isessioncookietime[i]:=0;
   isessionua[i]:=xuseragent;
   //successful
   result:=true;
   end;
except;end;
end;
//## xsessionok ##
function xsessionok(xsessionname,xsessioncookie,xuseragent,xip,xadminpage:string;var xindex:longint):boolean;
var//4 matches performed to permit access: sessionname -> user-agent -> ip -> cookiename
   p:longint;
begin
//defaults
result:=false;
xindex:=0;

try
//check
if (low__length(xsessionname)<>isessionnameLEN) then exit;
//find
for p:=0 to high(isessiontime) do if (isessiontime[p]<>0) and (isessionname[p]<>'') and strmatch(xsessionname,isessionname[p]) then
   begin
   if (sub64(ms64,isessiontime[p])<=isessiontimeout) then
      begin
      case strmatch(xuseragent,isessionua[p]) of
      true:begin
         result:=strmatch(xsessioncookie,isessioncookie[p]);
         //xindex and update time var - 23apr2024
         if result then
            begin
            xindex:=p;
            isessiontime[p]:=ms64;
            end;
         end;
      false:begin
         xwritemsg('Bubbles - Security  Notice',
         'A device attempted to use an active admin session key, and as a precaution, Bubbles terminated the session.'+#10+#10+
         'IP Address: '+xip+#10+
         'User-Agent: '+xuseragent+#10+
         'Cookie: '+xsessioncookie+#10+
         'Admin-Page: '+xadminpage+#10+
         #10+
         'This is a security notice sent by Bubbles.'+
         '');
         xsessiondel(xsessionname);
         end;
      end;//case
      end;
   break;
   end;
except;end;
end;
//## xsessiondel ##
function xsessiondel(xsessionname:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//check
if (low__length(xsessionname)<>isessionnameLEN) then exit;
//find
for p:=0 to high(isessiontime) do if (isessiontime[p]<>0) and (isessionname[p]<>'') and strmatch(xsessionname,isessionname[p]) then
   begin
   isessiontime[p]:=0;
   isessioncookietime[p]:=0;
   isessioncookie[p]:='';
   isessionname[p]:='';
   isessionua[p]:='';
   isessioncount:=frcmin32(isessioncount-1,0);
   result:=true;
   break;
   end;
except;end;
end;
//## xsessiondelall ##
procedure xsessiondelall;
var
   p:longint;
begin
try
for p:=0 to high(isessiontime) do
begin
isessiontime[p]:=0;
isessioncookietime[p]:=0;
isessionname[p]:='';
isessioncookie[p]:='';
isessionua[p]:='';
end;//p
isessioncount:=0;
except;end;
end;
//## xstrcopyto ##
function xstrcopyto(x:string;xto:char):string;
var
   p:longint;
begin
result:='';

try
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__length(x) do if (x[p-1+stroffset]=xto) then
      begin
      result:=strcopy1(result,1,p-1);
      break;
      end;
   end;
except;end;
end;
//## xforce_backslash ##
function xforce_backslash(x:string):string;
var
   p:longint;
begin
result:='';

try
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__length(result) do if (result[p-1+stroffset]='/') then result[p-1+stroffset]:='\';
   end;
except;end;
end;
//## xforce_slash ##
function xforce_slash(x:string):string;
var
   p:longint;
begin
result:='';

try
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__length(result) do if (result[p-1+stroffset]='\') then result[p-1+stroffset]:='/';
   end;
except;end;
end;
//## xdomfiles ##
function xdomfiles(n:string):longint;
begin
result:=0;try;result:=idominfo.i['files.'+n];except;end;
end;
//## xdombytes ##
function xdombytes(n:string):comp;
begin
result:=0;try;result:=idominfo.c['bytes.'+n];except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//1111111111111111111111111111
//## xaddfiletoram ##
function xaddfiletoram(var xfolder:string;var xrec:tsearchrec;var xsize:comp;var xdate:tdatetime;xisfile,xisfolder:boolean;xhelper:tobject):boolean;
var
   xoldmode,i:longint;
   xname:string;
   xnew,xmustreloadfile:boolean;
   xsize8:comp;
begin
result:=true;

try
if xisfile and (xrec.name<>'') then
   begin
   //xname
   xname:=xforce_slash(strcopy1(xfolder,low__length(ifastfolder__root)+1,low__length(xfolder))+xrec.name);//e.g. "www_blaizenterprises_com/index.html"
   //set
   if xramnewslot(xname,i,xnew) then
      begin
      xoldmode:=imode.value[i];
      xmustreloadfile:=xnew or (isize.value[i]<>xsize) or (idate.value[i]<>xdate);
      isize.value[i]:=xsize;
      idate.value[i]:=xdate;

      //.data
      if (i>=idata.count) then idata.value[i]:=nil;//creates slot but does not create a tstr9 object

      //.predict memory usage (more than file size as we're bounded by memory blocks)
      xsize8:=idata.value[i].mem_predict(xsize);

      //.mode
      imode.value[i]:=low__aorb(wsmRAM,wsmDisk, (xsize>ithreshold) or (add64(xsize8,ireload_rambytes)>ireload_ramlimit) );
      idomindex.value[i]:=ireload_domindex;

      //.inc file counters
      inc(iramfilecount);
      if (imode.value[i]=wsmRAM) then
         begin
         ihave.value[i]:=low__aorb(1,2, xmustreloadfile or (xoldmode<>wsmRAM) );
         inc(iramfilescached);
         ireload_rambytes:=add64(ireload_rambytes,xsize8);
         end
      else
         begin
         ihave.value[i]:=1;
         if (idata.value[i]<>nil) then idata.value[i].clear;//remove existing data from RAM cache
         end;
      end;
   end;
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//111111111111111111111111
//## xreload ##
function xreload(xboot:boolean):boolean;//01may2024: optimised for fast reload
label
   skipend;
var
   int1,xstyle,xtep,xcount,p:longint;
   xsize:comp;
   xnav:tstr8;
   str1,xname,xlabel,xroot,e:string;
   xref,c:comp;
begin
//defaults
result:=false;

ireload_rambytes:=0;
ireload_ramlimit:=mult64(iramlimit,1024000);
irambytes:=0;
iramfilescached:=0;
iramfilecount:=0;
nil__1(@xnav);

try
//init
low__iroll(iramid,1);
iramdate:=now;
iramgmt:=igmtstr;
imustcloseall:=true;//flush all connections -> files might be of a different size etc
if not ilivestats then scn__writeln('Loading files...');
xnav:=str__new8;


//clear
idom.clear;
idominfo.clear;
if (ihave.count>=1) then for p:=(ihave.count-1) downto 0 do ihave.items[p]:=0;


//ensure default folder "www_" exists -> this is the "catch all" disk domain -> a request maps to this when a domain can't be found
xroot:=app__subfolder2('',ialongsideexe);
app__subfolder2(idefaultdisksite,ialongsideexe);
idom.b[idefaultdisksite]:=true;//include the default even if folder fails to create


//fast folder references
ifastfolder__root          :=xroot;
ifastfolder__logs          :=app__subfolder2('logs',ialongsideexe);
ifastfolder__inbox         :=app__subfolder2('inbox',ialongsideexe);
ifastfolder__inbox_read    :=app__subfolder2('inbox\read',ialongsideexe);
ifastfolder__trash         :=app__subfolder2('trash',ialongsideexe);
ifastfolder__trash_read    :=app__subfolder2('trash\read',ialongsideexe);


//get list of disk domains (folders in root folder starting with "www_", e.g. "www_blaizenterprise_com"
if not nav__init(xnav) then goto skipend;
if not nav__list(xnav,nlName,xroot,idefaultdisksite+'*','',false,true,false) then goto skipend;
xcount:=nav__count(xnav);
if (xcount>=1) then
   begin
   for p:=0 to (xcount-1) do
   begin
   if nav__get(xnav,p,xstyle,xtep,xsize,xname,xlabel) and strmatch(strcopy1(xname,1,low__lengthb(idefaultdisksite)),idefaultdisksite) then idom.b[xname]:=true;
   end;//p
   end;


//.uses "idom"
xredirect__clean('');


//load file structure of each dom entry (e.g. rootfolder\www_ and rootfolder\www_blaizenterprises_com\) BUT load actual file contents into RAM later on - 01may2024
msset(xref,500);
for p:=0 to (idom.count-1) do
begin
ireload_domindex:=p;
int1:=iramfilecount;
io__filelist3(io__asfolder(xroot+idom.n[p]),'*','',true,false,true,nil,xaddfiletoram,nil);//proc "xaddfiletoram()" does the actual file loading into RAM - 23feb2024
idominfo.i['files.'+idom.n[p]]:=iramfilecount-int1;
end;//p


//delete unused/non-existent files
if (iramcount>=1) then
   begin
   for p:=(iramcount-1) downto 0 do if (ihave.items[p]=0) then
      begin
      inref1.items[p]:=0;//nref1=0 and nref2=0 marks the entry as FREE (not used)
      inref2.items[p]:=0;
      iname.items[p]^:='';
      if (idata.value[p]<>nil) then idata.value[p].clear;
      isize.items[p]:=0;
      idate.items[p]:=0;
      imode.items[p]:=wsmDisk;
      idomindex.items[p]:=0;
      end;//p
   end;


//load file contents
msset(xref,500);
if (iramcount>=1) then
   begin
   for p:=0 to (iramcount-1) do if ((inref1.items[p]<>0) or (inref2.items[p]<>0)) and (imode.items[p]=wsmRAM) then
      begin
      //reload file contents into RAM cache
      if (ihave.items[p]>=2) and (not io__fromfile64(ifastfolder__root+swapcharsb(iname.items[p]^,'/','\'),cache__ptr(idata.value[p]),e)) then
         begin
         if (idata.value[p]<>nil) then idata.value[p].clear;
         isize.value[p]:=0;
         end;
      //get
      c:=idata.value[p].mem;
      irambytes:=add64(irambytes,c);
      idominfo.c['bytes.'+idom.n[idomindex.items[p]]]:=add64(idominfo.c['bytes.'+idom.n[idomindex.items[p]]],c);
      //show status
      if msok(xref) then
         begin
         app__paintnow;
         msset(xref,500);
         end;
      end;//p
   end;//if

//.total
idominfo.i['files.total']:=iramfilecount;
idominfo.c['bytes.total']:=irambytes;

//successful
result:=true;
skipend:
if not ilivestats then scn__writeln(low__aorbstr('Failed','Loading done.',result));
except;end;
try
//.write msg to inbox
if ireloadnotice then
   begin
   str1:=#10+#10+'This is a security notice sent by Bubbles.';
   case xboot of
   false:xwritemsg('Bubbles - Reload Notice','Disk sites reloaded due to admin panel request.'+str1);
   true:xwritemsg('Bubbles - Boot Notice','Disk sites loaded due to boot/reboot.'+str1);
   end;//case
   end;
//.free
free__1(@xnav);
//.make "hits.png" for each disk domain
xmakepngs(true);
except;end;
end;
//## xmakehash ##
function xmakehash(x:string):string;
var
   e:string;
   s,d:tstr8;
begin
//defaults
result:='';

try
s:=nil;
d:=nil;
//get
s:=str__new8;
d:=str__new8;
s.text:=x;
s.text:=intstr64(low__ref256(x))+'_'+intstr64(low__crc32nonzero(s));
low__tob64(s,d,0,e);
result:=d.text;
except;end;
try
str__free(@s);
str__free(@d);
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//555555555555555555
//## xramnewslot ##
function xramnewslot(xname:string;var xslot:longint;var xnew:boolean):boolean;
var
   p:longint;
   c:tcmp8;
begin
//defaults
result:=false;
xslot:=0;
xnew:=false;

//check
if (xname='') then exit;

//init
c.val:=low__ref256U(xname);

try
//find existing
if (not result) and (iramcount>=1) then
   begin
   for p:=0 to (iramcount-1) do if (inref1.items[p]=c.ints[0]) and (inref2.items[p]=c.ints[1]) and strmatch(iname.items[p]^,xname) then
      begin
      xslot:=p;
      result:=true;
      break;
      end;//p
   end;

//find free
if (not result) and (iramcount>=1) then
   begin
   for p:=0 to (iramcount-1) do if (inref1.items[p]=0) and (inref2.items[p]=0) then
      begin
      xslot:=p;
      inref1.value[xslot]:=c.ints[0];
      inref2.value[xslot]:=c.ints[1];
      iname.value[xslot]:=xname;
      xnew:=true;
      result:=true;
      break;
      end;//p
   end;

//create new
if (not result) then
   begin
   xslot:=iramcount;
   inref1.value[xslot]:=c.ints[0];
   inref2.value[xslot]:=c.ints[1];
   iname.value[xslot]:=xname;
   xnew:=true;
   result:=true;
   inc(iramcount);
   end;
except;end;
end;
//## xramfind ##
function xramfind(m:tnetbasic):boolean;
var
   c:tcmp8;
   p:longint;
begin
//defaults
result:=false;

try
//check
if (m=nil) or (iramcount<=0) or (m.wfilename='') then exit;
//get
c.val:=low__ref256U(m.wfilename);
for p:=0 to (iramcount-1) do
begin
if (inref1.items[p]=c.ints[0]) and (inref2.items[p]=c.ints[1]) and strmatch(m.wfilename,iname.items[p]^) then
   begin
   //get
   m.wramindex:=p;
   //mode change -> this file is listed in RAM but not cached in RAM, so we need to switch to disk streaming - 31dec2023
   if (imode.value[p]=wsmDisk) then
      begin
      m.wfilename:=ifastfolder__root+xforce_backslash(m.wfilename);//convert webname to diskname "/..../..." to "\....\..." - 26feb2024
      m.wmode:=wsmDisk;
      end;
   //successful
   result:=true;
   break;
   end;
end;//p
except;end;
end;
//## xfilename ##
function xfileinram(xfilename:string):boolean;
var
   c:tcmp8;
   p:longint;
begin
//defaults
result:=false;

try
//check
if (xfilename='') or (iramcount<=0) then exit;

//init
if strmatch(ifastfolder__root,strcopy1(xfilename,1,low__length(ifastfolder__root))) then strdel1(xfilename,1,low__length(ifastfolder__root));
xfilename:=xforce_slash(xfilename);

//get
c.val:=low__ref256U(xfilename);
for p:=0 to (iramcount-1) do
begin
if (inref1.items[p]=c.ints[0]) and (inref2.items[p]=c.ints[1]) and strmatch(xfilename,iname.items[p]^) then
   begin
   result:=(imode.items[p]=wsmRAM);
   break;
   end;
end;//p
except;end;
end;
//## xfromfile64 ##
function xfromfile64(m:tnetbasic;xfrom:comp;var xfilesize:comp;var xfiledate:tdatetime;xchunksize:longint;xfirst,xmustbuffer:boolean):boolean;
label
   redo,skipend;
var
   e:string;
begin
//defaults
result:=false;

try
xfilesize:=0;
xfiledate:=0;

//check
if (m=nil) or (xfirst and (m.wfilename='')) or (xfrom<0) then goto skipend;

//get
redo:
case m.wmode of
wsmDisk:begin//append to existing stream buffer
   if (m.buf<>nil) then result:=io__fromfile64c(m.wfilename,@m.buf,true,e,xfilesize,xfrom,xchunksize,xfiledate) else result:=true;
   end;
wsmRAM:begin
   //find
   if xfirst and (not xramfind(m)) then goto skipend;
   //mode change
   if (m.wmode=wsmDisk) then goto redo;
   //set
   xfilesize:=isize.value[m.wramindex];
   xfiledate:=idate.value[m.wramindex];
   if (xchunksize>=1) then
      begin
      if str__splice(cache__ptr(idata.value[m.wramindex]),restrict32(xfrom),restrict32(xchunksize),m.splicemem,m.splicelen) then result:=(m.splicelen>=1);
      if xmustbuffer and (m.buf<>nil) then str__add3(@m.buf,cache__ptr(idata.value[m.wramindex]),restrict32(xfrom),restrict32(xchunksize));
      end
   else
      begin
      m.splicelen:=0;
      m.splicemem:=nil;
      result:=true;
      end;
   end;
end;

skipend:
except;end;
end;
//## xstreamstart ##
function xstreamstart(var a:pnetwork;wmode:longint;xfilename:string;xcancache:boolean):boolean;
label//Note: xfilename optional
   doNormal,skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   wmax,xsize:comp;
   xdate:tdatetime;
   p,vlen,xcode:longint;
   v2,v:string;
   xcontactok,xrangeok:boolean;
begin
//defaults
result:=true;//pass-thru

try
xrangeok:=false;

//check
if not net__recinfo(a,m,buf) then exit;

//init
xcode:=200;
m.wmode:=wmode;
m.wfilename:=xfilename;
xcontactok:=strmatch(m.hname,'contact.html');
//.reset the buffer
str__softclear2(buf,ibufferlimit);


//decide
if (m.hrange='') or xcontactok then goto doNormal;


//do range (partial download request) ------------------------------------------
//404
if not xfromfile64(m,m.wfrom,xsize,xdate,0,true,false) then//read no data
   begin
   if header__make4(a,404,true,false,false) then goto skipend;
   end;

//etag match -> if it fails return 412
if (m.hif_match<>'') and (m.hif_match<>low__makeetag(xdate)) then
   begin
   header__make3(a,412,true,0,xdate,xcancache,false,'');
   m.writing:=true;
   goto skipend;
   end;

//set vars
m.wfilesize:=xsize;
m.wfiledate:=xdate;
wmax:=sub64(m.wfilesize,1);

//empty file -> can't transfer 0 bytes
if (wmax<0) then goto donormal;

//partial download being requested -> "Range: bytes=0-499" where m.hrange holds for example the value "bytes=0-499"
if (m.hrange<>'') and strmatch(strcopy1(m.hrange,1,6),'bytes=') then
   begin
   v:=xstrcopyto(strcopy1(m.hrange,7,low__length(m.hrange)),',');//read only the first section, ignore the rest
   vlen:=low__length(v);
   if (vlen>=2) then
      begin
      for p:=1 to vlen do if (v[p-1+stroffset]='-') then
         begin
         //get
         v2:=strcopy1(v,p+1,vlen);
         //.from
         m.wfrom:=frcrange64(strint64(strcopy1(v,1,p-1)),0,wmax);
         //.to
         if (v2='') then m.wto:=wmax else m.wto:=frcrange64(strint64(v2),0,wmax);
         //.check
         if (m.wfrom>=0) and (m.wto>=0) and (m.wto>=m.wfrom) then xrangeok:=true;//OK
         //.done
         break;
         end;
      end;
   end;

//check
if not xrangeok then goto donormal;

//if ETAG or GMT DATE comparison check -> if changed -> default to normal and FULL download
if (m.hif_range<>'') and ( (not strmatch(m.hif_range,low__makeetag(xdate))) and (not strmatch(m.hif_range,low__gmt(m.wfiledate))) ) then goto donormal;

//get partial data
//404
if not xfromfile64(m,m.wfrom,xsize,xdate,restrict32(low__inscmp(frcmax64(add64(sub64(m.wto,m.wfrom),1),ichunksize),m.hwantdata)),true,false) then
   begin
   if header__make4(a,404,true,false,false) then goto skipend;
   end;

//.make the 206 Partial Content Header
header__make206(a,m.wfrom,m.wto,m.wfilesize,m.wfiledate,xcancache);
m.writing:=true;
goto skipend;


// normal streaming ------------------------------------------------------------
doNormal:
//404
if not xfromfile64(m,0,xsize,xdate,0,true,false) then//read no data -> just getting info
   begin
   if header__make4(a,404,true,false,false) then goto skipend;
   end;

//dynamic page: adjust key vars and compile out data into "ibuf2"
if xcontactok then
   begin
   xfromfile64(m,0,xsize,xdate,maxint,true,true);//must buffer "contact.html" so we can edit it on-the-fly - 25feb2024
   xcontact_html(a);
   str__clear(@ibuf2);
   str__add(@ibuf2,buf);
   str__clear(buf);
   xsize:=str__len(@ibuf2);
   xdate:=now;
   xcancache:=false;
   end;

//set vars
m.wfilesize:=xsize;
m.wfiledate:=xdate;
m.wfrom:=0;
m.wto:=sub64(xsize,1);
header__make3(a,xcode,true,xsize,xdate,xcancache,false,'');
m.writing:=true;

//dynamic page part 2: append data to buf which already has the header
if xcontactok then
   begin
   str__add(buf,@ibuf2);
   str__clear(@ibuf2);
   m.wmode:=wsmBuf;
   end;

skipend:
except;end;
end;
//## xstreammore ##
function xstreammore(var a:pnetwork;var xdataproblem,xdone:boolean):boolean;
label//xdataproblem=true => when the file has changed or does not exist -> this may occur if a client is downloading a large file slowly and the site is reloaded by the admin panel with a new version of the file, the download stream "content-length" cannot be updated (at front of stream) -> so best to close the connection EVEN in reverse proxy mode - 04jan2024
   skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   xrem,xsize,xpos:comp;
   xdate:tdatetime;
   xchunksize:longint;
begin
//defaults
result:=true;//pass-thru

try
xdone:=false;
xdataproblem:=false;
//check
if not net__recinfo(a,m,buf) then exit;
if not m.hwantdata then exit;

//get
if (m.wmode=wsmDisk) or (m.wmode=wsmRAM) then
   begin
   //init
   xpos:=add64(m.wfrom,sub64(m.wsent,m.wheadlen));//negative value means we're still sending the header
   xrem:=frcmin64(sub64(m.wlen,m.wsent),0);
   xchunksize:=restrict32(frcmax64(xrem,ichunksize));

   //clear
   m.wbufsent:=0;
   str__softclear2(buf,ibufferlimit);//faster - 23feb2024
   //get data
   if (xpos>=0) then
      begin
      //finished
      if (xrem<=0) then
         begin
         xdone:=true;
         goto skipend;
         end;

      //stream more
      if not xfromfile64(m,xpos,xsize,xdate,xchunksize,false,false) then
         begin
         //file did exist, but now it doesn't
         xdataproblem:=true;
         goto skipend;
         end;

      //check date and size of file is the same as when the stream was started
      if (m.wfilesize<>xsize) or (m.wfiledate<>xdate) then
         begin
         xdataproblem:=true;
         goto skipend;
         end;
      end;
   end;

skipend:
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxx//999999999999999999999999999999
//## xwritemsg ##
procedure xwritemsg(xsubject,xmsg:string);
var
   b:tstr9;
   e:string;
begin
try
//defaults
b:=nil;
//init
b:=str__new9;
//get
strdef(xsubject,'(no subject)');
strdef(xmsg,'(no message)');
//set
if mail__makemsg(@b,'127.0.0.1','','inbox@localhost',xsubject,xmsg,now,e) then mail__writemsg(@b,xsubject,io__makefolder2(ifastfolder__inbox));
except;end;
try;str__free(@b);except;end;
end;
//## xendofday ##
procedure xendofday;
var
   h,min,s,ms:word;
   xmsg:string;
begin
try
//other
low__decodetime2(now,h,min,s,ms);
case h of
0:if not iendofdaydone then//once per day only
   begin
   //init
   iendofdaydone:=true;
   xmsg:=xdailysummary(true)+#10+'This is an information notice sent by Bubbles.';
   //get
   if isummarynotice then xwritemsg('Bubbles - Daily Summary',xmsg);

   //reset daily bandwidth counter & state
   idaily_bandwidth:=0;//resets daily bandwidth counter
   idaily_bandwidth_exceeded:=false;
   end;
else iendofdaydone:=false;//reset
end;
except;end;
end;
//## xdailysummary ##
function xdailysummary(xreset:boolean):string;
const
   hline='------------------------------------------------------------';
var
   a:tstr9;
   n:string;
   ht,bt,h,b:comp;
   p:longint;
   //## ladd ##
   procedure ladd(xhits,xbandwidth,xsite:string);
   const
      xcol='               ';
     //## dcol ##
     function dcol(x:string;xright:boolean):string;
     var
        rlen,xlen:longint;
     begin
     try
     //defaults
     result:=x;
     rlen:=low__length(result);
     xlen:=low__lengthb(xcol);
     //align
     if xright and (rlen<xlen) then result:=strcopy1b(xcol,1,xlen-rlen)+result;
     except;end;
     end;
   begin
   try
   //range
   xsite:=strdefb(xsite,'-');
   //get
   a.saddb(dcol(xhits,true)+dcol(xbandwidth,true)+strcopy1b(xcol,1,5)+xsite+#10);
   except;end;
   end;
begin
//defaults
result:='';

try
a:=nil;

//init
a:=str__new9;

//get
a.saddb('Bubbles - Daily Summary ('+low__gmt(now)+')'+#10#10#10);

ladd('Hits','Bandwidth','Disk Site');
a.saddb(hline+#10);

if (idom.count>=1) then
   begin
   ht:=0;
   bt:=0;
   for p:=0 to (idom.count-1) do
   begin
   n:=idom.n[p];
   if (n<>'') then
      begin
      //get
      h:=frcmin64(sub64(ihit.c[n],ihitref.c[n]),0);
      b:=ibytes.c[n];
      ladd(k64(h),low__mbPLUS(b,true),n);
      ht:=add64(ht,h);
      bt:=add64(bt,b);
      //reset (end of day) or reset (if numbers out-of-sync) - 29mar2024
      if xreset or (ihitref.c[n]>ihit.c[n]) then
         begin
         ihitref.c[n]:=ihit.c[n];//never reset hit counter -> it persists, instead copy over value to hitref so the difference can be calculated for daily info
         ibytes.c[n]:=0;//safe to reset bandwidth counter -> it resets every 24hr
         end;
      end;
   end;//p
   //.total
   a.saddb(hline+#10);
   ladd(k64(ht),low__mbPLUS(bt,true),'Total');
   end;

//other
a.saddb(#10#10+'Server Up Time: '+app__uptimestr+#10);


//set
result:=a.text;
except;end;
try;str__free(@a);except;end;
end;
//## xlogs ##
function xlogs(var a:pnetwork;xcmd:string):string;
label
   skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   xfrom,xperpage,xstyle,xtep,xcount,p:longint;
   xsize:comp;
   b:tstr9;
   xnav:tstr8;
   xname,xlabel,xfolder:string;
   atleastone:boolean;
   //## ne ##
   function ne(x:string):string;
   begin
   result:=net__encodeforhtmlstr(x);
   end;
   //## xaddb ##
   procedure xaddb(xnumber,xname,xsize,xrep:string);
   begin
   b.saddb('<div class="ralign breakword">'+xnumber+'</div><div>'+xname+'</div><div class="ralign breakword">'+xsize+'</div><div>'+xrep+'</div>'+#10);
   end;
   //## xadd ##
   procedure xadd(xindex:longint;xname:string;var xsize:comp);
   begin
   xaddb(k64(xindex)+'.','<a title="View traffic log report" href="'+xneurl('log--'+xname+'.html')+'" target="msg">'+ne(io__remlastext(xname))+'</a>',low__mbPLUS(xsize,true),'<a title="View plain text traffic log (.txt)" href="'+xneurl('log--'+xname)+'" target="msg">RAW</a>');
   atleastone:=true;
   end;
   //## xnavbar ##
   function xnavbar:string;
   var
      b:tstr8;
      dcount,p:longint;
   begin
   //defaults
   result:='';
   b:=nil;

   try
   //init
   b:=str__new8;
   dcount:=xcount div xperpage;
   if ((dcount*xperpage)<>xcount) then inc(dcount);

   //get
   for p:=0 to (dcount-1) do
   begin
   str__saddb(@b,'<form class="inlineblock" method=post action="logs.html"><input name="cmd" type="hidden" value="from.'+inttostr(p*xperpage)+'"><input class="navbut" type=submit value="'+k64(p+1)+'"></form>');
   end;//p

   //set
   result:=str__text(@b);
   except;end;
   try;str__free(@b);except;end;
   end;
begin
//defaults
result:='';

try
xnav:=nil;
b:=nil;
//check
if (not net__recinfo(a,m,buf)) or (not m.vsessvalid) then exit;

//init
b:=str__new9;
xnav:=str__new8;
atleastone:=false;
xperpage:=ilogs_perpage;
xcmd:=strlow(xcmd);

//ensure log folder exists
xfolder:=io__makefolder2(ifastfolder__logs);

//get list of filenames
if not nav__init(xnav) then goto skipend;
if not nav__list(xnav,nlNameD,xfolder,'*.txt','',false,false,true) then goto skipend;//most recent files at top
xcount:=nav__count(xnav);

//.from
if (strcopy1(xcmd,1,5)='from.') then xfrom:=frcrange32(restrict32(strint64(strcopy1(xcmd,6,low__length(xcmd)))),0,xcount-1) else xfrom:=0;

//add the info message
b.saddb('<div class="logsinfo">You have '+k64(xcount)+' traffic logs in total<br>'+xnavbar+'</div>'+#10);

//start
b.saddb('<div class="logsview">'+#10);//**
b.saddb('<div class="logs">'+#10);
xaddb('#','Name','Size','RAW');

//.list of logs
if (xcount>=1) then
   begin
   for p:=xfrom to frcmax32(xfrom+xperpage-1,xcount-1) do if nav__get(xnav,p,xstyle,xtep,xsize,xname,xlabel) then xadd(p+1,xname,xsize);
   end;

//empty
if not atleastone then xaddb('','( there are no logs )','','');

//finish
b.saddb('</div>'+#10);
b.saddb('<iframe id="nowrap" class="logsmsg" style="white-space:nowrap; text-wrap:nowrap;" name="msg" title="Log"></iframe>'+#10);
b.saddb('</div>'+#10);

//set
result:=b.text;
skipend:
except;end;
try
str__free(@b);
str__free(@xnav);
except;end;
end;
//## xinbox__folder ##
function xinbox__folder(xstyle:string;xread:boolean):string;
begin
if strmatch(xstyle,'trash') then result:=low__aorbstr(ifastfolder__trash,ifastfolder__trash_read,xread)
else                             result:=low__aorbstr(ifastfolder__inbox,ifastfolder__inbox_read,xread);
end;
//## xinbox__markread ##
procedure xinbox__markread(xstyle,xname:string);
var
   df,e:string;
begin
try
df:=io__makefolder2(xinbox__folder(xstyle,true))+xname;
if not io__fileexists(df) then io__tofilestr(df,'read',e);
except;end;
end;
//## mail__bestformat ##
function mail__bestformat(s,d:pobject;var dhtml:boolean;var dfrom,dto,ddate,dsubject:string):boolean;
label//Assumes only #10 return codes
   redo,skipone,skipend;
var
   xinfo:tfastvars;
   xboundary,xline:string;
   xfrom,xto,xseccount,xboundarylen,p,lp,xpos,v2,v,smin,smax,slen:longint;
   smem:pdlbyte;
   xheader,xbody:boolean;
   c:char;
   //## vpull ##
   function vpull(xpos:longint):byte;
   begin
   if ((xpos<smin) or (xpos>smax)) and (not block__fastinfo(s,xpos,smem,smin,smax)) then
      begin
      result:=0;
      exit;
      end;
   result:=smem[xpos-smin];
   end;
   //## xsplitline ##
   procedure xsplitline;
   var
      p,p2,lp:longint;
      n,v:string;
   begin
   try
   lp:=1;
   c:=':';
   for p:=1 to low__length(xline) do
      begin
      if (xline[p-1+stroffset]=';') then
         begin
         n:=strcopy1(xline,lp,p-lp);
         v:='';
         if (n<>'') then
            begin
            for p2:=1 to low__length(n) do if (n[p2-1+stroffset]=c) then
               begin
               //.name and value pair
               v:=stripwhitespace_lt(strcopy1(n,p2+1,low__length(n)));
               n:=stripwhitespace_lt(strlow(strcopy1(n,1,p2-1)));
               //.remove quotes from value "v"
               if (strcopy1(v,1,1)='"') then strdel1(v,1,1);
               if (strcopy1(v,low__length(v),1)='"') then strdel1(v,low__length(v),1);
               //.boundary
               if (n='boundary') then v:='--'+v;
               //.store
               xinfo.s[inttostr(xseccount)+'.'+n]:=v;
               if (xboundarylen<=0) and (n='boundary') then
                  begin
                  xboundary:=v;
                  xboundarylen:=low__length(v);
                  end;
               //.switch from ":" to "=" separator (: for 1st item only)
               c:='=';
               break;
               end;
            end;
         lp:=p+1;
         end;
      end;//p
   except;end;
   end;
begin
//defaults
result:=false;
dhtml:=false;
dfrom:='';
dto:='';
ddate:='';
dsubject:='';
xinfo:=nil;

//check
if (not str__ok(s)) or (not str__ok(d)) then exit;

//init
str__clear(d);
xinfo:=tfastvars.create;
slen:=str__len(s);
smax:=-2;
smin:=-1;
xheader:=true;
xbody:=false;
xboundarylen:=0;
xboundary:='';
xseccount:=0;

try
//get
xpos:=0;
lp:=0;
xinfo.i[inttostr(xseccount)+'.soh']:=xpos;//start of header

redo:
v:=vpull(xpos);
v2:=vpull(xpos+1);

//.header
if xheader then
   begin
   //.end of line
   if (v=10) and ((v2<>ssspace) and (v2<>sstab)) then
      begin
      xline:=str__str0(s,lp,xpos-lp+1);
      low__remchar(xline,#10);
      if strmatch(strcopy1(xline,1,14),'content-type: ') or strmatch(strcopy1(xline,1,27),'content-transfer-encoding: ') or strmatch(strcopy1(xline,1,6),'from: ') or strmatch(strcopy1(xline,1,4),'to: ') or strmatch(strcopy1(xline,1,6),'date: ') or strmatch(strcopy1(xline,1,9),'subject: ') then
         begin
         xline:=xline+';';
         xsplitline;
         end;
      lp:=xpos+1
      end;
   //.end of header
   if (v=10) and (v2=10) then
      begin
      xheader:=false;
      xbody:=true;
      inc(xpos,1);
      xinfo.i[inttostr(xseccount)+'.sob']:=xpos;//start of body
      goto skipone;
      end;
   end;

if xbody then
   begin
   if (xboundarylen>=1) and (v=ssdash) and strmatch(str__str0(s,xpos,xboundarylen),xboundary) then
      begin
      xinfo.i[inttostr(xseccount)+'.eob']:=xpos;//end of body
      xbody:=false;
      xheader:=true;
      inc(xseccount);
      end;
   end;

//.loop
skipone:
inc(xpos);
if (xpos<slen) then goto redo;

//.finalise -> end of body
if not xinfo.found(inttostr(xseccount)+'.eob') then
   begin
   xinfo.i[inttostr(xseccount)+'.eob']:=frcmin32(slen-1,0);
   inc(xseccount);
   end;

//return best result
//.html
for p:=0 to (xseccount-1) do
begin
if strmatch(xinfo.s[inttostr(p)+'.content-type'],'text/html') then
   begin
   dhtml:=true;
   xfrom:=xinfo.i[inttostr(p)+'.sob'];
   xto:=xinfo.i[inttostr(p)+'.eob'];
   str__add3(d,s,xfrom,xto-xfrom+1);
//xxxxxxxx   if (xinfo.s[inttostr(p)+'.content-transfer-encoding'],'base64') then //xxxxxxxxxxxxxx need a block base64 handler
   result:=true;
   goto skipend;
   end;
end;//p
//.text
for p:=0 to (xseccount-1) do
begin
if strmatch(xinfo.s[inttostr(p)+'.content-type'],'text/plain') then
   begin
   dhtml:=false;
   xfrom:=xinfo.i[inttostr(p)+'.sob'];
   xto:=xinfo.i[inttostr(p)+'.eob'];
   str__add3(d,s,xfrom,xto-xfrom+1);
//xxxxxxxx   if (xinfo.s[inttostr(p)+'.content-transfer-encoding'],'base64') then //xxxxxxxxxxxxxx need a block base64 handler
   result:=true;
   goto skipend;
   end;
end;//p
//.failure
goto skipend;

skipend:

//.message values
dfrom:=xinfo.s['0.from'];
dto:=xinfo.s['0.to'];
ddate:=xinfo.s['0.date'];
dsubject:=xinfo.s['0.subject'];
except;end;
try;freeobj(@xinfo);except;end;
end;
//## xinbox_msgastext ##
procedure xinbox_msgastext(var a:pnetwork;xstyle,xname:string);//14mar2024: Updated for Facebook emails
label
   skipend;
var
   s,d:tobject;
   dhtml:boolean;
   dfrom,dto,ddate,dsubject:string;
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   xsize:comp;
   xdate:tdatetime;
   e:string;
   //## x404 ##
   function x404:boolean;
   begin
   result:=true;
   header__make(a,200,false,true,'', xhtmlstart3(a,'',false,true,false)+'Message not found'+xhtmlfinish2(true) ,'');
   m.writing:=true;
   end;
   //## xconvert ##
   procedure xconvert;
   label
      redo1,skipone1,redo2,skipone2,skipok2,skipend;
   var
      xstartpointINJECTPOS,smin,smax,slen,p,dlen:longint;
      smem:pdlbyte;
      vtmp,vtmp2,v:byte;
      xstartpointOK2,xscript1,xscript2:boolean;
      str1,n6,n7:string;
      //## pstart ##
      procedure pstart(xcopy:boolean);
      begin
      if xcopy then
         begin
         str__clear(@s);
         str__add(@s,@d);
         str__clear(@d);
         end;
      dlen:=0;
      slen:=str__len(@s);
      smax:=-2;
      smin:=-1;
      p:=0;
      xscript1:=false;
      xscript2:=false;
      end;
      //## vpull ##
      procedure vpull;
      begin
      if ((p<smin) or (p>smax)) and (not block__fastinfo(@s,p,smem,smin,smax)) then
         begin
         v:=0;
         exit;
         end;
      v:=smem[p-smin];
      end;
      //## vadd ##
      procedure vadd;
      begin
      inc(dlen);
      str__minlen(@d,dlen);
      str__setbytes0(@d,dlen-1,v);
      end;
      //## vadd1 ##
      procedure vadd1(x:byte);
      begin
      inc(dlen);
      str__minlen(@d,dlen);
      str__setbytes0(@d,dlen-1,x);
      end;
      //## vadd2 ##
      procedure vadd2(x:string);
      begin
      str__sadd(@d,x);
      dlen:=str__len(@d);
      end;
      //## xnext ##
      function xnext(xpos:longint):byte;
      begin
      if ((xpos<smin) or (xpos>smax)) and (not block__fastinfo(@s,xpos,smem,smin,smax)) then
         begin
         result:=0;
         exit;
         end;
      result:=smem[xpos-smin];
      end;
      //## xtext ##
      function xtext(xpos,xlen:longint):string;
      var
         p:longint;
         v:byte;
      begin
      result:='';
      if (xlen>=1) then
         begin
         for p:=xpos to (xpos+xlen-1) do
         begin
         v:=xnext(p);
         if (v=0) then break else result:=result+char(v);
         end;//p
         end;
      end;
      //## xinsinfo ##
      procedure xinsinfo(xpos:longint);
      const
         xspace3='&nbsp; &nbsp;';
         xspace5=xspace3+' &nbsp;';
      begin
      try
      str__clear(@s);
      str__saddb(@s,
      '<style>'+#10+
      'body {max-width:100% !important;}'+#10+
      '@media only screen and (max-width: 600px){.infopanel {font-size:0.74rem !important;}}'+#10+
      '</style>'+#10+
      '<div class="infopanel" style="display:block; margin:0; '+'margin-bottom:1rem; padding:0.5em; border:0; background-color:#f1e9fd; color:#000; text-align:left; letter-spacing:normal; line-height:100%; font-size:0.92rem; text-wrap:wrap;'+' word-wrap:anywhere; font-family:monospace, ''courier new'', courier;">'+
      '<span style="font-family:inherit;font-size:inherit;font-weight:bold;">Subject:</span> '+strdefb(dsubject,'(no subject)')+'<br>'+
      '<span style="font-family:inherit;font-size:inherit;font-weight:bold;">'+xspace3+'Date:</span> '+net__encodeforhtmlstr(ddate)+'<br>'+
      '<span style="font-family:inherit;font-size:inherit;font-weight:bold;">'+xspace3+'From:</span> '+strdefb(dfrom,'(no address)')+'<br>'+
      '<span style="font-family:inherit;font-size:inherit;font-weight:bold;">'+xspace5+'To:</span> '+dto+'<br>'+
      '</div>'
      );
      str__ins(@d,@s,xpos);
      except;end;
      end;
   begin
   try
   //layer 1 - restore long lines ----------------------------------------------
   pstart(true);
   if (slen<=0) then goto skipend;

   redo1:
   vpull;

   //=<rcode>
   if (v=ssequal) then
      begin
      if (xnext(p+1)=10) then
         begin
         inc(p,1);
         goto skipone1;
         end
      //[=] [09azAZ] [09azAZ] => single char
      else
         begin
         vtmp:=xnext(p+1);
         vtmp2:=xnext(p+2);
         case vtmp of
         nn0..nn9,llA..llZ,uuA..uuZ:begin
            case vtmp2 of
            nn0..nn9,llA..llZ,uuA..uuZ:begin
               vadd1(low__hexint2(char(vtmp)+char(vtmp2)));
               inc(p,2);
               goto skipone1;
               end;
            end;//case
            end;
         end;//case
         end;
      end
   //leading ".." -> "." (start of line)
   else if (v=ssdot) then
      begin
      vtmp:=xnext(p-1);
      if ((vtmp=0) or (vtmp=10)) and (xnext(p+1)=ssdot) then
         begin
         vadd;
         inc(p,1);
         goto skipone1;
         end;
      end;

   vadd;
   skipone1:
   inc(p);
   if (p<slen) then goto redo1;


   //layer 2 - convert html to plain text --------------------------------------
   pstart(true);

   //.len check
   if (slen<=0) then goto skipend;

   redo2:
   vpull;

   //<...>
   case v of
   sslessthan:begin
      //init
      str1:=strlow(xtext(p+1,10));
      n6:=strcopy1(str1,1,6);
      n7:=strcopy1(str1,1,7);
      //get
      if      (n6='script') then
         begin
         xscript1:=true;
         xscript2:=false;
         goto skipone2;
         end
      else if (n7='/script') then
         begin
         xscript1:=false;
         xscript2:=true;
         end;
      end;
   ssmorethan:begin
      if xscript2 then
         begin
         xscript2:=false;
         goto skipone2;
         end;
      end;
   end;//case

   //decide
   if xscript1 or xscript2 then goto skipone2;

   skipok2:
   if dhtml then vadd
   else
      begin
      case v of
      //10:vadd2('<br>'+#10);
      9:vadd2('&nbsp; &nbsp; &nbsp;');//5 spaces for a tab
      ssLessthan:vadd2('&lt;');
      ssMorethan:vadd2('&gt;');
      else vadd;
      end;//case
      end;

   skipone2:
   inc(p);
   if (p<slen) then goto redo2;

   //.finish html
   skipend:

   //.non-html insert htmlstart and htmlfinish
   if not dhtml then str__settextb(@d,xhtmlstart3(a,'',false,true,false)+'<pre class="plaintext">'+str__text(@d)+'</pre>'+xhtmlfinish2(true));

   //.message values
   dlen:=str__len(@d);
   smax:=-2;
   smin:=-1;
   xstartpointOK2:=false;
   xstartpointINJECTPOS:=-1;//not used
   if (dlen>=1) then
      begin
      for p:=0 to (dlen-1) do
      begin
      case str__bytes0(@d,p) of
      sslessthan:begin
         //Note: Facebook emails use a table BEFORE the body of the html document in their emails - 14mar2024
         str1:=strlow(str__str0(@d,p+1,10));
         if strmatch(strcopy1(str1,1,4),'body') then xstartpointOK2:=true
         else if strmatch(strcopy1(str1,1,3),'div') or strmatch(strcopy1(str1,1,5),'table') then
            begin
            xstartpointOK2:=true;
            xstartpointINJECTPOS:=p;
            end;
         end;
      ssmorethan:begin
         if xstartpointOK2 then
            begin
            if (xstartpointINJECTPOS>=0) then xinsinfo(xstartpointINJECTPOS) else xinsinfo(p+1);
            break;
            end;
         end;
      end;//case
      end;//p
      end;
   if not xstartpointOK2 then xinsinfo(0);//fallback
   except;end;
   end;
begin
try
//defaults
s:=nil;
d:=nil;

//check
if (not net__recinfo(a,m,buf)) or (not m.vsessvalid) then exit;

//init
dfrom:='';
dto:='';
ddate:='';
dsubject:='';
xname:=io__extractfilename(xname);
if (xname='') and x404 then goto skipend;
str__clear(buf);
s:=str__new9;
d:=str__new9;
//xstyle:=strlow(m.hnameext);

//get -> read upto the first 10mb of email message
if (not io__fromfile64d(xinbox__folder(xstyle,false)+xname,@s,false,e,xsize,0,iinbox_msgastext_size,xdate)) and x404 then goto skipend;

//leave only #10 return codes
str__remchar(@s,13);

//find best format -> e.g. "text/html"
mail__bestformat(@s,@d,dhtml,dfrom,dto,ddate,dsubject);


//utf-8 decoding added - 15apr2024
dsubject:=utf8__encodetohtmlstr(mail__encodefield(dsubject,false),false,false);//utf-8 etc
dfrom:=utf8__encodetohtmlstr(mail__encodefield(dfrom,false),false,false);//utf-8 etc
dto:=utf8__encodetohtmlstr(mail__encodefield(dto,false),false,false);//utf-8 etc

//trickle "s" into "d"
xconvert;

//set
m.wfilesize:=str__len(@d);
m.wfiledate:=xdate;
m.wfrom:=0;
m.wto:=sub64(m.wfilesize,1);
header__make3(a,200,true,m.wfilesize,xdate,false,true,'');//no-referrer=TRUE=for security reasons -> prevents url leakage
if m.hwantdata then str__add(buf,@d);
m.writing:=true;

skipend:
except;end;
try
str__free(@s);
str__free(@d);
except;end;
end;
//## xinbox_filenameassubject ##
function xinbox_filenameassubject(s:string;var xdatestr,xsubjectstr:string):boolean;
var
   slen,p:longint;
begin
//defaults
result:=false;
xdatestr:='';
xsubjectstr:=s;

try
s:=io__extractfilename(s);
if (s<>'') then
   begin
   slen:=low__length(s);
   for p:=1 to slen do if (s[p-1+stroffset]='_') then
      begin
      result:=true;
      xdatestr:=strcopy1(s,1,p-1);//date still needs to be decoded
      xsubjectstr:=io__remlastext(strcopy1(s,p+1,slen));
      break;
      end;
   end;
except;end;
end;
//## xinbox_act ##
function xinbox_act(var a:pnetwork;xname:string):string;
label
   skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   xorgname,xmore,sf,df,sf2,df2,e,xstyle,xcmd,xdate,xsubject:string;
begin
//defaults
result:='';
xstyle:='';
xcmd:='';
xorgname:='';
xmore:='';

try
//check
if (not net__recinfo(a,m,buf)) or (not m.vsessvalid) then exit;

//init
if strmatch(strcopy1(xname,1,11),'inbox.del--') then
   begin
   xcmd:='delete';
   xstyle:='inbox';
   xorgname:=strcopy1(m.hname,12,low__length(m.hname));
   xname:=io__remlastext(xorgname);
   end
else if strmatch(strcopy1(xname,1,11),'trash.udl--') then
   begin
   xcmd:='undelete';
   xstyle:='trash';
   xorgname:=strcopy1(m.hname,12,low__length(m.hname));
   xname:=io__remlastext(xorgname);
   end
else
   begin
   result:='Unsupported action';
   goto skipend;
   end;

//.name -> ".em.eml" => ".em" to support older ".em" messages if they're in the inbox/trash folders
if (not io__fileexists(xinbox__folder(xstyle,false)+xname)) and io__fileexists(xinbox__folder(xstyle,false)+io__remlastext(xname)) then xname:=io__remlastext(xname);

//get
if (xcmd='delete') then
   begin
   //init
   sf:=xinbox__folder('inbox',false)+xname;
   sf2:=xinbox__folder('inbox',true)+xname;
   df:=io__makefolder2(xinbox__folder('trash',false))+xname;
   df2:=io__makefolder2(xinbox__folder('trash',true))+xname;
   xmore:='<a class="navbut" href="'+xneurl('trash.udl--'+xorgname)+'">Restore to Inbox</a>';
   xinbox_filenameassubject(sf,xdate,xsubject);
   xsubject:=':<br>"'+xencodetextforhtml_barely(xsubject)+'"';

   //get
   case io__fileexists(sf) of
   true:begin
      if not io__copyfile(sf,df,e) then
         begin
         result:='Failed to delete message to Trash'+xsubject;
         goto skipend;
         end;
      io__copyfile(sf2,df2,e);//ignore errors here
      io__remfile(sf);
      io__remfile(sf2);

      result:='Message deleted to Trash'+xsubject;
      end;
   false:result:='Message previously deleted to Trash'+xsubject;
   end;//case
   end
else if (xcmd='undelete') then
   begin
   //init
   sf:=xinbox__folder('trash',false)+xname;
   sf2:=xinbox__folder('trash',true)+xname;
   df:=io__makefolder2(xinbox__folder('inbox',false))+xname;
   df2:=io__makefolder2(xinbox__folder('inbox',true))+xname;
   xmore:='<a class="navbut" href="'+xneurl('inbox.del--'+xorgname)+'">Delete to Trash</a>';

   xinbox_filenameassubject(sf,xdate,xsubject);
   xsubject:=':<br>"'+xencodetextforhtml_barely(xsubject)+'"';

   //get
   case io__fileexists(sf) of
   true:begin
      if not io__copyfile(sf,df,e) then
         begin
         result:='Failed to restore message to Inbox'+xsubject;
         goto skipend;
         end;
      io__copyfile(sf2,df2,e);//ignore errors here
      io__remfile(sf);
      io__remfile(sf2);
      result:='Message restored to Inbox'+xsubject;
      end;
   false:result:='Message previously restored to Inbox'+xsubject;
   end;//case
   end;
//.options
result:=result+'<br>&nbsp;<br>'+xmore;

skipend:
except;end;
end;
//## xneurl ##
function xneurl(x:string):string;//netencode url
begin
result:=net__encodeurlstr(x,true);
end;
//## xencodetextforhtml_barely ##
function xencodetextforhtml_barely(x:string):string;//only filter out [<>"] 3 chars
begin
result:=net__encodeforhtmlstr2(x,true,false,[sslessthan,ssmorethan,ssdoublequote],[0]);
end;
//## xinbox ##
function xinbox(var a:pnetwork;xstyle,xcmd,xcmd2:string):string;
label
   skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   sstyle,xfrom,xnewcount,xnavstyle,xtep,xcount,p:longint;
   xsize:comp;
   b:tstr9;
   xnav:tstr8;
   xreadlist:tdynamicstring;
   xreadref1,xreadref2:tdynamicinteger;
   str1,str2,xname,xlabel,xfolder,xfolder_read:string;
   atleastone:boolean;
   c8:tcmp8;
   //## xhaveread ##
   function xhaveread(x:string):boolean;
   var
      n8:tcmp8;
      p:longint;
   begin
   //defaults
   result:=false;
   try
   //init
   n8.val:=low__ref256U(x);
   //find
   for p:=0 to (xreadlist.count-1) do
   begin
   if (xreadref1.items[p]=n8.ints[0]) and (xreadref2.items[p]=n8.ints[1]) and strmatch(x,xreadlist.items[p]^) then
      begin
      result:=true;
      break;
      end;
   end;//p
   except;end;
   end;
   //## ne ##
   function ne(x:string):string;
   begin
   result:=net__encodeforhtmlstr(x);
   end;
   //## xdate ##
   function xdate(x:string):string;
   var
      y,m,d,hh,mm,ss:longint;
   begin
   try
   //defaults
   result:='';
   //get
   y:=strint(strcopy1(x,1,4));
   if (y>=1900) then
      begin
      m:=strint(strcopy1(x,5,2));
      if (m>=1) and (m<=12) then
         begin
         d:=strint(strcopy1(x,7,2));
         if (d>=1) and (d<=31) then
            begin
            hh:=strint(strcopy1(x,9,2));
            mm:=frcrange32(strint(strcopy1(x,11,2)),0,59);
            ss:=frcrange32(strint(strcopy1(x,13,2)),0,59);
            result:=inttostr(d)+#32+low__month1(m,false)+#32+inttostr(y)+' / '+low__digpad11(hh,2)+' : '+low__digpad11(mm,2)+' . '+low__digpad11(ss,2);
            end;
         end;
      end;
   except;end;
   end;
   //## xaddb ##
   procedure xaddb(xnumber,xdate,xsubject,xsize,xeml,xact:string);
   begin
   b.saddb('<div class="ralign breakword">'+xnumber+' </div><div>'+strdefb(xdate,'-')+'</div><div class="hidden">'+strdefb(xsubject,'-')+'</div><div class="ralign breakword">'+xsize+'</div><div>'+xeml+'</div><div>'+xact+'</div>'+#10);
   end;
   //## xadd ##
   procedure xadd(xindex:longint;xname:string;var xsize:comp);
   var
      d,s:string;
      xlen:longint;
      xemlOK:boolean;
   begin
   //split name -> datetime + subject
   d:='';
   s:=xname;
   xlen:=low__length(xname);
   xemlok:=strmatch(strcopy1(xname,xlen-3,4),'.eml');
   if xinbox_filenameassubject(s,d,s) then d:=xdate(d);
   //get
   case sstyle of
   0:xaddb(k64(xindex)+'.',d,'<a title="View message" class="'+low__aorbstr('unread','read',xhaveread(xname))+'" href="'+xneurl('inbox--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">'+xencodetextforhtml_barely(s)+'</a>',low__mbPLUS(xsize,true),'<a title="Download message in .eml file format" href="'+xneurl('inbox--'+xname+insstr('.eml',not xemlok))+'">EML</a>','<a title="Delete message to Trash folder" href="'+xneurl('inbox.del--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">Del</a>');
   1:xaddb(k64(xindex)+'.',d,'<a title="View message" class="'+low__aorbstr('unread','read',xhaveread(xname))+'" href="'+xneurl('trash--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">'+xencodetextforhtml_barely(s)+'</a>',low__mbPLUS(xsize,true),'<a title="Download message in .eml file format" href="'+xneurl('trash--'+xname+insstr('.eml',not xemlok))+'">EML</a>','<a title="Restore message to Inbox" href="'+xneurl('trash.udl--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">Res</a>');
   end;
   atleastone:=true;
   end;
   //## xadd2 ##
   procedure xadd2(xname,xval:string);
   begin
   b.saddb('<div></div><div></div><div>'+ne(xname)+'</div><div class="mlauto">'+ne(xval)+'</div><div></div>'+#10);
   end;
   //## xnavbar ##
   function xnavbar:string;
   var
      b:tstr8;
      dcount,p:longint;
      xname:string;
   begin
   //defaults
   result:='';
   b:=nil;

   try
   //init
   xname:=low__aorbstr('inbox','trash',sstyle=1);
   b:=str__new8;
   dcount:=xcount div iinbox_msgsperpage;
   if ((dcount*iinbox_msgsperpage)<>xcount) then inc(dcount);

   //get
   for p:=0 to (dcount-1) do
   begin
   str__saddb(@b,'<form class="inlineblock" method=post action="'+xname+'.html"><input name="cmd" type="hidden" value="from.'+inttostr(p*iinbox_msgsperpage)+'"><input class="navbut" type=submit value="'+k64(p+1)+'"></form>');
   end;//p

   //set
   result:=str__text(@b);
   except;end;
   try;str__free(@b);except;end;
   end;
begin
//defaults
result:='';
xcmd:=strlow(xcmd);
xcmd2:=strlow(xcmd2);

try
xnav:=nil;
b:=nil;
xreadlist:=nil;
xreadref1:=nil;
xreadref2:=nil;
//check
if (not net__recinfo(a,m,buf)) or (not m.vsessvalid) then exit;

//init
b:=str__new9;
xnav:=str__new8;
xreadlist:=tdynamicstring.create;
xreadref1:=tdynamicinteger.create;
xreadref2:=tdynamicinteger.create;
atleastone:=false;

//ensure "inbox" and "inbox\read" folders exist
xfolder      :=io__makefolder2(xinbox__folder(xstyle,false));
xfolder_read :=io__makefolder2(xinbox__folder(xstyle,true));

if strmatch(xfolder,ifastfolder__trash) then sstyle:=1 else sstyle:=0;//0=inbox, 1=trash

//trash - permanently delete all files
if (sstyle=1) and (xcmd2='trash.deleteall2') then
   begin
   //messages
   io__filelist(xreadlist,false,xfolder,'*','');
   if (xreadlist.count>=1) then
      begin
      for p:=0 to (xreadlist.count-1) do io__remfile(xfolder+xreadlist.items[p]^);
      end;
   //reads
   io__filelist(xreadlist,false,xfolder_read,'*','');
   if (xreadlist.count>=1) then
      begin
      for p:=0 to (xreadlist.count-1) do io__remfile(xfolder_read+xreadlist.items[p]^);
      end;
   //reset
   xreadlist.clear;
   end;

//get list of filenames
if not nav__init(xnav) then goto skipend;
if not nav__list(xnav,nlNameD,xfolder,'*.eml;*.em','',false,false,true) then goto skipend;//most recent files at top
//.number of messages in inbox
xcount:=nav__count(xnav);
//.from
if (strcopy1(xcmd,1,5)='from.') then xfrom:=frcrange32(restrict32(strint64(strcopy1(xcmd,6,low__length(xcmd)))),0,xcount-1) else xfrom:=0;

//read list
io__filelist(xreadlist,false,xfolder_read,'*','');
if (xreadlist.count>=1) then
   begin
   //init
   xreadref1.size:=xreadlist.count;
   xreadref2.size:=xreadlist.count;
   //get
   for p:=0 to (xreadlist.count-1) do
   begin
   c8.val:=low__ref256U(xreadlist.items[p]^);
   xreadref1.items[p]:=c8.ints[0];
   xreadref2.items[p]:=c8.ints[1];
   end;//p
   end;

//new message count -> number of "unread" messages to the first "read" message
xnewcount:=0;
if (xcount>=1) then
   begin
   for p:=0 to (xcount-1) do if nav__get(xnav,p,xnavstyle,xtep,xsize,xname,xlabel) then
      begin
      if xhaveread(xname) then break else xnewcount:=p+1;
      end;//p
   end;

//inbox and trash info message
case xnewcount of
min32..0:str1:='no new messages';
       1:str1:='<span class="bold">1</span> new message';
2..max32:str1:='<span class="bold">'+k64(xnewcount)+'</span> new messages';
end;//case
str2:='';

//.delete button for trash folder
if (sstyle<>0) and (xcount>=1) then
   begin
   //init
   str2:=' &nbsp; &nbsp; ';
   //get
   if (xcmd2='trash.deleteall') then
      begin
      str2:=str2+
      '<form class="inlineblock" method=post action="trash.html"><input name="cmd" type="hidden" value="'+net__encodeforhtmlstr(xcmd)+'"><input name="cmd2" type="hidden" value="trash.deleteall2"><input class="navbut" type=submit value="Permanently Delete All Messages"></form>'+
      ' &nbsp; <form class="inlineblock" method=post action="trash.html"><input name="cmd" type="hidden" value="'+net__encodeforhtmlstr(xcmd)+'"><input name="cmd2" type="hidden" value=""><input class="button abort" type=submit value="Abort"> &nbsp; &nbsp; </form>'+
      '';
      end
   else str2:=str2+'<form class="inlineblock" method=post action="trash.html"><input name="cmd" type="hidden" value="'+net__encodeforhtmlstr(xcmd)+'"><input name="cmd2" type="hidden" value="trash.deleteall"><input class="navbut" type=submit value="Delete All Messages..."></form>';
   end;

//.add the info message
b.saddb('<div class="inboxinfo">You have '+str1+' and '+k64(xcount)+' in total<br>'+xnavbar+str2+'</div>'+#10);


//start
b.saddb('<div class="inboxview">'+#10);//**

b.saddb('<div class="inbox">'+#10);
xaddb('#','Date','Subject','Size','EML','Act');

if (xcount>=1) then
   begin
   for p:=xfrom to frcmax32(xfrom+iinbox_msgsperpage-1,xcount-1) do if nav__get(xnav,p,xnavstyle,xtep,xsize,xname,xlabel) then xadd(p+1,xname,xsize);
   end;

//empty
if not atleastone then xadd2('( there are no messages )','');

//finish
b.saddb('</div>'+#10);

b.saddb('<iframe class="inboxmsg" name="msg" title="Message"></iframe>'+#10);
b.saddb('</div>'+#10);

//set
result:=b.text;
skipend:
except;end;
try
str__free(@b);
str__free(@xnav);
freeobj(@xreadlist);
freeobj(@xreadref1);
freeobj(@xreadref2);
except;end;
end;
//## xdommapping2 ##
function xdommapping2(xonesiteonly:string;var xerrorcount:longint):string;
var
   xdata:tstr9;
   m:tnetbasic;
   n:string;
   p:longint;
   xallsitesok:boolean;
   //## xtick ##
   function xtick(xyes:boolean):string;
   begin
   if xyes then result:='<div class="yes">&#x2713;</div>' else result:='<div class="no">X</div>';
   end;
   //## xadd ##
   procedure xadd(a,b,c,d:string;xmakelink,xshowtick:boolean);
   var
      dport,t:string;
      bol1:boolean;
    //## ne ##
    function ne(x:string):string;
    begin
    result:=net__encodeforhtmlstr(x);
    end;
   begin
   try
   if not xallsitesok then
      begin
      if strmatch(c,idefaultdisksite) and (not strmatch(xonesiteonly,idefaultdisksite)) then inc(xerrorcount);
      result:=c;
      exit;
      end;

   if xshowtick then
      begin
      bol1:=not strmatch(c,idefaultdisksite);
      if not bol1 then inc(xerrorcount);
      t:=xtick(bol1);
      end
   else t:='';

   if (xdata<>nil) then
      begin
      if strmatch(a,'127.0.0.1') or strmatch(a,'localhost') then dport:=':'+inttostr(iport) else dport:='';
      xdata.saddb(
      '<div>'+insstr('<a href="http://'+a+dport+'" target="_blank">',xmakelink)+ne(a)+insstr('</a>',xmakelink)+'</div>'+
      '<div>'+t+ne(b)+'</div>'+
      '<div>'+ne(c)+'</div>'+
      '<div class="ralign">'+ne(d)+'</div>'+
      #10);
      end;
   except;end;
   end;
   //## xdom ##
   procedure xdom(n:string;xmasklink,xshowtick:boolean);
   begin
   try
   //init
   n:=strlow(n);
   //get
   m.clear;
   m.hhost:=n;
   xresolvehost(m);
   xadd(m.hhost,m.hdesthost,m.hdiskhost,k64(ihit.c[m.hdiskhost]),xmasklink,xshowtick);
   except;end;
   end;
begin
//defaults
result:='';

try
xdata:=nil;
m:=nil;
xerrorcount:=0;

//init
m:=tnetbasic.create;
xallsitesok:=(xonesiteonly='');
if xallsitesok then xdata:=str__new9;

//get
if xallsitesok then
   begin
   if (xdata<>nil) then xdata.saddb('<div class="dommap">'+#10);
   xadd('Domain','Resolves To','Site (Disk Folder)','Hits',false,false);
   end;

for p:=0 to (idom.count-1) do
begin
if xallsitesok then n:=strlow(idom.n[p]) else n:=xonesiteonly;

if (n=idefaultdisksite) then
   begin
   if not xallsitesok then result:=n;//can't map default site as it's the fallback site "www_" - 19feb2024
   end
else
   begin
   swapchars(n,'_','.');
   xdom(n,true,true);
   end;

if not xallsitesok then break;//only test the one supplied site "xonesiteonly"
end;//p

//finalise
if xallsitesok then
   begin
   xadd('( fallback )','-',idefaultdisksite,k64(ihit.c[idefaultdisksite]),false,false);
   if (xdata<>nil) then
      begin
      xdata.saddb('</div>'+#10);
      //set
      result:=xdata.text;
      end;
   end;
except;end;
try
str__free(@xdata);
freeobj(@m);
except;end;
end;
//## xdommapping ##
function xdommapping(var xerrorcount:longint):string;
begin
result:='';try;result:=xdommapping2('',xerrorcount);except;end;
end;
//## xinfostats ##
function xinfostats:string;
var
   xdata:tstr9;
   p:longint;
   //## xadd2 ##
   procedure xadd2(a,b:string;abold,bbold:boolean);
   var
      s:string;
    //## ne ##
    function ne(x:string):string;
    begin
    result:=net__encodeforhtmlstr(x);
    end;
   begin
   try
   s:=' style="font-weight:bold;"';
   xdata.saddb(
   '<div'+insstr(s,abold)+'>'+ne(a)+'</div>'+
   '<div class="ralign"'+insstr(s,bbold)+'>'+ne(b)+'</div>'+
   #10);
   except;end;
   end;
   //## xadd4 ##
   procedure xadd4(a,b,c,d:string;abold,bbold,cbold,dbold:boolean);
   var
      s:string;
    //## ne ##
    function ne(x:string):string;
    begin
    result:=net__encodeforhtmlstr(x);
    end;
   begin
   try
   s:=' style="font-weight:bold;"';
   xdata.saddb(
   '<div style="'+insstr('font-weight:bold;',abold)+'text-align:left;">'+ne(a)+'</div>'+
   '<div'+insstr(s,bbold)+'>'+ne(b)+'</div>'+
   '<div'+insstr(s,cbold)+'>'+ne(c)+'</div>'+
   '<div'+insstr(s,dbold)+'>'+ne(d)+'</div>'+
   #10);
   except;end;
   end;
   //## xadd ##
   procedure xadd(a,b:string;xbold:boolean);
   begin
   xadd2(a,b,xbold,xbold);
   end;
   //## xdom2 ##
   procedure xdom2(n:string;abold,bbold,cbold,dbold:boolean);
   var
      int1:longint;
      cmp1:comp;
      v1,v2:string;
   begin
   try
   //get
   if not strmatch(n,'total') then n:=strlow(n);
   //.files
   int1:=xdomfiles(n);
   if (int1>=1) then v1:=k64(int1) else v1:='-';
   //.bytes
   cmp1:=xdombytes(n);
   if (cmp1>=1) then v2:=low__mbPLUS(cmp1,true) else v2:='-';
   //set
   xadd4(n,k64(ihit.c[n]),v1,v2,abold,bbold,cbold,dbold);except;end;
   end;
   //## xdom ##
   procedure xdom(n:string);
   begin
   try;xdom2(n,false,false,false,false);except;end;
   end;
   //## xabout ##
   function xabout:string;
      //## xadd2 ##
      procedure xadd2(n,v:string);
      begin
      if (strcopy1(v,1,1)='*') then v:=app__info(strcopy1(v,2,low__length(v)));
      result:=result+low__lcolumn(n,20)+#32+low__lcolumn(v,20)+#10;
      end;
   begin
   //defaults
   result:='';
   //get
   xadd2('Name',app__info('name')+' - '+app__info('des'));
   xadd2('Version','*ver');
   xadd2('Name on Disk',app__info('diskname'));
   xadd2('Size on Disk',app__info('size'));
   xadd2('','');
   xadd2('Library','Version');
   xadd2(app__info('gossroot.name'),app__info('gossroot.ver'));
   xadd2(app__info('gossio.name'),app__info('gossio.ver'));
   xadd2(app__info('gossimg.name'),app__info('gossimg.ver'));
   xadd2(app__info('gossnet.name'),app__info('gossnet.ver'));
   xadd2(app__info('gosswin.name'),app__info('gosswin.ver'));
   end;
begin
//defaults
result:='';

try
xdata:=nil;
//init
xdata:=str__new9;

//dailysummary
xdata.saddb('<pre class="daystats">'+#10);
xdata.saddb(xdailysummary(false));
xdata.saddb('</pre>'+#10+'<br><br>'+#10);

//stats for server
xdata.saddb('<div class="stats">'+#10);
xadd('Server Stats','',true);
//was: xadd(app__info('name'),'v'+app__info('ver'),false);
xadd('Last Load',iramgmt,false);
xadd('Up Time',app__uptimestr,false);
xadd('HTTP Port',k64(iport)+' ('+low__aorbstr('offline','online',net__socketgood(ihttpserver))+')',false);
xadd('SMTP Port',k64(imailport)+' ('+low__aorbstr('offline','online',net__socketgood(imailserver))+')',false);
xadd('Hits',k64(ihit.c['total']),false);
xadd('Bandwidth In',low__mbPLUS(net__in,true),false);
xadd('Bandwidth Out',low__mbPLUS(net__out,true),false);
xadd('Connections',k64(iconncount_1sec)+' / '+k64(iconnlimit),false);
//xadd('RAM',low__mbAUTO(irambytes,true),false);
xadd2('RAM',low__mbPLUS(irambytes,true),false,true);
xadd('Files Cached',k64(iramfilescached)+' / '+k64(iramfilecount),false);
xdata.saddb('</div>'+#10+'<br><br>'+#10);

//stats for sites
xdata.saddb('<div class="domstats">'+#10);
xadd4('Site Stats','Hits','Files','RAM',true,false,false,false);
for p:=0 to (idom.count-1) do xdom(idom.n[p]);
xdom2('Total',true,true,true,true);
xdata.saddb('</div>'+#10+'<br><br>'+#10);

//dailysummary
xdata.saddb('<pre class="console">'+#10);
xdata.saddb('About'+#10+#10);
xdata.saddb(xabout);
xdata.saddb('</pre>'+#10);

//set
result:=xdata.text;
except;end;
try
str__free(@xdata);
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//mmmmmmmmmmmmmmmmmmmmmm
//## xtotallabel ##
function xtotallabel(xpreblankline:boolean;xcount:comp;xname,xname12:string):string;
begin
result:=insstr(#10,xpreblankline)+k64(xcount)+#32+xname+insstr(xname12,xcount<>1)+' found.';
end;
//## xconbut ##
function xconbut(xpageurl,xcmd,xcmd2,xtitle,xbutlabel:string):string;
begin
if (xbutlabel='') then xbutlabel:=xtitle;
if (xtitle='')    then xtitle:=xbutlabel;
result:='<form class="inlineblock" method=post action="'+xpageurl+'"><input name="cmd" type="hidden" value="'+xcmd+'"><input name="cmd2" type="hidden" value="'+xcmd2+'"><input class="conbut" type=submit title="'+xtitle+'" value="'+xbutlabel+'"></form>';
end;
//## xinfo2 ##
function xinfo2(xpageurl,xcmd:string):string;
var
   str1:string;
begin
xinfo(xpageurl,xcmd,str1,result);
end;
//## xinfo ##
procedure xinfo(xpageurl,xcmd:string;var xtitle,xout:string);
const
   xred='<div class="red" style="display:inline">';
   xredend='</div>';
var
   a:pnetwork;
   b:tobject;
   xcount,p:longint;
   xms64:comp;
   xmode,xtype:string;

   //.ban list
   xmins,xconn,xpost,xbad,xhits:longint;
   xaddress:string;
   xbytes:comp;
   xbanned:boolean;
   xscanfor,xbanfor,xconnlimit,xpostlimit,xbadlimit,xhitlimit:longint;
   xdatalimit:comp;
   //## xcolumnRight2RED ##
   function xcolumnRight2RED(x:string;xmaxwidth:longint):string;
   begin
   case (x<>'') and (x[0+stroffset]='*') of
   true:result:=xred+low__rcolumn(strcopy1(x,2,low__length(x)),xmaxwidth)+xredend;
   false:result:=low__rcolumn(x,xmaxwidth);
   end;
   end;
   //## xadd ##
   procedure xadd(x:string);
   begin
   str__saddb(@b,x+#10);
   end;
   //## xstart ##
   procedure xstart;
   begin
   xadd('<pre class="console">');
   end;
   //## xstop ##
   procedure xstop;
   begin
   xadd('</pre>');
   end;
   //## xadd8 ##
   procedure xadd8(xindex,xtype,xmode,xopentime,xidletime,xreusecount,xrecycled,xlastip:string);
   var
      v1,v2:string;
   begin
   //init
   if (xlastip='') then xlastip:='(none)';
   if (xreusecount='0') then
      begin
      v1:=xred;
      v2:=xredend;
      end
   else
      begin
      v1:='';
      v2:='';
      end;
   xadd(v1+low__rcolumn(xindex,6)+#32+low__rcolumn(xtype,6)+#32+low__rcolumn(xmode,10)+#32+low__rcolumn(xopentime,13)+#32+low__rcolumn(xidletime,13)+#32+low__rcolumn(xreusecount,12)+#32+low__rcolumn(xrecycled,10)+low__rcolumn(xlastip,20)+v2);
   end;
   //## xadd6 ##
   procedure xadd6(xip,xpost,xbad,xrequests,xbandwidth,xmins:string);
   begin
   xadd(
    low__rcolumn(xip,30)+#32+
    low__rcolumn(xpost,7)+#32+
    low__rcolumn(xbad,11)+#32+
    low__rcolumn(xrequests,10)+#32+
    low__rcolumn(xbandwidth,14)+#32+
    low__rcolumn(xmins,13));//29apr2024
   end;
   //## xadd6RED ##
   procedure xadd6RED(xip,xpost,xbad,xrequests,xbandwidth,xmins:string);
   begin
   xadd(
    low__rcolumn(xip,30)+#32+
    xcolumnRight2RED(xpost,7)+#32+
    xcolumnRight2RED(xbad,11)+#32+
    xcolumnRight2RED(xrequests,10)+#32+
    xcolumnRight2RED(xbandwidth,14)+#32+
    low__rcolumn(xmins,13));
   end;
begin
//defaults
xtitle:='';
xout:='';
b:=nil;
xms64:=ms64;

try
//init
xcmd:=strlow(xcmd);
b:=str__new9;
xcount:=0;

//get
//.banned ips
if (xcmd='bannedips') then
   begin
   xstart;
   xtitle:='Banned IPs';
   xadd('IP Addresses');
   xadd('------------');
   for p:=0 to (ipsec__count-1) do
   begin
   if ipsec__slot(p,xaddress,xmins,xconn,xpost,xbad,xhits,xbytes,xbanned) and xbanned then
      begin
      inc(xcount);
      xadd(xaddress);
      end;
   end;//p
   xadd(xtotallabel(true,xcount,'instance','s'));

   if (xcount>=1) then
      begin
      xadd('');
      xadd(xconbut(xpageurl,xcmd,'unbanall','Unban all IP addresses','Unban All'));
      end;
   xstop;
   end
//.ban list
else if (xcmd='banlist') then
   begin
   //init
   ipsec__getvals(xscanfor,xbanfor,xconnlimit,xpostlimit,xbadlimit,xhitlimit,xdatalimit);

   //get
   xstart;
   xtitle:='Ban List';

   xadd6('IP Address','Posts','Bad Logins','Requests','Bandwidth','Time');
   xadd6('----------','-----','----------','--------','---------','----');

   for p:=0 to (ipsec__count-1) do
   begin
   if ipsec__slot(p,xaddress,xmins,xconn,xpost,xbad,xhits,xbytes,xbanned) and xbanned then
      begin
      inc(xcount);
      xadd6RED(xaddress,
       insstr('*',(xpostlimit>=1) and (xpost>=xpostlimit))+k64(xpost),
       insstr('*',(xbadlimit>=1) and (xbad>=xbadlimit))+k64(xbad),
       insstr('*',(xhitlimit>=1) and (xhits>=xhitlimit))+k64(xhits),
       insstr('*',(xdatalimit>=1) and (xbytes>=xdatalimit))+low__mbPLUS(xbytes,true),
       low__uptime(mult64(xmins,60000),false,true,true,false,false,''));//compact versions - 500days = 13c
      end;
   end;//p
   xadd(xtotallabel(true,xcount,'instance','s')+'  Items marked in '+xred+'red'+xredend+' indicate the reason for ban.');

   if (xcount>=1) then
      begin
      xadd('');
      xadd(xconbut(xpageurl,xcmd,'unbanall','Unban all IP addresses','Unban All'));
      end;
   xstop;
   end

//.open connections
else
   begin
   xstart;
   xtitle:='Open Connections';
   xadd8('Conn #','Type','Last Mode','Open Time','Idle Time','Use Count','Recycled','Last IP Address');
   xadd8('------','----','---------','---------','---------','---------','--------','---------------');

   for p:=0 to (xconn_limit-1) do if net__haverec(a,p) and a.client and (a.more<>nil) and (a.more is tnetbasic) then
      begin
      inc(xcount);

      case a.infotag of
      cthttp:xtype:='HTTP';
      ctmail:xtype:='SMTP';
      else   xtype:='?';
      end;

      case a.infolastmode of
      1:xmode:='read';
      2:xmode:='write';
      else xmode:='idle';
      end;

      xadd8(k64(p),//connections 0 and 1 => http and smtp server slots - 08apr2024
      xtype,
      xmode,
      low__uptime(sub64(xms64,a.time_created),false,false,true,true,false,''),//compact versions - 500days = 13c
      low__uptime(sub64(xms64,a.time_idle),false,false,true,true,false,''),
      k64(a.used),
      k64(a.recycle),
      a.infolastip
      );
      end;//p

   //.footer
   xadd(xtotallabel(true,xcount,'instance','s')+'  Entires marked in '+xred+'red'+xredend+' indicate no data in or out.');

   if (xcount>=1) then
      begin
      xadd('');
      xadd(xconbut(xpageurl,xcmd,'closeall','Close all connections','Close All'));
      end;
   xstop;
   end;

//successful
if (str__len(@b)>=1) then
   begin
   xout:=str__text(@b);
   end;
except;end;
try;str__free(@b);except;end;
end;
//## xmanage ##
function xmanage:string;
var
   b:tstr9;
   xsitemapsto,xcreatesite_status,str1,dname,xname,xcmd,xsite,xsitehtml,v,xmask:string;
   xvalidlen,xsitemaps,bol1:boolean;
   int1,p:longint;
   //## xhead ##
   procedure xhead(xname,xtitle:string);
   begin
   str__saddb(@b,xh2(xname,xtitle+' ['+xsitehtml+']'));
   end;
   //## xbutton ##
   function xbutton(xbutton,xmoreclass:string):string;
   begin
   result:='<div class="manageoption"><div><input class="button'+xmoreclass+'" type=submit value="'+net__encodeforhtmlstr(xbutton)+'"></div></div>';
   end;
   //## xtextandbutton2 ##
   function xtextandbutton2(xshow:boolean;xtextname,xtext,xbutton,xmoreclass:string):string;
   begin
   result:='<div class="manageoption"><div><input'+insstr(' class="text"',xshow)+' type="'+low__aorbstr('hidden','text',xshow)+'" name="'+xtextname+'" value="'+net__encodeforhtmlstr(xtext)+'"></div><div><input class="button'+xmoreclass+'" type=submit value="'+net__encodeforhtmlstr(xbutton)+'"></div></div>';
   end;
   //## xtextandbutton ##
   function xtextandbutton(xtextname,xtext,xbutton:string):string;
   begin
   result:=xtextandbutton2(true,xtextname,xtext,xbutton,'');
   end;
   //## xform ##
   function xform(xname,xcmd,xsite,xcode:string):string;
   begin
   result:=
           '<form class="block" method=post action="manage.html'+insstr('#'+xname,xname<>'')+'">'+
    insstr('<input name="cmd" type="hidden" value="'+xcmd+'">',xcmd<>'')+
    insstr('<input name="site" type="hidden" value="'+net__encodeforhtmlstr(xsite)+'">',xsite<>'')+
    xcode+
    '</form>'+#10;
   end;
   //## xuploadlog ##
   function xuploadlog:string;
   begin
   result:=ivars.s['manage.upload.log'];
   if (result<>'') then
      begin
      result:=
      '<pre class="console">-- Upload Log --'+#10+
      k64(ivars.i['total'])+' files uploaded ('+low__mbauto(ivars.c['upload.size'],true)+') for site "'+xsite+'" with '+k64(ivars.i['errcount'])+' errors'+#10+
      #10+
      result+
      '</pre>';
      end;
   end;
   //## xlistfiles ##
   function xlistfiles(xsite,xmask:string;xdel,xuse:boolean):string;
   label
      skipend;
   var
      xnav:tstr8;
      xlog:tstr9;
      xramcount,xdiskcount,xtotal,xerrcount,xstyle,xtep,xcount,p:longint;
      xtotalsize,xsize:comp;
      str1,xfolder,xname,xlabel:string;
   begin
   //defaults
   result:='';
   xnav:=nil;
   xlog:=nil;
   xtotal:=0;
   xerrcount:=0;
   xtotalsize:=0;
   xramcount:=0;
   xdiskcount:=0;
   //check
   if (not xuse) or (xsite='') then exit;

   try
   //init
   xnav:=str__new8;
   xlog:=str__new9;

   //get
   if not nav__init(xnav) then goto skipend;
   xfolder:=io__asfolder(ifastfolder__root+xsite);

   if not nav__list(xnav,nlName,xfolder,strdefb(xmask,'*'),'',false,false,true) then goto skipend;
   xcount:=nav__count(xnav);
   if (xcount>=1) then
      begin
      for p:=0 to (xcount-1) do
      begin
      if nav__get(xnav,p,xstyle,xtep,xsize,xname,xlabel) then
         begin
         inc(xtotal);
         xtotalsize:=add64(xtotalsize,xsize);
         if xdel then
            begin
            case io__remfile(xfolder+xname) of
            true :begin
               str1:='[ DELETED ]';
               end;
            false:begin
               str1:='[ <span class=red>Del.Err.</span>]';
               inc(xerrcount);
               end;
            end;//case
            end
         else
            begin
            case xfileinram(xfolder+xname) of
            true :begin
               str1:='[ RAM  ]';
               inc(xramcount);
               end;
            false:begin
               str1:='[ <span class=red>DISK</span> ]';//mark disk status in red
               inc(xdiskcount);
               end;
            end;
            end;

         if (xtotal=1) then
            begin
            case xdel of
            true:begin
               str__saddb(@xlog,'Status       '+xcolumnRight('Size')+'  Name'+#10);
               str__saddb(@xlog,'------       '+xcolumnRight('----')+'  ----'+#10);
               end;
            false:begin
               str__saddb(@xlog,'Location  '+xcolumnRight('Size')+'  Name'+#10);
               str__saddb(@xlog,'--------  '+xcolumnRight('----')+'  ----'+#10);
               end;
            end;//case
            end;

         str__saddb(@xlog,str1+'  '+xcolumnRight(k64(xsize))+'  '+xname+#10);
         end;
      end;//p
      //.finalise
      if (xtotal>=1) then
         begin
         str__saddb(@xlog,#10+k64(xtotalsize)+' bytes ('+low__mbPLUS(xtotalsize,true)+') in total'+insstr(' with '+k64(xramcount)+' file/s in RAM and '+k64(xdiskcount)+' on disk',not xdel)+#10);
         end;
      end;

   //successful
   if (str__len(@xlog)<=0) then str__saddb(@xlog,'There are no files for this site.  The site is empty and can be deleted.');
   result:=
    '<pre class="console">'+
    k64(xtotal)+' files '+low__aorbstr('listed','deleted',xdel)+' for site "'+xsite+'" with '+k64(xerrcount)+' errors'+#10+
    #10+
    str__text(@xlog)+
    '</pre>';

    //site is empty -> offer up the "Delete Site" button
   if nav__init(xnav) and nav__list(xnav,nlName,ifastfolder__root+xsite,'*','',false,false,true) and (nav__count(xnav)<=0) then
      begin
      result:=result+xform('del','manage.del','',xtextandbutton2(false,'name',xsite,'Delete Site',''));
      end;

   skipend:
   except;end;
   try
   str__free(@xnav);
   str__free(@xlog);
   except;end;
   end;
begin
//defaults
result:='';
b:=nil;

try
//init
xcmd:=strlow(ivars.s['cmd']);
xsite:=io__extractfilename(strlow(net__decodestrb(ivars.s['site'])));
xsitehtml:=net__encodeforhtmlstr(xsite);
xmask:=io__extractfilename(net__decodestrb(ivars.s['mask']));
xname:=io__extractfilename(strlow(net__decodestrb(ivars.s['name'])));
xcreatesite_status:='';
b:=str__new9;

//decide
if (xcmd='') or (xsite='') then
   begin
   //.new site -> do action here so "idom" can be updated BEFORE we list the sites
   if (xcmd='manage.new') then
      begin
      dname:=xname;
      if (dname<>'') then
         begin
         for p:=1 to low__length(dname) do
         begin
         case byte(dname[p-1+stroffset]) of
         ssDot:dname[p-1+stroffset]:='_';
         ssSlash,ssBackSlash:;
         end;
         end;//p

         //enforce leading "www_"
         if not strmatch( strcopy1(dname,1,low__lengthb(idefaultdisksite)) , idefaultdisksite ) then dname:=idefaultdisksite+dname;

         //check + create + log
         if strmatch(dname,idefaultdisksite+'localhost') or strmatch(dname,idefaultdisksite) then xvalidlen:=true
         else
            begin
            int1:=0;
            for p:=1 to low__length(dname) do if (dname[p-1+stroffset]='_') then inc(int1);
            xvalidlen:=(int1>=2);
            end;

         if not xvalidlen then xcreatesite_status:='<pre class="console">Invalid site name "'+dname+'".</pre>'
         else if io__folderexists(ifastfolder__root+dname) then xcreatesite_status:='<pre class="console">Site name "'+dname+'" already exists.</pre>'
         else
            begin
            bol1:=io__makefolder(ifastfolder__root+dname);
            xcreatesite_status:='<pre class="console">'+low__aorbstr('Failed to create site "'+dname+'".','Site "'+dname+'" created.',bol1)+'</pre>';
            //.include the new site name immediately in the "idom" so any cleaning will retain the new site data - 18feb2024
            if bol1 then idom.b[dname]:=true;
            end;
         end;
      end;

   //.sites
   str__saddb(@b,xh2('manage',xsymbol('manage')+'Manage Sites'));
   str__saddb(@b,xminiconsole);
   str__saddb(@b,'Click the "Reload Site(s)" button to refresh the memory cache and update the site list to reflect changes made to one or more sites.');
   str__saddb(@b,xform('','reload','','<input class="button buttonaslink" type=submit value="Reload Site(s)">'));

   str__saddb(@b,xvsep);
   str__saddb(@b,'<br>Select a site below to manage its contents:');

   int1:=0;
   for p:=0 to (idom.count-1) do
   begin
   v:=strlow(idom.n[p]);
   if (v<>'') then
      begin
      inc(int1);
      str__saddb(@b,xform('','manage.options',v,'<input class="button buttonaslink" type=submit value="'+k64(int1)+'. &nbsp;'+net__encodeforhtmlstr(v)+'">'));
      end;
   end;//p

   //.new site
   str__saddb(@b,xvsep);
   str__saddb(@b,xh2('new','Create Site / Disk Site'));
   str__saddb(@b,xform('new','manage.new','','Type a domain name or disk site name (e.g. mydomain.com or mydomain_com) to make it known to and hostable by Bubbles.'+xtextandbutton('name',xname,'Create Site')));
   if (xcreatesite_status<>'') then str__sadd(@b,xcreatesite_status);

   //.del site
   str__saddb(@b,xvsep);
   str__saddb(@b,xh2('del','Delete Site / Disk Site'));
   str__saddb(@b,xform('del','manage.del','',
    'Type a domain name or disk site name (e.g. mydomain.com or mydomain_com) to remove it from Bubbles.  '+
    'A site must be empty before it can be deleted.  To empty a site, click the site button from the list above, then scroll down and click the "Delete Files..." button, and confirm by clicking the "Permanently Delete Files" button.  '+
    'All files on the site are removed and the site can be deleted.  Click the "Delete Site" button.  The site is deleted.'+xtextandbutton('name',xname,'Delete Site')));
   if (xcmd='manage.del') then
      begin
      dname:=xname;
      if (dname<>'') then
         begin
         for p:=1 to low__length(dname) do
         begin
         case byte(dname[p-1+stroffset]) of
         ssDot:dname[p-1+stroffset]:='_';
         ssSlash,ssBackSlash:;
         end;
         end;//p
         //enforce leading "www_"
         if not strmatch( strcopy1(dname,1,low__lengthb(idefaultdisksite)) , idefaultdisksite ) then dname:=idefaultdisksite+dname;
         //delete + log
         if not io__folderexists(ifastfolder__root+dname) then str1:='Site "'+dname+'" does not exist/was previously deleted.'
         else if strmatch(dname,idefaultdisksite) then str1:='Can''t delete default site.'
         else if io__deletefolder(ifastfolder__root+dname) then str1:='Site "'+dname+'" deleted.'
         else if io__folderexists(ifastfolder__root+dname) then str1:='Unable to delete site "'+dname+'" as it contains files which must first be deleted.<br><form class="inline-block" method=post action="manage.html#delete"><input name="cmd" type="hidden" value="manage.options"><input name="site" type="hidden" value="'+net__encodeforhtmlstr(dname)+'"><input class="button" type=submit value="Delete Files..."></form>'
         else                                                    str1:='Failed.';

         str__saddb(@b,'<pre class="console">'+str1+'</pre>');
         end;
      end;
   end
else
   begin
   //.site support info
   xsitemapsto:=xdommapping2(xsite,int1);
   xsitemaps:=not strmatch(xsitemapsto,xsite);

   //.general
   xhead('general',xsymbol('manage')+'General');
   str__saddb(@b,
   insstr('<div class="bad">This site reroutes to "'+net__encodeforhtmlstr(xsitemapsto)+'".  Files, site hit counter and redirects do not apply.</div>',xsitemaps)+
   xminiconsole);
   str__saddb(@b,'Refresh the memory cache and update the site list to reflect changes made to one or more sites.');
   str__saddb(@b,xform('','reload','','<input type="hidden" name="site" value="'+xsitehtml+'"><input class="button buttonaslink" type=submit value="Reload Site(s)">'));

   //.upload
   xhead('upload','Upload Files');
   str__saddb(@b,
   '<form class="block" method=post action="manage.html" enctype="multipart/form-data"><input name="cmd" type="hidden" value="manage.upload.'+xsitehtml+'">'+
   '<div class="manageoption"><div><input type="file" name="filename" id="filename" multiple></div><div><input class="button" type="submit" value="Upload Files" name="submit"></div></div>'+
   '</form>'+#10+
   'The combined maximum upload size is ~'+low__mbauto2(imaxuploadsize_admin,0,true)+' for the selected files.'+
   xuploadlog
   );

   //.list
   xhead('list','List Files');
   str__saddb(@b,xvsep);
   str__saddb(@b,
    xform('list','manage.list',xsite,'Type a complex mask or leave blank to list all files (e.g. *.zip or *.zip;*ab*.exe;)'+xtextandbutton('mask',xmask,'List Files'))+
    xlistfiles(xsite,xmask,false,xcmd='manage.list'));

   //.delete
   xhead('delete','Delete Files');
   str__saddb(@b,xvsep);
   if (xcmd='manage.delete') then
      begin
      //confirm prompt
      str__saddb(@b,
      xform('delete','manage.option',xsite,xtextandbutton2(false,'mask',xmask,'ABORT',' abort'))+
      xform('delete','manage.delete2',xsite,'Type a complex mask or leave blank to delete all files (e.g. *.zip or *.zip;*ab*.exe;)'+xtextandbutton('mask',xmask,'Permanently Delete Files'))+
      '');
      end
   else
      begin
      //delete
      str__saddb(@b,xform('delete','manage.delete',xsite,'Type a complex mask or leave blank to delete all files (e.g. *.zip or *.zip;*ab*.exe;)'+xtextandbutton('mask',xmask,'Delete Files...')));
      if (xcmd='manage.delete2') then str__saddb(@b,xlistfiles(xsite,xmask,true,true));
      end;

   //.hit counters
   if (xcmd='manage.counter') then
      begin
      ihit.c[xsite]:=strint64(net__decodestrb(ivars.s['counter']));
      xmakepngs(true);//update counter pngs
      imustsavesettings:=true;
      end;
   xhead('counter','Hit Counter');
   str__saddb(@b,xvsep);
   str__saddb(@b,
    insstr('<div class="bad">This site reroutes to "'+net__encodeforhtmlstr(xsitemapsto)+'".  The "site hit counter" below does not apply.</div>',xsitemaps)+
    'A site''s counter increments each time a "html" or "htm" document is requested, and can be displayed on your page(s) by loading the ".hits.png" image <img src=".hits.png" style="max-height:1em; vertical-align:text-bottom;">.  '+'Each site has its own hit counter.  Load the ".totalhits.png" image <img src=".totalhits.png" style="max-height:1em; vertical-align:text-bottom;"> to show the total hits across all sites.  Each counter updates after a short delay.<br><br>'+#10+
    xform('counter','manage.counter',xsite,
    '<div class="grid2">'+
    '<div>Type a number for site hit counter<br>'+
    '<input class="text" type="text" name="counter" value="'+net__encodeforhtmlstr(k64(ihit.i[xsite]))+'"></div>'+
    '<div>'+
//    'Type a number for total (all sites) hit counter<br>'+
//xxxxxxxx    '<input class="text" type="text" name="total.counter" value="'+net__encodeforhtmlstr(k64(ihit.i['total']))+'"><br>'+
    '</div>'+
    '</div>'+
    xvsep+
    '<input class="button" type=submit value="Save">'+
    ''));

    //.redirect
   if (xcmd='manage.redirect') then
      begin
      xredirect__addlocal(xsite,net__decodestrb(ivars.s['manage.redirect.list']));
      imustsavesettings:=true;
      end;

   xhead('redirect','Redirect Links');
   str__saddb(@b,xvsep);
   str__saddb(@b,
    xform('redirect','manage.redirect',xsite,
    insstr(xvsep+'<div class="bad">This site reroutes to "'+net__encodeforhtmlstr(xsitemapsto)+'".  The redirects below do not apply.</div>',xsitemaps)+

    'Type a source filename followed by a destination filename/url in the format "(source filename):(space)(target filename/url)" per line.  Optionally, you may specify 2-10 destination filenames/urls as a comma-space-tab separated '+'list, of which, one will be randomly selected during the redirect process.  There is a combined limit of '+k64(iredirect.limit)+' redirect entires shared across all sites.' +
    '<br>'+
    '<br>'+
    'Important:<br>'+
    'If a source file in a redirect entry shares the same name as an existing file on the site, then the redirect takes precedence over the file and redirects accordingly.<br>'+
    '<div style="font-size:80%;"><br><span class="bold">Examples of use:</span><br>'+
    'test1.html: http://testsite.net/about.html -&gt; redirects to http://testsite.net/about.html<br>'+
    'test2.html: index.html, contact.html, other.html -&gt; randomly redirects to index.html, contact.html or other.html<br>'+
    'test3.html: index.html, http://testsite.net, https://mysite.com, other.html -&gt; randomly redirects to index.html, http://testsite.net, https://mysite.com or other.html<br>'+
    '</div>'+
    '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="manage.redirect.list">'+net__encodeforhtmlstr(xredirect__sitelinks(xsite))+'</textarea>'+#10+
    xvsep+
    xbutton('Save',''))
    );
   end;

//set
result:=str__text(@b);
except;end;
try;str__free(@b);except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//66666666666666666666666666
//## xredirect__have ##
function xredirect__have(sname:string;var dnameORurl:string):boolean;
var
   dnamelist:string;
   _lp:array[0..9] of longint;
   _pp:array[0..9] of longint;
   lp,lc,p:longint;
   v:byte;
   vsep,lvsep:boolean;
begin
//defaults
result:=false;
dnameORurl:='';
try
if iredirect.sfound(sname,dnamelist) and (dnamelist<>'') then
   begin
   //init
   lc:=0;
   lp:=1;
   dnamelist:=dnamelist+#32;
   lvsep:=true;
   //get
   for p:=1 to low__length(dnamelist) do
   begin
   v:=byte(dnamelist[p-1+stroffset]);
   vsep:=(v=ssspace) or (v=sscomma) or (v=sstab);

   if (not vsep) and lvsep then lp:=p
   else if (not lvsep) and vsep then
      begin
      if ((p-lp)>=1) then
         begin
         _lp[lc]:=lp;
         _pp[lc]:=p;
         lp:=p;
         inc(lc);
         if (lc>high(_lp)) then break;
         end;
      end;

   lvsep:=vsep;
   end;//p
   //set
   if (lc>=1) then
      begin
      p:=frcrange32(random(lc),0,lc-1);
      dnameORurl:=strcopy1(dnamelist,_lp[p],_pp[p]-_lp[p]);
      result:=(dnameORurl<>'');
      end;
   end;
except;end;
end;
//## xredirect__sitelinks ##
function xredirect__sitelinks(ssite:string):string;
label
   skipend;
var
   b:tobject;
   p:longint;
   xsite,xname:string;
   //## xsplit ##
   procedure xsplit(x:string;var xsite,xname:string);
   var
      p:longint;
   begin
   try
   //defaults
   xsite:=x;
   xname:='';

   //split
   if (x<>'') then
      begin
      for p:=1 to low__length(x) do if (x[p-1+stroffset]='/') then
         begin
         xsite:=strcopy1(x,1,p-1);
         xname:=strcopy1(x,p+1,low__length(x));
         break;
         end;
      end;
   except;end;
   end;
begin
//defaults
result:='';
b:=nil;

try
//check
if (ssite='') or (iredirect.count<=0) then goto skipend;

//get
b:=str__new9;
for p:=0 to (iredirect.count-1) do
begin
xsplit(iredirect.n[p],xsite,xname);
if (xname<>'') and (xsite<>'') and strmatch(xsite,ssite) then str__saddb(@b,xname+': '+iredirect.v[p]+#10);
end;//p

//successful
result:=str__text(@b);
skipend:
except;end;
try;str__free(@b);except;end;
end;
//## xredirect__addlocal ##
procedure xredirect__addlocal(xsite,xlinks:string);
var
   b:tfastvars;
   p:longint;
begin
try
//defaults
b:=nil;

//check
if (xsite='') then exit;//24mar2024: fixed - now allows xlinks=nil

//init
b:=tfastvars.create;

//clean first
xredirect__clean(xsite);

//add local site links
b.text:=xlinks;
if (b.count>=1) then
   begin
   idom.b[xsite]:=true;//just to be sure the "idom" has this site, if not, make it so, even if it's temporary - 18feb2024
   for p:=0 to (b.count-1) do if (b.n[p]<>'') and (b.v[p]<>'') then iredirect.s[xsite+'/'+b.n[p]]:=b.v[p];
   end;

//clean again
xredirect__clean('');
except;end;
try;freeobj(@b);except;end;
end;
//## xredirect__clean ##
procedure xredirect__clean(xremovesite:string);
var
   b:tobject;
   p:longint;
   xsite,xname:string;
   //## xsplit ##
   procedure xsplit(x:string;var xsite,xname:string);
   var
      p:longint;
   begin
   try
   //defaults
   xsite:=x;
   xname:='';

   //split
   if (x<>'') then
      begin
      for p:=1 to low__length(x) do if (x[p-1+stroffset]='/') then
         begin
         xsite:=strcopy1(x,1,p-1);
         xname:=strcopy1(x,p+1,low__length(x));
         break;
         end;
      end;
   except;end;
   end;
begin
//defaults
b:=nil;

//check
if (iredirect.count<=0) then exit;

//get
try
b:=str__new9;
for p:=0 to (iredirect.count-1) do
begin
xsplit(iredirect.n[p],xsite,xname);
if (xname<>'') and (xsite<>'') and (not strmatch(xsite,xremovesite)) and (iredirect.v[p]<>'') and idom.found(xsite) then str__saddb(@b,xsite+'/'+xname+': '+iredirect.v[p]+#10);
end;//p

//successful
iredirect.text:=str__text(@b);
except;end;
try;str__free(@b);except;end;
end;
//## xh2 ##
function xh2(xlinkname,xname:string):string;
begin
try;result:=xh2b(xlinkname,xname,'');except;end;
end;
//## xh2b ##
function xh2b(xlinkname,xname,xclass:string):string;
begin
try;result:=insstr('<div class="vsepbig"></div><a name="'+xlinkname+'"></a>',xlinkname<>'')+#10+'<h2'+insstr(' class="'+xclass+'"',xclass<>'')+'>'+xname+'</h2>'+#10;except;end;
end;
//## xvsep ##
function xvsep:string;
begin
try;result:='<div class="vsep"></div>'+#10;except;end;
end;
//## xvsepbig ##
function xvsepbig:string;
begin
try;result:='<div class="vsepbig"></div>'+#10;except;end;
end;
//## xhtmlstart ##
function xhtmlstart(var a:pnetwork;xshowtoolbar:boolean):string;
begin
result:=xhtmlstart2(a,'',xshowtoolbar);
end;
//## xhtmlstart2 ##
function xhtmlstart2(var a:pnetwork;xhead:string;xshowtoolbar:boolean):string;
begin
result:=xhtmlstart3(a,xhead,xshowtoolbar,false,false);
end;
//## xsymbol ##
function xsymbol(xname:string):string;
var
   n:string;
begin
//init
n:=strlow(xname);

//get
if      (n='inbox')      then result:='&#128233;'
else if (n='trash')      then result:='&#128465;'
else if (n='logs')       then result:='&#129717;'
else if (n='contact')    then result:='&#128222;'
else if (n='overview')   then result:='&#128200;'
else if (n='settings')   then result:='&#9881;'
else if (n='console')    then result:='&#128187;'
else if (n='ban')        then result:='&#128683;'
else if (n='conn')       then result:='&#128225;'
else if (n='map')        then result:='&#127759;'
else if (n='manage')     then result:='&#129489;&#8205;&#128188;'
else if (n='password')   then result:='&#128273;'
else if (n='logout')     then result:='&#128682;'
else if (n='limits')     then result:='&#128286;'
else if (n='mime')       then result:='&#128451;'
else if (n='help')       then result:='&#8505;'
else                          result:='';
end;
//## xhtmlstart3 ##
function xhtmlstart3(var a:pnetwork;xhead:string;xshowtoolbar,xbare,xultrawide:boolean):string;
begin
result:=xhtmlstart4(a,'',xhead,xshowtoolbar,xbare,xultrawide);
end;
//## xhtmlstart4 ##
function xhtmlstart4(var a:pnetwork;xhead0,xhead1:string;xshowtoolbar,xbare,xultrawide:boolean):string;
var
   m:tnetbasic;
   buf:pobject;
   //## l2 ##
   function l2(u,n,nlabel:string):string;//link
   var
      xlabel:string;
   begin
   if (u='') then u:=strlow(n);
   u:=u+'.html';
   xlabel:=strdefb(nlabel,n);
   //set
   result:=
   '<a id="" target="_top" href="'+u+'" class="toolbarbutton'+insstr(' toolbarfocus',strmatch(m.hname,u))+'" aria-label="'+xlabel+'" title="'+xlabel+'">'+xsymbol(n)+n+'</a>'+
   '<a id="" target="_top" href="'+u+'" class="toolbaricon'+insstr(' toolbarfocus',strmatch(m.hname,u))+'" aria-label="'+xlabel+'" title="'+xlabel+'">'+xsymbol(n)+'</a>'+
   '';
   end;
   //## l ##
   function l(u,n:string):string;//link
   begin
   result:=l2(u,n,'');
   end;
begin
try
//defaults
result:='';

//check
if not net__recinfo(a,m,buf) then exit;

//get
result:=
'<!DOCTYPE html>'+#10+
'<html>'+#10+
'<head>'+#10+
'<meta charset="utf-8">'+#10+//22mar2024
'<meta name="referrer" content="no-referrer">'+#10+//prevent leaking of admin session url - 06jan2024
'<link rel="shortcut icon" href="bubbles.ico">'+#10+
xhead0+
'<style type="text/css">'+#10+
':root {'+#10+
'--letter-spacing: 0;'+#10+
'--line-height: 1;'+#10+
//'--font-size:clamp(12px, 4vw, 16px);'+#10+
'--font-size:1.05rem;'+#10+
'--font-family-text:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";'+#10+
'--text: #444;'+#10+
'--small:85%;'+#10+
'--scroll-vpad:5em;'+#10+
'--max-width:'+low__aorbstr('880px','1900px',xultrawide)+';'+#10+
'--but-back:#b7e;'+#10+
'--but-text:#fff;'+#10+
'--hmargin:1em;'+#10+
'--vmargin:1em;'+#10+
'--but-gap:1em;'+#10+
'--h2-topmargin:calc(var(--vmargin) * 3);'+#10+
'--h2-botmargin:var(--vmargin);'+#10+
'--grid2-gap:1em 1em;'+#10+
'--radius:15px;'+#10+
'--softborder:#fff5 1px solid;'+#10+
'--backshade:linear-gradient(45deg, #38f3, #a1d1);'+#10+
'--backshade2:linear-gradient(45deg, #3388ff06, #aa11dd06);'+#10+
'--head-back:#3388ff;'+#10+
'--backfaint:#fef2;'+#10+
'--conback:#000f;'+#10+
'--context:#dddf;'+#10+
'--row-highlight:#f3e8fd;'+#10+
'--lcolor:#38f;'+#10+
'--hcolor:#74e;'+#10+
'--vcolor:#c8e;'+#10+
'--log-text:#777;'+#10+
'--log-head-back:#38f;'+#10+
'--log-head-text:#fff;'+#10+
'--log-toolbar-text:#eee;'+#10+
'--log-toolbar-hove:#fff;'+#10+
'--help-topic-back:#7ce2;'+#10+
'--help-topic-text:var(--text);'+#10+
'--help-letter-spacing: 0.03em !important;'+#10+
'--help-line-height: 1.5 !important;'+#10+
'--badge-border:1px #f0f0f0 solid;'+#10+
'--hove-time: .25s;'+#10+
'--hove-scale: 1.1;'+#10+
'--font-mono:''courier new'', courier, monospace;'+#10+
'}'+#10+

//'*, *::before, *::after {margin:0; padding:0; line-height:var(--line-height); letter-spacing:var(--letter-spacing); font-size:var(--font-size); font-family:var(--font-family-text); box-sizing:border-box;}'+#10+
'*, *::before, *::after {margin:0; padding:0; font-family:var(--font-family-text); box-sizing:border-box;}'+#10+
'.arrow-up {display:inline-block; position:relative; transform:scalex(.5); width:1.2em;}'+#10+
'.arrow-up:after {content:''''; display:block; position:absolute; left:-80%; bottom:50%; width:0; height:0; border:.8em #0000 solid; border-bottom:.8em var(--but-text) solid;}'+#10+
'.small {font-size:var(--small);}'+#10+
'.hidden {overflow:hidden !important;}'+#10+
'.green {font:inherit; color:green;}'+#10+
'.red {font:inherit; color:red;}'+#10+
'.yes {color:green;}'+#10+
'.no {color:red;}'+#10+
'.yes, .no {display:inline; padding:0em .25em;}'#10+
'.buttonaslink {display:block !important; width:75%; margin:1em auto !important; text-align:left;}'+#10+
'.abort {font-size:1.5em !important; background-color:#f00 !important;}'+#10+
'a, a:link {line-height:inherit; letter-spacing:inherit; font-size:inherit; color:var(--lcolor); text-decoration:none}'+#10+
'a:hover {line-height:inherit; letter-spacing:inherit; font-size:inherit; color:var(--hcolor); text-decoration:underline}'+#10+
'a:visited {text-decoration:none;color:var(--vcolor);}'+#10+
'.unread, .unread:link, .unread:visited {color:var(--lcolor); font-weight:bold;}'+#10+
'.read, .read:link, .read:visited {color:var(--vcolor);}'+#10+
'h1,h2 {margin:.25em 0em; border:var(--softborder); background-color:#17fd; color:#fff; border-radius:var(--radius);}'+#10+
'h2 {display:block; font-size:150%; padding:.1em; padding-left:.5em; background-image:linear-gradient(45deg, #38ff, #a1d9); margin:0 0 var(--h2-botmargin) 0;}'+#10+
'h1 {display:block; font-size:150%; padding:1em; text-align:center; background-image:linear-gradient(45deg, #38ff, #a1d9);}'+#10+
'input[type="checkbox"] {margin:.3em}'+#10+
'.textbox, input[type="text"], input[type="password"], input[type="textarea"] {padding:.1em .5em !important;}'+#10+
'.breakword {word-wrap:break-word;}'+#10+
'.uploadrow {margin-top:1em !important; background-color:#0000; background-image:linear-gradient(45deg,#38fd,#a1d7); padding:.2em !important; '+'padding-left:1em !important; color:#ffff; border:var(--softborder); border-radius:var(--radius); align-items:center;}'+#10+
'.uploadrow:hover {background-color:#000f;}'+#10+
'.grid1 {display:grid; grid-template-columns:1fr; grid-gap:var(--grid2-gap); width:auto; max-width:100%; padding:.2em; margin:0;}'+#10+
'.grid2, .manageoption {display:grid; grid-template-columns:1fr 1fr; grid-gap:var(--grid2-gap); width:auto; max-width:100%; padding:.2em; margin:0;}'+#10+
'.manageoption {width:100%; align-items:center; grid-template-columns:5fr 1fr;}'+#10+
'.gridgap2 {margin:var(--grid2-gap)}'+#10+
'.grid25 {display:grid; grid-template-columns:1fr 1.5fr; grid-gap:var(--grid2-gap); width:auto; max-width:100%; padding:.2em; margin:0;}'+#10+
'.notopmargin {margin-top:0 !important;}'+#10+
'.nobotmargin {margin-bottom:0 !important;}'+#10+

'.toolbar {z-index:10;display:block; position:fixed; margin:0; padding:0; text-align:center; background-color:#0000; background-image:linear-gradient(45deg, #38ff, #a1df); width:100%;}'+#10+
'.toolbar > a, .toolbar > a:link {display:inline-block; border:0; border-bottom:#0000 2px solid; border-radius:0px; color:var(--but-text); padding:0; '+'margin:.25em .5em; transition:.5s; font-size:1rem !important; font-weight:normal; word-wrap:break-word;}'+#10+
'.toolbar > a:hover {color:var(--but-text); transform:scale(1.1); text-decoration:none;}'+#10+
'.toolbar > a:visited {text-decoration:none}'+#10+
'.toolbar > a:hover {border-bottom:var(--but-text) 2px solid; border-radius:0px;}'+#10+
'.toolbarfocus, .toolbarfocus:link {font-weight:bold !important; border-bottom-color:var(--but-text) !important; border-bottom-style:solid !important;}'+#10+
'.toolbarbutton {display:inline-block !important;}'+#10+
'.toolbaricon {margin:.15em 1% !important; display:none !important;}'+#10+

'.textbox {text-wrap:nowrap; width:100%; background-color:#fff0; border:#0005 1px solid; border-radius:.5em;}'+#10+
'.text {width:100%; background-color:#fff0; border:#0005 1px solid; border-radius:var(--radius);}'+#10+
'.vsep {display:block; margin:var(--vmargin) 0 0 0}'+#10+
'.vsepbig {display:block; margin:calc(var(--vmargin) * 4) 0 0 0;}'+#10+
'.bold {font-weight:bold !important;}'+#10+
'.underline {text-decoration:underline !important;}'+#10+
'.button, input[type=file]::file-selector-button, select {display:inline-block; border-radius:var(--radius); border:var(--softborder); background-color:var(--but-back); color:var(--but-text); padding:.25em 2em; margin:.1em '+'var(--but-gap) .1em 0; transition:.5s;}'+#10+
'.button:hover {color:var(--but-text); transform: scale(1.1); text-decoration:none;}'+#10+
'.input[type=file]::file-selector-button:hover {text-decoration:none;}'+#10+
'select {padding:.25em .7em !important;}'+#10+
'.block {display:block; margin:0}'+#10+
'.inlineblock {display:inline-block; margin:0}'+#10+
'.inline {display:inline; margin-right:0;}'+#10+
'.back {overflow:hidden; width:var(--max-width); max-width:100%; margin:0em auto; border:#fff7 3px solid; background-color:#fff7; border-radius:var(--radius); padding:0.5em 1em;}'+#10+
'.bad {background-color:#e00; color:#ffff;}'+#10+
'.good {background-color:#194; color:#ffff;}'+#10+
'.info {background-color:#aaf; color:#ffff;}'+#10+
'.bad, .good, .info {display:block; font-weight:bold; padding:.2em 1em;  border:var(--softborder); border-radius:var(--radius); margin-bottom:1em;}'+#10+
'.copyright {display:block; padding:.5em; margin-top:auto; background-color:#38f; color:#fff; font-size:80%; text-align:center;}'+#10+
'.copyright > a, .copyright > a:link, .copyright > a:hover {color:#fff;}'+#10+
'.stats {display:grid; grid-template-columns:55% auto; grid-gap:0.3rem; align-items:center; width:auto; max-width:100%; padding:0.6rem 1.25rem; '+'margin:0 auto; font-size:inherit; border-radius:var(--radius); background-image: linear-gradient(45deg, #38f3, #a1d1); color:#777;}'+#10+
'.stats > div {width:100%; height:100%; padding:.2em; border-bottom:#0002 1px dotted;}'+#10+
'.domstats {display:grid; grid-template-columns:50% auto auto auto; grid-gap:0.3rem; align-items:center; width:auto; max-width:100%; padding:0.6rem 1.25rem; '+'margin:0 auto 0 auto; font-size:inherit; border-radius:var(--radius); background-image: linear-gradient(45deg, #38f3, #a1d1); color:#777;}'+#10+
'.domstats > div {text-align:right; width:100%; height:100%; padding:.2em; border-bottom:#0002 1px dotted;}'+#10+
'.dommap {display:grid; grid-template-columns:auto auto auto auto; grid-gap:0.3rem; align-items:center; width:fit-content; min-width:min(var(--max-width),100%); max-width:100vw; padding:0.6rem 1.25rem; '+'margin:0 auto; font-size:inherit; border-radius:var(--radius); background-image: linear-gradient(45deg, #38f3, #a1d1); color:#777;}'+#10+
'.dommap > div {width:100%; height:100%; padding:.2em; border-bottom:#0002 1px dotted;}'+#10+

'.inboxinfo, .logsinfo {display:block; overflow:hidden; text-align:center; width:fit-content; min-width:min(var(--max-width),100%); max-width:100vw; padding:0.6rem 1.25rem; '+'margin:.2em auto; font-size:inherit; border-radius:var(--radius); background-color:#a1d1; color:#777;}'+#10+
'.inboxview, .logsview {display:grid; grid-template-rows:100%; grid-template-columns:2fr 3fr; grid-gap:0.2rem; width:100%; height:72vh; padding:.2em; margin:0;}'+#10+
'.logsview {grid-template-columns:2fr 4fr;}'+#10+
'.inbox, .logs {display:grid; grid-template-columns:1fr 4fr 10fr 2fr 1fr 1fr; grid-gap:0.3rem; grid-auto-rows:max-content; overflow:auto auto; text-align:left; width:100%; height:100%; padding:0.6rem 0rem; '+'margin:0 auto; font-size:inherit; background-image:var(--backshade2); color:#777; border:1px #ddd dotted; border-radius:var(--radius);}'+#10+
'.inbox > div, .logs > div {white-space:pre; text-wrap:nowrap; font-size:var(--small); width:100%; height:100%; padding:.2em; border-bottom:#0002 1px dotted;}'+#10+
'.inbox > div > a:visited, .logs > div > a:visited {color:#b7e !important;}'+#10+//Note: ":visited" does not support font-weight, and only limited styling -> browser based security protocol
'.inbox > div:focus-within, .logs > div:focus-within {background-color:var(--row-highlight) !important; border-radius:var(--radius);}'+#10+
'.logs {grid-template-columns:1fr 10fr 2fr 1.5fr !important;}'+#10+
'.inboxmsg, .logsmsg {display:block; text-align:left; width:100%; height:100%; padding:0; margin:0 auto; font-size:inherit; color:#777;'+' border:1px #ddd dotted; border-radius:var(--radius);}'+#10+
'.navbut, .conbut {display: inline-block; width: max-content !important; border-radius: var(--radius); border: var(--softborder); background-color: var(--but-back); color: var(--but-text) !important; '+'font-size: 80% !important; margin:0 0.1em; padding:0.1em 0.8em; transition:.5s;}'+#10+
'.navbut:hover, .conbut:hover {color:var(--but-text); transform:scale(1.1); text-decoration:none;}'+#10+
'.conbut {background-color:transparent !important;}'+#10+
                                                                                           //note: "pre-wrap" required to force word wrap on <pre> in FireFox
'.plaintext {display:block; margin:0; font-family:var(--font-mono); font-size:0.92rem; white-space:pre-wrap !important; text-wrap:wrap; word-wrap:anywhere; overflow-x:auto; color:#000;}'+#10+
//xxxxxxxxxxx'.conwin {display:block; text-align:left; height:50vh; width:fit-content; min-width:min(var(--max-width),100%); max-width:100vw; padding:0; margin:0 auto; font-size:inherit; '+'border:1px #fffe solid; background-color:var(--conback); color:var(--context);}'+#10+
'.console, .console2, .help-console, .help-console-wrap, .daystats {display:block; white-space:preserve; text-wrap:nowrap; margin:0; padding:.8em; font-family:var(--font-mono); font-size:80%; overflow-x:auto; background-color:var(--conback); '+'color:var(--context); border:#ffff 3px groove; border-radius:var(--radius);}'+#10+
'.lalign {text-align:left;}'+#10+
'.ralign {text-align:right;}'+#10+
'.mlauto {margin-left:auto;}'+#10+
'.miniinfo {display:block; margin:.5em 0; font-size:80%;}'+#10+

'.help-topics {text-align:left; padding-bottom:2rem;}'+#10+
'.help-topics ul {list-style-type:none;}'+#10+
'.help-topics ul > li {display:inline-block;}'+#10+
'.help-topics ul li > a:link, .help-topics ul li > a:visited, .help-topics ul li > a:hover {display:inline-block; width:fit-content; padding:.5rem .7rem; margin:.2rem; font-size:1rem; '+'line-height:normal; text-align:center; background-color:'+'var(--help-topic-back); color:var(--help-topic-text); border:var(--badge-border); vertical-align:middle; border-radius:1rem; font-weight:normal; min-width:3.5rem; transition:var(--hove-time);}'+#10+
'.help-topics ul li > a:hover {transform:scale(var(--hove-scale)); text-decoration:none;}'+#10+
'.help-body {line-height:var(--help-line-height); letter-spacing:var(--help-letter-spacing);}'+#10+
'.help-head {display:block; border-bottom:2px solid black; margin:1em 0 0 0; font-weight:bold; font-size:150%; line-height:150%;}'+#10+
'.help-subhead {display:inline-block; margin:.8em 0 .3em 0; font-weight:bold; font-size:110%; line-height:110%;}'+#10+
'.help-underline {display:inline-block; margin:.8em 0 .3em 0; text-decoration:underline;}'+#10+
'.help-console, .help-console-wrap {display:block; margin:.5em 0 !important; line-height:130% !important;}'+#10+
'.help-console-wrap {text-wrap:wrap !important;}'+#10+
'.help-body ul > li, .help-topics ul > li {line-height:var(--help-line-height);}'+#10+
'.help-body > ul, .help-topics > ul {padding:.2em 3em;}'+#10+

//.log report support
'.logheader {display:block; background-color:var(--log-head-back); color:var(--log-head-text); border:0; margin:0 0 1em 0; padding:.1em .8em; font-size:100%; font-weight:bold;}'+#10+
'.logtable3, .logtable2ll, .logtable3rl, .logtable4rl, .logtable5rl, .logtable4rr, .logtable10rl {display:grid; max-width:500px; grid-template-columns:1fr 2fr 3fr; grid-gap:0.2rem; width:100%; padding:.2em; margin:0; color:var(--log-text);}'+#10+
'.logtable2ll {grid-template-columns:1fr 2fr !important;}'+#10+
'.logtable4rl {grid-template-columns:1fr 1fr 2fr 3fr !important;}'+#10+
'.logtable4rr {grid-template-columns:1fr 1fr 2fr 2fr !important;}'+#10+
'.logtable5rl {grid-template-columns:1fr 1fr 2fr 1fr 3fr !important;}'+#10+
'.logtable10rl {grid-template-columns:1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 4fr !important;}'+#10+
'.logtable2ll > div, .logtable3 > div, .logtable3rl > div, .logtable4rl > div, .logtable4rr > div, .logtable5rl > div, .logtable10rl > div {text-align:right; '+'white-space:pre; text-wrap:nowrap; font-size:var(--small); width:100%; margin:0; padding:.1em .5em; border-bottom:#0002 1px dotted;}'+#10+
'.logtable2ll > div {text-align:left;}'+#10+
'.logtable3rl > div:nth-child(3n+3) {text-align:left;}'+#10+
'.logtable4rl > div:nth-child(4n+4) {text-align:left;}'+#10+
'.logtable5rl > div:nth-child(5n+5) {text-align:left;}'+#10+
'.logtable10rl > div:nth-child(10n+10) {text-align:left;}'+#10+
'.logbar {font-size:70%; display:inline-block; margin:0 0 0 2em;}'+#10+
'.logbar > a, .logbar > a:link {display:inline-block;line-height:inherit; letter-spacing:inherit; font-size:inherit; color:var(--log-toolbar-text); text-decoration:none; transition:.5s; border:0; border-bottom:#0000 2px solid;}'+#10+
'.logbar > a:hover {line-height:inherit; letter-spacing:inherit; font-size:inherit; color:var(--log-toolbar-hove); transform:scale(1.1); text-decoration:none; border-bottom:var(--log-toolbar-hove) 2px solid;}'+#10+
'.logbar > a:visited {text-decoration:none;color:var(--log-toolbar-text);}'+#10+
'.loginfo {display:inline-block; font-size:60%; padding:0 0 0 .2em; vertical-align:super;}'+#10+

'body, .textbox, .text, .button {font-size:1.01em;}'+#10+
'body {margin:0; min-height:100%; display:flex; flex-direction:column; background-repeat:repeat; background-attachment:fixed; background-color:white; color:var(--text); background-image:linear-gradient(45deg, #aff5, #ebf5);}'+#10+
'html {height:100%; scroll-padding-top: var(--scroll-vpad); scroll-behavior:smooth; word-wrap:break-word; word-wrap:anywhere;}'+#10+
//.media quiries
'@media only screen and (max-width: 600px){.back {margin-top:2rem;} .inbox > div, .logs > div {font-size:0.7rem;} .grid2 {grid-template-columns:100%}}'+#10+
'@media only screen and (max-width: 1000px){.inboxview, .logsview {grid-template-columns:100%; grid-template-rows:3fr 5fr !important;}}'+#10+
//.toolbar buttons -> icons switching
'@media only screen and (max-width: 800px){:root {--scroll-vpad:1em; --vmargin:.4em;} .toolbarbutton {display:none !important;} .toolbaricon {display:inline-block !important;}}'+#10+


'</style>'+#10+
xhead1+
'</head>'+#10+
'<body>'+#10+
//.toolbar
insstr(
'<div class="toolbar">'+
l2('index','Overview','Overview Summaries')+
l2('','Inbox','Inbox Folder')+
l2('','Trash','Trash Folder')+
l2('','Logs','Traffic Logs and Reports')+
l2('','Ban','Banned List')+
l2('','Conn','Open Connections')+
l2('','Console','Console View')+
//' &nbsp; '+
l2('','Settings','Server Settings')+
l2('','Limits','Client Limits')+
l2('','Mime','Mime Types')+
l2('','Contact','Contact Form + Mail Server Settings')+
l2('','Map','Domain Mapping')+
//l('','Counters')+
l2('','Manage','Manage Sites')+
l2('pass','Password','Change Admin Password')+
l2('','Logout','Logout from Admin session')+
//xxxxxxxxxxxxxxxxxxxl2('','Info','Information')+
l('','Help')+
'</div>'+#10+
'',xshowtoolbar)+

//.doc start
insstr(xhtmlback,not xbare);
except;end;
end;
//## xhtmlback ##
function xhtmlback:string;
begin
try;result:='<div class="back">'+#10;except;end;
end;
//## xhtmlfinish ##
function xhtmlfinish:string;
begin
result:=xhtmlfinish2(false);
end;
//## xhtmlfinish2 ##
function xhtmlfinish2(xbare:boolean):string;
begin
try
result:=
insstr('</div>'+#10+'<div class="copyright">'+app__info('name')+' v'+app__info('ver')+' &copy; 1997-'+low__yearstr(2024)+' <a href="http://www.blaizenterprises.com" target="_blank" alt="Visit Blaiz Enterprises">Blaiz Enterprises</a></div>'+#10,not xbare)+
'</body>'+#10+
'</html>'+#10+
'';
except;end;
end;
//## xsafewebname ##
function xsafewebname(var x:string):boolean;
label
   skipend;
var
   xlen,p:longint;
   lv2,lv,v:byte;
begin
//defaults
result:=false;
try
//init
xlen:=low__length(x);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;
//get
lv:=0;
lv2:=0;
for p:=1 to xlen do
begin
v:=byte(x[p-1+stroffset]);

//get
case v of
//.forbid these chars in a path and/or filename
0..31,ssColon,ssSemicolon,ssAsterisk,ssdoublequote,ssmorethan,sslessthan,sspipe,ssdollar,ssbackslash:goto skipend;
//.check for directory escapement "/../"
ssdot:if (lv=ssdot) and (lv2=ssslash) then goto skipend
end;

//last
lv2:=lv;
lv:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//8888888888888888888888888
//## xcontact_html ##
function xcontact_html(var a:pnetwork):boolean;
label//Important: Uses values from global "ivars" handler
   skipend;
var
   m:tnetbasic;//ptr only
   buf:pobject;//ptr only
   xemail,xmsg:tstr9;
   xsubject,xreplymessage,x,n,e:string;
   xlen,p2,p,int1,int2:longint;
   bol1,xcontact_question,xhaveinput,xmustspamguardreply,xmustreply,ok:boolean;
   //## xspamguard ##
   procedure xspamguard;
   var
      p:longint;
      xquestion:string;
      //## xspamguard_code ##
      function xspamguard_code(xfull:boolean):string;
      begin
      case xfull of
      true:begin
         result:=
         '<div style="display:inline-block;background-color:#eeeeee61;color:#777;margin:1em 0;;padding:0.5em;border:#ddd 1px solid;border-radius:10px;">'+
         '<div style="display:block;font-weight:bold;font-size:140%;">Spam Guard</div>'+
         '<div style="display:inline-block;padding:0 .5em 0 0;">'+xquestion+'</div>'+
         '<input style="padding:.2em .5em;border:#ddd 1px solid;border-radius:10px;" name="answer" value="">'+
         '</div>'+
         '';
         end;
      false:result:=xquestion;
      end;//case
      end;
   begin
   try
   if (x<>'') then
      begin
      //.question value
      if xcontact_question and (not xhaveinput) then question__make(xquestion) else xquestion:='';

      //insert SpamGuard at the "((spamguard))"
      for p:=1 to xlen do if (x[p-1+stroffset]='(') and strmatch(strcopy1(x,p,13),'((spamguard))') then
         begin
         x:=strcopy1(x,1,p-1)+xspamguard_code(xquestion<>'')+strcopy1(x,p+13,xlen);
         xlen:=low__length(x);
         xmustspamguardreply:=true;
         break;
         end;//p

      //fallback: tag "((spamguard))" not found -> insert the SpamGuard code at the bottom of the form - 04apr2024
      if (not xmustspamguardreply) and (xquestion<>'') then
         begin
         for p:=1 to xlen do
         begin
         if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,7),'</form>') then
            begin
            //insert Spam Guard
            x:=strcopy1(x,1,p-1)+xspamguard_code(true)+strcopy1(x,p,xlen);
            xlen:=low__length(x);
            xmustspamguardreply:=true;
            break;
            end;
         end;//p
         end;
      end;
   except;end;
   end;
begin
//defaults
result:=true;//pass-thru
xlen:=0;
xmustreply:=false;
xmustspamguardreply:=false;
xmsg:=nil;
xemail:=nil;
ok:=false;
xreplymessage:='';
xcontact_question:=icontact_question;

try

//check
if (ivars=nil) or (not net__recinfo(a,m,buf)) then exit;

//init
xhaveinput:=(ivars.count>=1);//inbound data
xmustreply:=xhaveinput;
x:=str__text(buf);
xlen:=low__length(x);

//SpamGuard
xSpamGuard;

//contact form submissions have been disabled
if not icontact_allow then
   begin
   xmustreply:=true;
   goto skipend;
   end;

//check
if not xmustreply then
   begin
   goto skipend;//check this second
   end;

//init
xemail:=str__new9;
xmsg:=str__new9;

//get
//.subject
xsubject:=strdefb(ivars.s['subject'],'(no subject)');
//.text
xmsg.saddb(strdefb(strdefb(ivars.s['message'],ivars.s['msg']),'(no message)'));

//.append any other "name=value" pairs at the end of the message body
xmsg.saddb(#10+#10+'--( More Information )----------------------------'+#10);
xmsg.saddb('sender-ip: '+m.hip+#10);//sender-ip
if (ivars.count>=1) then for p:=0 to (ivars.count-1) do
   begin
   n:=strlow(ivars.n[p]);
   if (n<>'') and (n<>'subject') and (n<>'message') and (n<>'msg') then xmsg.saddb(n+': '+ivars.v[p]+#10);
   end;//p
//set
//.make standard 7bit email message
//if not mail__makemsg(@xemail,m.hip,ivars.s['email'],'contact.html@'+m.hdiskhost,xsubject,xmsg.text,now,e) then goto skipend;
if not mail__makemsg(@xemail,m.hip,ivars.s['email'],'inbox@localhost',xsubject,xmsg.text,now,e) then goto skipend;


//.write email message to inbox -> if it fails the challenge question it's written to trash instead
bol1:=(not xcontact_question) or question__checkanswer(ivars.i['answer']);
if not mail__writemsg(@xemail,xsubject,io__makefolder2(xinbox__folder(low__aorbstr('trash','inbox',bol1),false))) then goto skipend;

//successful
ok:=true;
skipend:
except;end;
try
if xmustreply then
   begin
   //decide
   if not icontact_allow    then xreplymessage:=strdefb(icontact_off,icontact_def_off)
   else if ok               then xreplymessage:=strdefb(icontact_ok,icontact_def_ok)
   else                          xreplymessage:=strdefb(icontact_fail,icontact_def_fail);

   //reply value #1 -> replace "<!--reply-->...<!--endreply-->" with reply content -> this way we are able to swap out a whole chunk of static html code and replace with a fully customisable html reply
   if (x<>'') then
      begin
      //init
      int1:=0;
      int2:=0;
      for p:=1 to xlen do if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,12),'<!--reply-->') then
         begin
         int1:=p;
         break;
         end;//p
      if (int1>=1) then for p:=1 to xlen do if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,15),'<!--endreply-->') then
         begin
         int2:=p+15;
         break;
         end;//p
      //get
      if (int1>=1) and (int2>=1) then
         begin
         x:=strcopy1(x,1,int1-1)+xreplymessage+strcopy1(x,int2,xlen);
         xlen:=low__length(x);
         xmustreply:=false;//done
         end;
      end;

   //reply value #2 -> "<form " or "<form>" -> insert reply above "<form*>"
   if xmustreply and (xlen>=1) then
      begin
      for p:=1 to xlen do if (x[p-1+stroffset]='<') and (strmatch(strcopy1(x,p,6),'<form>') or strmatch(strcopy1(x,p,6),'<form ')) then
         begin
         x:=strcopy1(x,1,p-1)+xreplymessage+strcopy1(x,p,xlen);
         xlen:=low__length(x);
         xmustreply:=false;//done
         break;
         end;//p
      end;

   //reply value #3 -> "<body " or "<body>" -> insert reply at end of "<body...>"
   if xmustreply and (xlen>=1) then
      begin
      //.p
      for p:=1 to xlen do if (x[p-1+stroffset]='<') and (strmatch(strcopy1(x,p,6),'<body>') or strmatch(strcopy1(x,p,6),'<body ')) then
         begin
         //.p2
         for p2:=p to xlen do if (x[p2-1+stroffset]='>') then//fixed 24oct2019
            begin
            x:=strcopy1(x,1,p2)+xreplymessage+strcopy1(x,p2+1,xlen);
            //xlen:=low__length(x);
            xmustreply:=false;//done
            break;
            end;//p2

         break;
         end;//p
      end;

   //reply value #4 -> none of the above tags were found, so just insert reply at beginning of static file "str1"
   if xmustreply then
      begin
      x:=xreplymessage+x;
      //xmustreply:=false;
      end;

   //set
   str__settext(buf,x);
   end
else if xmustspamguardreply then str__settext(buf,x);
except;end;
try
str__free(@xemail);
str__free(@xmsg);
except;end;
end;
//## xlogrequest_http ##
function xlogrequest_http(var a:pnetwork;xaltcode:longint):boolean;
var
   m:tnetbasic;//ptr only
   buf:pobject;//ptr only
   v:comp;
begin
//pass-thru
result:=true;

try
//get
if net__recinfo(a,m,buf) and m.vmustlog then
   begin
   //once only
   m.vmustlog:=false;
   
   //init
   v:=add64(m.hread,m.wsent);

   //bandwidth per diskhost
   ibytes.cinc2(m.hdiskhost,v);

   //ipsec -> dec sim. conn tracking
   ipsec__incConn(m.hslot,false);

   //ipsec -> update tracking
   ipsec__incHit(m.hslot);
   if (m.hmethod=hmPOST) and (not strmatch(strcopy1b(m.hpath,1,low__lengthb(iadminpath)),iadminpath)) then ipsec__incPost(m.hslot);//don't count admin posts, logged in or not - 07feb2024
   ipsec__update(m.hslot);

   //add entry to logs
   if irawlogs then log__addentry(ifastfolder__logs,'',a,xaltcode);
   end;
except;end;
end;
//## xlogrequest_smtp ##
function xlogrequest_smtp(var a:pnetwork;xcode:longint):boolean;
var
   m:tnetbasic;//ptr only
   buf:pobject;//ptr only
begin
//pass-thru
result:=true;

try
//get
if net__recinfo(a,m,buf) and m.vmustlog then
   begin
   //once only
   m.vmustlog:=false;

   //ipsec -> dec sim. conn tracking (only if not admin panel)
   ipsec__incConn(m.hslot,false);

   //ipsec -> update tracking
   //was: if (xcode=250) then ipsec__incPost(m.hslot);

   ipsec__incPost(m.hslot);//count all email transactions, even failed ones - 03apr2024
   ipsec__update(m.hslot);

   //add entry to logs
   if irawlogs then log__addmailentry(ifastfolder__logs,'',a,xcode,m.wfilesize);//03mar2024
   end;
except;end;
end;
//## xcodedes ##
function xcodedes(xcode:longint):string;
begin
result:='';

try
case xcode of
200:result:='OK';
206:result:='Partial Content';
221:result:='Closing (SMTP)';
250:result:='OK (SMTP)';
304:result:='Not Modified';
307:result:='Temporary Redirect';
308:result:='Permanent Redirect';
354:result:='OK (SMTP)';
400:result:='Bad Request';
404:result:='Not Found';
403:result:='Forbidden';
412:result:='Precondition Failed';
413:result:='Content Too Large';
429:result:='Too Many Requests';
431:result:='Request Header Fields Too Large';
500:result:='Command Unrecognised (SMTP)';
502:result:='Bad Gateway';
503:result:='Service Unavailable';
507:result:='Insufficient Storage';
509:result:='Bandwidth Limit Exceeded';
554:result:='Transaction Failed (SMTP)';
else result:='OK';
end;
except;end;
end;
//## xmime_fallback ##
procedure xmime_fallback;
const
   xadd_charset_utf8='; charset=utf-8';

   //## xadd ##
   procedure xadd(xext,xtype:string);
   begin
   xext:=strlow(xext);
   xtype:=strlow(xtype);
   imime_fallback.s[xext]:=xtype;
   end;
begin
try
//clear
imime_fallback.clear;

//get
xadd('html','text/html'+xadd_charset_utf8);
xadd('htm' ,'text/html'+xadd_charset_utf8);
xadd('xml' ,'text/xml'+xadd_charset_utf8);
xadd('xhtml','application/xhtml+xml'+xadd_charset_utf8);
xadd('txt'  ,'text/plain');
xadd('text' ,'text/plain');
xadd('css'  ,'text/css');
xadd('pdf'  ,'application/pdf');
xadd('rtf'  ,'application/rtf');
xadd('js'   ,'application/x-javascript');
xadd('mocha','application/x-javascript');
xadd('pl'   ,'application/x-perl');
xadd('png'  ,'image/png');
xadd('jpg'  ,'image/jpeg');
xadd('jpeg' ,'image/jpeg');
xadd('jpe'  ,'image/jpeg');
xadd('jif'  ,'image/jpeg');
xadd('jfif' ,'image/jpeg');
xadd('gif'  ,'image/gif');
xadd('ico'  ,'image/x-icon');
xadd('bmp'  ,'image/bmp');
xadd('tif'  ,'image/tiff');
xadd('tiff' ,'image/tiff');
xadd('exe'  ,'application/vnd.microsoft.portable-executable');//05mar2020 -> was: 'exe=application/octet-stream'
xadd('eml'  ,'message/rfc822');//15apr2024
xadd('zip'  ,'application/zip');//05mar2020 -> was: 'zip=application/x-zip-compressed');
xadd('7z'   ,'application/x-7z-compressed');
xadd('gz'   ,'application/x-gzip');
xadd('z'    ,'application/x-compress');
xadd('tgz'  ,'application/x-compressed');
xadd('gtar' ,'application/x-gtar');
xadd('tar'  ,'application/x-tar');
xadd('apk'  ,'application/vnd.android.package-archive');
xadd('wav'  ,'audio/wav');
xadd('mp3'  ,'audio/mpeg');
xadd('mp4'  ,'video/mp4');
xadd('wma'  ,'audio/x-ms-wma');
xadd('webm' ,'video/webm');
xadd('weba' ,'audio/webm');//verified as correct - 24mar2024
xadd('webp' ,'image/webp');//verified as correct - 24mar2024
xadd('mkv'  ,'video/x-matroska');
xadd('epub' ,'application/epub+zip');
xadd('mid'  ,'audio/midi');//was audio/x-midi
xadd('midi' ,'audio/midi');//was audio/x-midi
xadd('bwd'  ,'application/x-bwd');
xadd('bwp'  ,'application/x-bwp');
xadd('*'    ,'application/octet-stream');//.absolute fallback
except;end;
end;
//## xmimelist ##
function xmimelist:string;
const
   xleftcol='            ';
var
   a:tobject;
   xlist:tfastvars;
   xnamelist:tdynamicstring;
   xleftcolwidth,p:longint;
   //## xadd ##
   procedure xadd(n,v:string;xheader:boolean);
   var
      vcustom:boolean;
      vpre,vpost:string;
   begin
   //init
   vcustom:=(not xheader) and (not strmatch(imime_fallback.s[n],v));
   vpre:=insstr('<span class=red>',vcustom);
   vpost:=insstr('</span>',vcustom);
   //get
   str__saddb(@a,vpre+n+strcopy1b(xleftcol,1,xleftcolwidth-low__length(n))+vpost+'   '+vpre+v+vpost+#10);
   end;
begin
//defaults
result:='';
a:=nil;
xlist:=nil;
xnamelist:=nil;
xleftcolwidth:=low__lengthb(xleftcol);

try
//init
a:=str__new9;
xlist:=tfastvars.create;
xnamelist:=tdynamicstring.create;

//get
for p:=0 to (imime_fallback.count-1) do xlist.s[imime_fallback.n[p]]:=xmimetype(imime_fallback.n[p]);
for p:=0 to (imime.count-1) do xlist.s[imime.n[p]]:=xmimetype(imime.n[p]);

//.namelist
for p:=0 to (xlist.count-1) do xnamelist.value[p]:=xlist.n[p];
xnamelist.sort(true);

//set
xadd('File Type','Mime Type',true);
xadd('---------','---------',true);
for p:=0 to (xlist.count-1) do xadd(xnamelist.svalue[p],xlist.s[xnamelist.svalue[p]],false);
str__saddb(@a,
xtotallabel(true,xnamelist.count,'mime type','s')+'  Entires marked in <span class="red">red</span> indicate a custom mime type.'+#10+
'The "*" file type is the fallback mime type used for unknown file types.'+#10+
'');

//set
result:=str__text(@a);
except;end;
try
str__free(@a);
freeobj(@xlist);
freeobj(@xnamelist);
except;end;
end;
//## hits__extcounts ##
function hits__extcounts(xext:string):boolean;
begin
result:=(xext='htm') or (xext='html');
end;
//## xmimetype ##
function xmimetype(xext:string):string;//09apr2024: updated to allow minor modification to "html", includes common fallback defaults - 26dec2923
begin
result:='';

try
//get
result:=imime.s[xext];

//.special case check -> enforce safe value for "html" - 09apr2024
if (xext='html') and (result<>'') then
   begin
   if (not strmatch(result,'text/html')) and (not strmatch(strcopy1(result,1,10),'text/html;')) then result:='';//force use of fallback
   end;

//fallback
if (result='') then result:=imime_fallback.s[xext];

//absolute fallback
if (result='') then
   begin
   result:=imime.s['*'];
   if (result='') then imime_fallback.s['*'];
   end;
except;end;
end;
//## xcommonheaders ##
function xcommonheaders(xext:string;xkeepalive,xcache,xacceptranges:boolean):string;
begin
result:='';

try
result:=
'Content-Type: '+xmimetype(xext)+#10+
insstr('Connection: keep-alive'+#10,xkeepalive)+
'X-Content-Type-Options: nosniff'+#10+
insstr('Referrer-Policy: no-referrer-when-downgrade'+#10,inorefdown)+
insstr('Content-Security-Policy: script-src ''none''; object-src ''none''; base-uri ''none''; require-trusted-types-for ''script'';'+#10,icsp)+
'Accept-Ranges: '+low__aorbstr('none','bytes',iresumesupport and xacceptranges)+#10+//partial download support status - 30jun2020
'Server: Bubbles'+#10+
'Date: '+igmtstr+#10+//the value is updated centrally via the "app__ontimer()" proc saving us calls to "low__gmt()" - 26dec2023
insstr('Cache-Control: public, max-age=7200, immutable'+#10,xcache and icache)+
'';
except;end;
end;
//## header__make ##
function header__make(var a:pnetwork;xcode:longint;xacceptranges,xcustom404:boolean;xval,xtext,xmoreheaders:string):boolean;
var
   m:tnetbasic;
   buf:pobject;
   xfilesize:comp;
   xfiledate:tdatetime;
begin
//defaults
result:=false;

try
//get
if net__recinfo(a,m,buf) then
   begin
   //custom "404.html" in root folder of disk site - 19feb2024
   if (xcode=404) and xcustom404 and (xtext='') then
      begin
      m.wfilename:=m.hdiskhost+'/404.html';
      m.wmode:=wsmRAM;//start with RAM, preappends the "root folder" before the path+filename if required - 25feb2024
      if xfromfile64(m,0,xfilesize,xfiledate,maxint,true,true) then xtext:=str__text(@m.buf);
      end;

   //header
   str__settextb(buf,
   'HTTP/1.1 '+inttostr(xcode)+#32+xcodedes(xcode)+#10+
   'Content-Length: '+inttostr(low__length(xtext))+#10+
   insstr('Location: '+xval+#10,(xcode=307) or (xcode=308) )+//redirection header -> note: only include path+name e.g. "/admin/index.html" as the client insert the host name - 26dec2023
   xcommonheaders('html',m.hka,false,xacceptranges)+
   xmoreheaders+
   #10+
   insstr(xtext,m.hwantdata));

   //set
   m.wcode:=xcode;//for logs
   m.wlen:=str__len(buf);
   m.wheadlen:=frcmin64( sub64(m.wlen, low__inscmp(low__length(xtext),m.hwantdata) ) ,0);

   //successful
   result:=true;
   end;
except;end;
end;
//## header__make206 ##
function header__make206(var a:pnetwork;xpartFROM,xpartTO,xFILESIZE:comp;xdate:tdatetime;xcache:boolean):boolean;
var
   m:tnetbasic;
   buf:pobject;
begin
//defaults
result:=false;

try
//get
if net__recinfo(a,m,buf) then
   begin
   str__settextb(buf,
   'HTTP/1.1 206'+#32+xcodedes(206)+#10+
   'Content-Length: '+intstr64(frcmin64(add64(sub64(xpartTO,xpartFROM),1),0))+#10+//from-part+1
   'Content-Range: bytes '+intstr64(xpartFROM)+'-'+intstr64(xpartTO)+'/'+intstr64(xFILESIZE)+#10+
   xcommonheaders(m.hnameext,m.hka,xcache,true)+
   'Last-Modified: '+low__gmt(xdate)+#10+
   'Etag: '+low__makeetag(xdate)+#10+
   #10);

   //set
   m.wcode:=206;//for logs
   m.wheadlen:=str__len(buf);
   m.wlen:=add64(m.wheadlen, low__inscmp( add64(sub64(m.wto,m.wfrom),1) ,m.hwantdata) );

   //successful
   result:=true;
   end;
except;end;
end;
//## header__make3 ##
function header__make3(var a:pnetwork;xcode:longint;xacceptranges:boolean;xconlen:comp;xdate:tdatetime;xcache,xnoreferrer:boolean;xmoreheaders:string):boolean;
var
   m:tnetbasic;
   buf:pobject;
begin
//defaults
result:=false;

try
//get
if net__recinfo(a,m,buf) then
   begin
   //range
   xconlen:=frcmin64(xconlen,0);

   //get
   str__settextb(buf,
   'HTTP/1.1 '+inttostr(xcode)+#32+xcodedes(xcode)+#10+
   'Content-Length: '+intstr64(xconlen)+#10+
   insstr('Referrer-Policy: strict-origin-when-cross-origin'+#10,xnoreferrer)+//used by inbox to prevent url leakage in an admin session - 29feb2024
   xcommonheaders(m.hnameext,m.hka,xcache,xacceptranges)+
   xmoreheaders+
   'Last-Modified: '+low__gmt(xdate)+#10+
   'Etag: '+low__makeetag(xdate)+#10+
   #10);

   //set
   m.wcode:=xcode;//for logs
   m.wheadlen:=str__len(buf);
   m.wlen:=add64(m.wheadlen, low__inscmp(xconlen,m.hwantdata) );

   //successful
   result:=true;
   end;
except;end;
end;
//## header__make4 ##
function header__make4(var a:pnetwork;xcode:longint;xacceptranges,xmustclose,xfirstwrite:boolean):boolean;
var
   m:tnetbasic;
   buf:pobject;
begin
//pass-thru
result:=true;

try
//get
if net__recinfo(a,m,buf) then
   begin
   header__make(a,xcode,xacceptranges,true,'','','');//05apr2024
   m.writing:=true;
   if xmustclose then a.mustclose:=true;
   if xfirstwrite then stm__writedata3(a);
   end;
except;end;
end;
//## stm__readdata1 ##
procedure stm__readdata1(var a:pnetwork);
label
   skipend;
var
   m:tnetbasic;
   buf:pobject;//pointer only
   blen,int1,int2,int3,xpos,xmin,p,p2,len:longint;
   xonce__forwarded_for,bol1:boolean;
   str1,n,v,v2:string;
   //## xhavercode ##
   function xhavercode:boolean;
   var
      blen,p:longint;
      v,v1:byte;
   begin
   result:=false;

   try
   //defaults
   result:=m.r10 or m.r13;
   //init
   blen:=str__len(buf);
   //get
   if (not result) and (blen>=2) then
      begin
      for p:=0 to (blen-2) do
      begin
      v:=str__bytes0(buf,p);
      v1:=str__bytes0(buf,p+1);

      if (v=13) and (v1=10) then
         begin
         m.r13:=true;
         m.r10:=true;
         result:=true;
         break;
         end
      else if (v=13) and ((v1=13) or (v1<>10)) then
         begin
         m.r13:=true;
         result:=true;
         break;
         end
      else if (v=10) and ((v1=10) or (v1<>10)) then
         begin
         m.r10:=true;
         result:=true;
         break;
         end;
      end;//p
      end;
   except;end;
   end;
   //## xnextnv ##
   function xnextnv(var xpos:longint;xhlen:longint;var n,v,v2:string):boolean;//fixed - 05jan2024
   label
      redo,redo2;
   var
      int1,int2,lp,r,r2,xlen,p:longint;
      xfirstline:boolean;
   begin
   //defaults
   result:=false;

   try
   n:='';
   v:='';
   v2:='';
   //get
   xlen:=frcrange32(xhlen,0,str__len(buf));
   if (xlen<=0) or (xpos>=xlen) then exit;
   if (xpos<0) then xpos:=0;
   xfirstline:=(xpos<=0);
   lp:=xpos;
   //.r
   if m.r13 and m.r10 then
      begin
      r:=13;
      r2:=10;
      end
   else if m.r10 then
      begin
      r:=10;
      r2:=10;
      end
   else if m.r13 then
      begin
      r:=13;
      r2:=13;
      end
   else
      begin
      r:=10;
      r2:=10;
      end;
   //find
   redo:
   if (str__bytes0(buf,xpos)=r) then
      begin
      //.firstline
      if xfirstline then
         begin
         int1:=lp;
         int2:=0;
         for p:=lp to xpos do if (str__bytes0(buf,p)=ssSpace) then
            begin
            //get
            case int2 of
            0:n:=str__str1(buf,int1+1,p-int1);
            1:begin
               v:=str__str1(buf,int1+1,p-int1);
               v2:=str__str1(buf,p+2,xpos-(p+2)+1);
               break;
               end;
            end;//case
            //inc
            int1:=p+1;
            inc(int2);
            end;//p
         end
      else
         begin
         //.split into name value pair
         for p:=lp to xpos do if (str__bytes0(buf,p)=sscolon) then
            begin
            n:=str__str1(buf,lp+1,p-lp);
            v:=str__str1(buf,p+3,xpos-(p+3)+1);
            break;
            end;
         end;
      //.jump past return code
      redo2:
      inc(xpos);
      if (xpos<xlen) and ( (str__bytes0(buf,xpos)=r) or (str__bytes0(buf,xpos)=r2) ) then goto redo2;
      //successful
      result:=true;
      end
   else
      begin
      inc(xpos);
      if (xpos<xlen) then goto redo;
      end;
   except;end;
   end;
   //## xreadcookies ##
   procedure xreadcookies(var x:string);
   var
      xlen,lp,p:longint;
      n,v:string;
      c:byte;
   begin
   //init
   x:=x+';';
   xlen:=low__length(x);

   //check
   if (xlen<=2) then exit;

   //get
   lp:=1;
   for p:=1 to xlen do
   begin
   c:=byte(x[p-1+stroffset]);
   if (c=ssEqual) then
      begin
      n:=strlow(strcopy1(x,lp,p-lp));
      lp:=p+1;
      end
   else if (c=ssSemicolon) then
      begin
      if (n<>'') then
         begin
         //init
         v:=strcopy1(x,lp,p-lp);

         //get
         if (n='k') then m.hcookie_k:=v;
         //more cookies go here

         end;
      lp:=p+1;
      //reset
      n:='';
      v:='';
      end;
   end;//p

   end;
begin
try
//check
if not net__recinfo(a,m,buf) then exit;

//read more data
len:=net____recv(a.sock,ibuffer,sizeof(ibuffer),0);
if (len>=1) then
   begin
   //boost
   imustboost:=true;

   //time
   a.time_idle:=ms64;
   a.infolastmode:=1;//reading
   if not m.vmustlog then m.vmustlog:=true;//mark to be logged

   //daily bandwidth counter
   xinc_daily_bandwidth(len);

   //information vars - set once
   if m.vonce then
      begin
      m.vonce:=false;
      m.vstarttime:=ms64;
      case ireverseproxy of
      false:m.hip:=inttostr(a.sock_ip4.b0)+'.'+inttostr(a.sock_ip4.b1)+'.'+inttostr(a.sock_ip4.b2)+'.'+inttostr(a.sock_ip4.b3);//use socket's ip by default
      true:m.hip:='0.0.0.0';//we don't know the client's ip address till we read it from the header
      end;
      a.infolastip:=m.hip;//06apr2024
      a.used:=add64(a.used,1);
      //.request load tracking
      if (irequestrate0<maxint) then inc(irequestrate0);
      end;

   //add to buffer
   str__addrec(buf,@ibuffer,len);
   blen:=str__len(buf);

   //track upload bandwidth #1 -> can only do this once a "hslot" is set
   if (m.hslot>=0) then ipsec__incBytes(m.hslot,str__len(buf));


   //counters
   m.hread:=add64(m.hread,len);//this request
   net__inccounters(len,0);

   //reading header
   if (m.hlen<=0) then
      begin
      //.need 4+ bytes to scan header meaningfully
      if (blen<4) then goto skipend;
      //.can't determine return code type -> need more header to arrive
      if (not xhavercode) and (blen<=imaxheadersize) then goto skipend;
      //.find end of header -> can't, need more header
      if (m.hlenscan>=blen) and (blen<=imaxheadersize) then goto skipend;
      //.find
      xmin:=frcmin32(m.hlenscan-6,0);//start back a bit - 05jan2024
      if m.r13 and m.r10 then
         begin
         for p:=xmin to (blen-4) do
         begin
         m.hlenscan:=p;
         if (str__bytes0(buf,p)=13) and (str__bytes0(buf,p+1)=10) and (str__bytes0(buf,p+2)=13) and (str__bytes0(buf,p+3)=10) then
            begin
            m.hlen:=p+4;
            break;
            end;
         end;//p
         end
      else if m.r10 then
         begin
         for p:=xmin to (blen-2) do
         begin
         m.hlenscan:=p;
         if (str__bytes0(buf,p)=10) and (str__bytes0(buf,p+1)=10) then
            begin
            m.hlen:=p+2;
            break;
            end;
         end;//p
         end
      else if m.r13 then
         begin
         for p:=xmin to (blen-2) do
         begin
         m.hlenscan:=p;
         if (str__bytes0(buf,p)=13) and (str__bytes0(buf,p+1)=13) then
            begin
            m.hlen:=p+2;
            break;
            end;
         end;//p
         end;

      //IMPORTANT: length check -> request fields too large 431
      if (m.hlen<=0) and (blen>imaxheadersize) then
         begin
         //force the header to be read with what we've got as we're aborting the process
         m.hlen:=blen;
         m.htoobig:=true;//signal the intention to abort AFTER the head is read
         end;

      //check
      if (m.hlen<=0) then goto skipend;

      //process the header
      xonce__forwarded_for:=true;
      xpos:=0;
      bol1:=true;
      while xnextnv(xpos,m.hlen,n,v,v2) do
      begin
      //.1st line -> request line -> e.g. "GET /index.html HTTP/1.1"
      if bol1 then
         begin
         //.method
         if      strmatch(n,'head')    then m.hmethod:=hmHEAD
         else if strmatch(n,'get')     then m.hmethod:=hmGET
         else if strmatch(n,'post')    then m.hmethod:=hmPOST
         else if strmatch(n,'connect') then m.hmethod:=hmCONNECT
         else                               m.hmethod:=hmUNKNOWN;

         //.http version
         if      strmatch(v2,'http/1.0')    then m.hver:=hv1_0
         else if strmatch(v2,'http/1.1')    then m.hver:=hv1_1
         else if strmatch(v2,'http/0.9')    then m.hver:=hv0_9
         else                                    m.hver:=hvUnknown;

         //.path + name
         if (v<>'') then
            begin
            for p:=low__length(v) downto 1 do if (strbyte1(v,p)=ssSlash) then
               begin
               m.hpath:=strcopy1(v,1,p);
               m.hname:=strcopy1(v,p+1,low__length(v));
               if (m.hname<>'') then
                  begin
                  for p2:=1 to low__length(m.hname) do if (strbyte1(m.hname,p2)=ssquestion) then
                     begin
                     m.hgetdat:=strcopy1(m.hname,p2+1,low__length(m.hname));
                     m.hname:=strcopy1(m.hname,1,p2-1);
                     break;
                     end;//p2
                  end;
               break;
               end;
            //decode strs
            m.hpath:=net__decodestrb(m.hpath);
            m.hname:=net__decodestrb(m.hname);

            //clean                http://                         https://                           ftp://
            if (strcopy1(m.hpath,5,3)='://') or (strcopy1(m.hpath,6,3)='://') or (strcopy1(m.hpath,4,3)='://') then
               begin
               //.this is probably a proxy request -> strip the leading protocol and domain sections
               bol1:=true;
               int3:=0;
               int2:=-1;
               for p:=1 to low__length(m.hpath) do
               begin
               int1:=byte(m.hpath[p-1+stroffset]);
               case int1 of
               ssLSquarebracket:inc(int3);
               ssRSquarebracket:dec(int3);
               //.scan -> skip over IPv6 name space "https://[....]:<port #>/..normal path and file name.."
               else
                  begin
                  if (int3=0) then
                     begin
                     if bol1 and (int1<>ssSlash) and (int2=ssSlash) then bol1:=false;
                     if not bol1 and (int1=ssSlash) then
                        begin
                        m.hpath:=strcopy1b(m.hpath,p,low__length(m.hpath));
                        break;
                        end;
                     end;
                  end;
               end;//case
               //.last character
               int2:=int1;
               end;//p
               end;
            end;
         //.enforce a trailing slash "/" on "hpath" field - 25dec2023
         if (strlast(m.hpath)<>'/') then m.hpath:=m.hpath+'/';
         bol1:=false;
         end
      //.2nd+ lines -> name + value pairs
      else
         begin
         if strmatch(n,'host') then
            begin
            if (v<>'') then m.hhost:=v;
            end
         else if strmatch(n,'range')            then m.hrange:=v//client is requesting a partial download, e.g. "Range: bytes=0-499"
         else if strmatch(n,'if-range')         then m.hif_range:=v//GMT date OR ETAG comparison
         else if strmatch(n,'if-match')         then m.hif_match:=xstrcopyto(v,',')//strong (byte accurate) ETAG only -> use first ETAG only
         else if strmatch(n,'connection') then
            begin
            if strmatch(v,'keep-alive')         then m.hconn:=hcKeepalive
            else if strmatch(v,'close')         then m.hconn:=hcClose
            else                                     m.hconn:=hcUnknown;
            end
         else if strmatch(n,'content-length')   then m.clen:=strint64(v)
         else if strmatch(n,'content-type')     then m.hcontenttype:=v//content-type
         else if strmatch(n,'user-agent')       then m.hua:=v
         else if strmatch(n,'cookie')           then xreadcookies(v)
         else if strmatch(n,'referer')          then m.hreferer:=v
         else if strmatch(n,'x-forwarded-for')  then//Important Note: Standard states multiple "x-forwarded-for" headers CAN exist, importance order is from 1st to last, where 1st contains the client's IP address
            begin
            //WARNING: Only permitted in a reverse proxy situation, otherwise value might be spoofed
            if ireverseproxy and xonce__forwarded_for then
               begin
               xonce__forwarded_for:=false;
               m.hip:=xstrcopyto(v,',');//read in first entry only  -> offical format is "x-forwarded-for: <client>, <proxy1>, <proxy2>"  where <client>..<proxy 2> are IP addresses (IPv4 or IPv6)
               a.infolastip:=m.hip;//06apr2024
               end;
            end
         else if strmatch(n,'x-forwarded-host') then//there is only one entry for this
            begin
            //WARNING: Only permitted in a reverse proxy situation, otherwise value might be spoofed
            if ireverseproxy and (v<>'') then m.hhost:=v;
            end;
         end;
      end;//end of "while xnextnv"

      //finalise special vars --------------------------------------------------

      //.keep alive mode
      // 1. ireverseproxy=true => This server is acting behind a front end server, and so connections are between that server and us, and must be kept alive
      // 2. hver=hv1_1 (http/1.1) => this protocol assumes the connection is kept alive unless specially stated to close
      // 3. Older protocols may not support/must specify a connection is to be kept alive
      if ireverseproxy        then m.hka:=true
      else if (m.hver=hv1_1)  then m.hka:=(m.hconn<>hcClose)//http/1.1 connections assume keep-alive unless otherwise specified
      else                         m.hka:=(m.hconn=hcKeepalive);

      //.automatic "index.html"
      if (m.hname='') then m.hname:='index.html';

      //.name extensions (lower caser)
      m.hnameext:=io__readfileext_low(m.hname);

      //.hport
      if (m.hhost<>'') then
         begin
         int3:=0;

         for p:=1 to low__length(m.hhost) do
         begin
         int1:=byte(m.hhost[p-1+stroffset]);
         case int1 of
         ssLSquarebracket:inc(int3);//within an IPv6 host which has format "[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443" from an input such as this "https://[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443/"
         ssRSquarebracket:dec(int3);
         ssColon,ssSlash:begin
            if (int3=0) then
               begin
               if (int1=ssColon) then m.hport:=restrict32(strint64(strcopy1b(m.hhost,p+1,low__length(m.hhost))));
               m.hhost:=strcopy1(m.hhost,1,p-1);//IPv6 starts and ends with [..] square brackets
               break;
               end;
            end;//begin
         end;//case

         end;//p
         end;

      //.resolve host -> cleans "hhost" and sets "hdesthost" and "hdiskhost" fields using "imap" - 25dec2023
      xresolvehost(m);

      //.ipsec security tracking
      m.hslot:=ipsec__trackb(m.hip);//we should have a valid client ip address by this stage
      ipsec__incBytes(m.hslot,blen);

      //.are we logged into the admin panel?
      if strmatch(strcopy1b(m.hpath,1,low__lengthb(iadminpath)),iadminpath) and xextractsessionname(m.hpath,str1) then
         begin
         if xsessionok(str1,m.hcookie_k,m.hua,m.hip,m.hname,int1) then
            begin
            m.vsessname:=str1;
            m.vsessvalid:=true;
            m.vsessindex:=int1;
            end;
         //.track bad logins -> always allow this tracking
         //was: if not m.vsessvalid then ipsec__incbad(m.hslot);
         end;


      //.client is banned (rate limited) -> abort right now BUT only if we're not logged into admin panel
      if (not m.vsessvalid) and ipsec__banned(m.hslot) and header__make4(a,403,true,true,true) then goto skipend;

      //.too many simultaneous connections -> don't enforce limit when using admin panel
      if (not m.vsessvalid) and ipsec__incConn(m.hslot,true) and header__make4(a,503,true,true,true) then goto skipend;

      //IMPORTANT: The header was too big, so we must abort here
      if m.htoobig and header__make4(a,431,true,true,true) then goto skipend;

      //.remove header from buffer
      if (m.clen=0) then str__softclear2(buf,ibufferlimit) else str__del3(buf,0,m.hlen);

      //.upload size limit check -> do before receiving large data -> normal=small and admin=large -> content too large 413
      if (m.clen>low__aorb(imaxuploadsize_normal,imaxuploadsize_admin,m.vsessvalid)) and header__make4(a,413,true,true,true) then goto skipend;
      end;//end of "reading header"


   //.actual upload size check
   if (str__len(buf)>low__aorb(imaxuploadsize_normal,imaxuploadsize_admin,m.vsessvalid)) and header__make4(a,413,true,true,true) then goto skipend;


   //header+content => read => done
   if (m.hread>=add64(m.hlen,low__inscmp(m.clen,m.hmethod=hmpost))) then//only POST should have body data
      begin
      //inc hit counter BUT NOT for admin documents -> only broadcast facing documents
      if (not m.vsessvalid) and hits__extcounts(m.hnameext) then xinchit(m.hdiskhost);

      //hwantdata
      m.hwantdata:=(m.hmethod=hmget) or (m.hmethod=hmpost);


      //create a reply for the client
      if (m.hmethod=hmget) or (m.hmethod=hmpost) or (m.hmethod=hmhead) then stm__makereply2(a)
      else
         //bad request
         begin
         if header__make4(a,400,true,false,false) then goto skipend;
         end;


      //something went wrong -> use default reply
      if not m.writing then
         begin
         if header__make4(a,404,true,false,false) then goto skipend;
         end;

      //do frist write
      stm__writedata3(a);
      end;
   end
else a.canread:=false;

skipend:
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxx//555555555555555555
//## xcolumnRight ##
function xcolumnRight(x:string):string;
begin
result:=low__rcolumn(x,17);
end;
//## xminiconsole ##
function xminiconsole:string;
begin
result:='';
try;result:='<div class="console2 miniinfo">RAM used '+low__mbauto(irambytes,true)+' &nbsp; &nbsp; Files cached (all sites) '+k64(iramfilescached)+' of '+k64(iramfilecount)+'</div>'+#10;except;end;
end;
//## xpowerlevel ##
function xpowerlevel:string;
var
   v,p:longint;
begin
result:='<label for="powerlevel">Power Level </label><select id="powerlevel" name="powerlevel">';
for p:=1 to (ipowerlimit div 5) do
begin
v:=frcrange32(p*5,1,ipowerlimit);
result:=result+'<option value="'+inttostr(v)+'"'+insstr(' selected',v=ipowerlevel)+'>'+inttostr(v)+'%</option>';
end;//p
result:=result+'</select>';
end;
//## xsetdaily_bandwidth_quota ##
procedure xsetdaily_bandwidth_quota(xquota_in_mb:comp);
begin
idaily_bandwidth_quota:=app__cvalset('daily.bandwidth.quota',xquota_in_mb);
if (idaily_bandwidth_quota<=0) then
   begin
   //reset critical tracking & state vars
   idaily_bandwidth:=0;
   idaily_bandwidth_exceeded:=false;
   end
else if (idaily_bandwidth_quota<10) then idaily_bandwidth_quota:=10;

idaily_bandwidth_quota_bytes:=mult64(idaily_bandwidth_quota,1000000);//mb -> bytes
end;
//## stm__makereply2 ##
procedure stm__makereply2(var a:pnetwork);
label
   skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   mtmp:tnetbasic;
   xoldramlimit,xoldport,int1:longint;
   xoldthreshold:comp;
   hname_low,xloginstatus,xpassstatus,xcmd,xcmd2,str1,str2,str3:string;
   xalongsideexe,xmustreload:boolean;
   //## xrefreshcookie ##
   function xrefreshcookie:string;//periodicially update admin session cookie
   begin
   if m.vsessvalid and (sub64(ms64,isessioncookietime[m.vsessindex])>=icookietimeout) then result:=m.hcookie_k else result:='';
   end;
   //## xheadonly ##
   function xheadonly(xcode:longint;xacceptranges:boolean):boolean;
   begin
   result:=true;//pass-thru
   try
   header__make3(a,xcode,xacceptranges,0,now,false,false,'');
   m.writing:=true;
   except;end;
   end;
   //## xheadonly2 ##
   function xheadonly2(xcode:longint;xacceptranges:boolean;xval,xtext,xmoreheaders,xsessioncookie:string):boolean;
   begin
   result:=true;//pass-thru
   //.add cookie to xmoreheaders as a "set-cookie" header value
   if (xsessioncookie<>'') then
      begin
      xmoreheaders:=xmoreheaders+'set-cookie: k='+xsessioncookie+';path='+iadminpath+';httponly;samesite:strict;max-age='+intstr64(div64(isessiontimeout,1000))+';'+#10;
      isessioncookietime[m.vsessindex]:=ms64;//reset the cookie timeout
      end;
   //.make the header
   header__make(a,xcode,xacceptranges,true,xval,xtext,xmoreheaders);
   m.writing:=true;
   end;
   //## xhead3 ##
   function xhead3(xcode:longint;xacceptranges:boolean;xdata:pobject;xdate:tdatetime;xcache,xincludedata:boolean):boolean;
   begin
   result:=true;//pass-thru
   try
   header__make3(a,xcode,xacceptranges,str__len(xdata),xdate,xcache,false,'');
   if str__lock(xdata) then
      begin
      if xincludedata then str__add(buf,xdata);
      str__uaf(xdata);
      end;
   m.wlen:=str__len(buf);//override the value set by "header__make3"
   m.writing:=true;
   except;end;
   end;
   //## xwriting ##
   function xwriting(xreset_buf8:boolean):boolean;
   begin
   result:=true;//pass-thru
   try
   if xreset_buf8 then str__softclear2(@ibuf2,ibufferlimit);
   m.wlen:=str__len(buf);
   m.writing:=true;
   except;end;
   end;
   //## xreadpost 3#
   procedure xreadpost;
   label
      skipend;
   var
      xlog:tstr9;
      xtotal,xokcount,xerrcount,xpos:longint;
      n,e,xsite,xcmd,xname,xfilename,xcontenttype,xboundary:string;
      xoutdata:tstr9;
   begin
   try
   //defaults
   xoutdata:=nil;
   xlog:=nil;
   ivars.clear;
   xtotal:=0;
   xokcount:=0;
   xerrcount:=0;

   //get
   if (m.clen>=1) then
      begin
      if net__ismultipart(m.hcontenttype,xboundary) then
         begin
         //only Admin pages are permitted to upload a multi-part form
         if not m.vsessvalid then goto skipend;

         //init
         xlog:=str__new9;
         xoutdata:=str__new9;
         xpos:=0;
         xcmd:='';
         xsite:='';

         //get
         while true do
         begin
         if not str__multipart_nextitem(buf,xpos,xboundary,xname,xfilename,xcontenttype,@xoutdata) then break;

         //var
         if (xname<>'') and (xfilename='') then ivars.s[xname]:=str__text(@xoutdata);

         //cmd
         if (xfilename='') and strmatch('cmd',xname) then
            begin
            xcmd:=strlow(str__text(@xoutdata));
            //get
            if (strcopy1(xcmd,1,14)='manage.upload.') then
               begin
               xsite:=io__extractfilename(strcopy1(xcmd,15,low__length(xcmd)));
               ivars.s['site']:=xsite;
               net__decodestr(xsite);
               xcmd:='manage.upload';
               end;
            end;

         //decide
         if (xfilename<>'') and (xcmd='manage.upload') and (xsite<>'') then
            begin
            if strmatch(strcopy1(xsite,1,low__lengthb(idefaultdisksite)),idefaultdisksite) and idom.b[xsite] then//site must exist
               begin
               n:=io__extractfilename(xfilename);
               if (n<>'""') then
                  begin
                  case io__tofile64(io__asfolder(ifastfolder__root+xsite)+n,@xoutdata,e) of
                  true:begin
                     inc(xtotal);
                     inc(xokcount);
                     str__saddb(@xlog,'[ OK ]  '+xcolumnRight(k64(xoutdata.len))+'  '+n+#10);
                     end;
                  false:begin
                     inc(xtotal);
                     inc(xerrcount);
                     str__saddb(@xlog,'[FAIL]  '+n+#10);
                     end;
                  end;//case
                  end;
               end;
            end;
         end;//while

         //upload info
         if (xcmd='manage.upload') then
            begin
            ivars.s['manage.upload.log']:=str__text(@xlog);
            ivars.i['total']:=xtotal;
            ivars.i['okcount']:=xokcount;
            ivars.i['errcount']:=xerrcount;
            ivars.c['upload.size']:=m.clen;
            end;
         end
      else ivars.nettext:=str__text(buf);
      end;
   skipend:
   except;end;
   try
   str__free(@xoutdata);
   str__free(@xlog);
   except;end;
   end;
begin
try
//defaults
mtmp:=nil;

//check
if not net__recinfo(a,m,buf) then exit;


//bad requests -----------------------------------------------------------------
//.deny "connect" requests
if (m.hmethod=hmconnect) and xheadonly(400,true) then goto skipend;


//system files -----------------------------------------------------------------
//init
hname_low:=strlow(m.hname);

//".hits.png" -> per disk domain
if (hname_low='.hits.png') then
   begin
   if ihitpng.sfound8(m.hdiskhost,@ibuf2,false,int1) then xhead3(200,false,@ibuf2,now,false,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end
//".totalhits.png" -> for ALL domains combined
else if (hname_low='.totalhits.png') then
   begin
   if ihitpng.sfound8('total',@ibuf2,false,int1) then xhead3(200,false,@ibuf2,now,false,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end
//".bubbles.png"
else if (hname_low='.bubbles.png') then
   begin
   if (ibubbles_png.len>=1) then xhead3(200,false,@ibubbles_png,iloaddate,true,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end;

//admin ------------------------------------------------------------------------
if strmatch(strcopy1b(m.hpath,1,low__lengthb(iadminpath)),iadminpath) then
   begin
   //check - we don't accept HEAD request for admin
   if (not m.hwantdata) and xheadonly(400,false) then goto skipend;

   //."/admin/bubbles.ico" -> we don't need to be logged in for access to this icon
   if (hname_low='bubbles.ico') then
      begin
      if (ibubbles_ico_32px.len>=1) then xhead3(200,false,@ibubbles_ico_32px,iloaddate,true,m.hwantdata) else xheadonly(404,false);
      goto skipend;
      end;

   //init
   xloginstatus:='';
   xpassstatus:='';
   xmustreload:=false;

   //get
   //.read ANY post data inbound to admin pages
   xreadpost;

   //.root admin "/admin/" which only a few accessible pages "index.html/console.html/log--<date name of log file>/etc", else trigger a 403 error
   if strmatch(m.hpath,iadminpath) then
      begin
      //.login page
      if (hname_low='') or (hname_low='index.html') then
         begin                                                                                                                                                                               //secure; <- requires https:// website for cookies to work, we want to be able to login via http:// in cases of emergency or https failure, and partitioned; requires secure; to work - 27mar2024
//was:   if xnewsession(ivars.s['password'],m.hua,m.hip,str2,str3,int1) and xheadonly2(307,false,'/admin/'+str2+'/','','set-cookie: k='+str3+';path=/admin/;httponly;partitioned;samesite:strict;max-age='+intstr64(div64(isessiontimeout,1000))+';'+#10) then goto skipend
         if xnewsession(ivars.s['password'],m.hua,str2,str3,int1) and xheadonly2(307,false,iadminpath+str2+'/','','',str3) then goto skipend
         else
            begin
            if (ivars.s['password']<>'') then
               begin
               xloginstatus:='<div class="bad">Login failed.  Incorrect login details.</div>';
               //.track bad logins
               if not m.vsessvalid then ipsec__incbad(m.hslot);
               end;

            //login form -> punch back to main page when within a sub-frame, such as the inbox message pane - 08feb2024
            str1:=
            xhtmlstart(a,false)+
            xh2b('login',app__info('name')+' Login','nobotmargin')+
            '<div class="vsep"></div>'+#10+
            xloginstatus+
            '<form method=post action="index.html" target="_top">'+#10+
            '<div class="grid2">'+#10+
            '<div>Password<br><input class="text" name="password" type="password" value=""></div>'+#10+
            '</div>'+#10+
            '<div class="vsep"></div>'+#10+
            '<input class="button" type=submit value=" Login ">'+#10+
            '</form>'+#10+
            xhtmlfinish;
            //reply
            if xheadonly2(200,false,'',str1,'','') then goto skipend;
            end;
         end

      //.all other pages at "/admin/" are invalid and must return a 403 error
      else if xheadonly(403,false) then goto skipend;
      end;

   //.session name not valid or has timed out -> redirect to login page (include "index.html" for easier debugging of set-cookie failure) - 27mar2024
   if (not m.vsessvalid) and xheadonly2(307,false,iadminpath+'index.html','','','') then goto skipend;

   //---------------------------------------------------------------------------
   //---------------------------------------------------------------------------
   //init
   xoldport:=iport;


   //get - process commands
   xcmd:=strlow(ivars.s['cmd']);
   xcmd2:=strlow(ivars.s['cmd2']);//alternative parallel command

   //.settings
   if (xcmd='settings') then
      begin
      //get
      xoldthreshold:=ithreshold;
      xoldramlimit:=iramlimit;
      //set
      ithreshold     :=app__cvalset('threshold',ivars.c['threshold']);
      iramlimit      :=app__ivalset('ramlimit',ivars.i['ramlimit']);
      xsetdaily_bandwidth_quota(ivars.c['quota']);

      int1:=ivars.i['port']; if (int1<2) then int1:=idefaultport;
      iport          :=app__ivalset('port',int1);

      ishutidle      :=ivars.checked['shutidle'];
      xalongsideexe  :=ivars.checked['alongsideexe'];
      ireverseproxy  :=ivars.checked['reverseproxy'];
      isummarynotice :=ivars.checked['summary.notice'];
      iquotanotice   :=ivars.checked['quota.notice'];
      ireloadnotice  :=ivars.checked['reload.notice'];
      icsp           :=ivars.checked['csp'];
      inorefdown     :=ivars.checked['norefdown'];
      icache         :=ivars.checked['cache'];
      ilivestats     :=ivars.checked['livestats'];
      irawlogs       :=ivars.checked['rawlogs'];

      //.power level
      ipowerlevel:=app__ivalset('powerlevel',ivars.i['powerlevel']);

      //.reload on critical var value change
      if (xoldramlimit<>iramlimit) or (xoldthreshold<>ithreshold) then xmustreload:=true;

      //.conn limit
      int1:=iconnlimit;
      iconnlimit:=app__ivalset('connlimit',ivars.i['connlimit']);
      if (iconnlimit<int1) then imustcloseall:=true;

      //.trigger a save event
      imustsavesettings:=true;

      //.trigger a reload
      if low__setbol(ialongsideexe,xalongsideexe) then xmustreload:=true;
      end;

   //.limits
   if (xcmd='limits') then
      begin
      ipsec__setvals(ivars.i['scanfor'],ivars.i['banfor'],ivars.i['simconnlimit'],ivars.i['postlimit'],ivars.i['badlimit'],ivars.i['hitlimit'],mult64(ivars.c['datalimit'],1024000));
      //.trigger a save event
      imustsavesettings:=true;
      end;
   if (xcmd='hits') and (xcmd2='') then
      begin
      ihit.text:=ivars.s['hitinfo'];
      //.trigger a save event
      imustsavesettings:=true;
      end;
   if (xcmd='map') then
      begin
      imap.text:=ivars.s['mapinfo'];
      //.trigger a save event
      imustsavesettings:=true;
      end;
   if (xcmd='mime') then
      begin
      imime.text:=ivars.s['mimetypes'];
      //.trigger a save event
      imustsavesettings:=true;
      end;
   if (xcmd='contact') then
      begin
      icontact_question :=ivars.checked['contact.question'];
      icontact_allow    :=ivars.checked['contact.allow'];
      icontact_off      :=ivars.s['contact.off'];
      icontact_ok       :=ivars.s['contact.ok'];
      icontact_fail     :=ivars.s['contact.fail'];
      //.trigger a save event
      imustsavesettings:=true;
      end;
   if (xcmd='mail') then
      begin
      imail_allow     :=ivars.checked['mail.allow'];
      imail_domain    :=ivars.s['mail.domain'];
      imail_sizelimit :=app__ivalset('mail.sizelimit',ivars.i['mail.sizelimit']);
      //.trigger a save event
      imustsavesettings:=true;
      end;
   if (xcmd='unbanall') or (xcmd2='unbanall') then ipsec__clearall;
   if (xcmd='closeall') or (xcmd2='closeall') then imustcloseall:=true;
   if (xcmd='newpass') then
      begin
      if xpassword_ok(ivars.s['password']) then
         begin
         //init
         str1:=ivars.s['pass1'];
         str2:=ivars.s['pass2'];
         //check
         if (str1<>str2)               then xpassstatus:='<div class="bad">The new passwords do not match.  Please try again.</div>'
         else if (low__length(str1)<5) then xpassstatus:='<div class="bad">The new password is too short.  It must be 5 characters or more.</div>'
         else
            begin
            iadminkey:=xmakehash(str1);
            xpassstatus:='<div class="good">The new admin password has been set and will be reflected the next time you login.</div>';
            //.trigger a save event
            imustsavesettings:=true;
            end;
         end
      else
         begin
         xpassstatus:='<div class="bad">Access Denied.  Incorrect login details.</div>';
         end;
      end;
   if (xcmd='reload') then xmustreload:=true;
   if (xcmd='flush') then imustcloseall:=true;
   //.console
   if strmatch(strcopy1(xcmd,1,8),'console.') then
      begin
      iconsolerate:=app__ivalset('consolerate',strint(strcopy1(xcmd,9,low__length(xcmd))));
      //.trigger a save event
      imustsavesettings:=true;
      end;

   //port - detect port change and redirect to new page
   if (xoldport<>iport) then
      begin
      imustport:=true;//tell server to load new port immediately
      imustcloseall:=true;//close all connections
      if xheadonly2(307,false,'http'+insstr('s',iport=443)+'://'+m.hhost+insstr(':'+inttostr(iport),iport<>80)+iadminpath+m.vsessname+'/'+hname_low,'','','') then goto skipend;
      end;

   //mustreload
   if xmustreload then
      begin
      //xmustreload:=false;
      xreload(false);
      end;

   //---------------------------------------------------------------------------
   //---------------------------------------------------------------------------


   //index ---------------------------------------------------------------------
   if (hname_low='index.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+
      '<a name="top"></a>'+
      '<a name="stats"></a>'+

      //.any error messages / status messages go here
      xh2b('overview',xsymbol('overview')+'Overview','nobotmargin')+
      xvsep+
      '<form class="inlineblock" method=post action="index.html"><input name="cmd" type="hidden" value="refresh"><input class="button" title="Refresh this page" type=submit value="Refresh"></form>'+#10+
      '<form class="inlineblock" method=post action="index.html"><input name="cmd" type="hidden" value="reload"><input class="button" title="Reload the RAM cache" type=submit value="Reload Site(s)"></form>'+#10+
      '<form class="inlineblock" method=post action="logoutall.html"><input name="cmd" type="hidden" value="logoutall"><input class="button" title="Logout all Admin sessions" type=submit value="Logout All"></form>'+#10+
      xvsep+
      xinfostats+
      xvsep+
      '<form class="inlineblock" method=post action="index.html"><input name="cmd" type="hidden" value="refresh"><input class="button" title="Refresh this page" type=submit value="Refresh"></form>'+#10+
      '<form class="inlineblock" method=post action="index.html"><input name="cmd" type="hidden" value="reload"><input class="button" title="Reload the RAM cache" type=submit value="Reload Site(s)"></form>'+#10+
      '<form class="inlineblock" method=post action="logoutall.html"><input name="cmd" type="hidden" value="logoutall"><input class="button" title="Logout all Admin sessions" type=submit value="Logout All"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //settings.html -------------------------------------------------------------
   else if (hname_low='settings.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      //.settings
      xh2('settings',xsymbol('settings')+'Server Settings')+
      '<form class="inlineblock" method=post action="settings.html#settings">'+

      '<div class="grid2">'+#10+
      '<div>HTTP broadcast port (2 - '+k64(maxport)+', default is 1080)<br><input class="text" name="port" type="text" value="'+k64(iport)+'"></div>'+#10+
      '<div>Max. total connections (1 - '+k64(net__limit)+')<br><input class="text" name="connlimit" type="text" value="'+k64(iconnlimit)+'"></div>'+#10+
      '<div>Max. RAM cache size (10 - 1,500 Mb)<br><input class="text" name="ramlimit" type="text" value="'+k64(iramlimit)+'"></div>'+#10+
      '<div>Max. file size in bytes to store in RAM cache<br><input class="text" name="threshold" type="text" value="'+k64(ithreshold)+'"></div>'+#10+
      '<div>Daily Bandwidth Quota (0=none, 10-N Mb)<br><input class="text" name="quota" type="text" value="'+k64(idaily_bandwidth_quota)+'"></div>'+#10+
      '</div>'+#10+

      xminiconsole+

      '<div class="grid2">'+#10+

      '<div>'+xpowerlevel+'<br><div style="font-size:70%;">A higher power level uses more CPU for processing / streaming.  If the server is on a single core/v-core, a very high power level may starve other services/processes of CPU cycles.</div></div>'+#10+
      '<div><input name="reverseproxy" type="checkbox" '+insstr('checked',ireverseproxy)+'>Backend server - behind a frontend server like Caddy.  Untick "Shut idle connections (2m)" for persistent connections.</div>'+#10+
      '<div><input name="cache" type="checkbox" '+insstr('checked',icache)+'>Mark site content as cacheable to browsers (2h)</div>'+#10+
      '<div><input name="rawlogs" type="checkbox" '+insstr('checked',irawlogs)+'>Record raw traffic logs (*.txt)</div>'+#10+
      '<div><input name="csp" type="checkbox" '+insstr('checked',icsp)+'>Strict content security policy</div>'+#10+
      '<div><input name="norefdown" type="checkbox" '+insstr('checked',inorefdown)+'>No referrer info sent when downgrading from https to http</div>'+#10+
      '<div><input name="summary.notice" type="checkbox" '+insstr('checked',isummarynotice)+'>Bubbles daily summary notices (delivered to inbox)</div>'+#10+
      '<div><input name="quota.notice" type="checkbox" '+insstr('checked',iquotanotice)+'>Bubbles quota notices (delivered to inbox)</div>'+#10+
      '<div><input name="reload.notice" type="checkbox" '+insstr('checked',ireloadnotice)+'>Bubbles reload notices (boot/reboot/reload - delivered to inbox)</div>'+#10+
      '<div><input name="shutidle" type="checkbox" '+insstr('checked',ishutidle)+'>Shut idle connections (2m)</div>'+#10+
      '<div><input name="livestats" type="checkbox" '+insstr('checked',ilivestats)+'>Live stats via OS console window</div>'+#10+
      '</div>'+#10+

      '<div class="grid1">'+#10+
      '<div></div>'+#10+

      '<div><input name="alongsideexe" type="checkbox" '+insstr('checked',ialongsideexe)+'>Folders alongside EXE - <span class="bold">use with caution</span> as this option will change the location of your inbox, trash, logs and disk site(s) folders.<br>'+
       '<br>'+
       '<div style="font-size:70%;"><span class="underline">Not Ticked (default mode)</span>:<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'inbox<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'trash<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'logs<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+idefaultdisksite+'*<br>'+
       '<br>'+
       '<span class="underline">Ticked</span>:<br>'+
       net__encodeforhtmlstr(app__subfolder2('',true))+'inbox<br>'+
       net__encodeforhtmlstr(app__subfolder2('',true))+'trash<br>'+
       net__encodeforhtmlstr(app__subfolder2('',true))+'logs<br>'+
       net__encodeforhtmlstr(app__subfolder2('',true))+idefaultdisksite+'*<br>'+
       '</div></div>'+#10+
      '</div>'+#10+

      xvsep+
      '<input name="cmd" type="hidden" value="settings"><input class="button" type=submit value="Save"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //mime.html ----------------------------------------------------------------
   else if (hname_low='mime.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('mime',xsymbol('mime')+'Mime Types')+
      '<form class="block" method=post action="mime.html">'+
      'Type one file extension and mime type per line in the format "(file extension):(space)(mime type)" without the brackets and quotes.  For example: "zip: application/zip" (without quotes).  Note: The mime type for "html" is always at least "text/html"'+' for stability and security reasons.  Values may be appended to it, for instance "text/html; charset=utf-8" (without quotes).<br>'+#10+
      '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="mimetypes">'+net__encodeforhtmlstr(imime.text)+'</textarea>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="mime"><input class="button" type=submit value="Save"></form>'+#10+

      xvsep+
      '<pre class="console">'+
      xmimelist+
      '</pre>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //limits.html ----------------------------------------------------------------
   else if (hname_low='limits.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('limits',xsymbol('limits')+'Client Limits')+
      'When a client IP exceeds the <span class="bold">hit limit</span>, <span class="bold">bandwidth limit</span>, <span class="bold">post limit</span> or the <span class="bold">'+'bad login limit</span> within the specified <span class="bold">scan for</span> time period,'+' they are automatically banned and denied access to all site(s) and resources hosted by '+'Bubbles for a time period specified by <span class="bold">ban for</span>.<br><br>When the <span class="bold">ban for</span> time period elapses, they are automatically removed from the "ban list" and again allowed access to the site(s) and resources.  '+'However, a client exceeding the <span class="bold">max. simultaneous connections</span> limit is not banned, but restricted.<br>'+#10+
      '<br>'+#10+
      '<form class="block" method=post action="limits.html">'+
      '<div class="grid2">'+#10+
      '<div class="inlineblock">Scan for in minutes (60..N, 1,440=day)<br><input class="text" name="scanfor" type="text" value="'+k64(ipsec__scanfor)+'"></div>'+#10+
      '<div class="inlineblock">Ban for in minutes (60..N, 1,440=day, 10,080=week)<br><input class="text" name="banfor" type="text" value="'+k64(ipsec__banfor)+'"></div>'+#10+
      '<div class="inlineblock">Hit limit (0=unlimited or 100..N)<br><input class="text" name="hitlimit" type="text" value="'+k64(ipsec__hitlimit)+'"></div>'+#10+
      '<div class="inlineblock">Bandwidth limit in megabytes (0=unlimited or 1..N)<br><input class="text" name="datalimit" type="text" value="'+k64(div64(ipsec__datalimit,1024000))+insstr(' Mb',ipsec__datalimit>=1)+'"></div>'+#10+
      '<div class="inlineblock">Post limit (0=unlimited or 1..N, e.g. limit the number of contact form submissions and/or emails sent by an IP address)<br><input class="text" name="postlimit" type="text" value="'+k64(ipsec__postlimit)+'"></div>'+#10+
      '<div class="inlineblock">Bad login limit (0=unlimited or 10..N, e.g. limit the number of unsuccessful Admin login attempts)<br><input class="text" name="badlimit" type="text" value="'+k64(ipsec__badlimit)+'"></div>'+#10+
      '<div class="inlineblock">Max. simultaneous connections (0=unlimited or 1..N)<br><input class="text" name="simconnlimit" type="text" value="'+k64(ipsec__connlimit)+'"></div>'+#10+
      '</div>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="limits"><input class="button" type=submit value="Save"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //inbox.html ----------------------------------------------------------------
   else if (hname_low='inbox.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart3(a,'',true,false,true)+//ultra-wide support

      xh2b('inbox',xsymbol('inbox')+'Inbox','nobotmargin')+

      xvsep+
      xinbox(a,'inbox',xcmd,xcmd2)+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //trash.html ----------------------------------------------------------------
   else if (hname_low='trash.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart3(a,'',true,false,true)+//ultra-wide support

      xh2b('trash',xsymbol('trash')+'Trash','nobotmargin')+

      xvsep+
      xinbox(a,'trash',xcmd,xcmd2)+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //inbox--*.eml (message download handler)------------------------------------
   else if (strcopy1(hname_low,1,11)='inbox.del--') or (strcopy1(hname_low,1,11)='trash.udl--') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart3(a,'',false,true,false)+

      xinbox_act(a,hname_low)+

      xhtmlfinish2(true),'',xrefreshcookie) then goto skipend;
      end

   else if (strcopy1(hname_low,1,7)='inbox--') then
      begin
      str1:=strcopy1(hname_low,8,low__length(hname_low));
      if (io__readfileext_low(str1)='txt') then
         begin
         str1:=io__remlastext(str1);
         m.hnameext:='txt';//inform header to use mime type for plain text "txt" documents
         end
      else if (io__readfileext_low(str1)='html') then
         begin
         str1:=io__remlastext(str1);
         m.hnameext:='html';//inform header to use mime type for "html" documents
         end;
      if (not io__fileexists(xinbox__folder('inbox',false)+str1)) and io__fileexists(xinbox__folder('inbox',false)+io__remlastext(str1)) then str1:=io__remlastext(str1);
      xinbox__markread('inbox',str1);//mark message as read - 29feb2024

      //.txt -> load the email into the stream buffer (limit size to 1mb) and convert to plain text and stream out to client
      if (m.hnameext='txt') or (m.hnameext='html') then xinbox_msgastext(a,'inbox',str1)
      //.eml/.el -> stream raw email message as-is to client -> used for downloading the email message
      else xstreamstart(a,wsmDisk,xinbox__folder('inbox',false)+str1,false);//stream the whole email message

      goto skipend;
      end

   //trash--*.eml (message download handler)------------------------------------
   else if (strcopy1(hname_low,1,7)='trash--') then
      begin
      str1:=strcopy1(hname_low,8,low__length(hname_low));
      if (io__readfileext_low(str1)='txt') then
         begin
         str1:=io__remlastext(str1);
         m.hnameext:='txt';//inform header to use mime type for plain text "txt" documents
         end
      else if (io__readfileext_low(str1)='html') then
         begin
         str1:=io__remlastext(str1);
         m.hnameext:='html';//inform header to use mime type for "html" documents
         end;
      if (not io__fileexists(xinbox__folder('trash',false)+str1)) and io__fileexists(xinbox__folder('trash',false)+io__remlastext(str1)) then str1:=io__remlastext(str1);
      xinbox__markread('trash',str1);//mark message as read - 29feb2024

      //.txt -> load the email into the stream buffer (limit size to 1mb) and convert to plain text and stream out to client
      if (m.hnameext='txt') or (m.hnameext='html') then xinbox_msgastext(a,'trash',str1)
      //.eml/.el -> stream raw email message as-is to client -> used for downloading the email message
      else xstreamstart(a,wsmDisk,xinbox__folder('trash',false)+str1,false);//stream the whole email message

      goto skipend;
      end

   //logs.html ----------------------------------------------------------------
   else if (hname_low='logs.html') then
      begin
      if xheadonly2(200,false,'',

      xhtmlstart3(a,'',true,false,true)+//ultra-wide support

      xh2b('logs',xsymbol('logs')+'Traffic Logs','nobotmargin')+
      xvsep+
      xlogs(a,xcmd)+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //log--*.txt/log--*.html (log download handler)------------------------------------------
   else if (strcopy1(hname_low,1,5)='log--') then
      begin
      str1:=strcopy1(hname_low,6,low__length(hname_low));
      net__decodestr(str1);
      if (io__readfileext_low(str1)='html') then log__makereport(a,ifastfolder__logs+io__remlastext(str1));//make log report when requesting ".html" version of log
      xstreamstart(a,wsmDisk,ifastfolder__logs+str1,false);//don't mark logs as cacheable
      goto skipend;
      end


   //ban.html ------------------------------------------------------------------
   else if (hname_low='ban.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2b('ban',xsymbol('ban')+'Banned List','nobotmargin')+
      xvsep+
      xinfo2(hname_low,'banlist')+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //conn.html ------------------------------------------------------------------
   else if (hname_low='conn.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2b('conn',xsymbol('conn')+'Open Connections','nobotmargin')+
      xvsep+
      xinfo2(hname_low,'openconn')+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //console.html --------------------------------------------------------------
   else if (hname_low='console.html') then
      begin
      //.force screen update since live stats are disabled
      if not ilivestats then app__onpaint(scn__width,scn__height);

      //.return console view
      if xheadonly2(200,false,'',
      xhtmlstart2(a,insstr('<meta http-equiv="refresh" content="'+inttostr(iconsolerate)+'">'+#10,iconsolerate>=1),true)+
      xh2b('console',xsymbol('console')+'Console View','nobotmargin')+
      xvsep+
      '<pre class="console">'+
      net__encodeforhtmlstr(scn__gettext(scn__width,scn__height))+//23feb2024
      '</pre>'+#10+
      xvsep+

      '<form class="inlineblock" method=post action="console.html#console"><input name="cmd" type="hidden" value="console.0"><input class="button'+insstr(' bold',iconsolerate=0)+'" type=submit title="Manually refresh page" value="Refresh"></form>'+#10+
      '<form class="inlineblock" method=post action="console.html#console"><input name="cmd" type="hidden" value="console.1"><input class="button'+insstr(' bold',iconsolerate=1)+'" type=submit title="Automatically refresh page every second" value="1s Refresh"></form>'+#10+
      '<form class="inlineblock" method=post action="console.html#console"><input name="cmd" type="hidden" value="console.5"><input class="button'+insstr(' bold',iconsolerate=5)+'" type=submit title="Automatically refresh page every 5 seconds" value="5s Refresh"></form>'+#10+
      '<form class="inlineblock" method=post action="console.html#console"><input name="cmd" type="hidden" value="console.30"><input class="button'+insstr(' bold',iconsolerate=30)+'" type=submit title="Automatically refresh page every 30 seconds" value="30s Refresh"></form>'+#10+
      '<form class="inlineblock" method=post action="logoutall.html"><input name="cmd" type="hidden" value="logoutall"><input class="button" type=submit title="Logout all Admin sessions" value="Logout All"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //contact.html ------------------------------------------------------------------
   else if (hname_low='contact.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('contact',xsymbol('contact')+'Contact Form Responses')+
      '<form class="block" method=post action="contact.html">'+
      '<div class="grid2">'+#10+
      '<div><input name="contact.allow" type="checkbox" '+insstr('checked',icontact_allow)+'>Allow Contact Form Submissions (use contact.html).  Messages are stored in the "Inbox" '+'folder as files in ".eml" format.  HTML code is permitted within the response messages 1-3 below.  Leave reply boxes blank for default repsonses.</div>'+#10+
      '<div><input name="contact.question" type="checkbox" '+insstr('checked',icontact_question)+'>Protect against mass spam with Spam Guard.  Presents a simple math question on the contact form.  A correct answer stores the message in the Inbox, and an incorrect one in the Trash folder.</div>'+#10+
      '<div class="inlineblock">1. '+net__encodeforhtmlstr(icontact_def_ok)+'<br><input class="text" name="contact.ok" type="text" value="'+net__encodeforhtmlstr(icontact_ok)+'"></div>'+#10+
      '<div class="inlineblock">2. '+net__encodeforhtmlstr(icontact_def_fail)+'<br><input class="text" name="contact.fail" type="text" value="'+net__encodeforhtmlstr(icontact_fail)+'"></div>'+#10+
      '<div class="inlineblock">3. '+net__encodeforhtmlstr(icontact_def_off)+'<br><input class="text" name="contact.off" type="text" value="'+net__encodeforhtmlstr(icontact_off)+'"></div>'+#10+
      '</div>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="contact"><input class="button" type=submit value="Save"></form>'+#10+


      xh2('mail','SMTP Mail Server')+
      '<form class="block" method=post action="contact.html#mail">'+
      '<div class="grid2">'+#10+
      '<div><input name="mail.allow" type="checkbox" '+insstr('checked',imail_allow)+'>Allow emails to be received on port 25 and stored in the inbox.</div>'+#10+
      '<div class="inlineblock">Mail domain name to report to email senders when receiving emails<br><input class="text" name="mail.domain" type="text" value="'+net__encodeforhtmlstr(imail_domain)+'"></div>'+#10+
      '<div>Max Email Size (1..50 Mb)<br><input class="text" name="mail.sizelimit" type="text" value="'+k64(imail_sizelimit)+' Mb"></div>'+#10+
      '</div>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="mail"><input class="button" type=submit value="Save"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //map.html ------------------------------------------------------------------
   else if (hname_low='map.html') then
      begin
      str1:=xdommapping(int1);
      str2:=insstr('<div class="bad">Warning: '+k64(int1)+#32+low__aorbstr('domains are','domain is',int1=1)+' failing to route properly.  The '+low__aorbstr('domains','domain',int1=1)+' cannot serve intended content until the routing issuses are remedied.  Until then, content will be served from the fallback disk site "www_".</div>',int1>=1);

      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('map',xsymbol('map')+'Domain Mapping')+
      str2+
      'Routing is optional and by default each domain routes traffic to its own disk site.  '+
      'Local addresses "127.0.0.1" and "localhost" are valid domains.  A domain has a disk site where its files reside.  '+
      'All disk sites begin with "www_" followed by the domain name (dots become underlines).  '+
      'When traffic enters Bubbles with an unknown domain name traffic is routed to the default disk site "www_", a fallback domain which always exists and cannot be routed.  '+
      'The table below lists each domain name and its target disk site.'+
      '<br>'+#10+
      '</div>'+#10+
      str1+
      xhtmlback+
      'To specify a domain route, type one entry per line in the format "(source domain):(space)(target domain)" without the brackets.  There is no need to include the leading "www." or the trailing port number.  '+

      '<div style="font-size:80%;"><br><span class="bold">An example:</span><br>'+
      '"mydomain.com: testsite.net" (without the quotes) routes inbound traffic from <span class="bold">mydomain.com</span> to '+
      '<span class="bold">testsite.net</span>, and broadcasts the files/resources located in the disk site "<span class="bold">www_testsite_net</span>".'+
      '<br><br></div>'+

      'A green tick alongside a domain indicates a successful routing pathway, '+
      'whereas a red cross indicates a routing failure with traffic instead routed to the fallback disk site "www_".  A domain name becomes known to Bubbles when it has a disk site.  <a href="manage.html#new">Click here</a> to create a disk site.'+#10+
      '<form class="block" method=post action="map.html">'+
      '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="mapinfo">'+net__encodeforhtmlstr(imap.text)+'</textarea>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="map"><input class="button" type=submit value="Save"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //counters.html ------------------------------------------------------------------
{
   else if (hname_low='counters.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('counters','Site Counters')+
      '<form class="block" method=post action="counters.html">'+
      'A site''s counter increments each time a "html" or "htm" document is requested, and can be displayed on your page(s) by loading the ".hits.png" image <img src=".hits.png" style="max-height:1em; vertical-align:text-bottom;">.  '+'Each site has its own hit counter.  Load the ".totalhits.png" image <img src=".totalhits.png" style="max-height:1em; vertical-align:text-bottom;"> to show the total hits across all sites.  Each counter updates after a short delay.'+'  The current hit counts for each site and total is listed in the box below and can be edited.  One entry per line in the format "(disk site):(space)(hit count)".<br>'+
      '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="hitinfo">'+net__encodeforhtmlstr(ihit.text)+'</textarea>'+#10+
      xvsep+
      '<input name="cmd2" class="button" type=submit value="Refresh">'+#10+
      '<input name="cmd" type="hidden" value="hits"><input class="button" type=submit value="Save"></form>'+#10+

      xhtmlfinish) then goto skipend;
      end
}

   //manage.html ----------------------------------------------------------------
   else if (hname_low='manage.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xmanage+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //pass.html ----------------------------------------------------------------
   else if (hname_low='pass.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      //.admin password
      xh2('pass',xsymbol('password')+'Change Admin Password')+
      '<form class="block" method=post action="pass.html#pass">'+
      xpassstatus+
      '<div class="grid2">'+#10+
      '<div>Current password<br><input class="text" name="password" type="password" value=""></div>'+#10+
      '<div></div>'+#10+
      '<div>Type new password<br><input class="text" name="pass1" type="password" value=""></div>'+#10+
      '<div>Confirm new password<br><input class="text" name="pass2" type="password" value=""></div>'+#10+
      '</div>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="newpass"><input class="button" type=submit value="Change Password"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //logout.html ---------------------------------------------------------------
   else if (hname_low='logout.html') then
      begin
      xsessiondel(m.vsessname);
      if xheadonly2(307,false,iadminpath,'','','') then goto skipend;
      end
   else if (hname_low='logoutall.html') then
      begin
      xsessiondelall;
      if xheadonly2(307,false,iadminpath,'','','') then goto skipend;
      end

   //help.html ----------------------------------------------------------------
   else if (hname_low='help.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('help',xsymbol('help')+'Help')+

      xvsep+
      ihelpdata+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //(admin page not found) ----------------------------------------------------
   else if xheadonly2(404,false,'','','','') then goto skipend;
   end;


//public access area (front facing file system) --------------------------------
//decode path and filename
str1:=m.hpath+m.hname;
if (hname_low='contact.html') then xreadpost;

//path+name check -> ensure path+name is safe -> no directory escapement "/../" or bad characters
if (not xsafewebname(str1)) and header__make4(a,400,true,false,false) then goto skipend;

//redirect check
if xredirect__have(m.hdiskhost+str1,str2) then
   begin
   xheadonly2(307,false,str2,'','','');
   goto skipend;
   end;

//start streaming the file
xstreamstart(a,wsmRAM,m.hdiskhost+str1,true);

skipend:
except;end;
try
if (mtmp<>nil) then freeobj(@mtmp);
except;end;
end;
//## xinc_daily_bandwidth ##
procedure xinc_daily_bandwidth(xlen:longint);
begin
idaily_bandwidth:=add64(idaily_bandwidth,xlen);
//check
if (not idaily_bandwidth_exceeded) and (idaily_bandwidth_quota_bytes>=1) and (idaily_bandwidth>idaily_bandwidth_quota_bytes) then
   begin
   idaily_bandwidth_exceeded:=true;
   //.Quota notice for inbox
   if iquotanotice then
      begin
      xwritemsg('Bubbles - Quota  Notice',
      'Your daily bandwidth quota of '+low__mbPLUS(idaily_bandwidth_quota_bytes,true)+' has been reached.  All traffic in and out of Bubbles has been suspended until midnight.'+#10+
      #10+
      'This is a security notice sent by Bubbles.'+
      '');
      end;
   end;
end;
//## stm__writedata3 ##
procedure stm__writedata3(var a:pnetwork);
label
   more,skipend;
var
   m:tnetbasic;
   buf:pobject;
   xcount,smin,smax,bsent,blen,len:longint;
   smem:pdlbyte;
   dmem:pdlbyte;
   dlen:longint;
   xramstage2,xfailure,xdataproblem,xdone:boolean;
   //## xreset ##
   function xreset(xforceclose:boolean):boolean;
   begin
   //pass-thru
   result:=true;

   try
   //check
   if not m.writing then exit;

   //write to logs
   xlogrequest_http(a,0);

   //signal the connection to be closed
   if xforceclose or (not m.hka) then a.mustclose:=true;

   //clear the record
   m.clear;
   except;end;
   end;
   //## xsent ##
   procedure xsent(xlen:longint);
   begin
   //check
   if (xlen<=0) then exit;
   //daily bandwidth counter
   xinc_daily_bandwidth(xlen);
   //inc bytes sent
   m.wsent:=add64(m.wsent,xlen);
   //inc buffer sent counter
   m.wbufsent:=m.wbufsent+xlen;
   //inc counters
   net__inccounters(0,xlen);
   //track download bandwidth
   ipsec__incBytes(m.hslot,xlen);
   //time
   a.time_idle:=ms64;
   a.infolastmode:=2;//writing
   //log
   if not m.vmustlog then m.vmustlog:=true;//mark to be logged
   end;
begin
try
//check
if not net__recinfo(a,m,buf) then exit;
blen:=str__len(buf);
xramstage2:=false;
xcount:=8;

//stream more -> "wsmDisk" and "wsmRAM"
more:
if (m.wbufsent>=blen) and (m.wmode<>wsmBuf) and m.hwantdata then
   begin
   xstreammore(a,xdataproblem,xdone);
   //.done -> finished streaming data -> OK to reset
   if xdone and xreset(false) then goto skipend
   //.data problem with streaming -> must close the connection to resolve
   else if xdataproblem and xreset(true) then goto skipend;
   //.continue
   blen:=str__len(buf);
   if (m.wmode=wsmRAM) and (m.wsent>=blen) then
      begin
      blen:=m.splicelen;
      xramstage2:=true;
      end;
   end;

//get
if (m.wlen>=1) and (m.wsent<m.wlen) and (blen>=1) then
   begin
   //boost
   imustboost:=true;

   //init
   xfailure:=false;

   //calc next chunksize
   len:=restrict32( frcmax64(sub64(m.wlen,m.wsent) , frcmax32(blen,ichunksize)) );
   if (len>=1) then
      begin
      //RAM data direct from data blocks (~110 Mb/sec) -> RAM stage 2 (after we've used the buffer "buf" to send the header
      if xramstage2 then
         begin
         case (m.splicelen>=1) and (m.splicemem<>nil) of
         true:begin
            case net____send2(a.sock,m.splicemem^,m.splicelen,0,bsent) of
            true:xsent(bsent);
            false:begin
               xcount:=0;
               a.canwrite:=false;
               end;
            end;//case
            end;
         false:xfailure:=true;
         end;//case
         end
      else
      //buffer data -> Disk (~80 Mb/sec) / Dynamic page / or RAM stage 1 -> str__splice() returns a memory address to a memory block and a length that is bound to that block's upper boundary
         begin
         case block__fastinfo(buf,m.wbufsent,smem,smin,smax) and str__splice(buf,m.wbufsent,len,dmem,dlen) of
         true:begin
            case net____send2(a.sock,dmem^,dlen,0,bsent) of
            true:xsent(bsent);
            false:begin
               xcount:=0;
               a.canwrite:=false;
               end;
            end;//case
            end;
         false:xfailure:=true;
         end;//case
         end;

      //reset for next request
      if ((m.wsent>=m.wlen) or xfailure) and xreset(false) then goto skipend;

      //more -> loop for next memory block -> totals upto 64KB
      dec(xcount);
      if (xcount>=0) then goto more;
      end;
   end;

skipend:
except;end;
end;
//## stm__readmail ##
procedure stm__readmail(var a:pnetwork);//implements the SMTP protocol - 22mar2024: utf-8 subject handling, updated to 40K search 11mar2024
label
   skipend;
var
   m:tnetbasic;
   buf:pobject;//pointer only
   smin,smax,int1,bp,p,blen,len:longint;
   smem:pdlbyte;
   xline,xcmd:string;
   //## xalive ##
   procedure xalive(xin,xout:comp);
   begin
   try
   //time
   a.time_idle:=ms64;
   //net bandwidth counters
   net__inccounters(xin,xout);
   if (xin>=0) then m.wfilesize:=add64(m.wfilesize,xin);//using "wfilesize" as bandwidth tracker
   except;end;
   end;
   //## xhaveline ##
   function xhaveline:boolean;
   var
      p:longint;
      v:byte;
   begin
   //defaults
   result:=false;

   try
   xcmd:='';
   //check
   if (str__len(buf)<1) then exit;
   //get
   for p:=0 to (str__len(buf)-1) do
   begin
   v:=str__bytes0(buf,p);
   if (v=10) or (v=13) then
      begin
      xline:=str__str1(buf,1,p);
      xcmd:=strlow(strcopy1(xline,1,4));
      result:=true;
      break;
      end;
   end;//p
   except;end;
   end;
   //## xendofdata ##
   function xendofdata:boolean;
   var
      xlen,p:longint;
      v,v1,v2:byte;
   begin
   //defaults
   result:=false;

   try
   //init
   xlen:=str__len(buf);
   //check
   if (xlen<3) then exit;
   //get
   for p:=frcmin32(xlen-10,0) to (xlen-1) do
   begin
   v:=str__bytes0(buf,p);
   v1:=str__bytes0(buf,p+1);
   v2:=str__bytes0(buf,p+2);

   if ((v=10) or (v=13)) and (v1=ssdot) and ((v2=10) or (v2=13)) then
      begin
      str__setlen(buf,p-1);//exclude the trailing "<CRLF>.<CRLF>"
      m.mdata:=false;
      result:=true;
      break;
      end;
   end;//p
   except;end;
   end;
   //## xmaildomain ##
   function xmaildomain:string;
   begin
   result:='';try;result:=strdefb(imail_domain,'localhost');except;end;
   end;
   //## xreply ##
   procedure xreply(x:string);
   begin
   try
   str__clear(buf);
   str__sadd(buf,x);
   m.mdata:=false;
   m.wsent:=0;
   m.writing:=true;
   except;end;
   end;
   //## xreadmode ##
   procedure xreadmode;
   begin
   try
   str__clear(buf);
   m.writing:=false;
   except;end;
   end;
   //## xfindsubject__raw ##
   function xfindsubject__raw:string;
   var
      xlen,p:longint;
      c,lc:byte;
   begin
   //defaults
   result:='';

   try
   //init
   xlen:=frcmax32(str__len(buf),40000);//search first 40K of message only, 11mar2024: 40k search instead of previous 7K
   if (xlen<10) then exit;

   //get
   lc:=10;
   for p:=1 to xlen do
   begin
   c:=str__bytes0(buf,p-1);
   if ((c=uus) or (c=lls)) and ((lc=10) or (lc=13)) and strmatch(str__str1(buf,p,9),'subject: ') then
      begin
      result:=str__str1(buf,p+9,100);
      break;
      end;
   lc:=c;
   end;//p

   //trim to return code
   if (result<>'') then
      begin
      for p:=1 to low__length(result) do if (result[p-1+stroffset]=#10) or (result[p-1+stroffset]=#13) then
         begin
         result:=strcopy1(result,1,p-1);
         break;
         end;
      end;

   //decode
   //was: result:=utf8__encodetohtmlstr(mail__encodefield(result,false),true,true);//utf-8 etc - updated 22mar2024
   result:=mail__encodefield(result,false);//fixed 02may2024: mail__writemsg() internally calls the "utf8__encodetohtmlstr()" proc for safe filename encoding
   except;end;
   end;
   //## xsave ##
   function xsave:boolean;
   begin
   result:=false;try;result:=mail__writemsg(buf,strdefb(xfindsubject__raw,'(no subject)'),io__makefolder2(xinbox__folder('inbox',false)));except;end;
   end;
begin
try
//check
if not net__recinfo(a,m,buf) then exit;


//information vars - set once
if m.vonce then
   begin
   m.vonce:=false;
   m.vstarttime:=ms64;
   a.used:=add64(a.used,1);
   m.hip:=inttostr(a.sock_ip4.b0)+'.'+inttostr(a.sock_ip4.b1)+'.'+inttostr(a.sock_ip4.b2)+'.'+inttostr(a.sock_ip4.b3);
   a.infolastip:=m.hip;//06apr2024

   //.ipsec security tracking
   m.hslot:=ipsec__trackb(m.hip);//we should have a valid client ip address by this stage

   //.client is banned (rate limited) -> abort right now
   if ipsec__banned(m.hslot) then
      begin
      xlogrequest_smtp(a,403);
      a.mustclose:=true;
      goto skipend;
      end;

   //.too many simultaneous connections
   if ipsec__incConn(m.hslot,true) then
      begin
      xlogrequest_smtp(a,503);
      a.mustclose:=true;
      goto skipend;
      end;

   //.OK
   xreply('220 '+xmaildomain+' Ready'+rcode);
   end;


//write reply ------------------------------------------------------------------
if m.writing then
   begin
   len:=restrict32( frcmax64(sub64(str__len(buf),m.wsent) , high(ibuffer)+1) );
   if (len<=0) then xreadmode
   else if (len>=1) then
      begin
      //fill buffer with some data
      blen:=str__len(buf);
      bp:=restrict32(m.wsent);
      smin:=-1;
      smax:=-2;
      for p:=0 to (len-1) do
      begin
      if (bp<blen) then
         begin
         if (bp>smax) then block__fastinfo(buf,bp,smem,smin,smax);
         if (bp<=smax) then ibuffer[p]:=smem[bp-smin] else ibuffer[p]:=0;
         end
      else ibuffer[p]:=0;
      inc(bp);
      end;//p

      //send the data back to the client
      int1:=net____send(a.sock,ibuffer,len,0);
      if (int1>=1) then
         begin
         //alive
         xalive(0,int1);
         a.infolastmode:=2;//writing
         if not m.vmustlog then m.vmustlog:=true;//mark to be logged

         //daily bandwidth counter
         xinc_daily_bandwidth(int1);
         //increment the sent counter -> we keep sending till all the data has been sent to client
         m.wsent:=add64(m.wsent,int1);

         //done
         if (m.wsent>=blen) then xreadmode;
         end
      else a.canwrite:=false;
      end;
   end;


//read command/data ------------------------------------------------------------
if not m.writing then
   begin
   len:=net____recv(a.sock,ibuffer,sizeof(ibuffer),0);
   if (len>=1) then
      begin
      //alive
      xalive(len,0);
      a.infolastmode:=1;//reading
      if not m.vmustlog then m.vmustlog:=true;//mark to be logged

      //daily bandwidth counter
      xinc_daily_bandwidth(len);

      //add to buffer
      str__addrec(buf,@ibuffer,len);

      //size limit check
      if ((str__len(buf) div 1024000)>imail_sizelimit) then
         begin
         str__softclear2(buf,ibufferlimit);
         xlogrequest_smtp(a,503);
         a.mustclose:=true;
         goto skipend;
         end;

      //within the "data" receiving command and waiting for the terminating "." on a single line "<rcode>.<rcode>"
      if m.mdata then
         begin
         if xendofdata then
            begin
            case xsave of
            true:begin
               xreply('250 OK'+rcode);
               xlogrequest_smtp(a,250);
               end;
            false:begin
               xreply('554 Transaction Failed'+rcode);
               xlogrequest_smtp(a,554);
               end;
            end;//case

            end;
         end
      //decide
      else if xhaveline then
         begin
         if      (xcmd='helo') then xreply('250 '+xmaildomain+' Ready'+rcode)
         else if (xcmd='ehlo') then xreply('250-'+xmaildomain+' Ready'+rcode+'250 SIZE '+intstr64(mult64(imail_sizelimit,1024000))+rcode)
         else if (xcmd='mail') then
            begin
            if (m.hua='') then m.hua:=swapcharsb(strcopy1(xline,11,low__length(xline)),'"','''');//1st one only
            xreply('250 OK'+rcode);//mail from:
            end
         else if (xcmd='rcpt') then
            begin
            if (m.hreferer='') then m.hreferer:=swapcharsb(strcopy1(xline,9,low__length(xline)),'"','''');//1st one only
            xreply('250 OK'+rcode);//rcpt to:
            end
         else if (xcmd='data') then
            begin
            xreply('354 OK'+rcode);
            m.mdata:=true;//we are now in the "data" receving mode -> data transmission stops when we get "<rcode>.<rcode>"
            end
         else if (xcmd='vrfy') then xreply('250 OK'+rcode)//security risk -> give no specific info back
         else if (xcmd='noop') then xreply('250 OK'+rcode)
         else if (xcmd='rset') then xreply('250 OK'+rcode)
         else if (xcmd='quit') then
            begin
            xreply('221 '+xmaildomain+' Closing'+rcode);
            a.mustclose:=true;
            end
         else xreply('500 Command Unrecognised'+rcode);//command not supported
         end;
      end
   else a.canread:=false;
   end;

skipend:
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//cccccccccccccccccccc
//## question__make ##
function question__make(var xquestion:string):boolean;
var
   xindex,v1,v2:longint;
begin
//defaults
result:=false;
xindex:=iquestion__index;
xquestion:='';

try
//inc
inc(iquestion__index);
if (iquestion__index>high(iquestion__answer)) then iquestion__index:=0;

//question
v1:=frcmin32(random(100000),1);//1..100,000
v2:=frcmin32(random(11),1);//1..10
xquestion:='What is '+k64(v1)+' + '+k64(v2)+'?';
iquestion__answer[xindex]:=v1+v2;//always 1..N

//successful
result:=true;
except;end;
end;
//## question__checkanswer ##
function question__checkanswer(xanswer:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
if (xanswer>=1) then
   begin
   for p:=0 to high(iquestion__answer) do if (xanswer=iquestion__answer[p]) then
      begin
      iquestion__answer[p]:=0;//reset so it cannot be reused
      //answer is correct
      result:=true;
      end;
   end;
except;end;
end;
//## xmakehelp ##
function xmakehelp(xclaudehelp:boolean):string;
const
   //compressed (.zip) version of plain text help document
   xhelpdata

:array[0..18651] of byte=(
120,1,205,157,107,115,27,199,146,166,191,227,87,244,98,99,86,164,15,65,18,224,77,162,47,51,148,68,89,12,139,162,150,164,198,235,240,56,78,52,129,38,9,11,183,131,6,68,209,31,246,183,239,243,102,86,117,55,64,64,134,53,222,160,120,78,88,0,186,186,42,43,43,239,149,149,245,235,228,183,159,111,211,73,210,205,147,231,211,171,171,94,150,111,36,233,160,147,220,233,199,206,48,203,147,252,54,227,195,191,215,46,248,151,86,105,146,119,251,163,94,182,145,100,105,126,159,76,134,201,52,207,146,215,151,151,239,146,187,236,42,201,179,241,199,108,156,76,66,159,87,227,225,29,63,37,237,225,96,50,30,246,122,89,199,187,111,167,163,148,193,146,225,181,189,209,29,220,36,249,36,157,116,219,201,117,23,24,146,161,119,194,136,131,73,54,30,100,19,134,235,78,110,233,41,159,140,179,180,159,117,146,235,241,176,159,116,186,249,135,141,100,56,230,195,56,107,79,252,199,243,163,211,228,142,214,195,233,36,233,165,55,155,181,218,107,94,252,241,253,73,146,118,250,221,65,151,46,24,106,56,72,70,233,32,235,217,164,218,237,44,207,233,116,114,59,
30,78,111,110,147,251,225,116,108,243,137,19,88,203,54,111,54,147,250,237,100,50,58,220,218,234,13,219,105,239,118,152,79,14,155,219,79,183,183,172,219,173,122,242,143,164,147,93,167,211,222,132,158,243,252,110,56,238,104,130,117,123,92,95,223,0,169,221,246,109,196,5,168,236,245,18,155,82,54,153,128,1,126,0,241,31,187,147,180,151,92,79,7,109,129,168,213,160,85,119,144,48,235,222,164,219,207,152,205,209,40,29,135,169,10,221,66,158,97,109,195,214,138,53,170,96,151,169,182,63,24,122,187,147,140,206,243,238,36,79,214,248,111,6,28,83,33,55,7,48,112,151,117,173,163,172,159,118,123,26,21,140,140,4,149,129,155,10,181,195,113,63,201,167,87,253,110,158,11,50,67,49,63,140,70,67,65,195,26,92,140,210,126,242,227,52,29,135,69,166,87,80,80,12,78,39,140,49,185,79,210,60,233,164,0,192,138,247,71,66,250,56,189,190,102,233,123,195,155,124,51,73,68,104,105,47,31,50,235,118,111,218,129,26,210,228,106,218,237,77,26,160,129,54,160,41,237,221,139,170,52,104,63,245,233,101,3,200,16,108,11,161,115,29,94,222,102,60,19,114,135,
70,66,215,89,58,153,142,233,151,119,51,123,161,63,28,103,162,217,65,21,117,227,233,96,32,224,251,44,104,23,138,23,61,8,113,97,230,189,238,100,194,143,48,192,96,72,39,105,39,109,223,106,117,68,107,0,221,189,25,136,178,122,221,155,219,137,141,205,108,161,120,39,127,6,202,62,77,0,185,251,49,75,174,160,166,15,141,171,84,244,215,207,0,229,30,192,6,233,77,214,207,6,147,36,191,207,39,89,63,161,173,129,28,105,230,67,118,159,12,71,153,19,114,110,60,24,222,5,73,240,232,148,225,186,3,122,212,180,199,89,175,107,236,70,191,131,108,12,144,181,95,39,191,189,10,104,168,125,147,60,15,108,234,64,44,226,18,26,137,199,183,154,85,46,95,43,200,93,36,32,86,88,167,221,197,41,178,192,232,40,74,131,53,35,145,214,158,158,138,57,95,8,85,80,97,201,241,177,229,150,113,52,18,0,17,16,103,167,183,46,3,137,188,129,68,146,181,25,234,17,233,15,144,8,185,218,241,60,121,225,116,157,172,5,58,73,198,233,221,12,73,168,225,201,187,228,138,85,232,33,12,96,219,116,58,25,246,77,252,164,157,78,178,5,194,250,72,160,146,11,147,53,216,2,102,25,164,
131,54,63,143,51,72,173,10,222,201,224,106,248,201,80,13,160,249,173,11,22,0,253,216,205,238,28,21,57,163,72,8,22,156,4,192,57,107,108,80,191,8,15,94,205,178,88,2,65,118,122,144,19,152,130,64,93,62,140,179,81,175,203,103,232,110,97,127,73,67,244,152,183,199,221,209,68,130,113,212,155,222,184,252,248,215,20,25,217,209,228,95,119,39,17,75,129,152,59,221,27,147,59,200,211,81,47,189,79,214,70,16,126,183,15,128,235,198,101,38,48,242,81,214,238,138,81,183,76,62,27,41,210,19,16,177,252,112,10,61,191,24,246,161,177,14,120,29,192,223,21,217,0,101,241,98,30,37,221,90,245,89,193,96,109,127,155,137,2,58,152,22,172,231,83,232,89,34,224,231,238,160,131,50,73,46,36,242,88,133,181,1,11,198,34,117,7,208,17,50,82,195,78,97,88,255,54,68,120,153,248,28,103,54,239,60,57,146,236,7,103,14,224,8,237,49,154,104,128,159,157,171,147,211,146,231,92,47,172,77,71,189,97,138,162,145,70,218,112,82,9,159,59,89,47,67,128,217,183,200,97,69,83,67,216,144,249,75,58,73,176,68,185,97,211,201,92,83,149,234,103,141,69,113,229,197,146,166,214,
39,8,158,142,123,166,215,198,76,107,216,239,221,187,102,75,29,10,196,156,15,109,237,140,132,94,163,140,74,73,197,43,208,107,78,63,113,108,38,122,154,142,130,198,99,72,212,28,19,216,66,210,140,64,181,52,188,222,16,85,165,3,147,146,2,246,221,120,248,233,158,245,253,215,52,163,247,184,100,107,136,192,207,142,133,24,190,54,2,160,67,83,164,81,137,70,165,140,20,78,6,25,194,73,2,252,229,219,11,141,245,92,82,16,158,172,72,65,35,127,73,96,53,99,89,101,48,60,16,144,188,250,18,149,117,15,120,172,44,178,19,240,33,15,22,236,106,56,156,148,223,144,129,90,161,240,212,22,45,207,218,211,177,20,82,248,81,56,66,195,38,151,247,163,44,98,202,37,113,210,70,158,98,110,244,245,120,194,99,161,86,54,202,184,219,1,119,174,244,35,43,231,67,224,12,36,20,181,182,91,55,57,144,229,54,27,100,79,231,174,219,153,220,66,190,172,243,20,251,230,22,205,188,33,158,30,96,200,152,130,205,38,109,97,230,242,150,94,144,3,200,68,169,251,82,189,124,200,178,17,130,224,22,20,5,69,67,235,163,206,239,192,106,86,67,193,109,243,235,192,247,2,48,173,9,8,
240,245,96,249,145,51,19,204,11,122,58,51,22,194,24,217,221,222,221,188,157,244,123,76,234,166,228,234,181,40,43,0,32,247,71,90,39,26,39,175,224,152,228,45,216,127,133,40,238,36,160,105,136,153,65,151,239,134,119,128,255,38,251,136,217,181,246,226,221,123,244,150,137,24,153,93,81,155,78,238,178,244,67,130,116,165,55,176,15,167,99,169,245,134,119,201,72,47,203,198,73,225,24,99,14,107,169,110,182,146,143,13,108,141,12,53,249,177,59,30,14,164,57,115,198,123,142,241,147,1,65,192,91,164,96,193,41,171,213,230,142,29,41,201,30,27,9,147,88,5,47,80,4,136,65,179,250,212,92,202,207,233,52,90,34,183,89,111,20,36,124,164,235,104,172,106,170,72,194,145,132,253,85,119,32,170,92,3,17,76,189,153,156,62,215,211,227,210,118,230,219,78,139,102,19,214,190,147,137,1,140,66,160,14,81,22,34,232,94,179,161,213,59,164,172,241,192,218,221,109,54,16,209,70,217,39,53,47,17,169,105,66,251,235,174,223,145,156,102,191,4,187,222,122,21,231,93,119,199,16,136,108,201,218,201,181,24,148,110,12,1,90,125,164,109,209,62,109,139,249,244,74,
156,216,134,53,207,177,172,123,157,164,13,127,66,15,122,94,216,1,209,236,93,51,27,98,61,185,202,64,158,89,122,166,33,100,108,97,225,93,14,145,55,34,92,8,126,102,68,153,244,234,47,74,105,147,34,182,30,249,208,45,39,169,191,20,154,248,110,128,102,141,86,246,15,190,146,169,228,63,178,170,248,93,246,160,9,160,246,237,16,188,28,214,126,253,240,219,149,123,57,73,163,17,223,158,235,235,215,173,223,106,181,51,140,75,1,99,4,139,65,218,235,217,203,155,255,181,218,235,88,87,172,191,105,194,55,210,132,23,174,9,107,175,160,164,78,134,101,134,35,4,46,32,32,9,147,57,184,244,187,1,113,41,198,186,235,162,219,204,76,129,107,32,164,136,26,87,112,197,98,5,210,134,10,122,67,22,205,40,91,29,201,158,110,203,243,146,104,23,106,39,67,4,126,68,11,26,82,194,234,206,84,171,90,152,193,162,102,78,36,14,226,112,212,109,99,51,178,106,6,71,101,129,10,167,49,42,7,196,209,195,9,5,144,115,155,148,80,128,225,213,29,64,24,50,185,96,238,40,185,23,188,170,102,197,107,6,13,237,33,244,104,137,68,108,44,120,85,173,15,191,139,13,100,33,254,96,
61,29,127,194,235,232,45,66,250,161,236,24,181,49,196,7,241,150,251,58,49,236,45,50,8,20,33,85,13,145,102,211,14,166,253,43,216,154,185,216,111,230,6,187,176,1,97,47,162,57,211,199,162,186,202,146,39,72,86,228,81,231,137,186,201,62,161,125,80,193,165,235,33,53,140,100,150,131,61,184,97,85,110,134,244,17,160,205,231,104,196,6,127,186,93,165,226,244,170,141,196,104,52,218,50,174,243,238,31,89,210,108,110,171,133,153,10,250,190,183,189,189,177,109,63,9,173,181,10,41,203,124,255,239,245,198,56,112,242,106,125,138,229,87,135,179,186,104,200,79,208,47,157,23,66,14,88,22,105,167,157,34,207,12,35,224,245,233,246,134,47,79,20,69,252,102,168,65,183,22,152,225,183,230,102,51,249,241,249,134,219,91,134,46,126,4,67,201,79,207,205,56,184,70,110,247,48,43,68,242,112,213,66,138,221,76,194,242,36,173,168,176,28,182,28,106,43,61,4,217,34,132,34,4,116,79,160,70,154,228,7,117,75,56,98,218,14,147,10,138,10,80,132,36,153,180,87,217,13,68,81,204,19,210,40,71,221,41,177,97,211,87,251,40,213,12,11,232,249,41,102,160,70,246,158,
55,18,252,210,225,88,114,93,54,115,128,132,249,93,19,9,240,53,12,222,225,107,167,118,197,1,48,60,212,195,34,183,208,5,77,213,200,171,157,202,169,150,179,90,200,38,164,24,96,72,23,33,141,126,150,189,81,125,33,25,164,31,187,55,138,7,48,235,207,197,87,146,181,192,101,54,87,235,34,170,42,115,180,241,147,77,223,13,7,235,204,225,72,161,2,48,23,100,155,137,81,55,250,141,91,211,2,81,192,116,172,56,136,3,21,209,135,147,25,66,57,244,29,35,56,182,32,237,94,23,67,213,22,211,6,96,105,39,195,129,180,218,114,28,129,234,32,78,128,236,34,154,157,88,72,166,149,46,17,172,214,85,62,53,108,95,79,69,120,90,76,252,80,89,229,60,189,65,97,200,84,140,51,46,220,154,25,84,130,193,104,227,180,135,195,15,242,19,77,19,164,172,180,28,35,226,9,24,34,166,184,89,141,117,25,65,72,227,27,236,11,233,9,87,235,33,206,134,142,96,142,24,35,4,155,160,102,5,138,146,235,30,132,58,213,82,49,234,19,38,133,80,11,176,41,214,38,136,101,132,204,88,213,178,97,134,114,31,5,191,227,216,189,229,187,116,236,203,117,141,218,198,1,191,133,44,101,252,199,48,
81,160,67,220,51,119,221,202,176,93,35,57,67,21,74,85,33,169,225,179,240,37,193,58,194,101,150,129,77,240,174,80,42,50,153,114,58,83,83,211,106,27,193,97,184,112,135,97,35,46,141,83,185,204,112,103,60,166,227,38,186,112,55,85,200,17,163,52,58,74,107,193,177,114,247,24,76,57,107,183,118,81,19,211,177,236,26,112,103,97,61,57,179,253,110,103,160,64,16,96,188,37,240,163,192,208,133,155,242,23,196,64,104,157,10,120,100,62,88,199,115,135,44,48,187,171,42,50,189,18,130,53,140,243,241,19,130,124,211,241,152,133,51,207,130,176,18,180,115,43,43,208,36,140,185,58,178,240,54,146,41,86,60,194,72,107,83,58,29,113,70,12,12,133,96,221,232,95,245,30,244,25,96,216,50,200,18,43,252,145,128,67,204,54,226,154,6,238,70,114,161,64,98,152,131,75,202,12,33,251,16,73,21,171,68,195,76,134,10,114,186,199,83,58,209,193,183,51,159,0,122,124,131,172,236,221,187,52,63,242,249,27,142,224,226,143,24,199,249,12,130,88,26,5,188,36,216,96,130,192,37,37,86,32,17,5,45,227,252,132,13,147,249,252,4,99,126,96,106,71,142,94,153,71,134,43,252,
17,236,63,231,2,120,0,67,23,183,3,28,41,246,227,44,143,78,38,60,145,17,13,34,226,211,224,147,176,238,104,244,246,12,34,98,114,131,79,238,136,55,49,164,173,229,235,246,142,2,155,225,165,50,50,86,9,109,91,172,221,220,25,192,34,10,32,207,202,13,111,194,75,216,192,80,175,197,34,136,109,42,218,208,33,62,67,140,199,166,224,177,74,53,178,0,185,55,147,243,241,102,120,35,106,58,98,217,27,184,104,227,118,247,74,138,78,161,53,99,99,126,247,96,73,142,232,55,79,116,205,67,177,194,174,201,155,225,221,32,56,25,11,217,211,24,188,246,139,216,208,121,29,122,199,103,1,127,82,58,93,130,101,230,22,34,219,122,206,107,80,89,25,25,171,198,152,133,243,66,128,4,25,235,174,117,116,186,181,220,132,69,178,107,233,213,222,180,47,137,143,134,17,149,41,76,40,18,184,250,93,91,3,90,213,34,42,164,47,106,226,97,202,171,33,190,30,164,160,95,198,198,167,73,242,54,197,107,69,121,184,3,20,35,24,57,157,203,188,178,166,110,44,99,86,207,208,12,180,244,162,80,17,113,112,115,100,2,49,133,200,159,0,87,15,154,149,252,161,187,129,115,109,132,10,123,
165,232,166,126,124,250,166,142,41,50,248,64,235,83,143,28,22,175,136,17,12,30,9,248,14,209,247,48,43,55,176,147,250,102,214,239,213,81,252,22,77,143,19,138,64,8,17,34,172,116,194,2,220,70,66,227,183,78,7,49,52,196,6,170,178,153,68,192,16,50,35,236,86,98,143,121,232,139,71,62,175,135,61,252,220,25,216,95,102,189,2,246,179,10,146,89,54,214,29,145,28,220,128,8,146,169,234,168,46,13,57,242,157,45,224,86,12,58,51,192,57,33,11,121,153,0,98,228,86,15,12,26,241,18,59,158,89,97,87,8,50,248,250,10,157,105,7,4,97,234,219,31,198,234,1,2,196,190,177,163,22,121,173,210,116,93,195,93,185,148,88,235,177,23,22,251,88,135,219,64,1,11,117,38,84,84,187,52,48,161,66,237,60,33,80,90,27,201,78,66,144,135,166,199,146,154,238,210,242,160,141,185,121,11,34,89,153,234,66,8,88,7,208,215,97,28,100,143,176,34,166,250,100,198,234,12,106,2,62,164,25,81,67,106,24,252,63,125,20,16,22,71,65,16,219,179,216,161,203,55,193,89,181,46,24,84,219,6,11,57,222,22,223,84,108,149,12,108,3,36,237,50,99,196,13,34,123,96,138,13,89,19,72,198,160,43,
249,53,210,156,164,110,154,212,161,27,5,89,37,166,2,201,231,155,155,155,197,226,174,133,153,184,129,183,14,18,141,237,156,192,17,56,97,18,243,134,95,160,164,42,229,241,42,145,206,54,1,73,94,142,2,21,193,196,192,129,116,176,41,20,13,208,47,66,26,114,210,172,163,25,154,151,117,128,199,207,36,123,247,160,138,208,74,26,95,23,30,162,241,51,131,31,96,36,158,165,104,202,224,9,161,34,86,3,132,219,242,43,12,39,154,102,101,174,112,250,37,9,34,235,214,161,119,103,168,132,64,174,53,211,236,143,138,209,170,12,228,129,199,32,197,34,35,200,72,186,202,112,62,194,235,200,194,161,47,181,145,145,58,187,65,153,42,230,141,45,47,82,177,149,146,42,102,38,178,12,32,13,17,41,246,223,88,97,9,217,109,107,252,208,198,148,144,250,121,0,114,88,75,134,177,249,151,139,88,229,201,98,135,84,2,198,69,108,132,248,10,199,57,82,77,21,131,15,25,161,250,244,33,63,132,209,255,132,31,74,193,251,229,28,129,146,205,69,4,243,155,79,38,91,216,72,194,218,3,103,57,214,196,69,220,20,1,42,80,0,186,21,4,176,61,46,69,45,16,231,236,157,223,195,38,80,95,
58,26,101,169,199,27,220,208,34,178,32,90,172,238,160,154,140,54,221,36,39,135,184,91,123,218,227,157,78,122,143,213,136,150,71,37,206,68,132,120,32,234,180,32,191,22,86,42,193,49,32,235,37,40,157,35,147,78,194,155,193,193,238,151,92,215,25,249,80,50,114,49,20,203,99,146,173,248,1,115,84,19,195,33,204,110,4,21,178,128,17,247,228,52,12,25,214,226,140,31,217,252,213,94,57,35,196,121,65,117,35,104,21,68,64,155,110,69,69,110,16,72,116,81,21,84,14,162,143,100,212,203,164,153,122,84,41,181,218,249,220,134,32,122,168,63,146,247,33,92,74,85,59,131,99,169,35,30,137,202,20,218,91,182,187,156,128,184,37,2,61,7,119,73,76,82,137,254,200,226,210,79,182,23,26,93,111,215,35,252,42,29,137,190,240,117,149,28,51,101,162,246,21,5,19,31,187,142,17,135,99,164,106,223,216,194,87,73,62,232,66,11,236,147,73,206,204,17,153,5,139,154,173,131,205,109,254,215,196,200,107,36,191,182,158,109,157,166,227,173,214,118,107,247,112,187,121,184,221,58,220,221,77,254,209,220,222,217,254,45,169,255,120,124,153,108,221,221,221,253,243,170,
151,18,41,146,59,108,248,200,255,9,102,182,204,249,104,164,3,246,3,145,73,155,218,26,244,189,224,205,102,61,105,161,148,158,237,236,110,47,203,141,168,39,245,211,225,31,208,110,186,181,183,185,157,172,253,28,182,241,222,94,178,97,188,185,253,173,246,245,246,119,191,77,62,237,239,174,39,71,35,34,115,40,152,159,186,147,173,189,157,131,205,157,253,100,237,167,215,151,167,111,130,40,250,49,107,127,24,174,39,47,216,46,232,103,91,205,214,142,205,112,59,185,72,175,211,113,55,188,82,79,126,109,246,243,164,245,116,154,180,218,191,213,254,62,60,224,63,177,123,222,48,116,108,254,62,154,199,194,206,179,61,220,191,37,41,34,143,134,134,221,105,178,255,255,3,11,100,168,44,192,65,179,185,191,221,220,249,170,144,176,215,130,24,192,194,193,223,138,5,231,137,233,21,41,52,211,69,120,104,181,118,15,190,46,60,236,30,128,135,102,107,154,236,252,173,136,24,230,237,116,188,0,3,207,154,219,7,205,175,138,16,118,247,133,128,230,52,217,253,91,17,16,164,2,206,39,155,156,11,16,241,180,185,135,164,253,154,196,194,238,30,136,216,153,
38,123,43,225,97,239,47,105,9,114,138,22,40,136,157,167,251,207,190,66,13,241,108,85,13,241,215,112,208,201,59,11,112,112,176,179,187,255,117,225,96,71,106,114,111,85,253,176,42,14,54,21,214,91,52,255,189,103,95,21,23,108,7,113,184,154,52,88,117,246,174,23,58,36,145,118,23,200,130,230,211,189,237,253,167,95,21,26,14,158,10,15,72,131,213,212,194,254,138,210,128,45,227,15,127,12,135,125,79,28,153,53,23,119,118,15,118,191,46,213,96,180,128,141,240,247,226,32,191,198,241,24,46,96,133,230,238,206,65,107,25,21,204,96,238,81,204,70,97,99,103,123,85,217,184,42,69,124,129,92,120,124,84,72,66,138,57,86,19,18,171,162,226,230,118,9,97,180,246,90,123,95,55,93,192,36,171,153,13,171,226,162,88,227,135,110,101,107,119,255,235,70,198,254,170,186,243,175,34,163,65,132,134,248,28,161,193,201,34,45,178,243,116,7,175,123,137,73,89,32,84,41,123,143,34,63,118,228,113,53,49,44,86,18,167,123,219,127,81,165,84,144,211,90,132,157,131,167,187,207,150,186,94,143,143,157,125,195,14,164,179,26,118,90,127,17,59,155,7,127,204,69,103,
118,91,187,159,137,207,60,62,66,154,7,187,162,151,131,85,49,178,106,216,170,152,217,31,221,209,28,74,246,158,53,247,158,30,124,189,28,212,122,102,206,58,17,172,213,136,100,85,235,180,64,9,217,103,115,40,105,238,52,89,136,165,142,106,241,230,163,73,149,125,247,223,241,217,254,94,156,16,143,204,62,45,50,83,159,62,107,238,124,197,114,196,164,108,11,51,237,239,69,199,114,51,109,169,197,90,98,240,81,212,141,204,213,22,97,157,213,240,112,176,162,60,37,203,188,63,28,220,47,34,140,230,206,222,222,114,202,120,100,108,152,83,223,90,53,204,183,247,87,209,241,208,74,219,217,95,74,24,85,28,62,30,105,172,234,219,174,140,139,47,96,145,175,2,19,77,140,247,149,28,153,149,49,145,15,175,39,156,224,236,166,139,156,220,214,246,254,82,251,253,209,241,17,66,95,43,249,50,43,163,35,204,170,98,160,46,178,79,155,7,7,203,67,97,143,142,152,167,18,167,216,98,43,109,26,49,143,213,182,16,31,98,102,145,233,222,218,126,214,220,95,106,130,60,58,106,246,119,64,13,134,251,106,68,243,229,168,217,89,64,53,173,230,206,65,243,235,69,13,71,13,
156,108,86,192,205,14,251,207,127,141,108,54,23,152,171,187,187,79,249,255,50,19,254,241,105,229,64,8,193,128,95,13,33,59,43,34,100,169,234,249,106,237,17,161,1,155,125,37,52,52,87,117,118,73,158,25,144,159,88,17,180,123,155,55,221,235,121,151,102,127,127,249,30,108,232,194,236,187,199,179,77,86,139,57,239,28,254,85,204,44,50,91,159,237,111,239,44,149,32,143,109,181,90,80,4,103,230,239,165,147,47,96,151,71,167,11,89,38,59,184,51,43,228,174,124,1,93,60,180,223,119,155,75,67,206,143,142,11,9,143,214,106,129,196,191,142,139,138,244,88,160,112,201,100,57,120,186,212,126,125,116,204,20,49,214,21,12,250,191,128,26,25,244,59,139,76,179,230,193,179,165,202,246,209,145,33,50,81,98,199,223,43,60,194,180,42,100,178,16,49,251,7,251,203,109,214,71,71,205,193,51,112,131,25,178,130,57,15,153,172,26,90,125,136,154,69,54,43,52,243,108,127,105,148,245,209,81,99,230,60,166,201,106,168,89,117,11,39,78,235,97,208,153,204,56,12,146,101,22,107,124,239,209,226,171,45,243,252,154,232,224,213,16,178,106,228,104,169,14,94,30,108,
126,100,99,36,138,147,213,240,176,170,159,199,121,189,156,12,177,198,61,57,242,195,187,69,6,218,206,206,211,189,165,66,246,107,192,9,81,197,191,23,39,95,64,27,11,208,248,104,230,187,178,41,87,211,57,95,72,36,15,173,181,102,147,253,210,37,59,191,95,19,106,118,64,205,106,22,236,151,161,230,79,180,242,179,189,131,229,123,192,95,11,158,60,84,191,218,78,48,202,249,191,141,168,5,86,110,235,96,159,200,210,215,78,80,30,93,82,30,206,74,226,167,181,106,120,233,11,196,207,215,32,134,9,26,172,134,135,85,163,74,145,33,70,58,96,106,149,158,230,19,246,118,182,151,110,242,124,13,24,89,45,137,117,231,176,245,69,24,89,32,133,119,254,156,105,10,100,62,154,122,218,129,97,86,146,193,43,163,229,11,24,230,1,109,61,26,58,90,171,101,152,252,5,42,161,182,194,80,7,183,23,8,214,189,3,66,118,127,162,167,31,159,66,36,82,87,50,96,86,166,144,234,114,255,137,142,110,238,145,17,255,167,186,231,113,145,100,238,115,19,21,77,152,197,10,17,89,89,153,120,52,111,254,108,32,199,248,40,126,227,39,87,195,233,251,225,181,170,68,80,109,148,195,
205,156,96,84,21,136,151,42,160,98,5,8,84,130,141,154,131,25,181,79,58,42,30,236,53,24,255,193,169,77,42,24,252,195,138,61,232,4,40,31,237,104,33,133,47,38,67,206,153,36,161,154,5,239,158,83,14,77,53,193,58,28,29,182,90,117,58,142,183,118,246,147,14,161,91,41,190,181,217,90,124,42,255,240,252,94,7,48,117,152,82,39,106,57,233,169,79,107,162,99,175,173,172,54,148,181,160,106,31,39,29,169,67,201,215,247,170,19,115,164,58,49,42,187,169,218,70,215,42,73,164,210,206,27,201,217,133,14,177,235,173,147,106,81,47,175,98,152,212,127,229,208,246,111,117,63,64,109,101,26,24,212,138,44,28,90,13,58,67,25,39,61,135,84,91,237,81,222,162,87,28,174,228,120,105,159,239,28,203,212,217,80,142,132,150,197,73,84,210,196,209,204,163,80,47,49,185,227,84,51,5,109,188,126,171,125,240,242,125,29,138,60,114,100,241,39,170,37,114,152,92,37,67,195,241,77,85,62,214,58,228,61,74,233,253,79,205,169,236,237,51,103,221,159,167,3,59,233,206,191,42,176,251,70,37,100,99,77,10,149,118,115,192,202,37,7,82,184,66,181,90,88,42,59,45,68,41,150,
251,88,163,132,115,157,151,28,252,204,187,159,24,93,245,43,138,195,229,156,108,165,216,7,5,239,252,228,107,92,169,74,89,152,64,90,71,78,90,156,242,44,7,181,217,216,210,178,46,239,168,112,144,243,184,68,96,168,115,176,165,25,47,174,188,33,250,224,213,231,212,204,124,163,226,68,179,239,95,123,9,59,210,152,245,164,159,118,68,200,231,94,40,116,182,101,196,181,53,10,5,21,205,196,240,234,3,86,99,150,250,88,94,37,177,168,130,33,130,18,146,116,38,214,41,212,96,137,21,121,26,156,35,118,98,181,5,44,105,119,65,141,27,94,188,84,5,156,134,147,27,197,213,40,31,24,203,40,121,153,59,10,103,120,121,66,206,27,151,231,236,195,184,181,159,253,64,118,96,20,63,129,205,34,121,37,139,176,158,170,125,35,96,41,164,97,21,75,6,84,97,177,26,218,170,157,69,129,18,200,90,167,128,85,152,148,202,14,84,170,170,146,64,96,221,80,81,72,165,69,103,86,101,43,212,243,240,99,196,86,48,34,148,24,137,103,160,235,239,7,192,161,74,9,197,193,250,54,37,41,168,216,36,252,85,64,116,122,7,26,21,210,21,80,62,41,171,78,144,234,200,255,166,74,36,38,11,
254,160,172,72,102,84,75,48,122,170,210,134,78,101,219,1,242,220,223,125,14,95,121,241,36,255,174,21,168,45,232,150,146,99,241,143,167,246,49,252,19,62,23,13,252,229,216,184,17,250,210,247,133,253,242,92,135,159,249,95,104,25,255,213,215,226,115,19,51,206,255,118,55,119,154,79,41,206,25,190,38,219,205,254,178,126,213,228,240,176,25,90,22,125,241,189,248,220,108,61,13,143,119,55,91,173,237,106,191,219,253,90,141,114,159,46,59,130,82,128,40,168,89,53,232,108,154,138,89,90,100,227,5,178,174,38,113,3,245,233,252,125,41,173,188,138,14,21,239,134,237,46,218,69,7,233,93,255,112,158,159,51,248,172,169,222,69,198,33,108,84,220,214,106,43,37,167,168,13,129,121,166,206,140,71,248,114,66,165,217,226,11,114,223,11,69,243,224,60,107,223,67,85,29,189,225,239,151,52,81,243,117,225,129,62,84,86,80,109,253,153,253,254,153,47,177,149,222,40,95,241,95,125,37,90,60,48,61,104,77,238,40,147,101,208,219,183,164,249,52,80,158,190,110,183,42,95,146,36,174,69,146,180,212,71,252,43,14,134,123,247,162,132,229,221,239,85,122,108,
238,86,190,36,201,179,216,33,89,136,197,71,125,8,4,232,221,239,242,67,217,61,98,29,193,90,252,205,244,184,189,61,211,189,224,242,191,207,117,191,71,147,178,251,121,228,60,171,244,56,139,156,102,9,50,116,90,254,205,33,231,224,11,187,167,48,98,252,155,129,126,174,123,173,208,114,232,151,47,109,21,250,114,34,9,199,156,67,237,3,199,189,86,104,105,247,173,230,82,228,84,41,103,57,114,154,122,244,223,237,126,57,244,54,199,165,221,175,70,247,196,142,202,191,89,228,224,166,124,14,250,253,10,114,102,198,170,210,125,83,228,49,251,135,128,52,220,155,128,253,18,232,11,201,204,106,138,184,227,223,28,244,179,108,53,79,247,159,161,156,146,48,43,68,52,79,57,54,242,114,232,151,11,133,214,126,132,55,73,42,31,249,177,42,20,154,122,180,180,251,214,65,5,247,179,92,91,33,76,138,167,148,127,115,200,249,60,215,46,135,190,218,253,103,160,255,60,215,86,133,228,140,124,75,168,122,85,252,105,253,202,191,25,228,124,150,107,103,122,156,249,130,148,47,59,172,34,103,22,247,38,237,190,4,247,108,146,22,127,149,137,204,201,28,147,118,75,
187,159,1,120,230,203,12,244,149,145,24,50,34,167,6,55,63,208,255,110,63,88,41,83,46,19,144,73,62,166,210,176,74,244,80,44,157,127,58,148,148,68,95,82,232,157,250,59,169,126,199,65,164,44,215,159,155,28,170,16,93,123,233,247,66,96,103,96,117,84,174,120,176,50,67,114,156,98,209,202,162,174,252,172,5,34,23,231,218,46,59,177,106,169,42,43,100,70,112,165,40,153,60,177,80,79,141,14,101,184,90,145,52,217,211,86,56,103,214,119,52,119,163,44,189,232,159,244,82,168,242,195,115,228,58,110,44,200,80,117,198,35,110,248,216,4,23,254,61,52,194,136,199,23,80,65,31,247,49,121,9,166,88,246,146,215,223,142,181,138,228,201,239,160,169,203,214,241,147,183,219,217,14,157,170,33,30,212,226,138,139,75,234,45,150,181,250,172,174,17,174,249,103,252,209,88,63,138,194,178,161,6,171,95,1,64,233,72,85,140,199,103,15,158,67,40,72,170,98,168,191,222,254,102,196,89,212,21,182,250,201,184,181,170,84,230,110,131,23,84,6,163,248,37,177,7,91,53,121,168,3,43,162,171,106,97,170,228,184,230,110,196,122,213,34,117,87,163,218,215,76,137,38,
252,115,247,140,188,190,176,251,99,20,105,138,78,144,195,120,154,126,218,164,58,162,138,133,202,128,13,23,35,152,247,221,79,63,117,251,211,126,197,167,173,154,195,118,255,84,168,80,38,94,129,7,112,195,162,215,7,213,169,230,161,194,55,138,36,4,23,188,250,190,168,206,47,26,72,82,142,129,220,224,221,149,238,18,96,138,238,229,125,217,156,22,192,172,90,158,86,110,218,202,140,26,192,148,128,135,208,122,221,62,37,221,32,240,80,236,20,168,40,162,102,209,10,197,59,178,155,244,202,194,51,152,239,148,110,243,74,205,184,167,20,241,178,112,144,28,5,74,121,81,178,212,238,131,240,234,204,192,15,127,86,127,73,210,143,195,46,101,69,73,131,237,88,107,221,131,197,138,176,202,20,73,158,116,193,167,88,141,44,74,10,42,89,151,183,148,189,76,62,42,0,1,78,66,53,177,45,24,79,94,157,5,46,130,31,15,34,173,96,235,38,213,168,32,34,91,32,43,74,106,229,84,153,130,131,207,180,66,253,186,129,221,248,99,184,168,93,120,217,118,243,129,239,0,105,172,170,170,214,95,172,38,87,116,176,214,84,169,114,43,87,254,127,169,250,29,17,83,220,40,0,
18,161,173,236,147,221,16,21,75,52,66,172,5,226,65,202,69,95,107,102,224,154,91,126,165,162,91,6,73,135,167,111,108,248,27,74,79,11,100,143,182,33,223,88,120,107,103,226,6,58,23,174,157,24,253,154,145,210,179,253,223,83,8,51,89,219,254,126,0,33,109,80,205,170,241,54,57,189,90,23,27,58,7,69,18,133,130,40,19,100,49,179,194,45,230,114,153,16,192,80,220,175,8,189,33,247,32,206,64,184,16,164,215,29,150,180,134,86,67,113,97,9,172,238,80,83,136,248,52,57,31,81,68,93,88,139,4,26,2,1,40,249,30,252,253,72,253,71,24,181,68,106,248,253,242,74,133,197,44,194,33,225,249,47,155,18,136,69,140,83,230,84,247,120,129,193,72,15,128,161,78,36,179,32,224,192,76,79,180,14,32,201,10,218,85,171,140,234,205,16,234,136,12,66,105,202,74,184,137,176,135,42,192,186,160,240,130,179,22,70,3,160,35,134,209,69,94,46,184,124,85,66,233,85,198,191,190,102,65,142,202,170,202,220,68,167,234,153,118,211,214,220,44,16,121,229,229,78,64,228,101,181,171,93,23,221,90,137,65,43,228,205,2,218,205,103,101,95,10,225,36,212,165,227,110,9,102,78,132,
245,15,46,208,89,143,211,246,213,118,220,129,53,143,32,133,75,198,124,118,172,24,108,79,120,114,96,252,15,19,17,0,152,169,46,109,119,173,56,157,85,46,73,113,90,82,21,208,17,193,95,4,158,116,120,113,111,10,85,111,117,145,138,36,66,88,12,80,119,201,50,138,153,193,158,224,183,38,94,67,217,110,26,208,203,230,199,219,197,126,72,50,7,77,49,3,38,137,28,170,70,98,67,200,171,8,225,109,193,212,80,6,215,238,97,67,48,214,169,42,84,170,199,126,150,162,21,174,41,130,170,97,167,99,174,60,145,98,176,34,156,177,240,104,91,101,86,193,94,0,46,220,107,166,14,115,105,36,74,37,70,241,44,250,11,119,151,192,128,197,125,8,126,209,139,93,243,82,220,247,226,189,20,69,19,77,138,217,61,49,1,55,226,36,69,247,8,250,250,221,111,177,227,34,26,183,69,101,65,106,127,114,251,159,5,94,243,169,174,162,179,144,120,137,42,40,213,110,156,48,2,10,225,100,110,124,251,168,162,201,148,124,166,88,97,44,57,76,169,243,156,106,202,10,219,230,186,7,144,249,170,60,185,120,129,40,179,46,191,225,193,8,190,54,179,195,98,52,118,195,205,56,185,188,124,245,
60,89,147,58,178,21,176,59,90,36,152,188,150,125,117,78,244,185,247,111,90,42,167,59,175,61,91,202,24,129,109,188,190,189,253,111,70,2,86,83,144,95,157,186,102,175,196,169,93,122,49,123,80,30,46,20,9,84,16,215,130,152,58,183,239,205,92,163,195,194,191,183,203,108,172,26,40,28,237,149,130,41,43,9,189,89,117,72,74,130,169,58,164,27,7,186,26,207,138,199,67,166,162,72,39,42,40,175,18,172,54,177,194,67,161,7,138,149,205,50,107,63,158,13,96,93,163,78,89,40,1,84,43,17,25,1,229,231,171,140,171,144,8,187,34,176,184,2,73,154,106,246,106,31,227,14,196,171,174,157,145,60,13,33,92,187,172,193,110,116,164,198,229,132,91,27,63,168,26,186,38,163,134,220,67,104,50,89,208,233,23,153,208,241,58,28,70,228,182,34,130,103,130,92,115,208,252,22,13,202,107,119,41,165,204,111,133,72,194,178,224,199,175,239,129,95,216,104,9,55,17,233,237,41,5,100,219,227,251,145,192,143,208,112,143,208,7,233,20,219,178,49,49,165,177,32,30,118,137,34,4,122,23,216,163,196,100,173,253,6,35,91,191,57,144,52,11,85,188,196,170,16,169,26,241,6,52,6,
113,21,43,172,199,43,62,17,163,83,63,67,127,97,42,193,11,99,75,240,88,181,127,109,62,21,80,199,27,35,10,115,235,201,188,26,48,84,73,19,96,89,128,97,64,140,37,232,17,237,232,54,236,170,112,141,128,124,128,201,45,168,19,79,8,201,178,69,23,221,67,33,1,18,75,233,162,179,88,52,172,42,80,44,177,38,141,26,217,62,82,203,2,178,70,136,220,115,202,221,120,92,18,207,220,40,161,21,72,163,229,233,155,24,75,112,158,172,25,158,109,118,90,37,43,234,25,110,112,144,13,10,209,113,203,134,91,206,200,4,9,15,102,234,202,220,100,143,152,95,23,7,220,96,181,153,121,7,167,11,0,243,216,174,50,139,246,115,31,92,142,42,97,98,80,243,9,197,206,253,74,81,221,26,165,166,245,139,91,43,181,204,178,86,193,94,107,245,215,235,145,109,250,186,31,76,70,167,202,49,203,73,212,58,10,185,224,88,87,138,217,231,234,219,230,108,22,34,110,142,152,92,170,80,90,244,3,166,46,218,41,172,171,86,213,76,45,219,196,162,231,176,93,136,117,210,186,93,247,61,21,31,94,54,3,90,160,184,2,37,150,90,143,208,200,227,28,121,149,91,38,24,76,9,222,177,218,250,206,182,
54,144,48,215,153,22,87,86,249,21,3,229,142,87,161,196,180,89,165,169,206,144,2,162,133,249,143,83,171,101,44,145,23,198,241,217,93,76,198,93,42,200,199,169,25,205,235,222,184,209,144,186,204,247,181,19,196,249,56,216,124,212,63,71,206,107,169,138,86,46,0,67,65,219,18,227,204,89,157,134,155,26,77,2,122,161,250,120,237,221,33,23,8,25,143,52,46,194,149,26,141,119,54,224,97,120,169,145,143,219,201,19,89,159,79,190,77,134,246,242,204,79,87,80,69,131,205,207,162,77,32,235,70,144,143,13,221,154,148,55,180,252,79,28,12,250,49,179,62,226,166,131,125,246,224,102,61,93,141,162,109,84,5,22,192,163,149,140,150,213,43,125,143,220,55,163,46,242,171,213,141,118,9,147,22,246,107,188,154,3,242,150,27,22,80,189,197,219,241,134,216,134,221,13,17,56,41,24,74,21,45,59,83,85,191,30,129,109,204,222,235,81,247,181,139,79,221,60,67,36,216,30,220,194,41,252,172,45,5,45,126,165,75,55,242,253,166,150,186,102,101,30,95,152,22,27,131,114,246,3,147,10,85,165,89,55,111,74,155,242,49,153,4,0,88,39,208,11,93,37,31,6,220,179,99,138,140,
194,190,109,237,16,219,0,254,182,118,180,131,37,62,59,25,180,36,134,135,4,156,207,70,87,29,110,141,179,240,143,61,107,232,98,136,7,171,116,146,231,220,229,200,20,213,84,28,99,151,36,66,0,212,16,174,246,25,168,21,134,43,28,42,105,141,16,63,97,225,217,155,45,67,65,136,4,191,183,109,153,120,86,161,114,65,197,134,59,99,197,37,161,67,219,121,165,187,45,186,142,159,173,55,106,167,99,212,235,238,52,131,80,207,245,33,96,113,230,183,128,134,69,56,53,92,198,142,80,173,159,112,64,17,157,96,217,187,11,161,144,229,66,147,171,28,134,50,180,162,49,227,14,201,140,108,245,171,147,164,123,185,95,148,27,189,76,148,199,56,27,34,101,144,163,211,128,27,102,46,212,72,91,189,114,191,42,213,189,181,95,7,60,28,94,52,93,227,217,24,246,92,203,132,200,9,47,201,140,150,11,1,155,65,11,74,67,65,198,176,196,161,0,120,101,120,161,149,242,200,210,38,90,49,191,246,213,132,124,48,65,203,78,227,181,28,229,208,178,203,46,222,129,252,251,226,126,9,192,112,87,189,125,59,29,124,144,73,107,10,73,98,131,247,168,138,143,49,130,17,138,137,29,23,
246,46,229,238,8,105,113,183,80,131,27,193,176,252,42,242,131,141,138,157,254,72,59,93,238,10,185,120,71,38,128,223,24,24,196,181,233,60,168,144,165,67,254,218,248,72,126,129,91,116,32,15,34,237,131,147,24,188,170,216,234,8,186,96,223,92,193,46,149,121,187,157,19,186,226,254,48,243,235,88,139,94,3,59,199,221,170,114,128,17,55,3,4,74,121,101,215,91,176,50,66,127,174,43,26,143,255,207,113,237,57,200,10,183,69,173,193,147,4,149,164,87,33,246,136,16,221,226,164,235,105,180,164,126,67,70,165,7,169,94,122,9,89,0,245,43,191,160,80,103,158,255,169,24,10,247,13,212,33,159,139,233,149,191,73,31,24,140,212,7,179,141,94,169,101,166,161,197,40,37,211,134,87,217,223,80,220,145,230,172,143,162,24,166,159,209,191,177,27,187,89,204,110,204,49,221,94,87,253,239,186,220,13,67,100,176,177,195,93,143,49,70,101,45,219,220,214,196,198,178,89,110,241,46,41,93,84,224,21,234,49,225,116,219,10,30,143,1,20,164,59,118,158,41,10,172,44,187,33,217,136,134,203,154,69,20,50,3,141,177,237,234,117,45,174,212,186,93,50,32,58,244,235,110,
72,255,193,131,19,61,64,223,208,61,87,67,16,10,32,160,134,91,41,115,30,30,154,121,19,153,10,154,60,216,109,82,52,4,137,52,176,182,137,100,137,65,135,225,46,29,134,63,146,143,22,75,241,99,149,229,68,168,31,90,99,12,238,152,129,81,20,151,211,141,223,191,78,127,139,247,192,53,236,218,211,75,215,242,197,21,98,220,203,147,173,163,206,15,255,43,16,68,188,70,178,186,200,255,101,248,249,179,70,134,189,63,107,68,90,78,254,103,109,180,218,171,180,89,84,17,126,110,202,62,221,153,249,61,152,203,3,184,231,97,156,135,103,89,53,122,179,79,200,69,224,146,149,249,178,247,121,45,106,240,1,198,173,213,244,151,95,207,189,93,84,181,103,181,37,67,230,42,229,155,40,18,111,4,105,6,193,232,150,4,160,181,27,233,163,65,2,121,216,61,6,0,45,242,115,145,67,199,18,100,122,155,222,7,228,219,52,96,74,238,138,151,21,239,178,10,45,233,31,66,208,64,20,218,214,253,96,38,111,76,140,165,247,162,61,177,168,246,101,42,148,105,81,85,6,171,106,9,247,173,204,107,251,216,197,207,165,59,99,113,143,155,89,16,69,191,5,45,197,203,230,103,92,77,115,
124,79,164,56,208,27,67,121,92,145,28,42,238,96,195,104,67,162,35,89,73,79,244,207,69,32,177,228,73,134,114,223,200,250,48,62,71,34,152,143,130,123,37,212,206,199,174,139,168,77,110,65,216,210,156,190,12,168,21,194,37,36,162,124,136,78,34,40,139,82,19,248,185,150,71,183,233,40,192,9,174,109,110,74,63,212,76,132,31,23,227,6,143,4,137,173,50,243,15,137,148,49,83,209,60,192,8,1,43,233,247,78,77,134,4,245,16,17,244,197,229,122,40,30,57,78,120,34,74,204,8,142,151,109,145,196,172,75,198,82,107,223,183,42,188,33,187,224,33,54,145,44,184,253,237,45,249,141,49,125,82,81,12,150,131,120,134,217,120,210,41,55,227,84,247,204,248,166,150,238,59,52,125,168,15,114,36,42,142,80,17,40,137,30,145,169,22,235,14,8,21,139,149,25,83,230,105,250,16,72,247,224,128,176,224,228,243,251,56,38,138,221,87,79,214,108,208,195,173,173,245,136,124,209,177,44,247,79,132,35,252,198,167,106,211,106,75,35,9,17,37,64,7,138,32,234,194,5,142,186,235,203,150,212,253,158,194,81,115,148,188,209,214,159,196,165,118,78,82,101,140,178,92,149,171,
103,203,253,197,200,65,44,5,221,133,155,161,162,158,14,55,222,189,8,59,144,239,48,59,185,228,126,75,166,85,165,179,8,99,140,18,41,167,84,168,179,200,206,124,204,40,6,6,44,32,32,190,193,160,54,197,22,239,169,8,161,109,169,252,94,242,227,251,19,49,60,242,4,134,194,244,119,161,98,42,19,170,243,7,22,189,79,123,4,45,20,145,178,157,34,232,55,154,57,73,61,0,139,51,145,94,73,169,193,146,40,35,66,27,138,83,72,83,204,208,127,136,131,42,51,15,226,90,114,251,210,27,109,42,229,182,255,87,220,140,107,129,102,120,91,1,212,130,146,92,126,232,114,149,46,17,115,108,78,54,80,48,110,68,254,198,68,33,106,25,241,109,198,168,44,194,34,125,153,25,137,118,67,250,90,92,112,187,20,133,45,9,227,27,196,31,176,70,30,54,103,86,38,31,108,169,183,244,182,84,240,84,25,139,246,13,94,11,6,98,57,12,47,96,99,144,14,141,37,5,222,65,182,134,226,218,162,156,192,6,155,82,136,79,52,180,153,8,78,96,23,138,56,170,13,160,7,51,188,176,7,53,180,71,89,34,124,178,69,98,179,210,72,3,117,114,97,217,238,235,134,141,55,219,87,40,144,87,130,7,133,17,174,
22,255,249,118,30,220,16,17,105,190,174,225,143,31,181,251,48,63,50,208,64,53,128,180,160,95,95,4,136,38,236,222,67,148,1,211,66,153,8,240,65,112,205,144,41,11,50,208,46,246,93,148,168,80,168,239,175,152,104,196,38,19,67,89,170,118,49,78,85,183,112,61,151,146,86,77,178,165,228,142,239,36,71,190,55,251,106,56,190,234,118,120,236,23,185,59,194,159,63,196,247,153,34,217,21,98,43,241,37,113,241,96,74,118,247,17,229,210,63,102,24,202,88,143,30,41,43,102,172,197,20,154,2,65,75,217,66,89,17,157,229,250,1,206,209,32,222,195,123,88,91,64,8,218,0,219,216,229,134,154,181,166,212,251,122,237,33,236,106,194,102,35,87,32,211,134,136,238,7,110,55,60,209,50,105,17,187,186,242,212,236,221,72,212,198,43,129,78,108,89,22,17,176,38,224,227,6,130,116,101,5,211,25,121,192,236,54,161,107,221,174,106,180,20,58,113,74,130,1,2,113,105,233,1,195,9,193,118,58,194,93,80,208,73,88,179,21,168,66,208,96,94,112,171,156,68,115,166,45,77,51,243,233,249,119,197,3,77,252,219,205,66,16,247,115,44,109,223,238,178,80,181,196,152,72,25,45,97,
183,210,219,70,152,44,246,95,116,89,153,221,5,111,17,127,141,65,73,38,187,0,149,48,223,198,83,240,25,230,238,55,82,50,135,160,36,238,117,139,213,26,213,174,55,246,57,176,16,27,1,212,207,98,143,136,103,128,43,195,2,49,4,0,37,136,222,213,151,148,177,112,67,163,12,91,221,156,178,64,192,240,102,228,25,242,231,165,159,114,60,4,71,98,69,158,217,205,176,74,134,128,0,141,151,29,43,92,163,137,94,13,183,190,137,10,81,218,35,100,38,251,230,22,228,212,133,121,76,92,247,36,9,15,0,141,105,160,118,213,7,222,66,106,130,88,111,240,103,77,211,38,126,198,14,108,233,3,214,74,155,93,247,1,19,48,122,43,68,138,194,119,166,232,195,187,102,39,72,232,152,101,168,216,29,76,133,186,192,98,42,229,9,208,92,254,137,112,9,72,176,220,23,189,88,12,24,101,152,115,184,146,188,171,56,177,102,46,200,203,168,42,70,54,169,251,128,105,162,70,18,15,83,199,172,9,115,183,23,31,45,136,80,71,89,1,204,136,211,133,160,24,189,47,20,149,5,75,0,109,240,190,14,181,137,56,211,77,160,90,120,219,168,65,207,2,151,1,40,178,254,105,132,91,180,66,84,209,54,105,
119,100,156,148,144,135,43,232,112,96,121,93,27,241,54,4,75,133,3,50,211,208,222,183,11,83,213,194,79,2,56,174,29,161,207,25,196,115,226,3,198,43,54,51,105,221,54,182,32,228,157,208,206,12,87,105,54,24,144,161,60,25,160,204,28,16,208,178,40,221,29,161,133,175,69,145,35,81,153,110,21,91,144,187,78,117,96,247,34,136,12,148,185,196,12,110,49,132,200,252,132,135,108,19,140,44,196,17,196,96,111,4,120,124,17,61,88,179,112,32,17,34,195,222,76,205,199,176,211,5,218,119,24,235,210,123,36,133,18,175,226,21,237,118,249,232,135,16,98,177,148,146,156,220,158,30,185,75,25,124,171,169,199,200,89,237,156,48,161,226,230,15,9,177,104,83,232,32,216,131,125,3,37,183,71,223,193,239,92,102,42,154,161,182,0,37,130,35,249,1,108,88,152,82,157,115,127,50,91,246,225,18,68,123,10,38,164,179,170,132,41,17,36,3,211,23,219,61,137,62,18,1,129,35,217,3,75,192,32,102,0,106,123,69,22,144,16,38,110,131,90,48,140,43,243,51,112,33,151,165,166,222,41,0,215,56,137,161,208,135,93,247,123,79,71,136,65,245,218,151,130,180,152,62,61,68,25,10,85,
96,77,153,86,223,221,230,104,25,94,94,198,221,246,64,196,19,116,88,229,173,146,73,130,233,12,218,180,123,61,86,156,11,144,251,22,189,229,204,2,231,153,136,76,145,123,197,213,194,149,65,93,244,8,173,154,155,101,52,8,53,154,172,75,188,186,92,240,45,175,112,82,188,87,88,163,96,214,173,102,145,154,93,168,90,109,47,229,82,108,169,24,187,98,63,119,123,218,134,193,103,200,225,14,173,227,4,237,115,103,49,249,64,166,58,174,195,102,181,92,117,55,34,229,226,233,162,74,29,206,236,247,56,131,22,65,250,86,177,32,60,243,201,247,211,201,117,227,105,29,67,138,216,154,146,93,20,140,207,184,175,153,185,88,22,8,23,154,58,2,200,122,145,97,0,182,143,180,136,230,131,88,70,228,21,209,238,59,155,184,5,29,160,0,84,128,46,104,13,62,130,35,165,60,21,102,113,6,196,121,185,128,154,75,70,233,158,37,121,156,100,114,149,11,89,188,198,136,224,174,184,221,211,232,3,155,206,151,45,46,90,209,90,82,233,195,111,175,116,163,244,165,29,10,81,90,235,169,64,208,215,112,164,35,28,219,168,28,201,32,157,113,230,15,12,179,11,102,136,216,26,18,93,
167,42,159,69,100,107,20,162,175,254,85,219,125,106,28,252,209,128,254,152,132,2,52,181,116,244,97,89,211,143,196,187,89,238,49,249,108,155,218,8,39,28,218,72,199,108,13,124,204,106,87,253,81,245,53,59,75,182,197,143,181,171,187,202,225,138,68,217,51,5,136,159,26,60,164,193,204,155,243,13,70,181,54,7,183,42,127,70,37,252,86,203,70,211,171,202,239,213,23,245,232,31,148,253,169,169,90,101,229,175,218,70,179,233,119,185,126,83,133,182,54,45,63,147,45,248,6,111,180,167,118,222,175,166,50,134,149,63,159,19,63,214,110,72,99,169,60,168,246,250,169,161,135,181,155,207,33,252,70,144,201,220,168,252,45,163,125,181,235,173,210,174,219,30,86,154,17,170,98,117,182,62,53,248,121,80,251,253,122,102,38,254,236,247,81,118,83,251,125,230,65,120,203,159,232,108,82,249,87,125,135,23,203,7,179,239,84,31,204,60,153,89,194,57,42,248,61,253,152,250,166,103,173,15,67,87,254,210,105,167,59,220,226,199,174,158,116,151,60,249,240,177,242,0,47,191,147,13,153,57,30,43,107,251,33,173,245,135,72,147,178,197,236,106,85,199,30,85,115,
200,241,122,109,108,97,169,63,154,73,255,246,17,248,177,54,234,204,80,72,181,107,30,213,70,213,149,155,167,125,188,209,94,77,245,12,42,127,142,101,126,172,141,39,75,123,230,81,109,150,0,231,240,41,2,52,97,87,246,108,228,101,177,215,218,100,150,54,171,48,127,170,10,130,201,34,210,224,71,6,231,63,101,215,97,153,253,9,97,221,202,95,101,212,187,116,102,145,28,185,252,88,195,69,174,44,78,192,58,63,246,245,164,202,34,142,245,248,164,42,51,28,107,60,25,213,238,250,213,206,66,111,208,66,222,224,73,237,211,44,51,205,76,93,143,254,241,169,223,155,211,61,53,126,170,204,200,117,212,130,102,179,252,62,183,32,81,188,214,84,137,172,242,87,5,64,50,161,198,45,59,133,78,136,7,17,255,244,32,1,182,187,219,0,197,171,155,184,78,104,213,111,56,234,45,149,98,254,73,208,254,215,132,46,44,111,169,104,236,25,207,210,233,108,41,178,5,142,95,24,95,202,255,252,72,130,140,243,218,105,58,64,218,152,117,88,26,235,165,13,142,174,198,60,150,237,97,33,218,53,44,74,238,150,69,159,118,123,10,239,15,200,194,27,19,157,9,71,234,215,67,218,130,
71,206,165,25,111,127,59,82,32,85,177,69,235,254,149,130,39,108,194,245,187,102,226,231,181,75,210,28,45,190,166,49,16,120,37,16,30,243,226,100,60,211,246,92,144,153,199,85,24,99,20,191,30,90,152,157,228,24,52,79,14,4,6,28,218,14,151,33,9,30,246,12,32,153,181,214,25,246,236,44,4,193,103,81,131,96,7,210,155,60,126,51,189,251,137,165,0,121,58,29,75,246,238,236,226,178,78,14,167,149,33,176,0,169,188,35,89,148,218,112,182,125,137,153,142,78,174,45,117,65,89,112,66,113,72,27,21,166,71,228,134,254,40,131,31,187,57,102,36,173,173,229,252,108,110,192,58,73,72,15,172,170,73,138,61,60,36,151,6,207,26,99,202,55,18,113,175,194,157,206,51,168,243,66,7,150,201,121,167,235,154,195,228,158,96,223,18,28,195,180,35,15,71,29,96,5,105,85,202,227,36,22,255,134,220,250,134,85,121,235,50,230,216,38,26,89,178,132,219,253,68,34,247,247,126,114,251,253,74,1,10,96,32,52,33,42,82,135,218,62,146,45,175,188,23,219,142,32,139,194,107,32,120,100,205,96,192,83,35,21,142,40,46,241,58,123,19,255,133,211,28,50,81,25,147,100,84,174,87,6,
134,11,223,204,80,180,123,22,6,192,42,183,85,128,134,182,239,201,23,197,198,109,103,93,130,221,97,103,66,83,33,48,171,181,113,79,68,63,96,249,13,72,28,35,148,236,137,44,66,129,253,30,151,208,176,112,66,94,230,39,109,205,107,139,198,120,162,178,61,230,201,59,129,124,180,136,193,91,1,248,224,46,124,228,162,101,203,233,210,238,10,118,44,117,27,24,26,252,116,39,135,181,90,29,122,252,157,253,95,72,24,222,22,0,214,163,54,75,253,1,46,150,146,229,161,142,60,169,179,89,30,127,135,50,16,253,202,101,226,77,54,163,54,107,245,0,5,121,107,227,164,222,207,111,202,62,35,121,95,13,59,247,52,180,33,202,167,230,105,93,119,179,158,37,74,64,23,158,249,59,7,184,86,199,3,89,182,175,19,55,222,102,40,71,217,8,209,144,175,142,25,87,193,6,102,133,96,8,1,14,156,138,209,134,37,50,55,145,33,102,208,165,45,36,147,32,3,142,99,48,123,156,43,222,98,209,199,41,244,12,219,68,161,21,135,227,81,4,13,84,207,46,160,157,83,96,33,99,210,49,98,203,98,176,66,123,124,191,112,6,236,56,134,29,20,40,59,89,64,58,189,225,240,131,173,106,112,46,213,215,
156,112,178,99,89,4,157,156,221,68,32,80,146,237,242,141,186,80,169,230,111,42,79,92,32,146,47,200,144,7,74,51,82,197,146,0,158,112,55,33,134,33,66,82,176,128,94,115,24,79,137,63,114,146,73,34,231,84,138,222,207,217,95,162,107,235,50,224,119,17,84,145,232,44,149,72,125,136,104,21,146,178,23,235,223,253,143,6,91,180,140,223,104,252,80,145,68,26,32,250,120,194,191,131,0,76,240,29,72,215,99,4,221,104,8,211,39,214,7,223,42,221,88,104,195,60,236,138,179,232,84,225,147,34,155,129,45,226,160,90,213,157,227,164,68,210,124,66,41,109,135,65,196,71,122,152,65,155,182,240,176,16,52,41,243,74,125,37,76,44,153,200,134,161,219,69,88,35,96,237,42,66,161,72,133,177,152,173,126,25,108,245,210,53,22,90,213,57,153,27,18,117,92,135,122,239,238,178,58,24,134,77,20,5,196,172,52,233,78,38,79,245,186,27,179,179,162,223,185,144,112,152,155,97,192,34,133,32,216,236,130,128,101,143,205,65,198,151,214,183,54,184,181,215,19,233,123,150,118,242,195,90,147,195,97,200,188,15,166,142,180,246,70,218,104,74,229,141,69,14,160,238,7,48,198,
111,74,169,91,196,10,197,250,25,71,214,90,155,10,110,115,66,114,182,47,15,118,91,172,7,176,194,185,129,14,199,11,45,225,202,168,246,78,228,118,71,226,185,239,115,197,48,140,21,167,25,196,100,216,92,217,82,85,176,102,121,123,141,48,1,27,183,83,132,201,150,39,24,24,84,235,181,157,77,82,239,99,39,138,250,163,17,194,204,88,43,41,61,208,11,241,115,174,74,211,230,75,156,55,31,67,236,1,50,17,93,131,147,69,28,100,234,223,30,126,222,252,65,92,123,208,203,115,157,200,9,13,71,128,148,64,20,179,97,140,78,242,65,151,24,12,52,167,36,65,225,20,155,89,65,116,116,194,140,110,95,171,154,64,100,203,120,209,10,179,170,208,161,197,134,123,88,17,41,29,151,206,112,26,160,66,126,8,124,144,0,77,122,244,42,237,109,126,119,53,254,161,230,255,177,246,110,226,124,15,61,97,34,144,107,58,28,124,63,135,131,118,143,152,228,247,117,29,254,170,243,106,167,251,145,128,177,253,68,78,47,177,214,185,31,101,19,232,167,138,92,169,125,215,75,209,26,179,175,53,236,55,83,81,116,30,117,228,15,23,174,19,191,219,178,199,244,211,29,140,136,55,205,
140,216,32,69,16,117,42,109,251,125,169,93,187,157,74,63,174,199,190,175,3,201,103,70,7,133,154,65,227,227,40,237,68,72,212,107,253,135,183,252,119,117,24,236,157,196,0,240,143,166,69,191,100,116,215,219,63,28,155,77,30,170,203,172,14,71,208,250,6,72,248,252,197,144,4,46,169,255,112,138,208,19,247,252,175,193,85,62,250,246,59,44,87,157,31,186,239,129,251,107,76,252,134,204,183,195,131,189,127,251,182,254,195,218,27,133,236,225,38,120,119,143,77,44,69,15,33,42,118,132,214,191,219,210,139,63,148,115,17,157,64,153,218,240,168,16,83,195,200,7,151,228,19,7,49,111,38,183,223,171,27,155,79,132,39,145,125,249,125,157,96,228,29,27,80,223,215,239,179,60,146,66,108,194,40,177,119,150,127,198,216,134,26,42,4,220,54,219,149,8,197,152,184,127,61,206,10,98,144,165,223,152,12,71,135,73,147,61,88,102,54,75,134,228,197,76,16,24,139,95,183,253,12,94,228,172,17,9,13,132,13,191,135,184,65,75,36,201,228,66,46,66,196,42,93,111,1,145,200,20,142,169,104,209,90,248,189,248,71,236,250,131,85,195,193,17,35,207,99,98,57,133,170,
80,4,235,246,193,33,251,194,248,26,38,21,46,10,175,131,48,108,225,230,77,110,49,140,198,67,162,107,184,59,153,210,252,186,57,73,202,56,26,139,122,155,42,120,203,185,47,173,167,122,70,168,148,221,242,10,27,140,36,41,154,212,180,163,2,242,125,180,218,178,49,12,136,170,230,153,17,107,216,70,183,242,52,49,145,43,16,121,2,70,60,137,193,216,31,25,152,84,39,204,124,114,192,37,210,116,128,42,252,32,195,210,0,244,70,21,79,211,144,237,91,78,96,147,243,133,163,104,112,145,102,197,185,119,79,245,84,119,133,34,48,104,229,46,218,88,216,155,185,78,165,73,109,160,147,140,152,75,251,176,234,7,27,139,129,1,59,89,99,222,136,154,155,185,68,182,4,31,131,165,231,153,127,151,210,61,58,8,88,120,200,127,221,11,143,27,3,230,43,152,183,206,229,200,140,31,6,7,37,229,161,35,135,206,225,101,3,201,115,188,146,11,184,181,246,78,198,144,188,157,224,228,185,238,179,23,204,27,99,81,209,156,97,187,192,34,3,165,119,93,58,207,151,232,75,239,128,137,105,227,138,25,195,21,169,14,119,200,226,245,254,194,235,97,19,16,243,222,68,155,155,53,168,
187,116,100,186,155,230,57,167,193,161,10,55,115,67,207,44,211,9,192,129,52,209,217,253,19,148,26,249,121,246,133,228,104,145,29,179,224,76,157,251,182,51,158,171,121,149,22,180,56,85,124,163,154,255,102,8,51,236,241,41,204,26,90,81,103,166,235,29,155,2,196,30,18,215,48,179,33,156,17,74,99,95,134,36,51,129,141,6,28,49,114,235,252,108,122,153,235,193,44,94,201,165,9,219,44,164,118,88,180,128,205,27,152,75,116,166,132,30,144,23,107,99,146,231,185,217,191,215,195,77,206,187,213,131,81,106,52,232,208,134,201,220,89,158,1,238,117,189,210,186,140,38,200,100,169,218,240,114,196,68,138,184,146,97,98,228,127,77,123,16,56,21,26,141,143,205,34,168,175,201,114,51,237,186,254,31,149,142,161,164,247,74,64,155,76,7,150,159,239,158,146,3,36,1,98,101,24,45,36,19,86,82,116,62,155,120,72,152,230,33,118,56,225,9,160,37,182,162,179,24,207,40,68,115,17,60,197,204,52,168,236,58,45,142,53,153,224,1,81,58,182,109,43,69,203,171,140,140,236,16,110,153,3,209,79,60,184,224,242,216,150,56,136,19,7,61,195,65,216,12,183,48,143,23,159,
148,74,199,150,26,43,247,57,164,226,11,226,208,48,178,7,132,200,6,170,143,85,73,212,179,211,146,221,9,100,33,19,185,48,219,193,35,237,11,226,227,48,46,161,1,60,127,68,17,89,104,209,249,241,117,166,103,241,170,101,94,98,40,226,139,89,115,102,25,204,94,86,102,249,230,104,58,98,131,24,175,17,74,3,84,75,225,117,179,179,92,27,6,78,129,14,7,3,12,190,207,51,172,108,103,4,72,142,0,10,118,185,118,158,187,138,21,70,136,0,31,65,219,136,95,213,144,232,19,142,169,178,127,37,177,101,122,43,154,50,184,225,173,96,222,74,104,231,218,137,36,194,19,126,210,6,247,11,16,1,17,179,92,38,107,17,156,222,195,12,184,22,88,250,128,155,24,251,18,208,172,154,10,122,164,236,36,66,106,182,167,135,22,233,153,62,20,85,12,108,87,211,146,28,141,38,196,210,208,160,200,92,129,5,2,89,216,43,22,207,81,206,128,109,124,179,111,217,147,30,147,37,12,141,136,51,64,154,38,84,36,135,152,167,18,76,0,186,13,27,118,160,238,72,249,139,76,55,4,76,176,31,34,45,91,124,64,169,57,108,163,91,238,139,7,120,3,31,155,32,161,167,88,26,64,39,167,3,213,123,244,195,
232,71,107,168,9,160,120,169,73,33,248,252,33,34,75,75,167,24,95,62,181,244,52,121,73,196,19,136,106,115,36,178,86,251,133,197,209,182,63,63,104,125,174,134,55,56,15,91,10,44,177,201,166,220,93,109,253,134,149,164,75,162,109,230,169,137,67,116,36,39,174,177,172,22,148,169,186,21,24,209,73,85,248,34,230,0,185,147,38,193,69,177,213,194,141,54,182,132,250,84,92,2,24,37,243,44,188,33,134,24,144,106,41,160,140,202,196,16,33,223,22,248,57,244,41,224,164,71,3,158,196,136,134,230,128,189,120,128,35,89,243,51,143,174,218,205,253,207,6,22,39,17,155,69,249,193,40,142,1,80,130,41,81,36,200,224,84,101,159,44,205,203,36,46,225,145,67,199,81,179,181,179,201,183,154,33,44,124,57,76,74,137,232,197,111,57,61,6,29,41,52,195,178,215,231,122,50,151,80,24,90,52,149,4,65,107,33,28,159,158,231,131,205,136,114,177,120,220,248,79,237,92,156,162,165,224,111,49,162,205,244,168,87,193,13,227,91,98,10,107,231,3,5,125,34,25,22,23,115,30,238,228,135,25,20,240,181,156,182,236,100,133,150,197,86,74,48,144,167,57,195,170,243,157,97,169,
171,61,44,238,140,237,43,94,157,40,43,114,9,52,74,107,39,190,128,229,64,114,64,23,3,165,32,19,44,69,40,33,16,146,71,17,3,166,163,149,50,206,236,109,250,134,128,45,68,25,184,67,67,151,0,155,15,93,197,80,117,65,217,165,254,12,29,132,90,199,129,22,89,26,108,90,29,119,18,129,58,65,66,97,145,216,204,142,128,35,21,107,196,96,136,148,106,212,91,124,51,19,83,241,102,29,28,116,226,117,203,89,75,227,103,143,36,93,174,169,131,139,37,41,141,228,170,200,210,217,25,53,100,185,89,80,164,194,34,42,92,44,195,156,77,8,51,106,176,107,73,213,8,200,43,7,23,111,104,160,240,102,117,61,130,93,32,203,66,103,78,124,237,255,41,91,100,185,117,177,96,213,205,184,48,206,182,113,34,18,188,211,10,174,255,9,151,209,115,25,52,140,102,75,160,139,98,175,172,4,30,244,59,130,130,128,52,203,141,56,71,36,68,158,23,196,166,137,198,45,53,113,143,116,78,242,25,133,169,61,180,176,149,230,209,179,168,171,98,198,58,157,203,178,65,216,131,212,23,136,63,56,82,186,110,130,10,242,99,88,197,215,96,146,106,147,202,86,36,54,179,52,77,255,85,38,243,236,
203,254,187,105,233,248,68,89,123,254,25,75,162,146,81,233,78,165,35,65,81,145,178,81,161,70,3,51,49,233,147,162,250,213,91,188,71,14,39,21,37,152,89,31,144,103,243,130,24,131,253,6,73,146,80,165,45,69,201,55,3,138,249,250,78,87,17,178,66,182,133,186,0,178,7,156,136,99,94,160,91,5,240,95,148,242,1,27,252,206,201,8,109,110,250,217,142,41,99,251,182,138,194,155,74,34,28,81,124,24,56,72,8,193,220,87,168,59,42,60,52,220,109,216,168,209,1,240,44,121,117,249,46,26,68,114,188,138,112,41,62,114,88,153,11,9,204,45,43,7,133,247,51,201,106,150,217,35,138,52,198,49,150,66,230,24,80,145,185,227,201,26,219,22,242,110,137,87,235,157,122,165,215,88,89,24,172,188,2,85,81,34,85,57,137,71,248,153,216,25,38,45,148,105,108,201,80,38,16,9,28,203,11,150,187,128,66,54,153,85,193,175,200,201,234,119,207,40,117,237,154,225,144,7,17,142,81,228,145,136,210,223,126,41,46,179,41,251,196,194,230,33,139,32,115,128,13,60,151,158,193,51,173,251,142,177,189,64,24,197,168,114,45,216,45,178,89,20,185,4,147,47,237,108,161,119,187,16,147,
17,137,194,144,1,142,240,145,188,15,103,18,195,202,68,20,86,186,171,160,240,50,190,27,67,0,74,178,180,42,23,149,158,66,8,23,74,101,4,100,163,50,9,117,2,0,57,76,12,0,55,79,35,106,203,148,21,149,57,129,81,7,145,68,155,209,164,178,34,98,102,166,41,38,161,215,233,44,68,51,64,191,237,22,25,45,216,60,138,189,162,48,21,204,121,50,149,192,38,218,20,8,140,34,102,113,72,66,158,1,48,131,70,211,204,208,102,196,192,185,31,44,215,58,173,229,236,243,133,101,164,199,112,156,220,122,182,229,16,238,250,50,67,13,40,5,109,180,195,79,94,21,189,249,234,84,199,231,112,246,151,12,34,247,27,88,56,41,225,28,32,251,48,74,61,183,75,148,34,161,252,241,120,246,84,105,120,74,129,36,29,18,81,40,65,161,194,71,222,73,56,217,167,198,38,62,50,219,111,242,232,50,8,12,44,44,220,185,64,144,120,209,52,125,241,248,2,56,46,110,176,11,100,181,73,34,23,66,210,209,40,109,24,176,102,130,82,189,25,190,194,84,194,67,25,40,34,172,10,28,136,109,55,72,28,151,206,144,204,67,85,7,80,48,108,20,33,121,80,185,97,33,125,79,229,71,202,26,224,182,104,19,228,
189,239,143,191,146,72,215,238,195,27,172,212,196,191,237,110,38,129,182,253,251,222,102,162,44,250,23,33,45,190,182,191,153,156,71,239,230,13,7,209,114,227,174,216,55,172,171,193,169,159,72,165,60,243,134,80,240,114,218,29,171,194,144,102,89,102,154,27,142,48,128,84,150,140,121,174,180,244,211,17,59,223,32,115,193,66,186,126,1,31,146,194,72,186,234,68,125,199,185,58,57,204,64,167,244,144,163,92,109,93,11,95,170,164,225,192,130,103,245,29,210,60,35,141,205,2,255,220,50,8,184,34,161,224,139,53,109,62,56,29,230,48,184,188,75,144,98,174,165,186,53,199,207,201,66,126,92,146,170,58,78,65,21,106,225,164,97,52,198,225,113,81,173,202,98,245,172,60,90,225,219,58,132,165,40,165,68,93,238,125,115,68,196,211,202,13,248,252,182,123,61,161,44,140,216,33,252,156,178,103,125,23,116,152,241,41,79,175,134,36,125,204,206,236,140,196,219,98,82,122,217,129,158,197,180,20,181,7,223,220,251,76,174,149,82,76,72,198,162,173,24,117,78,127,54,54,71,65,97,66,27,209,161,239,100,202,237,21,67,33,3,201,251,197,115,71,97,90,178,3,98,
206,79,170,121,7,70,50,38,237,176,190,112,237,101,188,88,202,12,202,182,170,165,34,75,120,144,116,80,144,197,155,33,217,7,157,76,183,59,104,56,59,23,38,24,20,233,192,79,131,207,137,52,26,134,92,193,129,9,55,29,158,72,78,224,95,231,108,79,161,200,110,240,227,45,98,88,226,195,168,111,185,136,124,40,13,85,212,195,101,97,133,25,127,86,201,44,86,90,182,185,116,179,85,18,177,19,133,142,42,176,230,110,39,152,50,12,138,205,254,157,34,136,86,183,65,48,72,251,23,74,200,133,49,220,104,111,27,201,89,62,151,170,114,160,114,215,16,129,66,159,80,249,201,126,194,15,173,154,17,50,166,160,90,47,247,216,134,121,44,113,37,116,54,55,247,114,22,145,90,192,222,209,2,19,34,46,142,231,100,248,18,21,98,208,250,230,197,227,224,77,45,205,155,86,67,11,79,5,171,160,168,111,178,17,78,69,70,255,205,179,152,241,60,140,185,24,252,67,12,152,218,69,7,238,146,128,5,59,36,201,130,96,250,8,55,49,239,156,208,168,103,215,224,20,213,191,217,36,211,142,216,166,135,253,109,132,89,20,151,174,144,130,2,184,90,172,83,221,94,10,200,40,81,205,48,247,
190,150,174,150,91,152,136,248,139,192,135,166,84,204,209,37,149,155,201,5,191,71,249,101,27,164,121,134,205,41,211,202,19,46,72,72,30,18,6,1,206,111,85,52,231,56,56,134,210,76,47,194,26,159,50,53,148,3,225,131,111,56,174,244,141,165,169,125,107,255,124,251,77,250,205,31,155,36,39,214,190,209,53,72,252,72,122,47,63,166,87,124,84,222,242,55,155,188,193,231,201,167,9,255,37,143,52,110,235,84,5,108,196,158,168,44,100,87,137,40,75,218,48,250,52,196,205,28,12,149,225,133,172,48,191,180,160,192,106,199,122,207,81,161,147,189,118,115,78,202,28,205,44,14,212,12,173,86,73,217,216,216,101,149,241,102,181,183,138,156,102,93,126,177,64,32,92,2,16,4,133,177,224,128,29,38,204,136,105,177,16,24,159,88,188,145,78,173,218,168,220,103,87,228,46,198,49,202,84,17,69,242,203,69,156,68,147,201,93,163,103,173,39,202,156,9,178,39,84,171,25,36,146,63,130,235,65,3,172,169,62,167,53,20,201,98,203,171,32,90,194,184,236,24,40,252,84,40,137,130,228,195,28,204,6,45,77,189,57,254,92,46,155,170,230,91,209,167,77,228,115,82,171,98,36,
212,172,168,130,68,17,174,182,103,5,40,225,193,34,209,235,22,78,144,229,35,45,87,241,2,3,208,226,51,201,21,76,14,80,46,21,31,108,5,137,186,78,150,99,10,211,242,69,48,33,171,177,77,24,50,31,10,227,94,129,201,66,154,134,210,250,5,225,223,66,8,121,152,166,50,176,27,82,179,228,103,169,125,102,241,153,78,176,19,157,212,143,82,122,142,91,17,124,66,115,132,19,126,178,190,195,97,62,211,72,151,4,193,165,183,180,158,225,56,161,72,193,4,116,192,135,165,202,89,3,75,249,177,172,99,156,113,83,235,81,32,234,245,78,247,166,107,62,65,48,234,214,222,189,253,209,147,164,229,214,200,99,11,108,125,72,52,224,195,111,223,117,251,84,40,27,183,191,175,23,87,186,213,49,191,38,223,215,43,203,83,247,29,88,160,172,142,228,133,213,192,11,193,30,29,100,224,31,88,160,10,179,11,138,202,16,246,138,222,216,36,203,124,249,56,76,195,104,33,162,194,205,55,250,167,108,158,233,19,219,72,237,88,205,35,105,24,229,121,144,119,22,163,220,138,127,59,171,75,251,235,8,171,182,236,141,30,195,241,77,165,98,186,209,0,75,129,22,188,189,57,19,53,134,180,
138,93,29,235,39,72,242,38,151,190,152,250,136,225,6,73,105,113,11,15,182,201,224,35,189,162,207,250,122,44,134,103,1,241,50,223,36,190,139,71,28,50,62,108,82,29,80,135,110,120,232,113,81,117,108,158,37,97,5,114,14,93,54,19,77,35,23,139,187,145,204,203,138,77,182,184,148,75,65,50,19,3,158,124,169,125,44,11,175,198,54,235,135,74,187,109,103,235,107,33,20,29,31,232,229,117,21,20,58,195,149,137,192,90,16,146,211,106,160,89,185,83,0,126,169,197,152,237,178,140,80,122,152,11,65,167,136,186,11,24,118,249,224,68,197,48,205,93,47,123,22,231,153,207,217,230,224,25,43,196,200,175,66,185,48,29,166,148,78,100,163,35,234,81,222,11,215,8,105,114,115,0,88,207,229,225,231,8,188,11,93,181,159,155,106,17,42,151,202,103,169,2,75,217,221,104,169,110,54,35,12,135,220,16,66,52,99,138,1,197,240,214,220,90,186,232,212,14,50,222,15,90,209,21,47,107,30,145,42,23,146,110,52,119,45,234,2,216,21,242,44,150,213,212,173,81,142,173,145,125,226,29,67,131,106,91,52,236,231,134,156,183,82,85,199,193,203,49,69,122,91,150,28,96,67,3,152,
217,23,168,22,150,54,154,49,62,21,5,186,204,153,0,89,149,90,52,17,133,82,95,58,141,232,11,143,205,10,7,153,129,231,135,123,139,244,104,175,41,93,188,5,23,33,102,103,228,128,185,111,172,241,165,118,8,84,63,245,129,79,199,94,118,236,64,155,193,86,8,53,136,110,115,171,217,91,24,120,161,106,163,113,21,127,7,172,32,189,96,53,137,47,188,247,73,211,140,144,67,114,77,39,35,74,148,232,39,13,174,93,228,45,219,38,247,51,135,178,54,202,230,149,161,209,26,159,127,181,28,180,85,12,218,10,131,74,142,124,178,207,69,77,235,240,205,183,22,37,172,227,200,254,206,236,200,203,222,215,106,150,61,104,67,196,215,175,130,129,157,2,152,157,5,192,44,152,18,101,103,85,101,6,28,133,125,13,172,29,104,4,130,27,91,7,17,78,239,110,57,156,43,118,61,55,133,72,127,204,96,105,24,250,29,249,20,236,176,116,106,174,174,141,127,172,32,56,252,230,187,147,197,89,97,81,168,88,12,60,153,221,231,138,39,186,216,197,137,226,194,22,244,11,222,10,35,208,184,204,120,212,20,150,14,176,62,124,167,110,35,84,159,97,20,12,185,137,0,183,164,104,29,3,119,197,
158,149,93,111,65,152,37,36,129,217,198,34,175,156,103,127,58,220,139,225,0,48,253,56,109,236,63,142,248,179,196,2,176,154,35,73,12,24,114,43,131,94,1,93,239,2,250,230,76,151,234,4,92,28,84,173,32,201,40,171,170,103,54,11,35,200,57,133,39,236,144,55,88,94,90,107,198,174,178,168,134,222,112,142,217,173,181,122,54,161,3,229,168,32,141,12,197,113,105,188,192,59,105,255,242,109,132,202,14,145,98,132,146,159,166,153,45,247,34,32,212,135,43,254,74,73,9,213,239,224,32,46,125,163,19,67,177,208,64,88,150,49,176,229,135,125,94,16,40,200,37,39,116,27,230,217,79,181,214,246,126,242,78,87,252,97,44,128,108,5,66,107,45,110,104,81,113,71,217,211,107,74,78,90,175,181,184,90,253,236,167,248,109,103,123,215,138,185,157,14,169,6,129,247,94,219,217,62,72,46,139,61,248,243,160,231,249,249,105,242,46,218,233,69,200,171,182,203,208,58,102,127,238,10,141,239,222,221,43,165,164,240,109,71,97,116,175,171,82,219,229,18,166,119,36,18,196,82,218,201,43,59,124,207,239,59,17,94,110,193,24,250,149,5,181,221,214,51,251,118,42,229,21,
186,207,107,187,59,205,248,37,121,109,37,183,137,211,89,74,108,249,166,242,11,241,232,112,41,58,228,17,107,192,27,178,226,80,9,1,1,123,220,242,44,152,127,196,55,36,172,84,219,3,202,11,175,137,164,188,227,143,64,165,96,50,191,31,144,170,84,41,149,126,225,117,10,121,240,140,14,98,249,2,75,144,196,238,244,18,67,181,189,189,93,213,37,28,228,30,28,13,147,12,99,155,83,40,162,3,43,108,128,162,56,46,60,69,202,148,227,75,236,249,155,65,113,166,189,176,206,68,196,90,248,173,38,247,252,105,86,150,205,3,121,84,30,52,147,91,4,6,219,127,120,214,11,78,126,185,197,136,22,227,148,13,25,116,112,128,222,253,241,248,114,35,121,125,124,244,210,122,213,1,41,18,232,116,62,74,42,242,130,6,5,8,188,169,59,51,52,184,54,114,68,98,138,203,233,88,17,17,102,201,76,76,123,226,86,208,224,122,8,154,169,172,187,228,250,77,48,87,205,251,212,22,176,249,138,26,94,117,2,26,169,34,61,212,58,33,244,236,181,181,152,133,138,18,66,189,138,142,196,146,8,0,244,159,93,18,149,24,88,57,21,162,231,34,170,169,31,234,177,11,116,122,128,218,14,154,196,
179,105,114,85,165,11,149,20,93,132,11,98,60,220,230,21,195,228,136,58,229,133,4,12,16,47,204,147,99,92,17,67,154,214,7,8,100,156,40,19,86,113,123,199,108,153,181,18,181,190,172,230,10,98,96,171,117,219,125,139,207,101,130,90,49,136,72,1,178,245,87,75,31,164,103,219,102,34,81,80,47,149,185,109,15,115,5,189,26,128,153,247,175,143,223,156,217,68,143,95,243,129,211,11,209,136,237,193,7,202,253,41,114,245,66,56,210,237,33,124,106,4,67,40,84,9,6,61,18,20,211,156,194,118,94,64,86,177,185,31,58,115,149,44,219,193,207,192,11,39,164,168,176,246,141,107,149,187,210,105,109,158,170,224,41,11,106,27,49,156,254,2,165,163,222,244,166,65,114,157,41,192,34,84,4,204,83,34,244,12,246,26,128,129,159,213,192,166,195,59,181,68,38,86,30,248,172,182,55,91,142,20,46,5,197,55,183,88,238,49,68,37,206,177,116,158,200,13,228,45,74,56,219,174,163,72,155,68,90,50,2,233,95,44,26,69,136,92,133,144,108,143,13,72,171,219,172,55,122,200,164,184,56,118,58,136,61,211,16,8,100,214,146,65,94,12,78,244,30,126,8,81,148,24,39,75,49,68,125,46,
110,226,219,157,166,182,49,67,78,95,154,91,105,106,34,0,34,224,0,175,221,219,161,131,54,212,7,26,195,129,84,118,21,67,160,110,16,43,232,12,38,105,78,162,94,137,21,91,163,198,197,25,144,74,90,247,195,145,132,116,116,214,5,15,42,148,196,50,101,166,80,4,38,137,82,134,166,131,46,158,74,97,15,224,5,121,45,20,66,31,98,65,141,96,252,27,4,138,50,180,198,152,166,193,240,178,211,139,82,186,100,249,153,192,177,68,41,75,46,82,36,79,26,46,222,21,128,105,142,21,238,61,26,132,140,57,224,128,129,16,174,132,104,61,67,36,140,21,33,66,87,49,74,129,78,91,160,112,193,9,43,4,58,109,167,101,173,209,248,78,174,230,15,20,222,82,112,40,210,164,208,214,163,250,124,27,103,1,81,228,167,176,228,9,168,158,62,96,232,48,180,130,252,179,184,212,250,169,250,177,6,11,59,187,72,192,34,8,173,199,118,195,130,81,158,217,174,87,94,225,150,91,62,141,96,226,215,45,125,51,61,160,176,31,120,247,64,111,116,69,44,108,207,40,238,130,5,71,253,201,220,92,43,58,3,163,40,222,134,170,142,129,251,114,24,246,191,148,225,10,125,219,150,56,66,205,237,148,160,
23,61,144,71,225,87,22,38,70,3,10,185,92,119,144,217,14,50,252,112,91,46,52,197,153,211,195,64,192,194,193,111,206,36,111,8,55,242,172,118,122,114,73,24,211,63,83,208,125,116,111,119,95,163,14,184,205,231,57,117,73,255,80,200,58,27,195,172,200,211,90,77,150,132,159,48,150,15,6,21,101,236,139,17,190,160,13,251,7,94,250,142,130,121,152,153,210,30,16,151,140,0,41,6,9,144,43,85,192,20,61,200,119,139,53,243,233,166,200,45,16,205,84,240,18,227,82,101,120,1,149,165,5,171,95,4,241,85,135,68,24,164,163,172,183,16,113,136,143,76,91,201,74,67,3,90,73,30,100,24,217,190,3,221,200,36,24,132,52,61,54,97,233,35,168,107,155,190,201,35,219,112,18,156,36,39,202,198,210,191,153,77,203,54,124,243,91,18,76,228,0,116,161,81,230,138,248,192,242,21,78,77,72,109,65,172,184,180,61,205,84,186,51,40,253,8,93,80,62,208,173,16,106,101,248,84,35,70,147,161,8,26,7,1,0,37,182,21,166,175,73,187,38,167,211,5,13,228,155,83,46,134,17,117,150,85,239,168,185,123,240,154,90,97,168,17,233,178,72,137,231,25,104,46,190,186,82,13,68,155,133,110,
200,222,226,242,113,85,195,35,46,23,3,118,164,140,35,140,113,65,175,126,138,211,145,222,185,146,188,50,147,66,90,13,252,62,152,38,60,127,249,250,56,185,56,123,117,249,243,209,249,49,37,180,147,119,231,103,255,121,242,242,248,101,82,63,186,224,59,187,14,63,159,92,190,62,123,127,153,208,226,252,232,237,229,47,201,217,171,228,232,237,47,201,79,39,111,95,110,80,122,250,221,249,241,197,69,114,118,158,156,156,190,123,115,114,204,111,39,111,95,188,121,255,242,132,16,226,115,222,123,123,6,9,159,64,200,116,122,121,150,104,192,208,213,201,49,239,189,74,78,143,207,95,188,166,231,163,231,39,111,78,46,127,217,72,94,157,92,190,85,159,175,232,244,40,121,119,116,126,121,242,226,253,155,163,243,228,221,251,115,140,169,99,134,127,73,183,111,79,222,190,58,103,148,227,211,227,183,151,155,140,202,111,201,241,127,242,37,185,120,125,244,230,141,13,117,244,30,232,207,13,190,23,103,239,126,57,63,249,241,245,101,242,250,236,205,203,99,126,124,126,12,100,71,207,223,28,251,80,76,234,197,155,163,147,211,141,228,229,209,233,209,143,
130,238,60,57,3,224,115,107,22,160,251,249,245,177,253,196,120,71,252,255,197,229,201,217,91,77,227,197,217,219,203,115,190,82,62,251,236,252,178,120,245,231,147,139,227,141,228,232,252,228,66,8,121,117,126,70,247,66,39,111,8,103,111,245,222,219,99,239,69,168,54,168,139,21,161,137,16,246,158,73,23,176,188,60,62,122,67,95,44,207,219,153,198,210,175,255,15,10,175,186,66);

label
   redo,skipend;
var
   s,d,i:tobject;
   xcount10,p,p2,slen:longint;
   lv,v,lx,x:byte;
   xhelp,xtopiconce,xlist,xcon:boolean;
   xtopics:tdynamicstring;
   n,str1,xstop,xtopic,xsubheading,xunderline,xconsole,xconsoleWRAP:string;
   //## xaddone ##
   procedure xaddone(xval:byte);
   begin
   str__saddb(@d,char(xval));
   end;
   //## xaddstr ##
   procedure xaddstr(xval:string);
   begin
   str__saddb(@d,xval);
   end;
   //## xstopconsole ##
   procedure xstopconsole;
   begin
   if xcon then
      begin
      xcon:=false;
      xaddstr(xstop);//stop multiline console display
      end;
   end;
   //## xstopall ##
   procedure xstopall(_stopconsole:boolean);
   begin
   if _stopconsole then xstopconsole;
   case lx of
   llt,uuT:if xhelp then xaddstr(xstop);
   llh,uuH:xaddstr(xstop);
   llu,uuU:xaddstr(xstop);
   end;
   //reset
   lx:=0;
   end;
   //## xtopicname ##
   function xtopicname(xfrom:longint):string;
   var
      p2:longint;
   begin
   //defaults
   result:='';

   try
   for p2:=xfrom to slen do if (str__bytes1(@s,p2)=10) then
      begin
      result:=str__str1(@s,xfrom,p2-xfrom);
      break;
      end;
   except;end;
   end;
   //## xswaptosquare ##
   procedure xswaptosquare(var x:string;sn:string);
   var
      dn:string;
   begin
   //init
   dn:=sn;
   swapchars(dn,'<','[');
   swapchars(dn,'>',']');
   swapchars(dn,'(','[');
   swapchars(dn,')',']');
   //get
   swapstrs(x,sn,dn);
   end;
   //## xbacktotopics ##
   procedure xbacktotopics;
   begin
   if xtopiconce and xhelp then xaddstr('<a class="navbut" href="#topics">&#9206; Help Topics</a><br>'+#10);
   end;
   //## xclean ##
   procedure xclean;//remove unwanted blank lines and lines with unwanted white space for a consistent look and feel - 30mar2024
   var
      a:tdynamicstring;
      p,p2:longint;
      xcon,xempty,lempty:boolean;
      n3:string;
   begin
   try
   //defaults
   a:=nil;
   //init
   a:=tdynamicstring.create;
   a.text:=str__text(@s);
   str__clear(@s);
   //get
   lempty:=true;
   xcon:=false;
   for p:=0 to (a.count-1) do
   begin
   n3:=strlow(strcopy1b(a.value[p],1,3));
   //.turn console on
   if (not xcon) and ((n3='[k]') or (n3='[j]')) then xcon:=true;
   if xcon then//don't clean within console code [k]...[/] or [j]...[/]
      begin
      str__saddb(@s,a.value[p]+#10);
      lempty:=false;
      end
   else
      begin
      a.value[p]:=stripwhitespace_lt(a.value[p]);
      xempty:=(low__lengthb(a.value[p])<=0);
      if (not xempty) or (not lempty) then str__saddb(@s,a.value[p]+#10);
      lempty:=xempty;
      end;
   //.turn console off
   if xcon then
      begin
      str1:=a.value[p];
      if (str1<>'') then
         begin
         for p2:=1 to low__length(str1) do if (str1[p2-1+stroffset]='[') and (strcopy1(str1,p2,3)='[/]') then
            begin
            xcon:=false;
            break;
            end;//p2
         end;
      end;//xcon
   end;//p
   except;end;
   try;freeobj(@a);except;end;
   end;
   //## xlinkname ##
   function xlinkname(x:string):string;
   begin
   result:=strlow(swapcharsb(io__safefilename(x,false),#32,'-'));
   end;
begin
try
//defaults
s:=nil;
d:=nil;
i:=nil;
xtopics:=nil;
xhelp:=not xclaudehelp;

//init
s:=str__new9;
d:=str__new9;
i:=str__new9;
xtopics:=tdynamicstring.create;
str__addrec(@s,@xhelpdata,sizeof(xhelpdata));
low__decompress(@s);
//.clean
xclean;


case xhelp of
true:begin
   xstop         :='</div>';
   xtopic        :='<div class="help-head">';
   xsubheading   :='<div class="help-subhead">';
   xunderline    :='<div class="help-underline">';
   xconsole      :='<div class="help-console">';
   xconsoleWRAP  :='<div class="help-console-wrap">';
   end;
false:begin
   xstop         :='<chelp-stop>';
   xtopic        :='<chelp-topic>';
   xsubheading   :='<chelp-subhead>';
   xunderline    :='<chelp-underline>';
   xconsole      :='<chelp-console>';
   xconsoleWRAP  :='<chelp-console-wrap>';
   end;
end;//case

//text -> html safe text
if xhelp then str__settextb(@s,net__encodeforhtmlstr(str__text(@s)));

//encode line beginnings ([t]=help topic, [h]=subheading, [u]=underline, [k]=console view
str__saddb(@s,#10);//enforce a trailing return code
slen:=str__len(@s);
lv:=10;
lx:=0;
p:=1;
xlist:=false;
xcon:=false;
xcount10:=0;
xtopiconce:=false;

redo:
v:=str__bytes1(@s,p);

//.list end
if (lv=10) and xlist and (not xcon) and (v<>ssasterisk) then
   begin
   if xhelp then xaddstr('</ul>'+#10);
   xlist:=false;
   end;
//.search for [t]...[k].....[/]
if (lv=10) and (v=ssLSquarebracket) and (str__bytes1(@s,p+2)=ssRSquarebracket) then
   begin
   x:=str__bytes1(@s,p+1);

   //.stop previous modes
   xstopall(true);
   lx:=x;

   //.help topic
   if (x=llt) or (x=uuT) then
      begin
      xbacktotopics;
      str1:=xtopicname(p+3);
      if xhelp then xaddstr('<a name="'+xlinkname(str1)+'">&nbsp;</a>'+xtopic) else xaddstr(xtopic);
      xtopics.value[xtopics.count]:=str1;
      xtopiconce:=true;
      end
   //.subheading
   else if (x=llh) or (x=uuH) then xaddstr(xsubheading)
   //.underline
   else if (x=llu) or (x=uuU) then xaddstr(xunderline)
   //.console (start)
   else if (x=llk) or (x=uuK) then
      begin
      if not xcon then xaddstr(xconsole);//start multiline console display
      xcon:=true;
      end
   //.console-wrap (start)
   else if (x=llj) or (x=uuJ) then
      begin
      if not xcon then xaddstr(xconsoleWRAP);//start multiline console display
      xcon:=true;
      end
   //.end
   else if (x=ssSlash) then xstopall(true)
   //.unknown command
   else
      begin
      //nil
      end;
   //inc
   inc(p,2);
   end
//.insert tag
else if (v=ssLSquarebracket) and strmatch(str__str1(@s,p,8),'[insert:') then
   begin
   for p2:=p to slen do if (ssRSquarebracket=str__bytes1(@s,p2)) then
      begin
      //get
      n:=strlow(str__str1(@s,p+8,p2-p-8));
      //set
      if (n='commandline') then xaddstr(xconsoleWRAP+net__encodeforhtmlstr(xcmdline__output('--help'))+xstop);
      //stop
      p:=p2;
      break;
      end;//p2
   end
//.list start
else if (lv=10) and (v=ssasterisk) and (not xcon) and xhelp then
   begin
   if not xlist then
      begin
      xaddstr('<ul>'+#10);
      xlist:=true;
      end;
   xaddstr('<li>');
   end
else if (lv=10) and (v=ssasterisk) and xcon and xclaudehelp then
   begin
   xaddstr('(chelp-*)');
   end
else if (v=ssLSquarebracket) and (str__bytes1(@s,p+2)=ssRSquarebracket) and (str__bytes1(@s,p+1)=ssSlash) then
   begin
   xstopall(true);
   inc(p,2);
   xcount10:=1;
   end
else if (v=10) then
   begin
   if xcon then
      begin
      xaddstr(#10);
      xcount10:=0;
      end
   else
      begin
      inc(xcount10);
      xstopall(p>=slen);
      if (xcount10<=2) then
         begin
         if xhelp then xaddstr('<br>'+#10) else xaddstr(#10);
         end;
      end;
   end
else
   begin
   xaddone(v);
   xcount10:=0;
   end;
//.loop
lv:=v;
inc(p);
if (p<slen) then goto redo;

//.final topics link
xbacktotopics;


//.build help index
if xhelp then
   begin
   str__saddb(@i,'<a name="topics">&nbsp;</a>'+xtopic+'Help Topics'+xstop+'<br>'+#10);
   str__saddb(@i,'<div class="help-topics">'+#10);
   str__saddb(@i,'<ul>'+#10);
   for p:=0 to (xtopics.count-1) do str__saddb(@i,'<li><a href="#'+xlinkname(xtopics.value[p])+'">'+net__encodeforhtmlstr(xtopics.value[p])+'</a>'+#10);
   str__saddb(@i,'</ul>'+#10);
   str__saddb(@i,'</div>'+#10);

   //set
   result:=str__text(@i)+'<div class="help-body">'+#10+str__text(@d)+'</div>'+#10;
   end
else
//.claude help
   begin
   result:=str__text(@d);
   //we need to step around some of Claude's square bracket commands
   swapstrs(result,'[','(chelp-lsq)');
   swapstrs(result,']','(chelp-rsq)');

   xswaptosquare(result,'(chelp-lsq)');
   xswaptosquare(result,'(chelp-rsq)');
   xswaptosquare(result,'(chelp-*)');

   swapstrs(result,'http://','[chelp-http]');//avoid Claude's auto hyperlink creator by removing the http:// from any text as we want the text as is, not
   swapstrs(result,'https://','[chelp-https]');//as a link, same again for https://
   xswaptosquare(result,xstop);//tells Claude to stop the current style (eg. subheading, underline, console, console-wrap etc)
   swapstrs(result,xtopic,'[t]');//this one Claude knows -> generate help topic
   xswaptosquare(result,xsubheading);
   xswaptosquare(result,xunderline);
   xswaptosquare(result,xconsole);
   xswaptosquare(result,xconsoleWRAP);
   end;

skipend:
except;end;
try
str__free(@s);
str__free(@d);
str__free(@i);
freeobj(@xtopics);
except;end;
end;

//## log__version ##
function log__info(xname:string):string;
begin
//defaults
result:='';
xname:=strlow(xname);

//get
if      (xname='ver')      then result:='1.00.082'
else if (xname='name')     then result:='Bubbles Log Generator'
else
   begin
   //nil
   end;
end;
//## log__makereport ##
procedure log__makereport(var a:pnetwork;slogfilename:string);
label
   skipend;
var
   d:tobject;
   dreportfilename,dmakeref,e:string;
   dlen,lv,p,p2:longint;
   v:string;
begin
try
//defaults
d:=nil;
dreportfilename:=slogfilename+'.html';

//init
d:=str__new9;//log report
dmakeref:=log__info('name')+' v'+log__info('ver')+' / '+low__makeetag2(io__filedateb(slogfilename),'')+' / '+k64(io__filesize64(slogfilename))+' / '+k64(ilogs_report_read_limit)+' / '+k64(ilogs_report_large_limit);

//log is missing
if not io__fileexists(slogfilename) then
   begin
   str__settextb(@d,'Log not found.');
   goto skipend;
   end;

//search first 10K of log report for meta tag "makeref"
if io__fromfile64(dreportfilename,@d,e) then
   begin
   dlen:=str__len(@d);
   for p:=1 to frcmax32(dlen,10000) do if (str__bytes1(@d,p)=sslessthan) and strmatch(str__str1(@d,p,32),'<meta name="generator" content="') then
      begin
      lv:=p+32;
      for p2:=lv to dlen do if (str__bytes1(@d,p2)=ssdoublequote) then
         begin
         v:=str__str1(@d,lv,p2-lv);
         //.log is unchanged -> OK to go ahead and return the current report content
         if strmatch(v,dmakeref) then goto skipend;
         break;
         end;//p2
      break;
      end;//p
   end;

//build new log report
if not log__buildreport(a,d,dmakeref,slogfilename) then
   begin
   str__settextb(@d,'Failed to create log report.');
   goto skipend;
   end;

skipend:
//save the report
io__tofile64(dreportfilename,@d,e);
except;end;
try
str__free(@d);
except;end;
end;
//## log__buildreport ##
function log__buildreport(var a:pnetwork;d:tobject;dmakeref,slogfilename:string):boolean;
label
   makereport,redo;
const
   xread_chunk_size=5000000;//read the log file in 5Mb chunks
var
   s:tobject;
   xstarttime,spos:comp;
   xcount,li,i,lp,p,slen:longint;
   xonce:boolean;
   c:byte;
   xlarge_limit_label,xnav,vip,vdatetime,vmethod,vfilename,vext,vprotocol,vreferrer,vuseragent,vsite:string;
   vcode:longint;
   vtotal_requests,vtotal_hits,vtotal_bandwidth,vtotal_time,vbandwidth,vms:comp;
   vadmin:boolean;
   ivisitors,ireferrers:tdynamicvars;
   chits,cbytes,ctime:tcmplist;//codes
   mhits,mbytes,mtime:tcmplist;mnames:tdynamicvars;//methods
   phits,pbytes,ptime:tcmplist;pnames:tdynamicvars;//protocols
   ehits,ebytes,etime:tcmplist;enames:tdynamicvars;//extensions
   dhits,dbytes,dtime,dhits2,dbytes2,dtime2,dsize:tcmplist;dnames:tdynamicvars;//downloads
   rhits,rbytes,rtime:tcmplist;rnames:tdynamicvars;//referrers
   vhits,vbytes,vtime:tcmplist;vnames:tdynamicvars;//visitors (IP addresses)
   shits,sbytes,stime,s200,s206,s307,s403,s404,sOTH:tcmplist;snames:tdynamicvars;//sites
   isortcmp:tdynamiccomp;
   isorter:tobject;//ptr only
   //## nv ##
   function nv:tdynamicvars;
   begin
   result:=tdynamicvars.create;
   end;
   //## n8 ##
   function n8:tcmplist;
   begin
   result:=tcmplist.create;
   end;
   //## cinc ##
   procedure cinc(s:tcmplist;sindex:longint);
   begin
   if (s<>nil) and (sindex>=0) then s.value[sindex]:=add64(s.value[sindex],1);
   end;
   //## time__addms ##
   function time__addms(xtotaltime,xaddms:comp):comp;
   begin
   result:=add64(xtotaltime,mult64(frcmin64(xaddms,1),low__aorb(1,2,xaddms>=1)));
   end;
   //## time__decode ##
   function time__decode(xtotaltime:comp):comp;
   begin
   result:=div64(xtotaltime,2);
   end;
   //## time__str ##
   function time__str(xtotaltime:comp):string;
   begin
   result:=low__uptime(time__decode(xtotaltime),false,false,true,true,false,' ');
   end;
   //## xadd__cmppair8 ##
   procedure xadd__cmppair8(a,b:tcmplist;xindex:longint;xhits,xbytes:comp);
   begin
   if (xindex>=0) and (a<>nil) and (b<>nil) then
      begin
      if (xhits>=1)  then a.value[xindex]:=a.value[xindex]+xhits;
      if (xbytes>=1) then b.value[xindex]:=add64(b.value[xindex],xbytes);
      end;
   end;
   //## xadd__named__cmppair82 ##
   procedure xadd__named__cmppair82(n:tdynamicvars;a,b:tcmplist;xname:string;xhits,xbytes:comp;var xindex:longint);
   begin
   //defaults
   xindex:=0;

   //get
   if (n<>nil) and (a<>nil) and (b<>nil) then
      begin
      //name filter
      if (xname='') then xname:='(none)';
      //find name or add name
      if not n.find(xname,xindex) then
         begin
         n.s[xname]:='1';
         n.find(xname,xindex);
         end;
      //sync values for name
      if (xindex>=0) then
         begin
         if (xhits>=1)  then a.value[xindex]:=a.value[xindex]+xhits;
         if (xbytes>=1) then b.value[xindex]:=add64(b.value[xindex],xbytes);
         end;
      end;
   end;
   //## xadd__named__cmppair8 ##
   procedure xadd__named__cmppair8(n:tdynamicvars;a,b:tcmplist;xname:string;xhits,xbytes:comp);
   var
      int1:longint;
   begin
   xadd__named__cmppair82(n,a,b,xname,xhits,xbytes,int1);
   end;
   //## cadd ##
   procedure cadd(xcode:longint;xbytes,xtime:comp);
   begin
   xadd__cmppair8(chits,cbytes,xcode,1,xbytes);
   if (xcode>=0) then ctime.value[xcode]:=time__addms(ctime.value[xcode],xtime);
   end;
   //## madd ##
   procedure madd(xmethod:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(mnames,mhits,mbytes,xmethod,1,xbytes,xindex);

   mtime.value[xindex]:=time__addms(mtime.value[xindex],xtime);
   end;
   //## padd ##
   procedure padd(xprotocol:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(pnames,phits,pbytes,xprotocol,1,xbytes,xindex);

   ptime.value[xindex]:=time__addms(ptime.value[xindex],xtime);
   end;
   //## eadd ##
   procedure eadd(xext:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(enames,ehits,ebytes,xext,1,xbytes,xindex);

   etime.value[xindex]:=time__addms(etime.value[xindex],xtime);
   end;
   //## radd ##
   procedure radd(xreferrer:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(rnames,rhits,rbytes,xreferrer,1,xbytes,xindex);

   rtime.value[xindex]:=time__addms(rtime.value[xindex],xtime);
   end;
   //## sadd ##
   procedure sadd(xsite:string;xcode:longint;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(snames,shits,sbytes,xsite,1,xbytes,xindex);

   stime.value[xindex]:=time__addms(stime.value[xindex],xtime);

   case xcode of
   200:cinc(s200,xindex);
   206:cinc(s206,xindex);
   307:cinc(s307,xindex);
   403:cinc(s403,xindex);
   404:cinc(s404,xindex);
   else cinc(sOTH,xindex);
   end;//case
   end;
   //## vadd ##
   procedure vadd(xip:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(vnames,vhits,vbytes,xip,1,xbytes,xindex);

   vtime.value[xindex]:=time__addms(vtime.value[xindex],xtime);
   end;
   //## dadd ##
   procedure dadd(xfilename:string;xcode:longint;xbytes,xtime:comp);
   var
      xindex:longint;
      xsize:comp;
   begin
   //name filter
   if (xfilename='') then xfilename:='(none)';
   //find name or add name
   if not dnames.find(xfilename,xindex) then
      begin
      dnames.s[xfilename]:='1';
      dnames.find(xfilename,xindex);
      dsize.value[xindex]:=xbytes;
      end;
   //get
   xsize:=dsize.value[xindex];
   //.file size has increased -> shift all previous "full downloads" to "partial downloads" and reset the "full downloads to 0 hits and 0 bytes"
   if (xbytes>xsize) then
      begin
      dsize.value[xindex]:=xbytes;
      //shift all previous OK 200 entries to other now
      //.hits
      dhits2.value[xindex]:=add64(dhits.value[xindex],dhits2.value[xindex]);
      dhits.value[xindex]:=0;
      //.bytes
      dbytes2.value[xindex]:=add64(dbytes.value[xindex],dbytes2.value[xindex]);
      dbytes.value[xindex]:=0;
      //.time
      dtime2.value[xindex]:=add64(dtime.value[xindex],dtime2.value[xindex]);
      dtime.value[xindex]:=time__addms(dtime.value[xindex],xtime);
      end
   //.full download (according to our current knowledge of the file's size)
   else if (xbytes=xsize) then
      begin
      dhits.value[xindex]:=add64(dhits.value[xindex],1);
      dbytes.value[xindex]:=add64(dbytes.value[xindex],xbytes);
      dtime.value[xindex]:=time__addms(dtime.value[xindex],xtime);
      end
   //.partial download (either 206 or terminated download)
   else
      begin
      dhits2.value[xindex]:=add64(dhits2.value[xindex],1);
      dbytes2.value[xindex]:=add64(dbytes2.value[xindex],xbytes);
      dtime2.value[xindex]:=time__addms(dtime2.value[xindex],xtime);
      end;
   end;
   //## xnextchunk ##
   function xnextchunk:boolean;
   var
      e:string;
      xfilesize:comp;
      xdate:tdatetime;
      p:longint;
   begin
   //defaults
   result:=false;

   //check -> stop when we reach the upper permitted read limit - 09apr2024
   if (spos>=ilogs_report_read_limit) then exit;

   try
   //get
   if io__fromfile64d(slogfilename,@s,false,e,xfilesize,spos,xread_chunk_size,xdate) then//5 mb chunks
      begin
      //round to end of last full line -> ready for next chunk read
      slen:=str__len(@s);
      if (slen>=1) then
         begin
         for p:=(slen-1) downto 0 do if (str__bytes0(@s,p)=10) then
            begin
            slen:=p+1;
            spos:=add64(spos,slen);
            result:=(slen>=1);
            break;
            end;
         end;
      end;
   except;end;
   end;
   //## inext ##
   procedure inext;
   begin
   li:=i+1;
   inc(xcount);
   end;
   //## ival ##
   function ival:string;
   begin
   result:=str__str0(@s,li,i-li);
   inext;
   end;
   //## imethod_filename_protocol ##
   procedure imethod_filename_protocol;
   var
      v:string;
      vlen,v1,tlen,p,p2:longint;
   begin
   //init
   v:=ival;
   vlen:=low__length(v);
   if (vlen<3) then exit;
   v1:=1;

   //method -> read forward to 1st space
   for p:=1 to vlen do if (v[p-1+stroffset]=#32) then
      begin
      vmethod:=strup(strcopy1(v,1,p-1));
      v1:=p+1;
      break;
      end;//p
   //protocol -> read backward to 1st space
   for p:=vlen downto 1 do if (v[p-1+stroffset]=#32) then
      begin
      vprotocol:=strup(strcopy1(v,p+1,vlen));
      //filename
      vfilename:=strcopy1(v,v1,p-v1);
      vext:=io__readfileext_low(vfilename);
      vsite:=strcopy1(vfilename,2,low__length(vfilename))+'/';
      //done
      break;
      end;//p
   //site
   if (vsite<>'') then
      begin
      tlen:=low__length(vsite);
      for p:=1 to tlen do if (vsite[p-1+stroffset]='/') then
         begin
         //vadmin
         if (p<tlen) then
            begin
            for p2:=(p+1) to tlen do if (vsite[p2-1+stroffset]='/') then
               begin
               if strmatch(strcopy1(vsite,p,p2-p+1),iadminpath) then vadmin:=true;
               break;
               end;//p2
            end;
         //vsite
         vsite:=strcopy1(vsite,1,p-1);
         //stop
         break;
         end;//p
      end;

   //.fallbacks
   if (vmethod='')   then vmethod:='UNKNOWN';
   if (vprotocol='') then vprotocol:='UNKNOWN/?';
   end;
   //## vclear ##
   procedure vclear;
   begin
   vip:='';
   vdatetime:='';
   vmethod:='';
   vfilename:='';
   vext:='';
   vprotocol:='';
   vcode:=0;
   vbandwidth:=0;
   vreferrer:='';
   vuseragent:='';
   vsite:='';
   vms:=0;
   vadmin:=false;
   end;
   //## xadd ##
   procedure xadd(x:string);
   begin
   str__saddb(@d,x+#10);
   end;
   //## xdiv ##
   function xdiv(x:string;xbold:boolean):string;
   begin
   case xbold of
   true:result:='<div class="bold">'+net__encodeforhtmlstr(x)+'</div>';
   false:result:='<div>'+net__encodeforhtmlstr(x)+'</div>';
   end;//case
   end;
   //## xhead2 ##
   procedure xhead2(xtitle,xinfo,xname:string);
   const
      xsep=' &nbsp; ';
   begin
   xadd('<a name="'+xname+'"'+insstr(' style="margin-top:2em"',not xonce)+'></a>'+xnav+'<div class="logheader">'+

   net__encodeforhtmlstr(xtitle)+insstr('<div class="loginfo">'+net__encodeforhtmlstr(xinfo)+'</div>',xinfo<>'')+

   '<div class="logbar">'+
   '&nbsp; <a title="View Summary" href="#u">Summary</a>'+
   xsep+'<a title="View Sites" href="#s">Sites</a>'+
   xsep+'<a title="View Codes" href="#c">Codes</a>'+
   xsep+'<a title="View Methods" href="#m">Methods</a>'+
   xsep+'<a title="View Protocols" href="#o">Protocols</a>'+
   xsep+'<a title="View File Types" href="#f">File Types</a>'+
   xsep+'<a title="View Binary Downloads" href="#b">Binary Downloads</a>'+
   xsep+'<a title="View Visitors" href="#v">Visitors</a>'+
   xsep+'<a title="View Referrers" href="#r">Referrers</a>'+
   xsep+'<a title="View Downloads" href="#d">Downloads</a>'+
   xsep+'<a title="View Partial Downloads" href="#p">Partial Downloads</a>'+
   xsep+'<a title="View raw traffic Log as plain text document (.txt)" href="'+net__encodeurlstr('log--'+io__extractfilename(slogfilename),false)+'">Raw</a>'+
   '</div>'+

   '</div>');


   xonce:=false;
   end;
   //## xhead ##
   procedure xhead(xtitle,xname:string);
   begin
   xhead2(xtitle,'',xname);
   end;
   //## tadd21 ##
   procedure tadd21(v1,v2:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold));
   end;
   //## tadd2 ##
   procedure tadd2(v1,v2:string);
   begin
   tadd21(v1,v2,false);
   end;
   //## tadd31 ##
   procedure tadd31(v1,v2,v3:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold)+xdiv(v3,xbold));
   end;
   //## tadd3 ##
   procedure tadd3(v1,v2,v3:string);
   begin
   tadd31(v1,v2,v3,false);
   end;
   //## tstart3 ##
   procedure tstart3(xclass:string);
   begin
   xadd('<div class="'+strdefb(xclass,'logtable3')+'">');
   end;
   //## tadd41 ##
   procedure tadd41(v1,v2,v3,v4:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold)+xdiv(v3,xbold)+xdiv(v4,xbold));
   end;
   //## tadd4 ##
   procedure tadd4(v1,v2,v3,v4:string);
   begin
   tadd41(v1,v2,v3,v4,false);
   end;
   //## tadd51 ##
   procedure tadd51(v1,v2,v3,v4,v5:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold)+xdiv(v3,xbold)+xdiv(v4,xbold)+xdiv(v5,xbold));
   end;
   //## tadd5 ##
   procedure tadd5(v1,v2,v3,v4,v5:string);
   begin
   tadd51(v1,v2,v3,v4,v5,false);
   end;
   //## tadd101 ##
   procedure tadd101(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10:string;xbold:boolean);
   begin
   xadd(
    xdiv(v1,xbold)+
    xdiv(v2,xbold)+
    xdiv(v3,xbold)+
    xdiv(v4,xbold)+
    xdiv(v5,xbold)+
    xdiv(v6,xbold)+
    xdiv(v7,xbold)+
    xdiv(v8,xbold)+
    xdiv(v9,xbold)+
    xdiv(v10,xbold)
   );
   end;
   //## tadd10 ##
   procedure tadd10(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10:string);
   begin
   tadd101(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,false);
   end;
   //## tend ##
   procedure tend;
   begin
   xadd('</div>');
   end;
   //## xbinaryext ##
   function xbinaryext(xfilename:string):boolean;
   var
      v:string;
   begin
   v:=io__readfileext_low(xfilename);
   result:=(v='exe') or (v='zip') or (v='7z') or (v='apk');
   end;
   //## xsortcmp ##
   procedure xsortcmp(x:tcmplist);
   var
      p:longint;
   begin
   //init
   if (isortcmp=nil) then isortcmp:=tdynamiccomp.create;
   isortcmp.clear;
   //fill
   for p:=0 to (x.count-1) do isortcmp.value[p]:=x.value[p];
   isortcmp.sort(false);//largest first
   isorter:=isortcmp;
   end;
   //## xsortindex ##
   function xsortindex(s:longint;var d:longint):boolean;
   begin
   result:=true;//pass-thru
   if (isorter<>nil) and (isorter is tdynamiccomp) then d:=(isorter as tdynamiccomp).sindex(s) else d:=s;
   end;
begin
//defaults
result:=false;
s:=nil;
xonce:=true;
isortcmp:=nil;
isorter:=nil;

//check
if not str__ok(@d) then exit;

try
//init
xlarge_limit_label:=k64(div64(ilogs_report_large_limit,1000))+' K';
xstarttime:=ms64;
str__clear(@d);
s:=str__new9;
vtotal_hits:=0;
vtotal_requests:=0;
vtotal_bandwidth:=0;
vtotal_time:=0;
//.totals
ivisitors:=nv;
ireferrers:=nv;
//.codes
chits    :=n8;
cbytes   :=n8;
ctime    :=n8;
//.methods
mnames   :=nv;
mhits    :=n8;
mbytes   :=n8;
mtime    :=n8;
//.protocols
pnames   :=nv;
phits    :=n8;
pbytes   :=n8;
ptime    :=n8;
//.extensions
enames   :=nv;
ehits    :=n8;
ebytes   :=n8;
etime    :=n8;
//.downloads
dnames   :=nv;
dhits    :=n8;//ok downloads
dbytes   :=n8;
dtime    :=n8;
dhits2   :=n8;//partial or failed downloads
dbytes2  :=n8;
dtime2   :=n8;
dsize    :=n8;//actual size of file (calculated by using the largest downloaded size found in log)
//.referrers
rnames   :=nv;
rhits    :=n8;
rbytes   :=n8;
rtime    :=n8;
//.visitors
vnames   :=nv;
vhits    :=n8;
vbytes   :=n8;
vtime    :=n8;
//.sites
snames   :=nv;
shits    :=n8;
sbytes   :=n8;
stime    :=n8;
s200     :=n8;
s206     :=n8;
s307     :=n8;
s403     :=n8;
s404     :=n8;
sOTH     :=n8;
//get - scane the log one line at a time, one chunk at a time, counting the variables for the report maker
spos:=0;//position within log file
slen:=0;//length of buffer s
p:=0;//position within buffer s
lp:=0;

//.no data
if not xnextchunk then goto makereport;

redo:

//.end of line
if (str__bytes0(@s,p)=10) then
   begin
   //.clear
   vclear;

   //.split line into parts
   xcount:=0;
   li:=lp;
   for i:=lp to p do
   begin
   c:=str__bytes0(@s,i);
   case xcount of
   0:if (c=ssspace)           then vip:=ival;
   1:if (c=ssLsquarebracket)  then inext;
   2:if (c=ssRsquarebracket)  then vdatetime:=ival;
   3:if (c=ssdoublequote)     then inext;
   4:if (c=ssdoublequote)     then imethod_filename_protocol;
   5:if (c=ssspace)           then inext;
   6:if (c=ssspace)           then vcode:=strint(ival);
   7:if (c=ssspace)           then vbandwidth:=strint64(ival);
   8:if (c=ssdoublequote)     then inext;
   9:if (c=ssdoublequote)     then vreferrer:=ival;
   10:if (c=ssdoublequote)    then inext;
   11:if (c=ssdoublequote)    then vuseragent:=ival;
   12:if (c=ssLsquarebracket) then inext;
   13:if (c=ssspace)          then
      begin
      vms:=strint64(ival);
      vtotal_time:=time__addms(vtotal_time,vms);
      break;
      end;
   end;//case
   end;//i

   //.increment counters
   cadd(vcode,vbandwidth,vms);//codes
   padd(vprotocol,vbandwidth,vms);//protocols
   madd(vmethod,vbandwidth,vms);//methods
   eadd(vext,vbandwidth,vms);
   dadd(vfilename,vcode,vbandwidth,vms);
   radd(vreferrer,vbandwidth,vms);
   vadd(vip,vbandwidth,vms);
   if not strmatch(strcopy1(vprotocol,1,5),'SMTP/') then sadd(vsite,vcode,vbandwidth,vms);
   //.totals
   if (not vadmin) and hits__extcounts(vext) then vtotal_hits:=add64(vtotal_hits,1);//hits for HTML and HTM docs and NOT admin session docs
   vtotal_requests:=add64(vtotal_requests,1);
   vtotal_bandwidth:=add64(vtotal_bandwidth,vbandwidth);
   ivisitors.s[vip]:='1';
   ireferrers.s[vreferrer]:='1';
   //.reset
   lp:=p+1;
   end;

//.loop
inc(p);
if (p<slen) then goto redo
else if xnextchunk then
   begin
   p:=0;
   lp:=0;
   goto redo;
   end;

makereport:

//init
xstarttime:=ms64-xstarttime;

//start html
xadd(xhtmlstart4(a,'<meta name="generator" content="'+dmakeref+'">'+#10,'',false,true,true));

//report html
xhead('Summary','u');
tstart3('logtable2ll');
tadd21('Type','Value',true);
tadd2('Total Hits',k64(vtotal_hits));
tadd2('Total Requests',k64(vtotal_requests));
tadd2('Total Bandwidth',low__mbPLUS(vtotal_bandwidth,true));
tadd2('Total Time',time__str(vtotal_time));
tadd2('Unique Visitors',k64(ivisitors.count));
tadd2('Unique Referrers',k64(ireferrers.count));
tadd2('Log Size',low__mbPLUS(io__filesize64(slogfilename),true));
tadd2('Log Limit',low__mbPLUS(ilogs_report_read_limit,true));
tadd2('Log Version',log__info('ver'));
tadd2('Compilation Time',low__uptime(xstarttime,false,false,true,true,true,' '));
tadd2('Compilation Date',low__datestr(now,1,true));
tend;

xhead('Sites','s');
tstart3('logtable10rl');
tadd101('Requests','Bandwidth','Time','200','206','307','403','404','Other','Site',true);
for p:=0 to (shits.count-1) do if (shits.value[p]>=1) then tadd10(
 k64(shits.value[p]),
 low__mbPLUS(sbytes.value[p],true),
 time__str(stime.value[p]),
 k64(s200.value[p]),
 k64(s206.value[p]),
 k64(s307.value[p]),
 k64(s403.value[p]),
 k64(s404.value[p]),
 k64(sOTH.value[p]),
 snames.n[p]);
tend;

xhead('Codes','c');
tstart3('logtable5rl');
tadd51('Codes','Requests','Bandwidth','Time','Description',true);
xsortcmp(ctime);
for i:=0 to (chits.count-1) do if xsortindex(i,p) and (chits.value[p]>=1) then tadd5(k64(p),k64(chits.value[p]),low__mbPLUS(cbytes.value[p],true),time__str(ctime.value[p]),xcodedes(p));
tend;

xhead('Methods','m');
tstart3('logtable4rr');
tadd41('Type','Requests','Bandwidth','Time',true);
xsortcmp(mtime);
for i:=0 to (mhits.count-1) do if xsortindex(i,p) and (mhits.value[p]>=1) then tadd4(mnames.n[p],k64(mhits.value[p]),low__mbPLUS(mbytes.value[p],true),time__str(mtime.value[p]));
tend;

xhead('Protocols','o');
tstart3('logtable4rr');
tadd41('Type','Requests','Bandwidth','Time',true);
xsortcmp(ptime);
for i:=0 to (phits.count-1) do if xsortindex(i,p) and (phits.value[p]>=1) then tadd4(pnames.n[p],k64(phits.value[p]),low__mbPLUS(pbytes.value[p],true),time__str(ptime.value[p]));
tend;

xhead('File Types','f');
tstart3('logtable4rr');
tadd41('Type','Requests','Bandwidth','Time',true);
xsortcmp(etime);
for i:=0 to (ehits.count-1) do if xsortindex(i,p) and (ehits.value[p]>=1) then tadd4(enames.n[p],k64(ehits.value[p]),low__mbPLUS(ebytes.value[p],true),time__str(etime.value[p]));
tend;

xhead('Binary Downloads','b');
tstart3('logtable4rl');
tadd41('Requests','Bandwidth','Time','Url',true);
xsortcmp(dtime);
for i:=0 to (dhits.count-1) do if xsortindex(i,p) and (dhits.value[p]>=1) and xbinaryext(dnames.n[p]) then tadd4(k64(dhits.value[p]),low__mbPLUS(dbytes.value[p],true),time__str(dtime.value[p]),dnames.n[p]);
tend;

xhead2('Visitors',xlarge_limit_label,'v');
tstart3('logtable4rl');
tadd41('Requests','Bandwidth','Time','Client IP Address',true);
xsortcmp(vtime);
for i:=0 to frcmax32((vhits.count-1),ilogs_report_large_limit) do if xsortindex(i,p) and (vhits.value[p]>=1) then tadd4(k64(vhits.value[p]),low__mbPLUS(vbytes.value[p],true),time__str(vtime.value[p]),vnames.n[p]);
tend;

xhead2('Referrers',xlarge_limit_label,'r');
tstart3('logtable4rl');
tadd41('Requests','Bandwidth','Time','Url',true);
xsortcmp(rtime);
for i:=0 to frcmax32((rhits.count-1),ilogs_report_large_limit) do if xsortindex(i,p) and (rhits.value[p]>=1) then tadd4(k64(rhits.value[p]),low__mbPLUS(rbytes.value[p],true),time__str(rtime.value[p]),rnames.n[p]);
tend;

xhead('Downloads','d');
tstart3('logtable4rl');
tadd41('Requests','Bandwidth','Time','Url',true);
xsortcmp(dtime);
for i:=0 to (dhits.count-1) do if xsortindex(i,p) and (dhits.value[p]>=1) then tadd4(k64(dhits.value[p]),low__mbPLUS(dbytes.value[p],true),time__str(dtime.value[p]),dnames.n[p]);
tend;

xhead('Partial / Incomplete Downloads','p');
tstart3('logtable4rl');
tadd41('Requests','Bandwidth','Time','Url',true);
xsortcmp(dtime2);
for i:=0 to (dhits.count-1) do if xsortindex(i,p) and (dhits2.value[p]>=1) then tadd4(k64(dhits2.value[p]),low__mbPLUS(dbytes2.value[p],true),time__str(dtime2.value[p]),dnames.n[p]);
tend;


//end html
xadd(xhtmlfinish2(true));

//successful
result:=true;
except;end;
try
//.s
str__free(@s);
//.totals
freeobj(@ivisitors);
freeobj(@ireferrers);
//.codes
freeobj(@chits);
freeobj(@cbytes);
freeobj(@ctime);
//.methods
freeobj(@mnames);
freeobj(@mhits);
freeobj(@mbytes);
freeobj(@mtime);
//.protocols
freeobj(@pnames);
freeobj(@phits);
freeobj(@pbytes);
freeobj(@ptime);
//.extensions
freeobj(@enames);
freeobj(@ehits);
freeobj(@ebytes);
freeobj(@etime);
//.downloads
freeobj(@dnames);
freeobj(@dhits);
freeobj(@dbytes);
freeobj(@dtime);
freeobj(@dhits2);
freeobj(@dbytes2);
freeobj(@dtime2);
freeobj(@dsize);
//.referrers
freeobj(@rnames);
freeobj(@rhits);
freeobj(@rbytes);
freeobj(@rtime);
//.visitors
freeobj(@vnames);
freeobj(@vhits);
freeobj(@vbytes);
freeobj(@vtime);
//.sites
freeobj(@snames);
freeobj(@shits);
freeobj(@sbytes);
freeobj(@stime);
freeobj(@s200);
freeobj(@s206);
freeobj(@s307);
freeobj(@s403);
freeobj(@s404);
freeobj(@sOTH);
//.other
freeobj(@isortcmp);
except;end;
end;


end.
