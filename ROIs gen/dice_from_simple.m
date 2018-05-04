function [dice_coeffs]=dice_from_simple(all_simple_rois,roi,shrink_thresholds,expand_thresholds,nIter)
dice_coeffs=[];
for it=1:nIter
    iter_field_name=strcat(strcat("shrink_",num2str(it)),"_iter");
    iter_field_name=char(iter_field_name);
    for sth=shrink_thresholds
        thresh_field_name=strcat(strcat("thresh_",num2str(sth)));
        thresh_field_name=strrep(thresh_field_name,'.','');
        thresh_field_name=char(thresh_field_name);
        dice=dice_coeff_from_vol(roi,all_simple_rois.(iter_field_name).(thresh_field_name));
        dice_coeffs(end+1)=dice;
    end
    iter_field_name=strcat(strcat("expand_",num2str(it)),"_iter");
    iter_field_name=char(iter_field_name);
    for eth=expand_thresholds
        thresh_field_name=strcat(strcat("thresh_",num2str(eth)));
        thresh_field_name=strrep(thresh_field_name,'.','');
        thresh_field_name=char(thresh_field_name);
        dice=dice_coeff_from_vol(roi,all_simple_rois.(iter_field_name).(thresh_field_name));
        dice_coeffs(end+1)=dice;
    end
end
end