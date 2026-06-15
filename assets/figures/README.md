# assets/figures/

Place your exported figures here. The site references these files directly via `<img>` tags —
when a file is missing, a labelled placeholder is shown instead.

## Expected files

| File | Section |
|---|---|
| `benchmark-clipper.svg` | Benchmarks — Diode Clipper plot |
| `benchmark-bjt.svg` | Benchmarks — BJT Common-Emitter plot |
| `benchmark-colpitts.svg` | Benchmarks — Colpitts Oscillator plot |
| `vst-screenshot.png` | VST Demo — plugin interface screenshot |

## Exporting from MATLAB

**SVG (recommended — vector, scales perfectly at any size):**
```matlab
% After creating your figure:
print(gcf, 'benchmark-clipper', '-dsvg')
% or
saveas(gcf, 'benchmark-clipper.svg', 'svg')
```

**PNG (alternative — good for screenshots or complex plots):**
```matlab
print(gcf, 'benchmark-clipper', '-dpng', '-r300')   % 300 dpi
```

> **Note:** EPS does not render in web browsers. Convert EPS → SVG via Inkscape if needed:
> `inkscape --export-plain-svg output.svg input.eps`

After exporting, copy the files into this folder and push to GitHub.
