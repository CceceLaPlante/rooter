with Arbre;
with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 

with Ada.Calendar;            use Ada.Calendar;
with Ada.Calendar.Formatting; use Ada.Calendar.Formatting;
with Ada.Text_IO;             use Ada.Text_IO;


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
			temps : Time;
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
	procedure Initialiser_cache (Cache : in out T_Cache)
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
	function Trouver (Cache : in T_Cache; IP : in Unbounded_String) return T_ligne;

	-- permet d'ajouter une ligne dans le cache
	procedure Ajouter (Cache : in out T_Cache; Ligne : in T_ligne);

	-- permet de supprimer une ligne du cache
	procedure Supprimer_IP (Cache : in out T_Cache; IP : in Unbounded_String);

	-- permet de supprimer la ligne la plus ancienne du cache
	procedure Supprimer_LRU (Cache : in out T_Cache; Ligne : in T_ligne);

	-- permet de savoir si une ligne est présente dans le cache
	function IP_Presente (Cache : in T_Cache; IP : in Unbounded_String) return Boolean;

	-- permet de vider le cache
	procedure Vider (Cache : in out T_Cache)
		with Post => Est_Vide (Cache);

	-- procedure "traiter" de arbre
	procedure afficher_inter (Cle : in String(1..32); Ligne : in T_ligne);

	-- permet d'afficher le cache
	procedure Afficher (Cache : in T_Cache);

	-- permet de retourner la taille du cache (le nb de feuilles,pas de noeuds)
	function Taille_cache(Cache : in T_Cache) return Integer;



end Cache_Arbre;