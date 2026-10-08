---
author: lencelg from Arcadia Bay
---

[TOC]

# notice

representation by Bob Steagall, [video here](https://www.youtube.com/watch?v=tXUXl_RzkAk)

# classic stl

Genric Programming: **Lift algorithms and data structures from concrete examples to their most general and abstract form**

## original design principles

**Comprehensive**
- Take all the best from APL, Lisp, Dylan, C library, USL Standard Components...
- Provide structure and fill the gaps

**Extensible**
- Orthogonality of the component space
- Semantically based interoperability guarantees

**Efficient**
- No penalty for generality
- Complexity guarantees at the interface level

**Natural**
- C/C++ machine model and programming paradigm
- Support for built-in data types

**Key Principles**
- Containers and algorithms are entirely independent
- Iterators provide a common unit of information exchange between containers and algorithms

## container overview

| Category | Container Name | Introduced |
|----------|----------------|------------|
| Sequence | vector | — |
| Sequence | deque | — |
| Sequence | list | — |
| Sequence | array | C++11 |
| Sequence | forward_list | C++11 |
| Unordered associative | unordered_map | C++11 |
| Unordered associative | unordered_set | C++11 |
| Unordered associative | unordered_multimap | C++11 |
| Unordered associative | unordered_multiset | C++11 |
| Container adaptor | queue | — |
| Container adaptor | stack | — |
| Container adaptor | priority_queue | — |

## iterators overview

**interators never own the elements to which they refer**

```
        Input Iterator          Output Iterator
              |                       │
              ............┬───────────┘
                          ▼
                  Forward Iterator
                          │
                          ▼
                Bidirectional Iterator
                          │
                          ▼
                Random Access Iterator
```

| Category | Operation |
|----------|-----------|
| Output | Write forward, single-pass |
| Input | Read forward, single-pass |
| Forward | Access forward, multi-pass |
| Bidirectional | Access forward and backward, multi-pass |
| Random Access | Access arbitrary position, multi-pass |

## algorithms overview

Algorithm categories

- Non-modifying algorithms
- Modifying algorithms
- Removing algorithms
- Mutating algorithms
- Sorting algorithms
- Sorted range algorithms
- Numeric algorithms

## iterator ranges

In the STL, iteration over sequences is based on the idea of *iterator ranges*

An iterator range is represented by a pair of iterators -- [first, last)

- This pair represents a *half-open interval* over the sequence of elements
- first refers to the first element **included** in the sequence
- last refers to the non-dereferenceable, "one-past-the-end" (PTE) position **excluded** from the sequence

Q: Why use ranges described by half-open intervals?

A: It makes testing for loop termination very simple

- Loops only need to test for iterator equality
- Indexing not required
- Location in memory is irrelevant

![](/img/sential_node.png)

## algorithms

**lower_bound**

- **Action**: Returns an iterator pointing to the first element in the range [first, last) that is not less than (i.e., greater than or equal to) value, or last if no such element is found

- **Complexity**: the number of comparisons performed is logarithmic in the distance between first and last (at most \( \log 2(\text{last} - \text{first}) + O(1) \) comparisons)

**For non-random-access iterators, the number of iterator increments is linear**

```cpp
  template<class ForwardIter, class T>
  ForwardIt
  lower_bound(ForwardIter first, ForwardIter last, const T& value);
```
## other

no more note for containers' detailed template information and usage
