package as3.scope
{
	/**
	 * This internal utility parses values at configuration time,
	 * and can automatically generate Provider Functions when class
	 * and injection information is detected in those values.
	 *
	 * If the given value is a Function reference it is returned as-is.
	 *
	 * If the config is null, the identity itself is inspected.
	 */
	internal final class ConfigParser
	{
		private var scope:Scope;

		public function ConfigParser(scope:Scope) { this.scope = scope; }

		public function getProvider(id:Object, config:Object = null):Object
		{
			// Allow shorthand, e.g. id is a Class with annotations
			if (config === null) config = id;

			// Start with the config itself
			var provider:* = config;

			// Return function provider
			if (provider is Function) return provider;

			// Return instance generating provider
			const cls:Class = getClass(id, config);
			if (cls != null) return getInstanceProviderFor(cls, id, config) as Function;

			// Return plain value provider
			return provider;
		}

		private static function getClass(id:Object, config:Object):Class
		{
			if ('$class' in config) return config['$class'] as Class;
			if (config == null) return id as Class;
			return config as Class;
		}

		private static function isSingleton(config:Object):Boolean
		{
			return '$cache' in config ? config['$cache'] : true;
		}

		private function getInstanceProviderFor(cls:Class, id:Object, config:Object):Function
		{
			const provider:Function = generateConstructor(cls, config);
			return isSingleton(config) ? cacheProvider(id, provider) : provider;
		}

		private function generateConstructor(cls:Class, config:Object):Function
		{
			const injectConfig:* = '$inject' in config ? config['$inject'] : null;

			if (injectConfig is Function)
			{
				// Generated Provider 1: Custom Constructor Function
				return injectConfig as Function;
			}
			else if (injectConfig is Array)
			{
				// Generated Provider 2: Constructor Injection
				return function ():* { return construct(cls, inject(injectConfig, [])) };
			}
			else if (injectConfig is Object)
			{
				// Generated Provider 3: Simple Constructor, Setter Injection
				return function ():* { return inject(injectConfig, new cls()) };
			}

			// Generated Provider 3: Simple Constructor, No Injection
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
				target[key] = '$value' in id ? id['$value'] : scope.getValue(id);
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
