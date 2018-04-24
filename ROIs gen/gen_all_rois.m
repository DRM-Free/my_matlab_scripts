function ROIs_all_roiObj=gen_all_rois()
dataPaths=dir('DATA/*.mat');
dataPaths=dataPaths.';
ROIs_all_roiObj=[];
for dataPath=dataPaths %For one data file featuring all rois for one patient and one modality
    
    %Generating masks
    
    %Loading data file
    load(strcat('DATA/',dataPath.name));
    fprintf("Generating rois from data :\n%s\n\n",dataPath.name);
    rois = sData{1,2}.scan.contour;
    rois=rois.';
    type=sData{1,2}.type;
    
    %Generating all new rois
    ROIs_one_roiObj=[];
    for roiNum=1:numel(rois) %For one roi, one patient and one modality only
        roiName=rois(roiNum);
        
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
            [volObj,roiObj] = getROI(sData,roiNum,'2box');
            %Setting data to be modified with normalized spatial references
            roi=interpVolume(roiObj,[1,1,1],'linear',0.5,'roi'); %Just copying roiObj as only the data is meant to change and not the spatialref
            roiObj.spatialRef = roi.spatialRef;
            if type=='CTscan'
                vol=interpVolume(volObj,[1,1,1],'linear',1,'image');
            else
                vol=interpVolume(volObj,[1,1,1],'linear',[],'image');
            end
            volObj.spatialRef = vol.spatialRef;
            roi=roi.data;
            vol=vol.data;
            newROI=genROIs_tier2(roi,vol,100,true); %Last argument is for enabling better region choice
            %Applying new data to roiObj
            roiObj.data=newROI;
            save('roi','roi');
            save('newROI','newROI');
            save('vol','vol');
            %Re-setting roiOBJ with correct spatial references
            roiObj=interpVolume(roiObj,[0.9766,0.9766,5],'linear',0.5,'roi');
            newROI=roiObj.data;
            %ROIs_one_roiObj=cat(1,ROIs_one_roiObj,roiObj); %Here we generate only one roi per given roi at the start
            %We could put it in a for loop and do it more times
        end
    end
    clear sData;
    ROIs_all_roiObj=cat(2,ROIs_all_roiObj,ROIs_one_roiObj);
end
end