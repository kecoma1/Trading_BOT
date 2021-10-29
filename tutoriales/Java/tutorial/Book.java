package tutorial;

public class Book {
    private String title;
    private String author;
    private Integer pages;

    public Book(String title, String author, Integer pages) {
        this.title = title;
        this.author = author;
        this.pages = pages;
    }

    public String showBook() {
        return this.title+"\n"+this.author+"\n"+this.pages;
    }

    public String createDesc() {
        return "TITLE: "+this.title+"\nAUTHOR: "+this.author+"\nPAGES: "+this.pages;
    }
}