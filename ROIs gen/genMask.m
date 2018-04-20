%This function is meant to generate 3d masks with a given size (spherical masks will do at first glance.)
function [mask]=genMask(size)

%First, generate a circular mask
mask=zeros(size,size,size);
med=size/2;
offset=0.5;
for x=1:size
    for y=1:size
        for z=1:size
            if (x-offset-med)^2+(y-offset-med)^2+(z-offset-med)^2<med^2
                mask(x,y,z)=1;
            end
        end
    end
end
end