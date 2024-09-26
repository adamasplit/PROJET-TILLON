unit EnemyLib;

interface
uses SDL2,math,memgraph,SysUtils,coeur;


var EnemyBasik : TObjet;
procedure initStatEnnemi(nom:String,vie,att,def:Integer,directory:Pchar,var ennemi:TObjet);

implementation
procedure initStatEnnemi(nom:String,vie,att,def:Integer,directory:Pchar,var ennemi:TObjet);
begin
    CreateRawImage(ennemi.image,0,0, );
    InitAnimation(ennemi.anim,nom,'Chase', 6,True)
    ennemi.stats.vieMax:=vie;
    ennemi.stats.vie:=ennemi.stats.vieMax;
    ennemi.stats.force:=att;
    ennemi.stats.defense:=def;
end
begin
// EnnemyBasik

end.