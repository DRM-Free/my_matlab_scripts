function [pairs]=gen_pairs_1D(size)
for i=1:size
    for j=1:size
        if i>j
            try 
                pairs=cat(1,pairs,[i j]);
            catch
                pairs=[i j];
            end
        end
    end
end
end