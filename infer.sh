#!/bin/bash

set -e

exp_tag="af_za"
subset="test"
results="/home1/Sathvik/fairseq_results"
# chk=checkpoint_last_10h_default_adapter_ft-on-adapter128-ssl-"$exp_tag"-10h-adapter-only-pretraining_50ksteps_patience5-indicwav2vec.pt
chk=checkpoint_last_10h_default_adapter_ft-on-adapter64-ssl-"$exp_tag"-10h-adapter-only-pretraining_50ksteps_patience5.pt
# chk=checkpoint_last_10h_default_adapter64_ft-on_indicwav2vec_50k_patience5.pt
#chk=checkpoint_last_10h_default_adapter64_ft-on_default_wav2vec_50_patience5.pt
wav2vec2_path=/home1/Sathvik/fairseq_models/respin_adapter_pretraining/$exp_tag/$chk
# data="/home1/Sathvik/fairseq_datasets/respin_asr_split_fairseq/$exp_tag/"
data="/home1/Sathvik/fairseq_datasets/FLEURS/$exp_tag"
# data=/home1/Sathvik/fairseq_datasets/LibriLight/fairseq_files/10hr/
lexicon="$data"/"lexicon.lst"
beam="70"
lm="viterbi"
# lm="kenlm"
# final_results_folder="/home1/Sathvik/fairseq_results/librispeech100"
kenlm_path=/home1/Sathvik/fairseq_models/respin_adapter_pretraining/$exp_tag/kenlm_model_4.arpa

[ -e $results/hypo.units-checkpoint_best.pt-test.txt ] && rm $results/*.txt
[ -e $results/hypo.units-checkpoint_best.pt-valid.txt ] && rm $results/*.txt

python3 examples/speech_recognition/infer.py $data \
                --task audio_finetuning \
                --nbest 1 \
                --path $wav2vec2_path \
                --gen-subset $subset  \
                --results-path $results \
                --w2l-decoder $lm \
                --lm-model $kenlm_path \
                --word-score -1 \
                --lm-weight 2 \
                --sil-weight 0 \
                --criterion ctc \
                --labels ltr \
                --max-tokens 4000000 \
                --post-process letter \
                --lexicon $lexicon \
                --beam $beam \

# python3 metrics.py $results $subset $kenlm $final_results_folder $exp_tag
