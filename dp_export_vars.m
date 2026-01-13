function dp_export_vars(mdl, vars, where)
%DP_EXPORT_VARS Eksport zmiennych do base i/lub ModelWorkspace.

    if nargin < 3 || isempty(where)
        where = 'both';
    end

    fn = fieldnames(vars);

    if any(strcmpi(where, {'base','both'}))
        for i = 1:numel(fn)
            assignin('base', fn{i}, vars.(fn{i}));
        end
    end

    if any(strcmpi(where, {'model','both'}))
        try
            load_system(mdl);
            mws = get_param(mdl,'ModelWorkspace');
            for i = 1:numel(fn)
                assignin(mws, fn{i}, vars.(fn{i}));
            end
        catch
        end
    end
end
