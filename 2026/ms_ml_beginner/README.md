this is made from ML-For-Beginners course of micrsoft

# chapter2
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


