unit SonSys;
interface
uses SDL2, SDL2_mixer; //télécharger SDL2_mixer au préalable

type utilite=(OST,SFX);

procedure jouerSon(nomFichier:String;ext:extension);//joue un son .WAV ou .OGG
procedure bouclerMusique(nomFichier:String); //joue une musique .OGG en boucle (connaissant la durée du fichier)

procedure arretMus(duree:Integer);//éteindre progressivement la musique, durée en ms
procedure arretSons(duree:Integer);//arrêter tous les sons


//autres procédures déjà présentes : mix_pause/resume, mix_pause/resumeMusic, pour arrêter/reprendre tous les sons ou la musique
//mix_rewindMusic pour recommencer une musique depuis le début

{IMPORTANT : à la fin du programme, utiliser 'Mix_CloseAudio' ainsi que 'Mix_FreeMusic' ou 'Mix_FreeChunk' pour des variables PMix_Music ou PMix_Chunk}
implementation

function chargerSFX(nomFichier:String):PMix_Chunk;
    begin
    chargerWAV := Mix_LoadWAV(nomFichier);
    if chargerWAV = nil then Exit;
    Mix_VolumeChunk(chargerWAV, MIX_MAX_VOLUME);
    end;

function chargerOST(nomFichier:String):PMix_Music;
    begin
    chargerOGG := Mix_LoadMUS(nomFichier);
    if chargerOGG = nil then Exit;
    Mix_VolumeMusic(MIX_MAX_VOLUME);
    end;

procedure jouerSon(nomFichier:String;ext:extension);
begin
    if ext=SFX then
        Mix_PlayChannel(-1,chargerSFX(nomFichier),0)
    else
        Mix_PlayMusic(chargerOST(nomFichier),0)
end;

procedure bouclerMusique(nomFichier:String,duree:Integer);
begin
    while True do begin
        Mix_PlayMusic(chargerOST(nomFichier),0);
        delay(duree*100);
        end
end;

var musique:
procedure arretMus(duree:Integer); 
    Mix_FadeOutMusic(duree);
procedure arretSons(duree:Integer);
    Mix_FadeOutChannel(1, duree);


end.

