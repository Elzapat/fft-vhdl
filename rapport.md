---
title: Implémentations de l'algorithme FFT en VHDL
subtitle: Rapport de projet
author:
	- Arthur Gaudard
	- Morgan Van Amerongen
date: Vendredi 17 novembre 2023
lang: fr
documentclass: article
classoption: twocolumn
numbersections: true
geometry:
	- margin=1in
toc: true
toc-depth: 3
block-headings: true
indent: true
header-includes:
	- \usepackage{circuitikz}
...

# Presentation

# Opérateur papillon

## Théorie

## Implémentation

# Architecture pipeline

## Préparation

## Implémentation

## Performances

# Architecture itérative

## Préparation

### Machine d'état



+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
|                   | `out_valid`  | `in_ready`   | `inc_cpt`    | `rst_cpt`    | `w_en`       | `sel_input1` |
+===================+:============:+:============:+:============:+:============:+:============:+:============:+
| WAIT_DATA         | 0            | 1            | `in_valid`   | 0            | 1            | 0            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| RECEIVE           | 0            | 0            | 1            | `cpt = 7`    | 1            | 0            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| CALCUL            | 0            | 0            | 1            | `cpt = 25`   | `cpt > 1`    | 1            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| WAIT_OUT          | 1            | 0            | `out_ready`  | 0            | 0            | X            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+
| TRANSMIT          | 0            | 0            | 1            | 1            | 1            | 1            |
+-------------------+--------------+--------------+--------------+--------------+--------------+--------------+

### Séquencage d'adresses

## Implémentation

## Performances

# Architecture hybride

## Préparation

## Structure
