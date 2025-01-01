unit MenuSys;


interface

uses
	AnimationSys,
	math,
	coeur,
	CombatLib,
	EnemyLib,
	eventSys,
	fichierSys,
	mapSys,
	memgraph,
	SDL2,
	SDL2_ttf,
	SonoSys,
	sysutils;

//Image
	var menuBook,bgImage,characterImage,cardsImage : TImage;
	menuBookAnim : TAnimation;
	DecorCredits : TDecorParallax;

var iEnn,ideckprec:Integer;carteDeck,ennAff:TImage;
	changementDecor : Boolean;
var
  creditsText: TImage;

procedure AfficherTout();
procedure victoire(var statsJ:TStats;boss:Boolean;num:Integer);
procedure victoire(var statsJ:TStats;num:Integer);overload;
procedure RenderParallaxMenu(bgImage,characterImage,cardsImage : TImage);
procedure InitCredits;
procedure ParallaxMenuInit;
procedure annihiler();
procedure InitMenuEnJeu;
procedure InitMenuPrincipal;
procedure InitTutorial;
procedure jouer;
procedure direction_menu;
procedure openSettings;
procedure goSeekHelp;
procedure Credits;
procedure NouvellePartieIntro;
procedure menuEnJeu;
procedure retourMenu;
function NextOrSkipDialogue(i : Integer) : Boolean;
procedure actualiserDeck();
procedure actualiserBestiaire();
procedure scrollBestiaire();
procedure InitJoueur(continuer:Boolean);

implementation

procedure InitJoueur(continuer:Boolean);
var j : Integer;
begin
    // Initialisation du joueur
	
    LObjets[0].col.isTrigger := False;
    LObjets[0].col.estActif := True;
    LObjets[0].col.dimensions.w := 50;
    LObjets[0].col.dimensions.h := 85;
    LObjets[0].col.offset.x := 25;
    LObjets[0].col.offset.y := 15;
    LObjets[0].col.nom := 'Joueur';
	LObjets[0].stats.angle:=0;
    LObjets[0].anim.estActif := True;
    LObjets[0].image.rect.x := windowWidth div 2;
    LObjets[0].image.rect.y := windowHeight div 2;
	LObjets[0].stats.lastUpdateTimeMana:=SDL_GetTicks;
	statsJoueur.tailleCollection:=4;
	statsJoueur.Vitesse:=5;
	statsJoueur.multiplicateurMana:=1;
	statsJoueur.force:=1;
	statsJoueur.defense:=1;
	statsJoueur.multiplicateurDegat:=1;
	statsJoueur.avancement:=1;
	for j:=1 to MAXENNEMIS do
		statsJoueur.bestiaire[j]:=False;
	for j:=1 to 4 do 
		statsJoueur.collection[j]:=Cartes[1];
	statsJoueur.collection[j]:=Cartes[4];
	statsJoueur.relique:=0;
	statsJoueur.nbMarchand := 0;
	statsJoueur.nbJustice:=0;
	statsJoueur.vie:=100;statsJoueur.vieMax:=100;
	statsJoueur.mana:=0;statsJoueur.manaMax:=10;
	statsJoueur.manaDebutCombat:=0;
	statsJoueur.multiplicateurSoin:=1;
	initStatsCombat(statsJoueur,LObjets[0].stats);
	iCarteChoisie:=1;
	CreateRawImage(LObjets[0].image, windowWidth div 2-windowWidth div 4, windowHeight div 2, 100, 100, 'Sprites/Game/Joueur/Joueur_idle_1.bmp');
	CreateRawImage(menuBook,0,0,windowWidth,windowHeight,'Sprites/Game/Book/Book_Opening_1.bmp');
	initAnimation(LObjets[0].anim,'Joueur','idle',12,True);
	if continuer then
		chargerSauvegarde(statsJoueur);
end;

procedure InitDecorParallax(var decor: TDecorParallax; NomDecor: String; totalDecors: Integer);
var
  i: Integer;
  profondeur: Real;
  width, height: Integer;
begin
  profondeur := 1.1; // Coefficient de profondeur

  SetLength(decor.images, totalDecors);
  SetLength(decor.offsets, totalDecors);
  SetLength(decor.scales, totalDecors);

  for i := 0 to totalDecors - 1 do
  begin
    // Calcul de l'échelle initiale en fonction de la profondeur
    decor.scales[i] := 1 / profondeur;

    // Dimensions calculées à partir de l'échelle
    width := Round(windowWidth * profondeur);
    height := Round(windowHeight * profondeur);
    // Création de l'image
    CreateRawImage(decor.images[i], 0, 0, width, height,StringToPChar('Sprites/Menu/DecorsCredits/' + NomDecor + '-' + IntToStr(totalDecors - i) + '.bmp'));

    // Centrage initial des images
    decor.images[i].rect.x := (windowWidth- width);  // Centrer horizontalement
    decor.images[i].rect.y := (windowHeight - height); // Centrer verticalement

    // Définition des offsets
    decor.offsets[i].x := decor.images[i].rect.x;
    decor.offsets[i].y := decor.images[i].rect.y;
    // Ajuster la profondeur pour les plans suivants
    profondeur := profondeur * 1.2;
  end;

  decor.oscillation := 0; // Réinitialisation de l'oscillation
end;




function NextOrSkipDialogue(i : Integer) : Boolean;
begin
	NextOrSkipDialogue:=False;
	//if dialogues[i].letterdelay<>0 then begin writeln(dialogues[i].letterdelay); end;
  	  while (SDL_PollEvent( EventSystem ) = 1) do
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[i].letterdelay=0 then NextOrSkipDialogue:=True else dialogues[i].LetterDelay:=0;
				end;
	//if NextOrSkipDialogue then writeln('next');
end;

procedure menuEnJeu;
	begin
		if (SceneActive = 'MenuEnJeu') or (SceneActive='Deck') or (SceneActive='Bestiaire') then sceneActive:=scenePrec
		else
		begin
			scenePrec:=sceneActive;
			SceneActive := 'MenuEnJeu';

			boutons[8].button.estVisible :=True;
			boutons[9].button.estVisible := True;
			jouerSon('SFX/Pausemenu_appear.wav');
			DrawRect(black_color,50, 0, 0, windowWidth,windowHeight);
			InitAnimation(menuBookAnim,'Book','Opening',5,False);

		end;
end;

procedure openSettings;
begin
	case VOLUME_SON of
	0:VOLUME_SON:=VOLUME_SON_MAX;
	else 
	VOLUME_SON:=VOLUME_SON-10;
	end;
	sdl_settexturecolormod(boutons[5].image.imgTexture,round(255*(VOLUME_SON/VOLUME_SON_MAX)),round(255*(VOLUME_SON/VOLUME_SON_MAX)),round(255*(VOLUME_SON/VOLUME_SON_MAX)));
	sdl_settexturealphamod(boutons[5].image.imgTexture,round(125+130*(VOLUME_SON/VOLUME_SON_MAX)))
end;

procedure settings2;
begin
	case VOLUME_MUSIQUE of
	0:VOLUME_MUSIQUE:=VOLUME_MUSIQUE_MAX;
	else VOLUME_MUSIQUE:=VOLUME_MUSIQUE-10;
	end;
	sdl_settexturecolormod(button_help.image.imgTexture,round(255*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)),round(255*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)),round(255*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)));
	sdl_settexturealphamod(button_help.image.imgTexture,round(125+130*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)))
end;

procedure goSeekHelp;
begin
  
end;
procedure jouer;
	begin
		SceneActive := 'Jeu';
		ClearScreen;
		SDL_RenderClear(sdlRenderer);
		if not (scenePrec='Jeu') then
			DeclencherFondu(False, 1000);

		//Objets dissimulés
		boutons[3].button.estVisible := false;
        boutons[2].button.estVisible := false;
		boutons[4].button.estVisible := false;
		boutons[1].button.estVisible := false;
		button_retour_menu.button.estVisible :=false;
		
		boutons[8].button.estVisible := False;
		boutons[9].button.estVisible := False;

        //Objets de Scene
		//ActualiserJeu;
end;

procedure InitCreditsText;
begin
  CreateRawImage(creditsText, windowWidth div 2 - 540*windowWidth div 1080, windowHeight, windowWidth, 4800*windowHeight div 720,'Sprites/Menu/Credits.bmp');
end;
procedure UpdateCameraParallax(var decor: TDecorParallax; avance: Boolean);

var
  i,taillePlan: Integer;
  newWidth, newHeight: Integer;
  offsetY: Integer;
begin
  // Effet de marche
  if avance then
  begin
    decor.oscillation := decor.oscillation + 0.1; // Phase de l'oscillation
    if decor.oscillation > 2 * Pi then
      decor.oscillation := decor.oscillation - 2 * Pi;
  end;

  for i := 0 to High(decor.images) do
  begin
    if avance then
    begin

		if creditsText.rect.y >= -4025*windowHeight div 720 then
			creditsText.rect.y := Round(creditsText.rect.y - 0.55);
		
      newWidth := Round(decor.images[i].rect.w + (1+decor.scales[i]/100));
      newHeight := Round(decor.images[i].rect.h + (1+decor.scales[i]/100));

      // Recentrage des positions après zoom
      decor.images[i].rect.x := decor.offsets[i].x - (newWidth - decor.images[i].rect.w) div 2;
      decor.images[i].rect.y := decor.offsets[i].y - (newHeight - decor.images[i].rect.h) div 2;

      // Applique les nouvelles dimensions
      decor.images[i].rect.w := newWidth;
    	decor.images[i].rect.h := newHeight;
	  //writeln('Plan ', i, ' Scale: ', decor.scales[i]:0:4, ' NewWidth: ', newWidth, ' NewHeight: ', newHeight);
    end
	else decor.oscillation:=0;

    // Oscillation verticale pour l’effet de marche
    offsetY := Round(Sin(decor.oscillation) * 10); // Amplitude fixée à 10
    decor.images[i].rect.y := decor.images[i].rect.y + offsetY;

    // Affiche l’image
    RenderRawImage(decor.images[i], False);
	sdl_delay(7);
  end;

  // Vérifie si un changement de décor est requis
  //writeln('decor.images[0].rect.w ', decor.images[0].rect.w, ' fonduActif: ', fonduActif);
  if fonduActif = False and changementDecor then
  begin
    decor.currentPlan := (decor.currentPlan + 1) mod Length(decor.plans); // Décor suivant
	case decor.currentPlan of
	0:taillePlan :=5;
	1:taillePlan :=6;
	2:taillePlan :=7;
	3:taillePlan :=4
	end;
    InitDecorParallax(decor, decor.plans[decor.currentPlan], taillePlan);
    DeclencherFondu(False, 2000); // Déclenche le fondu d’entrée
	changementDecor:=False;
  end;

  if (decor.images[0].rect.w > 1460) and fonduActif = False then
  begin
    DeclencherFondu(True, 1000); // Déclenche le fondu de sortie
	changementDecor := True;
  end;
  effetDeFondu;
  RenderRawImage(creditsText,False);
end;




procedure Credits;
	begin
		SceneActive := 'Credits';
		
		indiceMusiqueJouee:=48;
		
		boutons[3].button.estVisible := false;
		boutons[4].button.estVisible := false;
        boutons[2].button.estVisible := false;
		boutons[1].button.estVisible := false;
		
		UpdateCameraParallax(DecorCredits,sdlKeyboardState[SDL_SCANCODE_W] = 1);
		
		OnMouseHover(button_retour_menu,GetMouseX,GetMouseY);
		RenderButtonGroup(button_retour_menu);
end;

procedure ParallaxMenuInit;
begin
  CreateRawImage(bgImage,0 , 0,windowWidth+30 ,windowHeight+30 ,'Sprites/Menu/parallax_bg.bmp');
  CreateRawImage(characterImage,0 , 8,windowWidth+30 ,windowHeight+30 ,'Sprites/Menu/parallax_player.bmp');
  CreateRawImage(cardsImage,0 , 0,windowWidth ,windowHeight ,'Sprites/Menu/parallax_cards.bmp');
end;

procedure NouvellePartieIntro;
var i:Integer;
begin
	indiceMusiqueJouee:=14;
	ClearScreen;
	SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
	//black_color.r := 255; black_color.g := 255; black_color.b := 255;
	
	InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp',nil,0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('PRISON_CELLULE_0'),10);
	sceneActive:='Event';
	for i:=1 to 19 do
		case i of
		5,7,9,11,14:ajoutDialogue('Sprites/Portraits/portraitGarde1.bmp',extractionTexte('PRISON_CELLULE_'+intToStr(i)))
		else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('PRISON_CELLULE_'+intToStr(i)));
		end;
	sceneSuiv:='Intro';
	initjoueur(false);
end;



procedure direction_menu;
begin
    SceneActive := 'Menu';
	indiceMusiqueJouee:=0;
	sdl_settexturecolormod(button_help.image.imgTexture,round(255*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)),round(255*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)),round(255*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)));
	sdl_settexturecolormod(boutons[5].image.imgTexture,round(255*(VOLUME_SON/VOLUME_SON_MAX)),round(255*(VOLUME_SON/VOLUME_SON_MAX)),round(255*(VOLUME_SON/VOLUME_SON_MAX)));
	sdl_settexturealphamod(button_help.image.imgTexture,round(125+130*(VOLUME_MUSIQUE/VOLUME_MUSIQUE_MAX)));
	sdl_settexturealphamod(boutons[5].image.imgTexture,round(125+130*(VOLUME_SON/VOLUME_SON_MAX)));
    // Activer les boutons du menu principal
    boutons[2].button.estVisible := true;
    boutons[1].button.estVisible := true;
    boutons[3].button.estVisible := true;
    boutons[4].button.estVisible := true;
    boutons[5].button.estVisible := true;
    button_help.button.estVisible := true;
    button_home.button.estVisible := true;
    
    // Rendre l'image de fond
    RenderParallaxMenu(bgImage,characterImage,cardsImage);

    // Rendre les boutons principaux
    OnMouseHover(boutons[2], GetMouseX, GetMouseY);
    OnMouseHover(boutons[1], GetMouseX, GetMouseY);
    OnMouseHover(boutons[3], GetMouseX, GetMouseY);
    OnMouseHover(boutons[4], GetMouseX, GetMouseY);

    RenderButtonGroup(boutons[2]);
    RenderButtonGroup(boutons[1]);
    RenderButtonGroup(boutons[3]);
    RenderButtonGroup(boutons[4]);

    // Rendre les icônes en bas
    OnMouseHover(boutons[5], GetMouseX, GetMouseY);
    OnMouseHover(button_help, GetMouseX, GetMouseY);
    OnMouseHover(button_home, GetMouseX, GetMouseY);

    RenderButtonGroup(boutons[5]);
    RenderButtonGroup(button_help);
    RenderButtonGroup(button_home);
	

    // Afficher le texte et autres éléments si nécessaire
    RenderText(Title);
end;

procedure annihiler();
begin
  // Nettoyage de Ram (DETRUIRE IMPERATIVEMENT TOUTES LES TEXTURES UTILISEES SOUS PEINE DE FUITE DE RAM !!!!)
  TTF_CloseFont(Fantasy30);
  TTF_Quit;
  
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  // Shutting down video subsystem (A laisser imperativement)
  SDL_Quit;
  QUITGAME:= True;
end;

procedure continuer();
begin
	initJoueur(true);
	choixSalle;
end;

procedure retourMenu;
begin
	SDL_DestroyTexture(boutons[1].image.imgTexture);
	SDL_freeSurface(boutons[1].image.imgSurface);
	SDL_DestroyTexture(boutons[2].image.imgTexture);	
	SDL_freeSurface(boutons[2].image.imgSurface);
	SDL_DestroyTexture(boutons[3].image.imgTexture);	
	SDL_freeSurface(boutons[3].image.imgSurface);
	SDL_DestroyTexture(boutons[4].image.imgTexture);	
	SDL_freeSurface(boutons[4].image.imgSurface);
	InitMenuPrincipal;
	direction_menu;
end;

procedure InitMenuPrincipal;
var PopenSettings2:ButtonProcedure;
begin
    // Créer des boutons
    btnProc := @OnButtonClickDebug;
    quitter:=@annihiler;
    Pjouer:=@jouer;
    PCredits:=@Credits;
    retour_menu:=@retourMenu;
    PopenSettings := @openSettings;
	PopenSettings2:=@settings2;
    PgoSeekHelp := @goSeekHelp;
	PNouvellePartieIntro := @NouvellePartieIntro;
    
	//Menu Principal
    // Game icon (𓈒⟡₊⋆∘ Wowie 𓈒⟡₊⋆∘)
    CreateText(Title, windowWidth div 2-150, 20, 300, 250, 'Les Cartes du Destin',Fantasy30, whiteCol);
	// Initialisation des boutons principaux (à gauche)
	InitButtonGroup(boutons[2], 100*windowWidth div 1080, windowHeight div 5, 350*windowWidth div 1080, 80*windowHeight div 720, 'Sprites/Menu/Button1.bmp', 'Continuer', @continuer);
    InitButtonGroup(boutons[1], 100*windowWidth div 1080, (windowHeight div 5) + 100*windowHeight div 720, 350*windowWidth div 1080, 80*windowHeight div 720, 'Sprites/Menu/Button1.bmp', 'Nouvelle Partie', PNouvellePartieIntro);
    InitButtonGroup(boutons[3], 100*windowWidth div 1080, (windowHeight div 5) + 200*windowHeight div 720, 350*windowWidth div 1080, 80*windowHeight div 720, 'Sprites/Menu/Button1.bmp', 'Credits', PCredits);
    InitButtonGroup(boutons[4], 100*windowWidth div 1080, (windowHeight div 5) + 300*windowHeight div 720, 350*windowWidth div 1080, 80*windowHeight div 720, 'Sprites/Menu/Button1.bmp', 'Quitter', quitter);

	// Initialisation des icônes en bas
	InitButtonGroup(boutons[5], windowWidth div 2 - 300*windowWidth div 1080, windowHeight - 100*windowHeight div 720, 100*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Icon_Sound.bmp', ' ', PopenSettings);
	InitButtonGroup(button_help, windowWidth div 2, windowHeight - 100*windowHeight div 720, 100, 100*windowHeight div 720, 'Sprites/Menu/Icon_Music.bmp', ' ', PopenSettings2);
	InitButtonGroup(button_home, windowWidth div 2 + 300*windowWidth div 1080, windowHeight - 100*windowHeight div 720, 100*windowWidth div 1080, 100*windowHeight div 720, 'Sprites/Menu/Icon_Help.bmp', ' ', btnProc);

    ParallaxMenuInit;
    
end;

procedure reactualiserDeck();
begin
	//writeln(ideck);
	
	if iDeck=statsJoueur.tailleCollection+2 then
		begin
		createRawImage(carteDeck,200*windowWidth div 1080,200*windowHeight div 720,300*windowWidth div 1080,300*windowHeight div 720,StringToPChar('Sprites/Reliques/reliques'+intToStr(statsJoueur.relique)+'.bmp'));
		initDialogueBox(dialogues[4],nil,nil,460*windowWidth div 1080,120*windowHeight div 720,500*windowWidth div 1080,600*windowHeight div 720,extractionTexte('DESC_REL_'+intToStr(statsJoueur.relique)),10,Fantasy20,25);
		initDialogueBox(dialogues[3],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',000,450*windowHeight div 720,windowWidth,350*windowHeight div 720,extractionTexte('COMM_REL_'+intToStr(statsJoueur.relique)),10);
		end
	else if iDeck<>statsJoueur.tailleCollection+1 then
		begin
		createRawImage(carteDeck,200*windowWidth div 1080,200*windowHeight div 720,300*windowWidth div 1080,300*windowHeight div 720,statsJoueur.collection[iDeck].dir);
		initDialogueBox(dialogues[4],nil,nil,460*windowWidth div 1080,120*windowHeight div 720,500*windowWidth div 1080,600*windowHeight div 720,extractionTexte('DESC_CAR_'+intToStr(statsJoueur.collection[iDeck].numero)),10,Fantasy20,25);
		initDialogueBox(dialogues[3],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',000,450*windowHeight div 720,windowWidth,350*windowHeight div 720,extractionTexte('COMM_CAR_'+intToStr(statsJoueur.collection[iDeck].numero)),10);
		end;
end;

procedure ouvrirDeck();

begin
	//writeln('ouverture du deck');
	sceneActive:='Deck';
	iDeck:=1;
	iDeckPrec:=1;
	reactualiserDeck;
end;

procedure afficheStat(x,y:Integer;stat,statBase:Real;nom:String);
var texte:TText;string1,string2:String;
begin

	if abs(round(stat)-stat)<0.01 then
		begin
		string1:=intToStr(round(stat));
		end
	else
		begin
		string1:=intToSTR(math.ceil(stat)-1)+'.'+(inttoStr(math.ceil(10*stat-10*(math.ceil(stat-1)))));
		end;
	if abs(round(statBase)-statBase)<0.01 then
		begin
		string2:=intToStr(round(statBase));
		end
	else
		begin
		string2:=intToSTR(math.ceil(statBase)-1)+'.'+(inttoStr(math.ceil(10*statBase-10*(math.ceil(statBase-1)))));
		end;
	if (scenePrec='Jeu') and (stat<>statBase) then
		createText(texte,x,y,500*windowWidth div 1080,600*windowHeight div 720,stringtoPchar(nom+' : '+string1+' (base : '+string2+')'),Fantasy20,black_col)
	else
		createText(texte,x,y,500*windowWidth div 1080,600*windowHeight div 720,stringtoPchar(nom+' : '+string2),Fantasy20,black_col);
	renderText(texte);
	sdl_destroytexture(texte.textTexture);
	sdl_freeSurface(texte.textSurface);
end;

procedure actualiserDeck();
var textePV,texteMana:TText;
begin
	if (iDeck<>iDeckPrec) then 
		begin
		if (ideckprec<>statsJoueur.tailleCollection+1) then 
			begin
			sdl_destroytexture(carteDeck.imgTexture);
			sdl_freeSurface(carteDeck.imgSurface);
			end;
		reactualiserDeck;
		iDeckPrec:=iDeck;
		end;
	
	if iDeck=statsJoueur.tailleCollection+2 then
		renderRawImage(carteDeck,False)
	else
	if iDeck=statsJoueur.tailleCollection+1 then
		begin
		createText(textePV,170*windowWidth div 1080,260,500*windowWidth div 1080,600,stringtoPchar('PV : '+intToStr(LObjets[0].stats.vie)+'/'+intToStr(LObjets[0].stats.vieMax)),Fantasy20,black_col);
		renderText(textePV);
		sdl_destroytexture(textePV.textTexture);
		sdl_freeSurface(textePV.textSurface);
		if sceneActive<>'Jeu' then
			createText(texteMana,600*windowWidth div 1080,260,500*windowWidth div 1080,600*windowHeight div 720,stringtoPchar('MANA : '+intToStr(statsJoueur.manaMax)),Fantasy20,black_col)
		else
			createText(texteMana,600*windowWidth div 1080,260,500*windowWidth div 1080,600*windowHeight div 720,stringtoPchar('MANA : '+intToStr(LObjets[0].stats.mana)+'/'+intToStr(LObjets[0].stats.manaMax)),Fantasy20,black_col);
		renderText(texteMana);
		sdl_destroytexture(texteMana.textTexture);
		sdl_freeSurface(texteMana.textSurface);
		afficheStat(600*windowWidth div 1080,360*windowHeight div 720,LObjets[0].stats.force,statsJoueur.force,'Force');
		afficheStat(600*windowWidth div 1080,410*windowHeight div 720,LObjets[0].stats.defense,statsJoueur.defense,'Defense');
		afficheStat(600*windowWidth div 1080,460*windowHeight div 720,LObjets[0].stats.vitesse,statsJoueur.vitesse,'Vitesse');
		afficheStat(170*windowWidth div 1080,310*windowHeight div 720,statsJoueur.tailleCollection,statsJoueur.tailleCollection,'Nombre de cartes');
		afficheStat(170*windowWidth div 1080,360*windowHeight div 720,LObjets[0].stats.multiplicateurDegat,statsJoueur.multiplicateurDegat,'Puissance');
		afficheStat(170*windowWidth div 1080,410*windowHeight div 720,LObjets[0].stats.multiplicateurMana,statsJoueur.multiplicateurMana,'Recup mana');
		afficheStat(170*windowWidth div 1080,460*windowHeight div 720,LObjets[0].stats.multiplicateurSoin,statsJoueur.multiplicateurSoin,'Pouvoir de soin');
		end
	else
		afficherCarte(statsJoueur.collection[iDeck],255,carteDeck);
	if iDeck<>statsJoueur.tailleCollection+1 then 
	begin
		UpdateDialogueBox(dialogues[4]);
		UpdateDialogueBox(dialogues[3]);
	end;
end;



procedure reactualiserBestiaire();
begin
	createRawImage(ennAff,200*windowWidth div 1080,200*windowHeight div 720,300*windowWidth div 1080,300*windowHeight div 720,StringToPChar('Sprites/Bestiaire/illustrations_bestiaire_'+intToStr(ienn)+'.bmp'));
	initDialogueBox(dialogues[4],nil,nil,460*windowWidth div 1080,120*windowHeight div 720,500*windowWidth div 1080,600*windowHeight div 720,extractionTexte('DESC_ENN_'+intToStr(ienn)),10,Fantasy20,25);
	initDialogueBox(dialogues[3],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',000,450*windowHeight div 720,windowWidth,350*windowHeight div 720,extractionTexte('COMM_ENN_'+intToStr(ienn)),10);
end;
procedure trouverBestiaire(var i:Integer;avance:Boolean);
var compte:Integer;
begin
	compte:=0;
	if avance then
	repeat
			if i>=MAXENNEMIS then
				begin
				compte:=compte+1;
				i:=1;
				end
			else
				i:=i+1
		until (statsJoueur.bestiaire[i]) or (compte>1)
	else
	repeat
			if i<=1 then
				begin
				i:=MAXENNEMIS;
				compte:=compte+1;
				end
			else
				i:=i-1
		until (statsJoueur.bestiaire[i]) or (compte>1);
	if compte>1 then sceneActive:='MenuEnJeu';
end;
procedure ouvrirBestiaire();

begin
	//writeln('ouverture du deck');
	sceneActive:='Bestiaire';
	iEnn:=1;
	if not statsJoueur.bestiaire[1] then
		trouverBestiaire(iEnn,True);
	reactualiserBestiaire;
	
end;

procedure actualiserBestiaire();

begin
	UpdateDialogueBox(dialogues[4]);
	UpdateDialogueBox(dialogues[3]);
	renderRawImage(ennAff,False);
end;



procedure scrollBestiaire();

begin
	if EventSystem^.wheel.y<0 then
		trouverBestiaire(iEnn,true)
	else
		trouverBestiaire(iEnn,false);
	reactualiserBestiaire;
end;

procedure InitTutorial;
begin
	CreateText(TexteTutos[1], windowWidth div 2-250*windowWidth div 1080, windowHeight div 2 + 50*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'ZQSD pour se deplacer',Fantasy30, b_color);
	CreateText(TexteTutos[2], windowWidth div 2-250*windowWidth div 1080, windowHeight div 2 + 50*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Echap pour ouvrir le menu',Fantasy30, b_color);
	CreateText(TexteTutos[3], windowWidth div 2-250*windowWidth div 1080, windowHeight div 2 + 50*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Scroll pour choisir une carte',Fantasy30, b_color);
	CreateText(TexteTutos[4], windowWidth div 2-250*windowWidth div 1080, windowHeight div 2 + 50*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Clic gauche/droit pour utiliser une carte',Fantasy30, b_color);
end;
procedure InitTutorialMenu;
begin
	CreateText(TexteTutosMenu[1], windowWidth div 2-380*windowWidth div 1080, windowHeight div 3 - 120*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Scroll pour défiler les pages (deck ou bestiaire)',Fantasy30, b_color);
	CreateText(TexteTutosMenu[2], windowWidth div 2-400*windowWidth div 1080, windowHeight div 3 - 120*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Les pages se débloquent au fur et à mesure dans le jeu !',Fantasy30, b_color);
	CreateText(TexteTutosMenu[3], windowWidth div 2-450*windowWidth div 1080, windowHeight div 3 - 120*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Chaque rencontre ou carte obtenue est notée dans le livre.',Fantasy30, b_color);
	CreateText(TexteTutosMenu[4], windowWidth div 2-350*windowWidth div 1080, windowHeight div 3 - 120*windowHeight div 720, 300*windowWidth div 1080, 250*windowHeight div 720, 'Echap pour quitter le menu',Fantasy30, b_color);
end;

procedure InitMenuEnJeu;
begin
  //Menu en Jeu
	InitButtonGroup(boutons[8], 210*windowWidth div 1080, 320*windowHeight div 720, 240*windowWidth div 1080, 50*windowHeight div 720,nil,'Deck',@ouvrirDeck);
	InitButtonGroup(boutons[9], 210*windowWidth div 1080, 390*windowHeight div 720, 240*windowWidth div 1080, 50*windowHeight div 720,nil,'Bestiaire',@ouvrirBestiaire);
	InitTutorialMenu;
end;

procedure InitCredits;
begin
	InitButtonGroup(button_retour_menu, 850*windowWidth div 1080, 625*windowHeight div 720, 200*windowWidth div 1080, 75*windowHeight div 720,'Sprites/Menu/Button1.bmp','Menu',retour_menu);
	SetLength(DecorCredits.plans, 4);
  	DecorCredits.plans[0] := 'Plains';
  	DecorCredits.plans[1] := 'Forest';
	DecorCredits.plans[2] := 'Winter';
	DecorCredits.plans[3] := 'Flowers';
	InitCreditsText;
	InitDecorParallax(DecorCredits,DecorCredits.plans[0],5);
end;

procedure AfficherTout(); //affiche tout (en combat)
var i : Integer;
begin
	if sceneActive='Jeu' then scenePrec:='Jeu';
	if scenePrec='Jeu' then
		begin
		renderRawImage(fond,255,False);
		if LObjets[0].stats.pendu then
				if LObjets[0].anim.isFliped then
					SDL_RenderCopyEx(sdlRenderer, LObjets[0].image.imgTexture, nil, @LObjets[0].image.rect,0, nil, SDL_FLIP_VERTICAL)
				else
					SDL_RenderCopyEx(sdlRenderer, LObjets[0].image.imgTexture, nil, @LObjets[0].image.rect,0, nil, SDL_FLIP_VERTICAL)
			else
				RenderRawImage(LObjets[0].image,255, LObjets[0].anim.isFliped);

		for i:=1 to high(LObjets) do
			case LOBjets[i].stats.genre of
				TypeObjet(2),TypeObjet(3),TypeObjet(4),explosion2:RenderAvecAngle(LObjets[i]);
				explosion,afterimage:RenderRawImage(LObjets[i].image,LObjets[i].stats.transparence, LObjets[i].anim.isFliped);
				else
					RenderRawImage(LObjets[i].image,255, LObjets[i].anim.isFliped);
			end;
		UpdateUICombat(icarteChoisie,400,400,LObjets[0].stats);
		if leMonde then 
			begin
			drawrect(black_color,50,0,0,windowWidth,windowHeight);
			if LObjets[0].stats.pendu then
				if LObjets[0].anim.isFliped then
					SDL_RenderCopyEx(sdlRenderer, LObjets[0].image.imgTexture, nil, @LObjets[0].image.rect,0, nil, SDL_FLIP_VERTICAL)
				else
					SDL_RenderCopyEx(sdlRenderer, LObjets[0].image.imgTexture, nil, @LObjets[0].image.rect,0, nil, SDL_FLIP_VERTICAL)
				else
					RenderRawImage(LObjets[0].image,255, LObjets[0].anim.isFliped);
			end;
		EffetDeFondu;
		if sceneActive = 'mortJoueur' then 
			begin
			RenderRawImage(LObjets[0].image, LObjets[0].anim.isFliped);
			RenderRawImage(LObjets[High(Lobjets)].image, False);
			end;
		end
	else renderRawImage(fond,255,False);
	
end;


procedure finirCombat(stats:TStats);
var i:Integer;
begin
	if (stats.avancement-1) mod (MAXSALLES div 4) = 0 then
		case (stats.avancement div (MAXSALLES div 4)) of
		1:	begin
			sceneActive:='Event';
			InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300,extractionTexte('FIN_BOSS1_1'),10);
			sceneSuiv:='Map';
			for i:=2 to 8 do
			case i of
				2,3,4,6:ajoutDialogue(nil,extractionTexte('FIN_BOSS1_'+intToStr(i)))
				else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('FIN_BOSS1_'+intToStr(i)));
			end;
			end;
		2:	begin
			sceneActive:='Event';
			InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp',nil,0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('FIN_BOSS2_1'),10);
			sceneSuiv:='Map';
			for i:=2 to 10 do
			case i of
				3,5,6,7,8,9:ajoutDialogue(nil,extractionTexte('FIN_BOSS2_'+intToStr(i)))
				else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('FIN_BOSS2_'+intToStr(i)));
			end;
			end;
		3:	begin
			sceneActive:='Event';
			InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp',nil,0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('FIN_BOSS3_1'),10);
			sceneSuiv:='Map';
			for i:=2 to 5 do
			case i of
				2,3,4:ajoutDialogue(nil,extractionTexte('FIN_BOSS3_'+intToStr(i)))
				else ajoutDialogue('Sprites/Menu/CombatUI_5.bmp',extractionTexte('FIN_BOSS3_'+intToStr(i)));
			end;
			end;
		4:Credits;
		end
	else choixSalle;
end;


procedure acquisitionCarte(carte:TCarte;var stats:TStats);
begin
    stats.tailleCollection:=stats.tailleCollection+1;
    stats.collection[stats.tailleCollection]:=carte;
    finirCombat(stats)
end;

procedure equiperRelique(rel:Integer;var stats:TStats);
begin
	if stats.relique<>0 then desequiperRelique(stats);
	case rel of
	1:
	stats.vitesse:=stats.vitesse+3;
	2:
	stats.manaMax:=stats.manaMax+4;
	3:	
	begin 
	stats.vieMax:=stats.vieMax+30;
	stats.vie:=stats.vie+30;
	end;
	4:
	stats.multiplicateurSoin:=stats.multiplicateurSoin+0.5;
	5:
	begin
	stats.manaDebutCombat:=10;
	stats.multiplicateurMana:=stats.multiplicateurMana+0.3;
	end;
	6:stats.force:=stats.force+3;
	7:stats.defense:=stats.defense+5;
	8:begin
		stats.multiplicateurDegat:=stats.multiplicateurDegat+1;
		stats.vieMax:=stats.vieMax-20;
		end;
	11:InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Portraits/portrait_Leo6.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('VICTOIRE_-1'),10);
	end;
	

	stats.relique:=rel;
	if rel<>11 then finirCombat(stats);
end;

procedure victoire(var statsJ:TStats;boss:Boolean;num:Integer); //censé contenir le choix+obtention d'une carte après un combat
var i,nbReliques:Integer;
begin
	if indiceMusiqueJouee<14 then indiceMusiqueJouee:=indiceMusiqueJouee+18; //donne une fanfare de victoire adaptée
	StatsJ.vie:=LObjets[0].stats.vie;//synchronise la vie
	if (statsJ.avancement-1) mod (MAXSALLES div 4) = 0 then
		InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('VICTOIRE_'+intToSTR(10*(statsJ.avancement div (MAXSALLES div 4)))),10)
	else
		InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('VICTOIRE_'+intToSTR(random(4)+1+10*((statsJ.avancement-1) div (MAXSALLES div 4)))),10);
	InitDecorCartes;
	randomize;
	nbReliques:=0;
    sceneActive:='victoire';
    for i:=1 to 3 do
		if boss and (random(2)=0) and (nbReliques<2) then
			begin
			boutons[i].parametresSpeciaux:=4;
			case num of
			31,32:repeat boutons[i].relique:=random(7)+1 until (boutons[i].relique<>2) and (boutons[i].relique<>5); 
			33,34:boutons[i].relique:=random(5)*2+2;
			12:if nbReliques<1 then boutons[i].relique:=9 else boutons[i].relique:=random(10)+1;
			else begin
				if random(10)=1 then boutons[i].relique:=10
				else boutons[i].relique:=random(8)+1;
				end;
			end;
			InitButtonGroup(boutons[i],(200+300*(i-1))*windowWidth div 1080,200*windowHeight div 720,128*windowWidth div 1080,128*windowHeight div 720,StringToPChar('Sprites/Reliques/reliques'+intToStr(boutons[i].relique)+'.bmp'),' ',btnProc);
			boutons[i].procRel:=@equiperRelique; 
			nbReliques:=nbReliques+1; //pour empêcher d'avoir uniquement des reliques lors du choix
			end
		else
			begin
			boutons[i].parametresSpeciaux:=1;
			boutons[i].carte:=dropCarte(statsJ.avancement-1,boss); 
			InitButtonGroup(boutons[i],(200+300*(i-1))*windowWidth div 1080,200*windowHeight div 720,128*windowWidth div 1080,128*windowHeight div 720,boutons[i].carte.dir,' ',btnProc);
			boutons[i].procCarte:=@acquisitionCarte; 
			end;
end;

procedure victoire(var statsJ:TStats;num:Integer);overload;
var i:Integer;
begin
	if indiceMusiqueJouee<14 then indiceMusiqueJouee:=indiceMusiqueJouee+18;
	StatsJoueur.vie:=LObjets[0].stats.vie;
	InitDialogueBox(dialogues[1],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,windowHeight div 3 + 200*windowHeight div 720,windowWidth,300*windowHeight div 720,extractionTexte('VICTOIRE_0'),10);
	InitDecorCartes;
    sceneActive:='victoire';
    for i:=1 to 3 do
		if i<>2 then
        begin
	    boutons[i].carte:=cartes[num];
	    InitButtonGroup(boutons[i],(200+300*(i-1))*windowWidth div 1080,200*windowHeight div 720,128*windowWidth div 1080,128*windowHeight div 720,boutons[i].carte.dir,' ',nil);
        boutons[i].procCarte:=@acquisitionCarte;
        boutons[i].parametresSpeciaux:=1;
        end;
			boutons[2].parametresSpeciaux:=4;
			boutons[2].relique:=11;
			InitButtonGroup(boutons[2],(200+300*(2-1))*windowWidth div 1080,200*windowHeight div 720,128*windowWidth div 1080,128*windowHeight div 720,StringToPChar('Sprites/Reliques/reliques'+intToStr(boutons[2].relique)+'.bmp'),' ',btnProc);
			boutons[2].procRel:=@equiperRelique; 
end;

procedure RenderParallaxMenu(bgImage,characterImage,cardsImage : TImage);
var
  mouseX, mouseY: Integer;
  targetX_bg, targetY_bg, offsetX_bg, offsetY_bg: Integer;
  targetX_character, targetY_character, offsetX_character, offsetY_character: Integer;
  targetX_cards, targetY_cards, offsetX_cards, offsetY_cards: Integer;

const
  SmoothFactor = 0.3; // Facteur de smothiessage pour un resultat plus clean

begin
  // Obtenir la position de la souris
  mouseX := GetMouseX;
  mouseY := GetMouseY;

  // Calculer les cibles en fonction de la position de la souris et des facteurs de vitesse
  // Arrière-plan
  targetX_bg := -Round(mouseX * 0.05);
  targetY_bg := -Round(mouseY * 0.05);

  // Personnage
  targetX_character := -Round(mouseX * 0.1);
  targetY_character := -Round(mouseY * 0.1);

  // Carte 1
  targetX_cards := -Round(mouseX * 0.2);
  targetY_cards := -Round(mouseY * 0.2);

  // Appliquer l'effet de lissage en rapprochant la position actuelle de la cible progressivement
  // Arrière-plan
  offsetX_bg := Round(SmoothFactor * (targetX_bg - bgImage.rect.x));
  offsetY_bg := Round(SmoothFactor * (targetY_bg - bgImage.rect.y));
  bgImage.rect.x := bgImage.rect.x + offsetX_bg;
  bgImage.rect.y := bgImage.rect.y + offsetY_bg;

  // Personnage
  offsetX_character := Round(SmoothFactor * (targetX_character - characterImage.rect.x));
  offsetY_character := Round(SmoothFactor * (targetY_character - characterImage.rect.y));
  characterImage.rect.x := characterImage.rect.x + offsetX_character;
  characterImage.rect.y := characterImage.rect.y + offsetY_character;

  // Cartes
  offsetX_cards := Round(SmoothFactor * (targetX_cards - cardsImage.rect.x));
  offsetY_cards := Round(SmoothFactor * (targetY_cards - cardsImage.rect.y));
  cardsImage.rect.x := cardsImage.rect.x + offsetX_cards;
  cardsImage.rect.y := cardsImage.rect.y + offsetY_cards;

  // Rendre chaque élément avec sa position mise à jour
  RenderRawImage(bgImage, False);
  RenderRawImage(characterImage, False);
  RenderRawImage(cardsImage, False);
end;

begin
changementDecor := False;
end.