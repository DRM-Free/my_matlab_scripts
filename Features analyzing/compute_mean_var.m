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
