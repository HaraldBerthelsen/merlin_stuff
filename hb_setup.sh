#!/bin/bash

BuildDir=test_build_nnc_full_161020
MerlinDir=/media/bigdisk/git_repos/merlin
VOICE=nnc_test

#For demo
#Train=50
#Valid=5
#Test=5

#For full
Train=1000
Valid=66
Test=66


make_dir=0
setup=1
copy_data=0
extract_features=0
align=0
setup_for_training=1
train=1
test_synthesis=1

########

CurrDir=`pwd`
WorkDir=$CurrDir/$BuildDir/s1
DataDir=$WorkDir/database


if [ "$make_dir" == "1" ]
then

cp -r ~/git/merlin/egs/build_your_own_voice_hb ${BuildDir}
echo "make_dir done"    
fi

cd ${BuildDir}/s1


if [ "$setup" == "1" ]
then

./01_setup.sh $VOICE
sed -i s#'MerlinDir=.*'#'MerlinDir='$MerlinDir# conf/global_settings.cfg
sed -i s#'FileIDList=.*'#'FileIDList=file_id_list.scp'# conf/global_settings.cfg
sed -i s#'Train=.*'#'Train='$Train# conf/global_settings.cfg
sed -i s#'Valid=.*'#'Valid='$Valid# conf/global_settings.cfg
sed -i s#'Test=.*'#'Test='$Test# conf/global_settings.cfg

echo "setup done"

fi


if [ "$copy_data" == "1" ]
then

cp ../../slt_demo_data/txt/* database/txt/
cp ../../slt_demo_data/wav/* database/wav/
cp ../../slt_demo_data/cmuarctic.data database/

echo "copy_data done"

fi

if [ "$extract_features" == "1" ]
then

cd scripts/vocoder/world
sed -i s#'data_dir=.*'#'data_dir="'$DataDir'"'# extract_features_for_merlin.sh
./extract_features_for_merlin.sh
cd -
echo "extract_features done"

fi

if [ "$align" == "1" ]
then

cd scripts/alignment/state_align
sed -i s#'WorkDir=.*'#'WorkDir='$DataDir# config.cfg
./run_aligner.sh config.cfg
cd -

cd scripts/alignment/phone_align
sed -i s#'WorkDir=.*'#'WorkDir='$DataDir# config.cfg
#TODO it wants cmuarctic.data instead of database/txt
#Make it use database/txt, or else create cmuarctic.data from it.
./run_aligner.sh config.cfg
cd -


cp -r scripts/alignment/phone_align/full-context-labels/full database/label_phone_align

echo "align done"

fi

if [ "$setup_for_training" == "1" ]
then


mkdir -p experiments/$VOICE/duration_model/data
cp database/file_id_list.scp experiments/$VOICE/duration_model/data/file_id_list_full.scp 
mkdir -p experiments/$VOICE/acoustic_model/data
cp database/file_id_list.scp experiments/$VOICE/acoustic_model/data/file_id_list_full.scp


#Copy files for test_synthesis

mkdir -p experiments/$VOICE/test_synthesis
mkdir -p experiments/$VOICE/test_synthesis/prompt-lab
tail -${Test} database/file_id_list.scp > experiments/$VOICE/test_synthesis/test_id_list.scp
for f in `tail -${Test} database/file_id_list.scp`
do
	cp database/label_phone_align/$f.lab experiments/$VOICE/test_synthesis/prompt-lab/
done
echo "setup_for_training done"

fi

if [ "$train" == "1" ]
then
#TRAINING
./03_run_merlin.sh

echo "train done"

fi

if [ "$test_synthesis" == "1" ]
then
#TEST SYNTHESIS NEW SENTENCE
mkdir experiments/$VOICE/test_synthesis/txt
echo "This is a first test." > experiments/$VOICE/test_synthesis/txt/test_01.txt

./04_merlin_synthesis.sh
wavesurfer experiments/$VOICE/test_synthesis/wav/test_01.wav

echo "test_synthesis done"

fi
