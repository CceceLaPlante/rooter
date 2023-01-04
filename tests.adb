with Ada.Strings;               use Ada.Strings;	-- pour Both utilisé par Trim
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Exceptions;            use Ada.Exceptions;	-- pour Exception_Message

procedure tests is 

    Type T_Cle is new String(1..3);
    a : T_Cle := "abc";

    function t_cle_to_string (c : T_Cle) return String is
        to_return : String(1..3);
    begin
        for i in 1..3 loop
            to_return(i) := c(i);
        end loop;
        return to_return;
    end t_cle_to_string;

begin

    Put(t_cle_to_string(a));
end tests;
