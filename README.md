# Cook Bible — a shared cooking blog

Anyone with an account can log in, upload photos, and write a recipe. The site arranges each post into a recipe page (cover photo, ingredient checklist, numbered steps with photos, tips).

- **Website:** static Astro site hosted free on GitHub Pages → https://panreta.github.io/Cooking-blog/
- **Accounts, posts, photos:** [Supabase](https://supabase.com) (free tier)

## One-time setup

### 1. Create the Supabase backend
1. Sign up at https://supabase.com and create a new project.
2. Open **SQL Editor → New query**, paste everything from [`supabase/schema.sql`](supabase/schema.sql), and click **Run**.
3. Click **Connect** at the top of the dashboard (or open **Project Settings → Data API** and **Project Settings → API Keys**) and copy the **Project URL** and the **publishable** key (or legacy **anon** key — never the secret key) into [`src/config.ts`](src/config.ts).
4. Go to **Authentication → URL Configuration** and set **Site URL** to `https://panreta.github.io/Cooking-blog/` so that confirmation-email links point to your site.
   - Optional: under **Authentication → Providers → Email**, turn off "Confirm email" if you want people to post right after signing up.

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
| `src/pages/post.astro` | Single recipe page (`/post/?id=…`), with Edit/Delete for the author |
| `src/pages/new.astro` | Form to create or edit a post |
| `src/pages/login.astro` | Log in / sign up |
| `src/styles/global.css` | Colors, fonts, layout |
| `supabase/schema.sql` | Database table, security rules, photo bucket |

Security: anyone can read posts, but only logged-in users can post, and only the author can edit or delete their own posts and photos. These rules are enforced in the database, not just in the page.
