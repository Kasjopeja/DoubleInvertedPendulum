function [mdlName, p] = dp_reset(modelFile)
%DP_RESET Initialize the model environment to a known default state.
%
% Resolves the Simulink model file/name, builds the default configuration via
% dp_defaults, prepares the corresponding workspace variables (physics, Ts,
% ICs, LQR placeholders, hysteresis thresholds, and equilibrium settings), and
% exports them to the base workspace. It then loads the Simulink model (if not
% already loaded) and applies basic simulation settings before forcing an
% update/compile step.
%
% Input:
%   modelFile - (optional) model file name/path (e.g., 'model.slx'); defaults to 'model.slx'.
%
% Outputs:
%   mdlName - resolved Simulink model name (without extension) used by the app.
%   p       - struct of physical parameters taken from the default configuration.

if nargin < 1 || isempty(modelFile)
    modelFile = 'model.slx';
end

appDir = fileparts(mfilename('fullpath'));

mf = modelFile;
if builtin('exist', mf, 'file') ~= 2
    mf2 = fullfile(appDir, modelFile);
    if builtin('exist', mf2, 'file') == 2
        mf = mf2;
    end
end

if builtin('exist', mf, 'file') ~= 2
    [~, mdlName] = fileparts(modelFile);
    if isempty(mdlName)
        mdlName = modelFile;
    end
else
    [~, mdlName] = fileparts(mf);
end

cfg = dp_defaults(mdlName);
p = cfg.p;

Ts = cfg.sim.Ts;

th_on = cfg.hyst.th_on;
hyst_delta = cfg.hyst.delta;
th_off = th_on - hyst_delta;

vars = struct();

vars.M  = p.M;
vars.m1 = p.m1;
vars.m2 = p.m2;
vars.l1 = p.l1;
vars.l2 = p.l2;
vars.g  = p.g;
vars.b  = p.b;
vars.c1 = p.c1;
vars.c2 = p.c2;

vars.Ts = Ts;

vars.Q = diag(cfg.lqr.Qdiag);
vars.R = cfg.lqr.R;
vars.K = zeros(1,6);

vars.th_on      = th_on;
vars.hyst_delta = hyst_delta;
vars.th_off     = th_off;
vars.use_hyst   = double(cfg.hyst.enabled ~= 0);

vars.x0       = cfg.ic.x0;
vars.theta1_0 = cfg.ic.theta1_0;
vars.theta2_0 = cfg.ic.theta2_0;

vars.x_ref   = cfg.eq.x_ref;
vars.theta1e = cfg.eq.theta1e;
vars.theta2e = cfg.eq.theta2e;
vars.mode    = cfg.eq.mode;

try
    dp_export_vars(mdlName, vars, 'base');
catch

end

try
    if ~bdIsLoaded(mdlName)
        if builtin('exist', mf, 'file') == 2
            load_system(mf);
        else
            load_system(mdlName);
        end
    end
catch
    error("Nie moge zaladowac modelu '%s'.", mdlName);
end

try, set_param(mdlName,'SimulationMode','normal'); catch, end
try, set_param(mdlName,'FastRestart','off'); catch, end

try, set_param(mdlName,'SimulationCommand','update'); catch, end
end
