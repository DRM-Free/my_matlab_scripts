function [mean_relative_variation,var_relative_variation]=plot_means_vars(features_mean,features_mean_original,features_var,features_var_original,feature)
original_mean=get_inclusive_field(features_mean_original.FEATURES,feature);
original_var=get_inclusive_field(features_var_original.FEATURES,feature);
new_mean_values=[];
new_var_values=[];
base_rois=fieldnames(features_mean);
base_rois=base_rois.';
for base_roi=base_rois
    new_mean_values(end+1)=get_inclusive_field(features_mean,strcat(base_roi{1},'.',feature));
    new_var_values(end+1)=get_inclusive_field(features_var,strcat(base_roi{1},'.',feature));
end

mean_relative_variation=sort((new_mean_values-original_mean)/original_mean);
var_relative_variation=sort((new_var_values-original_var)/original_var);

end