#!/bin/bash

# EGM2008ジオイドデータのダウンロードと展開スクリプト

set -e  # エラーが発生したら終了

# 変数定義
DOWNLOAD_URL="https://sourceforge.net/projects/geographiclib/files/geoids-distrib/egm2008-1.zip/download"
ZIP_FILE="egm2008-1.zip"

echo "EGM2008ジオイドデータをダウンロードしています..."
echo "URL: ${DOWNLOAD_URL}"

# wgetを使用してダウンロード
wget -O "${ZIP_FILE}" "${DOWNLOAD_URL}"

echo "ダウンロード完了: ${ZIP_FILE}"

# zipファイルを展開
echo "展開しています..."
unzip -o "${ZIP_FILE}"

echo "展開完了"

# zipファイルを削除
echo "zipファイルを削除しています..."
rm "${ZIP_FILE}"
echo "zipファイルを削除しました"

echo "完了!"
