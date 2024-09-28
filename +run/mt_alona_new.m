function [T] = mt_alona_new(X, genelist, clusterid, varargin)

% https://alona.panglaodb.se/
% https://academic.oup.com/database/article/doi/10.1093/database/baz046/5427041
% REF: PanglaoDB: a web server for exploration of mouse and human single-cell RNA sequencing data

if isempty(X) || isempty(genelist)
    k = 1;
    T = table("Unknown", 0, 'VariableNames', ...
        {sprintf('C%d_Cell_Type', k), sprintf('C%d_CTA_Score', k)});
    return;
end
if nargin < 3 || isempty(clusterid)
    clusterid = ones(1, size(X, 2));
end
if min(size(clusterid)) ~= 1 || ~isnumeric(clusterid)
    error('CLUSTERID={vector|[]}');
end

p = inputParser;
addRequired(p, 'X', @isnumeric);
addRequired(p, 'genelist', @isstring);
addRequired(p, 'clusterid', @isnumeric);
addOptional(p, 'species', "human", @(x) (isstring(x) | ischar(x)) & ismember(lower(string(x)), ["human", "mouse"]));
addOptional(p, 'bestonly', true, @islogical);
parse(p, X, genelist, clusterid, varargin{:});
species = p.Results.species;
bestonly = p.Results.bestonly;


oldpth = pwd;
pw1 = fileparts(mfilename('fullpath'));
% pth = fullfile(pw1, '..', 'resources', 'celltypes.xlsx');
pth = fullfile(cdgea, 'resources', 'PanglaoDB', 'celltypes.xlsx');

if issparse(X)
    try
        X = full(X);
    catch
        disp('Using sparse input--longer running time is expected.');
    end
end
% warning off
% X=sc_norm(X,"type","deseq");
% warning on
genelist = upper(genelist);

Tm = readtable(pth,'FileType','spreadsheet','Sheet',species);
Tw = pkg.e_markerweight(Tm);

wvalu = Tw.Var2;
wgene = string(upper(Tw.Var1));

[validG, idx1, idx2] = intersect(genelist, wgene);

genelist = genelist(idx1);
X = sc_norm(X(idx1, :));
X = log1p(X);

wvalu = wvalu(idx2);
wgene = wgene(idx2);

%celltypev=string(Tm.Var1);
%[celltypev,idx]=unique(celltypev);
%Tm=Tm(idx,:);

celltypev = string(Tm.CellType);
markergenev = string(Tm.PositiveMarkers);
NC = max(clusterid);

S = zeros(length(celltypev), NC);

for j = 1:length(celltypev)
    g = strsplit(markergenev(j), ',');
    g = strtrim(g);
    if strlength(g(end)) == 0
        g = g(1:end-1);
    end
    g = upper(unique(g));
    y = matches(g, genelist);
    if ~any(y), continue; end
    g = g(y);
    %[~,idx]=ismember(g,genelist);
    Z = zeros(NC, 1);
    ng = zeros(NC, 1);
    for i = 1:length(g)
        % if any(g(i)==wgene) && any(g(i)==genelist)
        gidx = g(i) == genelist;
        %if any(gidx)
        % if matches(g(i),validG)
        wi = wvalu(g(i) == wgene);
        for k = 1:NC
            z = X(gidx, clusterid == k);
            z = mean(z(:));
            Z(k) = Z(k) + z * wi;
            ng(k) = ng(k) + 1;
        end
        %end
    end
    for k = 1:NC
        if ng(k) > 0
            S(j, k) = Z(k) ./ nthroot(ng(k), 3);
        else
            S(j, k) = 0;
        end
    end
end
T = table();
% t=table(celltypev);
for k = 1:NC
    [c, idx] = sort(S(:, k), 'descend');
    if ~isempty(validG)
        T = [T, table(celltypev(idx), c, 'VariableNames', ...
            {sprintf('C%d_Cell_Type', k), sprintf('C%d_CTA_Score', k)})];
    else
        T = [T, table("Unknown", 0, 'VariableNames', ...
            {sprintf('C%d_Cell_Type', k), sprintf('C%d_CTA_Score', k)})];
    end
end
if size(T, 1) > 10
    T = T(1:10, :);
end
if bestonly && size(T, 1) > 1
    T = T(1, :);
end
cd(oldpth);
end
