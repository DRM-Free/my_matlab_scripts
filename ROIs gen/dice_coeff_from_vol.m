function [dice]=dice_coeff_from_vol(vol1,vol2)
 inter = (vol1 & vol2);
 area_inter = sum(inter(:));
 area1 = sum(vol1 (:));
 area2 = sum(vol2(:));
 dice = 2*area_inter/(area1+area2);
end