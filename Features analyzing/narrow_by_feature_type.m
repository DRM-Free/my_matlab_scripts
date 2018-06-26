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

function [kept_indices,narrowed_names_list]=narrow_by_feature_type(names_list,feature_type)
kept_indices=[];
for feature_number=1:numel(names_list)
    %     feature_name=names_list{feature_number};
    feature_name=names_list{feature_number}{1};
    cur_feature_type=strsplit(feature_name,'.');
    cur_feature_type=cur_feature_type(1);
    if isequal(feature_type,cur_feature_type{1})
        kept_indices(end+1)=feature_number;
        try
            narrowed_names_list(end+1)={feature_name};
        catch
            narrowed_names_list={feature_name};
        end
    end
end
if exist('narrowed_names_list','var')==1
    narrowed_names_list=narrowed_names_list.';
else
    narrowed_names_list={}
end
end
