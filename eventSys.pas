unit eventSys;

interface
uses
        coeur,AnimationSys,
        math,
        memgraph,
        SDL2;
        
var Boutons:array[1..20] of TButton;
CombatUI:Array[1..12] of TImage;
	sdlKeyboardState: PUInt8;
  lastMouseX,lastMouseY:Integer;
testevent:PSDL_Event;
SceneActive : String;


function GetMouseX():Integer;
function GetMouseY():Integer;
procedure InitUICombat();
procedure UpdateUICombat(icarteChoisie:Integer;x,y:Integer;stats:TStats);
procedure MouvementJoueur(var joueur:TObjet);
function isuiv(i:Integer):Integer;
function iprec(i:Integer):Integer;
implementation

function GetMouseX():Integer;
begin
        GetMouseX:=testevent^.motion.x;
        if GetMouseX=0 then
          getMouseX:=lastMouseX
        else lastMouseX:=getMouseX
end;

function GetMouseY():Integer;
begin
        GetMouseY:=testevent^.motion.y;
        if GetMouseY=0 then
          getMouseY:=lastMouseY
        else lastMouseY:=getMouseY
end;

procedure MouvementJoueur(var joueur:TObjet);
  begin
	
	joueur.anim.isFliped := False;
  	if sdlKeyboardState[SDL_SCANCODE_W] = 1 then
	begin
      joueur.image.rect.y := joueur.image.rect.y - joueur.stats.Vitesse;
	  if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
	end;
	
    if sdlKeyboardState[SDL_SCANCODE_A] = 1 then
	begin
	  	joueur.image.rect.x := joueur.image.rect.x - joueur.stats.Vitesse;
	  	if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
		joueur.anim.isFliped := True;
	end;
    
    if sdlKeyboardState[SDL_SCANCODE_S] = 1 then
      	begin
	  	joueur.image.rect.y := joueur.image.rect.y + joueur.stats.Vitesse;
	  	if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
	end;
	
    if sdlKeyboardState[SDL_SCANCODE_D] = 1 then
    	begin
	  	joueur.image.rect.x := joueur.image.rect.x + joueur.stats.Vitesse;
	  	if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
	end;

	if ((joueur.anim.Etat <> 'idle') and not((sdlKeyboardState[SDL_SCANCODE_D] = 1) or (sdlKeyboardState[SDL_SCANCODE_S] = 1) or (sdlKeyboardState[SDL_SCANCODE_W] = 1) or (sdlKeyboardState[SDL_SCANCODE_A] = 1))) 
		then InitAnimation(joueur.anim,'Joueur','idle',12,True);
		
  end;

procedure InitUICombat();
begin
    //Barres de part et d'autre de l'écran
    CreateRawImage(CombatUI[1],-70,-40,300,800,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[2],850,-40,300,800,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[4],15,560,128,128,'Sprites/Menu/CombatUI_4.bmp');
    CreateRawImage(CombatUI[5],30,575,100,100,'Sprites/Menu/CombatUI_5.bmp');
    RenderRawImage(CombatUI[1],False);RenderRawImage(CombatUI[2],True);
    iCarteChoisie:=1;
end;

procedure UpdateUICombat(icarteChoisie:Integer;x,y:Integer;stats:TStats);
var i:Integer;
begin
    //Carte-curseur
    SDL_FreeSurface(CombatUI[3].imgSurface);
    SDL_DestroyTexture(CombatUI[3].imgTexture);
    CreateRawImage(CombatUI[3],min(820,max(GetMouseX-20,140)),GetMouseY-5,128,128,stats.deck[icarteChoisie].dir);
    RenderRawImage(combatUI[3],false);
    if LObjets[0].stats.mana<LObjets[0].stats.deck[iCarteChoisie].cout then
        drawRect(black_color,190,CombatUI[3].rect.x+20,CombatUI[3].rect.y,90,128);

    //Bandes de part et d'autre
    RenderRawImage(CombatUI[1],False);
    RenderRawImage(CombatUI[2],True);
    //Vie
    DrawRect(black_color,255, 30, 350, 30, 200);
    DrawRect(red_color,255, 35, 355+190-Round(190*stats.vie/stats.vieMax), 20, Round(190*stats.vie/stats.vieMax) );
    //Mana
    DrawRect(black_color,255,95, 350, 30, 200);
    DrawRect(b_color,255, 100, 355+190-Round(190* stats.mana/stats.manaMax), 20, Round(190* stats.mana/stats.manaMax) );
    //Portrait
    RenderRawImage(CombatUI[4],False);
    RenderRawImage(CombatUI[5],False);
    //3 cartes disponibles
    if stats.tailleDeck-stats.cartesUniquesJouees>=3 then begin
        case icarteChoisie of //mettre une des cartes en surbrillance selon celle choisie
        1:drawRect(red_color,160,938,68,132,132);
        2:drawRect(red_color,160,938,218,132,132);
        3:drawRect(red_color,160,938,368,132,132);
        end;
        for i:=1 to 3 do begin
        SDL_FreeSurface(CombatUI[6+i].imgSurface);
        SDL_DestroyTexture(CombatUI[6+i].imgTexture);
        end;
        createRawImage(CombatUI[7],940,70,128,128,stats.deck[1].dir);
        createRawImage(CombatUI[8],940,220,128,128,stats.deck[2].dir);
        createRawImage(CombatUI[9],940,370,128,128,stats.deck[3].dir);
        RenderRawImage(combatUI[7],false);RenderRawImage(combatUI[8],false);RenderRawImage(combatUI[9],false);
        end;
    //Reste du deck
    drawRect(black_color,100,940,560,128,158);
    if stats.tailleDeck-stats.cartesUniquesJouees>3 then
        for i:=min(8,stats.tailleDeck-stats.cartesUniquesJouees) downto 4 do begin
            SDL_FreeSurface(CombatUI[7+i].imgSurface);
            SDL_DestroyTexture(CombatUI[7+i].imgTexture);
            createRawImage(CombatUI[7+i],920+4*i,600-i*5,128,128,stats.deck[i].dir);
            renderRawImage(CombatUI[7+i],False);
            end;
    end;
    
    
function isuiv(i:Integer):Integer;
  begin
    if i>2 then  
      isuiv:=1
    else isuiv:=i+1;
  end;

function iprec(i:Integer):Integer;
  begin
    if i<2 then  
      iprec:=3
    else iprec:=i-1;
  end;
  var j: integer;
    

begin

lastMouseX:=0;
lastMouseY:=0;

end.