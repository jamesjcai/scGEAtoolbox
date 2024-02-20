function py_writeh5ad(sce, fname, wkdir, isdebug)

if nargin < 2, fname = tempname + ".h5ad"; end
extprogname = 'py_writeh5ad';
if nargin<3 || isempty(wkdir)
    preftagname = 'externalwrkpath';
    [wkdir] = gui.gui_setprgmwkdir(extprogname, preftagname);
    if isempty(wkdir), return; end
end
if nargin < 4, isdebug = true; end

oldpth = pwd();
pw1 = fileparts(mfilename('fullpath'));
codepth = fullfile(pw1, 'external', extprogname);
if isempty(wkdir) || ~isfolder(wkdir)
    cd(codepth);
else
    disp('Using working directory provided.');
    cd(wkdir);
end
fw = gui.gui_waitbar([], [], 'Checking Python environment...');

x = pyenv;
try
    pkg.i_add_conda_python_path;
catch

end

codefullpath = fullfile(codepth,'require.py');
cmdlinestr = sprintf('"%s" "%s"', x.Executable, codefullpath);
disp(cmdlinestr)
[status, cmdout] = system(cmdlinestr, '-echo');
if status ~= 0
    cd(oldpth);
    if isvalid(fw)
        gui.gui_waitbar(fw, true);
    end
    error(cmdout);
end


%prgfoldername = 'py_writeh5ad';
%[pyok, wrkpth, x] = run.pycommon(prgfoldername);
%if ~pyok, return; end
tmpfilelist = {'X.mat', 'g.csv', 'c.csv'};
if ~isdebug, pkg.i_deletefiles(tmpfilelist); end

X = full(sce.X);
save('X.mat','-v7.3',"X");
g = sce.g;
writetable(table(g),'g.csv','WriteVariableNames',false);
% barcode = sce.c_cell_id;
sce.c_cell_id = matlab.lang.makeUniqueStrings(sce.c_cell_id);
T = pkg.makeattributestable(sce);
writetable(T,'c.csv');
disp('Files written.');

if isvalid(fw)
    gui.gui_waitbar(fw, [], [], 'Checking Python environment is complete');
    pause(0.5);
    gui.gui_waitbar(fw, [], [], 'Running Py_WriteH5AD...');
end

codefullpath = fullfile(codepth,'script.py');
cmdlinestr = sprintf('"%s" "%s"', x.Executable, codefullpath);
disp(cmdlinestr)
[status] = system(cmdlinestr, '-echo');

if status == 0 && isvalid(fw)
    gui.gui_waitbar(fw, [], 'Job is complete.');
end

if ~isdebug, pkg.i_deletefiles(tmpfilelist); end
cd(oldpth);
end