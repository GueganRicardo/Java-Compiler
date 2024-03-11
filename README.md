# Java-Compiler
## Project Overview
This project is a compiler for Juc, a simplified version of java, the diferent pahses we did are: syntactic analysis, construction of the Abstract Syntax Tree (AST) and semantic analysis.

### Syntactic Analysis
We began by declaring possible tokens from lexical analysis and copying the provided Juc grammar into our `jucompiler.y` file. We created auxiliary productions to handle optional or recursively optional parts and resolved conflicts before proceeding.

### AST Implementation
For the AST implementation, we designed a general "node" struct to accommodate all node types. We created helper functions like `create_new_node`, `add_new`, and `add_son` to associate each grammar production.

### Semantic Analysis
We constructed symbol tables by analyzing the AST to identify variable or method declarations. The process involved two traversals of the AST: one for global variables and methods, and another for local variables within methods.

### Error Detection and AST Annotation
Error detection and AST annotation occurred during the second traversal. We annotated specific nodes based on their children's types and raised errors if the conditions were not met.
