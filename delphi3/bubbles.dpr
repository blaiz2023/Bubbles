program bubbles;

uses
  main in 'main.pas',
  gossroot in 'gossroot.pas',
  gossio in 'gossio.pas',
  gossimg in 'gossimg.pas',
  gossnet in 'gossnet.pas',
  gosswin in 'gosswin.pas',
  tools in 'tools.pas';

//{$R *.RES}

//include multi-format icon - Delphi 3 can't compile an of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R app-icon-16-256px.res}

begin
//(1)true=timer event driven and false=direct processing, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(false,true,not isconsole);
end.
