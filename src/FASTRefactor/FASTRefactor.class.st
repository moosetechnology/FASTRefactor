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

{ #category : #'ast manipulation' }
FASTRefactor >> add: newNode after: aNode [
	"Add newNode after aNode in the parent container of aNode.
	Fail if aNode is not in a to-many relationship with its parent."

	self parentOf: aNode withRelationDo: [ :parent :relation |
		(parent perform: relation opposite implementingSelector)
			add: newNode
			after: aNode ]
]

{ #category : #'ast manipulation' }
FASTRefactor >> add: newNode before: aNode [
	"Add newNode before aNode in the parent container of aNode.
	Fail if aNode is not in a to-many relationship with its parent."

	self parentOf: aNode withRelationDo: [ :parent :relation |
		(parent perform: relation opposite implementingSelector)
			add: newNode
			before: aNode ]
]

{ #category : #enumerating }
FASTRefactor >> childrenOf: aNode withRelationDo: aBlock [
	"Evaluate a block with each child node and aNode's relation to it as arguments."

	(self propertiesOf: aNode) do: [ :property |
		property isChildrenProperty ifTrue: [
			(aNode perform: property implementingSelector) ifNotNil: [ :child |
				aBlock value: child value: property ] ] ]
]

{ #category : #copying }
FASTRefactor >> copyLeaf: aNode [
	"Return a copy of aNode with a new ID and properly added to its model.
	Do not implement the `postCopy` hook because we are dealing with tree structures, so this is not generalizable to all models in the Famix framework."

	| newNode |
	newNode := self privateCopy: aNode.
	(self propertiesOf: aNode)
		select: [ :property |
		property isDerived not and: [ property opposite isNil ] ]
		thenDo: [ :property |
			(aNode perform: property implementingSelector) ifNotNil: [ :value |
				newNode
					perform: property implementingSelector asMutator
					with: value copy ] ].
	^ newNode
]

{ #category : #copying }
FASTRefactor >> copyTree: aNode [
	"Copy aNode and all its children recursively."

	| newNode |
	newNode := self privateCopy: aNode.
	self childrenOf: aNode withRelationDo: [ :child :relation |
		child isCollection
			ifTrue: [
				child ifNotEmpty: [
					newNode
						perform: relation implementingSelector asMutator
						with: (child collect: [ :node | self copyTree: node ]) ] ]
			ifFalse: [
				newNode
					perform: relation implementingSelector asMutator
					with: (self copyTree: child) ] ].
	^ newNode
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

{ #category : #testing }
FASTRefactor >> isRedundantSetter: invocation [
	"Setting a value which is equals to the default value is redundant."

	| argument |
	^ invocation arguments size = 1 and: [
		  (argument := invocation arguments first) isLiteral and: [
			  argument isDefaultValue and: [ invocation famixMethod isSetter ] ] ]
]

{ #category : #accessing }
FASTRefactor >> model [

	^ model
]

{ #category : #accessing }
FASTRefactor >> model: aFASTModel [

	model := aFASTModel
]

{ #category : #enumerating }
FASTRefactor >> parentNodeOf: aNode [
	"Faster than FASTTEntity>>#parentNode."

	^ self parentOf: aNode withRelationDo: [ :parent :relation | parent ]
]

{ #category : #enumerating }
FASTRefactor >> parentOf: aNode withRelationDo: aBlock [
	"Evaluate a block with the parent node and aNode's relation to it as arguments.
	Stop at first found because there is only one parent in a tree."

	(self propertiesOf: aNode) do: [ :property |
		property isContainer ifTrue: [
			(aNode perform: property implementingSelector) ifNotNil: [ :parent |
				^ aBlock value: parent value: property ] ] ].
	^ nil
]

{ #category : #'private - copying' }
FASTRefactor >> privateCopy: aNode [

	^ aNode class new mooseModel: aNode mooseModel
]

{ #category : #enumerating }
FASTRefactor >> propertiesOf: aNode [
	"Iterate over the properties of aNode in a metamodel-agnostic manner.
	Properties include both direct properties (attributes) and relationships.
	Since this is used often, the result is cached for performance."

	^ propertyCache
		  at: aNode class
		  ifAbsentPut: [ aNode allDeclaredProperties ]
]

{ #category : #'ast manipulation' }
FASTRefactor >> removeNode: aNode [
	"Completely remove a node from its model and relations."

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

{ #category : #'ast transformation' }
FASTRefactor >> removeRedundantSetters [
	"Uninitialized variables have a default value, so it is redundant to use a setter with the default value as an argument.
	To work correctly, the invocations should be bound to the called method in a Famix model."

	(model allUsing: FASTTInvocation)
		select: [ :invoc | self isRedundantSetter: invoc ]
		thenDo: [ :invoc | "Remove the statement containing the setter expression."
			self removeTree: (self parentNodeOf: invoc) ]
]

{ #category : #'ast manipulation' }
FASTRefactor >> removeTree: aNode [
	"Recursively remove a node and all its children from the model."

	self childrenOf: aNode withRelationDo: [ :child :relation |
		child isCollection
			ifTrue: [
				child ifNotEmpty: [ "make an array copy to remove elements during iteration"
					child asArray do: [ :node | self removeTree: node ] ] ]
			ifFalse: [ self removeTree: child ] ].
	self removeNode: aNode
]

{ #category : #'ast manipulation' }
FASTRefactor >> replace: aNode with: newNode [
	"Replace a node with a new one in the same location."

	self parentOf: aNode withRelationDo: [ :parent :relation |
		relation opposite isMultivalued
			ifTrue: [ "replace at same index"
				(parent perform: relation opposite implementingSelector)
					replace: aNode
					with: newNode ]
			ifFalse: [
				aNode perform: relation implementingSelector asMutator with: nil.
				parent
					perform: relation opposite implementingSelector asMutator
					with: newNode ] ].
	self removeTree: aNode
]
