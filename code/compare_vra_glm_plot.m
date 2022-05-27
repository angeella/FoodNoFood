%NB: Unzippare i file .nii.gz, o decommentare i due comandi gunzip.

% media e dev std con pallini di colori proporzionali alla significativit? delle mappe T relative al tempo considerato e IBR
% singoli blocchi sovrapposti con anche il valor medio. 
% plotto in ROSSO la risposta del modello
clc
clear all
close all

my_path = 'F:\FSL\FoodNoFood\';
% cartella con tutti i soggetti
BOLD_folder=(fullfile(my_path,'volume'));

current_subj='sub-02';

T_GLM_folder=(fullfile(my_path,'zstat'));

n_blocks=8;
rest_block_duration=16; %in realtà è tra 8 e 12
stim_block_duration=16;
tot_block_duration=rest_block_duration+stim_block_duration;
TR=1.6;

%T_GLM_folder=('/Users/francescodebertoldi/Desktop/RICERCA/HRV/dati_verb_generation/ANALISI 2017/pre-processed-all-subj-run1/sub003/first_level_onereg');

%load('task_regressor');
%task_regressor=task_regressor(2:end);
task_regressor = repmat(0,16*8,1);

%% carico il file con i dati BOLD del soggetto che ci interessa 
%gunzip(fullfile(BOLD_folder,[current_subj,'.nii.gz']));
final_image = load_nii(fullfile(BOLD_folder,[current_subj,'.nii']));
final_image = final_image.img;
final_image = final_image - repmat(mean(final_image,4),1,1,1, size(final_image,4));


%for j=1:n_blocks
%    block_start=1+(j-1)*(rest_block_duration+stim_block_duration);
%    block_stop=(rest_block_duration+stim_block_duration)*j;   
%    single_block_resp(:,:,:,j,:)=final_image(:,:,:,block_start:block_stop);
%end
  
single_block_resp(:,:,:,1,:)=final_image(:,:,:,[ 1:16 26:41]);
single_block_resp(:,:,:,2,:)=final_image(:,:,:,[49:64 71:86]);
single_block_resp(:,:,:,3,:)=final_image(:,:,:,[91:106 113:128]);
single_block_resp(:,:,:,4,:)=final_image(:,:,:,[138:153 158:173]);
single_block_resp(:,:,:,5,:)=final_image(:,:,:,[188:203 210:225]);
single_block_resp(:,:,:,6,:)=final_image(:,:,:,[235:250 258:273]);
single_block_resp(:,:,:,7,:)=final_image(:,:,:,[280:295 300:315]);
single_block_resp(:,:,:,8,:)=final_image(:,:,:,[322:337 347:362]);

time_axis=[0:TR:TR*(rest_block_duration+stim_block_duration-1)];

% definisco le coordinate di interesse (???)
x_coord=42;
y_coord=47;
z_coord=29;

%% carico la mappa GLM standard (verifica che sia la spm_0001)
%gunzip(fullfile(T_GLM_folder,[current_subj,'.nii.gz']));
T_map_GLM=load_nii(fullfile(T_GLM_folder,[current_subj,'.nii.gz']));
coord_GLM_T_value=T_map_GLM.img(x_coord,y_coord,z_coord);

%metto un valore a caso per adesso
% coord_GLM_T_value=4;

% estraggo i singoli blocchi e calcolo la risposta media
BOLD_blocks=squeeze(single_block_resp(x_coord,y_coord,z_coord,:,:))';

BOLD_mean=mean(BOLD_blocks');
BOLD_std=std(BOLD_blocks,0,2)';

new_T_value=BOLD_mean./BOLD_std*sqrt(7);

up_ci=BOLD_mean+BOLD_std;
low_ci=BOLD_mean-BOLD_std;

onset_seconds=0;
offset_seconds=57.5;
%offset_seconds=1.6;

index_start=find(time_axis==onset_seconds);
if isempty(index_start)
    index_start=find(time_axis>onset_seconds);
    index_start=index_start(1);
end

index_end=find(time_axis==offset_seconds);
if isempty(index_end)
    index_end=find(time_axis<offset_seconds);
    index_end=index_end(end);
end

task_regressor_norm=task_regressor*max(max(BOLD_blocks))*0.8;
[T_max_task,ind_max_task]=max(abs(new_T_value(1:stim_block_duration)));
[T_max_rest,ind_max_rest]=max(abs(new_T_value(stim_block_duration+1:end)));
ind_max_rest=ind_max_rest+stim_block_duration;

%% il rettangolo indica il periodo di stimolazione
figure; 
subplot(3,1,1); title(['GLM regressor. T max GLM:',num2str(coord_GLM_T_value,2)]);
% rectangle('Position',[0 min(min(BOLD_blocks))-1 time_axis(stim_block_duration+1) max(max(BOLD_blocks))-min(min(BOLD_blocks))+2],'FaceColor',[0.7 0.95 0.95],'EdgeColor','none');
% for j=1:stim_block_duration
%     rectangle('Position',[time_axis(j) min(min(BOLD_blocks))-1 1 max(max(BOLD_blocks))-min(min(BOLD_blocks))+3],'FaceColor',[0.7 0.95 0.95],'EdgeColor','none');
% end
hold on; plot(time_axis(index_start:index_end),task_regressor_norm(index_start:index_end),'r','LineWidth',2); grid on; axis tight;
hold on; plot(time_axis(index_start:index_end),BOLD_mean(index_start:index_end),'k','LineWidth',2); grid on; axis tight; xlim([0 time_axis(index_end)]);
legend({'GLM regressor';'mean BOLD'});

subplot(3,1,2); title(['BOLD response to blocks. Max T task: ',num2str(T_max_task,3),'. Max T rest: ',num2str(T_max_rest,3),'.']);
% for j=1:stim_block_duration
%     rectangle('Position',[time_axis(j) min(min(BOLD_blocks))-1 1 max(max(BOLD_blocks))-min(min(BOLD_blocks))+3],'FaceColor',[0.7 0.95 0.95],'EdgeColor','none');
% end
% rectangle('Position',[0 min(min(BOLD_blocks))-1 time_axis(stim_block_duration+1) max(max(BOLD_blocks))-min(min(BOLD_blocks))+3],'FaceColor',[0.7 0.95 0.95],'EdgeColor','none');
hold on; plot(time_axis(index_start:index_end),BOLD_mean(index_start:index_end),'k','LineWidth',2); 
hold on; plot(time_axis(index_start:index_end),BOLD_blocks,'LineWidth',0.5); grid on; axis tight;

%gdl=7; alpha = 0.05; time points = 32; thr= -qt(.05/2/32,7) = 5.001577

for j=index_start:index_end
    if (abs(new_T_value(j))>5.001577)
        rectangle('Position',[time_axis(j) max(max(BOLD_blocks))+0.5 TR 1.5],'FaceColor',[1 0 0],'EdgeColor','none');
    elseif (abs(new_T_value(j))>2)
        rectangle('Position',[time_axis(j) max(max(BOLD_blocks))+0.5 TR 1.5],'FaceColor',[1 .5 0],'EdgeColor','none');
    else
        rectangle('Position',[time_axis(j) max(max(BOLD_blocks))+0.5 TR 1.5],'FaceColor',[1 1 0],'EdgeColor','none');
    end
end

xlim([0 time_axis(index_end)]);

subplot(3,1,3); title('T max absolute value');
for j=1:stim_block_duration
   rectangle('Position',[time_axis(j) min(min(abs(new_T_value)))-0.5 1 max(max(abs(new_T_value)))-min(min(abs(new_T_value)))+1],'FaceColor',[0.7 0.95 0.95],'EdgeColor','none');
end
for j=(stim_block_duration+1):2*stim_block_duration
    rectangle('Position',[time_axis(j) min(min(abs(new_T_value)))-0.5 1 max(max(abs(new_T_value)))-min(min(abs(new_T_value)))+1],'FaceColor',[0.95 0.95 0.7],'EdgeColor','none');
end
% rectangle('Position',[0 0 time_axis(stim_block_duration+1) max(abs(new_T_value))+0.5],'FaceColor',[0.7 0.95 0.95],'EdgeColor','none');
% hold on; bar(time_axis(index_start:index_end),abs(new_T_value(index_start:index_end)),'FaceColor',[.9 .5 .9],'EdgeColor','none'); grid on; axis tight;
hold on; plot(time_axis(index_start:index_end),abs(new_T_value(index_start:index_end)),'-o','Color','b','MarkerEdgeColor','b','MarkerFaceColor',[0 .8 .8],'LineWidth',1.5); grid on; axis tight;
hold on; plot(time_axis(index_start:index_end),abs(new_T_value(index_start:index_end)),'Color','b'); grid on; axis tight; xlim([0 time_axis(index_end)]);
hold on; plot(time_axis(ind_max_task),abs(new_T_value(ind_max_task)),'o','MarkerFaceColor','red','MarkerEdgeColor','r');
hold on; plot(time_axis(ind_max_rest),abs(new_T_value(ind_max_rest)),'o','MarkerFaceColor','red','MarkerEdgeColor','r');
suptitle(['Coordinates: ',num2str(x_coord),' ',num2str(y_coord),' ',num2str(z_coord),'.']);

%% with T from GLM analysis
% suptitle(['Coordinates: ',num2str(x_coord),' ',num2str(y_coord),' ',num2str(z_coord),'. T max task: ',num2str(T_max_max),'. T max GLM: ',num2str(coord_GLM_T_value)]);

