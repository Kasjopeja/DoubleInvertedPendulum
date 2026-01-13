function blk = dp_find_block(mdl, name)
%DP_FIND_BLOCK Find the first block with given Name inside a model.
% Safe helper used by the app to locate Integrators etc.

    blk = '';
    try
        hits = find_system(mdl, ...
            'LookUnderMasks','all', ...
            'FollowLinks','on', ...
            'SearchDepth',inf, ...
            'Name',name);
        if ~isempty(hits)
            blk = hits{1};
        end
    catch
    end

    if isempty(blk)
        % fallback - allows set_param to error with a readable path
        blk = [mdl '/' name];
    end
end
