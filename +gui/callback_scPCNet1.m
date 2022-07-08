function callback_scPCNet1(src,events)
    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);

    answer=questdlg('Construct gene regulatory network (GRN) for all cells or selected cells?',...
        '','All Cells','Select Cells...','Cancel',...
        'All Cells');
    switch answer
        case 'Cancel'
            return;
        case 'All Cells'
            
        case 'Select Cells...'
            gui.callback_SelectCellsByClass(src,events);
            return;
        otherwise
            return;
    end
   
%     answer=questdlg('This analysis may take several hours. Continue?');
%     if ~strcmpi(answer,'Yes'), return; end

    useparallel=false;
    answer=questdlg('Use parallel computing or not?','Parallel Computing', ...
        'Use parallel','Not use parallel','Use parallel');
    switch answer
        case 'Use parallel'
            useparallel=true;
        case 'Not use parallel'
            useparallel=false;
        otherwise
            return;
    end   
    
    try 
        disp('>> [A]=sc_pcnet(sce.X);');
        X=sc_norm(sce.X);
        X=log(X+1);
        if useparallel
            fw=gui.gui_waitbar;
            [A]=sc_pcnetpar(X);
            gui.gui_waitbar(fw);
        else
            [A]=sc_pcnet(X,[],[],[],true);
        end
    catch ME
        if useparallel
            gui.gui_waitbar(fw,true);
        end
        errordlg(ME.message);
        return;
    end    


    try
        tmpmat=tempname;
        g=sce.g;
        fprintf('Saving network (A) to %s.mat\n',tmpmat);
        save(tmpmat,'A','g','-v7.3');
    catch ME
        disp(ME.message);
    end

    % tstr=matlab.lang.makeValidName(datestr(datetime));
    % save(sprintf('A_%s',tstr),'A','g','-v7.3');

    if ~(ismcc || isdeployed)
        labels = {'Save network to variable named:',...
            'Save sce.g to variable named:'}; 
        vars = {'A','g'};
        values = {A,sce.g};
        waitfor(export2wsdlg(labels,vars,values));
    end
    
        answer = questdlg('Save network A to MAT file?');
        switch answer
            case 'Yes'
                [file, path] = uiputfile({'*.mat';'*.*'},'Save as');
                if isequal(file,0) || isequal(path,0)
                   return;
                else
                   filename=fullfile(path,file);
                   fw=gui.gui_waitbar;
                   g=sce.g;
                   save(filename,'A','g','-v7.3');
                   gui.gui_waitbar(fw);                   
                end
        end
   
end