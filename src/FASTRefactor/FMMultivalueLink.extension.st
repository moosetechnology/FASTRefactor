Extension { #name : #FMMultivalueLink }

{ #category : #'*FASTRefactor' }
FMMultivalueLink >> replace: oldEntity with: newEntity [

	| index |
	index := self indexOf: oldEntity.
	oldEntity perform: opposite with: nil.
	newEntity perform: opposite with: owner.
	self add: self removeLast beforeIndex: index
]
