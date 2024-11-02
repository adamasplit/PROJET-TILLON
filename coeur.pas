unit coeur;

interface
uses
  math,
  memgraph,
  SDL2,
  SysUtils;



const MAXSALLES=40; //nombre de salles total pour finir le jeu
  MAXENNEMIS=15; //nombre d'ennemis ayant une entrée dans le bestiaire
  MAXCARTES=60; //taille max du deck

var whiteCol,b_color,bf_color,f_color,navy_color,black_color,red_color: TSDL_Color;


type evenements=(combat,marchand,hasard,camp,rien,boss);
type typeObjet=(joueur,ennemi,projectile,laser,epee,effet,autre);

type
  TAnimation = record
    ObjectName: PChar;    // Nom de l'objet (par exemple 'Joueur')
    Etat: PChar;          // État de l'objet (par exemple 'idle', 'run')
    CurrentFrame: Integer; // Frame actuelle de l'animation
    TotalFrames: Integer;  // Nombre total de frames pour cet état
    LastUpdateTime: UInt32; // Dernière mise à jour de la frame
    IsLooping: Boolean;    // L'animation boucle-t-elle ?
    isFliped : Boolean; // L'image doit-elle etre renversée?
    estActif:Boolean; // L'objet est-il animé?
  end;

type TCarte=record
    nom:pchar;
    cout:Integer; //Coût en mana
    rarete:(commune,rare,epique,legendaire);
    numero:integer;
    description:String; //Description dans le menu
    dir:PChar;
    image:TImage;
    charges,chargesMax:Integer;
    active:Boolean;
end;
var iCarteChoisie:Integer;

type TDeck=array of TCarte;
type TPaquet=array[1..MAXCARTES] of TCarte;

{type TStats=record
    indice:Integer; //représente l'indice de l'objets dans la liste d'objets
    genre:typeObjet;
    force:Integer;
    multiplicateurDegat:Real;
    defense:Integer;
    vie:Integer;
    vieMax:Integer;
    mana:Integer;
    manaMax:Integer;
    avancement:Integer;
    multiplicateurMana:Real;
    Vitesse:Integer;
    manaDebutCombat:Integer;
    collection:TPaquet;
    deck:^TDeck;
    tailleCollection:Integer;
    bestiaire:array[1..MAXENNEMIS] of Boolean;    
    xcible,ycible,compteurAction:Integer;
    degats:Integer;origine:typeObjet;vectX,vectY,xreel,yreel,angle:Real;
    dureeVie,delai,vitRotation:Integer
end;}

type TStats=record //(version variable)
    indice:Integer; //représente l'indice de l'objets dans la liste d'objets
    force:Integer;
    multiplicateurDegat:Real;
    defense:Integer;
    vie:Integer;
    vieMax:Integer;
    xreel,yreel:Real;
    etatPrec:TANimation; //dans le cas où l'objet est interrompu (par des dégâts par exemple) 
    case genre:typeObjet of 
        joueur:(mana:Integer;
          manaMax:Integer;
          avancement:Integer;
          multiplicateurMana:Real;
          Vitesse:Integer;
          manaDebutCombat:Integer;
          collection:TPaquet;
          deck:^TDeck;
          tailleCollection:Integer;
          bestiaire:array[1..MAXENNEMIS] of Boolean;
          pendu:Boolean;
          compteurLeMonde:Integer;
          laMort,leFou:Boolean;
          nbJustice : Integer);
        
        ennemi:(
          xcible,
          ycible,
          compteurAction,
          nbFrames1,
          nbFrames2,
          nbFrames3,
          nbFramesMort,
          nbFramesApparition:Integer;
          typeIA_MVT:Byte;
          degatsContact:Integer;
          cooldown:Byte;
          vitessePoursuite:Integer;
          nomAttaque:PCHar);
        
        projectile,laser:(degats:Integer;origine:typeObjet;vectX,vectY,angle:Real;dureeVie,delai,delaiInit,vitRotation:Integer);
        effet:(fixeJoueur:Boolean);
end;

var Cartes:Array[1..22] of TCarte; //preset pour les cartes

// Structure TCol pour la gestion des collisions
type  TCol = record
    isTrigger: Boolean;     // Si vrai, l'objet ne bloque pas
    estActif: Boolean;      // Si vrai, l'objet est actif pour les collisions
    dimensions: TSDL_Rect;  // Boîte de collision (dimensions w et h)
    offset: TSDL_Point;     // Décalage par rapport à la position de l'objet
    nom: PChar;             // Nom de l'objet (facultatif)
  end;

type
  TObjet = record
    image: TImage;          // Image associée à l'objet
    anim: TAnimation;       // Animation associée à l'objet
    IsTrigger: Boolean;     // Si vrai, ne bloque pas, mais déclenche un événement (ex: un mur n'est pas trigger)
    stats:TStats;           // Caractéristiques de l'objet
    col:TCol;
  end;

type
  TButtonGroup = record
    button: TButton;       // Bouton de base
    image: TImage;         // Image de fond animée (taille et alpha)
    hoverSoundPlayed: Boolean;  // Pour suivre le premier survol de la souris
    originalWidth, originalHeight: Integer; 
  end;
type TSalle=record
    evenement:evenements;
    image:TButtonGroup;
end;


type ListeObjets = Array of TObjet; 
var LObjets: ListeObjets; //Liste universelle des objets présents
combatFini,vagueFinie,leMonde:Boolean;
statsJoueur: TStats;
PDeck:TDeck; //deck pointé par les stats du joueur

//Procédures de gestion de LObjets

procedure AjoutObjet(var obj:TObjet);
procedure supprimeObjet(var obj:TObjet); 
        
implementation

procedure AjoutObjet(var obj:TObjet); //Ajoute directement un projectile/autre à LObjets
begin
    
    obj.stats.indice:=High(LObjets)+1;
    setlength(LObjets,obj.stats.indice+1);
    if (obj.stats.indice<=High(LObjets)) then
      LObjets[obj.stats.indice]:=obj;
end;

procedure supprimeObjet(var obj:TObjet); //Retire un élément de LObjets

var i,taille:Integer;

begin
    taille:=High(LObjets)+1;
    //writeln('destruction de LOBjets[',obj.stats.indice,'], taille de LObjets:',taille);
    SDL_DestroyTexture(obj.image.imgtexture);
    SDL_freeSurface(obj.image.imgSurface);
    for i:=obj.stats.indice to taille-2 do 
        if (i<=High(LObjets)) then
        begin
            LObjets[i]:=LObjets[i+1];
            LObjets[i].stats.indice:=i;
        end;
    setlength(LObjets,taille-1);
end;



var i:Integer;
begin
   // Définir les couleurs de base
  whiteCol.r := 255; whiteCol.g := 255; whiteCol.b := 255;
  bf_color.r :=5; bf_color.g :=12; bf_color.b :=156;
  b_color.r :=167; b_color.g :=230; b_color.b :=255;
  f_color.r :=58; f_color.g :=190; f_color.b :=249;
  navy_color.r :=53; navy_color.g :=114; navy_color.b :=239;
  black_color.r := 0; black_color.g := 0; black_color.b := 0;
  red_color.r := 255; red_color.g := 0; red_color.b := 50;



  statsJoueur.genre:=joueur;
  statsJoueur.vieMax:=100;
  statsJoueur.vie:=100;
  statsJoueur.mana:=0;
  statsJoueur.manaMax:=10;
  statsJoueur.force:=1;
  statsJoueur.multiplicateurDegat:=1;
  statsJoueur.multiplicateurMana:=1;
  statsJoueur.nbJustice:=0;

  for i:=1 to 22 do begin
    cartes[i].numero:=i;
    case i of 
      1:cartes[i].nom:='bateleur';
      2:cartes[i].nom:='papesse';
      3:cartes[i].nom:='imperatrice';
      4:cartes[i].nom:='empereur';
      5:cartes[i].nom:='pape';
      6:cartes[i].nom:='amants';
      7:cartes[i].nom:='chariot';
      8:cartes[i].nom:='justice';
      9:cartes[i].nom:='ermite';
      10:cartes[i].nom:='roue';
      11:cartes[i].nom:='force';
      12:cartes[i].nom:='pendu';
      13:cartes[i].nom:='_';
      14:cartes[i].nom:='temperance';
      15:cartes[i].nom:='diable';
      16:cartes[i].nom:='tour';
      17:cartes[i].nom:='etoile';
      18:cartes[i].nom:='lune';
      19:cartes[i].nom:='soleil';
      20:cartes[i].nom:='ange';
      21:cartes[i].nom:='monde';
      22:cartes[i].nom:='fou';
      end;
    case i of
      1,2,3,4,5,10:cartes[i].rarete:=commune;
      6,7,8,9,11,16,19:cartes[i].rarete:=rare;
      12,14,17,18,20,22:cartes[i].rarete:=epique;
      13,15,21:cartes[i].rarete:=legendaire;
      end;
    case i of
      1,6:cartes[i].cout:=1;
      10,13,17:cartes[i].cout:=0;
      2,5,16,18,22:cartes[i].cout:=2;
      3,4,12,14,19:cartes[i].cout:=3;
      11,20:cartes[i].cout:=4;
      8,9,15,21:cartes[i].cout:=5;
      7:cartes[i].cout:=6;
      end;
    case i of 
    1:cartes[i].dir:='Sprites/Cartes/carte1.bmp';
    2:cartes[i].dir:='Sprites/Cartes/carte2.bmp';
    3:cartes[i].dir:='Sprites/Cartes/carte3.bmp';
    4:cartes[i].dir:='Sprites/Cartes/carte4.bmp';
    5:cartes[i].dir:='Sprites/Cartes/carte5.bmp';
    6:cartes[i].dir:='Sprites/Cartes/carte6.bmp';
    7:cartes[i].dir:='Sprites/Cartes/carte7.bmp';
    8:cartes[i].dir:='Sprites/Cartes/carte8.bmp';
    9:cartes[i].dir:='Sprites/Cartes/carte9.bmp';
    10:cartes[i].dir:='Sprites/Cartes/carte10.bmp';
    11:cartes[i].dir:='Sprites/Cartes/carte11.bmp';
    12:cartes[i].dir:='Sprites/Cartes/carte12.bmp';
    13:cartes[i].dir:='Sprites/Cartes/carte13.bmp';
    14:cartes[i].dir:='Sprites/Cartes/carte14.bmp';
    15:cartes[i].dir:='Sprites/Cartes/carte15.bmp';
    16:cartes[i].dir:='Sprites/Cartes/carte16.bmp';
    17:cartes[i].dir:='Sprites/Cartes/carte17.bmp';
    18:cartes[i].dir:='Sprites/Cartes/carte18.bmp';
    19:cartes[i].dir:='Sprites/Cartes/carte19.bmp';
    20:cartes[i].dir:='Sprites/Cartes/carte20.bmp';
    21:cartes[i].dir:='Sprites/Cartes/carte21.bmp';
    22:cartes[i].dir:='Sprites/Cartes/carte22.bmp';
    end;
    cartes[i].chargesMax:=1;
    end;
    writeln('CORE ready');
end.