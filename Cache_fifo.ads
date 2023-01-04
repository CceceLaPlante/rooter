with LCA ;

generic
    type T_Stats is private ;
    type T_Adresse is private ;
    type T_Cellule is private ;
    type T_Interface is private ;

package Cache_fifo is

    type T_Complet is limited private ;

    procedure Initialiser(Cache : out T_Complet) with
        Post => Taille(Cache) = 1 and Cache.Stats = 0 ;

    function Est_Vide(Cache : in T_Complet) return Boolean ;

    procedure Supprimer(Cache : in out T_Complet) ;

    procedure Enregistrer(Cache_Contenu : in out T_LCA, Cache_Stats : in out T_Stats, Adresse_IP : in T_Adresse, Interface_Adresse : in T_Interface) ;

    procedure Free is new Ada.Unchecked_Deallocation (Object => T_Table, Name => T_Liste);

    procedure Vider(Cache_Contenu : in out T_LCA, Cache_Stats : in out T_Stats);
        -- Post => Est_Vide(Cache) ;

    function Adresse_Presente(Cache_Contenu : in T_LCA, Cache_Stats : in T_Stats, Adresse : in T_Adresse) return Boolean;

    function Taille(Cache_Contenu : in T_LCA, Cache_Stats : in T_Stats) return Integer ;


private

    type T_Stats is record
        nb_demandes : Integer ;
        nb_defauts : Integer ;
        taux_defauts : Float ;
    end record ;

    type T_Adresse ;
    type T_Interface ;

    type T_Cellule ;
    type T_LCA is access T_Cellule ;
    type T_Cellule is record
        Adresse : T_Adresse ;
        Interface : T_Interface ; 
        Cle : T_Cle ;
        Suivant : T_LCA ;
    end record ;
    
    type T_Complet is record
        Stats : T_Stats ;
        Contenu : T_LCA ;
    end record ;

end Cache_fifo ;
