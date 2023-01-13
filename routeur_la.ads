with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
--with Ada.Command_Line;          use Ada.Command_Line;
--with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 
with cache_la; use cache_la;


package routeur_ll is 

    Politique: Unbounded_String;
    capacite_cache: Integer;

   type T_Table;
   type T_Liste is access T_Table;
   type T_Table is 
      record 
         destination : Unbounded_String;
         mask : Unbounded_String;
         inter : Unbounded_String;
         Suivant : T_Liste;
         cle : Integer;
      end record;

   type adr4 is array(1..4) of Unbounded_String;

   procedure Afficher (adresse : in Unbounded_String ; Masque_Adresse: in Unbounded_String; interface_utilisation : in Unbounded_String);
   
   procedure Afficher_Stats (Stats: in T_Stats);
   
   procedure Free
   is new Ada.Unchecked_Deallocation (Object => T_Table, Name => T_Liste);
   
   procedure Initialiser_Table(table : Out  T_Liste);
   

   -- d'abord on s'occupe d'une conversion 4bit 
   function Convertir_IP2B_4 (adr : Integer) return Unbounded_String;
    

   -- puis on s'occupe de la conversion de l'adresse IP complète
   function Convertir_IP2B(Adresse_IP : Unbounded_String) return Unbounded_String;
     
   --Fonction prenant une ligne de la table de routage et la convertie en T_Table.
   --Attention cependant, tout est stocké sous forme de Unbounded_String.*
   -- on dois renseigner une clé, après elle ne sert pas vraiment...
   function Convertir_L2T(ligne : Unbounded_String ; cle : Integer) return T_Table;

   -- Fonction qui renvoie True si le masque et l'adresse IP coïncident.
   function Masque(Adresse_IP : in Unbounded_String; ligne : in T_Table) return Boolean;


   -- prend un masque en entrée, et renvoie la somme des 1,ça permet de facilement en quantifier la taille...
   -- [!] prend un masque BINAIRE en entrée
   function somme_masque (m : Unbounded_String) return Integer;

   function Meilleur_Masque(lst : in T_Liste; Adresse_IP : in Unbounded_String; current : in out T_Table) return T_Table;

   --Procedure permettant d'écrire dans un fichier.
   procedure Ecrire(fichier : File_Type; a_ecrire : Unbounded_String);

   procedure Supprimer(Cache: in out T_LCA; Politique: in Unbounded_String);

   --Fonction qui traite les commandes telles que "fin", "table"...
   procedure Traiter_Commande(commande: in Unbounded_String; nom_table : in Unbounded_String; Cache : in T_LCA; Stats : in T_Stats); 
    
   --fonction qui libère tout élément de type T_Liste
   procedure Liberer(table : in out T_Liste);
   
   --Fonction qui permet de charger la table de routage dans une liste chaînée.
   --La première fois qu'on utilise chargement table, on utilise une liste_table Null.
   procedure Chargement_Table(liste_table : in out  T_Liste; fichier_tableT : in out File_Type; cle : Integer);
        
end routeur_ll;
