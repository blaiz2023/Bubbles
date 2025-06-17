program bubbles;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces,// this includes the LCL widgetset
  main,
  tools,
  gossroot,
  gossio,
  gossimg,
  gossnet,
  gosswin;
  { you can add units after this }



//include multi-format icon - Delphi 3 can't compile an of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R bubbles-16-256.res}

begin
//(1)true=timer event driven and false=direct processing, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(false,true,not isconsole);
end.
