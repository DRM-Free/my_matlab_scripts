function [all_simple_rois]= genROIs_simple(roi,range,nIter)
%range is the size of the area to be considered around each point for growth or shrink.
%threshold represents how easy it will be to grow or shrink. 0 will always
%grow, 1 will always shrink

%Those thersholds were chosen for a range of 5
% good_shrink_thresholds=[0.3,0.35,0.4,0.45,0.5]; %>0.5 can give unexpected behaviour, sometimes overshrink and matrix becomes 0
good_shrink_thresholds=[0.3,0.325,0.35,0.4,0.42,0.45]; %>0.5 can give unexpected behaviour, sometimes overshrink and matrix becomes 0
%<0.3 for shrink actually becomes an expand
% good_expand_thresholds=[0.05,0.1,0.15,0.2,0.25]; %>0.3 is actually a shrink
good_expand_thresholds=[0.3,0.275,0.25,0.2,0.18,0.16]; %>0.3 is actually a shrink
mask=genMask(range);
maxCv=numel(mask);
shrink_ROI=roi;
expand_roi=roi;

% shrink
for shrink_thresh=good_shrink_thresholds
    thresh_field_name=strcat(strcat("thresh_",num2str(shrink_thresh)));
    thresh_field_name=strrep(thresh_field_name,'.','');
    thresh_field_name=char(thresh_field_name);
    for i=1:nIter
        iter_field_name=strcat(strcat("shrink_",num2str(i)),"_iter");
        iter_field_name=char(iter_field_name);
        
        if i>1
            previous_iter_field_name=strcat(strcat("shrink_",num2str(i-1)),"_iter");
            previous_iter_field_name=char(previous_iter_field_name);
            shrink_ROI=all_simple_rois.(previous_iter_field_name).(thresh_field_name);
        else
            shrink_ROI=roi;
        end
        new_shrink_ROI=convn(shrink_ROI,mask,'same');
        cvThresh=shrink_thresh*maxCv;
        new_shrink_ROI(new_shrink_ROI>=cvThresh)=-1;
        new_shrink_ROI(new_shrink_ROI>0)=0;
        new_shrink_ROI(new_shrink_ROI==-1)=1;
        try
            all_simple_rois.(iter_field_name).(thresh_field_name)=new_shrink_ROI;
        catch
            try
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=new_shrink_ROI;
            catch
                all_simple_rois=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=new_shrink_ROI;
            end
        end
    end
end

%expand
for expand_thresh=good_expand_thresholds
    thresh_field_name=strcat(strcat("thresh_",num2str(expand_thresh)));
    thresh_field_name=strrep(thresh_field_name,'.','');
    thresh_field_name=char(thresh_field_name);
    for i=1:nIter
        iter_field_name=strcat(strcat("expand_",num2str(i)),"_iter");
        iter_field_name=char(iter_field_name);
        
        if i>1
            previous_iter_field_name=strcat(strcat("expand_",num2str(i-1)),"_iter");
            previous_iter_field_name=char(previous_iter_field_name);
            expand_roi=all_simple_rois.(previous_iter_field_name).(thresh_field_name);
        else
            expand_roi=roi;
        end
        new_expand_roi=convn(expand_roi,mask,'same');
        cvThresh=expand_thresh*maxCv;
        new_expand_roi(new_expand_roi<=cvThresh)=0;
        new_expand_roi(new_expand_roi>0)=1;
        try
            all_simple_rois.(iter_field_name).(thresh_field_name)=new_expand_roi;
        catch
            try
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=new_expand_roi;
            catch
                all_simple_rois=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=struct;
                all_simple_rois.(iter_field_name).(thresh_field_name)=new_expand_roi;
            end
        end
    end
end
end