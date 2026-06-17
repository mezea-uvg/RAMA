%% =========================================================================
% Residual-driven adaptive multi-rate Quadratic Programming Framework for
% nonlinear analog audio circuit emulation
% 
% Auxiliary script for generating the results.
%
% Authors: Miguel Zea and Luis Alberto Rivera
% Department of Electronics, Mechatronics and Biomedical Engineering
% Centro de Procesos Industriales
% Universidad del Valle de Guatemala
% =========================================================================

function gen_results(circ, variant, input_sig, freq_sin, amp_sin, duration, V_const, discret, use_full_QP, adapt_rule, error_metric, t, U, Y, Err, h_k)
    switch circ
        case 'clipper'
            circ2 = 'clip';
            variant = '';
        case 'oscillator'
            circ2 = 'osc';
            variant = int2str(variant);
        case 'amplifier'
            circ2 = 'amp';
            variant = '';
    end

    switch discret
        case 'TRAP'
            discret2 = 'trap';
        case 'BE'
            discret2 = 'be';
    end
    
    if(use_full_QP)
        qpsolve = 'qp';
    else
        qpsolve = 'pinv';
    end

    switch adapt_rule
        case 'deadbeat'
            adapt_rule2 = 'dbeat';
        case 'pid'
            adapt_rule2 = 'pid';
        case 'predictive'
            adapt_rule2 = 'pred';
        case 'fixed'
            adapt_rule2 = 'fix';
    end

    if(strcmp(error_metric, 'stepdoubling'))
        error_metric = 'stepdbl';
    end

    switch input_sig
        case 'sin'
            entrada2 = input_sig+string(freq_sin)+'HZ'+string(amp_sin*1000)+'mV'+string(duration)+'T';
        case 'const'
            entrada2 = input_sig+string(V_const*1000)+'mV'+string(1000*duration)+'ms';
    end

    filename = ['res_', circ2, variant, '_', char(entrada2), '_', discret2, '_', qpsolve, '_', adapt_rule2, '_', error_metric, '.mat'];

    disp("Saved to: "+filename);
    save(filename, 't', 'U', 'Y', 'Err', 'h_k');
    
end