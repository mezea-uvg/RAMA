/* ============================================================
   RAMA — main.js
   ============================================================ */

// ── Hero canvas oscilloscope ──────────────────────────────────

const canvas = document.getElementById('hero-canvas');
const ctx    = canvas.getContext('2d');

let W = 0, H = 0;

function resizeCanvas() {
  W = canvas.width  = canvas.offsetWidth;
  H = canvas.height = canvas.offsetHeight;
}
window.addEventListener('resize', resizeCanvas);
resizeCanvas();

// Oscilloscope wave definitions
const WAVES = [
  { amp: 0.075, freq: 1.10, phase: 0.00, speed: 0.55, alpha: 0.45, lw: 1.8 },
  { amp: 0.040, freq: 2.35, phase: 1.30, speed: 0.82, alpha: 0.22, lw: 1.0 },
  { amp: 0.100, freq: 0.65, phase: 0.80, speed: 0.38, alpha: 0.18, lw: 1.0 },
  { amp: 0.030, freq: 3.80, phase: 2.10, speed: 1.20, alpha: 0.12, lw: 0.7 },
];

function drawGrid() {
  ctx.save();
  ctx.strokeStyle = '#152D42';
  ctx.lineWidth   = 0.5;
  ctx.globalAlpha = 0.45;
  const cols = 18, rows = 11;
  for (let i = 0; i <= cols; i++) {
    const x = (W / cols) * i;
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke();
  }
  for (let j = 0; j <= rows; j++) {
    const y = (H / rows) * j;
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke();
  }
  ctx.restore();
}

function drawWave(w, t) {
  ctx.save();
  ctx.beginPath();
  const TWO_PI = Math.PI * 2;
  for (let px = 0; px <= W; px += 2) {
    const u = px / W;
    const y = H * 0.5 + H * w.amp * Math.sin(u * w.freq * TWO_PI + t * w.speed);
    px === 0 ? ctx.moveTo(px, y) : ctx.lineTo(px, y);
  }
  ctx.strokeStyle = `rgba(23,199,192,${w.alpha})`;
  ctx.lineWidth   = w.lw;
  ctx.globalAlpha = 1;
  ctx.stroke();
  ctx.restore();
}

function animateHero(ts) {
  ctx.clearRect(0, 0, W, H);
  drawGrid();
  const t = ts / 1000;
  WAVES.forEach(w => drawWave(w, t));
  requestAnimationFrame(animateHero);
}

requestAnimationFrame(animateHero);

// ── Active nav on scroll ──────────────────────────────────────

const sections = document.querySelectorAll('section[id], footer[id]');
const navLinks = document.querySelectorAll('.nav-links a');

function updateActiveNav() {
  const scrollY = window.scrollY;
  let current = '';
  sections.forEach(s => {
    if (scrollY >= s.offsetTop - 100) current = s.id;
  });
  navLinks.forEach(a => {
    const href = a.getAttribute('href');
    a.classList.toggle('active', href === `#${current}`);
  });
}
window.addEventListener('scroll', updateActiveNav, { passive: true });
updateActiveNav();

// ── Mobile nav toggle ─────────────────────────────────────────

const toggle  = document.querySelector('.nav-mobile-toggle');
const navList = document.querySelector('.nav-links');

toggle?.addEventListener('click', () => {
  const open = navList.classList.toggle('is-open');
  toggle.setAttribute('aria-expanded', String(open));
  const icon = toggle.querySelector('svg');
  // Swap hamburger ↔ close
  if (open) {
    icon.innerHTML = `<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>`;
  } else {
    icon.innerHTML = `<line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>`;
  }
});

// Close nav when a link is clicked (mobile)
navLinks.forEach(a => {
  a.addEventListener('click', () => {
    navList.classList.remove('is-open');
    toggle?.setAttribute('aria-expanded', 'false');
  });
});

// ── BibTeX copy button ────────────────────────────────────────

document.querySelectorAll('.copy-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const raw = btn.closest('.bibtex-wrap').querySelector('.bibtex-raw');
    if (!raw) return;
    navigator.clipboard.writeText(raw.textContent.trim()).then(() => {
      btn.textContent = '✓ Copied!';
      btn.classList.add('copied');
      setTimeout(() => {
        btn.textContent = 'Copy BibTeX';
        btn.classList.remove('copied');
      }, 2500);
    }).catch(() => {
      // Fallback for older browsers
      const ta = document.createElement('textarea');
      ta.value = raw.textContent.trim();
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      btn.textContent = '✓ Copied!';
      btn.classList.add('copied');
      setTimeout(() => { btn.textContent = 'Copy BibTeX'; btn.classList.remove('copied'); }, 2500);
    });
  });
});
