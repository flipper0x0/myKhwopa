package com.KhCE.student;

import android.animation.*;
import android.app.*;
import android.app.Activity;
import android.content.*;
import android.content.SharedPreferences;
import android.content.res.*;
import android.graphics.*;
import android.graphics.drawable.*;
import android.media.*;
import android.net.*;
import android.os.*;
import android.text.*;
import android.text.style.*;
import android.util.*;
import android.view.*;
import android.view.View.*;
import android.view.animation.*;
import android.webkit.*;
import android.widget.*;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.bottomnavigation.BottomNavigationView.OnNavigationItemSelectedListener;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener;
import com.google.firebase.FirebaseApp;
import de.hdodenhof.circleimageview.*;
import java.io.*;
import java.text.*;
import java.util.*;
import java.util.regex.*;
import org.json.*;

public class HomeActivity extends AppCompatActivity {
	
	private LinearLayout linear11;
	private BottomNavigationView bottomnavigation2;
	private LinearLayout homelinear;
	private LinearLayout reportlin;
	private LinearLayout paymentlin;
	private LinearLayout reslin;
	private LinearLayout proflin;
	private LinearLayout linear20;
	private TextView textview1;
	private TextView attend;
	private LinearLayout linear21;
	private LinearLayout linear22;
	private TextView textview9;
	private TextView gtuser;
	private TextView textview2;
	private TextView asgmt;
	private TabLayout tablayout1;
	private TextView textview3;
	private TextView bill;
	private TextView textview4;
	private TextView resc;
	private LinearLayout linear12;
	private LinearLayout linear13;
	private LinearLayout linear14;
	private LinearLayout linear19;
	private CircleImageView circleimageview1;
	private TextView textview7;
	
	private RequestNetwork request_khec_samyog;
	private RequestNetwork.RequestListener _request_khec_samyog_request_listener;
	private SharedPreferences getfromldbsamyog;
	
	@Override
	protected void onCreate(Bundle _savedInstanceState) {
		super.onCreate(_savedInstanceState);
		setContentView(R.layout.home);
		initialize(_savedInstanceState);
		FirebaseApp.initializeApp(this);
		initializeLogic();
	}
	
	private void initialize(Bundle _savedInstanceState) {
		linear11 = findViewById(R.id.linear11);
		bottomnavigation2 = findViewById(R.id.bottomnavigation2);
		homelinear = findViewById(R.id.homelinear);
		reportlin = findViewById(R.id.reportlin);
		paymentlin = findViewById(R.id.paymentlin);
		reslin = findViewById(R.id.reslin);
		proflin = findViewById(R.id.proflin);
		linear20 = findViewById(R.id.linear20);
		textview1 = findViewById(R.id.textview1);
		attend = findViewById(R.id.attend);
		linear21 = findViewById(R.id.linear21);
		linear22 = findViewById(R.id.linear22);
		textview9 = findViewById(R.id.textview9);
		gtuser = findViewById(R.id.gtuser);
		textview2 = findViewById(R.id.textview2);
		asgmt = findViewById(R.id.asgmt);
		tablayout1 = findViewById(R.id.tablayout1);
		textview3 = findViewById(R.id.textview3);
		bill = findViewById(R.id.bill);
		textview4 = findViewById(R.id.textview4);
		resc = findViewById(R.id.resc);
		linear12 = findViewById(R.id.linear12);
		linear13 = findViewById(R.id.linear13);
		linear14 = findViewById(R.id.linear14);
		linear19 = findViewById(R.id.linear19);
		circleimageview1 = findViewById(R.id.circleimageview1);
		textview7 = findViewById(R.id.textview7);
		request_khec_samyog = new RequestNetwork(this);
		getfromldbsamyog = getSharedPreferences("ldb", Activity.MODE_PRIVATE);
		
		bottomnavigation2.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
			@Override
			public boolean onNavigationItemSelected(MenuItem item) {
				final int _itemId = item.getItemId();
				if (_itemId == 0) {
					homelinear.setVisibility(View.VISIBLE);
					reportlin.setVisibility(View.GONE);
					paymentlin.setVisibility(View.GONE);
					proflin.setVisibility(View.GONE);
					reslin.setVisibility(View.GONE);
					
				}
				if (_itemId == 1) {
					homelinear.setVisibility(View.GONE);
					reportlin.setVisibility(View.VISIBLE);
					paymentlin.setVisibility(View.GONE);
					reslin.setVisibility(View.GONE);
					proflin.setVisibility(View.GONE);
					
				}
				if (_itemId == 2) {
					homelinear.setVisibility(View.GONE);
					reportlin.setVisibility(View.GONE);
					paymentlin.setVisibility(View.VISIBLE);
					reslin.setVisibility(View.GONE);
					proflin.setVisibility(View.GONE);
					
				}
				if (_itemId == 3) {
					homelinear.setVisibility(View.GONE);
					reportlin.setVisibility(View.GONE);
					paymentlin.setVisibility(View.GONE);
					reslin.setVisibility(View.VISIBLE);
					proflin.setVisibility(View.GONE);
					
				}
				if (_itemId == 4) {
					homelinear.setVisibility(View.GONE);
					reportlin.setVisibility(View.GONE);
					paymentlin.setVisibility(View.GONE);
					reslin.setVisibility(View.GONE);
					proflin.setVisibility(View.VISIBLE);
				}
				return true;
			}
		});
		
		tablayout1.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
			@Override
			public void onTabSelected(TabLayout.Tab tab) {
				final int _position = tab.getPosition();
				if (_position == 0) {
					SketchwareUtil.showMessage(getApplicationContext(), "Im Tab Pos 1");
				}
				if (_position == 1) {
					SketchwareUtil.showMessage(getApplicationContext(), "Im Tab Pos 2");
				}
			}
			
			@Override
			public void onTabUnselected(TabLayout.Tab tab) {
				final int _position = tab.getPosition();
				
			}
			
			@Override
			public void onTabReselected(TabLayout.Tab tab) {
				final int _position = tab.getPosition();
				
			}
		});
		
		_request_khec_samyog_request_listener = new RequestNetwork.RequestListener() {
			@Override
			public void onResponse(String _param1, String _param2, HashMap<String, Object> _param3) {
				final String _tag = _param1;
				final String _response = _param2;
				final HashMap<String, Object> _responseHeaders = _param3;
				SketchwareUtil.showMessage(getApplicationContext(), "");
			}
			
			@Override
			public void onErrorResponse(String _param1, String _param2) {
				final String _tag = _param1;
				final String _message = _param2;
				SketchwareUtil.showMessage(getApplicationContext(), "Error ! Check internet or Try again later");
			}
		};
	}
	
	private void initializeLogic() {
		bottomnavigation2.getMenu().add(0, 0, 0, "Home").setIcon(R.drawable.ic_home_white);
		bottomnavigation2.getMenu().add(0, 1, 0, "Report").setIcon(R.drawable.ic_receipt_white);
		bottomnavigation2.getMenu().add(0, 2, 0, "Payment").setIcon(R.drawable.ic_local_atm_white);
		bottomnavigation2.getMenu().add(0, 3, 0, "Resources").setIcon(R.drawable.ic_file_download_white);
		bottomnavigation2.getMenu().add(0, 4, 0, "More").setIcon(R.drawable.ic_view_headline_white);
		linear11.setVisibility(View.VISIBLE);
		reportlin.setVisibility(View.GONE);
		paymentlin.setVisibility(View.GONE);
		reslin.setVisibility(View.GONE);
		proflin.setVisibility(View.GONE);
		gtuser.setText(getfromldbsamyog.getString("name", ""));
		int hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY);
		
		if (hour >= 5 && hour < 12) {
			    textview9.setText("Good Morning,");
		} else if (hour >= 12 && hour < 18) {
			    textview9.setText("Good Afternoon,");
		} else {
			    textview9.setText("Good Evening,");
		}
		String text = gtuser.getText().toString();
		gtuser.setText(text.replaceAll("\\s.*$", ""));
		
		tablayout1.addTab(tablayout1.newTab().setText("gj"));
		tablayout1.addTab(tablayout1.newTab().setText("mj"));
		tablayout1.setTabRippleColor(new android.content.res.ColorStateList(new int[][]{new int[]{android.R.attr.state_pressed}}, 
		
		new int[] {0xFFFFFF00}));
		tablayout1.setSelectedTabIndicatorColor(0xFFFF3D00);
		tablayout1.setTabTextColors(0xFF000000, 0xFFFFFFFF);
		attend.setText("https://khwopa.edu.np/api/get_report_update?roll=".concat(getfromldbsamyog.getString("user", "").concat("&section=".concat(""))));
		if (true) {
			
		}
	}
	
	
	@Deprecated
	public void showMessage(String _s) {
		Toast.makeText(getApplicationContext(), _s, Toast.LENGTH_SHORT).show();
	}
	
	@Deprecated
	public int getLocationX(View _v) {
		int _location[] = new int[2];
		_v.getLocationInWindow(_location);
		return _location[0];
	}
	
	@Deprecated
	public int getLocationY(View _v) {
		int _location[] = new int[2];
		_v.getLocationInWindow(_location);
		return _location[1];
	}
	
	@Deprecated
	public int getRandom(int _min, int _max) {
		Random random = new Random();
		return random.nextInt(_max - _min + 1) + _min;
	}
	
	@Deprecated
	public ArrayList<Double> getCheckedItemPositionsToArray(ListView _list) {
		ArrayList<Double> _result = new ArrayList<Double>();
		SparseBooleanArray _arr = _list.getCheckedItemPositions();
		for (int _iIdx = 0; _iIdx < _arr.size(); _iIdx++) {
			if (_arr.valueAt(_iIdx))
			_result.add((double)_arr.keyAt(_iIdx));
		}
		return _result;
	}
	
	@Deprecated
	public float getDip(int _input) {
		return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, _input, getResources().getDisplayMetrics());
	}
	
	@Deprecated
	public int getDisplayWidthPixels() {
		return getResources().getDisplayMetrics().widthPixels;
	}
	
	@Deprecated
	public int getDisplayHeightPixels() {
		return getResources().getDisplayMetrics().heightPixels;
	}
}