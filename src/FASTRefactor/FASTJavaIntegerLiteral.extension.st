Extension { #name : #FASTJavaIntegerLiteral }

{ #category : #'*FASTRefactor' }
FASTJavaIntegerLiteral >> isDefaultValue [

	^ primitiveValue asNumber isZero
]
