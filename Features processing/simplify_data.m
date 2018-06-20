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


%Usage : This script is intended for removinig useless sData complexity before
%features processing
clearvars;
load imParams;
if ~isdir('Simplified_data')
    mkdir('Simplified_data');
end

all_data=dir('DATA/*.mat');
all_data=all_data.';
for data=all_data
    
    %For later save
    save_name=data.name;
    save_name=strcat('Simplified_data/',save_name);
    
    %Load data
    load(strcat('DATA/',data.name));
    all_rois_names={sData{1,2}.scan.contour(1).name};
    for roi_numer=2:numel(sData{1,2}.scan.contour)
        all_rois_names(end+1)={sData{1,2}.scan.contour(roi_numer).name};
    end
    all_rois_names=all_rois_names.';
    
    kept_rois=zeros(numel(sData{1,2}.scan.contour),1);
    
    %Remove ROIs elements that are not to be used
    ROIs_name_tags=[{'1vis'};{'1auto'}]; %These are the strings that ROIs names must contain in order to be kept
    %This simple line replaces the silly ROI selection config file
    for ROIs_name_tag=1:numel(ROIs_name_tags)
        new_kept_ROIs=arrayfun(@(x) contains(x,ROIs_name_tags{ROIs_name_tag}),all_rois_names);
        kept_rois=kept_rois|new_kept_ROIs;
    end
    
    %Here come the indexes of ROIs to keep
    kept_rois=find(kept_rois);
    kept_rois_names={sData{1,2}.scan.contour(kept_rois(1:end)).name};
    
    %Now convert all kept ROIs to the same referential and converts the
    %results to a compressed size
    [~,roiObj] = getROI(sData,kept_rois(1),'2box');
    all_roi_obj={roiObj};
    for kept_roi=2:numel(kept_rois)
        [~,roiObj] = getROI(sData,kept_rois(kept_roi),'2box');
        all_roi_obj(end+1)={roiObj};
    end
    
    [same_ref_rois,new_spatial_ref,new_image_size]=convert_to_same_referential(all_roi_obj);
    
    %Now saving those same referential ROIs as non-zero indexes and not 3D
    %matrices
    all_rois_compressed={find(same_ref_rois(:,:,:,1))};
    for roi_index=2:size(same_ref_rois,4)
        all_rois_compressed(end+1)={find(same_ref_rois(:,:,:,roi_index))};
    end
    
    %We do not need the sizeable rois data anymore so clean the ram
    keep all_rois_compressed sData new_spatial_ref new_image_size imParams save_name kept_rois_names
    %     The second thing we need to save is the underlying scan volume, in
    %     the same referential as the already processed ROIs
    full_spatial_ref=sData{1, 2}.scan.volume.spatialRef;
    full_vol=sData{1, 2}.scan.volume.data;
    
    full_offset_world=[full_spatial_ref.XWorldLimits-new_spatial_ref.XWorldLimits;...
        full_spatial_ref.YWorldLimits-new_spatial_ref.YWorldLimits;...
        full_spatial_ref.ZWorldLimits-new_spatial_ref.ZWorldLimits];
    full_offset_image(1)=-full_offset_world(1,1)/full_spatial_ref.PixelExtentInWorldX;
    full_offset_image(2)=-full_offset_world(2,1)/full_spatial_ref.PixelExtentInWorldY;
    full_offset_image(3)=-full_offset_world(3,1)/full_spatial_ref.PixelExtentInWorldZ;
    
    %Now that the full offset is known, extract partial volume information
    new_volObj_data=full_vol(full_offset_image(2)+1:full_offset_image(2)+new_image_size(1),...
        full_offset_image(1)+1:full_offset_image(1)+new_image_size(2),...
        full_offset_image(3)+1:full_offset_image(3)+new_image_size(3));
    
    %In the case we have PET data, we need to compute the SUV map
    scanType = sData{2}.type;
    imParamScan = imParams.(scanType);
    if strcmp(scanType,'PTscan')
        try
            new_volObj_data = computeSUVmap(single(new_volObj_data),sData{3}(1));
            if isfield(sData{2},'nrrd')
                sData{2}.nrrd.volume.data = computeSUVmap(single(sData{2}.nrrd.volume.data),sData{3}(1));
            end
            if isfield(sData{2},'img')
                sData{2}.img.volume.data = computeSUVmap(single(sData{2}.img.volume.data),sData{3}(1));
            end
        catch
            fprintf('\nERROR COMPUTING SUV MAP (no DICOM headers?)\n')
            return
        end
    end
    
    if ~isdir(save_name)
        mkdir(save_name);
    end
    save(strcat(save_name,'/ROIs'),'all_rois_compressed');
    save(strcat(save_name,'/ROIs_names'),'kept_rois_names');
    save(strcat(save_name,'/spatial_ref'),'new_spatial_ref');
    save(strcat(save_name,'/VOL'),'new_volObj_data');
    
keep imParams;
end
clearvars;
