with LCA;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Calendar; use Ada.Calendar;

generic
   capacite_cache : Integer ;

package cache_LL is

   type T_Stats is record
      nb_demandes : Float ;
      nb_defauts : Float ;
      taux_defauts : Float ;
   end record ;

   type Horaire is record 
      Annee    : Year_Number;
      Mois     : Month_Number;
      Jour     : Day_Number;
      Secondes : Day_Duration;
   end record ;

   type T_LCA is private ;

   procedure Temps(Annee : out Year_Number; Mois : out Month_Number; Jour : out Day_Number; Secondes : out Day_Duration) ;

   procedure Initialiser(Cache : out T_LCA; Stats : out T_Stats) ;

   function Est_Vide(Cache : in T_LCA) return Boolean ;

   procedure Supprimer_fifo(Cache : in out T_LCA) ;

   procedure Chercher_min_freq(Cache : in out T_LCA, min: out Unbounded_String, freq_min : out Integer);

   procedure Supprimer_lfu(Cache : in out T_LCA, min : in Unbounded_String) ;

   procedure Chercher_max_temps(Cache : in out T_LCA, max : out Unbounded_String, temps_max : out Horaire);

   procedure Supprimer_lru(Cache : in out T_LCA, max : in Unbounded_String) ;

   procedure Enregistrer(Cache : in out T_LCA; Stats : in out T_Stats; Adresse_IP : in Unbounded_String; Interface_Adresse : in Unbounded_String) ;

   procedure Vider(Cache : in out T_LCA; Stats : in out T_Stats);

   function Adresse_Presente(Cache : in T_LCA; Stats : in T_Stats; Adresse : in Unbounded_String) return Boolean;

   function Taille(Cache : in T_LCA) return Integer ;

   function Est_Pleine(Cache : in T_LCA; capacite_cache : in Integer) return Boolean ;
   
   procedure Pour_Chaque(Cache : in T_LCA);
      


private

   type T_Cellule;
   type T_LCA is access T_Cellule;
   type T_Cellule is record
      Adresse : Unbounded_String;
      Interface_utilisation : Unbounded_String; 
      Nombre_utilisation : Integer;
      Cle : Integer;
      Temps_enregistrement : Horaire ;
      Suivant : T_LCA;
   end record;

end cache_LL;
