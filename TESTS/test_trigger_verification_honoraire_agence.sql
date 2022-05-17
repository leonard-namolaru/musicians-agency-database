/* Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/TESTS/test_trigger_verification_honoraire_agence.sql'
 */
 
 \echo ' '
 \echo '------------ TEST POUR LE TRIGGER : verification_honoraire_agence ------------'
 \echo 'Verification si la valeur du champ paiement_honoraire_agence de la table paiement_artiste est correcte selon la table contrat_agent_artiste (la valeur du champ contrat_pourcentage_agence).'
 \echo ' '
 
 \echo 'SELECT * FROM contrat_artiste_producteur WHERE contrat_id = 1;'
 SELECT * FROM contrat_artiste_producteur WHERE contrat_id = 1;
 
 \echo 'chaque paiement de la table paiement_artiste est est attaché a un contrat artiste-producteur'
 \echo 'Supposons que nous voulions transferer une partie du paiement du au musicien pour ce contrat :'
 \echo ' '
 
 \echo ' INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence) VALUES (3, 1, CURRENT_DATE, 500, 100);'
 
 INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence)
 VALUES (3, 1, CURRENT_DATE, 500, 100);
 
 \echo 'Resultat : message d erreur ! Nous ne pouvons pas decider au hasard quel montant sera transfere a l agence. Apres tout, il y a un contrat entre l agence et un musicien.'
 \echo 'Il existe un autre declencheur qui garantit que lors de l ajout d un nouveau contrat entre un musicien et un producteur, il existe un contrat actif entre le musicien et l agence. Ce contrat definit le pourcentage de chaque paiement qui sera transfere a l agence.'
 \echo 'Un test pour ce declencheur se trouve dans un fichier separe. Un autre point a noter est que un 3eme trigger assure qu il n y a pas plus d un contrat actif a la fois entre le musicien et l agence'
 \echo ' '
 
 \echo 'Nous allons maintenant examiner quel pourcentage doit etre transfere a l agence dans le cadre du contrat actif entre le musicien et l agence'
 \echo 'SELECT * FROM contrat_agent_artiste  WHERE musicien_id = 84'
 \echo 'AND ( (contrat_debut <= CURRENT_DATE AND contrat_fin = NULL) OR (contrat_debut <= CURRENT_DATE AND contrat_fin >= CURRENT_DATE) );'
SELECT * FROM contrat_agent_artiste  WHERE musicien_id = 84 
AND ( (contrat_debut <= CURRENT_DATE AND contrat_fin = NULL) OR (contrat_debut <= CURRENT_DATE AND contrat_fin >= CURRENT_DATE) );
 
 \echo ' '
 \echo 'Donc : '
 \echo ' INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence) VALUES (3, 1, CURRENT_DATE, 500, 150);'
INSERT INTO paiement_artiste (paiements_id, contrat_id, paiements_date, paiement_montant_brut, paiement_honoraire_agence)
VALUES (3, 1, CURRENT_DATE, 500, 150);

\echo ' '
\echo 'Le message qui s affiche concerne un autre declencheur qui s assure que le total des paiements pour un contrat ne depasse pas le montant specifie dans le contrat. Un test pour ce declencheur apparait dans un autre fichier.'

DELETE FROM paiement_artiste WHERE paiements_id = 3 AND contrat_id = 1;