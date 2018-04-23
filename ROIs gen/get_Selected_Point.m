%This function is meant to return the positions of selectible points ie the
%points close enough to the surface of the tumor (and inside of it)
%considering a certain mask. For example, if a mask of size 3 is given, the
%chosen points must be at most in a distance of 2 from the surface,
%otherwise the erode or dilate transform would do nothing.


function [x,y,z]=get_Selected_Point(roi)
%The circular mask can't be used anywhere like that, as it would either add or remove
%huge circular shapes to ROI or even do nothing if applied completely inside or outside of
%the tumor.

laplacian(:,:,1)=[-1,-1,-1;-1,-1,-1;-1,-1,-1];
laplacian(:,:,2)=[-1,-1,-1;-1,26,-1;-1,-1,-1];
laplacian(:,:,3)=laplacian(:,:,1);

%Choosing only selectible points among the one where laplacian > 3
%(good tradeoff between being able to select everywhere and keeping only the borders)
selectiblePoints=convn(roi,laplacian);

%Eliminating enlarged borders after the convolution
selectiblePoints=selectiblePoints(2:end-1,2:end-1,2:end-1);

for sel=1:numel(selectiblePoints)
    if selectiblePoints(sel)>3
        selectiblePoints(sel)=1;
    else
        selectiblePoints(sel)=0;
    end
end
selectableIndices=find(selectiblePoints==1);
selectedPoint=ceil(rand()*numel(selectableIndices)); %Can all selectible points actually be used wit this line ?
s=size(selectiblePoints); %Size does not seem to work here, why ?
[x,y,z]=ind2sub(s,selectableIndices(selectedPoint));
end