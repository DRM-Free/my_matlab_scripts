function [matchingFile]=find_data_file(featureFile)
matchingFile=featureFile;
lesionName=split(featureFile.featureFileName,'.');
modality=lesionName{2};
lesionName=lesionName{1};
roi=split(lesionName,'(');
roi=roi{2};
roi=split(roi,')');
roi=roi{1};
lesionName=split(lesionName,'(');
lesionName=lesionName{1};
matchingFile.dataFileName=strcat(lesionName,'.',modality,".mat");
matchingFile.modality=modality;
end