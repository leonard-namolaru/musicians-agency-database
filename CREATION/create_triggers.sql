/* Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_triggers.sql'
 */

---------------------------------------- PAIEMENT_ARTISTE ------------------------------------------------------

DROP TRIGGER IF EXISTS verification_honoraire ON paiement_artiste;
DROP TRIGGER IF EXISTS verification_montant_brut ON paiement_artiste;

-- Verification si paiement_honoraire_agence est correcte selon la table contrat_agent_artiste (contrat_pourcentage_agence).
CREATE OR REPLACE FUNCTION verification_honoraire_agence() RETURNS trigger AS $$
	DECLARE
		pourcentage_agence integer;
		musicien integer;
		date_debut_contrat_artiste_producteur date;
		date_fin_contrat_artiste_producteur date;
	BEGIN
	    SELECT C.musicien_id INTO musicien
		FROM  contrat_artiste_producteur AS C
		WHERE C.contrat_id = NEW.contrat_id;
		
		SELECT C.contrat_date_debut INTO date_debut_contrat_artiste_producteur
		FROM  contrat_artiste_producteur AS C
		WHERE C.contrat_id = NEW.contrat_id;
		
		SELECT C.contrat_date_fin INTO date_fin_contrat_artiste_producteur
		FROM  contrat_artiste_producteur AS C
		WHERE C.contrat_id = NEW.contrat_id;
			    
		SELECT C.contrat_pourcentage_agence INTO pourcentage_agence
		FROM contrat_agent_artiste AS C
		WHERE C.musicien_id = musicien 
		AND ( (C.contrat_debut <= date_debut_contrat_artiste_producteur AND C.contrat_fin = NULL) OR (C.contrat_debut <= date_debut_contrat_artiste_producteur AND C.contrat_fin >= date_fin_contrat_artiste_producteur) );
		
		-- Pour des triggers BEFORE de type FOR EACH ROW :
		-- si un trigger renvoie NULL, la mise à jour / insertion sur la ligne courante
		-- ainsi que tous les triggers suivants sur cette même ligne - sont annulés
		
		IF NOT FOUND THEN -- Si pas de contrat
			RAISE 'Insertion ou mise a jour impossible car pas de contrat agent-artiste en cours .' USING ERRCODE='20006';
			RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
		ELSEIF  ((NEW.paiement_montant_brut * pourcentage_agence) / 100) != NEW.paiement_honoraire_agence THEN
			RAISE 'Insertion ou mise a jour impossible car (montant brut * pourcentage agence) != (honoraire agence) : % != % .', ((NEW.paiement_montant_brut * pourcentage_agence) / 100), NEW.paiement_honoraire_agence USING ERRCODE='20007';
			RETURN NULL; 
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

-- Avant d'ajouter ou de mettre à jour un paiement : 
-- La fonction vérifie que le montant des paiements pour le contrat jusqu'à présent avec le nouveau paiement 
-- ne dépasse pas le montant spécifié dans le contrat.
CREATE OR REPLACE FUNCTION verification_montant_brut() RETURNS trigger AS $$
	DECLARE
		paiements_anterieurs integer; -- Montant des paiements antérieurs
		contrat_renumeration_total integer;
	BEGIN
	    SELECT C.contrat_renumeration INTO contrat_renumeration_total
		FROM  contrat_artiste_producteur AS C
		WHERE C.contrat_id = NEW.contrat_id;
			    
		SELECT SUM(C.paiement_montant_brut) INTO paiements_anterieurs
		FROM paiement_artiste AS C
		WHERE C.contrat_id = NEW.contrat_id
		GROUP BY C.contrat_id;
		
		IF NOT FOUND THEN -- Si pas de paiements anterieurs
			paiements_anterieurs := 0;
		END IF;
		
		IF ((NEW.paiement_montant_brut + paiements_anterieurs) <= contrat_renumeration_total) THEN
			RAISE NOTICE 'Insertion ou mise a jour ok car (paiement montant brut + paiements anterieurs) <= (renumeration total du contrat) : % <=  % .', (NEW.paiement_montant_brut + paiements_anterieurs), contrat_renumeration_total;
			RETURN NEW;
		END IF;
		
		RAISE 'Insertion ou mise a jour impossible car (paiement montant brut + paiements anterieurs) > (renumeration total du contrat) : % >  % .', (NEW.paiement_montant_brut + paiements_anterieurs), contrat_renumeration_total USING ERRCODE='20005';
		RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
	END;
$$ LANGUAGE plpgsql;

-- Avant linsertion / mise a jour de chaque ligne affectée
CREATE TRIGGER verification_honoraire
BEFORE INSERT OR UPDATE ON paiement_artiste
FOR EACH ROW 
EXECUTE PROCEDURE verification_honoraire_agence();

-- Avant linsertion / mise a jour de chaque ligne affectée
CREATE TRIGGER verification_montant_brut
BEFORE INSERT OR UPDATE ON paiement_artiste 
FOR EACH ROW 
EXECUTE PROCEDURE verification_montant_brut();


---------------------------------------- CONTRAT_ARTISTE_PRODUCTEUR --------------------------------------------
DROP TRIGGER IF EXISTS verification_contrat_avec_agent ON contrat_artiste_producteur;

-- Un artiste ne peut signer un contrat avec un producteur sans avoir un contrat avec un agent
CREATE OR REPLACE FUNCTION verification_contrat_avec_agent() RETURNS trigger AS $$
	DECLARE
		contrat integer;
	BEGIN
				    
		SELECT C.contrat_id INTO contrat
		FROM contrat_agent_artiste AS C
		WHERE C.musicien_id = NEW.musicien_id 
		AND ( (C.contrat_debut <= NEW.contrat_date_debut AND C.contrat_fin = NULL) OR (C.contrat_debut <= NEW.contrat_date_debut AND C.contrat_fin >= NEW.contrat_date_fin) );
		
		-- Pour des triggers BEFORE de type FOR EACH ROW :
		-- si un trigger renvoie NULL, la mise à jour / insertion sur la ligne courante
		-- ainsi que tous les triggers suivants sur cette même ligne - sont annulés
		
		IF NOT FOUND THEN -- Si pas de contrat
			RAISE 'Insertion ou mise a jour impossible car pas de contrat agent-artiste en cours pour la periode du contrat artiste - producteur.' USING ERRCODE='20007';
			RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
		END IF;
		
		RAISE NOTICE 'Insertion ou mise a jour ok car il y a un contrat agent-artiste en cours pour la periode du contrat artiste-producteur. ID de ce contrat : % ', contrat;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

-- Avant linsertion / mise a jour de chaque ligne affectée
CREATE TRIGGER verification_contrat_avec_agent
BEFORE INSERT OR UPDATE ON contrat_artiste_producteur 
FOR EACH ROW 
EXECUTE PROCEDURE verification_contrat_avec_agent();

---------------------------------------- CONTRAT_AGENT_ARTISTE -------------------------------------------------
DROP TRIGGER IF EXISTS verification_periodes_differentes ON contrat_agent_artiste;

-- Deux contrats concernant un même artiste doivent couvrir des périodes différentes.
CREATE OR REPLACE FUNCTION verification_periodes_differentes() RETURNS trigger AS $$
	DECLARE
		contrat integer;
	BEGIN
				    
		SELECT C.contrat_id INTO contrat
		FROM contrat_agent_artiste AS C
		WHERE C.musicien_id = NEW.musicien_id 
		AND ( (C.contrat_debut <= NEW.contrat_debut AND C.contrat_fin = NULL) OR (C.contrat_debut <= NEW.contrat_debut AND C.contrat_fin >= NEW.contrat_fin) );
		
		-- Pour des triggers BEFORE de type FOR EACH ROW :
		-- si un trigger renvoie NULL, la mise à jour / insertion sur la ligne courante
		-- ainsi que tous les triggers suivants sur cette même ligne - sont annulés
		
		IF NOT FOUND THEN -- Si pas de contrat
			RAISE NOTICE 'Insertion ou mise a jour du contrat agent-artiste ok';
			RETURN NEW;
		END IF;
					
		RAISE 'Insertion ou mise a jour impossible car deux contrats concernant un même artiste doivent couvrir des périodes différentes.' USING ERRCODE='20008';
		RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
	END;
$$ LANGUAGE plpgsql;

-- Avant linsertion / mise a jour de chaque ligne affectée
CREATE TRIGGER verification_periodes_differentes
BEFORE INSERT OR UPDATE ON contrat_agent_artiste 
FOR EACH ROW 
EXECUTE PROCEDURE verification_periodes_differentes();

---------------------------------------- LES TABLES MUSICIEN, AGENT, PRODUCTEUR ----------------------------------
-- Table musicien
DROP TRIGGER IF EXISTS verification_musicien_telephone ON musicien;
DROP TRIGGER IF EXISTS verification_musicien_telephone_insert ON musicien;
DROP TRIGGER IF EXISTS verification_musicien_mail ON musicien;
DROP TRIGGER IF EXISTS verification_musicien_mail_insert ON musicien;

-- Table agent
DROP TRIGGER IF EXISTS verification_agent_telephone ON agent;
DROP TRIGGER IF EXISTS verification_agent_telephone_insert ON agent;
DROP TRIGGER IF EXISTS verification_agent_mail ON agent;
DROP TRIGGER IF EXISTS verification_agent_mail_insert ON agent;

-- Table producteur
DROP TRIGGER IF EXISTS verification_producteur_telephone ON producteur;
DROP TRIGGER IF EXISTS verification_producteur_telephone_insert ON producteur;
DROP TRIGGER IF EXISTS verification_producteur_mail ON producteur;
DROP TRIGGER IF EXISTS verification_producteur_mail_insert ON producteur;

--- Les tables musicien, agent, producteur
-- Les numéros de téléphone doivent être au format suivant : 263-958-0726
CREATE OR REPLACE FUNCTION verification_telephone() RETURNS trigger AS $$
	DECLARE
		-- les fonctions triggers ne peuvent pas avoir d'arguments déclarés
        -- À la place, on peut accéder aux arguments du trigger par TG_NARGS et TG_ARGV.
        -- TG_NARGS : le nombre d'arguments donnés à la fonction déclencheur dans l'instruction CREATE TRIGGER.
		-- TG_ARGV[] : les arguments de l'instruction CREATE TRIGGER.
		nom_table text := TG_ARGV[0]; -- Premier index de TG_ARGV[] : 0
		
		telephone VARCHAR;
		telephone_apres_trim text;
	BEGIN
		CASE 
			WHEN nom_table = 'musicien' THEN
				telephone := NEW.musicien_telephone;
			WHEN nom_table = 'producteur' THEN
				telephone := NEW.producteur_telephone;
			WHEN nom_table = 'agent' THEN
				telephone := NEW.agent_telephone;
		END CASE;
	
		-- trim ( [ LEADING | TRAILING | BOTH ] [ characters text ] FROM string text ) -> text
		telephone_apres_trim := trim(both from telephone);
				
		IF (telephone_apres_trim ~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$') THEN
			RAISE NOTICE 'Le numero % a ete verifie.', telephone;
			RETURN NEW;
		END IF;
		
		RAISE 'Insertion ou mise a jour impossible car le numero % est PAS correcte.', telephone USING ERRCODE='20003';
		RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
	END;
$$ LANGUAGE plpgsql;

-- La table musicien

/*  Par exemple:
 *  projet_bdd=# UPDATE musicien SET musicien_telephone = '372-106-3084' WHERE musicien_id  = 1;
 *  UPDATE 1
 *  projet_bdd=# UPDATE musicien SET musicien_telephone = '372-1063084' WHERE musicien_id  = 1;
 *  UPDATE 0
 */
CREATE TRIGGER verification_musicien_telephone
BEFORE UPDATE ON musicien
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.musicien_telephone != NEW.musicien_telephone)
EXECUTE PROCEDURE verification_telephone('musicien');

CREATE TRIGGER verification_musicien_telephone_insert
BEFORE INSERT ON musicien -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_telephone('musicien');

-- La table producteur

CREATE TRIGGER verification_producteur_telephone
BEFORE UPDATE ON producteur
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.producteur_telephone != NEW.producteur_telephone)
EXECUTE PROCEDURE verification_telephone('producteur');

CREATE TRIGGER verification_producteur_telephone_insert
BEFORE INSERT ON producteur -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_telephone('producteur');

-- La table agent

CREATE TRIGGER verification_agent_telephone
BEFORE UPDATE ON agent
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.agent_telephone != NEW.agent_telephone)
EXECUTE PROCEDURE verification_telephone('agent');

CREATE TRIGGER verification_agent_telephone_insert
BEFORE INSERT ON agent -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_telephone('agent');


--- Les tables musicien, agent, producteur
-- Les adresses email doivent être au format suivant : X@Y.Z
CREATE OR REPLACE FUNCTION verification_email() RETURNS trigger AS $$
	DECLARE
		email VARCHAR;
		email_len integer;
		tab_email text[];
		
		-- Index de la boucle
		i integer := 1;
		
	   arobase_existe BOOLEAN := false;
	   point_existe BOOLEAN := true; 
	BEGIN
	   -- TG_TABLE_NAME : le nom de la table qui a déclenché le trigger.
	   CASE 
			WHEN TG_TABLE_NAME = 'musicien' THEN
				email := NEW.musicien_mail;
			WHEN TG_TABLE_NAME = 'producteur' THEN
				email := NEW.producteur_mail;
			WHEN TG_TABLE_NAME = 'agent' THEN
				email := NEW.agent_mail;
		END CASE;	
		
	   -- string_to_array ( string text, delimiter text [, null_string text ] ) -> text[]
	   -- Si le délimiteur (delimiter) est NULL, chaque caractère de la chaîne deviendra un élément distinct dans le tableau.
	   tab_email := string_to_array(email, NULL);
	   
	   	-- char_length ( text ) -> integer
		email_len := char_length(email);
				
		WHILE (i <= email_len)
		LOOP
			IF (tab_email[i] = '@') THEN
				arobase_existe := true;
			END IF;
			
			IF ((arobase_existe = true) AND (tab_email[i] = '.')) THEN
				point_existe := true;
			END IF;
			
			i := (i + 1);
		END LOOP;
		
		IF arobase_existe AND point_existe THEN
			RAISE NOTICE 'L adresse e-mail % a ete verifiee et s est averee valide.', email;
			RETURN NEW;
		END IF;
		
		RAISE 'Insertion ou mise a jour impossible car l adresse % est PAS une adresse mail correcte.', email USING ERRCODE='20004';
		RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
	END;
$$ LANGUAGE plpgsql;

-- La table musicien

CREATE TRIGGER verification_musicien_mail
BEFORE UPDATE ON musicien
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.musicien_mail != NEW.musicien_mail)
EXECUTE PROCEDURE verification_email();

CREATE TRIGGER verification_musicien_mail_insert
BEFORE INSERT ON musicien -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_email();

-- La table producteur

CREATE TRIGGER verification_producteur_mail
BEFORE UPDATE ON producteur
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.producteur_mail != NEW.producteur_mail)
EXECUTE PROCEDURE verification_email();

CREATE TRIGGER verification_producteur_mail_insert
BEFORE INSERT ON producteur -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_email();

-- La table agent

CREATE TRIGGER verification_agent_mail
BEFORE UPDATE ON agent
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.agent_mail != NEW.agent_mail)
EXECUTE PROCEDURE verification_email();

CREATE TRIGGER verification_agent_mail_insert
BEFORE INSERT ON agent -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_email();
