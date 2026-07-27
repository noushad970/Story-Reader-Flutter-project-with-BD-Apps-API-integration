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
  const showToast = (msg, ms = 2400) => {
    toast.firstElementChild.textContent = msg;
    toast.classList.add('show');
    clearTimeout(showToast._t);
    showToast._t = setTimeout(() => toast.classList.remove('show'), ms);
  };

  const triggerDownload = (e) => {
    if (e) e.preventDefault();
    showToast('⬇️ ডাউনলোড শুরু হচ্ছে...');

    // Create a temporary anchor to trigger native download
    const a = document.createElement('a');
    a.href = APK_URL;
    a.download = APK_FILENAME;
    a.rel = 'noopener';
    a.target = '_blank';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    // After a delay show completion hint
    setTimeout(() => showToast('✅ ডাউনলোড শুরু হয়েছে — ফাইলটি সেভ করুন'), 1600);
  };

  const downloadBtn = $('#downloadBtn');
  const heroDownloadBtn = $('#heroDownloadBtn');
  if (downloadBtn) downloadBtn.addEventListener('click', triggerDownload);
  if (heroDownloadBtn) heroDownloadBtn.addEventListener('click', triggerDownload);

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