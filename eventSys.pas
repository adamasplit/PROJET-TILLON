unit eventSys;

interface
uses
  AnimationSys,
  coeur,
  math,
  memgraph,
  SDL2;

var CombatUI:Array[1..15] of TImage;
	sdlKeyboardState: PUInt8;
  lastMouseX,lastMouseY:Integer;
EventSystem:PSDL_Event;
SceneActive,ScenePrec : String;


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
        GetMouseX:=EventSystem^.motion.x;
        if GetMouseX=0 then
          getMouseX:=lastMouseX
        else lastMouseX:=getMouseX
end;

function GetMouseY():Integer;
begin
        GetMouseY:=EventSystem^.motion.y;
        if GetMouseY=0 then
          getMouseY:=lastMouseY
        else lastMouseY:=getMouseY
end;

procedure MouvementJoueur(var joueur:TObjet);
  begin
	if joueur.anim.etat<>'degats' then
    begin
    joueur.anim.isFliped := False;
      if ( (sdlKeyboardState[SDL_SCANCODE_W] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_S] = 1) AND joueur.stats.pendu) then //si z appuyé (ou s si pendu activé) alors déplacer vers le haut
    begin
        joueur.image.rect.y := joueur.image.rect.y - joueur.stats.Vitesse;
      if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
    end;
    
      if ( (sdlKeyboardState[SDL_SCANCODE_A] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_D] = 1) AND joueur.stats.pendu) then
    begin
        joueur.image.rect.x := joueur.image.rect.x - joueur.stats.Vitesse;
        if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
      joueur.anim.isFliped := True;
    end;
      
      if ( (sdlKeyboardState[SDL_SCANCODE_S] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_W] = 1) AND joueur.stats.pendu) then
          begin
        joueur.image.rect.y := joueur.image.rect.y + joueur.stats.Vitesse;
        if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
    end;
    
      if ( (sdlKeyboardState[SDL_SCANCODE_D] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_A] = 1) AND joueur.stats.pendu) then
        begin
        joueur.image.rect.x := joueur.image.rect.x + joueur.stats.Vitesse;
        if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,'Joueur','run',6,True);
    end;

    if ((joueur.anim.Etat <> 'idle') and not((sdlKeyboardState[SDL_SCANCODE_D] = 1) or (sdlKeyboardState[SDL_SCANCODE_S] = 1) or (sdlKeyboardState[SDL_SCANCODE_W] = 1) or (sdlKeyboardState[SDL_SCANCODE_A] = 1))) 
      then InitAnimation(joueur.anim,'Joueur','idle',12,True);
    end
		
  end;

procedure InitUICombat();
begin
    //Barres de part et d'autre de l'écran
    CreateRawImage(CombatUI[1],-70,-40,300,800,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[2],850,-40,300,800,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[4],15,560,128,128,'Sprites/Menu/CombatUI_4.bmp');
    CreateRawImage(CombatUI[5],30,575,100,100,'Sprites/Menu/CombatUI_5.bmp');
    renderRawImage(CombatUI[1],255,False);
    iCarteChoisie:=1;
end;

procedure UpdateUICombat(icarteChoisie:Integer;x,y:Integer;stats:TStats);
var i:Integer;
begin
    //Carte-curseur
    //if sdl_getTicks mod 150 <10 then writeln('mise à jour de l''UI,indice:',icarteChoisie);
    SDL_FreeSurface(CombatUI[3].imgSurface);
    SDL_DestroyTexture(CombatUI[3].imgTexture);
    if (icarteChoisie>2) or (icarteChoisie<0) then writeln(icarteChoisie);
    CreateRawImage(CombatUI[3],min(820,max(GetMouseX-20,140)),GetMouseY-5,64,64,stats.deck^[icarteChoisie].dir);
    if (LObjets[0].stats.mana<LObjets[0].stats.deck^[iCarteChoisie].cout) and not (LObjets[0].stats.deck^[iCarteChoisie].active) then
      begin
      //sdl_settexturecolormod(combatUI[3].imgTexture,120,120,120);
      RenderRawImage(combatUI[3],100,false);
      drawRect(black_color,100,CombatUI[3].rect.x+10,CombatUI[3].rect.y,45,64);
      end
    else
      begin
      //sdl_settexturecolormod(combatUI[3].imgTexture,120,120,120);
      RenderRawImage(combatUI[3],150,false);
      end;
    //Bandes de part et d'autre
    RenderRawImage(CombatUI[1],255,False);
    RenderRawImage(CombatUI[2],255,True);
    //Vie
    DrawRect(black_color,255, 30, 350, 30, 2*stats.vieMax);
    if stats.vie>0 then
      DrawRect(red_color,255, 35, 355+190-Round(190*(stats.vie/stats.vieMax)), 20, Round(190*(stats.vie/stats.vieMax)) );
    //Mana
    DrawRect(black_color,255,95, 350, 30, 200);
    if stats.manaMax<10 then
      writeln('Attention, le mana max est à ',stats.manaMax);
    if stats.manaMax>0 then
      DrawRect(b_color,255, 100, 355+190-Round(190* (stats.mana/stats.manaMax)), 20, Round(190* (stats.mana/stats.manaMax)) );
    //Portrait
    RenderRawImage(CombatUI[4],255,False);
    RenderRawImage(CombatUI[5],255,False);
    //3 cartes disponibles
    if  high(stats.deck^)>=2 then 
      begin
        case icarteChoisie of //mettre une des cartes en surbrillance selon celle choisie
        0:drawRect(red_color,160,933,68,135,132);
        1:drawRect(red_color,160,933,218,135,132);
        2:drawRect(red_color,160,933,368,135,132);
      end;
    for i:=1 to 3 do 
      begin
      SDL_FreeSurface(CombatUI[6+i].imgSurface);
      SDL_DestroyTexture(CombatUI[6+i].imgTexture);
      if (LObjets[0].stats.deck^[i-1].active) then
        drawRect(black_color,round(180*(LObjets[0].stats.deck^[i-1].charges)/(LObjets[0].stats.deck^[i-1].chargesMax)),933,68+150*(i-1),135,132);
      end;
    createRawImage(CombatUI[7],940,70,128,128,stats.deck^[0].dir);
    createRawImage(CombatUI[8],940,220,128,128,stats.deck^[1].dir);
    createRawImage(CombatUI[9],940,370,128,128,stats.deck^[2].dir);
    RenderRawImage(combatUI[7],255,false);RenderRawImage(combatUI[8],255,false);RenderRawImage(combatUI[9],255,false);
    end;
    //Reste du deck
    if high(stats.deck^)>=3 then begin
        drawRect(black_color,100,935,560,133,158);
        for i:=min(7,high(stats.deck^)+1) downto 4 do begin
            SDL_FreeSurface(CombatUI[7+i].imgSurface);
            SDL_DestroyTexture(CombatUI[7+i].imgTexture);
            createRawImage(CombatUI[7+i],920+4*i,600-i*5,128,128,stats.deck^[i-1].dir);
            renderRawImage(CombatUI[7+i],255,False);
            end;
            end;
    end;
    
    
function isuiv(i:Integer):Integer;
  begin
    if i>1 then  
      isuiv:=0
    else isuiv:=i+1;
  end;

function iprec(i:Integer):Integer;
  begin
    if i<1 then  
      iprec:=2
    else iprec:=i-1;
  end;
    

begin

lastMouseX:=0;
lastMouseY:=0;

end.