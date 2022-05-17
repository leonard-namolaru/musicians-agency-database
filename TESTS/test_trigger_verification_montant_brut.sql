/* Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/TESTS/test_trigger_verification_montant_brut.sql'
 */
 
  \echo ' '
 \echo '------------ TEST POUR LE TRIGGER : verification_montant_brut ------------'
 \echo 'Avant d ajouter ou de mettre a jour un paiement : la fonction verifie que le montant des paiements pour le contrat jusqu a present avec le nouveau paiement ne depasse pas le montant spécifié dans le contrat'
 \echo ' '
 
 \echo 'SELECT * FROM contrat_artiste_producteur WHERE contrat_id = 1;'
 SELECT * FROM contrat_artiste_producteur WHERE contrat_id = 1;
 
 \echo 'chaque paiement de la table paiement_artiste est est attaché a un contrat artiste-producteur'
 \echo 'Supposons que nous voulions transferer une paiement au musicien'
 \echo ' '
 
 \echo ' INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence) VALUES (3, 1, CURRENT_DATE, 100000, 30000);'
 
 INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence)
 VALUES (3, 1, CURRENT_DATE, 100000, 30000);
 
 \echo 'Resultat : message d erreur ! '
 
 \echo ' '
 \echo 'Donc : '
 \echo ' INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence) VALUES (3, 1, CURRENT_DATE, 500, 150);'
INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence)
VALUES (3, 1, CURRENT_DATE, 500, 150);

\echo ' '
\echo 'Le total des paiements pour ce contrat ne depasse pas le montant specifie dans le contrat.'

DELETE FROM paiement_artiste WHERE paiements_id = 3 AND contrat_id = 1;