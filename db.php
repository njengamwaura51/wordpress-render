<?php
/**
 * Plugin Name: TiDB Database Drop-in
 * Description: Compatibility drop-in for TiDB Cloud Serverless to prevent unsupported utf8mb4_unicode_520_ci collation errors.
 */

if (!defined('ABSPATH')) {
    exit;
}

class wpdb_tidb extends wpdb {
    public function has_cap($db_cap) {
        if ($db_cap === 'utf8mb4_520') {
            return false;
        }
        return parent::has_cap($db_cap);
    }

    public function determine_charset($charset, $collate) {
        $result = parent::determine_charset($charset, $collate);
        if (!empty($result['collate']) && strpos($result['collate'], '520') !== false) {
            $result['collate'] = 'utf8mb4_general_ci';
        }
        if (empty($result['collate'])) {
            $result['collate'] = 'utf8mb4_general_ci';
        }
        return $result;
    }
}

if (!isset($wpdb)) {
    $wpdb = new wpdb_tidb(DB_USER, DB_PASSWORD, DB_NAME, DB_HOST);
}
