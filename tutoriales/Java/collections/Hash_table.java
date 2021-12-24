import java.util.*;

public class Hash_table {
	public static void main(String args[]) {

		List<String> list = new ArrayList<String>(Arrays.asList("First", "Second", "Third", "Fourth", "Fifth"));

		HashMap<String, Integer> dict1 = new HashMap<String, Integer>();
		Hashtable<Integer, String> dict2 = new Hashtable<Integer, String>();

		int i = 1;
		for (String s: list) {
			dict1.put(s, i);
			dict2.put(i, s);
			i++;
		}

		System.out.println(dict1);
		System.out.println(dict2);

		// Updating a value
		dict1.put("Second", 3);
		System.out.println("\n"+dict1);

		// Getting a value
		System.out.println(dict1.get("Second"));
		
	}
}
