function [realROINames]=get_data_roi_names
dicom=dir('DICOM');
realROINames=struct('lesionName','','CTroiNames',[],'PTroiNames',[]);
lesionNum=size(dicom,1)

for lesionDir=3:lesionNum
    lesionName=dicom(lesionDir).name;
    
[CTroisNames,PTroisNames]= getROInames_one_lesion(strcat('DICOM/',lesionName));
    if isequal(realROINames(1).lesionName,'')
        realROINames(1)=struct('lesionName',lesionName,'CTroiNames',CTroisNames,'PTroiNames',PTroisNames);
    else
        realROINames(end+1)=struct('lesionName',lesionName,'CTroiNames',CTroisNames,'PTroiNames',PTroisNames);
    end
end
end