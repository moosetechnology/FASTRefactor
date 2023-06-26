# FASTRefactor
Refactoring operations on the Abstract Syntax Tree (AST) models in the [FAST](https://github.com/moosetechnology/FAST) framework.
FASTR includes a low-level API for manipulating AST nodes, and a high-level API for applying transformations to the entire AST model.

## Installation

```st
Metacello new
  githubUser: 'moosetechnology' project: 'FASTRefactor' commitish: 'main' path: 'src';
  baseline: 'FASTRefactor';
  load
```
