unit mapSys;

interface
uses SDL2,math,memgraph,SysUtils,coeur;
var imgs0,imgs1,imgs2,imgs3:TIntImage;
CombatUI:Array[1..7] of TImage;
var salleChoisie:TSalle;
CONST 
windowHeight=720;windowWidth=1080;
      Y1=(windowHeight div 2)+(windowHeight div 4)       ;           
      Y2=(windowHeight div 2);
      Y3=(windowHeight div 2)-(windowHeight div 4);
      X1=(windowWidth  div 2) - (windowWidth div 2);
      X2=(windowWidth  div 2) + (windowWidth div 2);

procedure generationChoix(avancement:Integer;var salle1,salle2,salle3:TSalle);
procedure affichageSalles(salle1,salle2,salle3:TSalle);
procedure choixSalle(avancement:Integer;var salle:TSalle);
procedure choisirEnnemis(avancement:integer;var salle:TSalle);
procedure InitUICombat();
procedure UpdateUICombat(carteChoisie:TCarte;x,y:Integer);

implementation


procedure generationChoix(avancement:Integer;var salle1,salle2,salle3:TSalle);
var alea:Integer;
begin
    if (avancement mod (MAXSALLES/4))=(MAXSALLES/4-1) then 
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

procedure choisirEnnemis(avancement:integer;var salle:TSalle);
var precTaille,i : Integer;
begin
    precTaille := High(LObjets)+1;
    setLength(LObjets, precTaille+avancement);
    for i:=1 to avancement do
    begin

    end;
end;

procedure InitUICombat();
begin
    CreateRawImage(CombatUI[1],-50,0,144,592,'Sprites/Menu/CombatUI_1.bmp');
    CreateRawImage(CombatUI[2],windowWidth-100,0,144,592,'Sprites/Menu/CombatUI_2.bmp');
    RenderRawImage(CombatUI[1],False);RenderRawImage(CombatUI[2],True);
end;

procedure UpdateUICombat(carteChoisie:TCarte;x,y:Integer);
begin
    //CreateRawImage(CombatUI[3],x,y,64,64,carteChoisie.dir);
    //CreateRawImage();
end;

procedure LancementSalleCombat();
begin
    choisirEnnemis(LObjets[0].stats.avancement,salleChoisie);
    InitUICombat();
end;

procedure LancementSalleHasard();
begin
end;

procedure LancementSalleBoss();
begin
end;

procedure LancementSalleMarchand();
begin
end;

procedure LancementSalleCamp();
begin
end;

procedure affichageSalle(salle:TSalle;x,y:integer;var img:TIntImage);
var dir:PCHar;proc:ButtonProcedure;
begin
    case salle.evenement of
        hasard:begin
            dir:='Sprites/Menu/salle_hasard.bmp';
            proc:= @LancementSalleHasard;
            end;
        combat:begin
            dir:='Sprites/Menu/salle_combat.bmp';
            proc:= @LancementSalleCombat;
            end;
        boss:begin
            dir:='Sprites/Menu/salle_combat.bmp';
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
            proc:=@OnButtonClickDebug;
            end
    end;
    writeln(dir);
    CreateInteractableImage(img,x,y,128,128,dir,proc);
    RenderIntImage(img);
end;

procedure affichageSalles(salle1,salle2,salle3:TSalle);
var depart:TSalle;
begin
    depart.evenement:=rien;
    affichageSalle(depart,X1,Y2,imgs0);
    affichageSalle(salle1,X2,Y1,imgs1);
    affichageSalle(salle2,X2,Y2,imgs2);
    affichageSalle(salle3,X2,Y3,imgs3);
end;

procedure choixSalle(avancement:Integer;var salle:TSalle);
var   salle1,salle2,salle3:TSalle;
begin
    writeln('initialisation des salles...');
    generationChoix(avancement,salle1,salle2,salle3);
    writeln('tentative d"affichage des salles');
    affichageSalles(salle1,salle2,salle3);
    salle.evenement:=rien;
    writeln('début du choix');
    SDL_RenderPresent(sdlRenderer);
end;

begin
writeln('MapSys ready')
end.