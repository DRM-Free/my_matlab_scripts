if ~exist("RTs")
RTs=dicominfo("RTstruct.dcm")
ROI=RTs.ROIContourSequence.Item_1.ContourSequence;
slices=fieldnames(ROI);
slices=slices.';
nslices=numel(slices);
end



% contourPoints=struct('x',[],'y',[],'z',[]);
contourPoints=[];
for slice=slices
    curSlice=ROI.(slice{1});
    slContour=curSlice.ContourData;
    for coord=1:3:numel(slContour)
% contourPoints(end+1)=struct('x',slContour(coord),'y',slContour(coord+1),'z',slContour(coord+2))
contourPoints=cat(1,contourPoints,[slContour(coord),slContour(coord+1),slContour(coord+2)]);
    end
end