function organized_rois_features=organize_rois_features()
original=false; %Set to true to retrieve from original rois, false otherwise
if original
    %%If retrieving original rois features, use following nametag and features folder
    file_nametag='Lung-Multidelineation-05_CT'; %This is for partial original rois retrieval. If all shall be retrieved, set to ''
    container_folders=struct('name','FEATURES','folder','.');
else
    file_nametag=''; %Files for new rois are already organized in proper folders and no tag is necesarry for retrieval
    container_folders=dir('features_rois_simple/Lung*');
    container_folders=container_folders.';
end

organized_rois_features=struct;
chosen_features_files={};
processed_folders=0;
for container_folder=container_folders
    if ~original
        %Initialize features proper container
        features_folders=strcat(container_folder.folder,'/',container_folder.name,'/GTV*');
        features_folders=dir(features_folders);
        features_folders=features_folders.';
    else
        features_folders=container_folders;
    end
    
    %container folder name is not a valid field, let us modify it a bit
    container_folder_name=strsplit(container_folder.name,'.');
    container_folder_name=container_folder_name{1};
    container_folder_name=strrep(container_folder_name,'-','');
    
    %Iterate over folders to append all associated features
    for features_folder=features_folders
        feature_folder_name=strrep(features_folder.name,'(',''); %Field names must not contain - ( )
        feature_folder_name=strrep(feature_folder_name,')','');
        feature_folder_name=strrep(feature_folder_name,'-','_');
        feature_folder_name=strrep(feature_folder_name,' ','_');
        
        if ~isfield(organized_rois_features,container_folder_name)
            organized_rois_features.(container_folder_name)=struct;
        end
        
        if ~original
            if ~isfield(organized_rois_features.(container_folder_name),(feature_folder_name))
                organized_rois_features.(container_folder_name).(feature_folder_name)=struct;
            end
        end
        
        %Here, chosen_features_files is the list of roi names. It is processed only
        %once and then the same order is kept for adding new features values to
        %resulting lists. Therefore the first name in
        %organized_rois_features.ordered_roi_names corresponds to the first feature
        %value in each features lists.
        
        if original
            [organized_rois_features.(container_folder_name),chosen_features_files]=append_features(organized_rois_features.(container_folder_name),features_folder,file_nametag,chosen_features_files);
        else
            [organized_rois_features.(container_folder_name).(feature_folder_name),chosen_features_files]=append_features(organized_rois_features.(container_folder_name).(feature_folder_name),features_folder,file_nametag,chosen_features_files);
        end
        organized_rois_features.ordered_roi_names=chosen_features_files;
    end
    processed_folders=processed_folders+1;
    fprintf('%i out of %i data folders were processed\n',processed_folders,numel(container_folders));
end
end