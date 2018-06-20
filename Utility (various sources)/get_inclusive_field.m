%MIT License

%Copyright (c) 2018 Anaël Leinert

%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:

%The above copyright notice and this permission notice shall be included in all
%copies or substantial portions of the Software
function nested_field=get_inclusive_field(struct,field_name)
separated_names=strsplit(field_name,'.');
nested_field=struct.(separated_names{1});

%Now get all the way down the sub structures to the sought field
field_pos=2;
while isstruct(nested_field)
    try
    nested_field=nested_field.(separated_names{field_pos});
    catch
        warning('Error in get inclusive field');
        nested_field=[];
        return
    end
    field_pos=field_pos+1;
end
end
