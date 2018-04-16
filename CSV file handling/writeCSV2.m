function []=writeCSV2()
lesions=dir('DICOM');
autoFilesnames="";
visFilesnames="";
wd=pwd;
%Get roi names, if not already existing
if exist('realROINames_1auto_1vis_rois')~=1
    load('realROINames_1auto_1vis.mat');
end

roiNames=realROINames_1auto_1vis_rois(1).CTroiNames;
roiNames=roiNames.';
%Generate csv files names
for roiName=roiNames
    roichar=char(roiName);
    visPos = strfind(roiName,'vis');
    autoPos = strfind(roiName,'auto');
    visEnd =  strfind(roiName,')');
    autoEnd =  strfind(roiName,')');
    
    if ~isequal(autoPos,[])
        if autoFilesnames==""
            autoFilesnames=string(strcat('CSV/roiNames_',roichar(autoPos:autoEnd),'.csv'));
        else
            roichar=char(roiName);
            autoFilesnames(end+1)=string(strcat('CSV/roiNames_',roichar(autoPos:autoEnd),'.csv'));
        end
    elseif ~isequal(visPos,[])
        if visFilesnames==""
            visFilesnames=string(strcat('CSV/roiNames_',roichar(visPos:visEnd),'.csv'));
        else
            visFilesnames(end+1)=string(strcat('CSV/roiNames_',roichar(visPos:visEnd),'.csv'));
        end
    end
end

%deleting old csv files
for autoFilesname=autoFilesnames
    delete(char(autoFilesname));
end
for visFilesname=visFilesnames
    delete(char(visFilesname));
end

%Opening all csv files streams

openFile=1;
autoStream = fopen(autoFilesnames(1),'a+');
for autoFilesname=autoFilesnames(2:end)
    openFile=openFile+1;
    autoStream(end+1)=fopen(autoFilesnames(openFile),'a+');
    fprintf(autoStream(end),"PatientID,ImagingScanName,ImagingModality,ROIname\n");
end
openFile=1;
visStream = fopen(visFilesnames(1),'a+');
for visFilesname=visFilesnames(2:end)
    openFile=openFile+1;
    visStream(end+1)=fopen(visFilesnames(openFile),'a+');
    fprintf(visStream(end),"PatientID,ImagingScanName,ImagingModality,ROIname\n");
end


keep visStream autoStream wd lesions realROINames_1auto_1vis_rois


for lesion=3:size(lesions,1)
    lName=lesions(lesion).name;
    writeFile=1;
    roisComplete=true;
    
    try
        for names=4:8 %vis ROIs position
            CTROIName=realROINames_1auto_1vis_rois(lesion-2).CTroiNames(names);
            PTROIName=realROINames_1auto_1vis_rois(lesion-2).PTroiNames(names);
            vs=visStream(writeFile);
            fprintf(vs,"%s,CT,CTscan,%s\n",lName,CTROIName);
            fprintf(vs,"%s,PET,PTscan,%s\n",lName,PTROIName);
            writeFile=writeFile+1;
        end
        writeFile=1;
        for names=[1,2,3,9,10] %auto ROIs position
            CTROIName=realROINames_1auto_1vis_rois(lesion-2).CTroiNames(names);
            PTROIName=realROINames_1auto_1vis_rois(lesion-2).PTroiNames(names);
            auto=autoStream(writeFile);
            fprintf(auto,"%s,CT,CTscan,%s\n",lName,CTROIName);
            fprintf(auto,"%s,PET,PTscan,%s\n",lName,PTROIName);
            writeFile=writeFile+1;
        end
        
    catch
        sprintf('Current lesion ROIs seem to be incomplete :\n%s\n',lName);
        writeFile=1;
        for names=1:5
            %vis ROIs position for one peculiar file. This code won't work for another dataset !
            CTROIName=realROINames_1auto_1vis_rois(lesion-2).CTroiNames(names);
            PTROIName=realROINames_1auto_1vis_rois(lesion-2).PTroiNames(names);
            vs=visStream(writeFile);
            fprintf(vs,"%s,CT,CTscan,%s\n",lName,CTROIName);
            fprintf(vs,"%s,PET,PTscan,%s\n",lName,PTROIName);
            writeFile=writeFile+1;
        end
    end
end

%Closing stream files
for vs=visStream
    fclose(vs);
end
for as=autoStream
    fclose(as);
end

end