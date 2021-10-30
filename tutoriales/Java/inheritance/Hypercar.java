public class Hypercar extends Car {
    
    private double topSpeed;

    public Hypercar(int hp, int seats, String name, double topSpeed) {
        super(hp, seats, name);
        this.topSpeed = topSpeed;
    }

    @Override
    public String show() {
        return super.show()+this.topSpeed+"\n";
    }

    @Override
    public void move() {
        System.out.println("I'm moving fast");
    }

}
