with cache_ll ; use cache_ll;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;


procedure test_cache_ll is 
   
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
   
    Put_Line("Test Insertion d'une première adresse dans le cache...");
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);
    pragma assert (Stats.nb_demandes = 1.0) ;
    pragma assert (Stats.nb_defauts = 1.0) ;
    pragma assert (Taille(Un_Cache) = 1) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line;
   
    Put_Line("Test Insertion d'une seconde adresse différente de la première dans le cache...");
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.65.36"),To_Unbounded_String("eth1"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);
    pragma assert (Stats.nb_demandes = 2.0) ;
    pragma assert (Stats.nb_defauts = 2.0) ;
    pragma assert (Taille(Un_Cache) = 2) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line;

    Put_Line("Test Insertion d'une adresse déjà présente avec le même masque dans le cache...");
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"), To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);
    pragma assert (Stats.nb_demandes = 3.0) ;
    pragma assert (Stats.nb_defauts = 2.0) ;
    pragma assert (Taille(Un_Cache) = 2) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line;
   
    Put_Line("Test cache plein...");
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("152.215.98.57"),To_Unbounded_String("eth2"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);
   
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("136.145.6.63"),To_Unbounded_String("eth3"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);

    Enregistrer(Un_Cache,Stats,To_Unbounded_String("254.168.15.76"),To_Unbounded_String("eth4"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);
    pragma assert (Taille(Un_Cache) = 5) ;
    pragma assert (Est_Pleine(Un_Cache, capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line;

    Put_Line("Test supprimer un élément du cache en politique FIFO...");
    Supprimer_fifo(Un_Cache);
    Afficher_cache(Un_Cache);
    pragma assert (Taille(Un_Cache) = 4) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line;
   
    Put_Line("Test supprimer un élément du cache en politique LFU...");
    min := To_Unbounded_String("00000000000000000000000000000000") ;
    freq_min := 0 ;
    Chercher_min_freq(Un_Cache, min, freq_min);
    Supprimer_lfu(Un_Cache,min);
    Afficher_cache(Un_Cache);
    pragma assert (Taille(Un_Cache) = 3) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line ;
    
    Put_Line("Test supprimer un élément du cache en politique LRU...");
    max := To_Unbounded_String("00000000000000000000000000000000");
    temps_max := Clock ;
    Chercher_max_temps(Un_Cache, max, temps_max);
    Supprimer_lru(Un_Cache,max);
    Afficher_cache(Un_Cache);
    pragma assert (Taille(Un_Cache) = 2) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;
    Put_Line("Test OK");
    Skip_Line;
   
    Put_Line("Test vider le cache...");
    Vider(Un_Cache, Stats) ; 
    pragma assert (Est_Vide(Un_Cache));
    pragma assert (Taille(Un_Cache) = 0);
    pragma assert (not Est_Pleine(Un_Cache, capacite_cache));
    Put_Line("Test OK"); 
    Skip_Line;

    -- Début du test concernant les caches.
    Skip_Line;
    Put_Line("Début du deuxième test");
    Skip_Line;
    Initialiser(Un_Cache, Stats) ; 
    pragma assert (Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache,capacite_cache)) ;

    Put_Line("Test enregistrer la même adresse mais avec un masque différent...");
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
    Afficher_cache(Un_Cache);
    pragma assert (Stats.nb_demandes = 1.0) ;
    pragma assert (Stats.nb_defauts = 1.0) ;
    pragma assert (Taille(Un_Cache) = 1) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
    pragma assert (Adresse_Presente(Un_Cache, Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.255.255")));
    pragma assert ( not Adresse_Presente(Un_Cache, Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.0.0")));

    Enregistrer(Un_Cache,Stats,To_Unbounded_String("147.255.32.57"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.0.0")) ;
    Afficher_cache(Un_Cache);
    pragma assert (Stats.nb_demandes = 2.0) ;
    pragma assert (Stats.nb_defauts = 2.0) ;
    pragma assert (Taille(Un_Cache) = 2) ;
    pragma assert (not Est_Vide(Un_Cache)) ;
    pragma assert (not Est_Pleine(Un_Cache, capacite_cache)) ;
    pragma assert (Adresse_Presente(Un_Cache, Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.0.0")));
    Put_Line("Test OK"); 
    Skip_Line;
   
    --Début du test sur les fonctions annexes appelées directement par le routeur
    Skip_Line;
    Put_Line("Début du troisième test");
    Skip_Line;
    
    Put_Line("Test recherche de l'interface à partir d'une adresse et d'un masque");
    Interface_test := Interface_du_Cache(Un_Cache,Stats, To_Unbounded_String("147.255.32.57"), To_Unbounded_String("255.255.0.0"));
    pragma assert (Interface_test =To_Unbounded_String("eth0"));
    Put_Line("Test OK"); 
    
    Put_Line("Test sur la présence d'un masque");
    pragma assert(Presence_masque(Un_Cache,To_Unbounded_String("147.255.32.57")));
    Put_Line("Test OK");
    
    Put_Line("Test sur masquer une adresse");
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("140.255.32.157"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.255")) ;
    Enregistrer(Un_Cache,Stats,To_Unbounded_String("140.255.32.157"),To_Unbounded_String("eth0"), To_Unbounded_String("255.255.255.0")) ;
    pragma assert(Masquer_Cache(Un_Cache,To_Unbounded_String("140.255.32.158"))= To_Unbounded_String("255.255.255.0"));
    Put_Line("Test OK");
                  
    
   
end test_cache_ll;

