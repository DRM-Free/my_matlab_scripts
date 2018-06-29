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

function ICC_original()
%Features discriminative characterisation from original ROIs.
lesions_folders=dir('features_from_original/*.mat');
for lesion_folder_index=1:numel(lesions_folders)
    ROIs_files=dir(strcat('features_from_original/',lesions_folders(lesion_folder_index).name,'/*.mat'));
    Lesion_name_parts=strsplit(lesions_folders(lesion_folder_index).name,'.');
    lesion_name=string(Lesion_name_parts{1});
    fprintf(strcat('Processing lesion : ', lesion_name,'\n'));
    for ROI_file_index=1:numel(ROIs_files)
        load(strcat('features_from_original/',lesions_folders(lesion_folder_index).name,'/',ROIs_files(ROI_file_index).name));
        if ~exist('all_features_names','var')
            all_features_names=fieldnamesr(radiomics.image);
        end
        for feature_index=1:numel(all_features_names)
            feature_name_parts=strsplit(all_features_names{feature_index},'.');
            feature_type=string(feature_name_parts{1});
            if isequal(feature_type,"texture")
                texture_type=string(feature_name_parts{2});
                feature_params=feature_name_parts{3};
                feature_params_parts=strsplit(feature_params,'_');
                algo=string(feature_params_parts{2});
                scale=string(feature_params_parts{1});
                bin_count=string(feature_params_parts{3});
            else
                texture_type="none";
                algo="unused";
                scale="unused";
                bin_count="unused";
            end
            feature_name=string(feature_name_parts{end});
            feature_value=get_inclusive_field(radiomics.image,all_features_names{feature_index});
            % Setting all features falues in proper container
            if ~isequal(feature_value,[])
                one_roi_feature_table=table(lesion_name,feature_type,texture_type,feature_name,scale,algo,bin_count,feature_value);
            else
                %Deal with unprocessed features
                one_roi_feature_table=table(lesion_name,feature_type,texture_type,feature_name,scale,algo,bin_count,"unprocessed");
            end
        end
        if ~exist('all_rois_features_table','var')
            all_rois_features_table=one_roi_feature_table;
        else
            all_rois_features_table=outerjoin(all_rois_features_table,one_roi_feature_table,'MergeKeys', true);
        end
    end
    %Adding all feature values from this lesion
    if ~exist('all_rois_all_lesions_features_table','var')
        all_rois_all_lesions_features_table=all_rois_features_table;
    else
        all_rois_all_lesions_features_table=outerjoin(all_rois_all_lesions_features_table,all_rois_features_table,'MergeKeys', true);
    end
    fprintf('%i out of %i lesions folders were processed\n',lesion_folder_index,numel(lesions_folders));
end
% Now all features values were added to a single, easy to browse table.
%Better save this table before proceeding to ICC
save('Original_ROIs_features_table','all_rois_all_lesions_features_table');
end