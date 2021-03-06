% Copyright 2013 Max-Planck-Institut f�r Eisenforschung GmbH
function menuFEM_mesh = preCPFE_custom_menu(label)
%% Function used to add a custom menu item in the GUI menubar
% label: String used as a label in the menu
% authors: d.mercier@mpie.de / c.zambaldi@mpie.de

if nargin < 1
    label = 'FEM';
end

menuFEM_mesh = uimenu('Label', label);

custom_menu_help(menuFEM_mesh);

uimenu(menuFEM_mesh, 'Label', 'Load CPFEM config. file', ...
   'Callback', 'preCPFE_select_config_CPFEM; preCPFE_config_CPFEM_updated;', ...
   'Separator','on');

uimenu(menuFEM_mesh, 'Label', 'Edit CPFEM config. file', ...
    'Callback', 'preCPFE_config_CPFEM_edit');

% uimenu(menuFEM_mesh, 'Label', 'Load default indenter', ...
%     'Callback', 'preCPFE_load_indenter_topo_AFM(1)',...
%     'Separator','on');
% uimenu(menuFEM_mesh, 'Label', 'Load indenter topography (AFM data)', ...
%     'Callback', 'preCPFE_load_indenter_topo_AFM(2)');
%--------------------------------------------------------------------------
uimenu(menuFEM_mesh, 'Label', 'Load CPFEM material config. file', ...
    'Callback', 'preCPFE_load_YAML_material_file',...
    'Separator','on');

uimenu(menuFEM_mesh, 'Label', 'Edit YAML material config. file', ...
    'Callback', 'preCPFE_edit_YAML_material_file');

end