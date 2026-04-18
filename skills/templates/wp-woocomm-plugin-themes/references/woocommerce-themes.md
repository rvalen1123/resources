# WooCommerce Theme Development Reference

## Table of Contents
- Child Theme Setup
- Declaring WooCommerce Support
- Template Structure & Overrides
- Image Sizing
- WooCommerce Hooks for Themes
- Block Theme Development

## Child Theme Setup

### Directory Structure
```
wp-content/themes/your-child-theme/
├── style.css              (required - theme header)
├── functions.php          (required - enqueue styles, declare support)
├── woocommerce/           (optional - WooCommerce template overrides)
│   ├── single-product.php
│   ├── archive-product.php
│   ├── cart/
│   ├── checkout/
│   ├── emails/
│   ├── loop/
│   ├── myaccount/
│   └── order/
├── template-parts/        (optional - custom partials)
└── assets/                (optional - CSS/JS/images)
```

### style.css Header (Required)
```css
/*
Theme Name: My WooCommerce Child
Theme URI: https://example.com
Description: Custom WooCommerce child theme
Author: Your Name
Author URI: https://example.com
Template: parent-theme-folder-name
Version: 1.0.0
License: GNU General Public License v2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html
Text Domain: my-woocommerce-child
*/
```
**Critical**: `Template` must exactly match parent theme folder name.

### functions.php - Enqueue Styles
```php
<?php
// Enqueue parent + child styles
function mytheme_enqueue_styles() {
    wp_enqueue_style(
        'parent-style',
        get_template_directory_uri() . '/style.css'
    );
    wp_enqueue_style(
        'child-style',
        get_stylesheet_directory_uri() . '/style.css',
        array( 'parent-style' ),
        wp_get_theme()->get( 'Version' )
    );
}
add_action( 'wp_enqueue_scripts', 'mytheme_enqueue_styles' );
```

**Key distinction**:
- `get_template_directory_uri()` = parent theme directory
- `get_stylesheet_directory_uri()` = child theme directory (active theme)

## Declaring WooCommerce Support

Must use `after_setup_theme` hook (NOT `init`):

```php
function mytheme_add_woocommerce_support() {
    add_theme_support( 'woocommerce' );
}
add_action( 'after_setup_theme', 'mytheme_add_woocommerce_support' );
```

### With Image Size Configuration
```php
add_theme_support( 'woocommerce', array(
    'thumbnail_image_width' => 200,
    'gallery_thumbnail_image_width' => 100,
    'single_image_width' => 500,
) );
```

### Product Gallery Features
```php
add_theme_support( 'wc-product-gallery-zoom' );
add_theme_support( 'wc-product-gallery-lightbox' );
add_theme_support( 'wc-product-gallery-slider' );
```

## Template Structure & Overrides

WooCommerce templates live in: `wp-content/plugins/woocommerce/templates/`

### Override by copying to child theme
Copy to: `wp-content/themes/your-child-theme/woocommerce/`

Example: Override single product template
```
Source: plugins/woocommerce/templates/single-product.php
Target: themes/your-child-theme/woocommerce/single-product.php
```

### Key Template Categories
| Category | Path | Purpose |
|----------|------|---------|
| Cart | `woocommerce/cart/` | Cart page templates |
| Checkout | `woocommerce/checkout/` | Checkout flow |
| Single Product | `woocommerce/single-product/` | Product detail pages |
| Loop | `woocommerce/loop/` | Product archive loops |
| Emails | `woocommerce/emails/` | Transactional emails |
| My Account | `woocommerce/myaccount/` | Customer dashboard |
| Notices | `woocommerce/notices/` | Store notices |
| Order | `woocommerce/order/` | Order confirmation |

### Common Templates to Override
- `content-product.php` - Product card in loops
- `single-product/product-image.php` - Product gallery
- `single-product/tabs/tabs.php` - Product tabs
- `cart/cart.php` - Cart page
- `checkout/form-checkout.php` - Checkout form
- `emails/email-header.php` - Email header

**Important**: Keep template version headers updated to avoid "outdated template" warnings.

## WooCommerce Hooks for Themes

### Shop Page Hooks (in order)
```
woocommerce_before_main_content
  woocommerce_archive_description
  woocommerce_before_shop_loop
    woocommerce_before_shop_loop_item
      woocommerce_before_shop_loop_item_title
      woocommerce_shop_loop_item_title
      woocommerce_after_shop_loop_item_title
    woocommerce_after_shop_loop_item
  woocommerce_after_shop_loop
woocommerce_after_main_content
woocommerce_sidebar
```

### Single Product Hooks (in order)
```
woocommerce_before_single_product
woocommerce_before_single_product_summary
woocommerce_single_product_summary
  woocommerce_product_meta_start
  woocommerce_product_meta_end
woocommerce_after_single_product_summary
woocommerce_after_single_product
```

### Cart Page Hooks
```
woocommerce_before_cart
woocommerce_before_cart_table
woocommerce_before_cart_contents
woocommerce_cart_contents
woocommerce_after_cart_contents
woocommerce_after_cart_table
woocommerce_cart_collaterals
woocommerce_after_cart
```

### Checkout Hooks
```
woocommerce_before_checkout_form
woocommerce_checkout_before_customer_details
woocommerce_checkout_after_customer_details
woocommerce_checkout_before_order_review
woocommerce_checkout_order_review
woocommerce_checkout_after_order_review
woocommerce_after_checkout_form
```

## Block Theme Development

For FSE (Full Site Editing) block themes:

### theme.json WooCommerce Integration
```json
{
    "$schema": "https://schemas.wp.org/trunk/theme.json",
    "version": 2,
    "settings": {
        "color": {
            "palette": [
                { "slug": "primary", "color": "#000000", "name": "Primary" }
            ]
        }
    },
    "styles": {
        "blocks": {
            "woocommerce/product-image": {
                "border": { "radius": "4px" }
            }
        }
    }
}
```

### Block Template Parts
```
templates/
├── single-product.html
├── archive-product.html
├── taxonomy-product_cat.html
├── taxonomy-product_tag.html
└── page-cart.html

parts/
├── header.html
└── footer.html
```

**Filters in templates**: Place only actions, not filters, inside templates. Move filterable logic to functions/methods that load templates.
