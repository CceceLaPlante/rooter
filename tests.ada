with Ada.Text_IO; use Ada.Text_IO;

procedure tests is 
    e : Integer(range(0..10));
begin
    e(2) := 666;
    Put_Line(Integer'Image(e(2)));
end tests;
