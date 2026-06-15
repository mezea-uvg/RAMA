# RAMA

**Residual-Adaptive Multi-rate Analog circuit emulation**

[![GitHub Pages](https://img.shields.io/badge/site-live-17C7C0?style=flat-square)](https://YOUR_USERNAME.github.io/rama/)

A residual-driven adaptive multi-rate framework for nonlinear analog circuit emulation, targeting virtual analog audio applications.

---

## Project page

**[YOUR_USERNAME.github.io/rama](https://YOUR_USERNAME.github.io/rama/)** — paper, code, supplementary derivations, benchmark results, and VST demo.

---

## Repository structure

```
/
├── index.html            ← Project website (GitHub Pages entry point)
├── paper/                ← DAFx-26 paper PDF and citation
├── supplementary/        ← Extended derivations and circuit matrices
├── benchmarks/           ← Benchmark results and reproduce scripts
├── vst-demo/             ← VST plugin build and screenshots
├── code/                 ← MATLAB and C++ reference implementation
├── docs/                 ← Additional documentation
└── assets/               ← CSS, JS, logo
```

---

## Local preview

No build step needed. Open `index.html` directly in a browser, or use any static server:

```bash
# Python 3
python3 -m http.server 8000
# then open http://localhost:8000
```

---

## Citation

```bibtex
@inproceedings{rama2026dafx,
  title     = {Residual-Driven Adaptive Multi-Rate Circuit Emulation for Virtual Analog Audio},
  author    = {Author, A. and Author, B.},
  booktitle = {Proceedings of the 23rd International Conference on Digital Audio Effects (DAFx-26)},
  year      = {2026},
  url       = {https://YOUR_USERNAME.github.io/rama/}
}
```

---

## License

MIT — see [LICENSE](LICENSE).
