![readme-header.png](readme-header.png)
[Français](#français-implémentation-dune-bd-graphe-dans-neo4j---données-historiques-de-la-blockchain-bitcoin) • [English](#english-neo4j-graph-database---bitcoin-blockchain-historical-data)  • [עברית](#עברית-neo4j--שימוש-במסד-נתונים-גרפי-עבור-הצגת-נתונים-היסטוריים-של-הבלוקציין-ביטקוין)

### [Français] Base de données pour une agence représentant des musiciens
> :school: **Lieu de formation :** Université Paris Cité, Campus Grands Moulins (ex-Paris Diderot)
> 
> :books: **UE :** Bases de données avancées 
> 
> :pushpin: **Année scolaire :** M1
> 
> :calendar: **Dates :** Avr. 2022 - mai 2022 
> 
> :chart_with_upwards_trend: **Note :** 18/20

#### Description
L’objectif du projet est la modélisation, le peuplement, et la mise en place d’une base de données d’une agence artistique. Dans ce contexte nous avons décidé d'axer notre projet sur la création d'une base de données pour une agence représentant des musiciens.

#### Principales fonctionnalités

- Création d’indexes qui permettent d’optimiser les requêtes les plus fréquentes.
- Fonctions PL/pgSQL pour les opérations courantes + tests qui permettent d’illustrer l’action de ses fonctions.
- Triggers + tests qui permettent d’illustrer les déclenchement de chaque trigger.

#### Les données
Pour générer des données sous forme de fichiers csv, nous avons utilisé l'outil 'Mockaroo' qui est un générateur de données.

- 1000 musiciens
- 1000 agents
- 1000 producteurs
- 6 instruments
- 6 styles de musique
- 50 demande
- 100 contrat agence artiste
- 30 albums

#### Instructions pour le démarrage
Afin de démarrer le projet, veuillez suivre les instructions ci-dessous :

1. Création d'une base de données
```
postgres=# CREATE DATABASE projet_bdd;
postgres=# \c projet_bdd;
```

2.L'importation du fichier create_all.sql peut être effectuée par la commande suivante :
```
projet_bdd=# \i 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_all.sql'
```

3. `\include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_triggers.sql'`
4. `\include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_functions.sql'`

5. Ouvrez le fichier `/CREATION/insert_data.sql` et modifiez les chemins des fichiers .csv en fonction de l'emplacement où ils se trouvent sur votre ordinateur. Pour éviter de recevoir des messages d'erreur de type `ERREUR:  n'a pas pu ouvrir le fichier ... pour une lecture : Permission denied`,
il est recommandé de placer les fichiers sous le dossier `C:\Users\Public` (si vous utilisez Windows) ou sous '~/' (si vous utilisez Mac ou Linux) [1].

6. Les données peuvent maintenant être importées :
```
projet_bdd=# \i 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/insert_data.sql'
```

Si vous recevez un message d'erreur de type `ERREUR: valeur du champ date/time en dehors des limites ...Peut-être avez-vous besoin d'un paramétrage « datestyle » différent.`, une façon de résoudre ce problème est de taper la commande suivante (pour le format : dd/mm/yyyy) [2] :
```
projet_bdd=# SET DATESTYLE = US; 
```

 _[1] Permission Denied error when using PostgreSQL's COPY FROM/TO command : https://www.neilwithdata.com/copy-permission-denied_

_[2] PostgreSQL Documentation_
    _https://www.postgresql.org/docs/9.1/datatype-datetime.html#DATATYPE-DATETIME-OUTPUT2-TABLE_
    _https://www.postgresql.org/docs/7.2/sql-set.html_

### [English] Database for an Agency Representing Musicians

### [עברית] מסד נתונים של סוכנות המייצגת מוזיקאים

