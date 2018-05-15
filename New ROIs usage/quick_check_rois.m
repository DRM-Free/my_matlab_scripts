function [original_roi,expand_roi,expand_roi2,shrink_roi,shrink_roi2]=quick_check_rois(sData)
%This function serves one purpose : get quick access to newly generated
%rois in order to visually compare them and check everything is in order
[~,roiObj] = getROI(sData,4,'2box');
roiObj_regular=interpVolume(roiObj,[1,1,1],'linear',0.5,'roi');
original_roi=roiObj_regular.data;
% world_extent=[sData{1,2}.scan.volume.spatialRef.PixelExtentInWorldX,sData{1,2}.scan.volume.spatialRef.PixelExtentInWorldY,sData{1, 2}.scan.volume.spatialRef.PixelExtentInWorldZ];
roi=sData{1,2}.scan.contour(4).simple_roi_gen;
roiex=roi.expand_dice_range_07_to_08{1};
roiex2=roi.expand_dice_range_07_to_08{2};
roisr=roi.shrink_dice_range_07_to_08{1};
roisr2=roi.shrink_dice_range_07_to_08{2};
sz=size(original_roi);
expand_roi=matrix_from_indices(sz,roiex);
expand_roi2=matrix_from_indices(sz,roiex2);
shrink_roi=matrix_from_indices(sz,roisr);
shrink_roi2=matrix_from_indices(sz,roisr2);
end