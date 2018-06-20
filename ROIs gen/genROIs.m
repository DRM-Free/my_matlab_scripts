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

function [newROI_obj]= genROIs(roiObj)
keep roiObj;
%Copying roiOBJ with normalized spatial references
newROI_obj=interpVolume(roiObj,[1,1,1],'linear',0.5,'roi'); %Just copying roiObj as only the data is meant to change and not the spatialref

%ROI dimensions
roiSizeX=size(newROI_obj.data,1);
roiSizeY=size(newROI_obj.data,2);
roiSizeZ=size(newROI_obj.data,3);

%Select area where to apply modifications
selectibleIndices=get_Selectible_Points(newROI_obj.data);
selectedPoint=ceil(rand()*numel(selectibleIndices)); %Can all selectible points actually be used wit this line ?
[x,y,z]=ind2sub(size(newROI_obj.data),selectibleIndices(selectedPoint,1)); %selected point coords

%Selecting mask dimensions
maxMaskSize=min([x,y,z,roiSizeX-x,roiSizeY-y,roiSizeZ-z]); %Mask size must fit chosen point position and roi size dimensions
maskSize=ceil(max(rand()*(maxMaskSize-1),maxMaskSize/3)); %size in dimension z is smaller, let's not exceed it
offset=(maskSize)/2; %We need to ensure mask size and touchRegion size are perfectly equal
touchRegion=newROI_obj.data(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset); %Region to edit
maskSize=maskSize+1; %touchRegion would be 1 unit larger in each dimension because of x-offset:x+offset interval
mask=genMask(maskSize);

expand=rand()>0.5; %expand or Shrink ?

% if expand
%setting roi points to 1 where mask is 1;
expandedRegion=touchRegion;
expandedRegion(mask==1)=1; %expand tier 1. To be perfected

% else
%setting roi points to 0 where mask is 1;
ShrinkedRegion=touchRegion;
ShrinkedRegion(mask==1)=0; %shrink tier 1. To be perfected

% end

newROI_obj.data(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=expandedRegion;

newROI_obj.data(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=ShrinkedRegion;


%Re-setting roiOBJ with correct spatial references
newROI_obj=interpVolume(newROI_obj,[0.9766,0.9766,5],'linear',0.5,'roi');
end
