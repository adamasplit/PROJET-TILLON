unit CollisionSys;

interface

uses
  AnimationSys,
  Math,
  memgraph,
  SDL2,sdl2_mixer,combatLib,eventSys,
  SysUtils,coeur;

  var modeDebug:Boolean;


  // Vérifie automatiquement les collisions entre tous les objets actifs
  procedure UpdateCollisions();
  function GetCollisionRect(var obj: TObjet): TSDL_Rect;

  // Fonction de vérification manuelle des collisions entre deux objets
  function CheckCollision(var obj1, obj2: TObjet): Boolean;

  // Fonction OnTriggerEnter déclenchée lors d'une collision (si IsTrigger est vrai)
  procedure OnTriggerEnter(var obj1, obj2: TObjet);

implementation



// Vérifie si deux rectangles (boîtes englobantes) se chevauchent (AABB)
function CheckAABB(rect1, rect2: TSDL_Rect): Boolean;
begin
  //WriteLn('x1 :', rect1.x, 'x2 : ',rect2.x, ' y1 :', rect1.y, ' y2 : ',rect2.y, ' h1 :', rect1.h, ' x2 : ',rect2.h);
  CheckAABB := (rect1.x < rect2.x + rect2.w) and (rect1.x + rect1.w > rect2.x) and
            (rect1.y < rect2.y + rect2.h) and (rect1.y + rect1.h > rect2.y);
end;

// Calcul des rectangles de collision ajustés par l'offset
function GetCollisionRect(var obj: TObjet): TSDL_Rect;
begin

  GetCollisionRect.x := obj.image.rect.x + obj.col.offset.x;
  GetCollisionRect.y := obj.image.rect.y + obj.col.offset.y;
  GetCollisionRect.w := obj.col.dimensions.w;
  GetCollisionRect.h := obj.col.dimensions.h;
  if modeDebug then
    begin
    SDL_SetRenderDrawColor(sdlRenderer, 0, 255, 0, 255);
    SDL_RenderDrawRect(sdlRenderer, @getcollisionrect);
    end;
end;

// Vérifie la collision entre deux objets et gère les conséquences (repoussement ou trigger)
function CheckCollision(var obj1, obj2: TObjet): Boolean;
var
  rect1, rect2: TSDL_Rect;
  overlapX, overlapY: Integer;
begin
  rect1 := GetCollisionRect(obj1);
  rect2 := GetCollisionRect(obj2);

  CheckCollision := CheckAABB(rect1, rect2);

  if CheckCollision then
  begin
    //WriteLn('Collision detected between ', obj1.col.nom, ' and ', obj2.col.nom);
    // Si l'un des deux objets est un trigger, on appelle OnTriggerEnter
    if obj1.col.isTrigger or obj2.col.isTrigger then
    begin
      OnTriggerEnter(obj1, obj2);
    end
    else
      begin
      // Si aucun des deux objets n'est un trigger, on les repousse pour éviter le chevauchement
      overlapX := Min(rect1.x + rect1.w, rect2.x + rect2.w) - Max(rect1.x, rect2.x);
      overlapY := Min(rect1.y + rect1.h, rect2.y + rect2.h) - Max(rect1.y, rect2.y);
      //WriteLn(overlapX);

      // Si le chevauchement est plus grand en X, on repousse en X
      if overlapX < overlapY then
        begin
        if rect1.x < rect2.x then
          obj1.image.rect.x := obj1.image.rect.x - overlapX  // Repousser vers la gauche
        else
          obj1.image.rect.x := obj1.image.rect.x + overlapX;  // Repousser vers la droite
        end
      else
        begin
        // Sinon, on repousse en Y
        if rect1.y < rect2.y then
          obj1.image.rect.y := obj1.image.rect.y - overlapY  // Repousser vers le haut
        else
          obj1.image.rect.y := obj1.image.rect.y + overlapY;  // Repousser vers le bas
        end;
      if (obj2.stats.genre=typeobjet(1)) and (obj2.stats.degatsContact>0) and (obj2.stats.cooldown=0) then
        begin
        subirDegats(obj1,obj2.stats.degatsContact,0,0);
        obj2.stats.cooldown:=150
        end;
    end;
  end;
end;

function collisionValide(genre1,genre2:TypeObjet):Boolean;
begin
  if (genre1=projectile) or (genre1=laser) or (genre1=epee) then
    collisionValide:=((genre2<>projectile) and (genre2<>laser) and (genre2<>epee));
  if (genre2=projectile) or (genre2=laser) or (genre2=epee) then
    collisionValide:=((genre1<>projectile) and (genre1<>laser) and (genre1<>epee));
end;
// Fonction appelée lorsqu'une collision avec un trigger est détectée
procedure OnTriggerEnter(var obj1, obj2: TObjet);
begin
  // Exemple de gestion du trigger : ici, tu peux ajouter des actions spécifiques
  if (not (obj1.col.nom='Dummy')) and collisionValide (obj1.stats.genre,obj2.stats.genre) then
  begin
    if (obj1.stats.genre=projectile) and (obj1.stats.origine<>obj2.stats.genre) then
      begin
      end;
    if ((obj2.stats.genre=projectile) or (obj2.stats.genre=laser) or (obj2.stats.genre=epee)) and (obj2.stats.origine<>obj1.stats.genre) then
      begin
        subirDegats(obj1,degat(obj2.stats.degats,obj2.stats.force,obj1.stats.defense,obj2.stats.multiplicateurDegat),round(obj2.stats.vectx),round(obj2.stats.vecty));
        if obj2.stats.genre=projectile then
          creerEffet(obj2.image.rect.x,obj2.image.rect.y,64,64,6,'impact',False,obj2)
      end
  end
end;

// Met à jour les collisions entre tous les objets actifs
procedure UpdateCollisions();
var
  i, j: Integer;
begin
  
  for i := 0 to High(LObjets) do
  if (i<=High(LObjets)) then
  begin
    // Si l'objet est actif pour les collisions
    if LObjets[i].col.estActif then
    begin
      for j := i + 1 to High(LObjets) do
      begin
        // Si l'autre objet est aussi actif pour les collisions
        if LObjets[j].col.estActif then
        begin
          // Vérifier les collisions entre obj[i] et obj[j]
          CheckCollision(LObjets[i], LObjets[j]);
        end;
      end;
    end;
  end;
end;

end.
