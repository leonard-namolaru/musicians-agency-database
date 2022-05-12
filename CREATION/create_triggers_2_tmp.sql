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