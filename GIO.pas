program SDL_Fonts;

uses
	AnimationSys,
	CollisionSys,
	memgraph,
	SDL2,
	SDL2_mixer,
	SDL2_ttf,
	SysUtils;

//Couleurs
var whiteCol,b_color,bf_color,f_color,navy_color,black_color,red_color: TSDL_Color;

// Bouttons
var button_jouer: TButton;
	button_lead : TButton;
	button_q : TButton;

	button_souligne : TButton;
	button_retour_menu : TButton;
	button_deck : TButton;
	button_bestiaire: TButton;

	engre : TIntImage;
    im1: TIntImage;

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
	var menu_bg : TImage;

//GameObjects
var
  JoueurX, JoueurY: Integer;

var Joueur : TObjet;
	Dummy : TObjet;

//Gestion des Events
	sdlEvent: PSDL_Event;
	sdlKeyboardState: PUInt8;
	SceneActive : String;

//procedures
	btnProc : ButtonProcedure;
	quitter : ButtonProcedure;
	retour_menu : ButtonProcedure;
	Pjouer : ButtonProcedure;
	leaderboard : ButtonProcedure;

//Variables de Debug
	Hp_Debug : Integer;

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

procedure ActualiserJeu;
	begin
		SDL_RenderClear(sdlRenderer);

		RenderRawImage(Dummy.image);

		RenderRawImage(Joueur.image);
		UpdateAnimation(Joueur.anim, Joueur.image);
    	RenderAnimation(Joueur.anim, Joueur.image, sdlRenderer);
		//UI de la Vie (provisoire)
		DrawRect(black_color,255, 10, 20, 200, 30);
		DrawRect(red_color,255, 15, 25, Round(190* Hp_Debug/100), 20 );

        //Render
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
		
		RenderRawImage(menu_bg);
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
		
		RenderRawImage(menu_bg);
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

  // Définir les couleurs de base
  whiteCol.r := 255; whiteCol.g := 255; whiteCol.b := 255;
  bf_color.r :=5; bf_color.g :=12; bf_color.b :=156;
  b_color.r :=167; b_color.g :=230; b_color.b :=255;
  f_color.r :=58; f_color.g :=190; f_color.b :=249;
  navy_color.r :=53; navy_color.g :=114; navy_color.b :=239;
  black_color.r := 0; black_color.g := 0; black_color.b := 0;
  red_color.r := 255; red_color.g := 0; red_color.b := 50;


  //récupérer les dimensions de la fenêtre
  SDL_GetWindowSize(sdlWindow1, @windowWidth, @windowHeight);

  //Events
	SceneActive := 'Menu';
	sdlKeyboardState := SDL_GetKeyboardState(nil);

  //Joueur
  Joueur.IsTrigger := False;

  JoueurX := windowWidth div 2;
  JoueurY := windowHeight div 2;

  //Dummy
  Dummy.IsTrigger := False;


  Hp_Debug := 100;
  
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
    CreateRawImage(Joueur.image, windowWidth div 2, windowHeight div 2, 150, 150, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
	CreateRawImage(Dummy.image, windowWidth - windowWidth div 5, windowHeight div 2, 100, 500, 'Sprites\Game\dummy.bmp');
	
	
	

	
{	
==================================================================================================================================
* RENDERING
*=================================================================================================================================
}
//Pas de Premier Render, on appelle juste direction_menu

direction_menu;
InitAnimation(Joueur.anim, 'Joueur', 'idle', 6, True);
{
==================================================================================================================================
* EVENTS
*=================================================================================================================================
}
    //Systeme de detection d'évents
  
  new( sdlEvent );
  
  while True do
  begin
//Mouvement Joueur
  SDL_PumpEvents;

  if (SceneActive = 'Jeu') then
  begin
	
  	if sdlKeyboardState[SDL_SCANCODE_W] = 1 then
	begin
      JoueurY := JoueurY - 1;
	  if Joueur.anim.Etat <> 'run' then InitAnimation(Joueur.anim,'Joueur','run',10,True);
	end;
	
    if sdlKeyboardState[SDL_SCANCODE_A] = 1 then
	begin
	  	JoueurX := JoueurX - 1;
	  	if Joueur.anim.Etat <> 'run' then InitAnimation(Joueur.anim,'Joueur','run',10,True);
	end;
    
    if sdlKeyboardState[SDL_SCANCODE_S] = 1 then
      	begin
	  	JoueurY := JoueurY + 1;
	  	if Joueur.anim.Etat <> 'run' then InitAnimation(Joueur.anim,'Joueur','run',10,True);
	end;
	
    if sdlKeyboardState[SDL_SCANCODE_D] = 1 then
    	begin
	  	JoueurX := JoueurX + 1;
	  	if Joueur.anim.Etat <> 'run' then InitAnimation(Joueur.anim,'Joueur','run',10,True);
	end;

	if ((Joueur.anim.Etat <> 'idle') and not((sdlKeyboardState[SDL_SCANCODE_D] = 1) or (sdlKeyboardState[SDL_SCANCODE_S] = 1) or (sdlKeyboardState[SDL_SCANCODE_W] = 1) or (sdlKeyboardState[SDL_SCANCODE_A] = 1))) 
		then InitAnimation(Joueur.anim,'Joueur','idle',6,True);
	

	Joueur.image.rect.x := JoueurX;
  	Joueur.image.rect.y := JoueurY;

	if CheckCollision(Joueur, Dummy,0,0) then Block(Joueur,Dummy);
	ActualiserJeu;
  end;

    

    while SDL_PollEvent( sdlEvent ) = 1 do
    begin
      case sdlEvent^.type_ of
			SDL_KEYDOWN:
			//Touches de Debug
      		begin
        		case sdlEvent^.key.keysym.sym of
          			SDLK_UP:  Hp_Debug := Hp_Debug +10;
					SDLK_DOWN: Hp_Debug := Hp_Debug-10;
					SDLK_ESCAPE : menuEnJeu;
        		end;
      		end;

			//Bouton de souris pressé
			SDL_MOUSEBUTTONDOWN: 
			begin
				if button_jouer.estVisible then
				begin
				HandleButtonClick(button_jouer,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
				if button_lead.estVisible then
				begin
				HandleButtonClick(button_lead,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
				if button_q.estVisible then
				begin
				HandleButtonClick(button_q,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
				if button_retour_menu.estVisible then
				begin
				HandleButtonClick(button_retour_menu,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
				if button_deck.estVisible then
				begin
				HandleButtonClick(button_deck,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
				if button_bestiaire.estVisible then
				begin
				HandleButtonClick(button_bestiaire,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
			end;
			
			//ajouter events ici
			end;
	end;
  end;
annihiler();
end.
