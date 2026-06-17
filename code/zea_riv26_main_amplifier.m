% =========================================================================
% Residual-driven adaptive multi-rate Quadratic Programming Framework for
% nonlinear analog audio circuit emulation
% 
% Circuit: BJT common-emitter amplifier
%
% Authors: Miguel Zea and Luis Alberto Rivera
% Department of Electronics, Mechatronics and Biomedical Engineering
% Centro de Procesos Industriales
% Universidad del Valle de Guatemala
% =========================================================================

clear;
circ = 'amplifier';

%% Selection of main parameters
% --- Save results -------------------------------------------------------------
save_results = false;    % true | false

% --- New figures each time or overwrite previuos figures ----------------------
new_figures = false;    % true | false

% --- Error metric -------------------------------------------------------------
error_metric = 'eta';    % 'eta' (QPDI) | 'stepdoubling' (SDDI)

% --- Discretization method ----------------------------------------------------
discret = 'BE';       % 'BE' | 'TRAP'  (Tustin)

% --- full QP or Pseudo inverse ------------------------------------------------
use_full_QP = false;     % true (QP eq) | false (pinv - Pseudo inverse)

% --- Adaptive controller ------------------------------------------------------
adapt_rule = 'deadbeat';     % 'deadbeat' | 'pid' | 'predictive' | 'fixed'

% --- Input signal -------------------------------------------------------------
input_sig = 'sin';
freq_sig = 220;   % 220 was used in the paper
amp_sig = 0.5;    % 0.5 was used in the paper
periods = 22;     % 22 was used in the paper

% --- Original sampling frequency ----------------------------------------------
undersample = 1; % downsampling factor
freq_s = 44100 / undersample;

%% Matrices, non-linearities, input signal and other parameters
[A, B, G, H, D, E, M, L, N] = amplifier_matrices();

% Transistor parameters given in Yeh 2011.
VT = 26.0e-3;   % V
Is = 6.734e-15; % A
beta_F = 300;
beta_R = 0.1;
Vcc = 9;
[eta, D_eta] = bjt_non_linearities(VT, Is, beta_F, beta_R);
dimq = 4;
tol = 0.001; 
max_oversample = 128;  % 16
max_undersample = 4;  % 4

u_t = @(t) amp_sig*sin(2*pi*freq_sig*t);
t_f = periods/freq_sig;

%% Simulation parameters and initialization
N_max = 500000;  % To pre-define arrays with enough space
dt = 1/freq_s;   % Initial
t_0 = 0;
t = t_0;

% Initial conditions
u0 = [0; 0];
x0 = zeros(size(A,1), 1);
q0 = zeros(dimq, 1);
y0 = M*x0 + L*u0 + N*q0;

% Initialize quantities
x = x0; dimx = numel(x);
u = u0;
q = q0; dimeta = numel(eta(q));
y = y0;
z = [x; q];
Err0 = norm(eta(q0));
h_0 = dt;

% Arrays for storing the results
U = [u(1); zeros(N_max-1,1)];  % Debería ser suficiente espacio.
Y = [y; zeros(N_max-1,1)];  % Debería ser suficiente espacio.
t = [t; t+dt; zeros(N_max-2,1)];  % Debería ser suficiente espacio.
Err = [Err0; zeros(N_max-1,1)];  % Debería ser suficiente espacio.
h_k = [h_0; zeros(N_max-1,1)];

% Other parameters
max_iter = 50;
e_min = tol*(1e-3);
e_max = 2*tol;
e_k_1 = 2*tol;
e_k_2 = 2*tol;
h_k_1 = dt;
dt_min = (1 / (max_oversample*freq_s)); % con max oversampling 
dt_max = (1 / ((1/max_undersample)*freq_s)); % con max undersampling

% Update parameters according to the adapt_rule
switch adapt_rule
    case 'deadbeat'
        theta = 0.9;
        eps = theta*tol;
        kappa = 2;
        kI = 1/kappa;
        reset_factor = 1;

    case 'pid'
        theta = 0.8;
        eps = theta*tol;
        kappa = 2;
        kI = 0.1/kappa;
        kP = 0.45/kappa;
        reset_factor = 0.5;

    case 'predictive'
        theta = 0.8;
        eps = theta*tol;
        kappa = 2;
        kI = 1/kappa;
        reset_factor = 1;

    case 'fixed'
        reset_factor = 1;
end


%% Ciclo de simulación
k = 2;   % Para llevar cuenta de los instantes de tiempo de la salida.

tic;  % start time measurement
while t(k) <= t_f
    % Señal de entrada
    u = [u_t(t(k)); Vcc];

    % From "Solving Ordinary Differential Equations I - Nonstiff Problems",
    % page 168, and the Söderlind papers.
    e = 2*tol;
    run = 1;

    % Repeat until a time-step is accepted, according to the selected tolerance,
    % or until reaching the maximum allowed number of iterations.
    while(run < max_iter)
        Kstab = -(1/dt)*eye(dimeta);

        % update previous error values
        e_k_2 = e_k_1;
        e_k_1 = e;

        % Calculate the "trial update" to estimate the DAE defect.
        % z1 for both cases
        z1 = z;
        z1 = next_state_v2026(A, B, G, H, D, E, eta, D_eta, Kstab, dt, z1,...
                      z1(1:dimx), z1((dimx+1):end), u, dimx, dimq, dimeta,...
                      use_full_QP, discret);

        % z2 and the defect indicator for the step-doubling case
        if(strcmp(error_metric, 'stepdoubling'))
            z2 = z;
            z2 = next_state_v2026(A, B, G, H, D, E, eta, D_eta, Kstab, dt/2, z2,...
                      z2(1:dimx), z2((dimx+1):end), u, dimx, dimq, dimeta,...
                      use_full_QP, discret);
            z2 = next_state_v2026(A, B, G, H, D, E, eta, D_eta, Kstab, dt/2, z2,...
                      z2(1:dimx), z2((dimx+1):end), u, dimx, dimq, dimeta,...
                      use_full_QP, discret);
            e = norm(z2 - z1);

        % Calculate the eta indicator of the proposed method
        elseif(strcmp(error_metric, 'eta'))
            q = z1((dimx+1):end);
            e = norm(eta(q));
        end

        % Clip the error, to avoid too small dt's that may result due to
        % atypically large errors in the initial iterations.
        e = max(min(e, e_max), e_min);

        if(e > tol)
            switch adapt_rule
                case 'deadbeat'
                    dt = dt * (eps/e)^kI;

                case 'pid'
                    dt = dt * ( (eps/e)^(3*kI/4 + kP/2) ) * ( (eps/e_k_1)^(kI/2) ) * ( (eps/e_k_2)^(-kI/4-kP/2) );

                case 'predictive'
                    dt = dt * ( (eps/e)^(1/(2*kappa)) ) * ( (eps/e_k_1)^(1/(2*kappa)) ) * ( (dt/h_k_1)^(-1/2) );

                case 'fixed'
                    break;
            end

            % Saturate the sampling time, to avoid going beyond reasonable
            % values for real-time processing.
            dt = max(min(dt, dt_max), dt_min);
            
            h_k_1 = dt;
            run = run + 1;
        else
            break;
        end
            
    end
    
    % Accept the state propagation, save the error ant the sample time and
    % prepare the quantities for the next iteration.
    switch error_metric
        case 'eta'
            z = z1;
        case 'stepdoubling'
            z = z2;
    end

    Err(k) = e;
    h_k(k) = dt;

    % Extract the solutions for the next iteration.
    x = z(1:dimx);
    q = z((dimx+1):end);

    % Calculate the output.
    y = M*x + L*u + N*q;

    % Save the quantities of interest for plotting.
    U(k) = u(1);
    Y(k) = y;

    k = k + 1;
    t(k) = t(k-1)+dt;

    % Bring back up the dt, to avoid unnecessarily small values that may cause
    % the simulation to take too long.
    dt = reset_factor/freq_s;
end

toc  % simulation time, in s
% res_tiempos_ms(cont_t) = 1000*toc   % simulation time, in ms
% cont_t = mod(cont_t,10)+1

% Remove what was not used of the arrays.
U = U(1:k-1);
Y = Y(1:k-1);
t = t(1:k-1);
Err = Err(1:(k-2));
h_k = h_k(1:(k-2));


%% Plot the results

if(new_figures)
    figure;
else
    figure(1); clf;
end

subplot(1,2,1);
plot(t, U, 'k', 'LineWidth', 1.5);
grid minor;
axis square;
xlabel('$t$', 'FontSize', 18, 'Interpreter', 'latex');
ylabel('$u(t)$', 'FontSize', 18, 'Interpreter', 'latex');
xlim([t(1), t(end)]);

subplot(1,2,2);
plot(t, Y, 'k', 'LineWidth', 1.5);
grid minor;
axis square;
xlabel('$t$', 'FontSize', 18, 'Interpreter', 'latex');
ylabel('$y(t)$', 'FontSize', 18, 'Interpreter', 'latex');
xlim([t(1), t(end)]);
sgtitle(sprintf('Circuit: %s | Discretization: %s | Full QP: %d | Error: %s',...
                circ, discret, use_full_QP, error_metric));

if(new_figures)
    figure;
else
    figure(2); clf;
end

plot(t, [U, Y], 'LineWidth', 1.5);
grid minor;
xlabel('$t$', 'FontSize', 18, 'Interpreter', 'latex');
xlim([t(1), t(end)]);
sgtitle(sprintf('Input and Output. Circuit: %s | Discretization: %s | Full QP: %d | Error: %s',...
                circ, discret, use_full_QP, error_metric));

if(new_figures)
    figure;
else
    figure(3); clf;
end

plot(Err, 'k', 'LineWidth', 1);
ylabel('Error');
sgtitle(sprintf('Error. Circuit: %s | Discretization: %s | Full QP: %d | Error: %s',...
                circ, discret, use_full_QP, error_metric));
xlim([1,k-2]);

if(new_figures)
    figure;
else
    figure(4); clf;
end

plot(h_k, 'k', 'LineWidth', 1);
sgtitle(sprintf('h_k. Circuit: %s | Discretization: %s | Full QP: %d | Error: %s',...
                circ, discret, use_full_QP, error_metric));
xlim([1,k-2]);


%% Save the results
if(save_results)
    gen_results(circ, 0, input_sig, freq_sig, amp_sig, periods, 0,...
             discret, use_full_QP, adapt_rule, error_metric, t, U, Y, Err, h_k);
end

%% Auxiliary functions

% --- Structure of the proposed method ---
% dx = Ax + Bu + Gq
% Hq = Dx + Eu,     q = [v; i]
% eta(q) = 0
% y = Mx + Lu + Nq 

% To obtain the matrices corresponding to the common-emmitter amplifier circuit
function [A, B, G, H, D, E, M, L, N] = amplifier_matrices()
    R1 = 100e3;  R2 = 22;  R3 = 10e3;  R4 = 470e3;  R5 = 100e3;
    Cap1 = 0.047e-6; Cap2 = 250e-12; Cap3 = 0.47e-6;
    
    A = [-(1/Cap1)*(1/R1+1/R3+1/R5), -(1/Cap1)*(1/R3+1/R5), -1/(R5*Cap1);
              -(1/Cap2)*(1/R3+1/R5), -(1/Cap2)*(1/R3+1/R5), -1/(R5*Cap2);
                       -1/(R5*Cap3),          -1/(R5*Cap3), -1/(R5*Cap3)];

    B = [(1/Cap1)*(1/R1+1/R3+1/R5), -1/(R3*Cap1);
              (1/Cap2)*(1/R3+1/R5), -1/(R3*Cap2);
                       1/(R5*Cap3),            0];

    G = [0,            0, 1/Cap1,       0;
         0, -1/(R4*Cap2),      0,  1/Cap2;
         0,            0,      0,       0];

    H = [1, 0, R2, 0;
         0, 1,  0, 0];
    D = [-1, 0, 0;
          0, 1, 0];
    E = [1, 0; 0, 0];

    M = [-1, -1, -1];
    L = [1, 0];
    N = [0, 0, 0, 0];
end

% To obtain eta and its Jacobian. Ebers Moll model of BJT used.
function [eta, D_eta] = bjt_non_linearities(VT, Is, beta_F, beta_R)
    
    eta = @(q) [q(3) - Is*( (exp(q(1)/VT)-exp(q(2)/VT)) + (1/beta_F)*(exp(q(1)/VT)-1) ); 
                q(4) - Is*( (exp(q(1)/VT)-exp(q(2)/VT)) - (1/beta_R)*(exp(q(2)/VT)-1) )];
    
    D_eta = @(q) [ -(Is/VT)*(1+1/beta_F)*exp(q(1)/VT), (Is/VT)*exp(q(2)/VT), 1,  0;
                   -(Is/VT)*exp(q(1)/VT), (Is/VT)*(1+1/beta_R)*exp(q(2)/VT), 0,  1 ];
end
