function ICC_heat_map_non_texture(ICC_table)
mod='PET';
% mod='CT';
% ROI_origin='new';
ROI_origin='original';
% constraint='_constrained_volume';
constraint='';

ICC_table=ICC_table(~isnan(ICC_table.ICC),:);
ICC_table = sortrows(ICC_table,{'feature_type','ICC'},'ascend');
close all;
figure('units','normalized','outerposition',[0 0 1 1],'Visible','off')
ax2 = axes('Position',[0.15 0.05 0.85 0.9],'Visible','off');
axes(ax2) % sets ax1 to current axes
map = interp1([min(ICC_table.ICC);1],[1 1 1;0 0.45 0.74],min(ICC_table.ICC):0.001:1); % color map
imagesc(ICC_table.ICC);
% legend(ICC_table.feature_name,'Location','east');
colormap(map);
colorbar;
title('ICC values for non texture features');
ax1 = axes('Position',[0.05 0.05 0.15 0.9],'Visible','off');
% ax1 = axes('Position',[0.1 -0.1 0.1 1],'Visible','off');
axes(ax1) % sets ax1 to current axes
for txt_index = 1:numel(ICC_table.feature_name);
    text(0.05,1-(txt_index-0.5)/numel(ICC_table.feature_name),char(ICC_table{txt_index,'feature_name'}), 'Interpreter', 'none');
end

figHandles = findobj('Type', 'figure');
    save_name=char(strcat("../Docs/Master thesis elements/ICC_heatmap/ICC_non_texture",'_',ROI_origin,'_',mod,constraint,'.png'));
    saveas(figHandles,save_name);
clear heat_map_table
end