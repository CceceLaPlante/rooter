with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 

procedure routeur_simple is 

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

   
   procedure Free
   is new Ada.Unchecked_Deallocation (Object => T_Table, Name => T_Liste);
   
   procedure Initialiser_Table(table : Out  T_Liste) is
   begin
      table := Null;
   end Initialiser_Table;
    
   Type T_adresse_IP is mod 2 ** 32;
   -- renvois la taille d'une T_Liste
   
   function length(lst : T_Liste) return Integer is
   begin
      if lst /= Null then
         return 1 + length(lst.Suivant); -- appel réccursif de la fonction classique ...
      else
         return 0;
      end if;
   end length;

-- Fonction qui converti les adresses IP en nombre binaire.
   -- Elle servira à appliquer les masques.


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
      type adr4 is array(1..4) of Unbounded_String;
      adr : adr4 ;
      idx : Integer := 1;
      Adresse_IP_S : String := To_String(Adresse_IP);
        
   begin
      for i in 1..Length(Adresse_IP) loop
         case Element(Adresse_IP, i) is
            when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
               --on fait une conversion en entier pour pouvoir appliquer la fonction Convertir_IP2B_4
               --begin
                  --entier := entier + (Character'Pos(Element(Adresse_IP,i))- Character'Pos('0') )*(10**true_i) ;
               --exception 
                  --when constraint_error =>
                     --Put_Line("constraint error");
               --end;

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

      return adr(1) & adr(2) & adr(3) & adr(4) ; -- [!] on ne renvoi pas avec des points !!!! 
        
   end Convertir_IP2B;

   -- Fonction qui convertie les adresses IP en entier.
   -- je ne crois pas qu'on l'utilise donc.. bon.. [!] par contre, je pense que la fonction est buggée, parce que si on a un . 
   -- l'adresse IP, il continue de s'incrémenter et dcp l'adresse IP est fucked up
   function Convertir_IP2I(Adresse_IP : in Unbounded_String) return Integer is
      entier : Integer := 0;
   begin
      for i in 1..Length(Adresse_IP) loop
         case Element(Adresse_IP, i) is
            when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
               entier := entier + Integer(Character'Pos(Element(Adresse_IP,i))*(10**i)) ;
            when others =>
               null ;
         end case ;
      end loop ;
      return entier ;
   end Convertir_IP2I;

   -- Fonction qui convertie les adresses binaires en adresses IP.
   -- alors je crois que c'est pas grave parce qu'on ne l'utilise pas (pour l'instant), mais elle n'est pas compatible avec 
   -- la conversion IP2B (présence de points...)
   function Convertir_B2IP(Adresse_IP : in Unbounded_String) return Unbounded_String is
      puissance : Integer;
      nombre_entier : Integer;
      nombre : Unbounded_String;
      indice : Integer;
      octet : Integer;

   begin
      indice := 1 ;
      octet := 1 ;
      nombre := To_Unbounded_String("");

      while octet /= 4 loop 
         -- on descend les puissances, de 7 à 0, parce que les nombres binaire se lisent de droite à gauche
         puissance := 7 ; 
         nombre_entier := 0 ;

         while puissance /= 0 loop
            nombre_entier := nombre_entier + Integer((Character'Pos(Element(Adresse_IP,indice))-Character'Pos('0'))*(2**puissance)) ;
            puissance := puissance - 1 ;
            indice := indice + 1 ;

         end loop ;
         if octet /= 1 then
            nombre := nombre & "." & To_Unbounded_String(nombre_entier)  ;
         else
            nombre := To_Unbounded_String(nombre_entier) ;
         end if ;
         octet := octet + 1 ;
      end loop ;
      return nombre ;
   end Convertir_B2IP;

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
      msk : Unbounded_String := ligne.mask;
      dest : Unbounded_String := ligne.destination;
      -- pour masquer il faut que l'adresse soit en binaire
      dest_binaire : Unbounded_String := Convertir_IP2B(dest);
      msk_binaire : Unbounded_String := Convertir_IP2B(msk);
      adr_binaire : Unbounded_String := Convertir_IP2B(Adresse_IP);
   begin
      for idx in 1..length(adr_binaire) loop
         -- l'égalité ne s'applique que si le masque est à 1
         -- on utilise des and then par cohérence syntaxique et un peu par optimisation, mais c'est pas nécéssaire
         --Put_Line("msk et adresse binaire et destination binaire: masque "&msk_binaire&" adresse : "&adr_binaire&" destination "&dest_binaire);
         if Element(msk_binaire, idx) = '1' and Element(adr_binaire,idx) /= Element(dest_binaire, idx) then
            return False;
         end if;
      end loop;
      --Put_Line("eh jai renvoye true alors que : "&msk_binaire&" "&adr_binaire&" "&dest_binaire);
      --Put_Line("eh jai renvoye true alors que : "&ligne.mask&" "&Adresse_IP&" "&ligne.destination);
      return True;

   end Masque;


   ------------
   --Renvoie le masque le plus long qui correspond avec l'adresse.

   --    function Meilleur_Masque(Lst : T_Liste; Adresse_IP : in String) return T_Table is
   --        indice : Integer ;
   --        taille_max : Integer ;
   --        current : Integer ;
   --        taille_current : Integer ;
   --        ligne : T_Table;
   --    begin
   --        taille_max := 0 ;
   --
   --        while indice /= length(Lst) loop
   --            taille_current := 0 ;
   --            ligne := Lst(indice).all ;
   --
   --            if Masque(Adresse_IP,ligne) then
   --                -- On parcourt l'adresse IP à l'envers pour réduire la complexité
   --                -- ehh je comprend pas pk ça optimise de parcourir à l'envers ? emma i need ansers ;( (céleste)
   --                current := Length(Adresse_IP(indice)) ; 
   --
   --                while current /= 0 loop
   --                    if Adresse_IP(current) = '.' then
   --                        null ;
   --                  elsif Adresse_IP(current) /= 0 then
   --                        taille_current := taille_current + 1 ;
   --                  else
   --                           null ;
   --                  end if ;
   --
   --                  current := current - 1 ;
   --                end loop ;
   --
   --                if taille_current > taille_max then
   --                    taille_max := taille_current ;
   --                      adresse_max := Adresse_IP(indice) ;
   --
   --                end if ;
   --            else
   --                    null ;
   --            end if ;
   --
   --        end loop ;
   --
   --        return adresse_max ;
   --
   --    end Meilleur_Masque;


   -----------------------
   -- prend un masque en entrée, et renvoie la somme des 1,ça permet de facilement en quantifier la taille...
   -- [!] prend un masque BINAIRE en entrée
   function somme_masque (m : Unbounded_String) return Integer is
      somme : Integer := 0;

   begin 
      for indice in 1..Length(m) loop
         somme := somme + Character'Pos(Element(m,indice)) - Character'Pos('0') ;
      end loop ;
      return somme ;

   end somme_masque;

   function Meilleur_Masque(lst : in out T_Liste; Adresse_IP : in Unbounded_String; current : in out T_Table) return T_Table is --Fonction qui renvoie le masque le plus long qui correspond avec l'adresse.
   begin 
      -- condition d'arrêt : si on est arrivé au bout de la liste...
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

   --Fonction qui traite les commandes telles que "fin", "table"...
   procedure Traiter_Commande(commande: String;nom_table : String; fichier_sortie: File_Type) is 
      fichier_table : File_Type;
      ligne : Unbounded_String := To_Unbounded_String("");
   begin
      if commande = "table" then 
         Open(fichier_table,In_File ,nom_table);  

         ligne := Lire(fichier_table);
         Ecrire(fichier_sortie,To_Unbounded_String(""));
         Ecrire(fichier_sortie,To_Unbounded_String("table : "));
         while ligne /= To_Unbounded_String("") loop
            Ecrire(fichier_sortie, ligne);
            ligne := Lire(fichier_table);
         end loop;
         Ecrire(fichier_sortie,To_Unbounded_String(""));
         
         Close(fichier_table);
      else
            Null;
      end if;
            
   end Traiter_Commande; 
    
   --fonction qui libère tout élément de type T_Liste
   procedure Liberer(table : in out T_Liste) is
   begin
      if table /= Null then
         Liberer(table.all.suivant);
      end if;
      Free(table);
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
   nom_entree : String := "fichier_entree.txt";
   nom_table : String := "table.txt";
   nom_sortie : String := "fichier_sortie.txt";

   -- pour la fonction Lire, il faut pré-ouvrire les fichiers
   fichier_table : File_Type;
   fichier_entree : File_Type;
   fichier_sortie : File_Type;
   
   -- Variable qui sert pour la fonction Meilleur_Masque
   current_tab : T_Table;
   a_ecrire : Unbounded_String;
   
     
begin
   Open(fichier_table,In_File,nom_table);
   Open(fichier_entree,In_File,nom_entree);
   Create(fichier_sortie,Out_File,nom_sortie);

   table := New T_Table;
   -- on donne table Null, et 0 comme clé, parce que la fonction est réccurssive et à besoin de ces paramètres.
   Chargement_Table(table, fichier_table,0);
   Close(fichier_table);
   ligne_a_lire := Lire(fichier_entree);

   while (not (ligne_a_lire = "fin") and not End_Of_File(fichier_entree) and not (ligne_a_lire = To_Unbounded_String(""))) loop

      current_tab.cle := 0;
      current_tab.mask := To_Unbounded_String("0.0.0.0");
      current_tab.inter := To_Unbounded_String("Adress does not match any known network");
      current_tab.suivant := Null;
      current_tab.destination := To_Unbounded_String("0.0.0.0");
      

      case Element(ligne_a_lire,1) is 
         when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
            a_ecrire := ligne_a_lire & To_Unbounded_String(" ")& Meilleur_Masque(table, ligne_a_lire, current_tab).inter;
            Ecrire(fichier_sortie, a_ecrire);
         when others =>
            Traiter_Commande(To_String(ligne_a_lire), nom_table, fichier_sortie);
         end case;

         ligne_a_lire := Lire(fichier_entree);

   end loop;

   Close(fichier_entree);
   Close(fichier_sortie);

   Liberer(table) ;
   
end routeur_simple;

