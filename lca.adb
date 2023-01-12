with SDA_Exceptions;        
with Ada.Unchecked_Deallocation;


package body lca is

	procedure Free_lca is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);


	procedure Initialiser(Sda: out T_LCA) is
	begin
		Sda := Null;
	end Initialiser;


	function Est_Vide (Sda : T_LCA) return Boolean is
	begin
		return Sda = Null;
	end;


	function Taille (Sda : in T_LCA) return Integer is
	begin
		if Sda = Null then
			return 0;
		else 
			return 1 + Taille(Sda.all.Suivant);
		end if;
	end Taille;


	procedure Enregistrer (Sda : in out T_LCA ; Cle : in T_Cle ; Donnee : in T_Donnee) is
	begin
		if Sda = Null then
			Sda := new T_Cellule;
			Sda.all.Cle := Cle;
			Sda.all.Donnee := Donnee;
			Sda.all.Suivant := Null;
		elsif Sda.all.Cle = Cle then
			Sda.all.Donnee := Donnee;
		else 
			Enregistrer(Sda.all.Suivant,Cle, Donnee);
		end if;
	end Enregistrer;


	function Cle_Presente (Sda : in T_LCA ; Cle : in T_Cle) return Boolean is
	begin
		if Sda = Null then
			return False;
		elsif Sda.all.Cle = Cle then
			return True;
		else
			return Cle_Presente(Sda.all.Suivant, Cle);
		end if;
	end;


	function La_Donnee (Sda : in T_LCA ; Cle : in T_Cle) return T_Donnee is
	begin
		if Sda = Null then
			raise SDA_Exceptions.Cle_Absente_Exception;
		elsif Sda.all.Cle = Cle then
			return Sda.all.Donnee;
		else
			return La_Donnee(Sda.all.Suivant,Cle);
		end if;
	end La_Donnee;

	
	-- cette fonction n'est utilisee null part,mais pourrait s'aver utile
	function Precedente (Sda: in T_LCA; Cle : in T_Cle) return T_LCA is
	begin
		if Sda = Null then
			raise SDA_Exceptions.Cle_Absente_Exception;
		elsif Sda.all.Suivant.Cle = Cle then 
			return Sda;
		else 
			return Precedente(Sda.all.Suivant, Cle);
		
		end if;

	end Precedente;

	procedure Supprimer (Sda : in out T_LCA ; Cle : in T_Cle) is
		sda_tampon : T_LCA;
	begin
		if Sda = Null then 
			raise SDA_Exceptions.Cle_Absente_Exception;

		-- cette partie ne s'executeras que si le maillon à supprimer est le premier de chaine.
		elsif Sda.all.Cle = Cle then 
			sda_tampon := Sda;
			Sda := Sda.all.Suivant;
			Free(sda_tampon);
		--on s'interesse toujours a ce qu'il y a 2 maillons plus loins dans la liste chainee
		elsif Sda.all.Suivant.all.Cle = Cle then
			sda_tampon := Sda.all.Suivant.all.Suivant;
			Free(Sda.all.Suivant);
			-- on raccroche ensuite les maillons 
			Sda.all.Suivant := sda_tampon;
		else 
			Supprimer(Sda.all.Suivant, Cle);
		end if;
		
	end Supprimer;


	procedure Vider (Sda : in out T_LCA) is
	begin
		if Sda /= Null then
			Vider(Sda.all.Suivant);
			Free(Sda);
		end if;
	end Vider;


	procedure Pour_Chaque (Sda : in T_LCA) is

		procedure pour_chaque_sda (Sda : in T_LCA) is 
		begin
			if Sda /= Null then
				begin
					Traiter(Sda.all.Cle, Sda.all.Donnee);
				exception 
					when others =>
						Null;
				end;
				pour_chaque_sda(Sda.all.Suivant);
			end if;
		end pour_chaque_sda;

	begin

		pour_Chaque_sda(Sda);

	end Pour_Chaque;


end lca;
