with Cache_Arbre; use Cache_Arbre;
with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.Unchecked_Deallocation; 

with Ada.Calendar;            use Ada.Calendar;
with Ada.Calendar.Formatting; use Ada.Calendar.Formatting;
with Ada.Text_IO;             use Ada.Text_IO;

procedure test_cache_LA is


    dest1 : Unbounded_String := To_Unbounded_String("192.168.0.0");
    mask1 : Unbounded_String := To_Unbounded_String("255.255.0.0");
    inter1 : Unbounded_String := To_Unbounded_String("wlans0");

    dest2 : Unbounded_String := To_Unbounded_String("0.0.0.0");
    mask2 : Unbounded_String := To_Unbounded_String("0.0.0.0");
    inter2 : Unbounded_String := To_Unbounded_String("eth0");

    dest3 : Unbounded_String := To_Unbounded_String("127.1.1.1");
    mask3 : Unbounded_String := To_Unbounded_String("255.255.255.255");
    inter3 : Unbounded_String := To_Unbounded_String("lo");

    tp : Time := Clock;

    Cache_rooter : T_Cache;
    
begin
    Initialiser_cache(Cache_rooter);
end test_cache_LA;