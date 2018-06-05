function [kept_morph,kept_stat]=classify_features_stats(all_test_results)
%Extract classification elements
mean_scores=all_test_results.mean_scores;
var_scores=all_test_results.var_scores;
features=all_test_results.features;

%Narrowing by feature type
[morph_indices,~]=narrow_by_feature_type(features,'morph');
[stat_indices,~]=narrow_by_feature_type(features,'stats');

mean_scores_stat=mean_scores(stat_indices);
mean_scores_morph=mean_scores(morph_indices);

var_scores_stat=var_scores(stat_indices);
var_scores_morph=var_scores(morph_indices);

features_stat=features(stat_indices);
features_morph=features(morph_indices);


% Sort stat features according to mean score
[mean_scores_stat_sorted, mean_scores_stat_order] = sort(mean_scores_stat);
var_scores_stat_sorted=var_scores_stat(mean_scores_stat_order);

% Sort morph features according to mean score
[mean_scores_morph_sorted, mean_scores_stat_order] = sort(mean_scores_morph);
var_scores_morph_sorted=var_scores_morph(mean_scores_stat_order);

%defining maxima for plot normalization
max_m_stat=max(mean_scores_stat_sorted);
max_m_morph=max(mean_scores_morph_sorted);
max_v_stat=max(var_scores_stat_sorted);
max_v_morph=max(var_scores_morph_sorted);

%The indices were previously reverted from x to 1-x so well reproduced features have
%high indices
good_mean_morph=find(mean_scores_morph>0.5);
good_mean_stats=find(mean_scores_stat>0.5);
good_var_morph=find(var_scores_morph>0.5);
good_var_stats=find(var_scores_stat>0.5);
kept_morph=[];
for mean_index=good_mean_morph
    if ~isequal(find(good_var_morph==mean_index),[])
        kept_morph(end+1)=mean_index;
    end
end
kept_morph=features_morph(kept_morph);

kept_stat=[];
for mean_index=good_mean_stats
    if ~isequal(find(good_var_stats==mean_index),[])
        kept_stat(end+1)=mean_index;
    end
end
kept_stat=features_stat(kept_stat);


figure('Name','Statistics features classification scores')
p_stat=plot(mean_scores_stat_sorted), hold on, p_stat(2)=plot(var_scores_stat_sorted);

p_stat(1).Color='Blue';
p_stat(1).LineWidth=2;
p_stat(2).Color='Yellow';
p_stat(2).LineWidth=2;

figure('Name','Morphological features classification scores')
p_morph=plot(mean_scores_morph_sorted), hold on, p_morph(2)=plot(var_scores_morph_sorted);


p_morph(1).Color='Blue';
p_morph(1).LineWidth=2;
p_morph(2).Color='Yellow';
p_morph(2).LineWidth=2;

end