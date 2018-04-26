function [all_dice]=diceCoefficient_distrib_all_rois()

% all_data=struct;
% all_data.name='Lung-Multidelineation-05_CT.CTscan.mat';
% cur_data=1;

all_data=dir('DATA/*.mat')
for cur_data=1:numel(all_data)
all_vols=get_all_vols(strcat('DATA/',all_data(cur_data).name));
pairs=gen_pairs_1D(size(all_vols,1));
if numel(pairs(:,1))>45
    %It appears that an abnormally big number of ROIs were introduced
    %somehow. This needs further investigation
    % example : Lung-Multidelineation-08_CT.CTscan.mat
end
for pair=1:numel(pairs(:,1))
    pair_Indices=pairs(pair,:);
    try
        dice(end+1)=dice_coeff_from_vol(all_vols{pair_Indices(1)},all_vols{pair_Indices(2)});
    catch
        dice=dice_coeff_from_vol(all_vols{pair_Indices(1)},all_vols{pair_Indices(2)});
    end
end
try
    all_dice(cur_data)={dice};
catch
    all_dice={dice};
end
clear dice;
fprintf('%i of %i data files were processed\n',cur_data,numel(all_data));
end
end