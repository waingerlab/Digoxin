function[removed_outliers_TR]=outlier_per_timepoint(TR_2, g, removed_outliers_TR, TR, num_timepoints)

timepoint=strcat("normBFP", num2str(g));
TR_BFP=table2array(TR(:,timepoint));

iqr_TR_BFP=iqr(TR_BFP);
upq_TR_BFP=quantile(TR_BFP, 0.75);
lowq_TR_BFP=quantile(TR_BFP, 0.25);

cc=1;
for bb=1:height(TR_2)
    if (TR_2(bb,g+numel(num_timepoints)) > upq_TR_BFP+(1.5*iqr_TR_BFP)) 
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' > ' ,num2str(upq_TR_BFP+(1.5*iqr_TR_BFP)))]};
        cc=cc+1;
    elseif TR_2(bb, g+numel(num_timepoints)) < lowq_TR_BFP-(1.5*iqr_TR_BFP)
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' < ' ,num2str(lowq_TR_BFP-(1.5*iqr_TR_BFP)))]};
        cc=cc+1;
    elseif TR_2(bb, g+numel(num_timepoints)) > 100
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' > 100')]};
        cc=cc+1;
    end 
end 