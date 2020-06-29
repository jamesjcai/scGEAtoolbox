function [T]=run_celltypeassignation(rankdedgenelist,k)
% see also: sc_pickmarkers
% Demo:
%gx=sc_pickmarkers(X,genelist,cluster_id,2);
%run_celltypeassignation(gx)

if nargin<2, k=5; end
if isempty(FindRpath)
   error('Rscript.exe is not found.');
end

oldpth=pwd;
pw1=fileparts(which(mfilename));
pth=fullfile(pw1,'thirdparty/R_cellTypeAssignation');
cd(pth);

if exist('output.txt','file')
    delete('output.txt');
end
%if ~exist('input.txt','file')
    % txtwrite('input.txt',rankdedgenelist);
    writetable(table(rankdedgenelist),'input.txt','WriteVariableNames',false);
%end
RunRcode('script.R');
if exist('output.txt','file')
    T=readtable('output.txt');
else
    T=[];
end
T=T(1:k,:);
if exist('input.txt','file')
    delete('input.txt');
end
if exist('output.txt','file')
    delete('output.txt');
end
cd(oldpth);
