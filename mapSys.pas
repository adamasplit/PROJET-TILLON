unit mapSys;

interface
uses
    AnimationSys,
    coeur,
    combatlib,
    EnemyLib,
    eventsys,
    math,
    memgraph,
    SDL2,
    sonoSys,
    SysUtils;
var imgs0,imgs1,imgs2,imgs3:TButtonGroup;
var salleChoisie:TSalle;
var iDeck,iChoix1,iChoix2:Integer;
var etatChoix:Boolean;
echangeFait:Boolean;

CONST 
windowHeight=720;windowWidth=1080;
      Y1=(windowHeight div 2)+(windowHeight div 4)-64;           
      Y2=(windowHeight div 2)-64;
      Y3=(windowHeight div 2)-(windowHeight div 4)-64;
      X1=(windowWidth  div 2) - (windowWidth div 2)+128;
      X2=(windowWidth  div 2) + (windowWidth div 4);

procedure generationChoix(var salle1,salle2,salle3:TSalle);
procedure affichageSalles(var salle1,salle2,salle3:TSalle);
procedure choixSalle();
procedure actualiserMap();
procedure actualiserMarchand();
procedure actualiserEchange();
procedure choisirEnnemis;
procedure LancementSalleHasard;
procedure LancementSalleBoss;
procedure LancementSalleMarchand;
procedure LancementSalleCamp;
procedure scrollDeck(var i:Integer);
procedure HandleButtonClickEch(var button: TButtonGroup; x, y: Integer;carte1,carte2:TCarte;var stats:TStats);
function Highlight(var btnGroup: TButtonGroup; x, y: Integer):Boolean;
implementation

var entree:Boolean;
var imgCar1,imgCar2:TImage;

procedure generationChoix(var salle1,salle2,salle3:TSalle);
var alea:Integer;
begin
    writeln('Actuellement en salle : ',statsJoueur.avancement);
    if ((statsJoueur.avancement mod 5) = 0) then 
        begin
            salle1.evenement:=rien;
            salle2.evenement:=boss;
            salle3.evenement:=rien
        end
    else begin
        randomize();
        alea:=random(2)+1;
        case alea of
            1:begin
                salle1.evenement:=combat;
                salle2.evenement:=evenements(random(3));
                salle3.evenement:=evenements(random(3))
                end;
            2:begin
                salle2.evenement:=combat;
                salle1.evenement:=evenements(random(3));
                salle3.evenement:=evenements(random(3))
                end;
            3:begin
                salle3.evenement:=combat;
                salle1.evenement:=evenements(random(3));
                salle2.evenement:=evenements(random(3))
                end
            end
        end
end;

procedure choisirEnnemis;
var j,alea : integer;
begin
    {if high(ennemis)>1 then
        repeat
            sdl_freeSurface(ennemis[high(ennemis)].image.imgSurface);
            SDL_DestroyTexture(ennemis[high(ennemis)].image.imgTexture);
            setlength(ennemis,high(ennemis));
        until high(ennemis)=0;}
    writeln('liste ennemis vide');
    initStatsCombat(statsJoueur,LObjets[0].stats);
    if high(LOBjets)>0 then repeat supprimeObjet(LObjets[1]) until high(LObjets)=0;
    writeln('LObjets vidée');
    vagueFinie:=True;
    combatFini:=False;
    randomize;
    indiceMusiqueJouee:=(statsJoueur.avancement div 3)+2;

    //###partie à modifier : choix des ennemis et de leur nombre
    setlength(ennemis,statsJoueur.avancement+1);
    for j:=1 to statsJoueur.avancement do
        begin
        alea:=random(28)+1;
        if (alea=20) or (alea=21) then
            ennemis[j]:=templatesEnnemis[30]
        else
            ennemis[j]:=templatesEnnemis[4];
        writeln('élément ',j,' de ennemis: ',ennemis[j].anim.objectName);
        end;
    writeln('ennemis choisis');

end;

procedure LancementSalleCombat();
begin
writeln('Lancement de salle Combat');
choisirEnnemis;
statsJoueur.avancement := statsJoueur.avancement+1;
ClearScreen;
SDL_RenderClear(sdlRenderer);
writeln('choix des ennemis...');

SceneActive := 'Jeu';
//indiceMusiqueJouee:=random(4)+2;
end;

procedure LancementSalleHasard;
begin
writeln('Lancement de salle Hasard');
choisirEnnemis;
statsJoueur.avancement := statsJoueur.avancement+1;
ClearScreen;
SDL_RenderClear(sdlRenderer);
SceneActive := 'Jeu';

end;

procedure LancementSalleBoss;
var j : integer;
begin
    writeln('Lancement de salle Boss');
    statsJoueur.avancement := statsJoueur.avancement+1;
    ClearScreen;
    SDL_RenderClear(sdlRenderer);
    SceneActive := 'Jeu';
    vagueFinie:=False;
    setlength(LObjets,2);
    for j:=1 to 1 do
    begin
        randomize;  
        LObjets[j]:=TemplatesEnnemis[2];
    end;
    setlength(ennemis,3);
    ennemis[2]:=templatesEnnemis[19];
    ennemis[1]:=templatesEnnemis[20];
    writeln('ennemis choisis (boss)')
end;

procedure ajouterCarteAleatoireRarete(rarete : Trarete ; var stats : Tstats);
var rdm : integer;
begin
    randomize;
    case rarete of 
    commune :  
    begin
        rdm := 1 + random(6);

        case rdm of
        1: ajouterCarte(stats , 1);
        2: ajouterCarte(stats , 2);
        3: ajouterCarte(stats , 3);
        4: ajouterCarte(stats , 4);
        5: ajouterCarte(stats , 5);
        6: ajouterCarte(stats , 10);
        end;
    end;

    rare :
    begin
         rdm := 1 + random(7);

        case rdm of
        1: ajouterCarte(stats , 6);
        2: ajouterCarte(stats , 7);
        3: ajouterCarte(stats , 8);
        4: ajouterCarte(stats ,9);
        5: ajouterCarte(stats , 11);
        6: ajouterCarte(stats , 16);
        7: ajouterCarte(stats , 19);
        end;
    end;

    epique :
    begin
         rdm := 1 + random(6);

        case rdm of
        1: ajouterCarte(stats , 12);
        2: ajouterCarte(stats , 14);
        3: ajouterCarte(stats , 17);
        4: ajouterCarte(stats , 18);
        5: ajouterCarte(stats , 20);
        6: ajouterCarte(stats , 22);
        end;
    
    end;

    legendaire :
    begin
         rdm := 1 + random(3);

        case rdm of
        1: ajouterCarte(stats , 13);
        2: ajouterCarte(stats , 15);
        3: ajouterCarte(stats , 21);
        end;
    end;
    end;
end;


procedure trade(carte1, carte2 : TCarte ; Var stats : Tstats); //#### table de proba à finir
var rdm : Integer;
begin
    randomize;
    //C-C -> Commune:93% Rare:5% Epique:1% Legendaire:1%
    if (carte1.rarete = commune) AND (carte2.rarete = commune) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..93: ajouterCarteAleatoireRarete(commune, stats);
            94..98: ajouterCarteAleatoireRarete(rare, stats);
            99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //R-R -> Commune:1% Rare:93% Epique:5% Legendaire:1%
    else if (carte1.rarete = rare) AND (carte2.rarete = rare) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1: ajouterCarteAleatoireRarete(commune, stats);
            2..94: ajouterCarteAleatoireRarete(rare, stats);
            95..99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //E-E -> Commune:1% Rare:1% Epique:93% Legendaire:5%
    else if (carte1.rarete = epique) AND (carte2.rarete = epique) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1: ajouterCarteAleatoireRarete(commune, stats);
            2: ajouterCarteAleatoireRarete(rare, stats);
            3..95: ajouterCarteAleatoireRarete(epique, stats);
            96..100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //L-L -> Commune:1% Rare:1% Epique:1% Legendaire:97%
    else if (carte1.rarete = legendaire) AND (carte2.rarete = legendaire) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1: ajouterCarteAleatoireRarete(commune, stats);
            2: ajouterCarteAleatoireRarete(rare, stats);
            3: ajouterCarteAleatoireRarete(epique, stats);
            4..100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //C-R
    else if ((carte1.rarete = commune) AND (carte2.rarete = rare) OR (carte1.rarete = rare) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..60 : ajouterCarteAleatoireRarete(commune, stats);
            61..98: ajouterCarteAleatoireRarete(rare, stats);
            99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //C-E
    else if ((carte1.rarete = commune) AND (carte2.rarete = epique) OR (carte1.rarete = epique) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..50: ajouterCarteAleatoireRarete(commune, stats);
            51..79: ajouterCarteAleatoireRarete(rare, stats);
            80..99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //C-L
    else if ((carte1.rarete = commune) AND (carte2.rarete = legendaire) OR (carte1.rarete = legendaire) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20: ajouterCarteAleatoireRarete(commune, stats);
            21..79: ajouterCarteAleatoireRarete(rare, stats);
            80..99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //R-E
    else if ((carte1.rarete = rare) AND (carte2.rarete = epique) OR (carte1.rarete = epique) AND (carte2.rarete = rare)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20: ajouterCarteAleatoireRarete(commune, stats);
            21..79: ajouterCarteAleatoireRarete(rare, stats);
            80..99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //R-L
    else if ((carte1.rarete = rare) AND (carte2.rarete = legendaire) OR (carte1.rarete = legendaire) AND (carte2.rarete = rare)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20: ajouterCarteAleatoireRarete(commune, stats);
            21..79: ajouterCarteAleatoireRarete(rare, stats);
            80..99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end

    //E-L
    else if ((carte1.rarete = epique) AND (carte2.rarete = legendaire) OR (carte1.rarete = legendaire) AND (carte2.rarete = epique)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20: ajouterCarteAleatoireRarete(commune, stats);
            21..79: ajouterCarteAleatoireRarete(rare, stats);
            80..99: ajouterCarteAleatoireRarete(epique, stats);
            100: ajouterCarteAleatoireRarete(legendaire, stats);
        end;
    end;

    
    supprimerCarte(stats,carte1.numero);
    supprimerCarte(stats,carte2.numero);
    echangeFait:=True;
    LancementSalleMarchand;
end;

procedure scrollDeck(var i:Integer);

begin
	if EventSystem^.wheel.y<0 then
		if i>=statsJoueur.tailleCollection then
			i:=1
		else
			i:=i+1
	else
		if i<=2 then
			i:=statsJoueur.tailleCollection
		else
			i:=i-1;
end;


function Highlight(var btnGroup: TButtonGroup; x, y: Integer):Boolean;
begin
  // Vérifier si la souris est sur le bouton
  if (x >= btnGroup.image.rect.x) and (x <= btnGroup.image.rect.x + btnGroup.image.rect.w) and
     (y >= btnGroup.image.rect.y) and (y <= btnGroup.image.rect.y + btnGroup.image.rect.h) then
  begin
    drawRect(yellowCol,255,btnGroup.image.rect.x-20,btnGroup.image.rect.y-20,btnGroup.image.rect.w+40,btnGroup.image.rect.h+40);
    highlight:=True;
  end
    else Highlight:=False;

end;

procedure HandleButtonClickEch(var button: TButtonGroup; x, y: Integer;carte1,carte2:TCarte;var stats:TStats);
begin
  if (x >= button.image.rect.x) and (x <= button.image.rect.x + button.image.rect.w) and
     (y >= button.image.rect.y) and (y <= button.image.rect.y + button.image.rect.h) then
  begin
    if Assigned(button.procEch) then
    begin
        writeln('procédure spéciale en cours');
		button.procEch(carte1,carte2,stats);
    end;
  end;
end;

procedure actualiserEchange();
begin
    renderRawImage(fond,false);


    highlight(boutons[2],getmousex,getmousey);highlight(boutons[3],getmousex,getmousey);
    sdl_destroytexture(imgCar1.imgTexture);
    sdl_freeSurface(imgCar1.imgSurface);
    sdl_destroytexture(imgCar2.imgTexture);
    sdl_freeSurface(imgCar2.imgSurface);
    //writeln(ichoix1);
    renderButtonGroup(boutons[1]);
    renderButtonGroup(boutons[2]);
    renderButtonGroup(boutons[3]);
    if ichoix1<>ichoix2 then
        renderButtonGroup(boutons[4]);
    createRawImage(imgCar1,boutons[2].image.rect.x,boutons[2].image.rect.y,boutons[2].image.rect.w,boutons[2].image.rect.h,StringToPChar('Sprites/Cartes/carte'+intToStr(statsJoueur.collection[iChoix1].numero)+'.bmp'));
    renderRawImage(imgCar1,False);
    createRawImage(imgCar2,boutons[3].image.rect.x,boutons[3].image.rect.y,boutons[3].image.rect.w,boutons[3].image.rect.h,StringToPChar('Sprites/Cartes/carte'+intToStr(statsJoueur.collection[iChoix2].numero)+'.bmp'));
    renderRawImage(imgCar2,False);
    
end;

procedure confirmer();
begin
    etatChoix:=not(etatChoix);
end;


procedure Echange;
begin
SceneActive := 'MenuShop';
ClearScreen;
etatchoix:=False;
iChoix1:=1;iChoix2:=2;
SDL_RenderClear(sdlRenderer);
InitButtonGroup(boutons[1],  415, 50, 250, 100, 'Sprites/Menu/button1.bmp','Annuler',@LancementSalleMarchand);
InitButtonGroup(boutons[2],  255, 250, 250, 250, 'Sprites/Menu/button1.bmp','X',@confirmer);
InitButtonGroup(boutons[3],  1080-255-250, 250, 250, 250, 'Sprites/Menu/button1.bmp','X',@confirmer);
InitButtonGroup(boutons[4],  415, 580, 250, 100, 'Sprites/Menu/button1.bmp','Echange',btnProc);
boutons[4].parametresSpeciaux:=3;boutons[4].procEch:=@trade;
end;

procedure LancementSalleMarchand; //###
begin
    sceneActive := 'marchand';
    indiceMusiqueJouee:=12;
    writeln('Lancement de salle Marchand');
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    if entree then
        begin
        statsJoueur.avancement := statsJoueur.avancement+1;
        entree:=False;
        end;
    if not echangeFait then
        InitButtonGroup(boutons[1],  415, 100, 250, 100, 'Sprites/Menu/button1.bmp','Marchandage',@Echange);
    InitButtonGroup(boutons[2],  440, 200, 200, 100, 'Sprites/Menu/button1.bmp','Discussion',btnproc);
    InitButtonGroup(boutons[3],  465, 300, 150, 100, 'Sprites/Menu/button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp',nil,0,450,1080,300,'aaa',10);
    
    
end;

procedure actualiserMarchand();
begin
    renderRawImage(fond,false);
    if not echangeFait then 
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        //HandleButtonClick(boutons[1].button,getmousex,getmousey);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[2],getMouseX,getMouseY);
    renderButtonGroup(boutons[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;




procedure LancementSalleCamp;
begin
writeln('Lancement de salle Camp');
statsJoueur.avancement := statsJoueur.avancement+1;
ClearScreen;
SDL_RenderClear(sdlRenderer);
SceneActive := 'Jeu';
choisirEnnemis;
end;

procedure affichageSalle(var salle:TSalle;x,y:integer);
var dir:PCHar;proc:ButtonProcedure;
begin
    case salle.evenement of //initialisation en fonction du type de salle
        hasard:begin
            dir:='Sprites/Menu/salle_hasard.bmp';
            proc:= @LancementSalleHasard;
            end;
        combat:begin
            dir:='Sprites/Menu/salle_combat.bmp';
            proc:= @LancementSalleCombat;
            end;
        boss:begin
            dir:='Sprites/Menu/salle_boss.bmp';
            proc:= @LancementSalleBoss;
            end;
        marchand:begin
            dir:='Sprites/Menu/salle_Marchand.bmp';
            proc:= @LancementSalleMarchand;
            end;
        camp:begin 
            dir:='Sprites/Menu/salle_camp.bmp';
            proc := @LancementSalleCamp;
            end;
        else begin
            dir:='Sprites/Menu/salle_rien.bmp';
            proc:= @OnButtonClickDebug;
            end
    end;
    writeln(dir);
    InitButtonGroup(salle.image,x,y,128,128,dir,' ',proc);
    RenderButtonGroup(salle.image);
end;

procedure affichageSalles(var salle1,salle2,salle3:TSalle);
var depart:TSalle;
begin
    depart.evenement:=rien;
    affichageSalle(depart,X1,Y2);
    affichageSalle(salle1,X2,Y1);
    affichageSalle(salle2,X2,Y2);
    affichageSalle(salle3,X2,Y3);
end;

procedure choixSalle();
    
begin
    entree:=true;
    combatFini:=False;
    echangeFait:=False;
    sdl_renderclear(sdlrenderer);
    SceneActive := 'map';
    ScenePrec:='map';
    writeln('Initializing rooms...');
    
    generationChoix(salles[1], salles[2], salles[3]);
    writeln('Displaying rooms');
    affichageSalles(salles[1], salles[2], salles[3]);
    
    writeln('Room choice started');
    new(EventSystem);
    
end;

procedure actualiserMap();
begin
    SDL_PumpEvents();
    RenderButtonGroup(salles[1].image);
    RenderButtonGroup(salles[2].image);
    RenderButtonGroup(salles[3].image);
    RenderButtonGroup(salles[1].image);
    RenderButtonGroup(salles[2].image);
    RenderButtonGroup(salles[3].image);
    RenderButtonGroup(salles[1].image);
    RenderButtonGroup(salles[2].image);
    RenderButtonGroup(salles[3].image);
end;





begin
statsJoueur.avancement:=1;
//
writeln('MapSys ready')
end.
