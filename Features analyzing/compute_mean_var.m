function [features_mean,features_var]=compute_mean_var(features,original)

if original
    base_rois={'FEATURES'};
    features_types=fieldnames(features.(base_rois{1}));
else
    base_rois=fieldnames(features);
    base_rois=base_rois.';
    features_types=fieldnames(features.(base_rois{1}));
end

features_types=features_types.';

for base_roi=base_rois
    for features_type=features_types
        features_names=fieldnames(features.(base_rois{1}).(features_type{1}));
        features_names=features_names.';
        for features_name=features_names
            if ~isequal(features_type{1},'texture')
                features_mean.(base_roi{1}).(features_type{1}).(features_name{1})=mean(features.(base_roi{1}).(features_type{1}).(features_name{1}));
                features_var.(base_roi{1}).(features_type{1}).(features_name{1})=var(features.(base_roi{1}).(features_type{1}).(features_name{1}));
            else
                params_sets=fieldnames(features.(base_roi{1}).(features_type{1}).(features_name{1}));
                params_sets=params_sets.';
                for params_set=params_sets
                    features_mean.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1})=mean(features.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1}));
                    features_var.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1})=var(features.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1}));
                end
            end
        end
    end
end
end