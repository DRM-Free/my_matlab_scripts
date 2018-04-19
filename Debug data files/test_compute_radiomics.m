function test_compute_radiomics(pathRead,pathCSV,imParams,roiTypes)
%This basically executes the rois verification part of compute_radiomics
%script

startpath = pwd;
for r = 1:numel(roiTypes)
    roiType=roiTypes{r};
    fprintf('\n    --> Testing for the "%s" roi type ... ',roiType);
    
    % READING CSV EXPERIMENT TABLE
    tableROI = readtable(['CSV/roiNames_',roiType,'.csv']);
    patientNames = getPatientNames([tableROI.PatientID,tableROI.ImagingScanName,tableROI.ImagingModality]);
    nameROI = tableROI.ROIname;
    %     if sum(contains(tableROI.Properties.VariableNames,'StructureSetName'))
    %         nameSet = tableROI.StructureSetName;
    %     else
    %         nameSet = cell(size(tableROI,1),1); % Creation of cell with empty entries.
    %     end
    for patientName=1:numel(patientNames)
        load(char(strcat('DATA/',patientNames(patientName))));
        % Computation of ROI mask
        boxString = 'box10'; % 10 voxels in all three dimensions are added to the smallest bounding box.
        %         try
        
        contourString = findContour(sData,nameROI{patientName}); % OUTPUT IS FOR EXAMPLE '3' or '1-3+2'
        
        %         catch
        %             fprintf('\nPROBLEM WITH ROI')
        %             radiomics = 'ERROR_ROI';
        %             errorROI = true;
        %         end
        
        if ~isequal(contourString,'0')
        if isfield(sData{2},'nrrd')
            [volObjInit,roiObjInit] = getMask(sData,contourString,'nrrd',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        elseif isfield(sData{2},'img')
            [volObjInit,roiObjInit] = getMask(sData,contourString,'img',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        else
            [volObjInit,roiObjInit] = getROI(sData,contourString,boxString); % This takes care of the "Volume resection" step as well using the argument "box". No fourth argument means 'interp' by default.
        end
        else
        fprintf('\nPROBLEM WITH ROI\n'); %Insert here relevant code if bad data files names must be kept
        end
        clear sData % Clear up RAM
        
    end
end
end