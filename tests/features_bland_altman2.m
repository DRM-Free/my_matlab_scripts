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

function features_bland_altman2()
%Getting full list of features names
all_features_folders=dir('features_from_original/*.mat');
all_features_files_original=dir(strcat('features_from_original/',all_features_folders(1).name,'/*.mat'));
load(strcat('features_from_original/',all_features_folders(1).name,'/',all_features_files_original(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics

patient_names={};
for patient_index=1:numel(all_features_folders)
    patient_name=all_features_folders(patient_index).name;
    patient_name=strsplit(patient_name,'.');
    patient_name=patient_name(1);
    patient_names(patient_index)=patient_name;
end

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
    else
        feature_name_complement='';
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
    
     % BA plot paramters
        ROI_Types={'Original ROI','New ROI'};
        gnames = {ROI_Types,patient_names}; % names of groups in data {dimension 1 and 2}
        label = {'Original ROIs','New ROIs'}; % Names of data sets
        corrinfo = {'n','SSE','r2','eq'}; % stats to display of correlation scatter plot
        BAinfo = {'RPC(%)','ks'}; % stats to display on Bland-ALtman plot
        limits = 'auto'; % how to set the axes limits
        if 0 % colors for the data sets may be set as:
            colors = 'br';      % character codes
        else
            colors = [0 0 1;... % or RGB triplets
                1 0 0];
        end
        try
    feature_plot_name=strrep(all_features{feature_index},'_',' ');
    feature_split_name=strsplit(feature_plot_name,'.');
    feature_name=feature_split_name{end};
            tit = feature_name; % figure title

        % Generate figure with numbers of the data points (patients) and fixed
        % Bland-Altman difference data axes limits
        BlandAltman(sorted_original_feature_all_patients, interpolated_majority_feature_all_patients,label,[tit ' (numbers, forced 0 intercept, and fixed BA y-axis limits)'],gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits,'colors',colors,'symbols','Num','baYLimMode','square','forceZeroIntercept','on','baStatsMode','Gaussian')
                    figHandles = findobj('Type', 'figure');                
                %                 p=plot(sorted_volumes,sorted_feature_values);
                if ~isdir(strcat('Bland_Altman_plot/',feature_type,'/',feature_name_complement));
                    mkdir(strcat('Bland_Altman_plot/',feature_type,'/',feature_name_complement));
                end
             saveas(figHandles(1),strcat('Bland_Altman_plot/',feature_type,'/',feature_name_complement,'/',feature_plot_name,'.png'));
                close all
        catch
        fprintf('A feature stats failed to be processed : %s',all_features{feature_index});
    end

end
end