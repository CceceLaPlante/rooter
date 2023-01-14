with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Unchecked_Deallocation;
with cache_ll; use cache_ll;


procedure routeur_ll is 

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

   procedure Afficher (adresse : in Unbounded_String ; Masque_Adresse: in Unbounded_String; interface_utilisation : in Unbounded_String) is
    begin
      Put_Line(adresse & To_Unbounded_String(" ") & Masque_Adresse & To_Unbounded_String(" ")& interface_utilisation);
    end Afficher ;

   procedure Afficher_cache is new Pour_Chaque(Afficher);
   
   procedure Afficher_Stats (Stats: in T_Stats) is
    begin
        Put("Nombre de défauts de Cache: ");
        Put(Float'Image(Stats.nb_defauts));
        Skip_Line ;
        Put("Nombre de demandes: ");
        Put(Float'Image(Stats.nb_demandes));
        Skip_Line ;
        Put("Taux de défauts: ");
        Put(Float'Image(Stats.taux_defauts));
        Skip_Line;
    end Afficher_Stats;
   
   procedure Free_Tab
   is new Ada.Unchecked_Deallocation (Object => T_Table, Name => T_Liste);
   
   procedure Initialiser_Table(table : Out  T_Liste) is
   begin
      table := Null;
   end Initialiser_Table;

   -- d'abord on s'occupe d'une conversion 4bit 
   function Convertir_IP2B_4 (adr : Integer) return Unbounded_String is 
      a_return : Unbounded_String :=To_Unbounded_String("");
      a_return_reversed : Unbounded_String :=To_Unbounded_String("");
      adr_cp : Integer := adr;
   begin
      for i in 1..8 loop
         if adr_cp mod 2 = 1 then
            -- on fais à l'envers parce qu'en binaire on fais de droite à gauche
            a_return := a_return & '1'; -- attention on vas inverser juste après !
         else
            a_return := a_return & '0'; 
         end if;
         -- on divise par 2 pour passer au bit suivant, on remarque que c'est une division entière car adr : Integer
         adr_cp := Integer(adr_cp / 2); 
      end loop;

      for i in 1..8 loop 
         -- on inverse la chaine de caractère
         a_return_reversed := a_return_reversed & Element(a_return, 9-i);
      end loop;


      return a_return_reversed;
   end Convertir_IP2B_4;
    

   -- puis on s'occupe de la conversion de l'adresse IP complète
   function Convertir_IP2B(Adresse_IP : Unbounded_String) return Unbounded_String is
      entier : Integer := 0;
      entier_string : Unbounded_String := To_Unbounded_String("");
      adr : adr4 ;
      idx : Integer := 1;
      --Adresse_IP_S : String := To_String(Adresse_IP);
        
   begin
      for i in 1..Length(Adresse_IP) loop
         case Element(Adresse_IP, i) is
            when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
               --on fait une conversion en entier pour pouvoir appliquer la fonction Convertir_IP2B_4
               entier_string := entier_string & Element(Adresse_IP, i);
            when '.' =>
               --touts les points, on convertis l'entier ainsi calculé en binaire
               entier := Integer'Value (To_String(entier_string));
               adr(idx) := Convertir_IP2B_4(entier) ;
               --Put_Line("entier, puis entier en binaire : "&entier_string&" , "&adr(idx));
               entier_string := To_Unbounded_String("");

               idx := idx + 1 ;
               entier := 0 ;
            when others =>
               null ;
         end case ;
      end loop ;

      entier := Integer'Value (To_String(entier_string));
      adr(idx) := Convertir_IP2B_4(entier) ;

      return adr(1) & adr(2) & adr(3) & adr(4) ; -- [!] on ne renvoi pas avec des points !!!! 
        
   end Convertir_IP2B;

   --Fonction prenant une ligne de la table de routage et la convertie en T_Table.
   --Attention cependant, tout est stocké sous forme de Unbounded_String.*
   -- on dois renseigner une clé, après elle ne sert pas vraiment...
   function Convertir_L2T(ligne : Unbounded_String ; cle : Integer) return T_Table is 
      destination : Unbounded_String;
      mask : Unbounded_String;
      inter : Unbounded_String;
      idx : Integer;
            
   begin
      idx := 1;
      -- on ajoute la ligne tant qu'on ne rencontre pas d'espace...
      while idx <= length(ligne) and then Element(ligne,idx) /= ' ' loop
         destination := destination & Element(ligne,idx); 
         idx := idx + 1;
      end loop;
      idx := idx + 1; -- on saute l'espace
      while idx <= length(ligne) and then Element(ligne,idx) /= ' ' loop
         mask := mask & Element(ligne,idx);
         idx := idx + 1;
      end loop;
      idx := idx + 1;
      while idx <= length(ligne) and then Element(ligne,idx) /= ' '  loop
         inter := inter & Element(ligne,idx);
         idx := idx + 1;
      end loop;
      -- on initialise suivant à Null pour la suite..
      -- ya ptet un problème avec cette ligne, cf tests.adb...
      return T_Table'(destination => destination, mask => mask, inter => inter, cle => cle,suivant => Null);

   end Convertir_L2T;

   -- Fonction qui renvoie True si le masque et l'adresse IP coïncident.
   function Masque(Adresse_IP : in Unbounded_String; ligne : in T_Table) return Boolean is 
      msk : constant Unbounded_String := ligne.mask;
      dest : constant Unbounded_String := ligne.destination;
      -- pour masquer il faut que l'adresse soit en binaire
      dest_binaire : constant Unbounded_String := Convertir_IP2B(dest);
      msk_binaire : constant Unbounded_String := Convertir_IP2B(msk);
      adr_binaire : constant Unbounded_String := Convertir_IP2B(Adresse_IP);

      a_return : Boolean := True;
   begin
      for idx in 1..length(adr_binaire) loop
         -- l'égalité ne s'applique que si le masque est à 1
         -- on utilise des and then par cohérence syntaxique et un peu par optimisation, mais c'est pas nécéssaire
         --Put_Line("msk et adresse binaire et destination binaire: masque "&msk_binaire&" adresse : "&adr_binaire&" destination "&dest_binaire);
         if Element(msk_binaire, idx) = '1' and then Element(adr_binaire,idx) /= Element(dest_binaire, idx) then
            a_return := False;
         end if;
      end loop;
      --Put_Line("eh jai renvoye true alors que : "&msk_binaire&" "&adr_binaire&" "&dest_binaire);
      --Put_Line("eh jai renvoye true alors que : "&ligne.mask&" "&Adresse_IP&" "&ligne.destination);
      return a_return;

   end Masque;


   -- prend un masque en entrée, et renvoie la somme des 1,ça permet de facilement en quantifier la taille...
   -- [!] prend un masque BINAIRE en entrée
   function somme_masque (m : Unbounded_String) return Integer is
      somme : Integer := 0;

   begin 
      for indice in 1..Length(m) loop
         somme := somme + Character'Pos(Element(m,indice)) ;
      end loop ;
      return somme ;

   end somme_masque;

   function Meilleur_Masque(lst : in T_Liste; Adresse_IP : in Unbounded_String; current : in out T_Table) return T_Table is --Fonction qui renvoie le masque le plus long qui correspond avec l'adresse.
   begin 
      -- condition d'arrêt : si on est arrivé au bout de la liste...

      --Put_Line("current meilleur masque : (adresse ip a la fin) "&current.destination&" "&current.mask&" "&Adresse_IP);

      if lst = Null then 
         return current; 

      elsif lst.all.mask /= To_Unbounded_String("") and then Masque(Adresse_IP,lst.all) then
         -- on compare les masques, et on garde le plus long
         if somme_masque(lst.all.mask) > somme_masque(current.mask) then
            current := lst.all;
            return Meilleur_Masque(lst.suivant,Adresse_IP,current);
            -- dans les autres cas, on continue à chercher
         else
            return Meilleur_Masque(lst.suivant,Adresse_IP,current);
         end if;
      else 
         return Meilleur_Masque(lst.suivant,Adresse_IP,current);
      end if;
   end Meilleur_Masque;

   --Procedure permettant d'écrire dans un fichier.
   procedure Ecrire(fichier : File_Type; a_ecrire : Unbounded_String) is
   begin
      Put_Line(fichier, a_ecrire);
   end Ecrire;

   --Fonction permettant de lire dans le fichier des destinations, il renvoie une ligne puis la suivante
   --à chaque appel.
   --Elle renvoie Null si c'est fini.
   -- [!] il faut que le fichier soit ouvert avant d'appeler cette fonction, et il faudras le fermer après !
   function Lire(fichier : File_Type) return Unbounded_String is 
      ligne_a_lire : Unbounded_String; 
   begin
      -- End_Of_File renvoie True si on est à la fin du fichier, et End_Error est une erreure relevée à la fin du fichier.
      if End_Of_File(fichier) then 
         ligne_a_lire := To_Unbounded_String("");
      else
         begin 
            ligne_a_lire := To_Unbounded_String(Get_Line(fichier));
         exception 
            when End_Error => 
               ligne_a_lire := To_Unbounded_String("");
         end;
      end if;
      return ligne_a_lire;
   end Lire;

   procedure Supprimer(Cache: in out T_LCA; Politique: in Unbounded_String) is
      Temps_max: Time;
      Freq_min: Integer;
      Adresse_min: Unbounded_String;
      Adresse_max: Unbounded_String;
   begin 

      if Politique = To_Unbounded_String("FIFO") then
         Supprimer_fifo(Cache);
      elsif Politique = To_Unbounded_String("LRU") then
         Adresse_max := To_Unbounded_String("00000000000000000000000000000000");
         temps_max := Clock ;
         Chercher_max_temps(Cache, Adresse_max, Temps_max);
         Supprimer_lru(Cache, Adresse_max);
      elsif Politique = To_Unbounded_String("LFU") then
         Adresse_min := To_Unbounded_String("00000000000000000000000000000000") ;
         freq_min := 0 ;
         Chercher_min_freq(Cache, Adresse_min, Freq_min);
         Supprimer_lfu(Cache, Adresse_min);
      else
         Null;
      end if;

   end Supprimer;


   --Fonction qui traite les commandes telles que "fin", "table"...
   procedure Traiter_Commande(commande: in Unbounded_String; nom_table : in Unbounded_String; Cache : in T_LCA; Affichage_Stats: in Boolean; Stats : in T_Stats; numero_ligne: in Integer) is 
      fichier_table : File_Type;
      ligne : Unbounded_String := To_Unbounded_String("");
   begin
      if commande = "table" then 
         Open(fichier_table,In_File ,To_String(nom_table)); 
         ligne := Lire(fichier_table);
         Skip_Line;
         Put(To_Unbounded_String("table (ligne "));
         Put(numero_ligne, 1);
         Put(To_Unbounded_String(")") );
         Skip_Line;
         while ligne /= To_Unbounded_String("") loop
            Put_Line(To_String(ligne));
            ligne := Lire(fichier_table);
         end loop;

         Close(fichier_table);
         Skip_Line;
         
   
      elsif commande = "cache" then
         Skip_Line;
         Put(To_Unbounded_String("cache (ligne "));
         Put(numero_ligne,1);
         Put(To_Unbounded_String(")" ));
         Skip_Line;
         Afficher_cache(Cache);
         Skip_Line;
         
      elsif Affichage_Stats then
         Skip_Line;
         Put_Line("-------------------------------- Statistiques --------------------------------");
         Afficher_Stats(Stats);
         Skip_Line;
         
      else
         Null ;
      end if;
               
   end Traiter_Commande; 

   procedure Traiter_Ligne_Commande (capacite_cache: out Integer; Politique: out Unbounded_String;
    Nom_entree: out Unbounded_String; Nom_sortie: out Unbounded_String; Nom_table: out Unbounded_String; Affichage_Stats: out Boolean) is
      politique_bool: Boolean;
      capacite_cache_bool: Boolean;
      entree_bool: Boolean;
      sortie_bool: Boolean;
      table_bool: Boolean;
      arg_count: Integer;
   
   begin
      politique_bool:= False;
      capacite_cache_bool:= False;
      entree_bool:= False;
      sortie_bool:= False;
      table_bool:= False;
      Affichage_Stats := True;
      Nom_entree := To_Unbounded_String("paquets.txt");
      Nom_sortie := To_Unbounded_String("resultats.txt");
      Nom_table := To_Unbounded_String("table.txt");
      Politique := To_Unbounded_String("FIFO");
      capacite_cache := 10;
      arg_count := Argument_Count;
      
      for VarBoucle in 1..arg_count loop
         if To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-p") then
            entree_bool:= True;      
         elsif entree_bool then
            Nom_entree := To_Unbounded_String(Argument(Varboucle));
            entree_bool:= False;
         elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-P") then
            politique_bool := True;
         elsif politique_bool then
            Politique := To_Unbounded_String(Argument(Varboucle));
            politique_bool:= False;
         elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-S") then
            Affichage_Stats := False;
         elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-t") then
            table_bool := True;
         elsif table_bool then
            Nom_table := To_Unbounded_String(Argument(Varboucle));
            table_bool:= False;
         elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-c") then
            capacite_cache_bool := True;
         elsif capacite_cache_bool then
            capacite_cache := Integer'Value(Argument(Varboucle));
            capacite_cache_bool:= False;
         elsif To_Unbounded_String(Argument(VarBoucle)) = To_Unbounded_String("-r") then
            sortie_bool := True;
         elsif sortie_bool then
            Nom_sortie := To_Unbounded_String(Argument(Varboucle));
            sortie_bool:= False;
         else
            Null;
         end if;
      end loop;

   end Traiter_Ligne_Commande;
    
   --fonction qui libère tout élément de type T_Liste
   procedure Liberer(table : in out T_Liste) is
   begin
      if table /= Null then
         Liberer(table.all.suivant);
      end if;
      Free_Tab(table);
   end Liberer;
   
   --Fonction qui permet de charger la table de routage dans une liste chaînée.
   --La première fois qu'on utilise chargement table, on utilise une liste_table Null.
   procedure Chargement_Table(liste_table : in out  T_Liste; fichier_tableT : in out File_Type; cle : Integer) is
      ligne_a_lire : Unbounded_String;
      ligne_L2T : T_Table; 
      --liste_table : T_Liste; --Table de routage reformatée

   begin
      liste_table := New T_Table;
      ligne_a_lire := Lire(fichier_tableT);
      if ligne_a_lire = To_Unbounded_String("") then
         Null;
      else
         --Put_Line("eh je charge-mental lolilol "&Integer'Image(cle));
         ligne_L2T := convertir_L2T(ligne_a_lire,cle);
         liste_table.all := ligne_L2T; -- j'ai jamais fais ça avant, alors ça marche sans doute, mais c'est à tester.
         Chargement_Table(liste_table.all.suivant, fichier_tableT,cle+1);
            
      end if;
   end Chargement_Table;
        
                

   ----------------------------------------------MAIN------------------------------------------------

   table : T_Liste := Null;
   ligne_a_lire : Unbounded_String;
   nom_entree: Unbounded_String;
   nom_sortie: Unbounded_String;
   nom_table: Unbounded_String;

   -- pour la fonction Lire, il faut pré-ouvrire les fichiers
   fichier_table : File_Type;
   fichier_entree : File_Type;
   fichier_sortie : File_Type;
   
   -- Variable qui sert pour la fonction Meilleur_Masque
   current_tab : T_Table;
   a_ecrire : Unbounded_String;

   -- Variables relatives au cache
   Cache : T_LCA;  
   Adresse_IP_Cache : Unbounded_String;
   Masque_Cache : Unbounded_String;
   Interface_Cache: Unbounded_String;
   Stats : T_Stats;
   numero_ligne: Integer;

   Affichage_Stats: Boolean;
   Politique: Unbounded_String;
   capacite_cache: Integer;
     
begin

   Traiter_Ligne_Commande (capacite_cache, Politique, nom_entree, nom_sortie, nom_table, Affichage_Stats);
   Initialiser(Cache,Stats);

   Open(fichier_table,In_File,To_String(nom_table));
   Open(fichier_entree,In_File,To_String(nom_entree));
   Create(fichier_sortie,Out_File,To_String(nom_sortie));

   Initialiser_Table(table);
   --table := New T_Table;
   -- on donne table Null, et 0 comme clé, parce que la fonction est réccurssive et à besoin de ces paramètres.
   Chargement_Table(table, fichier_table,0);
   Close(fichier_table);
   ligne_a_lire := Lire(fichier_entree);

   numero_ligne := 1;
   while (not (ligne_a_lire = "fin") and not End_Of_File(fichier_entree) and not (ligne_a_lire = To_Unbounded_String(""))) loop

      current_tab.cle := 0;
      current_tab.mask := To_Unbounded_String("0.0.0.0");
      current_tab.inter := To_Unbounded_String("Adress does not match any known network");
      current_tab.suivant := Null;
      current_tab.destination := To_Unbounded_String("0.0.0.0");
      

      case Element(ligne_a_lire,1) is 
         when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>

            Adresse_IP_Cache := ligne_a_lire;
            if Presence_masque(Cache,Adresse_IP_Cache) then 
               Masque_Cache := Masquer_Cache(Cache,Adresse_IP_Cache);
               Interface_Cache := Interface_du_Cache(Cache,Stats,Adresse_IP_Cache, Masque_Cache);
            else
               Null;
            end if;
            
            if not Adresse_Presente(Cache, Stats, Adresse_IP_Cache, Masque_Cache) then
               Masque_Cache := Meilleur_Masque(table, ligne_a_lire, current_tab).mask;
               Interface_Cache := Meilleur_Masque(table, ligne_a_lire, current_tab).inter;
               if Est_Pleine(Cache, capacite_cache) then
                  Supprimer(Cache, Politique);
               end if;
               Enregistrer(Cache, Stats, Adresse_IP_Cache, Interface_Cache,Masque_Cache);
            else 
               Stats.nb_demandes := Stats.nb_demandes + 1.0 ;
               Stats.taux_defauts := Stats.nb_defauts/Stats.nb_demandes ;
            end if ;

            a_ecrire := ligne_a_lire & To_Unbounded_String(" ")& Interface_Cache;
            Ecrire(fichier_sortie, a_ecrire);

         when others =>
            Traiter_Commande(ligne_a_lire, nom_table, Cache, Affichage_Stats, Stats, numero_ligne);
      end case;

      ligne_a_lire := Lire(fichier_entree);
      numero_ligne := numero_ligne + 1; 

   end loop;

   Put_Line(To_Unbounded_String("fin (ligne") & Integer'Image(numero_ligne) & To_Unbounded_String(")"));

   Close(fichier_entree);
   Close(fichier_sortie);

   Liberer(table) ;

   --Put_Line("convertire 0.0.0.3 "&Convertir_IP2B(To_Unbounded_String("0.0.0.3")));
   if Affichage_Stats then
      Afficher_Stats(Stats);
   end if;
   Vider(Cache,Stats);

end routeur_ll;
