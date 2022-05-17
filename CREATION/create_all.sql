/*
 * Exemple d'utilisation :
 * \include 'C:/Users/lenny/git/bdav-agence-artistique/CREATION/create_all.sql'
 */

DROP SEQUENCE IF EXISTS musicien_id_seq CASCADE;
DROP SEQUENCE IF EXISTS agent_id_seq CASCADE;
DROP SEQUENCE IF EXISTS producteur_id_seq CASCADE;
DROP SEQUENCE IF EXISTS instrument_id_seq CASCADE;
DROP SEQUENCE IF EXISTS style_id_seq CASCADE;
DROP SEQUENCE IF EXISTS contrat_id_artiste_producteur_seq CASCADE;
DROP SEQUENCE IF EXISTS demande_id_seq CASCADE;
DROP SEQUENCE IF EXISTS contrat_id_agent_artiste_seq CASCADE;
DROP SEQUENCE IF EXISTS album_id_seq CASCADE;

DROP TABLE IF EXISTS AGENT CASCADE;
DROP TABLE IF EXISTS DEMANDE CASCADE;
DROP TABLE IF EXISTS INSTRUMENT CASCADE;
DROP TABLE IF EXISTS CONTRAT_AGENT_ARTISTE CASCADE;
DROP TABLE IF EXISTS PAIEMENT_ARTISTE CASCADE;
DROP TABLE IF EXISTS ALBUMS CASCADE;
DROP TABLE IF EXISTS STYLE_MUSIQUE CASCADE;
DROP TABLE IF EXISTS CONTRAT_ARTISTE_PRODUCTEUR CASCADE;
DROP TABLE IF EXISTS MUSICIEN CASCADE;
DROP TABLE IF EXISTS PRODUCTEUR CASCADE;
DROP TABLE IF EXISTS MAITRISE CASCADE;
DROP TABLE IF EXISTS JOUE CASCADE;

CREATE TABLE IF NOT EXISTS MUSICIEN (
    musicien_id INTEGER NOT NULL,
    musicien_nom VARCHAR NOT NULL,
    musicien_prenom VARCHAR NOT NULL,
    musicien_date_naissance DATE NOT NULL,
    musicien_telephone VARCHAR NOT NULL,
    musicien_adresse VARCHAR NOT NULL,
    musicien_mail VARCHAR NOT NULL,
    
    PRIMARY KEY (musicien_id),
    UNIQUE (musicien_nom, musicien_prenom, musicien_date_naissance, musicien_telephone, musicien_adresse, musicien_mail)
);

CREATE SEQUENCE musicien_id_seq OWNED BY musicien.musicien_id;
ALTER TABLE musicien ALTER COLUMN musicien_id SET DEFAULT nextval('musicien_id_seq');


CREATE TABLE IF NOT EXISTS AGENT (
    agent_id INTEGER NOT NULL,
    agent_nom VARCHAR NOT NULL,
    agent_prenom VARCHAR NOT NULL,
    agent_telephone VARCHAR NOT NULL,
    agent_mail VARCHAR NOT NULL,
    agent_date_embauche DATE NOT NULL,
    
    PRIMARY KEY (agent_id),
    UNIQUE (agent_nom, agent_prenom, agent_telephone, agent_mail, agent_date_embauche)
   
);

CREATE SEQUENCE agent_id_seq OWNED BY agent.agent_id;
ALTER TABLE agent ALTER COLUMN agent_id SET DEFAULT nextval('agent_id_seq');

CREATE TABLE IF NOT EXISTS PRODUCTEUR (
    producteur_id INTEGER NOT NULL,
    producteur_nom VARCHAR NOT NULL,
    producteur_prenom VARCHAR NOT NULL,
    producteur_date_naissance DATE NOT NULL,
    producteur_telephone VARCHAR NOT NULL,
    producteur_adresse VARCHAR NOT NULL,
    producteur_mail VARCHAR NOT NULL,
    
    PRIMARY KEY (producteur_id),
    UNIQUE (producteur_nom, producteur_prenom, producteur_date_naissance, producteur_telephone, producteur_adresse, producteur_mail)
);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE producteur_id_seq OWNED BY producteur.producteur_id;
ALTER TABLE producteur ALTER COLUMN producteur_id SET DEFAULT nextval('producteur_id_seq');

CREATE TABLE IF NOT EXISTS INSTRUMENT (
    instrument_id INTEGER NOT NULL,
    instrument_nom VARCHAR NOT NULL,
    
    PRIMARY KEY (instrument_id)
);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE instrument_id_seq OWNED BY instrument.instrument_id;
ALTER TABLE instrument ALTER COLUMN instrument_id SET DEFAULT nextval('instrument_id_seq');

CREATE TABLE IF NOT EXISTS STYLE_MUSIQUE(
    style_id INTEGER NOT NULL,
    style_nom VARCHAR NOT NULL,
    
    PRIMARY KEY (style_id)
);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE style_id_seq OWNED BY style_musique.style_id;
ALTER TABLE style_musique ALTER COLUMN style_id SET DEFAULT nextval('style_id_seq');

CREATE TABLE IF NOT EXISTS CONTRAT_ARTISTE_PRODUCTEUR (
    contrat_id INTEGER NOT NULL,
    contrat_date_debut DATE NOT NULL,
    contrat_date_fin DATE CHECK (contrat_date_debut < contrat_date_fin) NOT NULL,
    contrat_renumeration INTEGER CHECK (contrat_renumeration > 0) NOT NULL,
    musicien_id INTEGER NOT NULL REFERENCES MUSICIEN,
    producteur_id INTEGER NOT NULL REFERENCES PRODUCTEUR,
    
    PRIMARY KEY (contrat_id)
);

-- CREATE INDEX nom_index ON nom_table (nom_attribut);
CREATE INDEX contrat_date_debut_index ON CONTRAT_ARTISTE_PRODUCTEUR (contrat_date_debut);
CREATE INDEX contrat_date_fin_index ON CONTRAT_ARTISTE_PRODUCTEUR (contrat_date_fin);
CREATE INDEX contrat_musicien_id_index ON CONTRAT_ARTISTE_PRODUCTEUR (musicien_id);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE contrat_id_artiste_producteur_seq OWNED BY contrat_artiste_producteur.contrat_id;
ALTER TABLE contrat_artiste_producteur ALTER COLUMN contrat_id SET DEFAULT nextval('contrat_id_artiste_producteur_seq');


CREATE TABLE IF NOT EXISTS DEMANDE (
    demande_id INTEGER NOT NULL,
    demande_nom VARCHAR NOT NULL,
    demande_date_debut DATE NOT NULL,
    demande_date_fin DATE CHECK (demande_date_debut <= demande_date_fin) NOT NULL,
    instrument_id integer REFERENCES INSTRUMENT,
    style_musique_id integer REFERENCES STYLE_MUSIQUE,
    
    PRIMARY KEY (demande_id)
);

-- CREATE INDEX nom_index ON nom_table (nom_attribut);
CREATE INDEX instrument_id_index ON DEMANDE (instrument_id);
CREATE INDEX style_musique_id_index ON DEMANDE (style_musique_id);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE demande_id_seq OWNED BY demande.demande_id;
ALTER TABLE demande ALTER COLUMN demande_id SET DEFAULT nextval('demande_id_seq');


CREATE TABLE IF NOT EXISTS CONTRAT_AGENT_ARTISTE (
    contrat_id INTEGER NOT NULL,
    contrat_debut DATE NOT NULL,
    contrat_fin DATE CHECK (contrat_debut < contrat_fin OR contrat_fin = NULL), -- Si la reprsentation actuelle est pour une dure indtermine sans date de fin : contrat_fin = NULL
    contrat_pourcentage_agence INTEGER NOT NULL,
    musicien_id INTEGER REFERENCES MUSICIEN,
    agent_id INTEGER REFERENCES AGENT,
    
    PRIMARY KEY (contrat_id)
);

-- CREATE INDEX nom_index ON nom_table (nom_attribut);
CREATE INDEX contrat_debut_index ON CONTRAT_AGENT_ARTISTE (contrat_debut);
CREATE INDEX contrat_fin_index ON CONTRAT_AGENT_ARTISTE (contrat_fin);
CREATE INDEX musicien_id_index ON CONTRAT_AGENT_ARTISTE (musicien_id);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE contrat_id_agent_artiste_seq OWNED BY contrat_agent_artiste.contrat_id;
ALTER TABLE contrat_agent_artiste ALTER COLUMN contrat_id SET DEFAULT nextval('contrat_id_agent_artiste_seq');


/* PAIEMENT_ARTISTE : Comptabilité
 * On maintient la trace de tout paiement que chaque artiste (musicien) recoit avec, evidemment, des references
 * qui permettent de connaitre le contrat concerné par le paiement (CONTRAT_ARTISTE_PRODUCTEUR).
 * On maintient également l’information concernant les honoraires percus par lagence.
*/
CREATE TABLE IF NOT EXISTS PAIEMENT_ARTISTE (
    paiements_id INTEGER NOT NULL,
    contrat_id INTEGER REFERENCES CONTRAT_ARTISTE_PRODUCTEUR,
    paiements_date DATE NOT NULL,
    paiement_montant_brut INTEGER CHECK (paiement_montant_brut > 0) NOT NULL,
    paiement_honoraire_agence INTEGER CHECK (paiement_honoraire_agence > 0 AND paiement_honoraire_agence < paiement_montant_brut) NOT NULL,
    
    -- paiement_artiste est une entité faible car un paiement est attaché a un contrat.
    PRIMARY KEY (paiements_id,contrat_id)
);


CREATE TABLE IF NOT EXISTS ALBUMS (
    album_id INTEGER NOT NULL,
    album_nom VARCHAR NOT NULL,
    album_date_debut DATE NOT NULL,
    album_date_fin DATE CHECK (album_date_debut < album_date_fin) NOT NULL,
    
    PRIMARY KEY (album_id)
);

-- Convertir le champ id de la table en auto-increment (incrémentation automatique)
CREATE SEQUENCE album_id_seq OWNED BY albums.album_id;
ALTER TABLE albums ALTER COLUMN album_id SET DEFAULT nextval('album_id_seq');


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