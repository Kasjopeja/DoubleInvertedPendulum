function ui_open_theory(fig)
url = 'https://github.com/Kasjopeja/DoubleInvertedPendulum/tree/master';

try
    web(url, '-browser');
catch
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
