%% =========================================================================
% Residual-driven adaptive multi-rate Quadratic Programming Framework for
% nonlinear analog audio circuit emulation
% 
% Auxiliary script for calculating the next step (main iteration loop).
%
% Authors: Miguel Zea and Luis Alberto Rivera
% Department of Electronics, Mechatronics and Biomedical Engineering
% Centro de Procesos Industriales
% Universidad del Valle de Guatemala
% =========================================================================

function z = next_state_v2026(A, B, G, H, D, E, eta, D_eta, Kstab, dt, z, x, q, u, dimx, dimq, dimeta, use_full_QP, discret)
    % NOTE: z = [x_k; q_k] 

    % Dynamics (discretized using Backward Euler or TRAP)
    if(strcmp(discret, 'BE')) % Backward Euler
        A1 = [eye(dimx)-A*dt, -G*dt];
        b1 = x + B*dt*u;
    else  % TRAP
        A1 = [eye(dimx)-A*dt/2, -G*dt];
        b1 = (eye(dimx)+A*dt/2)*x + B*dt*u;
    end

    % Linear restrictions for quantities associated to the non-linear
    % components [q].
    A2 = [-D, H];
    b2 = E*u;

    % Stabilization of non-linear restrictions
    A3 = [zeros(dimeta,dimx), D_eta(q)];
    b3 = D_eta(q)*q + Kstab*eta(q)*dt;
    
    % Equality constraints of the QP
    Aeq = [A1; A2; A3];
    beq = [b1; b2; b3];

    % Cost function matrices
    dimz = dimx + dimq;
    Hc = eye(dimz);
    fc = zeros(dimz, 1);

    % Solve the QP (either the full case or only through the pseudo-inverse)
    if(use_full_QP)
        z = quadprog(Hc, fc, [], [], Aeq, beq, [], [], z,...
                optimoptions('quadprog', 'Display','off', 'MaxIterations', 50));
    else
        z = pinv(Aeq)*beq;
    end
end