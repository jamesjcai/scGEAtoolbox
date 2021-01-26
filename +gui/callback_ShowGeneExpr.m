function callback_ShowGeneExpr(src,~)
    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);
    [axx,bxx]=view();
    % if any([axx,bxx]==0), axx=ax; bxx=bx; end
    gsorted=sort(sce.g);
    
answer = questdlg('Show expression of single or mulitple genes?',...
	'Single/Multiple Genes',...
	'Single','Multiple','Cancel','Single');

switch answer
    case 'Single'
        [indx,tf] = listdlg('PromptString',{'Select a gene',...
        '',''},'SelectionMode','single','ListString',gsorted);
        if tf==1
            f = figure('visible','off');
            %f=figure;
            [h1]=sc_scattermarker(sce.X,sce.g,...
                   sce.s,gsorted(indx),5);
            view(h1,axx,bxx);
            movegui(f,'center');
            set(f,'visible','on');        
            %movegui(f,'center');
        end
    case 'Multiple'
        %[idx]=gui.gui_selmultidlg;
        %if isempty(idx)
        %    helpdlg('No gene selected.');
        %else
            %
        %end
        helpdlg('Function is under development.');
    case 'Cancel'
        helpdlg('Action cancelled.');
end
end