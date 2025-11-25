#!/bin/bash

# EGM2008ジオイドデータをterrainRGB形式のタイルに変換するスクリプト

set -e  # エラーが発生したら終了

# 変数定義
INPUT_TIF="tif/egm2008_1m_3857.tif"
OUTPUT_TERRAINRGB="tif/egm2008_1m_3857_terrainrgb.tif"
OUTPUT_TILES_DIR="terrainrgb"
OUTPUT_MBTILES="egm2008_terrainrgb.mbtiles"
OUTPUT_PMTILES="egm2008_terrainrgb.pmtiles"

echo "terrainRGB形式のタイル変換を開始します..."

# (1) NoDataを外す
echo "ステップ1: NoDataを削除"
docker run --rm -u "$(id -u)":"$(id -g)" -v "$PWD":/work -w /work ghcr.io/osgeo/gdal:alpine-normal-latest \
  gdal_edit.py -unsetnodata "${INPUT_TIF}"

echo "完了"

# (2) terrainRGB作成
echo "ステップ2: terrainRGB形式に変換"
docker run --rm -u "$(id -u)":"$(id -g)" -ti -v $(pwd):/data helmi03/rio-rgbify -j 1 -b -10000 -i 0.1 \
    "${INPUT_TIF}" "${OUTPUT_TERRAINRGB}" \
    --co BIGTIFF=YES --co TILED=YES --co COMPRESS=DEFLATE --co PREDICTOR=2 --co ZLEVEL=5

echo "完了: ${OUTPUT_TERRAINRGB}"

# (3) ラスタータイル作成
echo "ステップ3: ラスタータイル作成"
docker run --rm -u "$(id -u)":"$(id -g)" -v "$PWD":/work -w /work ghcr.io/osgeo/gdal:alpine-normal-latest \
  gdal2tiles.py "${OUTPUT_TERRAINRGB}" "${OUTPUT_TILES_DIR}" -z0-5 --resampling=near --xyz --processes=6

echo "完了: ${OUTPUT_TILES_DIR}"

# (4) mbtiles作成
echo "ステップ4: mbtiles形式に変換"
# 既存のmbtilesファイルがあれば削除
if [ -f "${OUTPUT_MBTILES}" ]; then
    echo "既存の ${OUTPUT_MBTILES} を削除します"
    rm "${OUTPUT_MBTILES}"
fi
mb-util --image_format=png "${OUTPUT_TILES_DIR}/" "${OUTPUT_MBTILES}"

echo "完了: ${OUTPUT_MBTILES}"

# (5) pmtiles変換
echo "ステップ5: pmtiles形式に変換"
pmtiles convert "${OUTPUT_MBTILES}" "${OUTPUT_PMTILES}"

echo "完了: ${OUTPUT_PMTILES}"
echo ""
echo "変換完了!"
echo "出力ファイル:"
echo "  - ${OUTPUT_TERRAINRGB}"
echo "  - ${OUTPUT_TILES_DIR}/"
echo "  - ${OUTPUT_MBTILES}"
echo "  - ${OUTPUT_PMTILES}"
