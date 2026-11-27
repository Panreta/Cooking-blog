-- Run this in the Supabase dashboard: SQL Editor → New query → paste → Run.
-- Safe to run again; it updates an existing setup in place.

create table if not exists public.posts (
  id          uuid primary key default gen_random_uuid(),
  author_name text not null default '',
  title       text not null check (char_length(title) between 1 and 200),
  description text not null default '',
  cover_url   text not null,
  prep_time   text,
  cook_time   text,
  servings    text,
  tags        text[] not null default '{}',
  ingredients text[] not null default '{}',
  story       text not null default '',
  -- [{ "text": "...", "photo": "https://..." | null }, ...]
  steps       jsonb not null default '[]',
  tips        text not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- There are no accounts any more, so posts no longer belong to a user.
alter table public.posts drop column if exists author_id;

create index if not exists posts_created_at_idx on public.posts (created_at desc);

alter table public.posts enable row level security;

-- Newer Supabase projects don't auto-grant table access to the API roles.
grant select, insert, update, delete on public.posts to anon, authenticated;

-- No login: anyone can read, add, edit, and delete recipes.
drop policy if exists "posts are public" on public.posts;
drop policy if exists "users create own posts" on public.posts;
drop policy if exists "users update own posts" on public.posts;
drop policy if exists "users delete own posts" on public.posts;
drop policy if exists "anyone can read posts" on public.posts;
drop policy if exists "anyone can add posts" on public.posts;
drop policy if exists "anyone can edit posts" on public.posts;
drop policy if exists "anyone can delete posts" on public.posts;

create policy "anyone can read posts" on public.posts for select using (true);
create policy "anyone can add posts" on public.posts for insert with check (true);
create policy "anyone can edit posts" on public.posts for update using (true) with check (true);
create policy "anyone can delete posts" on public.posts for delete using (true);

-- Photo storage: a public bucket that anyone can upload images into (max 10 MB each).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 10485760, array['image/jpeg'])
on conflict (id) do update
  set public = true, file_size_limit = 10485760, allowed_mime_types = array['image/jpeg'];

drop policy if exists "users upload own photos" on storage.objects;
drop policy if exists "users delete own photos" on storage.objects;
drop policy if exists "anyone can upload photos" on storage.objects;

create policy "anyone can upload photos" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'photos');
