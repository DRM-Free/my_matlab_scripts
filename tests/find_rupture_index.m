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

all_features_folders=dir('features_from_majority/*.mat');
all_features_files=dir(strcat('features_from_majority/',all_features_folders(1).name,'/*.mat'));
load(strcat('features_from_majority/',all_features_folders(1).name,'/',all_features_files(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics

if ~isdir('features_from_majority_sorted_by_volume')
    mkdir('features_from_majority_sorted_by_volume');
end

for features_folder_index=1:numel(all_features_folders)
    all_features_files=dir(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/*.mat'));
    %all_features_file contains the names of all ROIs types (majority, expands and schinks)
    if ~isdir(strcat('features_from_majority_sorted_by_volume/',all_features_folders(features_folder_index).name))
        mkdir(strcat('features_from_majority_sorted_by_volume/',all_features_folders(features_folder_index).name));
    end
    unsorted_volumes=[];
    for feature_file_index=1:numel(all_features_files)
        load(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/',all_features_files(feature_file_index).name));
        cur_vol=radiomics.image.morph_3D.scale2.Fmorph_vol;
        unsorted_volumes(end+1)=cur_vol;
    end
    [sorted_volumes,sorted_indexes]=sort(unsorted_volumes);
    %We need to order features folders from the smallest ROI to the biggest
    %one in order to find a possible rupture ROI
    shrink_values=[];
    expand_values=[];
    for feature_file_index=1:numel(all_features_files)
        
        separated_name=strsplit(all_features_files(feature_file_index).name,'_');
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
            load(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/',file_name));
            cur_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            if ~isequal(cur_value,[])
                sorted_feature_values(end+1)=cur_value;
            end
            clear radiomics
        end
        
        load(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/majority.mat'));
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
            load(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/',file_name));
            cur_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            if ~isequal(cur_value,[])
                sorted_feature_values(end+1)=cur_value;
            end
            clear radiomics
        end
        
        maj_plot=zeros(1,numel(sorted_feature_values));
        maj_plot=maj_plot+maj_value;
        
        feature_plot_name=strsplit(all_features{feature_index},'.');
        feature_type=feature_plot_name{1};
        ignore_feature=false;
        if isequal(feature_type,'texture')
            feature_name_complement=strcat(feature_plot_name{2},'__',feature_plot_name{3});
            scale=strsplit(feature_name_complement,'scale');
            scale=scale{2};
            scale=scale(1);
            if ~isequal(scale,'1')
                ignore_feature=true;
            end
        else
            feature_name_complement='';
        end
        if ~ignore_feature
            feature_plot_name=feature_plot_name{end};
            feature_plot_name=strrep(feature_plot_name,'_',' ');
            figure('name',feature_plot_name,'visible','off');
            try
                p=plot(1:numel(maj_plot),maj_plot,1:numel(maj_plot),sorted_feature_values);
                legend('Majority value','New values')
                title(strcat('New feature'," '",feature_plot_name,"'",' evolution'));
                xlabel('ROI index');
                ylabel('Feature value');
                figHandles = findobj('Type', 'figure');                
                %                 p=plot(sorted_volumes,sorted_feature_values);
                if ~isdir(strcat('features_from_majority_sorted_by_volume/',all_features_folders(features_folder_index).name,'/',feature_type,'/',feature_name_complement));
                    mkdir(strcat('features_from_majority_sorted_by_volume/',all_features_folders(features_folder_index).name,'/',feature_type,'/',feature_name_complement));
                end
             saveas(figHandles(1),strcat('features_from_majority_sorted_by_volume/',all_features_folders(features_folder_index).name,'/',feature_type,'/',feature_name_complement,'/',feature_plot_name,'.png'));
                close all
            catch
                %Unprocessed features such as moran will be caught here, just
                %ignore it
            end
        end
    end
end
