function name = util_pickFont(candidates)
    name = get(0,'DefaultUicontrolFontName');
    lf = {};
    try
        lf = listfonts;
    catch
    end
    for k = 1:numel(candidates)
        if any(strcmpi(lf, candidates{k}))
            name = candidates{k};
            return;
        end
    end
end
