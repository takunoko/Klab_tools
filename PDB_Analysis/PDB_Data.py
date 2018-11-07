# PDBの構造を扱うためのクラス。
# PDB.pyにしようとしたが、有名?なデバッガと名前が被るのでやめておいた。

from Atom_Data import Atom

class PDB_Data:
    Atoms = []
    def __init__(self, filename="None"):
        if filename != "None":
            with open(filename) as f:
                self.read_atoms(f)

    def __str__(self):
        return 'Number of Atoms {0}'.format(len(self.Atoms))

    # 原子データをフィアルから取得する。
    def read_atoms(self, f):
        line = f.readline()

        while line:
            line_data = line.split(' ')
            if line_data[0] == "ATOM" or line_data[0] == "HETATM":
                self.Atoms.append(Atom(line_data[5], line_data[6], line_data[7]))
            line = f.readline()

        return len(self.Atoms)

if __name__ == "__main__":
    ligand_pdb = PDB_Data('./sample_data/ligand.pdb')
    print(ligand_pdb)
