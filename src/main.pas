unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, tools;
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
//## Library.................. app code (main.pas) -> Bubbles - Multi-Function Server
//## Version.................. 3.00.11252 (+99)
//## Items.................... 5
//## Last Updated ............ 09oct2026, 08oct2026, 09aug2025, 19jun2025, 17jun2025, 07apr2025, 22feb2025, 21nov2024, 18aug2024, 03may2024, 29apr2024, 30mar2024, 22mar2024, 16mar2024, 02mar2024, 29feb2024: str__splice(), 19feb2024, 13feb2024, 22jan224, 15jan2024, 03jan2023, 28dec2023, 26dec2023
//## Lines of Code............ 13,600+
//##
//## main.pas ................ app code
//## gossroot.pas ............ console/gui app startup and control
//## gossio.pas .............. file io
//## gossimg.pas ............. image/graphics
//## gossnet.pas ............. network
//## gosswin.pas ............. 32bit windows api's
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version    | Date        | Update history / brief description of function
//## |------------------------|-------------------|------------|-------------|--------------------------------------------------------
//## | Bubbles                | family of procs   | 1.00.10533 | 09oct2026   | Bubbles - 08oct2026, 09aug2025, 19jun2025, 07apr2025
//## | tmailsender            | tobjectex         | 1.00.530   | 07apr2025   | DNS lookup and STMP mail sender
//## | tshortdnscache         | tobjectex         | 1.00.030   | 06apr2025   | DNS A/MX record cache
//## | tshortlist             | tobjectex         | 1.00.020   | 06apr2025   | Simple list
//## | tnewvisitor            | tobjectex         | 1.00.025   | 07apr2025   | New visitor tracker
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
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

   iaddurl_def_off          ='Unable to accept url submissions at this stage';
   iaddurl_def_ok           ='Thank you for your submission, we will index it shortly';
   iaddurl_def_fail         ='Your url submission could not be processed';

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


bubbles_ico_32px
:array[0..4285] of byte=(
0,0,1,0,1,0,32,32,0,0,0,0,32,0,168,16,0,0,22,0,0,0,40,0,0,0,32,0,0,0,64,0,0,0,1,0,32,0,0,0,0,0,128,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,238,102,121,43,241,106,118,113,241,110,114,158,243,114,110,201,244,118,106,204,244,118,106,204,243,114,110,201,241,110,114,158,241,106,118,113,238,102,121,43,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,233,90,130,10,237,94,130,110,238,98,126,215,240,102,122,255,241,107,118,255,242,111,113,255,243,115,109,255,245,120,104,255,245,120,104,255,243,115,109,255,242,111,113,255,241,107,118,255,240,102,122,255,238,98,126,215,237,94,130,110,233,90,130,10,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,235,87,136,88,236,91,133,231,238,95,129,255,239,99,125,255,240,104,120,255,242,108,116,
255,242,113,111,255,244,117,107,255,245,122,103,255,245,122,103,255,244,117,107,255,242,113,111,255,242,108,116,255,240,104,120,255,239,99,125,255,238,95,129,255,236,91,133,231,235,87,136,88,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,232,81,141,10,234,84,140,170,235,88,136,255,237,92,132,255,238,97,128,255,239,101,123,255,241,106,119,255,242,110,114,255,243,114,110,255,244,119,105,255,246,123,101,255,246,123,101,255,244,119,105,255,243,114,110,255,242,110,114,255,241,106,119,255,239,101,123,255,238,97,128,255,237,92,132,255,235,88,136,255,234,84,140,170,232,81,142,10,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,230,77,145,17,233,81,143,201,235,85,139,255,236,90,135,255,237,94,130,255,239,98,126,255,240,103,121,255,241,107,117,255,243,112,113,255,243,116,108,255,245,120,104,255,246,125,99,255,246,125,99,255,245,120,104,255,243,116,108,255,243,112,113,255,241,107,117,255,240,103,121,255,239,98,126,255,
237,94,130,255,236,90,135,255,235,85,139,255,233,81,143,201,230,77,145,17,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,231,75,146,10,232,78,145,201,234,82,142,255,236,87,137,255,236,91,133,255,238,95,129,255,239,100,124,255,240,104,120,255,242,109,115,255,243,113,111,255,244,118,106,255,245,122,102,255,247,127,97,255,247,127,97,255,245,122,102,255,244,118,106,255,243,113,111,255,242,109,115,255,240,104,120,255,239,100,124,255,238,95,129,255,236,91,133,255,236,87,137,255,234,82,142,255,232,78,146,201,231,75,147,10,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,232,76,148,170,234,80,145,255,235,84,140,255,236,88,136,255,237,93,131,255,238,97,127,255,240,102,122,255,242,109,115,255,245,122,107,255,248,131,101,255,248,134,98,255,248,131,98,255,248,129,94,255,247,128,96,255,246,124,100,255,244,120,105,255,244,115,109,255,242,111,113,255,241,106,118,255,240,102,122,255,238,97,127,255,237,93,131,255,236,88,136,255,235,84,140,255,234,80,145,255,232,76,148,170,0,0,0,1,0,0,
0,1,0,0,0,1,0,0,0,1,0,0,0,1,231,74,150,88,233,77,147,255,234,81,143,255,235,86,138,255,237,90,134,255,237,95,129,255,241,105,120,255,251,158,121,255,254,200,170,255,254,224,208,255,254,235,224,255,254,238,229,255,254,235,224,255,254,225,210,255,253,203,181,255,250,162,132,255,246,124,102,255,244,117,107,255,243,112,112,255,241,108,116,255,240,104,121,255,239,99,125,255,237,95,129,255,237,90,134,255,235,86,138,255,234,81,143,255,233,77,147,255,231,74,150,88,0,0,0,1,0,0,0,1,0,0,0,1,226,70,149,10,232,74,149,231,234,78,146,255,234,83,141,255,235,87,137,255,237,92,132,255,238,96,128,255,250,159,129,255,254,235,224,255,255,255,254,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,254,253,255,254,233,224,255,248,166,151,255,243,114,110,255,242,110,115,255,241,105,119,255,239,100,123,255,238,96,128,255,237,92,132,255,235,87,137,255,234,83,141,255,234,78,146,255,232,74,150,231,226,71,149,10,0,0,0,1,0,0,0,1,230,72,151,110,233,76,148,
255,234,80,144,255,235,85,139,255,236,89,135,255,237,94,131,255,239,99,125,255,248,154,133,255,247,192,195,255,245,156,156,255,246,151,146,255,247,156,146,255,248,162,149,255,250,185,173,255,252,209,199,255,254,236,232,255,255,255,255,255,255,255,255,255,255,254,254,255,250,206,201,255,242,111,113,255,241,107,117,255,240,102,122,255,238,98,126,255,237,94,131,255,236,89,135,255,235,85,139,255,234,80,144,255,233,76,148,255,230,72,151,110,0,0,0,1,0,0,0,1,231,73,151,216,233,78,147,255,235,82,142,255,235,86,138,255,236,91,133,255,238,95,129,255,239,100,124,255,253,206,186,255,249,200,200,255,243,113,111,255,244,118,107,255,246,122,102,255,246,126,98,255,248,131,94,255,249,135,89,255,249,135,89,255,249,162,140,255,252,226,222,255,255,255,255,255,255,255,255,255,250,213,213,255,242,109,116,255,240,104,120,255,239,100,124,255,238,95,129,255,236,91,133,255,235,86,138,255,235,82,142,255,233,78,147,255,231,73,151,216,0,0,0,1,229,71,151,43,232,75,149,255,234,79,145,255,235,84,141,255,236,
88,136,255,237,92,131,255,238,97,127,255,239,102,123,255,247,160,151,255,255,252,252,255,245,144,140,255,245,119,105,255,246,124,100,255,247,128,96,255,248,133,92,255,250,137,87,255,250,137,87,255,248,133,92,255,247,128,96,255,251,199,189,255,255,255,255,255,255,255,255,255,249,203,204,255,241,106,118,255,239,102,123,255,238,97,127,255,237,92,131,255,236,88,136,255,235,84,141,255,234,79,145,255,232,75,149,255,229,71,151,43,231,73,150,113,233,77,148,255,234,81,143,255,236,85,139,255,236,90,134,255,237,94,130,255,239,99,125,255,240,103,121,255,242,109,115,255,253,224,216,255,251,218,216,255,245,121,103,255,247,125,99,255,247,130,94,255,249,134,90,255,250,139,86,255,250,139,86,255,249,134,90,255,247,130,94,255,247,127,98,255,254,231,221,255,255,255,255,255,255,254,254,255,243,140,146,255,240,103,121,255,239,99,125,255,237,94,130,255,236,90,134,255,236,85,139,255,234,81,143,255,233,77,148,255,231,73,150,113,232,74,149,159,233,78,146,255,235,83,141,255,236,87,137,255,237,92,133,255,
238,96,128,255,239,100,124,255,240,105,119,255,242,109,115,255,246,144,132,255,255,251,249,255,248,165,153,255,247,127,97,255,248,131,93,255,249,136,88,255,251,140,84,255,251,140,84,255,249,136,88,255,248,131,93,255,247,127,97,255,254,200,174,255,255,255,255,255,255,255,255,255,247,190,192,255,240,105,119,255,239,100,124,255,238,96,128,255,237,92,133,255,236,87,137,255,235,83,141,255,233,78,146,255,232,74,149,159,232,76,148,201,234,80,144,255,235,84,140,255,237,89,135,255,237,93,131,255,238,98,126,255,240,102,122,255,241,107,117,255,242,111,113,255,244,115,109,255,250,193,182,255,254,241,239,255,250,156,125,255,249,133,90,255,250,138,87,255,251,142,82,255,251,142,82,255,250,138,87,255,248,133,91,255,250,137,91,255,254,213,190,255,255,255,255,255,255,255,255,255,248,196,197,255,241,107,117,255,240,102,122,255,238,98,126,255,237,93,131,255,237,89,135,255,235,84,140,255,234,80,144,255,232,76,148,201,233,78,146,204,234,82,143,255,236,86,138,255,237,90,134,255,238,95,129,255,239,99,
125,255,240,104,120,255,241,108,116,255,243,113,111,255,244,117,107,255,246,124,103,255,254,231,225,255,255,252,250,255,254,225,212,255,253,191,163,255,253,167,120,255,253,158,104,255,253,156,103,255,253,169,124,255,254,205,177,255,255,247,242,255,255,255,255,255,255,251,251,255,244,141,141,255,241,108,116,255,240,104,120,255,239,99,125,255,238,95,129,255,237,90,134,255,236,86,138,255,234,82,143,255,233,78,146,204,233,78,146,204,234,82,143,255,236,86,138,255,237,90,134,255,238,95,129,255,239,99,125,255,240,104,120,255,241,108,116,255,243,113,111,255,244,117,107,255,245,121,103,255,248,151,127,255,255,250,248,255,254,238,234,255,254,244,242,255,255,253,252,255,255,249,246,255,255,247,242,255,255,250,247,255,255,255,254,255,255,254,253,255,252,227,225,255,246,155,149,255,243,113,111,255,241,108,116,255,240,104,120,255,239,99,125,255,238,95,129,255,237,90,134,255,236,86,138,255,234,82,143,255,233,78,146,204,232,76,148,201,234,80,144,255,235,84,140,255,237,89,135,255,237,93,131,255,
238,98,126,255,240,102,122,255,241,107,117,255,242,111,113,255,244,115,109,255,244,120,104,255,246,124,100,255,251,186,170,255,254,244,242,255,251,155,118,255,252,156,111,255,253,188,164,255,253,216,207,255,254,243,239,255,254,233,223,255,251,171,145,255,245,122,104,255,244,115,109,255,242,111,113,255,241,107,117,255,240,102,122,255,238,98,126,255,237,93,131,255,237,89,135,255,235,84,140,255,234,80,144,255,232,76,148,201,232,74,149,158,233,78,146,255,235,83,141,255,236,87,137,255,237,92,133,255,238,96,128,255,239,100,124,255,240,105,119,255,247,132,108,255,253,194,166,255,246,145,135,255,245,123,102,255,247,127,97,255,253,217,208,255,254,235,230,255,251,147,98,255,251,140,84,255,249,136,88,255,248,131,93,255,249,172,159,255,252,225,222,255,253,230,223,255,246,148,139,255,242,109,115,255,240,105,119,255,239,100,124,255,238,96,128,255,237,92,133,255,236,87,137,255,235,83,141,255,233,78,146,255,232,74,149,158,231,73,150,113,233,77,148,255,234,81,143,255,236,85,139,255,236,90,134,
255,237,94,130,255,239,99,125,255,240,103,121,255,251,167,135,255,255,249,246,255,253,228,222,255,249,148,122,255,247,125,99,255,248,136,104,255,254,237,232,255,253,221,212,255,250,139,86,255,249,134,90,255,247,130,94,255,247,125,99,255,245,121,103,255,246,170,166,255,254,244,241,255,245,163,166,255,240,103,121,255,239,99,125,255,237,94,130,255,236,90,134,255,236,85,139,255,234,81,143,255,233,77,148,255,231,73,150,113,229,71,151,43,232,75,149,255,234,79,145,255,235,84,141,255,236,88,136,255,237,92,131,255,238,97,127,255,239,102,123,255,243,133,131,255,254,248,247,255,255,255,255,255,255,251,249,255,254,219,205,255,251,174,145,255,251,161,126,255,254,244,242,255,252,193,176,255,248,133,92,255,247,128,96,255,246,124,100,255,245,119,105,255,243,115,109,255,252,193,171,255,255,252,252,255,243,157,167,255,238,97,127,255,237,92,131,255,236,88,136,255,235,84,141,255,234,79,145,255,232,75,149,255,229,71,151,43,0,0,0,1,231,73,151,216,233,78,147,255,235,82,142,255,235,86,138,255,236,91,
133,255,238,95,129,255,239,100,124,255,240,104,120,255,244,152,156,255,253,242,243,255,255,255,255,255,255,255,255,255,255,255,255,255,255,245,240,255,254,232,221,255,254,209,189,255,252,170,135,255,250,152,113,255,249,144,109,255,250,148,110,255,252,167,126,255,254,217,196,255,255,255,255,255,250,227,230,255,238,95,129,255,236,91,133,255,235,86,138,255,235,82,142,255,233,78,147,255,231,73,151,216,0,0,0,1,0,0,0,1,230,73,151,110,233,76,148,255,234,80,144,255,235,85,139,255,236,89,135,255,237,94,131,255,238,98,126,255,240,102,122,255,241,107,117,255,243,121,123,255,248,194,193,255,254,245,244,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,254,254,255,255,250,247,255,255,245,240,255,255,245,239,255,255,250,247,255,255,255,254,255,255,255,255,255,249,219,223,255,237,94,131,255,236,89,135,255,235,85,139,255,234,80,144,255,233,76,148,255,230,73,151,110,0,0,0,1,0,0,0,1,226,71,149,10,232,74,150,231,234,78,146,255,234,83,141,255,235,87,137,255,237,92,132,255,238,
96,128,255,239,100,123,255,241,105,119,255,242,110,115,255,243,114,110,255,245,118,106,255,248,169,160,255,251,209,202,255,254,240,238,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,251,229,232,255,240,129,150,255,237,92,132,255,235,87,137,255,234,83,141,255,234,78,146,255,232,74,150,231,226,71,150,10,0,0,0,1,0,0,0,1,0,0,0,1,231,74,150,89,233,77,147,255,234,81,143,255,235,86,138,255,237,90,134,255,237,95,129,255,239,99,125,255,240,104,121,255,241,108,116,255,243,112,112,255,244,117,107,255,245,121,103,255,246,126,99,255,248,130,94,255,249,146,118,255,249,175,163,255,249,190,185,255,249,195,193,255,247,188,188,255,246,180,183,255,242,137,148,255,239,99,125,255,237,95,129,255,237,90,134,255,235,86,138,255,234,81,143,255,233,77,147,255,231,74,150,89,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,233,76,148,170,234,80,145,255,235,84,140,255,236,88,136,255,237,93,131,255,238,97,127,255,240,102,122,255,241,106,118,255,242,
111,113,255,244,115,109,255,244,120,105,255,246,124,100,255,247,128,96,255,247,128,96,255,246,124,100,255,244,120,105,255,244,115,109,255,242,111,113,255,241,106,118,255,240,102,122,255,238,97,127,255,237,93,131,255,236,88,136,255,235,84,140,255,234,80,145,255,233,76,148,170,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,233,76,148,10,233,78,146,201,234,82,142,255,236,87,137,255,236,91,133,255,238,95,129,255,239,100,124,255,240,104,120,255,242,109,115,255,243,113,111,255,244,118,106,255,245,122,102,255,247,127,97,255,247,127,97,255,245,122,102,255,244,118,106,255,243,113,111,255,242,109,115,255,240,104,120,255,239,100,124,255,238,95,129,255,236,91,133,255,236,87,137,255,234,82,142,255,233,78,146,201,233,76,148,10,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,233,79,146,18,234,81,143,201,235,85,139,255,236,90,135,255,237,94,130,255,239,98,126,255,240,103,121,255,241,107,117,255,243,112,113,255,243,116,108,255,245,120,104,255,246,125,99,255,246,125,99,255,245,120,104,
255,243,116,108,255,243,112,113,255,241,107,117,255,240,103,121,255,239,98,126,255,237,94,130,255,236,90,135,255,235,85,139,255,234,81,143,201,233,79,146,18,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,234,82,143,10,235,84,140,170,235,88,136,255,237,92,132,255,238,97,128,255,239,101,123,255,241,106,119,255,242,110,114,255,243,114,110,255,244,119,105,255,246,123,101,255,246,123,101,255,244,119,105,255,243,114,110,255,242,110,114,255,241,106,119,255,239,101,123,255,238,97,128,255,237,92,132,255,235,88,136,255,235,84,140,170,234,82,143,10,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,235,87,137,89,236,91,133,231,238,95,129,255,239,99,125,255,240,104,120,255,242,108,116,255,242,113,111,255,244,117,107,255,245,122,103,255,245,122,103,255,244,117,107,255,242,113,111,255,242,108,116,255,240,104,120,255,239,99,125,255,238,95,129,255,236,91,133,231,235,87,137,89,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,
0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,237,92,133,10,238,94,130,110,238,98,126,216,240,102,122,255,241,107,118,255,242,111,113,255,243,115,109,255,245,120,104,255,245,120,104,255,243,115,109,255,242,111,113,255,241,107,118,255,240,102,122,255,238,98,126,216,238,94,130,110,237,92,133,10,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,240,103,122,43,241,106,118,113,241,110,114,159,243,114,110,201,244,118,106,204,244,118,106,204,243,114,110,201,241,110,114,159,241,106,118,113,240,103,122,43,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,255,224,7,255,255,0,0,255,254,0,0,127,248,0,0,31,240,0,0,15,224,0,0,7,224,0,0,7,192,0,0,3,128,0,0,1,128,0,0,1,128,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,1,128,0,0,1,128,0,0,1,192,0,0,3,224,0,0,7,224,0,0,7,240,0,0,15,248,
0,0,31,254,0,0,127,255,0,0,255,255,224,7,255);


   //flow stages
   fs__sendlist__haveaddr                 =0;

   //.mx record lookup
   fs__mxdns__usecache                    =10;
   fs__mxdns__connect                     =20;
   fs__mxdns__pushquery                   =30;
   fs__mxdns__pullquery                   =40;

   //.a record lookup
   fs__Adns__mxlist                       =100;
   fs__adns__usecache                     =110;
   fs__adns__connect                      =120;
   fs__adns__pushquery                    =130;
   fs__adns__pullquery                    =140;

   //.mail send
   fs__sendmail__iplist                   =200;
   fs__sendmail__start                    =210;//work through the mail-server-domains -> ips
   fs__sendmail__pull_welcome             =220;
   fs__sendmail__push_helo                =230;
   fs__sendmail__pull_helo                =240;
   fs__sendmail__push_mailfrom            =250;
   fs__sendmail__pull_mailfrom            =260;
   fs__sendmail__push_rcptto              =270;
   fs__sendmail__pull_rcptto              =280;
   fs__sendmail__push_data                =290;
   fs__sendmail__pull_data                =300;
   fs__sendmail__push_message             =310;
   fs__sendmail__pull_message             =320;

   fs__sendmail__doneaddress              =410;
   fs__sendmail__addressfailed            =420;


type
//xxxxxxxxxxxxxxxxxxxxxxxxx//6666666666666666666666666666
{tnewvisitor}
   tnewvisitor_addr=array[0..40] of byte;
   tnewvisitor=class(tobjectex)
   private
    ilimit:longint;
    ilen :array[0..19999] of byte;
    iref1:array[0..19999] of longint;
    iref2:array[0..19999] of longint;
    iaddr:array[0..19999] of tnewvisitor_addr;
    itime:array[0..19999] of comp;
   public
    //create
    constructor create;
    destructor destroy; override;
    //workers
    procedure clear;
    function new(const xip:string):boolean;
   end;

{tshortdnscache}
   tshortdnscache=class(tobjectex)
   private
    ilimit:longint;
    idomref:array[0..999] of comp;
    idomain:array[0..999] of string;
    iinfo  :array[0..999] of string;//A-record=list of IPs, MX-record=list of domains
    itime64:array[0..999] of comp;
   public
    //create
    constructor create;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    //clear
    function clear:boolean;
    //domain
    function exists(const xdomain:string):boolean;
    function exists2(xdomain:string;var xinfo:string):boolean;
    function dead(const xdomain:string):boolean;//mark as dead
    function add(xdomain,xinfo:string):boolean;
   end;

{tshortlist}
   tshortlist=class(tobjectex)
   private
    ilimit,icount:longint;
    ilist:array[0..199] of string;
   public
    //create
    constructor create;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    property count:longint read icount;
    //clear
    function clear:boolean;
    //fill entire list (one line of text per slot)
    function fill(const xtext:string):boolean;
    function fill2(const xtext:string;xstripwhitespace,xremoveblanklines:boolean):boolean;
    //pull slot content (from begnning of list)
    function canpull:boolean;
    function pull(var x:string):boolean;
    function pullb:string;
    //push slot content (append to end of list)
    function canpush:boolean;
    function push(const x:string):boolean;
   end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//000000000000000000
   tmailsender=class(tobjectex)
   private
    isocket:tsocket;
    ipaused,itimerbusy,idisable,isockconnected,isockclosed:boolean;
    istartref,ifilelistref,ilinger,itimeout:comp;
    iflow:tflowcontrol;
    ierrorinfo,ifilename,iusername,idomain,imaildomain,ifolder,ifrom,ito,ifallbacklist,idnslist:string;//root nameservers
    itemp,idata,iline:tstr8;//email message itself
    iport,iip4:longint;
    isendlist,ifilelist:tdynamicstring;
    ivars:tfastvars;

    //dns
    dns__pulllen :longint;
    dns__pullbuf :tstr8;
    dns__pushbuf :tstr8;
    dns__rootlist:tshortlist;
    dns__mxlist  :tshortlist;
    dns__alist   :tshortlist;
    dns__mxcache :tshortdnscache;
    dns__acache  :tshortdnscache;

    //.mail
    mail__buf       :tstr8;
    mail__pulledcode:longint;
    mail__pulledfullcode:string;//includes any description

    //socket
    procedure xsockstop;
    function xsockstart(xip4,xport:longint):boolean;
    //timeout
    function xtimedout:boolean;

    //dns io procs - low level tcp 2 byte header (push=dns__pushbuf and pull=dns__pullbuf)
    function  dns__moretime:boolean;
    function  dns__pushclear:boolean;
    function  dns__pushdone:boolean;
    function  dns__push:boolean;
    function  dns__pullclear:boolean;
    function  dns__pull:boolean;
    function  dns__pulldone:boolean;

    //mail io procs (push/pull=mail__buf)
    function mail__moretime:boolean;
    function mail__linger_timedout(xms:longint):boolean;
    function mail__pushclear:boolean;
    function mail__pushadd(const x:string):boolean;
    function mail__push:boolean;
    function mail__pushdone:boolean;
    function mail__pullclear:boolean;
    function mail__pull:boolean;
    function mail__pulldone:boolean;
    function mail__pullcode:boolean;

    //message queue
    function msg__clear:boolean;
    function msg__found:boolean;//load next email in queue + it's sendlist (or create it)
    function msg__sendlist_havenext:boolean;//next address in sendlist to send the email to
    function msg__sendlist_markdone(xsentOK:boolean):boolean;//mark that address as sent=OK or sent=FAILED
    function msg__notdelivered(xerrmsg:string;xattachOriginalMessage:boolean):boolean;
    procedure msg__reset_filelist;
    function msg__nextfileinqueue:string;
    procedure setfolder(x:string);

    //other
    procedure onmessage(m,w,l:longint);
    procedure setdnslist(const x:string);
   public
    //vars
    ouseragent:string;
    osenderdomain:string;
    //create
    constructor create;
    destructor destroy; override;

    //information
    property fallbacklist:string read ifallbacklist;//ip4
    property dnslist:string read idnslist write setdnslist;//ip4
    property folder:string read ifolder write setfolder;
    property paused:boolean read ipaused write ipaused;
    function status:string;//debug purposes

    //workers
    function saveTOqueue(xnewemail:pobject):boolean;//save an "eml" email datastream into the queue

    //host driven
    procedure xtimer;
   end;


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
   imail_mask:string='';//inbound mail mask -> used to allow only accepted email addresses/domains - optional
   imail_fromaddress:string='';
   imail_sizelimit:longint=10;//in megabytes
   imail_allow:boolean=false;
   imail_sender:tmailsender=nil;//05apr2025
   inewvisitor:tnewvisitor=nil;//07apr2025
   iua_mask:string='';//ban inbound http user agents - optional - 09aug2025
   iip_mask:string='';//ban inbound http IPs - optional - 09aug2025

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
   inotthislink:string='';//07apr2025

   //shared resources -> these are used amongst all connections
   ibuffer:array[0..65535] of byte;//shared buffer
   ibuf2:tobject;//can be tstr8 or tstr9
   igmtstr:string;
   ivars:tfastvars;

   icontact_allow               :boolean;
   icontact_question            :boolean;
   icontact_off                 :string;
   icontact_ok                  :string;
   icontact_fail                :string;

   isubscribe_allow             :boolean;
   isubscribe_question          :boolean;

   //settings
   imustboost,icache,ialongsideexe,ishutidle,icsp,inorefdown,isubscribeEachNotice,isubscribenotice,isummarynotice,iquotanotice,ireloadnotice,ireverseproxy,ilivestats,irawlogs:boolean;
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
   idaily_newvisitors,idaily_visitors,idaily_requests,idaily_hits,idaily_email,idaily_contact,idaily_jobs:comp;//for use with xlivestatus -> reset every 24hr by "xendofday"

   //fast folder references
   ifastfolder__logs:string;
   ifastfolder__inbox:string;
   ifastfolder__inbox_read:string;
   ifastfolder__trash:string;//16mar2024
   ifastfolder__trash_read:string;
   ifastfolder__root:string;

   //contact form question support
   ispamGuard_answer            :array [0..999] of longint32;//0=question not set, as answers are always ">=1" - 04apr2024
   ispamGuard_index             :longint32;


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function app__bol(xname:string):boolean;
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
procedure stm__readmail(var a:pnetwork);//implements the SMTP protocol - 20feb2025: disable connection reuse for email, 11mar2024: updated to 40K search

//log report procs
function log__info(xname:string):string;
procedure log__makereport(var a:pnetwork;slogfilename:string);
function log__buildreport(var a:pnetwork;d:tobject;dmakeref,slogfilename:string):boolean;

//Spam Guard support - 09oct2026
function  spamGuard__makeQuestion(var xquestion:string):boolean;
function  spamGuard__checkAnswer(const xanswer:longint32):boolean;

//support procs
function hits__extcounts(xext:string):boolean;
procedure inc__dailyjobs;
procedure xload_counter(var x:tfastvars;xfilename:string);//17jun2025
function xconn_limit:longint;//maximum number of records permitted
function xconn_count:longint;//number of records in use
function xaccept_connection_autotype(s:tsocket):boolean;
procedure xclose_connection(x:pnetwork);
procedure xsetdaily_bandwidth_quota(xquota_in_mb:comp);
function bubbles__daily_bandwidth_exceeded:boolean;
procedure bubbles__inc_daily_bandwidth(xlen:comp);
function xmakehelp(xclaudehelp:boolean):string;
function xsymbol(xname:string):string;
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
function xcompose(var a:pnetwork;xstyle,xcmd,xcmd2:string):string;//03apr2025
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
function xlivestatus(xstyle:longint):string;//realtime vital statistics - 21feb2025
function xinfo2(xpageurl,xcmd:string):string;
procedure xinfo(xpageurl,xcmd:string;var xtitle,xout:string);
function xmanage:string;//19jun2025
function xredirect__have(sname:string;var dnameORurl:string):boolean;
function xredirect__sitelinks(ssite:string):string;
procedure xredirect__addlocal(xsite,xlinks:string);
procedure xredirect__clean(xremovesite:string);
function xh2(xlinkname,xname:string):string;
function xh2b(xlinkname,xname,xclass:string):string;
function xvsep:string;
function xvsepbig:string;
function xhtmlstart(var a:pnetwork;xshowtoolbar:boolean):string;
function xhtmlstart1(var a:pnetwork;xhead:string;xshowtoolbar:boolean;xmaxwidth:longint):string;
function xhtmlstart2(var a:pnetwork;xhead:string;xshowtoolbar:boolean):string;
function xhtmlstart3(var a:pnetwork;xhead:string;xshowtoolbar,xbare,xultrawide:boolean):string;
function xhtmlstart4(var a:pnetwork;xhead0,xhead1:string;xshowtoolbar,xbare,xultrawide:boolean):string;
function xhtmlstart5(var a:pnetwork;xhead0,xhead1:string;xshowtoolbar,xbare:boolean;xmaxwidth:longint):string;
function xhtmlback:string;
function xhtmlfinish:string;
function xhtmlfinish2(xbare:boolean):string;
function xsafewebname(var x:string):boolean;

function  contact__html(var a:pnetwork):boolean;

function  subscribe__html(var a:pnetwork;const ddiskHost:string;const xsubscribe:boolean):boolean;//08oct2026
function  subscribe__listFilename(const ddiskHost:string;const xdailyList:boolean):string;
function  subscribe__manageOne(const ddiskHost:string;var demail:string;const xdailyList,xaddEmail:boolean;var xoutmsg:string):boolean;//09oct2026
function  subscribe__manageList(var xlistCount:longint32;const ddiskHost:string;const xreplaceListWithThisList:string;const xdailyList,xreplaceList,xdeleteList:boolean):string;//09oct2026

function xcodeis__badrequest(xcode:longint):boolean;
function xlogrequest_http(var a:pnetwork;xaltcode:longint):boolean;
function xlogrequest_smtp(var a:pnetwork;xcode:longint):boolean;
function xcodedes(xcode:longint):string;
function xmimelist:string;
procedure xmime_fallback;
function xmimetype(xext:string):string;//09apr2024: updated to allow minor modification to "html", includes common fallback defaults - 26dec2923
function xcommonheaders(xext:string;xkeepalive,xcache,xacceptranges:boolean):string;
procedure xinchit(xdiskhost:string);
procedure xresolvehost(m:tnetbasic);//use mapping

function html__checkbox(xlabel,xname:string;xchecked,xenabled,xdiv:boolean):string;
function utf8__toplaintext7bitb(const x:string):string;//08oct2026
function date__str(const x:tdatetime;const xtime,xmsec:boolean):string;//08oct2026

function  png__makeHits(x:tstr8;xhits:longint64):boolean;//make "hits.png" image - 09oct2026
procedure png__makeAll(const xforce:boolean);//make all "hits.png" for listed disk domains "idom"

function  cmdline__mustclose:boolean;
function  cmdline__mustclose2(xforcecmd:string;var xoutput:string):boolean;
function  cmdline__output(const xforcecmd:string):string;

function  bytes__RAM:longint64;//09oct2026

function email__valid(const xemailAddress:string):boolean;
function email__filteraddress(const xemailAddress:string):string;

function domain__fromDiskSite(const xdisksite:string):string;

implementation


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function app__bol(xname:string):boolean;
begin
result:=strbol(app__info(xname));
end;

function info__app(xname:string):string;//information specific to this unit of code - 09apr2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if (xname='language')                 then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='msix.tags')           then result:='-'//for Clyde - 31jan2026
else if (xname='msstore.name')        then result:='Bubbles'//optional - overrides default name for Clyde

else if (xname='ver')                 then result:='3.00.11252'
else if (xname='date')                then result:='09oct2026'
else if (xname='name')                then result:='Bubbles'
else if (xname='des')                 then result:='Multi-Function Server'
else if (xname='infoline')            then result:='Bubbles Multi-Function Server v'+app__info('ver')+' (c) 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:='Bubbles Multi-Function Server'
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:='HTTP/1, SMTP, web panel, web mail, virtual hosting, domain mapping, redirector, logs + reports, contact form and site counters'
else if (xname='tools')               then result:='1'//1=enable built-in tools, 0=disable built-in tools

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2026)+' Blaiz Enterprises'

else
   begin
   //nil
   end;

except;end;
end;

//## tnewvisitor ###############################################################
constructor tnewvisitor.create;
begin
//self
if classnameis('tnewvisitor') then track__inc(satOther,1);
inherited create;

ilimit:=high(ilen)+1;
clear;
end;

destructor tnewvisitor.destroy;
begin
try
//self
inherited destroy;
if classnameis('tnewvisitor') then track__inc(satOther,-1);
except;end;
end;

procedure tnewvisitor.clear;
var
   p:longint;
begin
for p:=0 to (ilimit-1) do
begin
ilen [p]:=0;
iref1[p]:=0;
iref2[p]:=0;
itime[p]:=0;
end;//p
end;
//xxxxxxxxxxxxxxxxxxxxxxxxx//6666666666666666666666666666

function tnewvisitor.new(const xip:string):boolean;
var//support for IPv4 and IPv6 address spaces
   i,xlen,xref1,xref2,p,p2:longint;
   xage:comp;
   xfound:boolean;

   procedure xrefs;
   begin
   xref1:=low__ref32u(xip);//never zero
   xref2:=low__ref32u(strcopy1(xip,10,xlen));//maybe zero
   end;
begin
//defaults
result:=false;
xlen  :=frcmax32(low__len32(xip),1+high(iaddr[0]) );//ignore any trailing parts of the address -> should not exceed 39 bytes for a FULL IPv6 address with [...] square brackets included

//check -> address must be 1+ chars in length
if (xlen<=0) then exit;

//init
xfound:=false;
xref1 :=0;//don't fill it till we need it
xref2 :=0;

//find
for p:=0 to (ilimit-1) do if (ilen[p]=xlen) and (iref1[p]<>0) then
   begin
   //init
   if (xref1=0) then xrefs;//once only

   //get
   if (iref1[p]=xref1) and (iref2[p]=xref2) then
      begin
      xfound:=true;

      for p2:=1 to xlen do if (byte(xip[p2-1+stroffset])<>iaddr[p][p2-1]) then
         begin
         xfound:=false;
         break;
         end;

      if xfound then break;
      end;
   end;//p

//add
if not xfound then
   begin
   //init
   if (xref1=0) then xrefs;//once only
   i   :=0;
   xage:=max64;

   //find oldest slot
   for p:=0 to (ilimit-1) do if (ilen[p]<=0) or (itime[p]<xage) then
      begin
      xage:=itime[p];
      i   :=p;
      if (xage<=0) then break;//oldest possible age is 0
      end;//p

   //get
   iref1[i]:=xref1;
   iref2[i]:=xref2;
   ilen [i]:=xlen;
   itime[i]:=ms64;
   for p2:=1 to xlen do iaddr[i][p2-1]:=byte(xip[p2-1+stroffset]);

   //new
   result:=true;
   end;

end;

//## tshortdnscache ############################################################
constructor tshortdnscache.create;
begin
//self
if classnameis('tshortdnscache') then track__inc(satOther,1);
inherited create;

ilimit:=high(idomref)+1;
clear;
end;

destructor tshortdnscache.destroy;
begin
try
//self
inherited destroy;
if classnameis('tshortdnscache') then track__inc(satOther,-1);
except;end;
end;

function tshortdnscache.clear:boolean;
var
   p:longint;
begin
result:=true;

for p:=0 to (ilimit-1) do
begin
idomref[p]:=0;
idomain[p]:='';
iinfo  [p]:='';
itime64[p]:=0;
end;//p

end;

function tshortdnscache.exists(const xdomain:string):boolean;
var
   xinfo:string;
begin
result:=exists2(xdomain,xinfo);
end;

function tshortdnscache.exists2(xdomain:string;var xinfo:string):boolean;
var
   p:longint;
   dref:comp;
begin
//defaults
result:=false;
xinfo :='';

//range
if (xdomain='') then xdomain:='*';

//init
dref:=low__ref256U(xdomain);

//find
for p:=0 to (ilimit-1) do if (dref=idomref[p]) and strmatch(xdomain,idomain[p]) then
   begin

   if (itime64[p]>=ms64) then
      begin
      result:=true;
      xinfo :=iinfo[p];
      end;

   break;
   end;//p

end;

function tshortdnscache.dead(const xdomain:string):boolean;//mark as dead
begin
result:=add(xdomain,'');
end;

function tshortdnscache.add(xdomain,xinfo:string):boolean;
var
   i,p:longint;
   xage,dref:comp;
   xdone:boolean;
begin
//pass-thru
result:=true;
xdone :=false;

//range
if (xdomain='') then xdomain:='*';

//init
dref:=low__ref256U(xdomain);

//find existing
for p:=0 to (ilimit-1) do if (dref=idomref[p]) then
   begin
   itime64[p]:=add64(ms64,60*60*1000);//1 hr
   iinfo  [p]:=xinfo;
   xdone:=true;
   break;
   end;

//add new
if not xdone then
   begin
   //find oldest
   i   :=0;
   xage:=max64;

   for p:=0 to (ilimit-1) do if (itime64[p]<xage) then
      begin
      xage:=itime64[p];
      i   :=p;
      if (xage<=0) then break;//0=oldest possible age
      end;

   //get
   itime64[i]:=add64(ms64,60*60*1000);//1 hr
   idomref[i]:=dref;
   idomain[i]:=xdomain;
   iinfo  [i]:=xinfo;
   end;

end;


//## tshortlist ################################################################
constructor tshortlist.create;
begin
//self
if classnameis('tshortlist') then track__inc(satOther,1);
inherited create;

ilimit:=high(ilist)+1;
icount:=0;
end;

destructor tshortlist.destroy;
begin
try
//self
inherited destroy;
if classnameis('tshortlist') then track__inc(satOther,-1);
except;end;
end;

function tshortlist.clear:boolean;
var
   p:longint;
begin
result:=true;
icount:=0;
for p:=0 to (ilimit-1) do ilist[p]:='';
end;

function tshortlist.fill(const xtext:string):boolean;
begin
result:=fill2(xtext,false,false);
end;

function tshortlist.fill2(const xtext:string;xstripwhitespace,xremoveblanklines:boolean):boolean;
var
   xlen,xpos:longint;
   xline:string;
begin
//defaults
result:=true;
xpos  :=0;
xlen  :=low__len32(xtext);
//clear
clear;

//get
while low__nextline1(xtext,xline,xlen,xpos) do
begin
if xstripwhitespace then xline:=stripwhitespace_lt(xline);

if (icount<ilimit) and ((not xremoveblanklines) or (xline<>'')) then
   begin
   ilist[icount]:=xline;
   inc(icount);
   if (icount>=ilimit) then break;
   end;
end;//loop

end;

function tshortlist.canpull:boolean;
begin
result:=(icount>=1);
end;

function tshortlist.pull(var x:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;
x     :='';

try
//get
if (icount>=1) then
   begin
   //get
   x:=ilist[0];
   dec(icount);
   result:=true;

   //shift all slots down one position
   for p:=0 to frcmax32(icount-1,ilimit-2) do ilist[p]:=ilist[p+1];

   //clear used slot
   ilist[icount]:='';
   end;
except;end;
end;

function tshortlist.pullb:string;
begin
pull(result);
end;

function tshortlist.canpush:boolean;
begin
result:=(icount<ilimit);
end;

function tshortlist.push(const x:string):boolean;
begin
result:=false;

try
if (icount<ilimit) then
   begin
   ilist[icount]:=x;
   inc(icount);
   result:=true;
   end;
except;end;
end;


//## tmailsender ###############################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxx//000000000000000000000000
constructor tmailsender.create;
begin
//self
if classnameis('tmaildns') then track__inc(satOther,1);
inherited create;

//vars
ouseragent   :='';
osenderdomain:='';
itimerbusy   :=false;
ipaused      :=false;
idisable     :=false;
isocket      :=invalid_socket;
itimeout     :=0;
ilinger      :=0;
ito          :='';
ifrom        :='';
iusername    :='';
idomain      :='';
ifolder      :='';
idnslist     :='';
ifilename    :='';//name only (incase folder changes during send procees, deletion can still take place in new folder)
istartref    :=0;
ifilelistref :=0;
ifilelist    :=tdynamicstring.create;
isendlist    :=tdynamicstring.create;

iflow        :=tflowcontrol.create;
iflow.onumerical:=true;

idata        :=str__new8;
iline        :=str__new8;
itemp        :=str__new8;
ivars        :=tfastvars.create;//general purpose - temp


//dns servers to query
ifallbacklist:=net__cleanlistIP4('8.8.8.8'+rcode+'8.8.4.4');

dns__pulllen :=-1;
dns__pullbuf :=str__new8;
dns__pushbuf :=str__new8;
dns__rootlist:=tshortlist.create;
dns__mxlist  :=tshortlist.create;
dns__alist   :=tshortlist.create;
dns__mxcache :=tshortdnscache.create;
dns__acache  :=tshortdnscache.create;

//mail
mail__buf       :=str__new8;
mail__pulledcode:=0;


//init buffers
dns__pullclear;
dns__pushclear;
mail__pullclear;
mail__pushclear;

end;

destructor tmailsender.destroy;
begin
try
//stop everything from processing
idisable:=true;

//vars
freeobj(@iflow);
freeobj(@ifilelist);
freeobj(@isendlist);
str__free(@idata);
str__free(@iline);
str__free(@itemp);
freeobj(@ivars);
freeobj(@dns__rootlist);
freeobj(@dns__mxlist);
freeobj(@dns__alist);
freeobj(@dns__mxcache);
freeobj(@dns__acache);
str__free(@dns__pushbuf);
str__free(@dns__pullbuf);
str__free(@mail__buf);
xsockstop;

//self
inherited destroy;
if classnameis('tmaildns') then track__inc(satOther,-1);
except;end;
end;

function tmailsender.status:string;
var
   v:string;
begin
v:='';

if iflow.idle then v:='Idle'
else
   begin
   case iflow.stagename32 of
   fs__mxdns__usecache,
   fs__mxdns__connect,
   fs__mxdns__pushquery,
   fs__mxdns__pullquery:v:='DNS MX record lookup via '+net__ip4str(iip4);

   fs__Adns__mxlist,
   fs__adns__usecache,
   fs__adns__connect,
   fs__adns__pushquery,
   fs__adns__pullquery:v:='DNS A record lookup via '+net__ip4str(iip4);
   fs__sendmail__start..maxint:v:='Sending mail to '+imaildomain+' ('+net__ip4str(iip4)+')';
   else v:='Sending mail...';
   end;//case
   end;

result:='Sendmail'+insstr( '('+k64(ifilelist.count+1)+')',not iflow.idle )+': '+v;
end;

procedure tmailsender.setfolder(x:string);
begin
x:=io__asfolderNIL(x);
io__makefolder(x);

//.force list to update next time it's accessed
if low__setstr(ifolder,x) then msg__reset_filelist;
end;

procedure tmailsender.msg__reset_filelist;
begin
ifilelist.clear;
ifilelistref :=0;
istartref    :=0;
end;

function tmailsender.saveTOqueue(xnewemail:pobject):boolean;
label
   skipend;
var
   xref:comp;
   e,df:string;
begin
//defaults
result:=false;

try
//check
if not str__lock(xnewemail) then exit;
if idisable                 then goto skipend;

//init
xref:=add64(ms64,30000);

//get
while true do
begin

if      (ifolder='') then goto skipend//can't write file we have no destination folder
else if (ms64>=xref) then goto skipend//timed out trying
else
   begin
   df:=ifolder+low__dateascode(date__now)+'.eml';

   if not io__fileexists(df) then
      begin
      io__remfile(df+'.txt');//remove existing state file if it exists -> auto. generated when system goes to load and send email - 06apr2025

      if io__tofile(df,xnewemail,e) then
         begin
         result:=true;//file was written -> success
         msg__reset_filelist;
         break;
         end
      else goto skipend;//failed to write file
      end
   else win____sleep(10);

   end;

end;//loop

skipend:
except;end;
//free
str__uaf(xnewemail);
end;

function tmailsender.xtimedout:boolean;
begin
result:=(ms64>=itimeout);
end;

function tmailsender.msg__nextfileinqueue:string;
begin
//defaults
result:='';

//check
if idisable then exit;

try
//from list
if (ifilelist.count>=1) then
   begin
   result:=ifilelist.value[0];
   ifilelist.del(0);
   end
//refresh list every minute unless trigger earlier
else if (ms64>=ifilelistref) then
   begin
   ifilelistref:=add64(ms64, (60*1000) );

   io__filelist(ifilelist,false,ifolder,'*.eml','');

   if (ifilelist.count>=1) then
      begin
      result:=ifilelist.value[0];
      ifilelist.del(0);
      end;
   end;
except;end;
end;

function tmailsender.msg__notdelivered(xerrmsg:string;xattachOriginalMessage:boolean):boolean;
var
   e,xsubject:string;
   xmsgsubject:tstr8;
begin
//defaults
result     :=false;
xmsgsubject:=nil;

try
//init
ivars.clear;
str__clear(@itemp);
xsubject:=utf8__toplaintext7bitb('Mail Undelivered');
xmsgsubject:=str__new8;

//get
if xattachOriginalMessage then
   begin
   ivars.s['file.name1']:='undelivered.eml';
   ivars.s['file.data1']:=idata.text;
   end;

//extract original message's subject line and inject into error message
mail__findfield2(@idata,'subject:',true,@xmsgsubject);
if (xmsgsubject.count>=1) then xerrmsg:=xmsgsubject.text+rcode+rcode+xerrmsg;

//make message
case xattachOriginalMessage of
true:mail__makemsg2(@itemp,osenderdomain,ouseragent,'',ifrom,ito,'','',xsubject,utf8__toplaintext7bitb(xerrmsg),date__now,ivars,e);
else mail__makemsg2(@itemp,osenderdomain,ouseragent,'',ifrom,ito,'','',xsubject,utf8__toplaintext7bitb(xerrmsg),date__now,nil,e);
end;//case

//store message in inbox
mail__writemsg(@itemp,xsubject,ifastfolder__inbox);
except;end;
//free
str__free(@xmsgsubject);
//clear
str__clear(@itemp);
ivars.clear;
end;

function tmailsender.msg__clear:boolean;
begin
result:=true;
str__clear(@idata);
str__clear(@iline);
isendlist.clear;
iusername:='';
idomain  :='';
ito      :='';
ifrom    :='';
ifilename:='';
end;

function tmailsender.msg__found:boolean;
label
   redo,skipend;
var
   xpos:longint;
   xdata,n,n3,n4,n5,xfilename,e:string;
   xwithin,xonceFROM:boolean;
   a:tstr8;

   function xlinevalue(const nlen:string):string;
   begin
   result:=strcopy1(iline.text,low__len32(nlen)+1,iline.len32);
   end;

   procedure madd(const xcmd,xdata:string);
   label
      skipend;
   var
      xstyle,z,v:string;
      lp,p:longint;
   begin
   //check
   if (xdata='') then exit;

   //init
   str__clear(@a);

   //range
   xstyle:=strlow(strcopy1(xcmd,1,2));                                  //from
   if (xstyle<>'to') and (xstyle<>'cc') and (xstyle<>'bc') and (xstyle<>'fr') then xstyle:='to';

   //check -> do FROM only once
   if (xstyle='fr') and (not xonceFROM) then exit;

   //filter
   v:=mail__filteraddresses(xdata,true,false)+', ';

   //get - extract all email addresses (addresses only)
   lp   :=1;
   for p:=1 to low__len32(v) do if (v[p-1+stroffset]=',') or (v[p-1+stroffset]=#32) then
      begin
      z :=stripwhitespace_lt(strcopy1(v,lp,p-lp));
      lp:=p+1;

      if (z<>'') then
         begin
         //to, cc, bcc and from -> sendlist
         str__sadd(@a,'[0/'+xstyle+']'+z+#10);//0=not sent, 1=sent OK, 2=send failed

         //one instance of from only
         if (xstyle='fr') then
            begin
            xonceFROM:=false;//mark as done
            break;
            end;

         end;

      end;//p

   //set
   isendlist.text:=isendlist.text+a.text;

   skipend:
   end;
begin
//defaults
result     :=false;
xonceFROM  :=true;
a          :=nil;

//time delay check
if (istartref>ms64) then exit;

try
//init
msg__clear;
a:=str__new8;

//no folder
if (ifolder='') then
   begin
   istartref:=add64(ms64,30000);//check back in 30sec
   goto skipend;
   end;

//no file (email as an ".eml" file)
xfilename:=msg__nextfileinqueue;
if (xfilename='') then
   begin
   istartref:=add64(ms64,30000);//check back in 30sec
   goto skipend;
   end;

//load sendlist file
isendlist.text:=io__fromfilestrb(ifolder+xfilename+'.txt',e);

//file not found -> stop
if not io__fromfile(ifolder+xfilename,@idata,e) then
   begin
   istartref:=add64(ms64,30000);//check back in 30sec
   if msg__clear then goto skipend;
   end;

//init
ifilename:=xfilename;

//auto-generate "sendlist" if none-exists by reading through email contents
if (isendlist.count<=0) then
   begin
   xwithin:=false;
   xdata  :='';
   xpos   :=0;

   while low__nextline0(idata,iline,xpos) do
   begin
redo:
   if not xwithin then
      begin
      n :='';//not set
      n5:=strlow(iline.str1[1,5]);
      n3:=strcopy1(n5,1,3);
      n4:=strcopy1(n5,1,4);

      if (n3='to:') then
        begin
        n      :=n3;
        xwithin:=true;
        xdata  :=xlinevalue(n);
        end
      else if (n3='cc:') then
        begin
        n      :=n3;
        xwithin:=true;
        xdata  :=xlinevalue(n);
        end
      else if (n4='bcc:') then
        begin
        n      :=n4;
        xwithin:=true;
        xdata  :=xlinevalue(n);
        end
      else if (n5='from:') then
        begin
        n      :=n5;
        xwithin:=true;
        xdata  :=xlinevalue(n);
        end;
      end

   else if xwithin then
      begin
      //line wraps -> add this line to previous data
      if (iline.str1[1,1]=#32) then xdata:=xdata+iline.text
      //line stops
      else
         begin
         madd(n,xdata);
         xdata  :='';
         xwithin:=false;

         //next to still check the current line
         goto redo;
         end;
      end;

   //stop on first blank line
   if (iline.len=0) then break;
   end;//loop

   //remove duplicates
   isendlist.text:=low__remdup(isendlist.text);

   //save
   io__tofilestr(ifolder+xfilename+'.txt',isendlist.text,e);
   end;

//ready
result:=true;
skipend:
except;end;
//free
str__free(@a);
end;

function tmailsender.msg__sendlist_havenext:boolean;
var
   p:longint;
   dn,dv,v:string;

   function xval:string;
   begin
   result:=stripwhitespace_lt(strcopy1(isendlist.items[p]^,7,low__len32(isendlist.items[p]^)));
   end;
begin
//defaults
result    :=false;
ito       :='';
iusername :='';
idomain   :='';

//find
for p:=0 to (isendlist.count-1) do if (isendlist.items[p]^<>'') and (isendlist.items[p]^[stroffset]='[') then
   begin
   v:=strcopy1(isendlist.items[p]^,1,6);

   //.set once during entire message transmission
   if (ifrom='') and strmatch(v,'[0/fr]') then ifrom:=xval;

   //.address
   if (not result) and ( strmatch(v,'[0/to]') or strmatch(v,'[0/cc]') or strmatch(v,'[0/bc]') ) and low__splitstr(strcopy1(isendlist.items[p]^,7,low__len32(isendlist.items[p]^)),ssAt,dn,dv) and (dn<>'') and (dv<>'') then
      begin
      result    :=true;
      ito       :=dn+'@'+dv;
      iusername :=dn;
      idomain   :=dv;
      end;

   //done
   if result and (ifrom<>'') then break;
   end;//p

end;

function tmailsender.msg__sendlist_markdone(xsentOK:boolean):boolean;
var
   p:longint;
   e,v:string;
begin
//defaults
result:=false;

//find
for p:=0 to (isendlist.count-1) do if (isendlist.items[p]^<>'') and (isendlist.items[p]^[stroffset]='[') then
   begin
   v:=strcopy1(isendlist.items[p]^,1,6);

   if strmatch(v,'[0/to]') or strmatch(v,'[0/cc]') or strmatch(v,'[0/bc]') then
      begin
      //adjust list
      if xsentOK then isendlist.items[p]^[stroffset+1]:='1' else isendlist.items[p]^[stroffset+1]:='2';//0=not sent yet, 1=sent OK, 2=send failed

      //save list
      io__tofilestr(ifolder+ifilename+'.txt',isendlist.text,e);

      //done
      result:=true;
      break;
      end;

   end;//p

end;

procedure tmailsender.xtimer;
label
   redo,skipend;
var
   str1:string;

   function xmaildomain:string;
   begin
   result:=strdefb(osenderdomain,'localhost');
   end;

   function xtimedout_sockclosed:boolean;
   begin
   result:=isockclosed or xtimedout;
   end;

   function xdomainisipv4_or_localhost(var x:string):boolean;//07apr2025
   var
      int1:longint;
   begin
   if strmatch(x,'localhost') then
      begin
      result:=true;
      x:='127.0.0.1';
      end
   else result:=( net__strip4(x,int1) and strmatch(x, net__ip4str(int1)) );
   end;

   function xerrorinfo(const x:string):boolean;
   begin
   result:=true;//pass-thru
   ierrorinfo:=x;
   end;

   function xerrorcode(xmarker:longint):boolean;
   begin
   result:=xerrorinfo('['+k64(xmarker)+'] error code ('+mail__pulledfullcode+')');
   end;
begin
//check
if      idisable   then exit
else if itimerbusy then exit
else                    itimerbusy:=true;


try
redo:

//hard flow control ------------------------------------------------------------

if iflow.idle then
   begin
   //scan for next email message in the queue to send
   if msg__found and iflow.start then goto skipend;
//   msg__found;

//xxxxxxxxxxxxxxxxxxxxxxxxxxx
   end


//started
else if iflow.started then
   begin
   if iflow.go32(fs__sendlist__haveaddr) then goto skipend;
   end

//halted
else if iflow.halted then
   begin
   //stopping
   if (ifolder<>'') and (ifilename<>'') then
      begin
      io__remfile(ifolder+ifilename);//remove the message from the queue
      io__remfile(ifolder+ifilename+'.txt');//remove the sendlist too
      end;

   //clear
   msg__clear;
   dns__pushclear;
   dns__pullclear;
   mail__pushclear;
   mail__pullclear;

   dns__rootlist.clear;
   dns__mxlist.clear;
   dns__alist.clear;

   xsockstop;
   end


//soft flow control ------------------------------------------------------------
else if iflow.at32(fs__sendlist__haveaddr) then
   begin
   ierrorinfo:='';

   //no more addresses to send the email to for this message
   if (not msg__sendlist_havenext) and iflow.halt then goto skipend;

   //lookup address domain in the MX cache
   if iflow.go32(fs__mxdns__usecache) then goto skipend;
   end


//------------------------------------------------------------------------------
//DNS MX record lookup ---------------------------------------------------------
//------------------------------------------------------------------------------
else if iflow.at32(fs__mxdns__usecache) then
   begin
   //close any open socket
   xsockstop;

   //.ip address by DNS lookup
   if xdomainisipv4_or_localhost(idomain) then dns__mxcache.add(idomain,idomain);

   //email address domain is in MX cache
   if dns__mxcache.exists2(idomain,str1) and dns__mxlist.fill(str1) and iflow.go32(fs__Adns__mxlist) then goto skipend;

   //dns connect -> lookup the email domain using the MX dns lookup
   if dns__rootlist.fill(strdefb(idnslist,ifallbacklist)) and iflow.go32(fs__mxdns__connect)  then goto skipend;
   end

//xxxxxxxxxxxxxxxxxxxxxx//**********************

else if iflow.at32(fs__mxdns__connect) then
   begin
   //no more root name servers
   if (not dns__rootlist.canpull) and dns__mxcache.dead(idomain) and iflow.go32(fs__mxdns__usecache) then goto skipend;

   //root name server invalid IPv4
   if not net__strip4(dns__rootlist.pullb,iip4) then goto skipend;

   //failed to connect to name server IPv4
   if not xsockstart(iip4,53) then goto skipend;

   //failed to create MX query for name server
   if dns__pushclear and (not dns__pushquery_MX(dns__pushbuf,0,idomain)) then goto skipend;

   //push query to name server
   if iflow.go32(fs__mxdns__pushquery) then goto skipend;
   end

else if iflow.at32(fs__mxdns__pushquery) then
   begin
   //query sent -> switch to read mode
   if dns__pushdone and dns__pullclear and iflow.go32(fs__mxdns__pullquery) then goto skipend;

   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__mxdns__connect) then goto skipend;
   end

else if iflow.at32(fs__mxdns__pullquery) then
   begin
   //query received
   if dns__pulldone then
      begin
      if dns__pullquery_MX(dns__pullbuf,true,str1) and dns__mxcache.add(idomain,str1) and iflow.go32(fs__mxdns__usecache) then goto skipend;
      if iflow.go32(fs__mxdns__connect) then goto skipend;
      end;

   //connection failure
   if (not dns__pull) and (not dns__pulldone) and xtimedout_sockclosed and iflow.go32(fs__mxdns__connect) then goto skipend;
   end


//------------------------------------------------------------------------------
//DNS A record lookup ----------------------------------------------------------
//------------------------------------------------------------------------------
else if iflow.at32(fs__Adns__mxlist) then
   begin
   //get next mail domain from MX list
   if (not dns__mxlist.pull(imaildomain)) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;

   //use mail domain
   if iflow.go32(fs__Adns__usecache) then goto skipend;
   end

else if iflow.at32(fs__Adns__usecache) then
   begin
   //close any open socket
   xsockstop;

   //.ip address by DNS lookup
   if xdomainisipv4_or_localhost(imaildomain) then dns__acache.add(imaildomain,imaildomain);

   //find mail domain in dns A cache for it's IPv4 address(s) and attempt to send mail to one of those ip addresses
   if dns__acache.exists2(imaildomain,str1) and dns__alist.fill(str1) and iflow.go32(fs__sendmail__iplist) then goto skipend;

   //dns connect -> lookup the mail domain using the A dns lookup
   if dns__rootlist.fill(strdefb(idnslist,ifallbacklist)) and iflow.go32(fs__Adns__connect)  then goto skipend;
   end

else if iflow.at32(fs__Adns__connect) then
   begin
   //no more root name servers
   if (not dns__rootlist.canpull) and dns__acache.dead(imaildomain) and iflow.go32(fs__Adns__mxlist) then goto skipend;

   //root name server invalid IPv4
   if not net__strip4(dns__rootlist.pullb,iip4) then goto skipend;

   //failed to connect to name server IPv4
   if not xsockstart(iip4,53) then goto skipend;

   //failed to create A query for name server
   if dns__pushclear and (not dns__pushquery_A(dns__pushbuf,0,imaildomain)) then goto skipend;

   //push query to name server
   if iflow.go32(fs__Adns__pushquery) then goto skipend;
   end

else if iflow.at32(fs__Adns__pushquery) then
   begin
   //query sent -> switch to read mode
   if dns__pushdone and dns__pullclear and iflow.go32(fs__Adns__pullquery) then goto skipend;

   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__Adns__connect) then goto skipend;
   end

else if iflow.at32(fs__Adns__pullquery) then
   begin
   //query received
   if dns__pulldone then
      begin
      if dns__pullquery_A(dns__pullbuf,true,str1) and dns__acache.add(imaildomain,str1) and iflow.go32(fs__Adns__usecache) then goto skipend;
      if iflow.go32(fs__Adns__connect) then goto skipend;
      end;

   //connection failure
   if (not dns__pull) and (not dns__pulldone) and xtimedout_sockclosed and iflow.go32(fs__Adns__connect) then goto skipend;
   end


//------------------------------------------------------------------------------
//Send mail --------------------------------------------------------------------
//------------------------------------------------------------------------------
else if iflow.at32(fs__sendmail__iplist) then
   begin
   //close any open socket
   xsockstop;

   //no more IPv4 addresses for the mail domain -> fetch next mail domain
   if (not dns__alist.canpull) and iflow.go32(fs__Adns__mxlist) then goto skipend;

   //fetch next IPv4 for mail domain -> if invalid get next one
   if not net__strip4(dns__alist.pullb,iip4) then goto skipend;

   //failed to connect to mail server IPv4
   if not xsockstart(iip4,25) then goto skipend;

   //clear buffers
   mail__pullclear;
   mail__pushclear;

   //send mail to IPv4
   if iflow.go32(fs__sendmail__pull_welcome) then goto skipend;
   end

else if iflow.at32(fs__sendmail__pull_welcome) then
   begin
   //connection failed -> try next IPv4 in list
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   //read in data
   if mail__pullcode then
      begin
      //connected to mail server
      if (mail__pulledcode=220) then
         begin
         mail__pushadd('helo'+#32+xmaildomain+rcode);
         if iflow.go32(fs__sendmail__push_helo) then goto skipend;
         end
      else if xerrorcode(1) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;
      end;
   end

else if iflow.at32(fs__sendmail__push_helo) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pushdone and mail__pullclear and iflow.go32(fs__sendmail__pull_helo) then goto skipend;
   end

else if iflow.at32(fs__sendmail__pull_helo) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pullcode then
      begin
      if (mail__pulledcode=250) then
         begin
         mail__pushclear;
         mail__pushadd('mail from:<'+ifrom+'>'+rcode);//email MUST be enclosed in angle brackets per gmail - 06apr2025
         if iflow.go32(fs__sendmail__push_mailfrom) then goto skipend;
         end
      else if xerrorcode(2) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;
      end;
   end

else if iflow.at32(fs__sendmail__push_mailfrom) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pushdone and mail__pullclear and iflow.go32(fs__sendmail__pull_mailfrom)  then goto skipend;
   end

else if iflow.at32(fs__sendmail__pull_mailfrom) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pullcode then
      begin
      if (mail__pulledcode=250) then
         begin
         mail__pushclear;
         mail__pushadd('rcpt to:<'+ito+'>'+rcode);//email MUST be enclosed in angle brackets per gmail - 06apr2025
         if iflow.go32(fs__sendmail__push_rcptto) then goto skipend;
         end
      else if xerrorcode(3) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;
      end;
   end

else if iflow.at32(fs__sendmail__push_rcptto) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pushdone and mail__pullclear and iflow.go32(fs__sendmail__pull_rcptto)  then goto skipend;
   end

else if iflow.at32(fs__sendmail__pull_rcptto) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pullcode then
      begin
      if (mail__pulledcode=250) then
         begin
         mail__pushclear;
         mail__pushadd('data'+rcode);//start message transfer
         if iflow.go32(fs__sendmail__push_data) then goto skipend;
         end
      else if xerrorcode(4) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;
      end;
   end

else if iflow.at32(fs__sendmail__push_data) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pushdone and mail__pullclear and iflow.go32(fs__sendmail__pull_data)  then goto skipend;
   end

else if iflow.at32(fs__sendmail__pull_data) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pullcode then
      begin
      if (mail__pulledcode=354) then
         begin
         mail__pushclear;
         mail__pushadd(idata.text+rcode+'.'+rcode);
         if iflow.go32(fs__sendmail__push_message) then goto skipend;
         end
      else if xerrorcode(5) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;
      end;
   end

else if iflow.at32(fs__sendmail__push_message) then
   begin
   //connection failure
   if xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pushdone and mail__pullclear and iflow.go32(fs__sendmail__pull_message) then goto skipend;
   end

else if iflow.at32(fs__sendmail__pull_message) then
   begin
   //connection failure -> linger for 10sec to catch any possible slow reply for a fast/unexpected connection close
   if (not mail__pull) and (not mail__pulldone) and mail__linger_timedout(10000) and xtimedout_sockclosed and iflow.go32(fs__sendmail__iplist) then goto skipend;

   if mail__pullcode then
      begin
      if      (mail__pulledcode=250) and iflow.go32(fs__sendmail__doneaddress)         then goto skipend
      else if xerrorcode(6) and iflow.go32(fs__sendmail__addressfailed) then goto skipend;
      end;
   end

else if iflow.at32(fs__sendmail__doneaddress) then
   begin
   //close
   xsockstop;

   //mark sendlist address as sent
   msg__sendlist_markdone(true);

   //loop back to beginning for the address of the next recipient
   if iflow.go32(fs__sendlist__haveaddr) then goto skipend;
   end

else if iflow.at32(fs__sendmail__addressfailed) then//recipint addresse failed -> keep going with the others addresses
   begin
   //close
   xsockstop;

   //mark sendlist address as failed
   msg__sendlist_markdone(false);

   //put a message in the Inbox stating that this message recipient's copy has failed to be sent
   msg__notdelivered('The email was unable to be delivered to "'+ito+'"'+insstr(' with '+ierrorinfo,(ierrorinfo<>'')),false);

   //loop back to beginning for the address of the next recipient
   if iflow.go32(fs__sendlist__haveaddr) then goto skipend;
   end


//.flow stage not found
else
   begin
   //debug only: if showbasic2('Internal Error: flow stage not found: "'+k64(iflow.stagename32)+'"',1) and iflow.halt then goto skipend;

   if iflow.halt then goto skipend;
   end;


skipend:
except;end;
//free
itimerbusy:=false;
end;

procedure tmailsender.xsockstop;
var
   x:tsocket;
begin
if net__makesession and (isocket<>invalid_socket) then
   begin
   //clear var
   x:=isocket;
   isocket:=invalid_socket;

   //close
   net____closesocket(x);
   end;
end;

function tmailsender.xsockstart(xip4,xport:longint):boolean;
label
   skipend;
var
   a:tsockaddrin;
begin
//defaults
result:=false;

//check
if not net__makesession then exit;

try
//close
xsockstop;

//init
isockconnected :=false;//not connected
isockclosed    :=false;//not closed
iport          :=xport;//info purposes

//check
if (xip4=0) then goto skipend;

//moretime
if (xport=53) then dns__moretime else mail__moretime;

//open
isocket:=net____makesocket(PF_INET,SOCK_STREAM,IPPROTO_TCP);
if (isocket=invalid_socket) then goto skipend;

//non-blocking (program runs while waiting for data) - requires a WINDOW handle to send messages to wndproc event (even though proc doesn't need to do anything other than return "0" = no error) - 05oct2021
//xarg:=1;//enabled non-blocking sockets
//net____ioctlsocket(isocket,FIONBIO,xarg);//this keeps the connection OPEN if we're slow to response, e.g. DNS - 06apr2025

//style
net____wsaasyncselect(isocket,app__wproc.window,wm_onmessage_netRAW,longint(FD_READ or FD_WRITE or FD_CONNECT or FD_CLOSE));

//connect
low__cls(@a,sizeof(a));
a.sin_family       :=PF_INET;
a.sin_addr.s_addr  :=xip4;
a.sin_port         :=low__rword(xport);//Mail (25) port
if (socket_error=net____connect(isocket,a,sizeof(a))) and (net____WSAGetLastError<>WSAEWOULDBLOCK) then goto skipend;

//successful
result:=true;
skipend:
except;end;
//close on error
if not result then xsockstop;
end;

procedure tmailsender.setdnslist(const x:string);
begin
idnslist:=net__cleanlistIP4(x);
end;

procedure tmailsender.onmessage(m,w,l:longint);
var
   a:tint4;
begin
//check
if (w<>isocket) then exit;

//get
imustboost:=true;
a.val     :=L;

case a.bytes[0] of
fd_connect:isockconnected:=true;
fd_close  :isockclosed:=true;
end;//case

end;

//dns io procs -----------------------------------------------------------------
function tmailsender.dns__moretime:boolean;
begin
result  :=true;//pass-thru
itimeout:=add64(ms64,45000);//45 seconds
//itimeout:=add64(ms64,10000);//10 seconds - debug only
end;

function tmailsender.dns__pushclear:boolean;
begin
result:=true;
dns__pushbuf.clear;
dns__moretime;
end;

function tmailsender.dns__pushdone:boolean;
begin
dns__push;
result:=(dns__pushbuf.len<=0);
end;

function tmailsender.dns__push:boolean;
var
   xsentlen:longint;
begin
if      (dns__pushbuf.len<=0) then result:=true
else if net____send2(isocket,dns__pushbuf.core^,dns__pushbuf.len32,0,xsentlen) then
   begin
   result:=true;
   dns__pushbuf.del3(0,xsentlen);
   dns__moretime;
   end
else result:=false;
end;

function tmailsender.dns__pullclear:boolean;
begin
result:=true;
dns__pullbuf.clear;
dns__pulllen:=-1;//pull len -> not set
end;

function tmailsender.dns__pull:boolean;
var
   xlen:longint;
begin
xlen   :=net____recv(isocket,ibuffer,sizeof(ibuffer),0);
result :=(xlen>=1);

if result then
   begin
   dns__pullbuf.addrec(@ibuffer,xlen);
   if (dns__pulllen<0) and (dns__pullbuf.len>=2) then dns__pulllen:=2+dns__pullbuf.wrd2R[0];//read 2byte header to know how much data to expect
   dns__moretime;
   end;
end;

function tmailsender.dns__pulldone:boolean;
begin
dns__pull;
result:=(dns__pulllen>=0) and (dns__pullbuf.len>=dns__pulllen);
end;

//mail io procs ----------------------------------------------------------------
function tmailsender.mail__moretime:boolean;
begin
result  :=true;//pass-thru
itimeout:=add64(ms64,3*60*1000);//3 minutes
end;

function tmailsender.mail__linger_timedout(xms:longint):boolean;
begin
result:=(ms64 > add64(ilinger,xms) );
end;

function tmailsender.mail__pushclear:boolean;
begin
result:=true;
mail__buf.clear;
end;

function tmailsender.mail__pullclear:boolean;
begin
result:=true;
mail__buf.clear;
end;

function tmailsender.mail__pushdone:boolean;
begin
mail__push;
result:=(mail__buf.len<=0);
end;

function tmailsender.mail__pushadd(const x:string):boolean;
begin
result:=false;
try
mail__buf.text:=x;
result:=true;
except;end;
end;

function tmailsender.mail__push:boolean;
var
   xsentlen:longint;
begin
if      (mail__buf.len<=0) then result:=true
else if net____send2(isocket,mail__buf.core^,mail__buf.len32,0,xsentlen) then
   begin
   result :=true;
   ilinger:=ms64;
   mail__buf.del3(0,xsentlen);
   mail__moretime;
   end
else result:=false;
end;

function tmailsender.mail__pull:boolean;
var
   xlen:longint;
begin
xlen:=net____recv(isocket,ibuffer,sizeof(ibuffer),0);
result:=(xlen>=1);
if result then
   begin
   ilinger:=ms64;
   mail__buf.addrec(@ibuffer,xlen);
   mail__moretime;
   end;
end;

function tmailsender.mail__pulldone:boolean;
var
   p:longint;
begin
result:=false;
mail__pull;
for p:=0 to (mail__buf.count32-1) do if (mail__buf.pbytes[p]=10) then result:=true;
end;

function tmailsender.mail__pullcode:boolean;
var
   xpos:longint;
begin
result:=false;
mail__pulledcode:=0;
mail__pulledfullcode:='';

if mail__pulldone then
   begin

   //read each line until we find the terminal status code "3 digit code + [space]"
   xpos:=0;
   while str__nextline0(@mail__buf,@iline,xpos) do
   begin
   case iline.len32 of
   3:mail__pulledcode:=strint32(iline.text);
   4..maxint:if (iline.bytes[3]=ssSpace) then
      begin
      mail__pulledcode:=strint32(iline.str1[1,3]);
      break;
      end;
   end;//case
   end;//loop

   //full code text
   mail__pulledfullcode:=mail__buf.text;

   //successful
   result:=true;
   end;
end;









//app procs --------------------------------------------------------------------
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

//.image format support checkers
need_png;
need_gif;
need_bmp;
need_tga;
need_jpg;

//vars
iloaddate                       :=date__now;
isessiontimeout                 :=mult64(2000,86400);//2 days
icookietimeout                  :=mult64(1000,60*60);//retransmit ative Admin session cookie every hour
iidletimeout                    :=mult64(1000,120);//2 minutes
ibuf2                           :=str__new9;
ivars                           :=tfastvars.create;
imail_sender                    :=tmailsender.create;
imail_sender.ouseragent         :=app__info('name');
inewvisitor                     :=tnewvisitor.create;
imustmakepngs                   :=false;
ihitmustsave                    :=false;
ihit                            :=tfastvars.create;//persists - does not reset
ihitref                         :=tfastvars.create;//resyncs every 24hr
ibytes                          :=tfastvars.create;//reset every 24hr
ihitpng                         :=tfastvars.create;

imap                            :=tfastvars.create;
idom                            :=tfastvars.create;
idominfo                        :=tfastvars.create;
imime                           :=tfastvars.create;
imime_fallback                  :=tfastvars.create;
iredirect                       :=tfastvars.create;

igmtstr                         :=low__gmt(date__now);
ibubbles_png                    :=str__new9;
ibubbles_ico_32px               :=str__new9;

str__addrec( @ibubbles_ico_32px ,@bubbles_ico_32px ,sizeof(bubbles_ico_32px) );

ichunksize                      :=high(ibuffer)+1;

//.127.0.0.1
with i127_0_0_1 do
begin

b0                              :=127;
b1                              :=0;
b2                              :=0;
b3                              :=1;

end;


//admin
iadminkey                       :='';

for p:=0 to high(isessiontime) do
begin

isessiontime[p]                 :=0;
isessioncookietime[p]           :=0;
isessionname[p]                 :='';
isessioncookie[p]               :='';
isessionua[p]                   :='';

end;//p

//ram cache
ireload_domindex                :=0;
ireload_rambytes                :=0;
ireload_ramlimit                :=0;
irambytes                       :=0;
iramcount                       :=0;//number of RAM slots used both FULL and EMPTY slots
iramfilescached                 :=0;
iramfilecount                   :=0;
iramdate                        :=date__now;
iramgmt                         :='';
iramid                          :=1;
inref1                          :=new__int;
inref2                          :=new__int;
iname                           :=new__str;
idata                           :=tdynamicstr9.create;
isize                           :=new__comp;
idate                           :=new__date;
imode                           :=new__int;
idomindex                       :=new__int;
ihave                           :=new__byte;

idaily_bandwidth                :=0;
idaily_bandwidth_quota          :=0;
idaily_bandwidth_quota_bytes    :=0;
idaily_bandwidth_exceeded       :=false;

idaily_newvisitors              :=0;//persistent -> IP tracking does not reset
idaily_visitors                 :=0;
idaily_requests                 :=0;//counts all request types - 21feb2025
idaily_hits                     :=0;//counts only htm/html requests
idaily_email                    :=0;//counts number of emails received
idaily_contact                  :=0;//counts number of contact form submissions received
idaily_jobs                     :=0;//counts number of jobs performed by built-in tools

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
app__breg('subscribe.notice',true);//09oct2026
app__breg('subscribe.each.notice',true);//09oct2026
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

//.subscribe form
app__breg('subscribe.question',false);
app__breg('subscribe.allow',false);

//.mail
app__breg('mail.allow',false);
app__sreg('mail.domain','');
app__sreg('mail.mask','');
app__sreg('mail.fromaddress','');//03mar2025
app__sreg('mail.dns','');//05mar2025
app__ireg('mail.sizelimit',20,1,50);//1..50Mb

//.ipsec
app__ireg('scanfor',24*60,0,max32);//1 day
app__ireg('banfor',7*24*60,0,max32);//1 week
app__ireg('simconnlimit',30,0,max32);//30 connections
app__ireg('postlimit',20,0,max32);//20 submissions
app__ireg('postlimit2',100,0,max32);//100 submissions - server tools, e.g. Icon Maker
app__ireg('badlimit',20,0,max32);//20 attempts
app__ireg('hitlimit',100*1000,0,max32);//100K hits
app__ireg('badreqlimit',0,0,max32);//0=off
app__ireg('badmaillimit',0,0,max32);//0=off
app__creg('datalimit',5000,0,max64);//5Gb
app__sreg('notthislink','');//07mar2025
app__sreg('ua.mask','');//09aug2025
app__sreg('ip.mask','');//09aug2025


//.start built-in server tools
tools__start;

//read settings
ipowerlevel                     :=app__ival('powerlevel');
icache                          :=app__bval('cache');
ilivestats                      :=app__bval('livestats');
irawlogs                        :=app__bval('rawlogs');
iconsolerate                    :=app__ival('consolerate');
icsp                            :=app__bval('csp');
inorefdown                      :=app__bval('norefdown');
ishutidle                       :=app__bval('shutidle');
ialongsideexe                   :=app__bval('alongsideexe');
ireverseproxy                   :=app__bval('reverseproxy');
isummarynotice                  :=app__bval('summary.notice');
isubscribenotice                :=app__bval('subscribe.notice');//09oct2026
isubscribeEachNotice            :=app__bval('subscribe.each.notice');//09oct2026
iquotanotice                    :=app__bval('quota.notice');
ireloadnotice                   :=app__bval('reload.notice');
iconnlimit                      :=app__ival('connlimit');
iramlimit                       :=app__ival('ramlimit');//in mb
iport                           :=app__ival('port');
iadminkey                       :=app__sval('adminkey');
ithreshold                      :=app__cval('threshold');

xsetdaily_bandwidth_quota( app__cval('daily.bandwidth.quota') );

//.contact form
icontact_question               :=app__bval('contact.question');
icontact_allow                  :=app__bval('contact.allow');
icontact_off                    :=app__sval('contact.off');
icontact_ok                     :=app__sval('contact.ok');
icontact_fail                   :=app__sval('contact.fail');

//.subscribe forms
isubscribe_question             :=app__bval('subscribe.question');
isubscribe_allow                :=app__bval('subscribe.allow');

//.Spam Guard support - 09oct2026
ispamGuard_index                :=0;

low__cls( @ispamGuard_answer ,sizeof(ispamGuard_answer) );

//.mail
imail_allow                     :=app__bval('mail.allow');
imail_domain                    :=app__sval('mail.domain');
imail_mask                      :=app__sval('mail.mask');
imail_sender.osenderdomain      :=imail_domain;
imail_sizelimit                 :=app__ival('mail.sizelimit');
imail_fromaddress               :=mail__extractaddress(app__sval('mail.fromaddress'));
imail_sender.dnslist            :=text__fromoneline(app__sval('mail.dns'),';');

//.ipsec
ipsec__setvals( app__ival('scanfor') ,app__ival('banfor') ,app__ival('simconnlimit') ,app__ival('postlimit') ,app__ival('postlimit2') ,app__ival('badlimit') ,app__ival('hitlimit') ,app__ival('badreqlimit') ,app__ival('badmaillimit') ,mult64(app__cval('datalimit'),1024000) );

inotthislink                    :=stripwhitespace_lt(app__sval('notthislink'));//07apr2025
iua_mask                        :=app__sval('ua.mask');//09aug2025
iip_mask                        :=app__sval('ip.mask');//09aug2025

//.load hit info - 17jun2025: fxied
xload_counter(ihit,app__settingsfile('hits.ini'));
xload_counter(ihitref,app__settingsfile('hitsref.ini'));
xload_counter(ibytes,app__settingsfile('bytes.ini'));

//.load map info (domain mapping)
imap.fromfile(app__settingsfile('map.ini'),e);

//.load mime type info
xmime_fallback;
imime.fromfile(app__settingsfile('mime.ini'),e);

//.load redirect info
iredirect.fromfile(app__settingsfile('redirect.ini'),e);

//.create http server record
net__makerec( ihttpserver );
net__makerec( imailserver );

//.command line parameters
if not cmdline__mustclose then
   begin

   app__halt;
   
   exit;

   end;

//.run all STARTED tool modules -> this loads the modules and their support vars into RAM for running and calls getvals
tools__run;

//.help - for server only, not required command prompt
ihelpdata                       :=xmakehelp(false);

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

procedure app__destroy;
begin
try

//save
//.save app settings
app__syncandsavesettings;

//.imail_sender
freeobj(@imail_sender);

//free
//.vars
free__7(@ihit,@ihitref,@ibytes,@imap,@idom,@idominfo,@imime);
free__4(@imime_fallback,@iredirect,@ihitpng,@ivars);
str__free(@ibuf2);
str__free(@ibubbles_png);
freeobj(@ibubbles_ico_32px);
freeobj(@inewvisitor);

//.ram cache
free__7(@inref1,@inref2,@iname,@idata,@isize,@idate,@imode);
free__2(@ihave,@idomindex);

except;end;
end;

function app__syncandsavesettings:boolean;
var
   e                  :string;

begin

//defaults
result                :=false;

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
app__bvalset('subscribe.notice',isubscribenotice);
app__bvalset('subscribe.each.notice',isubscribeeachnotice);
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

//.subscribe forms
app__bvalset('subscribe.question',isubscribe_question);
app__bvalset('subscribe.allow',isubscribe_allow);

//.mail
app__bvalset('mail.allow',imail_allow);
app__svalset('mail.domain',imail_domain);
app__svalset('mail.mask',imail_mask);//19jun2025
app__ivalset('mail.sizelimit',imail_sizelimit);
app__svalset('mail.fromaddress',imail_fromaddress);
app__svalset('mail.dns', text__tooneline(imail_sender.dnslist,';') );

//.ipsec
app__ivalset('scanfor',ipsec__scanfor);
app__ivalset('banfor',ipsec__banfor);
app__ivalset('simconnlimit',ipsec__connlimit);
app__ivalset('postlimit',ipsec__postlimit);
app__ivalset('postlimit2',ipsec__postlimit2);
app__ivalset('badlimit',ipsec__badlimit);
app__ivalset('hitlimit',ipsec__hitlimit);
app__ivalset('badreqlimit',ipsec__badreqlimit);
app__ivalset('badmaillimit',ipsec__badmaillimit);
app__cvalset('datalimit',div64(ipsec__datalimit,1024000));
app__svalset('notthislink',inotthislink);//07apr2025
app__svalset('ua.mask',iua_mask);//09aug2025
app__svalset('ip.mask',iip_mask);//09aug2025

//.all tool modules vals
tools__setvals;

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
result                :=true;

except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin

result                :=tnetbasic.create;

end;

function app__onmessage(m,w,l:longint):longint;
var
   a                  :tint4;//fixed 19feb2024
   x                  :pnetwork;

begin

//defaults
result                :=0;

if (m=wm_onmessage_net) then
   begin

   imustboost         :=true;

   //get
   a.val              :=l;

   case a.bytes[0] of

   fd_connect:;

   fd_close:begin

      case net__findbysock(x,w) of
      true :xclose_connection(x);
      false:net____closesocket(w);
      end;//case

      end;

   fd_accept:xaccept_connection_autotype(w);//08apr2024

   fd_read: if net__findbysock(x,w) then x.canread:=true;

   fd_write:if net__findbysock(x,w) then x.canwrite:=true;

   end;//case

   end

else if (m=wm_onmessage_netraw) then
   begin

   imail_sender.onmessage(m,w,l);//04apr2025

   end;

end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin

app__writeln('Bubbles online at port '+k64(iport)+'.  Live stats are off.');

end;

procedure app__onpaint(sw,sh:longint);
var
   p:longint;
   str1,n,v:string;

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
nv(0,'HTTP Port',intstr32(iport)+' ('+low__aorbstr('offline','online',net__socketgood(ihttpserver))+')' +insstr(' - Quota Reached',idaily_bandwidth_exceeded));
scn__down;
nv(0,'SMTP Port',intstr32(imailport)+' ('+low__aorbstr('offline','online',net__socketgood(imailserver))+')' +insstr(' - Quota Reached',idaily_bandwidth_exceeded)+#32+imail_sender.status);

scn__down;
nv(0,'RAM',low__mbauto(bytes__RAM,true)+'  ('+low__percentage64str(iramfilescached,iramfilecount,true)+' of files cached: '+k64(iramfilescached)+' / '+k64(iramfilecount)+')');
scn__down;
nv(0,'Memory Blocks',k64(track__val(satBlock))+' ('+low__kb(block64__size,true)+' per block)');

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


if tools__statusinfo('search',0,n,v) then
   begin
   scn__down;
   nv(0,n,v);
   if tools__statusinfo('search',1,n,v) then nv(1,n,v);
   if tools__statusinfo('search',2,n,v) then nv(2,n,v);
   end;


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

procedure xload_counter(var x:tfastvars;xfilename:string);//17jun2025
var//convert "name+value" pairs to "name+64bit number" paris -> tfastvars uses separate data channels for strings and numbers etc - 17jun2025
   e:string;
   p:longint;
begin
try
//check
if (x=nil) then exit;

//clear
x.clear;

//load
x.fromfile(xfilename,e);

//convert "value as string" to "value as 64bit number"
for p:=0 to (x.count-1) do x.c[ x.n[p] ]:=strint64(x.v[p]);

except;end;
end;

function xconn_limit:longint;//maximum number of records permitted
begin
result:=frcmax32(iconnlimit+2,net__limit);//+2 = http and smtp servers -> same network list
end;

function xconn_count:longint;//number of records in use
begin
result:=frcmax32(iconnlimit+2,net__count);//+2 = http and smtp servers -> same network list
end;

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
      igmtstr:=low__gmt(date__now);
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
   iconncount:=largest32(iconncount,xconncount);

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
            true:scn__writeln('HTTP Online at port '+intstr32(iport));
            false:scn__writeln('HTTP Failed to acquire port '+intstr32(iport));
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
            true:scn__writeln('SMTP Online at port '+intstr32(imailport));
            false:scn__writeln('SMTP Offline at port '+intstr32(imailport));
            end;//case
            end;
         end;
      end;

   //.remake domain based "hits.png" images
   if imustmakepngs then png__makeAll(false);

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

      ihitmustsave    :=false;

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
   int1               :=irequestrate0*60;

   if (int1>=irequestrate) then irequestrate:=int1 else irequestrate:=(irequestrate+int1) div 2;

   irequestrate0      :=0;

   //.connection count over 1sec
   iconncount_1sec    :=iconncount;
   iconncount         :=0;

   //reset
   msset(itimer1000,1000);

   end;

//0.1s
if msok(itimer100) then
   begin
   if (ilivestats<>scn__visible) then scn__setvisible(ilivestats);
   if scn__visible then scn__paint;

   //reset
   msset(itimer100,100);
   end;

//tool timers
tools__timers;

//mail sender
imail_sender.xtimer;//03apr2025

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

function cmdline__output(const xforcecmd:string):string;
begin

cmdline__mustclose2(xforcecmd,result);

end;

function cmdline__mustclose:boolean;
var
   str1     :string;
begin

result      :=cmdline__mustclose2( '' ,str1 );

end;

function cmdline__mustclose2(xforcecmd:string;var xoutput:string):boolean;
label
   redo,skipend;

const
   clist                        :array[0..17] of string=('password','connections','port','smtp','cachesize','filesize','quota','power','logs','live','install','uninstall','info','commands','run','help','rawhelp','howto');

var
   xout                         :tobject;
   p                            :longint32;
   nlen                         :longint32;
   int1                         :longint32;
   xpos                         :longint32;
   xappname                     :string;
   n                            :string;
   v                            :string;
   vreuse                       :string;
   vcomment                     :string;
   xforcecmdok                  :boolean;
   xrun                         :boolean;
   bol1                         :boolean;

   procedure xaddline(const x:string);
   begin

   case xforcecmdok of

   true:begin

      if (xout=nil) then xout:=str__new9;

      str__sadd(@xout,x+#10);

      end;

   false:app__writeln(x);

   end;//case

   end;

   procedure h(x:string);//heading (underlined)
   begin

   x        :='[ '+x+' ]';

   xaddline(x);
   xaddline(strcopy1('-----------------------------',1,low__len32(x)));

   end;

   procedure m(const x:string);//normal line
   begin

   xaddline(x);

   end;

   procedure e(const x:string);//example
   begin

   xaddline(#32+x);

   end;

   function xenabled(const x:boolean):string;
   begin

   result   :=low__aorbstr('Disabled','Enabled',x);

   end;

   function xinstalled(const x:boolean):string;
   begin

   result   :=low__aorbstr('Not Installed','Installed',x);

   end;

   function xpull:string;
   begin

   if (vreuse<>'') then
      begin

      result:=vreuse;
      vreuse:='';
      v     :='';

      end

   else begin

      case xforcecmdok of

      true:begin

         result       :=xforcecmd;//use once only
         xforcecmd    :='';

         end;

      false:result    :=low__param(xpos);

      end;//case

      inc(xpos);

      end;//if

   //legacy support
   if (strcopy1(result,1,1)='/') then
      begin

      result          :='--'+strcopy1(result,2,low__len32(result));

      end;

   end;

   procedure vcheck(const xdef:string);
   begin

   //get
   v                  :=xpull;
   vcomment           :='';

   //is the value a command
   if (strcopy1(v,1,1)='/') or (strcopy1(v,1,2)='--') then
      begin

      vreuse          :=v;
      v               :='';

      end;

   //use default value
   if (v='') and (xdef<>'') then
      begin

      vcomment        :=' (default used)';
      v               :=xdef;

      end;

   end;

   procedure xinforow(const n,v:string);
   const
      xwidth          ='.........................';

   begin

   xaddline( n + #32 + strcopy1(xwidth,1,low__len32(xwidth)-low__len32(n)) + #32 + v );

   end;

   procedure vok(const xmsg,xvalue:string;const xsavesettings:boolean);
   begin

   //save
   if xsavesettings then app__savesettings;

   //screen message
   if (xmsg<>'') then xinforow(xmsg,xvalue+vcomment);

   end;

   procedure xhelp(xname:string);
   var
      xbody           :string;
      p               :longint32;

      procedure e2(const x:string);//example
      begin

      e(xappname+' --'+xname+x);

      end;

      procedure e3(const x:string);//example
      begin

      e(xappname+insstr(' --',x<>'')+x);

      end;

      procedure xabout2(const xdes,usage0,xusage,xrange:string;const xexamples:boolean);//description
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

      procedure xabout(const xdes,xusage,xrange:string;const xexamples:boolean);//description
      begin

      xabout2(xdes,#32,xusage,xrange,xexamples);

      end;

   begin

   //init
   xname              :=strlow(xname);
   xbody              :='';

   //strip leading slash
   if      (strcopy1(xname,1,2)='--') then strdel1(xname,1,2)
   else if (strcopy1(xname,1,1)='/')  then strdel1(xname,1,1);//legacy support

   //body
   if (xname='filesize') then
      begin

      xabout(
       'Set the maximum file size threshold. All files at or below this size are loaded into the RAM cache. '+
       'Larger files are streamed from disk when requested. '+'Set to 0 (zero) to load any file size into cache.',
       '<size in bytes>','0..'+low__b(imaxcachesize*1024000,true)
       ,true);

      e2(' 123,500');
      e2(' 1024000');
      e2(' 333');
      e2('');
      m('');
      m('Example 1 loads files of 123.5 KB or less into cache.  The second 1 MB or less.  The third to 333 bytes or less. And the fourth defaults to 10 MB.');

      end

   else if (xname='cachesize') then
      begin

      xabout(
       'Set the maximum RAM Cache Size. The cache stores files for rapid access without disk lag. The cache expands upto this size to accomodate files. When the cache is full, or a file is too large, it''s left on disk and streamed out when requested.',
       '<size in MB (megabytes)>','10..'+k64(imaxcachesize)
       ,true);

      e2(' 50');
      e2(' 250');
      e2(' 1,500');
      e2('');
      m('');
      m('Example 1 sets RAM cache to use 50 MB. The second 250 MB.  The third to 1500 MB (1.5 GB). And the fourth defaults to 1200 MB (1.2 GB)');

      end

   else if (xname='quota') then
      begin

      xabout(
       'Set the daily bandwidth quota. If the combined upstream (client -> server) and downstream (server -> client) bandwidth exceeds the quota limit, all traffic in and out of Bubbles is '+'suspended until midnight.  At midnight, daily bandwidth quota tracking begins afresh.',
       '<size in MB (megabytes)>','0=Disabled (no limit), 10..N Mb'
       ,true);

      e2(' 250');
      e2(' 1,000');
      e2(' 3,000,000');
      e2('');
      m('');
      m('Example 1 sets the daily bandwidth quota to 250 Mb. The second to 1 Gb (1,000 Mb).  The third to 3 Tb (3,000,000 Mb). And the fourth defaults to 0, which disables quota tracking and allows any amount of bandwidth.');

      end

   else if (xname='info') then
      begin

      xabout(
       'Display basic settings in a easy to view summary.',
       '!',''
       ,false);

      end

   else if (xname='run') then
      begin

      xabout(
       'Runs the server.',
       '!',''
       ,true);

      e3('port 80 --password abcde --run');
      e3('port 80 --password abcde --run --cachesize 1100');
      e3('run');
      e3('');
      m('');
      m('Example 1 sets port to 80, password to abcde, and then runs the server. The second does the same, but all commands after --run are ignored, --cachesize is never executed. Both 1 and 2 are examples of command stacking. Examples 3 and 4 run the server.');

      end

   else if (xname='port') then
      begin

      xabout(
       'Set the broadcast port for the HTTP server.  Default is port '+intstr32(idefaultport)+'.',
       '<a number>','2..'+k64(maxport)
       ,true);

      e2(' 80');
      e2(' 1080');
      e2(' 2000');
      m('');
      m('Example 1 sets the port to 80, the standard port for http (insecure) web servers. The second sets it to broadcast on port 1080. And the third port 2000. Typically ports above 1024 require no special administration privileges.');

      end

   else if (xname='connections') then
      begin

      xabout(
       'Set the maximum number of inbound connections.  Default is '+k64(idefaultconnections)+'.',
       '<a number>','10..'+k64(net__limit)
       ,true);

      e2(' 500');
      e2(' 3000');
      e2(' 4000');
      e2('');
      m('');
      m('Example 1 sets the maximum number of connections to 500. The second to 3,000. And the third to 4,000. The fourth defaults to '+k64(idefaultconnections)+'.');

      end

   else if (xname='password') then
      begin

      xabout(
       'Set the web panel admin password. The default password is set to "'+idefaultpassword+'". We strongly recommend the password be changed to a strong/unique password before exposing the server to the internet.',
       '<a string of unique characters>','A minimum of 5 characters'
       ,true);

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

      xabout(
       'Set power level for CPU usage.  Default is '+k64(idefaultpower)+'.',
       '<a number>','0..'+k64(ipowerlimit)
       ,true);

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

      xabout(
       'Set raw traffic logging.  Default is enabled.',
       '<a value, 0 or negative=disabled, 1 or higher=enabled>',''
       ,true);

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

      xabout(
       'Set SMTP (simple mail transport protocol) mode.  Default is disabled.',
       '<a value, 0 or negative=disabled, 1 or higher=enabled>',''
       ,true);

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

      xabout(
       'Set live stats mode (console window).  Default is enabled.',
       '<a value, 0 or negative=disabled, 1 or higher=enabled>',''
       ,true);

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

      xabout(
       'Install Bubbles as a service.',
       '',''
       ,false);

      e2('');
      m('');
      m('Installs the server as a service with the following parameters:');
      m('Name: '+app__info('service.name'));
      m('Display Name: '+app__info('service.displayname'));
      m('Description: '+app__info('service.description'));

      end

   else if (xname='uninstall') then
      begin

      xabout(
       'Uninstall Bubbles as a service.',
       '',''
       ,false);

      e2('');
      m('');
      m('Removes the server from the services list.');

      end

   else if (xname='commands') then
      begin

      xabout(
       'List supported commands.',
       '!',''
       ,false);

      end

   else if (xname='help') then
      begin

      xabout2(
       'Get help for a specific command.',':',
       '<command name>',''
       ,true);

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

   else begin

      xabout('','','',false);

      end;

   end;

   function xadminrequired:string;
   begin

   result             :=insstr(' - Admin Level required',not app__adminlevel);

   end;

begin

//defaults
result                :=true;
xrun                  :=false;
xout                  :=nil;
xoutput               :='';

//init
xpos                  :=1;
vreuse                :='';
vcomment              :='';
xappname              :=io__remlastext(io__extractfilename(io__exename));

//decide
xforcecmdok           :=(xforcecmd<>'');

//get
try

redo:

n                     :=strlow(xpull);
nlen                  :=low__len32(n);

if (nlen>=1) then
   begin

   result             :=false;

   end;

if      (nlen<=0)        then goto skipend
else if (n='--password') then
   begin

   vcheck(idefaultpassword);

   if (low__len32(v)>=5) then iadminkey   :=xmakehash(v)
   else                       v           :='<must be at least 5 characters>';

   vok('Password',v,true);

   end

else if (n='--port') then
   begin

   vcheck(intstr32(idefaultport));

   int1                         :=strint32(v);

   if (int1<2) then int1        :=idefaultport
   else             int1        :=frcrange32(int1,2,maxport);

   iport                        :=int1;

   vok('Port',intstr32(iport),true);

   end

else if (n='--smtp') then
   begin

   vcheck('0');

   imail_allow                  :=(strint32(v)>=1);

   vok('SMTP (Port 25)',xenabled(imail_allow),true);

   end

else if (n='--power') then
   begin

   vcheck(k64(idefaultpower));

   ipowerlevel                  :=frcrange32(strint32(v),1,ipowerlimit);

   vok('Power Level',k64(ipowerlevel)+'%',true);

   end

else if (n='--live') then
   begin

   vcheck('1');

   ilivestats                   :=(strint32(v)>=1);

   vok('Live',xenabled(ilivestats),true);

   end

else if (n='--logs') then
   begin

   vcheck('1');

   irawlogs                     :=(strint32(v)>=1);

   vok('Traffic Logs',xenabled(irawlogs),true);

   end

else if (n='--install') then
   begin

   bol1                         :=service__install(int1);

   vok('Install',low__aorbstr('Failed to install service ('+intstr32(int1)+')'+xadminrequired,'Service installed',bol1),true);

   end

else if (n='--uninstall') then
   begin

   bol1                         :=service__uninstall(int1);

   vok('Uninstall',low__aorbstr('Failed to uninstall service ('+intstr32(int1)+')'+xadminrequired,'Service uninstalled',bol1),true);

   end

else if (n='--connections') then
   begin

   vcheck(intstr32(idefaultconnections));

   iconnlimit                   :=frcrange32(strint32(v),10,net__limit);

   vok('Connections',k64(iconnlimit),true);

   end

else if (n='--cachesize') then
   begin

   vcheck(intstr32(idefaultcachesize));

   iramlimit                    :=frcrange32(strint32(v),10,imaxcachesize);

   vok('RAM Cache Size',low__mbauto(mult64(iramlimit,1000000),true),true);

   end

else if (n='--filesize') then
   begin

   vcheck(intstr32(idefaultthreshold));

   ithreshold                   :=frcrange32(strint32(v),0,imaxcachesize*1024000);

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
   xinforow('Port',intstr32(iport));
   xinforow('SMTP (Port 25)',xenabled(imail_allow));
   xinforow('RAM Cache Size',low__mbauto(mult64(iramlimit,1000000),true));
   xinforow('Max. File Size to Cache',low__mbauto(ithreshold,true));
   xinforow('Daily Bandwidth Quota',low__aorbstr('Disabled',low__mbauto(idaily_bandwidth_quota_bytes,true),idaily_bandwidth_quota_bytes>=1));
   xinforow('Power Level',k64(ipowerlevel)+'%');
   xinforow('Traffic Logs',xenabled(irawlogs));
   xinforow('Live Stats',xenabled(ilivestats));
   xinforow('Web Panel','http://localhost:'+intstr32(iport)+iadminpath);
   xinforow('Built-in Tools',low__aorbstr('No','Yes',app__bol('tools')));

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

else if (strcopy1(n,1,7)='--help:')           then xhelp(strcopy1(n,8,low__len32(n)))

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

   xrun                         :=true;

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
if xrun then result             :=true;

except;end;

try

if (xout<>nil) then xoutput     :=str__text(@xout);

str__free(@xout);

except;end;

end;

function png__makeHits(x:tstr8;xhits:longint64):boolean;//make "hits.png" image - 09oct2026
label
   skipend;

const
   dheightscale       =2.5;
   dfontsize          =12;
   dbold              =true;

var
   a                  :tbasicimage;
   e                  :string;
   str1               :string;
   bcolor             :longint32;
   dcolor             :longint32;
   hpad               :longint32;
   vpad               :longint32;
   int2               :longint32;
   int1               :longint32;
   aw                 :longint32;
   ah                 :longint32;

begin

//defaults
result                :=false;
a                     :=nil;
hpad                  :=8;
vpad                  :=4;

try

//check
if not str__lock(@x) then exit;

//range
xhits                 :=frcrange64(xhits,0,max64);

//init
a                     :=misimg32(1,1);
bcolor                :=rgba0__int(0,0,0);
dcolor                :=rgba0__int(255,255,255);

//calculate dimensions required
str1                  :=intstr64(xhits);

mis__drawdigits2(a,misarea(a),hpad,vpad,dfontsize,dcolor,dheightscale,str1,dbold,false,aw,ah);

inc(aw,2*hpad);
inc(ah,2*vpad);

missize(a,aw,ah);

//draw background color
misclsarea2(a,area__make(0,0,aw-1,ah-1),bcolor,bcolor);

//draw text without using system graphics support
mis__drawdigits2(a,misarea(a),hpad,vpad,dfontsize,dcolor,dheightscale,str1,dbold,true,int1,int2);

//make text transparent and background slightly transparent
mask__copy3(a,a,dcolor,220);

//write to io stream
if not png__todata(a,@x,e) then goto skipend;

//successful
result                :=true;

skipend:
except;end;

//free
str__uaf(@x);
freeobj(@a);

end;

procedure xinchit(xdiskhost:string);
begin
try
low__roll64(idaily_hits,1);
imustmakepngs:=true;//triggers ".hits.png" to update
ihitmustsave:=true;//trigers "hits.ini" to be written to disk
ihit.cinc(xdiskhost);
ihitpng.b['mustupdate.'+xdiskhost]:=true;
except;end;
end;

procedure png__makeAll(const xforce:boolean);//make all "hits.png" for listed disk domains "idom"
var
   b                            :tstr8;
   p                            :longint32;
   xlen                         :longint32;
   st                           :longint64;
   ht                           :longint64;
   n                            :string;

   procedure xmakepng(const n:string;const st:longint64);
   begin
   try

   //total ALWAYS updates and DISK DOMAIN only if xforce or mustupdate
   if strmatch(n,'total') or ( strmatch(strcopy1(n,1,xlen),idefaultdisksite) and (xforce or ihitpng.b['mustupdate.'+n]) ) then
      begin

      ihitpng.b['mustupdate.'+n]:=false;

      png__makeHits(b,st);

      ihitpng.s[n]              :=b.text;

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
xlen:=low__len32(idefaultdisksite);
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

procedure xresolvehost(m:tnetbasic);//use mapping
label
   redo;
var
   int3,xcount,v,p:longint;
   xhost,str1:string;
   xfirst:boolean;

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
      for p:=1 to low__len32(x) do
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
   for p:=1 to low__len32(xhost) do
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
xlen:=low__len32(xpath);
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
      result:=(low__len32(xname)=isessionnameLEN);
      break;
      end;
   lp:=p;
   end;
end;//p
except;end;
end;

function xpassword_ok(xpassword:string):boolean;
begin
result:=(xmakehash(xpassword)=iadminkey);
end;

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

function xsessionok(xsessionname,xsessioncookie,xuseragent,xip,xadminpage:string;var xindex:longint):boolean;
var//4 matches performed to permit access: sessionname -> user-agent -> ip -> cookiename
   p:longint;
begin
//defaults
result:=false;
xindex:=0;

try
//check
if (low__len32(xsessionname)<>isessionnameLEN) then exit;
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

function xsessiondel(xsessionname:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;

//check
if (low__len32(xsessionname)<>isessionnameLEN) then exit;

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
end;

procedure xsessiondelall;
var
   p:longint;
begin
for p:=0 to high(isessiontime) do
begin
isessiontime[p]:=0;
isessioncookietime[p]:=0;
isessionname[p]:='';
isessioncookie[p]:='';
isessionua[p]:='';
end;//p
isessioncount:=0;
end;

function xstrcopyto(x:string;xto:char):string;
var
   p:longint;
begin
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__len32(x) do if (x[p-1+stroffset]=xto) then
      begin
      result:=strcopy1(result,1,p-1);
      break;
      end;
   end;
end;

function xforce_backslash(x:string):string;
var
   p:longint;
begin
result:='';

try
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__len32(result) do if (result[p-1+stroffset]='/') then result[p-1+stroffset]:='\';
   end;
except;end;
end;

function xforce_slash(x:string):string;
var
   p:longint;
begin
result:='';

try
result:=x;
if (result<>'') then
   begin
   for p:=1 to low__len32(result) do if (result[p-1+stroffset]='\') then result[p-1+stroffset]:='/';
   end;
except;end;
end;

function xdomfiles(n:string):longint;
begin
result:=0;try;result:=idominfo.i['files.'+n];except;end;
end;

function xdombytes(n:string):comp;
begin
result:=0;try;result:=idominfo.c['bytes.'+n];except;end;
end;

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
   xname:=xforce_slash(strcopy1(xfolder,low__len32(ifastfolder__root)+1,low__len32(xfolder))+xrec.name);//e.g. "www_blaizenterprises_com/index.html"
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
iramdate:=date__now;
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
imail_sender.folder        :=app__subfolder2('outbox',ialongsideexe);


//get list of disk domains (folders in root folder starting with "www_", e.g. "www_blaizenterprise_com"
if not nav__init(xnav) then goto skipend;
if not nav__list(xnav,nlName,xroot,idefaultdisksite+'*','',false,true,false) then goto skipend;
xcount:=nav__count(xnav);
if (xcount>=1) then
   begin
   for p:=0 to (xcount-1) do
   begin
   if nav__get(xnav,p,xstyle,xtep,xsize,xname,xlabel) and strmatch(strcopy1(xname,1,low__len32(idefaultdisksite)),idefaultdisksite) then idom.b[xname]:=true;
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
png__makeAll(true);

except;end;
end;

function xmakehash(x:string):string;
var
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
//was: low__tob64(s,d,0,e);
str__tob64(@s,@d,0);
result:=d.text;
except;end;
try
str__free(@s);
str__free(@d);
except;end;
end;

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
if strmatch(ifastfolder__root,strcopy1(xfilename,1,low__len32(ifastfolder__root))) then strdel1(xfilename,1,low__len32(ifastfolder__root));
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
      if str__splice32(cache__ptr(idata.value[m.wramindex]),restrict32(xfrom),restrict32(xchunksize),m.splicemem,m.splicelen) then result:=(m.splicelen>=1);
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

function xstreamstart(var a:pnetwork;wmode:longint;xfilename:string;xcancache:boolean):boolean;
label//Note: xfilename optional
   doNormal,skipend;

var
   m                  :tnetbasic;//pointer only
   buf                :pobject;//pointer only
   wmax               :longint64;
   xsize              :longint64;
   xdate              :tdatetime;
   p                  :longint32;
   vlen               :longint32;
   xcode              :longint32;
   v2                 :string;
   v                  :string;
   bol1               :boolean;
   xmoduleok          :boolean;
   xcontactok         :boolean;
   xsubscribeok       :boolean;
   xunsubscribeok     :boolean;
   xrangeok           :boolean;

begin

//defaults
result                :=true;//pass-thru

try

xrangeok              :=false;

//check
if not net__recinfo(a,m,buf) then exit;

//init
xcode                 :=200;
m.wmode               :=wmode;
m.wfilename           :=xfilename;
xcontactok            :=strmatch(m.hname,'contact.html');
xsubscribeok          :=strmatch(m.hname,'subscribe.html');
xunsubscribeok        :=strmatch(m.hname,'unsubscribe.html');
xmoduleok             :=(not xcontactok) and (not xsubscribeok) and (not xunsubscribeok) and (m.hmodule_index>=0);

//.reset the buffer
str__softclear2(buf,ibufferlimit);


//decide
if (m.hrange='') or xcontactok or xmoduleok then goto doNormal;


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
   m.writing          :=true;

   goto skipend;

   end;

//set vars
m.wfilesize           :=xsize;
m.wfiledate           :=xdate;
wmax                  :=sub64(m.wfilesize,1);

//empty file -> can't transfer 0 bytes
if (wmax<0) then goto donormal;

//partial download being requested -> "Range: bytes=0-499" where m.hrange holds for example the value "bytes=0-499"
if (m.hrange<>'') and strmatch(strcopy1(m.hrange,1,6),'bytes=') then
   begin

   v                  :=xstrcopyto(strcopy1(m.hrange,7,low__len32(m.hrange)),',');//read only the first section, ignore the rest
   vlen               :=low__len32(v);

   if (vlen>=2) then
      begin

      for p:=1 to vlen do if (v[p-1+stroffset]='-') then
         begin

         //get
         v2           :=strcopy1(v,p+1,vlen);
         //.from
         m.wfrom      :=frcrange64(strint64(strcopy1(v,1,p-1)),0,wmax);
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
m.writing             :=true;
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

   contact__html(a);

   str__clear(@ibuf2);
   str__add(@ibuf2,buf);
   str__clear(buf);
   xsize              :=str__len(@ibuf2);
   xdate              :=date__now;
   xcancache          :=false;

   end

else if xsubscribeok or xunsubscribeok then
   begin

   xfromfile64(m,0,xsize,xdate,maxint,true,true);//must buffer "subscribe.html/unsubscribe.html" so we can edit it on-the-fly

   subscribe__html( a ,m.hdiskhost ,xsubscribeok );

   str__clear(@ibuf2);
   str__add(@ibuf2,buf);
   str__clear(buf);
   xsize              :=str__len(@ibuf2);
   xdate              :=date__now;
   xcancache          :=false;

   end

else if xmoduleok then
   begin

   xfromfile64(m,0,xsize,xdate,maxint,true,true);
   
   tools__makepage2(m.hmodule_index,false,m.hname,ivars,buf,bol1);//don't search for it again, use "xmoduleindex" for direct access to the module in question

   str__clear(@ibuf2);
   str__add(@ibuf2,buf);
   str__clear(buf);
   xsize              :=str__len(@ibuf2);
   xdate              :=date__now;
   xcancache          :=false;

   end;

//set vars
m.wfilesize           :=xsize;
m.wfiledate           :=xdate;
m.wfrom               :=0;
m.wto                 :=sub64(xsize,1);
header__make3(a,xcode,true,xsize,xdate,xcancache,false,'');
m.writing             :=true;

//dynamic page part 2: append data to buf which already has the header
if xcontactok or xsubscribeok or xunsubscribeok or xmoduleok then
   begin

   str__add(buf,@ibuf2);
   str__clear(@ibuf2);
   m.wmode            :=wsmBuf;

   end;

skipend:

except;end;
end;

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
if mail__makemsg(@b,'127.0.0.1','','inbox@localhost',xsubject,xmsg,date__now,e) then mail__writemsg(@b,xsubject,io__makefolder2(ifastfolder__inbox));
except;end;
try;str__free(@b);except;end;
end;

procedure xendofday;
var
   h                            :word;
   min                          :word;
   s                            :word;
   ms                           :word;
   xmsg                         :string;
   v                            :string;
   vcount                       :longint32;
   p                            :longint32;
   n                            :string;//disk site
   dn                           :string;//domain name

begin
try

//other
low__decodetime2(date__now,h,min,s,ms);

case h of
0:if not iendofdaydone then//once per day only
   begin


   //daily summary notice ------------------------------------------------------

   //init
   iendofdaydone                :=true;
   xmsg                         :=xdailysummary(true)+#10+'This is an information notice sent by Bubbles.';

   //get
   if isummarynotice then xwritemsg('Bubbles - Daily Summary',xmsg);


   //reset daily bandwidth counter & state -------------------------------------

   idaily_bandwidth             :=0;//resets daily bandwidth counter
   idaily_bandwidth_exceeded    :=false;
   idaily_newvisitors           :=0;//07apr2025
   idaily_visitors              :=0;//21feb2025
   idaily_requests              :=0;//21feb2025
   idaily_hits                  :=0;//21feb2025
   idaily_email                 :=0;//
   idaily_contact               :=0;//
   idaily_jobs                  :=0;//22feb2025


   //daily subscribe list + notice for each site -------------------------------

   for p:=0 to (idom.count-1) do
   begin

   n                            :=strlow(idom.n[p]);

   if (n<>'') then
      begin

      //get daily subscribe list for each disk site
      if isubscribenotice then
         begin

         //get
         dn                     :=domain__fromDiskSite( n );//disksite -> domain name
         v                      :=subscribe__manageList( vcount ,n ,'' ,true ,false ,false );

         v                      :=
          'Daily Subscribed Emails ( '+k64(vcount)+' ) for site "' + dn + '" ( '+n+' )' + #10 +
                                                                                          #10 +
                                                                                          v;

         //write list to inbox
         if (vcount>=1) then xwritemsg( 'Bubbles - Daily Subscribe List for ' + dn ,v );

         end;

      //delete daily list even when notice is disabled - 09oct2026
      subscribe__manageList( vcount ,n ,'' ,true ,false ,true );

      end;//n

   end;//p


   end;

else iendofdaydone              :=false;//reset

end;//case

except;end;
end;

function xdailysummary(xreset:boolean):string;
const
   hline='------------------------------------------------------------';
var
   a:tstr9;
   n:string;
   ht,bt,h,b:comp;
   p:longint;

   procedure ladd(xhits,xbandwidth,xsite:string);
   const
      xcol='               ';

     function dcol(x:string;xright:boolean):string;
     var
        rlen,xlen:longint;
     begin
     try
     //defaults
     result:=x;
     rlen:=low__len32(result);
     xlen:=low__len32(xcol);
     //align
     if xright and (rlen<xlen) then result:=strcopy1(xcol,1,xlen-rlen)+result;
     except;end;
     end;
   begin
   try
   //range
   xsite:=strdefb(xsite,'-');
   //get
   a.sadd(dcol(xhits,true)+dcol(xbandwidth,true)+strcopy1(xcol,1,5)+xsite+#10);
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
a.sadd('Bubbles - Daily Summary ('+low__gmt(date__now)+')'+#10#10#10);

ladd('Hits','Bandwidth','Disk Site');
a.sadd(hline+#10);

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
   a.sadd(hline+#10);
   ladd(k64(ht),low__mbPLUS(bt,true),'Total');
   end;

//other
a.sadd(#10#10+'Server Up Time: '+app__uptimestr+#10);


//set
result:=a.text;
except;end;
try;str__free(@a);except;end;
end;

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

   function ne(const x:string):string;
   begin
   result:=net__encodeforhtmlstr(x);
   end;

   procedure xaddb(const xnumber,xname,xsize,xrep:string);
   begin
   b.sadd('<div class="ralign breakword">'+xnumber+'</div><div>'+xname+'</div><div class="ralign breakword">'+xsize+'</div><div>'+xrep+'</div>'+#10);
   end;

   procedure xadd(xindex:longint;const xname:string;var xsize:comp);
   begin
   xaddb(k64(xindex)+'.','<a title="View traffic log report" href="'+xneurl('log--'+xname+'.html')+'" target="msg">'+ne(io__remlastext(xname))+'</a>',low__mbPLUS(xsize,true),'<a title="View plain text traffic log (.txt)" href="'+xneurl('log--'+xname)+'" target="msg">RAW</a>');
   atleastone:=true;
   end;

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
   str__sadd(@b,'<form class="inlineblock" method=post action="logs.html"><input name="cmd" type="hidden" value="from.'+intstr32(p*xperpage)+'"><input class="navbut" type=submit value="'+k64(p+1)+'"></form>');
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
if (strcopy1(xcmd,1,5)='from.') then xfrom:=frcrange32(restrict32(strint64(strcopy1(xcmd,6,low__len32(xcmd)))),0,xcount-1) else xfrom:=0;

//add the info message
b.sadd('<div class="logsinfo">You have '+k64(xcount)+' traffic logs in total<br>'+xnavbar+'</div>'+#10);

//start
b.sadd('<div class="logsview">'+#10);//**
b.sadd('<div class="logs">'+#10);
xaddb('#','Name','Size','RAW');

//.list of logs
if (xcount>=1) then
   begin
   for p:=xfrom to frcmax32(xfrom+xperpage-1,xcount-1) do if nav__get(xnav,p,xstyle,xtep,xsize,xname,xlabel) then xadd(p+1,xname,xsize);
   end;

//empty
if not atleastone then xaddb('','( there are no logs )','','');

//finish
b.sadd('</div>'+#10);
b.sadd('<iframe id="nowrap" class="logsmsg" style="white-space:nowrap;text-wrap:nowrap;" name="msg" title="Log"></iframe>'+#10);
b.sadd('</div>'+#10);

//set
result:=b.text;
skipend:
except;end;
try
str__free(@b);
str__free(@xnav);
except;end;
end;

function xinbox__folder(xstyle:string;xread:boolean):string;
begin
if strmatch(xstyle,'trash') then result:=low__aorbstr(ifastfolder__trash,ifastfolder__trash_read,xread)
else                             result:=low__aorbstr(ifastfolder__inbox,ifastfolder__inbox_read,xread);
end;

procedure xinbox__markread(xstyle,xname:string);
var
   df,e:string;
begin
try
df:=io__makefolder2(xinbox__folder(xstyle,true))+xname;
if not io__fileexists(df) then io__tofilestr(df,'read',e);
except;end;
end;

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

   function vpull(xpos:longint):byte;
   begin
   if ((xpos<smin) or (xpos>smax)) and (not block64__fastinfo32(s,xpos,smem,smin,smax)) then
      begin
      result:=0;
      exit;
      end;
   result:=smem[xpos-smin];
   end;

   procedure xsplitline;
   var
      p,p2,lp:longint;
      n,v:string;
   begin
   try
   lp:=1;
   c:=':';
   for p:=1 to low__len32(xline) do
      begin
      if (xline[p-1+stroffset]=';') then
         begin
         n:=strcopy1(xline,lp,p-lp);
         v:='';
         if (n<>'') then
            begin
            for p2:=1 to low__len32(n) do if (n[p2-1+stroffset]=c) then
               begin
               //.name and value pair
               v:=stripwhitespace_lt(strcopy1(n,p2+1,low__len32(n)));
               n:=stripwhitespace_lt(strlow(strcopy1(n,1,p2-1)));
               //.remove quotes from value "v"
               if (strcopy1(v,1,1)='"') then strdel1(v,1,1);
               if (strcopy1(v,low__len32(v),1)='"') then strdel1(v,low__len32(v),1);
               //.boundary
               if (n='boundary') then v:='--'+v;
               //.store
               xinfo.s[intstr32(xseccount)+'.'+n]:=v;
               if (xboundarylen<=0) and (n='boundary') then
                  begin
                  xboundary:=v;
                  xboundarylen:=low__len32(v);
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
slen:=str__len32(s);
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
xinfo.i[intstr32(xseccount)+'.soh']:=xpos;//start of header

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
      xinfo.i[intstr32(xseccount)+'.sob']:=xpos;//start of body
      goto skipone;
      end;
   end;

if xbody then
   begin
   if (xboundarylen>=1) and (v=ssdash) and strmatch(str__str0(s,xpos,xboundarylen),xboundary) then
      begin
      xinfo.i[intstr32(xseccount)+'.eob']:=xpos;//end of body
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
if not xinfo.found(intstr32(xseccount)+'.eob') then
   begin
   xinfo.i[intstr32(xseccount)+'.eob']:=frcmin32(slen-1,0);
   inc(xseccount);
   end;

//return best result
//.html
for p:=0 to (xseccount-1) do
begin
if strmatch(xinfo.s[intstr32(p)+'.content-type'],'text/html') then
   begin
   dhtml:=true;
   xfrom:=xinfo.i[intstr32(p)+'.sob'];
   xto:=xinfo.i[intstr32(p)+'.eob'];
   str__add3(d,s,xfrom,xto-xfrom+1);
//xxxxxxxx   if (xinfo.s[intstr32(p)+'.content-transfer-encoding'],'base64') then //xxxxxxxxxxxxxx need a block base64 handler
   result:=true;
   goto skipend;
   end;
end;//p
//.text
for p:=0 to (xseccount-1) do
begin
if strmatch(xinfo.s[intstr32(p)+'.content-type'],'text/plain') then
   begin
   dhtml:=false;
   xfrom:=xinfo.i[intstr32(p)+'.sob'];
   xto:=xinfo.i[intstr32(p)+'.eob'];
   str__add3(d,s,xfrom,xto-xfrom+1);
//xxxxxxxx   if (xinfo.s[intstr32(p)+'.content-transfer-encoding'],'base64') then //xxxxxxxxxxxxxx need a block base64 handler
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

   function x404:boolean;
   begin
   result:=true;
   header__make(a,200,false,true,'', xhtmlstart3(a,'',false,true,false)+'Message not found'+xhtmlfinish2(true) ,'');
   m.writing:=true;
   end;

   procedure xconvert;
   label
      redo1,skipone1,redo2,skipone2,skipok2,skipend;
   var
      xstartpointINJECTPOS,smin,smax,slen,p,dlen:longint;
      smem:pdlbyte;
      vtmp,vtmp2,v:byte;
      xstartpointOK2,xscript1,xscript2:boolean;
      str1,n6,n7:string;

      procedure pstart(xcopy:boolean);
      begin
      if xcopy then
         begin
         str__clear(@s);
         str__add(@s,@d);
         str__clear(@d);
         end;
      dlen:=0;
      slen:=str__len32(@s);
      smax:=-2;
      smin:=-1;
      p:=0;
      xscript1:=false;
      xscript2:=false;
      end;

      procedure vpull;
      begin
      if ((p<smin) or (p>smax)) and (not block64__fastinfo32(@s,p,smem,smin,smax)) then
         begin
         v:=0;
         exit;
         end;
      v:=smem[p-smin];
      end;

      procedure vadd;
      begin
      inc(dlen);
      str__minlen(@d,dlen);
      str__setbytes0(@d,dlen-1,v);
      end;

      procedure vadd1(x:byte);
      begin
      inc(dlen);
      str__minlen(@d,dlen);
      str__setbytes0(@d,dlen-1,x);
      end;

      procedure vadd2(x:string);
      begin
      str__sadd(@d,x);
      dlen:=str__len32(@d);
      end;

      function xnext(xpos:longint):byte;
      begin
      if ((xpos<smin) or (xpos>smax)) and (not block64__fastinfo32(@s,xpos,smem,smin,smax)) then
         begin
         result:=0;
         exit;
         end;
      result:=smem[xpos-smin];
      end;

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

      procedure xinsinfo(xpos:longint);
      const
         xspace3='&nbsp; &nbsp;';
         xspace5=xspace3+' &nbsp;';
      begin
      try
      str__clear(@s);
      str__sadd(@s,
      '<style type="text/css">'+#10+
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
   dlen:=str__len32(@d);
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
   slen:=low__len32(s);
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
   xorgname:=strcopy1(m.hname,12,low__len32(m.hname));
   xname:=io__remlastext(xorgname);
   end
else if strmatch(strcopy1(xname,1,11),'trash.udl--') then
   begin
   xcmd:='undelete';
   xstyle:='trash';
   xorgname:=strcopy1(m.hname,12,low__len32(m.hname));
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

function xneurl(x:string):string;//netencode url
begin
result:=net__encodeurlstr(x,true);
end;

function xencodetextforhtml_barely(x:string):string;//only filter out [<>"] 3 chars
begin
result:=net__encodeforhtmlstr2(x,true,false,[sslessthan,ssmorethan,ssdoublequote],[0]);
end;

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

   function ne(x:string):string;
   begin
   result:=net__encodeforhtmlstr(x);
   end;

   function xdate(x:string):string;
   var
      y,m,d,hh,mm,ss:longint;
   begin
   try
   //defaults
   result:='';
   //get
   y:=strint32(strcopy1(x,1,4));
   if (y>=1900) then
      begin
      m:=strint32(strcopy1(x,5,2));
      if (m>=1) and (m<=12) then
         begin
         d:=strint32(strcopy1(x,7,2));
         if (d>=1) and (d<=31) then
            begin
            hh:=strint32(strcopy1(x,9,2));
            mm:=frcrange32(strint32(strcopy1(x,11,2)),0,59);
            ss:=frcrange32(strint32(strcopy1(x,13,2)),0,59);
            result:=intstr32(d)+#32+low__month1(m,false)+#32+intstr32(y)+' / '+low__digpad11(hh,2)+' : '+low__digpad11(mm,2)+' . '+low__digpad11(ss,2);
            end;
         end;
      end;
   except;end;
   end;

   procedure xaddb(const xnumber,xdate,xsubject,xsize,xeml,xact:string);
   begin
   b.sadd('<div class="ralign breakword">'+xnumber+' </div><div>'+strdefb(xdate,'-')+'</div><div class="hidden">'+strdefb(xsubject,'-')+'</div><div class="ralign breakword">'+xsize+'</div><div>'+xeml+'</div><div>'+xact+'</div>'+#10);
   end;

   procedure xadd(xindex:longint;const xname:string;var xsize:comp);
   var
      d,s:string;
      xlen:longint;
      xemlOK:boolean;
   begin
   //split name -> datetime + subject
   d:='';
   s:=xname;
   xlen:=low__len32(xname);
   xemlok:=strmatch(strcopy1(xname,xlen-3,4),'.eml');
   if xinbox_filenameassubject(s,d,s) then d:=xdate(d);
   //get
   case sstyle of
   0:xaddb(k64(xindex)+'.',d,'<a title="View message" class="'+low__aorbstr('unread','read',xhaveread(xname))+'" href="'+xneurl('inbox--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">'+xencodetextforhtml_barely(s)+'</a>',low__mbPLUS(xsize,true),'<a title="Download message in .eml file format" href="'+xneurl('inbox--'+xname+insstr('.eml',not xemlok))+'">EML</a>','<a title="Delete message to Trash folder" href="'+xneurl('inbox.del--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">Del</a>');
   1:xaddb(k64(xindex)+'.',d,'<a title="View message" class="'+low__aorbstr('unread','read',xhaveread(xname))+'" href="'+xneurl('trash--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">'+xencodetextforhtml_barely(s)+'</a>',low__mbPLUS(xsize,true),'<a title="Download message in .eml file format" href="'+xneurl('trash--'+xname+insstr('.eml',not xemlok))+'">EML</a>','<a title="Restore message to Inbox" href="'+xneurl('trash.udl--'+xname+insstr('.eml',not xemlok))+'.html" target="msg">Res</a>');
   end;
   atleastone:=true;
   end;

   procedure xadd2(const xname,xval:string);
   begin
   b.sadd('<div></div><div></div><div>'+ne(xname)+'</div><div class="mlauto">'+ne(xval)+'</div><div></div>'+#10);
   end;

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
   str__sadd(@b,'<form class="inlineblock" method=post action="'+xname+'.html"><input name="cmd" type="hidden" value="from.'+intstr32(p*iinbox_msgsperpage)+'"><input class="navbut" type=submit value="'+k64(p+1)+'"></form>');
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
if (strcopy1(xcmd,1,5)='from.') then xfrom:=frcrange32(restrict32(strint64(strcopy1(xcmd,6,low__len32(xcmd)))),0,xcount-1) else xfrom:=0;

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
b.sadd('<div class="inboxinfo">You have '+str1+' and '+k64(xcount)+' in total<br>'+xnavbar+str2+'</div>'+#10);


//start
b.sadd('<div class="inboxview">'+#10);//**

b.sadd('<div class="inbox">'+#10);
xaddb('#','Date','Subject','Size','EML','Act');

if (xcount>=1) then
   begin
   for p:=xfrom to frcmax32(xfrom+iinbox_msgsperpage-1,xcount-1) do if nav__get(xnav,p,xnavstyle,xtep,xsize,xname,xlabel) then xadd(p+1,xname,xsize);
   end;

//empty
if not atleastone then xadd2('( there are no messages )','');

//finish
b.sadd('</div>'+#10);

b.sadd('<iframe class="inboxmsg" name="msg" title="Message"></iframe>'+#10);
b.sadd('</div>'+#10);

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

function xcompose(var a:pnetwork;xstyle,xcmd,xcmd2:string):string;//03apr2025
label
   redo,skipend;
const
   xred='#e00';
   xgrn='#0a0';
   xwht='#fff';
   xreadonlycolor='#0a02';
   xaddrhint='title="Separate multiple email address with a comma, for example contact@blaizenterprises.com, software@blaizenterprises.com"';
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   b:tstr8;
   xbackcolor,xreadonly,xerrmsg:string;
   xpage:longint;

   function fa(const x:string):string;//filter addresses
   begin
   result:=mail__filteraddresses(x,true,false);
   end;

   procedure al(const x:string);
   begin
   b.sadd(x+#10);
   end;

   function xsend:boolean;
   label
      skipend;
   var
      c:tstr8;
      e:string;
   begin
   //defaults
   result:=false;
   c     :=nil;

   try
   //init
   c:=str__new8;

//bcc not yet:   if not mail__makemsg2(@c,'',ivars.s['from'],ivars.s['to'],ivars.s['cc'],ivars.s['bcc'],ivars.s['subject'],ivars.s['message'],now,ivars,e) then goto skipend;
   if not mail__makemsg2(@c,imail_sender.osenderdomain,imail_sender.ouseragent,'',ivars.s['from'],ivars.s['to'],ivars.s['cc'],'',ivars.s['subject'],ivars.s['message'],date__now,ivars,e) then goto skipend;

   if not imail_sender.saveTOqueue(@c) then goto skipend;

   //successful
   result:=true;
   skipend:
   except;end;
   //free
   str__free(@c);
   end;
begin
//defaults
result   :='';
xcmd     :=strlow(xcmd);
xpage    :=frcrange32(strint32(strdefb(strlow(xcmd2),'1')),1,3);
b        :=nil;
xerrmsg  :='';

try
//check
if (not net__recinfo(a,m,buf)) or (not m.vsessvalid) then exit;

//init
b:=str__new8;

//xxxxxxxxxxxxxxxxxxxxxx debug//xxxxxxxxxxxxxxxxx
{//debjug only
ivars.s['to']    :=strdefb(ivars.s['to'] ,'blaizenterprises@gmail.com');
ivars.s['cc']    :=strdefb(ivars.s['cc'] ,'cc@blaizenterprises.com');
ivars.s['subject']:=utf8__toplaintext7bitb(strdefb(ivars.s['subject'],'Test message'));
ivars.s['message']:=utf8__toplaintext7bitb(strdefb(ivars.s['message'],'Test message body...'));
{}//xxxxxxxxxxxxxxx


//filter
if ivars.found('back') then xpage:=1;

ivars.s['from']:=strdefb(mail__extractaddress(ivars.s['from']),imail_fromaddress);

if (ivars.count>=2) then
   begin
   //filter
   ivars.s['to']    :=fa(ivars.s['to']);
   if (ivars.s['cc']<>'')  then ivars.s['cc'] :=fa(ivars.s['cc']);//optional

   ivars.s['subject']:=utf8__toplaintext7bitb(ivars.s['subject']);
   ivars.s['message']:=utf8__toplaintext7bitb(ivars.s['message']);

   //check
   if  (ivars.s['to']='')     then xerrmsg:=xerrmsg+'<br>* The "To" field requires a valid email address';
   if (ivars.s['from']='')    then xerrmsg:=xerrmsg+'<br>* The "From" field requires a valid email address';
   if (ivars.s['subject']='') then xerrmsg:=xerrmsg+'<br>* The "Subject" field requires content';
   if (ivars.s['message']='') then xerrmsg:=xerrmsg+'<br>* The "Message" field requires content';

   if (xerrmsg<>'')        then xpage:=1;
   end;


//get
redo:
if (xpage>=3) then
   begin
   if not xsend then
      begin
      xpage:=1;
      xerrmsg:='<br>* Could not queue your email for sending - check disk space';
      goto redo;
      end;

   al('<div style="margin:1rem 0;background-color:'+xgrn+';color:'+xwht+';border-radius:1rem;padding:2rem 0.5rem;">Your email has been queued for sending</div>');
   end
else
   begin
   xreadonly  :=insstr(' readonly', (xpage>=2) );
   xbackcolor :=insstr(' style="background-color:'+xreadonlycolor+';"', (xpage>=2) );

   if (xerrmsg<>'') then al('<div style="margin:1rem 0;background-color:'+xred+';color:'+xwht+';border-radius:1rem;padding:0.5rem;">Important:'+xerrmsg+'</div>');

   al('<form method=post action="compose.html" enctype="multipart/form-data">');
   al('<input name="cmd" type="hidden" value="compose">');

   case xpage of
   1:al('<input name="cmd2" type="hidden" value="2">');
   2:al('<input name="cmd2" type="hidden" value="3">');
   end;

   al('<div style="margin-bottom:0.5rem">To<br><input class="text"'+xbackcolor+' name="to" type="text"'+xaddrhint+' value="'+net__encodeforhtmlstr(ivars.s['to'])+'"'+xreadonly+'></div>');

   al('<div class="grid2">');
   al('<div class="inlineblock">Cc<br><input class="text"'+xbackcolor+' name="cc" type="text"'+xaddrhint+' value="'+net__encodeforhtmlstr(ivars.s['cc'])+'"'+xreadonly+'></div>');
   al('<div class="inlineblock">From<br><input class="text"'+xbackcolor+' name="from" type="text" value="'+net__encodeforhtmlstr(ivars.s['from'])+'"'+xreadonly+'></div>');//****
   al('</div>');

//bcc not yet:   al('<div class="inlineblock">Bcc<br><input class="text"'+xbackcolor+' name="bcc" type="text"'+xaddrhint+' value="'+net__encodeforhtmlstr(ivars.s['bcc'])+'"'+xreadonly+'></div>');//****

   al('<div style="margin-top:1rem;">Subject<br><input class="text"'+xbackcolor+' name="subject" type="text" value="'+net__encodeforhtmlstr(ivars.s['subject'])+'"'+xreadonly+'></div>');

   al('<div style="margin-top:1rem;">Message<br><textarea style="text-wrap:wrap;" class="textbox"'+xbackcolor+' rows="12" name="message"'+xreadonly+'>'+net__encodeforhtmlstr(ivars.s['message'])+'</textarea></div>');

   if (xpage=2) then
      begin
      al('<div style="margin-top:1rem;background-color:'+xgrn+';color:'+xwht+';border-radius:1rem;padding:0.75rem;">Attach Files (Optional).  Combined maximum upload size is ~'+low__mbauto2(imaxuploadsize_admin,0,true)+'.<br><input type="file" name="filename" id="files" multiple></div>');
      end;

   al('<div style="margin-top:1rem;background-color:#dddddd78;text-align:right;border-radius:1rem;">'+
      insstr('<input class="button" type=submit name="back" value="&lt; Back">', (xpage>=2) )+
             '<input class="button" type=submit value="'+low__aorbstr('Next &gt;','Send Mail', (xpage>=2) )+'">'+
      '</div>'
      );

   al('</form>');
   end;


//set
result:=b.text;
skipend:
except;end;
//free
str__free(@b);
end;

function xdommapping2(xonesiteonly:string;var xerrorcount:longint):string;
var
   xdata:tstr9;
   m:tnetbasic;
   n:string;
   p:longint;
   xallsitesok:boolean;

   function xtick(xyes:boolean):string;
   begin
   if xyes then result:='<div class="yes">&#x2713;</div>' else result:='<div class="no">X</div>';
   end;

   procedure xadd(a,b,c,d:string;xmakelink,xshowtick:boolean);
   var
      dport,t:string;
      bol1:boolean;

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
      if strmatch(a,'127.0.0.1') or strmatch(a,'localhost') then dport:=':'+intstr32(iport) else dport:='';
      xdata.sadd(
      '<div>'+insstr('<a href="http://'+a+dport+'" target="_blank">',xmakelink)+ne(a)+insstr('</a>',xmakelink)+'</div>'+
      '<div>'+t+ne(b)+'</div>'+
      '<div>'+ne(c)+'</div>'+
      '<div class="ralign">'+ne(d)+'</div>'+
      #10);
      end;
   except;end;
   end;

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
   if (xdata<>nil) then xdata.sadd('<div class="dommap">'+#10);
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
      xdata.sadd('</div>'+#10);
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

function xdommapping(var xerrorcount:longint):string;
begin
result:='';try;result:=xdommapping2('',xerrorcount);except;end;
end;

function xinfostats:string;
var
   xdata:tstr9;
   p:longint;

   procedure xadd2(a,b:string;abold,bbold:boolean);
   var
      s:string;

    function ne(x:string):string;
    begin
    //special case for TITLE only -> allow hyperlink code through
    if (strcopy1(x,1,3)='<a ') then result:=x else result:=net__encodeforhtmlstr(x);
    end;
   begin
   try
   s:=' style="font-weight:bold;"';
   xdata.sadd(
   '<div'+insstr(s,abold)+'>'+ne(a)+'</div>'+
   '<div class="ralign"'+insstr(s,bbold)+'>'+ne(b)+'</div>'+
   #10);
   except;end;
   end;

   procedure xadd4(a,b,c,d:string;abold,bbold,cbold,dbold:boolean);
   var
      s:string;

    function ne(x:string):string;
    begin
    result:=net__encodeforhtmlstr(x);
    end;
   begin
   try
   s:=' style="font-weight:bold;"';
   xdata.sadd(
   '<div style="'+insstr('font-weight:bold;',abold)+'text-align:left;">'+ne(a)+'</div>'+
   '<div'+insstr(s,bbold)+'>'+ne(b)+'</div>'+
   '<div'+insstr(s,cbold)+'>'+ne(c)+'</div>'+
   '<div'+insstr(s,dbold)+'>'+ne(d)+'</div>'+
   #10);
   except;end;
   end;

   procedure xadd(a,b:string;xbold:boolean);
   begin
   xadd2(a,b,xbold,xbold);
   end;

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

   procedure xdom(n:string);
   begin
   xdom2(n,false,false,false,false);
   end;

   function xabout:string;
   var
      p:longint;
      n,v:string;

      procedure xadd2(n,v:string);
      begin
      if (strcopy1(v,1,1)='*') then v:=app__info(strcopy1(v,2,low__len32(v)));
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
   xadd2(app__info('gosszip.name'),app__info('gosszip.ver'));
   {$ifdef jpeg}xadd2(app__info('gossjpg.name'),app__info('gossjpg.ver'));{$endif}

   //.module names and versions
   for p:=0 to max32 do if tools__vers(p,n,v) then xadd2(n,v) else break;

   //.codebase - 18jun2025
   xadd2('','');
   xadd2('Codebase','Version');
   xadd2('Gossamer (Console)',app__info('gossamer.ver'));

   end;
begin
//defaults
result:='';

try
xdata:=nil;
//init
xdata:=str__new9;

//dailysummary
xdata.sadd('<pre class="daystats">'+#10);
xdata.sadd(xdailysummary(false));
xdata.sadd('</pre>'+#10+'<br><br>'+#10);

//stats for server
xdata.sadd('<div class="stats">'+#10);
xadd('Server Stats','<a href="live-status.html">Live Daily Status</a>',true);
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
xadd2('RAM',low__mbPLUS(bytes__RAM,true),false,true);
xadd('Files Cached',k64(iramfilescached)+' / '+k64(iramfilecount),false);
xdata.sadd('</div>'+#10+'<br><br>'+#10);

//stats for sites
xdata.sadd('<div class="domstats">'+#10);
xadd4('Site Stats','Hits','Files','RAM',true,false,false,false);
for p:=0 to (idom.count-1) do xdom(idom.n[p]);
xdom2('Total',true,true,true,true);
xdata.sadd('</div>'+#10+'<br><br>'+#10);

//dailysummary
xdata.sadd('<pre class="console">'+#10);
xdata.sadd('About'+#10+#10);
xdata.sadd(xabout);
xdata.sadd('</pre>'+#10);

//set
result:=xdata.text;
except;end;
try
str__free(@xdata);
except;end;
end;

function xtotallabel(xpreblankline:boolean;xcount:comp;xname,xname12:string):string;
begin
result:=insstr(#10,xpreblankline)+k64(xcount)+#32+xname+insstr(xname12,xcount<>1)+' found.';
end;

function xconbut(xpageurl,xcmd,xcmd2,xtitle,xbutlabel:string):string;
begin
if (xbutlabel='') then xbutlabel:=xtitle;
if (xtitle='')    then xtitle:=xbutlabel;
result:='<form class="inlineblock" method=post action="'+xpageurl+'"><input name="cmd" type="hidden" value="'+xcmd+'"><input name="cmd2" type="hidden" value="'+xcmd2+'"><input class="conbut" type=submit title="'+xtitle+'" value="'+xbutlabel+'"></form>';
end;

function xlivestatus(xstyle:longint):string;//realtime vital statistics - 21feb2025
const
   br=#10;
   xrefreshrate_seconds=30*60;//30 minutes
var
   xbandwidth,xbandwidthunit:string;

   procedure xsplit(s:string;var d1,d2:string);
   var
      p:longint;
   begin
   d1:=s;
   d2:='';
   if (d1<>'') then for p:=low__len32(d1) downto 1 do if (d1[p-1+stroffset]=#32) then
      begin
      d2:=strcopy1(d1,p+1,low__len32(d1));
      d1:=strcopy1(d1,1,p-1);
      break;
      end;
   end;

   function s(xlabel:string;xcount:comp):string;
   begin
   if (xcount=1) then result:=xlabel else result:=xlabel+'s';
   end;
begin
//init

//.bandwidth
xsplit(low__size(idaily_bandwidth,'mb+',1,true),xbandwidth,xbandwidthunit);
//.requests


//get
result:=

'<!DOCTYPE html>'+br+
'<html class="client-nojs" lang="en" dir="ltr">'+br+
'<head>'+br+
'<meta charset="UTF-8">'+br+
'<meta http-equiv="refresh" content="'+intstr32(xrefreshrate_seconds)+'">'+br+
'<title>Live Daily Status (30min)</title>'+br+
'<style type="text/css">'+br+
':root'+br+
'{'+br+
'--font-family-text:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";'+br+
'--bgcolor:#444;'+br+
'--text:#eee;'+br+
'}'+br+

'html'+br+
'{'+br+
'margin:0;'+br+
'height:100%;'+br+
'font-family:var(--font-family-text);'+br+
'}'+br+

'body {'+br+
'background-color:var(--bgcolor);'+br+
'color:var(--text);'+br+
'overflow-x:hidden;'+br+
'overflow-y:auto;'+br+
'position:relative;'+br+
'min-height:100%;'+br+
'display:flex;'+br+
'flex-direction:column;'+br+
'margin:0;'+br+
'padding:0;'+br+
'}'+br+

'.livestatus-base {display:block;font-size:min(30vw,30vh);margin:auto;text-align:center;}'+br+
'.livestatus-small {display:inline-block;font-size:30%;margin:0 0 0 1rem;}'+br+

'</style>'+br+
'</head>'+br+

'<body>'+br+
'<div class="livestatus-base">'+br+
//.daily bandwidth
'<div style="display:block;font-size:95%;">'+xbandwidth+'<div class="livestatus-small">'+xbandwidthunit+'</div></div>'+br+
//.daily visitors
'<div style="display:block;font-size:75%;">'+k64(idaily_visitors)+'<div class="livestatus-small">'+s('Visitor',idaily_visitors)+'</div></div>'+br+

//.daily new visitors
'<div style="display:block;font-size:30%;">'+k64(idaily_newvisitors)+'<div class="livestatus-small">'+s('New Visitor',idaily_newvisitors)+'</div></div>'+br+//07apr2025

//.daily requests
'<div style="display:block;font-size:30%;">'+k64(idaily_requests)+'<div class="livestatus-small">'+s('Request',idaily_requests)+' <div style="font-size:65%">all types</div></div></div>'+br+
//.daily hits
'<div style="display:block;font-size:30%;">'+k64(idaily_hits)+'<div class="livestatus-small">'+s('Hit',idaily_hits)+' <div style="font-size:65%">htm/html</div></div></div>'+br+

 //.daily emails + contacts + jobs
'<div style="display:block;font-size:20%;">'+
 k64(idaily_email)+'<div class="livestatus-small">'+s('Email',idaily_email)+'</div>'+
 ' &nbsp; &nbsp; '+
 k64(idaily_contact)+'<div class="livestatus-small">'+s('Contact',idaily_contact)+'</div>'+
 ' &nbsp; &nbsp; '+
 k64(idaily_jobs)+'<div class="livestatus-small">'+s('Job',idaily_jobs)+'</div>'+
 '<br>'+
 '<div style="font-size:50%"><br>'+mail__date(date__now)+'</div>'+
 '</div>'+br+

'</div>'+br+
'</body>'+br+
'</html>';
end;

function xinfo2(xpageurl,xcmd:string):string;
var
   str1:string;
begin
xinfo(xpageurl,xcmd,str1,result);
end;

procedure xinfo(xpageurl,xcmd:string;var xtitle,xout:string);
const
   xred='<div class="red" style="display:inline">';
   xredend='</div>';
var
   a:pnetwork;
   b:tobject;
   s,ls,xcount,p:longint;
   c,xms64:comp;
   xmode,xtype:string;

   //.ban list
   xmins,xconn,xpost,xpost2,xbad,xhits:longint;
   xaddress:string;
   xbytes:comp;
   xbanned:boolean;
   xbadrequest,xbadmail,xbanbymask,xnotthislink,xscanfor,xbanfor,xconnlimit,xpostlimit,xpostlimit2,xbadlimit,xhitlimit,xbadreqlimit,xbadmaillimit:longint;
   xdatalimit:comp;

   function xcolumnRight2RED(x:string;xmaxwidth:longint):string;
   begin
   case (x<>'') and (x[0+stroffset]='*') of
   true:result:=xred+low__rcolumn(strcopy1(x,2,low__len32(x)),xmaxwidth)+xredend;
   false:result:=low__rcolumn(x,xmaxwidth);
   end;
   end;

   procedure xadd(x:string);
   begin
   str__sadd(@b,x+#10);
   end;

   procedure xstart;
   begin
   xadd('<pre class="console">');
   end;

   procedure xstop;
   begin
   xadd('</pre>');
   end;

   procedure xadd9(xindex,xtype,xmode,xopentime,xidletime,xreusecount,xrecycled,xlastip,xbandwidth:string);
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
   xadd(v1+low__rcolumn(xindex,6)+#32+low__rcolumn(xtype,6)+#32+low__rcolumn(xmode,10)+#32+low__rcolumn(xopentime,13)+#32+low__rcolumn(xidletime,13)+#32+low__rcolumn(xreusecount,12)+#32+low__rcolumn(xrecycled,10)+low__rcolumn(xlastip,20)+low__rcolumn(xbandwidth,20)+v2);
   end;

   procedure xadd10(xip,xpost,xpost2,xbad,xrequests,xbandwidth,xbadrequest,xbadmaildomain,xbanbymask,xnotthislink,xmins:string);
   begin
   xadd(
    low__rcolumn(xip,30)+#32+
    low__rcolumn(xpost,7)+#32+
    low__rcolumn(xpost2,7)+#32+
    low__rcolumn(xbad,11)+#32+
    low__rcolumn(xrequests,10)+#32+
    low__rcolumn(xbandwidth,14)+#32+
    low__rcolumn(xbadrequest,6)+#32+
    low__rcolumn(xbadmaildomain,7)+#32+
    low__rcolumn(xbanbymask,7)+#32+
    low__rcolumn(xnotthislink,6)+#32+
    low__rcolumn(xmins,13));//29apr2024
   end;

   procedure xadd10RED(xip,xpost,xpost2,xbad,xrequests,xbandwidth,xbadrequest,xbadmaildomain,xbanbymask,xnotthislink,xmins:string);
   begin
   xadd(
    low__rcolumn(xip,30)+#32+
    xcolumnRight2RED(xpost,7)+#32+
    xcolumnRight2RED(xpost2,7)+#32+
    xcolumnRight2RED(xbad,11)+#32+
    xcolumnRight2RED(xrequests,10)+#32+
    xcolumnRight2RED(xbandwidth,14)+#32+
    xcolumnRight2RED(xbadrequest,6)+#32+
    xcolumnRight2RED(xbadmaildomain,7)+#32+
    xcolumnRight2RED(xbanbymask,7)+#32+
    xcolumnRight2RED(xnotthislink,6)+#32+
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
   if ipsec__slot(p,xaddress,xmins,xconn,xpost,xpost2,xbad,xhits,xbadrequest,xbadmail,xbanbymask,xnotthislink,xbytes,xbanned) and xbanned then
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
   ipsec__getvals(xscanfor,xbanfor,xconnlimit,xpostlimit,xpostlimit2,xbadlimit,xhitlimit,xbadreqlimit,xbadmaillimit,xdatalimit);

   //get
   xstart;
   xtitle:='Ban List';

   xadd10('IP Address','Posts','Posts2','Bad Logins','Requests','Bandwidth','BadReq','BadMail','BadMask','BadBot','Time');
   xadd10('----------','-----','------','----------','--------','---------','------','-------','-------','------','----');

   for p:=0 to (ipsec__count-1) do
   begin
   if ipsec__slot(p,xaddress,xmins,xconn,xpost,xpost2,xbad,xhits,xbadrequest,xbadmail,xbanbymask,xnotthislink,xbytes,xbanned) and xbanned then
      begin
      inc(xcount);
      xadd10RED(xaddress,
       insstr('*',(xpostlimit>=1) and (xpost>=xpostlimit))+k64(xpost),
       insstr('*',(xpostlimit2>=1) and (xpost2>=xpostlimit2))+k64(xpost2),//20feb2025
       insstr('*',(xbadlimit>=1) and (xbad>=xbadlimit))+k64(xbad),
       insstr('*',(xhitlimit>=1) and (xhits>=xhitlimit))+k64(xhits),
       insstr('*',(xdatalimit>=1) and (xbytes>=xdatalimit))+low__mbPLUS(xbytes,true),
       insstr('*',(xbadreqlimit>=1) and (xbadrequest>=xbadreqlimit))+k64(xbadrequest),
       insstr('*',(xbadmaillimit>=1) and (xbadmail>=xbadmaillimit))+k64(xbadmail),
       insstr('*',xbanbymask>=1)+k64(xbanbymask),
       insstr('*',xnotthislink>=1)+k64(xnotthislink),
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
   ls:=-2;

   xstart;
   xtitle:='Open Connections';
   xadd9('Conn #','Type','Last Mode','Open Time','Idle Time','Use Count','Recycled','Last IP Address','IP Bandwidth');
   xadd9('------','----','---------','---------','---------','---------','--------','---------------','------------');

   for p:=0 to (xconn_limit-1) do if net__haverec(a,p) and a.client and (a.more<>nil) and (a.more is tnetbasic) then
      begin
      //.slot #
      if (a.more<>nil) and (a.more is tnetbasic) then s:=(a.more as tnetbasic).hslot else s:=-1;
      if (s>=0) then c:=ipsec__slotBytes((a.more as tnetbasic).hslot) else c:=0;
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

      xadd9(k64(p),//connections 0 and 1 => http and smtp server slots - 08apr2024
      xtype,
      xmode,
      low__uptime(sub64(xms64,a.time_created),false,false,true,true,false,''),//compact versions - 500days = 13c
      low__uptime(sub64(xms64,a.time_idle),false,false,true,true,false,''),
      k64(a.used),
      k64(a.recycle),
      a.infolastip,
      insstr(k64(c),(s>=0) and (ls<>s)));//list the bandwidth for the IP address once, all other instances leave blank

      //ls
      ls:=s;
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

function xmanage:string;//19jun2025
var
   b                            :tstr9;
   xsitemapsto                  :string;
   xcreatesite_status           :string;
   str1                         :string;
   str2                         :string;
   dname                        :string;
   xname                        :string;
   xcmd                         :string;
   xbuttonName                  :string;
   xsite                        :string;
   xsitehtml                    :string;
   v                            :string;
   xmask                        :string;
   xvalidlen                    :boolean;
   xsitemaps                    :boolean;
   bol1                         :boolean;
   int1                         :longint32;
   p                            :longint32;

   procedure xhead(const xname,xtitle:string);
   begin

   str__sadd(@b,xh2(xname,xtitle+' ['+xsitehtml+']'));

   end;

   function xbutton(const xbutton,xmoreclass:string):string;
   begin

   result:='<div class="manageoption"><div><input class="button'+xmoreclass+'" type=submit value="'+net__encodeforhtmlstr(xbutton)+'"></div></div>';

   end;

   function xbuttonlist(const xbutton:array of string;const xmoreclass:string):string;
   var
      p               :longint32;
      xonce           :boolean;

   begin

   //start
   result             :='<div class="manageoption"><div>';
   xonce              :=true;

   //get buttons
   for p:=low(xbutton) to high(xbutton) do
   begin

   if (xbutton[p]<>'') then
      begin

      result          :=result + insstr(' &nbsp; ',not xonce) + '<input class="button'+xmoreclass+'" type="submit" name="buttonname" value="'+net__encodeforhtmlstr(xbutton[p])+'">';
      xonce           :=false;

      end;

   end;//p

   //finish
   result             :=result+'</div></div>';

   end;

   function xtextandbutton2(const xshow:boolean;const xtextname,xtext,xbutton,xmoreclass:string):string;
   begin

   result:='<div class="manageoption"><div><input'+insstr(' class="text"',xshow)+' type="'+low__aorbstr('hidden','text',xshow)+'" name="'+xtextname+'" value="'+net__encodeforhtmlstr(xtext)+'"></div><div><input class="button'+xmoreclass+'" type=submit value="'+net__encodeforhtmlstr(xbutton)+'"></div></div>';

   end;

   function xtextandbutton(const xtextname,xtext,xbutton:string):string;
   begin

   result:=xtextandbutton2(true,xtextname,xtext,xbutton,'');

   end;

   function xform(const xname,xcmd,xsite,xcode:string):string;
   begin

   result:=
           '<form class="block" method=post action="manage.html'+insstr('#'+xname,xname<>'')+'">'+
    insstr('<input name="cmd" type="hidden" value="'+xcmd+'">',xcmd<>'')+
    insstr('<input name="site" type="hidden" value="'+net__encodeforhtmlstr(xsite)+'">',xsite<>'')+
    xcode+
    '</form>'+#10;

   end;

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

   function xlistfiles(xsite,xmask:string;xdel,xuse:boolean):string;//19jun2025
   label
      skipend;

   var
      xnav                      :tstr8;
      xlog                      :tstr9;
      xramcount                 :longint32;
      xdiskcount                :longint32;
      xtotal                    :longint32;
      xerrcount                 :longint32;
      xstyle                    :longint32;
      xtep                      :longint32;
      xcount                    :longint32;
      p                         :longint32;
      xtotalsize                :longint64;
      xsize                     :longint64;
      str1                      :string;
      xfolder                   :string;
      xname                     :string;
      xlabel                    :string;

   begin

   //defaults
   result                       :='';
   xnav                         :=nil;
   xlog                         :=nil;
   xtotal                       :=0;
   xerrcount                    :=0;
   xtotalsize                   :=0;
   xramcount                    :=0;
   xdiskcount                   :=0;

   //check
   if (not xuse) or (xsite='') then exit;

   try

   //init
   xnav                         :=str__new8;
   xlog                         :=str__new9;

   //get
   if not nav__init(xnav) then goto skipend;

   xfolder                      :=io__asfolder(ifastfolder__root+xsite);

   if not nav__list(xnav,nlName,xfolder,strdefb(xmask,'*'),'',false,false,true) then goto skipend;

   xcount                       :=nav__count(xnav);

   if (xcount>=1) then
      begin

      for p:=0 to (xcount-1) do
      begin

      if nav__get(xnav,p,xstyle,xtep,xsize,xname,xlabel) then
         begin

         inc(xtotal);

         xtotalsize             :=add64(xtotalsize,xsize);

         if xdel then
            begin

            case io__remfile(xfolder+xname) of
            true :begin

               str1             :='[ DELETED ]';

               end;
            false:begin

               str1             :='[ <span class=red>Del.Err.</span>]';
               inc(xerrcount);

               end;
            end;//case

            end

         else begin

            case xfileinram(xfolder+xname) of
            true :begin

               str1             :='[ RAM  ]';
               inc(xramcount);

               end;
            false:begin

               str1             :='[ <span class=red>DISK</span> ]';//mark disk status in red
               inc(xdiskcount);

               end;
            end;//case

            end;

         if (xtotal=1) then
            begin

            case xdel of
            true:begin

               str__sadd(@xlog,'Status       '+xcolumnRight('Size')+'  Name'+#10);
               str__sadd(@xlog,'------       '+xcolumnRight('----')+'  ----'+#10);

               end;
            false:begin

               str__sadd(@xlog,'Location  '+xcolumnRight('Size')+'  Name'+#10);
               str__sadd(@xlog,'--------  '+xcolumnRight('----')+'  ----'+#10);

               end;
            end;//case

            end;

         str__sadd(@xlog,str1+'  '+xcolumnRight(k64(xsize))+'  '+xname+#10);

         end;

      end;//p

      //.finalise
      if (xtotal>=1) then
         begin

         str__sadd(@xlog,#10+k64(xtotalsize)+' bytes ('+low__mbPLUS(xtotalsize,true)+') in total'+insstr(' with '+k64(xramcount)+' file/s in RAM and '+k64(xdiskcount)+' on DISK',not xdel)+#10);//19jun2025

         end;

      end;

   //successful
   if (str__len(@xlog)<=0) then str__sadd(@xlog,'There are no files for this site.  The site is empty and can be deleted.');

   result:=
    '<pre class="console">'+
    k64(xtotal)+' files '+low__aorbstr('listed','deleted',xdel)+' for site "'+xsite+'" with '+k64(xerrcount)+' errors'+#10+
    #10+
    str__text(@xlog)+
    '</pre>';

    //site is empty -> offer up the "Delete Site" button
   if nav__init(xnav) and nav__list(xnav,nlName,ifastfolder__root+xsite,'*','',false,false,true) and (nav__count(xnav)<=0) then
      begin

      result                    :=result+xform('del','manage.del','',xtextandbutton2(false,'name',xsite,'Delete Site',''));

      end;

   skipend:
   except;end;

   //free
   str__free(@xnav);
   str__free(@xlog);

   end;
   
begin

//defaults
result                          :='';
b                               :=nil;

try

//init
xcmd                            :=strlow(ivars.s['cmd']);
xbuttonName                     :=strlow(ivars.s['buttonname']);//09oct2026
xsite                           :=io__extractfilename(strlow(net__decodestrb(ivars.s['site'])));
xsitehtml                       :=net__encodeforhtmlstr(xsite);
xmask                           :=io__extractfilename(net__decodestrb(ivars.s['mask']));
xname                           :=io__extractfilename(strlow(net__decodestrb(ivars.s['name'])));
xcreatesite_status              :='';
b                               :=str__new9;

//decide
if (xcmd='') or (xsite='') then
   begin

   //.new site -> do action here so "idom" can be updated BEFORE we list the sites
   if (xcmd='manage.new') then
      begin

      dname                     :=xname;

      if (dname<>'') then
         begin

         for p:=1 to low__len32(dname) do
         begin

         case byte(dname[p-1+stroffset]) of
         ssDot:dname[p-1+stroffset]       :='_';
         ssSlash,ssBackSlash:;
         end;//case

         end;//p

         //enforce leading "www_"
         if not strmatch( strcopy1(dname,1,low__len32(idefaultdisksite)) , idefaultdisksite ) then dname:=idefaultdisksite+dname;

         //check + create + log
         if strmatch(dname,idefaultdisksite+'localhost') or strmatch(dname,idefaultdisksite) then xvalidlen:=true
         else
            begin

            int1                :=0;

            for p:=1 to low__len32(dname) do if (dname[p-1+stroffset]='_') then inc(int1);

            xvalidlen           :=(int1>=2);

            end;

         if not xvalidlen                                  then xcreatesite_status:='<pre class="console">Invalid site name "'+dname+'".</pre>'
         else if io__folderexists(ifastfolder__root+dname) then xcreatesite_status:='<pre class="console">Site name "'+dname+'" already exists.</pre>'
         else
            begin

            bol1                :=io__makefolder(ifastfolder__root+dname);

            xcreatesite_status  :='<pre class="console">'+low__aorbstr('Failed to create site "'+dname+'".','Site "'+dname+'" created.',bol1)+'</pre>';

            //.include the new site name immediately in the "idom" so any cleaning will retain the new site data - 18feb2024
            if bol1 then idom.b[dname]:=true;

            end;

         end;

      end;

   //.sites
   str__sadd(@b,xh2('manage',xsymbol('manage')+'Manage Sites'));
   str__sadd(@b,xminiconsole);
   str__sadd(@b,'Click the "Reload Site(s)" button to refresh the memory cache and update the site list to reflect changes made to one or more sites.');
   str__sadd(@b,xform('','reload','','<input class="button buttonaslink" type=submit value="Reload Site(s)">'));

   str__sadd(@b,xvsep);
   str__sadd(@b,'<br>Select a site below to manage its contents:');

   int1                         :=0;

   for p:=0 to (idom.count-1) do
   begin

   v                            :=strlow(idom.n[p]);

   if (v<>'') then
      begin

      inc(int1);

      str__sadd(@b,xform('','manage.options',v,'<input class="button buttonaslink" type=submit value="'+k64(int1)+'. &nbsp;'+net__encodeforhtmlstr(v)+'">'));

      end;

   end;//p

   //.new site
   str__sadd(@b,xvsep);
   str__sadd(@b,xh2('new','Create Site / Disk Site'));
   str__sadd(@b,xform('new','manage.new','','Type a domain name or disk site name (e.g. mydomain.com or mydomain_com) to make it known to and hostable by Bubbles.'+xtextandbutton('name',xname,'Create Site')));
   if (xcreatesite_status<>'') then str__sadd(@b,xcreatesite_status);

   //.del site
   str__sadd(@b,xvsep);
   str__sadd(@b,xh2('del','Delete Site / Disk Site'));
   str__sadd(@b,xform('del','manage.del','',
    'Type a domain name or disk site name (e.g. mydomain.com or mydomain_com) to remove it from Bubbles.  '+
    'A site must be empty before it can be deleted.  To empty a site, click the site button from the list above, then scroll down and click the "Delete Files..." button, and confirm by clicking the "Permanently Delete Files" button.  '+
    'All files on the site are removed and the site can be deleted.  Click the "Delete Site" button.  The site is deleted.'+xtextandbutton('name',xname,'Delete Site')));

   if (xcmd='manage.del') then
      begin

      dname                     :=xname;

      if (dname<>'') then
         begin

         for p:=1 to low__len32(dname) do
         begin

         case byte(dname[p-1+stroffset]) of
         ssDot:dname[p-1+stroffset]:='_';
         ssSlash,ssBackSlash:;
         end;//case

         end;//p

         //enforce leading "www_"
         if not strmatch( strcopy1(dname,1,low__len32(idefaultdisksite)) , idefaultdisksite ) then dname:=idefaultdisksite+dname;

         //delete + log
         if not io__folderexists(ifastfolder__root+dname)   then str1:='Site "'+dname+'" does not exist/was previously deleted.'
         else if strmatch(dname,idefaultdisksite)           then str1:='Can''t delete default site.'
         else if io__deletefolder(ifastfolder__root+dname)  then str1:='Site "'+dname+'" deleted.'
         else if io__folderexists(ifastfolder__root+dname)  then str1:='Unable to delete site "'+dname+'" as it contains files which must first be deleted.<br><form class="inline-block" method=post action="manage.html#delete"><input name="cmd" type="hidden" value="manage.options"><input name="site" type="hidden" value="'+net__encodeforhtmlstr(dname)+'"><input class="button" type=submit value="Delete Files..."></form>'
         else                                                    str1:='Failed.';

         str__sadd(@b,'<pre class="console">'+str1+'</pre>');

         end;

      end;

   end

else begin

   //.site support info
   xsitemapsto                  :=xdommapping2(xsite,int1);
   xsitemaps                    :=not strmatch(xsitemapsto,xsite);

   //.general
   xhead('general',xsymbol('manage')+'General');

   str__sadd(@b,
    insstr('<div class="bad">This site reroutes to "'+net__encodeforhtmlstr(xsitemapsto)+'".  Files, site hit counter and redirects do not apply.</div>',xsitemaps)+
    xminiconsole);

   str__sadd(@b,'Refresh the memory cache and update the site list to reflect changes made to one or more sites.');
   str__sadd(@b,xform('','reload','','<input type="hidden" name="site" value="'+xsitehtml+'"><input class="button buttonaslink" type=submit value="Reload Site(s)">'));

   //.upload
   xhead('upload','Upload Files');
   str__sadd(@b,
    '<form class="block" method=post action="manage.html" enctype="multipart/form-data"><input name="cmd" type="hidden" value="manage.upload.'+xsitehtml+'">'+
    '<div class="manageoption"><div><input type="file" name="filename" id="filename" multiple></div><div><input class="button" type="submit" value="Upload Files" name="submit"></div></div>'+
    '</form>'+#10+
    'The combined maximum upload size is ~'+low__mbauto2(imaxuploadsize_admin,0,true)+' for the selected files.'+
    xuploadlog
    );

   //.list
   xhead('list','List Files');
   str__sadd(@b,xvsep);
   str__sadd(@b,
    xform('list','manage.list',xsite,'Type a complex mask or leave blank to list all files (e.g. *.zip or *.zip;*ab*.exe;)'+xtextandbutton('mask',xmask,'List Files'))+
    xlistfiles(xsite,xmask,false,xcmd='manage.list'));

   //.delete
   xhead('delete','Delete Files');
   str__sadd(@b,xvsep);

   if (xcmd='manage.delete') then
      begin

      //confirm prompt
      str__sadd(@b,
      xform('delete','manage.option',xsite,xtextandbutton2(false,'mask',xmask,'ABORT',' abort'))+
      xform('delete','manage.delete2',xsite,'Type a complex mask or leave blank to delete all files (e.g. *.zip or *.zip;*ab*.exe;)'+xtextandbutton('mask',xmask,'Permanently Delete Files'))+
      '');

      end

   else begin

      //delete
      str__sadd(@b,xform('delete','manage.delete',xsite,'Type a complex mask or leave blank to delete all files (e.g. *.zip or *.zip;*ab*.exe;)'+xtextandbutton('mask',xmask,'Delete Files...')));

      if (xcmd='manage.delete2') then str__sadd(@b,xlistfiles(xsite,xmask,true,true));

      end;

   //.hit counters
   if (xcmd='manage.counter') then
      begin

      ihit.c[xsite]             :=strint64(net__decodestrb(ivars.s['counter']));

      png__makeAll(true);//update counter pngs

      imustsavesettings         :=true;

      end;

   xhead('counter','Hit Counter');

   str__sadd(@b,xvsep);

   str__sadd(@b,
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

   str__sadd(@b,xvsep);

   str__sadd(@b,
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


   //subscribe list
   if (xbuttonname='save and replace') then
      begin

      //.replace list -> read list
      str2                      :=subscribe__manageList( int1 ,xsite ,net__decodestrb(ivars.s['manage.subscribe.list']) ,false ,true ,false );//09oct2026

      end

   else if (xbuttonname='load') then
      begin

      //.read list only
      str2                      :=subscribe__manageList( int1 ,xsite ,'' ,false ,false ,false );//09oct2026

      end

   else begin

      //.no list -> user needs to hit the "load" button first - 09oct2026
      str2                      :='';
      int1                      :=0;

      end;

   xhead('subscribe','Subscribe List');

   str__sadd(@b,xvsep);


   case (xbuttonname<>'') of
   true:str1          :='There '+low__aorbstr('is','are',int1<>1)+#32+k64(int1)+' subscribed email address'+insstr('es',int1<>1)+' for the site.  ';
   else str1          :='List of subscribed email addresses for the site.  ';
   end;//case

   str1               :=str1 +
    'Click the "Load" button to view the list.  '+
    'The list is automatically filtered, e.g. white space, duplicates, and invalid entires are removed.  '+
    'A date/time stamped backup copy of the list is stored in the "subscribe\backup\" folder each time it''s submitted using the text box below.  '+
    '<br>'+
    '<textarea class="textbox" spellcheck="false" rows="12" wrap="no" name="manage.subscribe.list">'+net__encodeforhtmlstr(str2)+'</textarea>'+#10+
    xvsep;

    str2              :='';//reduce mem

    case (xbuttonname<>'') of
    true:str1         :=str1 + xbuttonlist( [ 'Load','Save and Replace' ],'');
    else str1         :=str1 + xbuttonlist( [ 'Load'                    ],'');
    end;//case

   str__sadd( @b ,xform('subscribe' ,'manage.subscribe' ,xsite ,str1) );

   end;

//set
result                          :=str__text(@b);

except;end;

//free
str__free(@b);

end;

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
   for p:=1 to low__len32(dnamelist) do
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

function xredirect__sitelinks(ssite:string):string;
label
   skipend;
var
   b:tobject;
   p:longint;
   xsite,xname:string;

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
      for p:=1 to low__len32(x) do if (x[p-1+stroffset]='/') then
         begin
         xsite:=strcopy1(x,1,p-1);
         xname:=strcopy1(x,p+1,low__len32(x));
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
if (xname<>'') and (xsite<>'') and strmatch(xsite,ssite) then str__sadd(@b,xname+': '+iredirect.v[p]+#10);
end;//p

//successful
result:=str__text(@b);
skipend:
except;end;
try;str__free(@b);except;end;
end;

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

procedure xredirect__clean(xremovesite:string);
var
   b:tobject;
   p:longint;
   xsite,xname:string;

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
      for p:=1 to low__len32(x) do if (x[p-1+stroffset]='/') then
         begin
         xsite:=strcopy1(x,1,p-1);
         xname:=strcopy1(x,p+1,low__len32(x));
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
if (xname<>'') and (xsite<>'') and (not strmatch(xsite,xremovesite)) and (iredirect.v[p]<>'') and idom.found(xsite) then str__sadd(@b,xsite+'/'+xname+': '+iredirect.v[p]+#10);
end;//p

//successful
iredirect.text:=str__text(@b);
except;end;
try;str__free(@b);except;end;
end;

function xh2(xlinkname,xname:string):string;
begin
try;result:=xh2b(xlinkname,xname,'');except;end;
end;

function xh2b(xlinkname,xname,xclass:string):string;
begin
try;result:=insstr('<div class="vsepbig"></div><a name="'+xlinkname+'"></a>',xlinkname<>'')+#10+'<h2'+insstr(' class="'+xclass+'"',xclass<>'')+'>'+xname+'</h2>'+#10;except;end;
end;

function xvsep:string;
begin
try;result:='<div class="vsep"></div>'+#10;except;end;
end;

function xvsepbig:string;
begin
try;result:='<div class="vsepbig"></div>'+#10;except;end;
end;

function xhtmlstart(var a:pnetwork;xshowtoolbar:boolean):string;
begin
result:=xhtmlstart2(a,'',xshowtoolbar);
end;

function xhtmlstart1(var a:pnetwork;xhead:string;xshowtoolbar:boolean;xmaxwidth:longint):string;
begin
result:=xhtmlstart5(a,'',xhead,xshowtoolbar,false,xmaxwidth);
end;

function xhtmlstart2(var a:pnetwork;xhead:string;xshowtoolbar:boolean):string;
begin
result:=xhtmlstart3(a,xhead,xshowtoolbar,false,false);
end;

function xsymbol(xname:string):string;
var
   n:string;
begin
//init
n:=strlow(xname);

//get
if      (n='home')       then result:='&#127969;'
else if (n='compose')    then result:='&#128234;'
else if (n='inbox')      then result:='&#128233;'
else if (n='trash')      then result:='&#128465;'
else if (n='logs')       then result:='&#129717;'
else if (n='tools')      then result:='&#129691;'
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
else if (n='general')    then result:='&#127917;'//21feb2025
//.tool specific
else if (n='search')     then result:='&#127917;'//21feb2025
else if (n='crawler')    then result:='&#127917;'//21feb2025
else if (n='iconmaker')  then result:='&#127917;'//21feb2025
else if (n='imageconverter')  then result:='&#127917;'//22feb2025
//.other
else                          result:='';
end;

function xhtmlstart3(var a:pnetwork;xhead:string;xshowtoolbar,xbare,xultrawide:boolean):string;
begin
result:=xhtmlstart4(a,'',xhead,xshowtoolbar,xbare,xultrawide);
end;

function xhtmlstart4(var a:pnetwork;xhead0,xhead1:string;xshowtoolbar,xbare,xultrawide:boolean):string;
begin
result:=xhtmlstart5(a,xhead0,xhead1,xshowtoolbar,xbare,low__aorb(880,1900,xultrawide));
end;

function xhtmlstart5(var a:pnetwork;xhead0,xhead1:string;xshowtoolbar,xbare:boolean;xmaxwidth:longint):string;
var
   m:tnetbasic;
   buf:pobject;

   function l3(s,u,n,nlabel:string):string;//link
   var
      xlabel:string;
   begin
   if (u='') then u:=strlow(n);
   u:=u+'.html';
   xlabel:=strdefb(nlabel,n);
   //set
   result:=
   '<a id="" target="_top" href="'+u+'" class="toolbarbutton'+insstr(' toolbarfocus',strmatch(m.hname,u))+'" aria-label="'+xlabel+'" title="'+xlabel+'">'+xsymbol(s)+n+'</a>'+
   '<a id="" target="_top" href="'+u+'" class="toolbaricon'+insstr(' toolbarfocus',strmatch(m.hname,u))+'" aria-label="'+xlabel+'" title="'+xlabel+'">'+xsymbol(s)+'</a>'+
   '';
   end;

   function l2(u,n,nlabel:string):string;//link
   begin
   result:=l3(n,u,n,nlabel);
   end;

   function l(u,n:string):string;//link
   begin
   result:=l2(u,n,'');
   end;

   function xtoolbar:string;
   var
      p:longint;
      s,n,t,h:string;//symbol, name, title and help
   begin
   //tool toolbar
   if (tools__toolbarcount(m.hmodule_index)>=2) then
      begin
      result:=
      l3('home','index','Home','Home')+//home link back to Bubbles
      l3('tools','tools','Tools','Built-in tools');//link to built-in tools

      for p:=0 to max32 do if tools__toolbaritem(m.hmodule_index,p,s,n,t,h) then result:=result+l3(s,n,t,h) else break;
      result:=result+l('','Help');
      end
   //server settings
   else
      begin
      //init
      result:='';

      //main Bubbles toolbar
      result:=result+
      insstr(l3('tools','tools','Tools','Built-in tools'),tools__count>=1)+
      l2('index','Overview','Overview Summaries')+
      l2('','Compose','Compose new mail')+
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
      l('','Help');
      end;
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
'--max-width:'+intstr32(frcmin32(xmaxwidth,0))+'px;'+#10+
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
'.tool-listings {display:grid;grid-template-columns:1fr 1fr;grid-gap:12px;margin:0;}'+#10+
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
'@media only screen and (max-width: 820px){.tool-listings {grid-template-columns:100%}}'+#10+
'@media only screen and (max-width: 1000px){.inboxview, .logsview {grid-template-columns:100%; grid-template-rows:3fr 5fr !important;}}'+#10+
//.toolbar buttons -> icons switching
'@media only screen and (max-width: 800px){:root {--scroll-vpad:1em; --vmargin:.4em;} .toolbarbutton {display:none !important;} .toolbaricon {display:inline-block !important;}}'+#10+


'</style>'+#10+
xhead1+
'</head>'+#10+
'<body>'+#10+

//.toolbar
insstr('<div class="toolbar">'+xtoolbar+'</div>'+#10,xshowtoolbar)+

//.doc start
insstr(xhtmlback,not xbare);
except;end;
end;

function xhtmlback:string;
begin
try;result:='<div class="back">'+#10;except;end;
end;

function xhtmlfinish:string;
begin
result:=xhtmlfinish2(false);
end;

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
xlen:=low__len32(x);
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

function contact__html(var a:pnetwork):boolean;
label//Important: Uses values from global "ivars" handler
   skipend;

var
   m                  :tnetbasic;//ptr only
   buf                :pobject;//ptr only
   xemail             :tstr9;
   xmsg               :tstr9;
   xsubject           :string;
   dspamCheck_ok      :boolean;
   xreplymessage      :string;
   x                  :string;
   n                  :string;
   e                  :string;
   xlen               :longint32;
   p2                 :longint32;
   p                  :longint32;
   int1               :longint32;
   int2               :longint32;
   xcontact_question  :boolean;
   xhaveinput         :boolean;
   xmustspamguardreply:boolean;
   xmustreply         :boolean;
   ok                 :boolean;

   procedure xspamguard;
   var
      p               :longint32;
      xquestion       :string;

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
      if xcontact_question and (not xhaveinput) then spamGuard__makeQuestion(xquestion)
      else                                           xquestion:='';

      //insert SpamGuard at the "((spamguard))"
      for p:=1 to xlen do if (x[p-1+stroffset]='(') and strmatch(strcopy1(x,p,13),'((spamguard))') then
         begin

         x            :=strcopy1(x,1,p-1)+xspamguard_code(xquestion<>'')+strcopy1(x,p+13,xlen);
         xlen         :=low__len32(x);
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
            x         :=strcopy1(x,1,p-1)+xspamguard_code(true)+strcopy1(x,p,xlen);
            xlen      :=low__len32(x);
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
result                :=true;//pass-thru
xlen                  :=0;
xmustreply            :=false;
xmustspamguardreply   :=false;
xmsg                  :=nil;
xemail                :=nil;
ok                    :=false;
xreplymessage         :='';
xcontact_question     :=icontact_question;

try

//check
if (ivars=nil) or (not net__recinfo(a,m,buf)) then exit;

//init
xhaveinput            :=(ivars.count>=1);//inbound data
xmustreply            :=xhaveinput;
x                     :=str__text(buf);
xlen                  :=low__len32(x);

//SpamGuard
xSpamGuard;

//contact form submissions have been disabled
if not icontact_allow then
   begin

   xmustreply         :=true;
   goto skipend;

   end;

//check
if not xmustreply then
   begin

   goto skipend;//check this second

   end;

//init
xemail                :=str__new9;
xmsg                  :=str__new9;

//get

//.subject
xsubject              :=strdefb(ivars.s['subject'],'(no subject)');
dspamCheck_ok         :=(not xcontact_question) or spamGuard__checkAnswer(ivars.i['answer']);//08oct2026

//.text
xmsg.sadd(strdefb(strdefb(ivars.s['message'],ivars.s['msg']),'(no message)'));

//.append any other "name=value" pairs at the end of the message body
xmsg.sadd(#10+#10+'--( More Information )----------------------------'+#10);
xmsg.sadd('sender-ip: '+m.hip+#10);//sender-ip

if (ivars.count>=1) then for p:=0 to (ivars.count-1) do
   begin

   n                  :=strlow(ivars.n[p]);
   if (n<>'') and (n<>'subject') and (n<>'message') and (n<>'msg') then xmsg.sadd(n+': '+ivars.v[p]+#10);

   end;//p

//set
//.make standard 7bit email message
if not mail__makemsg(@xemail,m.hip,ivars.s['email'],'inbox@localhost',xsubject,xmsg.text,date__now,e) then goto skipend;


//.write email message to inbox -> if it fails the challenge question drop it and return an error message to the user's browswer - 08oct2026
if dspamCheck_ok and (not mail__writemsg(@xemail,xsubject,io__makefolder2(xinbox__folder('inbox',false)))) then
   begin

   goto skipend;

   end;

//.daily tracker -> track all attemps, even failed ones - 09oct2026
low__roll64(idaily_contact,1);

//successful
ok                    :=true;
skipend:

except;end;
try

if xmustreply then
   begin
   //decide
   if not icontact_allow     then xreplymessage:=strdefb(icontact_off,icontact_def_off)
   else if not dspamCheck_ok then xreplymessage:='The supplied Spam Guard answer is wrong.'//08oct2026
   else if ok                then xreplymessage:=strdefb(icontact_ok,icontact_def_ok)
   else                           xreplymessage:=strdefb(icontact_fail,icontact_def_fail);

   //reply value #1 -> replace "<!--reply-->...<!--endreply-->" with reply content -> this way we are able to swap out a whole chunk of static html code and replace with a fully customisable html reply
   if (x<>'') then
      begin
      //init
      int1            :=0;
      int2            :=0;

      for p:=1 to xlen do if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,12),'<!--reply-->') then
         begin

         int1         :=p;
         break;

         end;//p

      if (int1>=1) then for p:=1 to xlen do if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,15),'<!--endreply-->') then
         begin

         int2         :=p+15;
         break;

         end;//p

      //get
      if (int1>=1) and (int2>=1) then
         begin

         x            :=strcopy1(x,1,int1-1)+xreplymessage+strcopy1(x,int2,xlen);
         xlen         :=low__len32(x);
         xmustreply   :=false;//done

         end;

      end;

   //reply value #2 -> "<form " or "<form>" -> insert reply above "<form*>"
   if xmustreply and (xlen>=1) then
      begin

      for p:=1 to xlen do if (x[p-1+stroffset]='<') and (strmatch(strcopy1(x,p,6),'<form>') or strmatch(strcopy1(x,p,6),'<form ')) then
         begin

         x            :=strcopy1(x,1,p-1)+xreplymessage+strcopy1(x,p,xlen);
         xlen         :=low__len32(x);
         xmustreply   :=false;//done
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

            x         :=strcopy1(x,1,p2)+xreplymessage+strcopy1(x,p2+1,xlen);
            //xlen:=low__len32(x);
            xmustreply:=false;//done
            break;

            end;//p2

         break;

         end;//p

      end;

   //reply value #4 -> none of the above tags were found, so just insert reply at beginning of static file "str1"
   if xmustreply then
      begin

      x               :=xreplymessage+x;
      //xmustreply:=false;

      end;

   //set
   str__settext(buf,x);

   end

else if xmustspamguardreply then str__settext(buf,x);

except;end;

//free
str__free(@xemail);
str__free(@xmsg);

end;

function subscribe__html(var a:pnetwork;const ddiskHost:string;const xsubscribe:boolean):boolean;//08oct2026
label//Important: Uses values from global "ivars" handler
   skipend;

var
   m                  :tnetbasic;//ptr only
   buf                :pobject;//ptr only
   xmsg               :tstr9;
   dsubject           :string;
   demail             :string;
   dspamCheck_ok      :boolean;
   dlistMsg           :string;
   xreplymessage      :string;
   x                  :string;
   n                  :string;
   e                  :string;
   xlen               :longint32;
   p2                 :longint32;
   p                  :longint32;
   int1               :longint32;
   int2               :longint32;
   xsubscribe_question:boolean;
   xhaveinput         :boolean;
   xmustspamguardreply:boolean;
   xmustreply         :boolean;
   xnotused           :string;

   procedure xspamguard;
   var
      p               :longint32;
      xquestion       :string;

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
      if xsubscribe_question and (not xhaveinput) then spamGuard__makeQuestion(xquestion)
      else                                             xquestion:='';

      //insert SpamGuard at the "((spamguard))"
      for p:=1 to xlen do if (x[p-1+stroffset]='(') and strmatch(strcopy1(x,p,13),'((spamguard))') then
         begin

         x            :=strcopy1(x,1,p-1)+xspamguard_code(xquestion<>'')+strcopy1(x,p+13,xlen);
         xlen         :=low__len32(x);
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
            x         :=strcopy1(x,1,p-1)+xspamguard_code(true)+strcopy1(x,p,xlen);
            xlen      :=low__len32(x);
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
result                :=true;//pass-thru
xlen                  :=0;
xmustreply            :=false;
xmustspamguardreply   :=false;
xmsg                  :=nil;
xreplymessage         :='';
xsubscribe_question   :=isubscribe_question and xsubscribe;//not required for "unsubscribe" requests - 08oct2026
dspamCheck_ok         :=true;
dlistMsg              :='';

try

//check
if (ivars=nil) or (not net__recinfo(a,m,buf)) then exit;

//init
xhaveinput            :=(ivars.count>=1);//inbound data
xmustreply            :=xhaveinput;
x                     :=str__text(buf);
xlen                  :=low__len32(x);

//SpamGuard
xSpamGuard;

//contact form submissions have been disabled
if not isubscribe_allow then
   begin

   xmustreply         :=true;
   goto skipend;

   end;

//check
if not xmustreply then
   begin

   goto skipend;//check this second

   end;

//Spam Guard
dspamCheck_ok         :=(not xsubscribe_question) or spamGuard__checkAnswer(ivars.i['answer']);

//update subscribe list + write notification email
if dspamCheck_ok then
   begin

   //get email address -> note: "subscribe__manageOne()" returns a filtered version of "demail" - 09oct2026
   demail             :=ivars.s['email'];

   //sync "dailyList" as well - 09oct2026
   subscribe__manageOne( ddiskHost ,demail ,true ,xsubscribe ,xnotused );

   //sync subscribe list -> true=listChanged -> write notification email - 09oct2026
   if subscribe__manageOne( ddiskHost ,demail ,false ,xsubscribe ,dlistMsg ) and isubscribeEachNotice then
      begin

      //init
      xmsg            :=str__new9;

      //get
      //.email subject
      dsubject        :=low__aorbstr('Unsubscribe','Subscribe',xsubscribe) + ' Request for ' + m.hdesthost;

      //.email body
      xmsg.sadd( '-- '     + dsubject + ' --'                                     + #10 );
      xmsg.sadd( 'Email: ' + demail                                               + #10 );
      xmsg.sadd( 'Mode: '  + low__aorbstr('Del','Add',xsubscribe)                 + #10 );
      xmsg.sadd( 'Site: '  + m.hdesthost+' ( '+m.hdiskhost+' )'                   + #10 );//site being subscribed to - 09ct2026

      //.append any other "name=value" pairs at the end of the message body
      xmsg.sadd( #10+#10+'--( More Information )----------------------------'     + #10 );
      xmsg.sadd( 'sender-ip: ' + m.hip                                            + #10 );//sender-ip

      if (ivars.count>=1) then for p:=0 to (ivars.count-1) do
         begin

         n                  :=strlow(ivars.n[p]);
         if (n<>'') and (n<>'email') and (n<>'pin') then xmsg.sadd(n+': '+ivars.v[p]+#10);

         end;//p

      //.write message to inbox
      xwritemsg( 'Bubbles - '+dsubject ,xmsg.text );

      end;

   end;

//.daily tracker -> track all attempts, including failed attempts - 09oct2026
low__roll64(idaily_contact,1);

//successful
skipend:

except;end;
try

if xmustreply then
   begin

   //decide
   case xsubscribe of

   true:begin

      if not isubscribe_allow    then xreplymessage :='Subscribe service is currently offline.'
      else if not dspamCheck_ok  then xreplymessage :='Your answer to the Spam Guard question is incorrect.'
      else                            xreplymessage :=strdefb(dlistMsg,'Subscribe request processed.');

      end;

   else begin

      if not isubscribe_allow    then xreplymessage :='Unsubscribe service is currently offline.'
      else                            xreplymessage :=strdefb(dlistMsg,'Unsubscribe request processed.');

      end;

   end;//case


   //reply value #1 -> replace "<!--reply-->...<!--endreply-->" with reply content -> this way we are able to swap out a whole chunk of static html code and replace with a fully customisable html reply
   if (x<>'') then
      begin
      //init
      int1            :=0;
      int2            :=0;

      for p:=1 to xlen do if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,12),'<!--reply-->') then
         begin

         int1         :=p;
         break;

         end;//p

      if (int1>=1) then for p:=1 to xlen do if (x[p-1+stroffset]='<') and strmatch(strcopy1(x,p,15),'<!--endreply-->') then
         begin

         int2         :=p+15;
         break;

         end;//p

      //get
      if (int1>=1) and (int2>=1) then
         begin

         x            :=strcopy1(x,1,int1-1)+xreplymessage+strcopy1(x,int2,xlen);
         xlen         :=low__len32(x);
         xmustreply   :=false;//done

         end;

      end;

   //reply value #2 -> "<form " or "<form>" -> insert reply above "<form*>"
   if xmustreply and (xlen>=1) then
      begin

      for p:=1 to xlen do if (x[p-1+stroffset]='<') and (strmatch(strcopy1(x,p,6),'<form>') or strmatch(strcopy1(x,p,6),'<form ')) then
         begin

         x            :=strcopy1(x,1,p-1)+xreplymessage+strcopy1(x,p,xlen);
         xlen         :=low__len32(x);
         xmustreply   :=false;//done
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

            x         :=strcopy1(x,1,p2)+xreplymessage+strcopy1(x,p2+1,xlen);
            //xlen:=low__len32(x);
            xmustreply:=false;//done
            break;

            end;//p2

         break;

         end;//p

      end;

   //reply value #4 -> none of the above tags were found, so just insert reply at beginning of static file "str1"
   if xmustreply then
      begin

      x               :=xreplymessage+x;
      //xmustreply:=false;

      end;

   //set
   str__settext(buf,x);

   end

else if xmustspamguardreply then str__settext(buf,x);

except;end;

//free
str__free(@xmsg);

end;

function subscribe__listFilename(const ddiskHost:string;const xdailyList:boolean):string;
begin

result                :=app__subfolder2('subscribe',ialongsideexe) + ddiskHost + '__subscribe' + insstr('-daily',xdailyList) + '.txt';

end;

function subscribe__manageOne(const ddiskHost:string;var demail:string;const xdailyList,xaddEmail:boolean;var xoutmsg:string):boolean;//09oct2026
var//returns TRUE if list changes, FALSE if list remains the same
   e                            :string;
   f                            :string;
   slen                         :longint32;
   spos                         :longint32;
   sline                        :string;
   s                            :string;
   d                            :tstr8;
   dfound                       :boolean;

   procedure dsave;
   begin

   if (f<>'') then
      begin

      if (d.len32>=1) then io__tofile( f ,@d ,e )
      else                 io__remfile( f );//list is empty -> delete file

      end;

   end;

begin

//defaults
result                          :=false;
d                               :=nil;
xoutmsg                         :='';

//check
if (ddiskHost='') then exit;

//filter email address
demail                          :=email__filteraddress( demail );

if (demail='') then
   begin

   xoutmsg                      :='Your email address is not valid.';

   exit;

   end;

try

//init
f                               :=subscribe__listFilename(ddiskHost,xdailyList);
d                               :=str__new8;
dfound                          :=false;

//.read list from file -> "s"
io__fromfilestr( f , s ,e );

spos                            :=0;
slen                            :=low__len32( s );

//add email address ------------------------------------------------------------

if xaddEmail then
   begin

   //scan each line
   while low__nextline1( s ,sline ,slen ,spos ) do
   begin

   sline                        :=email__filterAddress( sline );

   if strmatch( sline ,demail ) then
      begin

      dfound                    :=true;//email already in list -> no need to save list

      break;//stop

      end;

   if (sline<>'') then
      begin

      d.sadd( sline + #10 );

      end;

   end;//loop

   //set
   case dfound of

   true:xoutmsg                 :='Your email address is already subscribed.';

   else begin

      d.sadd( demail + #10 );//append to list

      dsave;//save changes

      xoutmsg                   :='Your email address has been subscribed.';

      result                    :=true;

      end;

   end;//case

   end

//delete email address ---------------------------------------------------------

else begin

   //scan each line
   while low__nextline1( s ,sline ,slen ,spos ) do
   begin

   sline                        :=email__filterAddress( sline );

   case strmatch( sline ,demail ) of

   true:dfound                  :=true;//email detected -> exlude email from list -> need to save changes

   else if (sline<>'') then d.sadd( sline + #10 );

   end;//case

   end;//loop

   //save changes to list
   case dfound of

   true:begin

      dsave;

      xoutmsg                   :='Your email address has been unsubscribed.';

      result                    :=true;

      end

   else begin

      xoutmsg                   :='Your email address is not currently subscribed.';

      end;

   end;//case

   end;

except;end;

//free
freeobj(@d);

end;

function subscribe__manageList(var xlistCount:longint32;const ddiskHost:string;const xreplaceListWithThisList:string;const xdailyList,xreplaceList,xdeleteList:boolean):string;//09oct2026
var
   e                  :string;
   f                  :string;

   function xfilterList(const s:string):string;
   var
      d               :tstr8;
      spos            :longint32;
      slen            :longint32;
      sline           :string;

   begin

   //defaults
   result             :='';
   d                  :=nil;

   try

   //init
   d                  :=str__new8;
   slen               :=low__len32( s );
   spos               :=0;

   //get
   while low__nextline1( s ,sline ,slen ,spos ) do
   begin

   sline              :=email__filterAddress( sline );

   if (sline<>'') then
      begin

      d.sadd( sline + #10 );

      end;

   end;//loop

   //remove duplicates
   result             :=low__remdup2( d.text ,false ,false ,false );

   except;end;

   //free
   freeobj(@d);

   end;

   procedure xbackup;
   var
      e               :string;

   begin

   //make a backup
   io__copyfile( f ,io__asfolder(io__extractfilepath(f)+'backup') + io__remlastext(io__extractfilename(f)) +'--'+date__str(date__now,true,true)+'.txt' ,e );

   end;

   procedure xfindListCount;
   var
      sline           :string;
      slen            :longint32;
      spos            :longint32;

   begin

   //defaults
   xlistCount         :=0;

   //init
   slen               :=low__len32( result );
   spos               :=0;

   //get
   while low__nextline1( result ,sline ,slen ,spos ) do
   begin

   if (sline<>'') then inc(xlistCount);

   end;//loop

   end;

begin

//defaults
result                          :='';
f                               :=subscribe__listFilename(ddiskHost,xdailyList);
xlistCount                      :=0;

try

//delete list
if xdeleteList then
   begin

   //backup the list before deleting -> excludes "daily"
   if not xdailyList then xbackup;

   //delete list
   io__remfile( f );

   end

//replace list
else if xreplaceList then
   begin

   //backup the list before replacing -> excludes "daily"
   if not xdailyList then xbackup;

   //get
   result             :=xfilterList( xreplaceListWithThisList );

   xfindListCount;

   //replace list
   if (result<>'') then io__tofilestr( f ,result ,e )
   else                 io__remfile( f );//remove empty list

   end

//return list
else begin

   //get
   io__fromfilestr( f ,result ,e );

   //filter
   result             :=xfilterList( result );

   xfindListCount;

   end;

except;end;

end;

function xcodeis__badrequest(xcode:longint):boolean;
begin
result:=(xcode=400) or (xcode=502);
end;

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

   //badrequests - 18jun2025
   if xcodeis__badrequest( log__code(m.wcode,xaltcode) ) then ipsec__incBadrequest(m.hslot);

   //bandwidth per diskhost
   ibytes.cinc2(m.hdiskhost,v);

   //ipsec -> dec sim. conn tracking
   ipsec__incConn(m.hslot,false);

   //ipsec -> update tracking -> don't count admin posts, logged in or not - 07feb2024
   ipsec__incHit(m.hslot);

   if (m.hmethod=hmPOST) and (not strmatch(strcopy1(m.hpath,1,low__len32(iadminpath)),iadminpath)) then
      begin

      if tools__canprefix(m.hname) then ipsec__incPost2(m.hslot)//server tools (tools-*) are tracked using incPost2
      else                              ipsec__incPost(m.hslot);//normal posts (contact.html/email) tracked using incPost

      end;

   ipsec__update(m.hslot);

   //add entry to logs
   if irawlogs then log__addentry(ifastfolder__logs,'',a,xaltcode);

   end;

except;end;
end;

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

procedure xmime_fallback;
const
   xadd_charset_utf8='; charset=utf-8';

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
xadd('tga' ,'image/x-tga');//22feb2025
xadd('tea' ,'image/x-tea');//22feb2025
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

function xmimelist:string;
const
   xleftcol='            ';
var
   a:tobject;
   xlist:tfastvars;
   xnamelist:tdynamicstring;
   xleftcolwidth,p:longint;

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
   str__sadd(@a,vpre+n+strcopy1(xleftcol,1,xleftcolwidth-low__len32(n))+vpost+'   '+vpre+v+vpost+#10);
   end;
begin
//defaults
result:='';
a:=nil;
xlist:=nil;
xnamelist:=nil;
xleftcolwidth:=low__len32(xleftcol);

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
str__sadd(@a,
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

procedure inc__dailyjobs;
begin
low__roll64(idaily_jobs,1);
end;

function hits__extcounts(xext:string):boolean;
begin
result:=(xext='htm') or (xext='html');
end;

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
   'HTTP/1.1 '+intstr32(xcode)+#32+xcodedes(xcode)+#10+
   'Content-Length: '+intstr32(low__len32(xtext))+#10+
   insstr('Location: '+xval+#10,(xcode=307) or (xcode=308) )+//redirection header -> note: only include path+name e.g. "/admin/index.html" as the client insert the host name - 26dec2023
   xcommonheaders('html',m.hka,false,xacceptranges)+
   xmoreheaders+
   #10+
   insstr(xtext,m.hwantdata));

   //set
   m.wcode:=xcode;//for logs
   m.wlen:=str__len(buf);
   m.wheadlen:=frcmin64( sub64(m.wlen, low__inscmp(low__len32(xtext),m.hwantdata) ) ,0);

   //successful
   result:=true;
   end;
except;end;
end;

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
   'HTTP/1.1 '+intstr32(xcode)+#32+xcodedes(xcode)+#10+
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

procedure stm__readdata1(var a:pnetwork);
label
   skipend;
var
   m:tnetbasic;
   buf:pobject;//pointer only
   blen,int1,int2,int3,xpos,xmin,p,p2,len:longint;
   xnewslot,xonce__forwarded_for,bol1:boolean;
   str1,n,v,v2:string;

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
   blen:=str__len32(buf);
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
   xlen:=frcrange32(xhlen,0,str__len32(buf));
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

   procedure xreadcookies(var x:string);
   var
      xlen,lp,p:longint;
      n,v:string;
      c:byte;
   begin
   //init
   x:=x+';';
   xlen:=low__len32(x);

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
   bubbles__inc_daily_bandwidth(len);

   //information vars - set once
   if m.vonce then
      begin
      m.vonce:=false;
      m.vstarttime:=ms64;
      case ireverseproxy of
      false:m.hip:=intstr32(a.sock_ip4.b0)+'.'+intstr32(a.sock_ip4.b1)+'.'+intstr32(a.sock_ip4.b2)+'.'+intstr32(a.sock_ip4.b3);//use socket's ip by default
      true:m.hip:='0.0.0.0';//we don't know the client's ip address till we read it from the header
      end;
      a.infolastip:=m.hip;//06apr2024
      a.used:=add64(a.used,1);
      //.request load tracking
      if (irequestrate0<maxint) then inc(irequestrate0);
      end;

   //add to buffer
   str__addrec(buf,@ibuffer,len);
   blen:=str__len32(buf);

   //track upload bandwidth #1 -> can only do this once a "hslot" is set
   if (m.hslot>=0) then ipsec__incBytes(m.hslot,len);//18aug2024: fixed incorrect bandwidth tracking -> was str__len(buf)

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

      low__roll64(idaily_requests,1);//daily request counter - 20feb2025

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
            for p:=low__len32(v) downto 1 do if (strbyte1(v,p)=ssSlash) then
               begin
               m.hpath:=strcopy1(v,1,p);
               m.hname:=strcopy1(v,p+1,low__len32(v));
               if (m.hname<>'') then
                  begin
                  for p2:=1 to low__len32(m.hname) do if (strbyte1(m.hname,p2)=ssquestion) then
                     begin
                     m.hgetdat:=strcopy1(m.hname,p2+1,low__len32(m.hname));
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
               for p:=1 to low__len32(m.hpath) do
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
                        m.hpath:=strcopy1(m.hpath,p,low__len32(m.hpath));
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

         for p:=1 to low__len32(m.hhost) do
         begin
         int1:=byte(m.hhost[p-1+stroffset]);
         case int1 of
         ssLSquarebracket:inc(int3);//within an IPv6 host which has format "[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443" from an input such as this "https://[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443/"
         ssRSquarebracket:dec(int3);
         ssColon,ssSlash:begin
            if (int3=0) then
               begin
               if (int1=ssColon) then m.hport:=restrict32(strint64(strcopy1(m.hhost,p+1,low__len32(m.hhost))));
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
      m.hslot:=ipsec__trackb(m.hip,xnewslot);//we should have a valid client ip address by this stage
      if xnewslot then low__roll64(idaily_visitors,1);//21feb2025
      ipsec__incBytes(m.hslot,blen);

      if inewvisitor.new(m.hip) then low__roll64(idaily_newvisitors,1);//07apr2025

      //.are we logged into the admin panel?
      if strmatch(strcopy1(m.hpath,1,low__len32(iadminpath)),iadminpath) and xextractsessionname(m.hpath,str1) then
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

      //.user-agent mask - 09aug2025
      if (not m.vsessvalid) and (iua_mask<>'') and filter__matchlist(m.hua,iua_mask) and ipsec__incBanByMask(m.hslot) and header__make4(a,403,true,true,true) then goto skipend;

      //.IP address mask - 09aug2025
      if (not m.vsessvalid) and (iip_mask<>'') and filter__matchlist(m.hip,iip_mask) and ipsec__incBanByMask(m.hslot) and header__make4(a,403,true,true,true) then goto skipend;

      //.not this link "Bad Bot" detection - 07apr2025
      if (not m.vsessvalid) and (inotthislink<>'') and strmatch(m.hname,inotthislink) and ipsec__incNotThisLink(m.hslot) and header__make4(a,403,true,true,true) then goto skipend;

      //.too many simultaneous connections -> don't enforce limit when using admin panel
      if (not m.vsessvalid) and ipsec__incConn(m.hslot,true) and header__make4(a,503,true,true,true) then goto skipend;

      //IMPORTANT: The header was too big, so we must abort here
      if m.htoobig and header__make4(a,431,true,true,true) then goto skipend;

      //.remove header from buffer
      if (m.clen=0) then str__softclear2(buf,ibufferlimit) else str__del3(buf,0,m.hlen);

      //.module support and extended data support
      str1:=strlow(m.hname);
      if tools__findbypage2(m.vsessvalid, str1, int1) then
         begin
         m.hmodule_index:=int1;
         tools__specialvals(int1,m.vsessvalid,str1,m.hmodule_uploadlimit,m.hmodule_multipart,m.hmodule_canmakeraw,m.hmodule_readpost);
         end;

      //.upload size limit check -> do before receiving large data -> normal=small and admin=large -> content too large 413
      if (m.clen>low__aorb(imaxuploadsize_normal+m.hmodule_uploadlimit,imaxuploadsize_admin+m.hmodule_uploadlimit,m.vsessvalid)) and header__make4(a,413,true,true,true) then goto skipend;
      end;//end of "reading header"


   //.actual upload size check -> module can modify the upload limit - 17aug2024
   if (str__len(buf)>low__aorb(imaxuploadsize_normal+m.hmodule_uploadlimit,imaxuploadsize_admin+m.hmodule_uploadlimit,m.vsessvalid)) and header__make4(a,413,true,true,true) then goto skipend;


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

function xcolumnRight(x:string):string;
begin
result:=low__rcolumn(x,17);
end;

function xminiconsole:string;
begin

result      :=

 '<div class="console2 miniinfo">RAM '+low__mbauto(bytes__RAM,true)+' &nbsp; &nbsp; '+
 'Files Cached (All Sites) '+k64(iramfilescached)+' of '+k64(iramfilecount)+'</div>' +
 #10;

end;

function xpowerlevel:string;
var
   v,p:longint;
begin
result:='<label for="powerlevel">Power Level </label><select id="powerlevel" name="powerlevel">';
for p:=1 to (ipowerlimit div 5) do
begin
v:=frcrange32(p*5,1,ipowerlimit);
result:=result+'<option value="'+intstr32(v)+'"'+insstr(' selected',v=ipowerlevel)+'>'+intstr32(v)+'%</option>';
end;//p
result:=result+'</select>';
end;

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

procedure stm__makereply2(var a:pnetwork);
label
   skipend;
var
   m:tnetbasic;//pointer only
   buf:pobject;//pointer only
   mtmp:tnetbasic;
   xoldramlimit,xoldport,int1:longint;
   xoldthreshold:comp;
   xsearch__addurls,hname_low,xloginstatus,xpassstatus,xcmd,xcmd2,str1,str2,str3:string;
   xalongsideexe,xmustreload,bol1:boolean;

   function xbold(const x:string):string;
   begin
   if (x<>'') then result:='<span class="bold">'+x+'</span>' else result:='';
   end;

   function xsmall(const x:string):string;
   begin
   if (x<>'') then result:='<span style="display:inline;font-size:70%">'+x+'</span>' else result:='';
   end;

   function xsmall2(const x:string):string;
   begin
   if (x<>'') then result:=#32+'<span style="display:inline;font-size:70%">'+x+'</span><br>' else result:='';
   end;

   function xrefreshcookie:string;//periodicially update admin session cookie
   begin
   if m.vsessvalid and (sub64(ms64,isessioncookietime[m.vsessindex])>=icookietimeout) then result:=m.hcookie_k else result:='';
   end;

   function xheadonly(xcode:longint;xacceptranges:boolean):boolean;
   begin
   result:=true;//pass-thru
   try
   header__make3(a,xcode,xacceptranges,0,date__now,false,false,'');
   m.writing:=true;
   except;end;
   end;

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

   function xwriting(xreset_buf8:boolean):boolean;
   begin
   result:=true;//pass-thru
   try
   if xreset_buf8 then str__softclear2(@ibuf2,ibufferlimit);
   m.wlen:=str__len(buf);
   m.writing:=true;
   except;end;
   end;

   procedure xreadpost;
   label
      redo,skipend;
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
         //only Admin pages are permitted to upload a multi-part form OR "module page" - 17aug2024
         if (not m.vsessvalid) and (m.hmodule_index<0) then goto skipend;

         //init
         xlog:=str__new9;
         xoutdata:=str__new9;
         xpos:=0;
         xcmd:='';
         xsite:='';

         //get
         while true do
         begin
         redo:
         if not str__multipart_nextitem(buf,xpos,xboundary,xname,xfilename,xcontenttype,@xoutdata) then break;


         //module based uploading -----------------------------------------------
         if (m.hmodule_index>=0) or (xcmd='compose') then//03mar2025
            begin
            //store files as "file.data1...file.dataN" - 03apr2025, 17aug2024
            if (xfilename<>'') then
               begin
               inc(xokcount);
               ivars.s['file.name'+intstr32(xokcount)]:=xfilename;
               ivars.s['file.data'+intstr32(xokcount)]:=str__text(@xoutdata);
               end
            //copy over values like "cmd" etc
            else if (xname<>'') then ivars.s[xname]:=str__text(@xoutdata);
            //loop for more
            goto redo;
            end;


         //managed file uploading ----------------------------------------------
         //var
         if (xname<>'') and (xfilename='') then ivars.s[xname]:=str__text(@xoutdata);

         //cmd
         if (xfilename='') and strmatch('cmd',xname) then
            begin
            xcmd:=strlow(str__text(@xoutdata));
            //get
            if (strcopy1(xcmd,1,14)='manage.upload.') then
               begin
               xsite:=io__extractfilename(strcopy1(xcmd,15,low__len32(xcmd)));
               ivars.s['site']:=xsite;
               net__decodestr(xsite);
               xcmd:='manage.upload';
               end;
            end;

         //decide
         if (xfilename<>'') and (xcmd='manage.upload') and (xsite<>'') then
            begin
            if strmatch(strcopy1(xsite,1,low__len32(idefaultdisksite)),idefaultdisksite) and idom.b[xsite] then//site must exist
               begin
               n:=io__extractfilename(xfilename);
               if (n<>'""') then
                  begin
                  case io__tofile64(io__asfolder(ifastfolder__root+xsite)+n,@xoutdata,e) of
                  true:begin
                     inc(xtotal);
                     inc(xokcount);
                     str__sadd(@xlog,'[ OK ]  '+xcolumnRight(k64(xoutdata.len))+'  '+n+#10);
                     end;
                  false:begin
                     inc(xtotal);
                     inc(xerrcount);
                     str__sadd(@xlog,'[FAIL]  '+n+#10);
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
      end
   else if (m.hgetdat<>'') then ivars.nettext:=m.hgetdat;
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
xsearch__addurls:='';

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
   if ihitpng.sfound8(m.hdiskhost,@ibuf2,false,int1) then xhead3(200,false,@ibuf2,date__now,false,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end
//".totalhits.png" -> for ALL domains combined
else if (hname_low='.totalhits.png') then
   begin
   if ihitpng.sfound8('total',@ibuf2,false,int1) then xhead3(200,false,@ibuf2,date__now,false,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end
//".bubbles.png"
else if (hname_low='.bubbles.png') then
   begin
   if (ibubbles_png.len>=1) then xhead3(200,false,@ibubbles_png,iloaddate,true,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end
//.raw output -> full binary support with "post/get" decoding support - 17aug2024
//else if tools__findbypage2(false,hname_low,int1) and tools__canmakeraw2(int1,false,hname_low) then
else if (m.hmodule_index>=0) and (m.hmodule_canmakeraw) then
   begin
   if m.hmodule_readpost then xreadpost;
   if tools__makepage2(m.hmodule_index,false,hname_low,ivars,@ibuf2,bol1) then xhead3(200,false,@ibuf2,date__now,false,m.hwantdata) else xheadonly(404,false);
   goto skipend;
   end;

//admin ------------------------------------------------------------------------
if strmatch(strcopy1(m.hpath,1,low__len32(iadminpath)),iadminpath) then
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

      ishutidle                 :=ivars.checked['shutidle'];
      xalongsideexe             :=ivars.checked['alongsideexe'];
      ireverseproxy             :=ivars.checked['reverseproxy'];
      isummarynotice            :=ivars.checked['summary.notice'];
      isubscribenotice          :=ivars.checked['subscribe.notice'];//09oct2026
      isubscribeeachnotice      :=ivars.checked['subscribe.each.notice'];//09oct2026
      iquotanotice              :=ivars.checked['quota.notice'];
      ireloadnotice             :=ivars.checked['reload.notice'];
      icsp                      :=ivars.checked['csp'];
      inorefdown                :=ivars.checked['norefdown'];
      icache                    :=ivars.checked['cache'];
      ilivestats                :=ivars.checked['livestats'];
      irawlogs                  :=ivars.checked['rawlogs'];

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

      ipsec__setvals(ivars.i['scanfor'],ivars.i['banfor'],ivars.i['simconnlimit'],ivars.i['postlimit'],ivars.i['postlimit2'],ivars.i['badlimit'],ivars.i['hitlimit'],ivars.i['badreqlimit'],ivars.i['badmaillimit'],mult64(ivars.c['datalimit'],1024000));
      inotthislink :=stripwhitespace_lt(ivars.s['notthislink']);
      imail_mask   :=stripwhitespace_lt(ivars.s['mailmask']);//19jun2025
      iua_mask     :=stripwhitespace_lt(ivars.s['ua.mask']);//09aug2025
      iip_mask     :=stripwhitespace_lt(ivars.s['ip.mask']);//09aug2025

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

   if (xcmd='subscribe') then
      begin

      isubscribe_question :=ivars.checked['subscribe.question'];//08oct2026
      isubscribe_allow    :=ivars.checked['subscribe.allow'];

      //.trigger a save event
      imustsavesettings:=true;

      end;

   if (xcmd='mail') then
      begin
      imail_allow         :=ivars.checked['mail.allow'];
      imail_domain        :=ivars.s['mail.domain'];
      imail_sender.osenderdomain:=imail_domain;
      imail_fromaddress   :=mail__extractaddress(ivars.s['mail.fromaddress']);
      imail_sizelimit     :=app__ivalset('mail.sizelimit',ivars.i['mail.sizelimit']);
      imail_sender.dnslist:=ivars.s['mail.dns'];
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
         else if (low__len32(str1)<5) then xpassstatus:='<div class="bad">The new password is too short.  It must be 5 characters or more.</div>'
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
      iconsolerate:=app__ivalset('consolerate',strint32(strcopy1(xcmd,9,low__len32(xcmd))));
      //.trigger a save event
      imustsavesettings:=true;
      end;

   //port - detect port change and redirect to new page
   if (xoldport<>iport) then
      begin
      imustport:=true;//tell server to load new port immediately
      imustcloseall:=true;//close all connections
      if xheadonly2(307,false,'http'+insstr('s',iport=443)+'://'+m.hhost+insstr(':'+intstr32(iport),iport<>80)+iadminpath+m.vsessname+'/'+hname_low,'','','') then goto skipend;
      end;

   //modules support
   //if tools__findbypage2(true,hname_low,int1) and tools__readvals(int1,hname_low,xcmd,ivars) then imustsavesettings:=true;
   if (m.hmodule_index>=0) and tools__readvals(m.hmodule_index,hname_low,xcmd,ivars) then imustsavesettings:=true;


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

   //live-status.html ----------------------------------------------------------
   else if (hname_low='live-status.html') then//21feb2025
      begin
      if xheadonly2(200,false,'',xlivestatus(0),'',xrefreshcookie) then goto skipend;
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

      '<div><input name="subscribe.notice" type="checkbox" '+insstr('checked',isubscribenotice)+'>Bubbles daily subscribe notices (delivered to inbox)</div>'+#10+
      '<div><input name="subscribe.each.notice" type="checkbox" '+insstr('checked',isubscribeeachnotice)+'>Bubbles subscribe notices (delivered per request to inbox)</div>'+#10+

      '<div><input name="reload.notice" type="checkbox" '+insstr('checked',ireloadnotice)+'>Bubbles reload notices (boot/reboot/reload - delivered to inbox)</div>'+#10+
      '<div><input name="shutidle" type="checkbox" '+insstr('checked',ishutidle)+'>Shut idle connections (2m)</div>'+#10+
      '<div><input name="livestats" type="checkbox" '+insstr('checked',ilivestats)+'>Live stats via OS console window</div>'+#10+
      '</div>'+#10+

      '<div class="grid1">'+#10+
      '<div></div>'+#10+

      '<div><input name="alongsideexe" type="checkbox" '+insstr('checked',ialongsideexe)+'>Folders alongside EXE - '+xbold('use with caution')+' as this option will change the location of your outbox, inbox, trash, logs and disk site(s) folders.<br>'+
       '<br>'+
       '<div style="font-size:70%;"><span class="underline">Not Ticked (default mode)</span>:<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'outbox<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'inbox<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'trash<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+'logs<br>'+
       net__encodeforhtmlstr(app__subfolder2('',false))+idefaultdisksite+'*<br>'+
       '<br>'+
       '<span class="underline">Ticked</span>:<br>'+
       net__encodeforhtmlstr(app__subfolder2('',true))+'outbox<br>'+
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
      'When a client IP exceeds the '+xbold('hit limit')+', '+xbold('bandwidth limit')+', '+xbold('post limit')+', '+xbold('post 2 limit')+' (server tools), '+xbold('bad login limit')+', '+xbold('bad request limit')+' or the '+xbold('bad mail limit')+' within the specified '+xbold('scan for')+' time period,'+' they are automatically banned and denied access to all site(s) and resources hosted by '+'Bubbles for a time period specified by '+xbold('ban for')+'.<br><br>When the '+xbold('ban for')+' time period elapses, they are automatically removed from the "ban list" and again allowed access to the site(s) and resources.  '+'However, a client exceeding the '+xbold('max. simultaneous connections')+' limit is not banned, but restricted.<br>'+#10+
      '<br>'+#10+
      '<form class="block" method=post action="limits.html">'+
      '<div class="grid2">'+#10+
      '<div class="inlineblock">'+xbold('Scan for')+xsmall2('in minutes (60..N, 1,440=day)')+'<input class="text" name="scanfor" type="text" value="'+k64(ipsec__scanfor)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Ban for')+xsmall2('in minutes (60..N, 1,440=day, 10,080=week)')+'<input class="text" name="banfor" type="text" value="'+k64(ipsec__banfor)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Hit limit')+xsmall2('(0=unlimited or 100..N)')+'<input class="text" name="hitlimit" type="text" value="'+k64(ipsec__hitlimit)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Bandwidth limit')+xsmall2('in megabytes (0=unlimited or 1..N)')+'<input class="text" name="datalimit" type="text" value="'+k64(div64(ipsec__datalimit,1024000))+insstr(' Mb',ipsec__datalimit>=1)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Post limit')+xsmall2('(0=unlimited or 1..N, e.g. limit the number of contact form submissions, subscribe/unsubscribe requests, and/or emails sent by an IP address)')+'<input class="text" name="postlimit" type="text" value="'+k64(ipsec__postlimit)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Post 2 limit')+xsmall2('(0=unlimited or 1..N, e.g. limit the number of server tool submisions (e.g. Icon Maker) sent by an IP address)')+'<input class="text" name="postlimit2" type="text" value="'+k64(ipsec__postlimit2)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Bad login limit')+xsmall2('(0=unlimited or 10..N, e.g. limit the number of unsuccessful Admin login attempts)')+'<input class="text" name="badlimit" type="text" value="'+k64(ipsec__badlimit)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Bad request limit')+xsmall2('(0=unlimited or 1..N, e.g. limit the number of 502 and 400 codes)')+'<input class="text" name="badreqlimit" type="text" value="'+k64(ipsec__badreqlimit)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Max. simultaneous connections')+xsmall2('(0=unlimited or 1..N)')+'<input class="text" name="simconnlimit" type="text" value="'+k64(ipsec__connlimit)+'"></div>'+#10+
      '<div class="inlineblock">'+xbold('Bad mail limit')+xsmall2('(0=unlimited or 1..N, e.g. limit the number of emails that don''t match the inbound mail mask below)')+'<input class="text" name="badmaillimit" type="text" value="'+k64(ipsec__badmaillimit)+'"></div>'+#10+
      '</div>'+#10+

      '<br>'+#10+
      '<div class="inlineblock">'+xbold('Mail mask')+' ('+low__aorbstr('Off','On',imail_mask<>'')+')<br><div style="display:block;font-size:70%">A set of one or more complex masks to filter acceptable inbound email addresses, e.g. "*@blaizenterprises.com" (without quotes) the leading asterisk permits all '+'emails addressed to @blaizenterprises.com, but bans emails with a different domain name.  Emails which fail the mask filter test count towards the "'+xbold('Bad mail')+'" value above.  Separate multiple masks with the semi-colon "'+fesep+'" character, e.g. "*@blaizenterprises.com;*blaiz*.com" (without quotes).  Upto to 2 "*" asterisks permitted per mask.  Leave mask filter blank to turn off/disable and allow all emails through.</div><input class="text"'+insstr(' style="background-color:#0f02;"',imail_mask<>'')+' name="mailmask" type="text" value="'+net__encodeforhtmlstr(imail_mask)+'"></div>'+#10+

      '<br>'+#10+
      '<br>'+#10+
      '<div class="inlineblock">'+xbold('User-Agent mask')+' ('+low__aorbstr('Off','On',iua_mask<>'')+')<br><div style="display:block;font-size:70%">A set of one or more complex masks to exclude inbound http user-agents, e.g. "*badbot3*" (without quotes) '+' which immediately bans any IP address that matches the pattern.  Separate multiple masks with the semi-colon "'+fesep+'" character, e.g. "*badbot3*;*reallybadbot4*" (without quotes).  Upto to 2 "*" asterisks permitted per mask.  Leave mask filter blank to turn off/disable and allow all user-agents through.'+'  Once the IP address of a user-agent is banned, it remains banned for the "'+xbold('Ban for')+'" time period above.</div><input class="text"'+insstr(' style="background-color:#0f02;"',iua_mask<>'')+' name="ua.mask" type="text" value="'+net__encodeforhtmlstr(iua_mask)+'"></div>'+#10+

      '<br>'+#10+
      '<br>'+#10+
      '<div class="inlineblock">'+xbold('IP Address mask')+' ('+low__aorbstr('Off','On',iip_mask<>'')+')<br><div style="display:block;font-size:70%">A set of one or more complex masks to exclude inbound http IP addresses, e.g. "10.*.0.*" (without quotes) '+' which immediately bans any IP address that matches the pattern.  Separate multiple masks with the semi-colon "'+fesep+'" character, e.g. "10.*.0.*;127.0.0.1" (without quotes).  Upto to 2 "*" asterisks permitted per mask.  Leave mask filter blank to turn off/disable and allow all IP addresses through.'+'  Once an IP address is banned, it remains banned for the "'+xbold('Ban for')+'" time period above.</div><input class="text"'+insstr(' style="background-color:#0f02;"',iip_mask<>'')+' name="ip.mask" type="text" value="'+net__encodeforhtmlstr(iip_mask)+'"></div>'+#10+

      '<br>'+#10+
      '<br>'+#10+
      '<div class="inlineblock">'+xbold('Bad bot')+' prevention ('+low__aorbstr('Off','On',inotthislink<>'')+')<br><div style="display:block;font-size:70%">Type a filename, that when requested site-wide will trigger an immediate'+' ban of the IP address for the "'+xbold('Ban for')+'" time period above.  Name only, no path, e.g. "notthisfile.html" (excluding quotes).  Leave blank to turn off/disable.  Bait bad bots by including a reference to this file '+' in your robots.txt file.</div><input class="text"'+insstr(' style="background-color:#0f02;"',inotthislink<>'')+' name="notthislink" type="text" value="'+net__encodeforhtmlstr(inotthislink)+'"></div>'+#10+

      xvsep+
      '<input name="cmd" type="hidden" value="limits"><input class="button" type=submit value="Save"></form>'+#10+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //compose.html --------------------------------------------------------------
   else if (hname_low='compose.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2b('compose',xsymbol('compose')+'Compose','nobotmargin')+

      xvsep+
      xcompose(a,'compose',xcmd,xcmd2)+

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
      str1:=strcopy1(hname_low,8,low__len32(hname_low));
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
      str1:=strcopy1(hname_low,8,low__len32(hname_low));
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
      str1:=strcopy1(hname_low,6,low__len32(hname_low));
      net__decodestr(str1);
      if (io__readfileext_low(str1)='html') then log__makereport(a,ifastfolder__logs+io__remlastext(str1));//make log report when requesting ".html" version of log
      xstreamstart(a,wsmDisk,ifastfolder__logs+str1,false);//don't mark logs as cacheable
      goto skipend;
      end


   //ban.html ------------------------------------------------------------------
   else if (hname_low='ban.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart1(a,'',true,1100)+

      xh2b('ban',xsymbol('ban')+'Banned List','nobotmargin')+
      xvsep+
      xinfo2(hname_low,'banlist')+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //conn.html ------------------------------------------------------------------
   else if (hname_low='conn.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart1(a,'',true,1000)+

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
      xhtmlstart1(a,insstr('<meta http-equiv="refresh" content="'+intstr32(iconsolerate)+'">'+#10,iconsolerate>=1),true,1000)+

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
      '<div><input name="contact.question" type="checkbox" '+insstr('checked',icontact_question)+'>Protect against mass spam with Spam Guard.  Presents a simple math question on the contact form.  A correct answer stores the message in the Inbox, and an incorrect answer returns an error.</div>'+#10+
      '<div class="inlineblock">1. '+net__encodeforhtmlstr(icontact_def_ok)+'<br><input class="text" name="contact.ok" type="text" value="'+net__encodeforhtmlstr(icontact_ok)+'"></div>'+#10+
      '<div class="inlineblock">2. '+net__encodeforhtmlstr(icontact_def_fail)+'<br><input class="text" name="contact.fail" type="text" value="'+net__encodeforhtmlstr(icontact_fail)+'"></div>'+#10+
      '<div class="inlineblock">3. '+net__encodeforhtmlstr(icontact_def_off)+'<br><input class="text" name="contact.off" type="text" value="'+net__encodeforhtmlstr(icontact_off)+'"></div>'+#10+
      '</div>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="contact"><input class="button" type=submit value="Save"></form>'+#10+


      xh2('subscribe','Subscribe Settings')+
      '<form class="block" method=post action="contact.html#subscribe">'+
      '<div class="grid2">'+#10+
      '<div><input name="subscribe.allow" type="checkbox" '+insstr('checked',isubscribe_allow)+'>Allow Subscribe/Unsubscribe Requests (use subscribe.html and unsubscribe.html).</div>'+#10+
      '<div><input name="subscribe.question" type="checkbox" '+insstr('checked',isubscribe_question)+'>Protect against mass spam with Spam Guard.  Presents a simple math question on the subscribe form.  A correct answer processes the subscribe request, and an incorrect answer returns an error. An unsubscribe request does not require Spam Guard.</div>'+#10+
      '</div>'+#10+
      xvsep+
      '<input name="cmd" type="hidden" value="subscribe"><input class="button" type=submit value="Save"></form>'+#10+


      xh2('mail','SMTP Mail Server')+
      '<form class="block" method=post action="contact.html#mail">'+
      '<div class="grid2">'+#10+
      '<div><input name="mail.allow" type="checkbox" '+insstr('checked',imail_allow)+'>Allow emails to be received on port 25 and stored in the inbox.</div>'+#10+
      '<div>Max Email Size (1..50 Mb)<br><input class="text" name="mail.sizelimit" type="text" value="'+k64(imail_sizelimit)+' Mb"></div>'+#10+
      '<div class="inlineblock">Mail domain name to report to email senders<br><input class="text" name="mail.domain" type="text" value="'+net__encodeforhtmlstr(imail_domain)+'"></div>'+#10+
      '<div class="inlineblock">From email address (e.g. yourname@yourdomain.com)<br><input class="text" name="mail.fromaddress" type="text" value="'+net__encodeforhtmlstr(imail_fromaddress)+'"></div>'+#10+
      '</div>'+#10+
      '<div style="margin-top:1rem;">DNS Servers (for sending email) one IPv4 address per line, e.g. 8.8.8.8, or leave blank to use Google servers<br><textarea class="textbox" rows="6" wrap="no" name="mail.dns">'+net__encodeforhtmlstr(imail_sender.dnslist)+'</textarea></div>'+#10+

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

   //tools.html -------------------------------------------------------------
   else if (hname_low='tools.html') then
      begin
      if xheadonly2(200,false,'',
      xhtmlstart(a,true)+

      xh2('tools',xsymbol('tools')+'Tools')+
      tools__listings+

      xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end

   //module pages --------------------------------------------------------------
   else if tools__canprefix(hname_low) and (m.hmodule_index>=0) and tools__makepagestr2(m.hmodule_index,true,hname_low,ivars,str1,bol1) then
      begin
      //html or binary reply data
      case bol1 of
      true :if xheadonly2(200,false,'',str1,'',xrefreshcookie)                                then goto skipend;
      else  if xheadonly2(200,false,'',xhtmlstart(a,true)+str1+xhtmlfinish,'',xrefreshcookie) then goto skipend;
      end;
      end


   //(admin page not found) ----------------------------------------------------
   else if xheadonly2(404,false,'','','','') then goto skipend;
   end;


//public access area (front facing file system) --------------------------------
//decode path and filename
str1                  :=m.hpath+m.hname;
if (hname_low='contact.html') or (hname_low='subscribe.html')  or (hname_low='unsubscribe.html') or (m.hmodule_index>=0) then xreadpost;

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

function bubbles__daily_bandwidth_exceeded:boolean;
begin
result:=idaily_bandwidth_exceeded;
end;

procedure bubbles__inc_daily_bandwidth(xlen:comp);
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

   procedure xsent(xlen:longint);
   begin
   //check
   if (xlen<=0) then exit;
   //daily bandwidth counter
   bubbles__inc_daily_bandwidth(xlen);
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
blen:=str__len32(buf);
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
   blen:=str__len32(buf);
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
         case block64__fastinfo32(buf,m.wbufsent,smem,smin,smax) and str__splice32(buf,m.wbufsent,len,dmem,dlen) of
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

procedure stm__readmail(var a:pnetwork);//implements the SMTP protocol - 20feb2025: disable connection reuse for email, 11mar2024: updated to 40K search
label
   skipend;
var
   m:tnetbasic;
   buf:pobject;//pointer only
   smin,smax,int1,bp,p,blen,len:longint;
   smem:pdlbyte;
   str1,xline,xcmd:string;
   xnewslot:boolean;

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
   for p:=0 to (str__len32(buf)-1) do
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

   function xendofdata:boolean;
   var
      xlen,p:longint;
      v,v1,v2:byte;
   begin
   //defaults
   result:=false;

   try
   //init
   xlen:=str__len32(buf);
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

   function xmaildomain:string;
   begin
   result:=strdefb(imail_domain,'localhost');
   end;

   procedure xreply(x:string);
   begin
   str__clear(buf);
   str__sadd(buf,x);
   m.mdata:=false;
   m.wsent:=0;
   m.writing:=true;
   end;

   procedure xreadmode;
   begin
   str__clear(buf);
   m.writing:=false;
   end;

   function xfindsubject__raw:string;
   var
      xlen,p:longint;
      c,lc:byte;
   begin
   //defaults
   result:='';

   try
   //init
   xlen:=frcmax32(str__len32(buf),40000);//search first 40K of message only, 11mar2024: 40k search instead of previous 7K
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
      for p:=1 to low__len32(result) do if (result[p-1+stroffset]=#10) or (result[p-1+stroffset]=#13) then
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

   function xsave:boolean;
   begin
   result:=false;try;result:=mail__writemsg(buf,strdefb(xfindsubject__raw,'(no subject)'),io__makefolder2(xinbox__folder('inbox',false)));except;end;

   if result then
      begin
      //daily email count tracker - 21feb2025
      low__roll64(idaily_email,1);
      end;
   end;

   function xreset(xfirst:boolean):boolean;
   begin
   result:=true;

   //.client is banned (rate limited) -> abort right now
   if ipsec__banned(m.hslot) then
      begin
      xlogrequest_smtp(a,403);
      a.mustclose:=true;
      result:=false;
      end;

   //.too many simultaneous connections
   if ipsec__incConn(m.hslot,true) then
      begin
      xlogrequest_smtp(a,503);
      a.mustclose:=true;
      result:=false;
      end;

   //.reset bandwidth tracking
   if result and (not xfirst) then
      begin
      m.wfilesize:=0;
      a.used:=add64(a.used,1);
      end;
   end;

begin
try
//check
if not net__recinfo(a,m,buf) then exit;


//information vars - set once
if m.vonce then
   begin
   //clear
   m.vonce       :=false;
   m.vstarttime  :=ms64;
   a.used        :=add64(a.used,1);
   m.hip         :=intstr32(a.sock_ip4.b0)+'.'+intstr32(a.sock_ip4.b1)+'.'+intstr32(a.sock_ip4.b2)+'.'+intstr32(a.sock_ip4.b3);
   a.infolastip  :=m.hip;//06apr2024
   m.hreferer    :='';//flush previous value when connection is left open - 19jun2025
   m.hua         :='';//flush previous value when connection is left open - 19jun2025

   //.ipsec security tracking
   m.hslot:=ipsec__trackb(m.hip,xnewslot);//we should have a valid client ip address by this stage
   if xnewslot then low__roll64(idaily_visitors,1);//21feb2025

   if inewvisitor.new(m.hip) then low__roll64(idaily_newvisitors,1);//07apr2025

   //.reset
   if not xreset(true) then goto skipend;

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
      blen:=str__len32(buf);
      bp:=restrict32(m.wsent);
      smin:=-1;
      smax:=-2;
      for p:=0 to (len-1) do
      begin
      if (bp<blen) then
         begin
         if (bp>smax) then block64__fastinfo32(buf,bp,smem,smin,smax);
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
         bubbles__inc_daily_bandwidth(int1);
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
      bubbles__inc_daily_bandwidth(len);

      //add to buffer
      str__addrec(buf,@ibuffer,len);

      //size limit check
      if ((str__len32(buf) div 1024000)>imail_sizelimit) then
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
            if xsave then
               begin
               xreply('250 OK'+rcode);
               xlogrequest_smtp(a,250);
               end
            else
               begin
               xreply('554 Transaction Failed'+rcode);
               xlogrequest_smtp(a,554);
               end;

            //.reset - 21feb2025
            if not xreset(false) then goto skipend;
            end;

         end
      //decide
      else if xhaveline then
         begin
         if      (xcmd='helo') then
            begin
            low__roll64(idaily_requests,1);//21feb2025
            xreply('250 '+xmaildomain+' Ready'+rcode);
            end
         else if (xcmd='ehlo') then
            begin
            low__roll64(idaily_requests,1);//21feb2025
            xreply('250-'+xmaildomain+' Ready'+rcode+'250 SIZE '+intstr64(mult64(imail_sizelimit,1024000))+rcode);
            end
         else if (xcmd='mail') then
            begin
            if (m.hua='') then m.hua:=swapcharsb(strcopy1(xline,11,low__len32(xline)),'"','''');//1st one only
            xreply('250 OK'+rcode);//mail from:
            end
         else if (xcmd='rcpt') then
            begin
            //.1st to address
            if (m.hreferer='') then m.hreferer:=swapcharsb(strcopy1(xline,9,low__len32(xline)),'"','''');//1st one only

            //Inbound Email Filter -> security check -> ensure "to: address" is within the specified email mask
            if (imail_mask<>'') then
               begin

               //remove leading "<" and trailing ">" brackets from email address
               str1:=m.hreferer;
               if (strfirst(str1)='<') then strdelfirst(str1);
               if (strlast(str1) ='>') then strdellast(str1);

               //compare using complex mask -> if email not within complex mask then discard email AND optionally ban the mail sender
               if not filter__matchlist(str1,imail_mask) then
                  begin
                  ipsec__incBadmail(m.hslot);//increment the "Bad mail" counter for this sender's IP address - 19jun2025
                  xlogrequest_smtp(a,403);
                  a.mustclose:=true;
                  goto skipend;
                  end;

               end;

            //OK
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

function spamGuard__makeQuestion(var xquestion:string):boolean;
var
   xindex                       :longint32;
   v1                           :longint32;
   v2                           :longint32;

begin

//defaults
result                          :=false;
xindex                          :=ispamGuard_index;
xquestion                       :='';

//inc
inc(ispamGuard_index);

if (ispamGuard_index>high(ispamGuard_answer)) then
   begin

   ispamGuard_index             :=0;

   end;

//make question
v1                              :=1 + random(100001);//1..100,000
v2                              :=1 + random(10);//1..10
xquestion                       :='What is '+k64(v1)+' + '+k64(v2)+'?';
ispamGuard_answer[xindex]       :=v1 + v2;//important: answer is always 1 or more

//successful
result                          :=true;

end;

function spamGuard__checkAnswer(const xanswer:longint32):boolean;
var
   p                            :longint32;

begin

//defaults
result                          :=false;

//get
if (xanswer>=1) then
   begin

   for p:=0 to high(ispamGuard_answer) do
   begin

   if (xanswer=ispamGuard_answer[p]) then
      begin

      //reset slot -> only reset 1 slot in case there are 2+ slots with same answers representing 2+ separate requests - 09oct2026
      ispamGuard_answer[p]      :=0;

      //answer is correct
      result                    :=true;

      //stop
      break;

      end;

   end;//p

   end;

end;

function bytes__RAM:longint64;//09oct2026
var
   p        :longint32;
   n        :string;
   v1       :longint64;
   v2       :longint64;

begin

result      :=irambytes;

for p:=0 to max32 do
begin

if tools__bytes(p,n,v1,v2) then result    :=add64( result ,v1 )
else                            break;//last tool -> stop checking

end;//p

end;

function xmakehelp(xclaudehelp:boolean):string;
const
   //compressed (.zip) version of plain text help document - 09oct2026
   xhelpdata
:array[0..19931] of byte=(
120,1,236,189,91,115,27,199,178,231,251,142,79,209,7,19,251,152,244,18,72,2,188,73,180,173,25,74,162,44,198,210,109,72,106,123,28,222,142,21,32,0,146,176,112,219,104,64,20,253,48,159,125,126,255,204,170,238,106,16,144,96,109,159,35,61,12,215,10,11,64,87,87,101,101,229,189,178,178,126,155,253,254,203,77,123,150,245,243,236,201,252,242,114,208,203,179,246,168,155,221,234,183,238,152,111,249,77,143,15,255,189,118,206,191,52,106,103,121,127,56,25,244,30,100,189,118,126,151,205,198,217,60,239,101,47,46,46,222,102,183,189,203,44,239,77,63,244,166,217,44,116,121,57,29,223,242,83,214,25,143,102,211,241,96,208,235,62,176,238,59,237,73,155,177,178,241,149,189,209,31,93,103,249,172,61,235,119,178,171,190,64,24,123,39,140,56,154,245,166,163,222,140,225,250,179,27,122,202,103,211,94,123,216,235,102,87,211,241,48,235,246,243,247,15,178,241,148,15,211,94,103,230,63,158,29,191,202,110,105,61,158,207,178,65,251,122,171,86,123,193,139,63,191,59,205,218,221,97,127,212,167,11,134,26,143,178,73,123,
212,27,216,164,58,157,94,158,211,233,236,102,58,158,95,223,100,119,227,249,212,230,19,39,176,209,219,186,222,202,234,55,179,217,228,104,123,123,48,238,180,7,55,227,124,118,212,220,121,184,179,109,221,110,215,179,127,100,221,222,85,123,62,152,209,115,158,223,142,167,93,77,176,110,143,235,155,15,64,106,191,115,19,113,1,42,7,131,204,166,212,155,205,192,128,35,254,67,127,214,30,100,87,243,81,71,32,230,160,139,86,253,81,198,172,7,179,254,176,199,108,142,39,237,105,152,170,208,45,228,25,214,30,216,90,177,70,9,118,153,106,231,189,161,183,63,235,101,31,250,121,127,150,103,27,252,183,7,28,115,33,55,7,48,112,215,235,91,71,189,97,187,63,208,168,96,100,34,168,12,220,182,80,59,158,14,179,124,126,57,236,231,185,32,51,20,243,195,100,50,22,52,172,193,249,164,61,204,126,158,183,167,97,145,233,21,20,20,131,211,9,99,204,238,178,118,158,117,219,0,192,138,15,39,66,250,180,125,117,197,210,15,198,215,249,86,150,137,208,218,131,124,204,172,59,131,121,87,4,153,93,206,251,131,89,3,52,208,6,2,106,15,238,
68,85,26,116,216,246,233,245,70,144,33,216,22,66,23,58,188,184,233,241,76,84,61,54,18,186,234,181,103,243,41,253,242,110,207,94,24,142,167,61,209,236,40,69,221,116,62,26,9,248,33,11,218,135,226,69,15,66,92,152,249,160,63,155,241,35,12,48,26,211,73,187,219,238,220,104,117,68,107,0,221,191,30,137,178,6,253,235,155,153,141,205,108,161,120,39,127,6,234,125,156,1,114,255,67,47,187,132,154,222,55,46,219,162,191,97,15,80,238,0,108,212,190,238,13,123,163,89,150,223,229,179,222,48,163,173,129,28,105,230,125,239,46,27,79,122,78,200,185,241,96,120,23,36,193,163,115,134,235,143,232,81,211,158,246,6,125,99,55,250,29,245,166,0,89,251,109,246,251,243,128,134,218,247,217,147,192,166,14,196,50,46,161,145,120,124,187,153,114,249,70,65,238,34,1,177,194,38,237,206,95,33,11,140,142,162,52,216,48,18,105,237,235,169,152,243,169,80,5,21,150,28,31,91,110,27,71,35,1,16,1,113,118,122,235,34,144,200,75,72,36,219,168,80,143,72,127,132,68,200,213,142,231,217,83,167,235,108,35,208,73,54,109,223,86,72,66,13,
79,223,102,151,172,194,0,97,0,219,182,231,179,241,208,196,79,187,219,205,182,65,216,16,9,84,114,97,182,1,91,192,44,163,246,168,195,207,211,30,164,150,130,119,58,186,28,127,52,84,3,104,126,227,130,5,64,63,244,123,183,142,138,156,81,36,4,11,78,2,224,156,53,54,168,159,134,7,207,171,44,150,65,144,221,1,228,4,166,32,80,151,15,211,222,100,208,231,51,116,183,180,191,172,33,122,204,59,211,254,100,38,193,56,25,204,175,93,126,252,231,28,25,217,213,228,95,244,103,17,75,129,152,187,253,107,147,59,200,211,201,160,125,151,109,76,32,252,254,16,0,55,141,203,76,96,228,147,94,167,47,70,221,54,249,108,164,72,79,64,196,242,195,41,244,252,116,60,132,198,186,224,117,4,127,39,178,1,202,226,197,60,74,186,141,244,89,193,96,29,127,155,137,2,58,152,22,172,103,115,232,89,34,224,151,254,168,139,50,201,206,37,242,88,133,141,17,11,198,34,245,71,208,17,50,82,195,206,97,88,255,54,70,120,153,248,156,246,108,222,121,118,44,217,15,206,28,192,9,218,99,50,211,0,191,56,87,103,175,74,158,115,189,176,49,159,12,198,109,
20,141,52,210,3,39,149,240,185,219,27,244,16,96,246,45,114,88,209,212,16,54,102,254,146,78,18,44,81,110,216,116,122,174,169,74,245,179,193,162,184,242,98,73,219,214,39,8,158,79,7,166,215,166,76,107,60,28,220,185,102,107,59,20,136,57,31,218,218,25,9,189,64,25,149,146,138,87,160,215,156,126,226,216,76,244,85,123,18,52,30,67,162,230,152,192,54,146,102,2,170,165,225,245,134,168,170,61,50,41,41,96,223,78,199,31,239,88,223,255,156,247,232,61,46,217,6,34,240,147,99,33,134,175,140,0,232,208,20,105,84,162,81,41,35,133,179,81,15,225,36,1,254,236,245,185,198,122,34,41,8,79,38,82,208,200,95,18,88,205,88,86,25,12,247,4,36,175,62,67,101,221,1,30,43,139,236,4,124,200,131,5,187,28,143,103,229,55,100,160,86,40,60,181,69,203,123,157,249,84,10,41,252,40,28,161,97,179,139,187,73,47,98,202,37,113,214,65,158,98,110,12,245,120,198,99,161,86,54,202,180,223,5,119,174,244,35,43,231,99,224,12,36,20,181,182,91,55,57,144,229,54,27,100,79,247,182,223,157,221,64,190,172,243,28,251,230,6,205,252,64,60,61,194,
144,49,5,219,155,117,132,153,139,27,122,65,14,32,19,165,238,75,245,242,190,215,155,32,8,110,64,81,80,52,180,62,238,254,1,172,102,53,20,220,182,184,14,124,47,0,211,154,128,0,95,15,150,31,57,51,195,188,160,167,55,198,66,24,35,123,59,123,91,55,179,225,128,73,93,151,92,189,17,101,5,0,228,254,72,235,68,227,236,57,28,147,189,6,251,207,17,197,221,12,52,141,49,51,232,242,237,248,22,240,95,246,62,96,118,109,60,125,251,14,189,101,34,70,102,87,212,166,179,219,94,251,125,134,116,165,55,176,15,167,99,169,13,198,183,217,68,47,203,198,105,195,49,198,28,214,82,221,108,103,31,26,216,26,61,212,228,135,254,116,60,146,230,204,25,239,9,198,79,15,8,2,222,34,5,11,78,89,173,54,119,236,72,73,246,216,72,152,196,42,120,138,34,64,12,154,213,167,230,82,126,78,167,209,18,185,233,13,38,65,194,71,186,142,198,170,166,138,36,156,72,216,95,246,71,162,202,13,16,193,212,155,217,171,39,122,122,82,218,206,124,219,109,209,108,198,218,119,123,98,0,163,16,168,67,148,133,8,186,211,108,104,245,22,41,107,60,176,113,123,
211,27,137,104,163,236,147,154,151,136,212,52,161,253,77,215,239,72,78,179,95,162,89,175,105,136,243,174,250,83,8,68,182,100,237,244,74,12,74,55,134,0,173,62,210,182,104,223,238,136,249,244,74,156,216,3,107,158,99,89,15,186,89,7,254,132,30,244,188,176,3,162,217,187,97,54,196,102,118,217,99,84,179,244,76,67,200,216,194,194,187,24,35,111,68,184,16,124,101,68,153,244,234,47,74,105,147,34,182,30,249,216,45,39,169,191,54,52,241,227,8,205,26,173,236,199,190,146,109,201,127,100,85,241,187,236,65,19,64,157,155,49,120,57,170,253,246,254,247,203,224,228,52,26,241,237,133,190,126,219,254,189,86,123,131,113,41,96,140,96,49,72,7,3,123,121,235,63,214,123,29,235,138,245,55,77,248,82,154,240,220,53,97,237,57,75,208,237,97,153,225,8,129,11,8,72,194,100,1,46,253,110,64,92,136,177,110,251,232,54,51,83,224,26,8,41,162,198,21,92,177,88,129,180,161,130,193,152,69,51,202,86,71,178,167,59,242,188,36,218,133,218,217,24,129,31,209,130,134,148,176,186,53,213,170,22,102,176,168,153,19,137,131,56,158,244,
59,216,140,172,154,193,145,44,80,233,51,22,227,47,153,80,0,57,183,73,9,5,24,94,253,17,132,33,147,11,230,142,146,123,201,171,106,86,188,102,208,208,30,66,143,150,72,196,198,146,87,213,250,232,199,216,64,22,226,99,235,233,228,35,94,199,96,25,210,143,100,199,168,141,33,62,136,183,220,215,137,97,111,144,65,160,8,169,106,136,52,155,118,52,31,94,194,214,204,197,126,51,55,216,133,13,8,123,26,205,153,33,22,213,101,47,251,14,201,138,60,234,126,167,110,122,31,209,62,168,224,210,245,144,26,70,50,203,193,30,93,179,42,215,99,250,8,208,230,11,52,98,131,63,220,201,18,42,110,95,118,144,24,141,70,71,198,117,222,255,179,151,53,155,59,106,97,166,130,190,239,239,236,60,216,177,159,132,214,90,66,202,50,223,255,107,189,49,14,156,188,94,159,98,249,245,225,76,23,13,249,9,250,165,243,66,200,1,203,162,221,237,180,145,103,134,17,240,250,112,231,129,47,79,20,69,252,102,168,65,183,22,152,225,183,230,86,51,251,249,201,3,183,183,12,93,252,8,134,178,127,62,49,227,224,10,185,61,192,172,16,201,195,85,75,41,118,
43,11,203,147,181,162,194,114,216,114,168,173,244,16,100,139,16,138,16,208,3,129,26,105,146,31,212,45,225,136,121,39,76,42,40,42,64,17,146,100,210,94,246,174,33,138,98,158,144,70,57,234,110,137,13,155,190,218,71,169,102,88,64,207,207,49,3,53,178,247,252,32,195,47,29,79,37,215,101,51,7,72,152,223,21,145,0,95,195,224,29,190,112,106,87,28,0,195,67,61,44,115,11,93,208,164,70,94,237,149,156,106,57,171,133,108,66,138,1,134,116,17,210,232,23,217,27,233,11,217,168,253,161,127,173,120,0,179,254,84,124,37,219,8,92,102,115,181,46,162,170,50,71,27,63,217,244,221,120,180,201,28,142,21,42,0,115,65,182,153,24,117,163,223,184,181,93,32,10,152,78,20,7,113,160,34,250,112,50,67,40,135,190,99,4,199,22,164,51,232,99,168,218,98,218,0,44,237,108,60,146,86,91,141,35,80,29,196,9,144,157,71,179,19,11,201,180,210,5,130,213,186,202,231,134,237,171,185,8,79,139,137,31,42,171,156,167,215,40,12,153,138,113,198,133,91,83,65,37,24,140,54,78,103,60,126,47,63,209,52,65,155,149,150,99,68,60,1,67,196,20,55,171,177,
41,35,8,105,124,141,125,33,61,225,106,61,196,217,208,17,204,17,99,132,96,19,212,172,64,81,118,53,128,80,231,90,42,70,253,142,73,33,212,2,108,138,181,9,98,25,33,21,171,90,54,204,88,238,163,224,119,28,187,183,124,219,158,250,114,93,161,182,113,192,111,32,75,25,255,49,76,20,232,16,247,204,93,183,50,108,215,200,222,160,10,165,170,144,212,240,89,248,146,97,29,225,50,203,192,38,120,87,40,21,153,76,57,157,169,169,105,181,7,193,97,56,119,135,225,65,92,26,167,114,153,225,206,120,76,199,77,116,225,110,174,144,35,70,105,116,148,54,130,99,229,238,49,152,114,214,110,237,161,38,230,83,217,53,224,206,194,122,114,102,135,253,238,72,129,32,192,120,77,224,71,129,161,115,55,229,207,137,129,208,186,45,224,145,249,96,29,207,29,178,192,236,78,85,100,251,82,8,214,48,206,199,223,17,228,155,79,167,44,156,121,22,132,149,160,157,27,89,129,38,97,204,213,145,133,247,32,155,99,197,35,140,180,54,165,211,17,103,196,192,80,8,214,141,254,85,239,65,159,1,134,45,131,44,177,194,31,9,56,196,108,35,174,105,224,62,
200,206,21,72,12,115,112,73,217,67,200,222,71,82,98,149,104,152,217,88,65,78,247,120,74,39,58,248,118,230,19,64,143,47,145,149,131,59,151,230,199,62,127,195,17,92,252,1,227,56,175,32,136,165,81,192,75,130,13,38,8,92,82,98,5,18,81,208,50,206,79,216,48,153,207,79,48,230,123,166,118,236,232,149,121,100,184,194,31,193,254,115,46,128,7,48,116,113,59,192,145,98,63,206,242,232,100,194,19,61,162,65,68,124,26,124,18,214,29,141,222,158,65,68,76,110,240,201,29,241,38,134,180,141,124,211,222,81,96,51,188,84,70,198,146,208,182,197,218,205,157,1,44,162,0,242,172,220,240,38,188,132,13,12,245,90,44,130,216,166,162,13,93,226,51,196,120,108,10,30,171,84,35,11,144,123,51,57,31,47,199,215,162,166,99,150,189,129,139,54,237,244,47,165,232,20,90,51,54,230,119,15,150,228,136,126,243,68,55,60,20,43,236,154,188,25,223,142,130,147,177,148,61,141,193,107,191,138,13,157,215,161,119,124,22,240,39,165,211,39,88,102,110,33,178,109,224,188,6,149,149,145,177,52,198,44,156,23,2,36,200,88,119,173,163,211,173,229,
38,44,210,187,146,94,29,204,135,146,248,104,24,81,153,194,132,34,129,203,63,180,53,160,85,45,162,66,250,162,38,30,166,188,28,227,235,65,10,250,101,106,124,154,101,175,219,120,173,40,15,119,128,98,4,35,167,115,153,87,214,212,141,101,204,234,10,205,64,75,79,11,21,17,7,55,71,38,16,83,136,252,9,112,245,160,89,201,31,186,29,57,215,70,168,176,87,138,110,234,39,175,94,214,49,69,70,239,105,253,202,35,135,197,43,98,4,131,71,2,190,75,244,61,204,202,13,236,172,190,213,27,14,234,40,126,139,166,199,9,69,32,132,8,17,86,123,198,2,220,68,66,227,183,110,23,49,52,198,6,74,217,76,34,96,12,153,17,118,43,177,199,60,244,197,35,159,87,227,1,126,110,5,246,103,189,65,1,251,155,4,201,44,27,235,142,72,14,110,64,4,201,84,117,84,151,134,28,249,206,22,112,43,6,173,12,112,70,200,66,94,38,128,24,185,213,3,131,70,188,196,142,43,43,236,10,65,6,223,80,161,51,237,128,32,76,125,251,195,88,61,64,128,216,55,118,212,34,111,36,77,55,53,220,165,75,137,141,1,123,97,177,143,77,184,13,20,176,80,111,132,138,180,75,3,19,42,
212,206,19,2,165,245,32,219,205,8,242,208,244,68,82,211,93,90,30,116,48,55,111,64,36,43,147,46,132,128,117,0,125,29,166,65,246,8,43,98,170,143,102,172,86,80,19,240,33,205,136,26,82,195,224,255,233,163,128,176,56,10,130,216,158,197,14,93,190,9,206,212,186,96,80,109,27,44,229,120,91,124,83,177,41,25,216,6,72,187,207,140,17,55,136,236,145,41,54,100,77,32,25,131,174,228,215,72,115,146,186,237,172,14,221,40,200,42,49,21,72,62,223,218,218,42,22,119,35,204,196,13,188,77,144,104,108,231,4,142,192,9,147,88,52,252,2,37,165,148,199,171,68,58,59,4,36,121,57,10,84,4,19,3,7,210,193,166,80,52,64,191,8,105,200,73,179,142,42,52,47,235,0,143,159,73,14,238,64,21,161,149,118,124,93,120,136,198,79,5,63,192,72,60,75,209,148,209,119,132,138,88,13,16,110,203,175,48,156,104,154,149,185,196,233,151,36,136,172,91,135,222,157,161,50,2,185,214,76,179,63,46,70,75,25,200,3,143,65,138,69,70,144,145,116,217,195,249,8,175,35,11,199,190,212,70,70,234,236,26,101,170,152,55,182,188,72,197,86,74,170,152,153,200,50,
128,52,68,164,216,127,83,133,37,100,183,109,240,67,7,83,66,234,231,30,200,97,45,25,198,230,95,46,98,202,147,197,14,169,4,140,139,216,8,241,37,142,115,164,154,20,131,247,25,33,125,122,159,31,194,232,159,225,135,82,240,126,57,71,160,100,115,17,193,226,230,147,201,22,54,146,176,246,192,89,142,53,113,30,55,69,128,10,20,128,110,5,1,108,143,75,81,11,196,57,123,231,119,176,9,212,215,158,76,122,109,143,55,184,161,69,100,65,180,152,238,160,154,140,54,221,36,39,135,184,91,103,62,224,157,110,251,14,171,17,45,143,74,172,68,132,120,32,234,180,32,191,22,86,42,193,49,32,235,37,40,157,99,147,78,194,155,193,193,238,151,92,215,138,124,40,25,185,24,138,229,49,201,86,252,128,57,170,137,225,16,246,174,5,21,178,128,17,247,229,52,140,25,214,226,140,31,216,252,213,94,57,35,196,121,65,117,19,104,21,68,64,155,110,69,69,110,16,72,116,145,10,42,7,209,71,50,234,101,210,76,61,170,148,90,237,108,97,67,16,61,52,156,200,251,16,46,165,170,157,193,177,212,17,143,68,101,10,237,45,219,93,78,64,220,18,129,158,131,
187,36,38,73,162,63,178,184,244,147,237,133,70,215,219,245,8,191,74,71,162,47,124,93,37,199,76,153,168,125,162,96,226,99,215,49,226,112,140,84,237,27,91,248,42,203,71,125,104,129,125,50,201,153,5,34,179,96,81,179,117,184,181,195,255,154,24,121,141,236,183,214,163,237,87,237,233,118,107,167,181,119,180,211,60,218,105,29,237,237,101,255,104,238,236,238,252,158,213,127,62,185,200,182,111,111,111,255,117,57,104,19,41,146,59,108,248,200,255,5,102,182,205,249,104,180,71,236,7,34,147,182,180,53,232,123,193,91,205,122,214,66,41,61,218,221,219,89,149,27,81,207,234,175,198,127,66,187,237,237,253,173,157,108,227,151,176,141,247,250,130,13,227,173,157,31,180,175,119,176,247,67,246,241,96,111,51,59,158,16,153,67,193,252,179,63,219,222,223,61,220,218,61,200,54,254,249,226,226,213,203,32,138,126,238,117,222,143,55,179,167,108,23,12,123,219,205,214,174,205,112,39,59,111,95,181,167,253,240,74,61,251,173,57,204,179,214,195,121,214,234,252,94,251,251,240,128,255,196,238,121,195,208,177,245,199,
100,17,11,187,143,246,113,255,86,164,136,124,53,52,236,205,179,131,255,47,176,64,134,202,18,28,52,155,7,59,205,221,111,10,9,251,45,136,1,44,28,254,173,88,112,158,152,95,146,66,51,95,134,135,86,107,239,240,219,194,195,222,33,120,104,182,230,217,238,223,138,136,113,222,105,79,151,96,224,81,115,231,176,249,77,17,194,222,129,16,208,156,103,123,127,43,2,130,84,192,249,100,147,115,9,34,30,54,247,145,180,223,146,88,216,219,7,17,187,243,108,127,45,60,236,255,37,45,65,78,209,18,5,177,251,240,224,209,55,168,33,30,173,171,33,254,26,14,186,121,119,9,14,14,119,247,14,190,45,28,236,74,77,238,175,171,31,214,197,193,150,194,122,203,230,191,255,232,155,226,130,157,32,14,215,147,6,235,206,222,245,66,151,36,210,254,18,89,208,124,184,191,115,240,240,155,66,195,225,67,225,1,105,176,158,90,56,88,83,26,176,101,252,254,207,241,120,232,137,35,85,115,113,119,239,112,239,219,82,13,70,11,216,8,127,47,14,242,43,28,143,241,18,86,104,238,237,30,182,86,81,65,5,115,95,197,108,20,54,118,119,214,149,141,235,82,
196,23,200,133,175,143,10,73,72,49,199,122,66,98,93,84,92,223,172,32,140,214,126,107,255,219,166,11,152,100,61,179,97,93,92,20,107,124,223,173,108,237,29,124,219,200,56,88,87,119,254,85,100,52,136,208,16,159,35,52,56,91,166,69,118,31,238,226,117,175,48,41,11,132,42,101,239,171,200,143,93,121,92,77,12,139,181,196,233,254,206,95,84,41,9,114,90,203,176,115,248,112,239,209,74,215,235,235,99,231,192,176,3,233,172,135,157,214,95,196,206,214,225,159,11,209,153,189,214,222,39,226,51,95,31,33,205,195,61,209,203,225,186,24,89,55,108,85,204,236,207,254,100,1,37,251,143,154,251,15,15,191,93,14,106,61,50,103,157,8,214,122,68,178,174,117,90,160,132,236,179,5,148,52,119,155,44,196,74,71,181,120,243,171,73,149,3,247,223,241,217,254,94,156,16,143,236,125,92,102,166,62,124,212,220,253,134,229,136,73,217,22,102,218,223,139,142,213,102,218,74,139,181,196,224,87,81,55,50,87,91,132,117,214,195,195,225,154,242,148,44,243,225,120,116,183,140,48,154,187,251,251,171,41,227,43,99,195,156,250,214,186,97,
190,253,191,138,142,251,86,218,238,193,74,194,72,113,248,245,72,99,93,223,118,109,92,124,1,139,124,19,152,104,98,188,175,229,200,172,141,137,124,124,53,227,4,103,191,189,204,201,109,237,28,172,180,223,191,58,62,66,232,107,45,95,102,109,116,132,89,37,6,234,50,251,180,121,120,184,58,20,246,213,17,243,80,226,20,91,108,173,77,35,230,177,222,22,226,125,204,44,51,221,91,59,143,154,7,43,77,144,175,142,154,131,93,80,131,225,190,30,209,124,57,106,118,151,80,77,171,185,123,216,252,118,81,195,81,3,39,155,53,112,179,203,254,243,95,35,155,173,37,230,234,222,222,67,254,191,202,132,255,250,180,114,40,132,96,192,175,135,144,221,53,17,178,82,245,124,179,246,136,208,128,205,190,22,26,154,235,58,187,36,207,140,200,79,76,4,237,254,214,117,255,106,209,165,57,56,88,189,7,27,186,48,251,238,235,217,38,235,197,156,119,143,254,42,102,150,153,173,143,14,118,118,87,74,144,175,109,181,90,80,4,103,230,239,165,147,47,96,151,175,78,23,178,76,118,113,103,214,200,93,249,2,186,184,111,191,239,53,87,134,156,191,
58,46,36,60,90,235,5,18,255,58,46,18,233,177,68,225,146,201,114,248,112,165,253,250,213,49,83,196,88,215,48,232,255,2,106,100,208,239,46,51,205,154,135,143,86,42,219,175,142,12,145,137,18,59,254,94,225,17,166,149,144,201,82,196,28,28,30,172,182,89,191,58,106,14,31,129,27,204,144,53,204,121,200,100,221,208,234,125,212,44,179,89,161,153,71,7,43,163,172,95,29,53,102,206,99,154,172,135,154,117,183,112,226,180,238,7,157,201,140,195,32,89,101,177,198,247,190,90,124,181,101,158,95,19,29,188,30,66,214,141,28,173,212,193,171,131,205,95,217,24,137,226,100,61,60,172,235,231,113,94,47,39,67,172,113,71,142,252,248,118,153,129,182,187,251,112,127,165,144,253,22,112,66,84,241,239,197,201,23,208,198,18,52,126,53,243,93,217,148,235,233,156,47,36,146,251,214,90,179,201,126,233,138,157,223,111,9,53,187,160,102,61,11,246,203,80,243,25,173,252,104,255,112,245,30,240,183,130,39,15,213,175,183,19,140,114,254,47,35,106,137,149,219,58,60,32,178,244,173,19,148,71,151,148,135,179,150,248,105,173,27,94,
250,2,241,243,45,136,97,130,6,235,225,97,221,168,82,100,136,137,14,152,90,165,167,197,132,189,221,157,149,155,60,223,2,70,214,75,98,221,61,106,125,17,70,150,72,225,221,207,51,77,129,204,175,166,158,118,97,152,181,100,240,218,104,249,2,134,185,71,91,95,13,29,173,245,50,76,254,2,149,80,91,97,172,131,219,75,4,235,254,33,33,187,207,232,233,175,79,33,18,169,107,25,48,107,83,72,186,220,159,209,209,205,125,50,226,63,171,123,190,46,146,204,125,110,162,162,9,179,88,33,34,43,43,19,143,230,45,158,13,228,24,31,197,111,252,228,106,56,125,63,190,82,149,8,170,141,114,184,153,19,140,170,2,241,76,5,84,172,0,129,74,176,81,115,176,71,237,147,174,138,7,123,13,198,127,112,106,147,10,6,255,176,98,15,58,1,202,71,59,90,72,225,139,217,152,115,38,89,168,102,193,187,103,148,67,83,77,176,46,71,135,173,86,157,142,227,109,188,249,167,14,161,91,41,190,141,106,45,62,149,127,120,114,167,3,152,58,76,169,19,181,156,244,212,167,13,209,177,215,86,86,27,202,90,80,181,143,147,142,212,161,228,235,59,213,137,57,86,157,
24,149,221,84,109,163,43,149,36,82,105,231,7,217,155,115,29,98,215,91,167,105,81,47,175,98,152,213,127,227,208,246,239,117,63,64,109,101,26,24,212,138,44,28,89,13,58,67,25,39,61,199,84,91,29,80,222,98,80,28,174,228,120,233,144,239,28,203,212,217,80,142,132,150,197,73,84,210,196,209,204,163,80,47,49,187,229,84,51,5,109,188,126,171,125,240,242,125,93,138,60,114,100,241,159,84,75,228,48,185,74,134,134,227,155,170,124,172,117,200,7,148,210,251,111,154,83,217,219,39,206,186,63,105,143,236,164,59,255,170,192,238,75,149,144,141,53,41,84,218,205,1,43,151,28,72,225,10,213,106,97,169,236,180,16,165,88,238,98,141,18,206,117,94,112,240,51,239,127,100,116,213,175,40,14,151,115,178,149,98,31,20,188,243,147,175,113,165,146,178,48,129,180,142,157,180,56,229,89,14,106,179,177,165,101,93,222,82,225,32,231,113,137,192,80,231,96,91,51,94,94,121,67,244,193,171,79,168,153,249,82,197,137,170,239,95,121,9,59,210,152,245,100,216,238,138,144,207,188,80,104,181,101,196,181,53,10,5,21,205,196,240,234,3,
86,99,150,250,88,94,37,177,168,130,33,130,18,146,116,38,214,41,212,96,137,21,121,26,156,35,118,98,181,5,44,105,119,73,141,27,94,188,80,5,156,134,147,27,197,213,40,31,24,203,40,121,153,59,10,103,120,121,66,206,27,151,231,236,195,184,181,95,252,64,118,96,20,63,129,205,34,121,37,139,176,158,170,125,35,96,41,164,97,21,75,70,84,97,177,26,218,170,157,69,129,18,200,90,167,128,85,152,148,202,14,84,170,74,73,32,176,110,168,40,164,210,162,149,85,217,14,245,60,252,24,177,21,140,8,37,70,226,25,232,250,187,17,112,168,82,66,113,176,190,67,73,10,42,54,9,127,9,136,78,239,64,163,66,186,2,202,39,101,213,9,218,58,242,191,165,18,137,217,146,63,40,43,146,25,213,18,140,158,82,218,208,169,108,59,64,158,251,187,79,224,43,47,158,228,223,181,2,181,37,221,82,114,44,254,241,212,62,134,127,194,231,162,129,191,28,27,55,66,95,250,190,180,95,158,235,240,51,255,11,45,227,191,250,90,124,110,98,198,249,223,222,214,110,243,33,197,57,195,215,108,167,57,92,213,175,154,28,29,53,67,203,162,47,190,23,159,155,173,135,
225,241,222,86,171,181,147,246,187,51,172,213,40,247,233,178,35,40,5,136,130,154,85,163,238,150,169,152,149,69,54,158,34,235,106,18,55,80,159,206,223,151,210,202,171,232,80,241,110,220,233,163,93,116,144,222,245,15,231,249,57,131,207,154,234,93,100,28,194,70,197,109,173,182,82,246,10,181,33,48,223,168,51,227,17,190,156,82,105,182,248,130,220,247,66,209,60,56,235,117,238,160,170,174,222,240,247,75,154,168,249,186,240,64,31,146,21,84,91,127,102,191,127,226,75,108,165,55,202,87,252,87,95,137,22,15,76,15,90,147,91,202,100,25,244,246,45,107,62,12,148,167,175,59,173,228,75,150,197,181,200,178,150,250,136,127,197,193,112,239,94,148,176,186,251,253,164,199,230,94,242,37,203,30,197,14,201,66,44,62,234,67,32,64,239,126,143,31,202,238,17,235,8,214,226,175,210,227,206,78,165,123,193,229,127,159,234,126,159,38,101,247,139,200,121,148,244,88,69,78,179,4,25,58,45,255,22,144,115,248,133,221,83,24,49,254,85,160,95,232,94,43,180,26,250,213,75,155,66,95,78,36,227,152,115,168,125,224,184,215,10,
173,236,190,213,92,137,156,148,114,86,35,167,169,71,255,213,238,87,67,111,115,92,217,253,122,116,79,236,168,252,171,34,7,55,229,83,208,31,36,200,169,140,149,210,125,83,228,81,253,67,64,26,238,77,192,126,9,244,133,100,102,53,69,220,241,111,1,250,42,91,45,210,253,39,40,167,36,204,132,136,22,41,199,70,94,13,253,106,161,208,58,136,240,102,89,242,145,31,83,161,208,212,163,149,221,183,14,19,220,87,185,54,33,76,138,167,148,127,11,200,249,52,215,174,134,62,237,254,19,208,127,154,107,83,33,89,145,111,25,85,175,138,63,173,95,249,87,65,206,39,185,182,210,99,229,11,82,190,236,48,69,78,21,247,38,237,190,4,247,108,146,22,127,201,68,22,100,142,73,187,149,221,87,0,174,124,169,64,159,140,196,144,17,57,53,184,249,158,254,119,251,193,74,153,114,153,128,76,242,41,149,134,85,162,135,98,233,252,211,165,164,36,250,146,66,239,212,223,105,235,119,28,68,202,114,125,222,228,80,133,232,218,51,191,23,2,59,3,171,35,185,226,193,202,12,201,113,138,69,43,139,186,242,85,11,68,46,206,149,93,118,98,213,82,85,86,
200,140,224,164,40,153,60,177,80,79,141,14,101,184,90,145,52,217,211,86,56,167,234,59,154,187,81,150,94,244,79,122,41,84,249,225,57,114,29,55,22,100,168,58,227,49,55,124,108,129,11,255,30,26,97,196,227,11,168,160,143,251,152,188,4,83,172,122,201,235,111,199,90,69,242,228,119,209,212,101,235,248,201,219,237,238,132,78,213,16,15,106,121,197,197,21,245,22,203,90,125,86,215,8,215,252,19,254,104,172,31,69,97,217,80,131,213,175,0,160,116,164,42,198,227,179,7,207,33,20,36,85,49,212,223,110,126,55,226,44,234,10,91,253,100,220,90,85,42,115,183,193,11,42,131,81,252,146,216,131,173,154,60,212,145,21,209,85,181,48,85,114,220,112,55,98,51,181,72,221,213,72,251,170,148,104,194,63,119,207,200,235,11,187,63,70,145,166,232,4,57,140,175,218,31,183,168,142,168,98,161,50,96,195,197,8,230,125,15,219,31,251,195,249,48,241,105,83,115,216,238,159,10,21,202,196,43,240,0,110,88,244,250,160,58,213,60,84,248,70,145,132,224,130,167,239,139,234,252,162,129,172,205,49,144,107,188,187,210,93,2,76,209,189,188,
47,155,211,18,152,85,203,211,202,77,91,153,81,3,152,18,240,16,218,160,63,164,164,27,4,30,138,157,2,21,69,212,44,90,161,120,71,239,186,125,105,225,25,204,119,74,183,121,165,102,220,83,138,120,89,56,72,142,2,165,188,40,89,106,247,65,120,117,102,224,135,63,211,95,178,246,135,113,159,178,162,164,193,118,173,181,238,193,98,69,88,101,138,36,207,250,224,83,172,70,22,37,5,149,172,203,27,202,94,102,31,20,128,0,39,161,154,216,54,140,39,175,206,2,23,193,143,7,145,86,176,117,139,106,84,16,145,45,144,21,37,181,114,170,76,193,193,103,90,161,126,221,200,110,252,49,92,212,206,189,108,187,249,192,183,128,52,85,85,85,235,47,86,147,43,58,216,104,170,84,185,149,43,255,223,84,253,142,136,41,110,20,0,137,208,86,239,163,221,16,21,75,52,66,172,5,226,65,202,249,80,107,102,224,154,91,126,169,162,91,6,73,151,167,47,109,248,107,74,79,11,100,143,182,33,223,88,120,107,103,226,6,58,23,174,157,24,253,154,145,210,179,253,159,115,8,51,219,216,249,105,4,33,61,160,154,85,227,117,246,234,114,83,108,232,28,20,73,
20,10,162,76,144,197,204,10,183,152,203,101,66,0,67,113,191,34,244,134,220,131,56,3,225,66,144,94,119,88,210,26,90,13,197,133,37,176,250,99,77,33,226,211,228,124,68,17,117,97,45,18,104,8,4,160,236,39,240,247,51,245,31,97,212,18,169,225,247,139,75,21,22,179,8,135,132,231,127,218,148,64,44,98,156,50,167,186,199,11,12,70,122,0,12,117,34,153,5,1,7,102,250,78,235,0,146,172,160,93,90,101,84,111,134,80,71,100,16,74,83,38,225,38,194,30,170,0,235,130,194,11,206,90,24,13,128,142,25,70,23,121,185,224,242,85,9,165,87,25,255,234,138,5,57,46,171,42,115,19,157,170,103,218,77,91,11,179,64,228,149,151,59,1,145,151,213,78,187,46,186,181,18,131,86,200,155,5,180,155,207,202,190,20,194,201,168,75,199,221,18,204,156,8,235,159,92,160,179,25,167,237,171,237,184,3,107,30,65,10,151,140,249,236,88,49,216,158,240,228,200,248,31,38,34,0,80,169,46,109,119,173,56,157,37,151,164,56,45,169,10,232,132,224,47,2,79,58,188,184,55,133,170,183,186,72,69,18,33,44,6,168,187,96,25,197,204,96,79,240,91,19,175,161,108,
55,13,232,101,243,227,237,98,63,36,153,131,166,152,1,147,68,14,165,145,216,16,242,42,66,120,219,48,53,148,193,181,123,216,16,140,245,74,21,42,213,227,176,215,70,43,92,81,4,85,195,206,167,92,121,34,197,96,69,56,99,225,209,142,202,172,130,189,0,92,184,215,76,29,230,210,72,148,74,140,226,89,244,23,238,46,129,1,139,251,16,252,162,23,187,230,165,184,239,197,123,41,138,38,154,20,179,123,98,2,110,196,73,138,238,17,244,245,187,223,98,199,69,52,110,155,202,130,212,254,228,246,63,11,188,230,115,93,69,103,33,241,18,85,80,170,221,56,97,4,20,194,201,220,248,246,65,69,147,41,249,76,177,194,88,114,152,82,231,57,213,148,21,182,205,117,15,32,243,85,121,114,241,2,81,102,93,126,195,131,9,124,109,102,135,197,104,236,134,155,105,118,113,241,252,73,182,33,117,100,43,96,119,180,72,48,121,45,251,116,78,244,185,255,111,90,42,167,59,175,61,91,202,24,129,109,188,190,179,243,111,70,2,86,83,144,95,157,186,170,87,226,212,46,188,152,61,40,15,23,138,4,42,136,107,65,76,157,219,247,42,215,232,176,240,239,236,
50,27,171,6,10,71,123,165,96,202,74,66,111,86,29,146,146,96,170,14,233,198,129,174,198,179,226,241,144,169,40,210,137,10,202,75,130,213,38,86,120,40,244,64,177,178,89,170,246,227,155,17,172,107,212,41,11,37,128,106,37,34,35,160,252,124,217,227,42,36,194,174,8,44,174,64,146,166,170,94,237,99,220,129,120,213,181,51,146,167,33,132,107,151,53,216,141,142,212,184,156,113,107,227,123,85,67,215,100,212,144,123,8,77,38,11,58,253,34,19,58,94,135,195,136,220,86,68,240,76,144,107,14,154,223,178,65,121,237,182,77,41,243,27,33,146,176,44,248,241,235,123,224,23,54,90,194,77,68,122,123,78,1,217,206,244,110,34,240,35,52,220,35,244,94,58,197,182,108,76,76,105,44,136,135,93,162,8,129,222,5,246,40,49,89,107,191,193,200,214,111,1,36,205,66,21,47,177,42,68,170,70,188,1,141,65,92,197,10,235,241,138,79,196,232,220,207,208,159,155,74,240,194,216,18,60,86,237,95,155,79,5,212,241,198,136,194,220,250,110,81,13,24,170,164,9,176,44,192,48,32,198,18,244,136,118,116,27,118,85,184,70,64,62,192,236,6,212,137,
39,132,100,217,162,203,238,161,144,0,137,165,116,209,89,44,26,86,21,40,150,88,147,70,141,108,31,169,101,9,89,35,68,238,56,229,110,60,46,137,103,110,148,208,10,164,209,242,244,77,140,21,56,207,54,12,207,54,59,173,146,21,245,12,55,56,200,6,133,232,184,101,195,45,103,100,130,132,7,51,117,101,110,178,71,204,175,139,3,174,177,218,204,188,131,211,5,128,121,108,151,61,139,246,115,31,92,142,42,97,98,80,243,41,197,206,253,74,81,221,26,165,166,245,243,27,43,181,204,178,166,96,111,180,134,155,245,200,54,67,221,15,38,163,83,229,152,229,36,106,29,133,92,112,172,43,197,236,115,250,182,57,155,133,136,91,32,38,151,42,148,22,125,143,169,139,118,10,235,170,85,53,83,203,54,177,232,57,108,23,98,157,180,110,54,125,79,197,135,151,205,128,22,40,174,64,137,165,214,35,52,242,56,39,94,229,150,9,6,83,130,119,172,182,190,179,173,13,36,204,117,231,197,149,85,126,197,64,185,227,85,40,49,109,86,105,170,21,82,64,180,48,255,105,219,106,25,75,228,133,113,124,118,231,179,105,159,10,242,113,106,70,243,186,55,110,
50,166,46,243,93,237,20,113,62,13,54,31,245,207,145,243,90,170,162,149,11,192,80,208,182,196,56,115,86,167,225,166,70,147,128,94,168,62,94,123,119,196,5,66,198,35,141,243,112,165,70,227,173,13,120,20,94,106,228,211,78,246,157,172,207,239,126,200,198,246,114,229,167,75,168,162,193,230,103,209,38,144,117,35,200,199,134,110,77,202,27,90,254,239,28,12,250,49,179,62,226,166,139,125,118,239,102,61,93,141,162,109,84,5,22,192,163,149,140,150,213,43,125,143,220,55,163,46,242,171,213,141,118,9,211,46,236,215,120,53,7,228,45,55,44,160,122,155,183,227,13,177,13,187,27,34,112,82,48,148,18,45,91,169,170,95,143,192,54,170,247,122,212,125,237,226,83,55,207,16,9,182,7,183,116,10,191,104,75,65,139,159,116,233,70,190,223,212,82,215,172,204,227,11,211,98,99,80,206,126,96,82,161,170,52,235,22,77,105,83,62,38,147,0,0,235,4,122,161,171,236,253,136,123,118,76,145,81,216,183,163,29,98,27,192,223,214,142,118,176,196,171,147,65,75,98,120,72,192,249,108,116,213,225,246,180,23,254,177,103,13,93,12,113,111,
149,78,243,156,187,28,153,162,154,138,99,236,146,68,8,128,26,194,105,159,129,90,97,184,194,161,146,214,8,241,19,22,158,189,217,50,20,132,72,240,123,219,86,137,103,21,42,23,84,108,184,51,86,92,18,58,180,157,87,186,219,166,235,248,217,122,163,118,58,70,189,238,78,51,8,245,92,31,2,22,43,191,5,52,44,195,169,225,50,118,132,106,253,136,3,138,232,4,203,222,93,8,133,172,22,154,92,229,48,150,161,21,141,25,119,72,42,178,213,175,78,146,238,229,126,81,110,244,50,81,30,227,108,136,148,81,142,78,3,110,152,185,80,35,29,245,202,253,170,84,247,214,126,29,240,112,120,209,116,141,103,99,216,115,45,19,34,39,188,36,51,90,46,4,108,6,45,40,13,5,25,195,18,135,2,224,201,240,66,43,229,145,165,77,180,98,126,237,171,9,249,96,130,150,157,198,107,57,202,161,101,151,157,191,5,249,119,197,253,18,128,225,174,122,231,102,62,122,47,147,214,20,146,196,6,239,81,21,31,99,4,35,20,19,59,46,236,109,155,187,35,164,197,221,66,13,110,4,195,242,171,200,15,54,42,118,250,35,237,244,185,43,228,252,45,153,0,126,99,96,16,215,
166,243,160,66,150,14,249,107,227,35,249,5,110,209,129,60,136,246,16,156,196,224,85,98,171,35,232,130,125,115,9,187,36,243,118,59,39,116,197,253,97,230,215,177,22,131,6,118,142,187,85,229,0,19,110,6,8,148,242,220,174,183,96,101,132,254,92,87,52,158,252,175,147,218,19,144,21,110,139,218,128,39,9,42,73,175,66,236,17,33,186,197,73,215,211,104,73,253,134,140,164,7,169,94,122,9,89,0,245,75,191,160,80,103,158,255,165,24,10,247,13,212,33,159,243,249,165,191,73,31,24,140,212,7,179,141,94,169,101,166,161,197,40,37,211,3,175,178,255,64,113,71,154,179,62,138,98,152,126,70,255,198,110,236,102,49,187,49,199,116,123,93,245,191,235,114,55,12,145,193,198,14,119,61,198,24,149,181,236,112,91,19,27,203,102,185,197,187,164,116,81,129,87,168,199,132,211,109,43,120,60,6,80,144,238,216,121,166,40,176,178,236,134,100,35,26,46,107,22,81,200,12,52,198,182,171,215,181,184,82,235,118,201,128,232,208,175,187,33,253,7,15,78,244,0,125,67,247,92,13,65,40,128,128,26,110,165,204,121,120,168,242,38,50,21,52,121,
176,219,164,104,8,18,105,96,109,19,201,18,131,14,195,93,58,12,127,44,31,45,150,226,199,42,203,137,80,223,183,198,24,220,49,3,163,40,46,167,27,191,127,155,255,30,239,129,107,216,181,167,23,174,229,139,43,196,184,151,167,183,137,58,63,250,143,64,16,241,26,201,116,145,255,195,240,243,185,70,134,189,207,53,34,45,39,255,92,27,173,246,58,109,150,85,132,95,152,178,79,183,50,191,123,115,185,7,247,34,140,139,240,172,170,70,111,246,9,185,8,92,178,178,88,246,62,175,69,13,62,194,184,181,154,254,242,235,185,183,139,170,246,172,182,100,200,66,165,124,19,69,226,141,32,205,32,24,221,146,0,180,118,35,125,52,72,32,15,187,199,0,160,69,126,46,114,232,88,130,76,111,211,251,136,124,155,6,76,201,93,241,178,226,93,86,161,37,253,67,8,26,136,66,59,186,31,204,228,141,137,177,246,157,104,79,44,170,125,153,132,50,45,170,202,96,169,150,112,223,202,188,182,15,125,252,92,186,51,22,247,184,153,5,81,244,91,208,82,188,108,126,198,229,60,199,247,68,138,3,189,49,148,199,21,201,161,226,14,54,140,54,36,58,146,149,
244,68,255,92,4,18,75,158,100,40,247,141,172,15,227,115,36,130,249,40,184,87,66,237,98,236,186,136,218,228,22,132,45,205,233,139,128,90,33,92,66,34,202,135,232,36,130,178,40,53,129,159,107,121,116,155,142,2,156,224,218,230,166,244,67,205,68,248,113,49,110,240,72,144,216,42,51,255,144,72,25,51,21,205,3,140,16,176,146,126,239,212,108,76,80,15,17,65,95,92,174,135,226,145,227,132,39,162,196,140,224,120,217,22,73,204,186,100,44,181,246,125,171,194,27,178,11,30,98,19,201,130,155,223,95,147,223,24,211,39,21,197,96,57,136,103,152,141,39,157,114,61,109,235,158,25,223,212,210,125,135,166,15,245,65,142,68,226,8,21,129,146,232,17,153,106,177,238,128,80,177,88,153,49,101,158,166,15,129,116,15,14,8,11,78,62,191,143,99,162,216,125,245,108,195,6,61,218,222,222,140,200,23,29,203,114,255,72,56,194,111,124,74,155,166,45,141,36,68,148,0,29,40,130,168,11,23,56,234,174,47,91,82,247,123,10,71,205,81,242,82,91,127,18,151,218,57,105,43,99,148,229,74,174,158,45,247,23,35,7,177,20,116,23,110,134,138,122,
58,220,120,247,52,236,64,190,197,236,228,146,251,109,153,86,73,103,17,198,24,37,82,78,169,80,103,145,157,197,152,81,12,12,88,64,64,124,131,65,109,138,45,222,83,17,66,219,82,249,131,236,231,119,167,98,120,228,9,12,133,233,239,66,197,84,38,84,231,15,44,122,223,30,16,180,80,68,202,118,138,160,223,104,230,100,245,0,44,206,68,251,82,74,13,150,68,25,17,218,80,156,66,154,162,66,255,33,14,170,204,60,136,107,197,237,75,47,181,169,148,219,254,95,113,51,174,5,154,225,109,5,80,11,74,114,249,161,203,85,250,68,204,177,57,217,64,193,184,17,249,27,19,133,168,101,196,183,25,163,178,8,139,244,101,102,36,218,13,233,107,113,193,237,82,20,182,36,140,111,16,127,192,26,121,216,156,89,153,124,176,165,222,210,219,82,193,115,101,44,218,55,120,45,24,136,229,48,188,128,141,65,58,52,150,20,120,7,217,26,138,107,139,114,2,27,108,74,33,62,209,208,102,34,56,129,157,43,226,168,54,128,30,204,240,194,30,212,208,30,101,137,240,201,22,137,205,74,35,13,212,201,133,101,187,175,31,54,222,108,95,161,64,94,9,30,20,70,
184,90,252,231,219,121,112,67,68,164,249,186,134,63,126,212,238,195,226,200,64,3,213,0,210,146,126,125,17,32,154,176,123,15,81,6,76,11,101,34,192,123,193,53,67,166,44,200,64,187,216,119,81,162,66,161,190,191,98,162,17,155,76,12,101,169,218,197,56,169,110,225,122,46,37,173,154,100,107,147,59,190,155,29,251,222,236,243,241,244,178,223,229,177,95,228,238,8,127,114,31,223,111,20,201,78,136,173,196,151,196,197,189,41,217,221,71,148,75,255,208,195,80,198,122,244,72,89,49,99,45,166,208,20,8,90,202,22,202,138,232,44,215,15,112,142,71,241,30,222,163,218,18,66,208,6,216,131,61,110,168,217,104,74,189,111,214,238,195,174,38,108,54,114,5,50,109,136,232,190,231,118,195,83,45,147,22,177,175,43,79,205,222,141,68,109,188,18,232,196,150,101,25,1,107,2,62,110,32,72,87,86,48,157,145,7,204,110,19,186,210,237,170,70,75,161,19,167,36,24,32,16,151,150,30,48,156,16,108,167,35,220,5,5,157,132,53,91,131,42,4,13,230,5,183,202,73,52,247,180,165,105,102,62,61,255,161,120,160,137,127,187,89,8,226,126,130,165,
237,219,93,22,170,150,24,19,41,163,37,236,86,122,219,8,147,197,254,171,46,43,179,187,224,45,226,175,49,40,201,100,23,160,18,230,123,240,16,124,134,185,251,141,148,204,33,40,137,59,221,98,181,65,181,235,7,7,28,88,136,141,0,234,23,177,71,196,51,192,149,97,129,24,2,128,18,68,239,234,75,202,88,184,161,81,15,91,221,156,178,64,192,240,102,228,25,242,231,165,159,114,60,4,71,98,34,207,236,102,88,37,67,64,128,198,203,142,21,174,209,68,175,134,91,223,68,133,40,237,9,50,147,125,115,11,114,234,194,60,38,174,123,146,132,7,128,198,52,80,187,244,129,183,144,154,32,214,27,252,89,211,180,153,159,177,3,91,250,128,181,210,97,215,125,196,4,140,222,10,145,162,240,157,41,250,240,174,217,9,18,58,102,25,42,118,7,83,161,46,176,152,74,121,2,52,23,159,17,46,1,9,150,251,162,23,139,1,163,12,115,14,87,146,119,138,19,107,230,130,188,140,170,98,100,147,186,15,152,38,106,36,241,48,117,204,154,48,119,123,249,209,130,8,117,148,21,192,140,56,93,10,138,209,251,82,81,89,176,4,208,6,239,235,72,155,136,149,110,2,213,
194,219,70,13,122,22,184,12,64,145,245,15,35,220,162,21,162,138,182,73,187,43,227,164,132,60,92,65,135,3,203,235,218,136,183,33,88,42,28,144,74,67,123,223,46,76,85,11,63,9,224,184,118,132,62,97,16,207,137,15,24,79,108,102,210,186,109,108,65,200,59,161,157,25,174,210,108,48,32,67,121,50,64,153,57,32,160,101,81,186,59,66,11,95,139,34,71,34,153,110,138,45,200,93,167,58,176,123,17,68,6,202,66,98,6,183,24,66,100,126,194,67,182,9,70,22,226,8,98,176,55,2,60,190,136,30,172,89,58,144,8,145,97,175,231,230,99,216,233,2,237,59,76,117,233,61,146,66,137,87,241,138,118,187,124,244,125,8,177,88,74,73,78,110,207,128,220,165,30,124,171,169,199,200,89,237,140,48,161,226,230,247,9,177,104,83,232,32,216,131,125,3,37,183,71,223,193,239,92,102,42,154,161,182,0,37,130,35,249,1,108,88,152,82,157,115,127,50,91,246,225,18,68,123,10,38,164,179,82,194,148,8,146,129,233,139,237,158,196,16,137,128,192,145,236,129,37,96,16,51,0,181,189,34,11,72,8,19,183,65,45,24,198,201,252,12,92,200,101,165,169,247,10,128,
107,156,196,80,232,195,174,251,189,163,35,196,160,122,29,74,65,90,76,159,30,162,12,133,42,176,166,76,171,239,237,112,180,12,47,175,199,221,246,64,196,19,116,88,242,86,201,36,193,116,6,109,218,189,158,42,206,5,200,67,139,222,114,102,129,243,76,68,166,200,189,226,106,225,100,80,23,61,66,171,230,102,25,13,66,141,38,235,18,175,46,23,124,219,43,156,20,239,21,214,40,152,117,171,89,164,102,23,170,166,237,165,92,138,45,21,99,87,236,231,254,64,219,48,248,12,57,220,161,117,156,161,125,110,45,38,31,200,84,199,117,216,172,150,171,238,70,164,92,60,93,84,169,195,153,195,1,103,208,34,72,63,40,22,132,103,62,251,105,62,187,106,60,172,99,72,17,91,83,178,139,130,241,61,238,107,102,46,150,5,194,133,166,142,0,178,94,100,24,128,237,99,45,162,249,32,150,17,121,73,180,251,214,38,110,65,7,40,0,21,160,11,90,131,143,224,72,41,79,133,89,156,1,113,94,46,160,230,210,163,116,207,138,60,78,50,185,202,133,44,94,99,68,112,87,220,238,105,244,129,77,231,203,22,23,173,104,45,169,244,254,247,231,186,81,250,194,14,
133,40,173,245,149,64,208,215,112,164,35,28,219,72,142,100,144,206,88,249,3,195,236,130,25,34,182,199,68,215,169,202,103,17,217,26,133,232,211,191,180,221,199,198,225,159,13,232,143,73,40,64,83,107,79,222,175,106,250,129,120,55,203,61,37,159,109,75,27,225,132,67,27,237,41,91,3,31,122,181,203,225,36,125,205,206,146,109,243,99,237,242,54,57,92,145,41,123,166,0,241,99,131,135,52,168,188,185,216,96,82,235,112,112,43,249,51,42,225,183,90,111,50,191,76,126,79,95,212,163,127,80,246,167,166,106,149,201,95,218,70,179,25,246,185,126,83,133,182,182,44,63,147,45,248,6,111,116,230,118,222,175,166,50,134,201,159,207,137,31,107,215,164,177,36,15,210,94,63,54,244,176,118,253,41,132,95,11,50,153,27,201,223,42,218,87,187,193,58,237,250,157,113,210,140,80,21,171,179,253,177,193,207,163,218,31,87,149,153,248,179,63,38,189,235,218,31,149,7,225,45,127,162,179,73,229,95,250,14,47,150,15,170,239,164,15,42,79,42,75,184,64,5,127,180,63,180,125,211,179,54,132,161,147,191,246,188,219,31,111,243,99,95,79,
250,43,158,188,255,144,60,192,203,239,246,198,204,28,143,149,181,125,223,174,13,199,72,147,178,69,117,181,210,177,39,105,14,57,94,175,141,45,44,13,39,149,244,111,31,129,31,107,147,110,133,66,210,174,121,84,155,164,43,183,72,251,120,163,131,154,234,25,36,127,142,101,126,172,77,103,43,123,230,81,173,74,128,11,248,20,1,154,176,43,123,54,242,178,216,107,109,86,165,205,20,230,143,169,32,152,45,35,13,126,100,112,254,83,118,29,150,217,159,16,214,77,254,146,81,111,219,149,69,114,228,242,99,13,23,57,89,156,128,117,126,28,234,73,202,34,142,245,248,36,149,25,142,53,158,76,106,183,195,180,179,208,27,180,144,55,120,82,251,88,101,166,202,212,245,232,31,31,135,131,5,221,83,227,167,100,70,174,163,150,52,171,242,251,194,130,68,241,90,83,37,178,228,47,5,64,50,161,198,45,59,133,78,136,7,17,63,123,144,0,219,221,109,128,226,213,45,92,39,180,234,247,28,245,150,74,49,255,36,104,255,43,66,23,150,183,84,52,246,140,103,233,116,182,20,217,2,199,47,140,47,229,159,63,146,32,227,188,246,170,61,66,218,152,
117,88,26,235,165,13,142,189,206,23,113,56,198,179,236,133,57,246,115,252,30,61,170,210,226,177,56,238,6,102,39,23,208,162,116,251,3,237,1,140,72,213,155,18,194,9,231,238,55,67,110,131,135,215,165,62,111,126,63,86,180,85,1,72,131,225,185,34,44,231,242,35,204,15,200,107,23,228,66,90,16,78,70,16,82,177,132,212,3,99,28,159,7,55,158,48,82,121,156,76,196,66,166,122,191,30,90,152,49,229,104,54,119,15,44,7,68,219,54,152,97,18,70,247,52,33,217,190,214,25,70,111,21,130,224,216,168,65,48,22,233,77,97,1,179,207,135,153,229,9,121,206,29,99,191,125,115,126,81,39,209,211,106,21,88,20,85,46,148,204,78,237,74,219,230,69,165,163,211,43,203,111,80,170,28,200,231,81,236,233,124,66,2,233,207,242,10,48,174,99,218,210,198,70,206,207,230,43,108,146,169,116,207,244,154,181,49,154,199,36,220,224,126,99,113,249,110,35,62,88,184,248,185,130,58,175,134,96,233,158,183,186,211,57,76,238,59,140,96,34,104,216,127,36,235,168,3,76,37,97,181,60,115,98,65,114,104,114,104,88,149,75,47,139,143,189,164,137,101,84,
184,115,64,184,242,96,255,159,110,228,95,42,138,1,12,196,47,152,162,108,47,147,128,50,248,149,28,99,123,22,164,90,120,161,4,15,191,25,12,80,36,249,114,132,122,9,234,217,155,56,57,28,249,144,29,203,152,100,172,114,7,51,48,156,251,142,135,66,226,85,24,0,171,220,123,1,26,218,190,35,169,20,67,184,211,235,19,17,15,219,23,154,10,209,91,173,141,187,43,250,1,243,112,68,118,25,241,102,207,118,17,10,236,247,184,132,134,133,83,146,55,63,106,255,94,251,56,198,19,201,30,154,103,248,4,242,209,34,6,151,6,224,131,79,241,129,219,152,45,241,75,91,48,24,187,20,119,96,104,240,211,159,29,213,106,117,232,241,15,54,137,33,97,4,128,0,176,30,181,163,234,15,240,195,148,81,15,117,228,89,157,29,245,248,59,148,129,126,80,194,19,111,178,99,181,85,171,7,40,72,110,155,102,245,97,126,93,246,25,201,251,114,220,189,163,161,13,81,62,53,119,236,170,223,27,88,54,5,116,225,233,193,11,128,107,117,60,218,101,155,63,113,119,174,66,57,74,89,136,214,126,58,102,92,5,27,152,21,130,33,4,56,112,42,144,27,150,200,124,73,134,
168,160,75,251,76,38,65,70,156,217,96,246,120,96,188,197,162,79,219,208,51,108,227,68,67,35,172,103,100,160,30,69,208,64,117,117,1,237,48,3,11,25,51,147,17,91,22,168,21,218,227,251,133,199,96,103,54,236,52,65,217,201,18,210,25,140,199,239,109,85,131,7,170,190,22,132,147,157,221,34,50,229,236,38,2,129,146,108,43,112,210,135,74,53,127,211,139,226,2,145,124,65,134,60,80,46,146,202,154,4,240,132,187,25,129,14,17,146,34,10,244,154,195,120,202,14,146,39,77,166,57,71,87,244,126,206,38,20,93,91,151,1,191,203,160,138,68,103,249,70,234,67,68,171,184,149,189,88,255,241,255,105,176,143,203,248,141,198,227,68,18,105,128,232,8,10,255,14,2,48,193,119,32,93,143,17,116,147,49,76,159,89,31,124,75,186,177,248,135,185,225,137,71,233,84,225,147,34,229,129,125,228,160,127,213,157,227,164,68,210,98,214,41,109,199,65,196,71,122,168,160,77,251,124,152,17,154,148,185,174,190,18,38,150,76,100,195,208,157,34,246,17,176,118,25,161,80,56,195,88,204,86,191,140,200,122,125,27,139,191,234,48,205,53,217,60,18,
145,34,25,137,85,247,107,29,12,195,38,138,2,98,86,46,117,183,39,119,246,170,31,83,184,162,115,186,148,112,152,155,97,192,194,137,32,216,140,135,128,101,15,224,65,198,23,214,183,118,193,181,33,20,233,187,74,59,249,81,173,201,9,50,100,222,123,83,71,90,123,35,109,52,165,146,203,34,7,80,28,4,24,227,55,229,221,45,99,133,98,253,140,35,107,173,45,69,192,57,70,89,237,203,35,226,22,16,2,172,112,184,160,203,25,68,203,202,50,170,189,21,185,221,146,157,238,155,97,49,86,99,21,108,70,49,99,54,87,74,85,10,86,149,183,55,136,37,176,187,59,71,152,108,123,22,130,65,181,89,219,221,34,63,63,118,162,173,1,52,66,152,25,107,37,165,7,122,33,126,4,135,166,205,151,56,111,62,134,0,5,100,34,186,6,39,203,56,200,212,191,61,252,180,249,131,184,246,200,152,39,68,145,56,26,206,9,41,203,40,166,204,24,157,228,163,62,129,26,104,78,153,132,194,41,134,181,34,237,232,132,138,110,223,72,77,32,82,106,188,178,133,89,85,232,208,98,87,62,172,136,148,142,75,103,56,13,80,33,63,4,62,72,128,38,61,196,213,30,108,253,120,57,125,
92,243,255,88,123,55,113,126,130,158,48,17,72,72,29,143,126,90,192,65,103,64,224,242,167,186,78,136,213,121,181,219,255,64,84,217,126,34,241,151,128,236,194,143,178,9,244,83,34,87,106,63,14,218,104,141,234,107,13,251,205,84,20,157,71,29,249,248,220,117,226,143,219,246,152,126,250,163,9,65,169,202,136,13,242,8,81,167,210,182,63,149,218,181,223,77,250,113,61,246,83,29,72,62,49,58,40,212,12,26,31,38,237,110,132,68,189,214,31,191,230,191,235,195,96,239,100,6,128,127,52,45,250,37,163,187,222,126,124,98,54,121,40,65,179,62,28,65,235,27,32,225,243,23,67,18,184,164,254,248,85,80,187,255,239,232,50,159,252,240,35,150,171,14,25,221,13,192,253,21,38,126,67,230,219,209,225,254,191,253,80,127,188,241,82,113,125,184,9,222,221,103,167,75,33,70,136,138,109,163,205,31,183,245,226,227,114,46,162,19,40,83,187,34,9,49,53,140,124,112,73,62,114,90,243,122,118,243,147,186,177,249,68,120,50,217,151,63,213,137,88,222,178,75,245,83,253,174,151,71,82,136,77,24,37,246,206,242,87,140,109,168,33,33,224,142,
217,174,132,49,166,108,14,212,227,172,32,6,89,250,141,217,120,114,148,53,217,168,101,102,85,50,36,121,102,134,192,88,254,186,109,122,240,34,7,146,200,122,32,182,248,19,196,13,90,34,73,102,231,114,17,34,86,233,122,27,136,68,166,112,76,162,69,107,225,247,226,31,177,235,99,43,153,83,56,98,48,139,187,124,219,239,18,119,239,44,212,38,170,186,99,70,15,165,147,184,157,58,136,247,189,51,140,81,54,4,89,70,96,15,67,164,47,68,217,28,132,150,247,173,253,73,36,143,41,137,240,160,120,219,44,98,55,57,204,209,34,18,170,48,123,48,133,196,196,62,74,226,236,185,225,103,234,43,244,150,66,96,194,203,132,233,178,254,146,150,73,143,0,119,113,195,230,169,29,29,170,39,15,92,70,198,100,18,12,86,172,49,207,139,128,150,147,20,45,6,53,45,81,128,27,221,11,4,188,77,91,80,161,96,180,197,92,56,123,171,93,73,233,20,33,26,177,239,24,132,240,20,34,22,222,131,146,44,173,223,106,11,27,66,27,213,228,110,184,145,163,206,42,150,117,182,232,4,36,155,178,188,89,168,106,55,203,192,51,171,177,218,123,213,82,41,55,13,4,224,
152,250,62,79,22,183,185,228,205,138,82,98,32,64,72,194,145,20,166,165,83,43,28,152,24,153,209,192,252,140,187,91,98,187,88,116,95,201,74,144,195,158,153,217,44,91,68,115,229,72,211,118,132,225,188,112,195,51,63,68,233,179,54,123,64,195,203,44,80,20,3,19,197,148,178,145,221,61,178,244,34,110,133,253,178,182,131,93,99,195,51,236,170,85,244,123,193,119,160,233,83,254,183,236,7,29,250,13,7,140,197,14,182,239,145,115,202,94,33,27,209,165,188,173,18,83,129,23,35,168,149,244,162,44,111,147,243,131,111,101,102,39,139,164,198,4,144,44,205,88,24,232,143,208,26,68,137,43,36,215,163,5,178,112,252,65,45,216,176,178,96,136,153,226,248,105,88,151,215,74,179,2,46,104,193,114,202,144,113,132,102,144,253,122,36,47,160,75,96,65,59,39,242,28,216,212,36,23,1,79,135,124,45,132,173,231,155,160,87,162,153,130,23,239,71,113,34,73,25,140,182,74,100,61,42,243,17,162,215,224,149,83,31,182,104,150,139,43,195,143,104,182,31,146,142,246,155,99,56,120,165,118,60,56,37,217,36,103,85,228,173,20,138,120,132,71,
144,94,224,152,6,51,83,54,164,195,231,224,226,52,144,1,237,164,126,30,83,170,31,71,14,46,167,18,162,115,144,231,202,67,57,117,84,38,39,170,137,70,176,228,199,37,114,8,137,132,77,202,250,146,17,202,101,95,210,55,161,49,227,6,57,48,176,174,161,103,179,110,171,173,243,50,10,197,160,127,250,221,185,178,61,162,24,54,220,38,66,52,246,96,162,41,65,51,66,65,241,26,219,87,54,17,24,210,1,57,145,24,178,116,44,169,44,200,111,179,222,203,49,44,159,5,233,58,34,161,242,154,29,53,232,4,0,77,98,120,180,211,146,6,13,148,156,12,120,140,83,181,64,160,116,81,30,146,122,234,214,37,1,22,9,187,76,152,188,74,16,136,189,176,127,106,209,51,157,72,211,171,245,243,98,122,47,161,248,186,245,140,127,21,215,238,37,71,118,98,69,65,186,141,188,99,49,172,224,40,216,240,54,13,3,62,122,162,101,134,136,177,76,225,78,201,66,183,92,198,11,160,214,185,78,172,0,229,101,194,74,150,143,66,144,160,0,9,22,94,130,112,145,188,197,185,62,84,53,145,208,112,57,135,191,26,44,65,140,113,5,39,211,216,218,227,13,22,151,216,40,6,49,
149,167,152,76,50,146,253,102,213,39,211,224,69,213,183,78,157,241,191,22,71,136,34,62,98,170,8,26,220,143,66,36,182,207,125,29,33,89,161,108,23,208,81,120,237,165,199,238,134,69,132,18,36,211,44,191,37,244,15,210,36,122,36,31,137,76,70,124,85,38,23,123,94,25,19,208,154,43,173,180,242,150,70,72,66,12,129,110,13,221,230,150,49,90,18,49,80,57,3,228,183,211,42,98,81,89,199,214,150,94,172,119,243,252,83,183,63,152,5,33,152,138,48,120,87,38,102,172,84,33,9,53,5,146,192,178,168,128,237,134,78,68,4,221,190,40,245,14,39,242,44,244,89,245,80,13,115,5,1,185,25,7,201,137,254,150,170,71,115,82,75,70,3,49,242,111,131,0,32,131,130,148,86,203,255,109,72,240,123,112,194,213,76,104,41,190,58,90,199,73,45,96,10,118,220,231,220,84,132,52,206,138,112,108,62,97,226,5,200,87,144,199,209,48,203,189,241,104,127,193,163,69,23,94,143,26,110,236,7,155,127,209,193,173,120,21,125,11,144,52,156,78,253,229,232,60,175,244,131,83,79,20,194,82,180,230,126,7,194,190,28,113,57,135,245,199,191,10,177,39,127,205,
81,12,93,51,90,119,118,211,56,220,137,158,147,119,233,142,86,248,92,58,142,159,247,125,66,183,43,220,157,66,196,225,235,40,250,80,65,150,76,71,219,8,33,78,44,52,59,166,42,22,99,112,60,163,155,148,172,156,252,207,195,157,202,155,96,197,116,80,34,225,100,12,144,1,101,249,167,168,155,31,11,151,19,44,191,111,88,233,142,198,53,94,101,61,35,180,118,245,83,61,121,213,105,235,177,41,9,169,16,153,105,63,110,183,31,111,21,78,91,132,234,51,206,155,185,120,63,110,203,72,125,92,51,39,110,45,206,211,201,158,130,208,171,204,151,60,8,28,32,137,98,236,247,46,125,39,134,152,150,177,160,217,115,189,148,11,139,136,212,218,124,120,31,142,245,56,17,5,254,127,25,241,255,87,70,76,201,98,125,86,92,224,190,47,166,119,130,22,111,217,89,182,211,146,170,189,140,57,58,36,240,35,127,97,8,26,72,193,46,125,52,18,204,138,189,233,217,13,187,57,211,49,121,67,236,209,246,116,128,177,159,115,252,90,78,232,146,222,160,70,21,13,176,32,148,122,70,229,150,221,202,111,149,166,117,3,73,42,22,193,133,135,162,184,39,204,
109,64,152,113,27,2,170,21,69,139,34,92,224,196,160,232,151,66,234,71,78,164,37,109,24,115,215,129,204,210,31,41,142,174,163,239,128,134,133,207,70,232,216,126,8,102,153,218,116,83,152,173,206,180,54,129,129,157,36,81,153,29,72,179,244,112,130,71,165,77,108,155,125,142,115,95,152,140,178,187,170,49,2,115,0,60,239,91,165,139,138,237,250,191,158,18,16,83,25,153,161,54,220,240,67,91,251,90,152,48,56,162,171,44,147,226,208,97,112,64,6,164,188,6,189,117,78,232,176,246,86,59,51,24,38,33,29,53,4,226,237,5,168,224,79,197,16,16,224,33,193,209,210,20,202,173,254,96,163,7,195,170,200,103,85,170,173,76,63,48,37,227,95,219,111,222,95,120,61,164,45,227,210,153,250,244,61,22,98,239,237,137,109,36,208,60,120,214,209,227,176,158,25,229,20,203,7,164,201,252,185,251,14,119,131,19,133,246,133,227,220,90,103,102,65,21,32,223,104,175,108,163,219,22,119,152,60,201,22,233,137,61,67,152,97,143,79,97,214,152,194,234,204,28,87,199,166,0,177,135,36,89,216,30,134,66,76,44,116,59,246,101,72,178,253,56,163,
1,71,140,246,152,189,154,94,121,58,133,89,60,135,150,197,128,74,12,229,48,138,165,46,184,141,38,179,86,71,144,64,94,188,205,131,147,169,91,195,59,115,181,168,208,131,227,104,6,171,177,137,67,27,38,115,107,39,35,0,169,158,180,46,83,27,196,10,169,51,192,32,192,224,53,147,124,98,120,70,243,1,161,99,238,148,48,243,82,186,146,216,145,182,145,44,212,191,249,63,146,142,205,34,166,197,108,62,178,138,2,190,109,235,0,73,48,216,197,17,176,177,202,121,88,140,68,116,142,231,232,119,78,40,72,175,179,53,247,177,67,77,42,0,45,177,21,119,174,99,85,133,232,20,130,167,120,150,14,42,187,106,23,133,88,76,160,128,40,21,154,179,149,162,229,101,143,51,228,33,24,182,0,162,215,104,112,129,4,1,225,144,155,247,202,165,121,134,3,167,76,219,192,76,65,183,58,254,218,137,7,3,142,172,208,48,178,7,132,72,202,183,143,149,28,45,36,73,136,8,192,12,178,80,140,172,216,67,164,23,19,41,198,12,37,20,94,43,142,81,188,234,147,3,64,207,226,85,59,43,202,174,21,27,195,6,52,179,12,123,112,172,204,234,116,238,246,132,148,118,
44,46,130,64,128,106,135,142,221,226,40,215,6,46,104,3,29,150,22,24,124,151,247,240,182,157,17,32,57,60,93,36,168,114,229,251,74,92,138,16,185,104,110,196,175,106,72,42,12,187,228,58,175,44,97,107,22,32,194,100,116,205,91,97,175,77,242,54,87,238,52,190,88,248,73,41,249,79,145,173,16,49,203,101,187,24,88,41,222,67,5,92,203,114,121,143,87,24,251,18,208,100,195,168,4,105,155,220,103,72,13,15,95,135,28,185,31,67,122,78,84,49,178,60,108,59,150,105,52,33,150,134,6,69,230,202,114,32,171,134,205,19,139,64,42,136,17,66,42,199,138,160,89,182,49,52,34,206,0,105,154,80,113,156,197,182,77,195,126,4,221,134,20,99,80,119,172,19,151,76,215,182,64,65,247,120,18,105,217,60,79,217,119,132,157,153,255,157,85,101,161,244,163,243,134,9,18,122,138,197,12,165,153,3,213,123,48,218,232,71,107,168,9,160,148,168,162,25,227,119,156,167,187,33,101,74,122,149,82,63,115,59,80,167,104,9,225,116,115,198,193,239,175,44,142,14,42,240,131,214,231,114,124,77,156,109,91,89,46,164,5,3,19,42,163,88,88,198,35,245,199,
182,141,197,33,42,34,18,215,24,9,73,146,144,117,43,48,162,235,44,47,93,113,44,5,34,125,199,88,31,185,30,102,20,231,96,108,9,58,84,14,19,24,213,176,8,26,143,56,28,42,160,140,202,164,99,195,9,97,224,167,76,149,128,83,212,41,224,73,50,196,208,236,9,125,182,61,237,227,122,149,38,175,59,97,185,8,189,145,37,109,136,205,162,252,96,20,199,0,40,193,10,40,142,244,176,195,27,252,112,245,181,69,148,228,200,113,212,108,237,234,91,205,16,22,190,28,101,165,68,244,235,122,168,119,3,29,41,74,198,178,215,23,122,178,253,105,97,104,217,84,50,4,173,229,147,248,244,252,4,91,69,148,139,197,227,81,133,118,160,25,159,112,49,247,20,209,112,49,74,36,5,55,140,111,71,105,88,59,31,40,232,19,73,93,209,136,128,95,132,59,123,92,65,1,95,203,105,107,211,78,97,120,139,170,105,57,36,56,83,201,178,216,25,219,134,106,15,139,59,99,251,138,167,19,101,69,46,128,198,55,59,100,57,120,180,186,36,19,63,193,28,8,201,83,154,138,216,137,75,143,105,207,222,166,111,8,216,242,165,156,117,108,232,18,96,115,214,82,12,165,11,74,94,
189,197,99,150,211,129,47,119,164,69,150,6,91,85,59,106,34,80,39,72,40,44,18,155,217,17,112,164,18,159,48,24,98,113,20,163,222,226,155,197,204,148,252,166,82,71,78,188,110,17,107,105,188,90,138,164,203,21,55,247,96,129,42,11,210,180,168,31,192,103,84,60,107,181,180,224,104,194,34,186,106,73,6,55,25,145,102,212,168,160,101,238,202,81,75,16,234,180,200,181,181,215,195,155,233,122,4,187,64,150,133,170,100,248,218,255,75,182,200,106,235,98,201,170,155,113,97,156,45,48,203,145,173,211,4,215,255,130,203,232,185,204,96,138,102,75,160,139,34,187,183,236,2,244,59,130,130,128,52,203,77,138,57,16,34,207,11,98,211,68,99,18,176,150,86,58,39,251,132,194,84,214,111,72,254,117,63,61,234,42,223,167,178,136,168,44,27,132,61,235,249,20,241,135,68,83,26,227,12,21,228,133,99,138,175,193,36,85,198,172,173,72,108,102,177,108,255,85,38,115,245,101,255,221,180,116,124,162,115,134,254,25,75,34,57,3,234,59,220,142,4,165,104,148,141,10,53,26,183,126,56,112,92,212,235,126,141,31,71,57,149,226,210,40,214,
39,110,213,148,246,155,81,8,71,245,218,236,212,123,53,12,219,63,10,182,107,212,195,97,219,15,179,119,126,73,165,183,129,204,232,32,97,220,42,128,245,163,148,15,216,224,119,106,57,40,29,219,171,81,204,25,219,115,60,149,107,165,99,143,19,174,75,194,142,228,8,11,230,62,205,10,133,135,134,187,9,89,163,42,89,215,203,158,95,188,141,6,145,164,159,27,101,44,48,78,79,88,153,115,41,156,109,43,96,157,233,115,205,206,34,21,140,99,44,133,204,49,160,2,47,96,59,248,174,136,229,168,122,183,113,203,34,233,53,217,185,120,14,141,69,137,148,114,146,49,188,236,12,147,22,58,27,109,199,183,76,42,17,38,150,7,39,119,1,133,108,50,139,230,196,220,13,20,145,147,221,56,86,81,234,74,225,37,219,35,32,88,1,118,75,139,40,253,232,103,226,111,155,178,79,44,100,50,179,8,50,7,200,38,118,233,25,227,201,190,235,99,47,144,211,97,84,185,17,236,22,217,44,74,163,2,147,207,172,26,146,119,187,20,147,17,137,194,170,1,14,254,36,239,67,21,165,176,50,17,133,73,119,9,10,47,226,187,113,163,93,199,66,173,46,103,210,83,200,39,131,
189,25,65,155,134,80,183,246,189,144,195,236,81,226,230,105,68,185,238,172,168,204,9,140,58,136,36,210,170,73,101,69,89,205,76,83,172,65,175,211,89,136,82,128,126,75,93,45,23,160,72,92,13,83,193,156,247,93,47,180,105,160,145,122,21,135,113,11,172,130,70,211,204,208,102,196,192,153,151,194,211,58,109,228,36,29,135,101,164,71,196,61,210,218,211,77,109,57,132,187,161,204,80,3,74,193,24,157,73,224,36,24,189,249,234,164,227,83,78,238,75,6,145,251,13,44,212,118,112,14,144,125,24,165,158,219,37,80,143,212,20,46,78,4,193,140,10,32,174,236,238,90,39,97,95,87,141,77,124,244,44,249,213,83,221,64,96,96,97,209,138,11,4,137,23,77,211,23,143,47,128,99,50,144,249,93,200,106,147,68,46,132,164,163,81,218,48,96,205,4,165,122,51,124,133,169,132,135,182,143,204,163,4,14,196,182,27,36,62,17,103,72,230,161,58,137,40,24,178,86,145,60,168,220,176,144,158,224,249,51,133,24,113,91,148,145,249,206,147,245,159,75,164,43,21,242,37,86,106,230,223,246,182,178,64,219,254,125,127,43,123,129,76,126,26,14,242,215,
14,182,178,179,232,221,188,36,18,158,27,119,197,190,97,93,13,206,141,15,212,246,55,111,8,5,47,167,221,151,70,24,210,44,203,157,79,195,17,193,3,21,82,151,38,90,103,233,231,19,210,240,65,230,146,133,116,253,82,30,6,73,39,234,233,239,233,228,48,3,241,138,96,181,112,170,58,109,93,11,95,82,210,112,96,193,179,230,16,14,166,70,26,171,2,255,196,142,51,112,169,99,193,23,27,218,162,112,58,244,109,105,35,6,115,45,213,173,57,126,78,22,182,25,221,214,190,111,65,21,106,225,164,97,52,70,185,59,115,56,168,96,206,238,199,13,174,98,244,109,29,194,82,148,82,84,63,247,190,41,106,225,7,225,13,248,252,166,127,53,163,144,173,216,33,252,220,38,129,254,54,232,48,227,83,158,94,142,57,129,82,157,217,27,142,10,23,147,210,203,14,116,61,197,157,170,138,158,122,240,205,189,207,236,74,135,160,9,201,88,20,21,163,206,233,207,198,166,120,21,41,93,54,162,67,223,237,233,52,178,24,10,25,200,73,101,102,135,194,180,147,23,136,57,175,173,227,29,24,201,152,180,195,250,194,181,151,241,98,231,119,80,182,169,150,138,44,
225,161,215,81,22,129,125,57,230,40,68,183,71,98,136,101,162,88,210,129,96,80,164,3,63,13,62,87,32,81,80,186,130,3,19,174,218,190,147,66,199,191,206,201,149,69,145,93,227,199,91,196,176,196,135,40,164,190,90,68,222,151,134,42,67,234,178,48,97,198,95,84,228,27,122,179,2,168,232,102,171,125,106,53,144,28,85,96,205,221,78,48,101,24,20,155,253,119,174,109,176,74,147,130,65,218,191,80,66,46,140,225,70,123,219,72,206,78,160,169,142,40,42,119,3,3,64,232,19,42,63,218,79,248,161,169,25,33,43,20,14,243,11,42,58,48,143,157,162,9,157,45,204,189,156,69,164,22,176,119,188,196,132,136,139,227,7,68,66,116,220,32,45,68,168,29,180,83,238,15,64,45,189,177,39,220,143,161,240,84,176,10,138,138,172,15,20,78,129,126,162,255,230,231,174,241,60,140,185,24,252,189,199,137,66,154,155,187,36,218,235,83,121,123,22,228,216,113,19,79,202,99,35,250,81,31,156,162,250,247,91,156,13,36,182,153,140,80,69,113,233,10,41,40,128,171,197,58,213,237,165,128,140,18,213,12,115,231,107,233,106,185,133,137,168,52,168,156,
67,36,22,115,116,73,229,102,114,193,239,81,126,89,182,118,222,195,230,148,105,229,167,63,56,66,61,38,12,2,156,63,136,33,79,130,99,40,205,244,52,172,241,43,150,29,229,64,248,224,123,10,172,124,111,59,130,63,216,63,63,124,223,254,254,207,45,142,83,214,190,215,197,205,252,200,129,100,126,108,95,242,81,39,173,191,223,226,13,62,207,62,206,248,47,39,95,99,142,105,42,96,35,246,68,101,225,168,151,136,178,164,13,163,79,91,154,106,174,25,230,18,232,55,191,180,160,192,180,99,189,231,168,80,45,50,187,235,183,205,28,205,44,14,212,12,173,166,164,108,108,236,178,202,120,51,237,45,145,211,172,203,175,22,8,132,75,0,130,160,48,22,28,176,195,132,61,98,90,196,168,48,62,177,120,35,157,218,253,40,114,159,93,145,187,24,199,40,83,13,87,201,47,23,113,18,77,38,119,157,109,89,79,148,57,19,100,59,167,86,51,72,36,238,4,215,189,6,88,83,100,207,201,243,82,25,217,130,104,9,227,178,99,32,130,47,148,68,65,242,97,14,190,123,84,152,122,11,252,185,90,54,165,230,91,209,167,77,228,83,82,43,49,18,60,235,80,162,8,87,
219,143,40,232,244,133,5,10,55,45,156,32,203,71,41,87,137,23,24,128,22,159,73,174,96,114,128,114,169,248,96,43,72,212,121,6,23,45,159,6,19,50,141,109,194,144,249,88,24,247,154,209,22,210,52,148,214,207,9,255,22,66,200,195,52,201,192,46,25,170,228,103,231,12,205,226,51,157,96,57,0,84,188,214,89,33,183,34,248,132,230,8,53,137,100,125,23,226,3,232,46,200,127,150,222,210,122,134,2,72,34,5,19,208,1,31,229,169,78,59,127,100,231,164,113,198,77,173,71,129,168,215,187,253,235,190,249,4,193,168,219,120,251,250,103,63,214,45,183,70,30,91,96,235,35,162,1,239,127,255,177,63,164,166,250,180,243,19,105,202,224,120,139,243,234,228,171,13,102,63,213,147,229,169,123,58,56,80,166,35,121,41,120,189,133,47,194,241,124,254,129,5,82,152,93,80,36,67,216,43,159,31,135,105,24,45,68,84,184,249,70,255,20,250,55,125,114,35,134,234,90,149,102,105,24,165,44,114,8,46,70,185,125,187,73,212,43,237,175,162,91,202,223,48,122,12,5,167,44,25,209,140,6,23,217,120,123,11,38,106,12,105,21,187,58,214,79,144,228,77,174,
169,21,219,177,134,30,111,145,148,214,120,60,216,225,56,33,103,61,134,233,179,128,120,153,154,18,223,197,35,202,162,29,53,185,207,64,101,66,120,232,113,81,117,108,158,101,26,241,34,154,70,154,23,249,92,230,230,197,38,219,92,35,30,213,23,120,208,73,80,237,99,89,120,53,182,217,60,210,25,224,78,111,115,35,132,162,227,3,189,188,169,18,200,111,136,234,196,137,88,16,146,250,58,160,89,169,65,18,144,90,140,106,151,101,132,210,195,92,8,58,69,212,93,192,176,203,7,39,42,212,109,238,122,217,179,56,207,124,206,14,165,114,8,190,51,242,115,229,140,64,180,42,255,36,157,104,233,111,174,71,121,47,92,124,44,162,94,0,192,122,46,203,181,69,224,93,232,170,253,194,84,179,141,16,42,215,154,177,84,129,165,236,54,247,182,238,98,39,12,135,220,16,66,52,99,202,23,199,240,214,194,90,186,232,212,14,50,222,15,90,209,21,47,107,30,145,42,23,146,110,52,119,45,234,18,216,21,242,228,92,171,228,191,110,152,71,221,26,229,216,26,217,39,195,135,25,85,195,118,195,126,110,200,121,43,85,117,28,188,28,83,164,183,109,251,
250,54,52,128,153,125,129,106,97,105,163,25,227,83,81,160,203,114,92,1,32,201,68,142,40,148,250,82,253,36,95,120,108,86,56,200,96,241,114,100,197,89,109,191,5,171,120,11,46,34,226,80,145,3,230,190,73,180,105,135,64,55,190,220,243,233,216,203,142,29,104,51,216,174,110,9,162,219,146,166,217,91,24,249,213,90,70,227,186,174,14,176,130,244,130,213,36,190,240,222,103,77,51,66,142,72,68,157,77,40,170,170,159,52,248,22,145,219,109,219,38,183,231,153,172,141,178,121,50,52,90,227,211,175,150,131,182,138,65,91,97,80,146,154,123,31,237,115,113,11,87,248,230,91,139,18,214,113,100,127,167,58,242,170,247,181,154,101,15,218,16,241,245,75,48,176,91,0,179,187,4,152,37,83,226,162,28,213,197,5,71,97,95,3,107,7,26,129,224,166,214,65,132,211,187,91,13,231,154,93,47,76,33,210,31,51,88,25,134,126,75,62,5,59,44,221,154,171,107,227,31,187,194,12,126,243,221,201,162,186,153,40,84,44,6,158,204,238,115,197,19,93,236,162,6,90,97,11,250,149,244,133,17,104,92,102,60,106,10,75,37,183,238,191,83,183,17,210,103,
24,5,164,204,203,45,41,90,199,192,93,177,103,101,23,114,18,102,9,39,210,108,99,145,87,206,122,159,29,238,233,120,4,152,94,0,44,246,31,71,252,69,210,17,88,205,145,36,6,12,185,149,145,143,128,174,183,1,125,11,166,75,58,1,23,7,169,21,36,25,101,247,0,152,205,194,8,114,78,225,9,43,75,7,150,87,86,199,181,203,55,211,208,27,206,49,187,181,158,76,239,29,40,71,5,105,100,40,142,75,227,87,210,145,202,35,223,70,168,236,18,41,70,40,121,105,143,106,129,90,1,161,62,92,241,39,69,48,113,238,239,40,29,70,223,232,68,2,50,31,40,88,22,8,203,50,6,182,51,75,51,122,74,160,32,151,156,104,113,186,239,205,63,107,173,157,131,236,45,81,118,221,212,8,178,21,8,173,181,184,83,86,215,81,200,158,222,208,91,155,181,214,190,90,199,111,187,59,123,86,126,254,213,152,250,149,120,239,181,221,157,195,236,162,216,131,63,11,54,0,63,63,204,222,70,59,189,8,121,213,246,24,90,133,1,207,92,161,241,221,187,123,174,82,11,124,219,85,154,140,87,130,173,237,113,109,244,91,18,9,226,229,95,217,115,2,13,140,184,215,220,141,240,98,43,
142,253,146,197,218,94,235,145,125,123,37,229,21,186,207,107,123,187,205,248,37,123,65,82,18,170,252,185,159,207,45,223,212,97,71,60,58,92,138,46,135,154,53,224,53,217,110,168,132,128,128,253,157,150,193,252,51,190,33,97,165,218,62,80,158,123,21,103,29,130,254,0,84,10,38,243,251,33,169,74,201,229,110,231,126,179,2,15,30,209,65,44,184,104,167,53,177,59,189,40,114,109,127,127,79,55,41,140,114,15,142,134,73,134,177,205,41,20,209,129,21,12,26,20,199,121,56,124,36,96,159,113,34,227,122,84,84,225,43,172,51,17,177,22,126,187,185,69,154,46,13,45,155,7,242,72,30,52,179,27,4,6,219,127,74,195,70,156,44,148,161,113,231,16,45,70,201,15,14,51,67,192,122,247,231,147,139,7,217,139,147,227,103,214,171,142,216,145,28,168,98,45,82,145,231,52,40,64,224,77,221,242,169,193,181,145,35,18,83,92,78,53,78,136,48,75,102,162,238,137,91,65,131,155,33,104,166,139,232,36,215,175,21,133,226,61,243,62,21,180,48,95,81,195,171,178,97,131,132,101,178,81,20,46,2,122,217,187,204,66,215,40,64,189,188,82,20,104,4,160,
127,239,147,168,196,192,202,169,16,61,199,106,246,117,253,64,218,177,119,129,78,15,80,91,213,139,88,40,71,174,170,116,161,78,104,23,225,130,24,15,55,248,98,152,28,81,167,188,144,128,1,226,133,121,118,130,43,98,72,211,250,0,129,140,147,24,52,247,201,149,89,43,81,235,203,106,78,16,3,91,109,218,244,226,115,153,160,86,190,50,82,128,230,190,94,250,32,61,199,68,65,189,84,230,182,221,207,21,244,250,133,102,222,191,56,121,249,198,38,122,242,130,15,156,114,137,70,236,0,62,80,90,166,101,120,9,177,33,28,233,246,16,62,53,130,33,92,173,1,6,131,5,235,89,81,113,59,47,32,171,200,1,9,157,185,74,150,237,224,85,251,132,19,82,84,88,251,198,149,10,116,171,190,28,79,117,69,11,227,218,70,12,165,104,224,138,201,96,126,221,32,185,206,20,96,17,42,2,230,57,17,122,6,123,1,192,192,207,106,96,211,225,157,90,34,19,43,15,124,118,27,25,91,142,92,181,2,138,137,6,43,108,105,142,137,113,142,165,243,68,110,80,74,17,194,217,118,29,245,148,4,89,50,2,233,95,44,26,69,136,92,133,112,110,12,27,144,86,55,189,193,228,62,
147,226,226,88,169,18,165,183,122,32,144,89,75,6,121,249,122,209,123,248,33,68,81,98,156,172,141,33,234,115,113,19,191,195,177,192,169,109,204,112,118,176,157,219,9,62,58,20,1,7,120,237,166,81,85,253,160,162,49,71,98,186,220,69,35,134,64,221,60,231,167,50,39,81,175,196,59,102,162,198,197,25,144,74,218,132,9,224,4,66,58,58,217,130,7,21,138,120,155,50,83,40,2,147,68,41,67,243,81,31,79,165,176,7,240,130,60,91,142,208,135,40,69,35,24,255,6,129,130,65,194,109,0,170,171,108,134,151,149,82,146,210,37,203,207,4,142,37,74,89,114,145,34,121,210,112,241,118,67,76,115,172,112,239,209,32,100,204,17,213,14,132,112,37,58,235,25,34,97,42,69,136,174,98,148,2,157,182,64,225,74,86,86,8,116,218,78,203,70,163,241,163,92,205,199,148,10,87,112,40,210,164,208,54,224,190,188,14,206,2,162,200,75,194,200,19,208,13,128,128,161,242,109,10,242,87,113,169,245,211,125,77,26,44,236,236,34,1,181,65,108,65,104,61,182,59,33,141,242,204,118,189,244,59,121,178,70,195,8,38,126,221,214,55,211,3,10,251,129,119,15,244,
70,87,196,194,246,140,226,46,88,112,212,191,91,152,107,162,51,48,138,198,29,221,7,229,116,9,220,23,227,176,255,165,12,87,232,219,114,73,16,106,110,167,4,189,232,129,60,206,162,178,48,49,26,80,200,229,186,131,204,118,144,225,103,171,246,27,52,69,165,150,163,64,192,194,193,239,206,36,175,78,47,8,95,114,170,39,239,113,243,220,228,110,106,251,47,173,157,214,65,246,132,11,84,254,204,78,68,17,240,168,196,232,70,116,69,148,13,187,120,71,140,242,178,50,74,168,203,200,240,74,104,114,207,32,176,30,174,36,145,13,250,97,107,193,235,248,83,253,31,11,84,138,5,186,147,125,32,157,33,217,114,169,67,173,34,21,185,117,241,2,64,186,137,114,202,200,41,65,89,12,89,149,145,7,160,212,90,214,207,67,162,66,29,234,97,144,174,18,226,66,44,61,62,50,69,38,3,14,229,104,245,133,17,111,36,2,143,116,189,180,96,16,62,245,216,228,168,143,160,174,13,69,38,170,108,47,74,112,146,183,40,243,75,255,246,108,90,182,23,156,223,144,123,34,223,160,15,249,106,247,197,54,136,133,106,147,95,219,208,49,222,238,64,51,149,90,13,
246,64,132,46,232,37,72,90,8,181,59,5,84,240,86,147,161,162,187,69,38,40,22,22,178,49,64,209,21,25,217,164,123,186,12,130,178,115,106,223,50,162,106,110,233,29,65,238,206,189,166,86,216,112,4,193,44,136,226,41,8,154,139,83,128,180,6,129,104,113,175,37,215,24,16,158,48,30,30,113,83,58,176,35,128,28,97,140,11,122,245,83,156,142,84,210,165,210,171,205,218,144,194,3,191,247,166,137,56,184,120,113,146,157,191,121,126,241,203,241,217,9,247,129,101,111,207,222,252,251,233,179,147,103,89,253,248,156,239,108,72,252,114,122,241,226,205,187,139,140,22,103,199,175,47,126,205,222,60,207,142,95,255,154,253,243,244,245,179,7,220,163,245,246,236,228,252,60,123,115,150,157,190,122,251,242,244,132,223,78,95,63,125,249,238,217,41,209,197,39,188,247,250,13,84,126,10,173,211,233,197,155,76,3,134,174,78,79,120,239,121,246,234,228,236,233,11,122,62,126,114,250,242,244,226,215,7,217,243,211,139,215,234,243,57,157,30,103,111,143,207,46,78,159,190,123,121,124,150,189,125,119,134,157,117,194,240,207,232,
246,245,233,235,231,103,140,114,242,234,228,245,197,22,163,242,91,118,242,239,124,201,206,95,28,191,124,105,67,29,191,3,250,51,131,239,233,155,183,191,158,157,254,252,226,34,123,241,230,229,179,19,126,124,114,2,100,199,79,94,158,248,80,76,234,233,203,227,211,87,15,178,103,199,175,142,127,22,116,103,217,27,0,62,179,102,1,186,95,94,156,216,79,140,119,204,255,159,94,156,190,121,173,105,60,125,243,250,226,140,175,220,5,246,230,236,162,120,245,151,211,243,147,7,217,241,217,233,185,16,242,252,236,13,221,11,157,188,33,156,189,214,123,175,79,188,23,161,218,160,46,86,132,38,66,216,59,38,93,192,242,236,228,248,37,125,177,60,175,43,141,183,106,255,71,0,0,0,0,255,255,3,0,175,39,168,48);

label
   redo,skipend;
var
   s,d,i:tobject;
   xcount10,p,p2,slen:longint;
   lv,v,lx,x:byte;
   xhelp,xtopiconce,xlist,xcon:boolean;
   xtopics:tdynamicstring;
   n,str1,xstop,xtopic,xsubheading,xunderline,xconsole,xconsoleWRAP:string;

   procedure xaddone(xval:byte);
   begin
   str__sadd(@d,char(xval));
   end;

   procedure xaddstr(xval:string);
   begin
   str__sadd(@d,xval);
   end;

   procedure xstopconsole;
   begin
   if xcon then
      begin
      xcon:=false;
      xaddstr(xstop);//stop multiline console display
      end;
   end;

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

   procedure xbacktotopics;
   begin
   if xtopiconce and xhelp then xaddstr('<a class="navbut" href="#topics">&#9206; Help Topics</a><br>'+#10);
   end;

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
   n3:=strlow(strcopy1(a.value[p],1,3));
   //.turn console on
   if (not xcon) and ((n3='[k]') or (n3='[j]')) then xcon:=true;
   if xcon then//don't clean within console code [k]...[/] or [j]...[/]
      begin
      str__sadd(@s,a.value[p]+#10);
      lempty:=false;
      end
   else
      begin
      a.value[p]:=stripwhitespace_lt(a.value[p]);
      xempty:=(low__len32(a.value[p])<=0);
      if (not xempty) or (not lempty) then str__sadd(@s,a.value[p]+#10);
      lempty:=xempty;
      end;
   //.turn console off
   if xcon then
      begin
      str1:=a.value[p];
      if (str1<>'') then
         begin
         for p2:=1 to low__len32(str1) do if (str1[p2-1+stroffset]='[') and (strcopy1(str1,p2,3)='[/]') then
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
str__sadd(@s,#10);//enforce a trailing return code
slen:=str__len32(@s);
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
      if (n='commandline') then xaddstr(xconsoleWRAP+net__encodeforhtmlstr(cmdline__output('--help'))+xstop);
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
   str__sadd(@i,'<a name="topics">&nbsp;</a>'+xtopic+'Help Topics'+xstop+'<br>'+#10);
   str__sadd(@i,'<div class="help-topics">'+#10);
   str__sadd(@i,'<ul>'+#10);
   for p:=0 to (xtopics.count-1) do str__sadd(@i,'<li><a href="#'+xlinkname(xtopics.value[p])+'">'+net__encodeforhtmlstr(xtopics.value[p])+'</a>'+#10);
   str__sadd(@i,'</ul>'+#10);
   str__sadd(@i,'</div>'+#10);

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

function log__info(xname:string):string;
begin
//defaults
result:='';
xname:=strlow(xname);

//get
if      (xname='ver')      then result:='1.00.085'//18jun2025
else if (xname='name')     then result:='Bubbles Log Generator'
else
   begin
   //nil
   end;
end;

procedure log__makereport(var a:pnetwork;slogfilename:string);
label
   skipend;
var
   d:tobject;
   dreportfilename,dmakeref,v,e:string;
   dlen,p,p2,lv:longint;
begin
//defaults
d:=nil;
dreportfilename:=slogfilename+'.html';

try
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
   dlen:=str__len32(@d);
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
//free
str__free(@d);
end;

function log__buildreport(var a:pnetwork;d:tobject;dmakeref,slogfilename:string):boolean;
label
   makereport,redo;

const
   xread_chunk_size             =5000000;//read the log file in 5Mb chunks

var
   s                            :tobject;
   xstarttime                   :longint64;
   spos                         :longint64;
   xcount                       :longint32;
   li                           :longint32;
   i                            :longint32;
   lp                           :longint32;
   p                            :longint32;
   slen                         :longint32;
   xonce                        :boolean;
   c                            :byte;
   xlarge_limit_label           :string;
   xnav                         :string;
   vip                          :string;
   vdatetime                    :string;
   vmethod                      :string;
   vfilename                    :string;
   vext                         :string;
   vprotocol                    :string;
   vreferrer                    :string;
   vuseragent                   :string;
   vsite                        :string;
   vcode                        :longint32;
   vtotal_requests              :longint64;
   vtotal_hits                  :longint64;
   vtotal_bandwidth             :longint64;
   vtotal_time                  :longint64;
   vbandwidth                   :longint64;
   vms                          :longint64;
   vadmin                       :boolean;
   ivisitors                    :tdynamicvars;
   ireferrers                   :tdynamicvars;
   chits                        :tintlist64;
   cbytes                       :tintlist64;
   ctime                        :tintlist64;//codes
   mhits                        :tintlist64;
   mbytes                       :tintlist64;
   mtime                        :tintlist64;
   mnames                       :tdynamicvars;//methods
   phits                        :tintlist64;
   pbytes                       :tintlist64;
   ptime                        :tintlist64;
   pnames                       :tdynamicvars;//protocols
   ehits                        :tintlist64;
   ebytes                       :tintlist64;
   etime                        :tintlist64;
   enames                       :tdynamicvars;//extensions
   dhits                        :tintlist64;
   dbytes                       :tintlist64;
   dtime                        :tintlist64;
   dhits2                       :tintlist64;
   dbytes2                      :tintlist64;
   dtime2                       :tintlist64;
   dsize                        :tintlist64;
   dnames                       :tdynamicvars;//downloads
   rhits                        :tintlist64;
   rbytes                       :tintlist64;
   rtime                        :tintlist64;
   rnames                       :tdynamicvars;//referrers
   vhits                        :tintlist64;
   vbytes                       :tintlist64;
   vtime                        :tintlist64;
   vnames                       :tdynamicvars;//visitors (IP addresses)
   shits                        :tintlist64;
   sbytes                       :tintlist64;
   stime                        :tintlist64;
   s200                         :tintlist64;
   s206                         :tintlist64;
   s307                         :tintlist64;
   s403                         :tintlist64;
   s404                         :tintlist64;
   sOTH                         :tintlist64;
   snames                       :tdynamicvars;//sites
   isortcmp                     :tdynamiccomp;
   isorter                      :tobject;//ptr only

   function nv:tdynamicvars;
   begin
   result:=tdynamicvars.create;
   end;

   function n8:tintlist64;
   begin
   result:=tintlist64.create;
   end;

   procedure cinc(s:tintlist64;sindex:longint);
   begin
   if (s<>nil) and (sindex>=0) then s.value[sindex]:=add64(s.value[sindex],1);
   end;

   function time__addms(xtotaltime,xaddms:comp):comp;
   begin
   result:=add64(xtotaltime,mult64(frcmin64(xaddms,1),low__aorb(1,2,xaddms>=1)));
   end;

   function time__decode(xtotaltime:comp):comp;
   begin
   result:=div64(xtotaltime,2);
   end;

   function time__str(xtotaltime:comp):string;
   begin
   result:=low__uptime(time__decode(xtotaltime),false,false,true,true,false,' ');
   end;

   procedure xadd__cmppair8(a,b:tintlist64;xindex:longint;xhits,xbytes:comp);
   begin
   if (xindex>=0) and (a<>nil) and (b<>nil) then
      begin
      if (xhits>=1)  then a.value[xindex]:=a.value[xindex]+xhits;
      if (xbytes>=1) then b.value[xindex]:=add64(b.value[xindex],xbytes);
      end;
   end;

   procedure xadd__named__cmppair82(n:tdynamicvars;a,b:tintlist64;xname:string;xhits,xbytes:comp;var xindex:longint);
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
         if (xhits>=1)  then a.value[xindex]:=add64(a.value[xindex],xhits);//18jun2025
         if (xbytes>=1) then b.value[xindex]:=add64(b.value[xindex],xbytes);
         end;
      end;
   end;

   procedure xadd__named__cmppair8(n:tdynamicvars;a,b:tintlist64;xname:string;xhits,xbytes:comp);
   var
      int1:longint;
   begin
   xadd__named__cmppair82(n,a,b,xname,xhits,xbytes,int1);
   end;

   procedure cadd(xcode:longint;xbytes,xtime:comp);
   begin
   xadd__cmppair8(chits,cbytes,xcode,1,xbytes);
   if (xcode>=0) then ctime.value[xcode]:=time__addms(ctime.value[xcode],xtime);
   end;

   procedure madd(xmethod:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(mnames,mhits,mbytes,xmethod,1,xbytes,xindex);

   mtime.value[xindex]:=time__addms(mtime.value[xindex],xtime);
   end;

   procedure padd(xprotocol:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(pnames,phits,pbytes,xprotocol,1,xbytes,xindex);

   ptime.value[xindex]:=time__addms(ptime.value[xindex],xtime);
   end;

   procedure eadd(xext:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(enames,ehits,ebytes,xext,1,xbytes,xindex);

   etime.value[xindex]:=time__addms(etime.value[xindex],xtime);
   end;

   procedure radd(xreferrer:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(rnames,rhits,rbytes,xreferrer,1,xbytes,xindex);

   rtime.value[xindex]:=time__addms(rtime.value[xindex],xtime);
   end;

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

   procedure vadd(xip:string;xbytes,xtime:comp);
   var
      xindex:longint;
   begin
   xadd__named__cmppair82(vnames,vhits,vbytes,xip,1,xbytes,xindex);

   vtime.value[xindex]:=time__addms(vtime.value[xindex],xtime);
   end;

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
      slen:=str__len32(@s);
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

   procedure inext;
   begin
   li:=i+1;
   inc(xcount);
   end;

   function ival:string;
   begin
   result:=str__str0(@s,li,i-li);
   inext;
   end;

   procedure imethod_filename_protocol;
   var
      v:string;
      vlen,v1,tlen,p,p2:longint;
   begin
   //init
   v:=ival;
   vlen:=low__len32(v);
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
      vsite:=strcopy1(vfilename,2,low__len32(vfilename))+'/';
      //done
      break;
      end;//p
   //site
   if (vsite<>'') then
      begin
      tlen:=low__len32(vsite);
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

   procedure xadd(x:string);
   begin
   str__sadd(@d,x+#10);
   end;

   function xdiv(x:string;xbold:boolean):string;
   begin
   case xbold of
   true:result:='<div class="bold">'+net__encodeforhtmlstr(x)+'</div>';
   false:result:='<div>'+net__encodeforhtmlstr(x)+'</div>';
   end;//case
   end;

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

   procedure xhead(xtitle,xname:string);
   begin
   xhead2(xtitle,'',xname);
   end;

   procedure tadd21(v1,v2:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold));
   end;

   procedure tadd2(v1,v2:string);
   begin
   tadd21(v1,v2,false);
   end;

   procedure tadd31(v1,v2,v3:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold)+xdiv(v3,xbold));
   end;

   procedure tadd3(v1,v2,v3:string);
   begin
   tadd31(v1,v2,v3,false);
   end;

   procedure tstart3(xclass:string);
   begin
   xadd('<div class="'+strdefb(xclass,'logtable3')+'">');
   end;

   procedure tadd41(v1,v2,v3,v4:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold)+xdiv(v3,xbold)+xdiv(v4,xbold));
   end;

   procedure tadd4(v1,v2,v3,v4:string);
   begin
   tadd41(v1,v2,v3,v4,false);
   end;

   procedure tadd51(v1,v2,v3,v4,v5:string;xbold:boolean);
   begin
   xadd(xdiv(v1,xbold)+xdiv(v2,xbold)+xdiv(v3,xbold)+xdiv(v4,xbold)+xdiv(v5,xbold));
   end;

   procedure tadd5(v1,v2,v3,v4,v5:string);
   begin
   tadd51(v1,v2,v3,v4,v5,false);
   end;

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

   procedure tadd10(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10:string);
   begin
   tadd101(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,false);
   end;

   procedure tend;
   begin
   xadd('</div>');
   end;

   function xbinaryext(xfilename:string):boolean;
   var
      v:string;
   begin
   v:=io__readfileext_low(xfilename);
   result:=(v='exe') or (v='zip') or (v='7z') or (v='apk');
   end;

   procedure xsortcmp(x:tintlist64);
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

   function xsortindex(s:longint;var d:longint):boolean;
   begin
   result:=true;//pass-thru
   if (isorter<>nil) and (isorter is tdynamiccomp) then d:=(isorter as tdynamiccomp).sindex(s) else d:=s;
   end;
begin
//defaults
result   :=false;
s        :=nil;
xonce    :=true;
isortcmp :=nil;
isorter  :=nil;

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
p   :=0;//position within buffer s
lp  :=0;

//.no data
if not xnextchunk then goto makereport;

redo:

//.end of line
if (str__bytes0(@s,p)=10) then
   begin
   //init
   vclear;
   vms    :=0;
   xcount :=0;
   li     :=lp;

   //get - split line into parts
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
   6:if (c=ssspace)           then vcode:=strint32(ival);
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
   p :=0;
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
tadd2('Compilation Date',low__datestr(date__now,1,true));
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

function html__checkbox(xlabel,xname:string;xchecked,xenabled,xdiv:boolean):string;
begin
result:=
insstr('<div>',xdiv)+
//.disabled check boxs show the value but do not submit when form is sent -> revert to using a hidden backup value instead
insstr('<input type="hidden" name="'+xname+'" value="'+insstr('on',xchecked)+'">',not xenabled)+
//.checkbox
'<input name="'+xname+'" type="checkbox"'+insstr(' checked',xchecked)+insstr(' disabled',not xenabled)+'>'+xlabel+
insstr('</div>'+#10,xdiv);
end;

function utf8__toplaintext7bitb(const x:string):string;//08oct2026
begin

result:=utf8__to7bitTextb( x ,false ,true );

end;

function date__str(const x:tdatetime;const xtime,xmsec:boolean):string;//08oct2026
var
   y                  :word;
   m                  :word;
   d                  :word;
   hr                 :word;
   min                :word;
   sec                :word;
   msec               :word;

begin

low__decodedate2( x ,y ,m ,d );
low__decodetime2( x ,hr ,min ,sec ,msec );

result                :=low__digpad11(y,4)+'y-'+low__digpad11(m,2)+'m-'+low__digpad11(d,2)+'d';

if xtime then
   begin

   result             :=result+'--'+low__digpad11(hr,2)+'h-'+low__digpad11(min,2)+'min-'+low__digpad11(sec,2)+'s' + insstr( '-'+low__digpad11(msec,3)+'ms' ,xmsec);

   end;

end;

function email__valid(const xemailAddress:string):boolean;
begin

result                :=( email__filteraddress( xemailAddress ) <> '');

end;

function email__filteraddress(const xemailAddress:string):string;
var
   p                            :longint32;
   count_at                     :longint32;
   pos_at                       :longint32;
   pos_dot                      :longint32;

begin

//defaults
result                          :='';
count_at                        :=0;
pos_at                          :=0;
pos_dot                         :=0;

//length check
if (xemailaddress='') then exit;

//char scan
for p:=1 to low__len32( xemailaddress ) do
begin

case byte( xemailaddress[ p - 1 + stroffset ] ) of

0..31                 :exit;
sscolon               :exit;
sssemicolon           :exit;
ssmorethan            :exit;
sslessthan            :exit;
ssat                  :begin

                       if (pos_at <1) then pos_at :=p;//first instance

                       inc(count_at);

                       if (count_at>=2) then exit;//should only ever be one "@" in address

                       end;

ssdot                 :if (pos_dot<1) then pos_dot:=p;//first instance

end;//case

end;//p

//char positions must align as: "pos_at < pos_dot"
if (pos_at<1) or (pos_dot<1) or (pos_at>pos_dot) then exit;

//remove leading and trailing whitespace
result                          :=stripwhitespace_lt( xemailAddress );

end;

function domain__fromDiskSite(const xdisksite:string):string;
var
   p                  :longint32;
   
begin

//defaults
result                :=xdisksite;

//get
if strmatch( strcopy1(result,1,low__len32(idefaultdisksite)) ,idefaultdisksite) then
   begin

   result             :=strcopy1( result ,low__len32(idefaultdisksite) + 1 ,low__len32(result) );

   end;

//underscores -> dots
for p:=1 to low__len32(result) do
begin

if (result[p-1+stroffset]='_') then
   begin

   result[p-1+stroffset]:='.';

   end;

end;//p

end;

end.
