with Cache_fifo ;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

procedure ex_utilisation_cache_fifo is 

   package Cache_fifo_utilisation is new Cache_fifo(capacite_cache => 5) ;
   use Cache_fifo_utilisation;

   Un_Cache : T_LCA ;
   Stats : T_Stats ;
   capacite_cache : constant := 5 ;
   
begin
   Initialiser(Un_Cache, Stats) ; 
   pragma assert (Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0")) ;
   --pragma assert (Adresse_Presente(Un_Cache,Stats, "147.255.32.57")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   pragma assert (Stats.nb_demandes = 1.0) ;
   pragma assert (Stats.nb_defauts = 1.0) ;
   pragma assert (Taille(Un_Cache) = 1) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.65.36"),To_Unbounded_String("eth1")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   --pragma assert (Un_Cache.all.Suivant.all.Adresse = "147.255.65.36") ;
   --pragma assert (Un_Cache.all.Suivant.all.Interface_utilisation = "eth1") ;
   pragma assert (Stats.nb_demandes = 2.0) ;
   pragma assert (Stats.nb_defauts = 2.0) ;
   pragma assert (Taille(Un_Cache) = 2) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"), To_Unbounded_String("eth0")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   --pragma assert (Un_Cache.all.Suivant.all.Adresse = "147.255.65.36") ;
   --pragma assert (Un_Cache.all.Suivant.all.Interface_utilisation = "eth1") ;
   --pragma assert (Un_Cache.all.Suivant.all.Suivant.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Suivant.all.Suivant.all.Interface_utilisation = "eth0") ;
   pragma assert (Stats.nb_demandes = 3.0) ;
   pragma assert (Stats.nb_defauts = 2.0) ;
   pragma assert (Taille(Un_Cache) = 2) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("152.215.98.57"),To_Unbounded_String("eth2")) ;
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("136.145.6.63"),To_Unbounded_String("eth3")) ;
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("254.168.15.76"),To_Unbounded_String("eth4")) ;
   pragma assert (Taille(Un_Cache) = 5) ;
   pragma assert (Est_Pleine(Un_Cache, capacite_cache)) ;
   Supprimer(Un_Cache);
   --pragma assert (Un_Cache.all.Adresse = "147.255.65.36") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth1") ;
   pragma assert (Taille(Un_Cache) = 4) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   Vider(Un_Cache, Stats) ; 
end ex_utilisation_cache_fifo;


