unit CombatLib;

interface

uses
    animationSys,
    coeur,
    collisionSys,
    eventSys,
    math,
    memgraph,
    SDL2;

var leMonde:Boolean;

function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;
procedure RegenMana(var LastUpdateTime : UInt32;var mana:Integer;manaMax:Integer;multiplicateurMana:Real); 
procedure CreerDeckCombat(stat : TStats;var DeckCombat:TDeck); 
procedure cycle (var deck : TDeck ; i : Integer);
procedure circoncision  (var deck : Tdeck);
procedure initStatsCombat(statsPerm:TStats;var statsTemp:TStats);
//procedure CreerBoule(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,vitesse,xdest,ydest:Integer;nom:PChar;var proj:TObjet);
procedure updateBoule(var proj:TObjet);
procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,vitesse,nb,range,angleDepart:Integer;nom:PChar);
procedure multiLasers(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,vitesse,nb,range,angleDepart,duree,delai:Integer;nom:PChar);
//procedure CreerRayon(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,xdest,ydest,vitRotation,dureeVie:Integer;nom:PChar;var rayon:TObjet);
procedure updateRayon(var rayon:TObjet);
procedure UpdateJustice(var justice:TObjet);
procedure JouerCarte(var deck:TDeck;i,force:Integer;multiplicateurDegat:Real;var vie,mana:Integer;x,y:Integer);  



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
function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;
begin

    degat := math.ceil((flat + force - defence)*multiplicateurDegat);
    if degat < 1 then
        degat := 1;
end;

//procedure de dégat instantané : inflige des dégat FLAT 
procedure degatInst (var vie : Integer ; degat : integer );
begin
    vie := vie - degat;
end;


//Procedure Régénération du mana
procedure RegenMana(var LastUpdateTime : UInt32;var mana:Integer;manaMax:Integer;multiplicateurMana:Real);
var 
    currentTime: UInt32;
    

begin

        SDL_PumpEvents;
        currentTime := SDL_GetTicks(); //récupère le temps
        //writeln(currentTime,' comparé à ',lastUpdateTime);
        //writeln((( (currentTime - LastUpdateTime)*LObjets[0].stats.multiplicateurMana)>= 1000),' and ',(LObjets[0].stats.mana < LObjets[0].stats.manaMax));
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
procedure supprimerCarte(var  stats : TStats; num : integer);
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

//procedure ajouterCarte(var stats : TStats ; num : integer); //### faire une liste des toutes les cartes

//Lancement du combat
procedure initStatsCombat(statsPerm:TStats;var statsTemp:TStats);
//var i:Integer;
begin
    //Création de la copie
    statsTemp:=statsPerm;
    creerDeckCombat(statsTemp,Pdeck);
    //Initialisation du deck pointé
    statsTemp.deck:=@pDeck;
    if statsTemp.deck=NIL then writeln('AVERTISSEMENT: DECK NON DEFINI')
end;

procedure CreerRayon(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,xdest,ydest,vitRotation,dureeVie,delai:Integer;nom:PChar;var rayon:TObjet);
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
    rayon.stats.delai:=delai;

    //Initialisation de l'affichage
    InitAnimation(rayon.anim,nom,'actif',4,False);
    rayon.anim.estActif:=True;
    CreateRawImage(rayon.image,x-600,y-64,1200,120,getFramePath(rayon.anim));

    //Initialisation de la boîte de collisions

    rayon.col.isTrigger := True;
    rayon.col.estActif := True;
    rayon.col.dimensions.w := rayon.image.rect.w-20;
    rayon.col.dimensions.h := 50;
    rayon.col.offset.x := 10;
    rayon.col.offset.y := 50;
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
        end
        
end;

procedure updateRayon(var rayon:TObjet);
begin
    if round(rayon.stats.vectX*1000)=0 then //on définit l'angle en faisant attention de ne pas diviser par 0
        if rayon.stats.vectY>0 then
            rayon.stats.angle:=pi/2
        else
            rayon.stats.angle:=-pi/2
    else
        rayon.stats.angle:=arctan(rayon.stats.vectY/rayon.stats.vectX);
    if rayon.stats.delai>0 then //si le rayon n'est pas encore actif, il est transparent
        begin
        rayon.col.estActif:=False;
        rayon.stats.delai:=rayon.stats.delai-1;
        sdl_settexturealphamod(rayon.image.imgtexture,200-(rayon.stats.delai)*4)
        end
    else
        begin //si le rayon atteint son délai, il s'active
        sdl_settexturealphamod(rayon.image.imgtexture,255);
        rayon.col.estActif:=True;
        if rayon.stats.dureeVie<=0 then updateanimation(rayon.anim,rayon.image)
        else rayon.stats.dureeVie:=rayon.stats.dureeVie-1;
        end;
    if (rayon.anim.currentFrame=rayon.anim.totalFrames) then
            supprimeObjet(rayon)
    else
        begin
        if rayon.stats.vectX>0 then //render du rayon du côté droit
            begin
            SDL_RenderCopyEx(sdlRenderer, rayon.image.imgTexture, nil, @rayon.image.Rect,rayon.stats.angle*180/pi,nil, SDL_FLIP_NONE);
            if (rayon.stats.vitRotation<>0) and (rayon.stats.delai<=0) then
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
            SDL_RenderCopyEx(sdlRenderer, rayon.image.imgTexture, nil, @rayon.image.Rect,rayon.stats.angle*180/pi,nil, SDL_FLIP_HORIZONTAL);
            if (rayon.stats.vitRotation<>0) and (rayon.stats.delai<=0) then
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

procedure CreerBoule(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,vitesse,xdest,ydest:Integer;nom:PChar;var proj:TObjet); //Crée un project
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
        
        InitAnimation(proj.anim,nom,'active',8,true);
        proj.anim.estActif:=True;
        CreateRawImage(proj.image,x,y,100,100,getFramePath(proj.anim));

        //Initialisation de la boîte de collisions

        proj.col.isTrigger := True;
        proj.col.estActif := True;
        proj.col.dimensions.w := proj.image.rect.w-20;
        proj.col.dimensions.h := proj.image.rect.h div 2;
        proj.col.offset.x := 10;
        proj.col.offset.y := 30;
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
            end

end;

procedure updateBoule(var proj:TObjet);
begin

    //vérifie si le projectile sort de l'écran
    if (proj.stats.xreel>1200) or (proj.stats.xreel<0) or (proj.stats.yreel>1000) or (proj.stats.yreel<0) then 

        begin
        supprimeObjet(proj);
        end

    else
        if not(leMonde) then
        begin

        begin

        //ajustement de la position: le projectile avance
        proj.stats.xreel:=proj.stats.xreel+(proj.stats.vectX);
        proj.stats.yreel:=proj.stats.yreel+(proj.stats.vectY);
        proj.image.rect.x:=round(proj.stats.xreel)-25;
        proj.image.rect.y:=round(proj.stats.yreel)-25;
        //affichage inversé ou non selon la direction
            if proj.stats.vectX>0 then
            SDL_RenderCopyEx(sdlRenderer, proj.image.imgTexture, nil, @proj.image.Rect,180*(arctan(proj.stats.vectY/proj.stats.vectX))/pi,nil, SDL_FLIP_NONE);
            if proj.stats.vectX<0 then
            SDL_RenderCopyEx(sdlRenderer, proj.image.imgTexture, nil, @proj.image.Rect,180*(arctan(proj.stats.vectY/proj.stats.vectX))/pi,nil, SDL_FLIP_HORIZONTAL);
        end
end;    

procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,vitesse,nb,range,angleDepart:Integer;nom:PChar);
var proj:TObjet;i:Integer;

begin
    for i:=0 to nb-1 do
        begin
        creerBoule(origine,degats,force,mult,x,y,vitesse,x+round(100*cos((i*2*pi+(angleDepart*pi/180))/(nb*360/range))),y+round(100*sin((i*2*pi+(angleDepart*pi/180))/(nb*360/range))),nom,proj);
        ajoutObjet(proj);
        end;
end;

procedure multiLasers(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,vitesse,nb,range,angleDepart,duree,delai:Integer;nom:PChar);
var rayon:TObjet;i:Integer;

begin
    for i:=0 to nb-1 do
        begin
        CreerRayon(origine,degats,force,mult,x,y,x+round(100*cos((i*2*pi+(angleDepart*pi/180))/(nb*360/range))),y+round(100*sin((i*2*pi+(angleDepart*pi/180))/(nb*360/range))),vitesse,duree,delai,nom,rayon);
        ajoutObjet(rayon);
        end;
end;

procedure InitJustice(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,xCible,yCible,vitesse,delai:Integer);
var justice:TObjet;
begin
    creerBoule(typeobjet(1),degats,force,mult,x,y,vitesse,xCible,yCible,'justice',justice);
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
        justice.image.rect.x:=round(justice.stats.xreel)-25;
        justice.image.rect.y:=round(justice.stats.yreel)-25;
        //justice.stats.angle:=justice.stats.angle+1;
        end;
    if justice.stats.vectX>0 then
        SDL_RenderCopyEx(sdlRenderer, justice.image.imgTexture, nil, @justice.image.Rect,180*justice.stats.angle/pi,nil, SDL_FLIP_NONE);
    if justice.stats.vectX<0 then
        SDL_RenderCopyEx(sdlRenderer, justice.image.imgTexture, nil, @justice.image.Rect,180*justice.stats.angle/pi,nil, SDL_FLIP_HORIZONTAL);
    //vérifie si le projectile sort de l'écran
    if (justice.stats.xreel>1200) or (justice.stats.xreel<-100) or (justice.stats.yreel>1000) or (justice.stats.yreel<-200) then 
        begin
        //initJustice(typeobjet(0),1,1,1,justice.image.rect.x,justice.image.rect.y,getmouseX,getmouseY,37,25);
        supprimeObjet(justice);
        end
    
end;

//###"La procédure ultime. On raconte que son accomplissement entraîne la fin de l'univers."
procedure JouerCarte(var deck:TDeck;i,force:Integer;multiplicateurDegat:Real;var vie,mana:Integer;x,y:Integer); 

var tempCarte:TCarte;projectile:TOBjet;

begin
    tempCarte:=deck[i];
    if True or deck[i].active or (tempCarte.cout<=mana) then 
        begin
        if not deck[i].active then
            begin
            mana:=mana-tempCarte.cout;
            deck[i].active:=True;
            end;
        deck[i].charges:=deck[i].charges-1;
        //writeln('carte active : ',deck[i].active,' , nb charges : ',deck[i].charges);
        if deck[i].charges=0 then
            cycle(deck,i);
        //Partie principale : tous les effets de cartes y seront répertoriés
        case tempCarte.numero of
            0:writeln('???')
            else 
                begin //!! création d'un projectile ( les éventuelles variations sont sur le 2ème élément (les dégâts), celui avant getmousex (la vitesse) et l'avant-dernier (pour l'image)), pareil pour un rayon mais sans la vitesse
                
                //on peut aussi utiliser MultiProjs pour un arc de cercle si il faut
                //creerBoule(typeobjet(0),1,force,multiplicateurDegat,x,y,5,getmouseX,getmouseY,'projectile',projectile);
                //CreerRayon(typeobjet(0),2,force,multiplicateurDegat,x,y,getmouseX,getmouseY,0,10,'rayon',projectile);
                //ajoutObjet(projectile);
                initJustice(typeobjet(0),1,force,multiplicateurDegat,x,y,getmouseX,getmouseY,37,50);
                //multiProjs(TypeObjet(0),1,1,1,x,y,5,3,360,random(18)*10,'projectile');
                end
            end;
        end;


end;

begin
leMonde:=False;

end.