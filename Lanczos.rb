require 'narray'
include NMath

module Lanczos

  #############
  # NArray版 虚数単位 i (長さ1の配列)
  I = NArray.complex(1).fill( Complex(0.0,1.0) )

  module_function

  # sinc function
  #
  # 入力
  #  - x (NArray)
  # 出力
  #   - sinc (NArray)
  def sinc(x)
    n = x.length
    n_2 = (n-1)/2

    sinc=NMath::sin(PI*x)/(PI*x)
    sinc[n_2]=1 if x[n_2]==0
    return sinc
  end

  # Lanczos weight function; wk
  #
  # 入力
  #   - fc (Float) : cut-off(or cut-in) frequency
  #   - n (Integer) : weight number
  # 出力
  #   - w (NArray) : weight function
  def weight_f(fc,n)
    n = n.to_i
    if n%2 == 0
      raise "weights number need to be odd number!\n"
    end
    n_2 = (n-1)/2
    k = NArray.sfloat(n).indgen!-n_2

    sigma = sinc(k/n_2)
    w = 2.0 * fc * sinc(2.0*fc*k) * sigma

    return w
  end

  # Lanczos band-pass filter's weight function; wk
  #
  # 入力
  #   - fc1 (Float) : cut-in frequency
  #   - fc2 (Float) : cut-off frequency
  #   - n (Integer) : weight number
  # 出力
  #   - w (NArray) : weight function
  def weight_f_bp(fc1,fc2,n)
    n = n.to_i
    if n%2 == 0
      raise "weights number need to be odd number!\n"
    end
    n_2 = (n-1)/2
    if n_2 < (1.3/(fc2-fc1)).to_i
      raise "weights number need to be more than 2*1.3/(fc2-fc1)+1\n"
    end

    k = NArray.sfloat(n).indgen!-n_2
    sigma = sinc(k/n_2)
    w = 2.0 * ( fc2*sinc(2.0*fc2*k) - fc1*sinc(2.0*fc1*k) ) * sigma

    return w
  end

  # Lanczos Response function; R(f)
  #
  # 入力
  #   - w (NArray) : weight function
  #   - f (NArray) : sequence of frequencies
  # 出力
  #   - r (NArray) : response function
  def res_f(w,f)
    n = w.length
    n_2 = (n-1)/2
    k = NArray.complex(1,n).indgen!-n_2 
    w = w.reshape(1,n).to_type(NArray::COMPLEX)
    r = (w*NMath::exp(I*2*PI*f*k)).sum(-1)
    #p "r"
    #p r

    return r
  end

#########

  # Lanczos Band-Pass Filter
  #
  # 入力
  #   - f (NArray) : sequence of frequencies
  #   - fc1 (Float) : cut-in frequency
  #   - fc2 (Float) : cut-off frequency
  #   - n (Integer) : weight number
  # 出力
  #   - r (NArray) : response function
  def bp_filter( f, fc1, fc2, n )
    w = Lanczos::weight_f_bp( fc1, fc2, n )
    r = Lanczos::res_f( w, f )
    return r
  end

  # Lanczos Low-Pass Filter
  #
  # 入力
  #   - f (NArray) : sequence of frequencies
  #   - fc2 (Float) : cut-off frequency
  #   - n (Integer) : weight number
  # 出力
  #   - r (NArray) : response function
  def low_filter( f, fc2, n )
    w = Lanczos::weight_f( fc2, n )
    r = Lanczos::res_f( w, f )
    return r
  end

  # Lanczos High-Pass Filter
  #
  # 入力
  #   - f (NArray) : sequence of frequencies
  #   - fc1 (Float) : cut-in frequency
  #   - n (Integer) : weight number
  # 出力
  #   - r (NArray) : response function
  def high_filter( f, fc1, n )
    w = Lanczos::weight_f( fc1, n )
    r = 1-Lanczos::res_f( w, f )
    return r
  end

#########

end


##########################################################
# メイン
if $0 == __FILE__
  require 'numru/dcl'
  include NumRu

  #< 引数解釈 >
  fc1 = ARGV[0] ? ARGV[0].to_f : 0.2
  fc2 = ARGV[1] ? ARGV[1].to_f : 0.3
  n   = ARGV[2] ? ARGV[2].to_i : 43

  #< f >
  m = 365*2
  f = NArray.sfloat(m).indgen/m.to_f
  fN = 1.0/2.0  # Nyquist frequency

  DCL.gropn 1
  DCL.grfrm

  DCL.grsvpt 0.2,0.8,0.2,0.8
  DCL.grswnd 0.0,1.0,-0.2,1.1
  DCL.grstrn 1
  DCL.grstrf

  DCL.usdaxs

  # idealized filter response
  DCL.uulinz [0.0,fc1],[0.0,0.0],1,23
  DCL.uulinz [fc1,fc2],[1.0,1.0],1,23
  DCL.uulinz [fc2,fN],[0.0,0.0],1,23
  DCL.uulinz [fc1,fc1],[0.0,1.0],3,21
  DCL.uulinz [fc2,fc2],[0.0,1.0],3,21

  r = Lanczos::bp_filter( f, fc1, fc2, n )
  r_low = Lanczos::low_filter( f, fc2, n )
  r_high = Lanczos::high_filter( f, fc1, n )

  # Lanczos filter
  DCL.uulinz f,r,1,3

  DCL.uxsttl 't',"n=#{n}",-1
#}

  DCL.grcls
  
end
