Extension { #name : #FMSlotMultivalueLink }

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> replace: anEntity with: anotherEntity [

	slot remove: anEntity from: owner.
	values at: (values indexOf: anEntity) put: anotherEntity
]
