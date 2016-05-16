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

### sample_jinja2

jinja2 を用いたテンプレート操作のサンプルプログラム

  * sample1.py : テンプレート template.txt, データ data.csv の2つのファイルを用いて、
テンプレート部分にデータの内容を流し込んで、その結果を出力するプログラム  
  * sample2.py : テンプレート template.html の中に生成したデータを流し込むプログラムで、
mod_wsgi を利用する Webプログラムとなっている。
ブラウザでアクセスすると、Highcharts を利用した Javascriptによるグラフ表示が行われる。

### sample_irtR

pypeR を用いて IRT 分析を python から実行するプログラム

分析対象のデータファイルとして、プログラムと同じフォルダに irt_sample.csv をおいて実行すると、
IRT- 2パラメータロジスティックモデルによる分析結果としての2つのパラメータをデータ系列ごとに
列挙表示する。

IRTの分析は、R の ltm モジュールを用いる。
R は python プログラムから pypeR を用いて駆動し、分析結果として R が出力したテキストを 
re(正規表現)モジュールを用いたパターンマッチングによって 2つのパラメータ (Dffclt, Dscrmn) を 
抜き出して表示する内容である。

なお、事前に R コンソールにて、 install.packages("ltm") を実行し、パッケージをダウンロード
しておく必要がある。

R 単独のテストとして、下記を R コンソールにて試して確認できれば、
後の異常動作は python 側と考えられる。

    data <- read.table("cripboard", header=T)
        or
    data <- read.csv('irt_sample.csv', header=T)

    descript(data)

    model2 <- ltm(data~z1)

    plot(model2)

    model2

    


