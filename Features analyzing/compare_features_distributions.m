function [all_test_results]=compare_features_distributions(new_rois_features,original_rois_features)
all_features=fieldnamesr(original_rois_features.FEATURES);
all_features=all_features.';
original_rois=fieldnames(new_rois_features.LungMultidelineation05_CT);
original_rois=original_rois.';
all_test_results=struct('mean_scores',[],'var_scores',[]);
features_count=numel(all_features);
processed_features=0;
for feature_name=all_features
    feature_name=feature_name{1};
    mean_scores=[];
    var_scores=[];
    try
        all_test_results.features(end+1)={feature_name};
    catch
        all_test_results.features={feature_name};
    end
    
    for original_roi=original_rois
        original_roi=original_roi{1};
        original_distrib=get_inclusive_field(original_rois_features.FEATURES,feature_name);
        new_distrib=get_inclusive_field(new_rois_features.LungMultidelineation05_CT.(original_roi),feature_name);
        if ~isequal(original_distrib,[])
            
            if max(original_distrib==new_distrib)==0
                %Compare variances with Fisher test (Two-sample F-test)
                %                 null hypothesis : same variance
                [h_var,p_var] = vartest2(original_distrib,new_distrib);
                %h_var will be 1 if p_var<0.05
                %If h=1 then the null hypothesis of same variance is
                %rejected
                
                %Compare mean with two-sided Wilcoxon rank sum test
%                 null hypothesis : equal median
                [p_mean,h_mean,~] = ranksum(original_distrib,new_distrib);
                %h_mean will be 1 if p_mean<0.05
                %If h=1 then the null hypothesis of equal median is
                %rejected
            else %It appears that the tests fail when dealing with exact same values distribution
                %This only happens with stat_min that equals zero. In that
                %case we manually define the test results.
                h_var=1;
                h_mean=1;
                p_var=0;
                p_mean=0;
            end
            mean_scores(end+1)=h_mean;
            var_scores(end+1)=h_var;
            if isnan(h_var)
            end
        end
    end
    
    %Now apending test results. Remember that low scores correspond
    %to a high level of similarity between original and new
    %variances/medians
    all_test_results.mean_scores(end+1)=mean(mean_scores);
    all_test_results.var_scores(end+1)=mean(var_scores);
    
    processed_features=processed_features+1;
    fprintf('%i of %i features were processed\n',processed_features,features_count);
end

end