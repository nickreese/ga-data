/* Replace with your SQL commands */


CREATE TABLE language (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

CREATE TABLE text_content (
    id SERIAL PRIMARY KEY,
    original_language_id TEXT NOT NULL,
    original_text TEXT NOT NULL,
	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),

    FOREIGN KEY (original_language_id) REFERENCES language(id) ON UPDATE CASCADE
);

CREATE TABLE translation (
    id SERIAL PRIMARY KEY,
    language_id TEXT NOT NULL,
    text_content_id INTEGER NOT NULL,
    text TEXT NOT NULL,
	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),

    FOREIGN KEY (language_id) REFERENCES language(id) ON UPDATE CASCADE,
    FOREIGN KEY (text_content_id) REFERENCES text_content(id) ON UPDATE CASCADE
);


CREATE TRIGGER mdt_language
BEFORE UPDATE ON language
FOR EACH ROW
EXECUTE PROCEDURE moddatetime (language);


CREATE TRIGGER mdt_translation
BEFORE UPDATE ON translation
FOR EACH ROW
EXECUTE PROCEDURE moddatetime (translation);

CREATE TRIGGER mdt_text_content
BEFORE UPDATE ON text_content
FOR EACH ROW
EXECUTE PROCEDURE moddatetime (text_content);

INSERT INTO language(id, name) VALUES 
    ('en', 'English'),
    ('fr', 'Français'),
    ('es', 'Castellano'),
    ('ca', 'Català'),
    ('pt', 'Português');
