with lca; 
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Calendar; use Ada.Calendar;

package cache_ll is

   package lca_cache is new lca (Cle => Integer, Donnee => Adresse)

   type T_Stats is record
      nb_demandes : Float ;
      nb_defauts : Float ;
      taux_defauts : Float ;
   end record ;

   capacite_cache : Integer ;

   type T_LCA is access T_Cellule;
   type T_Cellule is record
      Adresse : Unbounded_String;
      Masque: Unbounded_String;
      Interface_utilisation : Unbounded_String; 
      Nombre_utilisation : Integer;
      Cle : Integer;
      Temps_enregistrement : Time ;
      Suivant : T_LCA;
   end record;


   procedure Initialiser(Cache : out T_LCA; Stats : out T_Stats) ;

   function Est_Vide(Cache : in T_LCA) return Boolean ;

   procedure Supprimer_fifo(Cache : in out T_LCA) ;

   procedure Chercher_min_freq(Cache : in out T_LCA; min: in out Unbounded_String; freq_min : in out Integer);

   procedure Supprimer_lfu(Cache : in out T_LCA; min : in Unbounded_String) ;

   procedure Chercher_max_temps(Cache : in out T_LCA; max : in out Unbounded_String; temps_max : in out Time);

   procedure Supprimer_lru(Cache : in out T_LCA; max : in Unbounded_String) ;

   procedure Enregistrer(Cache : in out T_LCA; Stats : in out T_Stats; Adresse_IP : in Unbounded_String; Interface_Adresse : in Unbounded_String; Masque_Adresse: Unbounded_String) ;

   procedure Vider(Cache : in out T_LCA; Stats : in out T_Stats);

   function Adresse_Presente(Cache : in T_LCA; Stats : in T_Stats; Adresse : in Unbounded_String; Masque_Adresse: in Unbounded_String) return Boolean;

   function Taille(Cache : in T_LCA) return Integer ;

   function Est_Pleine(Cache : in T_LCA; capacite_cache : in Integer) return Boolean ;
   
   generic
      with procedure Traiter(Adresse: in Unbounded_String; Interface_utilisation: in Unbounded_String; Masque_Adresse: in Unbounded_String);
   procedure Pour_Chaque(Cache : in T_LCA);

end cache_ll;
