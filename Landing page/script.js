/* =========================================================
   স্টোরি রিডার — Landing Page Script
   ========================================================= */

(function () {
  'use strict';

  // -------- Server config --------
  const BASE_URL = 'https://www.bdappsdigitalapps.com/NADB26020/story_reader';
  const APK_FILENAME = 'Story_Reader.apk';
  const APK_URL = `${BASE_URL}/${APK_FILENAME}`;

  // -------- DOM helpers --------
  const $ = (sel, ctx = document) => ctx.querySelector(sel);
  const $$ = (sel, ctx = document) => Array.from(ctx.querySelectorAll(sel));

  // -------- Mobile nav toggle --------
  const nav = $('#nav');
  const navToggle = $('#navToggle');
  const navLinks = $('#navLinks');

  navToggle.addEventListener('click', () => {
    navToggle.classList.toggle('open');
    navLinks.classList.toggle('open');
  });

  // Close mobile nav after clicking a link
  $$('#navLinks a').forEach((link) => {
    link.addEventListener('click', () => {
      navToggle.classList.remove('open');
      navLinks.classList.remove('open');
    });
  });

  // -------- Sticky nav style on scroll --------
  window.addEventListener(
    'scroll',
    () => {
      if (window.scrollY > 30) nav.classList.add('scrolled');
      else nav.classList.remove('scrolled');
    },
    { passive: true }
  );

  // -------- Reveal on scroll --------
  const revealEls = $$('.reveal');
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
    );
    revealEls.forEach((el) => io.observe(el));
  } else {
    revealEls.forEach((el) => el.classList.add('visible'));
  }

  // -------- Bangla numeral formatter --------
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  const toBn = (num) => String(num).replace(/[0-9]/g, (d) => bnDigits[Number(d)]);
  const formatNumberBn = (num) => {
    // Format like 5,000 / 50,000 with Bangla digits
    return toBn(num.toLocaleString('en-US'));
  };

  // -------- Animated counters --------
  const counters = $$('[data-counter]');
  const animateCounter = (el) => {
    const target = parseFloat(el.dataset.counter);
    const isDecimal = el.dataset.decimal === 'true';
    const duration = 1800;
    const startTime = performance.now();

    const tick = (now) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // Ease out cubic
      const eased = 1 - Math.pow(1 - progress, 3);
      const value = target * eased;

      if (isDecimal) {
        el.textContent = toBn(value.toFixed(1));
      } else {
        el.textContent = formatNumberBn(Math.floor(value)) + (target >= 1000 ? '+' : '+');
      }
      if (progress < 1) requestAnimationFrame(tick);
      else {
        if (isDecimal) el.textContent = toBn(target.toFixed(1));
        else el.textContent = formatNumberBn(target) + '+';
      }
    };
    requestAnimationFrame(tick);
  };

  if ('IntersectionObserver' in window) {
    const counterIO = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            animateCounter(entry.target);
            counterIO.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.5 }
    );
    counters.forEach((el) => counterIO.observe(el));
  } else {
    counters.forEach(animateCounter);
  }

  // -------- Smooth scroll for anchor links --------
  $$('a[href^="#"]').forEach((a) => {
    a.addEventListener('click', (e) => {
      const id = a.getAttribute('href');
      if (id.length <= 1) return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      const offset = 70;
      const top = target.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
    });
  });

  // -------- Download button (APK) --------
  const toast = $('#toast');
  const showToast = (msg, ms = 2800) => {
    if (!toast) return;
    toast.firstElementChild.textContent = msg;
    toast.classList.add('show');
    clearTimeout(showToast._t);
    showToast._t = setTimeout(() => toast.classList.remove('show'), ms);
  };

  // Collect every button that should download the APK. We support
  // BOTH the legacy id-based selectors (#downloadBtn, #heroDownloadBtn)
  // AND any element marked with [data-download]. Using a single
  // Set means duplicate IDs across the page never break the wiring.
  const downloadBtns = Array.from(new Set([
    ...$$('#downloadBtn'),
    ...$$('#heroDownloadBtn'),
    ...$$('[data-download]'),
  ]));

  // Disable every download button while a download is in flight
  const setBusy = (busy) => {
    downloadBtns.forEach((btn) => {
      if (!btn) return;
      btn.style.pointerEvents = busy ? 'none' : '';
      btn.style.opacity = busy ? '.7' : '';
    });
  };

  /**
   * Robust APK downloader.
   *
   * The APK is hosted on a different origin (www.bdappsdigitalapps.com)
   * and that server does NOT send CORS or Content-Disposition headers,
   * which rules out the usual "fetch as blob → saveBlob" trick and
   * makes a same-origin <a download> click unreliable.
   *
   * The most reliable, no-server-change approach is to navigate the
   * *current tab* to the APK URL. Because the server responds with
   * Content-Type: application/vnd.android.package-archive, every
   * modern browser (Chrome, Edge, Firefox, Safari) will trigger a
   * download in the browser's native download bar instead of rendering
   * the binary. The "Back" button takes the user back to the page.
   *
   * We also keep a same-origin anchor with the `download` attribute
   * as a same-tab navigation hint, which works when the landing page
   * happens to be served from the same origin.
   */
  const triggerDownload = (e) => {
    if (e) e.preventDefault();
    showToast('⬇️ ডাউনলোড শুরু হচ্ছে...');
    setBusy(true);

    // 1) Try the download-attribute anchor click first (best UX when
    //    the page is hosted on the same origin as the APK).
    const a = document.createElement('a');
    a.href = APK_URL;
    a.download = APK_FILENAME;
    a.rel = 'noopener';
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    setTimeout(() => {
      try { document.body.removeChild(a); } catch (_) {}
    }, 1000);

    // 2) Fallback / cross-origin guarantee: top-level navigation to
    //    the APK. Browsers download application/vnd.android.package-archive
    //    responses instead of rendering them.
    try {
      window.top.location.href = APK_URL;
    } catch (_) {
      window.location.href = APK_URL;
    }

    showToast('✅ ডাউনলোড শুরু হয়েছে — ফাইলটি সেভ করুন', 3500);
    setTimeout(() => setBusy(false), 1500);
  };

  downloadBtns.forEach((btn) => btn.addEventListener('click', triggerDownload));

  // -------- Subtle parallax on hero blobs (mouse move) --------
  const blobs = $$('.blob');
  if (blobs.length && window.matchMedia('(hover: hover)').matches) {
    let rafId = null;
    document.addEventListener('mousemove', (e) => {
      const x = (e.clientX / window.innerWidth - 0.5) * 30;
      const y = (e.clientY / window.innerHeight - 0.5) * 30;
      if (rafId) cancelAnimationFrame(rafId);
      rafId = requestAnimationFrame(() => {
        blobs.forEach((b, i) => {
          const factor = (i + 1) * 0.6;
          b.style.transform = `translate(${x * factor}px, ${y * factor}px)`;
        });
      });
    });
  }

  // -------- Year auto-fill (if needed in future) --------
  // (Currently unused — keeping site year as ২০২৬ in footer.)
})();