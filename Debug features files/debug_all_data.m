function [invalidContour,invalidROI]=debug_all_data()
%Use this script before running script_ComputeRadiomics to test for missing
%ROIs
clearvars;
load('ROIS.mat') %Containing roisNames variable. It is generated from get_rois_names script
%It might be necessary to manually remove unused rois from roisNames before
%running this script, that is why I save it once for all it a mat file
invalidContour=struct('dataFileName','','roiName','');
invalidROI=struct('dataFileName','','roiName','');

testDatas=dir('DATA/*.mat')

badFindContour=struct('file','','roi','');
badFindROI=struct('file','','roi','');
boxString = 'box10'; % 10 voxels in all three dimensions are added to the smallest bounding box.

for testData=1:size(testDatas,1)
    fileName=testDatas(testData).name;
    lesionName=split(fileName,'.');
    modality=lesionName{2};
    lesionName=lesionName{1};
    
    
    
    load(strcat('DATA/',testDatas(testData).name));
    if modality=='CTscan';
        mod=1;
    else
        mod=2;
    end;
    
    for roiName=roisNames(mod,:)
        foundContour=false
        try
            contourString = findContour(sData,roiName);
            if ~isequal(contourString,'0')
foundContour=true;                
                            end
if ~foundContour
                fprintf("No contour found with this file :\n%s\nMissing ROI: \n%s \n\n",fileName,roiName);
                if isequal(invalidContour(1).dataFileName,'')
                    invalidContour(1)=struct('dataFileName',fileName,'roiName',roiName);
                else
                    invalidContour(end+1)=struct('dataFileName',fileName,'roiName',roiName);
                end
end
        catch
            fprintf("This file apparently has issue with findContour :\n%s\nMissing ROI: \n%s \n\n",fileName,roiName);
            contourString='0';
            if isequal(invalidContour(1).dataFileName,'')
                invalidContour(1)=struct('dataFileName',fileName,'roiName',roiName);
            else
                invalidContour(end+1)=struct('dataFileName',fileName,'roiName',roiName);
            end
        end
    end
    if foundContour
        %             if isfield(sData{2},'nrrd')
        %                 [volObjInit,roiObjInit] = getMask(sData,contourString,'nrrd',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        %             elseif isfield(sData{2},'img')
        %                 [volObjInit,roiObjInit] = getMask(sData,contourString,'img',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        %             else
        try
            [volObjInit,roiObjInit] = getROI(sData,contourString,boxString); % This takes care of the "Volume resection" step as well using the argument "box". No fourth argument means 'interp' by default.
        catch
            fprintf("This file apparently has issue with findROI :\n%s\nMissing ROI: \n%s\n\n",fileName,roiName);
            if isequal(invalidROI(1).dataFileName,'')
                invalidROI(1)=struct('dataFileName',fileName,'roiName',roiName);
            else
                invalidROI(end+1)=struct('dataFileName',fileName,'roiName',roiName);
            end
        end
        %             end
    else
        stop=1;
    end
    %         if badFindContour(1).file==''
    %             badFindContour(1)=struct('file',invalidROIs(invalidROI).dataFileName,'contour',roiName);
    %         else
    %             badFindContour(end+1)=struct('file',invalidROIs(invalidROI).dataFileName,'contour',roiName);
    %         end
    clear sData;
end
end