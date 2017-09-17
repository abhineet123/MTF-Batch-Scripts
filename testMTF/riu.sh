#!/bin/bash -v
# IC with SSD with 25r and SubSeq 5
set -x
DB_ROOT_PATH="/home/abhineet/Secondary/Datasets/"
SETTINGS="mtf_sm pf mtf_am riu mtf_ssm sl3 mtf_res 50 mtf_ilm 0 likelihood_alpha 1 res_from_size 0 enable_nt 0 max_iters 30 epsilon 1e-4 db_root_path $DB_ROOT_PATH write_tracking_data 1 pre_proc_type 1  overwrite_gt 0 show_tracking_error 1 tracking_err_type 0 reinit_with_new_obj 0 reinit_at_each_frame 0 reinit_gt_from_bin 1 reinit_frame_skip 5 reinit_err_thresh 20 use_opt_gt 0 pause_after_frame 0 show_cv_window 0 init_frame_id 0 start_frame_id 0 frame_gap 1 read_obj_from_gt 1 invalid_state_check 1 invalid_state_err_thresh 0 img_resize_factor 1"
DIAG_SETTINGS="diag_am riu diag_ssm 2 diag_ilm 0 diag_inv 0 diag_res 100 diag_range 20 diag_ssm_range_id 93 diag_am_range_id -1 diag_3d 1 diag_3d_ids 0,1 diag_frame_gap 0 diag_update_type 0 diag_start_id 0 diag_end_id -1 diag_show_data 0 diag_show_corners 0 diag_show_patches 0 diag_verbose 1 diag_bin 1 diag_grad_diff 1e-2 diag_gen_norm 100 diag_gen_jac #111 diag_gen_hess #1111 diag_gen_hess2 #1000 diag_gen_hess_sum #1111 diag_gen_num #110 diag_gen_ssm 0 diag_enable_validation 0 diag_validation_prec 1e-20 dist_from_likelihood 1 likelihood_alpha #500"
EXEC_NAME=testMTF
ACTOR_IDS=(0 1 1 3 3 0)
SEQ_IDS=(2 41 48 2 11 39)
N_SEQS=${#SEQ_IDS[@]}
SEQ_IDX_ID=0
DIAG_OUT_PREFIX=riu_2
while [ $SEQ_IDX_ID -lt ${N_SEQS} ]; do
	SEQ_ID=${SEQ_IDS[$SEQ_IDX_ID]}
	ACTOR_ID=${ACTOR_IDS[$SEQ_IDX_ID]}
	$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID diag_out_prefix $DIAG_OUT_PREFIX $SETTINGS $DIAG_SETTINGS diag_3d 0
	$EXEC_NAME actor_id $ACTOR_ID source_id $SEQ_ID diag_out_prefix $DIAG_OUT_PREFIX $SETTINGS $DIAG_SETTINGS diag_3d 1
	let SEQ_IDX_ID=SEQ_IDX_ID+1 
done
