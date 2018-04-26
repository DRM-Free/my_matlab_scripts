function [dice]=diceCoefficient_distrib_all_rois()
try
   load('all_vols');
catch
all_vols=get_all_vols('DATA/Lung-Multidelineation-05_CT.CTscan.mat');
end
pairs=gen_pairs_1D(size(all_vols,1));
for pair=1:numel(pairs(1))
    pair_Indices=pairs(pair,:);
    try
        dice(end+1)=dice_coeff_from_vol(all_vols{pair_Indices(1)},all_vols{pair_Indices(2)});
    catch
        dice=dice_coeff_from_vol(all_vols{pair_Indices(1)},all_vols{pair_Indices(2)});
    end
end
end