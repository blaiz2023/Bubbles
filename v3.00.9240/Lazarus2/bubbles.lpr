program bubbles;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, bubbles1, gossnet, gossimg, gossroot, gossio
  { you can add units after this };


{$R *.res}

begin
  //event driven=false, file handle caching=true
  app__boot(false,true);
end.

