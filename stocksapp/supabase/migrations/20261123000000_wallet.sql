-- Wallet schema for the stocks app.
-- Run this once in the Supabase dashboard (SQL Editor) or with `supabase db push`.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null,
  email text not null unique,
  virtual_balance double precision not null check (virtual_balance >= 0),
  created_at timestamptz not null default now()
);

create table public.holdings (
  user_id uuid not null references public.profiles (id) on delete cascade,
  symbol text not null,
  quantity double precision not null check (quantity > 0),
  average_purchase_price double precision not null,
  primary key (user_id, symbol)
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  symbol text not null,
  type text not null check (type in ('BUY', 'SELL')),
  quantity double precision not null check (quantity > 0),
  price_at_execution double precision not null,
  timestamp timestamptz not null default now()
);

create index transactions_user_time_idx on public.transactions (user_id, timestamp desc);

-- Users can only read their own rows; all writes go through the functions below.
alter table public.profiles enable row level security;
alter table public.holdings enable row level security;
alter table public.transactions enable row level security;

create policy "read own profile" on public.profiles
  for select using (auth.uid() = id);
create policy "read own holdings" on public.holdings
  for select using (auth.uid() = user_id);
create policy "read own transactions" on public.transactions
  for select using (auth.uid() = user_id);

-- Creates the caller's profile with the starting balance if it doesn't exist.
create or replace function public.ensure_wallet(p_username text, p_starting_balance double precision)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Not signed in';
  end if;
  insert into profiles (id, username, email, virtual_balance)
  select v_uid, p_username, u.email, p_starting_balance
  from auth.users u
  where u.id = v_uid
  on conflict (id) do nothing;
end;
$$;

-- Atomically buys shares: checks balance, debits it, updates the holding's
-- weighted average price and records the transaction.
create or replace function public.buy_stock(p_symbol text, p_quantity double precision, p_price double precision)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_cost double precision := p_quantity * p_price;
  v_balance double precision;
begin
  if v_uid is null then raise exception 'Not signed in'; end if;
  if p_quantity <= 0 or p_price <= 0 then raise exception 'Invalid order'; end if;

  select virtual_balance into v_balance from profiles where id = v_uid for update;
  if not found then raise exception 'User not found'; end if;
  if v_balance < v_cost then raise exception 'Insufficient balance'; end if;

  update profiles set virtual_balance = virtual_balance - v_cost where id = v_uid;

  insert into holdings (user_id, symbol, quantity, average_purchase_price)
  values (v_uid, p_symbol, p_quantity, p_price)
  on conflict (user_id, symbol) do update set
    average_purchase_price =
      (holdings.quantity * holdings.average_purchase_price + excluded.quantity * excluded.average_purchase_price)
      / (holdings.quantity + excluded.quantity),
    quantity = holdings.quantity + excluded.quantity;

  insert into transactions (user_id, symbol, type, quantity, price_at_execution)
  values (v_uid, p_symbol, 'BUY', p_quantity, p_price);
end;
$$;

-- Atomically sells shares: checks the holding, credits the balance, reduces
-- or removes the holding and records the transaction.
create or replace function public.sell_stock(p_symbol text, p_quantity double precision, p_price double precision)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_owned double precision;
begin
  if v_uid is null then raise exception 'Not signed in'; end if;
  if p_quantity <= 0 or p_price <= 0 then raise exception 'Invalid order'; end if;

  select quantity into v_owned from holdings
  where user_id = v_uid and symbol = p_symbol for update;
  if not found then raise exception 'You do not own this stock'; end if;
  if v_owned < p_quantity then raise exception 'Not enough shares to sell'; end if;

  update profiles set virtual_balance = virtual_balance + p_quantity * p_price where id = v_uid;

  if v_owned - p_quantity <= 0 then
    delete from holdings where user_id = v_uid and symbol = p_symbol;
  else
    update holdings set quantity = quantity - p_quantity
    where user_id = v_uid and symbol = p_symbol;
  end if;

  insert into transactions (user_id, symbol, type, quantity, price_at_execution)
  values (v_uid, p_symbol, 'SELL', p_quantity, p_price);
end;
$$;

revoke execute on function public.ensure_wallet(text, double precision) from public, anon;
revoke execute on function public.buy_stock(text, double precision, double precision) from public, anon;
revoke execute on function public.sell_stock(text, double precision, double precision) from public, anon;
grant execute on function public.ensure_wallet(text, double precision) to authenticated;
grant execute on function public.buy_stock(text, double precision, double precision) to authenticated;
grant execute on function public.sell_stock(text, double precision, double precision) to authenticated;

-- Live updates for the wallet screen.
alter table public.holdings replica identity full;
alter publication supabase_realtime add table public.profiles, public.holdings, public.transactions;
