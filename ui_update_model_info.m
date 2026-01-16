function ui_update_model_info(fig)
%UI_UPDATE_MODEL_INFO Refresh the on-screen model constants summary text.
%
% Reads the current physical parameters from app.p, formats a human-readable
% summary string, and updates the txtModelInfo control (with optional text wrapping).
%
% Input:
%   fig - handle to the main UI figure (source of app state via guidata).

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

try, set(h,'UserData', raw); catch, end


try
    wrapped = textwrap(h, {raw});
    set(h,'String', wrapped);
catch
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
