with Arbre;
with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 

with Ada.Calendar;            use Ada.Calendar;
with Ada.Calendar.Formatting; use Ada.Calendar.Formatting;
with Ada.Text_IO;             use Ada.Text_IO;


package body  Cache_Arbre is

    function equivalente_ligne (Ligne1 : in T_ligne; Ligne2 : in T_Ligne) return Boolean is
        ip1 : String(1..32):=To_String(Convertir_IP2B(Ligne1.destination));
        ip2 : String(1..32):=To_String(Convertir_IP2B(Ligne2.destination));
        masque : String(1..32):=To_String(Convertir_IP2B(Ligne2.mask));
    begin  
        for i in 1..32 loop 
            if masque(i) = '1' and ip1(i) = ip2(i) then 
                null;
            else 
                return False;
            end if;
        end loop;
        return True;
    end equivalente_ligne;

    function La_cle_cache is new La_Cle(equivalente_ligne);

    procedure Initialiser_cache (Cache : in out T_Cache) is
        stat : T_Stat := (nb_defaut => 0, tx_defaut => 0.0 , nb_demande => 0);
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
   function Convertir_IP2B (Adresse_IP : Unbounded_String) return Unbounded_String is
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

    function B2IP_4 (IP : in Unbounded_String) return Unbounded_String is
        a_return : Unbounded_String := To_Unbounded_String("");
        a_return_reversed : Unbounded_String := To_Unbounded_String("");
        IP_cp : Unbounded_String := IP;
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

    function Trouver (Cache : in T_Cache; IP : in Unbounded_String) return T_Ligne is 
        IP_Bin : Unbounded_String := Convertir_IP2B(IP);
        Cle : String(1..32);
        ligne : T_Ligne;
        Now : Time := Clock;
    begin 
        Cle := To_String(IP_Bin);
        ligne:= La_Donnee(Cache.Arbre, Cle);
        -- j'ai peur que modifier comme ça ne change pas dans l'arbre
        ligne.temps := Now;
        return ligne;
    end Trouver;

    function Trouver_global(Cache: in  T_Cache; IP : in Unbounded_String) return T_ligne is
        cle : String(1..32);
        --ip_bin : String(1..32) := To_String(Convertir_IP2B(IP));
        ligne_factis : T_Ligne;
    begin
        ligne_factis.destination := IP;
        cle := La_cle_cache(Cache.Arbre, ligne_factis);
        return Trouver(Cache, To_Unbounded_String(cle));
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
        IP_Bin : Unbounded_String := Convertir_IP2B(Ligne.destination);
        Cle : String(1..32);
        Now : Time := Clock;
        nul_ligne : T_Ligne;
    begin
        nul_ligne.destination := To_Unbounded_String("");
        nul_ligne.mask := To_Unbounded_String("");
        nul_ligne.inter := To_Unbounded_String("");
        nul_ligne.temps := Clock;
        Cache.stats.nb_defaut := Cache.stats.nb_defaut + 1;
        Cle := To_String(IP_Bin);
        Ligne.temps := Now;
        Enregistrer(Cache.Arbre, Cle, Ligne,nul_ligne);
    end Ajouter;

    procedure Supprimer_IP (Cache : in out T_Cache; IP : in Unbounded_String) is
        IP_Bin : Unbounded_String := Convertir_IP2B(IP);
        Cle : String(1..32);
    begin
        Cle := To_String(IP_Bin);
        Supprimer(Cache.Arbre, Cle);
    end Supprimer_IP;

    procedure Supprimer_LRU (Cache : in out T_Cache; max_taille: in Integer) is
        -- faut utiliser un pour chaques j'ai envie de me tirer une balle...

        function minimum(a : T_Ligne; b : T_Ligne) return T_Ligne is
        begin
            if a.temps > b.temps then
                return b;
            else
                return a;
            end if;
        end minimum;

        function min_rec (Cache: in T_Arbre) return T_Ligne is
            nuls : String(1..32) := (others => Character'Val(0));
            -- Clock est forcément le plus grand temps possible
            nul_tligne : T_Ligne := (destination => To_Unbounded_String(nuls), mask => To_Unbounded_String(nuls), inter => To_Unbounded_String(nuls), temps => Clock);

        begin
            if not Est_vide(Cache) and then Cache.all.leaf = False then
                if Est_vide(Cache.all.Suivant_G) then 
                    return min_rec(Cache.all.suivant_D);
                elsif Est_vide(Cache.all.Suivant_G) then 
                    return min_rec(Cache.all.suivant_D);
                elsif Est_vide(Cache.all.Suivant_D) then
                    return min_rec(Cache.all.suivant_G);
                else
                    return minimum(min_rec(Cache.all.suivant_G),min_rec(Cache.all.suivant_D));
                end if;
            elsif not Est_Vide(Cache) and then Cache.all.leaf = True then
                return Cache.all.Donnee;
            else 
                return nul_tligne;
            end if;
        end min_rec;
    begin

        if Taille(Cache.Arbre) > max_taille then
            Supprimer_IP(Cache, min_rec(Cache.Arbre).destination);
        end if;
    end Supprimer_LRU;
        
    function IP_Presente(Cache : in T_Cache; IP : in String) return Boolean is
    begin
        return Cle_Presente(Cache.Arbre, IP);
    end IP_Presente;
    
    procedure afficher_inter(Cle : in String; Ligne : in T_Ligne) is
        IP : Unbounded_String := B2IP(To_Unbounded_String(Cle));    
        nuls:String(1..32) := (others => Character'Val(0));

    begin
        if Cle =  nuls then
            Put("");
        else 
            Put_Line (Ligne.destination & " : " & Ligne.mask & " : " & Ligne.inter);
        end if;
    end afficher_inter;

    procedure Afficher(Cache : in T_Cache) is
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

    
end Cache_Arbre;