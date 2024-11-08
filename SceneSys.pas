unit Scenesys;

interface
uses
    AnimationSys,
    coeur,
    CollisionSys,
    combatLib,
    enemyLib,
    eventsys,
    fichierSys,
    MapSys,
    memgraph,
    SDL2,
    SDL2_mixer,
    SDL2_ttf,
    sonoSys,
    SysUtils;

// Bouttons
var button_new_game: TButtonGroup;
	button_continue : TButtonGroup;
	button_leaderboard : TButtonGroup;
	button_quit : TButtonGroup;
	button_settings : TButtonGroup;
	button_help : TButtonGroup;
	button_home : TButtonGroup;

	button_retour_menu : TButtonGroup;
	button_deck : TButton;
	button_bestiaire: TButton;

// Textes
var	text1 : TText;
	titre_lead : TText;
	text_score_seize : TText;
	text_score_trente : TText;
	text_nom_seize : TText;
	text_nom_trente : TText;
	text_s3: TText;
	text_n3 : TText;
	text_s4 : TText;
	text_n4: TText;
	text_s5: TText;
	text_n5: TText;

	box,box2 : TDialogueBox;

//Image
	var combat_bg,menuBook,bgImage,characterImage,cardsImage : TImage;
	menuBookAnim : TAnimation;

//GameObjects

var Joueur : TObjet;

//procedures
	btnProc : ButtonProcedure;
	quitter : ButtonProcedure;
	retour_menu : ButtonProcedure;
	Pjouer : ButtonProcedure;
	leaderboard : ButtonProcedure;
    PopenSettings : ButtonProcedure;
    PgoSeekHelp : ButtonProcedure;

//Variables de Debug
	var LastUpdateTime2:UInt32;

procedure StartGame;

implementation

procedure UpdateAnimations();
var i:Integer;
begin
for i:=0 to High(LObjets) do 
		if (i<=High(LObjets)) then
			begin
			//writeln('objet actuel : ',Lobjets[i].stats.genre,' ',lobjets[i].anim.objectName);
			LObjets[i].stats.indice:=i;
			if LObjets[i].anim.estActif then 
				begin
				if (LObjets[i].anim.etat='degats') then
					begin
					LObjets[i].anim.isFliped:=LObjets[i].stats.etatPrec.isFliped;
					if animFinie(LObjets[i].anim) then
						LObjets[i].anim:=LObjets[i].stats.etatPrec;
					end;
				if (LObjets[i].stats.genre<>laser) and (LObjets[i].stats.genre<>epee) and ((not leMonde) or (LObjets[i].stats.genre=TypeObjet(0)) or (LObjets[i].anim.objectName='monde')) then
					begin
					UpdateAnimation(LObjets[i].anim, LObjets[i].image);
					if (LObjets[i].stats.genre=effet) and (animFinie(LObjets[i].anim)) then
						supprimeObjet(LObjets[i]);
					end
				end
			end;
for i:=2 to High(LObjets) do
      if (i<=High(LObjets)) then
	  	begin
			case LObjets[i].stats.genre of 
        	projectile:begin
        		if i<>LObjets[i].stats.indice then writeln('conflit à l"indice',i);
				LObjets[i].stats.indice:=i;
        		updateBoule(LObjets[i]);
        		end;
			laser:updateRayon(LObjets[i]);
			epee:UpdateJustice(LObjets[i]);
			effet:if (LObjets[i].stats.fixeJoueur) and (not (leMonde) or (LObjets[i].anim.objectName='monde')) then 
				begin
				LObjets[i].image.rect.x:=LObjets[0].image.rect.x+50-(LObjets[i].image.rect.w div 2);
				LObjets[i].image.rect.y:=LObjets[0].image.rect.y+50-(LObjets[i].image.rect.h div 2);
				end;
			end;
		end
end;

procedure AfficherTout();
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
	
	
end;

// Updates des Scenes

procedure ActualiserJeu;
var i:Integer;
	begin
		randomize();
		SDL_RenderClear(sdlRenderer);
		SDL_PumpEvents;
		sdl_delay(10);
		afficherTout;
		//UpdateDialogueBox(box);
		UpdateCollisions();
		UpdateAnimations();
		if LObjets[0].stats.vie>LObjets[0].stats.vieMax then LObjets[0].stats.vie:=LObjets[0].stats.vieMax;
		if LObjets[0].stats.vie<0 then LObjets[0].stats.vie:=0;
		if leMonde and (sdl_getTicks-UpdateTimeMonde>LObjets[0].stats.compteurLeMonde*1000) then
			begin
			leMonde:=False;
			mix_resumeMusic();
			end;
		if LObjets[0].stats.laMort and (sdl_getTicks-updateTimeMort>5000) then
			LObjets[0].stats.laMort:=False;
		RegenMana(LastUpdateTime2,LObjets[0].stats.mana,LObjets[0].stats.manaMax,LObjets[0].stats.multiplicateurMana);
		for i:=1 to High(LObjets) do
			if (i<=High(LObjets)) and not leMonde then
			begin
				if LObjets[i].stats.genre=TypeObjet(1) then
					begin
					IAEnnemi(LObjets[i],LObjets[0]);
					end;
			end;
		SDL_RenderPresent(sdlRenderer);
		if vagueFinie then ajoutVague;
		if combatFini then choixSalle;
	end;

procedure ActualiserMenuEnJeu;
	begin
		SDL_RenderClear(sdlrenderer);
		affichertout();
		UpdateAnimation(menuBookAnim,menuBook);
		RenderRawImage(menuBook,False);
		if animFinie(menuBookAnim) then
			begin
			RenderButton(button_deck);
			RenderButton(button_bestiaire);
			end;
		

		SDL_RenderPresent(sdlRenderer);
	end;

    //Scenes

procedure openSettings;
begin
  
end;

procedure goSeekHelp;
begin
  
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
procedure jouer;
	begin
		SceneActive := 'Jeu';
		ClearScreen;
		SDL_RenderClear(sdlRenderer);

		//Objets dissimulés
		button_leaderboard.button.estVisible := false;
        button_continue.button.estVisible := false;
		button_quit.button.estVisible := false;
		button_new_game.button.estVisible := false;
		button_retour_menu.button.estVisible :=false;
		
		button_deck.estVisible := False;
		button_bestiaire.estVisible := False;
		InitDialogueBox(box2,'Sprites\Menu\Button1.bmp','Sprites\Menu\portraitB.bmp',000,000,windowWidth,400,extractionTexte('DIALOGUE_BOSS_1'),100);

        //Objets de Scene
		ActualiserJeu;
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

    // Afficher le texte et autres éléments si nécessaire
    RenderText(text1);
    SDL_RenderPresent(sdlRenderer);
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

//Initialisations

procedure InitJoueur;
var j : Integer;
begin
    // Initialisation du joueur
    joueur.col.isTrigger := False;
    joueur.col.estActif := True;
    joueur.col.dimensions.w := 50;
    joueur.col.dimensions.h := 85;
    joueur.col.offset.x := 25;
    joueur.col.offset.y := 15;
    joueur.col.nom := 'Joueur';
    Joueur.anim.estActif := True;
    LObjets[0] := Joueur;
    LObjets[0].image.rect.x := windowWidth div 2;
    LObjets[0].image.rect.y := windowHeight div 2;
    statsJoueur.tailleCollection:=22;
    statsJoueur.Vitesse:=5;
    statsJoueur.multiplicateurMana:=1;
    statsJoueur.multiplicateurDegat:=1;
    for j:=1 to 22 do 
        statsJoueur.collection[j]:=Cartes[j];
    statsJoueur.vie:=100;statsJoueur.vieMax:=100;
    initStatsCombat(statsJoueur,LObjets[0].stats);
    iCarteChoisie:=8;
    CreateRawImage(LObjets[0].image, windowWidth div 2, windowHeight div 2, 100, 100, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
    CreateRawImage(menuBook,0,0,windowWidth,windowHeight,'Sprites\Game\Book\Book_Opening_1.bmp');
end;

procedure InitDecor;
begin
    randomize;
    CreateRawImage(combat_bg,88,-80,900,900,StringToPChar('Sprites/Game/floor/Floor'+ IntToStr(Random(4)+1) +'.bmp'));
end;

procedure ParallaxMenuInit;
begin
  CreateRawImage(bgImage,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\parallax_bg.bmp');
  CreateRawImage(characterImage,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\parallax_player.bmp');
  CreateRawImage(cardsImage,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\parallax_cards.bmp');
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
    
	//Menu Principal
    // Game icon (𓈒⟡₊⋆∘ Wowie 𓈒⟡₊⋆∘)
    CreateText(text1, windowWidth div 2-150, 20, 300, 250, 'Les Cartes du Destin',Fantasy30, black_color);
	// Initialisation des boutons principaux (à gauche)
	InitButtonGroup(button_continue, 100, windowHeight div 5, 350, 80, 'Sprites\Menu\Button1.bmp', 'Continuer', Pjouer);
    InitButtonGroup(button_new_game, 100, (windowHeight div 5) + 100, 350, 80, 'Sprites\Menu\Button1.bmp', 'Nouvelle Partie', Pjouer);
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



procedure GameUpdate;
begin
  new(EventSystem);
   while True do
  begin
  autoMusique();
    //Mouvement Joueur
  if SceneActive='Jeu' then 
  		begin
		ActualiserJeu;
		MouvementJoueur(LObjets[0]);
		end;
  if SceneActive='MenuEnJeu' then 
  		begin
		ActualiserMenuEnJeu;
		end;
  if SceneActive='Menu' then 
  		begin
		direction_menu;
		end;
  if sceneActive='Cutscene' then
		begin
		sdl_renderclear(sdlrenderer);
		affichertout;
		UpdateDialogueBox(box2);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		updateanimation(LObjets[1].anim,LObjets[1].image);
		sdl_renderpresent(sdlrenderer);
		while (SDL_PollEvent( EventSystem ) = 1) do
    		begin
      			case EventSystem^.type_ of
					SDL_mousebuttondown:sceneActive:='Jeu';
				end
			end
		end;
    

    while SDL_PollEvent( EventSystem ) = 1 do
    begin
      case EventSystem^.type_ of
			SDL_KEYDOWN:
			//Touches de Debug
      		begin
        		case EventSystem^.key.keysym.sym of
          			SDLK_UP:  LObjets[0].stats.vie := LObjets[0].stats.vie +10;
					SDLK_DOWN: LObjets[0].stats.vie := LObjets[0].stats.vie-10;
					SDLK_ESCAPE : menuEnJeu;
					SDLK_SPACE:begin
						leMonde:=not(leMonde);
						LObjets[0].stats.compteurLeMonde:=100;
						updateTimeMonde:=sdl_getTicks;
						end;
					SDLK_O:LOBjets[0].stats.multiplicateurMana:=10;
					SDLK_H : choixSalle();
					SDLK_F3:modeDebug:=not(modeDebug);
        		end;
      		end;
			
			SDL_mousemotion: 
				begin
				getMouseX;getMouseY;
				end;
			SDL_mousebuttondown : 
				begin 
				if sceneActive='Jeu' then jouerCarte(LObjets[0].stats,LObjets[0].image.rect.x+(LObjets[0].image.rect.w div 2),LObjets[0].image.rect.y+(LObjets[0].image.rect.h div 2),iCarteChoisie);
   				if button_continue.button.estVisible then
				begin
				OnMouseClick(button_continue,EventSystem^.motion.x,EventSystem^.motion.y);
				HandleButtonClick(button_continue.button,EventSystem^.motion.x,EventSystem^.motion.y);
				end;
                if button_new_game.button.estVisible then
				begin
				OnMouseClick(button_new_game,EventSystem^.motion.x,EventSystem^.motion.y);
				HandleButtonClick(button_new_game.button,EventSystem^.motion.x,EventSystem^.motion.y);
				end;
				if button_leaderboard.button.estVisible then
				begin
				OnMouseClick(button_leaderboard,EventSystem^.motion.x,EventSystem^.motion.y);
				HandleButtonClick(button_leaderboard.button,EventSystem^.motion.x,EventSystem^.motion.y);
				//continue;
				end;
				if button_quit.button.estVisible then
				begin
				OnMouseClick(button_quit,EventSystem^.motion.x,EventSystem^.motion.y);
				HandleButtonClick(button_quit.button,EventSystem^.motion.x,EventSystem^.motion.y);
				//continue;
				end;
				if button_retour_menu.button.estVisible then
				begin
				OnMouseClick(button_retour_menu,EventSystem^.motion.x,EventSystem^.motion.y);
				HandleButtonClick(button_retour_menu.button,EventSystem^.motion.x,EventSystem^.motion.y);
				//continue;
				end;
				if button_deck.estVisible then
				begin
				HandleButtonClick(button_deck,EventSystem^.motion.x,EventSystem^.motion.y);
				//continue;
				end;
				if button_bestiaire.estVisible then
				begin
				HandleButtonClick(button_bestiaire,EventSystem^.motion.x,EventSystem^.motion.y);
				end;
				end;
			SDL_MOUSEWHEEL:begin
  				if EventSystem^.wheel.y < 0 then icarteChoisie:=(isuiv(iCarteChoisie))
  				else icarteChoisie:=(iprec(iCarteChoisie));
				end;
				
				end;
			end;
  end;
end;

procedure StartGame;
begin
    IndiceMusiqueJouee:=1;
    Mix_VolumeMusic(VOLUME_MUSIQUE);
    SceneActive := 'Menu';
	sdlKeyboardState := SDL_GetKeyboardState(nil);
    lastUpdateTime2:=SDL_GetTicks;
    InitMenuPrincipal;
    InitMenuEnJeu;
    InitLeaderboard;
    GameUpdate;
end;

begin
  WriteLn('SceneSys ready !');
end.

