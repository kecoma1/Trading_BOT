package tutorial;
import tutorial.Book;

public class test {
    public static void main(String args[]) {
        Book b = new Book("The rational male", "Rollo tomassi", 300);
        Book c = new Book("The unplugged alpha", "Richard Cooper", 200);

        System.out.println(c.showBook());
        System.out.println(c.createDesc());
    }
}
