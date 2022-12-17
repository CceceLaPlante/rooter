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

    type T_Table;
    type T_Liste is access T_Table;
    type T_Table is 
        record 
            destination : Unbounded_String;
            mask : Unbounded_String;
            inter : Unbounded_String;
            Suivant : T_Liste;
            cle : Integer;
        end record;

    lst : T_Liste := Null ;


begin
    lst := new T_Table;
    lst.all.destination := To_Unbounded_String("abc");
    lst.all.mask := To_Unbounded_String("def");
    lst.all.inter := To_Unbounded_String("ghi");
    lst.all.cle := 1;
    lst.all.Suivant := Null;
    Put_Line(lst.all.destination&lst.all.mask&lst.all.inter);
    
    
end tests;
