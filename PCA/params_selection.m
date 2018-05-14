function [kept_entries]=params_selection(features_file)
load(features_file);
texture=radiomics.image.texture;
texture_types=fieldnames(texture).';
kept_entries=struct;
for texture_type=texture_types
    type=texture.(texture_type{1}); %Assuming all features of this type are processed for each sets of parameters
    params_sets=fieldnames(type);
    params_sets=params_sets.';
    texture_features_names=fieldnames(type.(params_sets{1})).';
    for texture_features_name=texture_features_names
        values=[];
        params={};
        kept_params=[];
        for params_set=params_sets
            values(end+1)=type.(params_set{1}).(texture_features_name{1});
            params(end+1)=params_set; %Just saving params in the same orders as values
            dev=std(values);
            cv=conv(sort(values),[1 -1],'same');
            kept_params=cv>dev/8; %This will influence the number of kept params.
            kept_params(end)=1; %Always keep last param as it is an extremum regardless and it will never be kept with the previous line
            kept_params(1)=1;
        end
        kept_entries.(texture_type{1}).(texture_features_name{1})=struct('values',values,'params',{params},'kept_params',kept_params);
    end
end
end

%In order to test kept values, run:
%plot(sort(kept_entries.glcm.Fcm_joint_max.values));
%plot(sort(kept_entries.glcm.Fcm_joint_max.values(kept_entries.glcm.Fcm_joint_max.kept_params)));