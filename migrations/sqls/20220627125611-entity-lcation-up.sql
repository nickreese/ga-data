/* Replace with your SQL commands */

-- CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE region (
    id TEXT NOT NULL PRIMARY KEY, 
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

INSERT INTO region 
(id, name, slug) 
VALUES 
('AD100', 'Canillo', 'canillo'),
('AD200', 'Encamp', 'encamp'),
('AD300', 'Ordino', 'ordino'),
('AD400', 'La Massana', 'la-massana'),
('AD500', 'Andorra la Vella', 'andorra-la-vella'),
('AD600', 'Sant Julia De Loria', 'sant-julia-de-loria'),
('AD700', 'Escaldes-Engordany', 'escaldes-engordany');


CREATE TABLE website (
    id SERIAL PRIMARY KEY,
    url TEXT NOT NULL,
    dedicated_to_entity BOOLEAN DEFAULT true,
    include_in_search BOOLEAN DEFAULT true,
	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);


CREATE TABLE restaurant(
    id SERIAL PRIMARY KEY,
    menu_url text,
    opening_closing_time text,
    stars int add constraint chk_start_limit check(stars between 0 and 5),
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

CREATE TABLE government(
    id SERIAL PRIMARY KEY,
    opening_closing_time text,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

CREATE TABLE hotel(
    id SERIAL PRIMARY KEY,
    services text,
    stars int add constraint chk_start_limit check(stars between 0 and 5),
    avg_price int,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

CREATE TABLE tag (
    id SERIAL PRIMARY KEY,
    text_content_id INTEGER NOT NULL,
    FOREIGN KEY (text_content_id) REFERENCES text_content(id) ON UPDATE CASCADE,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

CREATE TABLE entity_contact (
    id SERIAL PRIMARY KEY,
    email text,
    phone text,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
)

-----
-- Entity:
-- This is basically a generic 'entity' that represents an abstract concept of something tied to a location.
-- Initially we will tag entities with various tags. As we get more of a specific type of tag and want to add sub fields 
-- we can refactor the table to have a child table holding those specific details.

CREATE TABLE entity (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone text,

    website_id INTEGER,

    hotel_id INTEGER,
    government_id INTEGER,
    restaurant_id INTEGER,
    contact_id INTEGER,
	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),


    FOREIGN KEY (hotel_id) REFERENCES hotel(id) ON UPDATE CASCADE,
    FOREIGN KEY (government_id) REFERENCES government(id) ON UPDATE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON UPDATE CASCADE,

    FOREIGN KEY (website_id) REFERENCES website(id) ON UPDATE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES entity_contact(id) ON UPDATE CASCADE
);

----- 
-- Locations:
-- Represent a physical location. Unless the building gets knocked down, the location remains the same... maybe the attached entity changes.
-- we could put all tags on the entities... 'public park' and though the location doesn't change for public parks... it could for restaurants.
-- When tags become prevelant enough on the entity table and we want to attach new fields to the entity, we can always add a subtable like restaurant to hold menus, etc.

CREATE TABLE location (
    id SERIAL PRIMARY KEY,
    lat double precision NOT NULL,
    lon double precision NOT NULL,
    geom geography NOT NULL,
    region_id TEXT NOT NULL,
    entity_id INTEGER NOT NULL,
    google_place_id TEXT,

    primary_tag_id INTEGER,

    website_id INTEGER,
    name TEXT,

	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),

    FOREIGN KEY (primary_tag_id) REFERENCES tag(id) ON UPDATE CASCADE,
    FOREIGN KEY (website_id) REFERENCES website(id) ON UPDATE CASCADE,
    FOREIGN KEY (region_id) REFERENCES region(id) ON UPDATE CASCADE,
    FOREIGN KEY (entity_id) REFERENCES entity(id) ON UPDATE CASCADE
);
COMMENT ON COLUMN location.name IS 'Used to override the entity name for a specific location. XYZ ATM when tied to a bank.';
COMMENT ON COLUMN location.website_id IS 'Used to override the website of a specific location.';




CREATE TABLE location_tag(
    location_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,

    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),

    FOREIGN KEY (location_id) REFERENCES location(id) ON UPDATE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tag(id) ON UPDATE CASCADE
);

-- open hours (location)
-- viewport bounding box.
-- address

--- TODO: 
-- remove utm variables from urls on import
-- Andorre should be changed to Andorra

--- Tables:
-- user favorites
-- user reactions
-- user votes


CREATE TYPE app_user_view_enum AS ENUM ('local', 'visitor');

-- Notes:
-- Only users with a verified Andorran phone number can post in the local view. 

CREATE TABLE app_user_phone(
    id SERIAL PRIMARY KEY,
    phone TEXT NOT NULL,
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_andorran BOOLEAN NOT NULL DEFAULT FALSE,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);

CREATE TABLE app_user_email(
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL,
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
); 

CREATE TABLE app_user(
    id UUID DEFAULT uuid_generate_v4 (),

    -- name

    prefers_offline BOOLEAN default false,
    prefers_view app_user_view_enum default 'visitor',
    app_user_email_id INTEGER NOT NULL, -- used for magic sign in links.
    app_user_phone_id INTEGER,
    language_id TEXT NOT NULL DEFAULT 'es',

	last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),
    FOREIGN KEY (app_user_phone_id) REFERENCES app_user_phone(id) ON UPDATE CASCADE,
    FOREIGN KEY (app_user_email_id) REFERENCES app_user_email(id) ON UPDATE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON UPDATE CASCADE,
    PRIMARY KEY (id)
);


CREATE TABLE community_post_category(
    id SERIAL PRIMARY KEY,
    title_text_content_id INTEGER NOT NULL,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),
    FOREIGN KEY (title_text_content_id) REFERENCES text_content(id) ON UPDATE CASCADE
);
-- lost and found
-- parents / schools
-- local news. 
-- pets
-- anonymous
-- politics





--- community messages are messages that fit in a category or can be anonymous. 
-- for every message type we store the phone, email, ip, and name in an encrypted format, so that if the gov audits us we can unencrypt but workers on the team can't.
-- messages automatically expire in 7 days and are then are hidden.

-- permissions: 
-- anyone should be able to view the community messages if they are logged in. 
-- if the app_user_id matches, they should be able to soft delete the message. 

CREATE TABLE community_post(
    id SERIAL PRIMARY KEY,
    language_id TEXT NOT NULL DEFAULT 'es',
    slug TEXT UNIQUE NOT NULL,  -- we will need a fn to generate this from the title on insert. 
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    author_app_user_id UUID,

    app_user_info_encrypted TEXT NOT NULL, -- store phone, email, ip, name.
    community_post_category_id INTEGER NOT NULL,

    is_deleted BOOLEAN NOT NULL DEFAULT FALSE, -- soft delete
    expires_at TIMESTAMPTZ NULL DEFAULT now() + interval '7 days',
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),
    FOREIGN KEY (community_post_category_id) REFERENCES community_post_category(id) ON UPDATE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON UPDATE CASCADE,
    FOREIGN KEY (author_app_user_id) REFERENCES app_user(id) ON UPDATE CASCADE
);


CREATE TABLE emoji(
    id SERIAL PRIMARY KEY,
    -- text_content_id INTEGER NOT NULL,
    emoji TEXT NOT NULL,
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now()
);




-- permissions:
-- RATE: verified locals can rate any message that isn't theirs, and is not deleted, and is not expired, and that they haven't already rated.
-- If the user has already rated, the button should correspond. 
-- VIEW Totals: If someone can see the post, then can see the aggrate counts.


CREATE TABLE community_post_app_user_emoji(
    community_post_id INTEGER NOT NULL,
    app_user_id UUID NOT NULL,
    emoji_id INTEGER NOT NULL,
    FOREIGN KEY (community_post_id) REFERENCES community_post(id) ON UPDATE CASCADE,
    FOREIGN KEY (app_user_id) REFERENCES app_user(id) ON UPDATE CASCADE,
    FOREIGN KEY (emoji_id) REFERENCES emoji(id) ON UPDATE CASCADE
); 


-- job post
-- free post
-- item post
-- real estate (require lat, lon, address... we'll geocode?... associate with multiple RE agencies?)
-- car post
-- moto post


CREATE TABLE commerical_post(
    id SERIAL PRIMARY KEY,
    language_id TEXT NOT NULL DEFAULT 'es',
    slug TEXT UNIQUE NOT NULL,  -- we will need a fn to generate this from the title on insert. 
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    author_app_user_id UUID,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE, -- soft delete
    expires_at TIMESTAMPTZ NULL DEFAULT now() + interval '7 days',
    last_updated timestamptz NULL DEFAULT now(),
	created_at timestamptz NULL DEFAULT now(),
    -- FOREIGN KEY (community_post_category_id) REFERENCES community_post_category(id) ON UPDATE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON UPDATE CASCADE,
    FOREIGN KEY (author_app_user_id) REFERENCES app_user(id) ON UPDATE CASCADE
);



-- user votes

-- Event
-- date
-- en_description
-- es_description
-- ca_description
-- fr_description
-- photo
-- location
-- location text...
