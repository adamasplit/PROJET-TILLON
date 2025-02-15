unit CollisionSys;

interface

uses
  AnimationSys,
  Math,
  memgraph,
  SDL2,sdl2_mixer,CombatLib,eventSys,SonoSys,
  SysUtils,coeur;

  


  // Vérifie automatiquement les collisions entre tous les objets actifs
  procedure MAJCollisions();
  function GetCollisionRect(var obj: TObjet): TSDL_Rect;
  function CheckAABB(rect1, rect2: TSDL_Rect): Boolean;
  function isAttack(stats:TStats):Boolean;
  // Fonction de vérification manuelle des collisions entre deux objets
  function VerifCollision(var obj1, obj2: TObjet): Boolean;
  function PseudoColMurs(var obj:TObjet):Boolean;

  // Fonction OnTriggerEnter déclenchée lors d'une collision (si IsTrigger est vrai)
  procedure OnTriggerEnter(var obj1, obj2: TObjet);


implementation

type ligne=record
  x,y:real;
  centre:TSDL_POint;
end;
type axes=Array[1..2] of ligne;
type coins=Array[1..5] of TSDL_point;
vecteur=array[1..2] of real;
// Vérifie si deux rectangles (boîtes englobantes) se chevauchent (AABB)
function CheckAABB(rect1, rect2: TSDL_Rect): Boolean;
begin
  //WriteLn('x1 :', rect1.x, 'x2 : ',rect2.x, ' y1 :', rect1.y, ' y2 : ',rect2.y, ' h1 :', rect1.h, ' x2 : ',rect2.h);
  CheckAABB := (rect1.x < rect2.x + rect2.w) and (rect1.x + rect1.w > rect2.x) and
            (rect1.y < rect2.y + rect2.h) and (rect1.y + rect1.h > rect2.y);
end;

function isAttack(stats:TStats):Boolean;
begin
  isAttack:=(stats.genre=epee) or (stats.genre=projectile) or (stats.genre=laser) or (stats.genre=explosion) or (stats.genre=explosion2)
end; 

procedure dessinerpetitrectangle(x,y:Integer);
begin
  drawrect(red_color,255,x-8,y-8,16,16)
end;

//vérifie si deux boîtes de collisions (inclinées) sont en contact

function trouverAxes(obj:TObjet):axes;
var i,w,h,centreX,centreY:Integer;
begin


  w:=obj.col.dimensions.w div 2;
  h:=obj.col.dimensions.h div 2;
  centreX:=obj.image.rect.x+obj.col.offset.x+w;
  centreY:=obj.image.rect.y+obj.col.offset.y+h;
  
  trouverAxes[1].y:=sin(obj.stats.angle);
  trouverAxes[1].x:=cos(obj.stats.angle);
  trouverAxes[2].x:=-sin(obj.stats.angle);
  trouverAxes[2].y:=cos(obj.stats.angle);
  //writeln('directions de l''axe 2:',trouverAxes[2].x:2:2,' ',trouverAxes[2].y:2:2);
  for i:=1 to 2 do
    begin
      trouverAxes[i].centre.x:=centreX;
      trouverAxes[i].centre.y:=centreY;
    end;

  if modeDebug then for i:=1 to 2 do SDL_RenderDrawLine(sdlrenderer,round(trouveraxes[i].centre.x-trouveraxes[i].x*1000),round(trouveraxes[i].centre.y-trouveraxes[i].y*1000),round(trouveraxes[i].centre.x+trouveraxes[i].x*1000),round(trouveraxes[i].centre.y+trouveraxes[i].y*1000))
end;


function trouverCoins(obj:TObjet):coins;
var centreX,centreY,w,h:Integer;vect1,vect2:ligne;pointeurPoint:PSDL_Point;
begin
  w:=obj.col.dimensions.w div 2;
  h:=obj.col.dimensions.h div 2;
  centreX:=obj.image.rect.x+obj.col.offset.x+w;
  centreY:=obj.image.rect.y+obj.col.offset.y+h;
  vect1:=trouverAxes(obj)[1];
  vect2:=trouverAxes(obj)[2];
  //calcule les positions des 4 coins
  trouverCoins[1].x:=centreX+round((vect1.x*w)+(vect2.x*h));
  trouverCoins[1].y:=centreY+round((vect1.y*w)+(vect2.y*h));
  trouverCoins[2].x:=centreX+round((vect1.x*w)-(vect2.x*h));
  trouverCoins[2].y:=centreY+round((vect1.y*w)-(vect2.y*h));
  trouverCoins[3].x:=centreX+round(-(vect1.x*w)-(vect2.x*h));
  trouverCoins[3].y:=centreY+round(-(vect1.y*w)-(vect2.y*h));
  trouverCoins[4].x:=centreX+round(-(vect1.x*w)+(vect2.x*h));
  trouverCoins[4].y:=centreY+round(-(vect1.y*w)+(vect2.y*h));
  trouverCoins[5]:=trouvercoins[1];
  pointeurPoint:=@trouvercoins;
  
  if modeDebug and not (obj.col.hasCollided) then 
    begin
    SDL_SetRenderDrawColor(sdlRenderer, 0, 255, 255, 255);
    SDL_RenderDrawLines(sdlrenderer,pointeurPoint,5);
    end;
end;

function centreangle(obj:TObjet):TSDL_Point;
var co:coins;
begin
  co:=trouvercoins(obj);
  centreangle.x:=(co[1].x+co[3].x) div 2;
  centreangle.y:=(co[1].y+co[3].y) div 2;
end;

function projection(point:TSDL_Point;axe:ligne):vecteur;
var vect1,vect2:array[1..2] of Real;angle1,angle2,k:Real;
begin
  vect1[1]:=point.x-axe.centre.x;
  vect1[2]:=point.y-axe.centre.y;
  vect2[1]:=axe.x;
  vect2[2]:=axe.y;

  initAngle(vect1[1],vect1[2],angle1);
  initAngle(vect2[1],vect2[2],angle2);

  k:=vect2[1]*vect1[1]+vect2[2]*vect1[2];
  projection[1]:=k*vect2[1];
  projection[2]:=k*vect2[2];
  if modeDebug then 
    begin
    SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 255, 255);
    sdl_renderdrawline(sdlrenderer,point.x,point.y,axe.centre.x+round(projection[1]),axe.centre.y+round(projection[2]));
    dessinerpetitrectangle(axe.centre.x+round(projection[1]),axe.centre.y+round(projection[2]));
    end

end;

function contactCoins(coin1,coin2:TSDL_point;axe:ligne;seuil:Integer):Boolean;
var proj1,proj2:vecteur;norme1,norme2:Real;signe1,signe2:Boolean;distMax,distMin:Integer;
begin
  //projection des 2 coins
  proj1:=projection(coin1,axe);
  proj2:=projection(coin2,axe);
  //normes des projetés
  norme1:=sqrt(proj1[1]**2+proj1[2]**2);
  norme2:=sqrt(proj2[1]**2+proj2[2]**2);
  //calcul des signes respectifs des produits scalaires
  signe1:=(proj1[1]*axe.x+proj1[2]*axe.y>0);
  signe2:=(proj2[1]*axe.x+proj2[2]*axe.y>0);

  
  
  if not signe1 then norme1:=-norme1;
  if not signe2 then norme2:=-norme2;
  //vérifie si la boîte de collisions intersecte le segment formé par les 2 projetés
  distMax:=(round(max(norme1,norme2)));
  distMin:=(round(min(norme1,norme2)));

  contactCoins:=(((distMax>seuil) and (distMin<seuil))
              or (abs(distMin)<seuil) or (abs(distMax)<seuil));
  if contactCoins and modeDebug then 
    begin
    SDL_setRenderDrawColor(sdlrenderer,255,0,0,255);
    sdl_renderdrawline(sdlRenderer,round(axe.centre.x+proj2[1]),round(axe.centre.y+proj2[2]),round(axe.centre.x+proj1[1]),round(axe.centre.y+proj1[2]));
    dessinerpetitrectangle(coin1.x,coin1.y);
    dessinerpetitrectangle(coin2.x,coin2.y);
    end
  else
    if modeDebug then
    begin
    SDL_setRenderDrawColor(sdlrenderer,0,0,255,255);
    sdl_renderdrawline(sdlRenderer,round(axe.centre.x+proj2[1]),round(axe.centre.y+proj2[2]),round(axe.centre.x+proj1[1]),round(axe.centre.y+proj1[2]));
    end

end;
function collisionAngle(obj1,obj2:TObjet):Boolean;

var coins1,coins2:coins;axes1,axes2:axes;pointeurPoint:PSDL_Point;
begin

  //détermine les positions des coins des 2 objets
  coins1:=trouverCoins(obj1);
  coins2:=trouverCoins(obj2);
  //trouve leurs axes (centre et direction de propagation)
  axes1:=trouverAxes(obj1);
  axes2:=trouverAxes(obj2);

  collisionAngle:=True;

  //si les projections des coins d'un rectangle sur les axes de l'autre n'intersectent pas la boîte, la collision est fausse
  collisionANGLE:=((
        contactCoins(coins2[2],coins2[4],axes1[1],obj1.col.dimensions.w div 2) or contactCoins(coins2[1],coins2[3],axes1[1],obj1.col.dimensions.w div 2)) 
   and( contactCoins(coins2[3],coins2[1],axes1[2],obj1.col.dimensions.h div 2) or contactCoins(coins2[2],coins2[4],axes1[2],obj1.col.dimensions.h div 2))
   and( contactCoins(coins1[2],coins1[4],axes2[1],obj2.col.dimensions.w div 2) or contactCoins(coins1[1],coins1[3],axes2[1],obj2.col.dimensions.w div 2))
   and( contactCoins(coins1[1],coins1[3],axes2[2],obj2.col.dimensions.h div 2) or contactCoins(coins1[2],coins1[4],axes2[2],obj2.col.dimensions.h div 2)));

  pointeurPoint:=@coins1;
  
  if modeDebug and collisionANGLE then 
    begin
    SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 0, 255);
    SDL_RenderDrawLines(sdlrenderer,pointeurPoint,5);
    sdl_renderDrawLINE(sdlrenderer,obj1.image.rect.x+(obj1.image.rect.w div 2),obj1.image.rect.y+(obj1.image.rect.h div 2),obj2.image.rect.x+(obj2.image.rect.w div 2),obj2.image.rect.y+(obj2.image.rect.h div 2));
    end;
end;

// Calcul des rectangles de collision ajustés par l'offset
function GetCollisionRect(var obj: TObjet): TSDL_Rect;
begin

  GetCollisionRect.x := obj.image.rect.x + obj.col.offset.x;
  GetCollisionRect.y := obj.image.rect.y + obj.col.offset.y;
  GetCollisionRect.w := obj.col.dimensions.w;
  GetCollisionRect.h := obj.col.dimensions.h;
  if modeDebug and not (obj.col.hasCOllided) then
    begin
    SDL_RenderDrawRect(sdlRenderer, @getcollisionrect);
    end;
end;

//simule une collision avec tous les murs (différente de VerifCollision)
function PseudoColMurs(var obj:TObjet):Boolean;
var colx1,colx2,coly1,coly2:Integer; //4 coins de l'objet
begin
  if not isAttack(obj.stats) then
  begin
  colx1:=obj.image.rect.x+obj.col.offset.x;
  colx2:=obj.image.rect.x+obj.col.offset.x+obj.col.dimensions.w;
  coly1:=obj.image.rect.y+obj.col.offset.y;
  coly2:=obj.image.rect.y+obj.col.offset.y+obj.col.dimensions.h;
  PseudoColMurs:=False;
  if colx1<(murs[2].image.rect.x+murs[2].col.dimensions.w) then
    begin
    obj.image.rect.x:=murs[2].image.rect.x+murs[2].col.dimensions.w-obj.col.offset.x;
    pseudoColMurs:=True;
    end;
  if colx2>(murs[4].image.rect.x) then
    begin
    obj.image.rect.x:=murs[4].image.rect.x-obj.col.offset.x-obj.col.dimensions.w;
    pseudoColMurs:=True;
    end;
  if coly1<(murs[1].image.rect.y+murs[1].col.dimensions.h) then
    begin
    obj.image.rect.y:=murs[1].image.rect.y+murs[1].col.dimensions.h-obj.col.offset.y;
    pseudoColMurs:=True;
    end;
  if coly2>(murs[3].image.rect.y) then
    begin
    obj.image.rect.y:=murs[3].image.rect.y-obj.col.offset.y-obj.col.dimensions.h;
    pseudoColMurs:=True;
    end;
  end;

end;

// Vérifie la collision entre deux objets et gère les conséquences (repoussement ou trigger)
function VerifCollision(var obj1, obj2: TObjet): Boolean;
var
  rect1, rect2: TSDL_Rect;
  overlapX, overlapY: Integer;
begin
  if obj2.stats.angle<>0 then VerifCollision:=collisionAngle(obj1,obj2)
  else begin
    if modeDebug then
      SDL_SetRenderDrawColor(sdlRenderer, 0, 255, 0, 255);
    rect1 := GetCollisionRect(obj1);
    rect2 := GetCollisionRect(obj2);
    VerifCollision := CheckAABB(rect1, rect2);
    if VerifCollision then if modeDebug then 
      begin
      SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 0, 255);
      rect1 := GetCollisionRect(obj1);
      rect2 := GetCollisionRect(obj2);
      end;

    end;

  if (VerifCollision) and ((isAttack(obj2.stats) and (obj1.stats.indice>3) or (not (isAttack(obj2.stats) and (obj2.col.collisionsFaites[obj1.stats.indice]) )))) then
  begin
    //sert uniquement à l'affichage
    obj1.col.hasCollided:=True;
    obj2.col.hasCollided:=True;
    //pour savoir avec quels objets il est déjà en collision
    if isAttack(obj2.stats) and (obj1.stats.indice<=TAILLE_VAGUE+4) then obj2.col.collisionsFaites[obj1.stats.indice]:=True;
    // Si l'un des deux objets est un trigger, on appelle OnTriggerEnter
    if obj1.col.isTrigger or obj2.col.isTrigger then
    begin
      OnTriggerEnter(obj1, obj2);
    end
    else
      if not (obj1.stats.inamovible) and (not isAttack(obj1.stats)) then
      begin
      // Si aucun des deux objets n'est un trigger, on les repousse pour éviter le chevauchement
      overlapX := Min(rect1.x + rect1.w, rect2.x + rect2.w) - Max(rect1.x, rect2.x);
      overlapY := Min(rect1.y + rect1.h, rect2.y + rect2.h) - Max(rect1.y, rect2.y);
      //WriteLn(overlapX);

      // Si le chevauchement est plus grand en X, on repousse en X
      if overlapX < overlapY then
        begin
        if (rect1.x+(rect1.w div 2)) < (rect2.x+(rect2.w div 2)) then
          obj1.image.rect.x := obj1.image.rect.x - overlapX  // Repousser vers la gauche
        else
          obj1.image.rect.x := obj1.image.rect.x + overlapX;  // Repousser vers la droite
        end
      else
        begin
        // Sinon, on repousse en Y
        if (rect1.y+(rect1.h div 2)) < (rect2.y+(rect2.h div 2)) then
          obj1.image.rect.y := obj1.image.rect.y - overlapY  // Repousser vers le haut
        else
          obj1.image.rect.y := obj1.image.rect.y + overlapY;  // Repousser vers le bas
        end;

      //Permet à certains ennemis d'effectuer des dégâts au contact avec le joueur
      if (obj2.stats.genre=typeobjet(1)) and (obj1.stats.genre=typeobjet(0)) and (obj2.stats.degatsContact>0) and (obj2.stats.cooldown=0) then
        begin
        subirDegats(obj1,max(obj2.stats.degatsContact-(obj1.stats.defense),1),0,0);
        obj2.stats.cooldown:=150
        end;
    end;
  end
    else
      if (not VerifCollision) and isAttack(obj2.stats) and (obj1.stats.indice<=TAILLE_VAGUE+4) then
        obj2.col.collisionsFaites[obj1.stats.indice]:=False;
end;

function collisionValide(stats1,stats2:TStats):Boolean;
var att1,att2:Boolean;
begin
  att1:=isAttack(stats1);
  att2:=isAttack(stats2);
  if att1 then
    collisionValide:=(not (att2)) and (stats2.genre<>stats1.origine)
  else if att2 then
    collisionValide:=(not (att1)) and (stats1.genre<>stats2.origine)
  else if (stats1.genre=ennemi) or (stats1.genre=joueur) then collisionValide:=True;

end;

// Fonction appelée lorsqu'une collision avec un trigger est détectée
procedure OnTriggerEnter(var obj1, obj2: TObjet);
var eff:TObjet;
begin
  // Exemple de gestion du trigger : ici, on peut ajouter des actions spécifiques
  if (not (obj1.col.nom='Dummy')) then
  begin
    if (obj1.stats.genre=projectile) and (obj1.stats.origine<>obj2.stats.genre) then
      begin
      end;
    if (isAttack(obj2.stats)) and (obj2.stats.origine<>obj1.stats.genre) then
      begin
        if (obj2.stats.genre=epee) and not (isAttack(obj1.stats)) then
          jouerSonEff('impact_epee_'+intToStr(random(5)+1));
        if obj1.stats.genre=joueur then
          jouerSonEff('impact');
        if obj2.stats.genre=projectile then
          begin
          subirDegats(obj1,degat(obj2.stats.degats,obj2.stats.force,obj1.stats.defense,obj2.stats.multiplicateurDegat,obj2.stats.origine=ennemi),round(obj2.stats.vectx),round(obj2.stats.vecty));
          if (obj2.anim.objectName='meteore') then
            begin
            multiprojs(obj2.stats.origine,obj2.stats.degats div 20,obj2.stats.force,obj2.stats.multiplicateurDegat,round(obj2.stats.xreel),round(obj2.stats.yreel),100,100,8,8,360,0,'meteore2');
            creerEffet(obj2.image.rect.x,obj2.image.rect.y,obj2.image.rect.w,obj2.image.rect.h,8,'impact_meteore',False,obj2);
            end
          else
            creerEffet(obj2.image.rect.x,obj2.image.rect.y,obj2.image.rect.w,obj2.image.rect.h,6,'impact',False,obj2)
          end
        else
          begin
          subirDegats(obj1,degat(obj2.stats.degats,obj2.stats.force,obj1.stats.defense,obj2.stats.multiplicateurDegat,obj2.stats.origine=ennemi),0,0);
          if (obj2.stats.volVie) and (not (obj1.stats.indice>TAILLE_VAGUE)) then subirDegats(LObjets[0].stats,-min(LObjets[0].stats.vieMax div 10,round(degat(obj2.stats.degats,obj2.stats.force,obj1.stats.defense,obj2.stats.multiplicateurDegat,obj2.stats.origine=ennemi)*LObjets[0].stats.multiplicateurSoin) div 3),trouverCentreX(LObjets[0]),trouverCentreY(LObjets[0]));
          creerEffet(trouverCentreX(obj1),trouverCentreY(obj1),64,64,6,'impact',False,eff);
          ajoutobjet(eff);
          end;
        
      end
  end
end;

// Met à jour les collisions entre tous les objets actifs
procedure MAJCollisions();
var
  i, j: Integer;destructionI:Boolean; //mémorise si l'objet I est détruit
begin
  
  for i := 0 to High(LObjets) do
  if (i<=High(LObjets)) and not (leMonde and (LObjets[i].stats.genre=joueur)) and not (LObjets[i].stats.genre=afterimage) then
  begin
    LObjets[i].col.hasCollided:=False;
    //Limite la position d'un objet aux murs
    if (LObjets[i].stats.genre=ennemi) or (LObjets[i].stats.genre=joueur) then
         PseudoColMurs(LObjets[i]);
    // Si l'objet est actif pour les collisions
    if LObjets[i].col.estActif then
    begin
      destructionI:=False;
      for j := i + 1 to High(LObjets) do
      if (j<=High(LObjets)) and (i<=High(LObjets)) and (not destructionI) and not (LObjets[j].stats.genre=afterimage) then
      begin
        //writeln('i=',i,',j=',j,',High(LObjets)=',high(lobjets));
        if (LObjets[i].anim.objectName='Roue') then 
          begin 
          if isAttack(LObjets[j].stats) and (LObjets[j].stats.origine<>LObjets[i].stats.origine) and collisionAngle(LObjets[i],LObjets[j]) then
            begin
            if LObjets[j].stats.degats<10 then supprimeObjet(LObjets[j]) else LObjets[j].stats.degats:=LObjets[j].stats.degats-10;
            creerEffet(LObjets[i].image.rect.x+LObjets[i].col.offset.x div 2,LObjets[i].image.rect.y+LObjets[i].col.offset.y div 2,100,100,5,'roue_impact',False,LObjets[i]);
            destructionI:=True;
            end
          else if (LObjets[j].stats.genre=ennemi) and (LObjets[j].stats.degatsContact>0) and (LObjets[j].stats.cooldown<150) and collisionAngle(LObjets[i],LObjets[j]) then
            begin
            creerEffet(LObjets[i].image.rect.x+LObjets[i].col.offset.x div 2,LObjets[i].image.rect.y+LObjets[i].col.offset.y div 2,100,100,5,'roue_impact',False,LObjets[i]);
            LObjets[j].stats.cooldown:=LObjets[j].stats.cooldown+100;
            end;
          end
        else
        if (LObjets[j].anim.objectName='Roue') then 
          begin
          if isAttack(LObjets[i].stats) and (LObjets[j].stats.origine<>LObjets[i].stats.origine) and collisionAngle(LObjets[i],LObjets[j]) then
            begin
            if LObjets[i].stats.degats<10 then supprimeObjet(LObjets[i]) else LObjets[i].stats.degats:=LObjets[i].stats.degats-10;
            creerEffet(LObjets[j-1].image.rect.x+LObjets[j-1].col.offset.x div 2,LObjets[j-1].image.rect.y+LObjets[j-1].col.offset.y div 2,100,100,5,'roue_impact',False,LObjets[j-1]);
            destructionI:=True;
            end
          else if (LObjets[i].stats.genre=ennemi) and (LObjets[i].stats.degatsContact>0) and (LObjets[i].stats.cooldown<150) and collisionAngle(LObjets[i],LObjets[j]) then
            begin
            creerEffet(LObjets[j].image.rect.x+LObjets[j].col.offset.x div 2,LObjets[j].image.rect.y+LObjets[j].col.offset.y div 2,100,100,5,'roue_impact',False,LObjets[j]);
            LObjets[i].stats.cooldown:=LObjets[i].stats.cooldown+100;
            end;
          end
        else
          // Si l'autre objet est aussi actif pour les collisions
          if ((LObjets[j].col.estActif) and collisionValide(LObjets[i].stats,LObjets[j].stats)) and not (((LObjets[j].anim.objectName='Roue') and (Lobjets[j].stats.origine=joueur)) or ((LObjets[i].anim.objectName='Roue') and (Lobjets[i].stats.origine=joueur))) then
          begin
            // Vérifier les collisions entre obj[i] et obj[j]
            if pseudoColMurs(LObjets[i]) and not pseudoColMurs(LObjets[j]) then //si un objet est dans un mur, il a alors la 'priorité' pour le repoussement
              begin
              VerifCollision(LObjets[j], LObjets[i])
              end
            else
              VerifCollision(LObjets[i], LObjets[j]);
        end;
      end;
    end;
  end;
end;

end.
