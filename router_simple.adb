with lca;

procedure Routeur_Simple is 

    Type T_Liste is access T_Table;

    Type T_Table is record 
        destination : String;
        mask : String;
        interface : String;
        Suivant : T_Table;
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
    function Meilleur_Masque(LCA : T_LCA) return String is
        begin
        return Null;
    end Meilleur_Masque;

    function Chargement_Table()
        begin

    end 


    begin


    Null;

end Routeur_Simple;