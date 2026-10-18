<?php
/**
 * Plugin Name: ThemeIsle Pro Local License Activator
 * Description: Activates and unlocks all pro features for Neve Pro, Otter Pro, Sparks, Templates Cloud, and Landing Kit on local environments.
 * Version: 1.0.0
 * Author: Antigravity Local Dev
 */

if (!defined('ABSPATH')) {
    exit;
}

$themeisle_products = [
    'neve_pro_addon',
    'otter_pro',
    'sparks_for_woocommerce',
    'template_cloud_server',
    'wp_landing_kit',
    'neve_fse',
    'neve'
];

foreach ($themeisle_products as $key) {
    // 1. Force license status to 'valid'
    add_filter($key . '_license_status', function () {
        return 'valid';
    }, PHP_INT_MAX);

    add_filter('product_' . $key . '_license_status', function () {
        return 'valid';
    }, PHP_INT_MAX);

    // 2. Force plan to 'agency' / top tier
    add_filter($key . '_license_plan', function () {
        return 'agency';
    }, PHP_INT_MAX);

    add_filter('product_' . $key . '_license_plan', function () {
        return 'agency';
    }, PHP_INT_MAX);

    // 3. Fake valid license data object
    add_filter('pre_option_' . $key . '_license_data', function () {
        $data = new \stdClass();
        $data->license       = 'valid';
        $data->key           = 'LOCAL-PRO-LICENSE-ACTIVE';
        $data->plan          = 'agency';
        $data->expires       = 'lifetime';
        $data->customer_name = 'Local Admin';
        $data->is_expired    = 'no';
        return $data;
    }, PHP_INT_MAX);

    add_filter('pre_option_' . $key . '_license_plan', function () {
        return 'agency';
    }, PHP_INT_MAX);

    add_filter('pre_option_' . $key . '_license_status', function () {
        return 'valid';
    }, PHP_INT_MAX);
}

// Intercept ThemeIsle API remote license checks and return success
add_filter('pre_http_request', function ($preempt, $args, $url) {
    if (strpos($url, 'api.themeisle.com/license/') !== false) {
        $body = wp_json_encode([
            'license'       => 'valid',
            'key'           => 'LOCAL-PRO-LICENSE-ACTIVE',
            'plan'          => 'agency',
            'expires'       => 'lifetime',
            'customer_name' => 'Local Admin',
            'is_expired'    => 'no',
            'success'       => true,
            'checksum'      => 'local'
        ]);
        return [
            'response' => ['code' => 200, 'message' => 'OK'],
            'body'     => $body,
            'headers'  => ['content-type' => 'application/json'],
        ];
    }
    if (strpos($url, 'api.themeisle.com/sites/') !== false) {
        $demosites_url = preg_replace('#https://api\.themeisle\.com/sites/([^/]+)/#', 'https://demosites.io/$1/', $url);
        return wp_remote_request($demosites_url, $args);
    }
    return $preempt;
}, 10, 3);

// Auto-activate all ThemeIsle suite plugins and WooCommerce
add_filter('option_active_plugins', function ($plugins) {
    if (!is_array($plugins)) {
        $plugins = [];
    }
    $auto_active = [
        'neve-pro-addon/neve-pro-addon.php',
        'otter-blocks/otter-blocks.php',
        'otter-pro/otter-pro.php',
        'woocommerce/woocommerce.php',
        'sparks-for-woocommerce/sparks-for-woocommerce.php',
        'templates-patterns-collection/templates-patterns-collection.php',
        'template-cloud-server/template-cloud-server.php',
        'wp-landing-kit/wp-landing-kit.php',
    ];
    foreach ($auto_active as $plugin) {
        if (!in_array($plugin, $plugins, true)) {
            $plugins[] = $plugin;
        }
    }
    return $plugins;
});
