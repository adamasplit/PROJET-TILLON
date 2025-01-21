unit mapSys;

interface
uses
    AnimationSys,
    coeur,
    CombatLib,
    EnemyLib,
    eventSys,
    fichierSys,
    math,
    memgraph,
    SDL2,
    SDL2_mixer,
    SonoSys,
    SysUtils;
var isalleChoisie:Integer;
var iDeck,iChoix1,iChoix2,indiceMusiqueSuiv:Integer;
var etatChoix:Boolean;
var evenementSuiv:evenements;
echangeFait:Boolean;

var
    X1,X2,X3,Y2,Y1: Integer;

procedure generationChoix(var salle1,salle2,salle3:TSalle);
procedure affichageSalles(var salle1,salle2,salle3:TSalle);
procedure zoom();
procedure actualiserDD();
procedure actualiserUS;
procedure desequiperRelique(var stats:TStats);
procedure HandleButtonClickSalle(button:TButtonGroup;evenement:evenements;num,x,y:Integer);
procedure choixSalle();
procedure actualiserMap();
procedure actualiserMarchand();
procedure actualiserEchange();
procedure actualiserSalleLeo;
procedure actualiserEchangeDD();
procedure brulerCarte(carte:TCarte ; var stats : Tstats);
function dropCarte(avancement:Integer;boss:Boolean):TCarte;
procedure LancementSalleHasardReposRisque;
procedure actualiserReposRisque;
procedure actualiserFeuCamp;
procedure actualiserDefausse;
procedure ReposRisque;
procedure LancementSalleHasard;
procedure LancementSalleBoss;
procedure LancementSalleMarchand;
procedure LancementSalleHasardDD;
procedure LancementSalleCamp;
procedure scrollDeck(var i:Integer;imax:Integer);
procedure activationEvent(scene:String);overload;
procedure activationEvent(evenement:evenements);overload;
function nbCartesRecyclables(stats:TStats):Integer;
procedure HandleButtonClickEch(var button: TButtonGroup; x, y: Integer;carte1,carte2:TCarte;var stats:TStats);
function Highlight(var btnGroup: TButtonGroup; x, y: Integer):Boolean;
implementation

var entree:Boolean;
var numDialogue:Integer;
var imgCar1,imgCar2,imgCar3,imgEchange:TImage;
izoom:Integer;

function nbCartesRecyclables(stats:TStats):Integer;
var i:Integer;
begin
    nbCartesRecyclables:=0;
    for i:=1 to stats.tailleCollection do
        if not stats.collection[i].discard then
            nbCartesRecyclables:=nbCartesRecyclables+1;
end;

procedure zoom();
var
  tempsEcoule: UInt32;
  progression: Real;
  xinit,yinit:Integer;
  i:Integer;
begin
    tempsEcoule := SDL_GetTicks() - TimeDebutFondu;
    progression := 2-2*exp(-(tempsEcoule) / dureeFondu);
    
    xinit:=salles[izoom].image.image.rect.x+(salles[izoom].image.image.rect.w div 2);
    yinit:=salles[izoom].image.image.rect.y+(salles[izoom].image.image.rect.h div 2);
    salles[izoom].image.image.rect.w:=256*windowWidth div 1080+round(progression*600);
    salles[izoom].image.image.rect.h:=392*windowHeight div 720+round(progression*900);
    salles[izoom].image.image.rect.x:=xinit-(salles[izoom].image.image.rect.w div 2);
    salles[izoom].image.image.rect.y:=yinit-(salles[izoom].image.image.rect.h div 2);
    for i:=1 to 3 do 
        if (i<>iZoom) then
            case i of
            1:salles[i].image.image.rect.x:=X1-(salles[i].image.image.rect.w div 2)+round(progression*(480*windowWidth div 1080+izoom*20));
            2:salles[i].image.image.rect.x:=X2-(salles[i].image.image.rect.w div 2)+round(progression*(400*windowWidth div 1080*(izoom-2)));
            3:salles[i].image.image.rect.x:=X3-(salles[i].image.image.rect.w div 2)-round(progression*(540*windowWidth div 1080-izoom*20));
            end;
    progression:=progression*1.7;
    case izoom of
        3:begin
            fond.rect.x:=0;
            fond.rect.y:=-round(progression*360);
            fond.rect.w:=WINDOWWIDTH+round(progression*WINDOWWIDTH);
            fond.rect.h:=WINDOWHEIGHT+round(progression*windowHeight);
            end;
        2:begin
            fond.rect.x:=-round(progression*540);
            fond.rect.y:=-round(progression*360);
            fond.rect.w:=WINDOWWIDTH+round(progression*WINDOWWIDTH);
            fond.rect.h:=WINDOWHEIGHT+round(progression*windowHeight);
            end;
        1:begin
            fond.rect.x:=-round(progression*WINDOWWIDTH);
            fond.rect.y:=-round(progression*360);
            fond.rect.w:=WINDOWWIDTH+round(progression*WINDOWWIDTH);
            fond.rect.h:=WINDOWHEIGHT+round(progression*windowHeight);
            end;
    end;
    //writeln(izoom);
    

end;

procedure lancerSalle(evenement:evenements;numero:Integer);
begin
    if evenement<>rien then
    begin
        sceneActive:='Fondu';
        DeclencherFondu(True,1000);
        evenementSuiv:=evenement;
        if evenement<>boss then 
            begin
            sdl_destroytexture(salles[numero].image.image.imgtexture);
            sdl_freeSurface(salles[numero].image.image.imgSurface);
            createRawImage(salles[numero].image.image,salles[numero].image.image.rect.x,salles[numero].image.image.rect.y,salles[numero].image.image.rect.w,salles[numero].image.image.rect.h,'Sprites/salles/porte10.bmp');
            end;
        izoom:=numero;
    end;
end;

procedure generationChoix(var salle1,salle2,salle3:TSalle);
var alea:Integer;
begin
    ////writeln('Actuellement en salle : ',statsJoueur.avancement);
    if ((statsJoueur.avancement mod (MAXSALLES div 4)) = 0) and (statsJoueur.avancement <=MAXSALLES) then 
        begin
            salle1.evenement:=rien;
            salle2.evenement:=boss;
            salle3.evenement:=rien
        end
    else 
        if statsJoueur.avancement<4 then
            begin
            salle1.evenement:=combat;
            salle2.evenement:=combat;
            salle3.evenement:=combat;
            end
    else begin
        randomize();
        alea:=random(2)+1;
        case alea of
            1:begin
                salle1.evenement:=combat;
                salle2.evenement:=evenements(random(4));
                salle3.evenement:=evenements(random(4))
                end;
            2:begin
                salle2.evenement:=combat;
                salle1.evenement:=evenements(random(4));
                salle3.evenement:=evenements(random(4))
                end;
            3:begin
                salle3.evenement:=combat;
                salle1.evenement:=evenements(random(4));
                salle2.evenement:=evenements(random(4))
                end
            end
        end
end;

function choisirennemi(avancement,i:Integer):integer; //choisit un ennemi adapté à la salle actuelle
var alea:Integer;
begin
    alea:=random(10)+1;
    if (avancement<=MAXSALLES div 4) then
        case alea of
        1..7:choisirennemi:=random(5)+1;
        8..10:choisirennemi:=random(2)+6;
        end
    else if (avancement<=MAXSALLES div 2) then
        case alea of
        1..6:choisirennemi:=random(4)+13;
        7..9:choisirennemi:=random(3)+6;
        10:choisirennemi:=11;
        end
    else if (avancement<=(MAXSALLES - MAXSALLES div 4)) then
        case alea of
        1..8:choisirennemi:=random(5)+18;
        9:choisirennemi:=random(2)+9;
        10:if (trouverCarte(statsJoueur,24) or (statsJoueur.bestiaire[25])) then choisirennemi:=random(3)+6
            else choisirennemi:=25;
        end
    else if (avancement<=MAXSALLES) then
        case alea of
        1,2:choisirennemi:=26;
        3..6:choisirennemi:=random(2)+28;
        7..8:choisirennemi:=random(4)+13;
        9:choisirennemi:=random(7)+6;
        10:if i=1 then case random(3) of
            0:choisirennemi:=36;
            1:choisirennemi:=12;
            2:choisirennemi:=35;
            end
        else choisirennemi:=12;
        end
    else
        case alea of
        1,10:case random(3) of
            0:choisirennemi:=36;
            1:choisirennemi:=12;
            2:choisirennemi:=35;
            end;
        2:choisirennemi:=random(5)+1;
        3,7:choisirennemi:=random(7)+6;
        4:choisirennemi:=random(4)+13;
        5,8:choisirennemi:=random(5)+18;
        6:choisirennemi:=random(2)+28;
        9:choisirennemi:=random(2)+25;
        end;
end;

function choisirMusique(avancement:Integer):Integer;
begin
    if avancement>MAXSALLES+1 then
        choisirMusique:=random(13)+1
    else
    case avancement div (MAXSALLES div 6) of
        0..4:choisirMusique:=(avancement div (MAXSALLES div 6))+random(2)+1;
        else choisirMusique:=random(4)+5;
        end
end;

procedure choisirEnnemis(avancement:Integer;boss:Boolean);
var j,nb : integer;
begin
    //writeln(high(ennemis),',',high(LObjets));
    if high(damagepopups)>0 then
    repeat
        SDL_DestroyTexture(DamagePopUps[high(DamagePopUps)].textTexture);
        SDL_freeSurface(DamagePopUps[high(DamagePopUps)].textSurface);
        setlength(damagepopups,high(DamagePopUps));
    until high(damagepopups)<0;
    if high(ennemis)>1 then
        repeat
            SDL_DestroyTexture(ennemis[high(ennemis)].image.imgTexture);
            setlength(ennemis,high(ennemis));
        until high(ennemis)=0;
    if high(LOBjets)>0 then repeat 
        supprimeObjet(LObjets[1]);
    until high(LObjets)=0;
    //writeln('listes vidées');
    initStatsCombat(statsJoueur,LObjets[0].stats);
    //writeln('stats initialisées');
    vagueFinie:=True;
    combatFini:=False;
    randomize;
    if avancement>MAXSALLES then
        initDecor(random(5))
    else
        initDecor((avancement-1) div (MAXSALLES div 4));
    indiceMusiqueJouee:=choisirMusique(avancement);
    if avancement>MAXSALLES then
        nb:=(avancement div (MAXSALLES div 2))+(random(20) div 18)
    else
        nb:=1+(random(20) div 18)+((avancement mod (maxSalles div 4)) div 6);
    //writeln('choix des ennemis');
    if not boss then begin
        setlength(ennemis,nb+1);
        for j:=1 to nb do
            begin
            ennemis[j]:=templatesennemis[choisirEnnemi(avancement,j)];
            ennemis[j].stats.vie :=     round((avancement/MAXSALLES+1.2)*ennemis[j].stats.vie    );
            ennemis[j].stats.vieMax :=  round((avancement/MAXSALLES+1.2)*ennemis[j].stats.vieMax );
            ennemis[j].stats.force :=   round((avancement/MAXSALLES+1)*ennemis[j].stats.force  );
            ennemis[j].stats.defense := round(((avancement/1.3)/MAXSALLES+1)*(ennemis[j].stats.defense));
            ennemis[j].stats.vitesse := round((avancement/MAXSALLES+1)*ennemis[j].stats.vitesse);
            end;
    end;
    //writeln('ennemis choisis')

end;

procedure LancementSalleCombat(); //déclenche une salle de combat normal
begin

//writeln('Lancement de salle Combat');
choisirEnnemis(statsJoueur.avancement-1,false);
ClearScreen;
SDL_RenderClear(sdlRenderer);

SceneActive := 'Jeu';
end;

procedure LancementVSLeo(); //active le combat contre Leo
begin
    initStatsCombat(statsJoueur,LObjets[0].stats);
    if high(LOBjets)>0 then repeat supprimeObjet(LObjets[1]) until high(LObjets)=0;
    vagueFinie:=True;
    combatFini:=False;
    setlength(ennemis,2);
    indiceMusiqueJouee:=9;
    initDecor(4);
    ennemis[1]:=templatesEnnemis[23];
    sceneActive:='Jeu';
end;

procedure choixBoss(avancement:Integer); //choisit parmi la liste l'ennemi à mettre dans une salle de boss
begin
    setlength(LObjets,2);
    indiceMusiqueJouee:=min(12,((avancement-1) div (maxSalles div 4))+10);
    if (avancement<=MAXSALLES div 4) then
        LObjets[1]:=templatesEnnemis[31]
    else if (avancement<=MAXSALLES div 2) then
        LObjets[1]:=templatesennemis[33]
    else if (avancement<=(MAXSALLES - MAXSALLES div 4)) then
        LObjets[1]:=templatesennemis[37]
    else if (avancement<=MAXSALLES+1) then
        begin
        setlength(ennemis,3);
        LObjets[1]:=TemplatesEnnemis[27];
        ennemis[2]:=templatesEnnemis[30];
        ennemis[1]:=templatesEnnemis[38];
        end;
end;

procedure LancementSalleBoss; //active une salle où le joueur combattra un unique ennemi plus puissant
begin
    //writeln('Lancement de salle Boss');
    choisirEnnemis(statsJoueur.avancement-1,true);
    ClearScreen;
    SDL_RenderClear(sdlRenderer);
    SceneActive := 'Jeu';
    vagueFinie:=False;
    choixBoss(statsJoueur.avancement-1);
    //writeln('ennemis choisis (boss)');
end;

function ajouterCarteAleatoireRarete(rarete : Trarete):TCarte;
var rdm : integer;
begin
    case rarete of 
    commune :  
    begin
        rdm := 1 + random(6);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[1];
        2: ajouterCarteAleatoireRarete:=cartes[2];
        3: ajouterCarteAleatoireRarete:=cartes[3];
        4: ajouterCarteAleatoireRarete:=cartes[4];
        5: ajouterCarteAleatoireRarete:=cartes[5];
        6: ajouterCarteAleatoireRarete:=cartes[10];
        end;
    end;

    rare :
    begin
        if trouverCarte(statsJoueur,6) and (random(3)=0) then
            ajouterCarteAleatoireRarete:=cartes[6]
        else
            begin
            rdm := 1 + random(7);
        
            case rdm of
            1: ajouterCarteAleatoireRarete:=cartes[6];
            2: ajouterCarteAleatoireRarete:=cartes[7];
            3: ajouterCarteAleatoireRarete:=cartes[8];
            4: ajouterCarteAleatoireRarete:=cartes[9];
            5: ajouterCarteAleatoireRarete:=cartes[11];
            6: ajouterCarteAleatoireRarete:=cartes[16];
            7: ajouterCarteAleatoireRarete:=cartes[19];
                end;
            end;
    end;

    epique :
    begin
         rdm := 1 + random(6);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[12];
        2: ajouterCarteAleatoireRarete:=cartes[14];
        3: ajouterCarteAleatoireRarete:=cartes[17];
        4: ajouterCarteAleatoireRarete:=cartes[18];
        5: ajouterCarteAleatoireRarete:=cartes[20];
        6: ajouterCarteAleatoireRarete:=cartes[22];
        end;
    
    end;

    legendaire :
    begin
         rdm := 1 + random(3);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[13];
        2: ajouterCarteAleatoireRarete:=cartes[15];
        3: ajouterCarteAleatoireRarete:=cartes[21];
        end;
    end;
    end;
end;

function dropCarte(avancement:Integer;boss:Boolean):TCarte;
var alea:Integer;
begin
    alea:=random(100)+1;
    //writeln(alea);
    dropCarte.numero:=0;
    if boss then
        if alea div 25<=avancement div (MAXSALLES div 4) then
            begin
            if alea mod 5<>3 then
                if (random(5)=4) and (avancement div (MAXSALLES div 4)=2) then
                    dropCarte:=cartes[27+random(2)]
                else
                    dropCarte:=ajouterCarteAleatoireRarete(legendaire)
            else
                if alea mod 2=0 then 
                    dropCarte:=cartes[25]
                else
                    dropCarte:=cartes[26]
            end
        else
            dropCarte:=ajouterCarteAleatoireRarete(epique)
    else
    case (avancement div (MAXSALLES div 4))+1 of //sépare le jeu en 4 "sections" selon l'avancement
        1:case alea of
            1..85  :dropCarte:=ajouterCarteAleatoireRarete(commune);
            86..95 :dropCarte:=ajouterCarteAleatoireRarete(rare);
            96..100:dropCarte:=ajouterCarteAleatoireRarete(epique);
            end;
        2:case alea of
            1..65  :dropCarte:=ajouterCarteAleatoireRarete(commune);
            66..94 :dropCarte:=ajouterCarteAleatoireRarete(rare);
            95..100:dropCarte:=ajouterCarteAleatoireRarete(epique);
            end;
        3:case alea of
            1..40  :dropCarte:=ajouterCarteAleatoireRarete(commune);
            46..87 :dropCarte:=ajouterCarteAleatoireRarete(rare);
            88..98 :dropCarte:=ajouterCarteAleatoireRarete(epique);
            99..100:dropCarte:=ajouterCarteAleatoireRarete(legendaire);
            end;
        4:case alea of
            1..25  :dropCarte:=ajouterCarteAleatoireRarete(commune);
            26..50 :dropCarte:=ajouterCarteAleatoireRarete(rare);
            51..90 :dropCarte:=ajouterCarteAleatoireRarete(epique);
            91..100:dropCarte:=ajouterCarteAleatoireRarete(legendaire);
            end;
        end;
    if dropCarte.numero=0 then dropCarte:=Cartes[random(22)+1];
end;

procedure trade(carte1, carte2 : TCarte ; Var stats : Tstats); //#### table de proba à finir
var rdm,i : Integer;carte:TCarte;
begin
    randomize;
    //C-C -> Commune:93% Rare:5% Epique:1% Legendaire:1%
    if (carte1.rarete = commune) AND (carte2.rarete = commune) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..93:  carte:=ajouterCarteAleatoireRarete(commune);
            94..98: carte:=ajouterCarteAleatoireRarete(rare);
            99:     carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //R-R -> Commune:1% Rare:93% Epique:5% Legendaire:1%
    else if (carte1.rarete = rare) AND (carte2.rarete = rare) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1:      carte:=ajouterCarteAleatoireRarete(commune);
            2..94:  carte:=ajouterCarteAleatoireRarete(rare);
            95..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //E-E -> Commune:1% Rare:1% Epique:93% Legendaire:5%
    else if (carte1.rarete = epique) AND (carte2.rarete = epique) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1:      carte:=ajouterCarteAleatoireRarete(commune);
            2:      carte:=ajouterCarteAleatoireRarete(rare);
            3..95:  carte:=ajouterCarteAleatoireRarete(epique);
            96..100:carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //L-L -> Commune:1% Rare:1% Epique:1% Legendaire:97%
    else if (carte1.rarete = legendaire) AND (carte2.rarete = legendaire) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1:      carte:=ajouterCarteAleatoireRarete(commune);
            2:      carte:=ajouterCarteAleatoireRarete(rare);
            3:      carte:=ajouterCarteAleatoireRarete(epique);
            4..100: carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //C-R
    else if ((carte1.rarete = commune) AND (carte2.rarete = rare)) OR ((carte1.rarete = rare) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..60 : carte:=ajouterCarteAleatoireRarete(commune);
            61..98: carte:=ajouterCarteAleatoireRarete(rare);
            99:     carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //C-E
    else if ((carte1.rarete = commune) AND (carte2.rarete = epique)) OR ((carte1.rarete = epique) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..50:  carte:=ajouterCarteAleatoireRarete(commune);
            51..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //C-L
    else if ((carte1.rarete = commune) AND (carte2.rarete = legendaire)) OR ((carte1.rarete = legendaire) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //R-E
    else if ((carte1.rarete = rare) AND (carte2.rarete = epique)) OR ((carte1.rarete = epique) AND (carte2.rarete = rare)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //R-L
    else if ((carte1.rarete = rare) AND (carte2.rarete = legendaire)) OR ((carte1.rarete = legendaire) AND (carte2.rarete = rare)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //E-L
    else if ((carte1.rarete = epique) AND (carte2.rarete = legendaire)) OR ((carte1.rarete = legendaire) AND (carte2.rarete = epique)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end;

    for i:=ichoix1 to stats.tailleCollection-1 do
        begin
        stats.collection[i]:=stats.collection[i+1];
        end;
    stats.tailleCollection:=stats.tailleCollection-1;
    if ichoix1<ichoix2 then ichoix2:=ichoix2-1;
    for i:=ichoix2 to stats.tailleCollection-1 do
        begin
        stats.collection[i]:=stats.collection[i+1];
        end;
    stats.tailleCollection:=stats.tailleCollection-1;
    echangeFait:=True;
    ajouterCarte(statsJoueur,carte.numero);
    createRawImage(imgCar3,windowWidth-(150+127)*windowWidth div 1080,imgCar2.rect.y,imgCar2.rect.w,imgCar2.rect.h,carte.dir);
    renderRawImage(imgCar3,False);
    sdl_renderpresent(sdlrenderer);
    jouerSon('SFX/echange.wav');
    sdl_delay(3000);
    LancementSalleMarchand;
end;

procedure scrollDeck(var i:Integer;imax:Integer);

begin
	if EventSystem^.wheel.y<0 then
		if i>=imax then
			i:=1
		else
			i:=i+1
	else
		if i<=1 then
            i:=imax
		else
			i:=i-1;
end;


function Highlight(var btnGroup: TButtonGroup; x, y: Integer):Boolean;
begin
  // Vérifier si la souris est sur le bouton
  if (x >= btnGroup.image.rect.x) and (x <= btnGroup.image.rect.x + btnGroup.image.rect.w) and
     (y >= btnGroup.image.rect.y) and (y <= btnGroup.image.rect.y + btnGroup.image.rect.h) then
  begin
    drawRect(yellowCol,255,btnGroup.image.rect.x-20*windowWidth div 1080,btnGroup.image.rect.y-20*windowHeight div 720,btnGroup.image.rect.w+40*windowWidth div 1080,btnGroup.image.rect.h+40*windowHeight div 720);
    highlight:=True;
  end
    else Highlight:=False;

end;

procedure HandleButtonClickSalle(button:TButtonGroup;evenement:evenements;num,x,y:Integer);
begin
    if (x >= button.image.rect.x) and (x <= button.image.rect.x + button.image.rect.w) and
     (y >= button.image.rect.y) and (y <= button.image.rect.y + button.image.rect.h) then
  begin
    if Assigned(button.procEch) then
    begin  
        jouerSon(stringtoPchar('SFX/salle ('+IntToSTR(ord(evenement)+1)+').wav'));
        button.procSalle(evenement,num);
    end;
  end;
end;

procedure HandleButtonClickEch(var button: TButtonGroup; x, y: Integer;carte1,carte2:TCarte;var stats:TStats);
begin
  if (x >= button.image.rect.x+windowOffsetX) and (x <= button.image.rect.x +windowOffsetX+ button.image.rect.w) and
     (y >= button.image.rect.y) and (y <= button.image.rect.y + button.image.rect.h) then
  begin
    if Assigned(button.procEch) then
    begin
        //writeln('procédure spéciale en cours');
        jouerSon('SFX/trade.wav');
		button.procEch(carte1,carte2,stats);
    end;
  end;
end;

procedure actualiserEchange();
begin
    renderRawImage(fond,false);
    if etatChoix then highlight(boutons[3],getmousex,getmousey)
    else highlight(boutons[2],getmousex,getmousey);
    ////writeln(ichoix1);
    renderButtonGroup(boutons[1]);
    renderButtonGroup(boutons[2]);
    renderButtonGroup(boutons[3]);
    if ichoix1<>ichoix2 then
        renderButtonGroup(boutons[4]);
    createRawImage(imgCar1,boutons[2].image.rect.x,boutons[2].image.rect.y,boutons[2].image.rect.w,boutons[2].image.rect.h,StringToPChar('Sprites/Cartes/carte'+intToStr(statsJoueur.collection[iChoix1].numero)+'.bmp'));
    afficherCarte(statsJoueur.collection[ichoix1],255,imgCar1);
    createRawImage(imgCar2,boutons[3].image.rect.x,boutons[3].image.rect.y,boutons[3].image.rect.w,boutons[3].image.rect.h,StringToPChar('Sprites/Cartes/carte'+intToStr(statsJoueur.collection[iChoix2].numero)+'.bmp'));
    afficherCarte(statsJoueur.collection[ichoix2],255,imgCar2);
    renderRawImage(imgEchange,False);
    sdl_destroytexture(imgCar1.imgTexture);
    sdl_freeSurface(imgCar1.imgSurface);
    sdl_destroytexture(imgCar2.imgTexture);
    sdl_freeSurface(imgCar2.imgSurface);
end;

procedure actualiserEchangeDD();
begin
    renderRawImage(fond,false);
    ////writeln(ichoix1);
    if sceneActive='DShop' then
        drawRect(black_col,255,-windowOffsetX*2,0,windowWidth+windowOffsetX*3,windowHeight)
    else
        renderRawImage(imgCar3,120,false);
    updateDialogueBox(dialogues[2]);
    renderButtonGroup(boutons[1]);
    renderButtonGroup(boutons[4]);
    renderRawImage(imgCar1,False);
    renderRawImage(imgEchange,False);
    if (sceneActive='DShop') and echangeFait then 
        begin
        createRawImage(imgcar2,640*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,statsJoueur.collection[ichoix2].dir);
        afficherCarte(statsJoueur.collection[ichoix2],255,imgCar2);
        sdl_destroytexture(imgCar2.imgTexture);
        sdl_freeSurface(imgCar2.imgSurface);
        end
    else renderRawImage(imgCar2,False);
end;

procedure actualiserUS;
begin
    renderRawImage(fond,False);
    updateDialogueBox(dialogues[2]);
    renderButtonGroup(boutons[1]);
    renderButtonGroup(boutons[4]);
    createRawImage(imgcar2,imgcar2.rect.x,imgcar2.rect.y,200*windowWidth div 1080,200*windowHeight div 720,statsJoueur.collection[ichoix2].dir);
    afficherCarte(statsJoueur.collection[ichoix2],255,imgCar2);
    sdl_destroytexture(imgCar2.imgTexture);
    sdl_freeSurface(imgCar2.imgSurface);
    effetDeFondu;
end;

procedure confirmer();
begin
    etatChoix:=not(etatChoix);
end;

procedure Echange;
begin
SceneActive := 'MenuShop';
ClearScreen;
etatchoix:=False;
iChoix1:=1;iChoix2:=2;
SDL_RenderClear(sdlRenderer);
createRawImage(imgEchange,600*windowWidth div 1080,260*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,'Sprites/Menu/echange.bmp');
InitButtonGroup(boutons[1],  415*windowWidth div 1080, 50 *windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Annuler',@LancementSalleMarchand);
InitButtonGroup(boutons[2],  100*windowWidth div 1080, 250*windowHeight div 720, 250*windowWidth div 1080, 250*windowHeight div 720, 'Sprites/Menu/Button1.bmp','X',@confirmer);
InitButtonGroup(boutons[3],  windowWidth-(255+500)*windowWidth div 1080, 250*windowHeight div 720, 250*windowWidth div 1080, 250*windowHeight div 720, 'Sprites/Menu/Button1.bmp','X',@confirmer);
InitButtonGroup(boutons[4],  415*windowWidth div 1080, 580*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Echange',btnProc);
boutons[4].parametresSpeciaux:=3;boutons[4].procEch:=@trade;
end;

procedure rerollDialogueMarchand;
var portrait:PCHar;
begin
    
    case statsJoueur.nbMarchand of
        1:case numDialogue of
            1,3,4,6:portrait:='Sprites/Portraits/marchand.bmp';
            else portrait:='Sprites/Menu/CombatUI_5.bmp'
            end;
        2:case numDialogue of
            1,3,5:portrait:='Sprites/Portraits/marchand.bmp';
            else portrait:='Sprites/Menu/CombatUI_5.bmp'
            end;
        3:case numDialogue of
            2,3,4,5:portrait:='Sprites/Portraits/marchand.bmp';
            else portrait:='Sprites/Menu/CombatUI_5.bmp'
            end;
        4:case numDialogue of
            1,4,5:portrait:='Sprites/Portraits/marchand.bmp';
            else portrait:='Sprites/Menu/CombatUI_5.bmp'
            end;
        5:case numDialogue of
            1,3:portrait:='Sprites/Portraits/marchand.bmp';
            else portrait:='Sprites/Menu/CombatUI_5.bmp'
            end;
        6:case numDialogue of
            2,4,5,6:portrait:='Sprites/Portraits/marchand.bmp';
            else portrait:='Sprites/Menu/CombatUI_5.bmp'
            end;
    end;
    numDialogue:=numDialogue+1;
    if (numDialogue>8) or ((numDialogue>7) and (statsJoueur.nbMarchand<>1)) then
        numDialogue:=numDialogue-1
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp',portrait,0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('MARCHAND_DISCUSSION_'+intToStr(statsJoueur.nbMarchand)+'_'+intToSTR(numDialogue-1)),10);
end;

procedure LancementSalleMarchand; //###
begin
    sceneActive := 'marchand';
    indiceMusiqueJouee:=15;
    //writeln('Lancement de salle Marchand');
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    if nbCartesRecyclables(statsJoueur)<4 then
        echangeFait:=True;
    if not entree then
        begin
        numDialogue:=1;
        if statsJoueur.nbMarchand<6 then statsJoueur.nbMarchand := statsJoueur.nbMarchand+1;
        entree:=True;
        end;
    if not echangeFait then
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 100*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Marchandage',@Echange);
    InitButtonGroup(boutons[2],  440*windowWidth div 1080, 200*windowHeight div 720, 200*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Discussion',@rerollDialogueMarchand);
    InitButtonGroup(boutons[3],  465*windowWidth div 1080, 300*windowHeight div 720, 150*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/marchand.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('MARCHAND_ACCUEIL_'+intToStr(min(statsJoueur.nbMarchand,4))),10);
end;

procedure actualiserDD();
begin
    renderRawImage(fond,120,false);
    renderRawImage(imgCar3,false);
    if not echangeFait then 
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        //HandleButtonClick(boutons[1].button,getmousex,getmousey);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[2],getMouseX,getMouseY);
    renderButtonGroup(boutons[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;

procedure actualiserMarchand();
begin
    renderRawImage(fond,false);
    if not echangeFait then 
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        //HandleButtonClick(boutons[1].button,getmousex,getmousey);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[2],getMouseX,getMouseY);
    renderButtonGroup(boutons[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;

procedure soinFeuCamp();
begin
    jouerSon('SFX/repos.wav');
    subirDegats(statsJoueur, -40, windowWidth div 2, windowHeight div 2);
    echangeFait:=True;
end;



procedure actualiserFeuCamp;
begin
    renderRawImage(fond,false);
    if not echangeFait then 
        begin
        if nbCartesRecyclables(statsJoueur)>3 then 
            begin
            OnMouseHover(boutons[1],getMouseX,getMouseY);
            renderButtonGroup(boutons[1]);
            end;
        OnMouseHover(boutons[2],getMouseX,getMouseY);
        renderButtonGroup(boutons[2]);
        //HandleButtonClick(boutons[1].button,getmousex,getmousey);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;

procedure actualiserDefausse;
begin
    renderRawImage(fond,false);
    highlight(boutons[2],getmousex,getmousey);
    ////writeln(ichoix1);
    renderButtonGroup(boutons[1]);
    renderButtonGroup(boutons[2]);
    renderButtonGroup(boutons[3]);
    createRawImage(imgCar1,boutons[2].image.rect.x,boutons[2].image.rect.y,boutons[2].image.rect.w,boutons[2].image.rect.h,StringToPChar('Sprites/Cartes/carte'+intToStr(statsJoueur.collection[iChoix1].numero)+'.bmp'));
    afficherCarte(statsJoueur.collection[ichoix1],255,imgCar1);
    sdl_destroytexture(imgCar1.imgTexture);
    sdl_freeSurface(imgCar1.imgSurface);
end;

procedure defaussecarte;
begin
    sceneActive:='defausse';
    ClearScreen;
    iChoix1:=1;
    SDL_RenderClear(sdlRenderer);
    InitButtonGroup(boutons[1],  415      *windowWidth div 1080, 50 *windowHeight div 720,250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Annuler',@lancementSalleCamp);
    InitButtonGroup(boutons[2],  (540-125)*windowWidth div 1080, 250*windowHeight div 720,250*windowWidth div 1080, 250*windowHeight div 720, 'Sprites/Menu/Button1.bmp','X',btnProc);
    InitButtonGroup(boutons[3],  415      *windowWidth div 1080, 580*windowHeight div 720,250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Bruler',btnProc);
    boutons[3].parametresSpeciaux:=1;boutons[3].procCarte:=@brulerCarte;
end;


procedure LancementSalleCamp;
begin
    sceneActive:='feuCamp';
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    if not(entree) then  
        begin
        entree:=true;
        end;
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 100*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Bruler carte',@defaussecarte);
    InitButtonGroup(boutons[2],  440*windowWidth div 1080, 200*windowHeight div 720, 200*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Repos',@soinFeuCamp);
    InitButtonGroup(boutons[3],  465*windowWidth div 1080, 300*windowHeight div 720, 150*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('FEU_DE_CAMP_'+intToSTR(random(3)+1)),10);
end;

procedure brulerCarte(carte:TCarte ; var stats : Tstats);
var i:Integer;
begin
    for i:=ichoix1 to stats.tailleCollection-1 do
        begin
        stats.collection[i]:=stats.collection[i+1];
        end;
    stats.tailleCollection:=stats.tailleCollection-1;
    echangeFait:=True;
    lancementSalleCamp;
end;

procedure rerollDialogueLeo;
begin
    if numDialogue=6 then
        numDialogue:=numDialogue
    else
        numDialogue:=numDialogue+1;
    case numDialogue of
    0,2,4,5:
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Leo1.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT_'+intToStr(numDialogue)),10)
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT_'+intToStr(numDialogue)),10);
    end;
end;

procedure rerollDialogueOph;
begin
    if (numDialogue=0) and statsJoueur.bestiaire[25] then
        numDialogue:=12
    else if numDialogue>=14 then
        numDialogue:=1
    else if numDialogue=5 then
        begin
        ajouterCarte(statsJoueur,24);
        numDialogue:=6;
        end
    else if (numDialogue>=6) and (numDialogue<=11) then
        numDialogue:=random(5)+7
    else
        numDialogue:=numDialogue+1;
    case numDialogue of
    0,2,4,5,13,15:
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Ophiucus1.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT2_'+intToStr(numDialogue)),10);
    7..11:
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Ophiucus2.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT2_'+intToStr(numDialogue)),10);
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT2_'+intToStr(numDialogue)),10);
    end;
end;

procedure rerollDialogueDD;
begin
    numDialogue:=min(numDialogue+1,9);
    case numDialogue of
    0,2,4,6,7,8:
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/dd.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT4_'+intToStr(numDialogue)),10);
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT4_'+intToStr(numDialogue)),10);
    end;
end;

procedure desequiperRelique(var stats:TStats);
begin
	case stats.relique of
	1:
	stats.vitesse:=stats.vitesse-3;
	2:
	stats.manaMax:=stats.manaMax-4;
	3:	
	begin 
	stats.vieMax:=stats.vieMax-20;
	end;
	4:
	stats.multiplicateurSoin:=stats.multiplicateurSoin-0.5;
	5:
	begin
	stats.manaDebutCombat:=0;
	stats.multiplicateurMana:=stats.multiplicateurMana-0.3
	end;
	6:stats.force:=stats.force-5;
	7:stats.defense:=stats.defense-6;
	8:begin
		stats.multiplicateurDegat:=stats.multiplicateurDegat-0.5;
		stats.vieMax:=stats.vieMax+10;
		end;
	end;
end;

procedure tradeDD(num:Integer;var stats:TStats);
var i:Integer;modif1,modif2:Integer;
begin
    if etatChoix then
    begin
    jouerSon('SFX/echange2.wav');
    case ichoix1 of
    1:stats.multiplicateurMana:=stats.multiplicateurMana*0.8;
    2:stats.force:=stats.force-3;
    3:stats.defense:=stats.defense-3;
    4:stats.multiplicateurSoin:=stats.multiplicateurSoin*0.8;
    5:stats.vieMax:=stats.vieMax-30;
    6:stats.manaMax:=stats.manaMax-4;
    end;
    if echangeFait then 
        begin
        if stats.collection[ichoix2].discard then 
            stats.collection[ichoix2].chargesMax:=stats.collection[ichoix2].chargesMax+2
        else
            stats.collection[ichoix2].chargesMax:=stats.collection[ichoix2].chargesMax+3;
        sdl_settexturecolormod(stats.collection[ichoix2].image.imgtexture,100,0,0);
        end
    else
        case ichoix2 of
        1:begin
            stats.manaMax:=stats.manaMax+2;
            for i:=1 to 2+random(2) do 
                begin
                ajouterCarte(stats,27);
                stats.collection[stats.tailleCollection].cout:=min(stats.manaMax,10)
                end;
            end;
        2:begin
            stats.vieMax:=stats.vieMax+20;
            for i:=1 to 2+random(2) do 
                begin
                ajouterCarte(stats,28);
                stats.collection[stats.tailleCollection].cout:=min(stats.manaMax,10);
                end;
            end;
        3:  begin
            desequiperRelique(stats);
            stats.relique:=10;
            stats.vieMax:=stats.vieMax+10;
            stats.manaMax:=stats.manaMax+1;
            end;
        4:stats.force:=stats.force+4;
        5:stats.multiplicateurMana:=stats.multiplicateurMana+0.5;
        6:begin
            randomize;
            for i:=1 to stats.tailleCollection do 
                begin
                modif1:=stats.collection[i].cout-stats.collection[i].coutBase;
                modif2:=stats.collection[i].chargesMax-stats.collection[i].chargesMaxBase;
                stats.collection[i]:=cartes[random(22)+1];
                stats.collection[i].cout:=stats.collection[i].cout+modif1;
                stats.collection[i].chargesMax:=stats.collection[i].chargesMax+modif2;
                end;
            end;
        end;
    echangeFait:=True;
    if sceneActive='DShop' then
        begin
        sceneActive:='Event';
        InitDialogueBox(dialogues[1],nil,nil,50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('FIN_EVENT5_0'),100);
        ajoutDialogue(nil,extractionTexte('FIN_EVENT5_1'));
        sceneSuiv:='Map';
        declencherFondu(false,0);
        end
    else
        lancementSalleHasardDD;
    end
    else
        begin
        jouerSon('SFX/conf.wav');
        if sceneActive='DShop' then
            if echangeFait then
                initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp',nil,0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT5_3'),10)
            else
                initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp',nil,0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT5_1'),10)
        else
            initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/dd.bmp',0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT4_1'),10);
        etatChoix:=True;
        end;
end;

procedure EchangeDD;
begin
    SceneActive := 'DDShop';
    ClearScreen;
    etatchoix:=False;
    SDL_RenderClear(sdlRenderer);
    if not entree then
        begin
        entree:=True;
        ichoix1:=random(4)+1;ichoix2:=random(3)+1;
        end;
    createRawImage(imgEchange,440*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,'Sprites/Menu/echange.bmp');
    createRawImage(imgcar1,   240*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,StringToPChar('Sprites/Echange/stat'+intToSTR(ichoix1)+'.bmp'));
    createRawImage(imgcar2,   640*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,StringToPChar('Sprites/Echange/stat'+intToSTR(ichoix2+10)+'.bmp'));
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/dd.bmp',0,460*windowWidth div 1080,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT4_0'),10);
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 50 *windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Annuler',@LancementSalleHasardDD);
    InitButtonGroup(boutons[4],  415*windowWidth div 1080, 400*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Pacte',btnProc);
    boutons[4].parametresSpeciaux:=4;boutons[4].procRel:=@tradeDD;
end;

procedure lancementEchangeDiable;
begin
    SceneActive := 'DShop';
    ClearScreen;
    etatchoix:=False;
    SDL_RenderClear(sdlRenderer);
    repeat
        ichoix1:=random(4)+4;
    until not (((statsJoueur.vieMax<=60) and (ichoix1=5)) or ((statsJoueur.manaMax<=7) and (ichoix1=6)));
    if ichoix1=7 then
        ichoix2:=6
    else
    repeat
        ichoix2:=random(5)+4;
        //writeln(ichoix2)
    until ichoix2<>6;
    createRawImage(imgEchange,440*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,'Sprites/Menu/echange.bmp');
    createRawImage(imgcar1,240*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,StringToPChar('Sprites/Echange/stat'+intToSTR(ichoix1)+'.bmp'));
    if ichoix2>6 then
        begin
        createRawImage(imgcar2,640*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,statsJoueur.collection[1].dir);
        echangeFait:=True;
        ichoix2:=1;
        end
    else
        createRawImage(imgcar2,640*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,StringToPChar('Sprites/Echange/stat'+intToSTR(ichoix2+10)+'.bmp'));
    initDialogueBox(dialogues[2],nil,nil,0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT5_0'),10);
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 50 *windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Annuler',@choixSalle);
    InitButtonGroup(boutons[4],  415*windowWidth div 1080, 400*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','"Echange"',btnProc);
    boutons[4].parametresSpeciaux:=4;boutons[4].procRel:=@tradeDD;
end;

procedure upgradeUS(i:Integer;var stats:TStats);
begin
    if etatChoix then
        begin
        jouerSon('SFX/upgrade.wav');
        if echangeFait then
            stats.collection[ichoix2].chargesMax:=stats.collection[ichoix2].chargesMax+1
        else
            stats.collection[ichoix2].cout:=stats.collection[ichoix2].cout-3;
        sceneActive:='Event';
        sceneSuiv:='Map';
        initDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Portraits/ulgatr.bmp',0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('FIN_EVENT6_1'),10);
        ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('FIN_EVENT6_2'));
        end
    else
        begin
        etatChoix:=True;
        if echangeFait then
            initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/ulgatr.bmp',0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT6_1'),10)
        else
            initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/soeryo.bmp',0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT7_1'),10);
        end;
    
end;

procedure lancementSalleHasardUS;
begin
    SceneActive := 'US';
    ClearScreen;
    SDL_RenderClear(sdlRenderer);
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    createRawImage(imgcar2,440*windowWidth div 1080,160*windowHeight div 720,200*windowWidth div 1080,200*windowHeight div 720,statsJoueur.collection[1].dir);
    ichoix2:=1;
    if echangeFait then
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/ulgatr.bmp',0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT6_0'),10)
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/soeryo.bmp',0,460*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('ECH_EVENT7_0'),10);
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 50 *windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    InitButtonGroup(boutons[4],  415*windowWidth div 1080, 400*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Augmentation',btnProc);
    boutons[4].parametresSpeciaux:=4;boutons[4].procRel:=@upgradeUS;
end;

procedure LancementSalleHasardDD;
begin
    sceneActive:='DD';
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    createRawImage(imgCar3,0,0,windowWidth,windowHeight,'Sprites/salles/ddfull.bmp');
    if not echangeFait then
        numDialogue:=0;
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 100*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Pacte',@EchangeDD);
    InitButtonGroup(boutons[2],  440*windowWidth div 1080, 200*windowHeight div 720, 200*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Discussion',@rerollDialogueDD);
    InitButtonGroup(boutons[3],  465*windowWidth div 1080, 300*windowHeight div 720, 150*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/dd.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT4_0'),10);
end;

procedure LancementSalleHasardLeo;
begin
    sceneActive:='Leo_Menu';
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    numDialogue:=0;
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 100*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Affronter',@LancementVSLeo);
    InitButtonGroup(boutons[2],  440*windowWidth div 1080, 200*windowHeight div 720, 200*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Discussion',@rerollDialogueLeo);
    InitButtonGroup(boutons[3],  465*windowWidth div 1080, 300*windowHeight div 720, 150*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Leo3.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT_0'),10);
end;

procedure LancementSalleHasardOph;
begin
    sceneActive:='Oph_Menu';
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    statsJoueur.ophiucus:=True;
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    numDialogue:=0;
    //InitButtonGroup(boutons[1],  415, 100, 250, 100, 'Sprites/Menu/Button1.bmp','Affronter',@LancementVSLeo);
    InitButtonGroup(boutons[2],  440*windowWidth div 1080, 200*windowHeight div 720, 200*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Discussion',@rerollDialogueOph);
    InitButtonGroup(boutons[3],  465*windowWidth div 1080, 300*windowHeight div 720, 150*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Ophiucus4.bmp',0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT2_0'),10);
end;

procedure LancementSalleHasardReposRisque;
begin
    sceneActive:='Hreposrisque_Menu';
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    numDialogue:=0;
    InitButtonGroup(boutons[1],  415*windowWidth div 1080, 100*windowHeight div 720, 250*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Se reposer',@ReposRisque);
    InitButtonGroup(boutons[2],  465*windowWidth div 1080, 300*windowHeight div 720, 150*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp',nil,0,450*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('DIALOGUE_EVENT_0'),10);
end;


procedure actualiserSalleLeo;
begin
    renderRawImage(fond,false);
    if sceneActive='Leo_Menu' then
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[2],getMouseX,getMouseY);
    renderButtonGroup(boutons[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;

procedure actualiserReposRisque;
begin
    renderRawImage(fond,false);
    if sceneActive='Hreposrisque_Menu' then
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        end;
    OnMouseHover(boutons[2],getMouseX,getMouseY);
    renderButtonGroup(boutons[2]);
end;
procedure ReposRisque;
begin
    //statsJoueur.avancement := statsJoueur.avancement+1;
    case random(2)+1 of
    1 : begin
        StatsJoueur.vie := StatsJoueur.vie + 15;
        LancementSalleCombat;
        SceneActive:='Event';
        InitDialogueBox(dialogues[1],nil,nil,-50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT3_3'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT3_4'));
        sceneSuiv:='Jeu';
        end;
    2 : begin
        StatsJoueur.vie := StatsJoueur.vie + 50;
        choixSalle;
        SceneActive:='Event';
        InitDialogueBox(dialogues[1],nil,nil,-50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT3_5'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT3_6'));
        SceneSuiv:='map';
        end;
    end;
end;

procedure LancementSalleHasard;
var alea,i:Integer;
begin
//writeln('Lancement de salle Hasard');
//statsJoueur.avancement := statsJoueur.avancement+1;
ClearScreen;
SDL_RenderClear(sdlRenderer);
randomize;
if (trouverCarte(statsJoueur,23)) and not (statsJoueur.ophiucus) and (random(4)=0) then alea:=2
    else if statsJoueur.avancement>(MAXSALLES div 2) then alea:=random(9)+1
    else alea:=random(8)+1;
case alea of
2:  if (statsJoueur.ophiucus) then 
        begin
        echangeFait:=((random(100) mod 2)=0);
        sceneActive:='Event';
        sceneSuiv:='US';
        InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp',nil,0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('INTRO_EVENT6_1'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT6_2'));
        if echangeFait then
            begin
            ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('INTRO_EVENT6_3'));
            ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('INTRO_EVENT6_4'));
            if trouverCarte(statsJoueur,26) then
                for i:=1 to 9 do
                    case i of 
                    2,4,5,7,9:ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('SPEC_EVENT6_'+intToSTR(i)));
                    3,8:ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('SPEC_EVENT6_'+intToSTR(i)));
                    else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('SPEC_EVENT6_'+intToStr(i)));
                    end
            else if trouverCarte(statsJoueur,25) then
                for i:=1 to 5 do
                    case i of 
                    4:ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('SPEC_EVENT7_'+intToSTR(i)));
                    2,3,5:ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('SPEC_EVENT7_'+intToSTR(i)));
                    else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('SPEC_EVENT7_'+intToStr(i)));
                    end;
            for i:=5 to 12 do
                    case i of 
                    5,7,9,11:ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('INTRO_EVENT6_'+intToSTR(i)));
                    8,10,12:ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('INTRO_EVENT6_'+intToSTR(i)));
                    else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('INTRO_EVENT6_'+intToStr(i)));
                    end
            end
        else
            begin
            ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('INTRO_EVENT7_3'));
            ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('INTRO_EVENT7_4'));
            if trouverCarte(statsJoueur,25) then
                for i:=1 to 5 do
                    case i of 
                    4:ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('SPEC_EVENT7_'+intToSTR(i)));
                    2,3,5:ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('SPEC_EVENT7_'+intToSTR(i)));
                    else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('SPEC_EVENT7_'+intToStr(i)));
                    end
            else if trouverCarte(statsJoueur,26) then
                for i:=1 to 9 do
                    case i of 
                    2,4,5,7,9:ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('SPEC_EVENT6_'+intToSTR(i)));
                    3,8:ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('SPEC_EVENT6_'+intToSTR(i)));
                    else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('SPEC_EVENT6_'+intToStr(i)));
                    end;
            for i:=5 to 10 do
                    case i of 
                    5,7,10:ajoutDialogue('Sprites/Portraits/ulgatr.bmp',extractionTexte('INTRO_EVENT7_'+intToSTR(i)));
                    6,8,9:ajoutDialogue('Sprites/Portraits/soeryo.bmp',extractionTexte('INTRO_EVENT7_'+intToSTR(i)));
                    else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('INTRO_EVENT7_'+intToStr(i)));
                    end
            end;
        end
    else
        if trouverCarte(statsJoueur,23) then
            begin
            sceneActive:='Event';
            InitDialogueBox(dialogues[1],nil,nil,50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT2_1'),100);
            ajoutDialogue(nil,extractionTexte('INTRO_EVENT2_2'));
            sceneSuiv:='Ophiucus';
            end
    else
        if statsJoueur.avancement>(MAXSALLES div 6) then
        begin
        sceneActive:='Event';
        InitDialogueBox(dialogues[1],nil,nil,50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT1_1'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT1_2'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT1_3'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT1_4'));
        sceneSuiv:='Leo';
        end
    else
        lancementSalleCombat;
4: begin
    sceneActive:='Event';
    InitDialogueBox(dialogues[1],nil,nil,50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT3_1'),100);
    ajoutDialogue(nil,extractionTexte('INTRO_EVENT3_2'));
    sceneSuiv:='HReposRisque';
    end;
3:begin
    sceneActive:='Event';
    InitDialogueBox(dialogues[1],nil,nil,50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT5_1'),100);
    ajoutDialogue(nil,extractionTexte('INTRO_EVENT5_2'));
    ajoutDialogue(nil,extractionTexte('INTRO_EVENT5_3'));
    sceneSuiv:='EchangeDiable';
end;
6,7: lancementSalleCamp;
1: lancementSalleCombat;
5,8: lancementSalleMarchand;
9:  begin
        sceneActive:='Event';
        mix_pauseMusic;
        InitDialogueBox(dialogues[1],nil,nil,50*windowWidth div 1080,windowHeight div 3 - 100*windowHeight div 720,windowWidth,400*windowHeight div 720,extractionTexte('INTRO_EVENT4_1'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT4_2'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT4_3'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT4_4'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT4_5'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT4_6'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT4_7'));
        sceneSuiv:='DD';
        end

else lancementSalleCombat;
end;
end;

procedure HoverSalle(var salle: TSalle; x, y: Integer);overload;
begin
  // Vérifier si la souris est sur le bouton
  if (x >= salle.image.image.rect.x) and (x <= salle.image.image.rect.x + salle.image.image.rect.w) and
     (y >= salle.image.image.rect.y) and (y <= salle.image.image.rect.y + salle.image.image.rect.h) then
  begin
    drawRect(black_col,255,salle.image.image.rect.x+(salle.image.image.rect.w div 2)-(salle.image.image.rect.w div 20),salle.image.image.rect.y+salle.image.image.rect.h div 50,salle.image.image.rect.w div 10,salle.image.image.rect.h-salle.image.image.rect.h div 50);
    if not salle.image.hoverSoundPlayed then
    begin
      salle.image.image.rect.w := Round(salle.image.originalWidth * 1.02);
      salle.image.image.rect.h := Round(salle.image.originalHeight * 1.02);

      salle.image.button.rect.w := salle.image.image.rect.w;
      salle.image.button.rect.h := salle.image.image.rect.h;
      salle.image.image.rect.x:=round(salle.image.image.rect.x-salle.image.originalWidth*0.01);

      SDL_SetTextureAlphaMod(salle.image.image.imgTexture, 180);  // Alpha à 180 pour OnHover

      // Jouer le son de hoverr
      jouerSon('SFX/hoverSalle.wav');
      salle.image.hoverSoundPlayed := True;
    end;
  end
  else
  if salle.image.hoverSoundPlayed then
  begin
    // Réinitialiser l'alpha et la taille si la souris quitte la zone de Hover
    SDL_SetTextureAlphaMod(salle.image.image.imgTexture, 150);
      //btnGroup.image.rect.x := Round(btnGroup.image.rect.x *1.05);
      //btnGroup.image.rect.y := Round(btnGroup.image.rect.x *1.05);
      salle.image.image.rect.x:=round(salle.image.image.rect.x+salle.image.originalWidth*0.01);
      salle.image.image.rect.h :=  salle.image.originalHeight;
      salle.image.image.rect.w :=  salle.image.originalWidth;
      salle.image.button.rect.w := salle.image.originalWidth;
      salle.image.button.rect.h := salle.image.originalHeight;
    salle.image.hoverSoundPlayed := False;  // Réinitialiser pour le prochain Hover
  end;
end;

procedure affichageSalle(var salle:TSalle;x,y,i:integer);
var dir:PCHar;
begin
    
    //writeln(dir);
    if salle.evenement=boss then
        dir:=StringToPChar('Sprites/salles/porte'+inttostr(ord(salle.evenement)+(statsJoueur.avancement div (MAXSALLES div 4)))+'.bmp')
    else
        dir:=StringToPChar('Sprites/salles/porte'+inttostr(ord(salle.evenement)+1)+'.bmp');
    InitButtonGroup(salle.image,x-(256 div 2)*windowWidth div 1080,y-100*windowHeight div 720,256*windowWidth div 1080,392*windowHeight div 720,dir,' ',btnProc);
    RenderButtonGroup(salle.image);
    salle.image.parametresSpeciaux:=2;
    salle.image.procSalle:=@lancerSalle;
    salle.image.numero:=i;
end;

procedure affichageSalles(var salle1,salle2,salle3:TSalle);
var depart:TSalle;
begin
    depart.evenement:=rien;
    affichageSalle(depart,X2,Y1,0);
    affichageSalle(salle1,X1,Y2,1);
    affichageSalle(salle2,X2,Y2,2);
    affichageSalle(salle3,X3,Y2,3);
end;

procedure InitDecorMap;
begin
    randomize;
	sdl_freesurface(fond.imgSurface);
	sdl_destroytexture(fond.imgTexture);
    case (statsJoueur.avancement-1) div (MAXSALLES div 4) of
    0:CreateRawImage(fond,0,-80*windowHeight div 720,windowWidth,900*windowHeight div 720,StringToPChar('Sprites/Menu/map1.bmp'));
    1,2:CreateRawImage(fond,0,-80*windowHeight div 720,windowWidth,900*windowHeight div 720,StringToPChar('Sprites/Menu/map2.bmp'));
    3: CreateRawImage(fond,0,-80*windowHeight div 720,windowWidth,900*windowHeight div 720,StringToPChar('Sprites/Menu/map4.bmp'));
    else CreateRawImage(fond,0,-80*windowHeight div 720,windowWidth,900*windowHeight div 720,StringToPChar('Sprites/Menu/map'+inttoStr(random(2)*2+2)+'.bmp'));
    end;
end;

procedure choixSalle();
    
begin
    X1:=(windowWidth div 2)+(windowWidth div 4);
    X2:=(windowWidth div 2);
    X3:=(windowWidth div 2)-(windowWidth div 4);
    Y2:=(windowHeight  div 2) - (windowHeight div 2)+128;
    Y1:=(windowHeight  div 2) + (windowHeight div 4);
    sauvegarder(statsJoueur);
    if (statsJoueur.avancement) mod (MAXSALLES div 4)=0 then
        InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('TXT_MAP'+intToSTR(10*(statsJoueur.avancement div (MAXSALLES div 4)))),10);
    if statsJoueur.avancement<=1 then
        InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('TXT_MAP'+intToSTR(random(4)+statsJoueur.avancement)),10);
    entree:=false;
    combatFini:=False;
    echangeFait:=False;
    etatChoix:=False;
    SceneActive := 'map';
    ScenePrec:='map';
    InitDecorMap;
    declencherFondu(False,600);
    TimeDebutFondu:=sdl_getTicks-300;
    //writeln('Initializing rooms...');
    
    generationChoix(salles[1], salles[2], salles[3]);
    //writeln('Displaying rooms');
    affichageSalles(salles[1], salles[2], salles[3]);
    
    //writeln('Room choice started');
    new(EventSystem);
    
end;


procedure actualiserMap();
var i:Integer;
begin
    SDL_PumpEvents();
    drawrect(black_col,255,0,0,WINDOWWIDTH,windowHeight);
    renderRawImage(fond,True);
    if (((sceneActive='map') and ((statsJoueur.avancement=1) or ((statsJoueur.avancement) mod (MAXSALLES div 4)=0)))) and (statsJoueur.avancement<=MAXSALLES+1) then
        updateDialogueBox(dialogues[1]);
    for i:=1 to 3 do
        begin
        if (salles[i].evenement<>rien) or (sceneActive='map') then
            renderRawImage(salles[i].image.image,255,False);
        if (ord(salles[i].evenement)<4) and (sceneActive='map') then
            hoversalle(salles[i],getmousex,getmousey);
        end;
end;

procedure activationEvent(scene:String);
begin
    black_color.r := 0; 
    black_color.g := 0; 
    black_color.b := 0;
    DeclencherFondu(False,300);
    while high(queueDialogues)>-1 do
		supprimeDialogue(1);
    case scene of
        'Leo':LancementSalleHasardLeo;
        'Ophiucus':lancementSalleHasardOph;
        'DD':lancementSalleHasardDD;
        'US':lancementSalleHasardUS;
        'EchangeDiable':lancementEchangeDiable;
        'HReposRisque':lancementSalleHasardReposRisque;
        'Intro':
            begin 
            ChoixSalle;
            end;
        'Map':begin
            ChoixSalle;
            end;
        else sceneActive := sceneSuiv;
    end;
end;

procedure activationEvent(evenement:evenements);
begin
    DeclencherFondu(False,300);
    statsJoueur.avancement:=statsJoueur.avancement+1;
    jouerSon(stringtoPchar('SFX/lance'+inttostr(ord(evenement)+1)+'.wav'));
    case evenement of
        hasard:begin
            LancementSalleHasard;
            end;
        combat:begin
            LancementSalleCombat;
            end;
        boss:begin
            LancementSalleBoss;
            end;
        marchand:begin
            LancementSalleMarchand;
            end;
        camp:begin 
            LancementSalleCamp;
            end;
    end;
end;

    


begin
    
//writeln('mapSys ready')
end.