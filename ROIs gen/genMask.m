%This function is meant to generate 3d masks with a given size (spherical masks will do at first glance.)
function [mask]=genMask(range,mask_type)
%range must be odd
if isequal(mask_type,'spherical_distance')
    %First, generate a circular mask
    mask=zeros(range,range,range);
    med=range/2;
    offset=0.5;
    for x=1:range
        for y=1:range
            for z=1:range
                mask(x,y,z)=med-sqrt((x-offset-med)^2+(y-offset-med)^2+(z-offset-med)^2);
            end
        end
    end
end
if isequal(mask_type,'spherical_simple')
    %First, generate a circular mask
    mask=zeros(range,range,range);
    med=range/2;
    offset=0.5;
    for x=1:range
        for y=1:range
            for z=1:range
                if (x-offset-med)^2+(y-offset-med)^2+(z-offset-med)^2<med/2
                mask(x,y,z)=1;
                end
            end
        end
    end
end
end