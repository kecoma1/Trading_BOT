public class generic_class {
    
    static <T extends Number> Double add(T a, T b) { return a.doubleValue()+b.doubleValue(); }
    
	public static void main(String args[]){
        GenericExample<String> g1 = new GenericExample<String>("Hola");
        //GenericExample<Integer> g2 = new GenericExample<Integer>(2);
        //GenericOnlyNumbers<String> g3 = new GenericExample<String>("Hola");
        //GenericOnlyNumbers<Integer> g4 = new GenericOnlyNumbers<Integer>(3);
	}
}

class GenericExample<T> {
    private T attr;

    public GenericExample(T attr) { this.attr = attr; }

    public T get() { return attr; }
    public void set(T attr) { this.attr = attr; }
}


class GenericOnlyNumbers<T extends Number> {

    private T attr;

    public GenericOnlyNumbers(T attr) { this.attr = attr; }

    public T get() { return attr; }
    public void set(T attr) { this.attr = attr; }
}