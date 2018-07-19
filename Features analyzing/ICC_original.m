function ICC_table=ICC_original(features_table_file)
mod='PET';
% mod='CT';
ROI_origin='new';
% ROI_origin='original';
constraint='_constrained_volume';
% constraint='';
load(features_table_file);
all_rois_all_lesions_features_table=all_rois_all_lesions_features_table(all_rois_all_lesions_features_table.feature_type=='texture',:);
algos=unique(all_rois_all_lesions_features_table.algo);
bin_counts=unique(all_rois_all_lesions_features_table.bin_count);
lesion_names=unique(all_rois_all_lesions_features_table.lesion_name);
scales=unique(all_rois_all_lesions_features_table.scale);
texture_types=unique(all_rois_all_lesions_features_table.texture_type);

if strcmp(mod,'CT')
    % Original CT bin orders
    algo_FBN_bin_counts_indexes=[8 3 5 7];
    algo_FBS_bin_counts_indexes=[2 4 6 1];
else
    % Original PET bin orders
    algo_FBN_bin_counts_indexes=[8 4 6 7];
    algo_FBS_bin_counts_indexes=[1 2 3 5];
end

%Separate features values by parameter set
%     params_sets_indexes=[];

for texture_type_index=1:numel(texture_types)
    if isequal(texture_types(texture_type_index),"none")
        continue
    end
    load(features_table_file);
    all_rois_all_lesions_features_table=all_rois_all_lesions_features_table(all_rois_all_lesions_features_table.feature_type=='texture',:);
    texture_type_table=all_rois_all_lesions_features_table(all_rois_all_lesions_features_table.texture_type==texture_types(texture_type_index),:);
    texture_type_table=texture_type_table(:,{'lesion_name','ROI_name','feature_name','scale','algo','bin_count','feature_value'});
    clear all_rois_all_lesions_features_table
    feature_names=unique(texture_type_table.feature_name);
    for feature_name_index=1:numel(feature_names)
        feature_name_table=texture_type_table(texture_type_table.feature_name==feature_names(feature_name_index),:);
        feature_name_table=feature_name_table(:,{'lesion_name','ROI_name','scale','algo','bin_count','feature_value'});
        
        for scale_index=1:numel(scales)
            for algo_index=1:numel(algos)
                if isequal(strfind(algos(algo_index),"FBN"),[])
                    %This is not an "equal" algo : apply non equal bin counts indexes
                    bin_count_indexes=algo_FBS_bin_counts_indexes;
                else
                    bin_count_indexes=algo_FBN_bin_counts_indexes;
                end
                for bin_count_index=bin_count_indexes
                    %             params_sets_indexes(end+1)=unique_param_set_index; %Just
                    %             check out that indexes are actually unique (OK)
                    paramset_row_index = find(feature_name_table.scale==scales(scale_index)...
                        & feature_name_table.algo==algos(algo_index)...
                        & feature_name_table.bin_count==bin_counts(bin_count_index));
                    param_set_table=feature_name_table(paramset_row_index,:);
                    feature_values_one_param_set={};
                    for lesion_index=1:numel(lesion_names)
                        %Find all ROIs names for current lesion
                        ROI_names=unique(param_set_table.ROI_name);
                        lesion_folder_name=lesion_names(lesion_index);
                        if ~isequal(strfind(lesion_folder_name,"CT"),[])
                            lesion_folder_name=strcat(lesion_folder_name,'.CTscan.mat');
                        elseif ~isequal(strfind(lesion_folder_name,"PET"),[])
                            lesion_folder_name=strcat(lesion_folder_name,'.PTscan.mat');
                        end
                        all_vols=get_original_vols(lesion_folder_name);
                        min_vol = min(all_vols);
                        max_vol = max(all_vols);
                        lesion_indexes=param_set_table.lesion_name==lesion_names(lesion_index);
                        feature_table_one_lesion=param_set_table(lesion_indexes,{'feature_value','ROI_name'});
                        
                        if strcmp('_constrained_volume',constraint)
                            %we intend to ignore all unlikely volumes eg volumes
                            %out of the original volumes bounds
                            feature_values_one_lesion=[];
                            ROI_names=feature_table_one_lesion.ROI_name;
                            for ROI_name_index=1:numel(ROI_names)
                                roi_name=ROI_names(ROI_name_index);
                                cur_vol=strsplit(roi_name,'_');
                                cur_vol=cur_vol(end);
                                cur_vol=str2num(char(cur_vol));
                                if or(cur_vol<min_vol,cur_vol>max_vol)
                                    continue %skips current ROI
                                else
                                    feature_values_one_lesion(end+1)=feature_table_one_lesion.feature_value(ROI_name_index);
                                end
                            end
                        else
                            feature_values_one_lesion=feature_table_one_lesion.feature_value;
                        end
                        feature_values_one_lesion(isnan(feature_values_one_lesion))=[];
                        feature_values_one_param_set(end+1)={feature_values_one_lesion};
                        clear feature_values_one_lesion
                    end
                    %The whole feature values table is now constructed.
                    %Proceed to ICC computation
                    if ~isequal(numel(feature_values_one_param_set),0)
                        ICC=one_way_ICC(feature_values_one_param_set);
                        if isnan(ICC)
                            
                        end
                    else
                        ICC=nan(1,1);
                    end
                    clear feature_values_one_param_set
                    if ~exist('ICC_table','var')
                        ICC_table=table(ICC);
                        ICC_table.algo=algos(algo_index);
                        ICC_table.bin_count=bin_counts(bin_count_index);
                        ICC_table.feature_name=feature_names(feature_name_index);
                        ICC_table.texture_type=texture_types(texture_type_index);
                        ICC_table.scale=scales(scale_index);
                    else
                        join_table=table(ICC);
                        join_table.algo=algos(algo_index);
                        join_table.bin_count=bin_counts(bin_count_index);
                        join_table.feature_name=feature_names(feature_name_index);
                        join_table.texture_type=texture_types(texture_type_index);
                        join_table.scale=scales(scale_index);
                        ICC_table=cat(1,join_table,ICC_table);
                    end
                end
            end
        end
    end
    clear texture_type_table
    fprintf('%i out of %i texture types were processed\n', texture_type_index, numel(texture_types))
end
save_name=strcat('ICC_table_',ROI_origin,'_textures_',mod,constraint,'.mat');
save(save_name,'ICC_table');
end