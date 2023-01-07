with LCA;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

generic
   capacite_cache : Integer ;

package Cache_fifo is
   
   type T_LCA is private ;
   
   type T_Stats is private ;
   type T_Complet is limited private ;

   procedure Initialiser(Cache : out T_Complet) ;
   -- Post => Taille(Cache) = 1 and Cache.Stats = 0 ;

   function Est_Vide(Cache : in T_Complet) return Boolean ;

   procedure Supprimer(Cache : in out T_Complet) ;

   procedure Enregistrer(Cache_Contenu : in out T_LCA; Cache_Stats : in out T_Stats; Adresse_IP : in Unbounded_String; Interface_Adresse : in String) ;

   --procedure Free is new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);

   procedure Vider(Cache_Contenu : in out T_LCA; Cache_Stats : in out T_Stats);
   -- Post => Est_Vide(Cache) ;

   function Adresse_Presente(Cache_Contenu : in T_LCA; Cache_Stats : in T_Stats; Adresse : in Unbounded_String) return Boolean;

   function Taille(Cache_Contenu : in T_LCA; Cache_Stats : in T_Stats) return Integer ;
   
   function Est_Pleine(Cache : in T_Complet; capacite_cache : in Integer) return Boolean ;


private

   type T_Stats is record
      nb_demandes : Integer ;
      nb_defauts : Integer ;
      taux_defauts : Float ;
   end record ;

   type T_Cellule ;
   type T_LCA is access T_Cellule ;
   type T_Cellule is record
      Adresse : Unbounded_String ;
      Interface_utilisation : Unbounded_String ; 
      Cle : Integer ;
      Suivant : T_LCA ;
   end record ;
    
   type T_Complet is record
      Stats : T_Stats ;
      Contenu : T_LCA ;
   end record ;

end Cache_fifo ;
