program testProj;

uses
    math,coeur,eventSys,memgraph,animationSys,
    SDL2,combatLib;

var boule:TObjet;
i:Integer;
xpos:Integer;
bouledef:Boolean;

procedure UpdateAnimations(var Objets:Array of TObjet);
var i:Integer;
begin
for i:=0 to High(Objets) do 
			begin
        if Objets[i].stats.genre<>projectile then
				  RenderRawImage(Objets[i].image, Objets[i].anim.isFliped);
				if Objets[i].anim.estActif then 
					begin
					UpdateAnimation(Objets[i].anim, LObjets[i].image);
					end
			end;

end;

begin

new(TestEvent);
xpos:=testevent^.motion.x;
writeln('starting');
while True do begin
    SDL_delay(10);
    SDL_RenderClear(sdlRenderer);
    {if random(1000)=0 then begin
                        CreerBoule(typeobjet(0),1,1,1,random(5)*200,random(5)*150,5,testevent^.motion.x,testevent^.motion.y,'projectile',boule);
                        AjoutObjet(boule);
                        //bouledef:=True;
                        end;}
    drawRect(navy_color,255,0,0,1080,720);
    while sdl_pollevent(testEvent)=1 do 
    case testEvent^.type_ of
    SDL_MOUSEBUTTONDOWN:begin
                        //CreerBoule(typeobjet(0),1,1,1,LObjets[0].image.rect.x+(LObjets[0].image.rect.w div 2),LObjets[0].image.rect.y+(LObjets[0].image.rect.h div 2),5,xpos,'projectile',boule);
                        //AjoutObjet(boule);
                        randomize();
                        multiProjs(1,1,1,testevent^.motion.x,testevent^.motion.y,10,90,180,'projectile');
                        //bouledef:=True;
                        end;

    SDL_mousemotion: begin
    xpos:=testevent^.motion.x;
    getmousex;getmousey;              
    end;
    end;
    UpdateAnimations(LObjets);
    for i:=2 to High(LObjets) do
      if i<=High(LObjets) then 
        begin
        if i<>LObjets[i].stats.indice then writeln('conflit à l"indice',i);
        //writeln('accès à l"objet numéro ',i,' dernier indice de LObjets : ',high(LObjets));
        updateBoule(LObjets[i]);
        end;
    
    SDL_RenderPresent(sdlRenderer);
    end;

  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow(sdlWindow1);

  // Shutting down video subsystem (A laisser imperativement)
  SDL_Quit;
end.