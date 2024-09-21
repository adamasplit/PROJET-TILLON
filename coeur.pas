unit coeur;

interface
uses SDL2,memgraph,SysUtils,math;




const MAXSALLES=40; //nombre de salles total pour finir le jeu
  MAXENNEMIS=1; //nombre d'ennemis ayant une entrée dans le bestiaire
  MAXCARTES=40; //taille max du deck

var whiteCol,b_color,bf_color,f_color,navy_color,black_color,red_color: TSDL_Color;


type evenements=(combat,marchand,hasard,camp,rien,boss);
type typeObjet=(joueur,ennemi,projectile,autre);

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
    nom:String;
    cout:Integer; //Coût en mana
    rarete:(commune,rare,epique,legendaire);
    numero:integer;
    description:String; //Description dans le menu
    image:TImage;
end;

type TStats=record
    genre:typeObjet;
    case typeObjet of 

        joueur,ennemi: (force:Integer;
        defense:Integer;
        vie:Integer;
        vieMax:Integer);

        joueur:(mana:Integer;
        manaMax:Integer;
        multiplicateurMana:Real;
        multiplicateurDegat:Real;
        multiplicateurVitesse:Real;
        manaDebutCombat:Integer;
        TDeck:array[1..MAXCARTES] of TCarte;
        bestiaire:array[1..MAXENNEMIS] of Boolean);

        projectile:(degats:Integer);
end;

// Structure TCol pour la gestion des collisions
  TCol = record
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

type TSalle=record
    evenement:evenements;
end;

LObjets: Array of TObjet;


        
implementation
begin
 whiteCol.r := 255; whiteCol.g := 255; whiteCol.b := 255;
  bf_color.r :=5; bf_color.g :=12; bf_color.b :=156;
  b_color.r :=167; b_color.g :=230; b_color.b :=255;
  f_color.r :=58; f_color.g :=190; f_color.b :=249;
  navy_color.r :=53; navy_color.g :=114; navy_color.b :=239;
  black_color.r := 0; black_color.g := 0; black_color.b := 0;
  red_color.r := 255; red_color.g := 0; red_color.b := 50;

end.