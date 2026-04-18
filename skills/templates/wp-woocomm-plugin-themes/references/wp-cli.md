# WP-CLI Command Reference

## Table of Contents
- Core Commands
- Plugin Management
- Theme Management
- WooCommerce Commands
- Database & Content
- Development & Scaffolding
- Server & Maintenance

## Core Commands

```bash
wp core download                     # Download WordPress
wp core install --url=... --title=... --admin_user=... --admin_password=... --admin_email=...
wp core update                       # Update WordPress
wp core version                      # Show version
wp core verify-checksums             # Verify file integrity
```

## Plugin Management

```bash
wp plugin list                       # List all plugins
wp plugin install <slug>             # Install from WP.org
wp plugin install <zip-url>          # Install from URL
wp plugin activate <slug>            # Activate
wp plugin deactivate <slug>          # Deactivate
wp plugin delete <slug>              # Delete
wp plugin update --all               # Update all plugins
wp plugin status                     # Show status of all plugins
wp plugin search <term>              # Search WP.org repo
wp plugin is-installed <slug>        # Check if installed
wp plugin is-active <slug>           # Check if active
```

## Theme Management

```bash
wp theme list                        # List themes
wp theme install <slug>              # Install
wp theme activate <slug>             # Activate
wp theme delete <slug>               # Delete
wp theme update --all                # Update all
wp theme status                      # Show status
wp theme mod list                    # List theme mods
wp theme mod get <key>               # Get theme mod value
wp theme mod set <key> <value>       # Set theme mod
```

## WooCommerce Commands

```bash
wp wc product list                   # List products
wp wc product create --name="..." --type=simple --regular_price=19.99
wp wc product update <id> --sale_price=14.99
wp wc order list                     # List orders
wp wc order create                   # Create order
wp wc customer list                  # List customers
wp wc shop_coupon create --code=SAVE10 --discount_type=percent --amount=10
wp wc tool run install_pages         # Install default WC pages
wp wc tool run clear_transients      # Clear WC transients
```
Note: WooCommerce CLI requires `--user=<id>` for authenticated commands.

## Database & Content

```bash
wp db export backup.sql              # Export database
wp db import backup.sql              # Import database
wp db query "SELECT ..."             # Run SQL query
wp db optimize                       # Optimize tables
wp db search "term"                  # Search DB for text

wp post list --post_type=product     # List by type
wp post create --post_title="..."    # Create post
wp post delete <id>                  # Delete post
wp post meta list <id>               # List post meta
wp post meta update <id> <key> <val> # Update meta

wp option get <key>                  # Get option
wp option update <key> <value>       # Set option
wp option delete <key>               # Delete option

wp transient delete --all            # Clear all transients
wp cache flush                       # Flush object cache
```

## Development & Scaffolding

```bash
# Scaffold plugin
wp scaffold plugin <slug> --plugin_name="My Plugin" --plugin_author="Author" --activate

# Scaffold child theme
wp scaffold child-theme <slug> --parent_theme=<parent> --theme_name="My Child" --activate

# Scaffold custom post type (in plugin)
wp scaffold post-type <slug> --plugin=<plugin-slug> --label="My Type"

# Scaffold taxonomy
wp scaffold taxonomy <slug> --post_types=<types> --plugin=<plugin-slug>

# Scaffold block
wp scaffold block <slug> --plugin=<plugin-slug> --title="My Block"

# Scaffold PHPUnit tests
wp scaffold plugin-tests <plugin-slug>
```

## Server & Maintenance

```bash
wp server                            # Launch dev server (port 8080)
wp server --port=3000                # Custom port

wp rewrite flush                     # Flush rewrite rules
wp rewrite structure '/%postname%/'  # Set permalink structure

wp cron event list                   # List cron events
wp cron event run <hook>             # Run cron event now
wp cron test                         # Test if cron is working

wp user create <login> <email> --role=administrator
wp user list --role=customer         # List by role
wp user update <id> --display_name="New Name"

wp search-replace 'old.com' 'new.com' --dry-run  # Preview
wp search-replace 'old.com' 'new.com'             # Execute

wp config set WP_DEBUG true --raw    # Enable debug
wp config set WP_DEBUG_LOG true --raw
wp config list                       # Show all config

wp maintenance-mode activate         # Enable maintenance
wp maintenance-mode deactivate       # Disable maintenance
```

## Useful Patterns

### Batch Operations
```bash
# Update all product prices
wp post list --post_type=product --format=ids | xargs -I {} wp post meta update {} _regular_price 29.99

# Export product IDs
wp post list --post_type=product --fields=ID,post_title --format=csv > products.csv

# Regenerate thumbnails
wp media regenerate --yes
```

### Development Workflow
```bash
# Full dev setup
wp core download && wp core install --url=localhost:8080 --title="Dev" --admin_user=admin --admin_password=admin --admin_email=dev@local.test
wp plugin install woocommerce --activate
wp wc tool run install_pages --user=1
wp theme install storefront --activate
wp config set WP_DEBUG true --raw
```
