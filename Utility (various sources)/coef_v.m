function [c,m]=coef_v(v)
%returns coefficient of variation and mean of a set of values
m=mean(v);
c=std(v)/m;
end