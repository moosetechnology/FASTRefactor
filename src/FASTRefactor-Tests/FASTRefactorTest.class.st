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
FASTRefactorTest >> testRemoveNode [

	| size |
	size := model size.

	"Can remove entity in a univalued slot"
	refactor removeNode: literal.
	self deny: (model includes: literal).
	self assert: model size equals: size - 1.

	"Can remove entity in a multivalued slot"
	refactor removeNode: varExpr.
	self deny: (model includes: varExpr).
	self assert: model size equals: size - 2
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
