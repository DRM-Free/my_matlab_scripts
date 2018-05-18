function [rois_features]=append_features(rois_features,features_folder,file_nametag)

chosen_features_files={};
all_features_files=dir(strcat(features_folder.folder,'/',features_folder.name,'/*.mat'));
all_features_files=all_features_files.';

%Select the desired features files to be extracted
for feature_file=all_features_files
    name=feature_file.name;
    if contains(name,file_nametag)
        chosen_features_files(end+1)={name};
    end
end
clear name feature_file all_features_files file_nametag

%Get all features names
load(strcat(features_folder.folder,'/',features_folder.name,'/',chosen_features_files{1}));
concatenated_field_names=fieldnamesr(radiomics.image);
separated_features_names=separate_field_names(concatenated_field_names);
clear radiomics;

for chosen_features_file=chosen_features_files
    load(strcat(features_folder.folder,'/',features_folder.name,'/',chosen_features_file{1}));
    for features_name=1:length(separated_features_names)
        separated_name=separated_features_names{features_name};
        feature_value=radiomics.image.(separated_name{1});
        
        %Now get all the way down the sub structures to the sought feature
        %value
        field_pos=2;
        while isstruct(feature_value)
            feature_value=feature_value.(separated_name{field_pos});
            field_pos=field_pos+1;
        end
        
        new_field_name=separated_features_names{features_name}{end};
        feature_type=separated_name{1};
        
        if isequal(feature_type,'texture') %This is a texture feature so we need to sort by param set
            texture=true;
            param_set=separated_name{3};
        else
            texture=false;
        end
        
        feature_type=strrep(feature_type,'_3D','');
        new_field_name=strrep(new_field_name,feature_type,'');
        try
            if ~texture
                rois_features.(feature_type).(new_field_name)(end+1)=feature_value;
            else
                new_field_name=strrep(new_field_name,param_set,'');
                new_field_name=strrep(new_field_name,'____','__');
                rois_features.(feature_type).(new_field_name).(param_set)(end+1)=feature_value;
            end
        catch
            if ~texture
                rois_features.(feature_type).(new_field_name)=feature_value;
            else
                new_field_name=strrep(new_field_name,param_set,'');
                new_field_name=strrep(new_field_name,'____','__');
                rois_features.(feature_type).(new_field_name).(param_set)=feature_value;
            end
        end
    end
end
end