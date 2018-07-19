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

function ICC_table=ICC_direct()
%ICC : table with fields feature name, feature type, texture type, ICC
%value and texture parameters
unique_FBN_bins=[8 16 32 64];
unique_FBS_bins=[12.5 25 50 100];
unique_scales=[1 2 3 4];
unique_algos={'algoFBN','algoFBS','algoFBNequal64','algoFBSequal64'};
%Features discriminative characterisation from original ROIs.
lesions_folders=dir('features_from_majority_2/*.mat');
%Remove all_data elements that have already been processed
% example : already_processed_labels=[{'05'};{'06'};{'08'};{'10'};{'11'};{'12_CT'}];
already_processed_labels={'PTscan'};
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
                scale=str2int(strrep(scale,'scale',''));
                bin_count=string(feature_params_parts{3});
                bin_count=strrep(bin_count,'DOT','.');
                bin_count=str2double(strrep(bin_count,'bin',''));
                algo_index=find(unique_algos,algo);
                scale_index=find(unique_scales,scale);
                if (algo_index==1 | algo_index==3)
                    bin_index=find(bin_count, unique_FBN_bins)
                else
                    bin_index=find(bin_count, unique_FBS_bins)
                end
            else
                texture_type="none";
                algo="unused";
                scale="unused";
                bin_count="unused";
            end
            feature_name=string(feature_name_parts{end});
        end
    end
    fprintf('%i out of %i lesions folders were processed\n',lesion_folder_index,numel(lesions_folders));
    clear all_rois_features_table
end
% Now all features values were added to a single, easy to browse table.
%Better save this table before proceeding to ICC
if exist('New_ROIs_features_table_CT.mat', 'file')==2
    save_table=all_rois_all_lesions_features_table;
    load('New_ROIs_features_table_CT.mat'); %Load previously saved table
    all_rois_all_lesions_features_table=cat(1,save_table,all_rois_all_lesions_features_table);
end
save('New_ROIs_features_table_CT.mat','all_rois_all_lesions_features_table','-v7.3');
end