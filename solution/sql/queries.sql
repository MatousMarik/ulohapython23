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
WITH domain_ids AS (
  SELECT domain_name, ARRAY_AGG(id) AS ids
  FROM domain
  GROUP BY domain_name
)
SELECT 'www.' || domain_name || '.cz' as fully_qualified_domain_name
FROM domain_ids
WHERE EXISTS (
        SELECT 1
        FROM domain_flag fe
        WHERE fe.domain_id = ANY(ids)
            AND fe.flag = 'EXPIRED'
            AND fe.end_time IS NOT NULL -- has to be in the past
            AND fe.end_time < now()
            AND EXISTS (
                SELECT 1
                FROM domain_flag fo
                WHERE fo.domain_id = ANY(ids)
                    AND fo.flag = 'OUTZONE'
                    AND fo.end_time IS NOT NULL -- has to be in the past
                    AND fo.end_time < now()
            )
    );
