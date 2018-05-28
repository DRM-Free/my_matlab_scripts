function [kept_indices,narrowed_names_list]=narrow_by_feature_type(names_list,feature_type)
kept_indices=[];
for feature_number=1:numel(names_list)
    feature_name=names_list{feature_number};
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