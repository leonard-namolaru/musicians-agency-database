/* FonctionsPL/pgSQL qui ne sont pas utilisees pour definir les triggers 
 * Les fonctions PL/pgSQL pour les operations courantes : gestion (insertion et mise a jour), archivage.
 *
 * Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_functions.sql'
 */
 
=
CREATE OR REPLACE FUNCTION musicien_existe(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text) 
RETURNS INTEGER AS $$
	DECLARE
		id INTEGER;
	BEGIN
		
		SELECT musicien_id INTO id
		FROM musicien 
		WHERE musicien_nom = nom 
		     AND musicien_prenom = prenom 
		     AND musicien_date_naissance = date_naissance 
		     AND musicien_telephone = telephone 
		     AND musicien_adresse = adresse 
		     AND musicien_mail = mail;
		     
		IF FOUND THEN 
			RAISE NOTICE 'Le Musicien existe , id = % .', id;
			RETURN id;
		END IF;
			
		RAISE NOTICE 'Le Musicien existe pas.';
		RETURN -1;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ajout_musicien(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text) 
RETURNS BOOLEAN AS $$
	DECLARE
	is_musicien_existe INTEGER;
	BEGIN
		is_musicien_existe := musicien_existe(nom, prenom, date_naissance, telephone, adresse, mail);
	
		IF is_musicien_existe != -1 THEN
			RAISE 'Ce musicien est deja dans la base de donnees, son numero id dans la table des musiciens est : % .', is_musicien_existe USING ERRCODE='10000';
			RETURN FALSE;
		END IF;
		
		INSERT INTO musicien VALUES (default, nom, prenom, date_naissance ,telephone , adresse, mail);
		RAISE NOTICE 'Insertion OK.';
		RETURN TRUE;
	END;
$$ LANGUAGE plpgsql;