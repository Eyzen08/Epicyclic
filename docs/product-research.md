# Product research and price verification

This document records where every product in `assets/data/catalog.json` came
from. The catalog was rebuilt on **2026-11-05** so that each listing, price,
variant, and image is traceable to a real Philippine retailer page.

## Rules used

- A product is included only when the exact model and variant could be matched
  to a live retailer listing with a stated Philippine peso price.
- Prices are copied from the retailer, not estimated or converted from USD.
  Prices with centavos are stored exactly in the catalog as integer centavos
  (for example `₱1,388.89` is `138889`).
- The price source and the image source may be different retailers as long as
  both pages describe the same model and variant. This is noted per product.
- Images are downloaded into `assets/images/products/`; the app does not load
  product photos from a remote URL at runtime.
- Images with retailer watermarks, promotional overlays, or multiple colourways
  in one frame were rejected. Where an EasyPC photo had an `EASYPC` watermark,
  a clean photo of the same model from DataBlitz was used instead.
- No review or rating data was available from these retailers, so every product
  ships with `rating: 0` and `reviewCount: 0`, and the star UI is hidden.
- The `stock` values in the catalog are **demo inventory placeholders** (`10`),
  not live retailer stock counts.

## Verification status

All 29 catalog products are **Verified**: the model, variant, peso price, and a
clean image of the exact model were confirmed. Products that could not meet that
bar were excluded; they are listed at the end of this document.

## Review table

| # | ID | Product | Variant | Price (PHP) | Regular price | Seller | Status |
|---|----|---------|---------|-------------|---------------|--------|--------|
| 1 | `keychron-k8` | Keychron K8 | Red Switch | ₱4,400.00 | ₱4,400.00 | EasyPC | Verified |
| 2 | `aula-f75` | AULA F75 | Black / Gradient Grey | ₱2,595.00 | ₱2,595.00 | DataBlitz | Verified |
| 3 | `redragon-k617-fizz` | Redragon K617 Fizz | Gradient Grey / Blue Switch | ₱1,388.89 | ₱1,440.00 | EasyPC | Verified (discounted) |
| 4 | `steelseries-apex-pro-tkl` | SteelSeries Apex Pro TKL | Black | ₱10,500.00 | ₱10,500.00 | EasyPC | Verified |
| 5 | `royal-kludge-rk-m75` | Royal Kludge RK-M75 | Phantom | ₱2,794.44 | ₱2,925.00 | EasyPC | Verified (discounted) |
| 6 | `logitech-g102` | Logitech G102 LIGHTSYNC | Black | ₱941.00 | ₱1,045.00 | DataBlitz | Verified (discounted) |
| 7 | `razer-deathadder-v3` | Razer DeathAdder V3 | Black | ₱2,833.33 | ₱2,833.33 | EasyPC | Verified |
| 8 | `logitech-g502-x-plus` | Logitech G502 X Plus | Black | ₱6,995.00 | ₱6,995.00 | DataBlitz | Verified |
| 9 | `logitech-gpro-x-superlight-2` | Logitech G Pro X Superlight 2 | Black | ₱6,995.00 | ₱6,995.00 | DataBlitz | Verified |
| 10 | `razer-viper-v3-pro` | Razer Viper V3 Pro | White | ₱9,120.00 | ₱9,120.00 | DataBlitz | Verified |
| 11 | `logitech-g304-x` | Logitech G304 X | Black | ₱2,995.00 | ₱2,995.00 | DataBlitz | Verified |
| 12 | `razer-blackshark-v2-x` | Razer BlackShark V2 X | White | ₱2,350.00 | ₱2,350.00 | DataBlitz | Verified |
| 13 | `hyperx-cloud-iii` | HyperX Cloud III | Black | ₱3,595.00 | ₱3,595.00 | DataBlitz | Verified |
| 14 | `hyperx-cloud-iii-s` | HyperX Cloud III S Wireless | Black | ₱6,250.00 | ₱6,250.00 | DataBlitz | Verified |
| 15 | `steelseries-arctis-nova-pro-wireless` | SteelSeries Arctis Nova Pro Wireless | Black | ₱18,000.00 | ₱18,000.00 | EasyPC | Verified |
| 16 | `razer-kraken-v4-x` | Razer Kraken V4 X | Black | ₱4,695.00 | ₱4,695.00 | DataBlitz | Verified |
| 17 | `razer-goliathus-chroma` | Razer Goliathus Chroma | Black / Medium | ₱2,150.00 | ₱2,150.00 | DataBlitz | Verified |
| 18 | `razer-strider-large-quartz` | Razer Strider Large | Quartz | ₱1,740.00 | ₱1,740.00 | DataBlitz | Verified |
| 19 | `fantech-mp905-luffy` | Fantech ATO MP905 | Luffy | ₱895.00 | ₱895.00 | DataBlitz | Verified |
| 20 | `keychron-desk-mat-ninego` | Keychron Desk Mat | NINEGO Blue (DM-2) | ₱1,390.00 | ₱1,390.00 | DataBlitz | Verified |
| 21 | `razer-base-station-v2-chroma` | Razer Base Station V2 Chroma | Black | ₱3,450.00 | ₱3,450.00 | DataBlitz | Verified |
| 22 | `ugreen-uno-hub` | UGREEN Uno 6-in-1 USB-C Hub | Gray (CM889/75177) | ₱1,133.00 | ₱1,133.00 | DataBlitz | Verified |
| 23 | `inplay-kmt-3` | InPlay KMT-3 | Black | ₱1,183.00 | ₱1,183.00 | EasyPC | Verified |
| 24 | `keychron-palm-rest` | Keychron Silicone Palm Rest | Black (PR43) | ₱950.00 | ₱950.00 | DataBlitz | Verified |
| 25 | `arctic-z1-basic` | Arctic Z1 Basic | Black (AEMNT00039A) | ₱1,150.00 | ₱1,150.00 | DataBlitz | Verified |
| 26 | `hyperx-quadcast-2` | HyperX QuadCast 2 | Black (872V1AA) | ₱6,995.00 | ₱6,995.00 | DataBlitz | Verified |
| 27 | `razer-seiren-v3-mini` | Razer Seiren V3 Mini | Black | ₱2,850.00 | ₱2,850.00 | DataBlitz | Verified |
| 28 | `razer-seiren-v3-chroma` | Razer Seiren V3 Chroma | Black | ₱7,695.00 | ₱7,695.00 | DataBlitz | Verified |
| 29 | `logitech-c922` | Logitech C922 Pro Stream | Black | ₱5,666.00 | ₱5,666.00 | DataBlitz | Verified |

## Source manifest

Legend: **Checked** is the date the retailer page was read. **Availability**
means the item was listed for sale on that page; the Shopify product endpoints
used here did not expose a reliable per-variant stock count.

### Keyboards

| ID | Listing (price source) | Image source | Local asset | Checked | Availability |
|----|------------------------|--------------|-------------|---------|--------------|
| `keychron-k8` | https://easypc.com.ph/products/keychron-k8-rgb-tkl-mechanical-keyboard-red-switch-plastic-gateron-hot-swappable-87-keys-wireless-wired-for-mac-ios-windows-android-type-c-plug-k8h1-4jtp-kek81640 | https://cdn.shopify.com/s/files/1/0101/4864/2879/products/KEK81640-a.jpg | `keychron-k8.jpg` | 2026-11-05 | Listed |
| `aula-f75` | https://ecommerce.datablitz.com.ph/products/aula-f75-rgb-tri-mode-type-c-75-80-key-gasket-structure-hot-swap-mechanical-gaming-keyboard-reaper-switch-black-gradient-grey | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/1_95f4a68b-b9a3-4707-96ff-1febc7d7ffdf.jpg | `aula-f75.jpg` | 2026-11-05 | Listed |
| `redragon-k617-fizz` | https://easypc.com.ph/products/redragon-k617-fizz-60-wired-rgb-gaming-keyboard-blue-switch-gradient-grey | https://cdn.shopify.com/s/files/1/0101/4864/2879/products/Redragon_K617_FIZZ_60_Wired_RGB_Gaming_Keyboard_Blue_Switch_Gradient_Grey-a.jpg | `redragon-k617-fizz.jpg` | 2026-11-05 | Listed |
| `steelseries-apex-pro-tkl` | https://easypc.com.ph/products/steelseries-apex-pro-tkl-mechanical-gaming-keyboard | https://cdn.shopify.com/s/files/1/0101/4864/2879/products/2986-b.jpg | `steelseries-apex-pro-tkl.jpg` | 2026-11-05 | Listed |
| `royal-kludge-rk-m75` | https://easypc.com.ph/products/royal-kludge-rk-m75-trimode-mechanical-keyboard-oled-screen-phantom | https://cdn.shopify.com/s/files/1/0101/4864/2879/files/Royal_Kludge_RK-M75_Trimode_Mechanical_Keyboard_Oled_Screen_Phantom-a.png | `royal-kludge-rk-m75.png` | 2026-11-05 | Listed |

Notes:

- The EasyPC AULA F75 listing was ₱2,220.00, but its variant wording did not
  match the Reaper-switch Black/Gradient Grey board that was finally imaged.
  The DataBlitz listing above verifies that exact variant at ₱2,595.00, so the
  DataBlitz record and price were used.
- The EasyPC Keychron K8 photo includes a loose red switch next to the board;
  it is the retailer's own photo of the KEK81640 red-switch model.

### Mice

| ID | Listing (price source) | Image source | Local asset | Checked | Availability |
|----|------------------------|--------------|-------------|---------|--------------|
| `logitech-g102` | https://ecommerce.datablitz.com.ph/products/logitech-g102-lightsync-gaming-mouse-black | https://cdn.shopify.com/s/files/1/0355/8296/7943/products/High_Resolution_PNG-G203-Black-Top.jpg | `logitech-g102.jpg` | 2026-11-05 | Listed |
| `razer-deathadder-v3` | https://easypc.com.ph/products/razer-deathadder-v3-ultra-lightweight-ergonomic-esports-mouse-black | https://cdn.shopify.com/s/files/1/0355/8296/7943/products/0840272902998.jpg | `razer-deathadder-v3.jpg` | 2026-11-05 | Listed |
| `logitech-g502-x-plus` | https://ecommerce.datablitz.com.ph/products/logitech-g502-x-plus-lightspeed-wireless-rgb-gaming-mouse | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/g502-x-plus-top-angle-black-purple-gallery-1.jpg | `logitech-g502-x-plus.jpg` | 2026-11-05 | Listed |
| `logitech-gpro-x-superlight-2` | https://ecommerce.datablitz.com.ph/products/logitech-g-pro-x-superlight-2-lightspeed-wireless-gaming-mouse-black | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/zcx.jpg | `logitech-gpro-x-superlight-2.jpg` | 2026-11-05 | Listed |
| `razer-viper-v3-pro` | https://ecommerce.datablitz.com.ph/products/razer-viper-v3-pro-ultra-lightweight-wireless-symmetrical-esports-mouse | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/as_9b4c4092-b250-41a9-8e14-81f4f605865a.jpg | `razer-viper-v3-pro.jpg` | 2026-11-05 | Listed |
| `logitech-g304-x` | https://ecommerce.datablitz.com.ph/products/logitech-g304-x-lightspeed-wireless-gaming-mouse-black-white-910-007867-910-007868 | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/g304-x-black-3qtr-high-back-angle-gallery-5.jpg | `logitech-g304-x.jpg` | 2026-11-05 | Listed |

Notes:

- EasyPC listed the black DeathAdder V3 at ₱2,833.33. Its product photo carried
  a large `EASYPC` watermark, so the clean DataBlitz studio photo of the same
  black wired DeathAdder V3 was used for the catalog image. The image comes from
  the DataBlitz listing
  `https://ecommerce.datablitz.com.ph/products/razer-deathadder-v3-ultra-lightweight-ergonomic-esports-gaming-mouse-black`,
  which prices the same model at ₱3,795.00. EasyPC's lower verified price was
  used for the catalog.
- EasyPC's `compare_at_price` for the DeathAdder was lower than the current
  price (₱2,550.00 vs ₱2,833.33). That is a retailer data anomaly, not a real
  discount, so the regular price is recorded as the current price.
- The Viper V3 Pro Black and White variants are both ₱9,120.00. The White
  variant is listed because a clean white studio photo with the HyperSpeed
  dongle was available.
- The G304 X image is the black variant; the White variant uses the same price.

### Headsets

| ID | Listing (price source) | Image source | Local asset | Checked | Availability |
|----|------------------------|--------------|-------------|---------|--------------|
| `razer-blackshark-v2-x` | https://ecommerce.datablitz.com.ph/products/razer-blackshark-v2-x-multi-platform-wired-esports-headset-white | https://cdn.shopify.com/s/files/1/0355/8296/7943/products/1_1662393817.jpg | `razer-blackshark-v2-x.jpg` | 2026-11-05 | Listed |
| `hyperx-cloud-iii` | https://ecommerce.datablitz.com.ph/products/hyperx-cloud-iii-wired-gaming-headset-for-pc-ps5-ps4-xbox-series-x-s-xbox-one-nintendo-switch-mac-mobile-black-black-red-white-pink-white-silver-black-blue | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/hyperx_cloud_iii_black_66x0048_main_1_900x_3a26513b-dd91-45ee-bb41-6e0e01e65c2b.jpg | `hyperx-cloud-iii.jpg` | 2026-11-05 | Listed |
| `hyperx-cloud-iii-s` | https://ecommerce.datablitz.com.ph/products/hyperx-cloud-iii-s-wireless-gaming-headset-for-pc-ps5-ps4-nsw-mobile | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/hyperx_cloud_iii_s_wireless_black_a59yzaa_main_1_900x_78cb19ee-67c5-4b9b-8b8c-6ed799dd066e.jpg | `hyperx-cloud-iii-s.jpg` | 2026-11-05 | Listed |
| `steelseries-arctis-nova-pro-wireless` | https://easypc.com.ph/products/steelseries-61520-arctis-nova-pro-wireless-headset-black | https://cdn.shopify.com/s/files/1/0101/4864/2879/files/SteelSeries_61520_Arctis_Nova_Pro_Wireless_Headset_Black-c.png | `steelseries-arctis-nova-pro.png` | 2026-11-05 | Listed |
| `razer-kraken-v4-x` | https://ecommerce.datablitz.com.ph/products/razer-kraken-v4-x-wired-gaming-headset-black | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/0840272910108.jpg | `razer-kraken-v4-x.jpg` | 2026-11-05 | Listed |

Notes:

- DataBlitz listed the BlackShark V2 X White at ₱2,350.00. EasyPC also carries
  the headset at ₱2,995.00; the lower DataBlitz price for the same White model
  was used.
- The Cloud III Black (727A8AA) and White/Silver (BS7C1AA) are both ₱3,595.00.
  Black is used in the catalog.
- The Cloud III S Wireless colours are all ₱6,250.00. Black (A59YZAA) is used.

### Mousepads and desk mats

| ID | Listing (price source) | Image source | Local asset | Checked | Availability |
|----|------------------------|--------------|-------------|---------|--------------|
| `razer-goliathus-chroma` | https://ecommerce.datablitz.com.ph/products/razer-goliathus-chroma-soft-gaming-mouse-mat | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/0814855027699.jpg | `razer-goliathus-chroma.jpg` | 2026-11-05 | Listed |
| `razer-strider-large-quartz` | https://ecommerce.datablitz.com.ph/products/razer-strider-hybrid-gaming-mouse-mat-large-quartz | https://cdn.shopify.com/s/files/1/0355/8296/7943/products/0840272904671.jpg | `razer-strider-large-quartz.jpg` | 2026-11-05 | Listed |
| `fantech-mp905-luffy` | https://ecommerce.datablitz.com.ph/products/fantech-x-one-piece-ato-mp905-deskmat-luffy-zoro-luffy-gear-5-nami-brook-robin-egghead-chopper-1 | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/Product_Image_Deskmat_MP905_Luffy.jpg | `fantech-mp905-luffy.jpg` | 2026-11-05 | Listed |
| `keychron-desk-mat-ninego` | https://ecommerce.datablitz.com.ph/products/keychron-desk-mat-ninego-blue-dm-2 | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/Keychron-Desk-Mat-NINEGO-Blue_b97cf3fa-6c13-4d77-b4c8-0ca21c5657d8.jpg | `keychron-desk-mat-ninego.jpg` | 2026-11-05 | Listed |

Notes:

- EasyPC lists a Goliathus Chroma Medium at ₱1,225.00, but the DataBlitz SKU
  and listing (`0814855027699`, ₱2,150.00) were used because the exact size and
  image were unambiguous there.
- The DataBlitz MP905 page has a group photo of every One Piece design. The
  single-design Luffy image from that same product gallery is used locally.
  Luffy is ₱895.00; the Luffy Gear 5 variant is ₱850.00.

### Desk accessories

| ID | Listing (price source) | Image source | Local asset | Checked | Availability |
|----|------------------------|--------------|-------------|---------|--------------|
| `razer-base-station-v2-chroma` | https://ecommerce.datablitz.com.ph/products/razer-base-station-v2-chroma-usb-hub-headset-stand-w-razer-chroma-rgb-black | https://cdn.shopify.com/s/files/1/0355/8296/7943/products/6435280_sd.jpg | `razer-base-station-v2.jpg` | 2026-11-05 | Listed |
| `ugreen-uno-hub` | https://ecommerce.datablitz.com.ph/products/ugreen-uno-6-in-1-usb-c-hub-gray-cm889-75177 | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/asd56g4sad5g4.jpg | `ugreen-uno-hub.jpg` | 2026-11-05 | Listed |
| `inplay-kmt-3` | https://easypc.com.ph/products/inplay-kmt-3-dual-arms-monitor-stand-mount-17-27-black | https://cdn.shopify.com/s/files/1/0101/4864/2879/files/10881_a.png | `inplay-kmt-3.png` | 2026-11-05 | Listed |
| `keychron-palm-rest` | https://ecommerce.datablitz.com.ph/products/keychron-silicone-palm-rest-for-k2-k2-pro-k2-max-k2-he-k6-k6-pro-black-pr43 | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/dsfgshdgfb.jpg | `keychron-palm-rest.jpg` | 2026-11-05 | Listed |
| `arctic-z1-basic` | https://ecommerce.datablitz.com.ph/products/arctic-z1-basic-desk-mount-monitor-arm-aemnt00039a | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/Z1_Basic_G00.jpg | `arctic-z1.jpg` | 2026-11-05 | Listed |

Notes:

- EasyPC lists the Base Station V2 Chroma at ₱3,295.00; the DataBlitz listing
  at ₱3,450.00 was used because it supplied a clean image and SKU.
- The UGREEN hub has two 10 Gbps USB-C ports, two 10 Gbps USB-A ports, HDMI
  4K@60Hz, and 100 W PD (85 W pass-through).

### Streaming and audio

| ID | Listing (price source) | Image source | Local asset | Checked | Availability |
|----|------------------------|--------------|-------------|---------|--------------|
| `hyperx-quadcast-2` | https://ecommerce.datablitz.com.ph/products/hyperx-quadcast-2-usb-microphone-for-pc-mac-ps5-ps4-black-872v1aa | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/0197497651058.jpg | `hyperx-quadcast-2.jpg` | 2026-11-05 | Listed |
| `razer-seiren-v3-mini` | https://ecommerce.datablitz.com.ph/products/razer-seiren-v3-mini-ultra-compact-usb-microphone | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/https_3A_2F_2Fhybrismediaprod.blob.core.windows.net_2Fsys-master-phoenix-images-container_2Fhf9_2Fh28_2F9743850962974_2F240229-seiren-v3-mini-black-1500x1000-4.jpg | `razer-seiren-v3-mini.jpg` | 2026-11-05 | Listed |
| `razer-seiren-v3-chroma` | https://ecommerce.datablitz.com.ph/products/razer-seiren-v3-chroma-32-bit-dsp-rgb-usb-microphone-black-white-quartz | https://cdn.shopify.com/s/files/1/0355/8296/7943/files/dymdtyu.jpg | `razer-seiren-v3-chroma.jpg` | 2026-11-05 | Listed |
| `logitech-c922` | https://ecommerce.datablitz.com.ph/products/logitech-c922-pro-stream-webcam-hd-full-hd-video-streaming-1 | https://cdn.shopify.com/s/files/1/0355/8296/7943/products/1_dc7b068e-9fee-4800-b843-5eb568f2caa8.png | `logitech-c922.png` | 2026-11-05 | Listed |

Notes:

- The Seiren V3 Mini Black, White, and Quartz variants are all ₱2,850.00.
- The Seiren V3 Chroma Black, White, and Quartz variants are all ₱7,695.00.
  The catalog uses the Black variant and its clean studio photo.
- The QuadCast 2 Black (872V1AA) is ₱6,995.00. The Frost colourway is a
  different SKU at ₱6,750.00 and is not included.

## Data and image handling

- **Price storage.** `assets/data/catalog.json` stores `priceCents` as an
  integer. Exact centavo prices are preserved:
  `₱1,388.89 → 138889`, `₱2,833.33 → 283333`, `₱2,794.44 → 279444`.
- **Image files.** All 29 local files live in `assets/images/products/` and are
  declared by the existing `assets/images/products/` entry in `pubspec.yaml`.
  `ProductImage` renders them with `BoxFit.contain`, so isolated product shots
  are not cropped.
- **Rejected images.** No image in the final catalog contains an `EASYPC`
  watermark, a price banner, or a multi-product promotional collage. Candidate
  images that did were replaced with the clean retailer photo noted above.
- **Ratings.** The catalog sets `rating: 0` and `reviewCount: 0`. The product
  card, product detail screen, and search result tile now omit stars and review
  counts when `reviewCount == 0`.

## Researched but excluded

These items were seen at Philippine retailers but were not included because the
exact variant image, model match, or listing data could not be verified well
enough for this catalog. They are candidates for a later pass, not claims of
current availability.

| Product | Retailer / price seen | Reason excluded |
|---------|-----------------------|-----------------|
| AULA SC380 Pro (White) | EasyPC, ₱1,130.00 | Candidate image was watermarked or not a clean exact-model shot. |
| Logitech G733 LIGHTSPEED (White) | EasyPC, ₱5,595.00 | Clean exact White image could not be confirmed. |
| SteelSeries QcK Prism Cloth XL | EasyPC, ₱2,750.00 | Listing photo was generic, not an exact-model studio image. |
| HyperX Wrist Rest | EasyPC, ₱995.00 | Generic category image; exact model/colour not verifiable. |
| DeepCool M-Desk F2 | EasyPC, ₱945.00 | Listing photo did not clearly show the exact F2 stand. |
| Edifier G2000 | EasyPC, ₱3,450.00 | Exact-model image could not be verified cleanly. |
| HyperX QuadCast (original) | EasyPC, ₱9,030.00 | Superseded by the verified QuadCast 2 listing. |
| Razer Seiren Mini (older) | EasyPC, ₱2,499.00 | Superseded by the verified Seiren V3 Mini listing. |
| Logitech G102 (EasyPC listing) | EasyPC, ₱970.00 | Same model as DataBlitz, but DataBlitz had the lower verified price (₱941.00). |
| Razer BlackShark V2 X (EasyPC listing) | EasyPC, ₱2,995.00 | Same white model; DataBlitz's ₱2,350.00 price was used. |
| Razer Base Station V2 Chroma (EasyPC listing) | EasyPC, ₱3,295.00 | DataBlitz's ₱3,450.00 listing had a clean image and SKU. |

## Reproducing the check

The retailer catalogs used for matching are public Shopify JSON endpoints:

- EasyPC: `https://easypc.com.ph/products.json?limit=250&page=N`
- DataBlitz: `https://ecommerce.datablitz.com.ph/products.json?limit=250&page=N`
- Single product: `https://<retailer>/products/<handle>.json`

Prices and titles can change after the checked date. The catalog should be
re-verified before being presented as live pricing.
