unit SonoSys;
interface
uses
    SDL2,
    SDL2_mixer,
    SysUtils; //télécharger SDL2_mixer au préalable

const TAILLE_OST=50;
        VOLUME_MUSIQUE=20;
        VOLUME_SON=20;
        MAX_CHAINES = 8;
type TMus=record
    duree:real;
    nom:String;
    dir:PChar;
end;

var OST:array[0..TAILLE_OST] of TMus;
    SFX:array[1..MAX_CHAINES] of PMix_Chunk;
    MusiqueJouee:PMix_Music;
    IndiceMusiqueJouee,chaineActuelle:Integer;
    indiceMusiquePrec:Integer;
    updateTimeMusique,tempsTemp:UInt32;
    enFondu:Boolean;


procedure jouerSon(nomFichier:PChar);overload;//joue un son .WAV
procedure jouerSon(nomFichier:PCHar;volume:Integer);overload;
procedure autoMusique(var indice:Integer); //recommence une musique si elle est finie (à mettre dans la boucle d'actualisation du jeu)
procedure JouerSonEff(nom:String);
procedure arretMus(duree:Integer);//éteindre progressivement la musique, durée en ms
procedure arretSons(duree:Integer);//arrêter tous les sons
procedure JouerSonEnn(nom:String);overload;
procedure JouerSonEnn(nom:String;num:Integer);overload;


//autres procédures déjà présentes : mix_pause/resume, mix_pause/resumeMusic, pour arrêter/reprendre tous les sons ou la musique
//mix_rewindMusic pour recommencer une musique depuis le début

{IMPORTANT : à la fin du programme, utiliser 'Mix_CloseAudio' ainsi que 'Mix_FreeMusic' ou 'Mix_FreeChunk' pour des variables PMix_Music ou PMix_Chunk}
implementation

function StringToPChar(s : string) : Pchar;
begin
StringToPChar := StrAlloc(Length(s)+1);
StrPCopy(StringToPChar, s);
end;

function chargerSFX(nomFichier:PCHar):PMix_Chunk;
    begin
    chargerSFX := Mix_LoadWAV(nomFichier);
    if chargerSFX = nil then Exit;
    Mix_VolumeChunk(chargerSFX, VOLUME_SON);
    end;

function chargerOST(nomFichier:PChar):PMix_Music;
    begin
    chargerOST := Mix_LoadMUS(nomFichier);
    if chargerOST = nil then Exit;
    Mix_VolumeMusic(VOLUME_MUSIQUE);
    end;

procedure defMus(indice:Integer;dir:Pchar;nom:String;duree:real);

begin
    OST[indice].dir:=dir;
    OST[indice].nom:=nom;
    OST[indice].duree:=duree;
end;

procedure jouerSon(nomFichier:PCHar;volume:Integer); //identique à JouerSon, mais se fait à un volume donné
begin
    if fileExists(nomFichier) then
        begin
            Mix_FreeChunk(SFX[chaineActuelle]);
            SFX[chaineActuelle]:=chargerSFX(nomFichier);
            Mix_VolumeChunk(SFX[chaineActuelle],volume);
            Mix_PlayChannel(chaineActuelle,SFX[chaineActuelle],0);
            chaineActuelle:=chaineActuelle+1;
            if chaineActuelle>6 then
                chaineActuelle:=1;
        end;
end;

procedure jouerSon(nomFichier:PCHar); //joue un son 
begin
    if fileExists(nomFichier) then
        begin
            Mix_FreeChunk(SFX[chaineActuelle]); //libère un son s'il y en a déjà trop dans la liste d'effets sonores
            SFX[chaineActuelle]:=chargerSFX(nomFichier); //charge le son
            Mix_PlayChannel(chaineActuelle,SFX[chaineActuelle],0);
            chaineActuelle:=chaineActuelle+1;
            if chaineActuelle>6 then
                chaineActuelle:=1;
        end;
end;

procedure JouerSonEff(nom:String); //joue un son au volume adapté parmi ceux des effets
begin
    case nom of
    'ange','soleil','monde':jouerSon(StringToPChar('SFX/Effets/'+nom+'.wav'),VOLUME_SON);
    'impact':jouerSon(StringToPChar('SFX/Effets/'+nom+'.wav'),VOLUME_SON div 3);
    else
    jouerSon(StringToPChar('SFX/Effets/'+nom+'.wav'),VOLUME_SON div 2);
    end;
end;

procedure JouerSonEnn(nom:String);
begin
  jouerSon(StringToPChar('SFX/Ennemis/'+nom+'.wav'),VOLUME_SON * 2);
end;

procedure JouerSonEnn(nom:String;num:Integer);
begin
    if nom='elementaires' then
        jouerSon(StringToPChar('SFX/Ennemis/'+nom+' ('+intToStr(num)+').wav'),VOLUME_SON * 4)
    else
        jouerSon(StringToPChar('SFX/Ennemis/'+nom+' ('+intToStr(num)+').wav'),VOLUME_SON * 2);
end;

procedure autoMusique(var indice:integer);
begin
    SDL_PumpEvents;
        if (Indice<>indiceMusiquePrec) then
            if indiceMusiquePrec=0 then
                begin
                MusiqueJouee:=chargerOST(OST[Indice].dir);
                mix_playMusic(MusiqueJouee,0);
                indiceMusiquePrec:=indice;
                end
            else
                begin //change de musique (libère l'ancienne et joue la nouvelle)
                Mix_FreeMusic(MusiqueJouee);
                MusiqueJouee:=chargerOST(OST[Indice].dir);
                mix_playMusic(MusiqueJouee,0);
                writeln('changing music from ',indiceMusiquePrec,' to ',indice);
                indiceMusiquePrec:=indice;
                updatetimemusique:=sdl_getticks;
                end;
        if (SDL_GetTicks()-UpdateTimeMusique)>(OST[indice].duree)*1000 then //vérifier si le morceau est fini ou non
            begin
            if (indice>=16) and (indice<=31) then
                indice:=indice+14
            else
                mix_playMusic(musiquejouee,0);
            updatetimeMusique := SDL_GetTicks();
            end;
        {if leMonde and (tempsTemp=0) and not(enFondu) then
            begin
            mix_pauseMusic;
            tempsTemp:=sdl_getticks;
            end;
        if (not leMonde) and (tempsTemp<>0) then
            begin
            mix_resumeMusic;
            updateTimeMusique:=updateTimeMusique+(sdl_getTicks-tempsTemp);
            tempsTemp:=0;
            end;}
end;

procedure arretMus(duree:Integer);
begin
    Mix_FadeOutMusic(duree);
end;
procedure arretSons(duree:Integer);
begin
    Mix_FadeOutChannel(1, duree);
end;

procedure detruireOST();
begin
    Mix_CloseAudio
end;

begin
indiceMusiquePrec:=0;
tempsTemp:=0;
chaineActuelle:=0;
updatetimeMusique := SDL_GetTicks();
Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 4096);

    //Ecran titre
    defMus(0,'OST/Project_TITLE.wav','Cards of Fortune',101.6);
    //Combats normaux
    defMus(1,'OST/C0.wav','',102);
    defMus(2,'OST/C1.ogg','W-O-A-Y v0',51);
    defMus(3,'OST/C2.wav','W-O-A-Y V2',48);
    defMus(4,'OST/C3.wav','',104);
    defMus(5,'OST/C4.wav','',96);
    defMus(6,'OST/C5.wav','With Or Against You',113);
    defMus(7,'OST/C6.wav','',72);
    defMus(8,'OST/C7.wav','',142);
    //Boss
    defMus(9,'OST/Boss0.wav','',72);
    defMus(10,'OST/Boss1.wav','',120);
    defMus(13,'OST/Boss2.wav','',116);
    defMus(11,'OST/Boss3.wav','',149);
    defMus(12,'OST/Boss4.wav','',133);
    //Map/évènements
    defMus(14,'OST/Map.wav','',163);
    defMus(15,'OST/Event.wav','',49);
    //Fanfares de victoire
    defMus(19,'OST/C0_VictoireIntro.wav','',4);
    defMus(20,'OST/C1_VictoireIntro.wav','',5);
    defMus(21,'OST/C2_VictoireIntro.wav','',5);
    defMus(22,'OST/C3_VictoireIntro.wav','',5);
    defMus(23,'OST/C4_VictoireIntro.wav','',3);
    defMus(24,'OST/C5_VictoireIntro.wav','',5);
    defMus(25,'OST/C6_VictoireIntro.wav','',4);
    defMus(26,'OST/C7_VictoireIntro.wav','',6);
    defMus(27,'OST/Boss0_VictoireIntro.wav','',4);
    defMus(28,'OST/Boss1_VictoireIntro.wav','',5);
    defMus(31,'OST/Boss2_VictoireIntro.wav','',7);
    defMus(29,'OST/Boss3_VictoireIntro.wav','',5);
    defMus(30,'OST/Boss4_VictoireIntro.wav','',5);
    //Thèmes de victoire/map
    defMus(33,'OST/C0_VictoireRep.wav','',66);
    defMus(34,'OST/C1_VictoireRep.wav','',6);
    defMus(35,'OST/C2_VictoireRep.wav','',11);
    defMus(36,'OST/C3_VictoireRep.wav','',33);
    defMus(37,'OST/C4_VictoireRep.wav','',36);
    defMus(38,'OST/C5_VictoireRep.wav','',18);
    defMus(39,'OST/C6_VictoireRep.wav','',48);
    defMus(40,'OST/C7_VictoireRep.wav','',48);
    defMus(41,'OST/Boss0_VictoireRep.wav','',71);
    defMus(42,'OST/Boss1_VictoireRep.wav','',81);
    defMus(45,'OST/Boss2_VictoireRep.wav','',81);
    defMus(43,'OST/Boss3_VictoireRep.wav','',99);
    defMus(44,'OST/Boss4_VictoireRep.wav','',27);
    //Mort
    defMus(47,'OST\Project_DEATH.wav','',24);
    defMus(46,'OST\Project_DEATH2.wav','',72);


end.

