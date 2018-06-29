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

function selected_ROIs=select_rois(modality_type, base_volume,newROIs,shrink_thresholds,expand_thresholds,nIter)
%Eliminating null ROIs before start
selected_ROIs=newROIs;
seg=selected_ROIs.segment;
zero_rois=find(cellfun(@isempty,seg));
selected_ROIs(zero_rois,:)=[];
if isequal(modality_type,'PET')
    size_threshold=1000;
else
    size_threshold=3*10^4;
end

%Original PET ROIs can vary at most with an absolute relative variation of 1.2 for smaller
%ROIs and 0.6 for the bigger ones, so we keep everything in between for
%feature processing. Later on we will try to fit the selected volumes to
%different distributions and see the difference in model validation
thresh_values=struct('big_rois',0.6,'small_rois',1.2);

selected_volumes=[];
removed_indexes=[];
rel_vars=[];
all_volumes=[];
new_expanded_number=0;
new_shrink_number=0;
for new_roi=1:size(selected_ROIs,1)
    try
        vol_value=numel(selected_ROIs{new_roi,'segment'}{1});
    catch
    end
    if vol_value<size_threshold
        thresh_value=thresh_values.small_rois;
    else
        thresh_value=thresh_values.big_rois;
    end
    rel_var=(vol_value-base_volume)/base_volume;
    rel_vars(end+1)=rel_var;
    all_volumes(end+1)=vol_value;
    %remove same volume ROIs
    if (abs(rel_var)<thresh_value &&vol_value>8)
        if isequal(numel(find(selected_volumes==vol_value)),0)
            selected_volumes(end+1)=vol_value;
            if rel_var<0
                new_shrink_number=new_shrink_number+1;
            else
                new_expanded_number=new_expanded_number+1;
            end
        else
            removed_indexes(end+1)=new_roi;
        end
    else
        removed_indexes(end+1)=new_roi;
    end
end
selected_ROIs(removed_indexes,:)=[];
keep selected_ROIs
% close all
% figure();
% plot(all_volumes); ,hold on,
% plot(1:numel(all_volumes),zeros(1,numel(all_volumes))+base_volume);
% figure();
% plot(sort(rel_vars));
% %Visualize some ROIs results
% indices=[20 40 60 80 100];
% % indices=[1 5 10 15 20 25];
% % indices=[2 4 6 8 10];
% % indices=[1 2 3 4 5];
% 
% ROI1=matrix_from_indices(newROIs{indices(1),'gen_data'}.roi_size,newROIs{indices(1),'segment'}{1});
% ROI2=matrix_from_indices(newROIs{indices(2),'gen_data'}.roi_size,newROIs{indices(2),'segment'}{1});
% ROI3=matrix_from_indices(newROIs{indices(3),'gen_data'}.roi_size,newROIs{indices(3),'segment'}{1});
% ROI4=matrix_from_indices(newROIs{indices(4),'gen_data'}.roi_size,newROIs{indices(4),'segment'}{1});
% ROI5=matrix_from_indices(newROIs{indices(5),'gen_data'}.roi_size,newROIs{indices(5),'segment'}{1});
% keep ROI1 ROI2 ROI3 ROI4 ROI5 selected_ROIs new_shrink_number new_expanded_number
% save('ROIs_plot');
end