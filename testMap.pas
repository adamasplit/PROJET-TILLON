program testMap;

uses
  SDL2,
  SDL2_mixer,
  coeur,
  eventsys,
  MapSys,
  memgraph,
  SysUtils,
  sonoSys,
  combatLib;
  var lastUpdateTime1,LastUpdateTime2:UInt32;
  musique:TMus;
var s:TSalle;
function isuiv(i:Integer):Integer;
  begin
    if i>2 then  
      isuiv:=1
    else isuiv:=i+1;
  end;

function iprec(i:Integer):Integer;
  begin
    if i<2 then  
      iprec:=3
    else iprec:=i-1;
  end;
  var j: integer;
procedure annihiler(); //METTRE A JOUR APRES CHAQUE AJOUT D'OBJET
begin
  // Nettoyage de Ram (DETRUIRE IMPERATIVEMENT TOUTES LES TEXTURES UTILISEES SOUS PEINE DE FUITE DE RAM !!!!)
  
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  // Shutting down video subsystem (A laisser imperativement)
  SDL_Quit;
end;

begin
SDL_RenderClear(sdlRenderer);

lastUpdateTime1:=SDL_GetTicks();
LastUpdateTime2:=SDL_GetTicks();
Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 4096);
IndiceMusiqueJouee:=4;
//mix_playMusic(OST[IndiceMusiqueJouee].musique,0);


choixSalle(1,s);
detruireOST;
annihiler();
end.