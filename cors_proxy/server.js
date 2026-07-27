import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 8787;

const UPSTREAM = 'https://www.bdappsdigitalapps.com/NADB26020';

// Allow the Flutter web build (any origin) to call us.
app.use(cors());

// Parse both form-encoded and JSON bodies, then forward them as form-encoded
// since the upstream BD Apps endpoint expects form-encoded fields.
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Forward any POST /<segment> to the matching PHP file upstream.
app.post(/^\/(.+)$/, async (req, res) => {
  try {
    const upstreamPath = req.params[0]; // e.g. "send_otp.php"

    // Quick guard: only forward known endpoint names for safety.
    const allowed = ['send_otp.php', 'verify_otp.php', 'unsubscribe.php', 'check_subscription.php'];
    if (!allowed.includes(upstreamPath)) {
      return res.status(404).json({ success: false, message: 'Unknown endpoint' });
    }

    const url = `${UPSTREAM}/${upstreamPath}`;
    const body = new URLSearchParams(req.body).toString();

    const upstreamRes = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body,
    });

    const text = await upstreamRes.text();
    const contentType = upstreamRes.headers.get('content-type') || 'application/json';

    res.status(upstreamRes.status).set('Content-Type', contentType).send(text);
  } catch (e) {
    res.status(500).json({ success: false, message: 'Proxy error: ' + e.message });
  }
});

// Friendly 404 for everything else.
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Use POST /send_otp.php etc.' });
});

app.listen(PORT, () => {
  console.log(`CORS proxy running on http://localhost:${PORT}`);
  console.log(`Forwarding to: ${UPSTREAM}`);
});
