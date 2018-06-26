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

function newROIs=select_rois(modality_type, base_volume,newROIs,shrink_thresholds,expand_thresholds,nIter)
%Eliminating null ROIs before start
seg=newROIs.segment;
zero_rois=find(cellfun(@isempty,seg));
newROIs(zero_rois,:)=[];
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
for new_roi=1:size(newROIs,1)
    try
        vol_value=numel(newROIs{new_roi,'segment'}{1});
    catch
    end
    if vol_value<size_threshold
        thresh_value=thresh_values.small_rois;
    else
        thresh_value=thresh_values.big_rois;
    end
    rel_var=abs(base_volume-vol_value)/base_volume;
    rel_vars(end+1)=rel_var;
    all_volumes(end+1)=vol_value;
    if (abs(rel_var)<thresh_value &vol_value>8)
        selected_volumes(end+1)=vol_value;
    else
        removed_indexes(end+1)=new_roi;
    end
end
newROIs(removed_indexes,:)=[];
end