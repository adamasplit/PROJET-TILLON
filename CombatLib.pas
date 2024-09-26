unit CombatLib;

interface

uses
    math,coeur,
    SDL2;
function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;

procedure RegenMana();

implementation

//Fonction de calcul des dégats
function degat(flat : Integer ; force : Integer ; defence : Integer;multiplicateurDegat:Real): Integer;
begin

    degat := math.ceil((flat + force - defence)*multiplicateurDegat);
    if degat < 1 then
        degat := 1;
end;

//Procedure Régénération du mana
procedure RegenMana(); 
var 
    currentTime: UInt32;
    LastUpdateTime : UInt32;

begin

    while true do 
    begin
        SDL_PumpEvents;
        currentTime := SDL_GetTicks(); //récupère le temps
        LastUpdateTime := currentTime;

        if (( (currentTime - LastUpdateTime)*LObjets[0].stats.multiplicateurMana)>= 100) AND (LObjets[0].stats.mana < LObjets[0].stats.manaMax) then //attendre 1sec/mult avant +1 mana
        begin
            LObjets[0].stats.mana := LObjets[0].stats.mana + 1;
            LastUpdateTime := currentTime;
        end;
    end;

end;


end.