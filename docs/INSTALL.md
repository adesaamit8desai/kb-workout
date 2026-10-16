# Installing KB Workout on your iPhone

Apple only lets an iPhone run apps that are signed. With a **free Apple ID** you can sign apps for your own phone, but the signature lasts **7 days**, and you can have at most **3** such apps installed (SideStore counts as one).
**SideStore** handles this for you: it installs the app and re-signs it in the background over Wi-Fi before the 7 days run out.

## 1. Set up SideStore (one time)

Follow the official guide: <https://docs.sidestore.io>. It covers:

- Turning on **Developer Mode** (Settings → Privacy & Security → Developer Mode).
- Creating a **pairing file**, which lets SideStore talk to your phone.
- Installing **LocalDevVPN**, the small helper VPN app SideStore uses to sign and refresh apps.
- Signing in to SideStore with your **Apple ID**. Your password goes only to Apple.

> **No computer?** The official guide expects a computer (Windows, Mac or Linux) once, for the pairing file. There are iPhone-only methods (e.g. SideInstaller), but they come from third parties rather than the SideStore project, so use them at your own risk. Borrowing any computer for 15 minutes is the safer route.

## 2. Add the KB Workout source

In SideStore → **Sources** → **+**, add:

```
https://github.com/adesaamit8desai/kb-workout/releases/latest/download/source.json
```

Then open **KB Workout** in the source and tap **Install**.

If adding the source doesn't work, use the fallback: open the latest release in Safari, download `KBWorkout.ipa`, then in SideStore → **My Apps** tap **+** and choose the file from Downloads.
<https://github.com/adesaamit8desai/kb-workout/releases/latest>

## 3. Updates

Each change produces a new build in a few minutes. In SideStore → **My Apps**, tap **Update** (or reinstall the latest `.ipa`). Your workout history is kept.

## Keeping it working

- Open SideStore every few days with LocalDevVPN switched on, so it can refresh the 7-day signature (it also tries automatically in the background).
- If the app ever says it's no longer available, open SideStore and tap **Refresh All**.
