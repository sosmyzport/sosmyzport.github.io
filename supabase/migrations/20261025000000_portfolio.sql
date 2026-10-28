begin;

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create table if not exists public.portfolio_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.portfolio_admins enable row level security;
revoke all on table public.portfolio_admins from public, anon, authenticated;
grant select on table public.portfolio_admins to authenticated;
drop policy if exists "admins can read own authorization" on public.portfolio_admins;
create policy "admins can read own authorization"
  on public.portfolio_admins for select to authenticated
  using (user_id = (select auth.uid()));

create or replace function private.is_portfolio_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.portfolio_admins a
    where a.user_id = (select auth.uid())
  );
$$;
revoke all on function private.is_portfolio_admin() from public, anon, authenticated;
grant execute on function private.is_portfolio_admin() to authenticated;

create table if not exists public.portfolio_content (
  id smallint primary key default 1 check (id = 1),
  content jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.portfolio_content enable row level security;
revoke all on table public.portfolio_content from public, anon, authenticated;
grant select on table public.portfolio_content to anon, authenticated;
grant insert, update on table public.portfolio_content to authenticated;
drop policy if exists "published portfolio is public to read" on public.portfolio_content;
drop policy if exists "admins can create portfolio content" on public.portfolio_content;
drop policy if exists "admins can update portfolio content" on public.portfolio_content;
create policy "published portfolio is public to read"
  on public.portfolio_content for select to anon, authenticated using (true);
create policy "admins can create portfolio content"
  on public.portfolio_content for insert to authenticated
  with check ((select private.is_portfolio_admin()));
create policy "admins can update portfolio content"
  on public.portfolio_content for update to authenticated
  using ((select private.is_portfolio_admin()))
  with check ((select private.is_portfolio_admin()));

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values (
  'portfolio-media','portfolio-media',true,52428800,
  array['image/jpeg','image/png','image/webp','image/avif','video/mp4','application/pdf']::text[]
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "portfolio admin uploads media" on storage.objects;
drop policy if exists "portfolio admin replaces media" on storage.objects;
drop policy if exists "portfolio admin deletes media" on storage.objects;
create policy "portfolio admin uploads media"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'portfolio-media' and (select private.is_portfolio_admin()));
create policy "portfolio admin replaces media"
  on storage.objects for update to authenticated
  using (bucket_id = 'portfolio-media' and (select private.is_portfolio_admin()))
  with check (bucket_id = 'portfolio-media' and (select private.is_portfolio_admin()));
create policy "portfolio admin deletes media"
  on storage.objects for delete to authenticated
  using (bucket_id = 'portfolio-media' and (select private.is_portfolio_admin()));

commit;
