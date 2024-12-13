unit AnimationSys;

interface

uses
  coeur,
  math,
  memgraph,
  SDL2,
  SonoSys,
  SysUtils;

const
  FRAME_DURATION = 90;  // Durée en ms pour 30 FPS

var
  DamagePopUps: array of TText;

var
  fonduActif: Boolean;
  fonduEntrant: Boolean;
  dureeFondu: Integer;  // Durée en millisecondes
  timeDebutFondu : Uint32;

// Initialiser l'animation pour un objet
procedure InitAnimation(var anim: TAnimation; objectName, etat: PChar; totalFrames: Integer; isLooping: Boolean);

// Mettre à jour l'animation (changer la frame si nécessaire)
procedure UpdateAnimation(var anim: TAnimation; var image: TImage);

function GetFramePath(anim: TAnimation): PChar;
function AnimFinie(anim:TAnimation):Boolean;

// Initialiser un ButtonGroup avec des animations de fond et effets sonores
procedure InitButtonGroup(var btnGroup: TButtonGroup;  x, y, w, h: Integer; imgPath: PChar;labelText: PAnsiChar;onClick: ButtonProcedure);
procedure RenderButtonGroup(var btnGroup: TButtonGroup);

// Gestion des événements OnHover et OnClick
procedure OnMouseHover(var btnGroup: TButtonGroup; x,y : Integer);overload;
procedure OnMouseHover(var btnGroup: TButtonGroup; x, y: Integer; soundDir : Pchar;var isHovered :Boolean);overload;
procedure OnMouseClick(var btnGroup: TButtonGroup; x, y: Integer);

//Gestion due fondu
procedure DeclencherFondu(isFonduEntrant: Boolean; duree: Integer);
procedure EffetDeFondu;


procedure CreateDamagePopUp(x, y: Integer; damage: PChar; couleur: TSDL_Color);
procedure UpdateDamagePopUps;

implementation

// Fonction pour créer un chemin complet vers la frame de l'animation
function GetFramePath(anim: TAnimation): PChar;
var
  framePath: PChar;
begin
  framePath := PChar(Format('Sprites/Game/%s/%s_%s_%d.bmp', [anim.ObjectName, anim.ObjectName, anim.Etat, anim.CurrentFrame]));
  GetFramePath := framePath;
end;

// Initialiser l'animation
procedure InitAnimation(var anim: TAnimation; objectName, etat: PChar; totalFrames: Integer; isLooping: Boolean);
begin
  anim.ObjectName := objectName;
  anim.Etat := etat;
  anim.TotalFrames := totalFrames;
  anim.CurrentFrame := 1;  // Commence à la première frame
  anim.IsLooping := isLooping;
  anim.isFliped := False;
  anim.LastUpdateTime := SDL_GetTicks();  // Initialiser avec le temps courant
end;

// Mettre à jour l'animation (changer la frame si nécessaire)
procedure UpdateAnimation(var anim: TAnimation; var image: TImage);
var
  currentTime: UInt32;
begin
  if ((anim.etat<>'') and (anim.currentFrame<>0) and (anim.objectName<>'')) and not ((anim.currentFrame=anim.totalFrames) and (not anim.isLooping)) then
  begin
    currentTime := SDL_GetTicks();

    // Vérifier si le temps écoulé est suffisant pour passer à la prochaine frame
    if (currentTime - anim.LastUpdateTime >= FRAME_DURATION) then
    begin
      // Passer à la prochaine frame
      anim.CurrentFrame := anim.CurrentFrame + 1;

      // Si on dépasse le nombre de frames, revenir à la première si boucle
      if (anim.CurrentFrame > anim.TotalFrames) then
      begin
        if anim.IsLooping then
          anim.CurrentFrame := 1  // Reboucler
        else
          anim.CurrentFrame := anim.TotalFrames;  // Garder la dernière frame si non bouclant
      end;

      // Mettre à jour le répertoire de l'image pour charger la nouvelle frame
      {if (image.directory<>getframePath(anim)) then 
      begin
        if (image.directory<>nil) then
          begin
          writeln(image.directory);
          
          end;
        writeln('fini');
        image.directory:=getframePath(anim);
        writeln('image rechargée');
      end;}
      if (anim.etat<>'apparition') and (anim.etat<>'mort') then
        begin
        SDL_DestroyTexture(image.imgtexture);
        sdl_freeSurface(image.imgSurface);
        end; 
      image.directory:=getframePath(anim);
      CreateRawImage(image, image.rect.x, image.rect.y, image.rect.w, image.rect.h, image.directory);
      
      
      
      // Mettre à jour l'image avec la nouvelle frame
      {WriteLn('Animation : Changing directory to : ',image.directory);
      WriteLn(anim.isLooping);}
      

      // Mettre à jour le temps de la dernière mise à jour
      anim.LastUpdateTime := currentTime;
    end;
  end;
end;

function animFinie(anim:TAnimation):Boolean;
begin
  animFinie:=(anim.currentFrame=anim.totalFrames) and (sdl_getticks-anim.lastUpdateTime>60)
end;

procedure InitButtonGroup(var btnGroup: TButtonGroup;  x, y, w, h: Integer; imgPath: PChar;labelText: PAnsiChar;onClick: ButtonProcedure);
begin
  // Initialiser le bouton avec l'image de fond
  CreateButton(btnGroup.button,x,y,w,h,labelText,b_color,black_color,Fantasy30,onClick);  // Créer le bouton

  // Charger l'image de fond
  CreateRawImage(btnGroup.image,x,y,w,h,imgPath);  // Créer l'image de fond
  btnGroup.hoverSoundPlayed := False;         // Initialiser le survol comme non effectué
  btnGroup.originalHeight := btnGroup.image.rect.h;
  btnGroup.originalWidth := btnGroup.image.rect.w;
  SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 150);  
end;

// Procédure pour déclencher un effet de fondu
procedure DeclencherFondu(isFonduEntrant: Boolean; duree: Integer);
begin
  fonduActif := True;
  fonduEntrant := isFonduEntrant;
  dureeFondu := duree;
  TimeDebutFondu := SDL_GetTicks();  // Initialise l'heure de début du fondu
end;

// Procédure de l'effet de fondu sans boucle (à appeler dans AfficherTout)
procedure EffetDeFondu;
var
  tempsEcoule: UInt32;
  progression: Real;
  alpha: Integer;
begin

  if (not fonduActif) and (not modeDebug) and (fonduEntrant) then 
    begin 
    SDL_RenderFillRect(sdlRenderer, nil);
    exit;
  end;

  // Calcul du temps écoulé depuis le début du fondu
  tempsEcoule := SDL_GetTicks() - TimeDebutFondu;

  // Vérification si la durée du fondu est écoulée
  if tempsEcoule >= dureeFondu then
  begin
    fonduActif := False;
    if fonduEntrant then
      alpha := 255   // Fin du fondu entrant, opacité maximale
    else
      alpha := 0;    // Fin du fondu sortant, opacité nulle
    SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, alpha);
    if fonduEntrant then SDL_RenderFillRect(sdlRenderer, nil);
  end
  else
  begin
    // Calcul de l'interpolation naturelle (ease-in-out) pour une transition fluide
    progression := tempsEcoule / dureeFondu;
    if fonduEntrant then
      alpha := Round(255 * (1 - (cos(progression * PI) * 0.5 + 0.5)))  // Interpolation pour le fondu entrant (avec geogebra sa mère)
    else
      alpha := Round(255 * (cos(progression * PI) * 0.5 + 0.5));       // Interpolation pour le fondu sortant
    SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, alpha);
    if fonduEntrant then SDL_RenderFillRect(sdlRenderer, nil);
  end;
end;


procedure RenderButtonGroup(var btnGroup: TButtonGroup);
begin
RenderRawImage(btnGroup.image, False);
RenderButton(btnGroup.button);
end;

procedure OnMouseHover(var btnGroup: TButtonGroup; x, y: Integer);overload;
begin
  // Vérifier si la souris est sur le bouton
  if (x >= btnGroup.image.rect.x) and (x <= btnGroup.image.rect.x + btnGroup.image.rect.w) and
     (y >= btnGroup.image.rect.y) and (y <= btnGroup.image.rect.y + btnGroup.image.rect.h) then
  begin
     //writeln(x,'  ',y);
    if not btnGroup.hoverSoundPlayed then
    begin
      //btnGroup.image.rect.x := Round(btnGroup.image.rect.x *0.95);
      //btnGroup.image.rect.y := Round(btnGroup.image.rect.x *0.95);
      // Agrandir une seule fois
      btnGroup.image.rect.w := Round(btnGroup.originalWidth * 1.1);
      btnGroup.image.rect.h := Round(btnGroup.originalHeight * 1.1);

      btnGroup.button.rect.w := btnGroup.image.rect.w;
      btnGroup.button.rect.h := btnGroup.image.rect.h;

      SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 180);  // Alpha à 180 pour OnHover

      // Jouer le son de hoverr
      jouerSon('SFX/Button_hover.wav');
      btnGroup.hoverSoundPlayed := True;
    end;
  end
  else
  if btnGroup.hoverSoundPlayed then
  begin
    // Réinitialiser l'alpha et la taille si la souris quitte la zone de Hover
    SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 150);
      //btnGroup.image.rect.x := Round(btnGroup.image.rect.x *1.05);
      //btnGroup.image.rect.y := Round(btnGroup.image.rect.x *1.05);
      btnGroup.image.rect.h := btnGroup.originalHeight;
      btnGroup.image.rect.w := btnGroup.originalWidth;
      btnGroup.button.rect.w := btnGroup.originalWidth;
      btnGroup.button.rect.h := btnGroup.originalHeight;
    btnGroup.hoverSoundPlayed := False;  // Réinitialiser pour le prochain Hover
  end;
end;

procedure OnMouseHover(var btnGroup: TButtonGroup; x, y: Integer; soundDir : Pchar;var isHovered :Boolean);overload;
begin
  // Vérifier si la souris est sur le bouton
  if (x >= btnGroup.image.rect.x) and (x <= btnGroup.image.rect.x + btnGroup.image.rect.w) and
     (y >= btnGroup.image.rect.y) and (y <= btnGroup.image.rect.y + btnGroup.image.rect.h) then
  begin
    if not btnGroup.hoverSoundPlayed then
    begin
      btnGroup.image.rect.w := Round(btnGroup.originalWidth * 1.1);
      btnGroup.image.rect.h := Round(btnGroup.originalHeight * 1.1);

      btnGroup.button.rect.w := btnGroup.image.rect.w;
      btnGroup.button.rect.h := btnGroup.image.rect.h;

      SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 180);
      jouerSon(soundDir);
      btnGroup.hoverSoundPlayed := True;
      isHovered:=True;
    end;
  end
  else
  if btnGroup.hoverSoundPlayed then
  begin
    // Réinitialiser l'alpha et la taille si la souris quitte la zone de Hover
    SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 150);
      //btnGroup.image.rect.x := Round(btnGroup.image.rect.x *1.05);
      //btnGroup.image.rect.y := Round(btnGroup.image.rect.x *1.05);
      btnGroup.image.rect.h := btnGroup.originalHeight;
      btnGroup.image.rect.w := btnGroup.originalWidth;
      btnGroup.button.rect.w := btnGroup.originalWidth;
      btnGroup.button.rect.h := btnGroup.originalHeight;
    btnGroup.hoverSoundPlayed := False;  // Réinitialiser pour le prochain Hover
    isHovered:=False;
  end;
end;


// Gérer l'événement de clic sur le bouton (OnClick)
procedure OnMouseClick(var btnGroup: TButtonGroup; x, y: Integer);
begin
  if (x >= btnGroup.image.rect.x) and (x <= btnGroup.image.rect.x + btnGroup.image.rect.w) and
     (y >= btnGroup.image.rect.y) and (y <= btnGroup.image.rect.y + btnGroup.image.rect.h) then
  begin
  // Appliquer un alpha plus fort pour un effet visuel supplémentaire lors du clic
  SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 220);  // Alpha à 220 pour OnClick

  // Jouer le son de clic
  jouerSon('SFX/Button_click.wav');
  end;
end;

procedure CreateDamagePopUp(x, y: Integer; damage: PChar; couleur: TSDL_Color);
var
  newPopUp: TText;
begin
  CreateText(newPopUp, x+10, y+20,20,20, damage, Fantasy30, couleur);
  SetLength(DamagePopUps, Length(DamagePopUps) + 1);
  DamagePopUps[High(DamagePopUps)] := newPopUp;
end;


procedure UpdateDamagePopUps;
var
  i,j: Integer;
begin
  if  High(DamagePopUps)+1 = 0 then exit;

  for i :=0 to High(DamagePopUps) do
  if(i<=High(DamagePopUps)) then
  begin
    //writeln('focusing on element ', High(DamagePopUps)+1, ' , careful !');
    // Afficher le pop-up
    RenderText(DamagePopUps[i]);

    // Mise à jour de la position et de l'opacité
    DamagePopUps[i].rect.y := DamagePopUps[i].rect.y - 1; 
    DamagePopUps[i].textColor.a := Max(0, DamagePopUps[i].textColor.a - (255 div 60));

    // Supprimer le pop-up si son temps est écoulé
    if DamagePopUps[i].textColor.a = 0 then
    begin
      //writeln('element ', High(DamagePopUps)+1, ' being wiped out of existance...');
      SDL_DestroyTexture(DamagePopUps[i].textTexture);
      SDL_freeSurface(DamagePopUps[i].textSurface);
      //writeln('element ', High(DamagePopUps)+1, ' destroyed sucessfully !');
      for j:=i to High(DamagePopUps)-1 do 
            DamagePopUps[j]:=DamagePopUps[j+1];
      setlength(DamagePopUps,High(DamagePopUps));
      //writeln('liste popup : ', High(DamagePopUps)+1)
    end;
  end;
end;



begin
  fonduActif := False;
  fonduEntrant := True;
  dureeFondu := 0;
  //WriteLn('AnimationSys ready ⋆｡°✩');
end.

end.