function[new_outliers] = removed_outliers_in_progress2(data, TR, variables, condition, num_timepoints) 

TR=TR{1,1};
well1=string(TR{1,'well'});

index=find(strcmp(data.well, well1)==1);

% do not change this
TR.extra=zeros(height(TR), 1);

removed_outliers_TR=table('Size',[height(TR) width(data)],VariableTypes=variables);
new_outliers=table('Size',[height(TR) width(data)],VariableTypes=variables);

TR_2=table2array(TR(:, vartype('numeric')));

for g=1:numel(num_timepoints)-1
    [removed_outliers_TR]=outlier_per_timepoint(TR_2, g, removed_outliers_TR, TR,num_timepoints);
    new_outliers=[new_outliers;removed_outliers_TR];
end

