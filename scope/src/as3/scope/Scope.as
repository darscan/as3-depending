package as3.scope
{
	public final class Scope
	{
		public var parent:Scope;

		/**
		 * Registers or creates a provider for a given identity (name or Type).
		 *
		 * If the config is a Function reference it is used to provide values.
		 *
		 * Otherwise, a provider is automatically generated from the config.
		 *
		 * When the config is omitted the `id` itself is treated as the config.
		 *
		 * @param id Identity. String name, or Type (Interface or Class).
		 * @param config Provider Function, Class, Value or Configuration.
		 */
		public function register(id:Object, config:Object = null):void
		{
			setProvider(id, parseConfig(id, config));
		}

		public function unregister(id:Object):void
		{
			delete providers[id];
		}

		public function getValue(id:Object, required:Boolean = true):*
		{
			var p:* = findProvider(id);
			if (p === undefined && required) throw new Error("No provider found for " + id);
			if (p is Function) return p.length == 0 ? p() : p(getValue);
			return p;
		}

		private const providers:Object = {};

		internal function setProvider(id:Object, provider:Object):*
		{
			providers[id] = provider;
			return provider;
		}

		internal function findProvider(id:Object):*
		{
			var p:* = providers[id];
			if (p === undefined && parent) p = parent.findProvider(id);
			return p;
		}

		private var parser:ConfigParser;

		private function parseConfig(id:Object, config:Object):Object
		{
			if (parser == null) parser = new ConfigParser(this);
			return parser.getProvider(id, config);
		}
	}
}
