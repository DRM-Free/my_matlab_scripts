all_data=fieldnames(all_dice);
%Removing patient 19 with only 5 original ROIs
all_data(21)=[];
all_data(21)=[];
original_ROIs_count=numel(all_dice.(all_data{1}));
lesions_count=numel(all_data);
all_dice_matrix=zeros(lesions_count,original_ROIs_count); %One line per lesion
for lesion_number=1:lesions_count
    all_dice_matrix(lesion_number,:)=all_dice.(all_data{lesion_number});
end

all_dice_sorted_by_lesion=all_dice_matrix; %Rearrange columns so that the worst case lesion comes to first line
all_dice_sorted_by_specialist=all_dice_matrix; %Rearrange lines so that the worst case specialist comes to first column
all_dice_sorted_by_lesion=all_dice_sorted_by_lesion.';

figure('Name','Unsorted by lesion'); %One curve = one specialist
%Sorting by lesion
for roi_number=1:original_ROIs_count
    plot(all_dice_matrix(1:4:end,roi_number)), hold on,
end

figure('Name','Unsorted by specialist');  %One curve = one lesion
%Sorting by specialist
for lesion_number=1:4:lesions_count
    plot(all_dice_matrix(lesion_number,:)), hold on,
end

figure('Name','Sorted by lesion');
%Sorting by lesion
% [~,first_lesion_order]=sort(all_dice_sorted_by_lesion(roi_number,:));
for roi_number=1:original_ROIs_count
        all_dice_sorted_by_lesion(roi_number,:)=sort(all_dice_sorted_by_lesion(roi_number,:));
%     lesions=all_dice_sorted_by_lesion(roi_number,:);
%     all_dice_sorted_by_lesion(roi_number,:)=lesions(first_lesion_order);
    plot(all_dice_sorted_by_lesion(roi_number,1:4:end)), hold on,
end

figure('Name','Sorted by specialist');
%Sorting by specialist
% [~,first_specialist_order]=sort(all_dice_sorted_by_specialist(1,:));
for lesion_number=1:4:lesions_count
%         specialists=all_dice_sorted_by_specialist(lesion_number,:);
%     all_dice_sorted_by_specialist(lesion_number,:)=specialists(first_specialist_order);
            all_dice_sorted_by_specialist(lesion_number,:)=sort(all_dice_sorted_by_specialist(lesion_number,:));
    plot(all_dice_sorted_by_specialist(lesion_number,:)), hold on,
end
