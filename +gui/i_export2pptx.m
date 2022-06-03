function i_export2pptx(F,glist)

import mlreportgen.ppt.*;
answer=questdlg('Export to PowerPoint?');
switch answer
    case 'Yes'
        if ismcc || isdeployed
            makePPTCompilable();
        end
        
        N=length(F);
        images=cell(N,1);
        
        OUTppt=[tempname,'.pptx'];
        ppt = Presentation(OUTppt);
        open(ppt);
        
        for k=1:N
            if isvalid(F{k})
                images{k} = [tempname,'.png'];
                saveas(F{k},images{k});
                %images{k} = [tempname,'.emf'];
                %saveas(F{k},images{k},'meta');
                slide3 = add(ppt,'Title and Content');
                replace(slide3,'Title',glist(k));
                replace(slide3,'Content',Picture(images{k}));
            end
        end
        close(ppt);
        rptview(ppt);
        len = length(images);
        for i = 1:len
            delete(images{i});
        end        
end
end