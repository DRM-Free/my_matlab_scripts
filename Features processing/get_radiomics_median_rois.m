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

%Remove all_data elements that have already been processed
% example : already_processed_labels=[{'05'};{'06'};{'08'};{'10'};{'11'};{'12_CT'}];
already_processed_labels={};
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
    load(strcat('Simplified_data/',data.name,'/New_ROIs/','New_from_majority_2.mat')); %Loading new ROIs
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
    %just make a proper info container for majority ROI (move to compute_median_rois later)
    majority_gen_type='majority';
    majority_gen_data='none';
    majority_table=table;
    majority_table.segment={majority_roi};
    majority_table.gen_type=majority_gen_type;
    majority_table.gen_data=majority_gen_data;
    
    %Processing majority features
    roiObj=struct('spatialRef',new_spatial_ref,'data',single(majority_roi_matrix));
    volObj=struct('spatialRef',new_spatial_ref,'data',new_volObj_data);
    
    %Clear memory usage a little
    clear new_volObj_data majority_roi_matrix
    
    radiomics_values=get_radiomics_one_roi(volObj,roiObj,imParamScan);
%     radiomics_values=[]; %For testing
    
    save_folder=strcat('features_from_majority_2/',data.name);
    if ~isdir(save_folder)
        mkdir(save_folder);
    end
    save_name=strcat(save_folder,'/','majority');
    radiomics=struct('radiomics_values',radiomics_values,'ROI_info',majority_table);
    save(save_name,'radiomics');
    clear majority_gen_data majority_gen_type majority_roi majority_table radiomics_values
    %Processing new ROIs features
    
    for selected_ROI_index=1:size(selected_rois,1)
        new_roi=selected_rois{selected_ROI_index,'segment'}{1};
        ROI_info=selected_rois(selected_ROI_index,:);
        %Retrieving ROI in a matrix form from non-zero indices
        new_roi_matrix=matrix_from_indices(new_spatial_ref.ImageSize,new_roi);
        roiObj.data=new_roi_matrix;
        %Compute radiomics features
        radiomics_values=get_radiomics_one_roi(volObj,roiObj,imParamScan);
        %Generate name of file to be saved
        roi_vol=numel(new_roi);
        save_name=strcat(save_folder,'/ROI_vol_',num2str(roi_vol));
        
        radiomics=struct('ROI_info',ROI_info,'radiomics_values',radiomics_values);
        %save features in proper container
        save(save_name,'radiomics');
    end
    processed_data=processed_data+1;
    fprintf('%i of %i data files were processed\n',processed_data,numel(all_data));
end
end