function ui_update_cart_params(fig)
%UI_UPDATE_CART_PARAMS Read cart parameters (M, b) from UI and export.

    if nargin < 1 || isempty(fig) || ~ishandle(fig)
        return;
    end

    app = guidata(fig);

    if ~isfield(app,'ui') || ~isfield(app.ui,'edtM') || ~isfield(app.ui,'edtB')
        return;
    end

    M = str2double(get(app.ui.edtM,'String'));
    b = str2double(get(app.ui.edtB,'String'));

    if ~isfinite(M) || M <= 0
        % revert
        if isfield(app,'p') && isfield(app.p,'M')
            M = app.p.M;
        else
            M = 1.0;
        end
        set(app.ui.edtM,'String',num2str(M));
    end

    if ~isfinite(b)
        if isfield(app,'p') && isfield(app.p,'b')
            b = app.p.b;
        else
            b = 0.0;
        end
        set(app.ui.edtB,'String',num2str(b));
    end

    if ~isfield(app,'p') || ~isstruct(app.p)
        app.p = struct();
    end
    app.p.M = M;
    app.p.b = b;

    guidata(fig, app);
    dp_apply_workspace(fig);

    % force model update so dependent blocks see new values
    try
        st = get_param(app.mdl,'SimulationStatus');
        if strcmpi(st,'stopped')
            set_param(app.mdl,'SimulationCommand','update');
        end
    catch
    end
end
