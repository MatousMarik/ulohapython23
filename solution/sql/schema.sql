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
    overlap_found BOOLEAN;
BEGIN
    overlap_found := EXISTS (
        SELECT 1
        FROM domain d
        WHERE d.domain_name = NEW.domain_name
        AND NEW.id <> d.id  -- avoid update self block
        AND tsrange(NEW.registered_at, COALESCE(NEW.unregistered_at, 'infinity'::timestamp)) && 
            tsrange(d.registered_at, COALESCE(d.unregistered_at, 'infinity'::timestamp))
    );

    IF overlap_found THEN
        RAISE EXCEPTION 'Overlapping active domains not allowed';
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
