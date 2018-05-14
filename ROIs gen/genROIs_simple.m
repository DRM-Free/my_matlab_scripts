function [all_simple_rois,refROI,shrink_thresholds,expand_thresholds]= genROIs_simple(roiObj,world_extent,range,nIter)
%range is the size of the area to be considered around each point for growth or shrink.
%threshold represents how easy it will be to grow or shrink. 0 will always
%grow, 1 will always shrink
roiObj_regular=interpVolume(roiObj,[1,1,1],'linear',0.5,'roi');
refROI=roiObj_regular.data;
%Those thersholds were chosen for a range of 5
% good_shrink_thresholds=[0.3,0.35,0.4,0.45,0.5]; %>0.5 can give unexpected behaviour, sometimes overshrink and matrix becomes 0
shrink_thresholds=[0.3,0.35,0.4,0.45,0.5]; %>0.5 can give unexpected behaviour, sometimes overshrink and matrix becomes 0
%<0.3 for shrink actually becomes an expand
% good_expand_thresholds=[0.05,0.1,0.15,0.2,0.25]; %>0.3 is actually a shrink
expand_thresholds=[0.3,0.25,0.2,0.15,0.1]; %>0.3 is actually a shrink
mask=genMask(range);
maxCv=numel(mask);

% shrink
for shrink_thresh=shrink_thresholds
    thresh_field_name=strcat(strcat("thresh_",num2str(shrink_thresh)));
    thresh_field_name=strrep(thresh_field_name,'.','');
    thresh_field_name=char(thresh_field_name);
    for i=1:nIter
        iter_field_name=strcat(strcat("shrink_",num2str(i)),"_iter");
        iter_field_name=char(iter_field_name);
        
        if i>1
            previous_iter_field_name=strcat(strcat("shrink_",num2str(i-1)),"_iter");
            previous_iter_field_name=char(previous_iter_field_name);
            shrink_ROI=all_simple_rois.(previous_iter_field_name).(thresh_field_name).full_scale; %reduced version of ROI was saved so this can't work
        else
            shrink_ROI=refROI;
        end
        new_shrink_ROI=convn(shrink_ROI,mask,'same');
        cvThresh=shrink_thresh*maxCv;
        new_shrink_ROI(new_shrink_ROI>=cvThresh)=-1;
        new_shrink_ROI(new_shrink_ROI>0)=0;
        new_shrink_ROI(new_shrink_ROI==-1)=1;
        
        roiObj_regular.data=new_shrink_ROI;
        roiObj_final=interpVolume(roiObj_regular,[world_extent(1),world_extent(2),world_extent(3)],'linear',0.5,'roi');
        original_scale_shrink_ROI=roiObj_final.data;
        
        try
            all_simple_rois.(iter_field_name).(thresh_field_name)=struct('original_scale',original_scale_shrink_ROI,'full_scale',new_shrink_ROI);
        catch
            try
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
            all_simple_rois.(iter_field_name).(thresh_field_name)=struct('original_scale',original_scale_shrink_ROI,'full_scale',new_shrink_ROI);
            catch
                all_simple_rois=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
            all_simple_rois.(iter_field_name).(thresh_field_name)=struct('original_scale',original_scale_shrink_ROI,'full_scale',new_shrink_ROI);
            end
        end
    end
end

%expand
for expand_thresh=expand_thresholds
    thresh_field_name=strcat(strcat("thresh_",num2str(expand_thresh)));
    thresh_field_name=strrep(thresh_field_name,'.','');
    thresh_field_name=char(thresh_field_name);
    for i=1:nIter
        iter_field_name=strcat(strcat("expand_",num2str(i)),"_iter");
        iter_field_name=char(iter_field_name);
        
        if i>1
            previous_iter_field_name=strcat(strcat("expand_",num2str(i-1)),"_iter");
            previous_iter_field_name=char(previous_iter_field_name);
            expand_roi=all_simple_rois.(previous_iter_field_name).(thresh_field_name).full_scale;
        else
            expand_roi=refROI;
        end
        new_expand_roi=convn(expand_roi,mask,'same');
        cvThresh=expand_thresh*maxCv;
        new_expand_roi(new_expand_roi<=cvThresh)=0;
        new_expand_roi(new_expand_roi>0)=1;
        
        roiObj_regular.data=new_expand_roi;
        roiObj_final=interpVolume(roiObj_regular,[world_extent(1),world_extent(2),world_extent(3)],'linear',0.5,'roi');
        original_scale_expand_roi=roiObj_final.data;
        
        try
            all_simple_rois.(iter_field_name).(thresh_field_name)=struct('original_scale',original_scale_expand_roi,'full_scale',new_expand_roi);
        catch
            try
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
            all_simple_rois.(iter_field_name).(thresh_field_name)=struct('original_scale',original_scale_expand_roi,'full_scale',new_expand_roi);
            catch
                all_simple_rois=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
            all_simple_rois.(iter_field_name).(thresh_field_name)=struct('original_scale',original_scale_expand_roi,'full_scale',new_expand_roi);
            end
        end
    end
end
end