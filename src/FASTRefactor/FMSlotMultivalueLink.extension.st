Extension { #name : #FMSlotMultivalueLink }

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> add: newEntity after: entity [

	slot add: newEntity to: owner.
	super add: newEntity after: entity
]

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> add: newEntity before: entity [

	slot add: newEntity to: owner.
	super add: newEntity before: entity
]

{ #category : #'*FASTRefactor' }
FMSlotMultivalueLink >> replace: oldEntity with: newEntity [

	slot remove: oldEntity from: owner.
	slot add: newEntity to: owner.
	self at: (self indexOf: oldEntity) put: newEntity
]
