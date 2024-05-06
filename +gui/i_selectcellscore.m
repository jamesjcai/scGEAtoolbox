function [selecteditem] = i_selectcellscore


selecteditem = [];
selitems = {'Select a Predefined Score...', ...
    'Define a New Score...', ...
    '--------------------------------', ...
    'MSigDB Signature Score...', ...
    'PanglaoDB Cell Type Marker Score...', ...
    'TF Targets Expression Score...'};


% selitems={'MSigDB Molecular Signatures',...
%           'DoRothEA TF Targets Expression',...
%         'Predefined Gene Collections'};

%    '--------------------------------', ...
%    'Differentiation Potency [PMID:33244588]', ...
%    'Expression of Individual Genes', ...
%    '--------------------------------', ...
%    'Library Size of Cells', ...
%    'Other Cell Attribute...'};

% 'TF Activity Score [PMID:33135076]
% 🐢 ',... 🐇

[indx1, tf1] = listdlg('PromptString', ...
    'Select cell score:', ...
        'SelectionMode', 'single', 'ListString', selitems, ...
        'ListSize', [220, 300]);
    if tf1 ~= 1, return; end

    selecteditem = selitems{indx1};
end