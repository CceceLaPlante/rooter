with Ada.Strings;               use Ada.Strings;	-- pour Both utilisé par Trim
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Exceptions;            use Ada.Exceptions;	-- pour Exception_Message


procedure Ecrire_table is
    Info_entree : Unbounded_String ;
    Info_sortie : Unbounded_String ;
    Texte : Unbounded_String ;
    Entree : File_Type ;
    Sortie : File_Type ;
    Valeur : String ;
begin
    Info_entree := To_Unbounded_String(Argument(1));
    Info_sortie := To_Unbounded_String("fichier_sortie.txt");
    Create(Sortie, Out_File, To_String(Info_Sortie));
    Open(Entree, In_File, To_String(Info_Entree));
    begin
        loop
            Get(Entree,Valeur);
            Texte := Get_Line(Entree);
            Trim(Texte, Both);
            Put(Sortie);
            Put(Sortie, " " & Texte & " ");
            Put(Sortie);
            New_Line(Sortie);
            exit when End_Of_File(Entree)| Texte == 'Fin';
        end loop;
    exception
        when End_Error =>
                Put ("Blancs en surplus à la fin du fichier.");
                null;
    end
    Close(Entree);
    Close(Sortie);
end Ecrire_table ;
