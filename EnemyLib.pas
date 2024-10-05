unit EnemyLib;

interface
uses
    coeur,
    math,
    memgraph,
    SDL2,
    SysUtils;


var EnemyBasik : TObjet;
procedure initStatEnnemi(nom:String,vie,att,def:Integer,directory:Pchar,var ennemi:TObjet);

implementation
procedure initStatEnnemi(nom:String,vie,att,def:Integer,directory:Pchar,var ennemi:TObjet);
begin
    CreateRawImage(ennemi.image,0,0,'');
    InitAnimation(ennemi.anim,nom,'Chase', 6,True)
    ennemi.stats.vieMax:=vie;
    ennemi.stats.vie:=ennemi.stats.vieMax;
    ennemi.stats.force:=att;
    ennemi.stats.defense:=def;
end;

procedure AIPathFollow(var ennemi: TObjet; target: TObjet);
const
  vitesse = 2;  
  espaceVital = 5; 
var
  deltaX, deltaY: Integer;
begin
  // Calcul des distances entre l'ennemi et la cible
  deltaX := target.image.rect.x - ennemi.image.rect.x;
  deltaY := target.image.rect.y - ennemi.image.rect.y;

  // Si l'ennemi est suffisamment proche de la cible, il s'arrête
  if (Abs(deltaX) < espaceVital) and (Abs(deltaY) < espaceVital) then
    Exit;

  // Mouvement horizontal
  if Abs(deltaX) >= espaceVital then
  begin
    if deltaX > 0 then
      ennemi.image.rect.x := ennemi.image.rect.x + vitesse  // L'ennemi avance vers la droite
    else
      ennemi.image.rect.x := ennemi.image.rect.x - vitesse; // L'ennemi avance vers la gauche
  end;

  // Mouvement vertical
  if Abs(deltaY) >= espaceVital then
  begin
    if deltaY > 0 then
      ennemi.image.rect.y := ennemi.image.rect.y + vitesse  // L'ennemi avance vers le bas
    else
      ennemi.image.rect.y := ennemi.image.rect.y - vitesse; // L'ennemi monte vers le haut
  end;
end;



begin
// EnnemyBasik
initStatEnnemi('EnnemyBasik',100,12,4,'Sprites\Game\dummy.bmp',EnnemyBasik);

end.