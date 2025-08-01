# Binary Search Tree - Depth First Preorder Execution Flowchart

```mermaid
flowchart TD
    Start([Start: depth_first_preorder/1]) --> CheckNode{Is node nil?}
    
    CheckNode -->|Yes| ReturnEmpty[Return empty list: []]
    CheckNode -->|No| ExtractValue[Extract: value, left, right from Node]
    
    ExtractValue --> ProcessValue[Process current value]
    ProcessValue --> RecurseLeft[Recursively call depth_first_preorder/1 on left child]
    
    RecurseLeft --> LeftCheck{Is left child nil?}
    LeftCheck -->|Yes| LeftEmpty[Left returns: []]
    LeftCheck -->|No| LeftProcess[Left subtree processing...]
    
    LeftEmpty --> RecurseRight[Recursively call depth_first_preorder/1 on right child]
    LeftProcess --> LeftResult[Left returns: list of values]
    LeftResult --> RecurseRight
    
    RecurseRight --> RightCheck{Is right child nil?}
    RightCheck -->|Yes| RightEmpty[Right returns: []]
    RightCheck -->|No| RightProcess[Right subtree processing...]
    
    RightEmpty --> CombineResults[Combine: [value] ++ left_result ++ right_result]
    RightProcess --> RightResult[Right returns: list of values]
    RightResult --> CombineResults
    
    CombineResults --> ReturnResult[Return combined list]
    ReturnResult --> End([End])
    
    ReturnEmpty --> End
    
    %% Styling
    classDef startEnd fill:#e1f5fe
    classDef decision fill:#fff3e0
    classDef process fill:#e8f5e8
    classDef recursion fill:#fce4ec
    
    class Start,End startEnd
    class CheckNode,LeftCheck,RightCheck decision
    class ExtractValue,ProcessValue,CombineResults,ReturnResult,ReturnEmpty process
    class RecurseLeft,RecurseRight,LeftProcess,RightProcess recursion
```

## Execution Pattern

The `depth_first_preorder` function follows this pattern:

1. **Base Case**: If the node is `nil`, return an empty list `[]`
2. **Recursive Case**: For a valid node:
   - Extract the current node's `value`, `left` child, and `right` child
   - Process the current value first (this is what makes it "preorder")
   - Recursively process the left subtree
   - Recursively process the right subtree
   - Combine results: `[value] ++ left_result ++ right_result`

## Order of Execution

**Preorder traversal visits nodes in this order:**
1. **Root** (current node)
2. **Left** subtree (recursively)
3. **Right** subtree (recursively)

This means for a tree like:
```
    5
   / \
  3   7
 / \   \
1   4   9
```

The preorder traversal would visit: `[5, 3, 1, 4, 7, 9]`

## Key Characteristics

- **Depth-First**: Goes as deep as possible before backtracking
- **Preorder**: Processes the root before its children
- **Recursive**: Uses function call stack for traversal
- **Memory**: O(h) where h is the height of the tree (due to recursion stack)
- **Time**: O(n) where n is the number of nodes 