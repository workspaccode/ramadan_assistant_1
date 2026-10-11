# Legal Pages — Hosting Guide

Google Play **requires** a live, public privacy policy URL for every app that
requests sensitive permissions (this app requests location, notifications,
exact alarms, and overlay).

⚠️ **BLOCKER:** `https://tawabti.app/privacy` and `https://tawabti.app/terms`
are currently **unreachable**. The app's Settings screen links to them. Fix
before submitting to Play Console.

## What to host

| File | Target URL | Used by |
|---|---|---|
| `privacy_policy.html` | `https://tawabti.app/privacy` | Settings → Privacy Policy |
| `terms_of_service.html` | `https://tawabti.app/terms` | Settings → Terms of Service |
| (optional) about page | `https://tawabti.app/about` | Settings → About App |

## Quick free hosting options

1. **GitHub Pages** — create a repo, push these two HTML files, enable Pages.
   Then either point a `tawabti.app` CNAME at it, or change the URLs in
   `lib/presentation/screens/settings_screen/widgets/settings_screen_content.dart`.
2. **Firebase Hosting** — you already use Firebase: `firebase init hosting`,
   put the files in the public folder, `firebase deploy`.
3. **Any static host** (Netlify / Vercel / Cloudflare Pages).

## Before submitting to Play Console

- [ ] Update the support e-mail in both files (`support@tawabti.app`).
- [ ] Update the "Last updated" dates.
- [ ] Keep the **Data safety** form answers consistent with the summary table
      in `privacy_policy.html`.
- [ ] Make sure the page loads **without login** and is reachable from all
      countries where the app is published.