1	import android.graphics.Color; 
2	import android.support.v7.app.AppCompatActivity; 
3	import android.os.Bundle; 
4	import android.view.MenuItem; 
5	import android.view.View; 
6	import android.widget.Button; 
7	import android.widget.PopupMenu; 
8	import android.widget.RelativeLayout; 
9	 
10	 
11	public class MainActivity extends AppCompatActivity { 
12	 
13	    Button button; 
14	    RelativeLayout relativeLayout; 
15	 
16	    @Override 
17	    protected void onCreate(Bundle savedInstanceState) { 
18	        super.onCreate(savedInstanceState); 
19	        setContentView(R.layout.activity_main); 
20	 
21	        button = (Button) findViewById(R.id.button); 
22	        relativeLayout = (RelativeLayout) findViewById(R.id.relLayout); 
23	 
24	    } 
25	 
26	    public void changeBackground(View view) { 
27	        //init the menu and pass parameters: context and view to be registered for menu 
28	        PopupMenu popupMenu = new PopupMenu(MainActivity.this, button); 
29	        //inflate the menu 
30	        popupMenu.getMenuInflater().inflate(R.menu.menu_main, popupMenu.getMenu()); 
31	        //menu item click listener 
32	        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() { 
33	            @Override 
34	            public boolean onMenuItemClick(MenuItem item) { 
35	                switch (item.getItemId()) { 
36	                    case R.id.white: 
37	                        relativeLayout.setBackgroundColor(Color.WHITE); 
38	                        break; 
39	                    case R.id.blue: 
40	                        relativeLayout.setBackgroundColor(Color.BLUE); 
41	                        break; 
42	                    case R.id.yellow: 
43	                        relativeLayout.setBackgroundColor(Color.YELLOW); 
44	                        break; 
45	                } 
46	                return true; 
47	            } 
48	        }); 
49	        //we have created, initialized and inflated the menu now show it 
50	        popupMenu.show(); 
51	    } 
52	} 
