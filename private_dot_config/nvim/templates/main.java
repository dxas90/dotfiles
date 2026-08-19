import java.io.*;
import java.math.*;
import java.util.*;
/*
 * {{_date_}} {{_author_}} <{{_email_}}>
 */
public class Solution {

    static void solve() throws Exception {

    }
    // When I wrote this, only God and I understood what I was doing
    // Now, God only knows
    // <editor-fold defaultstate="collapsed" desc=";-) main Code">
    static BufferedReader read;
    static PrintWriter out = new PrintWriter(new OutputStreamWriter(System.out));
    static StringTokenizer st;
    final static boolean MY_FLAG = System.getProperty("MY_FLAG") == null;
    public static void main(String[] args) throws Exception {
        read = new BufferedReader(new InputStreamReader(MY_FLAG ? System.in : new FileInputStream("input")));
        eat("");
        solve();
        out.close();
        System.exit(0);
    }// </editor-fold>
    // <editor-fold defaultstate="collapsed" desc="Snippet Codes">
    static void eat(String str) {
        st = new StringTokenizer(str);
    }

    static String next() throws Exception {
        Locale.setDefault(Locale.ENGLISH);
        while (!st.hasMoreTokens()) {
            String line = read.readLine();
            if (line == null) return null;
            eat(line);
        }
        return st.nextToken();
    }

    static int nextInt() throws Exception {
        return Integer.parseInt(next());
    }// </editor-fold>
}

// ex: ts=4 sw=4 et filetype=java

