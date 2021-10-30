public class SUV extends Car {
    private double volume;

    public SUV(int hp, int seats, String name, double volume) {
        super(hp, seats, name);
        this.volume = volume;
    }

    @Override
    public String show() { 
        return super.show()+this.volume+"\n";
    }

    @Override
    public void move() {
        System.out.println("I'm moving slow because I'm big.");
    }
}
