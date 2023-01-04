-- on définis un abre binaire de recherche 
-- MAIS le type de clé est spécifiquement 

generic
   type T_Donnee is private;

package Arbre is
  -- on remarque qu'il n'éxiste pas de relation d'ordre pour la clé
  -- la relation d'ordre sera sur les éléments de la clé (les 32 charactere)
  type T_Cle is new String(1..32);
  type T_Arbre is limited private;

   -- Initialiser un Arbre.  l'Arbre est vide.
  procedure Initialiser(Arbre: out T_Arbre) with
    Post => Est_Vide (Arbre);

  -- si on veux afficher la clé 
  function Cle2String (Cle : in T_Cle) return String;

   -- Est-ce qu'un Arbre est vide ?
  function Est_Vide (Arbre : T_Arbre) return Boolean;


   -- Obtenir le nombre d'ï¿œlï¿œments d'un Arbre. 
  function Taille (Arbre : in T_Arbre) return Integer with
    Post => Taille'Result >= 0
    and (Taille'Result = 0) = Est_Vide (Arbre);


   -- Enregistrer une Donnï¿œe associï¿œe ï¿œ une Clï¿œ dans un Arbre.
   -- Si la clï¿œ est dï¿œjï¿œ prï¿œsente dans l'Arbre, sa donnï¿œe est changï¿œe.
  procedure Enregistrer (Arbre : in out T_Arbre ; Cle : in T_Cle ; Donnee : in T_Donnee) with
    Post => Cle_Presente (Arbre, Cle) and (La_Donnee (Arbre, Cle) = Donnee)   -- donnée insérée
    and (not (Cle_Presente (Arbre, Cle)'Old) or Taille (Arbre) = Taille (Arbre)'Old)
    and (Cle_Presente (Arbre, Cle)'Old or Taille (Arbre) = Taille (Arbre)'Old + 1);

   -- Supprimer la Donnée associée à une Clé dans un Arbre.
   -- Exception : Cle_Absente_Exception si Clé n'est pas utilisï¿œe dans l'Arbre
  procedure Supprimer (Arbre : in out T_Arbre ; Cle : in T_Cle) with
    Post =>  Taille (Arbre) = Taille (Arbre)'Old - 1 -- un élément de moins
    and not Cle_Presente (Arbre, Cle);         -- la clé a été supprimée


   -- Savoir si une Clï¿œ est prï¿œsente dans un Arbre.
  function Cle_Presente (Arbre : in T_Arbre ; Cle : in T_Cle) return Boolean;

   -- Obtenir la donnï¿œe associï¿œe ï¿œ une Cle dans l'Arbre.
   -- Exception : Cle_Absente_Exception si Clï¿œ n'est pas utilisï¿œe dans l'Arbre
  function La_Donnee (Arbre : in T_Arbre ; Cle : in T_Cle) return T_Donnee;


   -- Supprimer tous les ï¿œlï¿œments d'un Arbre.
  procedure Vider (Arbre : in out T_Arbre) with
    Post => Est_Vide (Arbre);


   -- Appliquer un traitement (Traiter) pour chaque couple d'un Arbre.
 generic
     with procedure Traiter (Cle : in T_Cle; Donnee: in T_Donnee);
  procedure Pour_Chaque (Arbre : in T_Arbre);


private
  type T_Node;

  type T_Arbre is access T_Node;

  type T_Node is record
         Cle: T_Cle;
         Donnee: T_Donnee;
         Suivant_G: T_Arbre;
         Suivant_D: T_Arbre;
         -- Invariant :
         --   Suivant = Null or else Suivant.all.Indice > Indice;
         --   	-- les cellules sont stockÃ©s dans l'ordre croissant des indices.
      end record;

end Arbre;




