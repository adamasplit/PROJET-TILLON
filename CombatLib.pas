unit CombatLib;

interface

uses
    AnimationSys,
    coeur,
    eventSys,
    math,
    memgraph,
    SDL2,
    sdl2_mixer,
    SonoSys,
    fichierSys,
    sysutils;

var updateTimeMonde:UInt32;updateTimeMort:UInt32;

function degat(flat : Integer ; force : Integer ; defense : Integer;multiplicateurDegat:Real;cap:Boolean): Integer;
procedure RegenMana(var LastUpdateTime : UInt32;var mana:Integer;manaMax:Integer;relique:Integer;var vie:Integer;multiplicateurMana:Real);
procedure CreerDeckCombat(stat : TStats;var DeckCombat:TDeck); 
function trouverCarte(stats:TStats;num:Integer):Boolean;
procedure cycle (var deck : TDeck ; i : Integer);
procedure circoncision  (var deck : Tdeck);
procedure initStatsCombat(statsPerm:TStats;var statsTemp:TStats);
procedure CreerBoule(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,w,h,vitesse,xdest,ydest:Integer;nom:PChar;var proj:TObjet);
procedure updateBoule(var proj:TObjet);
procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,h,vitesse,nb,range,angleDepart:Integer;nom:PChar);overload;
procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,h,vitesse,nb,range:Integer;angleDepart:Real;nom:PChar);overload;
procedure multiLasers(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,l,w,vitesse,nb,range,angleDepart,duree,delai:Integer;nom:PChar);
procedure CreerRayon(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;volVie:Boolean;x,y,l,w,xdest,ydest:Integer;vitRotation:Real;dureeVie,delai:Integer;nom:PChar;var rayon:TObjet);
procedure updateRayon(var rayon:TObjet);
procedure createAfterimage(obj:TObjet;duree:Integer);
procedure UpdateJustice(var justice:TObjet);
procedure ajouterCarte(var stats : TStats ; num : integer); 
procedure updateAttaques();
procedure XXIII(origine:typeObjet;s:TStats;x,y,xcible,ycible,delai:Integer);
procedure renderAvecAngle(objet:TObjet);
procedure creerEffet(x,y,w,h,frames:Integer;nom:PCHar;fixeJoueur:Boolean;var obj:TObjet);
procedure InitJustice(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,xCible,yCible,vitesse,delai:Integer;dir:PChar);
procedure subirDegats(var victime:TObjet;degats,knockbackX,knockbackY:Integer);overload;
procedure subirDegats(var stats:TStats;degats,x,y:Integer);overload;
procedure JouerCarte(var stats:TStats;x,y,i:Integer); 
procedure InitAngle(vectX,vectY:Real;var angle:Real);
procedure supprimerCarte(var  stats : TStats; num : integer);



implementation



procedure InitAngle(vectX,vectY:Real;var angle:Real); //calcule un angle à partir d'un vecteur de direction
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
function degat(flat : Integer ; force : Integer ; defense : Integer;multiplicateurDegat:Real;cap:Boolean): Integer;
begin

    degat := math.ceil((flat + force - defense)*multiplicateurDegat);
    if (degat < flat) and cap then
        degat := flat+((flat+force-defense) div 5); 
    if degat < 1 then
        degat := 1; 
end;


//Procedure Régénération du mana
procedure RegenMana(var LastUpdateTime : UInt32;var mana:Integer;manaMax:Integer;relique:Integer;var vie:Integer;multiplicateurMana:Real);
var 
    currentTime: UInt32;
    

begin

        SDL_PumpEvents;
        currentTime := SDL_GetTicks(); //récupère le temps
        if (( (currentTime - LastUpdateTime)*multiplicateurMana)>= 1000) AND ((mana < manaMax) or (relique=10)) then //attendre 1sec/mult avant +1 mana
        begin
            mana := mana + 1; //régénère le mana
            LastUpdateTime := currentTime;
        end;
        if (relique=10) and (mana>manaMax) then
            begin
            vie:=vie+(mana-manaMax);
            mana:=manaMax;
            end
        else
            if mana>manaMax*2 then mana:=manaMax*2
            

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

// retire la dernière carte du paquet+réduit sa taille
procedure circoncision  (var deck : Tdeck);
begin
    sdl_destroytexture(deck[high(deck)].image.imgTexture);
    sdl_freeSurface(deck[high(deck)].image.imgsurface);
    setLength (deck , High(deck));
end;

function trouverCarte(stats:TStats;num:Integer):Boolean;
var i:Integer;
begin
    trouverCarte:=False;
    for i:=1 to stats.tailleCollection do
        if stats.collection[i].numero=num then
            trouverCarte:=True;
end;
//supprimer une carte de la collection
procedure supprimerCarte(var  stats : TStats; num : integer); // num : numéro de la carte
var i,j: integer;
begin
    i := 1 ;
    while (stats.collection[i].numero <> num) and (i <= stats.tailleCollection) do // trouve la carte num
        begin
        i := i + 1;
        end;
    if (i <= stats.tailleCollection) then  // si trouvé alors supprimé et taille réduite
        for j:=i to stats.tailleCollection-1 do 
        begin
            stats.collection[j] := stats.collection[j+1];
        end;
    stats.tailleCollection := stats.tailleCollection -1;
end;

// place la carte jouée au fond du paquet // prend en entrée un POINTEUR deck^
procedure cycle (var deck : TDeck ; i: Integer); // i = indice de la carte jouée
var j : Integer;
    mem : TCarte;
begin
    //retire une carte de la collection (pour certaines cartes à usage unique)
    if (deck[i].numero=15) or (deck[i].numero=27) or (deck[i].numero=28) then
        begin
        supprimerCarte(statsJoueur,deck[i].numero);
        end;
    if high(deck)>2 then
    begin
    mem := deck[i];
    deck[i] := deck[3];

    if high(deck)=3 then
        j:=3
    else
        for j:= 3 to High(deck)-1 do //décale toutes les cartes du deck
            begin
            deck[j] := deck[j+1];
            end;

    if mem.discard then //certaines cartes sont mises dans la défausse (deck réduit jusqu'à la fin du combat)
        begin
        circoncision(deck);
        end
    else
        begin
        //carte envoyée au fond du deck
        deck[high(deck)] := mem ;
        deck[high(deck)].active:=False;
        deck[high(deck)].charges:=deck[high(deck)].chargesMax;
        end
    end
    else
        begin
        deck[i].active:=False;
        deck[i].charges:=deck[i].chargesMax;
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
    initAnimation(LObjets[0].anim,LObjets[0].anim.objectName,'idle',12,True);
    //Création de la copie
    statsTemp:=statsPerm;
    statsTemp.mana:=statsPerm.manaDebutCombat;
    creerDeckCombat(statsTemp,Pdeck);
    //Initialisation du deck pointé
    statsTemp.deck:=@pDeck;
    statsTemp.compteurLeMonde:=0;
    LObjets[0].image.rect.x:=WINDOWWIDTH div 2 - 50;
    LObjets[0].image.rect.y:=WINDOWHEIGHT div 2 + 50;
    if statsTemp.deck=NIL then //writeln('AVERTISSEMENT: DECK NON DEFINI');
    combatFini:=False;
    vagueFinie:=True;
end;

procedure creerEffet(x,y,w,h,frames:Integer;nom:PCHar;fixeJoueur:Boolean;var obj:TObjet); // crée un effet (objet sans collisions qui joue son animation puis s'efface)
begin
  InitAnimation(obj.anim,nom,'active',frames,False);
  obj.anim.estActif:=True;
  obj.stats.genre:=effet;
  if nom<>'impact' then
    jouerSonEff(nom);
  createRawImage(obj.image,x,y,w,h,getFramePath(obj.anim));
  obj.col.estActif:=False;
  obj.col.nom:=nom;
  obj.stats.fixeJoueur:=fixeJoueur;
end;

procedure CreerRayon(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;volVie:Boolean;x,y,l,w,xdest,ydest:Integer;vitRotation:Real;dureeVie,delai:Integer;nom:PChar;var rayon:TObjet);
var norme:Real;destination,distance:array['X'..'Y'] of Integer;i:Integer;
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
    rayon.stats.volVie:=volVie;

    //Initialisation de l'affichage
    InitAnimation(rayon.anim,nom,'start',5,False);
    rayon.anim.estActif:=True;
    CreateRawImage(rayon.image,x-(l div 2),y-64,l,w,getFramePath(rayon.anim));
    
    //Initialisation de la boîte de collisions

    rayon.col.isTrigger := True;
    rayon.col.estActif := False;
    rayon.col.dimensions.w := rayon.image.rect.w-20;
    rayon.col.dimensions.h := w div 2;
    rayon.col.offset.x := 10;
    rayon.col.offset.y := w div 4;
    rayon.col.nom := 'rayon';
    for i:=0 to 3 do
        rayon.col.collisionsFaites[i]:=False;

    //initialisation du vecteur de direction, basée sur la destination
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
        //writeln('le rayon n"a pas pu être créé')
        end;
    if rayon.stats.vectX<0 then
        begin
        rayon.image.rect.x:=round(rayon.image.rect.x+rayon.stats.vectX*(rayon.image.rect.w div 2));
        rayon.image.rect.y:=round(rayon.image.rect.y+rayon.stats.vecty*(rayon.image.rect.w div 2));
        end
    else
        begin
        rayon.image.rect.x:=round(rayon.image.rect.x+rayon.stats.vectX*(rayon.image.rect.w div 2));
        rayon.image.rect.y:=round(rayon.image.rect.y+rayon.stats.vecty*(rayon.image.rect.w div 2));
        end;
    initAngle(rayon.stats.vectX,rayon.stats.vectY,rayon.stats.angle);
    rayon.stats.xreel:=x-(l div 2);
    rayon.stats.yreel:=y-64;
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
            if rayon.anim.objectName<>'rayon' then jouerSonEff(rayon.anim.objectName);
            rayon.col.estActif:=True;
            rayon.anim.estActif:=True;
            rayon.stats.delai:=-1;
            SDL_DestroyTexture(rayon.image.imgTexture);SDL_freeSurface(rayon.image.imgSurface);
            CreateRawImage(rayon.image,rayon.image.rect.x,rayon.image.rect.y,rayon.image.rect.w,rayon.image.rect.h,getFramePath(rayon.anim))
            end
    else
        if (not leMonde) and (((rayon.stats.dureeVie>5) and (rayon.anim.currentFrame<5-(rayon.stats.dureeVie div (rayon.stats.dureeVieInit div 5)))) or (rayon.stats.dureeVie<0)) then
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
                rayon.image.rect.x:=round(rayon.stats.xreel+rayon.stats.vectX*(rayon.image.rect.w div 2));
                rayon.image.rect.y:=round(rayon.stats.yreel+rayon.stats.vecty*(rayon.image.rect.w div 2));
                end
            end
        else if (rayon.stats.vectX<>0) then //render du rayon du côté gauche
            begin
            if (rayon.stats.vitRotation<>0) and (rayon.stats.delai<=0) and not(leMonde) then
                begin
                //mise à jour du vecteur de direction
                rayon.stats.vectX:=-cos(rayon.stats.angle+(rayon.stats.vitRotation/180));
                rayon.stats.vectY:=-sin(rayon.stats.angle+(rayon.stats.vitRotation/180)); 
                rayon.image.rect.x:=round(rayon.stats.xreel+rayon.stats.vectX*(rayon.image.rect.w div 2));
                rayon.image.rect.y:=round(rayon.stats.yreel+rayon.stats.vecty*(rayon.image.rect.w div 2));
                end
        else
            begin
                if (rayon.stats.vitRotation<>0) and (rayon.stats.delai<=0) and not(leMonde) then
                begin
                //writeln('/?');
                //mise à jour du vecteur de direction
                rayon.stats.vectX:=cos(rayon.stats.angle+(rayon.stats.vitRotation/180));
                rayon.stats.vectY:=sin(rayon.stats.angle+(rayon.stats.vitRotation/180)); 
                rayon.image.rect.x:=round(rayon.stats.xreel+rayon.stats.vectX*(rayon.image.rect.w div 2));
                rayon.image.rect.y:=round(rayon.stats.yreel+rayon.stats.vecty*(rayon.image.rect.w div 2));
                end
            end
            end;
        end;
end;

procedure CreerBoule(   origine:TypeObjet ; 
                        flat,force:Integer ; 
                        multiplicateurDegat:Real ; 
                        x,y,w,h,vitesse,xdest,ydest:Integer; 
                        nom:PChar ;
                        var proj:TObjet); //Crée un projectile

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
        proj.stats.vitDep:=vitesse;
        proj.stats.volvie:=False;
        proj.stats.dureeVie:=0;

        if (nom='projectile') and (origine=joueur) then
            jouerSonEff('Arc ('+intToSTr(random(6)+1)+')');

        //Initialisation de l'affichage
        if nom='justice' then
            InitAnimation(proj.anim,nom,'modeProj',6,true)
        else
            InitAnimation(proj.anim,nom,'active',8,true);
        proj.anim.estActif:=True;
        CreateRawImage(proj.image,x-25,y-25,w,h,getFramePath(proj.anim));
        if (nom='onde') and (origine=joueur) then
            if vitesse mod 2 = 0 then
                proj.stats.vitRotation:=proj.stats.vitDep
            else
                proj.stats.vitRotation:=-proj.stats.vitDep
        else
            if (nom='tornade') and (origine=joueur) then
                proj.stats.vitRotation:=proj.stats.vitDep
            else
                proj.stats.vitRotation:=0;
        //Initialisation de la boîte de collisions

        proj.col.isTrigger := True;
        proj.col.estActif := True;
        proj.col.dimensions.w := w*2 div 8;
        proj.col.dimensions.h := h*2 div 8;
        proj.col.offset.x := w*3 div 8;
        proj.col.offset.y := h*3 div 8;
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
        initAngle(proj.stats.vectX,proj.stats.vectY,proj.stats.angle);

end;

procedure updateBoule(var proj:TObjet);
begin
    
    //vérifie si le projectile sort de l'écran
    if (proj.anim.objectName<>'meteore') and ((proj.anim.objectName<>'Roue') or (proj.stats.origine=ennemi)) and ((proj.stats.dureeVie>350) or (proj.stats.xreel>1200) or (proj.stats.xreel<0) or (proj.stats.yreel>1000) or (proj.stats.yreel<0)) then 

        begin
        supprimeObjet(proj);
        end

    else
        
        begin
        if not(leMonde) then
            begin
            if (proj.stats.dureeVie>300) and (proj.anim.objectName<>'meteore') and ((proj.anim.objectName<>'Roue') or (proj.stats.origine=ennemi)) then
                sdl_settexturealphamod(proj.image.imgTexture,max(0,1+round((350-proj.stats.dureeVie)/50*200)));
            proj.stats.dureeVie:=proj.stats.dureeVie+1;
            //ajustement de la position: le projectile avance
            proj.stats.xreel:=proj.stats.xreel+(proj.stats.vectX);
            proj.stats.yreel:=proj.stats.yreel+(proj.stats.vectY);
            proj.image.rect.x:=round(proj.stats.xreel)-(proj.image.rect.w div 2);
            proj.image.rect.y:=round(proj.stats.yreel)-(proj.image.rect.h div 2);
            initAngle(proj.stats.vectX,proj.stats.vectY,proj.stats.angle);
            if proj.stats.vitRotation<>0 then
                begin
                proj.stats.angle:=proj.stats.angle+proj.stats.vitRotation/180;
                if proj.stats.vectX>0 then
                    begin
                    proj.stats.vectX:=proj.stats.vitDep*cos(proj.stats.angle);
                    proj.stats.vectY:=proj.stats.vitDep*sin(proj.stats.angle);
                    end
                else
                    begin
                    proj.stats.vectX:=-proj.stats.vitDep*cos(proj.stats.angle);
                    proj.stats.vectY:=-proj.stats.vitDep*sin(proj.stats.angle);
                    end
                end
            end;
        end
end;    

procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,h,vitesse,nb,range,angleDepart:Integer;nom:PChar);
var proj:TObjet;i:Integer;
begin
    //crée un nombre nb de projectiles envoyés en cercle ou arc de cercle
    for i:=0 to nb-1 do
        begin
        creerBoule(origine,degats,force,mult,x,y,w,h,vitesse,x+round(100*cos((i*2*pi)/(nb*360/range)+(angleDepart*pi/180))),y+round(100*sin((i*2*pi)/(nb*360/range)+(angleDepart*pi/180))),nom,proj);
        ajoutObjet(proj);
        end;
end;

//même chose avec un angle de départ en radians
procedure multiProjs(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,w,h,vitesse,nb,range:Integer;angleDepart:Real;nom:PChar);
var proj:TObjet;i:Integer;
begin
    //crée un nombre nb de projectiles envoyés en cercle ou arc de cercle
    for i:=0 to nb-1 do
        begin
        creerBoule(origine,degats,force,mult,x,y,w,h,vitesse,x+round(100*cos((i*2*pi)/(nb*360/range)+angleDepart)),y+round(100*sin((i*2*pi)/(nb*360/range)+angleDepart)),nom,proj);
        ajoutObjet(proj);
        end;
end;

procedure multiLasers(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,l,w,vitesse,nb,range,angleDepart,duree,delai:Integer;nom:PChar);
var rayon:TObjet;i:Integer;
begin
    //crée un nombre nb de rayons répartis en cercle
    for i:=0 to nb-1 do
        begin
        CreerRayon(origine,degats,force,mult,False,x,y,l,w,x+round(100*cos((i*2*pi+(angleDepart*pi/180))/((nb)*360/range))),y+round(100*sin((i*2*pi+(angleDepart*pi/180))/((nb)*360/range))),vitesse,duree,delai,nom,rayon);
        ajoutObjet(rayon);
        end;
end;

procedure InitJustice(origine:TypeObjet;degats,force:Integer;mult:Real;x,y,xCible,yCible,vitesse,delai:Integer;dir:PChar);
var justice:TObjet;
begin
    //initialisation comme un projectile
    creerBoule(origine,degats,force,mult,x,y,200,100,vitesse,xCible,yCible,dir,justice);
    //modification de l'image utilisée
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
    //initialisation des caractéristiques
    justice.stats.xreel:=x;
    justice.stats.yreel:=y;
    justice.stats.targetx:=xcible;
    justice.stats.targety:=ycible;
    justice.stats.genre:=epee;
    justice.stats.origine:=origine;
    justice.stats.delai:=delai;
    justice.stats.delaiInit:=delai;
    justice.stats.vitDep:=vitesse;
    justice.stats.volvie:=False;
    ajoutObjet(justice);
end;

procedure renderAvecAngle(objet:TObjet);
begin
    if (objet.stats.vectX>=0) then
        SDL_RenderCopyEx(sdlRenderer, objet.image.imgTexture, nil, @objet.image.Rect,180*objet.stats.angle/pi,nil, SDL_FLIP_NONE)
    else
        SDL_RenderCopyEx(sdlRenderer, objet.image.imgTexture, nil, @objet.image.Rect,180*objet.stats.angle/pi,nil, SDL_FLIP_HORIZONTAL);
end;

procedure UpdateJustice(var justice:TObjet);
var angleDepart:Real;i:Integer;
begin
    if (justice.anim.objectName='justiceRykor') and (justice.stats.delai>0) then
            begin
            SDL_setRenderDrawColor(sdlRenderer,255,255,255,255);
            sdl_renderDrawLINE(sdlRenderer,round(trouvercentrex(justice)+justice.stats.vectY/3),round(trouvercentrey(justice)+justice.stats.vectX/3),round(justice.stats.targetX+5*(justice.stats.targetX-trouvercentrex(justice))+justice.stats.vectY/3),round(justice.stats.targetY+5*(justice.stats.targetY-trouvercentreY(justice))+justice.stats.vectX/3));
            sdl_renderDrawLINE(sdlRenderer,round(trouvercentrex(justice)-justice.stats.vectY/3),round(trouvercentrey(justice)-justice.stats.vectX/3),round(justice.stats.targetX+5*(justice.stats.targetX-trouvercentrex(justice))-justice.stats.vectY/3),round(justice.stats.targetY+5*(justice.stats.targetY-trouvercentreY(justice))-justice.stats.vectX/3));
            end;
    if (justice.stats.delai>0) and ((not leMonde) or (justice.stats.origine=joueur)) then 
        //phase initiale: 
        begin
        initAngle(justice.stats.vectX,justice.stats.vectY,angleDepart);
        justice.stats.angle:=angleDepart-2*pi*sqrt(1-((justice.stats.delai)/(justice.stats.delaiInit+1))**2);
        justice.image.rect.x:=round(justice.stats.xreel+min(100,justice.stats.delaiInit)/60*justice.stats.vectX*(justice.stats.angle-angleDepart));
        justice.image.rect.y:=round(justice.stats.yreel+min(100,justice.stats.delaiInit)/60*justice.stats.vecty*(justice.stats.angle-angleDepart));
        justice.stats.delai:=justice.stats.delai-1;
        updateAnimation(justice.anim,justice.image);
        end
    else if (justice.stats.delai=0) and not (leMonde) then //si la justice a fini sa préparation, elle s'active
        begin
        justice.stats.xreel:=trouvercentrex(justice);
        justice.stats.yreel:=trouvercentrey(justice);
        justice.stats.delai:=-1;
        justice.col.estActif:=True;
        InitAnimation(justice.anim,justice.anim.objectName,'active',10,false);
        jouerSonEff(justice.anim.objectName);
        for i:=0 to 3 do
            justice.col.collisionsFaites[i]:=False;
        justice.anim.currentFrame:=1;
        justice.col.estActif:=True;
        if (justice.anim.objectName='justice') or (justice.anim.objectName='justiceRykor') then
            begin
            justice.stats.vectX:=justice.stats.vitDep*(justice.stats.targetX-justice.stats.xreel)/sqrt((justice.stats.targetX-justice.stats.xreel)**2+(justice.stats.targetY-justice.stats.yreel)**2);
            justice.stats.vectY:=justice.stats.vitDep*(justice.stats.targetY-justice.stats.yreel)/sqrt((justice.stats.targetX-justice.stats.xreel)**2+(justice.stats.targetY-justice.stats.yreel)**2);
            end;
        initAngle(justice.stats.vectX,justice.stats.vectY,justice.stats.angle);
        end
    else
    if not leMonde then
        begin
        //fait avancer la justice
        updateAnimation(justice.anim,justice.image);
        justice.stats.xreel:=justice.stats.xreel+(justice.stats.vectX);
        justice.stats.yreel:=justice.stats.yreel+(justice.stats.vectY);
        justice.image.rect.x:=round(justice.stats.xreel)-(justice.image.rect.w div 2);
        justice.image.rect.y:=round(justice.stats.yreel)-(justice.image.rect.h div 2);
        end;
    //vérifie si le projectile sort de l'écran
    if (justice.stats.xreel>1600) or (justice.stats.xreel<-400) or (justice.stats.yreel>1200) or (justice.stats.yreel<-400) then 
        begin
        supprimeObjet(justice);
        end
    
end;



procedure subirDegats(var victime:TObjet;degats,knockbackX,knockbackY:Integer);overload;
var popUpColor : TSDL_Color;
begin
    if (victime.anim.etat<>'degats') then 
    begin //inflige des dégâts seulement si la victime n'est pas déjà immobilisée
        if (victime.stats.genre=joueur) and (victime.stats.leFou) then //gère les effets d'immunité
            victime.stats.leFou:=False 
        else
        if (victime.stats.genre=joueur) and (victime.stats.lamort) and (degats>victime.stats.vie) then //protège le joueur de la mort si la carte correspondante a été activée
            victime.stats.vie:=1
        else
        begin
            victime.stats.vie:=victime.stats.vie-degats; //inflige les dégâts

            if not (victime.stats.inamovible) then
            //calcule le recul infligé 
                begin
                knockbackX:=max(min(knockbackX*2,5),-5);
                knockbackY:=max(min(knockbackY*2,5),-5);
                end
            else
                begin
                knockbackX:=0;knockbackY:=0;
                end;
            //fait reculer la victime
            victime.image.rect.x:=victime.image.rect.x+knockbackX;
            victime.image.rect.y:=victime.image.rect.y+knockbackY;
            //mémorise l'état de l'animation si l'objet a une animation de dégâts subis
            victime.stats.etatPrec:=victime.anim;
            if victime.stats.genre=TypeObjet(0) then
                initAnimation(victime.anim,victime.anim.objectname,'degats',4,False);
            //accélère les actions de certains ennemis
            if (victime.stats.genre=TypeObjet(1)) and (victime.anim.etat='chase') then
                victime.stats.compteurAction:=victime.stats.compteurAction+1;
            //fait apparaître le chiffre des dégâts infligés
            if degats > 0 then
                // rouge (dégâts subis)
                begin popUpColor.r:=255;popUpColor.g:=51;popUpColor.b:=51;popUpColor.a:=255; end
                //vert (soin)
            else if degats<0 then begin popUpColor.r:=51;popUpColor.g:=255;popUpColor.b:=51;popUpColor.a:=255; end;
            if degats<>0 then CreateDamagePopUp(trouverCentreX(victime),trouverCentreY(victime),StringToPChar(IntToStr(abs(degats))),popUpColor);
        end;
    end;
end;

procedure subirDegats(var stats:TStats;degats,x,y:Integer);overload;
var popUpColor : TSDL_Color;
begin
    //inflige des dégâts directement, crée le chiffre de dégâts
    stats.vie:=stats.vie-degats;
    if degats >= 0 then
        begin popUpColor.r:=255;popUpColor.g:=51;popUpColor.b:=51;popUpColor.a:=255; end
        else begin popUpColor.r:=51;popUpColor.g:=255;popUpColor.b:=51;popUpColor.a:=255; end;
    if degats<>0 then CreateDamagePopUp(x,y,StringToPChar(IntToStr(abs(degats))),popUpColor);
end;

procedure createAfterimage(obj:TObjet;duree:Integer);
var image:TObjet;
begin
    if getframePath(obj.anim)<>nil then
        begin
        createRawImage(image.image,obj.image.rect.x,obj.image.rect.y,obj.image.rect.w,obj.image.rect.h,getFramePath(obj.anim));
        image.anim.estActif:=False;
        image.anim.isFliped:=obj.anim.isFliped;
        image.col.estActif:=False;
        image.stats.genre:=afterimage;
        image.stats.vie:=duree;
        image.stats.vieMax:=duree;
        ajoutObjet(image);
        end;
end;

procedure updateAfterimage(var image:TObjet);
begin
    image.stats.vie:=image.stats.vie-1;
    if image.stats.vie<=0 then supprimeObjet(image)
    else
        image.stats.transparence:=round(image.stats.vie/image.stats.vieMax*50)
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
        CreerRayon(joueur , 2 , s.force , s.multiplicateurDegat ,True, x,y,1200,120, getmouseX,getmouseY,{vitRotation}1,{dureeVie}30,{delai}1, 'rayon', proj);
        ajoutObjet(proj);
        jouerSonEff('Rayon');
    end;

    //3 L'impératrice
    procedure III(s : TStats ; x,y : integer);
    var proj : TObjet;
    begin
        CreerRayon(joueur , 3 , s.force , s.multiplicateurDegat ,True, x,y,1200,180, getmouseX,getmouseY,{vitRotation}0,{dureeVie}50,{delai}1, 'rayon', proj);
        ajoutObjet(proj);
        jouerSonEff('Rayon');
    end;

    //4 L'empereur
    procedure IV(s : TStats ; x,y : Integer);
    var proj : TObjet;
    begin
        creerBoule(joueur, 5, s.force, s.multiplicateurDegat, x, y,100,100, {vitesse} 29, getmouseX, getmouseY, 'projectile', proj);
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
        i : integer;
        flat:Real;
    begin
        flat := 0;
        for i:=0 to high(s.deck^) do //augmente le flat pour chaque copie de la carte dans le deck
            if (s.deck^[i].numero = 6) then 
                flat := flat +1.5 ;
        
        creerBoule(joueur, round(flat), s.force, s.multiplicateurDegat, x, y,80,80, {vitesse} 10, getmouseX, getmouseY, 'projectile', proj);
        ajoutObjet(proj);

    end;

    //7 le chariot
    procedure VII(var s: TStats;x,y:Integer);
    var eff:TObjet;
    begin
        s.defense := s.defense + 4;
        creerEffet(0,0,140,140,12,'chariot2',True,eff);
        ajoutObjet(eff);
    end; 

    //8 la justice 
    procedure VIII(var sPerm, sCombat :Tstats;x,y,charges:Integer);
    begin
        if (charges>=scombat.nbjustice) and (sCombat.nbJustice<10) then //incrémente le compteur d'utilisations de la carte
            begin
            sPerm.nbJustice := sPerm.nbJustice + 1;
            sCombat.nbJustice := sCombat.nbJustice + 1;  
            end;
        initJustice(typeObjet(0),1,scombat.force,sCombat.multiplicateurDegat,x,y,getmousex,getmousey,28,50,'justice');
    end;
    
    //9 L'ermite
    procedure IX(var s : TStats);
    var eff:TObjet;
    begin
        s.multiplicateurMana := s.multiplicateurMana * 1.2;
        creerEffet(0,0,100,140,20,'ermite',True,eff);
        ajoutObjet(eff);

    end;

    //10 La roue de la fortune
    procedure X_(var s : TStats);
    var rdm : integer ;  eff:TObjet; 
    begin
        randomize;
        rdm := random(10)+1;

        case rdm of //active un effet au hasard
            1,2,3 : subirDegats(s, 5,Lobjets[0].image.rect.x,Lobjets[0].image.rect.y); //-5pv
            4 : begin
                s.force := s.force + 3;
                creerEffet(0,0,100,100,16,'force',True,eff);
                ajoutObjet(eff);
                end; // +3 force
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
        s.multiplicateurMana := s.multiplicateurMana + 0.15;
        s.vitesse := s.vitesse + 1;
        jouerSonEff('pendu');
        //inverser les contrôles
        s.pendu := not(s.pendu); 
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
        subirDegats(sCombat, 45,Lobjets[0].image.rect.x,Lobjets[0].image.rect.y); // infliger 45 dmg
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
        multiLasers(joueur, 1 ,s.defense , s.multiplicateurDegat , x,y ,1200,120, {vitesse} 0 ,4 ,360,0, 100 ,1,'rayon');
        jouerSonEff('tour');
    end;

    //17 L'étoile
    procedure XVII(s : Tstats ; x,y : integer);
    begin
        multiLasers(joueur, 2 ,s.force , s.multiplicateurDegat , x,y ,1200,120, {vitesse} 0 ,8 ,360,0, 100 ,1,'rayon');
        jouerSonEff('etoile');
    end;

    //18 La lune
    procedure XVIII(var s : Tstats ; x,y : integer);
    var flat, vitesse : integer;
        proj : Tobjet;
    begin
        s.mana:=max(s.mana-2,0);
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
            else begin flat:=510;vitesse:=20;end;
        end;
        creerBoule(joueur, flat, s.force, s.multiplicateurDegat, x, y,s.mana*30,s.mana*30, vitesse, getmouseX, getmouseY, 'projectile', proj);
        s.mana:=0; //consomme tout le mana
        ajoutObjet(proj);
    end;

    //19 Le soleil
    procedure XIX(var s : TStats);
    var i : integer;eff:TObjet;
    begin
        subirDegats(s, round(-5*s.multiplicateurSoin),Lobjets[0].image.rect.x,Lobjets[0].image.rect.y); // soin de 5 pv 
        creerEffet(0,0,150,150,15,'soleil',True,eff);
        ajoutObjet(eff);
        for i := 0 to high(LOBjets) do
            if (LOBjets[i].stats.genre=ennemi) then
                subirDegats(LObjets[i].stats,degat(1,s.force,LObjets[i].stats.defense,s.multiplicateurDegat,false),trouverCentreX(LObjets[i]),trouverCentreY(LObjets[i]));
        for i := 0 to high(LOBjets) do
            if (LOBjets[i].stats.genre=ennemi) and (i<=high(LObjets)) then
            begin
                creerEffet(LObjets[i].image.rect.x+LObjets[i].col.offset.x,LObjets[i].image.rect.y+LObjets[i].col.offset.x,LObjets[i].col.dimensions.w,LObjets[i].col.dimensions.h,7,'impact_solaire',False,eff);
                ajoutObjet(eff);
            end;
    end;

    //20 L'ange
    procedure XX(var s : Tstats);
    var eff:TObjet;
    begin
        subirDegats(s, round(-20*s.multiplicateurSoin),Lobjets[0].image.rect.x,Lobjets[0].image.rect.y);
        creerEffet(0,0,150,150,15,'ange',True,eff);
        ajoutObjet(eff);
    end;

    //21 Le monde
    procedure XXI(var s : TStats);
    var eff:TObjet;
    begin
        s.compteurLemonde := s.compteurLemonde +1;
        leMonde:=True; //arrête le temps
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
    
    // Cartes bonus
    procedure XXIII(origine:typeObjet;s:TStats;x,y,xcible,ycible,delai:Integer);
    var distX,distY:Integer;
    begin
        jouerSonEff('XXIII');
        distX:=xcible-x;
        distY:=ycible-y;
        
        //lance 4 épées autour de la cible
        initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible-distx,ycible-disty,18,delai,'Lionheart');
        initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible+distx,ycible+disty,18,delai,'Lionheart');
        initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible+disty,ycible-distx,18,delai,'Lionheart');
        initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible-disty,ycible+distx,18,delai,'Lionheart');
        if s.relique=11 then 
            begin
            initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible-distx,ycible-disty,36,delai,'Lionheart');
            initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible+distx,ycible+disty,36,delai,'Lionheart');
            initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible+disty,ycible-distx,36,delai,'Lionheart');
            initJustice(origine,5,s.force,s.multiplicateurDegat,xcible,ycible,xcible-disty,ycible+distx,36,delai,'Lionheart');
            end;
    end;

    procedure XXIV(s:TStats;x,y:Integer);
    var angle:Real;
    begin
        //crée une barrière qui bloque les attaques
        jouerSonEff('XXIV');
        initAngle(getmouseX-x,getMouseY-y,angle);
        multiprojs(joueur, 10 ,s.force , s.multiplicateurDegat , x,y ,150,150, 0,3 ,360 ,round(angle*360),'Roue');
    end;

    procedure XXV(s:TStats;x,y:Integer);
    var angle:Real;i:Integer;
    begin
        initAngle(getmouseX-x,getMouseY-y,angle);
        for i:=0 to 4 do
            multiprojs(joueur, 1 ,s.force , s.multiplicateurDegat , x,y ,100,100, 9-i,6 ,360 ,angle+(i/pi*8),'tornade');
    end;

    procedure XXVI(s:TStats;x,y:Integer);
    var i:Integer;alea1:Real;obj:TObjet;
    begin
        randomize();
        for i:=1 to 6 do begin
            alea1:=random(360)/180*pi;
            creerRayon(typeObjet(0),6,s.force,s.multiplicateurDegat,false,round(x-cos(alea1)*200),50+round(y-sin(alea1)*200),200,100,x,y,0.1,20,20,'eclair',obj);
            ajoutObjet(obj);
        end;
    end;

    procedure XXVII(s:TStats;x,y:Integer);
    var exp:TObjet;
    begin  
        jouerSonEff('ultima1');
        creerBoule(joueur, 5, s.force, s.multiplicateurDegat, getmousex, getmousey,1500,1500, 0, getmouseX, getmouseY, 'ultima', exp);
        exp.stats.genre:=explosion;
        exp.stats.dureeVieInit:=150;
        exp.stats.dureeVie:=exp.stats.dureeVieInit;
        exp.col.estActif:=False;
        exp.stats.transparence:=0;
        ajoutObjet(exp);
        sceneActive:='Cutscene';
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,0,windowWidth,300,extractionTexte('SORT1_'+intToSTR(random(3)+1)),20,Angelic30,40);
        
    end;

    procedure modifexp(var exp:TObjet);
    var angle:Real;i:Integer;
    begin
    exp.image.rect.x:=round(exp.stats.xreel)-(exp.image.rect.w div 2);
    exp.image.rect.y:=round(exp.stats.yreel)-(exp.image.rect.h div 2);
    exp.stats.delai:=-250;
    exp.col.dimensions.w := exp.image.rect.w*2 div 8;
    exp.col.dimensions.h := exp.image.rect.h*2 div 8;
    exp.col.offset.x := exp.image.rect.w*3 div 8;
    exp.col.offset.y := exp.image.rect.h*3 div 8;
    exp.col.nom := 'boule';
    if not leMonde then exp.stats.dureeVie:=exp.stats.dureeVie-1;
    if (exp.stats.dureeVie<exp.stats.delai) then
            begin
            supprimeObjet(exp);
            end
        else if (exp.stats.dureeVie>0) then
            begin 
            exp.stats.transparence:=54+round(200*(1-exp.stats.dureeVie/exp.stats.dureeVieInit));
            exp.image.rect.w:=round(1500*(exp.stats.dureeVie/exp.stats.dureeVieInit)**3);
            exp.image.rect.h:=round(1500*(exp.stats.dureeVie/exp.stats.dureeVieInit)**3);
            end
        else if (exp.stats.dureeVie=0) then
            begin
            initAngle(getmouseX-exp.stats.xreel,getMouseY-exp.stats.yreel,angle);
            initAnimation(exp.anim,exp.anim.objectName,'explosion',6,True);
            jouerSonEff('ultima2');
            exp.col.estActif:=True;
            for i:=0 to 3 do
                exp.col.collisionsFaites[i]:=False;
            end
        else if (exp.stats.dureeVie<0) then
            begin
            exp.stats.transparence:=min(255,round(400*(1-exp.stats.dureeVie/exp.stats.delai)));
            exp.image.rect.w:=round(600*(exp.stats.dureeVie/exp.stats.delai));
            exp.image.rect.h:=round(600*(exp.stats.dureeVie/exp.stats.delai));
            end
    end;
    
    procedure attexp(exp:TObjet);
    var alea:Real;obj:TObjet;i:Integer;
    begin
        if (exp.stats.dureeVie<0) then
            begin
            if (random(5)=0) and (exp.stats.dureeVie>(exp.stats.delai div 2 + exp.stats.delai div 4)) then
                for i:=1 to 2 do
                if random(4)=0 then 
                    begin
                        alea:=pi*(random(12)-6)/8;
                        creerBoule(joueur,2,exp.stats.force,exp.stats.multiplicateurDegat,round(exp.stats.xreel),round(exp.stats.yreel),500,100,2,round(exp.stats.xreel+cos(alea)*100),round(exp.stats.xreel+sin(alea)*100),'ultima',obj);
                        obj.stats.angle:=alea;
                        obj.stats.genre:=explosion2;
                        obj.stats.dureeVieInit:=100;
                        obj.stats.dureeVie:=obj.stats.dureeVieInit;
                        sdl_settexturealphamod(obj.image.imgtexture,0);
                        ajoutObjet(obj);
                    end
                    else
                        begin
                        alea:=pi*(random(16)-8)/8;
                        creerRayon(typeObjet(0),2,exp.stats.force,exp.stats.multiplicateurDegat,false,round(exp.stats.xreel),round(exp.stats.yreel),1200,150,round(exp.stats.xreel+cos(alea)*500),round(exp.stats.xreel-sin(alea)*500),0,20,20,'rayonAL',obj);
                        ajoutObjet(obj);
                        end;
            end;
    end;

    procedure updateExplosion(var exp:TObjet;var interruption:Boolean);
    begin
        modifexp(exp);
        if not leMonde then
            attexp(exp);
        
    end;

    procedure updateExplosion2(var exp:TObjet);
    begin
        if exp.stats.dureeVie<0 then 
            supprimeObjet(exp)
        else
            begin
            exp.image.rect.x:=round(exp.stats.xreel)-(exp.image.rect.w div 2);
            exp.image.rect.y:=round(exp.stats.yreel)-(exp.image.rect.h div 2);
            if not leMonde then
            exp.stats.dureeVie:=exp.stats.dureeVie-1;
            exp.col.isTrigger := True;
            exp.col.estActif := True;
            exp.col.dimensions.w := exp.image.rect.w*2 div 8;
            exp.col.dimensions.h := exp.image.rect.h*2 div 8;
            exp.col.offset.x := exp.image.rect.w*3 div 8;
            exp.col.offset.y := exp.image.rect.h*3 div 8;
            exp.col.nom := 'boule';
            sdl_settexturealphamod(exp.image.imgtexture,2+round(250*(exp.stats.dureeVie/exp.stats.dureeVieInit)));
            exp.image.rect.w:=round(800*(1-(exp.stats.dureeVie/exp.stats.dureeVieInit)**3));
            exp.image.rect.h:=round(300*(1-(exp.stats.dureeVie/exp.stats.dureeVieInit)**3));
            end;
    end;

    procedure XXVIII(s:TStats;x,y:Integer);
    var proj : TObjet;angle:Real;
    begin
        jouerSonEff('meteore');
        initAngle(getMouseX-x,getMouseY-y,angle);
        sceneActive:='Cutscene';
        InitDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,0,windowWidth,300,extractionTexte('SORT2_'+intToSTR(random(3)+1)),20,Angelic30,30);
        creerBoule(joueur, 150, s.force, s.multiplicateurDegat, x-round(cos(angle)*1000), y-round(sin(angle)*1000),600,600, {vitesse} 3, getmouseX, getmouseY, 'meteore', proj);
        sdl_settexturealphamod(proj.image.imgTexture,0);
        ajoutObjet(proj);
    end;

//end

//###"La procédure ultime. On raconte que son accomplissement entraîne la fin de l'univers."
procedure JouerCarte(var stats:TStats;x,y:Integer;i:Integer); 

var tempCarte:TCarte;

begin
    tempCarte:=stats.deck^[i];
    if stats.deck^[i].active or (tempCarte.cout<=stats.mana) or (stats.relique=10) then 
        begin
        if LObjets[0].anim.etat='idle' then initAnimation(LObjets[0].anim,LObjets[0].anim.objectName,'sort',7,False);
        LObjets[0].anim.isFliped:=(getmousex<x);
        if not stats.deck^[i].active then
            begin
            stats.mana:=stats.mana-tempCarte.cout;
            if stats.mana<0 then 
                begin
                stats.vie:=stats.vie+stats.mana*3;
                stats.mana:=0;
                end;
            stats.deck^[i].active:=True;
            if tempCarte.numero=8 then
                begin
                stats.deck^[i].chargesMax:=stats.nbJustice+1;
                end;
            stats.deck^[i].charges:=stats.deck^[i].chargesMax;
            end;
            if (stats.relique<>9) or (random(5)<>0) then //la relique n°9 permet de lancer 2 fois les sorts parfois
                stats.deck^[i].charges:=stats.deck^[i].charges-1;
        if stats.deck^[i].charges<=0 then //si la carte est consommée, elle est renvoyée à la fin du paquet (ou non)
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
            //Cartes bonus
            23: XXIII(joueur,stats,x,y,getmouseX,getmousey,60);
            24: XXIV(stats,getmouseX,getmouseY);
            25: XXV(stats,x,y);
            26: XXVI(stats,getmousex,getmousey);
            27: XXVII(stats,x,y);
            28: XXVIII(stats,x,y);
            //writeln('???')
            end;
        end;


end;

procedure updateAttaques(); //met à jour tous les objets autres que le joueur et les ennemis
var i:Integer;interruption:Boolean;
begin
interruption:=False;
for i:=2 to High(LObjets) do
      if (not interruption) and (i<=High(LObjets)) then
	  	begin
            LObjets[i].stats.indice:=i;
			case LObjets[i].stats.genre of 
        	projectile:updateBoule(LObjets[i]); //fait avancer un projectile en ligne droite
			laser:updateRayon(LObjets[i]); //met à jour un rayon
			epee:UpdateJustice(LObjets[i]); //prépare ou fait avancer une épée
            explosion:UpdateExplosion(LObjets[i],interruption);
            explosion2:updateExplosion2(LObjets[i]);
            afterimage:updateAfterimage(LObjets[i]);

			effet:if (LObjets[i].stats.fixeJoueur) and (not (leMonde) or (LObjets[i].anim.objectName='monde')) then 
				begin
                //si l'effet suit le joueur, il se fixe à sa position
				LObjets[i].image.rect.x:=LObjets[0].image.rect.x+50-(LObjets[i].image.rect.w div 2);
				LObjets[i].image.rect.y:=LObjets[0].image.rect.y+50-(LObjets[i].image.rect.h div 2);
				end;
			end;
		end
end;

begin
leMonde:=False;

end.