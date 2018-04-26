function [all_vols]=get_all_vols(file)
load(file);
rois = sData{1,2}.scan.contour;

for roiNum=1:numel(rois) %First iterate over all rois in order to determine the best common matrix size
    roiName=rois(roiNum);
    
    %Removing unused rois
    roiName=roiName.name;
    visPos = strfind(roiName,'1vis');
    autoPos = strfind(roiName,'1auto');
    
    if ~(isequal(autoPos,[])&isequal(visPos,[]))
        process=true;
    else
        process=false;
    end
    if process
        [~,roiObj] = getROI(sData,roiNum,'box'); %Getting minimal cube inlcuding the tumor
        xmin=roiObj.spatialRef.XIntrinsicLimits(1); xmax=roiObj.spatialRef.XIntrinsicLimits(2);
        ymin=roiObj.spatialRef.YIntrinsicLimits(1);ymax=roiObj.spatialRef.YIntrinsicLimits(2);
        zmin=roiObj.spatialRef.ZIntrinsicLimits(1);zmax=roiObj.spatialRef.ZIntrinsicLimits(2);
        if ~exist('min_global')
            min_global=[xmin,ymin,zmin];
            max_global=[xmax,ymax,zmax];
        else
            min_global=[min(min_global(1),xmin),min(min_global(2),ymin),min(min_global(3),zmin)];
            max_global=[max(max_global(1),xmax),max(max_global(2),ymax),max(max_global(3),zmax)];
        end
        try
            [tr_ref_x,tr_ref_y,tr_ref_z]=min([tr_ref_x,tr_ref_y,tr_ref_z],worldToIntrinsic(roiObj.spatialRef,roiObj.spatialRef.XIntrinsicLimits(1),roiObj.spatialRef.YIntrinsicLimits(1),roiObj.spatialRef.ZIntrinsicLimits(1)));
        catch
            [tr_ref_x,tr_ref_y,tr_ref_z]=worldToIntrinsic(roiObj.spatialRef,roiObj.spatialRef.XIntrinsicLimits(1),roiObj.spatialRef.YIntrinsicLimits(1),roiObj.spatialRef.ZIntrinsicLimits(1));
            
        end
    end
end

[~,roiObj] = getROI(sData,roiNum,'full'); %here find the translate to apply to all boxes
%If there was a step to monitor closely it should be this one.
[translate_x,translate_y,translate_z]=worldToIntrinsic(roiObj.spatialRef,roiObj.spatialRef.XIntrinsicLimits(1),roiObj.spatialRef.YIntrinsicLimits(1),roiObj.spatialRef.ZIntrinsicLimits(1));
translate=[translate_y,translate_x,translate_z]-[tr_ref_y,tr_ref_x,tr_ref_z];

%New borders to apply to all ROIs
borderCoords=[min_global(1),max_global(1);min_global(2),max_global(2);min_global(3),max_global(3)];
borderCoords(1,:)=borderCoords(1,:)+translate(1);
borderCoords(2,:)=borderCoords(2,:)+translate(2);
borderCoords(3,:)=borderCoords(3,:)+translate(3);

for roiNum=1:numel(rois) %Now resize ROIs to the common sizes and return all of them
    %We still need to translate referentials for proper registration
    roiName=rois(roiNum);
    
    %Removing unused rois
    roiName=roiName.name;
    visPos = strfind(roiName,'1vis');
    autoPos = strfind(roiName,'1auto');
    
    if ~(isequal(autoPos,[])&isequal(visPos,[]))
        process=true;
    else
        process=false;
    end
    if process
        [volObj,roiObj] = getROI(sData,roiNum,'full'); %Getting minimal cube inlcuding the tumor
        
        % COMPUTING THE BOUNDING BOX
        try
            [~,roi,newSpatialRef] = compute_custom_box(volObj.data,roiObj.data,roiObj.spatialRef,borderCoords);
        catch
        end
        % ARRANGE OUTPUT
        newROI_Obj = struct;
        newROI_Obj.data = roi; newROI_Obj.spatialRef = newSpatialRef;
        try
            all_vols=cat(1,all_vols,{roi});
        catch
            all_vols={roi};
        end
    end
end

clear sData;
% save('all_vols','all_vols');
end