# 入力pdbファイルに対して様々な情報を返す。

import sys


def get_ligand_info():
    return 0

def center():
    return 0

def max_min():
    return 0

def max_length():
    return 0

if __name__=="__main__":
    argv = sys.argv
    argc = len(argv)

    if argv != 1:
        print('Usage: python %s [input.pdb]'.format(%argv[0]))
        quit(-1)

    with open(argv[1]) as f:
        print(type(f))
