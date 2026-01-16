function ui_update_model_table(fig)
%UI_UPDATE_MODEL_TABLE Read model parameters from the UI table and propagate updates.
%
% Parses the (label, value) rows from tblModel, maps labels to parameter keys,
% validates/converts values, writes results into app.p and app.sim (Ts), updates
% the table with corrected defaults when needed, and pushes changes via dp_apply_workspace.
%
% Input:
%   fig - handle to the main UI figure (source/target of app state via guidata).

app = guidata(fig);
if ~isfield(app,'ui') || ~isfield(app.ui,'tblModel') || isempty(app.ui.tblModel)
    return;
end

data = [];
try
    data = get(app.ui.tblModel,'Data');
catch
    return;
end

if isempty(data) || size(data,2) < 2
    return;
end

if ~isfield(app,'p') || ~isstruct(app.p)
    app.p = struct();
end
if ~isfield(app,'sim') || ~isstruct(app.sim)
    app.sim = struct();
end

Ts0 = safeField(app.sim,'Ts', 0.005);

p0 = struct();
p0.M  = safeField(app.p,'M',  1.0);
p0.m1 = safeField(app.p,'m1', 0.10);
p0.m2 = safeField(app.p,'m2', 0.10);
p0.l1 = safeField(app.p,'l1', 0.50);
p0.l2 = safeField(app.p,'l2', 0.50);
p0.g  = safeField(app.p,'g',  9.81);
p0.b  = safeField(app.p,'b',  0.0);
p0.c1 = safeField(app.p,'c1', 0.0);
p0.c2 = safeField(app.p,'c2', 0.0);

for i = 1:size(data,1)
    label = data{i,1};
    val = data{i,2};

    key = labelToKey(label);
    if isempty(key)
        continue;
    end

    x = toDouble(val);
    if ~isfinite(x)
        data{i,2} = defaultForKey(key, Ts0, p0);
        continue;
    end

    if strcmp(key,'Ts')
        if x <= 0
            x = Ts0;
        end
        app.sim.Ts = x;
        data{i,2} = x;
    else
        app.p.(key) = x;
        data{i,2} = x;
    end
end

try
    set(app.ui.tblModel,'Data', data);
catch
end

guidata(fig, app);
dp_apply_workspace(fig);
end

function x = toDouble(v)
if isnumeric(v)
    x = double(v);
    return;
end
x = NaN;
try
    x = str2double(v);
catch
end
end

function key = labelToKey(label)
key = '';
if isempty(label)
    return;
end
try
    if isstring(label), label = char(label); end
    if ~ischar(label), return; end

    s = strtrim(label);
    k = regexp(s, '^[^\s\[]+', 'match', 'once');
    if isempty(k)
        return;
    end
    key = k;
catch
    key = '';
end
end

function v = defaultForKey(key, Ts0, p0)
switch key
    case 'Ts', v = Ts0;
    case 'M',  v = p0.M;
    case 'm1', v = p0.m1;
    case 'm2', v = p0.m2;
    case 'l1', v = p0.l1;
    case 'l2', v = p0.l2;
    case 'g',  v = p0.g;
    case 'b',  v = p0.b;
    case 'c1', v = p0.c1;
    case 'c2', v = p0.c2;
    otherwise, v = NaN;
end
end

function v = safeField(s, f, fallback)
v = fallback;
try
    if isstruct(s) && isfield(s,f)
        v = s.(f);
    end
catch
end
end
