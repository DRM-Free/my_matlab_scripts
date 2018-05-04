function ROIs_all_roiObj=gen_all_rois()
dataPaths=dir('DATA/*.mat');
dataPaths=dataPaths.';
ROIs_all_roiObj=[];
processedPaths=0;
iterationsCounts=[10 20 30 40 50 60 70 80 90 100];
for dataPath=dataPaths %For one data file featuring all rois for one patient and one modality
    
    %Loading data file
    load(strcat('DATA/',dataPath.name));
    fprintf("Generating rois from data :\n%s\n\n",dataPath.name);
    rois = sData{1,2}.scan.contour;
    rois=rois.';
    type=sData{1,2}.type;
    patientName=sData{1,4}.PatientID;
    %Generating all new rois
    for roiNum=1:numel(rois) %For one roi, one patient and one modality only
        roiName=rois(roiNum);
        
        %Removing unused rois
        roiName=roiName.name;
        visPos = strfind(roiName,'vis');
        autoPos = strfind(roiName,'auto');
        gen=strfind(roiName,'gen');
        if (isequal(gen,[])) %We don't want to generate contours from non original contours
            if ~(isequal(autoPos,[])&isequal(visPos,[]))
                process=true;
            else
                process=false; %If image type is not recognized after that point then no ROI is processed
            end
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
%Gen ROI simple method (fast)
                %For expansion :
                %false, >0.6 is not good (ROI becomes 0)
                %false, >0.3 is not effective for actual expansion
                %false, <0.3 and >0 is good
                % newROI=genROIs_simple(roi,5,0.2,5,false); %Fair expand
                % newROI=genROIs_simple(roi,5,0.1,5,false); %Bigger expand
                %newROI=genROIs_simple(roi,5,0.6,5,false); %This is actually a shrink

                %For shrink:
                %true, <0.5 and >0.3 is fair. Param should never superior
                %to 0.7 (0.6 is the highest that worked), otherwise it overshrinks (and possibly matrix becomes 0).
                %If smaller than 0.3 it becomes an expansion
                %for genROIs_simple, when third param=0.1 : few modifications When =0.5
                %newROI=genROIs_simple(roi,5,0.3,5,true); %Fair shrink
%                 newROI=genROIs_simple(roi,5,0.5,5,true); %Fair shrink

                %newROI=genROIs_simple(roi,5,0.1,5,true); %This is actually an expansion
                newROI=genROIs_simple(roi,5,0.7,1,true); %Overshrink

%                 newROI=genROIs_simple(roi,5,0.3,5,true); %This seems not to do actual shrink or expand
%                 newROI=genROIs_simple(roi,5,0.3,5,false); %This seems not to do actual shrink or expand, this just increases sphericity
%                 newROI=genROIs_simple(roi,5,0.5,5,false); %To be debugged !
%                 newROI=genROIs_simple(roi,5,0.2,5,true); %Unexpected result


%Gen ROI other method
                %newROI=genROIs_tier2(roi,vol,nIter,true); %Last argument is for enabling better region choice
            for i=1:10
                nIter=iterationsCounts(i);
                %Applying new data to roiObj
                roiObj.data=newROI;
                save('roi','roi');
                save('newROI','newROI');
                save('vol','vol');
                %Re-setting roiOBJ with correct spatial references
                roiObj=interpVolume(roiObj,[0.9766,0.9766,5],'linear',0.5,'roi');
                newROI=roiObj.data;
            end
        end
    end
    clear sData;
    processedPaths=processedPaths+1;
    fprintf('%i of %i data files were processed',processedPaths,numel(dataPaths));
end
save('AllROIs/ROIs_from_all','ROIs_from_all');
end