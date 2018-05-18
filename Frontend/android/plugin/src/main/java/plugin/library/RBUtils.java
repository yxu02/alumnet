package plugin.library;


import android.util.Log;

import com.ansca.corona.CoronaEnvironment;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.LuaType;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import static com.naef.jnlua.LuaType.FUNCTION;

/**
 * Created by Red Beach on 12/9/16. Last update on 12/21/17
 * RBUtils - v6
 */

public class RBUtils {
    public static String TAG = "Corona | Plugin-Cognito";
    public static boolean isPrintEnabled = true;

    public static void print(Object value) {
        if (isPrintEnabled) {
            String text = value.toString();
            Log.d(TAG, text);
        }
    }

    public static int getAndroidAPIVersion() {
        return android.os.Build.VERSION.SDK_INT;
    }


    /**
     * The following Lua function has been called:  library.setDebugModeOn( bool )
     * <p>
     * Warning! This method is not called on the main thread.
     * @param luaState Reference to the Lua state that the Lua function was called from.
     * @return Returns the number of values to be returned by the library.setWifiEnabled() function.
     */
    public static int setDebugModeOn(LuaState luaState) {
        // Fetch the first argument from the called Lua function.
        boolean valueFromLua = luaState.checkBoolean(1);

        isPrintEnabled = valueFromLua;

        return 0; // Return 1 to indicate that this Lua function returns 1 value.
    }




    public static int dumpTable(com.naef.jnlua.LuaState luaState, Integer luaTableStackIndex ) {
        // Print the Lua function's argument to the Android logging system.
        try {
            print("on dumpTable - " + luaTableStackIndex.toString());
            // Check if the Lua function's first argument is a Lua table.
            // Will throw an exception if it is not a table or if no argument was given.
            //luaState.checkType(luaTableStackIndex, com.naef.jnlua.LuaType.TABLE);
            if (luaState.isTable(luaTableStackIndex) == false) {
                print("No table at stack index " + luaTableStackIndex);
                return 0;
            }

            // Print all of the key/value paris in the Lua table.
            int tableSize = luaState.length(luaTableStackIndex);
            System.out.println("{");
            for (luaState.pushNil(); luaState.next(luaTableStackIndex); luaState.pop(1)) {
                // Fetch the table entry's string key.
                // An index of -2 accesses the key that was pushed into the Lua stack by luaState.next() up above.
                String keyName = null;
                com.naef.jnlua.LuaType luaType = luaState.type(-2);
                switch (luaType) {
                    case STRING:
                        // Fetch the table entry's string key.
                        keyName = luaState.toString(-2);
                        break;
                    case NUMBER:
                        // The key will be a number if the given Lua table is really an array.
                        // In this case, the key is an array index. Do not call luaState.toString() on the
                        // numeric key or else Lua will convert the key to a string from within the Lua table.
                        keyName = Integer.toString(luaState.toInteger(-2));
                        break;
                }
                if (keyName == null) {
                    System.out.println("A valid key was not found. Skip this table entry.");
                    continue;
                }

                // Fetch the table entry's value in string form.
                // An index of -1 accesses the entry's value that was pushed into the Lua stack by luaState.next() above.
                String valueString;
                luaType = luaState.type(-1);
                switch (luaType) {
                    case STRING:
                        valueString = luaState.toString(-1);
                        break;
                    case BOOLEAN:
                        valueString = Boolean.toString(luaState.toBoolean(-1));
                        break;
                    case NUMBER:
                        valueString = Double.toString(luaState.toNumber(-1));
                        break;
                    default:
                        valueString = luaType.displayText();
                        break;
                }
                if (valueString == null) {
                    valueString = "";
                }

                // Print the table entry to the Android logging system.
                System.out.println("   [" + keyName + "] = " + valueString);
            }
            System.out.println("}");
        }
        catch (Exception ex) {
            // An exception will occur if given an invalid argument or no argument. Print the error.
            ex.printStackTrace();
        }

        // Return 0 since this Lua function does not return any values.
        return 0;
    }

    public static void dumpStack(LuaState luaState){
        print("- - - - on dumpStack - - - -");
        Integer i;
        Integer top = luaState.getTop();
        if (top == 0 ) {
            print("stack is empty!");
        }
        //print("num of elements on stack=" + top.toString());
        for (i = 1; i <= top; i++) {  /* repeat for each level */
            LuaType t = luaState.type(i);
            switch (t) {
                case STRING:  /* strings */
                    print("[" + i.toString() + "] (string)=" + luaState.toString(i));
                    break;

                case BOOLEAN:  /* booleans */
                    print("[" + i.toString() + "] (boolean)=" + (luaState.toBoolean(i)?"true" : "false"));
                    break;

                case NUMBER:  /* numbers */
                    Double n = luaState.toNumber(i);
                    print("[" + i.toString() + "] (number) =" + n.toString());
                    break;

                case FUNCTION:  /* function */
                    print("[" + i.toString() + "] (function)");
                    break;

                case TABLE:  /* table */
                    print("[" + i.toString() + "] (table)");
                    //dumpTable(luaState,i);
                    break;

                default:  /* other values */
                    print("[" + i.toString() + "] (" + t.toString() + ")" + luaState.toString(i));
                    break;

            }
            //print("");  /* put a separator */
        }
        print("\n");  /* end the listing */
        print("- - - - - - - - - - - -");
    }



    // this is used when to return just more than 1 table as param
    public static void callBackLua(final int luaFunctionReferenceKey, final List<Hashtable<String, Object>> tableList, final boolean doNotUnref){
        print("on callBackLua - luaFunctionReferenceKey=" + Integer.toString(luaFunctionReferenceKey));
        //print("on callBackLua");
        // Set up a dispatcher which allows us to send a task to the Corona runtime thread from another thread.
        // This way we can call the given Lua function on the same thread that Lua runs in.
        // This dispatcher will only send tasks to the Corona runtime that owns the given Lua state object.
        // Once the Corona runtime is disposed/destroyed, which happens when the Corona activity is destroyed,
        // then this dispatcher will no longer be able to send tasks.
        //        final com.ansca.corona.CoronaRuntimeTaskDispatcher dispatcher = new com.ansca.corona.CoronaRuntimeTaskDispatcher(luaState);

        final com.ansca.corona.CoronaRuntimeTaskDispatcher dispatcher = CoronaEnvironment.getCoronaActivity().getRuntimeTaskDispatcher();


        // Post a Runnable object on the UI thread that will call the given Lua function.
        com.ansca.corona.CoronaEnvironment.getCoronaActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // *** We are now running in the main UI thread. ***

                // Create a task that will call the given Lua function.
                // This task's execute() method will be called on the Corona runtime thread, just before rendering a frame.
                com.ansca.corona.CoronaRuntimeTask task = new com.ansca.corona.CoronaRuntimeTask() {
                    @Override
                    public void executeUsing(com.ansca.corona.CoronaRuntime runtime) {
                        // *** We are now running on the Corona runtime thread. ***
                        try {

                            // Fetch the Corona runtime's Lua state.
                            com.naef.jnlua.LuaState luaState = runtime.getLuaState();

                            //print("A luaType num of elements= " + luaState.getTop());

                            luaState.setTop(0); // clearing lua stack
                            //print("lua stack cleared");

                            // Fetch the Lua function stored in the registry and push it to the top of the stack.
                            luaState.rawGet(com.naef.jnlua.LuaState.REGISTRYINDEX, luaFunctionReferenceKey);


                            if (!doNotUnref) {
                                // Remove the Lua function from the registry.
                                luaState.unref(com.naef.jnlua.LuaState.REGISTRYINDEX, luaFunctionReferenceKey);
                                print("unrefered luaFunctionReferenceKey=" + Integer.toString(luaFunctionReferenceKey));
                            } else {
                                print("NOT unrefering luaFunctionReferenceKey=" + Integer.toString(luaFunctionReferenceKey));
                            }



                            LuaType luaType = luaState.type(1);

                            if (luaType !=  FUNCTION){
                                print("Trying to call a callback function that does not exist! Ignoring the call...");
                                dumpStack(luaState);
                                return ;
                            }

                            Integer tableListSize = tableList.size();
                            //print("tableListSize= " + tableListSize.toString());
                            if (tableListSize == 0) { // just call the callback passing no arguments
                                print("calling the callback wih no arguments");
                                // Call the Lua function that was just pushed to the top of the stack.
                                // The 1st argument indicates the number of arguments that we are passing to the Lua function.
                                // The 2nd argument indicates the number of return values to accept from the Lua function.
                                // In this case, we are calling this Lua function without arguments and accepting no return values.
                                // Note: If you want to call the Lua function with arguments, then you need to push each argument
                                //       value to the luaState object's stack.
                                luaState.call(0, 0);


                            } else if (tableListSize == 1) { // just call the callback passing 1

                                Hashtable<String, Object> tableEntry = tableList.get(0);

                                int numOfProperties = tableEntry.size();

                                // Create a new Lua array within the Lua state to copy the Java array's values to.
                                // Creating a Lua array in this manner automatically pushes it on the Lua stack.
                                // For best performance, you should pre-allocate the Lua array in one shot like below if the array size is known.
                                // The newTable() method's first argument should be set to the array's length.
                                // The newTable() method's second argument should be zero since we are not creating a key/value table in Lua.
                                luaState.newTable(0, numOfProperties);
                                int luaTableStackIndex = luaState.getTop();


                                for (String key : tableEntry.keySet()) {

                                    Object value = tableEntry.get(key);

                                    if (value instanceof String) {
                                        // do something String related to foo
                                        luaState.pushString(value.toString());
                                    } else if (value instanceof Integer) {
                                        luaState.pushInteger((int) value);
                                    } else if (value instanceof Long) {
                                        luaState.pushNumber(((Long) value).doubleValue());
                                    } else if (value instanceof Double) {
                                        luaState.pushNumber((double) value);
                                    } else if (value instanceof Boolean) {
                                        luaState.pushBoolean((boolean) value);
                                    } else {
                                        print("UNKNOWN TYPE!");
                                        continue;
                                    }
                                    luaState.setField(luaTableStackIndex, key);
                                }


                                // Call the Lua function that was just pushed to the top of the stack.
                                // The 1st argument indicates the number of arguments that we are passing to the Lua function.
                                // The 2nd argument indicates the number of return values to accept from the Lua function.
                                // In this case, we are calling this Lua function with 1 arguments and accepting no return values.
                                // Note: If you want to call the Lua function with arguments, then you need to push each argument
                                //       value to the luaState object's stack.
                                //print("going to call luaState.call");
                                luaState.call(1, 0);

                            } else {

                                // Create a new Lua array within the Lua state to copy the Java array's values to.
                                // Creating a Lua array in this manner automatically pushes it on the Lua stack.
                                // For best performance, you should pre-allocate the Lua array in one shot like below if the array size is known.
                                // The newTable() method's first argument should be set to the array's length.
                                // The newTable() method's second argument should be zero since we are not creating a key/value table in Lua.
                                luaState.newTable(tableListSize, 0);
                                int luaTableStackIndex = luaState.getTop();
                                //print("created table of size=" + tableListSize);
                                //dumpStack(luaState);

                                // Copy the Java array's values to the Lua array.
                                for (int index = 0; index < tableListSize; index++) {

                                    Hashtable<String, Object> tableEntry = tableList.get(index);

                                    int numOfProperties = tableEntry.size();
                                    //print("numOfProperties=" + numOfProperties);
                                    // Create a new Lua array within the Lua state to copy the Java array's values to.
                                    // Creating a Lua array in this manner automatically pushes it on the Lua stack.
                                    // For best performance, you should pre-allocate the Lua array in one shot like below if the array size is known.
                                    // The newTable() method's first argument should be set to the array's length.
                                    // The newTable() method's second argument should be zero since we are not creating a key/value table in Lua.
                                    luaState.newTable(0, numOfProperties);
                                    int luaTableStackEntryIndex = luaState.getTop();
                                    //print("created item table of size=" + numOfProperties);
                                    //dumpStack(luaState);


                                    for (String key : tableEntry.keySet()) {


                                        Object value = tableEntry.get(key);

                                        if (value instanceof String) {
                                            // do something String related to foo
                                            luaState.pushString(value.toString());
                                        } else if (value instanceof Integer) {
                                            luaState.pushInteger((int) value);
                                        } else if (value instanceof Long) {
                                            luaState.pushNumber(((Long) value).doubleValue());
                                        } else if (value instanceof Double) {
                                            luaState.pushNumber((double) value);
                                        } else if (value instanceof Boolean) {
                                            luaState.pushBoolean((boolean) value);
                                        } else {
                                            print("UNKNOWN TYPE!");
                                            continue;
                                        }
                                        //print("luaTableStackEntryIndex=" + luaTableStackEntryIndex);
                                        //dumpStack(luaState);

                                        luaState.setField(luaTableStackEntryIndex, key);
                                        //print("setField");
                                        //dumpStack(luaState);


                                    }

                                    // Assign the above pushed value to the next Lua array element.
                                    // We do an "index + 1" because arrays in Lua are 1-based by default.
                                    luaState.rawSet(luaTableStackIndex, index + 1);
                                    //print("after rawSet");
                                    //dumpStack(luaState);

                                }
                                // Call the Lua function that was just pushed to the top of the stack.
                                // The 1st argument indicates the number of arguments that we are passing to the Lua function.
                                // The 2nd argument indicates the number of return values to accept from the Lua function.
                                // In this case, we are calling this Lua function with 1 arguments and accepting no return values.
                                // Note: If you want to call the Lua function with arguments, then you need to push each argument
                                //       value to the luaState object's stack.
                                //print("going to call luaState.call");
                                luaState.call(1, 0);
                            }

                        }
                        catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                };

                // Send the above task to the Corona runtime asynchronously.
                // The send() method will do nothing if the Corona runtime is no longer available, which can
                // happen if the runtime was disposed/destroyed after the user has exited the Corona activity.
                dispatcher.send(task);
            }
        });
    }



    // this is used when to return just 1 table as param
    public static void callBackLua(final int luaFunctionReferenceKey, final Hashtable<String, Object> tableToReturnAsParam, boolean doNotUnRef) {
        List<Hashtable<String, Object>> tableList  = new ArrayList<Hashtable<String, Object>>();
        tableList.add(tableToReturnAsParam);

        callBackLua(luaFunctionReferenceKey, tableList, doNotUnRef);
    }



    /**
     * Private method used to fetch a Lua table entry's value in string form.
     * @param luaState Reference to the Lua state that contains the table.
     * @param luaTableStackIndex Index to the Lua table within the Lua stack.
     * @param keyName String key of the Lua table entry to access.
     * @return Returns the specified Lua table entry's value in string form.
     *         Will return "nil" if the key was not found in the Lua table.
     * @source: Corona Sample Codes (PrintTableValuesXYLuaFunction.java)
     */
    public static String getLuaTableEntryValueFrom(com.naef.jnlua.LuaState luaState, int luaTableStackIndex, String keyName) {
        // Fetch the value for the given key from the Lua table.
        // The getField() method will push the entry's value on to the Lua stack.
        // It will push nil if the value was not found.
        luaState.getField(luaTableStackIndex, keyName);

        // The table entry's value can now be accessed on the Lua stack with an index of -1.
        // Determine the type of value it is and then convert it to a string.
        String valueString;
        com.naef.jnlua.LuaType luaType = luaState.type(-1);
        switch (luaType) {
            case STRING:
                valueString = luaState.toString(-1);
                break;
            case BOOLEAN:
                valueString = Boolean.toString(luaState.toBoolean(-1));
                break;
            case NUMBER:
                valueString = Double.toString(luaState.toNumber(-1));
                break;
            default:
                valueString = luaType.displayText();
                break;
        }
        if (valueString == null) {
            valueString = com.naef.jnlua.LuaType.NIL.displayText();
        }

        // Pop the table entry's value off of the stack that was pushed by the getField() method call up above.
        luaState.pop(1);

        // Return the table entry's value string.
        return valueString;
    }
}
