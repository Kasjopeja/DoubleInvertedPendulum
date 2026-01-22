function dp_model_init(mdlName)
% Inicjalizacja zmiennych dla modelu - bez bdroot (kompatybilne z deploy)

if nargin < 1 || isempty(mdlName)
    mdlName = 'model';  % <- wpisz tutaj swoją nazwę modelu bez .slx
end

cfg = dp_defaults(mdlName);
p = cfg.p;

Ts = cfg.sim.Ts;
th_on = cfg.hyst.th_on;
hyst_delta = cfg.hyst.delta;
th_off = th_on - hyst_delta;

assignin('base','M',p.M);
assignin('base','m1',p.m1);
assignin('base','m2',p.m2);
assignin('base','l1',p.l1);
assignin('base','l2',p.l2);
assignin('base','g',p.g);
assignin('base','b',p.b);
assignin('base','c1',p.c1);
assignin('base','c2',p.c2);

assignin('base','Ts',Ts);

assignin('base','Q',diag(cfg.lqr.Qdiag));
assignin('base','R',cfg.lqr.R);
assignin('base','K',zeros(1,6));

assignin('base','th_on',th_on);
assignin('base','hyst_delta',hyst_delta);
assignin('base','th_off',th_off);
assignin('base','use_hyst',double(cfg.hyst.enabled ~= 0));

assignin('base','x0',cfg.ic.x0);
assignin('base','theta1_0',cfg.ic.theta1_0);
assignin('base','theta2_0',cfg.ic.theta2_0);

assignin('base','x_ref',cfg.eq.x_ref);
assignin('base','theta1e',cfg.eq.theta1e);
assignin('base','theta2e',cfg.eq.theta2e);
assignin('base','mode',cfg.eq.mode);
end
