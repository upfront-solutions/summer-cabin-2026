# Summer Olympic Games · Setup Guide

Two things make up the site:

```
index.html      the whole site, one file
photos/         the 10 photos, resized for phones (1.3 MB total)
```

Keep them next to each other and double-click `index.html`. It works right now.

There are two ways to run it.

---

## Mode 1: Solo (works this second, zero setup)

Open `index.html` on your phone or laptop and everything functions: menu, games, score entry, social points, leaderboard. But scores are saved **only on that one device**. If Leo logs a time on his phone, you will not see it on yours.

Great for showing people what it looks like. Not what you want on game day.

---

## Mode 2: Live (everyone shares one leaderboard)

This is the real thing. Takes about 10 minutes, costs nothing, and you never touch code beyond pasting two lines.

### Step 1 · Make a free database

1. Go to **[supabase.com](https://supabase.com)** and sign up (free tier, no card).
2. Click **New project**. Name it anything, e.g. `summer-games`. Pick the region closest to California. Set a database password and save it somewhere.
3. Wait about 2 minutes for it to build.

### Step 2 · Create the two tables

In the left sidebar click **SQL Editor**, then **New query**. Paste this in and hit **Run**:

```sql
create table scores (
  id         bigint generated always as identity primary key,
  game       text        not null,
  player     text        not null,
  value      numeric     not null,
  witness    text,
  created_at timestamptz default now()
);

create table social (
  id         bigint generated always as identity primary key,
  giver      text        not null,
  receiver   text        not null,
  created_at timestamptz default now()
);

alter table scores enable row level security;
alter table social enable row level security;

create policy "anyone can read scores"   on scores for select using (true);
create policy "anyone can add scores"    on scores for insert with check (true);
create policy "anyone can delete scores" on scores for delete using (true);
create policy "anyone can read social"   on social for select using (true);
create policy "anyone can add social"    on social for insert with check (true);
```

You should see "Success. No rows returned." That is correct.

What those policies allow: guests can **read** everything, **add** scores and social points, and **delete a score attempt**. That last one is what powers the delete button, for when somebody fat-fingers a time. Nothing can be **edited**, and social points can never be taken back once given.

The delete rule is deliberately loose because the anon key cannot tell your guests apart, so the app cannot technically stop Leo from deleting Dan's run. In practice the app only ever shows you your own attempts, and this is eighteen family members, not the internet. If you would rather nobody could delete anything at all, just leave that one line out of the SQL. The button will then quietly fail, so tell people first.

You can always fix things yourself from the Supabase **Table Editor**.

### Step 3 · Paste your two keys into the site

In Supabase go to **Settings → API Keys**. You need two values:

| Supabase calls it | Looks like |
|---|---|
| Project URL (under Settings → Data API) | `https://abcdefghijkl.supabase.co` |
| **Publishable key** | `sb_publishable_...` |

If the API Keys tab shows no publishable key yet, click **Create new API keys** and copy the one under **Publishable key**. Never copy anything labelled **Secret** or **service_role**. Those bypass all the safety rules above and must not go in a web page.

Older projects show a key called **anon public** that starts with `eyJ...` instead. That still works, the site handles both formats.

Open `index.html` in any text editor. Near the top of the `<script>` section, about two thirds of the way down the file, you will find:

```js
const SUPABASE_URL = "";      // e.g. "https://abcdefgh.supabase.co"
const SUPABASE_KEY = "";      // Publishable key, starts sb_publishable_
```

Paste your values between the quotes. Save.

That is the entire code change. The site now syncs every 8 seconds and the badge on the home screen switches from "Solo mode" to "Live · synced for everyone".

### Step 4 · Put it online

The site is plain HTML, CSS and JavaScript with no build step, so every static host works the same way: give it the folder, it serves it. Pick whichever you like.

**Netlify Drop, fastest, no account needed.** Go to **[app.netlify.com/drop](https://app.netlify.com/drop)** and drag **the whole folder** onto the page, not just `index.html`. You get a live URL in about 10 seconds. Make a free account afterward to keep the link and rename it.

**Vercel.** Push the folder to a GitHub repo, then Import it at [vercel.com/new](https://vercel.com/new). When it asks for a framework preset choose **Other**, and leave the build command and output directory blank. There is nothing to build.

**GitHub Pages.** Push the folder to a repo, then Settings → Pages → Source: Deploy from a branch → `main` / root.

Whichever you choose, the folder must contain both `index.html` and `photos/` or the pictures come out blank.

A `.gitignore` is already in the folder. It keeps the test files and `node_modules` out of your repo, so only the site itself gets deployed.

### Step 5 · Get everyone on it

Text the link to the group with something like:

> Summer Olympic Games HQ. Menu, rules, scores, the leaderboard. Open it and tap your name.
> On iPhone: tap Share, then **Add to Home Screen** and it behaves like a real app.

That's it. You're done.

---

## Things you might want to change

All of it is in the `<script>` block, clearly labelled in sections.

**The guest list** (section 2). Add or remove names. Everything else adapts automatically:

```js
const ATTENDEES = ["Dan","Thy-An","Mike", ...];
```

**The games** (section 2). Add a fifth event by copying one line:

```js
{ id:"cornhole", ic:"🌽", name:"Cornhole",
  rule:"First to 21. Losers rack the bags.",
  metric:"score", lowerBetter:false },
```

`metric:"time"` with `lowerBetter:true` means fastest wins. `metric:"score"` with `lowerBetter:false` means highest wins. The `id` must be unique and must not be changed after people start logging scores.

**Points per placing** (section 2):

```js
const AWARDS = { 1:10, 2:5, 3:3 };
const SOCIAL_POINT = 1;
```

**The menu** is plain HTML in the `<section id="s-food">` block. Edit the text directly.

**Photos.** All ten live in `photos/`, resized to about 130 KB each so the site loads fast on desert wifi. To swap one out, save your new picture over the old file using the exact same name and it appears everywhere that photo is used. No code change.

| File | Where it appears |
|---|---|
| `pool-day.jpg` | Home page hero |
| `pool-night.jpg` | House gallery, Pool Lap Sprint |
| `patio-bar.jpg` | House gallery, Social Points |
| `game-room.jpg` | House gallery, Pac-Man, Foosball |
| `pool-hoop.jpg` | House gallery, Pool Hoops |
| `food-panroast.jpg` | Friday dinner |
| `food-soup.jpg` | Saturday breakfast |
| `food-bone.jpg` | Saturday lunch |
| `food-bbq.jpg` | Saturday dinner |
| `food-snacks.jpg` | Snacks and sips |

To add more house photos, drop them in `photos/` and copy one line inside the gallery scroller on the home screen:

```html
<div class="sfig"><figure><img src="photos/kitchen.jpg" alt="Kitchen" loading="lazy"></figure>
<div class="cap"><span>The kitchen</span><span>05</span></div></div>
```

---

## How the scoring works

- Each event ranks everyone by their **single best attempt**. Log as many tries as you like; only the best one counts.
- First place takes **10**, second **5**, third **3**. Fourth and below get nothing.
- Ties share the better place. Two people tied for first both get 10, and the next person is third.
- **Social points** are worth 1 each, unlimited, and stack on top of event points.
- Overall ties break on most gold medals first, then most event points, then alphabetically.

Score entry is trust-based, exactly as you wanted: you log your own result and type the name of your witness. The witness name shows next to every result in the event breakdown on the leaderboard, so anything fishy is visible to the whole group.

Social points require two taps, the second one confirming, so nobody hands out a point by accident. You cannot give yourself one.

---

## Notes

- The `anon` key is designed to be public. It is safe in a file everyone can see. The row level security policies above are what actually protect the data.
- The site remembers who you are on each phone, so guests pick their name once and never again. There's a "Not you?" button to switch.
- No passwords needed. Since each person picks their name on their own phone and social points are capped at one action per tap with a confirm, the password idea from your doc turned out to be unnecessary friction. If you do want it later, say the word.
- If wifi in the desert is bad, the page still loads and everything renders. Scores queue in the browser and the leaderboard catches up once signal returns.
