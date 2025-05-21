package com.KhCE.student;

import android.animation.*;
import android.app.*;
import android.app.Activity;
import android.content.*;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.*;
import android.graphics.*;
import android.graphics.Typeface;
import android.graphics.drawable.*;
import android.media.*;
import android.net.*;
import android.net.Uri;
import android.os.*;
import android.os.Bundle;
import android.os.Vibrator;
import android.text.*;
import android.text.style.*;
import android.util.*;
import android.view.*;
import android.view.View;
import android.view.View.*;
import android.view.animation.*;
import android.webkit.*;
import android.widget.*;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import com.google.firebase.FirebaseApp;
import java.io.*;
import java.io.InputStream;
import java.text.*;
import java.util.*;
import java.util.HashMap;
import java.util.regex.*;
import org.json.*;

public class SingInActivity extends AppCompatActivity {
	
	private HashMap<String, Object> username = new HashMap<>();
	
	private LinearLayout linear1;
	private ImageView imageview1;
	private TextView textview1;
	private LinearLayout linear;
	private LinearLayout linear6;
	private LinearLayout linear5;
	private LinearLayout email;
	private LinearLayout password;
	private LinearLayout linear12;
	private LinearLayout sing_up;
	private TextView textview6;
	private LinearLayout linear14;
	private Button button1;
	private LinearLayout linear7;
	private TextView textview2;
	private LinearLayout linear8;
	private TextView textview3;
	private EditText reqemail;
	private LinearLayout linear11;
	private LinearLayout linear13;
	private TextView textview4;
	private EditText edit_password;
	private ImageView imageview2;
	private ImageView imageview3;
	private TextView textview5;
	private EditText reqpasso;
	
	private Intent i = new Intent();
	private RequestNetwork reqn;
	private RequestNetwork.RequestListener _reqn_request_listener;
	private SharedPreferences file;
	private Vibrator vib;
	
	@Override
	protected void onCreate(Bundle _savedInstanceState) {
		super.onCreate(_savedInstanceState);
		setContentView(R.layout.sing_in);
		initialize(_savedInstanceState);
		FirebaseApp.initializeApp(this);
		initializeLogic();
	}
	
	private void initialize(Bundle _savedInstanceState) {
		linear1 = findViewById(R.id.linear1);
		imageview1 = findViewById(R.id.imageview1);
		textview1 = findViewById(R.id.textview1);
		linear = findViewById(R.id.linear);
		linear6 = findViewById(R.id.linear6);
		linear5 = findViewById(R.id.linear5);
		email = findViewById(R.id.email);
		password = findViewById(R.id.password);
		linear12 = findViewById(R.id.linear12);
		sing_up = findViewById(R.id.sing_up);
		textview6 = findViewById(R.id.textview6);
		linear14 = findViewById(R.id.linear14);
		button1 = findViewById(R.id.button1);
		linear7 = findViewById(R.id.linear7);
		textview2 = findViewById(R.id.textview2);
		linear8 = findViewById(R.id.linear8);
		textview3 = findViewById(R.id.textview3);
		reqemail = findViewById(R.id.reqemail);
		linear11 = findViewById(R.id.linear11);
		linear13 = findViewById(R.id.linear13);
		textview4 = findViewById(R.id.textview4);
		edit_password = findViewById(R.id.edit_password);
		imageview2 = findViewById(R.id.imageview2);
		imageview3 = findViewById(R.id.imageview3);
		textview5 = findViewById(R.id.textview5);
		reqpasso = findViewById(R.id.reqpasso);
		reqn = new RequestNetwork(this);
		file = getSharedPreferences("ldb", Activity.MODE_PRIVATE);
		vib = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
		
		sing_up.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View _view) {
				String inputText = edit_password.getText().toString();
				String md5Hash = "";
				
				try {
					    // Create a MessageDigest instance for MD5
					    java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
					    md.update(inputText.getBytes());
					    byte[] digest = md.digest();
					
					    // Convert byte array to hex string
					    StringBuilder hexString = new StringBuilder();
					    for (byte b : digest) {
						        String hex = Integer.toHexString(0xff & b);
						        if (hex.length() == 1) hexString.append('0');
						        hexString.append(hex);
						    }
					    md5Hash = hexString.toString();
				} catch (java.security.NoSuchAlgorithmException e) {
					    e.printStackTrace();
				}
				
				// Set the MD5 hash to edittext2
				reqpasso.setText(md5Hash);
				
				reqn.startRequestNetwork(RequestNetworkController.GET, "https://khwopa.edu.np/api/auth?user=".concat(reqemail.getText().toString().concat("&pass=".concat(reqpasso.getText().toString()))), "a", _reqn_request_listener);
				file.edit().putString("user", reqemail.getText().toString()).commit();
				file.edit().putString("pwd", edit_password.getText().toString()).commit();
			}
		});
		
		textview6.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View _view) {
				SketchwareUtil.showMessage(getApplicationContext(), "Please contact Administrator Section.");
			}
		});
		
		button1.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View _view) {
				i.setClass(getApplicationContext(), SingProfileActivity.class);
				startActivity(i);
			}
		});
		
		imageview2.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View _view) {
				edit_password.setTransformationMethod(android.text.method.PasswordTransformationMethod.getInstance());
				imageview3.setVisibility(View.VISIBLE);
				imageview2.setVisibility(View.GONE);
			}
		});
		
		imageview3.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View _view) {
				edit_password.setTransformationMethod(android.text.method.HideReturnsTransformationMethod.getInstance());
				imageview2.setVisibility(View.VISIBLE);
				imageview3.setVisibility(View.GONE);
			}
		});
		
		_reqn_request_listener = new RequestNetwork.RequestListener() {
			@Override
			public void onResponse(String _param1, String _param2, HashMap<String, Object> _param3) {
				final String _tag = _param1;
				final String _response = _param2;
				final HashMap<String, Object> _responseHeaders = _param3;
				if (_response.contains("incorrect")) {
					SketchwareUtil.showMessage(getApplicationContext(), "Invalid email or password.");
					vib.vibrate((long)(100));
				}
				else {
					i.setClass(getApplicationContext(), SingProfileActivity.class);
					startActivity(i);
				}
				file.edit().putString("name", _response).commit();
				file.edit().putString("crn", reqemail.getText().toString()).commit();
			}
			
			@Override
			public void onErrorResponse(String _param1, String _param2) {
				final String _tag = _param1;
				final String _message = _param2;
				SketchwareUtil.showMessage(getApplicationContext(), "No Internet Connection");
				vib.vibrate((long)(200));
			}
		};
	}
	
	private void initializeLogic() {
		textview1.setTypeface(Typeface.createFromAsset(getAssets(),"fonts/ffbold.ttf"), 1);
		imageview2.setColorFilter(0xFF607D8B, PorterDuff.Mode.MULTIPLY);
		imageview3.setColorFilter(0xFF607D8B, PorterDuff.Mode.MULTIPLY);
		imageview2.setVisibility(View.GONE);
		{
			android.graphics.drawable.GradientDrawable SketchUi = new android.graphics.drawable.GradientDrawable();
			int d = (int) getApplicationContext().getResources().getDisplayMetrics().density;
			SketchUi.setColor(0xFFF1F4F9);
			SketchUi.setCornerRadius(d*5);
			SketchUi.setStroke(d*3,0xFFEAEEF7);
			password.setBackground(SketchUi);
		}
		{
			android.graphics.drawable.GradientDrawable SketchUi = new android.graphics.drawable.GradientDrawable();
			int d = (int) getApplicationContext().getResources().getDisplayMetrics().density;
			SketchUi.setColor(0xFFF1F4F9);
			SketchUi.setCornerRadius(d*5);
			SketchUi.setStroke(d*3,0xFFEAEEF7);
			email.setBackground(SketchUi);
		}
		{
			android.graphics.drawable.GradientDrawable SketchUi = new android.graphics.drawable.GradientDrawable();
			int d = (int) getApplicationContext().getResources().getDisplayMetrics().density;
			SketchUi.setColor(0xFFFFFFFF);SketchUi.setCornerRadii(new float[]{
				d*15,d*15,d*15 ,d*15,d*0,d*0 ,d*0,d*0});
			android.graphics.drawable.RippleDrawable SketchUiRD = new android.graphics.drawable.RippleDrawable(new android.content.res.ColorStateList(new int[][]{new int[]{}}, new int[]{0xFFE0E0E0}), SketchUi, null);
			linear.setBackground(SketchUiRD);
			linear.setClickable(false);
		}
		{
			android.graphics.drawable.GradientDrawable SketchUi = new android.graphics.drawable.GradientDrawable();
			int d = (int) getApplicationContext().getResources().getDisplayMetrics().density;
			SketchUi.setColor(0xFFFC4971);
			SketchUi.setCornerRadius(d*226);
			android.graphics.drawable.RippleDrawable SketchUiRD = new android.graphics.drawable.RippleDrawable(new android.content.res.ColorStateList(new int[][]{new int[]{}}, new int[]{0xFFE0E0E0}), SketchUi, null);
			sing_up.setBackground(SketchUiRD);
			sing_up.setClickable(true);
		}
		edit_password.setTransformationMethod(android.text.method.PasswordTransformationMethod.getInstance());
		reqemail.setFilters(new InputFilter[]{new InputFilter.LengthFilter((int) 12)});
		edit_password.setFilters(new InputFilter[]{new InputFilter.LengthFilter((int) 16)});
		reqpasso.setVisibility(View.GONE);
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