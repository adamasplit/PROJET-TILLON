unit CombatLib;

interface

uses
    math,coeur,eventSys,memgraph,
    SDL2;
function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;
procedure melangeDeck(var stats:TStats);
procedure initStatsCombat(var stats:TStats);
procedure RegenMana(var LastUpdateTime : UInt32;var stats:TStats); 
procedure RetirerCarte(i:Integer);
procedure CreerBoule(flat,force:Integer;multiplicateurDegat:Real;x,y,vitesse:Integer;var proj:TObjet);
procedure updateBoule(var proj:TObjet);


implementation

//Fonction de calcul des dégats
function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;
begin

    degat := math.ceil((flat + force - defence)*multiplicateurDegat);
    if degat < 1 then
        degat := 1;
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

procedure melangeDeck(var stats:TStats);
var tempDeck:array of TCarte;i,j,rand:Integer;
begin
    setLength(tempDeck,stats.tailleDeck+1);
    for i:=1 to stats.tailleDeck do
        tempDeck[i]:=stats.deck[i];
    for i:=1 to stats.tailleDeck do 
        begin
            randomize();
            rand:=random(stats.tailleDeck-i)+1;
            stats.deck[i]:=tempDeck[rand];
            for j:=rand to stats.tailleDeck-i do
                tempDeck[j]:=tempDeck[j+1];
        end;
end;

procedure initStatsCombat(var stats:TStats);
begin
    melangeDeck(stats);
    stats.cartesUniquesJouees:=0;
end;

procedure RetirerCarte(i:Integer); //retire une carte de la main et la remet dans le deck (ou non)
var tempCarte:TCarte;j:Integer;
    begin
        tempCarte:=LObjets[0].stats.deck[i];
        //writeln('numero de la carte actuelle:',LObjets[0].stats.deck[iCarteChoisie].numero);
        LObjets[0].stats.mana:=LObjets[0].stats.mana-LObjets[0].stats.deck[i].cout; //devra sans doute être déplacé dans JouerCarte 

        for j:=i to LObjets[0].stats.tailleDeck-1-LObjets[0].stats.cartesUniquesJouees do begin
            LObjets[0].stats.deck[j]:=LObjets[0].stats.deck[j+1];
            //writeln(j,'<-',j+1);
            end;
        
        if (tempCarte.numero=15) or (tempCarte.numero=13) then //vérifie si la carte est à usage unique ou non
            LObjets[0].stats.cartesUniquesJouees:=LObjets[0].stats.cartesUniquesJouees+1
        else begin
            LObjets[0].stats.deck[LObjets[0].stats.TailleDeck-LObjets[0].stats.cartesUniquesJouees]:=tempCarte;
            //writeln(LObjets[0].stats.TailleDeck-LObjets[0].stats.cartesUniquesJouees,' <- ',i);
            end
        
    end;

procedure CreerBoule(flat,force:Integer;multiplicateurDegat:Real;x,y,vitesse:Integer;var proj:TObjet);
var norme:Integer;destination,distance:array['X'..'Y'] of Integer;
    begin
        //Initialisation des caractéristiques
        proj.stats.genre:=projectile;
        proj.stats.degats:=flat;
        proj.stats.force:=force;
        proj.stats.multiplicateurDegat:=multiplicateurDegat;
        CreateRawImage(proj.image,x,y,20,20,'Sprites/Cartes/carte1.bmp');
        
        //Création du vecteur de mouvement du projectile
        destination['X']:=getMouseX;
        destination['Y']:=getmouseY;
        distance['X']:=destination['X']-x;
        distance['Y']:=destination['Y']-y;
        norme:=round(sqrt(distance['X']**2+distance['Y']**2)) div vitesse;
        if norme<>0 then begin
            //writeln('proj.stats.vectX:=',round(distance['X']/norme),';proj.stats.vectY:=',round(distance['Y']/norme));
            proj.stats.vectX:=round(distance['X']/norme);
            proj.stats.vectY:=round(distance['Y']/norme);
            end;
        

    end;

procedure updateBoule(var proj:TObjet);
begin
    proj.image.rect.x:=proj.image.rect.x+round(proj.stats.vectX);
    proj.image.rect.y:=proj.image.rect.y+round(proj.stats.vectY);
end;

begin

end.