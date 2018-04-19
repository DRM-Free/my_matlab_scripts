function [newTable]=checkHasEntries(table,rowEntry,colEntry)
%This checks if first line has rowEntries and first columnt has colEntries
tableSize=size(table);
    nRows=tableSize(1);
    nCols=tableSize(2);
if ((nRows==2)&(nCols==2)&(isequal(table{1,2},[]))&(isequal(table{2,1},[])))
    table{1,2}=rowEntry;
    table{2,1}=colEntry;
    
else
    hasRowEntry=false;
    hasColEntry=false;

    
    for rows=2:nRows
        if isequal(table{rows,2},rowEntry)
            hasRowEntry=true;
        end
    end
    
    for cols=2:nCols
        if isequal(table{2,cols},colEntry)
            hasColEntry=true;
        end
    end
    
    if ~(hasRowEntry)
        table{end+1,2}=rowEntry;
    end
    
    if ~(hasColEntry)
        table{2,end+1}=colEntry;
    end
end
newTable=table;

end