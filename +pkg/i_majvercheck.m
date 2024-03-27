function [needupdate, v1local, v2web] = i_majvercheck

% major version update check
needupdate = false;

try    
    % fid = fopen(xfilelocal, 'r');
    % C = textscan(fid, '%s', 'delimiter', '\n');
    % fclose(fid);
    % a = C{1};    
    % x = a(contains(a, '<param.version>'));
    % a1 = strfind(x, '<param.version>');
    % a2 = strfind(x, '</param.version>');
    % v1local = extractBetween(x, a1{1}+length('<param.version>'), a2{1}-1)

    v1local = {pkg.i_getversionnum};

    xfile = 'scGEAToolbox.prj';
    url = sprintf('https://raw.githubusercontent.com/jamesjcai/scGEAToolbox/main/%s',xfile);
    a = webread(url);
    a = strsplit(a, '\n')';
    x = a(contains(a, '<param.version>'));
    a1 = strfind(x, '<param.version>');
    a2 = strfind(x, '</param.version>');
    v2web = extractBetween(x, a1{1}+length('<param.version>'), a2{1}-1);

    %{
    a=textread('scGEAToolbox.prj','%s');
    x=a(contains(a,'<param.version>'));
    a1=strfind(x,'<param.version>');
    a2=strfind(x,'</param.version>');
    v1=extractBetween(x,a1{1}+15,a2{1}-1);


    url='https://raw.githubusercontent.com/jamesjcai/scGEAToolbox/master/scGEAToolbox.prj';
    a=webread(url);
    a=strsplit(a,'\n')';
    x=a(contains(a,'<param.version>'));
    a1=strfind(x,'<param.version>');
    a2=strfind(x,'</param.version>');
    v2=extractBetween(x,a1{1}+15,a2{1}-1);
    %}
    needupdate = ~isequal(v1local, v2web);
catch ME
    disp(ME.message);
end
if nargout > 1, v1local = v1local{1}; end
if nargout > 2, v2web = v2web{1}; end

end
