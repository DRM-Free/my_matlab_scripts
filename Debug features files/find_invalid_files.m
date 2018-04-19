function [invalidROIs,otherInvalids]=find_invalid_files()

files=dir('FEATURES/*.mat');
invalidROIs=struct('featureFileName',"",'dataFileName',"", 'modality', "");
otherInvalids=struct('featureFileName',"",'dataFileName',"", 'modality', "");
for file=1:size(files)
    curFile=files(file).name;
    clear radiomics; %Clearing features for next load
    load(strcat('FEATURES/',curFile));
    try
        featuresTypes=fieldnames(radiomics.image);%featuresTypes={morph locInt stats intHist intVolHist texture};
        fprintf("\nRetrieving features from radiomics structure : \n '%s' \n",curFile);
    catch
        fprintf("Current radiomics structure has no field image.\nInvalid file : %s \n",curFile);
        
        if isequal(radiomics,'ERROR_ROI')
            if invalidROIs(end).featureFileName=="";
                invalidROIs(end).featureFileName=curFile;
            else
                invalidROIs(end+1)=struct('featureFileName',curFile,'dataFileName',"", 'modality', "");
            end
            invalidROIs(end)=find_data_file(invalidROIs(end));
        else
            if otherInvalids(end).featureFileName=="";
                otherInvalids(end).featureFileName=curFile;
            else
                otherInvalids(end+1)=struct('featureFileName',curFile,'dataFileName',"", 'modality', "");
            end
            otherInvalids(end)=find_data_file(otherInvalids(end));
            
        end
    end
end
end