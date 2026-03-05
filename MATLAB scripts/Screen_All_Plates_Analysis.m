
%% this script takes an excel with all analysed data from experiments combined, 
% then graphs data 
addpath('.../Martha_subfunctions','.../gramm');

file=".../raw_data_all_plates.xlsx";
export_path="...";
neg_control="...";
pos_control="...";
experimental="...";


data=readtable(file, 'Sheet', '...');
num_plates=unique(data.Plate);

% calculate average values & create z_data (experimental values only)
y=1;
for f=1:height(data)
    data.AveNormBFP_24H(f)=(data.NormBFP_24H_A(f)+data.NormBFP_24H_B(f))/2;
    data.AveNormBFP_48H(f)=(data.NormBFP_48H_A(f)+data.NormBFP_48H_B(f))/2;
    data.AveNormNeur_24H(f)=(data.NormNeurite_24H_A(f)+data.NormNeurite_24H_B(f))/2;
    data.AveNormNeur_48H(f)=(data.NormNeurite_48H_A(f)+data.NormNeurite_48H_B(f))/2;
    if strcmp(data.Type(f), 'X')
        z_data(y, :)=data(f, :);
        y=y+1;
    end
end

%
f=1;
for g=1:numel(num_plates)
    for d=1:height(z_data)
        if strcmp(z_data.Plate(d), num_plates(g))
            if f==1
                individual_data{g,1}=z_data(d,:);
                f=f+1;
            else
            individual_data{g,1}=[individual_data{g,1};z_data(d,:)];
            f=f+1;
            end
        end
    end
    f=1;
end


z_data2=table('Size', [numel(num_plates) 9], 'VariableTypes', ...
    ["string", "double","double","double","double", "double","double","double","double"], ...
    'VariableNames',["Plate", "ave48BFP_A", "ave48BFP_B", "sd48BFP_A", "sd48BFP_B", "ave48Neur_A","ave48Neur_B", "sd48Neur_A","sd48Neur_B"]);

% calculate metrics per replicate plate
for s=1:numel(num_plates)
    z_data2.Plate(s)=num_plates(s);
    z_data2.ave48BFP_A(s)=mean(individual_data{s,1}.NormBFP_48H_A(:));
    z_data2.sd48BFP_A(s)=std(individual_data{s,1}.NormBFP_48H_A(:));
    z_data2.ave48BFP_B(s)=mean(individual_data{s,1}.NormBFP_48H_B(:));
    z_data2.sd48BFP_B(s)=std(individual_data{s,1}.NormBFP_48H_B(:));
    z_data2.ave48Neur_A(s)=mean(individual_data{s,1}.NormNeurite_48H_A(:));
    z_data2.ave48Neur_B(s)=mean(individual_data{s,1}.NormNeurite_48H_B(:));
    z_data2.sd48Neur_A(s)=std(individual_data{s,1}.NormNeurite_48H_A(:));
    z_data2.sd48Neur_B(s)=std(individual_data{s,1}.NormNeurite_48H_B(:));
    z_data2.aveNormBFP(s)=mean((individual_data{s,1}.NormBFP_48H_A(:)+individual_data{s,1}.NormBFP_48H_B(:))/2);
    z_data2.sdNormBFP(s)=std((individual_data{s,1}.NormBFP_48H_A(:)+individual_data{s,1}.NormBFP_48H_B(:))/2);
    z_data2.aveNormNeur(s)=mean((individual_data{s,1}.NormNeurite_48H_A(:)+individual_data{s,1}.NormNeurite_48H_B(:))/2);
    z_data2.sdNormNeur(s)=std((individual_data{s,1}.NormNeurite_48H_A(:)+individual_data{s,1}.NormNeurite_48H_B(:))/2);
end

% calculate Z scores from averages of both plates
for d=1:numel(num_plates)
    for h=1:height(individual_data{d,1})
        individual_data{d,1}.Zscore_48BFP(h)=((((individual_data{d,1}.NormBFP_48H_A(h)+individual_data{d,1}.NormBFP_48H_B(h))/2)-z_data2.aveNormBFP(d))/z_data2.sdNormBFP(d));
        individual_data{d,1}.Zscore_48Neur(h)=((((individual_data{d,1}.NormNeurite_48H_A(h)+individual_data{d,1}.NormNeurite_48H_B(h))/2)-z_data2.aveNormNeur(d))/z_data2.sdNormNeur(d));
        if individual_data{d,1}.Zscore_48BFP(h)>2
            individual_data{d,1}.BFP48_hit(h)={'Z>2'};
        else 
            individual_data{d,1}.BFP48_hit(h)={'Z<2'};
        end 
        if individual_data{d,1}.Zscore_48Neur(h)>2
            individual_data{d,1}.Neur48_hit(h)={'Z>2'};
        else 
            individual_data{d,1}.Neur48_hit(h)={'Z<2'};
        end
        if individual_data{d,1}.Zscore_48BFP(h)>2 && individual_data{d,1}.Zscore_48Neur(h)>2
            individual_data{d,1}.both48_hit(h)={'Hit'};
        else 
            individual_data{d,1}.both48_hit(h)={'Not a Hit'};
        end
        individual_data{d,1}.Zscore_48BFP_A(h)=((individual_data{d,1}.NormBFP_48H_A(h)-z_data2.ave48BFP_A(d))/z_data2.sd48BFP_A(d));
        individual_data{d,1}.Zscore_48BFP_B(h)=((individual_data{d,1}.NormBFP_48H_B(h)-z_data2.ave48BFP_B(d))/z_data2.sd48BFP_B(d));
        individual_data{d,1}.Zscore_48Neur_A(h)=((individual_data{d,1}.NormNeurite_48H_A(h)-z_data2.ave48Neur_A(d))/z_data2.sd48Neur_A(d));
        individual_data{d,1}.Zscore_48Neur_B(h)=((individual_data{d,1}.NormNeurite_48H_B(h)-z_data2.ave48Neur_B(d))/z_data2.sd48Neur_B(d));

        if individual_data{d,1}.Zscore_48BFP_A(h)>2
            individual_data{d,1}.BFP48_hit_A(h)={'Z>2'};
        else 
            individual_data{d,1}.BFP48_hit_A(h)={'Z<2'};
        end 
        if individual_data{d,1}.Zscore_48BFP_B(h)>2
            individual_data{d,1}.BFP48_hit_B(h)={'Z>2'};
        else 
            individual_data{d,1}.BFP48_hit_B(h)={'Z<2'};
        end 
        if individual_data{d,1}.Zscore_48Neur_A(h)>2
            individual_data{d,1}.Neur48_hit_A(h)={'Z>2'};
        else 
            individual_data{d,1}.Neur48_hit_A(h)={'Z<2'};
        end
        if individual_data{d,1}.Zscore_48Neur_B(h)>2
            individual_data{d,1}.Neur48_hit_B(h)={'Z>2'};
        else 
            individual_data{d,1}.Neur48_hit_B(h)={'Z<2'};
        end
        if individual_data{d,1}.Zscore_48BFP_A(h)>2 && individual_data{d,1}.Zscore_48BFP_B(h)>2
            individual_data{d,1}.bothBFP48_hit(h)={'Hit'};
        else 
            individual_data{d,1}.bothBFP48_hit(h)={'Not a Hit'};
        end
        if individual_data{d,1}.Zscore_48Neur_A(h)>2 && individual_data{d,1}.Zscore_48Neur_B(h)>2
            individual_data{d,1}.bothNeur48_hit(h)={'Hit'};
        else 
            individual_data{d,1}.bothNeur48_hit(h)={'Not a Hit'};
        end
        individual_data{d,1}.well_ID(h)=cellstr(strcat(string(individual_data{d,1}.Plate(h)), '_',string(individual_data{d,1}.Well(h))));
    end
end

% assign treatments to wells
for n=1:height(data)
    if (strcmp(data.Type(n),'N'))
        data.CompoundName(n)={string(neg_control)};
    elseif (strcmp(data.Type(n),'P'))
        data.CompoundName(n)={string(pos_control)};
    end
end

for p=1:height(data)
    if strcmp(data.Type(p), 'N')
        data.cat(p)={string(neg_control)};
    elseif strcmp(data.Type(p), 'P')
        data.cat(p)={string(pos_control)};
    elseif strcmp(data.Type(p), 'E')
        data.cat(p)={'Empty'};
    elseif strcmp(data.Type(p), 'X')
        data.cat(p)={string(experimental)};
    end 
    data.well_ID(p)=cellstr(strcat(string(data.Plate(p)), '_',string(data.Well(p))));
end


a=1;
for j=1:numel(num_plates)
    for f=1:height(individual_data{j,1})
        z_data3(a,:)=individual_data{j,1}(f,:);
        a=a+1;
    end
end


%% for Z-scores with negative controls included
y=1;
for u=1:height(data)
    if strcmp(data.Type(u), 'X') 
        zneg_data(u, :)=data(u, :);
        y=y+1;
    elseif strcmp(data.Type(u), 'N')
            zneg_data(u,:)=data(u,:);
            y=y+1;
    end
end 

k=1;
for a=1:numel(num_plates)
    for e=1:height(zneg_data)
        if strcmp(zneg_data.Plate(e), num_plates(a))
            if k==1
                individual_data_neg{a,1}=zneg_data(e,:);
                k=k+1;
            else
            individual_data_neg{a,1}=[individual_data_neg{a,1};zneg_data(e,:)];
            k=k+1;
            end
        end
    end
    k=1;
end

zneg_data2=table('Size', [numel(num_plates) 9], 'VariableTypes', ...
    ["string", "double","double","double","double", "double","double","double","double"], ...
    'VariableNames',["Plate", "ave48BFP_A_neg", "ave48BFP_B_neg", "sd48BFP_A_neg", "sd48BFP_B_neg", "ave48Neur_A_neg","ave48Neur_B_neg", "sd48Neur_A_neg","sd48Neur_B_neg"]);


for s=1:numel(num_plates)
    zneg_data2.Plate(s)=num_plates(s);
    zneg_data2.ave48BFP_A_neg(s)=mean(individual_data_neg{s,1}.NormBFP_48H_A(:));
    zneg_data2.sd48BFP_A_neg(s)=std(individual_data_neg{s,1}.NormBFP_48H_A(:));
    zneg_data2.ave48BFP_B_neg(s)=mean(individual_data_neg{s,1}.NormBFP_48H_B(:));
    zneg_data2.sd48BFP_B_neg(s)=std(individual_data_neg{s,1}.NormBFP_48H_B(:));
    zneg_data2.ave48Neur_A_neg(s)=mean(individual_data_neg{s,1}.NormNeurite_48H_A(:));
    zneg_data2.ave48Neur_B_neg(s)=mean(individual_data_neg{s,1}.NormNeurite_48H_B(:));
    zneg_data2.sd48Neur_A_neg(s)=std(individual_data_neg{s,1}.NormNeurite_48H_A(:));
    zneg_data2.sd48Neur_B_neg(s)=std(individual_data_neg{s,1}.NormNeurite_48H_B(:));
    zneg_data2.aveNormBFP_neg(s)=mean((individual_data_neg{s,1}.NormBFP_48H_A(:)+individual_data_neg{s,1}.NormBFP_48H_B(:))/2);
    zneg_data2.sdNormBFP_neg(s)=std((individual_data{s,1}.NormBFP_48H_A(:)+individual_data{s,1}.NormBFP_48H_B(:))/2);
    zneg_data2.aveNormNeur_neg(s)=mean((individual_data{s,1}.NormNeurite_48H_A(:)+individual_data{s,1}.NormNeurite_48H_B(:))/2);
    zneg_data2.sdNormNeur_neg(s)=std((individual_data{s,1}.NormNeurite_48H_A(:)+individual_data{s,1}.NormNeurite_48H_B(:))/2);
end

for d=1:numel(num_plates)
    for h=1:height(individual_data_neg{d,1})
        individual_data_neg{d,1}.Zscore_48BFP_neg(h)=((((individual_data_neg{d,1}.NormBFP_48H_A(h)+individual_data_neg{d,1}.NormBFP_48H_B(h))/2)-zneg_data2.aveNormBFP_neg(d))/zneg_data2.sdNormBFP_neg(d));
        individual_data_neg{d,1}.Zscore_48Neur_neg(h)=((((individual_data_neg{d,1}.NormNeurite_48H_A(h)+individual_data_neg{d,1}.NormNeurite_48H_B(h))/2)-zneg_data2.aveNormNeur_neg(d))/zneg_data2.sdNormNeur_neg(d));
        if individual_data_neg{d,1}.Zscore_48BFP_neg(h)>2
            individual_data_neg{d,1}.BFP48_hit_neg(h)={'Z>2'};
        else 
            individual_data_neg{d,1}.BFP48_hit_neg(h)={'Z<2'};
        end 
        if individual_data_neg{d,1}.Zscore_48Neur_neg(h)>2
            individual_data_neg{d,1}.Neur48_hit_neg(h)={'Z>2'};
        else 
            individual_data_neg{d,1}.Neur48_hit_neg(h)={'Z<2'};
        end
        if individual_data_neg{d,1}.Zscore_48BFP_neg(h)>2 && individual_data_neg{d,1}.Zscore_48Neur_neg(h)>2
            individual_data_neg{d,1}.both48_hit_neg(h)={'Hit'};
        else 
            individual_data_neg{d,1}.both48_hit_neg(h)={'Not a Hit'};
        end
        individual_data_neg{d,1}.Zscore_48BFP_A_neg(h)=((individual_data_neg{d,1}.NormBFP_48H_A(h)-zneg_data2.ave48BFP_A_neg(d))/zneg_data2.sd48BFP_A_neg(d));
        individual_data_neg{d,1}.Zscore_48BFP_B_neg(h)=((individual_data_neg{d,1}.NormBFP_48H_B(h)-zneg_data2.ave48BFP_B_neg(d))/zneg_data2.sd48BFP_B_neg(d));
        individual_data_neg{d,1}.Zscore_48Neur_A_neg(h)=((individual_data_neg{d,1}.NormNeurite_48H_A(h)-zneg_data2.ave48Neur_A_neg(d))/zneg_data2.sd48Neur_A_neg(d));
        individual_data_neg{d,1}.Zscore_48Neur_B_neg(h)=((individual_data_neg{d,1}.NormNeurite_48H_B(h)-zneg_data2.ave48Neur_B_neg(d))/zneg_data2.sd48Neur_B_neg(d));

        if individual_data_neg{d,1}.Zscore_48BFP_A_neg(h)>2
            individual_data_neg{d,1}.BFP48_hit_A_neg(h)={'Z>2'};
        else 
            individual_data_neg{d,1}.BFP48_hit_A_neg(h)={'Z<2'};
        end 
        if individual_data_neg{d,1}.Zscore_48BFP_B_neg(h)>2
            individual_data_neg{d,1}.BFP48_hit_B_neg(h)={'Z>2'};
        else 
            individual_data_neg{d,1}.BFP48_hit_B_neg(h)={'Z<2'};
        end 
        if individual_data_neg{d,1}.Zscore_48Neur_A_neg(h)>2
            individual_data_neg{d,1}.Neur48_hit_A_neg(h)={'Z>2'};
        else 
            individual_data_neg{d,1}.Neur48_hit_A_neg(h)={'Z<2'};
        end
        if individual_data_neg{d,1}.Zscore_48Neur_B_neg(h)>2
            individual_data_neg{d,1}.Neur48_hit_B_neg(h)={'Z>2'};
        else 
            individual_data_neg{d,1}.Neur48_hit_B_neg(h)={'Z<2'};
        end
        if individual_data_neg{d,1}.Zscore_48BFP_A_neg(h)>2 && individual_data_neg{d,1}.Zscore_48BFP_B_neg(h)>2
            individual_data_neg{d,1}.bothBFP48_hit_neg(h)={'Hit'};
        else 
            individual_data_neg{d,1}.bothBFP48_hit_neg(h)={'Not a Hit'};
        end
        if individual_data_neg{d,1}.Zscore_48Neur_A_neg(h)>2 && individual_data_neg{d,1}.Zscore_48Neur_B_neg(h)>2
            individual_data_neg{d,1}.bothNeur48_hit_neg(h)={'Hit'};
        else 
            individual_data_neg{d,1}.bothNeur48_hit_neg(h)={'Not a Hit'};
        end
        individual_data_neg{d,1}.well_ID(h)=cellstr(strcat(string(individual_data_neg{d,1}.Plate(h)), '_',string(individual_data_neg{d,1}.Well(h))));
    end
end

a=1;
for j=1:numel(num_plates)
    for f=1:height(individual_data_neg{j,1})
        zneg_data3(a,:)=individual_data_neg{j,1}(f,:);
        a=a+1;
    end
end
   
% save excels
writetable(z_data3, file, 'Sheet', 'Z_Scores');
writetable(zneg_data3, file, 'Sheet', 'Z_Scores_wNeg');


%% select graphs of interest here
allplates_norm24BFP=gramm('x', data.Well, 'y', data.AveNormBFP_24H, 'color', data.cat, 'subset', ~(strcmp(data.Type, 'E')));
allplates_norm24BFP.geom_point();
allplates_norm24BFP.set_title('Normalized Cell Count - All Plates - 24H', 'FontSize',20)
allplates_norm24BFP.set_names('x','Well','y', '% of Initial Cell Count');
allplates_norm24BFP.set_color_options('map',[0 0 0 ; 0.9 0 0 ; 0 0.9 0.9]);
allplates_norm24BFP.set_text_options('font','Arial','base_size',15);
allplates_norm24BFP.axe_property('YGrid','on', 'YLim', [0, 100], 'XTick', [], 'XTickLabel','');
allplates_norm24BFP.set_layout_options('redraw',0.04);
figure
allplates_norm24BFP.draw();
allplates_norm24BFP.export('file_name','allplates_norm24BFP','export_path',export_path, ...
    'file_type','pdf');


allplates_norm48BFP=gramm('x', data.Well, 'y', data.AveNormBFP_48H, 'color', data.cat, 'subset', ~(strcmp(data.Type, 'E')));
allplates_norm48BFP.geom_point();
allplates_norm48BFP.set_title('Normalized Cell Count - All Plates - 48H', 'FontSize',20)
allplates_norm48BFP.set_names('x','Well','y', '% of Initial Cell Count');
allplates_norm48BFP.set_text_options('font','Arial','base_size',15);
allplates_norm48BFP.axe_property('YGrid','on', 'YLim', [0, 100], 'XTick', [], 'XTickLabel','');
allplates_norm48BFP.set_layout_options('redraw',0.04);
figure
allplates_norm48BFP.draw();
allplates_norm48BFP.export('file_name','allplates_norm48BFP','export_path',export_path, ...
    'file_type','pdf');

allplates_norm24Neur=gramm('x', data.Well, 'y', data.AveNormNeur_24H, 'color', data.cat, 'subset', ~(strcmp(data.Type, 'E')));
allplates_norm24Neur.geom_point();
allplates_norm24Neur.set_title('Normalized Neurite Outgrowth - All Plates - 24H', 'FontSize',20)
allplates_norm24Neur.set_names('x','Well','y', '% of Initial Neurite Area');
allplates_norm24Neur.set_text_options('font','Arial','base_size',15);
allplates_norm24Neur.axe_property('YGrid','on', 'YLim', [0, 100], 'XTick', [], 'XTickLabel','');
allplates_norm24Neur.set_layout_options('redraw',0.04);
figure
allplates_norm24Neur.draw();
allplates_norm24Neur.export('file_name','allplates_norm24Neur','export_path',export_path, ...
    'file_type','pdf');

allplates_norm48Neur=gramm('x', data.Well, 'y', data.AveNormNeur_48H, 'color', data.cat, 'subset', ~(strcmp(data.Type, 'E')));
allplates_norm48Neur.geom_point();
allplates_norm48Neur.set_title('Normalized Neurite Outgrowth - All Plates - 48H', 'FontSize',20)
allplates_norm48Neur.set_names('x','Well','y', '% of Initial Neurite Area');
allplates_norm48Neur.set_text_options('font','Arial','base_size',15);
allplates_norm48Neur.axe_property('YGrid','on', 'YLim', [0, 150], 'XTick', [], 'XTickLabel','');
allplates_norm48Neur.set_layout_options('redraw',0.04);
figure
allplates_norm48Neur.draw();
allplates_norm48Neur.export('file_name','allplates_norm48Neur','export_path',export_path, ...
    'file_type','pdf');

allplates_BFPtoNeur=gramm('x',data.AveNormBFP_48H, 'y', data.AveNormNeur_48H, 'subset', ~(strcmp(data.Type, 'E')));
allplates_BFPtoNeur.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
allplates_BFPtoNeur.set_title('Neurite Outgrowth to Cell Survival - All Plates - 48H');
allplates_BFPtoNeur.set_color_options("chroma", 0, "lightness", 5);
allplates_BFPtoNeur.set_names('x', '% Initial Cell Count', 'y', '% Initial Neurite Area');
allplates_BFPtoNeur.set_text_options('font','Arial','base_size',15);
allplates_BFPtoNeur.axe_property('YGrid','on', 'XLim', [0 100], 'YLim', [0 150]);
figure
allplates_BFPtoNeur.draw();
allplates_BFPtoNeur.update('color', data.cat);
allplates_BFPtoNeur.set_color_options();
allplates_BFPtoNeur.geom_point('alpha', 0.6);
allplates_BFPtoNeur.draw();
allplates_BFPtoNeur.export('file_name','allplates_BFPtoNeur','export_path',export_path, ...
    'file_type','pdf');

allplates_48BFP_replicatecorr=gramm('x',data.NormBFP_48H_A, 'y', data.NormBFP_48H_B, 'subset', ~(strcmp(data.Plate, '3651')+strcmp(data.Type, 'E')));
allplates_48BFP_replicatecorr.set_title('Correlation Between Replicates - Cell Survival - 48H');
allplates_48BFP_replicatecorr.set_names('x', '48H Cell Survival - Replicate A', 'y', '48H Cell Survival - Replicate B');
allplates_48BFP_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48BFP_replicatecorr.axe_property('YGrid','on', 'XLim', [0 100], 'YLim', [0 100]);
allplates_48BFP_replicatecorr.set_color_options("chroma", 0, "lightness", 0);
allplates_48BFP_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
figure
allplates_48BFP_replicatecorr.draw();
%set([allplates_Zscores_both.results.stat_glm.text_handle],'Position',[0.7
%0.2]); %% couldn't figure out how to do this so just changed it within the
%gramm stat_glm.m function
allplates_48BFP_replicatecorr.update('color', data.cat);
allplates_48BFP_replicatecorr.set_color_options();
allplates_48BFP_replicatecorr.geom_point('alpha', 0.6);
allplates_48BFP_replicatecorr.draw();
%set([allplates_48BFP_replicatecorr.results.geom_point_handle],'FaceAlpha',0.4);
allplates_48BFP_replicatecorr.export('file_name','allplates_48BFP_replicate_scatter','export_path',export_path, ...
    'file_type','pdf');

allplates_48BFP_Zscore_replicatecorr=gramm('x', z_data3.Zscore_48BFP_A, 'y', z_data3.Zscore_48BFP_B, 'subset', ~strcmp(z_data.Type, 'E'));
allplates_48BFP_Zscore_replicatecorr.set_title("Correlation Between Replicates' 48H BFP Z-Scores");
allplates_48BFP_Zscore_replicatecorr.set_names('x', '48H Survival Z-Score - Replicate A', 'y', '48H Survival Z-Score - Replicate B');
allplates_48BFP_Zscore_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48BFP_Zscore_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
allplates_48BFP_Zscore_replicatecorr.set_color_options('map', [0 0.8 1]);
allplates_48BFP_Zscore_replicatecorr.draw();
%set([allplates_Zscores_both.results.stat_glm.text_handle],'Position',[0.7
%0.2]); %% couldn't figure out how to do this so just changed it within the
%gramm stat_glm.m function
%allplates_48BFP_Zscore_replicatecorr.update('color', data.cat);
allplates_48BFP_Zscore_replicatecorr.update("color",z_data.Type);
allplates_48BFP_Zscore_replicatecorr.set_color_options('map',[0 0.5 0.9]);
allplates_48BFP_Zscore_replicatecorr.axe_property('XAxisLocation','origin', 'YAxisLocation', 'origin','XLim', [-3 6], 'YLim', [-3 6]);
allplates_48BFP_Zscore_replicatecorr.geom_point('alpha', 0.6);
figure
allplates_48BFP_Zscore_replicatecorr.draw();
allplates_48BFP_Zscore_replicatecorr.export('file_name','allplates_Z_score_48BFP_replicate_scatter','export_path',export_path, ...
    'file_type','pdf');

allplates_48Neur_replicatecorr=gramm('x',data.NormNeurite_48H_A, 'y', data.NormNeurite_48H_B, 'subset', ~(strcmp(data.Plate, '3651')+strcmp(data.Type, 'E')));
allplates_48Neur_replicatecorr.set_title('Correlation Between Replicates - Neurite Outgrowth - 48H');
allplates_48Neur_replicatecorr.set_names('x', '48H Neurite Outgrowth - Replicate A', 'y', '48H Neurite Outgrowth - Replicate B');
allplates_48Neur_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48Neur_replicatecorr.axe_property('YGrid','on', 'XLim', [0 150], 'YLim', [0 150]);
allplates_48Neur_replicatecorr.set_color_options("chroma", 0, "lightness", 0);
allplates_48Neur_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
figure
allplates_48Neur_replicatecorr.draw();
allplates_48Neur_replicatecorr.update('color', data.cat);
allplates_48Neur_replicatecorr.set_color_options();
allplates_48Neur_replicatecorr.geom_point('alpha', 0.6);
allplates_48Neur_replicatecorr.draw();
%set([allplates_48BFP_replicatecorr.results.geom_point_handle],'FaceAlpha',0.4);
allplates_48Neur_replicatecorr.export('file_name','allplates_48Neur_replicate_scatter','export_path',export_path, ...
    'file_type','pdf');

allplates_48Neur_Zscore_replicatecorr=gramm('x', z_data3.Zscore_48BFP_A, 'y', z_data3.Zscore_48BFP_B, 'subset', ~strcmp(z_data.Type, 'E'));
allplates_48Neur_Zscore_replicatecorr.set_title("Correlation Between Replicates' 48H Survival Z-Scores");
allplates_48Neur_Zscore_replicatecorr.set_names('x', '48H Survival Z-Score - Replicate A', 'y', '48H Survival Z-Score - Replicate B');
allplates_48Neur_Zscore_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48Neur_Zscore_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
allplates_48Neur_Zscore_replicatecorr.set_color_options('map', [0 0.8 1]);
allplates_48Neur_Zscore_replicatecorr.draw();
%set([allplates_Zscores_both.results.stat_glm.text_handle],'Position',[0.7
%0.2]); %% couldn't figure out how to do this so just changed it within the
%gramm stat_glm.m function
%allplates_48BFP_Zscore_replicatecorr.update('color', data.cat);
allplates_48Neur_Zscore_replicatecorr.update("color",z_data.Type);
allplates_48Neur_Zscore_replicatecorr.set_color_options('map',[0 0.5 0.9]);
allplates_48Neur_Zscore_replicatecorr.axe_property('XAxisLocation','origin', 'YAxisLocation', 'origin','XLim', [-3 8], 'YLim', [-3 8]);
allplates_48Neur_Zscore_replicatecorr.geom_point('alpha', 0.6);
figure
allplates_48Neur_Zscore_replicatecorr.draw();
allplates_48Neur_Zscore_replicatecorr.export('file_name','allplates_48BFP_Zscore_replicate_scatter','export_path',export_path, ...
    'file_type','pdf');


allplates_48Neur_Zscore_replicatecorr=gramm('x', z_data3.Zscore_48Neur_A, 'y', z_data3.Zscore_48Neur_B, 'subset', ~strcmp(z_data.Type, 'E'));
allplates_48Neur_Zscore_replicatecorr.set_title("Correlation Between Replicates' 48H Outgrowth Z-Scores");
allplates_48Neur_Zscore_replicatecorr.set_names('x', '48H Outgrowth Z-Score - Replicate A', 'y', '48H Outgrowth Z-Score - Replicate B');
allplates_48Neur_Zscore_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48Neur_Zscore_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
allplates_48Neur_Zscore_replicatecorr.set_color_options('map', [0 0.8 1]);
allplates_48Neur_Zscore_replicatecorr.draw();
%set([allplates_Zscores_both.results.stat_glm.text_handle],'Position',[0.7
%0.2]); %% couldn't figure out how to do this so just changed it within the
%gramm stat_glm.m function
%allplates_48BFP_Zscore_replicatecorr.update('color', data.cat);
allplates_48Neur_Zscore_replicatecorr.update("color",z_data.Type);
allplates_48Neur_Zscore_replicatecorr.set_color_options('map',[0 0.5 0.9]);
allplates_48Neur_Zscore_replicatecorr.axe_property('XAxisLocation','origin', 'YAxisLocation', 'origin','XLim', [-3 8], 'YLim', [-3 8]);
allplates_48Neur_Zscore_replicatecorr.geom_point('alpha', 0.6);
figure
allplates_48Neur_Zscore_replicatecorr.draw();
allplates_48Neur_Zscore_replicatecorr.export('file_name','allplates_48Neur_Zscore_replicate_scatter','export_path',export_path, ...
    'file_type','pdf');



allplates_Zscores_BFP=gramm('x', z_data3.Well, 'y', z_data3.Zscore_48BFP, 'color', z_data3.BFP48_hit);
allplates_Zscores_BFP.geom_point();
allplates_Zscores_BFP.geom_abline('intercept', 2, 'slope', 0);
allplates_Zscores_BFP.set_title('Cell Survival Z-scores Across All Plates - 48H');
allplates_Zscores_BFP.set_names('x', 'Well', 'y', '48H Cell Survival Z-score');
allplates_Zscores_BFP.set_text_options('font','Arial','base_size',15);
allplates_Zscores_BFP.axe_property('YGrid','on','XTick', [], 'XTickLabel', '', 'YLim', [-4 8]);
figure
allplates_Zscores_BFP.draw();
allplates_Zscores_BFP.export('file_name','allplates_Zscores_BFP','export_path',export_path, ...
    'file_type','pdf');

allplates_Zscores_Neur=gramm('x', z_data3.Well, 'y', z_data3.Zscore_48Neur, 'color', z_data3.Neur48_hit);
allplates_Zscores_Neur.geom_point();
allplates_Zscores_Neur.set_title('Neurite Outgrowth Z-scores Across All Plates - 48H');
allplates_Zscores_Neur.geom_abline('intercept', 2, 'slope', 0);
allplates_Zscores_Neur.set_names('x', 'Well', 'y', '48H Neurite Outgrowth Z-score');
allplates_Zscores_Neur.set_text_options('font','Arial','base_size',15);
allplates_Zscores_Neur.axe_property('YGrid','on', 'XTick', [], 'XTickLabel', '', 'YLim', [-4 8]);
figure
allplates_Zscores_Neur.draw();
allplates_Zscores_Neur.export('file_name','allplates_Zscores_Neur','export_path',export_path, ...
    'file_type','pdf');


allplates_Zscores_both=gramm('x', z_data3.Zscore_48BFP, 'y', z_data3.Zscore_48Neur, 'color', z_data3.both48_hit);
%%,...
    %'subset', strcmp(z_data.both48_hit, 'Hit'), 'label', z_data.CompoundName);
allplates_Zscores_both.geom_point();
%allplates_Zscores_both.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','auto','Color','k', 'dodge', 2);
allplates_Zscores_both.set_title('Neurite Outgrowth & Cell Survival Z-scores - All Plates - 48H');
allplates_Zscores_both.set_names('x', '48H Cell Survival Z-score', 'y', '48H Neurite Outgrowth Z-score');
allplates_Zscores_both.geom_abline('intercept', 2, 'slope', 0);
allplates_Zscores_both.geom_vline('xintercept',2);
allplates_Zscores_both.set_text_options('font','Arial','base_size',15);
%allplates_Zscores_both.set_color_options('map', 'brewer1');
% allplates_Zscores_both.axe_property('YGrid','on', 'XLim', [1 6], 'XTick',[1 2 3 4 5 6], ...
%     'YLim', [1 6], 'YTick',[1 2 3 4 5 6]);
%allplates_Zscores_both.no_legend();
allplates_Zscores_both.axe_property('YGrid','on', 'XLim', [-4 8], 'XTick',[-4 -3 -2 -1 0 1 2 3 4 5 6 7 8], ...
    'YLim', [-4 8], 'YTick',[-4 -3 -2 -1 0 1 2 3 4 5 6 7 8], 'XAxisLocation','origin', 'YAxisLocation', 'origin');
figure
allplates_Zscores_both.draw();
allplates_Zscores_both.export('file_name','allplates_Zscores_both','export_path',export_path, ...
    'file_type','pdf');


%% with negative controls


allplates_48BFP_Zscore_replicatecorr=gramm('x', zneg_data3.Zscore_48BFP_A_neg, 'y', zneg_data3.Zscore_48BFP_B_neg, 'subset', ~strcmp(zneg_data3.Plate, '3651'));
allplates_48BFP_Zscore_replicatecorr.set_title("Correlation Between Replicates' 48H BFP Z-Scores");
allplates_48BFP_Zscore_replicatecorr.set_names('x', '48H Survival Z-Score - Replicate A', 'y', '48H Survival Z-Score - Replicate B');
allplates_48BFP_Zscore_replicatecorr.set_order_options('x', -1);
allplates_48BFP_Zscore_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48BFP_Zscore_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
allplates_48BFP_Zscore_replicatecorr.set_color_options('map', [0 0 0]);
allplates_48BFP_Zscore_replicatecorr.draw();
%set([allplates_Zscores_both.results.stat_glm.text_handle],'Position',[0.7
%0.2]); %% couldn't figure out how to do this so just changed it within the
%gramm stat_glm.m function
%allplates_48BFP_Zscore_replicatecorr.update('color', data.cat);
allplates_48BFP_Zscore_replicatecorr.update("color",zneg_data3.cat);
allplates_48BFP_Zscore_replicatecorr.set_color_options('map',[0 0 0;0 0.5 0.9]);
allplates_48BFP_Zscore_replicatecorr.axe_property('XAxisLocation','origin', 'YAxisLocation', 'origin','XLim', [-3 6], 'YLim', [-3 6]);
allplates_48BFP_Zscore_replicatecorr.geom_point('alpha', 0.4);
figure
allplates_48BFP_Zscore_replicatecorr.draw();
allplates_48BFP_Zscore_replicatecorr.export('file_name','allplates_48BFP_Zscore_replicate_scatter_withNeg_noPlate1','export_path',export_path, ...
    'file_type','pdf');


allplates_48Neur_Zscore_replicatecorr=gramm('x', zneg_data3.Zscore_48Neur_A_neg, 'y', zneg_data3.Zscore_48Neur_B_neg, 'subset', ~strcmp(zneg_data3.Plate,'3651'));
allplates_48Neur_Zscore_replicatecorr.set_title("Correlation Between Replicates' 48H Neurite Z-Scores");
allplates_48Neur_Zscore_replicatecorr.set_names('x', '48H Outgrowth Z-Score - Replicate A', 'y', '48H Outgrowth Z-Score - Replicate B');
allplates_48Neur_Zscore_replicatecorr.set_text_options('font','Arial','base_size',15);
allplates_48Neur_Zscore_replicatecorr.stat_glm('distribution', 'normal', 'geom', 'area', 'fullrange', 'true','disp_fit', 'true');
allplates_48Neur_Zscore_replicatecorr.set_color_options('map', [0 0 0]);
allplates_48Neur_Zscore_replicatecorr.draw();
%set([allplates_Zscores_both.results.stat_glm.text_handle],'Position',[0.7
%0.2]); %% couldn't figure out how to do this so just changed it within the
%gramm stat_glm.m function
%allplates_48BFP_Zscore_replicatecorr.update('color', data.cat);
allplates_48Neur_Zscore_replicatecorr.update("color",zneg_data3.cat);
allplates_48Neur_Zscore_replicatecorr.set_order_options('x', -1);
allplates_48Neur_Zscore_replicatecorr.set_color_options('map',[0 0 0;0 0.5 0.9]);
allplates_48Neur_Zscore_replicatecorr.axe_property('XAxisLocation','origin', 'YAxisLocation', 'origin','XLim', [-3 6], 'YLim', [-3 6]);
allplates_48Neur_Zscore_replicatecorr.geom_point('alpha', 0.4);
figure
allplates_48Neur_Zscore_replicatecorr.draw();
allplates_48Neur_Zscore_replicatecorr.export('file_name','allplates_48Neur_Zscore_replicate_scatter_withNeg_noPlate1','export_path',export_path, ...
    'file_type','pdf');


allplates_Zscores_BFP=gramm('x', zneg_data3.well_ID, 'y', zneg_data3.Zscore_48BFP_neg, 'color', zneg_data3.cat);
allplates_Zscores_BFP.geom_point('alpha', 0.5);
allplates_Zscores_BFP.geom_abline('intercept', 2, 'slope', 0);
allplates_Zscores_BFP.set_title('Cell Survival Z-scores Across All Plates - 48H');
allplates_Zscores_BFP.set_names('x', 'Well ID', 'y', '48H Cell Survival Z-score');
allplates_Zscores_BFP.set_text_options('font','Arial','base_size',15);
allplates_Zscores_BFP.axe_property('YGrid','on',  'YLim', [-4 6], 'XTick','');
%'XTickMode', 'manual', ...
    %'XTick', ['3561_K13'  '3655_J12']
figure
allplates_Zscores_BFP.draw();
allplates_Zscores_BFP.export('file_name','allplates_Zscores_BFP_byPlate_withNeg_bycat','export_path',export_path, ...
    'file_type','pdf');

allplates_Zscores_Neur=gramm('x', zneg_data3.Well, 'y', zneg_data3.Zscore_48Neur_neg, 'color', zneg_data3.cat);
allplates_Zscores_Neur.geom_point('alpha', 0.5);
allplates_Zscores_Neur.set_title('Neurite Outgrowth Z-scores Across All Plates - 48H');
allplates_Zscores_Neur.geom_abline('intercept', 2, 'slope', 0);
allplates_Zscores_Neur.set_names('x', 'Well', 'y', '48H Neurite Outgrowth Z-score');
allplates_Zscores_Neur.set_text_options('font','Arial','base_size',15);
allplates_Zscores_Neur.axe_property('YGrid','on', 'XTick', [], 'XTickLabel', '', 'YLim', [-4 6]);
figure
allplates_Zscores_Neur.draw();
allplates_Zscores_Neur.export('file_name','allplates_Zscores_Neur_withNeg_bycat','export_path',export_path, ...
    'file_type','pdf');


allplates_Zscores_both=gramm('x', zneg_data3.Zscore_48BFP_neg, 'y', zneg_data3.Zscore_48Neur_neg, 'color', zneg_data3.cat);
%%,...
    %'subset', strcmp(z_data.both48_hit, 'Hit'), 'label', z_data.CompoundName);
allplates_Zscores_both.geom_point('alpha', 0.5);
%allplates_Zscores_both.geom_label('VerticalAlignment','middle','HorizontalAlignment','center','BackgroundColor','auto','Color','k', 'dodge', 2);
allplates_Zscores_both.set_title('Neurite Outgrowth & Cell Survival Z-scores - All Plates - 48H');
allplates_Zscores_both.set_names('x', '48H Cell Survival Z-score', 'y', '48H Neurite Outgrowth Z-score');
allplates_Zscores_both.geom_abline('intercept', 2, 'slope', 0);
allplates_Zscores_both.geom_vline('xintercept',2);
allplates_Zscores_both.set_text_options('font','Arial','base_size',15);
%allplates_Zscores_both.set_color_options('map', 'brewer1');
% allplates_Zscores_both.axe_property('YGrid','on', 'XLim', [1 6], 'XTick',[1 2 3 4 5 6], ...
%     'YLim', [1 6], 'YTick',[1 2 3 4 5 6]);
%allplates_Zscores_both.no_legend();
allplates_Zscores_both.axe_property('YGrid','on', 'XLim', [-4 6], 'XTick',[-4 -3 -2 -1 0 1 2 3 4 5 6], ...
    'YLim', [-4 6], 'YTick',[-4 -3 -2 -1 0 1 2 3 4 5 6]);
figure
allplates_Zscores_both.draw();
allplates_Zscores_both.export('file_name','allplates_Zscores_both_withNeg_bycat','export_path',export_path, ...
    'file_type','pdf');





