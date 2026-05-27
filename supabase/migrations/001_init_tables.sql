-- 001_init_tables.sql
-- 断舍离消费助手数据库初始化

-- profiles 表
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamp with time zone default now()
);

-- purchase_records 表
create table purchase_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text,
  order_time timestamp with time zone,
  item_name text not null,
  quantity numeric default 1,
  amount numeric,
  category text,
  source_type text default 'screenshot',
  raw_text text,
  image_url text,
  created_at timestamp with time zone default now()
);

-- inventory_items 表
create table inventory_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  item_name text not null,
  category text,
  quantity numeric default 1,
  last_purchase_time timestamp with time zone,
  status text default 'enough',
  source_type text default 'manual',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- wish_items 表
create table wish_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  item_name text not null,
  item_image text,
  item_price numeric,
  category text,
  reason text,
  ai_advice_type text,
  ai_advice_text text,
  status text default 'pending',
  cooling_end_time timestamp with time zone,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 创建索引
create index idx_purchase_records_user_id on purchase_records(user_id);
create index idx_purchase_records_order_time on purchase_records(order_time desc);
create index idx_purchase_records_category on purchase_records(category);
create index idx_inventory_items_user_id on inventory_items(user_id);
create index idx_inventory_items_category on inventory_items(category);
create index idx_wish_items_user_id on wish_items(user_id);
create index idx_wish_items_status on wish_items(status);
create index idx_wish_items_created_at on wish_items(created_at desc);

-- RLS 策略：profiles
alter table profiles enable row level security;

create policy "Users can view own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- RLS 策略：purchase_records
alter table purchase_records enable row level security;

create policy "Users can view own purchase records"
  on purchase_records for select
  using (auth.uid() = user_id);

create policy "Users can insert own purchase records"
  on purchase_records for insert
  with check (auth.uid() = user_id);

create policy "Users can update own purchase records"
  on purchase_records for update
  using (auth.uid() = user_id);

create policy "Users can delete own purchase records"
  on purchase_records for delete
  using (auth.uid() = user_id);

-- RLS 策略：inventory_items
alter table inventory_items enable row level security;

create policy "Users can view own inventory"
  on inventory_items for select
  using (auth.uid() = user_id);

create policy "Users can insert own inventory"
  on inventory_items for insert
  with check (auth.uid() = user_id);

create policy "Users can update own inventory"
  on inventory_items for update
  using (auth.uid() = user_id);

create policy "Users can delete own inventory"
  on inventory_items for delete
  using (auth.uid() = user_id);

-- RLS 策略：wish_items
alter table wish_items enable row level security;

create policy "Users can view own wish items"
  on wish_items for select
  using (auth.uid() = user_id);

create policy "Users can insert own wish items"
  on wish_items for insert
  with check (auth.uid() = user_id);

create policy "Users can update own wish items"
  on wish_items for update
  using (auth.uid() = user_id);

create policy "Users can delete own wish items"
  on wish_items for delete
  using (auth.uid() = user_id);

-- 触发器：自动创建profile
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
