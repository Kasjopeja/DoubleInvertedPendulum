function ui_open_theory(fig)
url = 'https://github.com/Kasjopeja/DoubleInvertedPendulum/blob/master/Praca_In%C5%BCynierska_Aleksandra_Zakr%C4%99cka.pdf';

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
