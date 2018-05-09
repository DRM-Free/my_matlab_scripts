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
        dice=dice_coeff_from_vol(roi,all_simple_rois.(iter_field_name).(thresh_field_name));
        dice_coeffs(end+1)=dice;
        for i=0.9:-0.1:0.5
            if mod(dice,i)<0.1
                field_name=strcat(strcat(strcat(strcat("shrink_dice_range_",num2str(i))),'_to_'),num2str(i+0.1));
                field_name=strrep(field_name,'.','');
                field_name=char(field_name);
                try
                    if numel(kept_ROIs.(field_name))<2
                        kept_ROIs.(field_name)(end+1)={sparse(all_simple_rois.(iter_field_name).(thresh_field_name))};
                    end
                catch
                    kept_ROIs.(field_name)={find(all_simple_rois.(iter_field_name).(thresh_field_name))};
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
        dice=dice_coeff_from_vol(roi,all_simple_rois.(iter_field_name).(thresh_field_name));
        dice_coeffs(end+1)=dice;
        for i=0.9:-0.1:0.5
            if mod(dice,i)<0.1
                field_name=strcat(strcat(strcat(strcat("expand_dice_range_",num2str(i))),'_to_'),num2str(i+0.1));
                field_name=strrep(field_name,'.','');
                field_name=char(field_name);
                try
                    if numel(kept_ROIs.(field_name))<2
                        kept_ROIs.(field_name)(end+1)={find(all_simple_rois.(iter_field_name).(thresh_field_name))};
                    end
                catch
                    kept_ROIs.(field_name)={find(all_simple_rois.(iter_field_name).(thresh_field_name))};
                end
                break
            end
        end
    end
end
end