# Installing KB Workout on your iPhone (with a Chromebook)

You need: your iPhone, a USB cable that fits your iPhone, your Chromebook, and your Apple ID.
Allow about 30–45 minutes the first time. After that, updates take a minute and are done on the phone.

Apple only lets an iPhone run apps that are signed. A **free Apple ID** can sign apps for your own phone, but each signature lasts **7 days**, and you can have at most **3** such apps (SideStore counts as one).
**SideStore** is an app that installs KB Workout and re-signs it before it expires. The Chromebook is only needed **once**, to install SideStore.

---

## Part 1 — Get the iPhone ready (5 min)

1. On the iPhone, open the **App Store** and install **LocalDevVPN** (free). Don't set it up yet.
2. Make sure the iPhone is on the **same Wi-Fi** you'll use day to day.

## Part 2 — Turn on Linux on the Chromebook (10 min, one time)

1. Open **Settings** → **About ChromeOS** → **Developers** → **Linux development environment** → **Set up**. Accept the defaults and wait for it to finish. A black **Terminal** window opens.
   *If you can't find this option, the Chromebook may be managed by a school or work account, which can block Linux.*
2. In the Terminal, type each line below and press Enter. When it asks `Do you want to continue?`, type `y`.

   ```
   sudo apt update
   sudo apt install -y usbmuxd libimobiledevice-utils wget
   dpkg --print-architecture
   ```

   The last line prints either **amd64** or **arm64**. Remember which.

3. Download and install **iloader**, SideStore's official installer. Use the pair of lines that matches your answer above:

   **amd64:**
   ```
   wget https://github.com/nab138/iloader/releases/latest/download/iloader-linux-amd64.deb
   sudo apt install -y ./iloader-linux-amd64.deb
   ```

   **arm64:**
   ```
   wget https://github.com/nab138/iloader/releases/latest/download/iloader-linux-arm64.deb
   sudo apt install -y ./iloader-linux-arm64.deb
   ```

## Part 3 — Connect the iPhone to Linux (5 min)

1. Unlock the iPhone and plug it into the Chromebook with the cable.
2. ChromeOS shows a notification about the new USB device. Choose **Connect to Linux**.
   *Missed it? Settings → About ChromeOS → Developers → Linux development environment → **Manage USB devices** → switch on the iPhone.*
3. The iPhone asks **"Trust This Computer?"** → tap **Trust** and enter your passcode.
4. Check that Linux can see the phone. In the Terminal:

   ```
   idevice_id -l
   ```

   You should see a long ID (letters and numbers). If nothing appears:
   ```
   sudo systemctl restart usbmuxd
   idevice_id -l
   ```
   Still nothing? Unplug, plug back in, choose **Connect to Linux** again, then retry.

## Part 4 — Install SideStore (10 min)

1. In the Terminal, type `iloader` and press Enter. (It also appears in the launcher under **Linux apps**.)
2. **Sign in with your Apple ID.** The password goes to Apple to create your free developer certificate. If Apple sends a code to your phone, enter it.
3. Your iPhone appears in iloader. Choose **Install SideStore**. Wait until it says it's finished. iloader also sets up SideStore's *pairing file* automatically.
4. On the iPhone, turn on **Developer Mode**: **Settings → Privacy & Security → Developer Mode** → on → **Restart**. After the restart, tap **Turn On** and enter your passcode.
   *(This option only appears after step 3.)*
5. If the iPhone says the developer isn't trusted: **Settings → General → VPN & Device Management** → tap your Apple ID → **Trust**.

You can unplug the iPhone now. You don't need the Chromebook again unless you reset or update your iPhone and SideStore stops working (then repeat Parts 3–4).

## Part 5 — Install KB Workout (5 min, all on the iPhone)

1. Open **LocalDevVPN** and turn it **on**. (Allow it to add a VPN configuration when asked.)
2. Open **SideStore** and sign in with the **same Apple ID**.
3. Go to the **Sources** tab → **+** → paste this address → **Add**:

   ```
   https://github.com/adesaamit8desai/kb-workout/releases/latest/download/source.json
   ```

4. Tap **KB Workout** in the source → **Install** (Free). Wait for it to finish.
5. Find **KB Workout** on your home screen and open it. 🎉

**If adding the source doesn't work**, use the backup method:
open <https://github.com/adesaamit8desai/kb-workout/releases/latest> in Safari → tap **KBWorkout.ipa** → **Download**.
Then SideStore → **My Apps** → **+** (top left) → choose **KBWorkout.ipa** from Downloads.

## Keeping it working

- **Every few days:** turn on LocalDevVPN, open SideStore → **My Apps** → **Refresh All**. This renews the 7-day signature. SideStore also tries to do this on its own in the background.
- **Updates:** when there's a new version, SideStore → **My Apps** shows **Update**. Tap it (with LocalDevVPN on). Your workout history is kept.
- **"Unable to verify app" / app won't open:** the 7 days ran out. Turn on LocalDevVPN, open SideStore → **Refresh All**.
- **SideStore can't connect:** make sure Wi-Fi and LocalDevVPN are both on. If it keeps failing (often after an iOS update), redo Parts 3–4 on the Chromebook to refresh the pairing file.

Official docs: <https://docs.sidestore.io> · iloader: <https://github.com/nab138/iloader>
