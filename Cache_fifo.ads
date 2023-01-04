with LCA ;

generic
    type T_Stats is private ;
    type T_Adresse is private ;
    type T_Cellule_Stats is private ;


package Cache_fifo is
    type T_LCA_Stats is limited private ;
    function Est_Vide(Cache : in T_LCA_Stats) return Boolean ;
    procedure Initialiser(Cache : out T_LCA_Stats) with
        Post => Taille(Cache) = 1 and Cache.all.Stats = 0 ;
    procedure Supprimer(Cache : in out T_LCA_Stats) ;
    procedure Enregistrer(Cache : in out T_LCA_Stats) with
        Pre => not Est_Pleine(Cache) ;
    procedure Free is new Ada.Unchecked_Deallocation (Object => T_Table, Name => T_Liste);
    -- function La_Cle(Cache : in T_Complet, Donnee : in T_Adresse) return Integer;
    procedure Vider(Cache : in out T_LCA_Stats);
        Post => Est_Vide(Cache) ;


private

    type T_Stats is record
        nb_demandes : Integer ;
        nb_defauts : Integer ;
        taux_defauts : Float ;
    end record ;

    type T_Adresse ;

    type T_Cellule_Stats ;
    
    type T_LCA_Stats is access T_Cellule_Stats ;
    
    type T_Cellule_Stats is record
        Donnee : T_Adresse ;
        Stats : T_Stats ;
        Cle : Integer ;
        Suivant : T_LCA_Stats ;
    end record ;

end Cache_fifo ;