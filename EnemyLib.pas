unit EnemyLib;

interface
uses
    coeur,
    math,
    memgraph,
    SDL2,sdl2_mixer,
    animationSys,
    combatLib,
    sonoSys,
    SysUtils;


var EnemyBasik : TObjet;
var templatesEnnemis:array[1..MAXENNEMIS] of TObjet;
procedure initStatEnnemi(nom:PChar;typeIA_MVT,vie,att,def,w,h,frames1,frames2,frames3,framesM:Integer;var ennemi:TObjet;wcol,hcol,offx,offy:Integer;nomAttaques:PChar);
procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);

implementation
procedure initStatEnnemi(nom:PChar;typeIA_MVT,vie,att,def,w,h,frames1,frames2,frames3,framesM:Integer;var ennemi:TObjet;wcol,hcol,offx,offy:Integer;nomAttaques:PChar);
begin

    //Initialisation de l'affichage
    ennemi.stats.nbframes1:=frames1;
    ennemi.stats.nbframes2:=frames2;
    ennemi.stats.nbframes3:=frames3;
    ennemi.stats.nbframesMort:=framesM;
    InitAnimation(ennemi.anim,nom,'chase', ennemi.stats.nbframes1,True);
    //writeln('accès au fichier ',getframePath(ennemi.anim));
    CreateRawImage(ennemi.image,(random(20)+5)*20,0,w,h,getFramePath(ennemi.anim));
    

    //Initialisation des caractéristiques
    ennemi.stats.genre:=TypeObjet(1);
    ennemi.stats.vieMax:=vie;
    ennemi.stats.vie:=ennemi.stats.vieMax;
    ennemi.stats.force:=att;
    ennemi.stats.defense:=def;
    ennemi.stats.compteurAction:=0;
    ennemi.stats.multiplicateurDegat:=1;
    ennemi.stats.typeIA_MVT:=typeIA_MVT;
    ennemi.stats.xcible:=ennemi.image.rect.x;
    ennemi.stats.ycible:=ennemi.image.rect.y;
    ennemi.stats.nomAttaque:=nomAttaques;

    // Initialisation de la boîte de collisions
    ennemi.col.isTrigger := False;
    ennemi.col.estActif := True;
    ennemi.col.dimensions.w := wcol;
    ennemi.col.dimensions.h := hcol;
    ennemi.col.offset.x := offx;
    ennemi.col.offset.y := offy;
    ennemi.col.nom := nom;
    ennemi.anim.estActif := True;

end;

procedure AIWarp(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  randomize();
  ennemi.col.estActif:=False;
  repeat
    xdest:=random(10)*100;
  until (xdest<1000) and (xdest>0) and (abs(xdest-targetx)>100) and (abs(xdest-ennemi.image.rect.x)>100);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>100) and (abs(ydest-ennemi.image.rect.y)>100);
  InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'warp', ennemi.stats.nbframes2,False);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
  ennemi.stats.compteurAction:=0;
end;

procedure AIReWarp(var ennemi:TObjet);
begin
    InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'rewarp', ennemi.stats.nbframes3,False);
    ennemi.image.rect.x:=ennemi.stats.xcible;ennemi.image.rect.y:=ennemi.stats.ycible;
    ennemi.col.estActif:=True;
end;

procedure AIFly(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  repeat
  xdest:=random(10)*100;
  until (xdest<1000) and (xdest>0) and (abs(xdest-targetx)>100) and (abs(xdest-ennemi.image.rect.x)>100);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>50) and (abs(ydest-ennemi.image.rect.y)>50);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
end;

procedure FlyUpdate(var ennemi:TObjet);
var distx,disty:Integer;
begin
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);disty:=-(ennemi.image.rect.y-ennemi.stats.ycible);
  ennemi.image.rect.x:=ennemi.image.rect.x + (distx div 10);
  ennemi.image.rect.y:=ennemi.image.rect.y + (disty div 10);
  //writeln('x : ',ennemi.image.rect.x,', y : ',ennemi.image.rect.y);
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
end;

procedure AIDodge(var ennemi:TObjet;target:TObjet);
var distx:Integer;
begin
  distx:=(ennemi.image.rect.x-target.image.rect.x);
  InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'dodge', ennemi.stats.nbframes2,False);
  if distx>=0 then
    ennemi.stats.xcible:=800
  else
    ennemi.stats.xcible:=150;
  ennemi.stats.compteurAction:=0;
  ennemi.col.estActif:=False
end;

procedure DodgeUpdate(var ennemi:TObjet);
var distx:Integer;
begin
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);
  //writeln(ennemi.stats.xcible);
  ennemi.image.rect.x:=ennemi.image.rect.x + (distx div 10);
  //writeln('x : ',ennemi.image.rect.x,', y : ',ennemi.image.rect.y);
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
  if ennemi.stats.compteurAction>20 then
    initAnimation(ennemi.anim,ennemi.anim.objectName,'strike',ennemi.stats.nbframes3,false);
end;

procedure CrossMoveInit(var ennemi:TObjet;x,y:Integer);
var distx,disty:Integer;
begin
  distx:=-(ennemi.image.rect.x-x);disty:=-(ennemi.image.rect.y-y);
  if sqrt(distx**2+disty**2)>100 then
  if abs(distx)>abs(disty) then
    begin
    ennemi.stats.ycible:=ennemi.image.rect.y;ennemi.stats.xcible:=max(200,x);
    end
  else
    begin
    ennemi.stats.xcible:=ennemi.image.rect.x;ennemi.stats.ycible:=y;
    end;
  ennemi.stats.compteurAction:=0;
end;

procedure dashInit(var ennemi:TObjet);
begin
  if ennemi.image.rect.x>500 then
    ennemi.stats.xcible:=150
  else
    ennemi.stats.xcible:=700;
  ennemi.stats.ycible:=ennemi.image.rect.y;
  initAnimation(ennemi.anim,ennemi.anim.objectName,'dash',ennemi.stats.nbframes2,true);
end;

procedure MoveToTarget(var ennemi:TObjet;vitesse:Integer);
var angle:Real;
  distX,distY,y:Integer;
begin
  distX:=ennemi.stats.xcible-ennemi.image.rect.x;
  distY:=ennemi.stats.ycible-ennemi.image.rect.y;
  ennemi.anim.isFliped:=(distX>0);
  if distX=0 then
    if distY>0 then
      angle:=pi/2
    else
      angle:=-pi/2
  else
    if distX>0 then
      angle:=arctan(distY/distX)
    else
      angle:=-arctan(distY/distX);
  //writeln(distX,' ',distY,' ',angle);
  if abs(distX)>(vitesse) then
    if distX>0 then
      ennemi.image.rect.x:=ennemi.image.rect.x+round(vitesse*cos(angle))
    else
      ennemi.image.rect.x:=ennemi.image.rect.x-round(vitesse*cos(angle));
  if abs(distY)>(vitesse) then
    if distY>0 then
      ennemi.image.rect.y:=ennemi.image.rect.y+round(vitesse*sin(angle))
    else
      ennemi.image.rect.y:=ennemi.image.rect.y+round(vitesse*sin(angle));
  for y:=1 to 800 do
    begin
    distY:=ennemi.stats.ycible-y;
    if abs(distY+(ennemi.col.dimensions.h div 2))<(vitesse) then
      drawrect(red_color,200,ennemi.stats.xcible,y,10,5)
    end;
  if (abs(distX)<=vitesse) and (abs(distY)<=vitesse) then
    begin
    ennemi.image.rect.x:=ennemi.stats.xcible;
    ennemi.image.rect.y:=ennemi.stats.ycible;
    end;
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
  //drawRect(black_color,120,ennemi.stats.xcible-8,ennemi.stats.ycible-8,16,16);
end;

procedure AIPathFollow(var ennemi: TObjet; target: TObjet;vitesse:Integer;deplaceX,deplaceY:Boolean);
begin
  if deplaceX then
    ennemi.stats.xcible:=target.image.rect.x+50
  else 
    ennemi.stats.xcible:=ennemi.image.rect.x;
  if deplaceY then
    ennemi.stats.ycible:=target.image.rect.y+50
  else 
    ennemi.stats.ycible:=ennemi.image.rect.y;
  if (not deplaceX or (abs(ennemi.stats.xcible-(ennemi.image.rect.x)-ennemi.col.dimensions.w div 2)>ennemi.col.dimensions.w)) or (not deplaceY or (abs(ennemi.stats.ycible-(ennemi.image.rect.y)-ennemi.col.dimensions.h div 2)>ennemi.col.dimensions.h)) then
    moveToTarget(ennemi,vitesse);
  ennemi.anim.isFliped:=(target.image.rect.x-ennemi.image.rect.x>=0);
  {// Calcul des distances entre l'ennemi et la cible
  deltaX := target.image.rect.x - ennemi.image.rect.x;
  deltaY := target.image.rect.y - ennemi.image.rect.y;
  ennemi.anim.isFliped:=(deltaX>0);
  // Si l'ennemi est suffisamment proche de la cible, il s'arrête
  if (Abs(deltaX) < espaceVital) and (Abs(deltaY) < espaceVital) then
    Exit;

  // Mouvement horizontal
  if (Abs(deltaX) >= espaceVital) and (deplaceX) then
  begin
    if deltaX > 0 then
      ennemi.image.rect.x := ennemi.image.rect.x + vitesse  // L'ennemi avance vers la droite
    else
      ennemi.image.rect.x := ennemi.image.rect.x - vitesse; // L'ennemi avance vers la gauche
  end;

  // Mouvement vertical
  if (Abs(deltaY) >= espaceVital) and (deplaceY) then
  begin
    if deltaY > 0 then
      ennemi.image.rect.y := ennemi.image.rect.y + vitesse  // L'ennemi avance vers le bas
    else
      ennemi.image.rect.y := ennemi.image.rect.y - vitesse; // L'ennemi monte vers le haut
  end;}
end;


procedure ActionEnnemi(ennemi:TObjet;x,y:Integer); //permet à un ennemi d'agir (donc d'attaquer)
var obj:TObjet;
begin
  if (ennemi.anim.etat='shoot') and (ennemi.stats.compteurAction>10) and (ennemi.stats.compteurAction<15) then
    begin
      if (ennemi.image.rect.x<ennemi.stats.xcible) then
              CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+110,ennemi.image.rect.y+130,ennemi.image.rect.x+150,ennemi.image.rect.y+130,(random(5)-3)*3,10,100,ennemi.stats.nomAttaque,obj)
            else
              CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+60,ennemi.image.rect.y+130,ennemi.image.rect.x-60,ennemi.image.rect.y+130,(random(5)-3)*3,10,100,ennemi.stats.nomAttaque,obj);
            ajoutObjet(obj);
    end;
  case ennemi.stats.typeIA_MVT of
    0: if(ennemi.stats.compteurAction=100) then
      begin
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,5,5,360,(ennemi.stats.xcible-ennemi.image.rect.x),ennemi.stats.nomAttaque);
      end;
    3: if (ennemi.anim.etat='dash') and (ennemi.stats.compteurAction>50) and (ennemi.stats.compteurAction mod 45=0) then
      begin
      //multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,0,10,360,0,10,80,'rayon');
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,5,4,360,(ennemi.stats.xcible-ennemi.image.rect.x),ennemi.stats.nomAttaque);
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,5,4,360,(ennemi.stats.xcible-ennemi.image.rect.x) div 2,'kamui');
      end;
    4:if (ennemi.anim.etat='warp') and (ennemi.stats.compteurAction=1) then 
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+(ennemi.image.rect.w div 2),ennemi.image.rect.y+(ennemi.image.rect.h div 2),5,3,360,random(18)*10,ennemi.stats.nomAttaque);
    5: if (ennemi.anim.etat='strike')then
      begin
      ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
      if ennemi.anim.currentFrame=6 then
        begin
        if (ennemi.image.rect.x<ennemi.stats.xcible) then
          CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+40,ennemi.image.rect.y+50,ennemi.image.rect.x+60,ennemi.image.rect.y+50,0,10,5,ennemi.stats.nomAttaque,obj)
        else
          CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+40,ennemi.image.rect.y+50,ennemi.image.rect.x-60,ennemi.image.rect.y+50,0,10,5,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      end;
    6:
      begin
      if (ennemi.stats.compteurAction mod 60 = 0) and (ennemi.stats.compteurAction>0) and (ennemi.stats.compteurAction<200) then
        begin
        creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+64,ennemi.image.rect.y+64,4,x,y,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
      if ennemi.stats.compteurAction=100 then
        multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,0,4,360,0,10,100,'rayon');
      end;
    7:if (ennemi.stats.compteurAction mod 20 = 0) and (ennemi.anim.etat='fly') then begin
        creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+96+random(192),ennemi.image.rect.y+64+random(128),10,x,y,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    end;
end;

procedure DeplacementEnnemi(var ennemi:TObjet;joueur:TObjet); //déplace un ennemi 
var obj:TObjet;
begin
  case ennemi.stats.typeIA_MVT of
      0:
        begin //ennemi qui ne fait que suivre le joueur
        AIPathFollow(ennemi,joueur,1,true,true);
        if ennemi.stats.compteurAction>300 then
          ennemi.stats.compteurAction:=0
        else ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1
        end;
      1: //ennemi qui suit le joueur mais s'arrête pour attaquer
        begin
        if ennemi.anim.etat='chase' then
          begin
          AIPathFollow(ennemi,joueur,2,true,true);
          if ennemi.stats.compteurAction>300 then
            begin
            InitAnimation(ennemi.anim,ennemi.anim.objectName,'shoot',ennemi.stats.nbFrames2,True);
            ennemi.stats.compteurAction:=0;
            end
          else ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1
          end;
        if ennemi.anim.etat='shoot' then
          begin
          ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if ennemi.stats.compteurAction>100 then
            begin
            ennemi.stats.compteurAction:=0;
            InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True)
            end;
          end;
        end;
      3: //ennemi qui dash horizontalement
        begin
        if (ennemi.anim.etat='chase') then
          begin
          //ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
          AIPathFollow(ennemi,joueur,1,false,true);
          if abs((joueur.image.rect.y+64)-(ennemi.image.rect.y+(ennemi.col.dimensions.h div 2)))<50 then
            begin
            dashInit(ennemi);
            ennemi.stats.compteurAction:=0;
            end
          end;
        if ((ennemi.anim.etat='dash') or (ennemi.anim.etat='superdash')) and (abs(ennemi.stats.xcible-ennemi.image.rect.x)<40) then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,true);
            ennemi.col.estActif:=True;
            end;
        if (ennemi.anim.etat='dash') then
          begin
          moveToTarget(ennemi,10);
          if ennemi.stats.compteurAction>100 then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'superdash',2,true);
            ennemi.col.estActif:=False
            end;
          end;
        if (ennemi.anim.etat='superdash') then
          movetoTarget(ennemi,30);
        end;
      4: //pour un ennemi qui se téléporte 
        begin
          if (ennemi.anim.etat='rewarp') and animFinie(ennemi.anim) then
            InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase', ennemi.stats.nbFrames1,True);
          if animFinie(ennemi.anim) and (ennemi.anim.etat='chase') and (random(15)=0)  then 
            begin
              mix_playchannel(random(5),mix_loadWav('warp.wav'),0);
              AIWarp(ennemi,joueur.image.rect.x,joueur.image.rect.y);
            end;
          if (ennemi.anim.etat='warp') then
            ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if (ennemi.anim.etat='warp') and (ennemi.anim.currentFrame=ennemi.anim.totalFrames) and (ennemi.stats.compteurAction>50) then
            begin
            AIReWarp(ennemi);
            end
        end;
        
      //pour un ennemi qui esquive puis attaque
      5:begin
        if ennemi.anim.etat='chase' then
          AIPathFollow(ennemi,joueur,3,true,true);
        if (ennemi.anim.etat='chase') and (sqrt((ennemi.image.rect.x-joueur.image.rect.x)**2+(ennemi.image.rect.y-joueur.image.rect.y)**2)<120) then
          AIDodge(ennemi,joueur);
        if (ennemi.anim.etat='dodge') then
          DodgeUpdate(ennemi);
        if ennemi.anim.etat='strike' then
          ennemi.stats.xcible:=joueur.image.rect.x;
        ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
        if (ennemi.anim.etat='strike') and (animFinie(ennemi.anim)) then begin
          ennemi.col.estActif:=True;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          end;
        end;
      6:begin //déplacement similaire à la tour aux échecs
        if ennemi.stats.compteurAction>200 then
          crossMoveInit(ennemi,joueur.image.rect.x,joueur.image.rect.y)
        else
          begin
          moveToTarget(ennemi,10);
          end;
        end;
      7:begin //ennemi qui prend le temps de déployer ses ailes puis vole
        if (ennemi.anim.etat='chase') and (ennemi.stats.compteurAction>10) then
          initAnimation(ennemi.anim,ennemi.anim.objectName,'spread',ennemi.stats.nbFrames2,False);
        if (ennemi.anim.etat='chase') and (random(50)=1) then
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        if animFinie(ennemi.anim) and (ennemi.anim.etat='spread') then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'fly',ennemi.stats.nbFrames3,True);
          ennemi.stats.compteurAction:=0;
          end;
        if ennemi.anim.etat='fly' then
          begin
          if ennemi.stats.compteurAction mod 60=0 then
            aiFly(ennemi,joueur.image.rect.x,joueur.image.rect.y);
          flyUpdate(ennemi);
          if ennemi.stats.compteurAction>500 then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
            ennemi.stats.compteurAction:=0;
            end;
          end
        end;
    end
end;

procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);
var i:Integer;
begin
  DrawRect(black_color,255, ennemi.image.rect.x-2+ennemi.col.offset.x,ennemi.image.rect.y+ennemi.col.dimensions.h+ennemi.col.offset.y+5, ennemi.col.dimensions.w+4, 14);
  if ennemi.stats.vieMax>0 then
  DrawRect(red_color,255, ennemi.image.rect.x+ennemi.col.offset.x,ennemi.image.rect.y+ennemi.col.dimensions.h+ennemi.col.offset.y+7, Round(ennemi.col.dimensions.w*(ennemi.stats.vie/ennemi.stats.vieMax)), 10 );
  if ennemi.stats.vie<0 then ennemi.stats.vie:=0;
  if (ennemi.stats.vie>0) then 
    begin
      deplacementEnnemi(ennemi,joueur);
      actionEnnemi(ennemi,joueur.image.rect.x,joueur.image.rect.y);
    end
      
		else
      if (animFinie(ennemi.anim)) and (ennemi.anim.etat='mort') then
          begin
          supprimeObjet(ennemi);
          //writeln(ennemi.anim.objectname,' détruit')
          combatFini:=True;
          for i:=1 to High(LObjets) do
            if LObjets[i].stats.genre=TypeObjet(1) then
              begin
              combatFini:=False;
              //writeln('il reste des ennemis')
              end
          end
      else
      begin
      ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
			  if not (ennemi.anim.etat='mort') then 
          begin
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'mort',ennemi.stats.nbFramesMort,False);
          ennemi.col.estActif:=False
          end;
      end
end;

begin
initStatEnnemi('undrixel',3,50,5,0,288,192,10,4,0,10,TemplatesEnnemis[1],200,128,10,40,'eclairR');
initStatEnnemi('Archimage',4,100,2,6,128,128,6,6,6,4,TemplatesEnnemis[2],70,100,24,14,'projectile');
initStatEnnemi('liche',0,50,2,4,128,128,6,0,0,10,TemplatesEnnemis[3],70,110,19,7,'kamui');
initStatEnnemi('chevalier',5,10,10,1,90,90,6,3,10,5,TemplatesEnnemis[4],54,90,5,0,'rayonAbysse');
initStatEnnemi('expurgateur',6,20,3,1,128,128,12,0,0,7,TemplatesEnnemis[5],128,104,0,24,'eclairR');
initStatEnnemi('altegh',1,50,2,4,192,192,6,4,0,14,TemplatesEnnemis[6],160,96,16,96,'rayonAL');
initStatEnnemi('Akr',4,150,2,-20,384,256,9,9,8,16,TemplatesEnnemis[7],200,96,80,150,'kamui');
initStatEnnemi('UNKNOWN',4,150,2,-20,128,128,12,8,4,8,TemplatesEnnemis[8],64,114,32,14,'Roue');
initStatEnnemi('armure',7,400,0,10,384,256,2,13,9,16,TemplatesEnnemis[9],192,192,96,64,'justice');


end.