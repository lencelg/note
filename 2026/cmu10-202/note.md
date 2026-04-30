---
author: lencelg from Arcadia Bay
title: cmu10-202 note
---

[TOC]

# Lec 2
**The supervised machine learning paradigm**

- The "usual" programming approach
  - Specification of the desired behavior
  - Think about logic that will achieve that behavior
  - Write program

- The ML approach
  - Examples of the desired behavior
  - ML Algorithm
  - Produced "program"

**Downstream tasks** are specific AI, NLP, or computer vision applications that utilize pre-trained foundational models to achieve a targeted goal

# Lec 3
**vector** : one dimensional of array
- addition
- inner product
- transpose

**matrix** : two dimensional of array
- addition
- matrix multiplication
- transpose

there is another intersting interpation of matrix-verctor interpation

![](./img/matrix_vector_interpation.png)

- Properties of matrix multiplication  
  - Distributive: $A(B + C) = AB + AC$
  - Associative:  $(AB)C = A(BC) $
  - Not commutative: $ AB \neq BA $
  - Transpose of product: $ (AB)^T = B^TA^T $
