"
I specialize in refactoring Java-specific AST structures.
"
Class {
	#name : #FASTRJava,
	#superclass : #FASTRefactor,
	#category : #FASTRefactor
}

{ #category : #'ast transformation' }
FASTRJava >> inlineLiteralsIn: aFASTJavaMethodEntity [

	| varExprs expr |
	varExprs := (aFASTJavaMethodEntity toScope: FASTTVariableExpression)
		            asArray.
	(aFASTJavaMethodEntity toScope: FASTJavaVariableDeclarator)
		select: [ :decl | "select vars initialized with a literal" 
			(expr := decl expression) isNotNil and: [ expr isLiteral ] ]
		thenDo: [ :decl | 
			| variable name |
			name := (variable := decl variable) name.
			varExprs
				select: [ :var | var ~= variable and: [ var name = name ] ]
				thenDo: [ :var | self replace: var with: expr copy ].
			self removeVariableDeclaration: decl ]
]

{ #category : #'ast transformation' }
FASTRJava >> removeVariableDeclaration: aFASTJavaVariableDeclarator [

	"Remove a variable declarator from the AST.
	If the containing declaration statement is then empty, it is also removed."

	| aFASTJavaVarDeclStatement |
	aFASTJavaVarDeclStatement := aFASTJavaVariableDeclarator varDeclOwner.
	self removeNode: aFASTJavaVariableDeclarator.
	aFASTJavaVarDeclStatement declarators ifEmpty: [ 
		self removeNode: aFASTJavaVarDeclStatement ]
]
