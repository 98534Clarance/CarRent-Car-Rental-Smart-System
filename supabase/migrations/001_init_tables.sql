-- schema by @eidraky
-- core tables for CarRent Smart System #Issues 6

DO $$ BEGIN
  CREATE TYPE public.user_role AS ENUM ('owner', 'runner');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.vehicle_status AS ENUM ('available', 'rented', 'maintenance', 'retired');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.booking_status AS ENUM ('pending', 'confirmed', 'active', 'completed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.handover_type AS ENUM ('pickup', 'return');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

--1. Users table
create table if not exists public.users(
    id uuid primary key references auth.users(id) on delete cascade,
    full_name text not null,
    email text unique not null,
    phone text,
    role user_role not null default 'runner',
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

--2. Customers table
create table if not exists public.customers(
    id uuid primary key default gen_random_uuid(),
    full_name text not null,
    ic_or_passport text unique not null,
    license_number text not null,
    license_expiry date not null,
    phone text not null,
    email text,
    address text,
    ocr_verified boolean not null default false,
    entry_method text not null default 'ocr' check (entry_method in ('ocr', 'manual_fallback')),
    pdpa_consent boolean not null default false,
    pdpa_consent_at timestamptz,
    created_by uuid references public.users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

--3. Vehicles table
create table if not exists public.vehicles (
    id uuid primary key default gen_random_uuid(),
    plate_number text unique not null,
    brand text not null,
    model text not null,
    year int not null,
    color text,
    daily_rate numeric(10, 2) not null check (daily_rate >= 0),
    current_mileage int not null default 0,
    status vehicle_status not null default 'available',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

--4. Bookings table
create table if not exists public.bookings(
    id uuid primary key default gen_random_uuid(),
    customer_id uuid not null references public.customers(id) on delete restrict,
    vehicle_id uuid not null references public.vehicles(id) on delete restrict,
    assigned_runner_id uuid references public.users(id) on delete set null,
    pickup_datetime timestamptz not null,
    return_datetime timestamptz not null,
    total_price numeric(10, 2) not null check (total_price >= 0),
    deposit_amount numeric(10, 2) not null default 0,
    status booking_status not null default 'pending',
    notes text,
    created_by uuid references public.users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint valid_booking_dates check (return_datetime > pickup_datetime)
);

--5. Handovers table
create table if not exists public.handovers (
    id uuid primary key default gen_random_uuid(),
    booking_id uuid not null references public.bookings(id) on delete cascade,
    runner_id uuid not null references public.users(id) on delete restrict,
    type handover_type not null,
    odometer_reading int not null check (odometer_reading >= 0),
    fuel_level_percent int not null check (fuel_level_percent between 0 and 100),
    exterior_condition_notes text,
    damage_reported boolean not null default false,
    inspection_photo_urls text[] default '{}',
    customer_acknowledged boolean not null default false,
    completed_at timestamptz not null default now()
);