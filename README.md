# Variant Growth Rate Estimation using Bayesian Multinomial Model

SARS-CoV-2などのウイルス変異株の**相対成長率**をベイズ多項ロジスティック回帰モデル（Stan / CmdStan）で推定するGoogle Colabノートブックです。

---

## 概要

各変異株のゲノムメタデータを入力として、MCMCサンプリングにより変異株ごとの相対成長率（relative growth rate）と頻度推移（θ）を推定します。結果はPDFおよびTXTファイルとして出力されます。

---

## 必要な入力ファイル

以下のファイルはノートブック実行時に GitHub から自動ダウンロードされます。

| ファイル名 | 内容 |
|---|---|
| `input.zip` | ゲノムメタデータ（主要データ） |
| `input2.zip` | 補足メタデータ |
| `multinomial_independent.ver2.stan` | Stan モデルファイル |

メタデータファイル（`.txt`）はタブ区切りで、少なくとも以下のカラムが必要です：

- `Nextclade_pango` : Pango lineage（例：`XBB.1.5`）
- `date` : サンプリング日（例：`2024-01-15`）
- `pango_lineage` : Pango lineage（フィルタリング用）

---

## ワークフロー

```
[入力ファイル (.txt)] 
        │
        ▼
[Cell 3] パラメータ設定・ファイルダウンロード
        │
        ▼
[Cell 4] データ読み込み・Stan用データ構築
         └─ 変異株フィルタリング（最小サンプル数 > 30 のみ）
         └─ タイムビン作成・カウントマトリクス生成
        │
        ▼
[Cell 5] MCMC サンプリング（CmdStan）
         └─ iter_sampling = 1000, iter_warmup = 500
        │
        ▼
[Cell 6] 成長率・頻度推移の可視化と保存
```

---

## セルごとの説明

### Cell 1 : 環境構築

必要なRパッケージをインストールします。

```r
install.packages(c("patchwork", "posterior", "data.table"))
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
install_cmdstan(cores = 2)
```

> **注意**: CmdStan のビルドには数分かかります。

---

### Cell 2 : ライブラリの読み込み

```r
library(dplyr); library(tidyverse); library(data.table)
library(ggplot2); library(cmdstanr); library(patchwork)
library(RColorBrewer); library(posterior); library(httr)
```

---

### Cell 3 : 設定・入力ファイル定義

ここを編集することで解析対象を変更できます。

```r
# 解析対象メタデータファイル（期間に合わせて変更）
metadata.name.usa <- "/content/2023-10-01_to_2024-03-31.txt"

# 解析対象地域
region.interest <- "USA"

# 分析パラメータ
limit.count.analyzed <- 30   # 最小サンプル数（これ以下の変異株を除外）
bin.size             <- 1    # タイムビン幅（日数）
generation_time      <- 2.1  # 世代時間（日）
```

---

### Cell 4 : データ読み込み・Stan用データ構築

- メタデータをフィルタリングし、サンプル数が十分な変異株のみを抽出
- 時系列をビン化し、変異株 × タイムビンのカウントマトリクス（`Y`）を作成
- Stanモデルをコンパイル

---

### Cell 5 : MCMCサンプリング

```r
fit.stan <- multi_nomial_model$sample(
  data            = data.stan,
  iter_sampling   = 1000,
  iter_warmup     = 500,
  seed            = 1234,
  parallel_chains = 2,
  chains          = 2
)
```

> Colab 無料枠のCPUコア数に合わせ `parallel_chains = 2` に設定しています。

---

### Cell 6 : 可視化と出力

**出力1 : 成長率バーチャート**（上位10変異株）  
基準変異株に対する相対成長率（平均 ± 95% CI）を水平バーで表示。統計的に有意に高い変異株はオレンジで強調されます。

**出力2 : 頻度推移プロット**（上位5変異株）  
各変異株の推定頻度（θ）の時系列推移を 95% 信頼帯付きで可視化。実測頻度（点）と比較できます。

**保存されるファイル：**

| ファイル | 内容 |
|---|---|
| `*.method1.growth_rate.pdf` | 成長率バーチャート |
| `*.method1.growth_rate.txt` | 成長率の統計サマリー（TSV） |
| `*.method1.theta.pdf` | 頻度推移プロット |

---

## 実行方法

1. [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/) ノートブックをGoogle Colabで開く
2. **Cell 3** の `metadata.name.usa` を解析したいファイル名に変更する
3. 上から順にすべてのセルを実行する（`ランタイム` → `すべてのセルを実行`）
4. `/content/output/` フォルダに結果が保存される

---

## 依存関係

| ツール / パッケージ | バージョン |
|---|---|
| R | ≥ 4.1 |
| cmdstanr | 最新版 |
| CmdStan | 最新版 |
| tidyverse | ≥ 1.3 |
| data.table | ≥ 1.14 |
| posterior | ≥ 1.0 |
| patchwork | ≥ 1.1 |
| ggplot2 | ≥ 3.4 |
| httr | ≥ 1.4 |

---

## ライセンス

このリポジトリのライセンスについては [LICENSE](LICENSE) を参照してください。
