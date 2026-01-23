function dp_ui_lock(fig, locked)
%DP_UI_LOCK Blokuje/odblokowuje edycję parametrów w UI podczas symulacji.
%   locked = true  -> blokada
%   locked = false -> odblokowanie

    if nargin < 2
        locked = true;
    end

    if isempty(fig) || ~ishandle(fig)
        return;
    end

    a = guidata(fig);

    % Idempotencja (żeby nie mielić Enable co 50 ms)
    if isfield(a,'uiLocked') && isequal(a.uiLocked, logical(locked))
        return;
    end
    a.uiLocked = logical(locked);

    % Co blokujemy: wszystkie pola edycyjne/checkboxy od parametrów i IC + presety/reset
    hs = gobjects(0);

    % IC
    hs = addH(hs, a, {'ui','edtX0'});
    hs = addH(hs, a, {'ui','edtTh10'});
    hs = addH(hs, a, {'ui','edtTh20'});

    % Parametry (panel Parametry)
    hs = addH(hs, a, {'ui','btnResetAll'});
    hs = addH(hs, a, {'ui','hP'});
    hs = addH(hs, a, {'ui','hQ'});
    hs = addH(hs, a, {'ui','edtR'});
    hs = addH(hs, a, {'ui','chkHyst'});
    hs = addH(hs, a, {'ui','edtThOn'});
    hs = addH(hs, a, {'ui','edtDelta'});
    % edtThOff ma Enable='inactive' na stałe, nie ruszamy

    % Presety (zmieniają punkt równowagi/IC i przeliczają LQR)
    hs = addH(hs, a, {'ui','btnPreset'});

    % Ustaw Enable
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
