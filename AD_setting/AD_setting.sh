#!/bin/sh
# AutoDock(Zn)の入力ファイルを自動で生成するためのシェルスクリプト
# 制作日: 2018.11.3

# 概要
# タンパク質とリガンドの入力から、AutoDockに必要なもファイルの作成などを諸々してくれるツール

CMDNAME="AD_setting.sh"

# デフォルト値。何度も同じリガンド・タンパク質に対してい計算を行う際にはこの方がいいかも。
NPTS=65
GC_X=17.6
GC_Y=28.7
GC_Z=-4.6

# オプションの解析
FLG_ZINC="FALSE"
H_OPT=""
while getopts ius:x:y:z: OPT
do
  case $OPT in
    "i" ) FLG_ZINC="TRUE" ;;
    "u" ) H_OPT=" -U /''" ;;
    "s" ) NPTS=$OPTARG ;;
    "x" ) GC_X=$OPTARG ;;
    "y" ) GC_Y=$OPTARG ;;
    "z" ) GC_Z=$OPTARG ;;
    * ) echo "Usage: $0 [-i] [-u] [-s] [-x] [-y] [-z] [ProteinName(*.pdb)] [LigandFile(*.pdb, *.mol2)]"
      echo "-i=<Use Zn force Field>"
      echo "-u=Ligand Hydrogen Option.<Use all H> (when don't use -u, use only pola H)"
      echo "-s=<Size of grid Box>"
      echo "-x=<Grid center X>"
      echo "-y=<Grid center Y>"
      echo "-z=<Grid center Z>"
      1>&2
      exit 1 ;;
  esac
done

# オプション部分を切り捨てる。
shift `expr $OPTIND - 1`
echo $#
if [ $# -ne 2 ]; then
  echo "Usage: $0 [-i] [-u] [-s] [-x] [-y] [-z] [ProteinName(*.pdb)] [LigandFile(*.pdb, *.mol2)]"
  echo "-i=<Use Zn force Field>"
  echo "-u=Ligand Hydrogen Option.<Use all H> (when don't use -u, use only pola H)"
  echo "-s=<Size of grid Box>"
  echo "-x=<Grid center X>"
  echo "-y=<Grid center Y>"
  echo "-z=<Grid center Z>"
  exit -1
fi

# boxサイズ。できれば自動で生成したい
NPTS_X=$NPTS
NPTS_Y=$NPTS
NPTS_Z=$NPTS
echo "Boxサイズ"
echo "$NPTS_X x $NPTS_Y x $NPTS_Z"

# box center。引数もしくは自動で設定したい。
echo "x:$GC_X, y:$GC_Y, z:$GC_Z"



INPUT_PROTEIN=$1
INPUT_LIGAND=$2

PROTEIN=${INPUT_PROTEIN%.*}
LIGAND=${INPUT_LIGAND%.*}

# 入力タンパク質のチェック
echo "タンパク質 : ${INPUT_PROTEIN}"
if [ ${INPUT_PROTEIN##*.} != "pdb" ]; then
  echo "タンパク質のファイルは.pdbである必要があります。"
  exit -1
fi

# リガンドのファイルチェック
echo "リガンド : ${INPUT_LIGAND}"
if [ ${INPUT_LIGAND##*.} != "pdb" ] && [ ${INPUT_LIGAND##*.} != "mol2" ]; then
  echo "リガンドのファイルは.mol2か.pdbである必要があります。"
  exit -1
fi

# タンパク質.pdbqtの作成
echo "$MGLROOT/bin/pythonsh $ADTOOLS/prepare_receptor4.py -r ${INPUT_PROTEIN} -o ${PROTEIN}.pdbqt"
$MGLROOT/bin/pythonsh $ADTOOLS/prepare_receptor4.py -r ${INPUT_PROTEIN} -o ${PROTEIN}.pdbqt

# リガンドが.mol2の場合には、.mol2ファイルにかかれている電荷を使う
if [ ${INPUT_LIGAND##*.} = "mol2" ]; then
  echo "${INPUT_LIGAND}に記述された電荷を使用します"
  echo "$MGLROOT/bin/pythonsh $ADTOOLS/prepare_ligand4.py -l ${INPUT_LIGAND} -o ${LIGAND}.pdbqt -C$H_OPT"
  $MGLROOT/bin/pythonsh $ADTOOLS/prepare_ligand4.py -l ${INPUT_LIGAND} -o ${LIGAND}.pdbqt -C$H_OPT
else
  echo "Gasteiger charge(AutoDockデフォルト)の電荷を使用します"
  echo "$MGLROOT/bin/pythonsh $ADTOOLS/prepare_ligand4.py -l ${INPUT_LIGAND} -o ligand.pdbqt$H_OPT"
  $MGLROOT/bin/pythonsh $ADTOOLS/prepare_ligand4.py -l ${INPUT_LIGAND} -o ${LIGAND}.pdbqt$H_OPT
fi

if [ $FLG_ZINC = "TRUE" ]; then
  echo "AutoDockZN 力場を利用します。"
  echo "$MGLROOT/bin/pythonsh $ADZNTOOLS/zinc_pseudo.py -r ${PROTEIN}.pdbqt -o ${PROTEIN}_tz.pdbqt"
  $MGLROOT/bin/pythonsh $ADZNTOOLS/zinc_pseudo.py -r ${PROTEIN}.pdbqt -o ${PROTEIN}_tz.pdbqt
else
  echo "通常の力場を使用します。"
fi

# できればnptsとgridcenterも自動でやりたいなー
if [ $FLG_ZINC = "TRUE" ]; then
  echo "$MGLROOT/bin/pythonsh $ADZNTOOLS/prepare_gpf4zn.py -l ${LIGAND}.pdbqt -r ${PROTEIN}_tz.pdbqt -o ${PROTEIN}_tz.gpf -p npts=$NPTS_X,$NPTS_Y,$NPTS_Z -p gridcenter=$GC_X,$GC_Y,$GC_Z -p parameter_file=AD4Zn.dat"
  $MGLROOT/bin/pythonsh $ADZNTOOLS/prepare_gpf4zn.py -l ${LIGAND}.pdbqt -r ${PROTEIN}_tz.pdbqt -o ${PROTEIN}_tz.gpf -p npts=$NPTS_X,$NPTS_Y,$NPTS_Z -p gridcenter=$GC_X,$GC_Y,$GC_Z -p parameter_file=AD4Zn.dat
  echo "autogrid4 -p ${PROTEIN}_tz.gpf -l ${PROTEIN}_tz.glg"
  autogrid4 -p ${PROTEIN}_tz.gpf -l ${PROTEIN}_tz.glg
  echo "$MGLROOT/bin/pythonsh $ADTOOLS/prepare_dpf42.py -l ${LIGAND}.pdbqt -r ${PROTEIN}_tz.pdbqt -o ${LIGAND}_${PROTEIN}_tz.dpf -p ga_run=256"
  $MGLROOT/bin/pythonsh $ADTOOLS/prepare_dpf42.py -l ${LIGAND}.pdbqt -r ${PROTEIN}_tz.pdbqt -o ${LIGAND}_${PROTEIN}_tz.dpf -p ga_run=256
    read -p "タンパク質にZNやCAなどの金属イオンが含まれる場合にはチャージを2に手動で変更してください。理解したらEnterを押してください。"
else
  echo "$MGLROOT/bin/pythonsh $ADTOOLS/prepare_gpf4.py -l ${LIGAND}.pdbqt -r ${PROTEIN}.pdbqt -o ${PROTEIN}.gpf -p npts=$NPTS_X,$NPTS_Y,$NPTS_Z -p gridcenter=$GC_X,$GC_Y,$GC_Z"
  $MGLROOT/bin/pythonsh $ADTOOLS/prepare_gpf4.py -l ${LIGAND}.pdbqt -r ${PROTEIN}.pdbqt -o ${PROTEIN}.gpf -p npts=$NPTS_X,$NPTS_Y,$NPTS_Z -p gridcenter=$GC_X,$GC_Y,$GC_Z
  echo "autogrid4 -p ${PROTEIN}.gpf -l ${PROTEIN}.glg"
  autogrid4 -p ${PROTEIN}.gpf -l ${PROTEIN}.glg
  echo "$MGLROOT/bin/pythonsh $ADTOOLS/prepare_dpf42.py -l ${LIGAND}.pdbqt -r ${PROTEIN}.pdbqt -o ${LIGAND}_${PROTEIN}.dpf -p ga_run=256"
  $MGLROOT/bin/pythonsh $ADTOOLS/prepare_dpf42.py -l ${LIGAND}.pdbqt -r ${PROTEIN}.pdbqt -o ${LIGAND}_${PROTEIN}.dpf -p ga_run=256
    read -p "タンパク質にCAなどの金属イオンが含まれる場合にはチャージを2に手動で変更してください。(Znは0AutoDockZnの際には0のまま)理解したらEnterを押してください。"
fi


# 最後の実行は自分でやらせる。
echo "作成されたファイル類がただしいか確認して、良さそうであれば以下のコマンドを手動で実行して、AutoDockを実行してください"
if [ $FLG_ZINC = "TRUE" ]; then
  echo ""
  echo "autodock4 -p ${LIGAND}_${PROTEIN}_tz.dpf -l ${LIGAND}_${PROTEIN}_tz.dlg"
  echo ""
else
  echo ""
  echo "autodock4 -p ${LIGAND}_${PROTEIN}.dpf -l ${LIGAND}_${PROTEIN}.dlg"
  echo ""
fi

exit 0
