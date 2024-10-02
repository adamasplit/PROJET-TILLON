unit SonSys;
interface
uses SDL2, SDL2_mixer,SysUtils,crt; //télécharger SDL2_mixer au préalable

const TAILLE_OST=11;

type TMus=record
    musique:PMix_Music;
    duree:Integer;
    nom:String;
    dir:PChar;
end;

var OST:array[1..TAILLE_OST] of TMus;
    IndiceMusiqueJouee:Integer;

procedure jouerSon(nomFichier:PChar);//joue un son .WAV
procedure jouerMus(i:Integer);//joue une musique .OGG ou .WAV
procedure bouclerMusique(musique:TMus;var lastUpdateTime:UInt32); //recommence une musique si elle est finie (à mettre dans la boucle d'actualisation du jeu)

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
    Mix_VolumeChunk(chargerSFX, MIX_MAX_VOLUME);
    end;

function chargerOST(nomFichier:PChar):PMix_Music;
    begin
    chargerOST := Mix_LoadMUS(nomFichier);
    if chargerOST = nil then Exit;
    Mix_VolumeMusic(MIX_MAX_VOLUME);
    end;

procedure defMus(indice:Integer;dir:Pchar;nom:String;duree:Integer);

begin
    OST[indice].musique:=Mix_LoadMUS(dir);
    writeln('OST[',indice,'].musique:=MIX_LoadMUS(',dir,')');
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

procedure bouclerMusique(musique:TMus;var lastUpdateTime:UInt32);
begin
    SDL_PumpEvents;
        if (SDL_GetTicks()-LastUpdateTime)>(musique.duree)*1000 then //vérifier si le morceau est fini ou non
        begin
            mix_rewindMusic();
            LastUpdateTime := SDL_GetTicks();
        end;
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
writeln('SonSys');
    defMus(1,'Combat.ogg','Cards of Fortune',50);
end.

