#import "@preview/ori:0.2.5": *

#set heading(numbering: numbly("{1:一}、", default: "1.1  "))
#set math.equation(numbering: "(1)")

#show: ori.with( title: "os review note",
  author: "lencelg from Arcadia Bay",
  semester: "2026 summer",
  date: datetime.today(),
  maketitle: true,
  size: 10pt,
  lang: "en",
  font: (
    main: "Noto Sans CJK SC",
    mono: "IBM Plex Mono",
    cjk: "Noto Sans CJK SC",
    emph-cjk: "Noto Sans CJK SC",
    math-cjk: "Noto Sans CJK SC"
  )
)

#show raw: set text(font: "Hack Nerd Font")
#outline()

#pagebreak()

#set text(weight: 500)
= introduction

// #note[The big idea, in your own words. The passive layer.]
//
// #definition[a name][State the object, leave a clause blank: #fillin(width: 3cm).] <def:thing>
//
// #theorem[attribution][State the result, then refer back to @def:thing.] <thm:main>
// #proof[Skeleton: (i) … (ii) … #TODO[the step that makes it work]]
//
// #yourturn[Restage it as your own computation. #workspace(n: 3)]
//

== basis

#grid(
  columns: (1fr, 1fr, 1fr),
  [
      算法五大特性
      - 有穷性
      - 确定性
      - 可行性
      - 输入
      - 输出
  ],
  [
    渐进符号
    - $O$ 上界
    - $Omega$ 同阶
    - $Theta$ 下界
  ],
  [
    渐进符号特性
    - 传递性
    - 自反性
    - 对称性
  ],
)

== stl

#block(
  [
    ```cpp
    sort(myv.begin(),myv.end(),[](int a,int b)->bool { return a<b; });			//递增排序(默认)
    sort(myv.begin(),myv.end(),[](int a,int b)->bool { return a>b; });			//递减排序
    ```
  ]
)

其他的不多赘述

#pagebreak()

= recursion

#text(fill: blue)[递归（recursion）]是一个过程或函数在其定义或说明中直接或间接调用自身的一种方法

这里主要是例子增加经验

== 例2.6

#problem[
  给定一个含n（n>2）个整数的数组a，设计一个递归算法求其中最大元素。
]

#solution[
```cpp
int maxe(int a[],int low,int high) {			//递归算法
	if (low==high)
		return a[low];
	else {
		int mid=(low+high)/2;
		int lmaxe=maxe(a,low,mid);
		int rmaxe=maxe(a,mid+1,high);
		return max(lmaxe,rmaxe);
	}
}
```
]

== 例2.7
#problem[
  给定一个不带头结点的单链表h，设计一个递归算法删除其中所有结点值为x的结点。
]


#tip-block(
  [
   + f(h，x) ≡ 不做任何事件 #h(171pt)当h=NULL时
   + f(h，x) ≡	删除h结点； 让h指向原后继结点；f(h，x) #h(34pt)当h->val=x时
   + f(h，x) ≡ f(h->next，x)#h(171pt)当h->val≠x
  ]
) 
#solution([
  ````cpp
void Delallx(ListNode *&h,int x)	{
//删除L中所有结点值为x的结点
	ListNode *p;
	if (h==NULL) return;
	if (h->val==x) {
		p=h; h=h->next;
		delete p;								//删除结点值为x的结点
		Delallx(h,x);						//此时减少了一个结点
	}
	else Delallx(h->next,x);
}
````
])

== 例 2.8
#problem([
  设大问题$f(r)$的功能是由二叉树r复制产生另一棵二叉树r1并返回r1。
])

#solution([
  ````cpp
class Solution {
public:
	TreeNode* cloneTree(TreeNode* r) {
 		if (r==NULL) return NULL;
   	else {
     		TreeNode* r1=new TreeNode(r->val);
       	r1->left=cloneTree(r->left);
       	r1->right=cloneTree(r->right);
       	return r1;
    	}
 	}
};
````
])

== 0/1 背包

#problem([
有n个物品，物品编号为0～n-1，重量为${w_0，w_1，…，w_(n-1)}$，价值为${v_0，v_1，…，v_(n-1)}$，给定一个容量为W的背包。现在从这些物品中选取若干物品装入该背包的方案，每个物品要么选中要么不选中，要求选中的物品总重量不超过背包容量并且具有最大的价值。
])

#tip-block([
- 用数组x存放一个装入方案，x[i]=1表示选择物品i，x[i]=0表示不选择物品i（x称为解向量）。
- 设大问题f(w，v，i，rw)表示考虑物品i～n-1（共n-i个）并且背包剩余容量为rw时的最大价值。
- 小问题f(w，v，i+1，rw)表示考虑物品i+1～n-1（共n-i-1个）并且此时背包剩余容量为rw时的最大价值。
- 大小问题需要考虑的物品个数相差一个即物品i。
])

#solution([
  ````cpp
vector<int> x;											//解向量
int dfs(vector<int>&w,vector<int>&v,int i,int rw) {
	int n=w.size();
	if (i>=n || rw<0) return 0;					//递归出口
	int maxv1=0;
	if(rw>=w[i]) {
		maxv1=dfs(w,v,i+1,rw-w[i])+v[i];  	//选择物品i
	}
	int maxv2=dfs(w,v,i+1,rw);          		//不选择物品i
	if(maxv1>maxv2) {
		x[i]=1;
		return maxv1;
	}
	else {
		x[i]=0;
		return maxv2;
	}
}
````
])

== 主方法

#image("img/master.png", width: 100%)

= 穷举法

== 例 3.2

#problem([
子数组之和（LintCode138★）。给定一个整数数组nums，设计一个算法找到和为0的子数组，返回满足要求的子数组的起始位置和结束位置，测试数据保证至少有一个子数组的和为0，如果有多个子数组的和为0，返回其中任意一个子数组即可。
   
例如，nums={-3，1，2，-3，4}，答案为{0，2}或{1，3}。
])

=== BF

#solution([
    ````cpp
    class Solution {
    public:
        vector<int> subarraySum(vector<int> &nums) {
          vector<int> ans;
         	int n=nums.size();
         	for(int i=0;i<n;i++) {
         		for(int j=i;j<n;j++) {
          		int sum=0;
             	for(int k=i;k<=j;k++) sum+=nums[k];
              if(sum==0) {
              		ans.push_back(i);	ans.push_back(j);
                	return ans;
             	}
          	}
        	}
        	return {0,0};    				//没有找到
      	}
    };
    ````
])

=== 前缀和数组

#solution([
```cpp
class Solution {
public:
  	vector<int> subarraySum(vector<int> &nums) {
		  int n=nums.size(); int psum[n+1];
    	psum[0]=0;
    	for(int i=1;i<=n;i++) psum[i]=psum[i-1]+nums[i-1];
    	vector<int> ans;
    	for(int i=0;i<n;i++) {
     		for(int j=i;j<n;j++) {
        	int sum=psum[j+1]-psum[i];  //求nums[i..j]之和
         	if(sum==0) {
          		ans.push_back(i); ans.push_back(j);
           	  return ans;
         	}
       	}
    	}
    	return {0,0};
  	}
};
```
])

=== 哈希表加前缀和

这里前缀和不用使用数组了

#solution([
````cpp
class Solution {
public:
 	vector<int> subarraySum(vector<int> &nums) {
   	unordered_map<int,int> hmap;
    vector<int> ans;  	int n=nums.size();
    hmap[0]=-1; int psum=0;
    for (int j=0;j<n;j++) {
     	  psum+=nums[j];
       	if (hmap.count(psum)>0) {		//找到了psum
        	ans.push_back(hmap[psum]+1); ans.push_back(j);
         	return ans;
       	}
       	hmap[psum]=j;
   	}
   	return ans;
  	}
};
````
])

== 例 3.4
#problem(
  [
最大子序和（LeetCode53★）。给定一个含n（1≤n≤10^5）个整数的数组 nums，设计一个算法找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。
   
例如，nums={-2，1，-3，4，-1，2，1，-5，4}，答案为6。
  ]
)

同样的思想
- BF(朴素和改进版)
- 前缀和数组

下面介绍贪心， 这道题具有#text(fill: blue)[贪心性质]

#solution([
````cpp
int maxsubsum4(int a[],int n) {		//解法4
  	int maxsum=a[0],cursum=a[0];
  	for (int i=1;i<n;i++) {
  		cursum+=a[i];
      if(cursum>=maxsum)			//比较求最大maxsum
         maxsum=cursum;
      if(cursum<0)					//若cursum<0，从下一个位置开始
         cursum=0;
  	}
  	return maxsum;
}
````
])

== 0/1 背包

这里就是求了幂集然后再一个个判断条件，不多赘述

#pagebreak()

= 分治法

了解一下即可
- 快排
- 归并排序
 - 自底向上版本
 - 自顶向下版本

二分查找，ppt的版本是左闭右闭区间的写法

stl内置方法: `lower_bound` , `upper_bound`

#problem[
数组中的第k个最大元素（LeetCode215★★）。设计一个算法求无序数组nums中第k（1≤k≤数组的长度）大的整数，注意不是第k个不同的元素，而是数组排序后的第k个最大的元素。
   
例如，nums={3，2，1，5，6，4}，k=2，nums递减排序后是{6，5，4，3，2，1}，答案为5，若k=5，答案为2。
]

#tip-block([
这里求n个元素中第k大的元素，实际上就是求第n-k+1小的元素。

重点设计求第k小元素的算法。

对数组nums，遍历一次求最小元素mind和最大元素maxd，在[mind，maxd]区间中通过二分查找求第k小的元素。 这里也可以使用快速选择 (Quick Select) 来做
])

#solution([
  ````cpp
class Solution {
public:
	int findKthLargest(vector<int>& nums,int k) {
	   	int mind=nums[0],maxd=nums[0];
     	for(int i=1;i<nums.size();i++) {  //求最大最小元素
     		if(nums[i]>maxd) maxd=nums[i];
       	else if(nums[i]<mind) mind=nums[i];
    	}
    	if(maxd==mind)  							//所有元素相同的情况
      	return maxd;
     	else
     		return smallk(nums,mind,maxd,nums.size()-k+1);  //求n-k+1小的元素
   }
  int smallk(vector<int>&a,int mine,int maxe,int k) {     			//求第k小的元素
     	int n=a.size();
     	int low=mine,high=maxe;
     	while(low<=high) {
       		int mid=(low+high)/2;
       		int cnt=0;
       		for (int i=0;i<n;i++)  		//求≤mid的元素个数cnt
            	if (a[i]<=mid) cnt++;
       		if(cnt>=k) high=mid-1;		//查找第一个cnt≥k的mid
         	else low=mid+1;
     	}
     	return low;
  }
 };
````
])

#pagebreak()

= 回溯法

== exercise
#problem[
有n个集装箱要装上一艘载重量为t的轮船，其中集装箱i（0≤i≤n-1）的重量为wi。不考虑集装箱的体积限制，现要选出#text(fill: blue)[重量和小于等于t并且尽可能重]的若干集装箱装上轮船。

例如，n=5，t=10，w={5，2，6，4，3}时，其最佳装载方案有两种即（1，1，0，0，1）和（0，0，1，1，0），对应集装箱重量和达到最大值t。
]

#tip-block([
- 左剪支：判断选择集装箱i是否合适。检查当前集装箱被选中后总重量是否超过t，若是则剪支，即仅仅扩展满足cw+w[i]≤t的左孩子结点。

- 右剪支：判断不选择集装箱i是否合适。如果不选择集装箱i，此时剩余的所有整数和为rw，若cw+rw≤bestw成立，所有仅仅扩展满足cw+rw>bestw的右孩子结点
])

#solution([
  ````cpp

void dfs(int cw,int rw,int i) { 	//回溯算法
	tot++;
  if (i>=n) {								//达到一个叶子结点
  		if (cw>bestw) {				     	//找到一个满足条件的更优解
     		bestw=cw;					    	//保存更优解
      	bestx=x;
    	}
 	}
	else {										//尚未找完所有集装箱
  		rw-=w[i];								//求剩余集装箱的重量和
  		if (cw+w[i]<=t) {					//左孩子结点剪支
     		x[i]=1;								//选取集装箱i
      	cw+=w[i];							//累计当前所选集装箱的重量和
      	dfs(cw,rw,i+1);
      	cw-=w[i];							//恢复(回溯)
    	}

    	if (cw+rw>bestw) {					//右孩子结点剪支
     		x[i]=0;								//不选择集装箱i
      	dfs(cw,rw,i+1);
    	}
    	rw+=w[i];								//恢复(回溯)
  	}
}
    ````
])

#pagebreak()

== 0/1 背包

老朋友了

#important-block([
  限界函数\
  ````cpp
double bound(int cw,int cv,int i) {
//计算第i层结点的上界函数值
	int rw=W-cw; 						//背包的剩余容量
	double b=cv; 						//表示物品价值的上界值
	int j=i;
	while (j<n && g[j].w<=rw) {
		rw-=g[j].w; 						//选择物品j
		b+=g[j].v; 						//累计价值
		j++;
	}
	if (j<n) 								//最后一个物品只能部分装入
		b+=(double)g[j].v/g[j].w*rw;
	return b;
}
````
])

#solution([
  ````cpp
void dfs(int cw,int cv,int i) {  			//回溯算法
  	tot++;												//累计调用次数 
  	if (i>=n)	{										//到达一个叶子结点
    	if (cw<=W && cv>bestv) {				//找到一个更优解
        	bestv=cv;
        	bestx=x;
   	  }
  	}
  	else {												//没有到达叶子结点
  	  if(cw+g[i].w<=W) {	  						//左剪支
     		x[i]=1;										//选取物品i
     		dfs(cw+g[i].w,cv+g[i].v,i+1);
    	}
   	  double b=bound(cw,cv,i+1);			//计算限界函数值
   	  if(b>bestv)	{			          		//右剪支
     		x[i]=0;										//不选取物品i
      	dfs(cw,cv,i+1);
		}
  	}
}
````
])

== 完全背包问题

#problem[
有n种重量和价值分别为$w_i,v_i（0≤i<n）$的物品，从这些物品中挑选总重量不超过W的物品，每种物品可以挑选任意多件，求挑选物品的最大价值。该问题称为完全背包问题。
]

#tip-block([
与0/1背包问题不同，完全背包问题中物品i指的是第i种物品，每种物品可以取任意多件。

对于解空间中第i层的结点，用cw、cv表示选择物品的总重量和总价值，这样处理物品i的几种操作方式如下：
- 不选择物品i。
- 当cw+w[i]≤W时，选择物品i一件，下一步继续选择物品i。
- 当cw+w[i]≤W时，选择物品i一件，下一步开始选择物品i+1。
])

#solution([
  ````cpp
int bestv=0;      							//存放最大价值,初始为0
void dfs(int cw,int cv,int i) {   //回溯算法
	if(i>=n) {
  		if(cw<=W && cv>bestv)       	//找到一个更优解
     		bestv=cv;
	}
  else {
      dfs(cw,cv,i+1);             	//不选择物品i
      if(cw+w[i]<=W)						//剪支
         dfs(cw+w[i],cv+v[i],i);  	//选择物品i，然后继续选择物品i
      if(cw+w[i]<=W)						//剪支
         dfs(cw+w[i],cv+v[i],i+1); //选择物品i,然后选下一件
  	}
}
````
])

#pagebreak()

= 分支界限法
#figure(
    table(
          columns: 5,
          [算法], [解空间搜索方式], [存储结点的数据结构], [结点存储特性], [常用应用],
          [回溯法], [深度优先搜索], [栈], [只保存从根结点到当前扩展结点的路径], [能够找出满足约束条件的所有解],
          [分支限界法], [广度优先搜索], [队列或者优先队列], [每个结点只有一次成为活结点的机会], [找出满足约束条件的一个解或者满足目标函数的最优解]
    ),
    caption: [comparison]
)

下面可以参考另一份note
= 动态规划

下面可以参考另一份note

= 贪心算法

下面可以参考另一份note
