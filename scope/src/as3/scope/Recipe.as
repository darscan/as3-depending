package as3.scope
{
	/**
	 * This internal utility parses values at configuration time,
	 * and can automatically generate Provider Functions when class
	 * and injection information is detected in those values.
	 *
	 * If the given value is a Function reference it is returned as-is.
	 *
	 * If the value is null, the identity itself is inspected.
	 */
	internal final class Recipe
	{
		private var scope:Scope;

		public function Recipe(scope:Scope)
		{
			this.scope = scope;
		}

		public function parse(id:Object, recipe:Object):*
		{
			// allow shorthand, e.g. id is a class with annotations
			if (recipe === null) recipe = id;

			// start with the recipe
			var provider:* = recipe;

			// the simplest provider is a function reference
			if (provider is Function) return provider;

			// or, try to build a provider by reading the recipe
			// for class and dependency annotations
			const cls:Class = getClass(id, recipe);
			if (cls != null) return getClassProvider(cls, id, recipe) as Function;

			// the provider can also be a plain value object
			return provider;
		}

		private static function getClass(id:Object, recipe:Object):Class
		{
			if ('$class' in recipe) return recipe['$class'] as Class;
			if (recipe == null) return id as Class;
			return recipe as Class;
		}

		private function getClassProvider(cls:Class, id:Object, recipe:Object):Function
		{
			const provider:Function = createClassProvider(cls, recipe);
			return isSingleton(recipe) ? cacheProvider(id, provider) : provider;
		}

		private static function isSingleton(recipe:Object):Boolean
		{
			return '$cache' in recipe ? recipe['$cache'] : true;
		}

		private function createClassProvider(cls:Class, recipe:Object):Function
		{
			const injRecipe:* = '$inject' in recipe ? recipe['$inject'] : null;

			if (injRecipe is Function)
			{
				// custom constructor
				return injRecipe as Function;
			}
			else if (injRecipe is Array)
			{
				// constructor injection
				return function ():* { return construct(cls, inject(injRecipe, [])) };
			}
			else if (injRecipe is Object)
			{
				// simple constructor with setter injection
				return function ():* { return inject(injRecipe, new cls()) };
			}

			// simple constructor
			return function ():* { return new cls() };
		}

		private function cacheProvider(id:Object, provider:Function):Function
		{
			// Replace the provider with its own result after invoking it
			// Defined twice to allow resolver argument scanning
			if (provider.length == 1)
				return function (a:*):* { return scope.setProvider(id, provider(a)) };

			return function ():* { return scope.setProvider(id, provider()) };
		}

		private function inject(ids:Object, target:Object):*
		{
			// object to object, or array to array
			for (var key:String in ids)
			{
				const id:Object = ids[key];
				target[key] = 'val' in id ? id['val'] : scope.getValue(id);
			}
			return target;
		}

		private static function construct(cls:Class, p:Array):*
		{
			var obj:Object;
			switch (p.length)
			{
				case 1 :
					obj = new cls(p[0]);
					break;
				case 2 :
					obj = new cls(p[0], p[1]);
					break;
				case 3 :
					obj = new cls(p[0], p[1], p[2]);
					break;
				case 4 :
					obj = new cls(p[0], p[1], p[2], p[3]);
					break;
				case 5 :
					obj = new cls(p[0], p[1], p[2], p[3], p[4]);
					break;
				case 6 :
					obj = new cls(p[0], p[1], p[2], p[3], p[4], p[5]);
					break;
				case 7 :
					obj = new cls(p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
					break;
				case 8 :
					obj = new cls(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
					break;
				case 9 :
					obj = new cls(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]);
					break;
				case 10 :
					obj = new cls(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]);
					break;
				default:
					throw new Error("The constructor for " + cls + " has too many arguments, maximum is 10");
			}
			return obj;
		}
	}
}
