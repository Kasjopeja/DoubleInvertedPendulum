function ui_update_lqr(fig)
%UI_UPDATE_LQR Read Q/R from UI, compute K, update app state and export once.

    app = guidata(fig);

    % --- Q diag ---
    q = zeros(1,6);
    for i = 1:6
        v = str2double(get(app.ui.hQ(i),'String'));
        if ~isfinite(v) || v < 0
            v = 0;
            set(app.ui.hQ(i),'String','0');
        end
        q(i) = v;
    end

    % --- R ---
    % (handle name unified to edtR)
    Rval = str2double(get(app.ui.edtR,'String'));
    if ~isfinite(Rval) || Rval <= 0
        Rval = 100;
        set(app.ui.edtR,'String',num2str(Rval));
    end

    % compute K
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
        % keep previous values if any
    end

    guidata(fig, app);
    dp_apply_workspace(fig);
end
