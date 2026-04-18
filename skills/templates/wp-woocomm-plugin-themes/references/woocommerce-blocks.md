# WooCommerce Blocks Reference

## Table of Contents
- Available WooCommerce Blocks
- Block Registration & Development
- Scaffolding with @woocommerce/create-product-editor-block
- Block Attributes & InnerBlocks
- Store API for Blocks

## Available WooCommerce Blocks

### Product Blocks
| Block | Slug | Description |
|-------|------|-------------|
| All Products | `woocommerce/all-products` | Display all products with filters |
| Product Collection | `woocommerce/product-collection` | Curated product display |
| Featured Product | `woocommerce/featured-product` | Highlight single product |
| Featured Category | `woocommerce/featured-category` | Highlight product category |
| Hand-picked Products | `woocommerce/handpicked-products` | Manually selected products |
| Best Selling Products | `woocommerce/product-best-sellers` | Top sellers |
| Newest Products | `woocommerce/product-new` | Latest products |
| On Sale Products | `woocommerce/product-on-sale` | Discounted products |
| Top Rated Products | `woocommerce/product-top-rated` | Highest rated |
| Products by Category | `woocommerce/product-category` | Filter by category |
| Products by Tag | `woocommerce/product-tag` | Filter by tag |
| Products by Attribute | `woocommerce/product-attribute` | Filter by attribute |

### Cart & Checkout Blocks
| Block | Slug | Description |
|-------|------|-------------|
| Cart | `woocommerce/cart` | Full cart block |
| Checkout | `woocommerce/checkout` | Full checkout block |
| Mini Cart | `woocommerce/mini-cart` | Compact cart widget |

### Filter Blocks
| Block | Slug | Description |
|-------|------|-------------|
| Filter by Price | `woocommerce/price-filter` | Price range slider |
| Filter by Attribute | `woocommerce/attribute-filter` | Attribute checkboxes |
| Filter by Rating | `woocommerce/rating-filter` | Star rating filter |
| Filter by Stock | `woocommerce/stock-filter` | In/out of stock |
| Active Filters | `woocommerce/active-filters` | Show applied filters |

### Single Product Blocks
| Block | Slug | Description |
|-------|------|-------------|
| Product Image | `woocommerce/product-image` | Product photo/gallery |
| Product Title | `woocommerce/product-title` | Product name |
| Product Price | `woocommerce/product-price` | Price display |
| Add to Cart | `woocommerce/add-to-cart-form` | Add to cart button |
| Product Rating | `woocommerce/product-rating` | Star rating |
| Product Reviews | `woocommerce/product-reviews` | Customer reviews |
| Product Details | `woocommerce/product-details` | Tabs/accordion |
| Product Meta | `woocommerce/product-meta` | SKU, categories, tags |
| Related Products | `woocommerce/related-products` | Related items |

### Account Blocks
| Block | Slug | Description |
|-------|------|-------------|
| Customer Account | `woocommerce/customer-account` | Account link/icon |
| Order Confirmation | `woocommerce/order-confirmation` | Thank you page |

## Block Registration & Development

### Scaffold a WooCommerce Block
```bash
npx @wordpress/create-block my-woo-block --template @woocommerce/create-product-editor-block
```

Or via WP-CLI:
```bash
wp scaffold block my-block --plugin=my-plugin --title="My Block"
```

### Register Block in PHP
```php
add_action( 'init', function() {
    register_block_type( __DIR__ . '/build/my-block' );
});
```

### block.json (WooCommerce-aware)
```json
{
    "$schema": "https://schemas.wp.org/trunk/block.json",
    "apiVersion": 3,
    "name": "my-plugin/custom-product-block",
    "title": "Custom Product Block",
    "category": "woocommerce",
    "parent": ["woocommerce/all-products"],
    "description": "A custom WooCommerce product block.",
    "attributes": {
        "productId": { "type": "number" },
        "columns": { "type": "number", "default": 3 }
    },
    "supports": {
        "align": true,
        "color": { "background": true, "text": true }
    },
    "editorScript": "file:./index.js",
    "editorStyle": "file:./index.css",
    "style": "file:./style-index.css"
}
```

### Extend Checkout with Block
```php
use Automattic\WooCommerce\Blocks\Integrations\IntegrationInterface;

class My_Checkout_Integration implements IntegrationInterface {
    public function get_name() { return 'my-checkout-addon'; }
    public function get_script_handles() { return ['my-checkout-script']; }
    public function get_editor_script_handles() { return ['my-checkout-editor']; }
    public function get_script_data() {
        return ['setting' => get_option('my_setting')];
    }
    public function initialize() {
        $this->register_scripts();
    }
}

add_action( 'woocommerce_blocks_checkout_block_registration', function( $integration_registry ) {
    $integration_registry->register( new My_Checkout_Integration() );
});
```

## Store API for Blocks

WooCommerce Blocks use the Store API (REST-based) for cart/checkout:

### Key Endpoints
```
GET  /wc/store/v1/cart              # Get cart
POST /wc/store/v1/cart/add-item     # Add to cart
POST /wc/store/v1/cart/remove-item  # Remove from cart
POST /wc/store/v1/cart/update-item  # Update quantity
GET  /wc/store/v1/products          # List products
GET  /wc/store/v1/products/{id}     # Single product
POST /wc/store/v1/checkout          # Place order
```

### Extend Store API
```php
use Automattic\WooCommerce\StoreApi\Schemas\V1\CartSchema;

add_action( 'woocommerce_blocks_loaded', function() {
    woocommerce_store_api_register_endpoint_data( array(
        'endpoint' => CartSchema::IDENTIFIER,
        'namespace' => 'my-plugin',
        'data_callback' => function() {
            return ['custom_data' => 'value'];
        },
        'schema_callback' => function() {
            return [
                'custom_data' => [
                    'description' => 'Custom cart data',
                    'type' => 'string',
                    'context' => ['view', 'edit'],
                ],
            ];
        },
    ));
});
```
