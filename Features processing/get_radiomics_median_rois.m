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

function get_radiomics_median_rois()
load imParams;
% roi_types={'1vis', '1auto'}; %This parameter is still unused. Later it could replace strings to find in the
%kept_rois loop lines 46 to 53
all_data=dir('Simplified_data/*.mat');
all_data=all_data.';
processed_data=0;

%Remove all_data elements that have already been processed (for testing only)
% example : already_processed_labels=[{'05'};{'06'};{'08'};{'10'};{'11'};{'12_CT'}];
already_processed_labels={'PET';{'05'};{'06'};{'08'}};
already_processed=zeros(1,numel(all_data));
for processed_number=1:numel(already_processed_labels)
    new_processed=arrayfun(@(x) contains(x.name,already_processed_labels{processed_number}),all_data);
    already_processed=already_processed|new_processed;
end
all_data(already_processed==1)=[];
keep imParams all_data processed_data

% Processing features
for data=all_data
    fprintf('Processing data file %s\n',data.name);
    load(strcat('Simplified_data/',data.name,'/New_ROIs/','Majority.mat')); %Loading majority ROI
    load(strcat('Simplified_data/',data.name,'/New_ROIs/','New_from_majority.mat')); %Loading new ROIs
    load(strcat('Simplified_data/',data.name,'/VOL.mat')); %Loading scanner data
    %     load(strcat('Simplified_data/',data.name,'/ROIs.mat')); %Loading original ROIs
    load(strcat('Simplified_data/',data.name,'/ROIs_names.mat')); %Loading ROIs names
    load(strcat('Simplified_data/',data.name,'/spatial_ref.mat')); %Loading spatial ref
    
    if ~isequal(strfind(data.name,'CTscan'),[])
        imParamScan=imParams.CTscan;
    end
    if ~isequal(strfind(data.name,'PTscan'),[])
        imParamScan=imParams.PTscan;
    end
    majority_roi_matrix=matrix_from_indices(new_spatial_ref.ImageSize,majority_roi);
    
    %     majority_roi_matrix=zeros(new_spatial_ref.ImageSize);
    %     majority_roi_matrix=uint8(majority_roi_matrix);
    %     [non_zero_x,non_zero_y,non_zero_z]=ind2sub(new_spatial_ref.ImageSize,majority_roi);
    %     for index=1:numel(non_zero_x)
    %         majority_roi_matrix(non_zero_x(index),non_zero_y(index),non_zero_z(index))=1;
    %     end
    
    %Processing majority features
    roiObj=struct('spatialRef',new_spatial_ref,'data',single(majority_roi_matrix));
    volObj=struct('spatialRef',new_spatial_ref,'data',new_volObj_data);
    
    %Wipe out ram usage a little
    clear new_volObj_data majority_roi_matrix
    
    radiomics=get_radiomics_one_roi(volObj,roiObj,imParamScan);
            save_folder=strcat('features_from_majority/',data.name);
        if ~isdir(save_folder)
            mkdir(save_folder);
        end
    save_name=strcat(save_folder,'/','majority');
    save(save_name,'radiomics');
    
    %Processing new ROIs features
    new_rois_types=fieldnames(kept_ROIs);
    new_rois_types=new_rois_types.';
    new_rois=fieldnames(kept_ROIs);
    for new_rois_index=1:numel(new_rois_types)
        new_roi_type=new_rois_types(new_rois_index);
        new_roi=kept_ROIs.(new_roi_type{1}){1};
        %Retrieving ROI in a matrix form from non-zero indices
        new_roi_matrix=matrix_from_indices(new_spatial_ref.ImageSize,new_roi);
        roiObj.data=new_roi_matrix;
        %Compute radiomics features
        radiomics=get_radiomics_one_roi(volObj,roiObj,imParamScan);
        %Generate name of file to be saved

        save_name=strcat(save_folder,'/',new_roi_type{1});
        
        %save features in proper container
        save(save_name,'radiomics');
    end
    processed_data=processed_data+1;
    fprintf('%i of %i data files were processed\n',processed_data,numel(all_data));
end
end
