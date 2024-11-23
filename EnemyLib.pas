unit EnemyLib;

interface
uses
    coeur,
    math,
    memgraph,
    fichierSys,
    SDL2,sdl2_mixer,
    animationSys,
    collisionSys,
    combatLib,
    sonoSys,
    eventsys,
    SysUtils;

const TAILLE_VAGUE=3;

var EnemyBasik : TObjet;
var templatesEnnemis:array[1..MAXENNEMIS] of TObjet;
    ennemis:Array of TOBjet;
//procedure initStatEnnemi(nom:PChar;typeIA_MVT,vie,att,dmg,def,vitesse,w,h,framesA,frames1,frames2,frames3,framesM:Integer;var ennemi:TObjet;wcol,hcol,offx,offy:Integer;nomAttaques:PChar);
procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);
procedure ajoutVague();

implementation

procedure JouerSonEnn(nom:String);
begin
  jouerSon(StringToPChar('SFX/Ennemis/'+nom+'.wav'));
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
  writeln('tentative d"ajout d"une vague , ennemis restants : ',high(ennemis));
  if high(ennemis)<=0 then
    combatFini:=True
  else
    begin
    vagueFinie:=False;
    taille:=high(ennemis);
    fini:=False;
    writeln(taille,',',high(lobjets));
    if (high(LObjets)<taille) and (taille>TAILLE_VAGUE) then
      setlength(LObjets,TAILLE_VAGUE+1);
    if (high(LObjets)<taille) and (taille<=TAILLE_VAGUE) then
      setlength(LObjets,taille+1);
    writeln(taille,',',high(lobjets));
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
    writeln('combat fini:',combatFini);
    writeln('vague ajoutée');
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
    CreateRawImage(ennemi.image,(random(20)+5)*20,0,w,h,getFramePath(ennemi.anim));
    

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
    ennemi.stats.inamovible:=((ennemi.anim.objectname='Béhémoth') or (ennemi.anim.objectName='gardien'));
    ennemi.stats.numero:=num;
    templatesEnnemis[num]:=ennemi;
end;

//permet à un ennemi de se téléporter au hasard
procedure AIWarp(var ennemi:TObjet;targetx,targety:Integer);
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

procedure AIReWarp(var ennemi:TObjet);
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
    ennemi.image.rect.x:=ennemi.stats.xcible;ennemi.image.rect.y:=ennemi.stats.ycible;
    ennemi.col.estActif:=True;
end;

procedure AIFly(var ennemi:TObjet;targetx,targety:Integer);
var xdest,ydest:Integer;
begin
  //fonctionne de façon similaire à AIWarp, sans initialiser l'animation de téléportation
  jouerSonEnn('fly');
  repeat
  xdest:=random(10)*100;
  until (xdest<=800) and (xdest>=200) and (abs(xdest-targetx)>100) and (abs(xdest-ennemi.image.rect.x)>100);
  repeat
    ydest:=random(10)*100;
  until (ydest<700) and (ydest>0) and (abs(ydest-targety)>50) and (abs(ydest-ennemi.image.rect.y)>50);
  ennemi.stats.xcible:=xdest;ennemi.stats.ycible:=ydest;
end;

procedure FlyUpdate(var ennemi:TObjet;vit:Integer);
var distx,disty:Integer;
begin
  //l'ennemi se déplace vers sa cible, à une vitesse proportionnelle à la distance
  distx:=-(ennemi.image.rect.x-ennemi.stats.xcible);disty:=-(ennemi.image.rect.y-ennemi.stats.ycible);
  ennemi.image.rect.x:=ennemi.image.rect.x + (distx div vit);
  ennemi.image.rect.y:=ennemi.image.rect.y + (disty div vit);
  ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
end;

procedure AIDodge(var ennemi:TObjet;target:TObjet);
var distx:Integer;
begin
  jouerSonEnn(ennemi.anim.objectName+intToSTr(random(3)+1));
  //l'ennemi se décale vers un mur, selon sa position initiale, pour esquiver
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
  //choisit un endroit où l'ennemi peut se déplacer en ligne droite (tour aux échecs)
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
  //permet à un ennemi de foncer de l'autre côté de la salle
  if ennemi.image.rect.x>500 then
    ennemi.stats.xcible:=0
  else
    ennemi.stats.xcible:=1000;
  ennemi.stats.ycible:=getcentery(ennemi);
  JouerSonEnn(ennemi.anim.objectName);
  initAnimation(ennemi.anim,ennemi.anim.objectName,'dash',ennemi.stats.nbframes2,true);
end;

procedure MoveToTarget(var ennemi:TObjet;vitesse:Integer);
var angle:Real;
  distX,distY,y:Integer;
begin
  //l'ennemi se déplace vers sa position cible
  distX:=ennemi.stats.xcible-getcenterx(ennemi);
  distY:=ennemi.stats.ycible-getcentery(ennemi);
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
    ennemi.stats.xcible:=getcenterx(target)
  else 
    ennemi.stats.xcible:=getcenterx(ennemi);
  if deplaceY then
    ennemi.stats.ycible:=getcentery(target)
  else 
    ennemi.stats.ycible:=getcentery(ennemi);
  if (ennemi.stats.degatsContact>0) or (not deplaceX or (abs(ennemi.stats.xcible-getcenterx(ennemi))>ennemi.col.dimensions.w div 2)) or (not deplaceY or (abs(ennemi.stats.ycible-getcentery(ennemi))>ennemi.col.dimensions.h div 2)) then
    moveToTarget(ennemi,vitesse);
  //SDL_setRenderDrawColor(sdlrenderer,255,255,0,255);
  //sdl_renderDrawLINE(sdlrenderer,getcenterx(ennemi),getcentery(ennemi),ennemi.stats.xcible,ennemi.stats.ycible);
  ennemi.anim.isFliped:=(getcenterx(target)-getcenterx(ennemi)>=0);
end;


procedure ActionEnnemi(ennemi:TObjet;x,y:Integer); //permet à un ennemi d'agir (donc d'attaquer)
var obj:TObjet;alea1,alea2:Integer;
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
                CreerRayon(typeobjet(1),2,ennemi.stats.force,1,getcenterx(ennemi),getCenterY(ennemi),1200,80,ennemi.image.rect.x+400,getCenterY(ennemi),(random(5)-3)*3,10,100,ennemi.stats.nomAttaque,obj)
              else
                CreerRayon(typeobjet(1),2,ennemi.stats.force,1,getcenterx(ennemi),getCenterY(ennemi),1200,80,ennemi.image.rect.x-400,getCenterY(ennemi),(random(5)-3)*3,10,100,ennemi.stats.nomAttaque,obj);
              ajoutObjet(obj);
      end;
  case ennemi.stats.typeIA_MVT of
    0: if(ennemi.stats.compteurAction mod 100 = 50) then
      begin
        LObjets[0].stats.vitesse:=round(sqrt((ennemi.stats.xcible-ennemi.image.rect.x)**2+(ennemi.stats.ycible-ennemi.image.rect.y)**2)/50);
      end;
    2: if (ennemi.anim.currentFrame=4) and (ennemi.anim.etat='cast') then
      multiProjs(typeObjet(1),1,1,1,ennemi.image.rect.x+96,ennemi.image.rect.y+96,100,100,3,10,360,0,ennemi.stats.nomAttaque);
    3: if (ennemi.anim.etat='dash') and (ennemi.stats.compteurAction>50) and (ennemi.stats.compteurAction mod 45=0) and (ennemi.anim.objectName='undrixel') then
      begin
      //multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,0,10,360,0,10,80,'rayon');
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,100,100,5,4,360,(ennemi.stats.xcible-ennemi.image.rect.x),ennemi.stats.nomAttaque);
      multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+64,ennemi.image.rect.y+64,100,100,5,4,360,(ennemi.stats.xcible-ennemi.image.rect.x) div 2,'kamui');
      end;
    4:if (ennemi.anim.etat='warp') and (ennemi.stats.compteurAction=1) then 
      if ennemi.anim.objectName='elementaire_spectral' then
        begin
        CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,getCenterX(ennemi),getCenterY(ennemi),1200,200,x,y,0,50,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end
      else
        multiProjs(TypeObjet(1),1,1,1,ennemi.image.rect.x+(ennemi.image.rect.w div 2),ennemi.image.rect.y+(ennemi.image.rect.h div 2),100,100,5,3,360,random(18)*10,ennemi.stats.nomAttaque);
    5: if (ennemi.anim.etat='strike')then
      begin
      ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
      if (ennemi.anim.currentFrame=6) and (sdl_getTicks-ennemi.anim.lastUpdateTime<15) then
        begin
        if (ennemi.image.rect.x<ennemi.stats.xcible) then
          CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+40,ennemi.image.rect.y+50,1200,100,ennemi.image.rect.x+60,ennemi.image.rect.y+50,0,10,ennemi.stats.vie,ennemi.stats.nomAttaque,obj)
        else
          CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+40,ennemi.image.rect.y+50,1200,100,ennemi.image.rect.x-60,ennemi.image.rect.y+50,0,10,ennemi.stats.vie,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
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
        multiLasers(TypeObjet(1),1,1,1,ennemi.image.rect.x+50,ennemi.image.rect.y+50,120,0,4,360,0,10,100,'rayon');
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
          CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,getCenterX(ennemi)+60,getCenterY(ennemi),1000,200,x-100+random(20)*10,y,0,10,50,ennemi.stats.nomAttaque,obj);
          ajoutObjet(obj);
          end
        end
      else
        if (ennemi.stats.compteurAction <320) and (ennemi.stats.compteurAction mod 4 = 0) then
        begin
        creerBoule(typeobjet(1),0,ennemi.stats.force,ennemi.stats.multiplicateurDegat,getCenterX(ennemi),getCenterY(ennemi),60,60,3,x-128+random(64)*4,y-128+random(64)*4,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    10:begin
        if (ennemi.anim.etat='tir') and (ennemi.anim.currentFrame=20) and (ennemi.stats.compteurAction<=601) then
        begin
        CreerRayon(typeobjet(1),2,1,1,ennemi.image.rect.x+250,ennemi.image.rect.y+350,1200,300,ennemi.image.rect.x-60,ennemi.image.rect.y+350,-(y-(ennemi.image.rect.y+350))/280,80,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
        if (ennemi.anim.etat='chase') and (ennemi.anim.currentFrame mod 5 =2) and (ennemi.anim.currentFrame<>2) then
          begin
          creerBoule(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+200,ennemi.image.rect.y+340,64,64,5,x+32,y+0+((ennemi.anim.lastUpdateTime-sdl_getTicks)),'projRykor',obj);
          ajoutObjet(obj)
          end
        end;
    11:if random(30)=0 then begin
        alea1:=random(100)*10+200;alea2:=random(100)*10;
        creerRayon(typeObjet(1),100,ennemi.stats.force,ennemi.stats.multiplicateurDegat,alea1,alea2,400,200,alea1,alea2-100,0,100,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    12:if (ennemi.anim.etat='cast') and (ennemi.stats.compteurAction mod 30=0) then begin
        alea1:=random(30)*10+350;alea2:=random(100)-300;
        creerRayon(typeObjet(1),100,ennemi.stats.force,ennemi.stats.multiplicateurDegat,x+alea1,y+alea2-100,400,200,x+alea1,y+alea2,0,50,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj)
        end;
    13:begin
      if (ennemi.anim.etat='charge') and (ennemi.stats.compteurAction mod 30=0) then 
        begin
        alea1:=random(180);
        creerRayon(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,round(x+cos(alea1)*100)+400,50+round(y+sin(alea1)*100),400,200,350+round(x-cos(alea1)*100),round(y-sin(alea1)*100),0,50,50,ennemi.stats.nomAttaque,obj);
        sdl_settexturecolormod(obj.image.imgtexture,255,0,0);
        ajoutObjet(obj)
        end;
        if ((ennemi.anim.etat='strike') and (ennemi.stats.compteurAction<15)) then//or ((ennemi.anim.etat='dodge') and (ennemi.stats.compteurAction>40)) then
          begin 
          creerRayon(typeObjet(1),1,ennemi.stats.force,ennemi.stats.multiplicateurDegat,ennemi.image.rect.x+(ennemi.image.rect.w div 2),ennemi.image.rect.y+(ennemi.image.rect.h div 2),1200,200,x,y,0,10,100-ennemi.anim.currentFrame*10,'rayonLeo',obj);
          ajoutObjet(obj);
          end;
        end;
    14:begin
    if (random(30)=0) and (ennemi.anim.etat='rage') then begin
        alea1:=random(100)*10+200;alea2:=random(100)*10;
        creerRayon(typeObjet(1),100,ennemi.stats.force,ennemi.stats.multiplicateurDegat,alea1,alea2,400,200,alea1,alea2-100,0,100,100,ennemi.stats.nomAttaque,obj);
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
        CreerRayon(typeobjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,getCenterX(ennemi),getCenterY(ennemi),1200,100,x,y,0,10,100,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      end;
    16:begin
      if (ennemi.stats.compteurAction mod 80 = 0) then
        begin
        creerRayon(typeObjet(1),4,ennemi.stats.force,ennemi.stats.multiplicateurDegat,600,ennemi.stats.compteurAction div 2,300,150,1500,ennemi.stats.compteurAction div 2,0,30,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        creerRayon(typeObjet(1),4,ennemi.stats.force,ennemi.stats.multiplicateurDegat,1400,ennemi.stats.compteurAction div 2,300,150,200,ennemi.stats.compteurAction div 2,0,30,50,ennemi.stats.nomAttaque,obj);
        ajoutObjet(obj);
        end;
      if (ennemi.stats.compteurAction mod 50 =0) then
        begin
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,(random(10)+6)*100,750,300,150,x+400,y,0,30,80,'pic_terre',obj);
        ajoutObjet(obj);
        creerRayon(typeObjet(1),2,ennemi.stats.force,ennemi.stats.multiplicateurDegat,(random(10)+6)*100,-30,300,150,x+400,y,0,30,80,'pic_terre',obj);
        ajoutObjet(obj);
        end;
      end;
    end;
end;

procedure DeplacementEnnemi(var ennemi:TObjet;joueur:TObjet); //déplace un ennemi 
var i:Integer;rect1,rect2:TSDL_REct;trouve:Boolean;
begin

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
            //jouerSonEnn('focus ('+intToSTr(random(3)+1)+')');
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
          if (ennemi.stats.vie<100) then ennemi.stats.vitessePoursuite:=2;
          if ennemi.stats.compteurAction>300 then
            begin
            InitAnimation(ennemi.anim,ennemi.anim.objectName,'charge',ennemi.stats.nbFrames2,True);
            ennemi.stats.compteurAction:=0;
            end
          else ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1
          end
          else ennemi.anim.isFliped:=(ennemi.stats.xcible>ennemi.image.rect.x);
        if animFinie(ennemi.anim) and (ennemi.anim.etat='charge') then
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames3,False);
        if animFinie(ennemi.anim) and (ennemi.anim.etat='cast') then
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
        end;
      3: //ennemi qui dash horizontalement
        begin
        if (ennemi.anim.etat='chase') then
          begin
          //ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,false,true);
          if abs(getcentery(joueur)-getcentery(ennemi))<50 then
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
          if ((ennemi.stats.compteurAction mod 20=0) and (ennemi.stats.vie<ennemi.stats.vieMax div 4)) or (ennemi.stats.compteurAction mod 60=0) then
            begin
              aiFly(ennemi,joueur.image.rect.x,joueur.image.rect.y)
            end;
          if ennemi.stats.vie>ennemi.stats.vieMax div 4 then
            flyUpdate(ennemi,15)
          else
            flyUpdate(ennemi,2);
          if ennemi.stats.compteurAction>300 then
            begin
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
          //writeln(ennemi.stats.compteurAction);
          end;
        if (ennemi.anim.etat='tir') and (animFinie(ennemi.anim)) then
          begin
          ennemi.stats.compteurAction:=0;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'chase',ennemi.stats.nbFrames1,True);
          end;
        end;
      12:begin //ennemi qui s'arrête pour lancer un sort à la position du joueur
        ennemi.stats.compteurAction:=ennemi.stats.compteurAction+1;
        if ennemi.anim.etat='chase' then
          begin
          AIPathFollow(ennemi,joueur,ennemi.stats.vitessePoursuite,True,True);
          if (ennemi.stats.compteurAction>300) then
            begin
            initAnimation(ennemi.anim,ennemi.anim.objectName,'cast',ennemi.stats.nbFrames2,True);
            end;
          end;
        
        if ennemi.stats.compteurAction>400 then
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
                if lobjets[i].stats.genre=typeObjet(1) then
                  begin
                  SDL_setRenderDrawColor(sdlRenderer,0,255,0,255);
                  sdl_renderdrawline(sdlRenderer,getcenterx(ennemi),getCenterY(ennemi),getcenterx(LObjets[i]),getCenterY(LObjets[i]));
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

    end
end;

procedure IAEnnemi(var ennemi:TObjet;joueur:TObjet);
var i,x,y:Integer;
begin
  if animFinie(ennemi.anim) and (ennemi.anim.etat='apparition') then
    begin
    InitAnimation(ennemi.anim,ennemi.anim.objectName,'chase', ennemi.stats.nbFrames1,True);
    ennemi.col.estActif:=True;
    end;
  if ennemi.anim.objectname='Béhémoth' then
    begin
    ennemi.image.rect.x:=460;ennemi.image.rect.y:=00;
    end;
  if ennemi.anim.objectName='gardien' then
    ennemi.image.rect.y:=-50;
  if (ennemi.anim.etat='apparition') and (ennemi.anim.objectName='Béhémoth') and (ennemi.stats.compteurAction=0) then
    begin
	    InitDialogueBox(dialogues[2],'Sprites\Menu\Button1.bmp','Sprites\Menu\portraitB.bmp',0,0,windowWidth,400,extractionTexte('DIALOGUE_BOSS_1'),100);
      sceneActive:='Cutscene';
      ennemi.stats.compteurAction:=1;
    end;
  if (ennemi.anim.etat='apparition') and (ennemi.anim.objectName='dracomage') and (ennemi.stats.compteurAction=0) then
    begin
      //sceneActive:='Dracomage';
      ennemi.stats.compteurAction:=1;
    end;
  if ennemi.stats.cooldown>0 then
    ennemi.stats.cooldown:=ennemi.stats.cooldown-1;
  DrawRect(black_color,255, ennemi.image.rect.x-2+ennemi.col.offset.x,ennemi.image.rect.y+ennemi.col.dimensions.h+ennemi.col.offset.y+5, ennemi.col.dimensions.w+4, 14);
  if ennemi.stats.vieMax>0 then
  DrawRect(red_color,255, ennemi.image.rect.x+ennemi.col.offset.x,ennemi.image.rect.y+ennemi.col.dimensions.h+ennemi.col.offset.y+7, Round(ennemi.col.dimensions.w*(ennemi.stats.vie/ennemi.stats.vieMax)), 10 );
  if ennemi.stats.vie<0 then ennemi.stats.vie:=0;
  if (ennemi.stats.vie>0) and (ennemi.anim.etat<>'apparition') then 
    begin
      deplacementEnnemi(ennemi,joueur);
      actionEnnemi(ennemi,joueur.image.rect.x,joueur.image.rect.y);
    end
		else
      if (animFinie(ennemi.anim)) and (ennemi.anim.etat='mort') then
        if (ennemi.anim.objectName<>'Leo') then
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
        else
          begin
          x:=ennemi.image.rect.x;
          y:=ennemi.image.rect.y;
          InitDialogueBox(dialogues[2],'Sprites\Menu\Button1.bmp','Sprites\Menu\portrait_Leo7.bmp',0,0,windowWidth,400,extractionTexte('DIALOGUE_EVENT_BOSS_2'),10);
          sceneActive:='Cutscene';
          ennemi:=templatesEnnemis[21];
          ennemi.image.rect.x:=x;
          ennemi.image.rect.y:=y;
          end
          
      else if ennemi.stats.vie<=0 then
      begin
      if not (ennemi.anim.objectName='Béhémoth') then
        begin
        ennemi.anim.isFliped:=(joueur.image.rect.x>ennemi.image.rect.x);
        if not (ennemi.anim.etat='mort') then 
          begin
          jouerSonEnn(ennemi.anim.objectName+'_mort');
          InitAnimation(ennemi.anim,ennemi.anim.objectName,'mort',ennemi.stats.nbFramesMort,False);
          ennemi.col.estActif:=False;
          statsJoueur.bestiaire[ennemi.stats.numero]:=True;
          end;
        end
      else
        if (ennemi.anim.etat<>'mortRep') and (ennemi.anim.etat<>'mort') then
          begin
          statsJoueur.bestiaire[ennemi.stats.numero]:=True;
          initAnimation(ennemi.anim,ennemi.anim.objectName,'mortRep',ennemi.stats.nbframes3,True);
          InitDialogueBox(dialogues[2],'Sprites\Menu\Button1.bmp','Sprites\Menu\portraitB.bmp',0,0,windowWidth,400,extractionTexte('DIALOGUE_BOSS_2'),100);
          sceneActive:='Behemoth_Mort';
          end;
    end
end;

begin
// !!format : numéro dans TemplatesEnnemis, nom,mvt,vie,att,dmg,def,vit,w,h,nbFrames(apparition,chase,action1,action2,mort),collisions(w,h,offsetX,offsetY),nom de l'attaque
//(mvt: type de mouvement, dmg: dégâts au contact)

//***le numéro peut être changé selon la convénience, sans répercussions importantes
initStatEnnemi(1,'chaos',12,60,1,3,5,2,200,200,9,11,6,0,6,100,200,50,0,'rayonAbysse');
initStatEnnemi(2,'Archimage',4,100,2,0,6,0,128,128,10,6,6,6,4,70,100,24,14,'projectile');
initStatEnnemi(3,'liche',5,50,2,0,4,1,128,128,9,6,5,16,10,70,110,19,7,'rayonMort');
initStatEnnemi(4,'chevalier',5,10,10,0,1,3,90,90,5,6,3,10,5,54,90,5,0,'rayonAbysse');
initStatEnnemi(5,'expurgateur',6,20,3,1,1,0,128,128,13,12,0,0,7,128,104,0,24,'eclairR');
initStatEnnemi(6,'grenouille',8,20,1,0,2,0,90,90,7,6,4,4,7,54,90,5,0,'boule');
initStatEnnemi(7,'Akr',4,150,2,0,-20,1,384,256,14,9,9,8,16,200,96,80,150,'kamui');
initStatEnnemi(8,'UNKNOWN',4,150,2,0,-20,0,128,128,8,12,8,4,8,64,114,32,14,'Roue');
initStatEnnemi(9,'armure',7,400,0,0,10,0,384,256,7,2,13,9,16,192,192,96,64,'justice');
initStatEnnemi(10,'undrixel',3,50,5,2,0,1,288,192,4,10,4,0,10,200,128,10,40,'eclairR');
initStatEnnemi(11,'altegh',1,50,2,0,4,3,192,192,3,6,4,0,14,160,96,16,96,'rayonAL');
InitstatEnnemi(12,'Leo',13,150,8,2,5,0,300,300,14,8,7,10,8,100,150,100,150,'eclairL');
initStatEnnemi(13,'elementaire_astral',4,20,2,0,1,1,100,100,9,12,5,6,7,80,80,10,10,'etoile');
initStatEnnemi(14,'elementaire_temps',0,20,2,5,1,1,100,100,18,12,0,0,6,80,80,10,10,'');
initStatEnnemi(15,'slime',8,10,1,0,0,0,90,90,6,8,3,4,4,90,45,5,40,'boule');
InitstatEnnemi(16,'vestige',11,1000,3,0,5,1,400,400,10,16,0,0,7,250,400,75,0,'geyser_lumiere');
initStatEnnemi(17,'livre',12,20,1,0,2,1,180,90,7,12,4,0,12,60,90,60,0,'eclair');
initStatEnnemi(18,'feu_follet',6,20,3,1,1,0,100,100,7,9,0,0,6,70,70,15,15,'flamme');
initStatEnnemi(19,'dracomage',2,100,2,5,6,1,192,192,34,12,8,8,26,128,164,32,28,'eclairR');
initStatEnnemi(20,'Béhémoth',10,15000,20,10,10,5,463,614,12,32,40,12,39,400,307,63,307,'rayonRykor');
InitstatEnnemi(21,'Leo_Transe',14,150,20,5,2,1,300,300,13,16,6,22,10,200,250,50,25,'geyser_feu');
initStatEnnemi(22,'mage_blanc',15,40,2,0,0,1,100,120,18,12,3,5,14,60,90,20,30,'rayon');
initStatEnnemi(23,'elementaire_spectral',4,20,2,0,0,0,100,100,8,7,13,13,8,80,80,10,10,'rayon_spectral');
initStatEnnemi(24,'mage_rouge',8,50,2,0,2,0,100,200,11,6,4,9,5,60,90,20,110,'rayon_rouge');
initStatEnnemi(25,'main',3,50,0,5,0,1,150,150,8,16,8,0,15,150,150,0,0,'');
initStatEnnemi(26,'elementaire_lumiere',1,50,2,0,4,3,300,300,12,11,6,0,8,60,60,120,120,'rayon');
initStatEnnemi(27,'elementaire_ombre',1,50,2,0,4,3,300,300,11,12,9,0,10,60,60,120,120,'rayon_spectral');
initStatEnnemi(28,'elementaire_tempete',3,50,0,5,0,2,150,150,10,8,4,0,10,100,150,25,0,'');
initStatEnnemi(29,'elementaire_eclipse',1,250,2,0,4,3,400,400,19,12,7,0,9,60,60,160,160,'eclipse');
initStatEnnemi(30,'gardien',16,500,2,1,0,1,300,300,8,16,0,0,23,250,120,25,120,'rayon_main');
//initStatEnnemi(31,'Geist',17,200,10,0,-10,1,300,300,8,16,0,0,23,250,120,25,120,'rayonAL');



end.