/* Replace with your SQL commands */


DROP TRIGGER IF EXISTS mdt_language ON language;
DROP TRIGGER IF EXISTS mdt_text_content ON text_content;
DROP TRIGGER IF EXISTS mdt_translation ON translation;

DROP TABLE IF EXISTS translation;
DROP TABLE IF EXISTS text_content;
DROP TABLE IF EXISTS language;