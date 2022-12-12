with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
procedure Getline is
   F : File_Type;
   F2 : File_Type;
   File_Path2 : constant String := "yeet_2.txt";
   File_Path : constant String := "testAda.txt";

    A : Unbounded_String;
    B : Unbounded_String;

begin

    Open (File => F, Mode => In_File, Name => File_Path);
    A := Get_Line (F);
    B := Get_Line(F);

    Put (A);
    put_Line("UwU");
    Put(B);

    Open (File => F2, Mode => Out_File, Name => File_Path2);

    Put_Line(F2, A);
    Put_Line(F2, B);
    Close(File => F2);
    Close (File => F);
        

end Getline;