%This scipt is intended for bare reading of RTstruct.dcm metadata in order
%to identify where different ROIs lay in it's structure. (and eventually
%export these elements for being used in processing)
clear all;
close all;
clc;
allRTs=dir('RTs');
wP=pwd;
cd('RTs');
nElem = numel(allRTs);
nROIs=0;
for i = 3:nElem
    try
        info = dicominfo(allRTs(i).name);
        ROIsStruct=info.StructureSetROISequence;
        nROIs=numel(ROIsStruct);
    catch
        fprintf("Dicom info failed to be extracted\n",allRTs(i).name);
    end
    fprintf("Browsing patient data with ID : ");
    fprintf(info.PatientID);
    fprintf("\n");
    fprintf("\n");
    for j=1:14
        fprintf("ROI found with name : ");
        curname = ['Item_' num2str(j)];
        fprintf(ROIsStruct.(curname).ROIName); %braces aroud curname are important. It serves for dynamic estimation of field
        fprintf("\n");
    end
    %We still need to try to assess the case when there are more ROIs in it
            fprintf("\n");
end

cd(wP);