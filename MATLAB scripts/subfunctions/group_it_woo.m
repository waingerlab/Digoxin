function[all_treats,treats_combined]=group_it_woo(data,cond_assigns,condition)

% need some way to reach into all branches of all_conditions and determine
% which rows have same 3 conditions

all_treats={};    
c=1;

% creates all possible combinations of conditions into a string to be
% compared to when looking at each well
for n=1:height(data)
    if numel(condition)==1
        every_cond=cond_assigns; 
    else
        for f=1:numel(cond_assigns)
            add_cond=cond_assigns{1,f}{n,1};
            if f==1
                treat_conds=add_cond;
            else 
                treat_conds=[treat_conds add_cond];
            end 
        end
        every_cond(n,1)={treat_conds};
    end 
end 

j=0;
s=1;
for g=1:numel(every_cond)
    j=0;
    if g==1
        all_treats=[all_treats;every_cond(g,1)];
        %strcat('TR',string(n)){1,1}=data(n,:);
        c=c+1;
    else 
        for s=1:numel(all_treats)
            if contains(all_treats{s,1}, string(every_cond(g,1)))
                %index=find(strcmp(all_treats, string(treat_conds))==1);
                %strcat('TR',string(index))=[strcat('TR',string(index));data(n,:)];
            j=j+1;
            end
        end 
        if j==0
           all_treats=[all_treats;every_cond(g,1)];
        end 
    end 
    s=1;
end 

treats_combined=[];
for i=1:numel(all_treats)
    g=1;
    treat_group=array2table([]); 
    for u=1:numel(every_cond)
        if strcmp(string(every_cond(u,1)), string(all_treats(i,1)))
            treat_group(g,:)=data(u,:);
            g=g+1;
        end
    end
    treats_combined=[treats_combined; {treat_group}];
end 
% need to look through all_treats, if conditions are already in there, 
% don't add and skip to next set of conditions
   %% maybe add one to the counter after it passes through each S not being 
   % there, and if s=numel(all_treats), add it
