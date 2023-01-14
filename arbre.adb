with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;

package body arbre is 

    procedure Free is new Ada.Unchecked_Deallocation (Object => T_Node, Name => T_Arbre);

    procedure Initialiser(Arbre : out T_Arbre) is
    begin
        Arbre := null;
    end Initialiser;

    function Est_Vide(Arbre : T_Arbre) return Boolean is
    begin
        return Arbre = null;
    end Est_Vide;

    function Taille(Arbre : T_Arbre) return Integer is
    begin
        if Est_Vide(Arbre) then
            return 0;
        else
            return ( 1 + Taille(Arbre.Suivant_G) + Taille(Arbre.Suivant_D) );
        end if;
    end Taille;

    procedure Remplacer(Arbre : in out T_Arbre; Cle : in String; Donnee : in T_Donnee) is
        function Remplacer_r(Arbre : in out T_Arbre; Cle : in String; Donnee : in T_Donnee; idx : in Integer) return Boolean is
            trouve : Boolean;
        begin
            if Arbre = null then
                return False;
            elsif Arbre.all.Cle = Cle then
                Arbre.all.Donnee := Donnee;
                return True;
            elsif not Arbre.leaf then
                if Arbre.all.Cle(idx) = '1' then
                    trouve :=  Remplacer_r(Arbre.all.Suivant_D, Cle, Donnee, idx + 1);
                    if trouve then
                        return True;
                    else
                        return Remplacer_r(Arbre.all.Suivant_G, Cle, Donnee, idx + 1);
                    end if;
                else
                    trouve :=  Remplacer_r(Arbre.all.Suivant_G, Cle, Donnee, idx + 1);
                    if trouve then
                        return True;
                    else
                        return Remplacer_r(Arbre.all.Suivant_D, Cle, Donnee, idx + 1);
                    end if;
                end if;
            else
                return False;
            end if;
        end Remplacer_r;
        a : Boolean;
    begin
        a := Remplacer_r(Arbre, Cle, Donnee, 1);
    end Remplacer;

    procedure Enregistrer(Arbre : in out T_Arbre ; Cle : String ; Donnee : in T_Donnee;nul_donnee : in T_Donnee) is

        procedure Enregistrer_r (Arbre : in out T_Arbre ; Cle : String ; Donnee : in T_Donnee;nul_donnee : in T_Donnee; idx : in Integer;Cle_feuille : in String; Donnee_feuille : in T_Donnee ) is
            nuls : String(1..32) := (others => Character'Val(0));
            nv_arbre : T_Arbre;

            Cle_feuille_r : String(1..32);
            Donnee_feuille_r : T_Donnee;
        begin
            Initialiser(nv_arbre);
            if Arbre = null then
                if Cle_feuille = nuls then
                    Arbre := new T_Node;
                    Arbre.all.Cle := Cle;
                    Arbre.all.Donnee := Donnee;
                    Arbre.all.Suivant_G := null;
                    Arbre.all.Suivant_D := null;
                    Arbre.all.leaf := true;
                else 
                    if Cle(idx) = Cle_feuille(idx) then
                        Enregistrer_r(Arbre, Cle, Donnee,nul_donnee, idx + 1,Cle_feuille,Donnee_feuille);
                    else 
                        Arbre := new T_Node;

                        Arbre.all.leaf := False;
                        Arbre.all.Cle := nuls;
                        Arbre.all.Donnee := nul_donnee;
                        Arbre.all.Suivant_D := null;
                        Arbre.all.Suivant_G := null;

                        Initialiser(Arbre.all.Suivant_D);
                        Initialiser(Arbre.all.Suivant_G);

                        if CLe(idx) = '1' then
                            Enregistrer_r(Arbre.all.Suivant_D, Cle, Donnee,nul_donnee, idx + 1,nuls,Donnee_feuille);
                            Enregistrer_r(Arbre.all.Suivant_G, Cle_feuille, Donnee_feuille,nul_donnee, idx + 1,nuls,Donnee_feuille);
                        else 
                            Enregistrer_r(Arbre.all.Suivant_G, Cle, Donnee,nul_donnee, idx + 1,nuls,Donnee_feuille);
                            Enregistrer_r(Arbre.all.Suivant_D, Cle_feuille, Donnee_feuille,nul_donnee, idx + 1,nuls,Donnee_feuille);
                        end if;
                    end if;
                end if;
            else        
                if Arbre.all.Cle = Cle then
                    Arbre.all.Donnee := Donnee;
                elsif not Arbre.leaf then
                    if Arbre.all.Cle(idx) = '1' then
                        Enregistrer_r(Arbre.all.Suivant_D, Cle, Donnee,nul_donnee, idx + 1,Cle_feuille,Donnee_feuille);
                    else
                        Enregistrer_r(Arbre.all.Suivant_G, Cle, Donnee,nul_donnee, idx + 1,Cle_feuille,Donnee_feuille);
                    end if;
                else 
                    Cle_feuille_r := Arbre.all.Cle;
                    Donnee_feuille_r := Arbre.all.Donnee;
                    Arbre.all.leaf := False;
                    Arbre.all.Cle := nuls;
                    Arbre.all.Donnee := nul_donnee;
                    Enregistrer_r(Arbre, Cle, Donnee,nul_donnee, idx+1,Cle_feuille_r,Donnee_feuille_r);
                end if;
            end if;
        end Enregistrer_r;

        nuls : String(1..32) := (others => Character'Val(0));
    begin
        Enregistrer_r(Arbre, Cle, Donnee,nul_donnee, 1, nuls, nul_donnee);
    end Enregistrer;

    procedure Supprimer (Arbre : in out T_Arbre; Cle : in String) is
        function Supprimer_r (Arbre: in out T_Arbre; Cle : in String; idx : in Integer) return Boolean is
        begin 
            if Arbre = null then 
                return False;
            else 
                if Arbre.all.Cle = Cle then 
                    return True;
                elsif not Arbre.leaf then
                    if Cle(idx) = '1' then 
                        if Supprimer_r(Arbre.all.Suivant_D, Cle, idx+1) then 
                            if Arbre.all.Suivant_G = null then 
                                return True;
                            else
                                Vider(Arbre.all.Suivant_D);
                                return False;
                            end if;
                        else 
                            if Supprimer_r(Arbre.all.Suivant_G, Cle, idx+1) then 
                                if Arbre.all.Suivant_D = null then 
                                    return True;
                                else
                                    Vider(Arbre.all.Suivant_G);
                                    return False;
                                end if;
                            else 
                                return False;
                            end if;
                        end if;
                    else
                        if Supprimer_r(Arbre.all.Suivant_G, Cle, idx+1) then 
                            if Arbre.all.Suivant_D = null then 
                                return True;
                            else
                                Vider(Arbre.all.Suivant_G);
                                return False;
                            end if;
                        else 
                            if Supprimer_r(Arbre.all.Suivant_D, Cle, idx+1) then 
                                if Arbre.all.Suivant_G = null then 
                                    return True;
                                else
                                    Vider(Arbre.all.Suivant_D);
                                    return False;
                                end if;
                            else 
                                return False;
                            end if;
                        end if;
                    end if;
                else 
                    return False;
                end if;
            end if;
        end Supprimer_r;
        a : Boolean;
    begin
        a := Supprimer_r(Arbre, Cle, 1);
    end Supprimer;

    function Cle_Presente (Arbre : in T_Arbre; Cle : in String) return Boolean is
        function Cle_Presente_r (Arbre : in T_Arbre; Cle : in String; idx : in Integer) return Boolean is
        begin
            if Arbre = null then
                return False;
            else
                if Arbre.all.Cle = Cle then
                    return True;
                elsif not Arbre.leaf then
                    if Arbre.all.Cle(idx) = '1' then
                        if not  Cle_Presente_r(Arbre.all.Suivant_D, Cle, idx + 1) then
                            return Cle_Presente_r(Arbre.all.Suivant_G, Cle, idx + 1);
                        else
                            return True;
                        end if;
                    else
                        if not Cle_Presente_r(Arbre.all.Suivant_G, Cle, idx + 1) then 
                            return Cle_Presente_r(Arbre.all.Suivant_D, Cle, idx + 1);
                        else
                            return True;
                        end if;
                    end if;
                else 
                    return False;
                end if;
            end if;
        end Cle_Presente_r;
    begin
        return Cle_Presente_r(Arbre, Cle, 1);
    end Cle_Presente;

    function La_Donnee (Arbre : in T_Arbre; Cle : in String;nul_donnee : in T_Donnee) return T_Donnee is
        function Donnee_r (Arbre :in T_Arbre; Cle : in String; idx : in Integer;nul_donnee : in T_Donnee) return T_Donnee is
        begin
            if Arbre /= null then
                if Arbre.all.Cle = Cle then
                    return Arbre.all.Donnee;
                else 
                    if Arbre.all.Cle(idx) = '1' then
                        if Donnee_r(Arbre.all.Suivant_D, Cle, idx + 1, nul_donnee) = nul_donnee then
                            return Donnee_r(Arbre.all.Suivant_G, Cle, idx + 1, nul_donnee);
                        else
                            return Donnee_r(Arbre.all.Suivant_D, Cle, idx + 1, nul_donnee);
                        end if;
                    else
                        if Donnee_r(Arbre.all.Suivant_G, Cle, idx + 1,nul_donnee) = nul_donnee then
                            return Donnee_r(Arbre.all.Suivant_D, Cle, idx + 1, nul_donnee);
                        else
                            return Donnee_r(Arbre.all.Suivant_G, Cle, idx + 1, nul_donnee);
                        end if; 
                    end if;

                end if;
            else
                return nul_donnee;
            end if;
        end Donnee_r;

    begin
        if Cle_Presente(Arbre, Cle) then
            return Donnee_r(Arbre, Cle, 1,nul_donnee);
        else
            return nul_donnee;
        end if;
    end La_Donnee;

    procedure Vider (Arbre : in out T_Arbre) is
    begin
        if Arbre = null then
            Free(Arbre);
        else
            Vider(Arbre.all.Suivant_D);
            Vider(Arbre.all.Suivant_G);
            Free(Arbre);
        end if;

    end Vider;

    procedure Pour_Chaque (Arbre : in out T_Arbre) is
    begin
        if Arbre = null then
            null;
        else
            if Arbre.all.leaf then
                Put_Line("");
                Traiter(Arbre.all.Cle, Arbre.all.Donnee);
            else
                Pour_Chaque(Arbre.all.Suivant_D);
                Pour_Chaque(Arbre.all.Suivant_G);
            end if;
        end if;
    end Pour_Chaque;

    function La_Cle (Arbre : in T_Arbre;donnee : in T_Donnee) return String is
    
        function La_Cle_r (Arbre : in T_Arbre;donnee : in T_Donnee; idx : in Integer) return String is
        nuls : String(1..32) := (others => Character'Val(0));
        the_key : String(1..32);
        begin
            if Arbre = null then
                return nuls;
            else   
                if Arbre.all.leaf then 
                    if equivalente(donnee, Arbre.all.Donnee) then
                        return Arbre.all.Cle;
                    else 
                        return nuls;
                    end if; 
                else 
                    if Arbre.all.Cle(idx) = '1' then
                        the_key := La_Cle_r(Arbre.all.Suivant_D, donnee, idx + 1);
                        if the_key = nuls then
                            return La_Cle_r(Arbre.all.Suivant_G, donnee, idx + 1);
                        else
                            return the_key;
                        end if;
                    else
                        the_key := La_Cle_r(Arbre.all.Suivant_G, donnee, idx + 1);
                        if the_key = nuls then
                            return La_Cle_r(Arbre.all.Suivant_D, donnee, idx + 1);
                        else
                            return the_key;
                        end if;
                    end if;
                end if;
            end if;
        end La_Cle_r;
    begin
        return La_Cle_r(Arbre,donnee, 1);
    end La_Cle;

end arbre;

        