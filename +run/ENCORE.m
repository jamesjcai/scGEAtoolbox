function ENCORE(X,genelist)
error('under development');
if nargin<1, X=rand(4,5); end
if nargin<2, genelist=string((1:4)'); end

oldpth=pwd();

[isok,msg]=commoncheck_R('R_ENCORE');
if ~isok, error(msg); return; end

writematrix(X,'input.txt');
writematrix(genelist,'genelist.txt');

cd(oldpth);
end