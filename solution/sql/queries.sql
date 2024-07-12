-- I suppose EXIST will perform better than JOIN since there could be many flags for single domain
-- and might be flattened into JOIN anyway.

-- Registered, not expired domains. For simplicity I assume host www and TLD cz
SELECT 'www.' || d.domain_name || '.cz' as fully_qualified_domain_name
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

-- Domains, that had EXPIRED and OUTZONE flags. For simplicity I assume host www and TLD cz
SELECT DISTINCT 'www.' || d.domain_name || '.cz' as fully_qualified_domain_name
FROM domain d
JOIN domain_flag fe ON d.id = fe.domain_id AND fe.flag = 'EXPIRED'
JOIN domain_flag fo ON d.id = fo.domain_id AND fo.flag = 'OUTZONE'
WHERE COALESCE(fe.end_time, 'infinity'::timestamp) < now()
AND COALESCE(fo.end_time, 'infinity'::timestamp) < now()
GROUP BY d.domain_name;