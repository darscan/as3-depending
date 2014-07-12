package as3.scope
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	import org.hamcrest.object.instanceOf;

	public class ScopeTest
	{
		private var scope:Scope;

		[Before]
		public function before():void
		{
			scope = new Scope();
		}

		/**
		 * A provider must be supplied for a given identity.
		 */

		[Test(expects="Error")]
		public function unregisteredProvider_throws_Error():void
		{
			scope.getValue("missing");
		}

		/**
		 * A Provider can be a direct Value.
		 */

		[Test]
		public function stringId_to_Value_returns_Value():void
		{
			scope.register("id", 5);
			assertThat(scope.getValue("id"), equalTo(5));
		}

		[Test]
		public function anyId_to_Value_returns_Value():void
		{
			scope.register(Number, 5);
			assertThat(scope.getValue(Number), equalTo(5));
		}

		/**
		 * A Provider can be a Class reference.
		 */

		[Test]
		public function id_to_ClassValue_returns_Instance_of_Class():void
		{
			scope.register("id", Sprite);
			assertThat(scope.getValue("id"), instanceOf(Sprite));
		}

		[Test]
		public function anyId_to_ClassValue_returns_Instance_of_Class():void
		{
			scope.register(DisplayObject, Sprite);
			assertThat(scope.getValue(DisplayObject), instanceOf(Sprite));
		}

		/**
		 * Singleton behaviour by default for constructed Class.
		 */

		[Test]
		public function id_for_ClassValue_returns_same_Instance_of_Class():void
		{
			scope.register(DisplayObject, Sprite);
			const instance1:DisplayObject = scope.getValue(DisplayObject);
			const instance2:DisplayObject = scope.getValue(DisplayObject);
			assertThat(instance1, equalTo(instance2));
		}

		/**
		 * An Identity can be used as a Provider when the Provider is omitted
		 * and the Identity is a constructable Class.
		 */

		[Test]
		public function classId_without_Value_returns_Instance_of_Class():void
		{
			scope.register(Sprite);
			assertThat(scope.getValue(Sprite), instanceOf(Sprite));
		}

		[Test]
		public function id_without_Value_returns_Id():void
		{
			scope.register("id");
			assertThat(scope.getValue("id"), equalTo("id"));
		}

		/**
		 * An Identity can not be used as a Provider if it is not constructable.
		 */

		[Test(expects="Error")]
		public function nonConstructableId_without_Value_throws_Error():void
		{
			scope.register(DisplayObject);
			scope.getValue(DisplayObject);
		}

		[Test(expects="Error")]
		public function interfaceId_without_Value_throws_Error():void
		{
			scope.register(IVehicle);
			scope.getValue(IVehicle);
		}

		/**
		 * A Provider can be a Function reference, and can optionally
		 * accept a Resolver function.
		 */

		[Test]
		public function providerFunction_returns_FunctionValue():void
		{
			scope.register(DisplayObject, function ():* { return new Sprite() });
			assertThat(scope.getValue(DisplayObject), instanceOf(Sprite));
		}

		[Test]
		public function providerFunction_accepts_Resolver():void
		{
			scope.register("name", "Foo");
			scope.register("id", function (resolve:Function):Object
			{
				return { nameProperty: resolve("name") };
			});
			assertThat(scope.getValue("id"), hasProperty("nameProperty", "Foo"));
		}

		/**
		 * A Provider can be automatically generated when construction information supplied.
		 */

		[Test]
		public function provider_is_generated_using_supplied_construction_info():void
		{
			scope.register(IVehicle, { $class: Car });
			assertThat(scope.getValue(IVehicle), instanceOf(Car));
		}

		[Test]
		public function provider_is_generated_with_supplied_constructorInjection_info():void
		{
			scope.register("name", "Foo");
			scope.register(IVehicle, {
				$class: Car,
				$inject: ["name"]
			});
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}

		[Test]
		public function constructorInjectionProvider_needs_explicit_indicator_for_direct_values():void
		{
			scope.register(IVehicle, {
				$class: Car,
				$inject: [
					{ val: "Foo" }
				]
			});
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}

		[Test]
		public function provider_is_generated_with_supplied_propertyInjection_info():void
		{
			scope.register("name", "Foo");
			scope.register(IVehicle, {
				$class: Car,
				$inject: { name: "name" }
			});
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}

		[Test]
		public function propertyInjectionProvider_needs_explicit_indicator_for_direct_values():void
		{
			scope.register(IVehicle, {
				$class: Car,
				$inject: { name: { val: "Foo" } }
			});
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}

		/**
		 * A Provider can be automatically detected ot generated when
		 * construction information is found on a concrete class.
		 */

		[Test]
		public function providerFunction_declared_as_INLINE_annotation_is_used():void
		{
			scope.register("name", "Foo");
			scope.register(IVehicle, SelfConstructingCar);
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}

		[Test]
		public function provider_is_generated_using_INLINE_constructorInjection_annotation():void
		{
			scope.register("name", "Foo");
			scope.register(IVehicle, AutoConstructorInjectingCar);
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}

		[Test]
		public function provider_is_generated_with_INLINE_propertyInjection_info():void
		{
			scope.register("name", "Foo");
			scope.register(IVehicle, AutoSetterCar);
			assertThat(scope.getValue(IVehicle), hasProperty("name", "Foo"));
		}
	}
}

interface IVehicle
{
}

/**
 * Sample Vehicle
 */
class Car implements IVehicle
{
	public var name:String;

	public function Car(name:String = null)
	{
		this.name = name;
	}
}

/**
 * This class declares its own Provider function, and will build itself.
 *
 * The annotation must be declared at the Class level (static).
 */
class SelfConstructingCar extends Car
{
	public static function $inject(resolve:Function):SelfConstructingCar
	{
		return new SelfConstructingCar(resolve('name'));
	}

	public function SelfConstructingCar(name:String)
	{
		super(name);
	}
}

/**
 * This class declares its constructor argument dependencies, and can be built automatically.
 *
 * The annotation must be declared at the Class level (static).
 */
class AutoConstructorInjectingCar extends Car
{
	public static const $inject:Array = ['name'];

	public function AutoConstructorInjectingCar(name:String)
	{
		super(name);
	}
}

/**
 * This class declares dependencies that should be injected as properties after construction.
 *
 * The annotation must be declared at the Class level (static).
 */
class AutoSetterCar extends Car
{
	public static const $inject:Object = { name: 'name' };
}
