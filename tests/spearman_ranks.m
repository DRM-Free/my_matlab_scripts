function spearman_ranks
all_original_data=dir('features_from_majority/*.mat');
all_new_data=dir('features_from_original/*.mat');
all_features_folders=dir('features_from_original/*.mat');
all_features_files_original=dir(strcat('features_from_original/',all_features_folders(1).name,'/*.mat'));
load(strcat('features_from_original/',all_features_folders(1).name,'/',all_features_files_original(1).name));
all_features=fieldnamesr(radiomics.image);
clear radiomics

%For all feature, each patient, process the feature variation coefficient.

end