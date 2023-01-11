with cache_ll ;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Calendar; use Ada.Calendar;
with cache_exception; use cache_exception ;


procedure test_cache_ll is 

   package cache_ll_utilisation is new Cache_fifo(capacite_cache => 5) ;
   use cache_ll_utilisation;
   
   procedure Afficher_cache is new Cache_fifo_utilisation.Pour_Chaque(Afficher);
   
   procedure Afficher (adresse : in Unbounded_String ; interface_utilisation : in Unbounded_String) is
    begin
        Put("Adresse : ");
        Put(To_Unbounded_String(adresse));
        Skip_Line ;
        Put("interface : ");
        Put(To_Unbounded_String(interface_utilisation));
        Skip_Line ;
    end Afficher ;

   Un_Cache : T_LCA ;
   Stats : T_Stats ;
   capacite_cache : constant := 5 ;
   min : Unbounded_String;
   freq_min : Integer ;
   max : Unbounded_String ;
   temps_max : out Horaire ;
   
begin

   Initialiser(Un_Cache, Stats) ; 
   pragma assert (Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0")) ;
   Afficher_cache(Un_Cache);
   --pragma assert (Adresse_Presente(Un_Cache,Stats, "147.255.32.57")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   pragma assert (Stats.nb_demandes = 1.0) ;
   pragma assert (Stats.nb_defauts = 1.0) ;
   pragma assert (Taille(Un_Cache) = 1) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.65.36"),To_Unbounded_String("eth1")) ;
   Afficher_cache(Un_Cache);
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
   Afficher_cache(Un_Cache);
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
   Afficher_cache(Un_Cache);
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("136.145.6.63"),To_Unbounded_String("eth3")) ;
   Afficher_cache(Un_Cache);
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("254.168.15.76"),To_Unbounded_String("eth4")) ;
   Afficher_cache(Un_Cache);
   pragma assert (Taille(Un_Cache) = 5) ;
   pragma assert (Est_Pleine(Un_Cache, capacite_cache)) ;
   
   Supprimer_fifo(Un_Cache);
   Afficher_cache(Un_Cache);
   --pragma assert (Un_Cache.all.Adresse = "147.255.65.36") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth1") ;
   pragma assert (Taille(Un_Cache) = 4) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   Chercher_min_freq(Un_Cache, min, freq_min);
   Supprimer_lfu(Un_Cache,min);
   Afficher_cache(Un_Cache);
   pragma assert (Taille(Un_Cache) = 3) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   Chercher_min_freq(Un_Cache, max, temps_max);
   Supprimer_lru(Un_Cache,max);
   Afficher_cache(Un_Cache);
   pragma assert (Taille(Un_Cache) = 2) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   Vider(Un_Cache, Stats) ; 
   
end test_cache_ll;

