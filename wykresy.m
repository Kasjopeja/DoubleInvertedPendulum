% ============================================================
% Wykres 1: x + theta1 + theta2 (kąty rozdzielone na dwa pola)
% Wykres 2: u + tryb (SUR/LQR) -> ta sama WYSOKOŚĆ okna co wykres 1
% ============================================================

FS = 24; 
LW = 2;
Ts = 0.01;                        % ustaw jak w modelu
wrap = @(a) atan2(sin(a),cos(a)); % (-pi, pi]

% --- dane (array)
x   = out.x(:);
th1 = wrap(out.theta1(:));
th2 = wrap(out.theta2(:));

u = out.sila(:);
r = out.tryb(:);

% --- czas
N  = numel(x);
t  = (0:N-1)'*Ts;

N2 = min(numel(u), numel(r));
u  = u(1:N2);
r  = r(1:N2);
t2 = (0:N2-1)'*Ts;

tEnd = max(t(end), t2(end));

% ============================================================
% FIG 1: położenie + theta1 + theta2 (3 osie)
% ============================================================
fig1 = figure('Color','w','Units','pixels','Position',[100 100 1600 900]);

% --- górny: położenie
ax1 = axes(fig1,'Position',[0.07 0.70 0.86 0.25], 'PositionConstraint','innerposition');
plot(ax1, t, x, 'LineWidth', LW);
grid(ax1,'on');
yl = ylabel(ax1,'Położenie wózka');
yl.Units = 'normalized';
yl.Position(1) = -0.04;
set(ax1,'FontSize',FS);
xlim(ax1,[0 tEnd]);

% --- środkowy: theta1
ax2 = axes(fig1,'Position',[0.07 0.40 0.86 0.25], 'PositionConstraint','innerposition');
plot(ax2, t, th1, 'LineWidth', LW);
grid(ax2,'on');
yl2 = ylabel(ax2,'Kąt \theta_1');
yl2.Units = 'normalized';
yl2.Position(1) = -0.03;
set(ax2,'FontSize',FS);
xlim(ax2,[0 tEnd]);

% --- dolny: theta2
ax3 = axes(fig1,'Position',[0.07 0.10 0.86 0.25], 'PositionConstraint','innerposition');
plot(ax3, t, th2, 'LineWidth', LW);
grid(ax3,'on');
xlabel(ax3,'Czas [s]');
yl3 = ylabel(ax3,'Kąt \theta_2');
yl3.Units = 'normalized';
yl3.Position(1) = -0.03;
set(ax3,'FontSize',FS);
xlim(ax3,[0 tEnd]);

fig1Pos = fig1.Position;   % <-- rozmiar okna do skopiowania

% ============================================================
% FIG 2: siła + tryb (ta sama wysokość okna co fig1)
% ============================================================
fig2 = figure('Color','w','Units','pixels','Position',fig1Pos);

ax = axes(fig2,'Position',[0.07 0.10 0.86 0.85], ...
    'PositionConstraint','innerposition');
set(ax,'FontSize',FS);
grid(ax,'on');
box(ax,'on');
ax.Layer = 'top';

yyaxis(ax,'left');
plot(ax, t2, u, 'LineWidth', LW);
ylabel(ax,'Siła');
xlabel(ax,'Czas [s]');
xlim(ax,[0 tEnd]);

yyaxis(ax,'right');
stairs(ax, t2, r, 'LineWidth', LW);
ax.YLim  = [-0.2 1.2];
ax.YTick = [0 1];

ax.YAxis(1).Color = 'k';
ax.YAxis(1).Label.Color = 'k';

ax.YAxis(2).TickLabels = {};
ax.YAxis(2).TickLength = [0 0];
ax.YAxis(2).Label.String = '';
ax.YAxis(2).Color = [0 0 0];

% napisy SUR/LQR (możesz zostawić swoje wartości)
xLab = 1.01;
yLQR = 0.87;
ySUR = 0.13;

text(ax, xLab, yLQR, 'LQR', 'Units','normalized', ...
    'HorizontalAlignment','left', 'VerticalAlignment','middle', 'FontSize',FS, 'Clipping','off');
text(ax, xLab, ySUR, 'SUR', 'Units','normalized', ...
    'HorizontalAlignment','left', 'VerticalAlignment','middle', 'FontSize',FS, 'Clipping','off');

text(ax, 1.03, 0.50, 'Tryb regulatora', 'Units','normalized', ...
    'Rotation',90, 'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', 'FontSize',FS, 'Clipping','off');
