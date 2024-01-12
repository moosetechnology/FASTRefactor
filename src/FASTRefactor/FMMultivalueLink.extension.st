Extension { #name : #FMMultivalueLink }

{ #category : #'*FASTRefactor' }
FMMultivalueLink >> replace: oldEntity with: newEntity [

	| index |
	index := values indexOf: oldEntity.
	oldEntity perform: opposite with: nil.
	newEntity perform: opposite with: owner.
	values add: values removeLast beforeIndex: index
]
