unit CombatLib;

interface

uses math, SDL2;

var 
mana : Integer;
manaMax : Integer;
mutiplicateurMana : Real;
mutiplicateurDegat : Real;


function degat(flat : Integer ; force : Integer ; defence : Integer): Integer;

procedure RegenMana();

implementation

//Fonction de calcul des dégats
function degat(flat : Integer ; force : Integer ; defence : Integer): Integer;
begin

    degat := math.ceil((flat + force - defence)*mutiplicateurDegat);
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
        currentTime := SDL_GetTicks(); //récupère le temps
        LastUpdateTime := currentTime;

        if ( (currentTime - LastUpdateTime)*mutiplicateurMana  >= 100) AND (mana < ManaMAX) then //attendre 1sec/mult avant +1 mana
        begin
            mana := mana + 1;
            LastUpdateTime := currentTime;
        end;
    end;

end;


end.