function ROIs_all_roiObj=gen_all_rois()
dataPaths=dir('DATA/*.mat');
dataPaths=dataPaths.';
ROIs_all_roiObj=[];
ROIs_from_all=struct;
processedPaths=0;
iterationsCounts=[10 20 30 40 50 60 70 80 90 100];
for dataPath=dataPaths %For one data file featuring all rois for one patient and one modality
    
    %Generating masks
    
    %Loading data file
    load(strcat('DATA/',dataPath.name));
    fprintf("Generating rois from data :\n%s\n\n",dataPath.name);
    rois = sData{1,2}.scan.contour;
    rois=rois.';
    type=sData{1,2}.type;
    patientName=sData{1,4}.PatientID;
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
            ROIs_from_one=struct('patient_name',patientName,'original_ROI_name',roiName,'generated_ROIs',0);
            [~,roiObj] = getROI(sData,roiNum,'full');
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
            
            for i=1:10
                nIter=iterationsCounts(i);
                newROI=genROIs_tier2(roi,vol,nIter,true); %Last argument is for enabling better region choice
                try
                    ROIs_from_one.generated_ROIs(end+1)=newROI;
                catch
                    ROIs_from_one.generated_ROIs=newROI;
                end
            end
            %             %Applying new data to roiObj
            %             roiObj.data=newROI;
            %             save('roi','roi');
            %             save('newROI','newROI');
            %             save('vol','vol');
            %             %Re-setting roiOBJ with correct spatial references
            %             roiObj=interpVolume(roiObj,[0.9766,0.9766,5],'linear',0.5,'roi');
            %             newROI=roiObj.data;
        end
    end
    clear sData;
    try
        ROIs_from_all(end+1)={ROIs_from_one};
    catch
        ROIs_from_all={ROIs_from_one};
    end
    processedPaths=processedPaths+1;
    fprintf('%i of %i data files were processed',processedPaths,numel(dataPaths));
end
save('AllROIs/ROIs_from_all','ROIs_from_all');
end