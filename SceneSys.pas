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

var UpdateTimeTuto : UInt32; indiceTuto:Integer;

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







procedure InitDialogues;
begin

	
end;

// Updates des Scenes

procedure ActualiserJeu(boss:Boolean);
var faucheuse : TObjet;i:Integer;
	begin
		randomize();
		scenePrec:='Jeu';
		SDL_PumpEvents;
		afficherTout;
		MAJCollisions();
		UpdateAnimations();
		UpdateAttaques();
		UpdateDamagePopUps;
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
		if (Lobjets[0].stats.vie <= 0) then 
		begin
			DeclencherFondu(True, 3000);
			arretMus(1000);
			ajoutObjet(faucheuse);
			CreateRawImage(Lobjets[High(LObjets)].image,1200,Lobjets[0].image.rect.y-50,200,200,'Sprites\Game\death\death_walking_1.bmp');
			InitAnimation(Lobjets[High(LObjets)].anim,'death','walking',10,True);
			SceneActive := 'mortJoueur';
		end;
		if statsJoueur.avancement = 2 then
			begin
			if (sdl_getTicks-UpdateTimeTuto>3500) then
				begin
				UpdateTimeTuto:=sdl_getTicks;
				indiceTuto:=indiceTuto+1;
				if indiceTuto>4 then indiceTuto:=1;
				end;
			//RenderText(TexteTutos[indiceTuto]);
			end;
		if vagueFinie then ajoutVague;
		if combatFini then 
			victoire(statsJoueur,boss);
		
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
			//RenderButtonGroup(boutons[10]);
			end;
	end;

//Initialisations



procedure retourMenu;
begin
	InitMenuPrincipal;
	direction_menu;
end;
procedure InitGameOver();
begin
	initButtonGroup(boutons[1],1080-540-270,200,540,180,'Sprites/Menu/button1.bmp','Menu principal',@retourmenu);
end;

procedure OnPlayerDeath(var son:Boolean);
var hasDeath : Boolean;
var i : Integer;
begin
mix_pauseMusic;
afficherTout;
	//if (Lobjets[High(LObjets)].image.rect.x = 1100) then indiceMusiqueJouee:=32;
	if (Lobjets[High(LObjets)].image.rect.x > Lobjets[0].image.rect.x + 60) then
		begin
			Lobjets[High(LObjets)].image.rect.x -= 1;
			UpdateAnimation(Lobjets[High(LObjets)].anim,Lobjets[High(LObjets)].image);
		end
		else
		begin
			if (Lobjets[High(LObjets)].anim.etat = 'walking') then 
				begin
				InitAnimation(Lobjets[High(LObjets)].anim,'death','reap',21,False);
				son:=False;
				end;
			if (not son) and (Lobjets[High(LObjets)].anim.etat = 'reap') and (LObjets[High(LObjets)].anim.currentFrame=5) and (LObjets[HIgh(LObjets)].anim.lastUpdateTime-SDL_GetTicks<=0) then
				begin
				jouerSonEff('mort');
				son:=True;
				end;
			UpdateAnimation(Lobjets[High(LObjets)].anim,Lobjets[High(LObjets)].image);
			if animFinie(Lobjets[High(LObjets)].anim) then
			begin
				hasDeath:=False;
				for i:=1 to Lobjets[0].stats.tailleCollection do 
        			if (not hasDeath) and (Lobjets[0].stats.collection[i].numero = 13) then
						begin
							supprimerCarte(Lobjets[0].stats, 13);
							jouerSon('SFX\Effets\mort.wav');
							sceneActive:='Jeu';
							DeclencherFondu(false, 500);
							Lobjets[0].stats.vie := 20;
							hasDeath := True;
							supprimeObjet(Lobjets[High(LObjets)]);
							writeln('objet suprr');
							mix_resumeMusic();
							end;
				if not(hasDeath) then
					begin
					//jouerSon('SFX\Effets\mort.wav');
					DeclencherFondu(true,3000);
					sceneActive:='MortFondu';
					for i:=1 to 300 do
						begin
						EffetDeFondu;
						sdl_delay(10);
						sdl_renderpresent(sdlrenderer);
						end;
					DeclencherFondu(False, 5000);
					indiceMusiqueJouee:=46;
					supprimeObjet(Lobjets[High(LObjets)]);
					sceneActive := 'GameOver';
					initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450,1080,350,extractionTexte('GAMEOVER_'+intToSTr(random(5)+1)),40);
					InitGameOver();
				end;
			end;
		end;
		autoMusique(indiceMusiqueJouee);
		//writeln('objet : ',High(LObjets));
end;

procedure GameOver();
begin
	
	drawrect(black_color,255,0,0,WINDOWWIDTH,windowHeight);
	renderButtonGroup(boutons[1]);
	UpdateDialogueBox(dialogues[2]);
	EffetDeFondu;
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

procedure HandleButtonClickRelique(var button: TButtonGroup; x, y: Integer;rel:Integer;var stats:TStats);
begin
  if (x >= button.image.rect.x) and (x <= button.image.rect.x + button.image.rect.w) and
     (y >= button.image.rect.y) and (y <= button.image.rect.y + button.image.rect.h) then
  begin
    if Assigned(button.procCarte) then
    begin
        writeln('procédure spéciale en cours');
		button.procRel(rel,Stats);
    end;
  end;
end;

procedure actualiserIntro(var updateTime:UInt32;var i:Integer);
var delai,j:Integer;
begin
	renderRawImage(fond,false);
	effetDeFondu;
	case i of
		3,11,12,13,4,8:delai:=7000;
		1,2:delai:=3000;
		else delai:=4000;
		end;
	if (i<>8) and (i<>4) then
		updateDialogueBox(dialogues[1])
	else
		begin
		updateDialogueBox(dialogues[2]);
		updateDialogueBox(dialogues[3]);
		end;
	if (sdl_getTicks-updateTime>delai) then
		begin
		DeclencherFondu(True,2000);
		for j:=1 to 200 do
			begin
			sdl_delay(10);
			autoMusique(indiceMusiqueJouee);
			renderRawImage(fond,false);
			if (i<>8) and (i<>4) then
				updateDialogueBox(dialogues[1]);
			EffetDeFondu;
			
			sdl_renderpresent(sdlrenderer);
			end;
		DeclencherFondu(False,2000);
		i:=i+1;
		if i=15 then
			sceneActive:='Menu'
		else
			begin
			case i of
			4,8:begin
				supprimeDialogue(2);
				supprimeDialogue(3);
				end
			else supprimeDialogue(1);
			end;
			sdl_destroytexture(fond.imgtexture);
			sdl_freeSurface(fond.imgsurface);
			createRawImage(fond,fond.rect.x,fond.rect.y,fond.rect.w,fond.rect.h,StringToPChar('Sprites/Intro/illustrations_intro_'+intToSTR(i)+'.bmp'));
			updateTime:=sdl_getTicks;
			end;
		end;
end;

procedure Intro;
var updateTime:UInt32;indice:Integer;
begin
	sceneActive:='Intro';
	updateTime:=sdl_getTicks;
	InitDialogueBox(dialogues[1],nil,nil,0,windowHeight div 3 + 250,windowWidth+200,300,extractionTexte('INTRO_1'),30);
	InitDialogueBox(dialogues[2],nil,nil,-50,windowHeight div 3 + 250,windowWidth div 3+250,300,'',30);
	InitDialogueBox(dialogues[3],nil,nil,windowWidth div 2-100,windowHeight div 3 + 250,windowWidth div 3+250,300,'',30);
	for indice:=2 to 14 do
		if (indice<>4) and (indice<>8) then ajoutDialogue(nil,extractionTexte('INTRO_'+intToSTR(indice)))
			else 
				begin
				ajoutDialogue(nil,extractionTexte('INTRO_'+intToSTR(indice)+'_1'));
				ajoutDialogue(nil,extractionTexte('INTRO_'+intToSTR(indice)+'_2'));
				end;
	indice:=1;
	black_color.r:=255;black_color.b:=255;black_color.g:=255;
	indiceMusiquePrec:=0;
	indiceMusiqueJouee:=0;
	autoMusique(indiceMusiqueJouee);
	MusiqueJouee:=mix_loadMUS(OST[0].dir);
	mix_playmusic(musiqueJouee,0);
	Mix_VolumeMusic(40);
	createRawImage(fond,120,0,814,530,'Sprites/Intro/illustrations_intro_1.bmp');
	while sceneActive='Intro' do
	begin
		sdl_renderclear(sdlrenderer);
		sdl_delay(10);
		actualiserIntro(updateTime,indice);
		sdl_renderpresent(sdlrenderer);
		while SDL_PollEvent(EventSystem)=1 do
			if EventSystem^.type_=SDL_mousebuttondown then
				sceneActive:='Menu'
	end;
	while high(queueDialogues)>-1 do
		supprimeDialogue(1);
end;



procedure GameUpdate;
var i:Integer;son,boss:Boolean;cardHover:Array [1..3] of Boolean;
begin
   while True do
  begin
  sdl_delay(10);
  sdl_renderclear(sdlRenderer);
  autoMusique(indiceMusiqueJouee);
	case SceneActive of
		'Credits':Credits;
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
		boss:=(high(LObjets)>=1) and (LObjets[1].stats.boss);
		ActualiserJeu(boss);
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
		'Leo_Menu':
		begin
		actualiserSalleLeo;
		end;
		'Oph_Menu':
		begin
		actualiserSalleLeo;
		end;
		'Hreposrisque_Menu' : actualiserReposRisque;
		'NouvellePartieIntro': NouvellePartieIntro;
		'victoire':
			begin
			RenderRawImage(fond,False);
			//InitDecor;
			for i:=1 to 3 do
				begin
				RenderButtonGroup(boutons[i]);
				OnMouseHover(boutons[i],getMouseX,getMouseY,'SFX\cardHover.wav', cardHover[i]);
				if cardHover[i] then 
					begin
						cardHover[i] := False;
						if boutons[i].parametresSpeciaux=4 then
							initDialogueBox(dialogues[1],nil,nil,0,350,1080,450,extractionTexte('DESC_REL_'+intToSTr(boutons[i].relique)),20)
						else
							initDialogueBox(dialogues[1],nil,nil,0,350,1080,450,extractionTexte('DESC_CAR_'+intToSTr(boutons[i].carte.numero)),20);
					end;
				end;
			UpdateDialogueBox(dialogues[1])
			end;
		'mortJoueur': OnPlayerDeath(son);
		'feuCamp':actualiserFeuCamp;
		'defausse':actualiserDefausse;
		'GameOver': GameOver;
		'Event':
		begin
		UpdateDialogueBox(dialogues[1]);
		end;
  		'Cutscene':
		begin
		affichertout;
		UpdateDialogueBox(dialogues[2]);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		if (LObjets[1].anim.etat<>'apparition') then
			updateanimation(LObjets[1].anim,LObjets[1].image);
		
		if LObjets[1].anim.objectName='Béhémoth' then fond.rect.x:=88-4+random(9);
		while (SDL_PollEvent( EventSystem ) = 1) do
    		begin
      			case EventSystem^.type_ of
					SDL_mousebuttondown:if (dialogues[2].complete) then begin
						if high(queueDialogues)>-1 then
							supprimeDialogue(2)
						else begin
							if (LObjets[1].anim.objectName='Leo_Transe') and (LObjets[1].anim.etat='mort') then victoire(statsJoueur,23)
							else
								sceneActive:='Jeu';
							if LObjets[1].anim.objectName='Béhémoth' then begin
							indiceMusiqueJouee:=13;
							mix_resumeMusic;
							end
							end;
						end
						 else dialogues[2].LetterDelay:=0;
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
					SDL_mousebuttondown:if dialogues[2].letterdelay=0 then begin 
						jouerSonEnn('dragon3');
						InitAnimation(LObjets[1].anim,LObjets[1].anim.objectName,'mort',LObjets[1].stats.nbFramesMort,False);
						sceneActive:='Jeu';
						end
						else
							dialogues[2].LetterDelay:=0;
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
					SDLK_ESCAPE : begin
						if sceneActive='Event' then activationEvent(sceneSuiv)
						else if sceneActive<>'Menu' then menuEnJeu;
						end;
					SDLK_SPACE:begin
						leMonde:=not(leMonde);
						LObjets[0].stats.compteurLeMonde:=100;
						updateTimeMonde:=sdl_getTicks;
						end;
					SDLK_O:LOBjets[0].stats.multiplicateurMana:=LOBjets[0].stats.multiplicateurMana+10;
					SDLK_H : choixSalle();
					SDLK_F2:begin
						statsJoueur.force:=statsJoueur.force+1;
						LObjets[0].stats.force:=LObjets[0].stats.force+1;
						LObjets[0].stats.multiplicateurDegat:=LObjets[0].stats.multiplicateurDegat+10;
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
				'Event':if (dialogues[1].complete) then 
					begin
						if high(queueDialogues)>-1 then
							supprimeDialogue(1)
						else 
							activationEvent(sceneSuiv);
						end
						 else dialogues[1].LetterDelay:=0;
				'Credits':begin OnMouseClick(button_retour_menu,GetMouseX,GetMouseY); HandleButtonClick(button_retour_menu.button, EventSystem^.motion.x, EventSystem^.motion.y) end;
				'Leo_Menu':for i:=1 to 3 do
					begin
					OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
                    HandleButtonClick(boutons[i].button, EventSystem^.motion.x, EventSystem^.motion.y);
					end;
				'Oph_Menu':for i:=2 to 3 do
					begin
					OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
                    HandleButtonClick(boutons[i].button, EventSystem^.motion.x, EventSystem^.motion.y);
					end;
				'Hreposrisque_Menu':for i:=1 to 2 do
					begin
					OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
                    HandleButtonClick(boutons[i].button, EventSystem^.motion.x, EventSystem^.motion.y);
					end;
				'Jeu': jouerCarte(LObjets[0].stats,LObjets[0].image.rect.x+(LObjets[0].image.rect.w div 2),LObjets[0].image.rect.y+(LObjets[0].image.rect.h div 2),iCarteChoisie);
				'defausse':begin
					OnMouseClick(boutons[3], EventSystem^.motion.x, EventSystem^.motion.y);
					HandleButtonClickCarte(boutons[3], EventSystem^.motion.x, EventSystem^.motion.y,statsjoueur.collection[ichoix1],statsJoueur);
					OnMouseClick(boutons[1], EventSystem^.motion.x, EventSystem^.motion.y);
                    HandleButtonClick(boutons[1].button, EventSystem^.motion.x, EventSystem^.motion.y);
					end;
				'map':begin 
					writeln('Mouse button pressed at (', EventSystem^.motion.x, ',', EventSystem^.motion.y, ')');
                    writeln(salles[1].image.button.rect.x);
					for i:=1 to 3 do
						begin
                        OnMouseClick(salles[i].image, EventSystem^.motion.x, EventSystem^.motion.y);
                        HandleButtonClick(salles[i].image.button, EventSystem^.motion.x, EventSystem^.motion.y);
						end
					end;
				'victoire':for i:=1 to 3 do
					begin
					OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
					if boutons[i].parametresSpeciaux=4 then
						HandleButtonClickRelique(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y,boutons[i].relique,statsJoueur)
					else
						HandleButtonClickCarte(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y,boutons[i].carte,statsJoueur);
					end;
				'GameOver':begin
					OnMouseClick(boutons[1], EventSystem^.motion.x, EventSystem^.motion.y);
						HandleButtonClick(boutons[1].button, EventSystem^.motion.x, EventSystem^.motion.y);
						end;
				'feuCamp':
					begin
						OnMouseClick(boutons[3], EventSystem^.motion.x, EventSystem^.motion.y);
						HandleButtonClick(boutons[3].button, EventSystem^.motion.x, EventSystem^.motion.y);
					for i:=1 to 2 do
						if not echangeFait then
						begin
						OnMouseClick(boutons[i], EventSystem^.motion.x, EventSystem^.motion.y);
						HandleButtonClick(boutons[i].button, EventSystem^.motion.x, EventSystem^.motion.y);
						end;
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
				if sceneActive='defausse' then
					scrolldeck(ichoix1,statsJoueur.tailleCollection);
				if sceneActive='Jeu' then 
					begin
  					if EventSystem^.wheel.y < 0 then icarteChoisie:=(isuiv(iCarteChoisie))
  					else icarteChoisie:=(iprec(iCarteChoisie));
					end;
				if (sceneActive='Deck') then
					begin
					if statsJoueur.relique<>0 then
						scrollDeck(ideck,statsJoueur.tailleCollection+1)
					else
						scrollDeck(ideck,statsJoueur.tailleCollection)
					end;
				if sceneActive='Bestiaire' then
					begin
					scrollBestiaire;
					end;
				if sceneActive='MenuShop' then
					begin
					if not etatChoix then scrolldeck(iChoix1,statsJoueur.tailleCollection)
					else scrollDeck(iChoix2,statsJoueur.tailleCollection)
					end;
				end;
			end;
		end;
		sdl_renderpresent(sdlrenderer);
	end;
end;

procedure StartGame;
begin
	new(EventSystem);
    IndiceMusiqueJouee:=0;
	updatetimemusique:=sdl_getticks;
    Mix_VolumeMusic(VOLUME_MUSIQUE);
	Intro;
	black_color.r:=0;black_color.b:=0;black_color.g:=0;
    SceneActive := 'Menu';
	sdlKeyboardState := SDL_GetKeyboardState(nil);
    InitMenuPrincipal;
    InitMenuEnJeu;
    InitCredits;
	initUICombat;
	initDecor;
	InitDialogues;
	InitTutorial;
	setlength(LObjets,1);
	writeln('essai d''actualisation...');
	DeclencherFondu(False, 3000);
    GameUpdate;
end;

begin
  WriteLn('SceneSys ready !');
end.

