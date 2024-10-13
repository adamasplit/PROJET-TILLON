program test;

uses SDL2,SDL2_mixer,SonoSys;

var musique:TMus;

begin


  Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 4096);

musique.musique:=Mix_LoadMUS('Project_TITLE.wav');
mix_playMusic(musique.musique,0);
while True do 
    begin
        SDL_PumpEvents();
        sdl_delay(20);
    end
end.