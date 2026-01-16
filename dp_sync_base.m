function dp_sync_base(fig)
%DP_SYNC_BASE Read base parameters from the UI, update app state, and apply them to the workspace.
%
% Synchronizes initial-condition fields by parsing numeric values from UI edit
% controls into app.ic (with safe fallbacks and legacy field cleanup), stores the
% updated state via guidata, and then propagates the result through dp_apply_workspace.
%
% Input:
%   fig - handle to the main UI figure (source/target of app state via guidata).

app = guidata(fig);

app.ic.x0 = readNum(app.ui.edtX0, safeFallback(app.ic,'x0',0));

th10_fb = safeFallback(app.ic,'theta1_0', safeFallback(app.ic,'th10',0));
th20_fb = safeFallback(app.ic,'theta2_0', safeFallback(app.ic,'th20',0));

app.ic.theta1_0 = readNum(app.ui.edtTh10, th10_fb);
app.ic.theta2_0 = readNum(app.ui.edtTh20, th20_fb);

if isfield(app.ic,'th10'), app.ic = rmfield(app.ic,'th10'); end
if isfield(app.ic,'th20'), app.ic = rmfield(app.ic,'th20'); end

guidata(fig, app);
dp_apply_workspace(fig);
end

function v = readNum(h, fallback)
v = fallback;
try
    s = get(h,'String');
    tmp = str2double(s);
catch
    tmp = NaN;
end

if isfinite(tmp)
    v = tmp;
else
    try, set(h,'String',num2str(fallback)); catch, end
end
end

function v = safeFallback(s, field, fallback)
v = fallback;
try
    if isstruct(s) && isfield(s,field)
        v = s.(field);
    end
catch
end
end
