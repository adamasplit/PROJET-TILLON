unit eventSys;

interface
uses
  AnimationSys,
  coeur,
  Sysutils,
  math,
  memgraph,
  SDL2;

var CombatUI:Array[1..15] of TImage;
	sdlKeyboardState: PUInt8;
  lastMouseX,lastMouseY:Integer;
EventSystem:PSDL_Event;
SceneActive,ScenePrec,SceneSuiv : String;


function GetMouseX():Integer;
function GetMouseY():Integer;
procedure InitUICombat();
procedure UpdateUICombat(icarteChoisie:Integer;x,y:Integer;stats:TStats);
procedure MouvementJoueur(var joueur:TObjet);
function isuiv(i:Integer):Integer;
function iprec(i:Integer):Integer;
procedure afficherCarte(carte:TCarte;alpha:Integer;image:TImage);
procedure createAfterimage(obj:TObjet;duree:Integer);
procedure updateAfterimage(var image:TObjet);

implementation

function GetMouseX():Integer;
begin
        GetMouseX:=EventSystem^.motion.x;
        if GetMouseX=0 then
          getMouseX:=lastMouseX
        else lastMouseX:=getMouseX;
        getmouseX:=round((getmousex-windowOffsetX)/(windowWidth/1080))
end;

function GetMouseY():Integer;
begin
        GetMouseY:=EventSystem^.motion.y;
        if GetMouseY=0 then
          getMouseY:=lastMouseY
        else lastMouseY:=getmousey;
        getmouseY:=round(getMouseY/(windowHeight/720));
end;

procedure createAfterimage(obj:TObjet;duree:Integer);
var image:TObjet;
begin
    if getframePath(obj.anim)<>nil then
        begin
        createRawImage(image.image,obj.image.rect.x,obj.image.rect.y,obj.image.rect.w,obj.image.rect.h,getFramePath(obj.anim));
        image.anim.estActif:=False;
        image.anim.isFliped:=obj.anim.isFliped;
        image.col.estActif:=False;
        image.stats.genre:=afterimage;
        image.stats.vie:=duree;
        image.stats.vieMax:=duree;
        ajoutObjet(image);
        end;
end;

procedure updateAfterimage(var image:TObjet);
begin
    image.stats.vie:=image.stats.vie-1;
    if image.stats.vie<=0 then 
      supprimeObjet(image)
    else
      image.stats.transparence:=round(image.stats.vie/image.stats.vieMax*50)
end;

procedure MouvementJoueur(var joueur:TObjet);
var memflip:Boolean;
  begin
    if joueur.anim.etat<>'degats' then
      begin
        if ( (sdlKeyboardState[SDL_SCANCODE_W] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_S] = 1) AND joueur.stats.pendu) then //si z appuyé (ou s si pendu activé) alors déplacer vers le haut
        begin
          joueur.image.rect.y := joueur.image.rect.y - joueur.stats.Vitesse;
        if joueur.anim.Etat <> 'run' then 
            begin
            memflip:=joueur.anim.isfliped;
            InitAnimation(joueur.anim,joueur.anim.objectName,'run',6,True);
            joueur.anim.isfliped:=memflip;
            end;
        end;
      
        if ( (sdlKeyboardState[SDL_SCANCODE_A] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_D] = 1) AND joueur.stats.pendu) then
        begin
          joueur.image.rect.x := joueur.image.rect.x - joueur.stats.Vitesse;
          if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,joueur.anim.objectName,'run',6,True);
          joueur.anim.isFliped := True;
        end;
        
        if ( (sdlKeyboardState[SDL_SCANCODE_S] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_W] = 1) AND joueur.stats.pendu) then
        begin
          joueur.image.rect.y := joueur.image.rect.y + joueur.stats.Vitesse;
          if joueur.anim.Etat <> 'run' then 
            begin
            memflip:=joueur.anim.isfliped;
            InitAnimation(joueur.anim,joueur.anim.objectName,'run',6,True);
            joueur.anim.isfliped:=memflip;
            end;
        end;
      
        if ( (sdlKeyboardState[SDL_SCANCODE_D] = 1) AND not(joueur.stats.pendu)) OR ((sdlKeyboardState[SDL_SCANCODE_A] = 1) AND joueur.stats.pendu) then
          begin
          joueur.image.rect.x := joueur.image.rect.x + joueur.stats.Vitesse;
          joueur.anim.isFliped := False;
          if joueur.anim.Etat <> 'run' then InitAnimation(joueur.anim,joueur.anim.objectName,'run',6,True);
      end;

      if ((joueur.anim.etat='sort') and animFinie(joueur.anim)) or ((joueur.anim.Etat = 'run') and not((sdlKeyboardState[SDL_SCANCODE_D] = 1) or (sdlKeyboardState[SDL_SCANCODE_S] = 1) or (sdlKeyboardState[SDL_SCANCODE_W] = 1) or (sdlKeyboardState[SDL_SCANCODE_A] = 1))) 
        then begin
          memflip:=joueur.anim.isfliped;
          InitAnimation(joueur.anim,joueur.anim.objectName,'idle',12,True);
          joueur.anim.isfliped:=memflip;
          end;
      end;
  end;

procedure InitUICombat();
begin
    //Barres de part et d'autre de l'écran
    CreateRawImage(CombatUI[1],-70,-40,300,800,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[2],850,-40,300,800,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[4],15,560 ,128,128,'Sprites/Menu/CombatUI_4.bmp');
    CreateRawImage(CombatUI[5],30,575 ,100,100,'Sprites/Menu/CombatUI_5.bmp');
    renderRawImage(CombatUI[1],255,False);
    
    iCarteChoisie:=1;
end;

procedure afficherCarte(carte:TCarte;alpha:Integer;image:TImage);
var modif1,modif2:TImage;diff1,diff2:Integer;
begin
    diff1:=min(0,(carte.cout-carte.coutBase)*12);
    if carte.numero=8 then
      diff2:=0
    else
      diff2:=(carte.chargesMax-carte.chargesMaxBase)*36;
    sdl_settexturecolormod(image.imgTexture,max(0,255+diff1),max(0,255+diff1-diff2),max(0,255-diff2));
    if carte.chargesMax>carte.chargesMaxBase then
        begin
        createRawImage(modif2,image.rect.x,image.rect.y,image.rect.w,image.rect.h,'Sprites/Cartes/modif2.bmp');
        renderRawImage(modif2,False);
        sdl_destroytexture(modif2.imgTexture);
        sdl_freeSurface(modif2.imgSurface);
        end;
    if carte.inverse then
      begin
      rendermode(image.rect,True);
      sdl_settexturealphamod(image.imgtexture,alpha);
			SDL_RenderCopyEx(sdlRenderer,image.imgTexture, nil, @image.rect,0, nil, SDL_FLIP_VERTICAL);
      rendermode(image.rect,False);
      end
    else
      renderRawImage(image,alpha,False);
    if (carte.cout<carte.coutBase) and (carte.coutBase>0) and (carte.coutBase<=6) then
        begin
        createRawImage(modif1,image.rect.x+(image.rect.w div 15),image.rect.y,image.rect.w div 4,image.rect.h div 4,'Sprites/Cartes/modif1.bmp');
        renderRawImage(modif1,False);
        sdl_destroytexture(modif1.imgTexture);
        sdl_freeSurface(modif1.imgSurface);
        end;
end;   

procedure UpdateUICombat(icarteChoisie:Integer;x,y:Integer;stats:TStats);
var i:Integer;
begin
    //Carte-curseur
    //if sdl_getTicks mod 150 <10 then writeln('mise à jour de l''UI,indice:',icarteChoisie);
    SDL_FreeSurface(CombatUI[3].imgSurface);
    SDL_DestroyTexture(CombatUI[3].imgTexture);
   
    //if (icarteChoisie>2) or (icarteChoisie<0) then writeln(icarteChoisie);
    CreateRawImage(CombatUI[3],min(820,max(GetMouseX-20,140)),GetMouseY-5,90,90,stats.deck^[icarteChoisie].dir);
    if ((stats.mana<stats.deck^[iCarteChoisie].cout) and not (stats.deck^[iCarteChoisie].active)) then
      begin
      //sdl_settexturecolormod(combatUI[3].imgTexture,120,120,120);
      if stats.relique=10 then
        begin
        afficherCarte(stats.deck^[iCarteChoisie],150,combatUI[3]);
        if (stats.deck^[iCarteChoisie].numero=27) or (stats.deck^[iCarteChoisie].numero=28) then
          drawRect(red_color,20+5*(-stats.mana+stats.deck^[iCarteChoisie].cout),CombatUI[3].rect.x+8,CombatUI[3].rect.y+7,76,76)
        else
          drawRect(red_color,20+5*(-stats.mana+stats.deck^[iCarteChoisie].cout),CombatUI[3].rect.x+14,CombatUI[3].rect.y,63,90)
        end
      else
        begin
        afficherCarte(stats.deck^[iCarteChoisie],100,combatUI[3]);
        if (stats.deck^[iCarteChoisie].numero=27) or (stats.deck^[iCarteChoisie].numero=28) then
          drawRect(black_color,100,CombatUI[3].rect.x+8,CombatUI[3].rect.y+7,76,76)
        else
          drawRect(black_color,100,CombatUI[3].rect.x+14,CombatUI[3].rect.y,63,90)
        end
      end
    else
      begin
      //sdl_settexturecolormod(combatUI[3].imgTexture,120,120,120);
      afficherCarte(stats.deck^[iCarteChoisie],200,combatUI[3]);
      end;
    //Bandes de part et d'autre
    RenderRawImage(CombatUI[1],255,False);
    RenderRawImage(CombatUI[2],255,True);
    if stats.relique<>0 then
      begin
      SDL_FreeSurface(CombatUI[6].imgSurface);
      SDL_DestroyTexture(CombatUI[6].imgTexture);
      createRawImage(CombatUI[6],0,0,160,160,StringToPChar('Sprites/Reliques/reliques'+intToStr(stats.relique)+'.bmp'));
      renderRawImage(combatUI[6],255,False);
      end;
    //Vie
    DrawRect(black_color,255, 30, (550-2*stats.vieMax), 30, 2*stats.vieMax);
    if stats.vie>0 then
      DrawRect(red_color,255, 35, (355+190-Round(1.9*stats.vie)), 20, Round(1.9*stats.vie) );
    //Mana
    DrawRect(black_color,255,95, (550-20*stats.manaMax), 30, 20*stats.manaMax);
    if stats.manaMax>0 then
      DrawRect(b_color,255, 100, (355+190-Round(19* (stats.mana))), 20, Round(19* (stats.mana)) );
    //Portrait
    RenderRawImage(CombatUI[4],255,False);
    RenderRawImage(CombatUI[5],255,False);
    //3 cartes disponibles
    if  high(stats.deck^)>=2 then 
      begin
        case icarteChoisie of //mettre une des cartes en surbrillance selon celle choisie
        0:drawRect(red_color,160,933,68 ,135, 132);
        1:drawRect(red_color,160,933,218,135,132);
        2:drawRect(red_color,160,933,368,135,132);
      end;
    for i:=1 to 3 do 
      begin
      SDL_FreeSurface(CombatUI[6+i].imgSurface);
      SDL_DestroyTexture(CombatUI[6+i].imgTexture);
      if (stats.deck^[i-1].active) then
        drawRect(black_color,round(180*(stats.deck^[i-1].charges)/(stats.deck^[i-1].chargesMax)),933,(68+150*(i-1)),135,132);
      end;
    createRawImage(CombatUI[7],940,70 ,128,128,stats.deck^[0].dir);
    createRawImage(CombatUI[8],940,220,128,128,stats.deck^[1].dir);
    createRawImage(CombatUI[9],940,370,128,128,stats.deck^[2].dir);
    afficherCarte(stats.deck^[0],255,combatUI[7]);
    afficherCarte(stats.deck^[1],255,combatUI[8]);
    afficherCarte(stats.deck^[2],255,combatUI[9]);
    end;
    //Reste du deck
    if high(stats.deck^)>=3 then begin
        drawRect(black_color,100,935,560,133,158);
        for i:=min(7,high(stats.deck^)+1) downto 4 do begin
            SDL_FreeSurface(CombatUI[7+i].imgSurface);
            SDL_DestroyTexture(CombatUI[7+i].imgTexture);
            createRawImage(CombatUI[7+i],(920+4*i),(600-i*5),128,128,stats.deck^[i-1].dir);
            afficherCarte(stats.deck^[i-1],255,CombatUI[7+i]);
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