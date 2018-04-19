function [badFindContour,badFindROI]=debug_invalid_files(invalidROIs,otherInvalids,roisNames)
%Use this script when features have already been calculated and bad data
%files have already been identified with find_invalid_files.m

badFindContour=struct('file','','roi','');
badFindROI=struct('file','','roi','');
boxString = 'box10'; % 10 voxels in all three dimensions are added to the smallest bounding box.

for invalidROI=1:size(invalidROIs,2)
    load(strcat('DATA/',invalidROIs(invalidROI).dataFileName));
    if invalidROIs(invalidROI).modality=='CTscan';
        mod=1;
    else
        mod=2;
    end;
    
    for roiName=roisNames(mod,:)
        
        try
            contourString = findContour(sData,roiName);
            
        catch
            fprintf("This file apparently has issue with findContour :\n %s \n",invalidROIs(invalidROI).dataFileName);
            contourString=[];
            if isequal(badFindContour(1).file,'')
                badFindContour(1)=struct('file',invalidROIs(invalidROI).dataFileName,'roi',roiName);
            else
                badFindContour(end+1)=struct('file',invalidROIs(invalidROI).dataFileName,'roi',roiName);
            end
        end
        if ~isequal(contourString,[])
            %             if isfield(sData{2},'nrrd')
            %                 [volObjInit,roiObjInit] = getMask(sData,contourString,'nrrd',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
            %             elseif isfield(sData{2},'img')
            %                 [volObjInit,roiObjInit] = getMask(sData,contourString,'img',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
            %             else
            try
                [volObjInit,roiObjInit] = getROI(sData,contourString,boxString); % This takes care of the "Volume resection" step as well using the argument "box". No fourth argument means 'interp' by default.
            catch
                fprintf("This file apparently has issue with findROI :\n %s \n",invalidROIs(invalidROI).dataFileName);
                            if isequal(badFindROI(1).file,'')
                badFindROI(1)=struct('file',invalidROIs(invalidROI).dataFileName,'roi',roiName);
            else
                badFindROI(end+1)=struct('file',invalidROIs(invalidROI).dataFileName,'roi',roiName);
            end
            end
            %             end
        end
%         if badFindContour(1).file==''
%             badFindContour(1)=struct('file',invalidROIs(invalidROI).dataFileName,'contour',roiName);
%         else
%             badFindContour(end+1)=struct('file',invalidROIs(invalidROI).dataFileName,'contour',roiName);
%         end
    end
    clear sData;
end
end

%We need to separate CF data and PET data for debug