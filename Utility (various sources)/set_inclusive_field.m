%Author Anaël Leinert

function original_struct=set_inclusive_field(original_struct,inclusive_field)

separated_names=strsplit(inclusive_field,'.');
inclusive_field=original_struct.(separated_names{1});

%Now get all the way down the sub structures to the sought field
field_pos=2;
while isstruct(inclusive_field)
    parent_field=inclusive_field;
    inclusive_field=inclusive_field.(separated_names{field_pos});
    field_pos=field_pos+1;
end

end
