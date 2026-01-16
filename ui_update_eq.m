function ui_update_eq(fig)

app = guidata(fig);

theta = char(952);
sub1  = char(8321);
sub2  = char(8322);

s = sprintf('Balansowanie wokół: x = %.4g, %s%s = %.4g rad, %s%s = %.4g rad', ...
    app.eq.x_ref, theta, sub1, app.eq.theta1e, theta, sub2, app.eq.theta2e);

set(app.ui.txtEq, 'String', s);

guidata(fig, app);
end
