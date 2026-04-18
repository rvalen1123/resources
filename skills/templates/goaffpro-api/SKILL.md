---
name: goaffpro-api
description: Manage GoAffPro affiliate programs via their Admin REST API. Use when working with GoAffPro affiliates, coupons, sales, commissions, payouts, or syncing affiliate data with WooCommerce. Triggers on any mention of "GoAffPro", "affiliate program", "affiliate sync", "affiliate coupons", "referral tracking", "commission structure", or any affiliate marketing management task for stores using GoAffPro. Also trigger when user mentions syncing affiliates to WooCommerce, checking affiliate sales, generating affiliate reports, or managing payout data.
---

# GoAffPro Admin API Skill

Manage GoAffPro affiliate programs programmatically via the Admin REST API.
Covers affiliate CRUD, coupon management, sales/order queries, commission configuration, payout tracking, and WooCommerce account sync.

## Authentication

**Two tokens required** (from GoAffPro dashboard → Settings → Advanced Settings → API Keys):

| Token | Header | Purpose |
|-------|--------|---------|
| Access Token | `x-goaffpro-access-token` | Admin API auth (required for ALL calls) |
| Public Token | `x-goaffpro-public-token` | Frontend tracking only (NOT for admin API) |

```php
// WordPress example
$response = wp_remote_get($url, [
    'timeout' => 30,
    'headers' => [
        'x-goaffpro-access-token' => 'YOUR_ACCESS_TOKEN',
    ],
]);
```

```bash
# cURL example
curl -H "x-goaffpro-access-token: YOUR_TOKEN" \
  "https://api.goaffpro.com/v1/admin/affiliates?limit=10&fields=email,name"
```

**CRITICAL: The `fields` parameter is REQUIRED** for the affiliates endpoint. Without it, the API returns empty objects `{}` for each affiliate. Always specify which fields you need.

## Base URL

```
https://api.goaffpro.com/v1/admin/
```

## API Reference

### Affiliates

#### List Affiliates

```
GET /v1/admin/affiliates
```

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `fields` | string | **YES** | Comma-separated field list. Without this, response contains empty objects. |
| `page` | int | No | Page number (1-indexed) |
| `limit` | int | No | Results per page (max 100) |

**Available fields:** `email`, `name`, `phone`, `referral_code`, `coupon_code`, `status`, `created_at`, `commission`, `total_sales`, `total_revenue`, `total_clicks`, `payment_method`, `payment_details`

```bash
# Get all affiliates with email and name
GET /v1/admin/affiliates?limit=100&fields=email,name

# Response:
{
  "affiliates": [
    {"email": "alice@example.com", "name": "Alice Smith"},
    {"email": "bob@example.com", "name": "Bob Jones"}
  ],
  "limit": 100,
  "total_results": 118
}
```

**GOTCHA: Pagination loops infinitely.** The API returns 100 results per page even when you've passed the end. Always deduplicate by email and cap page count at `ceil(total_results / limit)`.

#### Get Single Affiliate

```
GET /v1/admin/affiliates/:id
```

Returns full affiliate profile including commission settings, sales history, and payment info.

#### Update Affiliate

```
PUT /v1/admin/affiliates/:id
```

Body fields: `name`, `email`, `phone`, `commission`, `status` (approved/pending/blocked), `payment_method`, `payment_details`, `referral_code`

#### Delete Affiliate

```
DELETE /v1/admin/affiliates/:id
```

### Sales & Orders

#### List Sales

```
GET /v1/admin/sales
```

| Param | Type | Description |
|-------|------|-------------|
| `page` | int | Page number |
| `limit` | int | Max 100 |
| `affiliate_id` | string | Filter by affiliate |
| `status` | string | pending, approved, rejected |
| `date_from` | string | ISO date filter |
| `date_to` | string | ISO date filter |

#### Get Sale Details

```
GET /v1/admin/sales/:id
```

#### Approve/Reject Sale

```
PUT /v1/admin/sales/:id
Body: {"status": "approved"} or {"status": "rejected"}
```

### Coupons

#### List Coupons

```
GET /v1/admin/coupons
```

#### Create Coupon

```
POST /v1/admin/coupons
Body: {
  "affiliate_id": "...",
  "code": "ALICE10",
  "discount_type": "percentage",
  "discount_value": 10,
  "usage_limit": 100
}
```

#### Delete Coupon

```
DELETE /v1/admin/coupons/:id
```

### Payouts

#### List Payouts

```
GET /v1/admin/payouts
```

| Param | Type | Description |
|-------|------|-------------|
| `page` | int | Page number |
| `limit` | int | Max 100 |
| `status` | string | pending, paid |
| `affiliate_id` | string | Filter by affiliate |

#### Create Payout

```
POST /v1/admin/payouts
Body: {
  "affiliate_id": "...",
  "amount": 150.00,
  "method": "paypal",
  "note": "March 2026 payout"
}
```

### Settings

#### Get Program Settings

```
GET /v1/admin/settings
```

Returns commission rates, cookie duration, approval mode, and program configuration.

#### Update Program Settings

```
PUT /v1/admin/settings
Body: { "commission_type": "percentage", "commission_value": 15 }
```

## WooCommerce Sync Pattern

GoAffPro's WooCommerce "Account Sync" feature is unreliable. Use this PHP pattern to sync affiliates directly:

```php
<?php
/**
 * GoAffPro → WooCommerce Affiliate Sync
 * Run via: wp eval-file sync.php
 */
$token = 'YOUR_ACCESS_TOKEN';
$page = 1;
$all = [];

// Fetch all affiliates (MUST use fields= parameter)
while ($page <= 20) { // Safety cap
    $url = "https://api.goaffpro.com/v1/admin/affiliates?page=$page&limit=100&fields=email,name";
    $r = wp_remote_get($url, [
        'timeout' => 30,
        'headers' => ['x-goaffpro-access-token' => $token],
    ]);
    $body = json_decode(wp_remote_retrieve_body($r), true);
    $affiliates = $body['affiliates'] ?? [];
    if (empty($affiliates)) break;
    $all = array_merge($all, $affiliates);
    if (count($affiliates) < 100) break;
    $page++;
}

// Deduplicate by email
$seen = [];
$unique = array_filter($all, function($a) use (&$seen) {
    $e = $a['email'] ?? '';
    if (!$e || isset($seen[$e])) return false;
    $seen[$e] = true;
    return true;
});

// Create WooCommerce accounts for missing affiliates
foreach ($unique as $aff) {
    $email = $aff['email'];
    if (get_user_by('email', $email)) continue; // Already exists

    $name = $aff['name'] ?? '';
    $parts = explode(' ', $name);
    $username = sanitize_user(strtolower(str_replace(' ', '.', $name)));
    if (empty($username) || username_exists($username)) {
        $username = sanitize_user(explode('@', $email)[0]);
    }
    if (username_exists($username)) $username .= '_' . wp_rand(100, 999);

    $uid = wc_create_new_customer($email, $username, wp_generate_password(12));
    if (!is_wp_error($uid)) {
        wp_update_user([
            'ID' => $uid,
            'first_name' => $parts[0] ?? '',
            'last_name' => trim(str_replace($parts[0] ?? '', '', $name)),
        ]);
        update_user_meta($uid, '_goaffpro_affiliate', 'yes');
    }
}
```

## Known API Quirks (March 2026)

1. **Empty objects without `fields=`**: The `/affiliates` endpoint returns `[{}, {}, ...]` unless you explicitly pass `?fields=email,name` (or other field names). This is undocumented and catches everyone.

2. **Infinite pagination**: The API keeps returning 100 results on every page, even past the actual count. Use `total_results` from the first response to calculate max pages, or deduplicate by email.

3. **Public token ≠ Access token**: The WooCommerce plugin uses a public token (`goaffpro_public_token` option) for frontend tracking. The Admin API requires a separate access token from the API Keys section. Using the wrong token returns 403.

4. **Account Sync unreliable**: GoAffPro's built-in "Re-Sync" button often fails silently, especially if the WooCommerce site has custom REST endpoints (mu-plugins) that throw errors on `admin-ajax.php`. Use the PHP sync pattern above instead.

5. **Rate limiting**: Undocumented, but stays under 2 requests/second to be safe. Add `usleep(500000)` between API calls in loops.

6. **Response structure**: Always `{"affiliates": [...], "limit": N, "total_results": N}` for list endpoints. Single-entity endpoints return the object directly.

## WordPress Integration

### wp-config.php Constants

Store credentials in wp-config.php, not in the database:

```php
// GoAffPro API Keys
define('GOAFFPRO_ACCESS_TOKEN', 'your-access-token');
define('GOAFFPRO_PUBLIC_TOKEN', 'your-public-token');
```

### WooCommerce Plugin

GoAffPro's WooCommerce plugin (`goaffpro/goaffpro.php`) handles:
- Frontend tracking script injection (`wp_footer`)
- Order attribution on checkout (`woocommerce_thankyou`)
- Coupon code detection and auto-apply (`woocommerce_before_cart_table`)
- REST API route for internal communication (`rest_api_init`)

The plugin only needs the public token (stored as `goaffpro_public_token` WP option). The admin API access token is separate and used only for server-side scripts.

### Custom REST Endpoints (Optional)

If using GoAffPro's "Custom SDK" integration (instead of native WooCommerce), you need custom REST endpoints. See the `goaffpro-endpoints.php` mu-plugin pattern. However, for most WooCommerce stores, the native integration is preferred — it's simpler and the plugin handles everything.

## Common Tasks

### Export Affiliate Report
```bash
# Get all affiliate emails + stats
GET /v1/admin/affiliates?limit=100&fields=email,name,total_sales,total_revenue,total_clicks
```

### Check Specific Affiliate Performance
```bash
GET /v1/admin/affiliates/:id
GET /v1/admin/sales?affiliate_id=:id&date_from=2026-01-01&date_to=2026-03-31
```

### Bulk Create Coupons for All Affiliates
Use the GoAffPro dashboard (Coupons tab → Automatic Coupons → Create for existing affiliates) for bulk coupon generation. The API approach requires looping through each affiliate, which is slower and more error-prone.

### Payout Report
```bash
GET /v1/admin/payouts?status=pending
GET /v1/admin/payouts?status=paid&date_from=2026-01-01
```
