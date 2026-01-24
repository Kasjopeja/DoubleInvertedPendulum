function dp_scale_fonts(fig)
if nargin < 1 || isempty(fig) || ~ishandle(fig)
    return;
end

a = guidata(fig);

if ~isfield(a,'ui') || ~isfield(a.ui,'fontBase') || isempty(a.ui.fontBase)
    hs = findall(fig, '-property','FontSize');
    hs = hs(isgraphics(hs));
    baseSizes = arrayfun(@(h)get(h,'FontSize'), hs);

    a.ui.fontBase.handles = hs;
    a.ui.fontBase.sizes   = baseSizes;
    a.ui.fontBase.figPos  = get(fig,'Position');
    guidata(fig, a);
end

a = guidata(fig);
if ~isfield(a.ui,'fontBase'), return; end

pos  = get(fig,'Position');
base = a.ui.fontBase.figPos;

if base(3) <= 0 || base(4) <= 0
    return;
end

s = min(pos(3)/base(3), pos(4)/base(4));
s = max(0.75, min(1.45, s));

hs = a.ui.fontBase.handles;
bs = a.ui.fontBase.sizes;

for i = 1:numel(hs)
    h = hs(i);
    if isgraphics(h)
        try
            set(h, 'FontSize', bs(i) * s);
        catch
        end
    end
end
end
