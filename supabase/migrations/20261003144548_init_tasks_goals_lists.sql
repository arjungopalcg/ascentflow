-- Tasks
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null,
  description text not null default '',
  category text not null default 'Other',
  priority text not null default 'medium' check (priority in ('high', 'medium', 'low')),
  due_date timestamptz,
  due_time text not null default '',
  is_completed boolean not null default false,
  created_at timestamptz not null default now()
);

-- Goals
create table public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null,
  category text not null default 'Personal',
  target_type text not null default 'numeric' check (target_type in ('numeric', 'yesNo', 'dailyHabit')),
  deadline timestamptz,
  icon text not null default 'target',
  progress_color bigint not null default 4284711589,
  progress double precision not null default 0,
  target double precision not null default 100,
  unit text not null default '',
  created_at timestamptz not null default now()
);

-- Lists
create table public.lists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null,
  icon text not null default 'shoppingCart',
  members text[] not null default array['A'],
  items text[] not null default '{}',
  created_at timestamptz not null default now()
);

create index tasks_user_id_idx on public.tasks (user_id);
create index goals_user_id_idx on public.goals (user_id);
create index lists_user_id_idx on public.lists (user_id);

alter table public.tasks enable row level security;
alter table public.goals enable row level security;
alter table public.lists enable row level security;

-- Owner-only policies
create policy "Users read own tasks" on public.tasks for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users insert own tasks" on public.tasks for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Users update own tasks" on public.tasks for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users delete own tasks" on public.tasks for delete to authenticated using ((select auth.uid()) = user_id);

create policy "Users read own goals" on public.goals for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users insert own goals" on public.goals for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Users update own goals" on public.goals for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users delete own goals" on public.goals for delete to authenticated using ((select auth.uid()) = user_id);

create policy "Users read own lists" on public.lists for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users insert own lists" on public.lists for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Users update own lists" on public.lists for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users delete own lists" on public.lists for delete to authenticated using ((select auth.uid()) = user_id);
