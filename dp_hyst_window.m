function dp_hyst_window(fig)
    % aktualizuj wartości z UI
    ui_update_hysteresis(fig);
    app = guidata(fig);

    th_on_raw  = app.hyst.th_on;
    th_off_raw = app.hyst.th_off;

    % W praktyce wejście do Relay bywa -e, więc progi w modelu są ujemne.
    % Na wykresie pokazujemy e = max(|e1|,|e2|) >= 0.
    th_on  = abs(th_on_raw);
    th_off = abs(th_off_raw);

    % upewnij się, że off jest dalej od zera niż on
    if th_off < th_on
        tmp = th_on; th_on = th_off; th_off = tmp;
    end

    if ~isfield(app,'hystFig') || isempty(app.hystFig) || ~isvalid(app.hystFig)
        app.hystFig = figure('Name','Wykres histerezy','NumberTitle','off', 'Position',[250 250 720 360]);
        app.hystAx = axes('Parent', app.hystFig, 'Position',[0.10 0.18 0.86 0.74]);
        guidata(fig, app);
    end

    ax = app.hystAx;
    cla(ax); grid(ax,'on'); hold(ax,'on');

    eMax = max(0.8, 1.6*max(th_on, th_off));
    xlim(ax, [0 eMax]);
    ylim(ax, [-0.2 1.2]);
    yticks(ax, [0 1]);
    yticklabels(ax, {'rozhuśtanie','LQR'});

    % logika: e < th_on -> LQR; e > th_off -> swingup
    % (granice...); rysujemy oba progi.
    stairs(ax, [0 th_on th_on eMax],   [1 1 0 0], '-',  'LineWidth',1.6);
    stairs(ax, [0 th_off th_off eMax], [1 1 0 0], '--', 'LineWidth',1.6);
    xline(ax, th_on,  ':');
    xline(ax, th_off, ':');

    title(ax, sprintf('Relay: th\_on = %.3g (raw %.3g), th\_off = %.3g (raw %.3g)', th_on, th_on_raw, th_off, th_off_raw));

    xlabel(ax,'e = max(|e1|, |e2|) [rad]');
    ylabel(ax,'tryb');

    hold(ax,'off');
end
