/* FonctionsPL/pgSQL qui ne sont pas utilisees pour definir les triggers 
 * Les fonctions PL/pgSQL pour les operations courantes : gestion (insertion et mise a jour), archivage.
 *
 * Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_functions.sql'
 */
 
 
CREATE OR REPLACE FUNCTION ajout_musicien(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text) 
RETURNS BOOLEAN AS $$
	BEGIN
		
		INSERT INTO musicien VALUES (default, nom, prenom, date_naissance ,telephone , adresse, mail);
		RETURN TRUE;
	END;
$$ LANGUAGE plpgsql;
 
 
 