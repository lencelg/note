# Linked List

Linked list problems test your ability to manipulate pointers directly, without
the convenience of index-based access.

The core techniques are:

- the dummy node (to simplify edge cases at the head)
- the fast and slow pointer (to find midpoints and detect cycles)
- in-place reversal (to rearrange nodes without extra memory)

These three techniques cover the majority of linked list problems.
The problems here also build the pointer intuition you will need
when working with trees in the next stage.

## 206. 反转链表

两种写法，递归和循环

我这里算是写了一点小优化，对于`head != nullptr`的时候才调用helper function。

````cpp
public:
    ListNode* reverseList(ListNode* head) {
        if(head == nullptr) return head;
        ListNode* s = head;        
        reverseListHelper(head, s);
        head->next = nullptr;
        return s; 
    }
private:
    void reverseListHelper(ListNode* prev, ListNode* &s){
        if(prev->next == nullptr) return;
        ListNode* cur = prev->next;
        s = cur;
        reverseListHelper(cur, s);
        cur->next = prev;
    }
````

我个人还是更喜欢写循环一些，性能好一些并且写起来不算难

````cpp
ListNode* reverseList(ListNode* head) {
    if(head == nullptr || head->next == nullptr) return head;
    ListNode* prev, *cur, *nex;
    prev = head, cur = head->next, nex = cur->next;
    head->next = nullptr;
    while(nex != nullptr)
    {
        cur->next = prev;
        prev = cur;
        cur = nex;
        nex = nex->next;
    }
    cur->next = prev;
    return cur;
}
````

[灵神题解](https://leetcode.cn/problems/reverse-linked-list/solutions/1992225/you-xie-cuo-liao-yi-ge-shi-pin-jiang-tou-o5zy)，灵神题解更加简洁优雅

## 21. 合并两个有序链表

使用哨兵节点来写

````cpp
ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {
    ListNode ans = ListNode(-1);        
    ListNode* cur = &ans;
    while(list1 && list2)
    {
        if(list1->val <= list2->val)
        {
            cur->next = list1;
            cur = cur->next;
            list1 = list1->next;
        }else
        {
            cur->next = list2;
            cur = cur->next;
            list2 = list2->next;
        }
    }
    while(list1)
    {
        cur->next = list1;
        cur = cur->next;
        list1 = list1->next;
    }
    while(list2)
    {
        cur->next = list2;
        cur = cur->next;
        list2 = list2->next;
    }
    cur->next = nullptr;
    return ans.next;
}
````

可以做一些小优化

````cpp
ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {
    ListNode ans = ListNode(-1);        
    ListNode* cur = &ans;
    while(list1 && list2)
    {
        if(list1->val <= list2->val)
        {
            cur->next = list1;
            list1 = list1->next;
        }else
        {
            cur->next = list2;
            list2 = list2->next;
        }
        cur = cur->next;
    }
    cur->next = list1 ? list1 : list2;
    return ans.next;
}
````

[灵神题解](https://leetcode.cn/problems/merge-two-sorted-lists/solutions/2373691/liang-chong-fang-fa-die-dai-di-gui-pytho-wf75)

## 141. 环形链表

快慢指针

这里写成`do-while loop`就简洁一些

````cpp
bool hasCycle(ListNode *head) {

    ListNode *fast = head, *slow = head; 

    do{
        if(fast && fast->next) fast = fast->next->next;
        else return false;

        slow = slow->next;
    }
    while(fast != slow);

    return true;
}
````

[灵神题解](https://leetcode.cn/problems/linked-list-cycle/solutions/1999269/mei-xiang-ming-bai-yi-ge-shi-pin-jiang-t-c4sw)

## 143. 重排链表

这道题乍一看没什么头绪，但是很容易想到是正向链表和反向链表的合并，使用变长数组来储存每个node的地址

````cpp
void reorderList(ListNode* head) {
    vector<ListNode *> record;        
    ListNode* temp = head;
    while(temp)
    {
        record.push_back(temp);
        temp = temp->next;
    }

    ListNode* left = head;
    for (int i = record.size() - 1; i >= 0; i--)
    {
        ListNode* right = record[i];
        if(left == right)
        {
            left->next = nullptr;
            return;
        }else if(left->next == right)
        {
            right->next = nullptr;
            return;
        }else
        {
            ListNode* temp = left->next;
            left->next = right;
            right->next = temp;
            left = temp;
        }
    }
}
````

[灵神题解](https://leetcode.cn/problems/reorder-list/solutions/1999276/mei-xiang-ming-bai-yi-ge-shi-pin-jiang-t-u66q)，灵神的题解还要硬核一些，既然这里是正向链表和反向链表的合并那就找到中间的值然后反向后半部分，最后再合并

还是佩服灵神的思路和能力，下次遇到这道题我也试试灵神的解法

> You find the middle, reverse the second half, then merge the two halves.

## 23. 合并k个有序链表

暴力轮询，空间$O(1)$，时间$O(k * length)$(length是所有链表的长度之和)

````cpp
ListNode* mergeKLists(vector<ListNode*>& lists) {
    ListNode* s = new ListNode(1e5); 
    ListNode* end = s;
    while(true)
    {
        ListNode* cur = s;
        int index = -1;
        for (size_t i = 0; i < lists.size(); i++)
        {
            if(lists[i]) 
            {
                if(lists[i]->val > cur->val) continue;
                cur = lists[i];
                index = i;
            }
        }
        if(index == -1) break;
        end->next = cur;
        end = cur;
        lists[index] = lists[index]->next;
    }
    end->next = nullptr;
    ListNode* ans = s->next;
    delete s;
    return ans;
}
````

这时候就想要加速查找了，使用最小堆

````cpp
ListNode* mergeKLists(vector<ListNode*>& lists) {
    ListNode* s = new ListNode(1e5); 
    ListNode* end = s;

    auto cmp = [](ListNode* const& a, ListNode* const& b) {
        return a->val > b->val;
    };
    priority_queue<ListNode*, vector<ListNode*>, decltype(cmp)> pq(cmp);

    for (size_t i = 0; i < lists.size(); i++)
    {
        if(lists[i])
        {
            pq.push(lists[i]);
        }
    }
    while(!pq.empty())
    {
        ListNode* cur = pq.top();
        end->next = cur;
        end = cur;
        pq.pop();
        if(cur->next)
        {
            pq.push(cur->next);
        }
    }
    end->next = nullptr;
    ListNode* ans = s->next;
    delete s;
    return ans;
}
````

看了题解才发现原来这道题hard在原地进行链表合并，k个链表合并本质是两两有序链表合并，受教了

[灵神题解](https://leetcode.cn/problems/merge-k-sorted-lists/solutions/2384305/liang-chong-fang-fa-zui-xiao-dui-fen-zhi-zbzx/)

## 19. 删除链表的倒数第 N 个节点

感觉算是一道小的练习题

````cpp
ListNode* removeNthFromEnd(ListNode* head, int n) {
    int index = 0; 
    ListNode* temp = head;
    while(temp)
    {
        index++;
        temp = temp->next;
    }

    index -= n;

    if(index == 0) return head->next;
    ListNode* cur = head;
    while(--index)
    {
        cur = cur->next;
    }
    cur->next = cur->next->next;
    return head;
}
````

看了[灵神的题解](https://leetcode.cn/problems/remove-nth-node-from-end-of-list/solutions/2004057/ru-he-shan-chu-jie-dian-liu-fen-zhong-ga-xpfs)才明白这里的小巧思是前后指针，感觉思维还是没有跟上

## 138. 随机链表的复制

这里很容易想到想建立一一对应的关系，于是可以使用哈希表来映射地址，空间$O(n)$，时间$O(n)$

````cpp
Node* copyRandomList(Node* head) {
    Node* s = new Node(-1);        

    Node* cur = s;
    unordered_map<Node*, Node*> hp;

    // copy list
    Node* temp = head;
    while(temp)
    {
        Node* new_node = new Node(temp->val);
        cur->next = new_node;
        cur = new_node;
        hp[temp] = cur;
        temp = temp->next;
    }

    // copy random pointer
    cur = s->next;
    temp = head;
    while(cur)
    {
        if(hp.count(temp->random)) cur->random = hp[temp->random];
        temp = temp->next;
        cur = cur->next;
    }

    cur = s->next;

    delete s;
    return cur;
}
````

于是考虑有无空间$O(1)$的做法，其实可以想到就是遍历到`random`的位置，于是就可以建立对应关系，这里顺带做了一点小优化

时间$O(n^2)$，$n$代表链表的长度

````cpp
Node* copyRandomList(Node* head) {
    if(!head) return nullptr;

    Node* s = new Node(head->val);
    Node* cur = s;

    // copy list
    Node* temp = head->next;
    while(temp)
    {
        Node* new_node = new Node(temp->val);
        cur->next = new_node;
        cur = new_node;
        temp = temp->next;
    }

    // find random pointer
    auto f = [](Node* target, Node* start, Node* head) mutable {
        while(head != target){
            head = head->next;
            start = start->next;
        }
        return start;
    };

    // copy random pointer
    cur = s;
    temp = head;
    while(cur)
    {
        if(temp->random)
        {
            cur->random = f(temp->random, s, head);
        }
        temp = temp->next;
        cur = cur->next;
    }

    return s;
}
````

[灵神题解](https://leetcode.cn/problems/copy-list-with-random-pointer/solutions/2993775/bu-yong-ha-xi-biao-de-zuo-fa-pythonjavac-nzdo)，看了灵神的题解只剩下惊叹。

灵神这里构建一一对应的关系十分巧妙，奇偶链表的思维，受教了

## 2. 两数相加

处理好进位然后代码简化一下

````cpp
ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
    bool carry = false;
    ListNode* ans = new ListNode(0);
    ListNode* cur = ans;
    while(l1 && l2)
    {
        int sum = l1->val + l2->val;
        if(carry) sum += 1;
        carry = sum / 10;
        ListNode* new_node = new ListNode(sum % 10); 
        cur->next = new_node;
        cur = new_node;
        l1 = l1->next;
        l2 = l2->next;
    }

    l1 = l1 ? l1 : l2;
    while(l1)
    {
        int sum = l1->val;
        if(carry) sum += 1;
        carry = sum / 10;
        ListNode* new_node = new ListNode(sum % 10); 
        cur->next = new_node;
        cur = new_node;
        l1 = l1->next;
    }

    if(carry)
    {
        cur->next = new ListNode(1); 
    }

    cur = ans->next; 
    delete ans;
    return cur;
}
````

[灵神题解](https://leetcode.cn/problems/add-two-numbers/solutions/2327008/dong-hua-jian-ji-xie-fa-cong-di-gui-dao-oe0di)，代码更加简洁

## 146. LRU缓存

双端链表加哈希

````cpp
struct Node{
    int key;
    int val;
    Node* prev;
    Node* next;
    Node(int v, int k): val(v), key(k), next(nullptr), prev(nullptr){}
    Node(int v, int k, Node* n, Node* p): val(v), key(k), next(n), prev(p){}
};
class LRUCache {
public:
    LRUCache(int capacity): _capacity(capacity), _size(0){
        s = new Node(-1, -1);
        end = s;
        s->next = s, s->prev = s;
    }
    
    int get(int key) {
        if(!hp.count(key)) return -1;

        Node* cur = hp[key];
        if(cur != end){
            cur->prev->next = cur->next;
            cur->next->prev = cur->prev;

            cur->prev = end;
            cur->next = s;
            end->next = cur;
            end = cur;
            s->prev = end;
        }

        return cur->val;
    }
    
    void put(int key, int value) {
        if(hp.count(key)){
            Node* cur = hp[key];
            cur->val = value;

            if(cur != end){
                cur->prev->next = cur->next;
                cur->next->prev = cur->prev;

                cur->prev = end;
                cur->next = s;
                end->next = cur;
                end = cur;
                s->prev = end;
            }
            return;
        }
        
        Node* cur = new Node(value, key, s, end);
        end->next = cur;
        end = cur;
        s->prev = end;

        hp[key] = cur;
        _size++;

        if(_size > _capacity){
            Node* nodeToDelete = s->next;
            s->next = nodeToDelete->next;
            nodeToDelete->next->prev = s;
            hp.erase(nodeToDelete->key);
            delete nodeToDelete;
            _size--;
        }
    }
    ~LRUCache(){
        Node* cur = s->next;
        while(cur != end){
            Node* curToDelete = cur;
            cur = cur->next;
            delete curToDelete;
        }
        if(s != end) delete end;
        delete s;
    }
private:
    int _capacity;
    int _size;
    Node *s,*end;
    unordered_map<int, Node*> hp;
};
````

[灵神题解](https://leetcode.cn/problems/lru-cache/solutions/2456294/tu-jie-yi-zhang-tu-miao-dong-lrupythonja-czgt)，重点可以看一下标准库的写法

## 25. k个一组的翻转链表

翻转链表的变形题，思路很直接，主要是在写的时候小心一些

````cpp
class Solution {
public:
    ListNode* reverseKGroup(ListNode* head, int k) {
        int count = 0;        
        ListNode* dummy = new ListNode(-1, head);

        ListNode* start = dummy, *end = dummy;
        ListNode* nextGroupStart = nullptr;
        
        while(true){
            // find one group
            while(count < k && end){
                end = end->next;
                count++;
            }

            // end equals nullptr, requirements no statisfiy
            if(!end) break;

            // reverse this group
            if(count == k){
                nextGroupStart = end->next;

                ListNode* temp = start->next;
                reverseLinkedList(start->next, end);
                start->next = end;
                temp->next = nextGroupStart;
                start = temp;
                end = start;

                count = 0;
            } 
        }

        ListNode* ans = dummy->next; 
        delete dummy;
        return ans;
    }
private:
    void reverseLinkedList(ListNode* start, ListNode* end){
        if(start == end) return;
        ListNode *prev, *cur, *next;
        prev = start, cur = start->next, next = cur->next;
        start->next = nullptr;
        while(cur != end){
            cur->next = prev;
            prev = cur;
            cur = next;
            next = cur->next;
        }
        cur->next = prev;
    }
````

[灵神题解](https://leetcode.cn/problems/reverse-nodes-in-k-group/solutions/1992228/you-xie-cuo-liao-yi-ge-shi-pin-jiang-tou-plfs)，灵神的题解依旧简洁有力，很值得学习如何简化自己的代码
