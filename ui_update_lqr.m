function ui_update_lqr(fig)
%UI_UPDATE_LQR Read LQR tuning values from the UI, compute K, and propagate updates.
%
% Parses the Q diagonal entries and R value from UI controls with basic validation,
% computes the LQR gain using dp_lqr_calc for the current plant/equilibrium, updates
% the on-screen K display, stores results in app.lqr, and pushes the updated values
% to the workspace/model via dp_apply_workspace.
%
% Input:
%   fig - handle to the main UI figure (source/target of app state via guidata).

app = guidata(fig);

q = zeros(1,6);
for i = 1:6
    v = str2double(get(app.ui.hQ(i),'String'));
    if ~isfinite(v) || v < 0
        v = 0;
        set(app.ui.hQ(i),'String','0');
    end
    q(i) = v;
end

Rval = str2double(get(app.ui.edtR,'String'));
if ~isfinite(Rval) || Rval <= 0
    Rval = 100;
    set(app.ui.edtR,'String',num2str(Rval));
end

try
    cfg = struct();
    cfg.p  = app.p;
    cfg.eq = app.eq;
    cfg.lqr = struct('Qdiag', q, 'R', Rval);

    [K,Q,R] = dp_lqr_calc(cfg);

    s = sprintf('%.5g ', K);
    set(app.ui.txtK, 'String', ['K = [ ' strtrim(s) ' ]']);

    app.lqr = struct();
    app.lqr.Qdiag = q;
    app.lqr.Q = Q;
    app.lqr.R = R;
    app.lqr.K = K;
catch
    set(app.ui.txtK, 'String', 'K = [ - ]');
end

guidata(fig, app);
dp_apply_workspace(fig);
end
