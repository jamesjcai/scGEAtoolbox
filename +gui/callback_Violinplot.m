function callback_Violinplot(src, ~)

    if isa(src,"SingleCellExperiment")
        sce = src;
        FigureHandle = [];
    else
        FigureHandle = src.Parent.Parent;
        sce = guidata(FigureHandle);
    end
    
    [thisc, ~] = gui.i_select1class(sce);
    if isempty(thisc), return; end
    
    answer = questdlg("Violinplot for gene expression or cell state variables?","", ...
        'Gene Expression', 'Cell State','Gene Expression');

    switch answer
        case 'Gene Expression'
            % [c, cL] = grp2idx(thisc);
            % [c, cL, noanswer] = gui.i_reordergroups(thisc);
            % if noanswer, return; end
            [glist] = gui.i_selectngenes(sce, [], FigureHandle);
            if isempty(glist)
                helpdlg('No gene selected.', '');
                return;
            end

            [Xt] = gui.i_transformx(sce.X);
            n = length(glist);
            thisyv=cell(n,1);
            for k=1:n
                thisyv{k} = full(Xt(upper(sce.g) == upper(glist(k)), :));
            end             
            ylabelv = glist;

        case 'Cell State'
            [thisyv, ylabelv] = gui.i_selectnstates(sce, true);
            a = false(length(thisyv), 1);
            for k = 1:length(thisyv)
                a(k) = isnumeric(thisyv{k});
            end
            if any(a)
                if ~all(a)
                    thisyv = thisyv(a);
                    ylabelv = ylabelv(a);
                    waitfor(helpdlg('Only continuous variables of cell state will be shown.',''));
                end
                
            else
                waitfor(helpdlg('No valid cell state variables. Violinplot cannot be shown.',''));
            end
    end
gui.i_violintabs(thisyv, ylabelv, thisc, FigureHandle);

end
