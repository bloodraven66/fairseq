#!/bin/bash

set -e

exp_tag="librilight10"
subset="test_other"
results="/home1/Sathvik/fairseq_results"
wav2vec2_path="/home1/Sathvik/fairseq_models/librilight_checkpoints/checkpoint_556_20000_10h_default_adapter128_ft-on_default_wav2vec.pt"
data="/home1/Sathvik/fairseq_datasets/LibriLight/fairseq_files/10hr/"
lexicon="/home1/Sathvik/fairseq_datasets/LibriLight/fairseq_files/10hr/lexicon.lst"
beam="70"
lm="viterbi"
final_results_folder="/home1/Sathvik/fairseq_results/librispeech100"

[ -e $results/hypo.units-checkpoint_best.pt-test.txt ] && rm $results/*.txt
[ -e $results/hypo.units-checkpoint_best.pt-valid.txt ] && rm $results/*.txt

python3 examples/speech_recognition/infer.py $data \
                --task audio_finetuning \
                --nbest 1 \
                --path $wav2vec2_path \
                --gen-subset $subset  \
                --results-path $results \
                --w2l-decoder $lm \
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
