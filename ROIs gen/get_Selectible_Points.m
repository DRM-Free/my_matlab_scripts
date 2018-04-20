%This function is meant to return the positions of selectible points ie the
%points close enough to the surface of the tumor (and inside of it)
%considering a certain mask. For example, if a mask of size 3 is given, the
%chosen points must be at most in a distance of 2 from the surface,
%otherwise the erode or dilate transform would do nothing.


function [selectibleIndices]=get_Selectible_Points(roi)
%The circular mask can't be used anywhere like that, as it would either add or remove
%huge circular shapes to ROI or even do nothing if applied completely inside or outside of
%the tumor.

laplacian(:,:,1)=[-1,-1,-1;-1,-1,-1;-1,-1,-1];
laplacian(:,:,2)=[-1,-1,-1;-1,26,-1;-1,-1,-1];
laplacian(:,:,3)=laplacian(:,:,1);

%Choosing only selectible points among the one where laplacian > 3 
%(good tradeoff between being able to select everywhere and keeping only the borders)
selectible=convn(roi,laplacian);
for sel=1:numel(selectible)
    if selectible(sel)>3
selectible(sel)=1;
    else
        selectible(sel)=0;
    end
    
end
%Eliminating enlarged borders after the convolution
selectible=selectible(2:size(roi,1)+1,2:size(roi,2)+1,2:size(roi,3)+1);
selectibleIndices=find(selectible==1);
end