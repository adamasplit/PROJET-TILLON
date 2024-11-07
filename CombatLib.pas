unit CombatLib;

interface

uses
    animationSys,
    coeur,
    eventSys,
    math,
    memgraph,
    sdl2_mixer,
    SDL2;

var updateTimeMonde:UInt32;updateTimeMort:UInt32;

function degat(flat : Integer ; force : Integer ; defense : Integer;multiplicateurDegat:Real): Integer;
procedure RegenMana(var LastUpdateTime : UInt32;var mana:Integer;manaMax:Integer;multiplicateurMana:Real); 
procedure CreerDeckCombat(stat : TStats;var DeckCombat:TDeck); 
procedure cycle (var deck : TDeck ; i : Integer);
procedure circoncision  (var deck : Tdeck);
procedure initStatsCombat(statsPerm:TStats;var statsTemp:TStats);
procedure CreerBoule(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,w,h,vitesse,xdest,ydest:Integer;nom:PChar;var proj:TObjet);
procedure updateBoule(var proj:TObjet);
procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,h,vitesse,nb,range,angleDepart:Integer;nom:PChar);
procedure multiLasers(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,vitesse,nb,range,angleDepart,duree,delai:Integer;nom:PChar);
procedure CreerRayon(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,w,xdest,ydest,vitRotation,dureeVie,delai:Integer;nom:PChar;var rayon:TObjet);
procedure updateRayon(var rayon:TObjet);
procedure UpdateJustice(var justice:TObjet);
procedure renderAvecAngle(objet:TObjet);
procedure creerEffet(x,y,w,h,frames:Integer;nom:PCHar;fixeJoueur:Boolean;var obj:TObjet);
procedure InitJustice(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,xCible,yCible,vitesse,delai:Integer);
procedure subirDegats(var victime:TObjet;degats,knockbackX,knockbackY:Integer);
procedure JouerCarte(var stats:TStats;x,y,i:Integer); 



implementation



procedure InitAngle(vectX,vectY:Real;var angle:Real);
begin
    if round(vectX*1000)=0 then
        if vectY>0 then
            angle:=pi/2
        else
            angle:=-pi/2
    else
        angle:=arctan(vectY/vectX);
end;

//Fonction de calcul des dégats
function degat(flat : Integer ; force : Integer ; defense : Integer;multiplicateurDegat:Real): Integer;
begin

    degat := math.ceil((flat + force - defense)*multiplicateurDegat);
    if degat < 1 then
        degat := 1;
end;

//procedure de dégat instantané : inflige des dégat FLAT 
procedure degatInst (var s : Tstats ; degat : integer );
begin
    s.vie := s.vie - degat;
end;


//Procedure Régénération du mana
procedure RegenMana(var LastUpdateTime : UInt32;var mana:Integer;manaMax:Integer;multiplicateurMana:Real);
var 
    currentTime: UInt32;
    

begin

        SDL_PumpEvents;
        currentTime := SDL_GetTicks(); //récupère le temps
        if (( (currentTime - LastUpdateTime)*multiplicateurMana)>= 1000) AND (mana < manaMax) then //attendre 1sec/mult avant +1 mana
        begin
            mana := mana + 1;
            LastUpdateTime := currentTime;
    end;

end;

//On créer un deck à base de la collection
procedure CreerDeckCombat(stat : TStats;var DeckCombat:TDeck); 
var tempDeck:TDeck;
    i, j, rdm : Integer;
begin
    setLength(tempDeck, stat.tailleCollection);
    setLength(deckCombat, stat.tailleCollection);
    for i:= 0 to stat.tailleCollection-1 do // création d'un deck temporaire identique à la collection
        tempDeck[i] := stat.collection[i+1];
    for i:= 0 to stat.tailleCollection-1 do // déplacement aléatoire des cartes de temp à combat
    begin
        randomize();
        rdm :=  random(stat.tailleCollection-i);
        DeckCombat[i] := tempDeck[rdm];
        DeckCombat[i].active:=False;
        DeckCombat[i].charges:=DeckCombat[i].chargesMax;
        for j := rdm to stat.tailleCollection-1-i do //réduction en continu de la taille de temp
        begin
            tempDeck[j] := tempDeck[j+1];
            setLength(tempDeck, stat.tailleCollection-i);
        end;
    end;
end;

// place la carte jouée au fond du paquet // prend en entrée un POINTEUR deck^
procedure cycle (var deck : TDeck ; i: Integer); // i = indice de la carte jouée
var j : Integer;
    mem : TCarte;
begin
    mem := deck[i];
    deck[i] := deck[3];

    for j:= 4 to High(deck)-1 do
        deck[j-1] := deck[j];

    deck[j] := mem ;
    deck[j].active:=False;
    deck[j].charges:=deck[j].chargesMax;
end;

// retire la dernière carte du paquet
procedure circoncision  (var deck : Tdeck);
begin
    setLength (deck , High(deck));
end;

//supprimer une carte de la collection
procedure supprimerCarte(var  stats : TStats; num : integer); // num : numéro de la carte
var i,j: integer;
begin
    i := 1 ;
    while (stats.collection[i].numero <> num) OR (i <= stats.tailleCollection) do // trouve la carte num
        i := i + 1;
    if (i <= stats.tailleCollection) then  // si trouvé alors supprimé et taille réduite
        for j:=i to stats.tailleCollection-1 do 
        begin
            stats.collection[j] := stats.collection[j+1];
            stats.tailleCollection := stats.tailleCollection -1;
        end;
end;

//Ajoute carte à la fin de la collection
procedure ajouterCarte(var stats : TStats ; num : integer); 
begin
    stats.tailleCollection := stats.tailleCollection + 1; //taille +1 
    stats.collection[stats.tailleCollection] := cartes[num]; //carte mise à la fin
end;

//Lancement du combat
procedure initStatsCombat(statsPerm:TStats;var statsTemp:TStats);
//var i:Integer;
begin
    //Création de la copie
    statsTemp:=statsPerm;
    creerDeckCombat(statsTemp,Pdeck);
    //Initialisation du deck pointé
    statsTemp.deck:=@pDeck;
    statsTemp.compteurLeMonde:=0;
    
    if statsTemp.deck=NIL then writeln('AVERTISSEMENT: DECK NON DEFINI');
    combatFini:=False;
    vagueFinie:=True;
end;

procedure creerEffet(x,y,w,h,frames:Integer;nom:PCHar;fixeJoueur:Boolean;var obj:TObjet); // crée un effet (objet sans collisions qui joue son animation puis s'efface)
begin
  InitAnimation(obj.anim,nom,'active',frames,False);
  obj.anim.estActif:=True;
  obj.stats.genre:=effet;
  
  createRawImage(obj.image,x,y,w,h,getFramePath(obj.anim));
  obj.col.estActif:=False;
  obj.col.nom:=nom;
  obj.stats.fixeJoueur:=fixeJoueur;
end;

procedure CreerRayon(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,w,xdest,ydest,vitRotation,dureeVie,delai:Integer;nom:PChar;var rayon:TObjet);
var norme:Real;destination,distance:array['X'..'Y'] of Integer;
begin
    //Initialisation des caractéristiques

    rayon.stats.genre:=laser;
    rayon.stats.degats:=flat;
    rayon.stats.force:=force;
    rayon.stats.multiplicateurDegat:=multiplicateurDegat;
    rayon.stats.origine:=origine;
    rayon.stats.xreel:=x-600;
    rayon.stats.yreel:=y-64;
    rayon.stats.vitRotation:=vitRotation;
    rayon.stats.dureeVie:=dureeVie;
    rayon.stats.dureeVieInit:=dureeVie;
    rayon.stats.delai:=delai;
    rayon.stats.delaiInit:=delai;

    //Initialisation de l'affichage
    InitAnimation(rayon.anim,nom,'start',5,False);
    rayon.anim.estActif:=True;
    CreateRawImage(rayon.image,x-600,y-64,1200,w,getFramePath(rayon.anim));
    

    //Initialisation de la boîte de collisions

    rayon.col.isTrigger := True;
    rayon.col.estActif := False;
    rayon.col.dimensions.w := rayon.image.rect.w-20;
    rayon.col.dimensions.h := w div 2;
    rayon.col.offset.x := 10;
    rayon.col.offset.y := w div 4;
    rayon.col.nom := 'rayon';

    destination['X']:=xdest;
    destination['Y']:=ydest;
    distance['X']:=destination['X']-x;
    distance['Y']:=destination['Y']-y;
    norme:=sqrt(distance['X']**2+distance['Y']**2);
    if norme<>0 then begin
        rayon.stats.vectX:=(distance['X']/norme);
        rayon.stats.vectY:=(distance['Y']/norme);
        end
    else begin 
        rayon.stats.vectX:=0;
        rayon.stats.vectY:=0;
        writeln('le rayon n"a pas pu être créé')
        end;
    //rayon.stats.vectX:=cos(arctan(rayon.stats.vectY/rayon.stats.vectX)-(40/180));
    //rayon.stats.vectY:=sin(arctan(rayon.stats.vectY/rayon.stats.vectX)-(40/180));
    if rayon.stats.vectX<0 then
        begin
        rayon.image.rect.x:=round(rayon.image.rect.x+rayon.stats.vectX*600);
        rayon.image.rect.y:=round(rayon.image.rect.y+rayon.stats.vecty*600);
        end
    else
        begin
        rayon.image.rect.x:=round(rayon.image.rect.x+rayon.stats.vectX*600);
        rayon.image.rect.y:=round(rayon.image.rect.y+rayon.stats.vecty*600);
        end;
    initAngle(rayon.stats.vectX,rayon.stats.vectY,rayon.stats.angle);
    //sdl_settexturealphamod(rayon.image.imgtexture,0);
end;

procedure updateRayon(var rayon:TObjet);
begin
    initAngle(rayon.stats.vectX,rayon.stats.vectY,rayon.stats.angle);;
    if (rayon.stats.delai>0) then //si le rayon n'est pas encore actif, il est transparent
        begin
        rayon.col.estActif:=False;
        if not leMonde then
            rayon.stats.delai:=rayon.stats.delai-1;
        //updateAnimation(rayon.anim,rayon.image);
        //sdl_settexturealphamod(rayon.image.imgtexture,max(200-round((rayon.stats.delai)/(rayon.stats.delaiInit)*200),0));

        if (rayon.stats.delaiInit>4) and (rayon.anim.currentFrame<4-(rayon.stats.delai div (rayon.stats.delaiInit div 4))) then
            updateAnimation(rayon.anim,rayon.image)
        end
    else
        if rayon.stats.delai=0 then //si le rayon atteint son délai, il s'active
            begin 
            initAnimation(rayon.anim,rayon.anim.objectName,'actif',5,False);
            rayon.col.estActif:=True;
            rayon.anim.estActif:=True;
            rayon.stats.delai:=-1;
            SDL_DestroyTexture(rayon.image.imgTexture);SDL_freeSurface(rayon.image.imgSurface);
            CreateRawImage(rayon.image,rayon.image.rect.x,rayon.image.rect.y,1200,rayon.image.rect.h,getFramePath(rayon.anim))
            end
    else
        if ((rayon.stats.dureeVie>4) and (rayon.anim.currentFrame<4-(rayon.stats.dureeVie div (rayon.stats.dureeVieInit div 4)))) or (rayon.stats.dureeVie<0) then
            updateAnimation(rayon.anim,rayon.image);
    if (rayon.stats.delai<0) and not (leMonde) then 
        rayon.stats.dureeVie:=rayon.stats.dureeVie-1;
    if (rayon.anim.currentFrame=rayon.anim.totalFrames) and (rayon.stats.dureeVie<=0) then
        supprimeObjet(rayon)
    else
        begin
        if rayon.stats.vectX>0 then //render du rayon du côté droit
            begin
            if (rayon.stats.vitRotation<>0) and (rayon.stats.delai<=0) and not(leMonde) then
                begin
                //mise à jour du vecteur de direction
                rayon.stats.vectX:=cos(rayon.stats.angle+(rayon.stats.vitRotation/180));
                rayon.stats.vectY:=sin(rayon.stats.angle+(rayon.stats.vitRotation/180)); 
                rayon.image.rect.x:=round(rayon.stats.xreel+rayon.stats.vectX*600);
                rayon.image.rect.y:=round(rayon.stats.yreel+rayon.stats.vecty*600);
                end
            end
        else if (rayon.stats.vectX<>0) then //render du rayon du côté gauche
            begin
            if (rayon.stats.vitRotation<>0) and (rayon.stats.delai<=0) and not(leMonde) then
                begin
                //mise à jour du vecteur de direction
                rayon.stats.vectX:=-cos(rayon.stats.angle+(rayon.stats.vitRotation/180));
                rayon.stats.vectY:=-sin(rayon.stats.angle+(rayon.stats.vitRotation/180)); 
                rayon.image.rect.x:=round(rayon.stats.xreel+rayon.stats.vectX*600);
                rayon.image.rect.y:=round(rayon.stats.yreel+rayon.stats.vecty*600);
                end
            end;
        end;
end;

procedure CreerBoule(   origine:TypeObjet ; 
                        flat,force:Integer ; 
                        multiplicateurDegat:Real ; 
                        x,y,w,h,vitesse,xdest,ydest:Integer; 
                        nom:PChar ;
                        var proj:TObjet); //Crée un project

var norme:Real;destination,distance:array['X'..'Y'] of Integer;
begin
        //Initialisation des caractéristiques

        proj.stats.genre:=projectile;
        proj.stats.degats:=flat;
        proj.stats.force:=force;
        proj.stats.xreel:=x;
        proj.stats.yreel:=y;
        proj.stats.multiplicateurDegat:=multiplicateurDegat;
        proj.stats.origine:=origine;

        //Initialisation de l'affichage
        if nom='justice' then
            InitAnimation(proj.anim,nom,'modeProj',6,true)
        else
            InitAnimation(proj.anim,nom,'active',8,true);
        proj.anim.estActif:=True;
        CreateRawImage(proj.image,x,y,w,h,getFramePath(proj.anim));

        //Initialisation de la boîte de collisions

        proj.col.isTrigger := True;
        proj.col.estActif := True;
        proj.col.dimensions.w := w div 2;
        proj.col.dimensions.h := h div 2;
        proj.col.offset.x := w div 5;
        proj.col.offset.y := h div 5;
        proj.col.nom := 'boule';

        //Création du vecteur de mouvement du projectile

        destination['X']:=xdest;
        destination['Y']:=ydest;
        distance['X']:=destination['X']-x;
        distance['Y']:=destination['Y']-y;
        norme:=sqrt(distance['X']**2+distance['Y']**2);
        if norme<>0 then begin
            proj.stats.vectX:=(distance['X']/norme)*vitesse;
            proj.stats.vectY:=(distance['Y']/norme)*vitesse;
            end
        else begin 
            proj.stats.vectX:=0;
            proj.stats.vectY:=0;
            end;
        initAngle(proj.stats.vectX,proj.stats.vectY,proj.stats.angle)

end;

procedure updateBoule(var proj:TObjet);
begin
    
    //vérifie si le projectile sort de l'écran
    if (proj.stats.xreel>1200) or (proj.stats.xreel<0) or (proj.stats.yreel>1000) or (proj.stats.yreel<0) then 

        begin
        supprimeObjet(proj);
        end

    else
        
        begin
        if not(leMonde) then
        begin

        //ajustement de la position: le projectile avance
        proj.stats.xreel:=proj.stats.xreel+(proj.stats.vectX);
        proj.stats.yreel:=proj.stats.yreel+(proj.stats.vectY);
        proj.image.rect.x:=round(proj.stats.xreel)-25;
        proj.image.rect.y:=round(proj.stats.yreel)-25;
        end;
        end
end;    

procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,h,vitesse,nb,range,angleDepart:Integer;nom:PChar);
var proj:TObjet;i:Integer;
begin
    for i:=0 to nb-1 do
        begin
        creerBoule(origine,degats,force,mult,x,y,w,h,vitesse,x+round(100*cos((i*2*pi+(angleDepart*pi/180))/(nb*360/range))),y+round(100*sin((i*2*pi+(angleDepart*pi/180))/(nb*360/range))),nom,proj);
        ajoutObjet(proj);
        end;
end;

procedure multiLasers(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,vitesse,nb,range,angleDepart,duree,delai:Integer;nom:PChar);
var rayon:TObjet;i:Integer;
begin
    for i:=0 to nb-1 do
        begin
        CreerRayon(origine,degats,force,mult,x,y,w,x+round(100*cos((i*2*pi+(angleDepart*pi/180))/((nb)*360/range))),y+round(100*sin((i*2*pi+(angleDepart*pi/180))/((nb)*360/range))),vitesse,duree,delai,nom,rayon);
        ajoutObjet(rayon);
        end;
end;

procedure InitJustice(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,xCible,yCible,vitesse,delai:Integer);
var justice:TObjet;
begin
    creerBoule(typeobjet(1),degats,force,mult,x,y,200,100,vitesse,xCible,yCible,'justice',justice);
    InitAnimation(justice.anim,justice.anim.objectname,'start',9,False);
    justice.anim.estActif:=True;
    justice.anim.currentFrame:=2;
    CreateRawImage(justice.image,x,y,200,100,getFramePath(justice.anim));
    initAngle(justice.stats.vectX,justice.stats.vectY,justice.stats.angle);
    justice.col.isTrigger := True;
    justice.col.dimensions.w := justice.image.rect.w-20;
    justice.col.dimensions.h := justice.image.rect.h div 2;
    justice.col.offset.x := 10;
    justice.col.offset.y := 30;
    justice.col.nom := 'Justice';
    justice.col.estActif:=False;
    justice.stats.xreel:=x;
    justice.stats.yreel:=y;
    justice.stats.genre:=epee;
    justice.stats.origine:=joueur;
    justice.stats.delai:=delai;
    ajoutObjet(justice);
end;

procedure renderAvecAngle(objet:TObjet);
begin
    if objet.stats.vectX>=0 then
        SDL_RenderCopyEx(sdlRenderer, objet.image.imgTexture, nil, @objet.image.Rect,180*objet.stats.angle/pi,nil, SDL_FLIP_NONE);
    if objet.stats.vectX<0 then
        SDL_RenderCopyEx(sdlRenderer, objet.image.imgTexture, nil, @objet.image.Rect,180*objet.stats.angle/pi,nil, SDL_FLIP_HORIZONTAL);
end;

procedure UpdateJustice(var justice:TObjet);
var angleDepart:Real;
begin
    if justice.stats.delai>0 then 
        begin
        initAngle(justice.stats.vectX,justice.stats.vectY,angleDepart);
        justice.stats.angle:=angleDepart-2*pi*sqrt(1-((justice.stats.delai)/51)**3);
        justice.image.rect.x:=round(justice.stats.xreel+justice.stats.vectX*(justice.stats.angle-angleDepart));
        justice.image.rect.y:=round(justice.stats.yreel+justice.stats.vecty*(justice.stats.angle-angleDepart));
        justice.stats.delai:=justice.stats.delai-1;
        //if justice.anim.currentFrame<>(50-justice.stats.delai) then
        updateAnimation(justice.anim,justice.image);
        
        
        end
    else if (justice.stats.delai=0) and not (leMonde) then
        begin
        justice.stats.xreel:=justice.image.rect.x;
        justice.stats.yreel:=justice.image.rect.y;
        justice.stats.delai:=-1;
        justice.col.estActif:=True;
        InitAnimation(justice.anim,'justice','active',10,false);
        justice.anim.currentFrame:=1;
        justice.col.estActif:=True;
        initAngle(justice.stats.vectX,justice.stats.vectY,justice.stats.angle);
        end
    else
    if not leMonde then
        begin
        updateAnimation(justice.anim,justice.image);
        justice.stats.xreel:=justice.stats.xreel+(justice.stats.vectX);
        justice.stats.yreel:=justice.stats.yreel+(justice.stats.vectY);
        justice.image.rect.x:=round(justice.stats.xreel);
        justice.image.rect.y:=round(justice.stats.yreel);
        //justice.stats.angle:=justice.stats.angle+1;
        end;
    //vérifie si le projectile sort de l'écran
    if (justice.stats.xreel>1200) or (justice.stats.xreel<-100) or (justice.stats.yreel>1000) or (justice.stats.yreel<-200) then 
        begin
        //initJustice(typeobjet(0),1,1,1,justice.image.rect.x,justice.image.rect.y,getmouseX,getmouseY,37,25);
        supprimeObjet(justice);
        end
    
end;

procedure subirDegats(var victime:TObjet;degats,knockbackX,knockbackY:Integer);
begin
    if (victime.stats.genre=joueur) and (victime.stats.leFou) then
        victime.stats.leFou:=False
    else
    if (victime.stats.genre=joueur) and (victime.stats.lamort) and (degats>victime.stats.vie) then
        victime.stats.vie:=1
    else
        victime.stats.vie:=victime.stats.vie-degats;
    if not (victime.stats.inamovible) then
        begin
        knockbackX:=max(min(knockbackX*2,5),-5);
        knockbackY:=max(min(knockbackY*2,5),-5);
        end;
    if (victime.anim.etat<>'degats') then begin 
        victime.stats.etatPrec:=victime.anim;
        victime.image.rect.x:=victime.image.rect.x+knockbackX;
        victime.image.rect.y:=victime.image.rect.y+knockbackY;
        if victime.stats.genre=TypeObjet(0) then
            initAnimation(victime.anim,victime.anim.objectname,'degats',4,False);
        if victime.stats.genre=TypeObjet(1) then
            victime.stats.compteurAction:=victime.stats.compteurAction+1;
    end;
end;


//----------------------------------------------
//-----------Déroulant des cartes---------------
//----------------------------------------------

    //1 Le batteleur
    procedure I_(s : TStats ; x,y : Integer);
    var proj : TObjet;
    begin
        creerBoule(joueur, 1, s.force, s.multiplicateurDegat, x, y,100,100, {vitesse} 10, getmouseX, getmouseY, 'projectile', proj);
        ajoutObjet(proj);
    end;

    //2 La papesse 
    procedure II(s : TStats ; x,y : integer);
    var proj : TObjet;
    begin
        CreerRayon(joueur , 2 , s.force , s.multiplicateurDegat , x,y,120, getmouseX,getmouseY,{vitRotation}0,{dureeVie}30,{delai}1, 'rayon', proj);
        ajoutObjet(proj);
    end;

    //3 L'impératrice
    procedure III(s : TStats ; x,y : integer);
    var proj : TObjet;
    begin
        CreerRayon(joueur , 3 , s.force , s.multiplicateurDegat , x,y,150, getmouseX,getmouseY,{vitRotation}0,{dureeVie}50,{delai}1, 'rayon', proj);
        ajoutObjet(proj);
    end;

    //4 L'empereur
    procedure IV(s : TStats ; x,y : Integer);
    var proj : TObjet;
    begin
        creerBoule(joueur, 3, s.force, s.multiplicateurDegat, x, y,100,100, {vitesse} 7, getmouseX, getmouseY, 'projectile', proj);
        ajoutObjet(proj);
    end;

    //5 Le pape
    procedure V(s : TStats ; x,y : Integer);
    var proj : TObjet;
    begin
        creerBoule(joueur, 6, s.force, s.multiplicateurDegat, x, y,150,150, {vitesse} 5, getmouseX, getmouseY, 'projectile', proj);
        ajoutObjet(proj);
    end;

    //6 les amants
    procedure VI(s : TStats ; x,y : Integer);
    var proj : TObjet;
        flat,i : integer;
    begin
        flat := 1;
        for i:=0 to high(s.deck^) do //augmente le flat pour chaque copie de la carte dans le deck
            if (s.deck^[i].numero = 6) then 
                flat := flat +1 ;
        
        creerBoule(joueur, flat, s.force, s.multiplicateurDegat, x, y,80,80, {vitesse} 10, getmouseX, getmouseY, 'projectile', proj);
        ajoutObjet(proj);

    end;

    //7 le chariot
    procedure VII(var s: TStats;x,y:Integer);
    var eff:TObjet;
    begin
        s.defense := s.defense + 3;
        //### à supprimer apres jouer
        creerEffet(0,0,140,140,12,'chariot2',True,eff);
        ajoutObjet(eff);
    end; 

    //8 la justice 
    procedure VIII(var sPerm, sCombat :Tstats;x,y,charges:Integer);
    begin
        if charges>=scombat.nbjustice then
            begin
            sPerm.nbJustice := sPerm.nbJustice + 1;
            sCombat.nbJustice := sCombat.nbJustice + 1;   //### à initialiser à 0 en débur de partie 
            end;
        initJustice(typeObjet(0),scombat.nbjustice,scombat.force,sCombat.multiplicateurDegat,x,y,getmousex,getmousey,28,50);
    end;
    
    //9 L'ermite
    procedure IX(var s : TStats);
    var eff:TObjet;
    begin
        s.multiplicateurMana := s.multiplicateurMana * 1.2;
        creerEffet(0,0,100,140,20,'ermite',True,eff);
        ajoutObjet(eff);
        //### à supprimer apres jouer

    end;

    //10 La roue de la fortune
    procedure X_(var s : TStats);
    var rdm : integer ;  eff:TObjet; 
    begin
        randomize;
        rdm := random(10)+1;

        case rdm of
            1,2,3 : degatInst(s, 5); //-5pv
            4 : s.force := s.force + 3; // +3 force
            5,6,7,8  : begin 
                s.mana := s.mana + 2;
                creerEffet(0,0,70,70,12,'plus',True,eff);
                ajoutObjet(eff);
                end;
                 //+2 mana
            //9,10 : rien 
        end;
    end;

    //11 La force
    procedure XI(var s : TStats);
    var eff:TObjet;
    begin
        s.force := s.force + 1;
        creerEffet(0,0,100,100,16,'force',True,eff);
        ajoutObjet(eff);
    end;

    //12 Le pendu
    procedure XII(var s : TStats);
    
    begin
        s.force := s.force + 5;
        s.defense := s.defense +5;
        s.multiplicateurMana := s.multiplicateurMana + 0.25;
        s.vitesse := s.vitesse + 1;

        //inverser les contrôles
        s.pendu := not(s.pendu); 
        //### mono usage


    end;

    //13 La mort
    procedure XIII(var s : Tstats);
    var eff:TObjet;
    begin
        s.laMort := True;
        updateTimeMort:=sdl_getticks;
        creerEffet(0,0,120,120,12,'mort',True,eff);
        ajoutObjet(eff);
    end;


    //14 La tempérance
    procedure XIV(var s : TStats);
    var eff:TObjet;
    begin
        s.defense := s.defense + 1;
        creerEffet(0,0,100,100,11,'chariot',True,eff);
        ajoutObjet(eff);
    end;

    //15 Le diable
    procedure XV(var sCombat, sPerm : TStats);
    var eff:TOBjet;
    begin
        degatInst(sCombat, 45); // infliger 45 dmg
        sCombat.defense := sCombat.defense + 1; //modifier le s en combat
        sPerm.defense := sPerm.defense + 1; // appliqué aussi au s de sauvegarde
        sCombat.multiplicateurDegat := sCombat.multiplicateurDegat + 0.5;
        sPerm.multiplicateurDegat := sPerm.multiplicateurDegat + 0.5;
        creerEffet(0,0,120,120,15,'diable',True,eff);
        ajoutObjet(eff);
    end;

    //16 La tour
    procedure XVI(s : TStats ; x,y : Integer);
    begin
        multiLasers(joueur, 2 ,s.force , s.multiplicateurDegat , x,y ,120, {vitesse} 0 ,4 ,360,0, 100 ,1,'rayon');
    end;

    //17 L'étoile
    procedure XVII(s : Tstats ; x,y : integer);
    begin
        multiLasers(joueur, 2 ,s.force , s.multiplicateurDegat , x,y ,120, {vitesse} 0 ,8 ,360,0, 100 ,1,'rayon');
    end;

    //18 La lune
    procedure XVIII(var s : Tstats ; x,y : integer);
    var flat, vitesse : integer;
        proj : Tobjet;
    begin
        case s.mana of 
            0 : begin flat := 0 ; vitesse := 10; end;
            1, 2 : begin flat := 1 ; vitesse := 10; end;
            3 : begin flat := 2 ; vitesse := 10;end;
            4 : begin flat := 3 ; vitesse := 10;end;
            5 : begin flat := 5 ; vitesse := 10;end;
            6 : begin flat := 8 ; vitesse := 10;end;
            7 : begin flat := 13 ; vitesse := 10;end;
            8 : begin flat := 21 ; vitesse := 10;end;
            9 : begin flat := 34 ; vitesse := 10;end;
            10 : begin flat := 55 ; vitesse := 10;end;
            11 : begin flat := 89 ; vitesse := 10;end; 
            12 : begin flat := 144 ; vitesse := 10;end;
            13 : begin flat := 233 ; vitesse := 10;end;
            14 : begin flat := 377 ; vitesse := 10;end;
        end;
        creerBoule(joueur, flat, s.force, s.multiplicateurDegat, x, y,s.mana*30,s.mana*30, vitesse, getmouseX, getmouseY, 'projectile', proj);
        s.mana:=0; //consomme tout le mana
        ajoutObjet(proj);
    end;

    //19 Le soleil
    procedure XIX(var s : TStats);
    var i : integer;eff:TObjet;
    begin
        degatInst(s, -5); // soin de 5 pv 
        for i := 0 to high(LOBjets) do
            if LOBjets[i].stats.genre=ennemi then
            begin
                degatInst(LObjets[i].stats,1);
                creerEffet(LObjets[i].image.rect.x+LObjets[i].col.offset.x,LObjets[i].image.rect.y+LObjets[i].col.offset.x,LObjets[i].col.dimensions.w,LObjets[i].col.dimensions.h,7,'impact_solaire',False,eff);
                ajoutObjet(eff);
            end;
        creerEffet(0,0,150,150,15,'soleil',True,eff);
        ajoutObjet(eff);
    end;

    //20 L'ange
    procedure XX(var s : Tstats);
    var eff:TObjet;
    begin
        degatInst(s, -20);
        creerEffet(0,0,150,150,15,'ange',True,eff);
        ajoutObjet(eff);
    end;

    //21 Le monde
    procedure XXI(var s : TStats);
    var eff:TObjet;
    begin
        s.compteurLemonde := s.compteurLemonde +1;
        leMonde:=True;
        updateTimeMonde:=sdl_getticks;
        creerEffet(0,0,150,150,6,'monde',True,eff);
        ajoutObjet(eff);
    end;
    
    //22 Le fou
    procedure __(var s:TStats);
    var eff:TObjet;
    begin
        s.lefou:=True;
        creerEffet(0,0,100,100,25,'fou',True,eff);
        ajoutObjet(eff);
    end;
//end

//###"La procédure ultime. On raconte que son accomplissement entraîne la fin de l'univers."
procedure JouerCarte(var stats:TStats;x,y:Integer;i:Integer); 

var tempCarte:TCarte;

begin
    tempCarte:=stats.deck^[i];
    if stats.deck^[i].active or (tempCarte.cout<=stats.mana) then 
        begin
        if not stats.deck^[i].active then
            begin
            stats.mana:=stats.mana-tempCarte.cout;
            stats.deck^[i].active:=True;
            if tempCarte.numero=8 then
                begin
                stats.deck^[i].chargesMax:=stats.nbJustice+1;
                end;
            stats.deck^[i].charges:=stats.deck^[i].chargesMax;
            end;
        stats.deck^[i].charges:=stats.deck^[i].charges-1;
        if stats.deck^[i].charges<=0 then
            cycle(stats.deck^,i);
        //Partie principale : tous les effets de cartes y seront répertoriés
        case tempCarte.numero of
            1: I_(stats,x,y);  
            2: II(stats,x,y);
            3: III(stats,x,y);
            4: IV(stats,x,y);
            5: V(stats,x,y);
            6: VI(stats,x,y);
            7: VII(stats,x,y);
            8: VIII(statsJoueur,stats,x,y,tempCarte.charges);
            9: IX(stats);
            10: X_(stats);
            11: XI(stats);
            12: XII(stats);
            13: XIII(stats);
            14: XIV(stats);
            15: XV(stats, statsJoueur);
            16: XVI(stats,x,y);
            17: XVII(stats,x,y);
            18: XVIII(stats,x,y);
            19: XIX(stats);
            20: XX(stats);
            21: XXI(stats);
            22: __(stats);
            else 
            writeln('???')
            end;
        end;


end;

begin
leMonde:=False;

end.