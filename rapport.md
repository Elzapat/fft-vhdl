---
title: Implémentations de l'algorithme FFT sur FPGA
subtitle: Rapport de projet
author:
	- Arthur Gaudard
	- Morgan Van Amerongen
date: Vendredi 17 novembre 2023
lang: fr
documentclass: article
numbersections: true
geometry:
	- margin=1in
toc: true
toc-depth: 3
block-headings: true
indent: true
header-includes:
	- \usepackage{circuitikz}
    - \newcommand{\hideFromPandoc}[1]{#1}
    - \hideFromPandoc{
        \let\Begin\begin
        \let\End\end
      }
...

# Presentation

L'objectif de ce projet est d'explorer les différentes implémentations possibles de l'algorithme Fast Fourier Transform (FFT) sur FPGA, afin de comparer leurs performances au niveau temporel (débit et latence) et au niveau matériel (ressources mémoire et calculatoires). La programmation sera faite en VHDL et simulée en utilisant le logiciel ModelSim.

Les implémentations présentées ici prennent en entrée $n = 8$ échantillons codés sur 12 bits en virgule fixe signée avec 3 bits après la virgule.

\break

# Opérateur papillon

## Théorie

Le calcul du spectre est basé sur un opérateur complexe appelé "papillon". Cet opérateur prend en entrée deux nombres complexes $A$ et $B$ ainsi qu'un coefficient unitaire $w^k_n$, et possède deux sorties complexes $S_1 = A+B$ et $S_2 = w^k_n(A-B)$ (voir fig. \ref{fig:butterfly}).

\begin{figure}[h]
\centering
\begin{circuitikz}
\draw
(0,0) node[coupler, scale=2](butt){}
(butt.n) node[above]{Papillon}
(butt.left up) to[short, -o] ++(-1,0) node[left, font=\huge]{$\hspace{4em}A$}
(butt.left down) to[short, -o] ++(-1,0) node[left, font=\huge]{$B$}
(butt.right up) to[short, -o] ++(1,0) node[right, font=\huge]{$A+B$}
(butt.right down) to[short, -o] ++(1,0) node[right, font=\huge]{$w^k_n(A-B)$}
(butt.s) to[short, -o] ++(0,-1) node[below, font=\huge]{$w^k_n$};
\end{circuitikz}
\caption{L'opérateur papillon}
\label{fig:butterfly}
\end{figure}

On a :

$$\begin{aligned}
S_1 &= A+B\\
&= A_r + iA_i + B_r + iB_i\\
&= A_r + B_r + i(A_i + B_i)\\
\end{aligned}$$

$$\begin{aligned}
S_2 &= w^k_n(A-B)\\
&= (w^k_{nr} + iw^k_{ni})(A_r+iA_i-B_r-iB_i)\\
&= w^k_{nr}A_r + iw^k_{ni}A_r + iw^k_{nr}A_i - w^k_{ni}A_i - w^k_{nr}B_r - iw^k_{ni}B_r - iw^k_{nr}B_i + w^k_{ni}B_i\\
&= w^k_{nr}A_r - w^k_{ni}A_i - w^k_{nr}B_r + w^k_{ni}B_i + i(w^k_{ni}A_r + w^k_{nr}A_i - w^k_{ni}B_r - w^k_{nr}B_i)\\
&= w^k_{nr}(A_r-B_r) + w^k_{ni}(B_i-A_i) + i(w^k_{nr}(A_i-B_i) + w^k_{ni}(A_r-B_r))\\
\end{aligned}$$

D'où :

$$\boxed{\begin{cases}
S_{1r} = A_r+B_r\\
S_{1i} = A_i+B_i\\
S_{2r} = w^k_{nr}(A_r-B_r) + w^k_{ni}(B_i-A_i)\\
S_{2i} = w^k_{nr}(A_i-B_i) + w^k_{ni}(A_r-B_r)\\
\end{cases}}$$

Les coefficients du papillon sont donnés par $w^k_n=e^{-2i\frac{\pi k}{n}}$, d'où $(w^k_{nr},w^k_{ni}) \in [-1;1[^2$.

## Implémentation

On suppose que $A_r$, $A_i$, $B_r$ et $B_i$ sont codés comme des nombres à virgule fixe au format $(1;l;n)$. On en déduit que $S_{1r}$, $S_{1i}$, $S_{2r}$ et $S_{2i}$ sont au format $(1;l+1;n)$ car la somme de deux nombres dans l'intervalle $[-2^{l-1};2^{l-1}-1]$ (codable sur $l$ bits) appartient à $[-2^l;2^l-2]$ (codable sur $l+1$ bits). Sachant cela, le format de $w^k_n$ doit être $(1,l+2,l+1)$ afin d'autoriser la multiplication avec $A$ et $B$.

Il s'agit d'un composant purement combinatoire, ce qui élimine le besoin d'un signal d'horloge ou de reset à cette étape.

# Architecture pipeline

L'idée de l'architecture pipeline est de maximiser les calculs en parallèles afin de réduire la latence et le débit au maximum. Ce résultat s'obtient cependant au prix d'une utilisation plus importante des ressources matérielles.

## Implémentation

### Architecture générale

L'algorithme FFT pour $n = 8$ échantillons nécessite d'utiliser 12 fois l'opérateur papillon (voir sec. 2), séparés en 3 étages successifs de 4 calculs simultanés (voir fig. \ref{fig:fft-butterflies}).

![Organisation des papillons pour la FFT\label{fig:fft-butterflies}](butterflies_pipeline.png){width=70%}

Ces étages sont séparés par des registres dont l'activation est contrôlée par une machine à états finis décrite dans la partie suivante.

### Machine à états finis

![Graphe de la machine à états finis de Mealy pour l'architecture *Full Pipeline*\label{fig:pipeline_sm_graph}](mealy_pipeline.png){width=80%}

\Begin{figure}

+--------------+--------------+--------------+--------------+--------------+--------------+
| État présent | `in_ready`   | `out_valid`  | `en1`        | `en2`        | `en3`        |
+:============:+:============:+:============:+:============:+:============:+:============:+
| E000         | 1            | 0            | 1            | 1            | 1            |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E001         | 1            | 1            | 1            | 1            | `out_ready`  |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E010         | 1            | 0            | 1            | 1            | 1            |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E011         | 1            | 1            | 1            | `out_ready`  | `out_ready`  |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E100         | 1            | 0            | 1            | 1            | 1            |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E101         | 1            | 1            | 1            | 1            | `out_ready`  |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E110         | 1            | 0            | 1            | 1            | 1            |
+--------------+--------------+--------------+--------------+--------------+--------------+
| E111         | `out_ready`  | 1            | `out_ready`  | `out_ready`  | `out_ready`  |
+--------------+--------------+--------------+--------------+--------------+--------------+

\caption{Table des sorties de la machine à états finis pour l'architecture \textit{Full Pipeline}}
\label{fig:pipeline_sm_table}
\End{figure}

## Performances

Comme les données passent d'un étage au suivant en une période d'horloge, la latence est égale au temps nécessaire à une donnée pour traverser les trois étages. Elle est donc de l'ordre de $L = 3T_{CK} = \frac{3}{f_{CK}}$ s.
Pour ce qui est du débit, le système est prêt à recevoir des données dès qu'elles sont passées à l'étage suivant, ce qui permet de traiter $D = 8\times 12 \times f_{CK}$ bits/s.
Cette architecture utilise cependant beaucoup de ressources matérielles, car les 12 papillons doivent être implémentés en même temps. Ce n'est pas très important pour $n = 8$, mais on voit que la complexité matérielle est en $O(n\log_2(n))$.

# Architecture itérative

## Préparation

### Machine d'état

Pour l'architecture itérative, nous allons faire une nouvelle machine à états finis de Mealy. Le graphe la décrivant est sur la figure \ref{fig:iterative_sm_graph}.

![Graphe de la machine à états finis de Mealy pour l'architecture *Full Iterative*\label{fig:iterative_sm_graph}](mealy_iterative.png)

Nous pouvons ensuite écrire un tableau décrivant les différentes valeurs que doivent prendre les paramètres de la machine à états finis en fonction de l'état présent. Voir figure \ref{fig:iterative_sm_table}.

\Begin{figure}

+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
|                   | `out_valid`  | `in_ready`   | `inc_cpt`    | `rst_cpt`    | `w_en`       | `sel_input`  |
+===================+:============:+:============:+:============:+:============:+:============:+:============:+
| WAIT_DATA         | 0            | 1            | `in_valid`   | 0            | 1            | 0            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| RECEIVE           | 0            | 0            | 1            | `cpt = 7`    | 1            | 0            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| CALCUL            | 0            | 0            | 1            | `cpt = 25`   | `cpt > 1`    | 1            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| WAIT_OUT          | 1            | 0            | `out_ready`  | 0            | 0            | `X`          |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| TRANSMIT          | 0            | 0            | 1            | 1            | 1            | 1            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+

\caption{Valeur des paramètres de la machine à états pour l'architecture \textit{Full Iterative}}
\label{fig:iterative_sm_table}
\End{figure}

### Séquencage d'adresses

Les tableaux suivants indiquent l'ordre dans lequel il faut adresser la RAM en lecture et en écriture.

#### Réception

 R | W
:-:|:-:
 X | 0
 X | 1
 X | 2
 X | 3
 X | 4
 X | 5
 X | 6
 X | 7

#### Calcul

 R | W
:-:|:-:
 0 | X
 4 | X
 1 | 0
 5 | 4
 2 | 1
 6 | 5
 3 | 2
 7 | 6
 0 | 3
 2 | 7
 1 | 0
 3 | 2
 4 | 1
 6 | 3
 5 | 4
 7 | 6
 0 | 5
 1 | 7
 2 | 0
 3 | 1
 4 | 2
 5 | 3
 6 | 4
 7 | 5
 X | 6
 X | 7

#### Transmission

 R | W
:-:|:-:
 0 | X
 4 | X
 2 | X
 6 | X
 1 | X
 5 | X
 3 | X
 7 | X

## Implémentation

L'implémentation de l'architecture *Full Iterative* n'utilise qu'une seule instance de l'opérateur papillon qui sera reutilisée pour toutes les opérations. Cela aura l'avantage d'utiliser moins de ressources dans la plupart des cas, mais sera aussi plus lent que l'architecture alternative.

La seule instance de l'opérateur papillon aura ses entrées et ses sorties branchées respectivement sur l'entrée et la sortie de la RAM. Comme la RAM n'a qu'une seule entrée et qu'une seule sortie, il faudra mettre une bascule sur une des entrées et sur une des sorties du papillon. Cela permettera de synchroniser les deux entrées et les deux sorties de l'opérateur papillon.

Deux multiplexeurs seront ajoutées pour controller si l'entrée de la RAM viendra de la sortie de l'opérateur papillon ou des données d'entrées.

Pour contrôler ce circuit, un compteur basique a été immplementé. Il permettera à la machine à états finis de décider des adresses auxquelle il faut lire dans la RAM et de calculer les différents états.

![Architecture *Full Iterative*](architecture_full_iterative.png){width=70%}

## Performances

Plus la taille des FFT sera grande, plus le gain de ressources de l'architecture *Full Iterative* sur l'architecture *Full Pipeline* sera évident. Avec les petites FFT que nous avons implémentés, l'avantage ne se voit pas car le seuil de ressources demandé par la RAM et les autres petits composants utilisés sera tout de même important.

# Architecture hybride

L'architecture hybride permet d'essayer de profiter des avantages de l'architecture itérative et de l'architecture pipeline. Il s'agira de combiner le parallèlisme de l'architecture pipeline avec le économie de ressource de l'architecture itérative.

## Préparation

Pour combiner les deux architectures étudiés précédemment, il serait possible d'instancier quatres opérateurs papillon, simulant un étage de l'architecture pipeline. Ensuite, à l'instar de l'architecture itérative, une RAM dual port pourrait être instanciée afin de stocker les résultats intermédiaires.

## Structure


