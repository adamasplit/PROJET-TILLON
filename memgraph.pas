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

  type
  TDialogueBox = record
    BackgroundImage: TImage;        // Image de fond
    LabelSurface: PSDL_Surface;     // Surface temporaire pour le texte
    LabelTexture: PSDL_Texture;     // Texture finale du texte
    Text: Pchar;                   // Texte complet
    DisplayedText: Pchar;          // Texte affiché lettre par lettre
    RemainingText: Pchar;          // Texte restant à afficher
    CurrentLetter: Integer;         // Position de la lettre actuelle
    LastUpdateTime: UInt32;         // Délai entre chaque lettre
    X, Y, Width, Height: Integer;   // Position et dimensions
    Complete: Boolean;              // Indicateur si tout le texte est affiché
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

procedure InitDialogueBox(var Box: TDialogueBox; ImgPath: pchar; X, Y, W, H: Integer; const DialogueText: pchar);
procedure UpdateDialogueBox(var Box: TDialogueBox);


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

procedure InitDialogueBox(var Box: TDialogueBox; ImgPath: pchar; X, Y, W, H: Integer; const DialogueText: pchar);
begin
  CreateRawImage(Box.BackgroundImage,X,Y,W,H,ImgPath);
  Box.X := X;
  Box.Y := Y;
  Box.Width := W;
  Box.Height := H;
  Box.Text := DialogueText;
  Box.RemainingText := DialogueText;
  Box.DisplayedText := StringToPChar(Box.RemainingText[0]);
  Box.CurrentLetter := 0;
  Box.LastUpdateTime := SDL_GetTicks();
  Box.Complete := False;
end;

procedure UpdateDialogueBox(var Box: TDialogueBox);
var
  TextRect: TSDL_Rect;
  CurrentTime: UInt32;
  LineText: string;
  RemainingChars: string;
  i, TextWidth: Integer;
  LineFinished: Boolean;
begin
  if Box.Complete then 
  begin
    // Si complet, on affiche l'image de fond et le texte complet
    RenderRawImage(Box.BackgroundImage, 255, False);
    SDL_RenderCopy(sdlRenderer, Box.LabelTexture, nil, @TextRect);
    Exit;
  end;

  // Affiche l'image de fond
  RenderRawImage(Box.BackgroundImage, 255, False);

  // Vérifie le temps pour afficher la prochaine lettre
  CurrentTime := SDL_GetTicks();
  if (CurrentTime - Box.LastUpdateTime > 100) then
  begin
    if Box.CurrentLetter < Length(Box.RemainingText) then
    begin
      // Ajoute la lettre suivante
      Box.DisplayedText := StringToPChar(Box.DisplayedText + Box.RemainingText[Box.CurrentLetter + 1]);
      Inc(Box.CurrentLetter);
      Box.LastUpdateTime := CurrentTime;
    end
    else
    begin
      // Texte complet, prêt pour le clic suivant
      Box.Complete := True;
    end;
  end;

  // Initialisation pour l'affichage ligne par ligne
  RemainingChars := Box.DisplayedText;
  i := 1;
  TextRect.x := Box.X + 10;   // Position de départ en X (10 pixels de marge)
  TextRect.y := Box.Y + 10;   // Position de départ en Y (10 pixels de marge)
  TextRect.w := Box.Width - 20;
  
  // Découpage et affichage du texte ligne par ligne
  while RemainingChars <> '' do
  begin
    LineText := '';
    LineFinished := False;
    TextWidth:=0;

    // Remplir une ligne jusqu'à ce qu'on atteigne la largeur limite
    while (RemainingChars <> '') and not LineFinished do
    begin
      LineText := LineText + RemainingChars[1];
      Delete(RemainingChars, 1, 1);
      
      // Calculer la largeur de la ligne courante
      //TTF_SizeText(Fantasy30, StringToPChar(LineText), TextWidth, TextWidth);
      
      if TextWidth >= TextRect.w then
        LineFinished := True;
    end;

    // Créer la surface et la texture pour la ligne courante
    Box.LabelSurface := TTF_RenderText_Blended(Fantasy30, StringToPChar(LineText), black_color);
    Box.LabelTexture := SDL_CreateTextureFromSurface(sdlRenderer, Box.LabelSurface);
    
    // Afficher la ligne
    SDL_RenderCopy(sdlRenderer, Box.LabelTexture, nil, @TextRect);
    
    // Libérer les ressources temporaires
    SDL_FreeSurface(Box.LabelSurface);
    SDL_DestroyTexture(Box.LabelTexture);

    // Passer à la ligne suivante
    TextRect.y := TextRect.y + TextRect.h + 5;  // 5 pixels d'espace entre les lignes
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
