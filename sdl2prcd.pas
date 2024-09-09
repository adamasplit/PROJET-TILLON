program SDL_Fonts;

uses
	memgraph,
	SDL2,
	SDL2_mixer,
	SDL2_ttf,
	SysUtils;

var
	whiteCol,b_color,bf_color,f_color,navy_color,black_color: TSDL_Color;

var button_jouer: TButton;
	button_lead : TButton;
	button_bg : TButton;
	button_q : TButton;
	button_facile : TButton;
	button_difficile : TButton;
	button_souligne : TButton;
	button_retour_menu : TButton;
	engre : TIntImage;
	vague : TImage;
	text1 : TText;
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
	sdlEvent: PSDL_Event;
	btnProc : ButtonProcedure;
	quitter : ButtonProcedure;
	retour_menu : ButtonProcedure;
	play : ButtonProcedure;
	leaderboard : ButtonProcedure;
	ez : ButtonProcedure;
	im1: TIntImage;
	
procedure annihiler(); //METTRE A JOUR APRES CHAQUE AJOUT D'OBJET
begin
  // Nettoyage de Ram (DETRUIRE IMPERATIVEMENT TOUTES LES TEXTURES UTILISEES SOUS PEINE DE FUITE DE RAM !!!!)
  TTF_CloseFont(dayDream30);
  TTF_Quit;

	//Clear Object [button]
  SDL_FreeSurface(button_jouer.labelSurface);
  SDL_DestroyTexture(button_jouer.labelTexture);
  
  	//Clear Object [btn2]
  SDL_FreeSurface(button_lead.labelSurface);
  SDL_DestroyTexture(button_lead.labelTexture);
  
    	//Clear Object [button_font]
  SDL_FreeSurface(button_bg.labelSurface);
  SDL_DestroyTexture(button_bg.labelTexture);
  
      	//Clear Object [button_font]
  SDL_FreeSurface(button_q.labelSurface);
  SDL_DestroyTexture(button_q.labelTexture);
  
	//Clear Object [text1]
  SDL_FreeSurface(text1.textSurface);
  SDL_DestroyTexture(text1.textTexture);
  
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  // Shutting down video subsystem (A laisser imperativement)
  SDL_Quit;
end;

procedure jouer;
	begin
		ClearScreen;
		SDL_RenderClear(sdlRenderer);
		
		button_lead.estVisible := false;
		button_q.estVisible := false;
		button_jouer.estVisible := false;
		button_facile.estVisible := true;
		button_difficile.estVisible := true;
		
		RenderButton(button_bg);
		RenderRawImage(vague);
		RenderText(text1);
		RenderButton(button_facile);
		RenderButton(button_difficile);
		RenderButton(button_retour_menu);
		SDL_RenderPresent(sdlRenderer);
	end;

procedure lead;
	begin
		ClearScreen;
		SDL_RenderClear(sdlRenderer);
		
		button_lead.estVisible := false;
		button_q.estVisible := false;
		button_jouer.estVisible := false;
		
		RenderButton(button_bg);
		RenderRawImage(vague);
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
		ClearScreen;
		SDL_RenderClear(sdlRenderer);
		
		button_lead.estVisible := true;
		button_q.estVisible := true;
		button_jouer.estVisible := true;
		button_facile.estVisible := false;
		
		RenderButton(button_bg);
		RenderRawImage(vague);
		RenderButton(button_jouer);
		RenderButton(button_lead); 
		RenderButton(button_q); 
		RenderIntImage(engre);
		RenderText(text1);
		SDL_RenderPresent(sdlRenderer);

	end;



procedure facile;
	begin
		ClearScreen;
		SDL_RenderClear(sdlRenderer);
		
		button_lead.estVisible := false;
		button_q.estVisible := false;
		button_jouer.estVisible := false;
		button_facile.estVisible := false;
		
		RenderButton(button_bg);
		RenderRawImage(vague);
		RenderText(text1);
		RenderIntImage(im1);
		
		SDL_RenderPresent(sdlRenderer);
	end;

begin
  // Définir les couleurs de base
  whiteCol.r := 255; whiteCol.g := 255; whiteCol.b := 255;
  bf_color.r :=5; bf_color.g :=12; bf_color.b :=156;
  b_color.r :=167; b_color.g :=230; b_color.b :=255;
  f_color.r :=58; f_color.g :=190; f_color.b :=249;
  navy_color.r :=53; navy_color.g :=114; navy_color.b :=239;
  black_color.r := 0; black_color.g := 0; black_color.b := 0;


  //récupérer les dimensions de la fenêtre
  SDL_GetWindowSize(sdlWindow1, @windowWidth, @windowHeight);
  
 {	
==================================================================================================================================
* ITEM CREATION
*=================================================================================================================================
}
  
   // Créer des boutons
    btnProc := @OnButtonClickDebug;
    quitter:=@annihiler;
    play:=@jouer;
    leaderboard:=@lead;
    retour_menu:=@direction_menu;
    ez:=@facile;
    CreateButton(button_bg,0 , 0,windowWidth ,windowHeight , ' ',f_color, bf_color,dayDream30,btnProc);
	CreateButton(button_jouer, windowWidth div 2-150, 150, 350, 100, 'Jouer', b_color, bf_color,dayDream30,play);
	CreateButton(button_lead, windowWidth  div 2-150-25, 275, 400, 100, 'Leaderboard',b_color, bf_color,dayDream30,leaderboard);
	CreateButton(button_q, windowWidth div 2-150, 400, 350, 100, 'Ragequit',b_color, bf_color,dayDream30,quitter);
	CreateButton(button_facile, windowWidth div 2-170, 150, 400, 100, 'Mode Facile', b_color, bf_color,dayDream30,ez);
	CreateButton(button_difficile, windowWidth div 2-170, 300, 400, 100, 'Mode Difficile', b_color, bf_color,dayDream30,btnProc);
	CreateButton(button_souligne, windowWidth div 2-215, 150, 475, 10, ' ', black_color, black_color,dayDream30,btnProc);
	CreateRawImage(vague, -10, 0, windowWidth+20, windowHeight, 'vague.bmp');
	CreateInteractableImage(engre, 200, 200, 100, 100, 'eng.bmp',btnProc);
	CreateText(text1, windowWidth div 2-150+65, 20, 300, 250, 'Memory',dayDream30, whiteCol);
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
	CreateText(text_s5, 40, 525, 150, 125, 'Nom partie :',dayDream20, bf_color);
	CreateButton(button_retour_menu, 850, 625, 200, 75, 'Menu', b_color, bf_color,dayDream30,retour_menu);
	CreateInteractableImage(im1, 10, 60, 150, 150, 'carte-i2_crop.bmp' , btnProc);
	

	
{	
==================================================================================================================================
* RENDERING
*=================================================================================================================================
}

  // Efface les Renderers précédents (NE PAS TOUCHER)
  SDL_RenderClear(sdlRenderer);
  
  

  // Render des objet
  button_facile.estVisible := false;
  RenderButton(button_bg);
  RenderRawImage(vague);
  RenderButton(button_jouer);
  RenderButton(button_lead); 
  RenderButton(button_q); 
  RenderIntImage(engre);
  RenderText(text1);
  
  

  // MAJ de l'écran (NE PAS TOUCHER)
  SDL_RenderPresent(sdlRenderer);

{
==================================================================================================================================
* EVENTS
*=================================================================================================================================
}
    //Systeme de detection d'évents
  
  new( sdlEvent );
  
  while True do
  begin
    while SDL_PollEvent( sdlEvent ) = 1 do
    begin
      case sdlEvent^.type_ of
			//Bouton de souris pressé
			SDL_MOUSEBUTTONDOWN: 
			begin
			writeln(button_facile.estVisible);
			
				if button_facile.estVisible then
				begin
				HandleButtonClick(button_facile,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
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
				if button_difficile.estVisible then
				begin
				HandleButtonClick(button_difficile,sdlEvent^.motion.x,sdlEvent^.motion.y);
				//continue;
				end;
			end;
			
			//ajouter events ici 655 680
			end;
	end;
  end;
annihiler();
end.
