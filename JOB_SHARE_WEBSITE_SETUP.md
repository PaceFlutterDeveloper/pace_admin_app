# Job share links — website / backend setup

This document is only for **paceeducation.com**. The Flutter app will share HTTPS job URLs. iOS and Android will open Smart PACE when it is installed **only if** this website work is live and valid. If it is not, every tap stays in the browser.

App work (Associated Domains, App Links intent-filters, `app_links`) is separate and is not covered here.

**Checked 29 Sep 2026:** both association files are missing, so Android opens Chrome and iOS opens Safari.

- `https://paceeducation.com/.well-known/assetlinks.json` → **404**
- `https://paceeducation.com/.well-known/apple-app-site-association` → **404**

Google’s checker reports `ERROR_CODE_FETCH_ERROR`. Deploy sections 4 and 5 first; the job page itself is already live.

---

## 1. What we are building

One public URL per job:

```text
https://paceeducation.com/careers/index.php?page=job&id={jobId}
```

Example:

```text
https://paceeducation.com/careers/index.php?page=job&id=116
```

| Situation | What should happen |
|---|---|
| App installed, OS verified the domain | OS opens Smart PACE on that job |
| App not installed | Same URL loads a landing page → App Store or Play Store |
| WhatsApp / Instagram in-app browser | Landing page shows **Open in app** (`paceerp://jobs/{id}`), then store fallback |
| Desktop browser | Landing page shows job details + store badges |

There is **no deferred deep link**. After a first install from the store, the next launch goes to careers home, not the original job.

The website must do three things:

1. Host association files so Apple and Google trust this domain for the app.
2. Serve a landing page at `/careers/index.php?page=job&id=` for when the app does not open.
3. Serve those files with the exact HTTP rules below. Wrong headers or a redirect will silently break verification.

---

## 2. Values to collect before going live

| Item | Status | Used for | Where to get it |
|---|---|---|---|
| Domain | Known: `paceeducation.com` | All URLs and association files | Canonical public site |
| Android package | Known: `com.paceEducation.erp` | `assetlinks.json`, Play Store URL | App / Play Console |
| iOS bundle ID | Known: `com.paceEducation.erp` | AASA `appIDs` | Xcode / App Store Connect |
| Apple Team ID | In the iOS project: `KL76YZPXR4` | AASA `appIDs` | [Apple Developer → Membership](https://developer.apple.com/account). Confirm it is the team that ships the App Store build. |
| Play signing SHA-256 | **You must paste this** | `assetlinks.json` | Play Console → app → **App integrity** / **App signing** → **App signing key certificate** → SHA-256 |
| Upload / local keystore SHA-256 | Known from `android/pace_key.jks`: `02:08:BC:B7:E4:13:59:F3:58:62:F2:D4:7D:A2:18:62:DA:6A:E6:54:90:F5:B2:65:A7:55:77:E1:42:D7:6A:2E` | `assetlinks.json` (local / upload-signed APKs) | `keytool -list -v -keystore android/pace_key.jks -alias pace` |
| App Store numeric ID | **You must paste this** | Landing page App Store button | App Store Connect → the app → **App Information** → **Apple ID** (numbers only, e.g. `1234567890`) |

Play SHA-256 must be the **app signing** certificate (the one Google uses on Play Store builds), not only the upload key, unless you do not use Play App Signing.

Format the fingerprint exactly as Play Console shows it (colon-separated hex):

```text
AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99
```

---

## 3. Host and path contract (do not change)

Use **apex** `paceeducation.com` (no `www`) as the host in association files and shared URLs.

If `www.paceeducation.com` is also used in the wild:

- 301 `www` → `https://paceeducation.com/...` **or**
- Host the same `.well-known` files on **both** hosts.

A redirect from `http://` to `https://` on the **site root** is fine. A redirect on the `.well-known` files themselves is **not**. Apple and Google must get `200` JSON at the HTTPS URL on the first hop.

Do not put association files only under `/careers/`. They must be at site root:

| File | Public URL | Notes |
|---|---|---|
| Apple AASA | `https://paceeducation.com/.well-known/apple-app-site-association` | **No** `.json` extension |
| Android Digital Asset Links | `https://paceeducation.com/.well-known/assetlinks.json` | Exact name |
| Job landing page | `https://paceeducation.com/careers/index.php?page=job&id={jobId}` | Same path the app claims |

---

## 4. File 1 — `apple-app-site-association`

**Path on disk (typical):** `/.well-known/apple-app-site-association`  
**Do not** name it `apple-app-site-association.json`.

Team ID below is from the current iOS project. Confirm before production.

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": [
          "KL76YZPXR4.com.paceEducation.erp"
        ],
        "components": [
          {
            "path": "/careers/index.php*"
          }
        ]
      }
    ]
  }
}
```

`appIDs` is `TEAM_ID` + `.` + `BUNDLE_ID`. Only `/careers/index.php*` is claimed so the rest of the marketing site stays in the browser.

### HTTP requirements (Apple)

- HTTPS
- Status `200`
- `Content-Type: application/json` (Apple also accepts `application/pkcs7-mime`; JSON is simpler)
- **No** `301` / `302` / `307` / `308` on this URL
- **No** HTML wrapper, login wall, or WAF interstitial
- Body must be valid JSON (no BOM, no trailing comments)

Apple caches AASA after install / update. Fixing the file does not always update existing installs until the app is reinstalled or Apple refreshes.

---

## 5. File 2 — `assetlinks.json`

**Path on disk:** `/.well-known/assetlinks.json`

Include the local release keystore SHA-256 below. If the Play Store build uses Play App Signing, **also** add the Play Console **App signing** SHA-256.

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.paceEducation.erp",
      "sha256_cert_fingerprints": [
        "02:08:BC:B7:E4:13:59:F3:58:62:F2:D4:7D:A2:18:62:DA:6A:E6:54:90:F5:B2:65:A7:55:77:E1:42:D7:6A:2E"
      ]
    }
  }
]
```

With Play App Signing as well:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.paceEducation.erp",
      "sha256_cert_fingerprints": [
        "PASTE_PLAY_APP_SIGNING_SHA256_HERE",
        "02:08:BC:B7:E4:13:59:F3:58:62:F2:D4:7D:A2:18:62:DA:6A:E6:54:90:F5:B2:65:A7:55:77:E1:42:D7:6A:2E"
      ]
    }
  }
]
```

### HTTP requirements (Google)

Same as AASA: HTTPS, `200`, `Content-Type: application/json`, no redirect.

Google’s checker:

```text
https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://paceeducation.com&relation=delegate_permission/common.handle_all_urls
```

---

## 6. How to host the `.well-known` files

These files cannot live only in the Flutter repo. They must be served from the **paceeducation.com** web root.

### nginx

```nginx
location ^~ /.well-known/apple-app-site-association {
    default_type application/json;
    add_header Content-Type application/json;
    try_files /path/to/apple-app-site-association =404;
}

location ^~ /.well-known/assetlinks.json {
    default_type application/json;
    add_header Content-Type application/json;
}

# Do not force a trailing slash or send these through a PHP front controller.
```

If the site is a PHP front-controller (`try_files $uri $uri/ /index.php`), add an exception **before** that rule so `/.well-known/*` is served as static files.

### Apache

```apache
<Directory "/var/www/html/.well-known">
    Require all granted
</Directory>

<Files "apple-app-site-association">
    Header set Content-Type "application/json"
</Files>

<Files "assetlinks.json">
    Header set Content-Type "application/json"
</Files>
```

Make sure `mod_rewrite` does not send `/.well-known/` to `index.php`.

### Cloudflare / CDN / WAF

- Do not challenge or block Applebot, Googlebot, or unknown datacenter IPs on `/.well-known/`.
- Do not inject HTML (email protection, rocket loader, “under attack”).
- Prefer cache bypass for these two URLs, or a short TTL after edits.

### Quick curl checks (must pass)

```bash
curl -sI https://paceeducation.com/.well-known/apple-app-site-association
curl -s  https://paceeducation.com/.well-known/apple-app-site-association

curl -sI https://paceeducation.com/.well-known/assetlinks.json
curl -s  https://paceeducation.com/.well-known/assetlinks.json
```

Expect:

- `HTTP/2 200` (or `HTTP/1.1 200`)
- `content-type` includes `application/json`
- **No** `location:` header
- Body is the JSON above, not an HTML 404

Also confirm there is **no extra hop**:

```bash
curl -sI http://paceeducation.com/.well-known/assetlinks.json
```

An HTTP → HTTPS redirect on `http://` is acceptable. The **HTTPS** URL must not redirect again.

---

## 7. Landing page at `/careers/index.php?page=job&id=`

This is the page the OS loads when the app is missing, or when an in-app browser skips Universal Links / App Links. It is already live; add **Open in app** (`paceerp://jobs/{id}`) if it is not on the page yet.

### URL

```text
GET https://paceeducation.com/careers/index.php?page=job&id={jobId}
```

`jobId` is the numeric `job_id` from careers API v2 (same id the mobile app uses).

The association files and the app claim `/careers/index.php` only.

### Data source (existing public API)

Server-side fetch (recommended, for Open Graph crawlers):

```text
GET https://paceeducation.com/careers/erp-api/index.php/job-details?id={jobId}
```

This is the same public endpoint the app uses. No auth.

Successful shape the app already parses (`status === true`):

```json
{
  "status": true,
  "data": {
    "job_id": 123,
    "title": "Primary Teacher",
    "location": "Dubai",
    "school": { "name": "PACE International School" },
    "country": { "name": "UAE" },
    "dates": {
      "posted": "2026-01-15",
      "deadline": "2026-03-01",
      "is_active": true
    },
    "description": { "html": "<p>...</p>" },
    "salary": { "range": "AED 8,000 - 12,000", "min_years": 2 },
    "details": { "employment_type": "Full-time" },
    "requirements": { "qualification": "...", "skills": "..." }
  }
}
```

If `status` is false or the job is missing, still return HTTP 200 HTML (or 404 HTML) with a friendly “Job not found” page and store buttons. Do not break association files if a job id is invalid.

### What to render

- Title, school name, location, country, employment type, salary range, deadline
- Short description (strip or sanitize HTML)
- Store buttons:
  - Play: `https://play.google.com/store/apps/details?id=com.paceEducation.erp`
  - App Store: `https://apps.apple.com/app/id{APPLE_APP_ID}`
- **Open in app** button: `paceerp://jobs/{jobId}`

### Open Graph (required for WhatsApp / iMessage)

Crawlers do not run much JavaScript. Render these tags in the **initial HTML**.

```html
<meta property="og:type" content="website" />
<meta property="og:site_name" content="Smart PACE Careers" />
<meta property="og:title" content="{job.title} — {school.name}" />
<meta property="og:description" content="{location} · {employment_type} · Apply in Smart PACE" />
<meta property="og:url" content="https://paceeducation.com/careers/index.php?page=job&id={jobId}" />
<meta property="og:image" content="https://paceeducation.com/careers/{static-share-image.png}" />
<meta name="twitter:card" content="summary_large_image" />
<title>{job.title} at {school.name}</title>
<link rel="canonical" href="https://paceeducation.com/careers/index.php?page=job&id={jobId}" />
```

Use a fixed careers/share image if jobs have no poster image. WhatsApp needs an absolute `https` image URL.

### Store routing on the page

Detect OS in the page (and keep visible buttons):

| Client | Primary action |
|---|---|
| iPhone / iPad | App Store URL |
| Android | Play Store URL |
| Desktop | Show both badges; do not auto-redirect |

Optional: after a few seconds on mobile, if the user did not leave, send them to the matching store. Do **not** auto-redirect desktop.

### “Open in app” custom scheme (required)

In-app browsers (WhatsApp, Instagram, Facebook) often **do not** trigger Universal Links / App Links. The landing page must offer:

```text
paceerp://jobs/{jobId}
```

Suggested behavior:

1. User taps **Open in app**.
2. `window.location = "paceerp://jobs/" + jobId`.
3. After ~1.5s, if the page is still visible, go to the store URL for that OS.

The Flutter app will register the `paceerp` scheme. Until that ships, the button will no-op and then fall through to the store — that is expected.

Do not use `intent://` only. Keep the `paceerp://` link as the documented fallback.

---

## 8. What the backend does **not** need to do

- No new mobile API for sharing. Job details already exist.
- No token, signed URL, or short-link service.
- No storing “last shared job” for first-open-after-install.
- No change to `job_id` format. Keep the numeric id.

Optional later (not required for v1): a short redirector like `https://paceeducation.com/j/123` — only if you also add that path to AASA, `assetlinks.json`, and the app. Prefer the long URL so one path stays in sync.

---

## 9. Suggested implementation on the current PHP site

The careers stack already lives under `https://paceeducation.com/careers/` and the API under `/careers/erp-api/index.php`.

A practical split:

1. **Static files** in the **site root** (not inside `/careers/`):
   - `/.well-known/apple-app-site-association`
   - `/.well-known/assetlinks.json`
2. **Keep** the existing job page at `/careers/index.php?page=job&id=` and add store + open-in-app buttons if they are missing.
   - Reads `{id}`
   - `file_get_contents` / curl to `.../job-details?id=`
   - Renders HTML + OG tags
   - Prints store + open-in-app buttons

Example route sketch (illustrative):

```php
// GET /careers/index.php?page=job&id=123
$jobId = (int) $id;
$url = 'https://paceeducation.com/careers/erp-api/index.php/job-details?id=' . $jobId;
$payload = json_decode(file_get_contents($url), true);
$job = ($payload['status'] ?? false) ? $payload['data'] : null;

$play = 'https://play.google.com/store/apps/details?id=com.paceEducation.erp';
$ios  = 'https://apps.apple.com/app/id' . APPLE_APP_ID; // set in config
$open = 'paceerp://jobs/' . $jobId;
```

If `/careers/` is a separate app with its own vhost, **still** put `.well-known` on the **apex** vhost (`paceeducation.com`), not only on a `/careers` subdirectory vhost.

---

## 10. Values to put in website config

```text
APPLE_TEAM_ID=KL76YZPXR4
IOS_BUNDLE_ID=com.paceEducation.erp
ANDROID_PACKAGE=com.paceEducation.erp
PLAY_STORE_URL=https://play.google.com/store/apps/details?id=com.paceEducation.erp
APPLE_APP_ID=          # numeric, from App Store Connect
PLAY_SIGNING_SHA256=   # from Play Console
UPLOAD_KEY_SHA256=02:08:BC:B7:E4:13:59:F3:58:62:F2:D4:7D:A2:18:62:DA:6A:E6:54:90:F5:B2:65:A7:55:77:E1:42:D7:6A:2E
CUSTOM_SCHEME=paceerp
JOB_PAGE=https://paceeducation.com/careers/index.php?page=job&id=
```

---

## 11. Website verification checklist

Do this **before** expecting the mobile app to open links.

- [ ] `https://paceeducation.com/.well-known/apple-app-site-association` → 200 JSON, no redirect
- [ ] AASA `appIDs` is `KL76YZPXR4.com.paceEducation.erp` (confirmed Team ID)
- [ ] `https://paceeducation.com/.well-known/assetlinks.json` → 200 JSON, no redirect
- [ ] `assetlinks.json` SHA-256 matches Play **app signing** certificate
- [ ] `https://www.paceeducation.com/.well-known/...` either 200 same JSON or 301 to apex **and** you never share `www` URLs — prefer hosting files on both
- [ ] `https://paceeducation.com/careers/index.php?page=job&id=116` loads for a real job id
- [ ] View-source shows `og:title`, `og:description`, `og:image` (not empty)
- [ ] WhatsApp preview shows job title, not a bare URL
- [ ] Android Play Integrity / Digital Asset Links list API returns the statement
- [ ] iOS: [Apple AASA validator](https://search.developer.apple.com/appsearch-validation-tool/) against `https://paceeducation.com/careers/index.php?page=job&id=116`
- [ ] Landing page **Open in app** uses `paceerp://jobs/{id}`
- [ ] iOS store button uses numeric App Store ID
- [ ] Android store button uses `com.paceEducation.erp`
- [ ] Closed / missing job still shows store buttons (no 500)

When the Flutter side is released, extra checks (not website work):

- Android: `adb shell am start -a android.intent.action.VIEW -d "https://paceeducation.com/careers/index.php?page=job&id={id}"`
- iOS: tap the URL from Notes (not from WhatsApp for the first Universal Link test)
- App installed → job detail
- App uninstalled → landing page → store

---

## 12. Common failures

| Symptom | Likely cause |
|---|---|
| App never opens; browser always loads | Association files missing, redirecting, or wrong `Content-Type` |
| Android verification fails | SHA-256 is upload key only, but Play resigns with a different cert |
| iOS never verifies | Wrong Team ID, Associated Domains not enabled on the App ID, or AASA path has `.json` |
| Works on `paceeducation.com` but not `www` | Files only on one host |
| WhatsApp preview is blank | OG tags rendered only by client-side JS |
| WhatsApp tap opens site, not app | Expected in in-app browsers; **Open in app** must use `paceerp://` |
| File looks fine in browser but Apple fails | WAF/JS challenge, or HTML error page for some user-agents |

---

## 13. Handoff summary for the web team

Ship this, in this order:

1. Confirm Apple Team ID `KL76YZPXR4` and collect Play signing SHA-256 + App Store numeric ID.
2. Publish AASA and `assetlinks.json` at `/.well-known/` with the JSON in sections 4 and 5.
3. Prove both URLs with `curl` (section 6).
4. Confirm `/careers/index.php?page=job&id=` shows job details and add **Open in app** (`paceerp://jobs/{id}`) if missing.
5. Tell the mobile team the `.well-known` files are live so they can reinstall the app and share `https://paceeducation.com/careers/index.php?page=job&id={jobId}`.
