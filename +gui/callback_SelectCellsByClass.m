function callback_SelectCellsByClass(src, ~)
FigureHandle = src.Parent.Parent;
sce = guidata(FigureHandle);


[ptsSelected] = gui.i_select1classcells(sce, true);
if isempty(ptsSelected), return; end

[ax, bx] = view();
fw = gui.gui_waitbar;
try
    scex = selectcells(sce, ptsSelected);
    % scex.c=cLi(ci(idx));
    scex.c = sce.c(ptsSelected);
    sc_scatter_sce(scex);
    view(ax, bx);
catch ME
    gui.gui_waitbar(fw, true);
    errordlg(ME.message);
    return;
end
gui.gui_waitbar(fw);
end
