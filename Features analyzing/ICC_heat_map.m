function ICC_heat_map(ICC_table)
mod='PET';
% mod='CT';
ROI_origin='new';
% ROI_origin='original';
constraint='constrained_volume_';
% constraint='';
unique_texture_types=unique(ICC_table.texture_type);
unique_scales=unique(ICC_table.scale);
unique_bin_counts=unique(ICC_table.bin_count);
unique_algos=unique(ICC_table.algo);
if strcmp(mod,'CT')
    % Original CT bin orders
    FBN_bin_indexes=[8 3 5 7];
    FBS_bin_indexes=[2 4 6 1];
else
    % Original PET bin orders
    FBN_bin_indexes=[8 4 6 7];
    FBS_bin_indexes=[1 2 3 5];
end

for texture_type_index=1:numel(unique_texture_types)
    texture_type_table=ICC_table(ICC_table.texture_type==unique_texture_types(texture_type_index),:);
    feature_names=unique(texture_type_table.feature_name);
    for feature_name_index=1:numel(feature_names)
        feature_name=feature_names(feature_name_index);
        for scale_index=1:numel(unique_scales)
            for algo_index=1:numel(unique_algos)
                if isequal(strfind(unique_algos(algo_index),"FBN"),[])
                    %This is not an "equal" algo : apply non equal bin counts indexes
                    bin_count_indexes=FBS_bin_indexes;
                else
                    bin_count_indexes=FBN_bin_indexes;
                end
                for bin_count_index=1:numel(bin_count_indexes) %Each bin count is used only in half algos, so
                    %It is possible to keep only 4 indexes and keep consistent indexes
                    unique_param_set_index=sub2ind([4 4 4],bin_count_index,scale_index,algo_index);
                    param_set_row_index=find(texture_type_table.bin_count==unique_bin_counts(bin_count_indexes(bin_count_index))...
                        &texture_type_table.scale==unique_scales(scale_index)...
                        &texture_type_table.algo==unique_algos(algo_index)...
                        &texture_type_table.feature_name==feature_names(feature_name_index));
                    ICC_value=texture_type_table{param_set_row_index,'ICC'};
                    if ~exist('heat_map_table','var')
                        heat_map_table=table(ICC_value,unique_param_set_index,feature_name);
                    else
                        try
                            heat_map_table=cat(1,heat_map_table,table(ICC_value,unique_param_set_index,feature_name));
                        catch
                        end
                    end
                end
            end
        end
    end
    close all;
    figure('units','normalized','outerposition',[0 0 1 1],'Visible','off')
    heat_map_table.ICC_value=double(heat_map_table.ICC_value); %For some reason some ICC
    %values are single type, which causes problem for heatmap computation
    h=heatmap(heat_map_table,'unique_param_set_index','feature_name','ColorVariable','ICC_value');
    h.Title = strcat('ICC values for texture type : ',unique_texture_types(texture_type_index));
    figHandles = findobj('Type', 'figure');
    save_name=char(strcat("../Docs/Master thesis elements/ICC_heatmap/ICC_texture_type_",unique_texture_types(texture_type_index),'_',ROI_origin,'_',mod,constraint,'.png'));
    saveas(figHandles,save_name);
    clear heat_map_table h
end
end