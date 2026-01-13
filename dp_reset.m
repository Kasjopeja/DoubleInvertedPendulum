function [mdlName, p] = dp_reset(modelFile)
%DP_RESET Predictable reset: set default variables and load the Simulink model.
%
%   [mdl,p] = dp_reset('model.slx')
%
% This function does not clear the base workspace. It only defines the
% variables required for model compilation and the app UI.

    if nargin < 1 || isempty(modelFile)
        modelFile = 'model.slx';
    end

    appDir = fileparts(mfilename('fullpath'));

    % --- resolve path to .slx ---
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

    % --- defaults from a single source of truth ---
    cfg = dp_defaults(mdlName);
    p = cfg.p;

    Ts = cfg.sim.Ts;

    th_on = cfg.hyst.th_on;
    hyst_delta = cfg.hyst.delta;
    th_off = th_on - hyst_delta;

    vars = struct();
    % physical
    vars.M  = p.M;
    vars.m1 = p.m1;
    vars.m2 = p.m2;
    vars.l1 = p.l1;
    vars.l2 = p.l2;
    vars.g  = p.g;
    vars.b  = p.b;
    vars.c1 = p.c1;
    vars.c2 = p.c2;

    % simulation
    vars.Ts = Ts;

    % LQR
    vars.Q = diag(cfg.lqr.Qdiag);
    vars.R = cfg.lqr.R;
    vars.K = zeros(1,6);

    % hysteresis
    vars.th_on      = th_on;
    vars.hyst_delta = hyst_delta;
    vars.th_off     = th_off;
    vars.use_hyst   = double(cfg.hyst.enabled ~= 0);

    % IC
    vars.x0       = cfg.ic.x0;
    vars.theta1_0 = cfg.ic.theta1_0;
    vars.theta2_0 = cfg.ic.theta2_0;

    % equilibrium
    vars.x_ref   = cfg.eq.x_ref;
    vars.theta1e = cfg.eq.theta1e;
    vars.theta2e = cfg.eq.theta2e;
    vars.mode    = cfg.eq.mode;

    try
        dp_export_vars(mdlName, vars, 'base');
    catch
        % keep going - the app can still open
    end

    % --- load the model ---
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

    % Normal mode (RuntimeObject needed for plotting)
    try, set_param(mdlName,'SimulationMode','normal'); catch, end
    try, set_param(mdlName,'FastRestart','off'); catch, end

    % Update so MATLAB Function blocks see variables immediately
    try, set_param(mdlName,'SimulationCommand','update'); catch, end
end
