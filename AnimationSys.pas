unit AnimationSys;

interface

uses
  memgraph,
  SDL2,
  SysUtils,
  sonoSys,
  coeur;

const
  FRAME_DURATION = 90;  // Durée en ms pour 30 FPS

  

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
procedure OnMouseHover(var btnGroup: TButtonGroup; x,y : Integer);
procedure OnMouseClick(var btnGroup: TButtonGroup; x, y: Integer);




// Animation de Fondu au fromage


implementation

// Fonction pour créer un chemin complet vers la frame de l'animation
function GetFramePath(anim: TAnimation): PChar;
var
  framePath: PChar;
begin
  framePath := PChar(Format('Sprites\Game\%s\%s_%s_%d.bmp', [anim.ObjectName, anim.ObjectName, anim.Etat, anim.CurrentFrame]));
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
    image.directory := GetFramePath(anim);

    // Mettre à jour l'image avec la nouvelle frame
    {WriteLn('Animation : Changing directory to : ',image.directory);
    WriteLn(anim.isLooping);}
    CreateRawImage(image, image.rect.x, image.rect.y, image.rect.w, image.rect.h, image.directory);

    // Mettre à jour le temps de la dernière mise à jour
    anim.LastUpdateTime := currentTime;
  end;
end;

function animFinie(anim:TAnimation):Boolean;
begin
  animFinie:=(anim.currentFrame=anim.totalFrames)
end;

procedure InitButtonGroup(var btnGroup: TButtonGroup;  x, y, w, h: Integer; imgPath: PChar;labelText: PAnsiChar;onClick: ButtonProcedure);
begin
  // Initialiser le bouton avec l'image de fond
  CreateButton(btnGroup.button,x,y,w,h,labelText,b_color,black_color,dayDream30,onClick);  // Créer le bouton

  // Charger l'image de fond
  CreateRawImage(btnGroup.image,x,y,w,h,imgPath);  // Créer l'image de fond
  btnGroup.hoverSoundPlayed := False;         // Initialiser le survol comme non effectué
  btnGroup.originalHeight := btnGroup.image.rect.h;
  btnGroup.originalWidth := btnGroup.image.rect.w;
  SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 150);  
end;

procedure RenderButtonGroup(var btnGroup: TButtonGroup);
begin
RenderRawImage(btnGroup.image, False);
RenderButton(btnGroup.button);
end;

procedure OnMouseHover(var btnGroup: TButtonGroup; x, y: Integer);
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
      jouerSon('SFX\Button_hover.wav');
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


// Gérer l'événement de clic sur le bouton (OnClick)
procedure OnMouseClick(var btnGroup: TButtonGroup; x, y: Integer);
begin
  if (x >= btnGroup.image.rect.x) and (x <= btnGroup.image.rect.x + btnGroup.image.rect.w) and
     (y >= btnGroup.image.rect.y) and (y <= btnGroup.image.rect.y + btnGroup.image.rect.h) then
  begin
  // Appliquer un alpha plus fort pour un effet visuel supplémentaire lors du clic
  SDL_SetTextureAlphaMod(btnGroup.image.imgTexture, 220);  // Alpha à 220 pour OnClick

  // Jouer le son de clic
  jouerSon('SFX\Button_click.wav');
  end;
end;

end.
