function callback_scTenifoldXct2(src, ~)

% if ~gui.gui_showrefinfo('scTenifoldXct [PMID:36787742]'), return; end
% [y, prepare_input_only] = gui.i_memorychecked(128);
% if ~y, return; end
% 
% extprogname = 'py_scTenifoldXct2';
% preftagname = 'externalwrkpath';
% [wkdir] = gui.gui_setprgmwkdir(extprogname, preftagname);
% if isempty(wkdir), return; end
% 
% FigureHandle = src.Parent.Parent;
% sce = guidata(FigureHandle);

if ~gui.gui_showrefinfo('scTenifoldXct [PMID:36787742]'), return; end
FigureHandle = src.Parent.Parent;
sce = guidata(FigureHandle);

numglist = [1 3000 5000];
memmlist = [16 32 64 128];
neededmem = memmlist(sum(sce.NumGenes > numglist));
[yesgohead, prepare_input_only] = gui.i_memorychecked(neededmem);
if ~yesgohead, return; end
    
extprogname = 'py_scTenifoldXct';
preftagname = 'externalwrkpath';
[wkdir] = gui.gui_setprgmwkdir(extprogname, preftagname);
if isempty(wkdir), return; end



[~, cL] = grp2idx(sce.c_batch_id);
[j1, j2, ~, ~] = aaa(cL, sce.c_batch_id);
if isempty(j1) || isempty(j2)
    warndlg('All cells have the same BATCH_ID. Two samples are required.','')
    return; 
end
sce1 = sce.selectcells(j1);
sce2 = sce.selectcells(j2);

if sce1.NumCells < 50 || sce2.NumCells < 50
    if ~strcmp(questdlg('One of samples contains too few cells (n < 50). Continue?'), 'Yes'), return; end
end


[~, cL] = grp2idx(sce.c_cell_type_tx);
[~, ~, celltype1, celltype2] = aaa(cL, sce.c_cell_type_tx);
if isempty(celltype1) || isempty(celltype2) 
    warndlg('All cells are the same type. Two different cell types are required.','')
    return; 
end

celltype1 = string(celltype1);
celltype2 = string(celltype2);

a1 = sprintf('%s -> %s', celltype1, celltype2);
a2 = sprintf('%s -> %s', celltype2, celltype1);

twosided = false;
[answer] = questdlg('Select direction: Source (ligand) -> Target (receptor)', '', 'Both', a1, a2, 'Both');
switch answer
    case 'Both'
        ct1 = celltype1;
        ct2 = celltype2;
        twosided = true;
    case a1
        ct1 = celltype1;
        ct2 = celltype2;
    case a2
        ct1 = celltype2;
        ct2 = celltype1;
    otherwise
        return;
end

if ~prepare_input_only
    if ~gui.i_setpyenv, return; end
end

[Tcell, iscomplete] = run.py_scTenifoldXct2(sce1, sce2, ct1, ct2, twosided, ...
    wkdir, true, prepare_input_only);

T = [];
if twosided && iscell(Tcell)
    [T1] = Tcell{1};
    [T2] = Tcell{2};
    if ~isempty(T1)
        a = sprintf('%s -> %s', celltype1, celltype2);
        T1 = addvars(T1, repelem(a, height(T1), 1), 'Before', 1);
        T1.Properties.VariableNames{'Var1'} = 'direction';
    end
    if ~isempty(T2)
        a = sprintf('%s -> %s', celltype2, celltype1);
        T2 = addvars(T2, repelem(a, height(T2), 1), 'Before', 1);
        T2.Properties.VariableNames{'Var1'} = 'direction';
    end
    T = [T1; T2];
else
    if ~isempty(Tcell)
        T = Tcell; 
        a = sprintf('%s -> %s', celltype1, celltype2);
        T = addvars(T, repelem(a, height(T), 1), 'Before', 1);
        T.Properties.VariableNames{'Var1'} = 'direction';
    end   
end

% ---- export result
if ~prepare_input_only && ~iscomplete
    errordlg('Running time error.', '');
end

if ~isempty(T)

    mfolder = fileparts(mfilename('fullpath'));
    load(fullfile(mfolder, '..', 'resources', 'Ligand_Receptor', ...
         'Ligand_Receptor_more.mat'), 'ligand','receptor');
    % knownpair = false(height(T), 1);
    A = [string(T.ligand) string(T.receptor)];
    B = [ligand receptor];
    [knownpair]= ismember(A, B, 'rows');
    assert(length(knownpair)==height(T));
    T=[T, table(knownpair)];

    [b, a] = pkg.i_tempfile("sctendifoldxct");
    writetable(T, b);

    T(:,[4 5 6 7 11])=[];
    
    [answer] = questdlg(sprintf('Result has been saved in %s', b), ...
        '', 'Export result...', 'Locate result file...', ...
        'Export result...');
    switch answer
        case 'Locate result file...'
            winopen(a);
            pause(2)
            if strcmp(questdlg('Export result to other format?'), 'Yes')
                gui.i_exporttable(T, false, 'Ttenifldxt2', 'TenifldXt2Table');
            end
        case 'Export result...'
            gui.i_exporttable(T, false, 'Ttenifldxt2', 'TenifldXt2Table');
        otherwise
            winopen(a);
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

end

function [i1, i2, cL1, cL2] = aaa(listitems, ci)
    i1 = []; i2 = [];
    cL1 = []; cL2 = [];
    n = length(listitems);
    if n < 2, return; end
    [indx, tf] = listdlg('PromptString', {'Select two groups:'}, ...
        'SelectionMode', 'multiple', ...
        'ListString', listitems, ...
        'InitialValue', [n - 1, n], 'ListSize', [220, 300]);
    if tf == 1
        if numel(indx) ~= 2
            errordlg('Please select 2 groups');
            return;
        end
        cL1 = listitems(indx(1));
        cL2 = listitems(indx(2));
        i1 = ci == cL1;
        i2 = ci == cL2;
    end
end
