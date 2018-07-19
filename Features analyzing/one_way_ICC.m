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

function ICC=one_way_ICC(m)
%M is a vector of vector cells.
% The m vector single dimension must be consistent (ex : lesions)
% Data dimension in each cell is not meaningful (ex : ROI number) and thus an equal number
% of elements for each cell is not required

% The result ICC value reflects how consistent the values are among each
% groups. An ICC close 1 meaning that overall variations are linked mainly
%to groups, and an ICC closer to 0 gives more credits to individual
%variations regardless of group, thus reducing the discriminative impact of our
%studied feature in regard to the considered groups

%Process number of groups
k=size(m,2);
%Keep track of each group mean and number of individuals (shortcut for overall mean)
groups_means=[];
groups_card=[];
%Mean square within groups
SSW=0;
for group=1:k
   group_card=numel(m{group});
   groups_card(end+1)=group_card;
   %Meanwhile, process SSW component for this particular group
   group_mean=mean(m{group});
   groups_means(end+1)=group_mean;
   for ind=1:group_card
      SSW=SSW+(m{group}(ind)-group_mean)^2;
   end
end

%Process overall number of individuals
N=sum(groups_card);
%Process global mean for SSB (mean square between groups)
global_mean=sum(groups_means.*groups_card)/N;
SSB=0;
%Second iteration
for group=1:k
SSB=SSB+(groups_means(group)-global_mean)^2;
end
%Mean square between
MSB=SSB/(k-1);
%Mean square within
MSW=SSW/(N-k);
ICC=(MSB-MSW)/(MSB+(k-1)*MSW);
end