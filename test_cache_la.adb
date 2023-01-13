with cache_arbre; use cache_arbre;
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
    inter1 : Unbounded_String := To_Unbounded_String("wlansp0");

    dest2 : Unbounded_String := To_Unbounded_String("0.0.0.0");
    mask2 : Unbounded_String := To_Unbounded_String("255.255.0.0");
    inter2 : Unbounded_String := To_Unbounded_String("eth0");

    dest3 : Unbounded_String := To_Unbounded_String("127.1.1.1");
    mask3 : Unbounded_String := To_Unbounded_String("255.255.255.255");
    inter3 : Unbounded_String := To_Unbounded_String("lo");

    dest4 : Unbounded_String := To_Unbounded_String("192.168.2.2");
    mask4 : Unbounded_String := To_Unbounded_String("255.255.255.255");
    inter4 : Unbounded_String := To_Unbounded_String("ether");

    tp :Integer := 0;

    l1 : T_ligne := (dest1, mask1, inter1, 0,0,0);
    l2 : T_ligne := (dest2, mask2, inter2, 0,0,0);
    l3 : T_ligne := (dest3, mask3, inter3, 0,0,0);
    l4 : T_ligne := (dest4, mask4, inter4, 0,0,0);

    Cache_rooter : T_Cache;
    cle1 : String(1..32) := To_String(Convertir_IP2B(dest1));
    
begin
    Initialiser_cache(Cache_rooter);
    Ajouter(Cache_rooter, l1);
    Ajouter(Cache_rooter, l2);
    Ajouter(Cache_rooter, l3);
    Ajouter(Cache_rooter, l4);
    Afficher(Cache_rooter);
    Put_Line("------------------");
    if IP_Presente(Cache_rooter,dest1) then
        Put_Line("IP 1 presente : "&To_String(Trouver(Cache_rooter,dest1).inter));
    else
        Put_Line("IP 1 non presente");
    end if;
    Put_Line("------------------");
    Afficher(Cache_rooter);
    Put_Line("------------------");
    Put_Line("Suppression de l'IP 1");
    Supprimer_IP(Cache_rooter,dest1);
    Afficher(Cache_rooter);
    Put_Line("------------------");
    if IP_Presente(Cache_rooter,dest1) then
        Put_Line("IP 1 presente : "&To_String(Trouver(Cache_rooter,dest1).inter));
    else
        Put_Line("IP 1 non presente");
    end if;
    Put_Line("------------------");
    Ajouter(Cache_rooter, l1);
    Afficher(Cache_rooter);
    Put_Line("------------------");
    Supprimer_LRU(Cache_rooter, 3);
    Afficher(Cache_rooter);
    Put_Line("------------------");


end test_cache_LA;