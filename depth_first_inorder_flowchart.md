# Binary Search Tree - Depth First Inorder Execution Flowchart

```mermaid
flowchart TD
    Start([Start: depth_first_inorder/1]) --> CheckNode{Is node nil?}
    
    CheckNode -->|Yes| ReturnEmpty[Return empty list: []]
    CheckNode -->|No| ExtractValue[Extract: value, left, right from Node]
    
    ExtractValue --> RecurseLeft[Recursively call depth_first_inorder/1 on left child]
    
    RecurseLeft --> LeftCheck{Is left child nil?}
    LeftCheck -->|Yes| LeftEmpty[Left returns: []]
    LeftCheck -->|No| LeftProcess[Left subtree processing...]
    
    LeftEmpty --> ProcessValue[Process current value]
    LeftProcess --> LeftResult[Left returns: list of values]
    LeftResult --> ProcessValue
    
    ProcessValue --> RecurseRight[Recursively call depth_first_inorder/1 on right child]
    
    RecurseRight --> RightCheck{Is right child nil?}
    RightCheck -->|Yes| RightEmpty[Right returns: []]
    RightCheck -->|No| RightProcess[Right subtree processing...]
    
    RightEmpty --> CombineResults[Combine: left_result ++ [value] ++ right_result]
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
    classDef inorderSpecific fill:#f3e5f5
    
    class Start,End startEnd
    class CheckNode,LeftCheck,RightCheck decision
    class ExtractValue,ProcessValue,CombineResults,ReturnResult,ReturnEmpty inorderSpecific
    class RecurseLeft,RecurseRight,LeftProcess,RightProcess recursion
```

## Execution Pattern

The `depth_first_inorder` function follows this pattern:

1. **Base Case**: If the node is `nil`, return an empty list `[]`
2. **Recursive Case**: For a valid node:
   - Extract the current node's `value`, `left` child, and `right` child
   - **First**: Recursively process the left subtree
   - **Second**: Process the current value (this is what makes it "inorder")
   - **Third**: Recursively process the right subtree
   - Combine results: `left_result ++ [value] ++ right_result`

## Order of Execution

**Inorder traversal visits nodes in this order:**
1. **Left** subtree (recursively)
2. **Root** (current node)
3. **Right** subtree (recursively)

This means for a tree like:
```
    5
   / \
  3   7
 / \   \
1   4   9
```

The inorder traversal would visit: `[1, 3, 4, 5, 7, 9]`

## Key Characteristics

- **Depth-First**: Goes as deep as possible before backtracking
- **Inorder**: Processes the root between its children (left → root → right)
- **Sorted Output**: For a BST, inorder traversal produces values in sorted ascending order
- **Recursive**: Uses function call stack for traversal
- **Memory**: O(h) where h is the height of the tree (due to recursion stack)
- **Time**: O(n) where n is the number of nodes

## Why Inorder is Special for BST

In a Binary Search Tree, the **inorder traversal is particularly important** because:
- It visits nodes in **sorted ascending order**
- Left subtree contains values ≤ current node
- Right subtree contains values ≥ current node
- This property makes inorder traversal perfect for getting sorted data from a BST

## Comparison with Preorder

| Aspect | Preorder | Inorder |
|--------|----------|---------|
| **Order** | Root → Left → Right | Left → Root → Right |
| **When Root Processed** | First | Middle |
| **BST Output** | Tree structure order | Sorted ascending order |
| **Use Case** | Tree copying, prefix expressions | Sorted retrieval, validation | 