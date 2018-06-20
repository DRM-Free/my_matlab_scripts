%MIT License

%Copyright (c) 2018 Anaël Leinert

%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:

%The above copyright notice and this permission notice shall be included in all
%copies or substantial portions of the Software

function classify_features(features_classification_elements)
%Extract classification elements
mvt=features_classification_elements.mvt;
vvt=features_classification_elements.vvt;
met=features_classification_elements.met;
vet=features_classification_elements.vet;
features=features_classification_elements.features;

%Narrowing by feature type
[morph_indices,~]=narrow_by_feature_type(features,'morph');
[stat_indices,~]=narrow_by_feature_type(features,'stats');

mvt_stat=mvt(stat_indices);
mvt_morph=mvt(morph_indices);

vvt_stat=vvt(stat_indices);
vvt_morph=vvt(morph_indices);

met_stat=met(stat_indices);
met_morph=met(morph_indices);

vet_stat=vet(stat_indices);
vet_morph=vet(morph_indices);

features_stat=features(stat_indices);
features_morph=features(morph_indices);

% Sort features according to mean variation

[met_stat_sorted, met_stat_order] = sort(met_stat);
vvt_stat_sorted=vvt_stat(met_stat_order);
vet_stat_sorted=vet_stat(met_stat_order);
mvt_stat_sorted=mvt_stat(met_stat_order);


[met_morph_sorted, met_morph_order] = sort(met_morph);
vvt_morph_sorted=vvt_morph(met_morph_order);
vet_morph_sorted=vet_morph(met_morph_order);
mvt_morph_sorted=mvt_morph(met_morph_order);

figure('Name','Statistics features classification indexes')
p_stat=plot(met_stat_sorted), hold on, p_stat(2)=plot(vvt_stat_sorted/10), hold on,p_stat(3)=plot(vet_stat_sorted/10),hold on,
p_stat(4)=plot(mvt_stat_sorted);

p_stat(1).Color='Blue';
p_stat(1).LineWidth=2;
p_stat(2).Color='Cyan';
p_stat(2).LineWidth=2;
p_stat(3).Color='Magenta';
p_stat(3).LineWidth=2;
p_stat(4).Color='Yellow';
p_stat(4).LineWidth=2;

figure('Name','Morphological features classification indexes')
p_morph=plot(met_morph_sorted), hold on, p_morph(2)=plot(vvt_morph_sorted/100), hold on,p_morph(3)=plot(vet_morph_sorted/100),hold on,
p_morph(4)=plot(mvt_morph_sorted);

p_morph(1).Color='Blue';
p_morph(1).LineWidth=2;
p_morph(2).Color='Cyan';
p_morph(2).LineWidth=2;
p_morph(3).Color='Magenta';
p_morph(3).LineWidth=2;
p_morph(4).Color='Yellow';
p_morph(4).LineWidth=2;

end
