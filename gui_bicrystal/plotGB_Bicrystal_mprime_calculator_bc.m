% Copyright 2013 Max-Planck-Institut f�r Eisenforschung GmbH
function plotGB_Bicrystal_mprime_calculator_bc(listslipA, listslipB)
%% Script used to calculate m' parameter values for all a bicrystal
% listslipA: list of slip systems for grainA from popup menu
% listslipB: list of slip systems for grainB from popup menu
%
% authors: d.mercier@mpie.de / c.zambaldi@mpie.de

%% Set the encapsulation of data
gui = guidata(gcf);

[slip_systA, slip_check_1] = slip_systems(gui.GB.Phase_A, listslipA);
[slip_systB, slip_check_2] = slip_systems(gui.GB.Phase_B, listslipB);

[size_max_slip_sys, slip_systA, slip_systB] = ...
    check_size_slipsystem(slip_systA, slip_systB);

if isempty(find(slip_check_1==0)) && isempty(find(slip_check_2==0)) % Check orthogonality
    
    vectA = zeros(size_max_slip_sys,21,gui.GB.GrainA);
    vectB = zeros(size_max_slip_sys,21,gui.GB.GrainB);
    
    % Grain A
    gui.GB.eulerA = ...
        plotGB_Bicrystal_update_euler(...
        gui.GB.eulerA_ori, gui.handles.getEulangGrA, ...
        gui.handles.pmEulerUnit_str);
    if strcmp(gui.handles.pmEulerUnit_str, 'Radian')
        gui.GB.eulerA = gui.GB.eulerA * 180/pi;
    end
    
    [slip_vecA, gui.flag.error] = ...
        vector_calculations(...
        gui.GB.GrainA, gui.GB.Material_A,...
        gui.GB.Phase_A, gui.GB.eulerA,...
        slip_systA, ...
        gui.stressTensor, gui.flag.error);
    
    ig = gui.GB.GrainA;
    sortbvA(:,:,ig) = sortrows(slip_vecA, -14);                                % Sort slip systems by Generalized Schimd factor
    vectA(:,1:17,ig) = slip_vecA;                                              % Matrix with slip systems, Burgers vectors, index of slips for GrainA...
    vectA(:,18,ig)   = size(slip_systA, 3);
    vectA(:,19,ig)   = sortbvA(:,14,ig);                                       % Highest Generalized Schmid Factor
    
    if ~gui.flag.error
        % Grain B
        gui.GB.eulerB = ...
            plotGB_Bicrystal_update_euler(...
            gui.GB.eulerB_ori, gui.handles.getEulangGrB,...
            gui.handles.pmEulerUnit_str);
        if strcmp(gui.handles.pmEulerUnit_str, 'Radian')
            gui.GB.eulerB = gui.GB.eulerB * 180/pi;
        end
        
        [slip_vecB, gui.flag.error] = ...
            vector_calculations(...
            gui.GB.GrainB, gui.GB.Material_B,...
            gui.GB.Phase_B, gui.GB.eulerB,...
            slip_systB, ...
            gui.stressTensor, gui.flag.error);
        
        ig = gui.GB.GrainB;
        sortbvB(:,:,ig) = sortrows(slip_vecB, -14);                                % Sort slip systems by Generalized Schimd factor
        vectB(:,1:17,ig) = slip_vecB;                                              % Matrix with slip systems, Burgers vectors, index of slips for GrainA...
        vectB(:,18,ig)   = size(slip_systB, 3);
        vectB(:,19,ig)   = sortbvB(:,14,ig);                                       % Highest Generalized Schmid Factor
    end
    
    if ~gui.flag.error
        %% m', residual Burgers vector, N-factor, lambda, and SF(GB) calculations
        sizeA = vectA(1,18,gui.GB.GrainA);
        sizeB = vectB(1,18,gui.GB.GrainB);
        valcase = get(gui.handles.pmchoicecase, 'Value');
        
        if valcase == 1 || valcase == 2 || valcase == 3 || valcase == 4 ||...
                valcase == 5 || valcase == 6 || valcase == 7 || valcase == 37
            % m prime (Luster and Morris)
            gui.calculations.mprime_val_bc = zeros(sizeA, sizeB);
            gui.calculations.mprime_val_bc = ...
                mprime_opt_vectorized(...
                vectA(:,1:3,gui.GB.GrainA), ...
                vectA(:,4:6,gui.GB.GrainA), ...
                vectB(:,1:3,gui.GB.GrainB), ...
                vectB(:,4:6,gui.GB.GrainB));
        end
        if valcase == 8 || valcase == 9 || valcase == 10 || valcase == 11 ||...
                valcase == 12 || valcase == 13 || valcase == 14 ...
                || valcase == 37
            % residual Burgers vector
            gui.calculations.residual_Burgers_vector_val_bc = ...
                zeros(sizeA, sizeB);
            for jj = 1:1:vectB(1,18,gui.GB.GrainB)
                for kk = 1:1:vectA(1,18,gui.GB.GrainA)
                    rbv_bc_val(1) = residual_Burgers_vector(...
                        vectA(kk,7:9,gui.GB.GrainA), ...
                        vectB(jj,7:9,gui.GB.GrainB));
                    rbv_bc_val(2) = residual_Burgers_vector(...
                        vectA(kk,10:12,gui.GB.GrainA), ...
                        vectB(jj,7:9,gui.GB.GrainB));
                    gui.calculations.residual_Burgers_vector_val_bc(kk,jj) = ...
                        min(rbv_bc_val);
                end
            end
        end
        if valcase == 15 || valcase == 16 || valcase == 17 || valcase == 18 || ...
                valcase == 19 || valcase == 20 || valcase == 21 ...
                || valcase == 37
            % N factor (Livingston and Chamlers)
            gui.calculations.n_fact_val_bc = zeros(sizeA, sizeB);
            gui.calculations.n_fact_val_bc = ...
                N_factor_opt_vectorized(...
                vectA(:,1:3,gui.GB.GrainA), ...
                vectA(:,4:6,gui.GB.GrainA), ...
                vectB(:,1:3,gui.GB.GrainB), ...
                vectB(:,4:6,gui.GB.GrainB));
        end
        if valcase == 22 || valcase == 23 || valcase == 24 || valcase == 25 || ...
                valcase == 26 || valcase == 27 || valcase == 28 ...
                || valcase == 37
            % LRB parameter (Shen)
            d_gb(:,1) = (ones(1,size(gui.calculations.vectA, 1)) ...
                * gui.GB_geometry.d_gb(1))';
            d_gb(:,2) = (ones(1,size(gui.calculations.vectA, 1)) ...
                * gui.GB_geometry.d_gb(2))';
            d_gb(:,3) = (ones(1,size(gui.calculations.vectA, 1)) ...
                * gui.GB_geometry.d_gb(3))';
            gui.calculations.LRB_val_bc = zeros(sizeA, sizeB);
            gui.calculations.LRB_val_bc = ...
                LRB_parameter_opt_vectorized(...
                cross(d_gb, ...
                vectA(:,4:6,gui.GB.GrainA)), ...
                vectA(:,4:6,gui.GB.GrainA), ...
                cross(d_gb, ...
                vectB(:,4:6,gui.GB.GrainB)), ...
                vectB(:,4:6,gui.GB.GrainB));
        end
        if valcase == 29 || valcase == 30 || valcase == 31 || valcase == 32 || ...
                valcase == 33 || valcase == 34 || valcase == 35 ...
                || valcase == 37
            % lambda parameter (Werner and Prantl)
            gui.calculations.lambda_val_bc = zeros(sizeA, sizeB);
            for jj = 1:1:vectB(1,18,gui.GB.GrainB)
                for kk = 1:1:vectA(1,18,gui.GB.GrainA)
                    gui.calculations.lambda_val_bc(kk,jj) = ...
                        lambda(...
                        vectA(kk,1:3,gui.GB.GrainA), ...
                        vectA(kk,4:6,gui.GB.GrainA), ...
                        vectB(jj,1:3,gui.GB.GrainB), ...
                        vectB(jj,4:6,gui.GB.GrainB));
                end
            end
        end
        if valcase == 36
            % GB Schmid Factor (Abuzaid)
            gui.calculations.GB_Schmid_Factor_max = ...
                vectA(1,19,gui.GB.GrainA) + ...
                vectB(1,19,gui.GB.GrainB);
        end
        
        res.SFmax_x = sortbvB(1,17,gui.GB.GrainB); % Column 15 --> Indice of slip (Row 1 = max)
        res.SFmax_y = sortbvA(1,17,gui.GB.GrainA); % Column 15 --> Indice of slip (Row 1 = max)
        
        %% Sorted values (max and min)
        switch(valcase)
            case {1, 2, 3, 4, 5, 6, 7} % m prime (Luster and Morris)
                mpr(:,:,gui.GB.GB_Number) = gui.calculations.mprime_val_bc;
                [res.mp_max1, res.x_mp_max1, res.y_mp_max1, ...
                    res.mp_max2, res.x_mp_max2, res.y_mp_max2, ...
                    res.mp_max3, res.x_mp_max3, res.y_mp_max3, ...
                    res.mp_min1, res.x_mp_min1, res.y_mp_min1, ...
                    res.mp_min2, res.x_mp_min2, res.y_mp_min2, ...
                    res.mp_min3, res.x_mp_min3, res.y_mp_min3] = ...
                    sort_values(mpr(:,:,gui.GB.GB_Number));
                res.mp_SFmax = mpr(res.SFmax_x, res.SFmax_y, gui.GB.GB_Number);
                
            case {8, 9, 10, 11, 12, 13, 14} % residual Burgers vector
                rbv(:,:,gui.GB.GB_Number) = ...
                    gui.calculations.residual_Burgers_vector_val_bc;
                [res.rbv_max1, res.x_rbv_max1, res.y_rbv_max1, ...
                    res.rbv_max2, res.x_rbv_max2, res.y_rbv_max2, ...
                    res.rbv_max3, res.x_rbv_max3, res.y_rbv_max3, ...
                    res.rbv_min1, res.x_rbv_min1, res.y_rbv_min1, ...
                    res.rbv_min2, res.x_rbv_min2, res.y_rbv_min2, ...
                    res.rbv_min3, res.x_rbv_min3, res.y_rbv_min3] = ...
                    sort_values(rbv(:,:,gui.GB.GB_Number));
                res.rbv_SFmax = rbv(res.SFmax_x, res.SFmax_y, gui.GB.GB_Number);
                
            case {15, 16, 17, 18, 19, 20, 21} % N factor (Livingston and Chamlers)
                nfact(:,:,gui.GB.GB_Number) = gui.calculations.n_fact_val_bc;
                [res.nfact_max1, res.x_nfact_max1, res.y_nfact_max1, ...
                    res.nfact_max2, res.x_nfact_max2, res.y_nfact_max2, ...
                    res.nfact_max3, res.x_nfact_max3, res.y_nfact_max3, ...
                    res.nfact_min1, res.x_nfact_min1, res.y_nfact_min1, ...
                    res.nfact_min2, res.x_nfact_min2, res.y_nfact_min2, ...
                    res.nfact_min3, res.x_nfact_min3, res.y_nfact_min3] = ...
                    sort_values(nfact(:,:,gui.GB.GB_Number));
                res.nfact_SFmax = ...
                    nfact(res.SFmax_x, res.SFmax_y, gui.GB.GB_Number);
                
            case {22, 23, 24, 25, 26, 27, 28} % LRB parameter (Shen)
                LRBfact(:,:,gui.GB.GB_Number) = gui.calculations.LRB_val_bc;
                [res.LRBfact_max1, res.x_LRBfact_max1, res.y_LRBfact_max1, ...
                    res.LRBfact_max2, res.x_LRBfact_max2, res.y_LRBfact_max2, ...
                    res.LRBfact_max3, res.x_LRBfact_max3, res.y_LRBfact_max3, ...
                    res.LRBfact_min1, res.x_LRBfact_min1, res.y_LRBfact_min1, ...
                    res.LRBfact_min2, res.x_LRBfact_min2, res.y_LRBfact_min2, ...
                    res.LRBfact_min3, res.x_LRBfact_min3, res.y_LRBfact_min3] = ...
                    sort_values(LRBfact(:,:,gui.GB.GB_Number));
                res.LRBfact_SFmax = ...
                    LRBfact(res.SFmax_x, res.SFmax_y, gui.GB.GB_Number);
                
            case {29, 30, 31, 32, 33, 34, 35} % lambda parameter (Werner and Prantl)
                lambdafact(:,:,gui.GB.GB_Number) = gui.calculations.lambda_val_bc;
                [res.lambdafact_max1, res.x_lambdafact_max1, res.y_lambdafact_max1, ...
                    res.lambdafact_max2, res.x_lambdafact_max2, res.y_lambdafact_max2, ...
                    res.lambdafact_max3, res.x_lambdafact_max3, res.y_lambdafact_max3, ...
                    res.lambdafact_min1, res.x_lambdafact_min1, res.y_lambdafact_min1, ...
                    res.lambdafact_min2, res.x_lambdafact_min2, res.y_lambdafact_min2, ...
                    res.lambdafact_min3, res.x_lambdafact_min3, res.y_lambdafact_min3] = ...
                    sort_values(lambdafact(:,:,gui.GB.GB_Number));
                res.lambdafact_SFmax = ...
                    lambdafact(res.SFmax_x, res.SFmax_y, gui.GB.GB_Number);
                
            case {36}
                res.GB_Schmid_Factor_max = ...
                    gui.calculations.GB_Schmid_Factor_max;
        end
        
        gui.GB.results = res;
        gui.flag.error = 0;
        guidata(gcf, gui);
    end
end
end