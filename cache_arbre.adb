with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Text_IO;               use Ada.Text_IO;

package body cache_arbre is

    function equivalente_ligne (Ligne1 : in T_ligne; Ligne2 : in T_Ligne) return Boolean is
        ip1 : String(1..32);
        ip2 : String(1..32);
        masque : String(1..32);
    begin  
        --Afficher_inter("--------------------------------", Ligne2);
        --Afficher_inter("________________________________", Ligne1);
        ip1 := To_String(Convertir_IP2B(Ligne1.destination));
        ip2 := To_String(Convertir_IP2B(Ligne2.destination));
        masque := To_String(Convertir_IP2B(Ligne2.mask));

        for i in 1..32 loop 

            if masque(i) = '1' and ip1(i) = ip2(i) then 
                null;
            else 
                if masque (i) = '0' then 
                    null;
                else
                    return False;
                end if;
            end if;
        end loop;
        return True;
    end equivalente_ligne;

    procedure Initialiser_cache (Cache : in out T_Cache) is
        -- pour eviter la division par 0 on met nb_defaut a 1
        stat : constant T_Stat := (nb_defaut => 1.0, tx_defaut => 0.0 , nb_demande => 0.0,horloge => 0);
    begin
        Cache.stats := stat;
        Cache.Arbre := null;
        Initialiser(Cache.Arbre);
    end Initialiser_cache;

    function Est_vide_cache (Cache : in T_Cache) return Boolean is
    begin
        return Est_vide(Cache.Arbre);
    end Est_vide_cache;

       -- d'abord on s'occupe d'une conversion 4bit 
   function Convertir_IP2B_4 (adr : in Integer) return Unbounded_String is 
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
   function Convertir_IP2B (Adresse_IP : in Unbounded_String) return Unbounded_String is
      entier : Integer := 0;
      entier_string : Unbounded_String := To_Unbounded_String("");
      type adr4 is array(1..4) of Unbounded_String;
      adr : adr4 ;
      idx : Integer := 1;
      --Adresse_IP_S : constant String := To_String(Adresse_IP);
        
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

        entier := Integer'Value (To_String(entier_string));
        adr(idx) := Convertir_IP2B_4(entier) ;
               --Put_Line("entier, puis entier en binaire : "&entier_string&" , "&adr(idx));

      return  adr(1) & adr(2) & adr(3) & adr(4) ; -- [!] on ne renvoi pas avec des points !!!!     

    end Convertir_IP2B;

    function B2IP_4 (IP : in Unbounded_String) return Unbounded_String is
        a_return : Unbounded_String := To_Unbounded_String("");
        a_return_reversed : Unbounded_String := To_Unbounded_String("");
        IP_cp : constant Unbounded_String := IP;
    begin
        for i in 1..Length(IP) loop
            if Element(IP_cp, i) = '1' then
                a_return := a_return & '1';
            else
                a_return := a_return & '0';
            end if;
        end loop;

        for i in 1..Length(IP) loop
            a_return_reversed := a_return_reversed & Element(a_return, Length(IP)+1-i);
        end loop;

        return a_return_reversed;
    end B2IP_4;

    function B2IP (IP : in Unbounded_String) return Unbounded_String is
        a_return : Unbounded_String;
        quart_IP : Unbounded_String;
    begin 
        for i in 1..4 loop
            if i = 4 then
                quart_IP := To_Unbounded_String(To_String(IP)((i-1)*8+1..i*8));
                a_return :=To_Unbounded_String(To_String(a_return) & To_String(B2IP_4(quart_IP)));
            else
                a_return := To_Unbounded_String(To_String(a_return) & To_String(B2IP_4(quart_IP))) & '.';
            end if;
        end loop;

        return a_return;
    end B2IP;

    function Trouver (Cache : in out T_Cache; IP : in Unbounded_String) return T_Ligne is 
        IP_Bin :constant  Unbounded_String := Convertir_IP2B(IP);
        Cle : String(1..32);
        ligne : T_Ligne;
        Now : constant Integer := Cache.stats.horloge;
        nul_ligne : T_Ligne;
    begin 
        nul_ligne.destination := To_Unbounded_String("");
        nul_ligne.mask := To_Unbounded_String("");
        nul_ligne.inter := To_Unbounded_String("");
        nul_ligne.temps := Now;
        nul_ligne.arrive := 0;
        nul_ligne.nb_utilisation := 0;

        Cache.stats.horloge := Cache.stats.horloge + 1;
        Cle := To_String(IP_Bin);
        ligne:= La_Donnee(Cache.Arbre, Cle, nul_ligne);
        ligne.temps := Now;
        ligne.nb_utilisation := Ligne.nb_utilisation + 1;
        Remplacer(Cache.Arbre,Cle, ligne); -- on réactualise la ligne...
        return ligne;
    end Trouver;

    function Trouver_global(Cache: in out T_Cache; IP : in Unbounded_String) return T_ligne is
        function La_cle_cache is new La_Cle(equivalente_ligne);
        cle : String(1..32);
        --ip_bin : String(1..32) := To_String(Convertir_IP2B(IP));
        ligne_factis : T_Ligne;
        Now :constant Integer := Cache.stats.horloge;
        nul_ligne : T_Ligne;
    begin
        nul_ligne.destination := To_Unbounded_String("");
        nul_ligne.mask := To_Unbounded_String("");
        nul_ligne.inter := To_Unbounded_String("");
        nul_ligne.temps := Now;
        nul_ligne.arrive := 0;
        nul_ligne.nb_utilisation := 0;

        ligne_factis.destination := IP;
        ligne_factis.mask := To_Unbounded_String("");
        ligne_factis.inter := To_Unbounded_String("");
        ligne_factis.temps := Now;
        ligne_factis.arrive := 0;
        ligne_factis.nb_utilisation := 0;
        cle := La_cle_cache(Cache.Arbre, ligne_factis);
        ligne_factis :=  La_Donnee(Cache.Arbre, cle,nul_ligne);
        ligne_factis.nb_utilisation := ligne_factis.nb_utilisation + 1;
        ligne_factis.temps := Now;
        Cache.stats.nb_demande := Cache.stats.nb_demande + 1.0;
        Remplacer(Cache.Arbre, cle, ligne_factis);
        return ligne_factis;
    end Trouver_global;

    function correspond(adr1 : in String; adr2 : in String; mask : in String) return Boolean is
        a_return : Boolean := True;
    begin 
        for i in 1..32 loop
            if mask(i) = '1' then
                if adr1(i) /= adr2(i) then
                    a_return := False;
                end if;
            end if;
        end loop;
        return a_return;
    end correspond;

    function masquer(adr : in String; mask : in String) return String is
        a_return : String(1..32):= "00000000000000000000000000000000";
    begin
        for i in 1..32 loop
            if mask(i) = '1' then
                a_return(i) := adr(i);
            end if;
        end loop;

        return a_return;
    end masquer;

    procedure Ajouter (Cache : in out T_Cache;Ligne : in out T_Ligne) is
        IP_Bin : constant Unbounded_String := Convertir_IP2B(Ligne.destination);
        Cle : String(1..32);
        Now : constant Integer := Cache.stats.horloge;
        nul_ligne : T_Ligne;
    begin
        nul_ligne.destination := To_Unbounded_String("");
        nul_ligne.mask := To_Unbounded_String("");
        nul_ligne.inter := To_Unbounded_String("");
        nul_ligne.temps := Now;
        nul_ligne.arrive := 0;
        nul_ligne.nb_utilisation := 0;
        Cache.stats.nb_defaut := Cache.stats.nb_defaut + 1.0;
        Cache.stats.horloge := Cache.stats.horloge + 1;
        Cle := To_String(IP_Bin);
        Ligne.temps := Now;
        Ligne.arrive := Now;
        Ligne.nb_utilisation := 1;

        if Cle_Presente(Cache.Arbre, Cle) then
            Remplacer(Cache.Arbre, Cle, Ligne);
        else
            Enregistrer(Cache.Arbre, Cle, Ligne,nul_ligne);
        end if;
    end Ajouter;

    procedure Supprimer_IP (Cache : in out T_Cache; IP : in Unbounded_String) is
        IP_Bin : constant String(1..32) := To_String(Convertir_IP2B(IP));
    begin   
        Supprimer(Cache.Arbre, IP_Bin);
        
    end Supprimer_IP;

    procedure Supprimer_Politic (Cache : in out T_Cache; max_taille: in Integer; politic : in String) is
        -- faut utiliser un pour chaques j'ai envie de me tirer une balle...
        function minimum(a : in T_Ligne; b : in T_Ligne;politic : in String ) return T_Ligne is
        begin
            if politic = "LRU" then
                if a.temps > b.temps then
                    return b;
                else
                    return a;
                end if;
            elsif politic = "LFU" then
                if a.nb_utilisation > b.nb_utilisation then
                    return b;
                else
                    return a;
                end if;
            else  
                if a.arrive > b.arrive then
                    return b;
                else
                    return a;
                end if;
            end if;
        end minimum;

        function min_rec (Cache: in T_Arbre; politic : in String) return T_Ligne is
            --nuls : constant String(1..32) := (others => Character'Val(0));
            nul_ligne : T_Ligne;
        begin
            nul_ligne.destination := To_Unbounded_String("");
            nul_ligne.mask := To_Unbounded_String("");
            nul_ligne.inter := To_Unbounded_String("");
            nul_ligne.temps := 0;
            nul_ligne.arrive := 0;
            nul_ligne.nb_utilisation := 0;

            if not Est_vide(Cache) and then Cache.all.leaf = False then
                if Est_vide(Cache.all.Suivant_G) then 
                    return min_rec(Cache.all.suivant_D,politic);
                elsif Est_vide(Cache.all.Suivant_G) then 
                    return min_rec(Cache.all.suivant_D,politic);
                elsif Est_vide(Cache.all.Suivant_D) then
                    return min_rec(Cache.all.suivant_G,politic);
                else
                    return minimum(min_rec(Cache.all.suivant_G,politic),min_rec(Cache.all.suivant_D,politic),politic);
                end if;
            elsif not Est_Vide(Cache) and then Cache.all.leaf = True then
                return Cache.all.Donnee;
            else 
                return nul_ligne;
            end if;
        end min_rec;
    begin

        if Taille(Cache.Arbre) > max_taille then
            Supprimer_IP(Cache, min_rec(Cache.Arbre,politic).destination);
        end if;
    end Supprimer_Politic;
        
    function IP_Presente(Cache : in T_Cache; IP : in Unbounded_String) return Boolean is
        IP_Bin : constant String(1..32) := To_String(Convertir_IP2B(IP));
    begin
        return Cle_Presente(Cache.Arbre, IP_Bin);
    end IP_Presente;
    
    procedure afficher_inter(Cle : in String; Ligne : in T_Ligne) is
        --IP : constant Unbounded_String := B2IP(To_Unbounded_String(Cle));    
        nuls:constant String(1..32) := (others => Character'Val(0));

    begin
        if Cle =  nuls then
            Put("");
        else 
            Put_Line (CLe &"|-> "&Ligne.destination & " : " & Ligne.mask & " : " & Ligne.inter);
            Put_Line("    "&"Temps : "&Integer'Image(Ligne.temps)&" Arrive : "&Integer'Image(Ligne.arrive)&" Nb_utilisation : "&Integer'Image(Ligne.nb_utilisation));
        end if;
    end afficher_inter;

    procedure Afficher(Cache : in out T_Cache) is
        procedure Afficher_inter2 is new Pour_Chaque(afficher_inter);
    begin
        Afficher_inter2(Cache.Arbre);
    end Afficher;

    function Taille_cache(Cache : in T_Cache) return Integer is 
    begin
        return Taille(Cache.Arbre);
    end Taille_cache;

    procedure Vider(Cache : in out T_Cache) is
    begin
        Vider(Cache.Arbre);
    end Vider;

    
end cache_arbre;