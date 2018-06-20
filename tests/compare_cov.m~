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

%This script is intended for comparing features COV and Mean among new ROIs
%from majority and original ROIs. lesions with an original ROI number
%different to the expected 10 are ignored (only 1 lesion) and unprocessed
%features are also dealt with (3 features concerned)
% Redundant texture features are ignored (scale 2 or more)

function [all_stats_all_features]=compare_cov
%Getting full list of features names
all_features_folders=dir('features_from_original/*.mat');
all_features_files_original=dir(strcat('features_from_original/',all_features_folders(1).name,'/*.mat'));
load(strcat('features_from_original/',all_features_folders(1).name,'/',all_features_files_original(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics


ignored_lesions_indexes=[];
skipped_features=0; %skipping volume and approx volume as they are constrained features
stop_feature=500;
ignored_features_indexes=[];
cov_ratio_all=[];
mean_ratio_all=[];
all_features=all_features(1+skipped_features:stop_feature);
skip_feature_flag=0;

for feature_index=1:numel(all_features)
    
    %Dealing with texture features
    feature_plot_name=strrep(all_features{feature_index},'_',' ');
    feature_split_name=strsplit(feature_plot_name,'.');
    feature_type=feature_split_name{1};
    
    if isequal(feature_type,'texture')
        feature_name_complement=strcat(feature_split_name{2},'__',feature_split_name{3},'/');
        scale=strsplit(feature_name_complement,'scale');
        scale=scale{2};
        scale=scale(1);
        if ~isequal(scale,'1')
            ignored_features_indexes(end+1)=feature_index;
            continue
        end
    end
    
    if skip_feature_flag==1
        skip_feature_flag=0;
        continue
    end
    sorted_original_feature_all_patients=zeros(numel(all_features_folders),numel(all_features_files_original));
    interpolated_majority_feature_all_patients=sorted_original_feature_all_patients;
    for lesion_index=1:numel(all_features_folders)
        
        %If this lesion is already recognized as to be ignored, continue
        if ~isequal(find(ignored_lesions_indexes==lesion_index),[])
            continue
        end
        
        all_features_files_original=dir(strcat('features_from_original/',all_features_folders(lesion_index).name,'/*.mat'));
        all_features_files_majority=dir(strcat('features_from_majority/',all_features_folders(lesion_index).name,'/*.mat'));
        
        %all_features_file contains the names of all ROIs types (majority, expands and schinks)
        
        %Sorting original ROIs volumes and features values
        unsorted_volumes_original=[];
        unsorted_features_original=[];
        for feature_file_index=1:numel(all_features_files_original)
            load(strcat('features_from_original/',all_features_folders(lesion_index).name,'/',all_features_files_original(feature_file_index).name));
            cur_vol=radiomics.image.morph_3D.scale2.Fmorph_vol;
            cur_orig_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            clear radiomics
            if ~isequal(cur_orig_value,[])
                unsorted_features_original(end+1)=cur_orig_value;
            else
                %This feature is unprocessed, add to ignored features
                skip_feature_flag=1;
                ignored_features_indexes(end+1)=feature_index;
                break
            end
            unsorted_volumes_original(end+1)=cur_vol;
        end
        if skip_feature_flag==1
            break
        end
        [sorted_volumes_original,sorted_indexes_original]=sort(unsorted_volumes_original);
        sorted_features_original=unsorted_features_original(sorted_indexes_original);
        
        %Sorting majority ROIs volumes and features values
        
        unsorted_volumes_majority=[];
        unsorted_features_majority=[];
        for feature_file_index=1:numel(all_features_files_majority)
            load(strcat('features_from_majority/',all_features_folders(lesion_index).name,'/',all_features_files_majority(feature_file_index).name));
            cur_vol=radiomics.image.morph_3D.scale2.Fmorph_vol;
            unsorted_volumes_majority(end+1)=cur_vol;
            cur_new_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            clear radiomics
            if ~isequal(cur_new_value,[])
                unsorted_features_majority(end+1)=cur_new_value;
            end
        end
        [sorted_volumes_majority,sorted_indexes_majority]=sort(unsorted_volumes_majority);
        sorted_features_majority=unsorted_features_majority(sorted_indexes_majority);
        
        %Adding sorted features for this patient
        [~,uniq_ind]=unique(sorted_volumes_majority);
        try
            new_features_interp=interp1(sorted_volumes_majority(uniq_ind),sorted_features_majority(uniq_ind),sorted_volumes_original);
            sorted_original_feature_all_patients(lesion_index,:)=sorted_features_original(:);
            interpolated_majority_feature_all_patients(lesion_index,:)=new_features_interp(:);
        catch
            %This patient has a different number of given ROIs than others.
            ignored_lesions_indexes(end+1)=lesion_index;
            continue %Ignoring
        end
    end
    
    %Removing lines corresponding to ignored lesions
    sorted_original_feature_all_patients(ignored_lesions_indexes,:)=[];
    interpolated_majority_feature_all_patients(ignored_lesions_indexes,:)=[];
    %Process lesion_wise variability for both original and new ROIs (one column = 1 same-related size ROI
    %for all lesions ie all smallest ROIs altogether, except they are not the same volume)
    lesion_wise_COVs_new=[];
    lesion_wise_COVs_orig=[];
    lesion_wise_means_new=[];
    lesion_wise_means_orig=[];
    for lesion_index_recap=1:size(sorted_original_feature_all_patients,1)
        %Process coefficient of variation
        %Note : One feature will not vary in certain circumstances ie stats
        %min, so the cov will be Nan
        [cov_new,mean_new]=coef_v(interpolated_majority_feature_all_patients(lesion_index_recap,:))
        [cov_orig,mean_orig]=coef_v(sorted_original_feature_all_patients(lesion_index_recap,:))
        lesion_wise_COVs_new(end+1)=cov_new;
        lesion_wise_COVs_orig(end+1)=cov_orig;
        lesion_wise_means_new(end+1)=mean_new;
        lesion_wise_means_orig(end+1)=mean_orig;
    end
    
try
    original_variability=struct();
    new_variability=original_variability;
    [original_variability.Lesion_wise_mean_variation,~]=coef_v(lesion_wise_means_orig);
    original_variability.Lesion_wise_cov_mean=mean(lesion_wise_COVs_orig);
    [original_variability.ROI_wise_mean_variation,~]=coef_v(lesion_wise_means_orig);
    original_variability.ROI_wise_cov_mean=mean(lesion_wise_COVs_orig);
    
    %Lesion wise variabilities are processed on a special way, as
    %processing the mean or cov of a column does not maks sense (Same ROIs indexes
    %are not related with each other in any way)
    new_variability.Lesion_wise_mean_variation=coef_v(lesion_wise_means_new);
    new_variability.Lesion_wise_cov_mean=mean(lesion_wise_COVs_new);
    new_variability.ROI_wise_mean_variation=coef_v(lesion_wise_means_new);
    new_variability.ROI_wise_cov_mean=mean(lesion_wise_COVs_new);
    %Process ROI_wise variability for both original and new ROIs (one column = all ROIs
    %for 1 lesion)
    
    if ~isequal(exist('all_stats_all_features'),1)
        all_stats_all_features=struct('new_variability',new_variability);
        all_stats_all_features.original_variability=original_variability;
        all_stats_all_features.feature_name={all_features(feature_index)};
    else
        all_stats_all_features.new_variability(end+1)=new_variability;
        all_stats_all_features.original_variability(end+1)=original_variability;
        all_stats_all_features.feature_name(end+1)={all_features(feature_index)};
    end
catch
    fprintf('A feature stats failed to be processed : %s',all_features(feature_index));
end
end
% [kept_indices,narrowed_names_list]=narrow_by_feature_type(all_features,'morph')
% cov_morph=cov_all(kept_indices);
keep all_stats_all_features
save('COV workspace')
end