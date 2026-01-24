function dp_ui_lock(fig, locked)
if nargin < 2
    locked = true;
end

if isempty(fig) || ~ishandle(fig)
    return;
end

a = guidata(fig);

if isfield(a,'uiLocked') && isequal(a.uiLocked, logical(locked))
    return;
end
a.uiLocked = logical(locked);

hs = gobjects(0);

hs = addH(hs, a, {'ui','edtX0'});
hs = addH(hs, a, {'ui','edtTh10'});
hs = addH(hs, a, {'ui','edtTh20'});

hs = addH(hs, a, {'ui','edtKickAmp'});

hs = addH(hs, a, {'ui','btnResetAll'});
hs = addH(hs, a, {'ui','hP'});
hs = addH(hs, a, {'ui','hQ'});
hs = addH(hs, a, {'ui','edtR'});
hs = addH(hs, a, {'ui','chkHyst'});
hs = addH(hs, a, {'ui','edtThOn'});
hs = addH(hs, a, {'ui','edtDelta'});

hs = addH(hs, a, {'ui','btnPreset'});

if a.uiLocked
    setEnableSafe(hs, 'off');
else
    setEnableSafe(hs, 'on');
end

guidata(fig, a);
end

function hs = addH(hs, a, path)
try
    v = a;
    for i = 1:numel(path)
        v = v.(path{i});
    end
    if isempty(v)
        return;
    end
    v = v(:);
    v = v(isgraphics(v));
    hs = [hs; v];
catch
end
end

function setEnableSafe(hs, state)
try
    for i = 1:numel(hs)
        h = hs(i);
        if isgraphics(h)
            try
                set(h,'Enable',state);
            catch
            end
        end
    end
catch
end
end
