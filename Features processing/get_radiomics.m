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

function get_radiomics()
load imParams;


all_data=dir('Simplified_data/*.mat');
all_data=all_data.';
processed_data=0;

%Remove all_data elements that have already been processed, or are which
%computation is not desired yet
already_processed_labels=[{'PET'}];
already_processed=zeros(1,numel(all_data));

for processed_number=1:numel(already_processed_labels)
    new_processed=arrayfun(@(x) contains(x.name,already_processed_labels{processed_number}),all_data);
    already_processed=already_processed|new_processed;
end
all_data(already_processed==1)=[];

keep imParams all_data processed_data

for data=all_data
    if ~isequal(strfind(data.name,'CTscan'),[])
        imParamScan=imParams.CTscan;
    end
    if ~isequal(strfind(data.name,'PTscan'),[])
        imParamScan=imParams.PTscan;
    end
    
    fprintf('Processing data file %s\n',data.name);
    %Loading original ROIs
    load(strcat('Simplified_data/',data.name,'/ROIs.mat'));
    load(strcat('Simplified_data/',data.name,'/VOL.mat')); %Loading scanner data
    load(strcat('Simplified_data/',data.name,'/ROIs_names.mat')); %Loading ROIs names
    load(strcat('Simplified_data/',data.name,'/spatial_ref.mat')); %Loading spatial ref
    
    roiObj=struct('spatialRef',new_spatial_ref,'data',[]);
    volObj=struct('spatialRef',new_spatial_ref,'data',new_volObj_data);
    
    save_folder=strcat('features_from_original/',data.name);
    if ~isdir(save_folder)
        mkdir(save_folder);
    end
    for original_roi_index=1:numel(all_rois_compressed)
        new_roi=all_rois_compressed{original_roi_index};
        
        %Retrieving ROI in a matrix form from non-zero indices
        new_roi_matrix=matrix_from_indices(new_spatial_ref.ImageSize,new_roi);
        cur_roi_obj=roiObj;
        cur_roi_obj.data=new_roi_matrix;
        %Compute radiomics features
        radiomics=get_radiomics_one_roi(volObj,cur_roi_obj,imParamScan);
        
        %Generate name of file to be saved
        save_name=strcat(save_folder,'/',kept_rois_names{original_roi_index});
        
        %save features in proper container
        save(save_name,'radiomics');
    end
    processed_data=processed_data+1;
end
fprintf('%i of %i data files were processed\n',processed_data,numel(all_data));
end
