function plot_variability(all_stats_all_features)
%Get indexes of features of interest
[morph_indexes,~]=narrow_by_feature_type(all_stats_all_features.feature_name,'morph_3D');
[stat_indexes,~]=narrow_by_feature_type(all_stats_all_features.feature_name,'stats_3D');
[texture_indexes,~]=narrow_by_feature_type(all_stats_all_features.feature_name,'texture');
[intHist_indexes,~]=narrow_by_feature_type(all_stats_all_features.feature_name,'intHist_3D');

%Reshape the data
original_lesion_wise_variations=cat(1,all_stats_all_features.original_variability(:).lesion_wise_variations);
new_lesion_wise_variations=cat(1,all_stats_all_features.new_variability(:).roi_wise_variations);
original_roi_wise_variations=cat(1,all_stats_all_features.original_variability(:).roi_wise_variations);
new_lesion_roi_variations=cat(1,all_stats_all_features.new_variability(:).lesion_wise_variations);

rois_types_and_indexes=struct('type','morph','indexes',morph_indexes);
rois_types_and_indexes(2)=struct('type','stat','indexes',stat_indexes);;
rois_types_and_indexes(3)=struct('type','texture','indexes',texture_indexes);;
rois_types_and_indexes(4)=struct('type','intHist','indexes',intHist_indexes);;

%Setting save folder
if ~isdir('Features_variability')
    mkdir('Features_variability');
end

for roi_type=rois_types_and_indexes
    [sorted_original_lesion_wise_variations,solw_indexes]=sort(original_lesion_wise_variations(roi_type.indexes));
    sorted_new_lesion_wise_variations=new_lesion_wise_variations(roi_type.indexes);
    sorted_new_lesion_wise_variations=sorted_new_lesion_wise_variations(solw_indexes);
    
    [sorted_original_roi_wise_variations,solw_indexes]=sort(original_roi_wise_variations(roi_type.indexes));
    sorted_new_roi_wise_variations=new_lesion_roi_variations(roi_type.indexes);
    sorted_new_roi_wise_variations=sorted_new_roi_wise_variations(solw_indexes);
    
    
    sorted_features_names=all_stats_all_features.feature_name(roi_type.indexes);
    sorted_features_names=sorted_features_names(solw_indexes);
    
    figure('name',strcat('Lesion wise',', ',roi_type.type ,' features variations'),'visible','off')
    plot(sorted_new_lesion_wise_variations),hold on,
    plot(sorted_original_lesion_wise_variations);
    legend('new variability','original variability')
    title(strcat('Lesion wise',', ',roi_type.type ,' features variations'))
    
    figure('name',strcat('ROI wise',', ',roi_type.type ,' features variations'),'visible','off')
    plot(sorted_new_roi_wise_variations),hold on,
    plot(sorted_original_roi_wise_variations);
    legend('new variability','original variability')
    title(strcat('ROI wise',', ',roi_type.type ,' features variations'))
    figHandles = findobj('Type', 'figure');
    saveas(figHandles(2),strcat('Features_variability/Lesion wise',', ',roi_type.type ,' features variations','.png'));
    saveas(figHandles(1),strcat('Features_variability/ROI wise',', ',roi_type.type ,' features variations','.png'));
    close all
end
end
