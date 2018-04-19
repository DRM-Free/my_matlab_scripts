function [fieldsStruct]=retrieveAllFields(refStruct,tempStruct,addName)
%tempStruct is a temporary struct that holds all features and names added
%so far. At the ends it is all added to fieldsStruct
%addName is intended for multiple features sharing same name. If researched
%features might share same name then addname should be set at start, then
%the whole search path taken to find these feature will be added recursively
%to their names
refIsLeaf=false;
try
    currentFields=fieldnames(refStruct);
catch %In that case refStruct is a leaf, which means it has no sub-structures
    %If we hit a leaf then we need to add all those fields to fieldsStruct
    refIsLeaf=true;
end
if ~refIsLeaf
    currentFields=currentFields.';%transposing further to a row vector
    for currentField=currentFields
        if ~isequal(addName,"")
            %Using isequal instead of == prevents failure from comparing different size vectors
            newAddName=[addName,',',currentField];
            tempStruct=retrieveAllFields(refStruct.(currentField{1}),tempStruct,newAddName);
            %In that case we recursively call the current function again
        end
    end
else
    try
        for feature=currentFields
            if ~isequal(refStruct.(feature{1}),NaN) %So as not to add empty fields. Warning : features that are not numerical will be discarded
                if isequal(tempStruct(1).name,"")
                    tempStruct(1)=struct('name',[addName,feature{1}],'value',refStruct.(feature{1}));
                else
                    tempStruct(end+1)=struct('name',[addName,feature{1}],'value',refStruct.(feature{1}));
                end
            end
        end
    catch
        %fprintf("A struct was recognised as a leaf mistakenly : \n");
    end
end
fieldsStruct=tempStruct;
end