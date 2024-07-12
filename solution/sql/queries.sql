-- I suppose EXIST will perform better than JOIN since there could be many flags for single domain
-- and might be flattened into JOIN anyway.

-- Registered, not expired domains. For simplicity I assume host www and TLD cz
SELECT domain_name
FROM domain d
WHERE d.registered_at < now()
    AND COALESCE(d.unregistered_at, 'infinity'::timestamp) > now()
    AND NOT EXISTS (
        SELECT 1
        FROM domain_flag f
        WHERE f.domain_id = d.id
            AND f.flag = 'EXPIRED'
            AND f.start_time < now()
            AND COALESCE(f.end_time, 'infinity'::timestamp) > now()
    );
