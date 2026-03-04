function[removed_outliers_TR]=outlier_per_timepoint_neur_only(TR_2, n, removed_outliers_TR, TR,num_timepoints)

timepoint=strcat("Neur", num2str(n));
TR_Neur=table2array(TR(:,timepoint));

iqr_TR_Neur=iqr(TR_Neur);
upq_TR_Neur=quantile(TR_Neur, 0.75);
lowq_TR_Neur=quantile(TR_Neur, 0.25);

cc=1;
for bb=1:height(TR_2)
    if (TR_2(bb,n+1) > upq_TR_Neur+(1.5*iqr_TR_Neur)) 
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' > ' ,num2str(upq_TR_Neur+(1.5*iqr_TR_Neur)))]};
        cc=cc+1;
    elseif TR_2(bb, n+1) < lowq_TR_Neur-(1.5*iqr_TR_Neur)
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' < ' ,num2str(lowq_TR_Neur-(1.5*iqr_TR_Neur)))]};
        cc=cc+1;
    end 
end 