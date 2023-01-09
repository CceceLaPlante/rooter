with LCA ;
with SDA_Exceptions;         use SDA_Exceptions;

package body Cache_fifo is

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);
   
   procedure Initialiser(Cache : out T_LCA; Stats : out T_Stats) is
   begin
      Cache := Null ;
      Stats.nb_demandes := 0.0 ;
      Stats.nb_defauts := 0.0 ;
      Stats.taux_defauts := 0.0 ;
   end Initialiser ;

   function Est_Vide(Cache : in T_LCA) return Boolean is
   begin
      return (Cache = Null) ;
   end Est_Vide ;

   procedure Supprimer(Cache : in out T_LCA) is -- fonction Ã  "supprimer" pour la passer en gÃ©nÃ©rique dans le cache_ll et rÃ©utiliser sinon les autres sous-programmes !
      pointeur_debut : T_LCA ;
   begin
      pointeur_debut := Cache.all.Suivant ; -- on rÃ©cupÃ¨re l'adresse du deuxiÃ¨me Ã©lÃ©ment du cache
      Free(Cache); -- on libÃ¨re le premier Ã©lÃ©ment ---- condition Ã  changer en fonction de la politique du cache !
      Cache := pointeur_debut ; -- on rÃ©cupÃ¨re le cache Ã  partir du deuxiÃ¨me Ã©lÃ©ment
   end Supprimer;

   procedure Enregistrer(Cache : in out T_LCA; Stats : in out T_Stats; Adresse_IP : in Unbounded_String; Interface_Adresse : in Unbounded_String) is
   begin
      if Est_Vide(Cache) then
         Cache := new T_Cellule'(Adresse => Adresse_IP, Nombre_utilisation => 0, Cle => (Taille(Cache) + 1), Suivant => Null, Interface_utilisation => Interface_Adresse);
         Stats.nb_demandes := Stats.nb_demandes + 1.0 ;
         Stats.nb_defauts := Stats.nb_defauts + 1.0 ;
         Stats.taux_defauts := Stats.nb_defauts / Stats.nb_demandes ;
      elsif (Cache.all.Adresse /= Adresse_IP) then
         Enregistrer(Cache.all.Suivant, Stats, Adresse_IP, Interface_Adresse);
      else 
         Stats.nb_demandes := Stats.nb_demandes + 1.0 ;
         Stats.taux_defauts := Stats.nb_defauts / Stats.nb_demandes ;
         Cache.all.Nombre_utilisation := Cache.all.Nombre_utilisation + 1;
      end if ;
   end Enregistrer ;

   procedure Vider(Cache : in out T_LCA; Stats : in out T_Stats) is -- on dÃ©compose les entrÃ©es pour pouvoir parcourir la LCA rÃ©cursivement
   begin
      if Est_Vide(Cache) then
         Null ;
      else
         Vider(Cache.all.Suivant, Stats) ;
      end if;
      Free(Cache);
      if (Stats.nb_demandes /= 0.0) and (Stats.nb_defauts /= 0.0) and (Stats.taux_defauts /= 0.0) then -- pour ne passer les diffÃ©rents paramÃ¨tres Ã  zÃ©ro une seule fois
         Stats.nb_demandes := 0.0 ;
         Stats.nb_defauts := 0.0 ;
         Stats.taux_defauts := 0.0 ;
      end if;
   end Vider ;

   function Adresse_Presente(Cache : in T_LCA; Stats : in T_Stats; Adresse : in Unbounded_String) return Boolean is
   begin
      if Est_Vide(Cache) then
         return False ;
      elsif Cache.all.Adresse = Adresse then
         return True ;
      else
         return Adresse_Presente(Cache.all.Suivant, Stats, Adresse);
      end if ;
   --exception when 
           --Adresse_Absente_Exception => return False ;
   end Adresse_Presente ;

   function Taille(Cache : in T_LCA) return Integer is
   begin
      if Est_Vide(Cache) then
         return 0 ;
      else
         return (1+Taille(Cache.all.Suivant)) ;
      end if;
   end Taille;

   function Est_Pleine(Cache : in T_LCA; capacite_cache : in Integer) return Boolean is
   begin
      return (Taille(Cache) = capacite_cache) ;
   end Est_Pleine ;

end Cache_fifo ;
