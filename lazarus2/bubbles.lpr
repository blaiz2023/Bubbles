program bubbles;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Classes, SysUtils, main, gossnet, gossimg, gossroot, gossio, search
  { you can add units after this };


{$R *.res}

begin
  //event driven=false, file handle caching=true
  app__boot(false,true,false);
end.

