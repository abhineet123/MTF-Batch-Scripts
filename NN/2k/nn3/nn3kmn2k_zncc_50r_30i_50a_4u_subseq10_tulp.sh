#!/bin/bash -v
# IC with SSD with 25r and SubSeq 5
set -x
DB_ROOT_PATH="/home/abhineet/Secondary/Datasets/"
SETTINGS="mtf_sm nnk mtf_ssm 8 mtf_res 50 mtf_ilm 0 res_from_size 0 enable_nt 0 max_iters 30 epsilon 1e-4 db_root_path $DB_ROOT_PATH write_tracking_data 1  overwrite_gt 0 show_tracking_error 1 tracking_err_type 0 reinit_with_new_obj 0 reinit_at_each_frame 0 reinit_gt_from_bin 1 reinit_frame_skip 5 reinit_err_thresh 20 use_opt_gt 0 pause_after_frame 0 show_cv_window 0 init_frame_id 0 start_frame_id 0 frame_gap 1 read_obj_from_gt 1 invalid_state_check 1 invalid_state_err_thresh 0 img_resize_factor 1"
NN_SETTINGS="nn_n_samples 2000 nn_index_type 2 nn_load_index 0 nn_save_index 0 nn_search_type 0 nn_max_iters 1 nn_ssm_sigma_ids 2 nn_ssm_mean_ids 0 nn_pix_sigma 0 nn_n_checks 50 nn_additive_update 0 nn_show_samples 0 nn_add_points 0 nn_remove_points 0"
NNK_SETTINGS="nnk_n_layers 3 nnk_ssm_sigma_ids 0 nnk_ssm_sigma_ids 1 nnk_ssm_sigma_ids 2"
HOM_SETTINGS="hom_corner_based_sampling 1 hom_normalized_init 1"
ZNCC_SETTINGS="zncc_likelihood_alpha 50"
ACTORS=(TMT UCSB LinTrack PAMI LinTrackShort METAIO CMT VOT VOT16 VTB VIVID TrakMark TMT_FINE)

N_SEQS=(109 96 3 28 14 40 20 25 60 100 9 21 24)
ACTOR_IDS=(0 1 2 3)
N_SUB_SEQ=10
EXEC_NAME=runMTF_vabh
TRACKING_DATA_FNAME=nn3kmn2k2s_zncc50r1i4u_8_0
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
	SEQ_ID=0
	saveIFS=$IFS
	while [ $SEQ_ID -lt ${N_SEQ} ]; do		
		IFS=","
		SUBSEQ_START_IDS=(${ACTOR_SUBSEQ_START_IDS[$SEQ_ID]})
		# printf '%s\n' "${SUBSEQ_START_IDS[@]}"
		IFS=$saveIFS
		SUBSEQ_ID=0
		while [ $SUBSEQ_ID -lt $(($N_SUB_SEQ)) ]; do		
			INIT_ID=${SUBSEQ_START_IDS[$SUBSEQ_ID]}
			$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am zncc reinit_on_failure 0 $NN_SETTINGS $NNK_SETTINGS $ZNCC_SETTINGS $HOM_SETTINGS init_frame_id $INIT_ID			
			let SUBSEQ_ID=SUBSEQ_ID+1
		done
		$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am zncc reinit_on_failure 1 $NN_SETTINGS $NNK_SETTINGS $ZNCC_SETTINGS $HOM_SETTINGS
		let SEQ_ID=SEQ_ID+1 		
	done
	let ACTOR_IDS_IDX=ACTOR_IDS_IDX+1
done
