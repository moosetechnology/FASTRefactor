Extension { #name : #FMSlotMultivalueLink }

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> add: newEntity after: entity [

	slot add: newEntity to: owner.
	values add: newEntity after: entity
]

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> add: newEntity before: entity [

	slot add: newEntity to: owner.
	values add: newEntity before: entity
]

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> replace: anEntity with: anotherEntity [

	slot remove: anEntity from: owner.
	values at: (values indexOf: anEntity) put: anotherEntity
]
