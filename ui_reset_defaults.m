function ui_reset_defaults(fig)
%UI_RESET_DEFAULTS Reset the UI and app state back to default configuration values.
%
% Loads the default cfg via dp_defaults for the current model, overwrites the
% app state (p, sim, eq, ic, lqr, hyst), updates corresponding UI controls, and
% triggers the standard update/sync functions so the workspace/model reflects
% the reset values.
%
% Input:
%   fig - handle to the main UI figure (source/target of app state via guidata).


if nargin < 1 || isempty(fig) || ~ishandle(fig)
    return;
end

app = guidata(fig);

mdl = 'model';
try
    if isfield(app,'mdl') && ~isempty(app.mdl)
        mdl = app.mdl;
    end
catch
end

cfg = dp_defaults(mdl);

app.p = cfg.p;
app.sim = cfg.sim;

try
    if isfield(app.ui,'hP')
        vals = [cfg.p.M cfg.p.m1 cfg.p.m2 cfg.p.l1 cfg.p.l2 cfg.p.g];
        for i = 1:min(numel(app.ui.hP), numel(vals))
            set(app.ui.hP(i),'String', num2str(vals(i)));
        end
    end
catch
end

app.eq = cfg.eq;

try
    if isfield(app.ui,'edtX0'),  set(app.ui.edtX0, 'String', num2str(cfg.ic.x0)); end
    if isfield(app.ui,'edtTh10'), set(app.ui.edtTh10,'String', num2str(cfg.ic.theta1_0)); end
    if isfield(app.ui,'edtTh20'), set(app.ui.edtTh20,'String', num2str(cfg.ic.theta2_0)); end
catch
end

try
    if isfield(app.ui,'chkHyst'), set(app.ui.chkHyst,'Value', double(cfg.hyst.enabled ~= 0)); end
    if isfield(app.ui,'edtThOn'), set(app.ui.edtThOn,'String', num2str(cfg.hyst.th_on)); end
    if isfield(app.ui,'edtDelta'), set(app.ui.edtDelta,'String', num2str(cfg.hyst.delta)); end
    if isfield(app.ui,'edtThOff'), set(app.ui.edtThOff,'String', num2str(cfg.hyst.th_on - cfg.hyst.delta)); end
catch
end

try
    if isfield(app.ui,'hQ')
        qd = cfg.lqr.Qdiag;
        for i = 1:min(numel(app.ui.hQ), numel(qd))
            set(app.ui.hQ(i),'String', num2str(qd(i)));
        end
    end
    if isfield(app.ui,'edtR'), set(app.ui.edtR,'String', num2str(cfg.lqr.R)); end
catch
end

guidata(fig, app);

try, ui_update_eq(fig); catch, end
try, ui_update_hysteresis(fig); catch, end
try, ui_update_lqr(fig); catch, end
try, dp_sync_base(fig); catch, end

try
    a = guidata(fig);
    dp_apply_workspace(fig);
    st = get_param(a.mdl,'SimulationStatus');
    if strcmpi(st,'stopped')
        set_param(a.mdl,'SimulationCommand','update');
    end
catch
end
end
