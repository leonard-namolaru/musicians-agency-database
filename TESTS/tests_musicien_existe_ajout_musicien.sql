/* Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/TESTS/tests_musicien_existe_ajout_musicien.sql'
 */

--- musicien_existe(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text) -> INTEGER

-- Le Musicien existe , id = 1
SELECT musicien_existe('Gene', 'Ousby', '1985-09-28', '372-106-3084', '1933 Meadow Vale Lane', 'gousby0@google.cn');

-- NOTICE:  Le Musicien existe pas.
SELECT musicien_existe('Lenny', 'Cohen', '1995-07-28', '373-107-3095', '1934 Meadow Vale Lane', 'lenny@google.com');

-- ERREUR:  Ce musicien est deja dans la base de donnees, son numero id dans la table des musiciens est : 1 .
SELECT ajout_musicien('Gene', 'Ousby', '1985-09-28', '372-106-3084', '1933 Meadow Vale Lane', 'gousby0@google.cn', '{1,2}', '{1,2}');

-- NOTICE:  Insertion OK.
SELECT ajout_musicien('Lenny', 'Cohen', '1995-07-28', '373-107-3095', '1934 Meadow Vale Lane', 'lenny@google.com', '{1,2}', '{1,2}');

/* Nous supprimons afin de pouvoir effectuer à nouveau le test précédent à l'avenir. 
 * Après suppression, nous effectuerons un test pour vérifier que l'utilisateur n'existe vrement pas en utilisant la fonction dédiée.
 */
DELETE FROM joue WHERE musicien_id = ( SELECT musicien_id FROM musicien 
WHERE musicien_nom = 'Lenny' 
	  AND musicien_prenom = 'Cohen' 
	  AND musicien_date_naissance = '1995-07-28' 
	  AND musicien_telephone = '373-107-3095' 
	  AND musicien_adresse = '1934 Meadow Vale Lane' 
	  AND musicien_mail = 'lenny@google.com' );
 
DELETE FROM maitrise WHERE musicien_id = ( SELECT musicien_id FROM musicien 
WHERE musicien_nom = 'Lenny' 
	  AND musicien_prenom = 'Cohen' 
	  AND musicien_date_naissance = '1995-07-28' 
	  AND musicien_telephone = '373-107-3095' 
	  AND musicien_adresse = '1934 Meadow Vale Lane' 
	  AND musicien_mail = 'lenny@google.com' );
 
DELETE FROM musicien 
WHERE musicien_nom = 'Lenny' 
	  AND musicien_prenom = 'Cohen' 
	  AND musicien_date_naissance = '1995-07-28' 
	  AND musicien_telephone = '373-107-3095' 
	  AND musicien_adresse = '1934 Meadow Vale Lane' 
	  AND musicien_mail = 'lenny@google.com';

-- NOTICE:  Le Musicien existe pas.
SELECT musicien_existe('Lenny', 'Cohen', '1995-07-28', '373-107-3095', '1934 Meadow Vale Lane', 'lenny@google.com');
	  