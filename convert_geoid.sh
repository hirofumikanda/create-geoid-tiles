#!/bin/bash

# EGM2008ジオイドデータをm単位にスケーリングし経緯度位置を調整するスクリプト

set -e  # エラーが発生したら終了

# 変数定義
INPUT_PGM="geoids/egm2008-1.pgm"
OUTPUT_DIR="tif"
OUTPUT_TIF="${OUTPUT_DIR}/egm2008_1m.tif"
OUTPUT_LON180="${OUTPUT_DIR}/egm2008_1m_lon180.tif"
OUTPUT_3857="${OUTPUT_DIR}/egm2008_1m_3857.tif"

# 出力ディレクトリが存在しない場合は作成
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "${OUTPUT_DIR} ディレクトリを作成しています..."
    mkdir -p "${OUTPUT_DIR}"
fi

echo "EGM2008ジオイドデータを変換しています..."

# (A) 実値[m]へスケール & 位置合わせ（0E..360E, 90N..-90S）
echo "ステップ1: 実値[m]へスケール & 位置合わせ"
docker run --rm -u "$(id -u)":"$(id -g)" -v "$PWD":/work -w /work ghcr.io/osgeo/gdal:alpine-normal-latest \
  gdal_translate -ot Float32 \
    -scale 0 65535 -108 88.605 \
    -a_srs EPSG:4326 \
    -a_ullr 0 90 360 -90 \
    "${INPUT_PGM}" "${OUTPUT_TIF}" \
    -co TILED=YES -co COMPRESS=LZW

echo "完了: ${OUTPUT_TIF}"

# (B) 経度を -180..180 に再中心化
echo "ステップ2: 経度を -180..180 に再中心化"
docker run --rm -u "$(id -u)":"$(id -g)" -v "$PWD":/work -w /work ghcr.io/osgeo/gdal:alpine-normal-latest \
  gdalwarp -overwrite -s_srs EPSG:4326 -t_srs EPSG:4326 \
    -te -180 -90 180 90 -r bilinear -dstnodata -9999 \
    -multi -wo SOURCE_EXTRA=1 \
    "${OUTPUT_TIF}" "${OUTPUT_LON180}"

echo "完了: ${OUTPUT_LON180}"

# (C) Webメルカトル投影(EPSG:3857)に変換
echo "ステップ3: Webメルカトル投影(EPSG:3857)に変換"
docker run --rm -u "$(id -u)":"$(id -g)" -v "$PWD":/work -w /work ghcr.io/osgeo/gdal:alpine-normal-latest \
  gdalwarp -overwrite "${OUTPUT_LON180}" "${OUTPUT_3857}" \
    -s_srs EPSG:4326 -t_srs EPSG:3857 \
    -te_srs EPSG:4326 -te -180 -85.051129 180 85.051129 \
    -r bilinear -multi -wo NUM_THREADS=ALL_CPUS \
    -dstnodata -9999 -ot Float32 \
    -co TILED=YES -co COMPRESS=DEFLATE -co PREDICTOR=3 -co ZLEVEL=9 -co BIGTIFF=YES

echo "完了: ${OUTPUT_3857}"
echo ""
echo "変換完了!"
echo "出力ファイル:"
echo "  - ${OUTPUT_TIF}"
echo "  - ${OUTPUT_LON180}"
echo "  - ${OUTPUT_3857}"
