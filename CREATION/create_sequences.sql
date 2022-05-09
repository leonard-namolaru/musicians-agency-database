/*  Convertir le champ id de la plupart des tables en auto-increment (incrémentation automatique)  */

-- Table MUSICIEN
 CREATE SEQUENCE musicien_id_seq OWNED BY musicien.musicien_id;
 ALTER TABLE musicien ALTER COLUMN musicien_id SET DEFAULT nextval('musicien_id_seq');