-- Create the domain table
CREATE TABLE domain (
    id SERIAL PRIMARY KEY,
    domain_name VARCHAR(255) NOT NULL CHECK(domain_name ~ '^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*$'),
    registered_at TIMESTAMP NOT NULL,
    unregistered_at TIMESTAMP,
    CONSTRAINT valid_time_interval CHECK((unregistered_at IS NULL) OR (registered_at <= unregistered_at))
);

-- Indexe for performance optimization
CREATE INDEX idx_domain_name ON domain(domain_name);

-- Unique active domain constraint
CREATE OR REPLACE FUNCTION check_unique_active_domain()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
    AS
$$
DECLARE
    overlapping_domain VARCHAR(255);
BEGIN
    overlapping_domain := (
        SELECT domain_name
        FROM domain d
        WHERE d.domain_name = NEW.domain_name
        AND tsrange(NEW.registered_at, COALESCE(NEW.unregistered_at, 'infinity'::timestamp)) && 
            tsrange(d.registered_at, COALESCE(d.unregistered_at, 'infinity'::timestamp))
        AND NEW.id <> d.id
        LIMIT 1
    );
    IF overlapping_domain IS NOT NULL THEN
        RAISE EXCEPTION 'Overlapping active domain "%"', overlapping_domain;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_unique_active_domain_insert
    BEFORE INSERT ON domain
    FOR EACH ROW
    EXECUTE FUNCTION check_unique_active_domain();

CREATE TRIGGER check_unique_active_domain_update
    BEFORE UPDATE ON domain
    FOR EACH ROW
    EXECUTE FUNCTION check_unique_active_domain();

-- Create the domain_flag table
CREATE TABLE domain_flag (
    id SERIAL PRIMARY KEY,
    domain_id INT REFERENCES domain(id) ON DELETE CASCADE,
    flag VARCHAR(50) NOT NULL CHECK (flag IN ('EXPIRED', 'OUTZONE', 'DELETE_CANDIDATE')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP
);

-- Indexe for performance optimization
CREATE INDEX idx_flag_domain ON domain_flag(domain_id);

/* Never change inserted records with one exception: if upper limit is unbounded, it can be set to specific 
   point in time but never to the past (at the time the change is made).
   => only null end_time rows can be modified */
CREATE OR REPLACE FUNCTION forbid_flag_column_update_only_upper_limit()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
    AS
$$
BEGIN
	IF (OLD.end_time IS NOT NULL OR     -- upper limit is not unbounded
        (OLD.end_time IS NULL AND       -- upper limit unbounded
            (NEW.end_time < now()       -- can't be set to past
            OR NEW.id <> OLD.id         -- rest can't be modified
            OR NEW.domain_id <> OLD.domain_id
            OR NEW.flag <> OLD.flag
            OR NEW.start_time <> OLD.start_time
            )))
    THEN
		RAISE EXCEPTION 'Modification not allowed';
	END IF;

	RETURN NEW;
END;
$$;

CREATE TRIGGER forbid_flag_modification
    BEFORE UPDATE ON domain_flag
    FOR EACH ROW
    EXECUTE FUNCTION forbid_flag_column_update_only_upper_limit();

-- It might also be fruitful to check whether flags are active only during domain active registration.