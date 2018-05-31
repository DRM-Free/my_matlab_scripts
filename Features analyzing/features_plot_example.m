function [morph_features_ordered,stat_features_ordered]=features_plot_example(new_rois_features,original_rois_features)
original_stat=original_rois_features.FEATURES.stats;
original_morph=original_rois_features.FEATURES.morph;
new_morph=new_rois_features.LungMultidelineation05_CT.GTV_1autoDR.morph;
new_stat=new_rois_features.LungMultidelineation05_CT.GTV_1autoDR.stats;
original_names=original_rois_features.ordered_roi_names;
new_names=new_rois_features.ordered_roi_names;

expand_position=3;
shrink_position=8;

morph_features=fieldnames(original_morph)
morph_features=morph_features.';
new_plot_morph=zeros(numel(morph_features),2);
original_plot_morph=zeros(numel(morph_features),1);

for morph_feature_number=1:numel(morph_features)
    try
        new_plot_morph(morph_feature_number,:)=[new_morph.(morph_features{morph_feature_number})(expand_position),new_morph.(morph_features{morph_feature_number})(shrink_position)];
%         original_plot_morph(morph_feature_number)=mean(new_morph.(morph_features{morph_feature_number}));
           original_plot_morph(morph_feature_number)=original_morph.(morph_features{morph_feature_number})(2);

    catch
        %some features that are never computed might cause errors here,
        %like F_moran_i
        %Just ignore this catch then
    end
end

figure('Name','Morphological features mean, dice 07 expand and shrink values')

m_shrink=(new_plot_morph(:,2)-original_plot_morph)./original_plot_morph;
m_expand=(new_plot_morph(:,1)-original_plot_morph)./original_plot_morph;
[morph_shrink_sorted,morph_order]=sort(m_shrink);
morph_expand_sorted=m_expand(morph_order);
plot_morph=plot(morph_shrink_sorted), hold on,plot_morph(2)=plot(morph_expand_sorted);

%Get the list of morph features in the same order as what is plotted
morph_features_ordered=morph_features(morph_order);

stat_features=fieldnames(original_stat)
stat_features=stat_features.';
new_plot_stat=zeros(numel(stat_features),2);
original_plot_stat=zeros(numel(stat_features),1);


for stat_feature_number=1:numel(stat_features)
    try
        new_plot_stat(stat_feature_number,:)=[new_stat.(stat_features{stat_feature_number})(expand_position),new_stat.(stat_features{stat_feature_number})(shrink_position)];
%         original_plot_stat(stat_feature_number)=mean(new_stat.(stat_features{stat_feature_number}));
           original_plot_stat(stat_feature_number)=original_stat.(stat_features{stat_feature_number})(2);

    catch
        %some features that are never computed might cause errors here,
        %like F_moran_i
        %Just ignore this catch then
    end
end

figure('Name','Statistical features mean, dice 07 expand and shrink values')

s_shrink=(new_plot_stat(:,1)-original_plot_stat)./original_plot_stat;
s_expand=(new_plot_stat(:,2)-original_plot_stat)./original_plot_stat;
[stat_shrink_sorted,stat_order]=sort(s_shrink);
stat_expand_sorted=s_expand(stat_order);
plot_stat=plot(stat_shrink_sorted), hold on,plot_stat(2)=plot(stat_expand_sorted);


%Get the list of stat features in the same order as what is plotted
stat_features_ordered=stat_features(stat_order);
end