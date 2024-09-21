unit AnimationSys;

interface

uses
  memgraph,
  SDL2,
  SysUtils;

const
  FRAME_DURATION = 66;  // Durée en ms pour 30 FPS

type
  TAnimation = record
    ObjectName: PChar;    // Nom de l'objet (par exemple 'Joueur')
    Etat: PChar;          // État de l'objet (par exemple 'idle', 'run')
    CurrentFrame: Integer; // Frame actuelle de l'animation
    TotalFrames: Integer;  // Nombre total de frames pour cet état
    LastUpdateTime: UInt32; // Dernière mise à jour de la frame
    IsLooping: Boolean;    // L'animation boucle-t-elle ?
    isFliped : Boolean; // L'image doit-elle etre renversée?
    estActif:Boolean; // L'objet est-il animé?
  end;

// Initialiser l'animation pour un objet
procedure InitAnimation(var anim: TAnimation; objectName, etat: PChar; totalFrames: Integer; isLooping: Boolean);

// Mettre à jour l'animation (changer la frame si nécessaire)
procedure UpdateAnimation(var anim: TAnimation; var image: TImage);

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
    WriteLn('Animation : Changing directory to : ',image.directory);
    WriteLn(anim.isLooping);
    CreateRawImage(image, image.rect.x, image.rect.y, image.rect.w, image.rect.h, image.directory);

    // Mettre à jour le temps de la dernière mise à jour
    anim.LastUpdateTime := currentTime;
  end;
end;

end.
