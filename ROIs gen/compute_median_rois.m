function compute_median_rois()
all_data=dir('DATA/*.mat');
all_data=all_data.';
for data=all_data
    fprintf('Processing data file %s\n',data.name);
    load(strcat('DATA/',data.name));
    world_extent=[sData{1,2}.scan.volume.spatialRef.PixelExtentInWorldX,sData{1,2}.scan.volume.spatialRef.PixelExtentInWorldY,sData{1, 2}.scan.volume.spatialRef.PixelExtentInWorldZ];
    rois_one_patient=sData{1, 2}.scan.contour;
    kept_rois=[];
    for roi_number=1:numel(rois_one_patient)
        roi_name=rois_one_patient(roi_number).name;
        visPos = strfind(roi_name,'1vis');
        autoPos = strfind(roi_name,'1auto');
        if ~(isequal(autoPos,[])&isequal(visPos,[]))
            kept_rois(end+1)=roi_number;
        end
    end
    
    all_roiObj=[];
    for kept_roi=kept_rois
        [~,roiObj] = getROI(sData,kept_roi,'2box');
        try
            all_roiObj=cat(4,all_roiObj,roiObj.data);
        catch
            all_roiObj=roiObj.data;
        end
    end
    majority_roi=zeros(size(all_roiObj(:,:,:,1)));
    %Let's take a majority vote for median ROI computation (in case of perfect split, keep
    %current voxel in resulting ROI)
    for x=1:size(majority_roi,1)
        for y=1:size(majority_roi,2)
            for z=1:size(majority_roi,3)
                if mean(all_roiObj(x,y,z,:))>=size(all_roiObj,4)/2
                    majority_roi(x,y,z)=1;
                end
            end
        end
    end
    
    majority_roiObj=roiObj;
    majority_roiObj.data=majority_roi;
    
    
    %Simple ROI gen parameters
    range=5;
    nIter=10;
    %Now compute new ROIs from majority ROI
    [newROIs,shrink_thresholds,expand_thresholds]=genROIs_simple(majority_roiObj,world_extent,range,nIter);
    [~,kept_ROIs]=dice_from_simple(newROIs,majority_roi,shrink_thresholds,expand_thresholds,nIter);
    %create proper data structure
    roi_struct=struct('majority',majority_roi,'new_rois',kept_ROIs)
    %Saving results on drive
    save_name=strcat('Data(median ROI)/',data.name);
    save(save_name,'roi_struct');
end
end