unit MenuSys;


interface

uses SDL2,coeur,eventsys,memgraph,animationSys,combatlib,mapsys,SDL2_ttf,sonoSys;

//Image
	var combat_bg,menuBook,bgImage,characterImage,cardsImage : TImage;
	menuBookAnim : TAnimation;

procedure AfficherTout();

procedure victoire(var statsJ:TStats);

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

implementation

function NextOrSkipDialogue(i : Integer) : Boolean;
begin
	NextOrSkipDialogue:=False;
  	  while (SDL_PollEvent( EventSystem ) = 1) do
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[i].letterdelay=0 then NextOrSkipDialogue:=True else dialogues[i].LetterDelay:=0;
	end;
end;

procedure menuEnJeu;
	begin
		if (SceneActive = 'MenuEnJeu') then jouer
		else
		begin
			SceneActive := 'MenuEnJeu';

			button_deck.estVisible :=True;
			button_bestiaire.estVisible := True;
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
		DeclencherFondu(False, 3000);

		//Objets dissimulés
		button_leaderboard.button.estVisible := false;
        button_continue.button.estVisible := false;
		button_quit.button.estVisible := false;
		button_new_game.button.estVisible := false;
		button_retour_menu.button.estVisible :=false;
		
		button_deck.estVisible := False;
		button_bestiaire.estVisible := False;

        //Objets de Scene
		//ActualiserJeu;
end;

procedure lead;
	begin

		SceneActive := 'Leaderboard';

		ClearScreen;
		SDL_RenderClear(sdlRenderer);

		
		
		button_leaderboard.button.estVisible := false;
		button_quit.button.estVisible := false;
        button_continue.button.estVisible := false;
		button_new_game.button.estVisible := false;

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
  CreateRawImage(bgImage,0 , 10,windowWidth ,windowHeight ,'Sprites\Menu\parallax_bg.bmp');
  CreateRawImage(characterImage,0 , 8,windowWidth ,windowHeight ,'Sprites\Menu\parallax_player.bmp');
  CreateRawImage(cardsImage,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\parallax_cards.bmp');
end;

procedure NouvellePartieIntro;
begin
	indiceMusiqueJouee:=11;
	ClearScreen;
	SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
	black_color.r := 255; black_color.g := 255; black_color.b := 255;
	repeat
	UpdateDialogueBox(dialogues[3]);
	SDL_RenderPresent(sdlRenderer);
	SDL_Delay(10);
	autoMusique;
	until NextOrSkipDialogue(3);

	ClearScreen;
  	SDL_Delay(300);  

	repeat
	UpdateDialogueBox(dialogues[4]);
	SDL_RenderPresent(sdlRenderer);
	autoMusique;
	until NextOrSkipDialogue(4);
	ClearScreen;

	repeat
	UpdateDialogueBox(dialogues[5]);
	SDL_RenderPresent(sdlRenderer);
	autoMusique;
	until NextOrSkipDialogue(5);
	ClearScreen;

	repeat
	UpdateDialogueBox(dialogues[6]);
	SDL_RenderPresent(sdlRenderer);
	autoMusique;
	until NextOrSkipDialogue(6);
	ClearScreen;

	repeat
	UpdateDialogueBox(dialogues[7]);
	SDL_RenderPresent(sdlRenderer);
	autoMusique;
	until NextOrSkipDialogue(7);
	ClearScreen;
	black_color.r := 0; black_color.g := 0; black_color.b := 0;
	jouer;
end;



procedure direction_menu;
begin
    SceneActive := 'Menu';

    // Activer les boutons du menu principal
    button_continue.button.estVisible := true;
    button_new_game.button.estVisible := true;
    button_leaderboard.button.estVisible := true;
    button_quit.button.estVisible := true;
    button_settings.button.estVisible := true;
    button_help.button.estVisible := true;
    button_home.button.estVisible := true;
    
    // Rendre l'image de fond
    RenderParallaxMenu(bgImage,characterImage,cardsImage);

    // Rendre les boutons principaux
    OnMouseHover(button_continue, GetMouseX, GetMouseY);
    OnMouseHover(button_new_game, GetMouseX, GetMouseY);
    OnMouseHover(button_leaderboard, GetMouseX, GetMouseY);
    OnMouseHover(button_quit, GetMouseX, GetMouseY);

    RenderButtonGroup(button_continue);
    RenderButtonGroup(button_new_game);
    RenderButtonGroup(button_leaderboard);
    RenderButtonGroup(button_quit);

    // Rendre les icônes en bas
    OnMouseHover(button_settings, GetMouseX, GetMouseY);
    OnMouseHover(button_help, GetMouseX, GetMouseY);
    OnMouseHover(button_home, GetMouseX, GetMouseY);

    RenderButtonGroup(button_settings);
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
	InitButtonGroup(button_continue, 100, windowHeight div 5, 350, 80, 'Sprites\Menu\Button1.bmp', 'Continuer', Pjouer);
    InitButtonGroup(button_new_game, 100, (windowHeight div 5) + 100, 350, 80, 'Sprites\Menu\Button1.bmp', 'Nouvelle Partie', PNouvellePartieIntro);
    InitButtonGroup(button_leaderboard, 100, (windowHeight div 5) + 200, 350, 80, 'Sprites\Menu\Button1.bmp', 'Leaderboard', leaderboard);
    InitButtonGroup(button_quit, 100, (windowHeight div 5) + 300, 350, 80, 'Sprites\Menu\Button1.bmp', 'Quitter', quitter);

	// Initialisation des icônes en bas
	InitButtonGroup(button_settings, windowWidth div 2 - 300, windowHeight - 100, 100, 100, 'Sprites\Menu\Icon_Settings.bmp', ' ', PopenSettings);
	InitButtonGroup(button_help, windowWidth div 2, windowHeight - 100, 100, 100, 'Sprites\Menu\Icon_Help.bmp', ' ', PgoSeekHelp);
	InitButtonGroup(button_home, windowWidth div 2 + 300, windowHeight - 100, 100, 100, 'Sprites\Menu\Icon_Help.bmp', ' ', btnProc);

    ParallaxMenuInit;
    
end;

procedure InitMenuEnJeu;
begin
  //Menu en Jeu
	CreateButton(button_deck, 210, 320, 240, 50,'Deck',b_color, bf_color,Fantasy30,btnProc);
	CreateButton(button_bestiaire, 210, 390, 240, 50,'Bestiaire',b_color, bf_color,Fantasy30,btnProc);
end;

procedure InitLeaderboard;
begin
    CreateText(titre_lead, windowWidth div 2-210, 90, 300, 250, 'Leaderboard',Fantasy40, navy_color);
	CreateText(text_score_seize, 40, 200, 150, 125, '1> Score  :',dayDream20, bf_color);
	CreateText(text_nom_seize, 40, 225, 250, 125, 'Nom partie :',dayDream20, bf_color);
	CreateText(text_score_trente, 40, 275, 150, 125, '2> Score :',dayDream20, bf_color);
	CreateText(text_nom_trente, 40, 300, 150, 125,'Nom partie :',dayDream20, bf_color);
	CreateText(text_n3, 40, 350, 150, 125, '3> Score :',dayDream20, bf_color);
	CreateText(text_s3, 40, 375, 150, 125, 'Nom partie :',dayDream20, bf_color);
	CreateText(text_n4, 40, 425, 150, 125, '4> Score :',dayDream20, bf_color);
	CreateText(text_s4, 40, 450, 150, 125, 'Nom partie :',dayDream20, bf_color);
	CreateText(text_n5, 40, 500, 150, 125, '5> Score :',dayDream20, bf_color);
	CreateText(text_s5, 40, 525, 150, 125, 'Arrive prochainement !',dayDream20, bf_color);
	InitButtonGroup(button_retour_menu, 850, 625, 200, 75,'Sprites\Menu\Button1.bmp','Menu',retour_menu);
end;

procedure AfficherTout(); //affiche tout (en combat)
var i : Integer;
begin
	renderRawImage(combat_bg,255,False);
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
	EffetDeFondu
	
end;

procedure acquisitionCarte(carte:TCarte;var stats:TStats);
begin
    writeln('tentative d''ajout d''une carte');
    stats.tailleCollection:=stats.tailleCollection+1;
    stats.collection[stats.tailleCollection]:=carte;
    choixSalle;
end;

procedure victoire(var statsJ:TStats); //censé contenir le choix+obtention d'une carte après un combat (voire d'une relique, pour plus tard)
var i:Integer;
begin
	indiceMusiqueJouee:=indiceMusiqueJouee+11;
    sceneActive:='victoire';
    for i:=1 to 3 do
        begin
	    btnCartes[i].carte:=cartes[i]; //###c'est cette partie qui est à remplacer pour déterminer les cartes que l'on peut obtenir
	    InitButtonGroup(btnCartes[i],200+300*(i-1),200,128,128,btnCartes[i].carte.dir,' ',nil);
        btnCartes[i].procCarte:=@acquisitionCarte;
        btnCartes[i].parametresSpeciaux:=1;
        end;
end;

procedure RenderParallaxMenu(bgImage,characterImage,cardsImage : TImage);
var
  mouseX, mouseY: Integer;
  targetX_bg, targetY_bg, offsetX_bg, offsetY_bg: Integer;
  targetX_character, targetY_character, offsetX_character, offsetY_character: Integer;
  targetX_cards, targetY_cards, offsetX_cards, offsetY_cards: Integer;

const
  SmoothFactor = 0.1; // Facteur de smothiessage pour un resultat plus clean

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