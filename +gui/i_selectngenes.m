function [glist] = i_selectngenes(sce)

% internal function used by callback_BuildGeneNetwork
glist=[];
gsorted=sort(sce.g);
answer = questdlg('Paste or select genes?',...
	'Build scGRN','Paste','Select','Cancel','Paste');
switch answer
    case 'Cancel'
        return;
    case 'Paste'
        n=length(sce.g);
        tg=gui.gui_inputgenelist(sce.g(randperm(n,20)));        
        if length(tg)>=2
            [y,i]=ismember(tg,sce.g);
            i=i(y);
            glist=tg(y);
            if length(glist)<2
                warndlg('Need at leaset 2 genes');
                return;
            end
        else
            warndlg('Need at least 2 genes');
            return;
        end
    case 'Select'
        [idx]=gui.gui_selmultidlg(gsorted);
        if isempty(idx), return; end
        if length(idx)<2
            warndlg('Need at least 2 genes');
            return;
        else
            glist=gsorted(idx);
            %g='Dhfr, Lmbr1, Reck, Rnf168, Rpl26, Snrnp27, Tmem160'
            %g=["Tcf7","Lef1","Bcl6","Ctla4","Lag3","Pdcd1"];
        end
end
end