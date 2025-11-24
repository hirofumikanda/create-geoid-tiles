#!/bin/bash

# EGM2008ジオイドタイル作成パイプライン
# download_geoid.sh → convert_geoid.sh → create_terrainrgb_tiles.sh を順次実行

set -e  # エラーが発生したら終了

echo "=================================="
echo "EGM2008ジオイドタイル作成パイプライン"
echo "=================================="
echo ""

# スクリプトの存在確認
for script in download_geoid.sh convert_geoid.sh create_terrainrgb_tiles.sh; do
    if [ ! -f "$script" ]; then
        echo "エラー: $script が見つかりません"
        exit 1
    fi
    if [ ! -x "$script" ]; then
        echo "エラー: $script に実行権限がありません"
        echo "chmod +x $script を実行してください"
        exit 1
    fi
done

# 開始時刻を記録
START_TIME=$(date +%s)

echo "パイプライン開始: $(date)"
echo ""

# ステージ1: ジオイドデータのダウンロード
echo "=========================================="
echo "ステージ1: ジオイドデータのダウンロード"
echo "=========================================="
./download_geoid.sh
echo ""

# ステージ2: GeoTIFF形式への変換
echo "=========================================="
echo "ステージ2: GeoTIFF形式への変換"
echo "=========================================="
./convert_geoid.sh
echo ""

# ステージ3: terrainRGBタイルの作成
echo "=========================================="
echo "ステージ3: terrainRGBタイルの作成"
echo "=========================================="
./create_terrainrgb_tiles.sh
echo ""

# 終了時刻を記録
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
HOURS=$((ELAPSED_TIME / 3600))
MINUTES=$(((ELAPSED_TIME % 3600) / 60))
SECONDS=$((ELAPSED_TIME % 60))

echo "=========================================="
echo "パイプライン完了"
echo "=========================================="
echo "終了時刻: $(date)"
echo "処理時間: ${HOURS}時間 ${MINUTES}分 ${SECONDS}秒"
echo ""
echo "生成されたファイル:"
echo "  - geoids/egm2008-1.pgm"
echo "  - tif/egm2008_1m.tif"
echo "  - tif/egm2008_1m_lon180.tif"
echo "  - tif/egm2008_1m_3857.tif"
echo "  - tif/egm2008_1m_3857_terrainrgb.tif"
echo "  - terrainrgb/"
echo "  - egm2008_terrainrgb.mbtiles"
echo "  - egm2008_terrainrgb.pmtiles"
