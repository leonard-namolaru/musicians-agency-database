------------------------------------------------------------------------------------------------------------------------- contrat_reste_a_payer(id_contrat integer) 
SELECT contrat_reste_a_payer(1); 

------------------------------------------------------------------------------------------------------------- trouver_musiciens_repondre_demande(id_demande integer)
SELECT * FROM demande WHERE demande_id = 44;
/*
 demande_id | demande_nom | demande_date_debut | demande_date_fin | instrument_id | style_musique_id
------------+-------------+--------------------+------------------+---------------+------------------
         44 | eu orci     | 2021-12-28         | 2024-02-14       |             3 |                4
*/

SELECT * FROM style_musique WHERE style_id = 4;
/*
 style_id | style_nom
----------+-----------
        4 | rap
*/

-- SELECT * FROM instrument WHERE instrument_id = 3;

SELECT trouver_musiciens_repondre_demande(44); -- (28 lignes)
/*
                                    trouver_musiciens_repondre_demande
----------------------------------------------------------------------------------------------------------
 (2,Jeri,Powter,1986-09-15,348-820-0937,"4913 Stone Corner Way",jpowter1@yale.edu)
 (51,Rosalynd,Kingsford,1999-05-08,840-253-2453,"2638 Lake View Court",rkingsford1e@marketwatch.com)
 (146,Berkeley,Josofovitz,2001-03-23,395-956-2676,"8973 Manufacturers Pass",bjosofovitz41@cam.ac.uk)
 (165,Arron,Benoey,1975-12-24,843-867-0231,"6190 Haas Trail",abenoey4k@seesaa.net)
 (192,Ruben,Gonthard,1989-11-12,947-362-3581,"9 Center Terrace",rgonthard5b@wisc.edu)
 (227,Corrina,Mellish,1990-01-30,795-686-6086,"283 Cascade Avenue",cmellish6a@soup.io)
 (272,Terry,Hanselman,1952-09-26,490-205-9977,"52728 Pennsylvania Point",thanselman7j@booking.com)
 (274,Charmane,Lillegard,1960-07-04,193-370-2846,"13568 Transport Point",clillegard7l@businessweek.com)
 (352,Maure,Trenouth,1955-06-22,353-341-8921,"8979 Hayes Junction",mtrenouth9r@google.pl)
 (378,Bari,Vigneron,1992-08-08,292-994-3010,"01194 Leroy Plaza",bvigneronah@intel.com)
 (379,Lennard,Showering,1982-01-22,251-635-7856,"33 Fulton Drive",lshoweringai@slate.com)
 (427,Jordana,Fontell,1995-09-30,998-796-1663,"13 Graedel Drive",jfontellbu@twitter.com)
 (436,Stefania,Varlow,1973-01-07,995-196-7201,"88 Orin Parkway",svarlowc3@cbslocal.com)
 (501,Jaine,Hastewell,1981-01-04,839-391-5244,"5 Victoria Street",jhastewelldw@bigcartel.com)
 (518,Tony,Havill,1997-01-27,550-596-3507,"8846 Blackbird Way",thavilled@cbslocal.com)
 (522,Janene,Shipcott,1972-10-18,999-608-4223,"8722 Saint Paul Crossing",jshipcotteh@merriam-webster.com)
 (535,Darryl,Sancho,1953-07-20,674-499-5523,"29553 Northland Way",dsanchoeu@wunderground.com)
 (539,Merrielle,Burdess,1973-10-13,430-977-5600,"7 Glacier Hill Parkway",mburdessey@studiopress.com)
 (572,Gladi,Snape,1972-07-30,615-450-3799,"13 Nova Point",gsnapefv@last.fm)
 (589,Bartolomeo,Deely,1991-04-14,422-433-7622,"572 Meadow Vale Point",bdeelygc@skyrock.com)
 (597,Valaree,Hockey,1996-11-19,445-122-2722,"225 Harper Lane",vhockeygk@cbc.ca)
 (612,Sorcha,Blomefield,1971-04-06,398-365-8262,"9882 Roxbury Way",sblomefieldgz@xrea.com)
 (622,Lloyd,Fairlem,1976-05-01,439-934-5943,"88885 Shoshone Street",lfairlemh9@freewebs.com)
 (672,Igor,Baugham,1955-07-01,577-564-9912,"14101 Montana Court",ibaughamin@ucsd.edu)
 (687,Cyrus,Garey,1953-10-01,518-751-8627,"99042 Sundown Pass",cgareyj2@amazonaws.com)
 (694,Georgianna,Pedgrift,1995-05-05,185-432-6446,"4059 Homewood Road",gpedgriftj9@cisco.com)
 (858,Brandie,Urvoy,1962-07-31,418-991-0073,"73035 Milwaukee Pass",burvoynt@nps.gov)
 (985,Tabb,Maddin,1996-07-08,313-378-3751,"17997 Surrey Junction",tmaddinrc@alexa.com)
(28 lignes)
*/


projet_bdd=# SELECT * FROM joue WHERE musicien_id = 2;
/*
 musicien_id | instrument_id
-------------+---------------
           2 |             3
(1 ligne)
*/

projet_bdd=# SELECT * FROM maitrise WHERE musicien_id = 2;
/*
 musicien_id | style_id
-------------+----------
           2 |        4
(1 ligne)
*/

---------------------------------------------------------------------------------------------------------- trouver_musiciens_repondre_demande(id_demande integer)
SELECT trouver_demandes_adaptees_musicien(2); 
/*
    trouver_demandes_adaptees_musicien
------------------------------------------
 (23,consequat,2021-06-19,2023-07-19,3,4)
 (44,"eu orci",2021-12-28,2024-02-14,3,4)

*/

-------------------------------------------------------------------------------------- exportation_contrats_en_vigueur(systeme_exploitation text) -- WINDOWS LINUX MAC.
SELECT exportation_contrats_en_vigueur('WINDOWS');