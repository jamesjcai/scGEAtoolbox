function callback_scTenifoldCko(src, ~)

% if ~gui.gui_showrefinfo('scTenifoldCko [PMID:36787742]'), return; end
if isa(src, "SingleCellExperiment")
    sce = src;
    FigureHandle = [];
else
    FigureHandle = src.Parent.Parent;
    sce = guidata(FigureHandle);
end

if ~(isscalar(unique(sce.c_batch_id)) && numel(unique(sce.c_cell_type_tx))==2)
    %errordlg(sprintf('This function requires data in one batch and has two cell types.\nisscalar(unique(sce.c_batch_id)) && numel(unique(sce.c_cell_type_tx))==2'),'');
    %return;
end

numglist = [1 3000 5000];
memmlist = [16 32 64 128];
neededmem = memmlist(sum(sce.NumGenes > numglist));
[yesgohead, prepare_input_only] = gui.i_memorychecked(neededmem);
if ~yesgohead, return; end

    
extprogname = 'scTenifoldCko';
preftagname = 'externalwrkpath';
[wkdir] = gui.gui_setprgmwkdir(extprogname, preftagname);
if isempty(wkdir), return; end


if ~prepare_input_only
    if ~gui.i_setpyenv, return; end
end

[thisc, clabel] = gui.i_select1class(sce, false, 'Select grouping variable (cell type):', 'Cell Type');
if isempty(thisc), return; end

if ~strcmp(clabel, 'Cell Type')
    if ~strcmp(questdlg('You selected grouping varible other than ''Cell Type''. Continue?'), 'Yes'), return; end
end

[c, cL] = grp2idx(thisc);
[idx] = gui.i_selmultidlg(cL, [], FigureHandle);
if isempty(idx), return; end
if numel(idx) < 2
    warndlg('Need at least 2 cell groups to perform cell-cell interaction analysis.');
    return;
end
if numel(idx) ~= 2
    warndlg(sprintf('Need only 2 cell groups to perform cell-cell interaction analysis. You selected %d.', ...
        numel(idx)));
    return;
end

x1 = idx(1);
x2 = idx(2);

%{
[~,cL]=grp2idx(sce.c_cell_type_tx);
if length(cL)<2, errordlg('Need at least 2 cell types.'); return; end

[indxx,tf2] = listdlg('PromptString',...
    {'Select two cell types:'},...
    'SelectionMode','multiple','ListString',cL, 'ListSize', [220, 300]);
if tf2==1
    if numel(indxx)~=2
        errordlg('Please select 2 cell types');
        return;
    end
    x1=indxx(1);
    x2=indxx(2);
else
    return;
end
%}

%celltype1 = sprintf('%s -> %s', cL{x1}, cL{x2});
%celltype2 = sprintf('%s -> %s', cL{x2}, cL{x1});

%{
twosided = false;
answer = questdlg('Select direction: Source (ligand) -> Target (receptor)', '', 'Both', celltype1, celltype2, 'Both');
switch answer
    case 'Both'
        x1 = x1;
        x2 = x2;
        twosided = true;
    case celltype1
        x1 = x1;
        x2 = x2;
    case celltype2
        x1 = x2;
        x2 = x1;
    otherwise
        return;
end

idx=sce.c_cell_type_tx==cL{x1} | sce.c_cell_type_tx==cL{x2};
sce=sce.selectcells(idx);

sce.c_batch_id=sce.c_cell_type_tx;
sce.c_batch_id(sce.c_cell_type_tx==cL{x1})="Source";
sce.c_batch_id(sce.c_cell_type_tx==cL{x2})="Target";
%}


sce.c_batch_id = thisc;
sce.c_batch_id(c == x1) = "Source";
sce.c_batch_id(c == x2) = "Target";
sce.c_cell_type_tx = string(cL(c));

% idx=thisc==cL{x1} | thisc==cL{x2};
idx = c == x1 | c == x2;
sce = sce.selectcells(idx);

% -------

gsorted = natsort(sce.g);
if isempty(gsorted), return; end
[indx2, tf] = listdlg('PromptString', {'Select a KO gene'}, ...
    'SelectionMode', 'single', 'ListString', gsorted, 'ListSize', [220, 300]);
if tf == 1
    [~, idx] = ismember(gsorted(indx2), sce.g);
else
    return;
end
targetg = sce.g(idx);

celltype1 = cL{x1};
celltype2 = cL{x2};

answer = questdlg(sprintf('Knockout %s in which cell type?',targetg), '', 'Both', celltype1, celltype2, 'Both');
switch answer
    case 'Both'
        targetcelltype=sprintf('%s+%s', celltype1, celltype2);
    case celltype1
        targetcelltype=celltype1;
    case celltype2
        targetcelltype=celltype2;
    otherwise
        return;
end
% -------
%sce.c_batch_id(thisc==cL{x1})="Source";
%sce.c_batch_id(thisc==cL{x2})="Target";

T = [];
%try
    [Tcell] = run.py_scTenifoldCko(sce, cL{x1}, cL{x2}, targetg, ...
        targetcelltype, wkdir, true, prepare_input_only);
    if ~isempty(Tcell)
        [T1] = Tcell{1};
        [T2] = Tcell{2};
        if ~isempty(T1)
            a = sprintf('%s -> %s', cL{x1}, cL{x2});
            T1 = addvars(T1, repelem(a, height(T1), 1), 'Before', 1);
            T1.Properties.VariableNames{'Var1'} = 'direction';
        end
        if ~isempty(T2)
            a = sprintf('%s -> %s', cL{x2}, cL{x1});
            T2 = addvars(T2, repelem(a, height(T2), 1), 'Before', 1);
            T2.Properties.VariableNames{'Var1'} = 'direction';
        end
        T = [T1; T2];
    end
% catch ME
%     errordlg(ME.message);
%     return;
% end

if ~isempty(T)
    mfolder = fileparts(mfilename('fullpath'));
    load(fullfile(mfolder, '..', 'resources', 'Ligand_Receptor', ...
         'Ligand_Receptor_more.mat'), 'ligand','receptor');
    A = [string(T.ligand) string(T.receptor)];
    B = [ligand receptor];
    [knownpair]= ismember(A, B, 'rows');
    assert(length(knownpair)==height(T));

    T=[T, table(knownpair)];
    % T(:,[4 5 6 7 11])=[];
    
    outfile = fullfile(wkdir,"outfile.csv");
    if isfile(outfile)
        answerx = questdlg('Overwrite outfile.csv? Select No to save in a temporary file.');
    else
        answerx = 'Yes';
    end
    if isempty(wkdir) || ~isfolder(wkdir) || ~strcmp(answerx, 'Yes')
        [a, b] = pkg.i_tempdirfile("sctendifoldcko");
        writetable(T, b);
    
        answer = questdlg(sprintf('Result has been saved in %s', b), ...
            '', 'Export result...', 'Locate result file...', 'Export result...');
        switch answer
            case 'Locate result file...'
                winopen(a);
                pause(2)
                if strcmp(questdlg('Export result to other format?'), 'Yes')
                    gui.i_exporttable(T, false, 'Ttenifldcko', 'TenifldCkoTable');
                end
            case 'Export result...'
                gui.i_exporttable(T, false, 'Ttenifldcko', 'TenifldCkoTable');
            otherwise
                winopen(a);
        end
    else
        writetable(T, outfile);
        waitfor(helpdlg(sprintf('Result has been saved in %s', outfile), ''));
    end
else
    if ~prepare_input_only
        helpdlg('No ligand-receptor pairs are identified.', '');
    else
        if strcmp(questdlg('Input files are prepared successfully. Open working folder?',''), 'Yes')
            winopen(wkdir);
        end
    end
end



eb = h5read('merged_embeds.h5','/data')';

n = height(eb);
sl = n / 4;

% Split the eb into four equal-length sub-ebs
a = eb(1:sl,:);
b = eb(sl+1:2*sl,:);
c = eb(2*sl+1:3*sl,:);
d = eb(3*sl+1:4*sl,:);

%dx = abs(pdist2(a,b)-pdist2(c,d));
%[x,y]=pkg.i_maxij(dx, 1050);
%[sce.g(x) sce.g(y)]
%dx1 = pdist2(a,c);
%dx1 = pdist2(b,d);
%[x,y]=maxij(dx1, 50);
%[sce.g(x) sce.g(y)]

[T] = ten.i_dr(a, c, sce.g, true);
outfile = sprintf('outfile_%s_expression_changes.csv',celltype1);
writetable(T, outfile);

[T] = ten.i_dr(b, d, sce.g, true);
outfile = sprintf('outfile_%s_expression_changes.csv',celltype1);
writetable(T, outfile);

end
