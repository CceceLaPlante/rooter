-- with Ada.Text_IO;            use Ada.Text_IO;
with Arbre_Exceptions;         use Arbre_Exceptions;
with Ada.Unchecked_Deallocation;

package body Arbre is

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Arbre);

   -- On initialise l'Arbre étant vide.
   procedure Initialiser(Arbre: out T_Arbre) is
   begin
      Arbre := Null;	
   end Initialiser;


   function Est_Vide (Arbre : T_Arbre) return Boolean is
   begin
      return (Arbre = Null);    -- Renvoie True si l'Arbre est vide
   end;

   -- On calcule la taille en parcourant récursivement l'Arbre et en ajoutant 1 à chaque pointeur non vide.
   function Taille (Arbre : in T_Arbre) return Integer is
   begin
      if Arbre = Null then
         return 0;
      else 
         return ( 1 + Taille(Arbre.Suivant_G) + Taille(Arbre.Suivant_D) );
      end if;
   end Taille;

   procedure Enregistrer (Arbre : in out T_Arbre ; Cle : in T_Cle ; Donnee : in T_Donnee) is
   begin
      if Arbre = Null then
         Arbre := New T_Node'(Cle, Donnee, Null);   -- On crée une cellule dans laquelle on enregistre la clé et la donnée souhaitées.
      elsif Arbre.all.Cle > Cle then   
           Enregistrer(Arbre.all.Suivant_G,Cle,Donnee) ; -- on parcourt à gauche
      else
            Enregistrer(Arbre.all.Suivant_D,Cle,Donnee); -- on parcourt à droite
      end if;
   end Enregistrer;


   function Cle_Presente (Arbre : in T_Arbre ; Cle : in T_Cle) return Boolean is
   begin
      if Arbre = Null then
         return False ;  -- La clé n'est pas présente car la liste est vide.
      elsif Arbre.all.Cle = Cle then
         return True;  -- On a trouvé la clé dans l'Arbre
      else
         return Cle_Presente(Arbre.all.Suivant_G, Cle); -- On parcours récursivement jusqu'à trouver la clé ou avoir un noeud suivant vide à gauche
         return Cle_Presente(Arbre.all.Suivant_D, Cle) ; -- idem à droite
      end if;
   end Cle_Presente;



   function La_Donnee (Arbre : in T_Arbre ; Cle : in T_Cle) return T_Donnee is
   begin
      if Arbre = Null then
         raise Cle_Absente_Exception;
      elsif  Arbre.all.Cle = Cle then
         return Arbre.all.Donnee;  -- On renvoie la donnee associée à la clé souhaitée.
      elsif Cle < Abre.all.Cle then
         return La_Donnee(Arbre.all.Suivant_G, Cle); -- On cherche la clé dans les pointeurs à gauche
      else
         return La_Donnee(Arbre.all.Suivant_D, Cle); -- On cherche la clé dans les pointeurs à droite
      end if;
   end La_Donnee;

  
   procedure Supprimer (Arbre : in out T_Arbre ; Cle : in T_Cle) is
      Next : T_Arbre;   -- La liste suivante
      
   begin
      if Arbre = Null then
         raise Cle_Absente_Exception;
      elsif Arbre.all.Cle = Cle then
         Next := Arbre; 
         Arbre := Arbre.all.Suivant; -- On associe l'Arbre suivante à celle que l'on souhaite supprimée. Elle est ainsi "effacée".
         Free(Next); -- On libère l'emplacement de l'Arbre correspondant à Cle dans la mémoire.
      else
         Supprimer(Arbre.all.Suivant_G,Cle); -- On continue de chercher la bonne clé ou d'atteindre la dernière Arbre.
         Supprimer(Arbre.all.Suivant_D,Cle);
      end if;

   end Supprimer;


   procedure Vider (Arbre : in out T_Arbre) is
   begin
      if Arbre /= Null then
         Vider(Arbre.all.Suivant_G); -- On parcours l'Arbre récursivement pour arriver à la dernière.
         Vider(Arbre.all.Suivant_D);
      end if;
      Free(Arbre);    -- On vide chaque Arbre
   end Vider;


   procedure Pour_Chaque (Arbre : in T_Arbre) is
   begin
      if Est_vide(Arbre) then
         null ;
      else
         begin
            Traiter(Arbre.all.Cle, Arbre.all.Donnee); -- On utilise la fonction que l'on souhaite comme Traiter est générique.
         exception
            when others =>
               Null ;
         end ;
         Pour_Chaque(Arbre.all.Suivant_G) ; -- On applique le traitement récursivement à chaque Arbre.
         Pour_Chaque(Arbre.all.Suivant_D) ;
      end if ;
   end Pour_Chaque;


end Arbre;