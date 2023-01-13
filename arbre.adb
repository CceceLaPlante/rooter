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

        procedure Supprimer_r (Arbre : in out T_Arbre; Cle : in String; idx : in Integer; oldest : in out T_Arbre;G : in Boolean) is
            updater : Boolean := False;
        begin
            if Arbre = null then
                null;
            else 
                if Arbre.all.leaf then 
                    if Arbre.all.Cle = Cle then
                        if G then 
                            Vider(oldest.all.Suivant_G);
                        else 
                            Vider(oldest.all.Suivant_D);
                        end if;
                    end if;
                else 
                    if Arbre.all.Suivant_D = null  or Arbre.all.Suivant_G = null then
                        Free(Arbre);
                    else
                        if Arbre.all.Suivant_D.leaf = True and Arbre.all.Suivant_G.leaf = True then
                            updater := True;
                        end if;
                        
                    end if;
                    if Cle(idx) = '1' then
                        if Arbre.all.Suivant_D /= null then 
                            if updater then 
                                Supprimer_r(Arbre.all.Suivant_D, Cle, idx + 1, Arbre,False);
                            else 
                                Supprimer_r(Arbre.all.Suivant_D, Cle, idx + 1, oldest,G);
                            end if;
                        end if;
                    else 
                        if Arbre.all.Suivant_G /= null then
                            if updater then
                                Supprimer_r(Arbre.all.Suivant_G, Cle, idx + 1, Arbre,True);
                            else
                                Supprimer_r(Arbre.all.Suivant_G, Cle, idx + 1, oldest,G);
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end Supprimer_r;
    begin
        if Arbre.all.Cle = Cle then
            Free(Arbre);
        else 
            if Arbre.all.Suivant_D = null then 
                Supprimer_r(Arbre.all.Suivant_G, Cle, 2, Arbre,True);
            elsif Arbre.all.Suivant_G = null then 
                Supprimer_r(Arbre.all.Suivant_D, Cle, 2, Arbre,False);
            elsif Cle(1) = '1' then 
                Supprimer_r(Arbre.all.Suivant_D, Cle, 2, Arbre,False);
            else
                Supprimer_r(Arbre.all.Suivant_G, Cle, 2, Arbre,True);
            end if;
        end if;
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
                        return Cle_Presente_r(Arbre.all.Suivant_D, Cle, idx + 1);
                    else
                        return Cle_Presente_r(Arbre.all.Suivant_G, Cle, idx + 1);
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
            if Arbre = null then
                null;
            else
                if Arbre.all.Cle = Cle then
                    return Arbre.all.Donnee;
                elsif not Arbre.leaf then
                    if Arbre.all.Cle(idx) = '1' then
                        return Donnee_r(Arbre.all.Suivant_D, Cle, idx + 1, nul_donnee);
                    else
                        return Donnee_r(Arbre.all.Suivant_G, Cle, idx + 1,nul_donnee);
                    end if;
                else 
                    return nul_donnee;
                end if;
            end if;
        end Donnee_r;

    begin
        if Cle_Presente(Arbre, Cle) then
            return Donnee_r(Arbre, Cle, 1,nul_donnee);
        else
            raise Constraint_Error with "Cle non presente";
        end if;
    end La_Donnee;

    procedure Vider (Arbre : in out T_Arbre) is
    begin
        if Arbre = null then
            null;
        else
            if not Arbre.leaf then
                Vider(Arbre.all.Suivant_D);
                Vider(Arbre.all.Suivant_G);
            end if;
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

    function La_Cle (Arbre : in T_Arbre;donnee : in T_Donnee;msk : in String) return String is
    
        function La_Cle_r (Arbre : in T_Arbre;donnee : in T_Donnee;msk : in String; idx : in Integer) return String is
        begin
            if Arbre = null then
                return "";
            else
                if equivalente(Arbre.all.Donnee, donnee) then
                    return Arbre.all.Cle;
                end if; 

                if msk(idx) = '1' then 
                    if Arbre.all.Cle(idx) = '1' then
                        return La_Cle_r(Arbre.all.Suivant_D, donnee,msk, idx + 1);
                    else
                        return La_Cle_r(Arbre.all.Suivant_G, donnee,msk, idx + 1);
                    end if;
                else 
                    return La_Cle_r(Arbre.all.Suivant_D, donnee, msk, idx + 1) & La_Cle_r(Arbre.all.Suivant_G, donnee, msk, idx + 1);
                end if;
            end if;
        end La_Cle_r;
    begin
        return La_Cle_r(Arbre,donnee, msk, 1);
    end La_Cle;

end arbre;

        