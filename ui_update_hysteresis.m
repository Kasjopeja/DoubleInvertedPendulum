function ui_update_hysteresis(fig)
%UI_UPDATE_HYSTERESIS Read hysteresis controls, update app state and export once.

    app = guidata(fig);

    % enabled toggle (optional)
    enabled = 1;
    try
        if isfield(app.ui,'chkHyst')
            enabled = get(app.ui.chkHyst,'Value');
        end
    catch
        enabled = 1;
    end

    th_on = str2double(get(app.ui.edtThOn,'String'));
    if ~isfinite(th_on)
        th_on = app.hyst.th_on;
        set(app.ui.edtThOn,'String',num2str(th_on));
    end

    delta = str2double(get(app.ui.edtDelta,'String'));
    if ~isfinite(delta) || delta < 0
        delta = app.hyst.delta;
        set(app.ui.edtDelta,'String',num2str(delta));
    end

    app.hyst.th_on   = th_on;
    app.hyst.delta   = delta;
    app.hyst.th_off  = th_on - delta;
    app.hyst.enabled = enabled ~= 0;

    set(app.ui.edtThOff,'String',num2str(app.hyst.th_off));

    guidata(fig, app);
    dp_apply_workspace(fig);
end
