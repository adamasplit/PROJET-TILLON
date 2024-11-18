unit fichierSys;

interface

uses sysutils,coeur;

procedure sauvegarder(stats:TStats);

procedure chargerSauvegarde(var stats:TStats);

function extractionTexte(code:String):String;

implementation

procedure sauvegarder(stats:TStats);
var fichier:File of TStats;
begin
    assign(fichier,'sauvegarde_COF');
    rewrite(fichier);
    write(fichier,stats);
    close(fichier);
end;

procedure chargerSauvegarde(var stats:TStats);
var fichier:File of TStats;
begin
    if fileExists('sauvegarde_COF') then
        begin
        assign(fichier,'sauvegarde_COF');
        reset(fichier);
        read(fichier,stats)
        end
    else
        begin
        end;
    close(fichier)
end;

function extractionTexte(code:String):String;
var fichier:Text;charTemp:Char;balise:String;codeTrouve:Boolean;
begin
    assign(fichier,'Texte.txt');
    reset(fichier);
    charTemp:=' ';
    codeTrouve:=False;
    repeat
        while (charTemp<>'<') and not (eof(fichier)) do
            begin
            read(fichier,charTemp);
            //if charTemp<>' ' then
                //writeln(charTemp);
            end;
        balise:='';
        while (charTemp<>'>') and not (eof(fichier)) do
            begin
            read(fichier,charTemp);
            if charTemp<>'>' then
                balise:=balise+charTemp;
            end;
        codeTrouve:=(balise=code);
    until codeTrouve or Eof(fichier);
    extractionTexte:='';
    while (charTemp<>';') and not eof(fichier) do
            begin
            read(fichier,charTemp);
            if charTemp<>';' then
                extractionTexte:=extractionTexte+charTemp;
            end;
    close(fichier);
    if extractionTexte='' then
        extractionTexte:=code;
end;


begin
end.