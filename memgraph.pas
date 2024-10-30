Unit memgraph;

INTERFACE

uses
  SDL2,
  SDL2_ttf,
  SysUtils;

type
 ButtonProcedure = procedure();
 
{Un boutton peut etre inialisé avec CreateButton, puis modifié à tout moment du code.}
type
  TButton = record
    rect: TSDL_Rect;
    labelSurface: PSDL_Surface;
    labelTexture: PSDL_Texture;
    bgColor, textColor, outlineColor: TSDL_Color;
    OnClick: ButtonProcedure;
    estVisible : Boolean;
  end;
  
type
  TText = record
    rect: TSDL_Rect;
    textSurface: PSDL_Surface;
    textTexture: PSDL_Texture;
    textColor : TSDL_Color;
  end;
  
type
  TImage = record
    rect: TSDL_Rect;
    imgSurface: PSDL_Surface;
    imgTexture: PSDL_Texture;
    directory: PChar;
  end;
  
  type
  TIntImage = record
    rect: TSDL_Rect;
    imgSurface: PSDL_Surface;
    imgTexture: PSDL_Texture;
    OnClick: ButtonProcedure;
  end;
  
{Variables}
var
  dayDreamFontDirectory : PChar;
  dayDream40 : PTTF_Font;
  dayDream30 : PTTF_Font;
  dayDream20 : PTTF_Font;
  sdlWindow1 : PSDL_Window;
  sdlRenderer : PSDL_Renderer;
  windowWidth, windowHeight: Integer;
  
{Fonctions & Procedures}
procedure CreateButton(var button: TButton; x, y, w, h: Integer; labelText: PAnsiChar; bgColor, textColor: TSDL_Color; font:PTTF_font;onClick: ButtonProcedure); overload;

procedure RenderButton(var button: TButton);
procedure HandleButtonClick(var button: TButton; x, y: Integer);

procedure CreateText(var text : TText; x, y, w, h: Integer; labelText: PAnsiChar;font:PTTF_font; textColor: TSDL_Color);
procedure RenderText(var text: TText);

procedure DrawRect(bgColor : TSDL_Color; alpha,x,y,w,h :Integer);

procedure CreateRawImage(var image : TImage; x, y, w, h: Integer; directory : PAnsiChar); 

procedure RenderRawImage(var image: Timage;alpha:Integer; flip : Boolean); overload;
procedure RenderRawImage(var image: Timage; flip : Boolean); overload;

procedure CreateInteractableImage(var image : TIntImage; x, y, w, h: Integer; directory : PAnsiChar; onClick: ButtonProcedure);
procedure RenderIntImage(var image : TIntImage);
procedure HandleImageClick(var image: TIntImage; x, y: Integer);


procedure ClearScreen;

{Debug}
procedure OnButtonClickDebug;




IMPLEMENTATION

{ 
* CreateButton 				| Crée un bouton
* button --> TButton 		| L'objet Bouton à créer
* x,y --> Integer 			| Coordonnées du bouton
* w,h --> Integer 			| longueur/largeur du bouton
* labelText --> PAnsiChar 	| texte au milieu du bouton
* bgColor --> TSDL_Color 	| couleur du fond du bouton
* textColor --> TSDL_Color 	| couleur du texte
* onClick --> ButtonProcedure 	| procedure à lancer en cas de clic (ATTENTION A METTRE UN @ AVANT VOTRE PROCEDURE EN ENTREE)
}
procedure CreateButton(var button: TButton; x, y, w, h: Integer; labelText: PAnsiChar; bgColor, textColor: TSDL_Color; font:PTTF_font; onClick: ButtonProcedure); 
begin
  button.rect.x := x;
  button.rect.y := y;
  button.rect.w := w;
  button.rect.h := h;
  button.bgColor := bgColor;
  button.textColor := textColor;
  button.OnClick := onClick;
  button.estVisible := True;


  // Render texte --> surface
  button.labelSurface := TTF_RenderText_Blended(font, labelText, button.textColor);
  if button.labelSurface = nil then HALT;

  // Convertion surface --> texture
  button.labelTexture := SDL_CreateTextureFromSurface(sdlRenderer, button.labelSurface);
  if button.labelTexture = nil then HALT;
end;

procedure RenderButton(var button: TButton);
var textRect: TSDL_Rect;
begin
  // Remplir le fond du bouton à la couleur choisie
  SDL_SetRenderDrawColor(sdlRenderer, button.bgColor.r, button.bgColor.g, button.bgColor.b, 5);
  SDL_RenderFillRect(sdlRenderer, @button.rect);

  // Calculs de la position du texte en fonction de la taille du bouton (Texte Centré)
  textRect.w := button.labelSurface^.w;
  textRect.h := button.labelSurface^.h;
  textRect.x := button.rect.x + (button.rect.w - textRect.w) div 2;
  textRect.y := button.rect.y + (button.rect.h - textRect.h) div 2;

  // Render de la texture du texte dans le bouton
  SDL_RenderCopy(sdlRenderer, button.labelTexture, nil, @textRect);
end;

{Prend le boutton et les coordonées en entrée (de la souris) puis vérifie si le bouton et cliqué et lance la procedure associée}
procedure HandleButtonClick(var button: TButton; x, y: Integer);
begin
  if (x >= button.rect.x) and (x <= button.rect.x + button.rect.w) and
     (y >= button.rect.y) and (y <= button.rect.y + button.rect.h) then
  begin
    if Assigned(button.OnClick) then
		writeln('Starting Procedure');
		button.OnClick;
  end;
end;
{Com à faire}
procedure CreateText(var text : TText; x, y, w, h: Integer; labelText: PAnsiChar;font:PTTF_font; textColor: TSDL_Color);
begin
  text.rect.w := w;
  text.rect.h := h;
  text.rect.x := x;
  text.rect.y := y;
  text.textcolor := textcolor;
  
   // Rendering text --> surface
  text.textSurface := TTF_RenderText_Solid(font, labelText, textColor);
  if text.textSurface = nil then HALT;
  // Convertion surface --> texture
  text.textTexture := SDL_CreateTextureFromSurface(sdlRenderer, text.textSurface);
  if text.textTexture = nil then HALT;
end;

{RenderText}
procedure RenderText(var text: TText);
var textRect: TSDL_Rect;
begin

  // Calculs de la position du texte
  textRect.w := text.textSurface^.w;
  textRect.h := text.textSurface^.h;
  textRect.x := text.rect.x;
  textRect.y := text.rect.y;

  // Render de la texture du texte
  SDL_RenderCopy(sdlRenderer, text.textTexture, nil, @textRect);
end;

procedure DrawRect(bgColor: TSDL_Color; alpha, x, y, w, h: Integer);
var
  drect: TSDL_Rect;
  prevR, prevG, prevB, prevA: UInt8;  // Variables pour sauvegarder la couleur actuelle
begin
  // Sauvegarde de la couleur actuelle du renderer
  SDL_GetRenderDrawColor(sdlRenderer, @prevR, @prevG, @prevB, @prevA);

  // Définition des dimensions du rectangle
  drect.w := w;
  drect.h := h;
  drect.x := x;
  drect.y := y;

  // Changement de la couleur de rendu pour dessiner le rectangle
  SDL_SetRenderDrawColor(sdlRenderer, bgColor.r, bgColor.g, bgColor.b, alpha);
  SDL_RenderFillRect(sdlRenderer, @drect);

  // Restauration de la couleur de rendu précédente
  SDL_SetRenderDrawColor(sdlRenderer, prevR, prevG, prevB, prevA);
end;

{ 
* CreateRawImage 			| Crée une Image
* image --> TImage 			| L'objet Image à créer
* x,y --> Integer 			| Coordonnées de l'image
* w,h --> Integer 			| longueur/largeur de l'image
* directory --> String 		| chemin de l'image associée de format bmp (Exemple : imgtest.bmp)
* onClick --> ButtonProcedure 	| procedure à lancer en cas de clic (ATTENTION A METTRE UN @ AVANT VOTRE PROCEDURE EN ENTREE)
}
procedure CreateRawImage(var image : TImage; x, y, w, h: Integer; directory : PAnsiChar);
begin
  image.rect.w := w;
  image.rect.h := h;
  image.rect.x := x;
  image.rect.y := y;
  image.directory := directory;

   // Rendering text --> surface
  image.imgSurface := SDL_LoadBMP(image.directory);
  if image.imgSurface = nil then begin WriteLn('Error in Surface load : ',image.directory);Write(SDL_GetError); HALT end;
  // Convertion surface --> texture
  image.imgTexture := SDL_CreateTextureFromSurface(sdlRenderer, image.imgSurface);
  if image.imgTexture = nil then begin WriteLn(SDL_GetError); HALT end;
  
end;


procedure RenderRawImage(var image: Timage;alpha:Integer; flip : Boolean); overload;
var imgRect: TSDL_Rect;
begin
  // Sauvegarde de la couleur actuelle du renderer
  sdl_settexturealphamod(image.imgTexture,alpha);
  // Calculs de la position du texte
  imgRect.w := image.rect.w;
  imgRect.h := image.rect.h;
  imgRect.x := image.rect.x;
  imgRect.y := image.rect.y;

  // Render de la texture de l'image
  if (flip) then
    SDL_RenderCopyEx(sdlRenderer, image.imgTexture, nil, @imgRect,0, nil, SDL_FLIP_HORIZONTAL)
    else
    SDL_RenderCopy(sdlRenderer, image.imgTexture, nil, @imgRect);
end;

procedure RenderRawImage(var image: Timage; flip : Boolean); overload;
var imgRect: TSDL_Rect;
begin
  // Calculs de la position du texte
  imgRect.w := image.rect.w;
  imgRect.h := image.rect.h;
  imgRect.x := image.rect.x;
  imgRect.y := image.rect.y;

  // Render de la texture de l'image
  if (flip) then
    SDL_RenderCopyEx(sdlRenderer, image.imgTexture, nil, @imgRect,0, nil, SDL_FLIP_HORIZONTAL)
    else
    SDL_RenderCopy(sdlRenderer, image.imgTexture, nil, @imgRect);
end;


{ 
* CreateInteractableImage 	| Crée une Image avec interaction
* image --> TIntImage 		| L'objet Image à créer
* x,y --> Integer 			| Coordonnées de l'image
* w,h --> Integer 			| longueur/largeur de l'image
* directory --> String 		| chemin de l'image associée de format bmp (Exemple : imgtest.bmp)
* onClick --> ButtonProcedure 	| procedure à lancer en cas de clic (ATTENTION A METTRE UN @ AVANT VOTRE PROCEDURE EN ENTREE)
}
procedure CreateInteractableImage(var image : TIntImage; x, y, w, h: Integer; directory : PAnsiChar; onClick: ButtonProcedure);
begin
  image.rect.x := x;
  image.rect.y := y;
  image.rect.w := w;
  image.rect.h := h;
  image.OnClick := onClick;

	// Rendering text --> surface
  image.imgSurface := SDL_LoadBMP(directory);
  if image.imgSurface = nil then HALT;
  // Convertion surface --> texture
  image.imgTexture := SDL_CreateTextureFromSurface(sdlRenderer, image.imgSurface);
  if image.imgTexture = nil then HALT;
end;

procedure RenderIntImage(var image : TIntImage);
var imgRect: TSDL_Rect;
begin
	  // Calculs de la position du texte
  imgRect.w := image.rect.w;
  imgRect.h := image.rect.h;
  imgRect.x := image.rect.x;
  imgRect.y := image.rect.y;

  // Render de la texture de l'image
  SDL_RenderCopy(sdlRenderer, image.imgTexture, nil, @imgRect);
end;

procedure HandleImageClick(var image: TIntImage; x, y: Integer);
begin
  if (x >= image.rect.x) and (x <= image.rect.x + image.rect.w) and
     (y >= image.rect.y) and (y <= image.rect.y + image.rect.h) then
  begin
    if Assigned(image.OnClick) then
		writeln('Starting Procedure');
		image.OnClick;
  end;
end;


procedure ClearScreen;
begin
	SDL_RenderClear(sdlRenderer);
	SDL_RenderPresent(sdlRenderer);
end;


{Debug}
procedure OnButtonClickDebug;
begin
  WriteLn('Button Clicked!');
end;

{Initialisation de la Fenêtre dans le programme principal}
BEGIN
  dayDreamFontDirectory := 'Fonts\Font_Fantasy_M_Edit.ttf';

  // Initialization of video subsystem
  if SDL_Init(SDL_INIT_VIDEO) < 0 then HALT;

  // Creation de la Fenetre
  sdlWindow1 := SDL_CreateWindow('Les Cartes du Destin 🃑', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1080, 720, SDL_WINDOW_SHOWN);
  if sdlWindow1 = nil then HALT;

  // Creation du Renderer
  sdlRenderer := SDL_CreateRenderer(sdlWindow1, -1, SDL_RENDERER_ACCELERATED);
  if sdlRenderer = nil then HALT;

  // Initialisation de la police [DayDream] et chargement de la police
  if TTF_Init = -1 then HALT;
  dayDream40 := TTF_OpenFont(dayDreamFontDirectory, 40);
  if dayDream40 = nil then HALT;
  dayDream30 := TTF_OpenFont(dayDreamFontDirectory, 30);
  if dayDream30 = nil then HALT;
  dayDream20 := TTF_OpenFont(dayDreamFontDirectory, 20);
  if dayDream20 = nil then HALT;

  // activation de l'opacité
  SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
  
  TTF_SetFontStyle(dayDream40, TTF_STYLE_NORMAL);
  TTF_SetFontOutline(dayDream40, 1);
  TTF_SetFontHinting(dayDream40, TTF_HINTING_NORMAL);
  writeln('memgraph DONE.');
END.
