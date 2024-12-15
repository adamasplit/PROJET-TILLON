unit EnemyLib;

interface
uses
  AnimationSys,
  coeur,
  CollisionSys,
  CombatLib,
  eventSys,
  fichierSys,
  math,
  memgraph,
  SDL2,
  sdl2_mixer,
  SonoSys,
  SysUtils;

const TAILLE_VAGUE=2;
var templatesEnnemis:array[1..MAXENNEMIS] of TObjet;
    ennemis:Array of TOBjet;
//procedure initStatEnnemi(nom:PChar;typeIA_MVT,vie,att,dmg,def,vitesse,w,h,framesA,frames1,frames2,frames3,framesM:Integer;var ennemi:TObjet;wcol,hcol,offx,offy:Integer;nomAttaques:PChar);
procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);
procedure ajoutVague();

implementation

procedure transformation(var ennemi:TObjet;num:Integer); //remplace un ennemi par un autre tout en conservant sa position
var x,y:Integer;
begin
  statsJoueur.bestiaire[ennemi.stats.numero]:=True;
  x:=ennemi.image.rect.x;
  y:=ennemi.image.rect.y;
  sdl_destroytexture(ennemi.image.imgTexture);
  sdl_freeSurface(ennemi.image.imgSurface);
  ennemi:=templatesEnnemis[num];
  ennemi.image.rect.x:=x;
  ennemi.image.rect.y:=y;
  jouerSonEnn(ennemi.anim.objectName+'_apparition');
end;

//supprime un ennemi de la liste
procedure supprimeEnn(var enn:TObjet;j:integer);
var taille,i:Integer;
begin
    if enn.stats.genre=ennemi then
    begin
      taille:=High(ennemis)+1;
      //SDL_DestroyTexture(enn.image.imgtexture);
      //SDL_freeSurface(enn.image.imgSurface);
      for i:=j to taille-2 do 
          if (i<High(ennemis)) then
          begin
              ennemis[i]:=ennemis[i+1];
          end;
      setlength(ennemis,taille-1);
    end
end;

//rajoute une 'vague' d'ennemis à LObjets
procedure ajoutVague();
var i,taille:Integer;
var fini:Boolean;
begin
  //writeln('tentative d"ajout d"une vague , ennemis restants : ',high(ennemis));
  if high(ennemis)<=0 then
    combatFini:=True
  else
    begin
    vagueFinie:=False;
    taille:=high(ennemis);
    fini:=False;
    if (high(LObjets)<taille) and (taille>TAILLE_VAGUE) then
      setlength(LObjets,TAILLE_VAGUE+1);
    if (high(LObjets)<taille) and (taille<=TAILLE_VAGUE) then
      setlength(LObjets,taille+1);
    for i:=1 to TAILLE_VAGUE do
      if not fini then
      begin
        if (high(ennemis)>0) then
          begin
          //writeln('tentative d"ajout d"un ennemi');
          LObjets[i]:=ennemis[taille];
          supprimeEnn(ennemis[taille],taille);
          taille:=taille-1;
          LObjets[i].image.rect.x:=(i-1)*round(600/TAILLE_VAGUE)+180;
          LObjets[i].image.rect.y:=50;
          jouerSonEnn(LObjets[i].anim.objectName+'_apparition');
          if LObjets[i].anim.objectName='dracomage' then
            begin
            fini:=True;
            end;
          if LObjets[i].anim.objectName='Béhémoth' then
            begin
            mix_pauseMusic;
            fini:=True;
            end;
          end;
      end;
    end;
    //writeln('combat fini:',combatFini);
    //writeln('vague ajoutée');
end;

// initialise un ennemi dans TemplatesEnnemis

procedure initStatEnnemi(num:Integer;nom:PChar;typeIA_MVT,vie,att,dmg,def,vitesse,w,h,framesA,frames1,frames2,frames3,framesM:Integer;wcol,hcol,offx,offy:Integer;nomAttaques:PChar);
var ennemi:TObjet;
begin

    //Initialisation de l'affichage
    ennemi.stats.nbframes1:=frames1;
    ennemi.stats.nbframes2:=frames2;
    ennemi.stats.nbframes3:=frames3;
    ennemi.stats.nbFramesApparition:=framesA;
    ennemi.stats.nbframesMort:=framesM;
    ennemi.stats.angle:=0;
    InitAnimation(ennemi.anim,nom,'apparition', ennemi.stats.nbFramesApparition,False);
    //writeln('accès au fichier ',getframePath(ennemi.anim));
    CreateRawImage(ennemi.image,(random(20)+5)*20,0,w,h,getframePath(ennemi.anim));
    //UpdateAnimation(ennemi.anim,ennemi.image);
    

    case num of
      30..38:ennemi.stats.boss:=True
    else ennemi.stats.boss:=False;
    end;

    //Initialisation des caractéristiques
    ennemi.stats.genre:=TypeObjet(1);
    ennemi.stats.vieMax:=vie;
    ennemi.stats.vie:=ennemi.stats.vieMax;
    ennemi.stats.force:=att;
    ennemi.stats.defense:=def;
    ennemi.stats.compteurAction:=0;
    ennemi.stats.vitessePoursuite:=vitesse;
    ennemi.stats.multiplicateurDegat:=1;
    ennemi.stats.typeIA_MVT:=typeIA_MVT;
    ennemi.stats.xcible:=ennemi.image.rect.x;
    ennemi.stats.ycible:=ennemi.image.rect.y;
    ennemi.stats.nomAttaque:=nomAttaques;
    ennemi.stats.degatsContact:=dmg;
    ennemi.stats.cooldown:=0;

    // Initialisation de la boîte de collisions
    ennemi.col.isTrigger := False;
    ennemi.col.estActif := False;
    ennemi.col.dimensions.w := wcol;
    ennemi.col.dimensions.h := hcol;
    ennemi.col.offset.x := offx;
    ennemi.col.offset.y := offy;
    ennemi.col.nom := nom;
    ennemi.anim.estActif := True;
    ennemi.stats.inamovible:=ennemi.stats.boss or ((ennemi.anim.objectname='Béhémoth') or (ennemi.anim.objectName='gardien'));
    ennemi.stats.numero:=num;
    templatesEnnemis[num]:=ennemi;
end;

//permet à un ennemi de se téléporter au hasard
procedure IATeleport(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  randomize();
  ennemi.col.estActif:=False;
  //endroit choisi entre certaines bornes et pas trop près du joueur
  repeat
    xdest:=random(10)*100;
  until (xdest<=800) and (xdest>=200) and (abs(xdest-targetx)>60) and (abs(xdest-ennemi.image.rect.x)>60);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>60) and (abs(ydest-ennemi.image.rect.y)>60);
  InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'warp', ennemi.stats.nbframes2,False);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
  ennemi.stats.compteurAction:=0;
end;

procedure IAReapparition(var ennemi:TObjet);
var alea:Integer;
begin
    //réapparaît à l'endroit cible (change de forme si l'ennemi en question est Akrojs)
    if (ennemi.anim.objectName='Akr') or (ennemi.anim.objectName='Akr2') or (ennemi.anim.objectName='Akr3') then
      begin
      alea:=random(3);
      case alea of
        1:ennemi.anim.objectName:='Akr';
        2:ennemi.anim.objectName:='Akr2';
        0:ennemi.anim.objectName:='Akr3';
        end;
      end;
    InitAnimation(ennemi.anim,ennemi.anim.ObjectName,'rewarp', ennemi.stats.nbframes3,False);
    ennemi.image.rect.x:=ennemi.stats.xcible-ennemi.col.offset.x-(ennemi.image.rect.w div 2);
    ennemi.image.rect.y:=ennemi.stats.ycible-ennemi.col.offset.y-(ennemi.image.rect.h div 2);
    ennemi.col.estActif:=True;
end;

procedure IAVol(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  //fonctionne de façon similaire à IATeleport, sans initialiser l'animation de téléportation
  if ennemi.anim.objectName<>'Spectre' then jouerSonEnn('fly');
  repeat
  xdest:=random(10)*100;
  until (xdest<=800) and (xdest>=200) and (abs(xdest-targetx)>100) and (abs(xdest-ennemi.image.rect.x)>100);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>50) and (abs(ydest-ennemi.image.rect.y)>50);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
end;

procedure FlyUpdate(var ennemi:TObjet;lenteur:Integer);
var distx,disty:Integer;
begin
  //l'ennemi se déplace vers sa cible, à une vitesse proportionnelle à la distance
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);disty:=-(ennemi.image.rect.y-ennemi.stats.ycible);
  ennemi.image.rect.x:=ennemi.image.rect.x + (distx div lenteur);
  ennemi.image.rect.y:=ennemi.image.rect.y + (disty div lenteur);
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
end;

procedure AIDodge(var ennemi:TObjet;target:TObjet);   //l'ennemi se décale vers un mur, selon sa position initiale, pour esquiver
var distx:Integer;
begin
  jouerSonEnn(ennemi.anim.objectName,random(3)+1);
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
  //l'ennemi poursuit sa riposte, voire initie une contre-attaque
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);
  ennemi.image.rect.x:=ennemi.image.rect.x + (distx div 10);
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
  if ennemi.stats.compteurAction>20 then
    initAnimation(ennemi.anim,ennemi.anim.objectName,'strike',ennemi.stats.nbframes3,false);
end;

procedure CrossMoveInit(var ennemi:TObjet;x,y:Integer);
var distx,disty:Integer;
begin

  //choisit un endroit où l'ennemi peut se déplacer en ligne droite (comme la tour aux échecs)
  distx:=-(ennemi.image.rect.x-x);disty:=-(ennemi.image.rect.y-y);
  if sqrt(distx**2+disty**2)>100 then
  if abs(distx)>abs(disty) then
    begin
    if random(2)=0 then 
      begin
      ennemi.stats.ycible:=trouverCentreY(ennemi);
      ennemi.stats.xcible:=200+random(2)*600;
      end
    else
      begin
      ennemi.stats.ycible:=trouverCentreY(ennemi);
      ennemi.stats.xcible:=max(200,x);
      end
    end
  else
    if random(2)=0 then 
      begin
      ennemi.stats.xcible:=trouverCentrex(ennemi);
      ennemi.stats.ycible:=200+random(2)*400;
      end
    else
    begin
    ennemi.stats.xcible:=trouverCentreX(ennemi);
    ennemi.stats.ycible:=y;
    end;
  ennemi.stats.compteurAction:=0;
end;

procedure dashInit(var ennemi:TObjet);
begin
  //permet à un ennemi de foncer de l'autre côté de la salle
  if ennemi.image.rect.x>500 then
    ennemi.stats.xcible:=0
  else
    ennemi.stats.xcible:=1000;
  ennemi.stats.ycible:=trouverCentreY(ennemi);
  JouerSonEnn(ennemi.anim.objectName);
  initAnimation(ennemi.anim,ennemi.anim.objectName,'dash',ennemi.stats.nbframes2,true);
end;

procedure MoveToTarget(var ennemi:TObjet;vitesse:Integer);
var angle:Real;
  distX,distY,y:Integer;
begin
  //l'ennemi se déplace vers sa position cible
  distX:=ennemi.stats.xcible-trouverCentreX(ennemi);
  distY:=ennemi.stats.ycible-trouverCentreY(ennemi);
  ennemi.anim.isFliped:=(distX>0);
  begin
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
    end;
  if (abs(distX)<=vitesse) and (abs(distY)<=vitesse) then
    begin
    ennemi.image.rect.x:=ennemi.stats.xcible;
    ennemi.image.rect.y:=ennemi.stats.ycible;
    end;
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
  end;
end;

procedure AIPathFollow(var ennemi: TObjet; target: TObjet;vitesse:Integer;deplaceX,deplaceY:Boolean);
begin
  //l'ennemi suit le joueur, pas forcément dans toutes les directions
  if deplaceX then
    ennemi.stats.xcible:=trouverCentreX(target)
  else 
    ennemi.stats.xcible:=trouverCentreX(ennemi);
  if deplaceY then
    ennemi.stats.ycible:=trouverCentreY(target)
  else 
    ennemi.stats.ycible:=trouverCentreY(ennemi);
  if (not deplaceX or (abs(ennemi.stats.xcible-trouverCentreX(ennemi))>ennemi.col.dimensions.w div 2+30)) or (not deplaceY or (abs(ennemi.stats.ycible-trouverCentreY(ennemi))>ennemi.col.dimensions.h div 2+40)) then
    moveToTarget(ennemi,vitesse);
  //SDL_setRenderDrawColor(sdlrenderer,255,255,0,255);
  //sdl_renderDrawLINE(sdlrenderer,trouverCentreX(ennemi),trouverCentreY(ennemi),ennemi.stats.xcible,ennemi.stats.ycible);
  ennemi.anim.isFliped:=(trouverCentreX(target)-trouverCentreX(ennemi)>=0);
end;


procedure ActionEnnemi(ennemi:TObjet;x,y:Integer); //permet à un ennemi d'agir (donc d'attaquer)
var obj:TObjet;alea1,alea2,i:Integer;angle:Real;
begin
  if (ennemi.anim.etat='shoot') then
    if (ennemi.anim.objectName='elementaire_eclipse') and (ennemi.stats.compteurAction<20) then
      begin
      if (ennemi.image.rect.x<ennemi.stats.xcible) then
        initJustice(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,200,random(20)*35,x,y,20,150-ennemi.stats.compteurAction,ennemi.stats.nomAttaque )
      else
        initJustice(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,750,random(20)*35,x,y,20,150-ennemi.stats.compteurAction,ennemi.stats.nomAttaque )
      end
    else if (ennemi.stats.compteurAction>10) and (ennemi.stats.compteurAction<15) then 
      begin
        if (ennemi.image.rect.x<ennemi.stats.xcible) then
                CreerRayon(typeobjet(1),2,ennemi.stats.force,1,false,trouverCentreX(ennemi),trouverCentreY(ennemi),1200,80,ennemi.image.rect.x+400,trouverCentreY(ennemi),(random(5)-3)*3,10,100,ennemi.stats.nomAttaque,obj)
              else
                CreerRayon(typeobjet(1),2,ennemi.stats.force,1,false,trouverCentreX(ennemi),trouverCentreY(ennemi),1200,80,ennemi.image.rect.x-400,trouverCentreY(ennemi),(random(5)-3)*3,10,100,ennemi.stats.nomAttaque,obj);
              ajoutObjet(obj);
      end;
  case ennemi.stats.typeIA_MVT of
    0: if(ennemi.stats.compteurAction mod 100 = 50) then
      begin
        LObjets[0].stats.vitesse:=round(sqrt((ennemi.stats.xcible-ennemi.image.rect.x)**2+(ennemi.stats.ycible-ennemi.image.rect.y)**2)/50);
      end;
    2: if (ennemi.anim.currentFrame=4) and (ennemi.anim.etat='cast') then
      begin
      if ennemi.anim.objectName='mage_noir' then 
        begin
        case random(3) of
        0:begin
          end;
        1:for i:=1 to 5 do begin
          creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi),80,80,4,x,y-150+i*50,'flamme',obj);
          ajoutObjet(obj)
          end;
        2:begin
          alea2:=random(10)*20-100;
          if random(2)=0 then
            creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,x-100,y+alea2,200,100,x+200,y+alea2,0,30,80,'eclair',obj)
          else
            creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,x+100,y+alea2,200,100,x-200,y+alea2,0,30,80,'eclair',obj);
          ajoutObjet(obj);
          end
        end
        end
      else
      multiProjs(typeObjet(1),1,1,1,ennemi.image.rect.x+96,ennemi.image.rect.y+96,100,100,3,10,360,0,ennemi.stats.nomAttaque);
      end;
    3: if (ennemi.anim.etat='dash') and (ennemi.stats.compteurAction>50) and (ennemi.stats.compteurAction mod 45=0) and (ennemi.anim.objectName='undrixel') then
      begin
      //multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,0,10,360,0,10,80,'rayon');
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,100,100,5,4,360,(ennemi.stats.xcible-ennemi.image.rect.x),ennemi.stats.nomAttaque);
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,100,100,5,4,360,(ennemi.stats.xcible-ennemi.image.rect.x) div 2,'kamui');
      end;
    4:if (ennemi.anim.etat='warp') and (ennemi.stats.compteurAction=1) then 
      if ennemi.anim.objectName='elementaire_spectral' then
        begin
        CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi),trouverCentreY(ennemi),1200,200,x,y,0,50,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end
      else
      if ennemi.anim.objectName='Archimage' then
        begin
        initAngle(x-trouverCentreX(ennemi),y-trouverCentreY(ennemi),angle);
        multiProjs(TypeObjet(1),4,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi),100,100,5,4,360,angle,ennemi.stats.nomAttaque);
        initAngle(x-ennemi.stats.xcible,y-ennemi.stats.ycible,angle);
        multiProjs(TypeObjet(1),4,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.stats.xcible,ennemi.stats.ycible,100,100,5,4,360,angle,ennemi.stats.nomAttaque);
        end
      else
        multiProjs(TypeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi),100,100,5,3,360,random(18)*10,ennemi.stats.nomAttaque);
    5: begin
      if (ennemi.anim.etat='chase') and (ennemi.stats.compteurAction mod 50 = 0) and (ennemi.anim.objectName='liche') then
        multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+(ennemi.image.rect.w div 2),ennemi.image.rect.y+(ennemi.image.rect.h div 2),100,100,5,3,360,ennemi.stats.compteurAction/180*pi,'kamui');
      if (ennemi.anim.etat='strike')then
      begin
      ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
      if (ennemi.anim.currentFrame=6) and (sdl_getTicks-ennemi.anim.lastUpdateTime<15) then
        if ennemi.anim.objectName='liche' then
          for i:=1 to 5 do
          begin
          alea2:=random(20)*10-100+y;
          if (ennemi.image.rect.x<ennemi.stats.xcible) then
            CreerRayon(typeobjet(1),2,1,1,false,ennemi.image.rect.x+40,alea2,1200,100,ennemi.image.rect.x+60,alea2,0,10,ennemi.stats.vie,ennemi.stats.nomAttaque,obj)
          else
            CreerRayon(typeobjet(1),2,1,1,false,ennemi.image.rect.x+40,alea2,1200,100,ennemi.image.rect.x-60,alea2,0,10,ennemi.stats.vie,ennemi.stats.nomAttaque,obj);
          ajoutObjet(obj);
          end
        else
          begin
          if (ennemi.image.rect.x<ennemi.stats.xcible) then
            CreerRayon(typeobjet(1),2,1,1,false,ennemi.image.rect.x+40,ennemi.image.rect.y+50,1200,100,ennemi.image.rect.x+60,ennemi.image.rect.y+50,0,10,ennemi.stats.vie,ennemi.stats.nomAttaque,obj)
          else
            CreerRayon(typeobjet(1),2,1,1,false,ennemi.image.rect.x+40,ennemi.image.rect.y+50,1200,100,ennemi.image.rect.x-60,ennemi.image.rect.y+50,0,10,ennemi.stats.vie,ennemi.stats.nomAttaque,obj);
          ajoutObjet(obj);
          end;
      end;
      end;
    6:
      begin
      if (ennemi.stats.compteurAction mod 60 = 0) and (ennemi.stats.compteurAction>0) and (ennemi.stats.compteurAction<200) then
        begin
        creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+64,ennemi.image.rect.y+64,100,100,4,x,y,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
      if (ennemi.stats.compteurAction=100) and (ennemi.anim.objectName='expurgateur') then
        multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,1200,120,0,4,360,0,10,100,'rayon');
      end;
    7:if (((ennemi.stats.vie<ennemi.stats.vieMax div 4) and (ennemi.stats.compteurAction mod 20 = 0)) or (ennemi.stats.vie>=ennemi.stats.vieMax div 4) and (ennemi.stats.compteurAction mod 50 = 0)) and (ennemi.anim.etat='fly') then begin
        creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+96+random(192),ennemi.image.rect.y+64+random(128),200,100,4,x,y,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    8:if (ennemi.anim.etat='cast') then
      if (ennemi.anim.objectName='mage_rouge') then
        begin
          if (ennemi.stats.compteurAction mod 50 = 0) then
          begin
          CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi)+60,trouverCentreY(ennemi),1000,200,x-100+random(20)*10,y,0,10,50,ennemi.stats.nomAttaque,obj);
          ajoutObjet(obj);
          end
        end
      else
        if (ennemi.stats.compteurAction <320) and (ennemi.stats.compteurAction mod 4 = 0) then
        begin
        creerBoule(typeobjet(1),0,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi),60,60,3,x-128+random(64)*4,y-128+random(64)*4,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    10:begin
        if (ennemi.anim.etat='tir') and (ennemi.anim.currentFrame=20) and (ennemi.stats.compteurAction<=601) then
        begin
        CreerRayon(typeobjet(1),80,ennemi.stats.force,1,false,ennemi.image.rect.x+250,ennemi.image.rect.y+350,1200,300,ennemi.image.rect.x-60,ennemi.image.rect.y+350,-(y-(ennemi.image.rect.y+350))/280,100,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
        if (ennemi.anim.etat='chase') and (ennemi.anim.currentFrame mod 5 =2) and (ennemi.anim.currentFrame<>2) then
          begin
          creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+200,ennemi.image.rect.y+340,64,64,5,x+32,y+0+((ennemi.anim.lastUpdateTime-sdl_getTicks)),'projRykor',obj);
          ajoutObjet(obj)
          end
        end;
    11:begin
      if (ennemi.anim.etat='cast') and (ennemi.stats.compteurAction mod 5=0) and (ennemi.stats.compteurAction<100) then
        begin
        alea1:=random(20);
        CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi),ennemi.image.rect.y,1000,200,ennemi.stats.xcible,ennemi.stats.ycible-100+alea1*10,-1+alea1/10,10,50,'rayon',obj);
        ajoutObjet(obj);
        end;
      if random(80)=0 then begin
        alea1:=random(100)*10+200;alea2:=random(100)*10;
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,alea1,alea2,400,200,alea1,alea2-100,0,100,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
      end;
    12:if (ennemi.anim.etat='cast') and (ennemi.stats.compteurAction mod 30=0) then begin
        if (ennemi.anim.objectName='invocateur') then
          begin
          if ennemi.stats.compteurAction mod 90 = 0 then
            ajoutObjet(templatesEnnemis[17])
          end
        else 
          if (ennemi.anim.objectName='Spectre') then
          begin
          if (ennemi.stats.compteurAction mod 20=0) then
            multiLasers(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),ennemi.image.rect.y+100,200,100,1,8,360,90,120,50,ennemi.stats.nomAttaque);
          for i:=1 to random(10) do
            begin
            alea1:=random(30)*10*i-180*i;alea2:=random(100)*i-50*i;
            creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,x+alea1-100,y+alea2,300,200,x+alea1+100,y+alea2,0,50,100,ennemi.stats.nomAttaque,obj);
            ajoutObjet(obj);
            end
          end
        else
          begin
          alea1:=random(30)*10-180;alea2:=random(100)-300;
          creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,x+alea1,y+alea2-100,400,200,x+alea1,y+alea2,0,50,100,ennemi.stats.nomAttaque,obj);
          ajoutObjet(obj);
          end;
        end;
    13:begin
      if (ennemi.anim.etat='charge') and (ennemi.stats.compteurAction mod 10=0) then 
        begin
        alea1:=random(180);
        creerRayon(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,round(x+cos(alea1)*100),50+round(y+sin(alea1)*100),400,200,350+round(x-cos(alea1)*100),round(y-sin(alea1)*100),0,50,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
        if ((ennemi.anim.etat='strike') and (ennemi.stats.compteurAction<15)) then//or ((ennemi.anim.etat='dodge') and (ennemi.stats.compteurAction>40)) then
          begin 
          creerRayon(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,ennemi.image.rect.x+(ennemi.image.rect.w div 2),ennemi.image.rect.y+(ennemi.image.rect.h div 2),1200,200,x,y,0,10,100-ennemi.anim.currentFrame*10,'rayonLeo',obj);
          ajoutObjet(obj);
          end;
        end;
    14:begin
    if (random(30)=0) and (ennemi.anim.etat='rage') then begin
        alea1:=random(100)*10;alea2:=random(100)*10;
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,alea1,alea2,400,200,alea1,alea2-100,0,100,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    if (ennemi.anim.etat='cast') and (ennemi.anim.currentFrame=2) and (ennemi.stats.compteurAction<3) then
      begin
      XXIII(typeObjet(1),ennemi.stats,ennemi.image.rect.x,ennemi.image.rect.y,x,y,110);
      end;
      end;
    15:begin
      if (ennemi.anim.etat='float') and (ennemi.stats.compteurAction mod 20=0) then
        begin
        CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi),trouverCentreY(ennemi),1200,100,x,y,0,10,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      end;
    16:begin
      if (ennemi.stats.compteurAction mod 160 = 0) then
        begin
        jouerSonEnn('gardien',random(3)+1);
        multiLasers(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,x,y+50,150,60,0,8,360,0,10,200,'pic_terre');
        end;
      if (ennemi.stats.compteurAction mod 80 = 0) then
        begin
        creerRayon(typeObjet(1),4,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,0,ennemi.stats.compteurAction div 2,300,150,1500,ennemi.stats.compteurAction div 2,0,30,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        creerRayon(typeObjet(1),4,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,1080,720-ennemi.stats.compteurAction div 2,300,150,200,720-ennemi.stats.compteurAction div 2,0,30,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      if (ennemi.stats.compteurAction mod 50 =0) then
        begin
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,(random(10))*100,750,300,150,x,y,0,30,80,'pic_terre',obj);
        ajoutObjet(obj);
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,(random(10))*100,-30,300,150,x,y,0,30,80,'pic_terre',obj);
        ajoutObjet(obj);
        end;
      end;
    17:begin
      if (ennemi.anim.etat='revolution') and (ennemi.anim.currentFrame=6) and (ennemi.stats.compteurAction<2) then
        begin
        jouerSonEnn('Geist (2)');
        multiProjs(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi),100,100,7,10,360,ennemi.stats.compteurAction*10,'onde');
        end;
      
      if (ennemi.anim.etat='strike') and (ennemi.anim.currentFrame=4) and (ennemi.stats.compteurAction<5) then
        begin
        if ennemi.stats.compteurAction=2 then jouerSonEnn('Geist (3)');
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi),trouverCentreY(ennemi),1200,200,random(6)*100+200,y,0,30,80,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      if (ennemi.anim.etat='dodge') and (ennemi.stats.compteurAction>100) and (ennemi.stats.compteurAction mod 30 < 5) then
        begin
        creerBoule(typeobjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi),50,50,4,x,y,'onde',obj);
        ajoutObjet(obj)
        end;
      end;
    18:begin
      if (ennemi.anim.etat='strike') and (ennemi.anim.currentFrame>=10) and (ennemi.stats.compteurAction mod 10 = 0) then
        begin
        initAngle(ennemi.stats.xcible-trouverCentreX(ennemi),ennemi.stats.ycible-trouverCentreY(ennemi),angle);
        if ennemi.anim.isFliped then
          begin
          alea1:=trouverCentreX(ennemi)+round(9*ennemi.stats.compteurAction*cos(angle))+100;
          alea2:=trouverCentreY(ennemi)+round(9*ennemi.stats.compteurAction*sin(angle))+100;
          end
        else
          begin
          alea1:=trouverCentreX(ennemi)-round(9*ennemi.stats.compteurAction*cos(angle));
          alea2:=trouverCentreY(ennemi)-round(9*ennemi.stats.compteurAction*sin(angle))+100;
          end;
        
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,alea1,alea2,300,150,alea1,alea2-50,0,50,100{-ennemi.stats.compteurAction},ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      end;
    19:begin
      if (ennemi.anim.etat='cast') and (ennemi.stats.compteurAction mod 60 = 59) then
        multiProjs(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi)-50,trouverCentreY(ennemi)-150,180,180,3,10,360,ennemi.stats.compteurAction*10,'flamme');
      if (ennemi.anim.etat='rage') and (ennemi.stats.compteurAction mod 14=0) then
        begin
        if random(2)=0 then
          begin
          alea1:=1080*random(2);
          alea2:=100*random(8);
          end
        else
          begin
          alea2:=-80+800*random(2);
          alea1:=random(10)*100;
          end;
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,alea1,alea2,1600,150,x,y,0,5,150,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
      end;
    20:
      begin
      if (ennemi.anim.etat='cast') and (ennemi.anim.currentFrame>=15) and (ennemi.anim.currentFrame<=18) then
        begin
        if ennemi.anim.isFliped then
          CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi)+200,ennemi.image.rect.y+100,1000,100,ennemi.stats.xcible-500+random(20)*50,ennemi.stats.ycible,0,10,50,'tentacule',obj)
        else
          CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,false,trouverCentreX(ennemi)-200,ennemi.image.rect.y+100,1000,100,ennemi.stats.xcible-500+random(20)*50,ennemi.stats.ycible,0,10,50,'tentacule',obj);
        ajoutObjet(obj);
        end;
      if (ennemi.anim.etat='peek') and (ennemi.anim.currentFrame=7) then
        begin
        creerBoule(typeobjet(1),0,ennemi.stats.force,ennemi.stats.multiplicateurDegat,trouverCentreX(ennemi),trouverCentreY(ennemi)+100,60,60,7,x-128+random(64)*4,y-128+random(64)*4,'miasme',obj);
        ajoutObjet(obj)
        end;
      end;
    end;
end;

procedure DeplacementEnnemi(var ennemi:TObjet;joueur:TObjet); //déplace un ennemi 
var i:Integer;rect1,rect2:TSDL_REct;trouve:Boolean;
begin
  if (random(100)=0) and (ennemi.anim.objectName[0]+ennemi.anim.objectName[1]+ennemi.anim.objectName[2]+ennemi.anim.objectName[3]+ennemi.anim.objectName[4]+ennemi.anim.objectName[5]+ennemi.anim.objectName[6]+ennemi.anim.objectName[7]+ennemi.anim.objectName[8]+ennemi.anim.objectName[9]+ennemi.anim.objectName[10]='elementaire') then
    jouerSonEnn('elementaires',random(5)+1);
  case ennemi.stats.typeIA_MVT of
      0:
        begin //ennemi qui ne fait que suivre le joueur
        AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,true,true);
        flyUpdate(ennemi,100);
        if ennemi.stats.compteurAction>(400*ennemi.stats.vie/ennemi.stats.vieMax) then
          ennemi.stats.compteurAction:=0
        else ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1
        end;
      1: //ennemi qui suit le joueur mais s'arrête pour attaquer
        begin
        if ennemi.anim.etat='chase' then
          begin
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,true,true);
          if ennemi.stats.compteurAction>300 then
            begin
            jouerSonEnn(ennemi.anim.objectName,random(3)+1);
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
      2://ennemi qui suit le joueur mais s'arrête pour charger puis lancer un sort
        begin
        if ennemi.anim.etat='chase' then
          begin
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,true,true);
          if (ennemi.anim.objectName='dracomage') and (ennemi.stats.vie<100) then ennemi.stats.vitessePoursuite:=2;
          if ennemi.stats.compteurAction>300 then
            begin
            InitAnimation(ennemi.anim,ennemi.anim.objectName,'charge',ennemi.stats.nbFrames2,True);
            ennemi.stats.compteurAction:=0;
            end
          else ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1
          end;
        if animFinie(ennemi.anim) and (ennemi.anim.etat='charge') then
          begin
          jouerSonEnn(ennemi.anim.objectName,random(5)+1);
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,False);
          end;
        if animFinie(ennemi.anim) and (ennemi.anim.etat='cast') then
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
        ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
        end;
      3: //ennemi qui dash horizontalement
        begin
        if (ennemi.anim.etat='chase') then
          begin
          //ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,false,true);
          if abs(trouverCentreY(joueur)-trouverCentreY(ennemi))<50 then
            begin
            dashInit(ennemi);
            ennemi.stats.compteurAction:=0;
            end
          end;
        if (ennemi.anim.etat='dash') then
          begin
          moveToTarget(ennemi,10);
          if (ennemi.stats.compteurAction>100) and (ennemi.anim.objectName='undrixel') then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'superdash',2,true);
            ennemi.col.estActif:=False
            end;
          end;
        if (ennemi.anim.etat='superdash') then
          begin
          movetoTarget(ennemi,30);
          ennemi.col.estActif:=False
          end;
        if ((ennemi.anim.etat='dash') or (ennemi.anim.etat='superdash')) and (pseudoColMurs(ennemi)) then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,true);
            ennemi.col.estActif:=True;
            end;
        end;
        
      4: //pour un ennemi qui se téléporte 
        begin
          if ennemi.anim.etat='chase' then
            AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,true,true);
          if (ennemi.anim.etat='rewarp') and animFinie(ennemi.anim) then
            InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase', ennemi.stats.nbFrames1,True);
          if (animFinie(ennemi.anim) and (ennemi.anim.etat='chase') and (random(15)=0)) or ((ennemi.anim.objectName='Archimage') and (ennemi.stats.compteurAction>70))  then 
            begin
              jouerSonEnn(ennemi.anim.objectName);
              ennemi.stats.compteurAction:=0;
              IATeleport(ennemi,joueur.image.rect.x,joueur.image.rect.y);
            end;
          if (ennemi.anim.etat='warp') then
            ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if (ennemi.anim.etat='warp') and (ennemi.anim.currentFrame=ennemi.anim.totalFrames) and (ennemi.stats.compteurAction>50) then
            begin
            IAReapparition(ennemi);
            end
        end;
        
      //pour un ennemi qui esquive puis attaque
      5:begin
        if ennemi.anim.etat='chase' then
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,true,true);
        if (ennemi.anim.etat='chase') and (sqrt((ennemi.image.rect.x-joueur.image.rect.x)**2+(ennemi.image.rect.y-joueur.image.rect.y)**2)<120) then
          AIDodge(ennemi,joueur);
        if (ennemi.anim.etat='dodge') then
          DodgeUpdate(ennemi);
        if ennemi.anim.etat='strike' then
          begin
          ennemi.stats.xcible:=joueur.image.rect.x;
          ennemi.col.estActif:=True;
          end;
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
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'spread',ennemi.stats.nbFrames2,False);
          ennemi.stats.vitessePoursuite:=ennemi.stats.defense;
          ennemi.stats.defense:=0;
          end;
        if (ennemi.anim.etat='chase') and (random(50)=1) then
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        if animFinie(ennemi.anim) and (ennemi.anim.etat='spread') then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'fly',ennemi.stats.nbFrames3,True);
          ennemi.stats.compteurAction:=0;
          end;
        if ennemi.anim.etat='fly' then
          begin
          if ((ennemi.stats.compteurAction mod 20=0) and (ennemi.stats.vie<ennemi.stats.vieMax div 4)) or (ennemi.stats.compteurAction mod 60=0) then
            begin
              IAVol(ennemi,joueur.image.rect.x,joueur.image.rect.y)
            end;
          if ennemi.stats.vie>ennemi.stats.vieMax div 4 then
            flyUpdate(ennemi,15)
          else
            flyUpdate(ennemi,2);
          if ennemi.stats.compteurAction>300 then
            begin
            ennemi.stats.defense:=ennemi.stats.vitessePoursuite;
            initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
            ennemi.stats.compteurAction:=0;
            end;
          end
        end;
      8://ennemi qui saute d'endroit en endroit
        begin
        if ennemi.anim.etat='chase' then
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,true,true);
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        if ennemi.stats.compteurAction mod 100=0 then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'jump',ennemi.stats.nbFrames2,True);
          randomize();
          ennemi.stats.xcible:=ennemi.image.rect.x+12*(random(20)-10);
          ennemi.stats.ycible:=ennemi.image.rect.y+12*(random(20)-10);
          end;
        if ennemi.anim.etat='jump' then
          begin
          //ennemi.anim.isFliped:=(ennemi.stats.xcible<ennemi.image.rect.x);
          if ennemi.stats.compteurAction mod 100=50 then
            initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,true)
          else
            flyUpdate(ennemi,20);
          end;
        if (ennemi.stats.compteurAction>300) and not (ennemi.anim.etat='cast') then
          initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,true);
        if (ennemi.anim.etat='cast') and (animFinie(ennemi.anim)) and (random(2)=0) then
          begin
          ennemi.stats.compteurAction:=0;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          end;
          ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
        end;
      10:begin
        if ennemi.anim.etat='chase' then
          begin
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if ennemi.stats.compteurAction>600 then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'tir',ennemi.stats.nbFrames2,False);
            ennemi.stats.compteurAction:=600
            end;
          end;
        if (ennemi.anim.etat='tir') and (ennemi.anim.currentFrame=10) then
          jouerSonEff('rykor');
        if (ennemi.anim.etat='tir') and (ennemi.stats.compteurAction<=601) and (ennemi.anim.currentFrame=20) then
          begin
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          end;
        if (ennemi.anim.etat='tir') and (animFinie(ennemi.anim)) then
          begin
          ennemi.stats.compteurAction:=0;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          end;
        end;
      11:begin //ennemi qui peut se déplacer vers le joueur ou s'en éloigner, ou encore lancer une attaque
        if (ennemi.anim.etat='chase') then
          flyUpdate(ennemi,20);
        if (ennemi.anim.etat='chase') and (random(100)=0) then
          if random(2)=0 then
              initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,False)
            else
              initAnimation(ennemi.anim,ennemi.anim.objectName,'walk',ennemi.stats.nbFrames2,True);
        if (ennemi.anim.etat='walk') then
          begin
          AIPathFollow(ennemi,joueur,2,True,True);
          if (random(100)=0) then
            if random(2)=0 then
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
              IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
              end
            else
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,false);
              ennemi.stats.compteurAction:=0;
              end;
          end;
        if (ennemi.anim.etat='cast') then
          begin
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if ennemi.stats.compteurAction>200 then
            if random(2)=0 then
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
              IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
              end
            else
              initAnimation(ennemi.anim,ennemi.anim.objectName,'walk',ennemi.stats.nbFrames2,True)
          end;
        ennemi.anim.isFliped:=(ennemi.stats.xcible>trouverCentreX(ennemi));
        end;
      12:begin //ennemi qui s'arrête pour lancer un sort à la position du joueur
        ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        ennemi.anim.isFliped:=(ennemi.stats.xcible>trouverCentreX(ennemi));
        if ennemi.anim.etat='chase' then
          begin
          if (ennemi.anim.objectName='Spectre') then
            moveToTarget(ennemi,ennemi.stats.vitessePoursuite)
          else
            AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
          if (ennemi.anim.objectName='Spectre') and (ennemi.stats.compteurAction mod 100=0) then 
            IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
          if (ennemi.stats.compteurAction>300) then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames2,True);
            end;
          end;
        
        if (ennemi.stats.compteurAction>400) and (animFinie(ennemi.anim)) then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          ennemi.stats.compteurAction:=0;
          end
        end;
      13:begin //pour Leo (qui peut esquiver+contrer, ou charger une attaque)
        ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
        if (ennemi.anim.etat='chase') or (ennemi.anim.etat='charge') then
          ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
        if ennemi.anim.etat='chase' then
          begin
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if ennemi.stats.compteurAction>250 then
            initAnimation(ennemi.anim,ennemi.anim.objectName,'charge',7,True);
          if ennemi.stats.compteurAction mod 10=0 then
            begin
            rect1.x:=ennemi.image.rect.x-50;
            rect1.y:=ennemi.image.rect.y;
            rect1.w:=ennemi.image.rect.w+100;
            rect1.h:=ennemi.image.rect.h+50;
            for i:=0 to high(LObjets) do
              begin
              rect2:=getcollisionrect(LObjets[i]);
              if isAttack(LObjets[i]) and (LObjets[i].stats.origine=TypeObjet(0)) and CheckAABB(rect1,rect2) then
                begin
                initAnimation(ennemi.anim,ennemi.anim.objectName,'dodge',4,True);
                ennemi.stats.compteurAction:=0;
                ennemi.stats.xcible:=ennemi.image.rect.x+round(300*sin(LObjets[i].stats.angle));
                ennemi.stats.ycible:=ennemi.image.rect.y+round(300*cos(LObjets[i].stats.angle));
                end;
              end;
            end;
          end;
        if ennemi.anim.etat='dodge' then
          begin
          
          flyUpdate(ennemi,4);
          ennemi.col.estActif:=False;
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if ennemi.stats.compteurAction=10 then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'strike',10,False)
            end;
          if ennemi.stats.compteurAction>50 then
            initAnimation(ennemi.anim,ennemi.anim.objectName,'land',3,False)
          end
        else ennemi.col.estActif:=True;
        if (ennemi.anim.etat='strike') and (ennemi.stats.compteurAction<15) then
          begin
          ennemi.stats.ycible:=ennemi.image.rect.y+round(1.5*(joueur.image.rect.y-(ennemi.image.rect.y+ennemi.col.offset.y+(ennemi.col.dimensions.h div 2))));
          ennemi.stats.xcible:=ennemi.image.rect.x+round(1.5*(joueur.image.rect.x-(ennemi.image.rect.x+ennemi.col.offset.x+(ennemi.col.dimensions.w div 2))));
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          end;
        if (ennemi.anim.etat='strike') and animFinie(ennemi.anim) then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'dodge',4,True);
          ennemi.stats.compteurAction:=15;
          jouerSonEff('epee ('+intToSTr(random(4)+1)+')');
          end;

        if (ennemi.anim.etat='charge') then
          begin
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          if (ennemi.stats.compteurAction>300) then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
            ennemi.stats.compteurAction:=0;
            end;
          end;
        if (ennemi.anim.etat='land') and animFinie(ennemi.anim) then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          ennemi.stats.compteurAction:=0;
          end;
        end;
      14:begin //Leo en transe
        ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
        if (ennemi.anim.etat='cast') and (ennemi.anim.currentFrame=2) and (ennemi.stats.compteurAction<3) then
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        if ennemi.anim.etat='chase' then 
          begin
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
          ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
          end;
        if (ennemi.anim.etat='chase') and (random((150+ennemi.stats.vie))=0) then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'rage',ennemi.stats.nbFrames2,True);
          jouerSonEnn(ennemi.anim.objectName);
          end;
        if (ennemi.anim.etat='rage') and (animFinie(ennemi.anim)) and (random(10)=0) then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          flyUpdate(ennemi,4);
          end;
        if ennemi.stats.compteurAction>200 then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,False);
          ennemi.stats.compteurAction:=1
          end;
        if (ennemi.anim.etat='cast') and (animFinie(ennemi.anim)) then
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
        end;
        15:begin //ennemi qui soigne ses alliés, puis se bat s'il est seul
          if (ennemi.anim.etat='float') then
            begin
            AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
            ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
            end;
          if (ennemi.anim.etat='chase') then
            begin
            ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
            if (ennemi.stats.compteurAction>250) then
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'heal',ennemi.stats.nbFrames2,True);
              ennemi.stats.compteurAction:=0;
              end;
            end;
          if (ennemi.anim.etat='heal') and (ennemi.stats.compteurAction<50) then
            begin
            ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
            if ennemi.stats.compteurAction mod 20 = 0 then
            begin
              trouve:=False;
              //s'il ne reste aucun allié à soigner, l'ennemi change de comportement
              for i:=1 to high(lobjets) do
                if (lobjets[i].stats.genre=typeObjet(1)) and (LObjets[i].anim.etat<>'mort') then
                  begin
                  //SDL_setRenderDrawColor(sdlRenderer,0,255,0,255);
                  sdl_renderdrawline(sdlRenderer,trouverCentreX(ennemi),trouverCentreY(ennemi),trouverCentreX(LObjets[i]),trouverCentreY(LObjets[i]));
                  if LObjets[i].stats.vie<LObjets[i].stats.vieMax then
                    lObjets[i].stats.vie:=LObjets[i].stats.vie+ennemi.stats.force;
                  if (LObjets[i].stats.indice<>ennemi.stats.indice) then trouve:=True;
                  end;
              if not trouve then
                initAnimation(ennemi.anim,ennemi.anim.objectName,'float',ennemi.stats.nbframes3,True);
              end;
            end
          else
            if ennemi.anim.etat='heal' then
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
              ennemi.stats.compteurAction:=0;
              end;
          end;
        16:begin //Boss : Le gardien
          
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,False);
          ennemi.anim.isFliped:=False;
          if (ennemi.stats.compteurAction>1600) then
            ennemi.stats.compteurAction:=0;
          end;
        17:begin
          if ennemi.anim.etat='chase' then
            begin
            AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
            if sqrt((trouverCentreX(joueur)-trouverCentreX(ennemi))**2+(trouverCentreY(joueur)-trouverCentreY(ennemi))**2)<150 then
              begin
              jouerSonEnn('Geist (1)');
              initAnimation(ennemi.anim,ennemi.anim.objectName,'revolution',9,False);
              ennemi.stats.compteurAction:=0;
              end;
            if ennemi.stats.compteurAction mod 20 = 0 then
              begin
              rect1.x:=trouverCentreX(ennemi)-100;
              rect1.y:=trouverCentreX(ennemi)-100;
              rect1.w:=200;
              rect1.h:=200;
              for i:=0 to high(LObjets) do
                begin
                rect2:=getcollisionrect(LObjets[i]);
                if isAttack(LObjets[i]) and (LObjets[i].stats.origine=TypeObjet(0)) and CheckAABB(rect1,rect2) then
                  begin
                  initAnimation(ennemi.anim,ennemi.anim.objectName,'dodge',3,True);
                  ennemi.stats.compteurAction:=100;
                  IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur))
                  end;
                end;
              end;
            end;
          if (ennemi.anim.etat='revolution') then
            begin
            if ennemi.anim.currentFrame=6 then
              ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
            if animFinie(ennemi.anim) then
              begin
              IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
              initAnimation(ennemi.anim,ennemi.anim.objectName,'dodge',ennemi.stats.nbFrames2,True);
              ennemi.stats.compteurAction:=0;
              end;
            end;
          if (ennemi.anim.etat='dodge') then
            begin
            flyUpdate(ennemi,10);
            if (ennemi.stats.compteurAction>30) and (ennemi.stats.compteurAction<100) then
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'strike',ennemi.stats.nbFrames3,False);
              ennemi.stats.compteurAction:=0;
              end;
            if (ennemi.stats.compteurAction>100) and (ennemi.stats.compteurAction mod 20 = 10) then
              IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
            if (ennemi.stats.compteurAction>200) then
              begin
              initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
              ennemi.stats.compteurAction:=0;
              end;
            end;
          if (ennemi.anim.etat='strike') then
            begin
            ennemi.anim.isFliped:=(trouverCentreX(joueur)>trouverCentreX(ennemi));
            if ennemi.anim.currentFrame=4 then
              ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
            if animFinie(ennemi.anim) then
              initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
            end;
          end;
    18: begin //Boss : Le geôlier
    ennemi.anim.isFliped:=(ennemi.Stats.xcible>trouverCentreX(ennemi));
      if ennemi.anim.etat='chase' then
        begin
        ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        ennemi.stats.degatsContact:=0;
        if ennemi.stats.compteurAction>100 then
          begin
          ennemi.stats.compteurAction:=0;
          jouerSonEnn('geolier',random(5)+1);
          if random(2)=0 then
            begin
            ennemi.stats.xcible:=trouverCentreX(joueur);
            ennemi.stats.ycible:=trouverCentreY(joueur);
            initAnimation(ennemi.anim,ennemi.anim.objectName,'strike',ennemi.stats.nbFrames2,False)
            end
          else
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'dash',ennemi.stats.nbFrames3,False);
            ennemi.stats.degatsContact:=25;
            ennemi.stats.xcible:=trouverCentreX(joueur);
            ennemi.stats.ycible:=trouverCentreY(joueur);
            end;
          end;
        end;
      if (ennemi.anim.etat='dash') then
        moveToTarget(ennemi,10);
      if (ennemi.anim.etat='strike') and (ennemi.anim.currentFrame>=10) then
        ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
      if animFinie(ennemi.anim) and ((ennemi.anim.etat='strike') or (ennemi.anim.etat='dash')) then
        begin
        initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
        ennemi.stats.degatsContact:=0;
        end;
      end;
    19:begin //Geôlier (phase 2)
      if (ennemi.anim.etat='chase') then
        begin
        AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
        if ennemi.stats.compteurAction>100 then
          begin
          jouerSonEnn('geolier2',random(3)+1);
          ennemi.stats.compteurAction:=0;
          if random(2)=0 then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'rage',ennemi.stats.nbFrames2,False);
            end
          else
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,False);
            end;
          end;
        end;
      if (ennemi.anim.etat='cast') or (ennemi.anim.etat='rage') then
        begin
        ennemi.anim.isFliped:=(trouverCentreX(joueur)>trouverCentreX(ennemi));
        ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        if ennemi.stats.compteurAction>100 then
          begin
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          ennemi.stats.compteurAction:=0;
          end;
        end;
      end;
    20:begin
      ennemi.col.estActif:=False;
      if ennemi.anim.etat='chase' then
        begin
        ennemi.col.estActif:=True;
        AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
        if ennemi.stats.compteurAction>200 then
          if random(ennemi.stats.vieMax)<=ennemi.stats.vie then 
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',25,False);
            ennemi.stats.compteurAction:=0;
            end
          else
            begin
            IATeleport(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
            ennemi.stats.compteurAction:=0;
            ennemi.col.estActif:=False;
            end;
        end;
      if (ennemi.anim.etat='warp') and animFinie(ennemi.anim) then
        initAnimation(ennemi.anim,ennemi.anim.objectName,'peek',13,False);
      if (ennemi.anim.etat='peek') then
        if ennemi.anim.currentFrame<5 then ennemi.stats.xcible:=trouverCentreX(joueur);
      if (ennemi.anim.etat='peek') and animFinie(ennemi.anim) then
        if random(4)=0 then
          initAnimation(ennemi.anim,ennemi.anim.objectName,'rewarp',14,False)
        else
          begin
          ennemi.col.estActif:=False;
          IAVol(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
          ennemi.image.rect.x:=ennemi.stats.xcible;ennemi.image.rect.y:=ennemi.stats.ycible;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'peek',13,False);
          end;
      if (ennemi.anim.etat='cast') then
        ennemi.col.estActif:=True;
      if (ennemi.anim.etat='cast') and (ennemi.anim.currentFrame>=15) and (ennemi.anim.currentFrame<=18) then
        ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
      if (ennemi.anim.etat='cast') and animFinie(ennemi.anim) then
        initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbframes1,True);
      if (ennemi.anim.etat='rewarp') and animFinie(ennemi.anim) then
        begin
        initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbframes1,True);
        end;
      if (ennemi.anim.etat='cast') or (ennemi.anim.etat='peek') then
        ennemi.anim.isFliped:=(ennemi.stats.xcible>trouverCentreX(ennemi))
      else
        ennemi.anim.isFliped:=(trouverCentreX(joueur)>trouverCentreX(ennemi));
    end;
    end
end;

procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);
var i:Integer;
begin
  if animFinie(ennemi.anim) and (ennemi.anim.etat='apparition') then
    begin
    InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase', ennemi.stats.nbFrames1,True);
    ennemi.col.estActif:=True;
    if (ennemi.anim.objectName='dracomage') then
      begin
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/dracomage1.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS4_3_1'),100);
        ajoutDialogue('Sprites/Portraits/dracomage1.bmp',extractionTexte('DIALOGUE_BOSS4_3_2'));
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_3_3'));
        ajoutDialogue('Sprites/Portraits/dracomage1.bmp',extractionTexte('DIALOGUE_BOSS4_3_4'));
        sceneActive:='Cutscene';
        ennemi.stats.compteurAction:=1;
      end;
    end;
  if ennemi.anim.objectname='Béhémoth' then
    begin
    ennemi.image.rect.x:=460;ennemi.image.rect.y:=0;
    end;
  if ennemi.anim.objectName='gardien' then
    ennemi.image.rect.y:=-50;
  if (ennemi.anim.etat='apparition') and (ennemi.stats.compteurAction=0) then
    begin
    if (ennemi.anim.objectName='creature') then
    begin
      sceneActive:='Cutscene';
      ennemi.stats.compteurAction:=1;
      InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp',nil,0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS3_1_1'),100);
      for i:=2 to 8 do
      case i of 
      2:ajoutDialogue('Sprites/Portraits/creature1.bmp',extractionTexte('DIALOGUE_BOSS3_1_'+intToSTR(i)));
      4,8:ajoutDialogue('Sprites/Portraits/creature2.bmp',extractionTexte('DIALOGUE_BOSS3_1_'+intToSTR(i)));
      6:ajoutDialogue(nil,extractionTexte('DIALOGUE_BOSS3_1_'+intToSTR(i)));
      else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS3_1_'+intToStr(i)));
      end
    end;
    if (ennemi.anim.objectName='Spectre') then
    begin
      sceneActive:='Cutscene';
      ennemi.stats.compteurAction:=1;
      InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/spectre.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS2_1_1'),100);
      for i:=2 to 12 do
      case i of 
      3,5,7,9,11:ajoutDialogue('Sprites/Portraits/spectre.bmp',extractionTexte('DIALOGUE_BOSS2_1_'+intToSTR(i)));
      else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS2_1_'+intToStr(i)));
      end
    end;
    if (ennemi.anim.objectName='geolier') then
    begin
      sceneActive:='Cutscene';
      ennemi.stats.compteurAction:=1;
      InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portraitGarde2.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS1_1_1'),100);
      for i:=2 to 10 do
      case i of 
      3,5,7,9:ajoutDialogue('Sprites/Portraits/portraitGarde2.bmp',extractionTexte('DIALOGUE_BOSS1_1_'+intToSTR(i)));
      else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS1_1_'+intToStr(i)));
      end
    end;
    if (ennemi.anim.objectName='Béhémoth')  then
    begin
	    InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portraitB.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS4_1'),100);
      ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_2'));
      ajoutDialogue('Sprites/Portraits/portraitB.bmp',extractionTexte('DIALOGUE_BOSS4_3'));
      ajoutDialogue('Sprites/Portraits/portraitB.bmp',extractionTexte('DIALOGUE_BOSS4_4'));
      ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_5'));
      sceneActive:='Cutscene';
      jouersonenn('dragon');
      ennemi.stats.compteurAction:=1;
    end;
    if (ennemi.anim.objectName='dracomage') then
      begin
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS4_2_1'),100);
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_2_2'));
        ajoutDialogue('Sprites/Game/Archimage/Archimage_chase_1.bmp',extractionTexte('DIALOGUE_BOSS4_2_3'));
        ajoutDialogue('Sprites/Game/Archimage/Archimage_chase_1.bmp',extractionTexte('DIALOGUE_BOSS4_2_4'));
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_2_5'));
        sceneActive:='Cutscene';
        ennemi.stats.compteurAction:=1;
      end;
    if (ennemi.anim.objectName='Leo') then
      begin
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Leo7.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_EVENT_BOSS_1'),10);
        sceneActive:='Cutscene';
        ennemi.stats.compteurAction:=1;
      end;
    if (ennemi.anim.objectName='Archimage') then
      begin
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Game/Archimage/Archimage_chase_1.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS4_1_1'),100);
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_1_2'));
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_1_3'));
        ajoutDialogue('Sprites/Game/Archimage/Archimage_chase_1.bmp',extractionTexte('DIALOGUE_BOSS4_1_4'));
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_1_5'));
        ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_1_6'));
        sceneActive:='Cutscene';
        ennemi.stats.compteurAction:=1;
      end;
    end;
  if (ennemi.anim.etat='apparition') then
    ennemi.col.estActif:=False;
  if ennemi.stats.cooldown>0 then
    ennemi.stats.cooldown:=ennemi.stats.cooldown-1;
  DrawRect(black_color,255, ennemi.image.rect.x-2+ennemi.col.offset.x,ennemi.image.rect.y+ennemi.col.dimensions.h+ennemi.col.offset.y+5, ennemi.col.dimensions.w+4, 14);
  if ennemi.stats.vieMax>0 then
  DrawRect(red_color,255, ennemi.image.rect.x+ennemi.col.offset.x,ennemi.image.rect.y+ennemi.col.dimensions.h+ennemi.col.offset.y+7, max(0,Round(ennemi.col.dimensions.w*(ennemi.stats.vie/ennemi.stats.vieMax))), 10 );
  if ennemi.stats.vie<0 then ennemi.stats.vie:=0;
  if (ennemi.stats.vie>0) and (ennemi.anim.etat<>'apparition') then 
    begin
      deplacementEnnemi(ennemi,joueur);
      actionEnnemi(ennemi,trouverCentreX(joueur),trouverCentreY(joueur));
    end
		else
      if (animFinie(ennemi.anim)) and (ennemi.anim.etat='mort') then
        if ennemi.anim.objectName='Leo' then begin
          InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Leo8.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_EVENT_BOSS_2'),10);
          ajoutDialogue('Sprites/Portraits/portrait_Leo7.bmp',extractionTexte('DIALOGUE_EVENT_BOSS_3'));
          ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_EVENT_BOSS_4'));
          sceneActive:='Cutscene';
          transformation(ennemi,24);
          end
        else if ennemi.anim.objectName='geolier' then begin
          transformation(ennemi,32);
          sceneActive:='Cutscene';
          InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portraitGarde3.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS1_2_1'),20);
          ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS1_2_2'));
          ajoutDialogue('Sprites/Portraits/portraitGarde3.bmp',extractionTexte('DIALOGUE_BOSS1_2_3'));
          ajoutDialogue('Sprites/Portraits/portraitGarde3.bmp',extractionTexte('DIALOGUE_BOSS1_2_4'));
          ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS1_2_5'));
          end
        else if (ennemi.anim.objectName='Leo_Transe') and (ennemi.stats.compteurAction=-1) then begin
          sceneActive:='Cutscene';
          ennemi.stats.compteurAction:=0;
          InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Leo2.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_EVENT_BOSS_5'),10);
          ajoutDialogue('Sprites/Portraits/portrait_Leo6.bmp',extractionTexte('DIALOGUE_EVENT_BOSS_6'));
          ajoutDialogue('Sprites/Portraits/portrait_Leo6.bmp',extractionTexte('DIALOGUE_EVENT_BOSS_7'));
          ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_EVENT_BOSS_8'));
          end
        else
          begin
          if ennemi.anim.objectName='elementaire_temps' then
            LObjets[0].stats.vitesse:=statsJoueur.vitesse;
          supprimeObjet(ennemi);
          vagueFinie:=True;
          for i:=1 to High(LObjets) do
            if LObjets[i].stats.genre=TypeObjet(1) then
              begin
              vagueFinie:=False;
              end;
          end
          
      else if ennemi.stats.vie<=0 then
      if (ennemi.anim.objectName='Spectre') then
        begin
        transformation(ennemi,34);
        sceneActive:='Cutscene';
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/spectre2.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS2_2_1'),100);
        for i:=2 to 10 do
        case i of 
        3,6,7,9,10:ajoutDialogue('Sprites/Portraits/spectre2.bmp',extractionTexte('DIALOGUE_BOSS2_2_'+intToSTR(i)));
        else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS2_2_'+intToStr(i)));
        end
        end
      else
      begin
      
      if not (ennemi.anim.objectName='Béhémoth') then
        begin
        ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
        if not (ennemi.anim.etat='mort') then 
          begin
          jouerSonEnn(ennemi.anim.objectName+'_mort');
          if ennemi.anim.objectName='Leo_Transe' then 
            ennemi.stats.compteurAction:=-1;
          if (ennemi.anim.objectName='geolier2') then
            begin
              sceneActive:='Cutscene';
              InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portraitGarde4.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS1_3_1'),20);
              ajoutDialogue('Sprites/Portraits/portraitGarde4.bmp',extractionTexte('DIALOGUE_BOSS1_3_2'));
            end;
          if (ennemi.anim.objectName='dracomage') then
            begin
            InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/dracomage2.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS4_4_1'),100);
            ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_4_2'));
            ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS4_4_3'));
            ajoutDialogue('Sprites/Portraits/dracomage3.bmp',extractionTexte('DIALOGUE_BOSS4_4_4'));
            ajoutDialogue('Sprites/Portraits/dracomage3.bmp',extractionTexte('DIALOGUE_BOSS4_4_5'));
            sceneActive:='Cutscene';
            end;
          if (ennemi.anim.objectName='vestige') then
              begin
              sceneActive:='Cutscene';
              InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/spectre4.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS2_4_1'),100);
              for i:=2 to 8 do
              case i of 
              3,5,7:ajoutDialogue('Sprites/Portraits/spectre4.bmp',extractionTexte('DIALOGUE_BOSS2_4_'+intToSTR(i)));
              else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS2_4_'+intToStr(i)));
              end
              end;
          if (ennemi.anim.objectName='creature') then
            begin
              sceneActive:='Cutscene';
              InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/creature3.bmp',0,0,windowWidth,300,extractionTexte('DIALOGUE_BOSS3_2_1'),20);
              for i:=2 to 6 do
              case i of 
              3:ajoutDialogue('Sprites/Portraits/creature3.bmp',extractionTexte('DIALOGUE_BOSS3_2_'+intToSTR(i)));
              4:ajoutDialogue('Sprites/Portraits/creature4.bmp',extractionTexte('DIALOGUE_BOSS3_2_'+intToSTR(i)));
              else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('DIALOGUE_BOSS3_2_'+intToStr(i)));
              end
            end;
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'mort',ennemi.stats.nbFramesMort,False);
          ennemi.col.estActif:=False;
          statsJoueur.bestiaire[ennemi.stats.numero]:=True;
          end;
        end
      else
        if (ennemi.anim.etat<>'mortRep') and (ennemi.anim.etat<>'mort') then
          begin
          jouerSonEnn('dragon2');
          statsJoueur.bestiaire[ennemi.stats.numero]:=True;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'mortRep',ennemi.stats.nbframes3,True);
          InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portraitB.bmp',0,-70,windowWidth,300,extractionTexte('DIALOGUE_BOSS4_0'),100);       sceneActive:='Behemoth_Mort';
          end;
    end
end;

begin
// !!format : numéro dans TemplatesEnnemis, nom,mvt,vie,att,dmg,def,vit,w,h,nbFrames(apparition,chase,action1,action2,mort),collisions(w,h,offsetX,offsetY),nom de l'attaque
//(mvt: type de mouvement, dmg: dégâts au contact)
setLength(ennemis,0);
// Ajuster les stats des ennemis
//              num,  nom,                    mvt, vie, att, dmg, def, vit, w,   h,   nbFramesApparition, nbFramesChase, nbFramesAction1, nbFramesAction2, nbFramesMort, wcol, hcol, offx, offy, nomAttaques
initStatEnnemi(1,    'slime',                 8,   30,  1,   0,   0,   0,   90,  90,  6,                 8,             3,               4,               4,           90,   45,   5,    40,   'boule');
initStatEnnemi(2,    'livre',                 12,  30,  3,   0,   2,   1,   180, 90,  7,                 12,            4,               0,               12,          60,   90,   60,   0,    'eclair');
initStatEnnemi(3,    'feu_follet',            6,   30,  3,   1,   1,   0,   100, 100, 7,                 9,             0,               0,               6,           70,   70,   15,   15,   'flamme');
initStatEnnemi(4,    'grenouille',            8,   30,  1,   0,   2,   0,   90,  90,  7,                 6,             4,               4,               7,           54,   90,   5,    0,    'boule');
initStatEnnemi(5,    'chevalier',             5,   30,  10,  0,   1,   5,   90,  90,  5,                 6,             3,               10,              5,           54,   90,   5,    0,    'rayonAbysse');
initStatEnnemi(6,    'elementaire_astral',    4,   30,  2,   0,   1,   1,   100, 100, 9,                 12,            5,               6,               7,           80,   80,   10,   10,   'etoile');
initStatEnnemi(7,    'elementaire_temps',     0,   25,  2,   5,   1,   1,   100, 100, 18,                12,            0,               0,               6,           80,   80,   10,   10,   '');
initStatEnnemi(8,    'elementaire_spectral',  4,   30,  2,   0,   0,   0,   100, 100, 8,                 7,             13,              13,              8,           80,   80,   10,   10,   'rayon_spectral');
initStatEnnemi(9,    'elementaire_lumiere',   1,   50,  2,   0,   4,   3,   300, 300, 12,                11,            6,               0,               8,           60,   60,   120,  120,  'rayon');
initStatEnnemi(10,   'elementaire_ombre',     1,   50,  2,   0,   4,   3,   300, 300, 11,                12,            9,               0,               10,          60,   60,   120,  120,  'rayon_spectral');
initStatEnnemi(11,   'elementaire_tempete',   3,   50,  0,   5,   0,   2,   150, 150, 10,                8,             4,               0,               10,          100,  150,  25,   0,    '');
initStatEnnemi(12,   'elementaire_eclipse',   1,   250, 2,   0,   4,   3,   400, 400, 19,                12,            7,               0,               9,           60,   60,   160,  160,  'eclipse');
initStatEnnemi(13,   'mage_noir',             2,   75,  0,   0,   0,   0,   126, 120, 10,                8,             9,               7,               9,           80,   100,  30,   20,   'flamme');
initStatEnnemi(14,   'mage_blanc',            15,  40,  4,   0,   0,   1,   100, 120, 18,                12,            3,               5,               14,          60,   90,   20,   30,   'rayon');
initStatEnnemi(15,   'mage_rouge',            8,   50,  10,  0,   2,   0,   100, 200, 11,                6,             4,               9,               5,           60,   90,   20,   110,  'rayon_rouge');
initStatEnnemi(16,   'invocateur',            12,  50,  0,   0,   0,   0,   120, 132, 12,                8,             3,               0,               5,           80,   100,  30,   20,   'rayon');
initStatEnnemi(17,   'diablotin',             4,   10,  1,   0,   0,   3,   80,  80,  4,                 6,             4,               5,               4,           50,   50,   15,   0,    'eclairR');
initStatEnnemi(18,   'Akr',                   4,   250, 2,   0,   -20, 1,   384, 256, 14,                9,             9,               8,               16,          200,  96,   80,   150,  'kamui');
initStatEnnemi(19,   'main',                  3,   50,  0,   5,   0,   1,   150, 150, 8,                 16,            8,               0,               15,          150,  150,  0,    0,    '');
initStatEnnemi(20,   'armure',                7,   400, 8,   0,   7 ,  0,   384, 256, 7,                 2,             13,              9,               16,          192,  192,  96,   64,   'justice');
initStatEnnemi(21,   'undrixel',              3,   50,  5,   30,  0,   1,   288, 192, 4,                 10,            4,               0,               10,          200,  128,  10,   40,   'eclairR');
initStatEnnemi(22,   'altegh',                1,   50,  2,   0,   4,   2,   192, 192, 3,                 6,             4,               0,               14,          160,  96,   16,   96,   'rayonAL');
initStatEnnemi(23,   'Leo',                   13,  150, 15,  5,   5,   0,   300, 300, 14,                8,             7,               10,              8,           100,  150,  100,  150,  'eclairL');
initStatEnnemi(24,   'Leo_Transe',            14,  150, 30,  10,   2,   1,   300, 300, 13,                16,            6,               22,              10,          200,  250,  50,   25,   'geyser_feu');
initStatEnnemi(25,   'UNKNOWN',               4,   150, 2,   0,   -20, 0,   128, 128, 8,                 12,            8,               4,               8,           64,   114,  32,   14,   'Roue');
initStatEnnemi(26,   'chaos',                 12,  60,  1,   3,   5,   2,   200, 200, 9,                 11,            6,               0,               6,           100,  200,  50,   0,    'rayonAbysse');
initStatEnnemi(27,   'Archimage',             4,   100, 2,   0,   6,   0,   128, 128, 8,                 6,             6,               6,               4,           64,   100,  32,  14,   'projectile');
initStatEnnemi(28,   'liche',                 5,   50,  2,   0,   4,   1,   128, 128, 9,                 6,             5,               16,              10,          70,   110,  19,   7,    'rayonMort');
initStatEnnemi(29,   'expurgateur',           6,   40,  3,   1,   1,   0,   128, 128, 13,                12,            0,               0,               7,           128,  104,  0,    24,   'eclairR');
initStatEnnemi(30,   'dracomage',             2,   300, 2,   5,   6,   1,   192, 192, 34,                12,            8,               8,               26,          128,  164,  32,   28,   'eclairR');
initStatEnnemi(31,   'geolier',               18,  300, 10,  0,   -10, 2,   500, 400, 4,                 12,            20,              4,               6,           100,  200,  200,  200,  'arcane');
initStatEnnemi(32,   'geolier2',              19,  300, 10,  0,   -10, 1,   500, 400, 32,                18,            10,              10,              14,          200,  200,  150,  200,  'chaine');
initStatEnnemi(33,   'Spectre',               12,  100, 1,   10,  0,   1,   300, 400, 8,                 22,            8,               0,               13,          160,  300,  70,   50,   'oeil');
initStatEnnemi(34,   'vestige',               11,  1000,3,   15,  5,   1,   400, 400, 16,                16,            12,              10,              7,           250,  400,  75,   0,    'geyser_lumiere');
initStatEnnemi(35,   'gardien',               16,  500, 2,   1,   0,   1,   300, 300, 8,                 16,            0,               0,               23,          250,  120,  25,   120,  'rayon_main');
initStatEnnemi(36,   'Geist',                 17,  200, 10,  0,   -10, 4,   300, 300, 21,                24,            3,               7,               9,           80,   80,   110,  160,  'rayonAL');
initStatEnnemi(37,   'creature',              20,  1000,15,  0,   0,   0,   600, 560, 46,                12,            14,              14,              20,          500,  460,  50,   50,   'arcane');
initStatEnnemi(38,   'Béhémoth',              10,  4500,20,  10,  10,  5,   463, 614, 12,                32,            40,              12,              39,          400,  307,  63,   307,  'rayonRykor');




end.