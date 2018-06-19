function features_bland_altman_plot()
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
ignored_patients=[];
for feature_index=1:numel(all_features)
    sorted_original_features_all_patients=zeros(numel(all_features_folders),numel(all_features_files_original));
    interpolated_majority_features_all_patients=sorted_original_features_all_patients;
    for features_folder_index=1:numel(all_features_folders)
        all_features_files_original=dir(strcat('features_from_original/',all_features_folders(features_folder_index).name,'/*.mat'));
        all_features_files_majority=dir(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/*.mat'));
        
        %all_features_file contains the names of all ROIs types (majority, expands and schinks)
        
        %Sorting original and new ROIs volumes values
        unsorted_volumes_original=[];
        for feature_file_index=1:numel(all_features_files_original)
            load(strcat('features_from_original/',all_features_folders(features_folder_index).name,'/',all_features_files_original(feature_file_index).name));
            cur_vol=radiomics.image.morph_3D.scale2.Fmorph_vol;
            unsorted_volumes_original(end+1)=cur_vol;
        end
        [sorted_volumes_original,sorted_indexes_original]=sort(unsorted_volumes_original);
        
        unsorted_volumes_majority=[];
        for feature_file_index=1:numel(all_features_files_majority)
            load(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/',all_features_files_majority(feature_file_index).name));
            cur_vol=radiomics.image.morph_3D.scale2.Fmorph_vol;
            unsorted_volumes_majority(end+1)=cur_vol;
        end
        [sorted_volumes_majority,sorted_indexes_majority]=sort(unsorted_volumes_majority);
        
        
        %     Finding ordered features values for original ROIs
        sorted_original_feature_values=[];
        for sorted_index_number=1:numel(sorted_indexes_original)
            feature_index_sorted=sorted_indexes_original(sorted_index_number);
            load(strcat('features_from_original/',all_features_folders(features_folder_index).name,'/',all_features_files_original(feature_index_sorted).name));
            cur_orig_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            clear radiomics
            if ~isequal(cur_orig_value,[])
                sorted_original_feature_values(end+1)=cur_orig_value;
            end
        end
        if isequal(sorted_original_feature_values,[])
            continue %Ignore unprocessed features
        end
        
        %     Finding ordered features values both for new ROIs
        sorted_majority_feature_values=[];
        for sorted_index_number=1:numel(sorted_indexes_majority)
            feature_index_sorted=sorted_indexes_majority(sorted_index_number);
            load(strcat('features_from_majority/',all_features_folders(features_folder_index).name,'/',all_features_files_majority(feature_index_sorted).name));
            cur_new_value=get_inclusive_field(radiomics.image,all_features{feature_index});
            clear radiomics
            if ~isequal(cur_new_value,[])
                sorted_majority_feature_values(end+1)=cur_new_value;
            end
        end
        
        %Adding sorted features for this patient
        [~,uniq_ind]=unique(sorted_volumes_majority);
        try
            new_features_interp=interp1(sorted_volumes_majority(uniq_ind),sorted_majority_feature_values(uniq_ind),sorted_volumes_original);
            sorted_original_features_all_patients(features_folder_index,:)=sorted_original_feature_values(:);
            interpolated_majority_features_all_patients(features_folder_index,:)=new_features_interp(:);
        catch
            ignored_patients(end+1)=features_folder_index;
        end
    end
    
%     new_features_interp_all=
%     original_features_all
    
    %p=plot((new_features_interp+sorted_original_feature_values)/2,new_features_interp-sorted_original_feature_values,'.k');
    feature_plot_name=strrep(all_features{feature_index},'_',' ');
    feature_split_name=strsplit(feature_plot_name,'.');
    feature_name=feature_split_name{end};
    ROI_Types={'Original ROI','New ROI'}
    
    % BA plot paramters
    tit = feature_name; % figure title
    gnames = {ROI_Types,patient_names}; % names of groups in data {dimension 1 and 2}
    label = {'Original ROIs','New ROIs'}; % Names of data sets
    corrinfo = {'n','SSE','r2','eq'}; % stats to display of correlation scatter plot
    BAinfo = {'RPC(%)','ks'}; % stats to display on Bland-ALtman plot
    limits = 'auto'; % how to set the axes limits
    if 1 % colors for the data sets may be set as:
        colors = 'br';      % character codes
    else
        colors = [0 0 1;... % or RGB triplets
            1 0 0];
    end
    
% Generate figure with numbers of the data points (patients) and fixed
% Bland-Altman difference data axes limits
% BlandAltman(sorted_original_features_all_patients, interpolated_majority_features_all_patients,label,[tit ' (numbers, forced 0 intercept, and fixed BA y-axis limits)'],gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits,'colors',colors,'symbols','Num','baYLimMode','square','forceZeroIntercept','on')

% Repeat analysis using non-parametric analysis, no warning should appear.
BAinfo = {'RPCnp','ks'};
[cr, fig, statsStruct] = BlandAltman(sorted_original_features_all_patients, interpolated_majority_features_all_patients,label,[tit ' (using non-parametric stats)'],gnames,'corrInfo',corrinfo,'baInfo',BAinfo,'axesLimits',limits,'colors',colors,'baStatsMode','non-parametric');

    close all;
    
    
end
end