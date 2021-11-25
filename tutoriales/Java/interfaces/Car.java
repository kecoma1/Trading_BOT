public class Car implements ICar, IAuto {
	public void move() { System.out.println("I'm moving"); }
	public void turnOff() { System.out.println("I'm turning my self off"); }
	public void accelerate() { System.out.println("I'm accelerating"); }
}