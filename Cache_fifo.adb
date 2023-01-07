with LCA ;
with Cache_Exceptions ;

package body Cache_fifo is

    procedure Initialiser(Cache : out T_Complet) is
    begin
        Cache.Contenu := Null ;
        Cache.Stats := 0 ;
    end Initialiser ;

    function Est_Vide(Cache : in T_Complet) return Boolean is
    begin
        return (Cache.Contenu = Null) ;
    end Est_Vide ;

    procedure Supprimer(Cache : in out T_Complet) is -- fonction à "supprimer" pour la passer en générique dans le cache_ll et réutiliser sinon les autres sous-programmes !
        pointeur_debut : T_complet ;
    begin
        pointeur_debut := Cache.Contenu.all.Suivant'access ; -- on récupère l'adresse du deuxième élément du cache
        Free(Cache); -- on libère le premier élément ---- condition à changer en fonction de la politique du cache !
        Cache.Contenu := pointeur_debut ; -- on récupère le cache à partir du deuxième élément
    end Supprimer;

    procedure Enregistrer(Cache_Contenu : in out T_LCA, Cache_Stats : in out T_Stats, Adresse_IP : in T_Adresse, Interface_Adresse : in T_Interface) is
    begin
        if Est_Vide(Cache) then
            Cache_Contenu := new T_Cellule'(Adresse => Adresse_IP, Cle => (Taille(Cache_Contenu) + 1), Suivant => Null, Interface => Interface_Adresse);
            Cache_Stats.nb_demandes := Cache_Stats.nb_demandes + 1 ;
            Cache_Stats.nb_defauts := Cache_Stats.nb_defauts + 1 ;
            Cache_Stats.taux_defauts := Cache_Stats.nb_defauts / Cache_Stats.nb_demandes ;
        elsif (Cache_Contenu.all.Adresse /= Adresse_IP) then
            Enregistrer(Cache_Contenu.all.Suivant; Cache_Stats; Adresse_IP; Interface_Adresse);
        else 
            Cache_Stats.nb_demandes := Cache_Stats.nb_demandes + 1 ;
            Cache_Stats.taux_defauts := Cache_Stats.nb_defauts / Cache_Stats.nb_demandes ;
        end if ;
    end Enregistrer ;

    procedure Vider(Cache_Contenu : in out T_LCA, Cache_Stats : in out T_Stats) is -- on décompose les entrées pour pouvoir parcourir la LCA récursivement
        Cache_total : T_Complet ;
    begin
        Cache_total.Contenu := Cache_Contenu ;
        Cache_total.Stats := Cache_Stats ;
        if Est_Vide(Cache_total) then
            Null ;
        else
            Vider(Cache_Contenu.all.Suivant; Cache_Stats) ;
        end if;
        Free(Cache_Contenu);
        if Cache_Stats /= 0 then -- pour ne passer les différents paramètres à zéro une seule fois
            Cache_Stats := 0 ;
        end if;
    end Vider ;

    function Adresse_Presente(Cache_Contenu : in T_LCA, Cache_Stats : in T_Stats, Adresse : in T_Adresse) return Boolean is
        Cache_total : T_Complet ;
    begin
        Cache_total.Contenu := Cache_Contenu ;
        Cache_total.Stats := Cache_Stats ;
        if Est_Vide(Cache_total) then
            raise Adresse_Absente_Exception ;
        elsif Cache_Contenu.all.Cle = Adresse then
            return True ;
        else
            return Adresse_Presente(Cache_Contenu.all.Suivant; Cache_Stats, Adresse);
        end if ;
    exception when 
        Adresse_Absente_Exception => return False ;
    end Adresse_Presente ;

    function Taille(Cache_Contenu : in T_LCA, Cache_Stats : in T_Stats) return Integer is
        Cache_total : T_Complet ;
        taille_cache : Integer ;
    begin
        if Est_Vide(Cache_total) then
            return 0 ;
        else
            return (1+Taille(Cache_Contenu.all.Suivant; Cache_Stats)) ;
        end if;
    end Taille;

    function Est_Pleine(Cache : in T_Complet, capacite_cache : in Integer) return Boolean is
    begin
        return (Taille(Cache.Contenu, Cache.Stats) = capacite_cache) ;
    end Est_Pleine ;

end Cache_fifo ;
