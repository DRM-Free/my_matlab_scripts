
function [selectedPoint,expand]=get_Better_Selected_Point(roi,vol)

%The circular mask can't be used anywhere like that, as it would either add or remove
%huge circular shapes to ROI or even do nothing if applied completely inside or outside of
%the tumor.

laplacian(:,:,1)=[-1,-1,-1;-1,-1,-1;-1,-1,-1];
laplacian(:,:,2)=[-1,-1,-1;-1,26,-1;-1,-1,-1];
laplacian(:,:,3)=laplacian(:,:,1);

%Choosing only selectible points among the one where laplacian > 3 
%(good tradeoff between being able to select everywhere and keeping only the borders)
selectible=convn(roi,laplacian);
selectible=selectible(2:end-1,2:end-1,2:end-1);
for sel=1:numel(selectible)
    if selectible(sel)>3
selectible(sel)=1;
    else
        selectible(sel)=0;
    end
end

selectedIndice=ceil(rand()*numel(selectible)); %Can all selectible points actually be used wit this line ?

if(Med_without_bones(selectedIndice)>0)
   expand=false;
else
    expand=true;
end

[x,y,z]=ind2sub(size(roi),selectedIndice); %selected point coords
selectedPoint=struct('x',x,'y',y,'z',z);
end