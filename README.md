# Cooking Bible — a shared cooking blog

Anyone can add a recipe with photos (no account needed). The site arranges each post into a recipe page (cover photo, ingredient checklist, numbered steps with photos, tips).

- **Website:** static Astro site hosted free on GitHub Pages → https://panreta.github.io/Cooking-blog/
- **Recipes and photos:** [Supabase](https://supabase.com) (free tier)

## One-time setup

### 1. Create the Supabase backend
1. Sign up at https://supabase.com and create a new project.
2. Open **SQL Editor → New query**, paste everything from [`supabase/schema.sql`](supabase/schema.sql), and click **Run**.
3. Click **Connect** at the top of the dashboard (or open **Project Settings → Data API** and **Project Settings → API Keys**) and copy the **Project URL** and the **publishable** key (or legacy **anon** key — never the secret key) into [`src/config.ts`](src/config.ts).

### 2. Turn on GitHub Pages
1. Push this repo to GitHub.
2. In the repo, go to **Settings → Pages → Build and deployment → Source** and choose **GitHub Actions**.
3. Every push to `main` now rebuilds and publishes the site (see `.github/workflows/deploy.yml`).

Posts are stored in Supabase, so new recipes show up immediately and don't need a redeploy. You only push when you change the site's code or design.

## Working on the code locally

```sh
npm install
npm run dev    # http://localhost:4321/Cooking-blog/
```

## Where things live

| File | What it does |
| --- | --- |
| `src/pages/index.astro` | Home feed: latest recipe featured, the rest in a grid, category filters |
| `src/pages/post.astro` | Single recipe page (`/post/?id=…`), with Edit/Delete buttons |
| `src/pages/new.astro` | Form to create or edit a post |
| `src/styles/global.css` | Colors, fonts, layout |
| `supabase/schema.sql` | Database table, security rules, photo bucket |

Permissions: there is no login. Anyone who visits the site can add, edit, or delete any recipe and upload photos (images up to 10 MB). If spam becomes a problem, accounts can be added back.
