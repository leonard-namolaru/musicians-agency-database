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
			RAISE 'Insertion ou mise a jour impossible car (montant brut * pourcentage agence) != (honoraire agence) : % != % .', ((NEW.paiement_montant_brut * pourcentage_agence) / 100), NEW.paiement_honoraire_agence USING ERRCODE='20006';
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
		
		RAISE 'Insertion ou mise a jour impossible car (paiement montant brut + paiements anterieurs) > (renumeration total du contrat) : % >  % .', (NEW.paiement_montant_brut + paiements_anterieurs), paiements_anterieurs USING ERRCODE='20005';
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