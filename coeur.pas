unit coeur;

interface
uses
  math,
  memgraph,
  SDL2,
  SysUtils;



const MAXSALLES=40; //nombre de salles total pour finir le jeu
  MAXENNEMIS=42; //nombre d'ennemis ayant une entrée dans le bestiaire
  MAXCARTES=60; //taille max du deck
  TAILLE_VAGUE=4;
var whiteCol,b_color,bf_color,f_color,navy_color,red_color,black_col,yellowCol,bk_col: TSDL_Color;

type TRarete=(commune,rare,epique,legendaire);
type evenements=(combat,marchand,hasard,camp,rien,boss);
type typeObjet=(joueur,ennemi,projectile,laser,epee,effet,explosion,explosion2,afterimage,autre);

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
    cout,coutBase:Integer; //Coût en mana
    rarete:TRarete;
    numero:integer;
    description:String; //Description dans le menu
    dir:PChar;
    image:TImage;
    charges,chargesMax,chargesMaxBase:Integer;
    active:Boolean;
    discard:Boolean;
    inverse:Boolean;
end;
var iCarteChoisie:Integer;

type TDeck=array of TCarte;
type TPaquet=array[1..MAXCARTES] of TCarte;

type TStats=record //(version variable)
    indice:Integer; //représente l'indice de l'objets dans la liste d'objets
    force:Integer;
    multiplicateurDegat:Real;
    defense:Integer;
    vie:Integer;
    vieMax:Integer;
    transparence:Byte;
    xreel,yreel,angle:Real;
    etatPrec:TANimation; //dans le cas où l'objet est interrompu (par des dégâts par exemple) 
    inamovible:Boolean;
    leFou:Integer;
    tp:record
      restants,duree,destTempx,destTempy,destx,desty:Integer;
      end;
    case genre:typeObjet of 
        joueur:(mana:Integer;
          manaMax:Integer;
          lastUpdateTimeMana:UInt32;
          avancement:Integer;
          multiplicateurMana:Real;
          multiplicateurSoin:Real;
          Vitesse:Integer;
          manaDebutCombat:Integer;
          collection:TPaquet;
          deck:^TDeck;
          tailleCollection:Integer;
          bestiaire:array[1..MAXENNEMIS] of Boolean;
          pendu,clone:Boolean;
          compteurLeMonde:Integer;
          laMort,ophiucus:Boolean;
          nbJustice : Integer;
          nbMarchand: Integer;
          relique:Integer);// numéro de la relique équipée
        
        ennemi:(
          xcible,ycible, //position de la cible du déplacement ou des attaques de l'ennemi (souvent celle du joueur)
          compteurAction, //sert à temporiser les actions des ennemis
          nbFrames1,
          nbFrames2,
          nbFrames3,
          nbFramesMort, //nombre de frames : 1->poursuite/sans action, 2->action n°1, 3->action n°2
          nbFramesApparition:Integer;
          typeIA_MVT:Byte; //détermine la façon dont l'ennemi se déplace et agit
          degatsContact:Integer; //permet d'infliger des dégâts au contact avec le joueur
          cooldown:Integer; //limite les dégâts au contact par le temps
          vitessePoursuite:Integer; //indique la vitesse où l'ennemi peut suivre le joueur
          nomAttaque:PCHar;//pour le sprite utilisé par le projectile ou rayon
          boss:Boolean;//détermine ce que l'on obtient à l'issue d'un combat avec l'ennemi
          numero:Integer); 

        projectile,laser,epee,explosion,explosion2:(degats:Integer;
        origine:typeObjet;
        vectX,vectY,vitRotation:Real;
        dureeVie,dureeVieInit,delai,delaiInit,targetX,targetY,vitDep:Integer;
        volVie:Boolean); //soigne le joueur si jamais l'attaque touche une cible

        effet:(fixeJoueur:Boolean);//si l'effet suit le joueur ou non
end;

var Cartes:Array[1..28] of TCarte; //preset pour les cartes

// Structure TCol pour la gestion des collisions
type  TCol = record
    isTrigger: Boolean;     // Si vrai, l'objet ne bloque pas
    estActif: Boolean;      // Si vrai, l'objet est actif pour les collisions
    dimensions: TSDL_Rect;  // Boîte de collision (dimensions w et h)
    offset: TSDL_Point;     // Décalage par rapport à la position de l'objet
    hasCollided:Boolean;    // pour l'affichage de la boîte de collisions
    collisionsFaites:array[0..TAILLE_VAGUE+4] of Boolean; //l'objet mémorise ceux avec qui il est déjà en collision 
    nom: PChar;             // Nom de l'objet (facultatif)
  end;

type
  TObjet = record
    image: TImage;          // Image associée à l'objet
    anim: TAnimation;       // Animation associée à l'objet
    stats:TStats;           // Caractéristiques de l'objet
    col:TCol;               // Boîte de collisions de l'objet
  end;

type
  TDecorParallax = record
    images: array of TImage;       // Images des plans actuels
    offsets: array of TSDL_Point;  // Offsets initiaux pour chaque plan
    scales: array of Real;         // Échelles initiales pour chaque plan
    oscillation: Real;             // Phase d’oscillation pour l’effet de marche
    currentPlan: Integer;          // Index du plan actuel
    plans: array of String;        // Liste des noms des décors à afficher
  end;




type
  TButtonGroup = record
    button: TButton;       // Bouton de base
    image: TImage;         // Image de fond animée (taille et alpha)
    hoverSoundPlayed: Boolean;  // Pour suivre le premier survol de la souris
    originalWidth, originalHeight: Integer; 
    case parametresSpeciaux:Integer of 
      1:(procCarte:procedure(carte:TCarte;var stats:TStats);carte:TCarte);
      2:(procSalle:procedure(evenement:evenements;numero:Integer);numero:Integer;);
      3:(procEch:procedure(carte1,carte2:TCarte;var stats:TStats));
      4:(procRel:procedure(rel:Integer;var stats:TStats);relique:Integer);
    end;

type TSalle=record
    evenement:evenements;
    image:TButtonGroup;
end;

type InfoBoiteDialogues=record
  dirPortrait:PChar;
  texte:String;
end;

type ListeObjets = Array of TObjet; 
var LObjets: ListeObjets; //Liste universelle des objets présents
murs:array[1..4] of TObjet;
combatFini,vagueFinie,leMonde:Boolean;
statsJoueur: TStats;
queueDialogues:array of InfoBoiteDialogues;
var modeDebug:Boolean;

QUITGAME : Boolean;

PDeck:TDeck; //deck pointé par les stats du joueur

Title : TText;
TexteTutosMenu : Array [1..10] of TText;
TexteTutos : Array [1..10] of TText;
ImagesMenu : Array [1..7] of TImage;
// Boutons
	button_help : TButtonGroup;
	button_home : TButtonGroup;
  salles: array[1..3] of TSalle;
	button_retour_menu : TButtonGroup;
  boutons:array[1..9] of TButtonGroup;

  var fond:TImage;
	dialogues : Array [1..4] of TDialogueBox;



//procedures
	btnProc : ButtonProcedure;
	quitter : ButtonProcedure;
	retour_menu : ButtonProcedure;
	Pjouer : ButtonProcedure;
	PCredits : ButtonProcedure;
  PopenSettings : ButtonProcedure;
  PgoSeekHelp : ButtonProcedure;
	PNouvellePartieIntro : ButtonProcedure;


//Procédures de gestion de LObjets

procedure AjoutObjet(var obj:TObjet);
procedure supprimeObjet(var obj:TObjet);

//Pour faciliter la gestion d'un objet
procedure analyseObjet(obj:TObjet);
function trouverCentreX(var obj:TObjet):Integer;
function trouverCentreY(var obj:TObjet):Integer;

procedure ajoutDialogue(portrait:PChar;texte:String);
procedure supprimeDialogue(i:Integer);
procedure InitDecor;overload;
procedure InitDecor(i:Integer);overload;
procedure InitDecorCartes;

implementation
procedure InitDecor;
begin
	sdl_freesurface(fond.imgSurface);
	sdl_destroytexture(fond.imgTexture);
  CreateRawImage(fond,88,-80,900,900,StringToPChar('Sprites/Game/floor/Floor'+ IntToStr(Random(5)) +'.bmp'));
end;
procedure InitDecor(i:Integer);
begin
	if fond.imgSurface<>nil then sdl_freesurface(fond.imgSurface);
	if fond.imgTexture<>nil then sdl_destroytexture(fond.imgTexture);
  CreateRawImage(fond,88,-80,900,900,StringToPChar('Sprites/Game/floor/Floor'+ intToSTR(i) +'.bmp'));
end;

procedure InitDecorCartes;
begin
    randomize;
	sdl_freesurface(fond.imgSurface);
	sdl_destroytexture(fond.imgTexture);
    CreateRawImage(fond,0,0,1080,720,StringToPChar('Sprites/Menu/fond_cartes.bmp'));
end;

procedure AjoutObjet(var obj:TObjet); //Ajoute directement un projectile/autre à LObjets
begin
    obj.stats.tp.restants :=-1;
    obj.stats.tp.duree    :=-1;
    obj.stats.tp.destTempx:=-1;
    obj.stats.tp.destTempy:=-1;
    obj.stats.tp.destx    :=-1;
    obj.stats.tp.desty    :=-1;
    obj.stats.indice:=High(LObjets)+1;
    setlength(LObjets,obj.stats.indice+1);
    if (obj.stats.indice<=High(LObjets)) then
      LObjets[obj.stats.indice]:=obj;
end;

procedure supprimeObjet(var obj:TObjet); //Retire un élément de LObjets

var i,taille:Integer;

begin
    taille:=High(LObjets)+1;
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

procedure ajoutDialogue(portrait:PChar;texte:String);
begin
  setlength(queueDialogues,high(queueDialogues)+2);
  queueDialogues[High(queueDialogues)].dirPortrait:=(portrait);
  queueDialogues[High(queueDialogues)].texte:=texte;
end;
procedure supprimeDialogue(i:Integer);
begin
  initDialogueBox(dialogues[i],dialogues[i].BackgroundImage.directory,queueDialogues[0].dirPortrait,dialogues[i].BackgroundImage.rect.x,dialogues[i].BackgroundImage.rect.y,dialogues[i].w,dialogues[i].BackgroundImage.rect.h,queueDialogues[0].texte,dialogues[i].letterDelay+1);
  for i:=0 to high(queueDialogues) do
    queueDialogues[i]:=queueDialogues[i+1];
  setlength(queueDialogues,high(queueDialogues));
end;

//pour déterminer la position du centre d'une boîte de collisions d'un objet
function trouverCentreX(var obj:TObjet):Integer;
begin
  trouverCentreX:=obj.image.rect.x+obj.col.offset.x+(obj.col.dimensions.w div 2);
end;

function trouverCentreY(var obj:TObjet):Integer;
begin
  trouverCentreY:=obj.image.rect.y+obj.col.offset.y+(obj.col.dimensions.h div 2);
end;
procedure analyseObjet(obj:TObjet); //donne toutes les caractéristiques d'un objet (procédure de debug)
begin
  //writeln(obj.stats.genre,' nommé ',obj.anim.objectName);
  //writeln(obj.image.directory);
end;
var i:Integer;



begin
   // Définir les couleurs de base
   yellowCol.r:=255;yellowCol.g:=255;yellowCol.b:=0;
  whiteCol.r := 255; whiteCol.g := 255; whiteCol.b := 255;
  bf_color.r :=5; bf_color.g :=12; bf_color.b :=156;
  b_color.r :=167; b_color.g :=230; b_color.b :=255;
  f_color.r :=58; f_color.g :=190; f_color.b :=249;
  navy_color.r :=53; navy_color.g :=114; navy_color.b :=239;
  red_color.r := 255; red_color.g := 0; red_color.b := 50;
  black_col.r:=0;black_col.g:=0;black_col.b:=0;
  bk_col.r:=0;bk_col.g:=0;bk_col.b:=0;


  statsJoueur.genre:=joueur;
  statsJoueur.vieMax:=100;
  statsJoueur.vie:=100;
  statsJoueur.mana:=0;
  statsJoueur.manaMax:=10;
  statsJoueur.force:=7;
  statsJoueur.multiplicateurDegat:=1;
  statsJoueur.multiplicateurMana:=1;
  statsJoueur.nbJustice:=0;

  for i:=1 to 28 do begin
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
      23:cartes[i].nom:='lion';
      24:cartes[i].nom:='serpentaire';
      25:cartes[i].nom:='general celeste';
      26:cartes[i].nom:='fulgurant';
      27:cartes[i].nom:='ultima';
      28:cartes[i].nom:='meteore';
      end;
    case i of
      1,2,3,4,5,10:cartes[i].rarete:=commune;
      6,7,8,9,11,16,19:cartes[i].rarete:=rare;
      12,14,17,18,20,22,24:cartes[i].rarete:=epique;
      13,15,21,23,25,26,27,28:cartes[i].rarete:=legendaire;

      end;
    case i of
      1,6:cartes[i].cout:=1;
      10,13,18,23,24:cartes[i].cout:=0;
      2,5,16,17,22:cartes[i].cout:=2;
      3,4,12,14,19:cartes[i].cout:=3;
      11,20:cartes[i].cout:=4;
      8,9,15,21:cartes[i].cout:=5;
      7,25,26:cartes[i].cout:=6;
      27,28:cartes[i].cout:=10;
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
    23:cartes[i].dir:='Sprites/Cartes/carte23.bmp';
    24:cartes[i].dir:='Sprites/Cartes/carte24.bmp';
    25:cartes[i].dir:='Sprites/Cartes/carte25.bmp';
    26:cartes[i].dir:='Sprites/Cartes/carte26.bmp';
    27:cartes[i].dir:='Sprites/Cartes/carte27.bmp';
    28:cartes[i].dir:='Sprites/Cartes/carte28.bmp';
    end;
    case i of
      7,9,12,13,15,27,28:cartes[i].discard:=True
    else
      cartes[i].discard:=False;
    end;
    case i of
      24:cartes[i].chargesMax:=5;
    else
      cartes[i].chargesMax:=1;
      end;
    cartes[i].chargesMaxBase:=cartes[i].chargesMax;
    cartes[i].coutBase:=cartes[i].cout;
    cartes[i].inverse:=False;
    end;
    //writeln('CORE ready');
end.