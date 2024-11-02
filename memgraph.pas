Unit memgraph;

INTERFACE

uses
  SDL2,
  SDL2_ttf,
  math,
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

type
  TDialogueBox = record
    BackgroundImage: TImage; 
    Lines: array[1..6] of string;  
    RemainingText: string;       
    DisplayedLetters: Integer;   
    CurrentLine: Integer;      
    LastUpdateTime: UInt32;       
    LetterDelay: UInt32;            // Délai entre l'affichage de chaque lettre C UN PUTAIN DE UINT32 MA GUEULE
    Complete: Boolean;              
  end;
  
{Variables}
var
  FantasyFontDirectory : PChar;
  Fantasy40 : PTTF_Font;
  Fantasy30 : PTTF_Font;
  dayDream20 : PTTF_Font;
  black_color: TSDL_Color;
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

procedure InitDialogueBox(var Box: TDialogueBox; ImgPath: PChar; X, Y, W, H: Integer; const DialogueText: string; Delay: UInt32);
procedure UpdateDialogueBox(var Box: TDialogueBox);
procedure RenderDialogueText(var Box: TDialogueBox);


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

function StringToPChar(s : string) : Pchar;
begin
StringToPChar := StrAlloc(Length(s)+1);
StrPCopy(StringToPChar, s);
end;

function WidthBasedLineLength(Font: PTTF_Font; const Text: string): Integer;
var
  LineWidth, i: Integer;
  TempText: string;
begin
  TempText := '';
  LineWidth:= 0;
  for i := 1 to Length(Text) do
  begin
    LineWidth:= Length(TempText);
    TempText := TempText + Text[i];
    if LineWidth >= 20 then
      Exit(i - 1);
  end;
  WidthBasedLineLength := Length(Text);
end;
function ExtractNextLine(var Text: string): string;
var
  LineEnd: Integer;
begin
  LineEnd := Min(WidthBasedLineLength(Fantasy30, Text), Length(Text));
  ExtractNextLine := Copy(Text, 1, LineEnd);
  Delete(Text, 1, LineEnd);
end;

procedure FillDialogueLines(var Box: TDialogueBox);
var
  i: Integer;
begin
  for i := 1 to 6 do
  begin
    if Box.RemainingText = '' then
      Box.Lines[i] := ''
    else
      Box.Lines[i] := ExtractNextLine(Box.RemainingText);
  end;
end;



procedure InitDialogueBox(var Box: TDialogueBox; ImgPath: PChar; X, Y, W, H: Integer; const DialogueText: string; Delay: UInt32);
begin
  CreateRawImage(Box.BackgroundImage, X, Y, W, H, ImgPath);
  Box.RemainingText := DialogueText;
  Box.DisplayedLetters := 0;
  Box.CurrentLine := 1;
  Box.LastUpdateTime := SDL_GetTicks();
  Box.LetterDelay := Delay;
  Box.Complete := False;

  // Charger les premières lignes
  FillDialogueLines(Box);
  writeln('INIT OK');
end;





procedure UpdateDialogueBox(var Box: TDialogueBox); // C'est la la scene de crime
var
  CurrentTime: UInt32;
  TimeDiff: UInt32;
begin
  CurrentTime := SDL_GetTicks();

  if Box.Complete then Exit;

  RenderRawImage(Box.BackgroundImage, 255, False);

  TimeDiff := CurrentTime - Box.LastUpdateTime;
  WriteLn('CurrentLine: ', Box.CurrentLine);
  WriteLn('DisplayedLetters: ', Box.DisplayedLetters);
  WriteLn('Lines[CurrentLine]: ', Box.Lines[Box.CurrentLine]);
  WriteLn('LetterDelay: ', Box.LetterDelay);
  WriteLn('LastUpdateTime: ', Box.LastUpdateTime);
  WriteLn('TimeDiff: ', TimeDiff);


if (TimeDiff > Box.LetterDelay) and (Box.DisplayedLetters < Length(Box.Lines[Box.CurrentLine])) then
  begin
    writeln('2');
    Inc(Box.DisplayedLetters);
    Box.LastUpdateTime := CurrentTime;
  end;

  RenderDialogueText(Box);
end;

procedure RenderTextLine(const Text: string; x, y: Integer);
var
  Surface: PSDL_Surface;
  Texture: PSDL_Texture;
  Rect: TSDL_Rect;
begin
  Surface := TTF_RenderText_Blended(Fantasy30, StringToPChar(Text), black_color);
  Texture := SDL_CreateTextureFromSurface(sdlRenderer, Surface);
  Rect.x := x;
  Rect.y := y;
  Rect.w := Surface^.w;
  Rect.h := Surface^.h;
  SDL_RenderCopy(sdlRenderer, Texture, nil, @Rect);
  SDL_FreeSurface(Surface);
  SDL_DestroyTexture(Texture);
end;

procedure RenderDialogueText(var Box: TDialogueBox);
var
  i: Integer;
  DisplayedText: string;
begin
  for i := 1 to Box.CurrentLine do
  begin
    if i = Box.CurrentLine then
      DisplayedText := Copy(Box.Lines[i], 1, Box.DisplayedLetters)
    else
      DisplayedText := Box.Lines[i];

    RenderTextLine(DisplayedText, Box.BackgroundImage.rect.x, Box.BackgroundImage.rect.y + (i - 1) * 40);
  end;

  if (Box.DisplayedLetters = Length(Box.Lines[Box.CurrentLine])) and (Box.CurrentLine < 6) then
  begin
    writeln('1');
    Inc(Box.CurrentLine);
    Box.DisplayedLetters := 0;
  end
  else if (Box.CurrentLine = 6) and (Box.DisplayedLetters = Length(Box.Lines[6])) then
  begin
    Box.Complete := True;
  end;
end;





{Debug}
procedure OnButtonClickDebug;
begin
  WriteLn('Button Clicked!');
end;

{Initialisation de la Fenêtre dans le programme principal}
BEGIN
  black_color.r := 0; black_color.g := 0; black_color.b := 0;
  FantasyFontDirectory := 'Fonts\Font_Fantasy_M_Edit.ttf';

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
  Fantasy40 := TTF_OpenFont(FantasyFontDirectory, 40);
  if Fantasy40 = nil then HALT;
  Fantasy30 := TTF_OpenFont(FantasyFontDirectory, 30);
  if Fantasy30 = nil then HALT;
  dayDream20 := TTF_OpenFont(FantasyFontDirectory, 20);
  if dayDream20 = nil then HALT;

  // activation de l'opacité
  SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
  
  TTF_SetFontStyle(Fantasy40, TTF_STYLE_NORMAL);
  TTF_SetFontOutline(Fantasy40, 1);
  TTF_SetFontHinting(Fantasy40, TTF_HINTING_NORMAL);
  writeln('memgraph DONE.');
END.
