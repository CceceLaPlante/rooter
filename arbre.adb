-- with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;

--fonctionnement de l'arbre : 
-- c'est un arbre binaire de recherche particulier, les noeuds sont
-- vides (que des embranchements) et les feuilles contiennent une donnée (généric)
-- par contre, les clés sont des nb binaires en 32 bits, mais la relation d'ordre, constitue 
--    si le i-ème élément est un 0, alors dans le chemin pour aller jusqu'à la feuille
--    correspondante, alors on iras à gauche au i-ème embranchement, sinon on ira à droite.


package body arbre is

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => T_Node, Name => T_Arbre);
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
   function Taille (Arbre : T_Arbre) return Integer is
   begin
      if Est_Vide(Arbre) then
         return 0;
      else 
         return ( 1 + Taille(Arbre.Suivant_G) + Taille(Arbre.Suivant_D) );
      end if;
   end Taille;

   procedure Enregistrer (Arbre : in out T_Arbre ; Cle : String ; Donnee : T_Donnee) is
      -- On crée une fonction récursive qui va parcourir l'Arbre et enregistrer la clé mais qui prend en compte le 
      -- soucis de relation d'ordre entre les clés.
      procedure Enregistrer_r (Arbre : in out T_Arbre ; Cle : String ; Donnee : in T_Donnee; idx : in Integer ) is
        nuls : String(1..32) := (others => Character'Val(0));
        nul_donnee : T_Donnee;
      begin

         if Est_Vide(Arbre) then
            Arbre := New T_Node'(nuls, nul_donnee, Null, Null);  --les valeurs par défaut...
         end if;
         
         if idx > 32 then 
            Arbre.all.Cle := Cle;
            Arbre.all.Donnee := Donnee;
         elsif Cle(idx) = '0' then
            Enregistrer_r(Arbre.all.Suivant_G,Cle,Donnee,idx+1) ; -- on parcourt à gauche
         else
            Enregistrer_r(Arbre.all.Suivant_D,Cle,Donnee, idx+1); -- on parcourt à droite
         end if;

      end Enregistrer_r;

      begin
         Enregistrer_r(Arbre,Cle,Donnee,1);
   end Enregistrer;


   function Cle_Presente (Arbre : in T_Arbre ; Cle : in String) return Boolean is

      function Cle_Presente_r (Arbre : in T_Arbre ; Cle : in String; idx : in Integer) return Boolean is
      begin
         if Est_Vide(Arbre) then
            return False ;  -- La clé n'est pas présente car la liste est vide.

         elsif Arbre.all.Cle = Cle then
            return True;  -- On a trouvé la clé dans l'Arbre
         else
            if Cle(idx) = '0' then
               return Cle_Presente_r(Arbre.all.Suivant_G, Cle, idx+1); -- On parcours récursivement jusqu'à trouver la clé ou avoir un noeud suivant vide à gauche
            else
               return Cle_Presente_r(Arbre.all.Suivant_D, Cle,idx+1) ; -- idem à droite
            end if;
         end if;

      end Cle_Presente_r;

   begin
      return Cle_Presente_r(Arbre,Cle,1);
   end Cle_Presente;



   function La_Donnee (Arbre : in T_Arbre ; Cle : in String) return T_Donnee is
      function La_Donnee_r (Arbre : in T_Arbre ; Cle : in String; idx : in Integer) return T_Donnee is
      begin
         if Est_Vide(Arbre) then
            raise Constraint_Error with "cle inexistante"; -- La clé n'est pas présente car la liste est vide
         elsif  Arbre.all.Cle = Cle then
            return Arbre.all.Donnee;  -- On renvoie la donnee associée à la clé souhaitée.
         elsif Cle(idx) = '0' then
            return La_Donnee_r(Arbre.all.Suivant_G, Cle,idx+1); -- On cherche la clé dans les pointeurs à gauche
         else
            return La_Donnee_r(Arbre.all.Suivant_D, Cle,idx+1); -- On cherche la clé dans les pointeurs à droite
         end if;
      end La_Donnee_r;

   begin
      return La_Donnee_r(Arbre,Cle,1);
   end La_Donnee;


   -- dans cette procédure, on ne supprime QUE la feuille, et pas les parents obsolètes qui y menaient.
   -- cette procedure pourrait être améliorée en supprimant les parents obsolètes
   -- cependant, pour cela, il faudrais doublement chainer l'arbre   
   procedure Supprimer (Arbre : in out T_Arbre ; Cle : in String) is
      procedure Supprimer_r (Arbre : in out T_Arbre ; Cle : in String; idx : in Integer) is
      begin
         if Est_Vide(Arbre) then
            raise Constraint_Error with "cle inexistante";
         elsif Arbre.all.Cle = Cle then
            Free(Arbre); -- On supprime l'Arbre
         else
            if Cle(idx) = '0' then 
               Supprimer(Arbre.all.Suivant_G,Cle); -- On continue de chercher la bonne clé ou d'atteindre la dernière Arbre.
            else
               Supprimer(Arbre.all.Suivant_D,Cle);
            end if;
         end if;
      end Supprimer_r;
   begin
      Supprimer_r(Arbre,Cle,1);

   end Supprimer;


   procedure Vider (Arbre : in out T_Arbre) is
   begin
      if not Est_Vide(Arbre) then
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


end arbre;