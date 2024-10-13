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
procedure initStatEnnemi(nom:Pchar;vie,att,def,w,h:Integer;var ennemi:TObjet);
procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);

implementation
procedure initStatEnnemi(nom:PChar;vie,att,def,w,h:Integer;var ennemi:TObjet);
begin

    //Initialisation de l'affichage
    InitAnimation(ennemi.anim,nom,'chase', 6,True);
    writeln('accès au fichier ',getframePath(ennemi.anim));
    CreateRawImage(ennemi.image,500,0,w,h,getFramePath(ennemi.anim));

    //Initialisation des caractéristiques
    ennemi.stats.genre:=TypeObjet(1);
    ennemi.stats.vieMax:=vie;
    ennemi.stats.vie:=ennemi.stats.vieMax;
    ennemi.stats.force:=att;
    ennemi.stats.defense:=def;
    ennemi.stats.compteurAction:=0;

    // Initialisation de la boîte de collisions
    ennemi.col.isTrigger := False;
    ennemi.col.estActif := True;
    ennemi.col.dimensions.w := 64;
    ennemi.col.dimensions.h := 100;
    ennemi.col.offset.x := 32;
    ennemi.col.offset.y := 14;
    ennemi.col.nom := 'Ennemi';
    ennemi.anim.estActif := True;

end;

procedure AIPathFollow(var ennemi: TObjet; target: TObjet);
const
  vitesse = 2;  
  espaceVital = 95; 
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
    ennemi.anim.isFliped:=(deltaX>0)
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

procedure AIWarp(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  randomize();
  repeat
    xdest:=random(10)*100;
  until (xdest<1000) and (xdest>0) and (abs(xdest-targetx)>100) and (abs(xdest-ennemi.image.rect.x)>100);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>100) and (abs(ydest-ennemi.image.rect.y)>100);
  InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'warp', 6,False);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
  ennemi.stats.compteurAction:=0;
end;

procedure AIReWarp(var ennemi:TObjet);
begin
    InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'rewarp', 6,False);
    ennemi.image.rect.x:=ennemi.stats.xcible;ennemi.image.rect.y:=ennemi.stats.ycible;
    ennemi.col.estActif:=True;
end;

procedure AIFly(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  ennemi.col.estActif:=False;
  repeat
  xdest:=random(10)*100;
  until (xdest<1000) and (xdest>0) and (abs(xdest-targetx)>100) and (abs(xdest-ennemi.image.rect.x)>100);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>50) and (abs(ydest-ennemi.image.rect.y)>50);
  InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'warp', 6,False);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
  ennemi.stats.compteurAction:=0;
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
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);
  InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'warp', 6,False);
  if distx>0 then
    ennemi.stats.xcible:=800
  else
    ennemi.stats.xcible:=200;
  ennemi.stats.compteurAction:=0;
end;

procedure DodgeUpdate(var ennemi:TObjet);
var distx:Integer;
begin
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);
  ennemi.image.rect.x:=ennemi.image.rect.x + (distx div 10);
  //writeln('x : ',ennemi.image.rect.x,', y : ',ennemi.image.rect.y);
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
  if ennemi.stats.compteurAction>10 then
    initAnimation(ennemi.anim,ennemi.anim.objectName,'rewarp',6,false);
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
    end
end;

procedure CrossMove();
begin

end;

procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);
var j:Integer;
obj:TObjet;
begin

  //affichage de la barre de vie

  DrawRect(black_color,255, ennemi.image.rect.x-2,ennemi.image.rect.y+118, 104, 14);
  if ennemi.stats.vie>0 then
  DrawRect(red_color,255, ennemi.image.rect.x,ennemi.image.rect.y+120, Round(100*(ennemi.stats.vie/ennemi.stats.vieMax)), 10 );

  if ennemi.stats.vie>0 then 
			begin
      //pour la majorité des ennemis
      if (ennemi.anim.etat='chase') then
				AIPathFollow(ennemi,joueur);
        {if (ennemi.stats.compteurAction>200) then
          begin
          crossMoveInit(ennemi,joueur.image.rect.x,joueur.image.rect.y);
          ennemi.stats.compteurAction:=0;
          end
        else
          begin
          flyUpdate(ennemi);
          writeln(ennemi.stats.compteurAction);
          //if ennemi.stats.compteurAction=50 then
            //multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,-2,2,360,1,200,50,'rayon');
          end}
        
      {//pour un ennemi qui esquive puis attaque
      if (ennemi.anim.etat='chase') and (sqrt((ennemi.image.rect.x-joueur.image.rect.x)**2+(ennemi.image.rect.y-joueur.image.rect.y)**2)<100) then
        AIDodge(ennemi,joueur);
      if (ennemi.anim.etat='warp') then
        DodgeUpdate(ennemi);
      if (ennemi.anim.etat='rewarp') and (animFinie(ennemi.anim)) then begin
        CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+40,ennemi.image.rect.y+50,ennemi.image.rect.x+60,ennemi.image.rect.y+50,5,'rayon',obj);
        ajoutObjet(obj,LObjets);
        initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',6,True)
      end}


      //pour un ennemi qui se téléporte 
			if (ennemi.anim.etat='rewarp') and animFinie(ennemi.anim) then
				InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase', 6,True);
			
			if {animFinie(ennemi.anim) and} (ennemi.anim.etat='chase') and (random(200)=0)  then begin
				multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,5,3,360,random(18)*10,'projectile');
        //multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,2,4,360,40,500,50,'rayon');
        mix_playchannel(random(5),mix_loadWav('warp.wav'),0);
				AIFly(ennemi,joueur.image.rect.x,joueur.image.rect.y);
				end;
      if (ennemi.anim.etat='warp') then
        FlyUpdate(ennemi);
			if (ennemi.anim.etat='warp') and (ennemi.anim.currentFrame=ennemi.anim.totalFrames) and (ennemi.stats.compteurAction>50) then
				begin
				AIReWarp(ennemi);
				for j:=1 to 5 do 
          begin
					//multiProjs(TypeObjet(1),2,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,6,5,360,j*20,'projectile');
          //writeln('MultiProjs numéro ',j,'ajouté')
          end
				end;
			end
		else
      if (animFinie(ennemi.anim)) and (ennemi.anim.etat='mort') then
          begin
          supprimeObjet(ennemi);
          //writeln(ennemi.anim.objectname,' détruit')
          end
      else
      begin
			  if not (ennemi.anim.etat='mort') then InitAnimation(ennemi.anim,ennemi.anim.objectName,'mort',4,False);
      end
end;

begin
// EnnemyBasik
//initStatEnnemi('Akr',100,12,4,EnemyBasik);

end.