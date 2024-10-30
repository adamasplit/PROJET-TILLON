program Chapter5_SDL2;

uses SDL2,memgraph,sysutils,SDL2_ttf;

var
  i: Integer;
  aaaaa:TImage;
  surf:PSDL_Surface;
  tex:PSDL_Texture;
  sdlWindow1: PSDL_Window;
  sdlRect1: TSDL_Rect;
  sdlPoints: array[0..499] of TSDL_Point;

begin

  //render and show cleared window with background color
  SDL_SetRenderDrawColor(sdlRenderer, 0, 255, 255, 255);
  SDL_RenderClear(sdlRenderer);
  SDL_RenderPresent(sdlRenderer);
  SDL_Delay(1000);

  //prepare, render and draw a rectangle
  sdlRect1.x := 260;
  sdlRect1.y := 10;
  sdlRect1.w := 230;
  sdlRect1.h := 230;
  SDL_SetRenderDrawColor(sdlRenderer, 0, 255, 0, 255);
  SDL_RenderDrawRect(sdlRenderer, @sdlRect1);

  //relocate, render and draw the rectangle
  sdlRect1.x := 10;
  sdlRect1.y := 260;
  SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
  SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 255, 10);
  Surf := SDL_LoadBMP('Sprites/Menu/CombatUI_1.bmp');

  // Convertion surface --> texture
  Tex := SDL_CreateTextureFromSurface(sdlRenderer,Surf);
  SDL_RenderFillRect(sdlRenderer, @sdlRect1);
  SDL_RenderCopy(sdlRenderer, Tex, nil, @sdlRect1);
  SDL_RenderPresent(sdlRenderer);
  SDL_Delay(1000);

  //prepare, render and draw 500 points with random x and y values
  Randomize;
  for i := 0 to 499 do
  begin
    sdlPoints[i].x := Random(500);
    sdlPoints[i].y := Random(500);
  end;
  SDL_SetRenderDrawColor(sdlRenderer, 128, 128, 128, 255);
  SDL_RenderDrawPoints(sdlRenderer, sdlPoints, 500);
  SDL_RenderPresent(sdlRenderer);
  SDL_Delay(3000);

  //clean memory
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow (sdlWindow1);

  //shut down SDL2
  SDL_Quit;
end.