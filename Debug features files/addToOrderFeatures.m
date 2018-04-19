function [orderedFeatures]=addToOrderFeatures(tempOrdered,patientName,ROIName, featureValue)
tempOrdered=checkHasEntries(tempOrdered,patientName, ROIName);
%checkHasEntries ensures that the proper location to store the feature already exists
%in tempOrdered (row with patient name and column with ROI ame)
tempOrderedSize=size(tempOrdered);
nRows=tempOrderedSize(1);
nCols=tempOrderedSize(2);


for ROIIndex=2:nCols
    for patientIndex=2:nRows
        if ((isequal(tempOrdered{2,ROIIndex}, ROIName)) && (isequal(tempOrdered{patientIndex,2},patientName)))
            tempOrdered{patientIndex,ROIIndex}=featureValue;
            break
        end
    end
    orderedFeatures=tempOrdered;
end