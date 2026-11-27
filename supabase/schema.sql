-- Run this once in the Supabase dashboard: SQL Editor → New query → paste → Run.

create table if not exists public.posts (
  id          uuid primary key default gen_random_uuid(),
  author_id   uuid not null references auth.users (id) on delete cascade default auth.uid(),
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

create index if not exists posts_created_at_idx on public.posts (created_at desc);

alter table public.posts enable row level security;

-- Newer Supabase projects don't auto-grant table access to the API roles; RLS below still limits rows.
grant select on public.posts to anon, authenticated;
grant insert, update, delete on public.posts to authenticated;

-- Anyone (even logged out) can read posts.
drop policy if exists "posts are public" on public.posts;
create policy "posts are public" on public.posts
  for select using (true);

-- Logged-in users can create posts as themselves.
drop policy if exists "users create own posts" on public.posts;
create policy "users create own posts" on public.posts
  for insert to authenticated with check (author_id = auth.uid());

-- Authors can edit and delete only their own posts.
drop policy if exists "users update own posts" on public.posts;
create policy "users update own posts" on public.posts
  for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());

drop policy if exists "users delete own posts" on public.posts;
create policy "users delete own posts" on public.posts
  for delete to authenticated using (author_id = auth.uid());

-- Photo storage: a public bucket; each user uploads into a folder named after their user id.
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

drop policy if exists "users upload own photos" on storage.objects;
create policy "users upload own photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "users delete own photos" on storage.objects;
create policy "users delete own photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
