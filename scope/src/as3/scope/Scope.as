package as3.scope
{
	public final class Scope
	{
		public var parent:Scope;

		/**
		 * Registers a provider for a given identity.
		 *
		 * If the provider is a Function reference it is used to provide values.
		 *
		 * Otherwise, a provider for the identity is automatically generated.
		 *
		 * @param id Identity
		 * @param provider Provider Function, Value or Configuration
		 */
		public function register(id:Object, provider:Object = null):void
		{
			setProvider(id, extractProvider(id, provider));
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

		private var recipeParser:Recipe;

		protected function extractProvider(id:Object, recipe:Object):Object
		{
			if (recipeParser == null) recipeParser = new Recipe(this);
			return recipeParser.parse(id, recipe);
		}
	}
}
