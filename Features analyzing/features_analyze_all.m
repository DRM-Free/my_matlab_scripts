function [features_classification_elements,features_mean_new,features_mean_original,features_var_new,features_var_original]=features_analyze_all(original_rois_features,new_rois_features)

%Compute mean and var of features from all original rois
[features_mean_original,features_var_original]=compute_mean_var(original_rois_features,true);

%Compute mean and var of features from all new rois
[features_mean_new,features_var_new]=compute_mean_var(new_rois_features.LungMultidelineation05_CT,false);

% all_features=fieldnamesr(features_mean_original.FEATURES); %This won't
% work because of bad naming
all_features=fieldnamesr(features_mean_new.GTV_1autoAB);

all_features=all_features.';

%Morph feature example
% feature='morph.F_sphericity';

%LocInt feature example
% feature='locInt.Floc_peak_local';

%Stat feature example
% feature='stats.Fstat_energy'; %energy is perfectly reproduced, according to xcorr

%IntHist feature example
% feature='intHist.Fih_median';

%IntVolHist feature example
% feature='intVolHist.Fivh_I10minusI90';

%texture scale 1 feature example
% feature='texture.Fcm_joint_max.scale1_algoFBN_bin64';

%Teture scale 4 feature example
% feature='texture.Fcm_joint_max.scale4_algoFBN_bin64';

% figure_name='Mean relative variation (relatively to original mean)';
% figure('Name',figure_name);
% plot(mean_relative_variation);
%
% figure_name='Var relative variation (relatively to original var)';
% figure('Name',figure_name);
%     plot(var_relative_variation);
%
% figure('Name','Original rois feature variations (relatively to mean)');
%     plot(sort(get_inclusive_field(features_original_variability.FEATURES,feature)));

% exp_curve=xcorr(sort(get_inclusive_field(features_original_variability.FEATURES,feature)),mean_relative_variation);
% exp_curve=conv(sort(get_inclusive_field(features_original_variability.FEATURES,feature)),mean_relative_variation,'full');
% figure('Name','Experimental curve');
% plot(exp_curve);


features_classification_elements=struct('amrvm',[],'aomrvm',[],'aovmrvm',[]);

processed_features=0;
for feature_name=all_features
    
    feature_name_parts=separate_field_names(feature_name);
    feature_name=feature_name{1};
    %plot_means_vars computes relative variation between the mean (respectively variance) of
    %features from new rois originating from the same original roi and the
    %features' original value (from original roi)
    try
        [mean_relative_variation,var_relative_variation]=plot_means_vars(features_mean_new,features_mean_original,features_var_new,features_var_original,feature_name);
    catch
    end
    
    features_original_variability=compute_original_variability(original_rois_features,features_mean_original);
    original_relative_variation=get_inclusive_field(features_original_variability.FEATURES,feature_name);
    
    
    %The three features classification indices described below are the mean
    %of the three functions that are plotted before this point.
    
    %Absolute mean relative variation mean indicates how much a model feature is
    %close to original values : it is an indicator of our model predictiveness in regard to a particular feature
    features_classification_elements.amrvm(end+1)=mean(abs(mean_relative_variation));
    %Absolute original mean relative relative variation mean indicates how
    %much a feature originally variates : it is an indicator of feature
    %variability (within 'natural' rois)
    features_classification_elements.aomrvm(end+1)=mean(abs(original_relative_variation));
    %Absolute original var relative variation mean indicates how much a
    %feature variance between new rois is impacted by the original roi
    %choice : it is an indicator of a feature intrinsic predictability
    %hazard
    features_classification_elements.aovmrvm(end+1)=(mean(abs(var_relative_variation)));
    
    
    %Now features only are sorted, but not their names, I should fix that
    %in order to put the features in appropriate classes.
    %Helping website :
    %https://fr.mathworks.com/matlabcentral/answers/13185-sorting-according-to-another-vector
    %     [a_sorted, a_order] = sort(A);
    % newB = B(a_order,:);
    %     feature_name=feature_name_parts{1}(end);
    %     feature_name=feature_name{1};
    %     feature_type=feature_name_parts{1}(1);
    %     feature_type=feature_type{1};
    %     if isequal(feature_type,'texture')
    %         feature_params=feature_name_parts{1}(2);
    %         feature_params=feature_params{1};
    %     else
    %         feature_params=[];
    %     end
    
    
    processed_features=processed_features+1;
    fprintf('Features processed : %i of %i\n',processed_features,length(all_features))
end
end