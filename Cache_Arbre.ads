with Arbre;
with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 


generic
    politic : Unbounded_String
   
package Cache_Arbre is

	-- ça c'est qu'on mettras dans chaques noeuds de l'arbre
	-- [!] pas la même que dans rooter simple
    type T_ligne is
        record
            destination : Unbounded_String;
            mask : Unbounded_String;
            inter : Unbounded_String;
			time : Integer;
        end record;
	
    package Arbre_LA is 
	    new Arbre (T_Donnee => T_ligne);
	use Arbre_LA;

	type T_Stat is 
		record 
			nb_defaut : Integer;
			tx_defaut : Float; -- nb_defaut / nb_demande
			nb_demande : Integer;
		end record;
			

	type T_Cache is record 
		Arbre : T_Arbre;
		stats : T_Stat;
	end record;


	-- permet d'initialiser le cache
	function Initialiser (Cache : in out T_Arbre) return Arbre
		with Post => Est_Vide (Cache) = True;

	-- pretty self explanatory
	function Est_Vide (Cache : in T_Arbre) return Boolean;



end Cache_Arbre;