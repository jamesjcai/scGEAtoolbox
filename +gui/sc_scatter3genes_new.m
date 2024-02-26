function sc_scatter3genes_new(X, g, dofit, showdata, parentfig)
%Scatter3 plot for genes

if nargin < 5, parentfig = []; end
if nargin < 4, showdata = true; end
if nargin < 3, dofit = true; end
if nargin < 2 || isempty(g), g = string(1:size(X,1)); end

[lgu, dropr, lgcv, g, X] = sc_genestat(X, g);

x = lgu;
y = lgcv;
z = dropr;

fw = gui.gui_waitbar;
hFig = figure('Visible','off');
hFig.Position(3)=hFig.Position(3)*1.8;

if ~isempty(parentfig)
    [px_new] = gui.i_getchildpos(parentfig, hFig);
    if ~isempty(px_new)
        movegui(hFig, px_new);
    else
        movegui(hFig, 'center');
    end
end

% hAx = axes('Parent', hFig);

tb = findall(hFig, 'Tag', 'FigureToolBar'); % get the figure's toolbar handle

% tb = uitoolbar('Parent', hFig);
% set(tb, 'Tag', 'FigureToolBar', ...
%     'HandleVisibility', 'off', 'Visible', 'on');
uipushtool(tb, 'Separator', 'off');
%pkg.i_addbutton2fig(tb, 'off', @in_ShowProfile, 'plotpicker-qqplotx.gif', 'Show Profile of Genes');
pkg.i_addbutton2fig(tb, 'off', @in_HighlightGenes, 'plotpicker-qqplot.gif', 'Highlight top HVGs');
pkg.i_addbutton2fig(tb, 'off', @in_HighlightSelectedGenes, 'xplotpicker-qqplot.gif', 'Highlight selected genes');
pkg.i_addbutton2fig(tb, 'off', @ExportGeneNames, 'export.gif', 'Export selected HVG gene names...');
pkg.i_addbutton2fig(tb, 'off', @ExportTable, 'xexport.gif', 'Export HVG Table...');
pkg.i_addbutton2fig(tb, 'off', @EnrichrHVGs, 'plotpicker-andrewsplot.gif', 'Enrichment analysis...');
pkg.i_addbutton2fig(tb, 'off', @ChangeAlphaValue, 'xplotpicker-andrewsplot.gif', 'Change MarkerFaceAlpha value');
gui.add_3dcamera(tb, 'HVGs');
pkg.i_addbutton2fig(tb, 'off', {@gui.i_savemainfig, 3}, "powerpoint.gif", 'Save Figure to PowerPoint File...');

if showdata
    %h=scatter3(hAx,x,y,z);  % 'filled','MarkerFaceAlpha',.5);
    hAx1 = subplot(2,2,[1 3]);
    h = scatter3(hAx1, x, y, z, 'filled', 'MarkerFaceAlpha', .1);

    if ~isempty(g)
        dt = datacursormode(hFig);
        % dt.UpdateFcn = {@i_myupdatefcn1, g};
    else
        dt = [];
    end
end    
    %grid on
    %box on
    %legend({'Genes','Spline fit'});
    xlabel(hAx1,'Mean, log');
    ylabel(hAx1,'CV, log');
    zlabel(hAx1,'Dropout rate (% of zeros)');

        
% [xData, yData, zData] = prepareSurfaceData(x,y,z);
% xyz=[xData yData zData]';

if dofit
    try
        [~, ~, ~, xyz1] = sc_splinefit(X, g);
    catch ME
        rethrow(ME);
    end

    %     xyz=[x y z]';
    %     % xyz=sortrows([x y z],[1 2])';
    %     pieces = 15;
    %     s = cumsum([0;sqrt(diff(x(:)).^2 + diff(y(:)).^2 + diff(z(:)).^2)]);
    %     pp1 = splinefit(s,xyz,pieces,0.75);
    %     xyz1 = ppval(pp1,s);
    hold on
    plot3(hAx1, xyz1(:, 1), xyz1(:, 2), xyz1(:, 3), '-', 'linewidth', 4);
    % scatter3(xyz1(:,1),xyz1(:,2),xyz1(:,3)); %,'MarkerEdgeAlpha',.8);

    [~, d] = dsearchn(xyz1, [x, y, z]);

    fitmeanv=xyz1(:,1);
    d(x>max(fitmeanv))=d(x>max(fitmeanv))./100;
    d(x<min(fitmeanv))=d(x<min(fitmeanv))./10;
    d((y-xyz1(:, 2))<0)=d((y-xyz1(:, 2))<0)./100;

    [sortedd, hvgidx] = sort(d, 'descend');

    hvg=g(hvgidx);
    lgu=lgu(hvgidx);
    lgcv=lgcv(hvgidx);
    dropr=dropr(hvgidx);    

    T=table(sortedd,hvgidx,hvg,lgu,lgcv,dropr);
    %assignin("base","T",T);
    %g(idx20)

    disp('scGEAToolbox controls for the variance-mean relationship of gene')
    disp('expression. scGEAToolbox considers three sample statistics of each')
    disp('gene: expression mean⁠, coefficient of variation⁠, and dropout rate⁠.')
    disp('After normalization, it fits a spline function based on piece-wise')
    disp('polynomials to model the relationship among the three statistics, ')
    disp('and calculates the distance between each geneis observed statistics')
    disp('to the fitted 3D spline surface. Genes with larger distances are ')
    disp('ranked higher for feature selection.')        
end


hAx2 = subplot(2,2,2);
x1=X(hvgidx(1),:);
stem(hAx2, 1:length(x1), x1, 'marker', 'none');
xlim(hAx2,[1 size(X,2)]);
title(hAx2, hvg(1));
[titxt] = gui.i_getsubtitle(x1);
subtitle(hAx2, titxt);
xlabel(hAx2,'Cell Index');
ylabel(hAx2,'Expression Level');

dt.UpdateFcn = {@in_myupdatefcn3, g};

gui.gui_waitbar(fw);
hFig.Visible = true;
drawnow;


    function in_ShowProfile(~, ~)
        idx = 1;
        x1 = X(idx, :);
        stem(hAx2, 1:length(x1), x1, 'marker', 'none');
        xlim(hAx2,[1 size(X,2)]);
        title(hAx2, g(idx));
        xlabel(hAx2,'Cell Index')
        ylabel(hAx2,'Expression Level')
    end

    function ChangeAlphaValue(~, ~)
        if h.MarkerFaceAlpha <= 0.05
            h.MarkerFaceAlpha = 1;
        else
            h.MarkerFaceAlpha = h.MarkerFaceAlpha - 0.1;
        end
    end            

    function in_HighlightGenes(~, ~)
        %h.MarkerIndices=idx20;
        idx = zeros(1, length(hvgidx));
        h.BrushData = idx;

        k = gui.i_inputnumk(200, 1, 2000);
        if isempty(k), return; end      
        idx(hvgidx(1:k)) = 1;
        h.BrushData = idx;
        % datatip(h, 'DataIndex', idx20);
        %h2=scatter3(x(idx20),y(idx20),z(idx20),'rx');  % 'filled','MarkerFaceAlpha',.5);
    end

    function ExportTable(~, ~)                
        gui.i_exporttable(T, true, 'Tsplinefitg', 'SplinefitGTable');
    end

    function in_HighlightSelectedGenes(~,~)        
        %Myc, Oct3/4, Sox2, Klf4
        [glist] = gui.i_selectngenes(SingleCellExperiment(X,g),...
            intersect(upper(g),["MYC", "POU5F1", "SOX2", "KLF4"]));
        if ~isempty(glist)            
            [yes,idx]=ismember(glist,g);
            idx=idx(yes);

            %idx=[idx(:); find(nearestidx==1)];
            % idv = zeros(1, length(hvgidx));
            % idv(idx)=1;
            % h.BrushData = idv;
            for k=1:length(idx)
                dt = datatip(h,'DataIndex',idx(k));
            end
        end
    end

    function ExportGeneNames(~, ~)
        ptsSelected = logical(h.BrushData.');
        if ~any(ptsSelected)
            warndlg("No gene is selected.");
            return;
        end
        fprintf('%d genes are selected.\n', sum(ptsSelected));

        gselected=g(ptsSelected);
        [yes,idx]=ismember(gselected,T.hvg);
        Tx=T(idx,:);
        Tx=sortrows(Tx,1,'descend');        
        if ~all(yes), error('Running time error.'); end
        tgenes=Tx.hvg;

        labels = {'Save gene names to variable:'};
        vars = {'g'};
        values = {tgenes};
        export2wsdlg(labels, vars, values, ...
            'Save Data to Workspace');
    end

    function EnrichrHVGs(~, ~)
        ptsSelected = logical(h.BrushData.');
        if ~any(ptsSelected)
            warndlg("No gene is selected.");
            return;
        end
        fprintf('%d genes are selected.\n', sum(ptsSelected));        

        gselected=g(ptsSelected);
        [yes,idx]=ismember(gselected,T.hvg);
        Tx=T(idx,:);
        Tx=sortrows(Tx,1,'descend');        
        if ~all(yes), error('Running time error.'); end
        tgenes=Tx.hvg;
        gui.i_enrichtest(tgenes, g, numel(tgenes));
    end

    function txt = in_myupdatefcn3(src, event_obj, g)
        if isequal(get(src, 'Parent'), hAx1)
            idx = event_obj.DataIndex;
            txt = {g(idx)};
            x1 = X(idx, :);
            stem(hAx2, 1:length(x1), x1, 'marker', 'none');
            xlim(hAx2,[1 size(X,2)]);
            title(hAx2, g(idx));
    
            [titxt] = gui.i_getsubtitle(x1);
            subtitle(hAx2, titxt);
            xlabel(hAx2,'Cell Index');
            ylabel(hAx2,'Expression Level');
        else
            txt = num2str(event_obj.Position(2));
        end
    end

end
