function get_radiomoics_mice_data()
load('mice_data/imParams.mat');
im_param_MR=imParams.MRscan;
mice_folders=dir(char("mice_data/**/mouse*"));
lesions_tags={"roi2","roi4"};
slices_tags={"sl1","sl2","sl3"};

for mouse_folder_index=1:numel(mice_folders)
    %here we need to retrieve the 3d matrix from csv files
    for lesion_tag=lesions_tags
        vol_file=strcat(mice_folders(mouse_folder_index).folder,"/",...
            mice_folders(mouse_folder_index).name,"/",lesion_tag{1},'_vol.mat');
        if exist(vol_file,'file')
            load(vol_file);
        else
            for slices_tag=slices_tags
                slice_file=dir(char(strcat(mice_folders(mouse_folder_index).folder,"/",...
                    mice_folders(mouse_folder_index).name,"/*",lesion_tag{1},"_",slices_tag{1},"*")));
                if exist('mat','var')
                    mat(:,:,end+1)=csvread(strcat(slice_file.folder,"/",slice_file.name));
                else
                    mat(:,:,1)=csvread(strcat(slice_file.folder,"/",slice_file.name));
                end
            end
            save(vol_file,'mat');
        end
        spatial_ref=imref3d(size(mat),0.3,0.3,1);
        roi=mat;
        roi(roi~=0)=1;
        roi_obj=struct('data',roi,'spatialRef',spatial_ref);
        vol_obj=struct('data',mat,'spatialRef',spatial_ref);
        %Voxel dimensions : 300 micro_meter * 300 micro_meter * 1 mm
        clear mat
        
        %Compute radiomics features
        radiomics=get_radiomics_one_roi(vol_obj,roi_obj,im_param_MR);
        
        %Generate name of file to be saved
        save_name=strcat(mice_folders(mouse_folder_index).folder,"/",...
            mice_folders(mouse_folder_index).name,"/",lesion_tag{1},'_radiomics.mat');
        
        %save features in proper container
        save(save_name,'radiomics');
        clear radiomics
    end
end
end