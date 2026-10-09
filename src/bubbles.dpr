program bubbles;

uses
  main in 'main.pas',
  tools in 'tools.pas',
  gossroot in 'gossroot.pas',
  gossio in 'gossio.pas',
  gossimg in 'gossimg.pas',
  gossnet in 'gossnet.pas',
  gosswin in 'gosswin.pas',
  gossjpg in 'gossjpg.pas',
  gosszip in 'gosszip.pas',
  gamefiles in 'gamefiles.pas';


//include multi-format icon - Delphi 3 can't compile an of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R bubbles-256.res}

//include version information
{$R ver.res}

begin
//(1)false=event driven disabled, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(false,true,not isconsole);
end.
