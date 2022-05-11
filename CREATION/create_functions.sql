/* FonctionsPL/pgSQL qui ne sont pas utilisees pour definir les triggers 
 * Les fonctions PL/pgSQL pour les operations courantes : gestion (insertion et mise a jour), archivage.
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


---------------------------------------- PRODUCTEUR -----------------------------------------------------------

---------------------------------------- INSTRUMENT -----------------------------------------------------------

---------------------------------------- STYLE_MUSIQUE ---------------------------------------------------------

---------------------------------------- CONTRAT_ARTISTE_PRODUCTEUR --------------------------------------------

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
			RAISE EXCEPTION 'La demande numero % est inexistante  ', id_demande USING ERRCODE = '10002' ; 
		END IF;
		
		RETURN QUERY SELECT * FROM musicien WHERE musicien_id IN (SELECT musicien_id FROM joue WHERE instrument_id = demande.instrument_id) AND musicien_id IN (SELECT musicien_id FROM maitrise WHERE style_id = demande.style_musique_id);
	END;
$$ LANGUAGE plpgsql;
---------------------------------------- CONTRAT_AGENT_ARTISTE -------------------------------------------------

---------------------------------------- PAIEMENT_ARTISTE ------------------------------------------------------

---------------------------------------- ALBUMS ----------------------------------------------------------------

---------------------------------------- JOUE ------------------------------------------------------------------

---------------------------------------- MAITRISE ------------------------------------------------------------------