file=/imagedata/imagedata/imagesWechat

if [ `df -h | grep imagedata | awk '{print $5}' | awk -F '%' '{print $1}'` -ge 90 ] 
then 
	img_files=`ls -lrt $file | head -n 3 | tail -n 2 | awk '{print $9}'`
	for i in ${img_files[*]}
	do
		rm -rf $file/$i
	done
fi
