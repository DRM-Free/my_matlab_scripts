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

function features_original_variability=compute_original_variability(original_rois_features,features_mean_original)
base_rois={'FEATURES'};
features_types=fieldnames(original_rois_features.(base_rois{1}));
features_types=features_types.';
features_original_variability=struct;
for base_roi=base_rois
    for features_type=features_types
        features_names=fieldnames(original_rois_features.(base_rois{1}).(features_type{1}));
        features_names=features_names.';
        for features_name=features_names
            if ~isequal(features_type{1},'texture')
                original_mean=features_mean_original.(base_roi{1}).(features_type{1}).(features_name{1});
                cur_value=original_rois_features.(base_roi{1}).(features_type{1}).(features_name{1});
                try
                    features_original_variability.(base_roi{1}).(features_type{1}).(features_name{1})(end+1)=(cur_value-original_mean)/original_mean;
                catch
                    features_original_variability.(base_roi{1}).(features_type{1}).(features_name{1})=(cur_value-original_mean)/original_mean;
                end
            else
                params_sets=fieldnames(original_rois_features.(base_roi{1}).(features_type{1}).(features_name{1}));
                params_sets=params_sets.';
                for params_set=params_sets
                    original_mean=features_mean_original.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1});
                    cur_value=original_rois_features.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1});
                    try
                        features_original_variability.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1})=(cur_value-original_mean)/original_mean;
                    catch
                        features_original_variability.(base_roi{1}).(features_type{1}).(features_name{1}).(params_set{1})(end+1)=(cur_value-original_mean)/original_mean;
                    end
                end
            end
        end
    end
end
end
