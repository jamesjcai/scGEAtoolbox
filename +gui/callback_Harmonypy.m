function [done]=callback_Harmonypy(src,~)
    done=false;
    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);
    if numel(unique(sce.c_batch_id))<2
        warndlg('No batch effect (SCE.C_BATCH_ID is empty)');
        return;
    end
    x=pyenv;
    if isempty(x.Executable)
        i_setpyenv
    else
        answer = questdlg(sprintf('%s',x.Executable), ...
            'Python Executable', ...
            'Use this','Use another','Cancel','Use this');        
        switch answer
            case 'Use this'
            case 'Use another'
                if ~gui.i_setpyenv, return; end                    
            case {'Cancel',''}
                return;
            otherwise
                return;
        end

        answer = questdlg('Using MATLAB engine for Python or Calling Python script?', ...
            'Engine Interface', ...
            'Use MATLAB Engine for Python','Call Python Script',...
            'Cancel','Use MATLAB Engine for Python');
        switch answer
            case 'Use MATLAB Engine for Python'
                usepylib=true;
            case 'Call Python Script'
                usepylib=false;                
            case {'Cancel',''}
                return;
            otherwise
                return;
        end        
        
        
        fw=gui.gui_waitbar;
        try
            s=run.harmonypy(sce.s,sce.c_batch_id,usepylib);
            if isempty(s) || isequal(sce.s,s)
                gui.gui_waitbar(fw);
                errordlg("Harmonypy Running Error");
                return;
            end
            sce.s=s;
        catch ME
            gui.gui_waitbar(fw);
            errordlg(ME.message);
            rethrow(ME);
        end 
            gui.gui_waitbar(fw);        
    end
   guidata(FigureHandle,sce);
   done=true;
end


