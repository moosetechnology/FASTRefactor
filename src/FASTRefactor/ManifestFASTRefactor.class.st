"
This package provides classes and utilities for performing refactoring operations on the Abstract Syntax Tree (AST) models in the Famix AST (FAST) framework.
"
Class {
	#name : #ManifestFASTRefactor,
	#superclass : #PackageManifest,
	#category : #'FASTRefactor-Manifest'
}

{ #category : #'code-critics' }
ManifestFASTRefactor class >> ruleBadMessageRule2V1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#FASTRefactor)) #'2023-06-26T00:00:00.0+02:00') )
]

{ #category : #'code-critics' }
ManifestFASTRefactor class >> ruleTempsReadBeforeWrittenRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#FASTRefactor)) #'2023-06-26T00:00:00.0+02:00') )
]
