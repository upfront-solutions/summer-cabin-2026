-- Summer Cabin 2026: paste this whole file into the Supabase SQL Editor and press Run.
-- Creates the two tables the leaderboard needs, and locks down what guests can do.

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

-- Guests may read everything, add scores and social points, and delete a score attempt
-- (that is the "delete a bad run" button). Nothing can be edited, and social points
-- can never be taken back once given.
create policy "anyone can read scores"   on scores for select using (true);
create policy "anyone can add scores"    on scores for insert with check (true);
create policy "anyone can delete scores" on scores for delete using (true);
create policy "anyone can read social"   on social for select using (true);
create policy "anyone can add social"    on social for insert with check (true);
