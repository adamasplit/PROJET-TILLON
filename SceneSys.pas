unit Scenesys;

interface
uses
	AnimationSys,
	coeur,
	CollisionSys,
	CombatLib,
	EnemyLib,
	eventSys,
	fichierSys,
	mapSys,
	math,
	memgraph,
	MenuSys,
	SDL2,
	SDL2_mixer,
	SDL2_ttf,
	SonoSys,
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

procedure ActualiserJeu(boss:Boolean;enn:Integer);
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
		if leMonde and (sdl_getTicks-UpdateTimeMonde>(1500+min(LObjets[0].stats.compteurLeMonde,17)*500)) then
			begin
			leMonde:=False;
			end;
		if LObjets[0].stats.laMort and (sdl_getTicks-updateTimeMort>5000) then
			LObjets[0].stats.laMort:=False;
		RegenMana(LObjets[0].stats.lastUpdateTimeMana,LObjets[0].stats.mana,LObjets[0].stats.manaMax,LObjets[0].stats.relique,LObjets[0].stats.vie,LObjets[0].stats.multiplicateurMana);
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
			arretSons(100);
			ajoutObjet(faucheuse);
			CreateRawImage(Lobjets[High(LObjets)].image,1200,Lobjets[0].image.rect.y-50,200,200,'Sprites/Game/death/death_walking_1.bmp');
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
			RenderText(TexteTutos[indiceTuto]);
			end;
		if vagueFinie then ajoutVague;
		if combatFini then 
			victoire(statsJoueur,boss,enn);
		
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
			OnMouseHover(button_retour_menu,GetMouseX,GetMouseY);
			RenderButtonGroup(button_retour_menu);
			end;
		if (sdl_getTicks-UpdateTimeTuto>3500) then
				begin
				UpdateTimeTuto:=sdl_getTicks;
				indiceTuto:=indiceTuto+1;
				if indiceTuto>4 then indiceTuto:=1;
				end;
		RenderText(TexteTutosMenu[indiceTuto]);
	end;

//Initialisations

procedure InitGameOver();
begin
	initButtonGroup(boutons[1],1080-540-270,200,540,180,'Sprites/Menu/Button1.bmp','Menu principal',@retourmenu);
end;

procedure OnPlayerDeath(var son:Boolean);
var hasDeath,deathInDeck : Boolean;
var i,j : Integer;
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
							sceneActive:='Jeu';
							DeclencherFondu(false, 500);
							Lobjets[0].stats.vie := 1;
							hasDeath := True;
							supprimeObjet(Lobjets[High(LObjets)]);
							mix_resumeMusic();
						end;
				deathInDeck:=False;
				if hasDeath then
					begin
					Mix_VolumeMusic(VOLUME_MUSIQUE);
					UpdateTimeMort:=SDL_GetTicks+1000;
					LObjets[0].stats.laMort:=True;
					for i:=0 to high(LObjets[0].stats.deck^) do
						if (not deathInDeck) and (LObjets[0].stats.deck^[i].numero=13) then
							begin
							deathInDeck:=True;
							for j:=i to high(LObjets[0].stats.deck^)-1 do
								LObjets[0].stats.deck^[j]:=LObjets[0].stats.deck^[j+1];
							setlength(LObjets[0].stats.deck^,high(LObjets[0].stats.deck^));
							mix_resumeMusic();
							end;
					end;
				if not(hasDeath) then
					begin
					//jouerSon('SFX/Effets/mort.wav');
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
					initJoueur(False);
					sauvegarder(statsJoueur);
					supprimeObjet(Lobjets[High(LObjets)]);
					sceneActive := 'GameOver';
					initDialogueBox(dialogues[2],'Sprites/Menu/Button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450,1080,350,extractionTexte('GAMEOVER_'+intToSTr(random(5)+1)),40);
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
        //writeln('procédure spéciale en cours');
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
        //writeln('procédure spéciale en cours');
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

procedure Intro(var indice:Integer;var updateTime:UINT32);
var i:Integer;
begin
	sceneActive:='Intro';
	updateTime:=sdl_getTicks;
	InitDialogueBox(dialogues[1],nil,nil,0,windowHeight div 3 + 250,windowWidth+200,300,extractionTexte('INTRO_1'),30);
	InitDialogueBox(dialogues[2],nil,nil,-50,windowHeight div 3 + 250,windowWidth div 3+250,300,'',30);
	InitDialogueBox(dialogues[3],nil,nil,windowWidth div 2-100,windowHeight div 3 + 250,windowWidth div 3+250,300,'',30);
	for i:=2 to 14 do
		if (i<>4) and (i<>8) then ajoutDialogue(nil,extractionTexte('INTRO_'+intToSTR(i)))
			else 
				begin
				ajoutDialogue(nil,extractionTexte('INTRO_'+intToSTR(i)+'_1'));
				ajoutDialogue(nil,extractionTexte('INTRO_'+intToSTR(i)+'_2'));
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
end;



procedure GameUpdate;
var updateTime:UInt32;indice:Integer;
var i:Integer;son,boss:Boolean;ennemiActuel:Integer;cardHover:Array [1..3] of Boolean;
begin
   while not QUITGAME do
  begin
  sdl_delay(10);
  sdl_renderclear(sdlRenderer);
  autoMusique(indiceMusiqueJouee);
	case SceneActive of
		'Intro':begin
			ActualiserIntro(updateTime,indice);
			while SDL_PollEvent(EventSystem)=1 do
				if EventSystem^.type_=SDL_mousebuttondown then
					sceneActive:='Menu';
			if sceneActive<>'Intro' then 
				begin
				while high(queueDialogues)>-1 do
					supprimeDialogue(1);
				initUICombat;
				ClearScreen;
				black_color.r:=0;black_color.b:=0;black_color.g:=0;
				sdlKeyboardState := SDL_GetKeyboardState(nil);
				InitMenuPrincipal;
				InitMenuEnJeu;
				InitCredits;
				//initDecor;
				InitDialogues;
				InitTutorial;
				indiceTuto:=1;
				setlength(LObjets,1);
				//writeln('essai d''actualisation...');
				DeclencherFondu(False, 1000);
				end;
			end;
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
		if boss then ennemiActuel:=LObjets[1].stats.numero;
		ActualiserJeu(boss,ennemiActuel);
		MouvementJoueur(LObjets[0]);
		end;
  		'MenuEnJeu': 
  		begin
		ActualiserMenuEnJeu;
		effetDeFondu;
		end;
  		'Menu': 
  		begin
		direction_menu;
		effetDeFondu;
		end;
		'map':
		begin
        actualiserMap;
		effetDeFondu;
		ennemiActuel:=0;
    	end;
		'Fondu':
		begin
		actualiserMap;
		effetDeFondu;
		zoom;
		if sdl_getTicks-timeDebutFondu>=dureeFondu then
			begin
			activationEvent(evenementSuiv);
			//indiceMusiqueJouee:=indiceMusiqueSuiv;
			end;
		end;
		'marchand':
		begin
		actualiserMarchand;
		effetDeFondu;
		end;
		'MenuShop':
		begin
		actualiserEchange;
		end;
		'DD':actualiserDD;
		'US':actualiserUS;
		'DDShop','DShop':actualiserEchangeDD;
		'Leo_Menu':
		begin
		actualiserSalleLeo;
		effetDeFondu;
		end;
		'Oph_Menu':
		begin
		actualiserSalleLeo;
		effetDeFondu;
		end;
		'Hreposrisque_Menu' : begin
			effetDeFondu;
			actualiserReposRisque;
			end;
		'NouvellePartieIntro': NouvellePartieIntro;
		'victoire':
			begin
			RenderRawImage(fond,False);
			//InitDecor;
			for i:=1 to 3 do
				begin
				RenderButtonGroup(boutons[i]);
				OnMouseHover(boutons[i],getMouseX,getMouseY,'SFX/cardHover.wav', cardHover[i]);
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
		'feuCamp':begin
		actualiserFeuCamp;
		effetDeFondu;
		end;
		'defausse':actualiserDefausse;
		'GameOver': GameOver;
		'Event':
		begin
		if dialogues[1].BackgroundImage.directory=nil then 
			begin
			black_color.r := 255; 
    		black_color.g := 255; 
    		black_color.b := 255;
			end;
		drawrect(bk_col,255,0,0,windowWidth,windowHeight);
		UpdateDialogueBox(dialogues[1]);
		end;
  		'Cutscene':
		begin
		affichertout;
		UpdateDialogueBox(dialogues[2]);
		if (LObjets[0].anim.etat<>'idle') then
			initAnimation(LObjets[0].anim,LObjets[0].anim.objectName,'idle',12,True);
		updateanimation(LObjets[0].anim,LObjets[0].image);
		if (LObjets[1].anim.etat<>'apparition') and (LObjets[1].anim.etat<>'mort') then
			updateanimation(LObjets[1].anim,LObjets[1].image);
		
		if LObjets[1].anim.objectName='Béhémoth' then fond.rect.x:=88-4+random(9);
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
					SDLK_1:icarteChoisie:=0;
					SDLK_2:icarteChoisie:=1;
					SDLK_3:icarteChoisie:=2;
					SDLK_ESCAPE : begin
						if sceneActive='Event' then activationEvent(sceneSuiv)
						else if sceneActive='Cutscene' then 
							begin
							if (LObjets[1].anim.objectName='Leo_Transe') and (LObjets[1].anim.etat='mort') then victoire(statsJoueur,23)
							else
								sceneActive:='Jeu';
							while high(queueDialogues)>-1 do
								supprimeDialogue(1);
							if LObjets[1].anim.objectName='Béhémoth' then begin
							indiceMusiqueJouee:=13;
							mix_resumeMusic;
							end
							end
						else if (sceneActive<>'Menu') and (sceneActive<>'Credits') and (sceneActive<>'Fondu') and (sceneActive<>'mortJoueur') and (sceneActive<>'GameOver') then menuEnJeu;
						end;
					SDLK_SPACE:begin
						if leMonde then leMonde:=False;
						//LObjets[0].stats.compteurLeMonde:=100;
						//updateTimeMonde:=sdl_getTicks;
						end;
					{SDLK_M:writeln(LObjets[0].stats.multiplicateurMana);
					SDLK_UP:  LObjets[0].stats.vie := LObjets[0].stats.vie +10;
					SDLK_DOWN: LObjets[0].stats.vie := LObjets[0].stats.vie-10;
					SDLK_O:LOBjets[0].stats.multiplicateurMana:=LOBjets[0].stats.multiplicateurMana+100;
					SDLK_H : choixSalle();
					SDLK_F2:begin
						LObjets[0].stats.force:=LObjets[0].stats.force+1;
						LObjets[0].stats.multiplicateurDegat:=LObjets[0].stats.multiplicateurDegat+10;
						end;
					SDLK_F3:modeDebug:=not(modeDebug);
					SDLK_F4:for i:=1 to MAXENNEMIS do	statsJoueur.bestiaire[i]:=True;
					SDLK_F5:begin statsJoueur.tailleCollection:=28; for i:=1 to 28 do statsJoueur.collection[i]:=Cartes[i]; end;
					SDLK_F6:
						begin
						statsJoueur.multiplicateurSoin:=statsJoueur.multiplicateurSoin+(random(4)-2)*0.2;
						//writeln(statsJoueur.multiplicateurSoin);
						end;
					SDLK_F7:begin statsJoueur.tailleCollection:=28; for i:=1 to 28 do statsJoueur.collection[i]:=Cartes[27+i mod 2]; end;
					SDLK_F8:for i:=0 to high(LObjets[0].stats.deck^) do LObjets[0].stats.deck^[i]:=Cartes[12];
					SDLK_F9:statsJoueur.avancement:=MAXSALLES;
					SDLK_F10:statsJoueur.multiplicateurSoin:=1;}
        		end;
      		end;
			
			SDL_mousemotion: 
				begin
				getMouseX;getMouseY;
				end;
			SDL_mousebuttondown : 
				begin 
				case sceneActive of
				'Cutscene':if (dialogues[2].complete) then begin
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
					//writeln('Mouse button pressed at (', EventSystem^.motion.x, ',', EventSystem^.motion.y, ')');
                    //writeln(salles[1].image.button.rect.x);
					for i:=1 to 3 do
						begin
                        OnMouseClick(salles[i].image, EventSystem^.motion.x, EventSystem^.motion.y);
                        HandleButtonClickSalle(salles[i].image,salles[i].evenement,i, EventSystem^.motion.x, EventSystem^.motion.y);
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
				'DD':
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
				'DDShop','DShop','US':begin
					OnMouseClick(boutons[1], EventSystem^.motion.x, EventSystem^.motion.y);
					HandleButtonClickRelique(boutons[4], EventSystem^.motion.x, EventSystem^.motion.y,0,statsJoueur);
					OnMouseClick(boutons[4], EventSystem^.motion.x, EventSystem^.motion.y);
					HandleButtonClick(boutons[1].button, EventSystem^.motion.x, EventSystem^.motion.y);
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
					for i:=1 to 6 do
					begin
					OnMouseClick(boutons[i],EventSystem^.motion.x,EventSystem^.motion.y);
					HandleButtonClick(boutons[i].button,EventSystem^.motion.x,EventSystem^.motion.y);
					end;
					OnMouseClick(button_help,EventSystem^.motion.x,EventSystem^.motion.y);
					HandleButtonClick(button_help.button,EventSystem^.motion.x,EventSystem^.motion.y);
				end;
				if sceneActive='MenuEnJeu' then
				begin
				if boutons[8].button.estVisible then
					HandleButtonClick(boutons[8].button,EventSystem^.motion.x,EventSystem^.motion.y);
				if boutons[9].button.estVisible then
					HandleButtonClick(boutons[9].button,EventSystem^.motion.x,EventSystem^.motion.y);
				if button_retour_menu.button.estVisible then
					HandleButtonClick(button_retour_menu.button,EventSystem^.motion.x,EventSystem^.motion.y);
				end;
				end;
			SDL_QUITEV:  QUITGAME:=True; 
			SDL_MOUSEWHEEL:begin
				if sceneActive='defausse' then
					scrolldeck(ichoix1,statsJoueur.tailleCollection);
				if ((sceneActive='DShop') and echangeFait) or (sceneActive='US') then
					begin
					scrolldeck(ichoix2,statsJoueur.tailleCollection);
					end;
				if sceneActive='Jeu' then 
					begin
  					if EventSystem^.wheel.y < 0 then icarteChoisie:=(isuiv(iCarteChoisie))
  					else icarteChoisie:=(iprec(iCarteChoisie));
					end;
				if (sceneActive='Deck') then
					begin
					if statsJoueur.relique<>0 then
						scrollDeck(ideck,statsJoueur.tailleCollection+2)
					else
						scrollDeck(ideck,statsJoueur.tailleCollection+1)
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
var lastUpdateTime:UInt32;indice:Integer;
begin
	new(EventSystem);
    IndiceMusiqueJouee:=0;
	updatetimemusique:=sdl_getticks;
    Mix_VolumeMusic(VOLUME_MUSIQUE);
	Intro(indice,lastUpdateTime);
    GameUpdate;
end;

begin
	QUITGAME := False;
  //WriteLn('SceneSys ready !');
end.

