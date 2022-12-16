with lca;

procedure Routeur_Simple is 

    Type T_Liste is access T_Table;

    Type T_Table is record 
        destination : String;
        mask : String;
        interface : String;
        Suivant : T_Table;
        cle : Integer;
    end record;

    Type T_adresse_IP is mod 2 ** 32;

    function lenght(lst : T_Liste) return Integer is
        begin
        if lst /= Null then
            return 1 + lenght(lst.Suivant);
        else
            return 0;
        end if;
    end lenght;

        -- Fonction qui convertie les adresses IP en nombre binaire.
        -- elle serviras pour appliquer les masques

    -- d'abord on s'occupe d'une conversion 4bit 
    function Convertir_IP2B_4 (adr : in Integer) return String is 
            a_return : String :=("00000000");
        begin
            for i in 1..8 loop
                if adr mod 2 == 1 then
                    a_return(9-i) := '1';
                else
                    a_return(9-i) := '0';
                end if;
                adr := adr / 2;
            end loop;
        return a_return;
    end Convertir_IP2B_4;
    

    -- puis on s'occupe de la conversion de l'adresse IP complète
    function Convertir_IP2B(Adresse_IP : in String) return String is
        entier : Integer ;
        type adr4 is array(1..4) of String ;
        adr : adr4 ;
        idx : Integer := 1;
        
        begin
        for i in 1..length(Adresse_IP) loop
            case Adresse_IP(i) is
                when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                    entier := entier + Adresse_IP(i)*(10**i) ;
                when '.' =>
                    adr(idx) := Convertir_IP2B_4(entier) ;
                    idx := idx + 1 ;
                    entier := 0 ;
                when others =>
                    null ;
            end case ;
        end loop ;

        return adr(1) & adr(2) & adr(3) & adr(4) ; -- [!] on ne renvois pas avec des points !!!! 
        
    end Convertir_IP2B;

    -- Fonction qui convertie les adresses IP en entier.
     function Convertir_IP2I(Adresse_IP : in String) return Integer is
        entier : Integer ;
        begin
        for i in 1..length(Adresse_IP) loop
            case Adresse_IP(i) is
                when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' =>
                    entier := entier + Adresse_IP(i)*(10**i) ;
                when others =>
                    null ;
            end case ;
        end loop ;
        return entier ;
    end Convertir_IP2I;

    -- Fonction qui convertie les adresses binaires en adresses IP.
    function Convertir_B2IP(Adresse_IP : in String) return String is
        puissance : Integer ;
        nombre_entier : Integer ;
        nombre : String ;
        indice : Integer ;
    begin
        indice := 1 ;
        octet := 1 ;
        while octet /= 4 loop 
            puissance := 7 ;
            nombre_entier := 0 ;
            while puissance /= 0 loop
                nombre_entier := nombre_entier + (Ord(Adresse_IP(indice))-Ord('0'))*2**puissance ;
                 puissance := puissance - 1 ;
                  indice := indice + 1 ;
         end loop ;
            if octet /= 1 then
                nombre := nombre + '.' + "nombre_entier"  ;
            else
                nombre := "nombre_entier" ;
            end if ;
            octet := octet + 1 ;
        end loop ;
        return nombre ;
    end Convertir_B2IP;

     --
    function Convertir_L2T(ligne : String) return T_Table is 
        begin
        return Null;
    end Convertir_L2T;

    -- Fonction qui renvoie True si le masque et l'adresse IP coïncident.
    function Masque(Adresse_IP : in String; ligne : in Integer) return Boolean is 
            idx : Integer;
        begin
        return Null;
    end Masque;

    -- Renvoie le masque le plus long qui correspond avec l'adresse.
     function Meilleur_Masque(Lst : T_Liste; Adresse_IP : in String) return T_Table is
        indice : Integer ;
        taille_max : Integer ;
        current : Integer ;
        taille_current : Integer ;
     begin
        taille_max := 0 ;
        while indice /= length(Lst) loop
            taille_current := 0 ;
            if Masque then
                current := length(Adresse_IP(indice)) ; -- on parcourt l'adresse IP à l'envers pour réduire la complexité
                while current /= 0 loop
                    if Adresse_IP(current) == '.' then
                        null ;
                  elsif Adresse_IP(current) /= 0 then
                        taille_current := taille_current + 1 ;
                  else
                           null ;
                  end if ;
                  current := current - 1 ;
                end loop ;
                if taille_current > taille_max then
                    taille_max := taille current ;
                      adresse_max := Adresse_IP(indice) ;
                end if ;
            else
                    null ;
            end if ;
         end loop ;
         return adresse_max ;
    end Meilleur_Masque;

    -- permet de charger la table de routage dans une liste chaînée.
    procedure Chargement_Table(LCA : T_LCA) is
        begin
    end;

    --procedure permettant d'écrire dans un fichier.
    procedure Ecrire(fichier : String; a_ecrire : String) is
        begin
    end;

    --fonction permettant de lire dans le fichier des destination, il renvoie une ligne puis la suivante
    --à chaques appels.
    -- elle renvoie Null si c'est finis.
    function Lire(fichier : String) return T_liste_IP is 
    begin
        return Null;
    end;
    
     table : T_Liste;
     ligne_a_lire : Unbunded_String;
     fichier_destination : String := "destination.txt";
     fichier_interface : String := "interface.txt";
    begin
        table := Null;
        Chargement_Table(table);
        ligne_a_lire := Lire(fichier_destination);
        
        while (ligne_a_lire is not Null) loop
            Ecrire(fichier_interface, Meilleur_Masque(table, ligne_a_lire).interface);
            ligne_a_lire := Lire(fichier_destination);
        end loop;


        


    Null;

end Routeur_Simple;
