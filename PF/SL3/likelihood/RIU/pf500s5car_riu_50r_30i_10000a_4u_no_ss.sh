#!/bin/bash -v
# IC with SSD with 25r and SubSeq 5
set -x
DB_ROOT_PATH="/home/abhineet/Secondary/Datasets/"
SETTINGS="mtf_sm pf mtf_ssm sl3 mtf_res 50 mtf_ilm 0 res_from_size 0 enable_nt 1 max_iters 30 epsilon 1e-4 db_root_path $DB_ROOT_PATH write_tracking_data 1 overwrite_gt 0 show_tracking_error 1 tracking_err_type 0 reinit_with_new_obj 0 reinit_at_each_frame 0 reinit_gt_from_bin 1 reinit_frame_skip 5 reinit_err_thresh 20 use_opt_gt 0 pause_after_frame 0 show_cv_window 0 init_frame_id 0 start_frame_id 0 frame_gap 1 read_obj_from_gt 1 invalid_state_check 1 invalid_state_err_thresh 0 img_resize_factor 1"
PF_SETTINGS="pf_n_particles 500 pf_max_iters 1 pf_dynamic_model 1 pf_update_type 1 pf_likelihood_func 0 pf_resampling_type 1 pf_reset_to_mean 0 pf_mean_type 0 pf_ssm_sigma_ids 5 pf_ssm_mean_ids -1 pf_update_distr_wts 0 pf_min_distr_wt 0.1 pf_pix_sigma 0 pf_measurement_sigma 0.1 pf_show_particles 0 pf_update_template 0 pf_jacobian_as_sigma 0 enable_learning 0 pf_debug_mode 0"
RIU_SETTINGS="likelihood_alpha 10000 likelihood_beta 0 dist_from_likelihood 0"
SL3_SETTINGS="sl3_normalized_init 1 sl3_iterative_sample_mean 1 sl3_sample_mean_max_iters 10 sl3_sample_mean_eps 1e-4 sl3_debug_mode 0"
ACTORS=(TMT UCSB LinTrack PAMI LinTrackShort METAIO CMT VOT VOT16 VTB VIVID TrakMark TMT_FINE)

START_IDS=(0 0 0 0 0 0 0 0 0 0 0 0 0)
N_SEQS=(109 96 3 28 14 40 20 25 60 100 9 21 24)
ACTOR_IDS=(0 1 2 3)
N_SUB_SEQ=10
EXEC_NAME=runMTF_vabh
TRACKING_DATA_FNAME=pf500s5car_riu50r30i1e4a4u_sl3_0
N_ACTORS=${#ACTOR_IDS[@]}
ACTOR_IDS_IDX=0
while [ $ACTOR_IDS_IDX -lt ${N_ACTORS} ]; do	
	ACTOR_ID=${ACTOR_IDS[$ACTOR_IDS_IDX]}
	N_SEQ=${N_SEQS[$ACTOR_ID]}
	ACTOR=${ACTORS[$ACTOR_ID]}
	SUBSEQ_FNAME="$DB_ROOT_PATH/$ACTOR/subseq_start_ids_$N_SUB_SEQ.txt"	
	mapfile -t ACTOR_SUBSEQ_START_IDS < $SUBSEQ_FNAME
	N_FRAMES_COUNT=${#ACTOR_SUBSEQ_START_IDS[@]}
	echo "ACTOR_IDS_IDX: $ACTOR_IDS_IDX"	
	echo "ACTOR_ID: $ACTOR_ID"	
	echo "ACTOR: $ACTOR"	
	echo "N_SEQ: $N_SEQ"
	echo "N_FRAMES_COUNT: $N_FRAMES_COUNT"
	if [ $N_FRAMES_COUNT != $N_SEQ ]; then
		echo "N_FRAMES_COUNT does not match N_SEQ"
		let ACTOR_IDS_IDX=ACTOR_IDS_IDX+1
		continue
	fi
	# printf '%s\n' "${ACTOR_SUBSEQ_START_IDS[@]}"
	SEQ_ID=${START_IDS[$ACTOR_ID]}
	saveIFS=$IFS
	while [ $SEQ_ID -lt ${N_SEQ} ]; do		
		IFS=","
		SUBSEQ_START_IDS=(${ACTOR_SUBSEQ_START_IDS[$SEQ_ID]})
		# printf '%s\n' "${SUBSEQ_START_IDS[@]}"
		IFS=$saveIFS
		SUBSEQ_ID=0
		while [ $SUBSEQ_ID -lt 1 ]; do		
			INIT_ID=${SUBSEQ_START_IDS[$SUBSEQ_ID]}
			$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am riu reinit_on_failure 0 $PF_SETTINGS $RIU_SETTINGS $SL3_SETTINGS init_frame_id $INIT_ID			
			let SUBSEQ_ID=SUBSEQ_ID+1
		done
		$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am riu reinit_on_failure 1 $PF_SETTINGS $RIU_SETTINGS $SL3_SETTINGS			
		let SEQ_ID=SEQ_ID+1 		
	done
	let ACTOR_IDS_IDX=ACTOR_IDS_IDX+1
done
