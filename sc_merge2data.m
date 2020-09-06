function [X,genelist,c]=sc_merge2data(X1,X2,genelist1,genelist2,method)
if nargin<5, method='intersect'; end

switch lower(method)
    case 'intersect'
        [genelist,i,j]=intersect(genelist1,genelist2);
        X1a=X1(i,:);
        X2a=X2(j,:);
    case 'union'
        [genelist]=union(genelist1,genelist2);
        [~,i]=ismember(genelist1,genelist);
        [~,j]=ismember(genelist2,genelist);
        X1a=zeros(length(genelist),size(X1,2));
        X2a=zeros(length(genelist),size(X2,2));
        X1a(i,:)=X1;
        X2a(j,:)=X2;
end
        X=[X1a X2a];
        c=1+[zeros(size(X1,2),1); ones(size(X2,2),1)];
