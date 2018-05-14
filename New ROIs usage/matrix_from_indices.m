function [matrix]=matrix_from_indices(sz,indices)
matrix=zeros(sz);
indices=indices.';
for ind=indices
    [x,y,z]=ind2sub(sz,ind);
    matrix(x,y,z)=1;
end
end