with Ada.Strings;               use Ada.Strings;	-- pour Both utilisé par Trim
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Exceptions;            use Ada.Exceptions;	-- pour Exception_Message

procedure tests is 

    function Lire (Entree : File_Type) return String is
        to_read : Unbounded_String;
    begin 
        to_read := To_Unbounded_String(Get_Line(Entree));
        return To_String(to_read);
        
    end Lire;
    Entree : File_Type;
    Entree2 : File_Type;
begin
    Open(Entree,In_File,"table.txt");
    Open(Entree2,In_File,"destination.txt");
    Put_Line(Lire(Entree));
    Put_Line(Lire(Entree2));
    Put_Line(Lire(Entree));
    Put_Line(Lire(Entree2));
    Put_Line(Lire(Entree));
    Put_Line(Lire(Entree2));
    Close(Entree);
    Close(Entree2);
    
end tests;
