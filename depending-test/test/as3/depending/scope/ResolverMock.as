package as3.depending.scope {
import as3.depending.Resolver;

public class ResolverMock implements Resolver {

    public function getByType(clazz:Class, required:Boolean = true):* {
        return undefined;
    }
}
}
