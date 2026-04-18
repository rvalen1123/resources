# WordPress Plugin Development Reference

## Table of Contents
- WooCommerce Extension Scaffolding
- Plugin File Structure
- Plugin Header
- Hooks: Actions & Filters
- Security (Nonces, Sanitization, Escaping)
- Administration Menus
- Settings API
- Custom Post Types & Taxonomies
- Metadata & Custom Meta Boxes
- Shortcodes
- AJAX
- WP-Cron
- Internationalization (i18n)
- Privacy
- Database Tables
- WooCommerce Plugin Integration

## WooCommerce Extension Scaffolding

### Quick Start
```bash
npx @wordpress/create-block -t @woocommerce/create-woo-extension my-extension-name
cd my-extension-name
npm install
npm run build
```

### Local Dev Environment
```bash
npm -g i @wordpress/env   # if not installed
wp-env start              # WordPress + WooCommerce on localhost:8888
```

### Scaffolded Structure
```
my-extension-name/
├── my-extension-name.php    (plugin entry point)
├── package.json             (npm deps & scripts)
├── composer.json            (PHP deps)
├── webpack.config.js        (uses @woocommerce/dependency-extraction-webpack-plugin)
├── .wp-env.json             (Docker dev env config)
├── src/
│   ├── index.js             (Webpack entry - registers React settings page)
│   └── index.scss           (styles entry)
├── includes/                (shared PHP code)
├── languages/               (i18n POT files)
├── tests/                   (PHP + JS tests)
└── build/                   (generated - do not edit)
```

### Webpack Config Pattern
```js
const defaultConfig = require('@wordpress/scripts/config/webpack.config');
const WooCommerceDependencyExtractionWebpackPlugin =
    require('@woocommerce/dependency-extraction-webpack-plugin');

module.exports = {
    ...defaultConfig,
    plugins: [
        ...defaultConfig.plugins.filter(
            (p) => p.constructor.name !== 'DependencyExtractionWebpackPlugin'
        ),
        new WooCommerceDependencyExtractionWebpackPlugin(),
    ],
};
```
The WC plugin auto-detects `@woocommerce` imports and adds them to PHP script dependencies.

### npm Scripts
- `npm run build` - Compile JS/CSS from `src/` to `build/`
- `npm start` - Dev mode with file watching
- `npm run lint` - Run linting
- `npm test` - Run tests

### Sample Data for Testing
WooCommerce includes sample data in `woocommerce/sample-data/`:
- `sample_products.csv` / `sample_products.xml` (25 products)
- Import via Tools > Import in WP Admin
- For orders/customers: use the **Smooth Generator** plugin

### Settings Page URL
```
wp-admin/admin.php?page=wc-admin&path=/my-extension-name
```

## Plugin File Structure

### Standard Layout
```
my-plugin/
├── my-plugin.php              (main plugin file with header)
├── includes/
│   ├── class-my-plugin.php    (core class)
│   ├── class-admin.php        (admin functionality)
│   └── class-frontend.php     (public functionality)
├── admin/
│   ├── css/
│   ├── js/
│   └── views/                 (admin templates)
├── public/
│   ├── css/
│   ├── js/
│   └── views/                 (frontend templates)
├── languages/                 (translation files)
├── templates/                 (overridable templates)
├── assets/
│   └── images/
├── tests/
├── uninstall.php              (cleanup on uninstall)
└── readme.txt                 (WordPress.org readme)
```

### Boilerplate Plugin Header
```php
<?php
/**
 * Plugin Name: My Plugin
 * Plugin URI: https://example.com/my-plugin
 * Description: Short description of the plugin.
 * Version: 1.0.0
 * Requires at least: 6.0
 * Requires PHP: 7.4
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: my-plugin
 * Domain Path: /languages
 * WC requires at least: 8.0
 * WC tested up to: 9.0
 */

// Prevent direct access
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}
```

## Hooks: Actions & Filters

### Actions - Execute code at specific points
```php
// Register action
add_action( 'hook_name', 'callback_function', $priority, $accepted_args );

// Common actions
add_action( 'init', 'my_register_post_types' );
add_action( 'admin_menu', 'my_add_admin_menu' );
add_action( 'wp_enqueue_scripts', 'my_enqueue_assets' );
add_action( 'admin_enqueue_scripts', 'my_admin_assets' );
add_action( 'plugins_loaded', 'my_plugin_init' );
add_action( 'activated_plugin', 'my_activation' );

// Fire custom action
do_action( 'my_plugin_event', $arg1, $arg2 );
```

### Filters - Modify data and return it
```php
// Register filter
add_filter( 'hook_name', 'callback_function', $priority, $accepted_args );

// Common filters
add_filter( 'the_content', 'my_modify_content' );
add_filter( 'woocommerce_product_tabs', 'my_custom_tabs' );
add_filter( 'manage_edit-post_columns', 'my_custom_columns' );

// Apply custom filter
$value = apply_filters( 'my_plugin_filter', $default_value, $context );
```

## Security

### Nonces (Number Used Once)
```php
// Create nonce
wp_nonce_field( 'my_action', 'my_nonce_field' );
$nonce_url = wp_nonce_url( $url, 'my_action', 'my_nonce' );

// Verify nonce
if ( ! wp_verify_nonce( $_POST['my_nonce_field'], 'my_action' ) ) {
    wp_die( 'Security check failed' );
}
check_admin_referer( 'my_action', 'my_nonce_field' );
```

### Sanitization (Input)
```php
sanitize_text_field( $_POST['title'] );
sanitize_email( $_POST['email'] );
sanitize_textarea_field( $_POST['description'] );
absint( $_POST['id'] );
wp_kses_post( $_POST['html_content'] );
sanitize_file_name( $_FILES['upload']['name'] );
```

### Escaping (Output)
```php
esc_html( $text );       // HTML context
esc_attr( $value );      // Attribute context
esc_url( $url );         // URL context
esc_js( $string );       // JavaScript context
wp_kses_post( $html );   // Allow post HTML tags
esc_html_e( 'string', 'text-domain' ); // Translate + escape + echo
```

### Capability Checks
```php
if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( 'Unauthorized' );
}
if ( ! current_user_can( 'edit_post', $post_id ) ) {
    return;
}
```

## Administration Menus

```php
// Top-level menu
add_action( 'admin_menu', function() {
    add_menu_page(
        'Page Title',           // page_title
        'Menu Label',           // menu_title
        'manage_options',       // capability
        'my-plugin-slug',       // menu_slug
        'render_admin_page',    // callback
        'dashicons-admin-tools', // icon_url
        30                      // position
    );
});

// Submenu
add_submenu_page(
    'my-plugin-slug',       // parent_slug
    'Settings',             // page_title
    'Settings',             // menu_title
    'manage_options',       // capability
    'my-plugin-settings',   // menu_slug
    'render_settings_page'  // callback
);
```

## Settings API

```php
// Register settings
add_action( 'admin_init', function() {
    register_setting( 'my_options_group', 'my_option_name', array(
        'type' => 'string',
        'sanitize_callback' => 'sanitize_text_field',
        'default' => '',
    ));

    add_settings_section( 'my_section', 'Section Title', '__return_null', 'my-settings' );

    add_settings_field(
        'my_field',
        'Field Label',
        function() {
            $val = get_option( 'my_option_name' );
            echo '<input type="text" name="my_option_name" value="' . esc_attr( $val ) . '" />';
        },
        'my-settings',
        'my_section'
    );
});

// Render settings form
function render_settings_page() {
    echo '<div class="wrap"><h1>Settings</h1><form method="post" action="options.php">';
    settings_fields( 'my_options_group' );
    do_settings_sections( 'my-settings' );
    submit_button();
    echo '</form></div>';
}
```

## Custom Post Types & Taxonomies

```php
add_action( 'init', function() {
    register_post_type( 'product_review', array(
        'labels' => array(
            'name' => 'Reviews',
            'singular_name' => 'Review',
        ),
        'public' => true,
        'has_archive' => true,
        'show_in_rest' => true,  // Enable Gutenberg
        'supports' => array( 'title', 'editor', 'thumbnail', 'custom-fields' ),
        'menu_icon' => 'dashicons-star-filled',
        'rewrite' => array( 'slug' => 'reviews' ),
    ));

    register_taxonomy( 'review_category', 'product_review', array(
        'labels' => array( 'name' => 'Review Categories' ),
        'hierarchical' => true,
        'show_in_rest' => true,
        'rewrite' => array( 'slug' => 'review-category' ),
    ));
});
```

## AJAX

```php
// PHP handler (logged-in and not-logged-in users)
add_action( 'wp_ajax_my_action', 'my_ajax_handler' );
add_action( 'wp_ajax_nopriv_my_action', 'my_ajax_handler' );

function my_ajax_handler() {
    check_ajax_referer( 'my_nonce', 'security' );
    $data = sanitize_text_field( $_POST['data'] );
    // Process...
    wp_send_json_success( array( 'message' => 'Done' ) );
}

// JS (enqueue with localized data)
function my_enqueue_ajax_script() {
    wp_enqueue_script( 'my-ajax', plugin_dir_url( __FILE__ ) . 'js/ajax.js', array( 'jquery' ) );
    wp_localize_script( 'my-ajax', 'myAjax', array(
        'url' => admin_url( 'admin-ajax.php' ),
        'nonce' => wp_create_nonce( 'my_nonce' ),
    ));
}
add_action( 'wp_enqueue_scripts', 'my_enqueue_ajax_script' );
```

```javascript
// js/ajax.js
jQuery(function($) {
    $.post(myAjax.url, {
        action: 'my_action',
        security: myAjax.nonce,
        data: 'value'
    }, function(response) {
        if (response.success) {
            console.log(response.data.message);
        }
    });
});
```

## WP-Cron

```php
// Schedule event on activation
register_activation_hook( __FILE__, function() {
    if ( ! wp_next_scheduled( 'my_cron_hook' ) ) {
        wp_schedule_event( time(), 'hourly', 'my_cron_hook' );
    }
});

// Handle event
add_action( 'my_cron_hook', function() {
    // Do scheduled task
});

// Clean up on deactivation
register_deactivation_hook( __FILE__, function() {
    wp_clear_scheduled_hook( 'my_cron_hook' );
});

// Custom interval
add_filter( 'cron_schedules', function( $schedules ) {
    $schedules['fifteen_minutes'] = array(
        'interval' => 900,
        'display' => 'Every 15 Minutes',
    );
    return $schedules;
});
```

## Internationalization

```php
// Load text domain
add_action( 'plugins_loaded', function() {
    load_plugin_textdomain( 'my-plugin', false, dirname( plugin_basename( __FILE__ ) ) . '/languages' );
});

// Usage
__( 'Translatable string', 'my-plugin' );         // Return
_e( 'Translatable string', 'my-plugin' );          // Echo
esc_html__( 'Safe translated string', 'my-plugin' ); // Escaped return
printf( __( 'Hello, %s!', 'my-plugin' ), $name );  // With placeholder
_n( '%d item', '%d items', $count, 'my-plugin' );  // Plurals
```

## Database Tables

```php
function my_create_table() {
    global $wpdb;
    $table = $wpdb->prefix . 'my_table';
    $charset_collate = $wpdb->get_charset_collate();

    $sql = "CREATE TABLE $table (
        id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
        user_id bigint(20) unsigned NOT NULL,
        data text NOT NULL,
        created_at datetime DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY user_id (user_id)
    ) $charset_collate;";

    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta( $sql );
}
register_activation_hook( __FILE__, 'my_create_table' );
```

## WooCommerce Plugin Integration

### Declare HPOS Compatibility
```php
add_action( 'before_woocommerce_init', function() {
    if ( class_exists( \Automattic\WooCommerce\Utilities\FeaturesUtil::class ) ) {
        \Automattic\WooCommerce\Utilities\FeaturesUtil::declare_compatibility(
            'custom_order_tables', __FILE__, true
        );
    }
});
```

### Check WooCommerce Active
```php
if ( in_array( 'woocommerce/woocommerce.php', apply_filters( 'active_plugins', get_option( 'active_plugins' ) ) ) ) {
    // WooCommerce is active
}
```

### Add Product Tab
```php
add_filter( 'woocommerce_product_tabs', function( $tabs ) {
    $tabs['custom_tab'] = array(
        'title'    => __( 'Custom Tab', 'my-plugin' ),
        'priority' => 50,
        'callback' => function() {
            echo '<h2>Custom Content</h2>';
            echo '<p>Tab content here.</p>';
        },
    );
    return $tabs;
});
```

### Custom Product Data Panel
```php
add_filter( 'woocommerce_product_data_tabs', function( $tabs ) {
    $tabs['my_custom'] = array(
        'label'  => 'My Data',
        'target' => 'my_custom_data',
    );
    return $tabs;
});

add_action( 'woocommerce_product_data_panels', function() {
    echo '<div id="my_custom_data" class="panel woocommerce_options_panel">';
    woocommerce_wp_text_input( array(
        'id' => '_my_custom_field',
        'label' => 'Custom Field',
    ));
    echo '</div>';
});

add_action( 'woocommerce_process_product_meta', function( $post_id ) {
    update_post_meta( $post_id, '_my_custom_field',
        sanitize_text_field( $_POST['_my_custom_field'] ?? '' )
    );
});
```

### Custom Order Status
```php
add_action( 'init', function() {
    register_post_status( 'wc-custom-status', array(
        'label' => 'Custom Status',
        'public' => true,
        'show_in_admin_status_list' => true,
        'label_count' => _n_noop( 'Custom <span class="count">(%s)</span>', 'Custom <span class="count">(%s)</span>' ),
    ));
});

add_filter( 'wc_order_statuses', function( $statuses ) {
    $statuses['wc-custom-status'] = 'Custom Status';
    return $statuses;
});
```
