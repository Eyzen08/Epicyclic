-- Epicyclic — initial schema, row-level security, and order creation RPC.
-- Apply with `supabase db push` (CLI) or paste into the Supabase SQL editor.
-- This migration creates the full data model the Flutter app expects.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Catalog
-- ---------------------------------------------------------------------------

create table if not exists public.categories (
  id text primary key,
  name text not null,
  icon text not null default 'gaming',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id text primary key,
  slug text not null unique,
  name text not null,
  brand text not null default 'Epicyclic',
  tagline text not null default '',
  description text not null default '',
  rating numeric(2, 1) not null default 0 check (rating >= 0 and rating <= 5),
  review_count integer not null default 0 check (review_count >= 0),
  features text[] not null default '{}',
  specs text[] not null default '{}',
  is_featured boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.product_variants (
  product_id text not null references public.products (id) on delete cascade,
  id text not null,
  name text not null,
  color_hex text not null default '#3A3A3C',
  price_cents integer not null check (price_cents >= 0),
  stock integer not null default 0 check (stock >= 0),
  sku text,
  primary key (product_id, id)
);

create table if not exists public.product_images (
  id bigint generated always as identity primary key,
  product_id text not null references public.products (id) on delete cascade,
  url text not null,
  sort_order integer not null default 0,
  unique (product_id, sort_order)
);

create table if not exists public.product_categories (
  product_id text not null references public.products (id) on delete cascade,
  category_id text not null references public.categories (id) on delete cascade,
  primary key (product_id, category_id)
);

-- ---------------------------------------------------------------------------
-- Accounts
-- ---------------------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  phone text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  full_name text not null,
  line1 text not null,
  line2 text,
  city text not null,
  state text not null,
  postal_code text not null,
  country text not null default 'United States',
  phone text not null default '',
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists addresses_user_idx on public.addresses (user_id);
create trigger addresses_set_updated_at
before update on public.addresses
for each row execute function public.set_updated_at();

-- Keep exactly one default address per user.
create unique index if not exists addresses_one_default_idx
on public.addresses (user_id)
where is_default;

-- Create a profile row for every new auth user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Orders and notifications
-- ---------------------------------------------------------------------------

create sequence if not exists public.order_number_seq start with 20482;

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  order_number text not null unique,
  status text not null default 'processing'
    check (
      status in (
        'placed',
        'confirmed',
        'processing',
        'shipped',
        'out_for_delivery',
        'delivered',
        'cancelled'
      )
    ),
  subtotal_cents integer not null check (subtotal_cents >= 0),
  delivery_cents integer not null default 0 check (delivery_cents >= 0),
  discount_cents integer not null default 0 check (discount_cents >= 0),
  total_cents integer not null check (total_cents >= 0),
  payment_method text not null default 'Card',
  contact_email text not null default '',
  promo_code text,
  shipping_address jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists orders_user_created_idx
on public.orders (user_id, created_at desc);

create trigger orders_set_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

create table if not exists public.order_items (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id text not null,
  variant_id text not null,
  product_name text not null,
  variant_name text not null default '',
  image_url text not null default '',
  unit_price_cents integer not null check (unit_price_cents >= 0),
  quantity integer not null check (quantity > 0)
);

create index if not exists order_items_order_idx on public.order_items (order_id);

create table if not exists public.order_status_events (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders (id) on delete cascade,
  status text not null
    check (
      status in (
        'placed',
        'confirmed',
        'processing',
        'shipped',
        'out_for_delivery',
        'delivered',
        'cancelled'
      )
    ),
  title text not null,
  description text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists order_status_events_order_idx
on public.order_status_events (order_id, created_at);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  body text not null default '',
  type text not null default 'account'
    check (type in ('order', 'welcome', 'promo', 'account')),
  read boolean not null default false,
  order_id uuid references public.orders (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_created_idx
on public.notifications (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Row-level security
-- ---------------------------------------------------------------------------

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.product_images enable row level security;
alter table public.product_categories enable row level security;
alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_status_events enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "Catalog categories are readable" on public.categories;
create policy "Catalog categories are readable"
on public.categories for select
to anon, authenticated
using (true);

drop policy if exists "Catalog products are readable" on public.products;
create policy "Catalog products are readable"
on public.products for select
to anon, authenticated
using (is_active);

drop policy if exists "Catalog variants are readable" on public.product_variants;
create policy "Catalog variants are readable"
on public.product_variants for select
to anon, authenticated
using (true);

drop policy if exists "Catalog images are readable" on public.product_images;
create policy "Catalog images are readable"
on public.product_images for select
to anon, authenticated
using (true);

drop policy if exists "Catalog links are readable" on public.product_categories;
create policy "Catalog links are readable"
on public.product_categories for select
to anon, authenticated
using (true);

drop policy if exists "Users read their own profile" on public.profiles;
create policy "Users read their own profile"
on public.profiles for select
to authenticated
using (auth.uid() = id);

drop policy if exists "Users insert their own profile" on public.profiles;
create policy "Users insert their own profile"
on public.profiles for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "Users update their own profile" on public.profiles;
create policy "Users update their own profile"
on public.profiles for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users read their own addresses" on public.addresses;
create policy "Users read their own addresses"
on public.addresses for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users create their own addresses" on public.addresses;
create policy "Users create their own addresses"
on public.addresses for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users update their own addresses" on public.addresses;
create policy "Users update their own addresses"
on public.addresses for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users delete their own addresses" on public.addresses;
create policy "Users delete their own addresses"
on public.addresses for delete
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users read their own orders" on public.orders;
create policy "Users read their own orders"
on public.orders for select
to authenticated
using (auth.uid() = user_id);

-- Orders are written only by the security-definer create_order function.
-- No insert/update/delete policies exist on purpose.

drop policy if exists "Users read their own order items" on public.order_items;
create policy "Users read their own order items"
on public.order_items for select
to authenticated
using (
  exists (
    select 1
    from public.orders
    where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
  )
);

drop policy if exists "Users read their own order events" on public.order_status_events;
create policy "Users read their own order events"
on public.order_status_events for select
to authenticated
using (
  exists (
    select 1
    from public.orders
    where orders.id = order_status_events.order_id
      and orders.user_id = auth.uid()
  )
);

drop policy if exists "Users read their own notifications" on public.notifications;
create policy "Users read their own notifications"
on public.notifications for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users mark their own notifications read" on public.notifications;
create policy "Users mark their own notifications read"
on public.notifications for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Notifications are inserted by trusted server-side code only.

-- ---------------------------------------------------------------------------
-- Order creation
-- ---------------------------------------------------------------------------

create or replace function public.create_order(
  p_items jsonb,
  p_address jsonb,
  p_payment_method text,
  p_contact_email text,
  p_promo_code text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_item jsonb;
  v_product_id text;
  v_variant_id text;
  v_quantity integer;
  v_product public.products%rowtype;
  v_variant public.product_variants%rowtype;
  v_image text;
  v_subtotal integer := 0;
  v_discount integer := 0;
  v_promo text := nullif(upper(trim(coalesce(p_promo_code, ''))), '');
  v_order_id uuid;
  v_order_number text;
  v_payment text := trim(coalesce(p_payment_method, ''));
  v_email text := trim(coalesce(p_contact_email, ''));
begin
  if v_user is null then
    raise exception 'Sign in to place an order.';
  end if;

  if p_items is null
     or jsonb_typeof(p_items) <> 'array'
     or jsonb_array_length(p_items) = 0 then
    raise exception 'Your cart is empty.';
  end if;

  if p_address is null
     or coalesce(trim(p_address ->> 'full_name'), '') = ''
     or coalesce(trim(p_address ->> 'line1'), '') = ''
     or coalesce(trim(p_address ->> 'city'), '') = ''
     or coalesce(trim(p_address ->> 'state'), '') = ''
     or coalesce(trim(p_address ->> 'postal_code'), '') = '' then
    raise exception 'A complete delivery address is required.';
  end if;

  if v_payment = '' then
    raise exception 'Choose a payment method.';
  end if;

  if v_email = '' or position('@' in v_email) = 0 then
    raise exception 'A valid contact email is required.';
  end if;

  if v_promo is not null and v_promo <> 'EPIC10' then
    raise exception 'That promo code is not valid.';
  end if;

  v_order_number := 'EP-' || nextval('public.order_number_seq')::text;

  insert into public.orders (
    user_id,
    order_number,
    status,
    subtotal_cents,
    delivery_cents,
    discount_cents,
    total_cents,
    payment_method,
    contact_email,
    promo_code,
    shipping_address
  ) values (
    v_user,
    v_order_number,
    'processing',
    0,
    0,
    0,
    0,
    v_payment,
    v_email,
    v_promo,
    jsonb_build_object(
      'id', coalesce(p_address ->> 'id', 'checkout'),
      'full_name', trim(p_address ->> 'full_name'),
      'line1', trim(p_address ->> 'line1'),
      'line2', nullif(trim(coalesce(p_address ->> 'line2', '')), ''),
      'city', trim(p_address ->> 'city'),
      'state', trim(p_address ->> 'state'),
      'postal_code', trim(p_address ->> 'postal_code'),
      'country', coalesce(nullif(trim(coalesce(p_address ->> 'country', '')), ''), 'United States'),
      'phone', coalesce(trim(p_address ->> 'phone'), '')
    )
  )
  returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := nullif(trim(coalesce(v_item ->> 'product_id', '')), '');
    v_variant_id := nullif(trim(coalesce(v_item ->> 'variant_id', '')), '');
    v_quantity := coalesce((v_item ->> 'quantity')::integer, 0);

    if v_product_id is null or v_variant_id is null then
      raise exception 'Cart items must include a product and variant.';
    end if;

    if v_quantity < 1 or v_quantity > 20 then
      raise exception 'Item quantities must be between 1 and 20.';
    end if;

    select *
    into v_product
    from public.products
    where id = v_product_id
      and is_active
    for share;

    if not found then
      raise exception 'One of the products in your cart is no longer available.';
    end if;

    select *
    into v_variant
    from public.product_variants
    where product_id = v_product_id
      and id = v_variant_id
    for update;

    if not found then
      raise exception '% is no longer available in that option.', v_product.name;
    end if;

    if v_variant.stock < v_quantity then
      raise exception '% (%) only has % left.',
        v_product.name, v_variant.name, v_variant.stock;
    end if;

    select url
    into v_image
    from public.product_images
    where product_id = v_product_id
    order by sort_order asc
    limit 1;

    insert into public.order_items (
      order_id,
      product_id,
      variant_id,
      product_name,
      variant_name,
      image_url,
      unit_price_cents,
      quantity
    ) values (
      v_order_id,
      v_product.id,
      v_variant.id,
      v_product.name,
      v_variant.name,
      coalesce(v_image, ''),
      v_variant.price_cents,
      v_quantity
    );

    update public.product_variants
    set stock = stock - v_quantity
    where product_id = v_product_id
      and id = v_variant_id
      and stock >= v_quantity;

    if not found then
      raise exception '% (%) no longer has enough stock.', v_product.name, v_variant.name;
    end if;

    v_subtotal := v_subtotal + (v_variant.price_cents * v_quantity);
  end loop;

  if v_promo = 'EPIC10' then
    v_discount := round(v_subtotal * 0.10)::integer;
  end if;

  update public.orders
  set subtotal_cents = v_subtotal,
      delivery_cents = 0,
      discount_cents = v_discount,
      total_cents = v_subtotal - v_discount
  where id = v_order_id;

  insert into public.order_status_events (order_id, status, title, description, created_at)
  values
    (
      v_order_id,
      'placed',
      'Order placed',
      'We received your order.',
      now() - interval '2 minutes'
    ),
    (
      v_order_id,
      'confirmed',
      'Confirmed',
      'Your order was confirmed.',
      now() - interval '1 minute'
    ),
    (
      v_order_id,
      'processing',
      'Processing',
      'We''re preparing your order.',
      now()
    );

  insert into public.notifications (user_id, title, body, type, order_id)
  values (
    v_user,
    'Order confirmed',
    'Order #' || v_order_number || ' is being prepared.',
    'order',
    v_order_id
  );

  return v_order_id;
end;
$$;

revoke all on function public.create_order(jsonb, jsonb, text, text, text) from public;
revoke all on function public.create_order(jsonb, jsonb, text, text, text) from anon;
grant execute on function public.create_order(jsonb, jsonb, text, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

grant usage on schema public to anon, authenticated;

grant select on public.categories,
  public.products,
  public.product_variants,
  public.product_images,
  public.product_categories
to anon, authenticated;

grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.addresses to authenticated;
grant select on public.orders, public.order_items, public.order_status_events to authenticated;
grant select, update on public.notifications to authenticated;
