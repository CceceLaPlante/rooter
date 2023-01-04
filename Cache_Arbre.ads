with Arbre;

generic
   type T_Cache is private;
   type T_Ligne is private;
   type T_Commande is private;
   type T_Adresse is private;
   

package Cache_Arbre is

   type T_Arbre is limited private;

   package Arbre_LA is new Arbre (T_cle => T_Cle, T_Donnee => T_Donnee);
   use Arbre_LA;

   -- Convertir une adresse IP en nombre binaire
   function Convertir(Adresse_IP : in str) return str ;
   

   -- Initialiser une Sda.  La Sda est vide.
   procedure Initialiser(Sda: out T_LCA) with
     Post => Est_Vide (Sda);


   -- Est-ce qu'une Sda est vide ?
   function Est_Vide (Sda : T_LCA) return Boolean;


   -- Obtenir le nombre d'ï¿œlï¿œments d'une Sda. 
   function Taille (Sda : in T_LCA) return Integer with
     Post => Taille'Result >= 0
     and (Taille'Result = 0) = Est_Vide (Sda);


   -- Enregistrer une Donnï¿œe associï¿œe ï¿œ une Clï¿œ dans une Sda.
   -- Si la clï¿œ est dï¿œjï¿œ prï¿œsente dans la Sda, sa donnï¿œe est changï¿œe.
   procedure Enregistrer (Sda : in out T_LCA ; Cle : in T_Cle ; Donnee : in T_Donnee) with
     Post => Cle_Presente (Sda, Cle) and (La_Donnee (Sda, Cle) = Donnee)   -- donnée insérée
     and (not (Cle_Presente (Sda, Cle)'Old) or Taille (Sda) = Taille (Sda)'Old)
     and (Cle_Presente (Sda, Cle)'Old or Taille (Sda) = Taille (Sda)'Old + 1);

   -- Supprimer la Donnée associée à une Clé dans une Sda.
   -- Exception : Cle_Absente_Exception si Clé n'est pas utilisï¿œe dans la Sda
   procedure Supprimer (Sda : in out T_LCA ; Cle : in T_Cle) with
     Post =>  Taille (Sda) = Taille (Sda)'Old - 1 -- un élément de moins
     and not Cle_Presente (Sda, Cle);         -- la clé a été supprimée


   -- Savoir si une Clï¿œ est prï¿œsente dans une Sda.
   function Cle_Presente (Sda : in T_LCA ; Cle : in T_Cle) return Boolean;


   -- Obtenir la donnï¿œe associï¿œe ï¿œ une Cle dans la Sda.
   -- Exception : Cle_Absente_Exception si Clï¿œ n'est pas utilisï¿œe dans l'Sda
   function La_Donnee (Sda : in T_LCA ; Cle : in T_Cle) return T_Donnee;


   -- Supprimer tous les ï¿œlï¿œments d'une Sda.
   procedure Vider (Sda : in out T_LCA) with
     Post => Est_Vide (Sda);


   -- Appliquer un traitement (Traiter) pour chaque couple d'une Sda.
   generic
      with procedure Traiter (Cle : in T_Cle; Donnee: in T_Donnee);
   procedure Pour_Chaque (Sda : in T_LCA);


private
   type T_Cellule;

   type T_LCA is access T_cellule;

   type T_Cellule is
      record
         Cle: T_Cle;
         Donnee: T_Donnee;
         Suivant: T_LCA;
         -- Invariant :
         --   Suivant = Null or else Suivant.all.Indice > Indice;
         --   	-- les cellules sont stockÃ©s dans l'ordre croissant des indices.
      end record;

end LCA;