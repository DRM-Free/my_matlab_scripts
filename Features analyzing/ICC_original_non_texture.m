function ICC_table=ICC_original_non_texture(features_table_file)
mod='PET';
% mod='CT';
ROI_origin='new';
% ROI_origin='original';
constraint='_constrained_volume';
% constraint='';
load(features_table_file);
non_texture_table=all_rois_all_lesions_features_table(all_rois_all_lesions_features_table.feature_type~='texture',:);
clear all_rois_all_lesions_features_table
lesion_names=unique(non_texture_table.lesion_name);
feature_types=unique(non_texture_table.feature_type);

for feature_type_index=1:numel(feature_types)
    load(features_table_file);
    non_texture_table=all_rois_all_lesions_features_table(all_rois_all_lesions_features_table.feature_type~='texture',:);
    feature_type_table=non_texture_table(non_texture_table.feature_type==feature_types(feature_type_index),:);
    clear all_rois_all_lesions_features_table
    feature_names=unique(feature_type_table.feature_name);
    for feature_name_index=1:numel(feature_names)
        feature_name_table=feature_type_table(feature_type_table.feature_name==feature_names(feature_name_index),:);
        feature_values_all_lesions={};
        for lesion_index=1:numel(lesion_names)
            %Find all ROIs names for current lesion
            ROI_names=unique(feature_name_table.ROI_name);
            lesion_folder_name=lesion_names(lesion_index);
            if ~isequal(strfind(lesion_folder_name,"CT"),[])
                lesion_folder_name=strcat(lesion_folder_name,'.CTscan.mat');
            elseif ~isequal(strfind(lesion_folder_name,"PET"),[])
                lesion_folder_name=strcat(lesion_folder_name,'.PTscan.mat');
            end
            all_vols=get_original_vols(lesion_folder_name);
            min_vol = min(all_vols);
            max_vol = max(all_vols);
            lesion_indexes=feature_name_table.lesion_name==lesion_names(lesion_index);
            feature_table_one_lesion=feature_name_table(lesion_indexes,{'feature_value','ROI_name'});
            
            if strcmp('_constrained_volume',constraint)
                %we intend to ignore all unlikely volumes eg volumes
                %out of the original volumes bounds
                feature_values_one_lesion=[];
                ROI_names=feature_table_one_lesion.ROI_name;
                for ROI_name_index=1:numel(ROI_names)
                    feature_values_one_lesion(isnan(feature_values_one_lesion))=[];
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
            feature_values_all_lesions(end+1)={feature_values_one_lesion};
            clear feature_values_one_lesion
        end
        %         for lesion_index=1:numel(lesion_names)
        %             %Find all ROIs names for current lesion
        %             ROI_names=unique(feature_name_table.ROI_name);
        %             feature_values_one_lesion=[];
        %             for ROI_name_index=1:numel(ROI_names)
        %                 feature_value_row_index = find(feature_name_table.feature_name==feature_names(feature_name_index)...
        %                     & feature_name_table.lesion_name==lesion_names(lesion_index)...
        %                     & feature_name_table.ROI_name==ROI_names(ROI_name_index));
        %                 %                 test_table=all_rois_all_lesions_features_table(feature_value_row_index,:);
        %                 feature_value=feature_name_table{feature_value_row_index,'feature_value'};
        %                 try
        %                     if ~isnan(feature_value)
        %                         feature_values_one_lesion(end+1)=feature_value;
        %                     end
        %                 catch
        %                     %Unprocessed features will be caught here, just ignore them (Features can be unprocessed
        %                     %because of a too small ROI or other reasons)
        %                 end
        %             end
        %             feature_values_all_lesions(end+1)={feature_values_one_lesion};
        %             clear feature_values_one_lesion
        %         end
        %The whole feature values table is now constructed.
        %Proceed to ICC computation
        if ~isequal(numel(feature_values_all_lesions),0)
            ICC=one_way_ICC(feature_values_all_lesions);
        else
            ICC=nan(1,1);
        end
        if ~exist('ICC_table','var')
            ICC_table=table(ICC);
            ICC_table.feature_name=feature_names(feature_name_index);
            ICC_table.feature_type=feature_types(feature_type_index);
        else
            join_table=table(ICC);
            join_table.feature_name=feature_names(feature_name_index);
            join_table.feature_type=feature_types(feature_type_index);
            ICC_table=cat(1,join_table,ICC_table);
        end
    end
    fprintf('%i out of %i feature types were processed\n', feature_type_index, numel(feature_types))
end
save_name=strcat('ICC_table_',ROI_origin,'_non_textures_',mod,constraint,'.mat');
save(save_name,'ICC_table');
end