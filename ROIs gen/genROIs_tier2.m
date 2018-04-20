function [newROI_obj]= genROIs_tier2(roiObj)
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

%Treshold parameter
ShrinkTreshold=(maskSize^3)/2; %If shrinkTreshold is higher there will be more shrink effect.
expandTreshold=(maskSize^3)/8; %If expandTreshold is lower there will be more expand effect

%Picking one transform
expand=rand()>0.5; %expand or Shrink ?

% if expand
%Processing convolution elements
sx=size(touchRegion,1);
sy=size(touchRegion,2);
sz=size(touchRegion,3);
cv=convn(touchRegion,mask);
cvsx=size(cv,1);
cvsy=size(cv,2);
cvsz=size(cv,3);
%applying the convolution
cv=cv(cvsx/2-sx/2:cvsx/2+sx/2,cvsy/2-sy/2:cvsy/2+sy/2,cvsz/2-sz/2:cvsz/2+sz/2);
cv=imresize3(cv,size(touchRegion,1)/size(cv,1));
expandedRegion=touchRegion;
expandedRegion(cv>expandTreshold)=1; %The outside part of the region is partially covered

% else
%shrinking is different to expanding in the way that when applying the
%convolution, we need to get rid of borders effects that would cause
%excavations even from the tumor size of the region to shrink. For this
%purpose we just fit our region in a larger region filled with 1 before
%applying convolution

ShrinkedRegion=ones(size(touchRegion)+2*size(mask)+[1,1,1]);
ShrinkedRegion(size(mask,1)+1:size(ShrinkedRegion,1)-size(mask,1)-1,size(mask,2)+1:size(ShrinkedRegion,2)-size(mask,2)-1,size(mask,3)+1:size(ShrinkedRegion,3)-size(mask,3)-1)=touchRegion;
%Applying convolution to enlarged region
cv=convn(ShrinkedRegion,mask);
%Reshaping cv and ShrinkRegion to ShrinkRegion's original size
% cv=cv(size(mask,1)+1:size(cv,1)-size(mask,1)-1,size(mask,2)+1:size(cv,2)-size(mask,2)-1,size(mask,3)+1:size(cv,3)-size(mask,3)-1);
ShrinkedRegion=ShrinkedRegion(size(mask,1)+1:size(ShrinkedRegion,1)-size(mask,1)-1,size(mask,2)+1:size(ShrinkedRegion,2)-size(mask,2)-1,size(mask,3)+1:size(ShrinkedRegion,3)-size(mask,3)-1);
s1=size(ShrinkedRegion,1);
s2=size(ShrinkedRegion,2);
s3=size(ShrinkedRegion,3);
cvsx=size(cv,1);
cvsy=size(cv,2);
cvsz=size(cv,3);

cv=cv((cvsx-s1)/2:(cvsx+s1)/2,(cvsy-s2)/2:(cvsy+s2)/2,(cvsz-s3)/2:(cvsz+s3)/2);
cv=imresize3(cv,size(touchRegion,1)/size(cv,1));
ShrinkedRegion(cv<ShrinkTreshold)=0;
% ShrinkedRegion(cv>2*cvmax/3)=0;

% %Shrink method 2
% mask=1-mask;
% %Processing convolution elements
% sx=size(touchRegion,1);
% sy=size(touchRegion,2);
% sz=size(touchRegion,3);
% cv=convn(touchRegion,mask);
% cvsx=size(cv,1);
% cvsy=size(cv,2);
% cvsz=size(cv,3);
% %applying the convolution
% cv=cv(cvsx/2-sx/2:cvsx/2+sx/2,cvsy/2-sy/2:cvsy/2+sy/2,cvsz/2-sz/2:cvsz/2+sz/2);
% cv=imresize3(cv,size(touchRegion,1)/size(cv,1));
% cvmax=max(max(max(cv)));
% ShrinkedRegion=touchRegion;
% ShrinkedRegion(cv<cvmax/4)=0;
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