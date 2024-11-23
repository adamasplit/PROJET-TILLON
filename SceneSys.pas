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
	sdl_freesurface(fond.imgSurface);
	sdl_destroytexture(fond.imgTexture);
    CreateRawImage(fond,88,-80,900,900,StringToPChar('Sprites/Game/floor/Floor'+ IntToStr(Random(5)) +'.bmp'));
end;

procedure InitDecorCartes;
begin
    randomize;
	sdl_freesurface(fond.imgSurface);
	sdl_destroytexture(fond.imgTexture);
    CreateRawImage(fond,0,0,windowWidth,windowHeight,StringToPChar('Sprites/Menu/fond_cartes.bmp'));
end;

procedure InitDecorMap;
begin
    randomize;
	sdl_freesurface(fond.imgSurface);
	sdl_destroytexture(fond.imgTexture);
    CreateRawImage(fond,88,-80,900,900,StringToPChar('Sprites/Game/floor/map_Bg.bmp'));
end;

procedure InitDialogues;
begin

	
end;

// Updates des Scenes

procedure ActualiserJeu;
var i:Integer;
	begin
		randomize();
		scenePrec:='Jeu';
		//writeln('actualiserJeu, taille de LObjets:',high(lobjets));
		SDL_PumpEvents;
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
					if not (LObjets[i].anim.etat='dodge') then
						LObjets[i].col.estActif:=True;
					IAEnnemi(LObjets[i],LObjets[0]);


					end;
			end;
		if vagueFinie then ajoutVague;
		if combatFini then victoire(statsJoueur);
	end;

procedure ActualiserMenuEnJeu;
	begin
		affichertout();
		UpdateAnimation(menuBookAnim,menuBook);
		RenderRawImage(menuBook,False);
		if (animFinie(menuBookAnim)) and (sceneActive='MenuEnJeu') then
			begin
			RenderButtonGroup(boutons[8]);
			RenderButtonGroup(boutons[9]);
			end;
	end;

//Initialisations

procedure InitJoueur;
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
    statsJoueur.vie:=100;statsJoueur.vieMax:=100;
    initStatsCombat(statsJoueur,LObjets[0].stats);
    iCarteChoisie:=1;
    CreateRawImage(LObjets[0].image, windowWidth div 2-windowWidth div 4, windowHeight div 2, 100, 100, 'Sprites\Game\Joueur\Joueur_idle_1.bmp');
    CreateRawImage(menuBook,0,0,windowWidth,windowHeight,'Sprites\Game\Book\Book_Opening_1.bmp');
	initAnimation(LObjets[0].anim,'Joueur','idle',12,True);
end;

procedure HandleButtonClickCarte(var button: TButtonGroup; x, y: Integer;carte:TCarte;var stats:TStats);
begin
  if (x >= button.image.rect.x) and (x <= button.image.rect.x + button.image.rect.w) and
     (y >= button.image.rect.y) and (y <= button.image.rect.y + button.image.rect.h) then
  begin
    if Assigned(button.procCarte) then
    begin
        writeln('procédure spéciale en cours');
		button.procCarte(carte,stats);
    end;
  end;
end;

procedure GameUpdate;
var i:Integer;
begin
  new(EventSystem);
   while True do
  begin
  sdl_delay(10);
  sdl_renderclear(sdlRenderer);
  autoMusique();
    //Mouvement Joueur
	case SceneActive of
		'Deck':
		begin
		actualiserMenuEnJeu;
		actualiserDeck;
		end;
		'Bestiaire':
		begin
		actualiserMenuEnJeu;
		actualiserBestiaire;
		end;
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
		'map':
		begin
        actualiserMap;
    	end;
		'marchand':
		begin
		actualiserMarchand;
		end;
		'MenuShop':
		begin
		actualiserEchange;
		end;
		'NouvellePartieIntro': NouvellePartieIntro;
		'victoire':
			begin
			InitDecorCartes;
			RenderRawImage(fond,False);
			InitDecor;
			for i:=1 to 3 do
				begin
				RenderButtonGroup(btnCartes[i]);
				OnMouseHover(btnCartes[i],getMouseX,getMouseY,'SFX\cardHover.wav')
				end;
			end;
  		'Cutscene':
		begin
		affichertout;
		UpdateDialogueBox(dialogues[2]);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		if LObjets[1].anim.objectName<>'Leo_Transe' then
		updateanimation(LObjets[1].anim,LObjets[1].image);
		
		fond.rect.x:=88-4+random(9);
		while (SDL_PollEvent( EventSystem ) = 1) do
    		begin
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if dialogues[1].letterdelay=0 then begin
						sceneActive:='Jeu';
						indiceMusiqueJouee:=8;
						end
						 else dialogues[1].LetterDelay:=0;
				end
			end
		end;
		'Behemoth_Mort':
		begin
		affichertout;
		UpdateDialogueBox(dialogues[2]);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		updateanimation(LObjets[1].anim,LObjets[1].image);
		if sdl_getTicks mod 1 = 0 then 
			begin
			fond.rect.x:=88+random(9);
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
					SDLK_F2:begin
						statsJoueur.force:=statsJoueur.force+1;
						LObjets[0].stats.force:=LObjets[0].stats.force+1;
						end;
					SDLK_F3:modeDebug:=not(modeDebug);
					SDLK_F4:for i:=1 to MAXENNEMIS do
						statsJoueur.bestiaire[i]:=True;
        		end;
      		end;
			
			SDL_mousemotion: 
				begin
				getMouseX;getMouseY;
				end;
			SDL_mousebuttondown : 
				begin 
				case sceneActive of
				'Jeu': jouerCarte(LObjets[0].stats,LObjets[0].image.rect.x+(LObjets[0].image.rect.w div 2),LObjets[0].image.rect.y+(LObjets[0].image.rect.h div 2),iCarteChoisie);

				'map':begin 
					//writeln('Mouse button pressed at (', EventSystem^.motion.x, ',', EventSystem^.motion.y, ')');
                    writeln(salles[1].image.button.rect.x);
					for i:=1 to 3 do
						begin
                        OnMouseClick(salles[i].image, EventSystem^.motion.x, EventSystem^.motion.y);
                        HandleButtonClick(salles[i].image.button, EventSystem^.motion.x, EventSystem^.motion.y);
						end
					end;
				'victoire':for i:=1 to 3 do
					begin
					OnMouseClick(btnCartes[i], EventSystem^.motion.x, EventSystem^.motion.y);
					HandleButtonClickCarte(btnCartes[i], EventSystem^.motion.x, EventSystem^.motion.y,btnCartes[i].carte,statsJoueur);
					end;
				'marchand':
					begin
					if not echangeFait then
						begin
						OnMouseClick(boutons[1], EventSystem^.motion.x, EventSystem^.motion.y);
						HandleButtonClick(boutons[1].button, EventSystem^.motion.x, EventSystem^.motion.y);
						end;
					for i:=2 to 3 do
						begin
						OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
						HandleButtonClick(boutons[i].button, EventSystem^.motion.x, EventSystem^.motion.y);
						end;
					end;
				'MenuShop':begin
					highlight(boutons[2],getmousex,getmousey);
					for i:=1 to 4 do
					begin
					OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
					HandleButtonClick(boutons[i].button, EventSystem^.motion.x, EventSystem^.motion.y);
					end;
					if ichoix1<>ichoix2 then HandleButtonClickEch(boutons[4],getmouseX,getMouseY,statsJoueur.collection[iChoix1],statsJoueur.collection[iChoix2],statsJoueur);
					end;
				end;
				if sceneActive='Menu' then
				begin
					for i:=1 to 5 do
					begin
					OnMouseClick(boutons[i],EventSystem^.motion.x,EventSystem^.motion.y);
					HandleButtonClick(boutons[i].button,EventSystem^.motion.x,EventSystem^.motion.y);
					end;
				end;
				if sceneActive='MenuEnJeu' then
				begin
				if boutons[8].button.estVisible then
					HandleButtonClick(boutons[8].button,EventSystem^.motion.x,EventSystem^.motion.y);
				if boutons[9].button.estVisible then
					HandleButtonClick(boutons[9].button,EventSystem^.motion.x,EventSystem^.motion.y);
				end;
				end;
			SDL_MOUSEWHEEL:begin
				if sceneActive='Jeu' then 
					begin
  					if EventSystem^.wheel.y < 0 then icarteChoisie:=(isuiv(iCarteChoisie))
  					else icarteChoisie:=(iprec(iCarteChoisie));
					end;
				if (sceneActive='Deck') then
					begin
					scrollDeck(ideck);
					end;
				if sceneActive='Bestiaire' then
					begin
					scrollBestiaire;
					end;
				if sceneActive='MenuShop' then
					begin
					if not etatChoix then scrolldeck(iChoix1)
					else scrollDeck(iChoix2)
					end;
				end;
			end;
		end;
		sdl_renderpresent(sdlrenderer);
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

