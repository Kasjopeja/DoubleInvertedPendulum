function blk = dp_find_block(mdl, name)

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
    blk = [mdl '/' name];
end
end
