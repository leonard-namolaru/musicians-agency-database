/* Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/TESTS/test_trigger_verification_contrat_avec_agent.sql'
 */
 
 \echo ' '
 \echo '------------ TEST POUR LE TRIGGER : verification_contrat_avec_agent ------------'
 \echo 'Un artiste ne peut signer un contrat avec un producteur sans avoir un contrat avec un agent.'
 \echo 'Lors de l ajout d un nouveau contrat entre un musicien et un producteur, doit exister un contrat actif entre le musicien et l agence. Ce contrat definit le pourcentage de chaque paiement qui sera transfere a l agence.'
 \echo 'Un autre point a noter est que un autre trigger assure qu il n y a pas plus d un contrat actif a la fois entre le musicien et l agence'
 \echo ' '
  
 \echo 'INSERT INTO contrat_artiste_producteur (contrat_id, contrat_date_debut, contrat_date_fin, contrat_renumeration, musicien_id, producteur_id)  VALUES (default, 2024-03-30, 2024-08-07, 1000, 84, 6);'
 INSERT INTO contrat_artiste_producteur (contrat_id, contrat_date_debut, contrat_date_fin, contrat_renumeration, musicien_id, producteur_id)
 VALUES (default, '2024-03-30', ' 2024-08-07', 1000, 84, 6);
 
 \echo 'Resultat : message d erreur ! N'
 \echo ' '
 
 \echo 'Par contre : '
 \echo 'INSERT INTO contrat_artiste_producteur (contrat_id, contrat_date_debut, contrat_date_fin, contrat_renumeration, musicien_id, producteur_id)  VALUES (default, 2023-01-10, 2023-02-10, 1000, 84, 6);'
 INSERT INTO contrat_artiste_producteur (contrat_id, contrat_date_debut, contrat_date_fin, contrat_renumeration, musicien_id, producteur_id)
 VALUES (default, '2023-01-10', '2023-02-10', 1000, 84, 6);

DELETE FROM contrat_artiste_producteur WHERE contrat_date_debut = '2023-01-10' AND contrat_date_fin = '2023-02-10' AND contrat_renumeration = 1000 AND musicien_id = 84 AND producteur_id = 6; 