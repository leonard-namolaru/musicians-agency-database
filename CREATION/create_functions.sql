/* FonctionsPL/pgSQL qui ne sont pas utilisees pour definir les triggers 
 * Les fonctions PL/pgSQL pour les operations courantes de gestion 
 *
 * Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_functions.sql'
 */

---------------------------------------- MUSICIEN ---------------------------------------------------------

/**
  * Signature : musicien_existe(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text) -> INTEGER
  * Description : Une fonction qui reçoit comme paramètres nom, prenom, téléphone, etc. et vérifie si un tel musicien existe.
  * 
  * Parametres :
  ** nom text : la nom du musicien.
  ** prenom text : le prenom du musicien.
  ** date_naissance date : la date de naissance du musicien
  ** telephone text : le telephone de l'agent (format : '123-456-1234')
  ** adresse text : l'adresse du musicien
  ** mail text : l'adresse mail du musicien (format : 'X@Y.Z')
  
  * Valeur de retour : le numero d'id du musicien si il existe ou -1 en cas d’erreur (le musicien existe PAS).
  */
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

/**
  * Signature : ajout_musicien(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text, instruments INTEGER[], styles_musique INTEGER[]) -> BOOLEAN
  * Description : Une fonction qui reçoit comme paramètres : nom, prenom, téléphone, etc. et ajoute un nouveau musicien s'il n'existe pas deja.
  *               De plus, la fonction reçoit en paramètre 2 tableaux : 
  *                - un tableau des id des instruments de musique que le musicien maitrise
  *                - un tableau des id des styles de musique du musicien. 
  *               La fonction ajoute ces informations aux tables appropriées.
  * 
  * Parametres :
  ** nom text : la nom du musicien.
  ** prenom text : le prenom du musicien.
  ** date_naissance date : la date de naissance du musicien
  ** telephone text : le telephone de l'agent (format : '123-456-1234')
  ** adresse text : l'adresse du musicien
  ** mail text : l'adresse mail du musicien (format : 'X@Y.Z')
  ** instruments INTEGER[] : un tableau des id des instruments de musique que le musicien maitrise (Par exemple : '{1,2}')
  ** styles_musique INTEGER[] : un tableau des id des styles de musique du musicien (Par exemple : '{1,2}')
  *
  * Valeur de retour : true si le musicien est ajouté avec succès, false si le musicien existe déjà.
  */
CREATE OR REPLACE FUNCTION ajout_musicien(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text, instruments INTEGER[], styles_musique INTEGER[]) 
RETURNS BOOLEAN AS $$
	DECLARE
	is_musicien_existe INTEGER;
	i INTEGER; -- Index boucle while
	
	-- array_length ( anyarray, integer ) -> integer
	-- Renvoie la longueur de la dimension de tableau demandée.
	instruments_count INTEGER := array_length(instruments, 1);
	styles_musique_count INTEGER := array_length(styles_musique, 1);
	
	nouveau_musicien_id INTEGER;
	BEGIN
		is_musicien_existe := musicien_existe(nom, prenom, date_naissance, telephone, adresse, mail);
	
		IF is_musicien_existe != -1 THEN
			RAISE 'Ce musicien est deja dans la base de donnees, son numero id dans la table des musiciens est : % .', is_musicien_existe USING ERRCODE='10001';
			RETURN FALSE;
		END IF;
		
		INSERT INTO musicien VALUES (default, nom, prenom, date_naissance ,telephone , adresse, mail);
		RAISE NOTICE 'Insertion du nouveau musicien OK.';
		
		-- Maintenant qu'on sait que le musicien existe, on veut juste avoir son id
		nouveau_musicien_id := musicien_existe(nom, prenom, date_naissance, telephone, adresse, mail);
		
		-- Par défaut, un tableau de n éléments commence par array[1] et se termine par array[n].
		i := 1;
		
		-- Ajout des instruments de musique que le musicien maitrise
		WHILE (i <= instruments_count)
		LOOP
			INSERT INTO joue VALUES (nouveau_musicien_id, instruments[i]);	-- (musicien_id,instrument_id)		
			i := (i + 1);
		END LOOP;
		
		i := 1;
		
		-- Ajout des styles de musique du musicien
		WHILE (i <= styles_musique_count)
		LOOP
			INSERT INTO maitrise VALUES (nouveau_musicien_id, instruments[i]);	--  (musicien_id,style_id)	
			i := (i + 1);
		END LOOP;
		
		RETURN TRUE;
	END;
$$ LANGUAGE plpgsql;
 
---------------------------------------- AGENT ---------------------------------------------------------

/**
  * Signature : agent_existe(nom text, prenom text, telephone text, date_embauche DATE) -> INTEGER
  * Description : Une fonction qui reçoit comme paramètres nom, prenom, téléphone, etc. et vérifie si un tel agent existe.
  * 
  * Parametres :
  ** nom text : la nom de l'agent.
  ** prenom text : le prenom de l'agent.
  ** telephone text : le telephone de l'agent (format : '123-456-1234')
  ** date_embauche DATE : la date d'embauche de l'agent
  *
  * Valeur de retour : le numero d'id de l'agent si il existe ou -1 en cas d’erreur (l'agent existe PAS).
  */
CREATE OR REPLACE FUNCTION agent_existe(nom text, prenom text, telephone text, date_embauche DATE) 
RETURNS INTEGER AS $$
	DECLARE
		id INTEGER;
	BEGIN	
			
		SELECT agent_id INTO id
		FROM agent 
		WHERE agent_nom = nom 
		      AND agent_prenom = prenom 
		      AND agent_telephone = telephone 
		      AND agent_mail = mail
		      AND agent_date_embauche = date_embauche;
		      
		IF FOUND THEN 
			RAISE NOTICE 'Agent existe , id = % .', id;
			RETURN id;
		END IF;
			
		RAISE NOTICE 'Agent existe pas.';
		RETURN -1;
	END;
$$ LANGUAGE plpgsql;

/**
  * Signature : ajout_agent(nom text, prenom text, telephone text, date_embauche DATE) -> BOOLEAN
  * Description : Une fonction qui reçoit comme paramètres : nom, prenom, téléphone, etc. et ajoute un nouveau agent s'il n'existe pas deja.
  * 
  * Parametres :
  ** nom text : la nom de l'agent.
  ** prenom text : le prenom de l'agent.
  ** telephone text : le telephone de l'agent (format : '123-456-1234')
  ** date_embauche DATE : la date d'embauche de l'agent
  *
  * Valeur de retour : true si l'agent est ajouté avec succès, false si l'agent existe déjà.
  */
CREATE OR REPLACE FUNCTION ajout_agent(nom text, prenom text, telephone text, date_embauche DATE) 
RETURNS BOOLEAN AS $$
	DECLARE
	is_agent_existe INTEGER;
	BEGIN
		is_agent_existe := agent_existe(nom, prenom, telephone, date_embauche);
	
		IF is_agent_existe != -1 THEN
			RAISE 'L agent est deja dans la base de donnees, son numero id dans la table des agents est : % .', is_agent_existe USING ERRCODE='10000';
			RETURN FALSE;
		END IF;
		
		INSERT INTO agent VALUES (default, nom, prenom, telephone, date_embauche);
		RAISE NOTICE 'Insertion OK.';
		RETURN TRUE;
	END;
$$ LANGUAGE plpgsql;


---------------------------------------- CONTRAT_ARTISTE_PRODUCTEUR --------------------------------------------
/**
  * Signature   : contrat_reste_a_payer(id_contrat integer) ->  integer
  * Description : Trouver les demandes adaptées a un musicien. C'est-à-dire des demandes qui 
  *               n'ont pas encore expiré (qui n'ont pas encore atteint leur date de fin) et 
  *               qui incluent des instruments de musique et un style de musique qui conviennent au musicien.
  * 
  *  Parametres :
  ** id_contrat integer : ID du contrat artiste producteur.
  *
  * Valeur de retour : La fonction retourne le reste a payer (somme de la renumeration total - paiements anterieurs)
  */
CREATE OR REPLACE FUNCTION contrat_reste_a_payer(id_contrat integer) 
RETURNS integer AS $$
	DECLARE
		paiements_anterieurs integer; -- Montant des paiements antérieurs
		contrat_renumeration_total integer;
	BEGIN
	    SELECT contrat_renumeration INTO contrat_renumeration_total
		FROM  contrat_artiste_producteur
		WHERE contrat_id = id_contrat;
			    
		SELECT SUM(paiement_montant_brut) INTO paiements_anterieurs
		FROM paiement_artiste
		WHERE contrat_id = id_contrat
		GROUP BY contrat_id;
		
		IF NOT FOUND THEN -- Si pas de paiements anterieurs
			paiements_anterieurs := 0;
		END IF;
		
		RETURN (contrat_renumeration_total - paiements_anterieurs);
	END;
$$ LANGUAGE plpgsql;

---------------------------------------- DEMANDE ---------------------------------------------------------------

/**
  * Signature : trouver_musiciens_repondre_demande(id_demande integer, musiciens_exclure_resultats integer[]) -> BOOLEAN
  * Description : Trouver des musiciens pour répondre à une demande. C'est-à-dire que la fonction trouve la liste des musiciens 
  * 			  qui contrôlent l'instrument qui apparaît dans la demande et en même temps ce sont des musiciens dont le style 
  *               de musique est tel qu'il apparaît dans la demande.
  * 
  * Parametres :
  ** id_demande integer : ID de la demande.
  *
  * Valeur de retour : La fonction retourne un type “ensemble” (SETOF) de la table musicien 
  */
CREATE OR REPLACE FUNCTION trouver_musiciens_repondre_demande(id_demande integer) 
RETURNS SETOF musicien AS $$
-- La fonction retourne un type “ensemble” (SETOF)
	DECLARE
		demande demande%ROWTYPE;
	BEGIN
		SELECT * INTO demande FROM demande WHERE demande_id = id_demande;
		IF NOT FOUND THEN 
			RAISE EXCEPTION 'La demande numero % est inexistante.', id_demande USING ERRCODE = '10002' ; 
		END IF;
		
		RETURN QUERY SELECT * FROM musicien WHERE musicien_id IN (SELECT musicien_id FROM joue WHERE instrument_id = demande.instrument_id) AND musicien_id IN (SELECT musicien_id FROM maitrise WHERE style_id = demande.style_musique_id);
	END;
$$ LANGUAGE plpgsql;

/**
  * Signature : trouver_musiciens_repondre_demande(id_demande integer) -> SETOF musicien
  * Description : Trouver des musiciens pour répondre à une demande. C'est-à-dire que la fonction trouve la liste des musiciens 
  * 			  qui contrôlent l'instrument qui apparaît dans la demande et en même temps ce sont des musiciens dont le style 
  *               de musique est tel qu'il apparaît dans la demande.
  * 
  * Parametres :
  ** id_demande integer : ID de la demande.
  *
  * Valeur de retour : La fonction retourne un type “ensemble” (SETOF) de la table musicien 
  */
CREATE OR REPLACE FUNCTION trouver_musiciens_repondre_demande(id_demande integer) 
RETURNS SETOF musicien AS $$
-- La fonction retourne un type “ensemble” (SETOF)
	DECLARE
		demande demande%ROWTYPE;
	BEGIN
		SELECT * INTO demande FROM demande WHERE demande_id = id_demande;
		IF NOT FOUND THEN 
			RAISE EXCEPTION 'La demande numero % est inexistante.', id_demande USING ERRCODE = '10002' ; 
		END IF;
		
		RETURN QUERY SELECT * FROM musicien WHERE musicien_id IN (SELECT musicien_id FROM joue WHERE instrument_id = demande.instrument_id) 
		                                    AND musicien_id IN (SELECT musicien_id FROM maitrise WHERE style_id = demande.style_musique_id);
	END;
$$ LANGUAGE plpgsql;

/**
  * Signature   : trouver_demandes_adaptees_musicien(id_musicien integer)  ->  SETOF demande
  * Description : Trouver les demandes adaptées a un musicien. C'est-à-dire des demandes qui 
  *               n'ont pas encore expiré (qui n'ont pas encore atteint leur date de fin) et 
  *               qui incluent des instruments de musique et un style de musique qui conviennent au musicien.
  * 
  *  Parametres :
  ** id_musicien integer : ID du musicien.
  *
  * Valeur de retour : La fonction retourne un type “ensemble” (SETOF) de la table demande 
  */
CREATE OR REPLACE FUNCTION trouver_demandes_adaptees_musicien(id_musicien integer) 
RETURNS SETOF demande AS $$
-- La fonction retourne un type “ensemble” (SETOF)
	DECLARE
		instruments integer[];
		styles_musique integer[];
	BEGIN
		
		instruments := ARRAY (SELECT instrument_id FROM joue WHERE musicien_id = id_musicien);
		
		-- array_length ( anyarray, integer ) -> integer
		-- Renvoie la longueur de la dimension de tableau demandée.
		IF ( (array_length(instruments, 1)) = 0) THEN 
			RAISE EXCEPTION 'Aucun instrument trouve pour un musicien dont le numero id est % .', id_musicien USING ERRCODE = '10003' ; 
		END IF;
				
		styles_musique := ARRAY (SELECT style_id FROM maitrise WHERE musicien_id = id_musicien);
		IF ( (array_length(styles_musique, 1)) = 0) THEN 
			RAISE EXCEPTION 'Aucun style de musique trouve pour un musicien dont le numero id est % .', id_musicien USING ERRCODE = '10004' ; 
		END IF;		
		
		RETURN QUERY SELECT * FROM demande WHERE instrument_id = ANY (instruments::int[]) 
		                               AND style_musique_id = ANY (styles_musique::int[])
		                               AND demande_date_fin >= CURRENT_DATE;
	END;
$$ LANGUAGE plpgsql;

---------------------------------------- CONTRAT_AGENT_ARTISTE --------------------------------------------

/**
  * Signature   : exportation_contrats_en_vigueur(systeme_exploitation text) -> void
  * Description : Exportation de tous les contrats actuellement en vigueur. 
  *               La destination pour l'exportation sur Windows : C:\Users\Public\contrats_en_vigueur.csv 
  * 	          La destination pour l'exportation sur Linux ou Mac : /tmp/contrats_en_vigueur.csv
  *
  *  Parametres :
  ** systeme_exploitation text : Cette fonction ne peut accepter que une les valeurs suivantes en tant que parametre : WINDOWS LINUX MAC.
  *
  * Valeur de retour : void
  */
CREATE OR REPLACE FUNCTION exportation_contrats_en_vigueur(systeme_exploitation text) 
RETURNS void AS $$
	BEGIN
		
		IF systeme_exploitation = 'WINDOWS' THEN
			
			COPY (SELECT * FROM contrat_agent_artiste WHERE ( (contrat_debut <= CURRENT_DATE AND contrat_fin = NULL) 
			OR (contrat_debut <= CURRENT_DATE AND contrat_fin >= CURRENT_DATE) )) TO 'C:\Users\Public\contrats_en_vigueur.csv'  WITH DELIMITER ',' CSV HEADER;
			
			RAISE NOTICE 'La destination pour l exportation : C:\Users\Public\contrats_en_vigueur.csv .'; 
		ELSEIF systeme_exploitation = 'MAC' OR systeme_exploitation = 'LINUX' THEN
			
			COPY (SELECT * FROM contrat_agent_artiste WHERE ( (contrat_debut <= CURRENT_DATE AND contrat_fin = NULL) 
			OR (contrat_debut <= CURRENT_DATE AND contrat_fin >= CURRENT_DATE) )) TO '/tmp/contrats_en_vigueur.csv'  WITH DELIMITER ',' CSV HEADER;
			
			RAISE NOTICE 'La destination pour l exportation : /tmp/contrats_en_vigueur.csv .'; 
		ELSE
			RAISE EXCEPTION 'Cette fonction ne peut accepter que une les valeurs suivantes en tant que parametre : WINDOWS LINUX MAC .' USING ERRCODE = '10008' ; 
		END IF;
		
	END;
$$ LANGUAGE plpgsql;