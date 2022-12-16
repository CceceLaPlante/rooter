with Ada.Text_IO; use Ada.Text_IO;

procedure tests is 
    b : String(1..10);
    c : String := "bitch";
    d : String := "Sensei";
begin
    b := b&c;
    Put_Line(b);

end tests;
