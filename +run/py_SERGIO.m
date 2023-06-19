function [X]=py_SERGIO(A,ncells)

arguments    
    A (:,:) {mustBeNumericOrLogical,mustBeSquare(A)} = randnet_example
    ncells (1,1) {mustBePositive, mustBeInteger} = 1000
end
X=[];

    ngenes=size(A,1);
    isdebug = true;
    oldpth=pwd();

    [pyok,wrkpth,x]=run.pycommon('py_SERGIO');
    if ~pyok, return; end

    %tmpfilelist={'input.mat','output.mat','regs.txt','targets.txt'};
    tmpfilelist={'input.mat','output.mat'};
    if ~isdebug, pkg.i_deletefiles(tmpfilelist); end

    pkg_e_writesergiogrn(A);

   
    save('input.mat','-v7.3','ncells','ngenes');
    cmdlinestr=sprintf('"%s" "%s%sscript.py"', ...
        x.Executable,wrkpth,filesep);
    disp(cmdlinestr)
    [status]=system(cmdlinestr,'-echo');
    if status==0 && exist('output.mat','file')
        load('output.mat','X');
    end
    if ~isdebug, pkg.i_deletefiles(tmpfilelist); end
    cd(oldpth);
end


function mustBeSquare(X)
    if ~isequal(size(X,1),size(X,2)) || ~ismatrix(X)
        eid = 'Type:notSquareMatrix';
        msg = 'Must be a square matrix.';
        throwAsCaller(MException(eid,msg))
    end
end

function A=randnet_example
    rng(244)
    A=rand(5);
    A=A-diag(diag(A));
    A=A>0.55;
end

% function mustBeSquareEqualSize(X,n)
%     if ~isequal(size(X,1),n) || ~isequal(size(X,2),n)
%         eid = 'Size:notEqual';
%         msg = 'Size of A must equal number of genes.';
%         throwAsCaller(MException(eid,msg))
%     end
% end

% function mustBeRealUpperTriangular(a)
%     if ~(istriu(a) && isreal(a))
%         eidType = 'mustBeRealUpperTriangular:notRealUpperTriangular';
%         msgType = 'Input must be a real-valued, upper triangular matrix.';
%         throwAsCaller(MException(eidType,msgType))
%     end
% end