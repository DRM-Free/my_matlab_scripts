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

all_features_folders=dir('features_from_original/*.mat');
all_features_files=dir(strcat('features_from_original/',all_features_folders(1).name,'/*.mat'));
load(strcat('features_from_original/',all_features_folders(1).name,'/',all_features_files(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics

if ~isdir('original_features_sorted_by_volume')
    mkdir('original_features_sorted_by_volume');
end

for features_folder_index=1:numel(all_features_folders)
    all_features_files=dir(strcat('features_from_original/',all_features_folders(features_folder_index).name,'/*.mat'));
    %all_features_file contains the names of all ROIs types (majority, expands and schinks)
    if ~isdir(strcat('original_features_sorted_by_volume/',all_features_folders(features_folder_index).name))
        mkdir(strcat('original_features_sorted_by_volume/',all_features_folders(features_folder_index).name));
    end
    %We need to order features folders from the smallest ROi to the biggest
    %one in order to find a possible rupture ROI
    unsorted_volumes=[];
    for feature_file_index=1:numel(all_features_files)
        load(strcat('features_from_original/',all_features_folders(features_folder_index).name,'/',all_features_files(feature_file_index).name));
        cur_vol=radiomics.image.morph_3D.scale2.Fmorph_vol;
        unsorted_volumes(end+1)=cur_vol;
    end
    [sorted_volumes,sorted_indexes]=sort(unsorted_volumes);
    
    for feature_index=1:numel(all_features)
        sorted_feature_values=[];
        for sorted_index_number=1:numel(sorted_indexes)
            feature_index_sorted=sorted_indexes(sorted_index_number);
            load(strcat('features_from_original/',all_features_folders(features_folder_index).name,'/',all_features_files(feature_index_sorted).name));
            cur_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            clear radiomics
            if ~isequal(cur_value,[])
                sorted_feature_values(end+1)=cur_value;
            end
        end
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
            figure('name',all_features{feature_index},'visible','off');
            try
                p=plot(sorted_feature_values);
                legend('Original values');
                title(strcat('Original feature'," '",feature_plot_name,"'",' evolution'));
                xlabel('ROI index');
                ylabel('Feature value');
                figHandles = findobj('Type', 'figure');                
               if ~isdir(strcat('original_features_sorted_by_volume/',all_features_folders(features_folder_index).name,'/',feature_type,'/',feature_name_complement))
                    mkdir(strcat('original_features_sorted_by_volume/',all_features_folders(features_folder_index).name,'/',feature_type,'/',feature_name_complement));
                end
             saveas(figHandles(1),strcat('original_features_sorted_by_volume/',all_features_folders(features_folder_index).name,'/',feature_type,'/',feature_name_complement,'/',feature_plot_name,'.png'));
            
             close all
            
            catch
                %Unprocessed features such as moran will be caught here, just
                %ignore it
            end
            close all;
        end
    end
end
