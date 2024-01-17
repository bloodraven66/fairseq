import os
from pathlib import Path
import argparse
import librosa
from tqdm import tqdm

parser = argparse.ArgumentParser()
parser.add_argument('--data_dir', type=str, default='/home1/Sathvik/fairseq_datasets/LibriLight/librispeech_finetuning')
parser.add_argument('--output_dir', type=str, default='/home1/Sathvik/fairseq_datasets/LibriLight/fairseq_files')
parser.add_argument("--version", default="10hr")
parser.add_argument("--mode", default="train")
parser.add_argument("--dict_and_lexicon", default=False)
args = parser.parse_args()

def get_all_files_with_extension_from_nested_folder(root_dir, extension):
    return list(Path(root_dir).rglob(f'*.{extension}'))

def make_files(keys, audios, texts, save_folder):
    with open(os.path.join(save_folder, f'{args.mode}.tsv'), 'w') as f:
        f.write(".\n")
        for id_ in tqdm(keys):
            y, sr = librosa.load(audios[id_], sr=16000)
            f.write(f'{audios[id_]}\t{len(y)}\n')
    
    with open(os.path.join(save_folder, f'{args.mode}.wrd'), 'w') as f:
        for x in tqdm(keys):
            f.write(f'{texts[x]}\n')
        
    with open(os.path.join(save_folder, f'{args.mode}.ltr'), 'w') as f:
        for x in tqdm(keys):
            t = texts[x]
            t = " ".join(t.replace(" ", "|")) + " |"
            f.write(f'{t}\n')
    
    if args.dict_and_lexicon:
    
        words = {}
        chars = set()
        for x in texts:
            for w in texts[x].split(" "):
                chars.update(w)
                if w not in words:
                    words[w] = " ".join(w) + " |"
        
        with open(os.path.join(save_folder, 'lexicon.lst'), 'w') as f:
            for w in words:
                f.write(f'{w}\t{words[w]}\n')
            
        chars = list(chars)
        with open(os.path.join(save_folder, 'dict.ltr.txt'), 'w') as f:
            for i in range(len(chars)):
                f.write(f'{chars[i]} {i}\n')
                

def main():
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)
    audios = get_all_files_with_extension_from_nested_folder(args.data_dir, 'flac')
    txts = get_all_files_with_extension_from_nested_folder(args.data_dir, 'trans.txt')
    audios = {Path(audio).stem: audio for audio in audios}
    texts = {}
    for x in txts:
        with open(x, 'r') as f:
            data = f.read().split('\n')
        for line in data:
            if len(line.strip()) == 0: continue

            id_ = line.split(' ')[0]
            text = ' '.join(line.split(' ')[1:]).lower()
            texts[id_] = text
            assert id_ in audios
    
    assert len(audios) == len(texts)
    save_folder = os.path.join(args.output_dir, args.version)
    if not os.path.exists(save_folder):
        os.makedirs(save_folder)
    keys = sorted(list(audios.keys()))
    
    make_files(keys, audios, texts, save_folder)
    
    
    
    

if __name__ == '__main__':
    main()