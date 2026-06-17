# AI-generated documentation note

This README was automatically drafted with the assistance of an AI language model and then reviewed as part of the preparation of the supplementary material. The MATLAB code and stored results described below correspond to the authors' implementation and reproducibility files.

---

# RAMA Reproducibility Code

This folder contains the MATLAB code and the precomputed data used to reproduce the numerical results of the paper:

> **Residual-driven adaptive multi-rate Quadratic Programming Framework for nonlinear analog audio circuit emulation**

The code is intentionally kept as a set of compact MATLAB scripts rather than as a large software package. The goal is to make the numerical recipe explicit and easy to inspect: select the circuit, select the discretization and adaptive rule, run the script, and compare the generated trajectories against the stored results and SPICE baselines.

---

## Folder structure

```text
code/
├── gen_results.m
├── next_state_v2026.m
├── zea_riv26_main_clipper.m
├── zea_riv26_main_amplifier.m
├── zea_riv26_main_oscillator.m
└── paper_results/
    ├── res_*.mat
    ├── spice_amplifier_sin220HZ500mV22T.txt
    ├── spice_clip_sin2205HZ5000mV2_5T.txt
    └── spice_oscilador3_step12V20ms_dt_2e-6.txt
```

---

## Main scripts

The three `zea_riv26_main_*.m` files are the entry points. Each one follows the same structure:

```matlab
%% Selection of main parameters
%% Matrices, non-linearities, input signal and other parameters
%% Simulation parameters and initialization
%% Main simulation cycle
%% Plot the results
%% Save the results
%% Auxiliary functions
```

The common structure is deliberate. It allows the three benchmark circuits to be compared while keeping the implementation close to the mathematical formulation used in the paper.

### `zea_riv26_main_clipper.m`

Runs the diode clipper benchmark.

Default paper configuration:

```matlab
circ = 'clipper';
input_sig = 'sin';
freq_sig = 2205;
amp_sig = 5;
periods = 2.5;
```

This script defines the clipper circuit matrices and the two-diode nonlinear map in the auxiliary functions:

```matlab
clipper_matrices()
clipper_non_linearities()
```

### `zea_riv26_main_amplifier.m`

Runs the BJT common-emitter amplifier benchmark.

Default paper configuration:

```matlab
circ = 'amplifier';
input_sig = 'sin';
freq_sig = 220;
amp_sig = 0.5;
periods = 22;
```

The transistor is modeled using an Ebers--Moll-type nonlinear map. The circuit matrices and nonlinearities are defined in:

```matlab
amplifier_matrices()
bjt_non_linearities(VT, Is, beta_F, beta_R)
```

### `zea_riv26_main_oscillator.m`

Runs the Colpitts oscillator benchmark.

Default paper configuration:

```matlab
circ = 'oscillator';
variant = 3;
input_sig = 'const';
V_const = 12;
t_final = 5e-3;
```

The oscillator script supports two circuit variants:

```matlab
variant = 1;   % Colpitts 1
variant = 3;   % Colpitts 3
```

The results reported in the paper use `variant = 3`.

---

## Core one-step update

The file

```matlab
next_state_v2026.m
```

contains the main RAMA/QP one-step update. It receives the circuit matrices, the nonlinear residual map, its Jacobian, the current step size, and the current state. The state vector is

```matlab
z = [x_k; q_k];
```

where `x_k` contains the dynamic variables and `q_k` contains the variables associated with the nonlinear components.

The equality system is assembled in three blocks:

```matlab
% Dynamics
A1 = ...
b1 = ...

% Linear restrictions for q
A2 = [-D, H];
b2 = E*u;

% Stabilization of non-linear restrictions
A3 = [zeros(dimeta,dimx), D_eta(q)];
b3 = D_eta(q)*q + Kstab*eta(q)*dt;
```

The resulting equality system is

```matlab
Aeq*z = beq;
```

and the step can be solved either as:

```matlab
quadprog(...)
```

or through the pseudoinverse:

```matlab
pinv(Aeq)*beq;
```

This choice is controlled by:

```matlab
use_full_QP = true;    % full equality-constrained QP
use_full_QP = false;   % pseudoinverse equality solve
```

---

## Discretization options

Each benchmark supports two discretization options:

```matlab
discret = 'BE';     % Backward Euler
discret = 'TRAP';   % Trapezoidal rule / Tustin
```

The selected method changes the dynamic block of the equality system in `next_state_v2026.m`.

Backward Euler was particularly useful in the diode clipper experiments because its stronger damping can be beneficial in stiff or constraint-dominated settings. The trapezoidal rule is also included because it is standard in virtual analog audio and provides a useful comparison.

---

## Error indicators and adaptive rules

Two error indicators are implemented:

```matlab
error_metric = 'eta';           % QPDI
error_metric = 'stepdoubling';  % SDDI
```

The `eta` option uses the post-step nonlinear residual,

```matlab
e = norm(eta(q));
```

which is the defect indicator proposed in the paper.

The `stepdoubling` option computes one full step and two half steps, then compares the resulting states:

```matlab
e = norm(z2 - z1);
```

The available adaptive rules are:

```matlab
adapt_rule = 'deadbeat';
adapt_rule = 'pid';
adapt_rule = 'predictive';
adapt_rule = 'fixed';
```

The adaptive update is bounded using:

```matlab
dt_min = 1/(max_oversample*freq_s);
dt_max = 1/((1/max_undersample)*freq_s);
```

After each accepted step, the code resets the proposed step size using `reset_factor/freq_s`. This keeps the simulation from remaining unnecessarily stuck at very small time steps after local transient events.

---

## Saving generated results

The helper file

```matlab
gen_results.m
```

generates filenames and saves the main simulation arrays:

```matlab
t
U
Y
Err
h_k
```

The naming convention is:

```text
res_<circuit>_<input>_<discretization>_<solver>_<adaptive_rule>_<error_metric>.mat
```

For example:

```text
res_clip_sin2205HZ5000mV2.5T_be_pinv_dbeat_eta.mat
```

means:

```text
Circuit:        diode clipper
Input:          sine, 2205 Hz, 5000 mV, 2.5 periods
Discretization: Backward Euler
Solver:         pseudoinverse equality solve
Adaptive rule:  deadbeat
Error metric:   eta / QPDI
```

---

## Stored paper results

The folder

```text
paper_results/
```

contains the precomputed `.mat` files used for the paper figures and comparisons.

It also contains the SPICE baselines:

```text
spice_amplifier_sin220HZ500mV22T.txt
spice_clip_sin2205HZ5000mV2_5T.txt
spice_oscilador3_step12V20ms_dt_2e-6.txt
```

These files are included so that the MATLAB results can be compared directly against the reference electrical simulations.

---

## How to run

From MATLAB, move into the code folder:

```matlab
cd code
```

Then run one of the benchmark scripts:

```matlab
zea_riv26_main_clipper
```

or

```matlab
zea_riv26_main_amplifier
```

or

```matlab
zea_riv26_main_oscillator
```

Each script will:

1. define the circuit matrices and nonlinearities,
2. initialize the state and input signal,
3. run the adaptive simulation loop,
4. plot the input, output, error indicator, and accepted step sizes,
5. optionally save the results.

To save new `.mat` results, set:

```matlab
save_results = true;
```

inside the corresponding main script.

---

## Typical configuration changes

The most common parameters to modify are located near the top of each main script.

### Solver choice

```matlab
use_full_QP = true;    % full QP
use_full_QP = false;   % pseudoinverse equality solve
```

### Discretization

```matlab
discret = 'BE';
discret = 'TRAP';
```

### Error metric

```matlab
error_metric = 'eta';
error_metric = 'stepdoubling';
```

### Adaptive rule

```matlab
adapt_rule = 'deadbeat';
adapt_rule = 'pid';
adapt_rule = 'predictive';
adapt_rule = 'fixed';
```

### Input signal

For the clipper and amplifier:

```matlab
freq_sig = ...;
amp_sig = ...;
periods = ...;
```

For the oscillator:

```matlab
V_const = ...;
t_final = ...;
variant = 1;  % or 3
```

---

## MATLAB requirements

The scripts were written for MATLAB and use only standard MATLAB functionality, except when the full QP option is selected:

```matlab
use_full_QP = true;
```

In that case, MATLAB's `quadprog` is used, which requires the Optimization Toolbox.

If

```matlab
use_full_QP = false;
```

then the equality solve is performed using `pinv`, and the Optimization Toolbox is not required.

---

## Notes on reproducibility

The code in this folder is meant to reproduce the numerical experiments rather than serve as a polished software library. For that reason, each main script includes the circuit matrices and nonlinearities as local auxiliary functions. This makes each benchmark self-contained and easier to compare with the equations in the paper.

The precomputed files in `paper_results/` are included to make it possible to inspect the exact data used in the paper without rerunning every configuration. To regenerate a given result, select the same circuit, input, discretization, solver, adaptive rule, and error metric encoded in the filename, then enable `save_results`.

---

## Citation

If this code is useful for your own work, please cite the accompanying paper and reference this repository or supplementary website.
