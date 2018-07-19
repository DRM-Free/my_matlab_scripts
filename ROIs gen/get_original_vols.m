function all_vols=get_original_vols(lesion_file)
load(strcat('Simplified_data/',lesion_file,'/ROIs.mat'));
all_vols=numel(all_rois_compressed{1,1});
for roi_index=2:numel(all_rois_compressed)
    all_vols(end+1)=numel(all_rois_compressed{1,roi_index});
end
end