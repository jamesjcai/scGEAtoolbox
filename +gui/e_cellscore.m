function [cs] = e_cellscore(sce, posg, methodid,showwaitbar)

if nargin < 4, showwaitbar=true; end

cs = [];
if nargin < 3 || isempty(methodid)
    [~, methodid] = gui.i_pickscoremethod;
    % answer = questdlg('Select algorithm:', ...
    %     'Select Method', ...
    %     'UCell [PMID:34285779]', 'AddModuleScore/Seurat', ...
    %     'UCell [PMID:34285779]');
    % switch answer
    %     case 'AddModuleScore/Seurat'
    %         methodid = 2;
    %     case 'UCell [PMID:34285779]'
    %         methodid = 1;
    %     otherwise
    %         return;
    % end
end

if showwaitbar, fw = gui.gui_waitbar; end
try
    if methodid == 1
        [cs] = sc_cellscore_ucell(sce.X, sce.g, posg);
    elseif methodid == 2
        [cs] = sc_cellscore_admdl(sce.X, sce.g, posg);
    end
catch ME
    if showwaitbar, gui.gui_waitbar(fw, true); end
    errordlg(ME.message);
    return;
end
if showwaitbar, gui.gui_waitbar(fw); end

if showwaitbar
    posg = sort(posg);
    isexpressed = ismember(upper(posg), upper(sce.g));
    fprintf('\n=============\n%s\n-------------\n', 'Genes');
    for k = 1:length(posg)
        if isexpressed(k)
            fprintf('%s\t*\n', posg(k));
        else
            fprintf('%s\t\n', posg(k));
        end
    end
    fprintf('=============\n*expressed genes (n=%d)\n', ...
        sum(isexpressed));
end

end