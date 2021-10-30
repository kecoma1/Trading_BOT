public class Test {
    public static void main(String args[]) {
        SUV b = new SUV(250, 5, "Lexus", 500.2);
        Hypercar c = new Hypercar(1000, 2, "Lamborghini", 375.78);
        Car d = new SUV(1, 1, "d", 1.2);

        System.out.println(b.show());
        System.out.println(c.show());
    }
}
