program bubbles;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  main,
  tools,
  gossroot,
  gossio,
  gossimg,
  gossnet,
  gosswin,
  gossjpg,
  gosszip,
  gamefiles;
  { you can add units after this }



//include multi-format icon - Delphi 3 can't compile an of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R bubbles-256.res}

//include version information
{$R ver.res}

begin
//(1)false=event driven disabled, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(false,true,not isconsole);
end.
