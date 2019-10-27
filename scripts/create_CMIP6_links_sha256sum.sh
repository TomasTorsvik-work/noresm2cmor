#!/bin/bash
#set -e
pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

# set data version
#VER=v20190815
#VER=v20190909
#VER=v20190917
VER=v20190920
#VER=v20190920b
#VER=v20191009
#VER=v20191018
#VER=v20191022

# set paths of cmorized data
#folders+=(.cmorout/NorESM2-LM/1pctCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/abrupt-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-GHG/${VER})
#folders+=(.cmorout/NorESM2-LM/historical/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piNTCF/${VER})
#folders+=(.cmorout/NorESM2-LM/piControl/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-spAer-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/esm-hist/${VER})
##folders+=(.cmorout/NorESM2-LM/omip1/${VER})
#folders+=(.cmorout/NorESM2-LM/omip2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-spAer-anthro/${VER})

#folders+=(.cmorout/NorESM2-LM/1pctCO2-cdr/${VER})

#folders+=(.cmorout/NorESM2-LM/pdSST-pdSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-futArcSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-piAntSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-futAntSIC/${VER})

#folders+=(.cmorout/NorESM2-LM/histSST/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST-piNTCF/${VER})

#folders+=(.cmorout/NorESM2-LM/piClim-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-BC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-control/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-ghg/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-lu/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-OC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-SO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-anthro/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xss/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xdust/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xDMS/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xVOC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-CH4/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-N2O/${VER})

#RFMIP
#folders+=(.cmorout/NorESM2-LM/piClim-histall/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-histaer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-histghg/${VER})
folders+=(.cmorout/NorESM2-LM/piClim-histnat/${VER})

echo "----------------"
echo "LINKING FILES..."
echo "----------------"

insitute=NCC
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    echo "$folder"

    find $folder -name *.nc -print 1>/tmp/flist.txt.$pid
    sort --version-sort /tmp/flist.txt.$pid -o /tmp/flist.txt.$pid

    # if no files found
    if [ $? -ne 0 ]
    then
        continue
    fi
    nf=$(cat /tmp/flist.txt.$pid |wc -l)
    fname1=$(head -1 /tmp/flist.txt.$pid) 
    version=$(echo $folder | awk -F/ '{print $(NF) }')
    version=${version:0:9}
    activity=$(cdo -s showattribute,activity_id $fname1 |grep 'activity_id' |cut -d'"' -f2)
    if [ "$activity" == "RFMIP AerChemMIP" ]
    then
        activity="RFMIP"
    fi
    k=1

    fname=$(head -1 /tmp/flist.txt.$pid)
    bname=$(basename $fname .nc)
    fstr=($(echo $bname |tr "_" " "))
    model=${fstr[2]}
    expid=${fstr[3]}
    echo $activity/$insitute/$model/$expid  > "${folder}.links"

    while read -r fname
    do
        bname=$(basename $fname .nc)
        fstr=($(echo $bname |tr "_" " "))
        #echo $bname

        var=${fstr[0]}
        table=${fstr[1]}
        model=${fstr[2]}
        expid=${fstr[3]}
        real=${fstr[4]}
        grid=${fstr[5]}

        subfolder=$activity/$insitute/$model/$expid/$real/$table/$var/$grid/$version
        latest=$activity/$insitute/$model/$expid/$real/$table/$var/$grid/latest
        if [ ! -d "$subfolder" ]
        then
            mkdir -p "$subfolder"
        fi
        ln -sf ../../../../../../../../../$fname "$subfolder/${bname}.nc"
        ln -sfT "$version"  "$latest"
        echo "$real/$table/$var/$grid/$version/${bname}.nc" >> ${folder}.links
        echo -ne "Linking $k/$nf files\r"
        let k+=1
    done </tmp/flist.txt.$pid

done
echo "---------------------"
echo "UPDATING SHA256SUM..."
echo "---------------------"

cd $activity/$insitute/$model/$expid

reals=($(tail -n +2 ${ROOT}/${folder}.links |cut -d"/" -f1 |sort -u --version-sort))
for (( j = 0; j < ${#reals[*]}; j++ )); do
    real=${reals[j]}
    rm -f .${real}.sha256sum_${VER}
done

k=1
nf=$(tail -n +2 ${ROOT}/${folder}.links |wc -l)
for fname in $(tail -n +2 ${ROOT}/${folder}.links)
    do
        real=$(echo $fname |cut -d"/" -f1)
        sha256sum $fname >>.${real}.sha256sum_${VER} &
        if [ $(($k%15)) -eq 0 ]; then
            echo -ne "sha256sum: $k/$nf files\r"
            wait
        fi
        let k+=1
done

echo "---------------------"
echo "      ALL DONE       "
echo "---------------------"