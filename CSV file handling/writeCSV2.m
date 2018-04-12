function []=writeCSV2()
lesions=dir('DICOM');
autoFilesnames="";
visFilesnames="";
wd=pwd;
%Get roi names, if not already existing
if exist('roisNames')~=1
    roisNames= getROInames();
end

%Generate csv files names
for roiName=roisNames(1,:)
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
        visEnd =  strfind(roiName,')');
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
autoStream = fopen(autoFilesnames(1),'w');
for autoFilesname=autoFilesnames(2:end)
    autoStream(end+1)=fopen(autoFilesnames(openFile),'w');
    fprintf(autoStream(end),"PatientID,ImagingScanName,ImagingModality,ROIname\n");
    openFile=openFile+1;
end
openFile=1;
visStream = fopen(visFilesnames(1),'w');
for visFilesname=visFilesnames(2:end)
    visStream(end+1)=fopen(visFilesnames(openFile),'w');
    fprintf(visStream(end),"PatientID,ImagingScanName,ImagingModality,ROIname\n");
    openFile=openFile+1;
end

for lesion=3:size(lesions,1)
    lName=lesions(lesion).name;
    writeFile=1;
    for names=6:10 %vis ROIs position
        CTROIName=roisNames(1,names);
        PTROIName=roisNames(2,names);
        fprintf(visStream(writeFile),'%s,CT,CTscan,%s\n',lName,CTROIName);
        fprintf(visStream(writeFile),'%s,PET,PTscan,%s\n',lName,PTROIName);
        writeFile=writeFile+1;
    end
    writeFile=1;
    for names=[3,4,5,12,13] %auto ROIs position
        CTROIName=roisNames(1,names);
        PTROIName=roisNames(2,names);
        fprintf(autoStream(writeFile),'%s,CT,CTscan,%s\n',lName,CTROIName);
        fprintf(autoStream(writeFile),'%s,PET,PTscan,%s\n',lName,PTROIName);
        writeFile=writeFile+1;
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