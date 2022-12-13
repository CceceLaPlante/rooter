procedure Ecrire_table is
    Info_entree : Unbounded_String ;
    Info_sortie : Unbounded_String ;
    Texte : Unbounded_String ;
    Entree : File_Type ;
    Sortie : File_Type ;
    Valeur : String ;
begin
    Info_entree := To_Unbounded_String(Argument(1));
    Info_sortie := To_Unbounded_String("info_sortie.txt");
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
            exit when End_Of_File(Entree);
        end loop;
    exception
        when End_Error =>
                Put ("Blancs en surplus à la fin du fichier.");
                null;
