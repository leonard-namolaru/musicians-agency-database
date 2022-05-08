--- Table paiement_artiste
-- Verification si paiement_honoraire_agence est correcte selon la table contrat_agent_artiste (contrat_pourcentage_agence).

CREATE OR REPLACE FUNCTION verification_honoraire_agence() RETURNS trigger AS $$
	DECLARE
		pourcentage_agence integer;
		musicien integer;
	BEGIN
	    SELECT C.musicien_id INTO musicien
		FROM  contrat_artiste_producteur AS C
		WHERE C.contrat_id = NEW.contrat_id;
			    
		SELECT C.contrat_pourcentage_agence INTO pourcentage_agence
		FROM contrat_agent_artiste AS C
		WHERE C.musicien_id = musicien 
		AND ( (C.contrat_debut >= NEW.paiements_date AND C.contrat_fin = NULL) OR (C.contrat_debut >= NEW.paiements_date AND C.contrat_fin <= NEW.paiements_date) );
		
		-- Pour des triggers BEFORE de type FOR EACH ROW :
		-- si un trigger renvoie NULL, la mise à jour / insertion sur la ligne courante
		-- ainsi que tous les triggers suivants sur cette même ligne - sont annulés
		
		IF NOT FOUND THEN -- Si pas de contrat
			RETURN NULL; -- La mise a jour / insertion déclenchante ne sera pas exécutée
		ELSEIF  ((NEW.paiement_montant_brut * pourcentage_agence) / 100) != NEW.paiement_honoraire_agence
			THEN RETURN NULL; 
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verification_honoraire_update
BEFORE UPDATE ON paiement_artiste
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN ((OLD.paiement_montant_brut != NEW.paiement_montant_brut) OR (OLD.paiement_honoraire_agence != NEW.paiement_honoraire_agence))
EXECUTE PROCEDURE verification_honoraire_agence();

CREATE TRIGGER verification_honoraire_insert
BEFORE INSERT ON paiement_artiste -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_honoraire_agence();

--- Les tables musicien, agent, producteur
-- Les numéros de téléphone doivent être au format suivant : 263-958-0726
CREATE OR REPLACE FUNCTION verification_telephone() RETURNS trigger AS $$
	DECLARE
		-- les fonctions triggers ne peuvent pas avoir d'arguments déclarés
        -- À la place, on peut accéder aux arguments du trigger par TG_NARGS et TG_ARGV.
        -- TG_NARGS : le nombre d'arguments donnés à la fonction déclencheur dans l'instruction CREATE TRIGGER.
		-- TG_ARGV[] : les arguments de l'instruction CREATE TRIGGER.
		telephone VARCHAR := TG_ARGV[0];

		telephone_apres_trim text;
	BEGIN
		-- trim([leading | trailing | both] [characters] from string)
		telephone_apres_trim := trim(both from telephone);
				
		IF (telephone_apres_trim ~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$')
			THEN RETURN NEW;
		END IF;
		
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
EXECUTE PROCEDURE verification_telephone(musicien_telephone);

CREATE TRIGGER verification_musicien_telephone_insert
BEFORE INSERT ON musicien -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_telephone(musicien_telephone);

-- La table producteur

CREATE TRIGGER verification_producteur_telephone
BEFORE UPDATE ON producteur
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.producteur_telephone != NEW.producteur_telephone)
EXECUTE PROCEDURE verification_telephone(producteur_telephone);

CREATE TRIGGER verification_producteur_telephone_insert
BEFORE INSERT ON producteur -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_telephone(producteur_telephone);

-- La table agent

CREATE TRIGGER verification_agent_telephone
BEFORE UPDATE ON agent
FOR EACH ROW -- Avant la mise a jour de chaque ligne affectée
WHEN (OLD.agent_telephone != NEW.agent_telephone)
EXECUTE PROCEDURE verification_telephone(agent_telephone);

CREATE TRIGGER verification_agent_telephone_insert
BEFORE INSERT ON agent -- Avant linsertion
FOR EACH ROW 
EXECUTE PROCEDURE verification_telephone(agent_telephone);