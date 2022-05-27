clc
clear all
close all

my_path = 'F:\FSL\FoodNoFood\'; %to change with the path where the github folder is

BOLD_folder=(fullfile(my_path,'volume'));
addpath("C:\Users\Angela Andreella\Documents\MATLAB\spm8") %to drop off

mkdir(fullfile(my_path,'T_max'));

for s=19:30
  if s < 10
     current_subj = sprintf('sub-0%d', s);
  else
     current_subj = sprintf('sub-%d', s);
  end

  TR_maps_folder=(fullfile(my_path,'zstat'));

  n_blocks=8;
  rest_block_duration=16;
  stim_block_duration=16;
  tot_block_duration=rest_block_duration+stim_block_duration;
  TR=1.6;
  index_start=1;
  index_end=32;
  duration=index_end-index_start+1;

  %load BOLD data
  gunzip(fullfile(BOLD_folder,[current_subj,'.nii.gz']))
  final_image = load_nii(fullfile(BOLD_folder,[current_subj,'.nii']));
  final_image = final_image.img;
  final_image = final_image - repmat(mean(final_image,4),1,1,1, size(final_image,4));

  xdim=size(final_image,1);
  ydim=size(final_image,2);
  zdim=size(final_image,3);

  single_block_resp(:,:,:,1,:)=final_image(:,:,:,[ 1:16 26:41]);
  single_block_resp(:,:,:,2,:)=final_image(:,:,:,[49:64 71:86]);
  single_block_resp(:,:,:,3,:)=final_image(:,:,:,[91:106 113:128]);
  single_block_resp(:,:,:,4,:)=final_image(:,:,:,[138:153 158:173]);
  single_block_resp(:,:,:,5,:)=final_image(:,:,:,[188:203 210:225]);
  single_block_resp(:,:,:,6,:)=final_image(:,:,:,[235:250 258:273]);
  single_block_resp(:,:,:,7,:)=final_image(:,:,:,[280:295 300:315]);
  single_block_resp(:,:,:,8,:)=final_image(:,:,:,[322:337 347:362]);


%% calculation of T value from BOLD mean and standard deviation
  for i=1:xdim
      for j=1:ydim
          for k=1:zdim
            % extract single block and compute mean signal
              BOLD_blocks=squeeze(single_block_resp(i,j,k,:,:))';
              BOLD_mean=mean(BOLD_blocks');
              BOLD_std=std(BOLD_blocks,0,2)';
              T_val_stab(i,j,k,:)=BOLD_mean./BOLD_std*sqrt(7);  
              STD_vox(i,j,k,:)=BOLD_std;
          end
      end
  end
  
  %% max_t_value map, in cui prendo il massimo all'interno dell'intervallo che mi interessa
  abs_T=abs(T_val_stab);
  abs_max_T_value_map=max(abs_T(:,:,:,index_start:index_end),[],4);
  flip_abs_max_T_value_map=flip(abs_max_T_value_map); 

  % salvo la mappa max T value in un file chiamato max T value index_start index_end
  gunzip(fullfile(TR_maps_folder,[current_subj,'.nii.gz']))

 % save_folder = 'C:/Users/Angela Andreella/Desktop/';
  V=spm_vol(fullfile(TR_maps_folder, [current_subj,'.nii']));
  V.dim=size(flip_abs_max_T_value_map);
  V.dt=[16 0];
  V.mat=V.mat;
  V.fname=fullfile(my_path,'T_max\',[current_subj,'T_max_value_abs_',num2str(index_start),'_',num2str(index_end),'.nii']);
  V.descrip='T max value using mean BOLD divided by standard deviation';
  spm_write_vol(V,flip_abs_max_T_value_map);
  
end

