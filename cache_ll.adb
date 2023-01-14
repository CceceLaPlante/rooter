with Ada.Unchecked_Deallocation;
with cache_exception; use cache_exception;
with Ada.Text_IO; use Ada.Text_IO;

package body cache_ll is

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


    procedure Supprimer_fifo(Cache : in out T_LCA) is -- fonction Ã  "supprimer" pour la passer en gÃ©nÃ©rique dans le cache_ll et rÃ©utiliser sinon les autres sous-programmes !
        pointeur_debut : T_LCA ;
    begin
        pointeur_debut := Cache.all.Suivant ; -- on rÃ©cupÃ¨re l'adresse du deuxiÃ¨me Ã©lÃ©ment du cache
        Free(Cache); -- on libÃ¨re le premier Ã©lÃ©ment ---- condition Ã  changer en fonction de la politique du cache !
        Cache := pointeur_debut ; -- on rÃ©cupÃ¨re le cache Ã  partir du deuxiÃ¨me Ã©lÃ©ment
    end Supprimer_fifo;


    procedure Chercher_min_freq(Cache : in T_LCA; min: in out Unbounded_String; freq_min : in out Integer) is
        --min : Unbounded_String;
        --freq_min : Integer ;
    begin
        if Est_Vide(Cache.all.Suivant)  then
            min := Cache.all.adresse ;
            freq_min := Cache.all.Nombre_utilisation ;
        else
            Chercher_min_freq(Cache.all.Suivant, min, freq_min);
        end if ;
        if Cache.all.Nombre_utilisation < freq_min then
            min := Cache.all.Adresse;
            freq_min := Cache.all.Nombre_utilisation;
        end if;
    end Chercher_min_freq ;


    procedure Supprimer_lfu(Cache : in T_LCA; min : in Unbounded_String) is
    begin
        if Est_Vide(Cache) then
            raise Adresse_Absente_Exception ;
        elsif Cache.all.Suivant.all.Adresse = min then
            Cache.all.Suivant := Cache.all.Suivant.all.Suivant ;
        else 
            Supprimer_lfu(Cache.all.Suivant, min);
        end if ;
    end Supprimer_lfu;

    procedure Chercher_max_temps(Cache : in T_LCA; max : in out Unbounded_String; temps_max : in out Time) is
    begin
        if Est_Vide(Cache.all.Suivant) then
            max := Cache.all.Adresse ;
            temps_max := Cache.all.Temps_enregistrement ;
        else
            Chercher_max_temps(Cache.All.Suivant, max, temps_max);
        end if;
        if Cache.all.Temps_enregistrement > temps_max then
            max := Cache.all.Adresse ;
            temps_max := Cache.all.Temps_enregistrement ;
        end if;
    end Chercher_max_temps ;

    procedure Supprimer_lru(Cache : in T_LCA; max : in Unbounded_String) is
    begin
        if Est_Vide(Cache) then
            raise Adresse_Absente_Exception ;
        elsif Cache.all.Suivant.all.Adresse = max then
            Cache.all.Suivant := Cache.all.Suivant.all.Suivant ;
        else 
            Supprimer_lru(Cache.all.Suivant, max);
        end if ;
    end Supprimer_lru;

    procedure Enregistrer(Cache : in out T_LCA; Stats : in out T_Stats; Adresse_IP : in Unbounded_String; Interface_Adresse : in Unbounded_String; Masque_Adresse: Unbounded_String) is
    begin
        if Est_Vide(Cache) then
            Cache := new T_Cellule'(Adresse => Adresse_IP, Masque => Masque_Adresse, Nombre_utilisation => 0, Cle => (Taille(Cache) + 1), Suivant => Null, Interface_utilisation => Interface_Adresse, Temps_enregistrement => Clock);
            Stats.nb_demandes := Stats.nb_demandes + 1.0 ;
            Stats.nb_defauts := Stats.nb_defauts + 1.0 ;
            Stats.taux_defauts := Stats.nb_defauts / Stats.nb_demandes ;
            Cache.all.Nombre_utilisation := 1;
        elsif (Cache.all.Adresse /= Adresse_IP) or ((Cache.all.Adresse = Adresse_IP) and (Cache.all.Masque /= Masque_Adresse)) then
            Enregistrer(Cache.all.Suivant, Stats, Adresse_IP, Interface_Adresse, Masque_Adresse);
        else 
            Stats.nb_demandes := Stats.nb_demandes + 1.0 ;
            Stats.taux_defauts := Stats.nb_defauts / Stats.nb_demandes ;
            Cache.all.Nombre_utilisation := Cache.all.Nombre_utilisation + 1;
            Cache.all.Temps_enregistrement := Clock ;
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
        if (Stats.nb_demandes /= 0.0) and (Stats.nb_defauts /= 0.0) and (Stats.taux_defauts /= 0.0) then -- pour ne passer les diffÃ©rents paramÃ¨tres Ã  zÃ©ro une seule fois
            Stats.nb_demandes := 0.0 ;
            Stats.nb_defauts := 0.0 ;
            Stats.taux_defauts := 0.0 ;
        end if;
    end Vider ;
   
    function Presence_masque(Cache : in T_LCA; Adresse_IP_entree : in Unbounded_String) return Boolean is
        Adresse_IP_entree_masque : Unbounded_String;
        Adresse_IP_courante_masque : Unbounded_String;
        Masque_IP_courante : Unbounded_String;
        Adresse_IP_courante : Unbounded_String;
        Adresse_IP_comparaison : Unbounded_String;
    begin
        if Est_Vide(Cache) then
            return False;
        else
            Adresse_IP_courante := Convertir_IP2B(Cache.all.Adresse);
            Masque_IP_courante := Convertir_IP2B(Cache.all.Masque);
            Adresse_IP_entree_masque := To_Unbounded_String("");
            Adresse_IP_courante_masque := To_Unbounded_String("");
            Adresse_IP_comparaison := Convertir_IP2B(Adresse_IP_entree);
            for i in 1..32 loop
                if Element(Masque_IP_courante,i) = '0' then
                    Adresse_IP_courante_masque := Adresse_IP_courante_masque & To_Unbounded_String("0");
                    Adresse_IP_entree_masque := Adresse_IP_entree_masque & To_Unbounded_String("0");
                else
                    Adresse_IP_courante_masque := Adresse_IP_courante_masque & Element(Adresse_IP_courante,i);
                    Adresse_IP_entree_masque := Adresse_IP_entree_masque & Element(Adresse_IP_comparaison,i);
                end if;
            end loop;
            if Adresse_IP_courante_masque /= Adresse_IP_entree_masque then
                return Presence_masque(Cache.all.Suivant,Adresse_IP_entree);
            else
                return True ;
            end if;
        end if;
    end Presence_masque;
    
    function Masquer_Cache(Cache: in T_LCA; Adresse: in Unbounded_String) return Unbounded_String is
        Adresse_IP_entree_masque : Unbounded_String;
        Adresse_IP_courante_masque : Unbounded_String;
        Masque_IP_courante : Unbounded_String;
        Adresse_IP_courante : Unbounded_String;
        Adresse_IP_comparaison : Unbounded_String;
    begin
        Put_Line(To_String(Adresse));
        Adresse_IP_courante := Convertir_IP2B(Cache.all.Adresse);
        Masque_IP_courante := Convertir_IP2B(Cache.all.Masque);
        Adresse_IP_entree_masque := To_Unbounded_String("");
        Adresse_IP_courante_masque := To_Unbounded_String("");
        Adresse_IP_comparaison := Convertir_IP2B(Adresse);
        for i in 1..32 loop
            if Element(Masque_IP_courante,i) = '0' then
                Adresse_IP_courante_masque := Adresse_IP_courante_masque & To_Unbounded_String("0");
                Adresse_IP_entree_masque := Adresse_IP_entree_masque & To_Unbounded_String("0");
            else
                Adresse_IP_courante_masque := Adresse_IP_courante_masque & Element(Adresse_IP_courante,i);
                Adresse_IP_entree_masque := Adresse_IP_entree_masque & Element(Adresse_IP_comparaison,i);
            end if;
            Put_Line("Masque en binaire" & To_String(Masque_IP_courante));
            Put_Line("Masque en IP" & To_String(Convertir_IP2B(Masque_IP_courante)));
        end loop;
        if Adresse_IP_courante_masque /= Adresse_IP_entree_masque then
            return Masquer_Cache(Cache.all.Suivant,Adresse);
        else
            return Convertir_B2IP(Masque_IP_courante) ;
        end if;
    end Masquer_Cache;

    function Adresse_Presente(Cache : in T_LCA; Stats : in T_Stats; Adresse : in Unbounded_String; Masque_Adresse: in Unbounded_String) return Boolean is
    begin
        if Est_Vide(Cache) then
            return False ;
        elsif (Cache.all.Adresse = Adresse) and (Cache.all.Masque = Masque_Adresse) then
            return True ;
        else
            return Adresse_Presente(Cache.all.Suivant, Stats, Adresse, Masque_Adresse);
        end if ;
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

    function Interface_du_Cache(Cache: in T_LCA; Stats: T_Stats; Adresse: in Unbounded_String; Masque: Unbounded_String) return Unbounded_String is
    begin
        if not Est_Vide(Cache) and Adresse_Presente(Cache, Stats, Adresse, Masque) then

            if (Cache.all.Adresse /= Adresse) or ((Cache.all.Adresse = Adresse) and (Cache.all.Masque /= Masque)) then
                return Interface_du_Cache(Cache.all.Suivant,Stats, Adresse, Masque);
            else 
                return Cache.all.interface_utilisation;
            end if;
        else
            return To_Unbounded_String("Null");
        end if;
    end Interface_du_Cache;
        
    procedure Pour_Chaque(Cache: in T_LCA) is
    begin
        if Est_Vide(Cache) then
            Null;
        else 
            begin
                Traiter(Cache.all.Adresse, Cache.all.Masque, Cache.all.Interface_utilisation);
            exception 
                when others =>
                    Null;
            end;
            Pour_Chaque(Cache.all.Suivant);
        end if;
    end Pour_Chaque ;
    
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
    
    type adr4 is array(1..4) of Unbounded_String;
    
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
    
    function B2IP_4 (Adresse_IP : in Unbounded_String) return Unbounded_String is
        a_return : Unbounded_String := To_Unbounded_String("");
        a_return_reversed : Unbounded_String := To_Unbounded_String("");
        IP_cp : constant Unbounded_String := Adresse_IP;
    begin
        for i in 1..Length(Adresse_IP) loop
            if Element(IP_cp, i) = '1' then
                a_return := a_return & '1';
            else
                a_return := a_return & '0';
            end if;
        end loop;

        for i in 1..Length(Adresse_IP) loop
            a_return_reversed := a_return_reversed & Element(a_return, Length(Adresse_IP)+1-i);
        end loop;

        return a_return_reversed;
    end B2IP_4;

    function B2IP (Adresse_IP : in Unbounded_String) return Unbounded_String is
        a_return : Unbounded_String;
        quart_IP : Unbounded_String;
    begin 
        for i in 1..4 loop
            if i = 4 then
                quart_IP := To_Unbounded_String(To_String(Adresse_IP)((i-1)*8+1..i*8));
                a_return := To_Unbounded_String(To_String(a_return) & To_String(B2IP_4(quart_IP)));
            else
                quart_IP := To_Unbounded_String(To_String(Adresse_IP)((i-1)*8+1..i*8));
                a_return := To_Unbounded_String(To_String(a_return) & To_String(B2IP_4(quart_IP))) & '.';
            end if;
        end loop;

        return a_return;
    end B2IP;
    
    function Convertir_B2IP(Adresse_IP : in Unbounded_String) return Unbounded_String is
        premier_nombre : Unbounded_String;
        deuxieme_nombre : Unbounded_String;
        troisieme_nombre : Unbounded_String;
        quatrieme_nombre : Unbounded_String;
        premier_nombre_IP : Unbounded_String;
        deuxieme_nombre_IP : Unbounded_String;
        troisieme_nombre_IP : Unbounded_String;
        quatrieme_nombre_IP : Unbounded_String;
        adresse_retour : Unbounded_String;
    begin
        premier_nombre := To_Unbounded_String(To_String(Adresse_IP)(1..8));
        deuxieme_nombre := To_Unbounded_String(To_String(Adresse_IP)(10..17));
        troisieme_nombre := To_Unbounded_String(To_String(Adresse_IP)(19..26));
        quatrieme_nombre := To_Unbounded_String(To_String(Adresse_IP)(28..35));
        for i in 1..8 loop
            premier_nombre_IP := To_Unbounded_String(To_String(premier_nombre_IP) & Integer'Image(Character'Pos(To_String(premier_nombre)(i))*2**(8-i)));
            deuxieme_nombre_IP := To_Unbounded_String(To_String(deuxieme_nombre_IP) & Integer'Image(Character'Pos(To_String(deuxieme_nombre)(i))*2**(8-i)));
            troisieme_nombre_IP := To_Unbounded_String(To_String(troisieme_nombre_IP) & Integer'Image(Character'Pos(To_String(troisieme_nombre)(i))*2**(8-i)));
            quatrieme_nombre_IP := To_Unbounded_String(To_String(quatrieme_nombre_IP) & Integer'Image(Character'Pos(To_String(quatrieme_nombre)(i))*2**(8-i)));
        end loop;
        adresse_retour := premier_nombre_IP & To_Unbounded_String(".") & deuxieme_nombre_IP & To_Unbounded_String(".") & troisieme_nombre_IP & To_Unbounded_String(".") & quatrieme_nombre_IP;
        return adresse_retour;
    end Convertir_B2IP;
    
end cache_ll ;

