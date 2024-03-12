function [methodtagsel] = i_pickembedmethod_new

methodtagsel = [];
% [indx2, tf2] = listdlg('PromptString', ...
%     {'Select embedding method:'}, ...
%     'SelectionMode', 'single', 'ListString', ...
%     {'tSNE', 'UMAP', 'PHATE', ...
%     'MetaViz [PMID:36774377] 🐢'}, 'ListSize', [175, 130]);
% if ~tf2, return; end
% methodopt = {'tsne', 'umap', 'phate', 'metaviz'};
% methodtag = methodopt{indx2};


listitems = {'tSNE 2D', 'tSNE 3D',...
    'UMAP 2D', 'UMAP 3D',...
    'PHATE 2D', 'PHATE 3D',...
    'MetaViz [PMID:36774377] 2D 🐢',...
    'MetaViz [PMID:36774377] 3D 🐢'};

methodtag = {'tsne2d', 'tsne3d', 'umap2d', 'umap3d',...
    'phate2d', 'phate3d', 'metaviz2d', 'metaviz3d'};

sce = SingleCellExperiment;
validmethodtag = fieldnames(sce.struct_cell_embeddings);
assert(all(ismember(methodtag,validmethodtag)));

    [indx2, tf2] = listdlg('PromptString', ...
        {'Select embedding methods:'}, ...
        'SelectionMode', 'multiple', ...
        'ListString', listitems, ...
        'InitialValue', [1 2]);
    if tf2 == 1        
        methodtagsel = methodtag(indx2);     
    end
end
