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
% feature_name='morph.F_sphericity';

%LocInt feature example
% feature_name='locInt.Floc_peak_local';

%Stat feature example
% feature_name='stats.Fstat_energy'; %energy is perfectly reproduced, according to xcorr

%IntHist feature example
% feature_name='intHist.Fih_median';

%IntVolHist feature example
% feature_name='intVolHist.Fivh_I10minusI90';

%texture scale 1 feature example
% feature_name='texture.Fcm_joint_max.scale1_algoFBN_bin64';

%Teture scale 4 feature example
% feature_name='texture.Fcm_joint_max.scale4_algoFBN_bin64';

% feature_name='texture.Fcm_clust_tend.scale1_algoFBNequal64_bin16';
% feature_name='texture.Fcm_clust_tend.scale2_algoFBNequal64_bin16';
% feature_name='texture.Fcm_clust_tend.scale3_algoFBNequal64_bin16';
% feature_name='texture.Fcm_clust_tend.scale4_algoFBNequal64_bin16';


% exp_curve=xcorr(sort(get_inclusive_field(features_original_variability.FEATURES,feature)),mean_relative_variation);
% exp_curve=conv(sort(get_inclusive_field(features_original_variability.FEATURES,feature)),mean_relative_variation,'full');
% figure('Name','Experimental curve');
% plot(exp_curve);


features_classification_elements=struct('mvt',[],'vvt',[],'met',[],'vet',[]);

processed_features=0;
for feature_name=all_features
    
    feature_name_parts=separate_field_names(feature_name);
    feature_name=feature_name{1};
    %plot_means_vars computes relative variation between the mean (respectively variance) of
    %features from new rois originating from the same original roi and the
    %features' original value (from original roi)
    [mean_relative_variation,var_relative_variation]=plot_means_vars(features_mean_new,features_mean_original,features_var_new,features_var_original,feature_name);
    
    features_original_variability=compute_original_variability(original_rois_features,features_mean_original);
    original_relative_variation=get_inclusive_field(features_original_variability.FEATURES,feature_name);
    
    
%     %Absolute original mean relative relative variation mean indicates how
%     %much a feature originally variates : it is an indicator of feature
%     %variability (within 'natural' rois)
% This element is not needed any more.
%     features_classification_elements.aomrvm(end+1)=mean(abs(original_relative_variation));
    
    %Mean evolution tendency sums up how features mean tend to evolve with new
    %rois in regard to original rois (positive values increase and negative value dercrease)
    %     This is an information about the ability the model has to generate
    %     both increased and decreased values.
    features_classification_elements.met(end+1)=mean(mean_relative_variation);
    
    %Var evolution tendency sums up how features variance tend to evolve with new
    %rois in regard to original rois (positive values increase and negative value decrease)
    features_classification_elements.vet(end+1)=mean(var_relative_variation);
    
    %Mean variance tendency
    features_classification_elements.mvt(end+1)=var(mean_relative_variation);
    
    %Var variance tendency
    features_classification_elements.vvt(end+1)=var(var_relative_variation);
    
    
    
    try
        features_classification_elements.features(end+1)={feature_name};
    catch
        features_classification_elements.features={feature_name};
    end
    %
    %     figure_name='Mean relative variation (relatively to original mean)';
    %     figure('Name',figure_name);
    %     plot(sort(abs(mean_relative_variation)));
    %
    %     figure_name='Var relative variation (relatively to original var)';
    %     figure('Name',figure_name);
    %     plot(sort(abs(var_relative_variation)));
    %
    %     figure('Name','Original rois feature variations (relatively to mean)');
    %     plot(sort(get_inclusive_field(features_original_variability.FEATURES,feature_name)));
    %
    %         close all;
    %
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
