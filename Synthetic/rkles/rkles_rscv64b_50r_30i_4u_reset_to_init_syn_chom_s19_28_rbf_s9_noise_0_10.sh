#!/bin/bash -v
# IC with SSD with 25r and SubSeq 5
set -x
DB_ROOT_PATH="/home/abhineet/Secondary/Datasets/"
SETTINGS="mtf_sm rkl mtf_ssm 8 mtf_res 50 mtf_ilm 0 res_from_size 0 enable_nt 0 max_iters 30 epsilon 1e-4 db_root_path $DB_ROOT_PATH write_tracking_data 1 pre_proc_type 1  overwrite_gt 0 show_tracking_error 1 tracking_err_type 0 reinit_with_new_obj 0 reinit_at_each_frame 0 reset_at_each_frame 1 reset_to_init 1 reinit_gt_from_bin 1 use_reinit_gt 0 use_opt_gt 0 reinit_frame_skip 5 reinit_err_thresh 20 use_opt_gt 0 pause_after_frame 0 show_cv_window 0 init_frame_id 0 start_frame_id 0 frame_gap 1 read_obj_from_gt 1 invalid_state_check 1 invalid_state_err_thresh 0 img_resize_factor 1"
ESM_SETTINGS="sec_ord_hess 0 esm_jac_type 1 esm_hess_type 2 esm_chained_warp 1 enable_learning 0 leven_marq 0 lm_delta_init 0.01 lm_delta_update 10"
RKL_SETTINGS="rkl_sm esm rkl_enable_spi 0 rkl_enable_feedback 1 rkl_failure_detection 0 rkl_failure_thresh 15.0"
GRID_SETTINGS="grid_sm esm grid_am rscv grid_ssm 2 grid_ilm 0 grid_res 10 grid_patch_size 25 grid_patch_res 0 grid_patch_centroid_inside 1 grid_dyn_patch_size 0 grid_reset_at_each_frame 1 grid_show_trackers 0 grid_show_tracker_edges 0 grid_use_tbb 0 grid_pyramid_levels 2 grid_use_min_eig_vals 0 grid_min_eig_thresh 1e-4"
EST_SETTINGS="est_method 1 est_ransac_reproj_thresh 5 est_n_model_pts 4 est_max_iters 10000 est_max_subset_attempts 300 est_use_boost_rng 0 est_confidence 0.995 est_refine 1 est_lm_max_iters 10"
RSCV_SETTINGS="scv_use_bspl 0 scv_n_bins 64 scv_preseed 0 scv_pou 1 scv_weighted_mapping 0 scv_mapped_gradient 0 scv_affine_mapping 1 scv_once_per_frame 0 scv_approx_dist_feat 0"
HOM_SETTINGS="hom_corner_based_sampling 1 hom_normalized_init 1"
SYN_SETTINGS="syn_ssm c8 syn_ilm 0 syn_frame_id 0 syn_grayscale_img 1 syn_continuous_warping 1 syn_ssm_sigma_ids 25 syn_ssm_mean_ids 0 syn_am_sigma_ids 4 syn_am_mean_ids 0 syn_pix_sigma 0 syn_warp_entire_image 1 syn_background_type 0 syn_use_inv_warp 1 syn_out_suffix #warped_c8_s20 syn_n_frames 400 syn_add_noise 1 syn_noise_mean 0 syn_noise_sigma 10 syn_save_as_video 0 syn_video_fps 24 syn_jpg_quality 25 syn_show_output 0"
ACTORS=(TMT UCSB LinTrack PAMI LinTrackShort METAIO CMT VOT VOT16 VTB VIVID TrakMark TMT_FINE Mosaic Misc Synthetic)
N_SEQS=(109 96 3 28 14 40 20 25 60 100 9 21 24 5 17 25)
ACTOR_IDS=(15)
SYN_SSM_SIGMA_IDS=(19 20 21 22 23 24 25 26 27 28)
EXEC_NAME=runMTF_vabh
TRACKING_DATA_FNAME=rkles10rLMS25p10Ki5t_rscv64b50r30i4u_8_0
N_ACTORS=${#ACTOR_IDS[@]}
N_SYN_SSM_SIGMA_IDS=${#SYN_SSM_SIGMA_IDS[@]}
ACTOR_IDS_IDX=0
while [ $ACTOR_IDS_IDX -lt ${N_ACTORS} ]; do	
	ACTOR_ID=${ACTOR_IDS[$ACTOR_IDS_IDX]}
	N_SEQ=${N_SEQS[$ACTOR_ID]}
	echo "ACTOR_IDS_IDX: $ACTOR_IDS_IDX"	
	echo "ACTOR_ID: $ACTOR_ID"	
	echo "N_SEQ: $N_SEQ"
	SEQ_ID=0
	while [ $SEQ_ID -lt ${N_SEQ} ]; do
		SYN_SSM_SIGMA_IDS_IDX=0
		while [ $SYN_SSM_SIGMA_IDS_IDX -lt ${N_SYN_SSM_SIGMA_IDS} ]; do	
		
			SYN_SSM_SIGMA_ID=(${SYN_SSM_SIGMA_IDS[$SYN_SSM_SIGMA_IDS_IDX]})
			
			$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am rscv reinit_on_failure 0 $GRID_SETTINGS $RKL_SETTINGS $EST_SETTINGS $ESM_SETTINGS $HOM_SETTINGS $RSCV_SETTINGS $SYN_SETTINGS syn_ssm_sigma_ids $SYN_SSM_SIGMA_ID syn_add_noise 0
			
			$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am rscv reinit_on_failure 0 $GRID_SETTINGS $RKL_SETTINGS $EST_SETTINGS $ESM_SETTINGS $HOM_SETTINGS $RSCV_SETTINGS $SYN_SETTINGS syn_ssm_sigma_ids $SYN_SSM_SIGMA_ID syn_add_noise 1	

			$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am rscv reinit_on_failure 0 $GRID_SETTINGS $RKL_SETTINGS $EST_SETTINGS $ESM_SETTINGS $HOM_SETTINGS $RSCV_SETTINGS $SYN_SETTINGS syn_ssm_sigma_ids $SYN_SSM_SIGMA_ID syn_add_noise 1 syn_ilm rbf syn_am_sigma_ids 9
			
			let SYN_SSM_SIGMA_IDS_IDX=SYN_SSM_SIGMA_IDS_IDX+1
		done	
		let SEQ_ID=SEQ_ID+1 		
	done
	let ACTOR_IDS_IDX=ACTOR_IDS_IDX+1
done
