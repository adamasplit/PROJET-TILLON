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
	SysUtils;

var i,j,xpos:Integer;
boule,enn:TObjet; //variable de test

// Bouttons
var button_jouer: TButton;
	button_lead : TButton;
	button_q : TButton;

	button_souligne : TButton;
	button_retour_menu : TButton;
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

//Image
	var menu_bg,combat_bg : TImage;

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
  TTF_CloseFont(dayDream30);
  TTF_Quit;

	//Anihilation Objet [button]
  SDL_FreeSurface(button_jouer.labelSurface);
  SDL_DestroyTexture(button_jouer.labelTexture);
  
  	//Anihilation Objet [btn2]
  SDL_FreeSurface(button_lead.labelSurface);
  SDL_DestroyTexture(button_lead.labelTexture);
  
    //Anihilation Objet [button_font]
  SDL_FreeSurface(menu_bg.imgSurface);
  SDL_DestroyTexture(menu_bg.imgTexture);
  
    //Anihilation Objet [button_font]
  SDL_FreeSurface(button_q.labelSurface);
  SDL_DestroyTexture(button_q.labelTexture);
  
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
		if i<=High(LObjets) then	begin
			//writeln('mise à jour des animations : indice ',i,', dernier indice :',high(lobjets));
			LObjets[i].stats.indice:=i;
        	if (LObjets[i].stats.genre<>projectile) and (LObjets[i].stats.genre<>laser) and (LObjets[i].stats.genre<>epee) then
				RenderRawImage(LObjets[i].image,255, LObjets[i].anim.isFliped);
			if LObjets[i].anim.estActif then 
				begin
				if (LObjets[i].stats.genre<>laser) and (LObjets[i].stats.genre<>epee) then
					begin
					UpdateAnimation(LObjets[i].anim, LObjets[i].image);
					if (LObjets[i].stats.genre=effet) and (LObjets[i].anim.currentFrame=6) then
					supprimeObjet(LObjets[i]);
					end
				end
			end;
for i:=2 to High(LObjets) do
      if (i<=High(LObjets)) then
	  	begin
	  		//writeln('mise à jour des projectiles : indice ',i,', dernier indice :',high(lobjets));
			case LObjets[i].stats.genre of 
        	projectile:begin
        		if i<>LObjets[i].stats.indice then writeln('conflit à l"indice',i);
        		//writeln('accès à l"objet numéro ',i,' dernier indice de LObjets : ',high(LObjets));
        		updateBoule(LObjets[i]);
        		end;
			laser:updateRayon(LObjets[i]);
			epee:UpdateJustice(LObjets[i]);
			end;
		end
end;

procedure ActualiserJeu;
	begin
		randomize();
		SDL_RenderClear(sdlRenderer);
		renderRawImage(combat_bg,255,False);
		SDL_PumpEvents;
		sdl_delay(10);
		//writeln('mise à jour des collisions');
		UpdateCollisions();
		//writeln('mise à jour des animations');
		UpdateAnimations();
		//writeln('animations mises à jour');
		RegenMana(LastUpdateTime2,LObjets[0].stats.mana,LObjets[0].stats.manaMax,LObjets[0].stats.multiplicateurMana);
        //Render
		//writeln('mise à jour de l"UI');
		//ébauche d'IA pour l'ennemi
		//writeln('les ennemis agissent');
		for i:=1 to High(LObjets) do
			if i<=High(LObjets) then
				if LObjets[i].stats.genre=TypeObjet(1) then
					IAEnnemi(LObjets[i],LObjets[0]);
		//writeln('les ennemis ont fini d"agir');
		UpdateUICombat(icarteChoisie,400,400,LObjets[0].stats);
		SDL_RenderPresent(sdlRenderer);
		
	end;


procedure jouer;
	begin
		SceneActive := 'Jeu';
		ClearScreen;
		SDL_RenderClear(sdlRenderer);

		//Objets dissimulés
		button_lead.estVisible := false;
		button_q.estVisible := false;
		button_jouer.estVisible := false;
		button_retour_menu.estVisible :=false;
		
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
		
		button_lead.estVisible := false;
		button_q.estVisible := false;
		button_jouer.estVisible := false;
		
		RenderRawImage(menu_bg,255, False);
		//RenderRawImage(vague);
		RenderText(text1);
		RenderText(titre_lead);
		RenderButton(button_souligne);
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


		
		RenderButton(button_retour_menu);
		SDL_RenderPresent(sdlRenderer);
	end;

procedure direction_menu;
	begin
		SceneActive := 'Menu';

		ClearScreen;
		SDL_RenderClear(sdlRenderer);
		//Menu Pricipal							A FAIRE Fonction ActiverEventsMenuPrincipal(Boolean) ?
		button_lead.estVisible := true;
		button_q.estVisible := true;
		button_jouer.estVisible := true;
		
		RenderRawImage(menu_bg,255, False);
		//RenderRawImage(vague);
		RenderButton(button_jouer);
		RenderButton(button_lead); 
		RenderButton(button_q); 
		RenderIntImage(engre);
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
		
			DrawRect(black_color,200, windowWidth div 10, windowHeight div 10, windowWidth - windowWidth div 8,windowHeight - windowHeight div 8);
			DrawRect(black_color, 230,windowWidth div 10 + 400, windowHeight div 10, 5,windowHeight - windowHeight div 8);
			RenderButton(button_deck);
			RenderButton(button_bestiaire);

			

			SDL_RenderPresent(sdlRenderer);
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
  setLength(LObjets,7);
  LObjets[0] := Joueur;
  LObjets[1] := Dummy;
  LObjets[1].stats.genre:=autre;
  LObjets[0].image.rect.x := windowWidth div 2;
  LObjets[0].image.rect.x := windowWidth div 2;
    LObjets[1].image.rect.x := windowWidth div 2;
  LObjets[1].image.rect.y := windowWidth div 2;
  LObjets[0].image.rect.y := windowHeight div 2;

  LObjets[2].image.rect.x := windowWidth div 2-100;
  LObjets[2].image.rect.y := windowHeight div 2-100;

  lastUpdateTime1:=SDL_GetTicks();
	LastUpdateTime2:=SDL_GetTicks();
	SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);

SDL_RenderClear(sdlRenderer);
new(TestEvent);
statsJoueur.tailleCollection:=22;
statsJoueur.Vitesse:=5;
statsJoueur.multiplicateurMana:=1;
for j:=1 to 22 do begin
  statsJoueur.collection[j]:=Cartes[j]
end;
statsJoueur.vie:=100;statsJoueur.vieMax:=100;
initStatsCombat(statsJoueur,LObjets[0].stats);

randomize();



iCarteChoisie:=1;
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
	CreateButton(button_jouer, windowWidth div 2-150, 150, 350, 100, 'Jouer', b_color, black_color,dayDream30,Pjouer);
	CreateButton(button_lead, windowWidth  div 2-150-25, 275, 400, 100, 'Leaderboard',b_color, black_color,dayDream30,leaderboard);
	CreateButton(button_q, windowWidth div 2-150, 400, 350, 100, 'Ragequit',b_color, black_color,dayDream30,quitter);
	CreateButton(button_souligne, windowWidth div 2-215, 150, 475, 10, ' ', black_color, black_color,dayDream30,btnProc); // A refaire avec un DrawRect
	//Menu en Jeu
	CreateButton(button_deck, 210, 320, 240, 50,'Deck',b_color, bf_color,dayDream30,btnProc);
	CreateButton(button_bestiaire, 210, 390, 240, 50,'Bestiaire',b_color, bf_color,dayDream30,btnProc);

	//
    //Images
	//
	CreateRawImage(menu_bg,0 , 0,windowWidth ,windowHeight ,'Sprites\Menu\fond1.bmp');
	//CreateRawImage(vague, -10, 0, windowWidth+20, windowHeight, 'Sprites\Menu\vague.bmp');
	CreateInteractableImage(engre, 200, 200, 100, 100, 'Sprites\Menu\eng.bmp',btnProc);

	//
    //Textes
	//

	CreateText(text1, windowWidth div 2-200, 20, 300, 250, 'Les Cartes du Destin ',dayDream30, whiteCol);
	CreateText(titre_lead, windowWidth div 2-210, 90, 300, 250, 'Leaderboard',dayDream40, navy_color);
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
	CreateButton(button_retour_menu, 850, 625, 200, 75, 'Menu', b_color, bf_color,dayDream30,retour_menu);

    // GameObjects
    CreateRawImage(LObjets[0].image, windowWidth div 2, windowHeight div 2, 100, 100, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
	CreateRawImage(LObjets[1].image, windowWidth, 100, 100, 500, 'Sprites\Menu\fond1.bmp');
	
	
	
	

	
{	
==================================================================================================================================
* RENDERING
*=================================================================================================================================
}
//Pas de Premier Render, on appelle juste direction_menu

direction_menu;
InitAnimation(LObjets[0].anim, 'Joueur', 'idle', 12, True);
for j:=1 to 1 do begin 
	initStatEnnemi('Archimage',10,1,1,128,128,LObjets[j]);
	LObjets[j].stats.vie:=100;
	LObjets[j].stats.vieMax:=100
	end;

createRawImage(combat_bg,88,-80,900,900,'Sprites/Game/floor/Floor.bmp');
IndiceMusiqueJouee:=5;
Mix_VolumeMusic(VOLUME_MUSIQUE);
//mix_playMusic(OST[IndiceMusiqueJouee].musique,0);
{
==================================================================================================================================
* EVENTS
*=================================================================================================================================
}
    //Systeme de detection d'évents
  
  new( testEvent );
  
  while True do
  begin
   // 100 FPS
//Mouvement Joueur
  if SceneActive='Jeu' then 
  		begin
		ActualiserJeu;
		MouvementJoueur(LObjets[0]);
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
					SDLK_SPACE:leMonde:=not(leMonde);
        		end;
      		end;
			
			SDL_mousemotion: 
				begin
				getMouseX;getMouseY;xpos:=testevent^.motion.x;
				end;
			SDL_mousebuttondown : 
				begin 
				if sceneActive='Jeu' then jouerCarte(LObjets[0].stats.deck^,iCarteChoisie,LObjets[0].stats.force,LObjets[0].stats.multiplicateurDegat,LObjets[0].stats.vie,LObjets[0].stats.mana,LObjets[0].image.rect.x+(LObjets[0].image.rect.w div 2),LObjets[0].image.rect.y+(LObjets[0].image.rect.h div 2));
   				if button_jouer.estVisible then
				begin
				HandleButtonClick(button_jouer,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_lead.estVisible then
				begin
				HandleButtonClick(button_lead,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_q.estVisible then
				begin
				HandleButtonClick(button_q,testEvent^.motion.x,testEvent^.motion.y);
				//continue;
				end;
				if button_retour_menu.estVisible then
				begin
				HandleButtonClick(button_retour_menu,testEvent^.motion.x,testEvent^.motion.y);
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
