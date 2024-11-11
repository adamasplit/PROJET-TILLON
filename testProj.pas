program testProj;

uses
    math,coeur,eventSys,memgraph,animationSys,
    SDL2,combatLib,collisionSys;

var boule:TObjet;
i:Integer;
xpos:Integer;
bouledef,stop:Boolean;
testEvent:PSDL_EVent;

begin

new(TestEvent);
xpos:=testevent^.motion.x;
modeDebug:=True;
stop:=False;
writeln('starting');
setlength(lobjets,1);
LObjets[0].stats.genre:=ennemi;
LObjets[0].col.isTrigger := False;
LObjets[0].col.estActif := True;
LObjets[0].col.dimensions.w := 200;
LObjets[0].stats.angle:=0;
LObjets[0].col.dimensions.h := 100;
LObjets[0].col.offset.x := 0;
LObjets[0].col.offset.y := 0;
LObjets[0].col.nom := 'Joueur';
createRawImage(LObjets[0].image,300,300,400,200,'Sprites/Game/Akr/Akr_chase_1.bmp');
while True do 
  begin
    SDL_delay(10);
    SDL_RenderClear(sdlRenderer);
    //writeln('taille de LOBjets:',high(lobjets)+1);
    
    {if random(1000)=0 then begin
                        CreerBoule(typeobjet(0),1,1,1,random(5)*200,random(5)*150,5,testevent^.motion.x,testevent^.motion.y,'projectile',boule);
                        AjoutObjet(boule);
                        //bouledef:=True;
                        end;}
    drawRect(black_col,255,0,0,1080,720);
    
    //UpdateAnimations(LObjets);
    renderRawImage(LObjets[0].image,False);
    for i:=1 to High(LObjets) do
      if i<=High(LObjets) then 
        begin
        //if i<>LObjets[i].stats.indice then writeln('conflit à l"indice',i);
        //writeln('accès à l"objet numéro ',i,' dernier indice de LObjets : ',high(LObjets));
        if not stop then 
          if LObjets[i].stats.genre=laser then updaterayon(LObjets[i]) else updateBoule(LObjets[i]);
        renderAvecAngle(lobjets[i]);
        end;
    updateCollisions;
    while sdl_pollevent(testEvent)=1 do 
      case testEvent^.type_ of
        SDL_MOUSEBUTTONDOWN:begin
                          //CreerBoule(typeobjet(0),1,1,1,testevent^.motion.x,testevent^.motion.y,600,100,1,testevent^.motion.x+30,testevent^.motion.y+30,'projectile',boule);
                          //AjoutObjet(boule);
                          randomize();
                          setlength(LObjets,2);
                          creerrayon(typeobjet(0),1,1,1,testevent^.motion.x,testevent^.motion.y,200,testevent^.motion.x-200,testevent^.motion.y,-2,400,50,'rayonAL',boule);
                          LObjets[1]:=boule;
                          //if true then multiProjs(typeobjet(0),1,1,1,testevent^.motion.x,testevent^.motion.y,64,64,1,3,360,90,'projectile');
                          //multilasers(typeobjet(0),1,1,1,testevent^.motion.x,testevent^.motion.y,100,0,2,360,90,200,10,'rayon');
                          //bouledef:=True;
                          end;
      SDL_KEYDOWN:if  testEvent^.key.keysym.sym=SDLK_SPACE then
        stop:=not(stop); 
      SDL_mousemotion: begin
        xpos:=testevent^.motion.x;
        //getmousex;getmousey;              
        end;
      end;
    SDL_RenderPresent(sdlRenderer);
    end;

  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  // Shutting down video subsystem (A laisser imperativement)
  SDL_Quit;
end.