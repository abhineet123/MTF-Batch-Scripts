#!/bin/bash -v
# IC with SSD with 25r and SubSeq 5
set -x
DB_ROOT_PATH="/home/abhineet/Secondary/Datasets/"
SETTINGS="mtf_sm ic mtf_ssm 8 mtf_res 50 mtf_ilm 0 res_from_size 0 enable_nt 0 epsilon 1e-4 db_root_path $DB_ROOT_PATH write_tracking_data 1 pre_proc_type 1  overwrite_gt 0 show_tracking_error 1 tracking_err_type 0 reinit_with_new_obj 0 reinit_at_each_frame 0 reinit_gt_from_bin 1 reinit_frame_skip 5 reinit_err_thresh 20 use_opt_gt 0 pause_after_frame 0 show_cv_window 0 init_frame_id 0 start_frame_id 0 frame_gap 1 read_obj_from_gt 1"
IC_SETTINGS="ic_update_ssm 0 leven_marq 0 lm_delta_init 0.01 lm_delta_update 10 ic_chained_warp 1 enable_learning 0 ic_hess_type  0"
HOM_SETTINGS="hom_corner_based_sampling 1 hom_normalized_init 1"
ACTORS=(TMT UCSB LinTrack PAMI LinTrackShort METAIO CMT VOT VOT16 VTB VIVID TrakMark TMT_FINE)

N_SEQS=(109 96 3 28 14 40 20 25 60 100 9 21 24)
ACTOR_IDS=(1)
N_SUB_SEQ=10
INIT_ID_GAP=5
EXEC_NAME=runMTF_vabh
TRACKING_DATA_FNAME=iccw1C1_ssd50r30i4u_8_0
echo "$TRACKING_DATA_FNAME" >> list.txt
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
	# printf '%s\n' "${ACTOR_SUBSEQ_START_IDS[@]}"
	printf '\n'
	if [ $N_FRAMES_COUNT != $N_SEQ ]; then
		echo "N_FRAMES_COUNT does not match N_SEQ"
		let ACTOR_IDS_IDX=ACTOR_IDS_IDX+1
		continue
	fi
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
			$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID tracking_data_fname $TRACKING_DATA_FNAME $SETTINGS mtf_am ssd reinit_on_failure 0 $IC_SETTINGS $HOM_SETTINGS init_frame_id $INIT_ID
			let SUBSEQ_ID=SUBSEQ_ID+1
		done
		let SEQ_ID=SEQ_ID+1 		
	done
	let ACTOR_IDS_IDX=ACTOR_IDS_IDX+1
done
