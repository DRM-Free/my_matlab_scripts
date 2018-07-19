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

function all_rois_all_lesions_features_table=Create_features_table()
%Features discriminative characterisation from original ROIs.
lesions_folders=dir('features_from_majority_2/*.mat');
%Remove all_data elements that have already been processed
% example : already_processed_labels=[{'05'};{'06'};{'08'};{'10'};{'11'};{'12_CT'}];
already_processed_labels={'PETscan'};
already_processed=zeros(numel(lesions_folders),1);
for processed_number=1:numel(already_processed_labels)
    new_processed=arrayfun(@(x) contains(x.name,already_processed_labels{processed_number}),lesions_folders);
    already_processed=already_processed|new_processed;
end
lesions_folders(already_processed==1)=[];
for lesion_folder_index=1:numel(lesions_folders)
    ROIs_files=dir(strcat('features_from_majority_2/',lesions_folders(lesion_folder_index).name,'/*.mat'));
    Lesion_name_parts=strsplit(lesions_folders(lesion_folder_index).name,'.');
    lesion_name=string(Lesion_name_parts{1});
    fprintf(strcat('Processing lesion : ', lesion_name,'\n'));
    for ROI_file_index=1:numel(ROIs_files)
        ROI_name_parts=strsplit(ROIs_files(ROI_file_index).name,'.');
        ROI_name=string(ROI_name_parts{1});
        load(strcat('features_from_majority_2/',lesions_folders(lesion_folder_index).name,'/',ROIs_files(ROI_file_index).name));
        if ~exist('all_features_names','var')
            all_features_names=fieldnamesr(radiomics.radiomics_values.image);
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
            feature_value=get_inclusive_field(radiomics.radiomics_values.image,all_features_names{feature_index});
            if ~exist('one_roi_feature_table','var')
                % Setting all features values in proper container
                if ~isequal(feature_value,[])
                    one_roi_feature_table=table(lesion_name,ROI_name,feature_type,texture_type,feature_name,scale,algo,bin_count,feature_value);
%                     one_roi_feature_table.gen_type=string(radiomics.ROI_info.gen_type);
%                     one_roi_feature_table.gen_data={radiomics.ROI_info.gen_data};
                else
                    %Deal with unprocessed features
                    one_roi_feature_table=table(lesion_name,ROI_name,feature_type,texture_type,feature_name,scale,algo,bin_count);
                    one_roi_feature_table.feature_value=NaN(1,1);
%                     one_roi_feature_table.gen_type=string(radiomics.ROI_info.gen_type);
%                     one_roi_feature_table.gen_data={radiomics.ROI_info.gen_data};
                end
            else
                if ~isequal(feature_value,[])
                    try
                        cur_table=table(lesion_name,ROI_name,feature_type,texture_type,feature_name,scale,algo,bin_count,feature_value);
%                         cur_table.gen_type=string(radiomics.ROI_info.gen_type);
%                         cur_table.gen_data={radiomics.ROI_info.gen_data};
                    catch
                        cur_table=table(lesion_name,ROI_name,feature_type,texture_type,feature_name,scale,algo,bin_count);
                        cur_table.feature_value=NaN(1,1);
%                         cur_table.gen_type=string(radiomics.ROI_info.gen_type);
%                         cur_table.gen_data={radiomics.ROI_info.gen_data};
                    end
                else
                    %Deal with unprocessed features
                    cur_table=table(lesion_name,ROI_name,feature_type,texture_type,feature_name,scale,algo,bin_count);
                    cur_table.feature_value=NaN(1,1);
%                     cur_table.gen_type=string(radiomics.ROI_info.gen_type);
%                     cur_table.gen_data={radiomics.ROI_info.gen_data};
                end
                one_roi_feature_table=cat(1,one_roi_feature_table,cur_table);
            end
        end
        if ~exist('all_rois_features_table','var')
            all_rois_features_table=one_roi_feature_table;
        else
            try
                all_rois_features_table=cat(1,all_rois_features_table,one_roi_feature_table);
            catch e %e is an MException struct
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
            end
        end
        clear one_roi_feature_table
    end
    %Adding all feature values from this lesion
    if ~exist('all_rois_all_lesions_features_table','var')
        all_rois_all_lesions_features_table=all_rois_features_table;
    else
        all_rois_all_lesions_features_table=cat(1,all_rois_all_lesions_features_table,all_rois_features_table);
    end
    fprintf('%i out of %i lesions folders were processed\n',lesion_folder_index,numel(lesions_folders));
    clear all_rois_features_table
end
% Now all features values were added to a single, easy to browse table.
%Better save this table before proceeding to ICC
save('New_ROIs_features_table_CT.mat','all_rois_all_lesions_features_table','-v7.3');
end