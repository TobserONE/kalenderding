-- Einmalig im Supabase SQL-Editor ausführen (Dashboard → SQL Editor → New query)
-- Legt die Tabelle für die Tracker-Einträge an und sorgt dafür,
-- dass jeder Nutzer ausschließlich seine eigenen Daten lesen/schreiben kann.

create table public.entries (
  user_id    uuid   not null references auth.users (id) on delete cascade,
  day        text   not null,          -- "JJJJ-MM-TT" oder "_settings"
  data       jsonb,                    -- Eintrag; null = gelöscht (Tombstone)
  updated_at bigint not null default 0, -- Zeitstempel in Millisekunden (vom Gerät gesetzt)
  primary key (user_id, day)
);

alter table public.entries enable row level security;

create policy "Nutzer sehen nur eigene Zeilen"
  on public.entries
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
