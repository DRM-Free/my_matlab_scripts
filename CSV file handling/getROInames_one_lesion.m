%This script is intended for bare reading of RTstruct.dcm metadata in order
%to identify where different ROIs lay in it's structure. (and eventually
%export these elements for being used in processing)
function [CTroisNames,PTroisNames]= getROInames_one_lesion(lesionDir)
addBraces=true;
keepAllROIS=true;
CTroisNames="";
PTroisNames="";
try
    CTInfo = dicominfo(strcat(lesionDir,'/CT/RTstruct.dcm'));
    PTInfo = dicominfo(strcat(lesionDir,'/PET/RTstruct.dcm'));
    CTROIsStruct=fieldnames(CTInfo.StructureSetROISequence);
    CTROIsStruct=CTROIsStruct.';
    PTROIsStruct=fieldnames(PTInfo.StructureSetROISequence);
    PTROIsStruct=PTROIsStruct.'
catch
    fprintf("Dicom info failed to be extracted\nFail for lesion :\n%s\n",lesionDir);
    CTroisNames=[];
    PTroisNames=[];
    return
end
fprintf("Browsing patient data with ID : %s\n",CTInfo.PatientID);

for PTFieldName=PTROIsStruct
    PTname=PTInfo.StructureSetROISequence.(PTFieldName{1}).ROIName;
    if addBraces
        PTname=strcat('{',PTname);
        PTname=strcat(PTname,'}');
    end
    if ~keepAllROIS
        findAuto=strfind({PTname},"1auto");
        findVis=strfind({PTname},"1vis");
        if ~(isequal(findAuto{1},[]) & (isequal(findVis{1},[]))) %We only keep vis and auto ROIs
            if PTroisNames(1)==""
                PTroisNames(1)=PTname;
            else
                PTroisNames(end+1)=PTname;
            end
        else
            if PTroisNames(1)==""
                PTroisNames(1)="Discarded";
            else
                PTroisNames(end+1)="Discarded";
            end
        end
    else
        if PTroisNames(1)==""
            PTroisNames(1)=PTname;
        else
            PTroisNames(end+1)=PTname;
        end
    end
end
for CTFieldName=CTROIsStruct
    CTname=CTInfo.StructureSetROISequence.(CTFieldName{1}).ROIName;
    if addBraces
        CTname=strcat('{',CTname);
        CTname=strcat(CTname,'}');
    end
    if ~keepAllROIS
        findAuto=strfind({CTname},"1auto");
        findVis=strfind({CTname},"1vis");
        if ~(isequal(findAuto{1},[]) & (isequal(findVis{1},[]))) %We only keep 1vis and auto ROIs
            if CTroisNames(1)==""
                CTroisNames(1)=CTname;
            else
                CTroisNames(end+1)=CTname;
            end
        else
            if CTroisNames(1)==""
                CTroisNames(1)="Discarded";
            else
                CTroisNames(end+1)="Discarded";
            end
        end
    else
        if CTroisNames(1)==""
            CTroisNames(1)=CTname;
        else
            CTroisNames(end+1)=CTname;
        end
    end
end
%Remove cells that were not written ie when vis or auto was not found
CTroisNames=CTroisNames.';
PTroisNames=PTroisNames.';
CTroisNames=CTroisNames(CTroisNames~="Discarded");
PTroisNames=PTroisNames(PTroisNames~="Discarded");
end