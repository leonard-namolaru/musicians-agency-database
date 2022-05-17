/* Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/TESTS/test_trigger_verification_periodes_differentes.sql'
 */
 
 \echo ' '
 \echo '------------ TEST POUR LE TRIGGER : verification_periodes_differentes ------------'
 \echo 'Deux contrats concernant un meme artiste doivent couvrir des periodes differentes.'
 \echo ' '
 
 \echo ' INSERT INTO contrat_agent_artiste (contrat_id, contrat_debut, contrat_fin, contrat_pourcentage_agence, musicien_id, agent_id) VALUES (default, 2022-05-27, 2023-01-27, 10, 84, 89);'
 INSERT INTO contrat_agent_artiste (contrat_id, contrat_debut, contrat_fin, contrat_pourcentage_agence, musicien_id, agent_id)
 VALUES (101, '2022-05-27', '2023-01-27', 10, 84, 89);
 
 \echo 'Resultat : message d erreur ! '
 \echo 'La raison :'
 \echo ' '
 
\echo 'SELECT * FROM contrat_agent_artiste  WHERE musicien_id = 84'
\echo 'AND ( (contrat_debut <= 2022-05-27 AND contrat_fin = NULL) OR (contrat_debut <= 2022-05-27 AND contrat_fin >= 2023-01-27) );'
SELECT * FROM contrat_agent_artiste  WHERE musicien_id = 84
AND ( (contrat_debut <= '2022-05-27' AND contrat_fin = NULL) OR (contrat_debut <= '2022-05-27' AND contrat_fin >= '2023-01-27') );

\echo ' ' 

\echo 'Si la reprsentation actuelle est pour une dure indtermine sans date de fin : contrat_fin = NULL'

\echo ' ' 
\echo 'Par contre : '
 \echo ' INSERT INTO contrat_agent_artiste (contrat_id, contrat_debut, contrat_fin, contrat_pourcentage_agence, musicien_id, agent_id) VALUES (default, 2023-11-16, 2024-01-27, 10, 84, 89);'
 INSERT INTO contrat_agent_artiste (contrat_id, contrat_debut, contrat_fin, contrat_pourcentage_agence, musicien_id, agent_id)
 VALUES (101, '2023-11-16', '2024-01-27', 10, 84, 89);

DELETE FROM contrat_agent_artiste WHERE contrat_debut = '2023-11-16' AND contrat_fin = '2024-01-27' AND contrat_pourcentage_agence = 10 AND musicien_id = 84 AND agent_id = 89; 

  