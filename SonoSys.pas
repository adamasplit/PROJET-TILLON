unit SonoSys;
interface
uses SDL2, SDL2_mixer,SysUtils,coeur; //télécharger SDL2_mixer au préalable

const TAILLE_OST=31;
        VOLUME_MUSIQUE=40;
        VOLUME_SON=40;
type TMus=record
    musique:PMix_Music;
    duree:Integer;
    nom:String;
    dir:PChar;
end;

var OST:array[1..TAILLE_OST] of TMus;
    IndiceMusiqueJouee:Integer;
    indiceMusiquePrec:Integer;
    updateTimeMusique,tempsTemp:UInt32;
    enFondu:Boolean;


procedure jouerSon(nomFichier:PChar);//joue un son .WAV
procedure jouerMus(i:Integer);//joue une musique .OGG ou .WAV
procedure autoMusique(); //recommence une musique si elle est finie (à mettre dans la boucle d'actualisation du jeu)

procedure arretMus(duree:Integer);//éteindre progressivement la musique, durée en ms
procedure arretSons(duree:Integer);//arrêter tous les sons
procedure detruireOST();//à mettre impérativement en fin du programme


//autres procédures déjà présentes : mix_pause/resume, mix_pause/resumeMusic, pour arrêter/reprendre tous les sons ou la musique
//mix_rewindMusic pour recommencer une musique depuis le début

{IMPORTANT : à la fin du programme, utiliser 'Mix_CloseAudio' ainsi que 'Mix_FreeMusic' ou 'Mix_FreeChunk' pour des variables PMix_Music ou PMix_Chunk}
implementation

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

procedure defMus(indice:Integer;dir:Pchar;nom:String;duree:Integer);

begin
    OST[indice].musique:=Mix_LoadMUS(dir);
    if OST[indice].musique = nil then writeln('La musique n°',indice,' n"est pas correctement chargée');
    OST[indice].dir:=dir;
    OST[indice].nom:=nom;
    OST[indice].duree:=duree;
end;

procedure jouerSon(nomFichier:PCHar);
begin
    Mix_PlayChannel(1,chargerSFX(nomFichier),0)
end;

procedure jouerMus(i:Integer);
begin
    mix_playMusic(chargerOST(OST[i].dir),0);
end;

procedure autoMusique();
begin
    SDL_PumpEvents;
        if (IndiceMusiqueJouee<>indiceMusiquePrec) then
            if indiceMusiquePrec=0 then
                begin
                mix_playMusic(OST[IndiceMusiqueJouee].musique,0);
                indiceMusiquePrec:=indiceMusiqueJouee;
                end
            else
                begin
                writeln('changing music from ',indiceMusiquePrec,' to ',indiceMusiqueJouee);
                indiceMusiquePrec:=indiceMusiqueJouee;
                updatetimemusique:=sdl_getticks;
                enFondu:=True;
                //mix_fadeoutmusic(1000)
                end;
        if enFondu and (sdl_getTicks-updateTimeMusique>0) then
            begin
            mix_playMusic(OST[IndiceMusiqueJouee].musique,0);
            enFondu:=False;
            end;
        if (SDL_GetTicks()-UpdateTimeMusique)>(OST[indiceMusiqueJouee].duree)*1000 then //vérifier si le morceau est fini ou non
            begin
            if (indiceMusiqueJouee>12) and (indiceMusiqueJouee<22) then
                indiceMusiqueJouee:=indiceMusiqueJouee+10
            else
                mix_rewindMusic();
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
var i:Integer;
begin
    for i:=1 to TAILLE_OST do
        if Assigned(OST[i].musique) then Mix_FreeMusic(OST[i].musique);
    Mix_CloseAudio
end;

begin
indiceMusiquePrec:=0;
tempsTemp:=0;
Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 4096);

    //Ecran titre
    defMus(1,'OST/Project_TITLE.wav','Cards of Fortune',102);
    //Combats normaux
    defMus(2,'OST/C1.ogg','W-O-A-Y v0',51);
    defMus(3,'OST/C2.wav','W-O-A-Y V2',48);
    defMus(4,'OST/C3.wav','',104);
    defMus(5,'OST/C4.wav','',96);
    defMus(6,'OST/C5.wav','With Or Against You',113);
    //Boss
    defMus(7,'OST/Boss1.wav','',120);
    defMus(8,'OST/Boss2.wav','',116);
    defMus(9,'OST/Boss3.wav','',149);
    defMus(10,'OST/Boss4.wav','',133);
    //Map/évènements
    defMus(11,'OST/Map.wav','',163);
    defMus(12,'OST/Event.wav','',49);
    //Fanfares de victoire
    defMus(13,'OST/C1_VictoireIntro.wav','',5);
    defMus(14,'OST/C2_VictoireIntro.wav','',5);
    defMus(15,'OST/C3_VictoireIntro.wav','',5);
    defMus(16,'OST/C4_VictoireIntro.wav','',3);
    defMus(17,'OST/C5_VictoireIntro.wav','',5);
    defMus(18,'OST/Boss1_VictoireIntro.wav','',5);
    defMus(19,'OST/Boss2_VictoireIntro.wav','',7);
    defMus(20,'OST/Boss3_VictoireIntro.wav','',5);
    defMus(21,'OST/Boss4_VictoireIntro.wav','',5);
    //Thèmes de victoire/map
    defMus(23,'OST/C1_VictoireRep.wav','',6);
    defMus(24,'OST/C2_VictoireRep.wav','',11);
    defMus(25,'OST/C3_VictoireRep.wav','',23);
    defMus(26,'OST/C4_VictoireRep.wav','',12);
    defMus(27,'OST/C5_VictoireRep.wav','',15);
    defMus(28,'OST/Boss1_VictoireRep.wav','',81);
    defMus(29,'OST/Boss2_VictoireRep.wav','',81);
    defMus(30,'OST/Boss3_VictoireRep.wav','',50);
    defMus(31,'OST/Boss4_VictoireRep.wav','',27);


end.

