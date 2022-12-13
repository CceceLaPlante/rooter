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



        -- Fonction qui convertie les adresses IP en entier.
    function Convertir_IP2I(Adresse_IP : in String) return Integer is
        begin
        return Null;
    end Convertir_IP2I;

    -- Fonction qui convertie les adresses IP en adresses binaires.
    function Convertir_IP2B(Adresse_IP : in String) return String is
        begin
        return Null;
    end Convertir_IP2B;

    -- Fonction qui convertie les adresses binaires en adresses IP.
    function Convertir_B2IP(Adresse_IP : in String) return String is
        begin
        return Null;
    end Convertir_B2IP;

     --
    function Convertir_L2T(ligne : String) return T_Table is 
        begin
        return Null;
    end Convertir_L2T;

    -- Fonction qui renvoie True si le masque et l'adresse IP coïncident.
    function Masque(Adresse_IP : in String; ligne : in Integer) return Boolean is 
        begin
        return Null;
    end Masque;

    -- Renvoie le masque le plus long qui correspond avec l'adresse.
    function Meilleur_Masque(Lst : T_Liste; Adresse_IP : in String) return T_Table is
        begin
        return Null;
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
