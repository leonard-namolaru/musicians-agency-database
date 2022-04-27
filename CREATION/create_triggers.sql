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
BEFORE INSERT ON paiement_artiste
FOR EACH ROW -- Avant linsertion
EXECUTE PROCEDURE verification_honoraire_agence();