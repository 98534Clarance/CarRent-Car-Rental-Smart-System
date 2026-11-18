### AI Usage Log — Issue #6: Supabase Database Schema & RLS Setup
* **Date:** 2026-11-18
* **Developer:** Norhadeef Danish Eidraky (@eidraky)
* **AI Tool Used:** Google Gemini
* **Related Issue / Requirement:** Issue #6 (`BR-05`: Owner vs. Runner Access Control)

#### 1. Human-Authored Work (Initial Draft — `001_init_tables.sql`)
* Wrote the initial PostgreSQL table definitions for `users`, `customers`, `vehicles`, `bookings`, and `handovers`, along with custom `ENUM` blocks (`user_role`, `vehicle_status`, `booking_status`, `handover_type`).

#### 2. Prompt & Debugging Assistance
* **Prompt 1 (Debugging DDL Errors):** Provided my SQL script after encountering `ERROR: 0A000: extension "uuid-oosp" is not available` and `ERROR: 42710: type "user_role" already exists` in Supabase.
* **AI Debugging Fixes Applied:**
  1. Replaced `uuid_generate_v4()` with PostgreSQL's built-in `gen_random_uuid()` so external UUID extensions are not required.
  2. Fixed `bookings.status` default value from `default 0` (integer mismatch) to `default 'pending'`.
  3. Changed `bookings.updated_at` type from `timetz` to `timestamptz`.
  4. Fixed foreign key reference typo in `handovers.runner_id` from `public.user(id)` to `public.users(id)`.
* **Prompt 2 (Finalizing RLS Policies — `002_rls_policies.sql`):** Requested Row-Level Security (RLS) policies enforcing `BR-05` so `owner` accounts have full CRUD control while `runner` accounts are restricted to operational reads/inserts/updates and blocked from deleting records.

#### 3. Human Verification
* Executed `001_init_tables.sql` and `002_rls_policies.sql` in the Supabase SQL Editor and verified all 5 tables and RLS policies are active in the Supabase Dashboard.