#!/usr/bin/env bash

echo "Loading Config"
. ./cmd.sh
. ./path.sh
. ./conf/common_vars.sh || exit 1;
. ./conf/lang.conf || exit 1;
echo "Finish Loading Config"


in_dir=`utils/make_absolute.sh $1`
ou_dir=`utils/make_absolute.sh $2`
lang=`utils/make_absolute.sh $3`
kw_dir=$in_dir/kws_data

mkdir -p $kw_dir
mkdir -p $ou_dir

# Create the ECF file
if [ ! -f $kw_dir/.ecf.done ]; then
    ./local/create_ecf_file.sh $in_dir/wav.scp $kw_dir/ecf.xml
    touch $kw_dir/.ecf.done
else
    echo "ECF.XML has been created, won't do it again"
fi

# Create the kwlist
if [ ! -f $kw_dir/keyword.txt ]; then
    echo "You can provide your own keywords in keyword.txt in the following format"
    echo "<word1>"
    echo "<word2>"
    echo "<word3>"
    echo "Now we use the template keyword for a quick start"
    cp ./conf/keyword.txt $kw_dir/keyword.txt
fi

if [ ! -f $kw_dir/.kwlist.done ]; then
    ./local/prepare_kwlist.sh $kw_dir
    touch $kw_dir/.kwlist.done
fi

# Create RTTM file
if [ ! -f $kw_dir/.rttm.done ]; then
    ./local/ali_to_rttm.sh $in_dir $lang $ou_dir
    cp $out_dir/rttm $kw_dir/rttm
    touch $kw_dir/.rttm.done
fi

exit 0

# Setup KWS
if [ ! -f $kw_dir/.setup.done ]; then
    kws_data_prep.sh $lang $in_dir $kw_dir

    local/kws_setup.sh \
    --case_insensitive $case_insensitive \
    --rttm-file $ou_dir/rttm \
    $in_dir/ecf.xml $in_dir/keyword.txt $lang $in_dir
    touch $kw_dir/.setup.done
fi