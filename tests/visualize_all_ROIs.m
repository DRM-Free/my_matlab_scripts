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

function visualize_all_ROIs(newROIs)
gen_type=fieldnames(newROIs);
all_vols=[];
for gen_type_index=1:numel(gen_type)
    thresh=fieldnames(newROIs.(gen_type{gen_type_index}));
    for thresh_index=1:numel(thresh)
        vol_value=numel(find(newROIs.(gen_type{gen_type_index}).(thresh{thresh_index}).original_scale));
        all_vols(end+1)=vol_value;
    end
end
close all
plot(all_vols,'*');
end