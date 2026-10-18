# WordPress on Render (Free Plan + External TiDB Cloud Database)

Pre-configured, production-ready WordPress deployment designed for **Render Free Tier** (Zero Credit Card Required) with **TiDB Cloud Serverless MySQL**.

---

## 🚀 1-Click Deploy to Render (No Card Required)

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/njengamwaura51/wordpress-render)

Click the button above or visit:
**[https://render.com/deploy?repo=https://github.com/njengamwaura51/wordpress-render](https://render.com/deploy?repo=https://github.com/njengamwaura51/wordpress-render)**

Render will automatically deploy:
* **`wordpress-app` (Web Service)** on the **Free Plan** (`plan: free`) with **no credit card needed**.
* Connected to your cloud-hosted **TiDB Serverless Database**.
* Automatic SSL/TLS encryption for database and web traffic.

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
   * **Subdomain (`shop.yourdomain.com`):** Add a `CNAME` pointing to your Render address (e.g., `wordpress-app-xxxx.onrender.com`).
   * **Root domain (`yourdomain.com`):** Add an `A` record pointing to `216.24.57.1` (or `ANAME`/`ALIAS`).
5. Render will automatically issue a free SSL certificate (HTTPS), and your ThemeIsle license activation will work seamlessly.
