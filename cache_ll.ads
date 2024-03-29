with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Calendar; use Ada.Calendar;
with Ada.Strings; use Ada.Strings;
package cache_ll is

capacite_cache: Integer;

type T_Stats is record
      nb_demandes : Float ;
      nb_defauts : Float ;
      taux_defauts : Float ;
   end record ;

   type T_Cellule;

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

   procedure Chercher_min_freq(Cache : in T_LCA; min: in out Unbounded_String; freq_min : in out Integer);

   procedure Supprimer_lfu(Cache : in T_LCA; min : in Unbounded_String) ;

   procedure Chercher_max_temps(Cache : in T_LCA; max : in out Unbounded_String; temps_max : in out Time);

   procedure Supprimer_lru(Cache : in T_LCA; max : in Unbounded_String) ;

   procedure Enregistrer(Cache : in out T_LCA; Stats : in out T_Stats; Adresse_IP : in Unbounded_String; Interface_Adresse : in Unbounded_String; Masque_Adresse: Unbounded_String) ;

   procedure Vider(Cache : in out T_LCA; Stats : in out T_Stats);

   function Adresse_Presente(Cache : in T_LCA; Stats : in T_Stats; Adresse : in Unbounded_String; Masque_Adresse: in Unbounded_String) return Boolean;
   
   function Presence_masque(Cache : in T_LCA; Adresse_IP_entree : in Unbounded_String) return Boolean;
   
   function Masquer_Cache(Cache: in T_LCA; Adresse: in Unbounded_String) return Unbounded_String ;

   function Taille(Cache : in T_LCA) return Integer ;

   function Est_Pleine(Cache : in T_LCA; capacite_cache : in Integer) return Boolean ;

   function Interface_du_Cache(Cache: in T_LCA; Stats: in T_Stats; Adresse: in Unbounded_String; Masque: Unbounded_String) return Unbounded_String;
   
    generic
        with procedure Traiter(Adresse: in Unbounded_String; Interface_utilisation: in Unbounded_String; Masque_Adresse: in Unbounded_String);
    procedure Pour_Chaque(Cache : in T_LCA);
    
     function Convertir_IP2B_4 (adr : Integer) return Unbounded_String;
    
    function Convertir_IP2B(Adresse_IP : Unbounded_String) return Unbounded_String;
    
    function B2IP_4 (Adresse_IP : in Unbounded_String) return Unbounded_String;
    
    function B2IP(Adresse_IP : in Unbounded_String) return Unbounded_String;
    
    function Convertir_B2IP(Adresse_IP : in Unbounded_String) return Unbounded_String;

end cache_ll;
