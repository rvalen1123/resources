---
name: wp-woocomm-plugin-themes
description: Build WordPress plugins and WooCommerce themes/child themes. Use when developing WooCommerce extensions, creating WordPress plugins with WooCommerce integration, setting up child themes, overriding WooCommerce templates, working with WooCommerce blocks, using WP-CLI for WooCommerce/WordPress tasks, or building any WordPress plugin that integrates with WooCommerce. Covers plugin architecture, hooks/actions/filters, security (nonces, sanitization, escaping), custom post types, AJAX, WP-Cron, Settings API, admin menus, child theme setup, WooCommerce template overrides, block development, HPOS compatibility, and Store API extensions.
---

# WordPress & WooCommerce Plugin/Theme Development

## Task Decision Tree

**Building a WooCommerce child theme?**
- Read [references/woocommerce-themes.md](references/woocommerce-themes.md)

**Building a WordPress plugin (with or without WooCommerce)?**
- Read [references/wordpress-plugins.md](references/wordpress-plugins.md)

**Working with WooCommerce blocks or Store API?**
- Read [references/woocommerce-blocks.md](references/woocommerce-blocks.md)

**Need WP-CLI commands for scaffolding, management, or debugging?**
- Read [references/wp-cli.md](references/wp-cli.md)

## Quick Start: WooCommerce Child Theme

```php
// functions.php - minimum viable WooCommerce child theme
<?php
// Enqueue parent styles
add_action( 'wp_enqueue_scripts', function() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri() . '/style.css' );
});

// Declare WooCommerce support (MUST use after_setup_theme, NOT init)
add_action( 'after_setup_theme', function() {
    add_theme_support( 'woocommerce' );
    add_theme_support( 'wc-product-gallery-zoom' );
    add_theme_support( 'wc-product-gallery-lightbox' );
    add_theme_support( 'wc-product-gallery-slider' );
});
```

## Quick Start: WooCommerce Plugin

```php
<?php
/**
 * Plugin Name: My WooCommerce Extension
 * Description: Extends WooCommerce functionality
 * Version: 1.0.0
 * Requires at least: 6.0
 * Requires PHP: 7.4
 * WC requires at least: 8.0
 * WC tested up to: 9.0
 */

if ( ! defined( 'ABSPATH' ) ) exit;

// Declare HPOS compatibility
add_action( 'before_woocommerce_init', function() {
    if ( class_exists( \Automattic\WooCommerce\Utilities\FeaturesUtil::class ) ) {
        \Automattic\WooCommerce\Utilities\FeaturesUtil::declare_compatibility(
            'custom_order_tables', __FILE__, true
        );
    }
});

// Check WooCommerce is active before proceeding
add_action( 'plugins_loaded', function() {
    if ( ! class_exists( 'WooCommerce' ) ) return;
    // Initialize plugin
});
```

## Critical Rules

1. **Always sanitize input, escape output**: `sanitize_text_field()` for input, `esc_html()` / `esc_attr()` / `esc_url()` for output
2. **Always verify nonces**: `wp_verify_nonce()` or `check_ajax_referer()` for form submissions and AJAX
3. **Always check capabilities**: `current_user_can()` before privileged operations
4. **Declare HPOS compatibility** in all WooCommerce plugins
5. **Use `after_setup_theme`** (not `init`) for `add_theme_support( 'woocommerce' )`
6. **Template field must exactly match** parent theme folder name in child theme `style.css`
7. **Prefix everything**: functions, classes, hooks, options, meta keys - avoid naming collisions
8. **Use `$wpdb->prepare()`** for all database queries with user input

## WP-CLI Quick Reference

```bash
# Scaffold plugin/theme
wp scaffold plugin my-plugin --activate
wp scaffold child-theme my-child --parent_theme=storefront --activate

# WooCommerce operations
wp wc product list --user=1
wp wc tool run install_pages --user=1
wp wc tool run clear_transients --user=1

# Debug & maintenance
wp config set WP_DEBUG true --raw
wp transient delete --all
wp rewrite flush
wp cron event list
```

## Reference Files

| File | Use When |
|------|----------|
| [woocommerce-themes.md](references/woocommerce-themes.md) | Child themes, template overrides, WC hooks, block themes, image sizing |
| [wordpress-plugins.md](references/wordpress-plugins.md) | Plugin structure, hooks, security, CPT, AJAX, cron, Settings API, WC integration |
| [wp-cli.md](references/wp-cli.md) | CLI scaffolding, management, debugging, batch operations |
| [woocommerce-blocks.md](references/woocommerce-blocks.md) | Block registration, available blocks, Store API, checkout extensions |
