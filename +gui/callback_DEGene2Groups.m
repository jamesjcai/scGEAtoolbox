function callback_DEGene2Groups(src,~)
    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);    

    [i1,i2]=gui.i_select2grps(sce);
    if i1==0 || i2==0, return; end

    answer = questdlg('Which method?',...
        'Select Method','Wilcoxon rank-sum test',...
        'MAST','Wilcoxon rank-sum test');
    
    if strcmpi(answer,'Wilcoxon rank-sum test')
        methodtag="ranksum";
    elseif strcmpi(answer,'MAST')
        methodtag="mast";
    else
        return;
    end
    fw=gui.gui_waitbar;
    switch methodtag
        case 'ranksum'
            T=sc_deg(sce.X(:,i1),...
                    sce.X(:,i2),sce.g);
        case 'mast'
            T=run.MAST(sce.X(:,i1),...
                    sce.X(:,i2),sce.g);
    end
    gui.gui_waitbar(fw);
    labels = {'Save DE results T to variable named:'}; 
    vars = {'T'}; values = {T};
    msgfig=export2wsdlg(labels,vars,values);
    uiwait(msgfig);
    answer = questdlg('Violin plots (top 16 DE genes)?');
    if strcmp(answer,'Yes')
        figure;
        for k=1:16
            subplot(4,4,k)
            i=sce.g==T.gene(k);
            pkg.i_violinplot(log2(1+sce.X(i,:)),...
                sce.c_batch_id);
            title(T.gene(k));
            ylabel('log2(UMI+1)')
        end
    end   
end