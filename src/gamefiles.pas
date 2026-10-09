unit gamefiles;

//---------------------------------------------------------------------------------------
// This unit of packed files was built using Blaiz Tools v1.00.2708 by Blaiz Enterprises
//---------------------------------------------------------------------------------------

interface

function storage__findfile(const xindex:longint;var xdata:pointer;var xdatalen,xorgsize:longint;var xcompressed:boolean;var xpathname:string):boolean;

implementation



function storage__findfile(const xindex:longint;var xdata:pointer;var xdatalen,xorgsize:longint;var xcompressed:boolean;var xpathname:string):boolean;

   procedure xset(const fdata:array of byte;const fcompressed:boolean;const fsize:longint;const fpathname:string);
   begin

   result     :=true;
   xdata      :=@fdata;
   xdatalen   :=high(fdata)+1;
   xorgsize   :=fsize;
   xcompressed:=fcompressed;
   xpathname  :=fpathname;

   end;

begin

//defaults
result:=false;

end;


end.

