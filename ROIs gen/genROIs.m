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

% sx=size(ShrinkedRegion,1);
% sy=size(ShrinkedRegion,2);
% sz=size(ShrinkedRegion,3);
% cv=convn(ShrinkedRegion,mask);
% cvsx=size(cv,1);
% cvsy=size(cv,2);
% cvsz=size(cv,3);
% cv=cv(cvsx/2-sx/2:cvsx/2+sx/2,cvsy/2-sy/2:cvsy/2+sy/2,cvsz/2-sz/2:cvsz/2+sz/2);
% cv=imresize3(cv,size(ShrinkedRegion,1)/size(cv,1));
% ShrinkedRegion(cv<300)=0;

% end

newROI_obj.data(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=expandedRegion;
fullRegion=roiObj.data;
newExpandedFullRegion=newROI_obj.data;

newROI_obj.data(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=ShrinkedRegion;
newShrinkedFullRegion=newROI_obj.data;

save('newExpandedFullRegion','newExpandedFullRegion');
save('newShrinkedFullRegion','newShrinkedFullRegion');
save('fullRegion','fullRegion');
save('touchRegion','touchRegion');
save('expandedRegion','expandedRegion');
save('ShrinkedRegion','ShrinkedRegion');

%Re-setting roiOBJ with correct spatial references
newROI_obj=interpVolume(newROI_obj,[0.9766,0.9766,5],'linear',0.5,'roi');
end