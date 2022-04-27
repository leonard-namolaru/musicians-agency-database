**** Instructions pour le démarrage (le document est toujours en cours de rédaction) **** 

Afin de démarrer le projet, veuillez, s'il vous plaît, suivre les instructions ci-dessous :

1. Depuis votre bureau, cliquez sur "SQL Shell (psql)".

2. 
postgres=# CREATE DATABASE projet_bdd;
CREATE DATABASE
postgres=# \c projet_bdd;
Vous êtes maintenant connecté à la base de données « projet_bdd » en tant qu'utilisateur « YOUR_USER_NAME ».

3.
projet_bdd=# \i 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_all.sql'

4. Ouvrez le fichier /CREATION/insert_data.sql et modifiez les chemins des fichiers .csv en fonction de l'emplacement où ils se trouvent sur votre ordinateur.
Pour éviter de recevoir des messages d'erreur de type "ERREUR:  n'a pas pu ouvrir le fichier ... pour une lecture : Permission denied",
Il est recommandé de placer les fichiers sous le dossier 'C:\Users\Public' (si vous utilisez Windows) ou sous '/tmp' (si vous utilisez Mac ou Linux) [1].

5. 
projet_bdd=# \i 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/insert_data.sql'

6.
Si vous recevez un message d'erreur de type "ERREUR: valeur du champ date/time en dehors des limites ...Peut-être avez-vous besoin d'un paramétrage « datestyle » différent.",
une façon de résoudre ce problème est de taper la commande suivante [2] :
projet_bdd=# SET DATESTYLE = PostgreSQL; 






[1] Permission Denied error when using PostgreSQL's COPY FROM/TO command : https://www.neilwithdata.com/copy-permission-denied
[2] PostgreSQL Documentation
    https://www.postgresql.org/docs/9.1/datatype-datetime.html#DATATYPE-DATETIME-OUTPUT2-TABLE
    https://www.postgresql.org/docs/7.2/sql-set.html