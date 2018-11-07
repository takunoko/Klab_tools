# RMSDを手動で計算するプログラム。
# AutoDockのRMSDを求めるプログラムとの比較を計算するために用いる

import numpy as np
import pandas as pd
import sys

def read_data(file_name):
    return pd.read_table(file_name, sep='\s+', names=('type', 'num', 'atom-num', 'groupe', 'flagment_num', 'x', 'y', 'z', 'A', 'B', 'charge', 'atom-type'))

if __name__ == '__main__':
    args = sys.argv
    if len(args) != 3:
        print("""
        実行形式が違います
        cal_RMSD.py (構造ファイル).pdb (構造ファイル).pdb
        の形式で実行してください""")
        sys.exit()

    # データの読み込み
    f1 = read_data(args[1])
    f2 = read_data(args[2])
    print("input data")
    print(f1)
    print(f2)

    diff_f1f2 = f1[['x', 'y', 'z']]-f2[['x', 'y', 'z']]
    # diff_f1f2 = diff_f1f2.round(2)
    print("diff")
    print(diff_f1f2)
    pow_f1f2 = diff_f1f2.pow(2)
    print("pow")
    print(pow_f1f2)
    rsum_pow_f1f2 = pow_f1f2.sum(axis=1)
    print("rsum")
    print(rsum_pow_f1f2)
    csum_rsum_pow_f1f2 = rsum_pow_f1f2.sum()
    print("csum")
    print(csum_rsum_pow_f1f2)
    div_csum_rsum_pow_f1f2 = csum_rsum_pow_f1f2/len(f1.index)
    print("div")
    print(div_csum_rsum_pow_f1f2)
    print("result")
    print(np.sqrt(div_csum_rsum_pow_f1f2))

    print("result")
    print(diff_f1f2.pow(2).sum(axis=1).sum())


