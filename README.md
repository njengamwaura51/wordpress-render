# WordPress on Render with ThemeIsle Pro Suite

Pre-configured, production-ready WordPress deployment designed specifically for **Render** using Docker, Persistent Disks, and MariaDB.

---

## 🚀 1-Click Deploy to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/njengamwaura51/wordpress-render)

Click the button above or visit:
**[https://render.com/deploy?repo=https://github.com/njengamwaura51/wordpress-render](https://render.com/deploy?repo=https://github.com/njengamwaura51/wordpress-render)**

Render will automatically parse `render.yaml` and provision:
1. **`wordpress-app` (Web Service)**: High-performance PHP/Apache WordPress container with reverse-proxy SSL & dynamic site URL handling.
2. **`wordpress-db` (Private Service)**: Secure MariaDB database pre-populated with your initial database dump.
3. **Persistent Disks**: Mounted to `/var/www/html/wp-content` and `/var/lib/mysql` so your uploads, products, posts, and database persist permanently across all redeploys.

---

## 📦 Pre-Packaged Products Included

* **Neve FSE** Theme
* **Neve** Base Theme
* **Neve Pro** Plugin (`v3.2.13`)
* **Sparks for WooCommerce** Plugin (`v2.0.5`)
* **Otter Pro** Plugin (`v3.2.7`)
* **Otter Blocks (Base)** Plugin (`v3.2.7`)
* **WooCommerce (Base)** Plugin (`v11.2.1`)
* **Templates Cloud** Plugin (`v1.0.4`)
* **WP Landing Kit** Plugin (`v1.6.4`)

---

## 🌐 Connecting Your Custom Domain

1. In the **Render Dashboard**, click on your **`wordpress-app`** web service.
2. Go to **Settings** → **Custom Domains** → **Add Custom Domain**.
3. Enter your domain (e.g. `yourdomain.com` or `shop.yourdomain.com`).
4. Point your DNS records at your domain registrar:
   * **Subdomain (`shop.yourdomain.com`):** Add a `CNAME` pointing to your Render service address (e.g., `wordpress-app-xxxx.onrender.com`).
   * **Root domain (`yourdomain.com`):** Add an `A` record pointing to `216.24.57.1` (or `ANAME`/`ALIAS`).
5. Render will automatically issue a free SSL certificate (HTTPS), and your ThemeIsle license activation will work seamlessly.
