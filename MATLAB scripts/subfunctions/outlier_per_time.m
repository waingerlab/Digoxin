function[removed_outliers_TR]=outlier_per_time(TR_2, n, removed_outliers_TR, TR)

timepoint=strcat("BFP", num2str(n));
TR_BFP=table2array(TR(:,timepoint));

iqr_TR_BFP=iqr(TR_BFP);
upq_TR_BFP=quantile(TR_BFP, 0.75);
lowq_TR_BFP=quantile(TR_BFP, 0.25);

cc=1;
for bb=1:height(TR_2)
    if (TR_2(bb,n+1) > upq_TR_BFP+(1.5*iqr_TR_BFP)) 
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' > ' ,num2str(upq_TR_BFP+(1.5*iqr_TR_BFP)))]};
        cc=cc+1;
    elseif TR_2(bb, n+1) < lowq_TR_BFP-(1.5*iqr_TR_BFP)
        removed_outliers_TR(cc,:)= TR(bb,:);
        removed_outliers_TR(cc, end) = {[strcat(timepoint, ' < ' ,num2str(lowq_TR_BFP-(1.5*iqr_TR_BFP)))]};
        cc=cc+1;
    end 
end 