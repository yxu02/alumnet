//
//  LuaLoader.java
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This corresponds to the name of the Lua library,
// e.g. [Lua] require "plugin.library"
package plugin.library;

import android.util.Log;

import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoDevice;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUser;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserAttributes;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserCodeDeliveryDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserPool;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserSession;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.AuthenticationContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.AuthenticationDetails;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.ChallengeContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.ForgotPasswordContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.continuations.MultiFactorAuthenticationContinuation;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.AuthenticationHandler;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.ForgotPasswordHandler;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.GetDetailsHandler;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.handlers.SignUpHandler;
import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaLua;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeListener;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.NamedJavaFunction;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static plugin.library.RBUtils.print;


/**
 * Implements the Lua interface for a Corona plugin.
 * <p>
 * Only one instance of this class will be created by Corona for the lifetime of the application.
 * This instance will be re-used for every new Corona activity that gets created.
 */
@SuppressWarnings("WeakerAccess")
public class LuaLoader implements JavaFunction, CoronaRuntimeListener {
	/** Lua registry ID to the Lua function to be called when the ad request finishes. */
	private int fListener;

	/** This corresponds to the event name, e.g. [Lua] event.name */
	private static final String EVENT_NAME = "pluginlibraryevent";


	private Hashtable<String, Integer> luaCallBackReferenceKeyByFunctionName = new Hashtable<String, Integer>();


	/**
	 * Creates a new Lua interface to this plugin.
	 * <p>
	 * Note that a new LuaLoader instance will not be created for every CoronaActivity instance.
	 * That is, only one instance of this class will be created for the lifetime of the application process.
	 * This gives a plugin the option to do operations in the background while the CoronaActivity is destroyed.
	 */
	@SuppressWarnings("unused")
	public LuaLoader() {
		// Initialize member variables.
		fListener = CoronaLua.REFNIL;

		// Set up this plugin to listen for Corona runtime events to be received by methods
		// onLoaded(), onStarted(), onSuspended(), onResumed(), and onExiting().
		CoronaEnvironment.addRuntimeListener(this);
	}

	/**
	 * Called when this plugin is being loaded via the Lua require() function.
	 * <p>
	 * Note that this method will be called every time a new CoronaActivity has been launched.
	 * This means that you'll need to re-initialize this plugin here.
	 * <p>
	 * Warning! This method is not called on the main UI thread.
	 * @param L Reference to the Lua state that the require() function was called from.
	 * @return Returns the number of values that the require() function will return.
	 *         <p>
	 *         Expected to return 1, the library that the require() function is loading.
	 */
	@Override
	public int invoke(LuaState L) {
		// Register this plugin into Lua with the following functions.
		NamedJavaFunction[] luaFunctions = new NamedJavaFunction[] {
			new loginWrapper(),
			new logoutWrapper(),
			new signupWrapper(),
			new getUserDetailsWrapper(),
			new loginSSOWrapper()
		};
		String libName = L.toString( 1 );
		L.register(libName, luaFunctions);

		// Returning 1 indicates that the Lua require() function will return the above Lua library.
		return 1;
	}

	/**
	 * Called after the Corona runtime has been created and just before executing the "main.lua" file.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been loaded/initialized.
	 *                Provides a LuaState object that allows the application to extend the Lua API.
	 */
	@Override
	public void onLoaded(CoronaRuntime runtime) {
		// Note that this method will not be called the first time a Corona activity has been launched.
		// This is because this listener cannot be added to the CoronaEnvironment until after
		// this plugin has been required-in by Lua, which occurs after the onLoaded() event.
		// However, this method will be called when a 2nd Corona activity has been created.

	}

	/**
	 * Called just after the Corona runtime has executed the "main.lua" file.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been started.
	 */
	@Override
	public void onStarted(CoronaRuntime runtime) {
	}

	/**
	 * Called just after the Corona runtime has been suspended which pauses all rendering, audio, timers,
	 * and other Corona related operations. This can happen when another Android activity (ie: window) has
	 * been displayed, when the screen has been powered off, or when the screen lock is shown.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been suspended.
	 */
	@Override
	public void onSuspended(CoronaRuntime runtime) {
	}

	/**
	 * Called just after the Corona runtime has been resumed after a suspend.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been resumed.
	 */
	@Override
	public void onResumed(CoronaRuntime runtime) {
	}

	/**
	 * Called just before the Corona runtime terminates.
	 * <p>
	 * This happens when the Corona activity is being destroyed which happens when the user presses the Back button
	 * on the activity, when the native.requestExit() method is called in Lua, or when the activity's finish()
	 * method is called. This does not mean that the application is exiting.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that is being terminated.
	 */
	@Override
	public void onExiting(CoronaRuntime runtime) {
		// Remove the Lua listener reference.
		CoronaLua.deleteRef( runtime.getLuaState(), fListener );
		fListener = CoronaLua.REFNIL;
	}
String TAG = RBUtils.TAG;


	// ------------------------------------------------
	// --- Lua Callback Handlers

	// handles all request for Lua callbacks
	private void callBackLua(String callBackKeyFunctionName, List<Hashtable<String, Object>> data) {


		print("on callBackLua for '" + callBackKeyFunctionName + "'");

		Integer callBackKey = luaCallBackReferenceKeyByFunctionName.get(callBackKeyFunctionName);

		if (callBackKey == null) {
			print("No callback registered for '" + callBackKeyFunctionName + "'");
			return ;
		}
		RBUtils.callBackLua(callBackKey, data, false);
		luaCallBackReferenceKeyByFunctionName.remove(callBackKeyFunctionName);
	}

	private void callBackLua(String callBackKeyFunctionName, Hashtable<String, Object> data) {
		List<Hashtable<String, Object>> tableList  = new ArrayList<Hashtable<String, Object>>();
		tableList.add(data);

		callBackLua(callBackKeyFunctionName, tableList);
	}

	//--------- AWS
	String userPassword;

	private void getUserAuthentication(AuthenticationContinuation continuation, String username) {
		if(username != null) {
			this.username = username;
			AppHelper.setUser(username);
		}

		AuthenticationDetails authenticationDetails = new AuthenticationDetails(this.username, userPassword, null);
		continuation.setAuthenticationDetails(authenticationDetails);
		continuation.continueTask();
	}
	// Callbacks
	ForgotPasswordHandler forgotPasswordHandler = new ForgotPasswordHandler() {
		@Override
		public void onSuccess() {
			//closeWaitDialog();
			//showDialogMessage("Password successfully changed!","");
			//inPassword.setText("");
			//inPassword.requestFocus();
		}

		@Override
		public void getResetCode(ForgotPasswordContinuation forgotPasswordContinuation) {
			//closeWaitDialog();
			//getForgotPasswordCode(forgotPasswordContinuation);
		}

		@Override
		public void onFailure(Exception e) {
			//closeWaitDialog();
			//showDialogMessage("Forgot password failed",AppHelper.formatException(e));
			Log.d(TAG, "Forgot password failed " + AppHelper.formatException(e));
		}
	};

	//
	AuthenticationHandler authenticationHandler = new AuthenticationHandler() {
		@Override
		public void onSuccess(CognitoUserSession cognitoUserSession, CognitoDevice device) {
			Log.d(TAG, " -- Auth Success");
			AppHelper.setCurrSession(cognitoUserSession);
			AppHelper.newDevice(device);
			//closeWaitDialog();
			//launchUser();

			Hashtable<String, Object> event = new Hashtable<>();
			if (cognitoUserSession != null) {
				if (cognitoUserSession.getAccessToken() != null) {
					event.put("userSessionAccessTokenExpiration", cognitoUserSession.getAccessToken().getExpiration().toString());
					event.put("userSessionAccessTokenJWTToken", cognitoUserSession.getAccessToken().getJWTToken());
					//event.put("userSessionAccessTokenUsername", cognitoUserSession.getAccessToken().getUsername());
				}
				if (cognitoUserSession.getRefreshToken() != null) {
					event.put("userSessionRefreshToken", cognitoUserSession.getRefreshToken().getToken());
				}
				if (cognitoUserSession.getUsername() != null) {
					event.put("userSessionUsername", cognitoUserSession.getUsername());
				}
				if (cognitoUserSession.getIdToken() != null) {
					event.put("userSessionIdTokenExpiration", cognitoUserSession.getIdToken().getExpiration().toString());
					event.put("userSessionIdTokenIssuedAt", cognitoUserSession.getIdToken().getIssuedAt().toString());
					event.put("userSessionIdTokenJWTToken", cognitoUserSession.getIdToken().getJWTToken());
					//event.put("userSessionIdTokenNotBefore", cognitoUserSession.getIdToken().getNotBefore());
				}
			}
			if (device != null) {
				if (device.getDeviceName() != null) {
					event.put("deviceName", device.getDeviceName());
				}
			}


			callBackLua("login", event);

		}

		@Override
		public void getAuthenticationDetails(AuthenticationContinuation authenticationContinuation, String username) {
			//closeWaitDialog();
			Locale.setDefault(Locale.US);
			getUserAuthentication(authenticationContinuation, username);
		}

		@Override
		public void getMFACode(MultiFactorAuthenticationContinuation multiFactorAuthenticationContinuation) {
			//closeWaitDialog();
			//mfaAuth(multiFactorAuthenticationContinuation);
		}

		@Override
		public void onFailure(Exception e) {
			//closeWaitDialog();

			Log.d(TAG, "Sign-in failed - " + AppHelper.formatException(e));

			Hashtable<String, Object> event = new Hashtable<>();
			event.put("errorMessage", "Sign-in failed - " + AppHelper.formatException(e));
			callBackLua("login-failed", event);
		}

		@Override
		public void authenticationChallenge(ChallengeContinuation continuation) {
			/**
			 * For Custom authentication challenge, implement your logic to present challenge to the
			 * user and pass the user's responses to the continuation.
			 */
			Log.d(TAG, "on authenticationChallenge");
			Log.d(TAG, continuation.getChallengeName());
			if ("NEW_PASSWORD_REQUIRED".equals(continuation.getChallengeName())) {
				// This is the first sign-in attempt for an admin created user
//				newPasswordContinuation = (NewPasswordContinuation) continuation;
//				AppHelper.setUserAttributeForDisplayFirstLogIn(newPasswordContinuation.getCurrentUserAttributes(),
//						newPasswordContinuation.getRequiredAttributes());
				//closeWaitDialog();
				//firstTimeSignIn();
			} else if ("SELECT_MFA_TYPE".equals(continuation.getChallengeName())) {
//				closeWaitDialog();
//				mfaOptionsContinuation = (ChooseMfaContinuation) continuation;
//				List<String> mfaOptions = mfaOptionsContinuation.getMfaOptions();
//				selectMfaToSignIn(mfaOptions, continuation.getParameters());
			}
		}
	};


	//---------




	// User Details
	private String username;



	/**
	 * The following Lua function has been called:  library.init( listener )
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param luaState Reference to the Lua state that the Lua function was called from.
	 * @return Returns the number of values to be returned by the library.init() function.
	 */
	@SuppressWarnings({"WeakerAccess", "SameReturnValue"})
	public int login(LuaState luaState) {

		String email = luaState.checkString( 1 );
		String password = luaState.checkString( 2 );

		username = email;

		Log.d(TAG, "email=" + email);
		Log.d(TAG, "password=" + password);

		int luaFunctionStackIndex = 4;
		if (luaState.isFunction(luaFunctionStackIndex)) {

			// storing that lua callback function so we can call it later (we stored it by getting a reference key to it
			luaState.pushValue(luaFunctionStackIndex);// making sure the function is on top of the stack.
			final int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX); // returns a Ref Key to the Top of stack item

			luaCallBackReferenceKeyByFunctionName.put("login-failed", callBackRefKey);
		}

		luaFunctionStackIndex = 3;
		if (luaState.isFunction(luaFunctionStackIndex)) {

			// storing that lua callback function so we can call it later (we stored it by getting a reference key to it
			luaState.pushValue(luaFunctionStackIndex);// making sure the function is on top of the stack.
			final int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX); // returns a Ref Key to the Top of stack item

			luaCallBackReferenceKeyByFunctionName.put("login", callBackRefKey);
		}

		AppHelper.init(CoronaEnvironment.getApplicationContext());

		AppHelper.setUser(email);
		userPassword = password; // it will be used inside the getUserAuthentication() function above

		CognitoUserPool pool = AppHelper.getPool();
		if (pool == null) {  Log.d(TAG, "POOL is null"); return 0; }

		CognitoUser user = pool.getUser(email);
		if (user == null){  Log.d(TAG, "User is null"); return 0; }

		user.getSessionInBackground(authenticationHandler);

		return 0;
	}

	/**
	 * The following Lua function has been called:  library.init( listener )
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param luaState Reference to the Lua state that the Lua function was called from.
	 * @return Returns the number of values to be returned by the library.init() function.
	 */
	@SuppressWarnings({"WeakerAccess", "SameReturnValue"})
	public int loginSSO(LuaState luaState) {

		int luaFunctionStackIndex = 1;
		if (luaState.isFunction(luaFunctionStackIndex)) {

			// storing that lua callback function so we can call it later (we stored it by getting a reference key to it
			luaState.pushValue(luaFunctionStackIndex);// making sure the function is on top of the stack.
			final int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX); // returns a Ref Key to the Top of stack item

			luaCallBackReferenceKeyByFunctionName.put("login-sso", callBackRefKey);
		}

//		// Add a call to initialize AWSMobileClient
//		AWSMobileClient.getInstance().initialize(this, new AWSStartupHandler() {
//			@Override
//			public void onComplete(AWSStartupResult awsStartupResult) {
//				AuthUIConfiguration config =
//						new AuthUIConfiguration.Builder()
//								.userPools(true)  // true? show the Email and Password UI
//								.signInButton(FacebookButton.class) // Show Facebook button
//								.logoResId(R.drawable.logo1) // Change the logo
//								.backgroundColor(Color.DKGRAY) // Change the backgroundColor
//								.isBackgroundColorFullScreen(true) // Full screen backgroundColor the backgroundColor full screenff
//								.fontFamily("sans-serif-light") // Apply sans-serif-light as the global font
//								.canCancel(true)
//								.build();
//				SignInUI signin = (SignInUI) AWSMobileClient.getInstance().getClient(AuthenticatorActivity.this, SignInUI.class);
//				signin.login(AuthenticatorActivity.this, MainActivity.class).authUIConfiguration(config).execute();
//			}
//		}).execute();




		return 0;
	}

	/**
	 * The following Lua function has been called:  library.init( listener )
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param luaState Reference to the Lua state that the Lua function was called from.
	 * @return Returns the number of values to be returned by the library.init() function.
	 */
	@SuppressWarnings({"WeakerAccess", "SameReturnValue"})
	public int logout(LuaState luaState) {

		String username = luaState.checkString( 1 );
		int luaFunctionStackIndex = 2;
		if (luaState.isFunction(luaFunctionStackIndex)) {

			// storing that lua callback function so we can call it later (we stored it by getting a reference key to it
			luaState.pushValue(luaFunctionStackIndex);// making sure the function is on top of the stack.
			final int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX); // returns a Ref Key to the Top of stack item

			luaCallBackReferenceKeyByFunctionName.put("logout", callBackRefKey);
		}

		print("username=");
		print(username);
		AppHelper.init(CoronaEnvironment.getApplicationContext());
		CognitoUser user = AppHelper.getPool().getUser(username);
		user.signOut();



		return 0;
	}

	/**
	 * The following Lua function has been called:  library.init( listener )
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param luaState Reference to the Lua state that the Lua function was called from.
	 * @return Returns the number of values to be returned by the library.init() function.
	 */
	@SuppressWarnings({"WeakerAccess", "SameReturnValue"})
	public int getUserDetails(LuaState luaState) {

		int luaFunctionStackIndex = 1;
		if (luaState.isFunction(luaFunctionStackIndex)) {

			// storing that lua callback function so we can call it later (we stored it by getting a reference key to it
			luaState.pushValue(luaFunctionStackIndex);// making sure the function is on top of the stack.
			final int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX); // returns a Ref Key to the Top of stack item

			luaCallBackReferenceKeyByFunctionName.put("userDetails", callBackRefKey);
		}


		AppHelper.init(CoronaEnvironment.getApplicationContext());
		CognitoUser user = AppHelper.getPool().getUser(username);


		GetDetailsHandler detailsHandler = new GetDetailsHandler() {
			@Override
			public void onSuccess(CognitoUserDetails cognitoUserDetails) {
				CognitoUserAttributes userAttributes = cognitoUserDetails.getAttributes();
				Map<String, String> attributes = userAttributes.getAttributes();

				Hashtable<String, Object> event = new Hashtable<>();
				for (String key : attributes.keySet()) {
					Object value = attributes.get(key);
					event.put(key, value);
//					print("key="+ key);
//					print("value="+ value);
				}
				callBackLua("userDetails", event);

				// Trusted devices?
				//handleTrustedDevice();
			}

			@Override
			public void onFailure(Exception exception) {

			}
		};


		user.getDetails(detailsHandler);

		return 0;
	}




	/**
	 * The following Lua function has been called:  library.init( listener )
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param luaState Reference to the Lua state that the Lua function was called from.
	 * @return Returns the number of values to be returned by the library.init() function.
	 */
	@SuppressWarnings({"WeakerAccess", "SameReturnValue"})
	public int signup(LuaState luaState) {

		String name = luaState.checkString( 1 );
		String email = luaState.checkString( 2 );
		String password = luaState.checkString( 3 );

		Log.d(TAG, "name=" + name);
		Log.d(TAG, "email=" + email);
		Log.d(TAG, "password=" + password);

        int luaFunctionStackIndex = 5;
        if (luaState.isFunction(luaFunctionStackIndex)) {
            luaState.pushValue(luaFunctionStackIndex);
            int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX);
            print("callBackRefKey failed=" + callBackRefKey);
            luaCallBackReferenceKeyByFunctionName.put("signup-failed", callBackRefKey);
        }


        luaFunctionStackIndex = 4;
		if (luaState.isFunction(luaFunctionStackIndex)) {
			// storing that lua callback function so we can call it later (we stored it by getting a reference key to it
			luaState.pushValue(luaFunctionStackIndex);// making sure the function is on top of the stack.
			int callBackRefKey = luaState.ref(com.naef.jnlua.LuaState.REGISTRYINDEX); // returns a Ref Key to the Top of stack item
            print("callBackRefKey success=" + callBackRefKey);
			luaCallBackReferenceKeyByFunctionName.put("signup-success", callBackRefKey);
		}


		SignUpHandler signUpHandler = new SignUpHandler() {
			@Override
			public void onSuccess(CognitoUser user, boolean signUpConfirmationState,
								  CognitoUserCodeDeliveryDetails cognitoUserCodeDeliveryDetails) {
				// Check signUpConfirmationState to see if the user is already confirmed


				Boolean regState = signUpConfirmationState;
				if (signUpConfirmationState) {
					// User is already confirmed
					print("Sign up successful! ");
				}
				else {
					print("User is not confirmed");
					//confirmSignUp(cognitoUserCodeDeliveryDetails);
				}

				Hashtable<String, Object> event = new Hashtable<>();
				event.put("signUpConfirmationState", signUpConfirmationState);
				callBackLua("signup-success", event);
			}

			@Override
			public void onFailure(Exception exception) {
				//closeWaitDialog();
				print("Sign up failed - " + AppHelper.formatException(exception));
				Hashtable<String, Object> event = new Hashtable<>();
				event.put("errorMessage", AppHelper.formatException(exception));
				callBackLua("signup-failed", event);
			}
		};

		CognitoUserAttributes userAttributes = new CognitoUserAttributes();
		userAttributes.addAttribute("name", name);
		userAttributes.addAttribute("email", email);


		print("signing up...");
		AppHelper.init(CoronaEnvironment.getApplicationContext());
		AppHelper.getPool().signUpInBackground(email, password, userAttributes, null, signUpHandler);
		return 0;

	}

//	/**
//	 * The following Lua function has been called:  library.init( listener )
//	 * <p>
//	 * Warning! This method is not called on the main thread.
//	 * @param L Reference to the Lua state that the Lua function was called from.
//	 * @return Returns the number of values to be returned by the library.init() function.
//	 */
//	@SuppressWarnings({"WeakerAccess", "SameReturnValue"})
//	public int init(LuaState L) {
//		int listenerIndex = 1;
//
//		if ( CoronaLua.isListener( L, listenerIndex, EVENT_NAME ) ) {
//			fListener = CoronaLua.newRef( L, listenerIndex );
//		}
//
//		return 0;
//	}
//
//	/**
//	 * The following Lua function has been called:  library.show( word )
//	 * <p>
//	 * Warning! This method is not called on the main thread.
//	 * @param L Reference to the Lua state that the Lua function was called from.
//	 * @return Returns the number of values to be returned by the library.show() function.
//	 */
//	@SuppressWarnings("WeakerAccess")
//	public int show(LuaState L) {
//		// Fetch a reference to the Corona activity.
//		// Note: Will be null if the end-user has just backed out of the activity.
//		CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
//		if (activity == null) {
//			return 0;
//		}
//
//		// Fetch the first argument from the called Lua function.
//		String word = L.checkString( 1 );
//		if ( null == word ) {
//			word = "corona";
//		}
//
//		// Create web view on the main UI thread.
//		final String url = "http://dictionary.reference.com/browse/" + word;
//		activity.runOnUiThread(new Runnable() {
//			@Override
//			public void run() {
//				// Fetch a reference to the Corona activity.
//				// Note: Will be null if the end-user has just backed out of the activity.
//				CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
//				if (activity == null) {
//					return;
//				}
//
//				// Create and set up the web view.
//				WebView view = new WebView(activity);
//
//				// Prevent redirect which causes an external browser to be launched
//				// because some sites detect phone/tablet and redirect.
//				view.setWebViewClient(new WebViewClient() {
//					@Override
//					public boolean shouldOverrideUrlLoading(WebView view, String url) {
//						return false;
//					}
//				});
//
//				// Display the web view.
//				activity.getOverlayView().addView(view);
//				view.loadUrl( url );
//			}
//		} );
//
//
//		// This will send event via dispatchEvent in 5 seconds. Not that dispatchEvent is called from
//		// background thread, but it will use runtime dispatcher to select proper thread for Lua message dispatch
//		(new Thread() {
//			@Override
//			public void run() {
//				// Sleep for 5 seconds
//				try {
//					Thread.sleep(5000);
//				} catch (InterruptedException ignored) {}
//
//				// dispatch message!
//				dispatchEvent("Hello!");
//			}
//		}).start();
//
//		return 0;
//	}

	/** Implements the library.init() Lua function. */
	@SuppressWarnings("unused")
	private class loginWrapper implements NamedJavaFunction {
		/**
		 * Gets the name of the Lua function as it would appear in the Lua script.
		 * @return Returns the name of the custom Lua function.
		 */
		@Override
		public String getName() {
			return "login";
		}
		
		/**
		 * This method is called when the Lua function is called.
		 * <p>
		 * Warning! This method is not called on the main UI thread.
		 * @param L Reference to the Lua state.
		 *                 Needed to retrieve the Lua function's parameters and to return values back to Lua.
		 * @return Returns the number of values to be returned by the Lua function.
		 */
		@Override
		public int invoke(LuaState L) {
			return login(L);
		}
	}

	/** Implements the library.show() Lua function. */
	@SuppressWarnings("unused")
	private class logoutWrapper implements NamedJavaFunction {
		/**
		 * Gets the name of the Lua function as it would appear in the Lua script.
		 * @return Returns the name of the custom Lua function.
		 */
		@Override
		public String getName() {
			return "logout";
		}
		
		/**
		 * This method is called when the Lua function is called.
		 * <p>
		 * Warning! This method is not called on the main UI thread.
		 * @param L Reference to the Lua state.
		 *                 Needed to retrieve the Lua function's parameters and to return values back to Lua.
		 * @return Returns the number of values to be returned by the Lua function.
		 */
		@Override
		public int invoke(LuaState L) {
			return logout(L);
		}
	}

	/** Implements the library.show() Lua function. */
	@SuppressWarnings("unused")
	private class signupWrapper implements NamedJavaFunction {
		/**
		 * Gets the name of the Lua function as it would appear in the Lua script.
		 * @return Returns the name of the custom Lua function.
		 */
		@Override
		public String getName() {
			return "signup";
		}

		/**
		 * This method is called when the Lua function is called.
		 * <p>
		 * Warning! This method is not called on the main UI thread.
		 * @param L Reference to the Lua state.
		 *                 Needed to retrieve the Lua function's parameters and to return values back to Lua.
		 * @return Returns the number of values to be returned by the Lua function.
		 */
		@Override
		public int invoke(LuaState L) {
			return signup(L);
		}
	}

	@SuppressWarnings("unused")
	private class getUserDetailsWrapper implements NamedJavaFunction {
		/**
		 * Gets the name of the Lua function as it would appear in the Lua script.
		 * @return Returns the name of the custom Lua function.
		 */
		@Override
		public String getName() {
			return "getUserDetails";
		}

		/**
		 * This method is called when the Lua function is called.
		 * <p>
		 * Warning! This method is not called on the main UI thread.
		 * @param L Reference to the Lua state.
		 *                 Needed to retrieve the Lua function's parameters and to return values back to Lua.
		 * @return Returns the number of values to be returned by the Lua function.
		 */
		@Override
		public int invoke(LuaState L) {
			return getUserDetails(L);
		}
	}

	@SuppressWarnings("unused")
	private class loginSSOWrapper implements NamedJavaFunction {
		/**
		 * Gets the name of the Lua function as it would appear in the Lua script.
		 * @return Returns the name of the custom Lua function.
		 */
		@Override
		public String getName() {
			return "loginSSO";
		}

		/**
		 * This method is called when the Lua function is called.
		 * <p>
		 * Warning! This method is not called on the main UI thread.
		 * @param L Reference to the Lua state.
		 *                 Needed to retrieve the Lua function's parameters and to return values back to Lua.
		 * @return Returns the number of values to be returned by the Lua function.
		 */
		@Override
		public int invoke(LuaState L) {
			return loginSSO(L);
		}
	}
}
