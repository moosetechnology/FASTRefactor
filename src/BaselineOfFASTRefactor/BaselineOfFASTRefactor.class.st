Class {
	#name : #BaselineOfFASTRefactor,
	#superclass : #BaselineOf,
	#category : #BaselineOfFASTRefactor
}

{ #category : #baselines }
BaselineOfFASTRefactor >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self dependencies: spec.
		self packages: spec.
		self groups: spec ]
]

{ #category : #baselines }
BaselineOfFASTRefactor >> dependencies: spec [

	spec baseline: 'FASTJava' with: [ "transitively loads FAST" 
		spec repository: 'github://moosetechnology/FAST-JAVA:v3/src' ]
]

{ #category : #baselines }
BaselineOfFASTRefactor >> groups: spec [

	spec
		group: 'default' with: #( 'core' 'tests' );
		group: 'core' with: #( 'FASTJava' 'FASTRefactor' );
		group: 'tests' with: 'FASTRefactor-Tests'
]

{ #category : #baselines }
BaselineOfFASTRefactor >> packages: spec [

	spec
		package: 'FASTRefactor';
		package: 'FASTRefactor-Tests'
		with: [ spec requires: 'FASTRefactor' ]
]
