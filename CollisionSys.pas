unit CollisionSys;

interface

uses
    AnimationSys,
    Math,
    memgraph,
    SDL2,
    SysUtils;

type
  // A DEPLACER VERS LA UNIT COEUR JSP COMMENT ELLE S'APPELLE !!!!
  TObjet = record
    image: TImage;          // Image associée à l'objet
    anim: TAnimation;       // Animation associée à l'objet
    IsTrigger: Boolean;     // Si vrai, ne bloque pas, mais déclenche un événement (ex: un mur n'est pas trigger)
  end;

  // Vérifie une collision entre deux objets
  function CheckCollision(var obj1, obj2: TObjet; offsetX: Integer; offsetY: Integer): Boolean;

  // Fonction OnTriggerEnter déclenchée lors d'une collision (si IsTrigger est vrai)
  function OnTriggerEnter(var obj1, obj2: TObjet): TObjet;

//Fonction de putain de Block de merde me fais pas chier et comprends tout seul
  procedure Block(var obj1, obj2 : TObjet);

implementation

// Vérifie si deux rectangles (boîtes englobantes) se chevauchent (AABB)
function CheckAABB(rect1, rect2: TSDL_Rect): Boolean;
begin
  CheckAABB := (rect1.x < rect2.x + rect2.w) and (rect1.x + rect1.w > rect2.x) and
            (rect1.y < rect2.y + rect2.h) and (rect1.y + rect1.h > rect2.y);
end;

// Vérifie une collision entre deux objets
function CheckCollision(var obj1, obj2: TObjet; offsetX: Integer; offsetY: Integer): Boolean;
var
  rect1, rect2: TSDL_Rect;
begin
  // Appliquer les offsets sur les objets
  rect1 := obj1.image.rect;
  rect2 := obj2.image.rect;

  rect1.x := rect1.x + offsetX;
  rect1.y := rect1.y + offsetY;

  // Vérifier la collision AABB
  CheckCollision := CheckAABB(rect1, rect2);

  // Si une collision est détectée et si un des objets est un Trigger
  if CheckCollision and not(obj1.IsTrigger or obj2.IsTrigger) then
  begin
    WriteLn('Non-Trigger Collision detected between ', obj1.image.rect.x, ' and ', obj2.image.rect.x); //Debug
  end;

    
end;

// Fonction OnTriggerEnter : Déclenchée lorsqu'un objet entre en collision avec un Trigger
function OnTriggerEnter(var obj1, obj2: TObjet): TObjet;
begin
  if obj1.IsTrigger then
    OnTriggerEnter := obj2
  else
    OnTriggerEnter := obj1;

  // Debug
  WriteLn('Trigger collision detected between ', obj1.image.rect.x, ' and ', obj2.image.rect.x);
end;

procedure Block(var obj1, obj2: TObjet);
var overlapX, overlapY: Integer;
    rect1,rect2 : TSDL_Rect;
begin
    rect1 :=obj1.image.rect;
    rect2 :=obj2.image.rect;
   // Si les deux objets ne sont pas des triggers, on bloque
    if not obj1.IsTrigger and not obj2.IsTrigger then
    begin
      // Calculer le chevauchement en X et Y
      overlapX := Min(rect1.x + rect1.w, rect2.x + rect2.w) - Max(rect1.x, rect2.x);
      overlapY := Min(rect1.y + rect1.h, rect2.y + rect2.h) - Max(rect1.y, rect2.y);

      // Déplacer l'objet 1 pour éviter le chevauchement
      if overlapX < overlapY then
      begin
        if rect1.x < rect2.x then
          obj1.image.rect.x := rect2.x - rect1.w  // Déplacer vers la gauche
        else
          obj1.image.rect.x := rect2.x + rect2.w;  // Déplacer vers la droite
      end
      else
      begin
        if rect1.y < rect2.y then
          obj1.image.rect.y := rect2.y - rect1.h  // Déplacer vers le haut
        else
          obj1.image.rect.y := rect2.y + rect2.h;  // Déplacer vers le bas
      end;
    end;
end;


begin

end.
