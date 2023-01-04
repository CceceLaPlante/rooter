with LCA ;

package body Cache_fifo is

    procedure Initialiser(Cache : out T_LCA_Stats) is
    begin
        Cache.all.Donnee := 0 ;
        Cache.all.Stats := 0 ;
        Cache.all.Cle := 0 ;
        Cache.all.Suivant := 0 ; 
        -- Peut-on mettre juste "Cache = Null" ? --> je suppose que oui après cf l+5
    end Initialiser ;

    function Est_Vide(Cache : in T_LCA_Stats) return Boolean is
    begin
        return (Cache = Null) ;
    end Est_Vide ;

    procedure Supprimer(Cache : in out T_LCA_Stats) is
        pointeur_debut : T_LCA_Stats ;
    begin
        pointeur_debut := Cache.all.Suivant'access ; -- on récupère l'adresse du deuxième élément du cache
        Free(Cache); -- on libère le premier élément
        Cache := pointeur_debut ; -- on récupère le cache à partir du deuxième élément
    end Supprimer;

    procedure Enregistrer(Cache : in out T_Complet; Adresse_IP : in T_Adresse) is
    begin
        if Est_Vide(Cache) then
            Cache := new T_Cellule_Stats'(Donnee => Adresse_IP, Stats => 1, Cle => 1, Suivant => Null);
        elsif (Cache.all.Donnee /= Adresse_IP) then
            Enregistrer(Cache.all.Suivant, Adresse_IP);
        else 
            Cache.all.Stats := Cache.all.Stats + 1 ;
        end if ;
    end Enregistrer ;

    procedure Vider(Cache : in out T_LCA_Stats) is
    begin
        if Est_Vide(Cache) then
            Null ;
        else
            Vider(Cache.all.Suivant) ;
        end if;
        Free(Cache);
    end Vider ;