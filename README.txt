README.txt
----------------------------

a. Auteurs du projet
- Sofien HENCHIR : sofien.henchir.tn@gmail.com (Groupe de TP : vendredi) , Numéro étudiant : 22107241
- Leonard NAMOLARU : leonard.namolaru@etu.u-paris.fr (Groupe de TP : mercredi) , Numéro étudiant : 51704115

b. Informations générales
L’objectif du projet est la modélisation, le peuplement, et la mise en place d’une base de données d’une agence artistique.
Conformément à la recommandation de M. Zielonka, lors de la pré-soutenance tenue en avril, nous avons décidé d'axer notre projet
sur la création d'une base de données pour une agence représentant des musiciens.

c. Les données
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

d. Instructions pour le démarrage

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


e. Les fonctions suivantes sont à votre disposition (fonctions PL/pgSQL pour les operations courantes de gestion) :

---------------------------------------- TABLE MUSICIEN ---------------------------------------------------------

----- musicien_existe(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text) -> INTEGER
Description : Une fonction qui reçoit comme paramètres nom, prenom, téléphone, etc. et vérifie si un tel musicien existe.

Parametres :
nom text : la nom du musicien.
prenom text : le prenom du musicien.
date_naissance date : la date de naissance du musicien
telephone text : le telephone de l'agent (format : '123-456-1234')
adresse text : l'adresse du musicien
mail text : l'adresse mail du musicien (format : 'X@Y.Z')
  
Valeur de retour : le numero d'id du musicien si il existe ou -1 en cas d’erreur (le musicien existe PAS).

-----  ajout_musicien(nom text, prenom text, date_naissance date, telephone text, adresse text, mail text, instruments INTEGER[], styles_musique INTEGER[]) -> BOOLEAN
Description : Une fonction qui reçoit comme paramètres : nom, prenom, téléphone, etc. et ajoute un nouveau musicien s'il n'existe pas deja.
               De plus, la fonction reçoit en paramètre 2 tableaux : 
                - un tableau des id des instruments de musique que le musicien maitrise
                - un tableau des id des styles de musique du musicien. 
              La fonction ajoute ces informations aux tables appropriées.
 
Parametres :
nom text : la nom du musicien.
prenom text : le prenom du musicien.
date_naissance date : la date de naissance du musicien
telephone text : le telephone de l'agent (format : '123-456-1234')
adresse text : l'adresse du musicien
mail text : l'adresse mail du musicien (format : 'X@Y.Z')
instruments INTEGER[] : un tableau des id des instruments de musique que le musicien maitrise (Par exemple : '{1,2}')
 styles_musique INTEGER[] : un tableau des id des styles de musique du musicien (Par exemple : '{1,2}')

Valeur de retour : true si le musicien est ajouté avec succès, false si le musicien existe déjà.

---------------------------------------- TABLE CONTRAT_ARTISTE_PRODUCTEUR --------------------------------------------
-----  contrat_reste_a_payer(id_contrat integer) ->  integer
Description : Trouver les demandes adaptées a un musicien. C'est-à-dire des demandes qui 
               n'ont pas encore expiré (qui n'ont pas encore atteint leur date de fin) et 
               qui incluent des instruments de musique et un style de musique qui conviennent au musicien.
 
Parametres :
id_contrat integer : ID du contrat artiste producteur.

Valeur de retour : La fonction retourne le reste a payer (somme de la renumeration total - paiements anterieurs)

---------------------------------------- TABLE DEMANDE ---------------------------------------------------------------
-----  trouver_musiciens_repondre_demande(id_demande integer, musiciens_exclure_resultats integer[]) -> BOOLEAN
Description : Trouver des musiciens pour répondre à une demande. C'est-à-dire que la fonction trouve la liste des musiciens 
 			  qui contrôlent l'instrument qui apparaît dans la demande et en même temps ce sont des musiciens dont le style 
               de musique est tel qu'il apparaît dans la demande.
 
Parametres :
id_demande integer : ID de la demande.

Valeur de retour : La fonction retourne un type “ensemble” (SETOF) de la table musicien 

-----  trouver_demandes_adaptees_musicien(id_musicien integer)  ->  SETOF demande
Description : Trouver les demandes adaptées a un musicien. C'est-à-dire des demandes qui 
              n'ont pas encore expiré (qui n'ont pas encore atteint leur date de fin) et 
              qui incluent des instruments de musique et un style de musique qui conviennent au musicien.
 
Parametres :
id_musicien integer : ID du musicien.

Valeur de retour : La fonction retourne un type “ensemble” (SETOF) de la table demande 

---------------------------------------- TABLE CONTRAT_AGENT_ARTISTE --------------------------------------------
----- exportation_contrats_en_vigueur(systeme_exploitation text) -> void
Description : Exportation de tous les contrats actuellement en vigueur. 
               La destination pour l'exportation sur Windows : C:\Users\Public\contrats_en_vigueur.csv 
 	          La destination pour l'exportation sur Linux ou Mac : /tmp/contrats_en_vigueur.csv

Parametres :
systeme_exploitation text : Cette fonction ne peut accepter que une les valeurs suivantes en tant que parametre : WINDOWS LINUX MAC.

Valeur de retour : void

-----
[1] Permission Denied error when using PostgreSQL's COPY FROM/TO command : https://www.neilwithdata.com/copy-permission-denied
[2] PostgreSQL Documentation
    https://www.postgresql.org/docs/9.1/datatype-datetime.html#DATATYPE-DATETIME-OUTPUT2-TABLE
    https://www.postgresql.org/docs/7.2/sql-set.html