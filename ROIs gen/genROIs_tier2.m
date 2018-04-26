function [newROI]= genROIs_tier2(roi,vol,numIter,better_selection)
numIter=numIter-1;
newROI=roi;
%ROI dimensions
roiSizeX=size(newROI,1);
roiSizeY=size(newROI,2);
roiSizeZ=size(newROI,3);
maxMaskSize=0;
minMaskSize=4;
while maxMaskSize<minMaskSize
    [x,y,z]=get_Selected_Point(newROI);
    %Selecting mask dimensions
    maxMaskSize=min([x,y,z,roiSizeX-x,roiSizeY-y,roiSizeZ-z]); %Mask size must fit chosen point position and roi size dimensions
end

if better_selection
    %     %Select area where to apply modifications
    volObjPerc=prctile(vol(roi==1),1:99); %This histogram could be processed only one time, there is no reason why it should change.
    % vol_without_bones=vol;
    % vol_without_bones(vol_without_bones>volObjPerc(3)&roi==0)=0; %Removing bones from outside of current ROI
    % Med_without_bones=medfilt3(vol_without_bones,[5 5 5]);
    % % if(Med_without_bones(x,y,z)>0)
    vol(vol>volObjPerc(99)&roi==0)=0; %Removing bones from vol
    vol(vol<volObjPerc(10)&roi==0)=0; %Removing other low density tissues from vol
    if vol(x,y,z)==0 %If the local zone barely covers the tumor
        expand=false; %In this case, the ROI already fully covers the tumor and other tissues in this location, so there is no reason to expand
    else
        %ROI is inside a zone where more matter is present, but we don't know whether or not it is tumoral tissue : we can either expand or shrink
        %The choice between those options should be made in regard to the best knowledge available, maybe use
        %some radiomics features later rather than intensity histogram values
        selPointPosition=find(vol(x,y,z)<volObjPerc);
        try
        selPointPosition=selPointPosition(1); %This is the position of the selected point in the intensity histogram
        catch
            selPointPosition=0; %The selected point contains an unusually big value. Better not keep this point.
        end
        %The further from 50, the more chance to shrink
        %%%%%%%%%%%%%%%%%%%%%%%%%% THERE SEEMS TO BE NO EXPANSIONS WITH THIS SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%
        expand=(rand()*abs(selPointPosition-50))<50; %If position is far from 50 then do not expand.
        %Better make sure that when value is between 25th and 75th
        %percentile, the chances of expanding are greater than shrinking
        %(that would make sense). It seems to be the case here.
    end
else
    expand=rand()>0.5;
end

maskSize=ceil(max(rand()*(maxMaskSize-1),minMaskSize)); %size in dimension z is smaller, let's not exceed it
offset=(maskSize)/2; %We need to ensure mask size and touchRegion size are perfectly equal
touchRegion=newROI(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset); %Region to edit
maskSize=maskSize+1; %touchRegion would be 1 unit larger in each dimension because of x-offset:x+offset interval
mask=genMask(maskSize);

%Treshold parameter
ShrinkTreshold=(maskSize^3)/5; %If shrinkTreshold is higher there will be more shrink effect.
expandTreshold=(maskSize^3)/8; %If expandTreshold is lower there will be more expand effect

if ~exist('expand','var')
    %Picking one transform
    expand=rand()>0.5; %expand or Shrink ?
end
if expand
    %Processing convolution elements
    sx=size(touchRegion,1);
    sy=size(touchRegion,2);
    sz=size(touchRegion,3);
    cv=convn(touchRegion,mask);
    cvsx=size(cv,1);
    cvsy=size(cv,2);
    cvsz=size(cv,3);
    %applying the convolution
    try
        cv=cv(cvsx/2-sx/2:cvsx/2+sx/2,cvsy/2-sy/2:cvsy/2+sy/2,cvsz/2-sz/2:cvsz/2+sz/2);
    catch
        
    end
    cv=imresize3(cv,size(touchRegion,1)/size(cv,1));
    expandedRegion=touchRegion;
    expandedRegion(cv>expandTreshold)=1; %The outside part of the region is partially covered
    newROI(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=expandedRegion;
    
else
    %shrinking is different to expanding in the way that when applying the
    %convolution, we need to get rid of borders effects that would cause
    %excavations even from the tumor size of the region to shrink. For this
    %purpose we just fit our region in a larger region filled with 1 before
    %applying convolution
    
    %Good shrink
    ShrinkedRegion=ones(size(touchRegion)+2*size(mask)+[1,1,1]);
    ShrinkedRegion(size(mask,1)+1:size(ShrinkedRegion,1)-size(mask,1)-1,size(mask,2)+1:size(ShrinkedRegion,2)-size(mask,2)-1,size(mask,3)+1:size(ShrinkedRegion,3)-size(mask,3)-1)=touchRegion;
    
    %Applying convolution to enlarged region
    cv=convn(ShrinkedRegion,mask);
    
    %Reshaping cv and ShrinkRegion to ShrinkRegion's original size
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
    newROI(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=ShrinkedRegion;
    %Good shrink end
    
    %Bad shrink
    %     sx=size(touchRegion,1);
    %     sy=size(touchRegion,2);
    %     sz=size(touchRegion,3);
    %     cv=convn(touchRegion,mask);
    %     cvsx=size(cv,1);
    %     cvsy=size(cv,2);
    %     cvsz=size(cv,3);
    %     %applying the convolution
    %     cv=cv(cvsx/2-sx/2:cvsx/2+sx/2,cvsy/2-sy/2:cvsy/2+sy/2,cvsz/2-sz/2:cvsz/2+sz/2);
    %     cv=imresize3(cv,size(touchRegion,1)/size(cv,1));
    %     ShrinkedRegion=touchRegion;
    %     ShrinkedRegion(cv<ShrinkTreshold)=0; %The outside part of the region is partially covered
    %     newData(x-offset:x+offset,y-offset:y+offset,z-offset:z+offset)=ShrinkedRegion;
    %Bad shrink end
    
end

if numIter>=1
%     fprintf("%i Transforms to go for this ROI\n",numIter);
    newROI=genROIs_tier2(newROI,vol,numIter,better_selection);
end
end