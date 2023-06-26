"
I perform refactoring operations on a FAST model.

### Low-Level AST Manipulation
- `replace: aNode with: anotherNode`: Replace an AST node with another in the same location.
- `removeNode: aNode`: Completely remove an entity from its model and relations.
- `removeTree: aNode`: Recursively remove a node and all its children from the model.

### High-Level AST Transformation
- `inlineLiterals`: Inline all variables holding literal values in the model.

FASTRefactor is based on the FAST metamodel, which is optimized for AST representations rather than manipulations, resulting in slower operations.
Optimization is prioritized over syntactic sugar to improve performance.
"
Class {
	#name : #FASTRefactor,
	#superclass : #Object,
	#instVars : [
		'model',
		'propertyCache'
	],
	#category : #FASTRefactor
}

{ #category : #'instance creation' }
FASTRefactor class >> on: aFASTModel [

	^ self new model: aFASTModel
]

{ #category : #initialization }
FASTRefactor >> initialize [

	propertyCache := Dictionary new
]

{ #category : #'ast transformation' }
FASTRefactor >> inlineLiterals [

	"Inline all variables holding literal values in the model."

	(model allUsing: FASTTBehaviouralEntity) do: [ :entity | 
		self inlineLiteralsIn: entity ]
]

{ #category : #'ast transformation' }
FASTRefactor >> inlineLiteralsIn: aFASTTBehaviouralEntity [

	"Replace variables initialized with a literal with the latter.
	Java example: `int i = 0; f(i);` -> `f(0);`"

	self subclassResponsibility
]

{ #category : #accessing }
FASTRefactor >> model [

	^ model
]

{ #category : #accessing }
FASTRefactor >> model: aFASTModel [

	model := aFASTModel
]

{ #category : #caching }
FASTRefactor >> propertiesOf: aNode [

	^ propertyCache
		  at: aNode class
		  ifAbsentPut: [ aNode allDeclaredPropertiesIn: aNode metamodel ]
]

{ #category : #'ast manipulation' }
FASTRefactor >> removeNode: aNode [

	"Completely remove an entity from its model and relations."

	(self propertiesOf: aNode)
		select: [ :relation | relation hasOpposite ]
		thenDo: [ :relation | 
			(aNode perform: relation implementingSelector) ifNotNil: [ 
				aNode
					perform: relation implementingSelector asMutator
					with: (relation isMultivalued
							 ifTrue: [ #(  ) ]
							 ifFalse: [ nil ]) ] ].
	model ifNotNil: [ model remove: aNode ]
]

{ #category : #'ast manipulation' }
FASTRefactor >> removeTree: aNode [

	"Recursively remove a node and all its children from the model."

	(self propertiesOf: aNode)
		select: [ :relation | relation isChildrenProperty ]
		thenDo: [ :relation | 
			(aNode perform: relation implementingSelector) ifNotNil: [ :child | 
				child isCollection
					ifTrue: [ 
						child ifNotEmpty: [ "make an array copy to remove elements during iteration" 
							child asArray do: [ :node | self removeTree: node ] ] ]
					ifFalse: [ self removeTree: child ] ] ].
	self removeNode: aNode
]

{ #category : #'ast manipulation' }
FASTRefactor >> replace: aNode with: anotherNode [

	"Replace an AST node with another in the same location."

	(self propertiesOf: aNode)
		select: [ :relation | relation isContainer ]
		thenDo: [ :relation | 
			(aNode perform: relation implementingSelector) ifNotNil: [ :parent | 
				relation opposite isMultivalued
					ifTrue: [ 
						(parent perform: relation opposite implementingSelector)
							replace: aNode
							with: anotherNode ]
					ifFalse: [ 
						aNode perform: relation implementingSelector asMutator with: nil.
						parent
							perform: relation opposite implementingSelector asMutator
							with: anotherNode ] ] ].
	self removeNode: aNode
]
