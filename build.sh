#!/bin/sh

NUSPACKER="../nuspacker/NUSPacker.jar" # Set path to NUSPacker.jar here. will be downloaded if empty
WUHBTOOL="" # Set path to wuhbtool. Will use the one from PATH if empty
FORCE_RELEASE=0 # set to 1 to force release builds even if we'e building ALPHA/BETA

# Don't edit below this line

NUSSPLI_VERSION="$(xmllint --xpath 'app/version/text()' meta/hbl/meta.xml)"

if [ $FORCE_RELEASE -eq 1 ]; then
	NUSSPLI_BETA=1
else
	grep -q "BETA" <<< "${NUSSPLI_VERSION}" > /dev/null 2>&1
	NUSSPLI_BETA=$?
	if [ $NUSSPLI_BETA -ne 0 ]; then
		grep -q "ALPHA" <<< "${NUSSPLI_VERSION}" > /dev/null 2>&1
		NUSSPLI_BETA=$?
	fi
fi

if [ "x${NUSPACKER}" = "x" ]; then
	NUSPACKER="NUSPacker.jar"
	wget "https://github.com/ihaveamac/nuspacker/blob/master/NUSPacker.jar?raw=true" -O $NUSPACKER
	NUSPACKER_DL="true"
else
	if [ ! -e "${NUSPACKER}" ]; then
		echo "${NUSPACKER} not found!"
		exit
	fi
	NUSPACKER_DL="false"
fi

if [ "x${WUHBTOOL}" = "x" ]; then
	WUHBTOOL="wuhbtool"
else
	if [ ! -e "${WUHBTOOL}" ]; then
		test  "${NUSPACKER_DL}" = "true" && rm $NUSPACKER
		echo "${WUHBTOOL} not found!"
		exit
	fi
fi

# Cleanup
rm -f NUSspli.wuhb
rm -f NUSspli-${NUSSPLI_VERSION}-DEBUG.wuhb
rm -f NUSspli-${NUSSPLI_VERSION}-DEBUG.rpx
rm -f NUSspli-${NUSSPLI_VERSION}.wuhb
rm -f NUSspli-${NUSSPLI_VERSION}.rpx
rm -f zips/NUSspli-${NUSSPLI_VERSION}-Aroma-DEBUG.zip
rm -f zips/NUSspli-${NUSSPLI_VERSION}-HBL-DEBUG.zip
rm -f zips/NUSspli-${NUSSPLI_VERSION}-Channel-DEBUG.zip
rm -f zips/NUSspli-${NUSSPLI_VERSION}-Aroma.zip
rm -f zips/NUSspli-${NUSSPLI_VERSION}-HBL.zip
rm -f zips/NUSspli-${NUSSPLI_VERSION}-Channel.zip
rm -rf NUSspli
rm -rf NUStmp
test  "${NUSPACKER_DL}" = "true" && rm $NUSPACKER
make clean

# Build debug rpx
make -j8 debug

# Build debug Aroma wuhb
$WUHBTOOL NUSspli.rpx NUSspli.wuhb --name=NUSspli --short-name=NUSspli --author=V10lator --icon=meta/menu/iconTex.tga --tv-image=meta/menu/bootTvTex.tga --drc-image=meta/menu/bootDrcTex.tga --content=data
mkdir zips
zip -9 zips/NUSspli-${NUSSPLI_VERSION}-Aroma-DEBUG.zip NUSspli.wuhb

# Build debug channel version
mkdir NUStmp
mkdir NUStmp/code
mkdir NUStmp/meta
cp NUSspli.rpx NUStmp/code/NUSspli.rpx
cp meta/menu/app.xml NUStmp/code/app.xml
cp meta/menu/cos.xml NUStmp/code/cos.xml
cp meta/menu/iconTex.tga NUStmp/meta/iconTex.tga
cp meta/menu/bootDrcTex.tga NUStmp/meta/bootDrcTex.tga
cp meta/menu/bootTvTex.tga NUStmp/meta/bootTvTex.tga
cp meta/menu/bootLogoTex.tga NUStmp/meta/bootLogoTex.tga
cp meta/menu/bootMovie.h264 NUStmp/meta/bootMovie.h264
cp meta/menu/bootSound.btsnd NUStmp/meta/bootSound.btsnd
cp meta/menu/meta.xml NUStmp/meta/meta.xml
cp meta/menu/title.cert NUStmp/meta/title.cert
cp meta/menu/title.tik NUStmp/meta/title.tik
cp -r data NUStmp/content
java -jar "${NUSPACKER}" -in NUStmp -out NUSspli
zip -9 -r zips/NUSspli-${NUSSPLI_VERSION}-Channel-DEBUG.zip NUSspli
rm -rf NUSspli/*

if [ $NUSSPLI_BETA -ne 0 ]; then
	# Build release rpx
	make -j8 release
	
	# Build release Aroma wuhb
	$WUHBTOOL NUSspli.rpx NUSspli.wuhb --name=NUSspli --short-name=NUSspli --author=V10lator --icon=meta/menu/iconTex.tga --tv-image=meta/menu/bootTvTex.tga --drc-image=meta/menu/bootDrcTex.tga --content=data
	zip -9 zips/NUSspli-${NUSSPLI_VERSION}-Aroma.zip NUSspli.wuhb
	
	# Build release channel version
	rm NUStmp/code/NUSspli.rpx
	mv NUSspli.rpx NUStmp/code/NUSspli.rpx
	java -jar "${NUSPACKER}" -in NUStmp -out NUSspli
	zip -9 -r zips/NUSspli-${NUSSPLI_VERSION}-Channel.zip NUSspli
	rm -rf NUSspli/*
fi

# Build debug homebrew loader zip
make clean
make HBL=1 -j8 debug
mkdir NUSspli
cp NUSspli.rpx NUSspli/NUSspli.rpx
cp meta/hbl/meta.xml NUSspli/meta.xml
cp meta/hbl/icon.png NUSspli/icon.png
zip -9 -r zips/NUSspli-${NUSSPLI_VERSION}-HBL-DEBUG.zip NUSspli

if [ $NUSSPLI_BETA -ne 0 ]; then
	# Build release homebrew loader zip
	make HBL=1 -j8 release
	rm NUSspli/NUSspli.rpx
	cp NUSspli.rpx NUSspli/NUSspli.rpx
	zip -9 -r zips/NUSspli-${NUSSPLI_VERSION}-HBL.zip NUSspli
fi

rm -f NUSspli/*


# Cleanup
rm -rf NUSspli NUStmp
test  "${NUSPACKER_DL}" = "true" && rm $NUSPACKER
