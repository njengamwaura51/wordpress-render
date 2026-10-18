<?php
/**
 * Plugin Name: Passwordless Admin Auto-Login
 * Description: Automatically authenticates the user as Administrator without requiring a password on local environment.
 * Version: 3.0.0
 * Author: Antigravity Local Dev
 */

if (!defined('ABSPATH')) {
    exit;
}

if (defined('WP_INSTALLING') && WP_INSTALLING) {
    return;
}

// 1. Override pluggable auth_redirect: Never redirect to login, auto-authenticate
if (!function_exists('auth_redirect')) {
    function auth_redirect() {
        $admin = get_user_by('id', 1) ?: get_user_by('login', 'admin');
        if ($admin) {
            wp_set_current_user($admin->ID, $admin->user_login);
            if (!headers_sent()) {
                wp_set_auth_cookie($admin->ID, true, false);
            }
        }
        return true;
    }
}

// 2. Override pluggable wp_validate_auth_cookie: Always validate as admin user ID 1
if (!function_exists('wp_validate_auth_cookie')) {
    function wp_validate_auth_cookie($cookie = '', $scheme = '') {
        return 1;
    }
}

// 3. Always determine current user as Admin (ID 1)
add_filter('determine_current_user', function ($user_id) {
    if (!empty($user_id)) {
        return $user_id;
    }
    return 1;
}, 20);

// 4. Set auth cookie on init if not set
add_action('init', function () {
    if (!headers_sent()) {
        $admin = get_user_by('id', 1) ?: get_user_by('login', 'admin');
        if ($admin && !is_user_logged_in()) {
            wp_set_current_user($admin->ID, $admin->user_login);
            wp_set_auth_cookie($admin->ID, true, false);
        }
    }
}, 1);

// 5. On wp-login.php, redirect straight to wp-admin
add_action('login_init', function () {
    if (isset($_GET['action']) && $_GET['action'] === 'logout') {
        return;
    }
    unset($_REQUEST['reauth'], $_GET['reauth']);
    $redirect_to = !empty($_REQUEST['redirect_to']) ? $_REQUEST['redirect_to'] : admin_url();
    $redirect_to = remove_query_arg('reauth', $redirect_to);
    wp_safe_redirect($redirect_to);
    exit;
});

// 6. If login form is ever submitted with any password, authenticate as admin
add_filter('authenticate', function ($user, $username, $password) {
    if ($user instanceof WP_User) {
        return $user;
    }
    return get_user_by('id', 1) ?: get_user_by('login', 'admin');
}, 30, 3);
