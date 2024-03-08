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
			(expr := decl expression) isNotNil and: [
				expr isLiteral or: [ "or with a class property (enum or static field)"
					expr class == FASTJavaClassProperty ] ] ]
		thenDo: [ :decl |
			| variable name |
			name := (variable := decl variable) name.
			varExprs
				select: [ :var | var ~~ variable and: [ var name = name ] ]
				thenDo: [ :var | self replace: var with: (self copyTree: expr) ].
			self removeVariableDeclaration: decl ]
]

{ #category : #testing }
FASTRJava >> isRedundantSetter: invoc [
	"Objects such as Integer, Long, Float, etc. can be initialized with a literal, but their default value is null."

	^ (super isRedundantSetter: invoc) and: [
		  invoc arguments first isNullLiteral or: [
			  invoc famixMethod parameters first declaredType isPrimitiveType ] ]
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
