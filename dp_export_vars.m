function dp_export_vars(mdl, vars, where)
%DP_EXPORT_VARS Export a set of variables to the base workspace and/or the model workspace.
%
% Writes all fields of the input struct vars as individual variables into the
% requested destination: MATLAB base workspace, Simulink model workspace, or both.
% Used as the single utility for propagating app/config values into the runtime
% environment in a consistent way.
%
% Inputs:
%   mdl   - Simulink model name (required for 'model' or 'both' destinations).
%   vars  - struct where each field is exported as a separate variable.
%   where - destination selector: 'base' | 'model' | 'both' (default: 'both').


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
