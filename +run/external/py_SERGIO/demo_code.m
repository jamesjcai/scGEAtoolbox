% cd 'D:\GitHub\scGEAToolbox\+run\external\py_SERGIO'

% Step 1: Draw GRN
gui.graph_gui

% Step 2: Save GRN as A

% Setp 3: Write A to regs.txt and targets.txt
pkg_e_writesergiogrn(A)

% Step 4: Run SERGIO
X=run.py_SERGIO(A,1000);

