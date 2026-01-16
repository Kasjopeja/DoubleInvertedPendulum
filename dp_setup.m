function cfg = dp_setup(cfg)
%DP_SETUP Compute derived configuration (equilibrium, LQR, hysteresis) and export variables.
%
% Completes the configuration struct by resolving the equilibrium angles from
% the selected mode (if enabled), computing LQR matrices/gain (with a safe
% fallback on failure), deriving hysteresis thresholds, and exporting the full
% set of runtime variables to the selected workspace target via dp_export_vars.
%
% Input:
%   cfg - (optional) configuration struct; when omitted, defaults are created via dp_defaults().
%
% Output:
%   cfg - updated configuration struct with derived fields (eq, lqr, hyst) populated.

if nargin < 1 || isempty(cfg)
    cfg = dp_defaults();
end

mdl = cfg.mdl;

if isfield(cfg,'eq') && isfield(cfg.eq,'useMode') && cfg.eq.useMode
    [cfg.eq.theta1e, cfg.eq.theta2e] = local_mode_to_eq(cfg.eq.mode);
end

try
    [K,Q,R] = dp_lqr_calc(cfg);
    cfg.lqr.Q = Q;
    cfg.lqr.R = R;
    cfg.lqr.K = K;
catch
    cfg.lqr.Q = diag(cfg.lqr.Qdiag(:).');
    cfg.lqr.R = cfg.lqr.R;
    cfg.lqr.K = zeros(1,6);
end

cfg.hyst.th_off = cfg.hyst.th_on - cfg.hyst.delta;

vars = struct();
vars.M  = cfg.p.M;  vars.m1 = cfg.p.m1;  vars.m2 = cfg.p.m2;
vars.l1 = cfg.p.l1; vars.l2 = cfg.p.l2;  vars.g  = cfg.p.g;
vars.b  = cfg.p.b;  vars.c1 = cfg.p.c1;  vars.c2 = cfg.p.c2;

if isfield(cfg,'sim') && isfield(cfg.sim,'Ts')
    vars.Ts = cfg.sim.Ts;
end

vars.mode    = cfg.eq.mode;
vars.x_ref   = cfg.eq.x_ref;
vars.theta1e = cfg.eq.theta1e;
vars.theta2e = cfg.eq.theta2e;

vars.x0       = cfg.ic.x0;
vars.theta1_0 = cfg.ic.theta1_0;
vars.theta2_0 = cfg.ic.theta2_0;

vars.K = cfg.lqr.K;
vars.Q = cfg.lqr.Q;
vars.R = cfg.lqr.R;

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
