function[neur_outliers] = removed_outliers_neur_in_progress(data, TR, variables, condition, num_timepoints) 

TR=TR{1,1};
well1=string(TR{1,'well'});

index=find(strcmp(data.well, well1)==1);

% do not change this
TR.extra=zeros(height(TR), 1);

removed_outliers_TR=table('Size',[height(TR) width(data)],VariableTypes=variables);
TR_2=table2array(TR(:, vartype('numeric')));

for n=1:numel(num_timepoints)-1
    [removed_outliers_TR]=outlier_per_timepoint_neur(TR_2, n, removed_outliers_TR, TR,num_timepoints);
end

neur_outliers=removed_outliers_TR;