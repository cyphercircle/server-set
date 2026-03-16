1	import android.support.v7.app.AppCompatActivity; 
2	import android.os.Bundle; 
3	import android.view.View; 
4	import android.widget.Button; 
5	import android.widget.CheckBox; 
6	import android.widget.TextView; 
7	 
8	public class MainActivity extends AppCompatActivity { 
9	 
10	    CheckBox checkBox1, checkBox2, checkBox3; 
11	    Button submitButton; 
12	    TextView textView; 
13	    @Override 
14	    protected void onCreate(Bundle savedInstanceState) { 
15	        super.onCreate(savedInstanceState); 
16	        setContentView(R.layout.activity_main); 
17	 
18	        checkBox1 = (CheckBox) findViewById(R.id.checkBox1); 
19	        checkBox2 = (CheckBox) findViewById(R.id.checkBox2); 
20	        checkBox3 = (CheckBox) findViewById(R.id.checkBox3); 
21	 
22	        submitButton = (Button) findViewById(R.id.submitButton); 
23	 
24	        textView = (TextView) findViewById(R.id.textView); 
25	 
26	    } 
27	 
28	    public void onClick(View view){ 
29	 
30	         if (checkBox1.isChecked() == true && checkBox2.isChecked() == true && checkBox3.isChecked() == true){ 
31	            textView.setText("You like all fruits !"); 
32	        } 
33	 
34	         else if (checkBox1.isChecked() == true && checkBox2.isChecked() == true){ 
35	             textView.setText("You like Banana and Apple !"); 
36	         } 
37	         else if (checkBox1.isChecked() == true && checkBox3.isChecked() == true){ 
38	             textView.setText("You like Banana and Orange !"); 
39	         } 
40	         else if (checkBox2.isChecked() == true && checkBox3.isChecked() == true){ 
41	             textView.setText("You like Apple and Orange !"); 
42	         } 
43	 
44	        else if(checkBox1.isChecked() == true){ 
45	            textView.setText("You like Banana !"); 
46	        } 
47	        else if (checkBox2.isChecked() == true){ 
48	            textView.setText("You like Apple !"); 
49	        } 
50	        else if (checkBox3.isChecked() == true){ 
51	            textView.setText("You like Orange !"); 
52	        } 
53	 
54	        else{ 
55	            textView.setText("You don't like these fruits?"); 
56	        } 
57	 
58	    } 
59	} 
