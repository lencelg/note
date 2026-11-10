# Trees

Trees are the data structure where recursion becomes natural.

Most tree problems follow DFS, going deep before backtracking,
or BFS, processing level by level.

- DFS is usually recursive and suits path-based problems
- BFS uses a queue and suits level-based or shortest-path questions.

A key habit is separating what a function returns from what it records as a
side effect, since many problems need a global answer tracked alongside local
recursive decisions.

Segment trees and Fenwick trees extend these ideas to range queries over a
mutable array, though they show up more in competitive programming
than standard interviews.

## 102. 二叉树的层序遍历

BFS

````cpp
vector<vector<int>> levelOrder(TreeNode* root) {
    vector<vector<int>> ans;
    if(!root) return ans;
    int curCount = 0;
    int curNeed = 1;
    int nextNeed = 0; 
    queue<TreeNode*> q;
    q.push(root);
    vector<int> vec;
    while(!q.empty()){
        TreeNode* cur = q.front();
        q.pop();
        vec.push_back(cur->val);
        if(cur->left)
        {
            q.push(cur->left);
            nextNeed++;
        }
        if(cur->right)
        {
            q.push(cur->right);
            nextNeed++;
        }
        curCount++;
        if(curCount == curNeed){
            curCount = 0;
            curNeed = nextNeed;
            nextNeed = 0;
            ans.emplace_back(std::move(vec));
            vec = {};
        }
    }
    return ans;
}
````

小优化：遍历完当前层以后，下一层需要的次数是`q.size()`

````cpp
vector<vector<int>> levelOrder(TreeNode* root) {
    vector<vector<int>> ans;
    if(!root) return ans;
    int curCount = 0;
    int curNeed = 1;
    queue<TreeNode*> q;
    q.push(root);
    vector<int> vec;
    while(!q.empty()){
        TreeNode* cur = q.front();
        q.pop();
        vec.push_back(cur->val);
        if(cur->left) q.push(cur->left);
        if(cur->right) q.push(cur->right);
        curCount++;
        if(curCount == curNeed){
            curCount = 0;
            curNeed = q.size();
            ans.emplace_back(std::move(vec));
            vec = {};
        }
    }
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/binary-tree-level-order-traversal/solutions/2049807/bfs-wei-shi-yao-yao-yong-dui-lie-yi-ge-s-xlpz)，灵神的写法一很有意思

## 104. 二叉树的最大深度

递归入门题

````cpp
int maxDepth(TreeNode* root) {
    if(root) return max(maxDepth(root->left), maxDepth(root->right)) + 1;
    else return 0;
}
````

也可以写成层序遍历

````cpp
int maxDepth(TreeNode* root) {
    int ans = 0;
    if(!root) return 0;
    queue<TreeNode*> q;
    q.push(root);
    while(!q.empty()){
        size_t size = q.size();
        for (size_t _ = 0; _ < size; _++)
        {
            TreeNode* cur = q.front();
            q.pop();
            if(cur->left) q.push(cur->left);
            if(cur->right) q.push(cur->right);
        }
        ans++; 
    }
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/maximum-depth-of-binary-tree/solutions/2010612/kan-wan-zhe-ge-shi-pin-rang-ni-dui-di-gu-44uz)

## 235. 二叉搜索树的最近公共祖先

要么都在当前节点的左子树，要么都在当前节点的右子树，如果都不满足说明当前节点就是答案

````cpp
TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
    while(true){
        int v = root->val; 
        if(p->val < v && q->val < v) root = root->left;
        else if(p->val > v && q->val > v) root = root->right;
        else break;
    }
    return root;
}
````

[官方题解](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-search-tree/solutions/428633/er-cha-sou-suo-shu-de-zui-jin-gong-gong-zu-xian-26)，这次官方题解写的不错

## 124. 二叉树中的最大路径和

数学归纳的思想

````cpp
int maxPathSum(TreeNode* root) {
    int ans = numeric_limits<int>::min();
    maxPathSumHelper(root, ans);
    return ans;
}

int maxPathSumHelper(TreeNode* root, int& ans){
    if(!root) return 0;

    int val = root->val;
    int l = max(maxPathSumHelper(root->left, ans), 0);
    int r = max(maxPathSumHelper(root->right, ans), 0);

    ans = max(l + r + val, ans);

    return max(l, r) + val;
}
````

[题解页](https://leetcode.cn/problems/binary-tree-maximum-path-sum/solutions)，这里的题解都差球不多

## 297. 二叉树的序列化和反序列化

使用层序遍历来记录和重建二叉树

````cpp
// Encodes a tree to a single string.
string serialize(TreeNode* root) {
    ostringstream ss;
    queue<TreeNode*> q;
    q.push(root);
    while(!q.empty()){
        TreeNode* cur = q.front();
        q.pop();

        if(cur){
            ss << cur->val << ' ';
            q.push(cur->left);
            q.push(cur->right);
        } else ss << 'n' << ' ';
    }
    return ss.str();
}

// Decodes your encoded data to tree.
TreeNode* deserialize(string data) {
    queue<TreeNode*> q;
    istringstream ss(data);
    string temp;
    ss >> temp;
    if(temp == "n"){
        return nullptr;
    }
    TreeNode* ans = new TreeNode(stoi(temp));
    q.push(ans);
    while(!q.empty()){
        TreeNode* cur = q.front();
        q.pop();

        ss >> temp;
        if(temp != "n"){
            TreeNode* new_node = new TreeNode(stoi(temp));
            cur->left = new_node;
            q.push(new_node);
        }

        ss >> temp;
        if(temp != "n"){
            TreeNode* new_node = new TreeNode(stoi(temp));
            cur->right = new_node;
            q.push(new_node);
        }
    }
    return ans;
}
````

[官方题解](https://leetcode.cn/problems/serialize-and-deserialize-binary-tree/solutions/290065/er-cha-shu-de-xu-lie-hua-yu-fan-xu-lie-hua-by-le-2)，评论区写的也不错

## 226. 翻转二叉树

标准的递归思路

````cpp
TreeNode* invertTree(TreeNode* root) {
    invertTreeHelper(root);
    return root;
}

void invertTreeHelper(TreeNode* root){
    if(!root) return;
    // 简洁写法：swap(root->left, root->right);
    TreeNode* temp = root->left;
    root->left = root->right;
    root->right = temp;
    invertTreeHelper(root->left);
    invertTreeHelper(root->right);
}
};
````

[灵神题解](https://leetcode.cn/problems/invert-binary-tree/solutions/2713610/shi-pin-shen-ru-li-jie-di-gui-pythonjava-zhqh)

## 543. 二叉树的直径

贡献度的思想，这里放回`-1`是因为直径首尾一定是两个叶子节点，这样处理可以简化代码

````cpp
class Solution {
private:
    int ans = 0;
    int diameterOfBinaryTreeHelper(TreeNode* root) {
        if(!root) return -1;
        int l = diameterOfBinaryTreeHelper(root->left) + 1;
        int r = diameterOfBinaryTreeHelper(root->right) + 1;
        ans = max(l + r, ans);
        return max(l, r);
    }
public:
    int diameterOfBinaryTree(TreeNode* root) {
        diameterOfBinaryTreeHelper(root);
        return ans;
    }
};
````

[灵神题解](https://leetcode.cn/problems/diameter-of-binary-tree/solutions/2227017/shi-pin-che-di-zhang-wo-zhi-jing-dpcong-taqma)

## 98. 验证二叉树

一开始看起来比较简单，看了失败的case就知道没有那么容易了，但是思想还是挺简单的，这里还要注意`INT_MAX`和`INT_MIN`的情形，所以要用64位整数

````cpp
bool isValidBST(TreeNode* root) {
    if(!root) return true;
    if(root->left && root->left->val >= root->val) return false;
    if(root->right && root->right->val <= root->val) return false;
    return isVaildBstHelper(root->left, numeric_limits<long>::min(), root->val) && isVaildBstHelper(root->right, root->val, numeric_limits<long>::max());
}

bool isVaildBstHelper(TreeNode* root, long min_val, long max_val){
    if(!root) return true;
    if(root->left){
        int v = root->left->val;
        if(v >= root->val || (v <= min_val) || (v >= max_val)) return false;
    }
    if(root->right){
        int v = root->right->val;
        if(v <= root->val || (v <= min_val) || (v >= max_val)) return false;
    }

    bool l = isVaildBstHelper(root->left, min_val, root->val);
    bool r = isVaildBstHelper(root->right, root->val, max_val);

    return l && r;
}
````

简化代码，这里考虑比较当前的值而不是其左右子树的值

````cpp
bool isValidBST(TreeNode* root) {
    return isVaildBstHelper(root, numeric_limits<long>::min(), numeric_limits<long>::max());
}

bool isVaildBstHelper(TreeNode* root, long min_val, long max_val){
    if(!root) return true;

    int v = root->val;
    if((v <= min_val) || (v >= max_val)) return false;

    bool l = isVaildBstHelper(root->left, min_val, root->val);
    bool r = isVaildBstHelper(root->right, root->val, max_val);

    return l && r;
}
````

[题解页](https://leetcode.cn/problems/validate-binary-search-tree/solutions)，官方和灵神的题解都不错，灵神的很全面

## 199. 二叉树的右视图

使用bfs

````cpp
vector<int> rightSideView(TreeNode* root) {
    vector<int> ans; 

    queue<TreeNode*> q;
    q.push(root);
    while(!q.empty())
    {
        size_t size = q.size();
        int val = INT_MAX;
        for (size_t i = 0; i < size; i++)
        {
            TreeNode* cur = q.front();
            q.pop();
            if(cur)
            {
                val = cur->val;
                q.push(cur->left);
                q.push(cur->right);
            }
        }
        if(val == INT_MAX) break;
        ans.push_back(val); 
    }
    return ans;
}
````

[题解页](https://leetcode.cn/problems/binary-tree-right-side-view/solutions)，官方题解写的一般，灵神依旧高水平题解

## 105. 从前序与中序遍历序列构造二叉树

最喜欢debug的一集。递归思路来构建，不过要处理好当前部分的`index`

````cpp
class Solution {
public:
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        size_t n = preorder.size();
        return buildTreeHelper(preorder, inorder, 0, 0, n - 1);
    }
private: 
    TreeNode* buildTreeHelper(vector<int>& preorder, vector<int>& inorder, int pStart, int iStart, int iEnd){
        if(iStart > iEnd) return nullptr;

        int mid;
        for (int i = iStart; i <= iEnd; i++)
        {
            if(inorder[i] == preorder[pStart])
            {
                mid = i;
                break;
            }
        }

        TreeNode* new_node = new TreeNode(preorder[pStart]);
        new_node->left = buildTreeHelper(preorder, inorder, pStart + 1, iStart, mid - 1);
        new_node->right = buildTreeHelper(preorder, inorder, pStart + mid - iStart + 1, mid + 1, iEnd);

        return new_node;
    }
};
````

优化：显而易见的就是可以加速match的过程，使用哈希表，因为没有重复元素

````cpp
class Solution {
public:
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        unordered_map<int, int> record;
        int n = preorder.size();
        for (size_t i = 0; i < n; i++)
        {
            record[inorder[i]] = i;
        }
        return buildTreeHelper(record, preorder, inorder, 0, 0, n - 1);
    }
private:
    TreeNode* buildTreeHelper(unordered_map<int, int> &hp, vector<int>& preorder, vector<int>& inorder, int pStart, int iStart, int iEnd){
        if(iStart > iEnd) return nullptr;

        int mid = hp[preorder[pStart]];

        TreeNode* new_node = new TreeNode(preorder[pStart]);
        new_node->left = buildTreeHelper(hp, preorder, inorder, pStart + 1, iStart, mid - 1);
        new_node->right = buildTreeHelper(hp, preorder, inorder, pStart + mid - iStart + 1, mid + 1, iEnd);

        return new_node;
    }
};
````

[题解页](https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-inorder-traversal/solutions)
