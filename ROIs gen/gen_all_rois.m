dataPaths=dir('DATA/*.mat');
dataPaths=dataPaths.';
for dataPath=dataPaths %For one data file featuring all rois for one patient and one modality
    
    %Loading data file
    load(strcat('DATA/',dataPath.name));
    rois = sData{1,2}.scan.contour;
    rois=rois.';
    type=sData{1,2}.type;

    
     %Generating all new rois
     ROIs_one_roiObj=[];
    for roi=1:numel(rois) %For one roi, one patient and one modality only
        process=false; %If image type is not recignized after that point then no ROI is processed
        if isequal(type,'CTscan')
    process=(~isequal(rois(roi).name,'Patient'));
    end
    
        if isequal(type,'PTscan')
    process=(~isequal(rois(roi).name,'Patient assoc 2'));
        end
     
    if process
    [volObj,roiObj] = getROI(sData,roi,'2box');
    ROIs_one_roiObj=cat(1,ROIs_one_roiObj,genROIs(roiObj)); %Here we generate only one roi per given roi at the start
    %We could put it in a for loop and do it more times
    end
    end
    clear sData;
end