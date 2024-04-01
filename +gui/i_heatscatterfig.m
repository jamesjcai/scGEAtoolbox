function [hFig] = i_heatscatterfig(sce, cs, posg, csname, parentfig)

if nargin < 5, parentfig = []; end
if nargin < 4 || isempty(csname), csname = "CellScore"; end

hFig = figure('Visible', false);


gui.i_heatscatter(sce.s, cs);

colorbar;
%cb.Label.String =  'Expression Level';


zlabel('Score value')
title(strrep(csname, '_', '\_'));

tb = findall(hFig, 'Tag', 'FigureToolBar'); % get the figure's toolbar handle
uipushtool(tb, 'Separator', 'off');

%tb = uitoolbar(hFig);
pkg.i_addbutton2fig(tb, 'off', @i_saveCrossTable, "export.gif", 'Save cross-table');
pkg.i_addbutton2fig(tb, 'off', {@gui.i_savemainfig, 3}, "powerpoint.gif", 'Save Figure to PowerPoint File...');
pkg.i_addbutton2fig(tb, 'on', @gui.i_pickcolormap, 'plotpicker-compass.gif', 'Pick new color map...');
pkg.i_addbutton2fig(tb, 'on', @gui.i_invertcolor, 'plotpicker-comet.gif', 'Invert colors');
pkg.i_addbutton2fig(tb, 'on', @i_geneheatmapx, 'greenarrowicon.gif', 'Heatmap');
pkg.i_addbutton2fig(tb, 'on', @i_genedotplot, 'greencircleicon.gif', 'Dot plot');
pkg.i_addbutton2fig(tb, 'on', @i_viewgenenames, 'HDF_point.gif', 'Show gene names');
pkg.i_addbutton2fig(tb,'on', @in_stemplot,'icon-mat-blur-on-10.gif','Show stem plot');
%pkg.i_addbutton2fig(tb,'on',@i_viewscatter3,'icon-mat-blur-on-10.gif','Show scatter plot');

try
    if ~isempty(parentfig) && isa(parentfig,'matlab.ui.Figure') 
        [px_new] = gui.i_getchildpos(parentfig, hFig);
        if ~isempty(px_new)
            movegui(hFig, px_new);
        else
            movegui(hFig, 'center');
        end
    else
        movegui(hFig, 'center');
    end
catch
    movegui(hFig, 'center');
end

set(hFig, 'Visible', true);

    function in_stemplot(~,~)
        gui.i_stemscatterfig(sce, cs, posg, csname);
    end

    function i_viewscatter3(~, ~)
        figure;
        s = sce.s;
        x = s(:, 1);
        y = s(:, 2);
        if size(s, 2) >= 3
            z = s(:, 3);
            is2d = false;
        else
            z = zeros(size(x));
            is2d = true;
        end
        scatter3(x, y, z, 10, cs, 'filled');
        if is2d, view(2); end
end

        function i_viewgenenames(~, ~)
            [passed] = i_checkposg;
            if ~passed, return; end

            %         if isempty(posg)
            %             helpdlg('The gene set is empty. This score may not be associated with any gene set.');
            %         else
            idx = matches(sce.g, posg, 'IgnoreCase', true);
            gg = sce.g(idx);
            inputdlg(csname, ...
                '', [10, 50], ...
                {char(gg)});
            %        end
    end

            function i_saveCrossTable(~, ~)
                gui.i_exporttable(table(cs), false, ...
                    char(matlab.lang.makeValidName(string(csname))));
        end
                function i_geneheatmapx(~, ~)
                    [passed] = i_checkposg;
                    if ~passed, return; end

                    [thisc] = gui.i_select1class(sce);
                    if ~isempty(thisc)
                        gui.i_geneheatmap(sce, thisc, posg);
                    end
            end
                    function i_genedotplot(~, ~)
                        [passed] = i_checkposg;
                        if ~passed, return; end
                        [thisc] = gui.i_select1class(sce);
                        [c, cL] = grp2idx(thisc);
                        idx = matches(posg, sce.g, 'IgnoreCase', true);
                        if any(idx)
                            gui.i_dotplot(sce.X, sce.g, c, cL, posg(idx));
                        else
                            helpdlg('No genes in this data set.')
                        end
                end
                        function [passed] = i_checkposg
                            if isempty(posg)
                                passed = false;
                                helpdlg('The gene set is empty. This score may not be associated with any gene set.');
                            else
                                passed = true;
                            end
                    end
                    end