#!/bin/sh
#SBATCH -J 1s63-ZN-resp-docking
#SBATCH -p undead16
#SBATCH -o .out%j
#SBATCH -e .err%j

source /usr/share/Modules/init/sh

module purge
module load autodock-4.2.6

## autogrid4 -p grid.gpf -l sample.glg
DPF_FILE="ligand_resp_protein_tz"
autodock4 -p $DPF_FILE.dpf -l $DPF_FILE.dlg
