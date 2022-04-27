DROP TABLE IF EXISTS AGENT;
DROP TABLE IF EXISTS DEMANDE;
DROP TABLE IF EXISTS INSTRUMENT;
DROP TABLE IF EXISTS CONTRAT_AGENT_ARTISTE;
DROP TABLE IF EXISTS PAIEMENT_ARTISTE;
DROP TABLE IF EXISTS ALBUMS;
DROP TABLE IF EXISTS STYLE_MUSIQUE;
DROP TABLE IF EXISTS CONTRAT_ARTISTE_PRODUCTEUR;
DROP TABLE IF EXISTS MUSICIEN;
DROP TABLE IF EXISTS PRODUCTEUR;
DROP TABLE IF EXISTS MAITRISE;

CREATE TABLE IF NOT EXISTS MUSICIEN (
    musicien_id SERIAL , -- SERIAL = autoincrementing integer
    musicien_nom VARCHAR NOT NULL,
    musicien_prenom VARCHAR NOT NULL,
    musicien_date_naissance DATE NOT NULL,
    musicien_telephone VARCHAR NOT NULL,
    musicien_adresse VARCHAR NOT NULL,
    musicien_mail VARCHAR NOT NULL,
    
    PRIMARY KEY (musicien_id),
    UNIQUE (musicien_nom, musicien_prenom, musicien_date_naissance, musicien_telephone, musicien_adresse, musicien_mail)
);


CREATE TABLE IF NOT EXISTS AGENT (
    agent_id SERIAL , -- SERIAL = autoincrementing integer
    agent_nom VARCHAR NOT NULL,
    agent_prenom VARCHAR NOT NULL,
    agent_telephone VARCHAR NOT NULL,
    agent_mail VARCHAR NOT NULL,
    agent_date_embauche VARCHAR NOT NULL,
    
    PRIMARY KEY (agent_id),
    UNIQUE (agent_nom, agent_prenom, agent_telephone, agent_mail, agent_date_embauche)
   
);

CREATE TABLE IF NOT EXISTS PRODUCTEUR (
    producteur_id SERIAL , -- SERIAL = autoincrementing integer
    producteur_nom VARCHAR NOT NULL,
    producteur_prenom VARCHAR NOT NULL,
    producteur_date_naissance DATE NOT NULL,
    producteur_telephone VARCHAR NOT NULL,
    producteur_adresse VARCHAR NOT NULL,
    producteur_mail VARCHAR NOT NULL,
    
    PRIMARY KEY (producteur_id),
    UNIQUE (producteur_nom, producteur_prenom, producteur_date_naissance, producteur_telephone, producteur_adresse, producteur_mail)
);

CREATE TABLE IF NOT EXISTS INSTRUMENT (
    instrument_id SERIAL , -- SERIAL = autoincrementing integer
    instrument_nom VARCHAR NOT NULL,
    
    PRIMARY KEY (instrument_id)
);

CREATE TABLE IF NOT EXISTS STYLE_MUSIQUE(
    style_id SERIAL , -- SERIAL = autoincrementing integer
    style_nom VARCHAR NOT NULL,
    
    PRIMARY KEY (style_id)
);

CREATE TABLE IF NOT EXISTS CONTRAT_ARTISTE_PRODUCTEUR (
    contrat_id SERIAL , -- SERIAL = autoincrementing integer
    contrat_date_debut DATE NOT NULL,
    contrat_date_fin DATE CHECK (contrat_date_debut < contrat_date_fin) NOT NULL,
    contrat_renumeration INTEGER CHECK (contrat_renumeration > 0) NOT NULL,
    contrat_pourcentage_benefice INTEGER CHECK (contrat_pourcentage_benefice >= 0) NOT NULL,
    musicien_id INTEGER NOT NULL REFERENCES MUSICIEN,
    producteur_id INTEGER NOT NULL REFERENCES PRODUCTEUR,
    
    PRIMARY KEY (contrat_id)
);



CREATE TABLE IF NOT EXISTS DEMANDE (
    demande_id SERIAL , -- SERIAL = autoincrementing integer
    demande_nom VARCHAR NOT NULL,
    demande_date_debut DATE NOT NULL,
    demande_date_fin DATE CHECK (demande_date_debut <= demande_date_fin) NOT NULL,
    instrument_id integer REFERENCES INSTRUMENT,
    style_musique_id integer REFERENCES STYLE_MUSIQUE,
    
    PRIMARY KEY (demande_id)
);



CREATE TABLE IF NOT EXISTS CONTRAT_AGENT_ARTISTE (
    contrat_id SERIAL , -- SERIAL = autoincrementing integer
    contrat_debut DATE NOT NULL,
    contrat_fin DATE CHECK (contrat_debut < contrat_fin OR contrat_fin = NULL), -- Si la reprsentation actuelle est pour une dure indtermine sans date de fin : contrat_fin = NULL
    contrat_pourcentage_agence INTEGER NOT NULL,
    musicien_id INTEGER REFERENCES MUSICIEN,
    agent_id INTEGER REFERENCES AGENT,
    
    PRIMARY KEY (contrat_id)
);

CREATE TABLE IF NOT EXISTS PAIEMENT_ARTISTE (
    paiements_id INTEGER NOT NULL,
    contrat_id INTEGER REFERENCES CONTRAT_ARTISTE_PRODUCTEUR,
    paiements_date DATE NOT NULL,
    paiement_montant_brut INTEGER CHECK (paiement_montant_brut > 0) NOT NULL,
    paiement_honoraire_agence INTEGER CHECK (paiement_honoraire_agence > 0) NOT NULL,
    
    PRIMARY KEY (paiements_id,contrat_id)
);

CREATE TABLE IF NOT EXISTS ALBUMS (
    album_id SERIAL , -- SERIAL = autoincrementing integer
    album_nom VARCHAR NOT NULL,
    album_date_debut DATE NOT NULL,
    album_date_fin DATE CHECK (album_date_debut < album_date_fin) NOT NULL,
    
    PRIMARY KEY (album_id)
);



CREATE TABLE IF NOT EXISTS JOUE (
    musicien_id INTEGER REFERENCES MUSICIEN,
    instrument_id INTEGER REFERENCES INSTRUMENT,
    
    PRIMARY KEY (musicien_id,instrument_id)
);

CREATE TABLE IF NOT EXISTS MAITRISE (
    musicien_id INTEGER REFERENCES MUSICIEN,
    style_id INTEGER REFERENCES STYLE_MUSIQUE,
    
    PRIMARY KEY (musicien_id,style_id)
    
);