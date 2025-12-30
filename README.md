# InstaCV

A single-page resume you can host anywhere.

## Quick start

1. Open `data.js` and replace the sample content with your own data.
2. Open `index.html` in a browser (or upload the whole folder to your hosting).

## Filling the data

- `data.js` contains your profile, experience, projects, and links.
- **Base64 images:** convert an image at [codebeautify.org](https://codebeautify.org/image-to-base64-converter) and use the value from the `CSS Background Source` block.
- **Or use my builder app** - `InstaCV.Builder` at [https://instacv.fushimyshi.com](https://instacv.fushimyshi.com/). No auth required; no data or keys are stored.

## What to upload

Upload the entire folder contents (keep file structure intact) into your hosting. The app is fully static.

## How to Put This Website Online (Netlify)

This folder contains a script that will automatically upload these files to the internet using Netlify. If you made changes to the code, you can run the script again to update the website.

### Phase 1: Get your "Access Token"

You only need to do this once. The script will save the token safely so you don't have to type it again.

1.  **Register:**

    - Go to https://app.netlify.com/signup
    - Sign up with Email.
    - Verify your email address if asked.

2.  **Get the Token:**

    - Once logged in, click your **User Avatar** (bottom-left) -> **User settings**.
    - On the left, click **Applications** -> **Personal access tokens**.
    - Click **New access token**.
    - **Description:** "Website Upload Script".
    - **Expiration:** "No expiration".
    - Click **Generate token**.

3.  **Copy the Token:**
    - Copy the long string of text immediately. You will need it in Phase 2.

---

### Phase 2: Run the Deploy Script

#### On macOS (Mac)

1.  Double-click **`deploy.command`**.
2.  **First Run:**
    - It will ask for your **Token** (paste it and press Enter).
    - It will ask for a **Project ID**.
      - To create a **NEW** project: Just press **Enter**.
      - To update an **EXISTING** project: Paste your Project ID (see instructions below).
3.  **Future Runs:**
    - Just double-click! It remembers your Token and Project.
    - It automatically excludes hidden system files (like .git) from the upload.

#### On Windows

_Prerequisite: Install "Git Bash"._

1.  Right-click **`deploy.command`**.
2.  Select **"Open with..."** -> **"Git Bash"**.
3.  Follow the prompts.

---

#### How to find your Project ID (Existing Projects)

If you want to link this script to a project you already created manually:

1.  Log in to Netlify.
2.  **Select a project** from your team list.
3.  Click **Project configuration** (in the sidebar).
4.  Click **General** (in the submenu).
5.  Look for **Project ID** (usually under "Project details").
6.  Copy that code (it looks like `12345678-abcd-1234...`).

---

### Phase 3: Custom Domain (Optional)

If you want a name like `www.mysite.com`:

1.  Go to Netlify.com, click your project, and go to **Domain Settings**.
2.  Add your domain there.
3.  The next time you run `deploy.command`, the script will automatically show your new custom URL.

---

### Troubleshooting & Resetting

If you pasted the wrong token, or if you want to switch to a completely different Netlify account or project, you can "Reset" the script.

#### Using the Clean Command

You can run the script with a special flag to wipe the saved settings.

**On Mac:**

1. Open Terminal.
2. Drag `deploy.command` into the terminal window.
3. Add ` --clean` to the end of the line and press Enter.
   Example: `/Users/name/folder/deploy.command --clean`

**On Windows (Git Bash):**

1. Right-click the folder background -> "Git Bash Here".
2. Type: `./deploy.command --clean` and press Enter.

---

## License

MIT. See [LICENSE](LICENSE).

---

If this helped you, you can say "thank you" with a PayPal donation (Friends and Family): [paypal.me/shvaykovski](https://paypal.me/shvaykovski).
