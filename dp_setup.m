function cfg = dp_setup(cfg)
%DP_SETUP Compute derived parameters (LQR, hysteresis) and export variables.
% cfg = dp_setup(cfg)
%
% The exported variable names are consistent with dp_reset and dp_apply_workspace:
% M,m1,m2,l1,l2,g,b,c1,c2, Ts, Q,R,K, th_on,hyst_delta,th_off,use_hyst,
% x0,theta1_0,theta2_0, x_ref,theta1e,theta2e, mode

    if nargin < 1 || isempty(cfg)
        cfg = dp_defaults();
    end

    mdl = cfg.mdl;

    % equilibrium from mode (if requested)
    if isfield(cfg,'eq') && isfield(cfg.eq,'useMode') && cfg.eq.useMode
        [cfg.eq.theta1e, cfg.eq.theta2e] = local_mode_to_eq(cfg.eq.mode);
    end

    % LQR
    try
        [K,Q,R] = dp_lqr_calc(cfg);
        cfg.lqr.Q = Q;
        cfg.lqr.R = R;
        cfg.lqr.K = K;
    catch
        % fallback - export still works
        cfg.lqr.Q = diag(cfg.lqr.Qdiag(:).');
        cfg.lqr.R = cfg.lqr.R;
        cfg.lqr.K = zeros(1,6);
    end

    % hysteresis derived threshold
    cfg.hyst.th_off = cfg.hyst.th_on - cfg.hyst.delta;

    % variables for Simulink
    vars = struct();

    % physical
    vars.M  = cfg.p.M;  vars.m1 = cfg.p.m1;  vars.m2 = cfg.p.m2;
    vars.l1 = cfg.p.l1; vars.l2 = cfg.p.l2;  vars.g  = cfg.p.g;
    vars.b  = cfg.p.b;  vars.c1 = cfg.p.c1;  vars.c2 = cfg.p.c2;

    % sim
    if isfield(cfg,'sim') && isfield(cfg.sim,'Ts')
        vars.Ts = cfg.sim.Ts;
    end

    % eq / ref
    vars.mode    = cfg.eq.mode;
    vars.x_ref   = cfg.eq.x_ref;
    vars.theta1e = cfg.eq.theta1e;
    vars.theta2e = cfg.eq.theta2e;

    % IC
    vars.x0       = cfg.ic.x0;
    vars.theta1_0 = cfg.ic.theta1_0;
    vars.theta2_0 = cfg.ic.theta2_0;

    % LQR
    vars.K = cfg.lqr.K;
    vars.Q = cfg.lqr.Q;
    vars.R = cfg.lqr.R;

    % hysteresis
    vars.th_on      = cfg.hyst.th_on;
    vars.hyst_delta = cfg.hyst.delta;
    vars.th_off     = cfg.hyst.th_off;
    vars.use_hyst   = double(cfg.hyst.enabled ~= 0);

    dp_export_vars(mdl, vars, cfg.export);
end

function [th1e, th2e] = local_mode_to_eq(mode)
    mode = floor(mode + 0.5);
    switch mode
        case 1, th1e = 0;   th2e = 0;
        case 2, th1e = pi;  th2e = pi;
        case 3, th1e = 0;   th2e = pi;
        case 4, th1e = pi;  th2e = 0;
        otherwise, th1e = 0; th2e = 0;
    end
end
