with Arbre;
with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 

-- toutes les adresses ip et masques donnés par le client sont en base 10.

generic
    politic : Unbounded_String
   
package Cache_Arbre is

	-- ça c'est qu'on mettras dans chaques noeuds de l'arbre
	-- [!] pas la même que dans rooter simple
	-- c'est le T_Donnee de Arbre
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
	procedure Initialiser_cache (Cache : in out T_Arbre)
		with Post => Est_Vide (Cache) = True;

	-- pretty self explanatory
	function Est_Vide_cache (Cache : in T_Arbre) return Boolean;

	-- permet une conversion 4bits de l'ip en binaire
	function Convertir_IP2B_4 (adr: Integer) return Unbounded_String;

	-- permet une conversion totale de l'ip en binaire
	--[!] elle renvoie sans les . (point)
	function IP2B (Adresse_IP : in Unbounded_String) return Unbounded_String;
  
  	-- operation inverse de IP2B
  	function B2IP_4 (IP : in Unbounded_String) return Unbounded_String;

	function B2IP (IP : in Unbounded_String) return Unbounded_String;

	-- permet de trouver la ligne correspondante à l'ip
	function Trouver (Cache : in T_Arbre; IP : in Unbounded_String) return T_ligne;

	-- permet d'ajouter une ligne dans le cache
	procedure Ajouter (Cache : in out T_Arbre; Ligne : in T_ligne);

	-- permet de supprimer une ligne du cache
	procedure Supprimer (Cache : in out T_Arbre; IP : in Unbounded_String);

	-- permet de savoir si une ligne est présente dans le cache
	function Cle_Presente (Cache : in T_Arbre; IP : in Unbounded_String) return Boolean;

	-- permet de vider le cache
	procedure vider (Cache : in out T_Arbre)
		with Post => Est_Vide (Cache);

	-- permet d'afficher le cache
	procedure Afficher (Cache : in T_Arbre);

	-- permet de retourner la taille du cache (le nb de feuilles,pas de noeuds)
	function taille(Cache : in T_Arbre) return Integer;



end Cache_Arbre;