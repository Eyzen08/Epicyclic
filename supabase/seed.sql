-- Epicyclic seed data — mirrors assets/data/catalog.json.
-- Re-running this file resets prices, stock, and image URLs to these values.
-- Images use bundled Flutter asset paths so Supabase mode looks correct with
-- the shipped assets. Replace them with Supabase Storage public URLs when you
-- upload your own product photography.

insert into public.categories (id, name, icon, sort_order) values
  ('gaming', 'Gaming', 'gaming', 1),
  ('keyboards', 'Keyboards', 'keyboards', 2),
  ('mice', 'Mice', 'mice', 3),
  ('audio', 'Audio', 'audio', 4)
on conflict (id) do update
set name = excluded.name,
    icon = excluded.icon,
    sort_order = excluded.sort_order;

insert into public.products (
  id, slug, name, brand, tagline, description, rating, review_count,
  features, specs, is_featured, is_active
) values
  (
    'keychron-k2-pro',
    'keychron-k2-pro',
    'Keychron K2 Pro',
    'Keychron',
    'Wireless Mechanical Keyboard',
    $desc$A compact wireless mechanical keyboard with premium build quality and powerful customization. Hot-swappable switches, a solid aluminium frame, and a layout that keeps your desk clean.$desc$,
    4.8,
    126,
    array['Wireless', 'Hot-swappable', 'RGB backlight'],
    array['75% layout', 'Bluetooth 5.1 + USB-C', '4000 mAh battery'],
    true,
    true
  ),
  (
    'keychron-k2',
    'keychron-k2',
    'Keychron K2',
    'Keychron',
    'Wireless Mechanical Keyboard',
    $desc$A 75% wireless mechanical keyboard with tactile switches and a compact footprint. Built for long sessions, with a familiar layout and satisfying feedback.$desc$,
    4.7,
    1200,
    array['Wireless', 'Tactile switches', 'RGB backlight'],
    array['75% layout', 'Bluetooth 5.1', '4000 mAh battery'],
    false,
    true
  ),
  (
    'pulse-wireless-mouse',
    'pulse-wireless-mouse',
    'Epicyclic Pulse Wireless Mouse',
    'Epicyclic',
    'Ultra-Light Wireless Gaming Mouse',
    $desc$A precision wireless mouse built for fast movement and long sessions. The 26,000 DPI sensor and lightweight shell keep every flick controlled.$desc$,
    4.6,
    320,
    array['Wireless', 'Lightweight', '26000 DPI'],
    array['63 g', '70 hour battery', 'USB-C charging'],
    true,
    true
  ),
  (
    'logitech-gpro-x-superlight-2',
    'logitech-gpro-x-superlight-2',
    'Logitech G Pro X Superlight 2',
    'Logitech',
    'Superlight 2 Wireless Mouse',
    $desc$The next generation of the professional-grade Superlight. A 60 gram shell, Hero 2 sensor, and optical switches for competition-level response.$desc$,
    4.8,
    2100,
    array['Wireless', '60 g', '32000 DPI'],
    array['Hero 2 sensor', '95 hour battery', 'USB-C charging'],
    false,
    true
  ),
  (
    'nova-wireless-mouse',
    'nova-wireless-mouse',
    'Nova Wireless Mouse',
    'Epicyclic',
    'Ergonomic Wireless Mouse',
    $desc$An everyday wireless mouse with a sculpted shape, quiet clicks, and a sensor that stays accurate across surfaces. Comfort for the long haul.$desc$,
    4.4,
    218,
    array['Wireless', 'Ergonomic', '12000 DPI'],
    array['80 g', '18 month battery', 'USB receiver'],
    true,
    true
  ),
  (
    'logitech-gpro-x2',
    'logitech-gpro-x2',
    'Logitech G Pro X 2',
    'Logitech',
    'Wireless Gaming Headset',
    $desc$A lightweight wireless headset tuned for competitive play. Graphene drivers, a detachable boom mic, and a comfortable fit for marathon sessions.$desc$,
    4.6,
    893,
    array['Wireless', 'Graphene drivers', 'Detachable mic'],
    array['50 hour battery', '2.4 GHz + Bluetooth', 'USB-C charging'],
    true,
    true
  ),
  (
    'elgato-wave-3',
    'elgato-wave-3',
    'Elgato Wave:3',
    'Elgato',
    'Premium USB Microphone',
    $desc$A broadcast-grade USB condenser microphone with a built-in pop filter and mix control. Clear voice capture for streams, calls, and recordings.$desc$,
    4.7,
    640,
    array['USB-C', 'Cardioid', 'Clipguard'],
    array['24-bit / 96 kHz', 'Built-in pop filter', 'Zero-latency monitoring'],
    true,
    true
  ),
  (
    'blue-yeti',
    'blue-yeti',
    'Blue Yeti',
    'Blue',
    'USB Condenser Microphone',
    $desc$A studio favourite with three condenser capsules and multiple pickup patterns. Plug in, choose a pattern, and sound ready for anything.$desc$,
    4.6,
    512,
    array['USB', 'Three capsules', 'Mute button'],
    array['4 pickup patterns', '16-bit / 48 kHz', 'Headphone output'],
    false,
    true
  )
on conflict (id) do update
set slug = excluded.slug,
    name = excluded.name,
    brand = excluded.brand,
    tagline = excluded.tagline,
    description = excluded.description,
    rating = excluded.rating,
    review_count = excluded.review_count,
    features = excluded.features,
    specs = excluded.specs,
    is_featured = excluded.is_featured,
    is_active = excluded.is_active;

insert into public.product_variants (product_id, id, name, color_hex, price_cents, stock, sku) values
  ('keychron-k2-pro', 'graphite', 'Graphite', '#3A3A3C', 12900, 8, 'K2P-GRA'),
  ('keychron-k2-pro', 'white', 'White', '#F0F0F0', 12900, 5, 'K2P-WHT'),
  ('keychron-k2-pro', 'black', 'Black', '#161618', 12900, 3, 'K2P-BLK'),
  ('keychron-k2-pro', 'pink', 'Pink', '#F4A7B9', 13400, 0, 'K2P-PNK'),
  ('keychron-k2', 'black', 'Black', '#17181C', 12900, 12, 'K2-BLK'),
  ('keychron-k2', 'white', 'White', '#F1F1F1', 12900, 4, 'K2-WHT'),
  ('pulse-wireless-mouse', 'black', 'Black', '#18191D', 7900, 15, 'PLS-BLK'),
  ('pulse-wireless-mouse', 'white', 'White', '#F2F2F2', 7900, 6, 'PLS-WHT'),
  ('logitech-gpro-x-superlight-2', 'black', 'Black', '#111318', 7900, 9, 'GPX2-BLK'),
  ('logitech-gpro-x-superlight-2', 'white', 'White', '#F3F3F3', 7900, 2, 'GPX2-WHT'),
  ('nova-wireless-mouse', 'white', 'White', '#F5F5F5', 5900, 20, 'NVA-WHT'),
  ('nova-wireless-mouse', 'black', 'Black', '#1C1D21', 5900, 11, 'NVA-BLK'),
  ('logitech-gpro-x2', 'black', 'Black', '#18191D', 14900, 7, 'GPX2-HS-BLK'),
  ('elgato-wave-3', 'black', 'Black', '#191A1E', 8900, 10, 'WAVE3-BLK'),
  ('blue-yeti', 'black', 'Black', '#18191D', 12900, 5, 'YETI-BLK')
on conflict (product_id, id) do update
set name = excluded.name,
    color_hex = excluded.color_hex,
    price_cents = excluded.price_cents,
    stock = excluded.stock,
    sku = excluded.sku;

insert into public.product_images (product_id, url, sort_order) values
  ('keychron-k2-pro', 'assets/images/products/keyboard_white.png', 0),
  ('keychron-k2-pro', 'assets/images/products/keyboard_blue.png', 1),
  ('keychron-k2', 'assets/images/products/keyboard_blue.png', 0),
  ('pulse-wireless-mouse', 'assets/images/products/mouse_black.png', 0),
  ('logitech-gpro-x-superlight-2', 'assets/images/products/mouse_black.png', 0),
  ('nova-wireless-mouse', 'assets/images/products/mouse_white.png', 0),
  ('logitech-gpro-x2', 'assets/images/products/headset_gpro.png', 0),
  ('elgato-wave-3', 'assets/images/products/mic_elgato.png', 0),
  ('blue-yeti', 'assets/images/products/mic_yeti.png', 0)
on conflict (product_id, sort_order) do update
set url = excluded.url;

insert into public.product_categories (product_id, category_id) values
  ('keychron-k2-pro', 'keyboards'),
  ('keychron-k2-pro', 'gaming'),
  ('keychron-k2', 'keyboards'),
  ('pulse-wireless-mouse', 'mice'),
  ('pulse-wireless-mouse', 'gaming'),
  ('logitech-gpro-x-superlight-2', 'mice'),
  ('logitech-gpro-x-superlight-2', 'gaming'),
  ('nova-wireless-mouse', 'mice'),
  ('logitech-gpro-x2', 'audio'),
  ('logitech-gpro-x2', 'gaming'),
  ('elgato-wave-3', 'audio'),
  ('blue-yeti', 'audio')
on conflict (product_id, category_id) do nothing;
