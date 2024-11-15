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
var map_bg:TImage;
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
procedure choisirEnnemis;
procedure LancementSalleHasard;
procedure LancementSalleBoss;
procedure LancementSalleMarchand;
procedure LancementSalleCamp;
implementation


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
    indiceMusiqueJouee:=random(9)+2;

    //###partie à modifier : choix des ennemis et de leur nombre
    setlength(ennemis,statsJoueur.avancement+1);
    for j:=1 to statsJoueur.avancement do
        begin
        alea:=random(20)+1;
        ennemis[j]:=templatesEnnemis[alea];
        //writeln('correspondant à ',templatesEnnemis[alea].image.directory);
        writeln('élément ',j,' de ennemis: ',ennemis[j].anim.objectName);
        //analyseObjet(ennemis[j]);
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
    ennemis[2]:=templatesEnnemis[10];
    ennemis[1]:=templatesEnnemis[12];
    writeln('ennemis choisis (boss)')
end;

procedure marchandage;
begin
SceneActive := 'MenuShop';
ClearScreen;
SDL_RenderClear(sdlRenderer);
end;

procedure LancementSalleMarchand; //###
begin
    sceneActive := 'marchand';
    indiceMusiqueJouee:=12;
    writeln('Lancement de salle Marchand');
    statsJoueur.avancement := statsJoueur.avancement+1;
    InitButtonGroup(btnEchange,  415, 100, 250, 100, 'Sprites/Menu/button1.bmp','Marchandage',btnProc);
    InitButtonGroup(btnDiscussion,  440, 200, 200, 100, 'Sprites/Menu/button1.bmp','Discussion',btnproc);
    InitButtonGroup(btnQuitterMarchand,  465, 300, 150, 100, 'Sprites/Menu/button1.bmp','Partir',btnProc);
    initDialogueBox(dialogues[10],'Sprites/Menu/button1.bmp',nil,0,600,1080,120,'aaa',10);
    
    
end;

procedure actualiserMarchand();
begin
    sdl_delay(10);
    sdl_renderclear(sdlrenderer);
    OnMouseHover(btnEchange,getMouseX,getMouseY);
    renderButtonGroup(btnEchange);
    UpdateDialogueBox(dialogues[10]);
    OnMouseHover(btnDiscussion,getMouseX,getMouseY);
    renderButtonGroup(btnDiscussion);
    OnMouseHover(btnQuitterMarchand,getMouseX,getMouseY);
    renderButtonGroup(btnQuitterMarchand);
    sdl_renderpresent(sdlrenderer);
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
    combatFini:=false;
    sdl_renderclear(sdlrenderer);
    SceneActive := 'map';
    writeln('Initializing rooms...');
    
    generationChoix(salles[1], salles[2], salles[3]);
    writeln('Displaying rooms');
    affichageSalles(salles[1], salles[2], salles[3]);
    
    writeln('Room choice started');
    SDL_RenderPresent(sdlRenderer);
    new(EventSystem);
    
end;

procedure actualiserMap();
begin
    SDL_PumpEvents();
    SDL_Delay(10);
    RenderButtonGroup(salles[1].image);
    RenderButtonGroup(salles[2].image);
    RenderButtonGroup(salles[3].image);
    SDL_RenderPresent(sdlRenderer);
end;

begin
statsJoueur.avancement:=1;
//
writeln('MapSys ready')
end.