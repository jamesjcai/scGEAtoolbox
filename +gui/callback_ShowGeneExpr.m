function callback_ShowGeneExpr(src,~)

   if ismcc || isdeployed
    makePPTCompilable();
    % https://www.mathworks.com/help/rptgen/ug/compile-a-presentation-program.html
   end
    import mlreportgen.ppt.*;

    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);
    [axx,bxx]=view();
    % if any([axx,bxx]==0), axx=ax; bxx=bx; end
    % gsorted=sort(sce.g);
    
answer = questdlg('Show expression of single or mulitple genes?',...
    'Single/Multiple Genes','Single','Multiple','Cancel','Single');

switch answer
    case 'Single'
        [gsorted]=gui.i_sortgenenames(sce);
        if isempty(gsorted), return; end
        [indx,tf] = listdlg('PromptString',{'Select a gene:','',''},...
            'SelectionMode','single','ListString',gsorted);
        if tf==1
            [methodid]=gui.i_pickscatterstem('Scatter+Stem');
            % methodid=2;      case 'Scatter'
            % 'Stem'           methodid=1;
            if isempty(methodid), return; end
            for k=1:length(indx)
                gui.i_cascadefig(sce,gsorted(indx(k)),axx,bxx,k,methodid);
            end
        end
    case 'Multiple'
        [glist]=gui.i_selectngenes(sce);
        if isempty(glist)
            helpdlg('No gene selected.','');
            return;
        %[gsorted]=gui.i_sortgenenames(sce);
        %if isempty(gsorted), return; end
        %[idx]=gui.i_selmultidlg(gsorted);
        %if isempty(idx), return; end
        %if isscalar(idx) && idx==0
        %   helpdlg('No gene selected.','');
        %    return;
        else
           [y,i]=ismember(upper(glist),upper(sce.g));
           if ~all(y), error('Unspecific running error.'); end
           glist=sce.g(i);
           
        %[~,i]=ismember(gsorted(idx),sce.g);
        x=sum(sce.X(i,:),1);
        if length(i)==1
           g=sce.g(i);
        elseif length(i)>1
            answer2=questdlg('Intersection (AND) or Union (OR)',...
                '','Individually',...
                'Intersection (AND)',...
                'Union (OR)',...                
                'Individually');
            switch answer2
                case 'Union (OR)'
                    g=sprintf("%s | ",glist); 
                case 'Intersection (AND)'
                    g=sprintf("%s & ",glist);
                    ix=sum(sce.X(i,:)>0,1)==length(i);
                    if ~any(ix)
                        helpdlg('No cells expressing all selected genes.','');
                        return;
                    end
                    x=x.*ix;
                case 'Individually'
%                     methodx=questdlg('Plot type:','','Scatter','Stem','Scatter+Stem','Scatter+Stem');
%                     switch methodx
%                         case 'Scatter'
%                             methodid=2;
%                         case 'Stem'
%                             methodid=1;
%                         case 'Scatter+Stem'
%                             methodid=5;
%                         otherwise
%                             methodid=5;
%                     end
                    [methodid]=gui.i_pickscatterstem('Scatter+Stem');
                    if isempty(methodid), return; end
                    
                    answer=questdlg('Output to PowerPoint?');
                    switch answer
                        case 'Yes'
                            needpptx=true;
                        case 'No'
                            needpptx=false;
                        otherwise
                            return;
                    end

                    images={};
                    for k=1:length(glist)
                        f=gui.i_cascadefig(sce,glist(k),axx,bxx,k,methodid);
                        % i_showcascade(sce,gsorted(idx(k)),axx,bxx,k);
                        if needpptx
                            img1=[tempname,'.png'];
                            images = [images {img1}];
                            saveas(f,img1);
                        end
                    end
                    if needpptx, gui.i_save2pptx(images); end
                    return;
                otherwise
                    return;
            end   % end of AND / OR / Individual
            g=extractBefore(g,strlength(g)-2);
        end
            f=figure('visible','off');
            [h1]=sc_scattermarker(x,g,sce.s,g,5);
            title(g);
            view(h1,axx,bxx);
            
            movegui(f,'center');
            set(f,'visible','on');  
        end
    case 'Cancel'
        % helpdlg('Action cancelled.','');
        return;
end

end

% function i_showcascade(sce,g,axx,bxx,k)
%         f = figure('visible','off');
%         [h1]=sc_scattermarker(sce.X,sce.g,sce.s,g,5);
%         view(h1,axx,bxx);
%         % movegui(f,'center');        
%         P = get(f,'Position');
%         set(f,'Position',[P(1)-20*k P(2)-20*k P(3) P(4)]);
%         set(f,'visible','on');
% end                       



% function [gsorted]=i_sortg(sce)
%         gsorted=[];
%         answer2 = questdlg('How to sort gene names?','Sort by',...
%             'Alphabetic','Expression Mean','Dropoff Rate','Alphabetic');
%         switch answer2
%             case 'Alphabetic'
%                 gsorted=sort(sce.g);
%             case 'Expression Mean'
%                 [T]=sc_genestats(sce.X,sce.g);
%                 [~,idx]=sort(T.Dropout_rate);
%                 gsorted=sce.g(idx);                
%             case 'Dropoff Rate'
%                 [T]=sc_genestats(sce.X,sce.g);
%                 [~,idx]=sort(T.Dropout_rate);
%                 gsorted=sce.g(idx);
%             otherwise
%                 return;
%         end
% end
