const STYLE = `
  :root {
    --ink: #3d3a4a;
    --soft: #6f6a7d;
    --cream: #fff7e8;
    --sky: #e8f6ff;
    --butter: #ffe29a;
    --accent: #ffb347;
    --card: rgba(255,255,255,0.88);
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    font-family: ui-rounded, "Segoe UI", system-ui, -apple-system, sans-serif;
    color: var(--ink);
    background: linear-gradient(160deg, var(--cream), var(--sky));
    min-height: 100vh;
    line-height: 1.6;
  }
  .wrap { max-width: 760px; margin: 0 auto; padding: 40px 20px 64px; }
  header { display: flex; align-items: center; gap: 14px; margin-bottom: 28px; }
  .badge {
    width: 56px; height: 56px; border-radius: 16px;
    background: linear-gradient(135deg, var(--butter), var(--accent));
    display: grid; place-items: center; font-size: 28px;
    box-shadow: 0 8px 20px rgba(255,179,71,0.35);
  }
  h1 { margin: 0; font-size: 1.8rem; }
  .sub { color: var(--soft); margin: 4px 0 0; }
  nav { display: flex; flex-wrap: wrap; gap: 10px; margin: 18px 0 28px; }
  nav a {
    text-decoration: none; color: var(--ink); background: var(--card);
    padding: 10px 14px; border-radius: 999px; border: 1px solid rgba(255,255,255,0.8);
    font-weight: 600; font-size: 0.92rem;
  }
  nav a:hover { background: var(--butter); }
  .card {
    background: var(--card); border-radius: 24px; padding: 22px 22px;
    border: 1px solid rgba(255,255,255,0.75);
    box-shadow: 0 10px 30px rgba(61,58,74,0.06);
    white-space: pre-wrap;
  }
  .card h2 { margin-top: 0; }
  .muted { color: var(--soft); font-size: 0.95rem; }
  footer { margin-top: 28px; color: var(--soft); font-size: 0.85rem; }
  a.inline { color: var(--accent); font-weight: 700; }
`;

const TERMS = `Welcome to SoftDiary (the “App”). Please read these Terms of Use carefully before using the App. By tapping Agree and entering the App, you acknowledge that you have read and agree to these Terms in full.

1. Service Description
1. SoftDiary provides local journal writing, character portraits, hand-drawn sketches, photos, and voice notes.
2. The App runs primarily on your device. Core journal content is stored locally by default.
3. We may update features as the product evolves and will notify you in the App or by other reasonable means.

2. Account and Use
1. The current version does not require registration; you may use it without an account.
2. You agree to use the App lawfully and respectfully, and not for any illegal activity.
3. To the extent permitted by law, SoftDiary is not liable for data loss caused by your actions, device failure, or system limits. Please back up important content regularly.

3. Intellectual Property
1. The App’s interface design, copy, portrait style, and related software elements are protected by law.
2. Journal text, sketches, photos, and recordings you create remain yours. You grant SoftDiary only the rights needed to store and display them locally on your device.

4. Disclaimer
1. The App is provided “as is,” without warranties of uninterrupted or error-free service.
2. SoftDiary is not liable for indirect losses except where caused by intentional misconduct or gross negligence.

5. Changes and Termination
1. We may revise these Terms and will present updates in the App or similarly.
2. If you disagree with the changes, please stop using the App.

6. Governing Law
These Terms are governed by the laws of the People’s Republic of China (excluding conflict-of-law rules), except where mandatory local consumer laws apply.

Questions? Contact us via the developer contact details on the App Store page, or email the address listed on the Support page.`;

const PRIVACY = `SoftDiary takes your privacy seriously. This Policy explains how we collect, use, and protect information.

1. Information We Collect
1. Journal content: titles, body text, tags, moods, portrait poses, sketches, and any photos or recordings you add.
2. Device permissions: used only after you grant access, and only for the related feature:
   - Camera: capture journal photos;
   - Photo Library: choose journal photos;
   - Microphone: record voice notes;
   - Face ID / Touch ID: unlock the optional app lock.
3. The App does not require sign-in by default and does not actively collect sensitive identity details such as your name, phone number, or ID number.

2. Storage and Use
1. Journal text, sketches, photos, and recordings are stored locally on your device for display, editing, and playback.
2. We will not sell your journal content to third parties without your consent.
3. Cloud sync is not a default feature in this version. If cloud services are added later, we will explain them and obtain any required consent.

3. Permissions
1. You can turn off camera, photo library, microphone, or biometrics access in system Settings at any time. Related features may become unavailable; other local journal features remain available.
2. We will not request unrelated permissions without explaining their purpose.

4. Sharing and Disclosure
1. We will not disclose your journal content to third parties except as required by law, regulators, or to protect users and the public.
2. If analytics or crash reporting is ever embedded, only the minimum data needed for that service will be processed, with appropriate disclosure.

5. Children’s Privacy
If you are a minor, please read this Policy and use the App with a parent or guardian’s guidance.

6. Your Rights
1. You can view, edit, or delete journal entries in the App.
2. Uninstalling the App may clear local data. Back up important content beforehand.

7. Policy Updates
We may update this Policy from time to time. Updates will appear on the splash screen or in the App. Continued use means you understand the updated Policy.

8. Contact Us
For questions about this Policy, contact us via the developer details on the App Store page, or the email listed on the Support page.`;

function page({ title, bodyHtml }) {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${title} · SoftDiary</title>
  <style>${STYLE}</style>
</head>
<body>
  <div class="wrap">
    <header>
      <div class="badge" aria-hidden="true">📔</div>
      <div>
        <h1>SoftDiary</h1>
        <p class="sub">Cute local journal · Support & legal</p>
      </div>
    </header>
    <nav>
      <a href="/">Support</a>
      <a href="/privacy">Privacy Policy</a>
      <a href="/terms">Terms of Use</a>
    </nav>
    ${bodyHtml}
    <footer>© ${new Date().getFullYear()} SoftDiary. All rights reserved.</footer>
  </div>
</body>
</html>`;
}

function supportHtml() {
  return page({
    title: "Support",
    bodyHtml: `
      <div class="card">
        <h2>Support</h2>
        <p>Thanks for using SoftDiary — a soft, cartoon-style journal for everyday moods.</p>
        <p class="muted">SoftDiary stores your journals, doodles, photos, and voice notes on your device by default. No account is required.</p>
        <h3>Need help?</h3>
        <ul>
          <li>Create an entry from Home → <strong>Write Journal</strong></li>
          <li>Enable App Lock in Settings (PIN / Face ID)</li>
          <li>Export entries from an entry page or Settings</li>
          <li>Manage Camera / Photos / Microphone permissions in iOS Settings → SoftDiary</li>
        </ul>
        <h3>Contact</h3>
        <p>Email: <a class="inline" href="mailto:support@softdiary.app">support@softdiary.app</a></p>
        <p class="muted">Please include your iOS version and a short description of the issue. We aim to reply within a few business days.</p>
        <h3>Legal</h3>
        <p>
          <a class="inline" href="/privacy">Privacy Policy</a> ·
          <a class="inline" href="/terms">Terms of Use</a>
        </p>
      </div>
    `,
  });
}

function legalHtml(kind) {
  const isPrivacy = kind === "privacy";
  return page({
    title: isPrivacy ? "Privacy Policy" : "Terms of Use",
    bodyHtml: `
      <div class="card">
        <h2>${isPrivacy ? "Privacy Policy" : "Terms of Use"}</h2>
        <div class="muted">${isPrivacy ? PRIVACY : TERMS}</div>
      </div>
    `,
  });
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname.replace(/\/+$/, "") || "/";

    let html;
    if (path === "/" || path === "/support") html = supportHtml();
    else if (path === "/privacy" || path === "/privacy.html") html = legalHtml("privacy");
    else if (path === "/terms" || path === "/terms.html") html = legalHtml("terms");
    else {
      return new Response("Not Found", { status: 404 });
    }

    return new Response(html, {
      headers: {
        "content-type": "text/html; charset=utf-8",
        "cache-control": "public, max-age=300",
      },
    });
  },
};
