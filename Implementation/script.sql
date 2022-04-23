DROP TABLE IF EXISTS AGENT;
DROP TABLE IF EXISTS DEMANDE;
DROP TABLE IF EXISTS INSTRUMENT;
DROP TABLE IF EXISTS CONTRAT_AGENT_ARTISTE;
DROP TABLE IF EXISTS PAIEMENT_ARTISTE
DROP TABLE IF EXISTS ALBUMS
DROP TABLE IF EXISTS STYLE_MUSIQUE
DROP TABLE IF EXISTS CONTRAT_ARTISTE_PRODUCTEUR
DROP TABLE IF EXISTS MUSICIEN
DROP TABLE IF EXISTS PRODUCTEUR
DROP TABLE IF EXISTS PRODUCTEUR
DROP TABLE IF EXISTS MAITRISE




CREATE TABLE IF NOT EXISTS AGENT
(
    agent_id INTEGER PRIMARY KEY NOT NULL,
    agent_nom VARCHAR NOT NULL,
    agent_prenom VARCHAR NOT NULL,
    agent_telephone VARCHAR NOT NULL,
    agent_mail VARCHAR NOT NULL,
    agent_date_embauche VARCHAR NOT NULL,
    PRIMARY KEY (agent_id)
   
);



CREATE TABLE IF NOT EXISTS DEMANDE
(
    demande_id INTEGER PRIMARY KEY NOT NULL,
    demande_nom VARCHAR NOT NULL,
    demande_date_debut DATE NOT NULL,
    demande_date_fin DATE NOT NULL,
    instrument_id integer REFERENCES INSTRUMENT,
    style_musique_id integer REFERENCES STYLE_MUSIQUE,
    PRIMARY KEY (demande_id)
    
);




CREATE TABLE IF NOT EXISTS INSTRUMENT
(
    instrument_id INTEGER NOT NULL,
    instrument_nom VARCHAR NOT NULL,
    PRIMARY KEY (instrument_id)
)



CREATE TABLE IF NOT EXISTS CONTRAT_AGENT_ARTISTE
(
    contrat_id INTEGER NOT NULL,
    contrat_debut DATE NOT NULL,
    contrat_fin DATE NOT NULL,
    contrat_pourcentage_agence INTEGER NOT NULL,
    musicien_id INTEGER REFERENCES MUSICIEN
    agent_id INTEGER REFERENCES AGENT
    PRIMARY KEY (contrat_id)
);


CREATE TABLE IF NOT EXISTS PAIEMENT_ARTISTE
(
    paiements_id INTEGER NOT NULL,
    contrat_id INTEGER REFERENCES CONTRAT_ARTISTE_PRODUCTEUR
    paiements_date DATE NOT NULL,
    paiement_montant_brut INTEGER NOT NULL,
    paiement_honoraire_agence INTEGER NOT NULL,
    PRIMARY KEY (paiements_id,contrat_id)
);



CREATE TABLE IF NOT EXISTS ALBUMS
(
    album_id INTEGER NOT NULL,
    album_nom VARCHAR NOT NULL,
    album_date_debut DATE NOT NULL,
    album_date_fin DATE NOT NULL,
    PRIMARY KEY (album_nom)
);


CREATE TABLE IF NOT EXISTS STYLE_MUSIQUE
(
    style_id INTEGER NOT NULL,
    style_nom VARCHAR NOT NULL,
    PRIMARY KEY (style_id)
);


CREATE TABLE IF NOT EXISTS CONTRAT_ARTISTE_PRODUCTEUR
(
    contrat_id INTEGER NOT NULL,
    contrat_date_debut DATE NOT NULL,
    contrat_date_fin DATE NOT NULL,
    contrat_renumeration INTEGER NOT NULL,
    contrat_pourcentage_benefice INTEGER NOT NULL,
    musicien_id INTEGER NOT NULL REFERENCES MUSICIEN,
    producteur_id INTEGER NOT NULL REFERENCES PRODUCTEUR,
    PRIMARY key(contrat_id)
);



CREATE TABLE IF NOT EXISTS MUSICIEN
(
    musicien_id INTEGER NOT NULL,
    personne_nom VARCHAR NOT NULL,
    personne_prenom VARCHAR NOT NULL,
    personne_date_naissance DATE NOT NULL,
    personne_telephone VARCHAR NOT NULL,
    personne_adresse VARCHAR NOT NULL,
    personne_mail VARCHAR NOT NULL,
    PRIMARY KEY (personne_id)
);

CREATE TABLE IF NOT EXISTS PRODUCTEUR
(
    producteur_id INTEGER NOT NULL,
    personne_nom VARCHAR NOT NULL,
    personne_prenom VARCHAR NOT NULL,
    personne_date_naissance DATE NOT NULL,
    personne_telephone VARCHAR NOT NULL,
    personne_adresse VARCHAR NOT NULL,
    personne_mail VARCHAR NOT NULL,
    PRIMARY KEY (personne_id)
);



CREATE TABLE IF NOT EXISTS JOUE
(
    instrument_id INTEGER REFERENCES INSTRUMENT,
    musicien_id INTEGER REFERENCES MUSICIEN,
    PRIMARY KEY (instrument_id,musicien_id)
    
);



CREATE TABLE IF NOT EXISTS MAITRISE
(
    
    style_id INTEGER REFERENCES STYLE_MUSIQUE,
    musicien_id INTEGER REFERENCES MUSICIEN,
    PRIMARY KEY (style_id,musicien_id)
    
);










