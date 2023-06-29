Extension { #name : #FASTJavaDoubleLiteral }

{ #category : #'*FASTRefactor' }
FASTJavaDoubleLiteral >> isDefaultValue [

	^ primitiveValue asNumber isZero
]
