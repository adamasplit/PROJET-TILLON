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
function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;
procedure RegenMana(var LastUpdateTime : UInt32;var stats:TStats); 
procedure CreerDeckCombat(stat : TStats;var DeckCombat:TDeck); 
procedure cycle (var deck : TDeck ; i : Integer);
procedure circoncision  (var deck : Tdeck);
procedure initStatsCombat(statsPerm:TStats;var statsTemp:TStats);
procedure CreerBoule(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,vitesse,xdest:Integer;nom:PChar;var proj:TObjet);
procedure updateBoule(var proj:TObjet);
procedure JouerCarte(var deck:TDeck;i,force:Integer;multiplicateurDegat:Real;var vie,mana:Integer;x,y:Integer);  


implementation

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
procedure RegenMana(var LastUpdateTime : UInt32;var stats:TStats); 
var 
    currentTime: UInt32;
    

begin

        SDL_PumpEvents;
        currentTime := SDL_GetTicks(); //récupère le temps
        //writeln(currentTime,' comparé à ',lastUpdateTime);
        //writeln((( (currentTime - LastUpdateTime)*LObjets[0].stats.multiplicateurMana)>= 1000),' and ',(LObjets[0].stats.mana < LObjets[0].stats.manaMax));
        if (( (currentTime - LastUpdateTime)*stats.multiplicateurMana)>= 1000) AND (stats.mana < stats.manaMax) then //attendre 1sec/mult avant +1 mana
        begin
            stats.mana := stats.mana + 1;
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
end;

// retire la dernière carte du paquet
procedure circoncision  (var deck : Tdeck);
begin
    setLength (deck , High(deck)-1);
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
var i:Integer;
begin
    //Création de la copie
    statsTemp:=statsPerm;
    creerDeckCombat(statsTemp,Pdeck);
    //Initialisation du deck pointé
    setlength(PDeck,statsTemp.taillecollection);
    for i:=1 to statsTemp.tailleCollection do
        PDeck[i-1]:=statsTemp.collection[i];
    statsTemp.deck:=@pDeck;
    if statsTemp.deck=NIL then writeln('AVERTISSEMENT: DECK NON DEFINI')
end;


procedure CreerBoule(origine:TypeObjet;flat,force:Integer;multiplicateurDegat:Real;x,y,vitesse,xdest:Integer;nom:PChar;var proj:TObjet); //Crée un project
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
        CreateRawImage(proj.image,x,y,64,64,getFramePath(proj.anim));

        //Initialisation de la boîte de collisions

        proj.col.isTrigger := True;
        proj.col.estActif := True;
        proj.col.dimensions.w := proj.image.rect.w-10;
        proj.col.dimensions.h := proj.image.rect.h-10;
        proj.col.offset.x := 10;
        proj.col.offset.y := 10;
        proj.col.nom := 'boule';

        //Création du vecteur de mouvement du projectile

        destination['X']:=xdest;
        destination['Y']:=getmouseY;
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

        begin

        //ajustement de la position: le projectile avance
        proj.stats.xreel:=proj.stats.xreel+(proj.stats.vectX);
        proj.stats.yreel:=proj.stats.yreel+(proj.stats.vectY);
        proj.image.rect.x:=round(proj.stats.xreel)-25;
        proj.image.rect.y:=round(proj.stats.yreel)-25;
            if proj.stats.vectX>0 then
            SDL_RenderCopyEx(sdlRenderer, proj.image.imgTexture, nil, @proj.image.Rect,180*(arctan(proj.stats.vectY/proj.stats.vectX))/pi,nil, SDL_FLIP_NONE);
            if proj.stats.vectX<0 then
            SDL_RenderCopyEx(sdlRenderer, proj.image.imgTexture, nil, @proj.image.Rect,180*(arctan(proj.stats.vectY/proj.stats.vectX))/pi,nil, SDL_FLIP_HORIZONTAL);
        end
end;    

//###"La procédure ultime. On raconte que son accomplissement entraîne la fin de l'univers."
procedure JouerCarte(var deck:TDeck;i,force:Integer;multiplicateurDegat:Real;var vie,mana:Integer;x,y:Integer); 

var tempCarte:TCarte;projectile:TOBjet;

begin
    tempCarte:=deck[i];
    if tempCarte.cout<=mana then 
        begin
        mana:=mana-tempCarte.cout;
        cycle(deck,i);
        //Partie principale : tous les effets de cartes y seront répertoriés
        case tempCarte.numero of
            0:writeln('???')
            else 
                begin //création d'un projectile ( les éventuels changements sont sur le 2ème élément (les dégâts), celui avant getmousex (la vitesse) et l'avant-dernier (pour l'image))
                creerBoule(typeobjet(0),1,force,multiplicateurDegat,x,y,5,getmouseX,'projectile',projectile);
                ajoutObjet(projectile);
                end
            end;
        end;


end;



end.