function ui_update_model_info(fig)
%UI_UPDATE_MODEL_INFO Build and wrap constant model-parameter info text.
% The text is wrapped dynamically to the current width of the control.

    if nargin < 1 || isempty(fig) || ~ishandle(fig)
        return;
    end

    try
        app = guidata(fig);
    catch
        return;
    end

    if ~isstruct(app) || ~isfield(app,'ui') || ~isfield(app.ui,'txtModelInfo')
        return;
    end

    h = app.ui.txtModelInfo;
    if isempty(h) || ~ishandle(h)
        return;
    end

    % Build raw string from current app.p (treated as constants in UI)
    p = struct();
    try
        if isfield(app,'p') && isstruct(app.p)
            p = app.p;
        end
    catch
    end

    M  = safeField(p,'M',1.0);
    m1 = safeField(p,'m1',0.10);
    m2 = safeField(p,'m2',0.10);
    l1 = safeField(p,'l1',0.50);
    l2 = safeField(p,'l2',0.50);
    g  = safeField(p,'g',9.81);

    raw = sprintf('Stałe modelu: M=%.4g kg, m1=%.4g kg, m2=%.4g kg, l1=%.4g m, l2=%.4g m, g=%.4g m/s^2', ...
        M, m1, m2, l1, l2, g);

    % Keep raw text in UserData (so we can re-wrap without recomputing, if needed)
    try, set(h,'UserData', raw); catch, end

    % Wrap to control width
    try
        wrapped = textwrap(h, {raw});
        set(h,'String', wrapped);
    catch
        % fallback (no wrapping)
        try, set(h,'String', raw); catch, end
    end
end

function v = safeField(s, name, fallback)
    v = fallback;
    try
        if isstruct(s) && isfield(s,name)
            vv = s.(name);
            if isnumeric(vv) && isscalar(vv) && isfinite(vv)
                v = vv;
            end
        end
    catch
    end
end
