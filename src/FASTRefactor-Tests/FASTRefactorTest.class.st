"
A FASTRefactorTest is a test class for testing the behavior of FASTRefactor
"
Class {
	#name : #FASTRefactorTest,
	#superclass : #TestCase,
	#instVars : [
		'literal',
		'varDecl',
		'varDeclStatement',
		'method',
		'model',
		'refactor',
		'varExpr',
		'invocation'
	],
	#category : #'FASTRefactor-Tests'
}

{ #category : #running }
FASTRefactorTest >> setUp [

	super setUp.
	refactor := FASTRefactor on: (model := FASTJavaModel new).

	"void f() { int var = 42; g(var, null); }"
	literal := model newIntegerLiteral.
	varDecl := model newVariableDeclarator expression: literal.
	varDeclStatement := model newVarDeclStatement declarators:
		                    { varDecl }.
	varExpr := model newVariableExpression.
	invocation := model newMethodInvocation arguments: { 
			              varExpr.
			              model newNullLiteral }.
	method := model newMethodEntity statementBlock:
		          (model newStatementBlock statements: { 
				           varDeclStatement.
				           (model newExpressionStatement expression: invocation) })
]

{ #category : #tests }
FASTRefactorTest >> testAddAfter [

	| newNode |
	newNode := model newNullLiteral.

	refactor add: newNode after: varExpr.
	self assert: (model includes: newNode).
	self assert: newNode argumentOwner equals: invocation.
	self assert: (invocation arguments at: 2) equals: newNode.
	self assert: (invocation arguments at: 1) equals: varExpr.
	self assert: invocation arguments size equals: 3
]

{ #category : #tests }
FASTRefactorTest >> testAddBefore [

	| newNode |
	newNode := model newNullLiteral.

	refactor add: newNode before: varExpr.
	self assert: (model includes: newNode).
	self assert: newNode argumentOwner equals: invocation.
	self assert: (invocation arguments at: 1) equals: newNode.
	self assert: (invocation arguments at: 2) equals: varExpr.
	self assert: invocation arguments size equals: 3
]

{ #category : #tests }
FASTRefactorTest >> testRemoveNode [

	"Once a node is removed, verify that:
	- model does not include it anymore
	- only one node is removed from the model
	- node is cut off from all relations"

	| size |
	size := model size.

	"Can remove entity in a univalued slot"
	refactor removeNode: literal.
	self deny: (model includes: literal).
	self assert: model size equals: size - 1.
	self assert:
		((literal allDeclaredProperties select: #hasOpposite) allSatisfy: [ 
			 :relation | 
			 (literal perform: relation implementingSelector) isEmptyOrNil ]).

	"Can remove entity in a multivalued slot"
	refactor removeNode: varExpr.
	self deny: (model includes: varExpr).
	self assert: model size equals: size - 2.
	self assert:
		((varExpr allDeclaredProperties select: #hasOpposite) allSatisfy: [ 
			 :relation | 
			 (varExpr perform: relation implementingSelector) isEmptyOrNil ])
]

{ #category : #tests }
FASTRefactorTest >> testRemoveTree [

	refactor removeTree: method.
	self assert: model isEmpty
]

{ #category : #tests }
FASTRefactorTest >> testReplaceWith [

	| newNode |
	newNode := model newNullLiteral.

	"Can replace entity in a univalued slot"
	refactor replace: literal with: newNode.
	self assert: varDecl expression equals: newNode.
	self deny: (model includes: literal).

	"Can replace entity in a multivalued slot"
	refactor replace: varExpr with: newNode.
	self assert: invocation arguments first equals: newNode.
	self deny: (model includes: varExpr)
]
