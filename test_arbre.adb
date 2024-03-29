with Ada.Text_IO; use Ada.Text_IO;
with Arbre;

procedure test_arbre is 

    package Arbre_Int is 
        new Arbre (T_Donnee => Integer);
    use Arbre_Int;

    procedure afficher(Cle : String; Donnee : Integer) is
        nuls:String(1..32) := (others => Character'Val(0));
    begin
        if Cle =  nuls then
            Put("");
        else 
            Put_Line (Cle & " : " & Integer'Image(Donnee));
        end if;

    end afficher;

    function equivalente_integer(D1 : Integer; D2 : Integer) return Boolean is
    begin
        return D1 = D2-1;
    end equivalente_integer;

    function La_Cle_integer is new La_Cle(equivalente_integer);

    procedure Afficher is 
        new Pour_Chaque(afficher);

    tree : T_Arbre;
    cle1 : String(1..32) := "11000000101010000000000000000000";
    cle2 : String(1..32) := "01111111000000010000000100000001";
    cle3 : String(1..32) := "00000000000000000000000000000000";
    cle4 : String(1..32) := "00000000000000000000000000000010";
    ladonnee : Integer;
    
begin
    Enregistrer(tree, cle1, 1,0);
    Enregistrer(tree, cle2, 2,0);
    Enregistrer(tree, cle3, 3,0);
    --Enregistrer(tree, cle4, 4,0);
    Afficher(tree);
    Put_Line("---------------------");
    Put_line("suppression  de " & cle1);
    Supprimer(tree, cle1);
    Afficher(tree);
    Put_Line("---------------------");
    if Cle_Presente(tree, cle1) then
        Put_Line("La cle " & cle1 & " est presente");
    else
        Put_Line("La cle " & cle1 & " n'est pas presente");
    end if;
    Put_Line("---------------------");
    ladonnee := La_Donnee(tree, cle2,32);
    Put_Line("La donnee de " & cle2 & " est " & Integer'Image(ladonnee));
    Put_Line("---------------------");
    if Cle_Presente(tree, cle2) then
        Put_Line("La cle " & cle2 & " est presente");
    else
        Put_Line("La cle " & cle2 & " n'est pas presente");
    end if;
    Put_Line("---------------------");
    Put_Line("La_cle equivalentede 2 est :" & La_Cle_integer(tree, 2)) ;
    Put_Line("---------------------");
    Enregistrer(tree, cle2, 2134,0);
    Afficher(tree);
    Put_Line("---------------------");
    Vider(tree);
    Put_Line("arbre vide : ");
    Afficher(tree);
    Put_Line("---------------------");

end test_arbre;
