public abstract class Car {
    private int hp;
    public int seats;
    public String name;

    public Car(int hp, int seats, String name) {
        this.hp = hp;
        this.seats = seats;
        this.name = name;
    }

    public int getSeats() { return this.seats; }
    public String show() { return this.name+"\n"+this.hp+"\n"+this.seats+"\n"; }
    public abstract void move();
}
