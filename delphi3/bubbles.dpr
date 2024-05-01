program bubbles;

uses
   bubbles1 in 'bubbles1.pas',
   gossroot in 'gossroot.pas',
   gossio in 'gossio.pas',
   gossimg in 'gossimg.pas',
   gossnet in 'gossnet.pas',
   gosswin in 'gosswin.pas';

{$R *.RES}

begin
//event driven=false, file handle caching=true
app__boot(false,true);
end.
