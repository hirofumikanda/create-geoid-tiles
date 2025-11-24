# EGM2008ジオイドタイル作成ツール

EGM2008ジオイドデータをダウンロードし、Webメルカトル投影のterrainRGBタイルに変換するツール群です。

## 概要

このプロジェクトは、EGM2008グローバルジオイドモデルをダウンロードし、以下の形式に変換します：

- GeoTIFF形式（EPSG:4326およびEPSG:3857）
- terrainRGB形式のラスタータイル
- MBTiles形式
- PMTiles形式

## 必要な環境

- Docker
- mb-util
- pmtiles

## ディレクトリ構成

```
.
├── pipeline.sh                    # 全工程を自動実行するパイプラインスクリプト
├── download_geoid.sh              # ジオイドデータのダウンロードスクリプト
├── convert_geoid.sh               # GeoTIFF形式への変換スクリプト
├── create_terrainrgb_tiles.sh     # terrainRGBタイル作成スクリプト
├── geoids/                        # ダウンロードしたジオイドデータ
├── tif/                          # 変換後のGeoTIFFファイル
└── terrainrgb/                   # 生成されたタイル
```

## 使い方

### 簡単な方法: パイプラインスクリプトで一括実行

すべての工程を自動的に実行する場合は、パイプラインスクリプトを使用します。

```bash
chmod +x *.sh
./pipeline.sh
```

このスクリプトは以下を順次実行します：
1. ジオイドデータのダウンロード（`download_geoid.sh`）
2. GeoTIFF形式への変換（`convert_geoid.sh`）
3. terrainRGBタイルの作成（`create_terrainrgb_tiles.sh`）

処理時間や生成されたファイルの一覧も表示されます。

### 個別実行する方法

各工程を個別に実行することもできます。

### 1. ジオイドデータのダウンロード

EGM2008ジオイドデータをSourceForgeからダウンロードし、`geoids`ディレクトリに展開します。

```bash
chmod +x download_geoid.sh
./download_geoid.sh
```

**処理内容：**
- EGM2008ジオイドデータ（egm2008-1.zip）をダウンロード
- `geoids`ディレクトリに展開
- zipファイルを自動削除

### 2. GeoTIFF形式への変換

PGM形式のジオイドデータを、m単位のGeoTIFF形式に変換します。

```bash
chmod +x convert_geoid.sh
./convert_geoid.sh
```

**処理内容：**
1. 実値[m]へスケーリング & 位置合わせ（0E..360E, 90N..-90S）
   - 入力: `geoids/egm2008-1.pgm`
   - 出力: `tif/egm2008_1m.tif`
   
2. 経度を -180..180 に再中心化
   - 出力: `tif/egm2008_1m_lon180.tif`
   
3. Webメルカトル投影（EPSG:3857）に変換
   - 出力: `tif/egm2008_1m_3857.tif`

### 3. terrainRGBタイルの作成

Webメルカトル投影のGeoTIFFをterrainRGB形式のタイルに変換します。

```bash
chmod +x create_terrainrgb_tiles.sh
./create_terrainrgb_tiles.sh
```

**処理内容：**
1. NoDataを削除
2. terrainRGB形式に変換
   - 出力: `tif/egm2008_1m_3857_terrainrgb.tif`
3. ラスタータイル作成（ズームレベル0-5）
   - 出力: `terrainrgb/`
4. MBTiles形式に変換
   - 出力: `egm2008_terrainrgb.mbtiles`
5. PMTiles形式に変換
   - 出力: `egm2008_terrainrgb.pmtiles`

## データソース

- **EGM2008**: Earth Gravitational Model 2008
- **配布元**: GeographicLib
- **URL**: https://sourceforge.net/projects/geographiclib/files/geoids-distrib/

## terrainRGBについて

terrainRGB形式は、標高データをRGBカラー値として符号化する形式です。このプロジェクトでは以下のパラメータを使用しています：

- ベース値: -10000m
- 間隔: 0.1m

## ライセンス

このツールはMITライセンスです。EGM2008データのライセンスについては、GeographicLibのドキュメントを参照してください。
