unit mapSys;

interface
uses
    AnimationSys,
    coeur,
    combatlib,
    EnemyLib,
    eventsys,
    fichierSys,
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
procedure actualiserSalleLeo;
procedure brulerCarte(carte:TCarte ; var stats : Tstats);
procedure actualiserFeuCamp;
procedure actualiserDefausse;
procedure choisirEnnemis;
procedure LancementSalleHasard;
procedure LancementSalleBoss;
procedure LancementSalleMarchand;
procedure LancementSalleCamp;
procedure scrollDeck(var i:Integer;imax:Integer);
procedure activationEvent(scene:String);
procedure HandleButtonClickEch(var button: TButtonGroup; x, y: Integer;carte1,carte2:TCarte;var stats:TStats);
function Highlight(var btnGroup: TButtonGroup; x, y: Integer):Boolean;
implementation

var entree:Boolean;
var numDialogue:Integer;
var imgCar1,imgCar2,imgCar3:TImage;

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
                salle2.evenement:=evenements(random(4));
                salle3.evenement:=evenements(random(4))
                end;
            2:begin
                salle2.evenement:=combat;
                salle1.evenement:=evenements(random(4));
                salle3.evenement:=evenements(random(4))
                end;
            3:begin
                salle3.evenement:=combat;
                salle1.evenement:=evenements(random(4));
                salle2.evenement:=evenements(random(4))
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
    initStatsCombat(statsJoueur,LObjets[0].stats);
    if high(LOBjets)>0 then repeat supprimeObjet(LObjets[1]) until high(LObjets)=0;
    vagueFinie:=True;
    combatFini:=False;
    randomize;
    indiceMusiqueJouee:=(statsJoueur.avancement div 3)+2;
    initDecor;

    //###partie à modifier : choix des ennemis et de leur nombre
    setlength(ennemis,statsJoueur.avancement+1);
    for j:=1 to statsJoueur.avancement do
        begin
        alea:=random(31)+1;
        if (alea=20) or (alea=21) then
            ennemis[j]:=templatesEnnemis[32]
        else
            ennemis[j]:=templatesEnnemis[alea];
        ennemis[j].stats.vie := ennemis[j].stats.vie + (statsJoueur.avancement * 2);
        ennemis[j].stats.vieMax := ennemis[j].stats.vieMax + (statsJoueur.avancement * 2);
        ennemis[j].stats.force := ennemis[j].stats.force + (statsJoueur.avancement div 2);
        ennemis[j].stats.defense := ennemis[j].stats.defense + (statsJoueur.avancement div 3);
        ennemis[j].stats.vitesse := ennemis[j].stats.vitesse + (statsJoueur.avancement div 5);
        end;

end;

procedure LancementSalleCombat();
begin

writeln('Lancement de salle Combat');
choisirEnnemis;
statsJoueur.avancement := statsJoueur.avancement+1;
ClearScreen;
SDL_RenderClear(sdlRenderer);

SceneActive := 'Jeu';
//indiceMusiqueJouee:=random(4)+2;
end;

procedure LancementVSLeo();
begin
    initStatsCombat(statsJoueur,LObjets[0].stats);
    if high(LOBjets)>0 then repeat supprimeObjet(LObjets[1]) until high(LObjets)=0;
    vagueFinie:=True;
    combatFini:=False;
    setlength(ennemis,2);
    indiceMusiqueJouee:=9;
    initDecor;
    ennemis[1]:=templatesEnnemis[12];
    sceneActive:='Jeu';
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
    indiceMusiqueJouee:=random(4)+11;
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

function ajouterCarteAleatoireRarete(rarete : Trarete):TCarte;
var rdm : integer;
begin
    randomize;
    case rarete of 
    commune :  
    begin
        rdm := 1 + random(6);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[1];
        2: ajouterCarteAleatoireRarete:=cartes[2];
        3: ajouterCarteAleatoireRarete:=cartes[3];
        4: ajouterCarteAleatoireRarete:=cartes[4];
        5: ajouterCarteAleatoireRarete:=cartes[5];
        6: ajouterCarteAleatoireRarete:=cartes[10];
        end;
    end;

    rare :
    begin
         rdm := 1 + random(7);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[6];
        2: ajouterCarteAleatoireRarete:=cartes[7];
        3: ajouterCarteAleatoireRarete:=cartes[8];
        4: ajouterCarteAleatoireRarete:=cartes[9];
        5: ajouterCarteAleatoireRarete:=cartes[11];
        6: ajouterCarteAleatoireRarete:=cartes[16];
        7: ajouterCarteAleatoireRarete:=cartes[19];
        end;
    end;

    epique :
    begin
         rdm := 1 + random(6);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[12];
        2: ajouterCarteAleatoireRarete:=cartes[14];
        3: ajouterCarteAleatoireRarete:=cartes[17];
        4: ajouterCarteAleatoireRarete:=cartes[18];
        5: ajouterCarteAleatoireRarete:=cartes[20];
        6: ajouterCarteAleatoireRarete:=cartes[22];
        end;
    
    end;

    legendaire :
    begin
         rdm := 1 + random(3);

        case rdm of
        1: ajouterCarteAleatoireRarete:=cartes[13];
        2: ajouterCarteAleatoireRarete:=cartes[15];
        3: ajouterCarteAleatoireRarete:=cartes[21];
        end;
    end;
    end;
end;


procedure trade(carte1, carte2 : TCarte ; Var stats : Tstats); //#### table de proba à finir
var rdm : Integer;carte:TCarte;
begin
    randomize;
    //C-C -> Commune:93% Rare:5% Epique:1% Legendaire:1%
    if (carte1.rarete = commune) AND (carte2.rarete = commune) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..93:  carte:=ajouterCarteAleatoireRarete(commune);
            94..98: carte:=ajouterCarteAleatoireRarete(rare);
            99:     carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //R-R -> Commune:1% Rare:93% Epique:5% Legendaire:1%
    else if (carte1.rarete = rare) AND (carte2.rarete = rare) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1:      ajouterCarteAleatoireRarete(commune);
            2..94:  ajouterCarteAleatoireRarete(rare);
            95..99: ajouterCarteAleatoireRarete(epique);
            100:    ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //E-E -> Commune:1% Rare:1% Epique:93% Legendaire:5%
    else if (carte1.rarete = epique) AND (carte2.rarete = epique) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1:      carte:=ajouterCarteAleatoireRarete(commune);
            2:      carte:=ajouterCarteAleatoireRarete(rare);
            3..95:  carte:=ajouterCarteAleatoireRarete(epique);
            96..100:carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //L-L -> Commune:1% Rare:1% Epique:1% Legendaire:97%
    else if (carte1.rarete = legendaire) AND (carte2.rarete = legendaire) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1:      carte:=ajouterCarteAleatoireRarete(commune);
            2:      carte:=ajouterCarteAleatoireRarete(rare);
            3:      carte:=ajouterCarteAleatoireRarete(epique);
            4..100: carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //C-R
    else if ((carte1.rarete = commune) AND (carte2.rarete = rare)) OR ((carte1.rarete = rare) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..60 : carte:=ajouterCarteAleatoireRarete(commune);
            61..98: carte:=ajouterCarteAleatoireRarete(rare);
            99:     carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //C-E
    else if ((carte1.rarete = commune) AND (carte2.rarete = epique)) OR ((carte1.rarete = epique) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..50:  carte:=ajouterCarteAleatoireRarete(commune);
            51..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //C-L
    else if ((carte1.rarete = commune) AND (carte2.rarete = legendaire)) OR ((carte1.rarete = legendaire) AND (carte2.rarete = commune)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //R-E
    else if ((carte1.rarete = rare) AND (carte2.rarete = epique)) OR ((carte1.rarete = epique) AND (carte2.rarete = rare)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //R-L
    else if ((carte1.rarete = rare) AND (carte2.rarete = legendaire)) OR ((carte1.rarete = legendaire) AND (carte2.rarete = rare)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end

    //E-L
    else if ((carte1.rarete = epique) AND (carte2.rarete = legendaire)) OR ((carte1.rarete = legendaire) AND (carte2.rarete = epique)) then
    begin
        rdm := 1 + random(100);
        case rdm of 
            1..20:  carte:=ajouterCarteAleatoireRarete(commune);
            21..79: carte:=ajouterCarteAleatoireRarete(rare);
            80..99: carte:=ajouterCarteAleatoireRarete(epique);
            100:    carte:=ajouterCarteAleatoireRarete(legendaire);
        end;
    end;

    
    supprimerCarte(stats,carte1.numero);
    supprimerCarte(stats,carte2.numero);
    echangeFait:=True;
    ajouterCarte(statsJoueur,carte.numero);
    createRawImage(imgCar3,1080-250-127,imgCar2.rect.y,imgCar2.rect.w,imgCar2.rect.h,carte.dir);
    renderRawImage(imgCar3,False);
    sdl_renderpresent(sdlrenderer);
    sdl_delay(3000);
    LancementSalleMarchand;
end;

procedure scrollDeck(var i:Integer;imax:Integer);

begin
	if EventSystem^.wheel.y<0 then
		if i>=imax then
			i:=1
		else
			i:=i+1
	else
		if i<=2 then
            i:=imax
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
    highlight(boutons[2],getmousex,getmousey);
    highlight(boutons[3],getmousex,getmousey);
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
InitButtonGroup(boutons[2],  100, 250, 250, 250, 'Sprites/Menu/button1.bmp','X',@confirmer);
InitButtonGroup(boutons[3],  1080-255-500, 250, 250, 250, 'Sprites/Menu/button1.bmp','X',@confirmer);
InitButtonGroup(boutons[4],  415, 580, 250, 100, 'Sprites/Menu/button1.bmp','Echange',btnProc);
boutons[4].parametresSpeciaux:=3;boutons[4].procEch:=@trade;
end;

procedure LancementSalleMarchand; //###
begin
    sceneActive := 'marchand';
    indiceMusiqueJouee:=15;
    writeln('Lancement de salle Marchand');
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    if statsJoueur.tailleCollection<4 then
        echangeFait:=True;
    if not entree then
        begin
        statsJoueur.avancement := statsJoueur.avancement+1;
        entree:=True;
        end;
    if not echangeFait then
    InitButtonGroup(boutons[1],  415, 100, 250, 100, 'Sprites/Menu/button1.bmp','Marchandage',@Echange);
    InitButtonGroup(boutons[2],  440, 200, 200, 100, 'Sprites/Menu/button1.bmp','Discussion',@LancementSalleMarchand);
    InitButtonGroup(boutons[3],  465, 300, 150, 100, 'Sprites/Menu/button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp',nil,0,450,1080,300,extractionTexte('DIALOGUE_MARCHAND_'+intToStr(random(9)+1)),10);
    
    
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

procedure soinFeuCamp();
begin
    subirDegats(statsJoueur, -40, windowWidth div 2, windowHeight div 2);
    echangeFait:=True;
end;



procedure actualiserFeuCamp;
begin
    renderRawImage(fond,false);
    if not echangeFait then 
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        OnMouseHover(boutons[2],getMouseX,getMouseY);
        renderButtonGroup(boutons[2]);
        //HandleButtonClick(boutons[1].button,getmousex,getmousey);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;

procedure actualiserDefausse;
begin
    renderRawImage(fond,false);
    highlight(boutons[2],getmousex,getmousey);
    //writeln(ichoix1);
    renderButtonGroup(boutons[1]);
    renderButtonGroup(boutons[2]);
    renderButtonGroup(boutons[3]);
    createRawImage(imgCar1,boutons[2].image.rect.x,boutons[2].image.rect.y,boutons[2].image.rect.w,boutons[2].image.rect.h,StringToPChar('Sprites/Cartes/carte'+intToStr(statsJoueur.collection[iChoix1].numero)+'.bmp'));
    renderRawImage(imgCar1,False);
    sdl_destroytexture(imgCar1.imgTexture);
    sdl_freeSurface(imgCar1.imgSurface);
end;

procedure defaussecarte;
begin
    sceneActive:='defausse';
    ClearScreen;
    iChoix1:=1;
    SDL_RenderClear(sdlRenderer);
    InitButtonGroup(boutons[1],  415, 50, 250, 100, 'Sprites/Menu/button1.bmp','Annuler',@lancementSalleCamp);
    InitButtonGroup(boutons[2],  540-125, 250, 250, 250, 'Sprites/Menu/button1.bmp','X',btnProc);
    InitButtonGroup(boutons[3],  415, 580, 250, 100, 'Sprites/Menu/button1.bmp','brulerCarte',btnProc);
    boutons[3].parametresSpeciaux:=1;boutons[3].procCarte:=@brulerCarte;
end;


procedure LancementSalleCamp;
begin
    sceneActive:='feuCamp';
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    if not(entree) then  
        begin
        statsJoueur.avancement:=statsJoueur.avancement+1;
        entree:=true;
        end;
    InitButtonGroup(boutons[1],  415, 100, 250, 100, 'Sprites/Menu/button1.bmp','Bruler carte',@defaussecarte);
    InitButtonGroup(boutons[2],  440, 200, 200, 100, 'Sprites/Menu/button1.bmp','Repos',@soinFeuCamp);
    InitButtonGroup(boutons[3],  465, 300, 150, 100, 'Sprites/Menu/button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450,1800,300,extractionTexte('FEU_DE_CAMP_'+intToSTR(random(3)+1)),10);
end;

procedure brulerCarte(carte:TCarte ; var stats : Tstats);
begin
    supprimerCarte(stats,carte.numero);
    echangeFait:=True;
    lancementSalleCamp;
end;

procedure rerollDialogueLeo;
begin
    if numDialogue=6 then
        numDialogue:=numDialogue
    else
        numDialogue:=numDialogue+1;
    case numDialogue of
    0,2,4,5:
        initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/portrait_Leo1.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT_'+intToStr(numDialogue)),10)
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT_'+intToStr(numDialogue)),10);
    end;
end;

procedure rerollDialogueOph;
begin
    if (numDialogue=0) and statsJoueur.bestiaire[8] then
        numDialogue:=12
    else if numDialogue>=14 then
        numDialogue:=1
    else if numDialogue=5 then
        begin
        ajouterCarte(statsJoueur,24);
        numDialogue:=6;
        end
    else if (numDialogue>=6) and (numDialogue<=11) then
        numDialogue:=random(5)+7
    else
        numDialogue:=numDialogue+1;
    case numDialogue of
    0,2,4,5,13,15:
        initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/portrait_Ophiucus1.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT2_'+intToStr(numDialogue)),10);
    7..11:
        initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/portrait_Ophiucus2.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT2_'+intToStr(numDialogue)),10);
    else
        initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/CombatUI_5.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT2_'+intToStr(numDialogue)),10);
    end;
end;

procedure LancementSalleHasardLeo;
begin
    sceneActive:='Leo_Menu';
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    numDialogue:=0;
    InitButtonGroup(boutons[1],  415, 100, 250, 100, 'Sprites/Menu/button1.bmp','Affronter',@LancementVSLeo);
    InitButtonGroup(boutons[2],  440, 200, 200, 100, 'Sprites/Menu/button1.bmp','Discussion',@rerollDialogueLeo);
    InitButtonGroup(boutons[3],  465, 300, 150, 100, 'Sprites/Menu/button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/portrait_Leo3.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT_0'),10);
end;

procedure LancementSalleHasardOph;
begin
    sceneActive:='Oph_Menu';
    sdl_destroytexture(fond.imgtexture);
    sdl_freeSurface(fond.imgsurface);
    createRawImage(fond, 0,0, WINDOWWIDTH, windowHeight,'Sprites/Menu/fondMarchand.bmp');
    numDialogue:=0;
    //InitButtonGroup(boutons[1],  415, 100, 250, 100, 'Sprites/Menu/button1.bmp','Affronter',@LancementVSLeo);
    InitButtonGroup(boutons[2],  440, 200, 200, 100, 'Sprites/Menu/button1.bmp','Discussion',@rerollDialogueOph);
    InitButtonGroup(boutons[3],  465, 300, 150, 100, 'Sprites/Menu/button1.bmp','Partir',@choixSalle);
    initDialogueBox(dialogues[2],'Sprites/Menu/button1.bmp','Sprites/Menu/portrait_Ophiucus4.bmp',0,450,1080,300,extractionTexte('DIALOGUE_EVENT2_0'),10);
end;

procedure actualiserSalleLeo;
begin
    renderRawImage(fond,false);
    if sceneActive='Leo_Menu' then
        begin
        OnMouseHover(boutons[1],getMouseX,getMouseY);
        renderButtonGroup(boutons[1]);
        end;
    UpdateDialogueBox(dialogues[2]);
    OnMouseHover(boutons[2],getMouseX,getMouseY);
    renderButtonGroup(boutons[2]);
    OnMouseHover(boutons[3],getMouseX,getMouseY);
    renderButtonGroup(boutons[3]);
end;

procedure LancementSalleHasard;
begin
writeln('Lancement de salle Hasard');
statsJoueur.avancement := statsJoueur.avancement+1;
ClearScreen;
SDL_RenderClear(sdlRenderer);
case random(10)+1 of
1:  if trouverCarte(statsJoueur,24) then lancementSalleHasard
    else
    if trouverCarte(statsJoueur,23) then
        begin
        sceneActive:='Event';
        InitDialogueBox(dialogues[1],nil,nil,-50,windowHeight div 3 - 100,windowWidth,400,extractionTexte('INTRO_EVENT2_1'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT2_2'));
        sceneSuiv:='Ophiucus';
        end
    else
        begin
        sceneActive:='Event';
        InitDialogueBox(dialogues[1],nil,nil,-50,windowHeight div 3 - 100,windowWidth,400,extractionTexte('INTRO_EVENT1_1'),100);
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT1_2'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT1_3'));
        ajoutDialogue(nil,extractionTexte('INTRO_EVENT1_4'));
        sceneSuiv:='Leo';
        end
else begin
    end;
end;
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
    sauvegarder(statsJoueur);
    entree:=false;
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

procedure activationEvent(scene:String);
begin
    case scene of
        'Leo':LancementSalleHasardLeo;
        'Ophiucus':lancementSalleHasardOph;
        'Intro':
            begin 
            black_color.r := 0; 
            black_color.g := 0; 
            black_color.b := 0;
            ChoixSalle;
            end;
    end;
end;
    

    






begin
statsJoueur.avancement:=1;
//
writeln('MapSys ready')
end.