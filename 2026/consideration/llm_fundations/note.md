---
author: lencelg from Arcadia Bay
title: note of Foundations-of-LLMs
---

book: [Foundations-of-LLMs](https://github.com/ZJU-LLMs/Foundations-of-LLMs)

[TOC]

# language model basis
语言是一套复杂的符号系统。

语言符号具有不确定性: 语言符号通常在音韵（Phonology）、词法（Mor-phology）、句法（Syntax）的约束下构成，并承载不同的语义（Semantics）。

语言模型（Language Models, LMs）旨在**准确预测语言符号的概率**

## based on Statistics
语言模型通过对 **语料库（Corpus）** 中的语料进行统计或学习来获得预测语言符号概率的能力。
 
n-grams 是最具代表性的统计语言模型, **n-grams 语言模型基于马尔可夫假设和离散变量的极大似然估计给出语言符号的概率**。

设包含 \( N \) 个元素的语言符号可以表示为 \( w_{1:N} = \{w_1, w_2, w_3, \dots, w_N\} \)。

n-grams 语言模型中的 n-gram 指的是长度为 \( n \) 的词序列。n-grams 语言模型通过依次统计文本中的 n-gram 及其对应的 (n-1)-gram 在语料库中出现的相对频率来计算文本 \( w_{1:N} \) 出现的概率。计算公式如下所示：

\[P_{n-grams}(w_{1:N}) = \prod_{i=n}^{N} \frac{C(w_{i-n+1:i})}{C(w_{i-n+1:i-1})}, \tag{1.1}\]

其中，\( C(w_{i-n+1:i}) \) 为词序列 \(\{w_{i-n+1}, \dots, w_i\}\) 在语料库中出现的次数，\( C(w_{i-n+1:i-1}) \) 为词序列 \(\{w_{i-n+1}, \dots, w_{i-1}\}\) 在语料库中出现的次数。

**n-grams 具备对未知文本的泛化能力 , 但是，这种泛化能力会随着 n 的增大而逐渐减弱。**