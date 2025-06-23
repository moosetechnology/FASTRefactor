Extension { #name : 'FASTJavaFloatLiteral' }

{ #category : '*FASTRefactor' }
FASTJavaFloatLiteral >> isDefaultValue [

	^ primitiveValue asNumber isZero
]
