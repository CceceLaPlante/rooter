with cache_ll ; use cache_ll;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;


procedure test_cache_ll is 

   --package cache_ll_utilisation is new cache_ll(capacite_cache => 5) ;
   --use cache_ll_utilisation;
   
   procedure Afficher (adresse : in Unbounded_String ; Masque_Adresse: in Unbounded_String; interface_utilisation : in Unbounded_String) is
    begin
        Put("Adresse : ");
        Put(To_String(adresse));
        Skip_Line ;
        Put("Masque: ");
        Put(To_String(Masque_Adresse));
        Skip_Line ;
        Put("Interface : ");
        Put(To_String(interface_utilisation));
        Skip_Line;
    end Afficher ;

   procedure Afficher_cache is new cache_ll.Pour_Chaque(Afficher);

   Un_Cache : T_LCA ;
   Stats : T_Stats ;
   capacite_cache : constant := 5 ;
   min : Unbounded_String;
   freq_min : Integer ;
   max : Unbounded_String ;
   temps_max : Time ;
   Interface_test : Unbounded_String;
   
begin
   
   --Test Général sur l'enregistrement et la suppression d'adresses. 
   Skip_Line;
   Put_Line("Début du premier test");
   Skip_Line;
   Initialiser(Un_Cache, Stats) ; 
   pragma assert (Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 1");
   --pragma assert (Adresse_Presente(Un_Cache,Stats, "147.255.32.57")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   pragma assert (Stats.nb_demandes = 1.0) ;
   pragma assert (Stats.nb_defauts = 1.0) ;
   pragma assert (Taille(Un_Cache) = 1) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.65.36"),To_Unbounded_String("eth1"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 2");
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   --pragma assert (Un_Cache.all.Suivant.all.Adresse = "147.255.65.36") ;
   --pragma assert (Un_Cache.all.Suivant.all.Interface_utilisation = "eth1") ;
   pragma assert (Stats.nb_demandes = 2.0) ;
   pragma assert (Stats.nb_defauts = 2.0) ;
   pragma assert (Taille(Un_Cache) = 2) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"), To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 3");
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
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("152.215.98.57"),To_Unbounded_String("eth2"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 4");
   
   Enregistrer(Un_Cache,Stats,To_Unbounded_String("136.145.6.63"),To_Unbounded_String("eth3"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 5");

   Enregistrer(Un_Cache,Stats,To_Unbounded_String("254.168.15.76"),To_Unbounded_String("eth4"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 6");
   pragma assert (Taille(Un_Cache) = 5) ;
   pragma assert (Est_Pleine(Un_Cache, capacite_cache)) ;
   
   Supprimer_fifo(Un_Cache);
   Afficher_cache(Un_Cache);
   Put_Line("Etape 7");
   --pragma assert (Un_Cache.all.Adresse = "147.255.65.36") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth1") ;
   pragma assert (Taille(Un_Cache) = 4) ;
   --Put_Line("Etape 7 - 1");
   pragma assert (not Est_Vide(Un_Cache)) ;
   --Put_Line("Etape 7 - 2");
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   --Put_Line("Juste avant Chercher min freq");
   min := To_Unbounded_String("00000000000000000000000000000000") ;
   freq_min := 0 ;
   Chercher_min_freq(Un_Cache, min, freq_min);
   --Put_Line("Juste avant Supprimer lfu");
   Supprimer_lfu(Un_Cache,min);
   --Put_Line("Juste avant le afficher");
   Afficher_cache(Un_Cache);
   Put_Line("Etape 8");
   pragma assert (Taille(Un_Cache) = 3) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
    
   --Put_Line("Juste avant Chercher max temps");
   max := To_Unbounded_String("00000000000000000000000000000000");
   temps_max := Clock ;
   Chercher_max_temps(Un_Cache, max, temps_max);
   --Put_Line("Juste avant Supprimer lfu");
   Supprimer_lru(Un_Cache,max);
   Afficher_cache(Un_Cache);
   Put_Line("Etape 9");
   pragma assert (Taille(Un_Cache) = 2) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
   
   Vider(Un_Cache, Stats) ; 
   pragma assert (Est_Vide(Un_Cache));
   pragma assert (Taille(Un_Cache) = 0);
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache));

   -- Début du test concernant les caches.
   Skip_Line;
   Put_Line("Début du deuxième test");
   Skip_Line;
   Initialiser(Un_Cache, Stats) ; 
   pragma assert (Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;

   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 1");
   --pragma assert (Adresse_Presente(Un_Cache,Stats, "147.255.32.57")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   pragma assert (Stats.nb_demandes = 1.0) ;
   pragma assert (Stats.nb_defauts = 1.0) ;
   pragma assert (Taille(Un_Cache) = 1) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   pragma assert (Adresse_Presente(Un_Cache, Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.255.255")));
   pragma assert ( not Adresse_Presente(Un_Cache, Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.0.0")));

   Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.0.0")) ;
   Afficher_cache(Un_Cache);
   Put_Line("Etape 2");
   --pragma assert (Adresse_Presente(Un_Cache,Stats, "147.255.32.57")) ;
   --pragma assert (Un_Cache.all.Adresse = "147.255.32.57") ;
   --pragma assert (Un_Cache.all.Interface_utilisation = "eth0") ;
   pragma assert (Stats.nb_demandes = 2.0) ;
   pragma assert (Stats.nb_defauts = 2.0) ;
   pragma assert (Taille(Un_Cache) = 2) ;
   pragma assert (not Est_Vide(Un_Cache)) ;
   pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
   pragma assert (Adresse_Presente(Un_Cache, Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.0.0")));

   Put_Line("Début du troisième test");
   Interface_test := Interface_Cache(Un_Cache,Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.0.0"));
   pragma assert (Interface_test =To_Unbounded_String("eth0"));

   
end test_cache_ll;
