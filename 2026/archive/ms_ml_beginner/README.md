this is made from ML-For-Beginners course of micrsoft

# ch2
```python
pd.get_dummy(data[column]) # get the one-hot encoding of specific data column
```

we can use `pipeline` api to combine all the operation processes into one pipe to use, example below

```python
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline

pipeline = make_pipeline(PolynomialFeatures(2), LinearRegression()) # 二阶多项式

pipeline.fit(X_train,y_train)
```

## classification

分类
* **二元分类**: 涉及一个类别
* **多项式分类** ：涉及多个类别，例如“橙色、白色和条纹”。
* **有序分类** ：涉及有序类别，适用于逻辑排序的结果，例如按有限大小排序的南瓜（迷你、小、中、大、特大、超大）。

要点
- 变量不需要相关
- 需要大量干净数据

# ch4
classifiers
- Linear Models
- Support Vector Machines
- Stochastic Gradient Descent
- Nearest Neighbors
- Gaussian Processes
- Decision Trees
- Ensemble methods (voting Classifier)
- Multiclass and multioutput algorithms (multiclass and multilabel classification, multiclass-multioutput classification)

# ch5
clustering

| Method name                  | Use case                                                               |
| :--------------------------- | :--------------------------------------------------------------------- |
| K-Means                      | general purpose, inductive                                             |
| Affinity propagation         | many, uneven clusters, inductive                                       |
| Mean-shift                   | many, uneven clusters, inductive                                       |
| Spectral clustering          | few, even clusters, transductive                                       |
| Ward hierarchical clustering | many, constrained clusters, transductive                               |
| Agglomerative clustering     | many, constrained, non Euclidean distances, transductive               |
| DBSCAN                       | non-flat geometry, uneven clusters, transductive                       |
| OPTICS                       | non-flat geometry, uneven clusters with variable density, transductive |
| Gaussian mixtures            | flat geometry, inductive                                               |
| BIRCH                        | large dataset with outliers, inductive                                 |


# ch6
Tasks common to NLP
- Tokenization
- Embeddlings: a similar meaning or words used together cluster together.
- Parsing & Part-of-speech Tagging
- Word and Phrase Frequencies
- N-grams
- Noun phrase Extraction
- Sentiment analysis
- Inflection(词形变化)
- Lemmatization(词形还原)

NLP Libraries
- `TextBlob` Library

# ch7
- Time Series
- Time Series Analysis
- Time Series Forecasting

##  ARIMA
ARIMA（自回归积分滑动平均模型，Autoregressive Integrated Moving Average）是一种广泛用于时间序列分析和预测的统计方法，特别适用于处理具有趋势或季节性的非平稳数据, 线性数据

## Support Vector Regressor
用于非线性的数据
