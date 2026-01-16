function ui_update_model_consts(fig)
%UI_UPDATE_MODEL_CONSTS Read model constants from the UI, validate, and propagate updates.
%
% Parses the physical parameters (M, m1, m2, l1, l2, g) from the edit controls with
% basic validation/fallbacks, writes them into app.p, and stores the updated state.
% Triggers an LQR refresh (since the plant changed) and requests a Simulink update
% when the model is stopped.
%
% Input:
%   fig - handle to the main UI figure (source/target of app state via guidata).

if nargin < 1 || isempty(fig) || ~ishandle(fig)
    return;
end

app = guidata(fig);

if ~isfield(app,'ui') || ~isfield(app.ui,'hP') || numel(app.ui.hP) < 6
    return;
end

names = {'M','m1','m2','l1','l2','g'};

p0 = struct();
if isfield(app,'p') && isstruct(app.p)
    p0 = app.p;
end

for i = 1:6
    h = app.ui.hP(i);
    v = str2double(get(h,'String'));

    fallback = 1.0;
    if isfield(p0, names{i})
        fallback = p0.(names{i});
    end

    if ~isfinite(v) || v <= 0
        v = fallback;
        try, set(h,'String', num2str(v)); catch, end
    end

    app.p.(names{i}) = v;
end

guidata(fig, app);

try, ui_update_lqr(fig); catch, end

try
    a = guidata(fig);
    st = get_param(a.mdl,'SimulationStatus');
    if strcmpi(st,'stopped')
        set_param(a.mdl,'SimulationCommand','update');
    end
catch
end
end
