unit gosswin;

interface

uses
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef d3} sysutils, activex; {$endif}
{$ifdef laz} sysutils, zbase, zdeflate, zinflate; {$endif}
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
//## Library.................. Win32 (gosswin.pas)
//## Version.................. 4.00.730
//## Items.................... 6
//## Last Updated ............ 17apr2024
//## Lines of Code............ 2,100+
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
//## | win____*               | Win32 general     | 1.00.300  | 04mar2024   | Win32 general api procs for Windows specific features and functionality.  The leading "win____" denotes a Window's API call
//## | net____*               | Win32 network     | 1.00.110  | 04mar2024   | Win32 network api procs for low level network IO.  The leading "net____" denotes a Window's network API call
//## | reg__*                 | family of procs   | 1.00.030  | 03mar2024   | Registry access procs (requires admin terminal for write/delete)
//## | service__*             | family of procs   | 1.00.170  | 04mar2024   | Service support, permits seamless switching from console app to app as a service
//## | zip compression        | proc              | 1.00.070  | 17feb2024   | ZIP compression for tstr8 and tstr9 binary streams
//## | console support        | procs             | 1.00.050  |   jan2024   | Console support procs
//## ==========================================================================================================================================================================================================================


resourcestring
  SBadPropValue = '''%s'' is not a valid property value';
  SCannotActivate = 'OLE control activation failed';
  SNoWindowHandle = 'Could not obtain OLE control window handle';
  SOleError = 'OLE error %.8x';
  SVarNotObject = 'Variant does not reference an OLE object';
  SVarNotAutoObject = 'Variant does not reference an automation object';
  SNoMethod = 'Method ''%s'' not supported by OLE object';
  SLinkProperties = 'Link Properties';
  SInvalidLinkSource = 'Cannot link to an invalid source.';
  SCannotBreakLink = 'Break link operation is not supported.';
  SLinkedObject = 'Linked %s';
  SEmptyContainer = 'Operation not allowed on an empty OLE container';
  SInvalidVerb = 'Invalid object verb';
  SPropDlgCaption = '%s Properties';
  SInvalidStreamFormat = 'Invalid stream format';
  SInvalidLicense = 'License information for %s is invalid';
  SNotLicensed = 'License information for %s not found. You cannot use this control in design mode';


type
   //.base value type - specify here before anything else
   DWORD         = longint;
   UINT          = longint;
   PUINT         = ^UINT;
   ULONG         = longint;
   PULONG        = ^ULONG;
   PLongint      = ^longint;
   PInteger      = ^longint;
   PSmallInt     = ^smallint;
   PDouble       = ^double;
   PWChar        = PWideChar;
   WCHAR         = WideChar;
   BOOL          = LongBool;
   PBOOL         = ^BOOL;
   SHORT         = smallint;
   HWND          = longint;
   HHOOK         = longint;
   THandle       = longint;
   PHandle       = ^THandle;
   SC_HANDLE     = THandle;
   SERVICE_STATUS_HANDLE = DWORD;
   ATOM          = Word;
   TAtom         = Word;
   //.registry
   HKEY          = longint;
   PHKEY         = ^HKEY;
   ACCESS_MASK   = DWORD;
   PACCESS_MASK  = ^ACCESS_MASK;
   REGSAM        = ACCESS_MASK;

   PWORD         = ^Word;
   PDWORD        = ^DWORD;
   LPDWORD       = PDWORD;

   HGLOBAL       = THandle;
   HLOCAL        = THandle;
   FARPROC       = Pointer;
   TFarProc      = Pointer;
   THandlerFunction = TFarProc;
   PROC_22       = Pointer;

   WPARAM        = longint;
   LPARAM        = longint;
   LRESULT       = longint;

   u_char        = char;
   u_short       = word;
   u_int         = integer;
   u_long        = longint;
   tsocket       = u_int;

   PByteArray    = ^TByteArray;
   TByteArray    = array[0..32767] of Byte;

   PWordArray    = ^TWordArray;
   TWordArray    = array[0..16383] of Word;

   TProcedure    = procedure;
   TFileName     = string;

   PPoint        = ^TPoint;
   TPoint        = record
                   x: Longint;
                   y: Longint;
                   end;

   PCoord        = ^TCoord;
   TCoord        = packed record
                   X: SHORT;
                   Y: SHORT;
                   end;

   PSmallRect    = ^TSmallRect;
   TSmallRect    = packed record
                   Left: SHORT;
                   Top: SHORT;
                   Right: SHORT;
                   Bottom: SHORT;
                   end;

const
   advapi32  = 'advapi32.dll';
   kernel32  = 'kernel32.dll';
   user32    = 'user32.dll';
   mpr       = 'mpr.dll';
   version   = 'version.dll';
   comctl32  = 'comctl32.dll';
   gdi32     = 'gdi32.dll';
   opengl32  = 'opengl32.dll';
   wintrust  = 'wintrust.dll';
   shell32   = 'shell32.dll';
   ole32     = 'ole32.dll';
   oleaut32  = 'oleaut32.dll';
   olepro32  = 'olepro32.dll';
   mmsyst    = 'winmm.dll';
   winsocket = 'wsock32.dll';

   SYNCHRONIZE              = $00100000;
   STANDARD_RIGHTS_REQUIRED = $000F0000;

   //access rights
   _DELETE                  = $00010000;
   READ_CONTROL             = $00020000;
   WRITE_DAC                = $00040000;
   WRITE_OWNER              = $00080000;
   STANDARD_RIGHTS_READ     = READ_CONTROL;
   STANDARD_RIGHTS_WRITE    = READ_CONTROL;
   STANDARD_RIGHTS_EXECUTE  = READ_CONTROL;
   STANDARD_RIGHTS_ALL      = $001F0000;
   SPECIFIC_RIGHTS_ALL      = $0000FFFF;
   ACCESS_SYSTEM_SECURITY   = $01000000;
   MAXIMUM_ALLOWED          = $02000000;
   GENERIC_READ             = -2147483647-1;//was $80000000; - avoids constant range error in Lazarus
   GENERIC_WRITE            = 1073741824;//was $40000000;
//   GENERIC_READ             = $80000000;
//   GENERIC_WRITE            = $40000000;
   GENERIC_EXECUTE          = $20000000;
   GENERIC_ALL              = $10000000;

   //registry
   HKEY_CLASSES_ROOT     = $80000000;
   HKEY_CURRENT_USER     = $80000001;
   HKEY_LOCAL_MACHINE    =-2147483646;//$80000002;
   HKEY_USERS            = $80000003;
   HKEY_PERFORMANCE_DATA = $80000004;
   HKEY_CURRENT_CONFIG   = $80000005;
   HKEY_DYN_DATA         = $80000006;
   ERROR_SUCCESS         = 0;
   NO_ERROR              = 0;
   REG_OPTION_NON_VOLATILE = ($00000000);//key is preserved when system is rebooted
   REG_CREATED_NEW_KEY     = ($00000001);//new registry key created
   REG_OPENED_EXISTING_KEY = ($00000002);//existing key opened
   //.registry value types
   REG_NONE                       = 0;
   REG_SZ                         = 1;
   REG_EXPAND_SZ                  = 2;
   REG_BINARY                     = 3;
   REG_DWORD                      = 4;
   REG_DWORD_LITTLE_ENDIAN        = 4;
   REG_DWORD_BIG_ENDIAN           = 5;
   REG_LINK                       = 6;
   REG_MULTI_SZ                   = 7;
   REG_RESOURCE_LIST              = 8;
   REG_FULL_RESOURCE_DESCRIPTOR   = 9;
   REG_RESOURCE_REQUIREMENTS_LIST = 10;

   KEY_QUERY_VALUE    = $0001;
   KEY_SET_VALUE      = $0002;
   KEY_CREATE_SUB_KEY = $0004;
   KEY_ENUMERATE_SUB_KEYS = $0008;
   KEY_NOTIFY         = $0010;
   KEY_CREATE_LINK    = $0020;

   KEY_READ           = (STANDARD_RIGHTS_READ or
                        KEY_QUERY_VALUE or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY) and not
                        SYNCHRONIZE;

   KEY_WRITE          = (STANDARD_RIGHTS_WRITE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY) and not
                        SYNCHRONIZE;

   KEY_EXECUTE        =  KEY_READ and not SYNCHRONIZE;

   KEY_ALL_ACCESS     = (STANDARD_RIGHTS_ALL or
                        KEY_QUERY_VALUE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY or
                        KEY_CREATE_LINK) and not
                        SYNCHRONIZE;

   //service manager
   SC_MANAGER_CONNECT             = $0001;
   SC_MANAGER_CREATE_SERVICE      = $0002;
   SC_MANAGER_ENUMERATE_SERVICE   = $0004;
   SC_MANAGER_LOCK                = $0008;
   SC_MANAGER_QUERY_LOCK_STATUS   = $0010;
   SC_MANAGER_MODIFY_BOOT_CONFIG  = $0020;

   SC_MANAGER_ALL_ACCESS          = (STANDARD_RIGHTS_REQUIRED or
                                    SC_MANAGER_CONNECT or
                                    SC_MANAGER_CREATE_SERVICE or
                                    SC_MANAGER_ENUMERATE_SERVICE or
                                    SC_MANAGER_LOCK or
                                    SC_MANAGER_QUERY_LOCK_STATUS or
                                    SC_MANAGER_MODIFY_BOOT_CONFIG);

   //priority codes
   NORMAL_PRIORITY_CLASS           = $00000020;
   IDLE_PRIORITY_CLASS             = $00000040;
   HIGH_PRIORITY_CLASS             = $00000080;
   REALTIME_PRIORITY_CLASS         = $00000100;

   //service support
   //.control codes
   SERVICE_CONTROL_STOP           = $00000001;
   SERVICE_CONTROL_PAUSE          = $00000002;
   SERVICE_CONTROL_CONTINUE       = $00000003;
   SERVICE_CONTROL_INTERROGATE    = $00000004;
   SERVICE_CONTROL_SHUTDOWN       = $00000005;
   //.status codes
   SERVICE_STOPPED                = $00000001;
   SERVICE_START_PENDING          = $00000002;
   SERVICE_STOP_PENDING           = $00000003;
   SERVICE_RUNNING                = $00000004;
   SERVICE_CONTINUE_PENDING       = $00000005;
   SERVICE_PAUSE_PENDING          = $00000006;
   SERVICE_PAUSED                 = $00000007;
   //.accept mask (Bit Mask)
   SERVICE_ACCEPT_STOP            = $00000001;
   SERVICE_ACCEPT_PAUSE_CONTINUE  = $00000002;
   SERVICE_ACCEPT_SHUTDOWN        = $00000004;

   //system messages
   WM_USER              =$0400;//anything below this is reserved
   WM_MULTIMEDIA_TIMER  =WM_USER + 127;
   WM_PAINT             = $000F;
   WM_CLOSE             = $0010;
   WM_QUERYENDSESSION   = $0011;
   WM_QUIT              = $0012;

   //sockets
   winsocketVersion       = $0101;//windows 95 compatiable
   WSADESCRIPTION_LEN     = 256;
   WSASYS_STATUS_LEN      = 128;
   INVALID_SOCKET         = tsocket(not(0));//This is used instead of -1, since the TSocket type is unsigned
   SOCKET_ERROR	          = -1;
   SOL_SOCKET             = $ffff;          {options for socket level }

   //option for opening sockets for synchronous access
   SO_OPENTYPE            = $7008;
   SO_SYNCHRONOUS_ALERT   = $10;
   SO_SYNCHRONOUS_NONALERT= $20;
   SO_ACCEPTCONN          = $0002;          { socket has had listen() }
   SO_KEEPALIVE           = $0008;          { keep connections alive }
   SO_LINGER              = $0080;          { linger on close if data present }
   SO_DONTLINGER          = $ff7f;

   INADDR_ANY             = $00000000;
   INADDR_LOOPBACK        = $7F000001;
   INADDR_BROADCAST       = $FFFFFFFF;
   INADDR_NONE            = $FFFFFFFF;

   //Address families
   AF_UNSPEC       = 0;               { unspecified }
   AF_UNIX         = 1;               { local to host (pipes, portals) }
   AF_INET         = 2;               { internetwork: UDP, TCP, etc. }

   //Protocol families - same as address families for now. }
   PF_UNSPEC       = AF_UNSPEC;
   PF_UNIX         = AF_UNIX;
   PF_INET         = AF_INET;

   //Types
   SOCK_STREAM     = 1;               { stream socket }
   SOCK_DGRAM      = 2;               { datagram socket }
   SOCK_RAW        = 3;               { raw-protocol interface }
   SOCK_RDM        = 4;               { reliably-delivered message }
   SOCK_SEQPACKET  = 5;               { sequenced packet stream }

   //Protocols
   IPPROTO_IP     =   0;             { dummy for IP }
   IPPROTO_ICMP   =   1;             { control message protocol }
   IPPROTO_IGMP   =   2;             { group management protocol }
   IPPROTO_GGP    =   3;             { gateway^2 (deprecated) }
   IPPROTO_TCP    =   6;             { tcp }
   IPPROTO_PUP    =  12;             { pup }
   IPPROTO_UDP    =  17;             { user datagram protocol }
   IPPROTO_IDP    =  22;             { xns idp }
   IPPROTO_ND     =  77;             { UNOFFICIAL net disk proto }
   IPPROTO_RAW    =  255;            { raw IP packet }
   IPPROTO_MAX    =  256;

   //Define flags to be used with the WSAAsyncSelect
   FD_READ         = $01;
   FD_WRITE        = $02;
   FD_OOB          = $04;
   FD_ACCEPT       = $08;
   FD_CONNECT      = $10;{=16}
   FD_CLOSE        = $20;{=32}

   //values to access various Windows paths (folders)
   REGSTR_PATH_EXPLORER        = 'Software\Microsoft\Windows\CurrentVersion\Explorer';
   REGSTR_PATH_SPECIAL_FOLDERS   = REGSTR_PATH_EXPLORER + '\Shell Folders';
   CSIDL_DESKTOP                       = $0000;
   CSIDL_PROGRAMS                      = $0002;
   CSIDL_CONTROLS                      = $0003;
   CSIDL_PRINTERS                      = $0004;
   CSIDL_PERSONAL                      = $0005;
   CSIDL_FAVORITES                     = $0006;
   CSIDL_STARTUP                       = $0007;
   CSIDL_RECENT                        = $0008;
   CSIDL_SENDTO                        = $0009;
   CSIDL_BITBUCKET                     = $000a;
   CSIDL_STARTMENU                     = $000b;
   CSIDL_DESKTOPDIRECTORY              = $0010;
   CSIDL_DRIVES                        = $0011;
   CSIDL_NETWORK                       = $0012;
   CSIDL_NETHOOD                       = $0013;
   CSIDL_FONTS                         = $0014;
   CSIDL_TEMPLATES                     = $0015;
   CSIDL_COMMON_STARTMENU              = $0016;
   CSIDL_COMMON_PROGRAMS               = $0017;
   CSIDL_COMMON_STARTUP                = $0018;
   CSIDL_COMMON_DESKTOPDIRECTORY       = $0019;
   CSIDL_APPDATA                       = $001a;
   CSIDL_PRINTHOOD                     = $001b;

   CLSCTX_INPROC_SERVER     = 1;
   CLSCTX_INPROC_HANDLER    = 2;
   CLSCTX_LOCAL_SERVER      = 4;
   CLSCTX_INPROC_SERVER16   = 8;
   CLSCTX_REMOTE_SERVER     = $10;
   CLSCTX_INPROC_HANDLER16  = $20;
   CLSCTX_INPROC_SERVERX86  = $40;
   CLSCTX_INPROC_HANDLERX86 = $80;

  // String constants for Interface IDs
   SID_INewShortcutHookA  = '{000214E1-0000-0000-C000-000000000046}';
   SID_IShellBrowser      = '{000214E2-0000-0000-C000-000000000046}';
   SID_IShellView         = '{000214E3-0000-0000-C000-000000000046}';
   SID_IContextMenu       = '{000214E4-0000-0000-C000-000000000046}';
   SID_IShellIcon         = '{000214E5-0000-0000-C000-000000000046}';
   SID_IShellFolder       = '{000214E6-0000-0000-C000-000000000046}';
   SID_IShellExtInit      = '{000214E8-0000-0000-C000-000000000046}';
   SID_IShellPropSheetExt = '{000214E9-0000-0000-C000-000000000046}';
   SID_IPersistFolder     = '{000214EA-0000-0000-C000-000000000046}';
   SID_IExtractIconA      = '{000214EB-0000-0000-C000-000000000046}';
   SID_IShellLinkA        = '{000214EE-0000-0000-C000-000000000046}';
   SID_IShellCopyHookA    = '{000214EF-0000-0000-C000-000000000046}';
   SID_IFileViewerA       = '{000214F0-0000-0000-C000-000000000046}';
   SID_ICommDlgBrowser    = '{000214F1-0000-0000-C000-000000000046}';
   SID_IEnumIDList        = '{000214F2-0000-0000-C000-000000000046}';
   SID_IFileViewerSite    = '{000214F3-0000-0000-C000-000000000046}';
   SID_IContextMenu2      = '{000214F4-0000-0000-C000-000000000046}';
   SID_IShellExecuteHookA = '{000214F5-0000-0000-C000-000000000046}';
   SID_IPropSheetPage     = '{000214F6-0000-0000-C000-000000000046}';
   SID_INewShortcutHookW  = '{000214F7-0000-0000-C000-000000000046}';
   SID_IFileViewerW       = '{000214F8-0000-0000-C000-000000000046}';
   SID_IShellLinkW        = '{000214F9-0000-0000-C000-000000000046}';
   SID_IExtractIconW      = '{000214FA-0000-0000-C000-000000000046}';
   SID_IShellExecuteHookW = '{000214FB-0000-0000-C000-000000000046}';
   SID_IShellCopyHookW    = '{000214FC-0000-0000-C000-000000000046}';
   SID_IShellView2        = '{88E39E80-3578-11CF-AE69-08002B2E1262}';

    // Class IDs        xx=00-9F
   CLSID_ShellDesktop: TGUID = (
        D1:$00021400; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
   CLSID_ShellLink: TGUID = (
        D1:$00021401; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));


   { Logical Font }
   LF_FACESIZE = 32;

   DEFAULT_QUALITY = 0;
   DRAFT_QUALITY = 1;
   PROOF_QUALITY = 2;
   NONANTIALIASED_QUALITY = 3;
   ANTIALIASED_QUALITY = 4;



   STD_INPUT_HANDLE = DWORD(-10);
   STD_OUTPUT_HANDLE = DWORD(-11);
   STD_ERROR_HANDLE = DWORD(-12);

   SEM_FAILCRITICALERRORS = 1;
   SEM_NOGPFAULTERRORBOX = 2;
   SEM_NOALIGNMENTFAULTEXCEPT = 4;
   SEM_NOOPENFILEERRORBOX = $8000;

   { PeekMessage() Options }
   PM_NOREMOVE = 0;
   PM_REMOVE = 1;
   PM_NOYIELD = 2;

   { Success codes }
   S_OK    = $00000000;
   S_FALSE = $00000001;

   NOERROR = 0;

   //file support
   MAX_PATH = 260;
   INVALID_HANDLE_VALUE = -1;
   INVALID_FILE_SIZE = DWORD($FFFFFFFF);

   FILE_BEGIN = 0;
   FILE_CURRENT = 1;
   FILE_END = 2;

   FILE_SHARE_READ                     = $00000001;
   FILE_SHARE_WRITE                    = $00000002;
   FILE_SHARE_DELETE                   = $00000004;
   FILE_ATTRIBUTE_READONLY             = $00000001;
   FILE_ATTRIBUTE_HIDDEN               = $00000002;
   FILE_ATTRIBUTE_SYSTEM               = $00000004;
   FILE_ATTRIBUTE_DIRECTORY            = $00000010;
   FILE_ATTRIBUTE_ARCHIVE              = $00000020;
   FILE_ATTRIBUTE_NORMAL               = $00000080;
   FILE_ATTRIBUTE_TEMPORARY            = $00000100;
   FILE_ATTRIBUTE_COMPRESSED           = $00000800;
   FILE_ATTRIBUTE_OFFLINE              = $00001000;
   FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;
   FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;
   FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;
   FILE_NOTIFY_CHANGE_SIZE             = $00000008;
   FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;
   FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;
   FILE_NOTIFY_CHANGE_CREATION         = $00000040;
   FILE_NOTIFY_CHANGE_SECURITY         = $00000100;
   FILE_ACTION_ADDED                   = $00000001;
   FILE_ACTION_REMOVED                 = $00000002;
   FILE_ACTION_MODIFIED                = $00000003;
   FILE_ACTION_RENAMED_OLD_NAME        = $00000004;
   FILE_ACTION_RENAMED_NEW_NAME        = $00000005;
   MAILSLOT_NO_MESSAGE                 = -1;
   MAILSLOT_WAIT_FOREVER               = -1;
   FILE_CASE_SENSITIVE_SEARCH          = $00000001;
   FILE_CASE_PRESERVED_NAMES           = $00000002;
   FILE_UNICODE_ON_DISK                = $00000004;
   FILE_PERSISTENT_ACLS                = $00000008;
   FILE_FILE_COMPRESSION               = $00000010;
   FILE_VOLUME_IS_COMPRESSED           = $00008000;

  { File creation flags must start at the high end since they }
  { are combined with the attributes}

   FILE_FLAG_WRITE_THROUGH = $80000000;
   FILE_FLAG_OVERLAPPED = $40000000;
   FILE_FLAG_NO_BUFFERING = $20000000;
   FILE_FLAG_RANDOM_ACCESS = $10000000;
   FILE_FLAG_SEQUENTIAL_SCAN = $8000000;
   FILE_FLAG_DELETE_ON_CLOSE = $4000000;
   FILE_FLAG_BACKUP_SEMANTICS = $2000000;
   FILE_FLAG_POSIX_SEMANTICS = $1000000;

   CREATE_NEW = 1;
   CREATE_ALWAYS = 2;
   OPEN_EXISTING = 3;
   OPEN_ALWAYS = 4;
   TRUNCATE_EXISTING = 5;

type
   TFNWndProc = TFarProc;
   TFNDlgProc = TFarProc;
   TFNTimerProc = TFarProc;
   TFNGrayStringProc = TFarProc;
   TFNWndEnumProc = TFarProc;
   TFNSendAsyncProc = TFarProc;
   TFNDrawStateProc = TFarProc;
   TFNTimeCallBack  = procedure(uTimerID,uMessage:UINT;dwUser,dw1,dw2:dword) stdcall;// <<-- special note: NO semicolon between "dword)" and "stdcall"!!!!

   //.media support
   MMRESULT = UINT;              { error return code, 0 means no error }

   HGDIOBJ = Integer;
   HACCEL = Integer;
   HBITMAP = Integer;
   HBRUSH = Integer;
   HCOLORSPACE = Integer;
   HDC = Integer;
   HGLRC = Integer;
   HDESK = Integer;
   HENHMETAFILE = Integer;
   HFONT = Integer;
   HICON = Integer;
   HMENU = Integer;
   HMETAFILE = Integer;
   HINST = Integer;
   HMODULE = HINST;              { HMODULEs can be used in place of HINSTs }
   HPALETTE = Integer;
   HPEN = Integer;
   HRGN = Integer;
   HRSRC = Integer;
   HSTR = Integer;
   HTASK = Integer;
   HWINSTA = Integer;
   HKL = Integer;


   HFILE = Integer;
   HCURSOR = HICON;              { HICONs & HCURSORs are polymorphic }

   COLORREF = DWORD;
   TColorRef = Longint;
   TFNHandlerRoutine = TFarProc;


   TFNHookProc = function (code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT stdcall;

   //.service status
   PServiceStatus = ^TServiceStatus;
   TServiceStatus = record
     dwServiceType: DWORD;
     dwCurrentState: DWORD;
     dwControlsAccepted: DWORD;
     dwWin32ExitCode: DWORD;
     dwServiceSpecificExitCode: DWORD;
     dwCheckPoint: DWORD;
     dwWaitHint: DWORD;
   end;

   TServiceMainFunction = tfarproc;
   PServiceTableEntry = ^TServiceTableEntry;
   TServiceTableEntry = record
     lpServiceName: PAnsiChar;
     lpServiceProc: TServiceMainFunction;
   end;

   //.network
   PWSAData = ^TWSAData;
   TWSAData = packed record
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..WSADESCRIPTION_LEN] of Char;
    szSystemStatus: array[0..WSASYS_STATUS_LEN] of Char;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PChar;
    end;//end of record

   SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
    end;

   SunW = packed record
    s_w1, s_w2: u_short;
    end;

   PInAddr = ^TInAddr;
   TInAddr = packed record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
    end;//end of record

   PSockAddrIn = ^TSockAddrIn;
   TSockAddrIn = packed record
    case Integer of
      0: (sin_family: u_short;
          sin_port: u_short;
          sin_addr: TInAddr;
          sin_zero: array[0..7] of Char);
      1: (sa_family: u_short;
          sa_data: array[0..13] of Char)
    end;//end of record

   PSockAddr = ^TSockAddr;
   TSockAddr = TSockAddrIn;

{ Interface ID }

   PIID = PGUID;
   TIID = TGUID;

{ Class ID }

   PCLSID = PGUID;
   TCLSID = TGUID;

{ Message structure }
   pmsg = ^tmsg;
   tmsg = packed record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
    time: DWORD;
    pt: TPoint;
   end;

 
   PConsoleScreenBufferInfo = ^TConsoleScreenBufferInfo;
   TConsoleScreenBufferInfo = packed record
     dwSize: TCoord;
     dwCursorPosition: TCoord;
     wAttributes: Word;
     srWindow: TSmallRect;
     dwMaximumWindowSize: TCoord;
   end;

   PConsoleCursorInfo = ^TConsoleCursorInfo;
   TConsoleCursorInfo = packed record
     dwSize: DWORD;
     bVisible: BOOL;
   end;


   TOleChar = WideChar;
   POleStr = PWideChar;

   POleStrList = ^TOleStrList;
   TOleStrList = array[0..65535] of POleStr;


{ TSHItemID -- Item ID }
   PSHItemID = ^TSHItemID;
   TSHItemID = packed record           { mkid }
    cb: Word;                         { Size of the ID (including cb itself) }
    abID: array[0..0] of Byte;        { The item ID (variable length) }
   end;

{ TItemIDList -- List if item IDs (combined with 0-terminator) }
   PItemIDList = ^TItemIDList;
   TItemIDList = packed record         { idl }
     mkid: TSHItemID;
    end;

   POverlapped = ^TOverlapped;
   TOverlapped = record
    Internal: DWORD;
    InternalHigh: DWORD;
    Offset: DWORD;
    OffsetHigh: DWORD;
    hEvent: THandle;
   end;

   PSecurityAttributes = ^TSecurityAttributes;
   TSecurityAttributes = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
   end;

   PProcessInformation = ^TProcessInformation;
   TProcessInformation = record
    hProcess: THandle;
    hThread: THandle;
    dwProcessId: DWORD;
    dwThreadId: DWORD;
   end;

  { File System time stamps are represented with the following structure: }
   PFileTime = ^TFileTime;
   TFileTime = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
   end;

   PByHandleFileInformation = ^TByHandleFileInformation;
   TByHandleFileInformation = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    dwVolumeSerialNumber: DWORD;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    nNumberOfLinks: DWORD;
    nFileIndexHigh: DWORD;
    nFileIndexLow: DWORD;
   end;


  { System time is represented with the following structure: }
  PSystemTime = ^TSystemTime;
  TSystemTime = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;

   PWndClassExA = ^TWndClassExA;
   PWndClassExW = ^TWndClassExW;
   PWndClassEx = PWndClassExA;
   TWndClassExA = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
    hIconSm: HICON;
   end;
   TWndClassExW = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
    hIconSm: HICON;
   end;
   TWndClassEx = TWndClassExA;

   PWndClassA = ^TWndClassA;
   PWndClassW = ^TWndClassW;
   PWndClass = PWndClassA;
   TWndClassA = packed record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
   end;
   TWndClassW = packed record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
   end;
   TWndClass = TWndClassA;

   PWin32FindDataA = ^TWin32FindDataA;
   PWin32FindDataW = ^TWin32FindDataW;
   PWin32FindData = PWin32FindDataA;
   TWin32FindDataA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of AnsiChar;
    cAlternateFileName: array[0..13] of AnsiChar;
   end;
   TWin32FindDataW = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of WideChar;
    cAlternateFileName: array[0..13] of WideChar;
   end;
   TWin32FindData = TWin32FindDataA;

   { Search record used by FindFirst, FindNext, and FindClose }
   TSearchRec = record
       Time: Integer;
       Size: Integer;
       Attr: Integer;
       Name: TFileName;
       ExcludeAttr: Integer;
       FindHandle: THandle;
       FindData: TWin32FindData;
      end;

  {console input}
  PKeyEventRecord = ^TKeyEventRecord;
  TKeyEventRecord = packed record
    bKeyDown: BOOL;
    wRepeatCount: Word;
    wVirtualKeyCode: Word;
    wVirtualScanCode: Word;
    case longint of
    0:(UnicodeChar:WCHAR; dwControlKeyStateU:DWORD);
    1:(AsciiChar:CHAR; dwControlKeyState:DWORD);
    end;


  PMouseEventRecord = ^TMouseEventRecord;
  TMouseEventRecord = packed record
    dwMousePosition: TCoord;
    dwButtonState: DWORD;
    dwControlKeyState: DWORD;
    dwEventFlags: DWORD;
  end;

  PWindowBufferSizeRecord = ^TWindowBufferSizeRecord;
  TWindowBufferSizeRecord = packed record
    dwSize: TCoord;
  end;

  PMenuEventRecord = ^TMenuEventRecord;
  TMenuEventRecord = packed record
    dwCommandId: UINT;
  end;

  PFocusEventRecord = ^TFocusEventRecord;
  TFocusEventRecord = packed record
    bSetFocus: BOOL;
  end;

   PInputRecord = ^TInputRecord;
   TInputRecord = record
    EventType: Word;
    case Integer of
      0: (KeyEvent: TKeyEventRecord);
      1: (MouseEvent: TMouseEventRecord);
      2: (WindowBufferSizeEvent: TWindowBufferSizeRecord);
      3: (MenuEvent: TMenuEventRecord);
      4: (FocusEvent: TFocusEventRecord);
    end;

   //.font support
   PLogFontA = ^TLogFontA;
   PLogFontW = ^TLogFontW;
   PLogFont = PLogFontA;
   TLogFontA = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of AnsiChar;
   end;
   TLogFontW = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of WideChar;
   end;
   TLogFont = TLogFontA;


  { imalloc interface }
   imalloc = interface(IUnknown)
      ['{00000002-0000-0000-C000-000000000046}']
      function Alloc(cb: Longint): Pointer; stdcall;
      function Realloc(pv: Pointer; cb: Longint): Pointer; stdcall;
      procedure Free(pv: Pointer); stdcall;
      function GetSize(pv: Pointer): Longint; stdcall;
      function DidAlloc(pv: Pointer): Integer; stdcall;
      procedure HeapMinimize; stdcall;
   end;

   IShellLinkA = interface(IUnknown) { sl }
      [SID_IShellLinkA]
      function GetPath(pszFile: PAnsiChar; cchMaxPath: Integer;
        var pfd: TWin32FindData; fFlags: DWORD): HResult; stdcall;
      function GetIDList(var ppidl: PItemIDList): HResult; stdcall;
      function SetIDList(pidl: PItemIDList): HResult; stdcall;
      function GetDescription(pszName: PAnsiChar; cchMaxName: Integer): HResult; stdcall;
      function SetDescription(pszName: PAnsiChar): HResult; stdcall;
      function GetWorkingDirectory(pszDir: PAnsiChar; cchMaxPath: Integer): HResult; stdcall;
      function SetWorkingDirectory(pszDir: PAnsiChar): HResult; stdcall;
      function GetArguments(pszArgs: PAnsiChar; cchMaxPath: Integer): HResult; stdcall;
      function SetArguments(pszArgs: PAnsiChar): HResult; stdcall;
      function GetHotkey(var pwHotkey: Word): HResult; stdcall;
      function SetHotkey(wHotkey: Word): HResult; stdcall;
      function GetShowCmd(out piShowCmd: Integer): HResult; stdcall;
      function SetShowCmd(iShowCmd: Integer): HResult; stdcall;
      function GetIconLocation(pszIconPath: PAnsiChar; cchIconPath: Integer;
        out piIcon: Integer): HResult; stdcall;
      function SetIconLocation(pszIconPath: PAnsiChar; iIcon: Integer): HResult; stdcall;
      function SetRelativePath(pszPathRel: PAnsiChar; dwReserved: DWORD): HResult; stdcall;
      function Resolve(Wnd: HWND; fFlags: DWORD): HResult; stdcall;
      function SetPath(pszFile: PAnsiChar): HResult; stdcall;
   end;
   IShellLinkW = interface(IUnknown) { sl }
      [SID_IShellLinkW]
      function GetPath(pszFile: PWideChar; cchMaxPath: Integer;
        var pfd: TWin32FindData; fFlags: DWORD): HResult; stdcall;
      function GetIDList(var ppidl: PItemIDList): HResult; stdcall;
      function SetIDList(pidl: PItemIDList): HResult; stdcall;
      function GetDescription(pszName: PWideChar; cchMaxName: Integer): HResult; stdcall;
      function SetDescription(pszName: PWideChar): HResult; stdcall;
      function GetWorkingDirectory(pszDir: PWideChar; cchMaxPath: Integer): HResult; stdcall;
      function SetWorkingDirectory(pszDir: PWideChar): HResult; stdcall;
      function GetArguments(pszArgs: PWideChar; cchMaxPath: Integer): HResult; stdcall;
      function SetArguments(pszArgs: PWideChar): HResult; stdcall;
      function GetHotkey(var pwHotkey: Word): HResult; stdcall;
      function SetHotkey(wHotkey: Word): HResult; stdcall;
      function GetShowCmd(out piShowCmd: Integer): HResult; stdcall;
      function SetShowCmd(iShowCmd: Integer): HResult; stdcall;
      function GetIconLocation(pszIconPath: PWideChar; cchIconPath: Integer;
        out piIcon: Integer): HResult; stdcall;
      function SetIconLocation(pszIconPath: PWideChar; iIcon: Integer): HResult; stdcall;
      function SetRelativePath(pszPathRel: PWideChar; dwReserved: DWORD): HResult; stdcall;
      function Resolve(Wnd: HWND; fFlags: DWORD): HResult; stdcall;
      function SetPath(pszFile: PWideChar): HResult; stdcall;
   end;
   IShellLink = IShellLinkA;


   { IPersist interface }
   IPersist = interface(IUnknown)
     ['{0000010C-0000-0000-C000-000000000046}']
     function GetClassID(out classID: TCLSID): HResult; stdcall;
   end;

   { IPersistFile interface }
   IPersistFile = interface(IPersist)
        ['{0000010B-0000-0000-C000-000000000046}']
        function IsDirty: HResult; stdcall;
        function Load(pszFileName: POleStr; dwMode: Longint): HResult;
          stdcall;
        function Save(pszFileName: POleStr; fRemember: BOOL): HResult;
          stdcall;
        function SaveCompleted(pszFileName: POleStr): HResult;
          stdcall;
        function GetCurFile(out pszFileName: POleStr): HResult;
          stdcall;
   end;


   win____EOleError = class(Exception);

   win____EOleSysError = class(win____EOleError)
      private
        FErrorCode: Integer;
      public
        constructor Create(const Message: string; ErrorCode: Integer;
          HelpContext: Integer);
        property ErrorCode: Integer read FErrorCode write FErrorCode;
      end;

   win____EOleException = class(win____EOleSysError)
      private
        FSource: string;
        FHelpFile: string;
      public
        constructor Create(const Message: string; ErrorCode: Integer;
          const Source, HelpFile: string; HelpContext: Integer);
        property HelpFile: string read FHelpFile write FHelpFile;
        property Source: string read FSource write FSource;
      end;

//Windows procs ----------------------------------------------------------------

//.API calls preappended with "win____" to easily spot them in code -> they are independant of Delphi and Lazarus
function win____SetTimer(hWnd: HWND; nIDEvent, uElapse: UINT; lpTimerFunc: TFNTimerProc): UINT; stdcall; external user32 name 'SetTimer';
function win____KillTimer(hWnd: HWND; uIDEvent: UINT): BOOL; stdcall; external user32 name 'KillTimer';
function win____WaitMessage:bool; stdcall; external user32 name 'WaitMessage';
function win____HeapCreate(flOptions, dwInitialSize, dwMaximumSize: DWORD): THandle; stdcall; external kernel32 name 'HeapCreate';
function win____HeapDestroy(hHeap: THandle): BOOL; stdcall; external kernel32 name 'HeapDestroy';
function win____HeapAlloc(hHeap: THandle; dwFlags, dwBytes: DWORD): Pointer; stdcall; external kernel32 name 'HeapAlloc';
function win____HeapReAlloc(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer; dwBytes: DWORD): Pointer; stdcall; external kernel32 name 'HeapReAlloc';
function win____HeapFree(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): BOOL; stdcall; external kernel32 name 'HeapFree';
function win____GetProcessHeap: THandle; stdcall; external kernel32 name 'GetProcessHeap';
function win____SetPriorityClass(hProcess: THandle; dwPriorityClass: DWORD): BOOL; stdcall; external kernel32 name 'SetPriorityClass';
function win____GetPriorityClass(hProcess: THandle): DWORD; stdcall; external kernel32 name 'GetPriorityClass';
function win____GetCurrentProcess: THandle; stdcall; external kernel32 name 'GetCurrentProcess';
function win____GetLastError: DWORD; stdcall; external kernel32 name 'GetLastError';
function win____GetStdHandle(nStdHandle: DWORD): THandle; stdcall; external kernel32 name 'GetStdHandle';
function win____SetStdHandle(nStdHandle: DWORD; hHandle: THandle): BOOL; stdcall; external kernel32 name 'SetStdHandle';
function win____GetConsoleScreenBufferInfo(hConsoleOutput: THandle; var lpConsoleScreenBufferInfo: TConsoleScreenBufferInfo): BOOL; stdcall; external kernel32 name 'GetConsoleScreenBufferInfo';
function win____FillConsoleOutputCharacter(hConsoleOutput: THandle; cCharacter: Char; nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall; external kernel32 name 'FillConsoleOutputCharacterA';
function win____FillConsoleOutputAttribute(hConsoleOutput: THandle; wAttribute: Word; nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfAttrsWritten: DWORD): BOOL; stdcall; external kernel32 name 'FillConsoleOutputAttribute';
function win____GetConsoleMode(hConsoleHandle: THandle; var lpMode: DWORD): BOOL; stdcall; external kernel32 name 'GetConsoleMode';
function win____SetConsoleCursorPosition(hConsoleOutput: THandle; dwCursorPosition: TCoord): BOOL; stdcall; external kernel32 name 'SetConsoleCursorPosition';
function win____SetConsoleTitle(lpConsoleTitle: PChar): BOOL; stdcall; external kernel32 name 'SetConsoleTitleA';
function win____SetConsoleCtrlHandler(HandlerRoutine: TFNHandlerRoutine; Add: BOOL): BOOL; stdcall; external kernel32 name 'SetConsoleCtrlHandler';
function win____GetNumberOfConsoleInputEvents(hConsoleInput: THandle; var lpNumberOfEvents: DWORD): BOOL; stdcall; external kernel32 name 'GetNumberOfConsoleInputEvents';
function win____ReadConsoleInput(hConsoleInput: THandle; var lpBuffer: TInputRecord; nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall; external kernel32 name 'ReadConsoleInputA';
function win____PeekMessage(var lpMsg: tmsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall; external user32 name 'PeekMessageA';
function win____DispatchMessage(const lpMsg: tmsg): Longint; stdcall; external user32 name 'DispatchMessageA';
function win____TranslateMessage(const lpMsg: tmsg): BOOL; stdcall; external user32 name 'TranslateMessage';
function win____GetDriveType(lpRootPathName: PChar): UINT; stdcall; external kernel32 name 'GetDriveTypeA';
function win____SetErrorMode(uMode: UINT): UINT; stdcall; external kernel32 name 'SetErrorMode';

function win____GetVolumeInformation(lpRootPathName: PChar;
  lpVolumeNameBuffer: PChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PChar; nFileSystemNameSize: DWORD): BOOL; stdcall; external kernel32 name 'GetVolumeInformationA';

function win____GetShortPathName(lpszLongPath: PChar; lpszShortPath: PChar; cchBuffer: DWORD): DWORD; stdcall; external kernel32 name 'GetShortPathNameA';

function win____SHGetSpecialFolderLocation(hwndOwner: HWND; nFolder: Integer; var ppidl: PItemIDList): HResult; stdcall; external shell32 name 'SHGetSpecialFolderLocation';
function win____SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall; external shell32 name 'SHGetPathFromIDListA';
function win____GetWindowsDirectoryA(lpBuffer: PAnsiChar; uSize: UINT): UINT; stdcall; external kernel32 name 'GetWindowsDirectoryA';
function win____GetSystemDirectoryA(lpBuffer: PAnsiChar; uSize: UINT): UINT; stdcall; external kernel32 name 'GetSystemDirectoryA';
function win____GetTempPathA(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall; external kernel32 name 'GetTempPathA';
function win____FlushFileBuffers(hFile: THandle): BOOL; stdcall; external kernel32 name 'FlushFileBuffers';
function win____CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: Integer;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall; external kernel32 name 'CreateFileA';
function win____GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall; external kernel32 name 'GetFileSize';
procedure win____GetSystemTime(var lpSystemTime: TSystemTime); stdcall; external kernel32 name 'GetSystemTime';
function win____CloseHandle(hObject: THandle): BOOL; stdcall; external kernel32 name 'CloseHandle';
function win____GetFileInformationByHandle(hFile: THandle; var lpFileInformation: TByHandleFileInformation): BOOL; stdcall; external kernel32 name 'GetFileInformationByHandle';
function win____SetFilePointer(hFile: THandle; lDistanceToMove: Longint; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall; external kernel32 name 'SetFilePointer';
function win____WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD; var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'WriteFile';
function win____ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'ReadFile';
function win____GetLogicalDrives: DWORD; stdcall; external kernel32 name 'GetLogicalDrives';
function win____FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'FileTimeToLocalFileTime';
function win____FileTimeToDosDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL; stdcall; external kernel32 name 'FileTimeToDosDateTime';
function win____DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external user32 name 'DefWindowProcA';
function win____RegisterClass(const lpWndClass: TWndClass): ATOM; stdcall; external user32 name 'RegisterClassA';
function win____RegisterClassA(const lpWndClass: TWndClassA): ATOM; stdcall; external user32 name 'RegisterClassA';
function win____CreateWindow(lpClassName: PChar; lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
function win____CreateWindowEx(dwExStyle: DWORD; lpClassName: PChar; lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND; stdcall; external user32 name 'CreateWindowExA';
function win____DestroyWindow(hWnd: HWND): BOOL; stdcall; external user32 name 'DestroyWindow';
function win____ShellExecute(hWnd: HWND; Operation, FileName, Parameters, Directory: PChar; ShowCmd: Integer): HINST; stdcall; external shell32 name 'ShellExecuteA';
function win____SHGetMalloc(var ppMalloc: imalloc): HResult; stdcall; external shell32 name 'SHGetMalloc';
function win____CreateComObject(const ClassID: TGUID): IUnknown;
procedure win____OleError(ErrorCode: HResult);
procedure win____OleCheck(Result: HResult);
function win____CoCreateInstance(const clsid: TCLSID; unkOuter: IUnknown; dwClsContext: Longint; const iid: TIID; out pv): HResult; stdcall; external ole32 name 'CoCreateInstance';
function win____TrimPunctuation(const S: string): string;
function win____GetObject(p1: HGDIOBJ; p2: Integer; p3: Pointer): Integer; stdcall; external gdi32 name 'GetObjectA';
function win____CreateFontIndirect(const p1: TLogFont): HFONT; stdcall; external gdi32 name 'CreateFontIndirectA';
function win____SelectObject(DC: HDC; p2: HGDIOBJ): HGDIOBJ; stdcall; external gdi32 name 'SelectObject';
function win____DeleteObject(p1: HGDIOBJ): BOOL; stdcall; external gdi32 name 'DeleteObject';
procedure win____sleep(dwMilliseconds: DWORD); stdcall; external kernel32 name 'Sleep';
function win____sleepex(dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall; external kernel32 name 'SleepEx';

//registry
function win____RegConnectRegistry(lpMachineName: PChar; hKey: HKEY; var phkResult: HKEY): Longint; stdcall; external advapi32 name 'RegConnectRegistryA';
function win___RegCreateKeyEx(hKey:HKEY;lpSubKey:PChar;Reserved:DWORD;lpClass:PChar;dwOptions:DWORD;samDesired:REGSAM;lpSecurityAttributes:PSecurityAttributes;var phkResult:HKEY;lpdwDisposition:PDWORD):Longint; stdcall; external advapi32 name 'RegCreateKeyExA';
function win____RegOpenKey(hKey: HKEY; lpSubKey: PChar; var phkResult: HKEY): Longint; stdcall; external advapi32 name 'RegOpenKeyA';
function win____RegCloseKey(hKey: HKEY): Longint; stdcall; external advapi32 name 'RegCloseKey';
function win____RegDeleteKey(hKey: HKEY; lpSubKey: PChar): Longint; stdcall; external advapi32 name 'RegDeleteKeyA';
function win____RegSetValueEx(hKey: HKEY; lpValueName: PChar; Reserved: DWORD; dwType: DWORD; lpData: Pointer; cbData: DWORD): Longint; stdcall; external advapi32 name 'RegSetValueExA';

//.support
function win____StartServiceCtrlDispatcher(var lpServiceStartTable: TServiceTableEntry): BOOL; stdcall; external advapi32 name 'StartServiceCtrlDispatcherA';
function win____RegisterServiceCtrlHandler(lpServiceName: PChar; lpHandlerProc: ThandlerFunction): SERVICE_STATUS_HANDLE; stdcall; external advapi32 name 'RegisterServiceCtrlHandlerA';
function win____SetServiceStatus(hServiceStatus: SERVICE_STATUS_HANDLE; var lpServiceStatus: TServiceStatus): BOOL; stdcall; external advapi32 name 'SetServiceStatus';
function win____OpenSCManager(lpMachineName, lpDatabaseName: PChar; dwDesiredAccess: DWORD): SC_HANDLE; stdcall; external advapi32 name 'OpenSCManagerA';
function win____CloseServiceHandle(hSCObject: SC_HANDLE): BOOL; stdcall; external advapi32 name 'CloseServiceHandle';
function win____CreateService(hSCManager: SC_HANDLE; lpServiceName, lpDisplayName: PChar; dwDesiredAccess, dwServiceType, dwStartType, dwErrorControl: DWORD; lpBinaryPathName, lpLoadOrderGroup: PChar; lpdwTagId: LPDWORD; lpDependencies, lpServiceStartName, lpPassword: PChar): SC_HANDLE; stdcall; external advapi32 name 'CreateServiceA';
function win____OpenService(hSCManager: SC_HANDLE; lpServiceName: PChar; dwDesiredAccess: DWORD): SC_HANDLE; stdcall; external advapi32 name 'OpenServiceA';
function win____DeleteService(hService: SC_HANDLE): BOOL; stdcall; external advapi32 name 'DeleteService';


//winmm.dll
function win____timeGetTime: DWORD; stdcall; external mmsyst name 'timeGetTime';
function win____timeSetEvent(uDelay, uResolution: UINT;  lpFunction: TFNTimeCallBack; dwUser: DWORD; uFlags: UINT): UINT; stdcall; external mmsyst name 'timeSetEvent';
function win____timeKillEvent(uTimerID: UINT): UINT; stdcall; external mmsyst name 'timeKillEvent';
function win____timeBeginPeriod(uPeriod: UINT): MMRESULT; stdcall; external mmsyst name 'timeBeginPeriod';
function win____timeEndPeriod(uPeriod: UINT): MMRESULT; stdcall; external mmsyst name 'timeEndPeriod';


//winsocket.dll
//.session
function net____WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer;                               stdcall;external winsocket name 'WSAStartup';
function net____WSACleanup: Integer;                                                                             stdcall;external winsocket name 'WSACleanup';
function net____wsaasyncselect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer;                stdcall;external winsocket name 'WSAAsyncSelect';
//function net____WSAGetLastError: Integer;                                                                        stdcall;external winsocket name 'WSAGetLastError';
//function net____WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle;   stdcall;external winsocket name 'WSAAsyncGetHostByName';
//.sockets
function net____makesocket(af, struct, protocol: Integer): TSocket;                                              stdcall;external winsocket name 'socket';
function net____bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer;                                stdcall;external winsocket name 'bind';
function net____listen(s: TSocket; backlog: Integer): Integer;                                                   stdcall;external winsocket name 'listen';
function net____closesocket(s: tsocket): integer;                                                                stdcall;external winsocket name 'closesocket';
function net____getsockopt(s: TSocket; level, optname: Integer; optval: PChar; var optlen: Integer): Integer;    stdcall;external winsocket name 'getsockopt';
function net____accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket;                                 stdcall;external winsocket name 'accept';
function net____recv(s: TSocket; var Buf; len, flags: Integer): Integer;                                         stdcall;external winsocket name 'recv';
function net____send(s: TSocket; var Buf; len, flags: Integer): Integer;                                         stdcall;external winsocket name 'send';
function net____send2(s:tsocket;var buf;len,flags:longint;var xsent:longint):boolean;
function net____getpeername(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer;                     stdcall;external winsocket name 'getpeername';


//file
function win__FindMatchingFile(var F: TSearchRec): Integer;
function win__FindFirst(const Path: string; Attr: longint; var F: TSearchRec): longint;
function win__FindNext(var F: TSearchRec): longint;//28jan2024
procedure win__FindClose(var F: TSearchRec);
function win____FindFirstFile(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name 'FindFirstFileA';
function win____FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall; external kernel32 name 'FindNextFileA';
function win____FindClose(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose';
function win____RemoveDirectory(lpPathName: PChar): BOOL; stdcall; external kernel32 name 'RemoveDirectoryA';


//console
function low__console(n:string;var v1,v2:longint):boolean;
function low__consoleb(n:string;v1,v2:longint):boolean;
function low__consolekey(xstdin:thandle):char;
function low__stdin:thandle;
function low__stdout:thandle;
function low__handleok(x:thandle):boolean;
procedure low__handlenone(var x:thandle);


//xxxxxxxxxxxxxxxxxxxxxxxx//7777777777777777777777

//registry procs ---------------------------------------------------------------
function reg__openkey(xrootkey:hkey;xuserkey:string;var xoutkey:hkey):boolean;
function reg__closekey(var xkey:hkey):boolean;
function reg__deletekey(xrootkey:hkey;xuserkey:string):boolean;
function reg__setstr(xkey:hkey;const xname,xvalue:string):boolean;
function reg__setstrx(xkey:hkey;xname,xvalue:string):boolean;
function reg__setint(xkey:hkey;xname:string;xvalue:longint):boolean;


//service procs ----------------------------------------------------------------
//.these procs enable the program to switch from console mode to service mode and handle service code requests
procedure service__start1;
procedure service__makecodehandler2;stdcall;
procedure service__coderesponder3(x:longint);stdcall;
procedure service__sendstatus4(xstate,xexitcode,xwaithint:dword);
//.install or uninstall this app as a service -> app must be installed as a service BEFORe procs (1-4) above will work
function service__install(var e:longint):boolean;
function service__install2(xname,xdisplayname,xfilename:string;var e:longint):boolean;
function service__uninstall(var e:longint):boolean;
function service__uninstall2(xname:string;var e:longint):boolean;


//root procs -------------------------------------------------------------------
function root__priority:boolean;//false=normal, true=fast
procedure root__setpriority(xfast:boolean);
function root__adminlevel:boolean;
function root__timeperiod:longint;
procedure root__settimeperiod(xms:longint);
procedure root__stoptimeperiod;
procedure root__throttleASdelay(xpert100:longint;var xloopcount:longint);


//compression support procs ----------------------------------------------------

//.Lazarus compression
{$ifdef laz}
function laz__compress(s:tobject;xcompress,xfast:boolean):boolean;//expects "s" to be a valid tstr8/str9 object -> 17feb2024, 05feb2021
{$endif}

//.Delphi 3 compression
{$ifdef d3}
function d3__compress(s:tobject;xcompress,xfast:boolean):boolean;//expects "s" to be a valid tstr8/str9 object -> 17feb2024, 05feb2021

const
   //zip compression
   zlib_version    ='1.0.4';
   Z_NO_FLUSH      = 0;
   Z_PARTIAL_FLUSH = 1;
   Z_SYNC_FLUSH    = 2;
   Z_FULL_FLUSH    = 3;
   Z_FINISH        = 4;
   Z_OK            = 0;
   Z_STREAM_END    = 1;
   Z_NEED_DICT     = 2;
   Z_ERRNO         = (-1);
   Z_STREAM_ERROR  = (-2);
   Z_DATA_ERROR    = (-3);
   Z_MEM_ERROR     = (-4);
   Z_BUF_ERROR     = (-5);
   Z_VERSION_ERROR = (-6);
   Z_NO_COMPRESSION       =   0;
   Z_BEST_SPEED           =   1;
   Z_BEST_COMPRESSION     =   9;
   Z_DEFAULT_COMPRESSION  = (-1);
   Z_FILTERED            = 1;
   Z_HUFFMAN_ONLY        = 2;
   Z_DEFAULT_STRATEGY    = 0;
   Z_BINARY   = 0;
   Z_ASCII    = 1;
   Z_UNKNOWN  = 2;
   Z_DEFLATED = 8;

type
   //.zip support
   TAlloc = function (AppData: Pointer; Items, Size: longint): Pointer;
   TFree = procedure (AppData, Block: Pointer);

   // Internal structure.  Ignore. - updated for "pointer instead of pchar" 26jan2021
   TZStreamRec = packed record
    next_in: pointer;//was: PChar;       // next input byte
    avail_in: longint;    // number of bytes available at next_in
    total_in: longint;    // total nb of input bytes read so far

    next_out: pointer;//was: PChar;      // next output byte should be put here
    avail_out: longint;   // remaining free space at next_out
    total_out: longint;   // total nb of bytes output so far

    msg: PChar;           // last error message, NULL if no error
    internal: Pointer;    // not visible by applications

    zalloc: TAlloc;       // used to allocate the internal state
    zfree: TFree;         // used to free the internal state
    AppData: Pointer;     // private data object passed to zalloc and zfree

    data_type: longint;   //  best guess about the data type: ascii or binary
    adler: longint;       // adler32 value of the uncompressed data
    reserved: longint;    // reserved for future use
   end;

//.support
function zlibAllocMem(AppData: Pointer; Items, Size: longint): Pointer;
procedure zlibFreeMem(AppData, Block: Pointer);
//.deflate compresses data
function deflateInit_(var strm: TZStreamRec; level: longint; version: PChar; recsize: longint): longint; external;
function deflate(var strm: TZStreamRec; flush: longint): longint; external;
function deflateEnd(var strm: TZStreamRec): longint; external;
//.inflate decompresses data
function inflateInit_(var strm: TZStreamRec; version: PChar; recsize: longint): longint; external;
function inflate(var strm: TZStreamRec; flush: longint): longint; external;
function inflateEnd(var strm: TZStreamRec): longint; external;
function inflateReset(var strm: TZStreamRec): longint; external;
{$endif}


//system procs -----------------------------------------------------------------
function gosswin__ver:string;
function low__ver:string;
procedure low__testlog(x:string);//for testing purposes -> write simple line by line log


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__win(xname:string):string;//information specific to this unit of code - 09apr2024


implementation

uses
   gossroot, gossio;


//.Delphi 3 compression libraries -> provides compression support
{$ifdef d3}
{$L deflate.obj}
{$L inflate.obj}
{$L inftrees.obj}
{$L trees.obj}
{$L adler32.obj}
{$L infblock.obj}
{$L infcodes.obj}
{$L infutil.obj}
{$L inffast.obj}
{$endif}


//info procs -------------------------------------------------------------------
//## app__info ##
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;
//## info__win ##
function info__win(xname:string):string;//information specific to this unit of code - 09apr2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//check -> xname must be "gosswin.*"
if (strcopy1(xname,1,8)='gosswin.') then strdel1(xname,1,8) else exit;

//get
if      (xname='ver')        then result:='4.00.730'
else if (xname='date')       then result:='04apr2024'
else if (xname='name')       then result:='Win32'
else
   begin
   //nil
   end;

except;end;
end;

//system procs -----------------------------------------------------------------
//## low__ver ##
function low__ver:string;
begin
result:='1.00.730';
end;
//## gosswin__ver ##
function gosswin__ver:string;
begin
result:=low__ver;
end;
//## low__testlog ##
procedure low__testlog(x:string);//for testing purposes -> write simple line by line log
var
   a:tstr9;
   e,df:string;
begin
try
//init
a:=nil;
df:='c:\temp\log.txt';

//get
if (x='') then io__remfile(df)
else
   begin
   a:=str__new9;
   str__saddb(@a,x+'<'+#10);
   io__tofileex64(df,@a,io__filesize64(df),false,e);
   end;
except;end;
try;str__free(@a);except;end;
end;

//Windows procs ----------------------------------------------------------------
//## win____CreateWindow ##
function win____CreateWindow(lpClassName: PChar; lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
begin
Result := win____CreateWindowEx(0, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;

{ Raise EOleSysError exception from an error code }

procedure win____OleError(ErrorCode: HResult);
begin
  raise win____EOleSysError.Create('', ErrorCode, 0);
end;

{ Raise EOleSysError exception if result code indicates an error }

procedure win____OleCheck(Result: HResult);
begin
  if Result < 0 then win____OleError(Result);
end;

function win____CreateComObject(const ClassID: TGUID): IUnknown;
begin
  win____OleCheck(win____CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or
    CLSCTX_LOCAL_SERVER, IUnknown, Result));
end;

{ EOleSysError }

constructor win____EOleSysError.Create(const Message: string;
  ErrorCode, HelpContext: Integer);
var
  S: string;
begin
  S := Message;
  if S = '' then
  begin
    S := SysErrorMessage(ErrorCode);
    if S = '' then FmtStr(S, SOleError, [ErrorCode]);
  end;
  inherited CreateHelp(S, HelpContext);
  FErrorCode := ErrorCode;
end;

{ EOleException }

constructor win____EOleException.Create(const Message: string; ErrorCode: Integer;
  const Source, HelpFile: string; HelpContext: Integer);
begin
  inherited Create(win____TrimPunctuation(Message), ErrorCode, HelpContext);
  FSource := Source;
  FHelpFile := HelpFile;
end;

function win____TrimPunctuation(const S: string): string;
var
  len:longint;
begin
  len := low__lengthb(s);
  while (Len > 0) and (S[len-1+stroffset] in [#0..#32, '.']) do Dec(Len);
  Result := strcopy1b(s,1,len);
end;


//Delphi 3 compression support -------------------------------------------------
{$ifdef d3}
procedure _tr_init; external;
procedure _tr_tally; external;
procedure _tr_flush_block; external;
procedure _tr_align; external;
procedure _tr_stored_block; external;
procedure adler32; external;

procedure inflate_blocks_new; external;
procedure inflate_blocks; external;
procedure inflate_blocks_reset; external;
procedure inflate_blocks_free; external;
procedure inflate_set_dictionary; external;
procedure inflate_trees_bits; external;
procedure inflate_trees_dynamic; external;
procedure inflate_trees_fixed; external;
procedure inflate_trees_free; external;
procedure inflate_codes_new; external;
procedure inflate_codes; external;
procedure inflate_codes_free; external;
procedure _inflate_mask; external;
procedure inflate_flush; external;
procedure inflate_fast; external;

procedure _memset(P: Pointer; B: Byte; count: longint);cdecl;
begin
FillChar(P^, count, B);
end;

procedure _memcpy(dest, source: Pointer; count: longint);cdecl;
begin
Move(source^, dest^, count);
end;

function zlibAllocMem(AppData: Pointer; Items, Size: longint): Pointer;
begin
//was: low__getmem(Result, Items*Size,80021);//15may2021
getmem(Result, Items*Size);//15may2021
end;

procedure zlibFreeMem(AppData, Block: Pointer);
begin
freemem(Block);
//was: low__freemem(block,0,80020);//04may2021
end;

//## d3__compress ##
function d3__compress(s:tobject;xcompress,xfast:boolean):boolean;//expects "s" to be a valid tstr8/str9 object -> 17feb2024, 05feb2021
label
   more,skipend;
var
   d:tobject;
   xmustclose:boolean;
   strm:TZStreamRec;
   smem,t:pdlbyte;
   v,spos,smin,smax,tsize,slen:longint;
begin
//defaults
result:=false;
xmustclose:=false;
d:=nil;
t:=nil;
tsize:=4096;

try
//lock
if not str__lock(@s) then exit;
slen:=str__len(@s);
if (slen<=0) then
   begin
   result:=true;
   goto skipend;
   end;
d:=str__new9;

//init
low__cls(@strm,sizeof(strm));
strm.zalloc:=zlibAllocMem;
strm.zfree:=zlibFreeMem;
getmem(t,tsize);
case xcompress of
true:if (z_ok=deflateInit_(strm,low__aorb(Z_BEST_COMPRESSION,Z_BEST_SPEED,xfast),zlib_version,sizeof(strm))) then xmustclose:=true else goto skipend;
false:if (z_ok=inflateInit_(strm,zlib_version,sizeof(strm))) then xmustclose:=true else goto skipend;
end;

//.out
strm.next_in:=nil;
strm.avail_in:=0;
strm.next_out:=t;
strm.avail_out:=tsize;

//get
spos:=0;
smax:=-2;
while true do
begin
//.read more data
if (strm.avail_in<=0) and (spos<slen) then
   begin
   if not block__fastinfo(@s,spos,smem,smin,smax) then goto skipend;
   strm.next_in:=smem;
   strm.avail_in:=smax-smin+1;
   inc(spos,smax-smin+1);
   end;

//.compress data
more:
if xcompress then v:=deflate(strm,z_sync_flush) else v:=inflate(strm,z_sync_flush);//z_sync_flush=works with very small buffers, whereas "z_no_flush" will fail - 16feb2024
//.ignore buf error as we may ask for data when there is none to be had -> simpler to implement - 17feb2024
if (v<0) and (v<>Z_BUF_ERROR) then goto skipend;

//.pull "out" data
if ((v=z_ok) or (v=z_stream_end)) and (strm.avail_out<tsize) then
   begin
   if not str__padd(@d,t,tsize-strm.avail_out) then goto skipend;
   strm.next_out:=t;
   strm.avail_out:=tsize;
   goto more;
   end;

//.finish
if (strm.avail_in<=0) and (strm.avail_out>=tsize) and (spos>=slen) then
   begin
   strm.next_out:=t;
   strm.avail_out:=tsize;
   if xcompress then deflate(strm,z_finish) else inflate(strm,z_finish);
   str__padd(@d,t,tsize-strm.avail_out);
   break;
   end;
end;//loop

//finalise s -> d
str__clear(@s);
if not str__add(@s,@d) then goto skipend;

//successful
result:=true;
skipend:
except;end;
try
if xmustclose then
   begin
   if xcompress then deflateEnd(strm) else inflateEnd(strm);
   end;
freemem(t,tsize);
except;end;
try
str__free(@d);
if (not result) then str__clear(@s);
str__uaf(@s);
except;end;
end;
{$endif}


//Lazarus compression support --------------------------------------------------
{$ifdef laz}
//## laz__compress ##
function laz__compress(s:tobject;xcompress,xfast:boolean):boolean;//expects "s" to be a valid tstr8/str9 object -> 17feb2024, 05feb2021
label
   more,skipend;
var
   d:tobject;
   xmustclose:boolean;
   strm:z_stream;
   smem,t:pdlbyte;
   int1,v,spos,smin,smax,tsize,slen:longint;
begin
//defaults
result:=false;
xmustclose:=false;
d:=nil;
t:=nil;
tsize:=4096;

try
//lock
if not str__lock(@s) then exit;
slen:=str__len(@s);
if (slen<=0) then
   begin
   result:=true;
   goto skipend;
   end;
d:=str__new9;

//init
low__cls(@strm,sizeof(strm));
//not used: strm.zalloc
//not used: strm.zfree
getmem(t,tsize);
case xcompress of
true:if (z_ok=deflateInit_(@strm,low__aorb(Z_BEST_COMPRESSION,Z_BEST_SPEED,xfast),zlib_version,sizeof(strm))) then xmustclose:=true else goto skipend;
false:if (z_ok=inflateInit_(@strm,zlib_version,sizeof(strm))) then xmustclose:=true else goto skipend;
end;

//.out
strm.next_in:=nil;
strm.avail_in:=0;
strm.next_out:=pbyte(t);
strm.avail_out:=tsize;

//get
spos:=0;
smax:=-2;
while true do
begin
//.read more data
if (strm.avail_in<=0) and (spos<slen) then
   begin
   if not block__fastinfo(@s,spos,smem,smin,smax) then goto skipend;
   strm.next_in:=pbyte(smem);
   strm.avail_in:=smax-smin+1;
   inc(spos,smax-smin+1);
   end;

//.compress data
more:
if xcompress then v:=deflate(strm,z_sync_flush) else v:=inflate(strm,z_sync_flush);
//.ignore buf error as we may ask for data when there is none to be had -> simpler to implement - 17feb2024
if (v<0) and (v<>Z_BUF_ERROR) then goto skipend;

//.pull "out" data
if ((v=z_ok) or (v=z_stream_end)) and (strm.avail_out<tsize) then
   begin
   if not str__padd(@d,t,tsize-strm.avail_out) then goto skipend;
   strm.next_out:=pbyte(t);
   strm.avail_out:=tsize;
   goto more;
   end;

//.finish
if (strm.avail_in<=0) and (strm.avail_out>=tsize) and (spos>=slen) then
   begin
   strm.next_out:=pbyte(t);
   strm.avail_out:=tsize;
   if xcompress then deflate(strm,z_finish) else inflate(strm,z_finish);
   str__padd(@d,t,tsize-strm.avail_out);
   break;
   end;
end;//loop

//finalise s -> d
str__clear(@s);
if not str__add(@s,@d) then goto skipend;

//successful
result:=true;
skipend:
except;end;
try
if xmustclose then
   begin
   if xcompress then deflateEnd(strm) else inflateEnd(strm);
   end;
freemem(t,tsize);
except;end;
try
str__free(@d);
if (not result) then str__clear(@s);
str__uaf(@s);
except;end;
end;
{$endif}

//## win__FindMatchingFile ##
function win__FindMatchingFile(var F: TSearchRec): longint;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not win____FindNextFile(FindHandle, FindData) then
      begin
        Result := win____GetLastError;
        Exit;
      end;
    win____FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    win____FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi,
      LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;
//## win__FindFirst ##
function win__FindFirst(const Path: string; Attr: longint; var F: TSearchRec): longint;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := win____FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := win__FindMatchingFile(F);
    if Result <> 0 then win__FindClose(F);
  end else
    Result := win____GetLastError;
end;
//## win__FindNext ##
function win__FindNext(var F: TSearchRec): longint;//28jan2024
begin
if (f.FindHandle=0) then
   begin
   result:=1;//error
   exit;
   end;
if win____FindNextFile(F.FindHandle, F.FindData) then Result := win__FindMatchingFile(F) else Result := win____GetLastError;
end;
//## win____FindClose ##
procedure win__FindClose(var F: TSearchRec);
begin
if (F.FindHandle <> INVALID_HANDLE_VALUE) then win____FindClose(F.FindHandle);
end;

//console procs ----------------------------------------------------------------
//## low__consoleb ##
function low__consoleb(n:string;v1,v2:longint):boolean;
begin
result:=low__console(n,v1,v2);
end;
//## low__console ##
function low__console(n:string;var v1,v2:longint):boolean;
var
   stdout:THandle;
   csbi:TConsoleScreenBufferInfo;
   xsize,xsizewritten:dword;
   a:tcoord;
   //## xstdoutOK ##
   function xstdoutOK:boolean;
   begin
   stdout:=win____GetStdHandle(STD_OUTPUT_HANDLE);
   result:=(stdout<>INVALID_HANDLE_VALUE);
   end;
begin
//defaults
result:=false;
try
//init
n:=strlow(n);
//get
if (n='cls') then
   begin
   if xstdoutOK and win____GetConsoleScreenBufferInfo(stdout,csbi) then
      begin
      xsize:=csbi.dwSize.x*csbi.dwSize.y;
      a.x:=0;
      a.y:=0;
      xsizewritten:=0;
      win____FillConsoleOutputCharacter(stdout,#32,xsize,a,xsizewritten);
      win____FillConsoleOutputAttribute(stdout,csbi.wAttributes,xsize,a,xsizewritten);
      win____SetConsoleCursorPosition(stdout,a);
      result:=true;
      end;
   end
else if (n='setcursorpos') then
   begin
   if xstdoutOK then
      begin
      a.x:=smallint(v1);
      a.y:=smallint(v2);
      win____SetConsoleCursorPosition(stdout,a);
      result:=true;
      end;
   end
else if (n='windowsize') then
     begin
     v1:=0;
     v2:=0;
     if xstdoutOK and win____GetConsoleScreenBufferInfo(stdout,csbi) then
        begin
        //get
        v1:=csbi.srWindow.right-csbi.srWindow.left+1;
        v2:=csbi.srWindow.bottom-csbi.srWindow.top+1;
        //.shrink width & height to allow for terminal window scrollbar (right) / minor padding (bottom)
        v1:=frcmin32(v1-1,0);
        v2:=frcmin32(v2-1,0);
        //successful
        result:=true;
        end;
     end;
except;end;
end;
//## low__stdin ##
function low__stdin:thandle;
begin
result:=invalid_handle_value;try;result:=win____GetStdHandle(STD_INPUT_HANDLE);except;end;
end;
//## low__stdout ##
function low__stdout:thandle;
begin
result:=invalid_handle_value;try;result:=win____GetStdHandle(STD_OUTPUT_HANDLE);except;end;
end;
//## low__handleok ##
function low__handleok(x:thandle):boolean;
begin
result:=(x<>invalid_handle_value);
end;
//## low__handlenone ##
procedure low__handlenone(var x:thandle);
begin
try;x:=invalid_handle_value;except;end;
end;
//## low__consolekey ##
function low__consolekey(xstdin:thandle):char;
var
   a:tinputrecord;
   acount:dword;
begin
result:=#0;
try;if (xstdin<>INVALID_HANDLE_VALUE) and win____ReadConsoleInput(xstdin,a,1,acount) and (acount>=1) and (a.EventType=1) and a.KeyEvent.bKeyDown then result:=a.KeyEvent.asciichar;except;end;
end;
//## net____send2 ##
function net____send2(s:tsocket;var buf;len,flags:longint;var xsent:longint):boolean;
begin
xsent:=net____send(s,buf,len,flags);
result:=(xsent>=1);
end;

//registry procs ---------------------------------------------------------------
//## reg__openkey ##
function reg__openkey(xrootkey:hkey;xuserkey:string;var xoutkey:hkey):boolean;
begin
//defaults
result:=false;
xoutkey:=0;
try
//create key
result:=(0=win___RegCreateKeyEx(xrootkey,pchar(xuserkey),0,nil,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,xoutkey,nil));
//open key
if not result then result:=(0=win____RegOpenKey(xrootkey,pchar(xuserkey),xoutkey));
except;end;
end;
//## reg__closekey ##
function reg__closekey(var xkey:hkey):boolean;
begin
if (xkey=0) then result:=true
else
   begin
   result:=(0=win____RegCloseKey(xkey));
   if result then xkey:=0;
   end;
end;
//## reg__deletekey ##
function reg__deletekey(xrootkey:hkey;xuserkey:string):boolean;
begin
result:=(0=win____RegDeleteKey(xrootkey,pchar(xuserkey)));
end;
//## reg__setstr ##
function reg__setstr(xkey:hkey;const xname,xvalue:string):boolean;
begin
result:=(0=win____RegSetValueEx(xkey,pchar(xname),0,reg_sz,pchar(xvalue),1+low__lengthb(xvalue)));
end;
//## reg__setstrx ##
function reg__setstrx(xkey:hkey;xname,xvalue:string):boolean;
begin
result:=(0=win____RegSetValueEx(xkey,pchar(xname),0,reg_expand_sz,pchar(xvalue),1+low__length(xvalue)));
end;
//## reg__setint ##
function reg__setint(xkey:hkey;xname:string;xvalue:longint):boolean;
begin
result:=(0=win____RegSetValueEx(xkey,pchar(xname),0,reg_dword,@xvalue,sizeof(xvalue)));
end;

//service procs ----------------------------------------------------------------
//## service__start1 ##
procedure service__start1;//stage 1: setup app to function as a service
begin
try
system_servicetable[0].lpServiceName:=pchar(app__info('service.name'));
system_servicetable[0].lpServiceProc:=@service__makecodehandler2;
system_servicetable[1].lpServiceName:=nil;
system_servicetable[1].lpServiceProc:=nil;
win____StartServiceCtrlDispatcher(system_servicetable[0]);
except;end;
end;
//## service__makecodehandler2 ##
procedure service__makecodehandler2;stdcall;//stage 2: activate the service handler proc -> if this fails then we're not running as a service but as a console app
begin
try
system_servicestatus.dwServiceType              :=16;//SERVICE_WIN32_OWN_PROCESS;
system_servicestatus.dwCurrentState             :=SERVICE_START_PENDING;
system_servicestatus.dwControlsAccepted         :=SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_PAUSE_CONTINUE;
system_servicestatus.dwServiceSpecificExitCode  :=0;
system_servicestatus.dwWin32ExitCode            :=0;
system_servicestatus.dwCheckPoint               :=0;
system_servicestatus.dwWaitHint                 :=0;
system_servicestatush:=win____RegisterServiceCtrlHandler(pchar(app__info('service.name')),@service__coderesponder3);

if (system_servicestatush<>0) then
   begin
   service__sendstatus4(SERVICE_RUNNING, NO_ERROR, 0);
   system_runstyle:=rsService;
   app__run;
   end
else
   begin
   service__sendstatus4(SERVICE_STOPPED, NO_ERROR, 0);
   end;
except;end;
end;
//## service__coderesponder3 ##
procedure service__coderesponder3(x:longint);stdcall;//stage 3: handle any service code requests
begin
case x of
SERVICE_CONTROL_STOP:begin
   service__sendstatus4(service_stopped,no_error,0);
   app__halt;
   end;
SERVICE_CONTROL_PAUSE:begin
   app__pause(true);
   service__sendstatus4(service_paused,no_error,0);
   end;
SERVICE_CONTROL_CONTINUE:begin
   app__pause(false);
   service__sendstatus4(service_running,no_error,0);
   end;
SERVICE_CONTROL_INTERROGATE:service__sendstatus4(system_servicestatus.dwCurrentState,no_error,0);
SERVICE_CONTROL_SHUTDOWN:app__halt;
end;//case
end;
//## service__sendstatus4 ##
procedure service__sendstatus4(xstate,xexitcode,xwaithint:dword);//part 4: send status codes back to Windows
begin
try
//init
system_servicestatus.dwCurrentState :=xstate;
system_servicestatus.dwWin32ExitCode:=xexitcode;
system_servicestatus.dwWaitHint     :=xwaithint;

//get
case (xstate=SERVICE_START_PENDING) of
true:system_servicestatus.dwControlsAccepted:=0;
false:system_servicestatus.dwControlsAccepted:=SERVICE_ACCEPT_STOP;
end;

case (xstate=SERVICE_RUNNING) or (xstate=SERVICE_STOPPED) of
true:system_servicestatus.dwCheckPoint:=0;
false:system_servicestatus.dwCheckPoint:=1;
end;

win____SetServiceStatus(system_servicestatush,system_servicestatus);
except;end;
end;
//## service__install ##
function service__install(var e:longint):boolean;
begin
result:=service__install2('','','',e);
end;
//## service__install2 ##
function service__install2(xname,xdisplayname,xfilename:string;var e:longint):boolean;
var
   h,h2:SC_HANDLE;
   dkey:hkey;
begin
//defaults
result:=false;
h:=0;
h2:=0;
e:=0;

try
//range
xname:=strcopy1b(strdefb(xname,app__info('service.name')),1,256);
xdisplayname:=strcopy1b(strdefb(xdisplayname,app__info('service.displayname')),1,256);
xfilename:=strdefb(xfilename,io__exename);

//get
h:=win____OpenSCManager(nil,nil,SC_MANAGER_ALL_ACCESS);
if (h<>0) then
   begin
   h2:=win____CreateService(h,pchar(xname),pchar(xdisplayname),SC_MANAGER_ALL_ACCESS,16,2,0,pchar('"'+xfilename+'"'),nil,nil,nil,nil,nil);
   case (h2<>0) of
   true:result:=true;
   false:begin
      e:=win____getlasterror;
      case e of
      1073:result:=true;//service already exists
      end;//case
      end;
   end;//case
   end;

//description
if result and reg__openkey(hkey_local_machine,'SYSTEM\CurrentControlSet\Services\'+app__info('service.name')+'\',dkey) then
   begin
   reg__setstr(dkey,'Description',strdefb(app__info('service.description'),app__info('service.displayname')));
   reg__closekey(dkey);
   end;

except;end;
try
win____CloseServiceHandle(h2);
win____CloseServiceHandle(h);
except;end;
end;
//## service__uninstall ##
function service__uninstall(var e:longint):boolean;
begin
result:=service__uninstall2('',e);
end;
//## service__uninstall2 ##
function service__uninstall2(xname:string;var e:longint):boolean;
var
   h,h2:SC_HANDLE;
begin
//defaults
result:=false;
h:=0;
h2:=0;
e:=0;

try
//range
xname:=strcopy1b(strdefb(xname,app__info('service.name')),1,256);

//get
h:=win____OpenSCManager(nil,nil,SC_MANAGER_ALL_ACCESS);
if (h<>0) then
   begin
   h2:=win____OpenService(h,pchar(xname),SC_MANAGER_ALL_ACCESS);
   result:=(h2<>0) and win____DeleteService(h2);
   if not result then
      begin
      e:=win____getlasterror;
      case e of
      1060:result:=true;//The specified service does not exist
      1072:result:=true;//The specified service has been marked for deletion.
      end;//case
      end;
   end;
except;end;
try
win____CloseServiceHandle(h2);
win____CloseServiceHandle(h);
except;end;
end;
//## root__priority ##
function root__priority:boolean;//false=normal, true=fast
begin
result:=(REALTIME_PRIORITY_CLASS=win____getpriorityclass(win____getcurrentprocess));
end;
//## root__setpriority ##
procedure root__setpriority(xfast:boolean);
begin
try;win____setpriorityclass(win____getcurrentprocess,low__aorb(NORMAL_PRIORITY_CLASS,REALTIME_PRIORITY_CLASS,xfast));except;end;
end;
//## root__adminlevel ##
function root__adminlevel:boolean;
var
   h:SC_HANDLE;
begin
case system_adminlevel of
1:result:=false;
2:result:=true;
else
   begin
   h:=win____OpenSCManager(nil,nil,SC_MANAGER_ALL_ACCESS);
   if (h<>0) then
      begin
      result:=true;
      system_adminlevel:=2;
      win____CloseServiceHandle(h);
      end
   else
      begin
      result:=false;
      system_adminlevel:=1;
      end;
   end;//begin
end;//case
end;
//## root__timeperiod ##
function root__timeperiod:longint;
begin
result:=system_timeperiod;
end;
//## root__settimeperiod ##
procedure root__settimeperiod(xms:longint);
begin
//range
if (xms<1) then xms:=1 else if (xms>1000) then xms:=1000;
//remove previous
if (system_timeperiod>=1) then win____timeEndPeriod(system_timeperiod);
//set new
system_timeperiod:=xms;
win____timeBeginPeriod(xms);
end;
//## root__stoptimeperiod ##
procedure root__stoptimeperiod;
begin
try
if (system_timeperiod>=1) then
   begin
   win____timeEndPeriod(system_timeperiod);
   system_timeperiod:=0;
   end;
except;end;
end;
//## root__throttleASdelay ##
procedure root__throttleASdelay(xpert100:longint;var xloopcount:longint);
var//note: xpert100=0..100 where 0=slow and 100=fast
   xms:longint;
begin
//defaults
xloopcount:=1;

//range
if (xpert100<0) then xpert100:=0 else if (xpert100>100) then xpert100:=100;

//delay
xms:=round(30-(xpert100/3.33));
if (xms<1) then xms:=1;

//thread timing resolution
case (xpert100<=10) of
true:root__stoptimeperiod;//normal mode
false:if (system_timeperiod>1) or (system_timeperiod=0) then root__settimeperiod(1);//fast
end;

//wait
app__waitms(xms);

//loop count -> used to execute host code a number of times
xloopcount:=round(xpert100*xpert100*0.01);//1..100 loop count -> exponential increase
if (xloopcount<1) then xloopcount:=1;
end;

end.

