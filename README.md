Lanczos

2012-12-26 Eriko Nishimoto

== Summary

Ruby libraries of Lanczos filter.

Lanczosフィルターに関するライブラリです。
時空間領域に対応した重み関数、周波数空間に対応した応答関数を返します。

== Runtime Dependency

* Ruby (>=1.8)
* NArray, NMath

== How to Use

  load this file in a ruby program, then 

    require 'Lanczos'

== Tips

データに時空間フィルターをかけるには、
時空間領域でのフィルタリング と 周波数空間でのフィルタリング
の二通りがある。
詳細は、Duchon(1979)、伊藤・見延(2010)などを参照してください。

* 時空間領域でのフィルタリングの仕方

重み関数（Lanczos::weight_fなど）を計算し、時空間データに対して加重移動平均を施す。

* 周波数空間でのフィルタリングの仕方

まず、フーリエ変換などによって、時空間データを周波数領域データに変換する。次にその周波数領域データに、応答関数（Lanczos::ref_fなど）をかけてフィルターをかける。最後にフーリエ逆変換などによって、時空間データに戻す。

== Functions

主な関数は次のようになっています。

-- Lanczos::weight_f( fc , n )
    Return a weight function of a low-pass filter

    ARGUMENTS
    * fc (Float) : cutoff frequency
    * n  (Interger) : number of weights

    RETURN VALUE
    * w  (NArray) : a weight function

-- Lanczos::weight_f＿bp( fc1, fc2 , n )

    Return a weight function of a band-pass filter

    ARGUMENTS
    * fc1 (Float) : cutin frequency
    * fc2 (Float) : cutoff frequency
    * n   (Integer) : number of weights

    RETURN VALUE
    * w  (NArray) : a weight function

-- Lanczos::res_f( wgt, f )

    Return a frequency-domain response function

    ARGUMENTS
    * wgt (NArray) : a weight function
    * f   (NArray) : sequence of frequencies

    RETURN VALUE
    * r   (NArray) : a response function

-- Lanczos::bp_filter( f, fc1, fc2, n ) 

    Return a band-pass response function

    ARGUMENTS
    * f (NArray) : sequence of frequencies
    * fc1 (Float) : cut-in frequency
    * fc2 (Float) : cut-off frequency
    * n (Integer) : number of weights

    RETURN VALUE
    * r (NArray) : a band-pass response function

-- Lanczos::low_filter( f, fc2, n )

    Return a low-pass response function

    ARGUMENTS
    * f (NArray) : sequence of frequencies
    * fc2 (Float) : cut-off frequency
    * n (Integer) : number of weights

    RETURN VALUE
    * r (NArray) : a low-pass response function

-- Lanczos::high_filter( f, fc1, n )

    Return a high-pass response function

    ARGUMENTS
    * f (NArray) : sequence of frequencies
    * fc1 (Float) : cut-in frequency
    * n (Integer) : number of weights

    RETURN VALUE
    * r (NArray) : a high-pass response function

== Bibliography

* Duchon, C. E. (1979). Lanczos filtering in one and two dimensions.  Journal of Applied Meteorology, 18, 1016-1022.  
* 伊藤久徳、見延庄士郎. (2010).  気象学と海洋物理学で用いられるデータ解析法, 気象研究ノート第221号.  日本気象学会.  
