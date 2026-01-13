function dp_apply_workspace(fig)
%DP_APPLY_WORKSPACE Single place that pushes app state into the base workspace
% and (optionally) into key Simulink block parameters (IC, solver step).
%
% The goal is to avoid having the same variable assigned from multiple
% callbacks in multiple files.

    app = guidata(fig);
    vars = struct();

    % --- physical parameters ---
    if isfield(app,'p') && isstruct(app.p)
        p = app.p;
        if isfield(p,'M'),  vars.M  = p.M;  end
        if isfield(p,'m1'), vars.m1 = p.m1; end
        if isfield(p,'m2'), vars.m2 = p.m2; end
        if isfield(p,'l1'), vars.l1 = p.l1; end
        if isfield(p,'l2'), vars.l2 = p.l2; end
        if isfield(p,'g'),  vars.g  = p.g;  end
        if isfield(p,'b'),  vars.b  = p.b;  end
        if isfield(p,'c1'), vars.c1 = p.c1; end
        if isfield(p,'c2'), vars.c2 = p.c2; end
    end

    % --- simulation ---
    if isfield(app,'sim') && isstruct(app.sim) && isfield(app.sim,'Ts')
        vars.Ts = app.sim.Ts;
    end

    % --- equilibrium / reference ---
    if isfield(app,'eq') && isstruct(app.eq)
        if isfield(app.eq,'x_ref'),   vars.x_ref   = app.eq.x_ref;   end
        if isfield(app.eq,'theta1e'), vars.theta1e = app.eq.theta1e; end
        if isfield(app.eq,'theta2e'), vars.theta2e = app.eq.theta2e; end
        if isfield(app.eq,'mode'),    vars.mode    = app.eq.mode;    end
    end

    % --- initial conditions ---
    if isfield(app,'ic') && isstruct(app.ic)
        if isfield(app.ic,'x0'),       vars.x0       = app.ic.x0;       end
        if isfield(app.ic,'theta1_0'), vars.theta1_0 = app.ic.theta1_0; end
        if isfield(app.ic,'theta2_0'), vars.theta2_0 = app.ic.theta2_0; end
    end

    % --- hysteresis ---
    if isfield(app,'hyst') && isstruct(app.hyst)
        if isfield(app.hyst,'th_on'), vars.th_on = app.hyst.th_on; end

        if isfield(app.hyst,'delta')
            vars.hyst_delta = app.hyst.delta;
        end

        if isfield(app.hyst,'th_off')
            vars.th_off = app.hyst.th_off;
        elseif isfield(app.hyst,'th_on') && isfield(app.hyst,'delta')
            vars.th_off = app.hyst.th_on - app.hyst.delta;
        end

        if isfield(app.hyst,'enabled')
            vars.use_hyst = double(app.hyst.enabled ~= 0);
        end
    end

    % --- LQR ---
    if isfield(app,'lqr') && isstruct(app.lqr)
        if isfield(app.lqr,'Q'), vars.Q = app.lqr.Q; end
        if isfield(app.lqr,'R'), vars.R = app.lqr.R; end
        if isfield(app.lqr,'K'), vars.K = app.lqr.K; end
    end

    % push into base workspace
    try
        if isfield(app,'mdl')
            dp_export_vars(app.mdl, vars, 'base');
        else
            dp_export_vars('', vars, 'base');
        end
    catch
    end

    % Integrator ICs - set directly if block handles are available
    try
        if isfield(app,'sigBlks') && isstruct(app.sigBlks) && isfield(app,'ic')
            if isfield(app.sigBlks,'x')   && isfield(app.ic,'x0'),       trySetIC(app.sigBlks.x,   app.ic.x0);       end
            if isfield(app.sigBlks,'th1') && isfield(app.ic,'theta1_0'), trySetIC(app.sigBlks.th1, app.ic.theta1_0); end
            if isfield(app.sigBlks,'th2') && isfield(app.ic,'theta2_0'), trySetIC(app.sigBlks.th2, app.ic.theta2_0); end
        end
    catch
    end

    % Fixed-step solver step
    try
        if isfield(app,'mdl') && isfield(vars,'Ts')
            if strcmpi(get_param(app.mdl,'SolverType'),'Fixed-step')
                set_param(app.mdl,'FixedStep', num2str(vars.Ts));
            end
        end
    catch
    end

    guidata(fig, app);
end

function trySetIC(blk, icVal)
    try
        if strcmpi(get_param(blk,'BlockType'),'Integrator')
            set_param(blk,'InitialCondition', num2str(icVal));
        end
    catch
    end
end
