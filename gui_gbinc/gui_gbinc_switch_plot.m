% Copyright 2013 Max-Planck-Institut f�r Eisenforschung GmbH
function gui_gbinc_switch_plot(image2plot)
%% Function used to switch plots
% image2plot: 1 for before polishing and 2 after polishing

% authors: d.mercier@mpie.de / c.zambaldi@mpie.de

gui = guidata(gcf);

if image2plot == 1
    pathname = gui.config_map.pathname_image_before_polishing;
    filename = gui.config_map.filename_image_before_polishing;
    set(gui.handles.switch_plot.pb1, 'BackgroundColor', [0.2 0.8 0]);
    set(gui.handles.switch_plot.pb2, 'BackgroundColor', [0.9 0.9 0.9]);
elseif image2plot == 2
    pathname = gui.config_map.pathname_image_after_polishing;
    filename = gui.config_map.filename_image_after_polishing;
    set(gui.handles.switch_plot.pb1, 'BackgroundColor', [0.9 0.9 0.9]);
    set(gui.handles.switch_plot.pb2, 'BackgroundColor', [0.2 0.8 0]);
end

gui_gbinc_load_image(pathname, filename);

end