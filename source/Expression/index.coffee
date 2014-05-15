Pos = require '../compile-help/Pos'
{ type, typeEach } = require '../help/check'
Call = require './Call'
Expression = require './Expression'
Member = require './Member'
JS = require './JS'

module.exports =
	AssignSingle: require './AssignSingle'
	AssignDestructure: require './AssignDestructure'
	Block: require './Block'
	BlockBody: require './BlockBody'
	BlockWrap: require './BlockWrap'
	Call: Call
	Case: require './Case'
	CasePart: require './CasePart'
	CaseTest: require './CaseTest'
	Context: require './Context'
	Expression: Expression
	Fun: require './Fun'
	Member: Member
	JS: JS
	ListElement: require './ListElement'
	Literal: require './Literal'
	Local: require './Local'
	Quote: require './Quote'
	Require: require './Require'
	This: require './This'
	Type: require './Type'
	TypedVariable: require './TypedVariable'

	null: (pos) ->
		new JS pos, 'null'

	sub: (pos, expr, subbed) ->
		type pos, Pos, expr, Expression
		typeEach subbed, Expression
		subMethod = new Member pos, expr, 'sub'
		new Call subMethod, subbed

	true: (pos) ->
		type pos, Pos
		new JS pos, 'true'
