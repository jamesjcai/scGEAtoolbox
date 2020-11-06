function [t,xyz1]=i_pseudotime_by_princurve(s,plotit)

if nargin<2, plotit=true; end

pw1=fileparts(which(mfilename));
pth=fullfile(pw1,'thirdparty/MPPC');
addpath(pth);


        n=size(s,1);
        mass = 1/n*ones(1,n);
        y0 = []; cut_indices0 = [];
        % y0=i_pseudotime_by_splinefit(s);
        crit_dens = .075;
%        lambda1 = .006;
%        lambda2 = 4/3*sqrt(lambda1/crit_dens);


% lambda1 - the coefficient for length penalty in the objective functional.
% lambda2 - the coefficient for the penalty on the number of curves.

        lambda1 = .006;
        lambda2 = 0.75;

        rho = [];
        tol = 10^-4;
        max_m = size(s,1);
        max_avg_turn = 5;
        normalize_data = 1;
        pause_bool = 0;
        

        tic;
        [yfinal,cut_indices,I,iters] = mppc(y0,cut_indices0,s,mass,lambda1,lambda2,tol,rho,...
            max_m, max_avg_turn,normalize_data,pause_bool,true);
        toc;

        t=I;
        xyz1=yfinal;


 if plotit
  hold on
  plot3(xyz1(:,1),xyz1(:,2),xyz1(:,3),'.r','linewidth',2);
 end
end
