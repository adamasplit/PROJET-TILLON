unit MenuSys;


interface

uses
	animationSys,
	coeur,
	combatlib,
	enemyLib,
	eventsys,
	fichierSys,
	mapsys,
	memgraph,
	SDL2,
	SDL2_ttf,
	sonoSys,
	sysutils;

//Image
	var menuBook,bgImage,characterImage,cardsImage : TImage;
	menuBookAnim : TAnimation;

var iEnn,ideckprec:Integer;carteDeck,ennAff:TImage;

procedure AfficherTout();
procedure victoire(var statsJ:TStats;boss:Boolean);
procedure victoire(var statsJ:TStats;num:Integer);overload;
procedure RenderParallaxMenu(bgImage,characterImage,cardsImage : TImage);
procedure InitLeaderboard;
procedure ParallaxMenuInit;
procedure annihiler();
procedure InitMenuEnJeu;
procedure InitMenuPrincipal;
procedure jouer;
procedure direction_menu;
procedure openSettings;
procedure goSeekHelp;
procedure lead;
procedure NouvellePartieIntro;
procedure menuEnJeu;
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
	statsJoueur.multiplicateurDegat:=1;
	for j:=1 to 4 do 
		statsJoueur.collection[j]:=Cartes[1];
	statsJoueur.collection[j]:=Cartes[10];
	statsJoueur.relique:=0;
	statsJoueur.vie:=100;statsJoueur.vieMax:=100;
	statsJoueur.multiplicateurSoin:=1;
	initStatsCombat(statsJoueur,LObjets[0].stats);
	iCarteChoisie:=1;
	CreateRawImage(LObjets[0].image, windowWidth div 2-windowWidth div 4, windowHeight div 2, 100, 100, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
	CreateRawImage(menuBook,0,0,windowWidth,windowHeight,'Sprites\Game\Book\Book_Opening_1.bmp');
	initAnimation(LObjets[0].anim,'Joueur','idle',12,True);
	if continuer then
		chargerSauvegarde(statsJoueur)
		
end;

function NextOrSkipDialogue(i : Integer) : Boolean;
begin
	NextOrSkipDialogue:=False;
	if dialogues[i].letterdelay<>0 then begin writeln(dialogues[i].letterdelay); end;
  	  while (SDL_PollEvent( EventSystem ) = 1) do
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[i].letterdelay=0 then NextOrSkipDialogue:=True else dialogues[i].LetterDelay:=0;
				end;
	if NextOrSkipDialogue then writeln('next');
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
			jouerSon('SFX\Pausemenu_appear.wav');
			DrawRect(black_color,50, 0, 0, windowWidth,windowHeight);
			InitAnimation(menuBookAnim,'Book','Opening',5,False);

		end;
end;

procedure openSettings;
begin
  
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

procedure lead;
	begin

		SceneActive := 'Leaderboard';

		ClearScreen;
		SDL_RenderClear(sdlRenderer);

		
		
		boutons[3].button.estVisible := false;
		boutons[4].button.estVisible := false;
        boutons[2].button.estVisible := false;
		boutons[1].button.estVisible := false;

		RenderParallaxMenu(bgImage,characterImage,cardsImage);
		//RenderRawImage(vague);
		RenderText(text1);
		RenderText(titre_lead);
		RenderText(text_score_seize);
		RenderText(text_score_trente);
		RenderText(text_nom_seize);
		RenderText(text_nom_trente);
		RenderText(text_n3);
		RenderText(text_s3);
		RenderText(text_n4);
		RenderText(text_s4);
		RenderText(text_n5);
		RenderText(text_s5);


		OnMouseHover(button_retour_menu,GetMouseX,GetMouseY);
		RenderButtonGroup(button_retour_menu);
		SDL_RenderPresent(sdlRenderer);
end;

procedure ParallaxMenuInit;
begin
  CreateRawImage(bgImage,0 , 0,windowWidth+30 ,windowHeight+30 ,'Sprites\Menu\parallax_bg.bmp');
  CreateRawImage(characterImage,0 , 8,windowWidth+30 ,windowHeight+30 ,'Sprites\Menu\parallax_player.bmp');
  CreateRawImage(cardsImage,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\parallax_cards.bmp');
end;

procedure NouvellePartieIntro;
begin
	indiceMusiqueJouee:=14;
	ClearScreen;
	SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
	black_color.r := 255; black_color.g := 255; black_color.b := 255;
	
	InitDialogueBox(dialogues[1],nil,nil,0,windowHeight div 3 - 100,windowWidth,400,extractionTexte('TXT_INTRO1'),10);
	sceneActive:='Event';
	sceneSuiv:='Intro';
	ajoutDialogue(nil,extractionTexte('TXT_INTRO2'));
	ajoutDialogue(nil,extractionTexte('TXT_INTRO3'));
	ajoutDialogue(nil,extractionTexte('TXT_INTRO4'));
	ajoutDialogue(nil,extractionTexte('TXT_INTRO5'));
	initjoueur(false);
end;



procedure direction_menu;
begin
    SceneActive := 'Menu';
	indiceMusiqueJouee:=1;

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
	EffetDeFondu;

    // Afficher le texte et autres éléments si nécessaire
    RenderText(text1);
    SDL_RenderPresent(sdlRenderer);
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
end;

procedure continuer();
begin
	initJoueur(true);
	choixSalle;
end;
procedure InitMenuPrincipal;
begin
    // Créer des boutons
    btnProc := @OnButtonClickDebug;
    quitter:=@annihiler;
    Pjouer:=@jouer;
    leaderboard:=@lead;
    retour_menu:=@direction_menu;
    PopenSettings := @openSettings;
    PgoSeekHelp := @goSeekHelp;
	PNouvellePartieIntro := @NouvellePartieIntro;
    
	//Menu Principal
    // Game icon (𓈒⟡₊⋆∘ Wowie 𓈒⟡₊⋆∘)
    CreateText(text1, windowWidth div 2-150, 20, 300, 250, 'Les Cartes du Destin',Fantasy30, whiteCol);
	// Initialisation des boutons principaux (à gauche)
	InitButtonGroup(boutons[2], 100, windowHeight div 5, 350, 80, 'Sprites\Menu\Button1.bmp', 'Continuer', @continuer);
    InitButtonGroup(boutons[1], 100, (windowHeight div 5) + 100, 350, 80, 'Sprites\Menu\Button1.bmp', 'Nouvelle Partie', PNouvellePartieIntro);
    InitButtonGroup(boutons[3], 100, (windowHeight div 5) + 200, 350, 80, 'Sprites\Menu\Button1.bmp', 'Leaderboard', leaderboard);
    InitButtonGroup(boutons[4], 100, (windowHeight div 5) + 300, 350, 80, 'Sprites\Menu\Button1.bmp', 'Quitter', quitter);

	// Initialisation des icônes en bas
	InitButtonGroup(boutons[5], windowWidth div 2 - 300, windowHeight - 100, 100, 100, 'Sprites\Menu\Icon_Settings.bmp', ' ', PopenSettings);
	InitButtonGroup(button_help, windowWidth div 2, windowHeight - 100, 100, 100, 'Sprites\Menu\Icon_Help.bmp', ' ', PgoSeekHelp);
	InitButtonGroup(button_home, windowWidth div 2 + 300, windowHeight - 100, 100, 100, 'Sprites\Menu\Icon_Help.bmp', ' ', btnProc);

    ParallaxMenuInit;
    
end;

procedure reactualiserDeck();
begin
	//writeln(ideck);
	
	if iDeck=statsJoueur.tailleCollection+1 then
		begin
		createRawImage(carteDeck,200,200,300,300,StringToPChar('Sprites/Reliques/reliques'+intToStr(statsJoueur.relique)+'.bmp'));
		initDialogueBox(dialogues[1],nil,nil,460,120,380,600,extractionTexte('DESC_REL_'+intToStr(statsJoueur.relique)),10,Fantasy20,25);
		initDialogueBox(dialogues[3],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',000,450,1080,350,extractionTexte('COMM_REL_'+intToStr(statsJoueur.relique)),0);
		end
	else
		begin
		createRawImage(carteDeck,200,200,300,300,statsJoueur.collection[iDeck].dir);
		initDialogueBox(dialogues[1],nil,nil,460,120,380,600,extractionTexte('DESC_CAR_'+intToStr(statsJoueur.collection[iDeck].numero)),0,Fantasy20,25);
		initDialogueBox(dialogues[3],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',000,450,1080,350,extractionTexte('COMM_CAR_'+intToStr(statsJoueur.collection[iDeck].numero)),0);
		end;
end;

procedure ouvrirDeck();

begin
	writeln('ouverture du deck');
	sceneActive:='Deck';
	iDeck:=1;
	iDeckPrec:=1;
	reactualiserDeck;
end;

procedure actualiserDeck();

begin
	if iDeck<>iDeckPrec then 
		begin
		sdl_destroytexture(carteDeck.imgTexture);
		sdl_freeSurface(carteDeck.imgSurface);
		reactualiserDeck;
		iDeckPrec:=iDeck;
		end;
	
	renderRawImage(carteDeck,False);
	UpdateDialogueBox(dialogues[1]);
	UpdateDialogueBox(dialogues[3]);
end;



procedure reactualiserBestiaire();
begin
	createRawImage(ennAff,200,200,300,300,StringToPChar('Sprites/Bestiaire/illustrations_bestiaire_'+intToStr(ienn)+'.bmp'));
	initDialogueBox(dialogues[1],nil,nil,460,120,380,600,extractionTexte('DESC_ENN_'+intToStr(ienn)),0,Fantasy20,25);
	initDialogueBox(dialogues[3],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',000,450,1080,350,extractionTexte('COMM_ENN_'+intToStr(ienn)),0);
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
	writeln('ouverture du deck');
	sceneActive:='Bestiaire';
	iEnn:=1;
	if not statsJoueur.bestiaire[1] then
		trouverBestiaire(iEnn,True);
	reactualiserBestiaire;
	
end;

procedure actualiserBestiaire();

begin
	UpdateDialogueBox(dialogues[1]);
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

procedure InitMenuEnJeu;
begin
  //Menu en Jeu
	InitButtonGroup(boutons[8], 210, 320, 240, 50,nil,'Deck',@ouvrirDeck);
	InitButtonGroup(boutons[9], 210, 390, 240, 50,nil,'Bestiaire',@ouvrirBestiaire);
end;

procedure InitLeaderboard;
begin
    CreateText(titre_lead, windowWidth div 2-210, 90, 300, 250, 'Leaderboard',Fantasy40, navy_color);
	CreateText(text_score_seize, 40, 200, 150, 125, '1> Score  :',Fantasy20, bf_color);
	CreateText(text_nom_seize, 40, 225, 250, 125, 'Nom partie :',Fantasy20, bf_color);
	CreateText(text_score_trente, 40, 275, 150, 125, '2> Score :',Fantasy20, bf_color);
	CreateText(text_nom_trente, 40, 300, 150, 125,'Nom partie :',Fantasy20, bf_color);
	CreateText(text_n3, 40, 350, 150, 125, '3> Score :',Fantasy20, bf_color);
	CreateText(text_s3, 40, 375, 150, 125, 'Nom partie :',Fantasy20, bf_color);
	CreateText(text_n4, 40, 425, 150, 125, '4> Score :',Fantasy20, bf_color);
	CreateText(text_s4, 40, 450, 150, 125, 'Nom partie :',Fantasy20, bf_color);
	CreateText(text_n5, 40, 500, 150, 125, '5> Score :',Fantasy20, bf_color);
	CreateText(text_s5, 40, 525, 150, 125, 'Arrive prochainement !',Fantasy20, bf_color);
	InitButtonGroup(button_retour_menu, 850, 625, 200, 75,'Sprites\Menu\Button1.bmp','Menu',retour_menu);
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
				TypeObjet(2),TypeObjet(3),TypeObjet(4):RenderAvecAngle(LObjets[i])
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
		end;
	
end;

procedure acquisitionCarte(carte:TCarte;var stats:TStats);
begin
    stats.tailleCollection:=stats.tailleCollection+1;
    stats.collection[stats.tailleCollection]:=carte;
    choixSalle;
end;

procedure desequiperRelique(var stats:TStats);
begin
	case stats.relique of
	1:
	stats.vitesse:=stats.vitesse-5;
	2:
	stats.manaMax:=stats.manaMax-4;
	3:	
	begin 
	stats.vieMax:=stats.vieMax-20;
	end;
	4:
	stats.multiplicateurSoin:=stats.multiplicateurSoin-0.3;
	5:
	stats.manaDebutCombat:=0;
	6:stats.force:=stats.force-5;
	7:stats.defense:=stats.defense-4;
	end;
end;

procedure equiperRelique(rel:Integer;var stats:TStats);
begin
	if stats.relique<>0 then desequiperRelique(stats);
	case rel of
	1:
	stats.vitesse:=stats.vitesse+5;
	2:
	stats.manaMax:=stats.manaMax+4;
	3:	
	begin 
	stats.vieMax:=stats.vieMax+20;
	stats.vie:=stats.vie+20;
	end;
	4:
	stats.multiplicateurSoin:=stats.multiplicateurSoin+0.3;
	5:
	stats.manaDebutCombat:=10;
	6:stats.force:=stats.force+5;
	7:stats.defense:=stats.defense+4;
	end;

	stats.relique:=rel;
	choixSalle;
end;

procedure victoire(var statsJ:TStats;boss:Boolean); //censé contenir le choix+obtention d'une carte après un combat
var i:Integer;
begin
	if indiceMusiqueJouee<14 then indiceMusiqueJouee:=indiceMusiqueJouee+18;
	StatsJoueur.vie:=LObjets[0].stats.vie;
	InitDecorCartes;
    sceneActive:='victoire';
    for i:=1 to 3 do
		if boss and (random(2)=0) then
			begin
			boutons[i].parametresSpeciaux:=4;
			boutons[i].relique:=random(7)+1; //###c'est cette partie qui est à remplacer pour déterminer les cartes que l'on peut obtenir
			InitButtonGroup(boutons[i],200+300*(i-1),200,128,128,StringToPChar('Sprites/Reliques/reliques'+intToStr(boutons[i].relique)+'.bmp'),' ',btnProc);
			boutons[i].procRel:=@equiperRelique; 
			end
		else
			begin
			boutons[i].parametresSpeciaux:=1;
			boutons[i].carte:=cartes[random(22)+1]; //###c'est cette partie qui est à remplacer pour déterminer les cartes que l'on peut obtenir
			InitButtonGroup(boutons[i],200+300*(i-1),200,128,128,boutons[i].carte.dir,' ',btnProc);
			boutons[i].procCarte:=@acquisitionCarte; 
			end;
end;

procedure victoire(var statsJ:TStats;num:Integer);overload;
var i:Integer;
begin
	if indiceMusiqueJouee<14 then indiceMusiqueJouee:=indiceMusiqueJouee+18;
	StatsJoueur.vie:=LObjets[0].stats.vie;
	InitDecorCartes;
    sceneActive:='victoire';
    for i:=1 to 3 do
        begin
	    boutons[i].carte:=cartes[num];
	    InitButtonGroup(boutons[i],200+300*(i-1),200,128,128,boutons[i].carte.dir,' ',nil);
        boutons[i].procCarte:=@acquisitionCarte;
        boutons[i].parametresSpeciaux:=1;
        end;
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
end.