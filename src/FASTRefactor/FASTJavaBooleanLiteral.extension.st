Extension { #name : 'FASTJavaBooleanLiteral' }

{ #category : '*FASTRefactor' }
FASTJavaBooleanLiteral >> isDefaultValue [

	^ primitiveValue = 'false'
]
