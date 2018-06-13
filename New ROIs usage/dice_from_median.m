function all_dice=dice_from_median()
all_data=dir('Data(median ROI)/*.mat');
all_dice=struct;
for data_file_number=1:numel(all_data)
    load(strcat('Data(median ROI)/',all_data(data_file_number).name));
    load(strcat('Simplified_data/',all_data(data_file_number).name,'/ROIs.mat'));
    load(strcat('Simplified_data/',all_data(data_file_number).name,'/ROIs_names.mat'));
    
    original_rois=kept_rois_names;
    imSize=roi_struct.vol_obj.spatialRef.ImageSize;
    
    lesion_field_name=strsplit(all_data(data_file_number).name,'.');
    lesion_field_name=lesion_field_name{1};
    lesion_field_name=strrep(lesion_field_name,'-','_');
    all_dice.(lesion_field_name)=[];
    
    for original_roi_number=1:numel(original_rois)
        non_zero_elements=all_rois_compressed{original_roi_number};
        new_roi_matrix=matrix_from_indices(imSize,non_zero_elements);
        dice=dice_coeff_from_vol(roi_struct.majority,new_roi_matrix);
        all_dice.(lesion_field_name)(end+1)=dice;
    end
    clear roi_struct;
end
end