-- Create the domain table
CREATE TABLE domain (
    id SERIAL PRIMARY KEY,
    domain_name VARCHAR(255) NOT NULL,
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
