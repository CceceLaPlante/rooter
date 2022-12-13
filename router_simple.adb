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

    Type T_liste_IP is access T_IP;
    Type T_IP is record 
        IP : T_adresse_IP;
        Suivant : T_IP;
    end record;



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
    function Meilleur_Masque(Lst : T_Liste; Adresse_IP : in String) return Integer is
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

    --fonction permettant de lire dans le fichier des destination, il renvoie une liste chaînée des adresses ip.
    function Lire(fichier : String) return T_liste_IP is 
    begin
        return Null;
    end;
    
     table : T_Liste;
    begin
        table := Null;
        Chargement_Table(table);
        





    Null;

end Routeur_Simple;
