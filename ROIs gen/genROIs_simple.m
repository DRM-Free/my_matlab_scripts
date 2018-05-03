function [all_simple_rois]= genROIs_simple(roi,range)
%range is the size of the area to be considered around each point for growth or shrink.
%threshold represents how easy it will be to grow or shrink. 0 will always
%grow, 1 will always shrink
iterations=5;
all_simple_rois=struct('rois_one_iter',[],'rois_tree_iter',[],'rois_five_iter',[]);
good_shrink_thresholds=[0.3,0.35,0.4,0.45,0.5]; %Those thersholds were chosen for a range of 5
good_expand_thresholds=[0.05,0.1,0.15,0.2,0.25];
mask=genMask(range);
maxCv=numel(mask);
shrink_ROI=roi;
expand_roi=roi;

for i=1:iterations
    new_shrink_ROI=convn(shrink_ROI,mask,'same');
    new_expand_roi=convn(expand_roi,mask,'same');
    % shrink
    for shrink_thresh=good_shrink_thresholds
        shrink_ROI=new_shrink_ROI;
        cvThresh=shrink_thresh*maxCv;
        shrink_ROI(shrink_ROI>=cvThresh)=-1;
        shrink_ROI(shrink_ROI>0)=0;
        shrink_ROI(shrink_ROI==-1)=1;
        try
            shrink_all_ROIs(end+1)=struct('thresh',shrink_thresh,'roi',shrink_ROI);
        catch
            shrink_all_ROIs=struct('thresh',shrink_thresh,'roi',shrink_ROI);
        end
    end
    
    %expand
    for expand_thresh=good_expand_thresholds
        expand_roi=new_expand_roi;
        cvThresh=expand_thresh*maxCv;
        expand_roi(expand_roi<=cvThresh)=0;
        expand_roi(expand_roi>0)=1;
        try
            expand_all_ROIs(end+1)=struct('thresh',expand_thresh,'roi',expand_roi);
        catch
            expand_all_ROIs=struct('thresh',expand_thresh,'roi',expand_roi);
        end
    end
    
    if i==1
        all_simple_rois.rois_one_iter=struct('shrink',shrink_all_ROIs,'expand',expand_all_ROIs);
    end
    
    if i==3
        all_simple_rois.rois_tree_iter=struct('shrink',shrink_all_ROIs,'expand',expand_all_ROIs);
    end
    
    if i==5
        all_simple_rois.rois_five_iter=struct('shrink',shrink_all_ROIs,'expand',expand_all_ROIs);
    end
    clear shrink_all_ROIs;
    clear expand_all_ROIs;
end
end