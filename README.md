# Functional DI for ActionScript

# "Scope"

A functional DI container.

## Basic Example

	const scope:Scope = new Scope();
	scope.register(User); // configures User singleton
	scope.getValue(User); // creates singleton User instance
	scope.getValue(User); // returns the same User instance

## Features

* Managed singletons
* Scope inheritance
* Inline and external configuration options
* Constructor and property injection
* Flexible construction and injection mechanics

## Feature Examples

	scope.register(IVehicle, Car); // interface singleton
	scope.getValue(IVehicle); // returns a Car instance
	
	const childScope:Scope = new Scope();
	childScope.parent = scope; // sets scope inheritance
	childScope.getValue(IVehicle); // returns inherited engine
	
	childScope.register(IVehicle, Bicycle); // overrides to local singleton
	childScope.getValue(IVehicle); // returns local singleton
	
	childScope.unregister(IVehicle); // unregisters local singleton
	childScope.getValue(IVehicle); // returns inherited engine


# Part II: "Spec"

`Scope` is an implementation that conforms to the following specification.

## Terminology

1. "value" is any legal ActionScript value or reference.
2. "identity" is any legal ActionScript value or reference.
3. "resolver" is any function that takes an `identity` and returns a `value`.
4. "provider" is any `value` or function that returns a `value` when invoked.

## Concepts

The spec defines two concepts:

* Resolver Functions
* Provider Functions and Values

This is enough to build a moderately elaborate DI container.


## Resolvers

A resolver is any function that takes an identity and returns a value:

	function(id:Object):Object {
		// ...
		return object;
	}

A resolver should throw an exception if it can not provide a value for a given identity.

## Providers

A provider can be any legal ActionScript value (including `null` and `undefined`):

	var urlProvider:String = "http://example.com/api"


A provider can be function that returns a value when invoked:

	function():String { return "http://example.com/api" }

A provider can optionally accept a resolver as a parameter:

	function(resolve:Function):Service {
		return new Service(resolve("serviceURL"))
	}

# Quick Footnote: Why DI?

Pilots fly aeroplanes, they don't have to know how to build them.

DI frameworks separate operational concerns from constructional concerns.

DI containers are just object factories.

A good DI container is a flexible and easily configurable object factory.
