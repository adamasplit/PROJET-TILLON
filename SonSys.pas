unit SonSys;
interface
uses SDL2, SDL2_mixer,SysUtils; //télécharger SDL2_mixer au préalable

procedure jouerSon(nomFichier:PChar);//joue un son .WAV ou .OGG
procedure bouclerMusique(nomFichier:PCHar;duree:Integer); //joue une musique .OGG en boucle (connaissant la durée du fichier)

procedure arretMus(duree:Integer);//éteindre progressivement la musique, durée en ms
procedure arretSons(duree:Integer);//arrêter tous les sons


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

procedure jouerSon(nomFichier:PCHar);
begin
    Mix_PlayChannel(-1,chargerSFX(nomFichier),0)
end;

procedure bouclerMusique(nomFichier:PChar;duree:Integer);
var
currentTime: UInt32;
LastUpdateTime : UInt32;
begin
    while True do begin
        Mix_PlayMusic(chargerOST(nomFichier),0);
        currentTime := SDL_GetTicks();
        LastUpdateTime := currentTime;
        repeat

        until (CurrentTime=LastUpdateTime+duree*1000);
        end
end;

procedure arretMus(duree:Integer);
begin
    Mix_FadeOutMusic(duree);
end;
procedure arretSons(duree:Integer);
begin
    Mix_FadeOutChannel(1, duree);
end;


end.

