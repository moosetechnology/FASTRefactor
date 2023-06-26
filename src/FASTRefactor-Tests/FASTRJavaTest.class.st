"
A FASTRJavaTest is a test class for testing the behavior of FASTRJava
"
Class {
	#name : #FASTRJavaTest,
	#superclass : #FASTRefactorTest,
	#category : #'FASTRefactor-Tests'
}

{ #category : #running }
FASTRJavaTest >> setUp [

	super setUp.
	refactor := FASTRJava new model: model.

	varDecl variable: (model newVariableExpression name: 'foo').
	varExpr name: 'foo'
]

{ #category : #tests }
FASTRJavaTest >> testInlineLiteralsIn [

	refactor inlineLiteralsIn: method.
	self assert: invocation arguments first isLiteral.
	self denyCollection: model includesAny: { 
			varDeclStatement.
			varDecl }
]
