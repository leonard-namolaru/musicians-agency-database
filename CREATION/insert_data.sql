-- Do not forget to change the path of the csv files when you have them on your proper drive 
-- Do not change the csv files name as they match the tables thus the below commands
-- Execute the commands the exact same order 

COPY musicien FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table musicien.csv' CSV HEADER; --1000 rows
COPY agent FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table agent.csv' CSV HEADER; --1000 rows
COPY producteur FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table producteur.csv' CSV HEADER; --1000 rows
COPY instrument FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table instrument.csv' CSV HEADER; --6 rows
COPY style_musique FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table style_musique.csv' CSV HEADER; --6 rows
COPY contrat_artiste_producteur FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table contrat_artiste_producteur.csv' CSV HEADER; --100 rows
COPY demande FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table demande.csv' CSV HEADER; --50 rows
COPY contrat_agent_artiste FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table contrat_agent_artiste.csv' CSV HEADER;--100 rows
COPY paiement_artiste FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table paiement_artiste.csv' CSV HEADER;--100 rows ( matching the contrats)
COPY albums FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table album.csv' CSV HEADER; --30
COPY joue FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table joue.csv' CSV HEADER;--1000 rows (matching the musicians)
COPY maitrise FROM '/Users/henchir/Desktop/Master 1 LP/Semestre 2/Bdd Avancé/Projet /script sql /sources csv/table maitrise.csv' CSV HEADER; --1000 rows (matching the musicians)
