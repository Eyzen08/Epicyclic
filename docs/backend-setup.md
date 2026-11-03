# Backend setup

## Phase 0 status

Candidate Supabase integration files were found:

- `supabase/migrations/20260101000000_init.sql`
- `supabase/seed.sql`
- `lib/features/**/data/supabase_*_repository.dart`
- `.env.example`

No remote Supabase project or credentials were available. Nothing was applied
to a remote database during Phase 0, and the SQL/RLS/RPC behavior is therefore
unverified. Phase 5 must review the schema and security before deployment;
Phase 6 must verify live reads/auth/user data; Phase 7 must verify trusted order
creation.

## Intended model found in the candidate migration

- Catalog: categories, products, product variants/inventory, images, category
  links.
- Customer data: auth-backed profiles and addresses.
- Commerce: orders, immutable order-item snapshots, status events, and
  notifications.
- Trusted operation: `create_order(p_items, p_address, p_payment_method,
  p_contact_email, p_promo_code)`.

The candidate design uses row-level security, owner-scoped private data, public
catalog reads, and server-side order pricing/stock changes. These claims must be
validated in Phase 5 rather than assumed from source inspection.

## Safe deployment sequence (future phase)

1. Create or choose a Supabase project only with explicit authorization.
2. Review migration SQL, constraints, RLS policies, grants, function search
   paths, and privilege boundaries.
3. Apply the versioned migration using the Supabase CLI or SQL editor.
4. Apply seed data only to the intended development environment.
5. Configure Auth URLs/providers, including the documented mobile deep links.
6. Use only the project URL and public anon/publishable key in Flutter.
7. Test anonymous catalog reads and authenticated owner/cross-owner scenarios.
8. Test order creation, duplicate submission behavior, stock contention,
   invalid prices/variants/discounts, and transaction rollback.
9. Record all results in `docs/testing.md` before claiming a live integration.

Never embed the service-role key, database password, JWT signing secret, or
payment-provider secret in the Flutter app.

## Payments

No payment provider is configured. The current candidate checkout records only
a payment-method label and explicitly says no payment is captured. Real payment
support requires a PCI-compliant provider, server-created payment intents, and
webhook-controlled order/payment state. Do not collect raw card details or
simulate a successful charge.
