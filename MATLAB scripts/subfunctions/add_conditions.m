function[TR]=add_conditions(data, p, TR, index)

TR_condition=data.(p+1)(index);
condition=cellstr(repmat(TR_condition,height(TR),1));

if p==1
    TR=addvars(TR, condition, 'After', "well");
else
    TR=addvars(TR, condition, 'After', strcat('condition', num2str(p-1)));
end

TR=renamevars(TR, 'condition', strcat('condition', num2str(p)));