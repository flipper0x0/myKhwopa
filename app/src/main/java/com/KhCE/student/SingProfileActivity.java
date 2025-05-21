package com.KhCE.student;

import android.animation.*;
import android.app.*;
import android.app.Activity;
import android.content.*;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.*;
import android.graphics.*;
import android.graphics.drawable.*;
import android.media.*;
import android.net.*;
import android.net.Uri;
import android.os.*;
import android.os.Bundle;
import android.text.*;
import android.text.style.*;
import android.util.*;
import android.view.*;
import android.view.View;
import android.view.View.*;
import android.view.animation.*;
import android.webkit.*;
import android.widget.*;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import androidx.annotation.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import com.bumptech.glide.Glide;
import com.google.android.material.button.*;
import com.google.firebase.FirebaseApp;
import de.hdodenhof.circleimageview.*;
import java.io.*;
import java.io.InputStream;
import java.text.*;
import java.util.*;
import java.util.HashMap;
import java.util.regex.*;
import org.json.*;

public class SingProfileActivity extends AppCompatActivity {
	
	private HashMap<String, Object> map = new HashMap<>();
	
	private LinearLayout linear1;
	private LinearLayout linear2;
	private LinearLayout linear7;
	private LinearLayout linear5;
	private LinearLayout linear3;
	private LinearLayout linear4;
	private LinearLayout linear9;
	private LinearLayout linear11;
	private LinearLayout linear18;
	private TextView textview5;
	private TextView guser;
	private CircleImageView circleimageview1;
	private ScrollView vscroll1;
	private TextView textview3;
	private LinearLayout linear10;
	private MaterialButton materialbutton1;
	
	private SharedPreferences ff;
	private Intent intent = new Intent();
	
	@Override
	protected void onCreate(Bundle _savedInstanceState) {
		super.onCreate(_savedInstanceState);
		setContentView(R.layout.sing_profile);
		initialize(_savedInstanceState);
		FirebaseApp.initializeApp(this);
		initializeLogic();
	}
	
	private void initialize(Bundle _savedInstanceState) {
		linear1 = findViewById(R.id.linear1);
		linear2 = findViewById(R.id.linear2);
		linear7 = findViewById(R.id.linear7);
		linear5 = findViewById(R.id.linear5);
		linear3 = findViewById(R.id.linear3);
		linear4 = findViewById(R.id.linear4);
		linear9 = findViewById(R.id.linear9);
		linear11 = findViewById(R.id.linear11);
		linear18 = findViewById(R.id.linear18);
		textview5 = findViewById(R.id.textview5);
		guser = findViewById(R.id.guser);
		circleimageview1 = findViewById(R.id.circleimageview1);
		vscroll1 = findViewById(R.id.vscroll1);
		textview3 = findViewById(R.id.textview3);
		linear10 = findViewById(R.id.linear10);
		materialbutton1 = findViewById(R.id.materialbutton1);
		ff = getSharedPreferences("ldb", Activity.MODE_PRIVATE);
		
		materialbutton1.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View _view) {
				intent.setClass(getApplicationContext(), HomeActivity.class);
				startActivity(intent);
				finishAffinity();
			}
		});
	}
	
	private void initializeLogic() {
		Glide.with(getApplicationContext()).load(Uri.parse("https://khwopa.edu.np/uploads/student/".concat(ff.getString("user", "").toUpperCase().concat(".jpg")))).into(circleimageview1);
		guser.setText(ff.getString("name", ""));
		int hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY);
		
		if (hour >= 5 && hour < 12) {
			    textview5.setText("Good Morning,");
		} else if (hour >= 12 && hour < 18) {
			    textview5.setText("Good Afternoon,");
		} else {
			    textview5.setText("Good Evening,");
		}
		String text = guser.getText().toString();
		guser.setText(text.replaceAll("\\s.*$", ""));
		
		SketchwareUtil.showMessage(getApplicationContext(), "Logged In");
		int[] colorsFDAEAB = { Color.parseColor("#4642B6"), Color.parseColor("#C10E8C") }; android.graphics.drawable.GradientDrawable FDAEAB = new android.graphics.drawable.GradientDrawable(android.graphics.drawable.GradientDrawable.Orientation.TL_BR, colorsFDAEAB);
		FDAEAB.setCornerRadii(new float[]{(int)30,(int)30,(int)30,(int)30,(int)30,(int)30,(int)30,(int)30});
		FDAEAB.setStroke((int) 0, Color.parseColor("#00FFFF"));
		materialbutton1.setElevation((float) 4);
		materialbutton1.setBackground(FDAEAB);
		int[] colorsFBBDEE = { Color.parseColor("#BD83C4"), Color.parseColor("#7D52FD") }; android.graphics.drawable.GradientDrawable FBBDEE = new android.graphics.drawable.GradientDrawable(android.graphics.drawable.GradientDrawable.Orientation.BOTTOM_TOP, colorsFBBDEE);
		FBBDEE.setCornerRadii(new float[]{(int)0,(int)0,(int)0,(int)0,(int)0,(int)0,(int)0,(int)0});
		FBBDEE.setStroke((int) 0, Color.parseColor("#000000"));
		linear4.setElevation((float) 6);
		linear4.setBackground(FBBDEE);
		int[] colorsFAEACE = { Color.parseColor("#2C2BEE"), Color.parseColor("#65F8CA") }; android.graphics.drawable.GradientDrawable FAEACE = new android.graphics.drawable.GradientDrawable(android.graphics.drawable.GradientDrawable.Orientation.BR_TL, colorsFAEACE);
		FAEACE.setCornerRadii(new float[]{(int)0,(int)0,(int)0,(int)0,(int)0,(int)0,(int)0,(int)0});
		FAEACE.setStroke((int) 0, Color.parseColor("#000000"));
		linear1.setElevation((float) 5);
		linear1.setBackground(FAEACE);
	}
	
	public void _clickAnimation(final View _view) {
		ScaleAnimation fade_in = new ScaleAnimation(0.9f, 1f, 0.9f, 1f, Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.7f);
		fade_in.setDuration(300);
		fade_in.setFillAfter(true);
		_view.startAnimation(fade_in);
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