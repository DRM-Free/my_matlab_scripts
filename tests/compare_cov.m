function [cov_ratio_all,mean_ratio_all,all_features]=compare_cov
all_features_folders=dir('features_from_original/*.mat');
all_features_files_original=dir(strcat('features_from_original/',all_features_folders(1).name,'/*.mat'));
load(strcat('features_from_original/',all_features_folders(1).name,'/',all_features_files_original(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics
ignored_patients=[];
skipped_features=2; %skipping volume and approx volume as they are constrained features
ignored_features_indices=[];
cov_ratio_all=[];
mean_ratio_all=[];
all_features=all_features(1+skipped_features:end); %keeping only the first 100 features
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
            ignored_features_indices(end+1)=feature_index;
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
           %This patient has a different number of given ROIs than others.
           continue %Ignoring
        end
    end
    
    feature_plot_name=strrep(all_features{feature_index},'_',' ');
    feature_split_name=strsplit(feature_plot_name,'.');
    feature_type=feature_split_name{1};
    if isequal(feature_type,'texture')
        feature_name_complement=strcat(feature_split_name{2},'__',feature_split_name{3},'/');
        scale=strsplit(feature_name_complement,'scale');
        scale=scale{2};
        scale=scale(1);
        if ~isequal(scale,'1')
            ignored_features_indices(end+1)=feature_index;
            continue
        end
    end
    %Process coefficient of variation
    mean_new=mean(sorted_majority_feature_values);
    mean_orig=mean(sorted_original_feature_values);
    mean_ratio=mean_new/mean_orig;
    cov_new=mean_new/std(sorted_majority_feature_values);
    cov_orig=mean_orig/std(sorted_original_feature_values);
    cov_ratio=cov_new/cov_orig;
    cov_ratio_all(end+1)=cov_ratio;
    mean_ratio_all(end+1)=mean_ratio;
end

all_features(ignored_features_indices)=[];
% [kept_indices,narrowed_names_list]=narrow_by_feature_type(all_features,'morph')
% cov_morph=cov_all(kept_indices);
keep cov_ratio_all mean_ratio_all all_features
save('COV workspace')
end