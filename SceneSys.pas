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
	menuSys,
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

	dialogues : Array [1..100] of TDialogueBox;



//procedures
	btnProc : ButtonProcedure;
	quitter : ButtonProcedure;
	retour_menu : ButtonProcedure;
	Pjouer : ButtonProcedure;
	leaderboard : ButtonProcedure;
    PopenSettings : ButtonProcedure;
    PgoSeekHelp : ButtonProcedure;
	PNouvellePartieIntro : ButtonProcedure;

//GameObjects
	var Joueur : TObjet;

procedure StartGame;

implementation

procedure UpdateAnimations();
var i:Integer;
begin
	for i:=0 to High(LObjets) do 
		if (i<=High(LObjets)) then
			begin
			//ajuste l'indice de l'objet à sa position dans LObjets
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
end;



procedure InitDecor;
begin
    randomize;
    CreateRawImage(combat_bg,88,-80,900,900,StringToPChar('Sprites/Game/floor/Floor'+ IntToStr(Random(4)+1) +'.bmp'));
end;

procedure InitDialogues;
begin
  	InitDialogueBox(dialogues[2],'Sprites\Menu\Button1.bmp','Sprites\Menu\portraitB.bmp',0,-100,windowWidth,400,extractionTexte('DIALOGUE_BOSS_1'),100);
	InitDialogueBox(dialogues[1],'Sprites\Menu\Button1.bmp','Sprites\Menu\portraitB.bmp',0,-100,windowWidth,400,extractionTexte('DIALOGUE_BOSS_2'),100);
	InitDialogueBox(dialogues[3],nil,nil,-50,windowHeight div 3 - 100,windowWidth,400,extractionTexte('TXT_INTRO1'),100);
	InitDialogueBox(dialogues[4],nil,nil,-50,windowHeight div 3 - 100 ,windowWidth,400,extractionTexte('TXT_INTRO2'),100);
	InitDialogueBox(dialogues[5],nil,nil,-50,windowHeight div 3 - 100 ,windowWidth,400,extractionTexte('TXT_INTRO3'),100);
	InitDialogueBox(dialogues[6],nil,nil,-50,windowHeight div 3 - 100 ,windowWidth,400,extractionTexte('TXT_INTRO4'),100);
	InitDialogueBox(dialogues[7],nil,nil,-50,windowHeight div 3 - 100 ,windowWidth,400,extractionTexte('TXT_INTRO5'),100);
end;

// Updates des Scenes

procedure ActualiserJeu;
var i:Integer;
	begin
		randomize();
		//writeln('actualiserJeu, taille de LObjets:',high(lobjets));
		SDL_RenderClear(sdlRenderer);
		SDL_PumpEvents;
		sdl_delay(10);
		afficherTout;
		//UpdateDialogueBox(box);
		UpdateCollisions();
		UpdateAnimations();
		UpdateAttaques();
		if LObjets[0].stats.vie>LObjets[0].stats.vieMax then LObjets[0].stats.vie:=LObjets[0].stats.vieMax;
		if LObjets[0].stats.vie<0 then LObjets[0].stats.vie:=0;
		if leMonde and (sdl_getTicks-UpdateTimeMonde>LObjets[0].stats.compteurLeMonde*1000) then
			begin
			leMonde:=False;
			mix_resumeMusic();
			end;
		if LObjets[0].stats.laMort and (sdl_getTicks-updateTimeMort>5000) then
			LObjets[0].stats.laMort:=False;
		RegenMana(LObjets[0].stats.lastUpdateTimeMana,LObjets[0].stats.mana,LObjets[0].stats.manaMax,LObjets[0].stats.multiplicateurMana);
		for i:=1 to High(LObjets) do
			if (i<=High(LObjets)) and not leMonde then
			begin
				if LObjets[i].stats.genre=TypeObjet(1) then
					begin
					vagueFinie:=False;
					IAEnnemi(LObjets[i],LObjets[0]);
					end;
			end;
		SDL_RenderPresent(sdlRenderer);
		if vagueFinie then ajoutVague;
		if combatFini then victoire(statsJoueur);
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

function NextOrSkipDialogue(i : Integer) : Boolean;
begin
	NextOrSkipDialogue:=False;
  	  while (SDL_PollEvent( EventSystem ) = 1) do
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[i].letterdelay=0 then NextOrSkipDialogue:=True else dialogues[i].LetterDelay:=0;
	end;
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
	joueur.stats.angle:=0;
    Joueur.anim.estActif := True;
    LObjets[0] := Joueur;
    LObjets[0].image.rect.x := windowWidth div 2;
    LObjets[0].image.rect.y := windowHeight div 2;
	LObjets[0].stats.lastUpdateTimeMana:=SDL_GetTicks;
    statsJoueur.tailleCollection:=22;
    statsJoueur.Vitesse:=5;
    statsJoueur.multiplicateurMana:=1;
    statsJoueur.multiplicateurDegat:=1;
    for j:=1 to 22 do 
        statsJoueur.collection[j]:=Cartes[j];
    statsJoueur.vie:=100;statsJoueur.vieMax:=100;
    initStatsCombat(statsJoueur,LObjets[0].stats);
    iCarteChoisie:=1;
    CreateRawImage(LObjets[0].image, windowWidth div 2-windowWidth div 4, windowHeight div 2, 100, 100, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
    CreateRawImage(menuBook,0,0,windowWidth,windowHeight,'Sprites\Game\Book\Book_Opening_1.bmp');
end;



procedure ParallaxMenuInit;
begin
  CreateRawImage(bgImage,0 , 10,windowWidth ,windowHeight ,'Sprites\Menu\parallax_bg.bmp');
  CreateRawImage(characterImage,0 , 8,windowWidth ,windowHeight ,'Sprites\Menu\parallax_player.bmp');
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



procedure GameUpdate;
begin
  new(EventSystem);
   while True do
  begin
  autoMusique();
    //Mouvement Joueur
	case SceneActive of
  		'Jeu': 
  		begin
		ActualiserJeu;
		MouvementJoueur(LObjets[0]);
		end;
  		'MenuEnJeu': 
  		begin
		ActualiserMenuEnJeu;
		end;
  		'Menu': 
  		begin
		direction_menu;
		end;
		'NouvellePartieIntro': NouvellePartieIntro;
  		'Cutscene':
		begin
		sdl_renderclear(sdlrenderer);
		affichertout;
		UpdateDialogueBox(dialogues[2]);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		updateanimation(LObjets[1].anim,LObjets[1].image);
		sdl_renderpresent(sdlrenderer);
		if sdl_getTicks mod 200 = 0 then 
			begin
			combat_bg.rect.x:=combat_bg.rect.x-4+random(9);
			combat_bg.rect.y:=combat_bg.rect.y-4+random(9);
			end;
		while (SDL_PollEvent( EventSystem ) = 1) do
    		begin
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[2].letterdelay=0 then sceneActive:='Jeu' else dialogues[2].LetterDelay:=0;
				end
			end
		end;
		'Behemoth_Mort':
		begin
		sdl_renderclear(sdlrenderer);
		affichertout;
		UpdateDialogueBox(dialogues[1]);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		updateanimation(LObjets[1].anim,LObjets[1].image);
		sdl_renderpresent(sdlrenderer);
		if sdl_getTicks mod 1 = 0 then 
			begin
			combat_bg.rect.x:=88+random(9);
			end;
		while (SDL_PollEvent( EventSystem ) = 1) do
    		begin
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[1].letterdelay=0 then begin 
						InitAnimation(LObjets[1].anim,LObjets[1].anim.objectName,'mort',LObjets[1].stats.nbFramesMort,False);
						sceneActive:='Jeu';
						end
						else
							dialogues[1].LetterDelay:=0;
				end
			end
		end;
    
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
    InitMenuPrincipal;
    InitMenuEnJeu;
    InitLeaderboard;
	initUICombat;
	initDecor;
	InitDialogues;
	setlength(LObjets,1);
	initjoueur;
	writeln('essai d''actualisation...');
	DeclencherFondu(False, 5000);
    GameUpdate;
end;

begin
  WriteLn('SceneSys ready !');
end.

