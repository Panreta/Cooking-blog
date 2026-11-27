# CLAUDE.md

Shared cooking blog: logged-in users upload photos and text through a web form, and the site arranges each post into a recipe page. The owner wants friends to post from the browser without touching the repo.

## Architecture

- **Frontend:** Astro 7 static site, deployed to GitHub Pages at `https://panreta.github.io/Cooking-blog/` by `.github/workflows/deploy.yml` on every push to `main`.
- **Backend:** Supabase (free tier) handles auth (email/password), the `posts` table, and the public `photos` storage bucket. GitHub Pages can't store data, so all dynamic data lives in Supabase.
- **Data loading:** all post data is fetched **client-side** in `<script>` tags with `@supabase/supabase-js`. Astro only builds 4 static shells, so new posts appear without a rebuild.

## Key conventions

- **Base path:** `astro.config.mjs` sets `base: '/Cooking-blog'` and `trailingSlash: 'always'`. Always build internal links with `url()` from `src/lib/util.ts`; never hardcode `/...`.
- **No dynamic routes:** a static host can't serve them, so a post page is `post/?id=<uuid>` and the edit page is `new/?id=<uuid>`.
- **Global styles only:** posts are rendered via `innerHTML`, which Astro's scoped styles don't reach, so all styles live in `src/styles/global.css`. Colors are CSS variables on `:root`, with a dark-mode override.
- **Escape user content:** user input is escaped with `esc()` before it goes into HTML. `paragraphs()` turns blank-line-separated text into `<p>`. Never insert raw user strings.
- **Form fields:** read them with `form.elements.namedItem(name)` (the `field()` helper), not `form.name` / `form.email`.
- **Photos:** resized in the browser (max 1800px, JPEG 0.85) and uploaded to `photos/<user_id>/<uuid>.jpg` (`uploadPhoto` in `src/lib/supabase.ts`).
- **Permissions:** enforced by row-level security in `supabase/schema.sql`. Anyone can read; authenticated users insert as themselves; only the author can update or delete their own posts and photos. Any schema change must be re-run by hand in the Supabase SQL Editor.

## Files

- `src/pages/index.astro`: feed (latest post as hero, grid of the rest, tag filter chips via `?tag=`)
- `src/pages/post.astro`: recipe page (cover, recipe card with facts and ingredient checklist, story, numbered steps with photos, tip); Edit/Delete shown to the author
- `src/pages/new.astro`: create/edit form; steps are repeatable rows of text plus an optional photo
- `src/pages/login.astro`: log-in / sign-up tabs; sign-up stores `display_name` in user metadata
- `src/layouts/Base.astro`: header nav that toggles on auth state (`data-auth="in|out"`)
- `src/lib/supabase.ts`: client, `Post`/`Step` types, `getUser`, `displayName`, `uploadPhoto`
- `src/config.ts`: Supabase URL and publishable/anon key (public by design; never put the secret/service_role key here)

Post fields: `title, description, cover_url, prep_time, cook_time, servings, tags[], ingredients[], story, steps (jsonb [{text, photo}]), tips, author_id, author_name, created_at`.

## Commands

```sh
npm install
npm run dev     # http://localhost:4321/Cooking-blog/
npm run build   # output in dist/
```

Node >= 22.23 is required by Astro 7; CI uses Node 24.

## Status (as of 2026-11-26)

- Deployed and live. `src/config.ts` is filled in with the owner's Supabase project, and every push to `main` publishes the site.
- The owner works only through GitHub's web UI, not locally.
- `schema.sql` now includes explicit `grant`s, because newer Supabase projects don't auto-grant table access to `anon`/`authenticated` (without them the site shows "permission denied for table posts").
- Signup, upload, and save have **not** been tested end-to-end yet.
- Free-tier note: Supabase pauses a project after 7 days with no activity. The data is kept and can be restored with one click within 90 days. A keep-alive GitHub Action that pings Supabase on a schedule was offered but not yet added.
- The site name "Cook Bible" appears in `Base.astro`, `post.astro` (`document.title`), and the README.
