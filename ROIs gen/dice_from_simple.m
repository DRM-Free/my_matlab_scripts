function [dice_coeffs,kept_ROIs]=dice_from_simple(all_simple_rois,roi,shrink_thresholds,expand_thresholds,nIter)
dice_coeffs=[];
kept_ROIs=struct;

for it=1:nIter
    iter_field_name=strcat(strcat("shrink_",num2str(it)),"_iter");
    iter_field_name=char(iter_field_name);
    for sth=shrink_thresholds
        thresh_field_name=strcat(strcat("thresh_",num2str(sth)));
        thresh_field_name=strrep(thresh_field_name,'.','');
        thresh_field_name=char(thresh_field_name);
        
        compROI=all_simple_rois.(iter_field_name).(thresh_field_name).original_scale;
        
        %Processing dice coefficient
        try
            dice=dice_coeff_from_vol(roi,compROI);
        catch
        end
        dice_coeffs(end+1)=dice;
        dice_step=0.05;
        %Selecting a variety of range of ROIs (with different dice values)
        for i=1-dice_step:-dice_step:0.4
            if (mod(dice,i)<dice_step && dice~=1)
                field_name=strcat(strcat(strcat(strcat("shrink_dice_range_",num2str(i))),'_to_'),num2str(i+dice_step));
                field_name=strrep(field_name,'.','');
                field_name=char(field_name);
                if ~isfield(kept_ROIs,field_name)
                    kept_ROIs.(field_name)={find(compROI)};
                end
                break
            end
        end
    end
    iter_field_name=strcat(strcat("expand_",num2str(it)),"_iter");
    iter_field_name=char(iter_field_name);
    for eth=expand_thresholds
        thresh_field_name=strcat(strcat("thresh_",num2str(eth)));
        thresh_field_name=strrep(thresh_field_name,'.','');
        thresh_field_name=char(thresh_field_name);
        
        compROI=all_simple_rois.(iter_field_name).(thresh_field_name).original_scale;
        try
            dice=dice_coeff_from_vol(roi,compROI);
        catch
        end
        dice_coeffs(end+1)=dice;
        for i=1-dice_step:-dice_step:0.4
            if (mod(dice,i)<dice_step && dice~=1)
                field_name=strcat(strcat(strcat(strcat("expand_dice_range_",num2str(i))),'_to_'),num2str(i+dice_step));
                field_name=strrep(field_name,'.','');
                field_name=char(field_name);
                if ~isfield(kept_ROIs,field_name)
                    kept_ROIs.(field_name)={find(compROI)};
                end
                break
            end
        end
    end
end
end
