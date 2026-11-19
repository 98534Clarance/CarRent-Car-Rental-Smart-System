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

---

### AI Usage Log — Issue #7: Gemini AI OCR Integration & Fallback Handling (Flutter/Dart)
* **Date:** 2026-11-19
* **Developer:** Norhadeef Danish Eidraky (@eidraky)
* **AI Tool Used:** Google Gemini
* **Related Issue / Requirements:** Issue #7 (`FR-AI-01`, `FR-AI-02`, `FR-AI-03`, `FR-AI-04`, PDPA 2010 Compliance)

#### 1. Human-Authored Work (Initial Draft — Commit 1)
* Created `lib/services/gemini_ocr_service.dart` with `CustomerOcrData` model matching `public.customers` and basic `http.post` integration to `gemini-2.5-flash:generateContent`.

#### 2. Prompt Provided to AI
> "Upgrade my Dart `GeminiOcrService` draft to satisfy FR-AI-01 to FR-AI-04 and PDPA 2010: compress images to 1280px JPEG with EXIF stripped, enforce structured JSON output, abort after a strict 20-second timeout, and return a manual fallback state with unit tests."

#### 3. AI Output & Assistance
* Added `compressImageForOcr()` using `FlutterImageCompress` (`minWidth: 1280`, `quality: 75`, `keepExif: false`) for `FR-AI-01` and PDPA 2010 data minimization.
* Configured `responseMimeType: 'application/json'` (`FR-AI-02`) and chained `.timeout(Duration(seconds: 20))` (`FR-AI-03`).
* Added `OcrScanResult` fallback handling (`entryMethod: 'manual_fallback'`) for timeouts, API errors, missing PDPA consent, or confidence `< 0.75` (`FR-AI-04`), plus unit tests in `test/gemini_ocr_service_test.dart`.

#### 4. Human Verification & Modifications
* Ran `flutter test test/gemini_ocr_service_test.dart` locally and confirmed both PDPA guardrail and JSON parsing tests pass before pushing PR for teammate review.