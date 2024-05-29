-- Test to ensure that autostats correctly uses skip_locked to prevent unwanted
-- lock waits. This aligns autostats to PG autoanalyze behavior.

CREATE TABLE test_autostats_locking(i int);
INSERT INTO test_autostats_locking SELECT 1 FROM generate_series(1, 10);
ANALYZE test_autostats_locking;
SELECT reltuples FROM pg_class WHERE relname = 'test_autostats_locking';

SET gp_autostats_mode TO onchange;
SET gp_autostats_on_change_threshold TO 9;
SET gp_autostats_lock_wait TO off;

1: BEGIN;
-- Hold a lock that conflicts with ANALYZE.
1: LOCK test_autostats_locking IN SHARE UPDATE EXCLUSIVE MODE;

-- This insert should not block because of the concurrent lock.
INSERT INTO test_autostats_locking SELECT 1 FROM generate_series(1, 10);
-- And reltuples should NOT have been updated from the autostats-analyze as
-- lock acquisition was unsuccessful.
SELECT reltuples FROM pg_class WHERE relname = 'test_autostats_locking';

1: END;

INSERT INTO test_autostats_locking SELECT 1 FROM generate_series(1, 10);
-- And reltuples should have been updated from the autostats-analyze as
-- lock acquisition was successful.
SELECT reltuples FROM pg_class WHERE relname = 'test_autostats_locking';
