function [same_ref_rois,new_spatial_ref,new_image_size]=convert_to_same_referential(all_roi_obj)
%This function takes various ROI obj and converts them to the same
%referential, while returning the transformed volObj

PEX=all_roi_obj{1}.spatialRef.PixelExtentInWorldX;
PEY=all_roi_obj{1}.spatialRef.PixelExtentInWorldY;
PEZ=all_roi_obj{1}.spatialRef.PixelExtentInWorldZ;

%Determining spatialRef new elements
x_limits_min=all_roi_obj{1}.spatialRef.XWorldLimits(1);
y_limits_min=all_roi_obj{1}.spatialRef.YWorldLimits(1);
z_limits_min=all_roi_obj{1}.spatialRef.ZWorldLimits(1);

x_limits_max=all_roi_obj{1}.spatialRef.XWorldLimits(2);
y_limits_max=all_roi_obj{1}.spatialRef.YWorldLimits(2);
z_limits_max=all_roi_obj{1}.spatialRef.ZWorldLimits(2);

% x_intrinsic_min=all_roi_obj{1}.spatialRef.XIntrinsicLimits(1);
% y_intrinsic_min=all_roi_obj{1}.spatialRef.YIntrinsicLimits(1);
% z_intrinsic_min=all_roi_obj{1}.spatialRef.ZIntrinsicLimits(1);

for roi_index=2:numel(all_roi_obj)
    if x_limits_max<all_roi_obj{roi_index}.spatialRef.XWorldLimits(2);
        x_limits_max=all_roi_obj{roi_index}.spatialRef.XWorldLimits(2);
        %         x_intrinsic_max=all_roi_obj{roi_index}.spatialRef.XIntrinsicLimits(2);
    end
    if x_limits_min>all_roi_obj{roi_index}.spatialRef.XWorldLimits(1);
        x_limits_min=all_roi_obj{roi_index}.spatialRef.XWorldLimits(1);
    end
    
    if y_limits_max<all_roi_obj{roi_index}.spatialRef.YWorldLimits(2);
        y_limits_max=all_roi_obj{roi_index}.spatialRef.YWorldLimits(2);
        %         y_intrinsic_max=all_roi_obj{roi_index}.spatialRef.YIntrinsicLimits(2);
    end
    if y_limits_min>all_roi_obj{roi_index}.spatialRef.YWorldLimits(1);
        y_limits_min=all_roi_obj{roi_index}.spatialRef.YWorldLimits(1);
    end
    
    if z_limits_max<all_roi_obj{roi_index}.spatialRef.ZWorldLimits(2);
        z_limits_max=all_roi_obj{roi_index}.spatialRef.ZWorldLimits(2);
        %         z_intrinsic_max=all_roi_obj{roi_index}.spatialRef.ZIntrinsicLimits(2);
    end
    if z_limits_min>all_roi_obj{roi_index}.spatialRef.ZWorldLimits(1);
        z_limits_min=all_roi_obj{roi_index}.spatialRef.ZWorldLimits(1);
    end
    
end
% x_intrinsic_range=x_intrinsic_max-x_intrinsic_min;
% y_intrinsic_range=y_intrinsic_max-y_intrinsic_min;
% z_intrinsic_range=z_intrinsic_max-z_intrinsic_min;

new_world_extent_x=x_limits_max-x_limits_min;
new_world_extent_y=y_limits_max-y_limits_min;
new_world_extent_z=z_limits_max-z_limits_min;
new_image_size_x=ceil(new_world_extent_x/PEX);
new_image_size_y=ceil(new_world_extent_y/PEY);
new_image_size_z=ceil(new_world_extent_z/PEZ);
new_image_size=[new_image_size_y,new_image_size_x,new_image_size_z]; %ordering as in original sData

%     spatialRef = imref3d([sz(1),sz(2),nSlices],pixelX,pixelY,sliceS);
%     spatialRef.XWorldLimits = spatialRef.XWorldLimits - (spatialRef.XWorldLimits(1)-(min(Xgrid(:))-pixelX/2));
%     spatialRef.YWorldLimits = spatialRef.YWorldLimits - (spatialRef.YWorldLimits(1)-(min(Ygrid(:))-pixelY/2));
%     spatialRef.ZWorldLimits = spatialRef.ZWorldLimits - (spatialRef.ZWorldLimits(1)-(min(Zgrid(:))-sliceS/2));

new_spatial_ref=imref3d(new_image_size,PEX,PEY,PEZ);
new_spatial_ref.XWorldLimits=[x_limits_min,x_limits_max];
new_spatial_ref.YWorldLimits=[y_limits_min,y_limits_max];
new_spatial_ref.ZWorldLimits=[z_limits_min,z_limits_max];

% new_spatial_ref.XIntrinsicLimits=[x_intrinsic_min,x_intrinsic_max];
% new_spatial_ref.YIntrinsicLimits=[y_intrinsic_min,y_intrinsic_max];
% new_spatial_ref.ZIntrinsicLimits=[z_intrinsic_min,z_intrinsic_max];
%
% new_spatial_ref.PixelExtentInWorldX=PEX;
% new_spatial_ref.PixelExtentInWorldY=PEY;
% new_spatial_ref.PixelExtentInWorldZ=PEZ;
% new_spatial_ref.ImageExtentInWorldX=x_limits_max-x_limits_min;
% new_spatial_ref.ImageExtentInWorldY=y_limits_max-y_limits_min;
% new_spatial_ref.ImageExtentInWorldZ=z_limits_max-z_limits_min;
% new_spatial_ref.ImageSize=[y_intrinsic_range,x_intrinsic_range,z_intrinsic_range];

%Extracting specific ROI from all ROI obj
same_ref_rois=[];
for roi_index=1:numel(all_roi_obj)
    %Finding coordinates offset between old and new ROI
    offset_x_world=all_roi_obj{roi_index}.spatialRef.XWorldLimits(1)-x_limits_min;
    offset_y_world=all_roi_obj{roi_index}.spatialRef.YWorldLimits(1)-y_limits_min;
    offset_z_world=all_roi_obj{roi_index}.spatialRef.ZWorldLimits(1)-z_limits_min;
    
    offset_x_image=offset_x_world/PEX;
    offset_y_image=offset_y_world/PEY;
    offset_z_image=offset_z_world/PEZ;
    offset=[offset_y_image,offset_x_image,offset_z_image];
    
    new_roi=zeros(new_image_size);
    new_roi(1+offset_y_image:offset_y_image+all_roi_obj{roi_index}.spatialRef.ImageSize(1),...
        1+offset_x_image:offset_x_image+all_roi_obj{roi_index}.spatialRef.ImageSize(2),...
        1+offset_z_image:offset_z_image+all_roi_obj{roi_index}.spatialRef.ImageSize(3))...
        =all_roi_obj{roi_index}.data;
    try
        same_ref_rois=cat(4,same_ref_rois,new_roi);
    catch
        same_ref_rois=new_roi;
    end
end

%Currently the offset is just in regard to the biggest ROI, but not the
%full object, Thus we need to add some values to the offset to get a full_offset


end