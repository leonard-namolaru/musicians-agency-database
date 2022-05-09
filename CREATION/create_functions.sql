/* FonctionsPL/pgSQL qui ne sont pas utilisees pour definir les triggers 
 * Les fonctions PL/pgSQL pour les operations courantes : gestion (insertion et mise a jour), archivage.
 */
 
 
CREATE OR REPLACE FUNCTION ajout_musicien(nom VARCHAR, prenom VARCHAR, date_naissance DATE, telephone VARCHAR, mail VARCHAR) RETURNS BOOLEAN AS $$
	BEGIN
		
		INSERT INTO musicien VALUES (default, nom, prenom, date_naissance ,telephone , mail);
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;
 
 