function ui_update_kick(fig)
    if nargin < 1 || isempty(fig) || ~ishandle(fig)
        return;
    end

    app = guidata(fig);

    if ~isfield(app,'ui') || ~isfield(app.ui,'edtKickAmp') || ~ishandle(app.ui.edtKickAmp)
        return;
    end

    v = str2double(get(app.ui.edtKickAmp,'String'));
    if ~isfinite(v)
        % fallback - zostaw poprzednią wartość
        if isfield(app,'kick') && isfield(app.kick,'amp')
            v = app.kick.amp;
        else
            v = 70;
        end
        try, set(app.ui.edtKickAmp,'String',num2str(v)); catch, end
    end

    if ~isfield(app,'kick') || ~isstruct(app.kick)
        app.kick = struct('amp', v, 'dur', 0.05, 'timer', []);
    else
        app.kick.amp = v;
    end

    guidata(fig, app);
end
