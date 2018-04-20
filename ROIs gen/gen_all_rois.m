function ROIs_all_roiObj=gen_all_rois()
dataPaths=dir('DATA/*.mat');
dataPaths=dataPaths.';
ROIs_all_roiObj=[];
for dataPath=dataPaths %For one data file featuring all rois for one patient and one modality
    
    %Generating masks (for erosion and dilation)
    
    
    %Loading data file
    load(strcat('DATA/',dataPath.name));
    fprintf("Generating rois from data :\n%s\n\n",dataPath.name);
    rois = sData{1,2}.scan.contour;
    rois=rois.';
    type=sData{1,2}.type;
    
    %Generating all new rois
    ROIs_one_roiObj=[];
    for roi=1:numel(rois) %For one roi, one patient and one modality only
        roiName=rois(roi);
        
        %Removing unused rois
        roiName=roiName.name;
        visPos = strfind(roiName,'vis');
        autoPos = strfind(roiName,'auto');
        
        if ~(isequal(autoPos,[])&isequal(visPos,[]))
            process=true;
        else
            process=false; %If image type is not recognized after that point then no ROI is processed
        end
        if process
            [volObj,roiObj] = getROI(sData,roi,'2box');
            ROIs_one_roiObj=cat(1,ROIs_one_roiObj,genROIs_tier2(roiObj)); %Here we generate only one roi per given roi at the start
            %We could put it in a for loop and do it more times
        end
    end
    clear sData;
    ROIs_all_roiObj=cat(2,ROIs_all_roiObj,ROIs_one_roiObj);
end
end