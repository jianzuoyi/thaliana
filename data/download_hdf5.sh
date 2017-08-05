#!/bin/bash

SRR_ACC_LIST=SRR_Acc_List_cross.txt
SRAPUB=http://sra-download.ncbi.nlm.nih.gov/srapub_files
OUTDIR=/its1/GB_BT2/jianzuoyi/workspace/thaliana/data/PacBio
bax2bam=/its1/GB_BT2/jianzuoyi/biosoft/smrt_bin/bax2bam
while read SRR
do
    hdf5=${SRAPUB}/${SRR}_${SRR}_hdf5.tgz
    WD=${OUTDIR}/${SRR}
    mkdir -p $WD
    SH=${WD}/down_hdf5.sh
    echo "#!/bin/bash
set -vex

if [[ -f ${SH}.done ]]; then exit 0; fi
cd $WD
wget -c -t 5 $hdf5 -P $WD
tar xvf ${WD}/${SRR}_${SRR}_hdf5.tgz || ture
$bax2bam ${WD}/*.bax.h5
rm -f ${WD}/*.bax.h5
rm -f ${WD}/*scraps*
rm -f ${WD}/*metadata.xml
rm -f ${WD}/*bas.h5
rm -f ${WD}/*.tgz
touch ${SH}.done" > $SH
done < $SRR_ACC_LIST

find $OUTDIR -type f -name 'down_hdf5.sh' | xargs -n1 -I {} echo bash {} > run_download_hdf5.sh
if [[ -n $1 && $1 == "-qsub" ]]; then
    qsub -cwd -S /bin/bash run_download_hdf5.sh
fi
