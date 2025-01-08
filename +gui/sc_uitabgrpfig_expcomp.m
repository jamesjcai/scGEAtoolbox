function sc_uitabgrpfig_expcomp(sce, glist, parentfig, cazcel, thisc)

if nargin < 4, cazcel = []; end
if nargin < 3, parentfig = []; end
% if ~isempty(parentfig) && isa(parentfig,'matlab.ui.Figure') 
%     p = parentfig.Position;
%     cx = [p(1)+p(3)/2 p(2)+p(4)/2];
% end

% https://www.mathworks.com/help/rptgen/ug/compile-a-presentation-program.html
if ismcc || isdeployed, makePPTCompilable(); end
import mlreportgen.ppt.*;

pw1 = fileparts(mfilename('fullpath'));
pth = fullfile(pw1, '..', 'resources', 'Misc', 'myTemplate.pptx');


hx=gui.myFigure;
hFig=hx.FigureHandle;
hFig.Position(3) = hFig.Position(3) * 1.8;

% if ~isempty(parentfig) && isa(parentfig,'matlab.ui.Figure') 
%     px = hFig.Position;
%     px_new = [cx(1)-px(3)/2 cx(2)-px(4)/2];
% 
%     % if px_new(1)<0
%     %     ss = get(0, 'screensize');
%     %     px_new(1)=px_new(1)-ss(4); %ss(3); 
%     % end
% else
%     px_new = [];
% end

n = length(glist);
% a = getpref('scgeatoolbox', 'prefcolormapname', 'autumn');

tabgp = uitabgroup();
tab = cell(n,1);
ax0 = cell(n,1);
ax = cell(n,2);

idx = 1;
focalg = glist(idx);

[c, cL] = grp2idx(thisc);
sce1 = sce.selectcells(c == 1);
sce2 = sce.selectcells(c == 2);

for k=1:n
    c1 = sce1.X(sce1.g == glist(k), :);
    if issparse(c1), c1 = full(c1); end
    c2 = sce2.X(sce2.g == glist(k), :);
    if issparse(c2), c2 = full(c2); end
 
    tab{k} = uitab(tabgp, 'Title', sprintf('%s',glist(k)));
    
    %{
    t = tiledlayout(1,2,'Parent',tab{k});
    ax1 = nexttile;
    hpl{k,1} = scatter3(sce.s(:,1), sce.s(:,2), sce.s(:,3), 5, c, 'filled','Parent', ax1);
    ax2 = nexttile;
    hpl{k,2} = scatter(sce.s(:,1), sce.s(:,2), 5, c, 'filled','Parent', ax2);
    %}
    
    ax0{k} = axes('parent',tab{k});
    ax{k,1} = subplot(1,2,1);

    scatter(sce1.s(:,1), sce1.s(:,2), 5, c1, 'filled');
    stem3(sce1.s(:,1), sce1.s(:,2), c1, 'marker', 'none', 'color', 'm');
    hold on;
    scatter3(sce1.s(:,1), sce1.s(:,2), zeros(size(sce1.s(:,2))), 5, c1, 'filled');
    z1 = zlim(ax{k,1});
    z1 = z1(2);
    

    ax{k,2} = subplot(1,2,2);
    scatter(sce2.s(:,1), sce2.s(:,2), 5, c2, 'filled');
    stem3(sce2.s(:,1), sce2.s(:,2), c2, 'marker', 'none', 'color', 'm');
    hold on;
    scatter3(sce2.s(:,1), sce2.s(:,2), zeros(size(sce2.s(:,2))), 5, c2, 'filled');
    z2 = zlim(ax{k,2});
    z2 = z2(2);

    zz = max([z1 z2]);
    zlim(ax{k,1},[0 zz]);
    zlim(ax{k,2},[0 zz]);

    
    title(ax{k,1}, glist(k)+" "+string(cL{1}));
    subtitle(ax{k,1}, gui.i_getsubtitle(c1));
    title(ax{k,2}, glist(k)+" "+string(cL{2}));
    subtitle(ax{k,2}, gui.i_getsubtitle(c2));
end
  
tabgp.SelectionChangedFcn=@displaySelection;

% hx.addCustomButton('off', [], "IMG00107.GIF", " ");
% hx.addCustomButton('off', @i_linksubplots, 'plottypectl-rlocusplot.gif', 'Link subplots');
hx.addCustomButton('off',  @i_genecards, 'fvtool_fdalinkbutton.gif', 'GeneCards...');
%hx.addCustomButton('off', @i_RescaleExpr, 'IMG00074.GIF', 'Rescale expression level [log2(x+1)]');
%hx.addCustomButton('off', @i_ResetExpr, 'plotpicker-geobubble2.gif', 'Reset expression level');
hx.addCustomButton('off', @in_savedata, "powerpointx.gif", 'Save Gene List...');
%hx.addCustomButton('off', @i_savemainfig, "powerpoint.gif", 'Save Figure to PowerPoint File...');
%hx.addCustomButton('off', @i_savemainfigx, "xpowerpoint.gif", 'Save Figure as Graphic File...');

hx.show(parentfig);


    function in_savedata(~,~)
        gui.i_exporttable(table(glist), true, ...
            'Tmarkerlist','MarkerListTable');    
    end


    function i_savemainfigx(~,~)
        answer = questdlg('Select Sub-plot to export:','', ...
            'Left','Right','Cancel','Left');
        switch answer
            case 'Left'
                p = 1;
            case 'Right'
                p = 2;
            otherwise
                return;
        end

        [~,idx]=ismember(focalg, glist);     
        filter = {'*.jpg'; '*.png'; '*.tif'; '*.pdf'; '*.eps'};
        [filename, filepath] = uiputfile(filter,'Save Feature Plot', ...
            sprintf('FeaturePlot_%s', focalg));
        if ischar(filename)
            exportgraphics(ax{idx,p}, [filepath, filename]);
        end
    end

    function i_savemainfig(~,~)
        answer = questdlg('Export to PowerPoint?');
        if ~strcmp(answer,'Yes'), return; end

        fw=gui.gui_waitbar_adv;
            OUTppt = [tempname, '.pptx'];
            ppt = Presentation(OUTppt, pth);
            open(ppt);
            images=cell(n,1);
            warning off
        for kx=1:n
            gui.gui_waitbar_adv(fw,kx./n,"Processing "+glist(kx)+" ...");
            images{kx} = [tempname, '.png'];
            tabgp.SelectedTab=tab{kx};
            saveas(tab{kx},images{kx});
            slide3 = add(ppt, 'Small Title and Content');
            replace(slide3, 'Title', glist(kx));
            replace(slide3, 'Content', Picture(images{kx}));        
        end
            close(ppt);
            rptview(ppt);      
            gui.gui_waitbar_adv(fw);
    end

    % function i_linksubplots(~,~)        
    %     hlink = linkprop([ax{idx,1},ax{idx,2}],{'CameraPosition','CameraUpVector'});
    % end

    function displaySelection(~,event)
        t = event.NewValue;
        txt = t.Title;
        % disp("Viewing gene " + txt);
        [~,idx]=ismember(txt,glist);
        focalg = glist(idx);
    end

    function i_genecards(~, ~)
        web(sprintf('https://www.genecards.org/cgi-bin/carddisp.pl?gene=%s', focalg),'-new');
    end

end



    function i_PickColorMap(~, ~, c)
        list = {'parula', 'turbo', 'hsv', 'hot', 'cool', 'spring', ...
            'summer', 'autumn (default)', ...
            'winter', 'jet'};
        [indx, tf] = listdlg('ListString', list, 'SelectionMode', 'single', ...
            'PromptString', 'Select a colormap:', 'ListSize', [220, 300]);
        if tf == 1
            a = list{indx};
            if strcmp(a, 'autumn (default)')
                a = 'autumn';
            end
            gui.i_setautumncolor(c, a);
            setpref('scgeatoolbox', 'prefcolormapname', a);
        end
    end

