all_features_folders=dir('features_from_majority/*.mat');
load(strcat('features_from_majority/',all_features_folders(1).name,'/',all_features_files(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics



for features_folder_index=1:numel(all_features_folders)
    all_features_files=dir(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/*.mat'));
    %all_features_file contains the names of all ROIs types (majority, expands and schinks)
    
    %We need to order features folders from the smallest ROi to the biggest
    %one in order to find a possible rupture ROI
    shrink_values=[];
    expand_values=[];
    for feature_file=1:numel(all_features_files)
        separated_name=strsplit(all_features_files(feature_file).name,'_');
        transform_type=separated_name{1};
        
        if isequal(transform_type,'expand') %This file contains features from expanded ROI
            expand_range=separated_name{4};
            expand_range=strrep(expand_range,'0','0.');
            num_range=str2num(expand_range);
            expand_values(end+1)=num_range;
        end
        if isequal(transform_type,'shrink') %This file contains features from shrinked ROI
            shrink_range=separated_name{4};
            shrink_range=strrep(shrink_range,'0','0.');
            num_range=str2num(shrink_range);
            shrink_values(end+1)=num_range;
        end
    end
    expand_values=sort(expand_values,'descend');
    shrink_values=sort(shrink_values);
    
    for feature_index=1:numel(all_features)
        close all;
        sorted_feature_values=[];
        for shrink_value_index=1:numel(shrink_values)
            inf_range_str=num2str(shrink_values(shrink_value_index));
            sup_range_str=num2str(shrink_values(shrink_value_index)+0.05);
            inf_range_str=strrep(inf_range_str,'.','');
            sup_range_str=strrep(sup_range_str,'.','');
            file_name=strcat('shrink_dice_range_',inf_range_str,'_to_',sup_range_str);
            load(strcat('features_from_majority/',all_features_folders(1).name,'/',file_name));
            cur_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            if ~isequal(cur_value,[])
                sorted_feature_values(end+1)=cur_value;
            end
            clear radiomics
        end
        
        load(strcat('features_from_majority/',all_features_folders(1).name,'/majority.mat'));
        maj_value=get_inclusive_field(radiomics.image,all_features{feature_index});
        if ~isequal(maj_value,[])
            sorted_feature_values(end+1)=maj_value;
        end
        clear radiomics
        
        for expand_value_index=1:numel(expand_values)
            inf_range_str=num2str(expand_values(expand_value_index));
            sup_range_str=num2str(expand_values(expand_value_index)+0.05);
            inf_range_str=strrep(inf_range_str,'.','');
            sup_range_str=strrep(sup_range_str,'.','');
            file_name=strcat('expand_dice_range_',inf_range_str,'_to_',sup_range_str);
            load(strcat('features_from_majority/',all_features_folders(1).name,'/',file_name));
            cur_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            if ~isequal(cur_value,[])
                sorted_feature_values(end+1)=cur_value;
            end
            clear radiomics
        end
        figure('name',all_features{feature_index});
        plot(sorted_feature_values), hold on,
        maj_plot=zeros(numel(sorted_feature_values));
        maj_plot=maj_plot+maj_value;
        plot(maj_plot);
    end
end