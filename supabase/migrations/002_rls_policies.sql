-- Finalized Row-Level Security (RLS) policies for BR-05 (Owner vs. Runner)
-- Issue #6

alter table public.users enable row level security;
alter table public.customers enable row level security;
alter table public.vehicles enable row level security;
alter table public.bookings enable row level security;
alter table public.handovers enable row level security;

-- Helper function to retrieve current user's role without recursive RLS lookups
create or replace function public.get_my_role()
returns public.user_role
language sql
security definer
stable
set search_path = public
as $$
    select role from public.users where id = auth.uid();
$$;

-- 1. USERS POLICIES
drop policy if exists "Owners have full access to users" on public.users;
create policy "Owners have full access to users"
on public.users for all to authenticated
using (public.get_my_role() = 'owner')
with check (public.get_my_role() = 'owner');

drop policy if exists "Runners can view users" on public.users;
create policy "Runners can view users"
on public.users for select to authenticated
using (public.get_my_role() = 'runner');

drop policy if exists "Runners can update own profile" on public.users;
create policy "Runners can update own profile"
on public.users for update to authenticated
using (id = auth.uid() and public.get_my_role() = 'runner')
with check (id = auth.uid() and role = 'runner');

-- 2. VEHICLES POLICIES
drop policy if exists "Owners have full CRUD on vehicles" on public.vehicles;
create policy "Owners have full CRUD on vehicles"
on public.vehicles for all to authenticated
using (public.get_my_role() = 'owner')
with check (public.get_my_role() = 'owner');

drop policy if exists "Runners can view all vehicles" on public.vehicles;
create policy "Runners can view all vehicles"
on public.vehicles for select to authenticated
using (public.get_my_role() = 'runner');

drop policy if exists "Runners can update vehicle status and mileage" on public.vehicles;
create policy "Runners can update vehicle status and mileage"
on public.vehicles for update to authenticated
using (public.get_my_role() = 'runner')
with check (public.get_my_role() = 'runner');

-- 3. CUSTOMERS POLICIES
drop policy if exists "Owners have full CRUD on customers" on public.customers;
create policy "Owners have full CRUD on customers"
on public.customers for all to authenticated
using (public.get_my_role() = 'owner')
with check (public.get_my_role() = 'owner');

drop policy if exists "Runners can view customers" on public.customers;
create policy "Runners can view customers"
on public.customers for select to authenticated
using (public.get_my_role() = 'runner');

drop policy if exists "Runners can insert customers" on public.customers;
create policy "Runners can insert customers"
on public.customers for insert to authenticated
with check (public.get_my_role() = 'runner');

drop policy if exists "Runners can update customers" on public.customers;
create policy "Runners can update customers"
on public.customers for update to authenticated
using (public.get_my_role() = 'runner')
with check (public.get_my_role() = 'runner');

-- 4. BOOKINGS POLICIES
drop policy if exists "Owners have full CRUD on bookings" on public.bookings;
create policy "Owners have full CRUD on bookings"
on public.bookings for all to authenticated
using (public.get_my_role() = 'owner')
with check (public.get_my_role() = 'owner');

drop policy if exists "Runners can view bookings" on public.bookings;
create policy "Runners can view bookings"
on public.bookings for select to authenticated
using (public.get_my_role() = 'runner');

drop policy if exists "Runners can update assigned bookings" on public.bookings;
create policy "Runners can update assigned bookings"
on public.bookings for update to authenticated
using (public.get_my_role() = 'runner' and (assigned_runner_id = auth.uid() or assigned_runner_id is null))
with check (public.get_my_role() = 'runner');

-- 5. HANDOVERS POLICIES
drop policy if exists "Owners have full CRUD on handovers" on public.handovers;
create policy "Owners have full CRUD on handovers"
on public.handovers for all to authenticated
using (public.get_my_role() = 'owner')
with check (public.get_my_role() = 'owner');

drop policy if exists "Runners can view handovers" on public.handovers;
create policy "Runners can view handovers"
on public.handovers for select to authenticated
using (public.get_my_role() = 'runner');

drop policy if exists "Runners can insert own handovers" on public.handovers;
create policy "Runners can insert own handovers"
on public.handovers for insert to authenticated
with check (public.get_my_role() = 'runner' and runner_id = auth.uid());

drop policy if exists "Runners can update own handovers" on public.handovers;
create policy "Runners can update own handovers"
on public.handovers for update to authenticated
using (public.get_my_role() = 'runner' and runner_id = auth.uid())
with check (public.get_my_role() = 'runner' and runner_id = auth.uid());