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

## 全体の動作確認 (main_v0.py) ##

アップロードされたファイルのデータを R の ltm モジュールを使って 
IRT の2パラメータロジスティックモデルにて分析を行い、その結果サマリーを示すとともに、
2つのパラメータから描かれる項目特性曲線をグラフとして示す。

同一ディレクトリに template.html ファイルが必要である。
また、アップロードするファイルの例として irt_sample.csv を載せておく。

__call__() : ファイル最終行で application = Irt_Web() とあり、インスタンスを application に
設定して、それが関数として機能するようにするために特殊メソッドとして作る必要がある。
サイトがアクセスされると、mod_wsgi では application() 関数が呼び出される。
ファイルがアップロードされると、その内容は /tmp/tmp.txt に一旦保存される。
保存後、irt_analysis() および graphhtml() が順に呼び出され、その結果の html テキストを
発信する。  
（参考プログラム sample_form フォルダ）

irt_analysis() : pypeR を用いて R を駆動し、IRT の分析を行って、その結果サマリーおよび
2つのパラメータの値を取得する。
R で行う作業は、/tmp/tmp.txt の内容を読み込み、ltm にて分析することである。
R から返される結果文字列のうち結果サマリーはそのまま利用する。
また、分析結果としてのパラメータ値は re モジュールを使ってパターンマッチングによって
数値として、項目名は文字列として入手する。  
（参考プログラム sample_irtR フォルダ）

graphhtml() : 結果をブラウザに表示するために、 template.html をテンプレートとし 
jinja2 モジュールを使って必要なデータを流し込んで html テキストを生成する。
template.html では、表示画面構成として画面を大きく左右に2分割し、左側に R が出力する
結果サマリーをそのまま表示し、右側には R からの2パラメータの値による ICCグラフを
Javascriptグラフライブラリ Highcharts を利用して描く。
画面の分割は css で行っており、サマリーの表示は \<pre>\<code> タグを利用した。
参考： http://www.geocities.jp/eijispace/2012/0419.html  
（参考プログラム sample_jinja2 フォルダ）

## ファイルのアップロードから R での IRT 分析までの動作確認（main_A.py）

ファイルをアップロードして R で IRT 分析を行うところまでのプログラム main_A.py を、
部分別のサンプル（sample_form, sample_irtR）を組み合わせて作成し、
動作を確認した。

最初、R のライブラリ読み込みが動かなかったため、思わぬ調整が必要になった。
mod_wsgi を使い pypeR を介して R がリモートから起動される場合、
root ユーザーが R を起動することになると考えられる。
その場合、R の環境変数の設定値が一般ユーザーと異なるため、
R の library() 関数で ltm ライブラリを読み込む際に読み込めなくなった。

一般ユーザーが R を動かして install.packages() でライブラリを読み込むと、
そのユーザーのホームの R ディレクトリ下に読み込まれるし、
library() 関数を呼ぶと、第一にユーザーホームのライブラリの場所から探す仕組みとなっている。

ところが、www ディレクトリ下に置かれて起動する場合は root として R が起動され、
ライブラリの読み込み先が /usr/lib64/R/library, /usr/share/R/library の2ディレクトリだけになり、
ユーザーのところに保存されているライブラリは検索対象外となってしまう。
そこで、IRT に必要な ltm ライブラリ および 依存関係にある他のライブラリを、
ユーザーのところから /usr/share/R/library にコピーしてしのいだ。

他の方法としては、root で R を動かして必要なライブラリをインストールすることが考えられる。
root のホーム下にインストールされることになりそうであるが、一つの解決方法である。
動くかどうかは未確認である。

    
    
## 部分別のサンプルプログラム（sample_* フォルダ）

### sample_form

HTML の FORMタグからの input および upload に対する処理を
python で書いた例を示す。

  * imput.py : 文字入力のためのテキストボックスに文字が入力され送信ボタンが押された場合に、
POSTメソッドでサーバに入力データを回収する手続きを示す。  
  * upload.py : GETメソッドでアクセスされた場合にファイル名選択のためのダイアログを表示し、
ファイルが選択され送信ボタンが押されると、 POSTメソッドでサーバにファイルデータを回収し、 
ファイルの内容を入手する手続きを示す。
アップロードされたファイルのデータは、サーバ側の実ファイル /tmp/tmp.txt として
保存する。


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

    


