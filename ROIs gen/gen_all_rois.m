%MIT License

%Copyright (c) 2018 Anaël Leinert

%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:

%The above copyright notice and this permission notice shall be included in all
%copies or substantial portions of the Software

function gen_all_rois()
dataPaths=dir('DATA/*.mat');
dataPaths=dataPaths.';
processedPaths=0;
%Simple ROI gen parameters
range=5;
nIter=10;
% iterationsCounts=[10 20 30 40 50 60 70 80 90 100];
for dataPath=dataPaths %For one data file featuring all rois for one patient and one modality
    %Loading data file
    load(strcat('DATA/',dataPath.name));
    fprintf("Generating rois from data :\n%s\n",dataPath.name);
    rois = sData{1,2}.scan.contour;
    rois=rois.';
    type=sData{1,2}.type;
    patientName=sData{1,4}.PatientID;
    world_extent=[sData{1,2}.scan.volume.spatialRef.PixelExtentInWorldX,sData{1,2}.scan.volume.spatialRef.PixelExtentInWorldY,sData{1, 2}.scan.volume.spatialRef.PixelExtentInWorldZ];
    
    %Generating all new rois
    for roiNum=1:numel(rois) %For one roi, one patient and one modality only
        roiName=rois(roiNum);
        
        %Removing unused rois
        roiName=roiName.name;
        visPos = strfind(roiName,'1vis');
        autoPos = strfind(roiName,'1auto');
        gen=strfind(roiName,'gen');
        if (isequal(gen,[])) %We don't want to generate contours from non original contours
            if ~(isequal(autoPos,[])&isequal(visPos,[]))
                process=true;
            else
                process=false; %If image type is not recognized after that point then no ROI is processed
            end
        end
        if process
            [~,roiObj] = getROI(sData,roiNum,'2box');
            %             %Setting data to be modified with normalized spatial references
            %             if type=='CTscan'
            %                 vol=interpVolume(volObj,[1,1,1],'linear',1,'image');
            %             else
            %                 vol=interpVolume(volObj,[1,1,1],'linear',[],'image');
            %             end
            % In genROIs_simple, see the thresholds params to generate ROIs with different
            % levels of similarity
            
            [newROIs,shrink_thresholds,expand_thresholds]=genROIs_simple(roiObj,world_extent,range,nIter);
            refROI=roiObj.data;
            %Now let's keep only the desired ROIs with proper dice
            %coefficients. The number that is kept is configurable
            %THIS STEP IS SLOW
            %IF MORE SPEED EFFICIENCY IS NEEDED, WHAT SHOULD BE DONE IS
            %USE LOW SCALE ROIS INSTEAD OF FULL SCALE ROIS IN
            %DICE_FROM_SIMPLE COMPARISON FUNCTION
            %(CURRENTLY, ROIS RESCALED TO [1 1 1] WORLD EXTENT ARE USED BECAUSE THE INTERPVOLUME FUNCTION
            %DOES NOT REVERT PROPERLY : TRANSFORM FROM TO X X X TO 1 1 1 AND BACK TO X X X DOES NOT KEEP ORIGINAL
            %VOL_OBJ DIMENSIONS, SO I COULDN'T COMPARE ORIGINAL SIZE ROIS)
            [~,kept_ROIs]=dice_from_simple(newROIs,refROI,shrink_thresholds,expand_thresholds,nIter);
            sData{1,2}.scan.contour(roiNum).simple_roi_gen=kept_ROIs;
            %Gen ROI other method
            %newROI=genROIs_tier2(roi,vol,nIter,true); %Last argument is for enabling better region choice
            %             for i=1:10
            %                 nIter=iterationsCounts(i);
            %                 %Applying new data to roiObj
            %                 roiObj.data=newROI;
            %                 save('roi','roi');
            %                 save('newROI','newROI');
            %                 save('vol','vol');
            %                 %Re-setting roiOBJ with correct spatial references
            %                 roiObj=interpVolume(roiObj,[0.9766,0.9766,5],'linear',0.5,'roi');
            %                 newROI=roiObj.data;
            %             end
        end
    end
    save(strcat('DATA/',dataPath.name),'sData','-v7.3');
    clear sData;
    processedPaths=processedPaths+1;
    fprintf('%i of %i data files were processed\n\n',processedPaths,numel(dataPaths));
    
end
end
