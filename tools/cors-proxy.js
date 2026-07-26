// =============================================================
// Dev-only CORS proxy for the BD Apps OTP endpoints.
//
// Why this exists:
// Flutter web runs in the browser, which enforces CORS. The
// server at https://www.bdappsdigitalapps.com/NADB26020/*.php
// does NOT send Access-Control-Allow-Origin headers, so the
// browser blocks the response body and Flutter throws
// "Failed to fetch" — even though the POST succeeded (the OTP
// is still delivered). Postman/curl work because they bypass
// the browser's CORS layer.
//
// Usage:
//   node tools/cors-proxy.js          # listens on :8787
// Then in another terminal:
//   flutter run -d edge --dart-define=API_BASE=http://localhost:8787/NADB26020
//
// In production builds, just leave API_BASE unset and the app
// calls the real BD Apps endpoint directly.
// =============================================================

const http = require('http');
const https = require('https');
const { URL } = require('url');

const PORT = process.env.PORT ? Number(process.env.PORT) : 8787;
const TARGET_HOST = 'www.bdappsdigitalapps.com';

const proxy = http.createServer((req, res) => {
  // Mirror the incoming path verbatim against the real host.
  const target = {
    protocol: 'https:',
    hostname: TARGET_HOST,
    port: 443,
    path: req.url,
    method: req.method,
    headers: {
      ...req.headers,
      host: TARGET_HOST,
      // Strip the browser Origin so the upstream doesn't try to
      // echo it back; we set our own CORS headers below.
      origin: undefined,
      referer: undefined,
    },
  };

  const upstream = https.request(target, upstreamRes => {
    // Inject permissive CORS headers on every response.
    res.statusCode = upstreamRes.statusCode || 502;
    Object.entries(upstreamRes.headers).forEach(([k, v]) => {
      // Drop headers that would conflict with our CORS overrides.
      if (
        k.toLowerCase() === 'access-control-allow-origin' ||
        k.toLowerCase() === 'access-control-allow-methods' ||
        k.toLowerCase() === 'access-control-allow-headers' ||
        k.toLowerCase() === 'access-control-max-age'
      ) {
        return;
      }
      res.setHeader(k, v);
    });
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS, GET');
    res.setHeader(
      'Access-Control-Allow-Headers',
      'Content-Type, Accept, Origin, X-Requested-With',
    );
    res.setHeader('Access-Control-Max-Age', '86400');
    upstreamRes.pipe(res);
  });

  upstream.on('error', err => {
    res.statusCode = 502;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ success: false, message: 'Proxy error: ' + err.message }));
  });

  // Handle browser preflight directly without hitting upstream.
  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS, GET');
    res.setHeader(
      'Access-Control-Allow-Headers',
      'Content-Type, Accept, Origin, X-Requested-With',
    );
    res.setHeader('Access-Control-Max-Age', '86400');
    res.end();
    return;
  }

  req.pipe(upstream);
});

proxy.listen(PORT, () => {
  console.log(`[cors-proxy] listening on http://localhost:${PORT}`);
  console.log(`[cors-proxy] forwarding to https://${TARGET_HOST}`);
  console.log('[cors-proxy] start Flutter with:');
  console.log(`[cors-proxy]   flutter run -d edge --dart-define=API_BASE=http://localhost:${PORT}/NADB26020`);
});