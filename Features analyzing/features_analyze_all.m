function [features_mean_new,features_mean_original,features_var_new,features_var_original]=features_analyze_all(original_rois_features,new_rois_features)
[features_mean_original,features_var_original]=compute_mean_var(original_rois_features,true);
[features_mean_new,features_var_new]=compute_mean_var(new_rois_features.LungMultidelineation05_CT,false);

%Morph texture example
% feature='morph.F_sphericity';

%LocInt texture example
% feature='locInt.Floc_peak_local';

%Stat texture example
% feature='stats.Fstat_energy'; %energy is perfectly reproduced, according to xcorr

%IntHist texture example
% feature='intHist.Fih_median';

%IntVolHist texture example
feature='intVolHist.Fivh_I10minusI90';

%texture scale 1 texture example
% feature='texture.Fcm_joint_max.scale1_algoFBN_bin64';

%Teture scale 4 texture example
% feature='texture.Fcm_joint_max.scale4_algoFBN_bin64';


[mean_relative_variation,var_relative_variation]=plot_means_vars(features_mean_new,features_mean_original,features_var_new,features_var_original,feature);

features_original_variability=compute_original_variability(original_rois_features,features_mean_original);

figure_name='Mean relative variation for feature';
% figure('Name',figure_name);
% plot(mean_relative_variation);

figure_name='Var relative variation for feature';
% figure('Name',figure_name);
% plot(var_relative_variation);

% figure('Name','Original rois feature variations');
% plot(sort(get_inclusive_field(features_original_variability.FEATURES,feature)));

exp_curve=xcorr(sort(get_inclusive_field(features_original_variability.FEATURES,feature)),mean_relative_variation);
% exp_curve=conv(sort(get_inclusive_field(features_original_variability.FEATURES,feature)),mean_relative_variation,'full');
figure('Name','Experimental curve');
plot(exp_curve);
end