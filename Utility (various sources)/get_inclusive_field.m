%Author Anaël Leinert

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