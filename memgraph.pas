Unit memgraph;

INTERFACE

uses
  math,
  SDL2,
  SDL2_ttf,
  sonoSys,
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
    Lines: array[1..7] of string;  
    RemainingText: string;       
    DisplayedLetters,w: Integer;   
    CurrentLine: Integer;      
    LastUpdateTime: UInt32;       
    LetterDelay: UInt32;            // Délai entre l'affichage de chaque lettre C UN PUTAIN DE UINT32 MA GUEULE
    portrait:TImage;
    font:PTTF_Font;
    fontsize:Integer;
    Complete,Complete2: Boolean;              
  end;
  
{Variables}
var
  FantasyFontDirectory : PChar;
  Fantasy40 : PTTF_Font;
  Fantasy30 : PTTF_Font;
  Fantasy20 : PTTF_Font;
  black_color: TSDL_Color;
  sdlWindow1 : PSDL_Window;
  sdlRenderer : PSDL_Renderer;
const
  windowWidth = 1080;
  windowHeight = 720;
  
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

procedure InitDialogueBox(var Box: TDialogueBox; ImgPath,portraitPath: PChar; X, Y, W, H: Integer; const DialogueText: string; Delay: UInt32);overload;
procedure InitDialogueBox(var Box: TDialogueBox; ImgPath,portraitPath: PChar; X, Y, W, H: Integer; const DialogueText: string; Delay: UInt32;font:PTTF_Font;fontsize:Integer);overload;
procedure UpdateDialogueBox(var Box: TDialogueBox);
procedure RenderDialogueText(var Box: TDialogueBox);

function boiteFinie(box:TDialogueBox):Boolean;



procedure ClearScreen;
function StringToPChar(s : string) : Pchar;
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
  text.textSurface := TTF_RenderUTF8_Solid(font, labelText, textColor);
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
  if directory = nil then Exit;
   // Rendering text --> surface
  //if image.imgtexture<>nil then SDL_DestroyTexture(image.imgtexture);
  //if image.imgsurface<>nil then SDL_freeSurface(image.imgsurface);
  image.imgSurface := SDL_LoadBMP(image.directory);
  if image.imgSurface = nil then begin WriteLn('Error in Surface load : ',image.directory);Write(SDL_GetError); HALT end;
  // Convertion surface --> texture
  
  image.imgTexture := SDL_CreateTextureFromSurface(sdlRenderer, image.imgSurface);
  if image.imgTexture = nil then begin WriteLn(SDL_GetError); HALT end;
  
  
end;

function boiteFinie(box:TDialogueBox):Boolean;
begin
  boiteFinie:=(box.RemainingText='');
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

function NextWordLength(text:String;i:Integer):Integer;
begin
  nextWordLength:=0;
  repeat
    nextWordLength:=nextWordLength+1;
  until (text[i+nextWordLength]=' ') or (text[i+nextWordLength]='!') or (text[i+nextWordLength]='.') or (text[i+nextWordLength]='?');
end;

function WidthBasedLineLength(Font: PTTF_Font;size:Integer; const Text: string;width:Integer): Integer;
var
  LineWidth,maxLength, i: Integer;
  TempText: string;
begin
  TempText := '';
  LineWidth:= 0;
  maxLength:=(width*30) div (size*20);
  for i := 1 to Length(Text) do
  begin
    LineWidth:= Length(TempText);
    TempText := TempText + Text[i];
    if (text[i]=' ') and (LineWidth+NextWordLength(text,i) >= maxLength) then
      begin
      Exit(i - 1);
      end;
  end;
  WidthBasedLineLength := Length(Text);
end;
function ExtractNextLine(var Text: string;width:Integer;font:PTTF_Font;size:Integer): string;
var
  LineEnd: Integer;
begin
  LineEnd := Min(WidthBasedLineLength(font,size, Text,width), Length(Text));
  ExtractNextLine := Copy(Text, 1, LineEnd);
  Delete(Text, 1, LineEnd);
end;

procedure FillDialogueLines(var Box: TDialogueBox);
var
  i: Integer;
begin
  for i := 1 to 7 do
  begin
    if Box.RemainingText = '' then
      Box.Lines[i] := ''
    else
      Box.Lines[i] := ExtractNextLine(Box.RemainingText,box.w,box.font,box.fontsize);
  end;
end;



procedure InitDialogueBox(var Box: TDialogueBox; ImgPath,portraitPath: PChar; X, Y, W, H: Integer; const DialogueText: string; Delay: UInt32);
begin
  sdl_destroytexture(box.BackgroundImage.imgtexture);
  sdl_destroytexture(box.portrait.imgtexture);
  CreateRawImage(Box.BackgroundImage, X, Y, W, H, ImgPath);
    if portraitPath='Sprites/Portraits/portraitB.bmp' then
      CreateRawImage(Box.portrait, X, Y, W div 4, W div 4, portraitPath)
    else
      CreateRawImage(Box.portrait, X+(W div 20), Y+(H div 6), H div 2+ (H div 10), H div 2+(H div 10), portraitPath);
  box.w:=W;
  Box.RemainingText := DialogueText;
  Box.DisplayedLetters := 0;
  Box.CurrentLine := 1;
  Box.Font:=Fantasy30;
  Box.FontSize:=30;
  Box.LastUpdateTime := SDL_GetTicks();
  Box.LetterDelay := Delay;
  Box.Complete := False;

  // Charger les premières lignes
  FillDialogueLines(Box);
end;

procedure InitDialogueBox(var Box: TDialogueBox; ImgPath,portraitPath: PChar; X, Y, W, H: Integer; const DialogueText: string; Delay: UInt32;font:PTTF_Font;fontsize:Integer);
begin
  sdl_destroytexture(box.BackgroundImage.imgtexture);
  sdl_destroytexture(box.portrait.imgtexture);
  
  if ImgPath <> nil then CreateRawImage(Box.BackgroundImage, X, Y, W, H, ImgPath) else begin Box.BackgroundImage.rect.x := X; Box.BackgroundImage.rect.y := Y end;
  if portraitPath <> nil then 
    begin
    if portraitPath='Sprites/Portraits/portraitB.bmp' then
      CreateRawImage(Box.portrait, X, Y, W div 4, W div 4, portraitPath)
    else
      CreateRawImage(Box.portrait, X, Y, W div 4-(W div 5), W div 4-(W div 5), portraitPath);
    end;
  
  
  box.w:=W;
  Box.RemainingText := DialogueText;
  
  Box.DisplayedLetters := 0;
  Box.CurrentLine := 1;
  Box.LastUpdateTime := SDL_GetTicks();
  Box.LetterDelay := Delay;
  Box.Font:=Font;
  box.fontsize:=fontsize;
  Box.Complete := False;

  // Charger les premières lignes
  FillDialogueLines(Box);
end;





procedure UpdateDialogueBox(var Box: TDialogueBox); // C'est la la scene de crime
var
  CurrentTime: UInt32;
  TimeDiff: UInt32;
  test,done:Boolean;
begin
  CurrentTime := SDL_GetTicks();
  
  if Box.Complete then RenderDialogueText(box);
  if Box.BackgroundImage.imgTexture <> nil then RenderRawImage(Box.BackgroundImage, 255, False);
  if Box.portrait.imgTexture <> nil then RenderRawImage(Box.portrait, 255, False);

  TimeDiff := CurrentTime - Box.LastUpdateTime;
  test:=timediff>=box.letterdelay;
  done:=False;
  while ((box.letterDelay=0) and not box.complete) or (not done) do
  begin
    done:=True;
    if (Box.DisplayedLetters <= Length(Box.Lines[Box.CurrentLine])) then
    begin
      if test=false then
        begin
        done:=True;
        end
      else
      begin
        Inc(Box.DisplayedLetters);
        if box.portrait.directory=nil then
          begin
          //jouerSon('SFX/Dialogues/texte.wav')
          end
        else
          jouerSon(StringToPChar('SFX/Dialogues/'+box.portrait.directory+'.wav'));
        Box.LastUpdateTime := CurrentTime;
        done:=True;
      end;
    end;
    if box.displayedLetters<>0 then RenderDialogueText(Box);
  end;

end;

procedure RenderTextLine(const Text: string; x, y,offsetX,offsetY: Integer;Font:PTTF_Font);
var
  Surface: PSDL_Surface;
  Texture: PSDL_Texture;
  Rect: TSDL_Rect;
begin
  Surface := TTF_RenderUTF8_Blended(font, StringToPChar(Text), black_color);
  Texture := SDL_CreateTextureFromSurface(sdlRenderer, Surface);
  Rect.x :=x+offsetX;
  Rect.y := y+offsetY;
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

    if box.portrait.imgTexture<>nil then
      RenderTextLine(DisplayedText, Box.BackgroundImage.rect.x, Box.BackgroundImage.rect.y + (i - 1) * 40,250,60,box.font)
    else
      RenderTextLine(DisplayedText, Box.BackgroundImage.rect.x, Box.BackgroundImage.rect.y + (i - 1) * 40,100,60,box.font);
  end;
  if ((Box.Lines[Box.CurrentLine+1] <> '') and (Box.DisplayedLetters >= Length(Box.Lines[Box.CurrentLine])) and (Box.CurrentLine <= 7)) then
  begin
    Inc(Box.CurrentLine);
    Box.DisplayedLetters := 0;
  end;
  if (box.lines[box.currentLine+1]='') and (box.displayedletters>=length(box.lines[box.currentline])) then
    box.complete:=True
  else if box.letterdelay=0 then inc(box.displayedLetters);
  if ((Box.CurrentLine = 7) and (Box.DisplayedLetters = Length(Box.Lines[7]))) then
  begin
    box.displayedLetters:=length(box.lines[box.currentLine]);
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
  Fantasy20 := TTF_OpenFont(FantasyFontDirectory, 25);
  if Fantasy20 = nil then HALT;

  // activation de l'opacité
  SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
  TTF_SetFontStyle(Fantasy40, TTF_STYLE_NORMAL);
  TTF_SetFontOutline(Fantasy40, 1);
  TTF_SetFontHinting(Fantasy40, TTF_HINTING_NORMAL);
END.
