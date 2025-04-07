unit gossio;

interface

uses
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3} sysutils, filectrl, gossroot, gosswin; {$endif}
{$ifdef laz} sysutils, gossroot, gosswin; {$endif}
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
//## Library.................. File IO - Disk, folder and file support (gossio.pas)
//## Version.................. 4.00.3962
//## Items.................... 3
//## Last Updated ............ 30apr2024
//## Lines of Code............ 3,400+
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
//## | filecache__*           | family of procs   | 1.00.152  | 29apr2024   | Cache open file handles for faster repeat file IO operations, 12apr2024: created
//## | io__*                  | family of procs   | 1.00.3510 | 30apr2024   | Disk, folder and file procs + 64bit file support, 30apr2024: io__tofileex64() updated to flush buffer for correct nav__* filesize reporting, 17apr2024: procs renamed
//## | nav__*                 | family of procs   | 1.00.300  | 26feb2024   | Worker procs for file/folder/navigation lists
//## ==========================================================================================================================================================================================================================

type
   //.tfilecache
   pfilecache=^tfilecache;
   tfilecache=record
    init:boolean;
    //.time + used
    time_created:comp;//time this record was created
    time_idle:comp;//used for idle timeout detection
    //.name
    filenameREF:comp;
    filename:string;
    opencount:longint;
    usecount:longint;//increments each time the record is reused -> procs can detect if their record has been reused and abort
    //.handle to file
    filehandle:thandle;
    //.access
    read:boolean;
    write:boolean;
    //.info
    slot:longint;
    end;

var
   //.started
   system_started               :boolean=false;
   //.filecache
   system_filecache_limit       :longint=20;//0..20=file caching is off, 21..200=file caching is on - 29apr2024
   system_filecache_timer       :comp=0;
   system_filecache_slot        :array[0..199] of tfilecache;
   system_filecache_filecount   :comp=0;//count actual file opens
   system_filecache_count       :longint=0;//last slot open+1
   system_filecache_active      :longint=0;//exact number of slots open

//start-stop procs -------------------------------------------------------------
procedure gossio__start;
procedure gossio__stop;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__io(xname:string):string;//information specific to this unit of code

//win32 folder procs -----------------------------------------------------------
function io__findfolder(x:longint;var y:string):boolean;//17jan2007
function io__appdata:string;//out of date
function io__windrive:string;//14DEC2010
function io__winroot:string;//11DEC2010
function io__winsystem:string;//11DEC2010
function io__wintemp:string;//11DEC2010
function io__windesktop:string;//17MAY2013
function io__winstartup:string;
function io__winprograms:string;//start button > programs > - 11NOV2010
function io__winstartmenu:string;

//disk, folder and file procs --------------------------------------------------
procedure io__createlink(df,sf,dswitches,iconfilename:string);//10apr2019, 14NOV2010
function io__exename:string;
function io__ownname:string;
function io__dates__filedatetime(x:tfiletime):tdatetime;
function io__dates__fileage(x:thandle):tdatetime;
function io__lastext(x:string):string;//returns last extension - 03mar2021
function io__lastext2(x:string;xifnodotusex:boolean):string;//returns last extension - 03mar2021
function io__remlastext(x:string):string;//remove last extension
function io__readfileext(x:string;fu:boolean):string;{Date: 24-DEC-2004, Superceeds "ExtractFileExt"}
function io__readfileext_low(x:string):string;//30jan2022
function io__scandownto(x:string;y,stopA,stopB:char;var a,b:string):boolean;
function io__faISfolder(x:longint):boolean;//05JUN2013
function io__safename(x:string):string;//07mar2021, 08mar2016
function io__safefilename(x:string;allowpath:boolean):string;//07mar2021, 08mar2016
function io__issafefilename(x:string):boolean;//07mar2021, 10APR2010
function io__hack_dangerous_filepath_allow_mask(x:string):boolean;
function io__hack_dangerous_filepath_deny_mask(x:string):boolean;
function io__hack_dangerous_filepath(x:string;xstrict_no_mask:boolean):boolean;
function io__makeportablefilename(filename:string):string;//11sep2021, 06oct2020, 14APR2011
function io__readportablefilename(filename:string):string;//11sep2021
function io__extractfileext(x:string):string;//12apr2021
function io__extractfileext2(x,xdefext:string;xuppercase:boolean):string;//12apr2021
function io__extractfileext3(x,xdefext:string):string;//lowercase version - 15feb2022
function io__extractfilepath(x:string):string;//04apr2021
function io__extractfilename(x:string):string;//05apr2021
function io__renamefile(s,d:string):boolean;//local only, soft check - 27nov2016
function io__shortfile(xlongfilename:string):string;//translate long filenames to short filename, using MS api, for "MCI playback of filenames with 125+c" - 23FEB2008
function io__asfolder(x:string):string;//enforces trailing "\"
function io__asfolderNIL(x:string):string;//enforces trailing "\" AND permits NIL - 03apr2021, 10mar2014
function io__folderaslabel(x:string):string;
function io__isfile(x:string):boolean;
function io__local(x:string):boolean;
function io__canshowfolder(x:string):boolean;
function io__driveexists(x:string):boolean;//true=drive has content - 17may2021, 16feb2016, 25feb2015, 17AUG2010
function io__drivetype(x:string):string;//15apr2021, 05apr2021
function io__drivelabel(x:string;xfancy:boolean):string;//17may2021, 05apr2021
function io__fileexists(x:string):boolean;//04apr2021, 15mar2020, 19may2019
function io__filesize64(x:string):comp;//24dec2023
function io__filedateb(x:string):tdatetime;//27jan2022
function io__filedate(x:string;var xdate:tdatetime):boolean;//24dec2023, 27jan2022
function io__remfile(x:string):boolean;
procedure io__filesetattr(x:string;xval:longint);
function io__copyfile(sf,df:string;var e:string):boolean;
function io__backupfilename(dname:string):string;//12feb2023
function io__tofilestr(x,xdata:string;var e:string):boolean;//fast and basic low-level
function io__tofile(x:string;xdata:pobject;var e:string):boolean;//27sep2022, fast and basic low-level
function io__tofile64(x:string;xdata:pobject;var e:string):boolean;//27sep2022, fast and basic low-level
function io__tofileex64(x:string;xdata:pobject;xfrom:comp;xreplace:boolean;var e:string):boolean;//30apr2024: flush file buffers for correct "nav__*" filesize info, 06feb2024, 22jan2024, 27sep2022, fast and basic low-level
function io__exemarker(x:tstr8):boolean;//14nov2023
function io__exereadFROMFILE(xfilename:string;xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8;var e:string):boolean;//14nov2023
function io__exeread(s,xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8):boolean;//14nov2023
function io__exewriteTOFILE(xfilename:string;xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8;var e:string):boolean;//14nov2023
function io__exewrite(d,xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8):boolean;//14nov2023
function io__fromfile(x:string;xdata:pobject;var e:string):boolean;
function io__fromfile64(x:string;xdata:pobject;var e:string):boolean;
function io__fromfile641(x:string;xdata:pobject;xappend:boolean;var e:string):boolean;//04feb2024
function io__fromfile64b(x:string;xdata:pobject;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//24dec2023, 20oct2006
function io__fromfile64c(x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//06feb2024, 24dec2023, 20oct2006
function io__fromfile64d(x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize:comp;_from:comp;_size:comp;var _date:tdatetime):boolean;//06feb2024, 24dec2023, 20oct2006
function io__fromfilestrb(x:string;var e:string):string;//30mar2022
function io__fromfilestr(x:string;var xdata,e:string):boolean;
function io__drivelist:tdrivelist;
function io__fromfiletime(x:tfiletime):tdatetime;
function io__folderexists(x:string):boolean;//15mar2020, 14dec2016
function io__deletefolder(x:string):boolean;//13feb2024
function io__makefolder(x:string):boolean;//15mar2020, 19may2019
function io__makefolder2(x:string):string;//29feb2024
//.simple file list support - 31dec2023, 06oct2022
function io__filelist(xoutlist:tdynamicstring;xfullfilenames:boolean;xfolder,xmasklist,xemasklist:string):boolean;//06oct2022
function io__filelist2(xoutlist:tdynamicstring;xfullfilenames:boolean;xfolder,xmasklist,xemasklist:string;xtotalsizelimit,xminsize,xmaxsize:comp;xminmax_emasklist:string):boolean;//31dec2023, 06oct2022
function io__filelist3(xfolder,xmasklist,xemasklist:string;xfiles,xfolders,xsubfolders:boolean;xevent:tsearchrecevent;xevent2:tsearchrecevent2;xhelper:tobject):boolean;//31dec2023

//filecache procs --------------------------------------------------------------
//caches open file handles (not file content)
//.init
function filecache__recok(x:pfilecache):boolean;
procedure filecache__initrec(x:pfilecache;xslot:longint);//used internally by system
function filecache__idletime:comp;
function filecache__enabled:boolean;
function filecache__limit:longint;
function filecache__safefilename(x:string):boolean;
//.find
function filecache__find(x:string;xread,xwrite:boolean;var xslot:longint):boolean;//13apr2024: updated
function filecache__newslot:longint;
procedure filecache__inc_usecount(x:pfilecache);
//.close
procedure filecache__closeall;
procedure filecache__closeall_rightnow;
procedure filecache__closerec(x:pfilecache);
procedure filecache__closefile(var x:pfilecache);
procedure filecache__closeall_byname_rightnow(x:string);
function filecache__remfile(x:string):boolean;
//.open
function filecache__openfile_anyORread(x:string;var v:pfilecache;var vmustclose:boolean;var e:string):boolean;//for info purposes such as filesize and filedate, not for reading/writing file content
function filecache__openfile_read(x:string;var v:pfilecache;var e:string):boolean;
function filecache__openfile_write(x:string;var v:pfilecache;var e:string):boolean;
function filecache__openfile_write2(x:string;xremfile_first:boolean;var xfilecreated:boolean;var v:pfilecache;var e:string):boolean;
//.management
procedure filecache__managementevent;


//nav procs (file list support) ------------------------------------------------
//note: builds a filelist with support for (a) nav list, (b) folders, (c) files, (d) fav folders etc - used by open/save/folder windows and low level file listing procs
//note: normal sequence: init() + add()/add()/add() + end() -> packs a 4 way sorted (name,size,date,type) nav/folder/file list(s) into a single compact data structure with rapid data access via low__navget - 25sep2020
//version: 1.00.250 / date: 06apr2021, 20feb2021, 25sep2020
function nav__init(x:tstr8):boolean;
function nav__add(x:tstr8;xstyle,xtep:longint;xsize:comp;xname,xlabel:string):boolean;
function nav__add2(x:tstr8;xstyle,xtep:longint;xsize:comp;xyear,xmonth,xday,xhr,xmin,xsec:longint;xname,xlabel:string):boolean;
function nav__sort(x:tstr8;xsortstyle:longint):boolean;
function nav__end(x:tstr8;xsortstyle:longint):boolean;
function nav__count(x:tstr8):longint;//28dec2023
function nav__info(x:tstr8;var xnavcount,xfoldercount,xfilecount,xtotalcount:longint):boolean;
function nav__get(x:tstr8;xindex:longint;var xstyle,xtep:longint;var xsize:comp;var xname,xlabel:string):boolean;
function nav__get2(x:tstr8;xindex:longint;var xstyle,xtep:longint;var xsize:comp;var xyear,xmonth,xday,xhr,xmin,xsec:longint;var xname,xlabel:string):boolean;
function nav__date(sdate:comp;var xyear,xmonth,xday,xhr,xmin,xsec:longint):boolean;//01feb2024
function nav__list(x:tstr8;xsortstyle:longint;xfolder,xmasklist,xemasklist:string;xnav,xfolders,xfiles:boolean):boolean;//04oct2020
function nav__list2(xownerid:longint;x:tstr8;xsortstyle:longint;xfolder,xmasklist,xemasklist:string;xnav,xfolders,xfiles:boolean):boolean;//supports custom folder images when "xownerid>=1" - 06apr2021, 04oct2020
function nav__list3(xownerid:longint;x:tstr8;xsortstyle:longint;xfolder,xmasklist,xemasklist:string;xnav,xfolders,xfiles:boolean;xminsize,xmaxsize:comp;xminmax_emasklist:string):boolean;//26feb2024: Upgraded 32bit filesize to 64bit, 04oct2020
function nav__proc(x:tstr8;xcmd:string;xindex:longint;var xstyle,xtep,xval1,xval2,xval3:longint;var xsize,xdate:comp;var xname,xlabel:string):boolean;//04apr2021, 25mar2021, 20feb2021


implementation


//start-stop procs -------------------------------------------------------------
procedure gossio__start;
var
   p:longint;
begin
try
//check
if system_started then exit else system_started:=true;

//filecache support
for p:=0 to (system_filecache_limit-1) do filecache__initrec(@system_filecache_slot[p],p);

except;end;
end;

procedure gossio__stop;
begin
try
//check
if not system_started then exit else system_started:=false;

//filecache - closeall open file handles - 13apr2024
filecache__closeall_rightnow;

except;end;
end;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__io(xname:string):string;//information specific to this unit of code
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//check -> xname must be "gossio.*"
if (strcopy1(xname,1,7)='gossio.') then strdel1(xname,1,7) else exit;

//get
if      (xname='ver')        then result:='4.00.3962'
else if (xname='date')       then result:='30apr2024'
else if (xname='name')       then result:='IO'
else
   begin
   //nil
   end;

except;end;
end;

//io procs ---------------------------------------------------------------------
function io__findfolder(x:longint;var y:string):boolean;//17jan2007
var
   i:imalloc;
   a:pitemidlist;
   b:pchar;
   tmpfolder:string;
begin
//defaults
result:=false;

try
y:='';
a:=nil;
//process
if (win____SHGetMalloc(i)=NOERROR) then
   begin
   if (win____shgetspecialfolderlocation(0,x,a)=0) then
      begin
      //.size
      b:=pchar(makestrb(max_path,0));
      //.get
      if win____shgetpathfromidlist(a,b) then
         begin
         y:=io__asfolder(string(b));
         result:=(length(y)>=3);
         end;//end of if
      end;//end of if
   end;//end of if
except;end;
try;if (a<>nil) then i.free(a);except;end;
try
//-- Linux and robust Windows Support --
//Note: return a path regardless whether we are Windows or Linux, and wether it's supported
//      or not.
if not result then
   begin
   //fallback to "c:\windows\temp\"
   tmpfolder:=io__wintemp;
   if (tmpfolder='') then tmpfolder:='C:\WINDOWS\TEMP\';
   y:='';
   //get
   case x of
   CSIDL_DESKTOP:                y:=tmpfolder;
   CSIDL_COMMON_DESKTOPDIRECTORY:y:=tmpfolder;
   CSIDL_FAVORITES:              y:=tmpfolder;
   CSIDL_STARTMENU:              y:=tmpfolder;
   CSIDL_COMMON_STARTMENU:       y:=tmpfolder;
   CSIDL_PROGRAMS:               y:=tmpfolder;
   CSIDL_COMMON_PROGRAMS:        y:=tmpfolder;
   CSIDL_STARTUP:                y:=tmpfolder;
   CSIDL_COMMON_STARTUP:         y:=tmpfolder;
   CSIDL_RECENT:                 y:=tmpfolder;
   CSIDL_FONTS:                  y:=tmpfolder;
   CSIDL_APPDATA:                y:=tmpfolder;
   end;//end of case
   //set
   result:=(length(y)>=3);
   end;//end of if
except;end;
end;

function io__appdata:string;//out of date
begin
result:='';try;io__findfolder(CSIDL_APPDATA,result);except;end;
end;

function io__windrive:string;//14DEC2010
begin
result:='';try;result:=strcopy1b(io__winroot,1,3);except;end;
end;

function io__winroot:string;//11dec2010
var
  a:pchar;
begin
result:='';

try
//process
//.size
a:=pchar(makestrb(max_path,0));
//.get
win____getwindowsdirectorya(a,MAX_PATH);
result:=io__asfolder(string(a));
except;end;
try;if (length(result)<3) then result:='C:\WINDOWS\';except;end;
end;

function io__winsystem:string;//11DEC2010
var
  a:pchar;
begin
result:='';

try
//process
//.size
a:=pchar(makestrb(max_path,0));
//.get
win____getsystemdirectorya(a,MAX_PATH);
result:=io__asfolder(string(a));
except;end;
try;if (length(result)<3) then result:=io__winroot+'SYSTEM32\';except;end;
end;

function io__wintemp:string;//11DEC2010
var
  a:pchar;
begin
//defaults
result:='';

try
//size
a:=pchar(makestrb(max_path,0));
//get
win____gettemppatha(max_path,a);
//set
result:=io__asfolder(string(a));
except;end;
try
//range
if (length(result)<3) then result:='C:\WINDOWS\TEMP\';//11DEC2010
io__makefolder(result);
except;end;
end;

function io__windesktop:string;//17MAY2013
begin
result:='';try;io__findfolder(csidl_desktop,result);except;end;
end;

function io__winstartup:string;
begin
result:='';try;io__findfolder(CSIDL_STARTUP,result);except;end;
end;

function io__winprograms:string;//start button > programs > - 11NOV2010
begin
result:='';try;io__findfolder(CSIDL_PROGRAMS,result);except;end;
end;

function io__winstartmenu:string;
begin
result:='';try;io__findfolder(CSIDL_STARTMENU,result);except;end;
end;

function io__fileexists(x:string):boolean;//04apr2021, 15mar2020, 19may2019
begin//soft check via low__driveexists
result:=false;try;result:=(x<>'') and io__local(x) and io__driveexists(x) and fileexists(x);except;end;
end;

function io__filesize64(x:string):comp;//24dec2023
var
   v:pfilecache;
   vmustclose:boolean;
   c:tcmp8;
   e:string;
begin
//defaults
result:=-1;//file not found
//get
if filecache__openfile_anyORread(x,v,vmustclose,e) then
   begin
   try
   c.ints[0]:=win____getfilesize(v.filehandle,@c.ints[1]);
   result:=c.val;
   except;end;
   if vmustclose then filecache__closefile(v);
   end;
end;

function io__filedateb(x:string):tdatetime;//27jan2022
begin
io__filedate(x,result);
end;

function io__filedate(x:string;var xdate:tdatetime):boolean;//24dec2023, 27jan2022
var
   v:pfilecache;
   vmustclose:boolean;
   b:tbyhandlefileinformation;
   e:string;
begin
//defaults
result:=false;
xdate:=0;
//get
if filecache__openfile_anyORread(x,v,vmustclose,e) then
   begin
   try
   if win____getfileinformationbyhandle(v.filehandle,b) then
      begin
      xdate:=io__fromfiletime(b.ftLastWriteTime);
      result:=true;//ok
      end;
   except;end;
   if vmustclose then filecache__closefile(v);
   end;
end;

function io__remfile(x:string):boolean;
begin
result:=filecache__remfile(x);
end;

procedure io__filesetattr(x:string;xval:longint);
begin
try
{$ifdef d3laz}
filesetattr(x,xval);
{$endif}

{$ifdef D10}
//D10: No support yet
{$endif}
except;end;
end;

function io__copyfile(sf,df:string;var e:string):boolean;
label//Warning: Only good for SMALL files - 29aug2021
   skipend;
var
   xdata:tobject;
begin
//defaults
result:=false;

try
xdata:=nil;
e:=gecTaskfailed;
//check
if strmatch(sf,df) then
   begin
   result:=true;
   goto skipend;
   end;
//check
if not io__fileexists(sf) then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;
//get
xdata:=str__new9;
if not io__fromfile(sf,@xdata,e) then goto skipend;
if not io__tofile(df,@xdata,e) then goto skipend;
//successful
result:=true;
skipend:
except;end;
try;str__free(@xdata);except;end;
end;

function io__backupfilename(dname:string):string;//12feb2023
var
   p:longint;
   d:tdatetime;
begin
try
//defaults
result:='';
d:=now;
//.name
if (dname<>'') then dname:=io__safename(dname);
//try upto 100 times
for p:=1 to 100 do
begin
result:=app__subfolder('backups\'+low__datename(d))+low__datetimename(d)+dname;
if io__fileexists(result) then win____sleep(20+random(40)) else break;
end;//p
except;end;
end;

function io__tofilestr(x,xdata:string;var e:string):boolean;//fast and basic low-level
var
   a:tstr8;
begin
//defaults
result:=false;

try
a:=nil;
a:=str__new8;
//get
a.text:=xdata;
result:=io__tofile(x,@a,e);
except;end;
try;str__free(@a);except;end;
end;

function io__tofile(x:string;xdata:pobject;var e:string):boolean;//27sep2022, fast and basic low-level
var
   xfrom:comp;
begin
result:=false;try;xfrom:=0;result:=io__tofileex64(x,xdata,xfrom,true,e);except;end;
end;

function io__tofile64(x:string;xdata:pobject;var e:string):boolean;//27sep2022, fast and basic low-level
var
   xfrom:comp;
begin
result:=false;try;xfrom:=0;result:=io__tofileex64(x,xdata,xfrom,true,e);except;end;
end;

function io__tofileex64(x:string;xdata:pobject;xfrom:comp;xreplace:boolean;var e:string):boolean;//30apr2024: flush file buffers for correct "nav__*" filesize info, 06feb2024, 22jan2024, 27sep2022, fast and basic low-level
label//xreplace=true=file is deleted and then written, false=file is written to/extended in size
   skipend;
const
   amax=maxword;//65K, was 32K
var
   a:array[0..amax] of byte;
   int1,xwritten,ylen,p,ap:longint;
   c:tcmp8;
   v:pfilecache;
   vok,xfilecreated:boolean;
begin
//defaults
result:=false;
e:=gecTaskfailed;
vok:=false;

try
//check
if not str__lock(xdata) then exit;

//init
ylen:=str__len(xdata);

//open or create file
vok:=filecache__openfile_write2(x,xreplace,xfilecreated,v,e);
if not vok then goto skipend;

//switch to replace mode if file was created
if xfilecreated then
   begin
   xreplace:=true;
   xfrom:=0;//22jan2024
   end;

//seek using _from
e:=gecOutOfDiskSpace;
c.val:=xfrom;
win____setfilepointer(v.filehandle,c.ints[0],@c.ints[1],0 {file_begin});

//init
p:=1;
ap:=0;
//.write - tstr8
if (ylen>=1) and (xdata^ is tstr8) then
   begin
   for p:=1 to ylen do
   begin
   //.fill
   a[ap]:=(xdata^ as tstr8).pbytes[p-1];
   //.store
   if (ap>=amax) or (p=yLEN) then
      begin
      if not win____writefile(v.filehandle,a,(ap+1),xwritten,nil) then goto skipend;
      if (xwritten<>(ap+1)) then goto skipend;
      ap:=-1;
      end;
   //.inc
   inc(ap);
   end;//p
   end
//.write - tstr9
else if (ylen>=1) and (xdata^ is tstr9) then
   begin
   while true do
   begin
   int1:=(xdata^ as tstr9).fastread(a,sizeof(a),p-1);
   if (int1>=1) then
      begin
      inc(p,int1);
      if not win____writefile(v.filehandle,a,int1,xwritten,nil) then goto skipend;
      if (xwritten<>int1) then goto skipend;
      end
   else break;
   end;//loop
   end;

//successful
result:=true;
skipend:
except;end;
try
//close file handle
if vok then
   begin
   //.flush the buffers so that a call to "nav__*" will show the correct file size when requested - 30apr2024
   if filecache__enabled then win____FlushFileBuffers(v.filehandle);

   //.close the file -> only if a single instance is open
   filecache__closefile(v);
   end;

//delete the file on failure for "xreplace=true" operations
if (not result) and xreplace then io__remfile(x);

//release buffer and optionally destroy it
str__unlockautofree(xdata);
except;end;
end;

function io__fromfilestrb(x:string;var e:string):string;//30mar2022
begin
result:='';try;io__fromfilestr(x,result,e);except;end;
end;

function io__fromfilestr(x:string;var xdata,e:string):boolean;
var
   a:tstr8;
begin
//defaults
result:=false;

try
xdata:='';
a:=nil;
//get
a:=str__new8;
result:=io__fromfile(x,@a,e);
if result then xdata:=a.text;
except;end;
try;str__free(@a);except;end;
end;

function io__fromfile(x:string;xdata:pobject;var e:string):boolean;
var
   _filesize,_from:comp;
   _date:tdatetime;
begin
result:=false;try;_from:=0;result:=io__fromfile64b(x,xdata,e,_filesize,_from,max32,_date);except;end;
end;

function io__fromfile64(x:string;xdata:pobject;var e:string):boolean;
begin
result:=false;try;result:=io__fromfile641(x,xdata,false,e);except;end;
end;

function io__fromfile641(x:string;xdata:pobject;xappend:boolean;var e:string):boolean;//04feb2024
var
   _filesize,_from:comp;
   _date:tdatetime;
begin
result:=false;try;_from:=0;result:=io__fromfile64c(x,xdata,xappend,e,_filesize,_from,max32,_date);except;end;
end;

function io__fromfile64b(x:string;xdata:pobject;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//24dec2023, 20oct2006
begin
result:=false;try;result:=io__fromfile64c(x,xdata,false,e,_filesize,_from,_size,_date);except;end;
end;

function io__fromfile64d(x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize:comp;_from:comp;_size:comp;var _date:tdatetime):boolean;//06feb2024, 24dec2023, 20oct2006
begin
result:=io__fromfile64c(x,xdata,xappend,e,_filesize,_from,_size,_date);
end;

function io__fromfile64c(x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//06feb2024, 24dec2023, 20oct2006
label
   skipend;
const
   amax=maxword;//65K, was 32K
var
   v:pfilecache;
   vok:boolean;
   a:array[0..amax] of byte;
   xdatalen,_size32,i,p,ac:longint;
   c:tcmp8;
   //## xfilesize ##
   function xfilesize:comp;
   var
      c:tcmp8;
   begin
   result:=0;
   try
   c.ints[0]:=win____getfilesize(v.filehandle,@c.ints[1]);
   result:=c.val;
   except;end;
   end;
begin
//defaults
result:=false;
vok:=false;

try
e:=gecTaskFailed;
_filesize:=0;

//check
if not str__lock(xdata) then exit;

//init
if xappend then xdatalen:=str__len(xdata)
else
   begin
   xdatalen:=0;
   str__clear(xdata);
   end;

//open
case filecache__openfile_read(x,v,e) of
true:vok:=true;
false:goto skipend;
end;

//get file size
_filesize:=xfilesize;

//get file date
_date:=io__dates__fileage(v.filehandle);

//set the value of "_from"
if (_from<0) then _from:=0
else if (_from>=_filesize) then
   begin
   result:=true;
   goto skipend;
   end;

//seek using _from
c.val:=_from;
win____setfilepointer(v.filehandle,c.ints[0],@c.ints[1],0 {file_begin});

//set the value of size
if (_size=0) then//0=read NO data
   begin
   result:=true;
   goto skipend;
   end
else if (_size<0) then _size:=_filesize//-X..-1=read ALL data
else if (_size>_filesize) then _size:=_filesize;//1..X=read SPECIFIED data

//convert _size(64bit) into a fast 32bit int
_size32:=restrict32(_size);

//size check - ensure buffer is small enough to fit in ram
if (add64(xdatalen,_size32)>max32) then
   begin
   e:=gecOutofmemory;
   goto skipend;
   end;

//size the buffer
if not str__setlen(xdata,xdatalen+_size32) then
   begin
   e:=gecOutofmemory;
   goto skipend;
   end;

i:=0;

//.write
while true do
begin
//.get
win____readfile(v.filehandle,a,amax+1,ac,nil);
//.check
if (ac=0) then break;
//.fill
if (xdata^ is tstr8) then
   begin
   for p:=0 to frcmax32(ac-1,_size32-i-1) do//tested and passed - 17may2021
   begin
   inc(i);
   (xdata^ as tstr8).pbytes[xdatalen+i-1]:=a[p];
   end;//p
   end
else if (xdata^ is tstr9) then
   begin
   inc(i,(xdata^ as tstr9).fastwrite(a,frcmax32(ac,_size32-i),xdatalen+i));
   end;

//.quit
if (i>=_size32) then break;
end;//loop

//successful
_from:=add64(_from,i);
if (_filesize=_size) and (_from=0) then result:=(i=_size)//only for small files, BIG files can't always fit in RAM
else
   begin
   if (i<>_size32) then str__setlen(xdata,xdatalen+i);
   result:=(i>=1);
   end;
skipend:
except;end;
try
//close cache record
if vok then filecache__closefile(v);
//reset buffer on failure
if (not result) and (not xappend) then str__clear(xdata);
//release buffer and optionally destroy it
str__unlockautofree(xdata);
except;end;
end;

function io__fromfiletime(x:tfiletime):tdatetime;
var
   a:longint;
   c:tfiletime;
begin
//defaults
result:=now;

try
//get
win____filetimetolocalfiletime(x,c);
if win____filetimetodosdatetime(c,longrec(a).hi,longrec(a).lo) then result:=filedatetodatetime(a) else result:=now;
except;end;
end;

function io__folderexists(x:string):boolean;//15mar2020, 14dec2016
begin//soft check via low__driveexists
result:=false;try;result:=(x<>'') and io__local(x) and io__driveexists(x) and directoryexists(x);except;end;
end;

function io__deletefolder(x:string):boolean;//13feb2024
begin//soft check via low__driveexists
result:=false;
try
//check
if (x='') then exit else x:=io__asfolder(x);
//get
if io__local(x) and io__driveexists(x) then result:=win____RemoveDirectory(pchar(x));
except;end;
end;

function io__makefolder2(x:string):string;
begin
result:=x;
io__makefolder(x)
end;

function io__makefolder(x:string):boolean;//15mar2020, 19may2019
begin//soft check via low__driveexists
result:=false;
try
//check
if (x='') then exit else x:=io__asfolder(x);
//get
if io__local(x) and io__driveexists(x) then
   begin
   result:=io__folderexists(x);
   if not result then
      begin
      forcedirectories(x);
      result:=io__folderexists(x);
      end;
   end;
except;end;
end;

function io__exemarker(x:tstr8):boolean;//14nov2023
var
   z:string;
begin
//defaults
result:=false;

try
//check
if not str__lock(@x) then exit;
z:='';
//set - dynamically create the header, so that no complete trace is formed in the final EXE data stream, we can then search for this header without fear of it being repeated in the code by mistake! - 18MAY2010
x.saddb('[packed');
x.saddb('-marker]');
x.saddb('[id--');
//.id
z:=z+'1398435432908435908';
z:='__12435897'+z;
z:=z+'0-9132487211239084%%__';
z:=z+'~12@__Z';
//finalise
x.saddb(z);
x.saddb('--]');
//successful
result:=true;
except;end;
try;str__uaf(@x);except;end;
end;

function io__exereadFROMFILE(xfilename:string;xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8;var e:string):boolean;//14nov2023
label
   skipend;
var
   s:tstr8;
begin
//defaults
result:=false;

try
s:=nil;
e:=gecTaskfailed;
//check
str__lock(@xexedata);
str__lock(@xsysdata);
str__lock(@xprgdata);
str__lock(@xusrdata);
//get
if (xfilename<>'') then
   begin
   s:=str__new8;
   if io__fromfile(xfilename,@s,e) then
      begin
      e:=gecUnknownformat;
      result:=io__exeread(s,xexedata,xsysdata,xprgdata,xusrdata,xsysmore);
      end;
   end;
skipend:
except;end;
try
str__free(@s);
str__uaf(@xexedata);
str__uaf(@xsysdata);
str__uaf(@xprgdata);
str__uaf(@xusrdata);
except;end;
end;

function io__exeread(s,xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8):boolean;//14nov2023
label
   skipend;
var
   m,xtmp:tstr8;
   xpos,p:longint;
   m1:byte;
   //## xread ##
   function xread(x:tstr8):boolean;
   label
      skipend;
   var
      xlen:longint;
   begin
   //defaults
   result:=false;
   try
   //get
   xlen:=s.int4[xpos];
   inc(xpos,4);
   if (x<>nil) then
      begin
      x.clear;
      if (xlen>=1) and (not x.add3(s,xpos,xlen)) then goto skipend;
      end;
   inc(xpos,xlen);
   //successful
   result:=true;
   skipend:
   except;end;
   end;
begin
//defaults
result:=false;//not found

try
m:=nil;
xtmp:=nil;
//check
str__lock(@xexedata);
str__lock(@xsysdata);
str__lock(@xprgdata);
str__lock(@xusrdata);
if not str__lock(@s) then goto skipend;
if (s.len<=0) then goto skipend;
//init
if (xexedata<>nil) then xexedata.clear;
if (xsysdata<>nil) then xsysdata.clear;
if (xprgdata<>nil) then xprgdata.clear;
if (xusrdata<>nil) then xusrdata.clear;
if (xsysmore<>nil) then xsysmore.clear;
xtmp:=str__new8;
m:=str__new8;
if not io__exemarker(m) then goto skipend;
m1:=m.pbytes[0];
//find
for p:=1 to s.len do if (m1=s.pbytes[p-1]) and s.same2(p-1,m) then
   begin
   if (xexedata<>nil) then xexedata.add31(s,1,p-1);
   //.data slots
   xpos:=p-1+m.len;
   if not xread(xsysdata) then goto skipend;
   if not xread(xprgdata) then goto skipend;
   if not xread(xusrdata) then goto skipend;
   //.xsysmore
   if not xread(xtmp) then goto skipend;
   if (xsysmore<>nil) then xsysmore.binary['more']:=xtmp;
   //.done
   result:=true;
   break;
   end;
//assume all of "s" is the exe
if not result then
   begin
   if (xexedata<>nil) and (not xexedata.add(s)) then goto skipend;
   result:=true;
   end;
skipend:
except;end;
try
str__free(@m);
str__uaf(@s);
str__uaf(@xexedata);
str__uaf(@xsysdata);
str__uaf(@xprgdata);
str__uaf(@xusrdata);
str__free(@xtmp);
except;end;
end;

function io__exewriteTOFILE(xfilename:string;xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8;var e:string):boolean;//14nov2023
label
   skipend;
var
   s:tstr8;
begin
//defaults
result:=false;

try
s:=nil;
e:=gecTaskfailed;
//check
str__lock(@xexedata);
str__lock(@xsysdata);
str__lock(@xprgdata);
str__lock(@xusrdata);
//get
if (xfilename<>'') then
   begin
   s:=str__new8;
   if not io__exewrite(s,xexedata,xsysdata,xprgdata,xusrdata,xsysmore) then goto skipend;
   if not io__tofile(xfilename,@s,e) then goto skipend;
   //successful
   result:=true;
   end;
skipend:
except;end;
try
str__free(@s);
str__uaf(@xexedata);
str__uaf(@xsysdata);
str__uaf(@xprgdata);
str__uaf(@xusrdata);
except;end;
end;

function io__exewrite(d,xexedata,xsysdata,xprgdata,xusrdata:tstr8;xsysmore:tvars8):boolean;//14nov2023
label
   skipend;
var
   m:tstr8;
   //## xadd ##
   function xadd(x:tstr8):boolean;
   label
      skipend;
   var
      int1:longint;
   begin
   //defaults
   result:=false;

   try
   str__lock(@x);
   int1:=str__len(@x);
   if not d.addint4(int1) then goto skipend;
   if (int1>=1) and (not d.add(x)) then goto skipend;
   //successful
   result:=true;
   skipend:
   except;end;
   try;str__uaf(@x);except;end;
   end;
begin
//defaults
result:=false;//not found

try
m:=nil;
//check
str__lock(@xexedata);
str__lock(@xsysdata);
str__lock(@xprgdata);
str__lock(@xusrdata);
if not low__true2(str__lock(@d),str__lock(@xexedata)) then goto skipend;
if (xexedata.len<=0) then goto skipend;
//init
m:=str__new8;
if not io__exemarker(m) then goto skipend;
//get
//.exe header
if not d.add(xexedata) then goto skipend;
//.marker
if not d.add(m) then goto skipend;//always include the marker, so EXE knows it is a child/client of a parent
//.sysdata
if not xadd(xsysdata) then goto skipend;
//.prgdata
if not xadd(xprgdata) then goto skipend;
//.usrdata
if not xadd(xusrdata) then goto skipend;
//.sysmore
if (xsysmore=nil) then xadd(nil)
else                   xadd(xsysmore.binary['more']);
//successful
result:=true;
skipend:
except;end;
try
str__free(@m);
str__uaf(@d);
str__uaf(@xexedata);
str__uaf(@xsysdata);
str__uaf(@xprgdata);
str__uaf(@xusrdata);
except;end;
end;

function io__drivelist:tdrivelist;
var
   xdrivelist:set of 0..25;
   p:longint;
begin
//defaults
for p:=0 to high(tdrivelist) do result[p]:=false;

try
//get
longint(xdrivelist):=win____getlogicaldrives;
for p:=0 to 25 do if (p in xdrivelist) then result[p]:=true;
except;end;
end;

//## io__createlink ##
procedure io__createlink(df,sf,dswitches,iconfilename:string);//10apr2019, 14NOV2010
var//Note: df=> filename to save link as, sf=filename we are linking to
   //ShlObj, ActiveX, ComObj
  iobject:iunknown;
  islink:ishelllink;
  ipfile:ipersistfile;
begin
try
//defaults
iobject:=nil;
//init
iobject:=win____createcomobject(CLSID_ShellLink);
islink:=iobject as ishelllink;
ipfile:=iobject as ipersistfile;
//clean
io__remfile(df);
//link
with islink do
begin
setarguments(pchar(dswitches));
setpath(pchar(sf));
setworkingdirectory(pchar(io__extractfilepath(sf)));
if (iconfilename<>'') then seticonlocation(pchar(iconfilename),0);//14NOV2010
end;
//.link.save
ipfile.save(pwchar(widestring(df)),false);
except;end;
//On 01mar2021 @2am the below line of code starting causing fatal error -> need to lookup if it actually is required or if there is a "correct" method for getting rid of this object instance - 01mar2021
//needs fixing!!!!!!!!!!!!!!!!: try;freeobj(@iobject);except;end;
//Note: "iunknown" is a special instance that is automatically destroyed by the compiler - 27apr2021
end;

function io__exename:string;
begin
result:='';try;result:=low__param(0);except;end;//w32 and a32
end;

function io__ownname:string;
begin
try;result:=io__remlastext(io__extractfilename(low__param(0)));except;end;//c:\xxxx\abc.exe -> "abc" - 09aug2021
end;

function io__dates__filedatetime(x:tfiletime):tdatetime;
var
   a:longint;
   c:tfiletime;
begin
//defaults
result:=now;

try
//process
win____filetimetolocalfiletime(x,c);
if win____filetimetodosdatetime(c,longrec(a).hi,longrec(a).lo) then result:=filedatetodatetime(a)
else result:=now;
except;end;
end;

function io__dates__fileage(x:thandle):tdatetime;
var
   a:tbyhandlefileinformation;
begin
result:=0;try;if (x=0) or (not win____getfileinformationbyhandle(x,a)) then result:=now else result:=io__dates__filedatetime(a.ftLastWriteTime);except;end;
end;

function io__lastext(x:string):string;//returns last extension - 03mar2021
begin
result:='';try;result:=io__lastext2(x,false);except;end;
end;

function io__lastext2(x:string;xifnodotusex:boolean):string;//returns last extension - 03mar2021
var
   p:longint;
   c:char;
begin
result:='';

try
//defaults
if xifnodotusex then result:=x else result:='';
//get
if (x<>'') then
   begin
   for p:=(length(x)-1) downto 0 do
   begin
   c:=x[p+stroffset];
   if (c='.') then
      begin
      result:=strcopy0(x,p+1,length(x));
      break;
      end
   else if (c='/') or (c='\') or (c=':') or (c='|') then break;
   end;//p
   end;
except;end;
end;

function io__remlastext(x:string):string;//remove last extension
var
   p:longint;
begin
result:='';

try
result:=x;
if (x<>'') then
   begin
   for p:=(length(x)-1) downto 0 do if (x[p+stroffset]='.') then
   begin
   result:=strcopy0(x,0,p);
   break;
   end;//p
   end;
except;end;
end;

function io__readfileext(x:string;fu:boolean):string;{Date: 24-DEC-2004, Superceeds "ExtractFileExt"}
var//supports: "c:\windows\abc.RTF" and also "http://www.blaiz.net/abc/docs/index.RTF?abc=com"
   a,b:string;
begin
result:='';

try
if io__scandownto(x,'.','/','\',a,result) then
   begin
   if io__scandownto(result,'?',#0,#0,a,b) then result:=a;
   if fu then result:=strup(result);
   end
else result:='';
except;end;
end;

function io__readfileext_low(x:string):string;//30jan2022
begin
result:='';try;result:=strlow(io__readfileext(x,false));except;end;
end;

function io__scandownto(x:string;y,stopA,stopB:char;var a,b:string):boolean;
var
   xlen,p:longint;
   _stopA,_stopB:boolean;
begin
//defaults
result:=false;

try
a:='';
b:='';
_stopA:=(stopA<>#0);
_stopB:=(stopB<>#0);
//init
xlen:=length(x);
//check
if (xlen<=0) then exit;
//get
for p:=(xlen-1) downto 0 do
begin
if (_stopA and (x[p+stroffset]=stopA)) then break
else if (_stopB and (x[p+stroffset]=stopB)) then break
else if (x[p+stroffset]=y) then
   begin
   a:=strcopy0(x,0,p);
   b:=strcopy0(x,p+1,xlen);
   result:=true;
   break;
   end;
end;//p
except;end;
end;

function io__faISfolder(x:longint):boolean;//05JUN2013
begin//fast
result:=((x and faDirectory)>0);
end;

function io__safename(x:string):string;//07mar2021, 08mar2016
begin
result:='';try;result:=io__safefilename(x,false);except;end;
end;

function io__safefilename(x:string;allowpath:boolean):string;//07mar2021, 08mar2016
var
   minp,p:longint;
   c:char;
   //## isbinary ##
   function isbinary(x:byte):boolean;
   begin
   result:=false;

   try
   case x of//31MAR2010
   32..255:result:=false;
   else result:=true;
   end;
   except;end;
   end;
begin
//defaults
result:='';

try
result:=x;
if (x='') then exit;
//get
if allowpath then
   begin
   //.get
   if (strcopy1(x,1,2)='\\') then minp:=3 else minp:=1;
   //.set
   for p:=(minp-1) to (length(result)-1) do
   begin
   c:=result[p+stroffset];
   if (c='/') then result[p+stroffset]:='\'
   else if isbinary(byte(c)) or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='$') then result[p+stroffset]:=pcSymSafe;
   //was: else if isbinary(byte(c)) or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='@') or (c='$') then result[p+stroffset]:=pcSymSafe;
   end;//p
   end
else
   begin
   //.set
   for p:=0 to (length(result)-1) do
   begin
   c:=result[p+stroffset];
   if isbinary(byte(c)) or (c='\') or (c='/') or (c=':') or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='@') or (c='$') then result[p+stroffset]:=pcSymSafe;
   end;//p
   end;
except;end;
end;

function io__issafefilename(x:string):boolean;//07mar2021, 10APR2010
var
   p:longint;
   c:char;
   //## isbinary ##
   function isbinary(x:byte):boolean;
   begin
   result:=false;

   try
   case x of//31MAR2010
   32..255:result:=false;
   else result:=true;
   end;
   except;end;
   end;
begin
//defaults
result:=true;

try
//check
if (x='') then exit;
//set
for p:=0 to (length(x)-1) do
begin
c:=x[p+stroffset];
//was: if isbinary(byte(c)) or (c='\') or (c='/') or (c=':') or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='@') or (c='$') then
if isbinary(byte(c)) or (c='\') or (c='/') or (c=':') or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='$') then
   begin
   result:=false;
   break;
   end;
end;//p
except;end;
end;

function io__hack_dangerous_filepath_allow_mask(x:string):boolean;
begin
result:=false;try;result:=io__hack_dangerous_filepath(x,false);except;end;
end;

function io__hack_dangerous_filepath_deny_mask(x:string):boolean;
begin
result:=false;try;result:=io__hack_dangerous_filepath(x,true);except;end;
end;

function io__hack_dangerous_filepath(x:string;xstrict_no_mask:boolean):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') then
   begin
   for p:=0 to (length(x)-1) do
   begin
   //check 1 - "..\" + "../"
   if (x[p+stroffset]='.') and ((strcopy0(x,p,3)='..\') or (strcopy0(x,p,3)='../')) then
      begin
      result:=true;
      break;
      end
   //check 2 - (..\) "..%5C" + "..%5c" AND (../) "..%2F" + "..%2f"
   else if (x[p+stroffset]='.') and ((strcopy0(x,p,5)='..%5C') or (strcopy0(x,p,5)='..%5c') or (strcopy0(x,p,5)='..%2F') or (strcopy0(x,p,5)='..%2f')) then
      begin
      result:=true;
      break;
      end
   //check 3 - ":" other than "(a-z/@):(\/)" e.g. "C:\" is ok, but "C::" is not - 02sep2016
   else if (p>=2) and (x[p+stroffset]=':') then
      begin
      result:=true;
      break;
      end
   //check 4 - none of these characters are allowed, ever - 02sep2016
   else if (x[p+stroffset]='?') or (x[p+stroffset]='<') or (x[p+stroffset]='>') or (x[p+stroffset]='|') then
      begin
      result:=true;
      break;
      end
   //optional check 5 - disallow file masking "*"
   else if xstrict_no_mask and (x[p+stroffset]='*') then
      begin
      result:=true;
      break;
      end;
   end;//p
   end;
except;end;
end;

function io__makeportablefilename(filename:string):string;//11sep2021, 06oct2020, 14APR2011
var// "C:\...\" => exact static filename
   // "c:\...\" => also an exact static filename
   // "?:\...\" => relative dynamic filename (on same disk as EXE and thus will adapt) - 11sep2021, 14APR2011
   edrive,sdrive:string;
begin
result:='';

try
result:=filename;
//get
if (length(result)>=2) and (strcopy1(result,2,1)=':') and (strcopy1(result,1,1)<>'/') and (strcopy1(result,1,1)<>'\') then
   begin
   edrive:=strcopy1b(io__exename+'Z',1,1);//pad with "Z" incase app.exename is empty for some reason - 14APR2011
   sdrive:=strcopy1b(result,1,1);
   //get - if on same drive as EXE then it's considered portable so make it "?:\...\"
   if strmatch(edrive,sdrive) then result:='?'+strcopy1(result,2,length(result));
   end;
except;end;
end;

function io__readportablefilename(filename:string):string;//11sep2021
var// "C:\...\" => STATIC, exact static filename
   // "c:\...\" => also an exact static filename
   // "?:\...\" => RELATIVE, dynamic filename (on same disk as EXE and thus will adapt) - 11sep2021, 14APR2011
   edrive:string;
begin
result:='';

try
result:=filename;
//get
if (length(result)>=2) and (strcopy1(result,2,1)=':') and (strcopy1(result,1,1)<>'/') and (strcopy1(result,1,1)<>'\') then
   begin
   edrive:=strcopy1b(io__exename+'Z',1,1);//pad with "Z" incase app.exename is empty for some reason - 14APR2011
   if (strcopy1(result,1,1)='?') then result:=edrive+strcopy1(result,2,length(result));
   end;
except;end;
end;

function io__extractfileext(x:string):string;//12apr2021
var
   p:longint;
begin
//defaults
result:='';

try
//get
if (x<>'') then
   begin
   for p:=length(x) downto 1 do
   begin
   if (strcopy1(x,p,1)='/') or (strcopy1(x,p,1)='\') then break
   else if (strcopy1(x,p,1)='.') then
      begin
      result:=strcopy1(x,p+1,length(x));
      break
      end;
   end;//p
   end;
except;end;
end;

function io__extractfileext2(x,xdefext:string;xuppercase:boolean):string;//12apr2021
begin
result:='';

try
result:=strdefb(io__extractfileext(x),xdefext);
if xuppercase then result:=strup(result);
except;end;
end;

function io__extractfileext3(x,xdefext:string):string;//lowercase version - 15feb2022
begin
result:='';try;result:=strlow(strdefb(io__extractfileext(x),xdefext));except;end;
end;

function io__extractfilepath(x:string):string;//04apr2021
var
   p:longint;
begin
//defaults
result:='';

try
//get
if (x<>'') then
   begin
   for p:=length(x) downto 1 do if (strcopy1(x,p,1)='/') or (strcopy1(x,p,1)='\') then
      begin
      result:=strcopy1(x,1,p);
      break;
      end;
   end;
except;end;
end;

function io__extractfilename(x:string):string;//05apr2021
var
   p:longint;
begin
result:='';

try
//defaults
result:=x;//allow default passthru -> this allows for instances with ONLY a filename present e.g. "aaaa.bcs"
//get
if (x<>'') then
   begin
   for p:=length(x) downto 1 do if (strcopy1(x,p,1)='/') or (strcopy1(x,p,1)='\') then
      begin
      result:=strcopy1(x,p+1,length(x));
      break;
      end;
   end;
except;end;
end;

function io__renamefile(s,d:string):boolean;//local only, soft check - 27nov2016
begin
//defaults
result:=false;

try
if (s='') or (d='') then exit;
//hack check
if io__hack_dangerous_filepath_deny_mask(s) then exit;
if io__hack_dangerous_filepath_deny_mask(d) then exit;
//collision check
if strmatch(s,d) then
   begin
   result:=true;
   exit;
   end;
//get - Delphi renamefile
if io__fileexists(s) and (not io__fileexists(d)) then
   begin
   filecache__closeall_byname_rightnow(s);//close any open "s" instances - 12apr2024
   result:=sysutils.renamefile(s,d);
   end;
except;end;
end;

function io__shortfile(xlongfilename:string):string;//translate long filenames to short filename, using MS api, for "MCI playback of filenames with 125+c" - 23FEB2008
var//Note: works only for existing filenames - short names accessed from disk system
  z:string;
  zlen:longint;
begin
result:='';

try
//defaults
result:=xlongfilename;
//get
low__setlen(z,max_path);
zlen:=win____getshortpathname(pchar(xlongfilename),pchar(z),max_path-1);
if (zlen>=1) then
   begin
   low__setlen(z,zlen);
   result:=z;
   end;
except;end;
end;

function io__asfolder(x:string):string;//enforces trailing "\"
begin
result:='';try;if (strcopy1(x,length(x),1)<>'\') then result:=x+'\' else result:=x;except;end;
end;

function io__asfolderNIL(x:string):string;//enforces trailing "\" AND permits NIL - 03apr2021, 10mar2014
begin
result:='';

try
if (x='') then result:=''//nil
else if (not strmatch(strcopy1(x,2,2),':\')) and (not strmatch(strcopy1(x,2,2),':/')) and (strcopy1(x,1,1)<>'/') and (strcopy1(x,1,1)<>'\') then result:=x//straight pass-thru -> this allows for "home" to pass right thru unaffected - 31mar2021
else result:=io__asfolder(x);//as a folder in the format "?:\.....\" or "?:/...../" or "/..../" or "\...\"
except;end;
end;

function io__folderaslabel(x:string):string;
var
   p:longint;
begin
//defaults
result:='';

try
//remove trailing slash
if (strcopy1(x,length(x),1)='/') or (strcopy1(x,length(x),1)='\') then strdel1(x,length(x),1);
//read down to next slash
if (x<>'') then for p:=length(x) downto 1 do if (strbyte1(x,p)=92) or (strbyte1(x,p)=47) then
   begin
   x:=strcopy1(x,p+1,length(x));
   break;
   end;
except;end;
try;result:=strdefb(x,'?');except;end;
end;

function io__isfile(x:string):boolean;
begin
result:=false;try;result:=(strcopy1(x,length(x),1)<>'\') and (strcopy1(x,length(x),1)<>'/');except;end;
end;

function io__local(x:string):boolean;
begin
result:=false;try;result:=(strcopy1(x,1,1)<>'@');except;end;
end;

function io__canshowfolder(x:string):boolean;
begin
result:=false;try;result:=io__local(x);except;end;
end;

function io__driveexists(x:string):boolean;//true=drive has content - 17may2021, 16feb2016, 25feb2015, 17AUG2010
var
   xdrive:string;
{$ifdef d3laz}
   orgerr,notused,volflags,serialno:dword;
   buf:array[0..max_path] of char;
   buf2:array[0..max_path] of char;
{$endif}
begin
//defaults
result:=false;
orgerr:=0;

try
//check
if (x<>'') then xdrive:=x[stroffset]+':\' else exit;
//hack check
if io__hack_dangerous_filepath_deny_mask(xdrive) then exit;//17may2021
//check drive is in range
if not (  (xdrive[1+stroffset]=':') and ((xdrive[2+stroffset]='\') or (xdrive[2+stroffset]='/')) and ( (xdrive[0+stroffset]='!') or (xdrive[0+stroffset]='@') or ((xdrive[0+stroffset]>='a') and (xdrive[0+stroffset]<='z')) or ((xdrive[0+stroffset]>='A') and (xdrive[0+stroffset]<='Z')) )  ) then exit;
//get
if      (xdrive='@:\') then result:=false//no support for Name Network at this stage - nn.stable - 15mar2020
else
   begin
{$ifdef d3laz}
   try
   //fully qualified for maximum stability - 17may2021
   orgerr:=win____seterrormode(SEM_FAILCRITICALERRORS);//prevents the display of a prompt window asking for a FLOPPY or CD-DISK to be inserted as stated my MS - 04apr2021
   fillchar(buf,sizeof(buf),0);
   fillchar(buf2,sizeof(buf2),0);
   buf[0]:=#$00;
   buf2[0]:=#$00;
   result:=boolean(win____getvolumeinformation(pchar(xdrive),buf,sizeof(buf),@serialno,notused,volflags,buf2,sizeof(buf2)));
   except;end;
   win____seterrormode(orgerr);
{$endif}

{$ifdef D10}
result:=true;//D10: No support yet
{$endif}
   end;
except;end;
end;

function io__drivetype(x:string):string;//15apr2021, 05apr2021
type
   tdrivetype2=(dtUnknown,dtNoDrive,dtFloppy,dtFixed,dtNetwork,dtCDROM,dtRAM);
var
   xdrive:string;
begin
//defaults
result:='';

try
//init
xdrive:=strup(strcopy1(x,1,1));
//get
if (xdrive<>'') then
   begin
   if      (xdrive='@')          then result:='nn'//name network
   else
      begin
      case tdrivetype2(win____getdrivetype(pchar(xdrive+':\'))) of
      dtFloppy:if (xdrive<='B') then result:='floppy' else result:='removable';
      dtFixed   :result:='fixed';
      dtNetwork :result:='network';
      dtCDROM   :result:='cd';
      dtRAM     :result:='ram';
      else       result:='fixed';
      end;//case
      end;//if
   end;
except;end;
end;

function io__drivelabel(x:string;xfancy:boolean):string;//17may2021, 05apr2021
var//Note: Incorrectly returns UPPERCASE labels for removable disks - 30DEC2010
   xdrive,xlabel:string;
   p:longint;
   orgerr,notused,volflags,serialno:dword;
   buf:array[0..max_path] of char;
   buf2:array[0..max_path] of char;
begin
//defaults
result:='';
orgerr:=0;

try
//get
if (x<>'') then
   begin
   //init
   xdrive:=strcopy1(x,1,1)+':';
   xlabel:='';
   //label
   if io__driveexists(x) then
      begin
      //.standard disk drives "A-Z:\"
      if ((x[0+stroffset]>='a') and (x[0+stroffset]<='z')) or ((x[0+stroffset]>='A') and (x[0+stroffset]<='Z')) then
         begin
         try
         //fully qualified for maximum stability - 17may2021
         orgerr:=win____seterrormode(SEM_FAILCRITICALERRORS);//prevents the display of a prompt window asking for a FLOPPY or CD-DISK to be inserted as stated my MS - 04apr2021
         fillchar(buf,sizeof(buf),0);
         fillchar(buf2,sizeof(buf2),0);
         buf[0]:=#$00;
         buf2[0]:=#$00;
         if boolean(win____getvolumeinformation(pchar(strcopy1(x,1,1)+':\'),buf,sizeof(buf),@serialno,notused,volflags,buf2,sizeof(buf2))) then setstring(xlabel,buf,strlen(buf));
         except;end;
         win____seterrormode(orgerr);
         end;
      end;
   //clean -> make more compatible with "Wine 5+" - 16apr2021
   if (xlabel<>'') then
      begin
      for p:=1 to length(xlabel) do if (strcopy1(xlabel,p,1)='?') or (strcopy1(xlabel,p,1)=#0) then
         begin
         xlabel:=strcopy1(xlabel,1,p-1);
         break;
         end;
      end;
   //set
   if xfancy then result:=xlabel+insstr(#32+'(',xlabel<>'')+xdrive+insstr(')',xlabel<>'') else result:=xlabel;
   end;
except;end;
end;

function io__filelist(xoutlist:tdynamicstring;xfullfilenames:boolean;xfolder,xmasklist,xemasklist:string):boolean;//06oct2022
begin
result:=false;try;result:=io__filelist2(xoutlist,xfullfilenames,xfolder,xmasklist,xemasklist,0,0,maxcur,'');except;end;
end;

function io__filelist2(xoutlist:tdynamicstring;xfullfilenames:boolean;xfolder,xmasklist,xemasklist:string;xtotalsizelimit,xminsize,xmaxsize:comp;xminmax_emasklist:string):boolean;//31dec2023, 06oct2022
label
   skipend;
const
   xfiles=true;
   xfolders=false;
   xallfiles='*';
var
   i:longint;
   xtotalsize,xsize:comp;
   c:tcmp8;
   xrec:tsearchrec;
   dfolder:string;
   xfindopen:boolean;
{
   //.dk support
   xoutname,xoutnameonly:string;
   xoutfolder,xoutfile:boolean;
   xoutdate:tdatetime;
   xpos,xoutsize:longint;
   xoutreadonly:boolean;
{}
begin
//defaults
result:=false;
xfindopen:=false;
low__cls(@xrec,sizeof(xrec));//28sep2020
xtotalsize:=0;

try
//check
if zznil(xoutlist,2183) then goto skipend;
//init
if (xmasklist='') then xmasklist:=xallfiles;
if (xfolder='') then
   begin
   result:=true;
   goto skipend;
   end
else xfolder:=io__asfolder(xfolder);//28sep2020
//.xtotalsizelimit
if (xtotalsizelimit<0) then xtotalsizelimit:=0;
//.dfolder
dfolder:=insstr(xfolder,xfullfilenames);

//hack check
if io__hack_dangerous_filepath_allow_mask(xfolder) then goto skipend;
//get

//.open
case xfolders of
true: i:=win__findfirst(xfolder+xallfiles,faReadOnly or faHidden or faSysFile or faDirectory or faArchive or faAnyFile,xrec);
false:i:=win__findfirst(xfolder+xallfiles,faReadOnly or faHidden or faSysFile or faArchive or faAnyFile,xrec);
end;//end of case
xfindopen:=(i=0);
while i=0 do
begin
//.skip system folders
if (xrec.name='.') or (xrec.name='..') then
   begin
   //nil
   end
//.add folder ------------------------------------------------------------------
else if io__faISfolder(xrec.attr) then
   begin
   //nil
   end
//.add file --------------------------------------------------------------------
else
   begin
   if xfiles then
      begin
      //64bit size support - 31dec2023
      c.ints[0]:=xrec.finddata.nFileSizeLow;
      c.ints[1]:=xrec.finddata.nFileSizeHigh;
      xsize:=c.val;

      if (((xsize>=xminsize) and (xsize<=xmaxsize)) or low__matchmasklistb(xrec.name,xminmax_emasklist)) and ( low__matchmasklistb(xrec.name,xmasklist) and ((xemasklist='') or (not low__matchmasklistb(xrec.name,xemasklist))) ) then
         begin
         //get
         //.at limit -> stop
         xtotalsize:=add64(xtotalsize,xsize);
         if (xtotalsizelimit>=1) and (xtotalsize>xtotalsizelimit) then
            begin
            result:=true;
            goto skipend;
            end;
         //.add
         xoutlist.value[xoutlist.count]:=dfolder+xrec.name;
         end;
      end;
   end;
//.inc
i:=win__findnext(xrec);
end;//while
//successful
result:=true;
skipend:
except;end;
try;if xfindopen then win__findclose(xrec);except;end;
end;

function io__filelist3(xfolder,xmasklist,xemasklist:string;xfiles,xfolders,xsubfolders:boolean;xevent:tsearchrecevent;xevent2:tsearchrecevent2;xhelper:tobject):boolean;//31dec2023
label
   skipend;
const
   xallfiles='*';
var
   p,i:longint;
   xsize:comp;
   xdatenow,xdate:tdatetime;
   c:tcmp8;
   xrec:tsearchrec;
   xeventOK,xeventOK2,xfindopen:boolean;
   xsubfolderlist:tdynamicstring;
begin
//defaults
result:=false;
xsubfolderlist:=nil;
xfindopen:=false;
low__cls(@xrec,sizeof(xrec));//31dec2023
xdatenow:=now;
i:=0;

try
//check
xeventOK:=assigned(xevent);
xeventOK2:=assigned(xevent2);
if (not xeventOK) and (not xeventOK2) then goto skipend;
//init
if (xmasklist='') then xmasklist:=xallfiles;
if (xfolder='') then
   begin
   result:=true;
   goto skipend;
   end
else xfolder:=io__asfolder(xfolder);//28sep2020

//hack check
if io__hack_dangerous_filepath_allow_mask(xfolder) then goto skipend;
//get

//.open
case xsubfolders of
true: i:=win__findfirst(xfolder+xallfiles,faReadOnly or faHidden or faSysFile or faDirectory or faArchive or faAnyFile,xrec);
false:i:=win__findfirst(xfolder+xallfiles,faReadOnly or faHidden or faSysFile or faArchive or faAnyFile,xrec);
end;//end of case

xfindopen:=(i=0);
while i=0 do
begin
//.skip system folders
if (xrec.name='.') or (xrec.name='..') then
   begin
   //nil
   end
//.add folder ------------------------------------------------------------------
else if io__faISfolder(xrec.attr) then
   begin
   //.subfolders
   if xsubfolders then
      begin
      if (xsubfolderlist=nil) then xsubfolderlist:=tdynamicstring.create;
      xsubfolderlist.value[xsubfolderlist.count]:=xrec.name;
      end;
   //.folders
   if xfolders then
      begin
      //init
      xsize:=0;
      xdate:=xdatenow;
      //fire the event - as a folder
      if xeventOK and (not xevent(xfolder,xrec,xsize,xdate,false,true,xhelper)) then goto skipend;
      if xeventOK2 and (not xevent2(xfolder,xrec,xsize,xdate,false,true,xhelper)) then goto skipend;
      end;
   end
//.add file --------------------------------------------------------------------
else
   begin
   //.files
   if xfiles and ( low__matchmasklistb(xrec.name,xmasklist) and ((xemasklist='') or (not low__matchmasklistb(xrec.name,xemasklist))) ) then
      begin
      //64bit size support - 31dec2023
      c.ints[0]:=xrec.finddata.nFileSizeLow;
      c.ints[1]:=xrec.finddata.nFileSizeHigh;
      xsize:=c.val;
      xdate:=io__fromfiletime(xrec.finddata.ftLastWriteTime);
      //fire the event
      if xeventOK and (not xevent(xfolder,xrec,xsize,xdate,true,false,xhelper)) then goto skipend;
      if xeventOK2 and (not xevent2(xfolder,xrec,xsize,xdate,true,false,xhelper)) then goto skipend;
      end;
   end;
//.inc
i:=win__findnext(xrec);
end;//while

//subfolders
if xsubfolders and (xsubfolderlist<>nil) and (xsubfolderlist.count>=1) then
   begin
   for p:=0 to (xsubfolderlist.count-1) do if not io__filelist3(io__asfolder(xfolder+xsubfolderlist.value[p]),xmasklist,xemasklist,xfiles,xfolders,xsubfolders,xevent,xevent2,xhelper) then goto skipend;
   end;

//successful
result:=true;
skipend:
except;end;
try
freeobj(@xsubfolderlist);
if xfindopen then win__findclose(xrec);
except;end;
end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//222222222222
//.filecache procs -------------------------------------------------------------
//## filecache__recok ##
function filecache__recok(x:pfilecache):boolean;
begin
result:=(x<>nil) and x.init;
end;
//## filecache__initrec ##
procedure filecache__initrec(x:pfilecache;xslot:longint);//used internally by system
begin
//check
if (x=nil) then exit;

//clear
with x^ do
begin
init:=false;
time_created:=0;
time_idle:=0;
filehandle:=0;
filename:='';
filenameREF:=0;
opencount:=0;
usecount:=0;//only place this is set to zero again
read:=false;
write:=false;
slot:=xslot;
end;
end;
//## filecache__idletime ##
function filecache__idletime:comp;
begin
result:=add64(ms64,60000);//1 minute
end;
//## filecache__enabled ##
function filecache__enabled:boolean;
begin
result:=(system_filecache_limit>=21);
end;
//## filecache__limit ##
function filecache__limit:longint;
begin
result:=system_filecache_limit;
end;
//## filecache__safefilename ##
function filecache__safefilename(x:string):boolean;
begin
result:=(x<>'') and (x[0+stroffset]<>'@') and (not io__hack_dangerous_filepath_deny_mask(x));
end;
//## filecache__closeall ##
procedure filecache__closeall;
var
   p:longint;
begin
for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init then system_filecache_slot[p].opencount:=0;
system_filecache_timer:=0;//act quickly
end;
//## filecache__closeall_rightnow ##
procedure filecache__closeall_rightnow;
var
   p:longint;
begin
for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init then filecache__closerec(@system_filecache_slot[p]);
end;
//## filecache__closeall_byname_rightnow ##
procedure filecache__closeall_byname_rightnow(x:string);
var
   p:longint;
   xref:comp;
begin
if (x<>'') and filecache__enabled then
   begin
   xref:=low__ref256u(x);
   for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and (xref=system_filecache_slot[p].filenameREF) and strmatch(x,system_filecache_slot[p].filename) then filecache__closerec(@system_filecache_slot[p]);
   end;
end;
//## filecache__closerec ##
procedure filecache__closerec(x:pfilecache);
begin
if filecache__recok(x) then
   begin
   x.init:=false;
   if (x.filehandle>=1) then win____closehandle(x.filehandle);
   with x^ do
   begin
   time_created  :=0;
   time_idle     :=0;
   filehandle    :=0;
   filename      :='';
   filenameREF   :=0;
   opencount     :=0;
   read          :=false;
   write         :=false;
   end;
   //.inc usecount
   filecache__inc_usecount(x);
   end;
end;
//## filecache__closefile ##
procedure filecache__closefile(var x:pfilecache);
begin
if filecache__recok(x) then
   begin
   x.opencount:=frcmin32(x.opencount-1,0);
   if (x.opencount<=0) then system_filecache_timer:=0;//instruct management to act quickly
   //.not caching -> close file right now
   if not filecache__enabled then filecache__closerec(x);
   end;
end;
//## filecache__inc_usecount ##
procedure filecache__inc_usecount(x:pfilecache);
begin
if filecache__recok(x) then
   begin
   //inc the "usecount" -> rolls between 1..maxint, never hits zero - 12apr2024
   if (x^.usecount<maxint) then inc(x^.usecount) else x^.usecount:=1;
   end;
end;
//## filecache__newslot ##
function filecache__newslot:longint;
var
   p:longint;
   xms64:comp;
begin
//defaults
result:=-1;

try
//new
if (result<0) then
   begin
   for p:=0 to (system_filecache_limit-1) do if not system_filecache_slot[p].init then
      begin
      result:=p;
      //.inc usecount
      filecache__inc_usecount(@system_filecache_slot[p]);
      //.stop
      break;
      end;
   end;

//oldest
if (result<0) then
   begin
   //.oldest with opencount=0
   if (result<0) then
      begin
      xms64:=0;
      for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and (system_filecache_slot[p].opencount<=0) and ((system_filecache_slot[p].time_idle<xms64) or (xms64<=0)) then
         begin
         xms64:=system_filecache_slot[p].time_idle;
         result:=p;
         end;
      end;
   //.oldest regardless of opencount
   if (result<0) then
      begin
      xms64:=0;
      for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and ((system_filecache_slot[p].time_idle<xms64) or (xms64<=0)) then
         begin
         xms64:=system_filecache_slot[p].time_idle;
         result:=p;
         end;
      end;
   //clear the slot
   if (result>=0) then filecache__closerec(@system_filecache_slot[result]);//auto increments the usecounter
   end;
except;end;

//emergency fallback - should never happen
if (result<0) then
   begin
   result:=0;
   //.inc usecount
   filecache__inc_usecount(@system_filecache_slot[result]);
   end;
end;
//## filecache__find ##
function filecache__find(x:string;xread,xwrite:boolean;var xslot:longint):boolean;//13apr2024: updated
var//xread=false and xwrite=false -> returns any record without matching the read/write values - 13apr2024
   p:longint;
   xref:comp;
begin
//defaults
result:=false;
xslot:=0;

//check
if (x='') then exit;

//find
xref:=low__ref256u(x);
for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and ((not xread) or system_filecache_slot[p].read) and ((not xwrite) or system_filecache_slot[p].write) and (xref=system_filecache_slot[p].filenameREF) and strmatch(x,system_filecache_slot[p].filename) then
   begin
   result:=true;
   xslot:=p;
   break;
   end;
end;
//## filecache__remfile ##
function filecache__remfile(x:string):boolean;
begin
//defaults
result:=false;
//check
if not filecache__safefilename(x) then exit;

//close cached files -> any open instances MUST be closed regardless
filecache__closeall_byname_rightnow(x);

//file not found -> ok
if not io__fileexists(x) then
   begin
   result:=true;
   exit;
   end;

//delete the file
try;io__filesetattr(x,0);except;end;
try;deletefile(pchar(x));except;end;

//return result
result:=not io__fileexists(x);
end;
//## filecache__openfile_anyORread ##
function filecache__openfile_anyORread(x:string;var v:pfilecache;var vmustclose:boolean;var e:string):boolean;
var
   i:longint;
begin
//defaults
result:=false;
v:=nil;
vmustclose:=false;
e:=gecTaskfailed;

//exists in cache -> ignore read and write values
if (not result) and filecache__find(x,false,false,i) then
   begin
   system_filecache_slot[i].time_idle:=filecache__idletime;//keep record alive
   v:=@system_filecache_slot[i];
   if (system_filecache_slot[i].opencount<maxint) then inc(system_filecache_slot[i].opencount);
   result:=true;
   end;

//open the file for reading
if (not result) then
   begin
   result:=filecache__openfile_read(x,v,e);
   if result then vmustclose:=true;
   end;
end;
//## filecache__openfile_read ##
function filecache__openfile_read(x:string;var v:pfilecache;var e:string):boolean;
label
   redo,skipend;
var
   h:thandle;
   i:longint;
   //## xopen_read ##
   function xopen_read:boolean;
   begin
   h:=win____createfile(pchar(x),generic_read,file_share_read or file_share_write,nil,open_existing,file_attribute_normal,0);
   if (h<=0) then h:=win____createfile(pchar(x),generic_read,file_share_read,nil,open_existing,file_attribute_normal,0);//fallback proc for readonly media -> in case it fails to open - 13apr2024
   result:=(h>=1);//13apr2024: updated
   end;
begin
//defaults
result:=false;
v:=nil;
e:=gecTaskfailed;

//check
if not filecache__safefilename(x) then
   begin
   e:=gecBadfilename;
   exit;
   end;

try
//exists in cache (read)
if (not result) and filecache__find(x,true,false,i) then
   begin
   system_filecache_slot[i].time_idle:=filecache__idletime;//keep record alive
   v:=@system_filecache_slot[i];
   if (system_filecache_slot[i].opencount<maxint) then inc(system_filecache_slot[i].opencount);
   result:=true;
   end;

//create cache entry
if (not result) and io__fileexists(x) then
   begin
   //.inc open count
   if (system_filecache_filecount<max64) then system_filecache_filecount:=add64(system_filecache_filecount,1) else system_filecache_filecount:=1;

   //.open for reading
   if not xopen_read then
      begin
      //.close and try again
      filecache__closeall_byname_rightnow(x);
      if not xopen_read then
         begin
         e:=gecFileinuse;
         goto skipend;
         end;
      end;

   //.file is open
   if (h>=1) then
      begin
      i:=filecache__newslot;
      v:=@system_filecache_slot[i];
      with system_filecache_slot[i] do
      begin
      init          :=true;
      opencount     :=1;
      filehandle    :=h;//set the filehandle
      filename      :=x;
      filenameREF   :=low__ref256u(x);
      time_created  :=ms64;
      time_idle     :=filecache__idletime;//keep record alive
      read          :=true;
      write         :=false;
      end;//with
      //successful
      result:=true;
      end;
   end;

skipend:
except;end;
end;
//## filecache__openfile_write ##
function filecache__openfile_write(x:string;var v:pfilecache;var e:string):boolean;
var
   bol1:boolean;
begin
result:=filecache__openfile_write2(x,false,bol1,v,e);
end;
//## filecache__openfile_write2 ##
function filecache__openfile_write2(x:string;xremfile_first:boolean;var xfilecreated:boolean;var v:pfilecache;var e:string):boolean;
label
   skipend;
var
   h:thandle;
   i:longint;
   //## xopen_write ##
   function xopen_write:boolean;
   var
      h2:thandle;
   begin
   //get
   case io__fileexists(x) of
   true :h:=win____createfile(pchar(x),generic_read or generic_write,file_share_read,nil,open_existing,file_attribute_normal,0);
   false:begin
      case io__makefolder(io__extractfilepath(x)) of//create folder
      false:begin
         h:=0;
         e:=gecPathnotfound;
         end;
      true:begin//create file
         h2:=win____createfile(pchar(x),generic_read or generic_write,0,nil,create_always,file_attribute_normal,0);
         if (h2>=1) then
            begin
            win____closehandle(h2);
//            h:=win____createfile(pchar(x),generic_read or generic_write,file_share_read,nil,open_existing,file_attribute_normal,0);
            h:=win____createfile(pchar(x),generic_read or generic_write,file_share_read,nil,open_existing,file_attribute_normal,0);
            if (h>=1) then xfilecreated:=true;
            end;
         end;
      end;//case
      end;
   end;//case
   //set
   result:=(h>=1);//updated 13apr2024
   end;
begin
//defaults
result:=false;
v:=nil;
e:=gecTaskfailed;
xfilecreated:=false;

//check
if not filecache__safefilename(x) then
   begin
   e:=gecBadfilename;
   exit;
   end;

try
//remfile_first
if xremfile_first and (not io__remfile(x)) then
   begin
   e:=gecFileinuse;
   goto skipend;
   end;

//exists in cache (write)
if (not result) and filecache__find(x,false,true,i) then
   begin
   system_filecache_slot[i].time_idle:=filecache__idletime;//keep record alive
   v:=@system_filecache_slot[i];
   if (system_filecache_slot[i].opencount<maxint) then inc(system_filecache_slot[i].opencount);
   result:=true;
   end;

//create cache entry
if (not result) then
   begin
   //.inc open count
   if (system_filecache_filecount<max64) then system_filecache_filecount:=add64(system_filecache_filecount,1) else system_filecache_filecount:=1;

   //.open for writing
   if not xopen_write then
      begin
      //.close and try again
      filecache__closeall_byname_rightnow(x);
      if not xopen_write then
         begin
         e:=gecFileinuse;
         goto skipend;
         end;
      end;

   //.file is open
   if (h>=1) then
      begin
      i:=filecache__newslot;
      v:=@system_filecache_slot[i];
      with system_filecache_slot[i] do
      begin
      init          :=true;
      opencount     :=1;
      filehandle    :=h;
      filename      :=x;
      filenameREF   :=low__ref256u(x);
      time_created  :=ms64;
      time_idle     :=filecache__idletime;//keep record alive
      read          :=true;
      write         :=true;
      end;//with
      //successful
      result:=true;
      end;
   end;

skipend:
except;end;
end;
//## filecache__managementevent ##
procedure filecache__managementevent;
var
   xcount,xactive,p:longint;
   xms64:comp;
begin
//defaults
xcount:=0;
xactive:=0;
//get
if msok(system_filecache_timer) then
   begin
   try
   //init
   xms64:=ms64;
   //get
   for p:=0 to (system_filecache_limit-1) do
   begin
   if system_filecache_slot[p].init then
      begin
      case (system_filecache_slot[p].opencount<=0) and (system_filecache_slot[p].time_idle<>0) and (xms64>system_filecache_slot[p].time_idle) of
      true:filecache__closerec(@system_filecache_slot[p]);//close record
      false:begin
         xcount:=p+1;//upper boundary as defined by the highest active slot
         inc(xactive);//simply the number of slots open regardless of their position within the system pool
         end;
      end;//case
      end;//if
   end;//p
   except;end;
   //sync information vars
   system_filecache_count:=xcount;
   system_filecache_active:=xactive;
   //reset timer
   msset(system_filecache_timer,5000);
   end;//if
end;

//nav procs --------------------------------------------------------------------
function nav__count(x:tstr8):longint;//28dec2023
var
   xnavcount,xfoldercount,xfilecount:longint;
begin
result:=0;try;nav__info(x,xnavcount,xfoldercount,xfilecount,result);except;end;
end;

function nav__info(x:tstr8;var xnavcount,xfoldercount,xfilecount,xtotalcount:longint):boolean;
var
   cmp1,cmp2:comp;
   xtep:longint;
   str1,str2:string;
begin
//defaults
result:=false;

try
xnavcount    :=0;
xfoldercount :=0;
xfilecount   :=0;
xtotalcount  :=0;
//get
result:=nav__proc(x,'info',0,xnavcount,xtep,xfoldercount,xfilecount,xtotalcount,cmp1,cmp2,str1,str2);
except;end;
try
if not result then
   begin
   xnavcount    :=0;
   xfoldercount :=0;
   xfilecount   :=0;
   xtotalcount  :=0;
   end;
except;end;
end;

function nav__can(x:tstr8;var xsortname,xsortsize,xsortdate,xsorttype:boolean):boolean;
var
   xtep,int1,int2,int3,int4:longint;
   cmp1,cmp2:comp;
   str1,str2:string;
begin
//defaults
result:=false;

try
xsortname    :=false;
xsortsize    :=false;
xsortdate    :=false;
xsorttype    :=false;;
//get
result:=nav__proc(x,'can',0,int1,xtep,int2,int3,int4,cmp1,cmp2,str1,str2);
if result then
   begin
   xsortname    :=(int1=1);
   xsortsize    :=(int2=1);
   xsortdate    :=(int3=1);
   xsorttype    :=(int4=1);
   end;
except;end;
end;

function nav__init(x:tstr8):boolean;
var
   xtep,int1,int2,int3,int4:longint;
   cmp1,cmp2:comp;
   str1,str2:string;
begin
result:=false;try;result:=nav__proc(x,'init',0,int1,xtep,int2,int3,int4,cmp1,cmp2,str1,str2);except;end;
end;

function nav__add(x:tstr8;xstyle,xtep:longint;xsize:comp;xname,xlabel:string):boolean;
begin
result:=false;try;result:=nav__add2(x,xstyle,xtep,xsize,2000,1,1,0,0,0,xname,xlabel);except;end;
end;

function nav__add2(x:tstr8;xstyle,xtep:longint;xsize:comp;xyear,xmonth,xday,xhr,xmin,xsec:longint;xname,xlabel:string):boolean;
var
   a:tcmp8;
   int1,int2,int3:longint;
begin
//defaults
result:=false;

try
//range
xyear:=frcrange32(xyear,0,50000);
xmonth:=frcrange32(xmonth,1,12);
xday:=frcrange32(xday,1,31);
xhr:=frcrange32(xhr,0,23);
xmin:=frcrange32(xmin,0,59);
xsec:=frcrange32(xsec,0,59);
//encode time
a.ints[0]:= xsec + (xmin*60) + (xhr*3600);
//encode date
a.ints[1]:=xmonth + (xday*13) + (xyear*416);
//get
result:=nav__proc(x,'add',0,xstyle,xtep,int1,int2,int3,xsize,a.val,xname,xlabel);
except;end;
end;

function nav__sort(x:tstr8;xsortstyle:longint):boolean;
var
   xtep,int2,int3,int4:longint;
   cmp1,cmp2:comp;
   str1,str2:string;
begin
result:=false;try;result:=nav__proc(x,'sort',0,xsortstyle,xtep,int2,int3,int4,cmp1,cmp2,str1,str2);except;end;
end;

function nav__end(x:tstr8;xsortstyle:longint):boolean;
var
   xtep,int2,int3,int4:longint;
   cmp1,cmp2:comp;
   str1,str2:string;
begin
result:=false;try;result:=nav__proc(x,'end',0,xsortstyle,xtep,int2,int3,int4,cmp1,cmp2,str1,str2);except;end;
end;

function nav__get(x:tstr8;xindex:longint;var xstyle,xtep:longint;var xsize:comp;var xname,xlabel:string):boolean;
var
   xyear,xmonth,xday,xhr,xmin,xsec:longint;
begin
result:=false;try;result:=nav__get2(x,xindex,xstyle,xtep,xsize,xyear,xmonth,xday,xhr,xmin,xsec,xname,xlabel);except;end;
end;

function nav__get2(x:tstr8;xindex:longint;var xstyle,xtep:longint;var xsize:comp;var xyear,xmonth,xday,xhr,xmin,xsec:longint;var xname,xlabel:string):boolean;
var
   int2,int3,int4:longint;
   xdate:comp;
begin
//defaults
result:=false;

try
xname:='';
xlabel:='';
xstyle:=0;
xtep:=tepNone;
xsize:=0;
xyear:=2000;
xmonth:=1;
xday:=1;
xhr:=0;
xmin:=0;
xsec:=0;
int2:=0;
int3:=0;
int4:=0;
//get
result:=nav__proc(x,'get', xindex,xstyle,xtep,int2,int3,int4,xsize,xdate,xname,xlabel);
if result then nav__date(xdate,xyear,xmonth,xday,xhr,xmin,xsec);
except;end;
end;

function nav__date(sdate:comp;var xyear,xmonth,xday,xhr,xmin,xsec:longint):boolean;//01feb2024
var
   a:tcmp8;
   int1:longint;
begin
//defaults
result:=false;

try
xyear:=2000;
xmonth:=1;
xday:=1;
xhr:=0;
xmin:=0;
xsec:=0;
a.val:=sdate;

//decode time
int1:=a.ints[0];
//.hr
xhr:=frcrange32(int1 div 3600,0,23);
dec(int1,xhr*3600);
//.min
xmin:=frcrange32(int1 div 60,0,59);
dec(int1,xmin*60);
//.sec
xsec:=frcrange32(int1,0,59);

//decode date
int1:=a.ints[1];
//.year
xyear:=frcrange32(int1 div 416,0,50000);
dec(int1,xyear*416);
//.day
xday:=frcrange32(int1 div 13,1,31);
dec(int1,xday*13);
//.month
xmonth:=frcrange32(int1,1,12);

//successful
result:=true;
except;end;
end;

function nav__list(x:tstr8;xsortstyle:longint;xfolder,xmasklist,xemasklist:string;xnav,xfolders,xfiles:boolean):boolean;//04oct2020
begin
result:=false;try;result:=nav__list2(0,x,xsortstyle,xfolder,xmasklist,xemasklist,xnav,xfolders,xfiles);except;end;
end;

function nav__list2(xownerid:longint;x:tstr8;xsortstyle:longint;xfolder,xmasklist,xemasklist:string;xnav,xfolders,xfiles:boolean):boolean;//04oct2020
begin
result:=false;try;result:=nav__list3(xownerid,x,xsortstyle,xfolder,xmasklist,xemasklist,xnav,xfolders,xfiles,min64,max64,'');except;end;
end;

function nav__list3(xownerid:longint;x:tstr8;xsortstyle:longint;xfolder,xmasklist,xemasklist:string;xnav,xfolders,xfiles:boolean;xminsize,xmaxsize:comp;xminmax_emasklist:string):boolean;//26feb2024: Upgraded 32bit filesize to 64bit, 04oct2020
label
   skipend;
const
   xallfiles='*';
var
   p,i,xyear,xmonth,xday,xhr,xmin,xsec:longint;
   xsize:comp;
   xrec:tsearchrec;
   str1,str2:string;
   bol1,xfindopen:boolean;
   //## xrootnav ##
   procedure xrootnav;
   label
      skipend;
   var
      a:tdrivelist;
      p:longint;
      //## xadd ##
      function xadd(xtep:longint;n,nlabel:string):boolean;
      begin
      result:=nav__add2(x,nltSysfolder,xtep,0,0,0,0,0,0,0,n,nlabel);
      end;
      //## xaddfolder ##
      function xaddfolder(n,nlabel:string):boolean;
      var
         xtep:longint;
      begin
      xtep:=low__foldertep2(xownerid,n);
      result:=nav__add2(x,nltSysfolder,xtep,0,0,0,0,0,0,0,n,nlabel);
      end;
   begin
   //disk drives
   nav__add2(x,nltTitle,tepNone,0,0,0,0,0,0,0,'Drives','');
   a:=io__drivelist;
   for p:=0 to high(a) do if a[p] and (not xaddfolder(char(65+p)+':\',io__drivelabel(char(65+p),true))) then goto skipend;
   //if sysdisk_inuse then xaddfolder(sysdisk_char+':\',low__drivelabel(sysdisk_char,true));//04apr2021
   //system folders
   nav__add2(x,nltTitle,tepNone,0,0,0,0,0,0,0,'Special Folders','');
   xaddfolder(app__folder,'');
   xaddfolder(app__subfolder('Settings'),'');
   if io__folderexists(app__folder2('Backups',false)) then xaddfolder(app__subfolder('Backups'),'');//10feb2023
   xaddfolder(io__windesktop,'');
   xaddfolder(io__winstartmenu,'');
   xaddfolder(io__winprograms,'');
   xaddfolder(app__subfolder('temp'),'Portable Temp');//17may2022
   xaddfolder(io__wintemp,'Temp');
   //xaddfolder(wincommontemp,'Common Temp');//05apr2021
   skipend:
   end;
   //## xfindsize ##
   function xfindsize:boolean;//pass-thru - 26feb2024
   var
      c:tcmp8;
   begin
   result:=true;
   c.ints[0]:=xrec.finddata.nFileSizeLow;
   c.ints[1]:=xrec.finddata.nFileSizeHigh;
   xsize:=c.val;
   end;
   //## xfinddate2 ##
   procedure xfinddate2(a:tdatetime);
   var
      y,m,d,h,min,s,ms:word;
   begin
   low__decodedate2(a,y,m,d);
   low__decodetime2(a,h,min,s,ms);
   //set
   xyear   :=y;
   xmonth  :=m;
   xday    :=d;
   xhr     :=h;
   xmin    :=min;
   xsec    :=s;
   end;
   //## xfinddate ##
   procedure xfinddate;
   begin
   xfinddate2(io__fromfiletime(xrec.finddata.ftLastWriteTime));
   end;
begin
//defaults
result:=false;
i:=0;
xfindopen:=false;
low__cls(@xrec,sizeof(xrec));//28sep2020

try
str__lock(@x);
//check
if zznil(x,2183) then goto skipend;
//init
if not nav__init(x) then goto skipend;
if (not xfolders) and (not xfiles) then goto skipend;
if (xmasklist='') then xmasklist:=xallfiles;
//low__reloadfastvars;
//if (xownerid>=1) then tep__delall20(xownerid);//delete any previous images done by us - 06apr2021
if (xfolder='') then
   begin
   xrootnav;
   result:=true;
   goto skipend;
   end
else xfolder:=io__asfolder(xfolder);//28sep2020

//hack check
if io__hack_dangerous_filepath_allow_mask(xfolder) then goto skipend;
//get
//.top title -> leave empty -> host can fill it with information in realtime - 04oct2020
if xnav and xfolders and xfiles then
   begin
   nav__add2(x,nltTitle,tepNone,0,0,0,0,0,0,0,'','');
   end;

//.add nav ---------------------------------------------------------------------
if xnav then
   begin
   //.home
   if not nav__add2(x,nltNav,tepNone,0,0,0,0,0,0,0,'','') then goto skipend;//"Home"
   //.nav sets
   bol1:=true;
   for p:=1 to length(xfolder) do if (xfolder[p-1+stroffset]='\') or (xfolder[p-1+stroffset]='/') then
      begin
      str1:=strcopy1(xfolder,1,p);
      if bol1 then
         begin
         bol1:=false;
         str2:=io__drivelabel(str1,true);//show drive label for first item in nav list
         end
      else str2:='';
      if (str1<>'') and (not nav__add2(x,nltNav,low__foldertep2(xownerid,str1),0,0,0,0,0,0,0,str1,str2)) then goto skipend;
      end;
   end;

//.open
case xfolders of
true: i:=win__findfirst(xfolder+xallfiles,faReadOnly or faHidden or faSysFile or faDirectory or faArchive or faAnyFile,xrec);
false:i:=win__findfirst(xfolder+xallfiles,faReadOnly or faHidden or faSysFile or faArchive or faAnyFile,xrec);
end;//end of case
xfindopen:=(i=0);
while i=0 do
begin
//.skip system folders
if (xrec.name='.') or (xrec.name='..') then
   begin
   //nil
   end
//.add folder ------------------------------------------------------------------
else if io__faISfolder(xrec.attr) then
   begin
   if xfolders then
      begin
      //init
      xfindsize;
      xfinddate;
      //get
      if not nav__add2(x,nltFolder,low__foldertep2(xownerid,io__asfoldernil(xfolder+xrec.name)),xsize,xyear,xmonth,xday,xhr,xmin,xsec,xrec.name,'') then goto skipend;
      end;
   end
//.add file --------------------------------------------------------------------
else
   begin
   if xfiles and xfindsize and (((xsize>=xminsize) and (xsize<=xmaxsize)) or low__matchmasklistb(xrec.name,xminmax_emasklist)) and ( low__matchmasklistb(xrec.name,xmasklist) and ((xemasklist='') or (not low__matchmasklistb(xrec.name,xemasklist))) ) then
      begin
      //init
      xfindsize;
      xfinddate;
      //get
      if not nav__add2(x,nltFile,tepext(xrec.name),xsize,xyear,xmonth,xday,xhr,xmin,xsec,xrec.name,'') then goto skipend;
      end;
   end;
//.inc
i:=win__findnext(xrec);
end;//while
//successful
result:=true;
skipend:
except;end;
try;if xfindopen then win__findclose(xrec);except;end;
try
nav__end(x,xsortstyle);//finalise
str__uaf(@x);
except;end;
end;

function nav__proc(x:tstr8;xcmd:string;xindex:longint;var xstyle,xtep,xval1,xval2,xval3:longint;var xsize,xdate:comp;var xname,xlabel:string):boolean;//04apr2021, 25mar2021, 20feb2021
label
   skipend,skipdone;
const
   xmorespace    =500000;
   xhdrlen       =24;
   xdatasetsize  =25;//min.size - 06apr2021
   //counters
   xnavpos       =8;
   xfolderpos    =12;
   xfilepos      =16;
   xsortpos      =20;
var
   xnamelen,xlabellen,v1,v2,v3,p,int1,int2,int3,int4,int5,xcount:longint;
   //## xlen ##
   function xlen:longint;
   begin
   result:=0;
   if zzok(x,7024) then result:=x.int4[4];
   if (result>x.datalen) then result:=x.datalen;
   end;
   //## xsetlen ##
   procedure xsetlen(xval:longint);
   begin
   if zzok(x,7025) then x.int4[4]:=frcmin32(xval,xhdrlen);
   end;
   //## xinfo ##
   procedure xinfo(var xnavcount,xfoldercount,xfilecount,xtotalcount:longint);
   begin
   xnavcount:=frcmin32(x.int4[xnavpos],0);//nav.count
   xfoldercount:=frcmin32(x.int4[xfolderpos],0);//folder.count
   xfilecount:=frcmin32(x.int4[xfilepos],0);//file.count
   xtotalcount:=xnavcount+xfoldercount+xfilecount;//total.count
   end;
   //## xsort ##
   function xsort(xsortstyle:longint):boolean;
   label//Note: Uses "nav__proc.int1"
      skipend;
   var
      v1,v2,v3,xcount,int2,int3,di,xfastlen:longint;
      a:tstr8;
      alist:pdllongint;
      //## xfindstyle ##
      function xfindstyle(xpos:longint;var xstyle:longint):boolean;
      var
         dlen:longint;
      begin
      //defaults
      result:=false;
      xstyle:=nltNav;
      //check dataset size
      if (xpos<0) or ((xpos+4)>xfastlen) then exit;
      dlen:=frcmin32(x.int4[xpos],0);
      if (dlen<xdatasetsize) or ((xpos+dlen)>xfastlen) then exit;
      //read dataset
      inc(xpos,4);
      xstyle:=frcrange32(x.byt1[xpos],0,nltMax);
      //successful
      result:=true;
      end;
      //## xfindvals ##
      function xfindvals(xpos:longint;var xstyle,xtep:longint;var xsize,xdate:comp;var xname,xlabel:string):boolean;
      var
         xnamelen,xlabellen,nlen,dlen:longint;
      begin
      //defaults
      result:=false;
      xstyle:=nltNav;
      xtep:=tepNone;
      xsize:=0;
      xdate:=0;
      xname:='';
      xlabel:='';
      //check dataset size
      if (xpos<0) or ((xpos+4)>xfastlen) then exit;
      dlen:=frcmin32(x.int4[xpos],0);
      if (dlen<xdatasetsize) or ((xpos+dlen)>xfastlen) then exit;
      //read dataset
      inc(xpos,4);
      xstyle:=frcrange32(x.byt1[xpos],0,nltMax); inc(xpos,1);
      xtep  :=x.int4[xpos]; inc(xpos,4);//06apr2021
      xsize :=x.cmp8[xpos]; inc(xpos,8);
      xdate :=x.cmp8[xpos]; inc(xpos,8);
      //namelen+name+label - 04apr2021
      nlen:=dlen-xdatasetsize;
      if (nlen>=1) then
         begin
         //namelen
         xnamelen:=frcmin32(x.int4[xpos],0);
         inc(xpos,4);
         //name
         if (xnamelen>=1) then
            begin
            xname:=x.str[xpos,xnamelen];//zero-based
            inc(xpos,xnamelen);
            end;
         //label
         xlabellen:=nlen-4-xnamelen;
         if (xlabellen>=1) then
            begin
            xlabel:=x.str[xpos,xlabellen];//zero-based
            //inc(xpos,xlabellen);
            end;
         end;
      //successful
      result:=true;
      end;
      //## xrev ##
      procedure xrev(s:tstr8);//25mar2021
      var
         d:tstr8;
         slist,dlist:pdllongint;
         xstyle,scount,p:Longint;
      begin
      try
      //defaults
      d:=nil;
      scount:=0;
      //check
      if (xcount<=0) or zznil(s,2185) then exit;
      //init
      d:=bnewlen(xcount*4);
      dlist:=d.pints4;
      slist:=s.pints4;
      //fill
      for p:=0 to (xcount-1) do dlist[p]:=slist[p];
      //write back to "s"
      //.nav - always at top -> never sort this
      for p:=0 to (xcount-1) do if xfindstyle(dlist[p],xstyle) and ((xstyle=nltNav) or (xstyle=nltSysfolder) or (xstyle=nltTitle)) then//nltTitle=25mar2021
         begin
         if (scount>=xcount) then break;
         slist[scount]:=dlist[p];
         inc(scount);
         end;
      //.all other items
      for p:=(xcount-1) downto 0 do if xfindstyle(dlist[p],xstyle) and (xstyle<>nltNav) and (xstyle<>nltSysFolder) and (xstyle<>nltTitle) then//nltTitle=25mar2021
         begin
         if (scount>=xcount) then break;
         slist[scount]:=dlist[p];
         inc(scount);
         end;
      except;end;
      try;str__free(@d);except;end;
      end;
      //## xdatestr ##
      function xdatestr(v:comp):string;
      var
         a:tcmp8;
         int1,xhr,xmin,xsec,xyear,xmonth,xday:longint;
      begin
      try
      //defaults
      result:='';
      //init
      a.val:=v;
      //decode time
      int1:=a.ints[0];
      //.hr
      xhr:=frcrange32(int1 div 3600,0,23);
      dec(int1,xhr*3600);
      //.min
      xmin:=frcrange32(int1 div 60,0,59);
      dec(int1,xmin*60);
      //.sec
      xsec:=frcrange32(int1,0,59);

      //decode date
      int1:=a.ints[1];
      //.year
      xyear:=frcrange32(int1 div 416,0,50000);
      dec(int1,xyear*416);
      //.day
      xday:=frcrange32(int1 div 13,1,31);
      dec(int1,xday*13);
      //.month
      xmonth:=frcrange32(int1,1,12);

      //get -> yyyyMMddHHmmSS - 01oct2020
      result:=low__digpad11(xyear,4)+low__digpad11(xmonth,2)+low__digpad11(xday,2)+low__digpad11(xhr,2)+low__digpad11(xmin,2)+low__digpad11(xsec,2);
      except;end;
      end;
      //## xsortname ##
      procedure xsortname(s:tstr8;ssortstyle:longint);
      label
         skipend;
      var
         a,d:tstr8;
         c:tdynamicstring;
         alist,slist,dlist:pdllongint;
         xstyle,xtep,acount,scount,p:longint;
         xsize,xdate:comp;
         xval:string;
         bol1,srev:boolean;
      begin
      int1:=0;

      try
      //defaults
      a:=nil;
      d:=nil;
      c:=nil;
      scount:=0;
      //check
      if (xcount<=0) or zznil(s,2186) then exit;
      //init
      srev:=(ssortstyle=nlAsisD) or (ssortstyle=nlNameD) or (ssortstyle=nlSizeD) or (ssortstyle=nlDateD) or (ssortstyle=nlTypeD);
      //.asis
      if (ssortstyle=nlAsis) or (ssortstyle=nlAsisD) then
         begin
         if srev then xrev(s);
         goto skipend;
         end;
      a:=bnewlen(xcount*4);
      d:=bnewlen(xcount*4);
      alist:=a.pints4;
      dlist:=d.pints4;
      slist:=s.pints4;
      c:=tdynamicstring.create;
      //fill
      for p:=0 to (xcount-1) do dlist[p]:=slist[p];

      //nav - always at top -> never sort this
      for p:=0 to (xcount-1) do if xfindstyle(dlist[p],xstyle) and ((xstyle=nltNav) or (xstyle=nltSysfolder) or (xstyle=nltTitle)) then
         begin
         if (scount>=xcount) then break;
         slist[scount]:=dlist[p];
         inc(scount);
         end;

      //folders
      c.clear;
      acount:=0;
      for p:=0 to (xcount-1) do if xfindvals(dlist[p],xstyle,xtep,xsize,xdate,xname,xlabel) and (xstyle=nltFolder) then
         begin
         if (acount>=xcount) then break;
         alist[acount]:=dlist[p];
         c.value[acount]:=strlow(xname);
         inc(acount);
         end;
      //.sort
      if (acount>=1) then
         begin
         c.sort(true);
         if (ssortstyle=nlName) or (ssortstyle=nlNameD) then bol1:=srev else bol1:=false;
         //.write back
         for p:=0 to (acount-1) do
         begin
         if (scount>=xcount) then break;
         case bol1 of
         false:slist[scount]:=alist[c.sindex(p)];
         true:slist[scount]:=alist[c.sindex(acount-1-p)];
         end;
         inc(scount);
         end;//p
         end;

      //files
      c.clear;
      acount:=0;
      for p:=0 to (xcount-1) do if xfindvals(dlist[p],xstyle,xtep,xsize,xdate,xname,xlabel) and (xstyle=nltFile) then
         begin
         case ssortstyle of
         nlName,nlNameD:xval:=strlow(xname);
         nlSize,nlSizeD:xval:=low__digpad20(xsize,20)+'|'+strlow(xname);
         nlDate,nlDateD:xval:=xdatestr(xdate)+'|'+strlow(xname);
         nlType,nlTypeD:xval:=io__readfileext(xname,true)+'|'+strlow(xname);
         end;
         if (acount>=xcount) then break;
         alist[acount]:=dlist[p];
         c.value[acount]:=xval;
         inc(acount);
         end;
      //.sort
      if (acount>=1) then
         begin
         c.sort(true);
         //.write back
         for p:=0 to (acount-1) do
         begin
         if (scount>=xcount) then break;
         case srev of
         false:slist[scount]:=alist[c.sindex(p)];
         true:slist[scount]:=alist[c.sindex(acount-1-p)];
         end;
         inc(scount);
         end;//p
         end;
      skipend:
      except;end;
      try
      str__free(@a );
      str__free(@d);
      freeobj(@c);
      except;end;
      end;
   begin
   //defaults
   result:=false;
   try
   a:=nil;
   //init
   xinfo(v1,v2,v3,xcount);//totalcount => number of items in EACH sort.list
   a:=bnewlen(xcount*4);//pre-size list for ultra-fast access
   alist:=a.pints4;
   xfastlen:=xlen;

   //get -> "nlAsis" is default sortstyle - 01oct2020
   int2:=xhdrlen;
   //note: int1 is set to "xlen" by calling proc - 26apr2021
   di:=0;
   while true do
   begin
   if ((int2+4)<=int1) then
      begin
      int3:=x.int4[int2];//read dataset.size
      if (int3<xdatasetsize) then break;//dataset.size is always 25..N bytes
      if (di<xcount) then alist[di]:=int2 else break;
      inc(di);
      inc(int2,int3);
      end
   else break;
   end;//while
   //sort
   xsortname(a,xsortstyle);

   //store
   x.int4[xsortpos]:=int2;
   x.owr(a,int2);
   xsetlen(int2+(xcount*4));//set datasize to actual size of data now - 25sep2020
   //successful
   result:=true;
   skipend:
   except;end;
   try;str__free(@a);except;end;
   end;
begin
//defaults
result:=false;
try
str__lock(@x);
//check
if zznil(x,2187) then goto skipend;
//init
xcmd:=strlow(xcmd);
if (xcmd='init') then
   begin
   x.clear;
   x.aadd([70,108,116,49]);//"Flt1" - 0..3 -> note uppercase "F" denotes structure is in edit mode -> there are no quick lookup sort.lists present yet -> 25sep2020
   x.addint4(xhdrlen);//overall data size - 4..7 -> used for building data structure - 25sep2020
   x.addint4(0);//nav.count - 8..11
   x.addint4(0);//folder.count - 12..15
   x.addint4(0);//file.count - 16..19
   x.addint4(0);//sortlist.pos - 20..23
   goto skipdone;
   end;
//check
if (x.len<xhdrlen) then goto skipend;
//get
if      (xcmd='end') then
   begin
   //already finished -> "flt1"
   if x.asame([102,108,116,49]) then goto skipdone;
   //need to finish -> "Flt1" -> "flt1"
   if not x.asame([70,108,116,49]) then goto skipend;
   //init
   int1:=xlen;
   if (int1<xhdrlen) then goto skipend;
   if (int1<>x.len) then x.setlen(int1);//finalise size -> safe to append data now
   //finish
   xsetlen(x.len);//set datasize to actual size of data now - 25sep2020
   x.pbytes[0]:=llf;//change "F" to "f" -> marks structure as finished -> can "get" now - 25sep2020
   //sort
   int1:=xlen;//26apr2021
   xsort(xstyle);//fixed 20feb2021
   end
else if (xcmd='sort') then
   begin
   int1:=xlen;//26apr2021
   xsort(xstyle)//fixed 20feb2021
   end
else if (xcmd='info') then xinfo(xstyle,xval1,xval2,xval3)
else if (xcmd='add') then
   begin
   //init
   xnamelen:=length(xname);
   xlabellen:=length(xlabel);
   int1:=xlen;
   int2:=4+xnamelen+xlabellen;
   x.minlen(int1+xdatasetsize+int2+xmorespace);
   //range
   xstyle:=frcrange32(xstyle,0,nltMax);//0=nav, 1=folder, 2=file, 3=full folder (full path -> special folder, system folder etc)
   xsize:=frcmin64(xsize,0);
   //get
   x.int4[int1]:=xdatasetsize+int2;
   inc(int1,4);//dataset.size -> 22+name.len
   x.byt1[int1]:=xstyle;  inc(int1,1);
   x.int4[int1]:=xtep;    inc(int1,4);//06apr2021
   x.cmp8[int1]:=xsize;   inc(int1,8);
   x.cmp8[int1]:=xdate;   inc(int1,8);
   //.name+label - 04apr2021
   if (int2>=1) then
      begin
      //.namelen
      x.int4[int1]:=xnamelen;
      inc(int1,4);
      //.name
      for p:=0 to (xnamelen-1) do x.pbytes[int1+p]:=byte(xname[p+stroffset]);//zero-base string copy 0 25sep2020
      inc(int1,xnamelen);
      //.label
      for p:=0 to (xlabellen-1) do x.pbytes[int1+p]:=byte(xlabel[p+stroffset]);//zero-base string copy 0 25sep2020
      inc(int1,xlabellen);
      end;
   //set
   xsetlen(int1);
   //inc counters
   case xstyle of
   nltNav,nltTitle:         x.int4[xnavpos]   :=x.int4[xnavpos]+1;
   nltFolder,nltSysFolder:  x.int4[xfolderpos]:=x.int4[xfolderpos]+1;
   nltFile:                 x.int4[xfilepos]  :=x.int4[xfilepos]+1;
   end;//case
   end
else if (xcmd='get') then
   begin
   //check
   if not x.asame([102,108,116,49]) then goto skipend;//must be "flt1" -> init->add's->end
   //init
   int1:=frcmax32(xlen,x.len);
   xstyle:=nltNav;
   xval1:=0;
   xval2:=0;
   xval3:=0;
   xsize:=0;
   xdate:=0;
   xname:='';
   xlabel:='';
   xinfo(v1,v2,v3,xcount);//totalcount => number of items in EACH sort.list

   //check
   if (xindex<0) or (xindex>=xcount) then goto skipend;
   //use sortlist
   int2:=x.int4[xsortpos];
   if (int2<=0) then goto skipend;
   //.inc to sort.list postion requested by "xindex"
   inc(int2,(xindex*4));//ascending order

   //dataset.pos
   if (int2>=0) and ((int2+4)<=int1) then int3:=x.int4[int2] else goto skipend;

   //check dataset size
   if (int3<0) or ((int3+4)>int1) then goto skipend;
   int4:=frcmin32(x.int4[int3],0);
   if (int4<xdatasetsize) or ((int3+int4)>int1) then goto skipend;

   //read dataset
   inc(int3,4);
   xstyle:=frcrange32(x.byt1[int3],0,nltMax); inc(int3,1);//28sep2020
   xtep  :=x.int4[int3]; inc(int3,4);//06apr2021
   xsize :=x.cmp8[int3]; inc(int3,8);
   xdate :=x.cmp8[int3]; inc(int3,8);
   int5:=int4-xdatasetsize;
   //.xnamelen+xname+xlabel - 04apr2021
   if (int5>=1) then
      begin
      //namelen
      xnamelen:=frcmin32(x.int4[int3],0);
      inc(int3,4);
      //name
      if (xnamelen>=1) then
         begin
         xname:=x.str[int3,xnamelen];//zero-based
         inc(int3,xnamelen);
         end;
      //label
      xlabellen:=int5-4-xnamelen;
      if (xlabellen>=1) then
         begin
         xlabel:=x.str[int3,xlabellen];//zero-based
         //inc(int3,xlabellen);
         end;
      end;//int5
   end
else goto skipend;

//successful
skipdone:
result:=true;
skipend:
except;end;
try
if not result then
   begin
   xstyle:=0;
   xtep:=tepNone;//06apr2021
   xval1:=0;
   xval2:=0;
   xval3:=0;
   xsize:=0;
   xdate:=0;
   xname:='';
   end;
except;end;
try
str__uaf(@x);
except;end;
end;

end.
