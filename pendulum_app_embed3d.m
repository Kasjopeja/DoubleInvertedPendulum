function pendulum_app_embed3d()
    MODEL_FILE = 'model.slx';   % jeśli masz inną nazwę pliku -> zmień tutaj
    VRML_FILE  = '3DAnimation.wrl';      % jeśli masz inną nazwę -> zmień tutaj

    % folder aplikacji na path
    appDir = fileparts(mfilename('fullpath'));
    addpath(appDir);

    % reset base + load model
    [mdl, p0] = dp_reset(MODEL_FILE);
    cfg = dp_defaults(mdl);

    % VR world (musi być open przed vr.canvas)
    wrl = VRML_FILE;
    if exist(wrl,'file') ~= 2
        wrl2 = fullfile(appDir, wrl);
        if exist(wrl2,'file') == 2, wrl = wrl2; end
    end
    w = vrworld(wrl);
    open(w);

    % ---------- UI ----------
    f = figure( ...
        'Name','Pendulum app', ...
        'NumberTitle','off', ...
        'Position',[100 100 1400 800], ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'DockControls','off', ...
        'CloseRequestFcn', @onClose, ...
        'SizeChangedFcn', @onResize);

    leftW = 0.30;
    gap = 0.008;

    pLeft = uipanel('Parent', f, 'Units','normalized', ...
        'Position',[0.02 0.02 leftW 0.96], 'BorderType','none');

    % wysokości sekcji w lewej kolumnie (tak, żeby nie ucinało panelu Parametry)
    hBtns = 0.22;
    % pasek statusu + miejsce na przycisk „Zaburz” (między sterowaniem a IC)
    hStatus = 0.035;
    pBtns = uipanel('Parent', pLeft, 'Units','normalized', ...
        'Position',[0 1-hBtns 1 hBtns], 'Title','Sterowanie');

    % pasek statusu pomiędzy sekcjami
    pStatus = uipanel('Parent', pLeft, 'Units','normalized', ...
        'Position',[0 1-hBtns-hStatus 1 hStatus], ...
        'BorderType','none');

    hIC = 0.17;
    pIC = uipanel('Parent', pLeft, 'Units','normalized', ...
        'Position',[0 1-hBtns-hStatus-hIC-gap 1 hIC], 'Title','Warunki początkowe');

    pParams = uipanel('Parent', pLeft, 'Units','normalized', ...
        'Position',[0 0 1 1-hBtns-hStatus-hIC-2*gap], 'Title','Parametry');

    % przyciski sterowania
    xPad = 0.06; colGap = 0.05;
    kickY = 0.05; kickH = 0.20;
    rowGap = 0.06;
    row2H = 0.23; yRow2 = kickY + kickH + rowGap;
    row1H = 0.36; yRow1 = yRow2 + row2H + rowGap;
    btnW12 = (1 - 2*xPad - colGap) / 2;

    uicontrol('Parent', pBtns, 'Style','pushbutton', 'String','Start / Restart', ...
        'Units','normalized', 'Position',[xPad yRow1 btnW12 row1H], 'Callback', @onStart);

    uicontrol('Parent', pBtns, 'Style','pushbutton', 'String','Pause / Continue', ...
        'Units','normalized', 'Position',[xPad+btnW12+colGap yRow1 btnW12 row1H], 'Callback', @onPause);

    colGap4 = 0.03;
    btnW4 = (1 - 2*xPad - 3*colGap4) / 4;
    for i = 1:4
        x = xPad + (i-1)*(btnW4+colGap4);
        uicontrol('Parent', pBtns, 'Style','pushbutton', 'String',sprintf('Preset %d', i), ...
            'Units','normalized', 'Position',[x yRow2 btnW4 row2H], ...
            'Callback', @(~,~)onPreset(i));
    end


    % szybkie „kopnięcie” (impuls na u) w trakcie RUNNING
    btnKick = uicontrol('Parent', pBtns, 'Style','pushbutton', 'String','ZABURZ', ...
        'Units','normalized', 'Position',[xPad kickY 1-2*xPad kickH], ...
        'FontSize', 12, 'FontWeight','bold', ...
        'Callback', @onDisturb);
    % status symulacji - pomiędzy sekcjami
    txtStatus = uicontrol('Parent', pStatus, 'Style','text', 'Units','normalized', ...
        'Position',[0.02 0.05 0.96 0.90], 'String','STATUS: STOPPED', ...
        'HorizontalAlignment','left', ...
        'FontSize', 12, 'FontWeight','bold', ...
        'BackgroundColor', get(pLeft,'BackgroundColor'));
    % IC
    bg = get(pIC,'BackgroundColor');
    uicontrol('Parent', pIC, 'Style','text', 'Units','normalized', ...
        'Position',[0.06 0.66 0.32 0.18], 'String','x [m]', ...
        'HorizontalAlignment','left', 'BackgroundColor',bg);
    edtX0 = uicontrol('Parent', pIC, 'Style','edit', 'Units','normalized', ...
        'Position',[0.45 0.66 0.50 0.20], 'String','0', 'Callback', @onApplyIC);

    uicontrol('Parent', pIC, 'Style','text', 'Units','normalized', ...
        'Position',[0.06 0.38 0.32 0.18], 'String','θ₁ [rad]', ...
        'HorizontalAlignment','left', 'BackgroundColor',bg);
    edtTh10 = uicontrol('Parent', pIC, 'Style','edit', 'Units','normalized', ...
        'Position',[0.45 0.38 0.50 0.20], 'String','0', 'Callback', @onApplyIC);

    uicontrol('Parent', pIC, 'Style','text', 'Units','normalized', ...
        'Position',[0.06 0.10 0.32 0.18], 'String','θ₂ [rad]', ...
        'HorizontalAlignment','left', 'BackgroundColor',bg);
    edtTh20 = uicontrol('Parent', pIC, 'Style','edit', 'Units','normalized', ...
        'Position',[0.45 0.10 0.50 0.20], 'String','0', 'Callback', @onApplyIC);

    % prawa strona
    rightX = 0.02 + leftW + gap;
    rightW = 0.96 - leftW - gap;

    pRight = uipanel('Parent', f, 'Units','normalized', ...
        'Position',[rightX 0.02 rightW 0.96], 'BorderType','none');

    topH = 0.58;
    p3d = uipanel('Parent', pRight, 'Units','normalized', ...
        'Position',[0 1-topH 1 topH], 'Title','Animacja 3D');

    pPlots = uipanel('Parent', pRight, 'Units','normalized', ...
        'Position',[0 0 1 1-topH-gap], 'Title','Wykresy');

    stripH = 0.12;
    p3dStrip = uipanel('Parent', p3d, 'Units','normalized', ...
        'Position',[0 1-stripH 1 stripH], 'BorderType','none');
    p3dView = uipanel('Parent', p3d, 'Units','normalized', ...
        'Position',[0 0 1 1-stripH], 'BorderType','none');

    txtU = uicontrol('Parent', p3dStrip, 'Style','text', 'Units','normalized', ...
        'Position',[0.05 0.15 0.40 0.6], 'String','u = 0 N', ...
        'HorizontalAlignment','left', 'FontSize', 9, ...
        'BackgroundColor', get(p3dStrip,'BackgroundColor'));

    uicontrol('Parent', p3dStrip, 'Style','pushbutton', 'Units','normalized', ...
        'Position',[0.78 0.18 0.20 0.64], 'String','Reset view', ...
        'FontSize', 9, 'Callback', @onResetView);

    c = vr.canvas(w, p3dView);

    % wykresy
    plotGap = 0.06;
    axW = (1 - 3*plotGap) / 2;
    axH = 0.78;
    axY = 0.14;

    axX = axes('Parent', pPlots, 'Units','normalized', 'Position',[plotGap axY axW axH]);
    grid(axX,'on'); hold(axX,'on');
    xlabel(axX,'t [s]'); ylabel(axX,'x [m]');
    title(axX,'Położenie x');
    hX = plot(axX, nan, nan);
    hold(axX,'off');

    axTh = axes('Parent', pPlots, 'Units','normalized', 'Position',[2*plotGap+axW axY axW axH]);
    grid(axTh,'on'); hold(axTh,'on');
    xlabel(axTh,'t [s]'); ylabel(axTh,'θ [rad]');
    title(axTh,'Kąty θ');
    hTh1 = plot(axTh, nan, nan);
    hTh2 = plot(axTh, nan, nan);
    ylim(axTh, [-pi pi]);
    yticks(axTh, [-pi -pi/2 0 pi/2 pi]);
    yticklabels(axTh, {'-\pi','-\pi/2','0','\pi/2','\pi'});
    hold(axTh,'off');

    % parametry UI
    ui = ui_build_params(pParams, f, cfg);
    
    try
        set(ui.btnHystPlot, 'Callback', @(~,~)dp_hyst_window(f));
    catch
    end

    % ---------- app ----------
    app = struct();
    app.mdl = mdl;
    app.w = w;
    app.canvas = c;
    app.initViewpoint = [];
    try, app.initViewpoint = c.Viewpoint; catch, end

    app.p = p0;

    app.sim = struct('Ts', cfg.sim.Ts);
    app.lqr = struct('Q', diag(cfg.lqr.Qdiag), 'R', cfg.lqr.R, 'K', zeros(1,6));
    app.eq  = struct('theta1e', cfg.eq.theta1e, 'theta2e', cfg.eq.theta2e, 'x_ref', cfg.eq.x_ref, 'mode', cfg.eq.mode);
    app.hyst = struct('th_on', cfg.hyst.th_on, 'delta', cfg.hyst.delta, 'th_off', cfg.hyst.th_on - cfg.hyst.delta, 'enabled', logical(cfg.hyst.enabled));
    app.ic = struct('x0', cfg.ic.x0, 'theta1_0', cfg.ic.theta1_0, 'theta2_0', cfg.ic.theta2_0);

    app.ui = ui;
    app.ui.txtU = txtU;
    app.ui.txtStatus = txtStatus;
    app.ui.edtX0 = edtX0;
    app.ui.edtTh10 = edtTh10;
    app.ui.edtTh20 = edtTh20;

    app.ax = struct('x',axX,'th',axTh);
    app.lines = struct('x',hX,'th1',hTh1,'th2',hTh2);

    app.plot = struct('t',[],'x',[],'th1',[],'th2',[], 'maxN',5000,'tWindow',10);
    app.timer = [];

    % bloki sygnałowe: bierzemy po nazwie (Twoje Integrator2/5/7)
    app.sigBlks = struct();
    app.sigBlks.x   = dp_find_block(mdl,'Integrator5');
    app.sigBlks.th1 = dp_find_block(mdl,'Integrator7');
    app.sigBlks.th2 = dp_find_block(mdl,'Integrator2');
    app.sigBlks.u   = dp_find_block(mdl,'Switch1');
    app.sigBlks.vr  = dp_find_block(mdl,'VR Sink');
    app.sigBlks.kick = dp_find_block(mdl,'kick');  % Constant block for runtime disturbance

    % runtime kick settings (amplitude added to u, duration in seconds)
    % domyślna amplituda „kopnięcia” - 70 (mocniej widać na wykresie u i w animacji)
    app.kick = struct('amp', 70, 'dur', 0.05, 'timer', []);


    guidata(f, app);
    % initial UI refresh + export
    try, ui_update_eq(f); catch, end
    try, ui_update_hysteresis(f); catch, end
    try, ui_update_lqr(f); catch, end
    try, dp_sync_base(f); catch, end

    % ---------- callbacks ----------
    function onStart(~,~)
        % „update/start” potrafi chwilę trwać (kompilacja). Pokaż to od razu.
        setStatusLabel('COMPILING');
        drawnow limitrate;
        a = guidata(f);
        dp_plot(f,'clear');
        ui_update_hysteresis(f);
        ui_update_lqr(f);
        dp_sync_base(f);

        % ensure kick is reset at start (and stop any pending kick timer)
        try, set_param(a.sigBlks.kick,'Value','0'); catch, end
        try
            if isfield(a,'kick') && isfield(a.kick,'timer') && ~isempty(a.kick.timer) && isvalid(a.kick.timer)
                if strcmpi(a.kick.timer.Running,'on')
                    stop(a.kick.timer);
                end
            end
        catch
        end

        try
            st = get_param(app.mdl,'SimulationStatus');
            if ~strcmpi(st,'stopped')
                set_param(app.mdl,'SimulationCommand','stop');
            end
        catch
        end
        % proste ustawienia wydajnosci (bez ingerencji w logike modelu)
        applyPerfHints();

        try, set_param(app.mdl,'SimulationCommand','update'); catch, end
        try, set_param(app.mdl,'SimulationCommand','start');  catch, end

        dp_plot(f,'start');
        setStatusLabel('RUNNING');
    end

    function onResize(~,~)
        % no-op (layout is static)
    end

    function onPause(~,~)
        st = '';
        try, st = get_param(app.mdl,'SimulationStatus'); catch, end

        if strcmpi(st,'running')
            try, set_param(app.mdl,'SimulationCommand','pause'); catch, end
            setStatusLabel('PAUSED');
            % Pause plotting without deleting timer (avoids axis/time reset glitches)
            try
                a = guidata(f);
                if isfield(a,'timer') && ~isempty(a.timer) && isvalid(a.timer)
                    stop(a.timer);
                end
            catch
            end
        elseif strcmpi(st,'paused')
            try, set_param(app.mdl,'SimulationCommand','continue'); catch, end
            setStatusLabel('RUNNING');
            % Resume plotting
            dp_plot(f,'start');
        end
    end

    function onDisturb(~,~)
        a = guidata(f);

        % Runtime 'kick' during RUNNING: adds short impulse to u via Constant block "kick".
        st = '';
        try, st = get_param(a.mdl,'SimulationStatus'); catch, end
        if ~strcmpi(st,'running')
            return; % kick only while running
        end

        % zapewnij istnienie timera (re-use, bez kasowania przy każdym kliknięciu)
        try
            if ~isfield(a,'kick') || ~isstruct(a.kick)
                a.kick = struct('amp',70,'dur',0.05,'timer',[]);
            end
            if ~isfield(a.kick,'timer') || isempty(a.kick.timer) || ~isvalid(a.kick.timer)
                a.kick.timer = timer( ...
                    'ExecutionMode','singleShot', ...
                    'StartDelay', a.kick.dur, ...
                    'TimerFcn', @(~,~)kickOff() );
            end
            if strcmpi(a.kick.timer.Running,'on')
                stop(a.kick.timer);
            end
            a.kick.timer.StartDelay = a.kick.dur;
            guidata(f,a);
        catch
            % jeśli timer nie powstał, spróbujemy bez niego (reset natychmiast)
        end

        % apply impulse
        try
            set_param(a.sigBlks.kick,'Value', num2str(a.kick.amp));
        catch
            return;
        end

        % schedule reset to zero
        try
            a = guidata(f);
            if isfield(a,'kick') && isfield(a.kick,'timer') && ~isempty(a.kick.timer) && isvalid(a.kick.timer)
                start(a.kick.timer);
            else
                set_param(a.sigBlks.kick,'Value','0');
            end
        catch
            try, set_param(a.sigBlks.kick,'Value','0'); catch, end
        end
    end

    function kickOff()
        try
            a = guidata(f);
            set_param(a.sigBlks.kick,'Value','0');
        catch
        end
    end

function ang = disturbAngleLocal(angEq, d)
        % utrzymaj wartosc numerycznie "blisko" rownowagi (0 lub pi), bez przeskoku przez +/-pi
        if abs(angEq) < pi/2
            ang = angEq + d;
        else
            ang = angEq - d;
        end
        if ang > pi,  ang = ang - 2*pi; end
        if ang < -pi, ang = ang + 2*pi; end
    end

    function onPreset(k)
        a = guidata(f);
        d = 0.25;

        % punkt równowagi (dla LQR i opisu w UI)
        switch k
            case 1, th1e = 0;   th2e = 0;
            case 2, th1e = pi;  th2e = pi;
            case 3, th1e = 0;   th2e = pi;
            case 4, th1e = pi;  th2e = 0;
            otherwise, th1e = 0; th2e = 0;
        end
        a.eq.theta1e = th1e;
        a.eq.theta2e = th2e;
        a.eq.x_ref   = 0;
        a.eq.mode    = k;

        % IC: „po drugiej stronie” względem punktu równowagi
        if th1e == 0
            th10 = pi - d;
        else
            th10 = -d;
        end
        if th2e == 0
            th20 = pi - d;
        else
            th20 = -d;
        end

        set(a.ui.edtX0,  'String','0');
        set(a.ui.edtTh10,'String',num2str(th10));
        set(a.ui.edtTh20,'String',num2str(th20));

        guidata(f,a);

        ui_update_eq(f);
        ui_update_lqr(f);
        dp_sync_base(f);
    end

    function onResetView(~,~)
        a = guidata(f);
        if isempty(a.initViewpoint), return; end
        try, a.canvas.Viewpoint = a.initViewpoint; catch, end
    end

    function onClose(~,~)
        % zablokuj ponowne wejście + ogranicz zdarzenia myszy (to usuwa spam "JavaCanvas/ButtonExited")
        try, set(f,'CloseRequestFcn',[]); catch, end
        try, set(f,'Visible','off'); drawnow('nocallbacks'); catch, end

        dp_plot(f,'stop');

        a = [];
        try, a = guidata(f); catch, end

        % cleanup runtime kick timer
        try
            if ~isempty(a)
                % wyzeruj zakłócenie
                try, set_param(a.sigBlks.kick,'Value','0'); catch, end
                if isfield(a,'kick') && isfield(a.kick,'timer') && ~isempty(a.kick.timer) && isvalid(a.kick.timer)
                    try
                        if strcmpi(a.kick.timer.Running,'on'), stop(a.kick.timer); end
                    catch
                    end
                    try, delete(a.kick.timer); catch, end
                    a.kick.timer = [];
                    try, guidata(f,a); catch, end
                end
            end
        catch
        end

        setStatusLabel('STOPPED');

        % zatrzymaj symulację
        try
            if ~isempty(a)
                st = get_param(a.mdl,'SimulationStatus');
                if ~strcmpi(st,'stopped')
                    set_param(a.mdl,'SimulationCommand','stop');
                end
            else
                st = get_param(app.mdl,'SimulationStatus');
                if ~strcmpi(st,'stopped')
                    set_param(app.mdl,'SimulationCommand','stop');
                end
            end
        catch
        end

        % zamknięcie VR: najpierw canvas, potem world (bez toolbar -> brak callback error)
        ws = warning;
        try
            warning('off','MATLAB:callback:error');
            warning('off','MATLAB:class:InvalidHandle');
        catch
        end
        try
            if ~isempty(a) && isfield(a,'canvas') && ~isempty(a.canvas)
                try, delete(a.canvas); catch, end
                a.canvas = [];
            end
        catch
        end
        try
            if ~isempty(a) && isfield(a,'w') && ~isempty(a.w)
                try, close(a.w); catch, end
                try, delete(a.w); catch, end
                a.w = [];
            else
                try, close(w); catch, end
                try, delete(w); catch, end
            end
        catch
        end
        try, warning(ws); catch, end

        try, delete(f); catch, end
    end

    function setStatusLabel(s)
        try
            a = guidata(f);
            if isfield(a,'ui') && isfield(a.ui,'txtStatus') && isgraphics(a.ui.txtStatus)
                if isstring(s), s = char(s); end
                if ~ischar(s), s = char(string(s)); end
                s = upper(strtrim(s));
                set(a.ui.txtStatus,'String',sprintf('STATUS: %s', s));
            end
        catch
        end
    end

    function applyPerfHints()
        % 1) mniejszy narzut na logowanie
        try, set_param(app.mdl,'SignalLogging','off'); catch, end
        try, set_param(app.mdl,'DSMLogging','off'); catch, end
        try, set_param(app.mdl,'SaveOutput','off'); catch, end
        try, set_param(app.mdl,'SaveTime','off'); catch, end
        try, set_param(app.mdl,'VisualizeSimOutput','off'); catch, end

        % 2) rozsadniejszy limit kroku dla solvera (ode15s + MaxStep=0.002 potrafi spowolnic model)
        try, set_param(app.mdl,'MaxStep','0.01'); catch, end

        % 3) wolniejsze odswiezanie VR (nie zmienia dynamiki, tylko rendering)
        try
            if isfield(app,'sigBlks') && isstruct(app.sigBlks) && isfield(app.sigBlks,'vr')
                set_param(app.sigBlks.vr,'SampleTime','0.005');
            end
        catch
        end
    end
end

