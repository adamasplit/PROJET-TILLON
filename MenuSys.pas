unit MenuSys;


interface

uses SDL2,coeur,eventsys,memgraph,animationSys,combatlib,mapsys;

//Image
	var combat_bg,menuBook,bgImage,characterImage,cardsImage : TImage;
	menuBookAnim : TAnimation;

procedure AfficherTout();

procedure victoire(var statsJ:TStats);

procedure RenderParallaxMenu(bgImage,characterImage,cardsImage : TImage);

implementation



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
    sceneActive:='Map'
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

procedure victoire(var statsJ:TStats); //censé contenir le choix+obtention d'une carte après un combat (voire d'une relique, pour plus tard)
var btn:array[1..3] of TButtonGroup;i:Integer;
begin
	//indiceMusiqueJouee:=14; quand cette musique existera
    sceneActive:='victoire';
    for i:=1 to 3 do
        begin
	    btn[i].carte:=cartes[i]; //###c'est cette partie qui est à remplacer pour déterminer les cartes que l'on peut obtenir
	    InitButtonGroup(btn[i],200+300*(i-1),200,128,128,btn[i].carte.dir,' ',nil);
        btn[i].procCarte:=@acquisitionCarte;
        btn[i].parametresSpeciaux:=1;
        end;
	while sceneActive='victoire' do
	begin
        SDL_PumpEvents();
        SDL_Delay(10);
            for i:=1 to 3 do
                RenderButtonGroup(btn[i]);
            SDL_RenderPresent(sdlRenderer);
            while SDL_PollEvent(EventSystem) = 1 do
            begin
                case EventSystem^.type_ of
                SDL_MOUSEBUTTONDOWN:
                    for i:=1 to 3 do
                    begin
                        OnMouseClick(btn[i], EventSystem^.motion.x, EventSystem^.motion.y);
                        HandleButtonClickCarte(btn[i], EventSystem^.motion.x, EventSystem^.motion.y,btn[i].carte,statsJ);
                    end;
                end;
            end;
	    end;
        choixSalle;
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