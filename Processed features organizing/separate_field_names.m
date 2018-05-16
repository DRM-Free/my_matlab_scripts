function fields=separate_field_names(concatenated_fields)
for i=1:length(concatenated_fields)
    fields{i,:}=strsplit(concatenated_fields{i},'.');
end
end