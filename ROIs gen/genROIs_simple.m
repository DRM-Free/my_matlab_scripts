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

function [new_ROIs,shrink_thresholds,expand_thresholds]= genROIs_simple(roiObj,world_extent,range,nIter)
%range is the size of the area to be considered around each point for growth or shrink.
%threshold represents how easy it will be to grow or shrink. 0 will always
%grow, 1 will always shrink
refROI=roiObj.data;
roiObj_regular=interpVolume(roiObj,[1,1,1],'linear',0.5,'roi');
ROI_normalized_ref=roiObj_regular.data;

% shrink_thresholds=[0.35]; % 0.35 Perfect shrink threshold for removing a single voxel with a mask size of 15
% expand_thresholds=[0.85]; % 0.85Perfect expand threshold for adding a single voxel with a mask size of 15
expand_thresholds=[0.81 0.85];
shrink_thresholds=[0.35 0.31];

mask_type='spherical_simple';
mask=genMask(range,mask_type);
maxCv=sum(mask(:));


%expand
for expand_thresh_number=1:numel(expand_thresholds)
    thresh_field_name=strcat(strcat("thresh_",num2str(expand_thresholds(expand_thresh_number))));
    thresh_field_name=strrep(thresh_field_name,'.','');
    thresh_field_name=strrep(thresh_field_name,'-','m');
    thresh_field_name=char(thresh_field_name);
    for i=1:nIter
        iter_field_name=strcat(strcat("expand_",num2str(i)),"_iter");
        iter_field_name=char(iter_field_name);
        
        if i>1
            previous_iter_field_name=strcat(strcat("expand_",num2str(i-1)),"_iter");
            previous_iter_field_name=char(previous_iter_field_name);
            expand_roi=all_simple_rois.(previous_iter_field_name).(thresh_field_name).full_scale;
        else
            expand_roi=ROI_normalized_ref;
        end
        %padding ROI with ones instead of zeros so as not to insert image
        %borders to segmentation
        pad_num=ceil(size(mask)/2);
        expand_roi=padarray(expand_roi,pad_num,0,'both');
        conv=convn(1-expand_roi,mask,'same');
        %Removing padding
        conv=conv(1+pad_num:end-pad_num,1+pad_num:end-pad_num,1+pad_num:end-pad_num);
        expand_roi=expand_roi(1+pad_num:end-pad_num,1+pad_num:end-pad_num,1+pad_num:end-pad_num);

        cvThresh=expand_thresholds(expand_thresh_number)*maxCv;
        new_expand_roi=expand_roi;
        new_expand_roi(conv<cvThresh)=1;
        
        if numel(find(new_expand_roi))<numel(find(expand_roi))
           %This is a shrink ! 
        end
        
        roiObj_regular.data=new_expand_roi;
        roiObj_final=interpVolume(roiObj_regular,[world_extent(1),world_extent(2),world_extent(3)],'linear',0.5,'roi');

        original_scale_expand_roi=roiObj_final.data;
        
        %Here an approximation is made in order to keep original ROI size !
        original_scale_expand_roi=original_scale_expand_roi(1:size(refROI,1),1:size(refROI,2),1:size(refROI,3));
        
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

% shrink
for shrink_thresh_number=1:numel(shrink_thresholds)
    thresh_field_name=strcat(strcat("thresh_",num2str(shrink_thresholds(shrink_thresh_number))));
    thresh_field_name=strrep(thresh_field_name,'.','');
    thresh_field_name=strrep(thresh_field_name,'-','m');
    thresh_field_name=char(thresh_field_name);
    for i=1:nIter
        iter_field_name=strcat(strcat("shrink_",num2str(i)),"_iter");
        iter_field_name=char(iter_field_name);
        
        if i>1
            previous_iter_field_name=strcat(strcat("shrink_",num2str(i-1)),"_iter");
            previous_iter_field_name=char(previous_iter_field_name);
            shrink_ROI=all_simple_rois.(previous_iter_field_name).(thresh_field_name).full_scale; %reduced version of ROI was saved so this can't work
        else
            shrink_ROI=ROI_normalized_ref;
        end
        conv=convn(1-shrink_ROI,mask,'same');
        cvThresh=shrink_thresholds(shrink_thresh_number)*maxCv;
        new_shrink_ROI=shrink_ROI;
        new_shrink_ROI(conv>cvThresh)=0;
        
        roiObj_regular.data=new_shrink_ROI;
        roiObj_final=interpVolume(roiObj_regular,[world_extent(1),world_extent(2),world_extent(3)],'linear',0.5,'roi');
        original_scale_shrink_ROI=roiObj_final.data;
        
        %Here an approximation is made in order to keep original ROI size !
        original_scale_shrink_ROI=original_scale_shrink_ROI(1:size(refROI,1),1:size(refROI,2),1:size(refROI,3));
        
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


%Now return ROIs with full generation data
keep all_simple_rois shrink_thresholds expand_thresholds range mask_type refROI
iter_names=fieldnames(all_simple_rois);
for iter=1:numel(iter_names)
    thresh_names=fieldnames(all_simple_rois.(iter_names{iter}));
    for thresh=1:numel(thresh_names)
        roi={find(all_simple_rois.(iter_names{iter}).(thresh_names{thresh}).original_scale)};
        gen_data=struct('thresh',thresh_names{thresh},'iteration',iter_names{iter},'mask_type',mask_type,'mask_size',range, 'roi_size',size(refROI));
        gen_type='simple_conv';
        roi_table=table;
        roi_table.segment=roi;
        roi_table.gen_data=gen_data;
        roi_table.gen_type=gen_type;
        try
            new_ROIs(end+1,:)=roi_table;
        catch
            new_ROIs=roi_table;
        end
    end
end

end
