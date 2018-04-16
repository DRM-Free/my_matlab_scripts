function []=writeCSV()
roisNames= getROInames();
wd=pwd;
visPath=fullfile(wd,'CSV','roiNames-visRW.csv');
autoPath=fullfile(wd,'CSV','roiNames-autoRW.csv');

delete autoPath;
delete visPath;

viscsv = fopen(visPath,'w');
autocsv = fopen(autoPath,'w');

dicomPath=[wd,'/DICOM'];

fprintf(viscsv,"PatientID,ImagingScanName,ImagingModality,ROIname");
fprintf(viscsv,"\n");

fprintf(autocsv,"PatientID,ImagingScanName,ImagingModality,ROIname");
fprintf(autocsv,"\n");

    cd(dicomPath);
    allPatients = dir; nElem = numel(allPatients);
for patients=3:nElem
    patientID=allPatients(patients).name();
   cd(patientID);
   cd('CT');
   %patientID=getPatientID(pwd); %Takes patient ID from rtstruct file. It won't find it unless rtstruct with usual name is present
   for names=7:11 %vis ROIs position
   CTROIName=roisNames(1,names);
   fprintf(viscsv,patientID);
   fprintf(viscsv,",CT,CTscan,");
   fprintf(viscsv,CTROIName);
   fprintf(viscsv,"\n");
   end

   for names=[4,5,6,13,14] %auto ROIs position
   CTROIName=roisNames(1,names);
   fprintf(autocsv,patientID);
   fprintf(autocsv,",CT,CTscan,");
   fprintf(autocsv,CTROIName);
   fprintf(autocsv,"\n");
   end
   
   cd('..');
   cd('PET');
   
   for names=7:11 %vis ROIs position
   PETROIName=roisNames(2,names);
   fprintf(viscsv,patientID);
   fprintf(viscsv,",PET,PTscan,");
   fprintf(viscsv,PETROIName);
   fprintf(viscsv,"\n");
   end

   for names=[4,5,6,13,14] %auto ROIs position
   PETROIName=roisNames(2,names);
   fprintf(autocsv,patientID);
   fprintf(autocsv,",PET,PTscan,");
   fprintf(autocsv,PETROIName);
   fprintf(autocsv,"\n");
   end
    cd(dicomPath);
end
cd(wd);
end