# Irt_Web

## IRT 分析サイト： 動作の流れ

1 リモート側から csv 形式のデータファイルを受け取る。  
  - ファイルはサーバー側にアップロードされ、サーバー内にファイルとして格納  
  [HTML form, mod_wsgi]
  
2 受け取った csvデータファイルを IRT (ltm) パッケージを用いて、
２パラメータモデルにて分析し、パラメータ (Dffclt, Dscrmn) を求める。  
  - csv データの IRT 分析を全系列からだけでなく、データ系列を選択可能とする。
    + 元データファイルから分析用データファイルは
別プログラムとして作ることができそうなので、今回は作らない。  
    + 元ファイルのデータから分析用データファイル作成  
    + form を用いて、表として表示したチェックボックスつきデータから分析用データを作成  
[pypeR, pandas?]

3 IRT パッケージで求めたパラメータの数値を用いて ICC（項目特性曲線）のグラフを描く。  
  - Javascript 系のグラフツールを活用する  
  [Highcharts の利用]  
  - Javascript のプログラム作成が仕事のメインとなる  
  [jinja2 テンプレート活用]  
    [re のパターンマッチングを用いて、R の結果から必要データを抽出]

## 部分別のサンプルプログラム（sample_* フォルダ）

### sample_form

HTML の FORMタグからの input および upload に対する処理を
python で書いた例を示す。
