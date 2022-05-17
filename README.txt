README.txt
----------------------------

1. Auteurs du projet
- Sofien HENCHIR : sofien.henchir.tn@gmail.com (Groupe de TP : vendredi) , Numéro étudiant : 22107241
- Leonard NAMOLARU : leonard.namolaru@etu.u-paris.fr (Groupe de TP : mercredi) , Numéro étudiant : 51704115

2. Informations générales
L’objectif du projet est la modélisation, le peuplement, et la mise en place d’une base de données d’une agence artistique.
Conformément à la recommandation de M. Zielonka, lors de la pré-soutenance tenue en avril, nous avons décidé d'axer notre projet
sur la création d'une base de données pour une agence représentant des musiciens.

3. Les données
Pour générer des données sous forme de fichiers csv, nous avons utilisé l'outil 'Mockaroo' qui est un générateur de données.

Nous avons choisi d'insérer les données comme ci-dessous :
-1000 musiciens
-1000 agents
-1000 producteurs
-6 instruments
-6 styles de musique
-50 demande
-100 contrat agence artiste
-30 albums

4. Instructions pour le démarrage

Afin de démarrer le projet, veuillez, s'il vous plaît, suivre les instructions ci-dessous :

1. Depuis votre bureau, cliquez sur "SQL Shell (psql)".

2. Création d'une base de données
postgres=# CREATE DATABASE projet_bdd;
CREATE DATABASE
postgres=# \c projet_bdd;
Vous êtes maintenant connecté à la base de données « projet_bdd » en tant qu'utilisateur « YOUR_USER_NAME ».

3.L'importation du fichier create_all.sql peut être effectuée par la commande suivante :
projet_bdd=# \i 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_all.sql'

4. \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_triggers.sql'
5. \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_functions.sql'

6. Ouvrez, s'il vous plaît, le fichier /CREATION/insert_data.sql et modifiez les chemins des fichiers .csv en fonction de l'emplacement où ils se trouvent sur votre ordinateur.
Pour éviter de recevoir des messages d'erreur de type "ERREUR:  n'a pas pu ouvrir le fichier ... pour une lecture : Permission denied",
Il est recommandé de placer les fichiers sous le dossier 'C:\Users\Public' (si vous utilisez Windows) ou sous '/tmp' (si vous utilisez Mac ou Linux) [1].

7. Les données peuvent maintenant être importées :
projet_bdd=# \i 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/insert_data.sql'

Si vous recevez un message d'erreur de type "ERREUR: valeur du champ date/time en dehors des limites ...Peut-être avez-vous besoin d'un paramétrage « datestyle » différent.",
une façon de résoudre ce problème est de taper la commande suivante (pour le format : dd/mm/yyyy) [2] :
projet_bdd=# SET DATESTYLE = US; 


[1] Permission Denied error when using PostgreSQL's COPY FROM/TO command : https://www.neilwithdata.com/copy-permission-denied
[2] PostgreSQL Documentation
    https://www.postgresql.org/docs/9.1/datatype-datetime.html#DATATYPE-DATETIME-OUTPUT2-TABLE
    https://www.postgresql.org/docs/7.2/sql-set.html