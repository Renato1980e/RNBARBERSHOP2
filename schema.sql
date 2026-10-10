-- RN BARBER SHOP: esquema inicial Supabase
create extension if not exists pgcrypto;
create extension if not exists btree_gist;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null default '',
 business_name text not null default 'RN Barber Shop',
 phone text default '',
 whatsapp text default '5599984158379',
 address text default 'Rua Longitudinal 4, quadra 6, lote 28 - Colina Park',
 instagram text default 'RN_Barber.shop',
 public_status text not null default 'available' check (public_status in ('available','pause','offline')),
 created_at timestamptz not null default now()
);
create table if not exists public.clients (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 phone text default '',
 notes text default '',
 created_at timestamptz not null default now()
);
create table if not exists public.services (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 price numeric(10,2) not null default 0 check (price >= 0),
 duration_minutes integer not null default 30 check (duration_minutes > 0),
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.appointments (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 client_id uuid references public.clients(id) on delete set null,
 client_name text not null,
 phone text default '',
 service_id uuid references public.services(id) on delete set null,
 service text not null default '',
 appointment_date date not null,
 start_time time not null,
 end_time time not null,
 duration_minutes integer not null default 30,
 price numeric(10,2) not null default 0 check (price >= 0),
 status text not null default 'Agendado' check (status in ('Agendado','Em atendimento','Concluído','Cancelado','Faltou')),
 paid boolean not null default false,
 payment_method text default '',
 notes text default '',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check (end_time > start_time)
);
create table if not exists public.payments (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 appointment_id uuid references public.appointments(id) on delete set null,
 description text not null,
 amount numeric(10,2) not null check (amount >= 0),
 kind text not null check (kind in ('Entrada','Despesa')),
 method text not null default 'Outro',
 payment_date date not null default current_date,
 created_at timestamptz not null default now()
);
create table if not exists public.activity_history (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 appointment_id uuid references public.appointments(id) on delete set null,
 action text not null,
 description text not null,
 created_at timestamptz not null default now()
);
create index if not exists appointments_user_date_idx on public.appointments(user_id, appointment_date, start_time);
create index if not exists clients_user_name_idx on public.clients(user_id, name);
create index if not exists payments_user_date_idx on public.payments(user_id, payment_date);

-- Bloqueia sobreposição de horários para a mesma conta. Cancelados e faltas liberam o horário.
alter table public.appointments drop constraint if exists appointments_no_overlap;
alter table public.appointments add constraint appointments_no_overlap
 exclude using gist (
   user_id with =,
   appointment_date with =,
   tsrange((appointment_date + start_time), (appointment_date + end_time), '[)') with &&
 )
 where (status not in ('Cancelado','Faltou'));

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
 insert into public.profiles(id, full_name) values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''));
 insert into public.services(user_id,name,price,duration_minutes) values
 (new.id,'Cabelo',20,30),(new.id,'Barba',10,20),(new.id,'Cabelo e barba',30,50),
 (new.id,'Sobrancelha',5,10),(new.id,'Pezinho',5,10),
 (new.id,'Corte + barba + sobrancelha',35,60),(new.id,'Corte + sobrancelha',25,40),
 (new.id,'Pezinho + sobrancelha',10,20),(new.id,'Barba + sobrancelha',20,30);
 return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
 for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.services enable row level security;
alter table public.appointments enable row level security;
alter table public.payments enable row level security;
alter table public.activity_history enable row level security;

drop policy if exists "profiles owner" on public.profiles;
create policy "profiles owner" on public.profiles for all to authenticated using (id = auth.uid()) with check (id = auth.uid());
drop policy if exists "clients owner" on public.clients;
create policy "clients owner" on public.clients for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "services owner" on public.services;
create policy "services owner" on public.services for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "appointments owner" on public.appointments;
create policy "appointments owner" on public.appointments for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "payments owner" on public.payments;
create policy "payments owner" on public.payments for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "history owner" on public.activity_history;
create policy "history owner" on public.activity_history for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
