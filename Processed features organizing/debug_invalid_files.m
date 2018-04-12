function [invalidStructs]=debug_invalid_files(invalidROIs,otherInvalids)

roiTypes = {'autoRW00','autoRW01','autoRW02','autoRW03','autoRW04',...
            'visRW00','visRW01','visRW02','visRW03','visRW04'};
        
for invalidROI=1:size(invalidROIs,2)
   load(strcat('DATA/',invalidROIs(invalidROI).dataFileName));
   try
       
   catch
       
   end
end
    % if size(invalidStructs)==1
    %
    %
    %     invalidStructs(end+1)=load(strcat('FEATURES/',invalidROI.fileName));
    %
    %
    % end
end