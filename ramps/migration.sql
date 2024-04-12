

CREATE TABLE rampstatus (
	id BIGINT PRIMARY KEY NOT NULL,
	ramp_name VARCHAR NOT NULL,
	access_status VARCHAR NOT NULL,
    o_id BIGINT NOT NULL,
    city VARCHAR NOT NULL,
    access_id VARCHAR NOT NULL,
    location VARCHAR NOT NULL
);

CREATE SEQUENCE Ramp_id_seq;
ALTER TABLE ONLY public.rampstatus ALTER COLUMN id SET DEFAULT nextval('Ramp_id_seq');
ALTER SEQUENCE Ramp_id_seq OWNED BY public.rampstatus.id;

ALTER TABLE rampstatus ADD UNIQUE (o_id);
ALTER TABLE rampstatus ADD CONSTRAINT access_id_unk UNIQUE (access_id);

-- Stub data
INSERT INTO rampstatus(ramp_name, access_status, o_id, city, access_id, location)
VALUES
	('ramp', 'access', 1, 'my city', 'access id', 'loc')
ON CONFLICT(access_id)
DO UPDATE SET
    ramp_name = EXCLUDED.ramp_name,
    access_status = EXCLUDED.access_status,
    city = EXCLUDED.city,
    access_id = EXCLUDED.access_id,
    location = EXCLUDED.location;


-- In case of emergency, drop the table
DROP TABLE rampstatus;
DROP SEQUENCE Ramp_id_seq;