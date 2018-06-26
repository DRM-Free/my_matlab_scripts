%MIT License

%Copyright (c) 2018 Anaël Leinert

%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:

%The above copyright notice and this permission notice shall be included in all
%copies or substantial portions of the Software

function volume_distribution=compute_volume_distribution()
close all
all_CT_volumes_files=dir('Simplified_data/*CTscan.mat/VOL.mat');
all_PET_volumes_files=dir('Simplified_data/*PTscan.mat/VOL.mat');
modality_types=struct('CT',all_CT_volumes_files,'PET',all_PET_volumes_files);
modalities=fieldnames(modality_types);

for modality=1:numel(modalities)
    all_volumes_files=modality_types.(modalities{modality});
    all_volumes_files=all_volumes_files.';
    max_relative_variations=[];
    median_volumes=[];
    cov_volumes=[];
    std_volumes=[];
    max_volume_majority_variations=[];
    for volume_file_index=1:numel(all_volumes_files)
        ROIs_file=strcat(all_volumes_files(volume_file_index).folder,'/','ROIs.mat');
        load(strcat(all_volumes_files(volume_file_index).folder,'/',all_volumes_files(volume_file_index).name));
        load(strcat(all_volumes_files(volume_file_index).folder,'/New_ROIs/Majority.mat'));
        load(ROIs_file);
        %Getting majority ROI as well
        %         load(strcat(all_volumes_files(volume_file_index).folder,'/New_ROIs/Majority.mat'));
        %restore all the ROIs matrices
        all_rois_volumes=[];
        vol_sz=size(new_volObj_data);
        %         majority_volume=numel(find(matrix_from_indices(vol_sz,majority_roi)));
        clear new_volObj_data
        majority_volume=numel(majority_roi);
        max_relative_variation=0;
        %         max_volume_majority_variation=0;
        for roi_compressed = all_rois_compressed
            cur_vol=numel(roi_compressed{1});
            all_rois_volumes(end+1)=cur_vol;
            max_relative_variation=max(max_relative_variation,abs(cur_vol-majority_volume)/majority_volume);
            %             max_relative_variations=
            %             max_volume_majority_variation=max(max_volume_majority_variation,abs((cur_vol-majority_volume)/majority_volume));
        end
        %         max_volume_majority_variations(end+1)=max_volume_majority_variation;
        median_volumes(end+1)=majority_volume;
        cov_volumes(end+1)=coef_v(all_rois_volumes);
        max_relative_variations(end+1)=max_relative_variation;
        
        %Save volumes distribution images
        %         close all
        %         figure('name','volumes histogram','visible','off');
        %         histogram(all_rois_volumes,10);
        %         title('Original ROIs volumes Histogram');
        %         figHandles = findobj('Type', 'figure');
        %         lesion_folder=all_volumes_files(volume_file_index).folder;
        %         lesion_folder=strsplit(lesion_folder,'/');
        %         lesion_folder=lesion_folder{end};
        %         if ~isdir(strcat('../Docs/Master thesis elements/ROIs vol variability/',modalities{modality}))
        %             mkdir(strcat('../Docs/Master thesis elements/ROIs vol variability/',modalities{modality}));
        %         end
        
        %         saveas(figHandles(1),strcat('../Docs/Master thesis elements/ROIs vol variability/',modalities{modality},'/',lesion_folder,' vol_distrib.png'));
        %     figure('name','normal distribution histogram');
        %     norm_dis = normrnd(mean(all_rois_volumes),std(all_rois_volumes),100,1);
        %     histogram(norm_dis,10)
        %     title('Same mean/std normal distribution Histogram');
    end
%     close all
    col_nb=numel(all_volumes_files);
    if exist('green_vec')~=1
        green_vec=rand(1,col_nb);
    end
    red_vec=[0:1/col_nb:1];
    blue_vec=[1:-1/col_nb:0];
    colors=[red_vec(1:col_nb);green_vec;blue_vec(1:col_nb)];
%     figure('visible','off');
figure();
    scatter(max_relative_variations,median_volumes,[],colors.','filled');
    title(strcat(modalities{modality}, ' modality volumes max relative variations scatter plot'));
    xlabel('max relative variations');
    ylabel('ROIs volumes median');
    
    %scatter(max_volume_majority_variations,median_volumes,[],colors.','filled');
    %     title(strcat(modalities{modality}, ' modality volumes median(COV) scatter plot'));
    %     xlabel('ROIs volumes COV');
    %     ylabel('ROIs volumes median');
end
% figHandles = findobj('Type', 'figure');
% saveas(figHandles(1),'PET COV median scatter plot.png')
% saveas(figHandles(2),'CT COV median scatter plot.png')
end