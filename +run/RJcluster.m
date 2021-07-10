function [s]=RJcluster(X)
%RJcluster - R pacakge
oldpth=pwd();
[isok,msg]=commoncheck_R('R_RJcluster');
if ~isok, error(msg); end
if exist('input.csv','file'), delete('input.csv'); end
if exist('output.csv','file'), delete('output.csv'); end
writematrix(X','input.csv');

pkg.RunRcode('script.R');
if exist('output.csv','file')
    s=readmatrix('output.csv');
    s=s(:,2);
else
    s=[];
end
%if exist('input.csv','file'), delete('input.csv'); end
%if exist('output.csv','file'), delete('output.csv'); end
cd(oldpth);
end
