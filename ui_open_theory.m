function ui_open_theory(fig)
    %#ok<*NASGU>
    % Wklej tutaj swój link:
    url = 'https://github.com/Kasjopeja/DoubleInvertedPendulum/tree/master';

    try
        web(url, '-browser'); % domyślna przeglądarka
    catch
        % awaryjnie, gdyby web() nie zadziałało
        try
            if ispc
                system(['start "" "' url '"']);
            elseif ismac
                system(['open "' url '"']);
            else
                system(['xdg-open "' url '"']);
            end
        catch
        end
    end
end
