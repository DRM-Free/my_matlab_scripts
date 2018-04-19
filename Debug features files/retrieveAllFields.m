function [fieldsStruct]=retrieveAllFields(refStruct,tempStruct,addName)
%tempStruct is a temporary struct that holds all features and names added
%so far. At the ends it is all added to fieldsStruct
%addName is intended for multiple features sharing same name. If researched
%features might share same name then addname should be set at start, then
%the whole search path taken to find these feature will be added recursively
%to their names

try
    currentFields=fieldnames(refStruct);
    currentFields=currentFields.';%transposing further to a row vector
catch 
    fieldsStruct=tempStruct;
    return
end
for currentField=currentFields
    fieldIsLeaf=false;
    try
        furtherFields=fieldnames(refStruct.(currentField{1}));
    catch
        fieldIsLeaf=true;
    end
    if ~isequal(addName,"")
        %Using isequal instead of == prevents failure from comparing different size vectors
        newAddName=strcat(addName,',',currentField);
    else
        newAddName=addName;
    end
    if ~fieldIsLeaf
        tempStruct=retrieveAllFields(refStruct.(currentField{1}),tempStruct,newAddName);
    else
        if ~isequal(refStruct.(currentField{1}),NaN) %So as not to add empty fields. Warning : features that are not numerical will be discarded
            if isequal(tempStruct(1).name,[])
                tempStruct(1)=struct('name',strcat(newAddName,currentField{1}),'value',refStruct.(currentField{1}));
            else
                tempStruct(end+1)=struct('name',strcat(newAddName,currentField{1}),'value',refStruct.(currentField{1}));
            end
        end
    end
    fieldsStruct=tempStruct;
end