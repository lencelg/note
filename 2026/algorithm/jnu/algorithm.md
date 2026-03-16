# algorithm 
PS: readed from 算法设计与分析（第2版） and ppt from lecture
---
## Introduction
### big O notation
|meansurement|description|
---|---
$\mathcal{\Theta}(n)$|upper bound of algorithm
$\mathcal{\Omega}(n)$|lower bound of algorithm
$\mathcal{O}(n)$| approximate size of a function on a domain
### STL
|data structure| header|
|---|---|
vector| \<vector>
string| \<string>
deque| \<deque>
list| \<list>
stack| \<stack>
priority_queue| \<queue>
set/mutilset| \<set>
map/mutilmap| \<map>
unordered_map| \<unordered_map>
unordered_set| \<unordered_set>
---
`rbegin()` and `rend()` for reverse iterator<br>
```c++
sort(myv.begin(),myv.end(),[](Stud& a,Stud& b)->bool { return a.no<b.no; });				//按no递增排序
sort(myv.begin(),myv.end(),[](Stud& a,Stud& b)->bool { return a.name>b.name; });			//按name递减排序
// less<T>, greater<T>, STL built-in function

// to define your own comparsion method in struct, two ways below
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

struct Stud
{
    int no;
    string name;

    Stud(int no1, string name1)
    {
        no = no1;
        name = name1;
    }

    // overload the < operator
    bool operator<(const Stud &s) const
    {
        return s.no < no; 
    }
};

// or use a functor
struct Cmp
{
    bool operator()(const Stud &s, const Stud &t) const
    {
        return s.name < t.name; 
    }
};
```
---
priority_queue
```c++
// to define your owner priority queue, three ways available
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

struct Stud
{
    int no;
    string name;

    Stud(int no1, string name1)
    {
        no = no1;
        name = name1;
    }

    // overload the < operator
    bool operator<(const Stud &s) const
    {
        return no < s.no; 
    }
    // or overload the > operator
    bool operator>(const Stud &s) const
    {
        return no > s.no; 
    }

};

// or use a functor
struct Cmp
{
    bool operator()(const Stud &s, const Stud &t) const
    {
        return s.name < t.name; 
    }
};
`
```
## Recursion
Horner rule
```c++
// 多项式求解结果
double Horner(double a[], int n, double x, int i){
    if(i == 0) return a[n];
    else return x * Horner(a, n, x, i - 1) + a[n - i];
}
```
## Divide and Conquer
a problem can be divided into several subproblem with similar structure<br>
* quick sort
* merge sort
