Extension { #name : 'FMSlotMultivalueLink' }

{ #category : '*FASTRefactor' }
FMSlotMultivalueLink >> insert: anElement before: spot [
	"Enables #add:after:, #add:before:, #add:beforeIndex: and #add:afterIndex:"

	slot add: anElement to: owner.
	(self includes: anElement) ifFalse: [
		super insert: anElement before: spot ].
	^ anElement
]

{ #category : '*FASTRefactor' }
FMSlotMultivalueLink >> replace: oldEntity with: newEntity [

	slot remove: oldEntity from: owner.
	slot add: newEntity to: owner.
	self at: (self indexOf: oldEntity) put: newEntity
]
