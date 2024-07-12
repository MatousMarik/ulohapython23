INSERT INTO domain (domain_name, registered_at, unregistered_at) VALUES
('example', '2023-01-01 00:00:00', NULL),
('test', '2023-02-01 00:00:00', '2023-03-01 00:00:00'),
('foo', '2023-03-01 00:00:00', NULL),
('example', '2022-02-01 00:00:00', '2022-03-01 00:00:00'),
('bar1.134.f', '2023-03-01 00:00:00', NULL);

/* invalid data
INSERT INTO domain (domain_name, registered_at, unregistered_at) VALUES
('test', '2023-02-01 00:00:00', '2023-03-01 00:00:00');

INSERT INTO domain (domain_name, registered_at, unregistered_at) VALUES
('test', '2022-02-01 00:00:00', NULL);

INSERT INTO domain (domain_name, registered_at, unregistered_at) VALUES
('.p', '2022-02-01 00:00:00', NULL);

INSERT INTO domain (domain_name, registered_at, unregistered_at) VALUES
('.nono', '2022-02-01 00:00:00', NULL);

INSERT INTO domain (domain_name, registered_at, unregistered_at) VALUES
('test.', '2022-02-01 00:00:00', NULL);

UPDATE domain
SET unregistered_at = NULL
WHERE domain_name = 'example';
*/
