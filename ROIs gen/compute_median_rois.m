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

function compute_median_rois()
all_data=dir('Simplified_data/*.mat');
all_data=all_data.';

%Remove all_data elements that have already been processed (for testing only)
already_processed_labels={'05'};
% already_processed_labels=[];
%11_PET keeps throwing warnings. Are those ROIs too small ?
already_processed=zeros(1,numel(all_data));

for processed_number=1:numel(already_processed_labels)
    new_processed=arrayfun(@(x) contains(x.name,already_processed_labels{processed_number}),all_data);
    already_processed=already_processed|new_processed;
end
all_data(already_processed==1)=[];


for data=all_data
    fprintf('Processing data file %s\n',data.name);
    if ~isequal(strfind(data.name,'CTscan'),[])
       modality='CT';
           range=9;
    else
        modality='PET';
            range=9;
    end
    %Loading ROIs (which are already in the same referential, but still in a reduced form, thus we need to reconstruct full matrix)
    load(strcat('Simplified_data/',data.name,'/ROIs.mat'));
    load(strcat('Simplified_data/',data.name,'/spatial_ref.mat'));
    
    all_rois=zeros([new_spatial_ref.ImageSize(1),new_spatial_ref.ImageSize(2),new_spatial_ref.ImageSize(3),numel(all_rois_compressed)]);;
    all_rois=uint8(all_rois);
    for roi_index=1:numel(all_rois_compressed)
        [non_zero_x,non_zero_y,non_zero_z]=ind2sub(new_spatial_ref.ImageSize,all_rois_compressed{roi_index});
        for index=1:numel(non_zero_x)
            all_rois(non_zero_x(index),non_zero_y(index),non_zero_z(index),roi_index)=1;
        end
    end
    
    majority_roi=zeros(size(all_rois(:,:,:,1)));
    %Let's take a majority vote for median ROI computation (in case of perfect split, keep
    %current voxel in resulting ROI)
    for x=1:size(majority_roi,1)
        for y=1:size(majority_roi,2)
            for z=1:size(majority_roi,3)
                if mean(all_rois(x,y,z,:))>=0.5
                    majority_roi(x,y,z)=1;
                end
            end
        end
    end
    
    majority_roiObj=struct('spatialRef',new_spatial_ref,'data',majority_roi);
    
    %Simple ROI gen parameters
    nIter=20;
    world_extent=[new_spatial_ref.PixelExtentInWorldX,new_spatial_ref.PixelExtentInWorldY,new_spatial_ref.PixelExtentInWorldZ];
    %Now compute new ROIs from majority ROI
    [newROIs,shrink_thresholds,expand_thresholds]=genROIs_simple(majority_roiObj,world_extent,range,nIter);
    majority_volume=numel(find(majority_roi));
%     visualize_all_ROIs(newROIs);
    selected_rois=select_rois(modality, majority_volume,newROIs,shrink_thresholds,expand_thresholds,nIter);
%     [~,kept_ROIs]=dice_from_simple(newROIs,majority_roi,shrink_thresholds,expand_thresholds,nIter);
    
    %Saving new ROIs and majority ROIs as an array of non-zero indexes
    majority_roi=find(majority_roi);
    if ~isdir(strcat('Simplified_data/',data.name,'/New_ROIs'))
        mkdir(strcat('Simplified_data/',data.name,'/New_ROIs'));
    end
    
    save_name=strcat('Simplified_data/',data.name,'/New_ROIs');
    save(strcat(save_name,'/Majority'),'majority_roi');
    save(strcat(save_name,'/New_from_majority_2'),'selected_rois');
    
end
end
