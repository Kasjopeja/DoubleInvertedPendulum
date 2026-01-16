function dp_plot(fig, action)
%DP_PLOT Live plot manager for simulation signals (start/stop/clear/tick).
%
% Maintains a timer-driven loop that samples selected Simulink runtime signals
% (x, th1, th2, and optionally u) and updates the UI plots in real time. The
% function also handles plot lifecycle actions: creating/starting the timer,
% stopping/disposing it, clearing buffers/lines, and performing a single update
% tick while the model is running.
%
% Inputs:
%   fig    - handle to the main UI figure (holds plot state, line handles, and model refs in guidata).
%   action - command string: 'start' | 'stop' | 'clear' | 'tick'.

a = guidata(fig);

switch lower(action)
    case 'start'
        if isempty(a.timer) || ~isvalid(a.timer)
            a.timer = timer( ...
                'ExecutionMode','fixedSpacing', ...
                'Period', 0.05, ...
                'BusyMode','drop', ...
                'TimerFcn', @(~,~)dp_plot(fig,'tick'));
            guidata(fig,a);
        end
        try
            if strcmp(a.timer.Running,'off')
                start(a.timer);
            end
        catch
        end

        try
            if ~isfield(a.plot,'wallT0') || isempty(a.plot.t)
                a.plot.wallT0 = tic;
            end
            guidata(fig,a);
        catch
        end

    case 'stop'
        try
            if ~isempty(a.timer) && isvalid(a.timer)
                stop(a.timer);
                delete(a.timer);
            end
        catch
        end
        a.timer = [];
        guidata(fig,a);

    case 'clear'
        a.plot.t   = [];
        a.plot.x   = [];
        a.plot.th1 = [];
        a.plot.th2 = [];

        set(a.lines.x,  'XData', nan, 'YData', nan);
        set(a.lines.th1,'XData', nan, 'YData', nan);
        set(a.lines.th2,'XData', nan, 'YData', nan);

        xlim(a.ax.x, [0 1]);
        xlim(a.ax.th,[0 1]);
        guidata(fig,a);
        drawnow;

    case 'tick'
        try
            st = '';
            try, st = get_param(a.mdl,'SimulationStatus'); catch, return; end

            try
                if isfield(a,'ui') && isfield(a.ui,'txtStatus') && isgraphics(a.ui.txtStatus)
                    ss = mapStatusLocal(st);
                    set(a.ui.txtStatus,'String', sprintf('STATUS: %s', ss));
                end
            catch
            end

            if strcmpi(st,'stopped') || strcmpi(st,'paused')
                guidata(fig,a);
                return;
            end

            t = NaN;
            try
                t = sscanf(get_param(a.mdl,'SimulationTime'), '%f', 1);
            catch
            end
            if ~isfinite(t)
                try
                    if isfield(a.plot,'wallT0')
                        t = toc(a.plot.wallT0);
                    end
                catch
                end
            end
            if ~isfinite(t)
                return;
            end

            if isfield(a,'plot') && isfield(a.plot,'t') && ~isempty(a.plot.t)
                if t < a.plot.t(end) - 1e-9
                    return;
                end
            end

            try
                roX  = get_param(a.sigBlks.x,  'RuntimeObject');
                roT1 = get_param(a.sigBlks.th1,'RuntimeObject');
                roT2 = get_param(a.sigBlks.th2,'RuntimeObject');

                xVal   = roX.OutputPort(1).Data;
                th1Val = roT1.OutputPort(1).Data;
                th2Val = roT2.OutputPort(1).Data;
            catch
                return;
            end

            uVal = NaN;
            try
                if isfield(a.sigBlks,'u') && ~isempty(a.sigBlks.u)
                    roU = get_param(a.sigBlks.u,'RuntimeObject');
                    uVal = roU.OutputPort(1).Data;
                end
            catch
                uVal = NaN;
            end

            th1Val = wrapToPiLocal(th1Val);
            th2Val = wrapToPiLocal(th2Val);

            a.plot.t(end+1)   = t;
            a.plot.x(end+1)   = xVal;
            a.plot.th1(end+1) = th1Val;
            a.plot.th2(end+1) = th2Val;

            if numel(a.plot.t) > a.plot.maxN
                k = numel(a.plot.t) - a.plot.maxN;
                a.plot.t   = a.plot.t(k+1:end);
                a.plot.x   = a.plot.x(k+1:end);
                a.plot.th1 = a.plot.th1(k+1:end);
                a.plot.th2 = a.plot.th2(k+1:end);
            end

            set(a.lines.x,  'XData', a.plot.t, 'YData', a.plot.x);
            set(a.lines.th1,'XData', a.plot.t, 'YData', a.plot.th1);
            set(a.lines.th2,'XData', a.plot.t, 'YData', a.plot.th2);

            t0 = max(0, t - a.plot.tWindow);
            xlim(a.ax.x,  [t0, max(t0+1e-6, t)]);
            xlim(a.ax.th, [t0, max(t0+1e-6, t)]);

            try
                if isfinite(uVal)
                    set(a.ui.txtU, 'String', sprintf('u = %.3g N', uVal));
                else
                    set(a.ui.txtU, 'String', 'u = -');
                end
            catch
            end

            guidata(fig,a);
            drawnow limitrate;
        catch

        end
end
end

function ang = wrapToPiLocal(ang)
ang = mod(ang + pi, 2*pi) - pi;
end

function s = mapStatusLocal(st)

try
    st = lower(char(st));
catch
    st = lower(char(string(st)));
end

switch strtrim(st)
    case {'initializing','updating','starting','initialization','compile','compiling'}
        s = 'COMPILING';
    case 'running'
        s = 'RUNNING';
    case 'paused'
        s = 'PAUSED';
    case {'stopped','terminating'}
        s = 'STOPPED';
    otherwise
        s = upper(st);
end
end
