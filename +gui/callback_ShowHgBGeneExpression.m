function callback_ShowHgBGeneExpression(src, ~)

FigureHandle = src.Parent.Parent;
sce = guidata(FigureHandle);

species = gui.i_selectspecies(2);
if isempty(species), return; end

switch species
    case 'mouse'
        idx1 = startsWith(sce.g, 'Hba-', 'IgnoreCase', true);
        idx2 = startsWith(sce.g, 'Hbb-', 'IgnoreCase', true);
        % idx3 = strcmpi(sce.g, "Alas2");
        idx3 = false;
    case 'human'
        idx1 = strcmpi(sce.g, "HBA1");
        idx2 = strcmpi(sce.g, "HBA2");
        idx3 = strcmpi(sce.g, "HBB");
end
idx = idx1 | idx2 | idx3;

if any(idx)
    ttxt = sprintf("%s+", sce.g(idx));
    ci = full(sum(sce.X(idx, :), 1));

    hx = gui.myFigure;
    hFig = hx.FigureHandle;
    %tb = uitoolbar('Parent', hFig);
    %pkg.i_addbutton2fig(tb, 'on', {@gui.i_resizewin, hFig}, ...
    %    'HDF_pointx.gif', 'Resize Plot Window');
    

    cm = uicontextmenu(hFig);
    m1 = uimenu(cm, 'Text', 'Save HgBGeneExpression...', "MenuSelectedFcn", {@i_saveM, ci});
    hFig.ContextMenu = cm;

    gui.i_stemscatter(sce.s, ci);

    title(ttxt);
    %tb1 = uitoolbar(hFig);
    hx.addCustomButton('off', {@i_saveM, ci}, 'greencircleicon.gif', ...
        'Save marker gene map...');
    hx.centerto(FigureHandle);
    hx.show;    
else
    warndlg('No Hgb-genes found');
end


    function i_saveM(~, ~, ~)
        if ~(ismcc || isdeployed)
            labels = {'Save C_CELL_ID to variable named:', ...
                'Save HgBGeneExpression to variable named:'};
            vars = {'cell_id', 'c'};
            values = {sce.c_cell_id, ci(:)};
            export2wsdlg(labels, vars, values);
        else
            errordlg(['This function is not available for standalone application.' ...
                ' Run scgeatool.m in MATLAB to use this function.']);                
        end            
    end
end