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
            Put("|");
        else 
            Put_Line("");
            Put_Line (Cle & " : " & Integer'Image(Donnee));
        end if;

    end afficher;

    procedure Afficher is 
        new Pour_Chaque(afficher);

    tree : T_Arbre;
    cle1 : String(1..32) := "00000000000000000000000000000000";
    cle2 : String(1..32) := "11111111111111111111111111111111";
    cle3 : String(1..32) := "00000000000000000000000000000001";
    cle4 : String(1..32) := "00000000000000000000000000000010";
    ladonnee : Integer;
begin
    Put(cle1(32));
    Enregistrer(tree, cle1, 1);
    Enregistrer(tree, cle2, 2);
    Enregistrer(tree, cle3, 3);
    Enregistrer(tree, cle4, 4);
    Afficher(tree);
    Put_Line("---------------------");
    Supprimer(tree, cle1);
    Afficher(tree);
    Put_Line("---------------------");
    ladonnee := La_Donnee(tree, cle2);
    Put_Line("La donnee de " & cle2 & " est " & Integer'Image(ladonnee));
    Put_Line("---------------------");

end test_arbre;
