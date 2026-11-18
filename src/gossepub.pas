unit gossepub;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, gossdoc, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps;
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
//## Library.................. EPUB generator (gossepub.pas)
//## Version.................. 1.00.3800 (+0)
//## Items.................... 1
//## Last Updated ............ 16nov2026, 15nov2026, 14nov2026, 13nov2026, 12nov2026, 11nov2026, 03nov2026, 02nov2026, 01nov2026, 31oct2026, 25oct2026, 23oct2026, 22oct2026, 20oct2026, 19oct2026, 18oct2026, 17oct2026, 16oct2026, 15oct2026
//## Lines of Code............ 8,100+
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
//## | epub__*                | family of procs   | 1.00.3800 | 16nov2026   | EPUB v2/v3 generator - 14nov2026, 13nov2026, 12nov2026, 11nov2026, 01nov2026, 31oct2026, 18oct2026, 17oct2026, 16oct2026, 15oct2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================
//##
//## EPUB output formmating verified for these e-readers:
//## 1) Kindle Previewer 4
//## 2) Koodo Reader 2.4.6
//## 3) Adobe Digital Editions 4.5.11
//## 4) Thorium 3.5.1
//## 5) Calibre 6.21
//## 6) Readest 0.12.16
//##
//## ==========================================================================================================================================================================================================================

const
   pub_filelimit                =8000;
   pub_utf8                     ='utf-8';
   pub_buildOK                  ='Built';
   pub_buildFailed              ='Build Error: ';
   pub_returnCode               =#13#10;
   pub_space160                 =#160;
   pub_buildSummary             ='-- Build Summary --';
   pub_docFiles                 ='-- Document Files --';
   pub_docMask                  ='*.txt;*.bwd;*.bwp;*.rtf';
   pub_docEMask                 ='.__recent.txt;';
   pub_OEBPS                    ='OEBPS/';
   pub_preprocessingScanLen     =1000;

   pub_firstName_def            ='Unknown';
   pub_lastName_def             ='Author';

   pub_fileMarker               ='file:';
   pub_fileMarkerOK             ='file(OK):';
   pub_fileMarkerNotFound       ='file(Not Found):';

   pub_labelFrontCover          ='Front Cover';//7-bit ascii
   pub_labelTableOfContents     ='Contents';   //7-bit ascii

   pub_scanForCoverInDocLen     =300;//first 300 characters

   //.codes supports
   pub_codesstart1              =ssLSquarebracket;//[
   pub_codesstop1               =ssRSquarebracket;//]
   pub_codesstart               ='[[[@';
   pub_codesstop                =']]]';
   pub_codesFormat              ='f1';//chapter formatting
   pub_codesNoFormat            ='f0';//plain formatting
   pub_codesHeading             ='h1';//include heading
   pub_codesNoHeading           ='h0';//exclude heading
   pub_codesBlankline           ='b1';//permit blank lines
   pub_codesNoBlankline         ='b0';//exclude blank lines
   pub_codesChapter1            ='c1';//mark as chapter one (once only)
   pub_codesSplit               ='s';//split document
   pub_codesSep1                =',';
   pub_codesSep2                =#32;

   pub_codelist_ChapterFormatting         =pub_codesFormat   + pub_codesSep1;
   pub_codelist_PlainFormatting           =pub_codesNoFormat + pub_codesSep1;

   //.other
   pub_epubVersion_min          =2;//EPUB 2
   pub_epubVersion_max          =3;//EPUB 3
   pub_epubVersion_def          =3;
   
   pub_headerSize_min           =100;
   pub_headerSize_max           =1200;
   pub_headerSize_def           =280;

   pub_headerAlign_min          =0;
   pub_headerAlign_max          =2;//0=left, 1=center, 2=right
   pub_headerAlign_def          =1;

   pub_headerAbove_min          =0;
   pub_headerAbove_max          =1200;//0-1,200 (12x)
   pub_headerAbove_def          =400;

   pub_headerBelow_min          =0;
   pub_headerBelow_max          =1200;//0-1,200 (12x)
   pub_headerBelow_def          =100;

   pub_textSize_min             =50;
   pub_textSize_max             =1200;
   pub_textSize_def             =100;

   pub_textJustify_min          =0;
   pub_textJustify_max          =1;
   pub_textJustify_def          =1;

   pub_lineHeight_min           =80;
   pub_lineHeight_max           =500;
   pub_lineHeight_def           =150;

   pub_autoSplit_min            =0;
   pub_autoSplit_max            =6;//0=off, 1=2, 2=3, 3=4, 4=5, 5=6, 6=7
   pub_autoSplit_def            =3;

   pub_dropcaps_min             =0;
   pub_dropcaps_max             =7;
   pub_dropcaps_def             =2;

   pub_indentChars_min          =-20;
   pub_indentChars_max          =20;
   pub_indentChars_def          =4;

   pub_blankLine_min            =0;
   pub_blankLine_max            =500;
   pub_blankLine_def            =50;//11nov2026

   pub_sceneSep_min             =0;
   pub_sceneSep_max             =22;
   pub_sceneSep_def             =9;//3 love hearts

   pub_quotesSingle_min         =0;
   pub_quotesSingle_max         =2;
   pub_quotesSingle_def         =2;

   pub_quotesDouble_min         =0;
   pub_quotesDouble_max         =2;
   pub_quotesDouble_def         =2;

   pub_formatUp_min             =0;
   pub_formatUp_max             =1;
   pub_formatUp_def             =1;

   pub_imageQuality_min         =0;
   pub_imageQuality_max         =5;
   pub_imageQuality_def         =5;

   pub_coverQuality_min         =0;
   pub_coverQuality_max         =4;
   pub_coverQuality_def         =2;//good quality

   pub_minCoverWidth            =1400;//Apple requires at least this width at 1.5:1 or 1.6:1 ratio - sourced from https://mcwriting.com/2022/05/26/what-size-should-an-ebook-cover-be/ - 21oct2026
   pub_maxWidth                 =1400;
   pub_maxHeight                =2100;

   pub_dropCapsStart            ='<span class="';
   pub_dropCapsStop             ='</span>';

   //file format types
   pub_fNone                    =0;
   pub_fText                    =1;
   pub_fImage                   =2;

   //image storage types
   pub_isImageData              =0;
   pub_isImageCover             =1;
   pub_isImageAsDoc             =2;

   //doc type
   pub_none                     =0;
   pub_html                     =1;
   pub_xhtml                    =2;
   pub_image                    =3;
   pub_titlePage                =4;
   pub_coverjpg                 =5;
   pub_contentshtml             =6;
   pub_styleSheetcss            =7;
   pub_contentopf               =8;
   pub_tocncx                   =9;
   pub_TOCxhtml                 =10;//v3 only
   pub_svg                      =11;
   

   //char commands
   pub_blankLine                =-1;
   pub_startLineHeader          =-2;

   pub_startLineIndentL         =-3;
   pub_startLineIndentC         =-4;
   pub_startLineIndentR         =-5;
   pub_startLineL               =-6;
   pub_startLineC               =-7;
   pub_startLineR               =-8;

   pub_stopline                 =-9;
   pub_stopLineHeader           =-10;
   pub_sceneSep                 =-11;
   pub_skip                     =-12;

   pub_startDropCapOne          =-13;
   pub_startDropCaps            =-14;
   pub_stopDropCaps             =-15;

   pub_unusedChar               =31;
   pub_sceneSep0                =30;


type

   ppubinfo                     =^tpubinfo;
   tpubinfo                     =record

    style                       :array[0..pred(pub_filelimit)] of byte;//0=text ,1=image
    nref                        :array[0..pred(pub_filelimit)] of longint32;
    nval                        :array[0..pred(pub_filelimit)] of longint32;
    name                        :array[0..pred(pub_filelimit)] of string;
    next                        :array[0..pred(pub_filelimit)] of string;//uppercase file extension
    data                        :array[0..pred(pub_filelimit)] of string;
    dataLen                     :array[0..pred(pub_filelimit)] of longint32;
    refdata                     :array[0..pred(pub_filelimit)] of string;
    refdataLen                  :array[0..pred(pub_filelimit)] of longint32;
    w                           :array[0..pred(pub_filelimit)] of longint32;
    h                           :array[0..pred(pub_filelimit)] of longint32;
    format                      :array[0..pred(pub_filelimit)] of string;
    headingU8                   :array[0..pred(pub_filelimit)] of string;//for contents link in utf-8
    svgUsed                     :array[0..pred(pub_filelimit)] of boolean;//16nov2026
    headingUntitledCount        :longint32;
    count                       :longint32;
    count_text                  :longint32;
    count_image                 :longint32;
    count_svg                   :longint32;
    buildFile                   :string;
    buildFolder                 :string;
    outputFilename              :string;

    //.internal data support
    internaldataMode            :boolean;
    internaldata                :tstr8;//internal data - 12nov2026

    //book info
    title                       :string;
    fname                       :string;
    lname                       :string;
    authorWebsite               :string;//v3
    releaseAuto                 :boolean;
    year                        :longint32;
    month                       :longint32;
    day                         :longint32;
    hour                        :longint32;
    minute                      :longint32;
    second                      :longint32;
    rights                      :string;
    subject1                    :string;
    subject2                    :string;
    subject3                    :string;
    subject4                    :string;
    subject5                    :string;

    bisacLabel1                 :string;
    bisacCode1                  :string;
    bisacLabel2                 :string;
    bisacCode2                  :string;
    bisacLabel3                 :string;
    bisacCode3                  :string;

    themaLabel1                 :string;
    themaCode1                  :string;
    themaLabel2                 :string;
    themaCode2                  :string;
    themaLabel3                 :string;
    themaCode3                  :string;

    des                         :string;
    publisher                   :string;
    publisherUrl                :string;
    isbn                        :string;
    firstChapterIndex           :longint32;//optional
    codeCount                   :longint32;//optional

    //.ids
    dMasterID                   :string;
    dMasterIDname               :string;
    duuid                       :string;
    disbn                       :string;

    //system file reference
    slot_contentsHtml           :longint32;
    slot_contentsOpf            :longint32;
    slot_titlepageXhtml         :longint32;
    slot_tocNcx                 :longint32;
    slot_stylesheetcss          :longint32;
    slot_TOCxhtml               :longint32;

    //build options
    epubVersion                 :longint32;
    headerSize                  :longint32;//10-1200%
    headerAlign                 :longint32;
    headerAbove                 :longint32;
    headerBelow                 :longint32;
    headerAbovePlain            :longint32;
    headerBelowPlain            :longint32;
    textsize                    :longint32;//10-1200%
    textJustify                 :longint32;
    lineHeight                  :longint32;//100-500%

    indentchars                 :longint32;
    indentFirst                 :longint32;
    dropcaps                    :longint32;
    blankLine                   :longint32;
    sceneSep                    :longint32;
    sceneSepCustom8             :string;
    formatUp                    :longint32;
    quotesSingle                :longint32;
    quotesDouble                :longint32;

    imageQuality                :longint32;
    coverQuality                :longint32;
    
    destCoverWidth              :longint32;

    autoSplit                   :longint32;//number of blank lines required to auto. split chapter/section
    dautoSplit                  :longint32;

    //strings
    firstError                  :string;
    docHeading                  :string;//11nov2026
    sepIsSVG                    :boolean;
    docUsedSVG                  :boolean;
    headersizeStr               :string;
    textsizeStr                 :string;
    lineheightStr               :string;
    docXMLencodingStr           :string;
    docTypeStr                  :string;
    docMetaStr                  :string;
    dcoverQuality               :string;
    dimageQuality               :string;

    blankLineStr8               :string;

    startLineHeaderStrPlain8    :string;
     stopLineHeaderStrPlain8    :string;

    startLineHeaderStrChapter8  :string;
     stopLineHeaderStrChapter8  :string;

    startLineHeaderStrTOC8      :string;
     stopLineHeaderStrTOC8      :string;

    startLineHeaderStrCurrent8  :string;
     stopLineHeaderStrCurrent8  :string;


    startLineIndentLStr         :string;
    startLineIndentCStr         :string;
    startLineIndentRStr         :string;
    startLineLStr               :string;
    startLineCStr               :string;
    startLineRStr               :string;
    startBeginContentsLineStr   :string;
    stopLineStr                 :string;
    sceneSepStr                 :string;
    metaListForPage             :string;

    v2                          :boolean;
    v3                          :boolean;

    //preprocessing streams
    s                           :tstr8;
    t                           :tunidoc;//pointer only
    tlen                        :longint32;
    docText                     :tstr8;

    //per document formatting options
    dchapterOne                 :boolean;
    dnoHeading                  :boolean;
    dnoBlanklines               :boolean;//17nov2026
    dformatDocument             :boolean;
    dsplit                      :boolean;
    dindentChars                :longint32;
    dindentFirst                :longint32;
    ddropCaps                   :longint32;
    ddropWordLimit              :longint32;
    dblankLine                  :longint32;
    dblankLineAutoInsert        :boolean;

    //misc
    dsectionCount               :longint32;//sections for current document
    dsectionTotalCount          :longint32;//sections overall
    dfilecount                  :longint32;//number of files processed - not used for internaldatamode
    dcoverImageDone             :boolean;
    dcoverRatio                 :double;
    dcoverBytes                 :longint32;

    end;


//Windows 1252 character set procs -> english text + latin 1 -------------------

function  windows1252__charIsLetter       (const v:longint32):boolean;
function  html__filterLine8               (const s:string):string;//limited, for xml values etc - 14nov2026
function  xml__filterLine8                (const s:string):string;//limited, for xml values etc - windows-1252 codepage
function  xml__filterlineFrom8            (const s8:string):string;//limited, for xml values etc - 12nov2026
function  xml__filterLineFromU8           (const u8:string):string;//limited, for xml values etc - 12nov2026
function  windows1252__charVisible        (const v:longint32):boolean;//windows-1252 -> sourced from "https://www.ascii-code.com/"


//pub procs --------------------------------------------------------------------

function  pub__build(const sbuildFile:string;var doutputFilename,dstatus:string):boolean;
function  pub__build2(const sbuildFile:string;const sbuildPub:boolean;var doutputFilename,dstatus:string):boolean;

function  pub__build4(const sbuildFile:string;const sbuildTemplateU8,smoreTextU8:pobject;const sbuildPub:boolean;const doutdata:pobject;var doutputFilename,dstatus:string):boolean;

function  pub__copy(const s:tbasicbwp;sbuildFolder:string):boolean;
function  pub__paste(const s:tbasicbwp;sbuildFolder:string):boolean;

//.support procs
function  pub__init(var x:tpubinfo;const sbuildFile:string):boolean;
procedure pub__free(var x:tpubinfo);
function  pub__codesExtractLineb(const s:tunidoc;const xfrom0:longint32;var dpos0:longint32):string;
function  pub__codesExtractLine(const s:tunidoc;const xfrom0:longint32;var dpos0:longint32;var xline:string):boolean;
procedure pub__codesRead(var xcore:tpubinfo;const xline:string);
function  pub__codesHasSplit(const xline:string):boolean;
procedure pub__codesApply(var xcore:tpubinfo);

procedure pub__autoSetSRL(var xcore:tpubinfo);//auto set start of reading location (if not already set) - 14nov2026
procedure pub__FilterBuildFile(const xbuildFile:string);
function  pub__documentFileList(const xcore:tpubinfo;const sbuildTemplateU8:pobject;const xfindWordCount:boolean;var dwordcount:longint32):string;
function  pub__isDocumentFile(const xbuildFolder,x:string):boolean;
function  pub__extractDocumentFile(const xbuildFolder,x:string):string;//30oct2026
function  pub__extractDocumentFile2(const xbuildFolder,x:string;var xhasFileMarker:boolean):string;//30oct2026
function  crc32__nonzero(const x:string):longint32;//15oct2026
function  pub__addfile(var xcore:tpubinfo;const dstyle:longint32;const xdata,xrefData:string;var dindex:longint32):boolean;

function  pub__addSVG(var xcore:tpubinfo;const xsvgData:string;var dindex:longint32):boolean;

function  pub__addImage(var xcore:tpubinfo;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;
function  pub__addImage2(var xcore:tpubinfo;const simageFileNameForRefOnly:string;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;//03nov2026

function  pub__addViaSplit(var xcore:tpubinfo;const xfilename:string):boolean;
function  pub__preprocess(var xcore:tpubinfo):boolean;
function  pub__addDocument(var xcore:tpubinfo):boolean;
function  pub__addCoverOrImage(var xcore:tpubinfo;const xfilename:string;const xAsCover:boolean):boolean;

function  pub__addContents(var xcore:tpubinfo):boolean;
function  pub__addTOCxhtml(var xcore:tpubinfo):boolean;
function  pub__addStylesheet(var xcore:tpubinfo):boolean;//11nov2026
function  pub__addContentopf(var xcore:tpubinfo):boolean;
function  pub__generator:string;
function  pub__isbnValid(const x:string;var e:string):boolean;
function  pub__isbnFilter(const x:string):string;
function  pub__isbn(const xcore:tpubinfo):string;//01nov2026
function  pub__uuid(const xcore:tpubinfo):string;//01nov2026, 20oct2026
function  pub__title(const xcore:tpubinfo):string;
function  pub__asTitle(const xlabel,xdef:string):string;//20oct2026
function  pub__asTitleU8(const u8:string;const xdef8:string):string;//11nov2026
function  pub__author(const xcore:tpubinfo):string;
function  pub__authorR(const xcore:tpubinfo):string;
function  pub__releaseDate(const xcore:tpubinfo):string;
function  pub__addTOCncx(var xcore:tpubinfo):boolean;
function  pub__containerxml:string;
function  pub__mimetype:string;
function  pub__asEbookFilename(const n:string):string;
function  pub__buildOptionValue(const xvalue:string;const xmin,xmax,xdef:longint32):longint32;//17oct2026
function  pub__buildOptionBool(const xvalue:string;const xdef:boolean):boolean;//17oct2026
function  pub__imageIsJpeg(const sformat:string):boolean;
function  pub__imageFormatSupported(const sformat:string):boolean;
function  pub__convertImage(var xcore:tpubinfo;const s,d:tstr8;const ximageIsCover:boolean;var doutW,doutH:longint32;var e:string):boolean;
function  pub__digPad(const x:longint32):string;
function  pub__single(const x:double):string;
function  pub__singleADE(const x:double):string;
function  pub__setFirstError(var xcore:tpubinfo;const xnewErrorMsg:string):boolean;
function  pub__seterrorFileNotFound(var xcore:tpubinfo;const xfilename:string):boolean;
function  pub__seterrorFileNotFound2(var xcore:tpubinfo;const xfilename,xmoreInfo:string):boolean;
function  pub__seterrorFolderNotFound(var xcore:tpubinfo;const xfolder:string):boolean;
function  pub__helpText:string;
function  pub__fileFormatSupported(const xfilename:string):boolean;
function  pub__fileFormatSupported2(const xfilename:string;var xdocStyle:longint32):boolean;
procedure pub__setChapterOneOnce(var xcore:tpubinfo;const dindex:longint32);
function  pub__enforceImageLimits(const xcore:tpubinfo;const ximagedata:tstr8;var xoutW,xoutH:longint32):boolean;
function  pub__enforceURLprotocol(const x:string):string;//30oct2026
function  pub__stripProtocols(const x:string):string;
procedure pub__formatUp(const x:tunidoc);
procedure pub__formatSceneSep(const x:tunidoc);//24oct2026
procedure pub__quotesSinglePlain(const x:tunidoc);
procedure pub__quotesDoublePlain(const x:tunidoc);
procedure pub__quotesDoubleCurly(const x:tunidoc);
procedure pub__quotesSingleCurly(const x:tunidoc);
function  pub__version:string;
procedure pub__bisac;
procedure pub__thema;
function  pub__sepCode(var xcore:tpubinfo;const xindex:longint32):string;


implementation


//Windows 1252 character set procs -> english text + latin 1 -------------------


function pub__junkLine:string;//???????????????????????????????????????
var
   p:longint32;
begin

result:='';

for p:=0 to 255 do result:=result+char(p);

end;

function html__filterLine8(const s:string):string;//limited, for xml values etc - 14nov2026
var
   p                            :longint32;
   v                            :longint32;

   procedure r(const v:string);
   begin

   result                       :=result + v;

   end;

   procedure ra;
   begin

   result                       :=result + char(v);

   end;

begin

//defaults
result                          :='';

//get
for p:=1 to low__len32(s) do
begin

v                               :=byte(s[p-1+stroffset]);

case v of

9,10,32,160                     :r(#32);
60                              :r('&lt;');//required for xml
62                              :r('&gt;');//required for xml
else if (v>=32) then             ra;

end;//case

end;//p

end;

function xml__filterLine8(const s:string):string;//limited, for xml values etc
var//Low-level XML/HTML conversion proc -> ADE confirmed - 23oct2026
   p                            :longint32;
   v                            :longint32;

   procedure r(const v:string);
   begin

   result                       :=result + v;

   end;

   procedure ra;
   begin

   result                       :=result + char(v);

   end;

begin

//defaults
result                          :='';

//get
for p:=1 to low__len32(s) do
begin

v                               :=byte(s[p-1+stroffset]);

case v of

9,10,32,160                     :r(#32);
34                              :r('&quot;');//required for xml
38                              :r('&amp;');//required for xml
39                              :r('&apos;');//required for xml
60                              :r('&lt;');//required for xml
62                              :r('&gt;');//required for xml
else if (v>=32) then             ra;

end;//case

end;//p

end;

function xml__filterlineFrom8(const s8:string):string;//limited, for xml values etc - 12nov2026
var//Flow: 8-bit ascii -> xml_filter -> utf-8 - ADE confirmed - 23oct2026
   p                            :longint32;
   v                            :longint32;

   procedure r8(const v:string);
   var
      p                         :longint32;

   begin

   for p:=0 to pred(low__len32(v)) do
   begin

   u8__wcStr( result ,u__from8b(byte(v[p+stroffset])) );

   end;//p

   end;

   procedure ra;
   begin

   u8__wcStr( result ,u__from8b(v) );

   end;

begin

//defaults
result                          :='';

//get
for p:=0 to pred(low__len32(s8)) do
begin

v                               :=byte(s8[p+stroffset]);

case v of

9,10,32,160                     :r8(#32);
34                              :r8('&quot;');//required for xml
38                              :r8('&amp;');//required for xml
39                              :r8('&apos;');//required for xml
60                              :r8('&lt;');//required for xml
62                              :r8('&gt;');//required for xml
else if (v>=32) then             ra;

end;//case

end;//p

end;

function xml__filterLineFromU8(const u8:string):string;//limited, for xml values etc - 12nov2026
label//Flow: utf-8 -> xml_filter -> utf-8 - ADE confirmed - 23oct2026
   redo;

var
   p                            :longint32;
   u                            :longint32;
   upos0                        :longint32;
   ulen                         :longint32;

   procedure r8(const v:string);
   var
      p                         :longint32;

   begin

   for p:=0 to pred(low__len32(v)) do
   begin

   u8__wcStr( result ,u__from8b(byte(v[p+stroffset])) );

   end;//p

   end;

   procedure ra;
   begin

   u8__wcStr( result ,u );

   end;

begin

//defaults
result                          :='';
upos0                           :=0;
ulen                            :=low__len32(u8);

//get
redo:

if u8__rcStr( u8 ,upos0 ,u ) then
   begin

   case u of

   9,10,32,160                  :r8(#32);
   34                           :r8('&quot;');//required for xml
   38                           :r8('&amp;');//required for xml
   39                           :r8('&apos;');//required for xml
   60                           :r8('&lt;');//required for xml
   62                           :r8('&gt;');//required for xml
   else if (u>=32) then          ra;

   end;//case

   end;

//.loop
if (upos0<ulen) then goto redo;

end;

function windows1252__charIsLetter(const v:longint32):boolean;
begin

case v of

48..57                          :result:=true;
65..90                          :result:=true;
97..122                         :result:=true;
131                             :result:=true;
138                             :result:=true;
140                             :result:=true;
142                             :result:=true;
154                             :result:=true;
158..159                        :result:=true;
161                             :result:=true;
192..214                        :result:=true;
216..246                        :result:=true;
248..255                        :result:=true;

else                             result:=false;

end;//case

end;

function windows1252__charVisible(const v:longint32):boolean;//windows-1252 -> sourced from "https://www.ascii-code.com/"
begin

case v of

33..126                         :result:=true;
128                             :result:=true;
130..140                        :result:=true;
142                             :result:=true;
145..156                        :result:=true;
158..159                        :result:=true;
160..255                        :result:=true;
else                             result:=false;

end;//case

end;


//pub procs --------------------------------------------------------------------

function pub__init(var x:tpubinfo;const sbuildFile:string):boolean;
var
   p                            :longint32;

begin

//defaults
result                          :=true;

//init
with x do
begin

count                           :=0;
count_text                      :=0;
count_image                     :=0;
count_svg                       :=0;
buildFile                       :=sbuildFile;
headingUntitledCount            :=0;//for document split's with a single image and NO heading

internaldataMode                :=false;
internaldata                    :=nil;//created when required

dsectionCount                   :=0;
dsectionTotalCount              :=0;
dfilecount                      :=0;
dcoverImageDone                 :=false;
dformatdocument                 :=false;
dsplit                          :=false;
dchapterOne                     :=false;
dnoHeading                      :=false;
dnoBlanklines                   :=true;
dcoverRatio                     :=1.5;
dcoverBytes                     :=0;

//.continue
title                           :='';
fname                           :='';
lname                           :='';
authorWebsite                   :='';
releaseAuto                     :=true;
year                            :=1900;
month                           :=1;
day                             :=1;
hour                            :=0;
minute                          :=0;
second                          :=0;
rights                          :='';
subject1                        :='';
subject2                        :='';
subject3                        :='';
subject4                        :='';
subject5                        :='';

bisacLabel1                     :='';
bisacCode1                      :='';
bisacLabel2                     :='';
bisacCode2                      :='';
bisacLabel3                     :='';
bisacCode3                      :='';

themaLabel1                     :='';
themaCode1                      :='';
themaLabel2                     :='';
themaCode2                      :='';
themaLabel3                     :='';
themaCode3                      :='';

des                             :='';
publisher                       :='';
publisherUrl                    :='';
isbn                            :='';
docHeading                      :='';
docUsedSVG                      :=false;
sepIsSVG                        :=false;
firstError                      :='';
firstChapterIndex               :=-1;//not set
codeCount                       :=0;//none used

slot_contentsHtml               :=-1;
slot_contentsOpf                :=-1;
slot_titlepageXhtml             :=-1;
slot_tocNcx                     :=-1;
slot_stylesheetcss              :=-1;
slot_TOCxhtml                   :=-1;

//built options
epubVersion                     :=pub_epubVersion_def;
headersize                      :=pub_headerSize_def;
headerAlign                     :=pub_headerAlign_def;
headerAbove                     :=pub_headerAbove_def;
headerBelow                     :=pub_headerBelow_def;
headerAbovePlain                :=50;
headerBelowPlain                :=50;

textsize                        :=pub_textSize_def;
textJustify                     :=pub_textJustify_def;
lineHeight                      :=pub_lineHeight_def;

indentChars                     :=pub_indentChars_def;
blankLine                       :=pub_blankLine_def;

dropcaps                        :=pub_dropCaps_def;

formatUp                        :=pub_formatUp_def;
sceneSep                        :=pub_sceneSep_def;
quotesSingle                    :=pub_quotesSingle_def;
quotesDouble                    :=pub_quotesDouble_def;

imageQuality                    :=pub_imageQuality_def;
coverQuality                    :=pub_coverquality_def;
destCoverWidth                  :=pub_minCoverWidth;

autoSplit                       :=pub_autoSplit_def;

end;//x


//data mode
if x.internaldataMode then
   begin

   x.buildFolder                :='';
   x.outputFilename             :='';

   end

else begin

   x.buildFolder                :=io__asfolderNIL(io__extractfilepath( x.buildFile ));
   x.outputFilename             :=io__remlastext(io__extractfilename( x.buildFile )) + '.' + feEpub;

   if not io__fileexists( x.buildFile ) then
      begin

      pub__seterrorFileNotFound( x ,x.buildFile );

      result                       :=false;

      end;

   if not io__folderexists( x.buildfolder ) then
      begin

      pub__seterrorFolderNotFound( x ,x.buildFolder );

      result                       :=false;

      end;

   end;


//codes
pub__codesRead( x ,'' );


//clear
with x do
begin

for p:=0 to pred(pub_filelimit) do
begin

style[p]                        :=pub_none;//not in use
w[p]                            :=0;
h[p]                            :=0;
nref[p]                         :=0;
nval[p]                         :=0;
name[p]                         :='';
next[p]                         :='';
data[p]                         :='';
dataLen[p]                      :=0;
refdata[p]                      :='';
refdataLen[p]                   :=0;
format[p]                       :='';
headingU8[p]                    :='';
svgUsed[p]                      :=false;

end;//p

s                               :=faststr__new8;
s.floatSize                     :=100*1000;//100K
t                               :=nil;//pointer only
tlen                            :=0;
docText                         :=faststr__new8;

end;//x

end;

procedure pub__free(var x:tpubinfo);
begin

with x do
begin

faststr__free(@internaldata);
faststr__free(@s);
faststr__free(@docText);

end;//with

end;

function pub__codesExtractLineb(const s:tunidoc;const xfrom0:longint32;var dpos0:longint32):string;
begin

pub__codesExtractLine( s ,xfrom0 ,dpos0 ,result );

end;

function pub__codesExtractLine(const s:tunidoc;const xfrom0:longint32;var dpos0:longint32;var xline:string):boolean;
label
   redo;

var
   v                            :longint32;
   xstartlen                    :longint32;
   xstopLen                     :longint32;
   lp                           :longint32;
   spos                         :longint32;
   xstart                       :boolean;

begin

//defaults
result                          :=false;
xline                           :='';

//check
if (s=nil) or (s.count<=0) then exit;

//init
spos                            :=xfrom0;
lp                              :=xfrom0;
dpos0                           :=xfrom0;
xstartlen                       :=low__len32(pub_codesstart);
xstopLen                        :=low__len32(pub_codesstop);
xstart                          :=false;

//get
redo:

v                               :=s.g_8b( spos );

//.start
if ( s.g_8b( spos ) = pub_codesstart1 ) and strmatch( s.t_82( spos ,xstartlen ) ,pub_codesstart ) then
   begin

   xstart                       :=true;

   inc( spos, xstartlen );

   lp                           :=spos;

   end;

//.stop
if xstart and (v=pub_codesstop1) and (  s.t_82( spos ,xstopLen ) = pub_codesstop  ) then
   begin

   //get codes value
   xline                        :=s.t_82( lp ,spos - lp );
   result                       :=true;

   //step to end of code section
   dpos0                        :=spos + pred(xstopLen);

   //quit
   exit;

   end;

//.loop
if (spos<pred(s.count)) then
   begin

   inc(spos);

   goto redo;

   end;

end;

procedure pub__codesRead(var xcore:tpubinfo;const xline:string);
var
   p                            :longint32;
   lp                           :longint32;
   n                            :string;
   dline                        :string;

   function m(const v:string):boolean;
   begin

   result                       :=(v=n);

   end;

begin

//defaults
xcore.dsplit          :=false;
xcore.dchapterone     :=false;
xcore.dformatdocument :=true;

//init
dline                 :=pub_codelist_ChapterFormatting + xline + pub_codesSep1;
lp                    :=1;

//get
for p:=1 to low__len32(dline) do
begin

if (dline[pred(p)+stroffset]=pub_codesSep1) or (dline[pred(p)+stroffset]=pub_codesSep2) then
   begin

   n                  :=strlow(strcopy1( dline ,lp ,p-lp ));

   //.main format setter -> one code sets multiple variables -> used as the default format setup
   if      m(pub_codesFormat)             then
      begin

      xcore.dformatdocument               :=true;
      xcore.dnoHeading                    :=false;
      xcore.dnoBlanklines                 :=true;

      end

   else if m(pub_codesNoFormat)           then
      begin

      xcore.dformatdocument               :=false;
      xcore.dnoHeading                    :=false;
      xcore.dnoBlanklines                 :=false;

      end

   //.adjustment codes
   else if m(pub_codesHeading)            then xcore.dnoHeading                   :=false
   else if m(pub_codesNoHeading)          then xcore.dnoHeading                   :=true
   else if m(pub_codesBlankline)          then xcore.dnoBlanklines                :=false
   else if m(pub_codesNoBlankline)        then xcore.dnoBlanklines                :=true
   else if m(pub_codesChapter1)           then xcore.dchapterone                  :=true
   else if m(pub_codesSplit)              then xcore.dsplit                       :=true
   else begin

      //nil

      end;

   //lp
   lp                 :=succ(p);

   end;

end;//p

//apply
pub__codesApply( xcore );

end;

function pub__codesHasSplit(const xline:string):boolean;
var
   p                            :longint32;
   lp                           :longint32;
   n                            :string;
   dline                        :string;

   function m(const v:string):boolean;
   begin

   result                       :=(v=n);

   end;

begin

//init
result                :=false;                           
dline                 :=pub_codelist_ChapterFormatting + xline + pub_codesSep1;
lp                    :=1;

//get
for p:=1 to low__len32(dline) do
begin

if (dline[pred(p)+stroffset]=pub_codesSep1) or (dline[pred(p)+stroffset]=pub_codesSep2) then
   begin

   n                  :=strlow(strcopy1( dline ,lp ,p-lp ));

   if m(pub_codesSplit) then
      begin

      result          :=true;

      break;

      end;

   //lp
   lp                 :=succ(p);

   end;

end;//p

end;

procedure pub__codesApply(var xcore:tpubinfo);
var
   p                  :longint32;

   function xheaderAlign:string;
   begin

   case xcore.headerAlign of

   0    :result:='l ';
   1    :result:='c ';
   2    :result:='r ';
   else  result:='c';

   end;//case

   end;

   function xtextLeftAlign:string;
   begin

   if xcore.dformatDocument and (xcore.textJustify>=1) then result:=' j'//justify text
   else                                                     result:=' l';//left align text

   end;

begin

with xcore do
begin

//.indentChars
case (indentChars>=0) of

true:indentFirst:=0 //NO - don't indent first paragraph of chapter
else indentFirst:=1;//YES - indent every paragraph regardless

end;//case

//.vars
v2                              :=(epubVersion=2);
v3                              :=(epubVersion=3);

//.strs
case epubVersion of
3   :begin

   docXMLencodingStr            :='';
   docTypeStr                   :='<!DOCTYPE html>';
   docMetaStr                   :='<meta charset="'+pub_utf8+'" />';

   end;

else begin

   docXMLencodingStr            :='<?xml version="1.0" encoding="'+pub_utf8+'"?>';
   docTypeStr                   :='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">';//required for v2
   docMetaStr                   :='<meta http-equiv="content-type" content="http://www.w3.org/1999/xhtml; charset='+pub_utf8+'" />';

   end;

end;//case

headerSizeStr                   :='font-size:'    + pub__singleADE(headersize/100)           + 'em !important;' ;
textSizeStr                     :='font-size:'    + pub__singleADE(textsize  /100)           + 'em !important;' ;
lineHeightStr                   :='line-height:'  + pub__singleADE(lineheight/100)           + 'em !important;' ;

case coverQuality of//14nov2026

4   :dcoverQuality              :=ia_bestquality;
3   :dcoverQuality              :=ia_highquality;
2   :dcoverQuality              :=ia_goodquality;
1   :dcoverQuality              :=ia_fairquality;
0   :dcoverQuality              :=ia_lowquality;
else dcoverQuality              :=ia_lowquality;

end;//case

case imageQuality of//14nov2026

5   :dimageQuality              :=ia_highquality;//png, jpg or gif
4   :dimageQuality              :=ia_highquality;//png or jpg
3   :dimageQuality              :=ia_highquality;//jpg only
2   :dimageQuality              :=ia_goodquality;//jpg only
1   :dimageQuality              :=ia_fairquality;//jpg only
0   :dimageQuality              :=ia_lowquality;//jpg only
else dimageQuality              :=ia_lowquality;//jpg only

end;//case

//.header strs -> these allow for decoration to be inserted under the heading and BEFORE the below space
startLineHeaderStrPlain8        :='<p class="topplain">' + pub_space160 + '</p>' + pub_returnCode +
                                  '<h1>';

 stopLineHeaderStrPlain8        :='</h1>' + pub_returnCode +
                                  '<p class="botplain">' + pub_space160 + '</p>' ;

startLineHeaderStrChapter8      :='<p class="top">' + pub_space160 + '</p>' + pub_returnCode +
                                  '<h1 class="' + xheaderAlign + '">' ;

 stopLineHeaderStrChapter8      :='</h1>' + pub_returnCode +
                                  '<p class="bot">' + pub_space160 + '</p>' ;

startLineHeaderStrCurrent8      :=low__aorbstr( startLineHeaderStrPlain8 ,startLineHeaderStrChapter8 ,dformatDocument );
 stopLineHeaderStrCurrent8      :=low__aorbstr(  stopLineHeaderStrPlain8 , stopLineHeaderStrChapter8 ,dformatDocument );

//.special case for toc.xhtml which does not allow for tags within "nav" area, so header must be self-contained
startLineHeaderStrTOC8          :='<h1 class="tocplain">';
 stopLineHeaderStrTOC8          :='</h1>';

//.other
startLineIndentLStr             :='<p class="t'+xtextLeftAlign+' i">';
startLineIndentCStr             :='<p class="t c">';//removed "i"
startLineIndentRStr             :='<p class="t r">';//removed "i"
startLineLStr                   :='<p class="t'+xtextLeftAlign+'">';
startLineCStr                   :='<p class="t c">';
startLineRStr                   :='<p class="t r">';
startBeginContentsLineStr       :='<p class="t i2 vv010"';

stopLineStr                     :='</p>';

sceneSepStr                     :=pub__sepCode( xcore ,sceneSep );

case dformatDocument of

true:begin

   dindentChars                 :=low__posn( indentChars );
   dindentFirst                 :=indentFirst;
   ddropCaps                    :=dropCaps;
   dblankLine                   :=blankLine;
   dblankLineAutoInsert         :=true;

   end;

else begin

   dindentChars                 :=0;//none
   dindentFirst                 :=0;//none
   ddropCaps                    :=0;//none
   dblankLine                   :=100;
   dblankLineAutoInsert         :=false;

   end;

end;//case

//.dropCaps
case ddropCaps of

3   :ddropWordLimit             :=1;
4   :ddropWordLimit             :=2;
5   :ddropWordLimit             :=3;
6   :ddropWordLimit             :=4;
7   :ddropWordLimit             :=5;
else ddropWordLimit             :=1;

end;//case

//.blankLine

if (dblankLine>=1) then blankLineStr8:='<p class="t c '+low__aorbstr('blank100','blank',dblankLine<>100)+'">'+pub_space160+'</p>'
else                    blankLineStr8:='';

//.misc
metaListForPage:=

 '<meta name="generator" content="'+xml__filterlineFrom8(pub__generator)+'" />'        + pub_returnCode +
 '<link href="css/stylesheet.css" type="text/css" rel="stylesheet" />'                 + pub_returnCode +
 '<meta name="author" content="'+xml__filterlineFrom8(pub__author(xcore))+'" />'       + pub_returnCode +
 '<meta name="created" content="'+xml__filterlineFrom8(pub__releasedate(xcore))+'" />' + pub_returnCode +
 '<meta name="changed" content="'+xml__filterlineFrom8(pub__releasedate(xcore))+'" />' ;

//.autoSplit -> 0 or 2..N
if (autoSplit>=1) then dautoSplit         :=1 + autoSplit
else                   dautoSplit         :=0;

end;//with


end;

function  pub__documentFileList(const xcore:tpubinfo;const sbuildTemplateU8:pobject;const xfindWordCount:boolean;var dwordcount:longint32):string;
var
   a                            :tdynamicnamelist;
   d                            :tstr8;
   w                            :tunidoc;
   l                            :tdynamicstring;
   xlen                         :longint32;
   xpos                         :longint32;
   xline                        :string;
   xwithin                      :boolean;
   xok                          :boolean;
   p                            :longint32;
   df                           :string;
   xappFolder                   :string;
   xdocType                     :longint32;
   sdata                        :string;

   function xcleanLine(const xline:string):string;
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

   function xcanadd(const xfilename:string):boolean;
   begin

   result                       :=pub__fileFormatSupported2( xfilename ,xdocType ) and a.addonce(xfilename);

   end;

   procedure xaddWordCount(const xfilename:string);
   var
      b                         :tstr8;
      e                         :string;

      procedure xincWordCount;
      var
         p                      :longint32;
         bol                    :boolean;
         lastbol                :boolean;

      begin

      //init
      lastbol                   :=false;

      //get
      for p:=0 to w.count do
      begin

      bol                       :=w.docsep1(p,0);

      if (bol<>lastbol) then
         begin

         lastbol             :=bol;

         if not lastbol then inc(dwordCount);

         end;

      end;//p

      end;

   begin

   //defaults
   b                            :=nil;

   //check
   if not xfindWordCount then exit;

   try

   //init
   b                            :=faststr__new8;

   //get
   if io__fromfile( xfilename ,@b ,e ) then
      begin

      if (w=nil) then w:=doc__uni;

      doc__fromdata( w ,@b ,e );
      
      //word count
      xincWordCount;

      end;

   except;end;

   //free
   faststr__free(@b);

   end;

   function fok(const xname:string):boolean;
   begin

   result             :=io__fileexists( xcore.buildFolder + xname );

   end;

   function fmarker(const x:boolean):string;
   begin

   case x of
   true:result:=pub_fileMarkerOK;
   else result:=pub_fileMarkerNotFound;
   end;//case

   end;

   function faddOK(const xname:string):boolean;
   begin

   result             :=fok(xname);

   if result then d.sadd( fmarker(result) + #32 + xname + #10 );

   end;

   procedure xaddDF;
   begin

   if xcanadd(df) then
      begin

      xok                 :=io__fileexists( df );

      if xok and (xdocType=pub_fText) then xaddWordCount( df );

      d.sadd( fmarker(xok) + #32 + xline + #10 );

      end;

   end;

begin

//defaults
result                          :='';
d                               :=nil;
a                               :=nil;
l                               :=nil;
w                               :=nil;
dwordcount                      :=0;

try

//init
sdata                           :=u8__to8strb(str__text(  sbuildTemplateU8  ));
xlen                            :=low__len32( sdata );
xpos                            :=0;
d                               :=faststr__new8;
a                               :=tdynamicnamelist.create;
xwithin                         :=false;
xappFolder                      :=app__folder;

//get
while low__nextline1( sdata ,xline ,xlen ,xpos ) do
begin

if (xline<>'') then
   begin

   xline                        :=xcleanLine( xline );

   if xwithin then
      begin

      //remove leading "file:" 
      xline                     :=pub__extractDocumentFile( xcore.buildFolder ,xline );

      //line is a full filename "c:\folder\abc.txt" or "?:\folder\abc.txt" - 17oct2026
      if (strcopy1(xline,2,1)=':') then
         begin

         //1. folder              = buildFolder   -> name only
         if strmatch( io__extractfilepath(xline) ,xcore.buildFolder ) then
            begin

            df                  :=xline;
            xline               :=io__extractfilename( xline );

            end

         //2. folder              = same drive as app -> portable folder + name
         else if strmatch( strcopy1(xline,1,1) ,strcopy1(xcore.buildFolder,1,1) ) then
            begin

            df                  :=xline;
            xline               :=io__makeportablefilename( xline );

            end

         //3. portable Folder    = leave as is / convert to name only / change to global drive letter
         else if (strcopy1(xline,1,1)='?') then
            begin

            df                  :=io__readportablefilename( xline );

            if strmatch( io__extractfilepath(df) ,xcore.buildFolder ) then
               begin

               xline            :=io__extractfilename( df );

               end

            else if not strmatch( strcopy1(df,1,1), strcopy1(xcore.buildFolder,1,1) ) then
               begin

               xline            :=df;

               end;

            end

         //.4 folder              =not build folder OR not on same drive -> leave as is
         else begin

            df                  :=xline;

            end;

         //get
         if xcanadd(df) then
            begin

            xok                 :=io__fileexists( df );

            if xok and (xdocType=pub_fText) then xaddWordCount( df );

            d.sadd( fmarker(xok) + #32 + xline + #10 );

            end;

         end

      //line is a relative filename "abc.txt"
      else if not low__havechar(xline,':') then
         begin

         df                     :=xcore.buildFolder + xline;

         if xcanadd(df) then
            begin

            xok                 :=io__fileexists( df );

            if xok and (xdocType=pub_fText) then xaddWordCount( df );

            d.sadd( fmarker(xok) + #32 + xline + #10 );

            end;

         end;

      end

   else begin

      xwithin                   :=strmatch(xline,pub_docFiles);

      end;

   end;

end;//loop

//fallback -> include current folder documents by default
if (d.len32<=0) and (not xcore.internaldataMode) then
   begin

   //.cover.bmp/jpg/png - auto. include - 23oct2026
   if faddOK('cover.bmp') or faddOK('cover.jpg') or faddOK('cover.jif') or faddOK('cover.jpeg') or faddOK('cover.png') then
      begin

      //nil

      end;

   //.doc files
   l                            :=tdynamicstring.create;

   io__filelist( l ,false ,xcore.buildFolder ,pub_docMask ,pub_docEMask );

   l.sort( true );

   for p:=0 to pred(l.count) do
   begin

   if (l.value[p]<>'') and xcanadd(l.value[p]) then
      begin

      d.sadd( fmarker(true) + #32 + l.value[p] + #10 );

      if (xdocType=pub_fText) then xaddWordCount( xcore.buildFolder + l.value[p] );

      end;

   end;//p

   end;

//set
result                          :=d.text;

except;end;

//free
faststr__free(@d);
freeobj(@a);
freeobj(@l);
freeobj(@w);

end;

procedure pub__FilterBuildFile(const xbuildFile:string);
var
   e                            :string;
   str1                         :string;

begin

pub__build2(xbuildFile,false,str1,e);

end;

function pub__build(const sbuildFile:string;var doutputFilename,dstatus:string):boolean;
begin

result                :=pub__build2( sbuildFile ,true ,doutputFilename ,dstatus );

end;

function pub__build2(const sbuildFile:string;const sbuildPub:boolean;var doutputFilename,dstatus:string):boolean;
label
   skipend;

var
   sbuildTemplateU8   :tstr8;
   doutdata           :tstr8;
   e                  :string;

begin

//defaults
result                :=false;
sbuildTemplateU8      :=nil;
doutdata              :=nil;
dstatus               :=gecTaskfailed;

try

//init
sbuildTemplateU8      :=faststr__new8;
doutdata              :=faststr__new8;

//get
if not io__fromfile( sbuildFile ,@sbuildTemplateU8 ,e ) then
   begin

   dstatus            :=e + ': ' + sbuildfile;

   goto skipend;

   end;

//build
if not pub__build4( sbuildFile ,@sbuildTemplateU8 ,nil ,sbuildPub ,@doutdata ,doutputFilename ,dstatus ) then
   begin

   goto skipend;

   end;

//save updated sbuildTemplate back to file
if not io__tofile( sbuildFile ,@sbuildTemplateU8 ,e ) then
   begin

   dstatus            :=e + ': ' + sbuildfile;

   goto skipend;

   end;

//save EPUB to file
if sbuildPub and (not io__tofile( doutputFilename ,@doutdata ,e )) then
   begin

   dstatus            :=e + ': ' + doutputFilename;

   goto skipend;

   end;

//successful
result                :=true;

skipend:

except;end;

//free
if (sbuildTemplateU8<>nil) then faststr__free( @sbuildTemplateU8 );
if (doutdata<>nil        ) then faststr__free( @doutdata       ) ;

end;

function  pub__build4(const sbuildFile:string;const sbuildTemplateU8,smoreTextU8:pobject;const sbuildPub:boolean;const doutdata:pobject;var doutputFilename,dstatus:string):boolean;
label
   skipend;

var
   s                            :tfastvars2;
   slen                         :longint32;
   spos                         :longint32;
   sline                        :string;
   binuse                       :boolean;
   sbuildFolder                 :string;
   d                            :tstr8;
   l                            :tstr8;
   b                            :tpubinfo;
   etmp                         :string;
   xtmp                         :string;
   v                            :string;
   v32                          :longint32;
   p                            :longint32;
   dinternaldataMode            :boolean;
   v64                          :longint64;
   ddate                        :tdatetime;
   yy                           :word;
   mm                           :word;
   dd                           :word;
   th                           :word;
   tm                           :word;
   ts                           :word;
   tms                          :word;

   procedure ladd(x:string);
   begin

   //get
   x                            :=stripwhitespace_lt( x );

   if (x<>'') then
      begin

      swapchars( x ,#10,#32);
      swapchars( x ,#13,#32);
      swapchars( x ,#9 ,#32);

      x                         :=stripwhitespace_lt( x );

      end;

   //set
   d.sadd( x + pub_returnCode );

   end;

   function fsep(const n:string):string;
   begin

   result             :=strpad( n ,17 ) + ': ' ;

   end;

   procedure fadd(const n,v:string);
   begin

   ladd( fsep(n) + v );

   end;

   procedure dadd2(const n,vdef:string);
   begin

   ladd( fsep(n) + strdefb(s.s[n],vdef) );

   end;

   procedure dadd(const n:string);
   begin

   dadd2(n,'');

   end;

   procedure iadd(const n:string;const xmin,xmax,xdef:longint32);//17oct2026
   begin

   ladd( fsep(n) + k64(  pub__buildOptionValue( s.s[n] ,xmin ,xmax ,xdef )  ) );

   end;

   procedure iadd2(const n:string;const xmin,xmax,xdef:longint32);//17oct2026
   begin

   ladd( fsep(n) + intstr32( pub__buildOptionValue( s.s[n] ,xmin ,xmax ,xdef )  ) );

   end;

   procedure iadd3(const n:string;const xmin,xmax,xdef,xval:longint32);//14nov2026
   begin

   ladd( fsep(n) + intstr32( pub__buildOptionValue( intstr32(xval) ,xmin ,xmax ,xdef )  ) );

   end;

   procedure badd(const n:string;const xdef:boolean);//17oct2026
   begin

   ladd( fsep(n) + bolstr(  pub__buildOptionBool( s.s[n] ,xdef )  ) );

   end;

   procedure dsave(const xmakepub,xbuildOK:boolean);
   var
      dlist                     :string;
      dwordcount                :longint32;
      str1                      :string;
      str2                      :string;

   begin

   //init
   d.clear;

   s.text                       :=u8__to8strb(str__text(  sbuildTemplateU8  ));

   //get
   ladd(pub_buildSummary);

   if xmakepub then
      begin

      fadd ('Status',dstatus );
      fadd ('Warning',low__aorbstr('(none)',b.firstError,(b.firstError<>'')) );

      fadd ('Release.Date',low__datestr(date__encodedate(b.year,b.month,b.day),0,false) + ' @ '+low__timestr(date__encodetime(b.hour,b.minute,b.second,0),0) +insstr(' (auto.update)',s.b['auto.update']) );

      if (b.firstChapterIndex>=0) then str1:=u8__from8strb( b.headingU8[b.firstChapterIndex] )
      else                             str1:='';

      fadd ('Start.Of.Reading',strdefb(str1,'(none)') );

      fadd ('Code.Sets',low__aorbstr('(none)','Yes ( '+k64(b.codeCount)+' )',b.codeCount>=1 ) );

      end

   else begin

      dadd2('Status','(none)');
      dadd2('Warning','(none)');
      dadd2('Release.Date','(none)');
      dadd2('Start.Of.Reading','(none)');
      dadd2('Code.Sets','(none)');

      end;

   dlist                        :=pub__documentFileList( b ,sbuildTemplateU8 ,sbuildPub ,dwordcount );

   if xmakepub then
      begin

      case b.internaldataMode of

      true:fadd ('Output.File','(internal datastream)');
      else fadd ('Output.File',io__extractfilename(doutputFilename));

      end;//case

      end

   else dadd2('Output.File','-');


   if xmakepub then fadd ('EPUB.Size',low__mbAUTO2( str__len32( doutdata) ,3 ,true ))
   else             dadd2('EPUB.Size','0'                                           );


   if xmakepub then fadd ('Word.Count',k64(dwordcount))
   else             dadd2('Word.Count','0');


   if xmakepub then fadd ('File.Count',k64(b.dfileCount))
   else             dadd2('File.Count','0');


   if xmakepub then fadd ('Cover.JPEG',intstr32(round32(b.destCoverWidth*b.dcoverRatio))+'h x '+intstr32(b.destCoverWidth)+'w  ( '+floattostrex(b.dcoverratio,1)+':1 )  '+low__mbPLUS(b.dcoverBytes,true) )
   else             dadd2('Cover.JPEG','(none)');

   
   //.book and author info
   ladd('');
   ladd('-- Meta Information --');
   fadd('Book.Title', xml__filterLine8(pub__asTitle( s.s['book.title'],io__remlastext(io__extractfilename(sbuildFile)) ) ));

   //.isbn
   ladd('');
   str1               :=pub__isbnFilter(s.s['isbn']);
   fadd('ISBN',str1 );

   //.isbn.status
   if (str1<>'') then pub__isbnValid(str1,str2)
   else               str2:='Not Used';

   fadd('ISBN.Status',str2);

   //.continue
   ladd('');
   dadd2('Author.First.Name'    ,pub_firstName_def);
   dadd2('Author.Last.Name'     ,pub_lastName_def);
   fadd('Author.Url'            ,xml__filterLine8( pub__enforceURLprotocol(s.s['author.url']) ));
   ladd('');
   fadd('Publisher.Name'        ,xml__filterLine8( s.s['publisher.name'] ));
   fadd('Publisher.Url'         ,xml__filterLine8(pub__enforceURLprotocol(s.s['publisher.url'])) );

   ladd('');
   dadd('Rights');
   dadd('Description');
   dadd('Subject.1');
   dadd('Subject.2');
   dadd('Subject.3');
   dadd('Subject.4');
   dadd('Subject.5');

   ladd('');
   dadd('BISAC.label1');
   dadd('BISAC.code1');
   dadd('BISAC.label2');
   dadd('BISAC.code2');
   dadd('BISAC.label3');
   dadd('BISAC.code3');

   ladd('');
   dadd('THEMA.label1');
   dadd('THEMA.code1');
   dadd('THEMA.label2');
   dadd('THEMA.code2');
   dadd('THEMA.label3');
   dadd('THEMA.code3');

   ladd('');
   iadd2('Auto.Update'          ,0                        ,1                         ,1                         );

   if xmakepub then
      begin

      iadd3('Release.Year'      ,0                        ,max32                     ,yy              ,b.year   );
      iadd3('Release.Month'     ,1                        ,12                        ,mm              ,b.month  );
      iadd3('Release.Day'       ,1                        ,31                        ,dd              ,b.day    );

      iadd3('Release.Hour'      ,0                        ,23                        ,th              ,b.hour   );
      iadd3('Release.Minute'    ,0                        ,59                        ,tm              ,b.minute );
      iadd3('Release.Second'    ,0                        ,59                        ,ts              ,b.second );

      end

   else begin

      iadd2('Release.Year'      ,0                        ,max32                     ,yy                        );
      iadd2('Release.Month'     ,1                        ,12                        ,mm                        );
      iadd2('Release.Day'       ,1                        ,31                        ,dd                        );

      iadd2('Release.Hour'      ,0                        ,23                        ,th                        );
      iadd2('Release.Minute'    ,0                        ,59                        ,tm                        );
      iadd2('Release.Second'    ,0                        ,59                        ,ts                        );

      end;

   //.build options
   ladd('');
   ladd('-- Build Options --');
   iadd('EPUB.Version'       ,pub_epubVersion_min      ,pub_epubVersion_max       ,pub_epubVersion_def       );

   iadd('Header.Align'       ,pub_headerAlign_min      ,pub_headerAlign_max       ,pub_headerAlign_def       );
   iadd('Header.Size%'       ,pub_headerSize_min       ,pub_headerSize_max        ,pub_headerSize_def        );
   iadd('Header.Above%'      ,pub_headerAbove_min      ,pub_headerAbove_max       ,pub_headerAbove_def       );
   iadd('Header.Below%'      ,pub_headerBelow_min      ,pub_headerBelow_max       ,pub_headerBelow_def       );

   iadd('Text.Size%'         ,pub_textSize_min         ,pub_textSize_max          ,pub_textSize_def          );
   iadd('Text.Justify'       ,pub_textJustify_min      ,pub_textJustify_max       ,pub_textJustify_def       );
   iadd('Line.Height%'       ,pub_lineHeight_min       ,pub_lineHeight_max        ,pub_lineHeight_def        );

   iadd('Drop.Caps'          ,pub_dropCaps_min         ,pub_dropCaps_max          ,pub_dropCaps_def          );
   iadd('Indent.Chars'       ,pub_indentChars_min      ,pub_indentChars_max       ,pub_indentChars_def       );
   iadd('Blank.Line%'        ,pub_blankLine_min        ,pub_blankLine_max         ,pub_blankLine_def         );

   iadd('Format.Up'          ,pub_formatUp_min         ,pub_formatUp_max          ,pub_formatUp_def          );
   iadd('Scene.Sep'          ,pub_sceneSep_min         ,pub_sceneSep_max          ,pub_sceneSep_def          );
   dadd('Scene.Sep.Custom');

   iadd('Quotes.Single'      ,pub_quotesSingle_min     ,pub_quotesSingle_max      ,pub_quotesSingle_def      );
   iadd('Quotes.Double'      ,pub_quotesDouble_min     ,pub_quotesDouble_max      ,pub_quotesDouble_def      );

   iadd('Image.Quality'      ,pub_imageQuality_min     ,pub_imageQuality_max      ,pub_imageQuality_def   );
   iadd('Cover.Quality'      ,pub_coverquality_min     ,pub_coverquality_max      ,pub_coverquality_def      );
   iadd('Auto.Split'         ,pub_autoSplit_min        ,pub_autoSplit_max         ,pub_autoSplit_def         );

   //.doc files
   ladd('');
   ladd(pub_docFiles);

   if (dlist<>'') then d.sadd( dlist );

   //.trailing blank line
   ladd('');

   //set
   str__settext( sbuildTemplateU8 ,u8__from8strb(d.text) );

   end;

   function m(const n:string):boolean;
   begin

   result                       :=strmatch( n ,sline );

   end;

   function mv(const sn:string):boolean;
   var
      nn                        :string;
      vv                        :string;

   begin

   if low__splitstr( sline ,ssColon ,nn ,vv ) then
      begin

      result                    :=strmatch( sn, stripwhitespace_lt( nn ) );

      if result then
         begin

         v                      :=stripwhitespace_lt( vv );
         v32                    :=strint32( vv );

         end;

      end

   else begin

      result                    :=strm( sline ,sn ,v ,v32 );

      end;

   end;

   function zadd(const dname,ddata:string;const dstoreOnly:boolean):boolean;
   var
      v               :tstr8;

   begin

   //defaults
   result             :=false;
   v                  :=nil;

   try

   //init
   v                  :=faststr__new8;
   v.text             :=ddata;

   //get
   result             :=zip__add2( d ,l ,dname ,v ,dstoreOnly );

   except;end;

   //free
   faststr__free(@v);

   end;

   function ziadd(const drootfolder:string;const dslot:longint32;const dstoreOnly:boolean):boolean;
   begin

   //defaults
   result             :=false;

   //get
   if (dslot>=0) and (dslot<b.count) and (b.style[dslot]<>pub_none) then
      begin

      result          :=zadd( drootfolder + b.name[dslot] ,b.data[dslot] ,dstoreOnly );

      end;

   end;

begin

//defaults
result                          :=false;
dstatus                         :=pub_buildOK;
binuse                          :=false;
s                               :=nil;
d                               :=nil;
l                               :=nil;
sbuildFolder                    :='';
doutputFilename                 :='';

//init
str__lock( sbuildTemplateU8 );
str__lock( doutdata       );
dinternaldataMode               :=str__lock( smoreTextU8      );
ddate                           :=date__now;

low__decodedate2( ddate ,yy ,mm ,dd );
low__decodetime2( ddate ,th ,tm ,ts ,tms );

//clear
str__clear( doutdata      );


//check
if (sbuildfile<>'') then
   begin

   doutputFilename              :=io__remlastext(sbuildFile) + '.' + feEpub;

   if not io__fileexists( sbuildFile ) then
      begin

      dstatus                   :=gecFileNotfound + ': ' + sbuildFile;

      exit;

      end;

   end;

try

//init -------------------------------------------------------------------------

s                               :=tfastvars2.create;
s.oremovewhitespaceSLOW         :=true;//auto-remove whitespace left/right of colon for "name:value" pairs
d                               :=faststr__new8;
binuse                          :=true;

pub__init( b ,sbuildFile );//once "b.init" it must be "b.free" - 20oct2026

//.internal data mode
b.internaldataMode              :=dinternaldataMode;

if b.internaldataMode then
   begin

   b.internaldata               :=faststr__new8;

   str__add( @b.internaldata ,smoretextU8 );

   end;

//.filter build info
dsave(false,true);

if not sbuildPub then
   begin

   result                       :=true;

   goto skipend;

   end;


//build.read.settings ----------------------------------------------------------

//init
spos                            :=0;
xtmp                            :=u8__to8strb(str__text(  sbuildTemplateU8  ));
slen                            :=low__len32( xtmp );

//get
while low__nextline1( xtmp ,sline ,slen ,spos ) do
begin

//.found first document file name -> stop
if pub__isDocumentFile( b.buildFolder ,sline ) then break;

//.book and author information
if      mv('book.title')                 then b.title         :=v
else if mv('author.first.name')          then b.fname         :=v
else if mv('author.last.name')           then b.lname         :=v
else if mv('author.url')                 then b.authorWebsite :=pub__enforceURLprotocol(v)

else if mv('auto.update')                then b.releaseAuto   :=strbol(intstr32(v32))

else if mv('release.year')               then b.year          :=low__aorb(v32,yy,b.releaseAuto)
else if mv('release.month')              then b.month         :=low__aorb(v32,mm,b.releaseAuto)
else if mv('release.day')                then b.day           :=low__aorb(v32,dd,b.releaseAuto)

else if mv('release.hour')               then b.hour          :=low__aorb(v32,th,b.releaseAuto)
else if mv('release.minute')             then b.minute        :=low__aorb(v32,tm,b.releaseAuto)
else if mv('release.second')             then b.second        :=low__aorb(v32,ts,b.releaseAuto)

else if mv('rights')                     then b.rights        :=v
else if mv('subject.1')                  then b.subject1      :=v
else if mv('subject.2')                  then b.subject2      :=v
else if mv('subject.3')                  then b.subject3      :=v
else if mv('subject.4')                  then b.subject4      :=v
else if mv('subject.5')                  then b.subject5      :=v
else if mv('description')                then b.des           :=v
else if mv('publisher.url')              then b.publisherUrl  :=pub__enforceURLprotocol(v)
else if mv('publisher.name')             then b.publisher     :=v

else if mv('bisac.label1')              then b.bisaclabel1    :=v
else if mv('bisac.code1')               then b.bisaccode1     :=v
else if mv('bisac.label2')              then b.bisaclabel2    :=v
else if mv('bisac.code2')               then b.bisaccode2     :=v
else if mv('bisac.label3')              then b.bisaclabel3    :=v
else if mv('bisac.code3')               then b.bisaccode3     :=v

else if mv('thema.label1')              then b.themalabel1    :=v
else if mv('thema.code1')               then b.themacode1     :=v
else if mv('thema.label2')              then b.themalabel2    :=v
else if mv('thema.code2')               then b.themacode2     :=v
else if mv('thema.label3')              then b.themalabel3    :=v
else if mv('thema.code3')               then b.themacode3     :=v

else if mv('isbn.status')                then
   begin
   //nil
   end
else if mv('isbn')                       then b.isbn:=pub__isbnFilter(v)

//.build options
else if mv('EPUB.Version')               then b.epubVersion          :=pub__buildOptionValue( v ,pub_epubVersion_min      ,pub_epubVersion_max      ,pub_epubVersion_def      )

else if mv('header.size%')               then b.headerSize           :=pub__buildOptionValue( v ,pub_headerSize_min       ,pub_headerSize_max       ,pub_headerSize_def       )
else if mv('header.align')               then b.headerAlign          :=pub__buildOptionValue( v ,pub_headerAlign_min      ,pub_headerAlign_max      ,pub_headerAlign_def      )
else if mv('header.above%')              then b.headerAbove          :=pub__buildOptionValue( v ,pub_headerAbove_min      ,pub_headerAbove_max      ,pub_headerAbove_def      )
else if mv('header.below%')              then b.headerBelow          :=pub__buildOptionValue( v ,pub_headerBelow_min      ,pub_headerBelow_max      ,pub_headerBelow_def      )

else if mv('text.size%')                 then b.textSize             :=pub__buildOptionValue( v ,pub_textSize_min         ,pub_textSize_max         ,pub_textSize_def         )
else if mv('line.height%')               then b.lineHeight           :=pub__buildOptionValue( v ,pub_lineHeight_min       ,pub_lineHeight_max       ,pub_lineHeight_def       )
else if mv('text.justify')               then b.textJustify          :=pub__buildOptionValue( v ,pub_textJustify_min      ,pub_textJustify_max      ,pub_textJustify_def      )

else if mv('indent.chars')               then b.indentChars          :=pub__buildOptionValue( v ,pub_indentChars_min      ,pub_indentChars_max      ,pub_indentChars_def      )
else if mv('blank.line%')                then b.blankLine            :=pub__buildOptionValue( v ,pub_blankLine_min        ,pub_blankLine_max        ,pub_blankLine_def        )
else if mv('drop.caps')                  then b.dropCaps             :=pub__buildOptionValue( v ,pub_dropCaps_min         ,pub_dropCaps_max         ,pub_dropCaps_def         )

else if mv('format.up')                  then b.formatUp             :=pub__buildOptionValue( v ,pub_formatUp_min         ,pub_formatUp_max         ,pub_formatUp_def         )
else if mv('scene.sep')                  then b.sceneSep             :=pub__buildOptionValue( v ,pub_sceneSep_min         ,pub_sceneSep_max         ,pub_sceneSep_def         )
else if mv('scene.sep.custom')           then b.sceneSepCustom8      :=v

else if mv('quotes.Single')              then b.quotesSingle         :=pub__buildOptionValue( v ,pub_quotesSingle_min     ,pub_quotesSingle_max     ,pub_quotesSingle_def     )
else if mv('quotes.Double')              then b.quotesDouble         :=pub__buildOptionValue( v ,pub_quotesDouble_min     ,pub_quotesDouble_max     ,pub_quotesDouble_def     )

else if mv('image.quality')              then b.imageQuality         :=pub__buildOptionValue( v ,pub_imageQuality_min     ,pub_imageQuality_max     ,pub_imageQuality_def     )
else if mv('cover.quality')              then b.coverQuality         :=pub__buildOptionValue( v ,pub_coverQuality_min     ,pub_coverQuality_max     ,pub_coverQuality_def     )


else if mv('auto.split')                 then b.autoSplit            :=pub__buildOptionValue( v ,pub_autoSplit_min        ,pub_autoSplit_max        ,pub_autoSplit_def        );

end;//loop


//build.make.user.documents ----------------------------------------------------

//init
spos                            :=0;
xtmp                            :=u8__to8strb(str__text(  sbuildTemplateU8  ));
slen                            :=low__len32( xtmp );

//get
if b.internaldataMode then
   begin

   pub__addViaSplit( b ,'' );//internal data

   end

else begin

   while low__nextline1( xtmp ,sline ,slen ,spos ) do
   begin

   if pub__isDocumentFile( b.buildFolder ,sline ) then
      begin

      //build filename
      sline           :=io__readportablefilename(  pub__extractDocumentFile( b.buildFolder ,sline )  );

      if (io__extractfilepath(sline)='') then
         begin

         sline        :=b.buildFolder + sline;

         end;

      //get

      pub__addViaSplit( b ,sline );//external file -> first external file can be a cover, else no - 13nov2026

      end;

   end;//while

   end;//if


//build.make.support.documents -------------------------------------------------

//init

//.SRL fallback -> scan for "chapter 1"/"chapter one/one/1"
pub__autoSetSRL( b );

//.formatting OFF for the following documents - 24oct2026
pub__codesRead( b ,pub_codelist_PlainFormatting );

//.ids
b.duuid                         :=pub__uuid(b);
b.disbn                         :=pub__isbn(b);

case (b.disbn<>'') of

true:begin

   b.dmasterID                  :=b.disbn;
   b.dmasterIDname              :='book-isbn';

   end;

else begin

   b.dmasterID                  :=b.duuid;
   b.dmasterIDname              :='book-uuid';

   end;

end;//case

//.contents
if b.v2 then pub__addContents( b );//v2 -> human readable html contents
if b.v3 then pub__addTOCxhtml( b );//v3 -> machine readable and human readable contents

//.contents.opf
pub__addContentopf( b );

//.stylesheet
pub__addStylesheet( b );

//.toc.ncx
pub__addTOCncx( b );


//build epub (.zip) ------------------------------------------------------------

//init
l                               :=faststr__new8;
d.clear;
zip__start( d ,l );

//get

zadd( 'mimetype' ,pub__mimetype      ,true );

zadd( 'META-INF/container.xml'       ,u8__from8strb( pub__containerxml ) ,false );//utf-8

//.titlepage
if (b.slot_titlepageXhtml>=0) then ziadd( pub_OEBPS ,b.slot_titlepagexhtml ,false )
else                               pub__setFirstError( b, 'No cover image detected');

//.css
ziadd( pub_OEBPS ,b.slot_stylesheetcss ,false );

//.chapters
for p:=0 to pred(b.count) do if (b.style[p]=pub_html) or (b.style[p]=pub_xhtml) then ziadd( pub_OEBPS ,p ,false );

//.images
for p:=0 to pred(b.count) do if (b.style[p]=pub_image) or (b.style[p]=pub_coverjpg) then ziadd( pub_OEBPS ,p ,false );

//.svgs
for p:=0 to pred(b.count) do if (b.style[p]=pub_svg) then ziadd( pub_OEBPS ,p ,false );//16nov2026

//.indexs
ziadd( pub_OEBPS ,b.slot_contentshtml ,false );
ziadd( pub_OEBPS ,b.slot_tocncx ,false );

if b.v3 then ziadd( pub_OEBPS ,b.slot_TOCxhtml ,false );

ziadd( pub_OEBPS ,b.slot_contentsopf ,false );

//set
zip__stop( d ,l );

if not str__add( doutdata ,@d ) then
   begin

   dstatus                      :=pub_buildFailed + etmp;

   goto skipend;

   end;

//successful -------------------------------------------------------------------

result                          :=true;
skipend:

//.update build file with status + build date
if sbuildPub then
   begin

   if result then dstatus       :=pub_buildOK + insstr(' with warnings',b.firstError<>'');

   dsave(true,result);

   end;

except;end;

//free
if (s<>nil)  then freeobj(@s);
if (d<>nil)  then faststr__free(@d);
if (l<>nil)  then faststr__free(@l);
if binuse    then pub__free(b);

str__uaf( sbuildTemplateU8 );
str__uaf( smoreTextU8      );
str__uaf( doutdata         );

end;

procedure pub__autoSetSRL(var xcore:tpubinfo);//auto set start of reading location (if not already set) - 14nov2026
var
   p                  :longint32;

   function xscan(const v8:string):boolean;
   var
      p               :longint32;
      u8              :string;

   begin

   //defaults
   result             :=false;

   //check
   if (v8='') then exit;

   //init
   u8                 :=u8__from8strb( v8 );

   //scan
   for p:=0 to pred(xcore.count) do
   begin

   if ((xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml)) and strmatch(u8,xcore.headingU8[p]) then
      begin

      result                    :=true;
      xcore.firstChapterIndex   :=p;

      break;

      end;

   end;//p

   end;

begin

//check -> already set -> nothing to do
if (xcore.firstChapterIndex>=0) or (xcore.count<=0) then exit;

//scan in order of preference
if xscan('chapter one') then exit;
if xscan('chapter 1')   then exit;
if xscan('one')         then exit;
if xscan('1')           then exit;

//first document
for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   xcore.firstChapterIndex      :=p;

   exit;

   end;

end;//p

//first slot
xcore.firstChapterIndex         :=0;

end;

function pub__isDocumentFile(const xbuildFolder,x:string):boolean;
begin

pub__extractDocumentFile2( xbuildFolder ,x ,result );

end;

function pub__extractDocumentFile(const xbuildFolder,x:string):string;//30oct2026
var
   xhasFileMarker               :boolean;

begin

result                          :=pub__extractDocumentFile2( xbuildFolder ,x ,xhasFileMarker );

end;

function pub__extractDocumentFile2(const xbuildFolder,x:string;var xhasFileMarker:boolean):string;//30oct2026

   function mv(const n:string;var v:string):boolean;
   begin

   result                       :=strmatch( strcopy1(v,1,low__len32(n)) ,n );

   if result then
      begin

      xhasFileMarker            :=true;

      v                         :=stripwhitespace_lt( strcopy1( v ,succ(low__len32(n)) ,low__len32(v) ) );

      end;

   end;

begin

//defaults
result                          :=x;
xhasFileMarker                  :=false;

//get
if mv( pub_fileMarker ,result ) or mv( pub_fileMarkerOK ,result ) or mv( pub_fileMarkerNotFound ,result ) then
   begin

   //nil

   end;

end;

function pub__preprocess(var xcore:tpubinfo):boolean;
label
   skipone,skipend;

var
   etmp                         :string;
   p                            :longint32;
   dstartPos                    :longint32;
   dheadTo                      :longint32;
   bol1                         :boolean;
   lc                           :longint32;
   xfrom                        :longint32;
   dstartLine                   :boolean;
   dfirstLine                   :boolean;
   dskipTill                    :longint32;
   dcanblankline                :boolean;

   ddropCapOne                  :longint32;//single large letter OR symbol + letter - 23oct2026
   ddropCapOneTo                :longint32;

   ddropCapsFrom                :longint32;//upto first 3 words in small caps
   ddropCapsTo                  :longint32;
   ddropCapsWordCount           :longint32;

   u                            :longint32;
   s                            :tslotstyle;

   procedure a(const c:longint32);
   begin

   xcore.s.addint4( c  );

   end;

   procedure sa8(const c:longint32;const newChar:byte);//windows-1252 to unicode
   begin

   if (c>=1) and (c<=xcore.tlen) then xcore.t.s_8( pred(c) ,newChar );

   xcore.s.addint4( c  );

   end;

   procedure astr8(const c:string);
   var
      p               :longint32;

   begin

   for p:=1 to low__len32(c) do a(byte( c[p-1+stroffset] ));

   end;

   function tc8(const xpos1:longint32):byte;
   begin

   if (xpos1>=1) and (xpos1<=xcore.tlen) then result:=xcore.t.g_8b( pred(xpos1) )
   else                                       result:=10;

   end;

   function tstr8(const xpos1,xlen:longint32):string;
   var
      p                         :longint32;
      i                         :longint32;

   begin

   //check
   if (xlen<=0) then
      begin

      result                    :='';

      exit;

      end;

   //init
   low__setlen( result ,xlen );
   i                            :=1;

   //get
   for p:=xpos1 to pred(xpos1+xlen) do
   begin

   result[ i - 1 + stroffset ]  :=char( tc8( p ) );

   inc( i );

   end;//p

   end;

   function xfindAlign(const xpos1:longint32):longint32;
   begin

   result                       :=xcore.t.findalign( pred(xpos1) );//scan to end of line for alignment code - 16oct2026

   end;

   procedure xstopline;//stop line
   begin

   if dstartLine then
      begin

      dstartLine                :=false;

      a( pub_stopLine );

      end

   else if (not xcore.dnoBlanklines) then
      begin

      if dcanblankline then a( pub_blankLine );//done first line and skipped it's trailing return code

      end;

   end;

begin


//defaults
result                          :=false;
dstartPos                       :=1;
dheadTo                         :=0;

ddropCapOne                     :=0;
ddropCapOneTo                   :=0;

ddropCapsFrom                   :=0;
ddropCapsTo                     :=0;
ddropCapsWordCount              :=0;


//init -------------------------------------------------------------------------

with xcore do
begin

s.clear;
docHeading                      :='';

end;

//check
if (xcore.t=nil) then exit;


//formatting -------------------------------------------------------------------

//.sceneSep
if (xcore.sceneSep>=1) then pub__formatSceneSep( xcore.t );

//.formatUP
if (xcore.formatUp>=1) then pub__formatUp( xcore.t );

//.quotesSingle
case xcore.quotesSingle of

1:pub__quotesSinglePlain( xcore.t );//plain/straight
2:pub__quotesSingleCurly( xcore.t );//curly

end;//case

//.quotesDouble
case xcore.quotesDouble of

1:pub__quotesDoublePlain( xcore.t );//plain/straight
2:pub__quotesDoubleCurly( xcore.t );//curly

end;//case


//find start of page -----------------------------------------------------------

for p:=1 to frcmax32( xcore.tlen ,pub_preprocessingScanLen ) do
begin

xcore.t.g_82( pred(p) ,u ,s );

if (s=s_i) then
   begin

   dstartPos          :=p;
   break;

   end;

if (s=s_t) and windows1252__charVisible( u ) then
   begin

   dstartPos          :=p;
   break;

   end;

end;//p


//find page heading ------------------------------------------------------------

bol1                  :=false;

for p:=dstartPos to frcmax32(xcore.tlen,pub_preprocessingScanLen) do
begin

xcore.t.g_82( pred(p) ,u ,s );

if (s=s_t) then
   begin

   case u of

   10:if bol1 then break;

   else if windows1252__charVisible( u ) or (u=32) or (u=160) then
      begin
      
      bol1                                :=true;
      dheadTo                             :=p;

      u8__wcStr( xcore.docHeading ,xcore.t.g_ub(pred(p)) );

      end;

   end;//case

   end

else if (s=s_i) then
   begin

   dheadTo                                :=p;
   break;

   end;


end;//p


//header processing ------------------------------------------------------------

if (dheadTo>=dstartPos) and (not xcore.dnoHeading) then
   begin

   //start
   a( pub_startLineHeader );

   lc                           :=10;

   //get
   for p:=dstartPos to dheadTo do
   begin

   xcore.t.g_u( pred(p) ,u ,s );

   //.image
   if      (s=s_i) then
      begin

      a( p )

      end

   //.text
   else if (s=s_t) then
      begin

      //.text character
      case u of

      32,160                         :if (lc<>32) and (lc<>160) then sa8(p,32);//single standard space

      else if (u>=32) then         a(p);

      end;//case

      end;

   //.last character
   lc                             :=u;

   end;//p

   //stop
   a( pub_stopLineHeader );

   end;


//drop caps processing ---------------------------------------------------------

if (xcore.ddropCaps>=1) then
   begin

   //init
   lc                           :=10;

   //get
   for p:=succ(largest32(dstartPos,dheadTo)) to xcore.tlen do
   begin

   xcore.t.g_82( pred(p) ,u ,s );

   //.stop
   if (u=10) and (ddropCapsFrom>=1) then break;

   //.decide
   if (s=s_t) then
      begin

      case xcore.ddropCaps of

      1..2:if windows1252__charVisible( u ) then
           begin

           if (ddropCapOne=0) then
              begin

              if (xfindAlign(p+1)=0) then
                 begin

                 ddropCapOne    :=p;//23oct2026
                 ddropCapOneTo  :=p;

                 end

              else break;

              end;

           if (ddropCapOne>=1) and windows1252__charIsLetter( u ) then
              begin

              ddropCapOneTo  :=p;

              break;

              end;

           end;

      3..pub_dropcaps_max:begin

         //cancel
         if (xfindAlign(p+1)<>0) then break;

         //start
         if windows1252__charVisible( u ) and (ddropCapsFrom=0) then
            begin

            ddropCapsFrom       :=p;

            end;

         //stop
         ddropCapsTo            :=p;

         if ((u=32) or (u=160)) and (lc<>32) and (lc<>160) then
            begin

            inc( ddropCapsWordCount );

            if (ddropCapsWordCount>=xcore.ddropWordLimit) then break;

            end;

         end;

      end;//case

      end;//t

   //.lc
   lc                              :=u;

   end;//p

   end;//if


//body text processing ---------------------------------------------------------

//init
lc                           :=10;
dfirstLine                   :=false;
dstartLine                   :=false;
dskipTill                    :=0;
xfrom                        :=succ(largest32(dstartPos,dheadTo));
dcanblankline                :=false;//first line not done yet

//get
for p:=xfrom to xcore.tlen do
begin

//.skip
if (p<=dskipTill) then goto skipone;

//.read unicode character
xcore.t.g_u( pred(p) ,u ,s );

//.start line
if (not dstartline) and  ( (s=s_i) or ((s=s_t) and windows1252__charVisible(u__to8b(u)) ) ) then
   begin

   //.start the line of text
   if (xcore.dblankLine>=1) and xcore.dblankLineAutoInsert and dfirstLine then a( pub_blankLine );

   dstartline                   :=true;
   lc                           :=10;

   case ( dfirstLine or (xcore.dindentFirst>=1) ) and (xcore.dindentChars>=1) of

   true:begin

      case xfindAlign( p ) of

      0   :a(pub_startLineIndentL);
      1   :a(pub_startLineIndentC);
      2   :a(pub_startLineIndentR);
      else a(pub_startLineIndentL);

      end;//case

      end;

   else begin

      case xfindAlign( p ) of

      0   :a(pub_startLineL);
      1   :a(pub_startLineC);
      2   :a(pub_startLineR);
      else a(pub_startLineL);

      end;//case

      end;

   end;//case

   dfirstline                   :=true;

   dcanblankline                :=true;//first line is done

   end;

//.image
if      (s=s_i) then
   begin

   a( p );

   end

//.text
else if (s=s_t) then
   begin

   //.start drop.caps
   if      (p = ddropCapOne ) then
      begin

      if ( ddropCapOne >= 1 ) then a( pub_startDropCapOne );

      end

   else if ( ddropCapsFrom >= 1 ) and ( p >= ddropCapsFrom ) then
      begin

      ddropCapsFrom             :=0;//off

      a( pub_startDropCaps );

      end;

   //.text
   case u of

   10                                :xstopline;//stop line
   32,160                            :if (lc<>32) and (lc<>160) then sa8(p,32);//single standard space

   else if (u>=32) then           a(p);

   end;//case

   //.stop drop.caps
   if      ( p = ddropCapOneTo ) then
      begin

      if ( ddropCapOne >= 1 ) then a( pub_stopDropCaps );

      end

   else if ( ddropCapsTo >= 1 ) and ( p >= ddropCapsTo ) then
      begin

      ddropCapsTo               :=0;//off

      a( pub_stopDropCaps );

      end;

   //.special codes
   case u of

   pub_sceneSep0                :sa8( pub_sceneSep ,pub_unusedChar );

   end;//case

   end;

//.last character
lc                             :=u;

skipone:

end;//p

//.finalise
if dstartLine then
   begin

   a( pub_stopLine );

   end;

//.docHeading
if (xcore.docHeading='') then
   begin

   inc( xcore.headingUntitledCount );

   xcore.docHeading             :='Untitled '+k64(xcore.headingUntitledCount);

   end;

//successful
result                                    :=true;

skipend:

end;

function pub__addCoverOrImage(var xcore:tpubinfo;const xfilename:string;const xAsCover:boolean):boolean;
label
   skipend;

var
   p                            :longint32;
   etmp                         :string;
   dindex                       :longint32;
   xformat                      :string;
   xbase64                      :boolean;
   xdocType                     :longint32;
   dmode                        :longint32;
   u                            :longint32;
   s                            :tslotstyle;

   procedure dmarkAsChapterOne(const dindex:longint32);
   begin

   if xcore.dchapterOne and ((dmode=pub_isImageAsDoc) or (dmode=pub_isImageCover)) then
      begin

      pub__setChapterOneOnce( xcore ,dindex );

      end;
      
   end;

begin

//defaults
result                          :=false;
dmode                           :=low__aorb( pub_isImageAsDoc ,pub_isImageCover ,xAsCover );

try


//init -------------------------------------------------------------------------

with xcore do
begin

s.clear;
docHeading                      :='';

end;


//check file format ------------------------------------------------------------

if (xfilename<>'') then
   begin

   pub__fileFormatSupported2( xfilename ,xdocType );

   if (xdocType=pub_fNone) then
      begin

      pub__setFirstError(xcore,'Unsupported file type: '+xfilename);

      goto skipend;

      end;


   //read file from disk -------------------------------------------------------

   if not io__fromfile( xfilename ,@xcore.s ,etmp ) then
      begin

      pub__seterrorFileNotFound2( xcore ,xfilename ,'Image skipped' );

      goto skipend;

      end;


   //file is an image file -----------------------------------------------------

   if (xdocType=pub_fImage) then
      begin

      case mis__format( @xcore.s, xformat, xbase64) of

      true:result        :=pub__addImage2( xcore ,xfilename ,xcore.s ,dmode ,dindex );

      else pub__setFirstError(xcore,'Image corrupt: '+xfilename+'.  Image skipped.');

      end;//case

      if result then dmarkAsChapterOne(dindex);//mark as chapter one

      goto skipend;

      end;

   end;


//file is a document -> extract FIRST IMAGE in document for cover --------------

if xAsCover and (xcore.t<>nil) then
   begin

   for p:=1 to frcmax32(xcore.t.count,pub_scanForCoverInDocLen) do//keep search near beginning of document
   begin

   xcore.t.g_u( pred(p) ,u ,s );

   if (s=s_i) and (xcore.t.image__findwidth(pred(p))>=300) and (xcore.t.image__findheight(pred(p))>=300) then
      begin

      result             :=pub__addImage2( xcore ,xfilename ,xcore.t.image__finddata8(pred(p)) ,dmode ,dindex );

      if result then dmarkAsChapterOne(dindex);//mark as chapter one

      goto skipend;

      end;

   end;//p

   end;


skipend:

except;end;

//clear
xcore.s.clear;

end;

function pub__addViaSplit(var xcore:tpubinfo;const xfilename:string):boolean;
label
   redo ,skipone ,skipdone ,skipend;

var
   etmp                         :string;
   xdocType                     :longint32;
   s                            :tunidoc;
   d                            :tunidoc;
   spos                         :longint32;
   dpos                         :longint32;
   lpos                         :longint32;
   p                            :longint32;
   sline                        :string;
   dblankLineCount              :longint32;

   function str8(const xpos0,xlen:longint32):string;
   begin

   result                       :=s.t_82( xpos0 ,xlen );

   end;

   procedure xaddDoc;
   var
      xok                       :boolean;
      p                         :longint32;
      uu                        :longint32;
      ss                        :tslotstyle;
      vv                        :longint32;

   begin


   //fast ----------------------------------------------------------------------

   if (lpos<=0) and (spos>=s.count) then
      begin

      xcore.t                   :=s;
      xcore.tlen                :=s.count;

      pub__addDocument( xcore );

      xcore.t                   :=nil;
      xcore.tlen                :=0;

      exit;

      end;


   //slow ----------------------------------------------------------------------

   xok                          :=false;

   //scan -> make sure this section has something to see/offer -> e.g one or more images, or some visible text (excluding white space)

   for p:=lpos to pred(spos) do
   begin

   if s.g_r( p ,uu ,ss ,vv ) then
      begin

      case ss of

      s_i:begin

         xok                    :=true;

         break;

         end;

      s_t:begin

         if (uu>32) then
            begin

            xok                 :=true;

            break;

            end;

         end;

      end;//case

      end;

   end;//p

   //check
   if not xok then exit;//nothing to offer -> ignore section/document

   //get -> add section/document
   d.copyfrom3( s ,lpos, pred(spos) );

   xcore.t                      :=d;
   xcore.tlen                   :=d.count;

   pub__addDocument( xcore );

   xcore.t                      :=nil;
   xcore.tlen                   :=0;

   //clear
   d.clear;

   end;

begin

//defaults
result                          :=false;
s                               :=nil;
d                               :=nil;

try

//init
s                               :=doc__uni;
d                               :=doc__uni;
dblankLineCount                 :=0;

pub__codesRead( xcore ,'' );

//get
if xcore.internaldataMode then
   begin


   if not doc__fromdata( s ,@xcore.internaldata ,etmp ) then
      begin

      pub__setFirstError( xcore, 'Bad document format: '+etmp);

      goto skipend;

      end;


   end

else begin

   //file mode -> use file extension to determine format type
   pub__fileFormatSupported2( xfilename ,xdocType );

   //image
   if (xdocType=pub_fImage) then
      begin

      if pub__addCoverOrImage( xcore ,xfilename ,(not xcore.dcoverImageDone) ) then
         begin

         xcore.dcoverImageDone  :=true;//mark as done -> can no longer search for a cover - 14nov2026

         goto skipdone

         end;

      goto skipend;

      end

   //document
   else if (xdocType=pub_fText) then
      begin


      if not doc__fromfile( s ,xfilename ,etmp ) then
         begin

         pub__setFirstError( xcore, 'Bad document format: '+etmp);

         goto skipend;

         end;


      end

   //unknown file type
   else if pub__setFirstError(xcore,'Unsupported file type: '+xfilename+'. File skipped.') then goto skipend;

   end;


//split document into sections and process each as a separate document/image/cover image
spos                  :=0;
lpos                  :=0;

redo:

//detect code section
if ( s.g_8b( spos ) = pub_codesstart1 ) and pub__codesExtractLine( s ,spos ,dpos ,sline ) then
   begin

   //finish previous section
   if pub__codesHasSplit( sline ) and (lpos<>spos) then
      begin

      xaddDoc;

      end;

   //read codes
   pub__codesRead( xcore ,sline );

   if (xcore.codeCount<max32) then inc(xcore.codeCount);

   //fill "code section" with unused chars so it doesn't appear as text within document
   for p:=spos to dpos do s.s_u( p ,pub_unusedChar );

   //inc
   spos               :=dpos;

   if xcore.dsplit then
      begin

      lpos            :=succ(spos);
      dblankLineCount :=0;

      goto skipone;

      end;

   end;

//detect blank lines -> auto split - 14nov2026
if (xcore.dautoSplit>=1) then
   begin

   if (s.g_8b( spos )=10) then
      begin

      if ( s.g_8b( succ(spos) ) = 10 ) then inc( dblankLineCount )
      else                                  dblankLineCount   :=0;//reset

      if (dblankLineCount>=xcore.dautoSplit) then
         begin

         //finish previous section
         xaddDoc;

         //read codes
         pub__codesRead( xcore ,'' );

         //inc
         lpos            :=succ(spos);

         dblankLineCount :=0;//reset

         goto skipone;

         end;

      end

   else begin

      dblankLineCount :=0;//reset

      end;

   end;


//inc
skipone:

inc(spos);
if (spos<s.count) then goto redo;

//finalise
xaddDoc;

//successful
skipdone:

result                          :=true;

inc( xcore.dfileCount );

skipend:

except;end;

//free
if (s<>nil) then freeobj(@s);
if (d<>nil) then freeobj(@d);

end;

function pub__addDocument(var xcore:tpubinfo):boolean;
label
   addfile, redo, skipend;

var
   p                            :longint32;
   etmp                         :string;
   dbold                        :boolean;
   ditalic                      :boolean;
   dunderline                   :boolean;
   dstrikeout                   :boolean;
   dindex                       :longint32;
   dpos                         :longint32;
   slen                         :longint32;
   tlen                         :longint32;
   dsmallCapsActive             :boolean;
   dlinkStart                   :longint32;
   dlinkData                    :tunidoc;
   dfirstLineText               :boolean;
   v                            :longint32;
   u                            :longint32;
   s                            :tslotstyle;
   f                            :punidoc_font;

   function cu(const xpos0:longint32):longint32;
   begin

   if (xpos0>=0) and (xpos0<xcore.t.count) then result:=xcore.t.g_ub( xpos0 )
   else                                       result:=10;

   end;

   procedure uadd(const u:longint32);
   begin

   u8__wc( @xcore.docText ,u );

   end;

   procedure uaddU8(const v:string);//assumes "v" is already utf-8 (unicode) encoded
   begin

   if (v<>'') then xcore.docText.sadd(v);

   end;

   procedure radd8(const v:string);
   var
      p               :longint32;
      du              :longint32;

   begin

   if (v<>'') then
      begin

      for p:=1 to low__len32(v) do
      begin

      u__from8( byte(v[p-1+stroffset]) ,du );

      uadd( du );

      end;//p

      end;

   end;

   procedure ladd8(const v:string);
   begin

   radd8( v + pub_returnCode );

   end;

   procedure dstyle(const xbold,xitalic,xunderline,xstrikeout:boolean);
   var
      r                         :string;

      procedure a(const v:string);
      begin

      if (v<>'') then
         begin

         r  :=r + insstr( '<span class="' ,(r='') ) + insstr(#32,r<>'') + v;

         end;

      end;


   begin

   //stop previous
   if dbold or ditalic or dunderline or dstrikeout then
      begin

      radd8('</span>');

      end;

   //init
   dbold                        :=xbold;
   ditalic                      :=xitalic;
   dunderline                   :=xunderline;
   dstrikeout                   :=xstrikeout;
   r                            :='';

   //get
   if dbold                          then a('bb');
   if ditalic                        then a('ii');

   if      dunderline and dstrikeout then a('us')
   else if dunderline                then a('uu')
   else if dstrikeout                then a('ss');

   //set
   if (r<>'')                        then radd8( r + '">' );

   end;

   procedure noStyle;
   begin

   //stop
   if dbold or ditalic or dunderline or dstrikeout then
      begin

      radd8('</span>');

      end;

   //stop
   dbold                        :=false;
   ditalic                      :=false;
   dunderline                   :=false;
   dstrikeout                   :=false;

   end;

   function dpull(var x:longint32):boolean;
   begin

   //defaults
   result                       :=false;

   //get
   if ((dpos+3)<slen) then
      begin

      x                         :=xcore.s.int4[ dpos ];

      inc( dpos ,4 );

      result                    :=true;

      end;

   end;

   function dstr8(const xshiftPos,xlen:longint32):string;
   var
      p                         :longint32;
      _pos                      :longint32;
      _v                        :longint32;

   begin

   //check
   if (xlen<=0) then
      begin

      result                    :='';

      exit;

      end;

   //init
   low__setlen( result ,xlen );
   _pos                         :=dpos;
   _v                           :=v;

   if (xshiftPos<>0) then
      begin

      dpos                      :=frcmin32( dpos + ( 4 * xshiftPos ) ,0 );

      end;

   //get
   for p:=1 to xlen do
   begin

   if dpull(v) and (v>=0) then
      begin

      result[ p - 1 + stroffset ]  :=char( xcore.t.g_8b(pred(v)) );
      
      end

   else begin

      low__setlen( result ,p );

      break;

      end;

   end;//p

   //restore
   dpos                         :=_pos;
   v                            :=_v;

   end;

   procedure xstopLink;//22oct2026
   var
      v               :string;
      vlabel          :string;

      function xlabel:string;
      begin

      if strmatch(strcopy1(dlinkData.t_8,1,7),'mailto:') then result:='Link to email: '+xml__filterlineFrom8(pub__stripProtocols(dlinkData.t_8))
      else                                                    result:='Link to website: '+xml__filterlineFrom8(dlinkData.t_8);

      end;

   begin

   if (dlinkStart<>max32) then
      begin

      //get
      vlabel                    :=xlabel;

      xcore.docText.setlen( dlinkStart );

      uaddU8(
       '<a target="_blank" title="'+xlabel+'" href="'                              +
       net__encodeforhtmlstr(dlinkData.t_8)                                        +
       '">'                                                                        +

       //.auto strip protocols for visible portion of link:
       pub__stripProtocols( dlinkData.t_8 )                                        +
       '</a>')                                                                     ;

       //stopped
       dlinkStart         :=max32;
       dlinkData.clear;

       end;

   end;

   function xcanStartLink:boolean;
   begin

   result             :=(dlinkStart=max32);

   end;

   procedure xstartLink(const xpos:longint32);
   begin

   if xcanStartLink and (xpos>=1) then
      begin

      dlinkStart      :=xpos;
      dlinkData.clear;

      end;

   end;

   procedure xAutoStartLink;
   var
      str1            :string;

      function m(const xname:string):boolean;
      begin

      result          :=strmatch( xname ,strcopy1(str1,1,low__len32(xname)) );

      end;


   begin

   if xcanStartLink then
      begin

      str1            :=strlow( dstr8( -1, 8) );

      if m('https://') or m('http://') or m('ftp://') or m('ftps://') or m('mailto:') then xstartLink( xcore.docText.len32 );

      end;

   end;

   function xadjustForDropOne(const xlineStartStr:string):string;
   var//searches for "t" = text, and adds "nobreak" for first line of text IF there is a dropCapOne coming up
      apos            :longint32;
      p               :longint32;
      i               :longint32;
      v               :longint32;

   begin

   result             :=xlineStartStr;

   if not dfirstLineText then
      begin

      //init
      apos            :=dpos;

      //get -> scan for a dropCapOne

      for p:=0 to 9 do
      begin

      if dpull(v) then
         begin

         if (v=pub_startDropCapOne) then
            begin

            //yes -> replace "t" with "nobreak t" in output class string
            for i:=1 to low__len32(result) do if strmatch(strcopy1(result,i,3),'"t ') then
               begin

               result :=strcopy1(result,1,i) +'nobreak ' +strcopy1(result,i+1,low__len32(result));

               break;

               end;//i

            break;

            end;

         end

      else break;

      end;

      //restore
      dpos            :=apos;

      //mark as done
      dfirstLineText  :=true;

      end;

   end;


begin

//defaults
result                          :=false;

//init
xcore.docText.clear;
xcore.docHeading                :='';
xcore.docUsedSVG                :=false;
tlen                            :=xcore.t.count;
dbold                           :=false;
ditalic                         :=false;
dunderline                      :=false;
dstrikeout                      :=false;
dsmallCapsActive                :=false;
dlinkdata                       :=nil;
dfirstLineText                  :=false;

try

//scan for an image ------------------------------------------------------------

if not xcore.dcoverImageDone then
   begin

   xcore.dcoverImageDone        :=true;

   result                       :=pub__addCoverOrImage( xcore ,'' ,true );

   goto skipend;

   end;


//add text document ------------------------------------------------------------

//.pre-process document
if not pub__preprocess( xcore ) then
   begin

   goto skipend;

   end;

slen                            :=xcore.s.len32;

//.start html
if (xcore.docXMLencodingStr<>'') then ladd8(xcore.docXMLencodingStr);
ladd8(xcore.docTypeStr);
ladd8('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">');
ladd8('');

ladd8('<head>');
ladd8(xcore.docMetaStr);

uaddU8('<title>' + pub__asTitleU8(xcore.docHeading,pub__title(xcore)) + '</title>');//add RAW unicode

ladd8(xcore.metaListForPage);

ladd8('</head>');

ladd8('');
ladd8('<body>');

ladd8('');


//get --------------------------------------------------------------------------

//init
dpos                            :=0;
dlinkStart                      :=max32;
dlinkData                       :=doc__uni;

//get
redo:

if dpull(v) then
   begin

   //get
   case v of

   pub_blankLine                :begin

                                nostyle;

                                ladd8( xcore.blankLineStr8 );

                                end;

   pub_startLineHeader          :begin

                                nostyle;
                                ladd8( xcore.startLineHeaderStrCurrent8 );

                                end;

   pub_stopLineHeader           :begin

                                xstopLink;

                                nostyle;

                                ladd8( xcore.stopLineHeaderStrCurrent8 );

                                end;

   pub_startLineIndentL         :begin

                                nostyle;
                                radd8( xadjustForDropOne(xcore.startLineIndentLStr) );

                                end;

   pub_startLineIndentC         :begin

                                nostyle;
                                radd8( xadjustForDropOne(xcore.startLineIndentCStr) );

                                end;

   pub_startLineIndentR         :begin

                                nostyle;
                                radd8( xadjustForDropOne(xcore.startLineIndentRStr) );

                                end;

   pub_startLineL               :begin

                                nostyle;
                                radd8( xadjustForDropOne(xcore.startLineLStr) );

                                end;

   pub_startLineC               :begin

                                nostyle;
                                radd8( xadjustForDropOne(xcore.startLineCStr) );

                                end;

   pub_startLineR               :begin

                                nostyle;
                                radd8( xadjustForDropOne(xcore.startLineRStr) );

                                end;

   pub_stopLine                 :begin

                                xstopLink;

                                nostyle;

                                ladd8( xcore.stopLineStr );

                                end;

   pub_sceneSep                 :begin

                                nostyle;

                                if (xcore.dblankLine>=1) then ladd8( xcore.blankLineStr8 );

                                ladd8( xcore.sceneSepStr );

                                if xcore.sepIsSVG then xcore.docUsedSVG :=true;//16nov2026

                                end;

   pub_skip                     :;

   pub_startDropCapOne          :begin

                                case xcore.ddropCaps of
                                1:radd8( pub_dropCapsStart+'abovechar">'  );//Koodo Reader requires "div" for dropcaps to work over size change
                                2:radd8( pub_dropCapsStart+'dropchar">'  );
                                end;//case

                                end;

   pub_startDropCaps            :begin

                                dsmallCapsActive    :=true;
                                radd8( pub_dropCapsStart+'smallcaps">' );

                                end;

   pub_stopDropCaps             :begin

                                dsmallCapsActive    :=false;

                                nostyle;//turn off all styles BEFORE stopping dropcaps STYLE

                                radd8( pub_dropCapsStop                );

                                end;

   0..max32: begin

      xcore.t.g_u( pred(v) ,u ,s );

      //.stop link
      if (s<>s_t) then
         begin

         xstopLink;

         end;

      //.style
      if (s=s_i) or ( (s=s_t) and ((u=9) or (u=10) or (u>=32)) ) then
         begin

         f            :=xcore.t.font__findslot(pred(v));

         if ( ( dbold      <>f.bold       ) or
              ( ditalic    <>f.italic     ) or
              ( dunderline <>f.underline  ) or
              ( dstrikeout <>f.strikeout  )
              ) then

            begin

            dstyle(
            f.bold      ,
            f.italic    ,
            f.underline ,
            f.strikeout
            );

            end;

         end;

      //.text character
      if (s=s_t) then
         begin

         //.link scanner - start
         case u of

         llh,uuH ,llf,uuf ,llm,uum :xAutoStartLink;

         9,10,32,160               :xstopLink;

         end;//case

         //.dsmallCapsActive case filter -> do AFTER "link scanner.start", as the scanner resets "fc.c" - 23oct2026
         if dsmallCapsActive then
            begin

            case u of
            lla..llz:dec(u,32);//a -> A
            end;//case

            end;

         //.link raw char collector
         if (dlinkStart<>max32) then
            begin

            dlinkData.a_u(u);

            end;

         //.text character
         case u of

         32,160                        :radd8(#32);//single spaces only
         else if (u>=32) then           uadd( u );//unicode

         end;//case

         end


      //.image
      else if (s=s_i) then
         begin

         if pub__addImage( xcore ,xcore.t.image__finddata8(pred(v)) ,pub_isImageData ,dindex ) then
            begin

            //scale image to fit within page dimensions - 20oct2026
            radd8('<img'+insstr(' class="fit"' ,(cu(v-2)=10) and (cu(v)=10) )+' alt="Inline Image" style="aspect-ratio:'+pub__single(xcore.t.image__findwidth(pred(v))/frcmin32(xcore.t.image__findheight(pred(v)),1))+';" src="'+xcore.name[dindex]+'" />');//the trailing back slash "/>" is required for Adobe Digital Editions to display multiple images without error - 17oct2026

            end;

         end;

      end;//begin

   end;//case

   //loop
   goto redo;

   end;//case

//.stop link
xstopLink;

//.stop html
ladd8('');
ladd8('</body>');

ladd8('');
ladd8('</html>');

//.addfile
result                          :=pub__addfile( xcore ,pub_html ,xcore.docText.text ,'' ,dindex );//utf-8

if result then
   begin

   if xcore.docUsedSVG then
      begin

      xcore.svgUsed[dindex]     :=true;

      end;

   if xcore.dchapterOne then pub__setChapterOneOnce( xcore ,dindex );

   xcore.headingU8[dindex]      :=pub__asTitleU8( xcore.docHeading ,'' );

   end;

goto skipend;


//finish -----------------------------------------------------------------------

skipend:

except;end;

//error
if (not result) then
   begin

   pub__setFirstError(xcore,'Failed to make document. Document skipped.');

   end;

//free
if (dlinkdata<>nil) then freeobj(@dlinkdata);

//inc
if (xcore.dsectionCount     <max32) then inc(xcore.dsectionCount);
if (xcore.dsectionTotalCount<max32) then inc(xcore.dsectionTotalCount);

end;

function pub__addfile(var xcore:tpubinfo;const dstyle:longint32;const xdata,xrefData:string;var dindex:longint32):boolean;
var
   p                  :longint32;
   dname              :string;

begin

//defaults
result                :=false;
dindex                :=0;

//check
if (dstyle<=pub_none) then exit;

//find free slot
for p:=0 to high(xcore.style) do
begin

if (xcore.style[p]=pub_none) then
   begin

   //get
   xcore.style[p]     :=dstyle;

   case xcore.style[p] of

   pub_html        :begin

                   xcore.format[p]        :='html';
                   dname                  :='section' + pub__digPad(xcore.count_text) + '.html';
                   xcore.nval[p]          :=xcore.count_text;
                   inc( xcore.count_text);

                   end;

   pub_xhtml       :begin

                   xcore.format[p]        :='xhtml';
                   dname                  :='section' + pub__digPad(xcore.count_text) + '.xhtml';
                   xcore.nval[p]          :=xcore.count_text;
                   inc( xcore.count_text);

                   end;

   pub_titlePage   :begin

                   xcore.format[p]        :='xhtml';
                   dname                  :='titlepage.xhtml';

                   end;

   pub_contentshtml:begin

                   xcore.format[p]        :='html';
                   dname                  :='contents.html';

                   end;

   pub_contentopf  :begin

                   xcore.format[p]        :='opf';
                   dname                  :='content.opf';

                   end;

   pub_tocncx      :begin

                   xcore.format[p]        :='ncx';
                   dname                  :='toc.ncx';

                   end;

   pub_TOCxhtml    :begin

                   xcore.format[p]        :='xhtml';
                   dname                  :='toc.xhtml';

                   end;


   pub_styleSheetcss:begin

                   xcore.format[p]        :='css';
                   dname                  :='css/stylesheet.css';

                   end;

   pub_image      :begin

                   xcore.format[p]        :=strlow( io__anyformatc(xdata) );
                   dname                  :='images/image' + pub__digPad(xcore.count_image) + '.'+xcore.format[p];
                   xcore.nval[p]          :=xcore.count_image;

                   inc( xcore.count_image);

                   end;

   pub_coverjpg   :begin

                   xcore.format[p]        :=strlow( io__anyformatc(xdata) );
                   dname                  :='images/cover' + '.'+xcore.format[p];

                   end;

   pub_svg        :begin

                   xcore.format[p]        :='svg';
                   dname                  :='images/svg' + pub__digPad(xcore.count_svg) + '.svg';//16nov2026
                   xcore.nval[p]          :=xcore.count_svg;

                   inc( xcore.count_svg);

                   end;

   end;//case

   xcore.name[p]                          :=dname;
   xcore.nref[p]                          :=crc32__nonzero( dname );
   xcore.data[p]                          :=xdata;
   xcore.dataLen[p]                       :=low__len32(xdata);//19oct2026

   xcore.refdata[p]                       :=xrefData;
   xcore.refdataLen[p]                    :=low__len32(xrefData);//19oct2026

   inc( xcore.count );


   //xxxxxxxxxxxxxxxxx//????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   io__tofilestr2( xcore.buildFolder + 'test-ccc\' + dname ,xdata );//?????????????

   //successful
   result          :=true;
   dindex          :=p;

   //stop
   break

   end;

end;//p



end;

function pub__addImage(var xcore:tpubinfo;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;
begin

result      :=pub__addImage2( xcore ,'' ,simageStream ,dimageStorageStyle ,dindex );

end;

function pub__addImage2(var xcore:tpubinfo;const simageFileNameForRefOnly:string;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;//03nov2026
var
   d                  :tstr8;
   dtitle             :string;
   etmp               :string;
   dw                 :longint32;
   dh                 :longint32;

   function dneed:boolean;
   begin

   result             :=true;

   if (d=nil) then d  :=faststr__new8;

   end;

   function xalreadyHaveImage(const s:tstr8):boolean;//03nov2026
   var
      v               :string;
      slen            :longint32;
      vlen            :longint32;
      p               :longint32;

   begin

   //defaults
   result             :=false;

   //check
   if (s=nil) or (s.len32<=0) then exit;

   //init
   slen               :=s.len32;
   v                  :=s.str1[1,1000];
   vlen               :=low__len32(v);

   //find
   for p:=0 to pred(xcore.count) do
   begin
                                                                                                    //quick compare                        //full compare
   if ((xcore.style[p]=pub_image) or (xcore.style[p]=pub_coverjpg)) and (slen=xcore.dataLen[p]) and (v=strcopy1(xcore.data[p],1,vlen)) and (s.text=xcore.data[p]) then
      begin

      result          :=true;
      dindex          :=p;

      break;

      end;

   end;//p

   end;

   function xaddfile(var xcore:tpubinfo;const dstyle:longint32;const xdata,xrefData:string;var dindex:longint32;const dw,dh:longint32):boolean;
   begin

   result             :=pub__addfile( xcore ,dstyle ,xdata ,xrefData ,dindex );

   if result then
      begin

      xcore.w[dindex] :=dw;
      xcore.h[dindex] :=dh;

      end;

   end;

begin

//defaults
result                :=false;
dindex                :=0;
d                     :=nil;

try

//normal image
if (dimageStorageStyle=pub_isImageData) then
   begin

   case xalreadyHaveImage(simageStream) of

   true:result        :=true;
   else result        := dneed and pub__convertImage( xcore ,simageStream ,d ,false ,dw ,dh ,etmp ) and
                                   ( xalreadyHaveImage(d) or xaddfile( xcore ,pub_image ,d.text ,simageStream.text ,dindex ,dw ,dh ) );

   end;//case

   end

//image as doc
else if (dimageStorageStyle=pub_isImageAsDoc) then
   begin

   //init
   case xalreadyHaveImage(simageStream) of

   true:result        :=true;
   else result        := dneed and pub__convertImage( xcore ,simageStream ,d ,false ,dw ,dh ,etmp ) and
                                   ( xalreadyHaveImage(d) or xaddfile( xcore ,pub_image ,d.text ,simageStream.text ,dindex ,dw ,dh ) );
   end;//case

   //make image png or jpg
   if result then
      begin

      //init
      dtitle          :=pub__asTitle( io__remlastext(io__extractfilename( simageFileNameForRefOnly )) ,'' );

      //image0000.html
      d.text:=
      xcore.docXMLencodingStr+insstr(pub_returnCode,xcore.docXMLencodingStr<>'')+
      xcore.docTypeStr+pub_returnCode+
      '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xml="http://www.w3.org/XML/1998/namespace" xml:lang="en">'+pub_returnCode+

      pub_returnCode+
      '<head>'+pub_returnCode+
      xcore.docMetaStr+pub_returnCode+
      '<title>'+xml__filterlineFrom8(dtitle)+'</title>'+pub_returnCode+
      xcore.metaListForPage+pub_returnCode+
      '</head>'+pub_returnCode+

      pub_returnCode+
      '<body>'+pub_returnCode+

      pub_returnCode+

      xcore.startLineHeaderStrCurrent8 + dtitle + xcore.stopLineHeaderStrCurrent8 + pub_returnCode +

//was: '<div class="t c"><img src="'+xcore.name[dindex]+'" alt="'+xml__filterlineFrom8(dtitle)+'" style="aspect-ratio:'+pub__single(xcore.w[dindex]/frcmin32(xcore.h[dindex],1))+';max-width:100%;" /></div>'+pub_returnCode+
      '<div class="t c"><img class="fit" src="'+xcore.name[dindex]+'" alt="'+xml__filterlineFrom8(dtitle)+'" style="aspect-ratio:'+pub__single(xcore.w[dindex]/frcmin32(xcore.h[dindex],1))+';" /></div>'+pub_returnCode+

      pub_returnCode+
      '</body>'+pub_returnCode+

      pub_returnCode+
      '</html>'+pub_returnCode;

      //add file -> return document slot instead of image slot
      if pub__addfile( xcore ,pub_html ,u8__from8strb( d.text ) ,'' ,dindex ) then//utf-8
         begin

         //heading for contents.html
         xcore.headingU8[dindex]          :=xml__filterlineFrom8( dtitle );

         end;

      end;

   end

//image as cover
else if (dimageStorageStyle=pub_isImageCover) then
   begin

   //make jpg
   if dneed and pub__convertImage( xcore ,simageStream ,d ,true ,dw ,dh ,etmp ) and xaddfile( xcore ,pub_coverjpg ,d.text ,simageStream.text ,dindex ,dw ,dh ) then
      begin

      //init
      result                    :=true;//successful

      //titlepage.xhtml
      d.text:=
      xcore.docXMLencodingStr+insstr(pub_returnCode,xcore.docXMLencodingStr<>'')+
      xcore.docTypeStr+pub_returnCode+
      '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xml="http://www.w3.org/XML/1998/namespace" xml:lang="en">'+pub_returnCode+

      pub_returnCode+
      '<head>'+pub_returnCode+
      xcore.docMetaStr+pub_returncode+
      '<title>'+pub_labelFrontCover+'</title>'+pub_returnCode+//13nov2026
      xcore.metaListForPage+pub_returnCode+

      '<style type="text/css" title="override_css">'+
      '* {height:100% !important;overflow:hidden !important;padding:0 !important;margin:0 !important;text-align:center !important;} '+
      '</style>'+pub_returnCode+

      '</head>'+pub_returnCode+

      pub_returnCode+
      '<body>'+pub_returnCode+

      //Note: <div>...</div> required for v2                                                                      //overflow:hidden - required - 12nov2026
      '<div><img class="cover" src="'+xcore.name[dindex]+'" alt="Cover art for '+xml__filterlineFrom8(pub__title(xcore))+'" /></div>'+pub_returnCode+

      '</body>'+pub_returnCode+

      pub_returnCode+
      '</html>'+pub_returnCode;

      //add file -> return document slot instead of image slot
      pub__addfile( xcore ,pub_titlepage ,u8__from8strb( d.text ) ,'' ,dindex );//utf-8

      xcore.slot_titlepageXhtml :=dindex;

      end;

   end;

except;end;

//free
if (d<>nil) then faststr__free(@d);

end;

function pub__addSVG(var xcore:tpubinfo;const xsvgData:string;var dindex:longint32):boolean;

   function xalreadyHaveImage:boolean;//03nov2026
   var
      v               :string;
      slen            :longint32;
      vlen            :longint32;
      p               :longint32;

   begin

   //defaults
   result             :=false;

   //init
   slen               :=low__len32(xsvgData);
   v                  :=strcopy1(xsvgData,1,50);
   vlen               :=low__len32(v);

   //find
   for p:=0 to pred(xcore.count) do
   begin
                                                              //quick compare                        //full compare
   if (xcore.style[p]=pub_svg) and (slen=xcore.dataLen[p]) and (v=strcopy1(xcore.data[p],1,vlen)) and (xsvgData=xcore.data[p]) then
      begin

      result          :=true;
      dindex          :=p;

      break;

      end;

   end;//p

   end;

begin

//defaults
dindex                :=0;

//get
result                :=xalreadyHaveImage or pub__addfile( xcore ,pub_svg ,xsvgData ,xsvgData ,dindex );

end;

function pub__addContents(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   procedure hadd(const findex:longint32);
   begin

   if (findex>=0) and (findex<xcore.count) and ( (xcore.style[findex]=pub_html) or (xcore.style[findex]=pub_xhtml) ) then
      begin

      ladd( xcore.startBeginContentsLineStr + ' id="section'+pub__digPad(xcore.nval[findex])+'"><a href="section'+pub__digPad(xcore.nval[findex])+'.'+xcore.format[findex]+'">'+xcore.headingU8[findex]+'</a></p>');

      end;

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;

//get
ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');//required for v2
ladd(xcore.docTypeStr);
ladd('<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xml="http://www.w3.org/XML/1998/namespace" xml:lang="en">');

ladd('');
ladd('<head>');
ladd(xcore.docMetaStr);
ladd('<title>' + pub_labelTableOfContents + '</title>');
ladd(xcore.metaListForPage);
ladd('</head>');

ladd('');
ladd('<body>');

ladd('');
ladd( u8__from8strb(xcore.startLineHeaderStrPlain8) + pub_labelTableOfContents + u8__from8strb(xcore.stopLineHeaderStrPLain8) );

//.cover
if (xcore.slot_titlepageXhtml>=0) then ladd( xcore.startBeginContentsLineStr + ' id="titlepage"><a href="titlepage.xhtml">'+pub_labelFrontCover+'</a></p>');

//.chapters/documents
for p:=0 to pred(xcore.count) do hadd(p);

ladd('');
ladd('</body>');

ladd('');
ladd('</html>');

//add files
pub__addfile( xcore ,pub_contentshtml ,b.text ,'' ,xcore.slot_contentsHtml );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__addTOCxhtml(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;

   function xtype3(const v:string):string;
   begin

   case xcore.epubVersion of

   3   :result:=' epub:type="'+v+'"';
   else result:='';

   end;//case

   end;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   procedure tocAdd(const findex:longint32);
   begin

   if (findex>=0) and (findex<xcore.count) and ( (xcore.style[findex]=pub_html) or (xcore.style[findex]=pub_xhtml) ) then
      begin

      ladd('<li><a href="section'+pub__digPad(xcore.nval[findex])+'.'+xcore.format[findex]+'">'+xcore.headingU8[findex]+'</a></li>');

      end;

   end;

   procedure landAdd(const findex:longint32);
   var
      xnavType                  :string;

   begin

   if (findex>=0) and (findex<xcore.count) and ( (xcore.style[findex]=pub_html) or (xcore.style[findex]=pub_xhtml) ) then
      begin

      //init
      case (findex=xcore.firstChapterIndex) of
      true:xnavType:=xtype3('bodymatter');//first chapter - v3 only
      else xnavType:='';
      end;//case

      //get
      ladd('<li><a href="section'+pub__digPad(xcore.nval[findex])+'.'+xcore.format[findex]+'"'+xnavType+'>'+xcore.headingU8[findex]+'</a>');

      end;

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;

//get
if (xcore.docXMLencodingStr<>'') then ladd(xcore.docXMLencodingStr);
ladd(xcore.docTypeStr);
ladd('<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="en">');

ladd('');
ladd('<head>');
ladd(xcore.docMetaStr);
ladd('<title>' + pub_labelTableOfContents + '</title>');
ladd(xcore.metaListForPage);
ladd('</head>');

ladd('');
ladd('<body>');


//toc list -> machine readable "Table of Contents" v3 --------------------------
ladd('');
ladd('<nav epub:type="toc" id="toc" role="doc-toc">');
ladd( u8__from8strb(xcore.startLineHeaderStrTOC8) + pub_labelTableOfContents + u8__from8strb(xcore.stopLineHeaderStrTOC8) );
ladd('<ol>');

//Warning: Koodo Reader appears to use link labels "<a href>...label...</a>" to navigate the Table of Contents,
//         consequently two or more entries with the same label causes navigation failure - last link instance
//         take precedence.
if (xcore.slot_titlepageXhtml>=0) then ladd('<li><a href="titlepage.xhtml">'+pub_labelFrontCover+'</a></li>');

for p:=0 to pred(xcore.count) do tocAdd(p);

ladd('</ol>');
ladd('</nav>');


//landmarks list -> machine readable (main parts only for e-readers) v3 --------
ladd('');
ladd('<nav epub:type="landmarks" id="landmarks" hidden="hidden">');

ladd( u8__from8strb(xcore.startLineHeaderStrTOC8) +  'Landmarks' + u8__from8strb(xcore.stopLineHeaderStrTOC8) );
ladd('<ol>');

if (xcore.slot_titlepageXhtml>=0) then ladd('<li><a epub:type="cover" href="titlepage.xhtml">'+pub_labelFrontCover+'</a></li>');
ladd('<li><a epub:type="toc" href="toc.xhtml#toc">'+pub_labelTableOfContents+'</a></li>');

case (xcore.firstChapterIndex>=0) of
true:ladd('<li><a epub:type="bodymatter" href="'+xcore.name[xcore.firstChapterIndex]+'">'+xcore.headingU8[xcore.firstChapterIndex]+'</a></li>');
else ladd('<li><a epub:type="bodymatter" href="toc.xhtml">'+pub_labelTableOfContents+'</a></li>');//contents
end;//case

ladd('</ol>');
ladd('</nav>');

ladd('');
ladd('</body>');

ladd('');
ladd('</html>');

//add files
pub__addfile( xcore ,pub_TOCxhtml ,b.text ,'' ,xcore.slot_TOCxhtml );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__addStylesheet(var xcore:tpubinfo):boolean;//11nov2026
var//Note: CSS rule -> classes defined last have higher precedence when overriding
   b                            :tstr8;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   procedure vadd(const v:string);
   begin

   if (v<>'') then
      begin

      if  ( strcopy1(v,low__len32(v),1) <> ';' ) then ladd( v + ';' )
      else                                            ladd( v       );

      end;

   end;

   procedure lsup2(const n,v1,v2:string);
   begin//v1 or v2

   //old engine support

   if (v1<>'') then
      begin

      ladd( ''                                                  );
      ladd( n + ' {'                                            );

      vadd(v1);

      ladd( '}'                                                 );

      end;

   //new engine support
   if (v2<>'') then
      begin

      ladd( ''                                   );
      ladd( '@supports (display:flex) {'         );
      ladd( n + ' {'                             );

      vadd(v2);

      ladd( '}'                                  );
      ladd( '}'                                  );

      end;

   end;

   procedure lzoom(const n:string;const dzoom100:longint32;const vlist:array of string);
   var
      p               :longint32;
      
   begin

   //check
   if (n='') then exit;

   //old engine support
   ladd( ''                                                  );
   ladd( n + ' {'                                            );

   for p:=0 to high(vlist) do if (vlist[p]<>'') then vadd( vlist[p] );

   ladd( 'font-size:' + pub__singleADE(dzoom100/100) + 'em;' );

   ladd( '}'                                                 );

   //new engine support
   ladd( ''                                   );
   ladd( '@supports (display:flex) {'         );
   ladd( n + ' {'                             );
   ladd( 'font-size:1em;'                     );
   ladd( 'zoom: ' + intstr32(dzoom100) + '%;' );
   ladd( '}'                                  );
   ladd( '}'                                  );

   end;

   procedure l5(const n,v1,v2,v3,v4,v5:string);
   begin

   //check
   if (n='') then exit;

   //get
   ladd( ''           );
   ladd( n + ' {'     );

   if (v1<>'') then vadd(v1);
   if (v2<>'') then vadd(v2);
   if (v3<>'') then vadd(v3);
   if (v4<>'') then vadd(v4);
   if (v5<>'') then vadd(v5);

   ladd( '}'          );

   end;

   procedure l4(const n,v1,v2,v3,v4:string);
   begin

   l5(n,v1,v2,v3,v4,'');

   end;

   procedure l3(const n,v1,v2,v3:string);
   begin

   l5(n,v1,v2,v3,'','');

   end;

   procedure l2(const n,v1,v2:string);
   begin

   l5(n,v1,v2,'','','');

   end;

   procedure l1(const n,v:string);
   begin

   l5(n,v,'','','','');

   end;

   function dmakeHeaderSize(const dsize100:longint32):longint32;
   begin

   result             :=round32( xcore.headerSize * (dsize100/100) );

   end;

   function dEM100(const dsize100:longint32):string;
   begin

   result             :=pub__singleADE(dsize100/100)+'em';

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;

ladd('@namespace h "http://www.w3.org/1999/xhtml";');

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//ssssssssssssssssssssssssssssssssss//??????????????????????????????????????


//dual mode CSS for old and new EPUB render engines - 15nov2026
ladd( ''                        );
ladd( '* {'                     );
ladd( 'box-sizing:border-box;'  );
ladd( 'word-break:break-word;'  );
ladd( 'margin:0;'               );
ladd( 'padding:0;'              );
ladd( 'border:0;'               );
ladd( 'line-height:1em;'        );
ladd( 'font-size:1em;'          );
ladd( 'font-style:normal;'      );
ladd( 'font-weight:normal;'     );
ladd( 'text-align:left;'        );
ladd( '}'                       );

ladd( ''                        );
ladd( 'html {'                  );
ladd( 'display:block;'          );
ladd( 'height:100%;'            );
ladd( '}'                       );

ladd( ''                        );
ladd( 'body {'                  );
ladd( 'font-size:' + pub__singleADE(xcore.textSize/100)+'em !important;' );
ladd( '}'                       );

//.zoom levels -> all based on font-size
lzoom( 'h1'           ,xcore.headerSize  ,['text-align:center','line-height:1em'] );

l2( 'h1.tocplain' ,'padding-top:' +dEM100(xcore.headerAbovePlain) ,'padding-bottom:' +dEM100(xcore.headerBelowPlain) );

lzoom( 'p.topplain'   ,dmakeHeaderSize( xcore.headerAbovePlain) ,['line-height:1em'] );
lzoom( 'p.botplain'   ,dmakeHeaderSize( xcore.headerBelowPlain) ,['line-height:1em'] );

lzoom( 'p.top'        ,dmakeHeaderSize(xcore.headerAbove) ,['line-height:1em'] );
lzoom( 'p.mid'        ,dmakeHeaderSize(20               ) ,['line-height:1em'] );//?????????????????? need a variable for this
lzoom( 'p.bot'        ,dmakeHeaderSize(xcore.headerBelow) ,['line-height:1em'] );

lzoom( 'p.blank'      ,xcore.blankline   ,['line-height:1em'] );
lzoom( 'p.blank100'   , 100              ,['line-height:1em'] );

//.list items
l3( 'ol, li' ,'list-style-type:none !important' ,'text-indent:2em !important' ,'padding:0.10em 0 !important' );

l1( 'span' ,'display:inline' );

l1( 'div' ,'display:block' );//16nov2026

l3( 'img' ,'overflow:hidden' ,'padding:0.1em' ,'vertical-align:text-bottom' );

l3( 'img.fit' ,'display:block' ,'width:100%' ,'object-fit:contain' );//for Kindle

l1( 'p.svg' ,'line-height:0' );

lsup2( 'img.cover' ,'height:100%' ,'height:100 vh' );

l3( '.nobreak' ,'-webkit-column-break-inside:avoid' ,'page-break-inside:avoid' ,'break-inside:avoid' );

ladd('');
ladd('.hline10, .hline20, .hline30, .hline40, .hline50 {');
ladd('background:transparent;');
ladd('border:none;');
ladd('border-top:1px solid currentcolor;');
ladd('height:0;');
ladd('width:30%;');
ladd('margin:2em auto;');
ladd('}');

l1( '.hline10' ,'width:10% !important' );
l1( '.hline20' ,'width:20% !important' );
l1( '.hline40' ,'width:40% !important' );
l1( '.hline50' ,'width:50% !important' );

//.align
l1( '.l' ,'text-align:left !important' );
l1( '.c' ,'text-align:center !important' );
l1( '.r' ,'text-align:right !important' );
l3( '.j' ,'text-align:justify !important' ,'text-align-last:left', 'text-justify:inter-word !important' );

//.indent
l1( '.i' ,'text-indent:' + pub__singleADE(low__posn(xcore.indentChars)/2)+'em !important;' );
l1( '.i2' ,'text-indent:2em !important;' );//for Contents page

//.styles
l1('.bb' ,'font-weight:bold !important' );
l1('.ii' ,'font-style:italic !important' );
l1('.uu' ,'text-decoration:underline !important' );
l1('.ss' ,'text-decoration:line-through !important' );
l1('.us' ,'text-decoration:underline line-through !important' );

l1('.vm100' ,'margin:1.00em 0 !important' );//OK - for seps
l1('.vv010' ,'padding:0.10em 0 !important' );

l1( '.t, .s' ,xcore.lineHeightStr );

//.hyperlinks -> do not specify a "font-size" for hyperlinks as Koodo Reader stuffs this up - 12nov2026
l3( 'a, a:link' ,xcore.lineHeightStr ,'text-decoration:none' ,'cursor:pointer' );
l2( 'a:hover' ,'text-decoration:underline' ,'cursor:pointer' );
l2( 'a[href]' ,'text-decoration:none' ,'cursor:pointer' );

//.dropCaps
lzoom( '.abovechar' ,2 * xcore.textSize ,['margin-right:0.02em'] );

//.dropChar
lzoom( '.dropchar' ,round32( 2.5 * xcore.textSize * (xcore.lineheight/100) ) ,
 [ 'line-height:' +pub__singleADE( 0.80 ) + 'em' ,
   'float:left' ,
   'margin-right:0.10em' ,
   'margin-top:0.05em' ,
   'vertical-align:top'
 ]
);

//.smallCaps
lzoom( '.smallcaps' ,70 ,['font-weight:bolder'] );

//.sep
l1( '.sep' ,'letter-spacing:0.55em !important' );

//add file
pub__addfile( xcore ,pub_styleSheetcss ,u8__from8strb( b.text ) ,'' ,xcore.slot_stylesheetcss );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function crc32__nonzero(const x:string):longint32;//15oct2026
var
   a                            :tstr8;

begin

//defaults
result                          :=0;
a                               :=nil;

try

//init
a                               :=faststr__new8;
a.text                          :=x;

//get
result                          :=low__crc32nonzero(a);

except;end;

//free
faststr__free( @a );

end;

function pub__addContentopf(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;
   donce                        :boolean;
   dtocOnce                     :boolean;

   function xcopyright:string;
   begin

   result                       :=app__info('copyright');

   strdel1(result,1,1);

   result                       :='(c)'+result;

   end;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   function xproperty3(const v:string):string;
   begin

   case xcore.v3 of
   true:result:=' properties="'+v+'"';
   else result:='';
   end;//case

   end;

   procedure sadd(const xstart,xcontent,xend:string);
   begin

   if (xcontent<>'') then ladd(xstart+xcontent+xend);

   end;

   procedure sadd2(const xstart,xcontent,xend:string);
   begin

   if (xcontent<>'') then
      begin

      ladd('');
      ladd(xstart+xcontent+xend);

      end;
      
   end;

   procedure daddSubject(const v:string);
   begin

   if (v<>'') then sadd('<dc:subject>',xml__filterlineFrom8(v),'</dc:subject>');//simple, no cataloguing codes

   end;

   procedure daddBisac(const xindex:longint32;xlabel,xcode:string);
   begin

   //filter
   xlabel             :=stripwhitespace_lt( xlabel );
   xcode              :=stripwhitespace_lt( xcode  );

   //check
   if (xlabel='') or (xcode='') then exit;

   //get
   if xcore.v3 then
      begin

      ladd('');
      sadd('<dc:subject id="bisac-'+intstr32(xindex)+'">',xml__filterlineFrom8(xlabel),'</dc:subject>');
      sadd('<meta refines="#bisac-'+intstr32(xindex)+'" property="authority">','BISAC','</meta>');
      sadd('<meta refines="#bisac-'+intstr32(xindex)+'" property="term">',xml__filterlineFrom8(strup(xcode)),'</meta>');

      end;

   if xcore.v2 then
      begin

      ladd('');
      sadd('<dc:subject>',xml__filterlineFrom8(xlabel),'</dc:subject>');
      sadd('<dc:subject>',xml__filterlineFrom8(xcode),'</dc:subject>');

      end;

   end;

   procedure daddThema(const xindex:longint32;xlabel,xcode:string);
   begin

   //filter
   xlabel             :=stripwhitespace_lt( xlabel );
   xcode              :=stripwhitespace_lt( xcode  );

   //check
   if (xlabel='') or (xcode='') then exit;

   //get
   if xcore.v3 then
      begin

      ladd('');
      sadd('<dc:subject id="thema-'+intstr32(xindex)+'">',xml__filterlineFrom8(xlabel),'</dc:subject>');
      sadd('<meta refines="#thema-'+intstr32(xindex)+'" property="authority">','Thema','</meta>');
      sadd('<meta refines="#thema-'+intstr32(xindex)+'" property="term">',xml__filterlineFrom8(strup(xcode)),'</meta>');

      end;

   if xcore.v2 then
      begin

      ladd('');
      sadd('<dc:subject>',xml__filterlineFrom8(xlabel),'</dc:subject>');
      sadd('<dc:subject>',xml__filterlineFrom8(xcode),'</dc:subject>');

      end;

   end;

   procedure tocOnce;
   begin

   if not dtocOnce then
      begin

      dtocOnce        :=true;

      if xcore.v2 then ladd('<itemref idref="contents" />');
      if xcore.v3 then ladd('<itemref idref="toc" />');

      end;

   end;

begin

//defaults
b                               :=nil;
dtocOnce                        :=false;

try

//init
b                               :=faststr__new8;

//package.start ----------------------------------------------------------------

ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');

ladd(
 '<package xmlns="http://www.idpf.org/2007/opf"'          +
 ' version="'+intstr32(xcore.epubVersion)+'.0"'           +
 ' unique-identifier="'+xcore.dMasterIDname+'"'           +//which ID name "book-uuid" or "book-isbn" name to use for entire ebook
 insstr(' prefix="schema: http://schema.org/"',xcore.v3)  +
 insstr(' xml:lang="en"',xcore.v3)                        +
 '>');


//metadata ---------------------------------------------------------------------

ladd('');
ladd(
 '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/"'       +
 ' xmlns:opf="http://www.idpf.org/2007/opf"'                   +
 insstr(' xmlns:dcterms="http://purl.org/dc/terms/"',xcore.v3) +
 '>');


//.identifiers -----------------------------------------------------------------

//..isbn
if (xcore.disbn<>'') then
   begin

   case xcore.epubVersion of
   3:ladd('<dc:identifier id="book-isbn">'+xcore.disbn+'</dc:identifier>');
   2:ladd('<dc:identifier id="book-isbn" opf:scheme="isbn">'+xcore.disbn+'</dc:identifier>');
   end;//case

   end;

//..uuid
case xcore.epubVersion of
3:ladd('<dc:identifier id="book-uuid">'+xcore.duuid+'</dc:identifier>');
2:ladd('<dc:identifier id="book-uuid" opf:scheme="uuid">'+xcore.duuid+'</dc:identifier>');
end;//case


//.generator -------------------------------------------------------------------

ladd('');

case xcore.epubVersion of
3:begin
   ladd('<dc:contributor id="generator">'+xml__filterlineFrom8(pub__generator)+'</dc:contributor>');
   ladd('<meta refines="#generator" property="role" scheme="marc:relators">bkp</meta>');
   end;

2:ladd('<dc:contributor opf:role="bkp">'+xml__filterlineFrom8(pub__generator)+'</dc:contributor>');
end;//case

ladd('<meta name="generator" content="'+xml__filterlineFrom8(pub__generator)+'" />');

//.title -----------------------------------------------------------------------

ladd('');
ladd('<dc:title>'+xml__filterlineFrom8(pub__title(xcore))+'</dc:title>');


//.language --------------------------------------------------------------------

ladd('');
ladd('<dc:language>en</dc:language>');


//.date ------------------------------------------------------------------------

case xcore.epubVersion of

3:begin

   ladd('');
   ladd('<dc:date>'+pub__releasedate(xcore)+'</dc:date>');
   ladd('<meta property="dcterms:issued">'+pub__releasedate(xcore)+'</meta>');//publication date
   ladd('<meta property="dcterms:modified">'+pub__releasedate(xcore)+'</meta>');//modification date

   end;

2:begin

   ladd('');
   ladd('<dc:date opf:event="publication">'+pub__releasedate(xcore)+'</dc:date>');
   ladd('<dc:date opf:event="modification">'+pub__releasedate(xcore)+'</dc:date>');

   end;

end;//case


//.author ----------------------------------------------------------------------

case xcore.epubVersion of

3:begin

   ladd('');
   ladd('<dc:creator id="author">'+xml__filterlineFrom8(pub__author(xcore))+'</dc:creator>');
   ladd('<meta refines="#author" property="file-as">'+xml__filterlineFrom8(pub__authorR(xcore))+'</meta>');
   ladd('<meta refines="#author" property="role" scheme="marc:relators">aut</meta>');

   if (xcore.authorWebsite<>'') then
      begin

      ladd('<link refines="#author" rel="schema:url" href="'+xml__filterlineFrom8(xcore.authorWebsite)+'" />');

      end;

   end;

2:begin

   ladd('');
   ladd('<dc:creator id="author" opf:file-as="'+xml__filterlineFrom8(pub__authorR(xcore))+'" opf:role="aut">'+xml__filterlineFrom8(pub__author(xcore))+'</dc:creator>');

   if (xcore.authorWebsite<>'') then
      begin

      ladd('<dc:relation>Author Website: '+xml__filterlineFrom8(xcore.authorWebsite)+'</dc:relation>');

      end;

   end;

end;//case


//.publisher -------------------------------------------------------------------

if (xcore.publisher<>'') then
   begin

   //.name of publisher
   ladd('');
   ladd('<dc:publisher id="publisher">'+xml__filterlineFrom8(xcore.publisher)+'</dc:publisher>');//simple, no sorting

   //.more detail
   if xcore.v3 then
      begin

      ladd('<meta refines="#publisher" property="role" scheme="marc:relators">pbl</meta>');
      ladd('<meta refines="#publisher" property="file-as">'+xml__filterlineFrom8(xcore.publisher)+'</meta>');

      end;

   //.url
   if (xcore.publisherUrl<>'') then
      begin

      case xcore.epubVersion of

      3:begin

         ladd('<link rel="dcterms:publisher" href="'+xml__filterlineFrom8(xcore.publisherUrl)+'" />');//v3 -> more native than rel="foaf:homepage" via refines - 13nov2026

         end;

      2:begin

         ladd('<dc:relation>Publisher Website: '+xml__filterlineFrom8(xcore.publisherUrl)+'</dc:relation>');
         ladd('<meta name="publisher:url" content="'+xml__filterlineFrom8(xcore.publisherUrl)+'" />');

         end;

      end;//case

      end;

   end;


//.rights ----------------------------------------------------------------------

sadd2('<dc:rights>',xml__filterlineFrom8(xcore.rights),'</dc:rights>');//simple, no sorting


//.subject ---------------------------------------------------------------------

daddBisac( 1 ,xcore.bisacLabel1 ,xcore.bisacCode1 );
daddBisac( 2 ,xcore.bisacLabel2 ,xcore.bisacCode2 );
daddBisac( 3 ,xcore.bisacLabel3 ,xcore.bisacCode3 );

daddThema( 1 ,xcore.themaLabel1 ,xcore.themaCode1 );
daddThema( 2 ,xcore.themaLabel2 ,xcore.themaCode2 );
daddThema( 3 ,xcore.themaLabel3 ,xcore.themaCode3 );

if (xcore.subject1<>'') or (xcore.subject2>'') or (xcore.subject3<>'') or (xcore.subject4<>'') or (xcore.subject5<>'') then ladd('');
daddSubject( xcore.subject1 );
daddSubject( xcore.subject2 );
daddSubject( xcore.subject3 );
daddSubject( xcore.subject4 );
daddSubject( xcore.subject5 );


//.description -----------------------------------------------------------------

sadd2('<dc:description>',xml__filterlineFrom8(xcore.des),'</dc:description>');//simple


//.book thumbnail --------------------------------------------------------------

if (xcore.slot_titlepageXhtml>=0) then
   begin

   ladd('');
   ladd('<meta name="cover" content="cover-image" />');//v2

   end;

//.metadata.stop ---------------------------------------------------------------

ladd('');
ladd('</metadata>');


//manifest ---------------------------------------------------------------------

ladd('');
ladd('<manifest>');

ladd('<item href="css/stylesheet.css" id="css" media-type="text/css" />');

if (xcore.slot_titlepageXhtml>=0) then
   begin

   ladd('<item href="images/cover.jpg" id="cover-image" media-type="image/jpeg"'+xproperty3('cover-image')+' />');//v3 uses property "cover-image" for book thumbnail detection
   ladd('<item href="titlepage.xhtml" id="titlepage" media-type="application/xhtml+xml" />');

   end;

if xcore.v3 then ladd('<item href="toc.xhtml" id="toc" media-type="application/xhtml+xml"'+xproperty3('nav')+' />');
if xcore.v2 then ladd('<item href="contents.html" id="contents" media-type="application/xhtml+xml" />');

ladd('<item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml" />');

//.documents
donce                 :=false;

for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   if not donce then
      begin

      ladd('');
      donce           :=true;

      end;

   ladd('<item href="'+xcore.name[p]+'" id="section'+pub__digPad(xcore.nval[p])+'" media-type="application/xhtml+xml"'+insstr(' properties="svg"',xcore.v3 and xcore.svgUsed[p])+' />');

   end;

end;//p

//.images
donce                 :=false;

for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_image) then
   begin

   if not donce then
      begin

      ladd('');
      donce           :=true;

      end;

   ladd('<item href="'+xcore.name[p]+'" id="image'+pub__digPad(xcore.nval[p])+'" media-type="'+net__mimefind(io__readfileext(xcore.name[p],false))+'" />');

   end;

end;//p

//.svgs
donce                 :=false;

for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_svg) then
   begin

   if not donce then
      begin

      ladd('');
      donce           :=true;

      end;

   ladd('<item href="'+xcore.name[p]+'" id="svg'+pub__digPad(xcore.nval[p])+'" media-type="'+net__mimefind(io__readfileext(xcore.name[p],false))+'" />');

   end;

end;//p


ladd('</manifest>');


//spine ------------------------------------------------------------------------


ladd('');
ladd('<spine toc="ncx"'+insstr(' page-progression-direction="ltr"',xcore.v3)+'>');

if (xcore.slot_titlepageXhtml>=0) then ladd('<itemref idref="titlepage" />');


ladd('');

//.fallback -> if no SRL then insert TOC at front of book
if (xcore.firstChapterIndex<0) then
   begin

   tocOnce;

   end;

//.sections / chapters
for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   //insert TOC immediately prior to SRL
   if (p=xcore.firstChapterIndex) then tocOnce;

   //document / chapter
   ladd('<itemref idref="section'+pub__digPad(xcore.nval[p])+'" />');

   end;

end;//p

ladd('</spine>');


//guide ------------------------------------------------------------------------

ladd('');
ladd('<guide>');//v2 only, but OK to keep for backwards compatilibty from v3 to v2 readers - 30oct2026

if (xcore.slot_titlepageXhtml>=0) then ladd('<reference type="cover" title="Cover" href="titlepage.xhtml" />');//cover page

if xcore.v2 then ladd('<reference type="toc" title="'+pub_labelTableOfContents+'" href="contents.html" />');//v2
if xcore.v3 then ladd('<reference type="toc" title="'+pub_labelTableOfContents+'" href="toc.xhtml" />');//v3

case (xcore.firstChapterIndex>=0) of
true:ladd('<reference type="text" title="'+xcore.headingU8[xcore.firstChapterIndex]+'" href="'+xcore.name[xcore.firstChapterIndex]+'" />');//first chapter
else begin

   if xcore.v2 then ladd('<reference type="text" title="'+pub_labelTableOfContents+'" href="contents.html" />');//v2
   if xcore.v3 then ladd('<reference type="text" title="'+pub_labelTableOfContents+'" href="toc.xhtml" />');//v3

   end;

end;//case

ladd('</guide>');


//package.stop -----------------------------------------------------------------

ladd('');
ladd('</package>');

//.add file
pub__addfile( xcore ,pub_contentopf ,b.text ,'' ,xcore.slot_contentsOpf );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__addTOCncx(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;
   dcount                       :longint32;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   function dcountstr:string;
   begin

   inc(dcount);

   result                       :=intstr32(dcount);

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;
dcount                          :=0;


//start ------------------------------------------------------------------------

ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');//required for v2
ladd('<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">');


//head -------------------------------------------------------------------------
ladd('');
ladd('<head>');
ladd('<meta name="dtb:uid" content="'+xcore.dMasterID+'" />');
ladd('<meta name="dtb:depth" content="1" />');
ladd('<meta name="dtb:generator" content="'+xml__filterlineFrom8(pub__generator)+'" />');
ladd('<meta name="dtb:totalPageCount" content="0" />');
ladd('<meta name="dtb:maxPageNumber" content="0" />');
ladd('</head>');


//doc title --------------------------------------------------------------------

ladd('');
ladd('<docTitle><text>'+xml__filterlineFrom8(pub__title(xcore))+'</text></docTitle>');
ladd('<docAuthor><text>'+xml__filterlineFrom8(pub__author(xcore))+'</text></docAuthor>');


//nav map ----------------------------------------------------------------------

ladd('');
ladd('<navMap>');

if (xcore.slot_titlepageXhtml>=0) then ladd('<navPoint playOrder="'+dcountStr+'" id="titlepage"><navLabel><text>Cover</text></navLabel><content src="titlepage.xhtml" /></navPoint>');

if xcore.v2 then ladd('<navPoint playOrder="'+dcountStr+'" id="contents"><navLabel><text>'+pub_labelTableOfContents+'</text></navLabel><content src="contents.html" /></navPoint>');
if xcore.v3 then ladd('<navPoint playOrder="'+dcountStr+'" id="contents"><navLabel><text>'+pub_labelTableOfContents+'</text></navLabel><content src="toc.xhtml" /></navPoint>');

for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   ladd('<navPoint playOrder="'+dcountStr+'" id="section'+pub__digPad(xcore.nval[p])+'"><navLabel><text>'+xcore.headingU8[p]+'</text></navLabel><content src="'+xcore.name[p]+'" /></navPoint>');

   end;

end;//p

ladd('</navMap>');


//finish -----------------------------------------------------------------------

ladd('');
ladd('</ncx>');

//.add file
pub__addfile( xcore ,pub_TOCncx ,b.text ,'' ,xcore.slot_tocNcx );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__containerxml:string;//v2 and v3
begin

result:=

'<?xml version="1.0" encoding="'+pub_utf8+'"?>'+pub_returnCode+
'<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">'+pub_returnCode+
'<rootfiles>'+pub_returnCode+
'<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml" />'+pub_returnCode+
'</rootfiles>'+pub_returnCode+
'</container>'+pub_returnCode;

end;

function pub__mimetype:string;//v2 and v3
begin

result:='application/epub+zip';

end;

function pub__version:string;//'ver'
begin

result                :='1.00.2740';

end;

function pub__generator:string;
begin

result:=app__info('name') + ' v'+app__info('ver') + #32#169#32 + low__yearstr(2026) + #32 + app__info('author.name');

end;

function pub__isbnValid(const x:string;var e:string):boolean;
var
   v                  :string;
   vlen               :longint32;
   s                  :string;

   function xcalcCheckDigit:longint32;
   var
      p               :longint32;
      c               :byte;
      w               :longint32;//weight
      t               :longint32;//total
      r               :longint32;//remainder
      alt             :boolean;

   begin

   //defaults
   result             :=0;
   t                  :=0;
   alt                :=false;

   //get - exclude last digit, the check digit
   for p:=1 to frcmax32(vlen,12) do
   begin

   //.digit as an int
   c                            :=byte( v[pred(p)+stroffset] ) - nn0;//char('0..'9') -> int(0..9)

   //.alternating weights
   if alt then w                :=3
   else        w                :=1;

   alt                          :=not alt;

   //.calc
   inc( t ,c * w );

   end;//p

   //.remainder
   r                            :=t - ((t div 10)*10);

   //set
   result                       :=(10-r);

   if (result=10) then result:=0;

   //range
   result                       :=frcrange32( result ,0 ,9 );

   end;

begin

//defaults
result                :=false;
e                     :='OK';

//init
v                     :=pub__isbnFilter( x );
vlen                  :=low__len32( v );

//checkers

//.length
if (vlen<13) then
   begin

   e                  :='Too short, must be 13 digits';
   exit;

   end;

if (vlen>13) then
   begin

   e                  :='Too long, must be 13 digits';
   exit;

   end;

//.leading 3 digits = "978" or "979" for books
s                     :=strcopy1(v,1,3);

if (s<>'978') and (s<>'979') then
   begin

   e                  :='Not a book, leading 3 digits must be "978" or "979"';
   exit;

   end;

//.check digit maths check
if (char(xcalcCheckDigit+nn0)<>strcopy1(v,13,1)) then
   begin

   e                  :='Trailing check digit does not match';
   exit;

   end;

//successful
result                :=true;

end;

function pub__isbnFilter(const x:string):string;
var
   p                  :longint32;
   v                  :byte;
begin

//defaults
result                :='';

//get
for p:=1 to low__len32(x) do
begin

v                     :=byte( x[pred(p)+stroffset] );

case v of
nn0..nn9:result       :=result + char(v);//correct placement of hypens requires online database lookups - 02nov2026
end;//case

end;//p

end;

function pub__isbn(const xcore:tpubinfo):string;//01nov2026;
var
   e                  :string;

begin

if (xcore.isbn<>'') and pub__isbnValid(xcore.isbn,e) then result:='urn:isbn:'+pub__isbnFilter(xcore.isbn)
else                                                      result:='';

end;

function pub__uuid(const xcore:tpubinfo):string;//01nov2026, 20oct2026
var//8-4-4-4-12 hex character structure (total of 36 characters including hyphens):

   v        :string;

begin

v           :=int4__hex8(crc32__nonzero(strlow(xcore.fname+'-'+xcore.lname)));

result      :=

            'urn:uuid:'+//v2 and v3 EPUB

            strlow(//must be lowercase

            //.8 chars
            int4__hex8(crc32__nonzero(strlow(xcore.title)))+//crc32 of book title
            '-'+

            //.4 chars
            strcopy1(v,1,4)+//author name part1 (1..4)
            '-'+
            
            //.4 chars -> leading 4 signifies "random uuid"
            '4e20'+//4 is required and "e20" is our "EPUB v2.0 specification"
            '-'+

            //.4 chars
            'a'+strcopy1(v,5,3)+//8,9,a or b is required and 3c's -> author name part2 (5..7)
            '-'+
            
            //.12 chars
            low__digpad11(xcore.year,4)+//year4
            low__digpad11(xcore.month,2)+//month2
            low__digpad11(xcore.day,2)+//day2
            low__digpad11(xcore.hour,2)+//hour2
            low__digpad11(xcore.minute,2)+//minute2

            '');

end;

function pub__title(const xcore:tpubinfo):string;
begin

result:=pub__asTitle( xcore.title ,'' );

end;

function pub__asTitle(const xlabel,xdef:string):string;//20oct2026
begin

//def
result      :=strdefb( stripwhitespace_lt(xlabel) ,stripwhitespace_lt(strdefb(xdef,'Untitled')) );

//first letter upper case
if (result<>'') then
   begin

   result   :=strup( strcopy1(result,1,1) ) + strcopy1(result,2,low__len32(result));

   end;

end;

function pub__asTitleU8(const u8:string;const xdef8:string):string;//11nov2026
begin

result                :=xml__filterLineFromU8( u8 );

if (result='') then result:=xml__filterlineFrom8(xdef8);//8-bit ascii

end;

function pub__author(const xcore:tpubinfo):string;
begin

result:=xcore.fname+#32+xcore.lname;

end;

function pub__authorR(const xcore:tpubinfo):string;
begin

result:=xcore.lname+', '+xcore.fname;

end;

function pub__releaseDate(const xcore:tpubinfo):string;

   function d2(const v:longint32):string;
   begin

   result             :=low__digpad11(v,2);

   end;

begin

result:=
 d2(xcore.year)+'-'+d2(xcore.month)+'-'+d2(xcore.day)+//date
 'T'+d2(xcore.hour)+':'+d2(xcore.minute)+':'+d2(xcore.second)+'Z';//time

end;

function pub__asEbookFilename(const n:string):string;
begin

if (n<>'') then result  :=io__remlastext( n ) + '.epub'
else            result  :='';

end;

function pub__buildOptionValue(const xvalue:string;const xmin,xmax,xdef:longint32):longint32;//17oct2026
var
   v                                   :string;

begin

//filter
v                                      :=stripwhitespace_lt( xvalue );
v                                      :=low__remcharb( v , ',' );//"1,000" -> "1000"

//get
if      (v='')                                               then result :=xdef
else if (strint32(v)<xmin)                                   then result :=xdef
else if (k64(strint32(v))<>v) and (intstr32(strint32(v))<>v) then result :=xdef
else                                                              result :=frcrange32( strint32(v) ,xmin ,xmax);

end;

function pub__buildOptionBool(const xvalue:string;const xdef:boolean):boolean;//17oct2026
begin

result                                 :=( pub__buildOptionValue( xvalue ,0 ,1 ,insint(1,xdef) ) <> 0 );

end;

function pub__imageIsJpeg(const sformat:string):boolean;
begin

result:=
 strmatch(sformat,'jpg')  or
 strmatch(sformat,'jpeg') or
 strmatch(sformat,'jif');

end;

function pub__imageFormatSupported(const sformat:string):boolean;
begin

result:=
 pub__imageIsJpeg(sformat) or
 strmatch(sformat,'png')   or
 strmatch(sformat,'gif');

end;

function pub__convertImage(var xcore:tpubinfo;const s,d:tstr8;const ximageIsCover:boolean;var doutW,doutH:longint32;var e:string):boolean;
var
   ss                        :tbasicimage;
   dd                        :tbasicimage;
   sformat                   :string;
   dformat                   :string;
   dmustSave                 :boolean;
   etmp                      :string;

   function cover__scale(const s,d:tbasicimage):boolean;
   begin

   //pass-thru
   result                       :=true;

   //check
   if (s=nil) or (d=nil) then exit;

   //get -> switch between 1.5:1 and 1.6:1
   if ( (s.height / frcmin32(s.width,1)) < 1.55) then xcore.dcoverRatio :=1.5
   else                                               xcore.dcoverRatio :=1.6;

   //size
   d.sizeto( xcore.destCoverWidth ,round32(xcore.destCoverWidth*xcore.dcoverRatio) );

   end;

begin

//defaults
result                          :=false;
e                               :=gecTaskfailed;
ss                              :=nil;
dd                              :=nil;
dmustSave                       :=false;
doutW                           :=1;
doutH                           :=1;

//checkers
if not str__ok(@s) then exit;
if not str__ok(@d) then exit;

try

//init
d.clear;

ss                              :=misimg32(1,1);

sformat                         :=io__anyformatb( @s );
dformat                         :=sformat;

//load image
if not mis__fromdata( ss ,@s ,etmp ) then
   begin

   ss.sizeto( 1 ,1 );

   end;

doutW                           :=ss.width;
doutH                           :=ss.height;

//cover image
if ximageIsCover then
   begin

   //init
   dd                           :=misimg32(1,1);

   //get -> size image to cover dimensions -> save as jpeg image
   result                       :=mis__onecell( ss ) and cover__scale( ss ,dd ) and
                                  mis__copyfast( maxarea ,misarea(ss) ,0 ,0 ,misw(dd) ,mish(dd) ,ss ,dd ) and
                                  mis__todata2 ( dd ,@d ,'jpg' ,xcore.dcoverQuality ,etmp );

   xcore.dcoverBytes            :=str__len32( @d );

   doutW                        :=dd.width;
   doutH                        :=dd.height;

   end

//normal image -> retain image OR convert to jpeg
else begin


   //too big -> scale down -----------------------------------------------------

   if (ss.ai.cellwidth>pub_maxWidth) or (ss.ai.cellheight>pub_maxHeight) then
      begin

      //init
      dmustSave                 :=true;

      //reduce to one cell
      mis__onecell( ss );

      doutW                     :=ss.width;
      doutH                     :=ss.height;

      //still to big -> shrink
      if (ss.width>pub_maxWidth) or (ss.height>pub_maxHeight) then
         begin

         //scale down to fit
         low__scaledown( pub_maxWidth ,pub_maxHeight ,ss.width ,ss.height ,doutW ,doutH );

         //range
         doutW                  :=frcmin32( doutW ,1 );
         doutH                  :=frcmin32( doutH ,1 );

         //get
         dd                     :=misimg32( doutW ,doutH );

         mis__copyfast( maxarea ,misarea(ss) ,0 ,0 ,doutW ,doutH ,ss ,dd );

         end;

      end;


   //wrong format -> change ----------------------------------------------------

   if (xcore.imageQuality<=3) then
      begin

      //all images must be jpeg
      dformat                                                 :='jpg';

      end

   else if (xcore.imageQuality<=4) or (not pub__imageFormatSupported(sformat)) then
      begin

      //transparent image -> png, else jpg
      if    mask__hasTransparency32( ss ) then dformat        :='png'
      else                                     dformat        :='jpg';

      end;


   //write new format ----------------------------------------------------------

   if dmustsave or (not strmatch(sformat,dformat)) then
      begin

      if (dd<>nil) then mis__todata2( dd ,@d ,dformat ,xcore.dimageQuality ,e )
      else              mis__todata2( ss ,@d ,dformat ,xcore.dimageQuality ,e );

      end

   else begin

      //image size is OK and format is OK -> copy "s" directly to "d" without alteration
      str__add( @d, @s );

      end;


   end;

//successful
result                          :=true;

except;end;

//free
if (ss<>nil) then freeobj(@ss);
if (dd<>nil) then freeobj(@dd);

end;

function pub__digPad(const x:longint32):string;
begin

result      :=low__digpad11(x,4);

end;

function pub__single(const x:double):string;
begin

result      :=floattostrex( x ,2 );

end;

function pub__singleADE(const x:double):string;
begin//Note: forces ADE to round up for too small font-sizes in EPUB 3 render engine - 11nov2026

result      :=floattostrex( x + 0.02001 ,2 );//force "floattostrex" to round up using "0.0001"

end;

function pub__setFirstError(var xcore:tpubinfo;const xnewErrorMsg:string):boolean;
begin

result                :=true;

if (xcore.firstError='') then
   begin

   xcore.firstError   :=xnewErrorMsg;

   end;

end;

function pub__seterrorFileNotFound(var xcore:tpubinfo;const xfilename:string):boolean;
begin

result                :=pub__seterrorFileNotFound2( xcore ,xfilename ,'' );

end;

function pub__seterrorFileNotFound2(var xcore:tpubinfo;const xfilename,xmoreInfo:string):boolean;
begin

result                :=pub__setFirstError( xcore ,'File not found: ' + xfilename +insstr('. '+xmoreInfo,xmoreInfo<>'') );

end;

function pub__seterrorFolderNotFound(var xcore:tpubinfo;const xfolder:string):boolean;
begin

result                :=pub__setFirstError( xcore ,'Folder not found: ' + xfolder );

end;

function pub__helpText:string;
var
   ia_first           :boolean;

   procedure a(const v:string);
   begin

   result             :=result + v + #10;

   end;

   procedure na;
   begin

   a('');

   end;

   procedure ia(const n,v:string;const xmin,xmax,xdef:longint32);
   begin

   if ia_first then ia_first:=false
   else             na;

   na;

   a(n+': '+intstr32(xmin)+'-'+intstr32(xmax));

   a(v + insstr(', ',v<>'') + 'default=' + intstr32(xdef) +'.') ;

   end;

   procedure mh(const v:string);
   var
      dv              :string;

   begin

   if (result<>'') then
      begin

      na;
      na;

      end;

   dv                 :='[ '+strup(v)+' ]';
   a( dv );
   a( makestrb( low__len32(dv) ,ssDash ) );

   ia_first           :=true;

   end;

   procedure h(const v:string);
   var
      dv              :string;

   begin

   if (result<>'') then na;

   dv                 :='< '+v+' >';
   a( dv );
   a( makestrb( low__len32(dv) ,ssDash ) );

   ia_first           :=true;

   end;

   function ximgExts:string;
   var
      p     :longint32;
      v     :string;
      bol1  :boolean;

   begin

   //defaults
   result   :='';

   for p:=0 to max32 do
   begin

   if io__imageExt( p ,v ,bol1 ) then result:=result+insstr(', ',result<>'')+v
   else                          break;

   end;//p

   end;

   function dcode(const v:string):string;
   begin

   result                       :='"' + pub_codesstart + #32 + v + #32 + pub_codesstop + '", excluding double quotes';

   end;

   function dimgRatio(const v:double):string;
   begin

   if (v>=1) then result        :=intstr32(round32(pub_minCoverWidth*v))+'h x '+intstr32( pub_minCoverWidth )+'w ( '+floattostrex(v,1)+':1 )'
   else           result        :='';

   end;

begin

//defaults
result                :='';
ia_first              :=false;

//get

mh('Book and Author Information');

h('Book.Title');
a('Name of e-book');

h('ISBN');
a('13-digit ISBN number (optional).  Sets e-book internal indentifier as ISBN, else auto. generated unique id (UUID).');
na;
a('Important:');
a('You must own the ISBN in order to use it for your e-book.');

h('Author');
a('Author.First.Name: Your first name');
na;;
a('Author.Last.Name: Your last name');
na;
a('Author.Url: Your website url (optional)');

h('Publisher');
a('Publisher: Name of publisher (optional)');
na;
a('Publisher.Url: Publisher''s website url (optional)');

h('Misc');
a('Rights: Copyright line (optional)');
na;
a('Description: Short description of e-book (optional)');
na;
a('Subject.1: Genre tag (optional)');
a('Subject.2: Genre tag (optional)');
a('Subject.3: Genre tag (optional)');
a('Subject.4: Genre tag (optional)');
a('Subject.5: Genre tag (optional)');

h('BISAC Subjects');
a('North American subject headings.  Click the "BISAC" button (toolbar above) to visit website for labels and codes (optional).  Codes are 9-digits long.');
na;
a('Example:');
a('BISAC.label1: FICTION / Romance / Contemporary');
a('BISAC.code1: FIC027020');
a('BISAC.label2: FICTION / Romance / Erotic');
a('BISAC.code2: FIC027010');

h('THEMA Subjects');
a('Click the "THEMA" button (toolbar above) to visit website for labels and codes.');
na;
a('Example:');
a('THEMA.label1: Modern and contemporary romance');
a('THEMA.code1: FRD');
a('THEMA.label2: Erotic romance');
a('THEMA.code2: FRX');
a('THEMA.label3: Content has detailed sexual activity described ‘on the page’');
a('THEMA.code3: 5YX');


h('Release Date');
a('Release date of e-book, stored internally within e-book.');
na;
a('Auto.Update   : 0-1');
a('0 = manual');
a('1 = auto. set values during build');
na;
a('Release.Year  : 4 digit year');
a('Release.Month : 1-12');
a('Release.Day   : 1-31');
a('Release.Hour  : 0-23');
a('Release.Minute: 0-59');
a('Release.Second: 0-59');


mh('Build Options');

ia('EPUB.Version','EPUB ver. to build',pub_epubVersion_min,pub_epubVersion_max,pub_epubVersion_def);
a('3 = EPUB v3');
a('2 = EPUB v2');

ia('Header.Align','Align chapter heading',pub_headerAlign_min,pub_headerAlign_max,pub_headerAlign_def);
a('0 = Left');
a('1 = Center');
a('2 = Right');

ia('Header.Size%','Size of header text in %',pub_headerSize_min,pub_headerSize_max,pub_headerSize_def);
ia('Header.Above%','Space above chapter heading as a % of heading height',pub_headerAbove_min,pub_headerAbove_max,pub_headerAbove_def);
ia('Header.Below%','Space below chapter heading as a % of heading height',pub_headerBelow_min,pub_headerBelow_max,pub_headerBelow_def);

ia('Text.Size%','Size of text in %',pub_textSize_min,pub_textSize_max,pub_textSize_def);

ia('Text.Justify','Justify text to width of page, applies to left-aligned text only',pub_textJustify_min,pub_textJustify_max,pub_textJustify_def);
a('0 = Off');
a('1 = Justify text');

ia('Line.Height%','Line height (spacing) for header and text in %',pub_lineHeight_min,pub_lineHeight_max,pub_lineHeight_def);
a('100 = 1.0 (no spacing)');
a('120 = 1.2 line spacing');
a('150 = 1.5 line spacing');
a('200 = 2.0 line spacing');

ia('Drop.Caps','Enhance 1st line of chapter text',pub_dropCaps_min,pub_dropCaps_max,pub_dropCaps_def);
a('0 = Off');
a('1 = Large letter on line');
a('2 = Large letter dropped from line');
a('3 = First word in small caps');
a('4 = First 2 words in small caps');
a('5 = First 3 words in small caps');
a('6 = First 4 words in small caps');
a('7 = First 5 words in small caps');

ia('Indent.Chars','Indent first line of paragraph by # spaces',pub_indentChars_min,pub_indentChars_max,pub_indentChars_def);
a('0       = Off');
a('1..20   = Indent all but first');
a('-1..-20 = Indent all');

ia('Blank.Line%','Vertical padding (spacing) between paragraphs in %',pub_blankLine_min,pub_blankLine_max,pub_blankLine_def);

ia('Format.Up','Convert plain text values into symbolic versions',pub_formatUp_min,pub_formatUp_max,pub_formatUp_def);
a('0 = Off');
a('1 = On');
na;
a('When "On", converts text values (left) to symbolic versions:');
a('(c)   = copyright');
a('(r)   = registered');
a('(tm)  = trademark');
a('1/4   = quarter');
a('1/2   = half');
a('3/4   = three quarters');
a('^1    = power of 1');
a('^2    = power of 2');
a('^3    = power of 3');
a('+/-   = plus or minus');
a('...   = ellipsis');
a('. . . = ellipsis');
a('--    = em dash');

ia('Scene.Sep','Convert plain text scene separators into enhanced versions',pub_sceneSep_min,pub_sceneSep_max,pub_sceneSep_def);
a('0  = Off');
a('1  = custom');
a('2  = 1 asterisk');
a('3  = 3 asterisks');
a('4  = 1 black diamond');
a('5  = 3 black diamonds');
a('6  = 1 red diamond');
a('7  = 3 red diamonds');
a('8  = 1 red love heart');
a('9  = 3 red love hearts');
a('10 = horiz. line 10%');
a('11 = horiz. line 20%');
a('12 = horiz. line 30%');
a('13 = horiz. line 40%');
a('14 = horiz. line 50%');
a('15 = 1 dinkus');
a('16 = 3 dinkus');
a('17 = 3 heart contrast');
a('18 = 3 diamond contrast');
a('19 = 1 floral fleuron');
a('20 = 3 floral fleuron');
a('21 = 3 vine & leaf');

na;
a('These plain text separators are scanned for, excluding double quotes:');
a('a) single hash "#"');
a('b) 3 asterisks "* * *"');

na;
a('Each scene separator must exist on a dedicated line of its own with no text.  Slight variations with or without white space are accepted.');

na;
a('A custom separator (19) can use html unicode characters, such as "&#x2661; &#x2764; &#x2661;" without double quotes, but html code will be ignored and formatted as text.');
na;
a('Some newer unicode characters may not render correctly on older e-readers.');


ia('Quotes.Single','Format single quotes',pub_quotesSingle_min,pub_quotesSingle_max,pub_quotesSingle_def);
a('0 = Off');
a('1 = Convert curly to straight');
a('2 = Auto-convert to curly 6 and 9');
na;
a('Note: Option 2 may fail on abreviations such as ''cause. Use with caution.');

ia('Quotes.Double','Format double quotes',pub_quotesDouble_min,pub_quotesDouble_max,pub_quotesDouble_def);
a('0 = Off');
a('1 = Convert curly to straight');
a('2 = Auto-convert to curly 66 and 99');

ia('Image.Quality','Convert images to png/jpeg format for maximum compatiblity with e-book readers',pub_imageQuality_min,pub_imageQuality_max,pub_imageQuality_def);
a('5 = Convert if not jpeg, png, gif');
a('4 = Convert transparent to png, solid to jpeg high quality');
a('3 = Convert to jpeg high quality');
a('2 = Convert to jpeg good quality');
a('1 = Convert to jpeg fair quality');
a('0 = Convert to jpeg low quality');
na;
a('Optimisation Note:');
a('Duplicate images are automatically filtered out by binary datastream comparison.');

ia('Cover.Quality','Set quality for e-book cover',pub_coverQuality_min,pub_coverQuality_max,pub_coverQuality_def);
a('4 = Best quality');
a('3 = High quality');
a('2 = Good quality');
a('1 = Fair quality');
a('0 = Low quality');
na;
a('Size Note:');
a('A lower quality cover reduces the overall size of the e-book.');

ia('Auto.Split','Split document files into separate chapters / sections based on the # of consecutive blank lines',pub_autoSplit_min,pub_autoSplit_max,pub_autoSplit_def);
a('0 = Off');
a('1 = 2 blank lines');
a('2 = 3 blank lines');
a('3 = 4 blank lines');
a('4 = 5 blank lines');
a('5 = 6 blank lines');
a('6 = 7 blank lines');


mh('Document Files');
na;
a('List of document files in bwd, bwp, udoc, rtf, or txt format to be included as chapters / sections in e-book. One file name per line.');
na;
a('May also be an image file of '+ximgExts+'.');
na;
a('When an image file is specified then its file name will be used for the heading and also as the link name in the Table of Contents.');
na;
a('Files are processed and listed in the e-book from first to last (top to bottom) order.');
na;
a('Each file can be a simple name - e.g. mydocument.txt - which assumes it resides in the current folder, or a full path + name, if the file resides '+
  'elsewhere on your computer - e.g. f:\docs\doc3.rtf');


mh('Cover Image');
a('The cover image for the e-book is sourced from the first file name in the list (top most).');
na;
a('It can be a document file containing an image.  When this is the case, the first image found to be at least 300h x 300w and at the beginning of the document is extracted for use and the rest of text / images in the document '+'or current section when being split, are discarded.');
na;
a('Alternatively, it can be an image file.');
na;
a('The cover image is then resampled to:');
a('a) '+dimgRatio(1.5)+' or ');
a('b) '+dimgRatio(1.6)+' and converted to a jpeg.');


mh('Hyperlinks');
a('Urls beginning with:');
a('"https://"');
a('"http://"');
a('"ftps://"');
a('"ftp://"');
a('excluding double quotes are automatically converted into clickable links and embedded into the page with leading protocols (e.g. https://) visually removed.');
na;
a('Email addresses in the format "mailto:your@emailaddress.com" excluding the double quotes are also converted into clickable links and embedded into the page.');
na;
a('Examples:');
a('https://www.blaizenterprises.com');
a('-> www.blaizenterprises.com');
na;
a('http://www.blaizenterprises.com');
a('-> www.blaizenterprises.com');
na;
a('mailto:contact@blaizenterprises.com');
a('-> contact@blaizenterprises.com');


mh('Start Reading Location (SRL)');
a('The Start Reading Location (SRL) corresponds to the "Go to Beginning" navigation option on a Kindle.');
na;
a('It represents the beginning of the text for the book, e.g. Chapter 1, and is automatically set when a document''s heading is "Chapter 1/Chapter One/One/1", regardless of case.');
na;
a('If your e-book does not use such headings, or navigation is required elsewhere, you may specify the SRL entry point by using a control code - see the section "Control Codes" below.');


mh('Control Codes');
a('Control codes are used to switch the chapter / section formatting style, split document text into multiple separate chapters / sections, '+
  'and set the Start Reading Location (SRL).');
na;
a('Control codes are extracted as a set and processed before any page formatting begins.  '+
  'Each time a control code set is extracted the previous values return to defaults for consistent and predictiable behaviour.');
na;
a('A control code set is begun with "'+pub_codesstart+'" and terminated with "'+pub_codesstop+'", excluding double quotes.  One or more control codes are placed inside and separated by a space or a comma.');
na;
a('Control codes are processed in left-to-right order and persist for the chapter / section being processed.');

h('Available Control Codes');
a( strpad(pub_codesFormat,5)    +'= chapter formatting *');
a( strpad(pub_codesNoFormat,5)  +'= plain formatting');
a( strpad(pub_codesHeading,5)   +'= include heading *');
a( strpad(pub_codesNoHeading,5) +'= exclude heading');
a( strpad(pub_codesChapter1,5)  +'= Start Reading Location (SRL)');
a( strpad(pub_codesSplit,5)     +'= split into chapter / section');

na;
a('Codes marked by an "*" are on by default.');
na;
h('Set The SRL');
a('In the text of your chapter / section include the code '+dcode(pub_codesChapter1)+'.');
na;
a('Once the SRL is set, any other attempts to set it are ignored.');
na;

h('Force Plain Formatting');
a('For pages other than chapters, for instance the copyright page and backmatter pages, simple formatting is required.');
na;
a('Use code set '+dcode(pub_codesNoFormat +pub_codesSep2 +pub_codesNoHeading)+', for plain formatting and no heading.');
na;
a('Use code set '+dcode(pub_codesNoFormat )+', for plain formatting with a heading.');
na;
a('Use code set '+dcode(pub_codesNoHeading )+', for chapter formatting with no heading.');
na;

h('Many Chapters From A Document');
a('If your e-book is one large continuous document (manuscript), for best results it should be split into separate chapters and sections.');
na;
a('Use '+dcode(pub_codesSplit)+', to start a new chapter.');
na;
a('Use '+dcode(pub_codesSplit+pub_codesSep2+pub_codesChapter1)+', to start a new chapter and set as the SRL.');
na;
a('Use '+dcode(pub_codesSplit+pub_codessep2+pub_codesNoFormat+pub_codessep2+pub_codesNoHeading)+', to start a new section with plain formatting and no heading.');
na;
a('Use '+dcode(pub_codesSplit+pub_codessep2+pub_codesNoFormat)+', to start a new section with plain formatting and a heading.');
na;
a('An automatic document spliting feature is also supported, which is based on the # of consecutive blank lines.  Default is '+k64(succ(pub_autoSplit_def))+' blank lines.  See above section titled "Auto.Split".');
na;
a('Note: Each code set should be positioned at the beginning of your chapter / section, e.g. right before the heading/1st line of text.');


mh('Text Processing');
a( 'The font names, font sizes, and font colors specified in the document files are discarded in order to generate a dynamic e-book.');
na;
a('This permits the reader to change the e-book''s font name, font color, font size, and background color.');
na;
a('Headings are generated from the first line of text encountered in a document/section, and do not require any special markings, formatting, or styles.');
na;
a('The 1st line of text is always regarded as the chapter / section heading, even when one is not shown on the page, it will however appear in the Table of Contents as a link.');

mh('Table Of Contents');
a('During the build process a Table of Contents is automatically generated and all chapters and sections linked to it.');


end;

function pub__copy(const s:tbasicbwp;sbuildFolder:string):boolean;
label
   skipend;

var
   b                  :tstr8;
   dline              :tstr8;
   d                  :tstr8;
   dpos               :longint32;
   f                  :string;

begin

//defaults
result                :=false;
b                     :=nil;
d                     :=nil;
dline                 :=nil;
sbuildFolder          :=io__asfolderNIL( sbuildFolder );

//check
if (s=nil) or (sbuildFolder='') then exit;

try

//init
b                     :=faststr__new8;
d                     :=faststr__new8;
dline                 :=faststr__new8;
dpos                  :=0;

//get
if not s.iogettxt(b) then goto skipend;

//enforce full filenames for Chapter Files during copy process

while str__nextline0( @b ,@dline ,dpos ) do
begin

if pub__isDocumentFile( sbuildFolder ,dline.text ) then
   begin

   //filename
   f                  :=pub__extractDocumentFile( sbuildFolder ,dline.text );

   //"c:\folder\abc.txt" - 15oct2026
   if (strcopy1(f,2,1)=':') then
      begin

      //convert "portable" filename to "global"
      if (strcopy1(f,1,1)='?') then
         begin

         f            :=io__readportablefilename( f );

         end;

      end

   //make "global" filename
   else if not low__havechar(f,':') then
      begin

      f               :=sbuildFolder + io__extractfilename(f);

      end;

   d.sadd( f + #10 );

   end

else begin

   d.sadd( dline.text + #10 );

   end;

end;//loop


//set
d.text                :=u8__from8strb(u8__to8strb(d.text));//utf-8 + part.8 -> utf-8
result                :=clip__copytext2( @d );

skipend:
except;end;

//free
if (b    <>nil) then faststr__free(@b    );
if (d    <>nil) then faststr__free(@d    );
if (dline<>nil) then faststr__free(@dline);

end;

function pub__paste(const s:tbasicbwp;sbuildFolder:string):boolean;
label
   skipend;

var
   stext              :tstr8;
   ctext              :tstr8;
   cline              :tstr8;
   ctextIsTPUB        :boolean;
   cpos               :longint32;
   f                  :string;

   procedure sreplace(const x:string);
   begin
   
   s.core.clear2;
   s.core.xinstext( x );

   end;

begin

//defaults
result                :=false;
stext                 :=nil;
ctext                 :=nil;
cline                 :=nil;
ctextIsTPUB           :=false;
sbuildFolder          :=io__asfolderNIL( sbuildFolder );

//check
if (s=nil) or (sbuildFolder='') then exit;

try

//init
stext                 :=faststr__new8;
ctext                 :=faststr__new8;
cline                 :=faststr__new8;
cpos                  :=0;

//get
clip__pastetext2( @ctext );

ctext.text            :=u8__to8strb( ctext.text );

while str__nextline0( @ctext ,@cline ,cpos ) do
begin

if strmatch(cline.text,pub_buildSummary) then
   begin

   ctextIsTPUB        :=true;

   break;

   end;

end;//loop

//set

//.clipboard text is a TPUB
if ctextIsTPUB then
   begin

   sreplace(ctext.text);

   end

//.clipboard text assumed to be a list of file names
else begin

   s.iogettxt( stext );

   stext.text         :=stext.text + pub_returnCode + ctext.text;

   sreplace( stext.text );

   end;

//successful
result                :=true;

skipend:
except;end;

//free
if (stext<>nil) then faststr__free(@stext);
if (ctext<>nil) then faststr__free(@ctext);
if (cline<>nil) then faststr__free(@cline);

end;

function pub__fileFormatSupported(const xfilename:string):boolean;
var
   int1     :longint32;

begin

result:=pub__fileFormatSupported2(xfilename,int1);

end;

function pub__fileFormatSupported2(const xfilename:string;var xdocStyle:longint32):boolean;
var
   vname    :string;
   v        :string;

begin

//get
v           :=strlow(io__extractfileext(xfilename));

if (v=fetxt) or (v=febwd) or (v=febwp) or (v=fertf) or (v=feudoc) then//08nov2026
   begin

   vname    :=strlow(io__extractfilename(xfilename));

   if (vname<>'.__recent.txt')   then xdocStyle:=pub_fText;

   end
else if io__imageExtSupported(v) then xdocStyle:=pub_fImage
else                                  xdocStyle:=pub_fNone;

//set
result      :=(xdocStyle<>pub_fNone);

end;

procedure pub__setChapterOneOnce(var xcore:tpubinfo;const dindex:longint32);
begin

if (dindex>=0) and (xcore.firstChapterIndex<0) then
   begin

   xcore.firstChapterIndex      :=dindex;

   end;

end;

function pub__enforceImageLimits(const xcore:tpubinfo;const ximagedata:tstr8;var xoutW,xoutH:longint32):boolean;
var
   a                  :tbasicimage;
   d                  :tbasicimage;
   e                  :string;
   dw                 :longint32;
   dh                 :longint32;
   dformat            :string;
   
begin

//defaults
result                :=true;//pass-thru
a                     :=nil;
d                     :=nil;
xoutW                 :=1;
xoutH                 :=1;

//check
if (ximagedata=nil) or (ximagedata.len32<=0) then exit;

try

//init
a                     :=misimg32(1,1);

//get
mis__fromdata( a ,@ximagedata ,e );

dformat               :=io__anyformatb(@ximagedata);
xoutW                 :=a.ai.cellWidth;
xoutH                 :=a.ai.cellHeight;

//check max width/height
if (a.width>pub_maxWidth) or (a.height>pub_maxHeight) then
   begin

   //one cell is ok?
   mis__onecell( a );

   if (a.width<=pub_maxWidth) and (a.height<=pub_maxHeight) then
      begin

      xoutW           :=a.width;
      xoutH           :=a.height;

      ximagedata.clear;

      mis__todata2( a ,@ximagedata ,dformat ,xcore.dimageQuality ,e );

      end

   //no, shrink one cell down to an acceptable size
   else begin

      //scale down to fit
      low__scaledown( pub_maxWidth ,pub_maxHeight ,a.width ,a.height ,dw ,dh );

      //range
      dw              :=frcmin32(dw,1);
      dh              :=frcmin32(dh,1);
      xoutW           :=dw;
      xoutH           :=dh;

      //get
      d               :=misimg32( dw ,dh );

      mis__copyfast( maxarea ,misarea(a) ,0 ,0 ,dw ,dh ,a ,d );

      //set
      ximagedata.clear;

      mis__todata2( d ,@ximagedata ,dformat ,xcore.dimageQuality ,e );

      end;

   end;

except;end;

//free
if (a<>nil) then freeobj(@a);
if (d<>nil) then freeobj(@d);

end;

function pub__enforceURLprotocol(const x:string):string;//30oct2026
label
   redo;
   
   function m(const n,v:string):boolean;
   begin

   result             :=strmatch( n ,strcopy1(v,1,low__len32(n)) );

   end;

begin

//defaults
result                :=x;

//check
if (result='') then exit;

//loop
redo:

result                :=stripwhitespace_lt( result );

if m( '/'      ,result ) then
   begin

   strdel1(result,1,1);
   goto redo;

   end;

if m( '\'      ,result ) then
   begin

   strdel1(result,1,1);
   goto redo;

   end;

//get
if m( 'https://' ,result ) then exit;
if m( 'http://'  ,result ) then exit;
if m( 'ftps://'  ,result ) then exit;
if m( 'ftp://'   ,result ) then exit;

//set
result                :='https://' + result;

end;

function pub__stripProtocols(const x:string):string;
label
   redo;

var
   bol1               :boolean;

   function m(const n:string;var v:string):boolean;
   begin

   result             :=strmatch( n ,strcopy1(v,1,low__len32(n)) );

   //strip
   if result then strdel1(v,1,low__len32(n));

   end;

begin

//init
result                :=x;
bol1                  :=false;

//get
redo:

result                :=stripwhitespace_lt( result );

if m( 'http://'  ,result ) then goto redo;
if m( 'https://' ,result ) then goto redo;
if m( 'ftps://'  ,result ) then goto redo;
if m( 'ftp://'   ,result ) then goto redo;
if m( 'mailto:'  ,result ) then goto redo;

end;

function pub__publisher(const x:string):string;
begin

result                :=pub__stripProtocols( x );

end;

procedure pub__formatUp(const x:tunidoc);
var
   xlen               :longint32;
   p                  :longint32;
   v                  :longint32;
   s                  :string;

   function c8(const xpos0:longint32):char;//read char
   begin

   if (xpos0>=0) and (xpos0<xlen) then result       :=char( x.g_8b(xpos0) )
   else                                result       :=#10;

   end;

   function cstr8(const xpos0,xlen:longint32):string;
   var
      p                         :longint32;
      r                         :longint32;

   begin

   if (xlen>=1) then
      begin

      low__setlen( result ,xlen );
      r                         :=0;

      for p:=xpos0 to pred( xpos0 + xlen ) do
      begin

      result[r+stroffset]       :=c8(p);

      inc(r);

      end;//p

      end

   else result:='';

   end;

   procedure sc8(const xpos0:longint32;const v:byte);//set char
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.s_8( xpos0 ,v );

   end;

   procedure nc8(const xpos0:longint32);//mark not used
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.s_8( xpos0 ,pub_unusedChar );

   end;

   function nn8(const xpos0:longint32):boolean;//not a number
   begin

   case byte(c8(xpos0)) of

   48..57   :result:=false;
   else      result:=true;

   end;//case

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.count;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.g_8b( p ) of


//em dash ----------------------------------------------------------------------

ssdash:begin

   if (cstr8(p,2)='--') and (c8(p-1)<>'-') and (c8(p+2)<>'-') then//"--" -> 151
      begin

      sc8( p ,151 );
      nc8( p+1    );

      end

   end;


//eclipse ----------------------------------------------------------------------

ssdot:begin

   if (cstr8(p,3)='...') and (c8(p-1)<>'.') and (c8(p+3)<>'.') then//"..." -> 133
      begin

      sc8( p ,133 );
      nc8( p+1    );
      nc8( p+2    );

      end

   else if (cstr8(p,5)='. . .') and (c8(p-1)<>'.') and (c8(p+5)<>'.') then//". . ." -> 133
      begin

      sc8( p ,133 );
      nc8( p+1    );
      nc8( p+2    );
      nc8( p+3    );
      nc8( p+4    );

      end;

   end;


//numbers ----------------------------------------------------------------------

nn1:begin

   if nn8(p-1) and nn8(p+3) then
      begin

      if (cstr8(p,3)='1/4') then
         begin

         sc8( p ,188 );
         nc8( p+1    );
         nc8( p+2    );

         end

      else if (cstr8(p,3)='1/2') then
         begin

         sc8( p ,189 );
         nc8( p+1    );
         nc8( p+2    );

         end;

      end;

   end;

nn3:begin

   if nn8(p-1) and nn8(p+3) then
      begin

      if (cstr8(p,3)='3/4') then
         begin

         sc8( p ,190 );
         nc8( p+1    );
         nc8( p+2    );

         end;

      end;

   end;

94:begin//"^"

   if nn8(p+2) then
      begin

      if (cstr8(p,2)='^2') then
         begin

         sc8( p ,178 );//power of 2
         nc8( p+1    );

         end

      else if (cstr8(p,2)='^3') then
         begin

         sc8( p ,179 );//power of 3
         nc8( p+1    );

         end

      else if (cstr8(p,2)='^1') then
         begin

         sc8( p ,185 );//power of 1
         nc8( p+1    );

         end;

      end;

   end;


//strings ----------------------------------------------------------------------

40:begin//"(c)" and "(r)" and "(tm)"

   if (strmatch(cstr8(p,3),'(c)')) then
      begin

      sc8( p ,169 );
      nc8( p+1    );
      nc8( p+2    );

      end

   else if (strmatch(cstr8(p,3),'(r)')) then
      begin

      sc8( p ,174 );
      nc8( p+1    );
      nc8( p+2    );

      end

   else if (strmatch(cstr8(p,4),'(tm)')) then
      begin

      sc8( p ,153 );
      nc8( p+1    );
      nc8( p+2    );
      nc8( p+3    );

      end;

   end;

43:begin//"+/-"

   if (cstr8(p,3)='+/-') then
      begin

      sc8( p ,177 );
      nc8( p+1    );
      nc8( p+2    );

      end

   end;

end;//case

end;//p

end;

procedure pub__formatSceneSep(const x:tunidoc);//24oct2026
var
   xlen               :longint32;
   p                  :longint32;
   v                  :longint32;
   s                  :string;

   function c8(const xpos0:longint32):char;//read char
   begin

   if (xpos0>=0) and (xpos0<xlen) then result       :=char( x.g_8b( xpos0 ) )
   else                                result       :=#10;

   end;

   function cstr8(const xpos0,xlen:longint32):string;
   var
      p                         :longint32;
      r                         :longint32;

   begin

   if (xlen>=1) then
      begin

      low__setlen( result ,xlen );
      r                         :=0;

      for p:=xpos0 to pred( xpos0 + xlen ) do
      begin

      result[r+stroffset]       :=c8(p);

      inc(r);

      end;//p

      end

   else result:='';

   end;

   procedure sc8(const xpos0:longint32;const v:byte);//set char
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.s_8( xpos0 ,v );

   end;

   procedure nc8(const xpos0:longint32);//mark not used
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.s_8( xpos0 ,pub_unusedChar );

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.count;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.g_8b( p ) of

sshash:begin

   if (cstr8(p-1,3)=(#10+'#'+#10)) then
      begin

      sc8( p ,pub_sceneSep0 );

      end

   else if (cstr8(p-2,4)=(#10+' #'+#10)) then
      begin

      nc8( p-1 );
      sc8( p ,pub_sceneSep0 )

      end

   else if (cstr8(p-1,4)=(#10+'# '+#10)) then
      begin

      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );

      end

   else if (cstr8(p-2,5)=(#10+' # '+#10)) then
      begin

      nc8( p-1 );
      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );

      end;

   end;

ssasterisk:begin

   if (cstr8(p-1,7)=(#10+'* * *'+#10)) then
      begin

      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );
      nc8( p+3 );
      nc8( p+4 );

      end

   else if (cstr8(p-1,8)=(#10+' * * *'+#10)) then
      begin

      nc8( p-1 );
      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );
      nc8( p+3 );
      nc8( p+4 );

      end

   else if (cstr8(p-1,8)=(#10+'* * * '+#10)) then
      begin

      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );
      nc8( p+3 );
      nc8( p+4 );
      nc8( p+5 );

      end

   else if (cstr8(p-1,9)=(#10+' * * * '+#10)) then
      begin

      nc8( p-1 );
      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );
      nc8( p+3 );
      nc8( p+4 );
      nc8( p+5 );

      end

   else if (cstr8(p-1,5)=(#10+'***'+#10)) then
      begin

      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );

      end

   else if (cstr8(p-1,6)=(#10+'*** '+#10)) then
      begin

      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );
      nc8( p+3 );

      end

   else if (cstr8(p-2,6)=(#10+' ***'+#10)) then
      begin

      nc8( p-1 );
      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );

      end

   else if (cstr8(p-2,7)=(#10+' *** '+#10)) then
      begin

      nc8( p-1 );
      sc8( p ,pub_sceneSep0 );
      nc8( p+1 );
      nc8( p+2 );
      nc8( p+3 );

      end;

   end;


//mark these chars as "unused" -> these char codes are reserved for formatting above
pub_sceneSep0 :nc8(p);

end;//case

end;//p

end;

procedure pub__quotesSinglePlain(const x:tunidoc);
var
   xlen               :longint32;
   p                  :longint32;

begin

//check
if (x=nil) then exit
else            xlen  :=x.count;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.g_ub( p ) of

u_leftSingleQuote ,u_rightSingleQuote     :x.s_8( p ,39 );//plain single

end;//case

end;//p

end;

procedure pub__quotesDoublePlain(const x:tunidoc);
var
   xlen               :longint32;
   p                  :longint32;

begin

//check
if (x=nil) then exit
else            xlen  :=x.count;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.g_ub( p ) of

u_leftDoubleQuote ,u_rightDoubleQuote     :x.s_8( p ,34 );//plain double

end;//case

end;//p

end;

procedure pub__quotesDoubleCurly(const x:tunidoc);
var
   xlen               :longint32;
   p                  :longint32;
   xwithin            :boolean;

   procedure xstart;
   begin

   xwithin         :=true;

   x.s_u( p ,u_leftDoubleQuote );

   end;

   procedure xstop;
   begin

   xwithin         :=false;
   x.s_u( p ,u_rightDoubleQuote );

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.count;

//check
if (xlen<=0) then exit;

//init
pub__quotesDoublePlain( x );

xwithin               :=false;

//get
for p:=0 to pred(xlen) do
begin

case x.g_ub( p ) of

10:xwithin            :=false;//cancel -> keeps processing to a paragraph, preventing any errors from carrying onwards
34:begin

   if xwithin then xstop
   else            xstart;

   end;

end;//case

end;//p

end;

procedure pub__quotesSingleCurly(const x:tunidoc);
label
   skipone;

var
   xlen               :longint32;
   p                  :longint32;
   i                  :longint32;

   function c8(const xpos0:longint32):byte;//read char
   begin

   if (xpos0>=0) and (xpos0<xlen) then result       :=x.g_8b( xpos0 )
   else                                result       :=10;

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.count;

//check
if (xlen<=0) then exit;

//init
pub__quotesSinglePlain( x );

//get
for p:=0 to pred(xlen) do
begin

case x.g_ub( p ) of

39:begin

   //is it a quotation?

   if not windows1252__charIsLetter( c8(pred(p)) ) then
      begin

      for i:=succ(p) to xlen do
      begin

      if ( c8(i) = 39 ) then
         begin

         if not windows1252__charIsLetter( c8(succ(i)) ) then
            begin


            x.s_u( p ,u_leftSingleQuote  );//left  "6"
            x.s_u( i ,u_rightSingleQuote );//right "9"

            goto skipone;

            end;

         end;

      end;//i

      end;

   //assume right
   x.s_u( p ,u_rightSingleQuote );//right "9"

   end;

end;//case

skipone:

end;//p

end;

procedure pub__bisac;
begin

runlow( 'https://www.bisg.org/fiction' ,'' );

end;

procedure pub__thema;
begin

runlow( 'https://ns.editeur.org/thema/en/FR' ,'' );

end;

const

file__1_svg
:array[0..1793] of byte=(
120,1,76,151,75,111,27,71,16,132,239,251,43,6,155,75,12,120,165,157,247,76,32,26,72,114,54,16,36,167,28,153,213,90,34,66,137,2,185,144,28,255,250,124,213,180,97,7,17,185,220,153,233,71,117,117,245,248,238,242,250,224,94,215,243,229,112,122,222,141,254,102,30,221,231,167,227,243,101,55,62,110,219,203,47,183,183,111,111,111,55,111,241,230,116,126,184,13,243,60,223,178,127,28,220,219,225,126,123,100,127,104,243,13,111,249,239,101,27,221,227,122,120,120,220,118,99,73,63,190,125,61,172,111,191,157,62,239,198,217,205,238,135,19,238,251,54,44,190,156,215,203,122,126,93,127,189,188,172,203,246,231,126,59,156,118,227,231,143,135,251,191,249,115,79,235,186,141,31,134,187,167,117,219,223,239,183,253,135,225,247,243,186,223,214,123,247,207,127,238,229,180,157,247,203,234,252,141,207,239,221,219,249,176,109,235,179,22,254,88,183,245,236,254,90,143,135,231,7,30,136,223,79,97,246,117,184,187,253,110,232,238,193,113,252,249,242,233,116,126,218,141,246,120,196,242,207,223,82,120,255,61,204,119,
238,178,236,143,90,242,150,243,251,233,219,211,187,113,248,116,56,30,119,227,79,182,0,138,151,237,124,250,119,221,141,207,167,231,85,145,191,236,183,71,119,191,27,63,114,52,100,151,122,72,110,153,66,169,110,10,222,77,53,53,55,177,164,143,174,207,218,221,148,131,94,134,224,166,150,35,251,66,25,38,95,82,214,10,31,41,114,216,23,158,106,78,44,55,206,245,200,71,140,221,29,57,168,61,216,38,111,215,61,222,122,10,46,105,131,175,121,30,138,246,135,216,187,171,201,222,53,231,11,166,125,116,124,93,87,121,95,35,102,188,183,72,228,43,53,253,142,5,195,61,17,85,30,166,64,28,202,131,61,149,63,139,186,5,170,61,37,252,78,145,224,138,30,170,204,55,18,243,36,63,181,196,153,216,177,214,236,39,80,84,242,35,106,217,243,45,58,239,49,17,103,5,168,16,162,11,89,110,136,56,202,79,36,146,216,205,241,236,90,7,166,4,54,222,124,166,222,134,50,99,27,224,124,232,209,17,68,136,161,187,128,195,52,7,231,103,239,58,1,133,210,157,143,145,13,4,118,244,190,179,234,130,74,210,155,91,12,252,156,135,40,252,125,110,46,123,
220,132,232,93,110,114,76,204,126,46,172,165,138,231,185,114,44,21,118,129,160,57,14,28,192,191,16,115,172,53,44,89,110,213,53,126,198,158,156,215,25,159,202,236,138,138,120,125,42,2,143,192,101,157,192,236,33,23,72,227,234,172,60,8,57,212,58,36,240,15,188,168,129,77,152,138,108,81,106,148,153,26,112,52,37,2,241,114,149,21,30,25,81,17,165,151,141,83,158,109,128,57,245,185,19,23,222,129,161,131,0,181,242,145,68,3,7,2,149,247,30,204,224,77,0,240,140,207,4,152,4,76,13,124,100,87,32,82,178,141,192,157,251,0,75,1,198,25,67,169,133,171,34,28,7,5,45,200,97,49,177,33,194,143,120,37,21,96,1,96,4,54,175,173,185,144,73,174,195,113,106,196,78,232,164,2,214,203,4,93,3,246,166,160,8,60,209,170,208,73,241,83,57,157,12,51,168,3,111,132,166,192,97,237,68,179,139,237,4,41,159,178,32,140,209,33,182,87,224,229,173,88,226,191,184,167,98,107,120,95,162,172,225,42,127,171,122,105,162,91,204,131,66,135,249,114,234,41,210,181,83,101,196,254,167,68,28,84,162,42,50,209,136,44,84,202,210,16,199,160,144,
58,11,35,77,173,156,212,244,33,43,167,64,140,180,30,191,61,200,76,74,163,107,53,234,4,221,199,103,164,26,116,117,22,70,242,199,138,23,101,120,24,188,213,151,130,211,230,60,146,173,167,31,200,87,217,161,185,252,145,88,134,32,52,65,35,110,88,212,161,37,93,32,77,134,8,156,160,164,33,13,106,144,64,63,225,145,218,154,123,88,166,174,13,25,148,232,100,49,37,160,10,75,86,243,90,221,42,65,197,153,218,170,192,108,193,183,31,40,4,92,252,186,69,82,161,93,2,144,140,232,72,18,36,19,99,139,50,77,6,191,89,212,66,156,133,161,9,69,42,9,54,40,111,225,131,17,218,120,161,28,132,172,110,106,188,141,128,45,133,128,8,18,132,4,134,215,53,117,60,157,78,21,0,130,232,48,20,102,41,11,141,65,23,47,60,80,53,162,9,2,130,126,145,30,4,32,10,144,178,160,15,106,103,248,207,54,34,149,77,53,37,202,229,219,32,154,80,107,41,9,0,26,119,13,111,212,17,160,106,181,92,48,187,160,92,19,145,139,52,106,60,9,170,240,155,96,144,144,144,168,179,22,169,16,89,169,188,38,24,234,86,111,45,171,228,162,24,95,140,18,212,9,238,144,38,
97,26,217,141,86,25,158,197,48,76,96,111,152,74,127,52,79,130,52,81,218,233,232,43,114,129,19,172,208,66,208,151,133,224,202,181,74,162,45,125,13,123,32,57,101,27,4,2,187,193,203,73,163,16,25,117,59,158,69,21,188,131,155,2,96,13,32,9,33,217,55,157,194,25,165,110,123,213,27,4,197,97,53,20,77,161,164,172,210,122,146,86,176,155,236,73,142,182,16,121,140,202,50,44,113,77,54,113,200,172,89,89,67,29,34,20,71,43,85,1,138,33,14,39,56,10,171,237,79,35,65,133,74,212,164,214,232,142,197,49,71,52,171,138,91,2,100,0,120,188,128,103,246,67,166,11,38,52,36,80,118,102,16,212,97,159,244,206,250,50,129,145,77,72,100,142,232,53,22,193,146,188,171,40,29,84,132,0,20,4,63,15,140,98,76,120,196,91,27,149,184,70,152,52,39,169,118,242,155,191,181,127,38,73,43,60,87,0,23,33,150,204,100,100,18,11,161,134,65,37,177,170,138,116,95,31,42,41,119,90,138,88,145,30,134,18,128,193,245,10,144,138,129,249,69,117,201,198,87,188,36,210,101,82,181,33,147,58,5,21,133,172,115,123,82,57,149,253,34,45,17,15,155,166,152,
135,85,54,119,96,159,90,152,136,81,163,98,145,115,35,40,116,13,176,161,181,164,131,41,37,174,58,193,11,141,21,152,9,50,158,182,32,117,142,122,77,121,97,111,213,53,227,215,253,54,178,81,133,32,213,148,147,132,55,13,133,78,88,129,136,49,130,41,233,255,4,39,77,99,177,42,207,102,62,82,211,227,149,189,226,78,25,208,31,188,35,130,124,9,26,225,237,139,52,74,211,88,46,22,107,53,9,165,194,211,136,209,8,179,90,104,88,64,109,13,42,234,23,233,246,166,205,26,115,220,23,88,162,155,76,245,53,243,113,39,141,212,144,3,80,141,90,66,238,80,82,93,127,148,118,195,20,244,115,144,26,46,95,143,81,76,226,1,37,131,93,178,126,180,249,165,36,33,17,241,232,6,88,137,156,22,17,132,146,231,41,95,73,200,253,12,102,241,251,58,149,174,109,35,131,186,23,250,70,99,139,155,25,2,232,86,66,191,225,134,134,4,7,182,86,172,31,39,218,131,192,208,166,52,15,11,95,146,58,118,163,4,244,138,18,135,73,48,36,0,141,74,152,144,120,221,30,244,27,71,25,142,170,81,155,228,67,89,218,180,100,106,197,10,194,176,89,245,162,59,201,73,79,
166,88,162,5,2,199,168,86,241,34,69,36,41,93,165,138,146,68,33,120,107,143,104,4,162,7,121,212,8,17,168,189,153,67,74,68,158,40,74,155,80,146,172,73,141,136,34,44,16,122,14,232,43,211,17,162,186,116,216,35,232,240,94,183,60,29,208,109,37,42,185,66,38,25,96,184,213,161,18,118,101,81,89,25,239,10,134,102,193,22,181,212,220,82,156,95,198,91,238,233,183,15,250,224,95,57,31,134,255,1,0,0,255,255,3,0,38,15,144,87);

file__scroll_png:array[0..2942] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,107,0,0,0,29,8,6,0,0,0,173,196,146,208,0,0,11,70,73,68,65,84,120,1,236,154,117,168,20,125,23,199,207,234,181,187,91,175,141,221,157,40,6,118,34,138,32,22,216,138,98,119,119,7,138,160,34,162,130,173,127,216,221,221,221,221,221,57,239,124,126,239,251,187,207,236,236,236,238,236,189,123,159,135,23,158,129,101,118,102,231,23,167,190,231,123,206,172,199,48,12,249,247,8,93,3,67,135,14,53,190,124,249,34,124,62,124,248,32,159,62,125,82,31,61,19,122,245,120,60,146,36,73,18,73,150,44,153,164,74,149,74,82,166,76,41,19,38,76,240,232,103,66,61,123,254,53,86,112,149,13,31,62,220,120,255,254,189,188,125,251,86,94,188,120,33,119,238,220,81,31,61,18,163,84,168,80,65,50,101,202,164,12,18,39,78,28,245,19,186,197,144,124,110,220,184,161,198,240,92,209,162,69,101,193,130,5,33,27,45,214,140,53,108,216,48,37,32,27,253,246,237,155,218,240,247,239,223,5,1,16,6,111,75,152,48,161,164,72,145,66,146,38,77,170,62,163,71,143,14,89,0,173,176,112,158,71,142,
28,105,96,152,87,175,94,201,189,123,247,228,248,241,227,62,211,23,47,94,92,242,229,203,39,233,210,165,83,6,26,51,102,76,192,189,35,119,223,190,125,141,43,87,174,200,174,93,187,164,97,195,134,82,162,68,9,49,215,10,56,206,186,112,88,141,133,129,158,60,121,162,60,232,224,193,131,82,172,88,49,201,156,57,179,50,12,198,209,30,199,6,128,13,140,136,66,16,224,205,155,55,82,174,92,57,201,150,45,155,82,0,176,17,76,1,86,65,98,250,125,196,136,17,198,203,151,47,229,193,131,7,114,234,212,41,181,47,251,156,149,42,85,146,220,185,115,75,134,12,25,100,210,164,73,174,149,108,159,167,75,151,46,198,202,149,43,165,81,163,70,178,98,197,10,215,243,132,197,88,192,4,97,190,111,223,62,41,80,160,128,228,201,147,71,210,167,79,239,26,159,241,186,129,3,7,26,239,222,189,147,103,207,158,201,245,235,215,229,241,227,199,82,185,114,101,101,60,148,51,110,220,56,215,66,217,149,227,239,122,212,168,81,6,206,114,255,254,125,193,185,62,126,252,232,243,40,176,69,4,101,204,152,209,181,60,62,147,56,220,232,212,169,147,177,
118,237,90,233,222,189,187,140,31,63,222,149,108,49,54,86,143,30,61,140,173,91,183,74,174,92,185,84,36,77,155,54,205,213,194,14,251,247,186,213,175,95,63,131,252,112,245,234,85,57,127,254,188,212,168,81,67,173,129,19,196,20,46,129,35,34,232,204,153,51,202,80,94,11,155,23,5,11,22,20,96,14,84,152,60,121,114,88,228,1,90,191,126,253,42,164,130,31,63,126,72,162,68,137,100,219,182,109,10,77,150,46,93,234,106,141,24,25,171,125,251,246,198,238,221,187,165,94,189,122,178,112,225,66,87,11,218,21,227,230,122,192,128,1,10,94,49,26,222,95,182,108,89,201,145,35,135,76,157,58,213,245,154,176,55,162,245,242,229,203,202,72,246,117,129,93,34,153,121,103,207,158,237,122,94,251,60,68,235,231,207,159,213,62,65,138,215,175,95,11,169,225,218,181,107,246,71,163,174,35,35,35,149,35,66,80,210,166,77,43,51,102,204,112,92,63,218,198,234,218,181,171,138,168,22,45,90,72,184,162,41,106,247,1,190,244,238,221,219,32,233,227,36,101,202,148,81,81,64,146,55,149,228,35,160,206,67,176,55,146,186,211,65,158,4,186,
137,162,177,99,199,250,204,225,52,198,122,15,39,208,70,1,194,143,30,61,42,191,126,253,178,62,18,242,119,114,61,178,45,90,180,200,107,63,209,50,22,57,106,249,242,229,138,209,204,155,55,207,107,194,144,119,22,205,1,144,153,71,143,30,201,233,211,167,213,12,8,151,53,107,86,85,219,192,228,200,67,39,79,158,148,231,207,159,251,172,64,20,85,173,90,85,240,104,127,94,236,51,232,127,55,144,157,249,49,204,221,187,119,229,220,185,115,254,30,85,247,129,84,72,19,172,23,232,211,36,11,131,62,125,250,84,144,1,210,2,98,220,188,121,83,221,211,19,214,174,93,91,161,136,134,253,8,253,67,40,231,135,15,31,170,176,253,167,12,197,94,53,225,48,5,49,48,200,145,35,71,84,244,252,249,243,199,75,96,171,92,133,11,23,150,210,165,75,135,28,69,192,48,249,147,60,183,127,255,126,235,148,62,223,153,63,103,206,156,138,209,38,79,158,60,32,121,32,141,196,141,27,87,54,111,222,28,229,240,131,7,15,54,128,78,114,245,142,29,59,84,126,3,90,65,142,128,198,130,165,13,25,50,196,32,41,82,169,115,253,243,231,79,133,251,9,18,36,144,
214,173,91,27,212,74,124,143,31,63,190,36,78,156,88,38,78,156,104,214,136,81,107,251,8,19,238,27,20,171,192,226,197,139,23,253,78,93,171,86,45,201,155,55,175,202,7,110,234,26,228,132,224,224,249,40,45,208,220,68,103,161,66,133,148,3,164,73,147,38,160,113,236,27,196,1,200,81,214,3,253,233,107,24,227,234,213,171,21,19,229,158,15,12,226,69,132,56,225,121,225,194,5,85,181,195,244,178,100,201,34,241,226,197,83,70,33,92,217,36,158,67,209,139,1,73,162,183,110,221,82,191,227,93,80,93,93,48,198,164,197,162,55,110,63,195,66,47,93,186,164,40,183,253,55,174,161,251,68,92,253,250,245,21,75,117,147,143,96,137,200,1,9,161,246,243,119,96,28,224,13,25,129,84,55,14,96,159,139,92,55,107,214,44,233,214,173,91,64,162,132,193,96,219,29,58,116,248,203,88,24,9,42,187,119,239,94,169,89,179,166,194,127,122,89,116,23,236,197,105,131,6,13,12,126,179,23,116,36,116,205,132,116,245,15,131,43,85,170,84,84,49,201,56,39,50,96,23,198,233,26,250,139,35,225,68,39,78,156,240,121,4,231,128,48,224,72,166,34,60,40,159,
103,113,34,10,90,156,78,195,167,30,76,4,105,150,24,200,64,24,7,24,133,177,145,231,122,246,236,169,156,133,121,242,231,207,31,50,27,110,217,178,165,234,240,152,80,23,21,73,122,79,214,51,81,110,18,14,3,166,170,34,203,44,204,140,245,235,215,75,197,138,21,85,1,104,13,69,235,64,253,157,10,252,208,161,67,2,19,12,166,120,96,148,238,4,10,193,112,68,39,108,135,164,139,87,6,27,207,154,204,161,59,11,68,181,253,0,230,48,16,53,152,221,177,120,22,131,176,54,144,86,165,74,21,165,112,32,136,200,228,227,239,160,184,103,175,160,10,6,210,240,110,238,217,88,178,100,137,146,73,143,237,213,171,151,204,156,57,51,160,226,245,179,125,250,244,81,240,214,174,93,59,87,117,92,243,230,205,13,210,76,196,160,65,131,140,77,155,54,73,227,198,141,93,123,7,225,31,17,17,161,216,144,222,128,191,179,21,2,17,18,38,133,225,40,8,241,26,211,155,13,12,55,125,250,116,47,65,121,22,35,223,190,125,91,118,238,220,41,191,127,255,246,90,162,90,181,106,42,82,216,139,61,90,188,30,52,47,152,27,131,163,236,53,107,214,216,127,246,
186,38,114,128,113,234,173,212,169,83,59,66,28,57,28,25,172,7,185,211,205,1,130,161,111,19,157,92,25,138,57,113,112,216,163,167,89,179,102,6,12,106,195,134,13,94,202,10,182,48,16,99,194,160,152,227,93,27,217,58,167,54,6,20,27,38,7,125,5,106,128,73,18,59,148,152,22,150,62,80,116,245,234,213,85,4,145,143,220,180,104,112,6,211,227,13,96,16,131,115,237,239,0,250,217,3,80,234,20,157,246,113,38,10,25,186,193,75,223,179,115,231,206,1,115,15,227,137,240,45,91,182,72,201,146,37,197,36,14,174,245,221,180,105,83,3,218,239,49,113,216,160,149,19,157,170,157,36,143,151,160,68,4,53,13,224,122,3,86,225,137,110,138,214,179,103,207,90,111,43,168,44,82,164,136,98,90,40,49,88,4,233,193,68,17,4,137,249,2,229,161,242,229,203,43,54,70,173,134,163,144,123,230,204,153,19,5,119,122,62,167,51,138,95,181,106,149,34,84,166,50,3,66,32,185,22,167,196,80,116,219,151,45,91,230,90,79,140,133,17,214,173,91,87,60,102,145,102,152,11,203,148,41,83,92,79,96,221,124,255,254,253,141,3,7,14,168,98,15,34,49,119,238,92,
87,194,66,70,116,19,149,6,48,29,120,14,32,136,28,129,162,137,32,114,6,80,167,11,67,235,218,214,239,58,138,128,205,237,219,183,91,127,242,250,206,124,154,40,232,190,31,133,46,198,165,136,166,104,165,47,8,52,7,139,94,208,5,39,163,86,226,29,21,212,157,8,0,182,128,109,200,22,157,124,156,129,232,131,19,184,205,107,122,211,109,219,182,85,29,27,147,35,120,60,102,157,100,152,204,38,218,198,98,82,32,141,66,25,56,163,230,130,218,18,9,48,73,29,13,116,28,168,210,105,205,64,143,129,16,132,137,140,140,84,94,173,251,98,58,199,97,76,158,3,14,173,253,64,61,159,22,134,34,82,71,17,4,194,233,32,98,52,81,8,212,26,67,14,136,7,176,73,59,139,14,2,12,146,90,200,159,179,104,134,10,1,162,30,3,194,245,129,147,97,120,242,31,228,199,156,63,164,128,128,200,173,91,183,78,32,34,236,219,99,66,152,74,240,102,251,40,164,137,244,134,172,103,132,213,239,132,80,28,237,24,251,65,228,96,24,188,144,4,78,68,147,143,252,29,68,12,52,153,70,40,134,163,77,132,240,116,176,81,42,165,134,211,65,23,1,3,17,33,120,115,160,53,156,
198,3,205,56,32,17,78,151,156,23,133,180,179,172,172,208,105,28,81,10,25,128,128,185,169,237,156,230,224,94,199,142,29,85,138,105,213,170,149,204,159,63,95,41,72,213,11,27,55,110,148,54,109,218,196,232,133,154,211,162,68,19,130,234,131,14,71,168,222,165,199,114,198,104,188,3,194,251,157,14,154,177,64,113,246,236,217,149,35,196,100,45,61,63,237,44,88,41,57,135,218,14,39,3,57,136,154,232,22,196,122,110,167,51,78,130,131,128,22,117,234,212,241,234,93,170,58,203,180,158,1,214,243,99,48,156,118,90,32,182,239,145,204,137,210,61,123,246,40,72,180,175,135,210,168,249,200,113,254,224,202,62,38,58,215,64,30,121,22,200,195,112,48,87,136,9,57,150,61,196,36,146,160,244,188,29,128,181,66,248,112,8,59,228,43,99,1,53,77,154,52,81,149,60,20,86,39,222,232,8,20,174,49,228,44,221,155,227,181,131,245,192,187,121,167,69,4,145,200,41,120,121,150,4,14,252,233,188,103,29,19,238,239,24,78,215,140,64,52,101,6,235,3,149,236,143,86,156,93,217,246,61,96,32,210,6,142,72,147,129,247,130,228,87,127,239,233,162,
122,131,132,59,61,177,99,199,142,169,196,186,120,241,226,144,113,222,190,153,80,175,77,216,82,144,67,99,22,3,1,63,250,160,155,160,189,24,101,216,35,136,247,92,228,73,94,207,67,115,121,222,159,208,122,206,112,158,81,60,221,114,77,80,48,30,251,213,112,169,115,38,206,133,92,68,39,4,138,142,10,6,38,143,7,51,110,148,177,244,198,169,157,128,27,194,154,226,13,42,174,127,139,141,179,246,80,146,57,4,2,33,56,16,142,126,24,209,19,232,237,169,125,79,40,77,119,61,136,62,94,44,198,182,12,246,61,112,13,75,229,79,65,188,173,224,12,122,33,19,52,31,26,31,157,127,116,249,24,139,133,128,32,66,243,240,225,195,74,81,224,39,150,15,23,188,80,155,225,133,64,23,255,36,210,17,4,57,136,140,252,111,143,47,166,57,128,174,54,50,80,34,96,108,152,33,50,216,35,18,121,255,95,14,71,99,233,205,99,52,94,51,208,60,229,165,27,145,70,78,64,145,120,7,53,85,32,66,2,27,164,143,134,103,241,42,133,228,76,71,129,240,103,60,198,129,20,0,107,188,73,13,6,3,122,95,161,156,117,189,6,195,98,31,58,215,5,218,119,40,243,255,157,207,
6,52,150,117,35,40,158,8,64,225,36,69,146,170,166,208,80,102,176,153,234,31,76,134,230,234,104,161,91,140,87,83,83,97,100,18,47,134,226,111,197,38,4,198,42,196,90,247,175,59,28,252,205,141,142,11,5,47,136,17,236,13,131,117,142,127,250,187,107,99,57,109,84,215,81,52,130,49,18,31,12,70,65,200,25,67,197,70,180,56,237,37,148,123,228,53,32,18,148,136,110,155,45,148,245,194,245,236,127,0,0,0,255,255,3,0,25,199,160,129,248,17,9,14,0,0,0,0,73,69,78,68,174,66,96,130);

function pub__sepCode(var xcore:tpubinfo;const xindex:longint32):string;

   function drepeatCode(const vrepeatCount:longint32;const vcode:string):string;
   var
      p                         :longint32;

   begin

   //defaults
   result                       :='';

   //get

   for p:=1 to vrepeatCount do
   begin

   result                       :=result + insstr(#32,result<>'') + vcode;

   end;//p

   end;

   procedure sp1(const vrepeatCount:longint32;const v:string);
   begin

   result                       :='<p class="sep s c vm100">' + drepeatCode( vrepeatCount ,v ) + '</p>';

   end;

   procedure sh1(const vclass:string);
   begin

   result                       :='<p class="s '+vclass+'">'+pub_space160+'</p>';//inherits text color

   end;

   procedure sc1(const vcustomCode:string);
   begin

   result                       :='<p class="s c vm100">'+ html__filterLine8(vcustomCode) + '</p>';

   end;

   procedure sa1(const v:array of byte);//???????????????????????? SVG do not work for Kindle Previewer 4!!!!!!!!!!!!!!!!!!!
   var
      b                         :tstr8;
      s                         :string;
      dindex                    :longint32;

   begin

   //defaults
   b                            :=nil;

   try

   //init
   b                            :=faststr__new8;

   //get
   b.aadd( v );

   //unzip
   if strmatch( io__anyformatb(@b) ,fezip ) then
      begin

      low__decompress( @b );

      end;

   //filter
   s                  :=u8__to8strb( b.text );//strip any BOM
   swapstrs( s ,'[[[fill]]]'   ,'#666666' );//Kindle does not support "currentcolor"

   //addImage
   //?????????????????????????????????????pub__addSVG( xcore ,s ,dindex );

   //set
   //result             :='<p class="svg sep s c vm100"><img class="svg" src="'+xcore.name[dindex]+'" /></p>';
   result             :='<p class="svg sep s c vm100">' + s + '</p>';
//   result             :=s;
   xcore.sepIsSVG     :=true;

   except;end;

   //free
   if (b<>nil) then faststr__free(@b);

   end;

   procedure pa1(const v:array of byte);
   var
      b                         :tstr8;
      s                         :string;
      dindex                    :longint32;

   begin

   //defaults
   b                            :=nil;

   try

   //init
   b                            :=faststr__new8;

   //get
   b.aadd( v );

   //unzip
   if strmatch( io__anyformatb(@b) ,fezip ) then
      begin

//      low__decompress( @b );

      end;


   //addImage
   if not pub__addImage( xcore ,b ,pub_isImageData ,dindex ) then showbasic('err');//???????????????


   //set
   result             :='<p class="sep s c vm100"><img style="width:6em;height:1.2em;" src="'+xcore.name[dindex]+'" /></p>';

   except;end;

   //free
   if (b<>nil) then faststr__free(@b);

   end;

begin

//defaults
xcore.sepIsSVG        :=false;

//get
case xindex of
1   :sc1( xcore.sceneSepCustom8                     );//custom
2   :sp1( 1,'*'                                     );
3   :sp1( 3,'*'                                     );
4   :sp1( 1,'&#9830;'                               );//1 black diamond
5   :sp1( 3,'&#9830;'                               );//3 black diamonds
6   :sp1( 1,'&#9830;&#65039;'                       );//1 red diamond
7   :sp1( 3,'&#9830;&#65039;'                       );//3 red diamonds
8   :sp1( 1,'&#10084;&#65039;'                      );//1 red love heart
9   :sp1( 3,'&#10084;&#65039;'                      );//3 red love hearts
10  :sh1('hline10'                                  );//inherits text color
11  :sh1('hline20'                                  );
12  :sh1('hline30'                                  );
13  :sh1('hline40'                                  );
14  :sh1('hline50'                                  );
15  :sp1( 1,'&#x2042;'                              );//1 Dinkus
16  :sp1( 3,'&#x2042;'                              );//3 Dinkus
17  :sp1( 1,'&#x2662; &#x2666; &#x2662;'            );//Diamond Trio
18  :sp1( 1,'&#x2766;'                              );//1 Floral Fleuron
19  :sp1( 3,'&#x2766;'                              );//3 Floral Fleuron
20  :sp1( 1,'&#x2767; &#x2766; &#x2767;'            );//Vine & Leaf
21  :sp1( 1,'&#x2726; &#x2727; &#x2726;'            );//Four-Point Sparkle
22  :sa1( file__1_svg );
//22  :pa1( file__scroll_png );//?????????????????????


else result:='';

end;//case

end;


end.
