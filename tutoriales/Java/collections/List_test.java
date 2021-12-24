import java.util.*;

public class List_test {
	public static void main(String args[]) {
		List<Integer> listA = new ArrayList<Integer>();
		List<String> listB = new LinkedList<String>();
		Collection<String> set = new TreeSet<String>();

		for (int i = 0; i < 10; i++) {
			listA.add(i+1);
			listB.add("n "+i);
			set.add("Hola");
		}
		
		System.out.println(listA);
		System.out.println(listB);
		System.out.println(set);
		
		System.out.println("\n");
		System.out.print("ListB: ");
		for (String s : listB) {
			System.out.print(s+ " - ");
		}
		System.out.println("\n");
	}
}
