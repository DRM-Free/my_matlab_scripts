function [orderedFeatures,invalidFiles]=orderFeatures()
wd=pwd;
cd FEATURES;
features=dir('*.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating relevant structure where features will be stored %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

orderedStructs = struct('name',"", 'values2D',{cell(2,2)});
%Creates an array of structures, to be completed with elements from function retrieveAllFields
%fieldsStruct will contain all features names ans values. It is an array of
%structs with field1 name and field2 2D array of values(one row containing all outlines for one patient)
invalidFiles=struct('fileName',"");
sharedName="texture"; % Some texture features might share some name so we will extend their names to be unique (see retrieveAllFields.m for details)
addName="";
for fs=3:size(features)
    curFile=features(fs).name;
    cd(wd);
    cd FEATURES;
    clear radiomics; %Clearing features for next load
    load(curFile);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Getting patient and roi names %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    patientName=split(curFile,'_');
    patientName=patientName(1,:);
    outlineName=split(curFile,'(');
    outlineName=outlineName(2,:);
    outlineName=split(outlineName,')');
    outlineName=outlineName(1,:);
    patientName=patientName{1}; %Converting cell to char
    outlineName=outlineName{1};
    %     patientName=[patientName]; %Converting char to string
    %     outlineName=convertCharsToStrings(outlineName);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Getting all features for this patient and this roi %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        featuresTypes=fieldnames(radiomics.image);%featuresTypes={morph locInt stats intHist intVolHist texture};
    catch
        fprintf("Current radiomics structure has no field image.\n");
        fprintf("Invalid file : ");
        fprintf('%s',curFile);
        fprintf("\n");
        featuresTypes={};
        if invalidFiles(end).fileName=="";
            invalidFiles(end).fileName=curFile;
        else
            invalidFiles(end+1)=struct('fileName',curFile);
        end
    end
    featuresTypes=featuresTypes.'; %transposing featuresTypes to a row vector
    for featureType=featuresTypes
        if featureType==sharedName
            addName=sharedName;
        else
            addName="";
        end
        fprintf("Retrieving features of type %s \n",featureType{1});
        addFeatures=[struct('name','','value',0)]; %creating empty array of struct
        %The first element of struct array must have same fields as
        %expected in the whole array, so we just create it with an empty
        %name field that indicates this first struct must be replaced with real data later
        cd(wd);
        addFeatures=retrieveAllFields(radiomics.image.(featureType{1}),addFeatures,addName); %this will be an array of struct with fields name and value (only one value)
        %%Todo%% Later add a parameter to this function so that texture
        %%type features get their names completed by their calculation
        %%parameters to avoid identical names occuring
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Adding a new struct to orderedStruct every time we find a feature with new name %
        % Note : this can be slightly slow, but this ensures only features that are actually calculated are added %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for addFeature=addFeatures
            addnewField=true; %If no feature matching addFeatures is found in orderedStruct then add it to orderedStruct
            %Warning : If several features share exact same name then only
            %the first one found will be added as a new field and all
            %subsequent values of each feature will be added in that same
            %field. To avoid that, we tend to change features names to
            %match their specificity ie calculation parameters.
            if orderedStructs(1).name~=""
                for orderedStruct=orderedStructs
                    if isequal(addFeature.name,orderedStruct.name)
                        addnewField=false; %Field already exists, now check it has patient name in first column or ROI name in first line
                        break
                    end
                end
                %else addNewField must stay to true : if orderedStructs if
                %empty, add field anyway
            end
            
            if addnewField
                if orderedStructs(1).name==""
                    orderedStructs(1)=struct('name',addFeature.name, 'values2D',{cell(2,2)});
                else
                    orderedStructs(end+1)=struct('name',addFeature.name, 'values2D',{cell(2,2)});
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Now that field is added just fill it with proper values %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            sizeStruct=size(orderedStructs);
            numRows=sizeStruct(2);
            for orderedStruct=1:numRows
                if isequal(addFeature.name,orderedStructs(orderedStruct).name)
                    orderedStructs(orderedStruct).values2D=addToOrderFeatures(orderedStructs(orderedStruct).values2D,patientName,outlineName, addFeature.value);
                    break
                end
            end
        end
    end
end
orderedFeatures=orderedStructs;
cd(wd)
end