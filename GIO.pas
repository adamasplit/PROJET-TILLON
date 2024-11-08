program SDL_Fonts;

uses
	AnimationSys,
	coeur,
	CollisionSys,
	combatLib,
	enemyLib,
	eventsys,
	MapSys,
	memgraph,
	SDL2,
	SDL2_mixer,
	SDL2_ttf,
	sonoSys,
	fichierSys,
	SysUtils;

var i,j,xpos:Integer;
boule,enn:TObjet; //variable de test

// Bouttons
var button_jouer: TButtonGroup;
	button_lead : TButtonGroup;
	button_q : TButtonGroup;

	button_retour_menu : TButtonGroup;
	button_deck : TButton;
	button_bestiaire: TButton;


	engre : TIntImage;

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
	var menu_bg,combat_bg,menuBook : TImage;
	menuBookAnim : TAnimation;

//GameObjects

var Joueur : TObjet;
	Dummy : TObjet;


//procedures
	btnProc : ButtonProcedure;
	quitter : ButtonProcedure;
	retour_menu : ButtonProcedure;
	Pjouer : ButtonProcedure;
	leaderboard : ButtonProcedure;

//Variables de Debug
	var lastUpdateTime1,LastUpdateTime2:UInt32;

procedure annihiler(); //METTRE A JOUR APRES CHAQUE AJOUT D'OBJET
begin
  // Nettoyage de Ram (DETRUIRE IMPERATIVEMENT TOUTES LES TEXTURES UTILISEES SOUS PEINE DE FUITE DE RAM !!!!)
  TTF_CloseFont(Fantasy30);
  TTF_Quit;

{	//Anihilation Objet [button]
  SDL_FreeSurface(button_jouer.labelSurface);
  SDL_DestroyTexture(button_jouer.labelTexture);}
  
    //Anihilation Objet [button_font]
  SDL_FreeSurface(menu_bg.imgSurface);
  SDL_DestroyTexture(menu_bg.imgTexture);
  
  
	//Anihilation Objet [text1]
  SDL_FreeSurface(text1.textSurface);
  SDL_DestroyTexture(text1.textTexture);
  
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  // Shutting down video subsystem (A laisser imperativement)
  SDL_Quit;
end;

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
begin
	renderRawImage(combat_bg,255,False);
	if LObjets[0].stats.pendu then
			begin
				SDL_RenderCopyEx(sdlRenderer, LObjets[0].image.imgTexture, nil, @LObjets[0].image.rect,0, nil, SDL_FLIP_VERTICAL)
			end
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

procedure ActualiserJeu;
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
					vagueFinie:=False;
					IAEnnemi(LObjets[i],LObjets[0]);
					end;
			end;
		SDL_RenderPresent(sdlRenderer);
		if vagueFinie then ajoutVague;
		if combatFini then choixSalle;
	end;


procedure jouer;
	begin
		SceneActive := 'Jeu';
		ClearScreen;
		SDL_RenderClear(sdlRenderer);

		//Objets dissimulés
		button_lead.button.estVisible := false;
		button_q.button.estVisible := false;
		button_jouer.button.estVisible := false;
		button_retour_menu.button.estVisible :=false;
		
		button_deck.estVisible := False;
		button_bestiaire.estVisible := False;
		//InitDialogueBox(box,'Sprites\Menu\Button1.bmp',000,000,windowWidth,400,'',30);
		InitDialogueBox(box2,'Sprites\Menu\Button1.bmp','Sprites\Menu\portraitB.bmp',000,000,windowWidth,400,extractionTexte('DIALOGUE_BOSS_1'),100);

        //Objets de Scene
		ActualiserJeu;
	end;
procedure lead;
	begin

		SceneActive := 'Leaderboard';

		ClearScreen;
		SDL_RenderClear(sdlRenderer);

		
		
		button_lead.button.estVisible := false;
		button_q.button.estVisible := false;
		button_jouer.button.estVisible := false;
		
		RenderRawImage(menu_bg,255, False);
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


		//Menu Pricipal							A FAIRE Fonction ActiverEventsMenuPrincipal(Boolean) ?
		button_lead.button.estVisible := true;
		button_q.button.estVisible := true;
		button_jouer.button.estVisible := true;
		
		SDL_PollEvent(testEvent);
		RenderRawImage(menu_bg, False);
		OnMouseHover(button_jouer, GetMouseX,GetMouseY);
		OnMouseHover(button_lead, GetMouseX,GetMouseY);
		OnMouseHover(button_q,GetMouseX,GetMouseY);
		RenderButtonGroup(button_jouer);
		RenderButtonGroup(button_lead); 
		RenderButtonGroup(button_q); 
		RenderIntImage(engre);
		RenderText(text1);
		SDL_RenderPresent(sdlRenderer);
		

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

begin
 {	
==================================================================================================================================
* INITIALISATION
*=================================================================================================================================
}

  //récupérer les dimensions de la fenêtre
  SDL_GetWindowSize(sdlWindow1, @windowWidth, @windowHeight);
	LastUpdateTime2:=SDL_GetTicks();
Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 4096);
IndiceMusiqueJouee:=10;
//mix_playMusic(OST[IndiceMusiqueJouee].musique,0);
  //Events
	SceneActive := 'Menu';
	sdlKeyboardState := SDL_GetKeyboardState(nil);

  // Initialisation du joueur
  joueur.col.isTrigger := False;
  joueur.col.estActif := True;
  joueur.col.dimensions.w := 50;
  joueur.col.dimensions.h := 85;
  joueur.col.offset.x := 25;
  joueur.col.offset.y := 15;
  joueur.col.nom := 'Joueur';
  Joueur.anim.estActif := True;

  // Initialisation du Dummy
  Dummy.col.isTrigger := False;
  Dummy.col.estActif := True;
  Dummy.col.dimensions.w := 100;
  Dummy.col.dimensions.h := 500;
  Dummy.col.offset.x := 0;
  Dummy.col.offset.y := 0;
  Dummy.col.nom := 'Dummy';
  Dummy.anim.estActif := False;

  //Initialisation de la liste d'objets
  setlength(LObjets,3);
  vagueFinie:=False;combatFini:=False;
	for j:=1 to 2 do begin 
		writeln('tentative d''accès à LObjets[',j,'], dernier élément : LObjets[',high(Lobjets),']');
		LObjets[j]:=TemplatesEnnemis[2];
		end;

	createRawImage(combat_bg,88,-80,900,900,'Sprites/Game/floor/Floor3.bmp');
	randomize();
	IndiceMusiqueJouee:=1;
	Mix_VolumeMusic(VOLUME_MUSIQUE);
	
	lastUpdateTime2:=sdl_getticks;
  LObjets[0] := Joueur;
  LObjets[0].image.rect.x := windowWidth div 2;
  LObjets[0].image.rect.y := windowHeight div 2;

  lastUpdateTime1:=SDL_GetTicks();
	LastUpdateTime2:=SDL_GetTicks();
	SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);

SDL_RenderClear(sdlRenderer);
new(TestEvent);
statsJoueur.tailleCollection:=22;
statsJoueur.Vitesse:=5;
statsJoueur.multiplicateurMana:=1;
statsJoueur.multiplicateurDegat:=1;
for j:=1 to 22 do begin
  statsJoueur.collection[j]:=Cartes[j]
end;
statsJoueur.vie:=100;statsJoueur.vieMax:=100;
initStatsCombat(statsJoueur,LObjets[0].stats);

randomize();



iCarteChoisie:=8;
initUICombat();
SDL_RenderPresent(sdlRenderer);
  
 {	
==================================================================================================================================
* CREATION D'OBJETS 
*=================================================================================================================================
}
  
   // Créer des boutons
    btnProc := @OnButtonClickDebug;
    quitter:=@annihiler;
    Pjouer:=@jouer;
    leaderboard:=@lead;
    retour_menu:=@direction_menu;

	//
    //Boutons
	//

    
	//Menu Principal
	InitButtonGroup(button_jouer,windowWidth div 2-208, windowHeight div 5, 416, 208,'Sprites\Menu\Button1.bmp', 'Jouer',Pjouer);
	InitButtonGroup(button_lead, windowWidth  div 2-208, 2*windowHeight div 4, 416, 150,'Sprites\Menu\Button1.bmp','Leaderboard',leaderboard);
	InitButtonGroup(button_q, windowWidth div 2-208, 3 * windowHeight div 4, 416, 100,'Sprites\Menu\Button1.bmp','Ragequit',quitter);
	//Menu en Jeu
	CreateButton(button_deck, 210, 320, 240, 50,'Deck',b_color, bf_color,Fantasy30,btnProc);
	CreateButton(button_bestiaire, 210, 390, 240, 50,'Bestiaire',b_color, bf_color,Fantasy30,btnProc);

	//
    //Images
	//
	CreateRawImage(menu_bg,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\fond1.bmp');
	//CreateRawImage(vague, -10, 0, windowWidth+20, windowHeight, 'Sprites\Menu\vague.bmp');
	CreateInteractableImage(engre, 200, 200, 100, 100, 'Sprites\Menu\eng.bmp',btnProc);

	//
    //Textes
	//

	CreateText(text1, windowWidth div 2-150, 20, 300, 250, 'Les Cartes du Destin ',Fantasy30, whiteCol);
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

    // GameObjects
    CreateRawImage(LObjets[0].image, windowWidth div 2, windowHeight div 2, 100, 100, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
	//CreateRawImage(LObjets[1].image, windowWidth, 100, 100, 500, 'Sprites\Menu\fond1.bmp');

	CreateRawImage(menuBook,0,0,windowWidth,windowHeight,'Sprites\Game\Book\Book_Opening_1.bmp');
	
	
	
	

	
{	
==================================================================================================================================
* RENDERING
*=================================================================================================================================
}
//Pas de Premier Render, on appelle juste direction_menu

direction_menu;
InitAnimation(LObjets[0].anim, 'Joueur', 'idle', 12, True);
{
==================================================================================================================================
* EVENTS
*=================================================================================================================================
}
    //Systeme de detection d'évents
  
  new( testEvent );
  
  while True do
  begin
  autoMusique();
   // 100 FPS
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
		while (SDL_PollEvent( testEvent ) = 1) do
    		begin
      			case testEvent^.type_ of
					SDL_mousebuttondown:sceneActive:='Jeu';
				end
			end
		end;
    

    while SDL_PollEvent( testEvent ) = 1 do
    begin
      case testEvent^.type_ of
			SDL_KEYDOWN:
			//Touches de Debug
      		begin
        		case testEvent^.key.keysym.sym of
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
				getMouseX;getMouseY;xpos:=testevent^.motion.x;
				end;
			SDL_mousebuttondown : 
				begin 
				if sceneActive='Jeu' then jouerCarte(LObjets[0].stats,LObjets[0].image.rect.x+(LObjets[0].image.rect.w div 2),LObjets[0].image.rect.y+(LObjets[0].image.rect.h div 2),iCarteChoisie);
   				if button_jouer.button.estVisible then
				begin
				OnMouseClick(button_jouer,testEvent^.motion.x,testEvent^.motion.y);
				HandleButtonClick(button_jouer.button,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_lead.button.estVisible then
				begin
				OnMouseClick(button_lead,testEvent^.motion.x,testEvent^.motion.y);
				HandleButtonClick(button_lead.button,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_q.button.estVisible then
				begin
				OnMouseClick(button_q,testEvent^.motion.x,testEvent^.motion.y);
				HandleButtonClick(button_q.button,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_retour_menu.button.estVisible then
				begin
				OnMouseClick(button_retour_menu,testEvent^.motion.x,testEvent^.motion.y);
				HandleButtonClick(button_retour_menu.button,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_deck.estVisible then
				begin
				HandleButtonClick(button_deck,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_bestiaire.estVisible then
				begin
				HandleButtonClick(button_bestiaire,testEvent^.motion.x,testEvent^.motion.y);
				end;
				end;
			SDL_MOUSEWHEEL:begin
  				if testEvent^.wheel.y < 0 then icarteChoisie:=(isuiv(iCarteChoisie))
  				else icarteChoisie:=(iprec(iCarteChoisie));
				end;
				
				end;
			end;
  end;
annihiler();
end.
