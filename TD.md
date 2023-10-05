## 2.1

$\text{A et B au format (1;l;n)}$


$S_1 = A + B \\$
$=A_r+iA_i + B_r + iB_i \\$
$=A_r + B_r + i(A_i + B_i)\\$

$S_{1r} = A_r + B_r\\$
$S_{1i} = A_i + B_i\\$

\
$S_2=w(A-B)\\$
$= ...\\$
$S_{2r} = w_rA_r-w_rB_r-w_iA_i+w_iB_i\\$
$S_{2i} = w_rA_i-w_rB_i-w_iA_r+w_iB_r$

## 2.1.2
### 2.1.2.1
$w_N^k=e^{-2i\frac{\pi k}{N}}\\$
$w_r \in \left[-1;1\right]\\$
$w_i \in \left[-1;1\right]$

### 2.1.2.2
$10_b = -2\\$
$01_b = 1\\$
$\Rightarrow \text{2 bits}$

### 2.1.2.3
$w_8^1=e^{\frac{-2i\pi}{8}}=e^{\frac{-i\pi}{4}} \hspace{2cm} Re(w_8^1)=\frac{\sqrt{2}}{2}\\$
$w_{th}=\sum^1_{i=-\infty}w_i2^i \hspace{2cm} w=\sum^1_{i=-m}w_i2^i\\$
$\text{valeur calculée}=w\times(A-B)\\$
$\text{valeur théorique}=w_th\times(A-B)\\$
$\text{On cherche m el que |Erreur|} \le 2^{-m}\\$
$|Erreur|=|w\times(A-B)-w_th\times(A-B)|=|w-w_th|\times|A-B|\\$

$\text{A et B : (1;l;n)}\hspace{2cm}\text{A-B}:(1;l+1;n)\\$
$|A-B|\le2^{l-n}\\$
$|w-w_th|=|\sum^1_{i=-m}w_i2^i-\sum^1_{i=-\infty}w_i2^i|\\$
$|w-w_th|=|\sum^{-m-1}_{i=-\infty}w_i2^i|\\$
$|w-w_th|\le|\sum^{-m-1}_{i=-\infty}2i| \hspace{2cm} \text{car } w_i=0 \text{ ou } 1\\$
$...\\$
$|Erreur|\le2^{-n}\\$
$\Leftrightarrow2^{l-n-m}\le 2^{-n}\\$
$\Leftrightarrow2^{l-m}\le 1\\$
$\Leftrightarrow2^{l}\le 2^m\\$

### 2.1.2.4
$\text{A et B }(1;l;m)\\$
$w_r \text{ et } w_i \text{ 2 bits partie entière et l bits partie après la virgule}\\$
$w_r \text{ et } w_i \text{ } (1;l+2;l)\\$

### 2.1.2.5
$S_1 = A+B \Rightarrow (1;l+1;n)\\$
$S_2 = w(A-B) \Rightarrow (1;l+1;n) \hspace{2cm} w\in \left]-1;1\right]\\$

### 2.1.2.6
$\text{On augmente de 1 bits à chaque étage} \Rightarrow (1;l+3;n)$
