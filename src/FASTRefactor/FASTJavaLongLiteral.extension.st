Extension { #name : 'FASTJavaLongLiteral' }

{ #category : '*FASTRefactor' }
FASTJavaLongLiteral >> isDefaultValue [

	^ primitiveValue asNumber isZero
]
