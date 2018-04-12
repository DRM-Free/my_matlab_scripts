%This scipt is intended for bare reading of RTstruct.dcm metadata in order
%to identify where different ROIs lay in it's structure. (and eventually
%export these elements for being used in processing)
function [roisNames]= getROInames()
clearvars;
close all;
clc;
addBraces=true
allRTs=dir('RTs/*.dcm');
wP=pwd;
cd('RTs');
nElem = numel(allRTs);
roisNames=strings(2,14); %first line will be for CT masks and second line for PET masks
for i = 1:nElem
    try
        info = dicominfo(allRTs(i).name);
        ROIsStruct=info.StructureSetROISequence;
    catch
        fprintf("Dicom info failed to be extracted\n",allRTs(i).name);
    end
    fprintf("Browsing patient data with ID : %s,\n\nFound ROIS :\n",info.PatientID);
    for j=1:14
        curname = ['Item_' num2str(j)];
        fprintf(ROIsStruct.(curname).ROIName); %braces aroud curname are important. It serves for dynamic estimation of field
        fprintf("\n");
        curname=ROIsStruct.(curname).ROIName;
        if addBraces
            curname=strcat('{',curname);
            curname=strcat(curname,'}');
        end
        roisNames(i,j)=curname;
    end
    %We still need to try to assess the case when there are more ROIs in it
    fprintf("\n");
end
roisNames(:,1)=[]; %Just as to remove annoying 'Patient' roi for both modalities
cd(wP);
end