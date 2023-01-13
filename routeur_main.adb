with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Command_Line;          use Ada.Command_Line;
with routeur_ll; use routeur_ll;
with routeur_la; use routeur_la;

procedure routeur_main is

ligne_commande: Unbounded_String;
Nombre_arguments_restants: Integer;
Politique: Unbounded_String;
capacite_cache: Integer;
capacite_cache_bool: Boolean;
Stats_Bool: Boolean;
Nom_Fichier_Entree: Unbounded_String;
Nom_Fichier_Sortie: Unbounded_String;
Nom_Table_Routage: Unbounded_String;

begin

    Nombre_arguments_restants := Argument_count;
    capacite_cache_bool := False; 
    for VarBoucle in 1..Nombre_arguments_restants loop
        if To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("routeur_LL") then
            

        elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("routeur_LA") then

        elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-c") then
            capacite_cache_bool := True;
        esif capacite_cache_bool = True

        
        else
            Null;
        end if;
    end loop;



     



end routeur_main;